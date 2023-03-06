
obj/user/pingpongs：     文件格式 elf32-i386


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
  80002c:	e8 d2 00 00 00       	call   800103 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 86 0f 00 00       	call   800fc7 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 74                	jne    8000bc <umain+0x89>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800048:	83 ec 04             	sub    $0x4,%esp
  80004b:	6a 00                	push   $0x0
  80004d:	6a 00                	push   $0x0
  80004f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	e8 89 0f 00 00       	call   800fe1 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800058:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80005e:	8b 7b 48             	mov    0x48(%ebx),%edi
  800061:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800064:	a1 04 20 80 00       	mov    0x802004,%eax
  800069:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006c:	e8 17 0b 00 00       	call   800b88 <sys_getenvid>
  800071:	83 c4 08             	add    $0x8,%esp
  800074:	57                   	push   %edi
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	ff 75 d4             	push   -0x2c(%ebp)
  80007a:	50                   	push   %eax
  80007b:	68 30 14 80 00       	push   $0x801430
  800080:	e8 6b 01 00 00       	call   8001f0 <cprintf>
		if (val == 10)
  800085:	a1 04 20 80 00       	mov    0x802004,%eax
  80008a:	83 c4 20             	add    $0x20,%esp
  80008d:	83 f8 0a             	cmp    $0xa,%eax
  800090:	74 22                	je     8000b4 <umain+0x81>
			return;
		++val;
  800092:	83 c0 01             	add    $0x1,%eax
  800095:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80009a:	6a 00                	push   $0x0
  80009c:	6a 00                	push   $0x0
  80009e:	6a 00                	push   $0x0
  8000a0:	ff 75 e4             	push   -0x1c(%ebp)
  8000a3:	e8 a0 0f 00 00       	call   801048 <ipc_send>
		if (val == 10)
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000b2:	75 94                	jne    800048 <umain+0x15>
			return;
	}

}
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000bc:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c2:	e8 c1 0a 00 00       	call   800b88 <sys_getenvid>
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	50                   	push   %eax
  8000cc:	68 00 14 80 00       	push   $0x801400
  8000d1:	e8 1a 01 00 00       	call   8001f0 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 aa 0a 00 00       	call   800b88 <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 1a 14 80 00       	push   $0x80141a
  8000e8:	e8 03 01 00 00       	call   8001f0 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	push   -0x1c(%ebp)
  8000f6:	e8 4d 0f 00 00       	call   801048 <ipc_send>
  8000fb:	83 c4 20             	add    $0x20,%esp
  8000fe:	e9 45 ff ff ff       	jmp    800048 <umain+0x15>

00800103 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80010e:	e8 75 0a 00 00       	call   800b88 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 db                	test   %ebx,%ebx
  800127:	7e 07                	jle    800130 <libmain+0x2d>
		binaryname = argv[0];
  800129:	8b 06                	mov    (%esi),%eax
  80012b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
  800135:	e8 f9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013a:	e8 0a 00 00 00       	call   800149 <exit>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014f:	6a 00                	push   $0x0
  800151:	e8 f1 09 00 00       	call   800b47 <sys_env_destroy>
}
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	74 09                	je     800183 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 76 09 00 00       	call   800b0a <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	eb db                	jmp    80017a <putch+0x1f>

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001af:	00 00 00 
	b.cnt = 0;
  8001b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bc:	ff 75 0c             	push   0xc(%ebp)
  8001bf:	ff 75 08             	push   0x8(%ebp)
  8001c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c8:	50                   	push   %eax
  8001c9:	68 5b 01 80 00       	push   $0x80015b
  8001ce:	e8 14 01 00 00       	call   8002e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d3:	83 c4 08             	add    $0x8,%esp
  8001d6:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	e8 22 09 00 00       	call   800b0a <sys_cputs>

	return b.cnt;
}
  8001e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	50                   	push   %eax
  8001fa:	ff 75 08             	push   0x8(%ebp)
  8001fd:	e8 9d ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	89 c7                	mov    %eax,%edi
  80020f:	89 d6                	mov    %edx,%esi
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 d1                	mov    %edx,%ecx
  800219:	89 c2                	mov    %eax,%edx
  80021b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800221:	8b 45 10             	mov    0x10(%ebp),%eax
  800224:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800227:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800231:	39 c2                	cmp    %eax,%edx
  800233:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800236:	72 3e                	jb     800276 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	ff 75 18             	push   0x18(%ebp)
  80023e:	83 eb 01             	sub    $0x1,%ebx
  800241:	53                   	push   %ebx
  800242:	50                   	push   %eax
  800243:	83 ec 08             	sub    $0x8,%esp
  800246:	ff 75 e4             	push   -0x1c(%ebp)
  800249:	ff 75 e0             	push   -0x20(%ebp)
  80024c:	ff 75 dc             	push   -0x24(%ebp)
  80024f:	ff 75 d8             	push   -0x28(%ebp)
  800252:	e8 69 0f 00 00       	call   8011c0 <__udivdi3>
  800257:	83 c4 18             	add    $0x18,%esp
  80025a:	52                   	push   %edx
  80025b:	50                   	push   %eax
  80025c:	89 f2                	mov    %esi,%edx
  80025e:	89 f8                	mov    %edi,%eax
  800260:	e8 9f ff ff ff       	call   800204 <printnum>
  800265:	83 c4 20             	add    $0x20,%esp
  800268:	eb 13                	jmp    80027d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	56                   	push   %esi
  80026e:	ff 75 18             	push   0x18(%ebp)
  800271:	ff d7                	call   *%edi
  800273:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800276:	83 eb 01             	sub    $0x1,%ebx
  800279:	85 db                	test   %ebx,%ebx
  80027b:	7f ed                	jg     80026a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	56                   	push   %esi
  800281:	83 ec 04             	sub    $0x4,%esp
  800284:	ff 75 e4             	push   -0x1c(%ebp)
  800287:	ff 75 e0             	push   -0x20(%ebp)
  80028a:	ff 75 dc             	push   -0x24(%ebp)
  80028d:	ff 75 d8             	push   -0x28(%ebp)
  800290:	e8 4b 10 00 00       	call   8012e0 <__umoddi3>
  800295:	83 c4 14             	add    $0x14,%esp
  800298:	0f be 80 60 14 80 00 	movsbl 0x801460(%eax),%eax
  80029f:	50                   	push   %eax
  8002a0:	ff d7                	call   *%edi
}
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bc:	73 0a                	jae    8002c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	88 02                	mov    %al,(%edx)
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <printfmt>:
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 10             	push   0x10(%ebp)
  8002d7:	ff 75 0c             	push   0xc(%ebp)
  8002da:	ff 75 08             	push   0x8(%ebp)
  8002dd:	e8 05 00 00 00       	call   8002e7 <vprintfmt>
}
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	c9                   	leave  
  8002e6:	c3                   	ret    

008002e7 <vprintfmt>:
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 3c             	sub    $0x3c,%esp
  8002f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f9:	eb 0a                	jmp    800305 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	ff d6                	call   *%esi
  800302:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	83 c7 01             	add    $0x1,%edi
  800308:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	74 0c                	je     80031d <vprintfmt+0x36>
			if (ch == '\0')
  800311:	85 c0                	test   %eax,%eax
  800313:	75 e6                	jne    8002fb <vprintfmt+0x14>
}
  800315:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    
		padc = ' ';
  80031d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800321:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800328:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800336:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8d 47 01             	lea    0x1(%edi),%eax
  80033e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800341:	0f b6 17             	movzbl (%edi),%edx
  800344:	8d 42 dd             	lea    -0x23(%edx),%eax
  800347:	3c 55                	cmp    $0x55,%al
  800349:	0f 87 bb 03 00 00    	ja     80070a <vprintfmt+0x423>
  80034f:	0f b6 c0             	movzbl %al,%eax
  800352:	ff 24 85 20 15 80 00 	jmp    *0x801520(,%eax,4)
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80035c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800360:	eb d9                	jmp    80033b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800365:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800369:	eb d0                	jmp    80033b <vprintfmt+0x54>
  80036b:	0f b6 d2             	movzbl %dl,%edx
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800383:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800386:	83 f9 09             	cmp    $0x9,%ecx
  800389:	77 55                	ja     8003e0 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8b 00                	mov    (%eax),%eax
  800395:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 40 04             	lea    0x4(%eax),%eax
  80039e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a8:	79 91                	jns    80033b <vprintfmt+0x54>
				width = precision, precision = -1;
  8003aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003b7:	eb 82                	jmp    80033b <vprintfmt+0x54>
  8003b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c3:	0f 49 c2             	cmovns %edx,%eax
  8003c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cc:	e9 6a ff ff ff       	jmp    80033b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003db:	e9 5b ff ff ff       	jmp    80033b <vprintfmt+0x54>
  8003e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e6:	eb bc                	jmp    8003a4 <vprintfmt+0xbd>
			lflag++;
  8003e8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ee:	e9 48 ff ff ff       	jmp    80033b <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 78 04             	lea    0x4(%eax),%edi
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	53                   	push   %ebx
  8003fd:	ff 30                	push   (%eax)
  8003ff:	ff d6                	call   *%esi
			break;
  800401:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800404:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800407:	e9 9d 02 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	8b 10                	mov    (%eax),%edx
  800414:	89 d0                	mov    %edx,%eax
  800416:	f7 d8                	neg    %eax
  800418:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041b:	83 f8 08             	cmp    $0x8,%eax
  80041e:	7f 23                	jg     800443 <vprintfmt+0x15c>
  800420:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  800427:	85 d2                	test   %edx,%edx
  800429:	74 18                	je     800443 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80042b:	52                   	push   %edx
  80042c:	68 81 14 80 00       	push   $0x801481
  800431:	53                   	push   %ebx
  800432:	56                   	push   %esi
  800433:	e8 92 fe ff ff       	call   8002ca <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80043e:	e9 66 02 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800443:	50                   	push   %eax
  800444:	68 78 14 80 00       	push   $0x801478
  800449:	53                   	push   %ebx
  80044a:	56                   	push   %esi
  80044b:	e8 7a fe ff ff       	call   8002ca <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800453:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800456:	e9 4e 02 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	83 c0 04             	add    $0x4,%eax
  800461:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800469:	85 d2                	test   %edx,%edx
  80046b:	b8 71 14 80 00       	mov    $0x801471,%eax
  800470:	0f 45 c2             	cmovne %edx,%eax
  800473:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800476:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047a:	7e 06                	jle    800482 <vprintfmt+0x19b>
  80047c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800480:	75 0d                	jne    80048f <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800485:	89 c7                	mov    %eax,%edi
  800487:	03 45 e0             	add    -0x20(%ebp),%eax
  80048a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048d:	eb 55                	jmp    8004e4 <vprintfmt+0x1fd>
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 d8             	push   -0x28(%ebp)
  800495:	ff 75 cc             	push   -0x34(%ebp)
  800498:	e8 0a 03 00 00       	call   8007a7 <strnlen>
  80049d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a0:	29 c1                	sub    %eax,%ecx
  8004a2:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004aa:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	eb 0f                	jmp    8004c2 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	ff 75 e0             	push   -0x20(%ebp)
  8004ba:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	83 ef 01             	sub    $0x1,%edi
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 ff                	test   %edi,%edi
  8004c4:	7f ed                	jg     8004b3 <vprintfmt+0x1cc>
  8004c6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c9:	85 d2                	test   %edx,%edx
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	0f 49 c2             	cmovns %edx,%eax
  8004d3:	29 c2                	sub    %eax,%edx
  8004d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004d8:	eb a8                	jmp    800482 <vprintfmt+0x19b>
					putch(ch, putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	53                   	push   %ebx
  8004de:	52                   	push   %edx
  8004df:	ff d6                	call   *%esi
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	0f be d0             	movsbl %al,%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 4b                	je     800542 <vprintfmt+0x25b>
  8004f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fb:	78 06                	js     800503 <vprintfmt+0x21c>
  8004fd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800501:	78 1e                	js     800521 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800503:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800507:	74 d1                	je     8004da <vprintfmt+0x1f3>
  800509:	0f be c0             	movsbl %al,%eax
  80050c:	83 e8 20             	sub    $0x20,%eax
  80050f:	83 f8 5e             	cmp    $0x5e,%eax
  800512:	76 c6                	jbe    8004da <vprintfmt+0x1f3>
					putch('?', putdat);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	53                   	push   %ebx
  800518:	6a 3f                	push   $0x3f
  80051a:	ff d6                	call   *%esi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb c3                	jmp    8004e4 <vprintfmt+0x1fd>
  800521:	89 cf                	mov    %ecx,%edi
  800523:	eb 0e                	jmp    800533 <vprintfmt+0x24c>
				putch(' ', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	53                   	push   %ebx
  800529:	6a 20                	push   $0x20
  80052b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80052d:	83 ef 01             	sub    $0x1,%edi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	85 ff                	test   %edi,%edi
  800535:	7f ee                	jg     800525 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
  80053d:	e9 67 01 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
  800542:	89 cf                	mov    %ecx,%edi
  800544:	eb ed                	jmp    800533 <vprintfmt+0x24c>
	if (lflag >= 2)
  800546:	83 f9 01             	cmp    $0x1,%ecx
  800549:	7f 1b                	jg     800566 <vprintfmt+0x27f>
	else if (lflag)
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	74 63                	je     8005b2 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8b 00                	mov    (%eax),%eax
  800554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800557:	99                   	cltd   
  800558:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 40 04             	lea    0x4(%eax),%eax
  800561:	89 45 14             	mov    %eax,0x14(%ebp)
  800564:	eb 17                	jmp    80057d <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 50 04             	mov    0x4(%eax),%edx
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 08             	lea    0x8(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80057d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800580:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800583:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800588:	85 c9                	test   %ecx,%ecx
  80058a:	0f 89 ff 00 00 00    	jns    80068f <vprintfmt+0x3a8>
				putch('-', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	53                   	push   %ebx
  800594:	6a 2d                	push   $0x2d
  800596:	ff d6                	call   *%esi
				num = -(long long) num;
  800598:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059e:	f7 da                	neg    %edx
  8005a0:	83 d1 00             	adc    $0x0,%ecx
  8005a3:	f7 d9                	neg    %ecx
  8005a5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a8:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005ad:	e9 dd 00 00 00       	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	99                   	cltd   
  8005bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 40 04             	lea    0x4(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c7:	eb b4                	jmp    80057d <vprintfmt+0x296>
	if (lflag >= 2)
  8005c9:	83 f9 01             	cmp    $0x1,%ecx
  8005cc:	7f 1e                	jg     8005ec <vprintfmt+0x305>
	else if (lflag)
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	74 32                	je     800604 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 10                	mov    (%eax),%edx
  8005d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005dc:	8d 40 04             	lea    0x4(%eax),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005e7:	e9 a3 00 00 00       	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 10                	mov    (%eax),%edx
  8005f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f4:	8d 40 08             	lea    0x8(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fa:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005ff:	e9 8b 00 00 00       	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060e:	8d 40 04             	lea    0x4(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800614:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800619:	eb 74                	jmp    80068f <vprintfmt+0x3a8>
	if (lflag >= 2)
  80061b:	83 f9 01             	cmp    $0x1,%ecx
  80061e:	7f 1b                	jg     80063b <vprintfmt+0x354>
	else if (lflag)
  800620:	85 c9                	test   %ecx,%ecx
  800622:	74 2c                	je     800650 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 10                	mov    (%eax),%edx
  800629:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062e:	8d 40 04             	lea    0x4(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800634:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800639:	eb 54                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	8b 48 04             	mov    0x4(%eax),%ecx
  800643:	8d 40 08             	lea    0x8(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800649:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80064e:	eb 3f                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800660:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800665:	eb 28                	jmp    80068f <vprintfmt+0x3a8>
			putch('0', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 30                	push   $0x30
  80066d:	ff d6                	call   *%esi
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 78                	push   $0x78
  800675:	ff d6                	call   *%esi
			num = (unsigned long long)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800681:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800684:	8d 40 04             	lea    0x4(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068a:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800696:	50                   	push   %eax
  800697:	ff 75 e0             	push   -0x20(%ebp)
  80069a:	57                   	push   %edi
  80069b:	51                   	push   %ecx
  80069c:	52                   	push   %edx
  80069d:	89 da                	mov    %ebx,%edx
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	e8 5e fb ff ff       	call   800204 <printnum>
			break;
  8006a6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ac:	e9 54 fc ff ff       	jmp    800305 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006b1:	83 f9 01             	cmp    $0x1,%ecx
  8006b4:	7f 1b                	jg     8006d1 <vprintfmt+0x3ea>
	else if (lflag)
  8006b6:	85 c9                	test   %ecx,%ecx
  8006b8:	74 2c                	je     8006e6 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ca:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006cf:	eb be                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d9:	8d 40 08             	lea    0x8(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006df:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006e4:	eb a9                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f0:	8d 40 04             	lea    0x4(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006fb:	eb 92                	jmp    80068f <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	6a 25                	push   $0x25
  800703:	ff d6                	call   *%esi
			break;
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	eb 9f                	jmp    8006a9 <vprintfmt+0x3c2>
			putch('%', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 25                	push   $0x25
  800710:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	89 f8                	mov    %edi,%eax
  800717:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80071b:	74 05                	je     800722 <vprintfmt+0x43b>
  80071d:	83 e8 01             	sub    $0x1,%eax
  800720:	eb f5                	jmp    800717 <vprintfmt+0x430>
  800722:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800725:	eb 82                	jmp    8006a9 <vprintfmt+0x3c2>

00800727 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 18             	sub    $0x18,%esp
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800733:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800736:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800744:	85 c0                	test   %eax,%eax
  800746:	74 26                	je     80076e <vsnprintf+0x47>
  800748:	85 d2                	test   %edx,%edx
  80074a:	7e 22                	jle    80076e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074c:	ff 75 14             	push   0x14(%ebp)
  80074f:	ff 75 10             	push   0x10(%ebp)
  800752:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800755:	50                   	push   %eax
  800756:	68 ad 02 80 00       	push   $0x8002ad
  80075b:	e8 87 fb ff ff       	call   8002e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800763:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800766:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800769:	83 c4 10             	add    $0x10,%esp
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    
		return -E_INVAL;
  80076e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800773:	eb f7                	jmp    80076c <vsnprintf+0x45>

00800775 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077e:	50                   	push   %eax
  80077f:	ff 75 10             	push   0x10(%ebp)
  800782:	ff 75 0c             	push   0xc(%ebp)
  800785:	ff 75 08             	push   0x8(%ebp)
  800788:	e8 9a ff ff ff       	call   800727 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	eb 03                	jmp    80079f <strlen+0x10>
		n++;
  80079c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80079f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a3:	75 f7                	jne    80079c <strlen+0xd>
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	eb 03                	jmp    8007ba <strnlen+0x13>
		n++;
  8007b7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ba:	39 d0                	cmp    %edx,%eax
  8007bc:	74 08                	je     8007c6 <strnlen+0x1f>
  8007be:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c2:	75 f3                	jne    8007b7 <strnlen+0x10>
  8007c4:	89 c2                	mov    %eax,%edx
	return n;
}
  8007c6:	89 d0                	mov    %edx,%eax
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007dd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e0:	83 c0 01             	add    $0x1,%eax
  8007e3:	84 d2                	test   %dl,%dl
  8007e5:	75 f2                	jne    8007d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e7:	89 c8                	mov    %ecx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	53                   	push   %ebx
  8007f2:	83 ec 10             	sub    $0x10,%esp
  8007f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f8:	53                   	push   %ebx
  8007f9:	e8 91 ff ff ff       	call   80078f <strlen>
  8007fe:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800801:	ff 75 0c             	push   0xc(%ebp)
  800804:	01 d8                	add    %ebx,%eax
  800806:	50                   	push   %eax
  800807:	e8 be ff ff ff       	call   8007ca <strcpy>
	return dst;
}
  80080c:	89 d8                	mov    %ebx,%eax
  80080e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	56                   	push   %esi
  800817:	53                   	push   %ebx
  800818:	8b 75 08             	mov    0x8(%ebp),%esi
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	89 f3                	mov    %esi,%ebx
  800820:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800823:	89 f0                	mov    %esi,%eax
  800825:	eb 0f                	jmp    800836 <strncpy+0x23>
		*dst++ = *src;
  800827:	83 c0 01             	add    $0x1,%eax
  80082a:	0f b6 0a             	movzbl (%edx),%ecx
  80082d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800830:	80 f9 01             	cmp    $0x1,%cl
  800833:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800836:	39 d8                	cmp    %ebx,%eax
  800838:	75 ed                	jne    800827 <strncpy+0x14>
	}
	return ret;
}
  80083a:	89 f0                	mov    %esi,%eax
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	56                   	push   %esi
  800844:	53                   	push   %ebx
  800845:	8b 75 08             	mov    0x8(%ebp),%esi
  800848:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084b:	8b 55 10             	mov    0x10(%ebp),%edx
  80084e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800850:	85 d2                	test   %edx,%edx
  800852:	74 21                	je     800875 <strlcpy+0x35>
  800854:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800858:	89 f2                	mov    %esi,%edx
  80085a:	eb 09                	jmp    800865 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085c:	83 c1 01             	add    $0x1,%ecx
  80085f:	83 c2 01             	add    $0x1,%edx
  800862:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800865:	39 c2                	cmp    %eax,%edx
  800867:	74 09                	je     800872 <strlcpy+0x32>
  800869:	0f b6 19             	movzbl (%ecx),%ebx
  80086c:	84 db                	test   %bl,%bl
  80086e:	75 ec                	jne    80085c <strlcpy+0x1c>
  800870:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800872:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800875:	29 f0                	sub    %esi,%eax
}
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800884:	eb 06                	jmp    80088c <strcmp+0x11>
		p++, q++;
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088c:	0f b6 01             	movzbl (%ecx),%eax
  80088f:	84 c0                	test   %al,%al
  800891:	74 04                	je     800897 <strcmp+0x1c>
  800893:	3a 02                	cmp    (%edx),%al
  800895:	74 ef                	je     800886 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800897:	0f b6 c0             	movzbl %al,%eax
  80089a:	0f b6 12             	movzbl (%edx),%edx
  80089d:	29 d0                	sub    %edx,%eax
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ab:	89 c3                	mov    %eax,%ebx
  8008ad:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b0:	eb 06                	jmp    8008b8 <strncmp+0x17>
		n--, p++, q++;
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b8:	39 d8                	cmp    %ebx,%eax
  8008ba:	74 18                	je     8008d4 <strncmp+0x33>
  8008bc:	0f b6 08             	movzbl (%eax),%ecx
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 04                	je     8008c7 <strncmp+0x26>
  8008c3:	3a 0a                	cmp    (%edx),%cl
  8008c5:	74 eb                	je     8008b2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c7:	0f b6 00             	movzbl (%eax),%eax
  8008ca:	0f b6 12             	movzbl (%edx),%edx
  8008cd:	29 d0                	sub    %edx,%eax
}
  8008cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    
		return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d9:	eb f4                	jmp    8008cf <strncmp+0x2e>

008008db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e5:	eb 03                	jmp    8008ea <strchr+0xf>
  8008e7:	83 c0 01             	add    $0x1,%eax
  8008ea:	0f b6 10             	movzbl (%eax),%edx
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	74 06                	je     8008f7 <strchr+0x1c>
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	75 f2                	jne    8008e7 <strchr+0xc>
  8008f5:	eb 05                	jmp    8008fc <strchr+0x21>
			return (char *) s;
	return 0;
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800908:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	74 09                	je     800918 <strfind+0x1a>
  80090f:	84 d2                	test   %dl,%dl
  800911:	74 05                	je     800918 <strfind+0x1a>
	for (; *s; s++)
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	eb f0                	jmp    800908 <strfind+0xa>
			break;
	return (char *) s;
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 7d 08             	mov    0x8(%ebp),%edi
  800923:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800926:	85 c9                	test   %ecx,%ecx
  800928:	74 2f                	je     800959 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092a:	89 f8                	mov    %edi,%eax
  80092c:	09 c8                	or     %ecx,%eax
  80092e:	a8 03                	test   $0x3,%al
  800930:	75 21                	jne    800953 <memset+0x39>
		c &= 0xFF;
  800932:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800936:	89 d0                	mov    %edx,%eax
  800938:	c1 e0 08             	shl    $0x8,%eax
  80093b:	89 d3                	mov    %edx,%ebx
  80093d:	c1 e3 18             	shl    $0x18,%ebx
  800940:	89 d6                	mov    %edx,%esi
  800942:	c1 e6 10             	shl    $0x10,%esi
  800945:	09 f3                	or     %esi,%ebx
  800947:	09 da                	or     %ebx,%edx
  800949:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80094e:	fc                   	cld    
  80094f:	f3 ab                	rep stos %eax,%es:(%edi)
  800951:	eb 06                	jmp    800959 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	fc                   	cld    
  800957:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800959:	89 f8                	mov    %edi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5f                   	pop    %edi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096e:	39 c6                	cmp    %eax,%esi
  800970:	73 32                	jae    8009a4 <memmove+0x44>
  800972:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800975:	39 c2                	cmp    %eax,%edx
  800977:	76 2b                	jbe    8009a4 <memmove+0x44>
		s += n;
		d += n;
  800979:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	89 d6                	mov    %edx,%esi
  80097e:	09 fe                	or     %edi,%esi
  800980:	09 ce                	or     %ecx,%esi
  800982:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800988:	75 0e                	jne    800998 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098a:	83 ef 04             	sub    $0x4,%edi
  80098d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800990:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800993:	fd                   	std    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 09                	jmp    8009a1 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800998:	83 ef 01             	sub    $0x1,%edi
  80099b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80099e:	fd                   	std    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a1:	fc                   	cld    
  8009a2:	eb 1a                	jmp    8009be <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	89 f2                	mov    %esi,%edx
  8009a6:	09 c2                	or     %eax,%edx
  8009a8:	09 ca                	or     %ecx,%edx
  8009aa:	f6 c2 03             	test   $0x3,%dl
  8009ad:	75 0a                	jne    8009b9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009af:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b7:	eb 05                	jmp    8009be <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c8:	ff 75 10             	push   0x10(%ebp)
  8009cb:	ff 75 0c             	push   0xc(%ebp)
  8009ce:	ff 75 08             	push   0x8(%ebp)
  8009d1:	e8 8a ff ff ff       	call   800960 <memmove>
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e3:	89 c6                	mov    %eax,%esi
  8009e5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e8:	eb 06                	jmp    8009f0 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009f0:	39 f0                	cmp    %esi,%eax
  8009f2:	74 14                	je     800a08 <memcmp+0x30>
		if (*s1 != *s2)
  8009f4:	0f b6 08             	movzbl (%eax),%ecx
  8009f7:	0f b6 1a             	movzbl (%edx),%ebx
  8009fa:	38 d9                	cmp    %bl,%cl
  8009fc:	74 ec                	je     8009ea <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009fe:	0f b6 c1             	movzbl %cl,%eax
  800a01:	0f b6 db             	movzbl %bl,%ebx
  800a04:	29 d8                	sub    %ebx,%eax
  800a06:	eb 05                	jmp    800a0d <memcmp+0x35>
	}

	return 0;
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1a:	89 c2                	mov    %eax,%edx
  800a1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1f:	eb 03                	jmp    800a24 <memfind+0x13>
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	39 d0                	cmp    %edx,%eax
  800a26:	73 04                	jae    800a2c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a28:	38 08                	cmp    %cl,(%eax)
  800a2a:	75 f5                	jne    800a21 <memfind+0x10>
			break;
	return (void *) s;
}
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 55 08             	mov    0x8(%ebp),%edx
  800a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3a:	eb 03                	jmp    800a3f <strtol+0x11>
		s++;
  800a3c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a3f:	0f b6 02             	movzbl (%edx),%eax
  800a42:	3c 20                	cmp    $0x20,%al
  800a44:	74 f6                	je     800a3c <strtol+0xe>
  800a46:	3c 09                	cmp    $0x9,%al
  800a48:	74 f2                	je     800a3c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a4a:	3c 2b                	cmp    $0x2b,%al
  800a4c:	74 2a                	je     800a78 <strtol+0x4a>
	int neg = 0;
  800a4e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a53:	3c 2d                	cmp    $0x2d,%al
  800a55:	74 2b                	je     800a82 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a57:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5d:	75 0f                	jne    800a6e <strtol+0x40>
  800a5f:	80 3a 30             	cmpb   $0x30,(%edx)
  800a62:	74 28                	je     800a8c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a6b:	0f 44 d8             	cmove  %eax,%ebx
  800a6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a73:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a76:	eb 46                	jmp    800abe <strtol+0x90>
		s++;
  800a78:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a80:	eb d5                	jmp    800a57 <strtol+0x29>
		s++, neg = 1;
  800a82:	83 c2 01             	add    $0x1,%edx
  800a85:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8a:	eb cb                	jmp    800a57 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a90:	74 0e                	je     800aa0 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	75 d8                	jne    800a6e <strtol+0x40>
		s++, base = 8;
  800a96:	83 c2 01             	add    $0x1,%edx
  800a99:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a9e:	eb ce                	jmp    800a6e <strtol+0x40>
		s += 2, base = 16;
  800aa0:	83 c2 02             	add    $0x2,%edx
  800aa3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa8:	eb c4                	jmp    800a6e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aaa:	0f be c0             	movsbl %al,%eax
  800aad:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab0:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ab3:	7d 3a                	jge    800aef <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ab5:	83 c2 01             	add    $0x1,%edx
  800ab8:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800abc:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800abe:	0f b6 02             	movzbl (%edx),%eax
  800ac1:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 09             	cmp    $0x9,%bl
  800ac9:	76 df                	jbe    800aaa <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800acb:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ace:	89 f3                	mov    %esi,%ebx
  800ad0:	80 fb 19             	cmp    $0x19,%bl
  800ad3:	77 08                	ja     800add <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ad5:	0f be c0             	movsbl %al,%eax
  800ad8:	83 e8 57             	sub    $0x57,%eax
  800adb:	eb d3                	jmp    800ab0 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800add:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 19             	cmp    $0x19,%bl
  800ae5:	77 08                	ja     800aef <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ae7:	0f be c0             	movsbl %al,%eax
  800aea:	83 e8 37             	sub    $0x37,%eax
  800aed:	eb c1                	jmp    800ab0 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af3:	74 05                	je     800afa <strtol+0xcc>
		*endptr = (char *) s;
  800af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800afa:	89 c8                	mov    %ecx,%eax
  800afc:	f7 d8                	neg    %eax
  800afe:	85 ff                	test   %edi,%edi
  800b00:	0f 45 c8             	cmovne %eax,%ecx
}
  800b03:	89 c8                	mov    %ecx,%eax
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b10:	b8 00 00 00 00       	mov    $0x0,%eax
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1b:	89 c3                	mov    %eax,%ebx
  800b1d:	89 c7                	mov    %eax,%edi
  800b1f:	89 c6                	mov    %eax,%esi
  800b21:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b33:	b8 01 00 00 00       	mov    $0x1,%eax
  800b38:	89 d1                	mov    %edx,%ecx
  800b3a:	89 d3                	mov    %edx,%ebx
  800b3c:	89 d7                	mov    %edx,%edi
  800b3e:	89 d6                	mov    %edx,%esi
  800b40:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5d:	89 cb                	mov    %ecx,%ebx
  800b5f:	89 cf                	mov    %ecx,%edi
  800b61:	89 ce                	mov    %ecx,%esi
  800b63:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b65:	85 c0                	test   %eax,%eax
  800b67:	7f 08                	jg     800b71 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	50                   	push   %eax
  800b75:	6a 03                	push   $0x3
  800b77:	68 a4 16 80 00       	push   $0x8016a4
  800b7c:	6a 2a                	push   $0x2a
  800b7e:	68 c1 16 80 00       	push   $0x8016c1
  800b83:	e8 4d 05 00 00       	call   8010d5 <_panic>

00800b88 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 02 00 00 00       	mov    $0x2,%eax
  800b98:	89 d1                	mov    %edx,%ecx
  800b9a:	89 d3                	mov    %edx,%ebx
  800b9c:	89 d7                	mov    %edx,%edi
  800b9e:	89 d6                	mov    %edx,%esi
  800ba0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_yield>:

void
sys_yield(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb7:	89 d1                	mov    %edx,%ecx
  800bb9:	89 d3                	mov    %edx,%ebx
  800bbb:	89 d7                	mov    %edx,%edi
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcf:	be 00 00 00 00       	mov    $0x0,%esi
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be2:	89 f7                	mov    %esi,%edi
  800be4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be6:	85 c0                	test   %eax,%eax
  800be8:	7f 08                	jg     800bf2 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf2:	83 ec 0c             	sub    $0xc,%esp
  800bf5:	50                   	push   %eax
  800bf6:	6a 04                	push   $0x4
  800bf8:	68 a4 16 80 00       	push   $0x8016a4
  800bfd:	6a 2a                	push   $0x2a
  800bff:	68 c1 16 80 00       	push   $0x8016c1
  800c04:	e8 cc 04 00 00       	call   8010d5 <_panic>

00800c09 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c23:	8b 75 18             	mov    0x18(%ebp),%esi
  800c26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7f 08                	jg     800c34 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	50                   	push   %eax
  800c38:	6a 05                	push   $0x5
  800c3a:	68 a4 16 80 00       	push   $0x8016a4
  800c3f:	6a 2a                	push   $0x2a
  800c41:	68 c1 16 80 00       	push   $0x8016c1
  800c46:	e8 8a 04 00 00       	call   8010d5 <_panic>

00800c4b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c64:	89 df                	mov    %ebx,%edi
  800c66:	89 de                	mov    %ebx,%esi
  800c68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7f 08                	jg     800c76 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c76:	83 ec 0c             	sub    $0xc,%esp
  800c79:	50                   	push   %eax
  800c7a:	6a 06                	push   $0x6
  800c7c:	68 a4 16 80 00       	push   $0x8016a4
  800c81:	6a 2a                	push   $0x2a
  800c83:	68 c1 16 80 00       	push   $0x8016c1
  800c88:	e8 48 04 00 00       	call   8010d5 <_panic>

00800c8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7f 08                	jg     800cb8 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 08                	push   $0x8
  800cbe:	68 a4 16 80 00       	push   $0x8016a4
  800cc3:	6a 2a                	push   $0x2a
  800cc5:	68 c1 16 80 00       	push   $0x8016c1
  800cca:	e8 06 04 00 00       	call   8010d5 <_panic>

00800ccf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7f 08                	jg     800cfa <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 09                	push   $0x9
  800d00:	68 a4 16 80 00       	push   $0x8016a4
  800d05:	6a 2a                	push   $0x2a
  800d07:	68 c1 16 80 00       	push   $0x8016c1
  800d0c:	e8 c4 03 00 00       	call   8010d5 <_panic>

00800d11 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d22:	be 00 00 00 00       	mov    $0x0,%esi
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4a:	89 cb                	mov    %ecx,%ebx
  800d4c:	89 cf                	mov    %ecx,%edi
  800d4e:	89 ce                	mov    %ecx,%esi
  800d50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7f 08                	jg     800d5e <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 0c                	push   $0xc
  800d64:	68 a4 16 80 00       	push   $0x8016a4
  800d69:	6a 2a                	push   $0x2a
  800d6b:	68 c1 16 80 00       	push   $0x8016c1
  800d70:	e8 60 03 00 00       	call   8010d5 <_panic>

00800d75 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d7d:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800d7f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d83:	0f 84 8e 00 00 00    	je     800e17 <pgfault+0xa2>
  800d89:	89 f0                	mov    %esi,%eax
  800d8b:	c1 e8 0c             	shr    $0xc,%eax
  800d8e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d95:	f6 c4 08             	test   $0x8,%ah
  800d98:	74 7d                	je     800e17 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800d9a:	e8 e9 fd ff ff       	call   800b88 <sys_getenvid>
  800d9f:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800da1:	83 ec 04             	sub    $0x4,%esp
  800da4:	6a 07                	push   $0x7
  800da6:	68 00 f0 7f 00       	push   $0x7ff000
  800dab:	50                   	push   %eax
  800dac:	e8 15 fe ff ff       	call   800bc6 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	78 73                	js     800e2b <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800db8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800dbe:	83 ec 04             	sub    $0x4,%esp
  800dc1:	68 00 10 00 00       	push   $0x1000
  800dc6:	56                   	push   %esi
  800dc7:	68 00 f0 7f 00       	push   $0x7ff000
  800dcc:	e8 8f fb ff ff       	call   800960 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800dd1:	83 c4 08             	add    $0x8,%esp
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	e8 70 fe ff ff       	call   800c4b <sys_page_unmap>
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	78 5b                	js     800e3d <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	6a 07                	push   $0x7
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	68 00 f0 7f 00       	push   $0x7ff000
  800dee:	53                   	push   %ebx
  800def:	e8 15 fe ff ff       	call   800c09 <sys_page_map>
  800df4:	83 c4 20             	add    $0x20,%esp
  800df7:	85 c0                	test   %eax,%eax
  800df9:	78 54                	js     800e4f <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800dfb:	83 ec 08             	sub    $0x8,%esp
  800dfe:	68 00 f0 7f 00       	push   $0x7ff000
  800e03:	53                   	push   %ebx
  800e04:	e8 42 fe ff ff       	call   800c4b <sys_page_unmap>
  800e09:	83 c4 10             	add    $0x10,%esp
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	78 51                	js     800e61 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	68 d0 16 80 00       	push   $0x8016d0
  800e1f:	6a 1d                	push   $0x1d
  800e21:	68 4c 17 80 00       	push   $0x80174c
  800e26:	e8 aa 02 00 00       	call   8010d5 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e2b:	50                   	push   %eax
  800e2c:	68 08 17 80 00       	push   $0x801708
  800e31:	6a 29                	push   $0x29
  800e33:	68 4c 17 80 00       	push   $0x80174c
  800e38:	e8 98 02 00 00       	call   8010d5 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e3d:	50                   	push   %eax
  800e3e:	68 2c 17 80 00       	push   $0x80172c
  800e43:	6a 2e                	push   $0x2e
  800e45:	68 4c 17 80 00       	push   $0x80174c
  800e4a:	e8 86 02 00 00       	call   8010d5 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800e4f:	50                   	push   %eax
  800e50:	68 57 17 80 00       	push   $0x801757
  800e55:	6a 30                	push   $0x30
  800e57:	68 4c 17 80 00       	push   $0x80174c
  800e5c:	e8 74 02 00 00       	call   8010d5 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e61:	50                   	push   %eax
  800e62:	68 2c 17 80 00       	push   $0x80172c
  800e67:	6a 32                	push   $0x32
  800e69:	68 4c 17 80 00       	push   $0x80174c
  800e6e:	e8 62 02 00 00       	call   8010d5 <_panic>

00800e73 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800e7c:	68 75 0d 80 00       	push   $0x800d75
  800e81:	e8 95 02 00 00       	call   80111b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e86:	b8 07 00 00 00       	mov    $0x7,%eax
  800e8b:	cd 30                	int    $0x30
  800e8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	78 2a                	js     800ec1 <fork+0x4e>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800e97:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800e9c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ea0:	75 5e                	jne    800f00 <fork+0x8d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ea2:	e8 e1 fc ff ff       	call   800b88 <sys_getenvid>
  800ea7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eaf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eb4:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800eb9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ebc:	e9 b0 00 00 00       	jmp    800f71 <fork+0xfe>
		panic("sys_exofork: %e", envid);
  800ec1:	50                   	push   %eax
  800ec2:	68 75 17 80 00       	push   $0x801775
  800ec7:	6a 75                	push   $0x75
  800ec9:	68 4c 17 80 00       	push   $0x80174c
  800ece:	e8 02 02 00 00       	call   8010d5 <_panic>
	r=sys_page_map(this_envid, va, this_envid, va, perm);//一定要用系统调用， 因为权限！！
  800ed3:	83 ec 0c             	sub    $0xc,%esp
  800ed6:	56                   	push   %esi
  800ed7:	57                   	push   %edi
  800ed8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800edb:	51                   	push   %ecx
  800edc:	57                   	push   %edi
  800edd:	51                   	push   %ecx
  800ede:	e8 26 fd ff ff       	call   800c09 <sys_page_map>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
		    // dup page to child
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800ee3:	83 c4 20             	add    $0x20,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	0f 88 8b 00 00 00    	js     800f79 <fork+0x106>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800eee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ef4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800efa:	0f 84 83 00 00 00    	je     800f83 <fork+0x110>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	c1 e8 16             	shr    $0x16,%eax
  800f05:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f0c:	a8 01                	test   $0x1,%al
  800f0e:	74 de                	je     800eee <fork+0x7b>
  800f10:	89 de                	mov    %ebx,%esi
  800f12:	c1 ee 0c             	shr    $0xc,%esi
  800f15:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f1c:	a8 01                	test   $0x1,%al
  800f1e:	74 ce                	je     800eee <fork+0x7b>
	envid_t this_envid = sys_getenvid();//父进程号
  800f20:	e8 63 fc ff ff       	call   800b88 <sys_getenvid>
  800f25:	89 c1                	mov    %eax,%ecx
	void * va = (void *)(pn * PGSIZE);
  800f27:	89 f7                	mov    %esi,%edi
  800f29:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & 0xFFF;
  800f2c:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
		perm &= ~PTE_W;
  800f33:	89 d0                	mov    %edx,%eax
  800f35:	25 fd 0f 00 00       	and    $0xffd,%eax
  800f3a:	80 cc 08             	or     $0x8,%ah
  800f3d:	89 d6                	mov    %edx,%esi
  800f3f:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
  800f45:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f4b:	0f 45 f0             	cmovne %eax,%esi
	perm&=PTE_SYSCALL; // 写sys_page_map函数时 perm必须要达成的要求
  800f4e:	81 e6 07 0e 00 00    	and    $0xe07,%esi
	r=sys_page_map(this_envid, va, envid, va, perm);
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	56                   	push   %esi
  800f58:	57                   	push   %edi
  800f59:	ff 75 e0             	push   -0x20(%ebp)
  800f5c:	57                   	push   %edi
  800f5d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800f60:	51                   	push   %ecx
  800f61:	e8 a3 fc ff ff       	call   800c09 <sys_page_map>
	if(r<0) return r;
  800f66:	83 c4 20             	add    $0x20,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	0f 89 62 ff ff ff    	jns    800ed3 <fork+0x60>
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7e:	0f 4f c2             	cmovg  %edx,%eax
  800f81:	eb ee                	jmp    800f71 <fork+0xfe>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800f83:	83 ec 04             	sub    $0x4,%esp
  800f86:	6a 07                	push   $0x7
  800f88:	68 00 f0 bf ee       	push   $0xeebff000
  800f8d:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800f90:	57                   	push   %edi
  800f91:	e8 30 fc ff ff       	call   800bc6 <sys_page_alloc>
	if(r<0) return r;
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 d4                	js     800f71 <fork+0xfe>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	68 91 11 80 00       	push   $0x801191
  800fa5:	57                   	push   %edi
  800fa6:	e8 24 fd ff ff       	call   800ccf <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	78 bf                	js     800f71 <fork+0xfe>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fb2:	83 ec 08             	sub    $0x8,%esp
  800fb5:	6a 02                	push   $0x2
  800fb7:	57                   	push   %edi
  800fb8:	e8 d0 fc ff ff       	call   800c8d <sys_env_set_status>
	if(r<0) return r;
  800fbd:	83 c4 10             	add    $0x10,%esp
	return envid;
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	0f 49 c7             	cmovns %edi,%eax
  800fc5:	eb aa                	jmp    800f71 <fork+0xfe>

00800fc7 <sfork>:

// Challenge!
int
sfork(void)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fcd:	68 85 17 80 00       	push   $0x801785
  800fd2:	68 9e 00 00 00       	push   $0x9e
  800fd7:	68 4c 17 80 00       	push   $0x80174c
  800fdc:	e8 f4 00 00 00       	call   8010d5 <_panic>

00800fe1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	56                   	push   %esi
  800fe5:	53                   	push   %ebx
  800fe6:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800ff6:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	50                   	push   %eax
  800ffd:	e8 32 fd ff ff       	call   800d34 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	85 f6                	test   %esi,%esi
  801007:	74 14                	je     80101d <ipc_recv+0x3c>
  801009:	ba 00 00 00 00       	mov    $0x0,%edx
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 09                	js     80101b <ipc_recv+0x3a>
  801012:	8b 15 08 20 80 00    	mov    0x802008,%edx
  801018:	8b 52 74             	mov    0x74(%edx),%edx
  80101b:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80101d:	85 db                	test   %ebx,%ebx
  80101f:	74 14                	je     801035 <ipc_recv+0x54>
  801021:	ba 00 00 00 00       	mov    $0x0,%edx
  801026:	85 c0                	test   %eax,%eax
  801028:	78 09                	js     801033 <ipc_recv+0x52>
  80102a:	8b 15 08 20 80 00    	mov    0x802008,%edx
  801030:	8b 52 78             	mov    0x78(%edx),%edx
  801033:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801035:	85 c0                	test   %eax,%eax
  801037:	78 08                	js     801041 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801039:	a1 08 20 80 00       	mov    0x802008,%eax
  80103e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801041:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	57                   	push   %edi
  80104c:	56                   	push   %esi
  80104d:	53                   	push   %ebx
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	8b 7d 08             	mov    0x8(%ebp),%edi
  801054:	8b 75 0c             	mov    0xc(%ebp),%esi
  801057:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80105a:	85 db                	test   %ebx,%ebx
  80105c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801061:	0f 44 d8             	cmove  %eax,%ebx
  801064:	eb 05                	jmp    80106b <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801066:	e8 3c fb ff ff       	call   800ba7 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80106b:	ff 75 14             	push   0x14(%ebp)
  80106e:	53                   	push   %ebx
  80106f:	56                   	push   %esi
  801070:	57                   	push   %edi
  801071:	e8 9b fc ff ff       	call   800d11 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80107c:	74 e8                	je     801066 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 08                	js     80108a <ipc_send+0x42>
	}while (r<0);

}
  801082:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801085:	5b                   	pop    %ebx
  801086:	5e                   	pop    %esi
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80108a:	50                   	push   %eax
  80108b:	68 9b 17 80 00       	push   $0x80179b
  801090:	6a 3d                	push   $0x3d
  801092:	68 af 17 80 00       	push   $0x8017af
  801097:	e8 39 00 00 00       	call   8010d5 <_panic>

0080109c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010a2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010a7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010aa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010b0:	8b 52 50             	mov    0x50(%edx),%edx
  8010b3:	39 ca                	cmp    %ecx,%edx
  8010b5:	74 11                	je     8010c8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8010b7:	83 c0 01             	add    $0x1,%eax
  8010ba:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010bf:	75 e6                	jne    8010a7 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8010c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c6:	eb 0b                	jmp    8010d3 <ipc_find_env+0x37>
			return envs[i].env_id;
  8010c8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010da:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010dd:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010e3:	e8 a0 fa ff ff       	call   800b88 <sys_getenvid>
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	ff 75 0c             	push   0xc(%ebp)
  8010ee:	ff 75 08             	push   0x8(%ebp)
  8010f1:	56                   	push   %esi
  8010f2:	50                   	push   %eax
  8010f3:	68 bc 17 80 00       	push   $0x8017bc
  8010f8:	e8 f3 f0 ff ff       	call   8001f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010fd:	83 c4 18             	add    $0x18,%esp
  801100:	53                   	push   %ebx
  801101:	ff 75 10             	push   0x10(%ebp)
  801104:	e8 96 f0 ff ff       	call   80019f <vcprintf>
	cprintf("\n");
  801109:	c7 04 24 18 14 80 00 	movl   $0x801418,(%esp)
  801110:	e8 db f0 ff ff       	call   8001f0 <cprintf>
  801115:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801118:	cc                   	int3   
  801119:	eb fd                	jmp    801118 <_panic+0x43>

0080111b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801121:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801128:	74 0a                	je     801134 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801132:	c9                   	leave  
  801133:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801134:	e8 4f fa ff ff       	call   800b88 <sys_getenvid>
  801139:	83 ec 04             	sub    $0x4,%esp
  80113c:	68 07 0e 00 00       	push   $0xe07
  801141:	68 00 f0 bf ee       	push   $0xeebff000
  801146:	50                   	push   %eax
  801147:	e8 7a fa ff ff       	call   800bc6 <sys_page_alloc>
		if (r < 0) {
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 2c                	js     80117f <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801153:	e8 30 fa ff ff       	call   800b88 <sys_getenvid>
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	68 91 11 80 00       	push   $0x801191
  801160:	50                   	push   %eax
  801161:	e8 69 fb ff ff       	call   800ccf <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	85 c0                	test   %eax,%eax
  80116b:	79 bd                	jns    80112a <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80116d:	50                   	push   %eax
  80116e:	68 20 18 80 00       	push   $0x801820
  801173:	6a 28                	push   $0x28
  801175:	68 56 18 80 00       	push   $0x801856
  80117a:	e8 56 ff ff ff       	call   8010d5 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80117f:	50                   	push   %eax
  801180:	68 e0 17 80 00       	push   $0x8017e0
  801185:	6a 23                	push   $0x23
  801187:	68 56 18 80 00       	push   $0x801856
  80118c:	e8 44 ff ff ff       	call   8010d5 <_panic>

00801191 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801191:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801192:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801197:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801199:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80119c:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8011a0:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8011a3:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8011a7:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8011ab:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8011ad:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8011b0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8011b1:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8011b4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8011b5:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8011b6:	c3                   	ret    
  8011b7:	66 90                	xchg   %ax,%ax
  8011b9:	66 90                	xchg   %ax,%ax
  8011bb:	66 90                	xchg   %ax,%ax
  8011bd:	66 90                	xchg   %ax,%ax
  8011bf:	90                   	nop

008011c0 <__udivdi3>:
  8011c0:	f3 0f 1e fb          	endbr32 
  8011c4:	55                   	push   %ebp
  8011c5:	57                   	push   %edi
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 1c             	sub    $0x1c,%esp
  8011cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8011cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8011d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	75 19                	jne    8011f8 <__udivdi3+0x38>
  8011df:	39 f3                	cmp    %esi,%ebx
  8011e1:	76 4d                	jbe    801230 <__udivdi3+0x70>
  8011e3:	31 ff                	xor    %edi,%edi
  8011e5:	89 e8                	mov    %ebp,%eax
  8011e7:	89 f2                	mov    %esi,%edx
  8011e9:	f7 f3                	div    %ebx
  8011eb:	89 fa                	mov    %edi,%edx
  8011ed:	83 c4 1c             	add    $0x1c,%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    
  8011f5:	8d 76 00             	lea    0x0(%esi),%esi
  8011f8:	39 f0                	cmp    %esi,%eax
  8011fa:	76 14                	jbe    801210 <__udivdi3+0x50>
  8011fc:	31 ff                	xor    %edi,%edi
  8011fe:	31 c0                	xor    %eax,%eax
  801200:	89 fa                	mov    %edi,%edx
  801202:	83 c4 1c             	add    $0x1c,%esp
  801205:	5b                   	pop    %ebx
  801206:	5e                   	pop    %esi
  801207:	5f                   	pop    %edi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    
  80120a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801210:	0f bd f8             	bsr    %eax,%edi
  801213:	83 f7 1f             	xor    $0x1f,%edi
  801216:	75 48                	jne    801260 <__udivdi3+0xa0>
  801218:	39 f0                	cmp    %esi,%eax
  80121a:	72 06                	jb     801222 <__udivdi3+0x62>
  80121c:	31 c0                	xor    %eax,%eax
  80121e:	39 eb                	cmp    %ebp,%ebx
  801220:	77 de                	ja     801200 <__udivdi3+0x40>
  801222:	b8 01 00 00 00       	mov    $0x1,%eax
  801227:	eb d7                	jmp    801200 <__udivdi3+0x40>
  801229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801230:	89 d9                	mov    %ebx,%ecx
  801232:	85 db                	test   %ebx,%ebx
  801234:	75 0b                	jne    801241 <__udivdi3+0x81>
  801236:	b8 01 00 00 00       	mov    $0x1,%eax
  80123b:	31 d2                	xor    %edx,%edx
  80123d:	f7 f3                	div    %ebx
  80123f:	89 c1                	mov    %eax,%ecx
  801241:	31 d2                	xor    %edx,%edx
  801243:	89 f0                	mov    %esi,%eax
  801245:	f7 f1                	div    %ecx
  801247:	89 c6                	mov    %eax,%esi
  801249:	89 e8                	mov    %ebp,%eax
  80124b:	89 f7                	mov    %esi,%edi
  80124d:	f7 f1                	div    %ecx
  80124f:	89 fa                	mov    %edi,%edx
  801251:	83 c4 1c             	add    $0x1c,%esp
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5f                   	pop    %edi
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    
  801259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801260:	89 f9                	mov    %edi,%ecx
  801262:	ba 20 00 00 00       	mov    $0x20,%edx
  801267:	29 fa                	sub    %edi,%edx
  801269:	d3 e0                	shl    %cl,%eax
  80126b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80126f:	89 d1                	mov    %edx,%ecx
  801271:	89 d8                	mov    %ebx,%eax
  801273:	d3 e8                	shr    %cl,%eax
  801275:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801279:	09 c1                	or     %eax,%ecx
  80127b:	89 f0                	mov    %esi,%eax
  80127d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801281:	89 f9                	mov    %edi,%ecx
  801283:	d3 e3                	shl    %cl,%ebx
  801285:	89 d1                	mov    %edx,%ecx
  801287:	d3 e8                	shr    %cl,%eax
  801289:	89 f9                	mov    %edi,%ecx
  80128b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80128f:	89 eb                	mov    %ebp,%ebx
  801291:	d3 e6                	shl    %cl,%esi
  801293:	89 d1                	mov    %edx,%ecx
  801295:	d3 eb                	shr    %cl,%ebx
  801297:	09 f3                	or     %esi,%ebx
  801299:	89 c6                	mov    %eax,%esi
  80129b:	89 f2                	mov    %esi,%edx
  80129d:	89 d8                	mov    %ebx,%eax
  80129f:	f7 74 24 08          	divl   0x8(%esp)
  8012a3:	89 d6                	mov    %edx,%esi
  8012a5:	89 c3                	mov    %eax,%ebx
  8012a7:	f7 64 24 0c          	mull   0xc(%esp)
  8012ab:	39 d6                	cmp    %edx,%esi
  8012ad:	72 19                	jb     8012c8 <__udivdi3+0x108>
  8012af:	89 f9                	mov    %edi,%ecx
  8012b1:	d3 e5                	shl    %cl,%ebp
  8012b3:	39 c5                	cmp    %eax,%ebp
  8012b5:	73 04                	jae    8012bb <__udivdi3+0xfb>
  8012b7:	39 d6                	cmp    %edx,%esi
  8012b9:	74 0d                	je     8012c8 <__udivdi3+0x108>
  8012bb:	89 d8                	mov    %ebx,%eax
  8012bd:	31 ff                	xor    %edi,%edi
  8012bf:	e9 3c ff ff ff       	jmp    801200 <__udivdi3+0x40>
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8012cb:	31 ff                	xor    %edi,%edi
  8012cd:	e9 2e ff ff ff       	jmp    801200 <__udivdi3+0x40>
  8012d2:	66 90                	xchg   %ax,%ax
  8012d4:	66 90                	xchg   %ax,%ax
  8012d6:	66 90                	xchg   %ax,%ax
  8012d8:	66 90                	xchg   %ax,%ax
  8012da:	66 90                	xchg   %ax,%ax
  8012dc:	66 90                	xchg   %ax,%ax
  8012de:	66 90                	xchg   %ax,%ax

008012e0 <__umoddi3>:
  8012e0:	f3 0f 1e fb          	endbr32 
  8012e4:	55                   	push   %ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 1c             	sub    $0x1c,%esp
  8012eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8012ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8012f3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8012f7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8012fb:	89 f0                	mov    %esi,%eax
  8012fd:	89 da                	mov    %ebx,%edx
  8012ff:	85 ff                	test   %edi,%edi
  801301:	75 15                	jne    801318 <__umoddi3+0x38>
  801303:	39 dd                	cmp    %ebx,%ebp
  801305:	76 39                	jbe    801340 <__umoddi3+0x60>
  801307:	f7 f5                	div    %ebp
  801309:	89 d0                	mov    %edx,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	83 c4 1c             	add    $0x1c,%esp
  801310:	5b                   	pop    %ebx
  801311:	5e                   	pop    %esi
  801312:	5f                   	pop    %edi
  801313:	5d                   	pop    %ebp
  801314:	c3                   	ret    
  801315:	8d 76 00             	lea    0x0(%esi),%esi
  801318:	39 df                	cmp    %ebx,%edi
  80131a:	77 f1                	ja     80130d <__umoddi3+0x2d>
  80131c:	0f bd cf             	bsr    %edi,%ecx
  80131f:	83 f1 1f             	xor    $0x1f,%ecx
  801322:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801326:	75 40                	jne    801368 <__umoddi3+0x88>
  801328:	39 df                	cmp    %ebx,%edi
  80132a:	72 04                	jb     801330 <__umoddi3+0x50>
  80132c:	39 f5                	cmp    %esi,%ebp
  80132e:	77 dd                	ja     80130d <__umoddi3+0x2d>
  801330:	89 da                	mov    %ebx,%edx
  801332:	89 f0                	mov    %esi,%eax
  801334:	29 e8                	sub    %ebp,%eax
  801336:	19 fa                	sbb    %edi,%edx
  801338:	eb d3                	jmp    80130d <__umoddi3+0x2d>
  80133a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801340:	89 e9                	mov    %ebp,%ecx
  801342:	85 ed                	test   %ebp,%ebp
  801344:	75 0b                	jne    801351 <__umoddi3+0x71>
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	f7 f5                	div    %ebp
  80134f:	89 c1                	mov    %eax,%ecx
  801351:	89 d8                	mov    %ebx,%eax
  801353:	31 d2                	xor    %edx,%edx
  801355:	f7 f1                	div    %ecx
  801357:	89 f0                	mov    %esi,%eax
  801359:	f7 f1                	div    %ecx
  80135b:	89 d0                	mov    %edx,%eax
  80135d:	31 d2                	xor    %edx,%edx
  80135f:	eb ac                	jmp    80130d <__umoddi3+0x2d>
  801361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801368:	8b 44 24 04          	mov    0x4(%esp),%eax
  80136c:	ba 20 00 00 00       	mov    $0x20,%edx
  801371:	29 c2                	sub    %eax,%edx
  801373:	89 c1                	mov    %eax,%ecx
  801375:	89 e8                	mov    %ebp,%eax
  801377:	d3 e7                	shl    %cl,%edi
  801379:	89 d1                	mov    %edx,%ecx
  80137b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80137f:	d3 e8                	shr    %cl,%eax
  801381:	89 c1                	mov    %eax,%ecx
  801383:	8b 44 24 04          	mov    0x4(%esp),%eax
  801387:	09 f9                	or     %edi,%ecx
  801389:	89 df                	mov    %ebx,%edi
  80138b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138f:	89 c1                	mov    %eax,%ecx
  801391:	d3 e5                	shl    %cl,%ebp
  801393:	89 d1                	mov    %edx,%ecx
  801395:	d3 ef                	shr    %cl,%edi
  801397:	89 c1                	mov    %eax,%ecx
  801399:	89 f0                	mov    %esi,%eax
  80139b:	d3 e3                	shl    %cl,%ebx
  80139d:	89 d1                	mov    %edx,%ecx
  80139f:	89 fa                	mov    %edi,%edx
  8013a1:	d3 e8                	shr    %cl,%eax
  8013a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013a8:	09 d8                	or     %ebx,%eax
  8013aa:	f7 74 24 08          	divl   0x8(%esp)
  8013ae:	89 d3                	mov    %edx,%ebx
  8013b0:	d3 e6                	shl    %cl,%esi
  8013b2:	f7 e5                	mul    %ebp
  8013b4:	89 c7                	mov    %eax,%edi
  8013b6:	89 d1                	mov    %edx,%ecx
  8013b8:	39 d3                	cmp    %edx,%ebx
  8013ba:	72 06                	jb     8013c2 <__umoddi3+0xe2>
  8013bc:	75 0e                	jne    8013cc <__umoddi3+0xec>
  8013be:	39 c6                	cmp    %eax,%esi
  8013c0:	73 0a                	jae    8013cc <__umoddi3+0xec>
  8013c2:	29 e8                	sub    %ebp,%eax
  8013c4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8013c8:	89 d1                	mov    %edx,%ecx
  8013ca:	89 c7                	mov    %eax,%edi
  8013cc:	89 f5                	mov    %esi,%ebp
  8013ce:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013d2:	29 fd                	sub    %edi,%ebp
  8013d4:	19 cb                	sbb    %ecx,%ebx
  8013d6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8013db:	89 d8                	mov    %ebx,%eax
  8013dd:	d3 e0                	shl    %cl,%eax
  8013df:	89 f1                	mov    %esi,%ecx
  8013e1:	d3 ed                	shr    %cl,%ebp
  8013e3:	d3 eb                	shr    %cl,%ebx
  8013e5:	09 e8                	or     %ebp,%eax
  8013e7:	89 da                	mov    %ebx,%edx
  8013e9:	83 c4 1c             	add    $0x1c,%esp
  8013ec:	5b                   	pop    %ebx
  8013ed:	5e                   	pop    %esi
  8013ee:	5f                   	pop    %edi
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    
