
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
  800039:	68 00 1e 80 00       	push   $0x801e00
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
  800090:	68 48 1e 80 00       	push   $0x801e48
  800095:	e8 7d 01 00 00       	call   800217 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009a:	c7 05 00 50 c0 00 00 	movl   $0x0,0xc05000
  8000a1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	68 a7 1e 80 00       	push   $0x801ea7
  8000ac:	6a 1a                	push   $0x1a
  8000ae:	68 98 1e 80 00       	push   $0x801e98
  8000b3:	e8 84 00 00 00       	call   80013c <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b8:	50                   	push   %eax
  8000b9:	68 7b 1e 80 00       	push   $0x801e7b
  8000be:	6a 11                	push   $0x11
  8000c0:	68 98 1e 80 00       	push   $0x801e98
  8000c5:	e8 72 00 00 00       	call   80013c <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ca:	50                   	push   %eax
  8000cb:	68 20 1e 80 00       	push   $0x801e20
  8000d0:	6a 16                	push   $0x16
  8000d2:	68 98 1e 80 00       	push   $0x801e98
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
  800128:	e8 7d 0e 00 00       	call   800faa <close_all>
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
  80015a:	68 c8 1e 80 00       	push   $0x801ec8
  80015f:	e8 b3 00 00 00       	call   800217 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	push   0x10(%ebp)
  80016b:	e8 56 00 00 00       	call   8001c6 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 96 1e 80 00 	movl   $0x801e96,(%esp)
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
  800279:	e8 32 19 00 00       	call   801bb0 <__udivdi3>
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
  8002b7:	e8 14 1a 00 00       	call   801cd0 <__umoddi3>
  8002bc:	83 c4 14             	add    $0x14,%esp
  8002bf:	0f be 80 eb 1e 80 00 	movsbl 0x801eeb(%eax),%eax
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
  800379:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
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
  800447:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	74 18                	je     80046a <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800452:	52                   	push   %edx
  800453:	68 b1 22 80 00       	push   $0x8022b1
  800458:	53                   	push   %ebx
  800459:	56                   	push   %esi
  80045a:	e8 92 fe ff ff       	call   8002f1 <printfmt>
  80045f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800462:	89 7d 14             	mov    %edi,0x14(%ebp)
  800465:	e9 66 02 00 00       	jmp    8006d0 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 03 1f 80 00       	push   $0x801f03
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
  800492:	b8 fc 1e 80 00       	mov    $0x801efc,%eax
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
  800b9e:	68 df 21 80 00       	push   $0x8021df
  800ba3:	6a 2a                	push   $0x2a
  800ba5:	68 fc 21 80 00       	push   $0x8021fc
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
  800c1f:	68 df 21 80 00       	push   $0x8021df
  800c24:	6a 2a                	push   $0x2a
  800c26:	68 fc 21 80 00       	push   $0x8021fc
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
  800c61:	68 df 21 80 00       	push   $0x8021df
  800c66:	6a 2a                	push   $0x2a
  800c68:	68 fc 21 80 00       	push   $0x8021fc
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
  800ca3:	68 df 21 80 00       	push   $0x8021df
  800ca8:	6a 2a                	push   $0x2a
  800caa:	68 fc 21 80 00       	push   $0x8021fc
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
  800ce5:	68 df 21 80 00       	push   $0x8021df
  800cea:	6a 2a                	push   $0x2a
  800cec:	68 fc 21 80 00       	push   $0x8021fc
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
  800d27:	68 df 21 80 00       	push   $0x8021df
  800d2c:	6a 2a                	push   $0x2a
  800d2e:	68 fc 21 80 00       	push   $0x8021fc
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
  800d69:	68 df 21 80 00       	push   $0x8021df
  800d6e:	6a 2a                	push   $0x2a
  800d70:	68 fc 21 80 00       	push   $0x8021fc
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
  800dcd:	68 df 21 80 00       	push   $0x8021df
  800dd2:	6a 2a                	push   $0x2a
  800dd4:	68 fc 21 80 00       	push   $0x8021fc
  800dd9:	e8 5e f3 ff ff       	call   80013c <_panic>

00800dde <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de1:	8b 45 08             	mov    0x8(%ebp),%eax
  800de4:	05 00 00 00 30       	add    $0x30000000,%eax
  800de9:	c1 e8 0c             	shr    $0xc,%eax
}
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800df9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dfe:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 16             	shr    $0x16,%edx
  800e12:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e19:	f6 c2 01             	test   $0x1,%dl
  800e1c:	74 29                	je     800e47 <fd_alloc+0x42>
  800e1e:	89 c2                	mov    %eax,%edx
  800e20:	c1 ea 0c             	shr    $0xc,%edx
  800e23:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2a:	f6 c2 01             	test   $0x1,%dl
  800e2d:	74 18                	je     800e47 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e2f:	05 00 10 00 00       	add    $0x1000,%eax
  800e34:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e39:	75 d2                	jne    800e0d <fd_alloc+0x8>
  800e3b:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800e40:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800e45:	eb 05                	jmp    800e4c <fd_alloc+0x47>
			return 0;
  800e47:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800e4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4f:	89 02                	mov    %eax,(%edx)
}
  800e51:	89 c8                	mov    %ecx,%eax
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e5b:	83 f8 1f             	cmp    $0x1f,%eax
  800e5e:	77 30                	ja     800e90 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e60:	c1 e0 0c             	shl    $0xc,%eax
  800e63:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e68:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e6e:	f6 c2 01             	test   $0x1,%dl
  800e71:	74 24                	je     800e97 <fd_lookup+0x42>
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	c1 ea 0c             	shr    $0xc,%edx
  800e78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7f:	f6 c2 01             	test   $0x1,%dl
  800e82:	74 1a                	je     800e9e <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e87:	89 02                	mov    %eax,(%edx)
	return 0;
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    
		return -E_INVAL;
  800e90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e95:	eb f7                	jmp    800e8e <fd_lookup+0x39>
		return -E_INVAL;
  800e97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9c:	eb f0                	jmp    800e8e <fd_lookup+0x39>
  800e9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea3:	eb e9                	jmp    800e8e <fd_lookup+0x39>

00800ea5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	b8 88 22 80 00       	mov    $0x802288,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800eb4:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800eb9:	39 13                	cmp    %edx,(%ebx)
  800ebb:	74 32                	je     800eef <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800ebd:	83 c0 04             	add    $0x4,%eax
  800ec0:	8b 18                	mov    (%eax),%ebx
  800ec2:	85 db                	test   %ebx,%ebx
  800ec4:	75 f3                	jne    800eb9 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec6:	a1 00 40 c0 00       	mov    0xc04000,%eax
  800ecb:	8b 40 48             	mov    0x48(%eax),%eax
  800ece:	83 ec 04             	sub    $0x4,%esp
  800ed1:	52                   	push   %edx
  800ed2:	50                   	push   %eax
  800ed3:	68 0c 22 80 00       	push   $0x80220c
  800ed8:	e8 3a f3 ff ff       	call   800217 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800ee5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee8:	89 1a                	mov    %ebx,(%edx)
}
  800eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    
			return 0;
  800eef:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef4:	eb ef                	jmp    800ee5 <dev_lookup+0x40>

00800ef6 <fd_close>:
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	83 ec 24             	sub    $0x24,%esp
  800eff:	8b 75 08             	mov    0x8(%ebp),%esi
  800f02:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f05:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f08:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f09:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f0f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f12:	50                   	push   %eax
  800f13:	e8 3d ff ff ff       	call   800e55 <fd_lookup>
  800f18:	89 c3                	mov    %eax,%ebx
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	78 05                	js     800f26 <fd_close+0x30>
	    || fd != fd2)
  800f21:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f24:	74 16                	je     800f3c <fd_close+0x46>
		return (must_exist ? r : 0);
  800f26:	89 f8                	mov    %edi,%eax
  800f28:	84 c0                	test   %al,%al
  800f2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2f:	0f 44 d8             	cmove  %eax,%ebx
}
  800f32:	89 d8                	mov    %ebx,%eax
  800f34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f37:	5b                   	pop    %ebx
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f3c:	83 ec 08             	sub    $0x8,%esp
  800f3f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f42:	50                   	push   %eax
  800f43:	ff 36                	push   (%esi)
  800f45:	e8 5b ff ff ff       	call   800ea5 <dev_lookup>
  800f4a:	89 c3                	mov    %eax,%ebx
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	78 1a                	js     800f6d <fd_close+0x77>
		if (dev->dev_close)
  800f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f56:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f59:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	74 0b                	je     800f6d <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f62:	83 ec 0c             	sub    $0xc,%esp
  800f65:	56                   	push   %esi
  800f66:	ff d0                	call   *%eax
  800f68:	89 c3                	mov    %eax,%ebx
  800f6a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f6d:	83 ec 08             	sub    $0x8,%esp
  800f70:	56                   	push   %esi
  800f71:	6a 00                	push   $0x0
  800f73:	e8 fa fc ff ff       	call   800c72 <sys_page_unmap>
	return r;
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	eb b5                	jmp    800f32 <fd_close+0x3c>

00800f7d <close>:

int
close(int fdnum)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f86:	50                   	push   %eax
  800f87:	ff 75 08             	push   0x8(%ebp)
  800f8a:	e8 c6 fe ff ff       	call   800e55 <fd_lookup>
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	79 02                	jns    800f98 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f96:	c9                   	leave  
  800f97:	c3                   	ret    
		return fd_close(fd, 1);
  800f98:	83 ec 08             	sub    $0x8,%esp
  800f9b:	6a 01                	push   $0x1
  800f9d:	ff 75 f4             	push   -0xc(%ebp)
  800fa0:	e8 51 ff ff ff       	call   800ef6 <fd_close>
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	eb ec                	jmp    800f96 <close+0x19>

00800faa <close_all>:

void
close_all(void)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	53                   	push   %ebx
  800fae:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	53                   	push   %ebx
  800fba:	e8 be ff ff ff       	call   800f7d <close>
	for (i = 0; i < MAXFD; i++)
  800fbf:	83 c3 01             	add    $0x1,%ebx
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	83 fb 20             	cmp    $0x20,%ebx
  800fc8:	75 ec                	jne    800fb6 <close_all+0xc>
}
  800fca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
  800fd5:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	ff 75 08             	push   0x8(%ebp)
  800fdf:	e8 71 fe ff ff       	call   800e55 <fd_lookup>
  800fe4:	89 c3                	mov    %eax,%ebx
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 7f                	js     80106c <dup+0x9d>
		return r;
	close(newfdnum);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	ff 75 0c             	push   0xc(%ebp)
  800ff3:	e8 85 ff ff ff       	call   800f7d <close>

	newfd = INDEX2FD(newfdnum);
  800ff8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ffb:	c1 e6 0c             	shl    $0xc,%esi
  800ffe:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801004:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801007:	89 3c 24             	mov    %edi,(%esp)
  80100a:	e8 df fd ff ff       	call   800dee <fd2data>
  80100f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801011:	89 34 24             	mov    %esi,(%esp)
  801014:	e8 d5 fd ff ff       	call   800dee <fd2data>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80101f:	89 d8                	mov    %ebx,%eax
  801021:	c1 e8 16             	shr    $0x16,%eax
  801024:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102b:	a8 01                	test   $0x1,%al
  80102d:	74 11                	je     801040 <dup+0x71>
  80102f:	89 d8                	mov    %ebx,%eax
  801031:	c1 e8 0c             	shr    $0xc,%eax
  801034:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103b:	f6 c2 01             	test   $0x1,%dl
  80103e:	75 36                	jne    801076 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801040:	89 f8                	mov    %edi,%eax
  801042:	c1 e8 0c             	shr    $0xc,%eax
  801045:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	25 07 0e 00 00       	and    $0xe07,%eax
  801054:	50                   	push   %eax
  801055:	56                   	push   %esi
  801056:	6a 00                	push   $0x0
  801058:	57                   	push   %edi
  801059:	6a 00                	push   $0x0
  80105b:	e8 d0 fb ff ff       	call   800c30 <sys_page_map>
  801060:	89 c3                	mov    %eax,%ebx
  801062:	83 c4 20             	add    $0x20,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	78 33                	js     80109c <dup+0xcd>
		goto err;

	return newfdnum;
  801069:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801076:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107d:	83 ec 0c             	sub    $0xc,%esp
  801080:	25 07 0e 00 00       	and    $0xe07,%eax
  801085:	50                   	push   %eax
  801086:	ff 75 d4             	push   -0x2c(%ebp)
  801089:	6a 00                	push   $0x0
  80108b:	53                   	push   %ebx
  80108c:	6a 00                	push   $0x0
  80108e:	e8 9d fb ff ff       	call   800c30 <sys_page_map>
  801093:	89 c3                	mov    %eax,%ebx
  801095:	83 c4 20             	add    $0x20,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	79 a4                	jns    801040 <dup+0x71>
	sys_page_unmap(0, newfd);
  80109c:	83 ec 08             	sub    $0x8,%esp
  80109f:	56                   	push   %esi
  8010a0:	6a 00                	push   $0x0
  8010a2:	e8 cb fb ff ff       	call   800c72 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010a7:	83 c4 08             	add    $0x8,%esp
  8010aa:	ff 75 d4             	push   -0x2c(%ebp)
  8010ad:	6a 00                	push   $0x0
  8010af:	e8 be fb ff ff       	call   800c72 <sys_page_unmap>
	return r;
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	eb b3                	jmp    80106c <dup+0x9d>

008010b9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 18             	sub    $0x18,%esp
  8010c1:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c7:	50                   	push   %eax
  8010c8:	56                   	push   %esi
  8010c9:	e8 87 fd ff ff       	call   800e55 <fd_lookup>
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	78 3c                	js     801111 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8010d8:	83 ec 08             	sub    $0x8,%esp
  8010db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010de:	50                   	push   %eax
  8010df:	ff 33                	push   (%ebx)
  8010e1:	e8 bf fd ff ff       	call   800ea5 <dev_lookup>
  8010e6:	83 c4 10             	add    $0x10,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	78 24                	js     801111 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010ed:	8b 43 08             	mov    0x8(%ebx),%eax
  8010f0:	83 e0 03             	and    $0x3,%eax
  8010f3:	83 f8 01             	cmp    $0x1,%eax
  8010f6:	74 20                	je     801118 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010fb:	8b 40 08             	mov    0x8(%eax),%eax
  8010fe:	85 c0                	test   %eax,%eax
  801100:	74 37                	je     801139 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801102:	83 ec 04             	sub    $0x4,%esp
  801105:	ff 75 10             	push   0x10(%ebp)
  801108:	ff 75 0c             	push   0xc(%ebp)
  80110b:	53                   	push   %ebx
  80110c:	ff d0                	call   *%eax
  80110e:	83 c4 10             	add    $0x10,%esp
}
  801111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801118:	a1 00 40 c0 00       	mov    0xc04000,%eax
  80111d:	8b 40 48             	mov    0x48(%eax),%eax
  801120:	83 ec 04             	sub    $0x4,%esp
  801123:	56                   	push   %esi
  801124:	50                   	push   %eax
  801125:	68 4d 22 80 00       	push   $0x80224d
  80112a:	e8 e8 f0 ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801137:	eb d8                	jmp    801111 <read+0x58>
		return -E_NOT_SUPP;
  801139:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80113e:	eb d1                	jmp    801111 <read+0x58>

00801140 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	83 ec 0c             	sub    $0xc,%esp
  801149:	8b 7d 08             	mov    0x8(%ebp),%edi
  80114c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801154:	eb 02                	jmp    801158 <readn+0x18>
  801156:	01 c3                	add    %eax,%ebx
  801158:	39 f3                	cmp    %esi,%ebx
  80115a:	73 21                	jae    80117d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80115c:	83 ec 04             	sub    $0x4,%esp
  80115f:	89 f0                	mov    %esi,%eax
  801161:	29 d8                	sub    %ebx,%eax
  801163:	50                   	push   %eax
  801164:	89 d8                	mov    %ebx,%eax
  801166:	03 45 0c             	add    0xc(%ebp),%eax
  801169:	50                   	push   %eax
  80116a:	57                   	push   %edi
  80116b:	e8 49 ff ff ff       	call   8010b9 <read>
		if (m < 0)
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	78 04                	js     80117b <readn+0x3b>
			return m;
		if (m == 0)
  801177:	75 dd                	jne    801156 <readn+0x16>
  801179:	eb 02                	jmp    80117d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80117b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80117d:	89 d8                	mov    %ebx,%eax
  80117f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	56                   	push   %esi
  80118b:	53                   	push   %ebx
  80118c:	83 ec 18             	sub    $0x18,%esp
  80118f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801192:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	53                   	push   %ebx
  801197:	e8 b9 fc ff ff       	call   800e55 <fd_lookup>
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 37                	js     8011da <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ac:	50                   	push   %eax
  8011ad:	ff 36                	push   (%esi)
  8011af:	e8 f1 fc ff ff       	call   800ea5 <dev_lookup>
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 1f                	js     8011da <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011bb:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011bf:	74 20                	je     8011e1 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	74 37                	je     801202 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	ff 75 10             	push   0x10(%ebp)
  8011d1:	ff 75 0c             	push   0xc(%ebp)
  8011d4:	56                   	push   %esi
  8011d5:	ff d0                	call   *%eax
  8011d7:	83 c4 10             	add    $0x10,%esp
}
  8011da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e1:	a1 00 40 c0 00       	mov    0xc04000,%eax
  8011e6:	8b 40 48             	mov    0x48(%eax),%eax
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	53                   	push   %ebx
  8011ed:	50                   	push   %eax
  8011ee:	68 69 22 80 00       	push   $0x802269
  8011f3:	e8 1f f0 ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801200:	eb d8                	jmp    8011da <write+0x53>
		return -E_NOT_SUPP;
  801202:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801207:	eb d1                	jmp    8011da <write+0x53>

00801209 <seek>:

int
seek(int fdnum, off_t offset)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80120f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	ff 75 08             	push   0x8(%ebp)
  801216:	e8 3a fc ff ff       	call   800e55 <fd_lookup>
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 0e                	js     801230 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801222:	8b 55 0c             	mov    0xc(%ebp),%edx
  801225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801228:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	56                   	push   %esi
  801236:	53                   	push   %ebx
  801237:	83 ec 18             	sub    $0x18,%esp
  80123a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801240:	50                   	push   %eax
  801241:	53                   	push   %ebx
  801242:	e8 0e fc ff ff       	call   800e55 <fd_lookup>
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	78 34                	js     801282 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801251:	83 ec 08             	sub    $0x8,%esp
  801254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801257:	50                   	push   %eax
  801258:	ff 36                	push   (%esi)
  80125a:	e8 46 fc ff ff       	call   800ea5 <dev_lookup>
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	85 c0                	test   %eax,%eax
  801264:	78 1c                	js     801282 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801266:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80126a:	74 1d                	je     801289 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80126c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80126f:	8b 40 18             	mov    0x18(%eax),%eax
  801272:	85 c0                	test   %eax,%eax
  801274:	74 34                	je     8012aa <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	ff 75 0c             	push   0xc(%ebp)
  80127c:	56                   	push   %esi
  80127d:	ff d0                	call   *%eax
  80127f:	83 c4 10             	add    $0x10,%esp
}
  801282:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    
			thisenv->env_id, fdnum);
  801289:	a1 00 40 c0 00       	mov    0xc04000,%eax
  80128e:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801291:	83 ec 04             	sub    $0x4,%esp
  801294:	53                   	push   %ebx
  801295:	50                   	push   %eax
  801296:	68 2c 22 80 00       	push   $0x80222c
  80129b:	e8 77 ef ff ff       	call   800217 <cprintf>
		return -E_INVAL;
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a8:	eb d8                	jmp    801282 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8012aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012af:	eb d1                	jmp    801282 <ftruncate+0x50>

008012b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
  8012b6:	83 ec 18             	sub    $0x18,%esp
  8012b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012bf:	50                   	push   %eax
  8012c0:	ff 75 08             	push   0x8(%ebp)
  8012c3:	e8 8d fb ff ff       	call   800e55 <fd_lookup>
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 49                	js     801318 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cf:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 36                	push   (%esi)
  8012db:	e8 c5 fb ff ff       	call   800ea5 <dev_lookup>
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 31                	js     801318 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8012e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ea:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ee:	74 2f                	je     80131f <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012fa:	00 00 00 
	stat->st_isdir = 0;
  8012fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801304:	00 00 00 
	stat->st_dev = dev;
  801307:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	53                   	push   %ebx
  801311:	56                   	push   %esi
  801312:	ff 50 14             	call   *0x14(%eax)
  801315:	83 c4 10             	add    $0x10,%esp
}
  801318:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    
		return -E_NOT_SUPP;
  80131f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801324:	eb f2                	jmp    801318 <fstat+0x67>

00801326 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80132b:	83 ec 08             	sub    $0x8,%esp
  80132e:	6a 00                	push   $0x0
  801330:	ff 75 08             	push   0x8(%ebp)
  801333:	e8 e4 01 00 00       	call   80151c <open>
  801338:	89 c3                	mov    %eax,%ebx
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 1b                	js     80135c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	ff 75 0c             	push   0xc(%ebp)
  801347:	50                   	push   %eax
  801348:	e8 64 ff ff ff       	call   8012b1 <fstat>
  80134d:	89 c6                	mov    %eax,%esi
	close(fd);
  80134f:	89 1c 24             	mov    %ebx,(%esp)
  801352:	e8 26 fc ff ff       	call   800f7d <close>
	return r;
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	89 f3                	mov    %esi,%ebx
}
  80135c:	89 d8                	mov    %ebx,%eax
  80135e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    

00801365 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	56                   	push   %esi
  801369:	53                   	push   %ebx
  80136a:	89 c6                	mov    %eax,%esi
  80136c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80136e:	83 3d 00 60 c0 00 00 	cmpl   $0x0,0xc06000
  801375:	74 27                	je     80139e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801377:	6a 07                	push   $0x7
  801379:	68 00 50 c0 00       	push   $0xc05000
  80137e:	56                   	push   %esi
  80137f:	ff 35 00 60 c0 00    	push   0xc06000
  801385:	e8 5c 07 00 00       	call   801ae6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80138a:	83 c4 0c             	add    $0xc,%esp
  80138d:	6a 00                	push   $0x0
  80138f:	53                   	push   %ebx
  801390:	6a 00                	push   $0x0
  801392:	e8 e8 06 00 00       	call   801a7f <ipc_recv>
}
  801397:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139a:	5b                   	pop    %ebx
  80139b:	5e                   	pop    %esi
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	6a 01                	push   $0x1
  8013a3:	e8 92 07 00 00       	call   801b3a <ipc_find_env>
  8013a8:	a3 00 60 c0 00       	mov    %eax,0xc06000
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	eb c5                	jmp    801377 <fsipc+0x12>

008013b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013be:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8013c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c6:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8013d5:	e8 8b ff ff ff       	call   801365 <fsipc>
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <devfile_flush>:
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e8:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8013f7:	e8 69 ff ff ff       	call   801365 <fsipc>
}
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <devfile_stat>:
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	53                   	push   %ebx
  801402:	83 ec 04             	sub    $0x4,%esp
  801405:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801408:	8b 45 08             	mov    0x8(%ebp),%eax
  80140b:	8b 40 0c             	mov    0xc(%eax),%eax
  80140e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801413:	ba 00 00 00 00       	mov    $0x0,%edx
  801418:	b8 05 00 00 00       	mov    $0x5,%eax
  80141d:	e8 43 ff ff ff       	call   801365 <fsipc>
  801422:	85 c0                	test   %eax,%eax
  801424:	78 2c                	js     801452 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	68 00 50 c0 00       	push   $0xc05000
  80142e:	53                   	push   %ebx
  80142f:	e8 bd f3 ff ff       	call   8007f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801434:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801439:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80143f:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801444:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801452:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <devfile_write>:
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 0c             	sub    $0xc,%esp
  80145d:	8b 45 10             	mov    0x10(%ebp),%eax
  801460:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801465:	39 d0                	cmp    %edx,%eax
  801467:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80146a:	8b 55 08             	mov    0x8(%ebp),%edx
  80146d:	8b 52 0c             	mov    0xc(%edx),%edx
  801470:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  801476:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80147b:	50                   	push   %eax
  80147c:	ff 75 0c             	push   0xc(%ebp)
  80147f:	68 08 50 c0 00       	push   $0xc05008
  801484:	e8 fe f4 ff ff       	call   800987 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801489:	ba 00 00 00 00       	mov    $0x0,%edx
  80148e:	b8 04 00 00 00       	mov    $0x4,%eax
  801493:	e8 cd fe ff ff       	call   801365 <fsipc>
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <devfile_read>:
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	56                   	push   %esi
  80149e:	53                   	push   %ebx
  80149f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a8:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014ad:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b8:	b8 03 00 00 00       	mov    $0x3,%eax
  8014bd:	e8 a3 fe ff ff       	call   801365 <fsipc>
  8014c2:	89 c3                	mov    %eax,%ebx
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	78 1f                	js     8014e7 <devfile_read+0x4d>
	assert(r <= n);
  8014c8:	39 f0                	cmp    %esi,%eax
  8014ca:	77 24                	ja     8014f0 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8014cc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014d1:	7f 33                	jg     801506 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	50                   	push   %eax
  8014d7:	68 00 50 c0 00       	push   $0xc05000
  8014dc:	ff 75 0c             	push   0xc(%ebp)
  8014df:	e8 a3 f4 ff ff       	call   800987 <memmove>
	return r;
  8014e4:	83 c4 10             	add    $0x10,%esp
}
  8014e7:	89 d8                	mov    %ebx,%eax
  8014e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ec:	5b                   	pop    %ebx
  8014ed:	5e                   	pop    %esi
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    
	assert(r <= n);
  8014f0:	68 98 22 80 00       	push   $0x802298
  8014f5:	68 9f 22 80 00       	push   $0x80229f
  8014fa:	6a 7c                	push   $0x7c
  8014fc:	68 b4 22 80 00       	push   $0x8022b4
  801501:	e8 36 ec ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  801506:	68 bf 22 80 00       	push   $0x8022bf
  80150b:	68 9f 22 80 00       	push   $0x80229f
  801510:	6a 7d                	push   $0x7d
  801512:	68 b4 22 80 00       	push   $0x8022b4
  801517:	e8 20 ec ff ff       	call   80013c <_panic>

0080151c <open>:
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	56                   	push   %esi
  801520:	53                   	push   %ebx
  801521:	83 ec 1c             	sub    $0x1c,%esp
  801524:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801527:	56                   	push   %esi
  801528:	e8 89 f2 ff ff       	call   8007b6 <strlen>
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801535:	7f 6c                	jg     8015a3 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	e8 c2 f8 ff ff       	call   800e05 <fd_alloc>
  801543:	89 c3                	mov    %eax,%ebx
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 3c                	js     801588 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	56                   	push   %esi
  801550:	68 00 50 c0 00       	push   $0xc05000
  801555:	e8 97 f2 ff ff       	call   8007f1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80155a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155d:	a3 00 54 c0 00       	mov    %eax,0xc05400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801565:	b8 01 00 00 00       	mov    $0x1,%eax
  80156a:	e8 f6 fd ff ff       	call   801365 <fsipc>
  80156f:	89 c3                	mov    %eax,%ebx
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	78 19                	js     801591 <open+0x75>
	return fd2num(fd);
  801578:	83 ec 0c             	sub    $0xc,%esp
  80157b:	ff 75 f4             	push   -0xc(%ebp)
  80157e:	e8 5b f8 ff ff       	call   800dde <fd2num>
  801583:	89 c3                	mov    %eax,%ebx
  801585:	83 c4 10             	add    $0x10,%esp
}
  801588:	89 d8                	mov    %ebx,%eax
  80158a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158d:	5b                   	pop    %ebx
  80158e:	5e                   	pop    %esi
  80158f:	5d                   	pop    %ebp
  801590:	c3                   	ret    
		fd_close(fd, 0);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	6a 00                	push   $0x0
  801596:	ff 75 f4             	push   -0xc(%ebp)
  801599:	e8 58 f9 ff ff       	call   800ef6 <fd_close>
		return r;
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	eb e5                	jmp    801588 <open+0x6c>
		return -E_BAD_PATH;
  8015a3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015a8:	eb de                	jmp    801588 <open+0x6c>

008015aa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ba:	e8 a6 fd ff ff       	call   801365 <fsipc>
}
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
  8015c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	ff 75 08             	push   0x8(%ebp)
  8015cf:	e8 1a f8 ff ff       	call   800dee <fd2data>
  8015d4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015d6:	83 c4 08             	add    $0x8,%esp
  8015d9:	68 cb 22 80 00       	push   $0x8022cb
  8015de:	53                   	push   %ebx
  8015df:	e8 0d f2 ff ff       	call   8007f1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015e4:	8b 46 04             	mov    0x4(%esi),%eax
  8015e7:	2b 06                	sub    (%esi),%eax
  8015e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015ef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015f6:	00 00 00 
	stat->st_dev = &devpipe;
  8015f9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801600:	30 80 00 
	return 0;
}
  801603:	b8 00 00 00 00       	mov    $0x0,%eax
  801608:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160b:	5b                   	pop    %ebx
  80160c:	5e                   	pop    %esi
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    

0080160f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	53                   	push   %ebx
  801613:	83 ec 0c             	sub    $0xc,%esp
  801616:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801619:	53                   	push   %ebx
  80161a:	6a 00                	push   $0x0
  80161c:	e8 51 f6 ff ff       	call   800c72 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801621:	89 1c 24             	mov    %ebx,(%esp)
  801624:	e8 c5 f7 ff ff       	call   800dee <fd2data>
  801629:	83 c4 08             	add    $0x8,%esp
  80162c:	50                   	push   %eax
  80162d:	6a 00                	push   $0x0
  80162f:	e8 3e f6 ff ff       	call   800c72 <sys_page_unmap>
}
  801634:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <_pipeisclosed>:
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	57                   	push   %edi
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	83 ec 1c             	sub    $0x1c,%esp
  801642:	89 c7                	mov    %eax,%edi
  801644:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801646:	a1 00 40 c0 00       	mov    0xc04000,%eax
  80164b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	57                   	push   %edi
  801652:	e8 1c 05 00 00       	call   801b73 <pageref>
  801657:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80165a:	89 34 24             	mov    %esi,(%esp)
  80165d:	e8 11 05 00 00       	call   801b73 <pageref>
		nn = thisenv->env_runs;
  801662:	8b 15 00 40 c0 00    	mov    0xc04000,%edx
  801668:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	39 cb                	cmp    %ecx,%ebx
  801670:	74 1b                	je     80168d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801672:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801675:	75 cf                	jne    801646 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801677:	8b 42 58             	mov    0x58(%edx),%eax
  80167a:	6a 01                	push   $0x1
  80167c:	50                   	push   %eax
  80167d:	53                   	push   %ebx
  80167e:	68 d2 22 80 00       	push   $0x8022d2
  801683:	e8 8f eb ff ff       	call   800217 <cprintf>
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	eb b9                	jmp    801646 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80168d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801690:	0f 94 c0             	sete   %al
  801693:	0f b6 c0             	movzbl %al,%eax
}
  801696:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5f                   	pop    %edi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <devpipe_write>:
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	57                   	push   %edi
  8016a2:	56                   	push   %esi
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 28             	sub    $0x28,%esp
  8016a7:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8016aa:	56                   	push   %esi
  8016ab:	e8 3e f7 ff ff       	call   800dee <fd2data>
  8016b0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	bf 00 00 00 00       	mov    $0x0,%edi
  8016ba:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016bd:	75 09                	jne    8016c8 <devpipe_write+0x2a>
	return i;
  8016bf:	89 f8                	mov    %edi,%eax
  8016c1:	eb 23                	jmp    8016e6 <devpipe_write+0x48>
			sys_yield();
  8016c3:	e8 06 f5 ff ff       	call   800bce <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016c8:	8b 43 04             	mov    0x4(%ebx),%eax
  8016cb:	8b 0b                	mov    (%ebx),%ecx
  8016cd:	8d 51 20             	lea    0x20(%ecx),%edx
  8016d0:	39 d0                	cmp    %edx,%eax
  8016d2:	72 1a                	jb     8016ee <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8016d4:	89 da                	mov    %ebx,%edx
  8016d6:	89 f0                	mov    %esi,%eax
  8016d8:	e8 5c ff ff ff       	call   801639 <_pipeisclosed>
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	74 e2                	je     8016c3 <devpipe_write+0x25>
				return 0;
  8016e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5e                   	pop    %esi
  8016eb:	5f                   	pop    %edi
  8016ec:	5d                   	pop    %ebp
  8016ed:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016f5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016f8:	89 c2                	mov    %eax,%edx
  8016fa:	c1 fa 1f             	sar    $0x1f,%edx
  8016fd:	89 d1                	mov    %edx,%ecx
  8016ff:	c1 e9 1b             	shr    $0x1b,%ecx
  801702:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801705:	83 e2 1f             	and    $0x1f,%edx
  801708:	29 ca                	sub    %ecx,%edx
  80170a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80170e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801712:	83 c0 01             	add    $0x1,%eax
  801715:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801718:	83 c7 01             	add    $0x1,%edi
  80171b:	eb 9d                	jmp    8016ba <devpipe_write+0x1c>

0080171d <devpipe_read>:
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	57                   	push   %edi
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	83 ec 18             	sub    $0x18,%esp
  801726:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801729:	57                   	push   %edi
  80172a:	e8 bf f6 ff ff       	call   800dee <fd2data>
  80172f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	be 00 00 00 00       	mov    $0x0,%esi
  801739:	3b 75 10             	cmp    0x10(%ebp),%esi
  80173c:	75 13                	jne    801751 <devpipe_read+0x34>
	return i;
  80173e:	89 f0                	mov    %esi,%eax
  801740:	eb 02                	jmp    801744 <devpipe_read+0x27>
				return i;
  801742:	89 f0                	mov    %esi,%eax
}
  801744:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801747:	5b                   	pop    %ebx
  801748:	5e                   	pop    %esi
  801749:	5f                   	pop    %edi
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    
			sys_yield();
  80174c:	e8 7d f4 ff ff       	call   800bce <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801751:	8b 03                	mov    (%ebx),%eax
  801753:	3b 43 04             	cmp    0x4(%ebx),%eax
  801756:	75 18                	jne    801770 <devpipe_read+0x53>
			if (i > 0)
  801758:	85 f6                	test   %esi,%esi
  80175a:	75 e6                	jne    801742 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80175c:	89 da                	mov    %ebx,%edx
  80175e:	89 f8                	mov    %edi,%eax
  801760:	e8 d4 fe ff ff       	call   801639 <_pipeisclosed>
  801765:	85 c0                	test   %eax,%eax
  801767:	74 e3                	je     80174c <devpipe_read+0x2f>
				return 0;
  801769:	b8 00 00 00 00       	mov    $0x0,%eax
  80176e:	eb d4                	jmp    801744 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801770:	99                   	cltd   
  801771:	c1 ea 1b             	shr    $0x1b,%edx
  801774:	01 d0                	add    %edx,%eax
  801776:	83 e0 1f             	and    $0x1f,%eax
  801779:	29 d0                	sub    %edx,%eax
  80177b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801783:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801786:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801789:	83 c6 01             	add    $0x1,%esi
  80178c:	eb ab                	jmp    801739 <devpipe_read+0x1c>

0080178e <pipe>:
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801796:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801799:	50                   	push   %eax
  80179a:	e8 66 f6 ff ff       	call   800e05 <fd_alloc>
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	0f 88 23 01 00 00    	js     8018cf <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ac:	83 ec 04             	sub    $0x4,%esp
  8017af:	68 07 04 00 00       	push   $0x407
  8017b4:	ff 75 f4             	push   -0xc(%ebp)
  8017b7:	6a 00                	push   $0x0
  8017b9:	e8 2f f4 ff ff       	call   800bed <sys_page_alloc>
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	0f 88 04 01 00 00    	js     8018cf <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d1:	50                   	push   %eax
  8017d2:	e8 2e f6 ff ff       	call   800e05 <fd_alloc>
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	0f 88 db 00 00 00    	js     8018bf <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e4:	83 ec 04             	sub    $0x4,%esp
  8017e7:	68 07 04 00 00       	push   $0x407
  8017ec:	ff 75 f0             	push   -0x10(%ebp)
  8017ef:	6a 00                	push   $0x0
  8017f1:	e8 f7 f3 ff ff       	call   800bed <sys_page_alloc>
  8017f6:	89 c3                	mov    %eax,%ebx
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	0f 88 bc 00 00 00    	js     8018bf <pipe+0x131>
	va = fd2data(fd0);
  801803:	83 ec 0c             	sub    $0xc,%esp
  801806:	ff 75 f4             	push   -0xc(%ebp)
  801809:	e8 e0 f5 ff ff       	call   800dee <fd2data>
  80180e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801810:	83 c4 0c             	add    $0xc,%esp
  801813:	68 07 04 00 00       	push   $0x407
  801818:	50                   	push   %eax
  801819:	6a 00                	push   $0x0
  80181b:	e8 cd f3 ff ff       	call   800bed <sys_page_alloc>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	0f 88 82 00 00 00    	js     8018af <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182d:	83 ec 0c             	sub    $0xc,%esp
  801830:	ff 75 f0             	push   -0x10(%ebp)
  801833:	e8 b6 f5 ff ff       	call   800dee <fd2data>
  801838:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80183f:	50                   	push   %eax
  801840:	6a 00                	push   $0x0
  801842:	56                   	push   %esi
  801843:	6a 00                	push   $0x0
  801845:	e8 e6 f3 ff ff       	call   800c30 <sys_page_map>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	83 c4 20             	add    $0x20,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 4e                	js     8018a1 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801853:	a1 20 30 80 00       	mov    0x803020,%eax
  801858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80185d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801860:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801867:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80186a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80186c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801876:	83 ec 0c             	sub    $0xc,%esp
  801879:	ff 75 f4             	push   -0xc(%ebp)
  80187c:	e8 5d f5 ff ff       	call   800dde <fd2num>
  801881:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801884:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801886:	83 c4 04             	add    $0x4,%esp
  801889:	ff 75 f0             	push   -0x10(%ebp)
  80188c:	e8 4d f5 ff ff       	call   800dde <fd2num>
  801891:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801894:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80189f:	eb 2e                	jmp    8018cf <pipe+0x141>
	sys_page_unmap(0, va);
  8018a1:	83 ec 08             	sub    $0x8,%esp
  8018a4:	56                   	push   %esi
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 c6 f3 ff ff       	call   800c72 <sys_page_unmap>
  8018ac:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	ff 75 f0             	push   -0x10(%ebp)
  8018b5:	6a 00                	push   $0x0
  8018b7:	e8 b6 f3 ff ff       	call   800c72 <sys_page_unmap>
  8018bc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8018bf:	83 ec 08             	sub    $0x8,%esp
  8018c2:	ff 75 f4             	push   -0xc(%ebp)
  8018c5:	6a 00                	push   $0x0
  8018c7:	e8 a6 f3 ff ff       	call   800c72 <sys_page_unmap>
  8018cc:	83 c4 10             	add    $0x10,%esp
}
  8018cf:	89 d8                	mov    %ebx,%eax
  8018d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d4:	5b                   	pop    %ebx
  8018d5:	5e                   	pop    %esi
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    

008018d8 <pipeisclosed>:
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e1:	50                   	push   %eax
  8018e2:	ff 75 08             	push   0x8(%ebp)
  8018e5:	e8 6b f5 ff ff       	call   800e55 <fd_lookup>
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 18                	js     801909 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8018f1:	83 ec 0c             	sub    $0xc,%esp
  8018f4:	ff 75 f4             	push   -0xc(%ebp)
  8018f7:	e8 f2 f4 ff ff       	call   800dee <fd2data>
  8018fc:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801901:	e8 33 fd ff ff       	call   801639 <_pipeisclosed>
  801906:	83 c4 10             	add    $0x10,%esp
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80190b:	b8 00 00 00 00       	mov    $0x0,%eax
  801910:	c3                   	ret    

00801911 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801917:	68 ea 22 80 00       	push   $0x8022ea
  80191c:	ff 75 0c             	push   0xc(%ebp)
  80191f:	e8 cd ee ff ff       	call   8007f1 <strcpy>
	return 0;
}
  801924:	b8 00 00 00 00       	mov    $0x0,%eax
  801929:	c9                   	leave  
  80192a:	c3                   	ret    

0080192b <devcons_write>:
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	57                   	push   %edi
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801937:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80193c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801942:	eb 2e                	jmp    801972 <devcons_write+0x47>
		m = n - tot;
  801944:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801947:	29 f3                	sub    %esi,%ebx
  801949:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80194e:	39 c3                	cmp    %eax,%ebx
  801950:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801953:	83 ec 04             	sub    $0x4,%esp
  801956:	53                   	push   %ebx
  801957:	89 f0                	mov    %esi,%eax
  801959:	03 45 0c             	add    0xc(%ebp),%eax
  80195c:	50                   	push   %eax
  80195d:	57                   	push   %edi
  80195e:	e8 24 f0 ff ff       	call   800987 <memmove>
		sys_cputs(buf, m);
  801963:	83 c4 08             	add    $0x8,%esp
  801966:	53                   	push   %ebx
  801967:	57                   	push   %edi
  801968:	e8 c4 f1 ff ff       	call   800b31 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80196d:	01 de                	add    %ebx,%esi
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	3b 75 10             	cmp    0x10(%ebp),%esi
  801975:	72 cd                	jb     801944 <devcons_write+0x19>
}
  801977:	89 f0                	mov    %esi,%eax
  801979:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80197c:	5b                   	pop    %ebx
  80197d:	5e                   	pop    %esi
  80197e:	5f                   	pop    %edi
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <devcons_read>:
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 08             	sub    $0x8,%esp
  801987:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80198c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801990:	75 07                	jne    801999 <devcons_read+0x18>
  801992:	eb 1f                	jmp    8019b3 <devcons_read+0x32>
		sys_yield();
  801994:	e8 35 f2 ff ff       	call   800bce <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801999:	e8 b1 f1 ff ff       	call   800b4f <sys_cgetc>
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	74 f2                	je     801994 <devcons_read+0x13>
	if (c < 0)
  8019a2:	78 0f                	js     8019b3 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8019a4:	83 f8 04             	cmp    $0x4,%eax
  8019a7:	74 0c                	je     8019b5 <devcons_read+0x34>
	*(char*)vbuf = c;
  8019a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ac:	88 02                	mov    %al,(%edx)
	return 1;
  8019ae:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    
		return 0;
  8019b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ba:	eb f7                	jmp    8019b3 <devcons_read+0x32>

008019bc <cputchar>:
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c5:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8019c8:	6a 01                	push   $0x1
  8019ca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019cd:	50                   	push   %eax
  8019ce:	e8 5e f1 ff ff       	call   800b31 <sys_cputs>
}
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <getchar>:
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8019de:	6a 01                	push   $0x1
  8019e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	6a 00                	push   $0x0
  8019e6:	e8 ce f6 ff ff       	call   8010b9 <read>
	if (r < 0)
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 06                	js     8019f8 <getchar+0x20>
	if (r < 1)
  8019f2:	74 06                	je     8019fa <getchar+0x22>
	return c;
  8019f4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    
		return -E_EOF;
  8019fa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8019ff:	eb f7                	jmp    8019f8 <getchar+0x20>

00801a01 <iscons>:
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0a:	50                   	push   %eax
  801a0b:	ff 75 08             	push   0x8(%ebp)
  801a0e:	e8 42 f4 ff ff       	call   800e55 <fd_lookup>
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 11                	js     801a2b <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a23:	39 10                	cmp    %edx,(%eax)
  801a25:	0f 94 c0             	sete   %al
  801a28:	0f b6 c0             	movzbl %al,%eax
}
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <opencons>:
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801a33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a36:	50                   	push   %eax
  801a37:	e8 c9 f3 ff ff       	call   800e05 <fd_alloc>
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 3a                	js     801a7d <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a43:	83 ec 04             	sub    $0x4,%esp
  801a46:	68 07 04 00 00       	push   $0x407
  801a4b:	ff 75 f4             	push   -0xc(%ebp)
  801a4e:	6a 00                	push   $0x0
  801a50:	e8 98 f1 ff ff       	call   800bed <sys_page_alloc>
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 21                	js     801a7d <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a65:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	50                   	push   %eax
  801a75:	e8 64 f3 ff ff       	call   800dde <fd2num>
  801a7a:	83 c4 10             	add    $0x10,%esp
}
  801a7d:	c9                   	leave  
  801a7e:	c3                   	ret    

00801a7f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	8b 75 08             	mov    0x8(%ebp),%esi
  801a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a94:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	50                   	push   %eax
  801a9b:	e8 fd f2 ff ff       	call   800d9d <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	85 f6                	test   %esi,%esi
  801aa5:	74 14                	je     801abb <ipc_recv+0x3c>
  801aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 09                	js     801ab9 <ipc_recv+0x3a>
  801ab0:	8b 15 00 40 c0 00    	mov    0xc04000,%edx
  801ab6:	8b 52 74             	mov    0x74(%edx),%edx
  801ab9:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801abb:	85 db                	test   %ebx,%ebx
  801abd:	74 14                	je     801ad3 <ipc_recv+0x54>
  801abf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	78 09                	js     801ad1 <ipc_recv+0x52>
  801ac8:	8b 15 00 40 c0 00    	mov    0xc04000,%edx
  801ace:	8b 52 78             	mov    0x78(%edx),%edx
  801ad1:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 08                	js     801adf <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801ad7:	a1 00 40 c0 00       	mov    0xc04000,%eax
  801adc:	8b 40 70             	mov    0x70(%eax),%eax
}
  801adf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	57                   	push   %edi
  801aea:	56                   	push   %esi
  801aeb:	53                   	push   %ebx
  801aec:	83 ec 0c             	sub    $0xc,%esp
  801aef:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801af8:	85 db                	test   %ebx,%ebx
  801afa:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aff:	0f 44 d8             	cmove  %eax,%ebx
  801b02:	eb 05                	jmp    801b09 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b04:	e8 c5 f0 ff ff       	call   800bce <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801b09:	ff 75 14             	push   0x14(%ebp)
  801b0c:	53                   	push   %ebx
  801b0d:	56                   	push   %esi
  801b0e:	57                   	push   %edi
  801b0f:	e8 66 f2 ff ff       	call   800d7a <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b1a:	74 e8                	je     801b04 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	78 08                	js     801b28 <ipc_send+0x42>
	}while (r<0);

}
  801b20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5f                   	pop    %edi
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801b28:	50                   	push   %eax
  801b29:	68 f6 22 80 00       	push   $0x8022f6
  801b2e:	6a 3d                	push   $0x3d
  801b30:	68 0a 23 80 00       	push   $0x80230a
  801b35:	e8 02 e6 ff ff       	call   80013c <_panic>

00801b3a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b45:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b48:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b4e:	8b 52 50             	mov    0x50(%edx),%edx
  801b51:	39 ca                	cmp    %ecx,%edx
  801b53:	74 11                	je     801b66 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b55:	83 c0 01             	add    $0x1,%eax
  801b58:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b5d:	75 e6                	jne    801b45 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b64:	eb 0b                	jmp    801b71 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b66:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b69:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b6e:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b79:	89 c2                	mov    %eax,%edx
  801b7b:	c1 ea 16             	shr    $0x16,%edx
  801b7e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b85:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b8a:	f6 c1 01             	test   $0x1,%cl
  801b8d:	74 1c                	je     801bab <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801b8f:	c1 e8 0c             	shr    $0xc,%eax
  801b92:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b99:	a8 01                	test   $0x1,%al
  801b9b:	74 0e                	je     801bab <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b9d:	c1 e8 0c             	shr    $0xc,%eax
  801ba0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ba7:	ef 
  801ba8:	0f b7 d2             	movzwl %dx,%edx
}
  801bab:	89 d0                	mov    %edx,%eax
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    
  801baf:	90                   	nop

00801bb0 <__udivdi3>:
  801bb0:	f3 0f 1e fb          	endbr32 
  801bb4:	55                   	push   %ebp
  801bb5:	57                   	push   %edi
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	83 ec 1c             	sub    $0x1c,%esp
  801bbb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801bbf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801bc3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801bc7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	75 19                	jne    801be8 <__udivdi3+0x38>
  801bcf:	39 f3                	cmp    %esi,%ebx
  801bd1:	76 4d                	jbe    801c20 <__udivdi3+0x70>
  801bd3:	31 ff                	xor    %edi,%edi
  801bd5:	89 e8                	mov    %ebp,%eax
  801bd7:	89 f2                	mov    %esi,%edx
  801bd9:	f7 f3                	div    %ebx
  801bdb:	89 fa                	mov    %edi,%edx
  801bdd:	83 c4 1c             	add    $0x1c,%esp
  801be0:	5b                   	pop    %ebx
  801be1:	5e                   	pop    %esi
  801be2:	5f                   	pop    %edi
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    
  801be5:	8d 76 00             	lea    0x0(%esi),%esi
  801be8:	39 f0                	cmp    %esi,%eax
  801bea:	76 14                	jbe    801c00 <__udivdi3+0x50>
  801bec:	31 ff                	xor    %edi,%edi
  801bee:	31 c0                	xor    %eax,%eax
  801bf0:	89 fa                	mov    %edi,%edx
  801bf2:	83 c4 1c             	add    $0x1c,%esp
  801bf5:	5b                   	pop    %ebx
  801bf6:	5e                   	pop    %esi
  801bf7:	5f                   	pop    %edi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    
  801bfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c00:	0f bd f8             	bsr    %eax,%edi
  801c03:	83 f7 1f             	xor    $0x1f,%edi
  801c06:	75 48                	jne    801c50 <__udivdi3+0xa0>
  801c08:	39 f0                	cmp    %esi,%eax
  801c0a:	72 06                	jb     801c12 <__udivdi3+0x62>
  801c0c:	31 c0                	xor    %eax,%eax
  801c0e:	39 eb                	cmp    %ebp,%ebx
  801c10:	77 de                	ja     801bf0 <__udivdi3+0x40>
  801c12:	b8 01 00 00 00       	mov    $0x1,%eax
  801c17:	eb d7                	jmp    801bf0 <__udivdi3+0x40>
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	89 d9                	mov    %ebx,%ecx
  801c22:	85 db                	test   %ebx,%ebx
  801c24:	75 0b                	jne    801c31 <__udivdi3+0x81>
  801c26:	b8 01 00 00 00       	mov    $0x1,%eax
  801c2b:	31 d2                	xor    %edx,%edx
  801c2d:	f7 f3                	div    %ebx
  801c2f:	89 c1                	mov    %eax,%ecx
  801c31:	31 d2                	xor    %edx,%edx
  801c33:	89 f0                	mov    %esi,%eax
  801c35:	f7 f1                	div    %ecx
  801c37:	89 c6                	mov    %eax,%esi
  801c39:	89 e8                	mov    %ebp,%eax
  801c3b:	89 f7                	mov    %esi,%edi
  801c3d:	f7 f1                	div    %ecx
  801c3f:	89 fa                	mov    %edi,%edx
  801c41:	83 c4 1c             	add    $0x1c,%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5e                   	pop    %esi
  801c46:	5f                   	pop    %edi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 f9                	mov    %edi,%ecx
  801c52:	ba 20 00 00 00       	mov    $0x20,%edx
  801c57:	29 fa                	sub    %edi,%edx
  801c59:	d3 e0                	shl    %cl,%eax
  801c5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c5f:	89 d1                	mov    %edx,%ecx
  801c61:	89 d8                	mov    %ebx,%eax
  801c63:	d3 e8                	shr    %cl,%eax
  801c65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c69:	09 c1                	or     %eax,%ecx
  801c6b:	89 f0                	mov    %esi,%eax
  801c6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c71:	89 f9                	mov    %edi,%ecx
  801c73:	d3 e3                	shl    %cl,%ebx
  801c75:	89 d1                	mov    %edx,%ecx
  801c77:	d3 e8                	shr    %cl,%eax
  801c79:	89 f9                	mov    %edi,%ecx
  801c7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c7f:	89 eb                	mov    %ebp,%ebx
  801c81:	d3 e6                	shl    %cl,%esi
  801c83:	89 d1                	mov    %edx,%ecx
  801c85:	d3 eb                	shr    %cl,%ebx
  801c87:	09 f3                	or     %esi,%ebx
  801c89:	89 c6                	mov    %eax,%esi
  801c8b:	89 f2                	mov    %esi,%edx
  801c8d:	89 d8                	mov    %ebx,%eax
  801c8f:	f7 74 24 08          	divl   0x8(%esp)
  801c93:	89 d6                	mov    %edx,%esi
  801c95:	89 c3                	mov    %eax,%ebx
  801c97:	f7 64 24 0c          	mull   0xc(%esp)
  801c9b:	39 d6                	cmp    %edx,%esi
  801c9d:	72 19                	jb     801cb8 <__udivdi3+0x108>
  801c9f:	89 f9                	mov    %edi,%ecx
  801ca1:	d3 e5                	shl    %cl,%ebp
  801ca3:	39 c5                	cmp    %eax,%ebp
  801ca5:	73 04                	jae    801cab <__udivdi3+0xfb>
  801ca7:	39 d6                	cmp    %edx,%esi
  801ca9:	74 0d                	je     801cb8 <__udivdi3+0x108>
  801cab:	89 d8                	mov    %ebx,%eax
  801cad:	31 ff                	xor    %edi,%edi
  801caf:	e9 3c ff ff ff       	jmp    801bf0 <__udivdi3+0x40>
  801cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801cbb:	31 ff                	xor    %edi,%edi
  801cbd:	e9 2e ff ff ff       	jmp    801bf0 <__udivdi3+0x40>
  801cc2:	66 90                	xchg   %ax,%ax
  801cc4:	66 90                	xchg   %ax,%ax
  801cc6:	66 90                	xchg   %ax,%ax
  801cc8:	66 90                	xchg   %ax,%ax
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	66 90                	xchg   %ax,%ax
  801cce:	66 90                	xchg   %ax,%ax

00801cd0 <__umoddi3>:
  801cd0:	f3 0f 1e fb          	endbr32 
  801cd4:	55                   	push   %ebp
  801cd5:	57                   	push   %edi
  801cd6:	56                   	push   %esi
  801cd7:	53                   	push   %ebx
  801cd8:	83 ec 1c             	sub    $0x1c,%esp
  801cdb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cdf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ce3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801ce7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801ceb:	89 f0                	mov    %esi,%eax
  801ced:	89 da                	mov    %ebx,%edx
  801cef:	85 ff                	test   %edi,%edi
  801cf1:	75 15                	jne    801d08 <__umoddi3+0x38>
  801cf3:	39 dd                	cmp    %ebx,%ebp
  801cf5:	76 39                	jbe    801d30 <__umoddi3+0x60>
  801cf7:	f7 f5                	div    %ebp
  801cf9:	89 d0                	mov    %edx,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	83 c4 1c             	add    $0x1c,%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    
  801d05:	8d 76 00             	lea    0x0(%esi),%esi
  801d08:	39 df                	cmp    %ebx,%edi
  801d0a:	77 f1                	ja     801cfd <__umoddi3+0x2d>
  801d0c:	0f bd cf             	bsr    %edi,%ecx
  801d0f:	83 f1 1f             	xor    $0x1f,%ecx
  801d12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d16:	75 40                	jne    801d58 <__umoddi3+0x88>
  801d18:	39 df                	cmp    %ebx,%edi
  801d1a:	72 04                	jb     801d20 <__umoddi3+0x50>
  801d1c:	39 f5                	cmp    %esi,%ebp
  801d1e:	77 dd                	ja     801cfd <__umoddi3+0x2d>
  801d20:	89 da                	mov    %ebx,%edx
  801d22:	89 f0                	mov    %esi,%eax
  801d24:	29 e8                	sub    %ebp,%eax
  801d26:	19 fa                	sbb    %edi,%edx
  801d28:	eb d3                	jmp    801cfd <__umoddi3+0x2d>
  801d2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d30:	89 e9                	mov    %ebp,%ecx
  801d32:	85 ed                	test   %ebp,%ebp
  801d34:	75 0b                	jne    801d41 <__umoddi3+0x71>
  801d36:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	f7 f5                	div    %ebp
  801d3f:	89 c1                	mov    %eax,%ecx
  801d41:	89 d8                	mov    %ebx,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f1                	div    %ecx
  801d47:	89 f0                	mov    %esi,%eax
  801d49:	f7 f1                	div    %ecx
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	31 d2                	xor    %edx,%edx
  801d4f:	eb ac                	jmp    801cfd <__umoddi3+0x2d>
  801d51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d58:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d5c:	ba 20 00 00 00       	mov    $0x20,%edx
  801d61:	29 c2                	sub    %eax,%edx
  801d63:	89 c1                	mov    %eax,%ecx
  801d65:	89 e8                	mov    %ebp,%eax
  801d67:	d3 e7                	shl    %cl,%edi
  801d69:	89 d1                	mov    %edx,%ecx
  801d6b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d6f:	d3 e8                	shr    %cl,%eax
  801d71:	89 c1                	mov    %eax,%ecx
  801d73:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d77:	09 f9                	or     %edi,%ecx
  801d79:	89 df                	mov    %ebx,%edi
  801d7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d7f:	89 c1                	mov    %eax,%ecx
  801d81:	d3 e5                	shl    %cl,%ebp
  801d83:	89 d1                	mov    %edx,%ecx
  801d85:	d3 ef                	shr    %cl,%edi
  801d87:	89 c1                	mov    %eax,%ecx
  801d89:	89 f0                	mov    %esi,%eax
  801d8b:	d3 e3                	shl    %cl,%ebx
  801d8d:	89 d1                	mov    %edx,%ecx
  801d8f:	89 fa                	mov    %edi,%edx
  801d91:	d3 e8                	shr    %cl,%eax
  801d93:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d98:	09 d8                	or     %ebx,%eax
  801d9a:	f7 74 24 08          	divl   0x8(%esp)
  801d9e:	89 d3                	mov    %edx,%ebx
  801da0:	d3 e6                	shl    %cl,%esi
  801da2:	f7 e5                	mul    %ebp
  801da4:	89 c7                	mov    %eax,%edi
  801da6:	89 d1                	mov    %edx,%ecx
  801da8:	39 d3                	cmp    %edx,%ebx
  801daa:	72 06                	jb     801db2 <__umoddi3+0xe2>
  801dac:	75 0e                	jne    801dbc <__umoddi3+0xec>
  801dae:	39 c6                	cmp    %eax,%esi
  801db0:	73 0a                	jae    801dbc <__umoddi3+0xec>
  801db2:	29 e8                	sub    %ebp,%eax
  801db4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801db8:	89 d1                	mov    %edx,%ecx
  801dba:	89 c7                	mov    %eax,%edi
  801dbc:	89 f5                	mov    %esi,%ebp
  801dbe:	8b 74 24 04          	mov    0x4(%esp),%esi
  801dc2:	29 fd                	sub    %edi,%ebp
  801dc4:	19 cb                	sbb    %ecx,%ebx
  801dc6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801dcb:	89 d8                	mov    %ebx,%eax
  801dcd:	d3 e0                	shl    %cl,%eax
  801dcf:	89 f1                	mov    %esi,%ecx
  801dd1:	d3 ed                	shr    %cl,%ebp
  801dd3:	d3 eb                	shr    %cl,%ebx
  801dd5:	09 e8                	or     %ebp,%eax
  801dd7:	89 da                	mov    %ebx,%edx
  801dd9:	83 c4 1c             	add    $0x1c,%esp
  801ddc:	5b                   	pop    %ebx
  801ddd:	5e                   	pop    %esi
  801dde:	5f                   	pop    %edi
  801ddf:	5d                   	pop    %ebp
  801de0:	c3                   	ret    
