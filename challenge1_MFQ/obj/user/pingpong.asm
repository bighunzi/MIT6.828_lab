
obj/user/pingpong.debug：     文件格式 elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 9d 0e 00 00       	call   800ede <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 4f                	jne    800097 <umain+0x64>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800048:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004b:	83 ec 04             	sub    $0x4,%esp
  80004e:	6a 00                	push   $0x0
  800050:	6a 00                	push   $0x0
  800052:	56                   	push   %esi
  800053:	e8 09 10 00 00       	call   801061 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 ee 0a 00 00       	call   800b50 <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 f6 25 80 00       	push   $0x8025f6
  80006a:	e8 49 01 00 00       	call   8001b8 <cprintf>
		if (i == 10)
  80006f:	83 c4 20             	add    $0x20,%esp
  800072:	83 fb 0a             	cmp    $0xa,%ebx
  800075:	74 18                	je     80008f <umain+0x5c>
			return;
		i++;
  800077:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	53                   	push   %ebx
  80007f:	ff 75 e4             	push   -0x1c(%ebp)
  800082:	e8 4a 10 00 00       	call   8010d1 <ipc_send>
		if (i == 10)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	83 fb 0a             	cmp    $0xa,%ebx
  80008d:	75 bc                	jne    80004b <umain+0x18>
			return;
	}

}
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
  800097:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800099:	e8 b2 0a 00 00       	call   800b50 <sys_getenvid>
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	50                   	push   %eax
  8000a3:	68 e0 25 80 00       	push   $0x8025e0
  8000a8:	e8 0b 01 00 00       	call   8001b8 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	push   -0x1c(%ebp)
  8000b6:	e8 16 10 00 00       	call   8010d1 <ipc_send>
  8000bb:	83 c4 20             	add    $0x20,%esp
  8000be:	eb 88                	jmp    800048 <umain+0x15>

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000cb:	e8 80 0a 00 00       	call   800b50 <sys_getenvid>
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8000db:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e0:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e5:	85 db                	test   %ebx,%ebx
  8000e7:	7e 07                	jle    8000f0 <libmain+0x30>
		binaryname = argv[0];
  8000e9:	8b 06                	mov    (%esi),%eax
  8000eb:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f0:	83 ec 08             	sub    $0x8,%esp
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
  8000f5:	e8 39 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000fa:	e8 0a 00 00 00       	call   800109 <exit>
}
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800105:	5b                   	pop    %ebx
  800106:	5e                   	pop    %esi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    

00800109 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010f:	e8 21 12 00 00       	call   801335 <close_all>
	sys_env_destroy(0);
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	6a 00                	push   $0x0
  800119:	e8 f1 09 00 00       	call   800b0f <sys_env_destroy>
}
  80011e:	83 c4 10             	add    $0x10,%esp
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	53                   	push   %ebx
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012d:	8b 13                	mov    (%ebx),%edx
  80012f:	8d 42 01             	lea    0x1(%edx),%eax
  800132:	89 03                	mov    %eax,(%ebx)
  800134:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800137:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800140:	74 09                	je     80014b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800142:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800146:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800149:	c9                   	leave  
  80014a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80014b:	83 ec 08             	sub    $0x8,%esp
  80014e:	68 ff 00 00 00       	push   $0xff
  800153:	8d 43 08             	lea    0x8(%ebx),%eax
  800156:	50                   	push   %eax
  800157:	e8 76 09 00 00       	call   800ad2 <sys_cputs>
		b->idx = 0;
  80015c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	eb db                	jmp    800142 <putch+0x1f>

00800167 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800170:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800177:	00 00 00 
	b.cnt = 0;
  80017a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800181:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800184:	ff 75 0c             	push   0xc(%ebp)
  800187:	ff 75 08             	push   0x8(%ebp)
  80018a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	68 23 01 80 00       	push   $0x800123
  800196:	e8 14 01 00 00       	call   8002af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019b:	83 c4 08             	add    $0x8,%esp
  80019e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001a4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 22 09 00 00       	call   800ad2 <sys_cputs>

	return b.cnt;
}
  8001b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c1:	50                   	push   %eax
  8001c2:	ff 75 08             	push   0x8(%ebp)
  8001c5:	e8 9d ff ff ff       	call   800167 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 1c             	sub    $0x1c,%esp
  8001d5:	89 c7                	mov    %eax,%edi
  8001d7:	89 d6                	mov    %edx,%esi
  8001d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001df:	89 d1                	mov    %edx,%ecx
  8001e1:	89 c2                	mov    %eax,%edx
  8001e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ec:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f9:	39 c2                	cmp    %eax,%edx
  8001fb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001fe:	72 3e                	jb     80023e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800200:	83 ec 0c             	sub    $0xc,%esp
  800203:	ff 75 18             	push   0x18(%ebp)
  800206:	83 eb 01             	sub    $0x1,%ebx
  800209:	53                   	push   %ebx
  80020a:	50                   	push   %eax
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	ff 75 e4             	push   -0x1c(%ebp)
  800211:	ff 75 e0             	push   -0x20(%ebp)
  800214:	ff 75 dc             	push   -0x24(%ebp)
  800217:	ff 75 d8             	push   -0x28(%ebp)
  80021a:	e8 71 21 00 00       	call   802390 <__udivdi3>
  80021f:	83 c4 18             	add    $0x18,%esp
  800222:	52                   	push   %edx
  800223:	50                   	push   %eax
  800224:	89 f2                	mov    %esi,%edx
  800226:	89 f8                	mov    %edi,%eax
  800228:	e8 9f ff ff ff       	call   8001cc <printnum>
  80022d:	83 c4 20             	add    $0x20,%esp
  800230:	eb 13                	jmp    800245 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800232:	83 ec 08             	sub    $0x8,%esp
  800235:	56                   	push   %esi
  800236:	ff 75 18             	push   0x18(%ebp)
  800239:	ff d7                	call   *%edi
  80023b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023e:	83 eb 01             	sub    $0x1,%ebx
  800241:	85 db                	test   %ebx,%ebx
  800243:	7f ed                	jg     800232 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	56                   	push   %esi
  800249:	83 ec 04             	sub    $0x4,%esp
  80024c:	ff 75 e4             	push   -0x1c(%ebp)
  80024f:	ff 75 e0             	push   -0x20(%ebp)
  800252:	ff 75 dc             	push   -0x24(%ebp)
  800255:	ff 75 d8             	push   -0x28(%ebp)
  800258:	e8 53 22 00 00       	call   8024b0 <__umoddi3>
  80025d:	83 c4 14             	add    $0x14,%esp
  800260:	0f be 80 13 26 80 00 	movsbl 0x802613(%eax),%eax
  800267:	50                   	push   %eax
  800268:	ff d7                	call   *%edi
}
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	3b 50 04             	cmp    0x4(%eax),%edx
  800284:	73 0a                	jae    800290 <sprintputch+0x1b>
		*b->buf++ = ch;
  800286:	8d 4a 01             	lea    0x1(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 45 08             	mov    0x8(%ebp),%eax
  80028e:	88 02                	mov    %al,(%edx)
}
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <printfmt>:
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800298:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029b:	50                   	push   %eax
  80029c:	ff 75 10             	push   0x10(%ebp)
  80029f:	ff 75 0c             	push   0xc(%ebp)
  8002a2:	ff 75 08             	push   0x8(%ebp)
  8002a5:	e8 05 00 00 00       	call   8002af <vprintfmt>
}
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <vprintfmt>:
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 3c             	sub    $0x3c,%esp
  8002b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c1:	eb 0a                	jmp    8002cd <vprintfmt+0x1e>
			putch(ch, putdat);
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	53                   	push   %ebx
  8002c7:	50                   	push   %eax
  8002c8:	ff d6                	call   *%esi
  8002ca:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cd:	83 c7 01             	add    $0x1,%edi
  8002d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d4:	83 f8 25             	cmp    $0x25,%eax
  8002d7:	74 0c                	je     8002e5 <vprintfmt+0x36>
			if (ch == '\0')
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	75 e6                	jne    8002c3 <vprintfmt+0x14>
}
  8002dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5e                   	pop    %esi
  8002e2:	5f                   	pop    %edi
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    
		padc = ' ';
  8002e5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002e9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002f0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002fe:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8d 47 01             	lea    0x1(%edi),%eax
  800306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800309:	0f b6 17             	movzbl (%edi),%edx
  80030c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80030f:	3c 55                	cmp    $0x55,%al
  800311:	0f 87 bb 03 00 00    	ja     8006d2 <vprintfmt+0x423>
  800317:	0f b6 c0             	movzbl %al,%eax
  80031a:	ff 24 85 60 27 80 00 	jmp    *0x802760(,%eax,4)
  800321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800324:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800328:	eb d9                	jmp    800303 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800331:	eb d0                	jmp    800303 <vprintfmt+0x54>
  800333:	0f b6 d2             	movzbl %dl,%edx
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800339:	b8 00 00 00 00       	mov    $0x0,%eax
  80033e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800341:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800344:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800348:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80034b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034e:	83 f9 09             	cmp    $0x9,%ecx
  800351:	77 55                	ja     8003a8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800353:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800356:	eb e9                	jmp    800341 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800358:	8b 45 14             	mov    0x14(%ebp),%eax
  80035b:	8b 00                	mov    (%eax),%eax
  80035d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800360:	8b 45 14             	mov    0x14(%ebp),%eax
  800363:	8d 40 04             	lea    0x4(%eax),%eax
  800366:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80036c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800370:	79 91                	jns    800303 <vprintfmt+0x54>
				width = precision, precision = -1;
  800372:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800375:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800378:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80037f:	eb 82                	jmp    800303 <vprintfmt+0x54>
  800381:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800384:	85 d2                	test   %edx,%edx
  800386:	b8 00 00 00 00       	mov    $0x0,%eax
  80038b:	0f 49 c2             	cmovns %edx,%eax
  80038e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800394:	e9 6a ff ff ff       	jmp    800303 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80039c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a3:	e9 5b ff ff ff       	jmp    800303 <vprintfmt+0x54>
  8003a8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ae:	eb bc                	jmp    80036c <vprintfmt+0xbd>
			lflag++;
  8003b0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b6:	e9 48 ff ff ff       	jmp    800303 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 78 04             	lea    0x4(%eax),%edi
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	53                   	push   %ebx
  8003c5:	ff 30                	push   (%eax)
  8003c7:	ff d6                	call   *%esi
			break;
  8003c9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003cc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003cf:	e9 9d 02 00 00       	jmp    800671 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 78 04             	lea    0x4(%eax),%edi
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	89 d0                	mov    %edx,%eax
  8003de:	f7 d8                	neg    %eax
  8003e0:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e3:	83 f8 0f             	cmp    $0xf,%eax
  8003e6:	7f 23                	jg     80040b <vprintfmt+0x15c>
  8003e8:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	74 18                	je     80040b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003f3:	52                   	push   %edx
  8003f4:	68 e1 2a 80 00       	push   $0x802ae1
  8003f9:	53                   	push   %ebx
  8003fa:	56                   	push   %esi
  8003fb:	e8 92 fe ff ff       	call   800292 <printfmt>
  800400:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800403:	89 7d 14             	mov    %edi,0x14(%ebp)
  800406:	e9 66 02 00 00       	jmp    800671 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80040b:	50                   	push   %eax
  80040c:	68 2b 26 80 00       	push   $0x80262b
  800411:	53                   	push   %ebx
  800412:	56                   	push   %esi
  800413:	e8 7a fe ff ff       	call   800292 <printfmt>
  800418:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80041e:	e9 4e 02 00 00       	jmp    800671 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	83 c0 04             	add    $0x4,%eax
  800429:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800431:	85 d2                	test   %edx,%edx
  800433:	b8 24 26 80 00       	mov    $0x802624,%eax
  800438:	0f 45 c2             	cmovne %edx,%eax
  80043b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80043e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800442:	7e 06                	jle    80044a <vprintfmt+0x19b>
  800444:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800448:	75 0d                	jne    800457 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80044d:	89 c7                	mov    %eax,%edi
  80044f:	03 45 e0             	add    -0x20(%ebp),%eax
  800452:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800455:	eb 55                	jmp    8004ac <vprintfmt+0x1fd>
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 d8             	push   -0x28(%ebp)
  80045d:	ff 75 cc             	push   -0x34(%ebp)
  800460:	e8 0a 03 00 00       	call   80076f <strnlen>
  800465:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800468:	29 c1                	sub    %eax,%ecx
  80046a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80046d:	83 c4 10             	add    $0x10,%esp
  800470:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800472:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800476:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	eb 0f                	jmp    80048a <vprintfmt+0x1db>
					putch(padc, putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	53                   	push   %ebx
  80047f:	ff 75 e0             	push   -0x20(%ebp)
  800482:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800484:	83 ef 01             	sub    $0x1,%edi
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	85 ff                	test   %edi,%edi
  80048c:	7f ed                	jg     80047b <vprintfmt+0x1cc>
  80048e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800491:	85 d2                	test   %edx,%edx
  800493:	b8 00 00 00 00       	mov    $0x0,%eax
  800498:	0f 49 c2             	cmovns %edx,%eax
  80049b:	29 c2                	sub    %eax,%edx
  80049d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a0:	eb a8                	jmp    80044a <vprintfmt+0x19b>
					putch(ch, putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	52                   	push   %edx
  8004a7:	ff d6                	call   *%esi
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004af:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b1:	83 c7 01             	add    $0x1,%edi
  8004b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b8:	0f be d0             	movsbl %al,%edx
  8004bb:	85 d2                	test   %edx,%edx
  8004bd:	74 4b                	je     80050a <vprintfmt+0x25b>
  8004bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c3:	78 06                	js     8004cb <vprintfmt+0x21c>
  8004c5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004c9:	78 1e                	js     8004e9 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004cf:	74 d1                	je     8004a2 <vprintfmt+0x1f3>
  8004d1:	0f be c0             	movsbl %al,%eax
  8004d4:	83 e8 20             	sub    $0x20,%eax
  8004d7:	83 f8 5e             	cmp    $0x5e,%eax
  8004da:	76 c6                	jbe    8004a2 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	53                   	push   %ebx
  8004e0:	6a 3f                	push   $0x3f
  8004e2:	ff d6                	call   *%esi
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	eb c3                	jmp    8004ac <vprintfmt+0x1fd>
  8004e9:	89 cf                	mov    %ecx,%edi
  8004eb:	eb 0e                	jmp    8004fb <vprintfmt+0x24c>
				putch(' ', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	53                   	push   %ebx
  8004f1:	6a 20                	push   $0x20
  8004f3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004f5:	83 ef 01             	sub    $0x1,%edi
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	85 ff                	test   %edi,%edi
  8004fd:	7f ee                	jg     8004ed <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800502:	89 45 14             	mov    %eax,0x14(%ebp)
  800505:	e9 67 01 00 00       	jmp    800671 <vprintfmt+0x3c2>
  80050a:	89 cf                	mov    %ecx,%edi
  80050c:	eb ed                	jmp    8004fb <vprintfmt+0x24c>
	if (lflag >= 2)
  80050e:	83 f9 01             	cmp    $0x1,%ecx
  800511:	7f 1b                	jg     80052e <vprintfmt+0x27f>
	else if (lflag)
  800513:	85 c9                	test   %ecx,%ecx
  800515:	74 63                	je     80057a <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051f:	99                   	cltd   
  800520:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 40 04             	lea    0x4(%eax),%eax
  800529:	89 45 14             	mov    %eax,0x14(%ebp)
  80052c:	eb 17                	jmp    800545 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8b 50 04             	mov    0x4(%eax),%edx
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800539:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 40 08             	lea    0x8(%eax),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800545:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800548:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80054b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800550:	85 c9                	test   %ecx,%ecx
  800552:	0f 89 ff 00 00 00    	jns    800657 <vprintfmt+0x3a8>
				putch('-', putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	53                   	push   %ebx
  80055c:	6a 2d                	push   $0x2d
  80055e:	ff d6                	call   *%esi
				num = -(long long) num;
  800560:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800563:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800566:	f7 da                	neg    %edx
  800568:	83 d1 00             	adc    $0x0,%ecx
  80056b:	f7 d9                	neg    %ecx
  80056d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800570:	bf 0a 00 00 00       	mov    $0xa,%edi
  800575:	e9 dd 00 00 00       	jmp    800657 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	99                   	cltd   
  800583:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 40 04             	lea    0x4(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
  80058f:	eb b4                	jmp    800545 <vprintfmt+0x296>
	if (lflag >= 2)
  800591:	83 f9 01             	cmp    $0x1,%ecx
  800594:	7f 1e                	jg     8005b4 <vprintfmt+0x305>
	else if (lflag)
  800596:	85 c9                	test   %ecx,%ecx
  800598:	74 32                	je     8005cc <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 10                	mov    (%eax),%edx
  80059f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a4:	8d 40 04             	lea    0x4(%eax),%eax
  8005a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005aa:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005af:	e9 a3 00 00 00       	jmp    800657 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bc:	8d 40 08             	lea    0x8(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005c7:	e9 8b 00 00 00       	jmp    800657 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8b 10                	mov    (%eax),%edx
  8005d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d6:	8d 40 04             	lea    0x4(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dc:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005e1:	eb 74                	jmp    800657 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005e3:	83 f9 01             	cmp    $0x1,%ecx
  8005e6:	7f 1b                	jg     800603 <vprintfmt+0x354>
	else if (lflag)
  8005e8:	85 c9                	test   %ecx,%ecx
  8005ea:	74 2c                	je     800618 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 10                	mov    (%eax),%edx
  8005f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f6:	8d 40 04             	lea    0x4(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005fc:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800601:	eb 54                	jmp    800657 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	8b 48 04             	mov    0x4(%eax),%ecx
  80060b:	8d 40 08             	lea    0x8(%eax),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800611:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800616:	eb 3f                	jmp    800657 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800622:	8d 40 04             	lea    0x4(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800628:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80062d:	eb 28                	jmp    800657 <vprintfmt+0x3a8>
			putch('0', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	6a 30                	push   $0x30
  800635:	ff d6                	call   *%esi
			putch('x', putdat);
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	53                   	push   %ebx
  80063b:	6a 78                	push   $0x78
  80063d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 10                	mov    (%eax),%edx
  800644:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800649:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80064c:	8d 40 04             	lea    0x4(%eax),%eax
  80064f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800652:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800657:	83 ec 0c             	sub    $0xc,%esp
  80065a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80065e:	50                   	push   %eax
  80065f:	ff 75 e0             	push   -0x20(%ebp)
  800662:	57                   	push   %edi
  800663:	51                   	push   %ecx
  800664:	52                   	push   %edx
  800665:	89 da                	mov    %ebx,%edx
  800667:	89 f0                	mov    %esi,%eax
  800669:	e8 5e fb ff ff       	call   8001cc <printnum>
			break;
  80066e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800674:	e9 54 fc ff ff       	jmp    8002cd <vprintfmt+0x1e>
	if (lflag >= 2)
  800679:	83 f9 01             	cmp    $0x1,%ecx
  80067c:	7f 1b                	jg     800699 <vprintfmt+0x3ea>
	else if (lflag)
  80067e:	85 c9                	test   %ecx,%ecx
  800680:	74 2c                	je     8006ae <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 10                	mov    (%eax),%edx
  800687:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068c:	8d 40 04             	lea    0x4(%eax),%eax
  80068f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800692:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800697:	eb be                	jmp    800657 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a1:	8d 40 08             	lea    0x8(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006ac:	eb a9                	jmp    800657 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 10                	mov    (%eax),%edx
  8006b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006be:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006c3:	eb 92                	jmp    800657 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	6a 25                	push   $0x25
  8006cb:	ff d6                	call   *%esi
			break;
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	eb 9f                	jmp    800671 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 25                	push   $0x25
  8006d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	89 f8                	mov    %edi,%eax
  8006df:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e3:	74 05                	je     8006ea <vprintfmt+0x43b>
  8006e5:	83 e8 01             	sub    $0x1,%eax
  8006e8:	eb f5                	jmp    8006df <vprintfmt+0x430>
  8006ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ed:	eb 82                	jmp    800671 <vprintfmt+0x3c2>

008006ef <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	83 ec 18             	sub    $0x18,%esp
  8006f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800702:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800705:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070c:	85 c0                	test   %eax,%eax
  80070e:	74 26                	je     800736 <vsnprintf+0x47>
  800710:	85 d2                	test   %edx,%edx
  800712:	7e 22                	jle    800736 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800714:	ff 75 14             	push   0x14(%ebp)
  800717:	ff 75 10             	push   0x10(%ebp)
  80071a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	68 75 02 80 00       	push   $0x800275
  800723:	e8 87 fb ff ff       	call   8002af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800728:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800731:	83 c4 10             	add    $0x10,%esp
}
  800734:	c9                   	leave  
  800735:	c3                   	ret    
		return -E_INVAL;
  800736:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80073b:	eb f7                	jmp    800734 <vsnprintf+0x45>

0080073d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800743:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800746:	50                   	push   %eax
  800747:	ff 75 10             	push   0x10(%ebp)
  80074a:	ff 75 0c             	push   0xc(%ebp)
  80074d:	ff 75 08             	push   0x8(%ebp)
  800750:	e8 9a ff ff ff       	call   8006ef <vsnprintf>
	va_end(ap);

	return rc;
}
  800755:	c9                   	leave  
  800756:	c3                   	ret    

00800757 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075d:	b8 00 00 00 00       	mov    $0x0,%eax
  800762:	eb 03                	jmp    800767 <strlen+0x10>
		n++;
  800764:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800767:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076b:	75 f7                	jne    800764 <strlen+0xd>
	return n;
}
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800775:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 03                	jmp    800782 <strnlen+0x13>
		n++;
  80077f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800782:	39 d0                	cmp    %edx,%eax
  800784:	74 08                	je     80078e <strnlen+0x1f>
  800786:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80078a:	75 f3                	jne    80077f <strnlen+0x10>
  80078c:	89 c2                	mov    %eax,%edx
	return n;
}
  80078e:	89 d0                	mov    %edx,%eax
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007a5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007a8:	83 c0 01             	add    $0x1,%eax
  8007ab:	84 d2                	test   %dl,%dl
  8007ad:	75 f2                	jne    8007a1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007af:	89 c8                	mov    %ecx,%eax
  8007b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 10             	sub    $0x10,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c0:	53                   	push   %ebx
  8007c1:	e8 91 ff ff ff       	call   800757 <strlen>
  8007c6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007c9:	ff 75 0c             	push   0xc(%ebp)
  8007cc:	01 d8                	add    %ebx,%eax
  8007ce:	50                   	push   %eax
  8007cf:	e8 be ff ff ff       	call   800792 <strcpy>
	return dst;
}
  8007d4:	89 d8                	mov    %ebx,%eax
  8007d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	56                   	push   %esi
  8007df:	53                   	push   %ebx
  8007e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	89 f3                	mov    %esi,%ebx
  8007e8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007eb:	89 f0                	mov    %esi,%eax
  8007ed:	eb 0f                	jmp    8007fe <strncpy+0x23>
		*dst++ = *src;
  8007ef:	83 c0 01             	add    $0x1,%eax
  8007f2:	0f b6 0a             	movzbl (%edx),%ecx
  8007f5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f8:	80 f9 01             	cmp    $0x1,%cl
  8007fb:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007fe:	39 d8                	cmp    %ebx,%eax
  800800:	75 ed                	jne    8007ef <strncpy+0x14>
	}
	return ret;
}
  800802:	89 f0                	mov    %esi,%eax
  800804:	5b                   	pop    %ebx
  800805:	5e                   	pop    %esi
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	8b 75 08             	mov    0x8(%ebp),%esi
  800810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800813:	8b 55 10             	mov    0x10(%ebp),%edx
  800816:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800818:	85 d2                	test   %edx,%edx
  80081a:	74 21                	je     80083d <strlcpy+0x35>
  80081c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800820:	89 f2                	mov    %esi,%edx
  800822:	eb 09                	jmp    80082d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	83 c2 01             	add    $0x1,%edx
  80082a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80082d:	39 c2                	cmp    %eax,%edx
  80082f:	74 09                	je     80083a <strlcpy+0x32>
  800831:	0f b6 19             	movzbl (%ecx),%ebx
  800834:	84 db                	test   %bl,%bl
  800836:	75 ec                	jne    800824 <strlcpy+0x1c>
  800838:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80083a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083d:	29 f0                	sub    %esi,%eax
}
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084c:	eb 06                	jmp    800854 <strcmp+0x11>
		p++, q++;
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800854:	0f b6 01             	movzbl (%ecx),%eax
  800857:	84 c0                	test   %al,%al
  800859:	74 04                	je     80085f <strcmp+0x1c>
  80085b:	3a 02                	cmp    (%edx),%al
  80085d:	74 ef                	je     80084e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085f:	0f b6 c0             	movzbl %al,%eax
  800862:	0f b6 12             	movzbl (%edx),%edx
  800865:	29 d0                	sub    %edx,%eax
}
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
  800873:	89 c3                	mov    %eax,%ebx
  800875:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800878:	eb 06                	jmp    800880 <strncmp+0x17>
		n--, p++, q++;
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800880:	39 d8                	cmp    %ebx,%eax
  800882:	74 18                	je     80089c <strncmp+0x33>
  800884:	0f b6 08             	movzbl (%eax),%ecx
  800887:	84 c9                	test   %cl,%cl
  800889:	74 04                	je     80088f <strncmp+0x26>
  80088b:	3a 0a                	cmp    (%edx),%cl
  80088d:	74 eb                	je     80087a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 00             	movzbl (%eax),%eax
  800892:	0f b6 12             	movzbl (%edx),%edx
  800895:	29 d0                	sub    %edx,%eax
}
  800897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    
		return 0;
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a1:	eb f4                	jmp    800897 <strncmp+0x2e>

008008a3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ad:	eb 03                	jmp    8008b2 <strchr+0xf>
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	0f b6 10             	movzbl (%eax),%edx
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	74 06                	je     8008bf <strchr+0x1c>
		if (*s == c)
  8008b9:	38 ca                	cmp    %cl,%dl
  8008bb:	75 f2                	jne    8008af <strchr+0xc>
  8008bd:	eb 05                	jmp    8008c4 <strchr+0x21>
			return (char *) s;
	return 0;
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d3:	38 ca                	cmp    %cl,%dl
  8008d5:	74 09                	je     8008e0 <strfind+0x1a>
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	74 05                	je     8008e0 <strfind+0x1a>
	for (; *s; s++)
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	eb f0                	jmp    8008d0 <strfind+0xa>
			break;
	return (char *) s;
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	57                   	push   %edi
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ee:	85 c9                	test   %ecx,%ecx
  8008f0:	74 2f                	je     800921 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f2:	89 f8                	mov    %edi,%eax
  8008f4:	09 c8                	or     %ecx,%eax
  8008f6:	a8 03                	test   $0x3,%al
  8008f8:	75 21                	jne    80091b <memset+0x39>
		c &= 0xFF;
  8008fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fe:	89 d0                	mov    %edx,%eax
  800900:	c1 e0 08             	shl    $0x8,%eax
  800903:	89 d3                	mov    %edx,%ebx
  800905:	c1 e3 18             	shl    $0x18,%ebx
  800908:	89 d6                	mov    %edx,%esi
  80090a:	c1 e6 10             	shl    $0x10,%esi
  80090d:	09 f3                	or     %esi,%ebx
  80090f:	09 da                	or     %ebx,%edx
  800911:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800913:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800916:	fc                   	cld    
  800917:	f3 ab                	rep stos %eax,%es:(%edi)
  800919:	eb 06                	jmp    800921 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	fc                   	cld    
  80091f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800921:	89 f8                	mov    %edi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	57                   	push   %edi
  80092c:	56                   	push   %esi
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 75 0c             	mov    0xc(%ebp),%esi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800936:	39 c6                	cmp    %eax,%esi
  800938:	73 32                	jae    80096c <memmove+0x44>
  80093a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093d:	39 c2                	cmp    %eax,%edx
  80093f:	76 2b                	jbe    80096c <memmove+0x44>
		s += n;
		d += n;
  800941:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	89 d6                	mov    %edx,%esi
  800946:	09 fe                	or     %edi,%esi
  800948:	09 ce                	or     %ecx,%esi
  80094a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800950:	75 0e                	jne    800960 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800952:	83 ef 04             	sub    $0x4,%edi
  800955:	8d 72 fc             	lea    -0x4(%edx),%esi
  800958:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80095b:	fd                   	std    
  80095c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095e:	eb 09                	jmp    800969 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800960:	83 ef 01             	sub    $0x1,%edi
  800963:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800966:	fd                   	std    
  800967:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800969:	fc                   	cld    
  80096a:	eb 1a                	jmp    800986 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096c:	89 f2                	mov    %esi,%edx
  80096e:	09 c2                	or     %eax,%edx
  800970:	09 ca                	or     %ecx,%edx
  800972:	f6 c2 03             	test   $0x3,%dl
  800975:	75 0a                	jne    800981 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800977:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80097a:	89 c7                	mov    %eax,%edi
  80097c:	fc                   	cld    
  80097d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097f:	eb 05                	jmp    800986 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800990:	ff 75 10             	push   0x10(%ebp)
  800993:	ff 75 0c             	push   0xc(%ebp)
  800996:	ff 75 08             	push   0x8(%ebp)
  800999:	e8 8a ff ff ff       	call   800928 <memmove>
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ab:	89 c6                	mov    %eax,%esi
  8009ad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b0:	eb 06                	jmp    8009b8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009b8:	39 f0                	cmp    %esi,%eax
  8009ba:	74 14                	je     8009d0 <memcmp+0x30>
		if (*s1 != *s2)
  8009bc:	0f b6 08             	movzbl (%eax),%ecx
  8009bf:	0f b6 1a             	movzbl (%edx),%ebx
  8009c2:	38 d9                	cmp    %bl,%cl
  8009c4:	74 ec                	je     8009b2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009c6:	0f b6 c1             	movzbl %cl,%eax
  8009c9:	0f b6 db             	movzbl %bl,%ebx
  8009cc:	29 d8                	sub    %ebx,%eax
  8009ce:	eb 05                	jmp    8009d5 <memcmp+0x35>
	}

	return 0;
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e2:	89 c2                	mov    %eax,%edx
  8009e4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e7:	eb 03                	jmp    8009ec <memfind+0x13>
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	39 d0                	cmp    %edx,%eax
  8009ee:	73 04                	jae    8009f4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f0:	38 08                	cmp    %cl,(%eax)
  8009f2:	75 f5                	jne    8009e9 <memfind+0x10>
			break;
	return (void *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	57                   	push   %edi
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a02:	eb 03                	jmp    800a07 <strtol+0x11>
		s++;
  800a04:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a07:	0f b6 02             	movzbl (%edx),%eax
  800a0a:	3c 20                	cmp    $0x20,%al
  800a0c:	74 f6                	je     800a04 <strtol+0xe>
  800a0e:	3c 09                	cmp    $0x9,%al
  800a10:	74 f2                	je     800a04 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a12:	3c 2b                	cmp    $0x2b,%al
  800a14:	74 2a                	je     800a40 <strtol+0x4a>
	int neg = 0;
  800a16:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a1b:	3c 2d                	cmp    $0x2d,%al
  800a1d:	74 2b                	je     800a4a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a25:	75 0f                	jne    800a36 <strtol+0x40>
  800a27:	80 3a 30             	cmpb   $0x30,(%edx)
  800a2a:	74 28                	je     800a54 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2c:	85 db                	test   %ebx,%ebx
  800a2e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a33:	0f 44 d8             	cmove  %eax,%ebx
  800a36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a3b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a3e:	eb 46                	jmp    800a86 <strtol+0x90>
		s++;
  800a40:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a43:	bf 00 00 00 00       	mov    $0x0,%edi
  800a48:	eb d5                	jmp    800a1f <strtol+0x29>
		s++, neg = 1;
  800a4a:	83 c2 01             	add    $0x1,%edx
  800a4d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a52:	eb cb                	jmp    800a1f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a54:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a58:	74 0e                	je     800a68 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a5a:	85 db                	test   %ebx,%ebx
  800a5c:	75 d8                	jne    800a36 <strtol+0x40>
		s++, base = 8;
  800a5e:	83 c2 01             	add    $0x1,%edx
  800a61:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a66:	eb ce                	jmp    800a36 <strtol+0x40>
		s += 2, base = 16;
  800a68:	83 c2 02             	add    $0x2,%edx
  800a6b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a70:	eb c4                	jmp    800a36 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a72:	0f be c0             	movsbl %al,%eax
  800a75:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a78:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a7b:	7d 3a                	jge    800ab7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a7d:	83 c2 01             	add    $0x1,%edx
  800a80:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a84:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a86:	0f b6 02             	movzbl (%edx),%eax
  800a89:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 09             	cmp    $0x9,%bl
  800a91:	76 df                	jbe    800a72 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a93:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a96:	89 f3                	mov    %esi,%ebx
  800a98:	80 fb 19             	cmp    $0x19,%bl
  800a9b:	77 08                	ja     800aa5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a9d:	0f be c0             	movsbl %al,%eax
  800aa0:	83 e8 57             	sub    $0x57,%eax
  800aa3:	eb d3                	jmp    800a78 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800aa5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800aa8:	89 f3                	mov    %esi,%ebx
  800aaa:	80 fb 19             	cmp    $0x19,%bl
  800aad:	77 08                	ja     800ab7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800aaf:	0f be c0             	movsbl %al,%eax
  800ab2:	83 e8 37             	sub    $0x37,%eax
  800ab5:	eb c1                	jmp    800a78 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abb:	74 05                	je     800ac2 <strtol+0xcc>
		*endptr = (char *) s;
  800abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ac2:	89 c8                	mov    %ecx,%eax
  800ac4:	f7 d8                	neg    %eax
  800ac6:	85 ff                	test   %edi,%edi
  800ac8:	0f 45 c8             	cmovne %eax,%ecx
}
  800acb:	89 c8                	mov    %ecx,%eax
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad8:	b8 00 00 00 00       	mov    $0x0,%eax
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae3:	89 c3                	mov    %eax,%ebx
  800ae5:	89 c7                	mov    %eax,%edi
  800ae7:	89 c6                	mov    %eax,%esi
  800ae9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af6:	ba 00 00 00 00       	mov    $0x0,%edx
  800afb:	b8 01 00 00 00       	mov    $0x1,%eax
  800b00:	89 d1                	mov    %edx,%ecx
  800b02:	89 d3                	mov    %edx,%ebx
  800b04:	89 d7                	mov    %edx,%edi
  800b06:	89 d6                	mov    %edx,%esi
  800b08:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b20:	b8 03 00 00 00       	mov    $0x3,%eax
  800b25:	89 cb                	mov    %ecx,%ebx
  800b27:	89 cf                	mov    %ecx,%edi
  800b29:	89 ce                	mov    %ecx,%esi
  800b2b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	7f 08                	jg     800b39 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	50                   	push   %eax
  800b3d:	6a 03                	push   $0x3
  800b3f:	68 1f 29 80 00       	push   $0x80291f
  800b44:	6a 2a                	push   $0x2a
  800b46:	68 3c 29 80 00       	push   $0x80293c
  800b4b:	e8 22 17 00 00       	call   802272 <_panic>

00800b50 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b60:	89 d1                	mov    %edx,%ecx
  800b62:	89 d3                	mov    %edx,%ebx
  800b64:	89 d7                	mov    %edx,%edi
  800b66:	89 d6                	mov    %edx,%esi
  800b68:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <sys_yield>:

void
sys_yield(void)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b75:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7f:	89 d1                	mov    %edx,%ecx
  800b81:	89 d3                	mov    %edx,%ebx
  800b83:	89 d7                	mov    %edx,%edi
  800b85:	89 d6                	mov    %edx,%esi
  800b87:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b97:	be 00 00 00 00       	mov    $0x0,%esi
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baa:	89 f7                	mov    %esi,%edi
  800bac:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bae:	85 c0                	test   %eax,%eax
  800bb0:	7f 08                	jg     800bba <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	50                   	push   %eax
  800bbe:	6a 04                	push   $0x4
  800bc0:	68 1f 29 80 00       	push   $0x80291f
  800bc5:	6a 2a                	push   $0x2a
  800bc7:	68 3c 29 80 00       	push   $0x80293c
  800bcc:	e8 a1 16 00 00       	call   802272 <_panic>

00800bd1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be0:	b8 05 00 00 00       	mov    $0x5,%eax
  800be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800beb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bee:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7f 08                	jg     800bfc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	50                   	push   %eax
  800c00:	6a 05                	push   $0x5
  800c02:	68 1f 29 80 00       	push   $0x80291f
  800c07:	6a 2a                	push   $0x2a
  800c09:	68 3c 29 80 00       	push   $0x80293c
  800c0e:	e8 5f 16 00 00       	call   802272 <_panic>

00800c13 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c27:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2c:	89 df                	mov    %ebx,%edi
  800c2e:	89 de                	mov    %ebx,%esi
  800c30:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7f 08                	jg     800c3e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3e:	83 ec 0c             	sub    $0xc,%esp
  800c41:	50                   	push   %eax
  800c42:	6a 06                	push   $0x6
  800c44:	68 1f 29 80 00       	push   $0x80291f
  800c49:	6a 2a                	push   $0x2a
  800c4b:	68 3c 29 80 00       	push   $0x80293c
  800c50:	e8 1d 16 00 00       	call   802272 <_panic>

00800c55 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6e:	89 df                	mov    %ebx,%edi
  800c70:	89 de                	mov    %ebx,%esi
  800c72:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7f 08                	jg     800c80 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	50                   	push   %eax
  800c84:	6a 08                	push   $0x8
  800c86:	68 1f 29 80 00       	push   $0x80291f
  800c8b:	6a 2a                	push   $0x2a
  800c8d:	68 3c 29 80 00       	push   $0x80293c
  800c92:	e8 db 15 00 00       	call   802272 <_panic>

00800c97 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb0:	89 df                	mov    %ebx,%edi
  800cb2:	89 de                	mov    %ebx,%esi
  800cb4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7f 08                	jg     800cc2 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	50                   	push   %eax
  800cc6:	6a 09                	push   $0x9
  800cc8:	68 1f 29 80 00       	push   $0x80291f
  800ccd:	6a 2a                	push   $0x2a
  800ccf:	68 3c 29 80 00       	push   $0x80293c
  800cd4:	e8 99 15 00 00       	call   802272 <_panic>

00800cd9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ced:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf2:	89 df                	mov    %ebx,%edi
  800cf4:	89 de                	mov    %ebx,%esi
  800cf6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7f 08                	jg     800d04 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	50                   	push   %eax
  800d08:	6a 0a                	push   $0xa
  800d0a:	68 1f 29 80 00       	push   $0x80291f
  800d0f:	6a 2a                	push   $0x2a
  800d11:	68 3c 29 80 00       	push   $0x80293c
  800d16:	e8 57 15 00 00       	call   802272 <_panic>

00800d1b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2c:	be 00 00 00 00       	mov    $0x0,%esi
  800d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d37:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d54:	89 cb                	mov    %ecx,%ebx
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	89 ce                	mov    %ecx,%esi
  800d5a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7f 08                	jg     800d68 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	50                   	push   %eax
  800d6c:	6a 0d                	push   $0xd
  800d6e:	68 1f 29 80 00       	push   $0x80291f
  800d73:	6a 2a                	push   $0x2a
  800d75:	68 3c 29 80 00       	push   $0x80293c
  800d7a:	e8 f3 14 00 00       	call   802272 <_panic>

00800d7f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d85:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d8f:	89 d1                	mov    %edx,%ecx
  800d91:	89 d3                	mov    %edx,%ebx
  800d93:	89 d7                	mov    %edx,%edi
  800d95:	89 d6                	mov    %edx,%esi
  800d97:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	b8 0f 00 00 00       	mov    $0xf,%eax
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	b8 10 00 00 00       	mov    $0x10,%eax
  800dd5:	89 df                	mov    %ebx,%edi
  800dd7:	89 de                	mov    %ebx,%esi
  800dd9:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de8:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800dea:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dee:	0f 84 8e 00 00 00    	je     800e82 <pgfault+0xa2>
  800df4:	89 f0                	mov    %esi,%eax
  800df6:	c1 e8 0c             	shr    $0xc,%eax
  800df9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e00:	f6 c4 08             	test   $0x8,%ah
  800e03:	74 7d                	je     800e82 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e05:	e8 46 fd ff ff       	call   800b50 <sys_getenvid>
  800e0a:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e0c:	83 ec 04             	sub    $0x4,%esp
  800e0f:	6a 07                	push   $0x7
  800e11:	68 00 f0 7f 00       	push   $0x7ff000
  800e16:	50                   	push   %eax
  800e17:	e8 72 fd ff ff       	call   800b8e <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	78 73                	js     800e96 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e23:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	68 00 10 00 00       	push   $0x1000
  800e31:	56                   	push   %esi
  800e32:	68 00 f0 7f 00       	push   $0x7ff000
  800e37:	e8 ec fa ff ff       	call   800928 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e3c:	83 c4 08             	add    $0x8,%esp
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
  800e41:	e8 cd fd ff ff       	call   800c13 <sys_page_unmap>
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	78 5b                	js     800ea8 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	6a 07                	push   $0x7
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	68 00 f0 7f 00       	push   $0x7ff000
  800e59:	53                   	push   %ebx
  800e5a:	e8 72 fd ff ff       	call   800bd1 <sys_page_map>
  800e5f:	83 c4 20             	add    $0x20,%esp
  800e62:	85 c0                	test   %eax,%eax
  800e64:	78 54                	js     800eba <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	68 00 f0 7f 00       	push   $0x7ff000
  800e6e:	53                   	push   %ebx
  800e6f:	e8 9f fd ff ff       	call   800c13 <sys_page_unmap>
  800e74:	83 c4 10             	add    $0x10,%esp
  800e77:	85 c0                	test   %eax,%eax
  800e79:	78 51                	js     800ecc <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e82:	83 ec 04             	sub    $0x4,%esp
  800e85:	68 4c 29 80 00       	push   $0x80294c
  800e8a:	6a 1d                	push   $0x1d
  800e8c:	68 c8 29 80 00       	push   $0x8029c8
  800e91:	e8 dc 13 00 00       	call   802272 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e96:	50                   	push   %eax
  800e97:	68 84 29 80 00       	push   $0x802984
  800e9c:	6a 29                	push   $0x29
  800e9e:	68 c8 29 80 00       	push   $0x8029c8
  800ea3:	e8 ca 13 00 00       	call   802272 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ea8:	50                   	push   %eax
  800ea9:	68 a8 29 80 00       	push   $0x8029a8
  800eae:	6a 2e                	push   $0x2e
  800eb0:	68 c8 29 80 00       	push   $0x8029c8
  800eb5:	e8 b8 13 00 00       	call   802272 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800eba:	50                   	push   %eax
  800ebb:	68 d3 29 80 00       	push   $0x8029d3
  800ec0:	6a 30                	push   $0x30
  800ec2:	68 c8 29 80 00       	push   $0x8029c8
  800ec7:	e8 a6 13 00 00       	call   802272 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ecc:	50                   	push   %eax
  800ecd:	68 a8 29 80 00       	push   $0x8029a8
  800ed2:	6a 32                	push   $0x32
  800ed4:	68 c8 29 80 00       	push   $0x8029c8
  800ed9:	e8 94 13 00 00       	call   802272 <_panic>

00800ede <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800ee7:	68 e0 0d 80 00       	push   $0x800de0
  800eec:	e8 c7 13 00 00       	call   8022b8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef1:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef6:	cd 30                	int    $0x30
  800ef8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	78 30                	js     800f32 <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f02:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f07:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f0b:	75 76                	jne    800f83 <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f0d:	e8 3e fc ff ff       	call   800b50 <sys_getenvid>
  800f12:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f17:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800f1d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f22:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800f27:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f32:	50                   	push   %eax
  800f33:	68 f1 29 80 00       	push   $0x8029f1
  800f38:	6a 78                	push   $0x78
  800f3a:	68 c8 29 80 00       	push   $0x8029c8
  800f3f:	e8 2e 13 00 00       	call   802272 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f44:	83 ec 0c             	sub    $0xc,%esp
  800f47:	ff 75 e4             	push   -0x1c(%ebp)
  800f4a:	57                   	push   %edi
  800f4b:	ff 75 dc             	push   -0x24(%ebp)
  800f4e:	57                   	push   %edi
  800f4f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f52:	56                   	push   %esi
  800f53:	e8 79 fc ff ff       	call   800bd1 <sys_page_map>
	if(r<0) return r;
  800f58:	83 c4 20             	add    $0x20,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	78 cb                	js     800f2a <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	ff 75 e4             	push   -0x1c(%ebp)
  800f65:	57                   	push   %edi
  800f66:	56                   	push   %esi
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	e8 63 fc ff ff       	call   800bd1 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f6e:	83 c4 20             	add    $0x20,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	78 76                	js     800feb <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f75:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f7b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f81:	74 75                	je     800ff8 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f83:	89 d8                	mov    %ebx,%eax
  800f85:	c1 e8 16             	shr    $0x16,%eax
  800f88:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f8f:	a8 01                	test   $0x1,%al
  800f91:	74 e2                	je     800f75 <fork+0x97>
  800f93:	89 de                	mov    %ebx,%esi
  800f95:	c1 ee 0c             	shr    $0xc,%esi
  800f98:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f9f:	a8 01                	test   $0x1,%al
  800fa1:	74 d2                	je     800f75 <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  800fa3:	e8 a8 fb ff ff       	call   800b50 <sys_getenvid>
  800fa8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800fab:	89 f7                	mov    %esi,%edi
  800fad:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800fb0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb7:	89 c1                	mov    %eax,%ecx
  800fb9:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800fbf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800fc2:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800fc9:	f6 c6 04             	test   $0x4,%dh
  800fcc:	0f 85 72 ff ff ff    	jne    800f44 <fork+0x66>
		perm &= ~PTE_W;
  800fd2:	25 05 0e 00 00       	and    $0xe05,%eax
  800fd7:	80 cc 08             	or     $0x8,%ah
  800fda:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800fe0:	0f 44 c1             	cmove  %ecx,%eax
  800fe3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fe6:	e9 59 ff ff ff       	jmp    800f44 <fork+0x66>
  800feb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff0:	0f 4f c2             	cmovg  %edx,%eax
  800ff3:	e9 32 ff ff ff       	jmp    800f2a <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800ff8:	83 ec 04             	sub    $0x4,%esp
  800ffb:	6a 07                	push   $0x7
  800ffd:	68 00 f0 bf ee       	push   $0xeebff000
  801002:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801005:	57                   	push   %edi
  801006:	e8 83 fb ff ff       	call   800b8e <sys_page_alloc>
	if(r<0) return r;
  80100b:	83 c4 10             	add    $0x10,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	0f 88 14 ff ff ff    	js     800f2a <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	68 2e 23 80 00       	push   $0x80232e
  80101e:	57                   	push   %edi
  80101f:	e8 b5 fc ff ff       	call   800cd9 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	0f 88 fb fe ff ff    	js     800f2a <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	6a 02                	push   $0x2
  801034:	57                   	push   %edi
  801035:	e8 1b fc ff ff       	call   800c55 <sys_env_set_status>
	if(r<0) return r;
  80103a:	83 c4 10             	add    $0x10,%esp
	return envid;
  80103d:	85 c0                	test   %eax,%eax
  80103f:	0f 49 c7             	cmovns %edi,%eax
  801042:	e9 e3 fe ff ff       	jmp    800f2a <fork+0x4c>

00801047 <sfork>:

// Challenge!
int
sfork(void)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80104d:	68 01 2a 80 00       	push   $0x802a01
  801052:	68 a1 00 00 00       	push   $0xa1
  801057:	68 c8 29 80 00       	push   $0x8029c8
  80105c:	e8 11 12 00 00       	call   802272 <_panic>

00801061 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	8b 75 08             	mov    0x8(%ebp),%esi
  801069:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80106f:	85 c0                	test   %eax,%eax
  801071:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801076:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	50                   	push   %eax
  80107d:	e8 bc fc ff ff       	call   800d3e <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	85 f6                	test   %esi,%esi
  801087:	74 17                	je     8010a0 <ipc_recv+0x3f>
  801089:	ba 00 00 00 00       	mov    $0x0,%edx
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 0c                	js     80109e <ipc_recv+0x3d>
  801092:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801098:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80109e:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8010a0:	85 db                	test   %ebx,%ebx
  8010a2:	74 17                	je     8010bb <ipc_recv+0x5a>
  8010a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 0c                	js     8010b9 <ipc_recv+0x58>
  8010ad:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010b3:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8010b9:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	78 0b                	js     8010ca <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8010bf:	a1 00 40 80 00       	mov    0x804000,%eax
  8010c4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8010ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	57                   	push   %edi
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8010e3:	85 db                	test   %ebx,%ebx
  8010e5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010ea:	0f 44 d8             	cmove  %eax,%ebx
  8010ed:	eb 05                	jmp    8010f4 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8010ef:	e8 7b fa ff ff       	call   800b6f <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8010f4:	ff 75 14             	push   0x14(%ebp)
  8010f7:	53                   	push   %ebx
  8010f8:	56                   	push   %esi
  8010f9:	57                   	push   %edi
  8010fa:	e8 1c fc ff ff       	call   800d1b <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801105:	74 e8                	je     8010ef <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801107:	85 c0                	test   %eax,%eax
  801109:	78 08                	js     801113 <ipc_send+0x42>
	}while (r<0);

}
  80110b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801113:	50                   	push   %eax
  801114:	68 17 2a 80 00       	push   $0x802a17
  801119:	6a 3d                	push   $0x3d
  80111b:	68 2b 2a 80 00       	push   $0x802a2b
  801120:	e8 4d 11 00 00       	call   802272 <_panic>

00801125 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80112b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801130:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801136:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80113c:	8b 52 60             	mov    0x60(%edx),%edx
  80113f:	39 ca                	cmp    %ecx,%edx
  801141:	74 11                	je     801154 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801143:	83 c0 01             	add    $0x1,%eax
  801146:	3d 00 04 00 00       	cmp    $0x400,%eax
  80114b:	75 e3                	jne    801130 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80114d:	b8 00 00 00 00       	mov    $0x0,%eax
  801152:	eb 0e                	jmp    801162 <ipc_find_env+0x3d>
			return envs[i].env_id;
  801154:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80115a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115f:	8b 40 58             	mov    0x58(%eax),%eax
}
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
  80116a:	05 00 00 00 30       	add    $0x30000000,%eax
  80116f:	c1 e8 0c             	shr    $0xc,%eax
}
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
  80117a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80117f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801184:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    

0080118b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801193:	89 c2                	mov    %eax,%edx
  801195:	c1 ea 16             	shr    $0x16,%edx
  801198:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119f:	f6 c2 01             	test   $0x1,%dl
  8011a2:	74 29                	je     8011cd <fd_alloc+0x42>
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 ea 0c             	shr    $0xc,%edx
  8011a9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b0:	f6 c2 01             	test   $0x1,%dl
  8011b3:	74 18                	je     8011cd <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011b5:	05 00 10 00 00       	add    $0x1000,%eax
  8011ba:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011bf:	75 d2                	jne    801193 <fd_alloc+0x8>
  8011c1:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8011c6:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8011cb:	eb 05                	jmp    8011d2 <fd_alloc+0x47>
			return 0;
  8011cd:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8011d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d5:	89 02                	mov    %eax,(%edx)
}
  8011d7:	89 c8                	mov    %ecx,%eax
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011e1:	83 f8 1f             	cmp    $0x1f,%eax
  8011e4:	77 30                	ja     801216 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e6:	c1 e0 0c             	shl    $0xc,%eax
  8011e9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ee:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8011f4:	f6 c2 01             	test   $0x1,%dl
  8011f7:	74 24                	je     80121d <fd_lookup+0x42>
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	c1 ea 0c             	shr    $0xc,%edx
  8011fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801205:	f6 c2 01             	test   $0x1,%dl
  801208:	74 1a                	je     801224 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80120a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120d:	89 02                	mov    %eax,(%edx)
	return 0;
  80120f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    
		return -E_INVAL;
  801216:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121b:	eb f7                	jmp    801214 <fd_lookup+0x39>
		return -E_INVAL;
  80121d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801222:	eb f0                	jmp    801214 <fd_lookup+0x39>
  801224:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801229:	eb e9                	jmp    801214 <fd_lookup+0x39>

0080122b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	53                   	push   %ebx
  80122f:	83 ec 04             	sub    $0x4,%esp
  801232:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801235:	b8 00 00 00 00       	mov    $0x0,%eax
  80123a:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80123f:	39 13                	cmp    %edx,(%ebx)
  801241:	74 37                	je     80127a <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801243:	83 c0 01             	add    $0x1,%eax
  801246:	8b 1c 85 b4 2a 80 00 	mov    0x802ab4(,%eax,4),%ebx
  80124d:	85 db                	test   %ebx,%ebx
  80124f:	75 ee                	jne    80123f <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801251:	a1 00 40 80 00       	mov    0x804000,%eax
  801256:	8b 40 58             	mov    0x58(%eax),%eax
  801259:	83 ec 04             	sub    $0x4,%esp
  80125c:	52                   	push   %edx
  80125d:	50                   	push   %eax
  80125e:	68 38 2a 80 00       	push   $0x802a38
  801263:	e8 50 ef ff ff       	call   8001b8 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801270:	8b 55 0c             	mov    0xc(%ebp),%edx
  801273:	89 1a                	mov    %ebx,(%edx)
}
  801275:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801278:	c9                   	leave  
  801279:	c3                   	ret    
			return 0;
  80127a:	b8 00 00 00 00       	mov    $0x0,%eax
  80127f:	eb ef                	jmp    801270 <dev_lookup+0x45>

00801281 <fd_close>:
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	57                   	push   %edi
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
  801287:	83 ec 24             	sub    $0x24,%esp
  80128a:	8b 75 08             	mov    0x8(%ebp),%esi
  80128d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801290:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801293:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801294:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80129a:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129d:	50                   	push   %eax
  80129e:	e8 38 ff ff ff       	call   8011db <fd_lookup>
  8012a3:	89 c3                	mov    %eax,%ebx
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 05                	js     8012b1 <fd_close+0x30>
	    || fd != fd2)
  8012ac:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012af:	74 16                	je     8012c7 <fd_close+0x46>
		return (must_exist ? r : 0);
  8012b1:	89 f8                	mov    %edi,%eax
  8012b3:	84 c0                	test   %al,%al
  8012b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ba:	0f 44 d8             	cmove  %eax,%ebx
}
  8012bd:	89 d8                	mov    %ebx,%eax
  8012bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5e                   	pop    %esi
  8012c4:	5f                   	pop    %edi
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	ff 36                	push   (%esi)
  8012d0:	e8 56 ff ff ff       	call   80122b <dev_lookup>
  8012d5:	89 c3                	mov    %eax,%ebx
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 1a                	js     8012f8 <fd_close+0x77>
		if (dev->dev_close)
  8012de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e1:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012e4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	74 0b                	je     8012f8 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	56                   	push   %esi
  8012f1:	ff d0                	call   *%eax
  8012f3:	89 c3                	mov    %eax,%ebx
  8012f5:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	56                   	push   %esi
  8012fc:	6a 00                	push   $0x0
  8012fe:	e8 10 f9 ff ff       	call   800c13 <sys_page_unmap>
	return r;
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	eb b5                	jmp    8012bd <fd_close+0x3c>

00801308 <close>:

int
close(int fdnum)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80130e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	ff 75 08             	push   0x8(%ebp)
  801315:	e8 c1 fe ff ff       	call   8011db <fd_lookup>
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	79 02                	jns    801323 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801321:	c9                   	leave  
  801322:	c3                   	ret    
		return fd_close(fd, 1);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	6a 01                	push   $0x1
  801328:	ff 75 f4             	push   -0xc(%ebp)
  80132b:	e8 51 ff ff ff       	call   801281 <fd_close>
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	eb ec                	jmp    801321 <close+0x19>

00801335 <close_all>:

void
close_all(void)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	53                   	push   %ebx
  801339:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80133c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801341:	83 ec 0c             	sub    $0xc,%esp
  801344:	53                   	push   %ebx
  801345:	e8 be ff ff ff       	call   801308 <close>
	for (i = 0; i < MAXFD; i++)
  80134a:	83 c3 01             	add    $0x1,%ebx
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	83 fb 20             	cmp    $0x20,%ebx
  801353:	75 ec                	jne    801341 <close_all+0xc>
}
  801355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	57                   	push   %edi
  80135e:	56                   	push   %esi
  80135f:	53                   	push   %ebx
  801360:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801363:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801366:	50                   	push   %eax
  801367:	ff 75 08             	push   0x8(%ebp)
  80136a:	e8 6c fe ff ff       	call   8011db <fd_lookup>
  80136f:	89 c3                	mov    %eax,%ebx
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 7f                	js     8013f7 <dup+0x9d>
		return r;
	close(newfdnum);
  801378:	83 ec 0c             	sub    $0xc,%esp
  80137b:	ff 75 0c             	push   0xc(%ebp)
  80137e:	e8 85 ff ff ff       	call   801308 <close>

	newfd = INDEX2FD(newfdnum);
  801383:	8b 75 0c             	mov    0xc(%ebp),%esi
  801386:	c1 e6 0c             	shl    $0xc,%esi
  801389:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80138f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801392:	89 3c 24             	mov    %edi,(%esp)
  801395:	e8 da fd ff ff       	call   801174 <fd2data>
  80139a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80139c:	89 34 24             	mov    %esi,(%esp)
  80139f:	e8 d0 fd ff ff       	call   801174 <fd2data>
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013aa:	89 d8                	mov    %ebx,%eax
  8013ac:	c1 e8 16             	shr    $0x16,%eax
  8013af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013b6:	a8 01                	test   $0x1,%al
  8013b8:	74 11                	je     8013cb <dup+0x71>
  8013ba:	89 d8                	mov    %ebx,%eax
  8013bc:	c1 e8 0c             	shr    $0xc,%eax
  8013bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c6:	f6 c2 01             	test   $0x1,%dl
  8013c9:	75 36                	jne    801401 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013cb:	89 f8                	mov    %edi,%eax
  8013cd:	c1 e8 0c             	shr    $0xc,%eax
  8013d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d7:	83 ec 0c             	sub    $0xc,%esp
  8013da:	25 07 0e 00 00       	and    $0xe07,%eax
  8013df:	50                   	push   %eax
  8013e0:	56                   	push   %esi
  8013e1:	6a 00                	push   $0x0
  8013e3:	57                   	push   %edi
  8013e4:	6a 00                	push   $0x0
  8013e6:	e8 e6 f7 ff ff       	call   800bd1 <sys_page_map>
  8013eb:	89 c3                	mov    %eax,%ebx
  8013ed:	83 c4 20             	add    $0x20,%esp
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 33                	js     801427 <dup+0xcd>
		goto err;

	return newfdnum;
  8013f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013f7:	89 d8                	mov    %ebx,%eax
  8013f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013fc:	5b                   	pop    %ebx
  8013fd:	5e                   	pop    %esi
  8013fe:	5f                   	pop    %edi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801401:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801408:	83 ec 0c             	sub    $0xc,%esp
  80140b:	25 07 0e 00 00       	and    $0xe07,%eax
  801410:	50                   	push   %eax
  801411:	ff 75 d4             	push   -0x2c(%ebp)
  801414:	6a 00                	push   $0x0
  801416:	53                   	push   %ebx
  801417:	6a 00                	push   $0x0
  801419:	e8 b3 f7 ff ff       	call   800bd1 <sys_page_map>
  80141e:	89 c3                	mov    %eax,%ebx
  801420:	83 c4 20             	add    $0x20,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	79 a4                	jns    8013cb <dup+0x71>
	sys_page_unmap(0, newfd);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	56                   	push   %esi
  80142b:	6a 00                	push   $0x0
  80142d:	e8 e1 f7 ff ff       	call   800c13 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801432:	83 c4 08             	add    $0x8,%esp
  801435:	ff 75 d4             	push   -0x2c(%ebp)
  801438:	6a 00                	push   $0x0
  80143a:	e8 d4 f7 ff ff       	call   800c13 <sys_page_unmap>
	return r;
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	eb b3                	jmp    8013f7 <dup+0x9d>

00801444 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	83 ec 18             	sub    $0x18,%esp
  80144c:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801452:	50                   	push   %eax
  801453:	56                   	push   %esi
  801454:	e8 82 fd ff ff       	call   8011db <fd_lookup>
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 3c                	js     80149c <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801460:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	ff 33                	push   (%ebx)
  80146c:	e8 ba fd ff ff       	call   80122b <dev_lookup>
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	85 c0                	test   %eax,%eax
  801476:	78 24                	js     80149c <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801478:	8b 43 08             	mov    0x8(%ebx),%eax
  80147b:	83 e0 03             	and    $0x3,%eax
  80147e:	83 f8 01             	cmp    $0x1,%eax
  801481:	74 20                	je     8014a3 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801483:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801486:	8b 40 08             	mov    0x8(%eax),%eax
  801489:	85 c0                	test   %eax,%eax
  80148b:	74 37                	je     8014c4 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80148d:	83 ec 04             	sub    $0x4,%esp
  801490:	ff 75 10             	push   0x10(%ebp)
  801493:	ff 75 0c             	push   0xc(%ebp)
  801496:	53                   	push   %ebx
  801497:	ff d0                	call   *%eax
  801499:	83 c4 10             	add    $0x10,%esp
}
  80149c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a3:	a1 00 40 80 00       	mov    0x804000,%eax
  8014a8:	8b 40 58             	mov    0x58(%eax),%eax
  8014ab:	83 ec 04             	sub    $0x4,%esp
  8014ae:	56                   	push   %esi
  8014af:	50                   	push   %eax
  8014b0:	68 79 2a 80 00       	push   $0x802a79
  8014b5:	e8 fe ec ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c2:	eb d8                	jmp    80149c <read+0x58>
		return -E_NOT_SUPP;
  8014c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014c9:	eb d1                	jmp    80149c <read+0x58>

008014cb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	57                   	push   %edi
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
  8014d1:	83 ec 0c             	sub    $0xc,%esp
  8014d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014d7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014df:	eb 02                	jmp    8014e3 <readn+0x18>
  8014e1:	01 c3                	add    %eax,%ebx
  8014e3:	39 f3                	cmp    %esi,%ebx
  8014e5:	73 21                	jae    801508 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e7:	83 ec 04             	sub    $0x4,%esp
  8014ea:	89 f0                	mov    %esi,%eax
  8014ec:	29 d8                	sub    %ebx,%eax
  8014ee:	50                   	push   %eax
  8014ef:	89 d8                	mov    %ebx,%eax
  8014f1:	03 45 0c             	add    0xc(%ebp),%eax
  8014f4:	50                   	push   %eax
  8014f5:	57                   	push   %edi
  8014f6:	e8 49 ff ff ff       	call   801444 <read>
		if (m < 0)
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 04                	js     801506 <readn+0x3b>
			return m;
		if (m == 0)
  801502:	75 dd                	jne    8014e1 <readn+0x16>
  801504:	eb 02                	jmp    801508 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801506:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150d:	5b                   	pop    %ebx
  80150e:	5e                   	pop    %esi
  80150f:	5f                   	pop    %edi
  801510:	5d                   	pop    %ebp
  801511:	c3                   	ret    

00801512 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	56                   	push   %esi
  801516:	53                   	push   %ebx
  801517:	83 ec 18             	sub    $0x18,%esp
  80151a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801520:	50                   	push   %eax
  801521:	53                   	push   %ebx
  801522:	e8 b4 fc ff ff       	call   8011db <fd_lookup>
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 37                	js     801565 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801537:	50                   	push   %eax
  801538:	ff 36                	push   (%esi)
  80153a:	e8 ec fc ff ff       	call   80122b <dev_lookup>
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 1f                	js     801565 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801546:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80154a:	74 20                	je     80156c <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154f:	8b 40 0c             	mov    0xc(%eax),%eax
  801552:	85 c0                	test   %eax,%eax
  801554:	74 37                	je     80158d <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801556:	83 ec 04             	sub    $0x4,%esp
  801559:	ff 75 10             	push   0x10(%ebp)
  80155c:	ff 75 0c             	push   0xc(%ebp)
  80155f:	56                   	push   %esi
  801560:	ff d0                	call   *%eax
  801562:	83 c4 10             	add    $0x10,%esp
}
  801565:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801568:	5b                   	pop    %ebx
  801569:	5e                   	pop    %esi
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156c:	a1 00 40 80 00       	mov    0x804000,%eax
  801571:	8b 40 58             	mov    0x58(%eax),%eax
  801574:	83 ec 04             	sub    $0x4,%esp
  801577:	53                   	push   %ebx
  801578:	50                   	push   %eax
  801579:	68 95 2a 80 00       	push   $0x802a95
  80157e:	e8 35 ec ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158b:	eb d8                	jmp    801565 <write+0x53>
		return -E_NOT_SUPP;
  80158d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801592:	eb d1                	jmp    801565 <write+0x53>

00801594 <seek>:

int
seek(int fdnum, off_t offset)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	ff 75 08             	push   0x8(%ebp)
  8015a1:	e8 35 fc ff ff       	call   8011db <fd_lookup>
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 0e                	js     8015bb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	56                   	push   %esi
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 18             	sub    $0x18,%esp
  8015c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	53                   	push   %ebx
  8015cd:	e8 09 fc ff ff       	call   8011db <fd_lookup>
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 34                	js     80160d <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015dc:	83 ec 08             	sub    $0x8,%esp
  8015df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	ff 36                	push   (%esi)
  8015e5:	e8 41 fc ff ff       	call   80122b <dev_lookup>
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 1c                	js     80160d <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f1:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015f5:	74 1d                	je     801614 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fa:	8b 40 18             	mov    0x18(%eax),%eax
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	74 34                	je     801635 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	ff 75 0c             	push   0xc(%ebp)
  801607:	56                   	push   %esi
  801608:	ff d0                	call   *%eax
  80160a:	83 c4 10             	add    $0x10,%esp
}
  80160d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    
			thisenv->env_id, fdnum);
  801614:	a1 00 40 80 00       	mov    0x804000,%eax
  801619:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161c:	83 ec 04             	sub    $0x4,%esp
  80161f:	53                   	push   %ebx
  801620:	50                   	push   %eax
  801621:	68 58 2a 80 00       	push   $0x802a58
  801626:	e8 8d eb ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801633:	eb d8                	jmp    80160d <ftruncate+0x50>
		return -E_NOT_SUPP;
  801635:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80163a:	eb d1                	jmp    80160d <ftruncate+0x50>

0080163c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	56                   	push   %esi
  801640:	53                   	push   %ebx
  801641:	83 ec 18             	sub    $0x18,%esp
  801644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801647:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	ff 75 08             	push   0x8(%ebp)
  80164e:	e8 88 fb ff ff       	call   8011db <fd_lookup>
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 49                	js     8016a3 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	ff 36                	push   (%esi)
  801666:	e8 c0 fb ff ff       	call   80122b <dev_lookup>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 31                	js     8016a3 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801675:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801679:	74 2f                	je     8016aa <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80167b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80167e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801685:	00 00 00 
	stat->st_isdir = 0;
  801688:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80168f:	00 00 00 
	stat->st_dev = dev;
  801692:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801698:	83 ec 08             	sub    $0x8,%esp
  80169b:	53                   	push   %ebx
  80169c:	56                   	push   %esi
  80169d:	ff 50 14             	call   *0x14(%eax)
  8016a0:	83 c4 10             	add    $0x10,%esp
}
  8016a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    
		return -E_NOT_SUPP;
  8016aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016af:	eb f2                	jmp    8016a3 <fstat+0x67>

008016b1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	56                   	push   %esi
  8016b5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b6:	83 ec 08             	sub    $0x8,%esp
  8016b9:	6a 00                	push   $0x0
  8016bb:	ff 75 08             	push   0x8(%ebp)
  8016be:	e8 e4 01 00 00       	call   8018a7 <open>
  8016c3:	89 c3                	mov    %eax,%ebx
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 1b                	js     8016e7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016cc:	83 ec 08             	sub    $0x8,%esp
  8016cf:	ff 75 0c             	push   0xc(%ebp)
  8016d2:	50                   	push   %eax
  8016d3:	e8 64 ff ff ff       	call   80163c <fstat>
  8016d8:	89 c6                	mov    %eax,%esi
	close(fd);
  8016da:	89 1c 24             	mov    %ebx,(%esp)
  8016dd:	e8 26 fc ff ff       	call   801308 <close>
	return r;
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	89 f3                	mov    %esi,%ebx
}
  8016e7:	89 d8                	mov    %ebx,%eax
  8016e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ec:	5b                   	pop    %ebx
  8016ed:	5e                   	pop    %esi
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	89 c6                	mov    %eax,%esi
  8016f7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801700:	74 27                	je     801729 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801702:	6a 07                	push   $0x7
  801704:	68 00 50 80 00       	push   $0x805000
  801709:	56                   	push   %esi
  80170a:	ff 35 00 60 80 00    	push   0x806000
  801710:	e8 bc f9 ff ff       	call   8010d1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801715:	83 c4 0c             	add    $0xc,%esp
  801718:	6a 00                	push   $0x0
  80171a:	53                   	push   %ebx
  80171b:	6a 00                	push   $0x0
  80171d:	e8 3f f9 ff ff       	call   801061 <ipc_recv>
}
  801722:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801725:	5b                   	pop    %ebx
  801726:	5e                   	pop    %esi
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801729:	83 ec 0c             	sub    $0xc,%esp
  80172c:	6a 01                	push   $0x1
  80172e:	e8 f2 f9 ff ff       	call   801125 <ipc_find_env>
  801733:	a3 00 60 80 00       	mov    %eax,0x806000
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	eb c5                	jmp    801702 <fsipc+0x12>

0080173d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	8b 40 0c             	mov    0xc(%eax),%eax
  801749:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80174e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801751:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801756:	ba 00 00 00 00       	mov    $0x0,%edx
  80175b:	b8 02 00 00 00       	mov    $0x2,%eax
  801760:	e8 8b ff ff ff       	call   8016f0 <fsipc>
}
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <devfile_flush>:
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80176d:	8b 45 08             	mov    0x8(%ebp),%eax
  801770:	8b 40 0c             	mov    0xc(%eax),%eax
  801773:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801778:	ba 00 00 00 00       	mov    $0x0,%edx
  80177d:	b8 06 00 00 00       	mov    $0x6,%eax
  801782:	e8 69 ff ff ff       	call   8016f0 <fsipc>
}
  801787:	c9                   	leave  
  801788:	c3                   	ret    

00801789 <devfile_stat>:
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	53                   	push   %ebx
  80178d:	83 ec 04             	sub    $0x4,%esp
  801790:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	8b 40 0c             	mov    0xc(%eax),%eax
  801799:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80179e:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a3:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a8:	e8 43 ff ff ff       	call   8016f0 <fsipc>
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 2c                	js     8017dd <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	68 00 50 80 00       	push   $0x805000
  8017b9:	53                   	push   %ebx
  8017ba:	e8 d3 ef ff ff       	call   800792 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017bf:	a1 80 50 80 00       	mov    0x805080,%eax
  8017c4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017ca:	a1 84 50 80 00       	mov    0x805084,%eax
  8017cf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <devfile_write>:
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	83 ec 0c             	sub    $0xc,%esp
  8017e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8017eb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017f0:	39 d0                	cmp    %edx,%eax
  8017f2:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801801:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801806:	50                   	push   %eax
  801807:	ff 75 0c             	push   0xc(%ebp)
  80180a:	68 08 50 80 00       	push   $0x805008
  80180f:	e8 14 f1 ff ff       	call   800928 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	b8 04 00 00 00       	mov    $0x4,%eax
  80181e:	e8 cd fe ff ff       	call   8016f0 <fsipc>
}
  801823:	c9                   	leave  
  801824:	c3                   	ret    

00801825 <devfile_read>:
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	8b 40 0c             	mov    0xc(%eax),%eax
  801833:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801838:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183e:	ba 00 00 00 00       	mov    $0x0,%edx
  801843:	b8 03 00 00 00       	mov    $0x3,%eax
  801848:	e8 a3 fe ff ff       	call   8016f0 <fsipc>
  80184d:	89 c3                	mov    %eax,%ebx
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 1f                	js     801872 <devfile_read+0x4d>
	assert(r <= n);
  801853:	39 f0                	cmp    %esi,%eax
  801855:	77 24                	ja     80187b <devfile_read+0x56>
	assert(r <= PGSIZE);
  801857:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80185c:	7f 33                	jg     801891 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80185e:	83 ec 04             	sub    $0x4,%esp
  801861:	50                   	push   %eax
  801862:	68 00 50 80 00       	push   $0x805000
  801867:	ff 75 0c             	push   0xc(%ebp)
  80186a:	e8 b9 f0 ff ff       	call   800928 <memmove>
	return r;
  80186f:	83 c4 10             	add    $0x10,%esp
}
  801872:	89 d8                	mov    %ebx,%eax
  801874:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801877:	5b                   	pop    %ebx
  801878:	5e                   	pop    %esi
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    
	assert(r <= n);
  80187b:	68 c8 2a 80 00       	push   $0x802ac8
  801880:	68 cf 2a 80 00       	push   $0x802acf
  801885:	6a 7c                	push   $0x7c
  801887:	68 e4 2a 80 00       	push   $0x802ae4
  80188c:	e8 e1 09 00 00       	call   802272 <_panic>
	assert(r <= PGSIZE);
  801891:	68 ef 2a 80 00       	push   $0x802aef
  801896:	68 cf 2a 80 00       	push   $0x802acf
  80189b:	6a 7d                	push   $0x7d
  80189d:	68 e4 2a 80 00       	push   $0x802ae4
  8018a2:	e8 cb 09 00 00       	call   802272 <_panic>

008018a7 <open>:
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	56                   	push   %esi
  8018ab:	53                   	push   %ebx
  8018ac:	83 ec 1c             	sub    $0x1c,%esp
  8018af:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018b2:	56                   	push   %esi
  8018b3:	e8 9f ee ff ff       	call   800757 <strlen>
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c0:	7f 6c                	jg     80192e <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018c2:	83 ec 0c             	sub    $0xc,%esp
  8018c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c8:	50                   	push   %eax
  8018c9:	e8 bd f8 ff ff       	call   80118b <fd_alloc>
  8018ce:	89 c3                	mov    %eax,%ebx
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 3c                	js     801913 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	56                   	push   %esi
  8018db:	68 00 50 80 00       	push   $0x805000
  8018e0:	e8 ad ee ff ff       	call   800792 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e8:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f5:	e8 f6 fd ff ff       	call   8016f0 <fsipc>
  8018fa:	89 c3                	mov    %eax,%ebx
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	85 c0                	test   %eax,%eax
  801901:	78 19                	js     80191c <open+0x75>
	return fd2num(fd);
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	ff 75 f4             	push   -0xc(%ebp)
  801909:	e8 56 f8 ff ff       	call   801164 <fd2num>
  80190e:	89 c3                	mov    %eax,%ebx
  801910:	83 c4 10             	add    $0x10,%esp
}
  801913:	89 d8                	mov    %ebx,%eax
  801915:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    
		fd_close(fd, 0);
  80191c:	83 ec 08             	sub    $0x8,%esp
  80191f:	6a 00                	push   $0x0
  801921:	ff 75 f4             	push   -0xc(%ebp)
  801924:	e8 58 f9 ff ff       	call   801281 <fd_close>
		return r;
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	eb e5                	jmp    801913 <open+0x6c>
		return -E_BAD_PATH;
  80192e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801933:	eb de                	jmp    801913 <open+0x6c>

00801935 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80193b:	ba 00 00 00 00       	mov    $0x0,%edx
  801940:	b8 08 00 00 00       	mov    $0x8,%eax
  801945:	e8 a6 fd ff ff       	call   8016f0 <fsipc>
}
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801952:	68 fb 2a 80 00       	push   $0x802afb
  801957:	ff 75 0c             	push   0xc(%ebp)
  80195a:	e8 33 ee ff ff       	call   800792 <strcpy>
	return 0;
}
  80195f:	b8 00 00 00 00       	mov    $0x0,%eax
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <devsock_close>:
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	53                   	push   %ebx
  80196a:	83 ec 10             	sub    $0x10,%esp
  80196d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801970:	53                   	push   %ebx
  801971:	e8 de 09 00 00       	call   802354 <pageref>
  801976:	89 c2                	mov    %eax,%edx
  801978:	83 c4 10             	add    $0x10,%esp
		return 0;
  80197b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801980:	83 fa 01             	cmp    $0x1,%edx
  801983:	74 05                	je     80198a <devsock_close+0x24>
}
  801985:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801988:	c9                   	leave  
  801989:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80198a:	83 ec 0c             	sub    $0xc,%esp
  80198d:	ff 73 0c             	push   0xc(%ebx)
  801990:	e8 b7 02 00 00       	call   801c4c <nsipc_close>
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	eb eb                	jmp    801985 <devsock_close+0x1f>

0080199a <devsock_write>:
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019a0:	6a 00                	push   $0x0
  8019a2:	ff 75 10             	push   0x10(%ebp)
  8019a5:	ff 75 0c             	push   0xc(%ebp)
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	ff 70 0c             	push   0xc(%eax)
  8019ae:	e8 79 03 00 00       	call   801d2c <nsipc_send>
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <devsock_read>:
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019bb:	6a 00                	push   $0x0
  8019bd:	ff 75 10             	push   0x10(%ebp)
  8019c0:	ff 75 0c             	push   0xc(%ebp)
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	ff 70 0c             	push   0xc(%eax)
  8019c9:	e8 ef 02 00 00       	call   801cbd <nsipc_recv>
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <fd2sockid>:
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019d6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019d9:	52                   	push   %edx
  8019da:	50                   	push   %eax
  8019db:	e8 fb f7 ff ff       	call   8011db <fd_lookup>
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 10                	js     8019f7 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ea:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019f0:	39 08                	cmp    %ecx,(%eax)
  8019f2:	75 05                	jne    8019f9 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8019f4:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    
		return -E_NOT_SUPP;
  8019f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019fe:	eb f7                	jmp    8019f7 <fd2sockid+0x27>

00801a00 <alloc_sockfd>:
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	83 ec 1c             	sub    $0x1c,%esp
  801a08:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0d:	50                   	push   %eax
  801a0e:	e8 78 f7 ff ff       	call   80118b <fd_alloc>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	78 43                	js     801a5f <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a1c:	83 ec 04             	sub    $0x4,%esp
  801a1f:	68 07 04 00 00       	push   $0x407
  801a24:	ff 75 f4             	push   -0xc(%ebp)
  801a27:	6a 00                	push   $0x0
  801a29:	e8 60 f1 ff ff       	call   800b8e <sys_page_alloc>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 28                	js     801a5f <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a40:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a45:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a4c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	50                   	push   %eax
  801a53:	e8 0c f7 ff ff       	call   801164 <fd2num>
  801a58:	89 c3                	mov    %eax,%ebx
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	eb 0c                	jmp    801a6b <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	56                   	push   %esi
  801a63:	e8 e4 01 00 00       	call   801c4c <nsipc_close>
		return r;
  801a68:	83 c4 10             	add    $0x10,%esp
}
  801a6b:	89 d8                	mov    %ebx,%eax
  801a6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a70:	5b                   	pop    %ebx
  801a71:	5e                   	pop    %esi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <accept>:
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7d:	e8 4e ff ff ff       	call   8019d0 <fd2sockid>
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 1b                	js     801aa1 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a86:	83 ec 04             	sub    $0x4,%esp
  801a89:	ff 75 10             	push   0x10(%ebp)
  801a8c:	ff 75 0c             	push   0xc(%ebp)
  801a8f:	50                   	push   %eax
  801a90:	e8 0e 01 00 00       	call   801ba3 <nsipc_accept>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 05                	js     801aa1 <accept+0x2d>
	return alloc_sockfd(r);
  801a9c:	e8 5f ff ff ff       	call   801a00 <alloc_sockfd>
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <bind>:
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aac:	e8 1f ff ff ff       	call   8019d0 <fd2sockid>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 12                	js     801ac7 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801ab5:	83 ec 04             	sub    $0x4,%esp
  801ab8:	ff 75 10             	push   0x10(%ebp)
  801abb:	ff 75 0c             	push   0xc(%ebp)
  801abe:	50                   	push   %eax
  801abf:	e8 31 01 00 00       	call   801bf5 <nsipc_bind>
  801ac4:	83 c4 10             	add    $0x10,%esp
}
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <shutdown>:
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	e8 f9 fe ff ff       	call   8019d0 <fd2sockid>
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	78 0f                	js     801aea <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801adb:	83 ec 08             	sub    $0x8,%esp
  801ade:	ff 75 0c             	push   0xc(%ebp)
  801ae1:	50                   	push   %eax
  801ae2:	e8 43 01 00 00       	call   801c2a <nsipc_shutdown>
  801ae7:	83 c4 10             	add    $0x10,%esp
}
  801aea:	c9                   	leave  
  801aeb:	c3                   	ret    

00801aec <connect>:
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801af2:	8b 45 08             	mov    0x8(%ebp),%eax
  801af5:	e8 d6 fe ff ff       	call   8019d0 <fd2sockid>
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 12                	js     801b10 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801afe:	83 ec 04             	sub    $0x4,%esp
  801b01:	ff 75 10             	push   0x10(%ebp)
  801b04:	ff 75 0c             	push   0xc(%ebp)
  801b07:	50                   	push   %eax
  801b08:	e8 59 01 00 00       	call   801c66 <nsipc_connect>
  801b0d:	83 c4 10             	add    $0x10,%esp
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <listen>:
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	e8 b0 fe ff ff       	call   8019d0 <fd2sockid>
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 0f                	js     801b33 <listen+0x21>
	return nsipc_listen(r, backlog);
  801b24:	83 ec 08             	sub    $0x8,%esp
  801b27:	ff 75 0c             	push   0xc(%ebp)
  801b2a:	50                   	push   %eax
  801b2b:	e8 6b 01 00 00       	call   801c9b <nsipc_listen>
  801b30:	83 c4 10             	add    $0x10,%esp
}
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <socket>:

int
socket(int domain, int type, int protocol)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b3b:	ff 75 10             	push   0x10(%ebp)
  801b3e:	ff 75 0c             	push   0xc(%ebp)
  801b41:	ff 75 08             	push   0x8(%ebp)
  801b44:	e8 41 02 00 00       	call   801d8a <nsipc_socket>
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	78 05                	js     801b55 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b50:	e8 ab fe ff ff       	call   801a00 <alloc_sockfd>
}
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    

00801b57 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	53                   	push   %ebx
  801b5b:	83 ec 04             	sub    $0x4,%esp
  801b5e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b60:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801b67:	74 26                	je     801b8f <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b69:	6a 07                	push   $0x7
  801b6b:	68 00 70 80 00       	push   $0x807000
  801b70:	53                   	push   %ebx
  801b71:	ff 35 00 80 80 00    	push   0x808000
  801b77:	e8 55 f5 ff ff       	call   8010d1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b7c:	83 c4 0c             	add    $0xc,%esp
  801b7f:	6a 00                	push   $0x0
  801b81:	6a 00                	push   $0x0
  801b83:	6a 00                	push   $0x0
  801b85:	e8 d7 f4 ff ff       	call   801061 <ipc_recv>
}
  801b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	6a 02                	push   $0x2
  801b94:	e8 8c f5 ff ff       	call   801125 <ipc_find_env>
  801b99:	a3 00 80 80 00       	mov    %eax,0x808000
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	eb c6                	jmp    801b69 <nsipc+0x12>

00801ba3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bb3:	8b 06                	mov    (%esi),%eax
  801bb5:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bba:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbf:	e8 93 ff ff ff       	call   801b57 <nsipc>
  801bc4:	89 c3                	mov    %eax,%ebx
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	79 09                	jns    801bd3 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801bca:	89 d8                	mov    %ebx,%eax
  801bcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bd3:	83 ec 04             	sub    $0x4,%esp
  801bd6:	ff 35 10 70 80 00    	push   0x807010
  801bdc:	68 00 70 80 00       	push   $0x807000
  801be1:	ff 75 0c             	push   0xc(%ebp)
  801be4:	e8 3f ed ff ff       	call   800928 <memmove>
		*addrlen = ret->ret_addrlen;
  801be9:	a1 10 70 80 00       	mov    0x807010,%eax
  801bee:	89 06                	mov    %eax,(%esi)
  801bf0:	83 c4 10             	add    $0x10,%esp
	return r;
  801bf3:	eb d5                	jmp    801bca <nsipc_accept+0x27>

00801bf5 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	53                   	push   %ebx
  801bf9:	83 ec 08             	sub    $0x8,%esp
  801bfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bff:	8b 45 08             	mov    0x8(%ebp),%eax
  801c02:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c07:	53                   	push   %ebx
  801c08:	ff 75 0c             	push   0xc(%ebp)
  801c0b:	68 04 70 80 00       	push   $0x807004
  801c10:	e8 13 ed ff ff       	call   800928 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c15:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c1b:	b8 02 00 00 00       	mov    $0x2,%eax
  801c20:	e8 32 ff ff ff       	call   801b57 <nsipc>
}
  801c25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    

00801c2a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c30:	8b 45 08             	mov    0x8(%ebp),%eax
  801c33:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801c40:	b8 03 00 00 00       	mov    $0x3,%eax
  801c45:	e8 0d ff ff ff       	call   801b57 <nsipc>
}
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <nsipc_close>:

int
nsipc_close(int s)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c52:	8b 45 08             	mov    0x8(%ebp),%eax
  801c55:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801c5a:	b8 04 00 00 00       	mov    $0x4,%eax
  801c5f:	e8 f3 fe ff ff       	call   801b57 <nsipc>
}
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    

00801c66 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	53                   	push   %ebx
  801c6a:	83 ec 08             	sub    $0x8,%esp
  801c6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c70:	8b 45 08             	mov    0x8(%ebp),%eax
  801c73:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c78:	53                   	push   %ebx
  801c79:	ff 75 0c             	push   0xc(%ebp)
  801c7c:	68 04 70 80 00       	push   $0x807004
  801c81:	e8 a2 ec ff ff       	call   800928 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c86:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801c8c:	b8 05 00 00 00       	mov    $0x5,%eax
  801c91:	e8 c1 fe ff ff       	call   801b57 <nsipc>
}
  801c96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cac:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801cb1:	b8 06 00 00 00       	mov    $0x6,%eax
  801cb6:	e8 9c fe ff ff       	call   801b57 <nsipc>
}
  801cbb:	c9                   	leave  
  801cbc:	c3                   	ret    

00801cbd <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	56                   	push   %esi
  801cc1:	53                   	push   %ebx
  801cc2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801ccd:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801cd3:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd6:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cdb:	b8 07 00 00 00       	mov    $0x7,%eax
  801ce0:	e8 72 fe ff ff       	call   801b57 <nsipc>
  801ce5:	89 c3                	mov    %eax,%ebx
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	78 22                	js     801d0d <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801ceb:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801cf0:	39 c6                	cmp    %eax,%esi
  801cf2:	0f 4e c6             	cmovle %esi,%eax
  801cf5:	39 c3                	cmp    %eax,%ebx
  801cf7:	7f 1d                	jg     801d16 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cf9:	83 ec 04             	sub    $0x4,%esp
  801cfc:	53                   	push   %ebx
  801cfd:	68 00 70 80 00       	push   $0x807000
  801d02:	ff 75 0c             	push   0xc(%ebp)
  801d05:	e8 1e ec ff ff       	call   800928 <memmove>
  801d0a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d0d:	89 d8                	mov    %ebx,%eax
  801d0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d12:	5b                   	pop    %ebx
  801d13:	5e                   	pop    %esi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d16:	68 07 2b 80 00       	push   $0x802b07
  801d1b:	68 cf 2a 80 00       	push   $0x802acf
  801d20:	6a 62                	push   $0x62
  801d22:	68 1c 2b 80 00       	push   $0x802b1c
  801d27:	e8 46 05 00 00       	call   802272 <_panic>

00801d2c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	53                   	push   %ebx
  801d30:	83 ec 04             	sub    $0x4,%esp
  801d33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d36:	8b 45 08             	mov    0x8(%ebp),%eax
  801d39:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801d3e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d44:	7f 2e                	jg     801d74 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d46:	83 ec 04             	sub    $0x4,%esp
  801d49:	53                   	push   %ebx
  801d4a:	ff 75 0c             	push   0xc(%ebp)
  801d4d:	68 0c 70 80 00       	push   $0x80700c
  801d52:	e8 d1 eb ff ff       	call   800928 <memmove>
	nsipcbuf.send.req_size = size;
  801d57:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801d5d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d60:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801d65:	b8 08 00 00 00       	mov    $0x8,%eax
  801d6a:	e8 e8 fd ff ff       	call   801b57 <nsipc>
}
  801d6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    
	assert(size < 1600);
  801d74:	68 28 2b 80 00       	push   $0x802b28
  801d79:	68 cf 2a 80 00       	push   $0x802acf
  801d7e:	6a 6d                	push   $0x6d
  801d80:	68 1c 2b 80 00       	push   $0x802b1c
  801d85:	e8 e8 04 00 00       	call   802272 <_panic>

00801d8a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
  801d93:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801d98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9b:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801da0:	8b 45 10             	mov    0x10(%ebp),%eax
  801da3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801da8:	b8 09 00 00 00       	mov    $0x9,%eax
  801dad:	e8 a5 fd ff ff       	call   801b57 <nsipc>
}
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	56                   	push   %esi
  801db8:	53                   	push   %ebx
  801db9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	ff 75 08             	push   0x8(%ebp)
  801dc2:	e8 ad f3 ff ff       	call   801174 <fd2data>
  801dc7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801dc9:	83 c4 08             	add    $0x8,%esp
  801dcc:	68 34 2b 80 00       	push   $0x802b34
  801dd1:	53                   	push   %ebx
  801dd2:	e8 bb e9 ff ff       	call   800792 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dd7:	8b 46 04             	mov    0x4(%esi),%eax
  801dda:	2b 06                	sub    (%esi),%eax
  801ddc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801de2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801de9:	00 00 00 
	stat->st_dev = &devpipe;
  801dec:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801df3:	30 80 00 
	return 0;
}
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	53                   	push   %ebx
  801e06:	83 ec 0c             	sub    $0xc,%esp
  801e09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e0c:	53                   	push   %ebx
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 ff ed ff ff       	call   800c13 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e14:	89 1c 24             	mov    %ebx,(%esp)
  801e17:	e8 58 f3 ff ff       	call   801174 <fd2data>
  801e1c:	83 c4 08             	add    $0x8,%esp
  801e1f:	50                   	push   %eax
  801e20:	6a 00                	push   $0x0
  801e22:	e8 ec ed ff ff       	call   800c13 <sys_page_unmap>
}
  801e27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <_pipeisclosed>:
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	57                   	push   %edi
  801e30:	56                   	push   %esi
  801e31:	53                   	push   %ebx
  801e32:	83 ec 1c             	sub    $0x1c,%esp
  801e35:	89 c7                	mov    %eax,%edi
  801e37:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e39:	a1 00 40 80 00       	mov    0x804000,%eax
  801e3e:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	57                   	push   %edi
  801e45:	e8 0a 05 00 00       	call   802354 <pageref>
  801e4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e4d:	89 34 24             	mov    %esi,(%esp)
  801e50:	e8 ff 04 00 00       	call   802354 <pageref>
		nn = thisenv->env_runs;
  801e55:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801e5b:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	39 cb                	cmp    %ecx,%ebx
  801e63:	74 1b                	je     801e80 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801e65:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e68:	75 cf                	jne    801e39 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e6a:	8b 42 68             	mov    0x68(%edx),%eax
  801e6d:	6a 01                	push   $0x1
  801e6f:	50                   	push   %eax
  801e70:	53                   	push   %ebx
  801e71:	68 3b 2b 80 00       	push   $0x802b3b
  801e76:	e8 3d e3 ff ff       	call   8001b8 <cprintf>
  801e7b:	83 c4 10             	add    $0x10,%esp
  801e7e:	eb b9                	jmp    801e39 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801e80:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e83:	0f 94 c0             	sete   %al
  801e86:	0f b6 c0             	movzbl %al,%eax
}
  801e89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8c:	5b                   	pop    %ebx
  801e8d:	5e                   	pop    %esi
  801e8e:	5f                   	pop    %edi
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <devpipe_write>:
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	57                   	push   %edi
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	83 ec 28             	sub    $0x28,%esp
  801e9a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e9d:	56                   	push   %esi
  801e9e:	e8 d1 f2 ff ff       	call   801174 <fd2data>
  801ea3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	bf 00 00 00 00       	mov    $0x0,%edi
  801ead:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801eb0:	75 09                	jne    801ebb <devpipe_write+0x2a>
	return i;
  801eb2:	89 f8                	mov    %edi,%eax
  801eb4:	eb 23                	jmp    801ed9 <devpipe_write+0x48>
			sys_yield();
  801eb6:	e8 b4 ec ff ff       	call   800b6f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ebb:	8b 43 04             	mov    0x4(%ebx),%eax
  801ebe:	8b 0b                	mov    (%ebx),%ecx
  801ec0:	8d 51 20             	lea    0x20(%ecx),%edx
  801ec3:	39 d0                	cmp    %edx,%eax
  801ec5:	72 1a                	jb     801ee1 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ec7:	89 da                	mov    %ebx,%edx
  801ec9:	89 f0                	mov    %esi,%eax
  801ecb:	e8 5c ff ff ff       	call   801e2c <_pipeisclosed>
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	74 e2                	je     801eb6 <devpipe_write+0x25>
				return 0;
  801ed4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ed9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801edc:	5b                   	pop    %ebx
  801edd:	5e                   	pop    %esi
  801ede:	5f                   	pop    %edi
  801edf:	5d                   	pop    %ebp
  801ee0:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ee1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ee8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801eeb:	89 c2                	mov    %eax,%edx
  801eed:	c1 fa 1f             	sar    $0x1f,%edx
  801ef0:	89 d1                	mov    %edx,%ecx
  801ef2:	c1 e9 1b             	shr    $0x1b,%ecx
  801ef5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ef8:	83 e2 1f             	and    $0x1f,%edx
  801efb:	29 ca                	sub    %ecx,%edx
  801efd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f01:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f05:	83 c0 01             	add    $0x1,%eax
  801f08:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f0b:	83 c7 01             	add    $0x1,%edi
  801f0e:	eb 9d                	jmp    801ead <devpipe_write+0x1c>

00801f10 <devpipe_read>:
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	57                   	push   %edi
  801f14:	56                   	push   %esi
  801f15:	53                   	push   %ebx
  801f16:	83 ec 18             	sub    $0x18,%esp
  801f19:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f1c:	57                   	push   %edi
  801f1d:	e8 52 f2 ff ff       	call   801174 <fd2data>
  801f22:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	be 00 00 00 00       	mov    $0x0,%esi
  801f2c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f2f:	75 13                	jne    801f44 <devpipe_read+0x34>
	return i;
  801f31:	89 f0                	mov    %esi,%eax
  801f33:	eb 02                	jmp    801f37 <devpipe_read+0x27>
				return i;
  801f35:	89 f0                	mov    %esi,%eax
}
  801f37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3a:	5b                   	pop    %ebx
  801f3b:	5e                   	pop    %esi
  801f3c:	5f                   	pop    %edi
  801f3d:	5d                   	pop    %ebp
  801f3e:	c3                   	ret    
			sys_yield();
  801f3f:	e8 2b ec ff ff       	call   800b6f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f44:	8b 03                	mov    (%ebx),%eax
  801f46:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f49:	75 18                	jne    801f63 <devpipe_read+0x53>
			if (i > 0)
  801f4b:	85 f6                	test   %esi,%esi
  801f4d:	75 e6                	jne    801f35 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801f4f:	89 da                	mov    %ebx,%edx
  801f51:	89 f8                	mov    %edi,%eax
  801f53:	e8 d4 fe ff ff       	call   801e2c <_pipeisclosed>
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	74 e3                	je     801f3f <devpipe_read+0x2f>
				return 0;
  801f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f61:	eb d4                	jmp    801f37 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f63:	99                   	cltd   
  801f64:	c1 ea 1b             	shr    $0x1b,%edx
  801f67:	01 d0                	add    %edx,%eax
  801f69:	83 e0 1f             	and    $0x1f,%eax
  801f6c:	29 d0                	sub    %edx,%eax
  801f6e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f76:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f79:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801f7c:	83 c6 01             	add    $0x1,%esi
  801f7f:	eb ab                	jmp    801f2c <devpipe_read+0x1c>

00801f81 <pipe>:
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	56                   	push   %esi
  801f85:	53                   	push   %ebx
  801f86:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8c:	50                   	push   %eax
  801f8d:	e8 f9 f1 ff ff       	call   80118b <fd_alloc>
  801f92:	89 c3                	mov    %eax,%ebx
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	85 c0                	test   %eax,%eax
  801f99:	0f 88 23 01 00 00    	js     8020c2 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9f:	83 ec 04             	sub    $0x4,%esp
  801fa2:	68 07 04 00 00       	push   $0x407
  801fa7:	ff 75 f4             	push   -0xc(%ebp)
  801faa:	6a 00                	push   $0x0
  801fac:	e8 dd eb ff ff       	call   800b8e <sys_page_alloc>
  801fb1:	89 c3                	mov    %eax,%ebx
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	0f 88 04 01 00 00    	js     8020c2 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801fbe:	83 ec 0c             	sub    $0xc,%esp
  801fc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fc4:	50                   	push   %eax
  801fc5:	e8 c1 f1 ff ff       	call   80118b <fd_alloc>
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	83 c4 10             	add    $0x10,%esp
  801fcf:	85 c0                	test   %eax,%eax
  801fd1:	0f 88 db 00 00 00    	js     8020b2 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fd7:	83 ec 04             	sub    $0x4,%esp
  801fda:	68 07 04 00 00       	push   $0x407
  801fdf:	ff 75 f0             	push   -0x10(%ebp)
  801fe2:	6a 00                	push   $0x0
  801fe4:	e8 a5 eb ff ff       	call   800b8e <sys_page_alloc>
  801fe9:	89 c3                	mov    %eax,%ebx
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	0f 88 bc 00 00 00    	js     8020b2 <pipe+0x131>
	va = fd2data(fd0);
  801ff6:	83 ec 0c             	sub    $0xc,%esp
  801ff9:	ff 75 f4             	push   -0xc(%ebp)
  801ffc:	e8 73 f1 ff ff       	call   801174 <fd2data>
  802001:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802003:	83 c4 0c             	add    $0xc,%esp
  802006:	68 07 04 00 00       	push   $0x407
  80200b:	50                   	push   %eax
  80200c:	6a 00                	push   $0x0
  80200e:	e8 7b eb ff ff       	call   800b8e <sys_page_alloc>
  802013:	89 c3                	mov    %eax,%ebx
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	85 c0                	test   %eax,%eax
  80201a:	0f 88 82 00 00 00    	js     8020a2 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802020:	83 ec 0c             	sub    $0xc,%esp
  802023:	ff 75 f0             	push   -0x10(%ebp)
  802026:	e8 49 f1 ff ff       	call   801174 <fd2data>
  80202b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802032:	50                   	push   %eax
  802033:	6a 00                	push   $0x0
  802035:	56                   	push   %esi
  802036:	6a 00                	push   $0x0
  802038:	e8 94 eb ff ff       	call   800bd1 <sys_page_map>
  80203d:	89 c3                	mov    %eax,%ebx
  80203f:	83 c4 20             	add    $0x20,%esp
  802042:	85 c0                	test   %eax,%eax
  802044:	78 4e                	js     802094 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802046:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80204b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80204e:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802050:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802053:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80205a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80205d:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80205f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802062:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802069:	83 ec 0c             	sub    $0xc,%esp
  80206c:	ff 75 f4             	push   -0xc(%ebp)
  80206f:	e8 f0 f0 ff ff       	call   801164 <fd2num>
  802074:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802077:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802079:	83 c4 04             	add    $0x4,%esp
  80207c:	ff 75 f0             	push   -0x10(%ebp)
  80207f:	e8 e0 f0 ff ff       	call   801164 <fd2num>
  802084:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802087:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802092:	eb 2e                	jmp    8020c2 <pipe+0x141>
	sys_page_unmap(0, va);
  802094:	83 ec 08             	sub    $0x8,%esp
  802097:	56                   	push   %esi
  802098:	6a 00                	push   $0x0
  80209a:	e8 74 eb ff ff       	call   800c13 <sys_page_unmap>
  80209f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8020a2:	83 ec 08             	sub    $0x8,%esp
  8020a5:	ff 75 f0             	push   -0x10(%ebp)
  8020a8:	6a 00                	push   $0x0
  8020aa:	e8 64 eb ff ff       	call   800c13 <sys_page_unmap>
  8020af:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8020b2:	83 ec 08             	sub    $0x8,%esp
  8020b5:	ff 75 f4             	push   -0xc(%ebp)
  8020b8:	6a 00                	push   $0x0
  8020ba:	e8 54 eb ff ff       	call   800c13 <sys_page_unmap>
  8020bf:	83 c4 10             	add    $0x10,%esp
}
  8020c2:	89 d8                	mov    %ebx,%eax
  8020c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020c7:	5b                   	pop    %ebx
  8020c8:	5e                   	pop    %esi
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    

008020cb <pipeisclosed>:
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d4:	50                   	push   %eax
  8020d5:	ff 75 08             	push   0x8(%ebp)
  8020d8:	e8 fe f0 ff ff       	call   8011db <fd_lookup>
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	78 18                	js     8020fc <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8020e4:	83 ec 0c             	sub    $0xc,%esp
  8020e7:	ff 75 f4             	push   -0xc(%ebp)
  8020ea:	e8 85 f0 ff ff       	call   801174 <fd2data>
  8020ef:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8020f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f4:	e8 33 fd ff ff       	call   801e2c <_pipeisclosed>
  8020f9:	83 c4 10             	add    $0x10,%esp
}
  8020fc:	c9                   	leave  
  8020fd:	c3                   	ret    

008020fe <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8020fe:	b8 00 00 00 00       	mov    $0x0,%eax
  802103:	c3                   	ret    

00802104 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80210a:	68 53 2b 80 00       	push   $0x802b53
  80210f:	ff 75 0c             	push   0xc(%ebp)
  802112:	e8 7b e6 ff ff       	call   800792 <strcpy>
	return 0;
}
  802117:	b8 00 00 00 00       	mov    $0x0,%eax
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <devcons_write>:
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80212a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80212f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802135:	eb 2e                	jmp    802165 <devcons_write+0x47>
		m = n - tot;
  802137:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80213a:	29 f3                	sub    %esi,%ebx
  80213c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802141:	39 c3                	cmp    %eax,%ebx
  802143:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802146:	83 ec 04             	sub    $0x4,%esp
  802149:	53                   	push   %ebx
  80214a:	89 f0                	mov    %esi,%eax
  80214c:	03 45 0c             	add    0xc(%ebp),%eax
  80214f:	50                   	push   %eax
  802150:	57                   	push   %edi
  802151:	e8 d2 e7 ff ff       	call   800928 <memmove>
		sys_cputs(buf, m);
  802156:	83 c4 08             	add    $0x8,%esp
  802159:	53                   	push   %ebx
  80215a:	57                   	push   %edi
  80215b:	e8 72 e9 ff ff       	call   800ad2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802160:	01 de                	add    %ebx,%esi
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	3b 75 10             	cmp    0x10(%ebp),%esi
  802168:	72 cd                	jb     802137 <devcons_write+0x19>
}
  80216a:	89 f0                	mov    %esi,%eax
  80216c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    

00802174 <devcons_read>:
{
  802174:	55                   	push   %ebp
  802175:	89 e5                	mov    %esp,%ebp
  802177:	83 ec 08             	sub    $0x8,%esp
  80217a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80217f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802183:	75 07                	jne    80218c <devcons_read+0x18>
  802185:	eb 1f                	jmp    8021a6 <devcons_read+0x32>
		sys_yield();
  802187:	e8 e3 e9 ff ff       	call   800b6f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80218c:	e8 5f e9 ff ff       	call   800af0 <sys_cgetc>
  802191:	85 c0                	test   %eax,%eax
  802193:	74 f2                	je     802187 <devcons_read+0x13>
	if (c < 0)
  802195:	78 0f                	js     8021a6 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802197:	83 f8 04             	cmp    $0x4,%eax
  80219a:	74 0c                	je     8021a8 <devcons_read+0x34>
	*(char*)vbuf = c;
  80219c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80219f:	88 02                	mov    %al,(%edx)
	return 1;
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8021a6:	c9                   	leave  
  8021a7:	c3                   	ret    
		return 0;
  8021a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ad:	eb f7                	jmp    8021a6 <devcons_read+0x32>

008021af <cputchar>:
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8021bb:	6a 01                	push   $0x1
  8021bd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021c0:	50                   	push   %eax
  8021c1:	e8 0c e9 ff ff       	call   800ad2 <sys_cputs>
}
  8021c6:	83 c4 10             	add    $0x10,%esp
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <getchar>:
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8021d1:	6a 01                	push   $0x1
  8021d3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d6:	50                   	push   %eax
  8021d7:	6a 00                	push   $0x0
  8021d9:	e8 66 f2 ff ff       	call   801444 <read>
	if (r < 0)
  8021de:	83 c4 10             	add    $0x10,%esp
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	78 06                	js     8021eb <getchar+0x20>
	if (r < 1)
  8021e5:	74 06                	je     8021ed <getchar+0x22>
	return c;
  8021e7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8021eb:	c9                   	leave  
  8021ec:	c3                   	ret    
		return -E_EOF;
  8021ed:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8021f2:	eb f7                	jmp    8021eb <getchar+0x20>

008021f4 <iscons>:
{
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fd:	50                   	push   %eax
  8021fe:	ff 75 08             	push   0x8(%ebp)
  802201:	e8 d5 ef ff ff       	call   8011db <fd_lookup>
  802206:	83 c4 10             	add    $0x10,%esp
  802209:	85 c0                	test   %eax,%eax
  80220b:	78 11                	js     80221e <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80220d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802210:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802216:	39 10                	cmp    %edx,(%eax)
  802218:	0f 94 c0             	sete   %al
  80221b:	0f b6 c0             	movzbl %al,%eax
}
  80221e:	c9                   	leave  
  80221f:	c3                   	ret    

00802220 <opencons>:
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802226:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802229:	50                   	push   %eax
  80222a:	e8 5c ef ff ff       	call   80118b <fd_alloc>
  80222f:	83 c4 10             	add    $0x10,%esp
  802232:	85 c0                	test   %eax,%eax
  802234:	78 3a                	js     802270 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802236:	83 ec 04             	sub    $0x4,%esp
  802239:	68 07 04 00 00       	push   $0x407
  80223e:	ff 75 f4             	push   -0xc(%ebp)
  802241:	6a 00                	push   $0x0
  802243:	e8 46 e9 ff ff       	call   800b8e <sys_page_alloc>
  802248:	83 c4 10             	add    $0x10,%esp
  80224b:	85 c0                	test   %eax,%eax
  80224d:	78 21                	js     802270 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80224f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802252:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802258:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80225a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802264:	83 ec 0c             	sub    $0xc,%esp
  802267:	50                   	push   %eax
  802268:	e8 f7 ee ff ff       	call   801164 <fd2num>
  80226d:	83 c4 10             	add    $0x10,%esp
}
  802270:	c9                   	leave  
  802271:	c3                   	ret    

00802272 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	56                   	push   %esi
  802276:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802277:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80227a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802280:	e8 cb e8 ff ff       	call   800b50 <sys_getenvid>
  802285:	83 ec 0c             	sub    $0xc,%esp
  802288:	ff 75 0c             	push   0xc(%ebp)
  80228b:	ff 75 08             	push   0x8(%ebp)
  80228e:	56                   	push   %esi
  80228f:	50                   	push   %eax
  802290:	68 60 2b 80 00       	push   $0x802b60
  802295:	e8 1e df ff ff       	call   8001b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80229a:	83 c4 18             	add    $0x18,%esp
  80229d:	53                   	push   %ebx
  80229e:	ff 75 10             	push   0x10(%ebp)
  8022a1:	e8 c1 de ff ff       	call   800167 <vcprintf>
	cprintf("\n");
  8022a6:	c7 04 24 4c 2b 80 00 	movl   $0x802b4c,(%esp)
  8022ad:	e8 06 df ff ff       	call   8001b8 <cprintf>
  8022b2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022b5:	cc                   	int3   
  8022b6:	eb fd                	jmp    8022b5 <_panic+0x43>

008022b8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
  8022bb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8022be:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8022c5:	74 0a                	je     8022d1 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ca:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8022cf:	c9                   	leave  
  8022d0:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8022d1:	e8 7a e8 ff ff       	call   800b50 <sys_getenvid>
  8022d6:	83 ec 04             	sub    $0x4,%esp
  8022d9:	68 07 0e 00 00       	push   $0xe07
  8022de:	68 00 f0 bf ee       	push   $0xeebff000
  8022e3:	50                   	push   %eax
  8022e4:	e8 a5 e8 ff ff       	call   800b8e <sys_page_alloc>
		if (r < 0) {
  8022e9:	83 c4 10             	add    $0x10,%esp
  8022ec:	85 c0                	test   %eax,%eax
  8022ee:	78 2c                	js     80231c <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8022f0:	e8 5b e8 ff ff       	call   800b50 <sys_getenvid>
  8022f5:	83 ec 08             	sub    $0x8,%esp
  8022f8:	68 2e 23 80 00       	push   $0x80232e
  8022fd:	50                   	push   %eax
  8022fe:	e8 d6 e9 ff ff       	call   800cd9 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802303:	83 c4 10             	add    $0x10,%esp
  802306:	85 c0                	test   %eax,%eax
  802308:	79 bd                	jns    8022c7 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80230a:	50                   	push   %eax
  80230b:	68 c4 2b 80 00       	push   $0x802bc4
  802310:	6a 28                	push   $0x28
  802312:	68 fa 2b 80 00       	push   $0x802bfa
  802317:	e8 56 ff ff ff       	call   802272 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80231c:	50                   	push   %eax
  80231d:	68 84 2b 80 00       	push   $0x802b84
  802322:	6a 23                	push   $0x23
  802324:	68 fa 2b 80 00       	push   $0x802bfa
  802329:	e8 44 ff ff ff       	call   802272 <_panic>

0080232e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80232e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80232f:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802334:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802336:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802339:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80233d:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802340:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802344:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802348:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80234a:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80234d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80234e:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802351:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802352:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802353:	c3                   	ret    

00802354 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802354:	55                   	push   %ebp
  802355:	89 e5                	mov    %esp,%ebp
  802357:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80235a:	89 c2                	mov    %eax,%edx
  80235c:	c1 ea 16             	shr    $0x16,%edx
  80235f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802366:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80236b:	f6 c1 01             	test   $0x1,%cl
  80236e:	74 1c                	je     80238c <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802370:	c1 e8 0c             	shr    $0xc,%eax
  802373:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80237a:	a8 01                	test   $0x1,%al
  80237c:	74 0e                	je     80238c <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80237e:	c1 e8 0c             	shr    $0xc,%eax
  802381:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802388:	ef 
  802389:	0f b7 d2             	movzwl %dx,%edx
}
  80238c:	89 d0                	mov    %edx,%eax
  80238e:	5d                   	pop    %ebp
  80238f:	c3                   	ret    

00802390 <__udivdi3>:
  802390:	f3 0f 1e fb          	endbr32 
  802394:	55                   	push   %ebp
  802395:	57                   	push   %edi
  802396:	56                   	push   %esi
  802397:	53                   	push   %ebx
  802398:	83 ec 1c             	sub    $0x1c,%esp
  80239b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80239f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	75 19                	jne    8023c8 <__udivdi3+0x38>
  8023af:	39 f3                	cmp    %esi,%ebx
  8023b1:	76 4d                	jbe    802400 <__udivdi3+0x70>
  8023b3:	31 ff                	xor    %edi,%edi
  8023b5:	89 e8                	mov    %ebp,%eax
  8023b7:	89 f2                	mov    %esi,%edx
  8023b9:	f7 f3                	div    %ebx
  8023bb:	89 fa                	mov    %edi,%edx
  8023bd:	83 c4 1c             	add    $0x1c,%esp
  8023c0:	5b                   	pop    %ebx
  8023c1:	5e                   	pop    %esi
  8023c2:	5f                   	pop    %edi
  8023c3:	5d                   	pop    %ebp
  8023c4:	c3                   	ret    
  8023c5:	8d 76 00             	lea    0x0(%esi),%esi
  8023c8:	39 f0                	cmp    %esi,%eax
  8023ca:	76 14                	jbe    8023e0 <__udivdi3+0x50>
  8023cc:	31 ff                	xor    %edi,%edi
  8023ce:	31 c0                	xor    %eax,%eax
  8023d0:	89 fa                	mov    %edi,%edx
  8023d2:	83 c4 1c             	add    $0x1c,%esp
  8023d5:	5b                   	pop    %ebx
  8023d6:	5e                   	pop    %esi
  8023d7:	5f                   	pop    %edi
  8023d8:	5d                   	pop    %ebp
  8023d9:	c3                   	ret    
  8023da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023e0:	0f bd f8             	bsr    %eax,%edi
  8023e3:	83 f7 1f             	xor    $0x1f,%edi
  8023e6:	75 48                	jne    802430 <__udivdi3+0xa0>
  8023e8:	39 f0                	cmp    %esi,%eax
  8023ea:	72 06                	jb     8023f2 <__udivdi3+0x62>
  8023ec:	31 c0                	xor    %eax,%eax
  8023ee:	39 eb                	cmp    %ebp,%ebx
  8023f0:	77 de                	ja     8023d0 <__udivdi3+0x40>
  8023f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f7:	eb d7                	jmp    8023d0 <__udivdi3+0x40>
  8023f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802400:	89 d9                	mov    %ebx,%ecx
  802402:	85 db                	test   %ebx,%ebx
  802404:	75 0b                	jne    802411 <__udivdi3+0x81>
  802406:	b8 01 00 00 00       	mov    $0x1,%eax
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	f7 f3                	div    %ebx
  80240f:	89 c1                	mov    %eax,%ecx
  802411:	31 d2                	xor    %edx,%edx
  802413:	89 f0                	mov    %esi,%eax
  802415:	f7 f1                	div    %ecx
  802417:	89 c6                	mov    %eax,%esi
  802419:	89 e8                	mov    %ebp,%eax
  80241b:	89 f7                	mov    %esi,%edi
  80241d:	f7 f1                	div    %ecx
  80241f:	89 fa                	mov    %edi,%edx
  802421:	83 c4 1c             	add    $0x1c,%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	89 f9                	mov    %edi,%ecx
  802432:	ba 20 00 00 00       	mov    $0x20,%edx
  802437:	29 fa                	sub    %edi,%edx
  802439:	d3 e0                	shl    %cl,%eax
  80243b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80243f:	89 d1                	mov    %edx,%ecx
  802441:	89 d8                	mov    %ebx,%eax
  802443:	d3 e8                	shr    %cl,%eax
  802445:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802449:	09 c1                	or     %eax,%ecx
  80244b:	89 f0                	mov    %esi,%eax
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 f9                	mov    %edi,%ecx
  802453:	d3 e3                	shl    %cl,%ebx
  802455:	89 d1                	mov    %edx,%ecx
  802457:	d3 e8                	shr    %cl,%eax
  802459:	89 f9                	mov    %edi,%ecx
  80245b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80245f:	89 eb                	mov    %ebp,%ebx
  802461:	d3 e6                	shl    %cl,%esi
  802463:	89 d1                	mov    %edx,%ecx
  802465:	d3 eb                	shr    %cl,%ebx
  802467:	09 f3                	or     %esi,%ebx
  802469:	89 c6                	mov    %eax,%esi
  80246b:	89 f2                	mov    %esi,%edx
  80246d:	89 d8                	mov    %ebx,%eax
  80246f:	f7 74 24 08          	divl   0x8(%esp)
  802473:	89 d6                	mov    %edx,%esi
  802475:	89 c3                	mov    %eax,%ebx
  802477:	f7 64 24 0c          	mull   0xc(%esp)
  80247b:	39 d6                	cmp    %edx,%esi
  80247d:	72 19                	jb     802498 <__udivdi3+0x108>
  80247f:	89 f9                	mov    %edi,%ecx
  802481:	d3 e5                	shl    %cl,%ebp
  802483:	39 c5                	cmp    %eax,%ebp
  802485:	73 04                	jae    80248b <__udivdi3+0xfb>
  802487:	39 d6                	cmp    %edx,%esi
  802489:	74 0d                	je     802498 <__udivdi3+0x108>
  80248b:	89 d8                	mov    %ebx,%eax
  80248d:	31 ff                	xor    %edi,%edi
  80248f:	e9 3c ff ff ff       	jmp    8023d0 <__udivdi3+0x40>
  802494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802498:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80249b:	31 ff                	xor    %edi,%edi
  80249d:	e9 2e ff ff ff       	jmp    8023d0 <__udivdi3+0x40>
  8024a2:	66 90                	xchg   %ax,%ax
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__umoddi3>:
  8024b0:	f3 0f 1e fb          	endbr32 
  8024b4:	55                   	push   %ebp
  8024b5:	57                   	push   %edi
  8024b6:	56                   	push   %esi
  8024b7:	53                   	push   %ebx
  8024b8:	83 ec 1c             	sub    $0x1c,%esp
  8024bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8024c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8024cb:	89 f0                	mov    %esi,%eax
  8024cd:	89 da                	mov    %ebx,%edx
  8024cf:	85 ff                	test   %edi,%edi
  8024d1:	75 15                	jne    8024e8 <__umoddi3+0x38>
  8024d3:	39 dd                	cmp    %ebx,%ebp
  8024d5:	76 39                	jbe    802510 <__umoddi3+0x60>
  8024d7:	f7 f5                	div    %ebp
  8024d9:	89 d0                	mov    %edx,%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	83 c4 1c             	add    $0x1c,%esp
  8024e0:	5b                   	pop    %ebx
  8024e1:	5e                   	pop    %esi
  8024e2:	5f                   	pop    %edi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    
  8024e5:	8d 76 00             	lea    0x0(%esi),%esi
  8024e8:	39 df                	cmp    %ebx,%edi
  8024ea:	77 f1                	ja     8024dd <__umoddi3+0x2d>
  8024ec:	0f bd cf             	bsr    %edi,%ecx
  8024ef:	83 f1 1f             	xor    $0x1f,%ecx
  8024f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8024f6:	75 40                	jne    802538 <__umoddi3+0x88>
  8024f8:	39 df                	cmp    %ebx,%edi
  8024fa:	72 04                	jb     802500 <__umoddi3+0x50>
  8024fc:	39 f5                	cmp    %esi,%ebp
  8024fe:	77 dd                	ja     8024dd <__umoddi3+0x2d>
  802500:	89 da                	mov    %ebx,%edx
  802502:	89 f0                	mov    %esi,%eax
  802504:	29 e8                	sub    %ebp,%eax
  802506:	19 fa                	sbb    %edi,%edx
  802508:	eb d3                	jmp    8024dd <__umoddi3+0x2d>
  80250a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802510:	89 e9                	mov    %ebp,%ecx
  802512:	85 ed                	test   %ebp,%ebp
  802514:	75 0b                	jne    802521 <__umoddi3+0x71>
  802516:	b8 01 00 00 00       	mov    $0x1,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	f7 f5                	div    %ebp
  80251f:	89 c1                	mov    %eax,%ecx
  802521:	89 d8                	mov    %ebx,%eax
  802523:	31 d2                	xor    %edx,%edx
  802525:	f7 f1                	div    %ecx
  802527:	89 f0                	mov    %esi,%eax
  802529:	f7 f1                	div    %ecx
  80252b:	89 d0                	mov    %edx,%eax
  80252d:	31 d2                	xor    %edx,%edx
  80252f:	eb ac                	jmp    8024dd <__umoddi3+0x2d>
  802531:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802538:	8b 44 24 04          	mov    0x4(%esp),%eax
  80253c:	ba 20 00 00 00       	mov    $0x20,%edx
  802541:	29 c2                	sub    %eax,%edx
  802543:	89 c1                	mov    %eax,%ecx
  802545:	89 e8                	mov    %ebp,%eax
  802547:	d3 e7                	shl    %cl,%edi
  802549:	89 d1                	mov    %edx,%ecx
  80254b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80254f:	d3 e8                	shr    %cl,%eax
  802551:	89 c1                	mov    %eax,%ecx
  802553:	8b 44 24 04          	mov    0x4(%esp),%eax
  802557:	09 f9                	or     %edi,%ecx
  802559:	89 df                	mov    %ebx,%edi
  80255b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80255f:	89 c1                	mov    %eax,%ecx
  802561:	d3 e5                	shl    %cl,%ebp
  802563:	89 d1                	mov    %edx,%ecx
  802565:	d3 ef                	shr    %cl,%edi
  802567:	89 c1                	mov    %eax,%ecx
  802569:	89 f0                	mov    %esi,%eax
  80256b:	d3 e3                	shl    %cl,%ebx
  80256d:	89 d1                	mov    %edx,%ecx
  80256f:	89 fa                	mov    %edi,%edx
  802571:	d3 e8                	shr    %cl,%eax
  802573:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802578:	09 d8                	or     %ebx,%eax
  80257a:	f7 74 24 08          	divl   0x8(%esp)
  80257e:	89 d3                	mov    %edx,%ebx
  802580:	d3 e6                	shl    %cl,%esi
  802582:	f7 e5                	mul    %ebp
  802584:	89 c7                	mov    %eax,%edi
  802586:	89 d1                	mov    %edx,%ecx
  802588:	39 d3                	cmp    %edx,%ebx
  80258a:	72 06                	jb     802592 <__umoddi3+0xe2>
  80258c:	75 0e                	jne    80259c <__umoddi3+0xec>
  80258e:	39 c6                	cmp    %eax,%esi
  802590:	73 0a                	jae    80259c <__umoddi3+0xec>
  802592:	29 e8                	sub    %ebp,%eax
  802594:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802598:	89 d1                	mov    %edx,%ecx
  80259a:	89 c7                	mov    %eax,%edi
  80259c:	89 f5                	mov    %esi,%ebp
  80259e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025a2:	29 fd                	sub    %edi,%ebp
  8025a4:	19 cb                	sbb    %ecx,%ebx
  8025a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8025ab:	89 d8                	mov    %ebx,%eax
  8025ad:	d3 e0                	shl    %cl,%eax
  8025af:	89 f1                	mov    %esi,%ecx
  8025b1:	d3 ed                	shr    %cl,%ebp
  8025b3:	d3 eb                	shr    %cl,%ebx
  8025b5:	09 e8                	or     %ebp,%eax
  8025b7:	89 da                	mov    %ebx,%edx
  8025b9:	83 c4 1c             	add    $0x1c,%esp
  8025bc:	5b                   	pop    %ebx
  8025bd:	5e                   	pop    %esi
  8025be:	5f                   	pop    %edi
  8025bf:	5d                   	pop    %ebp
  8025c0:	c3                   	ret    
