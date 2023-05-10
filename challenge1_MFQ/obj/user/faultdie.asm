
obj/user/faultdie.debug：     文件格式 elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	push   (%edx)
  800045:	68 20 23 80 00       	push   $0x802320
  80004a:	e8 29 01 00 00       	call   800178 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 bc 0a 00 00       	call   800b10 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 73 0a 00 00       	call   800acf <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 2f 0d 00 00       	call   800da0 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 80 0a 00 00       	call   800b10 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80009b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a0:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a5:	85 db                	test   %ebx,%ebx
  8000a7:	7e 07                	jle    8000b0 <libmain+0x30>
		binaryname = argv[0];
  8000a9:	8b 06                	mov    (%esi),%eax
  8000ab:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b0:	83 ec 08             	sub    $0x8,%esp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	e8 a7 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000ba:	e8 0a 00 00 00       	call   8000c9 <exit>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cf:	e8 39 0f 00 00       	call   80100d <close_all>
	sys_env_destroy(0);
  8000d4:	83 ec 0c             	sub    $0xc,%esp
  8000d7:	6a 00                	push   $0x0
  8000d9:	e8 f1 09 00 00       	call   800acf <sys_env_destroy>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 04             	sub    $0x4,%esp
  8000ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ed:	8b 13                	mov    (%ebx),%edx
  8000ef:	8d 42 01             	lea    0x1(%edx),%eax
  8000f2:	89 03                	mov    %eax,(%ebx)
  8000f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000fb:	3d ff 00 00 00       	cmp    $0xff,%eax
  800100:	74 09                	je     80010b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800102:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800106:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800109:	c9                   	leave  
  80010a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	68 ff 00 00 00       	push   $0xff
  800113:	8d 43 08             	lea    0x8(%ebx),%eax
  800116:	50                   	push   %eax
  800117:	e8 76 09 00 00       	call   800a92 <sys_cputs>
		b->idx = 0;
  80011c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb db                	jmp    800102 <putch+0x1f>

00800127 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800130:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800137:	00 00 00 
	b.cnt = 0;
  80013a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800141:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800144:	ff 75 0c             	push   0xc(%ebp)
  800147:	ff 75 08             	push   0x8(%ebp)
  80014a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800150:	50                   	push   %eax
  800151:	68 e3 00 80 00       	push   $0x8000e3
  800156:	e8 14 01 00 00       	call   80026f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015b:	83 c4 08             	add    $0x8,%esp
  80015e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800164:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016a:	50                   	push   %eax
  80016b:	e8 22 09 00 00       	call   800a92 <sys_cputs>

	return b.cnt;
}
  800170:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800181:	50                   	push   %eax
  800182:	ff 75 08             	push   0x8(%ebp)
  800185:	e8 9d ff ff ff       	call   800127 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 1c             	sub    $0x1c,%esp
  800195:	89 c7                	mov    %eax,%edi
  800197:	89 d6                	mov    %edx,%esi
  800199:	8b 45 08             	mov    0x8(%ebp),%eax
  80019c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019f:	89 d1                	mov    %edx,%ecx
  8001a1:	89 c2                	mov    %eax,%edx
  8001a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ac:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001b2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b9:	39 c2                	cmp    %eax,%edx
  8001bb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001be:	72 3e                	jb     8001fe <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	ff 75 18             	push   0x18(%ebp)
  8001c6:	83 eb 01             	sub    $0x1,%ebx
  8001c9:	53                   	push   %ebx
  8001ca:	50                   	push   %eax
  8001cb:	83 ec 08             	sub    $0x8,%esp
  8001ce:	ff 75 e4             	push   -0x1c(%ebp)
  8001d1:	ff 75 e0             	push   -0x20(%ebp)
  8001d4:	ff 75 dc             	push   -0x24(%ebp)
  8001d7:	ff 75 d8             	push   -0x28(%ebp)
  8001da:	e8 f1 1e 00 00       	call   8020d0 <__udivdi3>
  8001df:	83 c4 18             	add    $0x18,%esp
  8001e2:	52                   	push   %edx
  8001e3:	50                   	push   %eax
  8001e4:	89 f2                	mov    %esi,%edx
  8001e6:	89 f8                	mov    %edi,%eax
  8001e8:	e8 9f ff ff ff       	call   80018c <printnum>
  8001ed:	83 c4 20             	add    $0x20,%esp
  8001f0:	eb 13                	jmp    800205 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	56                   	push   %esi
  8001f6:	ff 75 18             	push   0x18(%ebp)
  8001f9:	ff d7                	call   *%edi
  8001fb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001fe:	83 eb 01             	sub    $0x1,%ebx
  800201:	85 db                	test   %ebx,%ebx
  800203:	7f ed                	jg     8001f2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	56                   	push   %esi
  800209:	83 ec 04             	sub    $0x4,%esp
  80020c:	ff 75 e4             	push   -0x1c(%ebp)
  80020f:	ff 75 e0             	push   -0x20(%ebp)
  800212:	ff 75 dc             	push   -0x24(%ebp)
  800215:	ff 75 d8             	push   -0x28(%ebp)
  800218:	e8 d3 1f 00 00       	call   8021f0 <__umoddi3>
  80021d:	83 c4 14             	add    $0x14,%esp
  800220:	0f be 80 46 23 80 00 	movsbl 0x802346(%eax),%eax
  800227:	50                   	push   %eax
  800228:	ff d7                	call   *%edi
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800230:	5b                   	pop    %ebx
  800231:	5e                   	pop    %esi
  800232:	5f                   	pop    %edi
  800233:	5d                   	pop    %ebp
  800234:	c3                   	ret    

00800235 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80023f:	8b 10                	mov    (%eax),%edx
  800241:	3b 50 04             	cmp    0x4(%eax),%edx
  800244:	73 0a                	jae    800250 <sprintputch+0x1b>
		*b->buf++ = ch;
  800246:	8d 4a 01             	lea    0x1(%edx),%ecx
  800249:	89 08                	mov    %ecx,(%eax)
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	88 02                	mov    %al,(%edx)
}
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <printfmt>:
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800258:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025b:	50                   	push   %eax
  80025c:	ff 75 10             	push   0x10(%ebp)
  80025f:	ff 75 0c             	push   0xc(%ebp)
  800262:	ff 75 08             	push   0x8(%ebp)
  800265:	e8 05 00 00 00       	call   80026f <vprintfmt>
}
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <vprintfmt>:
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 3c             	sub    $0x3c,%esp
  800278:	8b 75 08             	mov    0x8(%ebp),%esi
  80027b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800281:	eb 0a                	jmp    80028d <vprintfmt+0x1e>
			putch(ch, putdat);
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	53                   	push   %ebx
  800287:	50                   	push   %eax
  800288:	ff d6                	call   *%esi
  80028a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80028d:	83 c7 01             	add    $0x1,%edi
  800290:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800294:	83 f8 25             	cmp    $0x25,%eax
  800297:	74 0c                	je     8002a5 <vprintfmt+0x36>
			if (ch == '\0')
  800299:	85 c0                	test   %eax,%eax
  80029b:	75 e6                	jne    800283 <vprintfmt+0x14>
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    
		padc = ' ';
  8002a5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002be:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c3:	8d 47 01             	lea    0x1(%edi),%eax
  8002c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c9:	0f b6 17             	movzbl (%edi),%edx
  8002cc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002cf:	3c 55                	cmp    $0x55,%al
  8002d1:	0f 87 bb 03 00 00    	ja     800692 <vprintfmt+0x423>
  8002d7:	0f b6 c0             	movzbl %al,%eax
  8002da:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  8002e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e4:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002e8:	eb d9                	jmp    8002c3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002ed:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002f1:	eb d0                	jmp    8002c3 <vprintfmt+0x54>
  8002f3:	0f b6 d2             	movzbl %dl,%edx
  8002f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800301:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800304:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800308:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80030b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030e:	83 f9 09             	cmp    $0x9,%ecx
  800311:	77 55                	ja     800368 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800313:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800316:	eb e9                	jmp    800301 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800318:	8b 45 14             	mov    0x14(%ebp),%eax
  80031b:	8b 00                	mov    (%eax),%eax
  80031d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800320:	8b 45 14             	mov    0x14(%ebp),%eax
  800323:	8d 40 04             	lea    0x4(%eax),%eax
  800326:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80032c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800330:	79 91                	jns    8002c3 <vprintfmt+0x54>
				width = precision, precision = -1;
  800332:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800335:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800338:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80033f:	eb 82                	jmp    8002c3 <vprintfmt+0x54>
  800341:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800344:	85 d2                	test   %edx,%edx
  800346:	b8 00 00 00 00       	mov    $0x0,%eax
  80034b:	0f 49 c2             	cmovns %edx,%eax
  80034e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800354:	e9 6a ff ff ff       	jmp    8002c3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80035c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800363:	e9 5b ff ff ff       	jmp    8002c3 <vprintfmt+0x54>
  800368:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80036b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036e:	eb bc                	jmp    80032c <vprintfmt+0xbd>
			lflag++;
  800370:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800376:	e9 48 ff ff ff       	jmp    8002c3 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80037b:	8b 45 14             	mov    0x14(%ebp),%eax
  80037e:	8d 78 04             	lea    0x4(%eax),%edi
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	53                   	push   %ebx
  800385:	ff 30                	push   (%eax)
  800387:	ff d6                	call   *%esi
			break;
  800389:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80038c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80038f:	e9 9d 02 00 00       	jmp    800631 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 78 04             	lea    0x4(%eax),%edi
  80039a:	8b 10                	mov    (%eax),%edx
  80039c:	89 d0                	mov    %edx,%eax
  80039e:	f7 d8                	neg    %eax
  8003a0:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a3:	83 f8 0f             	cmp    $0xf,%eax
  8003a6:	7f 23                	jg     8003cb <vprintfmt+0x15c>
  8003a8:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  8003af:	85 d2                	test   %edx,%edx
  8003b1:	74 18                	je     8003cb <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003b3:	52                   	push   %edx
  8003b4:	68 99 27 80 00       	push   $0x802799
  8003b9:	53                   	push   %ebx
  8003ba:	56                   	push   %esi
  8003bb:	e8 92 fe ff ff       	call   800252 <printfmt>
  8003c0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c6:	e9 66 02 00 00       	jmp    800631 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003cb:	50                   	push   %eax
  8003cc:	68 5e 23 80 00       	push   $0x80235e
  8003d1:	53                   	push   %ebx
  8003d2:	56                   	push   %esi
  8003d3:	e8 7a fe ff ff       	call   800252 <printfmt>
  8003d8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003db:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003de:	e9 4e 02 00 00       	jmp    800631 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e6:	83 c0 04             	add    $0x4,%eax
  8003e9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003f1:	85 d2                	test   %edx,%edx
  8003f3:	b8 57 23 80 00       	mov    $0x802357,%eax
  8003f8:	0f 45 c2             	cmovne %edx,%eax
  8003fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800402:	7e 06                	jle    80040a <vprintfmt+0x19b>
  800404:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800408:	75 0d                	jne    800417 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80040a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80040d:	89 c7                	mov    %eax,%edi
  80040f:	03 45 e0             	add    -0x20(%ebp),%eax
  800412:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800415:	eb 55                	jmp    80046c <vprintfmt+0x1fd>
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	ff 75 d8             	push   -0x28(%ebp)
  80041d:	ff 75 cc             	push   -0x34(%ebp)
  800420:	e8 0a 03 00 00       	call   80072f <strnlen>
  800425:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800428:	29 c1                	sub    %eax,%ecx
  80042a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80042d:	83 c4 10             	add    $0x10,%esp
  800430:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800432:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800439:	eb 0f                	jmp    80044a <vprintfmt+0x1db>
					putch(padc, putdat);
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	53                   	push   %ebx
  80043f:	ff 75 e0             	push   -0x20(%ebp)
  800442:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800444:	83 ef 01             	sub    $0x1,%edi
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	85 ff                	test   %edi,%edi
  80044c:	7f ed                	jg     80043b <vprintfmt+0x1cc>
  80044e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	0f 49 c2             	cmovns %edx,%eax
  80045b:	29 c2                	sub    %eax,%edx
  80045d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800460:	eb a8                	jmp    80040a <vprintfmt+0x19b>
					putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	52                   	push   %edx
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800471:	83 c7 01             	add    $0x1,%edi
  800474:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800478:	0f be d0             	movsbl %al,%edx
  80047b:	85 d2                	test   %edx,%edx
  80047d:	74 4b                	je     8004ca <vprintfmt+0x25b>
  80047f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800483:	78 06                	js     80048b <vprintfmt+0x21c>
  800485:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800489:	78 1e                	js     8004a9 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80048b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80048f:	74 d1                	je     800462 <vprintfmt+0x1f3>
  800491:	0f be c0             	movsbl %al,%eax
  800494:	83 e8 20             	sub    $0x20,%eax
  800497:	83 f8 5e             	cmp    $0x5e,%eax
  80049a:	76 c6                	jbe    800462 <vprintfmt+0x1f3>
					putch('?', putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	53                   	push   %ebx
  8004a0:	6a 3f                	push   $0x3f
  8004a2:	ff d6                	call   *%esi
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	eb c3                	jmp    80046c <vprintfmt+0x1fd>
  8004a9:	89 cf                	mov    %ecx,%edi
  8004ab:	eb 0e                	jmp    8004bb <vprintfmt+0x24c>
				putch(' ', putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	53                   	push   %ebx
  8004b1:	6a 20                	push   $0x20
  8004b3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004b5:	83 ef 01             	sub    $0x1,%edi
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	85 ff                	test   %edi,%edi
  8004bd:	7f ee                	jg     8004ad <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004bf:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c5:	e9 67 01 00 00       	jmp    800631 <vprintfmt+0x3c2>
  8004ca:	89 cf                	mov    %ecx,%edi
  8004cc:	eb ed                	jmp    8004bb <vprintfmt+0x24c>
	if (lflag >= 2)
  8004ce:	83 f9 01             	cmp    $0x1,%ecx
  8004d1:	7f 1b                	jg     8004ee <vprintfmt+0x27f>
	else if (lflag)
  8004d3:	85 c9                	test   %ecx,%ecx
  8004d5:	74 63                	je     80053a <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004df:	99                   	cltd   
  8004e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 40 04             	lea    0x4(%eax),%eax
  8004e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ec:	eb 17                	jmp    800505 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8b 50 04             	mov    0x4(%eax),%edx
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8d 40 08             	lea    0x8(%eax),%eax
  800502:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800505:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800508:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80050b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800510:	85 c9                	test   %ecx,%ecx
  800512:	0f 89 ff 00 00 00    	jns    800617 <vprintfmt+0x3a8>
				putch('-', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	53                   	push   %ebx
  80051c:	6a 2d                	push   $0x2d
  80051e:	ff d6                	call   *%esi
				num = -(long long) num;
  800520:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800523:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800526:	f7 da                	neg    %edx
  800528:	83 d1 00             	adc    $0x0,%ecx
  80052b:	f7 d9                	neg    %ecx
  80052d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800530:	bf 0a 00 00 00       	mov    $0xa,%edi
  800535:	e9 dd 00 00 00       	jmp    800617 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8b 00                	mov    (%eax),%eax
  80053f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800542:	99                   	cltd   
  800543:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 40 04             	lea    0x4(%eax),%eax
  80054c:	89 45 14             	mov    %eax,0x14(%ebp)
  80054f:	eb b4                	jmp    800505 <vprintfmt+0x296>
	if (lflag >= 2)
  800551:	83 f9 01             	cmp    $0x1,%ecx
  800554:	7f 1e                	jg     800574 <vprintfmt+0x305>
	else if (lflag)
  800556:	85 c9                	test   %ecx,%ecx
  800558:	74 32                	je     80058c <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8b 10                	mov    (%eax),%edx
  80055f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800564:	8d 40 04             	lea    0x4(%eax),%eax
  800567:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80056f:	e9 a3 00 00 00       	jmp    800617 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 10                	mov    (%eax),%edx
  800579:	8b 48 04             	mov    0x4(%eax),%ecx
  80057c:	8d 40 08             	lea    0x8(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800582:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800587:	e9 8b 00 00 00       	jmp    800617 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 10                	mov    (%eax),%edx
  800591:	b9 00 00 00 00       	mov    $0x0,%ecx
  800596:	8d 40 04             	lea    0x4(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005a1:	eb 74                	jmp    800617 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005a3:	83 f9 01             	cmp    $0x1,%ecx
  8005a6:	7f 1b                	jg     8005c3 <vprintfmt+0x354>
	else if (lflag)
  8005a8:	85 c9                	test   %ecx,%ecx
  8005aa:	74 2c                	je     8005d8 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 10                	mov    (%eax),%edx
  8005b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005bc:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005c1:	eb 54                	jmp    800617 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005cb:	8d 40 08             	lea    0x8(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005d1:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005d6:	eb 3f                	jmp    800617 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8b 10                	mov    (%eax),%edx
  8005dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e2:	8d 40 04             	lea    0x4(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005e8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005ed:	eb 28                	jmp    800617 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	6a 30                	push   $0x30
  8005f5:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f7:	83 c4 08             	add    $0x8,%esp
  8005fa:	53                   	push   %ebx
  8005fb:	6a 78                	push   $0x78
  8005fd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800609:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80060c:	8d 40 04             	lea    0x4(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800612:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800617:	83 ec 0c             	sub    $0xc,%esp
  80061a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80061e:	50                   	push   %eax
  80061f:	ff 75 e0             	push   -0x20(%ebp)
  800622:	57                   	push   %edi
  800623:	51                   	push   %ecx
  800624:	52                   	push   %edx
  800625:	89 da                	mov    %ebx,%edx
  800627:	89 f0                	mov    %esi,%eax
  800629:	e8 5e fb ff ff       	call   80018c <printnum>
			break;
  80062e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800634:	e9 54 fc ff ff       	jmp    80028d <vprintfmt+0x1e>
	if (lflag >= 2)
  800639:	83 f9 01             	cmp    $0x1,%ecx
  80063c:	7f 1b                	jg     800659 <vprintfmt+0x3ea>
	else if (lflag)
  80063e:	85 c9                	test   %ecx,%ecx
  800640:	74 2c                	je     80066e <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064c:	8d 40 04             	lea    0x4(%eax),%eax
  80064f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800652:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800657:	eb be                	jmp    800617 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	8b 48 04             	mov    0x4(%eax),%ecx
  800661:	8d 40 08             	lea    0x8(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800667:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80066c:	eb a9                	jmp    800617 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8b 10                	mov    (%eax),%edx
  800673:	b9 00 00 00 00       	mov    $0x0,%ecx
  800678:	8d 40 04             	lea    0x4(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800683:	eb 92                	jmp    800617 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 25                	push   $0x25
  80068b:	ff d6                	call   *%esi
			break;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	eb 9f                	jmp    800631 <vprintfmt+0x3c2>
			putch('%', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 25                	push   $0x25
  800698:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	89 f8                	mov    %edi,%eax
  80069f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a3:	74 05                	je     8006aa <vprintfmt+0x43b>
  8006a5:	83 e8 01             	sub    $0x1,%eax
  8006a8:	eb f5                	jmp    80069f <vprintfmt+0x430>
  8006aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ad:	eb 82                	jmp    800631 <vprintfmt+0x3c2>

008006af <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	83 ec 18             	sub    $0x18,%esp
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006be:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	74 26                	je     8006f6 <vsnprintf+0x47>
  8006d0:	85 d2                	test   %edx,%edx
  8006d2:	7e 22                	jle    8006f6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d4:	ff 75 14             	push   0x14(%ebp)
  8006d7:	ff 75 10             	push   0x10(%ebp)
  8006da:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006dd:	50                   	push   %eax
  8006de:	68 35 02 80 00       	push   $0x800235
  8006e3:	e8 87 fb ff ff       	call   80026f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f1:	83 c4 10             	add    $0x10,%esp
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    
		return -E_INVAL;
  8006f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fb:	eb f7                	jmp    8006f4 <vsnprintf+0x45>

008006fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800706:	50                   	push   %eax
  800707:	ff 75 10             	push   0x10(%ebp)
  80070a:	ff 75 0c             	push   0xc(%ebp)
  80070d:	ff 75 08             	push   0x8(%ebp)
  800710:	e8 9a ff ff ff       	call   8006af <vsnprintf>
	va_end(ap);

	return rc;
}
  800715:	c9                   	leave  
  800716:	c3                   	ret    

00800717 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071d:	b8 00 00 00 00       	mov    $0x0,%eax
  800722:	eb 03                	jmp    800727 <strlen+0x10>
		n++;
  800724:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800727:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072b:	75 f7                	jne    800724 <strlen+0xd>
	return n;
}
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800735:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800738:	b8 00 00 00 00       	mov    $0x0,%eax
  80073d:	eb 03                	jmp    800742 <strnlen+0x13>
		n++;
  80073f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800742:	39 d0                	cmp    %edx,%eax
  800744:	74 08                	je     80074e <strnlen+0x1f>
  800746:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80074a:	75 f3                	jne    80073f <strnlen+0x10>
  80074c:	89 c2                	mov    %eax,%edx
	return n;
}
  80074e:	89 d0                	mov    %edx,%eax
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	53                   	push   %ebx
  800756:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800759:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075c:	b8 00 00 00 00       	mov    $0x0,%eax
  800761:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800765:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800768:	83 c0 01             	add    $0x1,%eax
  80076b:	84 d2                	test   %dl,%dl
  80076d:	75 f2                	jne    800761 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80076f:	89 c8                	mov    %ecx,%eax
  800771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	53                   	push   %ebx
  80077a:	83 ec 10             	sub    $0x10,%esp
  80077d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800780:	53                   	push   %ebx
  800781:	e8 91 ff ff ff       	call   800717 <strlen>
  800786:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800789:	ff 75 0c             	push   0xc(%ebp)
  80078c:	01 d8                	add    %ebx,%eax
  80078e:	50                   	push   %eax
  80078f:	e8 be ff ff ff       	call   800752 <strcpy>
	return dst;
}
  800794:	89 d8                	mov    %ebx,%eax
  800796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a6:	89 f3                	mov    %esi,%ebx
  8007a8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ab:	89 f0                	mov    %esi,%eax
  8007ad:	eb 0f                	jmp    8007be <strncpy+0x23>
		*dst++ = *src;
  8007af:	83 c0 01             	add    $0x1,%eax
  8007b2:	0f b6 0a             	movzbl (%edx),%ecx
  8007b5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b8:	80 f9 01             	cmp    $0x1,%cl
  8007bb:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007be:	39 d8                	cmp    %ebx,%eax
  8007c0:	75 ed                	jne    8007af <strncpy+0x14>
	}
	return ret;
}
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	56                   	push   %esi
  8007cc:	53                   	push   %ebx
  8007cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	74 21                	je     8007fd <strlcpy+0x35>
  8007dc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e0:	89 f2                	mov    %esi,%edx
  8007e2:	eb 09                	jmp    8007ed <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e4:	83 c1 01             	add    $0x1,%ecx
  8007e7:	83 c2 01             	add    $0x1,%edx
  8007ea:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007ed:	39 c2                	cmp    %eax,%edx
  8007ef:	74 09                	je     8007fa <strlcpy+0x32>
  8007f1:	0f b6 19             	movzbl (%ecx),%ebx
  8007f4:	84 db                	test   %bl,%bl
  8007f6:	75 ec                	jne    8007e4 <strlcpy+0x1c>
  8007f8:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007fa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fd:	29 f0                	sub    %esi,%eax
}
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080c:	eb 06                	jmp    800814 <strcmp+0x11>
		p++, q++;
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800814:	0f b6 01             	movzbl (%ecx),%eax
  800817:	84 c0                	test   %al,%al
  800819:	74 04                	je     80081f <strcmp+0x1c>
  80081b:	3a 02                	cmp    (%edx),%al
  80081d:	74 ef                	je     80080e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081f:	0f b6 c0             	movzbl %al,%eax
  800822:	0f b6 12             	movzbl (%edx),%edx
  800825:	29 d0                	sub    %edx,%eax
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
  800833:	89 c3                	mov    %eax,%ebx
  800835:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800838:	eb 06                	jmp    800840 <strncmp+0x17>
		n--, p++, q++;
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800840:	39 d8                	cmp    %ebx,%eax
  800842:	74 18                	je     80085c <strncmp+0x33>
  800844:	0f b6 08             	movzbl (%eax),%ecx
  800847:	84 c9                	test   %cl,%cl
  800849:	74 04                	je     80084f <strncmp+0x26>
  80084b:	3a 0a                	cmp    (%edx),%cl
  80084d:	74 eb                	je     80083a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084f:	0f b6 00             	movzbl (%eax),%eax
  800852:	0f b6 12             	movzbl (%edx),%edx
  800855:	29 d0                	sub    %edx,%eax
}
  800857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    
		return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
  800861:	eb f4                	jmp    800857 <strncmp+0x2e>

00800863 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086d:	eb 03                	jmp    800872 <strchr+0xf>
  80086f:	83 c0 01             	add    $0x1,%eax
  800872:	0f b6 10             	movzbl (%eax),%edx
  800875:	84 d2                	test   %dl,%dl
  800877:	74 06                	je     80087f <strchr+0x1c>
		if (*s == c)
  800879:	38 ca                	cmp    %cl,%dl
  80087b:	75 f2                	jne    80086f <strchr+0xc>
  80087d:	eb 05                	jmp    800884 <strchr+0x21>
			return (char *) s;
	return 0;
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800890:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800893:	38 ca                	cmp    %cl,%dl
  800895:	74 09                	je     8008a0 <strfind+0x1a>
  800897:	84 d2                	test   %dl,%dl
  800899:	74 05                	je     8008a0 <strfind+0x1a>
	for (; *s; s++)
  80089b:	83 c0 01             	add    $0x1,%eax
  80089e:	eb f0                	jmp    800890 <strfind+0xa>
			break;
	return (char *) s;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	57                   	push   %edi
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ae:	85 c9                	test   %ecx,%ecx
  8008b0:	74 2f                	je     8008e1 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b2:	89 f8                	mov    %edi,%eax
  8008b4:	09 c8                	or     %ecx,%eax
  8008b6:	a8 03                	test   $0x3,%al
  8008b8:	75 21                	jne    8008db <memset+0x39>
		c &= 0xFF;
  8008ba:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008be:	89 d0                	mov    %edx,%eax
  8008c0:	c1 e0 08             	shl    $0x8,%eax
  8008c3:	89 d3                	mov    %edx,%ebx
  8008c5:	c1 e3 18             	shl    $0x18,%ebx
  8008c8:	89 d6                	mov    %edx,%esi
  8008ca:	c1 e6 10             	shl    $0x10,%esi
  8008cd:	09 f3                	or     %esi,%ebx
  8008cf:	09 da                	or     %ebx,%edx
  8008d1:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008d6:	fc                   	cld    
  8008d7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d9:	eb 06                	jmp    8008e1 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008de:	fc                   	cld    
  8008df:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e1:	89 f8                	mov    %edi,%eax
  8008e3:	5b                   	pop    %ebx
  8008e4:	5e                   	pop    %esi
  8008e5:	5f                   	pop    %edi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f6:	39 c6                	cmp    %eax,%esi
  8008f8:	73 32                	jae    80092c <memmove+0x44>
  8008fa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fd:	39 c2                	cmp    %eax,%edx
  8008ff:	76 2b                	jbe    80092c <memmove+0x44>
		s += n;
		d += n;
  800901:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800904:	89 d6                	mov    %edx,%esi
  800906:	09 fe                	or     %edi,%esi
  800908:	09 ce                	or     %ecx,%esi
  80090a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800910:	75 0e                	jne    800920 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800912:	83 ef 04             	sub    $0x4,%edi
  800915:	8d 72 fc             	lea    -0x4(%edx),%esi
  800918:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80091b:	fd                   	std    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 09                	jmp    800929 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800920:	83 ef 01             	sub    $0x1,%edi
  800923:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800926:	fd                   	std    
  800927:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800929:	fc                   	cld    
  80092a:	eb 1a                	jmp    800946 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092c:	89 f2                	mov    %esi,%edx
  80092e:	09 c2                	or     %eax,%edx
  800930:	09 ca                	or     %ecx,%edx
  800932:	f6 c2 03             	test   $0x3,%dl
  800935:	75 0a                	jne    800941 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800937:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80093a:	89 c7                	mov    %eax,%edi
  80093c:	fc                   	cld    
  80093d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093f:	eb 05                	jmp    800946 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800941:	89 c7                	mov    %eax,%edi
  800943:	fc                   	cld    
  800944:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800950:	ff 75 10             	push   0x10(%ebp)
  800953:	ff 75 0c             	push   0xc(%ebp)
  800956:	ff 75 08             	push   0x8(%ebp)
  800959:	e8 8a ff ff ff       	call   8008e8 <memmove>
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096b:	89 c6                	mov    %eax,%esi
  80096d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800970:	eb 06                	jmp    800978 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800978:	39 f0                	cmp    %esi,%eax
  80097a:	74 14                	je     800990 <memcmp+0x30>
		if (*s1 != *s2)
  80097c:	0f b6 08             	movzbl (%eax),%ecx
  80097f:	0f b6 1a             	movzbl (%edx),%ebx
  800982:	38 d9                	cmp    %bl,%cl
  800984:	74 ec                	je     800972 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800986:	0f b6 c1             	movzbl %cl,%eax
  800989:	0f b6 db             	movzbl %bl,%ebx
  80098c:	29 d8                	sub    %ebx,%eax
  80098e:	eb 05                	jmp    800995 <memcmp+0x35>
	}

	return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009a2:	89 c2                	mov    %eax,%edx
  8009a4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a7:	eb 03                	jmp    8009ac <memfind+0x13>
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	39 d0                	cmp    %edx,%eax
  8009ae:	73 04                	jae    8009b4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b0:	38 08                	cmp    %cl,(%eax)
  8009b2:	75 f5                	jne    8009a9 <memfind+0x10>
			break;
	return (void *) s;
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	57                   	push   %edi
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c2:	eb 03                	jmp    8009c7 <strtol+0x11>
		s++;
  8009c4:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009c7:	0f b6 02             	movzbl (%edx),%eax
  8009ca:	3c 20                	cmp    $0x20,%al
  8009cc:	74 f6                	je     8009c4 <strtol+0xe>
  8009ce:	3c 09                	cmp    $0x9,%al
  8009d0:	74 f2                	je     8009c4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009d2:	3c 2b                	cmp    $0x2b,%al
  8009d4:	74 2a                	je     800a00 <strtol+0x4a>
	int neg = 0;
  8009d6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009db:	3c 2d                	cmp    $0x2d,%al
  8009dd:	74 2b                	je     800a0a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009df:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e5:	75 0f                	jne    8009f6 <strtol+0x40>
  8009e7:	80 3a 30             	cmpb   $0x30,(%edx)
  8009ea:	74 28                	je     800a14 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ec:	85 db                	test   %ebx,%ebx
  8009ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009f3:	0f 44 d8             	cmove  %eax,%ebx
  8009f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009fb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009fe:	eb 46                	jmp    800a46 <strtol+0x90>
		s++;
  800a00:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a03:	bf 00 00 00 00       	mov    $0x0,%edi
  800a08:	eb d5                	jmp    8009df <strtol+0x29>
		s++, neg = 1;
  800a0a:	83 c2 01             	add    $0x1,%edx
  800a0d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a12:	eb cb                	jmp    8009df <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a14:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a18:	74 0e                	je     800a28 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a1a:	85 db                	test   %ebx,%ebx
  800a1c:	75 d8                	jne    8009f6 <strtol+0x40>
		s++, base = 8;
  800a1e:	83 c2 01             	add    $0x1,%edx
  800a21:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a26:	eb ce                	jmp    8009f6 <strtol+0x40>
		s += 2, base = 16;
  800a28:	83 c2 02             	add    $0x2,%edx
  800a2b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a30:	eb c4                	jmp    8009f6 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a32:	0f be c0             	movsbl %al,%eax
  800a35:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a38:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a3b:	7d 3a                	jge    800a77 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a3d:	83 c2 01             	add    $0x1,%edx
  800a40:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a44:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a46:	0f b6 02             	movzbl (%edx),%eax
  800a49:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a4c:	89 f3                	mov    %esi,%ebx
  800a4e:	80 fb 09             	cmp    $0x9,%bl
  800a51:	76 df                	jbe    800a32 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a53:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a56:	89 f3                	mov    %esi,%ebx
  800a58:	80 fb 19             	cmp    $0x19,%bl
  800a5b:	77 08                	ja     800a65 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a5d:	0f be c0             	movsbl %al,%eax
  800a60:	83 e8 57             	sub    $0x57,%eax
  800a63:	eb d3                	jmp    800a38 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a65:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a68:	89 f3                	mov    %esi,%ebx
  800a6a:	80 fb 19             	cmp    $0x19,%bl
  800a6d:	77 08                	ja     800a77 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a6f:	0f be c0             	movsbl %al,%eax
  800a72:	83 e8 37             	sub    $0x37,%eax
  800a75:	eb c1                	jmp    800a38 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7b:	74 05                	je     800a82 <strtol+0xcc>
		*endptr = (char *) s;
  800a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a80:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a82:	89 c8                	mov    %ecx,%eax
  800a84:	f7 d8                	neg    %eax
  800a86:	85 ff                	test   %edi,%edi
  800a88:	0f 45 c8             	cmovne %eax,%ecx
}
  800a8b:	89 c8                	mov    %ecx,%eax
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa3:	89 c3                	mov    %eax,%ebx
  800aa5:	89 c7                	mov    %eax,%edi
  800aa7:	89 c6                	mov    %eax,%esi
  800aa9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ab6:	ba 00 00 00 00       	mov    $0x0,%edx
  800abb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac0:	89 d1                	mov    %edx,%ecx
  800ac2:	89 d3                	mov    %edx,%ebx
  800ac4:	89 d7                	mov    %edx,%edi
  800ac6:	89 d6                	mov    %edx,%esi
  800ac8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ad8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae5:	89 cb                	mov    %ecx,%ebx
  800ae7:	89 cf                	mov    %ecx,%edi
  800ae9:	89 ce                	mov    %ecx,%esi
  800aeb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800aed:	85 c0                	test   %eax,%eax
  800aef:	7f 08                	jg     800af9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800af9:	83 ec 0c             	sub    $0xc,%esp
  800afc:	50                   	push   %eax
  800afd:	6a 03                	push   $0x3
  800aff:	68 3f 26 80 00       	push   $0x80263f
  800b04:	6a 2a                	push   $0x2a
  800b06:	68 5c 26 80 00       	push   $0x80265c
  800b0b:	e8 3a 14 00 00       	call   801f4a <_panic>

00800b10 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_yield>:

void
sys_yield(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 d3                	mov    %edx,%ebx
  800b43:	89 d7                	mov    %edx,%edi
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b57:	be 00 00 00 00       	mov    $0x0,%esi
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b62:	b8 04 00 00 00       	mov    $0x4,%eax
  800b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6a:	89 f7                	mov    %esi,%edi
  800b6c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	7f 08                	jg     800b7a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	50                   	push   %eax
  800b7e:	6a 04                	push   $0x4
  800b80:	68 3f 26 80 00       	push   $0x80263f
  800b85:	6a 2a                	push   $0x2a
  800b87:	68 5c 26 80 00       	push   $0x80265c
  800b8c:	e8 b9 13 00 00       	call   801f4a <_panic>

00800b91 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bab:	8b 75 18             	mov    0x18(%ebp),%esi
  800bae:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	7f 08                	jg     800bbc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	50                   	push   %eax
  800bc0:	6a 05                	push   $0x5
  800bc2:	68 3f 26 80 00       	push   $0x80263f
  800bc7:	6a 2a                	push   $0x2a
  800bc9:	68 5c 26 80 00       	push   $0x80265c
  800bce:	e8 77 13 00 00       	call   801f4a <_panic>

00800bd3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be1:	8b 55 08             	mov    0x8(%ebp),%edx
  800be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bec:	89 df                	mov    %ebx,%edi
  800bee:	89 de                	mov    %ebx,%esi
  800bf0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf2:	85 c0                	test   %eax,%eax
  800bf4:	7f 08                	jg     800bfe <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	50                   	push   %eax
  800c02:	6a 06                	push   $0x6
  800c04:	68 3f 26 80 00       	push   $0x80263f
  800c09:	6a 2a                	push   $0x2a
  800c0b:	68 5c 26 80 00       	push   $0x80265c
  800c10:	e8 35 13 00 00       	call   801f4a <_panic>

00800c15 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2e:	89 df                	mov    %ebx,%edi
  800c30:	89 de                	mov    %ebx,%esi
  800c32:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7f 08                	jg     800c40 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 08                	push   $0x8
  800c46:	68 3f 26 80 00       	push   $0x80263f
  800c4b:	6a 2a                	push   $0x2a
  800c4d:	68 5c 26 80 00       	push   $0x80265c
  800c52:	e8 f3 12 00 00       	call   801f4a <_panic>

00800c57 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7f 08                	jg     800c82 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 09                	push   $0x9
  800c88:	68 3f 26 80 00       	push   $0x80263f
  800c8d:	6a 2a                	push   $0x2a
  800c8f:	68 5c 26 80 00       	push   $0x80265c
  800c94:	e8 b1 12 00 00       	call   801f4a <_panic>

00800c99 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7f 08                	jg     800cc4 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	83 ec 0c             	sub    $0xc,%esp
  800cc7:	50                   	push   %eax
  800cc8:	6a 0a                	push   $0xa
  800cca:	68 3f 26 80 00       	push   $0x80263f
  800ccf:	6a 2a                	push   $0x2a
  800cd1:	68 5c 26 80 00       	push   $0x80265c
  800cd6:	e8 6f 12 00 00       	call   801f4a <_panic>

00800cdb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cec:	be 00 00 00 00       	mov    $0x0,%esi
  800cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d14:	89 cb                	mov    %ecx,%ebx
  800d16:	89 cf                	mov    %ecx,%edi
  800d18:	89 ce                	mov    %ecx,%esi
  800d1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7f 08                	jg     800d28 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 0d                	push   $0xd
  800d2e:	68 3f 26 80 00       	push   $0x80263f
  800d33:	6a 2a                	push   $0x2a
  800d35:	68 5c 26 80 00       	push   $0x80265c
  800d3a:	e8 0b 12 00 00       	call   801f4a <_panic>

00800d3f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d45:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d4f:	89 d1                	mov    %edx,%ecx
  800d51:	89 d3                	mov    %edx,%ebx
  800d53:	89 d7                	mov    %edx,%edi
  800d55:	89 d6                	mov    %edx,%esi
  800d57:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
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
  800d90:	b8 10 00 00 00       	mov    $0x10,%eax
  800d95:	89 df                	mov    %ebx,%edi
  800d97:	89 de                	mov    %ebx,%esi
  800d99:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800da6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dad:	74 0a                	je     800db9 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	a3 04 40 80 00       	mov    %eax,0x804004
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800db9:	e8 52 fd ff ff       	call   800b10 <sys_getenvid>
  800dbe:	83 ec 04             	sub    $0x4,%esp
  800dc1:	68 07 0e 00 00       	push   $0xe07
  800dc6:	68 00 f0 bf ee       	push   $0xeebff000
  800dcb:	50                   	push   %eax
  800dcc:	e8 7d fd ff ff       	call   800b4e <sys_page_alloc>
		if (r < 0) {
  800dd1:	83 c4 10             	add    $0x10,%esp
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	78 2c                	js     800e04 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800dd8:	e8 33 fd ff ff       	call   800b10 <sys_getenvid>
  800ddd:	83 ec 08             	sub    $0x8,%esp
  800de0:	68 16 0e 80 00       	push   $0x800e16
  800de5:	50                   	push   %eax
  800de6:	e8 ae fe ff ff       	call   800c99 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800deb:	83 c4 10             	add    $0x10,%esp
  800dee:	85 c0                	test   %eax,%eax
  800df0:	79 bd                	jns    800daf <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800df2:	50                   	push   %eax
  800df3:	68 ac 26 80 00       	push   $0x8026ac
  800df8:	6a 28                	push   $0x28
  800dfa:	68 e2 26 80 00       	push   $0x8026e2
  800dff:	e8 46 11 00 00       	call   801f4a <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800e04:	50                   	push   %eax
  800e05:	68 6c 26 80 00       	push   $0x80266c
  800e0a:	6a 23                	push   $0x23
  800e0c:	68 e2 26 80 00       	push   $0x8026e2
  800e11:	e8 34 11 00 00       	call   801f4a <_panic>

00800e16 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e16:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e17:	a1 04 40 80 00       	mov    0x804004,%eax
	call *%eax
  800e1c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e1e:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800e21:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800e25:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800e28:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800e2c:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800e30:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800e32:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800e35:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800e36:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800e39:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800e3a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800e3b:	c3                   	ret    

00800e3c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e42:	05 00 00 00 30       	add    $0x30000000,%eax
  800e47:	c1 e8 0c             	shr    $0xc,%eax
}
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e5c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e6b:	89 c2                	mov    %eax,%edx
  800e6d:	c1 ea 16             	shr    $0x16,%edx
  800e70:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e77:	f6 c2 01             	test   $0x1,%dl
  800e7a:	74 29                	je     800ea5 <fd_alloc+0x42>
  800e7c:	89 c2                	mov    %eax,%edx
  800e7e:	c1 ea 0c             	shr    $0xc,%edx
  800e81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e88:	f6 c2 01             	test   $0x1,%dl
  800e8b:	74 18                	je     800ea5 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e8d:	05 00 10 00 00       	add    $0x1000,%eax
  800e92:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e97:	75 d2                	jne    800e6b <fd_alloc+0x8>
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800e9e:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800ea3:	eb 05                	jmp    800eaa <fd_alloc+0x47>
			return 0;
  800ea5:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800eaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ead:	89 02                	mov    %eax,(%edx)
}
  800eaf:	89 c8                	mov    %ecx,%eax
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eb9:	83 f8 1f             	cmp    $0x1f,%eax
  800ebc:	77 30                	ja     800eee <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ebe:	c1 e0 0c             	shl    $0xc,%eax
  800ec1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec6:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ecc:	f6 c2 01             	test   $0x1,%dl
  800ecf:	74 24                	je     800ef5 <fd_lookup+0x42>
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	c1 ea 0c             	shr    $0xc,%edx
  800ed6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edd:	f6 c2 01             	test   $0x1,%dl
  800ee0:	74 1a                	je     800efc <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee5:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    
		return -E_INVAL;
  800eee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef3:	eb f7                	jmp    800eec <fd_lookup+0x39>
		return -E_INVAL;
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efa:	eb f0                	jmp    800eec <fd_lookup+0x39>
  800efc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f01:	eb e9                	jmp    800eec <fd_lookup+0x39>

00800f03 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	53                   	push   %ebx
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f12:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f17:	39 13                	cmp    %edx,(%ebx)
  800f19:	74 37                	je     800f52 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f1b:	83 c0 01             	add    $0x1,%eax
  800f1e:	8b 1c 85 6c 27 80 00 	mov    0x80276c(,%eax,4),%ebx
  800f25:	85 db                	test   %ebx,%ebx
  800f27:	75 ee                	jne    800f17 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f29:	a1 00 40 80 00       	mov    0x804000,%eax
  800f2e:	8b 40 58             	mov    0x58(%eax),%eax
  800f31:	83 ec 04             	sub    $0x4,%esp
  800f34:	52                   	push   %edx
  800f35:	50                   	push   %eax
  800f36:	68 f0 26 80 00       	push   $0x8026f0
  800f3b:	e8 38 f2 ff ff       	call   800178 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4b:	89 1a                	mov    %ebx,(%edx)
}
  800f4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    
			return 0;
  800f52:	b8 00 00 00 00       	mov    $0x0,%eax
  800f57:	eb ef                	jmp    800f48 <dev_lookup+0x45>

00800f59 <fd_close>:
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	83 ec 24             	sub    $0x24,%esp
  800f62:	8b 75 08             	mov    0x8(%ebp),%esi
  800f65:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f68:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f6b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f6c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f72:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f75:	50                   	push   %eax
  800f76:	e8 38 ff ff ff       	call   800eb3 <fd_lookup>
  800f7b:	89 c3                	mov    %eax,%ebx
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 05                	js     800f89 <fd_close+0x30>
	    || fd != fd2)
  800f84:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f87:	74 16                	je     800f9f <fd_close+0x46>
		return (must_exist ? r : 0);
  800f89:	89 f8                	mov    %edi,%eax
  800f8b:	84 c0                	test   %al,%al
  800f8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f92:	0f 44 d8             	cmove  %eax,%ebx
}
  800f95:	89 d8                	mov    %ebx,%eax
  800f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9a:	5b                   	pop    %ebx
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fa5:	50                   	push   %eax
  800fa6:	ff 36                	push   (%esi)
  800fa8:	e8 56 ff ff ff       	call   800f03 <dev_lookup>
  800fad:	89 c3                	mov    %eax,%ebx
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 1a                	js     800fd0 <fd_close+0x77>
		if (dev->dev_close)
  800fb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fb9:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	74 0b                	je     800fd0 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	56                   	push   %esi
  800fc9:	ff d0                	call   *%eax
  800fcb:	89 c3                	mov    %eax,%ebx
  800fcd:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fd0:	83 ec 08             	sub    $0x8,%esp
  800fd3:	56                   	push   %esi
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 f8 fb ff ff       	call   800bd3 <sys_page_unmap>
	return r;
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	eb b5                	jmp    800f95 <fd_close+0x3c>

00800fe0 <close>:

int
close(int fdnum)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe9:	50                   	push   %eax
  800fea:	ff 75 08             	push   0x8(%ebp)
  800fed:	e8 c1 fe ff ff       	call   800eb3 <fd_lookup>
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	79 02                	jns    800ffb <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    
		return fd_close(fd, 1);
  800ffb:	83 ec 08             	sub    $0x8,%esp
  800ffe:	6a 01                	push   $0x1
  801000:	ff 75 f4             	push   -0xc(%ebp)
  801003:	e8 51 ff ff ff       	call   800f59 <fd_close>
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	eb ec                	jmp    800ff9 <close+0x19>

0080100d <close_all>:

void
close_all(void)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	53                   	push   %ebx
  801011:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801014:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	53                   	push   %ebx
  80101d:	e8 be ff ff ff       	call   800fe0 <close>
	for (i = 0; i < MAXFD; i++)
  801022:	83 c3 01             	add    $0x1,%ebx
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	83 fb 20             	cmp    $0x20,%ebx
  80102b:	75 ec                	jne    801019 <close_all+0xc>
}
  80102d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801030:	c9                   	leave  
  801031:	c3                   	ret    

00801032 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	57                   	push   %edi
  801036:	56                   	push   %esi
  801037:	53                   	push   %ebx
  801038:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80103b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80103e:	50                   	push   %eax
  80103f:	ff 75 08             	push   0x8(%ebp)
  801042:	e8 6c fe ff ff       	call   800eb3 <fd_lookup>
  801047:	89 c3                	mov    %eax,%ebx
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 7f                	js     8010cf <dup+0x9d>
		return r;
	close(newfdnum);
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	ff 75 0c             	push   0xc(%ebp)
  801056:	e8 85 ff ff ff       	call   800fe0 <close>

	newfd = INDEX2FD(newfdnum);
  80105b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80105e:	c1 e6 0c             	shl    $0xc,%esi
  801061:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801067:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80106a:	89 3c 24             	mov    %edi,(%esp)
  80106d:	e8 da fd ff ff       	call   800e4c <fd2data>
  801072:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801074:	89 34 24             	mov    %esi,(%esp)
  801077:	e8 d0 fd ff ff       	call   800e4c <fd2data>
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801082:	89 d8                	mov    %ebx,%eax
  801084:	c1 e8 16             	shr    $0x16,%eax
  801087:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80108e:	a8 01                	test   $0x1,%al
  801090:	74 11                	je     8010a3 <dup+0x71>
  801092:	89 d8                	mov    %ebx,%eax
  801094:	c1 e8 0c             	shr    $0xc,%eax
  801097:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80109e:	f6 c2 01             	test   $0x1,%dl
  8010a1:	75 36                	jne    8010d9 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a3:	89 f8                	mov    %edi,%eax
  8010a5:	c1 e8 0c             	shr    $0xc,%eax
  8010a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b7:	50                   	push   %eax
  8010b8:	56                   	push   %esi
  8010b9:	6a 00                	push   $0x0
  8010bb:	57                   	push   %edi
  8010bc:	6a 00                	push   $0x0
  8010be:	e8 ce fa ff ff       	call   800b91 <sys_page_map>
  8010c3:	89 c3                	mov    %eax,%ebx
  8010c5:	83 c4 20             	add    $0x20,%esp
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 33                	js     8010ff <dup+0xcd>
		goto err;

	return newfdnum;
  8010cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010cf:	89 d8                	mov    %ebx,%eax
  8010d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e8:	50                   	push   %eax
  8010e9:	ff 75 d4             	push   -0x2c(%ebp)
  8010ec:	6a 00                	push   $0x0
  8010ee:	53                   	push   %ebx
  8010ef:	6a 00                	push   $0x0
  8010f1:	e8 9b fa ff ff       	call   800b91 <sys_page_map>
  8010f6:	89 c3                	mov    %eax,%ebx
  8010f8:	83 c4 20             	add    $0x20,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	79 a4                	jns    8010a3 <dup+0x71>
	sys_page_unmap(0, newfd);
  8010ff:	83 ec 08             	sub    $0x8,%esp
  801102:	56                   	push   %esi
  801103:	6a 00                	push   $0x0
  801105:	e8 c9 fa ff ff       	call   800bd3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80110a:	83 c4 08             	add    $0x8,%esp
  80110d:	ff 75 d4             	push   -0x2c(%ebp)
  801110:	6a 00                	push   $0x0
  801112:	e8 bc fa ff ff       	call   800bd3 <sys_page_unmap>
	return r;
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	eb b3                	jmp    8010cf <dup+0x9d>

0080111c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	83 ec 18             	sub    $0x18,%esp
  801124:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801127:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	56                   	push   %esi
  80112c:	e8 82 fd ff ff       	call   800eb3 <fd_lookup>
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	85 c0                	test   %eax,%eax
  801136:	78 3c                	js     801174 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801138:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80113b:	83 ec 08             	sub    $0x8,%esp
  80113e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801141:	50                   	push   %eax
  801142:	ff 33                	push   (%ebx)
  801144:	e8 ba fd ff ff       	call   800f03 <dev_lookup>
  801149:	83 c4 10             	add    $0x10,%esp
  80114c:	85 c0                	test   %eax,%eax
  80114e:	78 24                	js     801174 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801150:	8b 43 08             	mov    0x8(%ebx),%eax
  801153:	83 e0 03             	and    $0x3,%eax
  801156:	83 f8 01             	cmp    $0x1,%eax
  801159:	74 20                	je     80117b <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80115b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115e:	8b 40 08             	mov    0x8(%eax),%eax
  801161:	85 c0                	test   %eax,%eax
  801163:	74 37                	je     80119c <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	ff 75 10             	push   0x10(%ebp)
  80116b:	ff 75 0c             	push   0xc(%ebp)
  80116e:	53                   	push   %ebx
  80116f:	ff d0                	call   *%eax
  801171:	83 c4 10             	add    $0x10,%esp
}
  801174:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801177:	5b                   	pop    %ebx
  801178:	5e                   	pop    %esi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80117b:	a1 00 40 80 00       	mov    0x804000,%eax
  801180:	8b 40 58             	mov    0x58(%eax),%eax
  801183:	83 ec 04             	sub    $0x4,%esp
  801186:	56                   	push   %esi
  801187:	50                   	push   %eax
  801188:	68 31 27 80 00       	push   $0x802731
  80118d:	e8 e6 ef ff ff       	call   800178 <cprintf>
		return -E_INVAL;
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80119a:	eb d8                	jmp    801174 <read+0x58>
		return -E_NOT_SUPP;
  80119c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011a1:	eb d1                	jmp    801174 <read+0x58>

008011a3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	57                   	push   %edi
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011af:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b7:	eb 02                	jmp    8011bb <readn+0x18>
  8011b9:	01 c3                	add    %eax,%ebx
  8011bb:	39 f3                	cmp    %esi,%ebx
  8011bd:	73 21                	jae    8011e0 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	89 f0                	mov    %esi,%eax
  8011c4:	29 d8                	sub    %ebx,%eax
  8011c6:	50                   	push   %eax
  8011c7:	89 d8                	mov    %ebx,%eax
  8011c9:	03 45 0c             	add    0xc(%ebp),%eax
  8011cc:	50                   	push   %eax
  8011cd:	57                   	push   %edi
  8011ce:	e8 49 ff ff ff       	call   80111c <read>
		if (m < 0)
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 04                	js     8011de <readn+0x3b>
			return m;
		if (m == 0)
  8011da:	75 dd                	jne    8011b9 <readn+0x16>
  8011dc:	eb 02                	jmp    8011e0 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011de:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011e0:	89 d8                	mov    %ebx,%eax
  8011e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5e                   	pop    %esi
  8011e7:	5f                   	pop    %edi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	56                   	push   %esi
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 18             	sub    $0x18,%esp
  8011f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	53                   	push   %ebx
  8011fa:	e8 b4 fc ff ff       	call   800eb3 <fd_lookup>
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	78 37                	js     80123d <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801206:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	ff 36                	push   (%esi)
  801212:	e8 ec fc ff ff       	call   800f03 <dev_lookup>
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	85 c0                	test   %eax,%eax
  80121c:	78 1f                	js     80123d <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801222:	74 20                	je     801244 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801224:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801227:	8b 40 0c             	mov    0xc(%eax),%eax
  80122a:	85 c0                	test   %eax,%eax
  80122c:	74 37                	je     801265 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80122e:	83 ec 04             	sub    $0x4,%esp
  801231:	ff 75 10             	push   0x10(%ebp)
  801234:	ff 75 0c             	push   0xc(%ebp)
  801237:	56                   	push   %esi
  801238:	ff d0                	call   *%eax
  80123a:	83 c4 10             	add    $0x10,%esp
}
  80123d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801244:	a1 00 40 80 00       	mov    0x804000,%eax
  801249:	8b 40 58             	mov    0x58(%eax),%eax
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	53                   	push   %ebx
  801250:	50                   	push   %eax
  801251:	68 4d 27 80 00       	push   $0x80274d
  801256:	e8 1d ef ff ff       	call   800178 <cprintf>
		return -E_INVAL;
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801263:	eb d8                	jmp    80123d <write+0x53>
		return -E_NOT_SUPP;
  801265:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80126a:	eb d1                	jmp    80123d <write+0x53>

0080126c <seek>:

int
seek(int fdnum, off_t offset)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801272:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801275:	50                   	push   %eax
  801276:	ff 75 08             	push   0x8(%ebp)
  801279:	e8 35 fc ff ff       	call   800eb3 <fd_lookup>
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 0e                	js     801293 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801285:	8b 55 0c             	mov    0xc(%ebp),%edx
  801288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80128e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 18             	sub    $0x18,%esp
  80129d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a3:	50                   	push   %eax
  8012a4:	53                   	push   %ebx
  8012a5:	e8 09 fc ff ff       	call   800eb3 <fd_lookup>
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 34                	js     8012e5 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ba:	50                   	push   %eax
  8012bb:	ff 36                	push   (%esi)
  8012bd:	e8 41 fc ff ff       	call   800f03 <dev_lookup>
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 1c                	js     8012e5 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c9:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012cd:	74 1d                	je     8012ec <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d2:	8b 40 18             	mov    0x18(%eax),%eax
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	74 34                	je     80130d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	ff 75 0c             	push   0xc(%ebp)
  8012df:	56                   	push   %esi
  8012e0:	ff d0                	call   *%eax
  8012e2:	83 c4 10             	add    $0x10,%esp
}
  8012e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012ec:	a1 00 40 80 00       	mov    0x804000,%eax
  8012f1:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012f4:	83 ec 04             	sub    $0x4,%esp
  8012f7:	53                   	push   %ebx
  8012f8:	50                   	push   %eax
  8012f9:	68 10 27 80 00       	push   $0x802710
  8012fe:	e8 75 ee ff ff       	call   800178 <cprintf>
		return -E_INVAL;
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130b:	eb d8                	jmp    8012e5 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80130d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801312:	eb d1                	jmp    8012e5 <ftruncate+0x50>

00801314 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	56                   	push   %esi
  801318:	53                   	push   %ebx
  801319:	83 ec 18             	sub    $0x18,%esp
  80131c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801322:	50                   	push   %eax
  801323:	ff 75 08             	push   0x8(%ebp)
  801326:	e8 88 fb ff ff       	call   800eb3 <fd_lookup>
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 49                	js     80137b <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801332:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 36                	push   (%esi)
  80133e:	e8 c0 fb ff ff       	call   800f03 <dev_lookup>
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	78 31                	js     80137b <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80134a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801351:	74 2f                	je     801382 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801353:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801356:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80135d:	00 00 00 
	stat->st_isdir = 0;
  801360:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801367:	00 00 00 
	stat->st_dev = dev;
  80136a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	53                   	push   %ebx
  801374:	56                   	push   %esi
  801375:	ff 50 14             	call   *0x14(%eax)
  801378:	83 c4 10             	add    $0x10,%esp
}
  80137b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137e:	5b                   	pop    %ebx
  80137f:	5e                   	pop    %esi
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    
		return -E_NOT_SUPP;
  801382:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801387:	eb f2                	jmp    80137b <fstat+0x67>

00801389 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	56                   	push   %esi
  80138d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	6a 00                	push   $0x0
  801393:	ff 75 08             	push   0x8(%ebp)
  801396:	e8 e4 01 00 00       	call   80157f <open>
  80139b:	89 c3                	mov    %eax,%ebx
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 1b                	js     8013bf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	ff 75 0c             	push   0xc(%ebp)
  8013aa:	50                   	push   %eax
  8013ab:	e8 64 ff ff ff       	call   801314 <fstat>
  8013b0:	89 c6                	mov    %eax,%esi
	close(fd);
  8013b2:	89 1c 24             	mov    %ebx,(%esp)
  8013b5:	e8 26 fc ff ff       	call   800fe0 <close>
	return r;
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	89 f3                	mov    %esi,%ebx
}
  8013bf:	89 d8                	mov    %ebx,%eax
  8013c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c4:	5b                   	pop    %ebx
  8013c5:	5e                   	pop    %esi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	89 c6                	mov    %eax,%esi
  8013cf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013d1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8013d8:	74 27                	je     801401 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013da:	6a 07                	push   $0x7
  8013dc:	68 00 50 80 00       	push   $0x805000
  8013e1:	56                   	push   %esi
  8013e2:	ff 35 00 60 80 00    	push   0x806000
  8013e8:	e8 13 0c 00 00       	call   802000 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ed:	83 c4 0c             	add    $0xc,%esp
  8013f0:	6a 00                	push   $0x0
  8013f2:	53                   	push   %ebx
  8013f3:	6a 00                	push   $0x0
  8013f5:	e8 96 0b 00 00       	call   801f90 <ipc_recv>
}
  8013fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5e                   	pop    %esi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801401:	83 ec 0c             	sub    $0xc,%esp
  801404:	6a 01                	push   $0x1
  801406:	e8 49 0c 00 00       	call   802054 <ipc_find_env>
  80140b:	a3 00 60 80 00       	mov    %eax,0x806000
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	eb c5                	jmp    8013da <fsipc+0x12>

00801415 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80141b:	8b 45 08             	mov    0x8(%ebp),%eax
  80141e:	8b 40 0c             	mov    0xc(%eax),%eax
  801421:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801426:	8b 45 0c             	mov    0xc(%ebp),%eax
  801429:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80142e:	ba 00 00 00 00       	mov    $0x0,%edx
  801433:	b8 02 00 00 00       	mov    $0x2,%eax
  801438:	e8 8b ff ff ff       	call   8013c8 <fsipc>
}
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <devfile_flush>:
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801445:	8b 45 08             	mov    0x8(%ebp),%eax
  801448:	8b 40 0c             	mov    0xc(%eax),%eax
  80144b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801450:	ba 00 00 00 00       	mov    $0x0,%edx
  801455:	b8 06 00 00 00       	mov    $0x6,%eax
  80145a:	e8 69 ff ff ff       	call   8013c8 <fsipc>
}
  80145f:	c9                   	leave  
  801460:	c3                   	ret    

00801461 <devfile_stat>:
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	53                   	push   %ebx
  801465:	83 ec 04             	sub    $0x4,%esp
  801468:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80146b:	8b 45 08             	mov    0x8(%ebp),%eax
  80146e:	8b 40 0c             	mov    0xc(%eax),%eax
  801471:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801476:	ba 00 00 00 00       	mov    $0x0,%edx
  80147b:	b8 05 00 00 00       	mov    $0x5,%eax
  801480:	e8 43 ff ff ff       	call   8013c8 <fsipc>
  801485:	85 c0                	test   %eax,%eax
  801487:	78 2c                	js     8014b5 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	68 00 50 80 00       	push   $0x805000
  801491:	53                   	push   %ebx
  801492:	e8 bb f2 ff ff       	call   800752 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801497:	a1 80 50 80 00       	mov    0x805080,%eax
  80149c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014a2:	a1 84 50 80 00       	mov    0x805084,%eax
  8014a7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <devfile_write>:
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	83 ec 0c             	sub    $0xc,%esp
  8014c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8014c3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014c8:	39 d0                	cmp    %edx,%eax
  8014ca:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014d9:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014de:	50                   	push   %eax
  8014df:	ff 75 0c             	push   0xc(%ebp)
  8014e2:	68 08 50 80 00       	push   $0x805008
  8014e7:	e8 fc f3 ff ff       	call   8008e8 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8014ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8014f6:	e8 cd fe ff ff       	call   8013c8 <fsipc>
}
  8014fb:	c9                   	leave  
  8014fc:	c3                   	ret    

008014fd <devfile_read>:
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	56                   	push   %esi
  801501:	53                   	push   %ebx
  801502:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801505:	8b 45 08             	mov    0x8(%ebp),%eax
  801508:	8b 40 0c             	mov    0xc(%eax),%eax
  80150b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801510:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801516:	ba 00 00 00 00       	mov    $0x0,%edx
  80151b:	b8 03 00 00 00       	mov    $0x3,%eax
  801520:	e8 a3 fe ff ff       	call   8013c8 <fsipc>
  801525:	89 c3                	mov    %eax,%ebx
  801527:	85 c0                	test   %eax,%eax
  801529:	78 1f                	js     80154a <devfile_read+0x4d>
	assert(r <= n);
  80152b:	39 f0                	cmp    %esi,%eax
  80152d:	77 24                	ja     801553 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80152f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801534:	7f 33                	jg     801569 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801536:	83 ec 04             	sub    $0x4,%esp
  801539:	50                   	push   %eax
  80153a:	68 00 50 80 00       	push   $0x805000
  80153f:	ff 75 0c             	push   0xc(%ebp)
  801542:	e8 a1 f3 ff ff       	call   8008e8 <memmove>
	return r;
  801547:	83 c4 10             	add    $0x10,%esp
}
  80154a:	89 d8                	mov    %ebx,%eax
  80154c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154f:	5b                   	pop    %ebx
  801550:	5e                   	pop    %esi
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    
	assert(r <= n);
  801553:	68 80 27 80 00       	push   $0x802780
  801558:	68 87 27 80 00       	push   $0x802787
  80155d:	6a 7c                	push   $0x7c
  80155f:	68 9c 27 80 00       	push   $0x80279c
  801564:	e8 e1 09 00 00       	call   801f4a <_panic>
	assert(r <= PGSIZE);
  801569:	68 a7 27 80 00       	push   $0x8027a7
  80156e:	68 87 27 80 00       	push   $0x802787
  801573:	6a 7d                	push   $0x7d
  801575:	68 9c 27 80 00       	push   $0x80279c
  80157a:	e8 cb 09 00 00       	call   801f4a <_panic>

0080157f <open>:
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	56                   	push   %esi
  801583:	53                   	push   %ebx
  801584:	83 ec 1c             	sub    $0x1c,%esp
  801587:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80158a:	56                   	push   %esi
  80158b:	e8 87 f1 ff ff       	call   800717 <strlen>
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801598:	7f 6c                	jg     801606 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80159a:	83 ec 0c             	sub    $0xc,%esp
  80159d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	e8 bd f8 ff ff       	call   800e63 <fd_alloc>
  8015a6:	89 c3                	mov    %eax,%ebx
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 3c                	js     8015eb <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	56                   	push   %esi
  8015b3:	68 00 50 80 00       	push   $0x805000
  8015b8:	e8 95 f1 ff ff       	call   800752 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c0:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015cd:	e8 f6 fd ff ff       	call   8013c8 <fsipc>
  8015d2:	89 c3                	mov    %eax,%ebx
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 19                	js     8015f4 <open+0x75>
	return fd2num(fd);
  8015db:	83 ec 0c             	sub    $0xc,%esp
  8015de:	ff 75 f4             	push   -0xc(%ebp)
  8015e1:	e8 56 f8 ff ff       	call   800e3c <fd2num>
  8015e6:	89 c3                	mov    %eax,%ebx
  8015e8:	83 c4 10             	add    $0x10,%esp
}
  8015eb:	89 d8                	mov    %ebx,%eax
  8015ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f0:	5b                   	pop    %ebx
  8015f1:	5e                   	pop    %esi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    
		fd_close(fd, 0);
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	6a 00                	push   $0x0
  8015f9:	ff 75 f4             	push   -0xc(%ebp)
  8015fc:	e8 58 f9 ff ff       	call   800f59 <fd_close>
		return r;
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	eb e5                	jmp    8015eb <open+0x6c>
		return -E_BAD_PATH;
  801606:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80160b:	eb de                	jmp    8015eb <open+0x6c>

0080160d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801613:	ba 00 00 00 00       	mov    $0x0,%edx
  801618:	b8 08 00 00 00       	mov    $0x8,%eax
  80161d:	e8 a6 fd ff ff       	call   8013c8 <fsipc>
}
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80162a:	68 b3 27 80 00       	push   $0x8027b3
  80162f:	ff 75 0c             	push   0xc(%ebp)
  801632:	e8 1b f1 ff ff       	call   800752 <strcpy>
	return 0;
}
  801637:	b8 00 00 00 00       	mov    $0x0,%eax
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <devsock_close>:
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	83 ec 10             	sub    $0x10,%esp
  801645:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801648:	53                   	push   %ebx
  801649:	e8 45 0a 00 00       	call   802093 <pageref>
  80164e:	89 c2                	mov    %eax,%edx
  801650:	83 c4 10             	add    $0x10,%esp
		return 0;
  801653:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801658:	83 fa 01             	cmp    $0x1,%edx
  80165b:	74 05                	je     801662 <devsock_close+0x24>
}
  80165d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801660:	c9                   	leave  
  801661:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801662:	83 ec 0c             	sub    $0xc,%esp
  801665:	ff 73 0c             	push   0xc(%ebx)
  801668:	e8 b7 02 00 00       	call   801924 <nsipc_close>
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	eb eb                	jmp    80165d <devsock_close+0x1f>

00801672 <devsock_write>:
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801678:	6a 00                	push   $0x0
  80167a:	ff 75 10             	push   0x10(%ebp)
  80167d:	ff 75 0c             	push   0xc(%ebp)
  801680:	8b 45 08             	mov    0x8(%ebp),%eax
  801683:	ff 70 0c             	push   0xc(%eax)
  801686:	e8 79 03 00 00       	call   801a04 <nsipc_send>
}
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <devsock_read>:
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801693:	6a 00                	push   $0x0
  801695:	ff 75 10             	push   0x10(%ebp)
  801698:	ff 75 0c             	push   0xc(%ebp)
  80169b:	8b 45 08             	mov    0x8(%ebp),%eax
  80169e:	ff 70 0c             	push   0xc(%eax)
  8016a1:	e8 ef 02 00 00       	call   801995 <nsipc_recv>
}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <fd2sockid>:
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016ae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016b1:	52                   	push   %edx
  8016b2:	50                   	push   %eax
  8016b3:	e8 fb f7 ff ff       	call   800eb3 <fd_lookup>
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 10                	js     8016cf <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c2:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016c8:	39 08                	cmp    %ecx,(%eax)
  8016ca:	75 05                	jne    8016d1 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8016cc:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    
		return -E_NOT_SUPP;
  8016d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016d6:	eb f7                	jmp    8016cf <fd2sockid+0x27>

008016d8 <alloc_sockfd>:
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	56                   	push   %esi
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 1c             	sub    $0x1c,%esp
  8016e0:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8016e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e5:	50                   	push   %eax
  8016e6:	e8 78 f7 ff ff       	call   800e63 <fd_alloc>
  8016eb:	89 c3                	mov    %eax,%ebx
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 43                	js     801737 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016f4:	83 ec 04             	sub    $0x4,%esp
  8016f7:	68 07 04 00 00       	push   $0x407
  8016fc:	ff 75 f4             	push   -0xc(%ebp)
  8016ff:	6a 00                	push   $0x0
  801701:	e8 48 f4 ff ff       	call   800b4e <sys_page_alloc>
  801706:	89 c3                	mov    %eax,%ebx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 28                	js     801737 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801712:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801718:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801724:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801727:	83 ec 0c             	sub    $0xc,%esp
  80172a:	50                   	push   %eax
  80172b:	e8 0c f7 ff ff       	call   800e3c <fd2num>
  801730:	89 c3                	mov    %eax,%ebx
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	eb 0c                	jmp    801743 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801737:	83 ec 0c             	sub    $0xc,%esp
  80173a:	56                   	push   %esi
  80173b:	e8 e4 01 00 00       	call   801924 <nsipc_close>
		return r;
  801740:	83 c4 10             	add    $0x10,%esp
}
  801743:	89 d8                	mov    %ebx,%eax
  801745:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801748:	5b                   	pop    %ebx
  801749:	5e                   	pop    %esi
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <accept>:
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801752:	8b 45 08             	mov    0x8(%ebp),%eax
  801755:	e8 4e ff ff ff       	call   8016a8 <fd2sockid>
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 1b                	js     801779 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80175e:	83 ec 04             	sub    $0x4,%esp
  801761:	ff 75 10             	push   0x10(%ebp)
  801764:	ff 75 0c             	push   0xc(%ebp)
  801767:	50                   	push   %eax
  801768:	e8 0e 01 00 00       	call   80187b <nsipc_accept>
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	85 c0                	test   %eax,%eax
  801772:	78 05                	js     801779 <accept+0x2d>
	return alloc_sockfd(r);
  801774:	e8 5f ff ff ff       	call   8016d8 <alloc_sockfd>
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <bind>:
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801781:	8b 45 08             	mov    0x8(%ebp),%eax
  801784:	e8 1f ff ff ff       	call   8016a8 <fd2sockid>
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 12                	js     80179f <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80178d:	83 ec 04             	sub    $0x4,%esp
  801790:	ff 75 10             	push   0x10(%ebp)
  801793:	ff 75 0c             	push   0xc(%ebp)
  801796:	50                   	push   %eax
  801797:	e8 31 01 00 00       	call   8018cd <nsipc_bind>
  80179c:	83 c4 10             	add    $0x10,%esp
}
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <shutdown>:
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	e8 f9 fe ff ff       	call   8016a8 <fd2sockid>
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 0f                	js     8017c2 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8017b3:	83 ec 08             	sub    $0x8,%esp
  8017b6:	ff 75 0c             	push   0xc(%ebp)
  8017b9:	50                   	push   %eax
  8017ba:	e8 43 01 00 00       	call   801902 <nsipc_shutdown>
  8017bf:	83 c4 10             	add    $0x10,%esp
}
  8017c2:	c9                   	leave  
  8017c3:	c3                   	ret    

008017c4 <connect>:
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cd:	e8 d6 fe ff ff       	call   8016a8 <fd2sockid>
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	78 12                	js     8017e8 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	ff 75 10             	push   0x10(%ebp)
  8017dc:	ff 75 0c             	push   0xc(%ebp)
  8017df:	50                   	push   %eax
  8017e0:	e8 59 01 00 00       	call   80193e <nsipc_connect>
  8017e5:	83 c4 10             	add    $0x10,%esp
}
  8017e8:	c9                   	leave  
  8017e9:	c3                   	ret    

008017ea <listen>:
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	e8 b0 fe ff ff       	call   8016a8 <fd2sockid>
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	78 0f                	js     80180b <listen+0x21>
	return nsipc_listen(r, backlog);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	ff 75 0c             	push   0xc(%ebp)
  801802:	50                   	push   %eax
  801803:	e8 6b 01 00 00       	call   801973 <nsipc_listen>
  801808:	83 c4 10             	add    $0x10,%esp
}
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    

0080180d <socket>:

int
socket(int domain, int type, int protocol)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801813:	ff 75 10             	push   0x10(%ebp)
  801816:	ff 75 0c             	push   0xc(%ebp)
  801819:	ff 75 08             	push   0x8(%ebp)
  80181c:	e8 41 02 00 00       	call   801a62 <nsipc_socket>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	78 05                	js     80182d <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801828:	e8 ab fe ff ff       	call   8016d8 <alloc_sockfd>
}
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	53                   	push   %ebx
  801833:	83 ec 04             	sub    $0x4,%esp
  801836:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801838:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80183f:	74 26                	je     801867 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801841:	6a 07                	push   $0x7
  801843:	68 00 70 80 00       	push   $0x807000
  801848:	53                   	push   %ebx
  801849:	ff 35 00 80 80 00    	push   0x808000
  80184f:	e8 ac 07 00 00       	call   802000 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801854:	83 c4 0c             	add    $0xc,%esp
  801857:	6a 00                	push   $0x0
  801859:	6a 00                	push   $0x0
  80185b:	6a 00                	push   $0x0
  80185d:	e8 2e 07 00 00       	call   801f90 <ipc_recv>
}
  801862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801865:	c9                   	leave  
  801866:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801867:	83 ec 0c             	sub    $0xc,%esp
  80186a:	6a 02                	push   $0x2
  80186c:	e8 e3 07 00 00       	call   802054 <ipc_find_env>
  801871:	a3 00 80 80 00       	mov    %eax,0x808000
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	eb c6                	jmp    801841 <nsipc+0x12>

0080187b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	56                   	push   %esi
  80187f:	53                   	push   %ebx
  801880:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80188b:	8b 06                	mov    (%esi),%eax
  80188d:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801892:	b8 01 00 00 00       	mov    $0x1,%eax
  801897:	e8 93 ff ff ff       	call   80182f <nsipc>
  80189c:	89 c3                	mov    %eax,%ebx
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	79 09                	jns    8018ab <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8018a2:	89 d8                	mov    %ebx,%eax
  8018a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a7:	5b                   	pop    %ebx
  8018a8:	5e                   	pop    %esi
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	ff 35 10 70 80 00    	push   0x807010
  8018b4:	68 00 70 80 00       	push   $0x807000
  8018b9:	ff 75 0c             	push   0xc(%ebp)
  8018bc:	e8 27 f0 ff ff       	call   8008e8 <memmove>
		*addrlen = ret->ret_addrlen;
  8018c1:	a1 10 70 80 00       	mov    0x807010,%eax
  8018c6:	89 06                	mov    %eax,(%esi)
  8018c8:	83 c4 10             	add    $0x10,%esp
	return r;
  8018cb:	eb d5                	jmp    8018a2 <nsipc_accept+0x27>

008018cd <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	53                   	push   %ebx
  8018d1:	83 ec 08             	sub    $0x8,%esp
  8018d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018df:	53                   	push   %ebx
  8018e0:	ff 75 0c             	push   0xc(%ebp)
  8018e3:	68 04 70 80 00       	push   $0x807004
  8018e8:	e8 fb ef ff ff       	call   8008e8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018ed:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8018f3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f8:	e8 32 ff ff ff       	call   80182f <nsipc>
}
  8018fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801910:	8b 45 0c             	mov    0xc(%ebp),%eax
  801913:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801918:	b8 03 00 00 00       	mov    $0x3,%eax
  80191d:	e8 0d ff ff ff       	call   80182f <nsipc>
}
  801922:	c9                   	leave  
  801923:	c3                   	ret    

00801924 <nsipc_close>:

int
nsipc_close(int s)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801932:	b8 04 00 00 00       	mov    $0x4,%eax
  801937:	e8 f3 fe ff ff       	call   80182f <nsipc>
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	53                   	push   %ebx
  801942:	83 ec 08             	sub    $0x8,%esp
  801945:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801950:	53                   	push   %ebx
  801951:	ff 75 0c             	push   0xc(%ebp)
  801954:	68 04 70 80 00       	push   $0x807004
  801959:	e8 8a ef ff ff       	call   8008e8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80195e:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801964:	b8 05 00 00 00       	mov    $0x5,%eax
  801969:	e8 c1 fe ff ff       	call   80182f <nsipc>
}
  80196e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801979:	8b 45 08             	mov    0x8(%ebp),%eax
  80197c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801981:	8b 45 0c             	mov    0xc(%ebp),%eax
  801984:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801989:	b8 06 00 00 00       	mov    $0x6,%eax
  80198e:	e8 9c fe ff ff       	call   80182f <nsipc>
}
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8019a5:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8019ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ae:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019b3:	b8 07 00 00 00       	mov    $0x7,%eax
  8019b8:	e8 72 fe ff ff       	call   80182f <nsipc>
  8019bd:	89 c3                	mov    %eax,%ebx
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	78 22                	js     8019e5 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8019c3:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019c8:	39 c6                	cmp    %eax,%esi
  8019ca:	0f 4e c6             	cmovle %esi,%eax
  8019cd:	39 c3                	cmp    %eax,%ebx
  8019cf:	7f 1d                	jg     8019ee <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019d1:	83 ec 04             	sub    $0x4,%esp
  8019d4:	53                   	push   %ebx
  8019d5:	68 00 70 80 00       	push   $0x807000
  8019da:	ff 75 0c             	push   0xc(%ebp)
  8019dd:	e8 06 ef ff ff       	call   8008e8 <memmove>
  8019e2:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019e5:	89 d8                	mov    %ebx,%eax
  8019e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ea:	5b                   	pop    %ebx
  8019eb:	5e                   	pop    %esi
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8019ee:	68 bf 27 80 00       	push   $0x8027bf
  8019f3:	68 87 27 80 00       	push   $0x802787
  8019f8:	6a 62                	push   $0x62
  8019fa:	68 d4 27 80 00       	push   $0x8027d4
  8019ff:	e8 46 05 00 00       	call   801f4a <_panic>

00801a04 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	53                   	push   %ebx
  801a08:	83 ec 04             	sub    $0x4,%esp
  801a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a11:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801a16:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a1c:	7f 2e                	jg     801a4c <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a1e:	83 ec 04             	sub    $0x4,%esp
  801a21:	53                   	push   %ebx
  801a22:	ff 75 0c             	push   0xc(%ebp)
  801a25:	68 0c 70 80 00       	push   $0x80700c
  801a2a:	e8 b9 ee ff ff       	call   8008e8 <memmove>
	nsipcbuf.send.req_size = size;
  801a2f:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801a35:	8b 45 14             	mov    0x14(%ebp),%eax
  801a38:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801a3d:	b8 08 00 00 00       	mov    $0x8,%eax
  801a42:	e8 e8 fd ff ff       	call   80182f <nsipc>
}
  801a47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    
	assert(size < 1600);
  801a4c:	68 e0 27 80 00       	push   $0x8027e0
  801a51:	68 87 27 80 00       	push   $0x802787
  801a56:	6a 6d                	push   $0x6d
  801a58:	68 d4 27 80 00       	push   $0x8027d4
  801a5d:	e8 e8 04 00 00       	call   801f4a <_panic>

00801a62 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801a70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a73:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801a78:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801a80:	b8 09 00 00 00       	mov    $0x9,%eax
  801a85:	e8 a5 fd ff ff       	call   80182f <nsipc>
}
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a94:	83 ec 0c             	sub    $0xc,%esp
  801a97:	ff 75 08             	push   0x8(%ebp)
  801a9a:	e8 ad f3 ff ff       	call   800e4c <fd2data>
  801a9f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aa1:	83 c4 08             	add    $0x8,%esp
  801aa4:	68 ec 27 80 00       	push   $0x8027ec
  801aa9:	53                   	push   %ebx
  801aaa:	e8 a3 ec ff ff       	call   800752 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aaf:	8b 46 04             	mov    0x4(%esi),%eax
  801ab2:	2b 06                	sub    (%esi),%eax
  801ab4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aba:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ac1:	00 00 00 
	stat->st_dev = &devpipe;
  801ac4:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801acb:	30 80 00 
	return 0;
}
  801ace:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5e                   	pop    %esi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	53                   	push   %ebx
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ae4:	53                   	push   %ebx
  801ae5:	6a 00                	push   $0x0
  801ae7:	e8 e7 f0 ff ff       	call   800bd3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aec:	89 1c 24             	mov    %ebx,(%esp)
  801aef:	e8 58 f3 ff ff       	call   800e4c <fd2data>
  801af4:	83 c4 08             	add    $0x8,%esp
  801af7:	50                   	push   %eax
  801af8:	6a 00                	push   $0x0
  801afa:	e8 d4 f0 ff ff       	call   800bd3 <sys_page_unmap>
}
  801aff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <_pipeisclosed>:
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	57                   	push   %edi
  801b08:	56                   	push   %esi
  801b09:	53                   	push   %ebx
  801b0a:	83 ec 1c             	sub    $0x1c,%esp
  801b0d:	89 c7                	mov    %eax,%edi
  801b0f:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b11:	a1 00 40 80 00       	mov    0x804000,%eax
  801b16:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	57                   	push   %edi
  801b1d:	e8 71 05 00 00       	call   802093 <pageref>
  801b22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b25:	89 34 24             	mov    %esi,(%esp)
  801b28:	e8 66 05 00 00       	call   802093 <pageref>
		nn = thisenv->env_runs;
  801b2d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801b33:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	39 cb                	cmp    %ecx,%ebx
  801b3b:	74 1b                	je     801b58 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b3d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b40:	75 cf                	jne    801b11 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b42:	8b 42 68             	mov    0x68(%edx),%eax
  801b45:	6a 01                	push   $0x1
  801b47:	50                   	push   %eax
  801b48:	53                   	push   %ebx
  801b49:	68 f3 27 80 00       	push   $0x8027f3
  801b4e:	e8 25 e6 ff ff       	call   800178 <cprintf>
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	eb b9                	jmp    801b11 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b58:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b5b:	0f 94 c0             	sete   %al
  801b5e:	0f b6 c0             	movzbl %al,%eax
}
  801b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b64:	5b                   	pop    %ebx
  801b65:	5e                   	pop    %esi
  801b66:	5f                   	pop    %edi
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <devpipe_write>:
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	57                   	push   %edi
  801b6d:	56                   	push   %esi
  801b6e:	53                   	push   %ebx
  801b6f:	83 ec 28             	sub    $0x28,%esp
  801b72:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b75:	56                   	push   %esi
  801b76:	e8 d1 f2 ff ff       	call   800e4c <fd2data>
  801b7b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	bf 00 00 00 00       	mov    $0x0,%edi
  801b85:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b88:	75 09                	jne    801b93 <devpipe_write+0x2a>
	return i;
  801b8a:	89 f8                	mov    %edi,%eax
  801b8c:	eb 23                	jmp    801bb1 <devpipe_write+0x48>
			sys_yield();
  801b8e:	e8 9c ef ff ff       	call   800b2f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b93:	8b 43 04             	mov    0x4(%ebx),%eax
  801b96:	8b 0b                	mov    (%ebx),%ecx
  801b98:	8d 51 20             	lea    0x20(%ecx),%edx
  801b9b:	39 d0                	cmp    %edx,%eax
  801b9d:	72 1a                	jb     801bb9 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801b9f:	89 da                	mov    %ebx,%edx
  801ba1:	89 f0                	mov    %esi,%eax
  801ba3:	e8 5c ff ff ff       	call   801b04 <_pipeisclosed>
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	74 e2                	je     801b8e <devpipe_write+0x25>
				return 0;
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb4:	5b                   	pop    %ebx
  801bb5:	5e                   	pop    %esi
  801bb6:	5f                   	pop    %edi
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bc0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc3:	89 c2                	mov    %eax,%edx
  801bc5:	c1 fa 1f             	sar    $0x1f,%edx
  801bc8:	89 d1                	mov    %edx,%ecx
  801bca:	c1 e9 1b             	shr    $0x1b,%ecx
  801bcd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bd0:	83 e2 1f             	and    $0x1f,%edx
  801bd3:	29 ca                	sub    %ecx,%edx
  801bd5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bd9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bdd:	83 c0 01             	add    $0x1,%eax
  801be0:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801be3:	83 c7 01             	add    $0x1,%edi
  801be6:	eb 9d                	jmp    801b85 <devpipe_write+0x1c>

00801be8 <devpipe_read>:
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	57                   	push   %edi
  801bec:	56                   	push   %esi
  801bed:	53                   	push   %ebx
  801bee:	83 ec 18             	sub    $0x18,%esp
  801bf1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bf4:	57                   	push   %edi
  801bf5:	e8 52 f2 ff ff       	call   800e4c <fd2data>
  801bfa:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	be 00 00 00 00       	mov    $0x0,%esi
  801c04:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c07:	75 13                	jne    801c1c <devpipe_read+0x34>
	return i;
  801c09:	89 f0                	mov    %esi,%eax
  801c0b:	eb 02                	jmp    801c0f <devpipe_read+0x27>
				return i;
  801c0d:	89 f0                	mov    %esi,%eax
}
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    
			sys_yield();
  801c17:	e8 13 ef ff ff       	call   800b2f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c1c:	8b 03                	mov    (%ebx),%eax
  801c1e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c21:	75 18                	jne    801c3b <devpipe_read+0x53>
			if (i > 0)
  801c23:	85 f6                	test   %esi,%esi
  801c25:	75 e6                	jne    801c0d <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801c27:	89 da                	mov    %ebx,%edx
  801c29:	89 f8                	mov    %edi,%eax
  801c2b:	e8 d4 fe ff ff       	call   801b04 <_pipeisclosed>
  801c30:	85 c0                	test   %eax,%eax
  801c32:	74 e3                	je     801c17 <devpipe_read+0x2f>
				return 0;
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
  801c39:	eb d4                	jmp    801c0f <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c3b:	99                   	cltd   
  801c3c:	c1 ea 1b             	shr    $0x1b,%edx
  801c3f:	01 d0                	add    %edx,%eax
  801c41:	83 e0 1f             	and    $0x1f,%eax
  801c44:	29 d0                	sub    %edx,%eax
  801c46:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c51:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c54:	83 c6 01             	add    $0x1,%esi
  801c57:	eb ab                	jmp    801c04 <devpipe_read+0x1c>

00801c59 <pipe>:
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	56                   	push   %esi
  801c5d:	53                   	push   %ebx
  801c5e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c64:	50                   	push   %eax
  801c65:	e8 f9 f1 ff ff       	call   800e63 <fd_alloc>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	0f 88 23 01 00 00    	js     801d9a <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c77:	83 ec 04             	sub    $0x4,%esp
  801c7a:	68 07 04 00 00       	push   $0x407
  801c7f:	ff 75 f4             	push   -0xc(%ebp)
  801c82:	6a 00                	push   $0x0
  801c84:	e8 c5 ee ff ff       	call   800b4e <sys_page_alloc>
  801c89:	89 c3                	mov    %eax,%ebx
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	0f 88 04 01 00 00    	js     801d9a <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801c96:	83 ec 0c             	sub    $0xc,%esp
  801c99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c9c:	50                   	push   %eax
  801c9d:	e8 c1 f1 ff ff       	call   800e63 <fd_alloc>
  801ca2:	89 c3                	mov    %eax,%ebx
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	0f 88 db 00 00 00    	js     801d8a <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801caf:	83 ec 04             	sub    $0x4,%esp
  801cb2:	68 07 04 00 00       	push   $0x407
  801cb7:	ff 75 f0             	push   -0x10(%ebp)
  801cba:	6a 00                	push   $0x0
  801cbc:	e8 8d ee ff ff       	call   800b4e <sys_page_alloc>
  801cc1:	89 c3                	mov    %eax,%ebx
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	0f 88 bc 00 00 00    	js     801d8a <pipe+0x131>
	va = fd2data(fd0);
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	ff 75 f4             	push   -0xc(%ebp)
  801cd4:	e8 73 f1 ff ff       	call   800e4c <fd2data>
  801cd9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdb:	83 c4 0c             	add    $0xc,%esp
  801cde:	68 07 04 00 00       	push   $0x407
  801ce3:	50                   	push   %eax
  801ce4:	6a 00                	push   $0x0
  801ce6:	e8 63 ee ff ff       	call   800b4e <sys_page_alloc>
  801ceb:	89 c3                	mov    %eax,%ebx
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	0f 88 82 00 00 00    	js     801d7a <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	ff 75 f0             	push   -0x10(%ebp)
  801cfe:	e8 49 f1 ff ff       	call   800e4c <fd2data>
  801d03:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d0a:	50                   	push   %eax
  801d0b:	6a 00                	push   $0x0
  801d0d:	56                   	push   %esi
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 7c ee ff ff       	call   800b91 <sys_page_map>
  801d15:	89 c3                	mov    %eax,%ebx
  801d17:	83 c4 20             	add    $0x20,%esp
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	78 4e                	js     801d6c <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801d1e:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d26:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d2b:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d32:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d35:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d41:	83 ec 0c             	sub    $0xc,%esp
  801d44:	ff 75 f4             	push   -0xc(%ebp)
  801d47:	e8 f0 f0 ff ff       	call   800e3c <fd2num>
  801d4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d51:	83 c4 04             	add    $0x4,%esp
  801d54:	ff 75 f0             	push   -0x10(%ebp)
  801d57:	e8 e0 f0 ff ff       	call   800e3c <fd2num>
  801d5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d5f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d6a:	eb 2e                	jmp    801d9a <pipe+0x141>
	sys_page_unmap(0, va);
  801d6c:	83 ec 08             	sub    $0x8,%esp
  801d6f:	56                   	push   %esi
  801d70:	6a 00                	push   $0x0
  801d72:	e8 5c ee ff ff       	call   800bd3 <sys_page_unmap>
  801d77:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d7a:	83 ec 08             	sub    $0x8,%esp
  801d7d:	ff 75 f0             	push   -0x10(%ebp)
  801d80:	6a 00                	push   $0x0
  801d82:	e8 4c ee ff ff       	call   800bd3 <sys_page_unmap>
  801d87:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d8a:	83 ec 08             	sub    $0x8,%esp
  801d8d:	ff 75 f4             	push   -0xc(%ebp)
  801d90:	6a 00                	push   $0x0
  801d92:	e8 3c ee ff ff       	call   800bd3 <sys_page_unmap>
  801d97:	83 c4 10             	add    $0x10,%esp
}
  801d9a:	89 d8                	mov    %ebx,%eax
  801d9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <pipeisclosed>:
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dac:	50                   	push   %eax
  801dad:	ff 75 08             	push   0x8(%ebp)
  801db0:	e8 fe f0 ff ff       	call   800eb3 <fd_lookup>
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 18                	js     801dd4 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	ff 75 f4             	push   -0xc(%ebp)
  801dc2:	e8 85 f0 ff ff       	call   800e4c <fd2data>
  801dc7:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcc:	e8 33 fd ff ff       	call   801b04 <_pipeisclosed>
  801dd1:	83 c4 10             	add    $0x10,%esp
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ddb:	c3                   	ret    

00801ddc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801de2:	68 0b 28 80 00       	push   $0x80280b
  801de7:	ff 75 0c             	push   0xc(%ebp)
  801dea:	e8 63 e9 ff ff       	call   800752 <strcpy>
	return 0;
}
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <devcons_write>:
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	57                   	push   %edi
  801dfa:	56                   	push   %esi
  801dfb:	53                   	push   %ebx
  801dfc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e02:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e07:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e0d:	eb 2e                	jmp    801e3d <devcons_write+0x47>
		m = n - tot;
  801e0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e12:	29 f3                	sub    %esi,%ebx
  801e14:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e19:	39 c3                	cmp    %eax,%ebx
  801e1b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e1e:	83 ec 04             	sub    $0x4,%esp
  801e21:	53                   	push   %ebx
  801e22:	89 f0                	mov    %esi,%eax
  801e24:	03 45 0c             	add    0xc(%ebp),%eax
  801e27:	50                   	push   %eax
  801e28:	57                   	push   %edi
  801e29:	e8 ba ea ff ff       	call   8008e8 <memmove>
		sys_cputs(buf, m);
  801e2e:	83 c4 08             	add    $0x8,%esp
  801e31:	53                   	push   %ebx
  801e32:	57                   	push   %edi
  801e33:	e8 5a ec ff ff       	call   800a92 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e38:	01 de                	add    %ebx,%esi
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e40:	72 cd                	jb     801e0f <devcons_write+0x19>
}
  801e42:	89 f0                	mov    %esi,%eax
  801e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5f                   	pop    %edi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <devcons_read>:
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 08             	sub    $0x8,%esp
  801e52:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e5b:	75 07                	jne    801e64 <devcons_read+0x18>
  801e5d:	eb 1f                	jmp    801e7e <devcons_read+0x32>
		sys_yield();
  801e5f:	e8 cb ec ff ff       	call   800b2f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e64:	e8 47 ec ff ff       	call   800ab0 <sys_cgetc>
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	74 f2                	je     801e5f <devcons_read+0x13>
	if (c < 0)
  801e6d:	78 0f                	js     801e7e <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801e6f:	83 f8 04             	cmp    $0x4,%eax
  801e72:	74 0c                	je     801e80 <devcons_read+0x34>
	*(char*)vbuf = c;
  801e74:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e77:	88 02                	mov    %al,(%edx)
	return 1;
  801e79:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    
		return 0;
  801e80:	b8 00 00 00 00       	mov    $0x0,%eax
  801e85:	eb f7                	jmp    801e7e <devcons_read+0x32>

00801e87 <cputchar>:
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e90:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e93:	6a 01                	push   $0x1
  801e95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e98:	50                   	push   %eax
  801e99:	e8 f4 eb ff ff       	call   800a92 <sys_cputs>
}
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    

00801ea3 <getchar>:
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ea9:	6a 01                	push   $0x1
  801eab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eae:	50                   	push   %eax
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 66 f2 ff ff       	call   80111c <read>
	if (r < 0)
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	78 06                	js     801ec3 <getchar+0x20>
	if (r < 1)
  801ebd:	74 06                	je     801ec5 <getchar+0x22>
	return c;
  801ebf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    
		return -E_EOF;
  801ec5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801eca:	eb f7                	jmp    801ec3 <getchar+0x20>

00801ecc <iscons>:
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed5:	50                   	push   %eax
  801ed6:	ff 75 08             	push   0x8(%ebp)
  801ed9:	e8 d5 ef ff ff       	call   800eb3 <fd_lookup>
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	78 11                	js     801ef6 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eee:	39 10                	cmp    %edx,(%eax)
  801ef0:	0f 94 c0             	sete   %al
  801ef3:	0f b6 c0             	movzbl %al,%eax
}
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <opencons>:
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801efe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f01:	50                   	push   %eax
  801f02:	e8 5c ef ff ff       	call   800e63 <fd_alloc>
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 3a                	js     801f48 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f0e:	83 ec 04             	sub    $0x4,%esp
  801f11:	68 07 04 00 00       	push   $0x407
  801f16:	ff 75 f4             	push   -0xc(%ebp)
  801f19:	6a 00                	push   $0x0
  801f1b:	e8 2e ec ff ff       	call   800b4e <sys_page_alloc>
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	85 c0                	test   %eax,%eax
  801f25:	78 21                	js     801f48 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f30:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f35:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f3c:	83 ec 0c             	sub    $0xc,%esp
  801f3f:	50                   	push   %eax
  801f40:	e8 f7 ee ff ff       	call   800e3c <fd2num>
  801f45:	83 c4 10             	add    $0x10,%esp
}
  801f48:	c9                   	leave  
  801f49:	c3                   	ret    

00801f4a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	56                   	push   %esi
  801f4e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f4f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f52:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f58:	e8 b3 eb ff ff       	call   800b10 <sys_getenvid>
  801f5d:	83 ec 0c             	sub    $0xc,%esp
  801f60:	ff 75 0c             	push   0xc(%ebp)
  801f63:	ff 75 08             	push   0x8(%ebp)
  801f66:	56                   	push   %esi
  801f67:	50                   	push   %eax
  801f68:	68 18 28 80 00       	push   $0x802818
  801f6d:	e8 06 e2 ff ff       	call   800178 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f72:	83 c4 18             	add    $0x18,%esp
  801f75:	53                   	push   %ebx
  801f76:	ff 75 10             	push   0x10(%ebp)
  801f79:	e8 a9 e1 ff ff       	call   800127 <vcprintf>
	cprintf("\n");
  801f7e:	c7 04 24 04 28 80 00 	movl   $0x802804,(%esp)
  801f85:	e8 ee e1 ff ff       	call   800178 <cprintf>
  801f8a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f8d:	cc                   	int3   
  801f8e:	eb fd                	jmp    801f8d <_panic+0x43>

00801f90 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	56                   	push   %esi
  801f94:	53                   	push   %ebx
  801f95:	8b 75 08             	mov    0x8(%ebp),%esi
  801f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fa5:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801fa8:	83 ec 0c             	sub    $0xc,%esp
  801fab:	50                   	push   %eax
  801fac:	e8 4d ed ff ff       	call   800cfe <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	85 f6                	test   %esi,%esi
  801fb6:	74 17                	je     801fcf <ipc_recv+0x3f>
  801fb8:	ba 00 00 00 00       	mov    $0x0,%edx
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	78 0c                	js     801fcd <ipc_recv+0x3d>
  801fc1:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fc7:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801fcd:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801fcf:	85 db                	test   %ebx,%ebx
  801fd1:	74 17                	je     801fea <ipc_recv+0x5a>
  801fd3:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 0c                	js     801fe8 <ipc_recv+0x58>
  801fdc:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fe2:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801fe8:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801fea:	85 c0                	test   %eax,%eax
  801fec:	78 0b                	js     801ff9 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801fee:	a1 00 40 80 00       	mov    0x804000,%eax
  801ff3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801ff9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ffc:	5b                   	pop    %ebx
  801ffd:	5e                   	pop    %esi
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    

00802000 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	57                   	push   %edi
  802004:	56                   	push   %esi
  802005:	53                   	push   %ebx
  802006:	83 ec 0c             	sub    $0xc,%esp
  802009:	8b 7d 08             	mov    0x8(%ebp),%edi
  80200c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80200f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802012:	85 db                	test   %ebx,%ebx
  802014:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802019:	0f 44 d8             	cmove  %eax,%ebx
  80201c:	eb 05                	jmp    802023 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80201e:	e8 0c eb ff ff       	call   800b2f <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802023:	ff 75 14             	push   0x14(%ebp)
  802026:	53                   	push   %ebx
  802027:	56                   	push   %esi
  802028:	57                   	push   %edi
  802029:	e8 ad ec ff ff       	call   800cdb <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802034:	74 e8                	je     80201e <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802036:	85 c0                	test   %eax,%eax
  802038:	78 08                	js     802042 <ipc_send+0x42>
	}while (r<0);

}
  80203a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802042:	50                   	push   %eax
  802043:	68 3b 28 80 00       	push   $0x80283b
  802048:	6a 3d                	push   $0x3d
  80204a:	68 4f 28 80 00       	push   $0x80284f
  80204f:	e8 f6 fe ff ff       	call   801f4a <_panic>

00802054 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80205a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80205f:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802065:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80206b:	8b 52 60             	mov    0x60(%edx),%edx
  80206e:	39 ca                	cmp    %ecx,%edx
  802070:	74 11                	je     802083 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802072:	83 c0 01             	add    $0x1,%eax
  802075:	3d 00 04 00 00       	cmp    $0x400,%eax
  80207a:	75 e3                	jne    80205f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80207c:	b8 00 00 00 00       	mov    $0x0,%eax
  802081:	eb 0e                	jmp    802091 <ipc_find_env+0x3d>
			return envs[i].env_id;
  802083:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80208e:	8b 40 58             	mov    0x58(%eax),%eax
}
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    

00802093 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802099:	89 c2                	mov    %eax,%edx
  80209b:	c1 ea 16             	shr    $0x16,%edx
  80209e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020a5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020aa:	f6 c1 01             	test   $0x1,%cl
  8020ad:	74 1c                	je     8020cb <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8020af:	c1 e8 0c             	shr    $0xc,%eax
  8020b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020b9:	a8 01                	test   $0x1,%al
  8020bb:	74 0e                	je     8020cb <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020bd:	c1 e8 0c             	shr    $0xc,%eax
  8020c0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020c7:	ef 
  8020c8:	0f b7 d2             	movzwl %dx,%edx
}
  8020cb:	89 d0                	mov    %edx,%eax
  8020cd:	5d                   	pop    %ebp
  8020ce:	c3                   	ret    
  8020cf:	90                   	nop

008020d0 <__udivdi3>:
  8020d0:	f3 0f 1e fb          	endbr32 
  8020d4:	55                   	push   %ebp
  8020d5:	57                   	push   %edi
  8020d6:	56                   	push   %esi
  8020d7:	53                   	push   %ebx
  8020d8:	83 ec 1c             	sub    $0x1c,%esp
  8020db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	75 19                	jne    802108 <__udivdi3+0x38>
  8020ef:	39 f3                	cmp    %esi,%ebx
  8020f1:	76 4d                	jbe    802140 <__udivdi3+0x70>
  8020f3:	31 ff                	xor    %edi,%edi
  8020f5:	89 e8                	mov    %ebp,%eax
  8020f7:	89 f2                	mov    %esi,%edx
  8020f9:	f7 f3                	div    %ebx
  8020fb:	89 fa                	mov    %edi,%edx
  8020fd:	83 c4 1c             	add    $0x1c,%esp
  802100:	5b                   	pop    %ebx
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    
  802105:	8d 76 00             	lea    0x0(%esi),%esi
  802108:	39 f0                	cmp    %esi,%eax
  80210a:	76 14                	jbe    802120 <__udivdi3+0x50>
  80210c:	31 ff                	xor    %edi,%edi
  80210e:	31 c0                	xor    %eax,%eax
  802110:	89 fa                	mov    %edi,%edx
  802112:	83 c4 1c             	add    $0x1c,%esp
  802115:	5b                   	pop    %ebx
  802116:	5e                   	pop    %esi
  802117:	5f                   	pop    %edi
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    
  80211a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802120:	0f bd f8             	bsr    %eax,%edi
  802123:	83 f7 1f             	xor    $0x1f,%edi
  802126:	75 48                	jne    802170 <__udivdi3+0xa0>
  802128:	39 f0                	cmp    %esi,%eax
  80212a:	72 06                	jb     802132 <__udivdi3+0x62>
  80212c:	31 c0                	xor    %eax,%eax
  80212e:	39 eb                	cmp    %ebp,%ebx
  802130:	77 de                	ja     802110 <__udivdi3+0x40>
  802132:	b8 01 00 00 00       	mov    $0x1,%eax
  802137:	eb d7                	jmp    802110 <__udivdi3+0x40>
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 d9                	mov    %ebx,%ecx
  802142:	85 db                	test   %ebx,%ebx
  802144:	75 0b                	jne    802151 <__udivdi3+0x81>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f3                	div    %ebx
  80214f:	89 c1                	mov    %eax,%ecx
  802151:	31 d2                	xor    %edx,%edx
  802153:	89 f0                	mov    %esi,%eax
  802155:	f7 f1                	div    %ecx
  802157:	89 c6                	mov    %eax,%esi
  802159:	89 e8                	mov    %ebp,%eax
  80215b:	89 f7                	mov    %esi,%edi
  80215d:	f7 f1                	div    %ecx
  80215f:	89 fa                	mov    %edi,%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 f9                	mov    %edi,%ecx
  802172:	ba 20 00 00 00       	mov    $0x20,%edx
  802177:	29 fa                	sub    %edi,%edx
  802179:	d3 e0                	shl    %cl,%eax
  80217b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80217f:	89 d1                	mov    %edx,%ecx
  802181:	89 d8                	mov    %ebx,%eax
  802183:	d3 e8                	shr    %cl,%eax
  802185:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802189:	09 c1                	or     %eax,%ecx
  80218b:	89 f0                	mov    %esi,%eax
  80218d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802191:	89 f9                	mov    %edi,%ecx
  802193:	d3 e3                	shl    %cl,%ebx
  802195:	89 d1                	mov    %edx,%ecx
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 f9                	mov    %edi,%ecx
  80219b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80219f:	89 eb                	mov    %ebp,%ebx
  8021a1:	d3 e6                	shl    %cl,%esi
  8021a3:	89 d1                	mov    %edx,%ecx
  8021a5:	d3 eb                	shr    %cl,%ebx
  8021a7:	09 f3                	or     %esi,%ebx
  8021a9:	89 c6                	mov    %eax,%esi
  8021ab:	89 f2                	mov    %esi,%edx
  8021ad:	89 d8                	mov    %ebx,%eax
  8021af:	f7 74 24 08          	divl   0x8(%esp)
  8021b3:	89 d6                	mov    %edx,%esi
  8021b5:	89 c3                	mov    %eax,%ebx
  8021b7:	f7 64 24 0c          	mull   0xc(%esp)
  8021bb:	39 d6                	cmp    %edx,%esi
  8021bd:	72 19                	jb     8021d8 <__udivdi3+0x108>
  8021bf:	89 f9                	mov    %edi,%ecx
  8021c1:	d3 e5                	shl    %cl,%ebp
  8021c3:	39 c5                	cmp    %eax,%ebp
  8021c5:	73 04                	jae    8021cb <__udivdi3+0xfb>
  8021c7:	39 d6                	cmp    %edx,%esi
  8021c9:	74 0d                	je     8021d8 <__udivdi3+0x108>
  8021cb:	89 d8                	mov    %ebx,%eax
  8021cd:	31 ff                	xor    %edi,%edi
  8021cf:	e9 3c ff ff ff       	jmp    802110 <__udivdi3+0x40>
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021db:	31 ff                	xor    %edi,%edi
  8021dd:	e9 2e ff ff ff       	jmp    802110 <__udivdi3+0x40>
  8021e2:	66 90                	xchg   %ax,%ax
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	f3 0f 1e fb          	endbr32 
  8021f4:	55                   	push   %ebp
  8021f5:	57                   	push   %edi
  8021f6:	56                   	push   %esi
  8021f7:	53                   	push   %ebx
  8021f8:	83 ec 1c             	sub    $0x1c,%esp
  8021fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802203:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802207:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80220b:	89 f0                	mov    %esi,%eax
  80220d:	89 da                	mov    %ebx,%edx
  80220f:	85 ff                	test   %edi,%edi
  802211:	75 15                	jne    802228 <__umoddi3+0x38>
  802213:	39 dd                	cmp    %ebx,%ebp
  802215:	76 39                	jbe    802250 <__umoddi3+0x60>
  802217:	f7 f5                	div    %ebp
  802219:	89 d0                	mov    %edx,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	83 c4 1c             	add    $0x1c,%esp
  802220:	5b                   	pop    %ebx
  802221:	5e                   	pop    %esi
  802222:	5f                   	pop    %edi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    
  802225:	8d 76 00             	lea    0x0(%esi),%esi
  802228:	39 df                	cmp    %ebx,%edi
  80222a:	77 f1                	ja     80221d <__umoddi3+0x2d>
  80222c:	0f bd cf             	bsr    %edi,%ecx
  80222f:	83 f1 1f             	xor    $0x1f,%ecx
  802232:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802236:	75 40                	jne    802278 <__umoddi3+0x88>
  802238:	39 df                	cmp    %ebx,%edi
  80223a:	72 04                	jb     802240 <__umoddi3+0x50>
  80223c:	39 f5                	cmp    %esi,%ebp
  80223e:	77 dd                	ja     80221d <__umoddi3+0x2d>
  802240:	89 da                	mov    %ebx,%edx
  802242:	89 f0                	mov    %esi,%eax
  802244:	29 e8                	sub    %ebp,%eax
  802246:	19 fa                	sbb    %edi,%edx
  802248:	eb d3                	jmp    80221d <__umoddi3+0x2d>
  80224a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802250:	89 e9                	mov    %ebp,%ecx
  802252:	85 ed                	test   %ebp,%ebp
  802254:	75 0b                	jne    802261 <__umoddi3+0x71>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f5                	div    %ebp
  80225f:	89 c1                	mov    %eax,%ecx
  802261:	89 d8                	mov    %ebx,%eax
  802263:	31 d2                	xor    %edx,%edx
  802265:	f7 f1                	div    %ecx
  802267:	89 f0                	mov    %esi,%eax
  802269:	f7 f1                	div    %ecx
  80226b:	89 d0                	mov    %edx,%eax
  80226d:	31 d2                	xor    %edx,%edx
  80226f:	eb ac                	jmp    80221d <__umoddi3+0x2d>
  802271:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802278:	8b 44 24 04          	mov    0x4(%esp),%eax
  80227c:	ba 20 00 00 00       	mov    $0x20,%edx
  802281:	29 c2                	sub    %eax,%edx
  802283:	89 c1                	mov    %eax,%ecx
  802285:	89 e8                	mov    %ebp,%eax
  802287:	d3 e7                	shl    %cl,%edi
  802289:	89 d1                	mov    %edx,%ecx
  80228b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80228f:	d3 e8                	shr    %cl,%eax
  802291:	89 c1                	mov    %eax,%ecx
  802293:	8b 44 24 04          	mov    0x4(%esp),%eax
  802297:	09 f9                	or     %edi,%ecx
  802299:	89 df                	mov    %ebx,%edi
  80229b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229f:	89 c1                	mov    %eax,%ecx
  8022a1:	d3 e5                	shl    %cl,%ebp
  8022a3:	89 d1                	mov    %edx,%ecx
  8022a5:	d3 ef                	shr    %cl,%edi
  8022a7:	89 c1                	mov    %eax,%ecx
  8022a9:	89 f0                	mov    %esi,%eax
  8022ab:	d3 e3                	shl    %cl,%ebx
  8022ad:	89 d1                	mov    %edx,%ecx
  8022af:	89 fa                	mov    %edi,%edx
  8022b1:	d3 e8                	shr    %cl,%eax
  8022b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022b8:	09 d8                	or     %ebx,%eax
  8022ba:	f7 74 24 08          	divl   0x8(%esp)
  8022be:	89 d3                	mov    %edx,%ebx
  8022c0:	d3 e6                	shl    %cl,%esi
  8022c2:	f7 e5                	mul    %ebp
  8022c4:	89 c7                	mov    %eax,%edi
  8022c6:	89 d1                	mov    %edx,%ecx
  8022c8:	39 d3                	cmp    %edx,%ebx
  8022ca:	72 06                	jb     8022d2 <__umoddi3+0xe2>
  8022cc:	75 0e                	jne    8022dc <__umoddi3+0xec>
  8022ce:	39 c6                	cmp    %eax,%esi
  8022d0:	73 0a                	jae    8022dc <__umoddi3+0xec>
  8022d2:	29 e8                	sub    %ebp,%eax
  8022d4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8022d8:	89 d1                	mov    %edx,%ecx
  8022da:	89 c7                	mov    %eax,%edi
  8022dc:	89 f5                	mov    %esi,%ebp
  8022de:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022e2:	29 fd                	sub    %edi,%ebp
  8022e4:	19 cb                	sbb    %ecx,%ebx
  8022e6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022eb:	89 d8                	mov    %ebx,%eax
  8022ed:	d3 e0                	shl    %cl,%eax
  8022ef:	89 f1                	mov    %esi,%ecx
  8022f1:	d3 ed                	shr    %cl,%ebp
  8022f3:	d3 eb                	shr    %cl,%ebx
  8022f5:	09 e8                	or     %ebp,%eax
  8022f7:	89 da                	mov    %ebx,%edx
  8022f9:	83 c4 1c             	add    $0x1c,%esp
  8022fc:	5b                   	pop    %ebx
  8022fd:	5e                   	pop    %esi
  8022fe:	5f                   	pop    %edi
  8022ff:	5d                   	pop    %ebp
  802300:	c3                   	ret    
