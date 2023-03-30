
obj/user/fairness.debug：     文件格式 elf32-i386


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
  80003b:	e8 ee 0a 00 00       	call   800b2e <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 00 40 80 00 7c 	cmpl   $0xeec0007c,0x804000
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
  800058:	68 b1 22 80 00       	push   $0x8022b1
  80005d:	e8 34 01 00 00       	call   800196 <cprintf>
  800062:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800065:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  80006a:	6a 00                	push   $0x0
  80006c:	6a 00                	push   $0x0
  80006e:	6a 00                	push   $0x0
  800070:	50                   	push   %eax
  800071:	e8 af 0d 00 00       	call   800e25 <ipc_send>
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	eb ea                	jmp    800065 <umain+0x32>
			ipc_recv(&who, 0, 0);
  80007b:	8d 75 f4             	lea    -0xc(%ebp),%esi
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	6a 00                	push   $0x0
  800083:	6a 00                	push   $0x0
  800085:	56                   	push   %esi
  800086:	e8 33 0d 00 00       	call   800dbe <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008b:	83 c4 0c             	add    $0xc,%esp
  80008e:	ff 75 f4             	push   -0xc(%ebp)
  800091:	53                   	push   %ebx
  800092:	68 a0 22 80 00       	push   $0x8022a0
  800097:	e8 fa 00 00 00       	call   800196 <cprintf>
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
  8000ac:	e8 7d 0a 00 00       	call   800b2e <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 91 0f 00 00       	call   801083 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 f1 09 00 00       	call   800aed <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	74 09                	je     800129 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800120:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800124:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800127:	c9                   	leave  
  800128:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	68 ff 00 00 00       	push   $0xff
  800131:	8d 43 08             	lea    0x8(%ebx),%eax
  800134:	50                   	push   %eax
  800135:	e8 76 09 00 00       	call   800ab0 <sys_cputs>
		b->idx = 0;
  80013a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	eb db                	jmp    800120 <putch+0x1f>

00800145 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800155:	00 00 00 
	b.cnt = 0;
  800158:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800162:	ff 75 0c             	push   0xc(%ebp)
  800165:	ff 75 08             	push   0x8(%ebp)
  800168:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016e:	50                   	push   %eax
  80016f:	68 01 01 80 00       	push   $0x800101
  800174:	e8 14 01 00 00       	call   80028d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800179:	83 c4 08             	add    $0x8,%esp
  80017c:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800182:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 22 09 00 00       	call   800ab0 <sys_cputs>

	return b.cnt;
}
  80018e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019f:	50                   	push   %eax
  8001a0:	ff 75 08             	push   0x8(%ebp)
  8001a3:	e8 9d ff ff ff       	call   800145 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	57                   	push   %edi
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 1c             	sub    $0x1c,%esp
  8001b3:	89 c7                	mov    %eax,%edi
  8001b5:	89 d6                	mov    %edx,%esi
  8001b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 d1                	mov    %edx,%ecx
  8001bf:	89 c2                	mov    %eax,%edx
  8001c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d7:	39 c2                	cmp    %eax,%edx
  8001d9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001dc:	72 3e                	jb     80021c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001de:	83 ec 0c             	sub    $0xc,%esp
  8001e1:	ff 75 18             	push   0x18(%ebp)
  8001e4:	83 eb 01             	sub    $0x1,%ebx
  8001e7:	53                   	push   %ebx
  8001e8:	50                   	push   %eax
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	ff 75 e4             	push   -0x1c(%ebp)
  8001ef:	ff 75 e0             	push   -0x20(%ebp)
  8001f2:	ff 75 dc             	push   -0x24(%ebp)
  8001f5:	ff 75 d8             	push   -0x28(%ebp)
  8001f8:	e8 53 1e 00 00       	call   802050 <__udivdi3>
  8001fd:	83 c4 18             	add    $0x18,%esp
  800200:	52                   	push   %edx
  800201:	50                   	push   %eax
  800202:	89 f2                	mov    %esi,%edx
  800204:	89 f8                	mov    %edi,%eax
  800206:	e8 9f ff ff ff       	call   8001aa <printnum>
  80020b:	83 c4 20             	add    $0x20,%esp
  80020e:	eb 13                	jmp    800223 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	56                   	push   %esi
  800214:	ff 75 18             	push   0x18(%ebp)
  800217:	ff d7                	call   *%edi
  800219:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021c:	83 eb 01             	sub    $0x1,%ebx
  80021f:	85 db                	test   %ebx,%ebx
  800221:	7f ed                	jg     800210 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	83 ec 04             	sub    $0x4,%esp
  80022a:	ff 75 e4             	push   -0x1c(%ebp)
  80022d:	ff 75 e0             	push   -0x20(%ebp)
  800230:	ff 75 dc             	push   -0x24(%ebp)
  800233:	ff 75 d8             	push   -0x28(%ebp)
  800236:	e8 35 1f 00 00       	call   802170 <__umoddi3>
  80023b:	83 c4 14             	add    $0x14,%esp
  80023e:	0f be 80 d2 22 80 00 	movsbl 0x8022d2(%eax),%eax
  800245:	50                   	push   %eax
  800246:	ff d7                	call   *%edi
}
  800248:	83 c4 10             	add    $0x10,%esp
  80024b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024e:	5b                   	pop    %ebx
  80024f:	5e                   	pop    %esi
  800250:	5f                   	pop    %edi
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800259:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025d:	8b 10                	mov    (%eax),%edx
  80025f:	3b 50 04             	cmp    0x4(%eax),%edx
  800262:	73 0a                	jae    80026e <sprintputch+0x1b>
		*b->buf++ = ch;
  800264:	8d 4a 01             	lea    0x1(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 45 08             	mov    0x8(%ebp),%eax
  80026c:	88 02                	mov    %al,(%edx)
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <printfmt>:
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800276:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800279:	50                   	push   %eax
  80027a:	ff 75 10             	push   0x10(%ebp)
  80027d:	ff 75 0c             	push   0xc(%ebp)
  800280:	ff 75 08             	push   0x8(%ebp)
  800283:	e8 05 00 00 00       	call   80028d <vprintfmt>
}
  800288:	83 c4 10             	add    $0x10,%esp
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <vprintfmt>:
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	57                   	push   %edi
  800291:	56                   	push   %esi
  800292:	53                   	push   %ebx
  800293:	83 ec 3c             	sub    $0x3c,%esp
  800296:	8b 75 08             	mov    0x8(%ebp),%esi
  800299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029f:	eb 0a                	jmp    8002ab <vprintfmt+0x1e>
			putch(ch, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	53                   	push   %ebx
  8002a5:	50                   	push   %eax
  8002a6:	ff d6                	call   *%esi
  8002a8:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ab:	83 c7 01             	add    $0x1,%edi
  8002ae:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b2:	83 f8 25             	cmp    $0x25,%eax
  8002b5:	74 0c                	je     8002c3 <vprintfmt+0x36>
			if (ch == '\0')
  8002b7:	85 c0                	test   %eax,%eax
  8002b9:	75 e6                	jne    8002a1 <vprintfmt+0x14>
}
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    
		padc = ' ';
  8002c3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8d 47 01             	lea    0x1(%edi),%eax
  8002e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e7:	0f b6 17             	movzbl (%edi),%edx
  8002ea:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ed:	3c 55                	cmp    $0x55,%al
  8002ef:	0f 87 bb 03 00 00    	ja     8006b0 <vprintfmt+0x423>
  8002f5:	0f b6 c0             	movzbl %al,%eax
  8002f8:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800302:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800306:	eb d9                	jmp    8002e1 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80030f:	eb d0                	jmp    8002e1 <vprintfmt+0x54>
  800311:	0f b6 d2             	movzbl %dl,%edx
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800317:	b8 00 00 00 00       	mov    $0x0,%eax
  80031c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80031f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800322:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800326:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800329:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032c:	83 f9 09             	cmp    $0x9,%ecx
  80032f:	77 55                	ja     800386 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800331:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800334:	eb e9                	jmp    80031f <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800336:	8b 45 14             	mov    0x14(%ebp),%eax
  800339:	8b 00                	mov    (%eax),%eax
  80033b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8d 40 04             	lea    0x4(%eax),%eax
  800344:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80034a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034e:	79 91                	jns    8002e1 <vprintfmt+0x54>
				width = precision, precision = -1;
  800350:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800353:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800356:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80035d:	eb 82                	jmp    8002e1 <vprintfmt+0x54>
  80035f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800362:	85 d2                	test   %edx,%edx
  800364:	b8 00 00 00 00       	mov    $0x0,%eax
  800369:	0f 49 c2             	cmovns %edx,%eax
  80036c:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800372:	e9 6a ff ff ff       	jmp    8002e1 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80037a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800381:	e9 5b ff ff ff       	jmp    8002e1 <vprintfmt+0x54>
  800386:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800389:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038c:	eb bc                	jmp    80034a <vprintfmt+0xbd>
			lflag++;
  80038e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800394:	e9 48 ff ff ff       	jmp    8002e1 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800399:	8b 45 14             	mov    0x14(%ebp),%eax
  80039c:	8d 78 04             	lea    0x4(%eax),%edi
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	53                   	push   %ebx
  8003a3:	ff 30                	push   (%eax)
  8003a5:	ff d6                	call   *%esi
			break;
  8003a7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003aa:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ad:	e9 9d 02 00 00       	jmp    80064f <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 78 04             	lea    0x4(%eax),%edi
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	89 d0                	mov    %edx,%eax
  8003bc:	f7 d8                	neg    %eax
  8003be:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c1:	83 f8 0f             	cmp    $0xf,%eax
  8003c4:	7f 23                	jg     8003e9 <vprintfmt+0x15c>
  8003c6:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  8003cd:	85 d2                	test   %edx,%edx
  8003cf:	74 18                	je     8003e9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003d1:	52                   	push   %edx
  8003d2:	68 d1 26 80 00       	push   $0x8026d1
  8003d7:	53                   	push   %ebx
  8003d8:	56                   	push   %esi
  8003d9:	e8 92 fe ff ff       	call   800270 <printfmt>
  8003de:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e1:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e4:	e9 66 02 00 00       	jmp    80064f <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003e9:	50                   	push   %eax
  8003ea:	68 ea 22 80 00       	push   $0x8022ea
  8003ef:	53                   	push   %ebx
  8003f0:	56                   	push   %esi
  8003f1:	e8 7a fe ff ff       	call   800270 <printfmt>
  8003f6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f9:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003fc:	e9 4e 02 00 00       	jmp    80064f <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	83 c0 04             	add    $0x4,%eax
  800407:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80040f:	85 d2                	test   %edx,%edx
  800411:	b8 e3 22 80 00       	mov    $0x8022e3,%eax
  800416:	0f 45 c2             	cmovne %edx,%eax
  800419:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80041c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800420:	7e 06                	jle    800428 <vprintfmt+0x19b>
  800422:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800426:	75 0d                	jne    800435 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800428:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80042b:	89 c7                	mov    %eax,%edi
  80042d:	03 45 e0             	add    -0x20(%ebp),%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	eb 55                	jmp    80048a <vprintfmt+0x1fd>
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	ff 75 d8             	push   -0x28(%ebp)
  80043b:	ff 75 cc             	push   -0x34(%ebp)
  80043e:	e8 0a 03 00 00       	call   80074d <strnlen>
  800443:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800446:	29 c1                	sub    %eax,%ecx
  800448:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80044b:	83 c4 10             	add    $0x10,%esp
  80044e:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800450:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	eb 0f                	jmp    800468 <vprintfmt+0x1db>
					putch(padc, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	53                   	push   %ebx
  80045d:	ff 75 e0             	push   -0x20(%ebp)
  800460:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800462:	83 ef 01             	sub    $0x1,%edi
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 ff                	test   %edi,%edi
  80046a:	7f ed                	jg     800459 <vprintfmt+0x1cc>
  80046c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80046f:	85 d2                	test   %edx,%edx
  800471:	b8 00 00 00 00       	mov    $0x0,%eax
  800476:	0f 49 c2             	cmovns %edx,%eax
  800479:	29 c2                	sub    %eax,%edx
  80047b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80047e:	eb a8                	jmp    800428 <vprintfmt+0x19b>
					putch(ch, putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	53                   	push   %ebx
  800484:	52                   	push   %edx
  800485:	ff d6                	call   *%esi
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048f:	83 c7 01             	add    $0x1,%edi
  800492:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800496:	0f be d0             	movsbl %al,%edx
  800499:	85 d2                	test   %edx,%edx
  80049b:	74 4b                	je     8004e8 <vprintfmt+0x25b>
  80049d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a1:	78 06                	js     8004a9 <vprintfmt+0x21c>
  8004a3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004a7:	78 1e                	js     8004c7 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ad:	74 d1                	je     800480 <vprintfmt+0x1f3>
  8004af:	0f be c0             	movsbl %al,%eax
  8004b2:	83 e8 20             	sub    $0x20,%eax
  8004b5:	83 f8 5e             	cmp    $0x5e,%eax
  8004b8:	76 c6                	jbe    800480 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	53                   	push   %ebx
  8004be:	6a 3f                	push   $0x3f
  8004c0:	ff d6                	call   *%esi
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	eb c3                	jmp    80048a <vprintfmt+0x1fd>
  8004c7:	89 cf                	mov    %ecx,%edi
  8004c9:	eb 0e                	jmp    8004d9 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	6a 20                	push   $0x20
  8004d1:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004d3:	83 ef 01             	sub    $0x1,%edi
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	85 ff                	test   %edi,%edi
  8004db:	7f ee                	jg     8004cb <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004dd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e3:	e9 67 01 00 00       	jmp    80064f <vprintfmt+0x3c2>
  8004e8:	89 cf                	mov    %ecx,%edi
  8004ea:	eb ed                	jmp    8004d9 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004ec:	83 f9 01             	cmp    $0x1,%ecx
  8004ef:	7f 1b                	jg     80050c <vprintfmt+0x27f>
	else if (lflag)
  8004f1:	85 c9                	test   %ecx,%ecx
  8004f3:	74 63                	je     800558 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f8:	8b 00                	mov    (%eax),%eax
  8004fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fd:	99                   	cltd   
  8004fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 40 04             	lea    0x4(%eax),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
  80050a:	eb 17                	jmp    800523 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8b 50 04             	mov    0x4(%eax),%edx
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800517:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 40 08             	lea    0x8(%eax),%eax
  800520:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800523:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800526:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800529:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80052e:	85 c9                	test   %ecx,%ecx
  800530:	0f 89 ff 00 00 00    	jns    800635 <vprintfmt+0x3a8>
				putch('-', putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	53                   	push   %ebx
  80053a:	6a 2d                	push   $0x2d
  80053c:	ff d6                	call   *%esi
				num = -(long long) num;
  80053e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800541:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800544:	f7 da                	neg    %edx
  800546:	83 d1 00             	adc    $0x0,%ecx
  800549:	f7 d9                	neg    %ecx
  80054b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800553:	e9 dd 00 00 00       	jmp    800635 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800560:	99                   	cltd   
  800561:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 40 04             	lea    0x4(%eax),%eax
  80056a:	89 45 14             	mov    %eax,0x14(%ebp)
  80056d:	eb b4                	jmp    800523 <vprintfmt+0x296>
	if (lflag >= 2)
  80056f:	83 f9 01             	cmp    $0x1,%ecx
  800572:	7f 1e                	jg     800592 <vprintfmt+0x305>
	else if (lflag)
  800574:	85 c9                	test   %ecx,%ecx
  800576:	74 32                	je     8005aa <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 10                	mov    (%eax),%edx
  80057d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800582:	8d 40 04             	lea    0x4(%eax),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800588:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80058d:	e9 a3 00 00 00       	jmp    800635 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 10                	mov    (%eax),%edx
  800597:	8b 48 04             	mov    0x4(%eax),%ecx
  80059a:	8d 40 08             	lea    0x8(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005a5:	e9 8b 00 00 00       	jmp    800635 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b4:	8d 40 04             	lea    0x4(%eax),%eax
  8005b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ba:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005bf:	eb 74                	jmp    800635 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005c1:	83 f9 01             	cmp    $0x1,%ecx
  8005c4:	7f 1b                	jg     8005e1 <vprintfmt+0x354>
	else if (lflag)
  8005c6:	85 c9                	test   %ecx,%ecx
  8005c8:	74 2c                	je     8005f6 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 10                	mov    (%eax),%edx
  8005cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d4:	8d 40 04             	lea    0x4(%eax),%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005da:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005df:	eb 54                	jmp    800635 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ef:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005f4:	eb 3f                	jmp    800635 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8b 10                	mov    (%eax),%edx
  8005fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800600:	8d 40 04             	lea    0x4(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800606:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80060b:	eb 28                	jmp    800635 <vprintfmt+0x3a8>
			putch('0', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 30                	push   $0x30
  800613:	ff d6                	call   *%esi
			putch('x', putdat);
  800615:	83 c4 08             	add    $0x8,%esp
  800618:	53                   	push   %ebx
  800619:	6a 78                	push   $0x78
  80061b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 10                	mov    (%eax),%edx
  800622:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800627:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80062a:	8d 40 04             	lea    0x4(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800630:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800635:	83 ec 0c             	sub    $0xc,%esp
  800638:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80063c:	50                   	push   %eax
  80063d:	ff 75 e0             	push   -0x20(%ebp)
  800640:	57                   	push   %edi
  800641:	51                   	push   %ecx
  800642:	52                   	push   %edx
  800643:	89 da                	mov    %ebx,%edx
  800645:	89 f0                	mov    %esi,%eax
  800647:	e8 5e fb ff ff       	call   8001aa <printnum>
			break;
  80064c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800652:	e9 54 fc ff ff       	jmp    8002ab <vprintfmt+0x1e>
	if (lflag >= 2)
  800657:	83 f9 01             	cmp    $0x1,%ecx
  80065a:	7f 1b                	jg     800677 <vprintfmt+0x3ea>
	else if (lflag)
  80065c:	85 c9                	test   %ecx,%ecx
  80065e:	74 2c                	je     80068c <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 10                	mov    (%eax),%edx
  800665:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066a:	8d 40 04             	lea    0x4(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800670:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800675:	eb be                	jmp    800635 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	8b 48 04             	mov    0x4(%eax),%ecx
  80067f:	8d 40 08             	lea    0x8(%eax),%eax
  800682:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800685:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80068a:	eb a9                	jmp    800635 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
  800696:	8d 40 04             	lea    0x4(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006a1:	eb 92                	jmp    800635 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 25                	push   $0x25
  8006a9:	ff d6                	call   *%esi
			break;
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	eb 9f                	jmp    80064f <vprintfmt+0x3c2>
			putch('%', putdat);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	6a 25                	push   $0x25
  8006b6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	89 f8                	mov    %edi,%eax
  8006bd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c1:	74 05                	je     8006c8 <vprintfmt+0x43b>
  8006c3:	83 e8 01             	sub    $0x1,%eax
  8006c6:	eb f5                	jmp    8006bd <vprintfmt+0x430>
  8006c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cb:	eb 82                	jmp    80064f <vprintfmt+0x3c2>

008006cd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 18             	sub    $0x18,%esp
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	74 26                	je     800714 <vsnprintf+0x47>
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	7e 22                	jle    800714 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f2:	ff 75 14             	push   0x14(%ebp)
  8006f5:	ff 75 10             	push   0x10(%ebp)
  8006f8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fb:	50                   	push   %eax
  8006fc:	68 53 02 80 00       	push   $0x800253
  800701:	e8 87 fb ff ff       	call   80028d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800706:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800709:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070f:	83 c4 10             	add    $0x10,%esp
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    
		return -E_INVAL;
  800714:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800719:	eb f7                	jmp    800712 <vsnprintf+0x45>

0080071b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800721:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800724:	50                   	push   %eax
  800725:	ff 75 10             	push   0x10(%ebp)
  800728:	ff 75 0c             	push   0xc(%ebp)
  80072b:	ff 75 08             	push   0x8(%ebp)
  80072e:	e8 9a ff ff ff       	call   8006cd <vsnprintf>
	va_end(ap);

	return rc;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
  800740:	eb 03                	jmp    800745 <strlen+0x10>
		n++;
  800742:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800745:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800749:	75 f7                	jne    800742 <strlen+0xd>
	return n;
}
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	eb 03                	jmp    800760 <strnlen+0x13>
		n++;
  80075d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800760:	39 d0                	cmp    %edx,%eax
  800762:	74 08                	je     80076c <strnlen+0x1f>
  800764:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800768:	75 f3                	jne    80075d <strnlen+0x10>
  80076a:	89 c2                	mov    %eax,%edx
	return n;
}
  80076c:	89 d0                	mov    %edx,%eax
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800783:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800786:	83 c0 01             	add    $0x1,%eax
  800789:	84 d2                	test   %dl,%dl
  80078b:	75 f2                	jne    80077f <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80078d:	89 c8                	mov    %ecx,%eax
  80078f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800792:	c9                   	leave  
  800793:	c3                   	ret    

00800794 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	83 ec 10             	sub    $0x10,%esp
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079e:	53                   	push   %ebx
  80079f:	e8 91 ff ff ff       	call   800735 <strlen>
  8007a4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007a7:	ff 75 0c             	push   0xc(%ebp)
  8007aa:	01 d8                	add    %ebx,%eax
  8007ac:	50                   	push   %eax
  8007ad:	e8 be ff ff ff       	call   800770 <strcpy>
	return dst;
}
  8007b2:	89 d8                	mov    %ebx,%eax
  8007b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	56                   	push   %esi
  8007bd:	53                   	push   %ebx
  8007be:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c4:	89 f3                	mov    %esi,%ebx
  8007c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	89 f0                	mov    %esi,%eax
  8007cb:	eb 0f                	jmp    8007dc <strncpy+0x23>
		*dst++ = *src;
  8007cd:	83 c0 01             	add    $0x1,%eax
  8007d0:	0f b6 0a             	movzbl (%edx),%ecx
  8007d3:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d6:	80 f9 01             	cmp    $0x1,%cl
  8007d9:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007dc:	39 d8                	cmp    %ebx,%eax
  8007de:	75 ed                	jne    8007cd <strncpy+0x14>
	}
	return ret;
}
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 21                	je     80081b <strlcpy+0x35>
  8007fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fe:	89 f2                	mov    %esi,%edx
  800800:	eb 09                	jmp    80080b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800802:	83 c1 01             	add    $0x1,%ecx
  800805:	83 c2 01             	add    $0x1,%edx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80080b:	39 c2                	cmp    %eax,%edx
  80080d:	74 09                	je     800818 <strlcpy+0x32>
  80080f:	0f b6 19             	movzbl (%ecx),%ebx
  800812:	84 db                	test   %bl,%bl
  800814:	75 ec                	jne    800802 <strlcpy+0x1c>
  800816:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800818:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081b:	29 f0                	sub    %esi,%eax
}
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082a:	eb 06                	jmp    800832 <strcmp+0x11>
		p++, q++;
  80082c:	83 c1 01             	add    $0x1,%ecx
  80082f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800832:	0f b6 01             	movzbl (%ecx),%eax
  800835:	84 c0                	test   %al,%al
  800837:	74 04                	je     80083d <strcmp+0x1c>
  800839:	3a 02                	cmp    (%edx),%al
  80083b:	74 ef                	je     80082c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	0f b6 12             	movzbl (%edx),%edx
  800843:	29 d0                	sub    %edx,%eax
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	89 c3                	mov    %eax,%ebx
  800853:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800856:	eb 06                	jmp    80085e <strncmp+0x17>
		n--, p++, q++;
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80085e:	39 d8                	cmp    %ebx,%eax
  800860:	74 18                	je     80087a <strncmp+0x33>
  800862:	0f b6 08             	movzbl (%eax),%ecx
  800865:	84 c9                	test   %cl,%cl
  800867:	74 04                	je     80086d <strncmp+0x26>
  800869:	3a 0a                	cmp    (%edx),%cl
  80086b:	74 eb                	je     800858 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 00             	movzbl (%eax),%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
}
  800875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800878:	c9                   	leave  
  800879:	c3                   	ret    
		return 0;
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
  80087f:	eb f4                	jmp    800875 <strncmp+0x2e>

00800881 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088b:	eb 03                	jmp    800890 <strchr+0xf>
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	0f b6 10             	movzbl (%eax),%edx
  800893:	84 d2                	test   %dl,%dl
  800895:	74 06                	je     80089d <strchr+0x1c>
		if (*s == c)
  800897:	38 ca                	cmp    %cl,%dl
  800899:	75 f2                	jne    80088d <strchr+0xc>
  80089b:	eb 05                	jmp    8008a2 <strchr+0x21>
			return (char *) s;
	return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b1:	38 ca                	cmp    %cl,%dl
  8008b3:	74 09                	je     8008be <strfind+0x1a>
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	74 05                	je     8008be <strfind+0x1a>
	for (; *s; s++)
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	eb f0                	jmp    8008ae <strfind+0xa>
			break;
	return (char *) s;
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	57                   	push   %edi
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
  8008c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cc:	85 c9                	test   %ecx,%ecx
  8008ce:	74 2f                	je     8008ff <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d0:	89 f8                	mov    %edi,%eax
  8008d2:	09 c8                	or     %ecx,%eax
  8008d4:	a8 03                	test   $0x3,%al
  8008d6:	75 21                	jne    8008f9 <memset+0x39>
		c &= 0xFF;
  8008d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dc:	89 d0                	mov    %edx,%eax
  8008de:	c1 e0 08             	shl    $0x8,%eax
  8008e1:	89 d3                	mov    %edx,%ebx
  8008e3:	c1 e3 18             	shl    $0x18,%ebx
  8008e6:	89 d6                	mov    %edx,%esi
  8008e8:	c1 e6 10             	shl    $0x10,%esi
  8008eb:	09 f3                	or     %esi,%ebx
  8008ed:	09 da                	or     %ebx,%edx
  8008ef:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008f4:	fc                   	cld    
  8008f5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f7:	eb 06                	jmp    8008ff <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fc:	fc                   	cld    
  8008fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ff:	89 f8                	mov    %edi,%eax
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5f                   	pop    %edi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	57                   	push   %edi
  80090a:	56                   	push   %esi
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800911:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800914:	39 c6                	cmp    %eax,%esi
  800916:	73 32                	jae    80094a <memmove+0x44>
  800918:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091b:	39 c2                	cmp    %eax,%edx
  80091d:	76 2b                	jbe    80094a <memmove+0x44>
		s += n;
		d += n;
  80091f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800922:	89 d6                	mov    %edx,%esi
  800924:	09 fe                	or     %edi,%esi
  800926:	09 ce                	or     %ecx,%esi
  800928:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092e:	75 0e                	jne    80093e <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800930:	83 ef 04             	sub    $0x4,%edi
  800933:	8d 72 fc             	lea    -0x4(%edx),%esi
  800936:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800939:	fd                   	std    
  80093a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093c:	eb 09                	jmp    800947 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80093e:	83 ef 01             	sub    $0x1,%edi
  800941:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800944:	fd                   	std    
  800945:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800947:	fc                   	cld    
  800948:	eb 1a                	jmp    800964 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094a:	89 f2                	mov    %esi,%edx
  80094c:	09 c2                	or     %eax,%edx
  80094e:	09 ca                	or     %ecx,%edx
  800950:	f6 c2 03             	test   $0x3,%dl
  800953:	75 0a                	jne    80095f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800955:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800958:	89 c7                	mov    %eax,%edi
  80095a:	fc                   	cld    
  80095b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095d:	eb 05                	jmp    800964 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80095f:	89 c7                	mov    %eax,%edi
  800961:	fc                   	cld    
  800962:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800964:	5e                   	pop    %esi
  800965:	5f                   	pop    %edi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80096e:	ff 75 10             	push   0x10(%ebp)
  800971:	ff 75 0c             	push   0xc(%ebp)
  800974:	ff 75 08             	push   0x8(%ebp)
  800977:	e8 8a ff ff ff       	call   800906 <memmove>
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	56                   	push   %esi
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
  800989:	89 c6                	mov    %eax,%esi
  80098b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098e:	eb 06                	jmp    800996 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800996:	39 f0                	cmp    %esi,%eax
  800998:	74 14                	je     8009ae <memcmp+0x30>
		if (*s1 != *s2)
  80099a:	0f b6 08             	movzbl (%eax),%ecx
  80099d:	0f b6 1a             	movzbl (%edx),%ebx
  8009a0:	38 d9                	cmp    %bl,%cl
  8009a2:	74 ec                	je     800990 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009a4:	0f b6 c1             	movzbl %cl,%eax
  8009a7:	0f b6 db             	movzbl %bl,%ebx
  8009aa:	29 d8                	sub    %ebx,%eax
  8009ac:	eb 05                	jmp    8009b3 <memcmp+0x35>
	}

	return 0;
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b3:	5b                   	pop    %ebx
  8009b4:	5e                   	pop    %esi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c0:	89 c2                	mov    %eax,%edx
  8009c2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c5:	eb 03                	jmp    8009ca <memfind+0x13>
  8009c7:	83 c0 01             	add    $0x1,%eax
  8009ca:	39 d0                	cmp    %edx,%eax
  8009cc:	73 04                	jae    8009d2 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ce:	38 08                	cmp    %cl,(%eax)
  8009d0:	75 f5                	jne    8009c7 <memfind+0x10>
			break;
	return (void *) s;
}
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 55 08             	mov    0x8(%ebp),%edx
  8009dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e0:	eb 03                	jmp    8009e5 <strtol+0x11>
		s++;
  8009e2:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009e5:	0f b6 02             	movzbl (%edx),%eax
  8009e8:	3c 20                	cmp    $0x20,%al
  8009ea:	74 f6                	je     8009e2 <strtol+0xe>
  8009ec:	3c 09                	cmp    $0x9,%al
  8009ee:	74 f2                	je     8009e2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009f0:	3c 2b                	cmp    $0x2b,%al
  8009f2:	74 2a                	je     800a1e <strtol+0x4a>
	int neg = 0;
  8009f4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f9:	3c 2d                	cmp    $0x2d,%al
  8009fb:	74 2b                	je     800a28 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a03:	75 0f                	jne    800a14 <strtol+0x40>
  800a05:	80 3a 30             	cmpb   $0x30,(%edx)
  800a08:	74 28                	je     800a32 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0a:	85 db                	test   %ebx,%ebx
  800a0c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a11:	0f 44 d8             	cmove  %eax,%ebx
  800a14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a19:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a1c:	eb 46                	jmp    800a64 <strtol+0x90>
		s++;
  800a1e:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a21:	bf 00 00 00 00       	mov    $0x0,%edi
  800a26:	eb d5                	jmp    8009fd <strtol+0x29>
		s++, neg = 1;
  800a28:	83 c2 01             	add    $0x1,%edx
  800a2b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a30:	eb cb                	jmp    8009fd <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a32:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a36:	74 0e                	je     800a46 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	75 d8                	jne    800a14 <strtol+0x40>
		s++, base = 8;
  800a3c:	83 c2 01             	add    $0x1,%edx
  800a3f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a44:	eb ce                	jmp    800a14 <strtol+0x40>
		s += 2, base = 16;
  800a46:	83 c2 02             	add    $0x2,%edx
  800a49:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4e:	eb c4                	jmp    800a14 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a50:	0f be c0             	movsbl %al,%eax
  800a53:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a56:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a59:	7d 3a                	jge    800a95 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a5b:	83 c2 01             	add    $0x1,%edx
  800a5e:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a62:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a64:	0f b6 02             	movzbl (%edx),%eax
  800a67:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 09             	cmp    $0x9,%bl
  800a6f:	76 df                	jbe    800a50 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a71:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a74:	89 f3                	mov    %esi,%ebx
  800a76:	80 fb 19             	cmp    $0x19,%bl
  800a79:	77 08                	ja     800a83 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a7b:	0f be c0             	movsbl %al,%eax
  800a7e:	83 e8 57             	sub    $0x57,%eax
  800a81:	eb d3                	jmp    800a56 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a83:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 19             	cmp    $0x19,%bl
  800a8b:	77 08                	ja     800a95 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a8d:	0f be c0             	movsbl %al,%eax
  800a90:	83 e8 37             	sub    $0x37,%eax
  800a93:	eb c1                	jmp    800a56 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a99:	74 05                	je     800aa0 <strtol+0xcc>
		*endptr = (char *) s;
  800a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800aa0:	89 c8                	mov    %ecx,%eax
  800aa2:	f7 d8                	neg    %eax
  800aa4:	85 ff                	test   %edi,%edi
  800aa6:	0f 45 c8             	cmovne %eax,%ecx
}
  800aa9:	89 c8                	mov    %ecx,%eax
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	8b 55 08             	mov    0x8(%ebp),%edx
  800abe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac1:	89 c3                	mov    %eax,%ebx
  800ac3:	89 c7                	mov    %eax,%edi
  800ac5:	89 c6                	mov    %eax,%esi
  800ac7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <sys_cgetc>:

int
sys_cgetc(void)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ade:	89 d1                	mov    %edx,%ecx
  800ae0:	89 d3                	mov    %edx,%ebx
  800ae2:	89 d7                	mov    %edx,%edi
  800ae4:	89 d6                	mov    %edx,%esi
  800ae6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800af6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afb:	8b 55 08             	mov    0x8(%ebp),%edx
  800afe:	b8 03 00 00 00       	mov    $0x3,%eax
  800b03:	89 cb                	mov    %ecx,%ebx
  800b05:	89 cf                	mov    %ecx,%edi
  800b07:	89 ce                	mov    %ecx,%esi
  800b09:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	7f 08                	jg     800b17 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b17:	83 ec 0c             	sub    $0xc,%esp
  800b1a:	50                   	push   %eax
  800b1b:	6a 03                	push   $0x3
  800b1d:	68 df 25 80 00       	push   $0x8025df
  800b22:	6a 2a                	push   $0x2a
  800b24:	68 fc 25 80 00       	push   $0x8025fc
  800b29:	e8 92 14 00 00       	call   801fc0 <_panic>

00800b2e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3e:	89 d1                	mov    %edx,%ecx
  800b40:	89 d3                	mov    %edx,%ebx
  800b42:	89 d7                	mov    %edx,%edi
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_yield>:

void
sys_yield(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b5d:	89 d1                	mov    %edx,%ecx
  800b5f:	89 d3                	mov    %edx,%ebx
  800b61:	89 d7                	mov    %edx,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b75:	be 00 00 00 00       	mov    $0x0,%esi
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b80:	b8 04 00 00 00       	mov    $0x4,%eax
  800b85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b88:	89 f7                	mov    %esi,%edi
  800b8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	7f 08                	jg     800b98 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 04                	push   $0x4
  800b9e:	68 df 25 80 00       	push   $0x8025df
  800ba3:	6a 2a                	push   $0x2a
  800ba5:	68 fc 25 80 00       	push   $0x8025fc
  800baa:	e8 11 14 00 00       	call   801fc0 <_panic>

00800baf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7f 08                	jg     800bda <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 05                	push   $0x5
  800be0:	68 df 25 80 00       	push   $0x8025df
  800be5:	6a 2a                	push   $0x2a
  800be7:	68 fc 25 80 00       	push   $0x8025fc
  800bec:	e8 cf 13 00 00       	call   801fc0 <_panic>

00800bf1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c05:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0a:	89 df                	mov    %ebx,%edi
  800c0c:	89 de                	mov    %ebx,%esi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 06                	push   $0x6
  800c22:	68 df 25 80 00       	push   $0x8025df
  800c27:	6a 2a                	push   $0x2a
  800c29:	68 fc 25 80 00       	push   $0x8025fc
  800c2e:	e8 8d 13 00 00       	call   801fc0 <_panic>

00800c33 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 08                	push   $0x8
  800c64:	68 df 25 80 00       	push   $0x8025df
  800c69:	6a 2a                	push   $0x2a
  800c6b:	68 fc 25 80 00       	push   $0x8025fc
  800c70:	e8 4b 13 00 00       	call   801fc0 <_panic>

00800c75 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 09                	push   $0x9
  800ca6:	68 df 25 80 00       	push   $0x8025df
  800cab:	6a 2a                	push   $0x2a
  800cad:	68 fc 25 80 00       	push   $0x8025fc
  800cb2:	e8 09 13 00 00       	call   801fc0 <_panic>

00800cb7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 0a                	push   $0xa
  800ce8:	68 df 25 80 00       	push   $0x8025df
  800ced:	6a 2a                	push   $0x2a
  800cef:	68 fc 25 80 00       	push   $0x8025fc
  800cf4:	e8 c7 12 00 00       	call   801fc0 <_panic>

00800cf9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d0a:	be 00 00 00 00       	mov    $0x0,%esi
  800d0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d15:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d32:	89 cb                	mov    %ecx,%ebx
  800d34:	89 cf                	mov    %ecx,%edi
  800d36:	89 ce                	mov    %ecx,%esi
  800d38:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7f 08                	jg     800d46 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	50                   	push   %eax
  800d4a:	6a 0d                	push   $0xd
  800d4c:	68 df 25 80 00       	push   $0x8025df
  800d51:	6a 2a                	push   $0x2a
  800d53:	68 fc 25 80 00       	push   $0x8025fc
  800d58:	e8 63 12 00 00       	call   801fc0 <_panic>

00800d5d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d63:	ba 00 00 00 00       	mov    $0x0,%edx
  800d68:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d6d:	89 d1                	mov    %edx,%ecx
  800d6f:	89 d3                	mov    %edx,%ebx
  800d71:	89 d7                	mov    %edx,%edi
  800d73:	89 d6                	mov    %edx,%esi
  800d75:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d92:	89 df                	mov    %ebx,%edi
  800d94:	89 de                	mov    %ebx,%esi
  800d96:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	b8 10 00 00 00       	mov    $0x10,%eax
  800db3:	89 df                	mov    %ebx,%edi
  800db5:	89 de                	mov    %ebx,%esi
  800db7:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800dd3:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  800dd6:	83 ec 0c             	sub    $0xc,%esp
  800dd9:	50                   	push   %eax
  800dda:	e8 3d ff ff ff       	call   800d1c <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  800ddf:	83 c4 10             	add    $0x10,%esp
  800de2:	85 f6                	test   %esi,%esi
  800de4:	74 14                	je     800dfa <ipc_recv+0x3c>
  800de6:	ba 00 00 00 00       	mov    $0x0,%edx
  800deb:	85 c0                	test   %eax,%eax
  800ded:	78 09                	js     800df8 <ipc_recv+0x3a>
  800def:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800df5:	8b 52 74             	mov    0x74(%edx),%edx
  800df8:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  800dfa:	85 db                	test   %ebx,%ebx
  800dfc:	74 14                	je     800e12 <ipc_recv+0x54>
  800dfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800e03:	85 c0                	test   %eax,%eax
  800e05:	78 09                	js     800e10 <ipc_recv+0x52>
  800e07:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800e0d:	8b 52 78             	mov    0x78(%edx),%edx
  800e10:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  800e12:	85 c0                	test   %eax,%eax
  800e14:	78 08                	js     800e1e <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  800e16:	a1 00 40 80 00       	mov    0x804000,%eax
  800e1b:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  800e37:	85 db                	test   %ebx,%ebx
  800e39:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800e3e:	0f 44 d8             	cmove  %eax,%ebx
  800e41:	eb 05                	jmp    800e48 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  800e43:	e8 05 fd ff ff       	call   800b4d <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  800e48:	ff 75 14             	push   0x14(%ebp)
  800e4b:	53                   	push   %ebx
  800e4c:	56                   	push   %esi
  800e4d:	57                   	push   %edi
  800e4e:	e8 a6 fe ff ff       	call   800cf9 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e59:	74 e8                	je     800e43 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	78 08                	js     800e67 <ipc_send+0x42>
	}while (r<0);

}
  800e5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  800e67:	50                   	push   %eax
  800e68:	68 0a 26 80 00       	push   $0x80260a
  800e6d:	6a 3d                	push   $0x3d
  800e6f:	68 1e 26 80 00       	push   $0x80261e
  800e74:	e8 47 11 00 00       	call   801fc0 <_panic>

00800e79 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e84:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e87:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e8d:	8b 52 50             	mov    0x50(%edx),%edx
  800e90:	39 ca                	cmp    %ecx,%edx
  800e92:	74 11                	je     800ea5 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800e94:	83 c0 01             	add    $0x1,%eax
  800e97:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e9c:	75 e6                	jne    800e84 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea3:	eb 0b                	jmp    800eb0 <ipc_find_env+0x37>
			return envs[i].env_id;
  800ea5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ea8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ead:	8b 40 48             	mov    0x48(%eax),%eax
}
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	05 00 00 00 30       	add    $0x30000000,%eax
  800ebd:	c1 e8 0c             	shr    $0xc,%eax
}
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec8:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ecd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ed2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ee1:	89 c2                	mov    %eax,%edx
  800ee3:	c1 ea 16             	shr    $0x16,%edx
  800ee6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eed:	f6 c2 01             	test   $0x1,%dl
  800ef0:	74 29                	je     800f1b <fd_alloc+0x42>
  800ef2:	89 c2                	mov    %eax,%edx
  800ef4:	c1 ea 0c             	shr    $0xc,%edx
  800ef7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efe:	f6 c2 01             	test   $0x1,%dl
  800f01:	74 18                	je     800f1b <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f03:	05 00 10 00 00       	add    $0x1000,%eax
  800f08:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f0d:	75 d2                	jne    800ee1 <fd_alloc+0x8>
  800f0f:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f14:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f19:	eb 05                	jmp    800f20 <fd_alloc+0x47>
			return 0;
  800f1b:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f20:	8b 55 08             	mov    0x8(%ebp),%edx
  800f23:	89 02                	mov    %eax,(%edx)
}
  800f25:	89 c8                	mov    %ecx,%eax
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f2f:	83 f8 1f             	cmp    $0x1f,%eax
  800f32:	77 30                	ja     800f64 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f34:	c1 e0 0c             	shl    $0xc,%eax
  800f37:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f3c:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f42:	f6 c2 01             	test   $0x1,%dl
  800f45:	74 24                	je     800f6b <fd_lookup+0x42>
  800f47:	89 c2                	mov    %eax,%edx
  800f49:	c1 ea 0c             	shr    $0xc,%edx
  800f4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f53:	f6 c2 01             	test   $0x1,%dl
  800f56:	74 1a                	je     800f72 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5b:	89 02                	mov    %eax,(%edx)
	return 0;
  800f5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    
		return -E_INVAL;
  800f64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f69:	eb f7                	jmp    800f62 <fd_lookup+0x39>
		return -E_INVAL;
  800f6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f70:	eb f0                	jmp    800f62 <fd_lookup+0x39>
  800f72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f77:	eb e9                	jmp    800f62 <fd_lookup+0x39>

00800f79 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 04             	sub    $0x4,%esp
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f83:	b8 00 00 00 00       	mov    $0x0,%eax
  800f88:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f8d:	39 13                	cmp    %edx,(%ebx)
  800f8f:	74 37                	je     800fc8 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f91:	83 c0 01             	add    $0x1,%eax
  800f94:	8b 1c 85 a4 26 80 00 	mov    0x8026a4(,%eax,4),%ebx
  800f9b:	85 db                	test   %ebx,%ebx
  800f9d:	75 ee                	jne    800f8d <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f9f:	a1 00 40 80 00       	mov    0x804000,%eax
  800fa4:	8b 40 48             	mov    0x48(%eax),%eax
  800fa7:	83 ec 04             	sub    $0x4,%esp
  800faa:	52                   	push   %edx
  800fab:	50                   	push   %eax
  800fac:	68 28 26 80 00       	push   $0x802628
  800fb1:	e8 e0 f1 ff ff       	call   800196 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800fbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc1:	89 1a                	mov    %ebx,(%edx)
}
  800fc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    
			return 0;
  800fc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcd:	eb ef                	jmp    800fbe <dev_lookup+0x45>

00800fcf <fd_close>:
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
  800fd5:	83 ec 24             	sub    $0x24,%esp
  800fd8:	8b 75 08             	mov    0x8(%ebp),%esi
  800fdb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fde:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe1:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fe2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fe8:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800feb:	50                   	push   %eax
  800fec:	e8 38 ff ff ff       	call   800f29 <fd_lookup>
  800ff1:	89 c3                	mov    %eax,%ebx
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	78 05                	js     800fff <fd_close+0x30>
	    || fd != fd2)
  800ffa:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ffd:	74 16                	je     801015 <fd_close+0x46>
		return (must_exist ? r : 0);
  800fff:	89 f8                	mov    %edi,%eax
  801001:	84 c0                	test   %al,%al
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
  801008:	0f 44 d8             	cmove  %eax,%ebx
}
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801015:	83 ec 08             	sub    $0x8,%esp
  801018:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80101b:	50                   	push   %eax
  80101c:	ff 36                	push   (%esi)
  80101e:	e8 56 ff ff ff       	call   800f79 <dev_lookup>
  801023:	89 c3                	mov    %eax,%ebx
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 1a                	js     801046 <fd_close+0x77>
		if (dev->dev_close)
  80102c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80102f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801032:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801037:	85 c0                	test   %eax,%eax
  801039:	74 0b                	je     801046 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	56                   	push   %esi
  80103f:	ff d0                	call   *%eax
  801041:	89 c3                	mov    %eax,%ebx
  801043:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801046:	83 ec 08             	sub    $0x8,%esp
  801049:	56                   	push   %esi
  80104a:	6a 00                	push   $0x0
  80104c:	e8 a0 fb ff ff       	call   800bf1 <sys_page_unmap>
	return r;
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	eb b5                	jmp    80100b <fd_close+0x3c>

00801056 <close>:

int
close(int fdnum)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105f:	50                   	push   %eax
  801060:	ff 75 08             	push   0x8(%ebp)
  801063:	e8 c1 fe ff ff       	call   800f29 <fd_lookup>
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	79 02                	jns    801071 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80106f:	c9                   	leave  
  801070:	c3                   	ret    
		return fd_close(fd, 1);
  801071:	83 ec 08             	sub    $0x8,%esp
  801074:	6a 01                	push   $0x1
  801076:	ff 75 f4             	push   -0xc(%ebp)
  801079:	e8 51 ff ff ff       	call   800fcf <fd_close>
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	eb ec                	jmp    80106f <close+0x19>

00801083 <close_all>:

void
close_all(void)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	53                   	push   %ebx
  801087:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80108a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	53                   	push   %ebx
  801093:	e8 be ff ff ff       	call   801056 <close>
	for (i = 0; i < MAXFD; i++)
  801098:	83 c3 01             	add    $0x1,%ebx
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	83 fb 20             	cmp    $0x20,%ebx
  8010a1:	75 ec                	jne    80108f <close_all+0xc>
}
  8010a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a6:	c9                   	leave  
  8010a7:	c3                   	ret    

008010a8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	57                   	push   %edi
  8010ac:	56                   	push   %esi
  8010ad:	53                   	push   %ebx
  8010ae:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010b4:	50                   	push   %eax
  8010b5:	ff 75 08             	push   0x8(%ebp)
  8010b8:	e8 6c fe ff ff       	call   800f29 <fd_lookup>
  8010bd:	89 c3                	mov    %eax,%ebx
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	78 7f                	js     801145 <dup+0x9d>
		return r;
	close(newfdnum);
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	ff 75 0c             	push   0xc(%ebp)
  8010cc:	e8 85 ff ff ff       	call   801056 <close>

	newfd = INDEX2FD(newfdnum);
  8010d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d4:	c1 e6 0c             	shl    $0xc,%esi
  8010d7:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010e0:	89 3c 24             	mov    %edi,(%esp)
  8010e3:	e8 da fd ff ff       	call   800ec2 <fd2data>
  8010e8:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010ea:	89 34 24             	mov    %esi,(%esp)
  8010ed:	e8 d0 fd ff ff       	call   800ec2 <fd2data>
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010f8:	89 d8                	mov    %ebx,%eax
  8010fa:	c1 e8 16             	shr    $0x16,%eax
  8010fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801104:	a8 01                	test   $0x1,%al
  801106:	74 11                	je     801119 <dup+0x71>
  801108:	89 d8                	mov    %ebx,%eax
  80110a:	c1 e8 0c             	shr    $0xc,%eax
  80110d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801114:	f6 c2 01             	test   $0x1,%dl
  801117:	75 36                	jne    80114f <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801119:	89 f8                	mov    %edi,%eax
  80111b:	c1 e8 0c             	shr    $0xc,%eax
  80111e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	25 07 0e 00 00       	and    $0xe07,%eax
  80112d:	50                   	push   %eax
  80112e:	56                   	push   %esi
  80112f:	6a 00                	push   $0x0
  801131:	57                   	push   %edi
  801132:	6a 00                	push   $0x0
  801134:	e8 76 fa ff ff       	call   800baf <sys_page_map>
  801139:	89 c3                	mov    %eax,%ebx
  80113b:	83 c4 20             	add    $0x20,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 33                	js     801175 <dup+0xcd>
		goto err;

	return newfdnum;
  801142:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801145:	89 d8                	mov    %ebx,%eax
  801147:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114a:	5b                   	pop    %ebx
  80114b:	5e                   	pop    %esi
  80114c:	5f                   	pop    %edi
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80114f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	25 07 0e 00 00       	and    $0xe07,%eax
  80115e:	50                   	push   %eax
  80115f:	ff 75 d4             	push   -0x2c(%ebp)
  801162:	6a 00                	push   $0x0
  801164:	53                   	push   %ebx
  801165:	6a 00                	push   $0x0
  801167:	e8 43 fa ff ff       	call   800baf <sys_page_map>
  80116c:	89 c3                	mov    %eax,%ebx
  80116e:	83 c4 20             	add    $0x20,%esp
  801171:	85 c0                	test   %eax,%eax
  801173:	79 a4                	jns    801119 <dup+0x71>
	sys_page_unmap(0, newfd);
  801175:	83 ec 08             	sub    $0x8,%esp
  801178:	56                   	push   %esi
  801179:	6a 00                	push   $0x0
  80117b:	e8 71 fa ff ff       	call   800bf1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801180:	83 c4 08             	add    $0x8,%esp
  801183:	ff 75 d4             	push   -0x2c(%ebp)
  801186:	6a 00                	push   $0x0
  801188:	e8 64 fa ff ff       	call   800bf1 <sys_page_unmap>
	return r;
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	eb b3                	jmp    801145 <dup+0x9d>

00801192 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 18             	sub    $0x18,%esp
  80119a:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a0:	50                   	push   %eax
  8011a1:	56                   	push   %esi
  8011a2:	e8 82 fd ff ff       	call   800f29 <fd_lookup>
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 3c                	js     8011ea <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ae:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	ff 33                	push   (%ebx)
  8011ba:	e8 ba fd ff ff       	call   800f79 <dev_lookup>
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 24                	js     8011ea <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011c6:	8b 43 08             	mov    0x8(%ebx),%eax
  8011c9:	83 e0 03             	and    $0x3,%eax
  8011cc:	83 f8 01             	cmp    $0x1,%eax
  8011cf:	74 20                	je     8011f1 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d4:	8b 40 08             	mov    0x8(%eax),%eax
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	74 37                	je     801212 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011db:	83 ec 04             	sub    $0x4,%esp
  8011de:	ff 75 10             	push   0x10(%ebp)
  8011e1:	ff 75 0c             	push   0xc(%ebp)
  8011e4:	53                   	push   %ebx
  8011e5:	ff d0                	call   *%eax
  8011e7:	83 c4 10             	add    $0x10,%esp
}
  8011ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f1:	a1 00 40 80 00       	mov    0x804000,%eax
  8011f6:	8b 40 48             	mov    0x48(%eax),%eax
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	56                   	push   %esi
  8011fd:	50                   	push   %eax
  8011fe:	68 69 26 80 00       	push   $0x802669
  801203:	e8 8e ef ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801210:	eb d8                	jmp    8011ea <read+0x58>
		return -E_NOT_SUPP;
  801212:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801217:	eb d1                	jmp    8011ea <read+0x58>

00801219 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	8b 7d 08             	mov    0x8(%ebp),%edi
  801225:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122d:	eb 02                	jmp    801231 <readn+0x18>
  80122f:	01 c3                	add    %eax,%ebx
  801231:	39 f3                	cmp    %esi,%ebx
  801233:	73 21                	jae    801256 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	89 f0                	mov    %esi,%eax
  80123a:	29 d8                	sub    %ebx,%eax
  80123c:	50                   	push   %eax
  80123d:	89 d8                	mov    %ebx,%eax
  80123f:	03 45 0c             	add    0xc(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	57                   	push   %edi
  801244:	e8 49 ff ff ff       	call   801192 <read>
		if (m < 0)
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 04                	js     801254 <readn+0x3b>
			return m;
		if (m == 0)
  801250:	75 dd                	jne    80122f <readn+0x16>
  801252:	eb 02                	jmp    801256 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801254:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801256:	89 d8                	mov    %ebx,%eax
  801258:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125b:	5b                   	pop    %ebx
  80125c:	5e                   	pop    %esi
  80125d:	5f                   	pop    %edi
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 18             	sub    $0x18,%esp
  801268:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	53                   	push   %ebx
  801270:	e8 b4 fc ff ff       	call   800f29 <fd_lookup>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 37                	js     8012b3 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	ff 36                	push   (%esi)
  801288:	e8 ec fc ff ff       	call   800f79 <dev_lookup>
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 1f                	js     8012b3 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801294:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801298:	74 20                	je     8012ba <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80129a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129d:	8b 40 0c             	mov    0xc(%eax),%eax
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	74 37                	je     8012db <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012a4:	83 ec 04             	sub    $0x4,%esp
  8012a7:	ff 75 10             	push   0x10(%ebp)
  8012aa:	ff 75 0c             	push   0xc(%ebp)
  8012ad:	56                   	push   %esi
  8012ae:	ff d0                	call   *%eax
  8012b0:	83 c4 10             	add    $0x10,%esp
}
  8012b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ba:	a1 00 40 80 00       	mov    0x804000,%eax
  8012bf:	8b 40 48             	mov    0x48(%eax),%eax
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	53                   	push   %ebx
  8012c6:	50                   	push   %eax
  8012c7:	68 85 26 80 00       	push   $0x802685
  8012cc:	e8 c5 ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d9:	eb d8                	jmp    8012b3 <write+0x53>
		return -E_NOT_SUPP;
  8012db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e0:	eb d1                	jmp    8012b3 <write+0x53>

008012e2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	ff 75 08             	push   0x8(%ebp)
  8012ef:	e8 35 fc ff ff       	call   800f29 <fd_lookup>
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 0e                	js     801309 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801301:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801304:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	56                   	push   %esi
  80130f:	53                   	push   %ebx
  801310:	83 ec 18             	sub    $0x18,%esp
  801313:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801316:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801319:	50                   	push   %eax
  80131a:	53                   	push   %ebx
  80131b:	e8 09 fc ff ff       	call   800f29 <fd_lookup>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 34                	js     80135b <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801327:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	ff 36                	push   (%esi)
  801333:	e8 41 fc ff ff       	call   800f79 <dev_lookup>
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 1c                	js     80135b <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80133f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801343:	74 1d                	je     801362 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801345:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801348:	8b 40 18             	mov    0x18(%eax),%eax
  80134b:	85 c0                	test   %eax,%eax
  80134d:	74 34                	je     801383 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	ff 75 0c             	push   0xc(%ebp)
  801355:	56                   	push   %esi
  801356:	ff d0                	call   *%eax
  801358:	83 c4 10             	add    $0x10,%esp
}
  80135b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    
			thisenv->env_id, fdnum);
  801362:	a1 00 40 80 00       	mov    0x804000,%eax
  801367:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80136a:	83 ec 04             	sub    $0x4,%esp
  80136d:	53                   	push   %ebx
  80136e:	50                   	push   %eax
  80136f:	68 48 26 80 00       	push   $0x802648
  801374:	e8 1d ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801381:	eb d8                	jmp    80135b <ftruncate+0x50>
		return -E_NOT_SUPP;
  801383:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801388:	eb d1                	jmp    80135b <ftruncate+0x50>

0080138a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
  80138f:	83 ec 18             	sub    $0x18,%esp
  801392:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801395:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 75 08             	push   0x8(%ebp)
  80139c:	e8 88 fb ff ff       	call   800f29 <fd_lookup>
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 49                	js     8013f1 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a8:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	ff 36                	push   (%esi)
  8013b4:	e8 c0 fb ff ff       	call   800f79 <dev_lookup>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 31                	js     8013f1 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013c7:	74 2f                	je     8013f8 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013cc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013d3:	00 00 00 
	stat->st_isdir = 0;
  8013d6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013dd:	00 00 00 
	stat->st_dev = dev;
  8013e0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	53                   	push   %ebx
  8013ea:	56                   	push   %esi
  8013eb:	ff 50 14             	call   *0x14(%eax)
  8013ee:	83 c4 10             	add    $0x10,%esp
}
  8013f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5e                   	pop    %esi
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    
		return -E_NOT_SUPP;
  8013f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013fd:	eb f2                	jmp    8013f1 <fstat+0x67>

008013ff <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	6a 00                	push   $0x0
  801409:	ff 75 08             	push   0x8(%ebp)
  80140c:	e8 e4 01 00 00       	call   8015f5 <open>
  801411:	89 c3                	mov    %eax,%ebx
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 1b                	js     801435 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	ff 75 0c             	push   0xc(%ebp)
  801420:	50                   	push   %eax
  801421:	e8 64 ff ff ff       	call   80138a <fstat>
  801426:	89 c6                	mov    %eax,%esi
	close(fd);
  801428:	89 1c 24             	mov    %ebx,(%esp)
  80142b:	e8 26 fc ff ff       	call   801056 <close>
	return r;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	89 f3                	mov    %esi,%ebx
}
  801435:	89 d8                	mov    %ebx,%eax
  801437:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143a:	5b                   	pop    %ebx
  80143b:	5e                   	pop    %esi
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	56                   	push   %esi
  801442:	53                   	push   %ebx
  801443:	89 c6                	mov    %eax,%esi
  801445:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801447:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80144e:	74 27                	je     801477 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801450:	6a 07                	push   $0x7
  801452:	68 00 50 80 00       	push   $0x805000
  801457:	56                   	push   %esi
  801458:	ff 35 00 60 80 00    	push   0x806000
  80145e:	e8 c2 f9 ff ff       	call   800e25 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801463:	83 c4 0c             	add    $0xc,%esp
  801466:	6a 00                	push   $0x0
  801468:	53                   	push   %ebx
  801469:	6a 00                	push   $0x0
  80146b:	e8 4e f9 ff ff       	call   800dbe <ipc_recv>
}
  801470:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801473:	5b                   	pop    %ebx
  801474:	5e                   	pop    %esi
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801477:	83 ec 0c             	sub    $0xc,%esp
  80147a:	6a 01                	push   $0x1
  80147c:	e8 f8 f9 ff ff       	call   800e79 <ipc_find_env>
  801481:	a3 00 60 80 00       	mov    %eax,0x806000
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	eb c5                	jmp    801450 <fsipc+0x12>

0080148b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
  801494:	8b 40 0c             	mov    0xc(%eax),%eax
  801497:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80149c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014ae:	e8 8b ff ff ff       	call   80143e <fsipc>
}
  8014b3:	c9                   	leave  
  8014b4:	c3                   	ret    

008014b5 <devfile_flush>:
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014be:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8014d0:	e8 69 ff ff ff       	call   80143e <fsipc>
}
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <devfile_stat>:
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	53                   	push   %ebx
  8014db:	83 ec 04             	sub    $0x4,%esp
  8014de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f6:	e8 43 ff ff ff       	call   80143e <fsipc>
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 2c                	js     80152b <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	68 00 50 80 00       	push   $0x805000
  801507:	53                   	push   %ebx
  801508:	e8 63 f2 ff ff       	call   800770 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80150d:	a1 80 50 80 00       	mov    0x805080,%eax
  801512:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801518:	a1 84 50 80 00       	mov    0x805084,%eax
  80151d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <devfile_write>:
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 0c             	sub    $0xc,%esp
  801536:	8b 45 10             	mov    0x10(%ebp),%eax
  801539:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80153e:	39 d0                	cmp    %edx,%eax
  801540:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801543:	8b 55 08             	mov    0x8(%ebp),%edx
  801546:	8b 52 0c             	mov    0xc(%edx),%edx
  801549:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80154f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801554:	50                   	push   %eax
  801555:	ff 75 0c             	push   0xc(%ebp)
  801558:	68 08 50 80 00       	push   $0x805008
  80155d:	e8 a4 f3 ff ff       	call   800906 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801562:	ba 00 00 00 00       	mov    $0x0,%edx
  801567:	b8 04 00 00 00       	mov    $0x4,%eax
  80156c:	e8 cd fe ff ff       	call   80143e <fsipc>
}
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <devfile_read>:
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	56                   	push   %esi
  801577:	53                   	push   %ebx
  801578:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80157b:	8b 45 08             	mov    0x8(%ebp),%eax
  80157e:	8b 40 0c             	mov    0xc(%eax),%eax
  801581:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801586:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80158c:	ba 00 00 00 00       	mov    $0x0,%edx
  801591:	b8 03 00 00 00       	mov    $0x3,%eax
  801596:	e8 a3 fe ff ff       	call   80143e <fsipc>
  80159b:	89 c3                	mov    %eax,%ebx
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 1f                	js     8015c0 <devfile_read+0x4d>
	assert(r <= n);
  8015a1:	39 f0                	cmp    %esi,%eax
  8015a3:	77 24                	ja     8015c9 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8015a5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015aa:	7f 33                	jg     8015df <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	50                   	push   %eax
  8015b0:	68 00 50 80 00       	push   $0x805000
  8015b5:	ff 75 0c             	push   0xc(%ebp)
  8015b8:	e8 49 f3 ff ff       	call   800906 <memmove>
	return r;
  8015bd:	83 c4 10             	add    $0x10,%esp
}
  8015c0:	89 d8                	mov    %ebx,%eax
  8015c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5e                   	pop    %esi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    
	assert(r <= n);
  8015c9:	68 b8 26 80 00       	push   $0x8026b8
  8015ce:	68 bf 26 80 00       	push   $0x8026bf
  8015d3:	6a 7c                	push   $0x7c
  8015d5:	68 d4 26 80 00       	push   $0x8026d4
  8015da:	e8 e1 09 00 00       	call   801fc0 <_panic>
	assert(r <= PGSIZE);
  8015df:	68 df 26 80 00       	push   $0x8026df
  8015e4:	68 bf 26 80 00       	push   $0x8026bf
  8015e9:	6a 7d                	push   $0x7d
  8015eb:	68 d4 26 80 00       	push   $0x8026d4
  8015f0:	e8 cb 09 00 00       	call   801fc0 <_panic>

008015f5 <open>:
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 1c             	sub    $0x1c,%esp
  8015fd:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801600:	56                   	push   %esi
  801601:	e8 2f f1 ff ff       	call   800735 <strlen>
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80160e:	7f 6c                	jg     80167c <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801616:	50                   	push   %eax
  801617:	e8 bd f8 ff ff       	call   800ed9 <fd_alloc>
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 3c                	js     801661 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	56                   	push   %esi
  801629:	68 00 50 80 00       	push   $0x805000
  80162e:	e8 3d f1 ff ff       	call   800770 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801633:	8b 45 0c             	mov    0xc(%ebp),%eax
  801636:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80163b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163e:	b8 01 00 00 00       	mov    $0x1,%eax
  801643:	e8 f6 fd ff ff       	call   80143e <fsipc>
  801648:	89 c3                	mov    %eax,%ebx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 19                	js     80166a <open+0x75>
	return fd2num(fd);
  801651:	83 ec 0c             	sub    $0xc,%esp
  801654:	ff 75 f4             	push   -0xc(%ebp)
  801657:	e8 56 f8 ff ff       	call   800eb2 <fd2num>
  80165c:	89 c3                	mov    %eax,%ebx
  80165e:	83 c4 10             	add    $0x10,%esp
}
  801661:	89 d8                	mov    %ebx,%eax
  801663:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801666:	5b                   	pop    %ebx
  801667:	5e                   	pop    %esi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    
		fd_close(fd, 0);
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	6a 00                	push   $0x0
  80166f:	ff 75 f4             	push   -0xc(%ebp)
  801672:	e8 58 f9 ff ff       	call   800fcf <fd_close>
		return r;
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	eb e5                	jmp    801661 <open+0x6c>
		return -E_BAD_PATH;
  80167c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801681:	eb de                	jmp    801661 <open+0x6c>

00801683 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801689:	ba 00 00 00 00       	mov    $0x0,%edx
  80168e:	b8 08 00 00 00       	mov    $0x8,%eax
  801693:	e8 a6 fd ff ff       	call   80143e <fsipc>
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016a0:	68 eb 26 80 00       	push   $0x8026eb
  8016a5:	ff 75 0c             	push   0xc(%ebp)
  8016a8:	e8 c3 f0 ff ff       	call   800770 <strcpy>
	return 0;
}
  8016ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <devsock_close>:
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 10             	sub    $0x10,%esp
  8016bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016be:	53                   	push   %ebx
  8016bf:	e8 42 09 00 00       	call   802006 <pageref>
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	83 c4 10             	add    $0x10,%esp
		return 0;
  8016c9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8016ce:	83 fa 01             	cmp    $0x1,%edx
  8016d1:	74 05                	je     8016d8 <devsock_close+0x24>
}
  8016d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8016d8:	83 ec 0c             	sub    $0xc,%esp
  8016db:	ff 73 0c             	push   0xc(%ebx)
  8016de:	e8 b7 02 00 00       	call   80199a <nsipc_close>
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	eb eb                	jmp    8016d3 <devsock_close+0x1f>

008016e8 <devsock_write>:
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016ee:	6a 00                	push   $0x0
  8016f0:	ff 75 10             	push   0x10(%ebp)
  8016f3:	ff 75 0c             	push   0xc(%ebp)
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	ff 70 0c             	push   0xc(%eax)
  8016fc:	e8 79 03 00 00       	call   801a7a <nsipc_send>
}
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <devsock_read>:
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801709:	6a 00                	push   $0x0
  80170b:	ff 75 10             	push   0x10(%ebp)
  80170e:	ff 75 0c             	push   0xc(%ebp)
  801711:	8b 45 08             	mov    0x8(%ebp),%eax
  801714:	ff 70 0c             	push   0xc(%eax)
  801717:	e8 ef 02 00 00       	call   801a0b <nsipc_recv>
}
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <fd2sockid>:
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801724:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801727:	52                   	push   %edx
  801728:	50                   	push   %eax
  801729:	e8 fb f7 ff ff       	call   800f29 <fd_lookup>
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	85 c0                	test   %eax,%eax
  801733:	78 10                	js     801745 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801738:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80173e:	39 08                	cmp    %ecx,(%eax)
  801740:	75 05                	jne    801747 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801742:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801745:	c9                   	leave  
  801746:	c3                   	ret    
		return -E_NOT_SUPP;
  801747:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80174c:	eb f7                	jmp    801745 <fd2sockid+0x27>

0080174e <alloc_sockfd>:
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
  801753:	83 ec 1c             	sub    $0x1c,%esp
  801756:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801758:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175b:	50                   	push   %eax
  80175c:	e8 78 f7 ff ff       	call   800ed9 <fd_alloc>
  801761:	89 c3                	mov    %eax,%ebx
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	85 c0                	test   %eax,%eax
  801768:	78 43                	js     8017ad <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	68 07 04 00 00       	push   $0x407
  801772:	ff 75 f4             	push   -0xc(%ebp)
  801775:	6a 00                	push   $0x0
  801777:	e8 f0 f3 ff ff       	call   800b6c <sys_page_alloc>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	78 28                	js     8017ad <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801788:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80178e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801793:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80179a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	50                   	push   %eax
  8017a1:	e8 0c f7 ff ff       	call   800eb2 <fd2num>
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	eb 0c                	jmp    8017b9 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8017ad:	83 ec 0c             	sub    $0xc,%esp
  8017b0:	56                   	push   %esi
  8017b1:	e8 e4 01 00 00       	call   80199a <nsipc_close>
		return r;
  8017b6:	83 c4 10             	add    $0x10,%esp
}
  8017b9:	89 d8                	mov    %ebx,%eax
  8017bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <accept>:
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	e8 4e ff ff ff       	call   80171e <fd2sockid>
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 1b                	js     8017ef <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	ff 75 10             	push   0x10(%ebp)
  8017da:	ff 75 0c             	push   0xc(%ebp)
  8017dd:	50                   	push   %eax
  8017de:	e8 0e 01 00 00       	call   8018f1 <nsipc_accept>
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 05                	js     8017ef <accept+0x2d>
	return alloc_sockfd(r);
  8017ea:	e8 5f ff ff ff       	call   80174e <alloc_sockfd>
}
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <bind>:
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	e8 1f ff ff ff       	call   80171e <fd2sockid>
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 12                	js     801815 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801803:	83 ec 04             	sub    $0x4,%esp
  801806:	ff 75 10             	push   0x10(%ebp)
  801809:	ff 75 0c             	push   0xc(%ebp)
  80180c:	50                   	push   %eax
  80180d:	e8 31 01 00 00       	call   801943 <nsipc_bind>
  801812:	83 c4 10             	add    $0x10,%esp
}
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <shutdown>:
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	e8 f9 fe ff ff       	call   80171e <fd2sockid>
  801825:	85 c0                	test   %eax,%eax
  801827:	78 0f                	js     801838 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	ff 75 0c             	push   0xc(%ebp)
  80182f:	50                   	push   %eax
  801830:	e8 43 01 00 00       	call   801978 <nsipc_shutdown>
  801835:	83 c4 10             	add    $0x10,%esp
}
  801838:	c9                   	leave  
  801839:	c3                   	ret    

0080183a <connect>:
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	e8 d6 fe ff ff       	call   80171e <fd2sockid>
  801848:	85 c0                	test   %eax,%eax
  80184a:	78 12                	js     80185e <connect+0x24>
	return nsipc_connect(r, name, namelen);
  80184c:	83 ec 04             	sub    $0x4,%esp
  80184f:	ff 75 10             	push   0x10(%ebp)
  801852:	ff 75 0c             	push   0xc(%ebp)
  801855:	50                   	push   %eax
  801856:	e8 59 01 00 00       	call   8019b4 <nsipc_connect>
  80185b:	83 c4 10             	add    $0x10,%esp
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <listen>:
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	e8 b0 fe ff ff       	call   80171e <fd2sockid>
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 0f                	js     801881 <listen+0x21>
	return nsipc_listen(r, backlog);
  801872:	83 ec 08             	sub    $0x8,%esp
  801875:	ff 75 0c             	push   0xc(%ebp)
  801878:	50                   	push   %eax
  801879:	e8 6b 01 00 00       	call   8019e9 <nsipc_listen>
  80187e:	83 c4 10             	add    $0x10,%esp
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <socket>:

int
socket(int domain, int type, int protocol)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801889:	ff 75 10             	push   0x10(%ebp)
  80188c:	ff 75 0c             	push   0xc(%ebp)
  80188f:	ff 75 08             	push   0x8(%ebp)
  801892:	e8 41 02 00 00       	call   801ad8 <nsipc_socket>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 05                	js     8018a3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80189e:	e8 ab fe ff ff       	call   80174e <alloc_sockfd>
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 04             	sub    $0x4,%esp
  8018ac:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018ae:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8018b5:	74 26                	je     8018dd <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018b7:	6a 07                	push   $0x7
  8018b9:	68 00 70 80 00       	push   $0x807000
  8018be:	53                   	push   %ebx
  8018bf:	ff 35 00 80 80 00    	push   0x808000
  8018c5:	e8 5b f5 ff ff       	call   800e25 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018ca:	83 c4 0c             	add    $0xc,%esp
  8018cd:	6a 00                	push   $0x0
  8018cf:	6a 00                	push   $0x0
  8018d1:	6a 00                	push   $0x0
  8018d3:	e8 e6 f4 ff ff       	call   800dbe <ipc_recv>
}
  8018d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	6a 02                	push   $0x2
  8018e2:	e8 92 f5 ff ff       	call   800e79 <ipc_find_env>
  8018e7:	a3 00 80 80 00       	mov    %eax,0x808000
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	eb c6                	jmp    8018b7 <nsipc+0x12>

008018f1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	56                   	push   %esi
  8018f5:	53                   	push   %ebx
  8018f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801901:	8b 06                	mov    (%esi),%eax
  801903:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801908:	b8 01 00 00 00       	mov    $0x1,%eax
  80190d:	e8 93 ff ff ff       	call   8018a5 <nsipc>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	85 c0                	test   %eax,%eax
  801916:	79 09                	jns    801921 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801918:	89 d8                	mov    %ebx,%eax
  80191a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5e                   	pop    %esi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801921:	83 ec 04             	sub    $0x4,%esp
  801924:	ff 35 10 70 80 00    	push   0x807010
  80192a:	68 00 70 80 00       	push   $0x807000
  80192f:	ff 75 0c             	push   0xc(%ebp)
  801932:	e8 cf ef ff ff       	call   800906 <memmove>
		*addrlen = ret->ret_addrlen;
  801937:	a1 10 70 80 00       	mov    0x807010,%eax
  80193c:	89 06                	mov    %eax,(%esi)
  80193e:	83 c4 10             	add    $0x10,%esp
	return r;
  801941:	eb d5                	jmp    801918 <nsipc_accept+0x27>

00801943 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	53                   	push   %ebx
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
  801950:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801955:	53                   	push   %ebx
  801956:	ff 75 0c             	push   0xc(%ebp)
  801959:	68 04 70 80 00       	push   $0x807004
  80195e:	e8 a3 ef ff ff       	call   800906 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801963:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801969:	b8 02 00 00 00       	mov    $0x2,%eax
  80196e:	e8 32 ff ff ff       	call   8018a5 <nsipc>
}
  801973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801986:	8b 45 0c             	mov    0xc(%ebp),%eax
  801989:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80198e:	b8 03 00 00 00       	mov    $0x3,%eax
  801993:	e8 0d ff ff ff       	call   8018a5 <nsipc>
}
  801998:	c9                   	leave  
  801999:	c3                   	ret    

0080199a <nsipc_close>:

int
nsipc_close(int s)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8019a8:	b8 04 00 00 00       	mov    $0x4,%eax
  8019ad:	e8 f3 fe ff ff       	call   8018a5 <nsipc>
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	53                   	push   %ebx
  8019b8:	83 ec 08             	sub    $0x8,%esp
  8019bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019be:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c1:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019c6:	53                   	push   %ebx
  8019c7:	ff 75 0c             	push   0xc(%ebp)
  8019ca:	68 04 70 80 00       	push   $0x807004
  8019cf:	e8 32 ef ff ff       	call   800906 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019d4:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8019da:	b8 05 00 00 00       	mov    $0x5,%eax
  8019df:	e8 c1 fe ff ff       	call   8018a5 <nsipc>
}
  8019e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8019f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fa:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8019ff:	b8 06 00 00 00       	mov    $0x6,%eax
  801a04:	e8 9c fe ff ff       	call   8018a5 <nsipc>
}
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	56                   	push   %esi
  801a0f:	53                   	push   %ebx
  801a10:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a13:	8b 45 08             	mov    0x8(%ebp),%eax
  801a16:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801a1b:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801a21:	8b 45 14             	mov    0x14(%ebp),%eax
  801a24:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a29:	b8 07 00 00 00       	mov    $0x7,%eax
  801a2e:	e8 72 fe ff ff       	call   8018a5 <nsipc>
  801a33:	89 c3                	mov    %eax,%ebx
  801a35:	85 c0                	test   %eax,%eax
  801a37:	78 22                	js     801a5b <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801a39:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801a3e:	39 c6                	cmp    %eax,%esi
  801a40:	0f 4e c6             	cmovle %esi,%eax
  801a43:	39 c3                	cmp    %eax,%ebx
  801a45:	7f 1d                	jg     801a64 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a47:	83 ec 04             	sub    $0x4,%esp
  801a4a:	53                   	push   %ebx
  801a4b:	68 00 70 80 00       	push   $0x807000
  801a50:	ff 75 0c             	push   0xc(%ebp)
  801a53:	e8 ae ee ff ff       	call   800906 <memmove>
  801a58:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a5b:	89 d8                	mov    %ebx,%eax
  801a5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a60:	5b                   	pop    %ebx
  801a61:	5e                   	pop    %esi
  801a62:	5d                   	pop    %ebp
  801a63:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801a64:	68 f7 26 80 00       	push   $0x8026f7
  801a69:	68 bf 26 80 00       	push   $0x8026bf
  801a6e:	6a 62                	push   $0x62
  801a70:	68 0c 27 80 00       	push   $0x80270c
  801a75:	e8 46 05 00 00       	call   801fc0 <_panic>

00801a7a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	53                   	push   %ebx
  801a7e:	83 ec 04             	sub    $0x4,%esp
  801a81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a84:	8b 45 08             	mov    0x8(%ebp),%eax
  801a87:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801a8c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a92:	7f 2e                	jg     801ac2 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	53                   	push   %ebx
  801a98:	ff 75 0c             	push   0xc(%ebp)
  801a9b:	68 0c 70 80 00       	push   $0x80700c
  801aa0:	e8 61 ee ff ff       	call   800906 <memmove>
	nsipcbuf.send.req_size = size;
  801aa5:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801aab:	8b 45 14             	mov    0x14(%ebp),%eax
  801aae:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801ab3:	b8 08 00 00 00       	mov    $0x8,%eax
  801ab8:	e8 e8 fd ff ff       	call   8018a5 <nsipc>
}
  801abd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    
	assert(size < 1600);
  801ac2:	68 18 27 80 00       	push   $0x802718
  801ac7:	68 bf 26 80 00       	push   $0x8026bf
  801acc:	6a 6d                	push   $0x6d
  801ace:	68 0c 27 80 00       	push   $0x80270c
  801ad3:	e8 e8 04 00 00       	call   801fc0 <_panic>

00801ad8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae9:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801aee:	8b 45 10             	mov    0x10(%ebp),%eax
  801af1:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801af6:	b8 09 00 00 00       	mov    $0x9,%eax
  801afb:	e8 a5 fd ff ff       	call   8018a5 <nsipc>
}
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	56                   	push   %esi
  801b06:	53                   	push   %ebx
  801b07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	ff 75 08             	push   0x8(%ebp)
  801b10:	e8 ad f3 ff ff       	call   800ec2 <fd2data>
  801b15:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b17:	83 c4 08             	add    $0x8,%esp
  801b1a:	68 24 27 80 00       	push   $0x802724
  801b1f:	53                   	push   %ebx
  801b20:	e8 4b ec ff ff       	call   800770 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b25:	8b 46 04             	mov    0x4(%esi),%eax
  801b28:	2b 06                	sub    (%esi),%eax
  801b2a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b30:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b37:	00 00 00 
	stat->st_dev = &devpipe;
  801b3a:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b41:	30 80 00 
	return 0;
}
  801b44:	b8 00 00 00 00       	mov    $0x0,%eax
  801b49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	53                   	push   %ebx
  801b54:	83 ec 0c             	sub    $0xc,%esp
  801b57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b5a:	53                   	push   %ebx
  801b5b:	6a 00                	push   $0x0
  801b5d:	e8 8f f0 ff ff       	call   800bf1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b62:	89 1c 24             	mov    %ebx,(%esp)
  801b65:	e8 58 f3 ff ff       	call   800ec2 <fd2data>
  801b6a:	83 c4 08             	add    $0x8,%esp
  801b6d:	50                   	push   %eax
  801b6e:	6a 00                	push   $0x0
  801b70:	e8 7c f0 ff ff       	call   800bf1 <sys_page_unmap>
}
  801b75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <_pipeisclosed>:
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	57                   	push   %edi
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	83 ec 1c             	sub    $0x1c,%esp
  801b83:	89 c7                	mov    %eax,%edi
  801b85:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b87:	a1 00 40 80 00       	mov    0x804000,%eax
  801b8c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	57                   	push   %edi
  801b93:	e8 6e 04 00 00       	call   802006 <pageref>
  801b98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b9b:	89 34 24             	mov    %esi,(%esp)
  801b9e:	e8 63 04 00 00       	call   802006 <pageref>
		nn = thisenv->env_runs;
  801ba3:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ba9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	39 cb                	cmp    %ecx,%ebx
  801bb1:	74 1b                	je     801bce <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bb3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bb6:	75 cf                	jne    801b87 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bb8:	8b 42 58             	mov    0x58(%edx),%eax
  801bbb:	6a 01                	push   $0x1
  801bbd:	50                   	push   %eax
  801bbe:	53                   	push   %ebx
  801bbf:	68 2b 27 80 00       	push   $0x80272b
  801bc4:	e8 cd e5 ff ff       	call   800196 <cprintf>
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	eb b9                	jmp    801b87 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801bce:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bd1:	0f 94 c0             	sete   %al
  801bd4:	0f b6 c0             	movzbl %al,%eax
}
  801bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5e                   	pop    %esi
  801bdc:	5f                   	pop    %edi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <devpipe_write>:
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	57                   	push   %edi
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	83 ec 28             	sub    $0x28,%esp
  801be8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801beb:	56                   	push   %esi
  801bec:	e8 d1 f2 ff ff       	call   800ec2 <fd2data>
  801bf1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	bf 00 00 00 00       	mov    $0x0,%edi
  801bfb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bfe:	75 09                	jne    801c09 <devpipe_write+0x2a>
	return i;
  801c00:	89 f8                	mov    %edi,%eax
  801c02:	eb 23                	jmp    801c27 <devpipe_write+0x48>
			sys_yield();
  801c04:	e8 44 ef ff ff       	call   800b4d <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c09:	8b 43 04             	mov    0x4(%ebx),%eax
  801c0c:	8b 0b                	mov    (%ebx),%ecx
  801c0e:	8d 51 20             	lea    0x20(%ecx),%edx
  801c11:	39 d0                	cmp    %edx,%eax
  801c13:	72 1a                	jb     801c2f <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801c15:	89 da                	mov    %ebx,%edx
  801c17:	89 f0                	mov    %esi,%eax
  801c19:	e8 5c ff ff ff       	call   801b7a <_pipeisclosed>
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	74 e2                	je     801c04 <devpipe_write+0x25>
				return 0;
  801c22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2a:	5b                   	pop    %ebx
  801c2b:	5e                   	pop    %esi
  801c2c:	5f                   	pop    %edi
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c32:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c36:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c39:	89 c2                	mov    %eax,%edx
  801c3b:	c1 fa 1f             	sar    $0x1f,%edx
  801c3e:	89 d1                	mov    %edx,%ecx
  801c40:	c1 e9 1b             	shr    $0x1b,%ecx
  801c43:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c46:	83 e2 1f             	and    $0x1f,%edx
  801c49:	29 ca                	sub    %ecx,%edx
  801c4b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c4f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c53:	83 c0 01             	add    $0x1,%eax
  801c56:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c59:	83 c7 01             	add    $0x1,%edi
  801c5c:	eb 9d                	jmp    801bfb <devpipe_write+0x1c>

00801c5e <devpipe_read>:
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 18             	sub    $0x18,%esp
  801c67:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c6a:	57                   	push   %edi
  801c6b:	e8 52 f2 ff ff       	call   800ec2 <fd2data>
  801c70:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	be 00 00 00 00       	mov    $0x0,%esi
  801c7a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c7d:	75 13                	jne    801c92 <devpipe_read+0x34>
	return i;
  801c7f:	89 f0                	mov    %esi,%eax
  801c81:	eb 02                	jmp    801c85 <devpipe_read+0x27>
				return i;
  801c83:	89 f0                	mov    %esi,%eax
}
  801c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c88:	5b                   	pop    %ebx
  801c89:	5e                   	pop    %esi
  801c8a:	5f                   	pop    %edi
  801c8b:	5d                   	pop    %ebp
  801c8c:	c3                   	ret    
			sys_yield();
  801c8d:	e8 bb ee ff ff       	call   800b4d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c92:	8b 03                	mov    (%ebx),%eax
  801c94:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c97:	75 18                	jne    801cb1 <devpipe_read+0x53>
			if (i > 0)
  801c99:	85 f6                	test   %esi,%esi
  801c9b:	75 e6                	jne    801c83 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801c9d:	89 da                	mov    %ebx,%edx
  801c9f:	89 f8                	mov    %edi,%eax
  801ca1:	e8 d4 fe ff ff       	call   801b7a <_pipeisclosed>
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	74 e3                	je     801c8d <devpipe_read+0x2f>
				return 0;
  801caa:	b8 00 00 00 00       	mov    $0x0,%eax
  801caf:	eb d4                	jmp    801c85 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cb1:	99                   	cltd   
  801cb2:	c1 ea 1b             	shr    $0x1b,%edx
  801cb5:	01 d0                	add    %edx,%eax
  801cb7:	83 e0 1f             	and    $0x1f,%eax
  801cba:	29 d0                	sub    %edx,%eax
  801cbc:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc4:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cc7:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801cca:	83 c6 01             	add    $0x1,%esi
  801ccd:	eb ab                	jmp    801c7a <devpipe_read+0x1c>

00801ccf <pipe>:
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801cd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cda:	50                   	push   %eax
  801cdb:	e8 f9 f1 ff ff       	call   800ed9 <fd_alloc>
  801ce0:	89 c3                	mov    %eax,%ebx
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	0f 88 23 01 00 00    	js     801e10 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ced:	83 ec 04             	sub    $0x4,%esp
  801cf0:	68 07 04 00 00       	push   $0x407
  801cf5:	ff 75 f4             	push   -0xc(%ebp)
  801cf8:	6a 00                	push   $0x0
  801cfa:	e8 6d ee ff ff       	call   800b6c <sys_page_alloc>
  801cff:	89 c3                	mov    %eax,%ebx
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	85 c0                	test   %eax,%eax
  801d06:	0f 88 04 01 00 00    	js     801e10 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d12:	50                   	push   %eax
  801d13:	e8 c1 f1 ff ff       	call   800ed9 <fd_alloc>
  801d18:	89 c3                	mov    %eax,%ebx
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	0f 88 db 00 00 00    	js     801e00 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d25:	83 ec 04             	sub    $0x4,%esp
  801d28:	68 07 04 00 00       	push   $0x407
  801d2d:	ff 75 f0             	push   -0x10(%ebp)
  801d30:	6a 00                	push   $0x0
  801d32:	e8 35 ee ff ff       	call   800b6c <sys_page_alloc>
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	0f 88 bc 00 00 00    	js     801e00 <pipe+0x131>
	va = fd2data(fd0);
  801d44:	83 ec 0c             	sub    $0xc,%esp
  801d47:	ff 75 f4             	push   -0xc(%ebp)
  801d4a:	e8 73 f1 ff ff       	call   800ec2 <fd2data>
  801d4f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d51:	83 c4 0c             	add    $0xc,%esp
  801d54:	68 07 04 00 00       	push   $0x407
  801d59:	50                   	push   %eax
  801d5a:	6a 00                	push   $0x0
  801d5c:	e8 0b ee ff ff       	call   800b6c <sys_page_alloc>
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	85 c0                	test   %eax,%eax
  801d68:	0f 88 82 00 00 00    	js     801df0 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6e:	83 ec 0c             	sub    $0xc,%esp
  801d71:	ff 75 f0             	push   -0x10(%ebp)
  801d74:	e8 49 f1 ff ff       	call   800ec2 <fd2data>
  801d79:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d80:	50                   	push   %eax
  801d81:	6a 00                	push   $0x0
  801d83:	56                   	push   %esi
  801d84:	6a 00                	push   $0x0
  801d86:	e8 24 ee ff ff       	call   800baf <sys_page_map>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 20             	add    $0x20,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 4e                	js     801de2 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801d94:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d9c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801da1:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801da8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dab:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801dad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801db7:	83 ec 0c             	sub    $0xc,%esp
  801dba:	ff 75 f4             	push   -0xc(%ebp)
  801dbd:	e8 f0 f0 ff ff       	call   800eb2 <fd2num>
  801dc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc7:	83 c4 04             	add    $0x4,%esp
  801dca:	ff 75 f0             	push   -0x10(%ebp)
  801dcd:	e8 e0 f0 ff ff       	call   800eb2 <fd2num>
  801dd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dd8:	83 c4 10             	add    $0x10,%esp
  801ddb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801de0:	eb 2e                	jmp    801e10 <pipe+0x141>
	sys_page_unmap(0, va);
  801de2:	83 ec 08             	sub    $0x8,%esp
  801de5:	56                   	push   %esi
  801de6:	6a 00                	push   $0x0
  801de8:	e8 04 ee ff ff       	call   800bf1 <sys_page_unmap>
  801ded:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801df0:	83 ec 08             	sub    $0x8,%esp
  801df3:	ff 75 f0             	push   -0x10(%ebp)
  801df6:	6a 00                	push   $0x0
  801df8:	e8 f4 ed ff ff       	call   800bf1 <sys_page_unmap>
  801dfd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e00:	83 ec 08             	sub    $0x8,%esp
  801e03:	ff 75 f4             	push   -0xc(%ebp)
  801e06:	6a 00                	push   $0x0
  801e08:	e8 e4 ed ff ff       	call   800bf1 <sys_page_unmap>
  801e0d:	83 c4 10             	add    $0x10,%esp
}
  801e10:	89 d8                	mov    %ebx,%eax
  801e12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e15:	5b                   	pop    %ebx
  801e16:	5e                   	pop    %esi
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <pipeisclosed>:
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e22:	50                   	push   %eax
  801e23:	ff 75 08             	push   0x8(%ebp)
  801e26:	e8 fe f0 ff ff       	call   800f29 <fd_lookup>
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 18                	js     801e4a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e32:	83 ec 0c             	sub    $0xc,%esp
  801e35:	ff 75 f4             	push   -0xc(%ebp)
  801e38:	e8 85 f0 ff ff       	call   800ec2 <fd2data>
  801e3d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e42:	e8 33 fd ff ff       	call   801b7a <_pipeisclosed>
  801e47:	83 c4 10             	add    $0x10,%esp
}
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e51:	c3                   	ret    

00801e52 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e58:	68 43 27 80 00       	push   $0x802743
  801e5d:	ff 75 0c             	push   0xc(%ebp)
  801e60:	e8 0b e9 ff ff       	call   800770 <strcpy>
	return 0;
}
  801e65:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <devcons_write>:
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	57                   	push   %edi
  801e70:	56                   	push   %esi
  801e71:	53                   	push   %ebx
  801e72:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e78:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e7d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e83:	eb 2e                	jmp    801eb3 <devcons_write+0x47>
		m = n - tot;
  801e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e88:	29 f3                	sub    %esi,%ebx
  801e8a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e8f:	39 c3                	cmp    %eax,%ebx
  801e91:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e94:	83 ec 04             	sub    $0x4,%esp
  801e97:	53                   	push   %ebx
  801e98:	89 f0                	mov    %esi,%eax
  801e9a:	03 45 0c             	add    0xc(%ebp),%eax
  801e9d:	50                   	push   %eax
  801e9e:	57                   	push   %edi
  801e9f:	e8 62 ea ff ff       	call   800906 <memmove>
		sys_cputs(buf, m);
  801ea4:	83 c4 08             	add    $0x8,%esp
  801ea7:	53                   	push   %ebx
  801ea8:	57                   	push   %edi
  801ea9:	e8 02 ec ff ff       	call   800ab0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801eae:	01 de                	add    %ebx,%esi
  801eb0:	83 c4 10             	add    $0x10,%esp
  801eb3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb6:	72 cd                	jb     801e85 <devcons_write+0x19>
}
  801eb8:	89 f0                	mov    %esi,%eax
  801eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5f                   	pop    %edi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    

00801ec2 <devcons_read>:
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	83 ec 08             	sub    $0x8,%esp
  801ec8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ecd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed1:	75 07                	jne    801eda <devcons_read+0x18>
  801ed3:	eb 1f                	jmp    801ef4 <devcons_read+0x32>
		sys_yield();
  801ed5:	e8 73 ec ff ff       	call   800b4d <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801eda:	e8 ef eb ff ff       	call   800ace <sys_cgetc>
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	74 f2                	je     801ed5 <devcons_read+0x13>
	if (c < 0)
  801ee3:	78 0f                	js     801ef4 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801ee5:	83 f8 04             	cmp    $0x4,%eax
  801ee8:	74 0c                	je     801ef6 <devcons_read+0x34>
	*(char*)vbuf = c;
  801eea:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eed:	88 02                	mov    %al,(%edx)
	return 1;
  801eef:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    
		return 0;
  801ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  801efb:	eb f7                	jmp    801ef4 <devcons_read+0x32>

00801efd <cputchar>:
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f03:	8b 45 08             	mov    0x8(%ebp),%eax
  801f06:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f09:	6a 01                	push   $0x1
  801f0b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f0e:	50                   	push   %eax
  801f0f:	e8 9c eb ff ff       	call   800ab0 <sys_cputs>
}
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	c9                   	leave  
  801f18:	c3                   	ret    

00801f19 <getchar>:
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f1f:	6a 01                	push   $0x1
  801f21:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f24:	50                   	push   %eax
  801f25:	6a 00                	push   $0x0
  801f27:	e8 66 f2 ff ff       	call   801192 <read>
	if (r < 0)
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 06                	js     801f39 <getchar+0x20>
	if (r < 1)
  801f33:	74 06                	je     801f3b <getchar+0x22>
	return c;
  801f35:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f39:	c9                   	leave  
  801f3a:	c3                   	ret    
		return -E_EOF;
  801f3b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f40:	eb f7                	jmp    801f39 <getchar+0x20>

00801f42 <iscons>:
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4b:	50                   	push   %eax
  801f4c:	ff 75 08             	push   0x8(%ebp)
  801f4f:	e8 d5 ef ff ff       	call   800f29 <fd_lookup>
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 c0                	test   %eax,%eax
  801f59:	78 11                	js     801f6c <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f64:	39 10                	cmp    %edx,(%eax)
  801f66:	0f 94 c0             	sete   %al
  801f69:	0f b6 c0             	movzbl %al,%eax
}
  801f6c:	c9                   	leave  
  801f6d:	c3                   	ret    

00801f6e <opencons>:
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f77:	50                   	push   %eax
  801f78:	e8 5c ef ff ff       	call   800ed9 <fd_alloc>
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	85 c0                	test   %eax,%eax
  801f82:	78 3a                	js     801fbe <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f84:	83 ec 04             	sub    $0x4,%esp
  801f87:	68 07 04 00 00       	push   $0x407
  801f8c:	ff 75 f4             	push   -0xc(%ebp)
  801f8f:	6a 00                	push   $0x0
  801f91:	e8 d6 eb ff ff       	call   800b6c <sys_page_alloc>
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	85 c0                	test   %eax,%eax
  801f9b:	78 21                	js     801fbe <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fa6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb2:	83 ec 0c             	sub    $0xc,%esp
  801fb5:	50                   	push   %eax
  801fb6:	e8 f7 ee ff ff       	call   800eb2 <fd2num>
  801fbb:	83 c4 10             	add    $0x10,%esp
}
  801fbe:	c9                   	leave  
  801fbf:	c3                   	ret    

00801fc0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	56                   	push   %esi
  801fc4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fc5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fc8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fce:	e8 5b eb ff ff       	call   800b2e <sys_getenvid>
  801fd3:	83 ec 0c             	sub    $0xc,%esp
  801fd6:	ff 75 0c             	push   0xc(%ebp)
  801fd9:	ff 75 08             	push   0x8(%ebp)
  801fdc:	56                   	push   %esi
  801fdd:	50                   	push   %eax
  801fde:	68 50 27 80 00       	push   $0x802750
  801fe3:	e8 ae e1 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fe8:	83 c4 18             	add    $0x18,%esp
  801feb:	53                   	push   %ebx
  801fec:	ff 75 10             	push   0x10(%ebp)
  801fef:	e8 51 e1 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  801ff4:	c7 04 24 3c 27 80 00 	movl   $0x80273c,(%esp)
  801ffb:	e8 96 e1 ff ff       	call   800196 <cprintf>
  802000:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802003:	cc                   	int3   
  802004:	eb fd                	jmp    802003 <_panic+0x43>

00802006 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80200c:	89 c2                	mov    %eax,%edx
  80200e:	c1 ea 16             	shr    $0x16,%edx
  802011:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802018:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80201d:	f6 c1 01             	test   $0x1,%cl
  802020:	74 1c                	je     80203e <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802022:	c1 e8 0c             	shr    $0xc,%eax
  802025:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80202c:	a8 01                	test   $0x1,%al
  80202e:	74 0e                	je     80203e <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802030:	c1 e8 0c             	shr    $0xc,%eax
  802033:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80203a:	ef 
  80203b:	0f b7 d2             	movzwl %dx,%edx
}
  80203e:	89 d0                	mov    %edx,%eax
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	66 90                	xchg   %ax,%ax
  802044:	66 90                	xchg   %ax,%ax
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__udivdi3>:
  802050:	f3 0f 1e fb          	endbr32 
  802054:	55                   	push   %ebp
  802055:	57                   	push   %edi
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	83 ec 1c             	sub    $0x1c,%esp
  80205b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80205f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802063:	8b 74 24 34          	mov    0x34(%esp),%esi
  802067:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80206b:	85 c0                	test   %eax,%eax
  80206d:	75 19                	jne    802088 <__udivdi3+0x38>
  80206f:	39 f3                	cmp    %esi,%ebx
  802071:	76 4d                	jbe    8020c0 <__udivdi3+0x70>
  802073:	31 ff                	xor    %edi,%edi
  802075:	89 e8                	mov    %ebp,%eax
  802077:	89 f2                	mov    %esi,%edx
  802079:	f7 f3                	div    %ebx
  80207b:	89 fa                	mov    %edi,%edx
  80207d:	83 c4 1c             	add    $0x1c,%esp
  802080:	5b                   	pop    %ebx
  802081:	5e                   	pop    %esi
  802082:	5f                   	pop    %edi
  802083:	5d                   	pop    %ebp
  802084:	c3                   	ret    
  802085:	8d 76 00             	lea    0x0(%esi),%esi
  802088:	39 f0                	cmp    %esi,%eax
  80208a:	76 14                	jbe    8020a0 <__udivdi3+0x50>
  80208c:	31 ff                	xor    %edi,%edi
  80208e:	31 c0                	xor    %eax,%eax
  802090:	89 fa                	mov    %edi,%edx
  802092:	83 c4 1c             	add    $0x1c,%esp
  802095:	5b                   	pop    %ebx
  802096:	5e                   	pop    %esi
  802097:	5f                   	pop    %edi
  802098:	5d                   	pop    %ebp
  802099:	c3                   	ret    
  80209a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a0:	0f bd f8             	bsr    %eax,%edi
  8020a3:	83 f7 1f             	xor    $0x1f,%edi
  8020a6:	75 48                	jne    8020f0 <__udivdi3+0xa0>
  8020a8:	39 f0                	cmp    %esi,%eax
  8020aa:	72 06                	jb     8020b2 <__udivdi3+0x62>
  8020ac:	31 c0                	xor    %eax,%eax
  8020ae:	39 eb                	cmp    %ebp,%ebx
  8020b0:	77 de                	ja     802090 <__udivdi3+0x40>
  8020b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b7:	eb d7                	jmp    802090 <__udivdi3+0x40>
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d9                	mov    %ebx,%ecx
  8020c2:	85 db                	test   %ebx,%ebx
  8020c4:	75 0b                	jne    8020d1 <__udivdi3+0x81>
  8020c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020cb:	31 d2                	xor    %edx,%edx
  8020cd:	f7 f3                	div    %ebx
  8020cf:	89 c1                	mov    %eax,%ecx
  8020d1:	31 d2                	xor    %edx,%edx
  8020d3:	89 f0                	mov    %esi,%eax
  8020d5:	f7 f1                	div    %ecx
  8020d7:	89 c6                	mov    %eax,%esi
  8020d9:	89 e8                	mov    %ebp,%eax
  8020db:	89 f7                	mov    %esi,%edi
  8020dd:	f7 f1                	div    %ecx
  8020df:	89 fa                	mov    %edi,%edx
  8020e1:	83 c4 1c             	add    $0x1c,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	89 f9                	mov    %edi,%ecx
  8020f2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020f7:	29 fa                	sub    %edi,%edx
  8020f9:	d3 e0                	shl    %cl,%eax
  8020fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020ff:	89 d1                	mov    %edx,%ecx
  802101:	89 d8                	mov    %ebx,%eax
  802103:	d3 e8                	shr    %cl,%eax
  802105:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802109:	09 c1                	or     %eax,%ecx
  80210b:	89 f0                	mov    %esi,%eax
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f9                	mov    %edi,%ecx
  802113:	d3 e3                	shl    %cl,%ebx
  802115:	89 d1                	mov    %edx,%ecx
  802117:	d3 e8                	shr    %cl,%eax
  802119:	89 f9                	mov    %edi,%ecx
  80211b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80211f:	89 eb                	mov    %ebp,%ebx
  802121:	d3 e6                	shl    %cl,%esi
  802123:	89 d1                	mov    %edx,%ecx
  802125:	d3 eb                	shr    %cl,%ebx
  802127:	09 f3                	or     %esi,%ebx
  802129:	89 c6                	mov    %eax,%esi
  80212b:	89 f2                	mov    %esi,%edx
  80212d:	89 d8                	mov    %ebx,%eax
  80212f:	f7 74 24 08          	divl   0x8(%esp)
  802133:	89 d6                	mov    %edx,%esi
  802135:	89 c3                	mov    %eax,%ebx
  802137:	f7 64 24 0c          	mull   0xc(%esp)
  80213b:	39 d6                	cmp    %edx,%esi
  80213d:	72 19                	jb     802158 <__udivdi3+0x108>
  80213f:	89 f9                	mov    %edi,%ecx
  802141:	d3 e5                	shl    %cl,%ebp
  802143:	39 c5                	cmp    %eax,%ebp
  802145:	73 04                	jae    80214b <__udivdi3+0xfb>
  802147:	39 d6                	cmp    %edx,%esi
  802149:	74 0d                	je     802158 <__udivdi3+0x108>
  80214b:	89 d8                	mov    %ebx,%eax
  80214d:	31 ff                	xor    %edi,%edi
  80214f:	e9 3c ff ff ff       	jmp    802090 <__udivdi3+0x40>
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80215b:	31 ff                	xor    %edi,%edi
  80215d:	e9 2e ff ff ff       	jmp    802090 <__udivdi3+0x40>
  802162:	66 90                	xchg   %ax,%ax
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__umoddi3>:
  802170:	f3 0f 1e fb          	endbr32 
  802174:	55                   	push   %ebp
  802175:	57                   	push   %edi
  802176:	56                   	push   %esi
  802177:	53                   	push   %ebx
  802178:	83 ec 1c             	sub    $0x1c,%esp
  80217b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80217f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802183:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802187:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80218b:	89 f0                	mov    %esi,%eax
  80218d:	89 da                	mov    %ebx,%edx
  80218f:	85 ff                	test   %edi,%edi
  802191:	75 15                	jne    8021a8 <__umoddi3+0x38>
  802193:	39 dd                	cmp    %ebx,%ebp
  802195:	76 39                	jbe    8021d0 <__umoddi3+0x60>
  802197:	f7 f5                	div    %ebp
  802199:	89 d0                	mov    %edx,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	83 c4 1c             	add    $0x1c,%esp
  8021a0:	5b                   	pop    %ebx
  8021a1:	5e                   	pop    %esi
  8021a2:	5f                   	pop    %edi
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    
  8021a5:	8d 76 00             	lea    0x0(%esi),%esi
  8021a8:	39 df                	cmp    %ebx,%edi
  8021aa:	77 f1                	ja     80219d <__umoddi3+0x2d>
  8021ac:	0f bd cf             	bsr    %edi,%ecx
  8021af:	83 f1 1f             	xor    $0x1f,%ecx
  8021b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021b6:	75 40                	jne    8021f8 <__umoddi3+0x88>
  8021b8:	39 df                	cmp    %ebx,%edi
  8021ba:	72 04                	jb     8021c0 <__umoddi3+0x50>
  8021bc:	39 f5                	cmp    %esi,%ebp
  8021be:	77 dd                	ja     80219d <__umoddi3+0x2d>
  8021c0:	89 da                	mov    %ebx,%edx
  8021c2:	89 f0                	mov    %esi,%eax
  8021c4:	29 e8                	sub    %ebp,%eax
  8021c6:	19 fa                	sbb    %edi,%edx
  8021c8:	eb d3                	jmp    80219d <__umoddi3+0x2d>
  8021ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d0:	89 e9                	mov    %ebp,%ecx
  8021d2:	85 ed                	test   %ebp,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x71>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f5                	div    %ebp
  8021df:	89 c1                	mov    %eax,%ecx
  8021e1:	89 d8                	mov    %ebx,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f1                	div    %ecx
  8021e7:	89 f0                	mov    %esi,%eax
  8021e9:	f7 f1                	div    %ecx
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	31 d2                	xor    %edx,%edx
  8021ef:	eb ac                	jmp    80219d <__umoddi3+0x2d>
  8021f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021fc:	ba 20 00 00 00       	mov    $0x20,%edx
  802201:	29 c2                	sub    %eax,%edx
  802203:	89 c1                	mov    %eax,%ecx
  802205:	89 e8                	mov    %ebp,%eax
  802207:	d3 e7                	shl    %cl,%edi
  802209:	89 d1                	mov    %edx,%ecx
  80220b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80220f:	d3 e8                	shr    %cl,%eax
  802211:	89 c1                	mov    %eax,%ecx
  802213:	8b 44 24 04          	mov    0x4(%esp),%eax
  802217:	09 f9                	or     %edi,%ecx
  802219:	89 df                	mov    %ebx,%edi
  80221b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80221f:	89 c1                	mov    %eax,%ecx
  802221:	d3 e5                	shl    %cl,%ebp
  802223:	89 d1                	mov    %edx,%ecx
  802225:	d3 ef                	shr    %cl,%edi
  802227:	89 c1                	mov    %eax,%ecx
  802229:	89 f0                	mov    %esi,%eax
  80222b:	d3 e3                	shl    %cl,%ebx
  80222d:	89 d1                	mov    %edx,%ecx
  80222f:	89 fa                	mov    %edi,%edx
  802231:	d3 e8                	shr    %cl,%eax
  802233:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802238:	09 d8                	or     %ebx,%eax
  80223a:	f7 74 24 08          	divl   0x8(%esp)
  80223e:	89 d3                	mov    %edx,%ebx
  802240:	d3 e6                	shl    %cl,%esi
  802242:	f7 e5                	mul    %ebp
  802244:	89 c7                	mov    %eax,%edi
  802246:	89 d1                	mov    %edx,%ecx
  802248:	39 d3                	cmp    %edx,%ebx
  80224a:	72 06                	jb     802252 <__umoddi3+0xe2>
  80224c:	75 0e                	jne    80225c <__umoddi3+0xec>
  80224e:	39 c6                	cmp    %eax,%esi
  802250:	73 0a                	jae    80225c <__umoddi3+0xec>
  802252:	29 e8                	sub    %ebp,%eax
  802254:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802258:	89 d1                	mov    %edx,%ecx
  80225a:	89 c7                	mov    %eax,%edi
  80225c:	89 f5                	mov    %esi,%ebp
  80225e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802262:	29 fd                	sub    %edi,%ebp
  802264:	19 cb                	sbb    %ecx,%ebx
  802266:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80226b:	89 d8                	mov    %ebx,%eax
  80226d:	d3 e0                	shl    %cl,%eax
  80226f:	89 f1                	mov    %esi,%ecx
  802271:	d3 ed                	shr    %cl,%ebp
  802273:	d3 eb                	shr    %cl,%ebx
  802275:	09 e8                	or     %ebp,%eax
  802277:	89 da                	mov    %ebx,%edx
  802279:	83 c4 1c             	add    $0x1c,%esp
  80227c:	5b                   	pop    %ebx
  80227d:	5e                   	pop    %esi
  80227e:	5f                   	pop    %edi
  80227f:	5d                   	pop    %ebp
  802280:	c3                   	ret    
