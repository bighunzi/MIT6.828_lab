
obj/user/faultio.debug：     文件格式 elf32-i386


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
  80002c:	e8 3e 00 00 00       	call   80006f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	75 1d                	jne    80005d <umain+0x2a>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800040:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800045:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80004a:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80004b:	83 ec 0c             	sub    $0xc,%esp
  80004e:	68 8e 22 80 00       	push   $0x80228e
  800053:	e8 0f 01 00 00       	call   800167 <cprintf>
}
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    
		cprintf("eflags wrong\n");
  80005d:	83 ec 0c             	sub    $0xc,%esp
  800060:	68 80 22 80 00       	push   $0x802280
  800065:	e8 fd 00 00 00       	call   800167 <cprintf>
  80006a:	83 c4 10             	add    $0x10,%esp
  80006d:	eb d1                	jmp    800040 <umain+0xd>

0080006f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800077:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80007a:	e8 80 0a 00 00       	call   800aff <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80008a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008f:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800094:	85 db                	test   %ebx,%ebx
  800096:	7e 07                	jle    80009f <libmain+0x30>
		binaryname = argv[0];
  800098:	8b 06                	mov    (%esi),%eax
  80009a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009f:	83 ec 08             	sub    $0x8,%esp
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
  8000a4:	e8 8a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a9:	e8 0a 00 00 00       	call   8000b8 <exit>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000be:	e8 9d 0e 00 00       	call   800f60 <close_all>
	sys_env_destroy(0);
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	6a 00                	push   $0x0
  8000c8:	e8 f1 09 00 00       	call   800abe <sys_env_destroy>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 04             	sub    $0x4,%esp
  8000d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000dc:	8b 13                	mov    (%ebx),%edx
  8000de:	8d 42 01             	lea    0x1(%edx),%eax
  8000e1:	89 03                	mov    %eax,(%ebx)
  8000e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ef:	74 09                	je     8000fa <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000fa:	83 ec 08             	sub    $0x8,%esp
  8000fd:	68 ff 00 00 00       	push   $0xff
  800102:	8d 43 08             	lea    0x8(%ebx),%eax
  800105:	50                   	push   %eax
  800106:	e8 76 09 00 00       	call   800a81 <sys_cputs>
		b->idx = 0;
  80010b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	eb db                	jmp    8000f1 <putch+0x1f>

00800116 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800126:	00 00 00 
	b.cnt = 0;
  800129:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800130:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800133:	ff 75 0c             	push   0xc(%ebp)
  800136:	ff 75 08             	push   0x8(%ebp)
  800139:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013f:	50                   	push   %eax
  800140:	68 d2 00 80 00       	push   $0x8000d2
  800145:	e8 14 01 00 00       	call   80025e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014a:	83 c4 08             	add    $0x8,%esp
  80014d:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800153:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800159:	50                   	push   %eax
  80015a:	e8 22 09 00 00       	call   800a81 <sys_cputs>

	return b.cnt;
}
  80015f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800170:	50                   	push   %eax
  800171:	ff 75 08             	push   0x8(%ebp)
  800174:	e8 9d ff ff ff       	call   800116 <vcprintf>
	va_end(ap);

	return cnt;
}
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	57                   	push   %edi
  80017f:	56                   	push   %esi
  800180:	53                   	push   %ebx
  800181:	83 ec 1c             	sub    $0x1c,%esp
  800184:	89 c7                	mov    %eax,%edi
  800186:	89 d6                	mov    %edx,%esi
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018e:	89 d1                	mov    %edx,%ecx
  800190:	89 c2                	mov    %eax,%edx
  800192:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800195:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800198:	8b 45 10             	mov    0x10(%ebp),%eax
  80019b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a8:	39 c2                	cmp    %eax,%edx
  8001aa:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ad:	72 3e                	jb     8001ed <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	ff 75 18             	push   0x18(%ebp)
  8001b5:	83 eb 01             	sub    $0x1,%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	50                   	push   %eax
  8001ba:	83 ec 08             	sub    $0x8,%esp
  8001bd:	ff 75 e4             	push   -0x1c(%ebp)
  8001c0:	ff 75 e0             	push   -0x20(%ebp)
  8001c3:	ff 75 dc             	push   -0x24(%ebp)
  8001c6:	ff 75 d8             	push   -0x28(%ebp)
  8001c9:	e8 62 1e 00 00       	call   802030 <__udivdi3>
  8001ce:	83 c4 18             	add    $0x18,%esp
  8001d1:	52                   	push   %edx
  8001d2:	50                   	push   %eax
  8001d3:	89 f2                	mov    %esi,%edx
  8001d5:	89 f8                	mov    %edi,%eax
  8001d7:	e8 9f ff ff ff       	call   80017b <printnum>
  8001dc:	83 c4 20             	add    $0x20,%esp
  8001df:	eb 13                	jmp    8001f4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	56                   	push   %esi
  8001e5:	ff 75 18             	push   0x18(%ebp)
  8001e8:	ff d7                	call   *%edi
  8001ea:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001ed:	83 eb 01             	sub    $0x1,%ebx
  8001f0:	85 db                	test   %ebx,%ebx
  8001f2:	7f ed                	jg     8001e1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f4:	83 ec 08             	sub    $0x8,%esp
  8001f7:	56                   	push   %esi
  8001f8:	83 ec 04             	sub    $0x4,%esp
  8001fb:	ff 75 e4             	push   -0x1c(%ebp)
  8001fe:	ff 75 e0             	push   -0x20(%ebp)
  800201:	ff 75 dc             	push   -0x24(%ebp)
  800204:	ff 75 d8             	push   -0x28(%ebp)
  800207:	e8 44 1f 00 00       	call   802150 <__umoddi3>
  80020c:	83 c4 14             	add    $0x14,%esp
  80020f:	0f be 80 b2 22 80 00 	movsbl 0x8022b2(%eax),%eax
  800216:	50                   	push   %eax
  800217:	ff d7                	call   *%edi
}
  800219:	83 c4 10             	add    $0x10,%esp
  80021c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021f:	5b                   	pop    %ebx
  800220:	5e                   	pop    %esi
  800221:	5f                   	pop    %edi
  800222:	5d                   	pop    %ebp
  800223:	c3                   	ret    

00800224 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80022a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	3b 50 04             	cmp    0x4(%eax),%edx
  800233:	73 0a                	jae    80023f <sprintputch+0x1b>
		*b->buf++ = ch;
  800235:	8d 4a 01             	lea    0x1(%edx),%ecx
  800238:	89 08                	mov    %ecx,(%eax)
  80023a:	8b 45 08             	mov    0x8(%ebp),%eax
  80023d:	88 02                	mov    %al,(%edx)
}
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    

00800241 <printfmt>:
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800247:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80024a:	50                   	push   %eax
  80024b:	ff 75 10             	push   0x10(%ebp)
  80024e:	ff 75 0c             	push   0xc(%ebp)
  800251:	ff 75 08             	push   0x8(%ebp)
  800254:	e8 05 00 00 00       	call   80025e <vprintfmt>
}
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    

0080025e <vprintfmt>:
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 3c             	sub    $0x3c,%esp
  800267:	8b 75 08             	mov    0x8(%ebp),%esi
  80026a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80026d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800270:	eb 0a                	jmp    80027c <vprintfmt+0x1e>
			putch(ch, putdat);
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	53                   	push   %ebx
  800276:	50                   	push   %eax
  800277:	ff d6                	call   *%esi
  800279:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80027c:	83 c7 01             	add    $0x1,%edi
  80027f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800283:	83 f8 25             	cmp    $0x25,%eax
  800286:	74 0c                	je     800294 <vprintfmt+0x36>
			if (ch == '\0')
  800288:	85 c0                	test   %eax,%eax
  80028a:	75 e6                	jne    800272 <vprintfmt+0x14>
}
  80028c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028f:	5b                   	pop    %ebx
  800290:	5e                   	pop    %esi
  800291:	5f                   	pop    %edi
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    
		padc = ' ';
  800294:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800298:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80029f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002a6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ad:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002b2:	8d 47 01             	lea    0x1(%edi),%eax
  8002b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b8:	0f b6 17             	movzbl (%edi),%edx
  8002bb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002be:	3c 55                	cmp    $0x55,%al
  8002c0:	0f 87 bb 03 00 00    	ja     800681 <vprintfmt+0x423>
  8002c6:	0f b6 c0             	movzbl %al,%eax
  8002c9:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  8002d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002d3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002d7:	eb d9                	jmp    8002b2 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002dc:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002e0:	eb d0                	jmp    8002b2 <vprintfmt+0x54>
  8002e2:	0f b6 d2             	movzbl %dl,%edx
  8002e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ed:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002f3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002f7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002fa:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002fd:	83 f9 09             	cmp    $0x9,%ecx
  800300:	77 55                	ja     800357 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800302:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800305:	eb e9                	jmp    8002f0 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800307:	8b 45 14             	mov    0x14(%ebp),%eax
  80030a:	8b 00                	mov    (%eax),%eax
  80030c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030f:	8b 45 14             	mov    0x14(%ebp),%eax
  800312:	8d 40 04             	lea    0x4(%eax),%eax
  800315:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80031b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80031f:	79 91                	jns    8002b2 <vprintfmt+0x54>
				width = precision, precision = -1;
  800321:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800324:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800327:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80032e:	eb 82                	jmp    8002b2 <vprintfmt+0x54>
  800330:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800333:	85 d2                	test   %edx,%edx
  800335:	b8 00 00 00 00       	mov    $0x0,%eax
  80033a:	0f 49 c2             	cmovns %edx,%eax
  80033d:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800343:	e9 6a ff ff ff       	jmp    8002b2 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80034b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800352:	e9 5b ff ff ff       	jmp    8002b2 <vprintfmt+0x54>
  800357:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80035a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035d:	eb bc                	jmp    80031b <vprintfmt+0xbd>
			lflag++;
  80035f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800365:	e9 48 ff ff ff       	jmp    8002b2 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80036a:	8b 45 14             	mov    0x14(%ebp),%eax
  80036d:	8d 78 04             	lea    0x4(%eax),%edi
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	53                   	push   %ebx
  800374:	ff 30                	push   (%eax)
  800376:	ff d6                	call   *%esi
			break;
  800378:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80037b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80037e:	e9 9d 02 00 00       	jmp    800620 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 78 04             	lea    0x4(%eax),%edi
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	89 d0                	mov    %edx,%eax
  80038d:	f7 d8                	neg    %eax
  80038f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800392:	83 f8 0f             	cmp    $0xf,%eax
  800395:	7f 23                	jg     8003ba <vprintfmt+0x15c>
  800397:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	74 18                	je     8003ba <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003a2:	52                   	push   %edx
  8003a3:	68 95 26 80 00       	push   $0x802695
  8003a8:	53                   	push   %ebx
  8003a9:	56                   	push   %esi
  8003aa:	e8 92 fe ff ff       	call   800241 <printfmt>
  8003af:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003b5:	e9 66 02 00 00       	jmp    800620 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003ba:	50                   	push   %eax
  8003bb:	68 ca 22 80 00       	push   $0x8022ca
  8003c0:	53                   	push   %ebx
  8003c1:	56                   	push   %esi
  8003c2:	e8 7a fe ff ff       	call   800241 <printfmt>
  8003c7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ca:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003cd:	e9 4e 02 00 00       	jmp    800620 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	83 c0 04             	add    $0x4,%eax
  8003d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003e0:	85 d2                	test   %edx,%edx
  8003e2:	b8 c3 22 80 00       	mov    $0x8022c3,%eax
  8003e7:	0f 45 c2             	cmovne %edx,%eax
  8003ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f1:	7e 06                	jle    8003f9 <vprintfmt+0x19b>
  8003f3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003f7:	75 0d                	jne    800406 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003fc:	89 c7                	mov    %eax,%edi
  8003fe:	03 45 e0             	add    -0x20(%ebp),%eax
  800401:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800404:	eb 55                	jmp    80045b <vprintfmt+0x1fd>
  800406:	83 ec 08             	sub    $0x8,%esp
  800409:	ff 75 d8             	push   -0x28(%ebp)
  80040c:	ff 75 cc             	push   -0x34(%ebp)
  80040f:	e8 0a 03 00 00       	call   80071e <strnlen>
  800414:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800417:	29 c1                	sub    %eax,%ecx
  800419:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800421:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800425:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800428:	eb 0f                	jmp    800439 <vprintfmt+0x1db>
					putch(padc, putdat);
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	53                   	push   %ebx
  80042e:	ff 75 e0             	push   -0x20(%ebp)
  800431:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800433:	83 ef 01             	sub    $0x1,%edi
  800436:	83 c4 10             	add    $0x10,%esp
  800439:	85 ff                	test   %edi,%edi
  80043b:	7f ed                	jg     80042a <vprintfmt+0x1cc>
  80043d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800440:	85 d2                	test   %edx,%edx
  800442:	b8 00 00 00 00       	mov    $0x0,%eax
  800447:	0f 49 c2             	cmovns %edx,%eax
  80044a:	29 c2                	sub    %eax,%edx
  80044c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80044f:	eb a8                	jmp    8003f9 <vprintfmt+0x19b>
					putch(ch, putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	53                   	push   %ebx
  800455:	52                   	push   %edx
  800456:	ff d6                	call   *%esi
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800460:	83 c7 01             	add    $0x1,%edi
  800463:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800467:	0f be d0             	movsbl %al,%edx
  80046a:	85 d2                	test   %edx,%edx
  80046c:	74 4b                	je     8004b9 <vprintfmt+0x25b>
  80046e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800472:	78 06                	js     80047a <vprintfmt+0x21c>
  800474:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800478:	78 1e                	js     800498 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80047a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80047e:	74 d1                	je     800451 <vprintfmt+0x1f3>
  800480:	0f be c0             	movsbl %al,%eax
  800483:	83 e8 20             	sub    $0x20,%eax
  800486:	83 f8 5e             	cmp    $0x5e,%eax
  800489:	76 c6                	jbe    800451 <vprintfmt+0x1f3>
					putch('?', putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	53                   	push   %ebx
  80048f:	6a 3f                	push   $0x3f
  800491:	ff d6                	call   *%esi
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	eb c3                	jmp    80045b <vprintfmt+0x1fd>
  800498:	89 cf                	mov    %ecx,%edi
  80049a:	eb 0e                	jmp    8004aa <vprintfmt+0x24c>
				putch(' ', putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	53                   	push   %ebx
  8004a0:	6a 20                	push   $0x20
  8004a2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004a4:	83 ef 01             	sub    $0x1,%edi
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	85 ff                	test   %edi,%edi
  8004ac:	7f ee                	jg     80049c <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ae:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004b1:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b4:	e9 67 01 00 00       	jmp    800620 <vprintfmt+0x3c2>
  8004b9:	89 cf                	mov    %ecx,%edi
  8004bb:	eb ed                	jmp    8004aa <vprintfmt+0x24c>
	if (lflag >= 2)
  8004bd:	83 f9 01             	cmp    $0x1,%ecx
  8004c0:	7f 1b                	jg     8004dd <vprintfmt+0x27f>
	else if (lflag)
  8004c2:	85 c9                	test   %ecx,%ecx
  8004c4:	74 63                	je     800529 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ce:	99                   	cltd   
  8004cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 40 04             	lea    0x4(%eax),%eax
  8004d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004db:	eb 17                	jmp    8004f4 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8b 50 04             	mov    0x4(%eax),%edx
  8004e3:	8b 00                	mov    (%eax),%eax
  8004e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 40 08             	lea    0x8(%eax),%eax
  8004f1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004fa:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004ff:	85 c9                	test   %ecx,%ecx
  800501:	0f 89 ff 00 00 00    	jns    800606 <vprintfmt+0x3a8>
				putch('-', putdat);
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	53                   	push   %ebx
  80050b:	6a 2d                	push   $0x2d
  80050d:	ff d6                	call   *%esi
				num = -(long long) num;
  80050f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800512:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800515:	f7 da                	neg    %edx
  800517:	83 d1 00             	adc    $0x0,%ecx
  80051a:	f7 d9                	neg    %ecx
  80051c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80051f:	bf 0a 00 00 00       	mov    $0xa,%edi
  800524:	e9 dd 00 00 00       	jmp    800606 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8b 00                	mov    (%eax),%eax
  80052e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800531:	99                   	cltd   
  800532:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 40 04             	lea    0x4(%eax),%eax
  80053b:	89 45 14             	mov    %eax,0x14(%ebp)
  80053e:	eb b4                	jmp    8004f4 <vprintfmt+0x296>
	if (lflag >= 2)
  800540:	83 f9 01             	cmp    $0x1,%ecx
  800543:	7f 1e                	jg     800563 <vprintfmt+0x305>
	else if (lflag)
  800545:	85 c9                	test   %ecx,%ecx
  800547:	74 32                	je     80057b <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 10                	mov    (%eax),%edx
  80054e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800553:	8d 40 04             	lea    0x4(%eax),%eax
  800556:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800559:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80055e:	e9 a3 00 00 00       	jmp    800606 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8b 10                	mov    (%eax),%edx
  800568:	8b 48 04             	mov    0x4(%eax),%ecx
  80056b:	8d 40 08             	lea    0x8(%eax),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800571:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800576:	e9 8b 00 00 00       	jmp    800606 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8b 10                	mov    (%eax),%edx
  800580:	b9 00 00 00 00       	mov    $0x0,%ecx
  800585:	8d 40 04             	lea    0x4(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800590:	eb 74                	jmp    800606 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800592:	83 f9 01             	cmp    $0x1,%ecx
  800595:	7f 1b                	jg     8005b2 <vprintfmt+0x354>
	else if (lflag)
  800597:	85 c9                	test   %ecx,%ecx
  800599:	74 2c                	je     8005c7 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a5:	8d 40 04             	lea    0x4(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ab:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005b0:	eb 54                	jmp    800606 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ba:	8d 40 08             	lea    0x8(%eax),%eax
  8005bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005c0:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005c5:	eb 3f                	jmp    800606 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8b 10                	mov    (%eax),%edx
  8005cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d1:	8d 40 04             	lea    0x4(%eax),%eax
  8005d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005d7:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005dc:	eb 28                	jmp    800606 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	53                   	push   %ebx
  8005e2:	6a 30                	push   $0x30
  8005e4:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e6:	83 c4 08             	add    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	6a 78                	push   $0x78
  8005ec:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005f8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005fb:	8d 40 04             	lea    0x4(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800601:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80060d:	50                   	push   %eax
  80060e:	ff 75 e0             	push   -0x20(%ebp)
  800611:	57                   	push   %edi
  800612:	51                   	push   %ecx
  800613:	52                   	push   %edx
  800614:	89 da                	mov    %ebx,%edx
  800616:	89 f0                	mov    %esi,%eax
  800618:	e8 5e fb ff ff       	call   80017b <printnum>
			break;
  80061d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800623:	e9 54 fc ff ff       	jmp    80027c <vprintfmt+0x1e>
	if (lflag >= 2)
  800628:	83 f9 01             	cmp    $0x1,%ecx
  80062b:	7f 1b                	jg     800648 <vprintfmt+0x3ea>
	else if (lflag)
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	74 2c                	je     80065d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063b:	8d 40 04             	lea    0x4(%eax),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800641:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800646:	eb be                	jmp    800606 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 10                	mov    (%eax),%edx
  80064d:	8b 48 04             	mov    0x4(%eax),%ecx
  800650:	8d 40 08             	lea    0x8(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800656:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80065b:	eb a9                	jmp    800606 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 10                	mov    (%eax),%edx
  800662:	b9 00 00 00 00       	mov    $0x0,%ecx
  800667:	8d 40 04             	lea    0x4(%eax),%eax
  80066a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800672:	eb 92                	jmp    800606 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 25                	push   $0x25
  80067a:	ff d6                	call   *%esi
			break;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	eb 9f                	jmp    800620 <vprintfmt+0x3c2>
			putch('%', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 25                	push   $0x25
  800687:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	89 f8                	mov    %edi,%eax
  80068e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800692:	74 05                	je     800699 <vprintfmt+0x43b>
  800694:	83 e8 01             	sub    $0x1,%eax
  800697:	eb f5                	jmp    80068e <vprintfmt+0x430>
  800699:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80069c:	eb 82                	jmp    800620 <vprintfmt+0x3c2>

0080069e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	83 ec 18             	sub    $0x18,%esp
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	74 26                	je     8006e5 <vsnprintf+0x47>
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	7e 22                	jle    8006e5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c3:	ff 75 14             	push   0x14(%ebp)
  8006c6:	ff 75 10             	push   0x10(%ebp)
  8006c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006cc:	50                   	push   %eax
  8006cd:	68 24 02 80 00       	push   $0x800224
  8006d2:	e8 87 fb ff ff       	call   80025e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e0:	83 c4 10             	add    $0x10,%esp
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    
		return -E_INVAL;
  8006e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ea:	eb f7                	jmp    8006e3 <vsnprintf+0x45>

008006ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f5:	50                   	push   %eax
  8006f6:	ff 75 10             	push   0x10(%ebp)
  8006f9:	ff 75 0c             	push   0xc(%ebp)
  8006fc:	ff 75 08             	push   0x8(%ebp)
  8006ff:	e8 9a ff ff ff       	call   80069e <vsnprintf>
	va_end(ap);

	return rc;
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070c:	b8 00 00 00 00       	mov    $0x0,%eax
  800711:	eb 03                	jmp    800716 <strlen+0x10>
		n++;
  800713:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800716:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071a:	75 f7                	jne    800713 <strlen+0xd>
	return n;
}
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800724:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
  80072c:	eb 03                	jmp    800731 <strnlen+0x13>
		n++;
  80072e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800731:	39 d0                	cmp    %edx,%eax
  800733:	74 08                	je     80073d <strnlen+0x1f>
  800735:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800739:	75 f3                	jne    80072e <strnlen+0x10>
  80073b:	89 c2                	mov    %eax,%edx
	return n;
}
  80073d:	89 d0                	mov    %edx,%eax
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	53                   	push   %ebx
  800745:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800748:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
  800750:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800754:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800757:	83 c0 01             	add    $0x1,%eax
  80075a:	84 d2                	test   %dl,%dl
  80075c:	75 f2                	jne    800750 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80075e:	89 c8                	mov    %ecx,%eax
  800760:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	53                   	push   %ebx
  800769:	83 ec 10             	sub    $0x10,%esp
  80076c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076f:	53                   	push   %ebx
  800770:	e8 91 ff ff ff       	call   800706 <strlen>
  800775:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800778:	ff 75 0c             	push   0xc(%ebp)
  80077b:	01 d8                	add    %ebx,%eax
  80077d:	50                   	push   %eax
  80077e:	e8 be ff ff ff       	call   800741 <strcpy>
	return dst;
}
  800783:	89 d8                	mov    %ebx,%eax
  800785:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	56                   	push   %esi
  80078e:	53                   	push   %ebx
  80078f:	8b 75 08             	mov    0x8(%ebp),%esi
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	89 f3                	mov    %esi,%ebx
  800797:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079a:	89 f0                	mov    %esi,%eax
  80079c:	eb 0f                	jmp    8007ad <strncpy+0x23>
		*dst++ = *src;
  80079e:	83 c0 01             	add    $0x1,%eax
  8007a1:	0f b6 0a             	movzbl (%edx),%ecx
  8007a4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a7:	80 f9 01             	cmp    $0x1,%cl
  8007aa:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007ad:	39 d8                	cmp    %ebx,%eax
  8007af:	75 ed                	jne    80079e <strncpy+0x14>
	}
	return ret;
}
  8007b1:	89 f0                	mov    %esi,%eax
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	56                   	push   %esi
  8007bb:	53                   	push   %ebx
  8007bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c7:	85 d2                	test   %edx,%edx
  8007c9:	74 21                	je     8007ec <strlcpy+0x35>
  8007cb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007cf:	89 f2                	mov    %esi,%edx
  8007d1:	eb 09                	jmp    8007dc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d3:	83 c1 01             	add    $0x1,%ecx
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007dc:	39 c2                	cmp    %eax,%edx
  8007de:	74 09                	je     8007e9 <strlcpy+0x32>
  8007e0:	0f b6 19             	movzbl (%ecx),%ebx
  8007e3:	84 db                	test   %bl,%bl
  8007e5:	75 ec                	jne    8007d3 <strlcpy+0x1c>
  8007e7:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007e9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ec:	29 f0                	sub    %esi,%eax
}
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007fb:	eb 06                	jmp    800803 <strcmp+0x11>
		p++, q++;
  8007fd:	83 c1 01             	add    $0x1,%ecx
  800800:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800803:	0f b6 01             	movzbl (%ecx),%eax
  800806:	84 c0                	test   %al,%al
  800808:	74 04                	je     80080e <strcmp+0x1c>
  80080a:	3a 02                	cmp    (%edx),%al
  80080c:	74 ef                	je     8007fd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080e:	0f b6 c0             	movzbl %al,%eax
  800811:	0f b6 12             	movzbl (%edx),%edx
  800814:	29 d0                	sub    %edx,%eax
}
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800822:	89 c3                	mov    %eax,%ebx
  800824:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800827:	eb 06                	jmp    80082f <strncmp+0x17>
		n--, p++, q++;
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80082f:	39 d8                	cmp    %ebx,%eax
  800831:	74 18                	je     80084b <strncmp+0x33>
  800833:	0f b6 08             	movzbl (%eax),%ecx
  800836:	84 c9                	test   %cl,%cl
  800838:	74 04                	je     80083e <strncmp+0x26>
  80083a:	3a 0a                	cmp    (%edx),%cl
  80083c:	74 eb                	je     800829 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083e:	0f b6 00             	movzbl (%eax),%eax
  800841:	0f b6 12             	movzbl (%edx),%edx
  800844:	29 d0                	sub    %edx,%eax
}
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    
		return 0;
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
  800850:	eb f4                	jmp    800846 <strncmp+0x2e>

00800852 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085c:	eb 03                	jmp    800861 <strchr+0xf>
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	0f b6 10             	movzbl (%eax),%edx
  800864:	84 d2                	test   %dl,%dl
  800866:	74 06                	je     80086e <strchr+0x1c>
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	75 f2                	jne    80085e <strchr+0xc>
  80086c:	eb 05                	jmp    800873 <strchr+0x21>
			return (char *) s;
	return 0;
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800882:	38 ca                	cmp    %cl,%dl
  800884:	74 09                	je     80088f <strfind+0x1a>
  800886:	84 d2                	test   %dl,%dl
  800888:	74 05                	je     80088f <strfind+0x1a>
	for (; *s; s++)
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	eb f0                	jmp    80087f <strfind+0xa>
			break;
	return (char *) s;
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	57                   	push   %edi
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
  800897:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80089d:	85 c9                	test   %ecx,%ecx
  80089f:	74 2f                	je     8008d0 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	09 c8                	or     %ecx,%eax
  8008a5:	a8 03                	test   $0x3,%al
  8008a7:	75 21                	jne    8008ca <memset+0x39>
		c &= 0xFF;
  8008a9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ad:	89 d0                	mov    %edx,%eax
  8008af:	c1 e0 08             	shl    $0x8,%eax
  8008b2:	89 d3                	mov    %edx,%ebx
  8008b4:	c1 e3 18             	shl    $0x18,%ebx
  8008b7:	89 d6                	mov    %edx,%esi
  8008b9:	c1 e6 10             	shl    $0x10,%esi
  8008bc:	09 f3                	or     %esi,%ebx
  8008be:	09 da                	or     %ebx,%edx
  8008c0:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008c2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008c5:	fc                   	cld    
  8008c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c8:	eb 06                	jmp    8008d0 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	fc                   	cld    
  8008ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d0:	89 f8                	mov    %edi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e5:	39 c6                	cmp    %eax,%esi
  8008e7:	73 32                	jae    80091b <memmove+0x44>
  8008e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ec:	39 c2                	cmp    %eax,%edx
  8008ee:	76 2b                	jbe    80091b <memmove+0x44>
		s += n;
		d += n;
  8008f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f3:	89 d6                	mov    %edx,%esi
  8008f5:	09 fe                	or     %edi,%esi
  8008f7:	09 ce                	or     %ecx,%esi
  8008f9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ff:	75 0e                	jne    80090f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800901:	83 ef 04             	sub    $0x4,%edi
  800904:	8d 72 fc             	lea    -0x4(%edx),%esi
  800907:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80090a:	fd                   	std    
  80090b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090d:	eb 09                	jmp    800918 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80090f:	83 ef 01             	sub    $0x1,%edi
  800912:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800915:	fd                   	std    
  800916:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800918:	fc                   	cld    
  800919:	eb 1a                	jmp    800935 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091b:	89 f2                	mov    %esi,%edx
  80091d:	09 c2                	or     %eax,%edx
  80091f:	09 ca                	or     %ecx,%edx
  800921:	f6 c2 03             	test   $0x3,%dl
  800924:	75 0a                	jne    800930 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800926:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800929:	89 c7                	mov    %eax,%edi
  80092b:	fc                   	cld    
  80092c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092e:	eb 05                	jmp    800935 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800930:	89 c7                	mov    %eax,%edi
  800932:	fc                   	cld    
  800933:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800935:	5e                   	pop    %esi
  800936:	5f                   	pop    %edi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80093f:	ff 75 10             	push   0x10(%ebp)
  800942:	ff 75 0c             	push   0xc(%ebp)
  800945:	ff 75 08             	push   0x8(%ebp)
  800948:	e8 8a ff ff ff       	call   8008d7 <memmove>
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095a:	89 c6                	mov    %eax,%esi
  80095c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095f:	eb 06                	jmp    800967 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800967:	39 f0                	cmp    %esi,%eax
  800969:	74 14                	je     80097f <memcmp+0x30>
		if (*s1 != *s2)
  80096b:	0f b6 08             	movzbl (%eax),%ecx
  80096e:	0f b6 1a             	movzbl (%edx),%ebx
  800971:	38 d9                	cmp    %bl,%cl
  800973:	74 ec                	je     800961 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800975:	0f b6 c1             	movzbl %cl,%eax
  800978:	0f b6 db             	movzbl %bl,%ebx
  80097b:	29 d8                	sub    %ebx,%eax
  80097d:	eb 05                	jmp    800984 <memcmp+0x35>
	}

	return 0;
  80097f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800991:	89 c2                	mov    %eax,%edx
  800993:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800996:	eb 03                	jmp    80099b <memfind+0x13>
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	39 d0                	cmp    %edx,%eax
  80099d:	73 04                	jae    8009a3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099f:	38 08                	cmp    %cl,(%eax)
  8009a1:	75 f5                	jne    800998 <memfind+0x10>
			break;
	return (void *) s;
}
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b1:	eb 03                	jmp    8009b6 <strtol+0x11>
		s++;
  8009b3:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009b6:	0f b6 02             	movzbl (%edx),%eax
  8009b9:	3c 20                	cmp    $0x20,%al
  8009bb:	74 f6                	je     8009b3 <strtol+0xe>
  8009bd:	3c 09                	cmp    $0x9,%al
  8009bf:	74 f2                	je     8009b3 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009c1:	3c 2b                	cmp    $0x2b,%al
  8009c3:	74 2a                	je     8009ef <strtol+0x4a>
	int neg = 0;
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009ca:	3c 2d                	cmp    $0x2d,%al
  8009cc:	74 2b                	je     8009f9 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ce:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d4:	75 0f                	jne    8009e5 <strtol+0x40>
  8009d6:	80 3a 30             	cmpb   $0x30,(%edx)
  8009d9:	74 28                	je     800a03 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009e2:	0f 44 d8             	cmove  %eax,%ebx
  8009e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ea:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009ed:	eb 46                	jmp    800a35 <strtol+0x90>
		s++;
  8009ef:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f7:	eb d5                	jmp    8009ce <strtol+0x29>
		s++, neg = 1;
  8009f9:	83 c2 01             	add    $0x1,%edx
  8009fc:	bf 01 00 00 00       	mov    $0x1,%edi
  800a01:	eb cb                	jmp    8009ce <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a07:	74 0e                	je     800a17 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a09:	85 db                	test   %ebx,%ebx
  800a0b:	75 d8                	jne    8009e5 <strtol+0x40>
		s++, base = 8;
  800a0d:	83 c2 01             	add    $0x1,%edx
  800a10:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a15:	eb ce                	jmp    8009e5 <strtol+0x40>
		s += 2, base = 16;
  800a17:	83 c2 02             	add    $0x2,%edx
  800a1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1f:	eb c4                	jmp    8009e5 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a21:	0f be c0             	movsbl %al,%eax
  800a24:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a27:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a2a:	7d 3a                	jge    800a66 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a2c:	83 c2 01             	add    $0x1,%edx
  800a2f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a33:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a35:	0f b6 02             	movzbl (%edx),%eax
  800a38:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a3b:	89 f3                	mov    %esi,%ebx
  800a3d:	80 fb 09             	cmp    $0x9,%bl
  800a40:	76 df                	jbe    800a21 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a42:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a45:	89 f3                	mov    %esi,%ebx
  800a47:	80 fb 19             	cmp    $0x19,%bl
  800a4a:	77 08                	ja     800a54 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a4c:	0f be c0             	movsbl %al,%eax
  800a4f:	83 e8 57             	sub    $0x57,%eax
  800a52:	eb d3                	jmp    800a27 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a54:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a57:	89 f3                	mov    %esi,%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 08                	ja     800a66 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a5e:	0f be c0             	movsbl %al,%eax
  800a61:	83 e8 37             	sub    $0x37,%eax
  800a64:	eb c1                	jmp    800a27 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6a:	74 05                	je     800a71 <strtol+0xcc>
		*endptr = (char *) s;
  800a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a71:	89 c8                	mov    %ecx,%eax
  800a73:	f7 d8                	neg    %eax
  800a75:	85 ff                	test   %edi,%edi
  800a77:	0f 45 c8             	cmovne %eax,%ecx
}
  800a7a:	89 c8                	mov    %ecx,%eax
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a92:	89 c3                	mov    %eax,%ebx
  800a94:	89 c7                	mov    %eax,%edi
  800a96:	89 c6                	mov    %eax,%esi
  800a98:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaa:	b8 01 00 00 00       	mov    $0x1,%eax
  800aaf:	89 d1                	mov    %edx,%ecx
  800ab1:	89 d3                	mov    %edx,%ebx
  800ab3:	89 d7                	mov    %edx,%edi
  800ab5:	89 d6                	mov    %edx,%esi
  800ab7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ac7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad4:	89 cb                	mov    %ecx,%ebx
  800ad6:	89 cf                	mov    %ecx,%edi
  800ad8:	89 ce                	mov    %ecx,%esi
  800ada:	cd 30                	int    $0x30
	if(check && ret > 0)
  800adc:	85 c0                	test   %eax,%eax
  800ade:	7f 08                	jg     800ae8 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae8:	83 ec 0c             	sub    $0xc,%esp
  800aeb:	50                   	push   %eax
  800aec:	6a 03                	push   $0x3
  800aee:	68 bf 25 80 00       	push   $0x8025bf
  800af3:	6a 2a                	push   $0x2a
  800af5:	68 dc 25 80 00       	push   $0x8025dc
  800afa:	e8 9e 13 00 00       	call   801e9d <_panic>

00800aff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0f:	89 d1                	mov    %edx,%ecx
  800b11:	89 d3                	mov    %edx,%ebx
  800b13:	89 d7                	mov    %edx,%edi
  800b15:	89 d6                	mov    %edx,%esi
  800b17:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_yield>:

void
sys_yield(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b46:	be 00 00 00 00       	mov    $0x0,%esi
  800b4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	b8 04 00 00 00       	mov    $0x4,%eax
  800b56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b59:	89 f7                	mov    %esi,%edi
  800b5b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7f 08                	jg     800b69 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	50                   	push   %eax
  800b6d:	6a 04                	push   $0x4
  800b6f:	68 bf 25 80 00       	push   $0x8025bf
  800b74:	6a 2a                	push   $0x2a
  800b76:	68 dc 25 80 00       	push   $0x8025dc
  800b7b:	e8 1d 13 00 00       	call   801e9d <_panic>

00800b80 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9a:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7f 08                	jg     800bab <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	50                   	push   %eax
  800baf:	6a 05                	push   $0x5
  800bb1:	68 bf 25 80 00       	push   $0x8025bf
  800bb6:	6a 2a                	push   $0x2a
  800bb8:	68 dc 25 80 00       	push   $0x8025dc
  800bbd:	e8 db 12 00 00       	call   801e9d <_panic>

00800bc2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bdb:	89 df                	mov    %ebx,%edi
  800bdd:	89 de                	mov    %ebx,%esi
  800bdf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7f 08                	jg     800bed <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	50                   	push   %eax
  800bf1:	6a 06                	push   $0x6
  800bf3:	68 bf 25 80 00       	push   $0x8025bf
  800bf8:	6a 2a                	push   $0x2a
  800bfa:	68 dc 25 80 00       	push   $0x8025dc
  800bff:	e8 99 12 00 00       	call   801e9d <_panic>

00800c04 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7f 08                	jg     800c2f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	50                   	push   %eax
  800c33:	6a 08                	push   $0x8
  800c35:	68 bf 25 80 00       	push   $0x8025bf
  800c3a:	6a 2a                	push   $0x2a
  800c3c:	68 dc 25 80 00       	push   $0x8025dc
  800c41:	e8 57 12 00 00       	call   801e9d <_panic>

00800c46 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7f 08                	jg     800c71 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	50                   	push   %eax
  800c75:	6a 09                	push   $0x9
  800c77:	68 bf 25 80 00       	push   $0x8025bf
  800c7c:	6a 2a                	push   $0x2a
  800c7e:	68 dc 25 80 00       	push   $0x8025dc
  800c83:	e8 15 12 00 00       	call   801e9d <_panic>

00800c88 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7f 08                	jg     800cb3 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 0a                	push   $0xa
  800cb9:	68 bf 25 80 00       	push   $0x8025bf
  800cbe:	6a 2a                	push   $0x2a
  800cc0:	68 dc 25 80 00       	push   $0x8025dc
  800cc5:	e8 d3 11 00 00       	call   801e9d <_panic>

00800cca <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdb:	be 00 00 00 00       	mov    $0x0,%esi
  800ce0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce6:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d03:	89 cb                	mov    %ecx,%ebx
  800d05:	89 cf                	mov    %ecx,%edi
  800d07:	89 ce                	mov    %ecx,%esi
  800d09:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	7f 08                	jg     800d17 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	50                   	push   %eax
  800d1b:	6a 0d                	push   $0xd
  800d1d:	68 bf 25 80 00       	push   $0x8025bf
  800d22:	6a 2a                	push   $0x2a
  800d24:	68 dc 25 80 00       	push   $0x8025dc
  800d29:	e8 6f 11 00 00       	call   801e9d <_panic>

00800d2e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d34:	ba 00 00 00 00       	mov    $0x0,%edx
  800d39:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3e:	89 d1                	mov    %edx,%ecx
  800d40:	89 d3                	mov    %edx,%ebx
  800d42:	89 d7                	mov    %edx,%edi
  800d44:	89 d6                	mov    %edx,%esi
  800d46:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
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
  800d5e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	b8 10 00 00 00       	mov    $0x10,%eax
  800d84:	89 df                	mov    %ebx,%edi
  800d86:	89 de                	mov    %ebx,%esi
  800d88:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	05 00 00 00 30       	add    $0x30000000,%eax
  800d9a:	c1 e8 0c             	shr    $0xc,%eax
}
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800daf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dbe:	89 c2                	mov    %eax,%edx
  800dc0:	c1 ea 16             	shr    $0x16,%edx
  800dc3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dca:	f6 c2 01             	test   $0x1,%dl
  800dcd:	74 29                	je     800df8 <fd_alloc+0x42>
  800dcf:	89 c2                	mov    %eax,%edx
  800dd1:	c1 ea 0c             	shr    $0xc,%edx
  800dd4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ddb:	f6 c2 01             	test   $0x1,%dl
  800dde:	74 18                	je     800df8 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800de0:	05 00 10 00 00       	add    $0x1000,%eax
  800de5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dea:	75 d2                	jne    800dbe <fd_alloc+0x8>
  800dec:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800df1:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800df6:	eb 05                	jmp    800dfd <fd_alloc+0x47>
			return 0;
  800df8:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 02                	mov    %eax,(%edx)
}
  800e02:	89 c8                	mov    %ecx,%eax
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e0c:	83 f8 1f             	cmp    $0x1f,%eax
  800e0f:	77 30                	ja     800e41 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e11:	c1 e0 0c             	shl    $0xc,%eax
  800e14:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e19:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e1f:	f6 c2 01             	test   $0x1,%dl
  800e22:	74 24                	je     800e48 <fd_lookup+0x42>
  800e24:	89 c2                	mov    %eax,%edx
  800e26:	c1 ea 0c             	shr    $0xc,%edx
  800e29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e30:	f6 c2 01             	test   $0x1,%dl
  800e33:	74 1a                	je     800e4f <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e38:	89 02                	mov    %eax,(%edx)
	return 0;
  800e3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    
		return -E_INVAL;
  800e41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e46:	eb f7                	jmp    800e3f <fd_lookup+0x39>
		return -E_INVAL;
  800e48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e4d:	eb f0                	jmp    800e3f <fd_lookup+0x39>
  800e4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e54:	eb e9                	jmp    800e3f <fd_lookup+0x39>

00800e56 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
  800e65:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e6a:	39 13                	cmp    %edx,(%ebx)
  800e6c:	74 37                	je     800ea5 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800e6e:	83 c0 01             	add    $0x1,%eax
  800e71:	8b 1c 85 68 26 80 00 	mov    0x802668(,%eax,4),%ebx
  800e78:	85 db                	test   %ebx,%ebx
  800e7a:	75 ee                	jne    800e6a <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e7c:	a1 00 40 80 00       	mov    0x804000,%eax
  800e81:	8b 40 58             	mov    0x58(%eax),%eax
  800e84:	83 ec 04             	sub    $0x4,%esp
  800e87:	52                   	push   %edx
  800e88:	50                   	push   %eax
  800e89:	68 ec 25 80 00       	push   $0x8025ec
  800e8e:	e8 d4 f2 ff ff       	call   800167 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e93:	83 c4 10             	add    $0x10,%esp
  800e96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9e:	89 1a                	mov    %ebx,(%edx)
}
  800ea0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    
			return 0;
  800ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaa:	eb ef                	jmp    800e9b <dev_lookup+0x45>

00800eac <fd_close>:
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 24             	sub    $0x24,%esp
  800eb5:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ebb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ebe:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ebf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ec5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ec8:	50                   	push   %eax
  800ec9:	e8 38 ff ff ff       	call   800e06 <fd_lookup>
  800ece:	89 c3                	mov    %eax,%ebx
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	78 05                	js     800edc <fd_close+0x30>
	    || fd != fd2)
  800ed7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800eda:	74 16                	je     800ef2 <fd_close+0x46>
		return (must_exist ? r : 0);
  800edc:	89 f8                	mov    %edi,%eax
  800ede:	84 c0                	test   %al,%al
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	0f 44 d8             	cmove  %eax,%ebx
}
  800ee8:	89 d8                	mov    %ebx,%eax
  800eea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ef2:	83 ec 08             	sub    $0x8,%esp
  800ef5:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ef8:	50                   	push   %eax
  800ef9:	ff 36                	push   (%esi)
  800efb:	e8 56 ff ff ff       	call   800e56 <dev_lookup>
  800f00:	89 c3                	mov    %eax,%ebx
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	78 1a                	js     800f23 <fd_close+0x77>
		if (dev->dev_close)
  800f09:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f0c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f0f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f14:	85 c0                	test   %eax,%eax
  800f16:	74 0b                	je     800f23 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f18:	83 ec 0c             	sub    $0xc,%esp
  800f1b:	56                   	push   %esi
  800f1c:	ff d0                	call   *%eax
  800f1e:	89 c3                	mov    %eax,%ebx
  800f20:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f23:	83 ec 08             	sub    $0x8,%esp
  800f26:	56                   	push   %esi
  800f27:	6a 00                	push   $0x0
  800f29:	e8 94 fc ff ff       	call   800bc2 <sys_page_unmap>
	return r;
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	eb b5                	jmp    800ee8 <fd_close+0x3c>

00800f33 <close>:

int
close(int fdnum)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3c:	50                   	push   %eax
  800f3d:	ff 75 08             	push   0x8(%ebp)
  800f40:	e8 c1 fe ff ff       	call   800e06 <fd_lookup>
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	79 02                	jns    800f4e <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f4c:	c9                   	leave  
  800f4d:	c3                   	ret    
		return fd_close(fd, 1);
  800f4e:	83 ec 08             	sub    $0x8,%esp
  800f51:	6a 01                	push   $0x1
  800f53:	ff 75 f4             	push   -0xc(%ebp)
  800f56:	e8 51 ff ff ff       	call   800eac <fd_close>
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	eb ec                	jmp    800f4c <close+0x19>

00800f60 <close_all>:

void
close_all(void)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	53                   	push   %ebx
  800f64:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f67:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	53                   	push   %ebx
  800f70:	e8 be ff ff ff       	call   800f33 <close>
	for (i = 0; i < MAXFD; i++)
  800f75:	83 c3 01             	add    $0x1,%ebx
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	83 fb 20             	cmp    $0x20,%ebx
  800f7e:	75 ec                	jne    800f6c <close_all+0xc>
}
  800f80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    

00800f85 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	57                   	push   %edi
  800f89:	56                   	push   %esi
  800f8a:	53                   	push   %ebx
  800f8b:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f8e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f91:	50                   	push   %eax
  800f92:	ff 75 08             	push   0x8(%ebp)
  800f95:	e8 6c fe ff ff       	call   800e06 <fd_lookup>
  800f9a:	89 c3                	mov    %eax,%ebx
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	78 7f                	js     801022 <dup+0x9d>
		return r;
	close(newfdnum);
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	ff 75 0c             	push   0xc(%ebp)
  800fa9:	e8 85 ff ff ff       	call   800f33 <close>

	newfd = INDEX2FD(newfdnum);
  800fae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fb1:	c1 e6 0c             	shl    $0xc,%esi
  800fb4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fbd:	89 3c 24             	mov    %edi,(%esp)
  800fc0:	e8 da fd ff ff       	call   800d9f <fd2data>
  800fc5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fc7:	89 34 24             	mov    %esi,(%esp)
  800fca:	e8 d0 fd ff ff       	call   800d9f <fd2data>
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fd5:	89 d8                	mov    %ebx,%eax
  800fd7:	c1 e8 16             	shr    $0x16,%eax
  800fda:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe1:	a8 01                	test   $0x1,%al
  800fe3:	74 11                	je     800ff6 <dup+0x71>
  800fe5:	89 d8                	mov    %ebx,%eax
  800fe7:	c1 e8 0c             	shr    $0xc,%eax
  800fea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff1:	f6 c2 01             	test   $0x1,%dl
  800ff4:	75 36                	jne    80102c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff6:	89 f8                	mov    %edi,%eax
  800ff8:	c1 e8 0c             	shr    $0xc,%eax
  800ffb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801002:	83 ec 0c             	sub    $0xc,%esp
  801005:	25 07 0e 00 00       	and    $0xe07,%eax
  80100a:	50                   	push   %eax
  80100b:	56                   	push   %esi
  80100c:	6a 00                	push   $0x0
  80100e:	57                   	push   %edi
  80100f:	6a 00                	push   $0x0
  801011:	e8 6a fb ff ff       	call   800b80 <sys_page_map>
  801016:	89 c3                	mov    %eax,%ebx
  801018:	83 c4 20             	add    $0x20,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 33                	js     801052 <dup+0xcd>
		goto err;

	return newfdnum;
  80101f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801022:	89 d8                	mov    %ebx,%eax
  801024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80102c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	25 07 0e 00 00       	and    $0xe07,%eax
  80103b:	50                   	push   %eax
  80103c:	ff 75 d4             	push   -0x2c(%ebp)
  80103f:	6a 00                	push   $0x0
  801041:	53                   	push   %ebx
  801042:	6a 00                	push   $0x0
  801044:	e8 37 fb ff ff       	call   800b80 <sys_page_map>
  801049:	89 c3                	mov    %eax,%ebx
  80104b:	83 c4 20             	add    $0x20,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	79 a4                	jns    800ff6 <dup+0x71>
	sys_page_unmap(0, newfd);
  801052:	83 ec 08             	sub    $0x8,%esp
  801055:	56                   	push   %esi
  801056:	6a 00                	push   $0x0
  801058:	e8 65 fb ff ff       	call   800bc2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80105d:	83 c4 08             	add    $0x8,%esp
  801060:	ff 75 d4             	push   -0x2c(%ebp)
  801063:	6a 00                	push   $0x0
  801065:	e8 58 fb ff ff       	call   800bc2 <sys_page_unmap>
	return r;
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	eb b3                	jmp    801022 <dup+0x9d>

0080106f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	83 ec 18             	sub    $0x18,%esp
  801077:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80107a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80107d:	50                   	push   %eax
  80107e:	56                   	push   %esi
  80107f:	e8 82 fd ff ff       	call   800e06 <fd_lookup>
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	78 3c                	js     8010c7 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80108b:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80108e:	83 ec 08             	sub    $0x8,%esp
  801091:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801094:	50                   	push   %eax
  801095:	ff 33                	push   (%ebx)
  801097:	e8 ba fd ff ff       	call   800e56 <dev_lookup>
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 24                	js     8010c7 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010a3:	8b 43 08             	mov    0x8(%ebx),%eax
  8010a6:	83 e0 03             	and    $0x3,%eax
  8010a9:	83 f8 01             	cmp    $0x1,%eax
  8010ac:	74 20                	je     8010ce <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b1:	8b 40 08             	mov    0x8(%eax),%eax
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	74 37                	je     8010ef <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010b8:	83 ec 04             	sub    $0x4,%esp
  8010bb:	ff 75 10             	push   0x10(%ebp)
  8010be:	ff 75 0c             	push   0xc(%ebp)
  8010c1:	53                   	push   %ebx
  8010c2:	ff d0                	call   *%eax
  8010c4:	83 c4 10             	add    $0x10,%esp
}
  8010c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ca:	5b                   	pop    %ebx
  8010cb:	5e                   	pop    %esi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ce:	a1 00 40 80 00       	mov    0x804000,%eax
  8010d3:	8b 40 58             	mov    0x58(%eax),%eax
  8010d6:	83 ec 04             	sub    $0x4,%esp
  8010d9:	56                   	push   %esi
  8010da:	50                   	push   %eax
  8010db:	68 2d 26 80 00       	push   $0x80262d
  8010e0:	e8 82 f0 ff ff       	call   800167 <cprintf>
		return -E_INVAL;
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ed:	eb d8                	jmp    8010c7 <read+0x58>
		return -E_NOT_SUPP;
  8010ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010f4:	eb d1                	jmp    8010c7 <read+0x58>

008010f6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 0c             	sub    $0xc,%esp
  8010ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801102:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801105:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110a:	eb 02                	jmp    80110e <readn+0x18>
  80110c:	01 c3                	add    %eax,%ebx
  80110e:	39 f3                	cmp    %esi,%ebx
  801110:	73 21                	jae    801133 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	89 f0                	mov    %esi,%eax
  801117:	29 d8                	sub    %ebx,%eax
  801119:	50                   	push   %eax
  80111a:	89 d8                	mov    %ebx,%eax
  80111c:	03 45 0c             	add    0xc(%ebp),%eax
  80111f:	50                   	push   %eax
  801120:	57                   	push   %edi
  801121:	e8 49 ff ff ff       	call   80106f <read>
		if (m < 0)
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 04                	js     801131 <readn+0x3b>
			return m;
		if (m == 0)
  80112d:	75 dd                	jne    80110c <readn+0x16>
  80112f:	eb 02                	jmp    801133 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801131:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801133:	89 d8                	mov    %ebx,%eax
  801135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	83 ec 18             	sub    $0x18,%esp
  801145:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801148:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114b:	50                   	push   %eax
  80114c:	53                   	push   %ebx
  80114d:	e8 b4 fc ff ff       	call   800e06 <fd_lookup>
  801152:	83 c4 10             	add    $0x10,%esp
  801155:	85 c0                	test   %eax,%eax
  801157:	78 37                	js     801190 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801159:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80115c:	83 ec 08             	sub    $0x8,%esp
  80115f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801162:	50                   	push   %eax
  801163:	ff 36                	push   (%esi)
  801165:	e8 ec fc ff ff       	call   800e56 <dev_lookup>
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	85 c0                	test   %eax,%eax
  80116f:	78 1f                	js     801190 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801171:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801175:	74 20                	je     801197 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801177:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117a:	8b 40 0c             	mov    0xc(%eax),%eax
  80117d:	85 c0                	test   %eax,%eax
  80117f:	74 37                	je     8011b8 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	ff 75 10             	push   0x10(%ebp)
  801187:	ff 75 0c             	push   0xc(%ebp)
  80118a:	56                   	push   %esi
  80118b:	ff d0                	call   *%eax
  80118d:	83 c4 10             	add    $0x10,%esp
}
  801190:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801197:	a1 00 40 80 00       	mov    0x804000,%eax
  80119c:	8b 40 58             	mov    0x58(%eax),%eax
  80119f:	83 ec 04             	sub    $0x4,%esp
  8011a2:	53                   	push   %ebx
  8011a3:	50                   	push   %eax
  8011a4:	68 49 26 80 00       	push   $0x802649
  8011a9:	e8 b9 ef ff ff       	call   800167 <cprintf>
		return -E_INVAL;
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b6:	eb d8                	jmp    801190 <write+0x53>
		return -E_NOT_SUPP;
  8011b8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011bd:	eb d1                	jmp    801190 <write+0x53>

008011bf <seek>:

int
seek(int fdnum, off_t offset)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	ff 75 08             	push   0x8(%ebp)
  8011cc:	e8 35 fc ff ff       	call   800e06 <fd_lookup>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 0e                	js     8011e6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011de:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	56                   	push   %esi
  8011ec:	53                   	push   %ebx
  8011ed:	83 ec 18             	sub    $0x18,%esp
  8011f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	53                   	push   %ebx
  8011f8:	e8 09 fc ff ff       	call   800e06 <fd_lookup>
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 34                	js     801238 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801204:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120d:	50                   	push   %eax
  80120e:	ff 36                	push   (%esi)
  801210:	e8 41 fc ff ff       	call   800e56 <dev_lookup>
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 1c                	js     801238 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801220:	74 1d                	je     80123f <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801225:	8b 40 18             	mov    0x18(%eax),%eax
  801228:	85 c0                	test   %eax,%eax
  80122a:	74 34                	je     801260 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80122c:	83 ec 08             	sub    $0x8,%esp
  80122f:	ff 75 0c             	push   0xc(%ebp)
  801232:	56                   	push   %esi
  801233:	ff d0                	call   *%eax
  801235:	83 c4 10             	add    $0x10,%esp
}
  801238:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80123f:	a1 00 40 80 00       	mov    0x804000,%eax
  801244:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801247:	83 ec 04             	sub    $0x4,%esp
  80124a:	53                   	push   %ebx
  80124b:	50                   	push   %eax
  80124c:	68 0c 26 80 00       	push   $0x80260c
  801251:	e8 11 ef ff ff       	call   800167 <cprintf>
		return -E_INVAL;
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125e:	eb d8                	jmp    801238 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801260:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801265:	eb d1                	jmp    801238 <ftruncate+0x50>

00801267 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	56                   	push   %esi
  80126b:	53                   	push   %ebx
  80126c:	83 ec 18             	sub    $0x18,%esp
  80126f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801272:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801275:	50                   	push   %eax
  801276:	ff 75 08             	push   0x8(%ebp)
  801279:	e8 88 fb ff ff       	call   800e06 <fd_lookup>
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 49                	js     8012ce <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801285:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128e:	50                   	push   %eax
  80128f:	ff 36                	push   (%esi)
  801291:	e8 c0 fb ff ff       	call   800e56 <dev_lookup>
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 31                	js     8012ce <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80129d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012a4:	74 2f                	je     8012d5 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b0:	00 00 00 
	stat->st_isdir = 0;
  8012b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012ba:	00 00 00 
	stat->st_dev = dev;
  8012bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	53                   	push   %ebx
  8012c7:	56                   	push   %esi
  8012c8:	ff 50 14             	call   *0x14(%eax)
  8012cb:	83 c4 10             	add    $0x10,%esp
}
  8012ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    
		return -E_NOT_SUPP;
  8012d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012da:	eb f2                	jmp    8012ce <fstat+0x67>

008012dc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	56                   	push   %esi
  8012e0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012e1:	83 ec 08             	sub    $0x8,%esp
  8012e4:	6a 00                	push   $0x0
  8012e6:	ff 75 08             	push   0x8(%ebp)
  8012e9:	e8 e4 01 00 00       	call   8014d2 <open>
  8012ee:	89 c3                	mov    %eax,%ebx
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 1b                	js     801312 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012f7:	83 ec 08             	sub    $0x8,%esp
  8012fa:	ff 75 0c             	push   0xc(%ebp)
  8012fd:	50                   	push   %eax
  8012fe:	e8 64 ff ff ff       	call   801267 <fstat>
  801303:	89 c6                	mov    %eax,%esi
	close(fd);
  801305:	89 1c 24             	mov    %ebx,(%esp)
  801308:	e8 26 fc ff ff       	call   800f33 <close>
	return r;
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	89 f3                	mov    %esi,%ebx
}
  801312:	89 d8                	mov    %ebx,%eax
  801314:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5d                   	pop    %ebp
  80131a:	c3                   	ret    

0080131b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	56                   	push   %esi
  80131f:	53                   	push   %ebx
  801320:	89 c6                	mov    %eax,%esi
  801322:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801324:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80132b:	74 27                	je     801354 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80132d:	6a 07                	push   $0x7
  80132f:	68 00 50 80 00       	push   $0x805000
  801334:	56                   	push   %esi
  801335:	ff 35 00 60 80 00    	push   0x806000
  80133b:	e8 13 0c 00 00       	call   801f53 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801340:	83 c4 0c             	add    $0xc,%esp
  801343:	6a 00                	push   $0x0
  801345:	53                   	push   %ebx
  801346:	6a 00                	push   $0x0
  801348:	e8 96 0b 00 00       	call   801ee3 <ipc_recv>
}
  80134d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801350:	5b                   	pop    %ebx
  801351:	5e                   	pop    %esi
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	6a 01                	push   $0x1
  801359:	e8 49 0c 00 00       	call   801fa7 <ipc_find_env>
  80135e:	a3 00 60 80 00       	mov    %eax,0x806000
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	eb c5                	jmp    80132d <fsipc+0x12>

00801368 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	8b 40 0c             	mov    0xc(%eax),%eax
  801374:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801379:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801381:	ba 00 00 00 00       	mov    $0x0,%edx
  801386:	b8 02 00 00 00       	mov    $0x2,%eax
  80138b:	e8 8b ff ff ff       	call   80131b <fsipc>
}
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <devfile_flush>:
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801398:	8b 45 08             	mov    0x8(%ebp),%eax
  80139b:	8b 40 0c             	mov    0xc(%eax),%eax
  80139e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a8:	b8 06 00 00 00       	mov    $0x6,%eax
  8013ad:	e8 69 ff ff ff       	call   80131b <fsipc>
}
  8013b2:	c9                   	leave  
  8013b3:	c3                   	ret    

008013b4 <devfile_stat>:
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	53                   	push   %ebx
  8013b8:	83 ec 04             	sub    $0x4,%esp
  8013bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013be:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8013d3:	e8 43 ff ff ff       	call   80131b <fsipc>
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 2c                	js     801408 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	68 00 50 80 00       	push   $0x805000
  8013e4:	53                   	push   %ebx
  8013e5:	e8 57 f3 ff ff       	call   800741 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013ea:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013f5:	a1 84 50 80 00       	mov    0x805084,%eax
  8013fa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801408:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <devfile_write>:
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	83 ec 0c             	sub    $0xc,%esp
  801413:	8b 45 10             	mov    0x10(%ebp),%eax
  801416:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80141b:	39 d0                	cmp    %edx,%eax
  80141d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801420:	8b 55 08             	mov    0x8(%ebp),%edx
  801423:	8b 52 0c             	mov    0xc(%edx),%edx
  801426:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80142c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801431:	50                   	push   %eax
  801432:	ff 75 0c             	push   0xc(%ebp)
  801435:	68 08 50 80 00       	push   $0x805008
  80143a:	e8 98 f4 ff ff       	call   8008d7 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80143f:	ba 00 00 00 00       	mov    $0x0,%edx
  801444:	b8 04 00 00 00       	mov    $0x4,%eax
  801449:	e8 cd fe ff ff       	call   80131b <fsipc>
}
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <devfile_read>:
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	56                   	push   %esi
  801454:	53                   	push   %ebx
  801455:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801458:	8b 45 08             	mov    0x8(%ebp),%eax
  80145b:	8b 40 0c             	mov    0xc(%eax),%eax
  80145e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801463:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801469:	ba 00 00 00 00       	mov    $0x0,%edx
  80146e:	b8 03 00 00 00       	mov    $0x3,%eax
  801473:	e8 a3 fe ff ff       	call   80131b <fsipc>
  801478:	89 c3                	mov    %eax,%ebx
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 1f                	js     80149d <devfile_read+0x4d>
	assert(r <= n);
  80147e:	39 f0                	cmp    %esi,%eax
  801480:	77 24                	ja     8014a6 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801482:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801487:	7f 33                	jg     8014bc <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801489:	83 ec 04             	sub    $0x4,%esp
  80148c:	50                   	push   %eax
  80148d:	68 00 50 80 00       	push   $0x805000
  801492:	ff 75 0c             	push   0xc(%ebp)
  801495:	e8 3d f4 ff ff       	call   8008d7 <memmove>
	return r;
  80149a:	83 c4 10             	add    $0x10,%esp
}
  80149d:	89 d8                	mov    %ebx,%eax
  80149f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a2:	5b                   	pop    %ebx
  8014a3:	5e                   	pop    %esi
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    
	assert(r <= n);
  8014a6:	68 7c 26 80 00       	push   $0x80267c
  8014ab:	68 83 26 80 00       	push   $0x802683
  8014b0:	6a 7c                	push   $0x7c
  8014b2:	68 98 26 80 00       	push   $0x802698
  8014b7:	e8 e1 09 00 00       	call   801e9d <_panic>
	assert(r <= PGSIZE);
  8014bc:	68 a3 26 80 00       	push   $0x8026a3
  8014c1:	68 83 26 80 00       	push   $0x802683
  8014c6:	6a 7d                	push   $0x7d
  8014c8:	68 98 26 80 00       	push   $0x802698
  8014cd:	e8 cb 09 00 00       	call   801e9d <_panic>

008014d2 <open>:
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	56                   	push   %esi
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 1c             	sub    $0x1c,%esp
  8014da:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014dd:	56                   	push   %esi
  8014de:	e8 23 f2 ff ff       	call   800706 <strlen>
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014eb:	7f 6c                	jg     801559 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f3:	50                   	push   %eax
  8014f4:	e8 bd f8 ff ff       	call   800db6 <fd_alloc>
  8014f9:	89 c3                	mov    %eax,%ebx
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 3c                	js     80153e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801502:	83 ec 08             	sub    $0x8,%esp
  801505:	56                   	push   %esi
  801506:	68 00 50 80 00       	push   $0x805000
  80150b:	e8 31 f2 ff ff       	call   800741 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801510:	8b 45 0c             	mov    0xc(%ebp),%eax
  801513:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801518:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151b:	b8 01 00 00 00       	mov    $0x1,%eax
  801520:	e8 f6 fd ff ff       	call   80131b <fsipc>
  801525:	89 c3                	mov    %eax,%ebx
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 19                	js     801547 <open+0x75>
	return fd2num(fd);
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	ff 75 f4             	push   -0xc(%ebp)
  801534:	e8 56 f8 ff ff       	call   800d8f <fd2num>
  801539:	89 c3                	mov    %eax,%ebx
  80153b:	83 c4 10             	add    $0x10,%esp
}
  80153e:	89 d8                	mov    %ebx,%eax
  801540:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801543:	5b                   	pop    %ebx
  801544:	5e                   	pop    %esi
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    
		fd_close(fd, 0);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	6a 00                	push   $0x0
  80154c:	ff 75 f4             	push   -0xc(%ebp)
  80154f:	e8 58 f9 ff ff       	call   800eac <fd_close>
		return r;
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	eb e5                	jmp    80153e <open+0x6c>
		return -E_BAD_PATH;
  801559:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80155e:	eb de                	jmp    80153e <open+0x6c>

00801560 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801566:	ba 00 00 00 00       	mov    $0x0,%edx
  80156b:	b8 08 00 00 00       	mov    $0x8,%eax
  801570:	e8 a6 fd ff ff       	call   80131b <fsipc>
}
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80157d:	68 af 26 80 00       	push   $0x8026af
  801582:	ff 75 0c             	push   0xc(%ebp)
  801585:	e8 b7 f1 ff ff       	call   800741 <strcpy>
	return 0;
}
  80158a:	b8 00 00 00 00       	mov    $0x0,%eax
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <devsock_close>:
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	53                   	push   %ebx
  801595:	83 ec 10             	sub    $0x10,%esp
  801598:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80159b:	53                   	push   %ebx
  80159c:	e8 45 0a 00 00       	call   801fe6 <pageref>
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	83 c4 10             	add    $0x10,%esp
		return 0;
  8015a6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8015ab:	83 fa 01             	cmp    $0x1,%edx
  8015ae:	74 05                	je     8015b5 <devsock_close+0x24>
}
  8015b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	ff 73 0c             	push   0xc(%ebx)
  8015bb:	e8 b7 02 00 00       	call   801877 <nsipc_close>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	eb eb                	jmp    8015b0 <devsock_close+0x1f>

008015c5 <devsock_write>:
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015cb:	6a 00                	push   $0x0
  8015cd:	ff 75 10             	push   0x10(%ebp)
  8015d0:	ff 75 0c             	push   0xc(%ebp)
  8015d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d6:	ff 70 0c             	push   0xc(%eax)
  8015d9:	e8 79 03 00 00       	call   801957 <nsipc_send>
}
  8015de:	c9                   	leave  
  8015df:	c3                   	ret    

008015e0 <devsock_read>:
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015e6:	6a 00                	push   $0x0
  8015e8:	ff 75 10             	push   0x10(%ebp)
  8015eb:	ff 75 0c             	push   0xc(%ebp)
  8015ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f1:	ff 70 0c             	push   0xc(%eax)
  8015f4:	e8 ef 02 00 00       	call   8018e8 <nsipc_recv>
}
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <fd2sockid>:
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801601:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801604:	52                   	push   %edx
  801605:	50                   	push   %eax
  801606:	e8 fb f7 ff ff       	call   800e06 <fd_lookup>
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 10                	js     801622 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801615:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80161b:	39 08                	cmp    %ecx,(%eax)
  80161d:	75 05                	jne    801624 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80161f:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801622:	c9                   	leave  
  801623:	c3                   	ret    
		return -E_NOT_SUPP;
  801624:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801629:	eb f7                	jmp    801622 <fd2sockid+0x27>

0080162b <alloc_sockfd>:
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	56                   	push   %esi
  80162f:	53                   	push   %ebx
  801630:	83 ec 1c             	sub    $0x1c,%esp
  801633:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801635:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	e8 78 f7 ff ff       	call   800db6 <fd_alloc>
  80163e:	89 c3                	mov    %eax,%ebx
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	78 43                	js     80168a <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801647:	83 ec 04             	sub    $0x4,%esp
  80164a:	68 07 04 00 00       	push   $0x407
  80164f:	ff 75 f4             	push   -0xc(%ebp)
  801652:	6a 00                	push   $0x0
  801654:	e8 e4 f4 ff ff       	call   800b3d <sys_page_alloc>
  801659:	89 c3                	mov    %eax,%ebx
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 28                	js     80168a <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801662:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801665:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80166b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80166d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801670:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801677:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80167a:	83 ec 0c             	sub    $0xc,%esp
  80167d:	50                   	push   %eax
  80167e:	e8 0c f7 ff ff       	call   800d8f <fd2num>
  801683:	89 c3                	mov    %eax,%ebx
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	eb 0c                	jmp    801696 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80168a:	83 ec 0c             	sub    $0xc,%esp
  80168d:	56                   	push   %esi
  80168e:	e8 e4 01 00 00       	call   801877 <nsipc_close>
		return r;
  801693:	83 c4 10             	add    $0x10,%esp
}
  801696:	89 d8                	mov    %ebx,%eax
  801698:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5e                   	pop    %esi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <accept>:
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a8:	e8 4e ff ff ff       	call   8015fb <fd2sockid>
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 1b                	js     8016cc <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016b1:	83 ec 04             	sub    $0x4,%esp
  8016b4:	ff 75 10             	push   0x10(%ebp)
  8016b7:	ff 75 0c             	push   0xc(%ebp)
  8016ba:	50                   	push   %eax
  8016bb:	e8 0e 01 00 00       	call   8017ce <nsipc_accept>
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	78 05                	js     8016cc <accept+0x2d>
	return alloc_sockfd(r);
  8016c7:	e8 5f ff ff ff       	call   80162b <alloc_sockfd>
}
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <bind>:
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	e8 1f ff ff ff       	call   8015fb <fd2sockid>
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 12                	js     8016f2 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8016e0:	83 ec 04             	sub    $0x4,%esp
  8016e3:	ff 75 10             	push   0x10(%ebp)
  8016e6:	ff 75 0c             	push   0xc(%ebp)
  8016e9:	50                   	push   %eax
  8016ea:	e8 31 01 00 00       	call   801820 <nsipc_bind>
  8016ef:	83 c4 10             	add    $0x10,%esp
}
  8016f2:	c9                   	leave  
  8016f3:	c3                   	ret    

008016f4 <shutdown>:
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fd:	e8 f9 fe ff ff       	call   8015fb <fd2sockid>
  801702:	85 c0                	test   %eax,%eax
  801704:	78 0f                	js     801715 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	ff 75 0c             	push   0xc(%ebp)
  80170c:	50                   	push   %eax
  80170d:	e8 43 01 00 00       	call   801855 <nsipc_shutdown>
  801712:	83 c4 10             	add    $0x10,%esp
}
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <connect>:
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80171d:	8b 45 08             	mov    0x8(%ebp),%eax
  801720:	e8 d6 fe ff ff       	call   8015fb <fd2sockid>
  801725:	85 c0                	test   %eax,%eax
  801727:	78 12                	js     80173b <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801729:	83 ec 04             	sub    $0x4,%esp
  80172c:	ff 75 10             	push   0x10(%ebp)
  80172f:	ff 75 0c             	push   0xc(%ebp)
  801732:	50                   	push   %eax
  801733:	e8 59 01 00 00       	call   801891 <nsipc_connect>
  801738:	83 c4 10             	add    $0x10,%esp
}
  80173b:	c9                   	leave  
  80173c:	c3                   	ret    

0080173d <listen>:
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	e8 b0 fe ff ff       	call   8015fb <fd2sockid>
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 0f                	js     80175e <listen+0x21>
	return nsipc_listen(r, backlog);
  80174f:	83 ec 08             	sub    $0x8,%esp
  801752:	ff 75 0c             	push   0xc(%ebp)
  801755:	50                   	push   %eax
  801756:	e8 6b 01 00 00       	call   8018c6 <nsipc_listen>
  80175b:	83 c4 10             	add    $0x10,%esp
}
  80175e:	c9                   	leave  
  80175f:	c3                   	ret    

00801760 <socket>:

int
socket(int domain, int type, int protocol)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801766:	ff 75 10             	push   0x10(%ebp)
  801769:	ff 75 0c             	push   0xc(%ebp)
  80176c:	ff 75 08             	push   0x8(%ebp)
  80176f:	e8 41 02 00 00       	call   8019b5 <nsipc_socket>
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	78 05                	js     801780 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80177b:	e8 ab fe ff ff       	call   80162b <alloc_sockfd>
}
  801780:	c9                   	leave  
  801781:	c3                   	ret    

00801782 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	53                   	push   %ebx
  801786:	83 ec 04             	sub    $0x4,%esp
  801789:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80178b:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801792:	74 26                	je     8017ba <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801794:	6a 07                	push   $0x7
  801796:	68 00 70 80 00       	push   $0x807000
  80179b:	53                   	push   %ebx
  80179c:	ff 35 00 80 80 00    	push   0x808000
  8017a2:	e8 ac 07 00 00       	call   801f53 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017a7:	83 c4 0c             	add    $0xc,%esp
  8017aa:	6a 00                	push   $0x0
  8017ac:	6a 00                	push   $0x0
  8017ae:	6a 00                	push   $0x0
  8017b0:	e8 2e 07 00 00       	call   801ee3 <ipc_recv>
}
  8017b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017ba:	83 ec 0c             	sub    $0xc,%esp
  8017bd:	6a 02                	push   $0x2
  8017bf:	e8 e3 07 00 00       	call   801fa7 <ipc_find_env>
  8017c4:	a3 00 80 80 00       	mov    %eax,0x808000
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	eb c6                	jmp    801794 <nsipc+0x12>

008017ce <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	56                   	push   %esi
  8017d2:	53                   	push   %ebx
  8017d3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017de:	8b 06                	mov    (%esi),%eax
  8017e0:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ea:	e8 93 ff ff ff       	call   801782 <nsipc>
  8017ef:	89 c3                	mov    %eax,%ebx
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	79 09                	jns    8017fe <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8017f5:	89 d8                	mov    %ebx,%eax
  8017f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fa:	5b                   	pop    %ebx
  8017fb:	5e                   	pop    %esi
  8017fc:	5d                   	pop    %ebp
  8017fd:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017fe:	83 ec 04             	sub    $0x4,%esp
  801801:	ff 35 10 70 80 00    	push   0x807010
  801807:	68 00 70 80 00       	push   $0x807000
  80180c:	ff 75 0c             	push   0xc(%ebp)
  80180f:	e8 c3 f0 ff ff       	call   8008d7 <memmove>
		*addrlen = ret->ret_addrlen;
  801814:	a1 10 70 80 00       	mov    0x807010,%eax
  801819:	89 06                	mov    %eax,(%esi)
  80181b:	83 c4 10             	add    $0x10,%esp
	return r;
  80181e:	eb d5                	jmp    8017f5 <nsipc_accept+0x27>

00801820 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801832:	53                   	push   %ebx
  801833:	ff 75 0c             	push   0xc(%ebp)
  801836:	68 04 70 80 00       	push   $0x807004
  80183b:	e8 97 f0 ff ff       	call   8008d7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801840:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801846:	b8 02 00 00 00       	mov    $0x2,%eax
  80184b:	e8 32 ff ff ff       	call   801782 <nsipc>
}
  801850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80185b:	8b 45 08             	mov    0x8(%ebp),%eax
  80185e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801863:	8b 45 0c             	mov    0xc(%ebp),%eax
  801866:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80186b:	b8 03 00 00 00       	mov    $0x3,%eax
  801870:	e8 0d ff ff ff       	call   801782 <nsipc>
}
  801875:	c9                   	leave  
  801876:	c3                   	ret    

00801877 <nsipc_close>:

int
nsipc_close(int s)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80187d:	8b 45 08             	mov    0x8(%ebp),%eax
  801880:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801885:	b8 04 00 00 00       	mov    $0x4,%eax
  80188a:	e8 f3 fe ff ff       	call   801782 <nsipc>
}
  80188f:	c9                   	leave  
  801890:	c3                   	ret    

00801891 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	53                   	push   %ebx
  801895:	83 ec 08             	sub    $0x8,%esp
  801898:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018a3:	53                   	push   %ebx
  8018a4:	ff 75 0c             	push   0xc(%ebp)
  8018a7:	68 04 70 80 00       	push   $0x807004
  8018ac:	e8 26 f0 ff ff       	call   8008d7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018b1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8018b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018bc:	e8 c1 fe ff ff       	call   801782 <nsipc>
}
  8018c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c4:	c9                   	leave  
  8018c5:	c3                   	ret    

008018c6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8018d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d7:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8018dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8018e1:	e8 9c fe ff ff       	call   801782 <nsipc>
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	56                   	push   %esi
  8018ec:	53                   	push   %ebx
  8018ed:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8018f8:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8018fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801901:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801906:	b8 07 00 00 00       	mov    $0x7,%eax
  80190b:	e8 72 fe ff ff       	call   801782 <nsipc>
  801910:	89 c3                	mov    %eax,%ebx
  801912:	85 c0                	test   %eax,%eax
  801914:	78 22                	js     801938 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801916:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80191b:	39 c6                	cmp    %eax,%esi
  80191d:	0f 4e c6             	cmovle %esi,%eax
  801920:	39 c3                	cmp    %eax,%ebx
  801922:	7f 1d                	jg     801941 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801924:	83 ec 04             	sub    $0x4,%esp
  801927:	53                   	push   %ebx
  801928:	68 00 70 80 00       	push   $0x807000
  80192d:	ff 75 0c             	push   0xc(%ebp)
  801930:	e8 a2 ef ff ff       	call   8008d7 <memmove>
  801935:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801938:	89 d8                	mov    %ebx,%eax
  80193a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5e                   	pop    %esi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801941:	68 bb 26 80 00       	push   $0x8026bb
  801946:	68 83 26 80 00       	push   $0x802683
  80194b:	6a 62                	push   $0x62
  80194d:	68 d0 26 80 00       	push   $0x8026d0
  801952:	e8 46 05 00 00       	call   801e9d <_panic>

00801957 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	53                   	push   %ebx
  80195b:	83 ec 04             	sub    $0x4,%esp
  80195e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801961:	8b 45 08             	mov    0x8(%ebp),%eax
  801964:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801969:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80196f:	7f 2e                	jg     80199f <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801971:	83 ec 04             	sub    $0x4,%esp
  801974:	53                   	push   %ebx
  801975:	ff 75 0c             	push   0xc(%ebp)
  801978:	68 0c 70 80 00       	push   $0x80700c
  80197d:	e8 55 ef ff ff       	call   8008d7 <memmove>
	nsipcbuf.send.req_size = size;
  801982:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801988:	8b 45 14             	mov    0x14(%ebp),%eax
  80198b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801990:	b8 08 00 00 00       	mov    $0x8,%eax
  801995:	e8 e8 fd ff ff       	call   801782 <nsipc>
}
  80199a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    
	assert(size < 1600);
  80199f:	68 dc 26 80 00       	push   $0x8026dc
  8019a4:	68 83 26 80 00       	push   $0x802683
  8019a9:	6a 6d                	push   $0x6d
  8019ab:	68 d0 26 80 00       	push   $0x8026d0
  8019b0:	e8 e8 04 00 00       	call   801e9d <_panic>

008019b5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019be:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8019c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c6:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8019cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ce:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8019d3:	b8 09 00 00 00       	mov    $0x9,%eax
  8019d8:	e8 a5 fd ff ff       	call   801782 <nsipc>
}
  8019dd:	c9                   	leave  
  8019de:	c3                   	ret    

008019df <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019e7:	83 ec 0c             	sub    $0xc,%esp
  8019ea:	ff 75 08             	push   0x8(%ebp)
  8019ed:	e8 ad f3 ff ff       	call   800d9f <fd2data>
  8019f2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019f4:	83 c4 08             	add    $0x8,%esp
  8019f7:	68 e8 26 80 00       	push   $0x8026e8
  8019fc:	53                   	push   %ebx
  8019fd:	e8 3f ed ff ff       	call   800741 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a02:	8b 46 04             	mov    0x4(%esi),%eax
  801a05:	2b 06                	sub    (%esi),%eax
  801a07:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a0d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a14:	00 00 00 
	stat->st_dev = &devpipe;
  801a17:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a1e:	30 80 00 
	return 0;
}
  801a21:	b8 00 00 00 00       	mov    $0x0,%eax
  801a26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    

00801a2d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	53                   	push   %ebx
  801a31:	83 ec 0c             	sub    $0xc,%esp
  801a34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a37:	53                   	push   %ebx
  801a38:	6a 00                	push   $0x0
  801a3a:	e8 83 f1 ff ff       	call   800bc2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a3f:	89 1c 24             	mov    %ebx,(%esp)
  801a42:	e8 58 f3 ff ff       	call   800d9f <fd2data>
  801a47:	83 c4 08             	add    $0x8,%esp
  801a4a:	50                   	push   %eax
  801a4b:	6a 00                	push   $0x0
  801a4d:	e8 70 f1 ff ff       	call   800bc2 <sys_page_unmap>
}
  801a52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <_pipeisclosed>:
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	57                   	push   %edi
  801a5b:	56                   	push   %esi
  801a5c:	53                   	push   %ebx
  801a5d:	83 ec 1c             	sub    $0x1c,%esp
  801a60:	89 c7                	mov    %eax,%edi
  801a62:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a64:	a1 00 40 80 00       	mov    0x804000,%eax
  801a69:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	57                   	push   %edi
  801a70:	e8 71 05 00 00       	call   801fe6 <pageref>
  801a75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a78:	89 34 24             	mov    %esi,(%esp)
  801a7b:	e8 66 05 00 00       	call   801fe6 <pageref>
		nn = thisenv->env_runs;
  801a80:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a86:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	39 cb                	cmp    %ecx,%ebx
  801a8e:	74 1b                	je     801aab <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a90:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a93:	75 cf                	jne    801a64 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a95:	8b 42 68             	mov    0x68(%edx),%eax
  801a98:	6a 01                	push   $0x1
  801a9a:	50                   	push   %eax
  801a9b:	53                   	push   %ebx
  801a9c:	68 ef 26 80 00       	push   $0x8026ef
  801aa1:	e8 c1 e6 ff ff       	call   800167 <cprintf>
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	eb b9                	jmp    801a64 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801aab:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801aae:	0f 94 c0             	sete   %al
  801ab1:	0f b6 c0             	movzbl %al,%eax
}
  801ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5f                   	pop    %edi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <devpipe_write>:
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	57                   	push   %edi
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	83 ec 28             	sub    $0x28,%esp
  801ac5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ac8:	56                   	push   %esi
  801ac9:	e8 d1 f2 ff ff       	call   800d9f <fd2data>
  801ace:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801adb:	75 09                	jne    801ae6 <devpipe_write+0x2a>
	return i;
  801add:	89 f8                	mov    %edi,%eax
  801adf:	eb 23                	jmp    801b04 <devpipe_write+0x48>
			sys_yield();
  801ae1:	e8 38 f0 ff ff       	call   800b1e <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae9:	8b 0b                	mov    (%ebx),%ecx
  801aeb:	8d 51 20             	lea    0x20(%ecx),%edx
  801aee:	39 d0                	cmp    %edx,%eax
  801af0:	72 1a                	jb     801b0c <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801af2:	89 da                	mov    %ebx,%edx
  801af4:	89 f0                	mov    %esi,%eax
  801af6:	e8 5c ff ff ff       	call   801a57 <_pipeisclosed>
  801afb:	85 c0                	test   %eax,%eax
  801afd:	74 e2                	je     801ae1 <devpipe_write+0x25>
				return 0;
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b07:	5b                   	pop    %ebx
  801b08:	5e                   	pop    %esi
  801b09:	5f                   	pop    %edi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b13:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	c1 fa 1f             	sar    $0x1f,%edx
  801b1b:	89 d1                	mov    %edx,%ecx
  801b1d:	c1 e9 1b             	shr    $0x1b,%ecx
  801b20:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b23:	83 e2 1f             	and    $0x1f,%edx
  801b26:	29 ca                	sub    %ecx,%edx
  801b28:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b2c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b30:	83 c0 01             	add    $0x1,%eax
  801b33:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b36:	83 c7 01             	add    $0x1,%edi
  801b39:	eb 9d                	jmp    801ad8 <devpipe_write+0x1c>

00801b3b <devpipe_read>:
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	57                   	push   %edi
  801b3f:	56                   	push   %esi
  801b40:	53                   	push   %ebx
  801b41:	83 ec 18             	sub    $0x18,%esp
  801b44:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b47:	57                   	push   %edi
  801b48:	e8 52 f2 ff ff       	call   800d9f <fd2data>
  801b4d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	be 00 00 00 00       	mov    $0x0,%esi
  801b57:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b5a:	75 13                	jne    801b6f <devpipe_read+0x34>
	return i;
  801b5c:	89 f0                	mov    %esi,%eax
  801b5e:	eb 02                	jmp    801b62 <devpipe_read+0x27>
				return i;
  801b60:	89 f0                	mov    %esi,%eax
}
  801b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    
			sys_yield();
  801b6a:	e8 af ef ff ff       	call   800b1e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b6f:	8b 03                	mov    (%ebx),%eax
  801b71:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b74:	75 18                	jne    801b8e <devpipe_read+0x53>
			if (i > 0)
  801b76:	85 f6                	test   %esi,%esi
  801b78:	75 e6                	jne    801b60 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801b7a:	89 da                	mov    %ebx,%edx
  801b7c:	89 f8                	mov    %edi,%eax
  801b7e:	e8 d4 fe ff ff       	call   801a57 <_pipeisclosed>
  801b83:	85 c0                	test   %eax,%eax
  801b85:	74 e3                	je     801b6a <devpipe_read+0x2f>
				return 0;
  801b87:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8c:	eb d4                	jmp    801b62 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b8e:	99                   	cltd   
  801b8f:	c1 ea 1b             	shr    $0x1b,%edx
  801b92:	01 d0                	add    %edx,%eax
  801b94:	83 e0 1f             	and    $0x1f,%eax
  801b97:	29 d0                	sub    %edx,%eax
  801b99:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ba4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ba7:	83 c6 01             	add    $0x1,%esi
  801baa:	eb ab                	jmp    801b57 <devpipe_read+0x1c>

00801bac <pipe>:
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb7:	50                   	push   %eax
  801bb8:	e8 f9 f1 ff ff       	call   800db6 <fd_alloc>
  801bbd:	89 c3                	mov    %eax,%ebx
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	0f 88 23 01 00 00    	js     801ced <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bca:	83 ec 04             	sub    $0x4,%esp
  801bcd:	68 07 04 00 00       	push   $0x407
  801bd2:	ff 75 f4             	push   -0xc(%ebp)
  801bd5:	6a 00                	push   $0x0
  801bd7:	e8 61 ef ff ff       	call   800b3d <sys_page_alloc>
  801bdc:	89 c3                	mov    %eax,%ebx
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	85 c0                	test   %eax,%eax
  801be3:	0f 88 04 01 00 00    	js     801ced <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801be9:	83 ec 0c             	sub    $0xc,%esp
  801bec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bef:	50                   	push   %eax
  801bf0:	e8 c1 f1 ff ff       	call   800db6 <fd_alloc>
  801bf5:	89 c3                	mov    %eax,%ebx
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	0f 88 db 00 00 00    	js     801cdd <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c02:	83 ec 04             	sub    $0x4,%esp
  801c05:	68 07 04 00 00       	push   $0x407
  801c0a:	ff 75 f0             	push   -0x10(%ebp)
  801c0d:	6a 00                	push   $0x0
  801c0f:	e8 29 ef ff ff       	call   800b3d <sys_page_alloc>
  801c14:	89 c3                	mov    %eax,%ebx
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	0f 88 bc 00 00 00    	js     801cdd <pipe+0x131>
	va = fd2data(fd0);
  801c21:	83 ec 0c             	sub    $0xc,%esp
  801c24:	ff 75 f4             	push   -0xc(%ebp)
  801c27:	e8 73 f1 ff ff       	call   800d9f <fd2data>
  801c2c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2e:	83 c4 0c             	add    $0xc,%esp
  801c31:	68 07 04 00 00       	push   $0x407
  801c36:	50                   	push   %eax
  801c37:	6a 00                	push   $0x0
  801c39:	e8 ff ee ff ff       	call   800b3d <sys_page_alloc>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	0f 88 82 00 00 00    	js     801ccd <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4b:	83 ec 0c             	sub    $0xc,%esp
  801c4e:	ff 75 f0             	push   -0x10(%ebp)
  801c51:	e8 49 f1 ff ff       	call   800d9f <fd2data>
  801c56:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c5d:	50                   	push   %eax
  801c5e:	6a 00                	push   $0x0
  801c60:	56                   	push   %esi
  801c61:	6a 00                	push   $0x0
  801c63:	e8 18 ef ff ff       	call   800b80 <sys_page_map>
  801c68:	89 c3                	mov    %eax,%ebx
  801c6a:	83 c4 20             	add    $0x20,%esp
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 4e                	js     801cbf <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c71:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801c76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c79:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c7e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c85:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c88:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	ff 75 f4             	push   -0xc(%ebp)
  801c9a:	e8 f0 f0 ff ff       	call   800d8f <fd2num>
  801c9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca4:	83 c4 04             	add    $0x4,%esp
  801ca7:	ff 75 f0             	push   -0x10(%ebp)
  801caa:	e8 e0 f0 ff ff       	call   800d8f <fd2num>
  801caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cbd:	eb 2e                	jmp    801ced <pipe+0x141>
	sys_page_unmap(0, va);
  801cbf:	83 ec 08             	sub    $0x8,%esp
  801cc2:	56                   	push   %esi
  801cc3:	6a 00                	push   $0x0
  801cc5:	e8 f8 ee ff ff       	call   800bc2 <sys_page_unmap>
  801cca:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ccd:	83 ec 08             	sub    $0x8,%esp
  801cd0:	ff 75 f0             	push   -0x10(%ebp)
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 e8 ee ff ff       	call   800bc2 <sys_page_unmap>
  801cda:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801cdd:	83 ec 08             	sub    $0x8,%esp
  801ce0:	ff 75 f4             	push   -0xc(%ebp)
  801ce3:	6a 00                	push   $0x0
  801ce5:	e8 d8 ee ff ff       	call   800bc2 <sys_page_unmap>
  801cea:	83 c4 10             	add    $0x10,%esp
}
  801ced:	89 d8                	mov    %ebx,%eax
  801cef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf2:	5b                   	pop    %ebx
  801cf3:	5e                   	pop    %esi
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    

00801cf6 <pipeisclosed>:
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cff:	50                   	push   %eax
  801d00:	ff 75 08             	push   0x8(%ebp)
  801d03:	e8 fe f0 ff ff       	call   800e06 <fd_lookup>
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	78 18                	js     801d27 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d0f:	83 ec 0c             	sub    $0xc,%esp
  801d12:	ff 75 f4             	push   -0xc(%ebp)
  801d15:	e8 85 f0 ff ff       	call   800d9f <fd2data>
  801d1a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1f:	e8 33 fd ff ff       	call   801a57 <_pipeisclosed>
  801d24:	83 c4 10             	add    $0x10,%esp
}
  801d27:	c9                   	leave  
  801d28:	c3                   	ret    

00801d29 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d29:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2e:	c3                   	ret    

00801d2f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d35:	68 07 27 80 00       	push   $0x802707
  801d3a:	ff 75 0c             	push   0xc(%ebp)
  801d3d:	e8 ff e9 ff ff       	call   800741 <strcpy>
	return 0;
}
  801d42:	b8 00 00 00 00       	mov    $0x0,%eax
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    

00801d49 <devcons_write>:
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d55:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d5a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d60:	eb 2e                	jmp    801d90 <devcons_write+0x47>
		m = n - tot;
  801d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d65:	29 f3                	sub    %esi,%ebx
  801d67:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d6c:	39 c3                	cmp    %eax,%ebx
  801d6e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d71:	83 ec 04             	sub    $0x4,%esp
  801d74:	53                   	push   %ebx
  801d75:	89 f0                	mov    %esi,%eax
  801d77:	03 45 0c             	add    0xc(%ebp),%eax
  801d7a:	50                   	push   %eax
  801d7b:	57                   	push   %edi
  801d7c:	e8 56 eb ff ff       	call   8008d7 <memmove>
		sys_cputs(buf, m);
  801d81:	83 c4 08             	add    $0x8,%esp
  801d84:	53                   	push   %ebx
  801d85:	57                   	push   %edi
  801d86:	e8 f6 ec ff ff       	call   800a81 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d8b:	01 de                	add    %ebx,%esi
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d93:	72 cd                	jb     801d62 <devcons_write+0x19>
}
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9a:	5b                   	pop    %ebx
  801d9b:	5e                   	pop    %esi
  801d9c:	5f                   	pop    %edi
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    

00801d9f <devcons_read>:
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 08             	sub    $0x8,%esp
  801da5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801daa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dae:	75 07                	jne    801db7 <devcons_read+0x18>
  801db0:	eb 1f                	jmp    801dd1 <devcons_read+0x32>
		sys_yield();
  801db2:	e8 67 ed ff ff       	call   800b1e <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801db7:	e8 e3 ec ff ff       	call   800a9f <sys_cgetc>
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	74 f2                	je     801db2 <devcons_read+0x13>
	if (c < 0)
  801dc0:	78 0f                	js     801dd1 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801dc2:	83 f8 04             	cmp    $0x4,%eax
  801dc5:	74 0c                	je     801dd3 <devcons_read+0x34>
	*(char*)vbuf = c;
  801dc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dca:	88 02                	mov    %al,(%edx)
	return 1;
  801dcc:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    
		return 0;
  801dd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd8:	eb f7                	jmp    801dd1 <devcons_read+0x32>

00801dda <cputchar>:
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801de0:	8b 45 08             	mov    0x8(%ebp),%eax
  801de3:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801de6:	6a 01                	push   $0x1
  801de8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801deb:	50                   	push   %eax
  801dec:	e8 90 ec ff ff       	call   800a81 <sys_cputs>
}
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <getchar>:
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801dfc:	6a 01                	push   $0x1
  801dfe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e01:	50                   	push   %eax
  801e02:	6a 00                	push   $0x0
  801e04:	e8 66 f2 ff ff       	call   80106f <read>
	if (r < 0)
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	78 06                	js     801e16 <getchar+0x20>
	if (r < 1)
  801e10:	74 06                	je     801e18 <getchar+0x22>
	return c;
  801e12:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    
		return -E_EOF;
  801e18:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e1d:	eb f7                	jmp    801e16 <getchar+0x20>

00801e1f <iscons>:
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e28:	50                   	push   %eax
  801e29:	ff 75 08             	push   0x8(%ebp)
  801e2c:	e8 d5 ef ff ff       	call   800e06 <fd_lookup>
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 11                	js     801e49 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e41:	39 10                	cmp    %edx,(%eax)
  801e43:	0f 94 c0             	sete   %al
  801e46:	0f b6 c0             	movzbl %al,%eax
}
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <opencons>:
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e54:	50                   	push   %eax
  801e55:	e8 5c ef ff ff       	call   800db6 <fd_alloc>
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	78 3a                	js     801e9b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e61:	83 ec 04             	sub    $0x4,%esp
  801e64:	68 07 04 00 00       	push   $0x407
  801e69:	ff 75 f4             	push   -0xc(%ebp)
  801e6c:	6a 00                	push   $0x0
  801e6e:	e8 ca ec ff ff       	call   800b3d <sys_page_alloc>
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 21                	js     801e9b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e83:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e88:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	50                   	push   %eax
  801e93:	e8 f7 ee ff ff       	call   800d8f <fd2num>
  801e98:	83 c4 10             	add    $0x10,%esp
}
  801e9b:	c9                   	leave  
  801e9c:	c3                   	ret    

00801e9d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	56                   	push   %esi
  801ea1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ea2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ea5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801eab:	e8 4f ec ff ff       	call   800aff <sys_getenvid>
  801eb0:	83 ec 0c             	sub    $0xc,%esp
  801eb3:	ff 75 0c             	push   0xc(%ebp)
  801eb6:	ff 75 08             	push   0x8(%ebp)
  801eb9:	56                   	push   %esi
  801eba:	50                   	push   %eax
  801ebb:	68 14 27 80 00       	push   $0x802714
  801ec0:	e8 a2 e2 ff ff       	call   800167 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ec5:	83 c4 18             	add    $0x18,%esp
  801ec8:	53                   	push   %ebx
  801ec9:	ff 75 10             	push   0x10(%ebp)
  801ecc:	e8 45 e2 ff ff       	call   800116 <vcprintf>
	cprintf("\n");
  801ed1:	c7 04 24 00 27 80 00 	movl   $0x802700,(%esp)
  801ed8:	e8 8a e2 ff ff       	call   800167 <cprintf>
  801edd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ee0:	cc                   	int3   
  801ee1:	eb fd                	jmp    801ee0 <_panic+0x43>

00801ee3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	56                   	push   %esi
  801ee7:	53                   	push   %ebx
  801ee8:	8b 75 08             	mov    0x8(%ebp),%esi
  801eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ef8:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801efb:	83 ec 0c             	sub    $0xc,%esp
  801efe:	50                   	push   %eax
  801eff:	e8 e9 ed ff ff       	call   800ced <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	85 f6                	test   %esi,%esi
  801f09:	74 17                	je     801f22 <ipc_recv+0x3f>
  801f0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 0c                	js     801f20 <ipc_recv+0x3d>
  801f14:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f1a:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f20:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f22:	85 db                	test   %ebx,%ebx
  801f24:	74 17                	je     801f3d <ipc_recv+0x5a>
  801f26:	ba 00 00 00 00       	mov    $0x0,%edx
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	78 0c                	js     801f3b <ipc_recv+0x58>
  801f2f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f35:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f3b:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 0b                	js     801f4c <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f41:	a1 00 40 80 00       	mov    0x804000,%eax
  801f46:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	57                   	push   %edi
  801f57:	56                   	push   %esi
  801f58:	53                   	push   %ebx
  801f59:	83 ec 0c             	sub    $0xc,%esp
  801f5c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f65:	85 db                	test   %ebx,%ebx
  801f67:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f6c:	0f 44 d8             	cmove  %eax,%ebx
  801f6f:	eb 05                	jmp    801f76 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f71:	e8 a8 eb ff ff       	call   800b1e <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f76:	ff 75 14             	push   0x14(%ebp)
  801f79:	53                   	push   %ebx
  801f7a:	56                   	push   %esi
  801f7b:	57                   	push   %edi
  801f7c:	e8 49 ed ff ff       	call   800cca <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f87:	74 e8                	je     801f71 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	78 08                	js     801f95 <ipc_send+0x42>
	}while (r<0);

}
  801f8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f90:	5b                   	pop    %ebx
  801f91:	5e                   	pop    %esi
  801f92:	5f                   	pop    %edi
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f95:	50                   	push   %eax
  801f96:	68 37 27 80 00       	push   $0x802737
  801f9b:	6a 3d                	push   $0x3d
  801f9d:	68 4b 27 80 00       	push   $0x80274b
  801fa2:	e8 f6 fe ff ff       	call   801e9d <_panic>

00801fa7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb2:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801fb8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fbe:	8b 52 60             	mov    0x60(%edx),%edx
  801fc1:	39 ca                	cmp    %ecx,%edx
  801fc3:	74 11                	je     801fd6 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801fc5:	83 c0 01             	add    $0x1,%eax
  801fc8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fcd:	75 e3                	jne    801fb2 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fcf:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd4:	eb 0e                	jmp    801fe4 <ipc_find_env+0x3d>
			return envs[i].env_id;
  801fd6:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fdc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fe1:	8b 40 58             	mov    0x58(%eax),%eax
}
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    

00801fe6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fec:	89 c2                	mov    %eax,%edx
  801fee:	c1 ea 16             	shr    $0x16,%edx
  801ff1:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ff8:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ffd:	f6 c1 01             	test   $0x1,%cl
  802000:	74 1c                	je     80201e <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802002:	c1 e8 0c             	shr    $0xc,%eax
  802005:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80200c:	a8 01                	test   $0x1,%al
  80200e:	74 0e                	je     80201e <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802010:	c1 e8 0c             	shr    $0xc,%eax
  802013:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80201a:	ef 
  80201b:	0f b7 d2             	movzwl %dx,%edx
}
  80201e:	89 d0                	mov    %edx,%eax
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
  802022:	66 90                	xchg   %ax,%ax
  802024:	66 90                	xchg   %ax,%ax
  802026:	66 90                	xchg   %ax,%ax
  802028:	66 90                	xchg   %ax,%ax
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

00802030 <__udivdi3>:
  802030:	f3 0f 1e fb          	endbr32 
  802034:	55                   	push   %ebp
  802035:	57                   	push   %edi
  802036:	56                   	push   %esi
  802037:	53                   	push   %ebx
  802038:	83 ec 1c             	sub    $0x1c,%esp
  80203b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80203f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802043:	8b 74 24 34          	mov    0x34(%esp),%esi
  802047:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80204b:	85 c0                	test   %eax,%eax
  80204d:	75 19                	jne    802068 <__udivdi3+0x38>
  80204f:	39 f3                	cmp    %esi,%ebx
  802051:	76 4d                	jbe    8020a0 <__udivdi3+0x70>
  802053:	31 ff                	xor    %edi,%edi
  802055:	89 e8                	mov    %ebp,%eax
  802057:	89 f2                	mov    %esi,%edx
  802059:	f7 f3                	div    %ebx
  80205b:	89 fa                	mov    %edi,%edx
  80205d:	83 c4 1c             	add    $0x1c,%esp
  802060:	5b                   	pop    %ebx
  802061:	5e                   	pop    %esi
  802062:	5f                   	pop    %edi
  802063:	5d                   	pop    %ebp
  802064:	c3                   	ret    
  802065:	8d 76 00             	lea    0x0(%esi),%esi
  802068:	39 f0                	cmp    %esi,%eax
  80206a:	76 14                	jbe    802080 <__udivdi3+0x50>
  80206c:	31 ff                	xor    %edi,%edi
  80206e:	31 c0                	xor    %eax,%eax
  802070:	89 fa                	mov    %edi,%edx
  802072:	83 c4 1c             	add    $0x1c,%esp
  802075:	5b                   	pop    %ebx
  802076:	5e                   	pop    %esi
  802077:	5f                   	pop    %edi
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    
  80207a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802080:	0f bd f8             	bsr    %eax,%edi
  802083:	83 f7 1f             	xor    $0x1f,%edi
  802086:	75 48                	jne    8020d0 <__udivdi3+0xa0>
  802088:	39 f0                	cmp    %esi,%eax
  80208a:	72 06                	jb     802092 <__udivdi3+0x62>
  80208c:	31 c0                	xor    %eax,%eax
  80208e:	39 eb                	cmp    %ebp,%ebx
  802090:	77 de                	ja     802070 <__udivdi3+0x40>
  802092:	b8 01 00 00 00       	mov    $0x1,%eax
  802097:	eb d7                	jmp    802070 <__udivdi3+0x40>
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d9                	mov    %ebx,%ecx
  8020a2:	85 db                	test   %ebx,%ebx
  8020a4:	75 0b                	jne    8020b1 <__udivdi3+0x81>
  8020a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ab:	31 d2                	xor    %edx,%edx
  8020ad:	f7 f3                	div    %ebx
  8020af:	89 c1                	mov    %eax,%ecx
  8020b1:	31 d2                	xor    %edx,%edx
  8020b3:	89 f0                	mov    %esi,%eax
  8020b5:	f7 f1                	div    %ecx
  8020b7:	89 c6                	mov    %eax,%esi
  8020b9:	89 e8                	mov    %ebp,%eax
  8020bb:	89 f7                	mov    %esi,%edi
  8020bd:	f7 f1                	div    %ecx
  8020bf:	89 fa                	mov    %edi,%edx
  8020c1:	83 c4 1c             	add    $0x1c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 f9                	mov    %edi,%ecx
  8020d2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020d7:	29 fa                	sub    %edi,%edx
  8020d9:	d3 e0                	shl    %cl,%eax
  8020db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020df:	89 d1                	mov    %edx,%ecx
  8020e1:	89 d8                	mov    %ebx,%eax
  8020e3:	d3 e8                	shr    %cl,%eax
  8020e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020e9:	09 c1                	or     %eax,%ecx
  8020eb:	89 f0                	mov    %esi,%eax
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e3                	shl    %cl,%ebx
  8020f5:	89 d1                	mov    %edx,%ecx
  8020f7:	d3 e8                	shr    %cl,%eax
  8020f9:	89 f9                	mov    %edi,%ecx
  8020fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020ff:	89 eb                	mov    %ebp,%ebx
  802101:	d3 e6                	shl    %cl,%esi
  802103:	89 d1                	mov    %edx,%ecx
  802105:	d3 eb                	shr    %cl,%ebx
  802107:	09 f3                	or     %esi,%ebx
  802109:	89 c6                	mov    %eax,%esi
  80210b:	89 f2                	mov    %esi,%edx
  80210d:	89 d8                	mov    %ebx,%eax
  80210f:	f7 74 24 08          	divl   0x8(%esp)
  802113:	89 d6                	mov    %edx,%esi
  802115:	89 c3                	mov    %eax,%ebx
  802117:	f7 64 24 0c          	mull   0xc(%esp)
  80211b:	39 d6                	cmp    %edx,%esi
  80211d:	72 19                	jb     802138 <__udivdi3+0x108>
  80211f:	89 f9                	mov    %edi,%ecx
  802121:	d3 e5                	shl    %cl,%ebp
  802123:	39 c5                	cmp    %eax,%ebp
  802125:	73 04                	jae    80212b <__udivdi3+0xfb>
  802127:	39 d6                	cmp    %edx,%esi
  802129:	74 0d                	je     802138 <__udivdi3+0x108>
  80212b:	89 d8                	mov    %ebx,%eax
  80212d:	31 ff                	xor    %edi,%edi
  80212f:	e9 3c ff ff ff       	jmp    802070 <__udivdi3+0x40>
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80213b:	31 ff                	xor    %edi,%edi
  80213d:	e9 2e ff ff ff       	jmp    802070 <__udivdi3+0x40>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	f3 0f 1e fb          	endbr32 
  802154:	55                   	push   %ebp
  802155:	57                   	push   %edi
  802156:	56                   	push   %esi
  802157:	53                   	push   %ebx
  802158:	83 ec 1c             	sub    $0x1c,%esp
  80215b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80215f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802163:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802167:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80216b:	89 f0                	mov    %esi,%eax
  80216d:	89 da                	mov    %ebx,%edx
  80216f:	85 ff                	test   %edi,%edi
  802171:	75 15                	jne    802188 <__umoddi3+0x38>
  802173:	39 dd                	cmp    %ebx,%ebp
  802175:	76 39                	jbe    8021b0 <__umoddi3+0x60>
  802177:	f7 f5                	div    %ebp
  802179:	89 d0                	mov    %edx,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	83 c4 1c             	add    $0x1c,%esp
  802180:	5b                   	pop    %ebx
  802181:	5e                   	pop    %esi
  802182:	5f                   	pop    %edi
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    
  802185:	8d 76 00             	lea    0x0(%esi),%esi
  802188:	39 df                	cmp    %ebx,%edi
  80218a:	77 f1                	ja     80217d <__umoddi3+0x2d>
  80218c:	0f bd cf             	bsr    %edi,%ecx
  80218f:	83 f1 1f             	xor    $0x1f,%ecx
  802192:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802196:	75 40                	jne    8021d8 <__umoddi3+0x88>
  802198:	39 df                	cmp    %ebx,%edi
  80219a:	72 04                	jb     8021a0 <__umoddi3+0x50>
  80219c:	39 f5                	cmp    %esi,%ebp
  80219e:	77 dd                	ja     80217d <__umoddi3+0x2d>
  8021a0:	89 da                	mov    %ebx,%edx
  8021a2:	89 f0                	mov    %esi,%eax
  8021a4:	29 e8                	sub    %ebp,%eax
  8021a6:	19 fa                	sbb    %edi,%edx
  8021a8:	eb d3                	jmp    80217d <__umoddi3+0x2d>
  8021aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b0:	89 e9                	mov    %ebp,%ecx
  8021b2:	85 ed                	test   %ebp,%ebp
  8021b4:	75 0b                	jne    8021c1 <__umoddi3+0x71>
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f5                	div    %ebp
  8021bf:	89 c1                	mov    %eax,%ecx
  8021c1:	89 d8                	mov    %ebx,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  8021c5:	f7 f1                	div    %ecx
  8021c7:	89 f0                	mov    %esi,%eax
  8021c9:	f7 f1                	div    %ecx
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	31 d2                	xor    %edx,%edx
  8021cf:	eb ac                	jmp    80217d <__umoddi3+0x2d>
  8021d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021dc:	ba 20 00 00 00       	mov    $0x20,%edx
  8021e1:	29 c2                	sub    %eax,%edx
  8021e3:	89 c1                	mov    %eax,%ecx
  8021e5:	89 e8                	mov    %ebp,%eax
  8021e7:	d3 e7                	shl    %cl,%edi
  8021e9:	89 d1                	mov    %edx,%ecx
  8021eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021ef:	d3 e8                	shr    %cl,%eax
  8021f1:	89 c1                	mov    %eax,%ecx
  8021f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021f7:	09 f9                	or     %edi,%ecx
  8021f9:	89 df                	mov    %ebx,%edi
  8021fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ff:	89 c1                	mov    %eax,%ecx
  802201:	d3 e5                	shl    %cl,%ebp
  802203:	89 d1                	mov    %edx,%ecx
  802205:	d3 ef                	shr    %cl,%edi
  802207:	89 c1                	mov    %eax,%ecx
  802209:	89 f0                	mov    %esi,%eax
  80220b:	d3 e3                	shl    %cl,%ebx
  80220d:	89 d1                	mov    %edx,%ecx
  80220f:	89 fa                	mov    %edi,%edx
  802211:	d3 e8                	shr    %cl,%eax
  802213:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802218:	09 d8                	or     %ebx,%eax
  80221a:	f7 74 24 08          	divl   0x8(%esp)
  80221e:	89 d3                	mov    %edx,%ebx
  802220:	d3 e6                	shl    %cl,%esi
  802222:	f7 e5                	mul    %ebp
  802224:	89 c7                	mov    %eax,%edi
  802226:	89 d1                	mov    %edx,%ecx
  802228:	39 d3                	cmp    %edx,%ebx
  80222a:	72 06                	jb     802232 <__umoddi3+0xe2>
  80222c:	75 0e                	jne    80223c <__umoddi3+0xec>
  80222e:	39 c6                	cmp    %eax,%esi
  802230:	73 0a                	jae    80223c <__umoddi3+0xec>
  802232:	29 e8                	sub    %ebp,%eax
  802234:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802238:	89 d1                	mov    %edx,%ecx
  80223a:	89 c7                	mov    %eax,%edi
  80223c:	89 f5                	mov    %esi,%ebp
  80223e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802242:	29 fd                	sub    %edi,%ebp
  802244:	19 cb                	sbb    %ecx,%ebx
  802246:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80224b:	89 d8                	mov    %ebx,%eax
  80224d:	d3 e0                	shl    %cl,%eax
  80224f:	89 f1                	mov    %esi,%ecx
  802251:	d3 ed                	shr    %cl,%ebp
  802253:	d3 eb                	shr    %cl,%ebx
  802255:	09 e8                	or     %ebp,%eax
  802257:	89 da                	mov    %ebx,%edx
  802259:	83 c4 1c             	add    $0x1c,%esp
  80225c:	5b                   	pop    %ebx
  80225d:	5e                   	pop    %esi
  80225e:	5f                   	pop    %edi
  80225f:	5d                   	pop    %ebp
  802260:	c3                   	ret    
