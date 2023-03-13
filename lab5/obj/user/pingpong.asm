
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
  80003c:	e8 39 0e 00 00       	call   800e7a <fork>
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
  800053:	e8 a2 0f 00 00       	call   800ffa <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 eb 0a 00 00       	call   800b4d <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 16 21 80 00       	push   $0x802116
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
  800082:	e8 da 0f 00 00       	call   801061 <ipc_send>
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
  8000a3:	68 00 21 80 00       	push   $0x802100
  8000a8:	e8 08 01 00 00       	call   8001b5 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	push   -0x1c(%ebp)
  8000b6:	e8 a6 0f 00 00       	call   801061 <ipc_send>
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
  80010c:	e8 a9 11 00 00       	call   8012ba <close_all>
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
  800217:	e8 94 1c 00 00       	call   801eb0 <__udivdi3>
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
  800255:	e8 76 1d 00 00       	call   801fd0 <__umoddi3>
  80025a:	83 c4 14             	add    $0x14,%esp
  80025d:	0f be 80 33 21 80 00 	movsbl 0x802133(%eax),%eax
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
  800317:	ff 24 85 80 22 80 00 	jmp    *0x802280(,%eax,4)
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
  8003e5:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	74 18                	je     800408 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003f0:	52                   	push   %edx
  8003f1:	68 fd 25 80 00       	push   $0x8025fd
  8003f6:	53                   	push   %ebx
  8003f7:	56                   	push   %esi
  8003f8:	e8 92 fe ff ff       	call   80028f <printfmt>
  8003fd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800400:	89 7d 14             	mov    %edi,0x14(%ebp)
  800403:	e9 66 02 00 00       	jmp    80066e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800408:	50                   	push   %eax
  800409:	68 4b 21 80 00       	push   $0x80214b
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
  800430:	b8 44 21 80 00       	mov    $0x802144,%eax
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
  800b3c:	68 3f 24 80 00       	push   $0x80243f
  800b41:	6a 2a                	push   $0x2a
  800b43:	68 5c 24 80 00       	push   $0x80245c
  800b48:	e8 42 12 00 00       	call   801d8f <_panic>

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
  800bbd:	68 3f 24 80 00       	push   $0x80243f
  800bc2:	6a 2a                	push   $0x2a
  800bc4:	68 5c 24 80 00       	push   $0x80245c
  800bc9:	e8 c1 11 00 00       	call   801d8f <_panic>

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
  800bff:	68 3f 24 80 00       	push   $0x80243f
  800c04:	6a 2a                	push   $0x2a
  800c06:	68 5c 24 80 00       	push   $0x80245c
  800c0b:	e8 7f 11 00 00       	call   801d8f <_panic>

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
  800c41:	68 3f 24 80 00       	push   $0x80243f
  800c46:	6a 2a                	push   $0x2a
  800c48:	68 5c 24 80 00       	push   $0x80245c
  800c4d:	e8 3d 11 00 00       	call   801d8f <_panic>

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
  800c83:	68 3f 24 80 00       	push   $0x80243f
  800c88:	6a 2a                	push   $0x2a
  800c8a:	68 5c 24 80 00       	push   $0x80245c
  800c8f:	e8 fb 10 00 00       	call   801d8f <_panic>

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
  800cc5:	68 3f 24 80 00       	push   $0x80243f
  800cca:	6a 2a                	push   $0x2a
  800ccc:	68 5c 24 80 00       	push   $0x80245c
  800cd1:	e8 b9 10 00 00       	call   801d8f <_panic>

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
  800d07:	68 3f 24 80 00       	push   $0x80243f
  800d0c:	6a 2a                	push   $0x2a
  800d0e:	68 5c 24 80 00       	push   $0x80245c
  800d13:	e8 77 10 00 00       	call   801d8f <_panic>

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
  800d6b:	68 3f 24 80 00       	push   $0x80243f
  800d70:	6a 2a                	push   $0x2a
  800d72:	68 5c 24 80 00       	push   $0x80245c
  800d77:	e8 13 10 00 00       	call   801d8f <_panic>

00800d7c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d84:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800d86:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d8a:	0f 84 8e 00 00 00    	je     800e1e <pgfault+0xa2>
  800d90:	89 f0                	mov    %esi,%eax
  800d92:	c1 e8 0c             	shr    $0xc,%eax
  800d95:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d9c:	f6 c4 08             	test   $0x8,%ah
  800d9f:	74 7d                	je     800e1e <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800da1:	e8 a7 fd ff ff       	call   800b4d <sys_getenvid>
  800da6:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800da8:	83 ec 04             	sub    $0x4,%esp
  800dab:	6a 07                	push   $0x7
  800dad:	68 00 f0 7f 00       	push   $0x7ff000
  800db2:	50                   	push   %eax
  800db3:	e8 d3 fd ff ff       	call   800b8b <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800db8:	83 c4 10             	add    $0x10,%esp
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	78 73                	js     800e32 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800dbf:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800dc5:	83 ec 04             	sub    $0x4,%esp
  800dc8:	68 00 10 00 00       	push   $0x1000
  800dcd:	56                   	push   %esi
  800dce:	68 00 f0 7f 00       	push   $0x7ff000
  800dd3:	e8 4d fb ff ff       	call   800925 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800dd8:	83 c4 08             	add    $0x8,%esp
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	e8 2e fe ff ff       	call   800c10 <sys_page_unmap>
  800de2:	83 c4 10             	add    $0x10,%esp
  800de5:	85 c0                	test   %eax,%eax
  800de7:	78 5b                	js     800e44 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800de9:	83 ec 0c             	sub    $0xc,%esp
  800dec:	6a 07                	push   $0x7
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	68 00 f0 7f 00       	push   $0x7ff000
  800df5:	53                   	push   %ebx
  800df6:	e8 d3 fd ff ff       	call   800bce <sys_page_map>
  800dfb:	83 c4 20             	add    $0x20,%esp
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	78 54                	js     800e56 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e02:	83 ec 08             	sub    $0x8,%esp
  800e05:	68 00 f0 7f 00       	push   $0x7ff000
  800e0a:	53                   	push   %ebx
  800e0b:	e8 00 fe ff ff       	call   800c10 <sys_page_unmap>
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	78 51                	js     800e68 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	68 6c 24 80 00       	push   $0x80246c
  800e26:	6a 1d                	push   $0x1d
  800e28:	68 e8 24 80 00       	push   $0x8024e8
  800e2d:	e8 5d 0f 00 00       	call   801d8f <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e32:	50                   	push   %eax
  800e33:	68 a4 24 80 00       	push   $0x8024a4
  800e38:	6a 29                	push   $0x29
  800e3a:	68 e8 24 80 00       	push   $0x8024e8
  800e3f:	e8 4b 0f 00 00       	call   801d8f <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e44:	50                   	push   %eax
  800e45:	68 c8 24 80 00       	push   $0x8024c8
  800e4a:	6a 2e                	push   $0x2e
  800e4c:	68 e8 24 80 00       	push   $0x8024e8
  800e51:	e8 39 0f 00 00       	call   801d8f <_panic>
		panic("pgfault: page map failed (%e)", r);
  800e56:	50                   	push   %eax
  800e57:	68 f3 24 80 00       	push   $0x8024f3
  800e5c:	6a 30                	push   $0x30
  800e5e:	68 e8 24 80 00       	push   $0x8024e8
  800e63:	e8 27 0f 00 00       	call   801d8f <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e68:	50                   	push   %eax
  800e69:	68 c8 24 80 00       	push   $0x8024c8
  800e6e:	6a 32                	push   $0x32
  800e70:	68 e8 24 80 00       	push   $0x8024e8
  800e75:	e8 15 0f 00 00       	call   801d8f <_panic>

00800e7a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800e83:	68 7c 0d 80 00       	push   $0x800d7c
  800e88:	e8 48 0f 00 00       	call   801dd5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e8d:	b8 07 00 00 00       	mov    $0x7,%eax
  800e92:	cd 30                	int    $0x30
  800e94:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	78 2d                	js     800ecb <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800e9e:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800ea3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ea7:	75 73                	jne    800f1c <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ea9:	e8 9f fc ff ff       	call   800b4d <sys_getenvid>
  800eae:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eb6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ebb:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800ec0:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800ecb:	50                   	push   %eax
  800ecc:	68 11 25 80 00       	push   $0x802511
  800ed1:	6a 78                	push   $0x78
  800ed3:	68 e8 24 80 00       	push   $0x8024e8
  800ed8:	e8 b2 0e 00 00       	call   801d8f <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	ff 75 e4             	push   -0x1c(%ebp)
  800ee3:	57                   	push   %edi
  800ee4:	ff 75 dc             	push   -0x24(%ebp)
  800ee7:	57                   	push   %edi
  800ee8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800eeb:	56                   	push   %esi
  800eec:	e8 dd fc ff ff       	call   800bce <sys_page_map>
	if(r<0) return r;
  800ef1:	83 c4 20             	add    $0x20,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 cb                	js     800ec3 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	ff 75 e4             	push   -0x1c(%ebp)
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	e8 c7 fc ff ff       	call   800bce <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f07:	83 c4 20             	add    $0x20,%esp
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	78 76                	js     800f84 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f0e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f14:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f1a:	74 75                	je     800f91 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f1c:	89 d8                	mov    %ebx,%eax
  800f1e:	c1 e8 16             	shr    $0x16,%eax
  800f21:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f28:	a8 01                	test   $0x1,%al
  800f2a:	74 e2                	je     800f0e <fork+0x94>
  800f2c:	89 de                	mov    %ebx,%esi
  800f2e:	c1 ee 0c             	shr    $0xc,%esi
  800f31:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f38:	a8 01                	test   $0x1,%al
  800f3a:	74 d2                	je     800f0e <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  800f3c:	e8 0c fc ff ff       	call   800b4d <sys_getenvid>
  800f41:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800f44:	89 f7                	mov    %esi,%edi
  800f46:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800f49:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f50:	89 c1                	mov    %eax,%ecx
  800f52:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800f58:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800f5b:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800f62:	f6 c6 04             	test   $0x4,%dh
  800f65:	0f 85 72 ff ff ff    	jne    800edd <fork+0x63>
		perm &= ~PTE_W;
  800f6b:	25 05 0e 00 00       	and    $0xe05,%eax
  800f70:	80 cc 08             	or     $0x8,%ah
  800f73:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800f79:	0f 44 c1             	cmove  %ecx,%eax
  800f7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f7f:	e9 59 ff ff ff       	jmp    800edd <fork+0x63>
  800f84:	ba 00 00 00 00       	mov    $0x0,%edx
  800f89:	0f 4f c2             	cmovg  %edx,%eax
  800f8c:	e9 32 ff ff ff       	jmp    800ec3 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	6a 07                	push   $0x7
  800f96:	68 00 f0 bf ee       	push   $0xeebff000
  800f9b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800f9e:	57                   	push   %edi
  800f9f:	e8 e7 fb ff ff       	call   800b8b <sys_page_alloc>
	if(r<0) return r;
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	0f 88 14 ff ff ff    	js     800ec3 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	68 4b 1e 80 00       	push   $0x801e4b
  800fb7:	57                   	push   %edi
  800fb8:	e8 19 fd ff ff       	call   800cd6 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	0f 88 fb fe ff ff    	js     800ec3 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fc8:	83 ec 08             	sub    $0x8,%esp
  800fcb:	6a 02                	push   $0x2
  800fcd:	57                   	push   %edi
  800fce:	e8 7f fc ff ff       	call   800c52 <sys_env_set_status>
	if(r<0) return r;
  800fd3:	83 c4 10             	add    $0x10,%esp
	return envid;
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	0f 49 c7             	cmovns %edi,%eax
  800fdb:	e9 e3 fe ff ff       	jmp    800ec3 <fork+0x49>

00800fe0 <sfork>:

// Challenge!
int
sfork(void)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fe6:	68 21 25 80 00       	push   $0x802521
  800feb:	68 a1 00 00 00       	push   $0xa1
  800ff0:	68 e8 24 80 00       	push   $0x8024e8
  800ff5:	e8 95 0d 00 00       	call   801d8f <_panic>

00800ffa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	56                   	push   %esi
  800ffe:	53                   	push   %ebx
  800fff:	8b 75 08             	mov    0x8(%ebp),%esi
  801002:	8b 45 0c             	mov    0xc(%ebp),%eax
  801005:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801008:	85 c0                	test   %eax,%eax
  80100a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80100f:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	50                   	push   %eax
  801016:	e8 20 fd ff ff       	call   800d3b <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	85 f6                	test   %esi,%esi
  801020:	74 14                	je     801036 <ipc_recv+0x3c>
  801022:	ba 00 00 00 00       	mov    $0x0,%edx
  801027:	85 c0                	test   %eax,%eax
  801029:	78 09                	js     801034 <ipc_recv+0x3a>
  80102b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801031:	8b 52 74             	mov    0x74(%edx),%edx
  801034:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801036:	85 db                	test   %ebx,%ebx
  801038:	74 14                	je     80104e <ipc_recv+0x54>
  80103a:	ba 00 00 00 00       	mov    $0x0,%edx
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 09                	js     80104c <ipc_recv+0x52>
  801043:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801049:	8b 52 78             	mov    0x78(%edx),%edx
  80104c:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 08                	js     80105a <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801052:	a1 00 40 80 00       	mov    0x804000,%eax
  801057:	8b 40 70             	mov    0x70(%eax),%eax
}
  80105a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80106d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801070:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801073:	85 db                	test   %ebx,%ebx
  801075:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80107a:	0f 44 d8             	cmove  %eax,%ebx
  80107d:	eb 05                	jmp    801084 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80107f:	e8 e8 fa ff ff       	call   800b6c <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801084:	ff 75 14             	push   0x14(%ebp)
  801087:	53                   	push   %ebx
  801088:	56                   	push   %esi
  801089:	57                   	push   %edi
  80108a:	e8 89 fc ff ff       	call   800d18 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801095:	74 e8                	je     80107f <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801097:	85 c0                	test   %eax,%eax
  801099:	78 08                	js     8010a3 <ipc_send+0x42>
	}while (r<0);

}
  80109b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8010a3:	50                   	push   %eax
  8010a4:	68 37 25 80 00       	push   $0x802537
  8010a9:	6a 3d                	push   $0x3d
  8010ab:	68 4b 25 80 00       	push   $0x80254b
  8010b0:	e8 da 0c 00 00       	call   801d8f <_panic>

008010b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010c0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010c3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010c9:	8b 52 50             	mov    0x50(%edx),%edx
  8010cc:	39 ca                	cmp    %ecx,%edx
  8010ce:	74 11                	je     8010e1 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8010d0:	83 c0 01             	add    $0x1,%eax
  8010d3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010d8:	75 e6                	jne    8010c0 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
  8010df:	eb 0b                	jmp    8010ec <ipc_find_env+0x37>
			return envs[i].env_id;
  8010e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010e9:	8b 40 48             	mov    0x48(%eax),%eax
}
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f9:	c1 e8 0c             	shr    $0xc,%eax
}
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801101:	8b 45 08             	mov    0x8(%ebp),%eax
  801104:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801109:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80110e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80111d:	89 c2                	mov    %eax,%edx
  80111f:	c1 ea 16             	shr    $0x16,%edx
  801122:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801129:	f6 c2 01             	test   $0x1,%dl
  80112c:	74 29                	je     801157 <fd_alloc+0x42>
  80112e:	89 c2                	mov    %eax,%edx
  801130:	c1 ea 0c             	shr    $0xc,%edx
  801133:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113a:	f6 c2 01             	test   $0x1,%dl
  80113d:	74 18                	je     801157 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80113f:	05 00 10 00 00       	add    $0x1000,%eax
  801144:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801149:	75 d2                	jne    80111d <fd_alloc+0x8>
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801150:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801155:	eb 05                	jmp    80115c <fd_alloc+0x47>
			return 0;
  801157:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80115c:	8b 55 08             	mov    0x8(%ebp),%edx
  80115f:	89 02                	mov    %eax,(%edx)
}
  801161:	89 c8                	mov    %ecx,%eax
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80116b:	83 f8 1f             	cmp    $0x1f,%eax
  80116e:	77 30                	ja     8011a0 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801170:	c1 e0 0c             	shl    $0xc,%eax
  801173:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801178:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80117e:	f6 c2 01             	test   $0x1,%dl
  801181:	74 24                	je     8011a7 <fd_lookup+0x42>
  801183:	89 c2                	mov    %eax,%edx
  801185:	c1 ea 0c             	shr    $0xc,%edx
  801188:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118f:	f6 c2 01             	test   $0x1,%dl
  801192:	74 1a                	je     8011ae <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801194:	8b 55 0c             	mov    0xc(%ebp),%edx
  801197:	89 02                	mov    %eax,(%edx)
	return 0;
  801199:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    
		return -E_INVAL;
  8011a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a5:	eb f7                	jmp    80119e <fd_lookup+0x39>
		return -E_INVAL;
  8011a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ac:	eb f0                	jmp    80119e <fd_lookup+0x39>
  8011ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b3:	eb e9                	jmp    80119e <fd_lookup+0x39>

008011b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 04             	sub    $0x4,%esp
  8011bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bf:	b8 d4 25 80 00       	mov    $0x8025d4,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  8011c4:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8011c9:	39 13                	cmp    %edx,(%ebx)
  8011cb:	74 32                	je     8011ff <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  8011cd:	83 c0 04             	add    $0x4,%eax
  8011d0:	8b 18                	mov    (%eax),%ebx
  8011d2:	85 db                	test   %ebx,%ebx
  8011d4:	75 f3                	jne    8011c9 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011d6:	a1 00 40 80 00       	mov    0x804000,%eax
  8011db:	8b 40 48             	mov    0x48(%eax),%eax
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	52                   	push   %edx
  8011e2:	50                   	push   %eax
  8011e3:	68 58 25 80 00       	push   $0x802558
  8011e8:	e8 c8 ef ff ff       	call   8001b5 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8011f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f8:	89 1a                	mov    %ebx,(%edx)
}
  8011fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    
			return 0;
  8011ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801204:	eb ef                	jmp    8011f5 <dev_lookup+0x40>

00801206 <fd_close>:
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	57                   	push   %edi
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 24             	sub    $0x24,%esp
  80120f:	8b 75 08             	mov    0x8(%ebp),%esi
  801212:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801215:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801218:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801219:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80121f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801222:	50                   	push   %eax
  801223:	e8 3d ff ff ff       	call   801165 <fd_lookup>
  801228:	89 c3                	mov    %eax,%ebx
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 05                	js     801236 <fd_close+0x30>
	    || fd != fd2)
  801231:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801234:	74 16                	je     80124c <fd_close+0x46>
		return (must_exist ? r : 0);
  801236:	89 f8                	mov    %edi,%eax
  801238:	84 c0                	test   %al,%al
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
  80123f:	0f 44 d8             	cmove  %eax,%ebx
}
  801242:	89 d8                	mov    %ebx,%eax
  801244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5f                   	pop    %edi
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801252:	50                   	push   %eax
  801253:	ff 36                	push   (%esi)
  801255:	e8 5b ff ff ff       	call   8011b5 <dev_lookup>
  80125a:	89 c3                	mov    %eax,%ebx
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 1a                	js     80127d <fd_close+0x77>
		if (dev->dev_close)
  801263:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801266:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801269:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80126e:	85 c0                	test   %eax,%eax
  801270:	74 0b                	je     80127d <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801272:	83 ec 0c             	sub    $0xc,%esp
  801275:	56                   	push   %esi
  801276:	ff d0                	call   *%eax
  801278:	89 c3                	mov    %eax,%ebx
  80127a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	56                   	push   %esi
  801281:	6a 00                	push   $0x0
  801283:	e8 88 f9 ff ff       	call   800c10 <sys_page_unmap>
	return r;
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	eb b5                	jmp    801242 <fd_close+0x3c>

0080128d <close>:

int
close(int fdnum)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801293:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801296:	50                   	push   %eax
  801297:	ff 75 08             	push   0x8(%ebp)
  80129a:	e8 c6 fe ff ff       	call   801165 <fd_lookup>
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	79 02                	jns    8012a8 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    
		return fd_close(fd, 1);
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	6a 01                	push   $0x1
  8012ad:	ff 75 f4             	push   -0xc(%ebp)
  8012b0:	e8 51 ff ff ff       	call   801206 <fd_close>
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	eb ec                	jmp    8012a6 <close+0x19>

008012ba <close_all>:

void
close_all(void)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	53                   	push   %ebx
  8012ca:	e8 be ff ff ff       	call   80128d <close>
	for (i = 0; i < MAXFD; i++)
  8012cf:	83 c3 01             	add    $0x1,%ebx
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	83 fb 20             	cmp    $0x20,%ebx
  8012d8:	75 ec                	jne    8012c6 <close_all+0xc>
}
  8012da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	57                   	push   %edi
  8012e3:	56                   	push   %esi
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	ff 75 08             	push   0x8(%ebp)
  8012ef:	e8 71 fe ff ff       	call   801165 <fd_lookup>
  8012f4:	89 c3                	mov    %eax,%ebx
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 7f                	js     80137c <dup+0x9d>
		return r;
	close(newfdnum);
  8012fd:	83 ec 0c             	sub    $0xc,%esp
  801300:	ff 75 0c             	push   0xc(%ebp)
  801303:	e8 85 ff ff ff       	call   80128d <close>

	newfd = INDEX2FD(newfdnum);
  801308:	8b 75 0c             	mov    0xc(%ebp),%esi
  80130b:	c1 e6 0c             	shl    $0xc,%esi
  80130e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801317:	89 3c 24             	mov    %edi,(%esp)
  80131a:	e8 df fd ff ff       	call   8010fe <fd2data>
  80131f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801321:	89 34 24             	mov    %esi,(%esp)
  801324:	e8 d5 fd ff ff       	call   8010fe <fd2data>
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80132f:	89 d8                	mov    %ebx,%eax
  801331:	c1 e8 16             	shr    $0x16,%eax
  801334:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80133b:	a8 01                	test   $0x1,%al
  80133d:	74 11                	je     801350 <dup+0x71>
  80133f:	89 d8                	mov    %ebx,%eax
  801341:	c1 e8 0c             	shr    $0xc,%eax
  801344:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80134b:	f6 c2 01             	test   $0x1,%dl
  80134e:	75 36                	jne    801386 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801350:	89 f8                	mov    %edi,%eax
  801352:	c1 e8 0c             	shr    $0xc,%eax
  801355:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	25 07 0e 00 00       	and    $0xe07,%eax
  801364:	50                   	push   %eax
  801365:	56                   	push   %esi
  801366:	6a 00                	push   $0x0
  801368:	57                   	push   %edi
  801369:	6a 00                	push   $0x0
  80136b:	e8 5e f8 ff ff       	call   800bce <sys_page_map>
  801370:	89 c3                	mov    %eax,%ebx
  801372:	83 c4 20             	add    $0x20,%esp
  801375:	85 c0                	test   %eax,%eax
  801377:	78 33                	js     8013ac <dup+0xcd>
		goto err;

	return newfdnum;
  801379:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801386:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80138d:	83 ec 0c             	sub    $0xc,%esp
  801390:	25 07 0e 00 00       	and    $0xe07,%eax
  801395:	50                   	push   %eax
  801396:	ff 75 d4             	push   -0x2c(%ebp)
  801399:	6a 00                	push   $0x0
  80139b:	53                   	push   %ebx
  80139c:	6a 00                	push   $0x0
  80139e:	e8 2b f8 ff ff       	call   800bce <sys_page_map>
  8013a3:	89 c3                	mov    %eax,%ebx
  8013a5:	83 c4 20             	add    $0x20,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	79 a4                	jns    801350 <dup+0x71>
	sys_page_unmap(0, newfd);
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	56                   	push   %esi
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 59 f8 ff ff       	call   800c10 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013b7:	83 c4 08             	add    $0x8,%esp
  8013ba:	ff 75 d4             	push   -0x2c(%ebp)
  8013bd:	6a 00                	push   $0x0
  8013bf:	e8 4c f8 ff ff       	call   800c10 <sys_page_unmap>
	return r;
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	eb b3                	jmp    80137c <dup+0x9d>

008013c9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	56                   	push   %esi
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 18             	sub    $0x18,%esp
  8013d1:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d7:	50                   	push   %eax
  8013d8:	56                   	push   %esi
  8013d9:	e8 87 fd ff ff       	call   801165 <fd_lookup>
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	78 3c                	js     801421 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	ff 33                	push   (%ebx)
  8013f1:	e8 bf fd ff ff       	call   8011b5 <dev_lookup>
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	78 24                	js     801421 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013fd:	8b 43 08             	mov    0x8(%ebx),%eax
  801400:	83 e0 03             	and    $0x3,%eax
  801403:	83 f8 01             	cmp    $0x1,%eax
  801406:	74 20                	je     801428 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801408:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140b:	8b 40 08             	mov    0x8(%eax),%eax
  80140e:	85 c0                	test   %eax,%eax
  801410:	74 37                	je     801449 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801412:	83 ec 04             	sub    $0x4,%esp
  801415:	ff 75 10             	push   0x10(%ebp)
  801418:	ff 75 0c             	push   0xc(%ebp)
  80141b:	53                   	push   %ebx
  80141c:	ff d0                	call   *%eax
  80141e:	83 c4 10             	add    $0x10,%esp
}
  801421:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801424:	5b                   	pop    %ebx
  801425:	5e                   	pop    %esi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801428:	a1 00 40 80 00       	mov    0x804000,%eax
  80142d:	8b 40 48             	mov    0x48(%eax),%eax
  801430:	83 ec 04             	sub    $0x4,%esp
  801433:	56                   	push   %esi
  801434:	50                   	push   %eax
  801435:	68 99 25 80 00       	push   $0x802599
  80143a:	e8 76 ed ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801447:	eb d8                	jmp    801421 <read+0x58>
		return -E_NOT_SUPP;
  801449:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80144e:	eb d1                	jmp    801421 <read+0x58>

00801450 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	57                   	push   %edi
  801454:	56                   	push   %esi
  801455:	53                   	push   %ebx
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80145f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801464:	eb 02                	jmp    801468 <readn+0x18>
  801466:	01 c3                	add    %eax,%ebx
  801468:	39 f3                	cmp    %esi,%ebx
  80146a:	73 21                	jae    80148d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	89 f0                	mov    %esi,%eax
  801471:	29 d8                	sub    %ebx,%eax
  801473:	50                   	push   %eax
  801474:	89 d8                	mov    %ebx,%eax
  801476:	03 45 0c             	add    0xc(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	57                   	push   %edi
  80147b:	e8 49 ff ff ff       	call   8013c9 <read>
		if (m < 0)
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 04                	js     80148b <readn+0x3b>
			return m;
		if (m == 0)
  801487:	75 dd                	jne    801466 <readn+0x16>
  801489:	eb 02                	jmp    80148d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80148b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80148d:	89 d8                	mov    %ebx,%eax
  80148f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801492:	5b                   	pop    %ebx
  801493:	5e                   	pop    %esi
  801494:	5f                   	pop    %edi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	56                   	push   %esi
  80149b:	53                   	push   %ebx
  80149c:	83 ec 18             	sub    $0x18,%esp
  80149f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	53                   	push   %ebx
  8014a7:	e8 b9 fc ff ff       	call   801165 <fd_lookup>
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	78 37                	js     8014ea <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	ff 36                	push   (%esi)
  8014bf:	e8 f1 fc ff ff       	call   8011b5 <dev_lookup>
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 1f                	js     8014ea <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014cb:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014cf:	74 20                	je     8014f1 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	74 37                	je     801512 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014db:	83 ec 04             	sub    $0x4,%esp
  8014de:	ff 75 10             	push   0x10(%ebp)
  8014e1:	ff 75 0c             	push   0xc(%ebp)
  8014e4:	56                   	push   %esi
  8014e5:	ff d0                	call   *%eax
  8014e7:	83 c4 10             	add    $0x10,%esp
}
  8014ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ed:	5b                   	pop    %ebx
  8014ee:	5e                   	pop    %esi
  8014ef:	5d                   	pop    %ebp
  8014f0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f1:	a1 00 40 80 00       	mov    0x804000,%eax
  8014f6:	8b 40 48             	mov    0x48(%eax),%eax
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	53                   	push   %ebx
  8014fd:	50                   	push   %eax
  8014fe:	68 b5 25 80 00       	push   $0x8025b5
  801503:	e8 ad ec ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801510:	eb d8                	jmp    8014ea <write+0x53>
		return -E_NOT_SUPP;
  801512:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801517:	eb d1                	jmp    8014ea <write+0x53>

00801519 <seek>:

int
seek(int fdnum, off_t offset)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	ff 75 08             	push   0x8(%ebp)
  801526:	e8 3a fc ff ff       	call   801165 <fd_lookup>
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 0e                	js     801540 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801532:	8b 55 0c             	mov    0xc(%ebp),%edx
  801535:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801538:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80153b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	83 ec 18             	sub    $0x18,%esp
  80154a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	53                   	push   %ebx
  801552:	e8 0e fc ff ff       	call   801165 <fd_lookup>
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 34                	js     801592 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801567:	50                   	push   %eax
  801568:	ff 36                	push   (%esi)
  80156a:	e8 46 fc ff ff       	call   8011b5 <dev_lookup>
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	78 1c                	js     801592 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801576:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80157a:	74 1d                	je     801599 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80157c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157f:	8b 40 18             	mov    0x18(%eax),%eax
  801582:	85 c0                	test   %eax,%eax
  801584:	74 34                	je     8015ba <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	ff 75 0c             	push   0xc(%ebp)
  80158c:	56                   	push   %esi
  80158d:	ff d0                	call   *%eax
  80158f:	83 c4 10             	add    $0x10,%esp
}
  801592:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801595:	5b                   	pop    %ebx
  801596:	5e                   	pop    %esi
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    
			thisenv->env_id, fdnum);
  801599:	a1 00 40 80 00       	mov    0x804000,%eax
  80159e:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a1:	83 ec 04             	sub    $0x4,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	50                   	push   %eax
  8015a6:	68 78 25 80 00       	push   $0x802578
  8015ab:	e8 05 ec ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b8:	eb d8                	jmp    801592 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8015ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015bf:	eb d1                	jmp    801592 <ftruncate+0x50>

008015c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
  8015c6:	83 ec 18             	sub    $0x18,%esp
  8015c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	ff 75 08             	push   0x8(%ebp)
  8015d3:	e8 8d fb ff ff       	call   801165 <fd_lookup>
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 49                	js     801628 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015df:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	ff 36                	push   (%esi)
  8015eb:	e8 c5 fb ff ff       	call   8011b5 <dev_lookup>
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 31                	js     801628 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8015f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015fe:	74 2f                	je     80162f <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801600:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801603:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80160a:	00 00 00 
	stat->st_isdir = 0;
  80160d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801614:	00 00 00 
	stat->st_dev = dev;
  801617:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	53                   	push   %ebx
  801621:	56                   	push   %esi
  801622:	ff 50 14             	call   *0x14(%eax)
  801625:	83 c4 10             	add    $0x10,%esp
}
  801628:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    
		return -E_NOT_SUPP;
  80162f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801634:	eb f2                	jmp    801628 <fstat+0x67>

00801636 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	6a 00                	push   $0x0
  801640:	ff 75 08             	push   0x8(%ebp)
  801643:	e8 e4 01 00 00       	call   80182c <open>
  801648:	89 c3                	mov    %eax,%ebx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 1b                	js     80166c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	ff 75 0c             	push   0xc(%ebp)
  801657:	50                   	push   %eax
  801658:	e8 64 ff ff ff       	call   8015c1 <fstat>
  80165d:	89 c6                	mov    %eax,%esi
	close(fd);
  80165f:	89 1c 24             	mov    %ebx,(%esp)
  801662:	e8 26 fc ff ff       	call   80128d <close>
	return r;
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	89 f3                	mov    %esi,%ebx
}
  80166c:	89 d8                	mov    %ebx,%eax
  80166e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801671:	5b                   	pop    %ebx
  801672:	5e                   	pop    %esi
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	56                   	push   %esi
  801679:	53                   	push   %ebx
  80167a:	89 c6                	mov    %eax,%esi
  80167c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80167e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801685:	74 27                	je     8016ae <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801687:	6a 07                	push   $0x7
  801689:	68 00 50 80 00       	push   $0x805000
  80168e:	56                   	push   %esi
  80168f:	ff 35 00 60 80 00    	push   0x806000
  801695:	e8 c7 f9 ff ff       	call   801061 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80169a:	83 c4 0c             	add    $0xc,%esp
  80169d:	6a 00                	push   $0x0
  80169f:	53                   	push   %ebx
  8016a0:	6a 00                	push   $0x0
  8016a2:	e8 53 f9 ff ff       	call   800ffa <ipc_recv>
}
  8016a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ae:	83 ec 0c             	sub    $0xc,%esp
  8016b1:	6a 01                	push   $0x1
  8016b3:	e8 fd f9 ff ff       	call   8010b5 <ipc_find_env>
  8016b8:	a3 00 60 80 00       	mov    %eax,0x806000
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	eb c5                	jmp    801687 <fsipc+0x12>

008016c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016db:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e5:	e8 8b ff ff ff       	call   801675 <fsipc>
}
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <devfile_flush>:
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801702:	b8 06 00 00 00       	mov    $0x6,%eax
  801707:	e8 69 ff ff ff       	call   801675 <fsipc>
}
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <devfile_stat>:
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	8b 40 0c             	mov    0xc(%eax),%eax
  80171e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801723:	ba 00 00 00 00       	mov    $0x0,%edx
  801728:	b8 05 00 00 00       	mov    $0x5,%eax
  80172d:	e8 43 ff ff ff       	call   801675 <fsipc>
  801732:	85 c0                	test   %eax,%eax
  801734:	78 2c                	js     801762 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801736:	83 ec 08             	sub    $0x8,%esp
  801739:	68 00 50 80 00       	push   $0x805000
  80173e:	53                   	push   %ebx
  80173f:	e8 4b f0 ff ff       	call   80078f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801744:	a1 80 50 80 00       	mov    0x805080,%eax
  801749:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80174f:	a1 84 50 80 00       	mov    0x805084,%eax
  801754:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <devfile_write>:
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	83 ec 0c             	sub    $0xc,%esp
  80176d:	8b 45 10             	mov    0x10(%ebp),%eax
  801770:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801775:	39 d0                	cmp    %edx,%eax
  801777:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80177a:	8b 55 08             	mov    0x8(%ebp),%edx
  80177d:	8b 52 0c             	mov    0xc(%edx),%edx
  801780:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801786:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80178b:	50                   	push   %eax
  80178c:	ff 75 0c             	push   0xc(%ebp)
  80178f:	68 08 50 80 00       	push   $0x805008
  801794:	e8 8c f1 ff ff       	call   800925 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801799:	ba 00 00 00 00       	mov    $0x0,%edx
  80179e:	b8 04 00 00 00       	mov    $0x4,%eax
  8017a3:	e8 cd fe ff ff       	call   801675 <fsipc>
}
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <devfile_read>:
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
  8017af:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017bd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8017cd:	e8 a3 fe ff ff       	call   801675 <fsipc>
  8017d2:	89 c3                	mov    %eax,%ebx
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 1f                	js     8017f7 <devfile_read+0x4d>
	assert(r <= n);
  8017d8:	39 f0                	cmp    %esi,%eax
  8017da:	77 24                	ja     801800 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017dc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017e1:	7f 33                	jg     801816 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	50                   	push   %eax
  8017e7:	68 00 50 80 00       	push   $0x805000
  8017ec:	ff 75 0c             	push   0xc(%ebp)
  8017ef:	e8 31 f1 ff ff       	call   800925 <memmove>
	return r;
  8017f4:	83 c4 10             	add    $0x10,%esp
}
  8017f7:	89 d8                	mov    %ebx,%eax
  8017f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5e                   	pop    %esi
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    
	assert(r <= n);
  801800:	68 e4 25 80 00       	push   $0x8025e4
  801805:	68 eb 25 80 00       	push   $0x8025eb
  80180a:	6a 7c                	push   $0x7c
  80180c:	68 00 26 80 00       	push   $0x802600
  801811:	e8 79 05 00 00       	call   801d8f <_panic>
	assert(r <= PGSIZE);
  801816:	68 0b 26 80 00       	push   $0x80260b
  80181b:	68 eb 25 80 00       	push   $0x8025eb
  801820:	6a 7d                	push   $0x7d
  801822:	68 00 26 80 00       	push   $0x802600
  801827:	e8 63 05 00 00       	call   801d8f <_panic>

0080182c <open>:
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	56                   	push   %esi
  801830:	53                   	push   %ebx
  801831:	83 ec 1c             	sub    $0x1c,%esp
  801834:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801837:	56                   	push   %esi
  801838:	e8 17 ef ff ff       	call   800754 <strlen>
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801845:	7f 6c                	jg     8018b3 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184d:	50                   	push   %eax
  80184e:	e8 c2 f8 ff ff       	call   801115 <fd_alloc>
  801853:	89 c3                	mov    %eax,%ebx
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 3c                	js     801898 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80185c:	83 ec 08             	sub    $0x8,%esp
  80185f:	56                   	push   %esi
  801860:	68 00 50 80 00       	push   $0x805000
  801865:	e8 25 ef ff ff       	call   80078f <strcpy>
	fsipcbuf.open.req_omode = mode;
  80186a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186d:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801872:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801875:	b8 01 00 00 00       	mov    $0x1,%eax
  80187a:	e8 f6 fd ff ff       	call   801675 <fsipc>
  80187f:	89 c3                	mov    %eax,%ebx
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	85 c0                	test   %eax,%eax
  801886:	78 19                	js     8018a1 <open+0x75>
	return fd2num(fd);
  801888:	83 ec 0c             	sub    $0xc,%esp
  80188b:	ff 75 f4             	push   -0xc(%ebp)
  80188e:	e8 5b f8 ff ff       	call   8010ee <fd2num>
  801893:	89 c3                	mov    %eax,%ebx
  801895:	83 c4 10             	add    $0x10,%esp
}
  801898:	89 d8                	mov    %ebx,%eax
  80189a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189d:	5b                   	pop    %ebx
  80189e:	5e                   	pop    %esi
  80189f:	5d                   	pop    %ebp
  8018a0:	c3                   	ret    
		fd_close(fd, 0);
  8018a1:	83 ec 08             	sub    $0x8,%esp
  8018a4:	6a 00                	push   $0x0
  8018a6:	ff 75 f4             	push   -0xc(%ebp)
  8018a9:	e8 58 f9 ff ff       	call   801206 <fd_close>
		return r;
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	eb e5                	jmp    801898 <open+0x6c>
		return -E_BAD_PATH;
  8018b3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018b8:	eb de                	jmp    801898 <open+0x6c>

008018ba <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8018ca:	e8 a6 fd ff ff       	call   801675 <fsipc>
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018d9:	83 ec 0c             	sub    $0xc,%esp
  8018dc:	ff 75 08             	push   0x8(%ebp)
  8018df:	e8 1a f8 ff ff       	call   8010fe <fd2data>
  8018e4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018e6:	83 c4 08             	add    $0x8,%esp
  8018e9:	68 17 26 80 00       	push   $0x802617
  8018ee:	53                   	push   %ebx
  8018ef:	e8 9b ee ff ff       	call   80078f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018f4:	8b 46 04             	mov    0x4(%esi),%eax
  8018f7:	2b 06                	sub    (%esi),%eax
  8018f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018ff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801906:	00 00 00 
	stat->st_dev = &devpipe;
  801909:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801910:	30 80 00 
	return 0;
}
  801913:	b8 00 00 00 00       	mov    $0x0,%eax
  801918:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191b:	5b                   	pop    %ebx
  80191c:	5e                   	pop    %esi
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	53                   	push   %ebx
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801929:	53                   	push   %ebx
  80192a:	6a 00                	push   $0x0
  80192c:	e8 df f2 ff ff       	call   800c10 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801931:	89 1c 24             	mov    %ebx,(%esp)
  801934:	e8 c5 f7 ff ff       	call   8010fe <fd2data>
  801939:	83 c4 08             	add    $0x8,%esp
  80193c:	50                   	push   %eax
  80193d:	6a 00                	push   $0x0
  80193f:	e8 cc f2 ff ff       	call   800c10 <sys_page_unmap>
}
  801944:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801947:	c9                   	leave  
  801948:	c3                   	ret    

00801949 <_pipeisclosed>:
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	57                   	push   %edi
  80194d:	56                   	push   %esi
  80194e:	53                   	push   %ebx
  80194f:	83 ec 1c             	sub    $0x1c,%esp
  801952:	89 c7                	mov    %eax,%edi
  801954:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801956:	a1 00 40 80 00       	mov    0x804000,%eax
  80195b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	57                   	push   %edi
  801962:	e8 0a 05 00 00       	call   801e71 <pageref>
  801967:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80196a:	89 34 24             	mov    %esi,(%esp)
  80196d:	e8 ff 04 00 00       	call   801e71 <pageref>
		nn = thisenv->env_runs;
  801972:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801978:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	39 cb                	cmp    %ecx,%ebx
  801980:	74 1b                	je     80199d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801982:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801985:	75 cf                	jne    801956 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801987:	8b 42 58             	mov    0x58(%edx),%eax
  80198a:	6a 01                	push   $0x1
  80198c:	50                   	push   %eax
  80198d:	53                   	push   %ebx
  80198e:	68 1e 26 80 00       	push   $0x80261e
  801993:	e8 1d e8 ff ff       	call   8001b5 <cprintf>
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	eb b9                	jmp    801956 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80199d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019a0:	0f 94 c0             	sete   %al
  8019a3:	0f b6 c0             	movzbl %al,%eax
}
  8019a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a9:	5b                   	pop    %ebx
  8019aa:	5e                   	pop    %esi
  8019ab:	5f                   	pop    %edi
  8019ac:	5d                   	pop    %ebp
  8019ad:	c3                   	ret    

008019ae <devpipe_write>:
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	57                   	push   %edi
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 28             	sub    $0x28,%esp
  8019b7:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019ba:	56                   	push   %esi
  8019bb:	e8 3e f7 ff ff       	call   8010fe <fd2data>
  8019c0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019cd:	75 09                	jne    8019d8 <devpipe_write+0x2a>
	return i;
  8019cf:	89 f8                	mov    %edi,%eax
  8019d1:	eb 23                	jmp    8019f6 <devpipe_write+0x48>
			sys_yield();
  8019d3:	e8 94 f1 ff ff       	call   800b6c <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8019db:	8b 0b                	mov    (%ebx),%ecx
  8019dd:	8d 51 20             	lea    0x20(%ecx),%edx
  8019e0:	39 d0                	cmp    %edx,%eax
  8019e2:	72 1a                	jb     8019fe <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8019e4:	89 da                	mov    %ebx,%edx
  8019e6:	89 f0                	mov    %esi,%eax
  8019e8:	e8 5c ff ff ff       	call   801949 <_pipeisclosed>
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	74 e2                	je     8019d3 <devpipe_write+0x25>
				return 0;
  8019f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f9:	5b                   	pop    %ebx
  8019fa:	5e                   	pop    %esi
  8019fb:	5f                   	pop    %edi
  8019fc:	5d                   	pop    %ebp
  8019fd:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a01:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a05:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a08:	89 c2                	mov    %eax,%edx
  801a0a:	c1 fa 1f             	sar    $0x1f,%edx
  801a0d:	89 d1                	mov    %edx,%ecx
  801a0f:	c1 e9 1b             	shr    $0x1b,%ecx
  801a12:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a15:	83 e2 1f             	and    $0x1f,%edx
  801a18:	29 ca                	sub    %ecx,%edx
  801a1a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a1e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a22:	83 c0 01             	add    $0x1,%eax
  801a25:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a28:	83 c7 01             	add    $0x1,%edi
  801a2b:	eb 9d                	jmp    8019ca <devpipe_write+0x1c>

00801a2d <devpipe_read>:
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	57                   	push   %edi
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	83 ec 18             	sub    $0x18,%esp
  801a36:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a39:	57                   	push   %edi
  801a3a:	e8 bf f6 ff ff       	call   8010fe <fd2data>
  801a3f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	be 00 00 00 00       	mov    $0x0,%esi
  801a49:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a4c:	75 13                	jne    801a61 <devpipe_read+0x34>
	return i;
  801a4e:	89 f0                	mov    %esi,%eax
  801a50:	eb 02                	jmp    801a54 <devpipe_read+0x27>
				return i;
  801a52:	89 f0                	mov    %esi,%eax
}
  801a54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5f                   	pop    %edi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    
			sys_yield();
  801a5c:	e8 0b f1 ff ff       	call   800b6c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801a61:	8b 03                	mov    (%ebx),%eax
  801a63:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a66:	75 18                	jne    801a80 <devpipe_read+0x53>
			if (i > 0)
  801a68:	85 f6                	test   %esi,%esi
  801a6a:	75 e6                	jne    801a52 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801a6c:	89 da                	mov    %ebx,%edx
  801a6e:	89 f8                	mov    %edi,%eax
  801a70:	e8 d4 fe ff ff       	call   801949 <_pipeisclosed>
  801a75:	85 c0                	test   %eax,%eax
  801a77:	74 e3                	je     801a5c <devpipe_read+0x2f>
				return 0;
  801a79:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7e:	eb d4                	jmp    801a54 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a80:	99                   	cltd   
  801a81:	c1 ea 1b             	shr    $0x1b,%edx
  801a84:	01 d0                	add    %edx,%eax
  801a86:	83 e0 1f             	and    $0x1f,%eax
  801a89:	29 d0                	sub    %edx,%eax
  801a8b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a93:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a96:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a99:	83 c6 01             	add    $0x1,%esi
  801a9c:	eb ab                	jmp    801a49 <devpipe_read+0x1c>

00801a9e <pipe>:
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801aa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa9:	50                   	push   %eax
  801aaa:	e8 66 f6 ff ff       	call   801115 <fd_alloc>
  801aaf:	89 c3                	mov    %eax,%ebx
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	0f 88 23 01 00 00    	js     801bdf <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abc:	83 ec 04             	sub    $0x4,%esp
  801abf:	68 07 04 00 00       	push   $0x407
  801ac4:	ff 75 f4             	push   -0xc(%ebp)
  801ac7:	6a 00                	push   $0x0
  801ac9:	e8 bd f0 ff ff       	call   800b8b <sys_page_alloc>
  801ace:	89 c3                	mov    %eax,%ebx
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	0f 88 04 01 00 00    	js     801bdf <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ae1:	50                   	push   %eax
  801ae2:	e8 2e f6 ff ff       	call   801115 <fd_alloc>
  801ae7:	89 c3                	mov    %eax,%ebx
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	85 c0                	test   %eax,%eax
  801aee:	0f 88 db 00 00 00    	js     801bcf <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af4:	83 ec 04             	sub    $0x4,%esp
  801af7:	68 07 04 00 00       	push   $0x407
  801afc:	ff 75 f0             	push   -0x10(%ebp)
  801aff:	6a 00                	push   $0x0
  801b01:	e8 85 f0 ff ff       	call   800b8b <sys_page_alloc>
  801b06:	89 c3                	mov    %eax,%ebx
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	0f 88 bc 00 00 00    	js     801bcf <pipe+0x131>
	va = fd2data(fd0);
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	ff 75 f4             	push   -0xc(%ebp)
  801b19:	e8 e0 f5 ff ff       	call   8010fe <fd2data>
  801b1e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b20:	83 c4 0c             	add    $0xc,%esp
  801b23:	68 07 04 00 00       	push   $0x407
  801b28:	50                   	push   %eax
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 5b f0 ff ff       	call   800b8b <sys_page_alloc>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	85 c0                	test   %eax,%eax
  801b37:	0f 88 82 00 00 00    	js     801bbf <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	ff 75 f0             	push   -0x10(%ebp)
  801b43:	e8 b6 f5 ff ff       	call   8010fe <fd2data>
  801b48:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b4f:	50                   	push   %eax
  801b50:	6a 00                	push   $0x0
  801b52:	56                   	push   %esi
  801b53:	6a 00                	push   $0x0
  801b55:	e8 74 f0 ff ff       	call   800bce <sys_page_map>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	83 c4 20             	add    $0x20,%esp
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 4e                	js     801bb1 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801b63:	a1 20 30 80 00       	mov    0x803020,%eax
  801b68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b6b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801b6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b70:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801b77:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b7a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	ff 75 f4             	push   -0xc(%ebp)
  801b8c:	e8 5d f5 ff ff       	call   8010ee <fd2num>
  801b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b94:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b96:	83 c4 04             	add    $0x4,%esp
  801b99:	ff 75 f0             	push   -0x10(%ebp)
  801b9c:	e8 4d f5 ff ff       	call   8010ee <fd2num>
  801ba1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801baf:	eb 2e                	jmp    801bdf <pipe+0x141>
	sys_page_unmap(0, va);
  801bb1:	83 ec 08             	sub    $0x8,%esp
  801bb4:	56                   	push   %esi
  801bb5:	6a 00                	push   $0x0
  801bb7:	e8 54 f0 ff ff       	call   800c10 <sys_page_unmap>
  801bbc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	ff 75 f0             	push   -0x10(%ebp)
  801bc5:	6a 00                	push   $0x0
  801bc7:	e8 44 f0 ff ff       	call   800c10 <sys_page_unmap>
  801bcc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801bcf:	83 ec 08             	sub    $0x8,%esp
  801bd2:	ff 75 f4             	push   -0xc(%ebp)
  801bd5:	6a 00                	push   $0x0
  801bd7:	e8 34 f0 ff ff       	call   800c10 <sys_page_unmap>
  801bdc:	83 c4 10             	add    $0x10,%esp
}
  801bdf:	89 d8                	mov    %ebx,%eax
  801be1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <pipeisclosed>:
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf1:	50                   	push   %eax
  801bf2:	ff 75 08             	push   0x8(%ebp)
  801bf5:	e8 6b f5 ff ff       	call   801165 <fd_lookup>
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	78 18                	js     801c19 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801c01:	83 ec 0c             	sub    $0xc,%esp
  801c04:	ff 75 f4             	push   -0xc(%ebp)
  801c07:	e8 f2 f4 ff ff       	call   8010fe <fd2data>
  801c0c:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c11:	e8 33 fd ff ff       	call   801949 <_pipeisclosed>
  801c16:	83 c4 10             	add    $0x10,%esp
}
  801c19:	c9                   	leave  
  801c1a:	c3                   	ret    

00801c1b <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c20:	c3                   	ret    

00801c21 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c27:	68 36 26 80 00       	push   $0x802636
  801c2c:	ff 75 0c             	push   0xc(%ebp)
  801c2f:	e8 5b eb ff ff       	call   80078f <strcpy>
	return 0;
}
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    

00801c3b <devcons_write>:
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	57                   	push   %edi
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c47:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c4c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c52:	eb 2e                	jmp    801c82 <devcons_write+0x47>
		m = n - tot;
  801c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c57:	29 f3                	sub    %esi,%ebx
  801c59:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801c5e:	39 c3                	cmp    %eax,%ebx
  801c60:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c63:	83 ec 04             	sub    $0x4,%esp
  801c66:	53                   	push   %ebx
  801c67:	89 f0                	mov    %esi,%eax
  801c69:	03 45 0c             	add    0xc(%ebp),%eax
  801c6c:	50                   	push   %eax
  801c6d:	57                   	push   %edi
  801c6e:	e8 b2 ec ff ff       	call   800925 <memmove>
		sys_cputs(buf, m);
  801c73:	83 c4 08             	add    $0x8,%esp
  801c76:	53                   	push   %ebx
  801c77:	57                   	push   %edi
  801c78:	e8 52 ee ff ff       	call   800acf <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c7d:	01 de                	add    %ebx,%esi
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c85:	72 cd                	jb     801c54 <devcons_write+0x19>
}
  801c87:	89 f0                	mov    %esi,%eax
  801c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5f                   	pop    %edi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <devcons_read>:
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 08             	sub    $0x8,%esp
  801c97:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801c9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ca0:	75 07                	jne    801ca9 <devcons_read+0x18>
  801ca2:	eb 1f                	jmp    801cc3 <devcons_read+0x32>
		sys_yield();
  801ca4:	e8 c3 ee ff ff       	call   800b6c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801ca9:	e8 3f ee ff ff       	call   800aed <sys_cgetc>
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	74 f2                	je     801ca4 <devcons_read+0x13>
	if (c < 0)
  801cb2:	78 0f                	js     801cc3 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801cb4:	83 f8 04             	cmp    $0x4,%eax
  801cb7:	74 0c                	je     801cc5 <devcons_read+0x34>
	*(char*)vbuf = c;
  801cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cbc:	88 02                	mov    %al,(%edx)
	return 1;
  801cbe:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    
		return 0;
  801cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cca:	eb f7                	jmp    801cc3 <devcons_read+0x32>

00801ccc <cputchar>:
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801cd8:	6a 01                	push   $0x1
  801cda:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cdd:	50                   	push   %eax
  801cde:	e8 ec ed ff ff       	call   800acf <sys_cputs>
}
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <getchar>:
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801cee:	6a 01                	push   $0x1
  801cf0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cf3:	50                   	push   %eax
  801cf4:	6a 00                	push   $0x0
  801cf6:	e8 ce f6 ff ff       	call   8013c9 <read>
	if (r < 0)
  801cfb:	83 c4 10             	add    $0x10,%esp
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 06                	js     801d08 <getchar+0x20>
	if (r < 1)
  801d02:	74 06                	je     801d0a <getchar+0x22>
	return c;
  801d04:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    
		return -E_EOF;
  801d0a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d0f:	eb f7                	jmp    801d08 <getchar+0x20>

00801d11 <iscons>:
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1a:	50                   	push   %eax
  801d1b:	ff 75 08             	push   0x8(%ebp)
  801d1e:	e8 42 f4 ff ff       	call   801165 <fd_lookup>
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	85 c0                	test   %eax,%eax
  801d28:	78 11                	js     801d3b <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d33:	39 10                	cmp    %edx,(%eax)
  801d35:	0f 94 c0             	sete   %al
  801d38:	0f b6 c0             	movzbl %al,%eax
}
  801d3b:	c9                   	leave  
  801d3c:	c3                   	ret    

00801d3d <opencons>:
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d46:	50                   	push   %eax
  801d47:	e8 c9 f3 ff ff       	call   801115 <fd_alloc>
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	78 3a                	js     801d8d <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d53:	83 ec 04             	sub    $0x4,%esp
  801d56:	68 07 04 00 00       	push   $0x407
  801d5b:	ff 75 f4             	push   -0xc(%ebp)
  801d5e:	6a 00                	push   $0x0
  801d60:	e8 26 ee ff ff       	call   800b8b <sys_page_alloc>
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	78 21                	js     801d8d <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d75:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d81:	83 ec 0c             	sub    $0xc,%esp
  801d84:	50                   	push   %eax
  801d85:	e8 64 f3 ff ff       	call   8010ee <fd2num>
  801d8a:	83 c4 10             	add    $0x10,%esp
}
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d94:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d97:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d9d:	e8 ab ed ff ff       	call   800b4d <sys_getenvid>
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	ff 75 0c             	push   0xc(%ebp)
  801da8:	ff 75 08             	push   0x8(%ebp)
  801dab:	56                   	push   %esi
  801dac:	50                   	push   %eax
  801dad:	68 44 26 80 00       	push   $0x802644
  801db2:	e8 fe e3 ff ff       	call   8001b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801db7:	83 c4 18             	add    $0x18,%esp
  801dba:	53                   	push   %ebx
  801dbb:	ff 75 10             	push   0x10(%ebp)
  801dbe:	e8 a1 e3 ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  801dc3:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  801dca:	e8 e6 e3 ff ff       	call   8001b5 <cprintf>
  801dcf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dd2:	cc                   	int3   
  801dd3:	eb fd                	jmp    801dd2 <_panic+0x43>

00801dd5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801ddb:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801de2:	74 0a                	je     801dee <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801de4:	8b 45 08             	mov    0x8(%ebp),%eax
  801de7:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801dee:	e8 5a ed ff ff       	call   800b4d <sys_getenvid>
  801df3:	83 ec 04             	sub    $0x4,%esp
  801df6:	68 07 0e 00 00       	push   $0xe07
  801dfb:	68 00 f0 bf ee       	push   $0xeebff000
  801e00:	50                   	push   %eax
  801e01:	e8 85 ed ff ff       	call   800b8b <sys_page_alloc>
		if (r < 0) {
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	78 2c                	js     801e39 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e0d:	e8 3b ed ff ff       	call   800b4d <sys_getenvid>
  801e12:	83 ec 08             	sub    $0x8,%esp
  801e15:	68 4b 1e 80 00       	push   $0x801e4b
  801e1a:	50                   	push   %eax
  801e1b:	e8 b6 ee ff ff       	call   800cd6 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	85 c0                	test   %eax,%eax
  801e25:	79 bd                	jns    801de4 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801e27:	50                   	push   %eax
  801e28:	68 a8 26 80 00       	push   $0x8026a8
  801e2d:	6a 28                	push   $0x28
  801e2f:	68 de 26 80 00       	push   $0x8026de
  801e34:	e8 56 ff ff ff       	call   801d8f <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801e39:	50                   	push   %eax
  801e3a:	68 68 26 80 00       	push   $0x802668
  801e3f:	6a 23                	push   $0x23
  801e41:	68 de 26 80 00       	push   $0x8026de
  801e46:	e8 44 ff ff ff       	call   801d8f <_panic>

00801e4b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e4b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e4c:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801e51:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e53:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801e56:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801e5a:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801e5d:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801e61:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801e65:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801e67:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801e6a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801e6b:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801e6e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801e6f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801e70:	c3                   	ret    

00801e71 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e77:	89 c2                	mov    %eax,%edx
  801e79:	c1 ea 16             	shr    $0x16,%edx
  801e7c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801e83:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801e88:	f6 c1 01             	test   $0x1,%cl
  801e8b:	74 1c                	je     801ea9 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801e8d:	c1 e8 0c             	shr    $0xc,%eax
  801e90:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e97:	a8 01                	test   $0x1,%al
  801e99:	74 0e                	je     801ea9 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e9b:	c1 e8 0c             	shr    $0xc,%eax
  801e9e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ea5:	ef 
  801ea6:	0f b7 d2             	movzwl %dx,%edx
}
  801ea9:	89 d0                	mov    %edx,%eax
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
  801ead:	66 90                	xchg   %ax,%ax
  801eaf:	90                   	nop

00801eb0 <__udivdi3>:
  801eb0:	f3 0f 1e fb          	endbr32 
  801eb4:	55                   	push   %ebp
  801eb5:	57                   	push   %edi
  801eb6:	56                   	push   %esi
  801eb7:	53                   	push   %ebx
  801eb8:	83 ec 1c             	sub    $0x1c,%esp
  801ebb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801ebf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ec3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ec7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	75 19                	jne    801ee8 <__udivdi3+0x38>
  801ecf:	39 f3                	cmp    %esi,%ebx
  801ed1:	76 4d                	jbe    801f20 <__udivdi3+0x70>
  801ed3:	31 ff                	xor    %edi,%edi
  801ed5:	89 e8                	mov    %ebp,%eax
  801ed7:	89 f2                	mov    %esi,%edx
  801ed9:	f7 f3                	div    %ebx
  801edb:	89 fa                	mov    %edi,%edx
  801edd:	83 c4 1c             	add    $0x1c,%esp
  801ee0:	5b                   	pop    %ebx
  801ee1:	5e                   	pop    %esi
  801ee2:	5f                   	pop    %edi
  801ee3:	5d                   	pop    %ebp
  801ee4:	c3                   	ret    
  801ee5:	8d 76 00             	lea    0x0(%esi),%esi
  801ee8:	39 f0                	cmp    %esi,%eax
  801eea:	76 14                	jbe    801f00 <__udivdi3+0x50>
  801eec:	31 ff                	xor    %edi,%edi
  801eee:	31 c0                	xor    %eax,%eax
  801ef0:	89 fa                	mov    %edi,%edx
  801ef2:	83 c4 1c             	add    $0x1c,%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5f                   	pop    %edi
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    
  801efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f00:	0f bd f8             	bsr    %eax,%edi
  801f03:	83 f7 1f             	xor    $0x1f,%edi
  801f06:	75 48                	jne    801f50 <__udivdi3+0xa0>
  801f08:	39 f0                	cmp    %esi,%eax
  801f0a:	72 06                	jb     801f12 <__udivdi3+0x62>
  801f0c:	31 c0                	xor    %eax,%eax
  801f0e:	39 eb                	cmp    %ebp,%ebx
  801f10:	77 de                	ja     801ef0 <__udivdi3+0x40>
  801f12:	b8 01 00 00 00       	mov    $0x1,%eax
  801f17:	eb d7                	jmp    801ef0 <__udivdi3+0x40>
  801f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f20:	89 d9                	mov    %ebx,%ecx
  801f22:	85 db                	test   %ebx,%ebx
  801f24:	75 0b                	jne    801f31 <__udivdi3+0x81>
  801f26:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2b:	31 d2                	xor    %edx,%edx
  801f2d:	f7 f3                	div    %ebx
  801f2f:	89 c1                	mov    %eax,%ecx
  801f31:	31 d2                	xor    %edx,%edx
  801f33:	89 f0                	mov    %esi,%eax
  801f35:	f7 f1                	div    %ecx
  801f37:	89 c6                	mov    %eax,%esi
  801f39:	89 e8                	mov    %ebp,%eax
  801f3b:	89 f7                	mov    %esi,%edi
  801f3d:	f7 f1                	div    %ecx
  801f3f:	89 fa                	mov    %edi,%edx
  801f41:	83 c4 1c             	add    $0x1c,%esp
  801f44:	5b                   	pop    %ebx
  801f45:	5e                   	pop    %esi
  801f46:	5f                   	pop    %edi
  801f47:	5d                   	pop    %ebp
  801f48:	c3                   	ret    
  801f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f50:	89 f9                	mov    %edi,%ecx
  801f52:	ba 20 00 00 00       	mov    $0x20,%edx
  801f57:	29 fa                	sub    %edi,%edx
  801f59:	d3 e0                	shl    %cl,%eax
  801f5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f5f:	89 d1                	mov    %edx,%ecx
  801f61:	89 d8                	mov    %ebx,%eax
  801f63:	d3 e8                	shr    %cl,%eax
  801f65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f69:	09 c1                	or     %eax,%ecx
  801f6b:	89 f0                	mov    %esi,%eax
  801f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f71:	89 f9                	mov    %edi,%ecx
  801f73:	d3 e3                	shl    %cl,%ebx
  801f75:	89 d1                	mov    %edx,%ecx
  801f77:	d3 e8                	shr    %cl,%eax
  801f79:	89 f9                	mov    %edi,%ecx
  801f7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f7f:	89 eb                	mov    %ebp,%ebx
  801f81:	d3 e6                	shl    %cl,%esi
  801f83:	89 d1                	mov    %edx,%ecx
  801f85:	d3 eb                	shr    %cl,%ebx
  801f87:	09 f3                	or     %esi,%ebx
  801f89:	89 c6                	mov    %eax,%esi
  801f8b:	89 f2                	mov    %esi,%edx
  801f8d:	89 d8                	mov    %ebx,%eax
  801f8f:	f7 74 24 08          	divl   0x8(%esp)
  801f93:	89 d6                	mov    %edx,%esi
  801f95:	89 c3                	mov    %eax,%ebx
  801f97:	f7 64 24 0c          	mull   0xc(%esp)
  801f9b:	39 d6                	cmp    %edx,%esi
  801f9d:	72 19                	jb     801fb8 <__udivdi3+0x108>
  801f9f:	89 f9                	mov    %edi,%ecx
  801fa1:	d3 e5                	shl    %cl,%ebp
  801fa3:	39 c5                	cmp    %eax,%ebp
  801fa5:	73 04                	jae    801fab <__udivdi3+0xfb>
  801fa7:	39 d6                	cmp    %edx,%esi
  801fa9:	74 0d                	je     801fb8 <__udivdi3+0x108>
  801fab:	89 d8                	mov    %ebx,%eax
  801fad:	31 ff                	xor    %edi,%edi
  801faf:	e9 3c ff ff ff       	jmp    801ef0 <__udivdi3+0x40>
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801fbb:	31 ff                	xor    %edi,%edi
  801fbd:	e9 2e ff ff ff       	jmp    801ef0 <__udivdi3+0x40>
  801fc2:	66 90                	xchg   %ax,%ax
  801fc4:	66 90                	xchg   %ax,%ax
  801fc6:	66 90                	xchg   %ax,%ax
  801fc8:	66 90                	xchg   %ax,%ax
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <__umoddi3>:
  801fd0:	f3 0f 1e fb          	endbr32 
  801fd4:	55                   	push   %ebp
  801fd5:	57                   	push   %edi
  801fd6:	56                   	push   %esi
  801fd7:	53                   	push   %ebx
  801fd8:	83 ec 1c             	sub    $0x1c,%esp
  801fdb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801fdf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801fe3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801fe7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801feb:	89 f0                	mov    %esi,%eax
  801fed:	89 da                	mov    %ebx,%edx
  801fef:	85 ff                	test   %edi,%edi
  801ff1:	75 15                	jne    802008 <__umoddi3+0x38>
  801ff3:	39 dd                	cmp    %ebx,%ebp
  801ff5:	76 39                	jbe    802030 <__umoddi3+0x60>
  801ff7:	f7 f5                	div    %ebp
  801ff9:	89 d0                	mov    %edx,%eax
  801ffb:	31 d2                	xor    %edx,%edx
  801ffd:	83 c4 1c             	add    $0x1c,%esp
  802000:	5b                   	pop    %ebx
  802001:	5e                   	pop    %esi
  802002:	5f                   	pop    %edi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    
  802005:	8d 76 00             	lea    0x0(%esi),%esi
  802008:	39 df                	cmp    %ebx,%edi
  80200a:	77 f1                	ja     801ffd <__umoddi3+0x2d>
  80200c:	0f bd cf             	bsr    %edi,%ecx
  80200f:	83 f1 1f             	xor    $0x1f,%ecx
  802012:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802016:	75 40                	jne    802058 <__umoddi3+0x88>
  802018:	39 df                	cmp    %ebx,%edi
  80201a:	72 04                	jb     802020 <__umoddi3+0x50>
  80201c:	39 f5                	cmp    %esi,%ebp
  80201e:	77 dd                	ja     801ffd <__umoddi3+0x2d>
  802020:	89 da                	mov    %ebx,%edx
  802022:	89 f0                	mov    %esi,%eax
  802024:	29 e8                	sub    %ebp,%eax
  802026:	19 fa                	sbb    %edi,%edx
  802028:	eb d3                	jmp    801ffd <__umoddi3+0x2d>
  80202a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802030:	89 e9                	mov    %ebp,%ecx
  802032:	85 ed                	test   %ebp,%ebp
  802034:	75 0b                	jne    802041 <__umoddi3+0x71>
  802036:	b8 01 00 00 00       	mov    $0x1,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	f7 f5                	div    %ebp
  80203f:	89 c1                	mov    %eax,%ecx
  802041:	89 d8                	mov    %ebx,%eax
  802043:	31 d2                	xor    %edx,%edx
  802045:	f7 f1                	div    %ecx
  802047:	89 f0                	mov    %esi,%eax
  802049:	f7 f1                	div    %ecx
  80204b:	89 d0                	mov    %edx,%eax
  80204d:	31 d2                	xor    %edx,%edx
  80204f:	eb ac                	jmp    801ffd <__umoddi3+0x2d>
  802051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802058:	8b 44 24 04          	mov    0x4(%esp),%eax
  80205c:	ba 20 00 00 00       	mov    $0x20,%edx
  802061:	29 c2                	sub    %eax,%edx
  802063:	89 c1                	mov    %eax,%ecx
  802065:	89 e8                	mov    %ebp,%eax
  802067:	d3 e7                	shl    %cl,%edi
  802069:	89 d1                	mov    %edx,%ecx
  80206b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80206f:	d3 e8                	shr    %cl,%eax
  802071:	89 c1                	mov    %eax,%ecx
  802073:	8b 44 24 04          	mov    0x4(%esp),%eax
  802077:	09 f9                	or     %edi,%ecx
  802079:	89 df                	mov    %ebx,%edi
  80207b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80207f:	89 c1                	mov    %eax,%ecx
  802081:	d3 e5                	shl    %cl,%ebp
  802083:	89 d1                	mov    %edx,%ecx
  802085:	d3 ef                	shr    %cl,%edi
  802087:	89 c1                	mov    %eax,%ecx
  802089:	89 f0                	mov    %esi,%eax
  80208b:	d3 e3                	shl    %cl,%ebx
  80208d:	89 d1                	mov    %edx,%ecx
  80208f:	89 fa                	mov    %edi,%edx
  802091:	d3 e8                	shr    %cl,%eax
  802093:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802098:	09 d8                	or     %ebx,%eax
  80209a:	f7 74 24 08          	divl   0x8(%esp)
  80209e:	89 d3                	mov    %edx,%ebx
  8020a0:	d3 e6                	shl    %cl,%esi
  8020a2:	f7 e5                	mul    %ebp
  8020a4:	89 c7                	mov    %eax,%edi
  8020a6:	89 d1                	mov    %edx,%ecx
  8020a8:	39 d3                	cmp    %edx,%ebx
  8020aa:	72 06                	jb     8020b2 <__umoddi3+0xe2>
  8020ac:	75 0e                	jne    8020bc <__umoddi3+0xec>
  8020ae:	39 c6                	cmp    %eax,%esi
  8020b0:	73 0a                	jae    8020bc <__umoddi3+0xec>
  8020b2:	29 e8                	sub    %ebp,%eax
  8020b4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8020b8:	89 d1                	mov    %edx,%ecx
  8020ba:	89 c7                	mov    %eax,%edi
  8020bc:	89 f5                	mov    %esi,%ebp
  8020be:	8b 74 24 04          	mov    0x4(%esp),%esi
  8020c2:	29 fd                	sub    %edi,%ebp
  8020c4:	19 cb                	sbb    %ecx,%ebx
  8020c6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8020cb:	89 d8                	mov    %ebx,%eax
  8020cd:	d3 e0                	shl    %cl,%eax
  8020cf:	89 f1                	mov    %esi,%ecx
  8020d1:	d3 ed                	shr    %cl,%ebp
  8020d3:	d3 eb                	shr    %cl,%ebx
  8020d5:	09 e8                	or     %ebp,%eax
  8020d7:	89 da                	mov    %ebx,%edx
  8020d9:	83 c4 1c             	add    $0x1c,%esp
  8020dc:	5b                   	pop    %ebx
  8020dd:	5e                   	pop    %esi
  8020de:	5f                   	pop    %edi
  8020df:	5d                   	pop    %ebp
  8020e0:	c3                   	ret    
