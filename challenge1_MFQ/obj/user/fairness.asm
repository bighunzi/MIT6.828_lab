
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
  80003b:	e8 f1 0a 00 00       	call   800b31 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 00 40 80 00 8c 	cmpl   $0xeec0008c,0x804000
  800049:	00 c0 ee 
  80004c:	74 2d                	je     80007b <umain+0x48>
		while (1) {
			ipc_recv(&who, 0, 0);
			cprintf("%x recv from %x\n", id, who);
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  80004e:	a1 e4 00 c0 ee       	mov    0xeec000e4,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	53                   	push   %ebx
  800058:	68 b1 22 80 00       	push   $0x8022b1
  80005d:	e8 37 01 00 00       	call   800199 <cprintf>
  800062:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800065:	a1 e4 00 c0 ee       	mov    0xeec000e4,%eax
  80006a:	6a 00                	push   $0x0
  80006c:	6a 00                	push   $0x0
  80006e:	6a 00                	push   $0x0
  800070:	50                   	push   %eax
  800071:	e8 bb 0d 00 00       	call   800e31 <ipc_send>
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	eb ea                	jmp    800065 <umain+0x32>
			ipc_recv(&who, 0, 0);
  80007b:	8d 75 f4             	lea    -0xc(%ebp),%esi
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	6a 00                	push   $0x0
  800083:	6a 00                	push   $0x0
  800085:	56                   	push   %esi
  800086:	e8 36 0d 00 00       	call   800dc1 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008b:	83 c4 0c             	add    $0xc,%esp
  80008e:	ff 75 f4             	push   -0xc(%ebp)
  800091:	53                   	push   %ebx
  800092:	68 a0 22 80 00       	push   $0x8022a0
  800097:	e8 fd 00 00 00       	call   800199 <cprintf>
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
  8000ac:	e8 80 0a 00 00       	call   800b31 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8000bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c1:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c6:	85 db                	test   %ebx,%ebx
  8000c8:	7e 07                	jle    8000d1 <libmain+0x30>
		binaryname = argv[0];
  8000ca:	8b 06                	mov    (%esi),%eax
  8000cc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d1:	83 ec 08             	sub    $0x8,%esp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	e8 58 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000db:	e8 0a 00 00 00       	call   8000ea <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f0:	e8 a0 0f 00 00       	call   801095 <close_all>
	sys_env_destroy(0);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	6a 00                	push   $0x0
  8000fa:	e8 f1 09 00 00       	call   800af0 <sys_env_destroy>
}
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 13                	mov    (%ebx),%edx
  800110:	8d 42 01             	lea    0x1(%edx),%eax
  800113:	89 03                	mov    %eax,(%ebx)
  800115:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800118:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	74 09                	je     80012c <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800123:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800127:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	68 ff 00 00 00       	push   $0xff
  800134:	8d 43 08             	lea    0x8(%ebx),%eax
  800137:	50                   	push   %eax
  800138:	e8 76 09 00 00       	call   800ab3 <sys_cputs>
		b->idx = 0;
  80013d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	eb db                	jmp    800123 <putch+0x1f>

00800148 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800151:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800158:	00 00 00 
	b.cnt = 0;
  80015b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800162:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800165:	ff 75 0c             	push   0xc(%ebp)
  800168:	ff 75 08             	push   0x8(%ebp)
  80016b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800171:	50                   	push   %eax
  800172:	68 04 01 80 00       	push   $0x800104
  800177:	e8 14 01 00 00       	call   800290 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017c:	83 c4 08             	add    $0x8,%esp
  80017f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800185:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018b:	50                   	push   %eax
  80018c:	e8 22 09 00 00       	call   800ab3 <sys_cputs>

	return b.cnt;
}
  800191:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a2:	50                   	push   %eax
  8001a3:	ff 75 08             	push   0x8(%ebp)
  8001a6:	e8 9d ff ff ff       	call   800148 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 1c             	sub    $0x1c,%esp
  8001b6:	89 c7                	mov    %eax,%edi
  8001b8:	89 d6                	mov    %edx,%esi
  8001ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c0:	89 d1                	mov    %edx,%ecx
  8001c2:	89 c2                	mov    %eax,%edx
  8001c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001da:	39 c2                	cmp    %eax,%edx
  8001dc:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001df:	72 3e                	jb     80021f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e1:	83 ec 0c             	sub    $0xc,%esp
  8001e4:	ff 75 18             	push   0x18(%ebp)
  8001e7:	83 eb 01             	sub    $0x1,%ebx
  8001ea:	53                   	push   %ebx
  8001eb:	50                   	push   %eax
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	ff 75 e4             	push   -0x1c(%ebp)
  8001f2:	ff 75 e0             	push   -0x20(%ebp)
  8001f5:	ff 75 dc             	push   -0x24(%ebp)
  8001f8:	ff 75 d8             	push   -0x28(%ebp)
  8001fb:	e8 60 1e 00 00       	call   802060 <__udivdi3>
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	52                   	push   %edx
  800204:	50                   	push   %eax
  800205:	89 f2                	mov    %esi,%edx
  800207:	89 f8                	mov    %edi,%eax
  800209:	e8 9f ff ff ff       	call   8001ad <printnum>
  80020e:	83 c4 20             	add    $0x20,%esp
  800211:	eb 13                	jmp    800226 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800213:	83 ec 08             	sub    $0x8,%esp
  800216:	56                   	push   %esi
  800217:	ff 75 18             	push   0x18(%ebp)
  80021a:	ff d7                	call   *%edi
  80021c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021f:	83 eb 01             	sub    $0x1,%ebx
  800222:	85 db                	test   %ebx,%ebx
  800224:	7f ed                	jg     800213 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800226:	83 ec 08             	sub    $0x8,%esp
  800229:	56                   	push   %esi
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	ff 75 e4             	push   -0x1c(%ebp)
  800230:	ff 75 e0             	push   -0x20(%ebp)
  800233:	ff 75 dc             	push   -0x24(%ebp)
  800236:	ff 75 d8             	push   -0x28(%ebp)
  800239:	e8 42 1f 00 00       	call   802180 <__umoddi3>
  80023e:	83 c4 14             	add    $0x14,%esp
  800241:	0f be 80 d2 22 80 00 	movsbl 0x8022d2(%eax),%eax
  800248:	50                   	push   %eax
  800249:	ff d7                	call   *%edi
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800260:	8b 10                	mov    (%eax),%edx
  800262:	3b 50 04             	cmp    0x4(%eax),%edx
  800265:	73 0a                	jae    800271 <sprintputch+0x1b>
		*b->buf++ = ch;
  800267:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026a:	89 08                	mov    %ecx,(%eax)
  80026c:	8b 45 08             	mov    0x8(%ebp),%eax
  80026f:	88 02                	mov    %al,(%edx)
}
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <printfmt>:
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800279:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027c:	50                   	push   %eax
  80027d:	ff 75 10             	push   0x10(%ebp)
  800280:	ff 75 0c             	push   0xc(%ebp)
  800283:	ff 75 08             	push   0x8(%ebp)
  800286:	e8 05 00 00 00       	call   800290 <vprintfmt>
}
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <vprintfmt>:
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 3c             	sub    $0x3c,%esp
  800299:	8b 75 08             	mov    0x8(%ebp),%esi
  80029c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029f:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a2:	eb 0a                	jmp    8002ae <vprintfmt+0x1e>
			putch(ch, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	53                   	push   %ebx
  8002a8:	50                   	push   %eax
  8002a9:	ff d6                	call   *%esi
  8002ab:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ae:	83 c7 01             	add    $0x1,%edi
  8002b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b5:	83 f8 25             	cmp    $0x25,%eax
  8002b8:	74 0c                	je     8002c6 <vprintfmt+0x36>
			if (ch == '\0')
  8002ba:	85 c0                	test   %eax,%eax
  8002bc:	75 e6                	jne    8002a4 <vprintfmt+0x14>
}
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    
		padc = ' ';
  8002c6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002ca:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e4:	8d 47 01             	lea    0x1(%edi),%eax
  8002e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ea:	0f b6 17             	movzbl (%edi),%edx
  8002ed:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f0:	3c 55                	cmp    $0x55,%al
  8002f2:	0f 87 bb 03 00 00    	ja     8006b3 <vprintfmt+0x423>
  8002f8:	0f b6 c0             	movzbl %al,%eax
  8002fb:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  800302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800305:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800309:	eb d9                	jmp    8002e4 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800312:	eb d0                	jmp    8002e4 <vprintfmt+0x54>
  800314:	0f b6 d2             	movzbl %dl,%edx
  800317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80031a:	b8 00 00 00 00       	mov    $0x0,%eax
  80031f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800322:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800325:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800329:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80032c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032f:	83 f9 09             	cmp    $0x9,%ecx
  800332:	77 55                	ja     800389 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800334:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800337:	eb e9                	jmp    800322 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800339:	8b 45 14             	mov    0x14(%ebp),%eax
  80033c:	8b 00                	mov    (%eax),%eax
  80033e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800341:	8b 45 14             	mov    0x14(%ebp),%eax
  800344:	8d 40 04             	lea    0x4(%eax),%eax
  800347:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80034d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800351:	79 91                	jns    8002e4 <vprintfmt+0x54>
				width = precision, precision = -1;
  800353:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800356:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800359:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800360:	eb 82                	jmp    8002e4 <vprintfmt+0x54>
  800362:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800365:	85 d2                	test   %edx,%edx
  800367:	b8 00 00 00 00       	mov    $0x0,%eax
  80036c:	0f 49 c2             	cmovns %edx,%eax
  80036f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800375:	e9 6a ff ff ff       	jmp    8002e4 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80037d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800384:	e9 5b ff ff ff       	jmp    8002e4 <vprintfmt+0x54>
  800389:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80038c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038f:	eb bc                	jmp    80034d <vprintfmt+0xbd>
			lflag++;
  800391:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800397:	e9 48 ff ff ff       	jmp    8002e4 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80039c:	8b 45 14             	mov    0x14(%ebp),%eax
  80039f:	8d 78 04             	lea    0x4(%eax),%edi
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	53                   	push   %ebx
  8003a6:	ff 30                	push   (%eax)
  8003a8:	ff d6                	call   *%esi
			break;
  8003aa:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003ad:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b0:	e9 9d 02 00 00       	jmp    800652 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 78 04             	lea    0x4(%eax),%edi
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	89 d0                	mov    %edx,%eax
  8003bf:	f7 d8                	neg    %eax
  8003c1:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c4:	83 f8 0f             	cmp    $0xf,%eax
  8003c7:	7f 23                	jg     8003ec <vprintfmt+0x15c>
  8003c9:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  8003d0:	85 d2                	test   %edx,%edx
  8003d2:	74 18                	je     8003ec <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003d4:	52                   	push   %edx
  8003d5:	68 d1 26 80 00       	push   $0x8026d1
  8003da:	53                   	push   %ebx
  8003db:	56                   	push   %esi
  8003dc:	e8 92 fe ff ff       	call   800273 <printfmt>
  8003e1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e7:	e9 66 02 00 00       	jmp    800652 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003ec:	50                   	push   %eax
  8003ed:	68 ea 22 80 00       	push   $0x8022ea
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	e8 7a fe ff ff       	call   800273 <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003ff:	e9 4e 02 00 00       	jmp    800652 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	83 c0 04             	add    $0x4,%eax
  80040a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800412:	85 d2                	test   %edx,%edx
  800414:	b8 e3 22 80 00       	mov    $0x8022e3,%eax
  800419:	0f 45 c2             	cmovne %edx,%eax
  80041c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80041f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800423:	7e 06                	jle    80042b <vprintfmt+0x19b>
  800425:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800429:	75 0d                	jne    800438 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80042e:	89 c7                	mov    %eax,%edi
  800430:	03 45 e0             	add    -0x20(%ebp),%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800436:	eb 55                	jmp    80048d <vprintfmt+0x1fd>
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	ff 75 d8             	push   -0x28(%ebp)
  80043e:	ff 75 cc             	push   -0x34(%ebp)
  800441:	e8 0a 03 00 00       	call   800750 <strnlen>
  800446:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800449:	29 c1                	sub    %eax,%ecx
  80044b:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800453:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80045a:	eb 0f                	jmp    80046b <vprintfmt+0x1db>
					putch(padc, putdat);
  80045c:	83 ec 08             	sub    $0x8,%esp
  80045f:	53                   	push   %ebx
  800460:	ff 75 e0             	push   -0x20(%ebp)
  800463:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800465:	83 ef 01             	sub    $0x1,%edi
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	85 ff                	test   %edi,%edi
  80046d:	7f ed                	jg     80045c <vprintfmt+0x1cc>
  80046f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800472:	85 d2                	test   %edx,%edx
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	0f 49 c2             	cmovns %edx,%eax
  80047c:	29 c2                	sub    %eax,%edx
  80047e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800481:	eb a8                	jmp    80042b <vprintfmt+0x19b>
					putch(ch, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	53                   	push   %ebx
  800487:	52                   	push   %edx
  800488:	ff d6                	call   *%esi
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800490:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800492:	83 c7 01             	add    $0x1,%edi
  800495:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800499:	0f be d0             	movsbl %al,%edx
  80049c:	85 d2                	test   %edx,%edx
  80049e:	74 4b                	je     8004eb <vprintfmt+0x25b>
  8004a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a4:	78 06                	js     8004ac <vprintfmt+0x21c>
  8004a6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004aa:	78 1e                	js     8004ca <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ac:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b0:	74 d1                	je     800483 <vprintfmt+0x1f3>
  8004b2:	0f be c0             	movsbl %al,%eax
  8004b5:	83 e8 20             	sub    $0x20,%eax
  8004b8:	83 f8 5e             	cmp    $0x5e,%eax
  8004bb:	76 c6                	jbe    800483 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	53                   	push   %ebx
  8004c1:	6a 3f                	push   $0x3f
  8004c3:	ff d6                	call   *%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb c3                	jmp    80048d <vprintfmt+0x1fd>
  8004ca:	89 cf                	mov    %ecx,%edi
  8004cc:	eb 0e                	jmp    8004dc <vprintfmt+0x24c>
				putch(' ', putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	6a 20                	push   $0x20
  8004d4:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004d6:	83 ef 01             	sub    $0x1,%edi
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	85 ff                	test   %edi,%edi
  8004de:	7f ee                	jg     8004ce <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e6:	e9 67 01 00 00       	jmp    800652 <vprintfmt+0x3c2>
  8004eb:	89 cf                	mov    %ecx,%edi
  8004ed:	eb ed                	jmp    8004dc <vprintfmt+0x24c>
	if (lflag >= 2)
  8004ef:	83 f9 01             	cmp    $0x1,%ecx
  8004f2:	7f 1b                	jg     80050f <vprintfmt+0x27f>
	else if (lflag)
  8004f4:	85 c9                	test   %ecx,%ecx
  8004f6:	74 63                	je     80055b <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800500:	99                   	cltd   
  800501:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 40 04             	lea    0x4(%eax),%eax
  80050a:	89 45 14             	mov    %eax,0x14(%ebp)
  80050d:	eb 17                	jmp    800526 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8b 50 04             	mov    0x4(%eax),%edx
  800515:	8b 00                	mov    (%eax),%eax
  800517:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 40 08             	lea    0x8(%eax),%eax
  800523:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800526:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800529:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80052c:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800531:	85 c9                	test   %ecx,%ecx
  800533:	0f 89 ff 00 00 00    	jns    800638 <vprintfmt+0x3a8>
				putch('-', putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	53                   	push   %ebx
  80053d:	6a 2d                	push   $0x2d
  80053f:	ff d6                	call   *%esi
				num = -(long long) num;
  800541:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800544:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800547:	f7 da                	neg    %edx
  800549:	83 d1 00             	adc    $0x0,%ecx
  80054c:	f7 d9                	neg    %ecx
  80054e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800551:	bf 0a 00 00 00       	mov    $0xa,%edi
  800556:	e9 dd 00 00 00       	jmp    800638 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8b 00                	mov    (%eax),%eax
  800560:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800563:	99                   	cltd   
  800564:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 40 04             	lea    0x4(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
  800570:	eb b4                	jmp    800526 <vprintfmt+0x296>
	if (lflag >= 2)
  800572:	83 f9 01             	cmp    $0x1,%ecx
  800575:	7f 1e                	jg     800595 <vprintfmt+0x305>
	else if (lflag)
  800577:	85 c9                	test   %ecx,%ecx
  800579:	74 32                	je     8005ad <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8b 10                	mov    (%eax),%edx
  800580:	b9 00 00 00 00       	mov    $0x0,%ecx
  800585:	8d 40 04             	lea    0x4(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800590:	e9 a3 00 00 00       	jmp    800638 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 10                	mov    (%eax),%edx
  80059a:	8b 48 04             	mov    0x4(%eax),%ecx
  80059d:	8d 40 08             	lea    0x8(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005a8:	e9 8b 00 00 00       	jmp    800638 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 10                	mov    (%eax),%edx
  8005b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005bd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005c2:	eb 74                	jmp    800638 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005c4:	83 f9 01             	cmp    $0x1,%ecx
  8005c7:	7f 1b                	jg     8005e4 <vprintfmt+0x354>
	else if (lflag)
  8005c9:	85 c9                	test   %ecx,%ecx
  8005cb:	74 2c                	je     8005f9 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005dd:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005e2:	eb 54                	jmp    800638 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ec:	8d 40 08             	lea    0x8(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005f2:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005f7:	eb 3f                	jmp    800638 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800603:	8d 40 04             	lea    0x4(%eax),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800609:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80060e:	eb 28                	jmp    800638 <vprintfmt+0x3a8>
			putch('0', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 30                	push   $0x30
  800616:	ff d6                	call   *%esi
			putch('x', putdat);
  800618:	83 c4 08             	add    $0x8,%esp
  80061b:	53                   	push   %ebx
  80061c:	6a 78                	push   $0x78
  80061e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8b 10                	mov    (%eax),%edx
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80062d:	8d 40 04             	lea    0x4(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800633:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800638:	83 ec 0c             	sub    $0xc,%esp
  80063b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80063f:	50                   	push   %eax
  800640:	ff 75 e0             	push   -0x20(%ebp)
  800643:	57                   	push   %edi
  800644:	51                   	push   %ecx
  800645:	52                   	push   %edx
  800646:	89 da                	mov    %ebx,%edx
  800648:	89 f0                	mov    %esi,%eax
  80064a:	e8 5e fb ff ff       	call   8001ad <printnum>
			break;
  80064f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800655:	e9 54 fc ff ff       	jmp    8002ae <vprintfmt+0x1e>
	if (lflag >= 2)
  80065a:	83 f9 01             	cmp    $0x1,%ecx
  80065d:	7f 1b                	jg     80067a <vprintfmt+0x3ea>
	else if (lflag)
  80065f:	85 c9                	test   %ecx,%ecx
  800661:	74 2c                	je     80068f <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 10                	mov    (%eax),%edx
  800668:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800673:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800678:	eb be                	jmp    800638 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8b 48 04             	mov    0x4(%eax),%ecx
  800682:	8d 40 08             	lea    0x8(%eax),%eax
  800685:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800688:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80068d:	eb a9                	jmp    800638 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8b 10                	mov    (%eax),%edx
  800694:	b9 00 00 00 00       	mov    $0x0,%ecx
  800699:	8d 40 04             	lea    0x4(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006a4:	eb 92                	jmp    800638 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 25                	push   $0x25
  8006ac:	ff d6                	call   *%esi
			break;
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	eb 9f                	jmp    800652 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 25                	push   $0x25
  8006b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	89 f8                	mov    %edi,%eax
  8006c0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c4:	74 05                	je     8006cb <vprintfmt+0x43b>
  8006c6:	83 e8 01             	sub    $0x1,%eax
  8006c9:	eb f5                	jmp    8006c0 <vprintfmt+0x430>
  8006cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ce:	eb 82                	jmp    800652 <vprintfmt+0x3c2>

008006d0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 18             	sub    $0x18,%esp
  8006d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006df:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 26                	je     800717 <vsnprintf+0x47>
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	7e 22                	jle    800717 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f5:	ff 75 14             	push   0x14(%ebp)
  8006f8:	ff 75 10             	push   0x10(%ebp)
  8006fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	68 56 02 80 00       	push   $0x800256
  800704:	e8 87 fb ff ff       	call   800290 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800709:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800712:	83 c4 10             	add    $0x10,%esp
}
  800715:	c9                   	leave  
  800716:	c3                   	ret    
		return -E_INVAL;
  800717:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071c:	eb f7                	jmp    800715 <vsnprintf+0x45>

0080071e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800724:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800727:	50                   	push   %eax
  800728:	ff 75 10             	push   0x10(%ebp)
  80072b:	ff 75 0c             	push   0xc(%ebp)
  80072e:	ff 75 08             	push   0x8(%ebp)
  800731:	e8 9a ff ff ff       	call   8006d0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800736:	c9                   	leave  
  800737:	c3                   	ret    

00800738 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	eb 03                	jmp    800748 <strlen+0x10>
		n++;
  800745:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800748:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074c:	75 f7                	jne    800745 <strlen+0xd>
	return n;
}
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
  80075e:	eb 03                	jmp    800763 <strnlen+0x13>
		n++;
  800760:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800763:	39 d0                	cmp    %edx,%eax
  800765:	74 08                	je     80076f <strnlen+0x1f>
  800767:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076b:	75 f3                	jne    800760 <strnlen+0x10>
  80076d:	89 c2                	mov    %eax,%edx
	return n;
}
  80076f:	89 d0                	mov    %edx,%eax
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077d:	b8 00 00 00 00       	mov    $0x0,%eax
  800782:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800786:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800789:	83 c0 01             	add    $0x1,%eax
  80078c:	84 d2                	test   %dl,%dl
  80078e:	75 f2                	jne    800782 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800790:	89 c8                	mov    %ecx,%eax
  800792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	83 ec 10             	sub    $0x10,%esp
  80079e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a1:	53                   	push   %ebx
  8007a2:	e8 91 ff ff ff       	call   800738 <strlen>
  8007a7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007aa:	ff 75 0c             	push   0xc(%ebp)
  8007ad:	01 d8                	add    %ebx,%eax
  8007af:	50                   	push   %eax
  8007b0:	e8 be ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007b5:	89 d8                	mov    %ebx,%eax
  8007b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	56                   	push   %esi
  8007c0:	53                   	push   %ebx
  8007c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c7:	89 f3                	mov    %esi,%ebx
  8007c9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cc:	89 f0                	mov    %esi,%eax
  8007ce:	eb 0f                	jmp    8007df <strncpy+0x23>
		*dst++ = *src;
  8007d0:	83 c0 01             	add    $0x1,%eax
  8007d3:	0f b6 0a             	movzbl (%edx),%ecx
  8007d6:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d9:	80 f9 01             	cmp    $0x1,%cl
  8007dc:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007df:	39 d8                	cmp    %ebx,%eax
  8007e1:	75 ed                	jne    8007d0 <strncpy+0x14>
	}
	return ret;
}
  8007e3:	89 f0                	mov    %esi,%eax
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	56                   	push   %esi
  8007ed:	53                   	push   %ebx
  8007ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	74 21                	je     80081e <strlcpy+0x35>
  8007fd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800801:	89 f2                	mov    %esi,%edx
  800803:	eb 09                	jmp    80080e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800805:	83 c1 01             	add    $0x1,%ecx
  800808:	83 c2 01             	add    $0x1,%edx
  80080b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80080e:	39 c2                	cmp    %eax,%edx
  800810:	74 09                	je     80081b <strlcpy+0x32>
  800812:	0f b6 19             	movzbl (%ecx),%ebx
  800815:	84 db                	test   %bl,%bl
  800817:	75 ec                	jne    800805 <strlcpy+0x1c>
  800819:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80081b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081e:	29 f0                	sub    %esi,%eax
}
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082d:	eb 06                	jmp    800835 <strcmp+0x11>
		p++, q++;
  80082f:	83 c1 01             	add    $0x1,%ecx
  800832:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800835:	0f b6 01             	movzbl (%ecx),%eax
  800838:	84 c0                	test   %al,%al
  80083a:	74 04                	je     800840 <strcmp+0x1c>
  80083c:	3a 02                	cmp    (%edx),%al
  80083e:	74 ef                	je     80082f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800840:	0f b6 c0             	movzbl %al,%eax
  800843:	0f b6 12             	movzbl (%edx),%edx
  800846:	29 d0                	sub    %edx,%eax
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	8b 55 0c             	mov    0xc(%ebp),%edx
  800854:	89 c3                	mov    %eax,%ebx
  800856:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800859:	eb 06                	jmp    800861 <strncmp+0x17>
		n--, p++, q++;
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800861:	39 d8                	cmp    %ebx,%eax
  800863:	74 18                	je     80087d <strncmp+0x33>
  800865:	0f b6 08             	movzbl (%eax),%ecx
  800868:	84 c9                	test   %cl,%cl
  80086a:	74 04                	je     800870 <strncmp+0x26>
  80086c:	3a 0a                	cmp    (%edx),%cl
  80086e:	74 eb                	je     80085b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800870:	0f b6 00             	movzbl (%eax),%eax
  800873:	0f b6 12             	movzbl (%edx),%edx
  800876:	29 d0                	sub    %edx,%eax
}
  800878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    
		return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
  800882:	eb f4                	jmp    800878 <strncmp+0x2e>

00800884 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088e:	eb 03                	jmp    800893 <strchr+0xf>
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	0f b6 10             	movzbl (%eax),%edx
  800896:	84 d2                	test   %dl,%dl
  800898:	74 06                	je     8008a0 <strchr+0x1c>
		if (*s == c)
  80089a:	38 ca                	cmp    %cl,%dl
  80089c:	75 f2                	jne    800890 <strchr+0xc>
  80089e:	eb 05                	jmp    8008a5 <strchr+0x21>
			return (char *) s;
	return 0;
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 09                	je     8008c1 <strfind+0x1a>
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	74 05                	je     8008c1 <strfind+0x1a>
	for (; *s; s++)
  8008bc:	83 c0 01             	add    $0x1,%eax
  8008bf:	eb f0                	jmp    8008b1 <strfind+0xa>
			break;
	return (char *) s;
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	57                   	push   %edi
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cf:	85 c9                	test   %ecx,%ecx
  8008d1:	74 2f                	je     800902 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d3:	89 f8                	mov    %edi,%eax
  8008d5:	09 c8                	or     %ecx,%eax
  8008d7:	a8 03                	test   $0x3,%al
  8008d9:	75 21                	jne    8008fc <memset+0x39>
		c &= 0xFF;
  8008db:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008df:	89 d0                	mov    %edx,%eax
  8008e1:	c1 e0 08             	shl    $0x8,%eax
  8008e4:	89 d3                	mov    %edx,%ebx
  8008e6:	c1 e3 18             	shl    $0x18,%ebx
  8008e9:	89 d6                	mov    %edx,%esi
  8008eb:	c1 e6 10             	shl    $0x10,%esi
  8008ee:	09 f3                	or     %esi,%ebx
  8008f0:	09 da                	or     %ebx,%edx
  8008f2:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008f7:	fc                   	cld    
  8008f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fa:	eb 06                	jmp    800902 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	fc                   	cld    
  800900:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800902:	89 f8                	mov    %edi,%eax
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5f                   	pop    %edi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	57                   	push   %edi
  80090d:	56                   	push   %esi
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 75 0c             	mov    0xc(%ebp),%esi
  800914:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800917:	39 c6                	cmp    %eax,%esi
  800919:	73 32                	jae    80094d <memmove+0x44>
  80091b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091e:	39 c2                	cmp    %eax,%edx
  800920:	76 2b                	jbe    80094d <memmove+0x44>
		s += n;
		d += n;
  800922:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800925:	89 d6                	mov    %edx,%esi
  800927:	09 fe                	or     %edi,%esi
  800929:	09 ce                	or     %ecx,%esi
  80092b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800931:	75 0e                	jne    800941 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800933:	83 ef 04             	sub    $0x4,%edi
  800936:	8d 72 fc             	lea    -0x4(%edx),%esi
  800939:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80093c:	fd                   	std    
  80093d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093f:	eb 09                	jmp    80094a <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800941:	83 ef 01             	sub    $0x1,%edi
  800944:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800947:	fd                   	std    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094a:	fc                   	cld    
  80094b:	eb 1a                	jmp    800967 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094d:	89 f2                	mov    %esi,%edx
  80094f:	09 c2                	or     %eax,%edx
  800951:	09 ca                	or     %ecx,%edx
  800953:	f6 c2 03             	test   $0x3,%dl
  800956:	75 0a                	jne    800962 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800958:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80095b:	89 c7                	mov    %eax,%edi
  80095d:	fc                   	cld    
  80095e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800960:	eb 05                	jmp    800967 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800962:	89 c7                	mov    %eax,%edi
  800964:	fc                   	cld    
  800965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800971:	ff 75 10             	push   0x10(%ebp)
  800974:	ff 75 0c             	push   0xc(%ebp)
  800977:	ff 75 08             	push   0x8(%ebp)
  80097a:	e8 8a ff ff ff       	call   800909 <memmove>
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	56                   	push   %esi
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098c:	89 c6                	mov    %eax,%esi
  80098e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800991:	eb 06                	jmp    800999 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800999:	39 f0                	cmp    %esi,%eax
  80099b:	74 14                	je     8009b1 <memcmp+0x30>
		if (*s1 != *s2)
  80099d:	0f b6 08             	movzbl (%eax),%ecx
  8009a0:	0f b6 1a             	movzbl (%edx),%ebx
  8009a3:	38 d9                	cmp    %bl,%cl
  8009a5:	74 ec                	je     800993 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009a7:	0f b6 c1             	movzbl %cl,%eax
  8009aa:	0f b6 db             	movzbl %bl,%ebx
  8009ad:	29 d8                	sub    %ebx,%eax
  8009af:	eb 05                	jmp    8009b6 <memcmp+0x35>
	}

	return 0;
  8009b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5e                   	pop    %esi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c3:	89 c2                	mov    %eax,%edx
  8009c5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c8:	eb 03                	jmp    8009cd <memfind+0x13>
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	39 d0                	cmp    %edx,%eax
  8009cf:	73 04                	jae    8009d5 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d1:	38 08                	cmp    %cl,(%eax)
  8009d3:	75 f5                	jne    8009ca <memfind+0x10>
			break;
	return (void *) s;
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	57                   	push   %edi
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e3:	eb 03                	jmp    8009e8 <strtol+0x11>
		s++;
  8009e5:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009e8:	0f b6 02             	movzbl (%edx),%eax
  8009eb:	3c 20                	cmp    $0x20,%al
  8009ed:	74 f6                	je     8009e5 <strtol+0xe>
  8009ef:	3c 09                	cmp    $0x9,%al
  8009f1:	74 f2                	je     8009e5 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009f3:	3c 2b                	cmp    $0x2b,%al
  8009f5:	74 2a                	je     800a21 <strtol+0x4a>
	int neg = 0;
  8009f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009fc:	3c 2d                	cmp    $0x2d,%al
  8009fe:	74 2b                	je     800a2b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a00:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a06:	75 0f                	jne    800a17 <strtol+0x40>
  800a08:	80 3a 30             	cmpb   $0x30,(%edx)
  800a0b:	74 28                	je     800a35 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0d:	85 db                	test   %ebx,%ebx
  800a0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a14:	0f 44 d8             	cmove  %eax,%ebx
  800a17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a1c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a1f:	eb 46                	jmp    800a67 <strtol+0x90>
		s++;
  800a21:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
  800a29:	eb d5                	jmp    800a00 <strtol+0x29>
		s++, neg = 1;
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a33:	eb cb                	jmp    800a00 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a35:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a39:	74 0e                	je     800a49 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a3b:	85 db                	test   %ebx,%ebx
  800a3d:	75 d8                	jne    800a17 <strtol+0x40>
		s++, base = 8;
  800a3f:	83 c2 01             	add    $0x1,%edx
  800a42:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a47:	eb ce                	jmp    800a17 <strtol+0x40>
		s += 2, base = 16;
  800a49:	83 c2 02             	add    $0x2,%edx
  800a4c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a51:	eb c4                	jmp    800a17 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a53:	0f be c0             	movsbl %al,%eax
  800a56:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a59:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a5c:	7d 3a                	jge    800a98 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a5e:	83 c2 01             	add    $0x1,%edx
  800a61:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a65:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a67:	0f b6 02             	movzbl (%edx),%eax
  800a6a:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 09             	cmp    $0x9,%bl
  800a72:	76 df                	jbe    800a53 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a74:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a7e:	0f be c0             	movsbl %al,%eax
  800a81:	83 e8 57             	sub    $0x57,%eax
  800a84:	eb d3                	jmp    800a59 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a86:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 08                	ja     800a98 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a90:	0f be c0             	movsbl %al,%eax
  800a93:	83 e8 37             	sub    $0x37,%eax
  800a96:	eb c1                	jmp    800a59 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9c:	74 05                	je     800aa3 <strtol+0xcc>
		*endptr = (char *) s;
  800a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800aa3:	89 c8                	mov    %ecx,%eax
  800aa5:	f7 d8                	neg    %eax
  800aa7:	85 ff                	test   %edi,%edi
  800aa9:	0f 45 c8             	cmovne %eax,%ecx
}
  800aac:	89 c8                	mov    %ecx,%eax
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  800abe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac4:	89 c3                	mov    %eax,%ebx
  800ac6:	89 c7                	mov    %eax,%edi
  800ac8:	89 c6                	mov    %eax,%esi
  800aca:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  800adc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae1:	89 d1                	mov    %edx,%ecx
  800ae3:	89 d3                	mov    %edx,%ebx
  800ae5:	89 d7                	mov    %edx,%edi
  800ae7:	89 d6                	mov    %edx,%esi
  800ae9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800af9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	b8 03 00 00 00       	mov    $0x3,%eax
  800b06:	89 cb                	mov    %ecx,%ebx
  800b08:	89 cf                	mov    %ecx,%edi
  800b0a:	89 ce                	mov    %ecx,%esi
  800b0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b0e:	85 c0                	test   %eax,%eax
  800b10:	7f 08                	jg     800b1a <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	50                   	push   %eax
  800b1e:	6a 03                	push   $0x3
  800b20:	68 df 25 80 00       	push   $0x8025df
  800b25:	6a 2a                	push   $0x2a
  800b27:	68 fc 25 80 00       	push   $0x8025fc
  800b2c:	e8 a1 14 00 00       	call   801fd2 <_panic>

00800b31 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b37:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b41:	89 d1                	mov    %edx,%ecx
  800b43:	89 d3                	mov    %edx,%ebx
  800b45:	89 d7                	mov    %edx,%edi
  800b47:	89 d6                	mov    %edx,%esi
  800b49:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <sys_yield>:

void
sys_yield(void)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b60:	89 d1                	mov    %edx,%ecx
  800b62:	89 d3                	mov    %edx,%ebx
  800b64:	89 d7                	mov    %edx,%edi
  800b66:	89 d6                	mov    %edx,%esi
  800b68:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
  800b75:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b78:	be 00 00 00 00       	mov    $0x0,%esi
  800b7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	b8 04 00 00 00       	mov    $0x4,%eax
  800b88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8b:	89 f7                	mov    %esi,%edi
  800b8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7f 08                	jg     800b9b <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 04                	push   $0x4
  800ba1:	68 df 25 80 00       	push   $0x8025df
  800ba6:	6a 2a                	push   $0x2a
  800ba8:	68 fc 25 80 00       	push   $0x8025fc
  800bad:	e8 20 14 00 00       	call   801fd2 <_panic>

00800bb2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc1:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bcc:	8b 75 18             	mov    0x18(%ebp),%esi
  800bcf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	7f 08                	jg     800bdd <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 05                	push   $0x5
  800be3:	68 df 25 80 00       	push   $0x8025df
  800be8:	6a 2a                	push   $0x2a
  800bea:	68 fc 25 80 00       	push   $0x8025fc
  800bef:	e8 de 13 00 00       	call   801fd2 <_panic>

00800bf4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0d:	89 df                	mov    %ebx,%edi
  800c0f:	89 de                	mov    %ebx,%esi
  800c11:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7f 08                	jg     800c1f <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 06                	push   $0x6
  800c25:	68 df 25 80 00       	push   $0x8025df
  800c2a:	6a 2a                	push   $0x2a
  800c2c:	68 fc 25 80 00       	push   $0x8025fc
  800c31:	e8 9c 13 00 00       	call   801fd2 <_panic>

00800c36 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4f:	89 df                	mov    %ebx,%edi
  800c51:	89 de                	mov    %ebx,%esi
  800c53:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c55:	85 c0                	test   %eax,%eax
  800c57:	7f 08                	jg     800c61 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 08                	push   $0x8
  800c67:	68 df 25 80 00       	push   $0x8025df
  800c6c:	6a 2a                	push   $0x2a
  800c6e:	68 fc 25 80 00       	push   $0x8025fc
  800c73:	e8 5a 13 00 00       	call   801fd2 <_panic>

00800c78 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
  800c7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c91:	89 df                	mov    %ebx,%edi
  800c93:	89 de                	mov    %ebx,%esi
  800c95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7f 08                	jg     800ca3 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 09                	push   $0x9
  800ca9:	68 df 25 80 00       	push   $0x8025df
  800cae:	6a 2a                	push   $0x2a
  800cb0:	68 fc 25 80 00       	push   $0x8025fc
  800cb5:	e8 18 13 00 00       	call   801fd2 <_panic>

00800cba <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd3:	89 df                	mov    %ebx,%edi
  800cd5:	89 de                	mov    %ebx,%esi
  800cd7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	7f 08                	jg     800ce5 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 0a                	push   $0xa
  800ceb:	68 df 25 80 00       	push   $0x8025df
  800cf0:	6a 2a                	push   $0x2a
  800cf2:	68 fc 25 80 00       	push   $0x8025fc
  800cf7:	e8 d6 12 00 00       	call   801fd2 <_panic>

00800cfc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d0d:	be 00 00 00 00       	mov    $0x0,%esi
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d18:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d35:	89 cb                	mov    %ecx,%ebx
  800d37:	89 cf                	mov    %ecx,%edi
  800d39:	89 ce                	mov    %ecx,%esi
  800d3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7f 08                	jg     800d49 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 0d                	push   $0xd
  800d4f:	68 df 25 80 00       	push   $0x8025df
  800d54:	6a 2a                	push   $0x2a
  800d56:	68 fc 25 80 00       	push   $0x8025fc
  800d5b:	e8 72 12 00 00       	call   801fd2 <_panic>

00800d60 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d66:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d70:	89 d1                	mov    %edx,%ecx
  800d72:	89 d3                	mov    %edx,%ebx
  800d74:	89 d7                	mov    %edx,%edi
  800d76:	89 d6                	mov    %edx,%esi
  800d78:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d90:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d95:	89 df                	mov    %ebx,%edi
  800d97:	89 de                	mov    %ebx,%esi
  800d99:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	b8 10 00 00 00       	mov    $0x10,%eax
  800db6:	89 df                	mov    %ebx,%edi
  800db8:	89 de                	mov    %ebx,%esi
  800dba:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800dd6:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	e8 3d ff ff ff       	call   800d1f <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  800de2:	83 c4 10             	add    $0x10,%esp
  800de5:	85 f6                	test   %esi,%esi
  800de7:	74 17                	je     800e00 <ipc_recv+0x3f>
  800de9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dee:	85 c0                	test   %eax,%eax
  800df0:	78 0c                	js     800dfe <ipc_recv+0x3d>
  800df2:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800df8:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  800dfe:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  800e00:	85 db                	test   %ebx,%ebx
  800e02:	74 17                	je     800e1b <ipc_recv+0x5a>
  800e04:	ba 00 00 00 00       	mov    $0x0,%edx
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	78 0c                	js     800e19 <ipc_recv+0x58>
  800e0d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800e13:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  800e19:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	78 0b                	js     800e2a <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  800e1f:	a1 00 40 80 00       	mov    0x804000,%eax
  800e24:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  800e2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  800e43:	85 db                	test   %ebx,%ebx
  800e45:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800e4a:	0f 44 d8             	cmove  %eax,%ebx
  800e4d:	eb 05                	jmp    800e54 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  800e4f:	e8 fc fc ff ff       	call   800b50 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  800e54:	ff 75 14             	push   0x14(%ebp)
  800e57:	53                   	push   %ebx
  800e58:	56                   	push   %esi
  800e59:	57                   	push   %edi
  800e5a:	e8 9d fe ff ff       	call   800cfc <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e65:	74 e8                	je     800e4f <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 08                	js     800e73 <ipc_send+0x42>
	}while (r<0);

}
  800e6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  800e73:	50                   	push   %eax
  800e74:	68 0a 26 80 00       	push   $0x80260a
  800e79:	6a 3d                	push   $0x3d
  800e7b:	68 1e 26 80 00       	push   $0x80261e
  800e80:	e8 4d 11 00 00       	call   801fd2 <_panic>

00800e85 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e90:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  800e96:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e9c:	8b 52 60             	mov    0x60(%edx),%edx
  800e9f:	39 ca                	cmp    %ecx,%edx
  800ea1:	74 11                	je     800eb4 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  800ea3:	83 c0 01             	add    $0x1,%eax
  800ea6:	3d 00 04 00 00       	cmp    $0x400,%eax
  800eab:	75 e3                	jne    800e90 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800ead:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb2:	eb 0e                	jmp    800ec2 <ipc_find_env+0x3d>
			return envs[i].env_id;
  800eb4:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800eba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ebf:	8b 40 58             	mov    0x58(%eax),%eax
}
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	05 00 00 00 30       	add    $0x30000000,%eax
  800ecf:	c1 e8 0c             	shr    $0xc,%eax
}
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eda:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800edf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ef3:	89 c2                	mov    %eax,%edx
  800ef5:	c1 ea 16             	shr    $0x16,%edx
  800ef8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eff:	f6 c2 01             	test   $0x1,%dl
  800f02:	74 29                	je     800f2d <fd_alloc+0x42>
  800f04:	89 c2                	mov    %eax,%edx
  800f06:	c1 ea 0c             	shr    $0xc,%edx
  800f09:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f10:	f6 c2 01             	test   $0x1,%dl
  800f13:	74 18                	je     800f2d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f15:	05 00 10 00 00       	add    $0x1000,%eax
  800f1a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f1f:	75 d2                	jne    800ef3 <fd_alloc+0x8>
  800f21:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f26:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f2b:	eb 05                	jmp    800f32 <fd_alloc+0x47>
			return 0;
  800f2d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f32:	8b 55 08             	mov    0x8(%ebp),%edx
  800f35:	89 02                	mov    %eax,(%edx)
}
  800f37:	89 c8                	mov    %ecx,%eax
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f41:	83 f8 1f             	cmp    $0x1f,%eax
  800f44:	77 30                	ja     800f76 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f46:	c1 e0 0c             	shl    $0xc,%eax
  800f49:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f4e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f54:	f6 c2 01             	test   $0x1,%dl
  800f57:	74 24                	je     800f7d <fd_lookup+0x42>
  800f59:	89 c2                	mov    %eax,%edx
  800f5b:	c1 ea 0c             	shr    $0xc,%edx
  800f5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f65:	f6 c2 01             	test   $0x1,%dl
  800f68:	74 1a                	je     800f84 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6d:	89 02                	mov    %eax,(%edx)
	return 0;
  800f6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    
		return -E_INVAL;
  800f76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f7b:	eb f7                	jmp    800f74 <fd_lookup+0x39>
		return -E_INVAL;
  800f7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f82:	eb f0                	jmp    800f74 <fd_lookup+0x39>
  800f84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f89:	eb e9                	jmp    800f74 <fd_lookup+0x39>

00800f8b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 04             	sub    $0x4,%esp
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f95:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9a:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f9f:	39 13                	cmp    %edx,(%ebx)
  800fa1:	74 37                	je     800fda <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800fa3:	83 c0 01             	add    $0x1,%eax
  800fa6:	8b 1c 85 a4 26 80 00 	mov    0x8026a4(,%eax,4),%ebx
  800fad:	85 db                	test   %ebx,%ebx
  800faf:	75 ee                	jne    800f9f <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb1:	a1 00 40 80 00       	mov    0x804000,%eax
  800fb6:	8b 40 58             	mov    0x58(%eax),%eax
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	52                   	push   %edx
  800fbd:	50                   	push   %eax
  800fbe:	68 28 26 80 00       	push   $0x802628
  800fc3:	e8 d1 f1 ff ff       	call   800199 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800fd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd3:	89 1a                	mov    %ebx,(%edx)
}
  800fd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd8:	c9                   	leave  
  800fd9:	c3                   	ret    
			return 0;
  800fda:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdf:	eb ef                	jmp    800fd0 <dev_lookup+0x45>

00800fe1 <fd_close>:
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	57                   	push   %edi
  800fe5:	56                   	push   %esi
  800fe6:	53                   	push   %ebx
  800fe7:	83 ec 24             	sub    $0x24,%esp
  800fea:	8b 75 08             	mov    0x8(%ebp),%esi
  800fed:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ff4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ffa:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ffd:	50                   	push   %eax
  800ffe:	e8 38 ff ff ff       	call   800f3b <fd_lookup>
  801003:	89 c3                	mov    %eax,%ebx
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 05                	js     801011 <fd_close+0x30>
	    || fd != fd2)
  80100c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80100f:	74 16                	je     801027 <fd_close+0x46>
		return (must_exist ? r : 0);
  801011:	89 f8                	mov    %edi,%eax
  801013:	84 c0                	test   %al,%al
  801015:	b8 00 00 00 00       	mov    $0x0,%eax
  80101a:	0f 44 d8             	cmove  %eax,%ebx
}
  80101d:	89 d8                	mov    %ebx,%eax
  80101f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801022:	5b                   	pop    %ebx
  801023:	5e                   	pop    %esi
  801024:	5f                   	pop    %edi
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801027:	83 ec 08             	sub    $0x8,%esp
  80102a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80102d:	50                   	push   %eax
  80102e:	ff 36                	push   (%esi)
  801030:	e8 56 ff ff ff       	call   800f8b <dev_lookup>
  801035:	89 c3                	mov    %eax,%ebx
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 1a                	js     801058 <fd_close+0x77>
		if (dev->dev_close)
  80103e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801041:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801044:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801049:	85 c0                	test   %eax,%eax
  80104b:	74 0b                	je     801058 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	56                   	push   %esi
  801051:	ff d0                	call   *%eax
  801053:	89 c3                	mov    %eax,%ebx
  801055:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801058:	83 ec 08             	sub    $0x8,%esp
  80105b:	56                   	push   %esi
  80105c:	6a 00                	push   $0x0
  80105e:	e8 91 fb ff ff       	call   800bf4 <sys_page_unmap>
	return r;
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	eb b5                	jmp    80101d <fd_close+0x3c>

00801068 <close>:

int
close(int fdnum)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80106e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801071:	50                   	push   %eax
  801072:	ff 75 08             	push   0x8(%ebp)
  801075:	e8 c1 fe ff ff       	call   800f3b <fd_lookup>
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	79 02                	jns    801083 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801081:	c9                   	leave  
  801082:	c3                   	ret    
		return fd_close(fd, 1);
  801083:	83 ec 08             	sub    $0x8,%esp
  801086:	6a 01                	push   $0x1
  801088:	ff 75 f4             	push   -0xc(%ebp)
  80108b:	e8 51 ff ff ff       	call   800fe1 <fd_close>
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	eb ec                	jmp    801081 <close+0x19>

00801095 <close_all>:

void
close_all(void)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	53                   	push   %ebx
  801099:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80109c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	53                   	push   %ebx
  8010a5:	e8 be ff ff ff       	call   801068 <close>
	for (i = 0; i < MAXFD; i++)
  8010aa:	83 c3 01             	add    $0x1,%ebx
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	83 fb 20             	cmp    $0x20,%ebx
  8010b3:	75 ec                	jne    8010a1 <close_all+0xc>
}
  8010b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	57                   	push   %edi
  8010be:	56                   	push   %esi
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010c6:	50                   	push   %eax
  8010c7:	ff 75 08             	push   0x8(%ebp)
  8010ca:	e8 6c fe ff ff       	call   800f3b <fd_lookup>
  8010cf:	89 c3                	mov    %eax,%ebx
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 7f                	js     801157 <dup+0x9d>
		return r;
	close(newfdnum);
  8010d8:	83 ec 0c             	sub    $0xc,%esp
  8010db:	ff 75 0c             	push   0xc(%ebp)
  8010de:	e8 85 ff ff ff       	call   801068 <close>

	newfd = INDEX2FD(newfdnum);
  8010e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010e6:	c1 e6 0c             	shl    $0xc,%esi
  8010e9:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010f2:	89 3c 24             	mov    %edi,(%esp)
  8010f5:	e8 da fd ff ff       	call   800ed4 <fd2data>
  8010fa:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010fc:	89 34 24             	mov    %esi,(%esp)
  8010ff:	e8 d0 fd ff ff       	call   800ed4 <fd2data>
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80110a:	89 d8                	mov    %ebx,%eax
  80110c:	c1 e8 16             	shr    $0x16,%eax
  80110f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801116:	a8 01                	test   $0x1,%al
  801118:	74 11                	je     80112b <dup+0x71>
  80111a:	89 d8                	mov    %ebx,%eax
  80111c:	c1 e8 0c             	shr    $0xc,%eax
  80111f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801126:	f6 c2 01             	test   $0x1,%dl
  801129:	75 36                	jne    801161 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80112b:	89 f8                	mov    %edi,%eax
  80112d:	c1 e8 0c             	shr    $0xc,%eax
  801130:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	25 07 0e 00 00       	and    $0xe07,%eax
  80113f:	50                   	push   %eax
  801140:	56                   	push   %esi
  801141:	6a 00                	push   $0x0
  801143:	57                   	push   %edi
  801144:	6a 00                	push   $0x0
  801146:	e8 67 fa ff ff       	call   800bb2 <sys_page_map>
  80114b:	89 c3                	mov    %eax,%ebx
  80114d:	83 c4 20             	add    $0x20,%esp
  801150:	85 c0                	test   %eax,%eax
  801152:	78 33                	js     801187 <dup+0xcd>
		goto err;

	return newfdnum;
  801154:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801157:	89 d8                	mov    %ebx,%eax
  801159:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801161:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801168:	83 ec 0c             	sub    $0xc,%esp
  80116b:	25 07 0e 00 00       	and    $0xe07,%eax
  801170:	50                   	push   %eax
  801171:	ff 75 d4             	push   -0x2c(%ebp)
  801174:	6a 00                	push   $0x0
  801176:	53                   	push   %ebx
  801177:	6a 00                	push   $0x0
  801179:	e8 34 fa ff ff       	call   800bb2 <sys_page_map>
  80117e:	89 c3                	mov    %eax,%ebx
  801180:	83 c4 20             	add    $0x20,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	79 a4                	jns    80112b <dup+0x71>
	sys_page_unmap(0, newfd);
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	56                   	push   %esi
  80118b:	6a 00                	push   $0x0
  80118d:	e8 62 fa ff ff       	call   800bf4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801192:	83 c4 08             	add    $0x8,%esp
  801195:	ff 75 d4             	push   -0x2c(%ebp)
  801198:	6a 00                	push   $0x0
  80119a:	e8 55 fa ff ff       	call   800bf4 <sys_page_unmap>
	return r;
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	eb b3                	jmp    801157 <dup+0x9d>

008011a4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 18             	sub    $0x18,%esp
  8011ac:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	56                   	push   %esi
  8011b4:	e8 82 fd ff ff       	call   800f3b <fd_lookup>
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 3c                	js     8011fc <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	ff 33                	push   (%ebx)
  8011cc:	e8 ba fd ff ff       	call   800f8b <dev_lookup>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 24                	js     8011fc <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d8:	8b 43 08             	mov    0x8(%ebx),%eax
  8011db:	83 e0 03             	and    $0x3,%eax
  8011de:	83 f8 01             	cmp    $0x1,%eax
  8011e1:	74 20                	je     801203 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e6:	8b 40 08             	mov    0x8(%eax),%eax
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	74 37                	je     801224 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ed:	83 ec 04             	sub    $0x4,%esp
  8011f0:	ff 75 10             	push   0x10(%ebp)
  8011f3:	ff 75 0c             	push   0xc(%ebp)
  8011f6:	53                   	push   %ebx
  8011f7:	ff d0                	call   *%eax
  8011f9:	83 c4 10             	add    $0x10,%esp
}
  8011fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ff:	5b                   	pop    %ebx
  801200:	5e                   	pop    %esi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801203:	a1 00 40 80 00       	mov    0x804000,%eax
  801208:	8b 40 58             	mov    0x58(%eax),%eax
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	56                   	push   %esi
  80120f:	50                   	push   %eax
  801210:	68 69 26 80 00       	push   $0x802669
  801215:	e8 7f ef ff ff       	call   800199 <cprintf>
		return -E_INVAL;
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801222:	eb d8                	jmp    8011fc <read+0x58>
		return -E_NOT_SUPP;
  801224:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801229:	eb d1                	jmp    8011fc <read+0x58>

0080122b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	57                   	push   %edi
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	83 ec 0c             	sub    $0xc,%esp
  801234:	8b 7d 08             	mov    0x8(%ebp),%edi
  801237:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123f:	eb 02                	jmp    801243 <readn+0x18>
  801241:	01 c3                	add    %eax,%ebx
  801243:	39 f3                	cmp    %esi,%ebx
  801245:	73 21                	jae    801268 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801247:	83 ec 04             	sub    $0x4,%esp
  80124a:	89 f0                	mov    %esi,%eax
  80124c:	29 d8                	sub    %ebx,%eax
  80124e:	50                   	push   %eax
  80124f:	89 d8                	mov    %ebx,%eax
  801251:	03 45 0c             	add    0xc(%ebp),%eax
  801254:	50                   	push   %eax
  801255:	57                   	push   %edi
  801256:	e8 49 ff ff ff       	call   8011a4 <read>
		if (m < 0)
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	85 c0                	test   %eax,%eax
  801260:	78 04                	js     801266 <readn+0x3b>
			return m;
		if (m == 0)
  801262:	75 dd                	jne    801241 <readn+0x16>
  801264:	eb 02                	jmp    801268 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801266:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801268:	89 d8                	mov    %ebx,%eax
  80126a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5f                   	pop    %edi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	56                   	push   %esi
  801276:	53                   	push   %ebx
  801277:	83 ec 18             	sub    $0x18,%esp
  80127a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801280:	50                   	push   %eax
  801281:	53                   	push   %ebx
  801282:	e8 b4 fc ff ff       	call   800f3b <fd_lookup>
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 37                	js     8012c5 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801291:	83 ec 08             	sub    $0x8,%esp
  801294:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801297:	50                   	push   %eax
  801298:	ff 36                	push   (%esi)
  80129a:	e8 ec fc ff ff       	call   800f8b <dev_lookup>
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 1f                	js     8012c5 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a6:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012aa:	74 20                	je     8012cc <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012af:	8b 40 0c             	mov    0xc(%eax),%eax
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	74 37                	je     8012ed <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012b6:	83 ec 04             	sub    $0x4,%esp
  8012b9:	ff 75 10             	push   0x10(%ebp)
  8012bc:	ff 75 0c             	push   0xc(%ebp)
  8012bf:	56                   	push   %esi
  8012c0:	ff d0                	call   *%eax
  8012c2:	83 c4 10             	add    $0x10,%esp
}
  8012c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012cc:	a1 00 40 80 00       	mov    0x804000,%eax
  8012d1:	8b 40 58             	mov    0x58(%eax),%eax
  8012d4:	83 ec 04             	sub    $0x4,%esp
  8012d7:	53                   	push   %ebx
  8012d8:	50                   	push   %eax
  8012d9:	68 85 26 80 00       	push   $0x802685
  8012de:	e8 b6 ee ff ff       	call   800199 <cprintf>
		return -E_INVAL;
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012eb:	eb d8                	jmp    8012c5 <write+0x53>
		return -E_NOT_SUPP;
  8012ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012f2:	eb d1                	jmp    8012c5 <write+0x53>

008012f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fd:	50                   	push   %eax
  8012fe:	ff 75 08             	push   0x8(%ebp)
  801301:	e8 35 fc ff ff       	call   800f3b <fd_lookup>
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 0e                	js     80131b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80130d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801310:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801313:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801316:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80131b:	c9                   	leave  
  80131c:	c3                   	ret    

0080131d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	83 ec 18             	sub    $0x18,%esp
  801325:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801328:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132b:	50                   	push   %eax
  80132c:	53                   	push   %ebx
  80132d:	e8 09 fc ff ff       	call   800f3b <fd_lookup>
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	78 34                	js     80136d <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801339:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801342:	50                   	push   %eax
  801343:	ff 36                	push   (%esi)
  801345:	e8 41 fc ff ff       	call   800f8b <dev_lookup>
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 1c                	js     80136d <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801351:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801355:	74 1d                	je     801374 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135a:	8b 40 18             	mov    0x18(%eax),%eax
  80135d:	85 c0                	test   %eax,%eax
  80135f:	74 34                	je     801395 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	ff 75 0c             	push   0xc(%ebp)
  801367:	56                   	push   %esi
  801368:	ff d0                	call   *%eax
  80136a:	83 c4 10             	add    $0x10,%esp
}
  80136d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    
			thisenv->env_id, fdnum);
  801374:	a1 00 40 80 00       	mov    0x804000,%eax
  801379:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80137c:	83 ec 04             	sub    $0x4,%esp
  80137f:	53                   	push   %ebx
  801380:	50                   	push   %eax
  801381:	68 48 26 80 00       	push   $0x802648
  801386:	e8 0e ee ff ff       	call   800199 <cprintf>
		return -E_INVAL;
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801393:	eb d8                	jmp    80136d <ftruncate+0x50>
		return -E_NOT_SUPP;
  801395:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80139a:	eb d1                	jmp    80136d <ftruncate+0x50>

0080139c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 18             	sub    $0x18,%esp
  8013a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013aa:	50                   	push   %eax
  8013ab:	ff 75 08             	push   0x8(%ebp)
  8013ae:	e8 88 fb ff ff       	call   800f3b <fd_lookup>
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 49                	js     801403 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ba:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c3:	50                   	push   %eax
  8013c4:	ff 36                	push   (%esi)
  8013c6:	e8 c0 fb ff ff       	call   800f8b <dev_lookup>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 31                	js     801403 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013d9:	74 2f                	je     80140a <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013db:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013de:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e5:	00 00 00 
	stat->st_isdir = 0;
  8013e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ef:	00 00 00 
	stat->st_dev = dev;
  8013f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	56                   	push   %esi
  8013fd:	ff 50 14             	call   *0x14(%eax)
  801400:	83 c4 10             	add    $0x10,%esp
}
  801403:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    
		return -E_NOT_SUPP;
  80140a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80140f:	eb f2                	jmp    801403 <fstat+0x67>

00801411 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	56                   	push   %esi
  801415:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801416:	83 ec 08             	sub    $0x8,%esp
  801419:	6a 00                	push   $0x0
  80141b:	ff 75 08             	push   0x8(%ebp)
  80141e:	e8 e4 01 00 00       	call   801607 <open>
  801423:	89 c3                	mov    %eax,%ebx
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 1b                	js     801447 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	ff 75 0c             	push   0xc(%ebp)
  801432:	50                   	push   %eax
  801433:	e8 64 ff ff ff       	call   80139c <fstat>
  801438:	89 c6                	mov    %eax,%esi
	close(fd);
  80143a:	89 1c 24             	mov    %ebx,(%esp)
  80143d:	e8 26 fc ff ff       	call   801068 <close>
	return r;
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	89 f3                	mov    %esi,%ebx
}
  801447:	89 d8                	mov    %ebx,%eax
  801449:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	56                   	push   %esi
  801454:	53                   	push   %ebx
  801455:	89 c6                	mov    %eax,%esi
  801457:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801459:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801460:	74 27                	je     801489 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801462:	6a 07                	push   $0x7
  801464:	68 00 50 80 00       	push   $0x805000
  801469:	56                   	push   %esi
  80146a:	ff 35 00 60 80 00    	push   0x806000
  801470:	e8 bc f9 ff ff       	call   800e31 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801475:	83 c4 0c             	add    $0xc,%esp
  801478:	6a 00                	push   $0x0
  80147a:	53                   	push   %ebx
  80147b:	6a 00                	push   $0x0
  80147d:	e8 3f f9 ff ff       	call   800dc1 <ipc_recv>
}
  801482:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801485:	5b                   	pop    %ebx
  801486:	5e                   	pop    %esi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801489:	83 ec 0c             	sub    $0xc,%esp
  80148c:	6a 01                	push   $0x1
  80148e:	e8 f2 f9 ff ff       	call   800e85 <ipc_find_env>
  801493:	a3 00 60 80 00       	mov    %eax,0x806000
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	eb c5                	jmp    801462 <fsipc+0x12>

0080149d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c0:	e8 8b ff ff ff       	call   801450 <fsipc>
}
  8014c5:	c9                   	leave  
  8014c6:	c3                   	ret    

008014c7 <devfile_flush>:
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014dd:	b8 06 00 00 00       	mov    $0x6,%eax
  8014e2:	e8 69 ff ff ff       	call   801450 <fsipc>
}
  8014e7:	c9                   	leave  
  8014e8:	c3                   	ret    

008014e9 <devfile_stat>:
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 04             	sub    $0x4,%esp
  8014f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801503:	b8 05 00 00 00       	mov    $0x5,%eax
  801508:	e8 43 ff ff ff       	call   801450 <fsipc>
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 2c                	js     80153d <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	68 00 50 80 00       	push   $0x805000
  801519:	53                   	push   %ebx
  80151a:	e8 54 f2 ff ff       	call   800773 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80151f:	a1 80 50 80 00       	mov    0x805080,%eax
  801524:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80152a:	a1 84 50 80 00       	mov    0x805084,%eax
  80152f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <devfile_write>:
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	8b 45 10             	mov    0x10(%ebp),%eax
  80154b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801550:	39 d0                	cmp    %edx,%eax
  801552:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801555:	8b 55 08             	mov    0x8(%ebp),%edx
  801558:	8b 52 0c             	mov    0xc(%edx),%edx
  80155b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801561:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801566:	50                   	push   %eax
  801567:	ff 75 0c             	push   0xc(%ebp)
  80156a:	68 08 50 80 00       	push   $0x805008
  80156f:	e8 95 f3 ff ff       	call   800909 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801574:	ba 00 00 00 00       	mov    $0x0,%edx
  801579:	b8 04 00 00 00       	mov    $0x4,%eax
  80157e:	e8 cd fe ff ff       	call   801450 <fsipc>
}
  801583:	c9                   	leave  
  801584:	c3                   	ret    

00801585 <devfile_read>:
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	56                   	push   %esi
  801589:	53                   	push   %ebx
  80158a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80158d:	8b 45 08             	mov    0x8(%ebp),%eax
  801590:	8b 40 0c             	mov    0xc(%eax),%eax
  801593:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801598:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80159e:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8015a8:	e8 a3 fe ff ff       	call   801450 <fsipc>
  8015ad:	89 c3                	mov    %eax,%ebx
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 1f                	js     8015d2 <devfile_read+0x4d>
	assert(r <= n);
  8015b3:	39 f0                	cmp    %esi,%eax
  8015b5:	77 24                	ja     8015db <devfile_read+0x56>
	assert(r <= PGSIZE);
  8015b7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015bc:	7f 33                	jg     8015f1 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	50                   	push   %eax
  8015c2:	68 00 50 80 00       	push   $0x805000
  8015c7:	ff 75 0c             	push   0xc(%ebp)
  8015ca:	e8 3a f3 ff ff       	call   800909 <memmove>
	return r;
  8015cf:	83 c4 10             	add    $0x10,%esp
}
  8015d2:	89 d8                	mov    %ebx,%eax
  8015d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d7:	5b                   	pop    %ebx
  8015d8:	5e                   	pop    %esi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    
	assert(r <= n);
  8015db:	68 b8 26 80 00       	push   $0x8026b8
  8015e0:	68 bf 26 80 00       	push   $0x8026bf
  8015e5:	6a 7c                	push   $0x7c
  8015e7:	68 d4 26 80 00       	push   $0x8026d4
  8015ec:	e8 e1 09 00 00       	call   801fd2 <_panic>
	assert(r <= PGSIZE);
  8015f1:	68 df 26 80 00       	push   $0x8026df
  8015f6:	68 bf 26 80 00       	push   $0x8026bf
  8015fb:	6a 7d                	push   $0x7d
  8015fd:	68 d4 26 80 00       	push   $0x8026d4
  801602:	e8 cb 09 00 00       	call   801fd2 <_panic>

00801607 <open>:
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	56                   	push   %esi
  80160b:	53                   	push   %ebx
  80160c:	83 ec 1c             	sub    $0x1c,%esp
  80160f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801612:	56                   	push   %esi
  801613:	e8 20 f1 ff ff       	call   800738 <strlen>
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801620:	7f 6c                	jg     80168e <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	e8 bd f8 ff ff       	call   800eeb <fd_alloc>
  80162e:	89 c3                	mov    %eax,%ebx
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 3c                	js     801673 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	56                   	push   %esi
  80163b:	68 00 50 80 00       	push   $0x805000
  801640:	e8 2e f1 ff ff       	call   800773 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801645:	8b 45 0c             	mov    0xc(%ebp),%eax
  801648:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801650:	b8 01 00 00 00       	mov    $0x1,%eax
  801655:	e8 f6 fd ff ff       	call   801450 <fsipc>
  80165a:	89 c3                	mov    %eax,%ebx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 19                	js     80167c <open+0x75>
	return fd2num(fd);
  801663:	83 ec 0c             	sub    $0xc,%esp
  801666:	ff 75 f4             	push   -0xc(%ebp)
  801669:	e8 56 f8 ff ff       	call   800ec4 <fd2num>
  80166e:	89 c3                	mov    %eax,%ebx
  801670:	83 c4 10             	add    $0x10,%esp
}
  801673:	89 d8                	mov    %ebx,%eax
  801675:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    
		fd_close(fd, 0);
  80167c:	83 ec 08             	sub    $0x8,%esp
  80167f:	6a 00                	push   $0x0
  801681:	ff 75 f4             	push   -0xc(%ebp)
  801684:	e8 58 f9 ff ff       	call   800fe1 <fd_close>
		return r;
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	eb e5                	jmp    801673 <open+0x6c>
		return -E_BAD_PATH;
  80168e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801693:	eb de                	jmp    801673 <open+0x6c>

00801695 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80169b:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a5:	e8 a6 fd ff ff       	call   801450 <fsipc>
}
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016b2:	68 eb 26 80 00       	push   $0x8026eb
  8016b7:	ff 75 0c             	push   0xc(%ebp)
  8016ba:	e8 b4 f0 ff ff       	call   800773 <strcpy>
	return 0;
}
  8016bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <devsock_close>:
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 10             	sub    $0x10,%esp
  8016cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016d0:	53                   	push   %ebx
  8016d1:	e8 42 09 00 00       	call   802018 <pageref>
  8016d6:	89 c2                	mov    %eax,%edx
  8016d8:	83 c4 10             	add    $0x10,%esp
		return 0;
  8016db:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8016e0:	83 fa 01             	cmp    $0x1,%edx
  8016e3:	74 05                	je     8016ea <devsock_close+0x24>
}
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8016ea:	83 ec 0c             	sub    $0xc,%esp
  8016ed:	ff 73 0c             	push   0xc(%ebx)
  8016f0:	e8 b7 02 00 00       	call   8019ac <nsipc_close>
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	eb eb                	jmp    8016e5 <devsock_close+0x1f>

008016fa <devsock_write>:
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801700:	6a 00                	push   $0x0
  801702:	ff 75 10             	push   0x10(%ebp)
  801705:	ff 75 0c             	push   0xc(%ebp)
  801708:	8b 45 08             	mov    0x8(%ebp),%eax
  80170b:	ff 70 0c             	push   0xc(%eax)
  80170e:	e8 79 03 00 00       	call   801a8c <nsipc_send>
}
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <devsock_read>:
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80171b:	6a 00                	push   $0x0
  80171d:	ff 75 10             	push   0x10(%ebp)
  801720:	ff 75 0c             	push   0xc(%ebp)
  801723:	8b 45 08             	mov    0x8(%ebp),%eax
  801726:	ff 70 0c             	push   0xc(%eax)
  801729:	e8 ef 02 00 00       	call   801a1d <nsipc_recv>
}
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <fd2sockid>:
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801736:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801739:	52                   	push   %edx
  80173a:	50                   	push   %eax
  80173b:	e8 fb f7 ff ff       	call   800f3b <fd_lookup>
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	85 c0                	test   %eax,%eax
  801745:	78 10                	js     801757 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801750:	39 08                	cmp    %ecx,(%eax)
  801752:	75 05                	jne    801759 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801754:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801757:	c9                   	leave  
  801758:	c3                   	ret    
		return -E_NOT_SUPP;
  801759:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80175e:	eb f7                	jmp    801757 <fd2sockid+0x27>

00801760 <alloc_sockfd>:
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	56                   	push   %esi
  801764:	53                   	push   %ebx
  801765:	83 ec 1c             	sub    $0x1c,%esp
  801768:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80176a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176d:	50                   	push   %eax
  80176e:	e8 78 f7 ff ff       	call   800eeb <fd_alloc>
  801773:	89 c3                	mov    %eax,%ebx
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 43                	js     8017bf <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80177c:	83 ec 04             	sub    $0x4,%esp
  80177f:	68 07 04 00 00       	push   $0x407
  801784:	ff 75 f4             	push   -0xc(%ebp)
  801787:	6a 00                	push   $0x0
  801789:	e8 e1 f3 ff ff       	call   800b6f <sys_page_alloc>
  80178e:	89 c3                	mov    %eax,%ebx
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	85 c0                	test   %eax,%eax
  801795:	78 28                	js     8017bf <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017ac:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	50                   	push   %eax
  8017b3:	e8 0c f7 ff ff       	call   800ec4 <fd2num>
  8017b8:	89 c3                	mov    %eax,%ebx
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	eb 0c                	jmp    8017cb <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8017bf:	83 ec 0c             	sub    $0xc,%esp
  8017c2:	56                   	push   %esi
  8017c3:	e8 e4 01 00 00       	call   8019ac <nsipc_close>
		return r;
  8017c8:	83 c4 10             	add    $0x10,%esp
}
  8017cb:	89 d8                	mov    %ebx,%eax
  8017cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <accept>:
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	e8 4e ff ff ff       	call   801730 <fd2sockid>
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 1b                	js     801801 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017e6:	83 ec 04             	sub    $0x4,%esp
  8017e9:	ff 75 10             	push   0x10(%ebp)
  8017ec:	ff 75 0c             	push   0xc(%ebp)
  8017ef:	50                   	push   %eax
  8017f0:	e8 0e 01 00 00       	call   801903 <nsipc_accept>
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	78 05                	js     801801 <accept+0x2d>
	return alloc_sockfd(r);
  8017fc:	e8 5f ff ff ff       	call   801760 <alloc_sockfd>
}
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <bind>:
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801809:	8b 45 08             	mov    0x8(%ebp),%eax
  80180c:	e8 1f ff ff ff       	call   801730 <fd2sockid>
  801811:	85 c0                	test   %eax,%eax
  801813:	78 12                	js     801827 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801815:	83 ec 04             	sub    $0x4,%esp
  801818:	ff 75 10             	push   0x10(%ebp)
  80181b:	ff 75 0c             	push   0xc(%ebp)
  80181e:	50                   	push   %eax
  80181f:	e8 31 01 00 00       	call   801955 <nsipc_bind>
  801824:	83 c4 10             	add    $0x10,%esp
}
  801827:	c9                   	leave  
  801828:	c3                   	ret    

00801829 <shutdown>:
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80182f:	8b 45 08             	mov    0x8(%ebp),%eax
  801832:	e8 f9 fe ff ff       	call   801730 <fd2sockid>
  801837:	85 c0                	test   %eax,%eax
  801839:	78 0f                	js     80184a <shutdown+0x21>
	return nsipc_shutdown(r, how);
  80183b:	83 ec 08             	sub    $0x8,%esp
  80183e:	ff 75 0c             	push   0xc(%ebp)
  801841:	50                   	push   %eax
  801842:	e8 43 01 00 00       	call   80198a <nsipc_shutdown>
  801847:	83 c4 10             	add    $0x10,%esp
}
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <connect>:
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	e8 d6 fe ff ff       	call   801730 <fd2sockid>
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 12                	js     801870 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  80185e:	83 ec 04             	sub    $0x4,%esp
  801861:	ff 75 10             	push   0x10(%ebp)
  801864:	ff 75 0c             	push   0xc(%ebp)
  801867:	50                   	push   %eax
  801868:	e8 59 01 00 00       	call   8019c6 <nsipc_connect>
  80186d:	83 c4 10             	add    $0x10,%esp
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <listen>:
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	e8 b0 fe ff ff       	call   801730 <fd2sockid>
  801880:	85 c0                	test   %eax,%eax
  801882:	78 0f                	js     801893 <listen+0x21>
	return nsipc_listen(r, backlog);
  801884:	83 ec 08             	sub    $0x8,%esp
  801887:	ff 75 0c             	push   0xc(%ebp)
  80188a:	50                   	push   %eax
  80188b:	e8 6b 01 00 00       	call   8019fb <nsipc_listen>
  801890:	83 c4 10             	add    $0x10,%esp
}
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <socket>:

int
socket(int domain, int type, int protocol)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80189b:	ff 75 10             	push   0x10(%ebp)
  80189e:	ff 75 0c             	push   0xc(%ebp)
  8018a1:	ff 75 08             	push   0x8(%ebp)
  8018a4:	e8 41 02 00 00       	call   801aea <nsipc_socket>
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	78 05                	js     8018b5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018b0:	e8 ab fe ff ff       	call   801760 <alloc_sockfd>
}
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	53                   	push   %ebx
  8018bb:	83 ec 04             	sub    $0x4,%esp
  8018be:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018c0:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8018c7:	74 26                	je     8018ef <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018c9:	6a 07                	push   $0x7
  8018cb:	68 00 70 80 00       	push   $0x807000
  8018d0:	53                   	push   %ebx
  8018d1:	ff 35 00 80 80 00    	push   0x808000
  8018d7:	e8 55 f5 ff ff       	call   800e31 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018dc:	83 c4 0c             	add    $0xc,%esp
  8018df:	6a 00                	push   $0x0
  8018e1:	6a 00                	push   $0x0
  8018e3:	6a 00                	push   $0x0
  8018e5:	e8 d7 f4 ff ff       	call   800dc1 <ipc_recv>
}
  8018ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018ef:	83 ec 0c             	sub    $0xc,%esp
  8018f2:	6a 02                	push   $0x2
  8018f4:	e8 8c f5 ff ff       	call   800e85 <ipc_find_env>
  8018f9:	a3 00 80 80 00       	mov    %eax,0x808000
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	eb c6                	jmp    8018c9 <nsipc+0x12>

00801903 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	56                   	push   %esi
  801907:	53                   	push   %ebx
  801908:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
  80190e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801913:	8b 06                	mov    (%esi),%eax
  801915:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80191a:	b8 01 00 00 00       	mov    $0x1,%eax
  80191f:	e8 93 ff ff ff       	call   8018b7 <nsipc>
  801924:	89 c3                	mov    %eax,%ebx
  801926:	85 c0                	test   %eax,%eax
  801928:	79 09                	jns    801933 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80192a:	89 d8                	mov    %ebx,%eax
  80192c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192f:	5b                   	pop    %ebx
  801930:	5e                   	pop    %esi
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801933:	83 ec 04             	sub    $0x4,%esp
  801936:	ff 35 10 70 80 00    	push   0x807010
  80193c:	68 00 70 80 00       	push   $0x807000
  801941:	ff 75 0c             	push   0xc(%ebp)
  801944:	e8 c0 ef ff ff       	call   800909 <memmove>
		*addrlen = ret->ret_addrlen;
  801949:	a1 10 70 80 00       	mov    0x807010,%eax
  80194e:	89 06                	mov    %eax,(%esi)
  801950:	83 c4 10             	add    $0x10,%esp
	return r;
  801953:	eb d5                	jmp    80192a <nsipc_accept+0x27>

00801955 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	53                   	push   %ebx
  801959:	83 ec 08             	sub    $0x8,%esp
  80195c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80195f:	8b 45 08             	mov    0x8(%ebp),%eax
  801962:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801967:	53                   	push   %ebx
  801968:	ff 75 0c             	push   0xc(%ebp)
  80196b:	68 04 70 80 00       	push   $0x807004
  801970:	e8 94 ef ff ff       	call   800909 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801975:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80197b:	b8 02 00 00 00       	mov    $0x2,%eax
  801980:	e8 32 ff ff ff       	call   8018b7 <nsipc>
}
  801985:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801990:	8b 45 08             	mov    0x8(%ebp),%eax
  801993:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801998:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8019a0:	b8 03 00 00 00       	mov    $0x3,%eax
  8019a5:	e8 0d ff ff ff       	call   8018b7 <nsipc>
}
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <nsipc_close>:

int
nsipc_close(int s)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b5:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8019ba:	b8 04 00 00 00       	mov    $0x4,%eax
  8019bf:	e8 f3 fe ff ff       	call   8018b7 <nsipc>
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	53                   	push   %ebx
  8019ca:	83 ec 08             	sub    $0x8,%esp
  8019cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d3:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019d8:	53                   	push   %ebx
  8019d9:	ff 75 0c             	push   0xc(%ebp)
  8019dc:	68 04 70 80 00       	push   $0x807004
  8019e1:	e8 23 ef ff ff       	call   800909 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019e6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8019ec:	b8 05 00 00 00       	mov    $0x5,%eax
  8019f1:	e8 c1 fe ff ff       	call   8018b7 <nsipc>
}
  8019f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f9:	c9                   	leave  
  8019fa:	c3                   	ret    

008019fb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a01:	8b 45 08             	mov    0x8(%ebp),%eax
  801a04:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801a11:	b8 06 00 00 00       	mov    $0x6,%eax
  801a16:	e8 9c fe ff ff       	call   8018b7 <nsipc>
}
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a25:	8b 45 08             	mov    0x8(%ebp),%eax
  801a28:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801a2d:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801a33:	8b 45 14             	mov    0x14(%ebp),%eax
  801a36:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a3b:	b8 07 00 00 00       	mov    $0x7,%eax
  801a40:	e8 72 fe ff ff       	call   8018b7 <nsipc>
  801a45:	89 c3                	mov    %eax,%ebx
  801a47:	85 c0                	test   %eax,%eax
  801a49:	78 22                	js     801a6d <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801a4b:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801a50:	39 c6                	cmp    %eax,%esi
  801a52:	0f 4e c6             	cmovle %esi,%eax
  801a55:	39 c3                	cmp    %eax,%ebx
  801a57:	7f 1d                	jg     801a76 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a59:	83 ec 04             	sub    $0x4,%esp
  801a5c:	53                   	push   %ebx
  801a5d:	68 00 70 80 00       	push   $0x807000
  801a62:	ff 75 0c             	push   0xc(%ebp)
  801a65:	e8 9f ee ff ff       	call   800909 <memmove>
  801a6a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a6d:	89 d8                	mov    %ebx,%eax
  801a6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a72:	5b                   	pop    %ebx
  801a73:	5e                   	pop    %esi
  801a74:	5d                   	pop    %ebp
  801a75:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801a76:	68 f7 26 80 00       	push   $0x8026f7
  801a7b:	68 bf 26 80 00       	push   $0x8026bf
  801a80:	6a 62                	push   $0x62
  801a82:	68 0c 27 80 00       	push   $0x80270c
  801a87:	e8 46 05 00 00       	call   801fd2 <_panic>

00801a8c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 04             	sub    $0x4,%esp
  801a93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801a9e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801aa4:	7f 2e                	jg     801ad4 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801aa6:	83 ec 04             	sub    $0x4,%esp
  801aa9:	53                   	push   %ebx
  801aaa:	ff 75 0c             	push   0xc(%ebp)
  801aad:	68 0c 70 80 00       	push   $0x80700c
  801ab2:	e8 52 ee ff ff       	call   800909 <memmove>
	nsipcbuf.send.req_size = size;
  801ab7:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801abd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801ac5:	b8 08 00 00 00       	mov    $0x8,%eax
  801aca:	e8 e8 fd ff ff       	call   8018b7 <nsipc>
}
  801acf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad2:	c9                   	leave  
  801ad3:	c3                   	ret    
	assert(size < 1600);
  801ad4:	68 18 27 80 00       	push   $0x802718
  801ad9:	68 bf 26 80 00       	push   $0x8026bf
  801ade:	6a 6d                	push   $0x6d
  801ae0:	68 0c 27 80 00       	push   $0x80270c
  801ae5:	e8 e8 04 00 00       	call   801fd2 <_panic>

00801aea <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afb:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801b00:	8b 45 10             	mov    0x10(%ebp),%eax
  801b03:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801b08:	b8 09 00 00 00       	mov    $0x9,%eax
  801b0d:	e8 a5 fd ff ff       	call   8018b7 <nsipc>
}
  801b12:	c9                   	leave  
  801b13:	c3                   	ret    

00801b14 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b1c:	83 ec 0c             	sub    $0xc,%esp
  801b1f:	ff 75 08             	push   0x8(%ebp)
  801b22:	e8 ad f3 ff ff       	call   800ed4 <fd2data>
  801b27:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b29:	83 c4 08             	add    $0x8,%esp
  801b2c:	68 24 27 80 00       	push   $0x802724
  801b31:	53                   	push   %ebx
  801b32:	e8 3c ec ff ff       	call   800773 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b37:	8b 46 04             	mov    0x4(%esi),%eax
  801b3a:	2b 06                	sub    (%esi),%eax
  801b3c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b42:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b49:	00 00 00 
	stat->st_dev = &devpipe;
  801b4c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b53:	30 80 00 
	return 0;
}
  801b56:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5e:	5b                   	pop    %ebx
  801b5f:	5e                   	pop    %esi
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    

00801b62 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	53                   	push   %ebx
  801b66:	83 ec 0c             	sub    $0xc,%esp
  801b69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b6c:	53                   	push   %ebx
  801b6d:	6a 00                	push   $0x0
  801b6f:	e8 80 f0 ff ff       	call   800bf4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b74:	89 1c 24             	mov    %ebx,(%esp)
  801b77:	e8 58 f3 ff ff       	call   800ed4 <fd2data>
  801b7c:	83 c4 08             	add    $0x8,%esp
  801b7f:	50                   	push   %eax
  801b80:	6a 00                	push   $0x0
  801b82:	e8 6d f0 ff ff       	call   800bf4 <sys_page_unmap>
}
  801b87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <_pipeisclosed>:
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	57                   	push   %edi
  801b90:	56                   	push   %esi
  801b91:	53                   	push   %ebx
  801b92:	83 ec 1c             	sub    $0x1c,%esp
  801b95:	89 c7                	mov    %eax,%edi
  801b97:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b99:	a1 00 40 80 00       	mov    0x804000,%eax
  801b9e:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ba1:	83 ec 0c             	sub    $0xc,%esp
  801ba4:	57                   	push   %edi
  801ba5:	e8 6e 04 00 00       	call   802018 <pageref>
  801baa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bad:	89 34 24             	mov    %esi,(%esp)
  801bb0:	e8 63 04 00 00       	call   802018 <pageref>
		nn = thisenv->env_runs;
  801bb5:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801bbb:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801bbe:	83 c4 10             	add    $0x10,%esp
  801bc1:	39 cb                	cmp    %ecx,%ebx
  801bc3:	74 1b                	je     801be0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bc5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bc8:	75 cf                	jne    801b99 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bca:	8b 42 68             	mov    0x68(%edx),%eax
  801bcd:	6a 01                	push   $0x1
  801bcf:	50                   	push   %eax
  801bd0:	53                   	push   %ebx
  801bd1:	68 2b 27 80 00       	push   $0x80272b
  801bd6:	e8 be e5 ff ff       	call   800199 <cprintf>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	eb b9                	jmp    801b99 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801be0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801be3:	0f 94 c0             	sete   %al
  801be6:	0f b6 c0             	movzbl %al,%eax
}
  801be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bec:	5b                   	pop    %ebx
  801bed:	5e                   	pop    %esi
  801bee:	5f                   	pop    %edi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <devpipe_write>:
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	57                   	push   %edi
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 28             	sub    $0x28,%esp
  801bfa:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801bfd:	56                   	push   %esi
  801bfe:	e8 d1 f2 ff ff       	call   800ed4 <fd2data>
  801c03:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	bf 00 00 00 00       	mov    $0x0,%edi
  801c0d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c10:	75 09                	jne    801c1b <devpipe_write+0x2a>
	return i;
  801c12:	89 f8                	mov    %edi,%eax
  801c14:	eb 23                	jmp    801c39 <devpipe_write+0x48>
			sys_yield();
  801c16:	e8 35 ef ff ff       	call   800b50 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c1b:	8b 43 04             	mov    0x4(%ebx),%eax
  801c1e:	8b 0b                	mov    (%ebx),%ecx
  801c20:	8d 51 20             	lea    0x20(%ecx),%edx
  801c23:	39 d0                	cmp    %edx,%eax
  801c25:	72 1a                	jb     801c41 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801c27:	89 da                	mov    %ebx,%edx
  801c29:	89 f0                	mov    %esi,%eax
  801c2b:	e8 5c ff ff ff       	call   801b8c <_pipeisclosed>
  801c30:	85 c0                	test   %eax,%eax
  801c32:	74 e2                	je     801c16 <devpipe_write+0x25>
				return 0;
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3c:	5b                   	pop    %ebx
  801c3d:	5e                   	pop    %esi
  801c3e:	5f                   	pop    %edi
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c44:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c48:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c4b:	89 c2                	mov    %eax,%edx
  801c4d:	c1 fa 1f             	sar    $0x1f,%edx
  801c50:	89 d1                	mov    %edx,%ecx
  801c52:	c1 e9 1b             	shr    $0x1b,%ecx
  801c55:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c58:	83 e2 1f             	and    $0x1f,%edx
  801c5b:	29 ca                	sub    %ecx,%edx
  801c5d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c61:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c65:	83 c0 01             	add    $0x1,%eax
  801c68:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c6b:	83 c7 01             	add    $0x1,%edi
  801c6e:	eb 9d                	jmp    801c0d <devpipe_write+0x1c>

00801c70 <devpipe_read>:
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	57                   	push   %edi
  801c74:	56                   	push   %esi
  801c75:	53                   	push   %ebx
  801c76:	83 ec 18             	sub    $0x18,%esp
  801c79:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c7c:	57                   	push   %edi
  801c7d:	e8 52 f2 ff ff       	call   800ed4 <fd2data>
  801c82:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	be 00 00 00 00       	mov    $0x0,%esi
  801c8c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c8f:	75 13                	jne    801ca4 <devpipe_read+0x34>
	return i;
  801c91:	89 f0                	mov    %esi,%eax
  801c93:	eb 02                	jmp    801c97 <devpipe_read+0x27>
				return i;
  801c95:	89 f0                	mov    %esi,%eax
}
  801c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5f                   	pop    %edi
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    
			sys_yield();
  801c9f:	e8 ac ee ff ff       	call   800b50 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ca4:	8b 03                	mov    (%ebx),%eax
  801ca6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ca9:	75 18                	jne    801cc3 <devpipe_read+0x53>
			if (i > 0)
  801cab:	85 f6                	test   %esi,%esi
  801cad:	75 e6                	jne    801c95 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801caf:	89 da                	mov    %ebx,%edx
  801cb1:	89 f8                	mov    %edi,%eax
  801cb3:	e8 d4 fe ff ff       	call   801b8c <_pipeisclosed>
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	74 e3                	je     801c9f <devpipe_read+0x2f>
				return 0;
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc1:	eb d4                	jmp    801c97 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cc3:	99                   	cltd   
  801cc4:	c1 ea 1b             	shr    $0x1b,%edx
  801cc7:	01 d0                	add    %edx,%eax
  801cc9:	83 e0 1f             	and    $0x1f,%eax
  801ccc:	29 d0                	sub    %edx,%eax
  801cce:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cd9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801cdc:	83 c6 01             	add    $0x1,%esi
  801cdf:	eb ab                	jmp    801c8c <devpipe_read+0x1c>

00801ce1 <pipe>:
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	56                   	push   %esi
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ce9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cec:	50                   	push   %eax
  801ced:	e8 f9 f1 ff ff       	call   800eeb <fd_alloc>
  801cf2:	89 c3                	mov    %eax,%ebx
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	0f 88 23 01 00 00    	js     801e22 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cff:	83 ec 04             	sub    $0x4,%esp
  801d02:	68 07 04 00 00       	push   $0x407
  801d07:	ff 75 f4             	push   -0xc(%ebp)
  801d0a:	6a 00                	push   $0x0
  801d0c:	e8 5e ee ff ff       	call   800b6f <sys_page_alloc>
  801d11:	89 c3                	mov    %eax,%ebx
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	85 c0                	test   %eax,%eax
  801d18:	0f 88 04 01 00 00    	js     801e22 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801d1e:	83 ec 0c             	sub    $0xc,%esp
  801d21:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d24:	50                   	push   %eax
  801d25:	e8 c1 f1 ff ff       	call   800eeb <fd_alloc>
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	0f 88 db 00 00 00    	js     801e12 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d37:	83 ec 04             	sub    $0x4,%esp
  801d3a:	68 07 04 00 00       	push   $0x407
  801d3f:	ff 75 f0             	push   -0x10(%ebp)
  801d42:	6a 00                	push   $0x0
  801d44:	e8 26 ee ff ff       	call   800b6f <sys_page_alloc>
  801d49:	89 c3                	mov    %eax,%ebx
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	0f 88 bc 00 00 00    	js     801e12 <pipe+0x131>
	va = fd2data(fd0);
  801d56:	83 ec 0c             	sub    $0xc,%esp
  801d59:	ff 75 f4             	push   -0xc(%ebp)
  801d5c:	e8 73 f1 ff ff       	call   800ed4 <fd2data>
  801d61:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d63:	83 c4 0c             	add    $0xc,%esp
  801d66:	68 07 04 00 00       	push   $0x407
  801d6b:	50                   	push   %eax
  801d6c:	6a 00                	push   $0x0
  801d6e:	e8 fc ed ff ff       	call   800b6f <sys_page_alloc>
  801d73:	89 c3                	mov    %eax,%ebx
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	0f 88 82 00 00 00    	js     801e02 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d80:	83 ec 0c             	sub    $0xc,%esp
  801d83:	ff 75 f0             	push   -0x10(%ebp)
  801d86:	e8 49 f1 ff ff       	call   800ed4 <fd2data>
  801d8b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d92:	50                   	push   %eax
  801d93:	6a 00                	push   $0x0
  801d95:	56                   	push   %esi
  801d96:	6a 00                	push   $0x0
  801d98:	e8 15 ee ff ff       	call   800bb2 <sys_page_map>
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	83 c4 20             	add    $0x20,%esp
  801da2:	85 c0                	test   %eax,%eax
  801da4:	78 4e                	js     801df4 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801da6:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801dab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dae:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801db0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801db3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801dba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dbd:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801dc9:	83 ec 0c             	sub    $0xc,%esp
  801dcc:	ff 75 f4             	push   -0xc(%ebp)
  801dcf:	e8 f0 f0 ff ff       	call   800ec4 <fd2num>
  801dd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dd9:	83 c4 04             	add    $0x4,%esp
  801ddc:	ff 75 f0             	push   -0x10(%ebp)
  801ddf:	e8 e0 f0 ff ff       	call   800ec4 <fd2num>
  801de4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	bb 00 00 00 00       	mov    $0x0,%ebx
  801df2:	eb 2e                	jmp    801e22 <pipe+0x141>
	sys_page_unmap(0, va);
  801df4:	83 ec 08             	sub    $0x8,%esp
  801df7:	56                   	push   %esi
  801df8:	6a 00                	push   $0x0
  801dfa:	e8 f5 ed ff ff       	call   800bf4 <sys_page_unmap>
  801dff:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e02:	83 ec 08             	sub    $0x8,%esp
  801e05:	ff 75 f0             	push   -0x10(%ebp)
  801e08:	6a 00                	push   $0x0
  801e0a:	e8 e5 ed ff ff       	call   800bf4 <sys_page_unmap>
  801e0f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e12:	83 ec 08             	sub    $0x8,%esp
  801e15:	ff 75 f4             	push   -0xc(%ebp)
  801e18:	6a 00                	push   $0x0
  801e1a:	e8 d5 ed ff ff       	call   800bf4 <sys_page_unmap>
  801e1f:	83 c4 10             	add    $0x10,%esp
}
  801e22:	89 d8                	mov    %ebx,%eax
  801e24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    

00801e2b <pipeisclosed>:
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	ff 75 08             	push   0x8(%ebp)
  801e38:	e8 fe f0 ff ff       	call   800f3b <fd_lookup>
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	85 c0                	test   %eax,%eax
  801e42:	78 18                	js     801e5c <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e44:	83 ec 0c             	sub    $0xc,%esp
  801e47:	ff 75 f4             	push   -0xc(%ebp)
  801e4a:	e8 85 f0 ff ff       	call   800ed4 <fd2data>
  801e4f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e54:	e8 33 fd ff ff       	call   801b8c <_pipeisclosed>
  801e59:	83 c4 10             	add    $0x10,%esp
}
  801e5c:	c9                   	leave  
  801e5d:	c3                   	ret    

00801e5e <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e63:	c3                   	ret    

00801e64 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e6a:	68 43 27 80 00       	push   $0x802743
  801e6f:	ff 75 0c             	push   0xc(%ebp)
  801e72:	e8 fc e8 ff ff       	call   800773 <strcpy>
	return 0;
}
  801e77:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7c:	c9                   	leave  
  801e7d:	c3                   	ret    

00801e7e <devcons_write>:
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e8a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e8f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e95:	eb 2e                	jmp    801ec5 <devcons_write+0x47>
		m = n - tot;
  801e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e9a:	29 f3                	sub    %esi,%ebx
  801e9c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ea1:	39 c3                	cmp    %eax,%ebx
  801ea3:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ea6:	83 ec 04             	sub    $0x4,%esp
  801ea9:	53                   	push   %ebx
  801eaa:	89 f0                	mov    %esi,%eax
  801eac:	03 45 0c             	add    0xc(%ebp),%eax
  801eaf:	50                   	push   %eax
  801eb0:	57                   	push   %edi
  801eb1:	e8 53 ea ff ff       	call   800909 <memmove>
		sys_cputs(buf, m);
  801eb6:	83 c4 08             	add    $0x8,%esp
  801eb9:	53                   	push   %ebx
  801eba:	57                   	push   %edi
  801ebb:	e8 f3 eb ff ff       	call   800ab3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ec0:	01 de                	add    %ebx,%esi
  801ec2:	83 c4 10             	add    $0x10,%esp
  801ec5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ec8:	72 cd                	jb     801e97 <devcons_write+0x19>
}
  801eca:	89 f0                	mov    %esi,%eax
  801ecc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5f                   	pop    %edi
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <devcons_read>:
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	83 ec 08             	sub    $0x8,%esp
  801eda:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801edf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ee3:	75 07                	jne    801eec <devcons_read+0x18>
  801ee5:	eb 1f                	jmp    801f06 <devcons_read+0x32>
		sys_yield();
  801ee7:	e8 64 ec ff ff       	call   800b50 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801eec:	e8 e0 eb ff ff       	call   800ad1 <sys_cgetc>
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	74 f2                	je     801ee7 <devcons_read+0x13>
	if (c < 0)
  801ef5:	78 0f                	js     801f06 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801ef7:	83 f8 04             	cmp    $0x4,%eax
  801efa:	74 0c                	je     801f08 <devcons_read+0x34>
	*(char*)vbuf = c;
  801efc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eff:	88 02                	mov    %al,(%edx)
	return 1;
  801f01:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    
		return 0;
  801f08:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0d:	eb f7                	jmp    801f06 <devcons_read+0x32>

00801f0f <cputchar>:
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f15:	8b 45 08             	mov    0x8(%ebp),%eax
  801f18:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f1b:	6a 01                	push   $0x1
  801f1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f20:	50                   	push   %eax
  801f21:	e8 8d eb ff ff       	call   800ab3 <sys_cputs>
}
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    

00801f2b <getchar>:
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f31:	6a 01                	push   $0x1
  801f33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f36:	50                   	push   %eax
  801f37:	6a 00                	push   $0x0
  801f39:	e8 66 f2 ff ff       	call   8011a4 <read>
	if (r < 0)
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	85 c0                	test   %eax,%eax
  801f43:	78 06                	js     801f4b <getchar+0x20>
	if (r < 1)
  801f45:	74 06                	je     801f4d <getchar+0x22>
	return c;
  801f47:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f4b:	c9                   	leave  
  801f4c:	c3                   	ret    
		return -E_EOF;
  801f4d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f52:	eb f7                	jmp    801f4b <getchar+0x20>

00801f54 <iscons>:
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5d:	50                   	push   %eax
  801f5e:	ff 75 08             	push   0x8(%ebp)
  801f61:	e8 d5 ef ff ff       	call   800f3b <fd_lookup>
  801f66:	83 c4 10             	add    $0x10,%esp
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	78 11                	js     801f7e <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f70:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f76:	39 10                	cmp    %edx,(%eax)
  801f78:	0f 94 c0             	sete   %al
  801f7b:	0f b6 c0             	movzbl %al,%eax
}
  801f7e:	c9                   	leave  
  801f7f:	c3                   	ret    

00801f80 <opencons>:
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f89:	50                   	push   %eax
  801f8a:	e8 5c ef ff ff       	call   800eeb <fd_alloc>
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	85 c0                	test   %eax,%eax
  801f94:	78 3a                	js     801fd0 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f96:	83 ec 04             	sub    $0x4,%esp
  801f99:	68 07 04 00 00       	push   $0x407
  801f9e:	ff 75 f4             	push   -0xc(%ebp)
  801fa1:	6a 00                	push   $0x0
  801fa3:	e8 c7 eb ff ff       	call   800b6f <sys_page_alloc>
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	85 c0                	test   %eax,%eax
  801fad:	78 21                	js     801fd0 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fb8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fc4:	83 ec 0c             	sub    $0xc,%esp
  801fc7:	50                   	push   %eax
  801fc8:	e8 f7 ee ff ff       	call   800ec4 <fd2num>
  801fcd:	83 c4 10             	add    $0x10,%esp
}
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	56                   	push   %esi
  801fd6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fd7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fda:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fe0:	e8 4c eb ff ff       	call   800b31 <sys_getenvid>
  801fe5:	83 ec 0c             	sub    $0xc,%esp
  801fe8:	ff 75 0c             	push   0xc(%ebp)
  801feb:	ff 75 08             	push   0x8(%ebp)
  801fee:	56                   	push   %esi
  801fef:	50                   	push   %eax
  801ff0:	68 50 27 80 00       	push   $0x802750
  801ff5:	e8 9f e1 ff ff       	call   800199 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ffa:	83 c4 18             	add    $0x18,%esp
  801ffd:	53                   	push   %ebx
  801ffe:	ff 75 10             	push   0x10(%ebp)
  802001:	e8 42 e1 ff ff       	call   800148 <vcprintf>
	cprintf("\n");
  802006:	c7 04 24 3c 27 80 00 	movl   $0x80273c,(%esp)
  80200d:	e8 87 e1 ff ff       	call   800199 <cprintf>
  802012:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802015:	cc                   	int3   
  802016:	eb fd                	jmp    802015 <_panic+0x43>

00802018 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80201e:	89 c2                	mov    %eax,%edx
  802020:	c1 ea 16             	shr    $0x16,%edx
  802023:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80202a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80202f:	f6 c1 01             	test   $0x1,%cl
  802032:	74 1c                	je     802050 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802034:	c1 e8 0c             	shr    $0xc,%eax
  802037:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80203e:	a8 01                	test   $0x1,%al
  802040:	74 0e                	je     802050 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802042:	c1 e8 0c             	shr    $0xc,%eax
  802045:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80204c:	ef 
  80204d:	0f b7 d2             	movzwl %dx,%edx
}
  802050:	89 d0                	mov    %edx,%eax
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__udivdi3>:
  802060:	f3 0f 1e fb          	endbr32 
  802064:	55                   	push   %ebp
  802065:	57                   	push   %edi
  802066:	56                   	push   %esi
  802067:	53                   	push   %ebx
  802068:	83 ec 1c             	sub    $0x1c,%esp
  80206b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80206f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802073:	8b 74 24 34          	mov    0x34(%esp),%esi
  802077:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80207b:	85 c0                	test   %eax,%eax
  80207d:	75 19                	jne    802098 <__udivdi3+0x38>
  80207f:	39 f3                	cmp    %esi,%ebx
  802081:	76 4d                	jbe    8020d0 <__udivdi3+0x70>
  802083:	31 ff                	xor    %edi,%edi
  802085:	89 e8                	mov    %ebp,%eax
  802087:	89 f2                	mov    %esi,%edx
  802089:	f7 f3                	div    %ebx
  80208b:	89 fa                	mov    %edi,%edx
  80208d:	83 c4 1c             	add    $0x1c,%esp
  802090:	5b                   	pop    %ebx
  802091:	5e                   	pop    %esi
  802092:	5f                   	pop    %edi
  802093:	5d                   	pop    %ebp
  802094:	c3                   	ret    
  802095:	8d 76 00             	lea    0x0(%esi),%esi
  802098:	39 f0                	cmp    %esi,%eax
  80209a:	76 14                	jbe    8020b0 <__udivdi3+0x50>
  80209c:	31 ff                	xor    %edi,%edi
  80209e:	31 c0                	xor    %eax,%eax
  8020a0:	89 fa                	mov    %edi,%edx
  8020a2:	83 c4 1c             	add    $0x1c,%esp
  8020a5:	5b                   	pop    %ebx
  8020a6:	5e                   	pop    %esi
  8020a7:	5f                   	pop    %edi
  8020a8:	5d                   	pop    %ebp
  8020a9:	c3                   	ret    
  8020aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b0:	0f bd f8             	bsr    %eax,%edi
  8020b3:	83 f7 1f             	xor    $0x1f,%edi
  8020b6:	75 48                	jne    802100 <__udivdi3+0xa0>
  8020b8:	39 f0                	cmp    %esi,%eax
  8020ba:	72 06                	jb     8020c2 <__udivdi3+0x62>
  8020bc:	31 c0                	xor    %eax,%eax
  8020be:	39 eb                	cmp    %ebp,%ebx
  8020c0:	77 de                	ja     8020a0 <__udivdi3+0x40>
  8020c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c7:	eb d7                	jmp    8020a0 <__udivdi3+0x40>
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 d9                	mov    %ebx,%ecx
  8020d2:	85 db                	test   %ebx,%ebx
  8020d4:	75 0b                	jne    8020e1 <__udivdi3+0x81>
  8020d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	f7 f3                	div    %ebx
  8020df:	89 c1                	mov    %eax,%ecx
  8020e1:	31 d2                	xor    %edx,%edx
  8020e3:	89 f0                	mov    %esi,%eax
  8020e5:	f7 f1                	div    %ecx
  8020e7:	89 c6                	mov    %eax,%esi
  8020e9:	89 e8                	mov    %ebp,%eax
  8020eb:	89 f7                	mov    %esi,%edi
  8020ed:	f7 f1                	div    %ecx
  8020ef:	89 fa                	mov    %edi,%edx
  8020f1:	83 c4 1c             	add    $0x1c,%esp
  8020f4:	5b                   	pop    %ebx
  8020f5:	5e                   	pop    %esi
  8020f6:	5f                   	pop    %edi
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 f9                	mov    %edi,%ecx
  802102:	ba 20 00 00 00       	mov    $0x20,%edx
  802107:	29 fa                	sub    %edi,%edx
  802109:	d3 e0                	shl    %cl,%eax
  80210b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80210f:	89 d1                	mov    %edx,%ecx
  802111:	89 d8                	mov    %ebx,%eax
  802113:	d3 e8                	shr    %cl,%eax
  802115:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802119:	09 c1                	or     %eax,%ecx
  80211b:	89 f0                	mov    %esi,%eax
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f9                	mov    %edi,%ecx
  802123:	d3 e3                	shl    %cl,%ebx
  802125:	89 d1                	mov    %edx,%ecx
  802127:	d3 e8                	shr    %cl,%eax
  802129:	89 f9                	mov    %edi,%ecx
  80212b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80212f:	89 eb                	mov    %ebp,%ebx
  802131:	d3 e6                	shl    %cl,%esi
  802133:	89 d1                	mov    %edx,%ecx
  802135:	d3 eb                	shr    %cl,%ebx
  802137:	09 f3                	or     %esi,%ebx
  802139:	89 c6                	mov    %eax,%esi
  80213b:	89 f2                	mov    %esi,%edx
  80213d:	89 d8                	mov    %ebx,%eax
  80213f:	f7 74 24 08          	divl   0x8(%esp)
  802143:	89 d6                	mov    %edx,%esi
  802145:	89 c3                	mov    %eax,%ebx
  802147:	f7 64 24 0c          	mull   0xc(%esp)
  80214b:	39 d6                	cmp    %edx,%esi
  80214d:	72 19                	jb     802168 <__udivdi3+0x108>
  80214f:	89 f9                	mov    %edi,%ecx
  802151:	d3 e5                	shl    %cl,%ebp
  802153:	39 c5                	cmp    %eax,%ebp
  802155:	73 04                	jae    80215b <__udivdi3+0xfb>
  802157:	39 d6                	cmp    %edx,%esi
  802159:	74 0d                	je     802168 <__udivdi3+0x108>
  80215b:	89 d8                	mov    %ebx,%eax
  80215d:	31 ff                	xor    %edi,%edi
  80215f:	e9 3c ff ff ff       	jmp    8020a0 <__udivdi3+0x40>
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80216b:	31 ff                	xor    %edi,%edi
  80216d:	e9 2e ff ff ff       	jmp    8020a0 <__udivdi3+0x40>
  802172:	66 90                	xchg   %ax,%ax
  802174:	66 90                	xchg   %ax,%ax
  802176:	66 90                	xchg   %ax,%ax
  802178:	66 90                	xchg   %ax,%ax
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__umoddi3>:
  802180:	f3 0f 1e fb          	endbr32 
  802184:	55                   	push   %ebp
  802185:	57                   	push   %edi
  802186:	56                   	push   %esi
  802187:	53                   	push   %ebx
  802188:	83 ec 1c             	sub    $0x1c,%esp
  80218b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80218f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802193:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802197:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80219b:	89 f0                	mov    %esi,%eax
  80219d:	89 da                	mov    %ebx,%edx
  80219f:	85 ff                	test   %edi,%edi
  8021a1:	75 15                	jne    8021b8 <__umoddi3+0x38>
  8021a3:	39 dd                	cmp    %ebx,%ebp
  8021a5:	76 39                	jbe    8021e0 <__umoddi3+0x60>
  8021a7:	f7 f5                	div    %ebp
  8021a9:	89 d0                	mov    %edx,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	83 c4 1c             	add    $0x1c,%esp
  8021b0:	5b                   	pop    %ebx
  8021b1:	5e                   	pop    %esi
  8021b2:	5f                   	pop    %edi
  8021b3:	5d                   	pop    %ebp
  8021b4:	c3                   	ret    
  8021b5:	8d 76 00             	lea    0x0(%esi),%esi
  8021b8:	39 df                	cmp    %ebx,%edi
  8021ba:	77 f1                	ja     8021ad <__umoddi3+0x2d>
  8021bc:	0f bd cf             	bsr    %edi,%ecx
  8021bf:	83 f1 1f             	xor    $0x1f,%ecx
  8021c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021c6:	75 40                	jne    802208 <__umoddi3+0x88>
  8021c8:	39 df                	cmp    %ebx,%edi
  8021ca:	72 04                	jb     8021d0 <__umoddi3+0x50>
  8021cc:	39 f5                	cmp    %esi,%ebp
  8021ce:	77 dd                	ja     8021ad <__umoddi3+0x2d>
  8021d0:	89 da                	mov    %ebx,%edx
  8021d2:	89 f0                	mov    %esi,%eax
  8021d4:	29 e8                	sub    %ebp,%eax
  8021d6:	19 fa                	sbb    %edi,%edx
  8021d8:	eb d3                	jmp    8021ad <__umoddi3+0x2d>
  8021da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e0:	89 e9                	mov    %ebp,%ecx
  8021e2:	85 ed                	test   %ebp,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x71>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f5                	div    %ebp
  8021ef:	89 c1                	mov    %eax,%ecx
  8021f1:	89 d8                	mov    %ebx,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f1                	div    %ecx
  8021f7:	89 f0                	mov    %esi,%eax
  8021f9:	f7 f1                	div    %ecx
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	31 d2                	xor    %edx,%edx
  8021ff:	eb ac                	jmp    8021ad <__umoddi3+0x2d>
  802201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802208:	8b 44 24 04          	mov    0x4(%esp),%eax
  80220c:	ba 20 00 00 00       	mov    $0x20,%edx
  802211:	29 c2                	sub    %eax,%edx
  802213:	89 c1                	mov    %eax,%ecx
  802215:	89 e8                	mov    %ebp,%eax
  802217:	d3 e7                	shl    %cl,%edi
  802219:	89 d1                	mov    %edx,%ecx
  80221b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80221f:	d3 e8                	shr    %cl,%eax
  802221:	89 c1                	mov    %eax,%ecx
  802223:	8b 44 24 04          	mov    0x4(%esp),%eax
  802227:	09 f9                	or     %edi,%ecx
  802229:	89 df                	mov    %ebx,%edi
  80222b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80222f:	89 c1                	mov    %eax,%ecx
  802231:	d3 e5                	shl    %cl,%ebp
  802233:	89 d1                	mov    %edx,%ecx
  802235:	d3 ef                	shr    %cl,%edi
  802237:	89 c1                	mov    %eax,%ecx
  802239:	89 f0                	mov    %esi,%eax
  80223b:	d3 e3                	shl    %cl,%ebx
  80223d:	89 d1                	mov    %edx,%ecx
  80223f:	89 fa                	mov    %edi,%edx
  802241:	d3 e8                	shr    %cl,%eax
  802243:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802248:	09 d8                	or     %ebx,%eax
  80224a:	f7 74 24 08          	divl   0x8(%esp)
  80224e:	89 d3                	mov    %edx,%ebx
  802250:	d3 e6                	shl    %cl,%esi
  802252:	f7 e5                	mul    %ebp
  802254:	89 c7                	mov    %eax,%edi
  802256:	89 d1                	mov    %edx,%ecx
  802258:	39 d3                	cmp    %edx,%ebx
  80225a:	72 06                	jb     802262 <__umoddi3+0xe2>
  80225c:	75 0e                	jne    80226c <__umoddi3+0xec>
  80225e:	39 c6                	cmp    %eax,%esi
  802260:	73 0a                	jae    80226c <__umoddi3+0xec>
  802262:	29 e8                	sub    %ebp,%eax
  802264:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802268:	89 d1                	mov    %edx,%ecx
  80226a:	89 c7                	mov    %eax,%edi
  80226c:	89 f5                	mov    %esi,%ebp
  80226e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802272:	29 fd                	sub    %edi,%ebp
  802274:	19 cb                	sbb    %ecx,%ebx
  802276:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80227b:	89 d8                	mov    %ebx,%eax
  80227d:	d3 e0                	shl    %cl,%eax
  80227f:	89 f1                	mov    %esi,%ecx
  802281:	d3 ed                	shr    %cl,%ebp
  802283:	d3 eb                	shr    %cl,%ebx
  802285:	09 e8                	or     %ebp,%eax
  802287:	89 da                	mov    %ebx,%edx
  802289:	83 c4 1c             	add    $0x1c,%esp
  80228c:	5b                   	pop    %ebx
  80228d:	5e                   	pop    %esi
  80228e:	5f                   	pop    %edi
  80228f:	5d                   	pop    %ebp
  802290:	c3                   	ret    
