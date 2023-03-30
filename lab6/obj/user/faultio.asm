
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
  80004e:	68 6e 22 80 00       	push   $0x80226e
  800053:	e8 0c 01 00 00       	call   800164 <cprintf>
}
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    
		cprintf("eflags wrong\n");
  80005d:	83 ec 0c             	sub    $0xc,%esp
  800060:	68 60 22 80 00       	push   $0x802260
  800065:	e8 fa 00 00 00       	call   800164 <cprintf>
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
  80007a:	e8 7d 0a 00 00       	call   800afc <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 db                	test   %ebx,%ebx
  800093:	7e 07                	jle    80009c <libmain+0x2d>
		binaryname = argv[0];
  800095:	8b 06                	mov    (%esi),%eax
  800097:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009c:	83 ec 08             	sub    $0x8,%esp
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
  8000a1:	e8 8d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a6:	e8 0a 00 00 00       	call   8000b5 <exit>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    

008000b5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000bb:	e8 9d 0e 00 00       	call   800f5d <close_all>
	sys_env_destroy(0);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	6a 00                	push   $0x0
  8000c5:	e8 f1 09 00 00       	call   800abb <sys_env_destroy>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	c9                   	leave  
  8000ce:	c3                   	ret    

008000cf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	53                   	push   %ebx
  8000d3:	83 ec 04             	sub    $0x4,%esp
  8000d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d9:	8b 13                	mov    (%ebx),%edx
  8000db:	8d 42 01             	lea    0x1(%edx),%eax
  8000de:	89 03                	mov    %eax,(%ebx)
  8000e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ec:	74 09                	je     8000f7 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ee:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 ff 00 00 00       	push   $0xff
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	50                   	push   %eax
  800103:	e8 76 09 00 00       	call   800a7e <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	eb db                	jmp    8000ee <putch+0x1f>

00800113 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800123:	00 00 00 
	b.cnt = 0;
  800126:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800130:	ff 75 0c             	push   0xc(%ebp)
  800133:	ff 75 08             	push   0x8(%ebp)
  800136:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013c:	50                   	push   %eax
  80013d:	68 cf 00 80 00       	push   $0x8000cf
  800142:	e8 14 01 00 00       	call   80025b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800147:	83 c4 08             	add    $0x8,%esp
  80014a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800150:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800156:	50                   	push   %eax
  800157:	e8 22 09 00 00       	call   800a7e <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016d:	50                   	push   %eax
  80016e:	ff 75 08             	push   0x8(%ebp)
  800171:	e8 9d ff ff ff       	call   800113 <vcprintf>
	va_end(ap);

	return cnt;
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 1c             	sub    $0x1c,%esp
  800181:	89 c7                	mov    %eax,%edi
  800183:	89 d6                	mov    %edx,%esi
  800185:	8b 45 08             	mov    0x8(%ebp),%eax
  800188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018b:	89 d1                	mov    %edx,%ecx
  80018d:	89 c2                	mov    %eax,%edx
  80018f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800192:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800195:	8b 45 10             	mov    0x10(%ebp),%eax
  800198:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a5:	39 c2                	cmp    %eax,%edx
  8001a7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001aa:	72 3e                	jb     8001ea <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	ff 75 18             	push   0x18(%ebp)
  8001b2:	83 eb 01             	sub    $0x1,%ebx
  8001b5:	53                   	push   %ebx
  8001b6:	50                   	push   %eax
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	ff 75 e4             	push   -0x1c(%ebp)
  8001bd:	ff 75 e0             	push   -0x20(%ebp)
  8001c0:	ff 75 dc             	push   -0x24(%ebp)
  8001c3:	ff 75 d8             	push   -0x28(%ebp)
  8001c6:	e8 45 1e 00 00       	call   802010 <__udivdi3>
  8001cb:	83 c4 18             	add    $0x18,%esp
  8001ce:	52                   	push   %edx
  8001cf:	50                   	push   %eax
  8001d0:	89 f2                	mov    %esi,%edx
  8001d2:	89 f8                	mov    %edi,%eax
  8001d4:	e8 9f ff ff ff       	call   800178 <printnum>
  8001d9:	83 c4 20             	add    $0x20,%esp
  8001dc:	eb 13                	jmp    8001f1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	56                   	push   %esi
  8001e2:	ff 75 18             	push   0x18(%ebp)
  8001e5:	ff d7                	call   *%edi
  8001e7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001ea:	83 eb 01             	sub    $0x1,%ebx
  8001ed:	85 db                	test   %ebx,%ebx
  8001ef:	7f ed                	jg     8001de <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	56                   	push   %esi
  8001f5:	83 ec 04             	sub    $0x4,%esp
  8001f8:	ff 75 e4             	push   -0x1c(%ebp)
  8001fb:	ff 75 e0             	push   -0x20(%ebp)
  8001fe:	ff 75 dc             	push   -0x24(%ebp)
  800201:	ff 75 d8             	push   -0x28(%ebp)
  800204:	e8 27 1f 00 00       	call   802130 <__umoddi3>
  800209:	83 c4 14             	add    $0x14,%esp
  80020c:	0f be 80 92 22 80 00 	movsbl 0x802292(%eax),%eax
  800213:	50                   	push   %eax
  800214:	ff d7                	call   *%edi
}
  800216:	83 c4 10             	add    $0x10,%esp
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800227:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	3b 50 04             	cmp    0x4(%eax),%edx
  800230:	73 0a                	jae    80023c <sprintputch+0x1b>
		*b->buf++ = ch;
  800232:	8d 4a 01             	lea    0x1(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 45 08             	mov    0x8(%ebp),%eax
  80023a:	88 02                	mov    %al,(%edx)
}
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <printfmt>:
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800244:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800247:	50                   	push   %eax
  800248:	ff 75 10             	push   0x10(%ebp)
  80024b:	ff 75 0c             	push   0xc(%ebp)
  80024e:	ff 75 08             	push   0x8(%ebp)
  800251:	e8 05 00 00 00       	call   80025b <vprintfmt>
}
  800256:	83 c4 10             	add    $0x10,%esp
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <vprintfmt>:
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 3c             	sub    $0x3c,%esp
  800264:	8b 75 08             	mov    0x8(%ebp),%esi
  800267:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80026a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80026d:	eb 0a                	jmp    800279 <vprintfmt+0x1e>
			putch(ch, putdat);
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	53                   	push   %ebx
  800273:	50                   	push   %eax
  800274:	ff d6                	call   *%esi
  800276:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800279:	83 c7 01             	add    $0x1,%edi
  80027c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800280:	83 f8 25             	cmp    $0x25,%eax
  800283:	74 0c                	je     800291 <vprintfmt+0x36>
			if (ch == '\0')
  800285:	85 c0                	test   %eax,%eax
  800287:	75 e6                	jne    80026f <vprintfmt+0x14>
}
  800289:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5e                   	pop    %esi
  80028e:	5f                   	pop    %edi
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    
		padc = ' ';
  800291:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800295:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80029c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002a3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002aa:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002af:	8d 47 01             	lea    0x1(%edi),%eax
  8002b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b5:	0f b6 17             	movzbl (%edi),%edx
  8002b8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002bb:	3c 55                	cmp    $0x55,%al
  8002bd:	0f 87 bb 03 00 00    	ja     80067e <vprintfmt+0x423>
  8002c3:	0f b6 c0             	movzbl %al,%eax
  8002c6:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  8002cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002d0:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002d4:	eb d9                	jmp    8002af <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d9:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002dd:	eb d0                	jmp    8002af <vprintfmt+0x54>
  8002df:	0f b6 d2             	movzbl %dl,%edx
  8002e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ea:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002ed:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002f0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002f4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002fa:	83 f9 09             	cmp    $0x9,%ecx
  8002fd:	77 55                	ja     800354 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8002ff:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800302:	eb e9                	jmp    8002ed <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800304:	8b 45 14             	mov    0x14(%ebp),%eax
  800307:	8b 00                	mov    (%eax),%eax
  800309:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030c:	8b 45 14             	mov    0x14(%ebp),%eax
  80030f:	8d 40 04             	lea    0x4(%eax),%eax
  800312:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800318:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80031c:	79 91                	jns    8002af <vprintfmt+0x54>
				width = precision, precision = -1;
  80031e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800321:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800324:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80032b:	eb 82                	jmp    8002af <vprintfmt+0x54>
  80032d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800330:	85 d2                	test   %edx,%edx
  800332:	b8 00 00 00 00       	mov    $0x0,%eax
  800337:	0f 49 c2             	cmovns %edx,%eax
  80033a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800340:	e9 6a ff ff ff       	jmp    8002af <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800348:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80034f:	e9 5b ff ff ff       	jmp    8002af <vprintfmt+0x54>
  800354:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800357:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035a:	eb bc                	jmp    800318 <vprintfmt+0xbd>
			lflag++;
  80035c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800362:	e9 48 ff ff ff       	jmp    8002af <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 78 04             	lea    0x4(%eax),%edi
  80036d:	83 ec 08             	sub    $0x8,%esp
  800370:	53                   	push   %ebx
  800371:	ff 30                	push   (%eax)
  800373:	ff d6                	call   *%esi
			break;
  800375:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800378:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80037b:	e9 9d 02 00 00       	jmp    80061d <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 78 04             	lea    0x4(%eax),%edi
  800386:	8b 10                	mov    (%eax),%edx
  800388:	89 d0                	mov    %edx,%eax
  80038a:	f7 d8                	neg    %eax
  80038c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038f:	83 f8 0f             	cmp    $0xf,%eax
  800392:	7f 23                	jg     8003b7 <vprintfmt+0x15c>
  800394:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  80039b:	85 d2                	test   %edx,%edx
  80039d:	74 18                	je     8003b7 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80039f:	52                   	push   %edx
  8003a0:	68 75 26 80 00       	push   $0x802675
  8003a5:	53                   	push   %ebx
  8003a6:	56                   	push   %esi
  8003a7:	e8 92 fe ff ff       	call   80023e <printfmt>
  8003ac:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003af:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003b2:	e9 66 02 00 00       	jmp    80061d <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003b7:	50                   	push   %eax
  8003b8:	68 aa 22 80 00       	push   $0x8022aa
  8003bd:	53                   	push   %ebx
  8003be:	56                   	push   %esi
  8003bf:	e8 7a fe ff ff       	call   80023e <printfmt>
  8003c4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003ca:	e9 4e 02 00 00       	jmp    80061d <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	83 c0 04             	add    $0x4,%eax
  8003d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003dd:	85 d2                	test   %edx,%edx
  8003df:	b8 a3 22 80 00       	mov    $0x8022a3,%eax
  8003e4:	0f 45 c2             	cmovne %edx,%eax
  8003e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ee:	7e 06                	jle    8003f6 <vprintfmt+0x19b>
  8003f0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003f4:	75 0d                	jne    800403 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003f9:	89 c7                	mov    %eax,%edi
  8003fb:	03 45 e0             	add    -0x20(%ebp),%eax
  8003fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800401:	eb 55                	jmp    800458 <vprintfmt+0x1fd>
  800403:	83 ec 08             	sub    $0x8,%esp
  800406:	ff 75 d8             	push   -0x28(%ebp)
  800409:	ff 75 cc             	push   -0x34(%ebp)
  80040c:	e8 0a 03 00 00       	call   80071b <strnlen>
  800411:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800414:	29 c1                	sub    %eax,%ecx
  800416:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800419:	83 c4 10             	add    $0x10,%esp
  80041c:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80041e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800422:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	eb 0f                	jmp    800436 <vprintfmt+0x1db>
					putch(padc, putdat);
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 e0             	push   -0x20(%ebp)
  80042e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800430:	83 ef 01             	sub    $0x1,%edi
  800433:	83 c4 10             	add    $0x10,%esp
  800436:	85 ff                	test   %edi,%edi
  800438:	7f ed                	jg     800427 <vprintfmt+0x1cc>
  80043a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80043d:	85 d2                	test   %edx,%edx
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	0f 49 c2             	cmovns %edx,%eax
  800447:	29 c2                	sub    %eax,%edx
  800449:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80044c:	eb a8                	jmp    8003f6 <vprintfmt+0x19b>
					putch(ch, putdat);
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	53                   	push   %ebx
  800452:	52                   	push   %edx
  800453:	ff d6                	call   *%esi
  800455:	83 c4 10             	add    $0x10,%esp
  800458:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80045d:	83 c7 01             	add    $0x1,%edi
  800460:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800464:	0f be d0             	movsbl %al,%edx
  800467:	85 d2                	test   %edx,%edx
  800469:	74 4b                	je     8004b6 <vprintfmt+0x25b>
  80046b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046f:	78 06                	js     800477 <vprintfmt+0x21c>
  800471:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800475:	78 1e                	js     800495 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800477:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80047b:	74 d1                	je     80044e <vprintfmt+0x1f3>
  80047d:	0f be c0             	movsbl %al,%eax
  800480:	83 e8 20             	sub    $0x20,%eax
  800483:	83 f8 5e             	cmp    $0x5e,%eax
  800486:	76 c6                	jbe    80044e <vprintfmt+0x1f3>
					putch('?', putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	53                   	push   %ebx
  80048c:	6a 3f                	push   $0x3f
  80048e:	ff d6                	call   *%esi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	eb c3                	jmp    800458 <vprintfmt+0x1fd>
  800495:	89 cf                	mov    %ecx,%edi
  800497:	eb 0e                	jmp    8004a7 <vprintfmt+0x24c>
				putch(' ', putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	53                   	push   %ebx
  80049d:	6a 20                	push   $0x20
  80049f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004a1:	83 ef 01             	sub    $0x1,%edi
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	85 ff                	test   %edi,%edi
  8004a9:	7f ee                	jg     800499 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ab:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b1:	e9 67 01 00 00       	jmp    80061d <vprintfmt+0x3c2>
  8004b6:	89 cf                	mov    %ecx,%edi
  8004b8:	eb ed                	jmp    8004a7 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004ba:	83 f9 01             	cmp    $0x1,%ecx
  8004bd:	7f 1b                	jg     8004da <vprintfmt+0x27f>
	else if (lflag)
  8004bf:	85 c9                	test   %ecx,%ecx
  8004c1:	74 63                	je     800526 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8b 00                	mov    (%eax),%eax
  8004c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004cb:	99                   	cltd   
  8004cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 40 04             	lea    0x4(%eax),%eax
  8004d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d8:	eb 17                	jmp    8004f1 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8b 50 04             	mov    0x4(%eax),%edx
  8004e0:	8b 00                	mov    (%eax),%eax
  8004e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 40 08             	lea    0x8(%eax),%eax
  8004ee:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004f7:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004fc:	85 c9                	test   %ecx,%ecx
  8004fe:	0f 89 ff 00 00 00    	jns    800603 <vprintfmt+0x3a8>
				putch('-', putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	6a 2d                	push   $0x2d
  80050a:	ff d6                	call   *%esi
				num = -(long long) num;
  80050c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80050f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800512:	f7 da                	neg    %edx
  800514:	83 d1 00             	adc    $0x0,%ecx
  800517:	f7 d9                	neg    %ecx
  800519:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80051c:	bf 0a 00 00 00       	mov    $0xa,%edi
  800521:	e9 dd 00 00 00       	jmp    800603 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052e:	99                   	cltd   
  80052f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 40 04             	lea    0x4(%eax),%eax
  800538:	89 45 14             	mov    %eax,0x14(%ebp)
  80053b:	eb b4                	jmp    8004f1 <vprintfmt+0x296>
	if (lflag >= 2)
  80053d:	83 f9 01             	cmp    $0x1,%ecx
  800540:	7f 1e                	jg     800560 <vprintfmt+0x305>
	else if (lflag)
  800542:	85 c9                	test   %ecx,%ecx
  800544:	74 32                	je     800578 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8b 10                	mov    (%eax),%edx
  80054b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800550:	8d 40 04             	lea    0x4(%eax),%eax
  800553:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800556:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80055b:	e9 a3 00 00 00       	jmp    800603 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 10                	mov    (%eax),%edx
  800565:	8b 48 04             	mov    0x4(%eax),%ecx
  800568:	8d 40 08             	lea    0x8(%eax),%eax
  80056b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800573:	e9 8b 00 00 00       	jmp    800603 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 10                	mov    (%eax),%edx
  80057d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800582:	8d 40 04             	lea    0x4(%eax),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800588:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80058d:	eb 74                	jmp    800603 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80058f:	83 f9 01             	cmp    $0x1,%ecx
  800592:	7f 1b                	jg     8005af <vprintfmt+0x354>
	else if (lflag)
  800594:	85 c9                	test   %ecx,%ecx
  800596:	74 2c                	je     8005c4 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 10                	mov    (%eax),%edx
  80059d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a2:	8d 40 04             	lea    0x4(%eax),%eax
  8005a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005a8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005ad:	eb 54                	jmp    800603 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8b 10                	mov    (%eax),%edx
  8005b4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005bd:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005c2:	eb 3f                	jmp    800603 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8b 10                	mov    (%eax),%edx
  8005c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ce:	8d 40 04             	lea    0x4(%eax),%eax
  8005d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005d4:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005d9:	eb 28                	jmp    800603 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	6a 30                	push   $0x30
  8005e1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e3:	83 c4 08             	add    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 78                	push   $0x78
  8005e9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 10                	mov    (%eax),%edx
  8005f0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005f5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005fe:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80060a:	50                   	push   %eax
  80060b:	ff 75 e0             	push   -0x20(%ebp)
  80060e:	57                   	push   %edi
  80060f:	51                   	push   %ecx
  800610:	52                   	push   %edx
  800611:	89 da                	mov    %ebx,%edx
  800613:	89 f0                	mov    %esi,%eax
  800615:	e8 5e fb ff ff       	call   800178 <printnum>
			break;
  80061a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800620:	e9 54 fc ff ff       	jmp    800279 <vprintfmt+0x1e>
	if (lflag >= 2)
  800625:	83 f9 01             	cmp    $0x1,%ecx
  800628:	7f 1b                	jg     800645 <vprintfmt+0x3ea>
	else if (lflag)
  80062a:	85 c9                	test   %ecx,%ecx
  80062c:	74 2c                	je     80065a <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	b9 00 00 00 00       	mov    $0x0,%ecx
  800638:	8d 40 04             	lea    0x4(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800643:	eb be                	jmp    800603 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	8b 48 04             	mov    0x4(%eax),%ecx
  80064d:	8d 40 08             	lea    0x8(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800653:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800658:	eb a9                	jmp    800603 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800664:	8d 40 04             	lea    0x4(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80066f:	eb 92                	jmp    800603 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 25                	push   $0x25
  800677:	ff d6                	call   *%esi
			break;
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	eb 9f                	jmp    80061d <vprintfmt+0x3c2>
			putch('%', putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	6a 25                	push   $0x25
  800684:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800686:	83 c4 10             	add    $0x10,%esp
  800689:	89 f8                	mov    %edi,%eax
  80068b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80068f:	74 05                	je     800696 <vprintfmt+0x43b>
  800691:	83 e8 01             	sub    $0x1,%eax
  800694:	eb f5                	jmp    80068b <vprintfmt+0x430>
  800696:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800699:	eb 82                	jmp    80061d <vprintfmt+0x3c2>

0080069b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	83 ec 18             	sub    $0x18,%esp
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 26                	je     8006e2 <vsnprintf+0x47>
  8006bc:	85 d2                	test   %edx,%edx
  8006be:	7e 22                	jle    8006e2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c0:	ff 75 14             	push   0x14(%ebp)
  8006c3:	ff 75 10             	push   0x10(%ebp)
  8006c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c9:	50                   	push   %eax
  8006ca:	68 21 02 80 00       	push   $0x800221
  8006cf:	e8 87 fb ff ff       	call   80025b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dd:	83 c4 10             	add    $0x10,%esp
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    
		return -E_INVAL;
  8006e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e7:	eb f7                	jmp    8006e0 <vsnprintf+0x45>

008006e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f2:	50                   	push   %eax
  8006f3:	ff 75 10             	push   0x10(%ebp)
  8006f6:	ff 75 0c             	push   0xc(%ebp)
  8006f9:	ff 75 08             	push   0x8(%ebp)
  8006fc:	e8 9a ff ff ff       	call   80069b <vsnprintf>
	va_end(ap);

	return rc;
}
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800709:	b8 00 00 00 00       	mov    $0x0,%eax
  80070e:	eb 03                	jmp    800713 <strlen+0x10>
		n++;
  800710:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800713:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800717:	75 f7                	jne    800710 <strlen+0xd>
	return n;
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800724:	b8 00 00 00 00       	mov    $0x0,%eax
  800729:	eb 03                	jmp    80072e <strnlen+0x13>
		n++;
  80072b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072e:	39 d0                	cmp    %edx,%eax
  800730:	74 08                	je     80073a <strnlen+0x1f>
  800732:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800736:	75 f3                	jne    80072b <strnlen+0x10>
  800738:	89 c2                	mov    %eax,%edx
	return n;
}
  80073a:	89 d0                	mov    %edx,%eax
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	53                   	push   %ebx
  800742:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800745:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800751:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800754:	83 c0 01             	add    $0x1,%eax
  800757:	84 d2                	test   %dl,%dl
  800759:	75 f2                	jne    80074d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80075b:	89 c8                	mov    %ecx,%eax
  80075d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	53                   	push   %ebx
  800766:	83 ec 10             	sub    $0x10,%esp
  800769:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076c:	53                   	push   %ebx
  80076d:	e8 91 ff ff ff       	call   800703 <strlen>
  800772:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800775:	ff 75 0c             	push   0xc(%ebp)
  800778:	01 d8                	add    %ebx,%eax
  80077a:	50                   	push   %eax
  80077b:	e8 be ff ff ff       	call   80073e <strcpy>
	return dst;
}
  800780:	89 d8                	mov    %ebx,%eax
  800782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800792:	89 f3                	mov    %esi,%ebx
  800794:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800797:	89 f0                	mov    %esi,%eax
  800799:	eb 0f                	jmp    8007aa <strncpy+0x23>
		*dst++ = *src;
  80079b:	83 c0 01             	add    $0x1,%eax
  80079e:	0f b6 0a             	movzbl (%edx),%ecx
  8007a1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a4:	80 f9 01             	cmp    $0x1,%cl
  8007a7:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007aa:	39 d8                	cmp    %ebx,%eax
  8007ac:	75 ed                	jne    80079b <strncpy+0x14>
	}
	return ret;
}
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	74 21                	je     8007e9 <strlcpy+0x35>
  8007c8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007cc:	89 f2                	mov    %esi,%edx
  8007ce:	eb 09                	jmp    8007d9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d0:	83 c1 01             	add    $0x1,%ecx
  8007d3:	83 c2 01             	add    $0x1,%edx
  8007d6:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007d9:	39 c2                	cmp    %eax,%edx
  8007db:	74 09                	je     8007e6 <strlcpy+0x32>
  8007dd:	0f b6 19             	movzbl (%ecx),%ebx
  8007e0:	84 db                	test   %bl,%bl
  8007e2:	75 ec                	jne    8007d0 <strlcpy+0x1c>
  8007e4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007e6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e9:	29 f0                	sub    %esi,%eax
}
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f8:	eb 06                	jmp    800800 <strcmp+0x11>
		p++, q++;
  8007fa:	83 c1 01             	add    $0x1,%ecx
  8007fd:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800800:	0f b6 01             	movzbl (%ecx),%eax
  800803:	84 c0                	test   %al,%al
  800805:	74 04                	je     80080b <strcmp+0x1c>
  800807:	3a 02                	cmp    (%edx),%al
  800809:	74 ef                	je     8007fa <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 c0             	movzbl %al,%eax
  80080e:	0f b6 12             	movzbl (%edx),%edx
  800811:	29 d0                	sub    %edx,%eax
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081f:	89 c3                	mov    %eax,%ebx
  800821:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800824:	eb 06                	jmp    80082c <strncmp+0x17>
		n--, p++, q++;
  800826:	83 c0 01             	add    $0x1,%eax
  800829:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80082c:	39 d8                	cmp    %ebx,%eax
  80082e:	74 18                	je     800848 <strncmp+0x33>
  800830:	0f b6 08             	movzbl (%eax),%ecx
  800833:	84 c9                	test   %cl,%cl
  800835:	74 04                	je     80083b <strncmp+0x26>
  800837:	3a 0a                	cmp    (%edx),%cl
  800839:	74 eb                	je     800826 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 00             	movzbl (%eax),%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
}
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    
		return 0;
  800848:	b8 00 00 00 00       	mov    $0x0,%eax
  80084d:	eb f4                	jmp    800843 <strncmp+0x2e>

0080084f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800859:	eb 03                	jmp    80085e <strchr+0xf>
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	0f b6 10             	movzbl (%eax),%edx
  800861:	84 d2                	test   %dl,%dl
  800863:	74 06                	je     80086b <strchr+0x1c>
		if (*s == c)
  800865:	38 ca                	cmp    %cl,%dl
  800867:	75 f2                	jne    80085b <strchr+0xc>
  800869:	eb 05                	jmp    800870 <strchr+0x21>
			return (char *) s;
	return 0;
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80087f:	38 ca                	cmp    %cl,%dl
  800881:	74 09                	je     80088c <strfind+0x1a>
  800883:	84 d2                	test   %dl,%dl
  800885:	74 05                	je     80088c <strfind+0x1a>
	for (; *s; s++)
  800887:	83 c0 01             	add    $0x1,%eax
  80088a:	eb f0                	jmp    80087c <strfind+0xa>
			break;
	return (char *) s;
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	57                   	push   %edi
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	8b 7d 08             	mov    0x8(%ebp),%edi
  800897:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80089a:	85 c9                	test   %ecx,%ecx
  80089c:	74 2f                	je     8008cd <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089e:	89 f8                	mov    %edi,%eax
  8008a0:	09 c8                	or     %ecx,%eax
  8008a2:	a8 03                	test   $0x3,%al
  8008a4:	75 21                	jne    8008c7 <memset+0x39>
		c &= 0xFF;
  8008a6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008aa:	89 d0                	mov    %edx,%eax
  8008ac:	c1 e0 08             	shl    $0x8,%eax
  8008af:	89 d3                	mov    %edx,%ebx
  8008b1:	c1 e3 18             	shl    $0x18,%ebx
  8008b4:	89 d6                	mov    %edx,%esi
  8008b6:	c1 e6 10             	shl    $0x10,%esi
  8008b9:	09 f3                	or     %esi,%ebx
  8008bb:	09 da                	or     %ebx,%edx
  8008bd:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008bf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008c2:	fc                   	cld    
  8008c3:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c5:	eb 06                	jmp    8008cd <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ca:	fc                   	cld    
  8008cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008cd:	89 f8                	mov    %edi,%eax
  8008cf:	5b                   	pop    %ebx
  8008d0:	5e                   	pop    %esi
  8008d1:	5f                   	pop    %edi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	57                   	push   %edi
  8008d8:	56                   	push   %esi
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e2:	39 c6                	cmp    %eax,%esi
  8008e4:	73 32                	jae    800918 <memmove+0x44>
  8008e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e9:	39 c2                	cmp    %eax,%edx
  8008eb:	76 2b                	jbe    800918 <memmove+0x44>
		s += n;
		d += n;
  8008ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f0:	89 d6                	mov    %edx,%esi
  8008f2:	09 fe                	or     %edi,%esi
  8008f4:	09 ce                	or     %ecx,%esi
  8008f6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fc:	75 0e                	jne    80090c <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008fe:	83 ef 04             	sub    $0x4,%edi
  800901:	8d 72 fc             	lea    -0x4(%edx),%esi
  800904:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800907:	fd                   	std    
  800908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090a:	eb 09                	jmp    800915 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80090c:	83 ef 01             	sub    $0x1,%edi
  80090f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800912:	fd                   	std    
  800913:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800915:	fc                   	cld    
  800916:	eb 1a                	jmp    800932 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800918:	89 f2                	mov    %esi,%edx
  80091a:	09 c2                	or     %eax,%edx
  80091c:	09 ca                	or     %ecx,%edx
  80091e:	f6 c2 03             	test   $0x3,%dl
  800921:	75 0a                	jne    80092d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800923:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800926:	89 c7                	mov    %eax,%edi
  800928:	fc                   	cld    
  800929:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092b:	eb 05                	jmp    800932 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80092d:	89 c7                	mov    %eax,%edi
  80092f:	fc                   	cld    
  800930:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800932:	5e                   	pop    %esi
  800933:	5f                   	pop    %edi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80093c:	ff 75 10             	push   0x10(%ebp)
  80093f:	ff 75 0c             	push   0xc(%ebp)
  800942:	ff 75 08             	push   0x8(%ebp)
  800945:	e8 8a ff ff ff       	call   8008d4 <memmove>
}
  80094a:	c9                   	leave  
  80094b:	c3                   	ret    

0080094c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
  800957:	89 c6                	mov    %eax,%esi
  800959:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095c:	eb 06                	jmp    800964 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80095e:	83 c0 01             	add    $0x1,%eax
  800961:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800964:	39 f0                	cmp    %esi,%eax
  800966:	74 14                	je     80097c <memcmp+0x30>
		if (*s1 != *s2)
  800968:	0f b6 08             	movzbl (%eax),%ecx
  80096b:	0f b6 1a             	movzbl (%edx),%ebx
  80096e:	38 d9                	cmp    %bl,%cl
  800970:	74 ec                	je     80095e <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800972:	0f b6 c1             	movzbl %cl,%eax
  800975:	0f b6 db             	movzbl %bl,%ebx
  800978:	29 d8                	sub    %ebx,%eax
  80097a:	eb 05                	jmp    800981 <memcmp+0x35>
	}

	return 0;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800981:	5b                   	pop    %ebx
  800982:	5e                   	pop    %esi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80098e:	89 c2                	mov    %eax,%edx
  800990:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800993:	eb 03                	jmp    800998 <memfind+0x13>
  800995:	83 c0 01             	add    $0x1,%eax
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	73 04                	jae    8009a0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099c:	38 08                	cmp    %cl,(%eax)
  80099e:	75 f5                	jne    800995 <memfind+0x10>
			break;
	return (void *) s;
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ae:	eb 03                	jmp    8009b3 <strtol+0x11>
		s++;
  8009b0:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009b3:	0f b6 02             	movzbl (%edx),%eax
  8009b6:	3c 20                	cmp    $0x20,%al
  8009b8:	74 f6                	je     8009b0 <strtol+0xe>
  8009ba:	3c 09                	cmp    $0x9,%al
  8009bc:	74 f2                	je     8009b0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009be:	3c 2b                	cmp    $0x2b,%al
  8009c0:	74 2a                	je     8009ec <strtol+0x4a>
	int neg = 0;
  8009c2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009c7:	3c 2d                	cmp    $0x2d,%al
  8009c9:	74 2b                	je     8009f6 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d1:	75 0f                	jne    8009e2 <strtol+0x40>
  8009d3:	80 3a 30             	cmpb   $0x30,(%edx)
  8009d6:	74 28                	je     800a00 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d8:	85 db                	test   %ebx,%ebx
  8009da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009df:	0f 44 d8             	cmove  %eax,%ebx
  8009e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009e7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009ea:	eb 46                	jmp    800a32 <strtol+0x90>
		s++;
  8009ec:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f4:	eb d5                	jmp    8009cb <strtol+0x29>
		s++, neg = 1;
  8009f6:	83 c2 01             	add    $0x1,%edx
  8009f9:	bf 01 00 00 00       	mov    $0x1,%edi
  8009fe:	eb cb                	jmp    8009cb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a00:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a04:	74 0e                	je     800a14 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a06:	85 db                	test   %ebx,%ebx
  800a08:	75 d8                	jne    8009e2 <strtol+0x40>
		s++, base = 8;
  800a0a:	83 c2 01             	add    $0x1,%edx
  800a0d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a12:	eb ce                	jmp    8009e2 <strtol+0x40>
		s += 2, base = 16;
  800a14:	83 c2 02             	add    $0x2,%edx
  800a17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1c:	eb c4                	jmp    8009e2 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a1e:	0f be c0             	movsbl %al,%eax
  800a21:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a24:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a27:	7d 3a                	jge    800a63 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a29:	83 c2 01             	add    $0x1,%edx
  800a2c:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a30:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a32:	0f b6 02             	movzbl (%edx),%eax
  800a35:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a38:	89 f3                	mov    %esi,%ebx
  800a3a:	80 fb 09             	cmp    $0x9,%bl
  800a3d:	76 df                	jbe    800a1e <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a3f:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 19             	cmp    $0x19,%bl
  800a47:	77 08                	ja     800a51 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a49:	0f be c0             	movsbl %al,%eax
  800a4c:	83 e8 57             	sub    $0x57,%eax
  800a4f:	eb d3                	jmp    800a24 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a51:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 19             	cmp    $0x19,%bl
  800a59:	77 08                	ja     800a63 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a5b:	0f be c0             	movsbl %al,%eax
  800a5e:	83 e8 37             	sub    $0x37,%eax
  800a61:	eb c1                	jmp    800a24 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a67:	74 05                	je     800a6e <strtol+0xcc>
		*endptr = (char *) s;
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a6e:	89 c8                	mov    %ecx,%eax
  800a70:	f7 d8                	neg    %eax
  800a72:	85 ff                	test   %edi,%edi
  800a74:	0f 45 c8             	cmovne %eax,%ecx
}
  800a77:	89 c8                	mov    %ecx,%eax
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
  800a89:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8f:	89 c3                	mov    %eax,%ebx
  800a91:	89 c7                	mov    %eax,%edi
  800a93:	89 c6                	mov    %eax,%esi
  800a95:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa7:	b8 01 00 00 00       	mov    $0x1,%eax
  800aac:	89 d1                	mov    %edx,%ecx
  800aae:	89 d3                	mov    %edx,%ebx
  800ab0:	89 d7                	mov    %edx,%edi
  800ab2:	89 d6                	mov    %edx,%esi
  800ab4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ac4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac9:	8b 55 08             	mov    0x8(%ebp),%edx
  800acc:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad1:	89 cb                	mov    %ecx,%ebx
  800ad3:	89 cf                	mov    %ecx,%edi
  800ad5:	89 ce                	mov    %ecx,%esi
  800ad7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	7f 08                	jg     800ae5 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800add:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae5:	83 ec 0c             	sub    $0xc,%esp
  800ae8:	50                   	push   %eax
  800ae9:	6a 03                	push   $0x3
  800aeb:	68 9f 25 80 00       	push   $0x80259f
  800af0:	6a 2a                	push   $0x2a
  800af2:	68 bc 25 80 00       	push   $0x8025bc
  800af7:	e8 9e 13 00 00       	call   801e9a <_panic>

00800afc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	89 d7                	mov    %edx,%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_yield>:

void
sys_yield(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b43:	be 00 00 00 00       	mov    $0x0,%esi
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b56:	89 f7                	mov    %esi,%edi
  800b58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	7f 08                	jg     800b66 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	50                   	push   %eax
  800b6a:	6a 04                	push   $0x4
  800b6c:	68 9f 25 80 00       	push   $0x80259f
  800b71:	6a 2a                	push   $0x2a
  800b73:	68 bc 25 80 00       	push   $0x8025bc
  800b78:	e8 1d 13 00 00       	call   801e9a <_panic>

00800b7d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b97:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7f 08                	jg     800ba8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	50                   	push   %eax
  800bac:	6a 05                	push   $0x5
  800bae:	68 9f 25 80 00       	push   $0x80259f
  800bb3:	6a 2a                	push   $0x2a
  800bb5:	68 bc 25 80 00       	push   $0x8025bc
  800bba:	e8 db 12 00 00       	call   801e9a <_panic>

00800bbf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd8:	89 df                	mov    %ebx,%edi
  800bda:	89 de                	mov    %ebx,%esi
  800bdc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7f 08                	jg     800bea <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	50                   	push   %eax
  800bee:	6a 06                	push   $0x6
  800bf0:	68 9f 25 80 00       	push   $0x80259f
  800bf5:	6a 2a                	push   $0x2a
  800bf7:	68 bc 25 80 00       	push   $0x8025bc
  800bfc:	e8 99 12 00 00       	call   801e9a <_panic>

00800c01 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1a:	89 df                	mov    %ebx,%edi
  800c1c:	89 de                	mov    %ebx,%esi
  800c1e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7f 08                	jg     800c2c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 08                	push   $0x8
  800c32:	68 9f 25 80 00       	push   $0x80259f
  800c37:	6a 2a                	push   $0x2a
  800c39:	68 bc 25 80 00       	push   $0x8025bc
  800c3e:	e8 57 12 00 00       	call   801e9a <_panic>

00800c43 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7f 08                	jg     800c6e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 09                	push   $0x9
  800c74:	68 9f 25 80 00       	push   $0x80259f
  800c79:	6a 2a                	push   $0x2a
  800c7b:	68 bc 25 80 00       	push   $0x8025bc
  800c80:	e8 15 12 00 00       	call   801e9a <_panic>

00800c85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7f 08                	jg     800cb0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 0a                	push   $0xa
  800cb6:	68 9f 25 80 00       	push   $0x80259f
  800cbb:	6a 2a                	push   $0x2a
  800cbd:	68 bc 25 80 00       	push   $0x8025bc
  800cc2:	e8 d3 11 00 00       	call   801e9a <_panic>

00800cc7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd8:	be 00 00 00 00       	mov    $0x0,%esi
  800cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d00:	89 cb                	mov    %ecx,%ebx
  800d02:	89 cf                	mov    %ecx,%edi
  800d04:	89 ce                	mov    %ecx,%esi
  800d06:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7f 08                	jg     800d14 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d14:	83 ec 0c             	sub    $0xc,%esp
  800d17:	50                   	push   %eax
  800d18:	6a 0d                	push   $0xd
  800d1a:	68 9f 25 80 00       	push   $0x80259f
  800d1f:	6a 2a                	push   $0x2a
  800d21:	68 bc 25 80 00       	push   $0x8025bc
  800d26:	e8 6f 11 00 00       	call   801e9a <_panic>

00800d2b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d31:	ba 00 00 00 00       	mov    $0x0,%edx
  800d36:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3b:	89 d1                	mov    %edx,%ecx
  800d3d:	89 d3                	mov    %edx,%ebx
  800d3f:	89 d7                	mov    %edx,%edi
  800d41:	89 d6                	mov    %edx,%esi
  800d43:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d60:	89 df                	mov    %ebx,%edi
  800d62:	89 de                	mov    %ebx,%esi
  800d64:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	b8 10 00 00 00       	mov    $0x10,%eax
  800d81:	89 df                	mov    %ebx,%edi
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	05 00 00 00 30       	add    $0x30000000,%eax
  800d97:	c1 e8 0c             	shr    $0xc,%eax
}
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800da7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dac:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dbb:	89 c2                	mov    %eax,%edx
  800dbd:	c1 ea 16             	shr    $0x16,%edx
  800dc0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc7:	f6 c2 01             	test   $0x1,%dl
  800dca:	74 29                	je     800df5 <fd_alloc+0x42>
  800dcc:	89 c2                	mov    %eax,%edx
  800dce:	c1 ea 0c             	shr    $0xc,%edx
  800dd1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd8:	f6 c2 01             	test   $0x1,%dl
  800ddb:	74 18                	je     800df5 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800ddd:	05 00 10 00 00       	add    $0x1000,%eax
  800de2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800de7:	75 d2                	jne    800dbb <fd_alloc+0x8>
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800dee:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800df3:	eb 05                	jmp    800dfa <fd_alloc+0x47>
			return 0;
  800df5:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	89 02                	mov    %eax,(%edx)
}
  800dff:	89 c8                	mov    %ecx,%eax
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e09:	83 f8 1f             	cmp    $0x1f,%eax
  800e0c:	77 30                	ja     800e3e <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e0e:	c1 e0 0c             	shl    $0xc,%eax
  800e11:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e16:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e1c:	f6 c2 01             	test   $0x1,%dl
  800e1f:	74 24                	je     800e45 <fd_lookup+0x42>
  800e21:	89 c2                	mov    %eax,%edx
  800e23:	c1 ea 0c             	shr    $0xc,%edx
  800e26:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2d:	f6 c2 01             	test   $0x1,%dl
  800e30:	74 1a                	je     800e4c <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e35:	89 02                	mov    %eax,(%edx)
	return 0;
  800e37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    
		return -E_INVAL;
  800e3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e43:	eb f7                	jmp    800e3c <fd_lookup+0x39>
		return -E_INVAL;
  800e45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e4a:	eb f0                	jmp    800e3c <fd_lookup+0x39>
  800e4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e51:	eb e9                	jmp    800e3c <fd_lookup+0x39>

00800e53 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	53                   	push   %ebx
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e62:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e67:	39 13                	cmp    %edx,(%ebx)
  800e69:	74 37                	je     800ea2 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800e6b:	83 c0 01             	add    $0x1,%eax
  800e6e:	8b 1c 85 48 26 80 00 	mov    0x802648(,%eax,4),%ebx
  800e75:	85 db                	test   %ebx,%ebx
  800e77:	75 ee                	jne    800e67 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e79:	a1 00 40 80 00       	mov    0x804000,%eax
  800e7e:	8b 40 48             	mov    0x48(%eax),%eax
  800e81:	83 ec 04             	sub    $0x4,%esp
  800e84:	52                   	push   %edx
  800e85:	50                   	push   %eax
  800e86:	68 cc 25 80 00       	push   $0x8025cc
  800e8b:	e8 d4 f2 ff ff       	call   800164 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9b:	89 1a                	mov    %ebx,(%edx)
}
  800e9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea0:	c9                   	leave  
  800ea1:	c3                   	ret    
			return 0;
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	eb ef                	jmp    800e98 <dev_lookup+0x45>

00800ea9 <fd_close>:
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 24             	sub    $0x24,%esp
  800eb2:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ebb:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ebc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ec2:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ec5:	50                   	push   %eax
  800ec6:	e8 38 ff ff ff       	call   800e03 <fd_lookup>
  800ecb:	89 c3                	mov    %eax,%ebx
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	78 05                	js     800ed9 <fd_close+0x30>
	    || fd != fd2)
  800ed4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ed7:	74 16                	je     800eef <fd_close+0x46>
		return (must_exist ? r : 0);
  800ed9:	89 f8                	mov    %edi,%eax
  800edb:	84 c0                	test   %al,%al
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee2:	0f 44 d8             	cmove  %eax,%ebx
}
  800ee5:	89 d8                	mov    %ebx,%eax
  800ee7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eef:	83 ec 08             	sub    $0x8,%esp
  800ef2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ef5:	50                   	push   %eax
  800ef6:	ff 36                	push   (%esi)
  800ef8:	e8 56 ff ff ff       	call   800e53 <dev_lookup>
  800efd:	89 c3                	mov    %eax,%ebx
  800eff:	83 c4 10             	add    $0x10,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	78 1a                	js     800f20 <fd_close+0x77>
		if (dev->dev_close)
  800f06:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f09:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	74 0b                	je     800f20 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	56                   	push   %esi
  800f19:	ff d0                	call   *%eax
  800f1b:	89 c3                	mov    %eax,%ebx
  800f1d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f20:	83 ec 08             	sub    $0x8,%esp
  800f23:	56                   	push   %esi
  800f24:	6a 00                	push   $0x0
  800f26:	e8 94 fc ff ff       	call   800bbf <sys_page_unmap>
	return r;
  800f2b:	83 c4 10             	add    $0x10,%esp
  800f2e:	eb b5                	jmp    800ee5 <fd_close+0x3c>

00800f30 <close>:

int
close(int fdnum)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f39:	50                   	push   %eax
  800f3a:	ff 75 08             	push   0x8(%ebp)
  800f3d:	e8 c1 fe ff ff       	call   800e03 <fd_lookup>
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	85 c0                	test   %eax,%eax
  800f47:	79 02                	jns    800f4b <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    
		return fd_close(fd, 1);
  800f4b:	83 ec 08             	sub    $0x8,%esp
  800f4e:	6a 01                	push   $0x1
  800f50:	ff 75 f4             	push   -0xc(%ebp)
  800f53:	e8 51 ff ff ff       	call   800ea9 <fd_close>
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	eb ec                	jmp    800f49 <close+0x19>

00800f5d <close_all>:

void
close_all(void)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	53                   	push   %ebx
  800f61:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f64:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	53                   	push   %ebx
  800f6d:	e8 be ff ff ff       	call   800f30 <close>
	for (i = 0; i < MAXFD; i++)
  800f72:	83 c3 01             	add    $0x1,%ebx
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	83 fb 20             	cmp    $0x20,%ebx
  800f7b:	75 ec                	jne    800f69 <close_all+0xc>
}
  800f7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	57                   	push   %edi
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
  800f88:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f8b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	ff 75 08             	push   0x8(%ebp)
  800f92:	e8 6c fe ff ff       	call   800e03 <fd_lookup>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 7f                	js     80101f <dup+0x9d>
		return r;
	close(newfdnum);
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	ff 75 0c             	push   0xc(%ebp)
  800fa6:	e8 85 ff ff ff       	call   800f30 <close>

	newfd = INDEX2FD(newfdnum);
  800fab:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fae:	c1 e6 0c             	shl    $0xc,%esi
  800fb1:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fba:	89 3c 24             	mov    %edi,(%esp)
  800fbd:	e8 da fd ff ff       	call   800d9c <fd2data>
  800fc2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fc4:	89 34 24             	mov    %esi,(%esp)
  800fc7:	e8 d0 fd ff ff       	call   800d9c <fd2data>
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fd2:	89 d8                	mov    %ebx,%eax
  800fd4:	c1 e8 16             	shr    $0x16,%eax
  800fd7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fde:	a8 01                	test   $0x1,%al
  800fe0:	74 11                	je     800ff3 <dup+0x71>
  800fe2:	89 d8                	mov    %ebx,%eax
  800fe4:	c1 e8 0c             	shr    $0xc,%eax
  800fe7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fee:	f6 c2 01             	test   $0x1,%dl
  800ff1:	75 36                	jne    801029 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff3:	89 f8                	mov    %edi,%eax
  800ff5:	c1 e8 0c             	shr    $0xc,%eax
  800ff8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	25 07 0e 00 00       	and    $0xe07,%eax
  801007:	50                   	push   %eax
  801008:	56                   	push   %esi
  801009:	6a 00                	push   $0x0
  80100b:	57                   	push   %edi
  80100c:	6a 00                	push   $0x0
  80100e:	e8 6a fb ff ff       	call   800b7d <sys_page_map>
  801013:	89 c3                	mov    %eax,%ebx
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 33                	js     80104f <dup+0xcd>
		goto err;

	return newfdnum;
  80101c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80101f:	89 d8                	mov    %ebx,%eax
  801021:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5f                   	pop    %edi
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801029:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	25 07 0e 00 00       	and    $0xe07,%eax
  801038:	50                   	push   %eax
  801039:	ff 75 d4             	push   -0x2c(%ebp)
  80103c:	6a 00                	push   $0x0
  80103e:	53                   	push   %ebx
  80103f:	6a 00                	push   $0x0
  801041:	e8 37 fb ff ff       	call   800b7d <sys_page_map>
  801046:	89 c3                	mov    %eax,%ebx
  801048:	83 c4 20             	add    $0x20,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	79 a4                	jns    800ff3 <dup+0x71>
	sys_page_unmap(0, newfd);
  80104f:	83 ec 08             	sub    $0x8,%esp
  801052:	56                   	push   %esi
  801053:	6a 00                	push   $0x0
  801055:	e8 65 fb ff ff       	call   800bbf <sys_page_unmap>
	sys_page_unmap(0, nva);
  80105a:	83 c4 08             	add    $0x8,%esp
  80105d:	ff 75 d4             	push   -0x2c(%ebp)
  801060:	6a 00                	push   $0x0
  801062:	e8 58 fb ff ff       	call   800bbf <sys_page_unmap>
	return r;
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	eb b3                	jmp    80101f <dup+0x9d>

0080106c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 18             	sub    $0x18,%esp
  801074:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801077:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80107a:	50                   	push   %eax
  80107b:	56                   	push   %esi
  80107c:	e8 82 fd ff ff       	call   800e03 <fd_lookup>
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	78 3c                	js     8010c4 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801088:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801091:	50                   	push   %eax
  801092:	ff 33                	push   (%ebx)
  801094:	e8 ba fd ff ff       	call   800e53 <dev_lookup>
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	78 24                	js     8010c4 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010a0:	8b 43 08             	mov    0x8(%ebx),%eax
  8010a3:	83 e0 03             	and    $0x3,%eax
  8010a6:	83 f8 01             	cmp    $0x1,%eax
  8010a9:	74 20                	je     8010cb <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ae:	8b 40 08             	mov    0x8(%eax),%eax
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	74 37                	je     8010ec <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010b5:	83 ec 04             	sub    $0x4,%esp
  8010b8:	ff 75 10             	push   0x10(%ebp)
  8010bb:	ff 75 0c             	push   0xc(%ebp)
  8010be:	53                   	push   %ebx
  8010bf:	ff d0                	call   *%eax
  8010c1:	83 c4 10             	add    $0x10,%esp
}
  8010c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010cb:	a1 00 40 80 00       	mov    0x804000,%eax
  8010d0:	8b 40 48             	mov    0x48(%eax),%eax
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	56                   	push   %esi
  8010d7:	50                   	push   %eax
  8010d8:	68 0d 26 80 00       	push   $0x80260d
  8010dd:	e8 82 f0 ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ea:	eb d8                	jmp    8010c4 <read+0x58>
		return -E_NOT_SUPP;
  8010ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010f1:	eb d1                	jmp    8010c4 <read+0x58>

008010f3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 0c             	sub    $0xc,%esp
  8010fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ff:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801102:	bb 00 00 00 00       	mov    $0x0,%ebx
  801107:	eb 02                	jmp    80110b <readn+0x18>
  801109:	01 c3                	add    %eax,%ebx
  80110b:	39 f3                	cmp    %esi,%ebx
  80110d:	73 21                	jae    801130 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80110f:	83 ec 04             	sub    $0x4,%esp
  801112:	89 f0                	mov    %esi,%eax
  801114:	29 d8                	sub    %ebx,%eax
  801116:	50                   	push   %eax
  801117:	89 d8                	mov    %ebx,%eax
  801119:	03 45 0c             	add    0xc(%ebp),%eax
  80111c:	50                   	push   %eax
  80111d:	57                   	push   %edi
  80111e:	e8 49 ff ff ff       	call   80106c <read>
		if (m < 0)
  801123:	83 c4 10             	add    $0x10,%esp
  801126:	85 c0                	test   %eax,%eax
  801128:	78 04                	js     80112e <readn+0x3b>
			return m;
		if (m == 0)
  80112a:	75 dd                	jne    801109 <readn+0x16>
  80112c:	eb 02                	jmp    801130 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80112e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801130:	89 d8                	mov    %ebx,%eax
  801132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	56                   	push   %esi
  80113e:	53                   	push   %ebx
  80113f:	83 ec 18             	sub    $0x18,%esp
  801142:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801145:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	53                   	push   %ebx
  80114a:	e8 b4 fc ff ff       	call   800e03 <fd_lookup>
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 37                	js     80118d <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801156:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	ff 36                	push   (%esi)
  801162:	e8 ec fc ff ff       	call   800e53 <dev_lookup>
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	78 1f                	js     80118d <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80116e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801172:	74 20                	je     801194 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801174:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801177:	8b 40 0c             	mov    0xc(%eax),%eax
  80117a:	85 c0                	test   %eax,%eax
  80117c:	74 37                	je     8011b5 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80117e:	83 ec 04             	sub    $0x4,%esp
  801181:	ff 75 10             	push   0x10(%ebp)
  801184:	ff 75 0c             	push   0xc(%ebp)
  801187:	56                   	push   %esi
  801188:	ff d0                	call   *%eax
  80118a:	83 c4 10             	add    $0x10,%esp
}
  80118d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801190:	5b                   	pop    %ebx
  801191:	5e                   	pop    %esi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801194:	a1 00 40 80 00       	mov    0x804000,%eax
  801199:	8b 40 48             	mov    0x48(%eax),%eax
  80119c:	83 ec 04             	sub    $0x4,%esp
  80119f:	53                   	push   %ebx
  8011a0:	50                   	push   %eax
  8011a1:	68 29 26 80 00       	push   $0x802629
  8011a6:	e8 b9 ef ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b3:	eb d8                	jmp    80118d <write+0x53>
		return -E_NOT_SUPP;
  8011b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ba:	eb d1                	jmp    80118d <write+0x53>

008011bc <seek>:

int
seek(int fdnum, off_t offset)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c5:	50                   	push   %eax
  8011c6:	ff 75 08             	push   0x8(%ebp)
  8011c9:	e8 35 fc ff ff       	call   800e03 <fd_lookup>
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 0e                	js     8011e3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011db:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e3:	c9                   	leave  
  8011e4:	c3                   	ret    

008011e5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	56                   	push   %esi
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 18             	sub    $0x18,%esp
  8011ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f3:	50                   	push   %eax
  8011f4:	53                   	push   %ebx
  8011f5:	e8 09 fc ff ff       	call   800e03 <fd_lookup>
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 34                	js     801235 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801201:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120a:	50                   	push   %eax
  80120b:	ff 36                	push   (%esi)
  80120d:	e8 41 fc ff ff       	call   800e53 <dev_lookup>
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	78 1c                	js     801235 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801219:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80121d:	74 1d                	je     80123c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80121f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801222:	8b 40 18             	mov    0x18(%eax),%eax
  801225:	85 c0                	test   %eax,%eax
  801227:	74 34                	je     80125d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	ff 75 0c             	push   0xc(%ebp)
  80122f:	56                   	push   %esi
  801230:	ff d0                	call   *%eax
  801232:	83 c4 10             	add    $0x10,%esp
}
  801235:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801238:	5b                   	pop    %ebx
  801239:	5e                   	pop    %esi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80123c:	a1 00 40 80 00       	mov    0x804000,%eax
  801241:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	53                   	push   %ebx
  801248:	50                   	push   %eax
  801249:	68 ec 25 80 00       	push   $0x8025ec
  80124e:	e8 11 ef ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125b:	eb d8                	jmp    801235 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80125d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801262:	eb d1                	jmp    801235 <ftruncate+0x50>

00801264 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
  801269:	83 ec 18             	sub    $0x18,%esp
  80126c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	ff 75 08             	push   0x8(%ebp)
  801276:	e8 88 fb ff ff       	call   800e03 <fd_lookup>
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 49                	js     8012cb <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801282:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128b:	50                   	push   %eax
  80128c:	ff 36                	push   (%esi)
  80128e:	e8 c0 fb ff ff       	call   800e53 <dev_lookup>
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	78 31                	js     8012cb <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80129a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012a1:	74 2f                	je     8012d2 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012a3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012a6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012ad:	00 00 00 
	stat->st_isdir = 0;
  8012b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012b7:	00 00 00 
	stat->st_dev = dev;
  8012ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	53                   	push   %ebx
  8012c4:	56                   	push   %esi
  8012c5:	ff 50 14             	call   *0x14(%eax)
  8012c8:	83 c4 10             	add    $0x10,%esp
}
  8012cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    
		return -E_NOT_SUPP;
  8012d2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012d7:	eb f2                	jmp    8012cb <fstat+0x67>

008012d9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	6a 00                	push   $0x0
  8012e3:	ff 75 08             	push   0x8(%ebp)
  8012e6:	e8 e4 01 00 00       	call   8014cf <open>
  8012eb:	89 c3                	mov    %eax,%ebx
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	78 1b                	js     80130f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012f4:	83 ec 08             	sub    $0x8,%esp
  8012f7:	ff 75 0c             	push   0xc(%ebp)
  8012fa:	50                   	push   %eax
  8012fb:	e8 64 ff ff ff       	call   801264 <fstat>
  801300:	89 c6                	mov    %eax,%esi
	close(fd);
  801302:	89 1c 24             	mov    %ebx,(%esp)
  801305:	e8 26 fc ff ff       	call   800f30 <close>
	return r;
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	89 f3                	mov    %esi,%ebx
}
  80130f:	89 d8                	mov    %ebx,%eax
  801311:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801314:	5b                   	pop    %ebx
  801315:	5e                   	pop    %esi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	56                   	push   %esi
  80131c:	53                   	push   %ebx
  80131d:	89 c6                	mov    %eax,%esi
  80131f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801321:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801328:	74 27                	je     801351 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80132a:	6a 07                	push   $0x7
  80132c:	68 00 50 80 00       	push   $0x805000
  801331:	56                   	push   %esi
  801332:	ff 35 00 60 80 00    	push   0x806000
  801338:	e8 0a 0c 00 00       	call   801f47 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80133d:	83 c4 0c             	add    $0xc,%esp
  801340:	6a 00                	push   $0x0
  801342:	53                   	push   %ebx
  801343:	6a 00                	push   $0x0
  801345:	e8 96 0b 00 00       	call   801ee0 <ipc_recv>
}
  80134a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801351:	83 ec 0c             	sub    $0xc,%esp
  801354:	6a 01                	push   $0x1
  801356:	e8 40 0c 00 00       	call   801f9b <ipc_find_env>
  80135b:	a3 00 60 80 00       	mov    %eax,0x806000
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	eb c5                	jmp    80132a <fsipc+0x12>

00801365 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80136b:	8b 45 08             	mov    0x8(%ebp),%eax
  80136e:	8b 40 0c             	mov    0xc(%eax),%eax
  801371:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801376:	8b 45 0c             	mov    0xc(%ebp),%eax
  801379:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80137e:	ba 00 00 00 00       	mov    $0x0,%edx
  801383:	b8 02 00 00 00       	mov    $0x2,%eax
  801388:	e8 8b ff ff ff       	call   801318 <fsipc>
}
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <devfile_flush>:
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801395:	8b 45 08             	mov    0x8(%ebp),%eax
  801398:	8b 40 0c             	mov    0xc(%eax),%eax
  80139b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8013aa:	e8 69 ff ff ff       	call   801318 <fsipc>
}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <devfile_stat>:
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	53                   	push   %ebx
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013be:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8013d0:	e8 43 ff ff ff       	call   801318 <fsipc>
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 2c                	js     801405 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	68 00 50 80 00       	push   $0x805000
  8013e1:	53                   	push   %ebx
  8013e2:	e8 57 f3 ff ff       	call   80073e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013e7:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013f2:	a1 84 50 80 00       	mov    0x805084,%eax
  8013f7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801405:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <devfile_write>:
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 0c             	sub    $0xc,%esp
  801410:	8b 45 10             	mov    0x10(%ebp),%eax
  801413:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801418:	39 d0                	cmp    %edx,%eax
  80141a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80141d:	8b 55 08             	mov    0x8(%ebp),%edx
  801420:	8b 52 0c             	mov    0xc(%edx),%edx
  801423:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801429:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80142e:	50                   	push   %eax
  80142f:	ff 75 0c             	push   0xc(%ebp)
  801432:	68 08 50 80 00       	push   $0x805008
  801437:	e8 98 f4 ff ff       	call   8008d4 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80143c:	ba 00 00 00 00       	mov    $0x0,%edx
  801441:	b8 04 00 00 00       	mov    $0x4,%eax
  801446:	e8 cd fe ff ff       	call   801318 <fsipc>
}
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <devfile_read>:
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	56                   	push   %esi
  801451:	53                   	push   %ebx
  801452:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801455:	8b 45 08             	mov    0x8(%ebp),%eax
  801458:	8b 40 0c             	mov    0xc(%eax),%eax
  80145b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801460:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801466:	ba 00 00 00 00       	mov    $0x0,%edx
  80146b:	b8 03 00 00 00       	mov    $0x3,%eax
  801470:	e8 a3 fe ff ff       	call   801318 <fsipc>
  801475:	89 c3                	mov    %eax,%ebx
  801477:	85 c0                	test   %eax,%eax
  801479:	78 1f                	js     80149a <devfile_read+0x4d>
	assert(r <= n);
  80147b:	39 f0                	cmp    %esi,%eax
  80147d:	77 24                	ja     8014a3 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80147f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801484:	7f 33                	jg     8014b9 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801486:	83 ec 04             	sub    $0x4,%esp
  801489:	50                   	push   %eax
  80148a:	68 00 50 80 00       	push   $0x805000
  80148f:	ff 75 0c             	push   0xc(%ebp)
  801492:	e8 3d f4 ff ff       	call   8008d4 <memmove>
	return r;
  801497:	83 c4 10             	add    $0x10,%esp
}
  80149a:	89 d8                	mov    %ebx,%eax
  80149c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    
	assert(r <= n);
  8014a3:	68 5c 26 80 00       	push   $0x80265c
  8014a8:	68 63 26 80 00       	push   $0x802663
  8014ad:	6a 7c                	push   $0x7c
  8014af:	68 78 26 80 00       	push   $0x802678
  8014b4:	e8 e1 09 00 00       	call   801e9a <_panic>
	assert(r <= PGSIZE);
  8014b9:	68 83 26 80 00       	push   $0x802683
  8014be:	68 63 26 80 00       	push   $0x802663
  8014c3:	6a 7d                	push   $0x7d
  8014c5:	68 78 26 80 00       	push   $0x802678
  8014ca:	e8 cb 09 00 00       	call   801e9a <_panic>

008014cf <open>:
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	56                   	push   %esi
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 1c             	sub    $0x1c,%esp
  8014d7:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014da:	56                   	push   %esi
  8014db:	e8 23 f2 ff ff       	call   800703 <strlen>
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014e8:	7f 6c                	jg     801556 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f0:	50                   	push   %eax
  8014f1:	e8 bd f8 ff ff       	call   800db3 <fd_alloc>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 3c                	js     80153b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	56                   	push   %esi
  801503:	68 00 50 80 00       	push   $0x805000
  801508:	e8 31 f2 ff ff       	call   80073e <strcpy>
	fsipcbuf.open.req_omode = mode;
  80150d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801510:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801515:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801518:	b8 01 00 00 00       	mov    $0x1,%eax
  80151d:	e8 f6 fd ff ff       	call   801318 <fsipc>
  801522:	89 c3                	mov    %eax,%ebx
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 19                	js     801544 <open+0x75>
	return fd2num(fd);
  80152b:	83 ec 0c             	sub    $0xc,%esp
  80152e:	ff 75 f4             	push   -0xc(%ebp)
  801531:	e8 56 f8 ff ff       	call   800d8c <fd2num>
  801536:	89 c3                	mov    %eax,%ebx
  801538:	83 c4 10             	add    $0x10,%esp
}
  80153b:	89 d8                	mov    %ebx,%eax
  80153d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    
		fd_close(fd, 0);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	6a 00                	push   $0x0
  801549:	ff 75 f4             	push   -0xc(%ebp)
  80154c:	e8 58 f9 ff ff       	call   800ea9 <fd_close>
		return r;
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	eb e5                	jmp    80153b <open+0x6c>
		return -E_BAD_PATH;
  801556:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80155b:	eb de                	jmp    80153b <open+0x6c>

0080155d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 08 00 00 00       	mov    $0x8,%eax
  80156d:	e8 a6 fd ff ff       	call   801318 <fsipc>
}
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80157a:	68 8f 26 80 00       	push   $0x80268f
  80157f:	ff 75 0c             	push   0xc(%ebp)
  801582:	e8 b7 f1 ff ff       	call   80073e <strcpy>
	return 0;
}
  801587:	b8 00 00 00 00       	mov    $0x0,%eax
  80158c:	c9                   	leave  
  80158d:	c3                   	ret    

0080158e <devsock_close>:
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	53                   	push   %ebx
  801592:	83 ec 10             	sub    $0x10,%esp
  801595:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801598:	53                   	push   %ebx
  801599:	e8 36 0a 00 00       	call   801fd4 <pageref>
  80159e:	89 c2                	mov    %eax,%edx
  8015a0:	83 c4 10             	add    $0x10,%esp
		return 0;
  8015a3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8015a8:	83 fa 01             	cmp    $0x1,%edx
  8015ab:	74 05                	je     8015b2 <devsock_close+0x24>
}
  8015ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8015b2:	83 ec 0c             	sub    $0xc,%esp
  8015b5:	ff 73 0c             	push   0xc(%ebx)
  8015b8:	e8 b7 02 00 00       	call   801874 <nsipc_close>
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	eb eb                	jmp    8015ad <devsock_close+0x1f>

008015c2 <devsock_write>:
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015c8:	6a 00                	push   $0x0
  8015ca:	ff 75 10             	push   0x10(%ebp)
  8015cd:	ff 75 0c             	push   0xc(%ebp)
  8015d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d3:	ff 70 0c             	push   0xc(%eax)
  8015d6:	e8 79 03 00 00       	call   801954 <nsipc_send>
}
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <devsock_read>:
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015e3:	6a 00                	push   $0x0
  8015e5:	ff 75 10             	push   0x10(%ebp)
  8015e8:	ff 75 0c             	push   0xc(%ebp)
  8015eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ee:	ff 70 0c             	push   0xc(%eax)
  8015f1:	e8 ef 02 00 00       	call   8018e5 <nsipc_recv>
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <fd2sockid>:
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015fe:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801601:	52                   	push   %edx
  801602:	50                   	push   %eax
  801603:	e8 fb f7 ff ff       	call   800e03 <fd_lookup>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 10                	js     80161f <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80160f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801612:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801618:	39 08                	cmp    %ecx,(%eax)
  80161a:	75 05                	jne    801621 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80161c:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80161f:	c9                   	leave  
  801620:	c3                   	ret    
		return -E_NOT_SUPP;
  801621:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801626:	eb f7                	jmp    80161f <fd2sockid+0x27>

00801628 <alloc_sockfd>:
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	56                   	push   %esi
  80162c:	53                   	push   %ebx
  80162d:	83 ec 1c             	sub    $0x1c,%esp
  801630:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	e8 78 f7 ff ff       	call   800db3 <fd_alloc>
  80163b:	89 c3                	mov    %eax,%ebx
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	78 43                	js     801687 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801644:	83 ec 04             	sub    $0x4,%esp
  801647:	68 07 04 00 00       	push   $0x407
  80164c:	ff 75 f4             	push   -0xc(%ebp)
  80164f:	6a 00                	push   $0x0
  801651:	e8 e4 f4 ff ff       	call   800b3a <sys_page_alloc>
  801656:	89 c3                	mov    %eax,%ebx
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 28                	js     801687 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80165f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801662:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801668:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80166a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801674:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801677:	83 ec 0c             	sub    $0xc,%esp
  80167a:	50                   	push   %eax
  80167b:	e8 0c f7 ff ff       	call   800d8c <fd2num>
  801680:	89 c3                	mov    %eax,%ebx
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	eb 0c                	jmp    801693 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801687:	83 ec 0c             	sub    $0xc,%esp
  80168a:	56                   	push   %esi
  80168b:	e8 e4 01 00 00       	call   801874 <nsipc_close>
		return r;
  801690:	83 c4 10             	add    $0x10,%esp
}
  801693:	89 d8                	mov    %ebx,%eax
  801695:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801698:	5b                   	pop    %ebx
  801699:	5e                   	pop    %esi
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <accept>:
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	e8 4e ff ff ff       	call   8015f8 <fd2sockid>
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 1b                	js     8016c9 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	ff 75 10             	push   0x10(%ebp)
  8016b4:	ff 75 0c             	push   0xc(%ebp)
  8016b7:	50                   	push   %eax
  8016b8:	e8 0e 01 00 00       	call   8017cb <nsipc_accept>
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 05                	js     8016c9 <accept+0x2d>
	return alloc_sockfd(r);
  8016c4:	e8 5f ff ff ff       	call   801628 <alloc_sockfd>
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <bind>:
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d4:	e8 1f ff ff ff       	call   8015f8 <fd2sockid>
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 12                	js     8016ef <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8016dd:	83 ec 04             	sub    $0x4,%esp
  8016e0:	ff 75 10             	push   0x10(%ebp)
  8016e3:	ff 75 0c             	push   0xc(%ebp)
  8016e6:	50                   	push   %eax
  8016e7:	e8 31 01 00 00       	call   80181d <nsipc_bind>
  8016ec:	83 c4 10             	add    $0x10,%esp
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <shutdown>:
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fa:	e8 f9 fe ff ff       	call   8015f8 <fd2sockid>
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 0f                	js     801712 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	ff 75 0c             	push   0xc(%ebp)
  801709:	50                   	push   %eax
  80170a:	e8 43 01 00 00       	call   801852 <nsipc_shutdown>
  80170f:	83 c4 10             	add    $0x10,%esp
}
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <connect>:
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	e8 d6 fe ff ff       	call   8015f8 <fd2sockid>
  801722:	85 c0                	test   %eax,%eax
  801724:	78 12                	js     801738 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801726:	83 ec 04             	sub    $0x4,%esp
  801729:	ff 75 10             	push   0x10(%ebp)
  80172c:	ff 75 0c             	push   0xc(%ebp)
  80172f:	50                   	push   %eax
  801730:	e8 59 01 00 00       	call   80188e <nsipc_connect>
  801735:	83 c4 10             	add    $0x10,%esp
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <listen>:
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801740:	8b 45 08             	mov    0x8(%ebp),%eax
  801743:	e8 b0 fe ff ff       	call   8015f8 <fd2sockid>
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 0f                	js     80175b <listen+0x21>
	return nsipc_listen(r, backlog);
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	ff 75 0c             	push   0xc(%ebp)
  801752:	50                   	push   %eax
  801753:	e8 6b 01 00 00       	call   8018c3 <nsipc_listen>
  801758:	83 c4 10             	add    $0x10,%esp
}
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <socket>:

int
socket(int domain, int type, int protocol)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801763:	ff 75 10             	push   0x10(%ebp)
  801766:	ff 75 0c             	push   0xc(%ebp)
  801769:	ff 75 08             	push   0x8(%ebp)
  80176c:	e8 41 02 00 00       	call   8019b2 <nsipc_socket>
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	85 c0                	test   %eax,%eax
  801776:	78 05                	js     80177d <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801778:	e8 ab fe ff ff       	call   801628 <alloc_sockfd>
}
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	53                   	push   %ebx
  801783:	83 ec 04             	sub    $0x4,%esp
  801786:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801788:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80178f:	74 26                	je     8017b7 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801791:	6a 07                	push   $0x7
  801793:	68 00 70 80 00       	push   $0x807000
  801798:	53                   	push   %ebx
  801799:	ff 35 00 80 80 00    	push   0x808000
  80179f:	e8 a3 07 00 00       	call   801f47 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017a4:	83 c4 0c             	add    $0xc,%esp
  8017a7:	6a 00                	push   $0x0
  8017a9:	6a 00                	push   $0x0
  8017ab:	6a 00                	push   $0x0
  8017ad:	e8 2e 07 00 00       	call   801ee0 <ipc_recv>
}
  8017b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017b7:	83 ec 0c             	sub    $0xc,%esp
  8017ba:	6a 02                	push   $0x2
  8017bc:	e8 da 07 00 00       	call   801f9b <ipc_find_env>
  8017c1:	a3 00 80 80 00       	mov    %eax,0x808000
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	eb c6                	jmp    801791 <nsipc+0x12>

008017cb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	56                   	push   %esi
  8017cf:	53                   	push   %ebx
  8017d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017db:	8b 06                	mov    (%esi),%eax
  8017dd:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e7:	e8 93 ff ff ff       	call   80177f <nsipc>
  8017ec:	89 c3                	mov    %eax,%ebx
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	79 09                	jns    8017fb <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8017f2:	89 d8                	mov    %ebx,%eax
  8017f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f7:	5b                   	pop    %ebx
  8017f8:	5e                   	pop    %esi
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	ff 35 10 70 80 00    	push   0x807010
  801804:	68 00 70 80 00       	push   $0x807000
  801809:	ff 75 0c             	push   0xc(%ebp)
  80180c:	e8 c3 f0 ff ff       	call   8008d4 <memmove>
		*addrlen = ret->ret_addrlen;
  801811:	a1 10 70 80 00       	mov    0x807010,%eax
  801816:	89 06                	mov    %eax,(%esi)
  801818:	83 c4 10             	add    $0x10,%esp
	return r;
  80181b:	eb d5                	jmp    8017f2 <nsipc_accept+0x27>

0080181d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	53                   	push   %ebx
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80182f:	53                   	push   %ebx
  801830:	ff 75 0c             	push   0xc(%ebp)
  801833:	68 04 70 80 00       	push   $0x807004
  801838:	e8 97 f0 ff ff       	call   8008d4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80183d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801843:	b8 02 00 00 00       	mov    $0x2,%eax
  801848:	e8 32 ff ff ff       	call   80177f <nsipc>
}
  80184d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801850:	c9                   	leave  
  801851:	c3                   	ret    

00801852 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801860:	8b 45 0c             	mov    0xc(%ebp),%eax
  801863:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801868:	b8 03 00 00 00       	mov    $0x3,%eax
  80186d:	e8 0d ff ff ff       	call   80177f <nsipc>
}
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <nsipc_close>:

int
nsipc_close(int s)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801882:	b8 04 00 00 00       	mov    $0x4,%eax
  801887:	e8 f3 fe ff ff       	call   80177f <nsipc>
}
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	53                   	push   %ebx
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018a0:	53                   	push   %ebx
  8018a1:	ff 75 0c             	push   0xc(%ebp)
  8018a4:	68 04 70 80 00       	push   $0x807004
  8018a9:	e8 26 f0 ff ff       	call   8008d4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018ae:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8018b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b9:	e8 c1 fe ff ff       	call   80177f <nsipc>
}
  8018be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8018d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d4:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8018d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8018de:	e8 9c fe ff ff       	call   80177f <nsipc>
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	56                   	push   %esi
  8018e9:	53                   	push   %ebx
  8018ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8018f5:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8018fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fe:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801903:	b8 07 00 00 00       	mov    $0x7,%eax
  801908:	e8 72 fe ff ff       	call   80177f <nsipc>
  80190d:	89 c3                	mov    %eax,%ebx
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 22                	js     801935 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801913:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801918:	39 c6                	cmp    %eax,%esi
  80191a:	0f 4e c6             	cmovle %esi,%eax
  80191d:	39 c3                	cmp    %eax,%ebx
  80191f:	7f 1d                	jg     80193e <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801921:	83 ec 04             	sub    $0x4,%esp
  801924:	53                   	push   %ebx
  801925:	68 00 70 80 00       	push   $0x807000
  80192a:	ff 75 0c             	push   0xc(%ebp)
  80192d:	e8 a2 ef ff ff       	call   8008d4 <memmove>
  801932:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801935:	89 d8                	mov    %ebx,%eax
  801937:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5d                   	pop    %ebp
  80193d:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80193e:	68 9b 26 80 00       	push   $0x80269b
  801943:	68 63 26 80 00       	push   $0x802663
  801948:	6a 62                	push   $0x62
  80194a:	68 b0 26 80 00       	push   $0x8026b0
  80194f:	e8 46 05 00 00       	call   801e9a <_panic>

00801954 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	53                   	push   %ebx
  801958:	83 ec 04             	sub    $0x4,%esp
  80195b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80195e:	8b 45 08             	mov    0x8(%ebp),%eax
  801961:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801966:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80196c:	7f 2e                	jg     80199c <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80196e:	83 ec 04             	sub    $0x4,%esp
  801971:	53                   	push   %ebx
  801972:	ff 75 0c             	push   0xc(%ebp)
  801975:	68 0c 70 80 00       	push   $0x80700c
  80197a:	e8 55 ef ff ff       	call   8008d4 <memmove>
	nsipcbuf.send.req_size = size;
  80197f:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801985:	8b 45 14             	mov    0x14(%ebp),%eax
  801988:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80198d:	b8 08 00 00 00       	mov    $0x8,%eax
  801992:	e8 e8 fd ff ff       	call   80177f <nsipc>
}
  801997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    
	assert(size < 1600);
  80199c:	68 bc 26 80 00       	push   $0x8026bc
  8019a1:	68 63 26 80 00       	push   $0x802663
  8019a6:	6a 6d                	push   $0x6d
  8019a8:	68 b0 26 80 00       	push   $0x8026b0
  8019ad:	e8 e8 04 00 00       	call   801e9a <_panic>

008019b2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8019c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c3:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8019c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019cb:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8019d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8019d5:	e8 a5 fd ff ff       	call   80177f <nsipc>
}
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019e4:	83 ec 0c             	sub    $0xc,%esp
  8019e7:	ff 75 08             	push   0x8(%ebp)
  8019ea:	e8 ad f3 ff ff       	call   800d9c <fd2data>
  8019ef:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019f1:	83 c4 08             	add    $0x8,%esp
  8019f4:	68 c8 26 80 00       	push   $0x8026c8
  8019f9:	53                   	push   %ebx
  8019fa:	e8 3f ed ff ff       	call   80073e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ff:	8b 46 04             	mov    0x4(%esi),%eax
  801a02:	2b 06                	sub    (%esi),%eax
  801a04:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a0a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a11:	00 00 00 
	stat->st_dev = &devpipe;
  801a14:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a1b:	30 80 00 
	return 0;
}
  801a1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a26:	5b                   	pop    %ebx
  801a27:	5e                   	pop    %esi
  801a28:	5d                   	pop    %ebp
  801a29:	c3                   	ret    

00801a2a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	53                   	push   %ebx
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a34:	53                   	push   %ebx
  801a35:	6a 00                	push   $0x0
  801a37:	e8 83 f1 ff ff       	call   800bbf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a3c:	89 1c 24             	mov    %ebx,(%esp)
  801a3f:	e8 58 f3 ff ff       	call   800d9c <fd2data>
  801a44:	83 c4 08             	add    $0x8,%esp
  801a47:	50                   	push   %eax
  801a48:	6a 00                	push   $0x0
  801a4a:	e8 70 f1 ff ff       	call   800bbf <sys_page_unmap>
}
  801a4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <_pipeisclosed>:
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	57                   	push   %edi
  801a58:	56                   	push   %esi
  801a59:	53                   	push   %ebx
  801a5a:	83 ec 1c             	sub    $0x1c,%esp
  801a5d:	89 c7                	mov    %eax,%edi
  801a5f:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a61:	a1 00 40 80 00       	mov    0x804000,%eax
  801a66:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a69:	83 ec 0c             	sub    $0xc,%esp
  801a6c:	57                   	push   %edi
  801a6d:	e8 62 05 00 00       	call   801fd4 <pageref>
  801a72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a75:	89 34 24             	mov    %esi,(%esp)
  801a78:	e8 57 05 00 00       	call   801fd4 <pageref>
		nn = thisenv->env_runs;
  801a7d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a83:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	39 cb                	cmp    %ecx,%ebx
  801a8b:	74 1b                	je     801aa8 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a8d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a90:	75 cf                	jne    801a61 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a92:	8b 42 58             	mov    0x58(%edx),%eax
  801a95:	6a 01                	push   $0x1
  801a97:	50                   	push   %eax
  801a98:	53                   	push   %ebx
  801a99:	68 cf 26 80 00       	push   $0x8026cf
  801a9e:	e8 c1 e6 ff ff       	call   800164 <cprintf>
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	eb b9                	jmp    801a61 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801aa8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801aab:	0f 94 c0             	sete   %al
  801aae:	0f b6 c0             	movzbl %al,%eax
}
  801ab1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5f                   	pop    %edi
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <devpipe_write>:
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	57                   	push   %edi
  801abd:	56                   	push   %esi
  801abe:	53                   	push   %ebx
  801abf:	83 ec 28             	sub    $0x28,%esp
  801ac2:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ac5:	56                   	push   %esi
  801ac6:	e8 d1 f2 ff ff       	call   800d9c <fd2data>
  801acb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ad8:	75 09                	jne    801ae3 <devpipe_write+0x2a>
	return i;
  801ada:	89 f8                	mov    %edi,%eax
  801adc:	eb 23                	jmp    801b01 <devpipe_write+0x48>
			sys_yield();
  801ade:	e8 38 f0 ff ff       	call   800b1b <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae3:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae6:	8b 0b                	mov    (%ebx),%ecx
  801ae8:	8d 51 20             	lea    0x20(%ecx),%edx
  801aeb:	39 d0                	cmp    %edx,%eax
  801aed:	72 1a                	jb     801b09 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801aef:	89 da                	mov    %ebx,%edx
  801af1:	89 f0                	mov    %esi,%eax
  801af3:	e8 5c ff ff ff       	call   801a54 <_pipeisclosed>
  801af8:	85 c0                	test   %eax,%eax
  801afa:	74 e2                	je     801ade <devpipe_write+0x25>
				return 0;
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5e                   	pop    %esi
  801b06:	5f                   	pop    %edi
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b10:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b13:	89 c2                	mov    %eax,%edx
  801b15:	c1 fa 1f             	sar    $0x1f,%edx
  801b18:	89 d1                	mov    %edx,%ecx
  801b1a:	c1 e9 1b             	shr    $0x1b,%ecx
  801b1d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b20:	83 e2 1f             	and    $0x1f,%edx
  801b23:	29 ca                	sub    %ecx,%edx
  801b25:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b29:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b2d:	83 c0 01             	add    $0x1,%eax
  801b30:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b33:	83 c7 01             	add    $0x1,%edi
  801b36:	eb 9d                	jmp    801ad5 <devpipe_write+0x1c>

00801b38 <devpipe_read>:
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	57                   	push   %edi
  801b3c:	56                   	push   %esi
  801b3d:	53                   	push   %ebx
  801b3e:	83 ec 18             	sub    $0x18,%esp
  801b41:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b44:	57                   	push   %edi
  801b45:	e8 52 f2 ff ff       	call   800d9c <fd2data>
  801b4a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	be 00 00 00 00       	mov    $0x0,%esi
  801b54:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b57:	75 13                	jne    801b6c <devpipe_read+0x34>
	return i;
  801b59:	89 f0                	mov    %esi,%eax
  801b5b:	eb 02                	jmp    801b5f <devpipe_read+0x27>
				return i;
  801b5d:	89 f0                	mov    %esi,%eax
}
  801b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b62:	5b                   	pop    %ebx
  801b63:	5e                   	pop    %esi
  801b64:	5f                   	pop    %edi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    
			sys_yield();
  801b67:	e8 af ef ff ff       	call   800b1b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b6c:	8b 03                	mov    (%ebx),%eax
  801b6e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b71:	75 18                	jne    801b8b <devpipe_read+0x53>
			if (i > 0)
  801b73:	85 f6                	test   %esi,%esi
  801b75:	75 e6                	jne    801b5d <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801b77:	89 da                	mov    %ebx,%edx
  801b79:	89 f8                	mov    %edi,%eax
  801b7b:	e8 d4 fe ff ff       	call   801a54 <_pipeisclosed>
  801b80:	85 c0                	test   %eax,%eax
  801b82:	74 e3                	je     801b67 <devpipe_read+0x2f>
				return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
  801b89:	eb d4                	jmp    801b5f <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b8b:	99                   	cltd   
  801b8c:	c1 ea 1b             	shr    $0x1b,%edx
  801b8f:	01 d0                	add    %edx,%eax
  801b91:	83 e0 1f             	and    $0x1f,%eax
  801b94:	29 d0                	sub    %edx,%eax
  801b96:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ba1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ba4:	83 c6 01             	add    $0x1,%esi
  801ba7:	eb ab                	jmp    801b54 <devpipe_read+0x1c>

00801ba9 <pipe>:
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	56                   	push   %esi
  801bad:	53                   	push   %ebx
  801bae:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb4:	50                   	push   %eax
  801bb5:	e8 f9 f1 ff ff       	call   800db3 <fd_alloc>
  801bba:	89 c3                	mov    %eax,%ebx
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	0f 88 23 01 00 00    	js     801cea <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc7:	83 ec 04             	sub    $0x4,%esp
  801bca:	68 07 04 00 00       	push   $0x407
  801bcf:	ff 75 f4             	push   -0xc(%ebp)
  801bd2:	6a 00                	push   $0x0
  801bd4:	e8 61 ef ff ff       	call   800b3a <sys_page_alloc>
  801bd9:	89 c3                	mov    %eax,%ebx
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	85 c0                	test   %eax,%eax
  801be0:	0f 88 04 01 00 00    	js     801cea <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801be6:	83 ec 0c             	sub    $0xc,%esp
  801be9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bec:	50                   	push   %eax
  801bed:	e8 c1 f1 ff ff       	call   800db3 <fd_alloc>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	0f 88 db 00 00 00    	js     801cda <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bff:	83 ec 04             	sub    $0x4,%esp
  801c02:	68 07 04 00 00       	push   $0x407
  801c07:	ff 75 f0             	push   -0x10(%ebp)
  801c0a:	6a 00                	push   $0x0
  801c0c:	e8 29 ef ff ff       	call   800b3a <sys_page_alloc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	85 c0                	test   %eax,%eax
  801c18:	0f 88 bc 00 00 00    	js     801cda <pipe+0x131>
	va = fd2data(fd0);
  801c1e:	83 ec 0c             	sub    $0xc,%esp
  801c21:	ff 75 f4             	push   -0xc(%ebp)
  801c24:	e8 73 f1 ff ff       	call   800d9c <fd2data>
  801c29:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2b:	83 c4 0c             	add    $0xc,%esp
  801c2e:	68 07 04 00 00       	push   $0x407
  801c33:	50                   	push   %eax
  801c34:	6a 00                	push   $0x0
  801c36:	e8 ff ee ff ff       	call   800b3a <sys_page_alloc>
  801c3b:	89 c3                	mov    %eax,%ebx
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	85 c0                	test   %eax,%eax
  801c42:	0f 88 82 00 00 00    	js     801cca <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c48:	83 ec 0c             	sub    $0xc,%esp
  801c4b:	ff 75 f0             	push   -0x10(%ebp)
  801c4e:	e8 49 f1 ff ff       	call   800d9c <fd2data>
  801c53:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c5a:	50                   	push   %eax
  801c5b:	6a 00                	push   $0x0
  801c5d:	56                   	push   %esi
  801c5e:	6a 00                	push   $0x0
  801c60:	e8 18 ef ff ff       	call   800b7d <sys_page_map>
  801c65:	89 c3                	mov    %eax,%ebx
  801c67:	83 c4 20             	add    $0x20,%esp
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	78 4e                	js     801cbc <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c6e:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801c73:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c76:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c7b:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c82:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c85:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c91:	83 ec 0c             	sub    $0xc,%esp
  801c94:	ff 75 f4             	push   -0xc(%ebp)
  801c97:	e8 f0 f0 ff ff       	call   800d8c <fd2num>
  801c9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca1:	83 c4 04             	add    $0x4,%esp
  801ca4:	ff 75 f0             	push   -0x10(%ebp)
  801ca7:	e8 e0 f0 ff ff       	call   800d8c <fd2num>
  801cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801caf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cba:	eb 2e                	jmp    801cea <pipe+0x141>
	sys_page_unmap(0, va);
  801cbc:	83 ec 08             	sub    $0x8,%esp
  801cbf:	56                   	push   %esi
  801cc0:	6a 00                	push   $0x0
  801cc2:	e8 f8 ee ff ff       	call   800bbf <sys_page_unmap>
  801cc7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cca:	83 ec 08             	sub    $0x8,%esp
  801ccd:	ff 75 f0             	push   -0x10(%ebp)
  801cd0:	6a 00                	push   $0x0
  801cd2:	e8 e8 ee ff ff       	call   800bbf <sys_page_unmap>
  801cd7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	ff 75 f4             	push   -0xc(%ebp)
  801ce0:	6a 00                	push   $0x0
  801ce2:	e8 d8 ee ff ff       	call   800bbf <sys_page_unmap>
  801ce7:	83 c4 10             	add    $0x10,%esp
}
  801cea:	89 d8                	mov    %ebx,%eax
  801cec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    

00801cf3 <pipeisclosed>:
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfc:	50                   	push   %eax
  801cfd:	ff 75 08             	push   0x8(%ebp)
  801d00:	e8 fe f0 ff ff       	call   800e03 <fd_lookup>
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	78 18                	js     801d24 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	ff 75 f4             	push   -0xc(%ebp)
  801d12:	e8 85 f0 ff ff       	call   800d9c <fd2data>
  801d17:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1c:	e8 33 fd ff ff       	call   801a54 <_pipeisclosed>
  801d21:	83 c4 10             	add    $0x10,%esp
}
  801d24:	c9                   	leave  
  801d25:	c3                   	ret    

00801d26 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d26:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2b:	c3                   	ret    

00801d2c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d32:	68 e7 26 80 00       	push   $0x8026e7
  801d37:	ff 75 0c             	push   0xc(%ebp)
  801d3a:	e8 ff e9 ff ff       	call   80073e <strcpy>
	return 0;
}
  801d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <devcons_write>:
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	57                   	push   %edi
  801d4a:	56                   	push   %esi
  801d4b:	53                   	push   %ebx
  801d4c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d52:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d57:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d5d:	eb 2e                	jmp    801d8d <devcons_write+0x47>
		m = n - tot;
  801d5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d62:	29 f3                	sub    %esi,%ebx
  801d64:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d69:	39 c3                	cmp    %eax,%ebx
  801d6b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d6e:	83 ec 04             	sub    $0x4,%esp
  801d71:	53                   	push   %ebx
  801d72:	89 f0                	mov    %esi,%eax
  801d74:	03 45 0c             	add    0xc(%ebp),%eax
  801d77:	50                   	push   %eax
  801d78:	57                   	push   %edi
  801d79:	e8 56 eb ff ff       	call   8008d4 <memmove>
		sys_cputs(buf, m);
  801d7e:	83 c4 08             	add    $0x8,%esp
  801d81:	53                   	push   %ebx
  801d82:	57                   	push   %edi
  801d83:	e8 f6 ec ff ff       	call   800a7e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d88:	01 de                	add    %ebx,%esi
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d90:	72 cd                	jb     801d5f <devcons_write+0x19>
}
  801d92:	89 f0                	mov    %esi,%eax
  801d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    

00801d9c <devcons_read>:
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 08             	sub    $0x8,%esp
  801da2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801da7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dab:	75 07                	jne    801db4 <devcons_read+0x18>
  801dad:	eb 1f                	jmp    801dce <devcons_read+0x32>
		sys_yield();
  801daf:	e8 67 ed ff ff       	call   800b1b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801db4:	e8 e3 ec ff ff       	call   800a9c <sys_cgetc>
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	74 f2                	je     801daf <devcons_read+0x13>
	if (c < 0)
  801dbd:	78 0f                	js     801dce <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801dbf:	83 f8 04             	cmp    $0x4,%eax
  801dc2:	74 0c                	je     801dd0 <devcons_read+0x34>
	*(char*)vbuf = c;
  801dc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc7:	88 02                	mov    %al,(%edx)
	return 1;
  801dc9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    
		return 0;
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd5:	eb f7                	jmp    801dce <devcons_read+0x32>

00801dd7 <cputchar>:
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801de3:	6a 01                	push   $0x1
  801de5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de8:	50                   	push   %eax
  801de9:	e8 90 ec ff ff       	call   800a7e <sys_cputs>
}
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <getchar>:
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801df9:	6a 01                	push   $0x1
  801dfb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	6a 00                	push   $0x0
  801e01:	e8 66 f2 ff ff       	call   80106c <read>
	if (r < 0)
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	78 06                	js     801e13 <getchar+0x20>
	if (r < 1)
  801e0d:	74 06                	je     801e15 <getchar+0x22>
	return c;
  801e0f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e13:	c9                   	leave  
  801e14:	c3                   	ret    
		return -E_EOF;
  801e15:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e1a:	eb f7                	jmp    801e13 <getchar+0x20>

00801e1c <iscons>:
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e25:	50                   	push   %eax
  801e26:	ff 75 08             	push   0x8(%ebp)
  801e29:	e8 d5 ef ff ff       	call   800e03 <fd_lookup>
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 11                	js     801e46 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e38:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e3e:	39 10                	cmp    %edx,(%eax)
  801e40:	0f 94 c0             	sete   %al
  801e43:	0f b6 c0             	movzbl %al,%eax
}
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    

00801e48 <opencons>:
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e51:	50                   	push   %eax
  801e52:	e8 5c ef ff ff       	call   800db3 <fd_alloc>
  801e57:	83 c4 10             	add    $0x10,%esp
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	78 3a                	js     801e98 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e5e:	83 ec 04             	sub    $0x4,%esp
  801e61:	68 07 04 00 00       	push   $0x407
  801e66:	ff 75 f4             	push   -0xc(%ebp)
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 ca ec ff ff       	call   800b3a <sys_page_alloc>
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 21                	js     801e98 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e80:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e85:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	50                   	push   %eax
  801e90:	e8 f7 ee ff ff       	call   800d8c <fd2num>
  801e95:	83 c4 10             	add    $0x10,%esp
}
  801e98:	c9                   	leave  
  801e99:	c3                   	ret    

00801e9a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	56                   	push   %esi
  801e9e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e9f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ea2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ea8:	e8 4f ec ff ff       	call   800afc <sys_getenvid>
  801ead:	83 ec 0c             	sub    $0xc,%esp
  801eb0:	ff 75 0c             	push   0xc(%ebp)
  801eb3:	ff 75 08             	push   0x8(%ebp)
  801eb6:	56                   	push   %esi
  801eb7:	50                   	push   %eax
  801eb8:	68 f4 26 80 00       	push   $0x8026f4
  801ebd:	e8 a2 e2 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ec2:	83 c4 18             	add    $0x18,%esp
  801ec5:	53                   	push   %ebx
  801ec6:	ff 75 10             	push   0x10(%ebp)
  801ec9:	e8 45 e2 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  801ece:	c7 04 24 e0 26 80 00 	movl   $0x8026e0,(%esp)
  801ed5:	e8 8a e2 ff ff       	call   800164 <cprintf>
  801eda:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801edd:	cc                   	int3   
  801ede:	eb fd                	jmp    801edd <_panic+0x43>

00801ee0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	56                   	push   %esi
  801ee4:	53                   	push   %ebx
  801ee5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ef5:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ef8:	83 ec 0c             	sub    $0xc,%esp
  801efb:	50                   	push   %eax
  801efc:	e8 e9 ed ff ff       	call   800cea <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	85 f6                	test   %esi,%esi
  801f06:	74 14                	je     801f1c <ipc_recv+0x3c>
  801f08:	ba 00 00 00 00       	mov    $0x0,%edx
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	78 09                	js     801f1a <ipc_recv+0x3a>
  801f11:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f17:	8b 52 74             	mov    0x74(%edx),%edx
  801f1a:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f1c:	85 db                	test   %ebx,%ebx
  801f1e:	74 14                	je     801f34 <ipc_recv+0x54>
  801f20:	ba 00 00 00 00       	mov    $0x0,%edx
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 09                	js     801f32 <ipc_recv+0x52>
  801f29:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f2f:	8b 52 78             	mov    0x78(%edx),%edx
  801f32:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f34:	85 c0                	test   %eax,%eax
  801f36:	78 08                	js     801f40 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f38:	a1 00 40 80 00       	mov    0x804000,%eax
  801f3d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5e                   	pop    %esi
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    

00801f47 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	57                   	push   %edi
  801f4b:	56                   	push   %esi
  801f4c:	53                   	push   %ebx
  801f4d:	83 ec 0c             	sub    $0xc,%esp
  801f50:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f53:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f59:	85 db                	test   %ebx,%ebx
  801f5b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f60:	0f 44 d8             	cmove  %eax,%ebx
  801f63:	eb 05                	jmp    801f6a <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f65:	e8 b1 eb ff ff       	call   800b1b <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f6a:	ff 75 14             	push   0x14(%ebp)
  801f6d:	53                   	push   %ebx
  801f6e:	56                   	push   %esi
  801f6f:	57                   	push   %edi
  801f70:	e8 52 ed ff ff       	call   800cc7 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f7b:	74 e8                	je     801f65 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	78 08                	js     801f89 <ipc_send+0x42>
	}while (r<0);

}
  801f81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f84:	5b                   	pop    %ebx
  801f85:	5e                   	pop    %esi
  801f86:	5f                   	pop    %edi
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f89:	50                   	push   %eax
  801f8a:	68 17 27 80 00       	push   $0x802717
  801f8f:	6a 3d                	push   $0x3d
  801f91:	68 2b 27 80 00       	push   $0x80272b
  801f96:	e8 ff fe ff ff       	call   801e9a <_panic>

00801f9b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fa9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801faf:	8b 52 50             	mov    0x50(%edx),%edx
  801fb2:	39 ca                	cmp    %ecx,%edx
  801fb4:	74 11                	je     801fc7 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801fb6:	83 c0 01             	add    $0x1,%eax
  801fb9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fbe:	75 e6                	jne    801fa6 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc5:	eb 0b                	jmp    801fd2 <ipc_find_env+0x37>
			return envs[i].env_id;
  801fc7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fcf:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    

00801fd4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fda:	89 c2                	mov    %eax,%edx
  801fdc:	c1 ea 16             	shr    $0x16,%edx
  801fdf:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fe6:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801feb:	f6 c1 01             	test   $0x1,%cl
  801fee:	74 1c                	je     80200c <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ff0:	c1 e8 0c             	shr    $0xc,%eax
  801ff3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ffa:	a8 01                	test   $0x1,%al
  801ffc:	74 0e                	je     80200c <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ffe:	c1 e8 0c             	shr    $0xc,%eax
  802001:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802008:	ef 
  802009:	0f b7 d2             	movzwl %dx,%edx
}
  80200c:	89 d0                	mov    %edx,%eax
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    

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
