
obj/user/yield.debug：     文件格式 elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 00 40 80 00       	mov    0x804000,%eax
  80003f:	8b 40 58             	mov    0x58(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 a0 22 80 00       	push   $0x8022a0
  800048:	e8 45 01 00 00       	call   800192 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 ef 0a 00 00       	call   800b49 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 00 40 80 00       	mov    0x804000,%eax
  80005f:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 c0 22 80 00       	push   $0x8022c0
  80006c:	e8 21 01 00 00       	call   800192 <cprintf>
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 00 40 80 00       	mov    0x804000,%eax
  800081:	8b 40 58             	mov    0x58(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 ec 22 80 00       	push   $0x8022ec
  80008d:	e8 00 01 00 00       	call   800192 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 80 0a 00 00       	call   800b2a <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8000b5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ba:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bf:	85 db                	test   %ebx,%ebx
  8000c1:	7e 07                	jle    8000ca <libmain+0x30>
		binaryname = argv[0];
  8000c3:	8b 06                	mov    (%esi),%eax
  8000c5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ca:	83 ec 08             	sub    $0x8,%esp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	e8 5f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0a 00 00 00       	call   8000e3 <exit>
}
  8000d9:	83 c4 10             	add    $0x10,%esp
  8000dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e9:	e8 9d 0e 00 00       	call   800f8b <close_all>
	sys_env_destroy(0);
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	6a 00                	push   $0x0
  8000f3:	e8 f1 09 00 00       	call   800ae9 <sys_env_destroy>
}
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	53                   	push   %ebx
  800101:	83 ec 04             	sub    $0x4,%esp
  800104:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800107:	8b 13                	mov    (%ebx),%edx
  800109:	8d 42 01             	lea    0x1(%edx),%eax
  80010c:	89 03                	mov    %eax,(%ebx)
  80010e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800111:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800115:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011a:	74 09                	je     800125 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800123:	c9                   	leave  
  800124:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	68 ff 00 00 00       	push   $0xff
  80012d:	8d 43 08             	lea    0x8(%ebx),%eax
  800130:	50                   	push   %eax
  800131:	e8 76 09 00 00       	call   800aac <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	eb db                	jmp    80011c <putch+0x1f>

00800141 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800151:	00 00 00 
	b.cnt = 0;
  800154:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015e:	ff 75 0c             	push   0xc(%ebp)
  800161:	ff 75 08             	push   0x8(%ebp)
  800164:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016a:	50                   	push   %eax
  80016b:	68 fd 00 80 00       	push   $0x8000fd
  800170:	e8 14 01 00 00       	call   800289 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800175:	83 c4 08             	add    $0x8,%esp
  800178:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80017e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800184:	50                   	push   %eax
  800185:	e8 22 09 00 00       	call   800aac <sys_cputs>

	return b.cnt;
}
  80018a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800190:	c9                   	leave  
  800191:	c3                   	ret    

00800192 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800198:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019b:	50                   	push   %eax
  80019c:	ff 75 08             	push   0x8(%ebp)
  80019f:	e8 9d ff ff ff       	call   800141 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 1c             	sub    $0x1c,%esp
  8001af:	89 c7                	mov    %eax,%edi
  8001b1:	89 d6                	mov    %edx,%esi
  8001b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b9:	89 d1                	mov    %edx,%ecx
  8001bb:	89 c2                	mov    %eax,%edx
  8001bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d3:	39 c2                	cmp    %eax,%edx
  8001d5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001d8:	72 3e                	jb     800218 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	ff 75 18             	push   0x18(%ebp)
  8001e0:	83 eb 01             	sub    $0x1,%ebx
  8001e3:	53                   	push   %ebx
  8001e4:	50                   	push   %eax
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	ff 75 e4             	push   -0x1c(%ebp)
  8001eb:	ff 75 e0             	push   -0x20(%ebp)
  8001ee:	ff 75 dc             	push   -0x24(%ebp)
  8001f1:	ff 75 d8             	push   -0x28(%ebp)
  8001f4:	e8 57 1e 00 00       	call   802050 <__udivdi3>
  8001f9:	83 c4 18             	add    $0x18,%esp
  8001fc:	52                   	push   %edx
  8001fd:	50                   	push   %eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	89 f8                	mov    %edi,%eax
  800202:	e8 9f ff ff ff       	call   8001a6 <printnum>
  800207:	83 c4 20             	add    $0x20,%esp
  80020a:	eb 13                	jmp    80021f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	56                   	push   %esi
  800210:	ff 75 18             	push   0x18(%ebp)
  800213:	ff d7                	call   *%edi
  800215:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	85 db                	test   %ebx,%ebx
  80021d:	7f ed                	jg     80020c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	ff 75 e4             	push   -0x1c(%ebp)
  800229:	ff 75 e0             	push   -0x20(%ebp)
  80022c:	ff 75 dc             	push   -0x24(%ebp)
  80022f:	ff 75 d8             	push   -0x28(%ebp)
  800232:	e8 39 1f 00 00       	call   802170 <__umoddi3>
  800237:	83 c4 14             	add    $0x14,%esp
  80023a:	0f be 80 15 23 80 00 	movsbl 0x802315(%eax),%eax
  800241:	50                   	push   %eax
  800242:	ff d7                	call   *%edi
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800255:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800259:	8b 10                	mov    (%eax),%edx
  80025b:	3b 50 04             	cmp    0x4(%eax),%edx
  80025e:	73 0a                	jae    80026a <sprintputch+0x1b>
		*b->buf++ = ch;
  800260:	8d 4a 01             	lea    0x1(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	88 02                	mov    %al,(%edx)
}
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <printfmt>:
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800272:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 10             	push   0x10(%ebp)
  800279:	ff 75 0c             	push   0xc(%ebp)
  80027c:	ff 75 08             	push   0x8(%ebp)
  80027f:	e8 05 00 00 00       	call   800289 <vprintfmt>
}
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <vprintfmt>:
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	57                   	push   %edi
  80028d:	56                   	push   %esi
  80028e:	53                   	push   %ebx
  80028f:	83 ec 3c             	sub    $0x3c,%esp
  800292:	8b 75 08             	mov    0x8(%ebp),%esi
  800295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800298:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029b:	eb 0a                	jmp    8002a7 <vprintfmt+0x1e>
			putch(ch, putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	53                   	push   %ebx
  8002a1:	50                   	push   %eax
  8002a2:	ff d6                	call   *%esi
  8002a4:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a7:	83 c7 01             	add    $0x1,%edi
  8002aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ae:	83 f8 25             	cmp    $0x25,%eax
  8002b1:	74 0c                	je     8002bf <vprintfmt+0x36>
			if (ch == '\0')
  8002b3:	85 c0                	test   %eax,%eax
  8002b5:	75 e6                	jne    80029d <vprintfmt+0x14>
}
  8002b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5e                   	pop    %esi
  8002bc:	5f                   	pop    %edi
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    
		padc = ' ';
  8002bf:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002c3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ca:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002d1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002dd:	8d 47 01             	lea    0x1(%edi),%eax
  8002e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e3:	0f b6 17             	movzbl (%edi),%edx
  8002e6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e9:	3c 55                	cmp    $0x55,%al
  8002eb:	0f 87 bb 03 00 00    	ja     8006ac <vprintfmt+0x423>
  8002f1:	0f b6 c0             	movzbl %al,%eax
  8002f4:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002fe:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800302:	eb d9                	jmp    8002dd <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800307:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80030b:	eb d0                	jmp    8002dd <vprintfmt+0x54>
  80030d:	0f b6 d2             	movzbl %dl,%edx
  800310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800313:	b8 00 00 00 00       	mov    $0x0,%eax
  800318:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80031b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800322:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800325:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800328:	83 f9 09             	cmp    $0x9,%ecx
  80032b:	77 55                	ja     800382 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80032d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800330:	eb e9                	jmp    80031b <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800332:	8b 45 14             	mov    0x14(%ebp),%eax
  800335:	8b 00                	mov    (%eax),%eax
  800337:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033a:	8b 45 14             	mov    0x14(%ebp),%eax
  80033d:	8d 40 04             	lea    0x4(%eax),%eax
  800340:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800346:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034a:	79 91                	jns    8002dd <vprintfmt+0x54>
				width = precision, precision = -1;
  80034c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80034f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800352:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800359:	eb 82                	jmp    8002dd <vprintfmt+0x54>
  80035b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80035e:	85 d2                	test   %edx,%edx
  800360:	b8 00 00 00 00       	mov    $0x0,%eax
  800365:	0f 49 c2             	cmovns %edx,%eax
  800368:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80036e:	e9 6a ff ff ff       	jmp    8002dd <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800376:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80037d:	e9 5b ff ff ff       	jmp    8002dd <vprintfmt+0x54>
  800382:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800385:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800388:	eb bc                	jmp    800346 <vprintfmt+0xbd>
			lflag++;
  80038a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800390:	e9 48 ff ff ff       	jmp    8002dd <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800395:	8b 45 14             	mov    0x14(%ebp),%eax
  800398:	8d 78 04             	lea    0x4(%eax),%edi
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	53                   	push   %ebx
  80039f:	ff 30                	push   (%eax)
  8003a1:	ff d6                	call   *%esi
			break;
  8003a3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a9:	e9 9d 02 00 00       	jmp    80064b <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b1:	8d 78 04             	lea    0x4(%eax),%edi
  8003b4:	8b 10                	mov    (%eax),%edx
  8003b6:	89 d0                	mov    %edx,%eax
  8003b8:	f7 d8                	neg    %eax
  8003ba:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bd:	83 f8 0f             	cmp    $0xf,%eax
  8003c0:	7f 23                	jg     8003e5 <vprintfmt+0x15c>
  8003c2:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  8003c9:	85 d2                	test   %edx,%edx
  8003cb:	74 18                	je     8003e5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003cd:	52                   	push   %edx
  8003ce:	68 f5 26 80 00       	push   $0x8026f5
  8003d3:	53                   	push   %ebx
  8003d4:	56                   	push   %esi
  8003d5:	e8 92 fe ff ff       	call   80026c <printfmt>
  8003da:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003dd:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e0:	e9 66 02 00 00       	jmp    80064b <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003e5:	50                   	push   %eax
  8003e6:	68 2d 23 80 00       	push   $0x80232d
  8003eb:	53                   	push   %ebx
  8003ec:	56                   	push   %esi
  8003ed:	e8 7a fe ff ff       	call   80026c <printfmt>
  8003f2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f8:	e9 4e 02 00 00       	jmp    80064b <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	83 c0 04             	add    $0x4,%eax
  800403:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80040b:	85 d2                	test   %edx,%edx
  80040d:	b8 26 23 80 00       	mov    $0x802326,%eax
  800412:	0f 45 c2             	cmovne %edx,%eax
  800415:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800418:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041c:	7e 06                	jle    800424 <vprintfmt+0x19b>
  80041e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800422:	75 0d                	jne    800431 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800424:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800427:	89 c7                	mov    %eax,%edi
  800429:	03 45 e0             	add    -0x20(%ebp),%eax
  80042c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042f:	eb 55                	jmp    800486 <vprintfmt+0x1fd>
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	ff 75 d8             	push   -0x28(%ebp)
  800437:	ff 75 cc             	push   -0x34(%ebp)
  80043a:	e8 0a 03 00 00       	call   800749 <strnlen>
  80043f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800442:	29 c1                	sub    %eax,%ecx
  800444:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80044c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800450:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	eb 0f                	jmp    800464 <vprintfmt+0x1db>
					putch(padc, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	53                   	push   %ebx
  800459:	ff 75 e0             	push   -0x20(%ebp)
  80045c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ef 01             	sub    $0x1,%edi
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	85 ff                	test   %edi,%edi
  800466:	7f ed                	jg     800455 <vprintfmt+0x1cc>
  800468:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80046b:	85 d2                	test   %edx,%edx
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	0f 49 c2             	cmovns %edx,%eax
  800475:	29 c2                	sub    %eax,%edx
  800477:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80047a:	eb a8                	jmp    800424 <vprintfmt+0x19b>
					putch(ch, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	52                   	push   %edx
  800481:	ff d6                	call   *%esi
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800489:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048b:	83 c7 01             	add    $0x1,%edi
  80048e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800492:	0f be d0             	movsbl %al,%edx
  800495:	85 d2                	test   %edx,%edx
  800497:	74 4b                	je     8004e4 <vprintfmt+0x25b>
  800499:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049d:	78 06                	js     8004a5 <vprintfmt+0x21c>
  80049f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004a3:	78 1e                	js     8004c3 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a9:	74 d1                	je     80047c <vprintfmt+0x1f3>
  8004ab:	0f be c0             	movsbl %al,%eax
  8004ae:	83 e8 20             	sub    $0x20,%eax
  8004b1:	83 f8 5e             	cmp    $0x5e,%eax
  8004b4:	76 c6                	jbe    80047c <vprintfmt+0x1f3>
					putch('?', putdat);
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	53                   	push   %ebx
  8004ba:	6a 3f                	push   $0x3f
  8004bc:	ff d6                	call   *%esi
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	eb c3                	jmp    800486 <vprintfmt+0x1fd>
  8004c3:	89 cf                	mov    %ecx,%edi
  8004c5:	eb 0e                	jmp    8004d5 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	53                   	push   %ebx
  8004cb:	6a 20                	push   $0x20
  8004cd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004cf:	83 ef 01             	sub    $0x1,%edi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 ff                	test   %edi,%edi
  8004d7:	7f ee                	jg     8004c7 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004df:	e9 67 01 00 00       	jmp    80064b <vprintfmt+0x3c2>
  8004e4:	89 cf                	mov    %ecx,%edi
  8004e6:	eb ed                	jmp    8004d5 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004e8:	83 f9 01             	cmp    $0x1,%ecx
  8004eb:	7f 1b                	jg     800508 <vprintfmt+0x27f>
	else if (lflag)
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	74 63                	je     800554 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f9:	99                   	cltd   
  8004fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8d 40 04             	lea    0x4(%eax),%eax
  800503:	89 45 14             	mov    %eax,0x14(%ebp)
  800506:	eb 17                	jmp    80051f <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8b 50 04             	mov    0x4(%eax),%edx
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800513:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 40 08             	lea    0x8(%eax),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80051f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800522:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800525:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80052a:	85 c9                	test   %ecx,%ecx
  80052c:	0f 89 ff 00 00 00    	jns    800631 <vprintfmt+0x3a8>
				putch('-', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	6a 2d                	push   $0x2d
  800538:	ff d6                	call   *%esi
				num = -(long long) num;
  80053a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800540:	f7 da                	neg    %edx
  800542:	83 d1 00             	adc    $0x0,%ecx
  800545:	f7 d9                	neg    %ecx
  800547:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054a:	bf 0a 00 00 00       	mov    $0xa,%edi
  80054f:	e9 dd 00 00 00       	jmp    800631 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8b 00                	mov    (%eax),%eax
  800559:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055c:	99                   	cltd   
  80055d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 40 04             	lea    0x4(%eax),%eax
  800566:	89 45 14             	mov    %eax,0x14(%ebp)
  800569:	eb b4                	jmp    80051f <vprintfmt+0x296>
	if (lflag >= 2)
  80056b:	83 f9 01             	cmp    $0x1,%ecx
  80056e:	7f 1e                	jg     80058e <vprintfmt+0x305>
	else if (lflag)
  800570:	85 c9                	test   %ecx,%ecx
  800572:	74 32                	je     8005a6 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 10                	mov    (%eax),%edx
  800579:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057e:	8d 40 04             	lea    0x4(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800584:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800589:	e9 a3 00 00 00       	jmp    800631 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 10                	mov    (%eax),%edx
  800593:	8b 48 04             	mov    0x4(%eax),%ecx
  800596:	8d 40 08             	lea    0x8(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005a1:	e9 8b 00 00 00       	jmp    800631 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b0:	8d 40 04             	lea    0x4(%eax),%eax
  8005b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005bb:	eb 74                	jmp    800631 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005bd:	83 f9 01             	cmp    $0x1,%ecx
  8005c0:	7f 1b                	jg     8005dd <vprintfmt+0x354>
	else if (lflag)
  8005c2:	85 c9                	test   %ecx,%ecx
  8005c4:	74 2c                	je     8005f2 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 10                	mov    (%eax),%edx
  8005cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d0:	8d 40 04             	lea    0x4(%eax),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005d6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005db:	eb 54                	jmp    800631 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e5:	8d 40 08             	lea    0x8(%eax),%eax
  8005e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005eb:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005f0:	eb 3f                	jmp    800631 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 10                	mov    (%eax),%edx
  8005f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800602:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800607:	eb 28                	jmp    800631 <vprintfmt+0x3a8>
			putch('0', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 30                	push   $0x30
  80060f:	ff d6                	call   *%esi
			putch('x', putdat);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 78                	push   $0x78
  800617:	ff d6                	call   *%esi
			num = (unsigned long long)
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8b 10                	mov    (%eax),%edx
  80061e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800623:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800626:	8d 40 04             	lea    0x4(%eax),%eax
  800629:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062c:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800631:	83 ec 0c             	sub    $0xc,%esp
  800634:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	ff 75 e0             	push   -0x20(%ebp)
  80063c:	57                   	push   %edi
  80063d:	51                   	push   %ecx
  80063e:	52                   	push   %edx
  80063f:	89 da                	mov    %ebx,%edx
  800641:	89 f0                	mov    %esi,%eax
  800643:	e8 5e fb ff ff       	call   8001a6 <printnum>
			break;
  800648:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80064b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064e:	e9 54 fc ff ff       	jmp    8002a7 <vprintfmt+0x1e>
	if (lflag >= 2)
  800653:	83 f9 01             	cmp    $0x1,%ecx
  800656:	7f 1b                	jg     800673 <vprintfmt+0x3ea>
	else if (lflag)
  800658:	85 c9                	test   %ecx,%ecx
  80065a:	74 2c                	je     800688 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
  800666:	8d 40 04             	lea    0x4(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800671:	eb be                	jmp    800631 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	8b 48 04             	mov    0x4(%eax),%ecx
  80067b:	8d 40 08             	lea    0x8(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800681:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800686:	eb a9                	jmp    800631 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800698:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80069d:	eb 92                	jmp    800631 <vprintfmt+0x3a8>
			putch(ch, putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 25                	push   $0x25
  8006a5:	ff d6                	call   *%esi
			break;
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 9f                	jmp    80064b <vprintfmt+0x3c2>
			putch('%', putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 25                	push   $0x25
  8006b2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	89 f8                	mov    %edi,%eax
  8006b9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006bd:	74 05                	je     8006c4 <vprintfmt+0x43b>
  8006bf:	83 e8 01             	sub    $0x1,%eax
  8006c2:	eb f5                	jmp    8006b9 <vprintfmt+0x430>
  8006c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c7:	eb 82                	jmp    80064b <vprintfmt+0x3c2>

008006c9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	83 ec 18             	sub    $0x18,%esp
  8006cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006dc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	74 26                	je     800710 <vsnprintf+0x47>
  8006ea:	85 d2                	test   %edx,%edx
  8006ec:	7e 22                	jle    800710 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ee:	ff 75 14             	push   0x14(%ebp)
  8006f1:	ff 75 10             	push   0x10(%ebp)
  8006f4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f7:	50                   	push   %eax
  8006f8:	68 4f 02 80 00       	push   $0x80024f
  8006fd:	e8 87 fb ff ff       	call   800289 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800702:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800705:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070b:	83 c4 10             	add    $0x10,%esp
}
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    
		return -E_INVAL;
  800710:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800715:	eb f7                	jmp    80070e <vsnprintf+0x45>

00800717 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800720:	50                   	push   %eax
  800721:	ff 75 10             	push   0x10(%ebp)
  800724:	ff 75 0c             	push   0xc(%ebp)
  800727:	ff 75 08             	push   0x8(%ebp)
  80072a:	e8 9a ff ff ff       	call   8006c9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072f:	c9                   	leave  
  800730:	c3                   	ret    

00800731 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
  80073c:	eb 03                	jmp    800741 <strlen+0x10>
		n++;
  80073e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800741:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800745:	75 f7                	jne    80073e <strlen+0xd>
	return n;
}
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 03                	jmp    80075c <strnlen+0x13>
		n++;
  800759:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075c:	39 d0                	cmp    %edx,%eax
  80075e:	74 08                	je     800768 <strnlen+0x1f>
  800760:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800764:	75 f3                	jne    800759 <strnlen+0x10>
  800766:	89 c2                	mov    %eax,%edx
	return n;
}
  800768:	89 d0                	mov    %edx,%eax
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	53                   	push   %ebx
  800770:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800773:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80077f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800782:	83 c0 01             	add    $0x1,%eax
  800785:	84 d2                	test   %dl,%dl
  800787:	75 f2                	jne    80077b <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800789:	89 c8                	mov    %ecx,%eax
  80078b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	83 ec 10             	sub    $0x10,%esp
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	53                   	push   %ebx
  80079b:	e8 91 ff ff ff       	call   800731 <strlen>
  8007a0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007a3:	ff 75 0c             	push   0xc(%ebp)
  8007a6:	01 d8                	add    %ebx,%eax
  8007a8:	50                   	push   %eax
  8007a9:	e8 be ff ff ff       	call   80076c <strcpy>
	return dst;
}
  8007ae:	89 d8                	mov    %ebx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f0                	mov    %esi,%eax
  8007c7:	eb 0f                	jmp    8007d8 <strncpy+0x23>
		*dst++ = *src;
  8007c9:	83 c0 01             	add    $0x1,%eax
  8007cc:	0f b6 0a             	movzbl (%edx),%ecx
  8007cf:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d2:	80 f9 01             	cmp    $0x1,%cl
  8007d5:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007d8:	39 d8                	cmp    %ebx,%eax
  8007da:	75 ed                	jne    8007c9 <strncpy+0x14>
	}
	return ret;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	74 21                	je     800817 <strlcpy+0x35>
  8007f6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fa:	89 f2                	mov    %esi,%edx
  8007fc:	eb 09                	jmp    800807 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fe:	83 c1 01             	add    $0x1,%ecx
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800807:	39 c2                	cmp    %eax,%edx
  800809:	74 09                	je     800814 <strlcpy+0x32>
  80080b:	0f b6 19             	movzbl (%ecx),%ebx
  80080e:	84 db                	test   %bl,%bl
  800810:	75 ec                	jne    8007fe <strlcpy+0x1c>
  800812:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800814:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800817:	29 f0                	sub    %esi,%eax
}
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800826:	eb 06                	jmp    80082e <strcmp+0x11>
		p++, q++;
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	84 c0                	test   %al,%al
  800833:	74 04                	je     800839 <strcmp+0x1c>
  800835:	3a 02                	cmp    (%edx),%al
  800837:	74 ef                	je     800828 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800839:	0f b6 c0             	movzbl %al,%eax
  80083c:	0f b6 12             	movzbl (%edx),%edx
  80083f:	29 d0                	sub    %edx,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 c3                	mov    %eax,%ebx
  80084f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800852:	eb 06                	jmp    80085a <strncmp+0x17>
		n--, p++, q++;
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80085a:	39 d8                	cmp    %ebx,%eax
  80085c:	74 18                	je     800876 <strncmp+0x33>
  80085e:	0f b6 08             	movzbl (%eax),%ecx
  800861:	84 c9                	test   %cl,%cl
  800863:	74 04                	je     800869 <strncmp+0x26>
  800865:	3a 0a                	cmp    (%edx),%cl
  800867:	74 eb                	je     800854 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 00             	movzbl (%eax),%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
}
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    
		return 0;
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	eb f4                	jmp    800871 <strncmp+0x2e>

0080087d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800887:	eb 03                	jmp    80088c <strchr+0xf>
  800889:	83 c0 01             	add    $0x1,%eax
  80088c:	0f b6 10             	movzbl (%eax),%edx
  80088f:	84 d2                	test   %dl,%dl
  800891:	74 06                	je     800899 <strchr+0x1c>
		if (*s == c)
  800893:	38 ca                	cmp    %cl,%dl
  800895:	75 f2                	jne    800889 <strchr+0xc>
  800897:	eb 05                	jmp    80089e <strchr+0x21>
			return (char *) s;
	return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008aa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ad:	38 ca                	cmp    %cl,%dl
  8008af:	74 09                	je     8008ba <strfind+0x1a>
  8008b1:	84 d2                	test   %dl,%dl
  8008b3:	74 05                	je     8008ba <strfind+0x1a>
	for (; *s; s++)
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	eb f0                	jmp    8008aa <strfind+0xa>
			break;
	return (char *) s;
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	57                   	push   %edi
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c8:	85 c9                	test   %ecx,%ecx
  8008ca:	74 2f                	je     8008fb <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cc:	89 f8                	mov    %edi,%eax
  8008ce:	09 c8                	or     %ecx,%eax
  8008d0:	a8 03                	test   $0x3,%al
  8008d2:	75 21                	jne    8008f5 <memset+0x39>
		c &= 0xFF;
  8008d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d8:	89 d0                	mov    %edx,%eax
  8008da:	c1 e0 08             	shl    $0x8,%eax
  8008dd:	89 d3                	mov    %edx,%ebx
  8008df:	c1 e3 18             	shl    $0x18,%ebx
  8008e2:	89 d6                	mov    %edx,%esi
  8008e4:	c1 e6 10             	shl    $0x10,%esi
  8008e7:	09 f3                	or     %esi,%ebx
  8008e9:	09 da                	or     %ebx,%edx
  8008eb:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ed:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008f0:	fc                   	cld    
  8008f1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f3:	eb 06                	jmp    8008fb <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f8:	fc                   	cld    
  8008f9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fb:	89 f8                	mov    %edi,%eax
  8008fd:	5b                   	pop    %ebx
  8008fe:	5e                   	pop    %esi
  8008ff:	5f                   	pop    %edi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800910:	39 c6                	cmp    %eax,%esi
  800912:	73 32                	jae    800946 <memmove+0x44>
  800914:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800917:	39 c2                	cmp    %eax,%edx
  800919:	76 2b                	jbe    800946 <memmove+0x44>
		s += n;
		d += n;
  80091b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091e:	89 d6                	mov    %edx,%esi
  800920:	09 fe                	or     %edi,%esi
  800922:	09 ce                	or     %ecx,%esi
  800924:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092a:	75 0e                	jne    80093a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80092c:	83 ef 04             	sub    $0x4,%edi
  80092f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800932:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800935:	fd                   	std    
  800936:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800938:	eb 09                	jmp    800943 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80093a:	83 ef 01             	sub    $0x1,%edi
  80093d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800940:	fd                   	std    
  800941:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800943:	fc                   	cld    
  800944:	eb 1a                	jmp    800960 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800946:	89 f2                	mov    %esi,%edx
  800948:	09 c2                	or     %eax,%edx
  80094a:	09 ca                	or     %ecx,%edx
  80094c:	f6 c2 03             	test   $0x3,%dl
  80094f:	75 0a                	jne    80095b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800951:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800954:	89 c7                	mov    %eax,%edi
  800956:	fc                   	cld    
  800957:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800959:	eb 05                	jmp    800960 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80095b:	89 c7                	mov    %eax,%edi
  80095d:	fc                   	cld    
  80095e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800960:	5e                   	pop    %esi
  800961:	5f                   	pop    %edi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80096a:	ff 75 10             	push   0x10(%ebp)
  80096d:	ff 75 0c             	push   0xc(%ebp)
  800970:	ff 75 08             	push   0x8(%ebp)
  800973:	e8 8a ff ff ff       	call   800902 <memmove>
}
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
  800985:	89 c6                	mov    %eax,%esi
  800987:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098a:	eb 06                	jmp    800992 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800992:	39 f0                	cmp    %esi,%eax
  800994:	74 14                	je     8009aa <memcmp+0x30>
		if (*s1 != *s2)
  800996:	0f b6 08             	movzbl (%eax),%ecx
  800999:	0f b6 1a             	movzbl (%edx),%ebx
  80099c:	38 d9                	cmp    %bl,%cl
  80099e:	74 ec                	je     80098c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009a0:	0f b6 c1             	movzbl %cl,%eax
  8009a3:	0f b6 db             	movzbl %bl,%ebx
  8009a6:	29 d8                	sub    %ebx,%eax
  8009a8:	eb 05                	jmp    8009af <memcmp+0x35>
	}

	return 0;
  8009aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009af:	5b                   	pop    %ebx
  8009b0:	5e                   	pop    %esi
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009bc:	89 c2                	mov    %eax,%edx
  8009be:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c1:	eb 03                	jmp    8009c6 <memfind+0x13>
  8009c3:	83 c0 01             	add    $0x1,%eax
  8009c6:	39 d0                	cmp    %edx,%eax
  8009c8:	73 04                	jae    8009ce <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ca:	38 08                	cmp    %cl,(%eax)
  8009cc:	75 f5                	jne    8009c3 <memfind+0x10>
			break;
	return (void *) s;
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dc:	eb 03                	jmp    8009e1 <strtol+0x11>
		s++;
  8009de:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009e1:	0f b6 02             	movzbl (%edx),%eax
  8009e4:	3c 20                	cmp    $0x20,%al
  8009e6:	74 f6                	je     8009de <strtol+0xe>
  8009e8:	3c 09                	cmp    $0x9,%al
  8009ea:	74 f2                	je     8009de <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009ec:	3c 2b                	cmp    $0x2b,%al
  8009ee:	74 2a                	je     800a1a <strtol+0x4a>
	int neg = 0;
  8009f0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f5:	3c 2d                	cmp    $0x2d,%al
  8009f7:	74 2b                	je     800a24 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ff:	75 0f                	jne    800a10 <strtol+0x40>
  800a01:	80 3a 30             	cmpb   $0x30,(%edx)
  800a04:	74 28                	je     800a2e <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a06:	85 db                	test   %ebx,%ebx
  800a08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0d:	0f 44 d8             	cmove  %eax,%ebx
  800a10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a15:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a18:	eb 46                	jmp    800a60 <strtol+0x90>
		s++;
  800a1a:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a1d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a22:	eb d5                	jmp    8009f9 <strtol+0x29>
		s++, neg = 1;
  800a24:	83 c2 01             	add    $0x1,%edx
  800a27:	bf 01 00 00 00       	mov    $0x1,%edi
  800a2c:	eb cb                	jmp    8009f9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a32:	74 0e                	je     800a42 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a34:	85 db                	test   %ebx,%ebx
  800a36:	75 d8                	jne    800a10 <strtol+0x40>
		s++, base = 8;
  800a38:	83 c2 01             	add    $0x1,%edx
  800a3b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a40:	eb ce                	jmp    800a10 <strtol+0x40>
		s += 2, base = 16;
  800a42:	83 c2 02             	add    $0x2,%edx
  800a45:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4a:	eb c4                	jmp    800a10 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a4c:	0f be c0             	movsbl %al,%eax
  800a4f:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a52:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a55:	7d 3a                	jge    800a91 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a57:	83 c2 01             	add    $0x1,%edx
  800a5a:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a5e:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a60:	0f b6 02             	movzbl (%edx),%eax
  800a63:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 09             	cmp    $0x9,%bl
  800a6b:	76 df                	jbe    800a4c <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a6d:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a70:	89 f3                	mov    %esi,%ebx
  800a72:	80 fb 19             	cmp    $0x19,%bl
  800a75:	77 08                	ja     800a7f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a77:	0f be c0             	movsbl %al,%eax
  800a7a:	83 e8 57             	sub    $0x57,%eax
  800a7d:	eb d3                	jmp    800a52 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a7f:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a82:	89 f3                	mov    %esi,%ebx
  800a84:	80 fb 19             	cmp    $0x19,%bl
  800a87:	77 08                	ja     800a91 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a89:	0f be c0             	movsbl %al,%eax
  800a8c:	83 e8 37             	sub    $0x37,%eax
  800a8f:	eb c1                	jmp    800a52 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a95:	74 05                	je     800a9c <strtol+0xcc>
		*endptr = (char *) s;
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a9c:	89 c8                	mov    %ecx,%eax
  800a9e:	f7 d8                	neg    %eax
  800aa0:	85 ff                	test   %edi,%edi
  800aa2:	0f 45 c8             	cmovne %eax,%ecx
}
  800aa5:	89 c8                	mov    %ecx,%eax
  800aa7:	5b                   	pop    %ebx
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abd:	89 c3                	mov    %eax,%ebx
  800abf:	89 c7                	mov    %eax,%edi
  800ac1:	89 c6                	mov    %eax,%esi
  800ac3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <sys_cgetc>:

int
sys_cgetc(void)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	57                   	push   %edi
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad5:	b8 01 00 00 00       	mov    $0x1,%eax
  800ada:	89 d1                	mov    %edx,%ecx
  800adc:	89 d3                	mov    %edx,%ebx
  800ade:	89 d7                	mov    %edx,%edi
  800ae0:	89 d6                	mov    %edx,%esi
  800ae2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	57                   	push   %edi
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800af2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af7:	8b 55 08             	mov    0x8(%ebp),%edx
  800afa:	b8 03 00 00 00       	mov    $0x3,%eax
  800aff:	89 cb                	mov    %ecx,%ebx
  800b01:	89 cf                	mov    %ecx,%edi
  800b03:	89 ce                	mov    %ecx,%esi
  800b05:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b07:	85 c0                	test   %eax,%eax
  800b09:	7f 08                	jg     800b13 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b13:	83 ec 0c             	sub    $0xc,%esp
  800b16:	50                   	push   %eax
  800b17:	6a 03                	push   $0x3
  800b19:	68 1f 26 80 00       	push   $0x80261f
  800b1e:	6a 2a                	push   $0x2a
  800b20:	68 3c 26 80 00       	push   $0x80263c
  800b25:	e8 9e 13 00 00       	call   801ec8 <_panic>

00800b2a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b30:	ba 00 00 00 00       	mov    $0x0,%edx
  800b35:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3a:	89 d1                	mov    %edx,%ecx
  800b3c:	89 d3                	mov    %edx,%ebx
  800b3e:	89 d7                	mov    %edx,%edi
  800b40:	89 d6                	mov    %edx,%esi
  800b42:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_yield>:

void
sys_yield(void)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b54:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b59:	89 d1                	mov    %edx,%ecx
  800b5b:	89 d3                	mov    %edx,%ebx
  800b5d:	89 d7                	mov    %edx,%edi
  800b5f:	89 d6                	mov    %edx,%esi
  800b61:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b71:	be 00 00 00 00       	mov    $0x0,%esi
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b84:	89 f7                	mov    %esi,%edi
  800b86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b88:	85 c0                	test   %eax,%eax
  800b8a:	7f 08                	jg     800b94 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b94:	83 ec 0c             	sub    $0xc,%esp
  800b97:	50                   	push   %eax
  800b98:	6a 04                	push   $0x4
  800b9a:	68 1f 26 80 00       	push   $0x80261f
  800b9f:	6a 2a                	push   $0x2a
  800ba1:	68 3c 26 80 00       	push   $0x80263c
  800ba6:	e8 1d 13 00 00       	call   801ec8 <_panic>

00800bab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc5:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	7f 08                	jg     800bd6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd6:	83 ec 0c             	sub    $0xc,%esp
  800bd9:	50                   	push   %eax
  800bda:	6a 05                	push   $0x5
  800bdc:	68 1f 26 80 00       	push   $0x80261f
  800be1:	6a 2a                	push   $0x2a
  800be3:	68 3c 26 80 00       	push   $0x80263c
  800be8:	e8 db 12 00 00       	call   801ec8 <_panic>

00800bed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	b8 06 00 00 00       	mov    $0x6,%eax
  800c06:	89 df                	mov    %ebx,%edi
  800c08:	89 de                	mov    %ebx,%esi
  800c0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7f 08                	jg     800c18 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	50                   	push   %eax
  800c1c:	6a 06                	push   $0x6
  800c1e:	68 1f 26 80 00       	push   $0x80261f
  800c23:	6a 2a                	push   $0x2a
  800c25:	68 3c 26 80 00       	push   $0x80263c
  800c2a:	e8 99 12 00 00       	call   801ec8 <_panic>

00800c2f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	b8 08 00 00 00       	mov    $0x8,%eax
  800c48:	89 df                	mov    %ebx,%edi
  800c4a:	89 de                	mov    %ebx,%esi
  800c4c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	7f 08                	jg     800c5a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	83 ec 0c             	sub    $0xc,%esp
  800c5d:	50                   	push   %eax
  800c5e:	6a 08                	push   $0x8
  800c60:	68 1f 26 80 00       	push   $0x80261f
  800c65:	6a 2a                	push   $0x2a
  800c67:	68 3c 26 80 00       	push   $0x80263c
  800c6c:	e8 57 12 00 00       	call   801ec8 <_panic>

00800c71 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8a:	89 df                	mov    %ebx,%edi
  800c8c:	89 de                	mov    %ebx,%esi
  800c8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c90:	85 c0                	test   %eax,%eax
  800c92:	7f 08                	jg     800c9c <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 09                	push   $0x9
  800ca2:	68 1f 26 80 00       	push   $0x80261f
  800ca7:	6a 2a                	push   $0x2a
  800ca9:	68 3c 26 80 00       	push   $0x80263c
  800cae:	e8 15 12 00 00       	call   801ec8 <_panic>

00800cb3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ccc:	89 df                	mov    %ebx,%edi
  800cce:	89 de                	mov    %ebx,%esi
  800cd0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	7f 08                	jg     800cde <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	6a 0a                	push   $0xa
  800ce4:	68 1f 26 80 00       	push   $0x80261f
  800ce9:	6a 2a                	push   $0x2a
  800ceb:	68 3c 26 80 00       	push   $0x80263c
  800cf0:	e8 d3 11 00 00       	call   801ec8 <_panic>

00800cf5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d06:	be 00 00 00 00       	mov    $0x0,%esi
  800d0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d11:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2e:	89 cb                	mov    %ecx,%ebx
  800d30:	89 cf                	mov    %ecx,%edi
  800d32:	89 ce                	mov    %ecx,%esi
  800d34:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7f 08                	jg     800d42 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	83 ec 0c             	sub    $0xc,%esp
  800d45:	50                   	push   %eax
  800d46:	6a 0d                	push   $0xd
  800d48:	68 1f 26 80 00       	push   $0x80261f
  800d4d:	6a 2a                	push   $0x2a
  800d4f:	68 3c 26 80 00       	push   $0x80263c
  800d54:	e8 6f 11 00 00       	call   801ec8 <_panic>

00800d59 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d64:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d69:	89 d1                	mov    %edx,%ecx
  800d6b:	89 d3                	mov    %edx,%ebx
  800d6d:	89 d7                	mov    %edx,%edi
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d8e:	89 df                	mov    %ebx,%edi
  800d90:	89 de                	mov    %ebx,%esi
  800d92:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	b8 10 00 00 00       	mov    $0x10,%eax
  800daf:	89 df                	mov    %ebx,%edi
  800db1:	89 de                	mov    %ebx,%esi
  800db3:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc0:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc5:	c1 e8 0c             	shr    $0xc,%eax
}
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd0:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800dd5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dda:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800de9:	89 c2                	mov    %eax,%edx
  800deb:	c1 ea 16             	shr    $0x16,%edx
  800dee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df5:	f6 c2 01             	test   $0x1,%dl
  800df8:	74 29                	je     800e23 <fd_alloc+0x42>
  800dfa:	89 c2                	mov    %eax,%edx
  800dfc:	c1 ea 0c             	shr    $0xc,%edx
  800dff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e06:	f6 c2 01             	test   $0x1,%dl
  800e09:	74 18                	je     800e23 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e0b:	05 00 10 00 00       	add    $0x1000,%eax
  800e10:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e15:	75 d2                	jne    800de9 <fd_alloc+0x8>
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800e1c:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800e21:	eb 05                	jmp    800e28 <fd_alloc+0x47>
			return 0;
  800e23:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 02                	mov    %eax,(%edx)
}
  800e2d:	89 c8                	mov    %ecx,%eax
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e37:	83 f8 1f             	cmp    $0x1f,%eax
  800e3a:	77 30                	ja     800e6c <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e3c:	c1 e0 0c             	shl    $0xc,%eax
  800e3f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e44:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e4a:	f6 c2 01             	test   $0x1,%dl
  800e4d:	74 24                	je     800e73 <fd_lookup+0x42>
  800e4f:	89 c2                	mov    %eax,%edx
  800e51:	c1 ea 0c             	shr    $0xc,%edx
  800e54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5b:	f6 c2 01             	test   $0x1,%dl
  800e5e:	74 1a                	je     800e7a <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e60:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e63:	89 02                	mov    %eax,(%edx)
	return 0;
  800e65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    
		return -E_INVAL;
  800e6c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e71:	eb f7                	jmp    800e6a <fd_lookup+0x39>
		return -E_INVAL;
  800e73:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e78:	eb f0                	jmp    800e6a <fd_lookup+0x39>
  800e7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e7f:	eb e9                	jmp    800e6a <fd_lookup+0x39>

00800e81 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	53                   	push   %ebx
  800e85:	83 ec 04             	sub    $0x4,%esp
  800e88:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e95:	39 13                	cmp    %edx,(%ebx)
  800e97:	74 37                	je     800ed0 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800e99:	83 c0 01             	add    $0x1,%eax
  800e9c:	8b 1c 85 c8 26 80 00 	mov    0x8026c8(,%eax,4),%ebx
  800ea3:	85 db                	test   %ebx,%ebx
  800ea5:	75 ee                	jne    800e95 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ea7:	a1 00 40 80 00       	mov    0x804000,%eax
  800eac:	8b 40 58             	mov    0x58(%eax),%eax
  800eaf:	83 ec 04             	sub    $0x4,%esp
  800eb2:	52                   	push   %edx
  800eb3:	50                   	push   %eax
  800eb4:	68 4c 26 80 00       	push   $0x80264c
  800eb9:	e8 d4 f2 ff ff       	call   800192 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800ec6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec9:	89 1a                	mov    %ebx,(%edx)
}
  800ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    
			return 0;
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed5:	eb ef                	jmp    800ec6 <dev_lookup+0x45>

00800ed7 <fd_close>:
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	83 ec 24             	sub    $0x24,%esp
  800ee0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ee3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ee6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ee9:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eea:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ef0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef3:	50                   	push   %eax
  800ef4:	e8 38 ff ff ff       	call   800e31 <fd_lookup>
  800ef9:	89 c3                	mov    %eax,%ebx
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	78 05                	js     800f07 <fd_close+0x30>
	    || fd != fd2)
  800f02:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f05:	74 16                	je     800f1d <fd_close+0x46>
		return (must_exist ? r : 0);
  800f07:	89 f8                	mov    %edi,%eax
  800f09:	84 c0                	test   %al,%al
  800f0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f10:	0f 44 d8             	cmove  %eax,%ebx
}
  800f13:	89 d8                	mov    %ebx,%eax
  800f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f1d:	83 ec 08             	sub    $0x8,%esp
  800f20:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f23:	50                   	push   %eax
  800f24:	ff 36                	push   (%esi)
  800f26:	e8 56 ff ff ff       	call   800e81 <dev_lookup>
  800f2b:	89 c3                	mov    %eax,%ebx
  800f2d:	83 c4 10             	add    $0x10,%esp
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 1a                	js     800f4e <fd_close+0x77>
		if (dev->dev_close)
  800f34:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f37:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f3a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	74 0b                	je     800f4e <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f43:	83 ec 0c             	sub    $0xc,%esp
  800f46:	56                   	push   %esi
  800f47:	ff d0                	call   *%eax
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f4e:	83 ec 08             	sub    $0x8,%esp
  800f51:	56                   	push   %esi
  800f52:	6a 00                	push   $0x0
  800f54:	e8 94 fc ff ff       	call   800bed <sys_page_unmap>
	return r;
  800f59:	83 c4 10             	add    $0x10,%esp
  800f5c:	eb b5                	jmp    800f13 <fd_close+0x3c>

00800f5e <close>:

int
close(int fdnum)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f67:	50                   	push   %eax
  800f68:	ff 75 08             	push   0x8(%ebp)
  800f6b:	e8 c1 fe ff ff       	call   800e31 <fd_lookup>
  800f70:	83 c4 10             	add    $0x10,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	79 02                	jns    800f79 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f77:	c9                   	leave  
  800f78:	c3                   	ret    
		return fd_close(fd, 1);
  800f79:	83 ec 08             	sub    $0x8,%esp
  800f7c:	6a 01                	push   $0x1
  800f7e:	ff 75 f4             	push   -0xc(%ebp)
  800f81:	e8 51 ff ff ff       	call   800ed7 <fd_close>
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	eb ec                	jmp    800f77 <close+0x19>

00800f8b <close_all>:

void
close_all(void)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f92:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f97:	83 ec 0c             	sub    $0xc,%esp
  800f9a:	53                   	push   %ebx
  800f9b:	e8 be ff ff ff       	call   800f5e <close>
	for (i = 0; i < MAXFD; i++)
  800fa0:	83 c3 01             	add    $0x1,%ebx
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	83 fb 20             	cmp    $0x20,%ebx
  800fa9:	75 ec                	jne    800f97 <close_all+0xc>
}
  800fab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fb9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	ff 75 08             	push   0x8(%ebp)
  800fc0:	e8 6c fe ff ff       	call   800e31 <fd_lookup>
  800fc5:	89 c3                	mov    %eax,%ebx
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	78 7f                	js     80104d <dup+0x9d>
		return r;
	close(newfdnum);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	ff 75 0c             	push   0xc(%ebp)
  800fd4:	e8 85 ff ff ff       	call   800f5e <close>

	newfd = INDEX2FD(newfdnum);
  800fd9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fdc:	c1 e6 0c             	shl    $0xc,%esi
  800fdf:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fe5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fe8:	89 3c 24             	mov    %edi,(%esp)
  800feb:	e8 da fd ff ff       	call   800dca <fd2data>
  800ff0:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800ff2:	89 34 24             	mov    %esi,(%esp)
  800ff5:	e8 d0 fd ff ff       	call   800dca <fd2data>
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801000:	89 d8                	mov    %ebx,%eax
  801002:	c1 e8 16             	shr    $0x16,%eax
  801005:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100c:	a8 01                	test   $0x1,%al
  80100e:	74 11                	je     801021 <dup+0x71>
  801010:	89 d8                	mov    %ebx,%eax
  801012:	c1 e8 0c             	shr    $0xc,%eax
  801015:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101c:	f6 c2 01             	test   $0x1,%dl
  80101f:	75 36                	jne    801057 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801021:	89 f8                	mov    %edi,%eax
  801023:	c1 e8 0c             	shr    $0xc,%eax
  801026:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	25 07 0e 00 00       	and    $0xe07,%eax
  801035:	50                   	push   %eax
  801036:	56                   	push   %esi
  801037:	6a 00                	push   $0x0
  801039:	57                   	push   %edi
  80103a:	6a 00                	push   $0x0
  80103c:	e8 6a fb ff ff       	call   800bab <sys_page_map>
  801041:	89 c3                	mov    %eax,%ebx
  801043:	83 c4 20             	add    $0x20,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 33                	js     80107d <dup+0xcd>
		goto err;

	return newfdnum;
  80104a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80104d:	89 d8                	mov    %ebx,%eax
  80104f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801057:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	25 07 0e 00 00       	and    $0xe07,%eax
  801066:	50                   	push   %eax
  801067:	ff 75 d4             	push   -0x2c(%ebp)
  80106a:	6a 00                	push   $0x0
  80106c:	53                   	push   %ebx
  80106d:	6a 00                	push   $0x0
  80106f:	e8 37 fb ff ff       	call   800bab <sys_page_map>
  801074:	89 c3                	mov    %eax,%ebx
  801076:	83 c4 20             	add    $0x20,%esp
  801079:	85 c0                	test   %eax,%eax
  80107b:	79 a4                	jns    801021 <dup+0x71>
	sys_page_unmap(0, newfd);
  80107d:	83 ec 08             	sub    $0x8,%esp
  801080:	56                   	push   %esi
  801081:	6a 00                	push   $0x0
  801083:	e8 65 fb ff ff       	call   800bed <sys_page_unmap>
	sys_page_unmap(0, nva);
  801088:	83 c4 08             	add    $0x8,%esp
  80108b:	ff 75 d4             	push   -0x2c(%ebp)
  80108e:	6a 00                	push   $0x0
  801090:	e8 58 fb ff ff       	call   800bed <sys_page_unmap>
	return r;
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	eb b3                	jmp    80104d <dup+0x9d>

0080109a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	56                   	push   %esi
  80109e:	53                   	push   %ebx
  80109f:	83 ec 18             	sub    $0x18,%esp
  8010a2:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a8:	50                   	push   %eax
  8010a9:	56                   	push   %esi
  8010aa:	e8 82 fd ff ff       	call   800e31 <fd_lookup>
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	78 3c                	js     8010f2 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b6:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8010b9:	83 ec 08             	sub    $0x8,%esp
  8010bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010bf:	50                   	push   %eax
  8010c0:	ff 33                	push   (%ebx)
  8010c2:	e8 ba fd ff ff       	call   800e81 <dev_lookup>
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	78 24                	js     8010f2 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010ce:	8b 43 08             	mov    0x8(%ebx),%eax
  8010d1:	83 e0 03             	and    $0x3,%eax
  8010d4:	83 f8 01             	cmp    $0x1,%eax
  8010d7:	74 20                	je     8010f9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010dc:	8b 40 08             	mov    0x8(%eax),%eax
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	74 37                	je     80111a <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010e3:	83 ec 04             	sub    $0x4,%esp
  8010e6:	ff 75 10             	push   0x10(%ebp)
  8010e9:	ff 75 0c             	push   0xc(%ebp)
  8010ec:	53                   	push   %ebx
  8010ed:	ff d0                	call   *%eax
  8010ef:	83 c4 10             	add    $0x10,%esp
}
  8010f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f5:	5b                   	pop    %ebx
  8010f6:	5e                   	pop    %esi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f9:	a1 00 40 80 00       	mov    0x804000,%eax
  8010fe:	8b 40 58             	mov    0x58(%eax),%eax
  801101:	83 ec 04             	sub    $0x4,%esp
  801104:	56                   	push   %esi
  801105:	50                   	push   %eax
  801106:	68 8d 26 80 00       	push   $0x80268d
  80110b:	e8 82 f0 ff ff       	call   800192 <cprintf>
		return -E_INVAL;
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801118:	eb d8                	jmp    8010f2 <read+0x58>
		return -E_NOT_SUPP;
  80111a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80111f:	eb d1                	jmp    8010f2 <read+0x58>

00801121 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	57                   	push   %edi
  801125:	56                   	push   %esi
  801126:	53                   	push   %ebx
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80112d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801130:	bb 00 00 00 00       	mov    $0x0,%ebx
  801135:	eb 02                	jmp    801139 <readn+0x18>
  801137:	01 c3                	add    %eax,%ebx
  801139:	39 f3                	cmp    %esi,%ebx
  80113b:	73 21                	jae    80115e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80113d:	83 ec 04             	sub    $0x4,%esp
  801140:	89 f0                	mov    %esi,%eax
  801142:	29 d8                	sub    %ebx,%eax
  801144:	50                   	push   %eax
  801145:	89 d8                	mov    %ebx,%eax
  801147:	03 45 0c             	add    0xc(%ebp),%eax
  80114a:	50                   	push   %eax
  80114b:	57                   	push   %edi
  80114c:	e8 49 ff ff ff       	call   80109a <read>
		if (m < 0)
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	78 04                	js     80115c <readn+0x3b>
			return m;
		if (m == 0)
  801158:	75 dd                	jne    801137 <readn+0x16>
  80115a:	eb 02                	jmp    80115e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80115c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80115e:	89 d8                	mov    %ebx,%eax
  801160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 18             	sub    $0x18,%esp
  801170:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801173:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	53                   	push   %ebx
  801178:	e8 b4 fc ff ff       	call   800e31 <fd_lookup>
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	85 c0                	test   %eax,%eax
  801182:	78 37                	js     8011bb <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801184:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	ff 36                	push   (%esi)
  801190:	e8 ec fc ff ff       	call   800e81 <dev_lookup>
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 1f                	js     8011bb <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80119c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011a0:	74 20                	je     8011c2 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	74 37                	je     8011e3 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ac:	83 ec 04             	sub    $0x4,%esp
  8011af:	ff 75 10             	push   0x10(%ebp)
  8011b2:	ff 75 0c             	push   0xc(%ebp)
  8011b5:	56                   	push   %esi
  8011b6:	ff d0                	call   *%eax
  8011b8:	83 c4 10             	add    $0x10,%esp
}
  8011bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011be:	5b                   	pop    %ebx
  8011bf:	5e                   	pop    %esi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c2:	a1 00 40 80 00       	mov    0x804000,%eax
  8011c7:	8b 40 58             	mov    0x58(%eax),%eax
  8011ca:	83 ec 04             	sub    $0x4,%esp
  8011cd:	53                   	push   %ebx
  8011ce:	50                   	push   %eax
  8011cf:	68 a9 26 80 00       	push   $0x8026a9
  8011d4:	e8 b9 ef ff ff       	call   800192 <cprintf>
		return -E_INVAL;
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e1:	eb d8                	jmp    8011bb <write+0x53>
		return -E_NOT_SUPP;
  8011e3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011e8:	eb d1                	jmp    8011bb <write+0x53>

008011ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f3:	50                   	push   %eax
  8011f4:	ff 75 08             	push   0x8(%ebp)
  8011f7:	e8 35 fc ff ff       	call   800e31 <fd_lookup>
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 0e                	js     801211 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801203:	8b 55 0c             	mov    0xc(%ebp),%edx
  801206:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801209:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	56                   	push   %esi
  801217:	53                   	push   %ebx
  801218:	83 ec 18             	sub    $0x18,%esp
  80121b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	53                   	push   %ebx
  801223:	e8 09 fc ff ff       	call   800e31 <fd_lookup>
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 34                	js     801263 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801232:	83 ec 08             	sub    $0x8,%esp
  801235:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801238:	50                   	push   %eax
  801239:	ff 36                	push   (%esi)
  80123b:	e8 41 fc ff ff       	call   800e81 <dev_lookup>
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 1c                	js     801263 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801247:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80124b:	74 1d                	je     80126a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80124d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801250:	8b 40 18             	mov    0x18(%eax),%eax
  801253:	85 c0                	test   %eax,%eax
  801255:	74 34                	je     80128b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	ff 75 0c             	push   0xc(%ebp)
  80125d:	56                   	push   %esi
  80125e:	ff d0                	call   *%eax
  801260:	83 c4 10             	add    $0x10,%esp
}
  801263:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801266:	5b                   	pop    %ebx
  801267:	5e                   	pop    %esi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    
			thisenv->env_id, fdnum);
  80126a:	a1 00 40 80 00       	mov    0x804000,%eax
  80126f:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	53                   	push   %ebx
  801276:	50                   	push   %eax
  801277:	68 6c 26 80 00       	push   $0x80266c
  80127c:	e8 11 ef ff ff       	call   800192 <cprintf>
		return -E_INVAL;
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801289:	eb d8                	jmp    801263 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80128b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801290:	eb d1                	jmp    801263 <ftruncate+0x50>

00801292 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	56                   	push   %esi
  801296:	53                   	push   %ebx
  801297:	83 ec 18             	sub    $0x18,%esp
  80129a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a0:	50                   	push   %eax
  8012a1:	ff 75 08             	push   0x8(%ebp)
  8012a4:	e8 88 fb ff ff       	call   800e31 <fd_lookup>
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 49                	js     8012f9 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012b3:	83 ec 08             	sub    $0x8,%esp
  8012b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b9:	50                   	push   %eax
  8012ba:	ff 36                	push   (%esi)
  8012bc:	e8 c0 fb ff ff       	call   800e81 <dev_lookup>
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 31                	js     8012f9 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8012c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012cb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012cf:	74 2f                	je     801300 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012d1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012d4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012db:	00 00 00 
	stat->st_isdir = 0;
  8012de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012e5:	00 00 00 
	stat->st_dev = dev;
  8012e8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	53                   	push   %ebx
  8012f2:	56                   	push   %esi
  8012f3:	ff 50 14             	call   *0x14(%eax)
  8012f6:	83 c4 10             	add    $0x10,%esp
}
  8012f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fc:	5b                   	pop    %ebx
  8012fd:	5e                   	pop    %esi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    
		return -E_NOT_SUPP;
  801300:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801305:	eb f2                	jmp    8012f9 <fstat+0x67>

00801307 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	56                   	push   %esi
  80130b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	6a 00                	push   $0x0
  801311:	ff 75 08             	push   0x8(%ebp)
  801314:	e8 e4 01 00 00       	call   8014fd <open>
  801319:	89 c3                	mov    %eax,%ebx
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 1b                	js     80133d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801322:	83 ec 08             	sub    $0x8,%esp
  801325:	ff 75 0c             	push   0xc(%ebp)
  801328:	50                   	push   %eax
  801329:	e8 64 ff ff ff       	call   801292 <fstat>
  80132e:	89 c6                	mov    %eax,%esi
	close(fd);
  801330:	89 1c 24             	mov    %ebx,(%esp)
  801333:	e8 26 fc ff ff       	call   800f5e <close>
	return r;
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	89 f3                	mov    %esi,%ebx
}
  80133d:	89 d8                	mov    %ebx,%eax
  80133f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	56                   	push   %esi
  80134a:	53                   	push   %ebx
  80134b:	89 c6                	mov    %eax,%esi
  80134d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80134f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801356:	74 27                	je     80137f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801358:	6a 07                	push   $0x7
  80135a:	68 00 50 80 00       	push   $0x805000
  80135f:	56                   	push   %esi
  801360:	ff 35 00 60 80 00    	push   0x806000
  801366:	e8 13 0c 00 00       	call   801f7e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80136b:	83 c4 0c             	add    $0xc,%esp
  80136e:	6a 00                	push   $0x0
  801370:	53                   	push   %ebx
  801371:	6a 00                	push   $0x0
  801373:	e8 96 0b 00 00       	call   801f0e <ipc_recv>
}
  801378:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80137f:	83 ec 0c             	sub    $0xc,%esp
  801382:	6a 01                	push   $0x1
  801384:	e8 49 0c 00 00       	call   801fd2 <ipc_find_env>
  801389:	a3 00 60 80 00       	mov    %eax,0x806000
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	eb c5                	jmp    801358 <fsipc+0x12>

00801393 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801399:	8b 45 08             	mov    0x8(%ebp),%eax
  80139c:	8b 40 0c             	mov    0xc(%eax),%eax
  80139f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b1:	b8 02 00 00 00       	mov    $0x2,%eax
  8013b6:	e8 8b ff ff ff       	call   801346 <fsipc>
}
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <devfile_flush>:
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d3:	b8 06 00 00 00       	mov    $0x6,%eax
  8013d8:	e8 69 ff ff ff       	call   801346 <fsipc>
}
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <devfile_stat>:
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 04             	sub    $0x4,%esp
  8013e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ef:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013fe:	e8 43 ff ff ff       	call   801346 <fsipc>
  801403:	85 c0                	test   %eax,%eax
  801405:	78 2c                	js     801433 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	68 00 50 80 00       	push   $0x805000
  80140f:	53                   	push   %ebx
  801410:	e8 57 f3 ff ff       	call   80076c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801415:	a1 80 50 80 00       	mov    0x805080,%eax
  80141a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801420:	a1 84 50 80 00       	mov    0x805084,%eax
  801425:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801433:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <devfile_write>:
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 0c             	sub    $0xc,%esp
  80143e:	8b 45 10             	mov    0x10(%ebp),%eax
  801441:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801446:	39 d0                	cmp    %edx,%eax
  801448:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80144b:	8b 55 08             	mov    0x8(%ebp),%edx
  80144e:	8b 52 0c             	mov    0xc(%edx),%edx
  801451:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801457:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80145c:	50                   	push   %eax
  80145d:	ff 75 0c             	push   0xc(%ebp)
  801460:	68 08 50 80 00       	push   $0x805008
  801465:	e8 98 f4 ff ff       	call   800902 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80146a:	ba 00 00 00 00       	mov    $0x0,%edx
  80146f:	b8 04 00 00 00       	mov    $0x4,%eax
  801474:	e8 cd fe ff ff       	call   801346 <fsipc>
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <devfile_read>:
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	56                   	push   %esi
  80147f:	53                   	push   %ebx
  801480:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	8b 40 0c             	mov    0xc(%eax),%eax
  801489:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80148e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801494:	ba 00 00 00 00       	mov    $0x0,%edx
  801499:	b8 03 00 00 00       	mov    $0x3,%eax
  80149e:	e8 a3 fe ff ff       	call   801346 <fsipc>
  8014a3:	89 c3                	mov    %eax,%ebx
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 1f                	js     8014c8 <devfile_read+0x4d>
	assert(r <= n);
  8014a9:	39 f0                	cmp    %esi,%eax
  8014ab:	77 24                	ja     8014d1 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8014ad:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014b2:	7f 33                	jg     8014e7 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	50                   	push   %eax
  8014b8:	68 00 50 80 00       	push   $0x805000
  8014bd:	ff 75 0c             	push   0xc(%ebp)
  8014c0:	e8 3d f4 ff ff       	call   800902 <memmove>
	return r;
  8014c5:	83 c4 10             	add    $0x10,%esp
}
  8014c8:	89 d8                	mov    %ebx,%eax
  8014ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cd:	5b                   	pop    %ebx
  8014ce:	5e                   	pop    %esi
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    
	assert(r <= n);
  8014d1:	68 dc 26 80 00       	push   $0x8026dc
  8014d6:	68 e3 26 80 00       	push   $0x8026e3
  8014db:	6a 7c                	push   $0x7c
  8014dd:	68 f8 26 80 00       	push   $0x8026f8
  8014e2:	e8 e1 09 00 00       	call   801ec8 <_panic>
	assert(r <= PGSIZE);
  8014e7:	68 03 27 80 00       	push   $0x802703
  8014ec:	68 e3 26 80 00       	push   $0x8026e3
  8014f1:	6a 7d                	push   $0x7d
  8014f3:	68 f8 26 80 00       	push   $0x8026f8
  8014f8:	e8 cb 09 00 00       	call   801ec8 <_panic>

008014fd <open>:
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	56                   	push   %esi
  801501:	53                   	push   %ebx
  801502:	83 ec 1c             	sub    $0x1c,%esp
  801505:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801508:	56                   	push   %esi
  801509:	e8 23 f2 ff ff       	call   800731 <strlen>
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801516:	7f 6c                	jg     801584 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	e8 bd f8 ff ff       	call   800de1 <fd_alloc>
  801524:	89 c3                	mov    %eax,%ebx
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 3c                	js     801569 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80152d:	83 ec 08             	sub    $0x8,%esp
  801530:	56                   	push   %esi
  801531:	68 00 50 80 00       	push   $0x805000
  801536:	e8 31 f2 ff ff       	call   80076c <strcpy>
	fsipcbuf.open.req_omode = mode;
  80153b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801543:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801546:	b8 01 00 00 00       	mov    $0x1,%eax
  80154b:	e8 f6 fd ff ff       	call   801346 <fsipc>
  801550:	89 c3                	mov    %eax,%ebx
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 19                	js     801572 <open+0x75>
	return fd2num(fd);
  801559:	83 ec 0c             	sub    $0xc,%esp
  80155c:	ff 75 f4             	push   -0xc(%ebp)
  80155f:	e8 56 f8 ff ff       	call   800dba <fd2num>
  801564:	89 c3                	mov    %eax,%ebx
  801566:	83 c4 10             	add    $0x10,%esp
}
  801569:	89 d8                	mov    %ebx,%eax
  80156b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5d                   	pop    %ebp
  801571:	c3                   	ret    
		fd_close(fd, 0);
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	6a 00                	push   $0x0
  801577:	ff 75 f4             	push   -0xc(%ebp)
  80157a:	e8 58 f9 ff ff       	call   800ed7 <fd_close>
		return r;
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	eb e5                	jmp    801569 <open+0x6c>
		return -E_BAD_PATH;
  801584:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801589:	eb de                	jmp    801569 <open+0x6c>

0080158b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801591:	ba 00 00 00 00       	mov    $0x0,%edx
  801596:	b8 08 00 00 00       	mov    $0x8,%eax
  80159b:	e8 a6 fd ff ff       	call   801346 <fsipc>
}
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015a8:	68 0f 27 80 00       	push   $0x80270f
  8015ad:	ff 75 0c             	push   0xc(%ebp)
  8015b0:	e8 b7 f1 ff ff       	call   80076c <strcpy>
	return 0;
}
  8015b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <devsock_close>:
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 10             	sub    $0x10,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015c6:	53                   	push   %ebx
  8015c7:	e8 45 0a 00 00       	call   802011 <pageref>
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	83 c4 10             	add    $0x10,%esp
		return 0;
  8015d1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8015d6:	83 fa 01             	cmp    $0x1,%edx
  8015d9:	74 05                	je     8015e0 <devsock_close+0x24>
}
  8015db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015de:	c9                   	leave  
  8015df:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	ff 73 0c             	push   0xc(%ebx)
  8015e6:	e8 b7 02 00 00       	call   8018a2 <nsipc_close>
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	eb eb                	jmp    8015db <devsock_close+0x1f>

008015f0 <devsock_write>:
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015f6:	6a 00                	push   $0x0
  8015f8:	ff 75 10             	push   0x10(%ebp)
  8015fb:	ff 75 0c             	push   0xc(%ebp)
  8015fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801601:	ff 70 0c             	push   0xc(%eax)
  801604:	e8 79 03 00 00       	call   801982 <nsipc_send>
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <devsock_read>:
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801611:	6a 00                	push   $0x0
  801613:	ff 75 10             	push   0x10(%ebp)
  801616:	ff 75 0c             	push   0xc(%ebp)
  801619:	8b 45 08             	mov    0x8(%ebp),%eax
  80161c:	ff 70 0c             	push   0xc(%eax)
  80161f:	e8 ef 02 00 00       	call   801913 <nsipc_recv>
}
  801624:	c9                   	leave  
  801625:	c3                   	ret    

00801626 <fd2sockid>:
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80162c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80162f:	52                   	push   %edx
  801630:	50                   	push   %eax
  801631:	e8 fb f7 ff ff       	call   800e31 <fd_lookup>
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 10                	js     80164d <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801640:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801646:	39 08                	cmp    %ecx,(%eax)
  801648:	75 05                	jne    80164f <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80164a:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    
		return -E_NOT_SUPP;
  80164f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801654:	eb f7                	jmp    80164d <fd2sockid+0x27>

00801656 <alloc_sockfd>:
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	56                   	push   %esi
  80165a:	53                   	push   %ebx
  80165b:	83 ec 1c             	sub    $0x1c,%esp
  80165e:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	e8 78 f7 ff ff       	call   800de1 <fd_alloc>
  801669:	89 c3                	mov    %eax,%ebx
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 43                	js     8016b5 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801672:	83 ec 04             	sub    $0x4,%esp
  801675:	68 07 04 00 00       	push   $0x407
  80167a:	ff 75 f4             	push   -0xc(%ebp)
  80167d:	6a 00                	push   $0x0
  80167f:	e8 e4 f4 ff ff       	call   800b68 <sys_page_alloc>
  801684:	89 c3                	mov    %eax,%ebx
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 28                	js     8016b5 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80168d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801690:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801696:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016a2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	50                   	push   %eax
  8016a9:	e8 0c f7 ff ff       	call   800dba <fd2num>
  8016ae:	89 c3                	mov    %eax,%ebx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	eb 0c                	jmp    8016c1 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8016b5:	83 ec 0c             	sub    $0xc,%esp
  8016b8:	56                   	push   %esi
  8016b9:	e8 e4 01 00 00       	call   8018a2 <nsipc_close>
		return r;
  8016be:	83 c4 10             	add    $0x10,%esp
}
  8016c1:	89 d8                	mov    %ebx,%eax
  8016c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <accept>:
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	e8 4e ff ff ff       	call   801626 <fd2sockid>
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 1b                	js     8016f7 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016dc:	83 ec 04             	sub    $0x4,%esp
  8016df:	ff 75 10             	push   0x10(%ebp)
  8016e2:	ff 75 0c             	push   0xc(%ebp)
  8016e5:	50                   	push   %eax
  8016e6:	e8 0e 01 00 00       	call   8017f9 <nsipc_accept>
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 05                	js     8016f7 <accept+0x2d>
	return alloc_sockfd(r);
  8016f2:	e8 5f ff ff ff       	call   801656 <alloc_sockfd>
}
  8016f7:	c9                   	leave  
  8016f8:	c3                   	ret    

008016f9 <bind>:
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	e8 1f ff ff ff       	call   801626 <fd2sockid>
  801707:	85 c0                	test   %eax,%eax
  801709:	78 12                	js     80171d <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80170b:	83 ec 04             	sub    $0x4,%esp
  80170e:	ff 75 10             	push   0x10(%ebp)
  801711:	ff 75 0c             	push   0xc(%ebp)
  801714:	50                   	push   %eax
  801715:	e8 31 01 00 00       	call   80184b <nsipc_bind>
  80171a:	83 c4 10             	add    $0x10,%esp
}
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <shutdown>:
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801725:	8b 45 08             	mov    0x8(%ebp),%eax
  801728:	e8 f9 fe ff ff       	call   801626 <fd2sockid>
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 0f                	js     801740 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	ff 75 0c             	push   0xc(%ebp)
  801737:	50                   	push   %eax
  801738:	e8 43 01 00 00       	call   801880 <nsipc_shutdown>
  80173d:	83 c4 10             	add    $0x10,%esp
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <connect>:
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801748:	8b 45 08             	mov    0x8(%ebp),%eax
  80174b:	e8 d6 fe ff ff       	call   801626 <fd2sockid>
  801750:	85 c0                	test   %eax,%eax
  801752:	78 12                	js     801766 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801754:	83 ec 04             	sub    $0x4,%esp
  801757:	ff 75 10             	push   0x10(%ebp)
  80175a:	ff 75 0c             	push   0xc(%ebp)
  80175d:	50                   	push   %eax
  80175e:	e8 59 01 00 00       	call   8018bc <nsipc_connect>
  801763:	83 c4 10             	add    $0x10,%esp
}
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <listen>:
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80176e:	8b 45 08             	mov    0x8(%ebp),%eax
  801771:	e8 b0 fe ff ff       	call   801626 <fd2sockid>
  801776:	85 c0                	test   %eax,%eax
  801778:	78 0f                	js     801789 <listen+0x21>
	return nsipc_listen(r, backlog);
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	ff 75 0c             	push   0xc(%ebp)
  801780:	50                   	push   %eax
  801781:	e8 6b 01 00 00       	call   8018f1 <nsipc_listen>
  801786:	83 c4 10             	add    $0x10,%esp
}
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <socket>:

int
socket(int domain, int type, int protocol)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801791:	ff 75 10             	push   0x10(%ebp)
  801794:	ff 75 0c             	push   0xc(%ebp)
  801797:	ff 75 08             	push   0x8(%ebp)
  80179a:	e8 41 02 00 00       	call   8019e0 <nsipc_socket>
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 05                	js     8017ab <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017a6:	e8 ab fe ff ff       	call   801656 <alloc_sockfd>
}
  8017ab:	c9                   	leave  
  8017ac:	c3                   	ret    

008017ad <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	53                   	push   %ebx
  8017b1:	83 ec 04             	sub    $0x4,%esp
  8017b4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017b6:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8017bd:	74 26                	je     8017e5 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017bf:	6a 07                	push   $0x7
  8017c1:	68 00 70 80 00       	push   $0x807000
  8017c6:	53                   	push   %ebx
  8017c7:	ff 35 00 80 80 00    	push   0x808000
  8017cd:	e8 ac 07 00 00       	call   801f7e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017d2:	83 c4 0c             	add    $0xc,%esp
  8017d5:	6a 00                	push   $0x0
  8017d7:	6a 00                	push   $0x0
  8017d9:	6a 00                	push   $0x0
  8017db:	e8 2e 07 00 00       	call   801f0e <ipc_recv>
}
  8017e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e3:	c9                   	leave  
  8017e4:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017e5:	83 ec 0c             	sub    $0xc,%esp
  8017e8:	6a 02                	push   $0x2
  8017ea:	e8 e3 07 00 00       	call   801fd2 <ipc_find_env>
  8017ef:	a3 00 80 80 00       	mov    %eax,0x808000
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	eb c6                	jmp    8017bf <nsipc+0x12>

008017f9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	56                   	push   %esi
  8017fd:	53                   	push   %ebx
  8017fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801809:	8b 06                	mov    (%esi),%eax
  80180b:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801810:	b8 01 00 00 00       	mov    $0x1,%eax
  801815:	e8 93 ff ff ff       	call   8017ad <nsipc>
  80181a:	89 c3                	mov    %eax,%ebx
  80181c:	85 c0                	test   %eax,%eax
  80181e:	79 09                	jns    801829 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801820:	89 d8                	mov    %ebx,%eax
  801822:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801825:	5b                   	pop    %ebx
  801826:	5e                   	pop    %esi
  801827:	5d                   	pop    %ebp
  801828:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801829:	83 ec 04             	sub    $0x4,%esp
  80182c:	ff 35 10 70 80 00    	push   0x807010
  801832:	68 00 70 80 00       	push   $0x807000
  801837:	ff 75 0c             	push   0xc(%ebp)
  80183a:	e8 c3 f0 ff ff       	call   800902 <memmove>
		*addrlen = ret->ret_addrlen;
  80183f:	a1 10 70 80 00       	mov    0x807010,%eax
  801844:	89 06                	mov    %eax,(%esi)
  801846:	83 c4 10             	add    $0x10,%esp
	return r;
  801849:	eb d5                	jmp    801820 <nsipc_accept+0x27>

0080184b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80185d:	53                   	push   %ebx
  80185e:	ff 75 0c             	push   0xc(%ebp)
  801861:	68 04 70 80 00       	push   $0x807004
  801866:	e8 97 f0 ff ff       	call   800902 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80186b:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801871:	b8 02 00 00 00       	mov    $0x2,%eax
  801876:	e8 32 ff ff ff       	call   8017ad <nsipc>
}
  80187b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801886:	8b 45 08             	mov    0x8(%ebp),%eax
  801889:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80188e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801891:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801896:	b8 03 00 00 00       	mov    $0x3,%eax
  80189b:	e8 0d ff ff ff       	call   8017ad <nsipc>
}
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <nsipc_close>:

int
nsipc_close(int s)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ab:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8018b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b5:	e8 f3 fe ff ff       	call   8017ad <nsipc>
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018ce:	53                   	push   %ebx
  8018cf:	ff 75 0c             	push   0xc(%ebp)
  8018d2:	68 04 70 80 00       	push   $0x807004
  8018d7:	e8 26 f0 ff ff       	call   800902 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018dc:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8018e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e7:	e8 c1 fe ff ff       	call   8017ad <nsipc>
}
  8018ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8018ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801902:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801907:	b8 06 00 00 00       	mov    $0x6,%eax
  80190c:	e8 9c fe ff ff       	call   8017ad <nsipc>
}
  801911:	c9                   	leave  
  801912:	c3                   	ret    

00801913 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	56                   	push   %esi
  801917:	53                   	push   %ebx
  801918:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80191b:	8b 45 08             	mov    0x8(%ebp),%eax
  80191e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801923:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801929:	8b 45 14             	mov    0x14(%ebp),%eax
  80192c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801931:	b8 07 00 00 00       	mov    $0x7,%eax
  801936:	e8 72 fe ff ff       	call   8017ad <nsipc>
  80193b:	89 c3                	mov    %eax,%ebx
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 22                	js     801963 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801941:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801946:	39 c6                	cmp    %eax,%esi
  801948:	0f 4e c6             	cmovle %esi,%eax
  80194b:	39 c3                	cmp    %eax,%ebx
  80194d:	7f 1d                	jg     80196c <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80194f:	83 ec 04             	sub    $0x4,%esp
  801952:	53                   	push   %ebx
  801953:	68 00 70 80 00       	push   $0x807000
  801958:	ff 75 0c             	push   0xc(%ebp)
  80195b:	e8 a2 ef ff ff       	call   800902 <memmove>
  801960:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801963:	89 d8                	mov    %ebx,%eax
  801965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80196c:	68 1b 27 80 00       	push   $0x80271b
  801971:	68 e3 26 80 00       	push   $0x8026e3
  801976:	6a 62                	push   $0x62
  801978:	68 30 27 80 00       	push   $0x802730
  80197d:	e8 46 05 00 00       	call   801ec8 <_panic>

00801982 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	53                   	push   %ebx
  801986:	83 ec 04             	sub    $0x4,%esp
  801989:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80198c:	8b 45 08             	mov    0x8(%ebp),%eax
  80198f:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801994:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80199a:	7f 2e                	jg     8019ca <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80199c:	83 ec 04             	sub    $0x4,%esp
  80199f:	53                   	push   %ebx
  8019a0:	ff 75 0c             	push   0xc(%ebp)
  8019a3:	68 0c 70 80 00       	push   $0x80700c
  8019a8:	e8 55 ef ff ff       	call   800902 <memmove>
	nsipcbuf.send.req_size = size;
  8019ad:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8019b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b6:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8019bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c0:	e8 e8 fd ff ff       	call   8017ad <nsipc>
}
  8019c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    
	assert(size < 1600);
  8019ca:	68 3c 27 80 00       	push   $0x80273c
  8019cf:	68 e3 26 80 00       	push   $0x8026e3
  8019d4:	6a 6d                	push   $0x6d
  8019d6:	68 30 27 80 00       	push   $0x802730
  8019db:	e8 e8 04 00 00       	call   801ec8 <_panic>

008019e0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8019ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f1:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8019f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8019fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801a03:	e8 a5 fd ff ff       	call   8017ad <nsipc>
}
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	56                   	push   %esi
  801a0e:	53                   	push   %ebx
  801a0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	ff 75 08             	push   0x8(%ebp)
  801a18:	e8 ad f3 ff ff       	call   800dca <fd2data>
  801a1d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a1f:	83 c4 08             	add    $0x8,%esp
  801a22:	68 48 27 80 00       	push   $0x802748
  801a27:	53                   	push   %ebx
  801a28:	e8 3f ed ff ff       	call   80076c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a2d:	8b 46 04             	mov    0x4(%esi),%eax
  801a30:	2b 06                	sub    (%esi),%eax
  801a32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a38:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a3f:	00 00 00 
	stat->st_dev = &devpipe;
  801a42:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a49:	30 80 00 
	return 0;
}
  801a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	53                   	push   %ebx
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a62:	53                   	push   %ebx
  801a63:	6a 00                	push   $0x0
  801a65:	e8 83 f1 ff ff       	call   800bed <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a6a:	89 1c 24             	mov    %ebx,(%esp)
  801a6d:	e8 58 f3 ff ff       	call   800dca <fd2data>
  801a72:	83 c4 08             	add    $0x8,%esp
  801a75:	50                   	push   %eax
  801a76:	6a 00                	push   $0x0
  801a78:	e8 70 f1 ff ff       	call   800bed <sys_page_unmap>
}
  801a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <_pipeisclosed>:
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	57                   	push   %edi
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	83 ec 1c             	sub    $0x1c,%esp
  801a8b:	89 c7                	mov    %eax,%edi
  801a8d:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a8f:	a1 00 40 80 00       	mov    0x804000,%eax
  801a94:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	57                   	push   %edi
  801a9b:	e8 71 05 00 00       	call   802011 <pageref>
  801aa0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801aa3:	89 34 24             	mov    %esi,(%esp)
  801aa6:	e8 66 05 00 00       	call   802011 <pageref>
		nn = thisenv->env_runs;
  801aab:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ab1:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	39 cb                	cmp    %ecx,%ebx
  801ab9:	74 1b                	je     801ad6 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801abb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801abe:	75 cf                	jne    801a8f <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ac0:	8b 42 68             	mov    0x68(%edx),%eax
  801ac3:	6a 01                	push   $0x1
  801ac5:	50                   	push   %eax
  801ac6:	53                   	push   %ebx
  801ac7:	68 4f 27 80 00       	push   $0x80274f
  801acc:	e8 c1 e6 ff ff       	call   800192 <cprintf>
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	eb b9                	jmp    801a8f <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ad6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ad9:	0f 94 c0             	sete   %al
  801adc:	0f b6 c0             	movzbl %al,%eax
}
  801adf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5f                   	pop    %edi
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <devpipe_write>:
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	57                   	push   %edi
  801aeb:	56                   	push   %esi
  801aec:	53                   	push   %ebx
  801aed:	83 ec 28             	sub    $0x28,%esp
  801af0:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801af3:	56                   	push   %esi
  801af4:	e8 d1 f2 ff ff       	call   800dca <fd2data>
  801af9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	bf 00 00 00 00       	mov    $0x0,%edi
  801b03:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b06:	75 09                	jne    801b11 <devpipe_write+0x2a>
	return i;
  801b08:	89 f8                	mov    %edi,%eax
  801b0a:	eb 23                	jmp    801b2f <devpipe_write+0x48>
			sys_yield();
  801b0c:	e8 38 f0 ff ff       	call   800b49 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b11:	8b 43 04             	mov    0x4(%ebx),%eax
  801b14:	8b 0b                	mov    (%ebx),%ecx
  801b16:	8d 51 20             	lea    0x20(%ecx),%edx
  801b19:	39 d0                	cmp    %edx,%eax
  801b1b:	72 1a                	jb     801b37 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801b1d:	89 da                	mov    %ebx,%edx
  801b1f:	89 f0                	mov    %esi,%eax
  801b21:	e8 5c ff ff ff       	call   801a82 <_pipeisclosed>
  801b26:	85 c0                	test   %eax,%eax
  801b28:	74 e2                	je     801b0c <devpipe_write+0x25>
				return 0;
  801b2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b32:	5b                   	pop    %ebx
  801b33:	5e                   	pop    %esi
  801b34:	5f                   	pop    %edi
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b3e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b41:	89 c2                	mov    %eax,%edx
  801b43:	c1 fa 1f             	sar    $0x1f,%edx
  801b46:	89 d1                	mov    %edx,%ecx
  801b48:	c1 e9 1b             	shr    $0x1b,%ecx
  801b4b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b4e:	83 e2 1f             	and    $0x1f,%edx
  801b51:	29 ca                	sub    %ecx,%edx
  801b53:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b57:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b5b:	83 c0 01             	add    $0x1,%eax
  801b5e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b61:	83 c7 01             	add    $0x1,%edi
  801b64:	eb 9d                	jmp    801b03 <devpipe_write+0x1c>

00801b66 <devpipe_read>:
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	57                   	push   %edi
  801b6a:	56                   	push   %esi
  801b6b:	53                   	push   %ebx
  801b6c:	83 ec 18             	sub    $0x18,%esp
  801b6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b72:	57                   	push   %edi
  801b73:	e8 52 f2 ff ff       	call   800dca <fd2data>
  801b78:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	be 00 00 00 00       	mov    $0x0,%esi
  801b82:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b85:	75 13                	jne    801b9a <devpipe_read+0x34>
	return i;
  801b87:	89 f0                	mov    %esi,%eax
  801b89:	eb 02                	jmp    801b8d <devpipe_read+0x27>
				return i;
  801b8b:	89 f0                	mov    %esi,%eax
}
  801b8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b90:	5b                   	pop    %ebx
  801b91:	5e                   	pop    %esi
  801b92:	5f                   	pop    %edi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    
			sys_yield();
  801b95:	e8 af ef ff ff       	call   800b49 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b9a:	8b 03                	mov    (%ebx),%eax
  801b9c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b9f:	75 18                	jne    801bb9 <devpipe_read+0x53>
			if (i > 0)
  801ba1:	85 f6                	test   %esi,%esi
  801ba3:	75 e6                	jne    801b8b <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801ba5:	89 da                	mov    %ebx,%edx
  801ba7:	89 f8                	mov    %edi,%eax
  801ba9:	e8 d4 fe ff ff       	call   801a82 <_pipeisclosed>
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	74 e3                	je     801b95 <devpipe_read+0x2f>
				return 0;
  801bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb7:	eb d4                	jmp    801b8d <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bb9:	99                   	cltd   
  801bba:	c1 ea 1b             	shr    $0x1b,%edx
  801bbd:	01 d0                	add    %edx,%eax
  801bbf:	83 e0 1f             	and    $0x1f,%eax
  801bc2:	29 d0                	sub    %edx,%eax
  801bc4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcc:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bcf:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801bd2:	83 c6 01             	add    $0x1,%esi
  801bd5:	eb ab                	jmp    801b82 <devpipe_read+0x1c>

00801bd7 <pipe>:
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	56                   	push   %esi
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be2:	50                   	push   %eax
  801be3:	e8 f9 f1 ff ff       	call   800de1 <fd_alloc>
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	0f 88 23 01 00 00    	js     801d18 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf5:	83 ec 04             	sub    $0x4,%esp
  801bf8:	68 07 04 00 00       	push   $0x407
  801bfd:	ff 75 f4             	push   -0xc(%ebp)
  801c00:	6a 00                	push   $0x0
  801c02:	e8 61 ef ff ff       	call   800b68 <sys_page_alloc>
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 88 04 01 00 00    	js     801d18 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1a:	50                   	push   %eax
  801c1b:	e8 c1 f1 ff ff       	call   800de1 <fd_alloc>
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	83 c4 10             	add    $0x10,%esp
  801c25:	85 c0                	test   %eax,%eax
  801c27:	0f 88 db 00 00 00    	js     801d08 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2d:	83 ec 04             	sub    $0x4,%esp
  801c30:	68 07 04 00 00       	push   $0x407
  801c35:	ff 75 f0             	push   -0x10(%ebp)
  801c38:	6a 00                	push   $0x0
  801c3a:	e8 29 ef ff ff       	call   800b68 <sys_page_alloc>
  801c3f:	89 c3                	mov    %eax,%ebx
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	85 c0                	test   %eax,%eax
  801c46:	0f 88 bc 00 00 00    	js     801d08 <pipe+0x131>
	va = fd2data(fd0);
  801c4c:	83 ec 0c             	sub    $0xc,%esp
  801c4f:	ff 75 f4             	push   -0xc(%ebp)
  801c52:	e8 73 f1 ff ff       	call   800dca <fd2data>
  801c57:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c59:	83 c4 0c             	add    $0xc,%esp
  801c5c:	68 07 04 00 00       	push   $0x407
  801c61:	50                   	push   %eax
  801c62:	6a 00                	push   $0x0
  801c64:	e8 ff ee ff ff       	call   800b68 <sys_page_alloc>
  801c69:	89 c3                	mov    %eax,%ebx
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	0f 88 82 00 00 00    	js     801cf8 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c76:	83 ec 0c             	sub    $0xc,%esp
  801c79:	ff 75 f0             	push   -0x10(%ebp)
  801c7c:	e8 49 f1 ff ff       	call   800dca <fd2data>
  801c81:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c88:	50                   	push   %eax
  801c89:	6a 00                	push   $0x0
  801c8b:	56                   	push   %esi
  801c8c:	6a 00                	push   $0x0
  801c8e:	e8 18 ef ff ff       	call   800bab <sys_page_map>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 20             	add    $0x20,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 4e                	js     801cea <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c9c:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801ca1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca4:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ca6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca9:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801cb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cb3:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	ff 75 f4             	push   -0xc(%ebp)
  801cc5:	e8 f0 f0 ff ff       	call   800dba <fd2num>
  801cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ccf:	83 c4 04             	add    $0x4,%esp
  801cd2:	ff 75 f0             	push   -0x10(%ebp)
  801cd5:	e8 e0 f0 ff ff       	call   800dba <fd2num>
  801cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce8:	eb 2e                	jmp    801d18 <pipe+0x141>
	sys_page_unmap(0, va);
  801cea:	83 ec 08             	sub    $0x8,%esp
  801ced:	56                   	push   %esi
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 f8 ee ff ff       	call   800bed <sys_page_unmap>
  801cf5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cf8:	83 ec 08             	sub    $0x8,%esp
  801cfb:	ff 75 f0             	push   -0x10(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 e8 ee ff ff       	call   800bed <sys_page_unmap>
  801d05:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	ff 75 f4             	push   -0xc(%ebp)
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 d8 ee ff ff       	call   800bed <sys_page_unmap>
  801d15:	83 c4 10             	add    $0x10,%esp
}
  801d18:	89 d8                	mov    %ebx,%eax
  801d1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <pipeisclosed>:
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2a:	50                   	push   %eax
  801d2b:	ff 75 08             	push   0x8(%ebp)
  801d2e:	e8 fe f0 ff ff       	call   800e31 <fd_lookup>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	78 18                	js     801d52 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d3a:	83 ec 0c             	sub    $0xc,%esp
  801d3d:	ff 75 f4             	push   -0xc(%ebp)
  801d40:	e8 85 f0 ff ff       	call   800dca <fd2data>
  801d45:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4a:	e8 33 fd ff ff       	call   801a82 <_pipeisclosed>
  801d4f:	83 c4 10             	add    $0x10,%esp
}
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    

00801d54 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d54:	b8 00 00 00 00       	mov    $0x0,%eax
  801d59:	c3                   	ret    

00801d5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d60:	68 67 27 80 00       	push   $0x802767
  801d65:	ff 75 0c             	push   0xc(%ebp)
  801d68:	e8 ff e9 ff ff       	call   80076c <strcpy>
	return 0;
}
  801d6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <devcons_write>:
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	57                   	push   %edi
  801d78:	56                   	push   %esi
  801d79:	53                   	push   %ebx
  801d7a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d80:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d85:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d8b:	eb 2e                	jmp    801dbb <devcons_write+0x47>
		m = n - tot;
  801d8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d90:	29 f3                	sub    %esi,%ebx
  801d92:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d97:	39 c3                	cmp    %eax,%ebx
  801d99:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d9c:	83 ec 04             	sub    $0x4,%esp
  801d9f:	53                   	push   %ebx
  801da0:	89 f0                	mov    %esi,%eax
  801da2:	03 45 0c             	add    0xc(%ebp),%eax
  801da5:	50                   	push   %eax
  801da6:	57                   	push   %edi
  801da7:	e8 56 eb ff ff       	call   800902 <memmove>
		sys_cputs(buf, m);
  801dac:	83 c4 08             	add    $0x8,%esp
  801daf:	53                   	push   %ebx
  801db0:	57                   	push   %edi
  801db1:	e8 f6 ec ff ff       	call   800aac <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801db6:	01 de                	add    %ebx,%esi
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dbe:	72 cd                	jb     801d8d <devcons_write+0x19>
}
  801dc0:	89 f0                	mov    %esi,%eax
  801dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    

00801dca <devcons_read>:
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 08             	sub    $0x8,%esp
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801dd5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd9:	75 07                	jne    801de2 <devcons_read+0x18>
  801ddb:	eb 1f                	jmp    801dfc <devcons_read+0x32>
		sys_yield();
  801ddd:	e8 67 ed ff ff       	call   800b49 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801de2:	e8 e3 ec ff ff       	call   800aca <sys_cgetc>
  801de7:	85 c0                	test   %eax,%eax
  801de9:	74 f2                	je     801ddd <devcons_read+0x13>
	if (c < 0)
  801deb:	78 0f                	js     801dfc <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801ded:	83 f8 04             	cmp    $0x4,%eax
  801df0:	74 0c                	je     801dfe <devcons_read+0x34>
	*(char*)vbuf = c;
  801df2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df5:	88 02                	mov    %al,(%edx)
	return 1;
  801df7:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dfc:	c9                   	leave  
  801dfd:	c3                   	ret    
		return 0;
  801dfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801e03:	eb f7                	jmp    801dfc <devcons_read+0x32>

00801e05 <cputchar>:
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e11:	6a 01                	push   $0x1
  801e13:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e16:	50                   	push   %eax
  801e17:	e8 90 ec ff ff       	call   800aac <sys_cputs>
}
  801e1c:	83 c4 10             	add    $0x10,%esp
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    

00801e21 <getchar>:
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e27:	6a 01                	push   $0x1
  801e29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2c:	50                   	push   %eax
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 66 f2 ff ff       	call   80109a <read>
	if (r < 0)
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 06                	js     801e41 <getchar+0x20>
	if (r < 1)
  801e3b:	74 06                	je     801e43 <getchar+0x22>
	return c;
  801e3d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    
		return -E_EOF;
  801e43:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e48:	eb f7                	jmp    801e41 <getchar+0x20>

00801e4a <iscons>:
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e53:	50                   	push   %eax
  801e54:	ff 75 08             	push   0x8(%ebp)
  801e57:	e8 d5 ef ff ff       	call   800e31 <fd_lookup>
  801e5c:	83 c4 10             	add    $0x10,%esp
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	78 11                	js     801e74 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e66:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e6c:	39 10                	cmp    %edx,(%eax)
  801e6e:	0f 94 c0             	sete   %al
  801e71:	0f b6 c0             	movzbl %al,%eax
}
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <opencons>:
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7f:	50                   	push   %eax
  801e80:	e8 5c ef ff ff       	call   800de1 <fd_alloc>
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	78 3a                	js     801ec6 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e8c:	83 ec 04             	sub    $0x4,%esp
  801e8f:	68 07 04 00 00       	push   $0x407
  801e94:	ff 75 f4             	push   -0xc(%ebp)
  801e97:	6a 00                	push   $0x0
  801e99:	e8 ca ec ff ff       	call   800b68 <sys_page_alloc>
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	78 21                	js     801ec6 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eae:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eba:	83 ec 0c             	sub    $0xc,%esp
  801ebd:	50                   	push   %eax
  801ebe:	e8 f7 ee ff ff       	call   800dba <fd2num>
  801ec3:	83 c4 10             	add    $0x10,%esp
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	56                   	push   %esi
  801ecc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ecd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ed0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ed6:	e8 4f ec ff ff       	call   800b2a <sys_getenvid>
  801edb:	83 ec 0c             	sub    $0xc,%esp
  801ede:	ff 75 0c             	push   0xc(%ebp)
  801ee1:	ff 75 08             	push   0x8(%ebp)
  801ee4:	56                   	push   %esi
  801ee5:	50                   	push   %eax
  801ee6:	68 74 27 80 00       	push   $0x802774
  801eeb:	e8 a2 e2 ff ff       	call   800192 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ef0:	83 c4 18             	add    $0x18,%esp
  801ef3:	53                   	push   %ebx
  801ef4:	ff 75 10             	push   0x10(%ebp)
  801ef7:	e8 45 e2 ff ff       	call   800141 <vcprintf>
	cprintf("\n");
  801efc:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  801f03:	e8 8a e2 ff ff       	call   800192 <cprintf>
  801f08:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f0b:	cc                   	int3   
  801f0c:	eb fd                	jmp    801f0b <_panic+0x43>

00801f0e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	8b 75 08             	mov    0x8(%ebp),%esi
  801f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f23:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f26:	83 ec 0c             	sub    $0xc,%esp
  801f29:	50                   	push   %eax
  801f2a:	e8 e9 ed ff ff       	call   800d18 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 f6                	test   %esi,%esi
  801f34:	74 17                	je     801f4d <ipc_recv+0x3f>
  801f36:	ba 00 00 00 00       	mov    $0x0,%edx
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	78 0c                	js     801f4b <ipc_recv+0x3d>
  801f3f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f45:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f4b:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f4d:	85 db                	test   %ebx,%ebx
  801f4f:	74 17                	je     801f68 <ipc_recv+0x5a>
  801f51:	ba 00 00 00 00       	mov    $0x0,%edx
  801f56:	85 c0                	test   %eax,%eax
  801f58:	78 0c                	js     801f66 <ipc_recv+0x58>
  801f5a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f60:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f66:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	78 0b                	js     801f77 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f6c:	a1 00 40 80 00       	mov    0x804000,%eax
  801f71:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 0c             	sub    $0xc,%esp
  801f87:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f90:	85 db                	test   %ebx,%ebx
  801f92:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f97:	0f 44 d8             	cmove  %eax,%ebx
  801f9a:	eb 05                	jmp    801fa1 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f9c:	e8 a8 eb ff ff       	call   800b49 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801fa1:	ff 75 14             	push   0x14(%ebp)
  801fa4:	53                   	push   %ebx
  801fa5:	56                   	push   %esi
  801fa6:	57                   	push   %edi
  801fa7:	e8 49 ed ff ff       	call   800cf5 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fb2:	74 e8                	je     801f9c <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	78 08                	js     801fc0 <ipc_send+0x42>
	}while (r<0);

}
  801fb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fbb:	5b                   	pop    %ebx
  801fbc:	5e                   	pop    %esi
  801fbd:	5f                   	pop    %edi
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801fc0:	50                   	push   %eax
  801fc1:	68 97 27 80 00       	push   $0x802797
  801fc6:	6a 3d                	push   $0x3d
  801fc8:	68 ab 27 80 00       	push   $0x8027ab
  801fcd:	e8 f6 fe ff ff       	call   801ec8 <_panic>

00801fd2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fd8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fdd:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801fe3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe9:	8b 52 60             	mov    0x60(%edx),%edx
  801fec:	39 ca                	cmp    %ecx,%edx
  801fee:	74 11                	je     802001 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801ff0:	83 c0 01             	add    $0x1,%eax
  801ff3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ff8:	75 e3                	jne    801fdd <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ffa:	b8 00 00 00 00       	mov    $0x0,%eax
  801fff:	eb 0e                	jmp    80200f <ipc_find_env+0x3d>
			return envs[i].env_id;
  802001:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802007:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80200c:	8b 40 58             	mov    0x58(%eax),%eax
}
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802017:	89 c2                	mov    %eax,%edx
  802019:	c1 ea 16             	shr    $0x16,%edx
  80201c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802023:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802028:	f6 c1 01             	test   $0x1,%cl
  80202b:	74 1c                	je     802049 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80202d:	c1 e8 0c             	shr    $0xc,%eax
  802030:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802037:	a8 01                	test   $0x1,%al
  802039:	74 0e                	je     802049 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80203b:	c1 e8 0c             	shr    $0xc,%eax
  80203e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802045:	ef 
  802046:	0f b7 d2             	movzwl %dx,%edx
}
  802049:	89 d0                	mov    %edx,%eax
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    
  80204d:	66 90                	xchg   %ax,%ax
  80204f:	90                   	nop

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
