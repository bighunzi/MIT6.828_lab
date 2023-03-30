
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
  80003c:	e8 9a 0e 00 00       	call   800edb <fork>
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
  800053:	e8 03 10 00 00       	call   80105b <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 eb 0a 00 00       	call   800b4d <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 d6 25 80 00       	push   $0x8025d6
  80006a:	e8 46 01 00 00       	call   8001b5 <cprintf>
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
  800082:	e8 3b 10 00 00       	call   8010c2 <ipc_send>
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
  800099:	e8 af 0a 00 00       	call   800b4d <sys_getenvid>
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	50                   	push   %eax
  8000a3:	68 c0 25 80 00       	push   $0x8025c0
  8000a8:	e8 08 01 00 00       	call   8001b5 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	push   -0x1c(%ebp)
  8000b6:	e8 07 10 00 00       	call   8010c2 <ipc_send>
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
  8000cb:	e8 7d 0a 00 00       	call   800b4d <sys_getenvid>
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000dd:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e2:	85 db                	test   %ebx,%ebx
  8000e4:	7e 07                	jle    8000ed <libmain+0x2d>
		binaryname = argv[0];
  8000e6:	8b 06                	mov    (%esi),%eax
  8000e8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	e8 3c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f7:	e8 0a 00 00 00       	call   800106 <exit>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010c:	e8 0f 12 00 00       	call   801320 <close_all>
	sys_env_destroy(0);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	6a 00                	push   $0x0
  800116:	e8 f1 09 00 00       	call   800b0c <sys_env_destroy>
}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 04             	sub    $0x4,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 13                	mov    (%ebx),%edx
  80012c:	8d 42 01             	lea    0x1(%edx),%eax
  80012f:	89 03                	mov    %eax,(%ebx)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013d:	74 09                	je     800148 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80013f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800146:	c9                   	leave  
  800147:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800148:	83 ec 08             	sub    $0x8,%esp
  80014b:	68 ff 00 00 00       	push   $0xff
  800150:	8d 43 08             	lea    0x8(%ebx),%eax
  800153:	50                   	push   %eax
  800154:	e8 76 09 00 00       	call   800acf <sys_cputs>
		b->idx = 0;
  800159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	eb db                	jmp    80013f <putch+0x1f>

00800164 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800174:	00 00 00 
	b.cnt = 0;
  800177:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800181:	ff 75 0c             	push   0xc(%ebp)
  800184:	ff 75 08             	push   0x8(%ebp)
  800187:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	68 20 01 80 00       	push   $0x800120
  800193:	e8 14 01 00 00       	call   8002ac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800198:	83 c4 08             	add    $0x8,%esp
  80019b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 22 09 00 00       	call   800acf <sys_cputs>

	return b.cnt;
}
  8001ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001be:	50                   	push   %eax
  8001bf:	ff 75 08             	push   0x8(%ebp)
  8001c2:	e8 9d ff ff ff       	call   800164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    

008001c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 1c             	sub    $0x1c,%esp
  8001d2:	89 c7                	mov    %eax,%edi
  8001d4:	89 d6                	mov    %edx,%esi
  8001d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dc:	89 d1                	mov    %edx,%ecx
  8001de:	89 c2                	mov    %eax,%edx
  8001e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f6:	39 c2                	cmp    %eax,%edx
  8001f8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001fb:	72 3e                	jb     80023b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	ff 75 18             	push   0x18(%ebp)
  800203:	83 eb 01             	sub    $0x1,%ebx
  800206:	53                   	push   %ebx
  800207:	50                   	push   %eax
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	push   -0x1c(%ebp)
  80020e:	ff 75 e0             	push   -0x20(%ebp)
  800211:	ff 75 dc             	push   -0x24(%ebp)
  800214:	ff 75 d8             	push   -0x28(%ebp)
  800217:	e8 64 21 00 00       	call   802380 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9f ff ff ff       	call   8001c9 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 13                	jmp    800242 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	push   0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023b:	83 eb 01             	sub    $0x1,%ebx
  80023e:	85 db                	test   %ebx,%ebx
  800240:	7f ed                	jg     80022f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	56                   	push   %esi
  800246:	83 ec 04             	sub    $0x4,%esp
  800249:	ff 75 e4             	push   -0x1c(%ebp)
  80024c:	ff 75 e0             	push   -0x20(%ebp)
  80024f:	ff 75 dc             	push   -0x24(%ebp)
  800252:	ff 75 d8             	push   -0x28(%ebp)
  800255:	e8 46 22 00 00       	call   8024a0 <__umoddi3>
  80025a:	83 c4 14             	add    $0x14,%esp
  80025d:	0f be 80 f3 25 80 00 	movsbl 0x8025f3(%eax),%eax
  800264:	50                   	push   %eax
  800265:	ff d7                	call   *%edi
}
  800267:	83 c4 10             	add    $0x10,%esp
  80026a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800278:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	3b 50 04             	cmp    0x4(%eax),%edx
  800281:	73 0a                	jae    80028d <sprintputch+0x1b>
		*b->buf++ = ch;
  800283:	8d 4a 01             	lea    0x1(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 45 08             	mov    0x8(%ebp),%eax
  80028b:	88 02                	mov    %al,(%edx)
}
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <printfmt>:
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800295:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800298:	50                   	push   %eax
  800299:	ff 75 10             	push   0x10(%ebp)
  80029c:	ff 75 0c             	push   0xc(%ebp)
  80029f:	ff 75 08             	push   0x8(%ebp)
  8002a2:	e8 05 00 00 00       	call   8002ac <vprintfmt>
}
  8002a7:	83 c4 10             	add    $0x10,%esp
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <vprintfmt>:
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	53                   	push   %ebx
  8002b2:	83 ec 3c             	sub    $0x3c,%esp
  8002b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002be:	eb 0a                	jmp    8002ca <vprintfmt+0x1e>
			putch(ch, putdat);
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	50                   	push   %eax
  8002c5:	ff d6                	call   *%esi
  8002c7:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ca:	83 c7 01             	add    $0x1,%edi
  8002cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d1:	83 f8 25             	cmp    $0x25,%eax
  8002d4:	74 0c                	je     8002e2 <vprintfmt+0x36>
			if (ch == '\0')
  8002d6:	85 c0                	test   %eax,%eax
  8002d8:	75 e6                	jne    8002c0 <vprintfmt+0x14>
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    
		padc = ' ';
  8002e2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002e6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ed:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002fb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8d 47 01             	lea    0x1(%edi),%eax
  800303:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800306:	0f b6 17             	movzbl (%edi),%edx
  800309:	8d 42 dd             	lea    -0x23(%edx),%eax
  80030c:	3c 55                	cmp    $0x55,%al
  80030e:	0f 87 bb 03 00 00    	ja     8006cf <vprintfmt+0x423>
  800314:	0f b6 c0             	movzbl %al,%eax
  800317:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800321:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800325:	eb d9                	jmp    800300 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80032e:	eb d0                	jmp    800300 <vprintfmt+0x54>
  800330:	0f b6 d2             	movzbl %dl,%edx
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800336:	b8 00 00 00 00       	mov    $0x0,%eax
  80033b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80033e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800341:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800345:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800348:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034b:	83 f9 09             	cmp    $0x9,%ecx
  80034e:	77 55                	ja     8003a5 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800350:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800353:	eb e9                	jmp    80033e <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800355:	8b 45 14             	mov    0x14(%ebp),%eax
  800358:	8b 00                	mov    (%eax),%eax
  80035a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035d:	8b 45 14             	mov    0x14(%ebp),%eax
  800360:	8d 40 04             	lea    0x4(%eax),%eax
  800363:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800369:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036d:	79 91                	jns    800300 <vprintfmt+0x54>
				width = precision, precision = -1;
  80036f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800372:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800375:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80037c:	eb 82                	jmp    800300 <vprintfmt+0x54>
  80037e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800381:	85 d2                	test   %edx,%edx
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	0f 49 c2             	cmovns %edx,%eax
  80038b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800391:	e9 6a ff ff ff       	jmp    800300 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800399:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a0:	e9 5b ff ff ff       	jmp    800300 <vprintfmt+0x54>
  8003a5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ab:	eb bc                	jmp    800369 <vprintfmt+0xbd>
			lflag++;
  8003ad:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b3:	e9 48 ff ff ff       	jmp    800300 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 78 04             	lea    0x4(%eax),%edi
  8003be:	83 ec 08             	sub    $0x8,%esp
  8003c1:	53                   	push   %ebx
  8003c2:	ff 30                	push   (%eax)
  8003c4:	ff d6                	call   *%esi
			break;
  8003c6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003cc:	e9 9d 02 00 00       	jmp    80066e <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 78 04             	lea    0x4(%eax),%edi
  8003d7:	8b 10                	mov    (%eax),%edx
  8003d9:	89 d0                	mov    %edx,%eax
  8003db:	f7 d8                	neg    %eax
  8003dd:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e0:	83 f8 0f             	cmp    $0xf,%eax
  8003e3:	7f 23                	jg     800408 <vprintfmt+0x15c>
  8003e5:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	74 18                	je     800408 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003f0:	52                   	push   %edx
  8003f1:	68 c1 2a 80 00       	push   $0x802ac1
  8003f6:	53                   	push   %ebx
  8003f7:	56                   	push   %esi
  8003f8:	e8 92 fe ff ff       	call   80028f <printfmt>
  8003fd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800400:	89 7d 14             	mov    %edi,0x14(%ebp)
  800403:	e9 66 02 00 00       	jmp    80066e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800408:	50                   	push   %eax
  800409:	68 0b 26 80 00       	push   $0x80260b
  80040e:	53                   	push   %ebx
  80040f:	56                   	push   %esi
  800410:	e8 7a fe ff ff       	call   80028f <printfmt>
  800415:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800418:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80041b:	e9 4e 02 00 00       	jmp    80066e <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	83 c0 04             	add    $0x4,%eax
  800426:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80042e:	85 d2                	test   %edx,%edx
  800430:	b8 04 26 80 00       	mov    $0x802604,%eax
  800435:	0f 45 c2             	cmovne %edx,%eax
  800438:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80043b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043f:	7e 06                	jle    800447 <vprintfmt+0x19b>
  800441:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800445:	75 0d                	jne    800454 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800447:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80044a:	89 c7                	mov    %eax,%edi
  80044c:	03 45 e0             	add    -0x20(%ebp),%eax
  80044f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800452:	eb 55                	jmp    8004a9 <vprintfmt+0x1fd>
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	ff 75 d8             	push   -0x28(%ebp)
  80045a:	ff 75 cc             	push   -0x34(%ebp)
  80045d:	e8 0a 03 00 00       	call   80076c <strnlen>
  800462:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800465:	29 c1                	sub    %eax,%ecx
  800467:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80046f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800473:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800476:	eb 0f                	jmp    800487 <vprintfmt+0x1db>
					putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	53                   	push   %ebx
  80047c:	ff 75 e0             	push   -0x20(%ebp)
  80047f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	83 ef 01             	sub    $0x1,%edi
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	85 ff                	test   %edi,%edi
  800489:	7f ed                	jg     800478 <vprintfmt+0x1cc>
  80048b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80048e:	85 d2                	test   %edx,%edx
  800490:	b8 00 00 00 00       	mov    $0x0,%eax
  800495:	0f 49 c2             	cmovns %edx,%eax
  800498:	29 c2                	sub    %eax,%edx
  80049a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80049d:	eb a8                	jmp    800447 <vprintfmt+0x19b>
					putch(ch, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	53                   	push   %ebx
  8004a3:	52                   	push   %edx
  8004a4:	ff d6                	call   *%esi
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ac:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ae:	83 c7 01             	add    $0x1,%edi
  8004b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b5:	0f be d0             	movsbl %al,%edx
  8004b8:	85 d2                	test   %edx,%edx
  8004ba:	74 4b                	je     800507 <vprintfmt+0x25b>
  8004bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c0:	78 06                	js     8004c8 <vprintfmt+0x21c>
  8004c2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004c6:	78 1e                	js     8004e6 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004cc:	74 d1                	je     80049f <vprintfmt+0x1f3>
  8004ce:	0f be c0             	movsbl %al,%eax
  8004d1:	83 e8 20             	sub    $0x20,%eax
  8004d4:	83 f8 5e             	cmp    $0x5e,%eax
  8004d7:	76 c6                	jbe    80049f <vprintfmt+0x1f3>
					putch('?', putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	53                   	push   %ebx
  8004dd:	6a 3f                	push   $0x3f
  8004df:	ff d6                	call   *%esi
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	eb c3                	jmp    8004a9 <vprintfmt+0x1fd>
  8004e6:	89 cf                	mov    %ecx,%edi
  8004e8:	eb 0e                	jmp    8004f8 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	6a 20                	push   $0x20
  8004f0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004f2:	83 ef 01             	sub    $0x1,%edi
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	85 ff                	test   %edi,%edi
  8004fa:	7f ee                	jg     8004ea <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004fc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800502:	e9 67 01 00 00       	jmp    80066e <vprintfmt+0x3c2>
  800507:	89 cf                	mov    %ecx,%edi
  800509:	eb ed                	jmp    8004f8 <vprintfmt+0x24c>
	if (lflag >= 2)
  80050b:	83 f9 01             	cmp    $0x1,%ecx
  80050e:	7f 1b                	jg     80052b <vprintfmt+0x27f>
	else if (lflag)
  800510:	85 c9                	test   %ecx,%ecx
  800512:	74 63                	je     800577 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051c:	99                   	cltd   
  80051d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 40 04             	lea    0x4(%eax),%eax
  800526:	89 45 14             	mov    %eax,0x14(%ebp)
  800529:	eb 17                	jmp    800542 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8b 50 04             	mov    0x4(%eax),%edx
  800531:	8b 00                	mov    (%eax),%eax
  800533:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800536:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 40 08             	lea    0x8(%eax),%eax
  80053f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800542:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800545:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800548:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80054d:	85 c9                	test   %ecx,%ecx
  80054f:	0f 89 ff 00 00 00    	jns    800654 <vprintfmt+0x3a8>
				putch('-', putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	6a 2d                	push   $0x2d
  80055b:	ff d6                	call   *%esi
				num = -(long long) num;
  80055d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800560:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800563:	f7 da                	neg    %edx
  800565:	83 d1 00             	adc    $0x0,%ecx
  800568:	f7 d9                	neg    %ecx
  80056a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80056d:	bf 0a 00 00 00       	mov    $0xa,%edi
  800572:	e9 dd 00 00 00       	jmp    800654 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	99                   	cltd   
  800580:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 40 04             	lea    0x4(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
  80058c:	eb b4                	jmp    800542 <vprintfmt+0x296>
	if (lflag >= 2)
  80058e:	83 f9 01             	cmp    $0x1,%ecx
  800591:	7f 1e                	jg     8005b1 <vprintfmt+0x305>
	else if (lflag)
  800593:	85 c9                	test   %ecx,%ecx
  800595:	74 32                	je     8005c9 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 10                	mov    (%eax),%edx
  80059c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a1:	8d 40 04             	lea    0x4(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005ac:	e9 a3 00 00 00       	jmp    800654 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8b 10                	mov    (%eax),%edx
  8005b6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b9:	8d 40 08             	lea    0x8(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005bf:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005c4:	e9 8b 00 00 00       	jmp    800654 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005de:	eb 74                	jmp    800654 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005e0:	83 f9 01             	cmp    $0x1,%ecx
  8005e3:	7f 1b                	jg     800600 <vprintfmt+0x354>
	else if (lflag)
  8005e5:	85 c9                	test   %ecx,%ecx
  8005e7:	74 2c                	je     800615 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f3:	8d 40 04             	lea    0x4(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005f9:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005fe:	eb 54                	jmp    800654 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8b 10                	mov    (%eax),%edx
  800605:	8b 48 04             	mov    0x4(%eax),%ecx
  800608:	8d 40 08             	lea    0x8(%eax),%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80060e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800613:	eb 3f                	jmp    800654 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800625:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80062a:	eb 28                	jmp    800654 <vprintfmt+0x3a8>
			putch('0', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 30                	push   $0x30
  800632:	ff d6                	call   *%esi
			putch('x', putdat);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 78                	push   $0x78
  80063a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800646:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064f:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800654:	83 ec 0c             	sub    $0xc,%esp
  800657:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	ff 75 e0             	push   -0x20(%ebp)
  80065f:	57                   	push   %edi
  800660:	51                   	push   %ecx
  800661:	52                   	push   %edx
  800662:	89 da                	mov    %ebx,%edx
  800664:	89 f0                	mov    %esi,%eax
  800666:	e8 5e fb ff ff       	call   8001c9 <printnum>
			break;
  80066b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800671:	e9 54 fc ff ff       	jmp    8002ca <vprintfmt+0x1e>
	if (lflag >= 2)
  800676:	83 f9 01             	cmp    $0x1,%ecx
  800679:	7f 1b                	jg     800696 <vprintfmt+0x3ea>
	else if (lflag)
  80067b:	85 c9                	test   %ecx,%ecx
  80067d:	74 2c                	je     8006ab <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	b9 00 00 00 00       	mov    $0x0,%ecx
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800694:	eb be                	jmp    800654 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8b 10                	mov    (%eax),%edx
  80069b:	8b 48 04             	mov    0x4(%eax),%ecx
  80069e:	8d 40 08             	lea    0x8(%eax),%eax
  8006a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006a9:	eb a9                	jmp    800654 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b5:	8d 40 04             	lea    0x4(%eax),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bb:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006c0:	eb 92                	jmp    800654 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	6a 25                	push   $0x25
  8006c8:	ff d6                	call   *%esi
			break;
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 9f                	jmp    80066e <vprintfmt+0x3c2>
			putch('%', putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	6a 25                	push   $0x25
  8006d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	89 f8                	mov    %edi,%eax
  8006dc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e0:	74 05                	je     8006e7 <vprintfmt+0x43b>
  8006e2:	83 e8 01             	sub    $0x1,%eax
  8006e5:	eb f5                	jmp    8006dc <vprintfmt+0x430>
  8006e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ea:	eb 82                	jmp    80066e <vprintfmt+0x3c2>

008006ec <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	83 ec 18             	sub    $0x18,%esp
  8006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ff:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800702:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800709:	85 c0                	test   %eax,%eax
  80070b:	74 26                	je     800733 <vsnprintf+0x47>
  80070d:	85 d2                	test   %edx,%edx
  80070f:	7e 22                	jle    800733 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800711:	ff 75 14             	push   0x14(%ebp)
  800714:	ff 75 10             	push   0x10(%ebp)
  800717:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	68 72 02 80 00       	push   $0x800272
  800720:	e8 87 fb ff ff       	call   8002ac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800725:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800728:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072e:	83 c4 10             	add    $0x10,%esp
}
  800731:	c9                   	leave  
  800732:	c3                   	ret    
		return -E_INVAL;
  800733:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800738:	eb f7                	jmp    800731 <vsnprintf+0x45>

0080073a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800740:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800743:	50                   	push   %eax
  800744:	ff 75 10             	push   0x10(%ebp)
  800747:	ff 75 0c             	push   0xc(%ebp)
  80074a:	ff 75 08             	push   0x8(%ebp)
  80074d:	e8 9a ff ff ff       	call   8006ec <vsnprintf>
	va_end(ap);

	return rc;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075a:	b8 00 00 00 00       	mov    $0x0,%eax
  80075f:	eb 03                	jmp    800764 <strlen+0x10>
		n++;
  800761:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800764:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800768:	75 f7                	jne    800761 <strlen+0xd>
	return n;
}
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	eb 03                	jmp    80077f <strnlen+0x13>
		n++;
  80077c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	39 d0                	cmp    %edx,%eax
  800781:	74 08                	je     80078b <strnlen+0x1f>
  800783:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800787:	75 f3                	jne    80077c <strnlen+0x10>
  800789:	89 c2                	mov    %eax,%edx
	return n;
}
  80078b:	89 d0                	mov    %edx,%eax
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	53                   	push   %ebx
  800793:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800796:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800799:	b8 00 00 00 00       	mov    $0x0,%eax
  80079e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007a2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007a5:	83 c0 01             	add    $0x1,%eax
  8007a8:	84 d2                	test   %dl,%dl
  8007aa:	75 f2                	jne    80079e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ac:	89 c8                	mov    %ecx,%eax
  8007ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b1:	c9                   	leave  
  8007b2:	c3                   	ret    

008007b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	83 ec 10             	sub    $0x10,%esp
  8007ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bd:	53                   	push   %ebx
  8007be:	e8 91 ff ff ff       	call   800754 <strlen>
  8007c3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007c6:	ff 75 0c             	push   0xc(%ebp)
  8007c9:	01 d8                	add    %ebx,%eax
  8007cb:	50                   	push   %eax
  8007cc:	e8 be ff ff ff       	call   80078f <strcpy>
	return dst;
}
  8007d1:	89 d8                	mov    %ebx,%eax
  8007d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	56                   	push   %esi
  8007dc:	53                   	push   %ebx
  8007dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e3:	89 f3                	mov    %esi,%ebx
  8007e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e8:	89 f0                	mov    %esi,%eax
  8007ea:	eb 0f                	jmp    8007fb <strncpy+0x23>
		*dst++ = *src;
  8007ec:	83 c0 01             	add    $0x1,%eax
  8007ef:	0f b6 0a             	movzbl (%edx),%ecx
  8007f2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f5:	80 f9 01             	cmp    $0x1,%cl
  8007f8:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007fb:	39 d8                	cmp    %ebx,%eax
  8007fd:	75 ed                	jne    8007ec <strncpy+0x14>
	}
	return ret;
}
  8007ff:	89 f0                	mov    %esi,%eax
  800801:	5b                   	pop    %ebx
  800802:	5e                   	pop    %esi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	8b 75 08             	mov    0x8(%ebp),%esi
  80080d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800810:	8b 55 10             	mov    0x10(%ebp),%edx
  800813:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800815:	85 d2                	test   %edx,%edx
  800817:	74 21                	je     80083a <strlcpy+0x35>
  800819:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081d:	89 f2                	mov    %esi,%edx
  80081f:	eb 09                	jmp    80082a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800821:	83 c1 01             	add    $0x1,%ecx
  800824:	83 c2 01             	add    $0x1,%edx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80082a:	39 c2                	cmp    %eax,%edx
  80082c:	74 09                	je     800837 <strlcpy+0x32>
  80082e:	0f b6 19             	movzbl (%ecx),%ebx
  800831:	84 db                	test   %bl,%bl
  800833:	75 ec                	jne    800821 <strlcpy+0x1c>
  800835:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800837:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083a:	29 f0                	sub    %esi,%eax
}
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800849:	eb 06                	jmp    800851 <strcmp+0x11>
		p++, q++;
  80084b:	83 c1 01             	add    $0x1,%ecx
  80084e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800851:	0f b6 01             	movzbl (%ecx),%eax
  800854:	84 c0                	test   %al,%al
  800856:	74 04                	je     80085c <strcmp+0x1c>
  800858:	3a 02                	cmp    (%edx),%al
  80085a:	74 ef                	je     80084b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085c:	0f b6 c0             	movzbl %al,%eax
  80085f:	0f b6 12             	movzbl (%edx),%edx
  800862:	29 d0                	sub    %edx,%eax
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800870:	89 c3                	mov    %eax,%ebx
  800872:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800875:	eb 06                	jmp    80087d <strncmp+0x17>
		n--, p++, q++;
  800877:	83 c0 01             	add    $0x1,%eax
  80087a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80087d:	39 d8                	cmp    %ebx,%eax
  80087f:	74 18                	je     800899 <strncmp+0x33>
  800881:	0f b6 08             	movzbl (%eax),%ecx
  800884:	84 c9                	test   %cl,%cl
  800886:	74 04                	je     80088c <strncmp+0x26>
  800888:	3a 0a                	cmp    (%edx),%cl
  80088a:	74 eb                	je     800877 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	0f b6 00             	movzbl (%eax),%eax
  80088f:	0f b6 12             	movzbl (%edx),%edx
  800892:	29 d0                	sub    %edx,%eax
}
  800894:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800897:	c9                   	leave  
  800898:	c3                   	ret    
		return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
  80089e:	eb f4                	jmp    800894 <strncmp+0x2e>

008008a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008aa:	eb 03                	jmp    8008af <strchr+0xf>
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	0f b6 10             	movzbl (%eax),%edx
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	74 06                	je     8008bc <strchr+0x1c>
		if (*s == c)
  8008b6:	38 ca                	cmp    %cl,%dl
  8008b8:	75 f2                	jne    8008ac <strchr+0xc>
  8008ba:	eb 05                	jmp    8008c1 <strchr+0x21>
			return (char *) s;
	return 0;
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d0:	38 ca                	cmp    %cl,%dl
  8008d2:	74 09                	je     8008dd <strfind+0x1a>
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	74 05                	je     8008dd <strfind+0x1a>
	for (; *s; s++)
  8008d8:	83 c0 01             	add    $0x1,%eax
  8008db:	eb f0                	jmp    8008cd <strfind+0xa>
			break;
	return (char *) s;
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	74 2f                	je     80091e <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ef:	89 f8                	mov    %edi,%eax
  8008f1:	09 c8                	or     %ecx,%eax
  8008f3:	a8 03                	test   $0x3,%al
  8008f5:	75 21                	jne    800918 <memset+0x39>
		c &= 0xFF;
  8008f7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	c1 e0 08             	shl    $0x8,%eax
  800900:	89 d3                	mov    %edx,%ebx
  800902:	c1 e3 18             	shl    $0x18,%ebx
  800905:	89 d6                	mov    %edx,%esi
  800907:	c1 e6 10             	shl    $0x10,%esi
  80090a:	09 f3                	or     %esi,%ebx
  80090c:	09 da                	or     %ebx,%edx
  80090e:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800910:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800913:	fc                   	cld    
  800914:	f3 ab                	rep stos %eax,%es:(%edi)
  800916:	eb 06                	jmp    80091e <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800918:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091b:	fc                   	cld    
  80091c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091e:	89 f8                	mov    %edi,%eax
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5f                   	pop    %edi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800930:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800933:	39 c6                	cmp    %eax,%esi
  800935:	73 32                	jae    800969 <memmove+0x44>
  800937:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093a:	39 c2                	cmp    %eax,%edx
  80093c:	76 2b                	jbe    800969 <memmove+0x44>
		s += n;
		d += n;
  80093e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800941:	89 d6                	mov    %edx,%esi
  800943:	09 fe                	or     %edi,%esi
  800945:	09 ce                	or     %ecx,%esi
  800947:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094d:	75 0e                	jne    80095d <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094f:	83 ef 04             	sub    $0x4,%edi
  800952:	8d 72 fc             	lea    -0x4(%edx),%esi
  800955:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800958:	fd                   	std    
  800959:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095b:	eb 09                	jmp    800966 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095d:	83 ef 01             	sub    $0x1,%edi
  800960:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800963:	fd                   	std    
  800964:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800966:	fc                   	cld    
  800967:	eb 1a                	jmp    800983 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800969:	89 f2                	mov    %esi,%edx
  80096b:	09 c2                	or     %eax,%edx
  80096d:	09 ca                	or     %ecx,%edx
  80096f:	f6 c2 03             	test   $0x3,%dl
  800972:	75 0a                	jne    80097e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800974:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800977:	89 c7                	mov    %eax,%edi
  800979:	fc                   	cld    
  80097a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097c:	eb 05                	jmp    800983 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80097e:	89 c7                	mov    %eax,%edi
  800980:	fc                   	cld    
  800981:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80098d:	ff 75 10             	push   0x10(%ebp)
  800990:	ff 75 0c             	push   0xc(%ebp)
  800993:	ff 75 08             	push   0x8(%ebp)
  800996:	e8 8a ff ff ff       	call   800925 <memmove>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a8:	89 c6                	mov    %eax,%esi
  8009aa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ad:	eb 06                	jmp    8009b5 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009af:	83 c0 01             	add    $0x1,%eax
  8009b2:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009b5:	39 f0                	cmp    %esi,%eax
  8009b7:	74 14                	je     8009cd <memcmp+0x30>
		if (*s1 != *s2)
  8009b9:	0f b6 08             	movzbl (%eax),%ecx
  8009bc:	0f b6 1a             	movzbl (%edx),%ebx
  8009bf:	38 d9                	cmp    %bl,%cl
  8009c1:	74 ec                	je     8009af <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009c3:	0f b6 c1             	movzbl %cl,%eax
  8009c6:	0f b6 db             	movzbl %bl,%ebx
  8009c9:	29 d8                	sub    %ebx,%eax
  8009cb:	eb 05                	jmp    8009d2 <memcmp+0x35>
	}

	return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e4:	eb 03                	jmp    8009e9 <memfind+0x13>
  8009e6:	83 c0 01             	add    $0x1,%eax
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 04                	jae    8009f1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ed:	38 08                	cmp    %cl,(%eax)
  8009ef:	75 f5                	jne    8009e6 <memfind+0x10>
			break;
	return (void *) s;
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ff:	eb 03                	jmp    800a04 <strtol+0x11>
		s++;
  800a01:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a04:	0f b6 02             	movzbl (%edx),%eax
  800a07:	3c 20                	cmp    $0x20,%al
  800a09:	74 f6                	je     800a01 <strtol+0xe>
  800a0b:	3c 09                	cmp    $0x9,%al
  800a0d:	74 f2                	je     800a01 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a0f:	3c 2b                	cmp    $0x2b,%al
  800a11:	74 2a                	je     800a3d <strtol+0x4a>
	int neg = 0;
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a18:	3c 2d                	cmp    $0x2d,%al
  800a1a:	74 2b                	je     800a47 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a22:	75 0f                	jne    800a33 <strtol+0x40>
  800a24:	80 3a 30             	cmpb   $0x30,(%edx)
  800a27:	74 28                	je     800a51 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a30:	0f 44 d8             	cmove  %eax,%ebx
  800a33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a38:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a3b:	eb 46                	jmp    800a83 <strtol+0x90>
		s++;
  800a3d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a40:	bf 00 00 00 00       	mov    $0x0,%edi
  800a45:	eb d5                	jmp    800a1c <strtol+0x29>
		s++, neg = 1;
  800a47:	83 c2 01             	add    $0x1,%edx
  800a4a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a4f:	eb cb                	jmp    800a1c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a51:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a55:	74 0e                	je     800a65 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a57:	85 db                	test   %ebx,%ebx
  800a59:	75 d8                	jne    800a33 <strtol+0x40>
		s++, base = 8;
  800a5b:	83 c2 01             	add    $0x1,%edx
  800a5e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a63:	eb ce                	jmp    800a33 <strtol+0x40>
		s += 2, base = 16;
  800a65:	83 c2 02             	add    $0x2,%edx
  800a68:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6d:	eb c4                	jmp    800a33 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a6f:	0f be c0             	movsbl %al,%eax
  800a72:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a75:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a78:	7d 3a                	jge    800ab4 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a81:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a83:	0f b6 02             	movzbl (%edx),%eax
  800a86:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 09             	cmp    $0x9,%bl
  800a8e:	76 df                	jbe    800a6f <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a90:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a93:	89 f3                	mov    %esi,%ebx
  800a95:	80 fb 19             	cmp    $0x19,%bl
  800a98:	77 08                	ja     800aa2 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a9a:	0f be c0             	movsbl %al,%eax
  800a9d:	83 e8 57             	sub    $0x57,%eax
  800aa0:	eb d3                	jmp    800a75 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800aa2:	8d 70 bf             	lea    -0x41(%eax),%esi
  800aa5:	89 f3                	mov    %esi,%ebx
  800aa7:	80 fb 19             	cmp    $0x19,%bl
  800aaa:	77 08                	ja     800ab4 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800aac:	0f be c0             	movsbl %al,%eax
  800aaf:	83 e8 37             	sub    $0x37,%eax
  800ab2:	eb c1                	jmp    800a75 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab8:	74 05                	je     800abf <strtol+0xcc>
		*endptr = (char *) s;
  800aba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abd:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800abf:	89 c8                	mov    %ecx,%eax
  800ac1:	f7 d8                	neg    %eax
  800ac3:	85 ff                	test   %edi,%edi
  800ac5:	0f 45 c8             	cmovne %eax,%ecx
}
  800ac8:	89 c8                	mov    %ecx,%eax
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae0:	89 c3                	mov    %eax,%ebx
  800ae2:	89 c7                	mov    %eax,%edi
  800ae4:	89 c6                	mov    %eax,%esi
  800ae6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_cgetc>:

int
sys_cgetc(void)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af3:	ba 00 00 00 00       	mov    $0x0,%edx
  800af8:	b8 01 00 00 00       	mov    $0x1,%eax
  800afd:	89 d1                	mov    %edx,%ecx
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	89 d7                	mov    %edx,%edi
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b22:	89 cb                	mov    %ecx,%ebx
  800b24:	89 cf                	mov    %ecx,%edi
  800b26:	89 ce                	mov    %ecx,%esi
  800b28:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	7f 08                	jg     800b36 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b36:	83 ec 0c             	sub    $0xc,%esp
  800b39:	50                   	push   %eax
  800b3a:	6a 03                	push   $0x3
  800b3c:	68 ff 28 80 00       	push   $0x8028ff
  800b41:	6a 2a                	push   $0x2a
  800b43:	68 1c 29 80 00       	push   $0x80291c
  800b48:	e8 10 17 00 00       	call   80225d <_panic>

00800b4d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5d:	89 d1                	mov    %edx,%ecx
  800b5f:	89 d3                	mov    %edx,%ebx
  800b61:	89 d7                	mov    %edx,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_yield>:

void
sys_yield(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b94:	be 00 00 00 00       	mov    $0x0,%esi
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba7:	89 f7                	mov    %esi,%edi
  800ba9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7f 08                	jg     800bb7 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 04                	push   $0x4
  800bbd:	68 ff 28 80 00       	push   $0x8028ff
  800bc2:	6a 2a                	push   $0x2a
  800bc4:	68 1c 29 80 00       	push   $0x80291c
  800bc9:	e8 8f 16 00 00       	call   80225d <_panic>

00800bce <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	b8 05 00 00 00       	mov    $0x5,%eax
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be8:	8b 75 18             	mov    0x18(%ebp),%esi
  800beb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7f 08                	jg     800bf9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	50                   	push   %eax
  800bfd:	6a 05                	push   $0x5
  800bff:	68 ff 28 80 00       	push   $0x8028ff
  800c04:	6a 2a                	push   $0x2a
  800c06:	68 1c 29 80 00       	push   $0x80291c
  800c0b:	e8 4d 16 00 00       	call   80225d <_panic>

00800c10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	b8 06 00 00 00       	mov    $0x6,%eax
  800c29:	89 df                	mov    %ebx,%edi
  800c2b:	89 de                	mov    %ebx,%esi
  800c2d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7f 08                	jg     800c3b <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	50                   	push   %eax
  800c3f:	6a 06                	push   $0x6
  800c41:	68 ff 28 80 00       	push   $0x8028ff
  800c46:	6a 2a                	push   $0x2a
  800c48:	68 1c 29 80 00       	push   $0x80291c
  800c4d:	e8 0b 16 00 00       	call   80225d <_panic>

00800c52 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7f 08                	jg     800c7d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	83 ec 0c             	sub    $0xc,%esp
  800c80:	50                   	push   %eax
  800c81:	6a 08                	push   $0x8
  800c83:	68 ff 28 80 00       	push   $0x8028ff
  800c88:	6a 2a                	push   $0x2a
  800c8a:	68 1c 29 80 00       	push   $0x80291c
  800c8f:	e8 c9 15 00 00       	call   80225d <_panic>

00800c94 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7f 08                	jg     800cbf <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 09                	push   $0x9
  800cc5:	68 ff 28 80 00       	push   $0x8028ff
  800cca:	6a 2a                	push   $0x2a
  800ccc:	68 1c 29 80 00       	push   $0x80291c
  800cd1:	e8 87 15 00 00       	call   80225d <_panic>

00800cd6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cef:	89 df                	mov    %ebx,%edi
  800cf1:	89 de                	mov    %ebx,%esi
  800cf3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7f 08                	jg     800d01 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 0a                	push   $0xa
  800d07:	68 ff 28 80 00       	push   $0x8028ff
  800d0c:	6a 2a                	push   $0x2a
  800d0e:	68 1c 29 80 00       	push   $0x80291c
  800d13:	e8 45 15 00 00       	call   80225d <_panic>

00800d18 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d29:	be 00 00 00 00       	mov    $0x0,%esi
  800d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d31:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d34:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d51:	89 cb                	mov    %ecx,%ebx
  800d53:	89 cf                	mov    %ecx,%edi
  800d55:	89 ce                	mov    %ecx,%esi
  800d57:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7f 08                	jg     800d65 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 0d                	push   $0xd
  800d6b:	68 ff 28 80 00       	push   $0x8028ff
  800d70:	6a 2a                	push   $0x2a
  800d72:	68 1c 29 80 00       	push   $0x80291c
  800d77:	e8 e1 14 00 00       	call   80225d <_panic>

00800d7c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d8c:	89 d1                	mov    %edx,%ecx
  800d8e:	89 d3                	mov    %edx,%ebx
  800d90:	89 d7                	mov    %edx,%edi
  800d92:	89 d6                	mov    %edx,%esi
  800d94:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dac:	b8 0f 00 00 00       	mov    $0xf,%eax
  800db1:	89 df                	mov    %ebx,%edi
  800db3:	89 de                	mov    %ebx,%esi
  800db5:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	b8 10 00 00 00       	mov    $0x10,%eax
  800dd2:	89 df                	mov    %ebx,%edi
  800dd4:	89 de                	mov    %ebx,%esi
  800dd6:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de5:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800de7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800deb:	0f 84 8e 00 00 00    	je     800e7f <pgfault+0xa2>
  800df1:	89 f0                	mov    %esi,%eax
  800df3:	c1 e8 0c             	shr    $0xc,%eax
  800df6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dfd:	f6 c4 08             	test   $0x8,%ah
  800e00:	74 7d                	je     800e7f <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e02:	e8 46 fd ff ff       	call   800b4d <sys_getenvid>
  800e07:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e09:	83 ec 04             	sub    $0x4,%esp
  800e0c:	6a 07                	push   $0x7
  800e0e:	68 00 f0 7f 00       	push   $0x7ff000
  800e13:	50                   	push   %eax
  800e14:	e8 72 fd ff ff       	call   800b8b <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	78 73                	js     800e93 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e20:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	68 00 10 00 00       	push   $0x1000
  800e2e:	56                   	push   %esi
  800e2f:	68 00 f0 7f 00       	push   $0x7ff000
  800e34:	e8 ec fa ff ff       	call   800925 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e39:	83 c4 08             	add    $0x8,%esp
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
  800e3e:	e8 cd fd ff ff       	call   800c10 <sys_page_unmap>
  800e43:	83 c4 10             	add    $0x10,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	78 5b                	js     800ea5 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e4a:	83 ec 0c             	sub    $0xc,%esp
  800e4d:	6a 07                	push   $0x7
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	68 00 f0 7f 00       	push   $0x7ff000
  800e56:	53                   	push   %ebx
  800e57:	e8 72 fd ff ff       	call   800bce <sys_page_map>
  800e5c:	83 c4 20             	add    $0x20,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	78 54                	js     800eb7 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	68 00 f0 7f 00       	push   $0x7ff000
  800e6b:	53                   	push   %ebx
  800e6c:	e8 9f fd ff ff       	call   800c10 <sys_page_unmap>
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	85 c0                	test   %eax,%eax
  800e76:	78 51                	js     800ec9 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e7f:	83 ec 04             	sub    $0x4,%esp
  800e82:	68 2c 29 80 00       	push   $0x80292c
  800e87:	6a 1d                	push   $0x1d
  800e89:	68 a8 29 80 00       	push   $0x8029a8
  800e8e:	e8 ca 13 00 00       	call   80225d <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e93:	50                   	push   %eax
  800e94:	68 64 29 80 00       	push   $0x802964
  800e99:	6a 29                	push   $0x29
  800e9b:	68 a8 29 80 00       	push   $0x8029a8
  800ea0:	e8 b8 13 00 00       	call   80225d <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ea5:	50                   	push   %eax
  800ea6:	68 88 29 80 00       	push   $0x802988
  800eab:	6a 2e                	push   $0x2e
  800ead:	68 a8 29 80 00       	push   $0x8029a8
  800eb2:	e8 a6 13 00 00       	call   80225d <_panic>
		panic("pgfault: page map failed (%e)", r);
  800eb7:	50                   	push   %eax
  800eb8:	68 b3 29 80 00       	push   $0x8029b3
  800ebd:	6a 30                	push   $0x30
  800ebf:	68 a8 29 80 00       	push   $0x8029a8
  800ec4:	e8 94 13 00 00       	call   80225d <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ec9:	50                   	push   %eax
  800eca:	68 88 29 80 00       	push   $0x802988
  800ecf:	6a 32                	push   $0x32
  800ed1:	68 a8 29 80 00       	push   $0x8029a8
  800ed6:	e8 82 13 00 00       	call   80225d <_panic>

00800edb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800ee4:	68 dd 0d 80 00       	push   $0x800ddd
  800ee9:	e8 b5 13 00 00       	call   8022a3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eee:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef3:	cd 30                	int    $0x30
  800ef5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	78 2d                	js     800f2c <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800eff:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f04:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f08:	75 73                	jne    800f7d <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f0a:	e8 3e fc ff ff       	call   800b4d <sys_getenvid>
  800f0f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f14:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f17:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f1c:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800f21:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f27:	5b                   	pop    %ebx
  800f28:	5e                   	pop    %esi
  800f29:	5f                   	pop    %edi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f2c:	50                   	push   %eax
  800f2d:	68 d1 29 80 00       	push   $0x8029d1
  800f32:	6a 78                	push   $0x78
  800f34:	68 a8 29 80 00       	push   $0x8029a8
  800f39:	e8 1f 13 00 00       	call   80225d <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	ff 75 e4             	push   -0x1c(%ebp)
  800f44:	57                   	push   %edi
  800f45:	ff 75 dc             	push   -0x24(%ebp)
  800f48:	57                   	push   %edi
  800f49:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f4c:	56                   	push   %esi
  800f4d:	e8 7c fc ff ff       	call   800bce <sys_page_map>
	if(r<0) return r;
  800f52:	83 c4 20             	add    $0x20,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	78 cb                	js     800f24 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f59:	83 ec 0c             	sub    $0xc,%esp
  800f5c:	ff 75 e4             	push   -0x1c(%ebp)
  800f5f:	57                   	push   %edi
  800f60:	56                   	push   %esi
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	e8 66 fc ff ff       	call   800bce <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f68:	83 c4 20             	add    $0x20,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	78 76                	js     800fe5 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f6f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f75:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f7b:	74 75                	je     800ff2 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f7d:	89 d8                	mov    %ebx,%eax
  800f7f:	c1 e8 16             	shr    $0x16,%eax
  800f82:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f89:	a8 01                	test   $0x1,%al
  800f8b:	74 e2                	je     800f6f <fork+0x94>
  800f8d:	89 de                	mov    %ebx,%esi
  800f8f:	c1 ee 0c             	shr    $0xc,%esi
  800f92:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f99:	a8 01                	test   $0x1,%al
  800f9b:	74 d2                	je     800f6f <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  800f9d:	e8 ab fb ff ff       	call   800b4d <sys_getenvid>
  800fa2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800fa5:	89 f7                	mov    %esi,%edi
  800fa7:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800faa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb1:	89 c1                	mov    %eax,%ecx
  800fb3:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800fb9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800fbc:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800fc3:	f6 c6 04             	test   $0x4,%dh
  800fc6:	0f 85 72 ff ff ff    	jne    800f3e <fork+0x63>
		perm &= ~PTE_W;
  800fcc:	25 05 0e 00 00       	and    $0xe05,%eax
  800fd1:	80 cc 08             	or     $0x8,%ah
  800fd4:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800fda:	0f 44 c1             	cmove  %ecx,%eax
  800fdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fe0:	e9 59 ff ff ff       	jmp    800f3e <fork+0x63>
  800fe5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fea:	0f 4f c2             	cmovg  %edx,%eax
  800fed:	e9 32 ff ff ff       	jmp    800f24 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800ff2:	83 ec 04             	sub    $0x4,%esp
  800ff5:	6a 07                	push   $0x7
  800ff7:	68 00 f0 bf ee       	push   $0xeebff000
  800ffc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800fff:	57                   	push   %edi
  801000:	e8 86 fb ff ff       	call   800b8b <sys_page_alloc>
	if(r<0) return r;
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	0f 88 14 ff ff ff    	js     800f24 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801010:	83 ec 08             	sub    $0x8,%esp
  801013:	68 19 23 80 00       	push   $0x802319
  801018:	57                   	push   %edi
  801019:	e8 b8 fc ff ff       	call   800cd6 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	0f 88 fb fe ff ff    	js     800f24 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801029:	83 ec 08             	sub    $0x8,%esp
  80102c:	6a 02                	push   $0x2
  80102e:	57                   	push   %edi
  80102f:	e8 1e fc ff ff       	call   800c52 <sys_env_set_status>
	if(r<0) return r;
  801034:	83 c4 10             	add    $0x10,%esp
	return envid;
  801037:	85 c0                	test   %eax,%eax
  801039:	0f 49 c7             	cmovns %edi,%eax
  80103c:	e9 e3 fe ff ff       	jmp    800f24 <fork+0x49>

00801041 <sfork>:

// Challenge!
int
sfork(void)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801047:	68 e1 29 80 00       	push   $0x8029e1
  80104c:	68 a1 00 00 00       	push   $0xa1
  801051:	68 a8 29 80 00       	push   $0x8029a8
  801056:	e8 02 12 00 00       	call   80225d <_panic>

0080105b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	8b 75 08             	mov    0x8(%ebp),%esi
  801063:	8b 45 0c             	mov    0xc(%ebp),%eax
  801066:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801069:	85 c0                	test   %eax,%eax
  80106b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801070:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801073:	83 ec 0c             	sub    $0xc,%esp
  801076:	50                   	push   %eax
  801077:	e8 bf fc ff ff       	call   800d3b <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	85 f6                	test   %esi,%esi
  801081:	74 14                	je     801097 <ipc_recv+0x3c>
  801083:	ba 00 00 00 00       	mov    $0x0,%edx
  801088:	85 c0                	test   %eax,%eax
  80108a:	78 09                	js     801095 <ipc_recv+0x3a>
  80108c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801092:	8b 52 74             	mov    0x74(%edx),%edx
  801095:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801097:	85 db                	test   %ebx,%ebx
  801099:	74 14                	je     8010af <ipc_recv+0x54>
  80109b:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 09                	js     8010ad <ipc_recv+0x52>
  8010a4:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010aa:	8b 52 78             	mov    0x78(%edx),%edx
  8010ad:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	78 08                	js     8010bb <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8010b3:	a1 00 40 80 00       	mov    0x804000,%eax
  8010b8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010be:	5b                   	pop    %ebx
  8010bf:	5e                   	pop    %esi
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8010d4:	85 db                	test   %ebx,%ebx
  8010d6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010db:	0f 44 d8             	cmove  %eax,%ebx
  8010de:	eb 05                	jmp    8010e5 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8010e0:	e8 87 fa ff ff       	call   800b6c <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8010e5:	ff 75 14             	push   0x14(%ebp)
  8010e8:	53                   	push   %ebx
  8010e9:	56                   	push   %esi
  8010ea:	57                   	push   %edi
  8010eb:	e8 28 fc ff ff       	call   800d18 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010f6:	74 e8                	je     8010e0 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	78 08                	js     801104 <ipc_send+0x42>
	}while (r<0);

}
  8010fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ff:	5b                   	pop    %ebx
  801100:	5e                   	pop    %esi
  801101:	5f                   	pop    %edi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801104:	50                   	push   %eax
  801105:	68 f7 29 80 00       	push   $0x8029f7
  80110a:	6a 3d                	push   $0x3d
  80110c:	68 0b 2a 80 00       	push   $0x802a0b
  801111:	e8 47 11 00 00       	call   80225d <_panic>

00801116 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80111c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801121:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801124:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80112a:	8b 52 50             	mov    0x50(%edx),%edx
  80112d:	39 ca                	cmp    %ecx,%edx
  80112f:	74 11                	je     801142 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801131:	83 c0 01             	add    $0x1,%eax
  801134:	3d 00 04 00 00       	cmp    $0x400,%eax
  801139:	75 e6                	jne    801121 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80113b:	b8 00 00 00 00       	mov    $0x0,%eax
  801140:	eb 0b                	jmp    80114d <ipc_find_env+0x37>
			return envs[i].env_id;
  801142:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801145:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80114a:	8b 40 48             	mov    0x48(%eax),%eax
}
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	05 00 00 00 30       	add    $0x30000000,%eax
  80115a:	c1 e8 0c             	shr    $0xc,%eax
}
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80116a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80116f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117e:	89 c2                	mov    %eax,%edx
  801180:	c1 ea 16             	shr    $0x16,%edx
  801183:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118a:	f6 c2 01             	test   $0x1,%dl
  80118d:	74 29                	je     8011b8 <fd_alloc+0x42>
  80118f:	89 c2                	mov    %eax,%edx
  801191:	c1 ea 0c             	shr    $0xc,%edx
  801194:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119b:	f6 c2 01             	test   $0x1,%dl
  80119e:	74 18                	je     8011b8 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011a0:	05 00 10 00 00       	add    $0x1000,%eax
  8011a5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011aa:	75 d2                	jne    80117e <fd_alloc+0x8>
  8011ac:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8011b1:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8011b6:	eb 05                	jmp    8011bd <fd_alloc+0x47>
			return 0;
  8011b8:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8011bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c0:	89 02                	mov    %eax,(%edx)
}
  8011c2:	89 c8                	mov    %ecx,%eax
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011cc:	83 f8 1f             	cmp    $0x1f,%eax
  8011cf:	77 30                	ja     801201 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d1:	c1 e0 0c             	shl    $0xc,%eax
  8011d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d9:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8011df:	f6 c2 01             	test   $0x1,%dl
  8011e2:	74 24                	je     801208 <fd_lookup+0x42>
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	c1 ea 0c             	shr    $0xc,%edx
  8011e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f0:	f6 c2 01             	test   $0x1,%dl
  8011f3:	74 1a                	je     80120f <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f8:	89 02                	mov    %eax,(%edx)
	return 0;
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    
		return -E_INVAL;
  801201:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801206:	eb f7                	jmp    8011ff <fd_lookup+0x39>
		return -E_INVAL;
  801208:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120d:	eb f0                	jmp    8011ff <fd_lookup+0x39>
  80120f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801214:	eb e9                	jmp    8011ff <fd_lookup+0x39>

00801216 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	53                   	push   %ebx
  80121a:	83 ec 04             	sub    $0x4,%esp
  80121d:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801220:	b8 00 00 00 00       	mov    $0x0,%eax
  801225:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80122a:	39 13                	cmp    %edx,(%ebx)
  80122c:	74 37                	je     801265 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80122e:	83 c0 01             	add    $0x1,%eax
  801231:	8b 1c 85 94 2a 80 00 	mov    0x802a94(,%eax,4),%ebx
  801238:	85 db                	test   %ebx,%ebx
  80123a:	75 ee                	jne    80122a <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80123c:	a1 00 40 80 00       	mov    0x804000,%eax
  801241:	8b 40 48             	mov    0x48(%eax),%eax
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	52                   	push   %edx
  801248:	50                   	push   %eax
  801249:	68 18 2a 80 00       	push   $0x802a18
  80124e:	e8 62 ef ff ff       	call   8001b5 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80125b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125e:	89 1a                	mov    %ebx,(%edx)
}
  801260:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801263:	c9                   	leave  
  801264:	c3                   	ret    
			return 0;
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
  80126a:	eb ef                	jmp    80125b <dev_lookup+0x45>

0080126c <fd_close>:
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	57                   	push   %edi
  801270:	56                   	push   %esi
  801271:	53                   	push   %ebx
  801272:	83 ec 24             	sub    $0x24,%esp
  801275:	8b 75 08             	mov    0x8(%ebp),%esi
  801278:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80127e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80127f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801285:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801288:	50                   	push   %eax
  801289:	e8 38 ff ff ff       	call   8011c6 <fd_lookup>
  80128e:	89 c3                	mov    %eax,%ebx
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 05                	js     80129c <fd_close+0x30>
	    || fd != fd2)
  801297:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80129a:	74 16                	je     8012b2 <fd_close+0x46>
		return (must_exist ? r : 0);
  80129c:	89 f8                	mov    %edi,%eax
  80129e:	84 c0                	test   %al,%al
  8012a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a5:	0f 44 d8             	cmove  %eax,%ebx
}
  8012a8:	89 d8                	mov    %ebx,%eax
  8012aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5f                   	pop    %edi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012b8:	50                   	push   %eax
  8012b9:	ff 36                	push   (%esi)
  8012bb:	e8 56 ff ff ff       	call   801216 <dev_lookup>
  8012c0:	89 c3                	mov    %eax,%ebx
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 1a                	js     8012e3 <fd_close+0x77>
		if (dev->dev_close)
  8012c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012cc:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	74 0b                	je     8012e3 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8012d8:	83 ec 0c             	sub    $0xc,%esp
  8012db:	56                   	push   %esi
  8012dc:	ff d0                	call   *%eax
  8012de:	89 c3                	mov    %eax,%ebx
  8012e0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012e3:	83 ec 08             	sub    $0x8,%esp
  8012e6:	56                   	push   %esi
  8012e7:	6a 00                	push   $0x0
  8012e9:	e8 22 f9 ff ff       	call   800c10 <sys_page_unmap>
	return r;
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	eb b5                	jmp    8012a8 <fd_close+0x3c>

008012f3 <close>:

int
close(int fdnum)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fc:	50                   	push   %eax
  8012fd:	ff 75 08             	push   0x8(%ebp)
  801300:	e8 c1 fe ff ff       	call   8011c6 <fd_lookup>
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	79 02                	jns    80130e <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    
		return fd_close(fd, 1);
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	6a 01                	push   $0x1
  801313:	ff 75 f4             	push   -0xc(%ebp)
  801316:	e8 51 ff ff ff       	call   80126c <fd_close>
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	eb ec                	jmp    80130c <close+0x19>

00801320 <close_all>:

void
close_all(void)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	53                   	push   %ebx
  801324:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801327:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80132c:	83 ec 0c             	sub    $0xc,%esp
  80132f:	53                   	push   %ebx
  801330:	e8 be ff ff ff       	call   8012f3 <close>
	for (i = 0; i < MAXFD; i++)
  801335:	83 c3 01             	add    $0x1,%ebx
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	83 fb 20             	cmp    $0x20,%ebx
  80133e:	75 ec                	jne    80132c <close_all+0xc>
}
  801340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	57                   	push   %edi
  801349:	56                   	push   %esi
  80134a:	53                   	push   %ebx
  80134b:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80134e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801351:	50                   	push   %eax
  801352:	ff 75 08             	push   0x8(%ebp)
  801355:	e8 6c fe ff ff       	call   8011c6 <fd_lookup>
  80135a:	89 c3                	mov    %eax,%ebx
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 7f                	js     8013e2 <dup+0x9d>
		return r;
	close(newfdnum);
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	ff 75 0c             	push   0xc(%ebp)
  801369:	e8 85 ff ff ff       	call   8012f3 <close>

	newfd = INDEX2FD(newfdnum);
  80136e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801371:	c1 e6 0c             	shl    $0xc,%esi
  801374:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80137a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80137d:	89 3c 24             	mov    %edi,(%esp)
  801380:	e8 da fd ff ff       	call   80115f <fd2data>
  801385:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801387:	89 34 24             	mov    %esi,(%esp)
  80138a:	e8 d0 fd ff ff       	call   80115f <fd2data>
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801395:	89 d8                	mov    %ebx,%eax
  801397:	c1 e8 16             	shr    $0x16,%eax
  80139a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a1:	a8 01                	test   $0x1,%al
  8013a3:	74 11                	je     8013b6 <dup+0x71>
  8013a5:	89 d8                	mov    %ebx,%eax
  8013a7:	c1 e8 0c             	shr    $0xc,%eax
  8013aa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b1:	f6 c2 01             	test   $0x1,%dl
  8013b4:	75 36                	jne    8013ec <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b6:	89 f8                	mov    %edi,%eax
  8013b8:	c1 e8 0c             	shr    $0xc,%eax
  8013bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c2:	83 ec 0c             	sub    $0xc,%esp
  8013c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ca:	50                   	push   %eax
  8013cb:	56                   	push   %esi
  8013cc:	6a 00                	push   $0x0
  8013ce:	57                   	push   %edi
  8013cf:	6a 00                	push   $0x0
  8013d1:	e8 f8 f7 ff ff       	call   800bce <sys_page_map>
  8013d6:	89 c3                	mov    %eax,%ebx
  8013d8:	83 c4 20             	add    $0x20,%esp
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 33                	js     801412 <dup+0xcd>
		goto err;

	return newfdnum;
  8013df:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013e2:	89 d8                	mov    %ebx,%eax
  8013e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5f                   	pop    %edi
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013fb:	50                   	push   %eax
  8013fc:	ff 75 d4             	push   -0x2c(%ebp)
  8013ff:	6a 00                	push   $0x0
  801401:	53                   	push   %ebx
  801402:	6a 00                	push   $0x0
  801404:	e8 c5 f7 ff ff       	call   800bce <sys_page_map>
  801409:	89 c3                	mov    %eax,%ebx
  80140b:	83 c4 20             	add    $0x20,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	79 a4                	jns    8013b6 <dup+0x71>
	sys_page_unmap(0, newfd);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	56                   	push   %esi
  801416:	6a 00                	push   $0x0
  801418:	e8 f3 f7 ff ff       	call   800c10 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80141d:	83 c4 08             	add    $0x8,%esp
  801420:	ff 75 d4             	push   -0x2c(%ebp)
  801423:	6a 00                	push   $0x0
  801425:	e8 e6 f7 ff ff       	call   800c10 <sys_page_unmap>
	return r;
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	eb b3                	jmp    8013e2 <dup+0x9d>

0080142f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
  801434:	83 ec 18             	sub    $0x18,%esp
  801437:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	56                   	push   %esi
  80143f:	e8 82 fd ff ff       	call   8011c6 <fd_lookup>
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	85 c0                	test   %eax,%eax
  801449:	78 3c                	js     801487 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144b:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	ff 33                	push   (%ebx)
  801457:	e8 ba fd ff ff       	call   801216 <dev_lookup>
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 24                	js     801487 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801463:	8b 43 08             	mov    0x8(%ebx),%eax
  801466:	83 e0 03             	and    $0x3,%eax
  801469:	83 f8 01             	cmp    $0x1,%eax
  80146c:	74 20                	je     80148e <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80146e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801471:	8b 40 08             	mov    0x8(%eax),%eax
  801474:	85 c0                	test   %eax,%eax
  801476:	74 37                	je     8014af <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	ff 75 10             	push   0x10(%ebp)
  80147e:	ff 75 0c             	push   0xc(%ebp)
  801481:	53                   	push   %ebx
  801482:	ff d0                	call   *%eax
  801484:	83 c4 10             	add    $0x10,%esp
}
  801487:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148a:	5b                   	pop    %ebx
  80148b:	5e                   	pop    %esi
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80148e:	a1 00 40 80 00       	mov    0x804000,%eax
  801493:	8b 40 48             	mov    0x48(%eax),%eax
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	56                   	push   %esi
  80149a:	50                   	push   %eax
  80149b:	68 59 2a 80 00       	push   $0x802a59
  8014a0:	e8 10 ed ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ad:	eb d8                	jmp    801487 <read+0x58>
		return -E_NOT_SUPP;
  8014af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014b4:	eb d1                	jmp    801487 <read+0x58>

008014b6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	57                   	push   %edi
  8014ba:	56                   	push   %esi
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 0c             	sub    $0xc,%esp
  8014bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ca:	eb 02                	jmp    8014ce <readn+0x18>
  8014cc:	01 c3                	add    %eax,%ebx
  8014ce:	39 f3                	cmp    %esi,%ebx
  8014d0:	73 21                	jae    8014f3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	89 f0                	mov    %esi,%eax
  8014d7:	29 d8                	sub    %ebx,%eax
  8014d9:	50                   	push   %eax
  8014da:	89 d8                	mov    %ebx,%eax
  8014dc:	03 45 0c             	add    0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	57                   	push   %edi
  8014e1:	e8 49 ff ff ff       	call   80142f <read>
		if (m < 0)
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 04                	js     8014f1 <readn+0x3b>
			return m;
		if (m == 0)
  8014ed:	75 dd                	jne    8014cc <readn+0x16>
  8014ef:	eb 02                	jmp    8014f3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014f3:	89 d8                	mov    %ebx,%eax
  8014f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5f                   	pop    %edi
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	56                   	push   %esi
  801501:	53                   	push   %ebx
  801502:	83 ec 18             	sub    $0x18,%esp
  801505:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801508:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	53                   	push   %ebx
  80150d:	e8 b4 fc ff ff       	call   8011c6 <fd_lookup>
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 37                	js     801550 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801519:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	ff 36                	push   (%esi)
  801525:	e8 ec fc ff ff       	call   801216 <dev_lookup>
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 1f                	js     801550 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801531:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801535:	74 20                	je     801557 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801537:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153a:	8b 40 0c             	mov    0xc(%eax),%eax
  80153d:	85 c0                	test   %eax,%eax
  80153f:	74 37                	je     801578 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801541:	83 ec 04             	sub    $0x4,%esp
  801544:	ff 75 10             	push   0x10(%ebp)
  801547:	ff 75 0c             	push   0xc(%ebp)
  80154a:	56                   	push   %esi
  80154b:	ff d0                	call   *%eax
  80154d:	83 c4 10             	add    $0x10,%esp
}
  801550:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801553:	5b                   	pop    %ebx
  801554:	5e                   	pop    %esi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801557:	a1 00 40 80 00       	mov    0x804000,%eax
  80155c:	8b 40 48             	mov    0x48(%eax),%eax
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	53                   	push   %ebx
  801563:	50                   	push   %eax
  801564:	68 75 2a 80 00       	push   $0x802a75
  801569:	e8 47 ec ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801576:	eb d8                	jmp    801550 <write+0x53>
		return -E_NOT_SUPP;
  801578:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80157d:	eb d1                	jmp    801550 <write+0x53>

0080157f <seek>:

int
seek(int fdnum, off_t offset)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801585:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	ff 75 08             	push   0x8(%ebp)
  80158c:	e8 35 fc ff ff       	call   8011c6 <fd_lookup>
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 0e                	js     8015a6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801598:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 18             	sub    $0x18,%esp
  8015b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	53                   	push   %ebx
  8015b8:	e8 09 fc ff ff       	call   8011c6 <fd_lookup>
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 34                	js     8015f8 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	ff 36                	push   (%esi)
  8015d0:	e8 41 fc ff ff       	call   801216 <dev_lookup>
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 1c                	js     8015f8 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015dc:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015e0:	74 1d                	je     8015ff <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e5:	8b 40 18             	mov    0x18(%eax),%eax
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	74 34                	je     801620 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	ff 75 0c             	push   0xc(%ebp)
  8015f2:	56                   	push   %esi
  8015f3:	ff d0                	call   *%eax
  8015f5:	83 c4 10             	add    $0x10,%esp
}
  8015f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fb:	5b                   	pop    %ebx
  8015fc:	5e                   	pop    %esi
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015ff:	a1 00 40 80 00       	mov    0x804000,%eax
  801604:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	53                   	push   %ebx
  80160b:	50                   	push   %eax
  80160c:	68 38 2a 80 00       	push   $0x802a38
  801611:	e8 9f eb ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80161e:	eb d8                	jmp    8015f8 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801620:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801625:	eb d1                	jmp    8015f8 <ftruncate+0x50>

00801627 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	56                   	push   %esi
  80162b:	53                   	push   %ebx
  80162c:	83 ec 18             	sub    $0x18,%esp
  80162f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801632:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	ff 75 08             	push   0x8(%ebp)
  801639:	e8 88 fb ff ff       	call   8011c6 <fd_lookup>
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	85 c0                	test   %eax,%eax
  801643:	78 49                	js     80168e <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801645:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	ff 36                	push   (%esi)
  801651:	e8 c0 fb ff ff       	call   801216 <dev_lookup>
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 31                	js     80168e <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80165d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801660:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801664:	74 2f                	je     801695 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801666:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801669:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801670:	00 00 00 
	stat->st_isdir = 0;
  801673:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167a:	00 00 00 
	stat->st_dev = dev;
  80167d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	53                   	push   %ebx
  801687:	56                   	push   %esi
  801688:	ff 50 14             	call   *0x14(%eax)
  80168b:	83 c4 10             	add    $0x10,%esp
}
  80168e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801691:	5b                   	pop    %ebx
  801692:	5e                   	pop    %esi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    
		return -E_NOT_SUPP;
  801695:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80169a:	eb f2                	jmp    80168e <fstat+0x67>

0080169c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	6a 00                	push   $0x0
  8016a6:	ff 75 08             	push   0x8(%ebp)
  8016a9:	e8 e4 01 00 00       	call   801892 <open>
  8016ae:	89 c3                	mov    %eax,%ebx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 1b                	js     8016d2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016b7:	83 ec 08             	sub    $0x8,%esp
  8016ba:	ff 75 0c             	push   0xc(%ebp)
  8016bd:	50                   	push   %eax
  8016be:	e8 64 ff ff ff       	call   801627 <fstat>
  8016c3:	89 c6                	mov    %eax,%esi
	close(fd);
  8016c5:	89 1c 24             	mov    %ebx,(%esp)
  8016c8:	e8 26 fc ff ff       	call   8012f3 <close>
	return r;
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	89 f3                	mov    %esi,%ebx
}
  8016d2:	89 d8                	mov    %ebx,%eax
  8016d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d7:	5b                   	pop    %ebx
  8016d8:	5e                   	pop    %esi
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    

008016db <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	89 c6                	mov    %eax,%esi
  8016e2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016e4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016eb:	74 27                	je     801714 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ed:	6a 07                	push   $0x7
  8016ef:	68 00 50 80 00       	push   $0x805000
  8016f4:	56                   	push   %esi
  8016f5:	ff 35 00 60 80 00    	push   0x806000
  8016fb:	e8 c2 f9 ff ff       	call   8010c2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801700:	83 c4 0c             	add    $0xc,%esp
  801703:	6a 00                	push   $0x0
  801705:	53                   	push   %ebx
  801706:	6a 00                	push   $0x0
  801708:	e8 4e f9 ff ff       	call   80105b <ipc_recv>
}
  80170d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801710:	5b                   	pop    %ebx
  801711:	5e                   	pop    %esi
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801714:	83 ec 0c             	sub    $0xc,%esp
  801717:	6a 01                	push   $0x1
  801719:	e8 f8 f9 ff ff       	call   801116 <ipc_find_env>
  80171e:	a3 00 60 80 00       	mov    %eax,0x806000
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	eb c5                	jmp    8016ed <fsipc+0x12>

00801728 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	8b 40 0c             	mov    0xc(%eax),%eax
  801734:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801739:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801741:	ba 00 00 00 00       	mov    $0x0,%edx
  801746:	b8 02 00 00 00       	mov    $0x2,%eax
  80174b:	e8 8b ff ff ff       	call   8016db <fsipc>
}
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <devfile_flush>:
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	8b 40 0c             	mov    0xc(%eax),%eax
  80175e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801763:	ba 00 00 00 00       	mov    $0x0,%edx
  801768:	b8 06 00 00 00       	mov    $0x6,%eax
  80176d:	e8 69 ff ff ff       	call   8016db <fsipc>
}
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <devfile_stat>:
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	53                   	push   %ebx
  801778:	83 ec 04             	sub    $0x4,%esp
  80177b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 05 00 00 00       	mov    $0x5,%eax
  801793:	e8 43 ff ff ff       	call   8016db <fsipc>
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 2c                	js     8017c8 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80179c:	83 ec 08             	sub    $0x8,%esp
  80179f:	68 00 50 80 00       	push   $0x805000
  8017a4:	53                   	push   %ebx
  8017a5:	e8 e5 ef ff ff       	call   80078f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017aa:	a1 80 50 80 00       	mov    0x805080,%eax
  8017af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017b5:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <devfile_write>:
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 0c             	sub    $0xc,%esp
  8017d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017db:	39 d0                	cmp    %edx,%eax
  8017dd:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e3:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017ec:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017f1:	50                   	push   %eax
  8017f2:	ff 75 0c             	push   0xc(%ebp)
  8017f5:	68 08 50 80 00       	push   $0x805008
  8017fa:	e8 26 f1 ff ff       	call   800925 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8017ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801804:	b8 04 00 00 00       	mov    $0x4,%eax
  801809:	e8 cd fe ff ff       	call   8016db <fsipc>
}
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <devfile_read>:
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	8b 40 0c             	mov    0xc(%eax),%eax
  80181e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801823:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801829:	ba 00 00 00 00       	mov    $0x0,%edx
  80182e:	b8 03 00 00 00       	mov    $0x3,%eax
  801833:	e8 a3 fe ff ff       	call   8016db <fsipc>
  801838:	89 c3                	mov    %eax,%ebx
  80183a:	85 c0                	test   %eax,%eax
  80183c:	78 1f                	js     80185d <devfile_read+0x4d>
	assert(r <= n);
  80183e:	39 f0                	cmp    %esi,%eax
  801840:	77 24                	ja     801866 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801842:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801847:	7f 33                	jg     80187c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801849:	83 ec 04             	sub    $0x4,%esp
  80184c:	50                   	push   %eax
  80184d:	68 00 50 80 00       	push   $0x805000
  801852:	ff 75 0c             	push   0xc(%ebp)
  801855:	e8 cb f0 ff ff       	call   800925 <memmove>
	return r;
  80185a:	83 c4 10             	add    $0x10,%esp
}
  80185d:	89 d8                	mov    %ebx,%eax
  80185f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    
	assert(r <= n);
  801866:	68 a8 2a 80 00       	push   $0x802aa8
  80186b:	68 af 2a 80 00       	push   $0x802aaf
  801870:	6a 7c                	push   $0x7c
  801872:	68 c4 2a 80 00       	push   $0x802ac4
  801877:	e8 e1 09 00 00       	call   80225d <_panic>
	assert(r <= PGSIZE);
  80187c:	68 cf 2a 80 00       	push   $0x802acf
  801881:	68 af 2a 80 00       	push   $0x802aaf
  801886:	6a 7d                	push   $0x7d
  801888:	68 c4 2a 80 00       	push   $0x802ac4
  80188d:	e8 cb 09 00 00       	call   80225d <_panic>

00801892 <open>:
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	56                   	push   %esi
  801896:	53                   	push   %ebx
  801897:	83 ec 1c             	sub    $0x1c,%esp
  80189a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80189d:	56                   	push   %esi
  80189e:	e8 b1 ee ff ff       	call   800754 <strlen>
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018ab:	7f 6c                	jg     801919 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018ad:	83 ec 0c             	sub    $0xc,%esp
  8018b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b3:	50                   	push   %eax
  8018b4:	e8 bd f8 ff ff       	call   801176 <fd_alloc>
  8018b9:	89 c3                	mov    %eax,%ebx
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	78 3c                	js     8018fe <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	56                   	push   %esi
  8018c6:	68 00 50 80 00       	push   $0x805000
  8018cb:	e8 bf ee ff ff       	call   80078f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018db:	b8 01 00 00 00       	mov    $0x1,%eax
  8018e0:	e8 f6 fd ff ff       	call   8016db <fsipc>
  8018e5:	89 c3                	mov    %eax,%ebx
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 19                	js     801907 <open+0x75>
	return fd2num(fd);
  8018ee:	83 ec 0c             	sub    $0xc,%esp
  8018f1:	ff 75 f4             	push   -0xc(%ebp)
  8018f4:	e8 56 f8 ff ff       	call   80114f <fd2num>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	83 c4 10             	add    $0x10,%esp
}
  8018fe:	89 d8                	mov    %ebx,%eax
  801900:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801903:	5b                   	pop    %ebx
  801904:	5e                   	pop    %esi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    
		fd_close(fd, 0);
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	6a 00                	push   $0x0
  80190c:	ff 75 f4             	push   -0xc(%ebp)
  80190f:	e8 58 f9 ff ff       	call   80126c <fd_close>
		return r;
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	eb e5                	jmp    8018fe <open+0x6c>
		return -E_BAD_PATH;
  801919:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80191e:	eb de                	jmp    8018fe <open+0x6c>

00801920 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801926:	ba 00 00 00 00       	mov    $0x0,%edx
  80192b:	b8 08 00 00 00       	mov    $0x8,%eax
  801930:	e8 a6 fd ff ff       	call   8016db <fsipc>
}
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80193d:	68 db 2a 80 00       	push   $0x802adb
  801942:	ff 75 0c             	push   0xc(%ebp)
  801945:	e8 45 ee ff ff       	call   80078f <strcpy>
	return 0;
}
  80194a:	b8 00 00 00 00       	mov    $0x0,%eax
  80194f:	c9                   	leave  
  801950:	c3                   	ret    

00801951 <devsock_close>:
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	53                   	push   %ebx
  801955:	83 ec 10             	sub    $0x10,%esp
  801958:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80195b:	53                   	push   %ebx
  80195c:	e8 de 09 00 00       	call   80233f <pageref>
  801961:	89 c2                	mov    %eax,%edx
  801963:	83 c4 10             	add    $0x10,%esp
		return 0;
  801966:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80196b:	83 fa 01             	cmp    $0x1,%edx
  80196e:	74 05                	je     801975 <devsock_close+0x24>
}
  801970:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801973:	c9                   	leave  
  801974:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801975:	83 ec 0c             	sub    $0xc,%esp
  801978:	ff 73 0c             	push   0xc(%ebx)
  80197b:	e8 b7 02 00 00       	call   801c37 <nsipc_close>
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	eb eb                	jmp    801970 <devsock_close+0x1f>

00801985 <devsock_write>:
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80198b:	6a 00                	push   $0x0
  80198d:	ff 75 10             	push   0x10(%ebp)
  801990:	ff 75 0c             	push   0xc(%ebp)
  801993:	8b 45 08             	mov    0x8(%ebp),%eax
  801996:	ff 70 0c             	push   0xc(%eax)
  801999:	e8 79 03 00 00       	call   801d17 <nsipc_send>
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <devsock_read>:
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019a6:	6a 00                	push   $0x0
  8019a8:	ff 75 10             	push   0x10(%ebp)
  8019ab:	ff 75 0c             	push   0xc(%ebp)
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	ff 70 0c             	push   0xc(%eax)
  8019b4:	e8 ef 02 00 00       	call   801ca8 <nsipc_recv>
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <fd2sockid>:
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019c1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019c4:	52                   	push   %edx
  8019c5:	50                   	push   %eax
  8019c6:	e8 fb f7 ff ff       	call   8011c6 <fd_lookup>
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 10                	js     8019e2 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8019d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019db:	39 08                	cmp    %ecx,(%eax)
  8019dd:	75 05                	jne    8019e4 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8019df:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    
		return -E_NOT_SUPP;
  8019e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019e9:	eb f7                	jmp    8019e2 <fd2sockid+0x27>

008019eb <alloc_sockfd>:
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	56                   	push   %esi
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 1c             	sub    $0x1c,%esp
  8019f3:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8019f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f8:	50                   	push   %eax
  8019f9:	e8 78 f7 ff ff       	call   801176 <fd_alloc>
  8019fe:	89 c3                	mov    %eax,%ebx
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 43                	js     801a4a <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a07:	83 ec 04             	sub    $0x4,%esp
  801a0a:	68 07 04 00 00       	push   $0x407
  801a0f:	ff 75 f4             	push   -0xc(%ebp)
  801a12:	6a 00                	push   $0x0
  801a14:	e8 72 f1 ff ff       	call   800b8b <sys_page_alloc>
  801a19:	89 c3                	mov    %eax,%ebx
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 28                	js     801a4a <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a2b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a30:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a37:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a3a:	83 ec 0c             	sub    $0xc,%esp
  801a3d:	50                   	push   %eax
  801a3e:	e8 0c f7 ff ff       	call   80114f <fd2num>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	eb 0c                	jmp    801a56 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	56                   	push   %esi
  801a4e:	e8 e4 01 00 00       	call   801c37 <nsipc_close>
		return r;
  801a53:	83 c4 10             	add    $0x10,%esp
}
  801a56:	89 d8                	mov    %ebx,%eax
  801a58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5b:	5b                   	pop    %ebx
  801a5c:	5e                   	pop    %esi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <accept>:
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a65:	8b 45 08             	mov    0x8(%ebp),%eax
  801a68:	e8 4e ff ff ff       	call   8019bb <fd2sockid>
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	78 1b                	js     801a8c <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a71:	83 ec 04             	sub    $0x4,%esp
  801a74:	ff 75 10             	push   0x10(%ebp)
  801a77:	ff 75 0c             	push   0xc(%ebp)
  801a7a:	50                   	push   %eax
  801a7b:	e8 0e 01 00 00       	call   801b8e <nsipc_accept>
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 05                	js     801a8c <accept+0x2d>
	return alloc_sockfd(r);
  801a87:	e8 5f ff ff ff       	call   8019eb <alloc_sockfd>
}
  801a8c:	c9                   	leave  
  801a8d:	c3                   	ret    

00801a8e <bind>:
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	e8 1f ff ff ff       	call   8019bb <fd2sockid>
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	78 12                	js     801ab2 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801aa0:	83 ec 04             	sub    $0x4,%esp
  801aa3:	ff 75 10             	push   0x10(%ebp)
  801aa6:	ff 75 0c             	push   0xc(%ebp)
  801aa9:	50                   	push   %eax
  801aaa:	e8 31 01 00 00       	call   801be0 <nsipc_bind>
  801aaf:	83 c4 10             	add    $0x10,%esp
}
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <shutdown>:
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801aba:	8b 45 08             	mov    0x8(%ebp),%eax
  801abd:	e8 f9 fe ff ff       	call   8019bb <fd2sockid>
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 0f                	js     801ad5 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801ac6:	83 ec 08             	sub    $0x8,%esp
  801ac9:	ff 75 0c             	push   0xc(%ebp)
  801acc:	50                   	push   %eax
  801acd:	e8 43 01 00 00       	call   801c15 <nsipc_shutdown>
  801ad2:	83 c4 10             	add    $0x10,%esp
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <connect>:
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801add:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae0:	e8 d6 fe ff ff       	call   8019bb <fd2sockid>
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 12                	js     801afb <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801ae9:	83 ec 04             	sub    $0x4,%esp
  801aec:	ff 75 10             	push   0x10(%ebp)
  801aef:	ff 75 0c             	push   0xc(%ebp)
  801af2:	50                   	push   %eax
  801af3:	e8 59 01 00 00       	call   801c51 <nsipc_connect>
  801af8:	83 c4 10             	add    $0x10,%esp
}
  801afb:	c9                   	leave  
  801afc:	c3                   	ret    

00801afd <listen>:
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	e8 b0 fe ff ff       	call   8019bb <fd2sockid>
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 0f                	js     801b1e <listen+0x21>
	return nsipc_listen(r, backlog);
  801b0f:	83 ec 08             	sub    $0x8,%esp
  801b12:	ff 75 0c             	push   0xc(%ebp)
  801b15:	50                   	push   %eax
  801b16:	e8 6b 01 00 00       	call   801c86 <nsipc_listen>
  801b1b:	83 c4 10             	add    $0x10,%esp
}
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <socket>:

int
socket(int domain, int type, int protocol)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b26:	ff 75 10             	push   0x10(%ebp)
  801b29:	ff 75 0c             	push   0xc(%ebp)
  801b2c:	ff 75 08             	push   0x8(%ebp)
  801b2f:	e8 41 02 00 00       	call   801d75 <nsipc_socket>
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	85 c0                	test   %eax,%eax
  801b39:	78 05                	js     801b40 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b3b:	e8 ab fe ff ff       	call   8019eb <alloc_sockfd>
}
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    

00801b42 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	53                   	push   %ebx
  801b46:	83 ec 04             	sub    $0x4,%esp
  801b49:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b4b:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801b52:	74 26                	je     801b7a <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b54:	6a 07                	push   $0x7
  801b56:	68 00 70 80 00       	push   $0x807000
  801b5b:	53                   	push   %ebx
  801b5c:	ff 35 00 80 80 00    	push   0x808000
  801b62:	e8 5b f5 ff ff       	call   8010c2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b67:	83 c4 0c             	add    $0xc,%esp
  801b6a:	6a 00                	push   $0x0
  801b6c:	6a 00                	push   $0x0
  801b6e:	6a 00                	push   $0x0
  801b70:	e8 e6 f4 ff ff       	call   80105b <ipc_recv>
}
  801b75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b7a:	83 ec 0c             	sub    $0xc,%esp
  801b7d:	6a 02                	push   $0x2
  801b7f:	e8 92 f5 ff ff       	call   801116 <ipc_find_env>
  801b84:	a3 00 80 80 00       	mov    %eax,0x808000
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	eb c6                	jmp    801b54 <nsipc+0x12>

00801b8e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b9e:	8b 06                	mov    (%esi),%eax
  801ba0:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ba5:	b8 01 00 00 00       	mov    $0x1,%eax
  801baa:	e8 93 ff ff ff       	call   801b42 <nsipc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	79 09                	jns    801bbe <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801bb5:	89 d8                	mov    %ebx,%eax
  801bb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bbe:	83 ec 04             	sub    $0x4,%esp
  801bc1:	ff 35 10 70 80 00    	push   0x807010
  801bc7:	68 00 70 80 00       	push   $0x807000
  801bcc:	ff 75 0c             	push   0xc(%ebp)
  801bcf:	e8 51 ed ff ff       	call   800925 <memmove>
		*addrlen = ret->ret_addrlen;
  801bd4:	a1 10 70 80 00       	mov    0x807010,%eax
  801bd9:	89 06                	mov    %eax,(%esi)
  801bdb:	83 c4 10             	add    $0x10,%esp
	return r;
  801bde:	eb d5                	jmp    801bb5 <nsipc_accept+0x27>

00801be0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	53                   	push   %ebx
  801be4:	83 ec 08             	sub    $0x8,%esp
  801be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bf2:	53                   	push   %ebx
  801bf3:	ff 75 0c             	push   0xc(%ebp)
  801bf6:	68 04 70 80 00       	push   $0x807004
  801bfb:	e8 25 ed ff ff       	call   800925 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c00:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c06:	b8 02 00 00 00       	mov    $0x2,%eax
  801c0b:	e8 32 ff ff ff       	call   801b42 <nsipc>
}
  801c10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    

00801c15 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c26:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801c2b:	b8 03 00 00 00       	mov    $0x3,%eax
  801c30:	e8 0d ff ff ff       	call   801b42 <nsipc>
}
  801c35:	c9                   	leave  
  801c36:	c3                   	ret    

00801c37 <nsipc_close>:

int
nsipc_close(int s)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c40:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801c45:	b8 04 00 00 00       	mov    $0x4,%eax
  801c4a:	e8 f3 fe ff ff       	call   801b42 <nsipc>
}
  801c4f:	c9                   	leave  
  801c50:	c3                   	ret    

00801c51 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	53                   	push   %ebx
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c63:	53                   	push   %ebx
  801c64:	ff 75 0c             	push   0xc(%ebp)
  801c67:	68 04 70 80 00       	push   $0x807004
  801c6c:	e8 b4 ec ff ff       	call   800925 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c71:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801c77:	b8 05 00 00 00       	mov    $0x5,%eax
  801c7c:	e8 c1 fe ff ff       	call   801b42 <nsipc>
}
  801c81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801c94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c97:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801c9c:	b8 06 00 00 00       	mov    $0x6,%eax
  801ca1:	e8 9c fe ff ff       	call   801b42 <nsipc>
}
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	56                   	push   %esi
  801cac:	53                   	push   %ebx
  801cad:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801cb8:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801cbe:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc1:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cc6:	b8 07 00 00 00       	mov    $0x7,%eax
  801ccb:	e8 72 fe ff ff       	call   801b42 <nsipc>
  801cd0:	89 c3                	mov    %eax,%ebx
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	78 22                	js     801cf8 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801cd6:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801cdb:	39 c6                	cmp    %eax,%esi
  801cdd:	0f 4e c6             	cmovle %esi,%eax
  801ce0:	39 c3                	cmp    %eax,%ebx
  801ce2:	7f 1d                	jg     801d01 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ce4:	83 ec 04             	sub    $0x4,%esp
  801ce7:	53                   	push   %ebx
  801ce8:	68 00 70 80 00       	push   $0x807000
  801ced:	ff 75 0c             	push   0xc(%ebp)
  801cf0:	e8 30 ec ff ff       	call   800925 <memmove>
  801cf5:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801cf8:	89 d8                	mov    %ebx,%eax
  801cfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d01:	68 e7 2a 80 00       	push   $0x802ae7
  801d06:	68 af 2a 80 00       	push   $0x802aaf
  801d0b:	6a 62                	push   $0x62
  801d0d:	68 fc 2a 80 00       	push   $0x802afc
  801d12:	e8 46 05 00 00       	call   80225d <_panic>

00801d17 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	53                   	push   %ebx
  801d1b:	83 ec 04             	sub    $0x4,%esp
  801d1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d21:	8b 45 08             	mov    0x8(%ebp),%eax
  801d24:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801d29:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d2f:	7f 2e                	jg     801d5f <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d31:	83 ec 04             	sub    $0x4,%esp
  801d34:	53                   	push   %ebx
  801d35:	ff 75 0c             	push   0xc(%ebp)
  801d38:	68 0c 70 80 00       	push   $0x80700c
  801d3d:	e8 e3 eb ff ff       	call   800925 <memmove>
	nsipcbuf.send.req_size = size;
  801d42:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801d48:	8b 45 14             	mov    0x14(%ebp),%eax
  801d4b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801d50:	b8 08 00 00 00       	mov    $0x8,%eax
  801d55:	e8 e8 fd ff ff       	call   801b42 <nsipc>
}
  801d5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    
	assert(size < 1600);
  801d5f:	68 08 2b 80 00       	push   $0x802b08
  801d64:	68 af 2a 80 00       	push   $0x802aaf
  801d69:	6a 6d                	push   $0x6d
  801d6b:	68 fc 2a 80 00       	push   $0x802afc
  801d70:	e8 e8 04 00 00       	call   80225d <_panic>

00801d75 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801d83:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d86:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801d8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d8e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801d93:	b8 09 00 00 00       	mov    $0x9,%eax
  801d98:	e8 a5 fd ff ff       	call   801b42 <nsipc>
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801da7:	83 ec 0c             	sub    $0xc,%esp
  801daa:	ff 75 08             	push   0x8(%ebp)
  801dad:	e8 ad f3 ff ff       	call   80115f <fd2data>
  801db2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801db4:	83 c4 08             	add    $0x8,%esp
  801db7:	68 14 2b 80 00       	push   $0x802b14
  801dbc:	53                   	push   %ebx
  801dbd:	e8 cd e9 ff ff       	call   80078f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dc2:	8b 46 04             	mov    0x4(%esi),%eax
  801dc5:	2b 06                	sub    (%esi),%eax
  801dc7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dcd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801dd4:	00 00 00 
	stat->st_dev = &devpipe;
  801dd7:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801dde:	30 80 00 
	return 0;
}
  801de1:	b8 00 00 00 00       	mov    $0x0,%eax
  801de6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de9:	5b                   	pop    %ebx
  801dea:	5e                   	pop    %esi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    

00801ded <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	53                   	push   %ebx
  801df1:	83 ec 0c             	sub    $0xc,%esp
  801df4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801df7:	53                   	push   %ebx
  801df8:	6a 00                	push   $0x0
  801dfa:	e8 11 ee ff ff       	call   800c10 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dff:	89 1c 24             	mov    %ebx,(%esp)
  801e02:	e8 58 f3 ff ff       	call   80115f <fd2data>
  801e07:	83 c4 08             	add    $0x8,%esp
  801e0a:	50                   	push   %eax
  801e0b:	6a 00                	push   $0x0
  801e0d:	e8 fe ed ff ff       	call   800c10 <sys_page_unmap>
}
  801e12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <_pipeisclosed>:
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	57                   	push   %edi
  801e1b:	56                   	push   %esi
  801e1c:	53                   	push   %ebx
  801e1d:	83 ec 1c             	sub    $0x1c,%esp
  801e20:	89 c7                	mov    %eax,%edi
  801e22:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e24:	a1 00 40 80 00       	mov    0x804000,%eax
  801e29:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e2c:	83 ec 0c             	sub    $0xc,%esp
  801e2f:	57                   	push   %edi
  801e30:	e8 0a 05 00 00       	call   80233f <pageref>
  801e35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e38:	89 34 24             	mov    %esi,(%esp)
  801e3b:	e8 ff 04 00 00       	call   80233f <pageref>
		nn = thisenv->env_runs;
  801e40:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801e46:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	39 cb                	cmp    %ecx,%ebx
  801e4e:	74 1b                	je     801e6b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801e50:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e53:	75 cf                	jne    801e24 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e55:	8b 42 58             	mov    0x58(%edx),%eax
  801e58:	6a 01                	push   $0x1
  801e5a:	50                   	push   %eax
  801e5b:	53                   	push   %ebx
  801e5c:	68 1b 2b 80 00       	push   $0x802b1b
  801e61:	e8 4f e3 ff ff       	call   8001b5 <cprintf>
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	eb b9                	jmp    801e24 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801e6b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e6e:	0f 94 c0             	sete   %al
  801e71:	0f b6 c0             	movzbl %al,%eax
}
  801e74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e77:	5b                   	pop    %ebx
  801e78:	5e                   	pop    %esi
  801e79:	5f                   	pop    %edi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <devpipe_write>:
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	57                   	push   %edi
  801e80:	56                   	push   %esi
  801e81:	53                   	push   %ebx
  801e82:	83 ec 28             	sub    $0x28,%esp
  801e85:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e88:	56                   	push   %esi
  801e89:	e8 d1 f2 ff ff       	call   80115f <fd2data>
  801e8e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	bf 00 00 00 00       	mov    $0x0,%edi
  801e98:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e9b:	75 09                	jne    801ea6 <devpipe_write+0x2a>
	return i;
  801e9d:	89 f8                	mov    %edi,%eax
  801e9f:	eb 23                	jmp    801ec4 <devpipe_write+0x48>
			sys_yield();
  801ea1:	e8 c6 ec ff ff       	call   800b6c <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ea6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ea9:	8b 0b                	mov    (%ebx),%ecx
  801eab:	8d 51 20             	lea    0x20(%ecx),%edx
  801eae:	39 d0                	cmp    %edx,%eax
  801eb0:	72 1a                	jb     801ecc <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801eb2:	89 da                	mov    %ebx,%edx
  801eb4:	89 f0                	mov    %esi,%eax
  801eb6:	e8 5c ff ff ff       	call   801e17 <_pipeisclosed>
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	74 e2                	je     801ea1 <devpipe_write+0x25>
				return 0;
  801ebf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ec4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec7:	5b                   	pop    %ebx
  801ec8:	5e                   	pop    %esi
  801ec9:	5f                   	pop    %edi
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ecf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ed3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ed6:	89 c2                	mov    %eax,%edx
  801ed8:	c1 fa 1f             	sar    $0x1f,%edx
  801edb:	89 d1                	mov    %edx,%ecx
  801edd:	c1 e9 1b             	shr    $0x1b,%ecx
  801ee0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ee3:	83 e2 1f             	and    $0x1f,%edx
  801ee6:	29 ca                	sub    %ecx,%edx
  801ee8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801eec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ef0:	83 c0 01             	add    $0x1,%eax
  801ef3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ef6:	83 c7 01             	add    $0x1,%edi
  801ef9:	eb 9d                	jmp    801e98 <devpipe_write+0x1c>

00801efb <devpipe_read>:
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	57                   	push   %edi
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	83 ec 18             	sub    $0x18,%esp
  801f04:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f07:	57                   	push   %edi
  801f08:	e8 52 f2 ff ff       	call   80115f <fd2data>
  801f0d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	be 00 00 00 00       	mov    $0x0,%esi
  801f17:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f1a:	75 13                	jne    801f2f <devpipe_read+0x34>
	return i;
  801f1c:	89 f0                	mov    %esi,%eax
  801f1e:	eb 02                	jmp    801f22 <devpipe_read+0x27>
				return i;
  801f20:	89 f0                	mov    %esi,%eax
}
  801f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5f                   	pop    %edi
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    
			sys_yield();
  801f2a:	e8 3d ec ff ff       	call   800b6c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f2f:	8b 03                	mov    (%ebx),%eax
  801f31:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f34:	75 18                	jne    801f4e <devpipe_read+0x53>
			if (i > 0)
  801f36:	85 f6                	test   %esi,%esi
  801f38:	75 e6                	jne    801f20 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801f3a:	89 da                	mov    %ebx,%edx
  801f3c:	89 f8                	mov    %edi,%eax
  801f3e:	e8 d4 fe ff ff       	call   801e17 <_pipeisclosed>
  801f43:	85 c0                	test   %eax,%eax
  801f45:	74 e3                	je     801f2a <devpipe_read+0x2f>
				return 0;
  801f47:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4c:	eb d4                	jmp    801f22 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f4e:	99                   	cltd   
  801f4f:	c1 ea 1b             	shr    $0x1b,%edx
  801f52:	01 d0                	add    %edx,%eax
  801f54:	83 e0 1f             	and    $0x1f,%eax
  801f57:	29 d0                	sub    %edx,%eax
  801f59:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f61:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f64:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801f67:	83 c6 01             	add    $0x1,%esi
  801f6a:	eb ab                	jmp    801f17 <devpipe_read+0x1c>

00801f6c <pipe>:
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	56                   	push   %esi
  801f70:	53                   	push   %ebx
  801f71:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f77:	50                   	push   %eax
  801f78:	e8 f9 f1 ff ff       	call   801176 <fd_alloc>
  801f7d:	89 c3                	mov    %eax,%ebx
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	85 c0                	test   %eax,%eax
  801f84:	0f 88 23 01 00 00    	js     8020ad <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f8a:	83 ec 04             	sub    $0x4,%esp
  801f8d:	68 07 04 00 00       	push   $0x407
  801f92:	ff 75 f4             	push   -0xc(%ebp)
  801f95:	6a 00                	push   $0x0
  801f97:	e8 ef eb ff ff       	call   800b8b <sys_page_alloc>
  801f9c:	89 c3                	mov    %eax,%ebx
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	0f 88 04 01 00 00    	js     8020ad <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801fa9:	83 ec 0c             	sub    $0xc,%esp
  801fac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801faf:	50                   	push   %eax
  801fb0:	e8 c1 f1 ff ff       	call   801176 <fd_alloc>
  801fb5:	89 c3                	mov    %eax,%ebx
  801fb7:	83 c4 10             	add    $0x10,%esp
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	0f 88 db 00 00 00    	js     80209d <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc2:	83 ec 04             	sub    $0x4,%esp
  801fc5:	68 07 04 00 00       	push   $0x407
  801fca:	ff 75 f0             	push   -0x10(%ebp)
  801fcd:	6a 00                	push   $0x0
  801fcf:	e8 b7 eb ff ff       	call   800b8b <sys_page_alloc>
  801fd4:	89 c3                	mov    %eax,%ebx
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	0f 88 bc 00 00 00    	js     80209d <pipe+0x131>
	va = fd2data(fd0);
  801fe1:	83 ec 0c             	sub    $0xc,%esp
  801fe4:	ff 75 f4             	push   -0xc(%ebp)
  801fe7:	e8 73 f1 ff ff       	call   80115f <fd2data>
  801fec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fee:	83 c4 0c             	add    $0xc,%esp
  801ff1:	68 07 04 00 00       	push   $0x407
  801ff6:	50                   	push   %eax
  801ff7:	6a 00                	push   $0x0
  801ff9:	e8 8d eb ff ff       	call   800b8b <sys_page_alloc>
  801ffe:	89 c3                	mov    %eax,%ebx
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	85 c0                	test   %eax,%eax
  802005:	0f 88 82 00 00 00    	js     80208d <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200b:	83 ec 0c             	sub    $0xc,%esp
  80200e:	ff 75 f0             	push   -0x10(%ebp)
  802011:	e8 49 f1 ff ff       	call   80115f <fd2data>
  802016:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80201d:	50                   	push   %eax
  80201e:	6a 00                	push   $0x0
  802020:	56                   	push   %esi
  802021:	6a 00                	push   $0x0
  802023:	e8 a6 eb ff ff       	call   800bce <sys_page_map>
  802028:	89 c3                	mov    %eax,%ebx
  80202a:	83 c4 20             	add    $0x20,%esp
  80202d:	85 c0                	test   %eax,%eax
  80202f:	78 4e                	js     80207f <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802031:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802036:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802039:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80203b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80203e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802045:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802048:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80204a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80204d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802054:	83 ec 0c             	sub    $0xc,%esp
  802057:	ff 75 f4             	push   -0xc(%ebp)
  80205a:	e8 f0 f0 ff ff       	call   80114f <fd2num>
  80205f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802062:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802064:	83 c4 04             	add    $0x4,%esp
  802067:	ff 75 f0             	push   -0x10(%ebp)
  80206a:	e8 e0 f0 ff ff       	call   80114f <fd2num>
  80206f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802072:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802075:	83 c4 10             	add    $0x10,%esp
  802078:	bb 00 00 00 00       	mov    $0x0,%ebx
  80207d:	eb 2e                	jmp    8020ad <pipe+0x141>
	sys_page_unmap(0, va);
  80207f:	83 ec 08             	sub    $0x8,%esp
  802082:	56                   	push   %esi
  802083:	6a 00                	push   $0x0
  802085:	e8 86 eb ff ff       	call   800c10 <sys_page_unmap>
  80208a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80208d:	83 ec 08             	sub    $0x8,%esp
  802090:	ff 75 f0             	push   -0x10(%ebp)
  802093:	6a 00                	push   $0x0
  802095:	e8 76 eb ff ff       	call   800c10 <sys_page_unmap>
  80209a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80209d:	83 ec 08             	sub    $0x8,%esp
  8020a0:	ff 75 f4             	push   -0xc(%ebp)
  8020a3:	6a 00                	push   $0x0
  8020a5:	e8 66 eb ff ff       	call   800c10 <sys_page_unmap>
  8020aa:	83 c4 10             	add    $0x10,%esp
}
  8020ad:	89 d8                	mov    %ebx,%eax
  8020af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020b2:	5b                   	pop    %ebx
  8020b3:	5e                   	pop    %esi
  8020b4:	5d                   	pop    %ebp
  8020b5:	c3                   	ret    

008020b6 <pipeisclosed>:
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020bf:	50                   	push   %eax
  8020c0:	ff 75 08             	push   0x8(%ebp)
  8020c3:	e8 fe f0 ff ff       	call   8011c6 <fd_lookup>
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	78 18                	js     8020e7 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8020cf:	83 ec 0c             	sub    $0xc,%esp
  8020d2:	ff 75 f4             	push   -0xc(%ebp)
  8020d5:	e8 85 f0 ff ff       	call   80115f <fd2data>
  8020da:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8020dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020df:	e8 33 fd ff ff       	call   801e17 <_pipeisclosed>
  8020e4:	83 c4 10             	add    $0x10,%esp
}
  8020e7:	c9                   	leave  
  8020e8:	c3                   	ret    

008020e9 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8020e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ee:	c3                   	ret    

008020ef <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020ef:	55                   	push   %ebp
  8020f0:	89 e5                	mov    %esp,%ebp
  8020f2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020f5:	68 33 2b 80 00       	push   $0x802b33
  8020fa:	ff 75 0c             	push   0xc(%ebp)
  8020fd:	e8 8d e6 ff ff       	call   80078f <strcpy>
	return 0;
}
  802102:	b8 00 00 00 00       	mov    $0x0,%eax
  802107:	c9                   	leave  
  802108:	c3                   	ret    

00802109 <devcons_write>:
{
  802109:	55                   	push   %ebp
  80210a:	89 e5                	mov    %esp,%ebp
  80210c:	57                   	push   %edi
  80210d:	56                   	push   %esi
  80210e:	53                   	push   %ebx
  80210f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802115:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80211a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802120:	eb 2e                	jmp    802150 <devcons_write+0x47>
		m = n - tot;
  802122:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802125:	29 f3                	sub    %esi,%ebx
  802127:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80212c:	39 c3                	cmp    %eax,%ebx
  80212e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802131:	83 ec 04             	sub    $0x4,%esp
  802134:	53                   	push   %ebx
  802135:	89 f0                	mov    %esi,%eax
  802137:	03 45 0c             	add    0xc(%ebp),%eax
  80213a:	50                   	push   %eax
  80213b:	57                   	push   %edi
  80213c:	e8 e4 e7 ff ff       	call   800925 <memmove>
		sys_cputs(buf, m);
  802141:	83 c4 08             	add    $0x8,%esp
  802144:	53                   	push   %ebx
  802145:	57                   	push   %edi
  802146:	e8 84 e9 ff ff       	call   800acf <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80214b:	01 de                	add    %ebx,%esi
  80214d:	83 c4 10             	add    $0x10,%esp
  802150:	3b 75 10             	cmp    0x10(%ebp),%esi
  802153:	72 cd                	jb     802122 <devcons_write+0x19>
}
  802155:	89 f0                	mov    %esi,%eax
  802157:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80215a:	5b                   	pop    %ebx
  80215b:	5e                   	pop    %esi
  80215c:	5f                   	pop    %edi
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    

0080215f <devcons_read>:
{
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	83 ec 08             	sub    $0x8,%esp
  802165:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80216a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80216e:	75 07                	jne    802177 <devcons_read+0x18>
  802170:	eb 1f                	jmp    802191 <devcons_read+0x32>
		sys_yield();
  802172:	e8 f5 e9 ff ff       	call   800b6c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802177:	e8 71 e9 ff ff       	call   800aed <sys_cgetc>
  80217c:	85 c0                	test   %eax,%eax
  80217e:	74 f2                	je     802172 <devcons_read+0x13>
	if (c < 0)
  802180:	78 0f                	js     802191 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802182:	83 f8 04             	cmp    $0x4,%eax
  802185:	74 0c                	je     802193 <devcons_read+0x34>
	*(char*)vbuf = c;
  802187:	8b 55 0c             	mov    0xc(%ebp),%edx
  80218a:	88 02                	mov    %al,(%edx)
	return 1;
  80218c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802191:	c9                   	leave  
  802192:	c3                   	ret    
		return 0;
  802193:	b8 00 00 00 00       	mov    $0x0,%eax
  802198:	eb f7                	jmp    802191 <devcons_read+0x32>

0080219a <cputchar>:
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a3:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8021a6:	6a 01                	push   $0x1
  8021a8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ab:	50                   	push   %eax
  8021ac:	e8 1e e9 ff ff       	call   800acf <sys_cputs>
}
  8021b1:	83 c4 10             	add    $0x10,%esp
  8021b4:	c9                   	leave  
  8021b5:	c3                   	ret    

008021b6 <getchar>:
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8021bc:	6a 01                	push   $0x1
  8021be:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021c1:	50                   	push   %eax
  8021c2:	6a 00                	push   $0x0
  8021c4:	e8 66 f2 ff ff       	call   80142f <read>
	if (r < 0)
  8021c9:	83 c4 10             	add    $0x10,%esp
  8021cc:	85 c0                	test   %eax,%eax
  8021ce:	78 06                	js     8021d6 <getchar+0x20>
	if (r < 1)
  8021d0:	74 06                	je     8021d8 <getchar+0x22>
	return c;
  8021d2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8021d6:	c9                   	leave  
  8021d7:	c3                   	ret    
		return -E_EOF;
  8021d8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8021dd:	eb f7                	jmp    8021d6 <getchar+0x20>

008021df <iscons>:
{
  8021df:	55                   	push   %ebp
  8021e0:	89 e5                	mov    %esp,%ebp
  8021e2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021e8:	50                   	push   %eax
  8021e9:	ff 75 08             	push   0x8(%ebp)
  8021ec:	e8 d5 ef ff ff       	call   8011c6 <fd_lookup>
  8021f1:	83 c4 10             	add    $0x10,%esp
  8021f4:	85 c0                	test   %eax,%eax
  8021f6:	78 11                	js     802209 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8021f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802201:	39 10                	cmp    %edx,(%eax)
  802203:	0f 94 c0             	sete   %al
  802206:	0f b6 c0             	movzbl %al,%eax
}
  802209:	c9                   	leave  
  80220a:	c3                   	ret    

0080220b <opencons>:
{
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802214:	50                   	push   %eax
  802215:	e8 5c ef ff ff       	call   801176 <fd_alloc>
  80221a:	83 c4 10             	add    $0x10,%esp
  80221d:	85 c0                	test   %eax,%eax
  80221f:	78 3a                	js     80225b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802221:	83 ec 04             	sub    $0x4,%esp
  802224:	68 07 04 00 00       	push   $0x407
  802229:	ff 75 f4             	push   -0xc(%ebp)
  80222c:	6a 00                	push   $0x0
  80222e:	e8 58 e9 ff ff       	call   800b8b <sys_page_alloc>
  802233:	83 c4 10             	add    $0x10,%esp
  802236:	85 c0                	test   %eax,%eax
  802238:	78 21                	js     80225b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80223a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802243:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802245:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802248:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80224f:	83 ec 0c             	sub    $0xc,%esp
  802252:	50                   	push   %eax
  802253:	e8 f7 ee ff ff       	call   80114f <fd2num>
  802258:	83 c4 10             	add    $0x10,%esp
}
  80225b:	c9                   	leave  
  80225c:	c3                   	ret    

0080225d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80225d:	55                   	push   %ebp
  80225e:	89 e5                	mov    %esp,%ebp
  802260:	56                   	push   %esi
  802261:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802262:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802265:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80226b:	e8 dd e8 ff ff       	call   800b4d <sys_getenvid>
  802270:	83 ec 0c             	sub    $0xc,%esp
  802273:	ff 75 0c             	push   0xc(%ebp)
  802276:	ff 75 08             	push   0x8(%ebp)
  802279:	56                   	push   %esi
  80227a:	50                   	push   %eax
  80227b:	68 40 2b 80 00       	push   $0x802b40
  802280:	e8 30 df ff ff       	call   8001b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802285:	83 c4 18             	add    $0x18,%esp
  802288:	53                   	push   %ebx
  802289:	ff 75 10             	push   0x10(%ebp)
  80228c:	e8 d3 de ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  802291:	c7 04 24 2c 2b 80 00 	movl   $0x802b2c,(%esp)
  802298:	e8 18 df ff ff       	call   8001b5 <cprintf>
  80229d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022a0:	cc                   	int3   
  8022a1:	eb fd                	jmp    8022a0 <_panic+0x43>

008022a3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
  8022a6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8022a9:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8022b0:	74 0a                	je     8022bc <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b5:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8022ba:	c9                   	leave  
  8022bb:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8022bc:	e8 8c e8 ff ff       	call   800b4d <sys_getenvid>
  8022c1:	83 ec 04             	sub    $0x4,%esp
  8022c4:	68 07 0e 00 00       	push   $0xe07
  8022c9:	68 00 f0 bf ee       	push   $0xeebff000
  8022ce:	50                   	push   %eax
  8022cf:	e8 b7 e8 ff ff       	call   800b8b <sys_page_alloc>
		if (r < 0) {
  8022d4:	83 c4 10             	add    $0x10,%esp
  8022d7:	85 c0                	test   %eax,%eax
  8022d9:	78 2c                	js     802307 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8022db:	e8 6d e8 ff ff       	call   800b4d <sys_getenvid>
  8022e0:	83 ec 08             	sub    $0x8,%esp
  8022e3:	68 19 23 80 00       	push   $0x802319
  8022e8:	50                   	push   %eax
  8022e9:	e8 e8 e9 ff ff       	call   800cd6 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8022ee:	83 c4 10             	add    $0x10,%esp
  8022f1:	85 c0                	test   %eax,%eax
  8022f3:	79 bd                	jns    8022b2 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  8022f5:	50                   	push   %eax
  8022f6:	68 a4 2b 80 00       	push   $0x802ba4
  8022fb:	6a 28                	push   $0x28
  8022fd:	68 da 2b 80 00       	push   $0x802bda
  802302:	e8 56 ff ff ff       	call   80225d <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802307:	50                   	push   %eax
  802308:	68 64 2b 80 00       	push   $0x802b64
  80230d:	6a 23                	push   $0x23
  80230f:	68 da 2b 80 00       	push   $0x802bda
  802314:	e8 44 ff ff ff       	call   80225d <_panic>

00802319 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802319:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80231a:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  80231f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802321:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802324:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802328:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80232b:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80232f:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802333:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802335:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802338:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802339:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80233c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80233d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80233e:	c3                   	ret    

0080233f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80233f:	55                   	push   %ebp
  802340:	89 e5                	mov    %esp,%ebp
  802342:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802345:	89 c2                	mov    %eax,%edx
  802347:	c1 ea 16             	shr    $0x16,%edx
  80234a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802351:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802356:	f6 c1 01             	test   $0x1,%cl
  802359:	74 1c                	je     802377 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80235b:	c1 e8 0c             	shr    $0xc,%eax
  80235e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802365:	a8 01                	test   $0x1,%al
  802367:	74 0e                	je     802377 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802369:	c1 e8 0c             	shr    $0xc,%eax
  80236c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802373:	ef 
  802374:	0f b7 d2             	movzwl %dx,%edx
}
  802377:	89 d0                	mov    %edx,%eax
  802379:	5d                   	pop    %ebp
  80237a:	c3                   	ret    
  80237b:	66 90                	xchg   %ax,%ax
  80237d:	66 90                	xchg   %ax,%ax
  80237f:	90                   	nop

00802380 <__udivdi3>:
  802380:	f3 0f 1e fb          	endbr32 
  802384:	55                   	push   %ebp
  802385:	57                   	push   %edi
  802386:	56                   	push   %esi
  802387:	53                   	push   %ebx
  802388:	83 ec 1c             	sub    $0x1c,%esp
  80238b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80238f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802393:	8b 74 24 34          	mov    0x34(%esp),%esi
  802397:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80239b:	85 c0                	test   %eax,%eax
  80239d:	75 19                	jne    8023b8 <__udivdi3+0x38>
  80239f:	39 f3                	cmp    %esi,%ebx
  8023a1:	76 4d                	jbe    8023f0 <__udivdi3+0x70>
  8023a3:	31 ff                	xor    %edi,%edi
  8023a5:	89 e8                	mov    %ebp,%eax
  8023a7:	89 f2                	mov    %esi,%edx
  8023a9:	f7 f3                	div    %ebx
  8023ab:	89 fa                	mov    %edi,%edx
  8023ad:	83 c4 1c             	add    $0x1c,%esp
  8023b0:	5b                   	pop    %ebx
  8023b1:	5e                   	pop    %esi
  8023b2:	5f                   	pop    %edi
  8023b3:	5d                   	pop    %ebp
  8023b4:	c3                   	ret    
  8023b5:	8d 76 00             	lea    0x0(%esi),%esi
  8023b8:	39 f0                	cmp    %esi,%eax
  8023ba:	76 14                	jbe    8023d0 <__udivdi3+0x50>
  8023bc:	31 ff                	xor    %edi,%edi
  8023be:	31 c0                	xor    %eax,%eax
  8023c0:	89 fa                	mov    %edi,%edx
  8023c2:	83 c4 1c             	add    $0x1c,%esp
  8023c5:	5b                   	pop    %ebx
  8023c6:	5e                   	pop    %esi
  8023c7:	5f                   	pop    %edi
  8023c8:	5d                   	pop    %ebp
  8023c9:	c3                   	ret    
  8023ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d0:	0f bd f8             	bsr    %eax,%edi
  8023d3:	83 f7 1f             	xor    $0x1f,%edi
  8023d6:	75 48                	jne    802420 <__udivdi3+0xa0>
  8023d8:	39 f0                	cmp    %esi,%eax
  8023da:	72 06                	jb     8023e2 <__udivdi3+0x62>
  8023dc:	31 c0                	xor    %eax,%eax
  8023de:	39 eb                	cmp    %ebp,%ebx
  8023e0:	77 de                	ja     8023c0 <__udivdi3+0x40>
  8023e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8023e7:	eb d7                	jmp    8023c0 <__udivdi3+0x40>
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 d9                	mov    %ebx,%ecx
  8023f2:	85 db                	test   %ebx,%ebx
  8023f4:	75 0b                	jne    802401 <__udivdi3+0x81>
  8023f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fb:	31 d2                	xor    %edx,%edx
  8023fd:	f7 f3                	div    %ebx
  8023ff:	89 c1                	mov    %eax,%ecx
  802401:	31 d2                	xor    %edx,%edx
  802403:	89 f0                	mov    %esi,%eax
  802405:	f7 f1                	div    %ecx
  802407:	89 c6                	mov    %eax,%esi
  802409:	89 e8                	mov    %ebp,%eax
  80240b:	89 f7                	mov    %esi,%edi
  80240d:	f7 f1                	div    %ecx
  80240f:	89 fa                	mov    %edi,%edx
  802411:	83 c4 1c             	add    $0x1c,%esp
  802414:	5b                   	pop    %ebx
  802415:	5e                   	pop    %esi
  802416:	5f                   	pop    %edi
  802417:	5d                   	pop    %ebp
  802418:	c3                   	ret    
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	89 f9                	mov    %edi,%ecx
  802422:	ba 20 00 00 00       	mov    $0x20,%edx
  802427:	29 fa                	sub    %edi,%edx
  802429:	d3 e0                	shl    %cl,%eax
  80242b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80242f:	89 d1                	mov    %edx,%ecx
  802431:	89 d8                	mov    %ebx,%eax
  802433:	d3 e8                	shr    %cl,%eax
  802435:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802439:	09 c1                	or     %eax,%ecx
  80243b:	89 f0                	mov    %esi,%eax
  80243d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802441:	89 f9                	mov    %edi,%ecx
  802443:	d3 e3                	shl    %cl,%ebx
  802445:	89 d1                	mov    %edx,%ecx
  802447:	d3 e8                	shr    %cl,%eax
  802449:	89 f9                	mov    %edi,%ecx
  80244b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80244f:	89 eb                	mov    %ebp,%ebx
  802451:	d3 e6                	shl    %cl,%esi
  802453:	89 d1                	mov    %edx,%ecx
  802455:	d3 eb                	shr    %cl,%ebx
  802457:	09 f3                	or     %esi,%ebx
  802459:	89 c6                	mov    %eax,%esi
  80245b:	89 f2                	mov    %esi,%edx
  80245d:	89 d8                	mov    %ebx,%eax
  80245f:	f7 74 24 08          	divl   0x8(%esp)
  802463:	89 d6                	mov    %edx,%esi
  802465:	89 c3                	mov    %eax,%ebx
  802467:	f7 64 24 0c          	mull   0xc(%esp)
  80246b:	39 d6                	cmp    %edx,%esi
  80246d:	72 19                	jb     802488 <__udivdi3+0x108>
  80246f:	89 f9                	mov    %edi,%ecx
  802471:	d3 e5                	shl    %cl,%ebp
  802473:	39 c5                	cmp    %eax,%ebp
  802475:	73 04                	jae    80247b <__udivdi3+0xfb>
  802477:	39 d6                	cmp    %edx,%esi
  802479:	74 0d                	je     802488 <__udivdi3+0x108>
  80247b:	89 d8                	mov    %ebx,%eax
  80247d:	31 ff                	xor    %edi,%edi
  80247f:	e9 3c ff ff ff       	jmp    8023c0 <__udivdi3+0x40>
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80248b:	31 ff                	xor    %edi,%edi
  80248d:	e9 2e ff ff ff       	jmp    8023c0 <__udivdi3+0x40>
  802492:	66 90                	xchg   %ax,%ax
  802494:	66 90                	xchg   %ax,%ax
  802496:	66 90                	xchg   %ax,%ax
  802498:	66 90                	xchg   %ax,%ax
  80249a:	66 90                	xchg   %ax,%ax
  80249c:	66 90                	xchg   %ax,%ax
  80249e:	66 90                	xchg   %ax,%ax

008024a0 <__umoddi3>:
  8024a0:	f3 0f 1e fb          	endbr32 
  8024a4:	55                   	push   %ebp
  8024a5:	57                   	push   %edi
  8024a6:	56                   	push   %esi
  8024a7:	53                   	push   %ebx
  8024a8:	83 ec 1c             	sub    $0x1c,%esp
  8024ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024b3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8024b7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8024bb:	89 f0                	mov    %esi,%eax
  8024bd:	89 da                	mov    %ebx,%edx
  8024bf:	85 ff                	test   %edi,%edi
  8024c1:	75 15                	jne    8024d8 <__umoddi3+0x38>
  8024c3:	39 dd                	cmp    %ebx,%ebp
  8024c5:	76 39                	jbe    802500 <__umoddi3+0x60>
  8024c7:	f7 f5                	div    %ebp
  8024c9:	89 d0                	mov    %edx,%eax
  8024cb:	31 d2                	xor    %edx,%edx
  8024cd:	83 c4 1c             	add    $0x1c,%esp
  8024d0:	5b                   	pop    %ebx
  8024d1:	5e                   	pop    %esi
  8024d2:	5f                   	pop    %edi
  8024d3:	5d                   	pop    %ebp
  8024d4:	c3                   	ret    
  8024d5:	8d 76 00             	lea    0x0(%esi),%esi
  8024d8:	39 df                	cmp    %ebx,%edi
  8024da:	77 f1                	ja     8024cd <__umoddi3+0x2d>
  8024dc:	0f bd cf             	bsr    %edi,%ecx
  8024df:	83 f1 1f             	xor    $0x1f,%ecx
  8024e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8024e6:	75 40                	jne    802528 <__umoddi3+0x88>
  8024e8:	39 df                	cmp    %ebx,%edi
  8024ea:	72 04                	jb     8024f0 <__umoddi3+0x50>
  8024ec:	39 f5                	cmp    %esi,%ebp
  8024ee:	77 dd                	ja     8024cd <__umoddi3+0x2d>
  8024f0:	89 da                	mov    %ebx,%edx
  8024f2:	89 f0                	mov    %esi,%eax
  8024f4:	29 e8                	sub    %ebp,%eax
  8024f6:	19 fa                	sbb    %edi,%edx
  8024f8:	eb d3                	jmp    8024cd <__umoddi3+0x2d>
  8024fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802500:	89 e9                	mov    %ebp,%ecx
  802502:	85 ed                	test   %ebp,%ebp
  802504:	75 0b                	jne    802511 <__umoddi3+0x71>
  802506:	b8 01 00 00 00       	mov    $0x1,%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	f7 f5                	div    %ebp
  80250f:	89 c1                	mov    %eax,%ecx
  802511:	89 d8                	mov    %ebx,%eax
  802513:	31 d2                	xor    %edx,%edx
  802515:	f7 f1                	div    %ecx
  802517:	89 f0                	mov    %esi,%eax
  802519:	f7 f1                	div    %ecx
  80251b:	89 d0                	mov    %edx,%eax
  80251d:	31 d2                	xor    %edx,%edx
  80251f:	eb ac                	jmp    8024cd <__umoddi3+0x2d>
  802521:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802528:	8b 44 24 04          	mov    0x4(%esp),%eax
  80252c:	ba 20 00 00 00       	mov    $0x20,%edx
  802531:	29 c2                	sub    %eax,%edx
  802533:	89 c1                	mov    %eax,%ecx
  802535:	89 e8                	mov    %ebp,%eax
  802537:	d3 e7                	shl    %cl,%edi
  802539:	89 d1                	mov    %edx,%ecx
  80253b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80253f:	d3 e8                	shr    %cl,%eax
  802541:	89 c1                	mov    %eax,%ecx
  802543:	8b 44 24 04          	mov    0x4(%esp),%eax
  802547:	09 f9                	or     %edi,%ecx
  802549:	89 df                	mov    %ebx,%edi
  80254b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80254f:	89 c1                	mov    %eax,%ecx
  802551:	d3 e5                	shl    %cl,%ebp
  802553:	89 d1                	mov    %edx,%ecx
  802555:	d3 ef                	shr    %cl,%edi
  802557:	89 c1                	mov    %eax,%ecx
  802559:	89 f0                	mov    %esi,%eax
  80255b:	d3 e3                	shl    %cl,%ebx
  80255d:	89 d1                	mov    %edx,%ecx
  80255f:	89 fa                	mov    %edi,%edx
  802561:	d3 e8                	shr    %cl,%eax
  802563:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802568:	09 d8                	or     %ebx,%eax
  80256a:	f7 74 24 08          	divl   0x8(%esp)
  80256e:	89 d3                	mov    %edx,%ebx
  802570:	d3 e6                	shl    %cl,%esi
  802572:	f7 e5                	mul    %ebp
  802574:	89 c7                	mov    %eax,%edi
  802576:	89 d1                	mov    %edx,%ecx
  802578:	39 d3                	cmp    %edx,%ebx
  80257a:	72 06                	jb     802582 <__umoddi3+0xe2>
  80257c:	75 0e                	jne    80258c <__umoddi3+0xec>
  80257e:	39 c6                	cmp    %eax,%esi
  802580:	73 0a                	jae    80258c <__umoddi3+0xec>
  802582:	29 e8                	sub    %ebp,%eax
  802584:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802588:	89 d1                	mov    %edx,%ecx
  80258a:	89 c7                	mov    %eax,%edi
  80258c:	89 f5                	mov    %esi,%ebp
  80258e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802592:	29 fd                	sub    %edi,%ebp
  802594:	19 cb                	sbb    %ecx,%ebx
  802596:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80259b:	89 d8                	mov    %ebx,%eax
  80259d:	d3 e0                	shl    %cl,%eax
  80259f:	89 f1                	mov    %esi,%ecx
  8025a1:	d3 ed                	shr    %cl,%ebp
  8025a3:	d3 eb                	shr    %cl,%ebx
  8025a5:	09 e8                	or     %ebp,%eax
  8025a7:	89 da                	mov    %ebx,%edx
  8025a9:	83 c4 1c             	add    $0x1c,%esp
  8025ac:	5b                   	pop    %ebx
  8025ad:	5e                   	pop    %esi
  8025ae:	5f                   	pop    %edi
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    
