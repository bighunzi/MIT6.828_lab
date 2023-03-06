
obj/user/fairness：     文件格式 elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 e6 0a 00 00       	call   800b26 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  800049:	00 c0 ee 
  80004c:	74 2d                	je     80007b <umain+0x48>
		while (1) {
			ipc_recv(&who, 0, 0);
			cprintf("%x recv from %x\n", id, who);
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  80004e:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	53                   	push   %ebx
  800058:	68 b1 10 80 00       	push   $0x8010b1
  80005d:	e8 2c 01 00 00       	call   80018e <cprintf>
  800062:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800065:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  80006a:	6a 00                	push   $0x0
  80006c:	6a 00                	push   $0x0
  80006e:	6a 00                	push   $0x0
  800070:	50                   	push   %eax
  800071:	e8 04 0d 00 00       	call   800d7a <ipc_send>
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	eb ea                	jmp    800065 <umain+0x32>
			ipc_recv(&who, 0, 0);
  80007b:	8d 75 f4             	lea    -0xc(%ebp),%esi
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	6a 00                	push   $0x0
  800083:	6a 00                	push   $0x0
  800085:	56                   	push   %esi
  800086:	e8 88 0c 00 00       	call   800d13 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008b:	83 c4 0c             	add    $0xc,%esp
  80008e:	ff 75 f4             	push   -0xc(%ebp)
  800091:	53                   	push   %ebx
  800092:	68 a0 10 80 00       	push   $0x8010a0
  800097:	e8 f2 00 00 00       	call   80018e <cprintf>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb dd                	jmp    80007e <umain+0x4b>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 75 0a 00 00       	call   800b26 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	e8 f1 09 00 00       	call   800ae5 <sys_env_destroy>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800103:	8b 13                	mov    (%ebx),%edx
  800105:	8d 42 01             	lea    0x1(%edx),%eax
  800108:	89 03                	mov    %eax,(%ebx)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800111:	3d ff 00 00 00       	cmp    $0xff,%eax
  800116:	74 09                	je     800121 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800118:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80011f:	c9                   	leave  
  800120:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800121:	83 ec 08             	sub    $0x8,%esp
  800124:	68 ff 00 00 00       	push   $0xff
  800129:	8d 43 08             	lea    0x8(%ebx),%eax
  80012c:	50                   	push   %eax
  80012d:	e8 76 09 00 00       	call   800aa8 <sys_cputs>
		b->idx = 0;
  800132:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	eb db                	jmp    800118 <putch+0x1f>

0080013d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800146:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014d:	00 00 00 
	b.cnt = 0;
  800150:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800157:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015a:	ff 75 0c             	push   0xc(%ebp)
  80015d:	ff 75 08             	push   0x8(%ebp)
  800160:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800166:	50                   	push   %eax
  800167:	68 f9 00 80 00       	push   $0x8000f9
  80016c:	e8 14 01 00 00       	call   800285 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	83 c4 08             	add    $0x8,%esp
  800174:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80017a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	e8 22 09 00 00       	call   800aa8 <sys_cputs>

	return b.cnt;
}
  800186:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800194:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800197:	50                   	push   %eax
  800198:	ff 75 08             	push   0x8(%ebp)
  80019b:	e8 9d ff ff ff       	call   80013d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	57                   	push   %edi
  8001a6:	56                   	push   %esi
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 1c             	sub    $0x1c,%esp
  8001ab:	89 c7                	mov    %eax,%edi
  8001ad:	89 d6                	mov    %edx,%esi
  8001af:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b5:	89 d1                	mov    %edx,%ecx
  8001b7:	89 c2                	mov    %eax,%edx
  8001b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001cf:	39 c2                	cmp    %eax,%edx
  8001d1:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001d4:	72 3e                	jb     800214 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	ff 75 18             	push   0x18(%ebp)
  8001dc:	83 eb 01             	sub    $0x1,%ebx
  8001df:	53                   	push   %ebx
  8001e0:	50                   	push   %eax
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	push   -0x1c(%ebp)
  8001e7:	ff 75 e0             	push   -0x20(%ebp)
  8001ea:	ff 75 dc             	push   -0x24(%ebp)
  8001ed:	ff 75 d8             	push   -0x28(%ebp)
  8001f0:	e8 5b 0c 00 00       	call   800e50 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9f ff ff ff       	call   8001a2 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 13                	jmp    80021b <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	push   0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800214:	83 eb 01             	sub    $0x1,%ebx
  800217:	85 db                	test   %ebx,%ebx
  800219:	7f ed                	jg     800208 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	83 ec 04             	sub    $0x4,%esp
  800222:	ff 75 e4             	push   -0x1c(%ebp)
  800225:	ff 75 e0             	push   -0x20(%ebp)
  800228:	ff 75 dc             	push   -0x24(%ebp)
  80022b:	ff 75 d8             	push   -0x28(%ebp)
  80022e:	e8 3d 0d 00 00       	call   800f70 <__umoddi3>
  800233:	83 c4 14             	add    $0x14,%esp
  800236:	0f be 80 d2 10 80 00 	movsbl 0x8010d2(%eax),%eax
  80023d:	50                   	push   %eax
  80023e:	ff d7                	call   *%edi
}
  800240:	83 c4 10             	add    $0x10,%esp
  800243:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800246:	5b                   	pop    %ebx
  800247:	5e                   	pop    %esi
  800248:	5f                   	pop    %edi
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800251:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800255:	8b 10                	mov    (%eax),%edx
  800257:	3b 50 04             	cmp    0x4(%eax),%edx
  80025a:	73 0a                	jae    800266 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 45 08             	mov    0x8(%ebp),%eax
  800264:	88 02                	mov    %al,(%edx)
}
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <printfmt>:
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80026e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800271:	50                   	push   %eax
  800272:	ff 75 10             	push   0x10(%ebp)
  800275:	ff 75 0c             	push   0xc(%ebp)
  800278:	ff 75 08             	push   0x8(%ebp)
  80027b:	e8 05 00 00 00       	call   800285 <vprintfmt>
}
  800280:	83 c4 10             	add    $0x10,%esp
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <vprintfmt>:
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	57                   	push   %edi
  800289:	56                   	push   %esi
  80028a:	53                   	push   %ebx
  80028b:	83 ec 3c             	sub    $0x3c,%esp
  80028e:	8b 75 08             	mov    0x8(%ebp),%esi
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800294:	8b 7d 10             	mov    0x10(%ebp),%edi
  800297:	eb 0a                	jmp    8002a3 <vprintfmt+0x1e>
			putch(ch, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	53                   	push   %ebx
  80029d:	50                   	push   %eax
  80029e:	ff d6                	call   *%esi
  8002a0:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a3:	83 c7 01             	add    $0x1,%edi
  8002a6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002aa:	83 f8 25             	cmp    $0x25,%eax
  8002ad:	74 0c                	je     8002bb <vprintfmt+0x36>
			if (ch == '\0')
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	75 e6                	jne    800299 <vprintfmt+0x14>
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    
		padc = ' ';
  8002bb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002bf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002c6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002d9:	8d 47 01             	lea    0x1(%edi),%eax
  8002dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002df:	0f b6 17             	movzbl (%edi),%edx
  8002e2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e5:	3c 55                	cmp    $0x55,%al
  8002e7:	0f 87 bb 03 00 00    	ja     8006a8 <vprintfmt+0x423>
  8002ed:	0f b6 c0             	movzbl %al,%eax
  8002f0:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002fa:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002fe:	eb d9                	jmp    8002d9 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800303:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800307:	eb d0                	jmp    8002d9 <vprintfmt+0x54>
  800309:	0f b6 d2             	movzbl %dl,%edx
  80030c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80030f:	b8 00 00 00 00       	mov    $0x0,%eax
  800314:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800317:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80031e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800321:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800324:	83 f9 09             	cmp    $0x9,%ecx
  800327:	77 55                	ja     80037e <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800329:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80032c:	eb e9                	jmp    800317 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80032e:	8b 45 14             	mov    0x14(%ebp),%eax
  800331:	8b 00                	mov    (%eax),%eax
  800333:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800336:	8b 45 14             	mov    0x14(%ebp),%eax
  800339:	8d 40 04             	lea    0x4(%eax),%eax
  80033c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800342:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800346:	79 91                	jns    8002d9 <vprintfmt+0x54>
				width = precision, precision = -1;
  800348:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80034b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800355:	eb 82                	jmp    8002d9 <vprintfmt+0x54>
  800357:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80035a:	85 d2                	test   %edx,%edx
  80035c:	b8 00 00 00 00       	mov    $0x0,%eax
  800361:	0f 49 c2             	cmovns %edx,%eax
  800364:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80036a:	e9 6a ff ff ff       	jmp    8002d9 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800372:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800379:	e9 5b ff ff ff       	jmp    8002d9 <vprintfmt+0x54>
  80037e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800381:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800384:	eb bc                	jmp    800342 <vprintfmt+0xbd>
			lflag++;
  800386:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038c:	e9 48 ff ff ff       	jmp    8002d9 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800391:	8b 45 14             	mov    0x14(%ebp),%eax
  800394:	8d 78 04             	lea    0x4(%eax),%edi
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	53                   	push   %ebx
  80039b:	ff 30                	push   (%eax)
  80039d:	ff d6                	call   *%esi
			break;
  80039f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a5:	e9 9d 02 00 00       	jmp    800647 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 78 04             	lea    0x4(%eax),%edi
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	89 d0                	mov    %edx,%eax
  8003b4:	f7 d8                	neg    %eax
  8003b6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b9:	83 f8 08             	cmp    $0x8,%eax
  8003bc:	7f 23                	jg     8003e1 <vprintfmt+0x15c>
  8003be:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  8003c5:	85 d2                	test   %edx,%edx
  8003c7:	74 18                	je     8003e1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003c9:	52                   	push   %edx
  8003ca:	68 f3 10 80 00       	push   $0x8010f3
  8003cf:	53                   	push   %ebx
  8003d0:	56                   	push   %esi
  8003d1:	e8 92 fe ff ff       	call   800268 <printfmt>
  8003d6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d9:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003dc:	e9 66 02 00 00       	jmp    800647 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003e1:	50                   	push   %eax
  8003e2:	68 ea 10 80 00       	push   $0x8010ea
  8003e7:	53                   	push   %ebx
  8003e8:	56                   	push   %esi
  8003e9:	e8 7a fe ff ff       	call   800268 <printfmt>
  8003ee:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f1:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f4:	e9 4e 02 00 00       	jmp    800647 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	83 c0 04             	add    $0x4,%eax
  8003ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800407:	85 d2                	test   %edx,%edx
  800409:	b8 e3 10 80 00       	mov    $0x8010e3,%eax
  80040e:	0f 45 c2             	cmovne %edx,%eax
  800411:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800418:	7e 06                	jle    800420 <vprintfmt+0x19b>
  80041a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80041e:	75 0d                	jne    80042d <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800420:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800423:	89 c7                	mov    %eax,%edi
  800425:	03 45 e0             	add    -0x20(%ebp),%eax
  800428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042b:	eb 55                	jmp    800482 <vprintfmt+0x1fd>
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	ff 75 d8             	push   -0x28(%ebp)
  800433:	ff 75 cc             	push   -0x34(%ebp)
  800436:	e8 0a 03 00 00       	call   800745 <strnlen>
  80043b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043e:	29 c1                	sub    %eax,%ecx
  800440:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800448:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80044f:	eb 0f                	jmp    800460 <vprintfmt+0x1db>
					putch(padc, putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	53                   	push   %ebx
  800455:	ff 75 e0             	push   -0x20(%ebp)
  800458:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045a:	83 ef 01             	sub    $0x1,%edi
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	85 ff                	test   %edi,%edi
  800462:	7f ed                	jg     800451 <vprintfmt+0x1cc>
  800464:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800467:	85 d2                	test   %edx,%edx
  800469:	b8 00 00 00 00       	mov    $0x0,%eax
  80046e:	0f 49 c2             	cmovns %edx,%eax
  800471:	29 c2                	sub    %eax,%edx
  800473:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800476:	eb a8                	jmp    800420 <vprintfmt+0x19b>
					putch(ch, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	53                   	push   %ebx
  80047c:	52                   	push   %edx
  80047d:	ff d6                	call   *%esi
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800485:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800487:	83 c7 01             	add    $0x1,%edi
  80048a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048e:	0f be d0             	movsbl %al,%edx
  800491:	85 d2                	test   %edx,%edx
  800493:	74 4b                	je     8004e0 <vprintfmt+0x25b>
  800495:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800499:	78 06                	js     8004a1 <vprintfmt+0x21c>
  80049b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80049f:	78 1e                	js     8004bf <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a5:	74 d1                	je     800478 <vprintfmt+0x1f3>
  8004a7:	0f be c0             	movsbl %al,%eax
  8004aa:	83 e8 20             	sub    $0x20,%eax
  8004ad:	83 f8 5e             	cmp    $0x5e,%eax
  8004b0:	76 c6                	jbe    800478 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	6a 3f                	push   $0x3f
  8004b8:	ff d6                	call   *%esi
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	eb c3                	jmp    800482 <vprintfmt+0x1fd>
  8004bf:	89 cf                	mov    %ecx,%edi
  8004c1:	eb 0e                	jmp    8004d1 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	53                   	push   %ebx
  8004c7:	6a 20                	push   $0x20
  8004c9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004cb:	83 ef 01             	sub    $0x1,%edi
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 ff                	test   %edi,%edi
  8004d3:	7f ee                	jg     8004c3 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004db:	e9 67 01 00 00       	jmp    800647 <vprintfmt+0x3c2>
  8004e0:	89 cf                	mov    %ecx,%edi
  8004e2:	eb ed                	jmp    8004d1 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004e4:	83 f9 01             	cmp    $0x1,%ecx
  8004e7:	7f 1b                	jg     800504 <vprintfmt+0x27f>
	else if (lflag)
  8004e9:	85 c9                	test   %ecx,%ecx
  8004eb:	74 63                	je     800550 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8b 00                	mov    (%eax),%eax
  8004f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f5:	99                   	cltd   
  8004f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 40 04             	lea    0x4(%eax),%eax
  8004ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800502:	eb 17                	jmp    80051b <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8b 50 04             	mov    0x4(%eax),%edx
  80050a:	8b 00                	mov    (%eax),%eax
  80050c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 40 08             	lea    0x8(%eax),%eax
  800518:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80051b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80051e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800521:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800526:	85 c9                	test   %ecx,%ecx
  800528:	0f 89 ff 00 00 00    	jns    80062d <vprintfmt+0x3a8>
				putch('-', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	53                   	push   %ebx
  800532:	6a 2d                	push   $0x2d
  800534:	ff d6                	call   *%esi
				num = -(long long) num;
  800536:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800539:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053c:	f7 da                	neg    %edx
  80053e:	83 d1 00             	adc    $0x0,%ecx
  800541:	f7 d9                	neg    %ecx
  800543:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800546:	bf 0a 00 00 00       	mov    $0xa,%edi
  80054b:	e9 dd 00 00 00       	jmp    80062d <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8b 00                	mov    (%eax),%eax
  800555:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800558:	99                   	cltd   
  800559:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8d 40 04             	lea    0x4(%eax),%eax
  800562:	89 45 14             	mov    %eax,0x14(%ebp)
  800565:	eb b4                	jmp    80051b <vprintfmt+0x296>
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7f 1e                	jg     80058a <vprintfmt+0x305>
	else if (lflag)
  80056c:	85 c9                	test   %ecx,%ecx
  80056e:	74 32                	je     8005a2 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8b 10                	mov    (%eax),%edx
  800575:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057a:	8d 40 04             	lea    0x4(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800580:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800585:	e9 a3 00 00 00       	jmp    80062d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8b 10                	mov    (%eax),%edx
  80058f:	8b 48 04             	mov    0x4(%eax),%ecx
  800592:	8d 40 08             	lea    0x8(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800598:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80059d:	e9 8b 00 00 00       	jmp    80062d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ac:	8d 40 04             	lea    0x4(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005b7:	eb 74                	jmp    80062d <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7f 1b                	jg     8005d9 <vprintfmt+0x354>
	else if (lflag)
  8005be:	85 c9                	test   %ecx,%ecx
  8005c0:	74 2c                	je     8005ee <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cc:	8d 40 04             	lea    0x4(%eax),%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005d2:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005d7:	eb 54                	jmp    80062d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 10                	mov    (%eax),%edx
  8005de:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e1:	8d 40 08             	lea    0x8(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005e7:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005ec:	eb 3f                	jmp    80062d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005fe:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800603:	eb 28                	jmp    80062d <vprintfmt+0x3a8>
			putch('0', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 30                	push   $0x30
  80060b:	ff d6                	call   *%esi
			putch('x', putdat);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 78                	push   $0x78
  800613:	ff d6                	call   *%esi
			num = (unsigned long long)
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80061f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800622:	8d 40 04             	lea    0x4(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800628:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	ff 75 e0             	push   -0x20(%ebp)
  800638:	57                   	push   %edi
  800639:	51                   	push   %ecx
  80063a:	52                   	push   %edx
  80063b:	89 da                	mov    %ebx,%edx
  80063d:	89 f0                	mov    %esi,%eax
  80063f:	e8 5e fb ff ff       	call   8001a2 <printnum>
			break;
  800644:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064a:	e9 54 fc ff ff       	jmp    8002a3 <vprintfmt+0x1e>
	if (lflag >= 2)
  80064f:	83 f9 01             	cmp    $0x1,%ecx
  800652:	7f 1b                	jg     80066f <vprintfmt+0x3ea>
	else if (lflag)
  800654:	85 c9                	test   %ecx,%ecx
  800656:	74 2c                	je     800684 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800668:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80066d:	eb be                	jmp    80062d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8b 48 04             	mov    0x4(%eax),%ecx
  800677:	8d 40 08             	lea    0x8(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800682:	eb a9                	jmp    80062d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800694:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800699:	eb 92                	jmp    80062d <vprintfmt+0x3a8>
			putch(ch, putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 25                	push   $0x25
  8006a1:	ff d6                	call   *%esi
			break;
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 9f                	jmp    800647 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	6a 25                	push   $0x25
  8006ae:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	89 f8                	mov    %edi,%eax
  8006b5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b9:	74 05                	je     8006c0 <vprintfmt+0x43b>
  8006bb:	83 e8 01             	sub    $0x1,%eax
  8006be:	eb f5                	jmp    8006b5 <vprintfmt+0x430>
  8006c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c3:	eb 82                	jmp    800647 <vprintfmt+0x3c2>

008006c5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 18             	sub    $0x18,%esp
  8006cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	74 26                	je     80070c <vsnprintf+0x47>
  8006e6:	85 d2                	test   %edx,%edx
  8006e8:	7e 22                	jle    80070c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ea:	ff 75 14             	push   0x14(%ebp)
  8006ed:	ff 75 10             	push   0x10(%ebp)
  8006f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f3:	50                   	push   %eax
  8006f4:	68 4b 02 80 00       	push   $0x80024b
  8006f9:	e8 87 fb ff ff       	call   800285 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800701:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800704:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800707:	83 c4 10             	add    $0x10,%esp
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    
		return -E_INVAL;
  80070c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800711:	eb f7                	jmp    80070a <vsnprintf+0x45>

00800713 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800719:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071c:	50                   	push   %eax
  80071d:	ff 75 10             	push   0x10(%ebp)
  800720:	ff 75 0c             	push   0xc(%ebp)
  800723:	ff 75 08             	push   0x8(%ebp)
  800726:	e8 9a ff ff ff       	call   8006c5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    

0080072d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800733:	b8 00 00 00 00       	mov    $0x0,%eax
  800738:	eb 03                	jmp    80073d <strlen+0x10>
		n++;
  80073a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80073d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800741:	75 f7                	jne    80073a <strlen+0xd>
	return n;
}
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
  800753:	eb 03                	jmp    800758 <strnlen+0x13>
		n++;
  800755:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800758:	39 d0                	cmp    %edx,%eax
  80075a:	74 08                	je     800764 <strnlen+0x1f>
  80075c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800760:	75 f3                	jne    800755 <strnlen+0x10>
  800762:	89 c2                	mov    %eax,%edx
	return n;
}
  800764:	89 d0                	mov    %edx,%eax
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	53                   	push   %ebx
  80076c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80077b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80077e:	83 c0 01             	add    $0x1,%eax
  800781:	84 d2                	test   %dl,%dl
  800783:	75 f2                	jne    800777 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800785:	89 c8                	mov    %ecx,%eax
  800787:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	53                   	push   %ebx
  800790:	83 ec 10             	sub    $0x10,%esp
  800793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800796:	53                   	push   %ebx
  800797:	e8 91 ff ff ff       	call   80072d <strlen>
  80079c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80079f:	ff 75 0c             	push   0xc(%ebp)
  8007a2:	01 d8                	add    %ebx,%eax
  8007a4:	50                   	push   %eax
  8007a5:	e8 be ff ff ff       	call   800768 <strcpy>
	return dst;
}
  8007aa:	89 d8                	mov    %ebx,%eax
  8007ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	56                   	push   %esi
  8007b5:	53                   	push   %ebx
  8007b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 f3                	mov    %esi,%ebx
  8007be:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c1:	89 f0                	mov    %esi,%eax
  8007c3:	eb 0f                	jmp    8007d4 <strncpy+0x23>
		*dst++ = *src;
  8007c5:	83 c0 01             	add    $0x1,%eax
  8007c8:	0f b6 0a             	movzbl (%edx),%ecx
  8007cb:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ce:	80 f9 01             	cmp    $0x1,%cl
  8007d1:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007d4:	39 d8                	cmp    %ebx,%eax
  8007d6:	75 ed                	jne    8007c5 <strncpy+0x14>
	}
	return ret;
}
  8007d8:	89 f0                	mov    %esi,%eax
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ec:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	74 21                	je     800813 <strlcpy+0x35>
  8007f2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f6:	89 f2                	mov    %esi,%edx
  8007f8:	eb 09                	jmp    800803 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fa:	83 c1 01             	add    $0x1,%ecx
  8007fd:	83 c2 01             	add    $0x1,%edx
  800800:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800803:	39 c2                	cmp    %eax,%edx
  800805:	74 09                	je     800810 <strlcpy+0x32>
  800807:	0f b6 19             	movzbl (%ecx),%ebx
  80080a:	84 db                	test   %bl,%bl
  80080c:	75 ec                	jne    8007fa <strlcpy+0x1c>
  80080e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800810:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800813:	29 f0                	sub    %esi,%eax
}
  800815:	5b                   	pop    %ebx
  800816:	5e                   	pop    %esi
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800822:	eb 06                	jmp    80082a <strcmp+0x11>
		p++, q++;
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80082a:	0f b6 01             	movzbl (%ecx),%eax
  80082d:	84 c0                	test   %al,%al
  80082f:	74 04                	je     800835 <strcmp+0x1c>
  800831:	3a 02                	cmp    (%edx),%al
  800833:	74 ef                	je     800824 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800835:	0f b6 c0             	movzbl %al,%eax
  800838:	0f b6 12             	movzbl (%edx),%edx
  80083b:	29 d0                	sub    %edx,%eax
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
  800849:	89 c3                	mov    %eax,%ebx
  80084b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084e:	eb 06                	jmp    800856 <strncmp+0x17>
		n--, p++, q++;
  800850:	83 c0 01             	add    $0x1,%eax
  800853:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800856:	39 d8                	cmp    %ebx,%eax
  800858:	74 18                	je     800872 <strncmp+0x33>
  80085a:	0f b6 08             	movzbl (%eax),%ecx
  80085d:	84 c9                	test   %cl,%cl
  80085f:	74 04                	je     800865 <strncmp+0x26>
  800861:	3a 0a                	cmp    (%edx),%cl
  800863:	74 eb                	je     800850 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 00             	movzbl (%eax),%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
}
  80086d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800870:	c9                   	leave  
  800871:	c3                   	ret    
		return 0;
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
  800877:	eb f4                	jmp    80086d <strncmp+0x2e>

00800879 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800883:	eb 03                	jmp    800888 <strchr+0xf>
  800885:	83 c0 01             	add    $0x1,%eax
  800888:	0f b6 10             	movzbl (%eax),%edx
  80088b:	84 d2                	test   %dl,%dl
  80088d:	74 06                	je     800895 <strchr+0x1c>
		if (*s == c)
  80088f:	38 ca                	cmp    %cl,%dl
  800891:	75 f2                	jne    800885 <strchr+0xc>
  800893:	eb 05                	jmp    80089a <strchr+0x21>
			return (char *) s;
	return 0;
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a9:	38 ca                	cmp    %cl,%dl
  8008ab:	74 09                	je     8008b6 <strfind+0x1a>
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	74 05                	je     8008b6 <strfind+0x1a>
	for (; *s; s++)
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	eb f0                	jmp    8008a6 <strfind+0xa>
			break;
	return (char *) s;
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	57                   	push   %edi
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
  8008be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c4:	85 c9                	test   %ecx,%ecx
  8008c6:	74 2f                	je     8008f7 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c8:	89 f8                	mov    %edi,%eax
  8008ca:	09 c8                	or     %ecx,%eax
  8008cc:	a8 03                	test   $0x3,%al
  8008ce:	75 21                	jne    8008f1 <memset+0x39>
		c &= 0xFF;
  8008d0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d4:	89 d0                	mov    %edx,%eax
  8008d6:	c1 e0 08             	shl    $0x8,%eax
  8008d9:	89 d3                	mov    %edx,%ebx
  8008db:	c1 e3 18             	shl    $0x18,%ebx
  8008de:	89 d6                	mov    %edx,%esi
  8008e0:	c1 e6 10             	shl    $0x10,%esi
  8008e3:	09 f3                	or     %esi,%ebx
  8008e5:	09 da                	or     %ebx,%edx
  8008e7:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008e9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008ec:	fc                   	cld    
  8008ed:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ef:	eb 06                	jmp    8008f7 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f4:	fc                   	cld    
  8008f5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f7:	89 f8                	mov    %edi,%eax
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	57                   	push   %edi
  800902:	56                   	push   %esi
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	8b 75 0c             	mov    0xc(%ebp),%esi
  800909:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090c:	39 c6                	cmp    %eax,%esi
  80090e:	73 32                	jae    800942 <memmove+0x44>
  800910:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800913:	39 c2                	cmp    %eax,%edx
  800915:	76 2b                	jbe    800942 <memmove+0x44>
		s += n;
		d += n;
  800917:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091a:	89 d6                	mov    %edx,%esi
  80091c:	09 fe                	or     %edi,%esi
  80091e:	09 ce                	or     %ecx,%esi
  800920:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800926:	75 0e                	jne    800936 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800928:	83 ef 04             	sub    $0x4,%edi
  80092b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80092e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800931:	fd                   	std    
  800932:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800934:	eb 09                	jmp    80093f <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800936:	83 ef 01             	sub    $0x1,%edi
  800939:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80093c:	fd                   	std    
  80093d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80093f:	fc                   	cld    
  800940:	eb 1a                	jmp    80095c <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	89 f2                	mov    %esi,%edx
  800944:	09 c2                	or     %eax,%edx
  800946:	09 ca                	or     %ecx,%edx
  800948:	f6 c2 03             	test   $0x3,%dl
  80094b:	75 0a                	jne    800957 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800950:	89 c7                	mov    %eax,%edi
  800952:	fc                   	cld    
  800953:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800955:	eb 05                	jmp    80095c <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800957:	89 c7                	mov    %eax,%edi
  800959:	fc                   	cld    
  80095a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095c:	5e                   	pop    %esi
  80095d:	5f                   	pop    %edi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800966:	ff 75 10             	push   0x10(%ebp)
  800969:	ff 75 0c             	push   0xc(%ebp)
  80096c:	ff 75 08             	push   0x8(%ebp)
  80096f:	e8 8a ff ff ff       	call   8008fe <memmove>
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	89 c6                	mov    %eax,%esi
  800983:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800986:	eb 06                	jmp    80098e <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  80098e:	39 f0                	cmp    %esi,%eax
  800990:	74 14                	je     8009a6 <memcmp+0x30>
		if (*s1 != *s2)
  800992:	0f b6 08             	movzbl (%eax),%ecx
  800995:	0f b6 1a             	movzbl (%edx),%ebx
  800998:	38 d9                	cmp    %bl,%cl
  80099a:	74 ec                	je     800988 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  80099c:	0f b6 c1             	movzbl %cl,%eax
  80099f:	0f b6 db             	movzbl %bl,%ebx
  8009a2:	29 d8                	sub    %ebx,%eax
  8009a4:	eb 05                	jmp    8009ab <memcmp+0x35>
	}

	return 0;
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ab:	5b                   	pop    %ebx
  8009ac:	5e                   	pop    %esi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b8:	89 c2                	mov    %eax,%edx
  8009ba:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009bd:	eb 03                	jmp    8009c2 <memfind+0x13>
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	39 d0                	cmp    %edx,%eax
  8009c4:	73 04                	jae    8009ca <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c6:	38 08                	cmp    %cl,(%eax)
  8009c8:	75 f5                	jne    8009bf <memfind+0x10>
			break;
	return (void *) s;
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d8:	eb 03                	jmp    8009dd <strtol+0x11>
		s++;
  8009da:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009dd:	0f b6 02             	movzbl (%edx),%eax
  8009e0:	3c 20                	cmp    $0x20,%al
  8009e2:	74 f6                	je     8009da <strtol+0xe>
  8009e4:	3c 09                	cmp    $0x9,%al
  8009e6:	74 f2                	je     8009da <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009e8:	3c 2b                	cmp    $0x2b,%al
  8009ea:	74 2a                	je     800a16 <strtol+0x4a>
	int neg = 0;
  8009ec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f1:	3c 2d                	cmp    $0x2d,%al
  8009f3:	74 2b                	je     800a20 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fb:	75 0f                	jne    800a0c <strtol+0x40>
  8009fd:	80 3a 30             	cmpb   $0x30,(%edx)
  800a00:	74 28                	je     800a2a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a02:	85 db                	test   %ebx,%ebx
  800a04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a09:	0f 44 d8             	cmove  %eax,%ebx
  800a0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a11:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a14:	eb 46                	jmp    800a5c <strtol+0x90>
		s++;
  800a16:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a19:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1e:	eb d5                	jmp    8009f5 <strtol+0x29>
		s++, neg = 1;
  800a20:	83 c2 01             	add    $0x1,%edx
  800a23:	bf 01 00 00 00       	mov    $0x1,%edi
  800a28:	eb cb                	jmp    8009f5 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a2e:	74 0e                	je     800a3e <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a30:	85 db                	test   %ebx,%ebx
  800a32:	75 d8                	jne    800a0c <strtol+0x40>
		s++, base = 8;
  800a34:	83 c2 01             	add    $0x1,%edx
  800a37:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a3c:	eb ce                	jmp    800a0c <strtol+0x40>
		s += 2, base = 16;
  800a3e:	83 c2 02             	add    $0x2,%edx
  800a41:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a46:	eb c4                	jmp    800a0c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a48:	0f be c0             	movsbl %al,%eax
  800a4b:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a4e:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a51:	7d 3a                	jge    800a8d <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a53:	83 c2 01             	add    $0x1,%edx
  800a56:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a5a:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a5c:	0f b6 02             	movzbl (%edx),%eax
  800a5f:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 09             	cmp    $0x9,%bl
  800a67:	76 df                	jbe    800a48 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a69:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	80 fb 19             	cmp    $0x19,%bl
  800a71:	77 08                	ja     800a7b <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a73:	0f be c0             	movsbl %al,%eax
  800a76:	83 e8 57             	sub    $0x57,%eax
  800a79:	eb d3                	jmp    800a4e <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a7b:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a7e:	89 f3                	mov    %esi,%ebx
  800a80:	80 fb 19             	cmp    $0x19,%bl
  800a83:	77 08                	ja     800a8d <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a85:	0f be c0             	movsbl %al,%eax
  800a88:	83 e8 37             	sub    $0x37,%eax
  800a8b:	eb c1                	jmp    800a4e <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a91:	74 05                	je     800a98 <strtol+0xcc>
		*endptr = (char *) s;
  800a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a96:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a98:	89 c8                	mov    %ecx,%eax
  800a9a:	f7 d8                	neg    %eax
  800a9c:	85 ff                	test   %edi,%edi
  800a9e:	0f 45 c8             	cmovne %eax,%ecx
}
  800aa1:	89 c8                	mov    %ecx,%eax
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	89 c6                	mov    %eax,%esi
  800abf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad6:	89 d1                	mov    %edx,%ecx
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	89 d7                	mov    %edx,%edi
  800adc:	89 d6                	mov    %edx,%esi
  800ade:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800aee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af3:	8b 55 08             	mov    0x8(%ebp),%edx
  800af6:	b8 03 00 00 00       	mov    $0x3,%eax
  800afb:	89 cb                	mov    %ecx,%ebx
  800afd:	89 cf                	mov    %ecx,%edi
  800aff:	89 ce                	mov    %ecx,%esi
  800b01:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	7f 08                	jg     800b0f <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0f:	83 ec 0c             	sub    $0xc,%esp
  800b12:	50                   	push   %eax
  800b13:	6a 03                	push   $0x3
  800b15:	68 24 13 80 00       	push   $0x801324
  800b1a:	6a 2a                	push   $0x2a
  800b1c:	68 41 13 80 00       	push   $0x801341
  800b21:	e8 e1 02 00 00       	call   800e07 <_panic>

00800b26 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	b8 02 00 00 00       	mov    $0x2,%eax
  800b36:	89 d1                	mov    %edx,%ecx
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	89 d7                	mov    %edx,%edi
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_yield>:

void
sys_yield(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b6d:	be 00 00 00 00       	mov    $0x0,%esi
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b80:	89 f7                	mov    %esi,%edi
  800b82:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7f 08                	jg     800b90 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	50                   	push   %eax
  800b94:	6a 04                	push   $0x4
  800b96:	68 24 13 80 00       	push   $0x801324
  800b9b:	6a 2a                	push   $0x2a
  800b9d:	68 41 13 80 00       	push   $0x801341
  800ba2:	e8 60 02 00 00       	call   800e07 <_panic>

00800ba7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7f 08                	jg     800bd2 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 05                	push   $0x5
  800bd8:	68 24 13 80 00       	push   $0x801324
  800bdd:	6a 2a                	push   $0x2a
  800bdf:	68 41 13 80 00       	push   $0x801341
  800be4:	e8 1e 02 00 00       	call   800e07 <_panic>

00800be9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	b8 06 00 00 00       	mov    $0x6,%eax
  800c02:	89 df                	mov    %ebx,%edi
  800c04:	89 de                	mov    %ebx,%esi
  800c06:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7f 08                	jg     800c14 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 06                	push   $0x6
  800c1a:	68 24 13 80 00       	push   $0x801324
  800c1f:	6a 2a                	push   $0x2a
  800c21:	68 41 13 80 00       	push   $0x801341
  800c26:	e8 dc 01 00 00       	call   800e07 <_panic>

00800c2b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7f 08                	jg     800c56 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 08                	push   $0x8
  800c5c:	68 24 13 80 00       	push   $0x801324
  800c61:	6a 2a                	push   $0x2a
  800c63:	68 41 13 80 00       	push   $0x801341
  800c68:	e8 9a 01 00 00       	call   800e07 <_panic>

00800c6d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	b8 09 00 00 00       	mov    $0x9,%eax
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7f 08                	jg     800c98 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 09                	push   $0x9
  800c9e:	68 24 13 80 00       	push   $0x801324
  800ca3:	6a 2a                	push   $0x2a
  800ca5:	68 41 13 80 00       	push   $0x801341
  800caa:	e8 58 01 00 00       	call   800e07 <_panic>

00800caf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc0:	be 00 00 00 00       	mov    $0x0,%esi
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccb:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce8:	89 cb                	mov    %ecx,%ebx
  800cea:	89 cf                	mov    %ecx,%edi
  800cec:	89 ce                	mov    %ecx,%esi
  800cee:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7f 08                	jg     800cfc <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 0c                	push   $0xc
  800d02:	68 24 13 80 00       	push   $0x801324
  800d07:	6a 2a                	push   $0x2a
  800d09:	68 41 13 80 00       	push   $0x801341
  800d0e:	e8 f4 00 00 00       	call   800e07 <_panic>

00800d13 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  800d21:	85 c0                	test   %eax,%eax
  800d23:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800d28:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	e8 9e ff ff ff       	call   800cd2 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	85 f6                	test   %esi,%esi
  800d39:	74 14                	je     800d4f <ipc_recv+0x3c>
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	85 c0                	test   %eax,%eax
  800d42:	78 09                	js     800d4d <ipc_recv+0x3a>
  800d44:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800d4a:	8b 52 74             	mov    0x74(%edx),%edx
  800d4d:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  800d4f:	85 db                	test   %ebx,%ebx
  800d51:	74 14                	je     800d67 <ipc_recv+0x54>
  800d53:	ba 00 00 00 00       	mov    $0x0,%edx
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	78 09                	js     800d65 <ipc_recv+0x52>
  800d5c:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800d62:	8b 52 78             	mov    0x78(%edx),%edx
  800d65:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  800d67:	85 c0                	test   %eax,%eax
  800d69:	78 08                	js     800d73 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  800d6b:	a1 04 20 80 00       	mov    0x802004,%eax
  800d70:	8b 40 70             	mov    0x70(%eax),%eax
}
  800d73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  800d8c:	85 db                	test   %ebx,%ebx
  800d8e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800d93:	0f 44 d8             	cmove  %eax,%ebx
  800d96:	eb 05                	jmp    800d9d <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  800d98:	e8 a8 fd ff ff       	call   800b45 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  800d9d:	ff 75 14             	push   0x14(%ebp)
  800da0:	53                   	push   %ebx
  800da1:	56                   	push   %esi
  800da2:	57                   	push   %edi
  800da3:	e8 07 ff ff ff       	call   800caf <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800dae:	74 e8                	je     800d98 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  800db0:	85 c0                	test   %eax,%eax
  800db2:	78 08                	js     800dbc <ipc_send+0x42>
	}while (r<0);

}
  800db4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  800dbc:	50                   	push   %eax
  800dbd:	68 4f 13 80 00       	push   $0x80134f
  800dc2:	6a 3d                	push   $0x3d
  800dc4:	68 63 13 80 00       	push   $0x801363
  800dc9:	e8 39 00 00 00       	call   800e07 <_panic>

00800dce <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dd4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800dd9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800ddc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800de2:	8b 52 50             	mov    0x50(%edx),%edx
  800de5:	39 ca                	cmp    %ecx,%edx
  800de7:	74 11                	je     800dfa <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800de9:	83 c0 01             	add    $0x1,%eax
  800dec:	3d 00 04 00 00       	cmp    $0x400,%eax
  800df1:	75 e6                	jne    800dd9 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800df3:	b8 00 00 00 00       	mov    $0x0,%eax
  800df8:	eb 0b                	jmp    800e05 <ipc_find_env+0x37>
			return envs[i].env_id;
  800dfa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800dfd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e02:	8b 40 48             	mov    0x48(%eax),%eax
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e0c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e0f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e15:	e8 0c fd ff ff       	call   800b26 <sys_getenvid>
  800e1a:	83 ec 0c             	sub    $0xc,%esp
  800e1d:	ff 75 0c             	push   0xc(%ebp)
  800e20:	ff 75 08             	push   0x8(%ebp)
  800e23:	56                   	push   %esi
  800e24:	50                   	push   %eax
  800e25:	68 70 13 80 00       	push   $0x801370
  800e2a:	e8 5f f3 ff ff       	call   80018e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e2f:	83 c4 18             	add    $0x18,%esp
  800e32:	53                   	push   %ebx
  800e33:	ff 75 10             	push   0x10(%ebp)
  800e36:	e8 02 f3 ff ff       	call   80013d <vcprintf>
	cprintf("\n");
  800e3b:	c7 04 24 af 10 80 00 	movl   $0x8010af,(%esp)
  800e42:	e8 47 f3 ff ff       	call   80018e <cprintf>
  800e47:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e4a:	cc                   	int3   
  800e4b:	eb fd                	jmp    800e4a <_panic+0x43>
  800e4d:	66 90                	xchg   %ax,%ax
  800e4f:	90                   	nop

00800e50 <__udivdi3>:
  800e50:	f3 0f 1e fb          	endbr32 
  800e54:	55                   	push   %ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	83 ec 1c             	sub    $0x1c,%esp
  800e5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800e5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e63:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	75 19                	jne    800e88 <__udivdi3+0x38>
  800e6f:	39 f3                	cmp    %esi,%ebx
  800e71:	76 4d                	jbe    800ec0 <__udivdi3+0x70>
  800e73:	31 ff                	xor    %edi,%edi
  800e75:	89 e8                	mov    %ebp,%eax
  800e77:	89 f2                	mov    %esi,%edx
  800e79:	f7 f3                	div    %ebx
  800e7b:	89 fa                	mov    %edi,%edx
  800e7d:	83 c4 1c             	add    $0x1c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
  800e85:	8d 76 00             	lea    0x0(%esi),%esi
  800e88:	39 f0                	cmp    %esi,%eax
  800e8a:	76 14                	jbe    800ea0 <__udivdi3+0x50>
  800e8c:	31 ff                	xor    %edi,%edi
  800e8e:	31 c0                	xor    %eax,%eax
  800e90:	89 fa                	mov    %edi,%edx
  800e92:	83 c4 1c             	add    $0x1c,%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    
  800e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea0:	0f bd f8             	bsr    %eax,%edi
  800ea3:	83 f7 1f             	xor    $0x1f,%edi
  800ea6:	75 48                	jne    800ef0 <__udivdi3+0xa0>
  800ea8:	39 f0                	cmp    %esi,%eax
  800eaa:	72 06                	jb     800eb2 <__udivdi3+0x62>
  800eac:	31 c0                	xor    %eax,%eax
  800eae:	39 eb                	cmp    %ebp,%ebx
  800eb0:	77 de                	ja     800e90 <__udivdi3+0x40>
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	eb d7                	jmp    800e90 <__udivdi3+0x40>
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	89 d9                	mov    %ebx,%ecx
  800ec2:	85 db                	test   %ebx,%ebx
  800ec4:	75 0b                	jne    800ed1 <__udivdi3+0x81>
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	f7 f3                	div    %ebx
  800ecf:	89 c1                	mov    %eax,%ecx
  800ed1:	31 d2                	xor    %edx,%edx
  800ed3:	89 f0                	mov    %esi,%eax
  800ed5:	f7 f1                	div    %ecx
  800ed7:	89 c6                	mov    %eax,%esi
  800ed9:	89 e8                	mov    %ebp,%eax
  800edb:	89 f7                	mov    %esi,%edi
  800edd:	f7 f1                	div    %ecx
  800edf:	89 fa                	mov    %edi,%edx
  800ee1:	83 c4 1c             	add    $0x1c,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	89 f9                	mov    %edi,%ecx
  800ef2:	ba 20 00 00 00       	mov    $0x20,%edx
  800ef7:	29 fa                	sub    %edi,%edx
  800ef9:	d3 e0                	shl    %cl,%eax
  800efb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eff:	89 d1                	mov    %edx,%ecx
  800f01:	89 d8                	mov    %ebx,%eax
  800f03:	d3 e8                	shr    %cl,%eax
  800f05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f09:	09 c1                	or     %eax,%ecx
  800f0b:	89 f0                	mov    %esi,%eax
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	d3 e3                	shl    %cl,%ebx
  800f15:	89 d1                	mov    %edx,%ecx
  800f17:	d3 e8                	shr    %cl,%eax
  800f19:	89 f9                	mov    %edi,%ecx
  800f1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f1f:	89 eb                	mov    %ebp,%ebx
  800f21:	d3 e6                	shl    %cl,%esi
  800f23:	89 d1                	mov    %edx,%ecx
  800f25:	d3 eb                	shr    %cl,%ebx
  800f27:	09 f3                	or     %esi,%ebx
  800f29:	89 c6                	mov    %eax,%esi
  800f2b:	89 f2                	mov    %esi,%edx
  800f2d:	89 d8                	mov    %ebx,%eax
  800f2f:	f7 74 24 08          	divl   0x8(%esp)
  800f33:	89 d6                	mov    %edx,%esi
  800f35:	89 c3                	mov    %eax,%ebx
  800f37:	f7 64 24 0c          	mull   0xc(%esp)
  800f3b:	39 d6                	cmp    %edx,%esi
  800f3d:	72 19                	jb     800f58 <__udivdi3+0x108>
  800f3f:	89 f9                	mov    %edi,%ecx
  800f41:	d3 e5                	shl    %cl,%ebp
  800f43:	39 c5                	cmp    %eax,%ebp
  800f45:	73 04                	jae    800f4b <__udivdi3+0xfb>
  800f47:	39 d6                	cmp    %edx,%esi
  800f49:	74 0d                	je     800f58 <__udivdi3+0x108>
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	31 ff                	xor    %edi,%edi
  800f4f:	e9 3c ff ff ff       	jmp    800e90 <__udivdi3+0x40>
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f5b:	31 ff                	xor    %edi,%edi
  800f5d:	e9 2e ff ff ff       	jmp    800e90 <__udivdi3+0x40>
  800f62:	66 90                	xchg   %ax,%ax
  800f64:	66 90                	xchg   %ax,%ax
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	66 90                	xchg   %ax,%ax
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__umoddi3>:
  800f70:	f3 0f 1e fb          	endbr32 
  800f74:	55                   	push   %ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 1c             	sub    $0x1c,%esp
  800f7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f83:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800f87:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	89 da                	mov    %ebx,%edx
  800f8f:	85 ff                	test   %edi,%edi
  800f91:	75 15                	jne    800fa8 <__umoddi3+0x38>
  800f93:	39 dd                	cmp    %ebx,%ebp
  800f95:	76 39                	jbe    800fd0 <__umoddi3+0x60>
  800f97:	f7 f5                	div    %ebp
  800f99:	89 d0                	mov    %edx,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	83 c4 1c             	add    $0x1c,%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
  800fa5:	8d 76 00             	lea    0x0(%esi),%esi
  800fa8:	39 df                	cmp    %ebx,%edi
  800faa:	77 f1                	ja     800f9d <__umoddi3+0x2d>
  800fac:	0f bd cf             	bsr    %edi,%ecx
  800faf:	83 f1 1f             	xor    $0x1f,%ecx
  800fb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fb6:	75 40                	jne    800ff8 <__umoddi3+0x88>
  800fb8:	39 df                	cmp    %ebx,%edi
  800fba:	72 04                	jb     800fc0 <__umoddi3+0x50>
  800fbc:	39 f5                	cmp    %esi,%ebp
  800fbe:	77 dd                	ja     800f9d <__umoddi3+0x2d>
  800fc0:	89 da                	mov    %ebx,%edx
  800fc2:	89 f0                	mov    %esi,%eax
  800fc4:	29 e8                	sub    %ebp,%eax
  800fc6:	19 fa                	sbb    %edi,%edx
  800fc8:	eb d3                	jmp    800f9d <__umoddi3+0x2d>
  800fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd0:	89 e9                	mov    %ebp,%ecx
  800fd2:	85 ed                	test   %ebp,%ebp
  800fd4:	75 0b                	jne    800fe1 <__umoddi3+0x71>
  800fd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	f7 f5                	div    %ebp
  800fdf:	89 c1                	mov    %eax,%ecx
  800fe1:	89 d8                	mov    %ebx,%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	f7 f1                	div    %ecx
  800fe7:	89 f0                	mov    %esi,%eax
  800fe9:	f7 f1                	div    %ecx
  800feb:	89 d0                	mov    %edx,%eax
  800fed:	31 d2                	xor    %edx,%edx
  800fef:	eb ac                	jmp    800f9d <__umoddi3+0x2d>
  800ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ffc:	ba 20 00 00 00       	mov    $0x20,%edx
  801001:	29 c2                	sub    %eax,%edx
  801003:	89 c1                	mov    %eax,%ecx
  801005:	89 e8                	mov    %ebp,%eax
  801007:	d3 e7                	shl    %cl,%edi
  801009:	89 d1                	mov    %edx,%ecx
  80100b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80100f:	d3 e8                	shr    %cl,%eax
  801011:	89 c1                	mov    %eax,%ecx
  801013:	8b 44 24 04          	mov    0x4(%esp),%eax
  801017:	09 f9                	or     %edi,%ecx
  801019:	89 df                	mov    %ebx,%edi
  80101b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80101f:	89 c1                	mov    %eax,%ecx
  801021:	d3 e5                	shl    %cl,%ebp
  801023:	89 d1                	mov    %edx,%ecx
  801025:	d3 ef                	shr    %cl,%edi
  801027:	89 c1                	mov    %eax,%ecx
  801029:	89 f0                	mov    %esi,%eax
  80102b:	d3 e3                	shl    %cl,%ebx
  80102d:	89 d1                	mov    %edx,%ecx
  80102f:	89 fa                	mov    %edi,%edx
  801031:	d3 e8                	shr    %cl,%eax
  801033:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801038:	09 d8                	or     %ebx,%eax
  80103a:	f7 74 24 08          	divl   0x8(%esp)
  80103e:	89 d3                	mov    %edx,%ebx
  801040:	d3 e6                	shl    %cl,%esi
  801042:	f7 e5                	mul    %ebp
  801044:	89 c7                	mov    %eax,%edi
  801046:	89 d1                	mov    %edx,%ecx
  801048:	39 d3                	cmp    %edx,%ebx
  80104a:	72 06                	jb     801052 <__umoddi3+0xe2>
  80104c:	75 0e                	jne    80105c <__umoddi3+0xec>
  80104e:	39 c6                	cmp    %eax,%esi
  801050:	73 0a                	jae    80105c <__umoddi3+0xec>
  801052:	29 e8                	sub    %ebp,%eax
  801054:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801058:	89 d1                	mov    %edx,%ecx
  80105a:	89 c7                	mov    %eax,%edi
  80105c:	89 f5                	mov    %esi,%ebp
  80105e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801062:	29 fd                	sub    %edi,%ebp
  801064:	19 cb                	sbb    %ecx,%ebx
  801066:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80106b:	89 d8                	mov    %ebx,%eax
  80106d:	d3 e0                	shl    %cl,%eax
  80106f:	89 f1                	mov    %esi,%ecx
  801071:	d3 ed                	shr    %cl,%ebp
  801073:	d3 eb                	shr    %cl,%ebx
  801075:	09 e8                	or     %ebp,%eax
  801077:	89 da                	mov    %ebx,%edx
  801079:	83 c4 1c             	add    $0x1c,%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    
