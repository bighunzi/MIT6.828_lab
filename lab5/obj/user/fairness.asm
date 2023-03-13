
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
  800058:	68 d1 1d 80 00       	push   $0x801dd1
  80005d:	e8 34 01 00 00       	call   800196 <cprintf>
  800062:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800065:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  80006a:	6a 00                	push   $0x0
  80006c:	6a 00                	push   $0x0
  80006e:	6a 00                	push   $0x0
  800070:	50                   	push   %eax
  800071:	e8 4e 0d 00 00       	call   800dc4 <ipc_send>
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	eb ea                	jmp    800065 <umain+0x32>
			ipc_recv(&who, 0, 0);
  80007b:	8d 75 f4             	lea    -0xc(%ebp),%esi
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	6a 00                	push   $0x0
  800083:	6a 00                	push   $0x0
  800085:	56                   	push   %esi
  800086:	e8 d2 0c 00 00       	call   800d5d <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008b:	83 c4 0c             	add    $0xc,%esp
  80008e:	ff 75 f4             	push   -0xc(%ebp)
  800091:	53                   	push   %ebx
  800092:	68 c0 1d 80 00       	push   $0x801dc0
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
  8000ed:	e8 2b 0f 00 00       	call   80101d <close_all>
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
  8001f8:	e8 83 19 00 00       	call   801b80 <__udivdi3>
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
  800236:	e8 65 1a 00 00       	call   801ca0 <__umoddi3>
  80023b:	83 c4 14             	add    $0x14,%esp
  80023e:	0f be 80 f2 1d 80 00 	movsbl 0x801df2(%eax),%eax
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
  8002f8:	ff 24 85 40 1f 80 00 	jmp    *0x801f40(,%eax,4)
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
  8003c6:	8b 14 85 a0 20 80 00 	mov    0x8020a0(,%eax,4),%edx
  8003cd:	85 d2                	test   %edx,%edx
  8003cf:	74 18                	je     8003e9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003d1:	52                   	push   %edx
  8003d2:	68 ed 21 80 00       	push   $0x8021ed
  8003d7:	53                   	push   %ebx
  8003d8:	56                   	push   %esi
  8003d9:	e8 92 fe ff ff       	call   800270 <printfmt>
  8003de:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e1:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e4:	e9 66 02 00 00       	jmp    80064f <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003e9:	50                   	push   %eax
  8003ea:	68 0a 1e 80 00       	push   $0x801e0a
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
  800411:	b8 03 1e 80 00       	mov    $0x801e03,%eax
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
  800b1d:	68 ff 20 80 00       	push   $0x8020ff
  800b22:	6a 2a                	push   $0x2a
  800b24:	68 1c 21 80 00       	push   $0x80211c
  800b29:	e8 c4 0f 00 00       	call   801af2 <_panic>

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
  800b9e:	68 ff 20 80 00       	push   $0x8020ff
  800ba3:	6a 2a                	push   $0x2a
  800ba5:	68 1c 21 80 00       	push   $0x80211c
  800baa:	e8 43 0f 00 00       	call   801af2 <_panic>

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
  800be0:	68 ff 20 80 00       	push   $0x8020ff
  800be5:	6a 2a                	push   $0x2a
  800be7:	68 1c 21 80 00       	push   $0x80211c
  800bec:	e8 01 0f 00 00       	call   801af2 <_panic>

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
  800c22:	68 ff 20 80 00       	push   $0x8020ff
  800c27:	6a 2a                	push   $0x2a
  800c29:	68 1c 21 80 00       	push   $0x80211c
  800c2e:	e8 bf 0e 00 00       	call   801af2 <_panic>

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
  800c64:	68 ff 20 80 00       	push   $0x8020ff
  800c69:	6a 2a                	push   $0x2a
  800c6b:	68 1c 21 80 00       	push   $0x80211c
  800c70:	e8 7d 0e 00 00       	call   801af2 <_panic>

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
  800ca6:	68 ff 20 80 00       	push   $0x8020ff
  800cab:	6a 2a                	push   $0x2a
  800cad:	68 1c 21 80 00       	push   $0x80211c
  800cb2:	e8 3b 0e 00 00       	call   801af2 <_panic>

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
  800ce8:	68 ff 20 80 00       	push   $0x8020ff
  800ced:	6a 2a                	push   $0x2a
  800cef:	68 1c 21 80 00       	push   $0x80211c
  800cf4:	e8 f9 0d 00 00       	call   801af2 <_panic>

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
  800d4c:	68 ff 20 80 00       	push   $0x8020ff
  800d51:	6a 2a                	push   $0x2a
  800d53:	68 1c 21 80 00       	push   $0x80211c
  800d58:	e8 95 0d 00 00       	call   801af2 <_panic>

00800d5d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	8b 75 08             	mov    0x8(%ebp),%esi
  800d65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800d72:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	50                   	push   %eax
  800d79:	e8 9e ff ff ff       	call   800d1c <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  800d7e:	83 c4 10             	add    $0x10,%esp
  800d81:	85 f6                	test   %esi,%esi
  800d83:	74 14                	je     800d99 <ipc_recv+0x3c>
  800d85:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	78 09                	js     800d97 <ipc_recv+0x3a>
  800d8e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800d94:	8b 52 74             	mov    0x74(%edx),%edx
  800d97:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  800d99:	85 db                	test   %ebx,%ebx
  800d9b:	74 14                	je     800db1 <ipc_recv+0x54>
  800d9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800da2:	85 c0                	test   %eax,%eax
  800da4:	78 09                	js     800daf <ipc_recv+0x52>
  800da6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800dac:	8b 52 78             	mov    0x78(%edx),%edx
  800daf:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  800db1:	85 c0                	test   %eax,%eax
  800db3:	78 08                	js     800dbd <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  800db5:	a1 00 40 80 00       	mov    0x804000,%eax
  800dba:	8b 40 70             	mov    0x70(%eax),%eax
}
  800dbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dd0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  800dd6:	85 db                	test   %ebx,%ebx
  800dd8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800ddd:	0f 44 d8             	cmove  %eax,%ebx
  800de0:	eb 05                	jmp    800de7 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  800de2:	e8 66 fd ff ff       	call   800b4d <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  800de7:	ff 75 14             	push   0x14(%ebp)
  800dea:	53                   	push   %ebx
  800deb:	56                   	push   %esi
  800dec:	57                   	push   %edi
  800ded:	e8 07 ff ff ff       	call   800cf9 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  800df2:	83 c4 10             	add    $0x10,%esp
  800df5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800df8:	74 e8                	je     800de2 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	78 08                	js     800e06 <ipc_send+0x42>
	}while (r<0);

}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  800e06:	50                   	push   %eax
  800e07:	68 2a 21 80 00       	push   $0x80212a
  800e0c:	6a 3d                	push   $0x3d
  800e0e:	68 3e 21 80 00       	push   $0x80213e
  800e13:	e8 da 0c 00 00       	call   801af2 <_panic>

00800e18 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e1e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e23:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e26:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e2c:	8b 52 50             	mov    0x50(%edx),%edx
  800e2f:	39 ca                	cmp    %ecx,%edx
  800e31:	74 11                	je     800e44 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800e33:	83 c0 01             	add    $0x1,%eax
  800e36:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e3b:	75 e6                	jne    800e23 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e42:	eb 0b                	jmp    800e4f <ipc_find_env+0x37>
			return envs[i].env_id;
  800e44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e4c:	8b 40 48             	mov    0x48(%eax),%eax
}
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	05 00 00 00 30       	add    $0x30000000,%eax
  800e5c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
  800e67:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e71:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e80:	89 c2                	mov    %eax,%edx
  800e82:	c1 ea 16             	shr    $0x16,%edx
  800e85:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8c:	f6 c2 01             	test   $0x1,%dl
  800e8f:	74 29                	je     800eba <fd_alloc+0x42>
  800e91:	89 c2                	mov    %eax,%edx
  800e93:	c1 ea 0c             	shr    $0xc,%edx
  800e96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e9d:	f6 c2 01             	test   $0x1,%dl
  800ea0:	74 18                	je     800eba <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800ea2:	05 00 10 00 00       	add    $0x1000,%eax
  800ea7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eac:	75 d2                	jne    800e80 <fd_alloc+0x8>
  800eae:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800eb3:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800eb8:	eb 05                	jmp    800ebf <fd_alloc+0x47>
			return 0;
  800eba:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800ebf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec2:	89 02                	mov    %eax,(%edx)
}
  800ec4:	89 c8                	mov    %ecx,%eax
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ece:	83 f8 1f             	cmp    $0x1f,%eax
  800ed1:	77 30                	ja     800f03 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed3:	c1 e0 0c             	shl    $0xc,%eax
  800ed6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800edb:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ee1:	f6 c2 01             	test   $0x1,%dl
  800ee4:	74 24                	je     800f0a <fd_lookup+0x42>
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	c1 ea 0c             	shr    $0xc,%edx
  800eeb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef2:	f6 c2 01             	test   $0x1,%dl
  800ef5:	74 1a                	je     800f11 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ef7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efa:	89 02                	mov    %eax,(%edx)
	return 0;
  800efc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    
		return -E_INVAL;
  800f03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f08:	eb f7                	jmp    800f01 <fd_lookup+0x39>
		return -E_INVAL;
  800f0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0f:	eb f0                	jmp    800f01 <fd_lookup+0x39>
  800f11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f16:	eb e9                	jmp    800f01 <fd_lookup+0x39>

00800f18 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 04             	sub    $0x4,%esp
  800f1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f22:	b8 c4 21 80 00       	mov    $0x8021c4,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800f27:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f2c:	39 13                	cmp    %edx,(%ebx)
  800f2e:	74 32                	je     800f62 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800f30:	83 c0 04             	add    $0x4,%eax
  800f33:	8b 18                	mov    (%eax),%ebx
  800f35:	85 db                	test   %ebx,%ebx
  800f37:	75 f3                	jne    800f2c <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f39:	a1 00 40 80 00       	mov    0x804000,%eax
  800f3e:	8b 40 48             	mov    0x48(%eax),%eax
  800f41:	83 ec 04             	sub    $0x4,%esp
  800f44:	52                   	push   %edx
  800f45:	50                   	push   %eax
  800f46:	68 48 21 80 00       	push   $0x802148
  800f4b:	e8 46 f2 ff ff       	call   800196 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5b:	89 1a                	mov    %ebx,(%edx)
}
  800f5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f60:	c9                   	leave  
  800f61:	c3                   	ret    
			return 0;
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
  800f67:	eb ef                	jmp    800f58 <dev_lookup+0x40>

00800f69 <fd_close>:
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 24             	sub    $0x24,%esp
  800f72:	8b 75 08             	mov    0x8(%ebp),%esi
  800f75:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f78:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f7b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f7c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f82:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f85:	50                   	push   %eax
  800f86:	e8 3d ff ff ff       	call   800ec8 <fd_lookup>
  800f8b:	89 c3                	mov    %eax,%ebx
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 05                	js     800f99 <fd_close+0x30>
	    || fd != fd2)
  800f94:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f97:	74 16                	je     800faf <fd_close+0x46>
		return (must_exist ? r : 0);
  800f99:	89 f8                	mov    %edi,%eax
  800f9b:	84 c0                	test   %al,%al
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa2:	0f 44 d8             	cmove  %eax,%ebx
}
  800fa5:	89 d8                	mov    %ebx,%eax
  800fa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fb5:	50                   	push   %eax
  800fb6:	ff 36                	push   (%esi)
  800fb8:	e8 5b ff ff ff       	call   800f18 <dev_lookup>
  800fbd:	89 c3                	mov    %eax,%ebx
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 1a                	js     800fe0 <fd_close+0x77>
		if (dev->dev_close)
  800fc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fc9:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fcc:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	74 0b                	je     800fe0 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	56                   	push   %esi
  800fd9:	ff d0                	call   *%eax
  800fdb:	89 c3                	mov    %eax,%ebx
  800fdd:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fe0:	83 ec 08             	sub    $0x8,%esp
  800fe3:	56                   	push   %esi
  800fe4:	6a 00                	push   $0x0
  800fe6:	e8 06 fc ff ff       	call   800bf1 <sys_page_unmap>
	return r;
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	eb b5                	jmp    800fa5 <fd_close+0x3c>

00800ff0 <close>:

int
close(int fdnum)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff9:	50                   	push   %eax
  800ffa:	ff 75 08             	push   0x8(%ebp)
  800ffd:	e8 c6 fe ff ff       	call   800ec8 <fd_lookup>
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	79 02                	jns    80100b <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801009:	c9                   	leave  
  80100a:	c3                   	ret    
		return fd_close(fd, 1);
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	6a 01                	push   $0x1
  801010:	ff 75 f4             	push   -0xc(%ebp)
  801013:	e8 51 ff ff ff       	call   800f69 <fd_close>
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	eb ec                	jmp    801009 <close+0x19>

0080101d <close_all>:

void
close_all(void)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	53                   	push   %ebx
  801021:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801024:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	53                   	push   %ebx
  80102d:	e8 be ff ff ff       	call   800ff0 <close>
	for (i = 0; i < MAXFD; i++)
  801032:	83 c3 01             	add    $0x1,%ebx
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	83 fb 20             	cmp    $0x20,%ebx
  80103b:	75 ec                	jne    801029 <close_all+0xc>
}
  80103d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801040:	c9                   	leave  
  801041:	c3                   	ret    

00801042 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80104b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80104e:	50                   	push   %eax
  80104f:	ff 75 08             	push   0x8(%ebp)
  801052:	e8 71 fe ff ff       	call   800ec8 <fd_lookup>
  801057:	89 c3                	mov    %eax,%ebx
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 7f                	js     8010df <dup+0x9d>
		return r;
	close(newfdnum);
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	ff 75 0c             	push   0xc(%ebp)
  801066:	e8 85 ff ff ff       	call   800ff0 <close>

	newfd = INDEX2FD(newfdnum);
  80106b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80106e:	c1 e6 0c             	shl    $0xc,%esi
  801071:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801077:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80107a:	89 3c 24             	mov    %edi,(%esp)
  80107d:	e8 df fd ff ff       	call   800e61 <fd2data>
  801082:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801084:	89 34 24             	mov    %esi,(%esp)
  801087:	e8 d5 fd ff ff       	call   800e61 <fd2data>
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801092:	89 d8                	mov    %ebx,%eax
  801094:	c1 e8 16             	shr    $0x16,%eax
  801097:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109e:	a8 01                	test   $0x1,%al
  8010a0:	74 11                	je     8010b3 <dup+0x71>
  8010a2:	89 d8                	mov    %ebx,%eax
  8010a4:	c1 e8 0c             	shr    $0xc,%eax
  8010a7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ae:	f6 c2 01             	test   $0x1,%dl
  8010b1:	75 36                	jne    8010e9 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b3:	89 f8                	mov    %edi,%eax
  8010b5:	c1 e8 0c             	shr    $0xc,%eax
  8010b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c7:	50                   	push   %eax
  8010c8:	56                   	push   %esi
  8010c9:	6a 00                	push   $0x0
  8010cb:	57                   	push   %edi
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 dc fa ff ff       	call   800baf <sys_page_map>
  8010d3:	89 c3                	mov    %eax,%ebx
  8010d5:	83 c4 20             	add    $0x20,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 33                	js     80110f <dup+0xcd>
		goto err;

	return newfdnum;
  8010dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010df:	89 d8                	mov    %ebx,%eax
  8010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f8:	50                   	push   %eax
  8010f9:	ff 75 d4             	push   -0x2c(%ebp)
  8010fc:	6a 00                	push   $0x0
  8010fe:	53                   	push   %ebx
  8010ff:	6a 00                	push   $0x0
  801101:	e8 a9 fa ff ff       	call   800baf <sys_page_map>
  801106:	89 c3                	mov    %eax,%ebx
  801108:	83 c4 20             	add    $0x20,%esp
  80110b:	85 c0                	test   %eax,%eax
  80110d:	79 a4                	jns    8010b3 <dup+0x71>
	sys_page_unmap(0, newfd);
  80110f:	83 ec 08             	sub    $0x8,%esp
  801112:	56                   	push   %esi
  801113:	6a 00                	push   $0x0
  801115:	e8 d7 fa ff ff       	call   800bf1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80111a:	83 c4 08             	add    $0x8,%esp
  80111d:	ff 75 d4             	push   -0x2c(%ebp)
  801120:	6a 00                	push   $0x0
  801122:	e8 ca fa ff ff       	call   800bf1 <sys_page_unmap>
	return r;
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	eb b3                	jmp    8010df <dup+0x9d>

0080112c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	83 ec 18             	sub    $0x18,%esp
  801134:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801137:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	56                   	push   %esi
  80113c:	e8 87 fd ff ff       	call   800ec8 <fd_lookup>
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	85 c0                	test   %eax,%eax
  801146:	78 3c                	js     801184 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801148:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	ff 33                	push   (%ebx)
  801154:	e8 bf fd ff ff       	call   800f18 <dev_lookup>
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 24                	js     801184 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801160:	8b 43 08             	mov    0x8(%ebx),%eax
  801163:	83 e0 03             	and    $0x3,%eax
  801166:	83 f8 01             	cmp    $0x1,%eax
  801169:	74 20                	je     80118b <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80116b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116e:	8b 40 08             	mov    0x8(%eax),%eax
  801171:	85 c0                	test   %eax,%eax
  801173:	74 37                	je     8011ac <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	ff 75 10             	push   0x10(%ebp)
  80117b:	ff 75 0c             	push   0xc(%ebp)
  80117e:	53                   	push   %ebx
  80117f:	ff d0                	call   *%eax
  801181:	83 c4 10             	add    $0x10,%esp
}
  801184:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80118b:	a1 00 40 80 00       	mov    0x804000,%eax
  801190:	8b 40 48             	mov    0x48(%eax),%eax
  801193:	83 ec 04             	sub    $0x4,%esp
  801196:	56                   	push   %esi
  801197:	50                   	push   %eax
  801198:	68 89 21 80 00       	push   $0x802189
  80119d:	e8 f4 ef ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011aa:	eb d8                	jmp    801184 <read+0x58>
		return -E_NOT_SUPP;
  8011ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011b1:	eb d1                	jmp    801184 <read+0x58>

008011b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	57                   	push   %edi
  8011b7:	56                   	push   %esi
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 0c             	sub    $0xc,%esp
  8011bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c7:	eb 02                	jmp    8011cb <readn+0x18>
  8011c9:	01 c3                	add    %eax,%ebx
  8011cb:	39 f3                	cmp    %esi,%ebx
  8011cd:	73 21                	jae    8011f0 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	89 f0                	mov    %esi,%eax
  8011d4:	29 d8                	sub    %ebx,%eax
  8011d6:	50                   	push   %eax
  8011d7:	89 d8                	mov    %ebx,%eax
  8011d9:	03 45 0c             	add    0xc(%ebp),%eax
  8011dc:	50                   	push   %eax
  8011dd:	57                   	push   %edi
  8011de:	e8 49 ff ff ff       	call   80112c <read>
		if (m < 0)
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 04                	js     8011ee <readn+0x3b>
			return m;
		if (m == 0)
  8011ea:	75 dd                	jne    8011c9 <readn+0x16>
  8011ec:	eb 02                	jmp    8011f0 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011ee:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011f0:	89 d8                	mov    %ebx,%eax
  8011f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	56                   	push   %esi
  8011fe:	53                   	push   %ebx
  8011ff:	83 ec 18             	sub    $0x18,%esp
  801202:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801205:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801208:	50                   	push   %eax
  801209:	53                   	push   %ebx
  80120a:	e8 b9 fc ff ff       	call   800ec8 <fd_lookup>
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	78 37                	js     80124d <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801216:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801219:	83 ec 08             	sub    $0x8,%esp
  80121c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	ff 36                	push   (%esi)
  801222:	e8 f1 fc ff ff       	call   800f18 <dev_lookup>
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 1f                	js     80124d <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801232:	74 20                	je     801254 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801234:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801237:	8b 40 0c             	mov    0xc(%eax),%eax
  80123a:	85 c0                	test   %eax,%eax
  80123c:	74 37                	je     801275 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80123e:	83 ec 04             	sub    $0x4,%esp
  801241:	ff 75 10             	push   0x10(%ebp)
  801244:	ff 75 0c             	push   0xc(%ebp)
  801247:	56                   	push   %esi
  801248:	ff d0                	call   *%eax
  80124a:	83 c4 10             	add    $0x10,%esp
}
  80124d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801254:	a1 00 40 80 00       	mov    0x804000,%eax
  801259:	8b 40 48             	mov    0x48(%eax),%eax
  80125c:	83 ec 04             	sub    $0x4,%esp
  80125f:	53                   	push   %ebx
  801260:	50                   	push   %eax
  801261:	68 a5 21 80 00       	push   $0x8021a5
  801266:	e8 2b ef ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801273:	eb d8                	jmp    80124d <write+0x53>
		return -E_NOT_SUPP;
  801275:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80127a:	eb d1                	jmp    80124d <write+0x53>

0080127c <seek>:

int
seek(int fdnum, off_t offset)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	ff 75 08             	push   0x8(%ebp)
  801289:	e8 3a fc ff ff       	call   800ec8 <fd_lookup>
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	85 c0                	test   %eax,%eax
  801293:	78 0e                	js     8012a3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801295:	8b 55 0c             	mov    0xc(%ebp),%edx
  801298:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80129e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a3:	c9                   	leave  
  8012a4:	c3                   	ret    

008012a5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	56                   	push   %esi
  8012a9:	53                   	push   %ebx
  8012aa:	83 ec 18             	sub    $0x18,%esp
  8012ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	53                   	push   %ebx
  8012b5:	e8 0e fc ff ff       	call   800ec8 <fd_lookup>
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	78 34                	js     8012f5 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	ff 36                	push   (%esi)
  8012cd:	e8 46 fc ff ff       	call   800f18 <dev_lookup>
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 1c                	js     8012f5 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d9:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012dd:	74 1d                	je     8012fc <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e2:	8b 40 18             	mov    0x18(%eax),%eax
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	74 34                	je     80131d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	ff 75 0c             	push   0xc(%ebp)
  8012ef:	56                   	push   %esi
  8012f0:	ff d0                	call   *%eax
  8012f2:	83 c4 10             	add    $0x10,%esp
}
  8012f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f8:	5b                   	pop    %ebx
  8012f9:	5e                   	pop    %esi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012fc:	a1 00 40 80 00       	mov    0x804000,%eax
  801301:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801304:	83 ec 04             	sub    $0x4,%esp
  801307:	53                   	push   %ebx
  801308:	50                   	push   %eax
  801309:	68 68 21 80 00       	push   $0x802168
  80130e:	e8 83 ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131b:	eb d8                	jmp    8012f5 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80131d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801322:	eb d1                	jmp    8012f5 <ftruncate+0x50>

00801324 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	83 ec 18             	sub    $0x18,%esp
  80132c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	ff 75 08             	push   0x8(%ebp)
  801336:	e8 8d fb ff ff       	call   800ec8 <fd_lookup>
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 49                	js     80138b <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801342:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	ff 36                	push   (%esi)
  80134e:	e8 c5 fb ff ff       	call   800f18 <dev_lookup>
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 31                	js     80138b <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80135a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801361:	74 2f                	je     801392 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801363:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801366:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136d:	00 00 00 
	stat->st_isdir = 0;
  801370:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801377:	00 00 00 
	stat->st_dev = dev;
  80137a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	53                   	push   %ebx
  801384:	56                   	push   %esi
  801385:	ff 50 14             	call   *0x14(%eax)
  801388:	83 c4 10             	add    $0x10,%esp
}
  80138b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138e:	5b                   	pop    %ebx
  80138f:	5e                   	pop    %esi
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    
		return -E_NOT_SUPP;
  801392:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801397:	eb f2                	jmp    80138b <fstat+0x67>

00801399 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	56                   	push   %esi
  80139d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	6a 00                	push   $0x0
  8013a3:	ff 75 08             	push   0x8(%ebp)
  8013a6:	e8 e4 01 00 00       	call   80158f <open>
  8013ab:	89 c3                	mov    %eax,%ebx
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 1b                	js     8013cf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	ff 75 0c             	push   0xc(%ebp)
  8013ba:	50                   	push   %eax
  8013bb:	e8 64 ff ff ff       	call   801324 <fstat>
  8013c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8013c2:	89 1c 24             	mov    %ebx,(%esp)
  8013c5:	e8 26 fc ff ff       	call   800ff0 <close>
	return r;
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	89 f3                	mov    %esi,%ebx
}
  8013cf:	89 d8                	mov    %ebx,%eax
  8013d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5e                   	pop    %esi
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
  8013dd:	89 c6                	mov    %eax,%esi
  8013df:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8013e8:	74 27                	je     801411 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ea:	6a 07                	push   $0x7
  8013ec:	68 00 50 80 00       	push   $0x805000
  8013f1:	56                   	push   %esi
  8013f2:	ff 35 00 60 80 00    	push   0x806000
  8013f8:	e8 c7 f9 ff ff       	call   800dc4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013fd:	83 c4 0c             	add    $0xc,%esp
  801400:	6a 00                	push   $0x0
  801402:	53                   	push   %ebx
  801403:	6a 00                	push   $0x0
  801405:	e8 53 f9 ff ff       	call   800d5d <ipc_recv>
}
  80140a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801411:	83 ec 0c             	sub    $0xc,%esp
  801414:	6a 01                	push   $0x1
  801416:	e8 fd f9 ff ff       	call   800e18 <ipc_find_env>
  80141b:	a3 00 60 80 00       	mov    %eax,0x806000
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	eb c5                	jmp    8013ea <fsipc+0x12>

00801425 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80142b:	8b 45 08             	mov    0x8(%ebp),%eax
  80142e:	8b 40 0c             	mov    0xc(%eax),%eax
  801431:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801436:	8b 45 0c             	mov    0xc(%ebp),%eax
  801439:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80143e:	ba 00 00 00 00       	mov    $0x0,%edx
  801443:	b8 02 00 00 00       	mov    $0x2,%eax
  801448:	e8 8b ff ff ff       	call   8013d8 <fsipc>
}
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <devfile_flush>:
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801455:	8b 45 08             	mov    0x8(%ebp),%eax
  801458:	8b 40 0c             	mov    0xc(%eax),%eax
  80145b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801460:	ba 00 00 00 00       	mov    $0x0,%edx
  801465:	b8 06 00 00 00       	mov    $0x6,%eax
  80146a:	e8 69 ff ff ff       	call   8013d8 <fsipc>
}
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <devfile_stat>:
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	53                   	push   %ebx
  801475:	83 ec 04             	sub    $0x4,%esp
  801478:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80147b:	8b 45 08             	mov    0x8(%ebp),%eax
  80147e:	8b 40 0c             	mov    0xc(%eax),%eax
  801481:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801486:	ba 00 00 00 00       	mov    $0x0,%edx
  80148b:	b8 05 00 00 00       	mov    $0x5,%eax
  801490:	e8 43 ff ff ff       	call   8013d8 <fsipc>
  801495:	85 c0                	test   %eax,%eax
  801497:	78 2c                	js     8014c5 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	68 00 50 80 00       	push   $0x805000
  8014a1:	53                   	push   %ebx
  8014a2:	e8 c9 f2 ff ff       	call   800770 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a7:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b2:	a1 84 50 80 00       	mov    0x805084,%eax
  8014b7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <devfile_write>:
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8014d3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014d8:	39 d0                	cmp    %edx,%eax
  8014da:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014e9:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014ee:	50                   	push   %eax
  8014ef:	ff 75 0c             	push   0xc(%ebp)
  8014f2:	68 08 50 80 00       	push   $0x805008
  8014f7:	e8 0a f4 ff ff       	call   800906 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8014fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801501:	b8 04 00 00 00       	mov    $0x4,%eax
  801506:	e8 cd fe ff ff       	call   8013d8 <fsipc>
}
  80150b:	c9                   	leave  
  80150c:	c3                   	ret    

0080150d <devfile_read>:
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	56                   	push   %esi
  801511:	53                   	push   %ebx
  801512:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801515:	8b 45 08             	mov    0x8(%ebp),%eax
  801518:	8b 40 0c             	mov    0xc(%eax),%eax
  80151b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801520:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801526:	ba 00 00 00 00       	mov    $0x0,%edx
  80152b:	b8 03 00 00 00       	mov    $0x3,%eax
  801530:	e8 a3 fe ff ff       	call   8013d8 <fsipc>
  801535:	89 c3                	mov    %eax,%ebx
  801537:	85 c0                	test   %eax,%eax
  801539:	78 1f                	js     80155a <devfile_read+0x4d>
	assert(r <= n);
  80153b:	39 f0                	cmp    %esi,%eax
  80153d:	77 24                	ja     801563 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80153f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801544:	7f 33                	jg     801579 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801546:	83 ec 04             	sub    $0x4,%esp
  801549:	50                   	push   %eax
  80154a:	68 00 50 80 00       	push   $0x805000
  80154f:	ff 75 0c             	push   0xc(%ebp)
  801552:	e8 af f3 ff ff       	call   800906 <memmove>
	return r;
  801557:	83 c4 10             	add    $0x10,%esp
}
  80155a:	89 d8                	mov    %ebx,%eax
  80155c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155f:	5b                   	pop    %ebx
  801560:	5e                   	pop    %esi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    
	assert(r <= n);
  801563:	68 d4 21 80 00       	push   $0x8021d4
  801568:	68 db 21 80 00       	push   $0x8021db
  80156d:	6a 7c                	push   $0x7c
  80156f:	68 f0 21 80 00       	push   $0x8021f0
  801574:	e8 79 05 00 00       	call   801af2 <_panic>
	assert(r <= PGSIZE);
  801579:	68 fb 21 80 00       	push   $0x8021fb
  80157e:	68 db 21 80 00       	push   $0x8021db
  801583:	6a 7d                	push   $0x7d
  801585:	68 f0 21 80 00       	push   $0x8021f0
  80158a:	e8 63 05 00 00       	call   801af2 <_panic>

0080158f <open>:
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	56                   	push   %esi
  801593:	53                   	push   %ebx
  801594:	83 ec 1c             	sub    $0x1c,%esp
  801597:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80159a:	56                   	push   %esi
  80159b:	e8 95 f1 ff ff       	call   800735 <strlen>
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a8:	7f 6c                	jg     801616 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015aa:	83 ec 0c             	sub    $0xc,%esp
  8015ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	e8 c2 f8 ff ff       	call   800e78 <fd_alloc>
  8015b6:	89 c3                	mov    %eax,%ebx
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 3c                	js     8015fb <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	56                   	push   %esi
  8015c3:	68 00 50 80 00       	push   $0x805000
  8015c8:	e8 a3 f1 ff ff       	call   800770 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d0:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015dd:	e8 f6 fd ff ff       	call   8013d8 <fsipc>
  8015e2:	89 c3                	mov    %eax,%ebx
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 19                	js     801604 <open+0x75>
	return fd2num(fd);
  8015eb:	83 ec 0c             	sub    $0xc,%esp
  8015ee:	ff 75 f4             	push   -0xc(%ebp)
  8015f1:	e8 5b f8 ff ff       	call   800e51 <fd2num>
  8015f6:	89 c3                	mov    %eax,%ebx
  8015f8:	83 c4 10             	add    $0x10,%esp
}
  8015fb:	89 d8                	mov    %ebx,%eax
  8015fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801600:	5b                   	pop    %ebx
  801601:	5e                   	pop    %esi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    
		fd_close(fd, 0);
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	6a 00                	push   $0x0
  801609:	ff 75 f4             	push   -0xc(%ebp)
  80160c:	e8 58 f9 ff ff       	call   800f69 <fd_close>
		return r;
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	eb e5                	jmp    8015fb <open+0x6c>
		return -E_BAD_PATH;
  801616:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80161b:	eb de                	jmp    8015fb <open+0x6c>

0080161d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801623:	ba 00 00 00 00       	mov    $0x0,%edx
  801628:	b8 08 00 00 00       	mov    $0x8,%eax
  80162d:	e8 a6 fd ff ff       	call   8013d8 <fsipc>
}
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	56                   	push   %esi
  801638:	53                   	push   %ebx
  801639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80163c:	83 ec 0c             	sub    $0xc,%esp
  80163f:	ff 75 08             	push   0x8(%ebp)
  801642:	e8 1a f8 ff ff       	call   800e61 <fd2data>
  801647:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801649:	83 c4 08             	add    $0x8,%esp
  80164c:	68 07 22 80 00       	push   $0x802207
  801651:	53                   	push   %ebx
  801652:	e8 19 f1 ff ff       	call   800770 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801657:	8b 46 04             	mov    0x4(%esi),%eax
  80165a:	2b 06                	sub    (%esi),%eax
  80165c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801662:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801669:	00 00 00 
	stat->st_dev = &devpipe;
  80166c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801673:	30 80 00 
	return 0;
}
  801676:	b8 00 00 00 00       	mov    $0x0,%eax
  80167b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5e                   	pop    %esi
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80168c:	53                   	push   %ebx
  80168d:	6a 00                	push   $0x0
  80168f:	e8 5d f5 ff ff       	call   800bf1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801694:	89 1c 24             	mov    %ebx,(%esp)
  801697:	e8 c5 f7 ff ff       	call   800e61 <fd2data>
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	50                   	push   %eax
  8016a0:	6a 00                	push   $0x0
  8016a2:	e8 4a f5 ff ff       	call   800bf1 <sys_page_unmap>
}
  8016a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <_pipeisclosed>:
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	57                   	push   %edi
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 1c             	sub    $0x1c,%esp
  8016b5:	89 c7                	mov    %eax,%edi
  8016b7:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016b9:	a1 00 40 80 00       	mov    0x804000,%eax
  8016be:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016c1:	83 ec 0c             	sub    $0xc,%esp
  8016c4:	57                   	push   %edi
  8016c5:	e8 6e 04 00 00       	call   801b38 <pageref>
  8016ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016cd:	89 34 24             	mov    %esi,(%esp)
  8016d0:	e8 63 04 00 00       	call   801b38 <pageref>
		nn = thisenv->env_runs;
  8016d5:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8016db:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	39 cb                	cmp    %ecx,%ebx
  8016e3:	74 1b                	je     801700 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016e5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016e8:	75 cf                	jne    8016b9 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016ea:	8b 42 58             	mov    0x58(%edx),%eax
  8016ed:	6a 01                	push   $0x1
  8016ef:	50                   	push   %eax
  8016f0:	53                   	push   %ebx
  8016f1:	68 0e 22 80 00       	push   $0x80220e
  8016f6:	e8 9b ea ff ff       	call   800196 <cprintf>
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	eb b9                	jmp    8016b9 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801700:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801703:	0f 94 c0             	sete   %al
  801706:	0f b6 c0             	movzbl %al,%eax
}
  801709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170c:	5b                   	pop    %ebx
  80170d:	5e                   	pop    %esi
  80170e:	5f                   	pop    %edi
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    

00801711 <devpipe_write>:
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	57                   	push   %edi
  801715:	56                   	push   %esi
  801716:	53                   	push   %ebx
  801717:	83 ec 28             	sub    $0x28,%esp
  80171a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80171d:	56                   	push   %esi
  80171e:	e8 3e f7 ff ff       	call   800e61 <fd2data>
  801723:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	bf 00 00 00 00       	mov    $0x0,%edi
  80172d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801730:	75 09                	jne    80173b <devpipe_write+0x2a>
	return i;
  801732:	89 f8                	mov    %edi,%eax
  801734:	eb 23                	jmp    801759 <devpipe_write+0x48>
			sys_yield();
  801736:	e8 12 f4 ff ff       	call   800b4d <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80173b:	8b 43 04             	mov    0x4(%ebx),%eax
  80173e:	8b 0b                	mov    (%ebx),%ecx
  801740:	8d 51 20             	lea    0x20(%ecx),%edx
  801743:	39 d0                	cmp    %edx,%eax
  801745:	72 1a                	jb     801761 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801747:	89 da                	mov    %ebx,%edx
  801749:	89 f0                	mov    %esi,%eax
  80174b:	e8 5c ff ff ff       	call   8016ac <_pipeisclosed>
  801750:	85 c0                	test   %eax,%eax
  801752:	74 e2                	je     801736 <devpipe_write+0x25>
				return 0;
  801754:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801759:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175c:	5b                   	pop    %ebx
  80175d:	5e                   	pop    %esi
  80175e:	5f                   	pop    %edi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801761:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801764:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801768:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80176b:	89 c2                	mov    %eax,%edx
  80176d:	c1 fa 1f             	sar    $0x1f,%edx
  801770:	89 d1                	mov    %edx,%ecx
  801772:	c1 e9 1b             	shr    $0x1b,%ecx
  801775:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801778:	83 e2 1f             	and    $0x1f,%edx
  80177b:	29 ca                	sub    %ecx,%edx
  80177d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801781:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801785:	83 c0 01             	add    $0x1,%eax
  801788:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80178b:	83 c7 01             	add    $0x1,%edi
  80178e:	eb 9d                	jmp    80172d <devpipe_write+0x1c>

00801790 <devpipe_read>:
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	57                   	push   %edi
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	83 ec 18             	sub    $0x18,%esp
  801799:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80179c:	57                   	push   %edi
  80179d:	e8 bf f6 ff ff       	call   800e61 <fd2data>
  8017a2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	be 00 00 00 00       	mov    $0x0,%esi
  8017ac:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017af:	75 13                	jne    8017c4 <devpipe_read+0x34>
	return i;
  8017b1:	89 f0                	mov    %esi,%eax
  8017b3:	eb 02                	jmp    8017b7 <devpipe_read+0x27>
				return i;
  8017b5:	89 f0                	mov    %esi,%eax
}
  8017b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ba:	5b                   	pop    %ebx
  8017bb:	5e                   	pop    %esi
  8017bc:	5f                   	pop    %edi
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    
			sys_yield();
  8017bf:	e8 89 f3 ff ff       	call   800b4d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017c4:	8b 03                	mov    (%ebx),%eax
  8017c6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017c9:	75 18                	jne    8017e3 <devpipe_read+0x53>
			if (i > 0)
  8017cb:	85 f6                	test   %esi,%esi
  8017cd:	75 e6                	jne    8017b5 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8017cf:	89 da                	mov    %ebx,%edx
  8017d1:	89 f8                	mov    %edi,%eax
  8017d3:	e8 d4 fe ff ff       	call   8016ac <_pipeisclosed>
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	74 e3                	je     8017bf <devpipe_read+0x2f>
				return 0;
  8017dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e1:	eb d4                	jmp    8017b7 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017e3:	99                   	cltd   
  8017e4:	c1 ea 1b             	shr    $0x1b,%edx
  8017e7:	01 d0                	add    %edx,%eax
  8017e9:	83 e0 1f             	and    $0x1f,%eax
  8017ec:	29 d0                	sub    %edx,%eax
  8017ee:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017f9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017fc:	83 c6 01             	add    $0x1,%esi
  8017ff:	eb ab                	jmp    8017ac <devpipe_read+0x1c>

00801801 <pipe>:
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	56                   	push   %esi
  801805:	53                   	push   %ebx
  801806:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801809:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180c:	50                   	push   %eax
  80180d:	e8 66 f6 ff ff       	call   800e78 <fd_alloc>
  801812:	89 c3                	mov    %eax,%ebx
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	85 c0                	test   %eax,%eax
  801819:	0f 88 23 01 00 00    	js     801942 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181f:	83 ec 04             	sub    $0x4,%esp
  801822:	68 07 04 00 00       	push   $0x407
  801827:	ff 75 f4             	push   -0xc(%ebp)
  80182a:	6a 00                	push   $0x0
  80182c:	e8 3b f3 ff ff       	call   800b6c <sys_page_alloc>
  801831:	89 c3                	mov    %eax,%ebx
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	85 c0                	test   %eax,%eax
  801838:	0f 88 04 01 00 00    	js     801942 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80183e:	83 ec 0c             	sub    $0xc,%esp
  801841:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801844:	50                   	push   %eax
  801845:	e8 2e f6 ff ff       	call   800e78 <fd_alloc>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	0f 88 db 00 00 00    	js     801932 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801857:	83 ec 04             	sub    $0x4,%esp
  80185a:	68 07 04 00 00       	push   $0x407
  80185f:	ff 75 f0             	push   -0x10(%ebp)
  801862:	6a 00                	push   $0x0
  801864:	e8 03 f3 ff ff       	call   800b6c <sys_page_alloc>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 c0                	test   %eax,%eax
  801870:	0f 88 bc 00 00 00    	js     801932 <pipe+0x131>
	va = fd2data(fd0);
  801876:	83 ec 0c             	sub    $0xc,%esp
  801879:	ff 75 f4             	push   -0xc(%ebp)
  80187c:	e8 e0 f5 ff ff       	call   800e61 <fd2data>
  801881:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801883:	83 c4 0c             	add    $0xc,%esp
  801886:	68 07 04 00 00       	push   $0x407
  80188b:	50                   	push   %eax
  80188c:	6a 00                	push   $0x0
  80188e:	e8 d9 f2 ff ff       	call   800b6c <sys_page_alloc>
  801893:	89 c3                	mov    %eax,%ebx
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	85 c0                	test   %eax,%eax
  80189a:	0f 88 82 00 00 00    	js     801922 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a0:	83 ec 0c             	sub    $0xc,%esp
  8018a3:	ff 75 f0             	push   -0x10(%ebp)
  8018a6:	e8 b6 f5 ff ff       	call   800e61 <fd2data>
  8018ab:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018b2:	50                   	push   %eax
  8018b3:	6a 00                	push   $0x0
  8018b5:	56                   	push   %esi
  8018b6:	6a 00                	push   $0x0
  8018b8:	e8 f2 f2 ff ff       	call   800baf <sys_page_map>
  8018bd:	89 c3                	mov    %eax,%ebx
  8018bf:	83 c4 20             	add    $0x20,%esp
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	78 4e                	js     801914 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8018c6:	a1 20 30 80 00       	mov    0x803020,%eax
  8018cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ce:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8018d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8018da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018dd:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8018df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018e9:	83 ec 0c             	sub    $0xc,%esp
  8018ec:	ff 75 f4             	push   -0xc(%ebp)
  8018ef:	e8 5d f5 ff ff       	call   800e51 <fd2num>
  8018f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018f9:	83 c4 04             	add    $0x4,%esp
  8018fc:	ff 75 f0             	push   -0x10(%ebp)
  8018ff:	e8 4d f5 ff ff       	call   800e51 <fd2num>
  801904:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801907:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801912:	eb 2e                	jmp    801942 <pipe+0x141>
	sys_page_unmap(0, va);
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	56                   	push   %esi
  801918:	6a 00                	push   $0x0
  80191a:	e8 d2 f2 ff ff       	call   800bf1 <sys_page_unmap>
  80191f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	ff 75 f0             	push   -0x10(%ebp)
  801928:	6a 00                	push   $0x0
  80192a:	e8 c2 f2 ff ff       	call   800bf1 <sys_page_unmap>
  80192f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	ff 75 f4             	push   -0xc(%ebp)
  801938:	6a 00                	push   $0x0
  80193a:	e8 b2 f2 ff ff       	call   800bf1 <sys_page_unmap>
  80193f:	83 c4 10             	add    $0x10,%esp
}
  801942:	89 d8                	mov    %ebx,%eax
  801944:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801947:	5b                   	pop    %ebx
  801948:	5e                   	pop    %esi
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <pipeisclosed>:
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801951:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801954:	50                   	push   %eax
  801955:	ff 75 08             	push   0x8(%ebp)
  801958:	e8 6b f5 ff ff       	call   800ec8 <fd_lookup>
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	85 c0                	test   %eax,%eax
  801962:	78 18                	js     80197c <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801964:	83 ec 0c             	sub    $0xc,%esp
  801967:	ff 75 f4             	push   -0xc(%ebp)
  80196a:	e8 f2 f4 ff ff       	call   800e61 <fd2data>
  80196f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801971:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801974:	e8 33 fd ff ff       	call   8016ac <_pipeisclosed>
  801979:	83 c4 10             	add    $0x10,%esp
}
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80197e:	b8 00 00 00 00       	mov    $0x0,%eax
  801983:	c3                   	ret    

00801984 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80198a:	68 26 22 80 00       	push   $0x802226
  80198f:	ff 75 0c             	push   0xc(%ebp)
  801992:	e8 d9 ed ff ff       	call   800770 <strcpy>
	return 0;
}
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devcons_write>:
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	57                   	push   %edi
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019aa:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019af:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019b5:	eb 2e                	jmp    8019e5 <devcons_write+0x47>
		m = n - tot;
  8019b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019ba:	29 f3                	sub    %esi,%ebx
  8019bc:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8019c1:	39 c3                	cmp    %eax,%ebx
  8019c3:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019c6:	83 ec 04             	sub    $0x4,%esp
  8019c9:	53                   	push   %ebx
  8019ca:	89 f0                	mov    %esi,%eax
  8019cc:	03 45 0c             	add    0xc(%ebp),%eax
  8019cf:	50                   	push   %eax
  8019d0:	57                   	push   %edi
  8019d1:	e8 30 ef ff ff       	call   800906 <memmove>
		sys_cputs(buf, m);
  8019d6:	83 c4 08             	add    $0x8,%esp
  8019d9:	53                   	push   %ebx
  8019da:	57                   	push   %edi
  8019db:	e8 d0 f0 ff ff       	call   800ab0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019e0:	01 de                	add    %ebx,%esi
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019e8:	72 cd                	jb     8019b7 <devcons_write+0x19>
}
  8019ea:	89 f0                	mov    %esi,%eax
  8019ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5f                   	pop    %edi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    

008019f4 <devcons_read>:
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	83 ec 08             	sub    $0x8,%esp
  8019fa:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8019ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a03:	75 07                	jne    801a0c <devcons_read+0x18>
  801a05:	eb 1f                	jmp    801a26 <devcons_read+0x32>
		sys_yield();
  801a07:	e8 41 f1 ff ff       	call   800b4d <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a0c:	e8 bd f0 ff ff       	call   800ace <sys_cgetc>
  801a11:	85 c0                	test   %eax,%eax
  801a13:	74 f2                	je     801a07 <devcons_read+0x13>
	if (c < 0)
  801a15:	78 0f                	js     801a26 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801a17:	83 f8 04             	cmp    $0x4,%eax
  801a1a:	74 0c                	je     801a28 <devcons_read+0x34>
	*(char*)vbuf = c;
  801a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1f:	88 02                	mov    %al,(%edx)
	return 1;
  801a21:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    
		return 0;
  801a28:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2d:	eb f7                	jmp    801a26 <devcons_read+0x32>

00801a2f <cputchar>:
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a35:	8b 45 08             	mov    0x8(%ebp),%eax
  801a38:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a3b:	6a 01                	push   $0x1
  801a3d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a40:	50                   	push   %eax
  801a41:	e8 6a f0 ff ff       	call   800ab0 <sys_cputs>
}
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <getchar>:
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a51:	6a 01                	push   $0x1
  801a53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a56:	50                   	push   %eax
  801a57:	6a 00                	push   $0x0
  801a59:	e8 ce f6 ff ff       	call   80112c <read>
	if (r < 0)
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	85 c0                	test   %eax,%eax
  801a63:	78 06                	js     801a6b <getchar+0x20>
	if (r < 1)
  801a65:	74 06                	je     801a6d <getchar+0x22>
	return c;
  801a67:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    
		return -E_EOF;
  801a6d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a72:	eb f7                	jmp    801a6b <getchar+0x20>

00801a74 <iscons>:
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7d:	50                   	push   %eax
  801a7e:	ff 75 08             	push   0x8(%ebp)
  801a81:	e8 42 f4 ff ff       	call   800ec8 <fd_lookup>
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 11                	js     801a9e <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a90:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a96:	39 10                	cmp    %edx,(%eax)
  801a98:	0f 94 c0             	sete   %al
  801a9b:	0f b6 c0             	movzbl %al,%eax
}
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <opencons>:
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801aa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa9:	50                   	push   %eax
  801aaa:	e8 c9 f3 ff ff       	call   800e78 <fd_alloc>
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 3a                	js     801af0 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab6:	83 ec 04             	sub    $0x4,%esp
  801ab9:	68 07 04 00 00       	push   $0x407
  801abe:	ff 75 f4             	push   -0xc(%ebp)
  801ac1:	6a 00                	push   $0x0
  801ac3:	e8 a4 f0 ff ff       	call   800b6c <sys_page_alloc>
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	85 c0                	test   %eax,%eax
  801acd:	78 21                	js     801af0 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801add:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	50                   	push   %eax
  801ae8:	e8 64 f3 ff ff       	call   800e51 <fd2num>
  801aed:	83 c4 10             	add    $0x10,%esp
}
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801af7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801afa:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b00:	e8 29 f0 ff ff       	call   800b2e <sys_getenvid>
  801b05:	83 ec 0c             	sub    $0xc,%esp
  801b08:	ff 75 0c             	push   0xc(%ebp)
  801b0b:	ff 75 08             	push   0x8(%ebp)
  801b0e:	56                   	push   %esi
  801b0f:	50                   	push   %eax
  801b10:	68 34 22 80 00       	push   $0x802234
  801b15:	e8 7c e6 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b1a:	83 c4 18             	add    $0x18,%esp
  801b1d:	53                   	push   %ebx
  801b1e:	ff 75 10             	push   0x10(%ebp)
  801b21:	e8 1f e6 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  801b26:	c7 04 24 1f 22 80 00 	movl   $0x80221f,(%esp)
  801b2d:	e8 64 e6 ff ff       	call   800196 <cprintf>
  801b32:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b35:	cc                   	int3   
  801b36:	eb fd                	jmp    801b35 <_panic+0x43>

00801b38 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3e:	89 c2                	mov    %eax,%edx
  801b40:	c1 ea 16             	shr    $0x16,%edx
  801b43:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b4a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b4f:	f6 c1 01             	test   $0x1,%cl
  801b52:	74 1c                	je     801b70 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801b54:	c1 e8 0c             	shr    $0xc,%eax
  801b57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b5e:	a8 01                	test   $0x1,%al
  801b60:	74 0e                	je     801b70 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b62:	c1 e8 0c             	shr    $0xc,%eax
  801b65:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b6c:	ef 
  801b6d:	0f b7 d2             	movzwl %dx,%edx
}
  801b70:	89 d0                	mov    %edx,%eax
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    
  801b74:	66 90                	xchg   %ax,%ax
  801b76:	66 90                	xchg   %ax,%ax
  801b78:	66 90                	xchg   %ax,%ax
  801b7a:	66 90                	xchg   %ax,%ax
  801b7c:	66 90                	xchg   %ax,%ax
  801b7e:	66 90                	xchg   %ax,%ax

00801b80 <__udivdi3>:
  801b80:	f3 0f 1e fb          	endbr32 
  801b84:	55                   	push   %ebp
  801b85:	57                   	push   %edi
  801b86:	56                   	push   %esi
  801b87:	53                   	push   %ebx
  801b88:	83 ec 1c             	sub    $0x1c,%esp
  801b8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b8f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b93:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b97:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	75 19                	jne    801bb8 <__udivdi3+0x38>
  801b9f:	39 f3                	cmp    %esi,%ebx
  801ba1:	76 4d                	jbe    801bf0 <__udivdi3+0x70>
  801ba3:	31 ff                	xor    %edi,%edi
  801ba5:	89 e8                	mov    %ebp,%eax
  801ba7:	89 f2                	mov    %esi,%edx
  801ba9:	f7 f3                	div    %ebx
  801bab:	89 fa                	mov    %edi,%edx
  801bad:	83 c4 1c             	add    $0x1c,%esp
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	5f                   	pop    %edi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    
  801bb5:	8d 76 00             	lea    0x0(%esi),%esi
  801bb8:	39 f0                	cmp    %esi,%eax
  801bba:	76 14                	jbe    801bd0 <__udivdi3+0x50>
  801bbc:	31 ff                	xor    %edi,%edi
  801bbe:	31 c0                	xor    %eax,%eax
  801bc0:	89 fa                	mov    %edi,%edx
  801bc2:	83 c4 1c             	add    $0x1c,%esp
  801bc5:	5b                   	pop    %ebx
  801bc6:	5e                   	pop    %esi
  801bc7:	5f                   	pop    %edi
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    
  801bca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bd0:	0f bd f8             	bsr    %eax,%edi
  801bd3:	83 f7 1f             	xor    $0x1f,%edi
  801bd6:	75 48                	jne    801c20 <__udivdi3+0xa0>
  801bd8:	39 f0                	cmp    %esi,%eax
  801bda:	72 06                	jb     801be2 <__udivdi3+0x62>
  801bdc:	31 c0                	xor    %eax,%eax
  801bde:	39 eb                	cmp    %ebp,%ebx
  801be0:	77 de                	ja     801bc0 <__udivdi3+0x40>
  801be2:	b8 01 00 00 00       	mov    $0x1,%eax
  801be7:	eb d7                	jmp    801bc0 <__udivdi3+0x40>
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	89 d9                	mov    %ebx,%ecx
  801bf2:	85 db                	test   %ebx,%ebx
  801bf4:	75 0b                	jne    801c01 <__udivdi3+0x81>
  801bf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfb:	31 d2                	xor    %edx,%edx
  801bfd:	f7 f3                	div    %ebx
  801bff:	89 c1                	mov    %eax,%ecx
  801c01:	31 d2                	xor    %edx,%edx
  801c03:	89 f0                	mov    %esi,%eax
  801c05:	f7 f1                	div    %ecx
  801c07:	89 c6                	mov    %eax,%esi
  801c09:	89 e8                	mov    %ebp,%eax
  801c0b:	89 f7                	mov    %esi,%edi
  801c0d:	f7 f1                	div    %ecx
  801c0f:	89 fa                	mov    %edi,%edx
  801c11:	83 c4 1c             	add    $0x1c,%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5f                   	pop    %edi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	89 f9                	mov    %edi,%ecx
  801c22:	ba 20 00 00 00       	mov    $0x20,%edx
  801c27:	29 fa                	sub    %edi,%edx
  801c29:	d3 e0                	shl    %cl,%eax
  801c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c2f:	89 d1                	mov    %edx,%ecx
  801c31:	89 d8                	mov    %ebx,%eax
  801c33:	d3 e8                	shr    %cl,%eax
  801c35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c39:	09 c1                	or     %eax,%ecx
  801c3b:	89 f0                	mov    %esi,%eax
  801c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e3                	shl    %cl,%ebx
  801c45:	89 d1                	mov    %edx,%ecx
  801c47:	d3 e8                	shr    %cl,%eax
  801c49:	89 f9                	mov    %edi,%ecx
  801c4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c4f:	89 eb                	mov    %ebp,%ebx
  801c51:	d3 e6                	shl    %cl,%esi
  801c53:	89 d1                	mov    %edx,%ecx
  801c55:	d3 eb                	shr    %cl,%ebx
  801c57:	09 f3                	or     %esi,%ebx
  801c59:	89 c6                	mov    %eax,%esi
  801c5b:	89 f2                	mov    %esi,%edx
  801c5d:	89 d8                	mov    %ebx,%eax
  801c5f:	f7 74 24 08          	divl   0x8(%esp)
  801c63:	89 d6                	mov    %edx,%esi
  801c65:	89 c3                	mov    %eax,%ebx
  801c67:	f7 64 24 0c          	mull   0xc(%esp)
  801c6b:	39 d6                	cmp    %edx,%esi
  801c6d:	72 19                	jb     801c88 <__udivdi3+0x108>
  801c6f:	89 f9                	mov    %edi,%ecx
  801c71:	d3 e5                	shl    %cl,%ebp
  801c73:	39 c5                	cmp    %eax,%ebp
  801c75:	73 04                	jae    801c7b <__udivdi3+0xfb>
  801c77:	39 d6                	cmp    %edx,%esi
  801c79:	74 0d                	je     801c88 <__udivdi3+0x108>
  801c7b:	89 d8                	mov    %ebx,%eax
  801c7d:	31 ff                	xor    %edi,%edi
  801c7f:	e9 3c ff ff ff       	jmp    801bc0 <__udivdi3+0x40>
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c8b:	31 ff                	xor    %edi,%edi
  801c8d:	e9 2e ff ff ff       	jmp    801bc0 <__udivdi3+0x40>
  801c92:	66 90                	xchg   %ax,%ax
  801c94:	66 90                	xchg   %ax,%ax
  801c96:	66 90                	xchg   %ax,%ax
  801c98:	66 90                	xchg   %ax,%ax
  801c9a:	66 90                	xchg   %ax,%ax
  801c9c:	66 90                	xchg   %ax,%ax
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__umoddi3>:
  801ca0:	f3 0f 1e fb          	endbr32 
  801ca4:	55                   	push   %ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 1c             	sub    $0x1c,%esp
  801cab:	8b 74 24 30          	mov    0x30(%esp),%esi
  801caf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cb3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801cb7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801cbb:	89 f0                	mov    %esi,%eax
  801cbd:	89 da                	mov    %ebx,%edx
  801cbf:	85 ff                	test   %edi,%edi
  801cc1:	75 15                	jne    801cd8 <__umoddi3+0x38>
  801cc3:	39 dd                	cmp    %ebx,%ebp
  801cc5:	76 39                	jbe    801d00 <__umoddi3+0x60>
  801cc7:	f7 f5                	div    %ebp
  801cc9:	89 d0                	mov    %edx,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	39 df                	cmp    %ebx,%edi
  801cda:	77 f1                	ja     801ccd <__umoddi3+0x2d>
  801cdc:	0f bd cf             	bsr    %edi,%ecx
  801cdf:	83 f1 1f             	xor    $0x1f,%ecx
  801ce2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ce6:	75 40                	jne    801d28 <__umoddi3+0x88>
  801ce8:	39 df                	cmp    %ebx,%edi
  801cea:	72 04                	jb     801cf0 <__umoddi3+0x50>
  801cec:	39 f5                	cmp    %esi,%ebp
  801cee:	77 dd                	ja     801ccd <__umoddi3+0x2d>
  801cf0:	89 da                	mov    %ebx,%edx
  801cf2:	89 f0                	mov    %esi,%eax
  801cf4:	29 e8                	sub    %ebp,%eax
  801cf6:	19 fa                	sbb    %edi,%edx
  801cf8:	eb d3                	jmp    801ccd <__umoddi3+0x2d>
  801cfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d00:	89 e9                	mov    %ebp,%ecx
  801d02:	85 ed                	test   %ebp,%ebp
  801d04:	75 0b                	jne    801d11 <__umoddi3+0x71>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f5                	div    %ebp
  801d0f:	89 c1                	mov    %eax,%ecx
  801d11:	89 d8                	mov    %ebx,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f1                	div    %ecx
  801d17:	89 f0                	mov    %esi,%eax
  801d19:	f7 f1                	div    %ecx
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	eb ac                	jmp    801ccd <__umoddi3+0x2d>
  801d21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d28:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d2c:	ba 20 00 00 00       	mov    $0x20,%edx
  801d31:	29 c2                	sub    %eax,%edx
  801d33:	89 c1                	mov    %eax,%ecx
  801d35:	89 e8                	mov    %ebp,%eax
  801d37:	d3 e7                	shl    %cl,%edi
  801d39:	89 d1                	mov    %edx,%ecx
  801d3b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d3f:	d3 e8                	shr    %cl,%eax
  801d41:	89 c1                	mov    %eax,%ecx
  801d43:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d47:	09 f9                	or     %edi,%ecx
  801d49:	89 df                	mov    %ebx,%edi
  801d4b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d4f:	89 c1                	mov    %eax,%ecx
  801d51:	d3 e5                	shl    %cl,%ebp
  801d53:	89 d1                	mov    %edx,%ecx
  801d55:	d3 ef                	shr    %cl,%edi
  801d57:	89 c1                	mov    %eax,%ecx
  801d59:	89 f0                	mov    %esi,%eax
  801d5b:	d3 e3                	shl    %cl,%ebx
  801d5d:	89 d1                	mov    %edx,%ecx
  801d5f:	89 fa                	mov    %edi,%edx
  801d61:	d3 e8                	shr    %cl,%eax
  801d63:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d68:	09 d8                	or     %ebx,%eax
  801d6a:	f7 74 24 08          	divl   0x8(%esp)
  801d6e:	89 d3                	mov    %edx,%ebx
  801d70:	d3 e6                	shl    %cl,%esi
  801d72:	f7 e5                	mul    %ebp
  801d74:	89 c7                	mov    %eax,%edi
  801d76:	89 d1                	mov    %edx,%ecx
  801d78:	39 d3                	cmp    %edx,%ebx
  801d7a:	72 06                	jb     801d82 <__umoddi3+0xe2>
  801d7c:	75 0e                	jne    801d8c <__umoddi3+0xec>
  801d7e:	39 c6                	cmp    %eax,%esi
  801d80:	73 0a                	jae    801d8c <__umoddi3+0xec>
  801d82:	29 e8                	sub    %ebp,%eax
  801d84:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d88:	89 d1                	mov    %edx,%ecx
  801d8a:	89 c7                	mov    %eax,%edi
  801d8c:	89 f5                	mov    %esi,%ebp
  801d8e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d92:	29 fd                	sub    %edi,%ebp
  801d94:	19 cb                	sbb    %ecx,%ebx
  801d96:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d9b:	89 d8                	mov    %ebx,%eax
  801d9d:	d3 e0                	shl    %cl,%eax
  801d9f:	89 f1                	mov    %esi,%ecx
  801da1:	d3 ed                	shr    %cl,%ebp
  801da3:	d3 eb                	shr    %cl,%ebx
  801da5:	09 e8                	or     %ebp,%eax
  801da7:	89 da                	mov    %ebx,%edx
  801da9:	83 c4 1c             	add    $0x1c,%esp
  801dac:	5b                   	pop    %ebx
  801dad:	5e                   	pop    %esi
  801dae:	5f                   	pop    %edi
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    
