
obj/user/testbss.debug：     文件格式 elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 c0 22 80 00       	push   $0x8022c0
  80003e:	e8 d4 01 00 00       	call   800217 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 00 40 80 00 	cmpl   $0x0,0x804000(,%eax,4)
  800052:	00 
  800053:	75 63                	jne    8000b8 <umain+0x85>
	for (i = 0; i < ARRAYSIZE; i++)
  800055:	83 c0 01             	add    $0x1,%eax
  800058:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80005d:	75 ec                	jne    80004b <umain+0x18>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80005f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800064:	89 04 85 00 40 80 00 	mov    %eax,0x804000(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006b:	83 c0 01             	add    $0x1,%eax
  80006e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800073:	75 ef                	jne    800064 <umain+0x31>
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007a:	39 04 85 00 40 80 00 	cmp    %eax,0x804000(,%eax,4)
  800081:	75 47                	jne    8000ca <umain+0x97>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 ed                	jne    80007a <umain+0x47>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	68 08 23 80 00       	push   $0x802308
  800095:	e8 7d 01 00 00       	call   800217 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009a:	c7 05 00 50 c0 00 00 	movl   $0x0,0xc05000
  8000a1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	68 67 23 80 00       	push   $0x802367
  8000ac:	6a 1a                	push   $0x1a
  8000ae:	68 58 23 80 00       	push   $0x802358
  8000b3:	e8 84 00 00 00       	call   80013c <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b8:	50                   	push   %eax
  8000b9:	68 3b 23 80 00       	push   $0x80233b
  8000be:	6a 11                	push   $0x11
  8000c0:	68 58 23 80 00       	push   $0x802358
  8000c5:	e8 72 00 00 00       	call   80013c <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ca:	50                   	push   %eax
  8000cb:	68 e0 22 80 00       	push   $0x8022e0
  8000d0:	6a 16                	push   $0x16
  8000d2:	68 58 23 80 00       	push   $0x802358
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e7:	e8 c3 0a 00 00       	call   800baf <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 00 40 c0 00       	mov    %eax,0xc04000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 e3 0e 00 00       	call   801010 <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 37 0a 00 00       	call   800b6e <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 60 0a 00 00       	call   800baf <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	push   0xc(%ebp)
  800155:	ff 75 08             	push   0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 88 23 80 00       	push   $0x802388
  80015f:	e8 b3 00 00 00       	call   800217 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	push   0x10(%ebp)
  80016b:	e8 56 00 00 00       	call   8001c6 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 56 23 80 00 	movl   $0x802356,(%esp)
  800177:	e8 9b 00 00 00       	call   800217 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	74 09                	je     8001aa <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001aa:	83 ec 08             	sub    $0x8,%esp
  8001ad:	68 ff 00 00 00       	push   $0xff
  8001b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b5:	50                   	push   %eax
  8001b6:	e8 76 09 00 00       	call   800b31 <sys_cputs>
		b->idx = 0;
  8001bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c1:	83 c4 10             	add    $0x10,%esp
  8001c4:	eb db                	jmp    8001a1 <putch+0x1f>

008001c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d6:	00 00 00 
	b.cnt = 0;
  8001d9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e3:	ff 75 0c             	push   0xc(%ebp)
  8001e6:	ff 75 08             	push   0x8(%ebp)
  8001e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 82 01 80 00       	push   $0x800182
  8001f5:	e8 14 01 00 00       	call   80030e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fa:	83 c4 08             	add    $0x8,%esp
  8001fd:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800203:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	e8 22 09 00 00       	call   800b31 <sys_cputs>

	return b.cnt;
}
  80020f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800220:	50                   	push   %eax
  800221:	ff 75 08             	push   0x8(%ebp)
  800224:	e8 9d ff ff ff       	call   8001c6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 1c             	sub    $0x1c,%esp
  800234:	89 c7                	mov    %eax,%edi
  800236:	89 d6                	mov    %edx,%esi
  800238:	8b 45 08             	mov    0x8(%ebp),%eax
  80023b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023e:	89 d1                	mov    %edx,%ecx
  800240:	89 c2                	mov    %eax,%edx
  800242:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800245:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800248:	8b 45 10             	mov    0x10(%ebp),%eax
  80024b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800251:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800258:	39 c2                	cmp    %eax,%edx
  80025a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80025d:	72 3e                	jb     80029d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025f:	83 ec 0c             	sub    $0xc,%esp
  800262:	ff 75 18             	push   0x18(%ebp)
  800265:	83 eb 01             	sub    $0x1,%ebx
  800268:	53                   	push   %ebx
  800269:	50                   	push   %eax
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	ff 75 e4             	push   -0x1c(%ebp)
  800270:	ff 75 e0             	push   -0x20(%ebp)
  800273:	ff 75 dc             	push   -0x24(%ebp)
  800276:	ff 75 d8             	push   -0x28(%ebp)
  800279:	e8 02 1e 00 00       	call   802080 <__udivdi3>
  80027e:	83 c4 18             	add    $0x18,%esp
  800281:	52                   	push   %edx
  800282:	50                   	push   %eax
  800283:	89 f2                	mov    %esi,%edx
  800285:	89 f8                	mov    %edi,%eax
  800287:	e8 9f ff ff ff       	call   80022b <printnum>
  80028c:	83 c4 20             	add    $0x20,%esp
  80028f:	eb 13                	jmp    8002a4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	56                   	push   %esi
  800295:	ff 75 18             	push   0x18(%ebp)
  800298:	ff d7                	call   *%edi
  80029a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80029d:	83 eb 01             	sub    $0x1,%ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f ed                	jg     800291 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	83 ec 04             	sub    $0x4,%esp
  8002ab:	ff 75 e4             	push   -0x1c(%ebp)
  8002ae:	ff 75 e0             	push   -0x20(%ebp)
  8002b1:	ff 75 dc             	push   -0x24(%ebp)
  8002b4:	ff 75 d8             	push   -0x28(%ebp)
  8002b7:	e8 e4 1e 00 00       	call   8021a0 <__umoddi3>
  8002bc:	83 c4 14             	add    $0x14,%esp
  8002bf:	0f be 80 ab 23 80 00 	movsbl 0x8023ab(%eax),%eax
  8002c6:	50                   	push   %eax
  8002c7:	ff d7                	call   *%edi
}
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002da:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e3:	73 0a                	jae    8002ef <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ed:	88 02                	mov    %al,(%edx)
}
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <printfmt>:
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 10             	push   0x10(%ebp)
  8002fe:	ff 75 0c             	push   0xc(%ebp)
  800301:	ff 75 08             	push   0x8(%ebp)
  800304:	e8 05 00 00 00       	call   80030e <vprintfmt>
}
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <vprintfmt>:
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 3c             	sub    $0x3c,%esp
  800317:	8b 75 08             	mov    0x8(%ebp),%esi
  80031a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800320:	eb 0a                	jmp    80032c <vprintfmt+0x1e>
			putch(ch, putdat);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	53                   	push   %ebx
  800326:	50                   	push   %eax
  800327:	ff d6                	call   *%esi
  800329:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032c:	83 c7 01             	add    $0x1,%edi
  80032f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800333:	83 f8 25             	cmp    $0x25,%eax
  800336:	74 0c                	je     800344 <vprintfmt+0x36>
			if (ch == '\0')
  800338:	85 c0                	test   %eax,%eax
  80033a:	75 e6                	jne    800322 <vprintfmt+0x14>
}
  80033c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    
		padc = ' ';
  800344:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800348:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80034f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800356:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8d 47 01             	lea    0x1(%edi),%eax
  800365:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800368:	0f b6 17             	movzbl (%edi),%edx
  80036b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80036e:	3c 55                	cmp    $0x55,%al
  800370:	0f 87 bb 03 00 00    	ja     800731 <vprintfmt+0x423>
  800376:	0f b6 c0             	movzbl %al,%eax
  800379:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800383:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800387:	eb d9                	jmp    800362 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800390:	eb d0                	jmp    800362 <vprintfmt+0x54>
  800392:	0f b6 d2             	movzbl %dl,%edx
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800398:	b8 00 00 00 00       	mov    $0x0,%eax
  80039d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003aa:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ad:	83 f9 09             	cmp    $0x9,%ecx
  8003b0:	77 55                	ja     800407 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003b2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b5:	eb e9                	jmp    8003a0 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8d 40 04             	lea    0x4(%eax),%eax
  8003c5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cf:	79 91                	jns    800362 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003de:	eb 82                	jmp    800362 <vprintfmt+0x54>
  8003e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003e3:	85 d2                	test   %edx,%edx
  8003e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ea:	0f 49 c2             	cmovns %edx,%eax
  8003ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f3:	e9 6a ff ff ff       	jmp    800362 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003fb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800402:	e9 5b ff ff ff       	jmp    800362 <vprintfmt+0x54>
  800407:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80040a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040d:	eb bc                	jmp    8003cb <vprintfmt+0xbd>
			lflag++;
  80040f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800415:	e9 48 ff ff ff       	jmp    800362 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 78 04             	lea    0x4(%eax),%edi
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	53                   	push   %ebx
  800424:	ff 30                	push   (%eax)
  800426:	ff d6                	call   *%esi
			break;
  800428:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80042b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80042e:	e9 9d 02 00 00       	jmp    8006d0 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 78 04             	lea    0x4(%eax),%edi
  800439:	8b 10                	mov    (%eax),%edx
  80043b:	89 d0                	mov    %edx,%eax
  80043d:	f7 d8                	neg    %eax
  80043f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800442:	83 f8 0f             	cmp    $0xf,%eax
  800445:	7f 23                	jg     80046a <vprintfmt+0x15c>
  800447:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	74 18                	je     80046a <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800452:	52                   	push   %edx
  800453:	68 75 27 80 00       	push   $0x802775
  800458:	53                   	push   %ebx
  800459:	56                   	push   %esi
  80045a:	e8 92 fe ff ff       	call   8002f1 <printfmt>
  80045f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800462:	89 7d 14             	mov    %edi,0x14(%ebp)
  800465:	e9 66 02 00 00       	jmp    8006d0 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 c3 23 80 00       	push   $0x8023c3
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 7a fe ff ff       	call   8002f1 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 4e 02 00 00       	jmp    8006d0 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	83 c0 04             	add    $0x4,%eax
  800488:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800490:	85 d2                	test   %edx,%edx
  800492:	b8 bc 23 80 00       	mov    $0x8023bc,%eax
  800497:	0f 45 c2             	cmovne %edx,%eax
  80049a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80049d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a1:	7e 06                	jle    8004a9 <vprintfmt+0x19b>
  8004a3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004a7:	75 0d                	jne    8004b6 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ac:	89 c7                	mov    %eax,%edi
  8004ae:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	eb 55                	jmp    80050b <vprintfmt+0x1fd>
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	ff 75 d8             	push   -0x28(%ebp)
  8004bc:	ff 75 cc             	push   -0x34(%ebp)
  8004bf:	e8 0a 03 00 00       	call   8007ce <strnlen>
  8004c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c7:	29 c1                	sub    %eax,%ecx
  8004c9:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004d1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	eb 0f                	jmp    8004e9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	53                   	push   %ebx
  8004de:	ff 75 e0             	push   -0x20(%ebp)
  8004e1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	83 ef 01             	sub    $0x1,%edi
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	7f ed                	jg     8004da <vprintfmt+0x1cc>
  8004ed:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f0:	85 d2                	test   %edx,%edx
  8004f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f7:	0f 49 c2             	cmovns %edx,%eax
  8004fa:	29 c2                	sub    %eax,%edx
  8004fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ff:	eb a8                	jmp    8004a9 <vprintfmt+0x19b>
					putch(ch, putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	53                   	push   %ebx
  800505:	52                   	push   %edx
  800506:	ff d6                	call   *%esi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800510:	83 c7 01             	add    $0x1,%edi
  800513:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800517:	0f be d0             	movsbl %al,%edx
  80051a:	85 d2                	test   %edx,%edx
  80051c:	74 4b                	je     800569 <vprintfmt+0x25b>
  80051e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800522:	78 06                	js     80052a <vprintfmt+0x21c>
  800524:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800528:	78 1e                	js     800548 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80052a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052e:	74 d1                	je     800501 <vprintfmt+0x1f3>
  800530:	0f be c0             	movsbl %al,%eax
  800533:	83 e8 20             	sub    $0x20,%eax
  800536:	83 f8 5e             	cmp    $0x5e,%eax
  800539:	76 c6                	jbe    800501 <vprintfmt+0x1f3>
					putch('?', putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	53                   	push   %ebx
  80053f:	6a 3f                	push   $0x3f
  800541:	ff d6                	call   *%esi
  800543:	83 c4 10             	add    $0x10,%esp
  800546:	eb c3                	jmp    80050b <vprintfmt+0x1fd>
  800548:	89 cf                	mov    %ecx,%edi
  80054a:	eb 0e                	jmp    80055a <vprintfmt+0x24c>
				putch(' ', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	6a 20                	push   $0x20
  800552:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800554:	83 ef 01             	sub    $0x1,%edi
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	85 ff                	test   %edi,%edi
  80055c:	7f ee                	jg     80054c <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80055e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800561:	89 45 14             	mov    %eax,0x14(%ebp)
  800564:	e9 67 01 00 00       	jmp    8006d0 <vprintfmt+0x3c2>
  800569:	89 cf                	mov    %ecx,%edi
  80056b:	eb ed                	jmp    80055a <vprintfmt+0x24c>
	if (lflag >= 2)
  80056d:	83 f9 01             	cmp    $0x1,%ecx
  800570:	7f 1b                	jg     80058d <vprintfmt+0x27f>
	else if (lflag)
  800572:	85 c9                	test   %ecx,%ecx
  800574:	74 63                	je     8005d9 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057e:	99                   	cltd   
  80057f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 40 04             	lea    0x4(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
  80058b:	eb 17                	jmp    8005a4 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 50 04             	mov    0x4(%eax),%edx
  800593:	8b 00                	mov    (%eax),%eax
  800595:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800598:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 40 08             	lea    0x8(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005aa:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005af:	85 c9                	test   %ecx,%ecx
  8005b1:	0f 89 ff 00 00 00    	jns    8006b6 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	6a 2d                	push   $0x2d
  8005bd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c5:	f7 da                	neg    %edx
  8005c7:	83 d1 00             	adc    $0x0,%ecx
  8005ca:	f7 d9                	neg    %ecx
  8005cc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005cf:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005d4:	e9 dd 00 00 00       	jmp    8006b6 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 00                	mov    (%eax),%eax
  8005de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e1:	99                   	cltd   
  8005e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 40 04             	lea    0x4(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ee:	eb b4                	jmp    8005a4 <vprintfmt+0x296>
	if (lflag >= 2)
  8005f0:	83 f9 01             	cmp    $0x1,%ecx
  8005f3:	7f 1e                	jg     800613 <vprintfmt+0x305>
	else if (lflag)
  8005f5:	85 c9                	test   %ecx,%ecx
  8005f7:	74 32                	je     80062b <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800603:	8d 40 04             	lea    0x4(%eax),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800609:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80060e:	e9 a3 00 00 00       	jmp    8006b6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	8b 48 04             	mov    0x4(%eax),%ecx
  80061b:	8d 40 08             	lea    0x8(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800621:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800626:	e9 8b 00 00 00       	jmp    8006b6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	b9 00 00 00 00       	mov    $0x0,%ecx
  800635:	8d 40 04             	lea    0x4(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800640:	eb 74                	jmp    8006b6 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800642:	83 f9 01             	cmp    $0x1,%ecx
  800645:	7f 1b                	jg     800662 <vprintfmt+0x354>
	else if (lflag)
  800647:	85 c9                	test   %ecx,%ecx
  800649:	74 2c                	je     800677 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	b9 00 00 00 00       	mov    $0x0,%ecx
  800655:	8d 40 04             	lea    0x4(%eax),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80065b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800660:	eb 54                	jmp    8006b6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8b 10                	mov    (%eax),%edx
  800667:	8b 48 04             	mov    0x4(%eax),%ecx
  80066a:	8d 40 08             	lea    0x8(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800670:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800675:	eb 3f                	jmp    8006b6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800681:	8d 40 04             	lea    0x4(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800687:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80068c:	eb 28                	jmp    8006b6 <vprintfmt+0x3a8>
			putch('0', putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 30                	push   $0x30
  800694:	ff d6                	call   *%esi
			putch('x', putdat);
  800696:	83 c4 08             	add    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 78                	push   $0x78
  80069c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8b 10                	mov    (%eax),%edx
  8006a3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006a8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ab:	8d 40 04             	lea    0x4(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b1:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006bd:	50                   	push   %eax
  8006be:	ff 75 e0             	push   -0x20(%ebp)
  8006c1:	57                   	push   %edi
  8006c2:	51                   	push   %ecx
  8006c3:	52                   	push   %edx
  8006c4:	89 da                	mov    %ebx,%edx
  8006c6:	89 f0                	mov    %esi,%eax
  8006c8:	e8 5e fb ff ff       	call   80022b <printnum>
			break;
  8006cd:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d3:	e9 54 fc ff ff       	jmp    80032c <vprintfmt+0x1e>
	if (lflag >= 2)
  8006d8:	83 f9 01             	cmp    $0x1,%ecx
  8006db:	7f 1b                	jg     8006f8 <vprintfmt+0x3ea>
	else if (lflag)
  8006dd:	85 c9                	test   %ecx,%ecx
  8006df:	74 2c                	je     80070d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8b 10                	mov    (%eax),%edx
  8006e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006eb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f1:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006f6:	eb be                	jmp    8006b6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800700:	8d 40 08             	lea    0x8(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800706:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80070b:	eb a9                	jmp    8006b6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800722:	eb 92                	jmp    8006b6 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 25                	push   $0x25
  80072a:	ff d6                	call   *%esi
			break;
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	eb 9f                	jmp    8006d0 <vprintfmt+0x3c2>
			putch('%', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	6a 25                	push   $0x25
  800737:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	89 f8                	mov    %edi,%eax
  80073e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800742:	74 05                	je     800749 <vprintfmt+0x43b>
  800744:	83 e8 01             	sub    $0x1,%eax
  800747:	eb f5                	jmp    80073e <vprintfmt+0x430>
  800749:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074c:	eb 82                	jmp    8006d0 <vprintfmt+0x3c2>

0080074e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	83 ec 18             	sub    $0x18,%esp
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800761:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800764:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076b:	85 c0                	test   %eax,%eax
  80076d:	74 26                	je     800795 <vsnprintf+0x47>
  80076f:	85 d2                	test   %edx,%edx
  800771:	7e 22                	jle    800795 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800773:	ff 75 14             	push   0x14(%ebp)
  800776:	ff 75 10             	push   0x10(%ebp)
  800779:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077c:	50                   	push   %eax
  80077d:	68 d4 02 80 00       	push   $0x8002d4
  800782:	e8 87 fb ff ff       	call   80030e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800787:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800790:	83 c4 10             	add    $0x10,%esp
}
  800793:	c9                   	leave  
  800794:	c3                   	ret    
		return -E_INVAL;
  800795:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079a:	eb f7                	jmp    800793 <vsnprintf+0x45>

0080079c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a5:	50                   	push   %eax
  8007a6:	ff 75 10             	push   0x10(%ebp)
  8007a9:	ff 75 0c             	push   0xc(%ebp)
  8007ac:	ff 75 08             	push   0x8(%ebp)
  8007af:	e8 9a ff ff ff       	call   80074e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	eb 03                	jmp    8007c6 <strlen+0x10>
		n++;
  8007c3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ca:	75 f7                	jne    8007c3 <strlen+0xd>
	return n;
}
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dc:	eb 03                	jmp    8007e1 <strnlen+0x13>
		n++;
  8007de:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e1:	39 d0                	cmp    %edx,%eax
  8007e3:	74 08                	je     8007ed <strnlen+0x1f>
  8007e5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e9:	75 f3                	jne    8007de <strnlen+0x10>
  8007eb:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ed:	89 d0                	mov    %edx,%eax
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800804:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800807:	83 c0 01             	add    $0x1,%eax
  80080a:	84 d2                	test   %dl,%dl
  80080c:	75 f2                	jne    800800 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80080e:	89 c8                	mov    %ecx,%eax
  800810:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	83 ec 10             	sub    $0x10,%esp
  80081c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081f:	53                   	push   %ebx
  800820:	e8 91 ff ff ff       	call   8007b6 <strlen>
  800825:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800828:	ff 75 0c             	push   0xc(%ebp)
  80082b:	01 d8                	add    %ebx,%eax
  80082d:	50                   	push   %eax
  80082e:	e8 be ff ff ff       	call   8007f1 <strcpy>
	return dst;
}
  800833:	89 d8                	mov    %ebx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 75 08             	mov    0x8(%ebp),%esi
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
  800845:	89 f3                	mov    %esi,%ebx
  800847:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084a:	89 f0                	mov    %esi,%eax
  80084c:	eb 0f                	jmp    80085d <strncpy+0x23>
		*dst++ = *src;
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	0f b6 0a             	movzbl (%edx),%ecx
  800854:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800857:	80 f9 01             	cmp    $0x1,%cl
  80085a:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80085d:	39 d8                	cmp    %ebx,%eax
  80085f:	75 ed                	jne    80084e <strncpy+0x14>
	}
	return ret;
}
  800861:	89 f0                	mov    %esi,%eax
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 75 08             	mov    0x8(%ebp),%esi
  80086f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800872:	8b 55 10             	mov    0x10(%ebp),%edx
  800875:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800877:	85 d2                	test   %edx,%edx
  800879:	74 21                	je     80089c <strlcpy+0x35>
  80087b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087f:	89 f2                	mov    %esi,%edx
  800881:	eb 09                	jmp    80088c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800883:	83 c1 01             	add    $0x1,%ecx
  800886:	83 c2 01             	add    $0x1,%edx
  800889:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80088c:	39 c2                	cmp    %eax,%edx
  80088e:	74 09                	je     800899 <strlcpy+0x32>
  800890:	0f b6 19             	movzbl (%ecx),%ebx
  800893:	84 db                	test   %bl,%bl
  800895:	75 ec                	jne    800883 <strlcpy+0x1c>
  800897:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800899:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089c:	29 f0                	sub    %esi,%eax
}
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ab:	eb 06                	jmp    8008b3 <strcmp+0x11>
		p++, q++;
  8008ad:	83 c1 01             	add    $0x1,%ecx
  8008b0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008b3:	0f b6 01             	movzbl (%ecx),%eax
  8008b6:	84 c0                	test   %al,%al
  8008b8:	74 04                	je     8008be <strcmp+0x1c>
  8008ba:	3a 02                	cmp    (%edx),%al
  8008bc:	74 ef                	je     8008ad <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008be:	0f b6 c0             	movzbl %al,%eax
  8008c1:	0f b6 12             	movzbl (%edx),%edx
  8008c4:	29 d0                	sub    %edx,%eax
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	53                   	push   %ebx
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d2:	89 c3                	mov    %eax,%ebx
  8008d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d7:	eb 06                	jmp    8008df <strncmp+0x17>
		n--, p++, q++;
  8008d9:	83 c0 01             	add    $0x1,%eax
  8008dc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008df:	39 d8                	cmp    %ebx,%eax
  8008e1:	74 18                	je     8008fb <strncmp+0x33>
  8008e3:	0f b6 08             	movzbl (%eax),%ecx
  8008e6:	84 c9                	test   %cl,%cl
  8008e8:	74 04                	je     8008ee <strncmp+0x26>
  8008ea:	3a 0a                	cmp    (%edx),%cl
  8008ec:	74 eb                	je     8008d9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ee:	0f b6 00             	movzbl (%eax),%eax
  8008f1:	0f b6 12             	movzbl (%edx),%edx
  8008f4:	29 d0                	sub    %edx,%eax
}
  8008f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    
		return 0;
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800900:	eb f4                	jmp    8008f6 <strncmp+0x2e>

00800902 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090c:	eb 03                	jmp    800911 <strchr+0xf>
  80090e:	83 c0 01             	add    $0x1,%eax
  800911:	0f b6 10             	movzbl (%eax),%edx
  800914:	84 d2                	test   %dl,%dl
  800916:	74 06                	je     80091e <strchr+0x1c>
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	75 f2                	jne    80090e <strchr+0xc>
  80091c:	eb 05                	jmp    800923 <strchr+0x21>
			return (char *) s;
	return 0;
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800932:	38 ca                	cmp    %cl,%dl
  800934:	74 09                	je     80093f <strfind+0x1a>
  800936:	84 d2                	test   %dl,%dl
  800938:	74 05                	je     80093f <strfind+0x1a>
	for (; *s; s++)
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	eb f0                	jmp    80092f <strfind+0xa>
			break;
	return (char *) s;
}
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	57                   	push   %edi
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 2f                	je     800980 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	89 f8                	mov    %edi,%eax
  800953:	09 c8                	or     %ecx,%eax
  800955:	a8 03                	test   $0x3,%al
  800957:	75 21                	jne    80097a <memset+0x39>
		c &= 0xFF;
  800959:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095d:	89 d0                	mov    %edx,%eax
  80095f:	c1 e0 08             	shl    $0x8,%eax
  800962:	89 d3                	mov    %edx,%ebx
  800964:	c1 e3 18             	shl    $0x18,%ebx
  800967:	89 d6                	mov    %edx,%esi
  800969:	c1 e6 10             	shl    $0x10,%esi
  80096c:	09 f3                	or     %esi,%ebx
  80096e:	09 da                	or     %ebx,%edx
  800970:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800972:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800975:	fc                   	cld    
  800976:	f3 ab                	rep stos %eax,%es:(%edi)
  800978:	eb 06                	jmp    800980 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097d:	fc                   	cld    
  80097e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800980:	89 f8                	mov    %edi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800992:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800995:	39 c6                	cmp    %eax,%esi
  800997:	73 32                	jae    8009cb <memmove+0x44>
  800999:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099c:	39 c2                	cmp    %eax,%edx
  80099e:	76 2b                	jbe    8009cb <memmove+0x44>
		s += n;
		d += n;
  8009a0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a3:	89 d6                	mov    %edx,%esi
  8009a5:	09 fe                	or     %edi,%esi
  8009a7:	09 ce                	or     %ecx,%esi
  8009a9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009af:	75 0e                	jne    8009bf <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1a                	jmp    8009e5 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
  8009cf:	09 ca                	or     %ecx,%edx
  8009d1:	f6 c2 03             	test   $0x3,%dl
  8009d4:	75 0a                	jne    8009e0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009d9:	89 c7                	mov    %eax,%edi
  8009db:	fc                   	cld    
  8009dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009de:	eb 05                	jmp    8009e5 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009e0:	89 c7                	mov    %eax,%edi
  8009e2:	fc                   	cld    
  8009e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e5:	5e                   	pop    %esi
  8009e6:	5f                   	pop    %edi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ef:	ff 75 10             	push   0x10(%ebp)
  8009f2:	ff 75 0c             	push   0xc(%ebp)
  8009f5:	ff 75 08             	push   0x8(%ebp)
  8009f8:	e8 8a ff ff ff       	call   800987 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	89 c6                	mov    %eax,%esi
  800a0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	eb 06                	jmp    800a17 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a11:	83 c0 01             	add    $0x1,%eax
  800a14:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a17:	39 f0                	cmp    %esi,%eax
  800a19:	74 14                	je     800a2f <memcmp+0x30>
		if (*s1 != *s2)
  800a1b:	0f b6 08             	movzbl (%eax),%ecx
  800a1e:	0f b6 1a             	movzbl (%edx),%ebx
  800a21:	38 d9                	cmp    %bl,%cl
  800a23:	74 ec                	je     800a11 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a25:	0f b6 c1             	movzbl %cl,%eax
  800a28:	0f b6 db             	movzbl %bl,%ebx
  800a2b:	29 d8                	sub    %ebx,%eax
  800a2d:	eb 05                	jmp    800a34 <memcmp+0x35>
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a41:	89 c2                	mov    %eax,%edx
  800a43:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a46:	eb 03                	jmp    800a4b <memfind+0x13>
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	39 d0                	cmp    %edx,%eax
  800a4d:	73 04                	jae    800a53 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4f:	38 08                	cmp    %cl,(%eax)
  800a51:	75 f5                	jne    800a48 <memfind+0x10>
			break;
	return (void *) s;
}
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a61:	eb 03                	jmp    800a66 <strtol+0x11>
		s++;
  800a63:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a66:	0f b6 02             	movzbl (%edx),%eax
  800a69:	3c 20                	cmp    $0x20,%al
  800a6b:	74 f6                	je     800a63 <strtol+0xe>
  800a6d:	3c 09                	cmp    $0x9,%al
  800a6f:	74 f2                	je     800a63 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a71:	3c 2b                	cmp    $0x2b,%al
  800a73:	74 2a                	je     800a9f <strtol+0x4a>
	int neg = 0;
  800a75:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7a:	3c 2d                	cmp    $0x2d,%al
  800a7c:	74 2b                	je     800aa9 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a84:	75 0f                	jne    800a95 <strtol+0x40>
  800a86:	80 3a 30             	cmpb   $0x30,(%edx)
  800a89:	74 28                	je     800ab3 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8b:	85 db                	test   %ebx,%ebx
  800a8d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a92:	0f 44 d8             	cmove  %eax,%ebx
  800a95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9d:	eb 46                	jmp    800ae5 <strtol+0x90>
		s++;
  800a9f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa7:	eb d5                	jmp    800a7e <strtol+0x29>
		s++, neg = 1;
  800aa9:	83 c2 01             	add    $0x1,%edx
  800aac:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab1:	eb cb                	jmp    800a7e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab7:	74 0e                	je     800ac7 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 d8                	jne    800a95 <strtol+0x40>
		s++, base = 8;
  800abd:	83 c2 01             	add    $0x1,%edx
  800ac0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac5:	eb ce                	jmp    800a95 <strtol+0x40>
		s += 2, base = 16;
  800ac7:	83 c2 02             	add    $0x2,%edx
  800aca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acf:	eb c4                	jmp    800a95 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad1:	0f be c0             	movsbl %al,%eax
  800ad4:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ada:	7d 3a                	jge    800b16 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800adc:	83 c2 01             	add    $0x1,%edx
  800adf:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ae3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ae5:	0f b6 02             	movzbl (%edx),%eax
  800ae8:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aeb:	89 f3                	mov    %esi,%ebx
  800aed:	80 fb 09             	cmp    $0x9,%bl
  800af0:	76 df                	jbe    800ad1 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800af2:	8d 70 9f             	lea    -0x61(%eax),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 08                	ja     800b04 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800afc:	0f be c0             	movsbl %al,%eax
  800aff:	83 e8 57             	sub    $0x57,%eax
  800b02:	eb d3                	jmp    800ad7 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b04:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 08                	ja     800b16 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b0e:	0f be c0             	movsbl %al,%eax
  800b11:	83 e8 37             	sub    $0x37,%eax
  800b14:	eb c1                	jmp    800ad7 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1a:	74 05                	je     800b21 <strtol+0xcc>
		*endptr = (char *) s;
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b21:	89 c8                	mov    %ecx,%eax
  800b23:	f7 d8                	neg    %eax
  800b25:	85 ff                	test   %edi,%edi
  800b27:	0f 45 c8             	cmovne %eax,%ecx
}
  800b2a:	89 c8                	mov    %ecx,%eax
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b37:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	89 c3                	mov    %eax,%ebx
  800b44:	89 c7                	mov    %eax,%edi
  800b46:	89 c6                	mov    %eax,%esi
  800b48:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5f:	89 d1                	mov    %edx,%ecx
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	89 d7                	mov    %edx,%edi
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b84:	89 cb                	mov    %ecx,%ebx
  800b86:	89 cf                	mov    %ecx,%edi
  800b88:	89 ce                	mov    %ecx,%esi
  800b8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	7f 08                	jg     800b98 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
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
  800b9c:	6a 03                	push   $0x3
  800b9e:	68 9f 26 80 00       	push   $0x80269f
  800ba3:	6a 2a                	push   $0x2a
  800ba5:	68 bc 26 80 00       	push   $0x8026bc
  800baa:	e8 8d f5 ff ff       	call   80013c <_panic>

00800baf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_yield>:

void
sys_yield(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf6:	be 00 00 00 00       	mov    $0x0,%esi
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	b8 04 00 00 00       	mov    $0x4,%eax
  800c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c09:	89 f7                	mov    %esi,%edi
  800c0b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7f 08                	jg     800c19 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 04                	push   $0x4
  800c1f:	68 9f 26 80 00       	push   $0x80269f
  800c24:	6a 2a                	push   $0x2a
  800c26:	68 bc 26 80 00       	push   $0x8026bc
  800c2b:	e8 0c f5 ff ff       	call   80013c <_panic>

00800c30 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7f 08                	jg     800c5b <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 05                	push   $0x5
  800c61:	68 9f 26 80 00       	push   $0x80269f
  800c66:	6a 2a                	push   $0x2a
  800c68:	68 bc 26 80 00       	push   $0x8026bc
  800c6d:	e8 ca f4 ff ff       	call   80013c <_panic>

00800c72 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8b:	89 df                	mov    %ebx,%edi
  800c8d:	89 de                	mov    %ebx,%esi
  800c8f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7f 08                	jg     800c9d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 06                	push   $0x6
  800ca3:	68 9f 26 80 00       	push   $0x80269f
  800ca8:	6a 2a                	push   $0x2a
  800caa:	68 bc 26 80 00       	push   $0x8026bc
  800caf:	e8 88 f4 ff ff       	call   80013c <_panic>

00800cb4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7f 08                	jg     800cdf <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 08                	push   $0x8
  800ce5:	68 9f 26 80 00       	push   $0x80269f
  800cea:	6a 2a                	push   $0x2a
  800cec:	68 bc 26 80 00       	push   $0x8026bc
  800cf1:	e8 46 f4 ff ff       	call   80013c <_panic>

00800cf6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d0f:	89 df                	mov    %ebx,%edi
  800d11:	89 de                	mov    %ebx,%esi
  800d13:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d15:	85 c0                	test   %eax,%eax
  800d17:	7f 08                	jg     800d21 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 09                	push   $0x9
  800d27:	68 9f 26 80 00       	push   $0x80269f
  800d2c:	6a 2a                	push   $0x2a
  800d2e:	68 bc 26 80 00       	push   $0x8026bc
  800d33:	e8 04 f4 ff ff       	call   80013c <_panic>

00800d38 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d51:	89 df                	mov    %ebx,%edi
  800d53:	89 de                	mov    %ebx,%esi
  800d55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d57:	85 c0                	test   %eax,%eax
  800d59:	7f 08                	jg     800d63 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 0a                	push   $0xa
  800d69:	68 9f 26 80 00       	push   $0x80269f
  800d6e:	6a 2a                	push   $0x2a
  800d70:	68 bc 26 80 00       	push   $0x8026bc
  800d75:	e8 c2 f3 ff ff       	call   80013c <_panic>

00800d7a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d86:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8b:	be 00 00 00 00       	mov    $0x0,%esi
  800d90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d96:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db3:	89 cb                	mov    %ecx,%ebx
  800db5:	89 cf                	mov    %ecx,%edi
  800db7:	89 ce                	mov    %ecx,%esi
  800db9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7f 08                	jg     800dc7 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 0d                	push   $0xd
  800dcd:	68 9f 26 80 00       	push   $0x80269f
  800dd2:	6a 2a                	push   $0x2a
  800dd4:	68 bc 26 80 00       	push   $0x8026bc
  800dd9:	e8 5e f3 ff ff       	call   80013c <_panic>

00800dde <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de4:	ba 00 00 00 00       	mov    $0x0,%edx
  800de9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dee:	89 d1                	mov    %edx,%ecx
  800df0:	89 d3                	mov    %edx,%ebx
  800df2:	89 d7                	mov    %edx,%edi
  800df4:	89 d6                	mov    %edx,%esi
  800df6:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e13:	89 df                	mov    %ebx,%edi
  800e15:	89 de                	mov    %ebx,%esi
  800e17:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2f:	b8 10 00 00 00       	mov    $0x10,%eax
  800e34:	89 df                	mov    %ebx,%edi
  800e36:	89 de                	mov    %ebx,%esi
  800e38:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e3a:	5b                   	pop    %ebx
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4a:	c1 e8 0c             	shr    $0xc,%eax
}
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
  800e55:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e5f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e6e:	89 c2                	mov    %eax,%edx
  800e70:	c1 ea 16             	shr    $0x16,%edx
  800e73:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7a:	f6 c2 01             	test   $0x1,%dl
  800e7d:	74 29                	je     800ea8 <fd_alloc+0x42>
  800e7f:	89 c2                	mov    %eax,%edx
  800e81:	c1 ea 0c             	shr    $0xc,%edx
  800e84:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8b:	f6 c2 01             	test   $0x1,%dl
  800e8e:	74 18                	je     800ea8 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e90:	05 00 10 00 00       	add    $0x1000,%eax
  800e95:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e9a:	75 d2                	jne    800e6e <fd_alloc+0x8>
  800e9c:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800ea1:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800ea6:	eb 05                	jmp    800ead <fd_alloc+0x47>
			return 0;
  800ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800ead:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb0:	89 02                	mov    %eax,(%edx)
}
  800eb2:	89 c8                	mov    %ecx,%eax
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ebc:	83 f8 1f             	cmp    $0x1f,%eax
  800ebf:	77 30                	ja     800ef1 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ec1:	c1 e0 0c             	shl    $0xc,%eax
  800ec4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec9:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ecf:	f6 c2 01             	test   $0x1,%dl
  800ed2:	74 24                	je     800ef8 <fd_lookup+0x42>
  800ed4:	89 c2                	mov    %eax,%edx
  800ed6:	c1 ea 0c             	shr    $0xc,%edx
  800ed9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee0:	f6 c2 01             	test   $0x1,%dl
  800ee3:	74 1a                	je     800eff <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee8:	89 02                	mov    %eax,(%edx)
	return 0;
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    
		return -E_INVAL;
  800ef1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef6:	eb f7                	jmp    800eef <fd_lookup+0x39>
		return -E_INVAL;
  800ef8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efd:	eb f0                	jmp    800eef <fd_lookup+0x39>
  800eff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f04:	eb e9                	jmp    800eef <fd_lookup+0x39>

00800f06 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f10:	b8 00 00 00 00       	mov    $0x0,%eax
  800f15:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f1a:	39 13                	cmp    %edx,(%ebx)
  800f1c:	74 37                	je     800f55 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f1e:	83 c0 01             	add    $0x1,%eax
  800f21:	8b 1c 85 48 27 80 00 	mov    0x802748(,%eax,4),%ebx
  800f28:	85 db                	test   %ebx,%ebx
  800f2a:	75 ee                	jne    800f1a <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f2c:	a1 00 40 c0 00       	mov    0xc04000,%eax
  800f31:	8b 40 48             	mov    0x48(%eax),%eax
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	52                   	push   %edx
  800f38:	50                   	push   %eax
  800f39:	68 cc 26 80 00       	push   $0x8026cc
  800f3e:	e8 d4 f2 ff ff       	call   800217 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4e:	89 1a                	mov    %ebx,(%edx)
}
  800f50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    
			return 0;
  800f55:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5a:	eb ef                	jmp    800f4b <dev_lookup+0x45>

00800f5c <fd_close>:
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	57                   	push   %edi
  800f60:	56                   	push   %esi
  800f61:	53                   	push   %ebx
  800f62:	83 ec 24             	sub    $0x24,%esp
  800f65:	8b 75 08             	mov    0x8(%ebp),%esi
  800f68:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f6b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f6e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f6f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f75:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f78:	50                   	push   %eax
  800f79:	e8 38 ff ff ff       	call   800eb6 <fd_lookup>
  800f7e:	89 c3                	mov    %eax,%ebx
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	78 05                	js     800f8c <fd_close+0x30>
	    || fd != fd2)
  800f87:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f8a:	74 16                	je     800fa2 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f8c:	89 f8                	mov    %edi,%eax
  800f8e:	84 c0                	test   %al,%al
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
  800f95:	0f 44 d8             	cmove  %eax,%ebx
}
  800f98:	89 d8                	mov    %ebx,%eax
  800f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fa2:	83 ec 08             	sub    $0x8,%esp
  800fa5:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fa8:	50                   	push   %eax
  800fa9:	ff 36                	push   (%esi)
  800fab:	e8 56 ff ff ff       	call   800f06 <dev_lookup>
  800fb0:	89 c3                	mov    %eax,%ebx
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	78 1a                	js     800fd3 <fd_close+0x77>
		if (dev->dev_close)
  800fb9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fbc:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fbf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	74 0b                	je     800fd3 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fc8:	83 ec 0c             	sub    $0xc,%esp
  800fcb:	56                   	push   %esi
  800fcc:	ff d0                	call   *%eax
  800fce:	89 c3                	mov    %eax,%ebx
  800fd0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fd3:	83 ec 08             	sub    $0x8,%esp
  800fd6:	56                   	push   %esi
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 94 fc ff ff       	call   800c72 <sys_page_unmap>
	return r;
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	eb b5                	jmp    800f98 <fd_close+0x3c>

00800fe3 <close>:

int
close(int fdnum)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fec:	50                   	push   %eax
  800fed:	ff 75 08             	push   0x8(%ebp)
  800ff0:	e8 c1 fe ff ff       	call   800eb6 <fd_lookup>
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	79 02                	jns    800ffe <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    
		return fd_close(fd, 1);
  800ffe:	83 ec 08             	sub    $0x8,%esp
  801001:	6a 01                	push   $0x1
  801003:	ff 75 f4             	push   -0xc(%ebp)
  801006:	e8 51 ff ff ff       	call   800f5c <fd_close>
  80100b:	83 c4 10             	add    $0x10,%esp
  80100e:	eb ec                	jmp    800ffc <close+0x19>

00801010 <close_all>:

void
close_all(void)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	53                   	push   %ebx
  801014:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801017:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	53                   	push   %ebx
  801020:	e8 be ff ff ff       	call   800fe3 <close>
	for (i = 0; i < MAXFD; i++)
  801025:	83 c3 01             	add    $0x1,%ebx
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	83 fb 20             	cmp    $0x20,%ebx
  80102e:	75 ec                	jne    80101c <close_all+0xc>
}
  801030:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	57                   	push   %edi
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80103e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801041:	50                   	push   %eax
  801042:	ff 75 08             	push   0x8(%ebp)
  801045:	e8 6c fe ff ff       	call   800eb6 <fd_lookup>
  80104a:	89 c3                	mov    %eax,%ebx
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 7f                	js     8010d2 <dup+0x9d>
		return r;
	close(newfdnum);
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	ff 75 0c             	push   0xc(%ebp)
  801059:	e8 85 ff ff ff       	call   800fe3 <close>

	newfd = INDEX2FD(newfdnum);
  80105e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801061:	c1 e6 0c             	shl    $0xc,%esi
  801064:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80106a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80106d:	89 3c 24             	mov    %edi,(%esp)
  801070:	e8 da fd ff ff       	call   800e4f <fd2data>
  801075:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801077:	89 34 24             	mov    %esi,(%esp)
  80107a:	e8 d0 fd ff ff       	call   800e4f <fd2data>
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801085:	89 d8                	mov    %ebx,%eax
  801087:	c1 e8 16             	shr    $0x16,%eax
  80108a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801091:	a8 01                	test   $0x1,%al
  801093:	74 11                	je     8010a6 <dup+0x71>
  801095:	89 d8                	mov    %ebx,%eax
  801097:	c1 e8 0c             	shr    $0xc,%eax
  80109a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a1:	f6 c2 01             	test   $0x1,%dl
  8010a4:	75 36                	jne    8010dc <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a6:	89 f8                	mov    %edi,%eax
  8010a8:	c1 e8 0c             	shr    $0xc,%eax
  8010ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b2:	83 ec 0c             	sub    $0xc,%esp
  8010b5:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ba:	50                   	push   %eax
  8010bb:	56                   	push   %esi
  8010bc:	6a 00                	push   $0x0
  8010be:	57                   	push   %edi
  8010bf:	6a 00                	push   $0x0
  8010c1:	e8 6a fb ff ff       	call   800c30 <sys_page_map>
  8010c6:	89 c3                	mov    %eax,%ebx
  8010c8:	83 c4 20             	add    $0x20,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	78 33                	js     801102 <dup+0xcd>
		goto err;

	return newfdnum;
  8010cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010d2:	89 d8                	mov    %ebx,%eax
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010eb:	50                   	push   %eax
  8010ec:	ff 75 d4             	push   -0x2c(%ebp)
  8010ef:	6a 00                	push   $0x0
  8010f1:	53                   	push   %ebx
  8010f2:	6a 00                	push   $0x0
  8010f4:	e8 37 fb ff ff       	call   800c30 <sys_page_map>
  8010f9:	89 c3                	mov    %eax,%ebx
  8010fb:	83 c4 20             	add    $0x20,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	79 a4                	jns    8010a6 <dup+0x71>
	sys_page_unmap(0, newfd);
  801102:	83 ec 08             	sub    $0x8,%esp
  801105:	56                   	push   %esi
  801106:	6a 00                	push   $0x0
  801108:	e8 65 fb ff ff       	call   800c72 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80110d:	83 c4 08             	add    $0x8,%esp
  801110:	ff 75 d4             	push   -0x2c(%ebp)
  801113:	6a 00                	push   $0x0
  801115:	e8 58 fb ff ff       	call   800c72 <sys_page_unmap>
	return r;
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	eb b3                	jmp    8010d2 <dup+0x9d>

0080111f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 18             	sub    $0x18,%esp
  801127:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	56                   	push   %esi
  80112f:	e8 82 fd ff ff       	call   800eb6 <fd_lookup>
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	85 c0                	test   %eax,%eax
  801139:	78 3c                	js     801177 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113b:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80113e:	83 ec 08             	sub    $0x8,%esp
  801141:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801144:	50                   	push   %eax
  801145:	ff 33                	push   (%ebx)
  801147:	e8 ba fd ff ff       	call   800f06 <dev_lookup>
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 24                	js     801177 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801153:	8b 43 08             	mov    0x8(%ebx),%eax
  801156:	83 e0 03             	and    $0x3,%eax
  801159:	83 f8 01             	cmp    $0x1,%eax
  80115c:	74 20                	je     80117e <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80115e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801161:	8b 40 08             	mov    0x8(%eax),%eax
  801164:	85 c0                	test   %eax,%eax
  801166:	74 37                	je     80119f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	ff 75 10             	push   0x10(%ebp)
  80116e:	ff 75 0c             	push   0xc(%ebp)
  801171:	53                   	push   %ebx
  801172:	ff d0                	call   *%eax
  801174:	83 c4 10             	add    $0x10,%esp
}
  801177:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80117e:	a1 00 40 c0 00       	mov    0xc04000,%eax
  801183:	8b 40 48             	mov    0x48(%eax),%eax
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	56                   	push   %esi
  80118a:	50                   	push   %eax
  80118b:	68 0d 27 80 00       	push   $0x80270d
  801190:	e8 82 f0 ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80119d:	eb d8                	jmp    801177 <read+0x58>
		return -E_NOT_SUPP;
  80119f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011a4:	eb d1                	jmp    801177 <read+0x58>

008011a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	57                   	push   %edi
  8011aa:	56                   	push   %esi
  8011ab:	53                   	push   %ebx
  8011ac:	83 ec 0c             	sub    $0xc,%esp
  8011af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ba:	eb 02                	jmp    8011be <readn+0x18>
  8011bc:	01 c3                	add    %eax,%ebx
  8011be:	39 f3                	cmp    %esi,%ebx
  8011c0:	73 21                	jae    8011e3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c2:	83 ec 04             	sub    $0x4,%esp
  8011c5:	89 f0                	mov    %esi,%eax
  8011c7:	29 d8                	sub    %ebx,%eax
  8011c9:	50                   	push   %eax
  8011ca:	89 d8                	mov    %ebx,%eax
  8011cc:	03 45 0c             	add    0xc(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	57                   	push   %edi
  8011d1:	e8 49 ff ff ff       	call   80111f <read>
		if (m < 0)
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 04                	js     8011e1 <readn+0x3b>
			return m;
		if (m == 0)
  8011dd:	75 dd                	jne    8011bc <readn+0x16>
  8011df:	eb 02                	jmp    8011e3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011e3:	89 d8                	mov    %ebx,%eax
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	56                   	push   %esi
  8011f1:	53                   	push   %ebx
  8011f2:	83 ec 18             	sub    $0x18,%esp
  8011f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	53                   	push   %ebx
  8011fd:	e8 b4 fc ff ff       	call   800eb6 <fd_lookup>
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	85 c0                	test   %eax,%eax
  801207:	78 37                	js     801240 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801209:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80120c:	83 ec 08             	sub    $0x8,%esp
  80120f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	ff 36                	push   (%esi)
  801215:	e8 ec fc ff ff       	call   800f06 <dev_lookup>
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 1f                	js     801240 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801221:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801225:	74 20                	je     801247 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801227:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122a:	8b 40 0c             	mov    0xc(%eax),%eax
  80122d:	85 c0                	test   %eax,%eax
  80122f:	74 37                	je     801268 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801231:	83 ec 04             	sub    $0x4,%esp
  801234:	ff 75 10             	push   0x10(%ebp)
  801237:	ff 75 0c             	push   0xc(%ebp)
  80123a:	56                   	push   %esi
  80123b:	ff d0                	call   *%eax
  80123d:	83 c4 10             	add    $0x10,%esp
}
  801240:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801243:	5b                   	pop    %ebx
  801244:	5e                   	pop    %esi
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801247:	a1 00 40 c0 00       	mov    0xc04000,%eax
  80124c:	8b 40 48             	mov    0x48(%eax),%eax
  80124f:	83 ec 04             	sub    $0x4,%esp
  801252:	53                   	push   %ebx
  801253:	50                   	push   %eax
  801254:	68 29 27 80 00       	push   $0x802729
  801259:	e8 b9 ef ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801266:	eb d8                	jmp    801240 <write+0x53>
		return -E_NOT_SUPP;
  801268:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80126d:	eb d1                	jmp    801240 <write+0x53>

0080126f <seek>:

int
seek(int fdnum, off_t offset)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801275:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	ff 75 08             	push   0x8(%ebp)
  80127c:	e8 35 fc ff ff       	call   800eb6 <fd_lookup>
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	78 0e                	js     801296 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801288:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	56                   	push   %esi
  80129c:	53                   	push   %ebx
  80129d:	83 ec 18             	sub    $0x18,%esp
  8012a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a6:	50                   	push   %eax
  8012a7:	53                   	push   %ebx
  8012a8:	e8 09 fc ff ff       	call   800eb6 <fd_lookup>
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 34                	js     8012e8 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	50                   	push   %eax
  8012be:	ff 36                	push   (%esi)
  8012c0:	e8 41 fc ff ff       	call   800f06 <dev_lookup>
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 1c                	js     8012e8 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012cc:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012d0:	74 1d                	je     8012ef <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d5:	8b 40 18             	mov    0x18(%eax),%eax
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	74 34                	je     801310 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	ff 75 0c             	push   0xc(%ebp)
  8012e2:	56                   	push   %esi
  8012e3:	ff d0                	call   *%eax
  8012e5:	83 c4 10             	add    $0x10,%esp
}
  8012e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012eb:	5b                   	pop    %ebx
  8012ec:	5e                   	pop    %esi
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012ef:	a1 00 40 c0 00       	mov    0xc04000,%eax
  8012f4:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	53                   	push   %ebx
  8012fb:	50                   	push   %eax
  8012fc:	68 ec 26 80 00       	push   $0x8026ec
  801301:	e8 11 ef ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130e:	eb d8                	jmp    8012e8 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801310:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801315:	eb d1                	jmp    8012e8 <ftruncate+0x50>

00801317 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	56                   	push   %esi
  80131b:	53                   	push   %ebx
  80131c:	83 ec 18             	sub    $0x18,%esp
  80131f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801322:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	ff 75 08             	push   0x8(%ebp)
  801329:	e8 88 fb ff ff       	call   800eb6 <fd_lookup>
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	78 49                	js     80137e <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801335:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	ff 36                	push   (%esi)
  801341:	e8 c0 fb ff ff       	call   800f06 <dev_lookup>
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 31                	js     80137e <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801350:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801354:	74 2f                	je     801385 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801356:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801359:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801360:	00 00 00 
	stat->st_isdir = 0;
  801363:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80136a:	00 00 00 
	stat->st_dev = dev;
  80136d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	53                   	push   %ebx
  801377:	56                   	push   %esi
  801378:	ff 50 14             	call   *0x14(%eax)
  80137b:	83 c4 10             	add    $0x10,%esp
}
  80137e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    
		return -E_NOT_SUPP;
  801385:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80138a:	eb f2                	jmp    80137e <fstat+0x67>

0080138c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	6a 00                	push   $0x0
  801396:	ff 75 08             	push   0x8(%ebp)
  801399:	e8 e4 01 00 00       	call   801582 <open>
  80139e:	89 c3                	mov    %eax,%ebx
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 1b                	js     8013c2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	ff 75 0c             	push   0xc(%ebp)
  8013ad:	50                   	push   %eax
  8013ae:	e8 64 ff ff ff       	call   801317 <fstat>
  8013b3:	89 c6                	mov    %eax,%esi
	close(fd);
  8013b5:	89 1c 24             	mov    %ebx,(%esp)
  8013b8:	e8 26 fc ff ff       	call   800fe3 <close>
	return r;
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	89 f3                	mov    %esi,%ebx
}
  8013c2:	89 d8                	mov    %ebx,%eax
  8013c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
  8013d0:	89 c6                	mov    %eax,%esi
  8013d2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013d4:	83 3d 00 60 c0 00 00 	cmpl   $0x0,0xc06000
  8013db:	74 27                	je     801404 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013dd:	6a 07                	push   $0x7
  8013df:	68 00 50 c0 00       	push   $0xc05000
  8013e4:	56                   	push   %esi
  8013e5:	ff 35 00 60 c0 00    	push   0xc06000
  8013eb:	e8 c4 0b 00 00       	call   801fb4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f0:	83 c4 0c             	add    $0xc,%esp
  8013f3:	6a 00                	push   $0x0
  8013f5:	53                   	push   %ebx
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 50 0b 00 00       	call   801f4d <ipc_recv>
}
  8013fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801404:	83 ec 0c             	sub    $0xc,%esp
  801407:	6a 01                	push   $0x1
  801409:	e8 fa 0b 00 00       	call   802008 <ipc_find_env>
  80140e:	a3 00 60 c0 00       	mov    %eax,0xc06000
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	eb c5                	jmp    8013dd <fsipc+0x12>

00801418 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	8b 40 0c             	mov    0xc(%eax),%eax
  801424:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801429:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142c:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801431:	ba 00 00 00 00       	mov    $0x0,%edx
  801436:	b8 02 00 00 00       	mov    $0x2,%eax
  80143b:	e8 8b ff ff ff       	call   8013cb <fsipc>
}
  801440:	c9                   	leave  
  801441:	c3                   	ret    

00801442 <devfile_flush>:
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801448:	8b 45 08             	mov    0x8(%ebp),%eax
  80144b:	8b 40 0c             	mov    0xc(%eax),%eax
  80144e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801453:	ba 00 00 00 00       	mov    $0x0,%edx
  801458:	b8 06 00 00 00       	mov    $0x6,%eax
  80145d:	e8 69 ff ff ff       	call   8013cb <fsipc>
}
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <devfile_stat>:
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	53                   	push   %ebx
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80146e:	8b 45 08             	mov    0x8(%ebp),%eax
  801471:	8b 40 0c             	mov    0xc(%eax),%eax
  801474:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801479:	ba 00 00 00 00       	mov    $0x0,%edx
  80147e:	b8 05 00 00 00       	mov    $0x5,%eax
  801483:	e8 43 ff ff ff       	call   8013cb <fsipc>
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 2c                	js     8014b8 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	68 00 50 c0 00       	push   $0xc05000
  801494:	53                   	push   %ebx
  801495:	e8 57 f3 ff ff       	call   8007f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80149a:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80149f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014a5:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8014aa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    

008014bd <devfile_write>:
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8014c6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014cb:	39 d0                	cmp    %edx,%eax
  8014cd:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d6:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  8014dc:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014e1:	50                   	push   %eax
  8014e2:	ff 75 0c             	push   0xc(%ebp)
  8014e5:	68 08 50 c0 00       	push   $0xc05008
  8014ea:	e8 98 f4 ff ff       	call   800987 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8014ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f4:	b8 04 00 00 00       	mov    $0x4,%eax
  8014f9:	e8 cd fe ff ff       	call   8013cb <fsipc>
}
  8014fe:	c9                   	leave  
  8014ff:	c3                   	ret    

00801500 <devfile_read>:
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	56                   	push   %esi
  801504:	53                   	push   %ebx
  801505:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801508:	8b 45 08             	mov    0x8(%ebp),%eax
  80150b:	8b 40 0c             	mov    0xc(%eax),%eax
  80150e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801513:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801519:	ba 00 00 00 00       	mov    $0x0,%edx
  80151e:	b8 03 00 00 00       	mov    $0x3,%eax
  801523:	e8 a3 fe ff ff       	call   8013cb <fsipc>
  801528:	89 c3                	mov    %eax,%ebx
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 1f                	js     80154d <devfile_read+0x4d>
	assert(r <= n);
  80152e:	39 f0                	cmp    %esi,%eax
  801530:	77 24                	ja     801556 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801532:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801537:	7f 33                	jg     80156c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801539:	83 ec 04             	sub    $0x4,%esp
  80153c:	50                   	push   %eax
  80153d:	68 00 50 c0 00       	push   $0xc05000
  801542:	ff 75 0c             	push   0xc(%ebp)
  801545:	e8 3d f4 ff ff       	call   800987 <memmove>
	return r;
  80154a:	83 c4 10             	add    $0x10,%esp
}
  80154d:	89 d8                	mov    %ebx,%eax
  80154f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801552:	5b                   	pop    %ebx
  801553:	5e                   	pop    %esi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    
	assert(r <= n);
  801556:	68 5c 27 80 00       	push   $0x80275c
  80155b:	68 63 27 80 00       	push   $0x802763
  801560:	6a 7c                	push   $0x7c
  801562:	68 78 27 80 00       	push   $0x802778
  801567:	e8 d0 eb ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  80156c:	68 83 27 80 00       	push   $0x802783
  801571:	68 63 27 80 00       	push   $0x802763
  801576:	6a 7d                	push   $0x7d
  801578:	68 78 27 80 00       	push   $0x802778
  80157d:	e8 ba eb ff ff       	call   80013c <_panic>

00801582 <open>:
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	56                   	push   %esi
  801586:	53                   	push   %ebx
  801587:	83 ec 1c             	sub    $0x1c,%esp
  80158a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80158d:	56                   	push   %esi
  80158e:	e8 23 f2 ff ff       	call   8007b6 <strlen>
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80159b:	7f 6c                	jg     801609 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80159d:	83 ec 0c             	sub    $0xc,%esp
  8015a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	e8 bd f8 ff ff       	call   800e66 <fd_alloc>
  8015a9:	89 c3                	mov    %eax,%ebx
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 3c                	js     8015ee <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	56                   	push   %esi
  8015b6:	68 00 50 c0 00       	push   $0xc05000
  8015bb:	e8 31 f2 ff ff       	call   8007f1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c3:	a3 00 54 c0 00       	mov    %eax,0xc05400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d0:	e8 f6 fd ff ff       	call   8013cb <fsipc>
  8015d5:	89 c3                	mov    %eax,%ebx
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 19                	js     8015f7 <open+0x75>
	return fd2num(fd);
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	ff 75 f4             	push   -0xc(%ebp)
  8015e4:	e8 56 f8 ff ff       	call   800e3f <fd2num>
  8015e9:	89 c3                	mov    %eax,%ebx
  8015eb:	83 c4 10             	add    $0x10,%esp
}
  8015ee:	89 d8                	mov    %ebx,%eax
  8015f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f3:	5b                   	pop    %ebx
  8015f4:	5e                   	pop    %esi
  8015f5:	5d                   	pop    %ebp
  8015f6:	c3                   	ret    
		fd_close(fd, 0);
  8015f7:	83 ec 08             	sub    $0x8,%esp
  8015fa:	6a 00                	push   $0x0
  8015fc:	ff 75 f4             	push   -0xc(%ebp)
  8015ff:	e8 58 f9 ff ff       	call   800f5c <fd_close>
		return r;
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	eb e5                	jmp    8015ee <open+0x6c>
		return -E_BAD_PATH;
  801609:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80160e:	eb de                	jmp    8015ee <open+0x6c>

00801610 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801616:	ba 00 00 00 00       	mov    $0x0,%edx
  80161b:	b8 08 00 00 00       	mov    $0x8,%eax
  801620:	e8 a6 fd ff ff       	call   8013cb <fsipc>
}
  801625:	c9                   	leave  
  801626:	c3                   	ret    

00801627 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80162d:	68 8f 27 80 00       	push   $0x80278f
  801632:	ff 75 0c             	push   0xc(%ebp)
  801635:	e8 b7 f1 ff ff       	call   8007f1 <strcpy>
	return 0;
}
  80163a:	b8 00 00 00 00       	mov    $0x0,%eax
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <devsock_close>:
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	53                   	push   %ebx
  801645:	83 ec 10             	sub    $0x10,%esp
  801648:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80164b:	53                   	push   %ebx
  80164c:	e8 f0 09 00 00       	call   802041 <pageref>
  801651:	89 c2                	mov    %eax,%edx
  801653:	83 c4 10             	add    $0x10,%esp
		return 0;
  801656:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80165b:	83 fa 01             	cmp    $0x1,%edx
  80165e:	74 05                	je     801665 <devsock_close+0x24>
}
  801660:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801663:	c9                   	leave  
  801664:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	ff 73 0c             	push   0xc(%ebx)
  80166b:	e8 b7 02 00 00       	call   801927 <nsipc_close>
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	eb eb                	jmp    801660 <devsock_close+0x1f>

00801675 <devsock_write>:
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80167b:	6a 00                	push   $0x0
  80167d:	ff 75 10             	push   0x10(%ebp)
  801680:	ff 75 0c             	push   0xc(%ebp)
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	ff 70 0c             	push   0xc(%eax)
  801689:	e8 79 03 00 00       	call   801a07 <nsipc_send>
}
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <devsock_read>:
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801696:	6a 00                	push   $0x0
  801698:	ff 75 10             	push   0x10(%ebp)
  80169b:	ff 75 0c             	push   0xc(%ebp)
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	ff 70 0c             	push   0xc(%eax)
  8016a4:	e8 ef 02 00 00       	call   801998 <nsipc_recv>
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <fd2sockid>:
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016b1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016b4:	52                   	push   %edx
  8016b5:	50                   	push   %eax
  8016b6:	e8 fb f7 ff ff       	call   800eb6 <fd_lookup>
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 10                	js     8016d2 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8016c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016cb:	39 08                	cmp    %ecx,(%eax)
  8016cd:	75 05                	jne    8016d4 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8016cf:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    
		return -E_NOT_SUPP;
  8016d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016d9:	eb f7                	jmp    8016d2 <fd2sockid+0x27>

008016db <alloc_sockfd>:
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 1c             	sub    $0x1c,%esp
  8016e3:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8016e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	e8 78 f7 ff ff       	call   800e66 <fd_alloc>
  8016ee:	89 c3                	mov    %eax,%ebx
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 43                	js     80173a <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016f7:	83 ec 04             	sub    $0x4,%esp
  8016fa:	68 07 04 00 00       	push   $0x407
  8016ff:	ff 75 f4             	push   -0xc(%ebp)
  801702:	6a 00                	push   $0x0
  801704:	e8 e4 f4 ff ff       	call   800bed <sys_page_alloc>
  801709:	89 c3                	mov    %eax,%ebx
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 28                	js     80173a <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801715:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80171b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80171d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801720:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801727:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80172a:	83 ec 0c             	sub    $0xc,%esp
  80172d:	50                   	push   %eax
  80172e:	e8 0c f7 ff ff       	call   800e3f <fd2num>
  801733:	89 c3                	mov    %eax,%ebx
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	eb 0c                	jmp    801746 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	56                   	push   %esi
  80173e:	e8 e4 01 00 00       	call   801927 <nsipc_close>
		return r;
  801743:	83 c4 10             	add    $0x10,%esp
}
  801746:	89 d8                	mov    %ebx,%eax
  801748:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174b:	5b                   	pop    %ebx
  80174c:	5e                   	pop    %esi
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <accept>:
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801755:	8b 45 08             	mov    0x8(%ebp),%eax
  801758:	e8 4e ff ff ff       	call   8016ab <fd2sockid>
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 1b                	js     80177c <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801761:	83 ec 04             	sub    $0x4,%esp
  801764:	ff 75 10             	push   0x10(%ebp)
  801767:	ff 75 0c             	push   0xc(%ebp)
  80176a:	50                   	push   %eax
  80176b:	e8 0e 01 00 00       	call   80187e <nsipc_accept>
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	78 05                	js     80177c <accept+0x2d>
	return alloc_sockfd(r);
  801777:	e8 5f ff ff ff       	call   8016db <alloc_sockfd>
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <bind>:
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801784:	8b 45 08             	mov    0x8(%ebp),%eax
  801787:	e8 1f ff ff ff       	call   8016ab <fd2sockid>
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 12                	js     8017a2 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801790:	83 ec 04             	sub    $0x4,%esp
  801793:	ff 75 10             	push   0x10(%ebp)
  801796:	ff 75 0c             	push   0xc(%ebp)
  801799:	50                   	push   %eax
  80179a:	e8 31 01 00 00       	call   8018d0 <nsipc_bind>
  80179f:	83 c4 10             	add    $0x10,%esp
}
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <shutdown>:
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	e8 f9 fe ff ff       	call   8016ab <fd2sockid>
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 0f                	js     8017c5 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	ff 75 0c             	push   0xc(%ebp)
  8017bc:	50                   	push   %eax
  8017bd:	e8 43 01 00 00       	call   801905 <nsipc_shutdown>
  8017c2:	83 c4 10             	add    $0x10,%esp
}
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <connect>:
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	e8 d6 fe ff ff       	call   8016ab <fd2sockid>
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 12                	js     8017eb <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8017d9:	83 ec 04             	sub    $0x4,%esp
  8017dc:	ff 75 10             	push   0x10(%ebp)
  8017df:	ff 75 0c             	push   0xc(%ebp)
  8017e2:	50                   	push   %eax
  8017e3:	e8 59 01 00 00       	call   801941 <nsipc_connect>
  8017e8:	83 c4 10             	add    $0x10,%esp
}
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <listen>:
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	e8 b0 fe ff ff       	call   8016ab <fd2sockid>
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	78 0f                	js     80180e <listen+0x21>
	return nsipc_listen(r, backlog);
  8017ff:	83 ec 08             	sub    $0x8,%esp
  801802:	ff 75 0c             	push   0xc(%ebp)
  801805:	50                   	push   %eax
  801806:	e8 6b 01 00 00       	call   801976 <nsipc_listen>
  80180b:	83 c4 10             	add    $0x10,%esp
}
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <socket>:

int
socket(int domain, int type, int protocol)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801816:	ff 75 10             	push   0x10(%ebp)
  801819:	ff 75 0c             	push   0xc(%ebp)
  80181c:	ff 75 08             	push   0x8(%ebp)
  80181f:	e8 41 02 00 00       	call   801a65 <nsipc_socket>
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	85 c0                	test   %eax,%eax
  801829:	78 05                	js     801830 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80182b:	e8 ab fe ff ff       	call   8016db <alloc_sockfd>
}
  801830:	c9                   	leave  
  801831:	c3                   	ret    

00801832 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	53                   	push   %ebx
  801836:	83 ec 04             	sub    $0x4,%esp
  801839:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80183b:	83 3d 00 80 c0 00 00 	cmpl   $0x0,0xc08000
  801842:	74 26                	je     80186a <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801844:	6a 07                	push   $0x7
  801846:	68 00 70 c0 00       	push   $0xc07000
  80184b:	53                   	push   %ebx
  80184c:	ff 35 00 80 c0 00    	push   0xc08000
  801852:	e8 5d 07 00 00       	call   801fb4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801857:	83 c4 0c             	add    $0xc,%esp
  80185a:	6a 00                	push   $0x0
  80185c:	6a 00                	push   $0x0
  80185e:	6a 00                	push   $0x0
  801860:	e8 e8 06 00 00       	call   801f4d <ipc_recv>
}
  801865:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801868:	c9                   	leave  
  801869:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80186a:	83 ec 0c             	sub    $0xc,%esp
  80186d:	6a 02                	push   $0x2
  80186f:	e8 94 07 00 00       	call   802008 <ipc_find_env>
  801874:	a3 00 80 c0 00       	mov    %eax,0xc08000
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	eb c6                	jmp    801844 <nsipc+0x12>

0080187e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	56                   	push   %esi
  801882:	53                   	push   %ebx
  801883:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801886:	8b 45 08             	mov    0x8(%ebp),%eax
  801889:	a3 00 70 c0 00       	mov    %eax,0xc07000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80188e:	8b 06                	mov    (%esi),%eax
  801890:	a3 04 70 c0 00       	mov    %eax,0xc07004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801895:	b8 01 00 00 00       	mov    $0x1,%eax
  80189a:	e8 93 ff ff ff       	call   801832 <nsipc>
  80189f:	89 c3                	mov    %eax,%ebx
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	79 09                	jns    8018ae <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8018a5:	89 d8                	mov    %ebx,%eax
  8018a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5e                   	pop    %esi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	ff 35 10 70 c0 00    	push   0xc07010
  8018b7:	68 00 70 c0 00       	push   $0xc07000
  8018bc:	ff 75 0c             	push   0xc(%ebp)
  8018bf:	e8 c3 f0 ff ff       	call   800987 <memmove>
		*addrlen = ret->ret_addrlen;
  8018c4:	a1 10 70 c0 00       	mov    0xc07010,%eax
  8018c9:	89 06                	mov    %eax,(%esi)
  8018cb:	83 c4 10             	add    $0x10,%esp
	return r;
  8018ce:	eb d5                	jmp    8018a5 <nsipc_accept+0x27>

008018d0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	a3 00 70 c0 00       	mov    %eax,0xc07000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018e2:	53                   	push   %ebx
  8018e3:	ff 75 0c             	push   0xc(%ebp)
  8018e6:	68 04 70 c0 00       	push   $0xc07004
  8018eb:	e8 97 f0 ff ff       	call   800987 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018f0:	89 1d 14 70 c0 00    	mov    %ebx,0xc07014
	return nsipc(NSREQ_BIND);
  8018f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8018fb:	e8 32 ff ff ff       	call   801832 <nsipc>
}
  801900:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
  80190e:	a3 00 70 c0 00       	mov    %eax,0xc07000
	nsipcbuf.shutdown.req_how = how;
  801913:	8b 45 0c             	mov    0xc(%ebp),%eax
  801916:	a3 04 70 c0 00       	mov    %eax,0xc07004
	return nsipc(NSREQ_SHUTDOWN);
  80191b:	b8 03 00 00 00       	mov    $0x3,%eax
  801920:	e8 0d ff ff ff       	call   801832 <nsipc>
}
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <nsipc_close>:

int
nsipc_close(int s)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80192d:	8b 45 08             	mov    0x8(%ebp),%eax
  801930:	a3 00 70 c0 00       	mov    %eax,0xc07000
	return nsipc(NSREQ_CLOSE);
  801935:	b8 04 00 00 00       	mov    $0x4,%eax
  80193a:	e8 f3 fe ff ff       	call   801832 <nsipc>
}
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	53                   	push   %ebx
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80194b:	8b 45 08             	mov    0x8(%ebp),%eax
  80194e:	a3 00 70 c0 00       	mov    %eax,0xc07000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801953:	53                   	push   %ebx
  801954:	ff 75 0c             	push   0xc(%ebp)
  801957:	68 04 70 c0 00       	push   $0xc07004
  80195c:	e8 26 f0 ff ff       	call   800987 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801961:	89 1d 14 70 c0 00    	mov    %ebx,0xc07014
	return nsipc(NSREQ_CONNECT);
  801967:	b8 05 00 00 00       	mov    $0x5,%eax
  80196c:	e8 c1 fe ff ff       	call   801832 <nsipc>
}
  801971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	a3 00 70 c0 00       	mov    %eax,0xc07000
	nsipcbuf.listen.req_backlog = backlog;
  801984:	8b 45 0c             	mov    0xc(%ebp),%eax
  801987:	a3 04 70 c0 00       	mov    %eax,0xc07004
	return nsipc(NSREQ_LISTEN);
  80198c:	b8 06 00 00 00       	mov    $0x6,%eax
  801991:	e8 9c fe ff ff       	call   801832 <nsipc>
}
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	56                   	push   %esi
  80199c:	53                   	push   %ebx
  80199d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	a3 00 70 c0 00       	mov    %eax,0xc07000
	nsipcbuf.recv.req_len = len;
  8019a8:	89 35 04 70 c0 00    	mov    %esi,0xc07004
	nsipcbuf.recv.req_flags = flags;
  8019ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b1:	a3 08 70 c0 00       	mov    %eax,0xc07008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019b6:	b8 07 00 00 00       	mov    $0x7,%eax
  8019bb:	e8 72 fe ff ff       	call   801832 <nsipc>
  8019c0:	89 c3                	mov    %eax,%ebx
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 22                	js     8019e8 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8019c6:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019cb:	39 c6                	cmp    %eax,%esi
  8019cd:	0f 4e c6             	cmovle %esi,%eax
  8019d0:	39 c3                	cmp    %eax,%ebx
  8019d2:	7f 1d                	jg     8019f1 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019d4:	83 ec 04             	sub    $0x4,%esp
  8019d7:	53                   	push   %ebx
  8019d8:	68 00 70 c0 00       	push   $0xc07000
  8019dd:	ff 75 0c             	push   0xc(%ebp)
  8019e0:	e8 a2 ef ff ff       	call   800987 <memmove>
  8019e5:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019e8:	89 d8                	mov    %ebx,%eax
  8019ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ed:	5b                   	pop    %ebx
  8019ee:	5e                   	pop    %esi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8019f1:	68 9b 27 80 00       	push   $0x80279b
  8019f6:	68 63 27 80 00       	push   $0x802763
  8019fb:	6a 62                	push   $0x62
  8019fd:	68 b0 27 80 00       	push   $0x8027b0
  801a02:	e8 35 e7 ff ff       	call   80013c <_panic>

00801a07 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	53                   	push   %ebx
  801a0b:	83 ec 04             	sub    $0x4,%esp
  801a0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	a3 00 70 c0 00       	mov    %eax,0xc07000
	assert(size < 1600);
  801a19:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a1f:	7f 2e                	jg     801a4f <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a21:	83 ec 04             	sub    $0x4,%esp
  801a24:	53                   	push   %ebx
  801a25:	ff 75 0c             	push   0xc(%ebp)
  801a28:	68 0c 70 c0 00       	push   $0xc0700c
  801a2d:	e8 55 ef ff ff       	call   800987 <memmove>
	nsipcbuf.send.req_size = size;
  801a32:	89 1d 04 70 c0 00    	mov    %ebx,0xc07004
	nsipcbuf.send.req_flags = flags;
  801a38:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3b:	a3 08 70 c0 00       	mov    %eax,0xc07008
	return nsipc(NSREQ_SEND);
  801a40:	b8 08 00 00 00       	mov    $0x8,%eax
  801a45:	e8 e8 fd ff ff       	call   801832 <nsipc>
}
  801a4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    
	assert(size < 1600);
  801a4f:	68 bc 27 80 00       	push   $0x8027bc
  801a54:	68 63 27 80 00       	push   $0x802763
  801a59:	6a 6d                	push   $0x6d
  801a5b:	68 b0 27 80 00       	push   $0x8027b0
  801a60:	e8 d7 e6 ff ff       	call   80013c <_panic>

00801a65 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6e:	a3 00 70 c0 00       	mov    %eax,0xc07000
	nsipcbuf.socket.req_type = type;
  801a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a76:	a3 04 70 c0 00       	mov    %eax,0xc07004
	nsipcbuf.socket.req_protocol = protocol;
  801a7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7e:	a3 08 70 c0 00       	mov    %eax,0xc07008
	return nsipc(NSREQ_SOCKET);
  801a83:	b8 09 00 00 00       	mov    $0x9,%eax
  801a88:	e8 a5 fd ff ff       	call   801832 <nsipc>
}
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	56                   	push   %esi
  801a93:	53                   	push   %ebx
  801a94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	ff 75 08             	push   0x8(%ebp)
  801a9d:	e8 ad f3 ff ff       	call   800e4f <fd2data>
  801aa2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aa4:	83 c4 08             	add    $0x8,%esp
  801aa7:	68 c8 27 80 00       	push   $0x8027c8
  801aac:	53                   	push   %ebx
  801aad:	e8 3f ed ff ff       	call   8007f1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ab2:	8b 46 04             	mov    0x4(%esi),%eax
  801ab5:	2b 06                	sub    (%esi),%eax
  801ab7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801abd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ac4:	00 00 00 
	stat->st_dev = &devpipe;
  801ac7:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ace:	30 80 00 
	return 0;
}
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	53                   	push   %ebx
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ae7:	53                   	push   %ebx
  801ae8:	6a 00                	push   $0x0
  801aea:	e8 83 f1 ff ff       	call   800c72 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aef:	89 1c 24             	mov    %ebx,(%esp)
  801af2:	e8 58 f3 ff ff       	call   800e4f <fd2data>
  801af7:	83 c4 08             	add    $0x8,%esp
  801afa:	50                   	push   %eax
  801afb:	6a 00                	push   $0x0
  801afd:	e8 70 f1 ff ff       	call   800c72 <sys_page_unmap>
}
  801b02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <_pipeisclosed>:
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	57                   	push   %edi
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	83 ec 1c             	sub    $0x1c,%esp
  801b10:	89 c7                	mov    %eax,%edi
  801b12:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b14:	a1 00 40 c0 00       	mov    0xc04000,%eax
  801b19:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b1c:	83 ec 0c             	sub    $0xc,%esp
  801b1f:	57                   	push   %edi
  801b20:	e8 1c 05 00 00       	call   802041 <pageref>
  801b25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b28:	89 34 24             	mov    %esi,(%esp)
  801b2b:	e8 11 05 00 00       	call   802041 <pageref>
		nn = thisenv->env_runs;
  801b30:	8b 15 00 40 c0 00    	mov    0xc04000,%edx
  801b36:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	39 cb                	cmp    %ecx,%ebx
  801b3e:	74 1b                	je     801b5b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b40:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b43:	75 cf                	jne    801b14 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b45:	8b 42 58             	mov    0x58(%edx),%eax
  801b48:	6a 01                	push   $0x1
  801b4a:	50                   	push   %eax
  801b4b:	53                   	push   %ebx
  801b4c:	68 cf 27 80 00       	push   $0x8027cf
  801b51:	e8 c1 e6 ff ff       	call   800217 <cprintf>
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	eb b9                	jmp    801b14 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b5b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b5e:	0f 94 c0             	sete   %al
  801b61:	0f b6 c0             	movzbl %al,%eax
}
  801b64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b67:	5b                   	pop    %ebx
  801b68:	5e                   	pop    %esi
  801b69:	5f                   	pop    %edi
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <devpipe_write>:
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	57                   	push   %edi
  801b70:	56                   	push   %esi
  801b71:	53                   	push   %ebx
  801b72:	83 ec 28             	sub    $0x28,%esp
  801b75:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b78:	56                   	push   %esi
  801b79:	e8 d1 f2 ff ff       	call   800e4f <fd2data>
  801b7e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	bf 00 00 00 00       	mov    $0x0,%edi
  801b88:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b8b:	75 09                	jne    801b96 <devpipe_write+0x2a>
	return i;
  801b8d:	89 f8                	mov    %edi,%eax
  801b8f:	eb 23                	jmp    801bb4 <devpipe_write+0x48>
			sys_yield();
  801b91:	e8 38 f0 ff ff       	call   800bce <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b96:	8b 43 04             	mov    0x4(%ebx),%eax
  801b99:	8b 0b                	mov    (%ebx),%ecx
  801b9b:	8d 51 20             	lea    0x20(%ecx),%edx
  801b9e:	39 d0                	cmp    %edx,%eax
  801ba0:	72 1a                	jb     801bbc <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ba2:	89 da                	mov    %ebx,%edx
  801ba4:	89 f0                	mov    %esi,%eax
  801ba6:	e8 5c ff ff ff       	call   801b07 <_pipeisclosed>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	74 e2                	je     801b91 <devpipe_write+0x25>
				return 0;
  801baf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb7:	5b                   	pop    %ebx
  801bb8:	5e                   	pop    %esi
  801bb9:	5f                   	pop    %edi
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bc3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc6:	89 c2                	mov    %eax,%edx
  801bc8:	c1 fa 1f             	sar    $0x1f,%edx
  801bcb:	89 d1                	mov    %edx,%ecx
  801bcd:	c1 e9 1b             	shr    $0x1b,%ecx
  801bd0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bd3:	83 e2 1f             	and    $0x1f,%edx
  801bd6:	29 ca                	sub    %ecx,%edx
  801bd8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bdc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801be0:	83 c0 01             	add    $0x1,%eax
  801be3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801be6:	83 c7 01             	add    $0x1,%edi
  801be9:	eb 9d                	jmp    801b88 <devpipe_write+0x1c>

00801beb <devpipe_read>:
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	57                   	push   %edi
  801bef:	56                   	push   %esi
  801bf0:	53                   	push   %ebx
  801bf1:	83 ec 18             	sub    $0x18,%esp
  801bf4:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bf7:	57                   	push   %edi
  801bf8:	e8 52 f2 ff ff       	call   800e4f <fd2data>
  801bfd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	be 00 00 00 00       	mov    $0x0,%esi
  801c07:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c0a:	75 13                	jne    801c1f <devpipe_read+0x34>
	return i;
  801c0c:	89 f0                	mov    %esi,%eax
  801c0e:	eb 02                	jmp    801c12 <devpipe_read+0x27>
				return i;
  801c10:	89 f0                	mov    %esi,%eax
}
  801c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c15:	5b                   	pop    %ebx
  801c16:	5e                   	pop    %esi
  801c17:	5f                   	pop    %edi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    
			sys_yield();
  801c1a:	e8 af ef ff ff       	call   800bce <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c1f:	8b 03                	mov    (%ebx),%eax
  801c21:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c24:	75 18                	jne    801c3e <devpipe_read+0x53>
			if (i > 0)
  801c26:	85 f6                	test   %esi,%esi
  801c28:	75 e6                	jne    801c10 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801c2a:	89 da                	mov    %ebx,%edx
  801c2c:	89 f8                	mov    %edi,%eax
  801c2e:	e8 d4 fe ff ff       	call   801b07 <_pipeisclosed>
  801c33:	85 c0                	test   %eax,%eax
  801c35:	74 e3                	je     801c1a <devpipe_read+0x2f>
				return 0;
  801c37:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3c:	eb d4                	jmp    801c12 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c3e:	99                   	cltd   
  801c3f:	c1 ea 1b             	shr    $0x1b,%edx
  801c42:	01 d0                	add    %edx,%eax
  801c44:	83 e0 1f             	and    $0x1f,%eax
  801c47:	29 d0                	sub    %edx,%eax
  801c49:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c51:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c54:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c57:	83 c6 01             	add    $0x1,%esi
  801c5a:	eb ab                	jmp    801c07 <devpipe_read+0x1c>

00801c5c <pipe>:
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	56                   	push   %esi
  801c60:	53                   	push   %ebx
  801c61:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c67:	50                   	push   %eax
  801c68:	e8 f9 f1 ff ff       	call   800e66 <fd_alloc>
  801c6d:	89 c3                	mov    %eax,%ebx
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	0f 88 23 01 00 00    	js     801d9d <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7a:	83 ec 04             	sub    $0x4,%esp
  801c7d:	68 07 04 00 00       	push   $0x407
  801c82:	ff 75 f4             	push   -0xc(%ebp)
  801c85:	6a 00                	push   $0x0
  801c87:	e8 61 ef ff ff       	call   800bed <sys_page_alloc>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	83 c4 10             	add    $0x10,%esp
  801c91:	85 c0                	test   %eax,%eax
  801c93:	0f 88 04 01 00 00    	js     801d9d <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c9f:	50                   	push   %eax
  801ca0:	e8 c1 f1 ff ff       	call   800e66 <fd_alloc>
  801ca5:	89 c3                	mov    %eax,%ebx
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	0f 88 db 00 00 00    	js     801d8d <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb2:	83 ec 04             	sub    $0x4,%esp
  801cb5:	68 07 04 00 00       	push   $0x407
  801cba:	ff 75 f0             	push   -0x10(%ebp)
  801cbd:	6a 00                	push   $0x0
  801cbf:	e8 29 ef ff ff       	call   800bed <sys_page_alloc>
  801cc4:	89 c3                	mov    %eax,%ebx
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	0f 88 bc 00 00 00    	js     801d8d <pipe+0x131>
	va = fd2data(fd0);
  801cd1:	83 ec 0c             	sub    $0xc,%esp
  801cd4:	ff 75 f4             	push   -0xc(%ebp)
  801cd7:	e8 73 f1 ff ff       	call   800e4f <fd2data>
  801cdc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cde:	83 c4 0c             	add    $0xc,%esp
  801ce1:	68 07 04 00 00       	push   $0x407
  801ce6:	50                   	push   %eax
  801ce7:	6a 00                	push   $0x0
  801ce9:	e8 ff ee ff ff       	call   800bed <sys_page_alloc>
  801cee:	89 c3                	mov    %eax,%ebx
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	0f 88 82 00 00 00    	js     801d7d <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfb:	83 ec 0c             	sub    $0xc,%esp
  801cfe:	ff 75 f0             	push   -0x10(%ebp)
  801d01:	e8 49 f1 ff ff       	call   800e4f <fd2data>
  801d06:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d0d:	50                   	push   %eax
  801d0e:	6a 00                	push   $0x0
  801d10:	56                   	push   %esi
  801d11:	6a 00                	push   $0x0
  801d13:	e8 18 ef ff ff       	call   800c30 <sys_page_map>
  801d18:	89 c3                	mov    %eax,%ebx
  801d1a:	83 c4 20             	add    $0x20,%esp
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	78 4e                	js     801d6f <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801d21:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d29:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d2e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d35:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d38:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d44:	83 ec 0c             	sub    $0xc,%esp
  801d47:	ff 75 f4             	push   -0xc(%ebp)
  801d4a:	e8 f0 f0 ff ff       	call   800e3f <fd2num>
  801d4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d52:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d54:	83 c4 04             	add    $0x4,%esp
  801d57:	ff 75 f0             	push   -0x10(%ebp)
  801d5a:	e8 e0 f0 ff ff       	call   800e3f <fd2num>
  801d5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d62:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d6d:	eb 2e                	jmp    801d9d <pipe+0x141>
	sys_page_unmap(0, va);
  801d6f:	83 ec 08             	sub    $0x8,%esp
  801d72:	56                   	push   %esi
  801d73:	6a 00                	push   $0x0
  801d75:	e8 f8 ee ff ff       	call   800c72 <sys_page_unmap>
  801d7a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d7d:	83 ec 08             	sub    $0x8,%esp
  801d80:	ff 75 f0             	push   -0x10(%ebp)
  801d83:	6a 00                	push   $0x0
  801d85:	e8 e8 ee ff ff       	call   800c72 <sys_page_unmap>
  801d8a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d8d:	83 ec 08             	sub    $0x8,%esp
  801d90:	ff 75 f4             	push   -0xc(%ebp)
  801d93:	6a 00                	push   $0x0
  801d95:	e8 d8 ee ff ff       	call   800c72 <sys_page_unmap>
  801d9a:	83 c4 10             	add    $0x10,%esp
}
  801d9d:	89 d8                	mov    %ebx,%eax
  801d9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da2:	5b                   	pop    %ebx
  801da3:	5e                   	pop    %esi
  801da4:	5d                   	pop    %ebp
  801da5:	c3                   	ret    

00801da6 <pipeisclosed>:
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801daf:	50                   	push   %eax
  801db0:	ff 75 08             	push   0x8(%ebp)
  801db3:	e8 fe f0 ff ff       	call   800eb6 <fd_lookup>
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	78 18                	js     801dd7 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801dbf:	83 ec 0c             	sub    $0xc,%esp
  801dc2:	ff 75 f4             	push   -0xc(%ebp)
  801dc5:	e8 85 f0 ff ff       	call   800e4f <fd2data>
  801dca:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcf:	e8 33 fd ff ff       	call   801b07 <_pipeisclosed>
  801dd4:	83 c4 10             	add    $0x10,%esp
}
  801dd7:	c9                   	leave  
  801dd8:	c3                   	ret    

00801dd9 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dde:	c3                   	ret    

00801ddf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801de5:	68 e7 27 80 00       	push   $0x8027e7
  801dea:	ff 75 0c             	push   0xc(%ebp)
  801ded:	e8 ff e9 ff ff       	call   8007f1 <strcpy>
	return 0;
}
  801df2:	b8 00 00 00 00       	mov    $0x0,%eax
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    

00801df9 <devcons_write>:
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	57                   	push   %edi
  801dfd:	56                   	push   %esi
  801dfe:	53                   	push   %ebx
  801dff:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e05:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e0a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e10:	eb 2e                	jmp    801e40 <devcons_write+0x47>
		m = n - tot;
  801e12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e15:	29 f3                	sub    %esi,%ebx
  801e17:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e1c:	39 c3                	cmp    %eax,%ebx
  801e1e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e21:	83 ec 04             	sub    $0x4,%esp
  801e24:	53                   	push   %ebx
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	03 45 0c             	add    0xc(%ebp),%eax
  801e2a:	50                   	push   %eax
  801e2b:	57                   	push   %edi
  801e2c:	e8 56 eb ff ff       	call   800987 <memmove>
		sys_cputs(buf, m);
  801e31:	83 c4 08             	add    $0x8,%esp
  801e34:	53                   	push   %ebx
  801e35:	57                   	push   %edi
  801e36:	e8 f6 ec ff ff       	call   800b31 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e3b:	01 de                	add    %ebx,%esi
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e43:	72 cd                	jb     801e12 <devcons_write+0x19>
}
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4a:	5b                   	pop    %ebx
  801e4b:	5e                   	pop    %esi
  801e4c:	5f                   	pop    %edi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <devcons_read>:
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	83 ec 08             	sub    $0x8,%esp
  801e55:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e5e:	75 07                	jne    801e67 <devcons_read+0x18>
  801e60:	eb 1f                	jmp    801e81 <devcons_read+0x32>
		sys_yield();
  801e62:	e8 67 ed ff ff       	call   800bce <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e67:	e8 e3 ec ff ff       	call   800b4f <sys_cgetc>
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	74 f2                	je     801e62 <devcons_read+0x13>
	if (c < 0)
  801e70:	78 0f                	js     801e81 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801e72:	83 f8 04             	cmp    $0x4,%eax
  801e75:	74 0c                	je     801e83 <devcons_read+0x34>
	*(char*)vbuf = c;
  801e77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e7a:	88 02                	mov    %al,(%edx)
	return 1;
  801e7c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    
		return 0;
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
  801e88:	eb f7                	jmp    801e81 <devcons_read+0x32>

00801e8a <cputchar>:
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e90:	8b 45 08             	mov    0x8(%ebp),%eax
  801e93:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e96:	6a 01                	push   $0x1
  801e98:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e9b:	50                   	push   %eax
  801e9c:	e8 90 ec ff ff       	call   800b31 <sys_cputs>
}
  801ea1:	83 c4 10             	add    $0x10,%esp
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <getchar>:
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801eac:	6a 01                	push   $0x1
  801eae:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb1:	50                   	push   %eax
  801eb2:	6a 00                	push   $0x0
  801eb4:	e8 66 f2 ff ff       	call   80111f <read>
	if (r < 0)
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 06                	js     801ec6 <getchar+0x20>
	if (r < 1)
  801ec0:	74 06                	je     801ec8 <getchar+0x22>
	return c;
  801ec2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    
		return -E_EOF;
  801ec8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ecd:	eb f7                	jmp    801ec6 <getchar+0x20>

00801ecf <iscons>:
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed8:	50                   	push   %eax
  801ed9:	ff 75 08             	push   0x8(%ebp)
  801edc:	e8 d5 ef ff ff       	call   800eb6 <fd_lookup>
  801ee1:	83 c4 10             	add    $0x10,%esp
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 11                	js     801ef9 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eeb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ef1:	39 10                	cmp    %edx,(%eax)
  801ef3:	0f 94 c0             	sete   %al
  801ef6:	0f b6 c0             	movzbl %al,%eax
}
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <opencons>:
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f04:	50                   	push   %eax
  801f05:	e8 5c ef ff ff       	call   800e66 <fd_alloc>
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	78 3a                	js     801f4b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f11:	83 ec 04             	sub    $0x4,%esp
  801f14:	68 07 04 00 00       	push   $0x407
  801f19:	ff 75 f4             	push   -0xc(%ebp)
  801f1c:	6a 00                	push   $0x0
  801f1e:	e8 ca ec ff ff       	call   800bed <sys_page_alloc>
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 21                	js     801f4b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f33:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f38:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f3f:	83 ec 0c             	sub    $0xc,%esp
  801f42:	50                   	push   %eax
  801f43:	e8 f7 ee ff ff       	call   800e3f <fd2num>
  801f48:	83 c4 10             	add    $0x10,%esp
}
  801f4b:	c9                   	leave  
  801f4c:	c3                   	ret    

00801f4d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	56                   	push   %esi
  801f51:	53                   	push   %ebx
  801f52:	8b 75 08             	mov    0x8(%ebp),%esi
  801f55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f62:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f65:	83 ec 0c             	sub    $0xc,%esp
  801f68:	50                   	push   %eax
  801f69:	e8 2f ee ff ff       	call   800d9d <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	85 f6                	test   %esi,%esi
  801f73:	74 14                	je     801f89 <ipc_recv+0x3c>
  801f75:	ba 00 00 00 00       	mov    $0x0,%edx
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	78 09                	js     801f87 <ipc_recv+0x3a>
  801f7e:	8b 15 00 40 c0 00    	mov    0xc04000,%edx
  801f84:	8b 52 74             	mov    0x74(%edx),%edx
  801f87:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f89:	85 db                	test   %ebx,%ebx
  801f8b:	74 14                	je     801fa1 <ipc_recv+0x54>
  801f8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f92:	85 c0                	test   %eax,%eax
  801f94:	78 09                	js     801f9f <ipc_recv+0x52>
  801f96:	8b 15 00 40 c0 00    	mov    0xc04000,%edx
  801f9c:	8b 52 78             	mov    0x78(%edx),%edx
  801f9f:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	78 08                	js     801fad <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801fa5:	a1 00 40 c0 00       	mov    0xc04000,%eax
  801faa:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb0:	5b                   	pop    %ebx
  801fb1:	5e                   	pop    %esi
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    

00801fb4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	57                   	push   %edi
  801fb8:	56                   	push   %esi
  801fb9:	53                   	push   %ebx
  801fba:	83 ec 0c             	sub    $0xc,%esp
  801fbd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801fc6:	85 db                	test   %ebx,%ebx
  801fc8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fcd:	0f 44 d8             	cmove  %eax,%ebx
  801fd0:	eb 05                	jmp    801fd7 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fd2:	e8 f7 eb ff ff       	call   800bce <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801fd7:	ff 75 14             	push   0x14(%ebp)
  801fda:	53                   	push   %ebx
  801fdb:	56                   	push   %esi
  801fdc:	57                   	push   %edi
  801fdd:	e8 98 ed ff ff       	call   800d7a <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe8:	74 e8                	je     801fd2 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801fea:	85 c0                	test   %eax,%eax
  801fec:	78 08                	js     801ff6 <ipc_send+0x42>
	}while (r<0);

}
  801fee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff1:	5b                   	pop    %ebx
  801ff2:	5e                   	pop    %esi
  801ff3:	5f                   	pop    %edi
  801ff4:	5d                   	pop    %ebp
  801ff5:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ff6:	50                   	push   %eax
  801ff7:	68 f3 27 80 00       	push   $0x8027f3
  801ffc:	6a 3d                	push   $0x3d
  801ffe:	68 07 28 80 00       	push   $0x802807
  802003:	e8 34 e1 ff ff       	call   80013c <_panic>

00802008 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80200e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802013:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802016:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80201c:	8b 52 50             	mov    0x50(%edx),%edx
  80201f:	39 ca                	cmp    %ecx,%edx
  802021:	74 11                	je     802034 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802023:	83 c0 01             	add    $0x1,%eax
  802026:	3d 00 04 00 00       	cmp    $0x400,%eax
  80202b:	75 e6                	jne    802013 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80202d:	b8 00 00 00 00       	mov    $0x0,%eax
  802032:	eb 0b                	jmp    80203f <ipc_find_env+0x37>
			return envs[i].env_id;
  802034:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802037:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80203c:	8b 40 48             	mov    0x48(%eax),%eax
}
  80203f:	5d                   	pop    %ebp
  802040:	c3                   	ret    

00802041 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
  802044:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802047:	89 c2                	mov    %eax,%edx
  802049:	c1 ea 16             	shr    $0x16,%edx
  80204c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802053:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802058:	f6 c1 01             	test   $0x1,%cl
  80205b:	74 1c                	je     802079 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80205d:	c1 e8 0c             	shr    $0xc,%eax
  802060:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802067:	a8 01                	test   $0x1,%al
  802069:	74 0e                	je     802079 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80206b:	c1 e8 0c             	shr    $0xc,%eax
  80206e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802075:	ef 
  802076:	0f b7 d2             	movzwl %dx,%edx
}
  802079:	89 d0                	mov    %edx,%eax
  80207b:	5d                   	pop    %ebp
  80207c:	c3                   	ret    
  80207d:	66 90                	xchg   %ax,%ax
  80207f:	90                   	nop

00802080 <__udivdi3>:
  802080:	f3 0f 1e fb          	endbr32 
  802084:	55                   	push   %ebp
  802085:	57                   	push   %edi
  802086:	56                   	push   %esi
  802087:	53                   	push   %ebx
  802088:	83 ec 1c             	sub    $0x1c,%esp
  80208b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80208f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802093:	8b 74 24 34          	mov    0x34(%esp),%esi
  802097:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80209b:	85 c0                	test   %eax,%eax
  80209d:	75 19                	jne    8020b8 <__udivdi3+0x38>
  80209f:	39 f3                	cmp    %esi,%ebx
  8020a1:	76 4d                	jbe    8020f0 <__udivdi3+0x70>
  8020a3:	31 ff                	xor    %edi,%edi
  8020a5:	89 e8                	mov    %ebp,%eax
  8020a7:	89 f2                	mov    %esi,%edx
  8020a9:	f7 f3                	div    %ebx
  8020ab:	89 fa                	mov    %edi,%edx
  8020ad:	83 c4 1c             	add    $0x1c,%esp
  8020b0:	5b                   	pop    %ebx
  8020b1:	5e                   	pop    %esi
  8020b2:	5f                   	pop    %edi
  8020b3:	5d                   	pop    %ebp
  8020b4:	c3                   	ret    
  8020b5:	8d 76 00             	lea    0x0(%esi),%esi
  8020b8:	39 f0                	cmp    %esi,%eax
  8020ba:	76 14                	jbe    8020d0 <__udivdi3+0x50>
  8020bc:	31 ff                	xor    %edi,%edi
  8020be:	31 c0                	xor    %eax,%eax
  8020c0:	89 fa                	mov    %edi,%edx
  8020c2:	83 c4 1c             	add    $0x1c,%esp
  8020c5:	5b                   	pop    %ebx
  8020c6:	5e                   	pop    %esi
  8020c7:	5f                   	pop    %edi
  8020c8:	5d                   	pop    %ebp
  8020c9:	c3                   	ret    
  8020ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d0:	0f bd f8             	bsr    %eax,%edi
  8020d3:	83 f7 1f             	xor    $0x1f,%edi
  8020d6:	75 48                	jne    802120 <__udivdi3+0xa0>
  8020d8:	39 f0                	cmp    %esi,%eax
  8020da:	72 06                	jb     8020e2 <__udivdi3+0x62>
  8020dc:	31 c0                	xor    %eax,%eax
  8020de:	39 eb                	cmp    %ebp,%ebx
  8020e0:	77 de                	ja     8020c0 <__udivdi3+0x40>
  8020e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e7:	eb d7                	jmp    8020c0 <__udivdi3+0x40>
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	89 d9                	mov    %ebx,%ecx
  8020f2:	85 db                	test   %ebx,%ebx
  8020f4:	75 0b                	jne    802101 <__udivdi3+0x81>
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f3                	div    %ebx
  8020ff:	89 c1                	mov    %eax,%ecx
  802101:	31 d2                	xor    %edx,%edx
  802103:	89 f0                	mov    %esi,%eax
  802105:	f7 f1                	div    %ecx
  802107:	89 c6                	mov    %eax,%esi
  802109:	89 e8                	mov    %ebp,%eax
  80210b:	89 f7                	mov    %esi,%edi
  80210d:	f7 f1                	div    %ecx
  80210f:	89 fa                	mov    %edi,%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 f9                	mov    %edi,%ecx
  802122:	ba 20 00 00 00       	mov    $0x20,%edx
  802127:	29 fa                	sub    %edi,%edx
  802129:	d3 e0                	shl    %cl,%eax
  80212b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80212f:	89 d1                	mov    %edx,%ecx
  802131:	89 d8                	mov    %ebx,%eax
  802133:	d3 e8                	shr    %cl,%eax
  802135:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802139:	09 c1                	or     %eax,%ecx
  80213b:	89 f0                	mov    %esi,%eax
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 e3                	shl    %cl,%ebx
  802145:	89 d1                	mov    %edx,%ecx
  802147:	d3 e8                	shr    %cl,%eax
  802149:	89 f9                	mov    %edi,%ecx
  80214b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80214f:	89 eb                	mov    %ebp,%ebx
  802151:	d3 e6                	shl    %cl,%esi
  802153:	89 d1                	mov    %edx,%ecx
  802155:	d3 eb                	shr    %cl,%ebx
  802157:	09 f3                	or     %esi,%ebx
  802159:	89 c6                	mov    %eax,%esi
  80215b:	89 f2                	mov    %esi,%edx
  80215d:	89 d8                	mov    %ebx,%eax
  80215f:	f7 74 24 08          	divl   0x8(%esp)
  802163:	89 d6                	mov    %edx,%esi
  802165:	89 c3                	mov    %eax,%ebx
  802167:	f7 64 24 0c          	mull   0xc(%esp)
  80216b:	39 d6                	cmp    %edx,%esi
  80216d:	72 19                	jb     802188 <__udivdi3+0x108>
  80216f:	89 f9                	mov    %edi,%ecx
  802171:	d3 e5                	shl    %cl,%ebp
  802173:	39 c5                	cmp    %eax,%ebp
  802175:	73 04                	jae    80217b <__udivdi3+0xfb>
  802177:	39 d6                	cmp    %edx,%esi
  802179:	74 0d                	je     802188 <__udivdi3+0x108>
  80217b:	89 d8                	mov    %ebx,%eax
  80217d:	31 ff                	xor    %edi,%edi
  80217f:	e9 3c ff ff ff       	jmp    8020c0 <__udivdi3+0x40>
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80218b:	31 ff                	xor    %edi,%edi
  80218d:	e9 2e ff ff ff       	jmp    8020c0 <__udivdi3+0x40>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	f3 0f 1e fb          	endbr32 
  8021a4:	55                   	push   %ebp
  8021a5:	57                   	push   %edi
  8021a6:	56                   	push   %esi
  8021a7:	53                   	push   %ebx
  8021a8:	83 ec 1c             	sub    $0x1c,%esp
  8021ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021b3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8021b7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8021bb:	89 f0                	mov    %esi,%eax
  8021bd:	89 da                	mov    %ebx,%edx
  8021bf:	85 ff                	test   %edi,%edi
  8021c1:	75 15                	jne    8021d8 <__umoddi3+0x38>
  8021c3:	39 dd                	cmp    %ebx,%ebp
  8021c5:	76 39                	jbe    802200 <__umoddi3+0x60>
  8021c7:	f7 f5                	div    %ebp
  8021c9:	89 d0                	mov    %edx,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	83 c4 1c             	add    $0x1c,%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    
  8021d5:	8d 76 00             	lea    0x0(%esi),%esi
  8021d8:	39 df                	cmp    %ebx,%edi
  8021da:	77 f1                	ja     8021cd <__umoddi3+0x2d>
  8021dc:	0f bd cf             	bsr    %edi,%ecx
  8021df:	83 f1 1f             	xor    $0x1f,%ecx
  8021e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021e6:	75 40                	jne    802228 <__umoddi3+0x88>
  8021e8:	39 df                	cmp    %ebx,%edi
  8021ea:	72 04                	jb     8021f0 <__umoddi3+0x50>
  8021ec:	39 f5                	cmp    %esi,%ebp
  8021ee:	77 dd                	ja     8021cd <__umoddi3+0x2d>
  8021f0:	89 da                	mov    %ebx,%edx
  8021f2:	89 f0                	mov    %esi,%eax
  8021f4:	29 e8                	sub    %ebp,%eax
  8021f6:	19 fa                	sbb    %edi,%edx
  8021f8:	eb d3                	jmp    8021cd <__umoddi3+0x2d>
  8021fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802200:	89 e9                	mov    %ebp,%ecx
  802202:	85 ed                	test   %ebp,%ebp
  802204:	75 0b                	jne    802211 <__umoddi3+0x71>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f5                	div    %ebp
  80220f:	89 c1                	mov    %eax,%ecx
  802211:	89 d8                	mov    %ebx,%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	f7 f1                	div    %ecx
  802217:	89 f0                	mov    %esi,%eax
  802219:	f7 f1                	div    %ecx
  80221b:	89 d0                	mov    %edx,%eax
  80221d:	31 d2                	xor    %edx,%edx
  80221f:	eb ac                	jmp    8021cd <__umoddi3+0x2d>
  802221:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802228:	8b 44 24 04          	mov    0x4(%esp),%eax
  80222c:	ba 20 00 00 00       	mov    $0x20,%edx
  802231:	29 c2                	sub    %eax,%edx
  802233:	89 c1                	mov    %eax,%ecx
  802235:	89 e8                	mov    %ebp,%eax
  802237:	d3 e7                	shl    %cl,%edi
  802239:	89 d1                	mov    %edx,%ecx
  80223b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80223f:	d3 e8                	shr    %cl,%eax
  802241:	89 c1                	mov    %eax,%ecx
  802243:	8b 44 24 04          	mov    0x4(%esp),%eax
  802247:	09 f9                	or     %edi,%ecx
  802249:	89 df                	mov    %ebx,%edi
  80224b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224f:	89 c1                	mov    %eax,%ecx
  802251:	d3 e5                	shl    %cl,%ebp
  802253:	89 d1                	mov    %edx,%ecx
  802255:	d3 ef                	shr    %cl,%edi
  802257:	89 c1                	mov    %eax,%ecx
  802259:	89 f0                	mov    %esi,%eax
  80225b:	d3 e3                	shl    %cl,%ebx
  80225d:	89 d1                	mov    %edx,%ecx
  80225f:	89 fa                	mov    %edi,%edx
  802261:	d3 e8                	shr    %cl,%eax
  802263:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802268:	09 d8                	or     %ebx,%eax
  80226a:	f7 74 24 08          	divl   0x8(%esp)
  80226e:	89 d3                	mov    %edx,%ebx
  802270:	d3 e6                	shl    %cl,%esi
  802272:	f7 e5                	mul    %ebp
  802274:	89 c7                	mov    %eax,%edi
  802276:	89 d1                	mov    %edx,%ecx
  802278:	39 d3                	cmp    %edx,%ebx
  80227a:	72 06                	jb     802282 <__umoddi3+0xe2>
  80227c:	75 0e                	jne    80228c <__umoddi3+0xec>
  80227e:	39 c6                	cmp    %eax,%esi
  802280:	73 0a                	jae    80228c <__umoddi3+0xec>
  802282:	29 e8                	sub    %ebp,%eax
  802284:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802288:	89 d1                	mov    %edx,%ecx
  80228a:	89 c7                	mov    %eax,%edi
  80228c:	89 f5                	mov    %esi,%ebp
  80228e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802292:	29 fd                	sub    %edi,%ebp
  802294:	19 cb                	sbb    %ecx,%ebx
  802296:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80229b:	89 d8                	mov    %ebx,%eax
  80229d:	d3 e0                	shl    %cl,%eax
  80229f:	89 f1                	mov    %esi,%ecx
  8022a1:	d3 ed                	shr    %cl,%ebp
  8022a3:	d3 eb                	shr    %cl,%ebx
  8022a5:	09 e8                	or     %ebp,%eax
  8022a7:	89 da                	mov    %ebx,%edx
  8022a9:	83 c4 1c             	add    $0x1c,%esp
  8022ac:	5b                   	pop    %ebx
  8022ad:	5e                   	pop    %esi
  8022ae:	5f                   	pop    %edi
  8022af:	5d                   	pop    %ebp
  8022b0:	c3                   	ret    
