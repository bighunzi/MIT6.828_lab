
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
  80004e:	68 ae 1d 80 00       	push   $0x801dae
  800053:	e8 0c 01 00 00       	call   800164 <cprintf>
}
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    
		cprintf("eflags wrong\n");
  80005d:	83 ec 0c             	sub    $0xc,%esp
  800060:	68 a0 1d 80 00       	push   $0x801da0
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
  8000bb:	e8 37 0e 00 00       	call   800ef7 <close_all>
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
  8001c6:	e8 85 19 00 00       	call   801b50 <__udivdi3>
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
  800204:	e8 67 1a 00 00       	call   801c70 <__umoddi3>
  800209:	83 c4 14             	add    $0x14,%esp
  80020c:	0f be 80 d2 1d 80 00 	movsbl 0x801dd2(%eax),%eax
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
  8002c6:	ff 24 85 20 1f 80 00 	jmp    *0x801f20(,%eax,4)
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
  800394:	8b 14 85 80 20 80 00 	mov    0x802080(,%eax,4),%edx
  80039b:	85 d2                	test   %edx,%edx
  80039d:	74 18                	je     8003b7 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80039f:	52                   	push   %edx
  8003a0:	68 b1 21 80 00       	push   $0x8021b1
  8003a5:	53                   	push   %ebx
  8003a6:	56                   	push   %esi
  8003a7:	e8 92 fe ff ff       	call   80023e <printfmt>
  8003ac:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003af:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003b2:	e9 66 02 00 00       	jmp    80061d <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003b7:	50                   	push   %eax
  8003b8:	68 ea 1d 80 00       	push   $0x801dea
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
  8003df:	b8 e3 1d 80 00       	mov    $0x801de3,%eax
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
  800aeb:	68 df 20 80 00       	push   $0x8020df
  800af0:	6a 2a                	push   $0x2a
  800af2:	68 fc 20 80 00       	push   $0x8020fc
  800af7:	e8 d0 0e 00 00       	call   8019cc <_panic>

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
  800b6c:	68 df 20 80 00       	push   $0x8020df
  800b71:	6a 2a                	push   $0x2a
  800b73:	68 fc 20 80 00       	push   $0x8020fc
  800b78:	e8 4f 0e 00 00       	call   8019cc <_panic>

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
  800bae:	68 df 20 80 00       	push   $0x8020df
  800bb3:	6a 2a                	push   $0x2a
  800bb5:	68 fc 20 80 00       	push   $0x8020fc
  800bba:	e8 0d 0e 00 00       	call   8019cc <_panic>

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
  800bf0:	68 df 20 80 00       	push   $0x8020df
  800bf5:	6a 2a                	push   $0x2a
  800bf7:	68 fc 20 80 00       	push   $0x8020fc
  800bfc:	e8 cb 0d 00 00       	call   8019cc <_panic>

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
  800c32:	68 df 20 80 00       	push   $0x8020df
  800c37:	6a 2a                	push   $0x2a
  800c39:	68 fc 20 80 00       	push   $0x8020fc
  800c3e:	e8 89 0d 00 00       	call   8019cc <_panic>

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
  800c74:	68 df 20 80 00       	push   $0x8020df
  800c79:	6a 2a                	push   $0x2a
  800c7b:	68 fc 20 80 00       	push   $0x8020fc
  800c80:	e8 47 0d 00 00       	call   8019cc <_panic>

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
  800cb6:	68 df 20 80 00       	push   $0x8020df
  800cbb:	6a 2a                	push   $0x2a
  800cbd:	68 fc 20 80 00       	push   $0x8020fc
  800cc2:	e8 05 0d 00 00       	call   8019cc <_panic>

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
  800d1a:	68 df 20 80 00       	push   $0x8020df
  800d1f:	6a 2a                	push   $0x2a
  800d21:	68 fc 20 80 00       	push   $0x8020fc
  800d26:	e8 a1 0c 00 00       	call   8019cc <_panic>

00800d2b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	05 00 00 00 30       	add    $0x30000000,%eax
  800d36:	c1 e8 0c             	shr    $0xc,%eax
}
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d4b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d5a:	89 c2                	mov    %eax,%edx
  800d5c:	c1 ea 16             	shr    $0x16,%edx
  800d5f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d66:	f6 c2 01             	test   $0x1,%dl
  800d69:	74 29                	je     800d94 <fd_alloc+0x42>
  800d6b:	89 c2                	mov    %eax,%edx
  800d6d:	c1 ea 0c             	shr    $0xc,%edx
  800d70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d77:	f6 c2 01             	test   $0x1,%dl
  800d7a:	74 18                	je     800d94 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800d7c:	05 00 10 00 00       	add    $0x1000,%eax
  800d81:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d86:	75 d2                	jne    800d5a <fd_alloc+0x8>
  800d88:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800d8d:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800d92:	eb 05                	jmp    800d99 <fd_alloc+0x47>
			return 0;
  800d94:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 02                	mov    %eax,(%edx)
}
  800d9e:	89 c8                	mov    %ecx,%eax
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da8:	83 f8 1f             	cmp    $0x1f,%eax
  800dab:	77 30                	ja     800ddd <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dad:	c1 e0 0c             	shl    $0xc,%eax
  800db0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800db5:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800dbb:	f6 c2 01             	test   $0x1,%dl
  800dbe:	74 24                	je     800de4 <fd_lookup+0x42>
  800dc0:	89 c2                	mov    %eax,%edx
  800dc2:	c1 ea 0c             	shr    $0xc,%edx
  800dc5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dcc:	f6 c2 01             	test   $0x1,%dl
  800dcf:	74 1a                	je     800deb <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd4:	89 02                	mov    %eax,(%edx)
	return 0;
  800dd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    
		return -E_INVAL;
  800ddd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de2:	eb f7                	jmp    800ddb <fd_lookup+0x39>
		return -E_INVAL;
  800de4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de9:	eb f0                	jmp    800ddb <fd_lookup+0x39>
  800deb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df0:	eb e9                	jmp    800ddb <fd_lookup+0x39>

00800df2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	53                   	push   %ebx
  800df6:	83 ec 04             	sub    $0x4,%esp
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	b8 88 21 80 00       	mov    $0x802188,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800e01:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e06:	39 13                	cmp    %edx,(%ebx)
  800e08:	74 32                	je     800e3c <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800e0a:	83 c0 04             	add    $0x4,%eax
  800e0d:	8b 18                	mov    (%eax),%ebx
  800e0f:	85 db                	test   %ebx,%ebx
  800e11:	75 f3                	jne    800e06 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e13:	a1 00 40 80 00       	mov    0x804000,%eax
  800e18:	8b 40 48             	mov    0x48(%eax),%eax
  800e1b:	83 ec 04             	sub    $0x4,%esp
  800e1e:	52                   	push   %edx
  800e1f:	50                   	push   %eax
  800e20:	68 0c 21 80 00       	push   $0x80210c
  800e25:	e8 3a f3 ff ff       	call   800164 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e35:	89 1a                	mov    %ebx,(%edx)
}
  800e37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3a:	c9                   	leave  
  800e3b:	c3                   	ret    
			return 0;
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e41:	eb ef                	jmp    800e32 <dev_lookup+0x40>

00800e43 <fd_close>:
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 24             	sub    $0x24,%esp
  800e4c:	8b 75 08             	mov    0x8(%ebp),%esi
  800e4f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e52:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e55:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e56:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e5c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e5f:	50                   	push   %eax
  800e60:	e8 3d ff ff ff       	call   800da2 <fd_lookup>
  800e65:	89 c3                	mov    %eax,%ebx
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	78 05                	js     800e73 <fd_close+0x30>
	    || fd != fd2)
  800e6e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800e71:	74 16                	je     800e89 <fd_close+0x46>
		return (must_exist ? r : 0);
  800e73:	89 f8                	mov    %edi,%eax
  800e75:	84 c0                	test   %al,%al
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7c:	0f 44 d8             	cmove  %eax,%ebx
}
  800e7f:	89 d8                	mov    %ebx,%eax
  800e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e89:	83 ec 08             	sub    $0x8,%esp
  800e8c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e8f:	50                   	push   %eax
  800e90:	ff 36                	push   (%esi)
  800e92:	e8 5b ff ff ff       	call   800df2 <dev_lookup>
  800e97:	89 c3                	mov    %eax,%ebx
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	78 1a                	js     800eba <fd_close+0x77>
		if (dev->dev_close)
  800ea0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ea3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800eab:	85 c0                	test   %eax,%eax
  800ead:	74 0b                	je     800eba <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800eaf:	83 ec 0c             	sub    $0xc,%esp
  800eb2:	56                   	push   %esi
  800eb3:	ff d0                	call   *%eax
  800eb5:	89 c3                	mov    %eax,%ebx
  800eb7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800eba:	83 ec 08             	sub    $0x8,%esp
  800ebd:	56                   	push   %esi
  800ebe:	6a 00                	push   $0x0
  800ec0:	e8 fa fc ff ff       	call   800bbf <sys_page_unmap>
	return r;
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	eb b5                	jmp    800e7f <fd_close+0x3c>

00800eca <close>:

int
close(int fdnum)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed3:	50                   	push   %eax
  800ed4:	ff 75 08             	push   0x8(%ebp)
  800ed7:	e8 c6 fe ff ff       	call   800da2 <fd_lookup>
  800edc:	83 c4 10             	add    $0x10,%esp
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	79 02                	jns    800ee5 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    
		return fd_close(fd, 1);
  800ee5:	83 ec 08             	sub    $0x8,%esp
  800ee8:	6a 01                	push   $0x1
  800eea:	ff 75 f4             	push   -0xc(%ebp)
  800eed:	e8 51 ff ff ff       	call   800e43 <fd_close>
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	eb ec                	jmp    800ee3 <close+0x19>

00800ef7 <close_all>:

void
close_all(void)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	53                   	push   %ebx
  800efb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800efe:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	53                   	push   %ebx
  800f07:	e8 be ff ff ff       	call   800eca <close>
	for (i = 0; i < MAXFD; i++)
  800f0c:	83 c3 01             	add    $0x1,%ebx
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	83 fb 20             	cmp    $0x20,%ebx
  800f15:	75 ec                	jne    800f03 <close_all+0xc>
}
  800f17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    

00800f1c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f28:	50                   	push   %eax
  800f29:	ff 75 08             	push   0x8(%ebp)
  800f2c:	e8 71 fe ff ff       	call   800da2 <fd_lookup>
  800f31:	89 c3                	mov    %eax,%ebx
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	78 7f                	js     800fb9 <dup+0x9d>
		return r;
	close(newfdnum);
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	ff 75 0c             	push   0xc(%ebp)
  800f40:	e8 85 ff ff ff       	call   800eca <close>

	newfd = INDEX2FD(newfdnum);
  800f45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f48:	c1 e6 0c             	shl    $0xc,%esi
  800f4b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f54:	89 3c 24             	mov    %edi,(%esp)
  800f57:	e8 df fd ff ff       	call   800d3b <fd2data>
  800f5c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f5e:	89 34 24             	mov    %esi,(%esp)
  800f61:	e8 d5 fd ff ff       	call   800d3b <fd2data>
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f6c:	89 d8                	mov    %ebx,%eax
  800f6e:	c1 e8 16             	shr    $0x16,%eax
  800f71:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f78:	a8 01                	test   $0x1,%al
  800f7a:	74 11                	je     800f8d <dup+0x71>
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	c1 e8 0c             	shr    $0xc,%eax
  800f81:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f88:	f6 c2 01             	test   $0x1,%dl
  800f8b:	75 36                	jne    800fc3 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f8d:	89 f8                	mov    %edi,%eax
  800f8f:	c1 e8 0c             	shr    $0xc,%eax
  800f92:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa1:	50                   	push   %eax
  800fa2:	56                   	push   %esi
  800fa3:	6a 00                	push   $0x0
  800fa5:	57                   	push   %edi
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 d0 fb ff ff       	call   800b7d <sys_page_map>
  800fad:	89 c3                	mov    %eax,%ebx
  800faf:	83 c4 20             	add    $0x20,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 33                	js     800fe9 <dup+0xcd>
		goto err;

	return newfdnum;
  800fb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800fb9:	89 d8                	mov    %ebx,%eax
  800fbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fc3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd2:	50                   	push   %eax
  800fd3:	ff 75 d4             	push   -0x2c(%ebp)
  800fd6:	6a 00                	push   $0x0
  800fd8:	53                   	push   %ebx
  800fd9:	6a 00                	push   $0x0
  800fdb:	e8 9d fb ff ff       	call   800b7d <sys_page_map>
  800fe0:	89 c3                	mov    %eax,%ebx
  800fe2:	83 c4 20             	add    $0x20,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	79 a4                	jns    800f8d <dup+0x71>
	sys_page_unmap(0, newfd);
  800fe9:	83 ec 08             	sub    $0x8,%esp
  800fec:	56                   	push   %esi
  800fed:	6a 00                	push   $0x0
  800fef:	e8 cb fb ff ff       	call   800bbf <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ff4:	83 c4 08             	add    $0x8,%esp
  800ff7:	ff 75 d4             	push   -0x2c(%ebp)
  800ffa:	6a 00                	push   $0x0
  800ffc:	e8 be fb ff ff       	call   800bbf <sys_page_unmap>
	return r;
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	eb b3                	jmp    800fb9 <dup+0x9d>

00801006 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	56                   	push   %esi
  80100a:	53                   	push   %ebx
  80100b:	83 ec 18             	sub    $0x18,%esp
  80100e:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801011:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801014:	50                   	push   %eax
  801015:	56                   	push   %esi
  801016:	e8 87 fd ff ff       	call   800da2 <fd_lookup>
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 3c                	js     80105e <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801022:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801025:	83 ec 08             	sub    $0x8,%esp
  801028:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102b:	50                   	push   %eax
  80102c:	ff 33                	push   (%ebx)
  80102e:	e8 bf fd ff ff       	call   800df2 <dev_lookup>
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	78 24                	js     80105e <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80103a:	8b 43 08             	mov    0x8(%ebx),%eax
  80103d:	83 e0 03             	and    $0x3,%eax
  801040:	83 f8 01             	cmp    $0x1,%eax
  801043:	74 20                	je     801065 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801045:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801048:	8b 40 08             	mov    0x8(%eax),%eax
  80104b:	85 c0                	test   %eax,%eax
  80104d:	74 37                	je     801086 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	ff 75 10             	push   0x10(%ebp)
  801055:	ff 75 0c             	push   0xc(%ebp)
  801058:	53                   	push   %ebx
  801059:	ff d0                	call   *%eax
  80105b:	83 c4 10             	add    $0x10,%esp
}
  80105e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801065:	a1 00 40 80 00       	mov    0x804000,%eax
  80106a:	8b 40 48             	mov    0x48(%eax),%eax
  80106d:	83 ec 04             	sub    $0x4,%esp
  801070:	56                   	push   %esi
  801071:	50                   	push   %eax
  801072:	68 4d 21 80 00       	push   $0x80214d
  801077:	e8 e8 f0 ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801084:	eb d8                	jmp    80105e <read+0x58>
		return -E_NOT_SUPP;
  801086:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80108b:	eb d1                	jmp    80105e <read+0x58>

0080108d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	8b 7d 08             	mov    0x8(%ebp),%edi
  801099:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80109c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a1:	eb 02                	jmp    8010a5 <readn+0x18>
  8010a3:	01 c3                	add    %eax,%ebx
  8010a5:	39 f3                	cmp    %esi,%ebx
  8010a7:	73 21                	jae    8010ca <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	89 f0                	mov    %esi,%eax
  8010ae:	29 d8                	sub    %ebx,%eax
  8010b0:	50                   	push   %eax
  8010b1:	89 d8                	mov    %ebx,%eax
  8010b3:	03 45 0c             	add    0xc(%ebp),%eax
  8010b6:	50                   	push   %eax
  8010b7:	57                   	push   %edi
  8010b8:	e8 49 ff ff ff       	call   801006 <read>
		if (m < 0)
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	78 04                	js     8010c8 <readn+0x3b>
			return m;
		if (m == 0)
  8010c4:	75 dd                	jne    8010a3 <readn+0x16>
  8010c6:	eb 02                	jmp    8010ca <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010c8:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8010ca:	89 d8                	mov    %ebx,%eax
  8010cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 18             	sub    $0x18,%esp
  8010dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e2:	50                   	push   %eax
  8010e3:	53                   	push   %ebx
  8010e4:	e8 b9 fc ff ff       	call   800da2 <fd_lookup>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 37                	js     801127 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010f3:	83 ec 08             	sub    $0x8,%esp
  8010f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f9:	50                   	push   %eax
  8010fa:	ff 36                	push   (%esi)
  8010fc:	e8 f1 fc ff ff       	call   800df2 <dev_lookup>
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	85 c0                	test   %eax,%eax
  801106:	78 1f                	js     801127 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801108:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80110c:	74 20                	je     80112e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80110e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801111:	8b 40 0c             	mov    0xc(%eax),%eax
  801114:	85 c0                	test   %eax,%eax
  801116:	74 37                	je     80114f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801118:	83 ec 04             	sub    $0x4,%esp
  80111b:	ff 75 10             	push   0x10(%ebp)
  80111e:	ff 75 0c             	push   0xc(%ebp)
  801121:	56                   	push   %esi
  801122:	ff d0                	call   *%eax
  801124:	83 c4 10             	add    $0x10,%esp
}
  801127:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80112a:	5b                   	pop    %ebx
  80112b:	5e                   	pop    %esi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80112e:	a1 00 40 80 00       	mov    0x804000,%eax
  801133:	8b 40 48             	mov    0x48(%eax),%eax
  801136:	83 ec 04             	sub    $0x4,%esp
  801139:	53                   	push   %ebx
  80113a:	50                   	push   %eax
  80113b:	68 69 21 80 00       	push   $0x802169
  801140:	e8 1f f0 ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114d:	eb d8                	jmp    801127 <write+0x53>
		return -E_NOT_SUPP;
  80114f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801154:	eb d1                	jmp    801127 <write+0x53>

00801156 <seek>:

int
seek(int fdnum, off_t offset)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80115c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	ff 75 08             	push   0x8(%ebp)
  801163:	e8 3a fc ff ff       	call   800da2 <fd_lookup>
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 0e                	js     80117d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80116f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801175:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117d:	c9                   	leave  
  80117e:	c3                   	ret    

0080117f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 18             	sub    $0x18,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	53                   	push   %ebx
  80118f:	e8 0e fc ff ff       	call   800da2 <fd_lookup>
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	78 34                	js     8011cf <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a4:	50                   	push   %eax
  8011a5:	ff 36                	push   (%esi)
  8011a7:	e8 46 fc ff ff       	call   800df2 <dev_lookup>
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 1c                	js     8011cf <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b3:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011b7:	74 1d                	je     8011d6 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8011b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bc:	8b 40 18             	mov    0x18(%eax),%eax
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	74 34                	je     8011f7 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	ff 75 0c             	push   0xc(%ebp)
  8011c9:	56                   	push   %esi
  8011ca:	ff d0                	call   *%eax
  8011cc:	83 c4 10             	add    $0x10,%esp
}
  8011cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    
			thisenv->env_id, fdnum);
  8011d6:	a1 00 40 80 00       	mov    0x804000,%eax
  8011db:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	53                   	push   %ebx
  8011e2:	50                   	push   %eax
  8011e3:	68 2c 21 80 00       	push   $0x80212c
  8011e8:	e8 77 ef ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f5:	eb d8                	jmp    8011cf <ftruncate+0x50>
		return -E_NOT_SUPP;
  8011f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011fc:	eb d1                	jmp    8011cf <ftruncate+0x50>

008011fe <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	56                   	push   %esi
  801202:	53                   	push   %ebx
  801203:	83 ec 18             	sub    $0x18,%esp
  801206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801209:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120c:	50                   	push   %eax
  80120d:	ff 75 08             	push   0x8(%ebp)
  801210:	e8 8d fb ff ff       	call   800da2 <fd_lookup>
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 49                	js     801265 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	ff 36                	push   (%esi)
  801228:	e8 c5 fb ff ff       	call   800df2 <dev_lookup>
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	78 31                	js     801265 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801234:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801237:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80123b:	74 2f                	je     80126c <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80123d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801240:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801247:	00 00 00 
	stat->st_isdir = 0;
  80124a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801251:	00 00 00 
	stat->st_dev = dev;
  801254:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	53                   	push   %ebx
  80125e:	56                   	push   %esi
  80125f:	ff 50 14             	call   *0x14(%eax)
  801262:	83 c4 10             	add    $0x10,%esp
}
  801265:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    
		return -E_NOT_SUPP;
  80126c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801271:	eb f2                	jmp    801265 <fstat+0x67>

00801273 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	6a 00                	push   $0x0
  80127d:	ff 75 08             	push   0x8(%ebp)
  801280:	e8 e4 01 00 00       	call   801469 <open>
  801285:	89 c3                	mov    %eax,%ebx
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 1b                	js     8012a9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	ff 75 0c             	push   0xc(%ebp)
  801294:	50                   	push   %eax
  801295:	e8 64 ff ff ff       	call   8011fe <fstat>
  80129a:	89 c6                	mov    %eax,%esi
	close(fd);
  80129c:	89 1c 24             	mov    %ebx,(%esp)
  80129f:	e8 26 fc ff ff       	call   800eca <close>
	return r;
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	89 f3                	mov    %esi,%ebx
}
  8012a9:	89 d8                	mov    %ebx,%eax
  8012ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	56                   	push   %esi
  8012b6:	53                   	push   %ebx
  8012b7:	89 c6                	mov    %eax,%esi
  8012b9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012bb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8012c2:	74 27                	je     8012eb <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012c4:	6a 07                	push   $0x7
  8012c6:	68 00 50 80 00       	push   $0x805000
  8012cb:	56                   	push   %esi
  8012cc:	ff 35 00 60 80 00    	push   0x806000
  8012d2:	e8 a2 07 00 00       	call   801a79 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012d7:	83 c4 0c             	add    $0xc,%esp
  8012da:	6a 00                	push   $0x0
  8012dc:	53                   	push   %ebx
  8012dd:	6a 00                	push   $0x0
  8012df:	e8 2e 07 00 00       	call   801a12 <ipc_recv>
}
  8012e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5e                   	pop    %esi
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012eb:	83 ec 0c             	sub    $0xc,%esp
  8012ee:	6a 01                	push   $0x1
  8012f0:	e8 d8 07 00 00       	call   801acd <ipc_find_env>
  8012f5:	a3 00 60 80 00       	mov    %eax,0x806000
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	eb c5                	jmp    8012c4 <fsipc+0x12>

008012ff <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801305:	8b 45 08             	mov    0x8(%ebp),%eax
  801308:	8b 40 0c             	mov    0xc(%eax),%eax
  80130b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801310:	8b 45 0c             	mov    0xc(%ebp),%eax
  801313:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801318:	ba 00 00 00 00       	mov    $0x0,%edx
  80131d:	b8 02 00 00 00       	mov    $0x2,%eax
  801322:	e8 8b ff ff ff       	call   8012b2 <fsipc>
}
  801327:	c9                   	leave  
  801328:	c3                   	ret    

00801329 <devfile_flush>:
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80132f:	8b 45 08             	mov    0x8(%ebp),%eax
  801332:	8b 40 0c             	mov    0xc(%eax),%eax
  801335:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80133a:	ba 00 00 00 00       	mov    $0x0,%edx
  80133f:	b8 06 00 00 00       	mov    $0x6,%eax
  801344:	e8 69 ff ff ff       	call   8012b2 <fsipc>
}
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <devfile_stat>:
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	53                   	push   %ebx
  80134f:	83 ec 04             	sub    $0x4,%esp
  801352:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801355:	8b 45 08             	mov    0x8(%ebp),%eax
  801358:	8b 40 0c             	mov    0xc(%eax),%eax
  80135b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801360:	ba 00 00 00 00       	mov    $0x0,%edx
  801365:	b8 05 00 00 00       	mov    $0x5,%eax
  80136a:	e8 43 ff ff ff       	call   8012b2 <fsipc>
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 2c                	js     80139f <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	68 00 50 80 00       	push   $0x805000
  80137b:	53                   	push   %ebx
  80137c:	e8 bd f3 ff ff       	call   80073e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801381:	a1 80 50 80 00       	mov    0x805080,%eax
  801386:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80138c:	a1 84 50 80 00       	mov    0x805084,%eax
  801391:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a2:	c9                   	leave  
  8013a3:	c3                   	ret    

008013a4 <devfile_write>:
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	83 ec 0c             	sub    $0xc,%esp
  8013aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ad:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013b2:	39 d0                	cmp    %edx,%eax
  8013b4:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ba:	8b 52 0c             	mov    0xc(%edx),%edx
  8013bd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013c3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013c8:	50                   	push   %eax
  8013c9:	ff 75 0c             	push   0xc(%ebp)
  8013cc:	68 08 50 80 00       	push   $0x805008
  8013d1:	e8 fe f4 ff ff       	call   8008d4 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8013d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013db:	b8 04 00 00 00       	mov    $0x4,%eax
  8013e0:	e8 cd fe ff ff       	call   8012b2 <fsipc>
}
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <devfile_read>:
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	56                   	push   %esi
  8013eb:	53                   	push   %ebx
  8013ec:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013fa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801400:	ba 00 00 00 00       	mov    $0x0,%edx
  801405:	b8 03 00 00 00       	mov    $0x3,%eax
  80140a:	e8 a3 fe ff ff       	call   8012b2 <fsipc>
  80140f:	89 c3                	mov    %eax,%ebx
  801411:	85 c0                	test   %eax,%eax
  801413:	78 1f                	js     801434 <devfile_read+0x4d>
	assert(r <= n);
  801415:	39 f0                	cmp    %esi,%eax
  801417:	77 24                	ja     80143d <devfile_read+0x56>
	assert(r <= PGSIZE);
  801419:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80141e:	7f 33                	jg     801453 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801420:	83 ec 04             	sub    $0x4,%esp
  801423:	50                   	push   %eax
  801424:	68 00 50 80 00       	push   $0x805000
  801429:	ff 75 0c             	push   0xc(%ebp)
  80142c:	e8 a3 f4 ff ff       	call   8008d4 <memmove>
	return r;
  801431:	83 c4 10             	add    $0x10,%esp
}
  801434:	89 d8                	mov    %ebx,%eax
  801436:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801439:	5b                   	pop    %ebx
  80143a:	5e                   	pop    %esi
  80143b:	5d                   	pop    %ebp
  80143c:	c3                   	ret    
	assert(r <= n);
  80143d:	68 98 21 80 00       	push   $0x802198
  801442:	68 9f 21 80 00       	push   $0x80219f
  801447:	6a 7c                	push   $0x7c
  801449:	68 b4 21 80 00       	push   $0x8021b4
  80144e:	e8 79 05 00 00       	call   8019cc <_panic>
	assert(r <= PGSIZE);
  801453:	68 bf 21 80 00       	push   $0x8021bf
  801458:	68 9f 21 80 00       	push   $0x80219f
  80145d:	6a 7d                	push   $0x7d
  80145f:	68 b4 21 80 00       	push   $0x8021b4
  801464:	e8 63 05 00 00       	call   8019cc <_panic>

00801469 <open>:
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	56                   	push   %esi
  80146d:	53                   	push   %ebx
  80146e:	83 ec 1c             	sub    $0x1c,%esp
  801471:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801474:	56                   	push   %esi
  801475:	e8 89 f2 ff ff       	call   800703 <strlen>
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801482:	7f 6c                	jg     8014f0 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801484:	83 ec 0c             	sub    $0xc,%esp
  801487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	e8 c2 f8 ff ff       	call   800d52 <fd_alloc>
  801490:	89 c3                	mov    %eax,%ebx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	85 c0                	test   %eax,%eax
  801497:	78 3c                	js     8014d5 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	56                   	push   %esi
  80149d:	68 00 50 80 00       	push   $0x805000
  8014a2:	e8 97 f2 ff ff       	call   80073e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014aa:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b7:	e8 f6 fd ff ff       	call   8012b2 <fsipc>
  8014bc:	89 c3                	mov    %eax,%ebx
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 19                	js     8014de <open+0x75>
	return fd2num(fd);
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	ff 75 f4             	push   -0xc(%ebp)
  8014cb:	e8 5b f8 ff ff       	call   800d2b <fd2num>
  8014d0:	89 c3                	mov    %eax,%ebx
  8014d2:	83 c4 10             	add    $0x10,%esp
}
  8014d5:	89 d8                	mov    %ebx,%eax
  8014d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014da:	5b                   	pop    %ebx
  8014db:	5e                   	pop    %esi
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    
		fd_close(fd, 0);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	6a 00                	push   $0x0
  8014e3:	ff 75 f4             	push   -0xc(%ebp)
  8014e6:	e8 58 f9 ff ff       	call   800e43 <fd_close>
		return r;
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	eb e5                	jmp    8014d5 <open+0x6c>
		return -E_BAD_PATH;
  8014f0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8014f5:	eb de                	jmp    8014d5 <open+0x6c>

008014f7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801502:	b8 08 00 00 00       	mov    $0x8,%eax
  801507:	e8 a6 fd ff ff       	call   8012b2 <fsipc>
}
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
  801513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801516:	83 ec 0c             	sub    $0xc,%esp
  801519:	ff 75 08             	push   0x8(%ebp)
  80151c:	e8 1a f8 ff ff       	call   800d3b <fd2data>
  801521:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801523:	83 c4 08             	add    $0x8,%esp
  801526:	68 cb 21 80 00       	push   $0x8021cb
  80152b:	53                   	push   %ebx
  80152c:	e8 0d f2 ff ff       	call   80073e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801531:	8b 46 04             	mov    0x4(%esi),%eax
  801534:	2b 06                	sub    (%esi),%eax
  801536:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80153c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801543:	00 00 00 
	stat->st_dev = &devpipe;
  801546:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80154d:	30 80 00 
	return 0;
}
  801550:	b8 00 00 00 00       	mov    $0x0,%eax
  801555:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801558:	5b                   	pop    %ebx
  801559:	5e                   	pop    %esi
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	53                   	push   %ebx
  801560:	83 ec 0c             	sub    $0xc,%esp
  801563:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801566:	53                   	push   %ebx
  801567:	6a 00                	push   $0x0
  801569:	e8 51 f6 ff ff       	call   800bbf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80156e:	89 1c 24             	mov    %ebx,(%esp)
  801571:	e8 c5 f7 ff ff       	call   800d3b <fd2data>
  801576:	83 c4 08             	add    $0x8,%esp
  801579:	50                   	push   %eax
  80157a:	6a 00                	push   $0x0
  80157c:	e8 3e f6 ff ff       	call   800bbf <sys_page_unmap>
}
  801581:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801584:	c9                   	leave  
  801585:	c3                   	ret    

00801586 <_pipeisclosed>:
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	57                   	push   %edi
  80158a:	56                   	push   %esi
  80158b:	53                   	push   %ebx
  80158c:	83 ec 1c             	sub    $0x1c,%esp
  80158f:	89 c7                	mov    %eax,%edi
  801591:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801593:	a1 00 40 80 00       	mov    0x804000,%eax
  801598:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80159b:	83 ec 0c             	sub    $0xc,%esp
  80159e:	57                   	push   %edi
  80159f:	e8 62 05 00 00       	call   801b06 <pageref>
  8015a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015a7:	89 34 24             	mov    %esi,(%esp)
  8015aa:	e8 57 05 00 00       	call   801b06 <pageref>
		nn = thisenv->env_runs;
  8015af:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8015b5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	39 cb                	cmp    %ecx,%ebx
  8015bd:	74 1b                	je     8015da <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8015bf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015c2:	75 cf                	jne    801593 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015c4:	8b 42 58             	mov    0x58(%edx),%eax
  8015c7:	6a 01                	push   $0x1
  8015c9:	50                   	push   %eax
  8015ca:	53                   	push   %ebx
  8015cb:	68 d2 21 80 00       	push   $0x8021d2
  8015d0:	e8 8f eb ff ff       	call   800164 <cprintf>
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	eb b9                	jmp    801593 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8015da:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015dd:	0f 94 c0             	sete   %al
  8015e0:	0f b6 c0             	movzbl %al,%eax
}
  8015e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e6:	5b                   	pop    %ebx
  8015e7:	5e                   	pop    %esi
  8015e8:	5f                   	pop    %edi
  8015e9:	5d                   	pop    %ebp
  8015ea:	c3                   	ret    

008015eb <devpipe_write>:
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	57                   	push   %edi
  8015ef:	56                   	push   %esi
  8015f0:	53                   	push   %ebx
  8015f1:	83 ec 28             	sub    $0x28,%esp
  8015f4:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8015f7:	56                   	push   %esi
  8015f8:	e8 3e f7 ff ff       	call   800d3b <fd2data>
  8015fd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	bf 00 00 00 00       	mov    $0x0,%edi
  801607:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80160a:	75 09                	jne    801615 <devpipe_write+0x2a>
	return i;
  80160c:	89 f8                	mov    %edi,%eax
  80160e:	eb 23                	jmp    801633 <devpipe_write+0x48>
			sys_yield();
  801610:	e8 06 f5 ff ff       	call   800b1b <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801615:	8b 43 04             	mov    0x4(%ebx),%eax
  801618:	8b 0b                	mov    (%ebx),%ecx
  80161a:	8d 51 20             	lea    0x20(%ecx),%edx
  80161d:	39 d0                	cmp    %edx,%eax
  80161f:	72 1a                	jb     80163b <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801621:	89 da                	mov    %ebx,%edx
  801623:	89 f0                	mov    %esi,%eax
  801625:	e8 5c ff ff ff       	call   801586 <_pipeisclosed>
  80162a:	85 c0                	test   %eax,%eax
  80162c:	74 e2                	je     801610 <devpipe_write+0x25>
				return 0;
  80162e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801633:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801636:	5b                   	pop    %ebx
  801637:	5e                   	pop    %esi
  801638:	5f                   	pop    %edi
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80163b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80163e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801642:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801645:	89 c2                	mov    %eax,%edx
  801647:	c1 fa 1f             	sar    $0x1f,%edx
  80164a:	89 d1                	mov    %edx,%ecx
  80164c:	c1 e9 1b             	shr    $0x1b,%ecx
  80164f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801652:	83 e2 1f             	and    $0x1f,%edx
  801655:	29 ca                	sub    %ecx,%edx
  801657:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80165b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80165f:	83 c0 01             	add    $0x1,%eax
  801662:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801665:	83 c7 01             	add    $0x1,%edi
  801668:	eb 9d                	jmp    801607 <devpipe_write+0x1c>

0080166a <devpipe_read>:
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	57                   	push   %edi
  80166e:	56                   	push   %esi
  80166f:	53                   	push   %ebx
  801670:	83 ec 18             	sub    $0x18,%esp
  801673:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801676:	57                   	push   %edi
  801677:	e8 bf f6 ff ff       	call   800d3b <fd2data>
  80167c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	be 00 00 00 00       	mov    $0x0,%esi
  801686:	3b 75 10             	cmp    0x10(%ebp),%esi
  801689:	75 13                	jne    80169e <devpipe_read+0x34>
	return i;
  80168b:	89 f0                	mov    %esi,%eax
  80168d:	eb 02                	jmp    801691 <devpipe_read+0x27>
				return i;
  80168f:	89 f0                	mov    %esi,%eax
}
  801691:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801694:	5b                   	pop    %ebx
  801695:	5e                   	pop    %esi
  801696:	5f                   	pop    %edi
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    
			sys_yield();
  801699:	e8 7d f4 ff ff       	call   800b1b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80169e:	8b 03                	mov    (%ebx),%eax
  8016a0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016a3:	75 18                	jne    8016bd <devpipe_read+0x53>
			if (i > 0)
  8016a5:	85 f6                	test   %esi,%esi
  8016a7:	75 e6                	jne    80168f <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8016a9:	89 da                	mov    %ebx,%edx
  8016ab:	89 f8                	mov    %edi,%eax
  8016ad:	e8 d4 fe ff ff       	call   801586 <_pipeisclosed>
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	74 e3                	je     801699 <devpipe_read+0x2f>
				return 0;
  8016b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bb:	eb d4                	jmp    801691 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016bd:	99                   	cltd   
  8016be:	c1 ea 1b             	shr    $0x1b,%edx
  8016c1:	01 d0                	add    %edx,%eax
  8016c3:	83 e0 1f             	and    $0x1f,%eax
  8016c6:	29 d0                	sub    %edx,%eax
  8016c8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8016cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016d3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8016d6:	83 c6 01             	add    $0x1,%esi
  8016d9:	eb ab                	jmp    801686 <devpipe_read+0x1c>

008016db <pipe>:
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8016e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e6:	50                   	push   %eax
  8016e7:	e8 66 f6 ff ff       	call   800d52 <fd_alloc>
  8016ec:	89 c3                	mov    %eax,%ebx
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	0f 88 23 01 00 00    	js     80181c <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016f9:	83 ec 04             	sub    $0x4,%esp
  8016fc:	68 07 04 00 00       	push   $0x407
  801701:	ff 75 f4             	push   -0xc(%ebp)
  801704:	6a 00                	push   $0x0
  801706:	e8 2f f4 ff ff       	call   800b3a <sys_page_alloc>
  80170b:	89 c3                	mov    %eax,%ebx
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	85 c0                	test   %eax,%eax
  801712:	0f 88 04 01 00 00    	js     80181c <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801718:	83 ec 0c             	sub    $0xc,%esp
  80171b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	e8 2e f6 ff ff       	call   800d52 <fd_alloc>
  801724:	89 c3                	mov    %eax,%ebx
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	85 c0                	test   %eax,%eax
  80172b:	0f 88 db 00 00 00    	js     80180c <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801731:	83 ec 04             	sub    $0x4,%esp
  801734:	68 07 04 00 00       	push   $0x407
  801739:	ff 75 f0             	push   -0x10(%ebp)
  80173c:	6a 00                	push   $0x0
  80173e:	e8 f7 f3 ff ff       	call   800b3a <sys_page_alloc>
  801743:	89 c3                	mov    %eax,%ebx
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	85 c0                	test   %eax,%eax
  80174a:	0f 88 bc 00 00 00    	js     80180c <pipe+0x131>
	va = fd2data(fd0);
  801750:	83 ec 0c             	sub    $0xc,%esp
  801753:	ff 75 f4             	push   -0xc(%ebp)
  801756:	e8 e0 f5 ff ff       	call   800d3b <fd2data>
  80175b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175d:	83 c4 0c             	add    $0xc,%esp
  801760:	68 07 04 00 00       	push   $0x407
  801765:	50                   	push   %eax
  801766:	6a 00                	push   $0x0
  801768:	e8 cd f3 ff ff       	call   800b3a <sys_page_alloc>
  80176d:	89 c3                	mov    %eax,%ebx
  80176f:	83 c4 10             	add    $0x10,%esp
  801772:	85 c0                	test   %eax,%eax
  801774:	0f 88 82 00 00 00    	js     8017fc <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80177a:	83 ec 0c             	sub    $0xc,%esp
  80177d:	ff 75 f0             	push   -0x10(%ebp)
  801780:	e8 b6 f5 ff ff       	call   800d3b <fd2data>
  801785:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80178c:	50                   	push   %eax
  80178d:	6a 00                	push   $0x0
  80178f:	56                   	push   %esi
  801790:	6a 00                	push   $0x0
  801792:	e8 e6 f3 ff ff       	call   800b7d <sys_page_map>
  801797:	89 c3                	mov    %eax,%ebx
  801799:	83 c4 20             	add    $0x20,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 4e                	js     8017ee <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8017a0:	a1 20 30 80 00       	mov    0x803020,%eax
  8017a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8017aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ad:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8017b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017b7:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8017b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8017c3:	83 ec 0c             	sub    $0xc,%esp
  8017c6:	ff 75 f4             	push   -0xc(%ebp)
  8017c9:	e8 5d f5 ff ff       	call   800d2b <fd2num>
  8017ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017d3:	83 c4 04             	add    $0x4,%esp
  8017d6:	ff 75 f0             	push   -0x10(%ebp)
  8017d9:	e8 4d f5 ff ff       	call   800d2b <fd2num>
  8017de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ec:	eb 2e                	jmp    80181c <pipe+0x141>
	sys_page_unmap(0, va);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	56                   	push   %esi
  8017f2:	6a 00                	push   $0x0
  8017f4:	e8 c6 f3 ff ff       	call   800bbf <sys_page_unmap>
  8017f9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	ff 75 f0             	push   -0x10(%ebp)
  801802:	6a 00                	push   $0x0
  801804:	e8 b6 f3 ff ff       	call   800bbf <sys_page_unmap>
  801809:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	ff 75 f4             	push   -0xc(%ebp)
  801812:	6a 00                	push   $0x0
  801814:	e8 a6 f3 ff ff       	call   800bbf <sys_page_unmap>
  801819:	83 c4 10             	add    $0x10,%esp
}
  80181c:	89 d8                	mov    %ebx,%eax
  80181e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801821:	5b                   	pop    %ebx
  801822:	5e                   	pop    %esi
  801823:	5d                   	pop    %ebp
  801824:	c3                   	ret    

00801825 <pipeisclosed>:
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80182b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182e:	50                   	push   %eax
  80182f:	ff 75 08             	push   0x8(%ebp)
  801832:	e8 6b f5 ff ff       	call   800da2 <fd_lookup>
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	78 18                	js     801856 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80183e:	83 ec 0c             	sub    $0xc,%esp
  801841:	ff 75 f4             	push   -0xc(%ebp)
  801844:	e8 f2 f4 ff ff       	call   800d3b <fd2data>
  801849:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80184b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184e:	e8 33 fd ff ff       	call   801586 <_pipeisclosed>
  801853:	83 c4 10             	add    $0x10,%esp
}
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801858:	b8 00 00 00 00       	mov    $0x0,%eax
  80185d:	c3                   	ret    

0080185e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801864:	68 ea 21 80 00       	push   $0x8021ea
  801869:	ff 75 0c             	push   0xc(%ebp)
  80186c:	e8 cd ee ff ff       	call   80073e <strcpy>
	return 0;
}
  801871:	b8 00 00 00 00       	mov    $0x0,%eax
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <devcons_write>:
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	57                   	push   %edi
  80187c:	56                   	push   %esi
  80187d:	53                   	push   %ebx
  80187e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801884:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801889:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80188f:	eb 2e                	jmp    8018bf <devcons_write+0x47>
		m = n - tot;
  801891:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801894:	29 f3                	sub    %esi,%ebx
  801896:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80189b:	39 c3                	cmp    %eax,%ebx
  80189d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018a0:	83 ec 04             	sub    $0x4,%esp
  8018a3:	53                   	push   %ebx
  8018a4:	89 f0                	mov    %esi,%eax
  8018a6:	03 45 0c             	add    0xc(%ebp),%eax
  8018a9:	50                   	push   %eax
  8018aa:	57                   	push   %edi
  8018ab:	e8 24 f0 ff ff       	call   8008d4 <memmove>
		sys_cputs(buf, m);
  8018b0:	83 c4 08             	add    $0x8,%esp
  8018b3:	53                   	push   %ebx
  8018b4:	57                   	push   %edi
  8018b5:	e8 c4 f1 ff ff       	call   800a7e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8018ba:	01 de                	add    %ebx,%esi
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018c2:	72 cd                	jb     801891 <devcons_write+0x19>
}
  8018c4:	89 f0                	mov    %esi,%eax
  8018c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c9:	5b                   	pop    %ebx
  8018ca:	5e                   	pop    %esi
  8018cb:	5f                   	pop    %edi
  8018cc:	5d                   	pop    %ebp
  8018cd:	c3                   	ret    

008018ce <devcons_read>:
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	83 ec 08             	sub    $0x8,%esp
  8018d4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8018d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018dd:	75 07                	jne    8018e6 <devcons_read+0x18>
  8018df:	eb 1f                	jmp    801900 <devcons_read+0x32>
		sys_yield();
  8018e1:	e8 35 f2 ff ff       	call   800b1b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8018e6:	e8 b1 f1 ff ff       	call   800a9c <sys_cgetc>
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	74 f2                	je     8018e1 <devcons_read+0x13>
	if (c < 0)
  8018ef:	78 0f                	js     801900 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8018f1:	83 f8 04             	cmp    $0x4,%eax
  8018f4:	74 0c                	je     801902 <devcons_read+0x34>
	*(char*)vbuf = c;
  8018f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f9:	88 02                	mov    %al,(%edx)
	return 1;
  8018fb:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    
		return 0;
  801902:	b8 00 00 00 00       	mov    $0x0,%eax
  801907:	eb f7                	jmp    801900 <devcons_read+0x32>

00801909 <cputchar>:
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80190f:	8b 45 08             	mov    0x8(%ebp),%eax
  801912:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801915:	6a 01                	push   $0x1
  801917:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80191a:	50                   	push   %eax
  80191b:	e8 5e f1 ff ff       	call   800a7e <sys_cputs>
}
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <getchar>:
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80192b:	6a 01                	push   $0x1
  80192d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801930:	50                   	push   %eax
  801931:	6a 00                	push   $0x0
  801933:	e8 ce f6 ff ff       	call   801006 <read>
	if (r < 0)
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 06                	js     801945 <getchar+0x20>
	if (r < 1)
  80193f:	74 06                	je     801947 <getchar+0x22>
	return c;
  801941:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    
		return -E_EOF;
  801947:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80194c:	eb f7                	jmp    801945 <getchar+0x20>

0080194e <iscons>:
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801954:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801957:	50                   	push   %eax
  801958:	ff 75 08             	push   0x8(%ebp)
  80195b:	e8 42 f4 ff ff       	call   800da2 <fd_lookup>
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	85 c0                	test   %eax,%eax
  801965:	78 11                	js     801978 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801970:	39 10                	cmp    %edx,(%eax)
  801972:	0f 94 c0             	sete   %al
  801975:	0f b6 c0             	movzbl %al,%eax
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <opencons>:
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801980:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801983:	50                   	push   %eax
  801984:	e8 c9 f3 ff ff       	call   800d52 <fd_alloc>
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 3a                	js     8019ca <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801990:	83 ec 04             	sub    $0x4,%esp
  801993:	68 07 04 00 00       	push   $0x407
  801998:	ff 75 f4             	push   -0xc(%ebp)
  80199b:	6a 00                	push   $0x0
  80199d:	e8 98 f1 ff ff       	call   800b3a <sys_page_alloc>
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 21                	js     8019ca <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8019a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	50                   	push   %eax
  8019c2:	e8 64 f3 ff ff       	call   800d2b <fd2num>
  8019c7:	83 c4 10             	add    $0x10,%esp
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	56                   	push   %esi
  8019d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019d4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019da:	e8 1d f1 ff ff       	call   800afc <sys_getenvid>
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	ff 75 0c             	push   0xc(%ebp)
  8019e5:	ff 75 08             	push   0x8(%ebp)
  8019e8:	56                   	push   %esi
  8019e9:	50                   	push   %eax
  8019ea:	68 f8 21 80 00       	push   $0x8021f8
  8019ef:	e8 70 e7 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019f4:	83 c4 18             	add    $0x18,%esp
  8019f7:	53                   	push   %ebx
  8019f8:	ff 75 10             	push   0x10(%ebp)
  8019fb:	e8 13 e7 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  801a00:	c7 04 24 e3 21 80 00 	movl   $0x8021e3,(%esp)
  801a07:	e8 58 e7 ff ff       	call   800164 <cprintf>
  801a0c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a0f:	cc                   	int3   
  801a10:	eb fd                	jmp    801a0f <_panic+0x43>

00801a12 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	56                   	push   %esi
  801a16:	53                   	push   %ebx
  801a17:	8b 75 08             	mov    0x8(%ebp),%esi
  801a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801a20:	85 c0                	test   %eax,%eax
  801a22:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a27:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a2a:	83 ec 0c             	sub    $0xc,%esp
  801a2d:	50                   	push   %eax
  801a2e:	e8 b7 f2 ff ff       	call   800cea <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	85 f6                	test   %esi,%esi
  801a38:	74 14                	je     801a4e <ipc_recv+0x3c>
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 09                	js     801a4c <ipc_recv+0x3a>
  801a43:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a49:	8b 52 74             	mov    0x74(%edx),%edx
  801a4c:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a4e:	85 db                	test   %ebx,%ebx
  801a50:	74 14                	je     801a66 <ipc_recv+0x54>
  801a52:	ba 00 00 00 00       	mov    $0x0,%edx
  801a57:	85 c0                	test   %eax,%eax
  801a59:	78 09                	js     801a64 <ipc_recv+0x52>
  801a5b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a61:	8b 52 78             	mov    0x78(%edx),%edx
  801a64:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 08                	js     801a72 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a6a:	a1 00 40 80 00       	mov    0x804000,%eax
  801a6f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a75:	5b                   	pop    %ebx
  801a76:	5e                   	pop    %esi
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	57                   	push   %edi
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a85:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a8b:	85 db                	test   %ebx,%ebx
  801a8d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a92:	0f 44 d8             	cmove  %eax,%ebx
  801a95:	eb 05                	jmp    801a9c <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a97:	e8 7f f0 ff ff       	call   800b1b <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a9c:	ff 75 14             	push   0x14(%ebp)
  801a9f:	53                   	push   %ebx
  801aa0:	56                   	push   %esi
  801aa1:	57                   	push   %edi
  801aa2:	e8 20 f2 ff ff       	call   800cc7 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aad:	74 e8                	je     801a97 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	78 08                	js     801abb <ipc_send+0x42>
	}while (r<0);

}
  801ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5e                   	pop    %esi
  801ab8:	5f                   	pop    %edi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801abb:	50                   	push   %eax
  801abc:	68 1b 22 80 00       	push   $0x80221b
  801ac1:	6a 3d                	push   $0x3d
  801ac3:	68 2f 22 80 00       	push   $0x80222f
  801ac8:	e8 ff fe ff ff       	call   8019cc <_panic>

00801acd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801adb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae1:	8b 52 50             	mov    0x50(%edx),%edx
  801ae4:	39 ca                	cmp    %ecx,%edx
  801ae6:	74 11                	je     801af9 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ae8:	83 c0 01             	add    $0x1,%eax
  801aeb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af0:	75 e6                	jne    801ad8 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801af2:	b8 00 00 00 00       	mov    $0x0,%eax
  801af7:	eb 0b                	jmp    801b04 <ipc_find_env+0x37>
			return envs[i].env_id;
  801af9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801afc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b01:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0c:	89 c2                	mov    %eax,%edx
  801b0e:	c1 ea 16             	shr    $0x16,%edx
  801b11:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b18:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b1d:	f6 c1 01             	test   $0x1,%cl
  801b20:	74 1c                	je     801b3e <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801b22:	c1 e8 0c             	shr    $0xc,%eax
  801b25:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b2c:	a8 01                	test   $0x1,%al
  801b2e:	74 0e                	je     801b3e <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b30:	c1 e8 0c             	shr    $0xc,%eax
  801b33:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b3a:	ef 
  801b3b:	0f b7 d2             	movzwl %dx,%edx
}
  801b3e:	89 d0                	mov    %edx,%eax
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    
  801b42:	66 90                	xchg   %ax,%ax
  801b44:	66 90                	xchg   %ax,%ax
  801b46:	66 90                	xchg   %ax,%ax
  801b48:	66 90                	xchg   %ax,%ax
  801b4a:	66 90                	xchg   %ax,%ax
  801b4c:	66 90                	xchg   %ax,%ax
  801b4e:	66 90                	xchg   %ax,%ax

00801b50 <__udivdi3>:
  801b50:	f3 0f 1e fb          	endbr32 
  801b54:	55                   	push   %ebp
  801b55:	57                   	push   %edi
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	83 ec 1c             	sub    $0x1c,%esp
  801b5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b63:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	75 19                	jne    801b88 <__udivdi3+0x38>
  801b6f:	39 f3                	cmp    %esi,%ebx
  801b71:	76 4d                	jbe    801bc0 <__udivdi3+0x70>
  801b73:	31 ff                	xor    %edi,%edi
  801b75:	89 e8                	mov    %ebp,%eax
  801b77:	89 f2                	mov    %esi,%edx
  801b79:	f7 f3                	div    %ebx
  801b7b:	89 fa                	mov    %edi,%edx
  801b7d:	83 c4 1c             	add    $0x1c,%esp
  801b80:	5b                   	pop    %ebx
  801b81:	5e                   	pop    %esi
  801b82:	5f                   	pop    %edi
  801b83:	5d                   	pop    %ebp
  801b84:	c3                   	ret    
  801b85:	8d 76 00             	lea    0x0(%esi),%esi
  801b88:	39 f0                	cmp    %esi,%eax
  801b8a:	76 14                	jbe    801ba0 <__udivdi3+0x50>
  801b8c:	31 ff                	xor    %edi,%edi
  801b8e:	31 c0                	xor    %eax,%eax
  801b90:	89 fa                	mov    %edi,%edx
  801b92:	83 c4 1c             	add    $0x1c,%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    
  801b9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ba0:	0f bd f8             	bsr    %eax,%edi
  801ba3:	83 f7 1f             	xor    $0x1f,%edi
  801ba6:	75 48                	jne    801bf0 <__udivdi3+0xa0>
  801ba8:	39 f0                	cmp    %esi,%eax
  801baa:	72 06                	jb     801bb2 <__udivdi3+0x62>
  801bac:	31 c0                	xor    %eax,%eax
  801bae:	39 eb                	cmp    %ebp,%ebx
  801bb0:	77 de                	ja     801b90 <__udivdi3+0x40>
  801bb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb7:	eb d7                	jmp    801b90 <__udivdi3+0x40>
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	89 d9                	mov    %ebx,%ecx
  801bc2:	85 db                	test   %ebx,%ebx
  801bc4:	75 0b                	jne    801bd1 <__udivdi3+0x81>
  801bc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bcb:	31 d2                	xor    %edx,%edx
  801bcd:	f7 f3                	div    %ebx
  801bcf:	89 c1                	mov    %eax,%ecx
  801bd1:	31 d2                	xor    %edx,%edx
  801bd3:	89 f0                	mov    %esi,%eax
  801bd5:	f7 f1                	div    %ecx
  801bd7:	89 c6                	mov    %eax,%esi
  801bd9:	89 e8                	mov    %ebp,%eax
  801bdb:	89 f7                	mov    %esi,%edi
  801bdd:	f7 f1                	div    %ecx
  801bdf:	89 fa                	mov    %edi,%edx
  801be1:	83 c4 1c             	add    $0x1c,%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	89 f9                	mov    %edi,%ecx
  801bf2:	ba 20 00 00 00       	mov    $0x20,%edx
  801bf7:	29 fa                	sub    %edi,%edx
  801bf9:	d3 e0                	shl    %cl,%eax
  801bfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bff:	89 d1                	mov    %edx,%ecx
  801c01:	89 d8                	mov    %ebx,%eax
  801c03:	d3 e8                	shr    %cl,%eax
  801c05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c09:	09 c1                	or     %eax,%ecx
  801c0b:	89 f0                	mov    %esi,%eax
  801c0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e3                	shl    %cl,%ebx
  801c15:	89 d1                	mov    %edx,%ecx
  801c17:	d3 e8                	shr    %cl,%eax
  801c19:	89 f9                	mov    %edi,%ecx
  801c1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c1f:	89 eb                	mov    %ebp,%ebx
  801c21:	d3 e6                	shl    %cl,%esi
  801c23:	89 d1                	mov    %edx,%ecx
  801c25:	d3 eb                	shr    %cl,%ebx
  801c27:	09 f3                	or     %esi,%ebx
  801c29:	89 c6                	mov    %eax,%esi
  801c2b:	89 f2                	mov    %esi,%edx
  801c2d:	89 d8                	mov    %ebx,%eax
  801c2f:	f7 74 24 08          	divl   0x8(%esp)
  801c33:	89 d6                	mov    %edx,%esi
  801c35:	89 c3                	mov    %eax,%ebx
  801c37:	f7 64 24 0c          	mull   0xc(%esp)
  801c3b:	39 d6                	cmp    %edx,%esi
  801c3d:	72 19                	jb     801c58 <__udivdi3+0x108>
  801c3f:	89 f9                	mov    %edi,%ecx
  801c41:	d3 e5                	shl    %cl,%ebp
  801c43:	39 c5                	cmp    %eax,%ebp
  801c45:	73 04                	jae    801c4b <__udivdi3+0xfb>
  801c47:	39 d6                	cmp    %edx,%esi
  801c49:	74 0d                	je     801c58 <__udivdi3+0x108>
  801c4b:	89 d8                	mov    %ebx,%eax
  801c4d:	31 ff                	xor    %edi,%edi
  801c4f:	e9 3c ff ff ff       	jmp    801b90 <__udivdi3+0x40>
  801c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c58:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c5b:	31 ff                	xor    %edi,%edi
  801c5d:	e9 2e ff ff ff       	jmp    801b90 <__udivdi3+0x40>
  801c62:	66 90                	xchg   %ax,%ax
  801c64:	66 90                	xchg   %ax,%ax
  801c66:	66 90                	xchg   %ax,%ax
  801c68:	66 90                	xchg   %ax,%ax
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__umoddi3>:
  801c70:	f3 0f 1e fb          	endbr32 
  801c74:	55                   	push   %ebp
  801c75:	57                   	push   %edi
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	83 ec 1c             	sub    $0x1c,%esp
  801c7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c83:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801c87:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801c8b:	89 f0                	mov    %esi,%eax
  801c8d:	89 da                	mov    %ebx,%edx
  801c8f:	85 ff                	test   %edi,%edi
  801c91:	75 15                	jne    801ca8 <__umoddi3+0x38>
  801c93:	39 dd                	cmp    %ebx,%ebp
  801c95:	76 39                	jbe    801cd0 <__umoddi3+0x60>
  801c97:	f7 f5                	div    %ebp
  801c99:	89 d0                	mov    %edx,%eax
  801c9b:	31 d2                	xor    %edx,%edx
  801c9d:	83 c4 1c             	add    $0x1c,%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    
  801ca5:	8d 76 00             	lea    0x0(%esi),%esi
  801ca8:	39 df                	cmp    %ebx,%edi
  801caa:	77 f1                	ja     801c9d <__umoddi3+0x2d>
  801cac:	0f bd cf             	bsr    %edi,%ecx
  801caf:	83 f1 1f             	xor    $0x1f,%ecx
  801cb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cb6:	75 40                	jne    801cf8 <__umoddi3+0x88>
  801cb8:	39 df                	cmp    %ebx,%edi
  801cba:	72 04                	jb     801cc0 <__umoddi3+0x50>
  801cbc:	39 f5                	cmp    %esi,%ebp
  801cbe:	77 dd                	ja     801c9d <__umoddi3+0x2d>
  801cc0:	89 da                	mov    %ebx,%edx
  801cc2:	89 f0                	mov    %esi,%eax
  801cc4:	29 e8                	sub    %ebp,%eax
  801cc6:	19 fa                	sbb    %edi,%edx
  801cc8:	eb d3                	jmp    801c9d <__umoddi3+0x2d>
  801cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd0:	89 e9                	mov    %ebp,%ecx
  801cd2:	85 ed                	test   %ebp,%ebp
  801cd4:	75 0b                	jne    801ce1 <__umoddi3+0x71>
  801cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	f7 f5                	div    %ebp
  801cdf:	89 c1                	mov    %eax,%ecx
  801ce1:	89 d8                	mov    %ebx,%eax
  801ce3:	31 d2                	xor    %edx,%edx
  801ce5:	f7 f1                	div    %ecx
  801ce7:	89 f0                	mov    %esi,%eax
  801ce9:	f7 f1                	div    %ecx
  801ceb:	89 d0                	mov    %edx,%eax
  801ced:	31 d2                	xor    %edx,%edx
  801cef:	eb ac                	jmp    801c9d <__umoddi3+0x2d>
  801cf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cfc:	ba 20 00 00 00       	mov    $0x20,%edx
  801d01:	29 c2                	sub    %eax,%edx
  801d03:	89 c1                	mov    %eax,%ecx
  801d05:	89 e8                	mov    %ebp,%eax
  801d07:	d3 e7                	shl    %cl,%edi
  801d09:	89 d1                	mov    %edx,%ecx
  801d0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d0f:	d3 e8                	shr    %cl,%eax
  801d11:	89 c1                	mov    %eax,%ecx
  801d13:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d17:	09 f9                	or     %edi,%ecx
  801d19:	89 df                	mov    %ebx,%edi
  801d1b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d1f:	89 c1                	mov    %eax,%ecx
  801d21:	d3 e5                	shl    %cl,%ebp
  801d23:	89 d1                	mov    %edx,%ecx
  801d25:	d3 ef                	shr    %cl,%edi
  801d27:	89 c1                	mov    %eax,%ecx
  801d29:	89 f0                	mov    %esi,%eax
  801d2b:	d3 e3                	shl    %cl,%ebx
  801d2d:	89 d1                	mov    %edx,%ecx
  801d2f:	89 fa                	mov    %edi,%edx
  801d31:	d3 e8                	shr    %cl,%eax
  801d33:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d38:	09 d8                	or     %ebx,%eax
  801d3a:	f7 74 24 08          	divl   0x8(%esp)
  801d3e:	89 d3                	mov    %edx,%ebx
  801d40:	d3 e6                	shl    %cl,%esi
  801d42:	f7 e5                	mul    %ebp
  801d44:	89 c7                	mov    %eax,%edi
  801d46:	89 d1                	mov    %edx,%ecx
  801d48:	39 d3                	cmp    %edx,%ebx
  801d4a:	72 06                	jb     801d52 <__umoddi3+0xe2>
  801d4c:	75 0e                	jne    801d5c <__umoddi3+0xec>
  801d4e:	39 c6                	cmp    %eax,%esi
  801d50:	73 0a                	jae    801d5c <__umoddi3+0xec>
  801d52:	29 e8                	sub    %ebp,%eax
  801d54:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d58:	89 d1                	mov    %edx,%ecx
  801d5a:	89 c7                	mov    %eax,%edi
  801d5c:	89 f5                	mov    %esi,%ebp
  801d5e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d62:	29 fd                	sub    %edi,%ebp
  801d64:	19 cb                	sbb    %ecx,%ebx
  801d66:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d6b:	89 d8                	mov    %ebx,%eax
  801d6d:	d3 e0                	shl    %cl,%eax
  801d6f:	89 f1                	mov    %esi,%ecx
  801d71:	d3 ed                	shr    %cl,%ebp
  801d73:	d3 eb                	shr    %cl,%ebx
  801d75:	09 e8                	or     %ebp,%eax
  801d77:	89 da                	mov    %ebx,%edx
  801d79:	83 c4 1c             	add    $0x1c,%esp
  801d7c:	5b                   	pop    %ebx
  801d7d:	5e                   	pop    %esi
  801d7e:	5f                   	pop    %edi
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    
