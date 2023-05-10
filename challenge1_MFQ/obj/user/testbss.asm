
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
  800039:	68 e0 22 80 00       	push   $0x8022e0
  80003e:	e8 d7 01 00 00       	call   80021a <cprintf>
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
  800090:	68 28 23 80 00       	push   $0x802328
  800095:	e8 80 01 00 00       	call   80021a <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009a:	c7 05 00 50 c0 00 00 	movl   $0x0,0xc05000
  8000a1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	68 87 23 80 00       	push   $0x802387
  8000ac:	6a 1a                	push   $0x1a
  8000ae:	68 78 23 80 00       	push   $0x802378
  8000b3:	e8 87 00 00 00       	call   80013f <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b8:	50                   	push   %eax
  8000b9:	68 5b 23 80 00       	push   $0x80235b
  8000be:	6a 11                	push   $0x11
  8000c0:	68 78 23 80 00       	push   $0x802378
  8000c5:	e8 75 00 00 00       	call   80013f <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ca:	50                   	push   %eax
  8000cb:	68 00 23 80 00       	push   $0x802300
  8000d0:	6a 16                	push   $0x16
  8000d2:	68 78 23 80 00       	push   $0x802378
  8000d7:	e8 63 00 00 00       	call   80013f <_panic>

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
  8000e7:	e8 c6 0a 00 00       	call   800bb2 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8000f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fc:	a3 00 40 c0 00       	mov    %eax,0xc04000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800101:	85 db                	test   %ebx,%ebx
  800103:	7e 07                	jle    80010c <libmain+0x30>
		binaryname = argv[0];
  800105:	8b 06                	mov    (%esi),%eax
  800107:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	e8 1d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800116:	e8 0a 00 00 00       	call   800125 <exit>
}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012b:	e8 e3 0e 00 00       	call   801013 <close_all>
	sys_env_destroy(0);
  800130:	83 ec 0c             	sub    $0xc,%esp
  800133:	6a 00                	push   $0x0
  800135:	e8 37 0a 00 00       	call   800b71 <sys_env_destroy>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	56                   	push   %esi
  800143:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800144:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800147:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014d:	e8 60 0a 00 00       	call   800bb2 <sys_getenvid>
  800152:	83 ec 0c             	sub    $0xc,%esp
  800155:	ff 75 0c             	push   0xc(%ebp)
  800158:	ff 75 08             	push   0x8(%ebp)
  80015b:	56                   	push   %esi
  80015c:	50                   	push   %eax
  80015d:	68 a8 23 80 00       	push   $0x8023a8
  800162:	e8 b3 00 00 00       	call   80021a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800167:	83 c4 18             	add    $0x18,%esp
  80016a:	53                   	push   %ebx
  80016b:	ff 75 10             	push   0x10(%ebp)
  80016e:	e8 56 00 00 00       	call   8001c9 <vcprintf>
	cprintf("\n");
  800173:	c7 04 24 76 23 80 00 	movl   $0x802376,(%esp)
  80017a:	e8 9b 00 00 00       	call   80021a <cprintf>
  80017f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800182:	cc                   	int3   
  800183:	eb fd                	jmp    800182 <_panic+0x43>

00800185 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	53                   	push   %ebx
  800189:	83 ec 04             	sub    $0x4,%esp
  80018c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018f:	8b 13                	mov    (%ebx),%edx
  800191:	8d 42 01             	lea    0x1(%edx),%eax
  800194:	89 03                	mov    %eax,(%ebx)
  800196:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800199:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a2:	74 09                	je     8001ad <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ad:	83 ec 08             	sub    $0x8,%esp
  8001b0:	68 ff 00 00 00       	push   $0xff
  8001b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b8:	50                   	push   %eax
  8001b9:	e8 76 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  8001be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c4:	83 c4 10             	add    $0x10,%esp
  8001c7:	eb db                	jmp    8001a4 <putch+0x1f>

008001c9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d9:	00 00 00 
	b.cnt = 0;
  8001dc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e6:	ff 75 0c             	push   0xc(%ebp)
  8001e9:	ff 75 08             	push   0x8(%ebp)
  8001ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	68 85 01 80 00       	push   $0x800185
  8001f8:	e8 14 01 00 00       	call   800311 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fd:	83 c4 08             	add    $0x8,%esp
  800200:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800206:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	e8 22 09 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  800212:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800220:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800223:	50                   	push   %eax
  800224:	ff 75 08             	push   0x8(%ebp)
  800227:	e8 9d ff ff ff       	call   8001c9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
  800234:	83 ec 1c             	sub    $0x1c,%esp
  800237:	89 c7                	mov    %eax,%edi
  800239:	89 d6                	mov    %edx,%esi
  80023b:	8b 45 08             	mov    0x8(%ebp),%eax
  80023e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800241:	89 d1                	mov    %edx,%ecx
  800243:	89 c2                	mov    %eax,%edx
  800245:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800248:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024b:	8b 45 10             	mov    0x10(%ebp),%eax
  80024e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800251:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800254:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025b:	39 c2                	cmp    %eax,%edx
  80025d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800260:	72 3e                	jb     8002a0 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	ff 75 18             	push   0x18(%ebp)
  800268:	83 eb 01             	sub    $0x1,%ebx
  80026b:	53                   	push   %ebx
  80026c:	50                   	push   %eax
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 e4             	push   -0x1c(%ebp)
  800273:	ff 75 e0             	push   -0x20(%ebp)
  800276:	ff 75 dc             	push   -0x24(%ebp)
  800279:	ff 75 d8             	push   -0x28(%ebp)
  80027c:	e8 0f 1e 00 00       	call   802090 <__udivdi3>
  800281:	83 c4 18             	add    $0x18,%esp
  800284:	52                   	push   %edx
  800285:	50                   	push   %eax
  800286:	89 f2                	mov    %esi,%edx
  800288:	89 f8                	mov    %edi,%eax
  80028a:	e8 9f ff ff ff       	call   80022e <printnum>
  80028f:	83 c4 20             	add    $0x20,%esp
  800292:	eb 13                	jmp    8002a7 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	56                   	push   %esi
  800298:	ff 75 18             	push   0x18(%ebp)
  80029b:	ff d7                	call   *%edi
  80029d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a0:	83 eb 01             	sub    $0x1,%ebx
  8002a3:	85 db                	test   %ebx,%ebx
  8002a5:	7f ed                	jg     800294 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	56                   	push   %esi
  8002ab:	83 ec 04             	sub    $0x4,%esp
  8002ae:	ff 75 e4             	push   -0x1c(%ebp)
  8002b1:	ff 75 e0             	push   -0x20(%ebp)
  8002b4:	ff 75 dc             	push   -0x24(%ebp)
  8002b7:	ff 75 d8             	push   -0x28(%ebp)
  8002ba:	e8 f1 1e 00 00       	call   8021b0 <__umoddi3>
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	0f be 80 cb 23 80 00 	movsbl 0x8023cb(%eax),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff d7                	call   *%edi
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e1:	8b 10                	mov    (%eax),%edx
  8002e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e6:	73 0a                	jae    8002f2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002eb:	89 08                	mov    %ecx,(%eax)
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	88 02                	mov    %al,(%edx)
}
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <printfmt>:
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fd:	50                   	push   %eax
  8002fe:	ff 75 10             	push   0x10(%ebp)
  800301:	ff 75 0c             	push   0xc(%ebp)
  800304:	ff 75 08             	push   0x8(%ebp)
  800307:	e8 05 00 00 00       	call   800311 <vprintfmt>
}
  80030c:	83 c4 10             	add    $0x10,%esp
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <vprintfmt>:
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
  800317:	83 ec 3c             	sub    $0x3c,%esp
  80031a:	8b 75 08             	mov    0x8(%ebp),%esi
  80031d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800320:	8b 7d 10             	mov    0x10(%ebp),%edi
  800323:	eb 0a                	jmp    80032f <vprintfmt+0x1e>
			putch(ch, putdat);
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	53                   	push   %ebx
  800329:	50                   	push   %eax
  80032a:	ff d6                	call   *%esi
  80032c:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032f:	83 c7 01             	add    $0x1,%edi
  800332:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800336:	83 f8 25             	cmp    $0x25,%eax
  800339:	74 0c                	je     800347 <vprintfmt+0x36>
			if (ch == '\0')
  80033b:	85 c0                	test   %eax,%eax
  80033d:	75 e6                	jne    800325 <vprintfmt+0x14>
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    
		padc = ' ';
  800347:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80034b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800352:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800359:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800360:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8d 47 01             	lea    0x1(%edi),%eax
  800368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036b:	0f b6 17             	movzbl (%edi),%edx
  80036e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800371:	3c 55                	cmp    $0x55,%al
  800373:	0f 87 bb 03 00 00    	ja     800734 <vprintfmt+0x423>
  800379:	0f b6 c0             	movzbl %al,%eax
  80037c:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800386:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80038a:	eb d9                	jmp    800365 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800393:	eb d0                	jmp    800365 <vprintfmt+0x54>
  800395:	0f b6 d2             	movzbl %dl,%edx
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039b:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003aa:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ad:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b0:	83 f9 09             	cmp    $0x9,%ecx
  8003b3:	77 55                	ja     80040a <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b8:	eb e9                	jmp    8003a3 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 40 04             	lea    0x4(%eax),%eax
  8003c8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d2:	79 91                	jns    800365 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e1:	eb 82                	jmp    800365 <vprintfmt+0x54>
  8003e3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ed:	0f 49 c2             	cmovns %edx,%eax
  8003f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f6:	e9 6a ff ff ff       	jmp    800365 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003fe:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800405:	e9 5b ff ff ff       	jmp    800365 <vprintfmt+0x54>
  80040a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80040d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800410:	eb bc                	jmp    8003ce <vprintfmt+0xbd>
			lflag++;
  800412:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800418:	e9 48 ff ff ff       	jmp    800365 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 78 04             	lea    0x4(%eax),%edi
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	53                   	push   %ebx
  800427:	ff 30                	push   (%eax)
  800429:	ff d6                	call   *%esi
			break;
  80042b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80042e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800431:	e9 9d 02 00 00       	jmp    8006d3 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 78 04             	lea    0x4(%eax),%edi
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	89 d0                	mov    %edx,%eax
  800440:	f7 d8                	neg    %eax
  800442:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800445:	83 f8 0f             	cmp    $0xf,%eax
  800448:	7f 23                	jg     80046d <vprintfmt+0x15c>
  80044a:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	74 18                	je     80046d <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800455:	52                   	push   %edx
  800456:	68 95 27 80 00       	push   $0x802795
  80045b:	53                   	push   %ebx
  80045c:	56                   	push   %esi
  80045d:	e8 92 fe ff ff       	call   8002f4 <printfmt>
  800462:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800465:	89 7d 14             	mov    %edi,0x14(%ebp)
  800468:	e9 66 02 00 00       	jmp    8006d3 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80046d:	50                   	push   %eax
  80046e:	68 e3 23 80 00       	push   $0x8023e3
  800473:	53                   	push   %ebx
  800474:	56                   	push   %esi
  800475:	e8 7a fe ff ff       	call   8002f4 <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800480:	e9 4e 02 00 00       	jmp    8006d3 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	83 c0 04             	add    $0x4,%eax
  80048b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800493:	85 d2                	test   %edx,%edx
  800495:	b8 dc 23 80 00       	mov    $0x8023dc,%eax
  80049a:	0f 45 c2             	cmovne %edx,%eax
  80049d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a4:	7e 06                	jle    8004ac <vprintfmt+0x19b>
  8004a6:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004aa:	75 0d                	jne    8004b9 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004af:	89 c7                	mov    %eax,%edi
  8004b1:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b7:	eb 55                	jmp    80050e <vprintfmt+0x1fd>
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 d8             	push   -0x28(%ebp)
  8004bf:	ff 75 cc             	push   -0x34(%ebp)
  8004c2:	e8 0a 03 00 00       	call   8007d1 <strnlen>
  8004c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ca:	29 c1                	sub    %eax,%ecx
  8004cc:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004d4:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	eb 0f                	jmp    8004ec <vprintfmt+0x1db>
					putch(padc, putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	ff 75 e0             	push   -0x20(%ebp)
  8004e4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	83 ef 01             	sub    $0x1,%edi
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	85 ff                	test   %edi,%edi
  8004ee:	7f ed                	jg     8004dd <vprintfmt+0x1cc>
  8004f0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fa:	0f 49 c2             	cmovns %edx,%eax
  8004fd:	29 c2                	sub    %eax,%edx
  8004ff:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800502:	eb a8                	jmp    8004ac <vprintfmt+0x19b>
					putch(ch, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	52                   	push   %edx
  800509:	ff d6                	call   *%esi
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800511:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800513:	83 c7 01             	add    $0x1,%edi
  800516:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051a:	0f be d0             	movsbl %al,%edx
  80051d:	85 d2                	test   %edx,%edx
  80051f:	74 4b                	je     80056c <vprintfmt+0x25b>
  800521:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800525:	78 06                	js     80052d <vprintfmt+0x21c>
  800527:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80052b:	78 1e                	js     80054b <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80052d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800531:	74 d1                	je     800504 <vprintfmt+0x1f3>
  800533:	0f be c0             	movsbl %al,%eax
  800536:	83 e8 20             	sub    $0x20,%eax
  800539:	83 f8 5e             	cmp    $0x5e,%eax
  80053c:	76 c6                	jbe    800504 <vprintfmt+0x1f3>
					putch('?', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	6a 3f                	push   $0x3f
  800544:	ff d6                	call   *%esi
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	eb c3                	jmp    80050e <vprintfmt+0x1fd>
  80054b:	89 cf                	mov    %ecx,%edi
  80054d:	eb 0e                	jmp    80055d <vprintfmt+0x24c>
				putch(' ', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	6a 20                	push   $0x20
  800555:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800557:	83 ef 01             	sub    $0x1,%edi
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	85 ff                	test   %edi,%edi
  80055f:	7f ee                	jg     80054f <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800561:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
  800567:	e9 67 01 00 00       	jmp    8006d3 <vprintfmt+0x3c2>
  80056c:	89 cf                	mov    %ecx,%edi
  80056e:	eb ed                	jmp    80055d <vprintfmt+0x24c>
	if (lflag >= 2)
  800570:	83 f9 01             	cmp    $0x1,%ecx
  800573:	7f 1b                	jg     800590 <vprintfmt+0x27f>
	else if (lflag)
  800575:	85 c9                	test   %ecx,%ecx
  800577:	74 63                	je     8005dc <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8b 00                	mov    (%eax),%eax
  80057e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800581:	99                   	cltd   
  800582:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 40 04             	lea    0x4(%eax),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
  80058e:	eb 17                	jmp    8005a7 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 50 04             	mov    0x4(%eax),%edx
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 40 08             	lea    0x8(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ad:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005b2:	85 c9                	test   %ecx,%ecx
  8005b4:	0f 89 ff 00 00 00    	jns    8006b9 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 2d                	push   $0x2d
  8005c0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c8:	f7 da                	neg    %edx
  8005ca:	83 d1 00             	adc    $0x0,%ecx
  8005cd:	f7 d9                	neg    %ecx
  8005cf:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d2:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005d7:	e9 dd 00 00 00       	jmp    8006b9 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e4:	99                   	cltd   
  8005e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f1:	eb b4                	jmp    8005a7 <vprintfmt+0x296>
	if (lflag >= 2)
  8005f3:	83 f9 01             	cmp    $0x1,%ecx
  8005f6:	7f 1e                	jg     800616 <vprintfmt+0x305>
	else if (lflag)
  8005f8:	85 c9                	test   %ecx,%ecx
  8005fa:	74 32                	je     80062e <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 10                	mov    (%eax),%edx
  800601:	b9 00 00 00 00       	mov    $0x0,%ecx
  800606:	8d 40 04             	lea    0x4(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800611:	e9 a3 00 00 00       	jmp    8006b9 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	8b 48 04             	mov    0x4(%eax),%ecx
  80061e:	8d 40 08             	lea    0x8(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800624:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800629:	e9 8b 00 00 00       	jmp    8006b9 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	b9 00 00 00 00       	mov    $0x0,%ecx
  800638:	8d 40 04             	lea    0x4(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800643:	eb 74                	jmp    8006b9 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800645:	83 f9 01             	cmp    $0x1,%ecx
  800648:	7f 1b                	jg     800665 <vprintfmt+0x354>
	else if (lflag)
  80064a:	85 c9                	test   %ecx,%ecx
  80064c:	74 2c                	je     80067a <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8b 10                	mov    (%eax),%edx
  800653:	b9 00 00 00 00       	mov    $0x0,%ecx
  800658:	8d 40 04             	lea    0x4(%eax),%eax
  80065b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80065e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800663:	eb 54                	jmp    8006b9 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	8b 48 04             	mov    0x4(%eax),%ecx
  80066d:	8d 40 08             	lea    0x8(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800673:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800678:	eb 3f                	jmp    8006b9 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800684:	8d 40 04             	lea    0x4(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80068a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80068f:	eb 28                	jmp    8006b9 <vprintfmt+0x3a8>
			putch('0', putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 30                	push   $0x30
  800697:	ff d6                	call   *%esi
			putch('x', putdat);
  800699:	83 c4 08             	add    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	6a 78                	push   $0x78
  80069f:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8b 10                	mov    (%eax),%edx
  8006a6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006ab:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ae:	8d 40 04             	lea    0x4(%eax),%eax
  8006b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b4:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006c0:	50                   	push   %eax
  8006c1:	ff 75 e0             	push   -0x20(%ebp)
  8006c4:	57                   	push   %edi
  8006c5:	51                   	push   %ecx
  8006c6:	52                   	push   %edx
  8006c7:	89 da                	mov    %ebx,%edx
  8006c9:	89 f0                	mov    %esi,%eax
  8006cb:	e8 5e fb ff ff       	call   80022e <printnum>
			break;
  8006d0:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d6:	e9 54 fc ff ff       	jmp    80032f <vprintfmt+0x1e>
	if (lflag >= 2)
  8006db:	83 f9 01             	cmp    $0x1,%ecx
  8006de:	7f 1b                	jg     8006fb <vprintfmt+0x3ea>
	else if (lflag)
  8006e0:	85 c9                	test   %ecx,%ecx
  8006e2:	74 2c                	je     800710 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006f9:	eb be                	jmp    8006b9 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8b 10                	mov    (%eax),%edx
  800700:	8b 48 04             	mov    0x4(%eax),%ecx
  800703:	8d 40 08             	lea    0x8(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800709:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80070e:	eb a9                	jmp    8006b9 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8b 10                	mov    (%eax),%edx
  800715:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071a:	8d 40 04             	lea    0x4(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800720:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800725:	eb 92                	jmp    8006b9 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	53                   	push   %ebx
  80072b:	6a 25                	push   $0x25
  80072d:	ff d6                	call   *%esi
			break;
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	eb 9f                	jmp    8006d3 <vprintfmt+0x3c2>
			putch('%', putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 25                	push   $0x25
  80073a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	89 f8                	mov    %edi,%eax
  800741:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800745:	74 05                	je     80074c <vprintfmt+0x43b>
  800747:	83 e8 01             	sub    $0x1,%eax
  80074a:	eb f5                	jmp    800741 <vprintfmt+0x430>
  80074c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074f:	eb 82                	jmp    8006d3 <vprintfmt+0x3c2>

00800751 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 18             	sub    $0x18,%esp
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800760:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800764:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800767:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076e:	85 c0                	test   %eax,%eax
  800770:	74 26                	je     800798 <vsnprintf+0x47>
  800772:	85 d2                	test   %edx,%edx
  800774:	7e 22                	jle    800798 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800776:	ff 75 14             	push   0x14(%ebp)
  800779:	ff 75 10             	push   0x10(%ebp)
  80077c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	68 d7 02 80 00       	push   $0x8002d7
  800785:	e8 87 fb ff ff       	call   800311 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800793:	83 c4 10             	add    $0x10,%esp
}
  800796:	c9                   	leave  
  800797:	c3                   	ret    
		return -E_INVAL;
  800798:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079d:	eb f7                	jmp    800796 <vsnprintf+0x45>

0080079f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a8:	50                   	push   %eax
  8007a9:	ff 75 10             	push   0x10(%ebp)
  8007ac:	ff 75 0c             	push   0xc(%ebp)
  8007af:	ff 75 08             	push   0x8(%ebp)
  8007b2:	e8 9a ff ff ff       	call   800751 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strlen+0x10>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cd:	75 f7                	jne    8007c6 <strlen+0xd>
	return n;
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
  8007df:	eb 03                	jmp    8007e4 <strnlen+0x13>
		n++;
  8007e1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	39 d0                	cmp    %edx,%eax
  8007e6:	74 08                	je     8007f0 <strnlen+0x1f>
  8007e8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ec:	75 f3                	jne    8007e1 <strnlen+0x10>
  8007ee:	89 c2                	mov    %eax,%edx
	return n;
}
  8007f0:	89 d0                	mov    %edx,%eax
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800803:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800807:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80080a:	83 c0 01             	add    $0x1,%eax
  80080d:	84 d2                	test   %dl,%dl
  80080f:	75 f2                	jne    800803 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800811:	89 c8                	mov    %ecx,%eax
  800813:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	83 ec 10             	sub    $0x10,%esp
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800822:	53                   	push   %ebx
  800823:	e8 91 ff ff ff       	call   8007b9 <strlen>
  800828:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80082b:	ff 75 0c             	push   0xc(%ebp)
  80082e:	01 d8                	add    %ebx,%eax
  800830:	50                   	push   %eax
  800831:	e8 be ff ff ff       	call   8007f4 <strcpy>
	return dst;
}
  800836:	89 d8                	mov    %ebx,%eax
  800838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	56                   	push   %esi
  800841:	53                   	push   %ebx
  800842:	8b 75 08             	mov    0x8(%ebp),%esi
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
  800848:	89 f3                	mov    %esi,%ebx
  80084a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	eb 0f                	jmp    800860 <strncpy+0x23>
		*dst++ = *src;
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	0f b6 0a             	movzbl (%edx),%ecx
  800857:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085a:	80 f9 01             	cmp    $0x1,%cl
  80085d:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800860:	39 d8                	cmp    %ebx,%eax
  800862:	75 ed                	jne    800851 <strncpy+0x14>
	}
	return ret;
}
  800864:	89 f0                	mov    %esi,%eax
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	56                   	push   %esi
  80086e:	53                   	push   %ebx
  80086f:	8b 75 08             	mov    0x8(%ebp),%esi
  800872:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800875:	8b 55 10             	mov    0x10(%ebp),%edx
  800878:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 d2                	test   %edx,%edx
  80087c:	74 21                	je     80089f <strlcpy+0x35>
  80087e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800882:	89 f2                	mov    %esi,%edx
  800884:	eb 09                	jmp    80088f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	83 c2 01             	add    $0x1,%edx
  80088c:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80088f:	39 c2                	cmp    %eax,%edx
  800891:	74 09                	je     80089c <strlcpy+0x32>
  800893:	0f b6 19             	movzbl (%ecx),%ebx
  800896:	84 db                	test   %bl,%bl
  800898:	75 ec                	jne    800886 <strlcpy+0x1c>
  80089a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80089c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089f:	29 f0                	sub    %esi,%eax
}
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ae:	eb 06                	jmp    8008b6 <strcmp+0x11>
		p++, q++;
  8008b0:	83 c1 01             	add    $0x1,%ecx
  8008b3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008b6:	0f b6 01             	movzbl (%ecx),%eax
  8008b9:	84 c0                	test   %al,%al
  8008bb:	74 04                	je     8008c1 <strcmp+0x1c>
  8008bd:	3a 02                	cmp    (%edx),%al
  8008bf:	74 ef                	je     8008b0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c1:	0f b6 c0             	movzbl %al,%eax
  8008c4:	0f b6 12             	movzbl (%edx),%edx
  8008c7:	29 d0                	sub    %edx,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d5:	89 c3                	mov    %eax,%ebx
  8008d7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008da:	eb 06                	jmp    8008e2 <strncmp+0x17>
		n--, p++, q++;
  8008dc:	83 c0 01             	add    $0x1,%eax
  8008df:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e2:	39 d8                	cmp    %ebx,%eax
  8008e4:	74 18                	je     8008fe <strncmp+0x33>
  8008e6:	0f b6 08             	movzbl (%eax),%ecx
  8008e9:	84 c9                	test   %cl,%cl
  8008eb:	74 04                	je     8008f1 <strncmp+0x26>
  8008ed:	3a 0a                	cmp    (%edx),%cl
  8008ef:	74 eb                	je     8008dc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f1:	0f b6 00             	movzbl (%eax),%eax
  8008f4:	0f b6 12             	movzbl (%edx),%edx
  8008f7:	29 d0                	sub    %edx,%eax
}
  8008f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    
		return 0;
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800903:	eb f4                	jmp    8008f9 <strncmp+0x2e>

00800905 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090f:	eb 03                	jmp    800914 <strchr+0xf>
  800911:	83 c0 01             	add    $0x1,%eax
  800914:	0f b6 10             	movzbl (%eax),%edx
  800917:	84 d2                	test   %dl,%dl
  800919:	74 06                	je     800921 <strchr+0x1c>
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	75 f2                	jne    800911 <strchr+0xc>
  80091f:	eb 05                	jmp    800926 <strchr+0x21>
			return (char *) s;
	return 0;
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800932:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800935:	38 ca                	cmp    %cl,%dl
  800937:	74 09                	je     800942 <strfind+0x1a>
  800939:	84 d2                	test   %dl,%dl
  80093b:	74 05                	je     800942 <strfind+0x1a>
	for (; *s; s++)
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	eb f0                	jmp    800932 <strfind+0xa>
			break;
	return (char *) s;
}
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800950:	85 c9                	test   %ecx,%ecx
  800952:	74 2f                	je     800983 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800954:	89 f8                	mov    %edi,%eax
  800956:	09 c8                	or     %ecx,%eax
  800958:	a8 03                	test   $0x3,%al
  80095a:	75 21                	jne    80097d <memset+0x39>
		c &= 0xFF;
  80095c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800960:	89 d0                	mov    %edx,%eax
  800962:	c1 e0 08             	shl    $0x8,%eax
  800965:	89 d3                	mov    %edx,%ebx
  800967:	c1 e3 18             	shl    $0x18,%ebx
  80096a:	89 d6                	mov    %edx,%esi
  80096c:	c1 e6 10             	shl    $0x10,%esi
  80096f:	09 f3                	or     %esi,%ebx
  800971:	09 da                	or     %ebx,%edx
  800973:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800975:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800978:	fc                   	cld    
  800979:	f3 ab                	rep stos %eax,%es:(%edi)
  80097b:	eb 06                	jmp    800983 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	fc                   	cld    
  800981:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800983:	89 f8                	mov    %edi,%eax
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	57                   	push   %edi
  80098e:	56                   	push   %esi
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 75 0c             	mov    0xc(%ebp),%esi
  800995:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800998:	39 c6                	cmp    %eax,%esi
  80099a:	73 32                	jae    8009ce <memmove+0x44>
  80099c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099f:	39 c2                	cmp    %eax,%edx
  8009a1:	76 2b                	jbe    8009ce <memmove+0x44>
		s += n;
		d += n;
  8009a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a6:	89 d6                	mov    %edx,%esi
  8009a8:	09 fe                	or     %edi,%esi
  8009aa:	09 ce                	or     %ecx,%esi
  8009ac:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b2:	75 0e                	jne    8009c2 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b4:	83 ef 04             	sub    $0x4,%edi
  8009b7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009bd:	fd                   	std    
  8009be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c0:	eb 09                	jmp    8009cb <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c2:	83 ef 01             	sub    $0x1,%edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 1a                	jmp    8009e8 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	89 f2                	mov    %esi,%edx
  8009d0:	09 c2                	or     %eax,%edx
  8009d2:	09 ca                	or     %ecx,%edx
  8009d4:	f6 c2 03             	test   $0x3,%dl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f2:	ff 75 10             	push   0x10(%ebp)
  8009f5:	ff 75 0c             	push   0xc(%ebp)
  8009f8:	ff 75 08             	push   0x8(%ebp)
  8009fb:	e8 8a ff ff ff       	call   80098a <memmove>
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 c6                	mov    %eax,%esi
  800a0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a12:	eb 06                	jmp    800a1a <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a14:	83 c0 01             	add    $0x1,%eax
  800a17:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a1a:	39 f0                	cmp    %esi,%eax
  800a1c:	74 14                	je     800a32 <memcmp+0x30>
		if (*s1 != *s2)
  800a1e:	0f b6 08             	movzbl (%eax),%ecx
  800a21:	0f b6 1a             	movzbl (%edx),%ebx
  800a24:	38 d9                	cmp    %bl,%cl
  800a26:	74 ec                	je     800a14 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a28:	0f b6 c1             	movzbl %cl,%eax
  800a2b:	0f b6 db             	movzbl %bl,%ebx
  800a2e:	29 d8                	sub    %ebx,%eax
  800a30:	eb 05                	jmp    800a37 <memcmp+0x35>
	}

	return 0;
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a44:	89 c2                	mov    %eax,%edx
  800a46:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a49:	eb 03                	jmp    800a4e <memfind+0x13>
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	39 d0                	cmp    %edx,%eax
  800a50:	73 04                	jae    800a56 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a52:	38 08                	cmp    %cl,(%eax)
  800a54:	75 f5                	jne    800a4b <memfind+0x10>
			break;
	return (void *) s;
}
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a64:	eb 03                	jmp    800a69 <strtol+0x11>
		s++;
  800a66:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a69:	0f b6 02             	movzbl (%edx),%eax
  800a6c:	3c 20                	cmp    $0x20,%al
  800a6e:	74 f6                	je     800a66 <strtol+0xe>
  800a70:	3c 09                	cmp    $0x9,%al
  800a72:	74 f2                	je     800a66 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a74:	3c 2b                	cmp    $0x2b,%al
  800a76:	74 2a                	je     800aa2 <strtol+0x4a>
	int neg = 0;
  800a78:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7d:	3c 2d                	cmp    $0x2d,%al
  800a7f:	74 2b                	je     800aac <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a81:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a87:	75 0f                	jne    800a98 <strtol+0x40>
  800a89:	80 3a 30             	cmpb   $0x30,(%edx)
  800a8c:	74 28                	je     800ab6 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8e:	85 db                	test   %ebx,%ebx
  800a90:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a95:	0f 44 d8             	cmove  %eax,%ebx
  800a98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa0:	eb 46                	jmp    800ae8 <strtol+0x90>
		s++;
  800aa2:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aa5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aaa:	eb d5                	jmp    800a81 <strtol+0x29>
		s++, neg = 1;
  800aac:	83 c2 01             	add    $0x1,%edx
  800aaf:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab4:	eb cb                	jmp    800a81 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab6:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aba:	74 0e                	je     800aca <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800abc:	85 db                	test   %ebx,%ebx
  800abe:	75 d8                	jne    800a98 <strtol+0x40>
		s++, base = 8;
  800ac0:	83 c2 01             	add    $0x1,%edx
  800ac3:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac8:	eb ce                	jmp    800a98 <strtol+0x40>
		s += 2, base = 16;
  800aca:	83 c2 02             	add    $0x2,%edx
  800acd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad2:	eb c4                	jmp    800a98 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad4:	0f be c0             	movsbl %al,%eax
  800ad7:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ada:	3b 45 10             	cmp    0x10(%ebp),%eax
  800add:	7d 3a                	jge    800b19 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800adf:	83 c2 01             	add    $0x1,%edx
  800ae2:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ae6:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ae8:	0f b6 02             	movzbl (%edx),%eax
  800aeb:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aee:	89 f3                	mov    %esi,%ebx
  800af0:	80 fb 09             	cmp    $0x9,%bl
  800af3:	76 df                	jbe    800ad4 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800af5:	8d 70 9f             	lea    -0x61(%eax),%esi
  800af8:	89 f3                	mov    %esi,%ebx
  800afa:	80 fb 19             	cmp    $0x19,%bl
  800afd:	77 08                	ja     800b07 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800aff:	0f be c0             	movsbl %al,%eax
  800b02:	83 e8 57             	sub    $0x57,%eax
  800b05:	eb d3                	jmp    800ada <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b07:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b0a:	89 f3                	mov    %esi,%ebx
  800b0c:	80 fb 19             	cmp    $0x19,%bl
  800b0f:	77 08                	ja     800b19 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b11:	0f be c0             	movsbl %al,%eax
  800b14:	83 e8 37             	sub    $0x37,%eax
  800b17:	eb c1                	jmp    800ada <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b19:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1d:	74 05                	je     800b24 <strtol+0xcc>
		*endptr = (char *) s;
  800b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b22:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b24:	89 c8                	mov    %ecx,%eax
  800b26:	f7 d8                	neg    %eax
  800b28:	85 ff                	test   %edi,%edi
  800b2a:	0f 45 c8             	cmovne %eax,%ecx
}
  800b2d:	89 c8                	mov    %ecx,%eax
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	b8 03 00 00 00       	mov    $0x3,%eax
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7f 08                	jg     800b9b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
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
  800b9f:	6a 03                	push   $0x3
  800ba1:	68 bf 26 80 00       	push   $0x8026bf
  800ba6:	6a 2a                	push   $0x2a
  800ba8:	68 dc 26 80 00       	push   $0x8026dc
  800bad:	e8 8d f5 ff ff       	call   80013f <_panic>

00800bb2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_yield>:

void
sys_yield(void)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be1:	89 d1                	mov    %edx,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf9:	be 00 00 00 00       	mov    $0x0,%esi
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	b8 04 00 00 00       	mov    $0x4,%eax
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	89 f7                	mov    %esi,%edi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800c20:	6a 04                	push   $0x4
  800c22:	68 bf 26 80 00       	push   $0x8026bf
  800c27:	6a 2a                	push   $0x2a
  800c29:	68 dc 26 80 00       	push   $0x8026dc
  800c2e:	e8 0c f5 ff ff       	call   80013f <_panic>

00800c33 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	b8 05 00 00 00       	mov    $0x5,%eax
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800c62:	6a 05                	push   $0x5
  800c64:	68 bf 26 80 00       	push   $0x8026bf
  800c69:	6a 2a                	push   $0x2a
  800c6b:	68 dc 26 80 00       	push   $0x8026dc
  800c70:	e8 ca f4 ff ff       	call   80013f <_panic>

00800c75 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c89:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800ca4:	6a 06                	push   $0x6
  800ca6:	68 bf 26 80 00       	push   $0x8026bf
  800cab:	6a 2a                	push   $0x2a
  800cad:	68 dc 26 80 00       	push   $0x8026dc
  800cb2:	e8 88 f4 ff ff       	call   80013f <_panic>

00800cb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ccb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800ce6:	6a 08                	push   $0x8
  800ce8:	68 bf 26 80 00       	push   $0x8026bf
  800ced:	6a 2a                	push   $0x2a
  800cef:	68 dc 26 80 00       	push   $0x8026dc
  800cf4:	e8 46 f4 ff ff       	call   80013f <_panic>

00800cf9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 09                	push   $0x9
  800d2a:	68 bf 26 80 00       	push   $0x8026bf
  800d2f:	6a 2a                	push   $0x2a
  800d31:	68 dc 26 80 00       	push   $0x8026dc
  800d36:	e8 04 f4 ff ff       	call   80013f <_panic>

00800d3b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7f 08                	jg     800d66 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0a                	push   $0xa
  800d6c:	68 bf 26 80 00       	push   $0x8026bf
  800d71:	6a 2a                	push   $0x2a
  800d73:	68 dc 26 80 00       	push   $0x8026dc
  800d78:	e8 c2 f3 ff ff       	call   80013f <_panic>

00800d7d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d99:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db6:	89 cb                	mov    %ecx,%ebx
  800db8:	89 cf                	mov    %ecx,%edi
  800dba:	89 ce                	mov    %ecx,%esi
  800dbc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7f 08                	jg     800dca <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 0d                	push   $0xd
  800dd0:	68 bf 26 80 00       	push   $0x8026bf
  800dd5:	6a 2a                	push   $0x2a
  800dd7:	68 dc 26 80 00       	push   $0x8026dc
  800ddc:	e8 5e f3 ff ff       	call   80013f <_panic>

00800de1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dec:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df1:	89 d1                	mov    %edx,%ecx
  800df3:	89 d3                	mov    %edx,%ebx
  800df5:	89 d7                	mov    %edx,%edi
  800df7:	89 d6                	mov    %edx,%esi
  800df9:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e16:	89 df                	mov    %ebx,%edi
  800e18:	89 de                	mov    %ebx,%esi
  800e1a:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e32:	b8 10 00 00 00       	mov    $0x10,%eax
  800e37:	89 df                	mov    %ebx,%edi
  800e39:	89 de                	mov    %ebx,%esi
  800e3b:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e55:	8b 45 08             	mov    0x8(%ebp),%eax
  800e58:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e62:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e71:	89 c2                	mov    %eax,%edx
  800e73:	c1 ea 16             	shr    $0x16,%edx
  800e76:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7d:	f6 c2 01             	test   $0x1,%dl
  800e80:	74 29                	je     800eab <fd_alloc+0x42>
  800e82:	89 c2                	mov    %eax,%edx
  800e84:	c1 ea 0c             	shr    $0xc,%edx
  800e87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8e:	f6 c2 01             	test   $0x1,%dl
  800e91:	74 18                	je     800eab <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e93:	05 00 10 00 00       	add    $0x1000,%eax
  800e98:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e9d:	75 d2                	jne    800e71 <fd_alloc+0x8>
  800e9f:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800ea4:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800ea9:	eb 05                	jmp    800eb0 <fd_alloc+0x47>
			return 0;
  800eab:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 02                	mov    %eax,(%edx)
}
  800eb5:	89 c8                	mov    %ecx,%eax
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ebf:	83 f8 1f             	cmp    $0x1f,%eax
  800ec2:	77 30                	ja     800ef4 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ec4:	c1 e0 0c             	shl    $0xc,%eax
  800ec7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ecc:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ed2:	f6 c2 01             	test   $0x1,%dl
  800ed5:	74 24                	je     800efb <fd_lookup+0x42>
  800ed7:	89 c2                	mov    %eax,%edx
  800ed9:	c1 ea 0c             	shr    $0xc,%edx
  800edc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee3:	f6 c2 01             	test   $0x1,%dl
  800ee6:	74 1a                	je     800f02 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eeb:	89 02                	mov    %eax,(%edx)
	return 0;
  800eed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    
		return -E_INVAL;
  800ef4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef9:	eb f7                	jmp    800ef2 <fd_lookup+0x39>
		return -E_INVAL;
  800efb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f00:	eb f0                	jmp    800ef2 <fd_lookup+0x39>
  800f02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f07:	eb e9                	jmp    800ef2 <fd_lookup+0x39>

00800f09 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	53                   	push   %ebx
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
  800f18:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f1d:	39 13                	cmp    %edx,(%ebx)
  800f1f:	74 37                	je     800f58 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f21:	83 c0 01             	add    $0x1,%eax
  800f24:	8b 1c 85 68 27 80 00 	mov    0x802768(,%eax,4),%ebx
  800f2b:	85 db                	test   %ebx,%ebx
  800f2d:	75 ee                	jne    800f1d <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f2f:	a1 00 40 c0 00       	mov    0xc04000,%eax
  800f34:	8b 40 58             	mov    0x58(%eax),%eax
  800f37:	83 ec 04             	sub    $0x4,%esp
  800f3a:	52                   	push   %edx
  800f3b:	50                   	push   %eax
  800f3c:	68 ec 26 80 00       	push   $0x8026ec
  800f41:	e8 d4 f2 ff ff       	call   80021a <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f51:	89 1a                	mov    %ebx,(%edx)
}
  800f53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    
			return 0;
  800f58:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5d:	eb ef                	jmp    800f4e <dev_lookup+0x45>

00800f5f <fd_close>:
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	57                   	push   %edi
  800f63:	56                   	push   %esi
  800f64:	53                   	push   %ebx
  800f65:	83 ec 24             	sub    $0x24,%esp
  800f68:	8b 75 08             	mov    0x8(%ebp),%esi
  800f6b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f71:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f72:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f78:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f7b:	50                   	push   %eax
  800f7c:	e8 38 ff ff ff       	call   800eb9 <fd_lookup>
  800f81:	89 c3                	mov    %eax,%ebx
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	78 05                	js     800f8f <fd_close+0x30>
	    || fd != fd2)
  800f8a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f8d:	74 16                	je     800fa5 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f8f:	89 f8                	mov    %edi,%eax
  800f91:	84 c0                	test   %al,%al
  800f93:	b8 00 00 00 00       	mov    $0x0,%eax
  800f98:	0f 44 d8             	cmove  %eax,%ebx
}
  800f9b:	89 d8                	mov    %ebx,%eax
  800f9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fa5:	83 ec 08             	sub    $0x8,%esp
  800fa8:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fab:	50                   	push   %eax
  800fac:	ff 36                	push   (%esi)
  800fae:	e8 56 ff ff ff       	call   800f09 <dev_lookup>
  800fb3:	89 c3                	mov    %eax,%ebx
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 1a                	js     800fd6 <fd_close+0x77>
		if (dev->dev_close)
  800fbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fbf:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fc2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	74 0b                	je     800fd6 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fcb:	83 ec 0c             	sub    $0xc,%esp
  800fce:	56                   	push   %esi
  800fcf:	ff d0                	call   *%eax
  800fd1:	89 c3                	mov    %eax,%ebx
  800fd3:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fd6:	83 ec 08             	sub    $0x8,%esp
  800fd9:	56                   	push   %esi
  800fda:	6a 00                	push   $0x0
  800fdc:	e8 94 fc ff ff       	call   800c75 <sys_page_unmap>
	return r;
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	eb b5                	jmp    800f9b <fd_close+0x3c>

00800fe6 <close>:

int
close(int fdnum)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fef:	50                   	push   %eax
  800ff0:	ff 75 08             	push   0x8(%ebp)
  800ff3:	e8 c1 fe ff ff       	call   800eb9 <fd_lookup>
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	79 02                	jns    801001 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800fff:	c9                   	leave  
  801000:	c3                   	ret    
		return fd_close(fd, 1);
  801001:	83 ec 08             	sub    $0x8,%esp
  801004:	6a 01                	push   $0x1
  801006:	ff 75 f4             	push   -0xc(%ebp)
  801009:	e8 51 ff ff ff       	call   800f5f <fd_close>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	eb ec                	jmp    800fff <close+0x19>

00801013 <close_all>:

void
close_all(void)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	53                   	push   %ebx
  801017:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80101a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	53                   	push   %ebx
  801023:	e8 be ff ff ff       	call   800fe6 <close>
	for (i = 0; i < MAXFD; i++)
  801028:	83 c3 01             	add    $0x1,%ebx
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	83 fb 20             	cmp    $0x20,%ebx
  801031:	75 ec                	jne    80101f <close_all+0xc>
}
  801033:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801036:	c9                   	leave  
  801037:	c3                   	ret    

00801038 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	57                   	push   %edi
  80103c:	56                   	push   %esi
  80103d:	53                   	push   %ebx
  80103e:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801041:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801044:	50                   	push   %eax
  801045:	ff 75 08             	push   0x8(%ebp)
  801048:	e8 6c fe ff ff       	call   800eb9 <fd_lookup>
  80104d:	89 c3                	mov    %eax,%ebx
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	78 7f                	js     8010d5 <dup+0x9d>
		return r;
	close(newfdnum);
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	ff 75 0c             	push   0xc(%ebp)
  80105c:	e8 85 ff ff ff       	call   800fe6 <close>

	newfd = INDEX2FD(newfdnum);
  801061:	8b 75 0c             	mov    0xc(%ebp),%esi
  801064:	c1 e6 0c             	shl    $0xc,%esi
  801067:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80106d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801070:	89 3c 24             	mov    %edi,(%esp)
  801073:	e8 da fd ff ff       	call   800e52 <fd2data>
  801078:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80107a:	89 34 24             	mov    %esi,(%esp)
  80107d:	e8 d0 fd ff ff       	call   800e52 <fd2data>
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801088:	89 d8                	mov    %ebx,%eax
  80108a:	c1 e8 16             	shr    $0x16,%eax
  80108d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801094:	a8 01                	test   $0x1,%al
  801096:	74 11                	je     8010a9 <dup+0x71>
  801098:	89 d8                	mov    %ebx,%eax
  80109a:	c1 e8 0c             	shr    $0xc,%eax
  80109d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a4:	f6 c2 01             	test   $0x1,%dl
  8010a7:	75 36                	jne    8010df <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a9:	89 f8                	mov    %edi,%eax
  8010ab:	c1 e8 0c             	shr    $0xc,%eax
  8010ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010bd:	50                   	push   %eax
  8010be:	56                   	push   %esi
  8010bf:	6a 00                	push   $0x0
  8010c1:	57                   	push   %edi
  8010c2:	6a 00                	push   $0x0
  8010c4:	e8 6a fb ff ff       	call   800c33 <sys_page_map>
  8010c9:	89 c3                	mov    %eax,%ebx
  8010cb:	83 c4 20             	add    $0x20,%esp
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	78 33                	js     801105 <dup+0xcd>
		goto err;

	return newfdnum;
  8010d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010d5:	89 d8                	mov    %ebx,%eax
  8010d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e6:	83 ec 0c             	sub    $0xc,%esp
  8010e9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ee:	50                   	push   %eax
  8010ef:	ff 75 d4             	push   -0x2c(%ebp)
  8010f2:	6a 00                	push   $0x0
  8010f4:	53                   	push   %ebx
  8010f5:	6a 00                	push   $0x0
  8010f7:	e8 37 fb ff ff       	call   800c33 <sys_page_map>
  8010fc:	89 c3                	mov    %eax,%ebx
  8010fe:	83 c4 20             	add    $0x20,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	79 a4                	jns    8010a9 <dup+0x71>
	sys_page_unmap(0, newfd);
  801105:	83 ec 08             	sub    $0x8,%esp
  801108:	56                   	push   %esi
  801109:	6a 00                	push   $0x0
  80110b:	e8 65 fb ff ff       	call   800c75 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801110:	83 c4 08             	add    $0x8,%esp
  801113:	ff 75 d4             	push   -0x2c(%ebp)
  801116:	6a 00                	push   $0x0
  801118:	e8 58 fb ff ff       	call   800c75 <sys_page_unmap>
	return r;
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	eb b3                	jmp    8010d5 <dup+0x9d>

00801122 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	56                   	push   %esi
  801126:	53                   	push   %ebx
  801127:	83 ec 18             	sub    $0x18,%esp
  80112a:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	56                   	push   %esi
  801132:	e8 82 fd ff ff       	call   800eb9 <fd_lookup>
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	85 c0                	test   %eax,%eax
  80113c:	78 3c                	js     80117a <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801147:	50                   	push   %eax
  801148:	ff 33                	push   (%ebx)
  80114a:	e8 ba fd ff ff       	call   800f09 <dev_lookup>
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 24                	js     80117a <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801156:	8b 43 08             	mov    0x8(%ebx),%eax
  801159:	83 e0 03             	and    $0x3,%eax
  80115c:	83 f8 01             	cmp    $0x1,%eax
  80115f:	74 20                	je     801181 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801161:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801164:	8b 40 08             	mov    0x8(%eax),%eax
  801167:	85 c0                	test   %eax,%eax
  801169:	74 37                	je     8011a2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80116b:	83 ec 04             	sub    $0x4,%esp
  80116e:	ff 75 10             	push   0x10(%ebp)
  801171:	ff 75 0c             	push   0xc(%ebp)
  801174:	53                   	push   %ebx
  801175:	ff d0                	call   *%eax
  801177:	83 c4 10             	add    $0x10,%esp
}
  80117a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117d:	5b                   	pop    %ebx
  80117e:	5e                   	pop    %esi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801181:	a1 00 40 c0 00       	mov    0xc04000,%eax
  801186:	8b 40 58             	mov    0x58(%eax),%eax
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	56                   	push   %esi
  80118d:	50                   	push   %eax
  80118e:	68 2d 27 80 00       	push   $0x80272d
  801193:	e8 82 f0 ff ff       	call   80021a <cprintf>
		return -E_INVAL;
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a0:	eb d8                	jmp    80117a <read+0x58>
		return -E_NOT_SUPP;
  8011a2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011a7:	eb d1                	jmp    80117a <read+0x58>

008011a9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	57                   	push   %edi
  8011ad:	56                   	push   %esi
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bd:	eb 02                	jmp    8011c1 <readn+0x18>
  8011bf:	01 c3                	add    %eax,%ebx
  8011c1:	39 f3                	cmp    %esi,%ebx
  8011c3:	73 21                	jae    8011e6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c5:	83 ec 04             	sub    $0x4,%esp
  8011c8:	89 f0                	mov    %esi,%eax
  8011ca:	29 d8                	sub    %ebx,%eax
  8011cc:	50                   	push   %eax
  8011cd:	89 d8                	mov    %ebx,%eax
  8011cf:	03 45 0c             	add    0xc(%ebp),%eax
  8011d2:	50                   	push   %eax
  8011d3:	57                   	push   %edi
  8011d4:	e8 49 ff ff ff       	call   801122 <read>
		if (m < 0)
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 04                	js     8011e4 <readn+0x3b>
			return m;
		if (m == 0)
  8011e0:	75 dd                	jne    8011bf <readn+0x16>
  8011e2:	eb 02                	jmp    8011e6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011e6:	89 d8                	mov    %ebx,%eax
  8011e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 18             	sub    $0x18,%esp
  8011f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fe:	50                   	push   %eax
  8011ff:	53                   	push   %ebx
  801200:	e8 b4 fc ff ff       	call   800eb9 <fd_lookup>
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 37                	js     801243 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	ff 36                	push   (%esi)
  801218:	e8 ec fc ff ff       	call   800f09 <dev_lookup>
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	78 1f                	js     801243 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801224:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801228:	74 20                	je     80124a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80122a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122d:	8b 40 0c             	mov    0xc(%eax),%eax
  801230:	85 c0                	test   %eax,%eax
  801232:	74 37                	je     80126b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	ff 75 10             	push   0x10(%ebp)
  80123a:	ff 75 0c             	push   0xc(%ebp)
  80123d:	56                   	push   %esi
  80123e:	ff d0                	call   *%eax
  801240:	83 c4 10             	add    $0x10,%esp
}
  801243:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801246:	5b                   	pop    %ebx
  801247:	5e                   	pop    %esi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80124a:	a1 00 40 c0 00       	mov    0xc04000,%eax
  80124f:	8b 40 58             	mov    0x58(%eax),%eax
  801252:	83 ec 04             	sub    $0x4,%esp
  801255:	53                   	push   %ebx
  801256:	50                   	push   %eax
  801257:	68 49 27 80 00       	push   $0x802749
  80125c:	e8 b9 ef ff ff       	call   80021a <cprintf>
		return -E_INVAL;
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801269:	eb d8                	jmp    801243 <write+0x53>
		return -E_NOT_SUPP;
  80126b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801270:	eb d1                	jmp    801243 <write+0x53>

00801272 <seek>:

int
seek(int fdnum, off_t offset)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	ff 75 08             	push   0x8(%ebp)
  80127f:	e8 35 fc ff ff       	call   800eb9 <fd_lookup>
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 0e                	js     801299 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801291:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	56                   	push   %esi
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 18             	sub    $0x18,%esp
  8012a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a9:	50                   	push   %eax
  8012aa:	53                   	push   %ebx
  8012ab:	e8 09 fc ff ff       	call   800eb9 <fd_lookup>
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 34                	js     8012eb <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b7:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	ff 36                	push   (%esi)
  8012c3:	e8 41 fc ff ff       	call   800f09 <dev_lookup>
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 1c                	js     8012eb <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012cf:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012d3:	74 1d                	je     8012f2 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d8:	8b 40 18             	mov    0x18(%eax),%eax
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	74 34                	je     801313 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012df:	83 ec 08             	sub    $0x8,%esp
  8012e2:	ff 75 0c             	push   0xc(%ebp)
  8012e5:	56                   	push   %esi
  8012e6:	ff d0                	call   *%eax
  8012e8:	83 c4 10             	add    $0x10,%esp
}
  8012eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ee:	5b                   	pop    %ebx
  8012ef:	5e                   	pop    %esi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012f2:	a1 00 40 c0 00       	mov    0xc04000,%eax
  8012f7:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012fa:	83 ec 04             	sub    $0x4,%esp
  8012fd:	53                   	push   %ebx
  8012fe:	50                   	push   %eax
  8012ff:	68 0c 27 80 00       	push   $0x80270c
  801304:	e8 11 ef ff ff       	call   80021a <cprintf>
		return -E_INVAL;
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801311:	eb d8                	jmp    8012eb <ftruncate+0x50>
		return -E_NOT_SUPP;
  801313:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801318:	eb d1                	jmp    8012eb <ftruncate+0x50>

0080131a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	56                   	push   %esi
  80131e:	53                   	push   %ebx
  80131f:	83 ec 18             	sub    $0x18,%esp
  801322:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801325:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	ff 75 08             	push   0x8(%ebp)
  80132c:	e8 88 fb ff ff       	call   800eb9 <fd_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 49                	js     801381 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801338:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	ff 36                	push   (%esi)
  801344:	e8 c0 fb ff ff       	call   800f09 <dev_lookup>
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 31                	js     801381 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801350:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801353:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801357:	74 2f                	je     801388 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801359:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80135c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801363:	00 00 00 
	stat->st_isdir = 0;
  801366:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80136d:	00 00 00 
	stat->st_dev = dev;
  801370:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	53                   	push   %ebx
  80137a:	56                   	push   %esi
  80137b:	ff 50 14             	call   *0x14(%eax)
  80137e:	83 c4 10             	add    $0x10,%esp
}
  801381:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801384:	5b                   	pop    %ebx
  801385:	5e                   	pop    %esi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    
		return -E_NOT_SUPP;
  801388:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80138d:	eb f2                	jmp    801381 <fstat+0x67>

0080138f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	6a 00                	push   $0x0
  801399:	ff 75 08             	push   0x8(%ebp)
  80139c:	e8 e4 01 00 00       	call   801585 <open>
  8013a1:	89 c3                	mov    %eax,%ebx
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	78 1b                	js     8013c5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	ff 75 0c             	push   0xc(%ebp)
  8013b0:	50                   	push   %eax
  8013b1:	e8 64 ff ff ff       	call   80131a <fstat>
  8013b6:	89 c6                	mov    %eax,%esi
	close(fd);
  8013b8:	89 1c 24             	mov    %ebx,(%esp)
  8013bb:	e8 26 fc ff ff       	call   800fe6 <close>
	return r;
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	89 f3                	mov    %esi,%ebx
}
  8013c5:	89 d8                	mov    %ebx,%eax
  8013c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ca:	5b                   	pop    %ebx
  8013cb:	5e                   	pop    %esi
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
  8013d3:	89 c6                	mov    %eax,%esi
  8013d5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013d7:	83 3d 00 60 c0 00 00 	cmpl   $0x0,0xc06000
  8013de:	74 27                	je     801407 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013e0:	6a 07                	push   $0x7
  8013e2:	68 00 50 c0 00       	push   $0xc05000
  8013e7:	56                   	push   %esi
  8013e8:	ff 35 00 60 c0 00    	push   0xc06000
  8013ee:	e8 cd 0b 00 00       	call   801fc0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f3:	83 c4 0c             	add    $0xc,%esp
  8013f6:	6a 00                	push   $0x0
  8013f8:	53                   	push   %ebx
  8013f9:	6a 00                	push   $0x0
  8013fb:	e8 50 0b 00 00       	call   801f50 <ipc_recv>
}
  801400:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801403:	5b                   	pop    %ebx
  801404:	5e                   	pop    %esi
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801407:	83 ec 0c             	sub    $0xc,%esp
  80140a:	6a 01                	push   $0x1
  80140c:	e8 03 0c 00 00       	call   802014 <ipc_find_env>
  801411:	a3 00 60 c0 00       	mov    %eax,0xc06000
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	eb c5                	jmp    8013e0 <fsipc+0x12>

0080141b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	8b 40 0c             	mov    0xc(%eax),%eax
  801427:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  80142c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142f:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801434:	ba 00 00 00 00       	mov    $0x0,%edx
  801439:	b8 02 00 00 00       	mov    $0x2,%eax
  80143e:	e8 8b ff ff ff       	call   8013ce <fsipc>
}
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <devfile_flush>:
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80144b:	8b 45 08             	mov    0x8(%ebp),%eax
  80144e:	8b 40 0c             	mov    0xc(%eax),%eax
  801451:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801456:	ba 00 00 00 00       	mov    $0x0,%edx
  80145b:	b8 06 00 00 00       	mov    $0x6,%eax
  801460:	e8 69 ff ff ff       	call   8013ce <fsipc>
}
  801465:	c9                   	leave  
  801466:	c3                   	ret    

00801467 <devfile_stat>:
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	53                   	push   %ebx
  80146b:	83 ec 04             	sub    $0x4,%esp
  80146e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801471:	8b 45 08             	mov    0x8(%ebp),%eax
  801474:	8b 40 0c             	mov    0xc(%eax),%eax
  801477:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80147c:	ba 00 00 00 00       	mov    $0x0,%edx
  801481:	b8 05 00 00 00       	mov    $0x5,%eax
  801486:	e8 43 ff ff ff       	call   8013ce <fsipc>
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 2c                	js     8014bb <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80148f:	83 ec 08             	sub    $0x8,%esp
  801492:	68 00 50 c0 00       	push   $0xc05000
  801497:	53                   	push   %ebx
  801498:	e8 57 f3 ff ff       	call   8007f4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80149d:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8014a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014a8:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8014ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014be:	c9                   	leave  
  8014bf:	c3                   	ret    

008014c0 <devfile_write>:
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8014c9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014ce:	39 d0                	cmp    %edx,%eax
  8014d0:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d9:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  8014df:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014e4:	50                   	push   %eax
  8014e5:	ff 75 0c             	push   0xc(%ebp)
  8014e8:	68 08 50 c0 00       	push   $0xc05008
  8014ed:	e8 98 f4 ff ff       	call   80098a <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8014f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014fc:	e8 cd fe ff ff       	call   8013ce <fsipc>
}
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <devfile_read>:
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	56                   	push   %esi
  801507:	53                   	push   %ebx
  801508:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	8b 40 0c             	mov    0xc(%eax),%eax
  801511:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801516:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80151c:	ba 00 00 00 00       	mov    $0x0,%edx
  801521:	b8 03 00 00 00       	mov    $0x3,%eax
  801526:	e8 a3 fe ff ff       	call   8013ce <fsipc>
  80152b:	89 c3                	mov    %eax,%ebx
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 1f                	js     801550 <devfile_read+0x4d>
	assert(r <= n);
  801531:	39 f0                	cmp    %esi,%eax
  801533:	77 24                	ja     801559 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801535:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80153a:	7f 33                	jg     80156f <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80153c:	83 ec 04             	sub    $0x4,%esp
  80153f:	50                   	push   %eax
  801540:	68 00 50 c0 00       	push   $0xc05000
  801545:	ff 75 0c             	push   0xc(%ebp)
  801548:	e8 3d f4 ff ff       	call   80098a <memmove>
	return r;
  80154d:	83 c4 10             	add    $0x10,%esp
}
  801550:	89 d8                	mov    %ebx,%eax
  801552:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801555:	5b                   	pop    %ebx
  801556:	5e                   	pop    %esi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    
	assert(r <= n);
  801559:	68 7c 27 80 00       	push   $0x80277c
  80155e:	68 83 27 80 00       	push   $0x802783
  801563:	6a 7c                	push   $0x7c
  801565:	68 98 27 80 00       	push   $0x802798
  80156a:	e8 d0 eb ff ff       	call   80013f <_panic>
	assert(r <= PGSIZE);
  80156f:	68 a3 27 80 00       	push   $0x8027a3
  801574:	68 83 27 80 00       	push   $0x802783
  801579:	6a 7d                	push   $0x7d
  80157b:	68 98 27 80 00       	push   $0x802798
  801580:	e8 ba eb ff ff       	call   80013f <_panic>

00801585 <open>:
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	56                   	push   %esi
  801589:	53                   	push   %ebx
  80158a:	83 ec 1c             	sub    $0x1c,%esp
  80158d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801590:	56                   	push   %esi
  801591:	e8 23 f2 ff ff       	call   8007b9 <strlen>
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80159e:	7f 6c                	jg     80160c <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015a0:	83 ec 0c             	sub    $0xc,%esp
  8015a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	e8 bd f8 ff ff       	call   800e69 <fd_alloc>
  8015ac:	89 c3                	mov    %eax,%ebx
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 3c                	js     8015f1 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	56                   	push   %esi
  8015b9:	68 00 50 c0 00       	push   $0xc05000
  8015be:	e8 31 f2 ff ff       	call   8007f4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c6:	a3 00 54 c0 00       	mov    %eax,0xc05400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d3:	e8 f6 fd ff ff       	call   8013ce <fsipc>
  8015d8:	89 c3                	mov    %eax,%ebx
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 19                	js     8015fa <open+0x75>
	return fd2num(fd);
  8015e1:	83 ec 0c             	sub    $0xc,%esp
  8015e4:	ff 75 f4             	push   -0xc(%ebp)
  8015e7:	e8 56 f8 ff ff       	call   800e42 <fd2num>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	83 c4 10             	add    $0x10,%esp
}
  8015f1:	89 d8                	mov    %ebx,%eax
  8015f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f6:	5b                   	pop    %ebx
  8015f7:	5e                   	pop    %esi
  8015f8:	5d                   	pop    %ebp
  8015f9:	c3                   	ret    
		fd_close(fd, 0);
  8015fa:	83 ec 08             	sub    $0x8,%esp
  8015fd:	6a 00                	push   $0x0
  8015ff:	ff 75 f4             	push   -0xc(%ebp)
  801602:	e8 58 f9 ff ff       	call   800f5f <fd_close>
		return r;
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb e5                	jmp    8015f1 <open+0x6c>
		return -E_BAD_PATH;
  80160c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801611:	eb de                	jmp    8015f1 <open+0x6c>

00801613 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801619:	ba 00 00 00 00       	mov    $0x0,%edx
  80161e:	b8 08 00 00 00       	mov    $0x8,%eax
  801623:	e8 a6 fd ff ff       	call   8013ce <fsipc>
}
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801630:	68 af 27 80 00       	push   $0x8027af
  801635:	ff 75 0c             	push   0xc(%ebp)
  801638:	e8 b7 f1 ff ff       	call   8007f4 <strcpy>
	return 0;
}
  80163d:	b8 00 00 00 00       	mov    $0x0,%eax
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <devsock_close>:
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	53                   	push   %ebx
  801648:	83 ec 10             	sub    $0x10,%esp
  80164b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80164e:	53                   	push   %ebx
  80164f:	e8 ff 09 00 00       	call   802053 <pageref>
  801654:	89 c2                	mov    %eax,%edx
  801656:	83 c4 10             	add    $0x10,%esp
		return 0;
  801659:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80165e:	83 fa 01             	cmp    $0x1,%edx
  801661:	74 05                	je     801668 <devsock_close+0x24>
}
  801663:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801666:	c9                   	leave  
  801667:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	ff 73 0c             	push   0xc(%ebx)
  80166e:	e8 b7 02 00 00       	call   80192a <nsipc_close>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	eb eb                	jmp    801663 <devsock_close+0x1f>

00801678 <devsock_write>:
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80167e:	6a 00                	push   $0x0
  801680:	ff 75 10             	push   0x10(%ebp)
  801683:	ff 75 0c             	push   0xc(%ebp)
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	ff 70 0c             	push   0xc(%eax)
  80168c:	e8 79 03 00 00       	call   801a0a <nsipc_send>
}
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <devsock_read>:
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801699:	6a 00                	push   $0x0
  80169b:	ff 75 10             	push   0x10(%ebp)
  80169e:	ff 75 0c             	push   0xc(%ebp)
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	ff 70 0c             	push   0xc(%eax)
  8016a7:	e8 ef 02 00 00       	call   80199b <nsipc_recv>
}
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <fd2sockid>:
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016b4:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016b7:	52                   	push   %edx
  8016b8:	50                   	push   %eax
  8016b9:	e8 fb f7 ff ff       	call   800eb9 <fd_lookup>
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 10                	js     8016d5 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c8:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016ce:	39 08                	cmp    %ecx,(%eax)
  8016d0:	75 05                	jne    8016d7 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8016d2:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    
		return -E_NOT_SUPP;
  8016d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016dc:	eb f7                	jmp    8016d5 <fd2sockid+0x27>

008016de <alloc_sockfd>:
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 1c             	sub    $0x1c,%esp
  8016e6:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8016e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	e8 78 f7 ff ff       	call   800e69 <fd_alloc>
  8016f1:	89 c3                	mov    %eax,%ebx
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 43                	js     80173d <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016fa:	83 ec 04             	sub    $0x4,%esp
  8016fd:	68 07 04 00 00       	push   $0x407
  801702:	ff 75 f4             	push   -0xc(%ebp)
  801705:	6a 00                	push   $0x0
  801707:	e8 e4 f4 ff ff       	call   800bf0 <sys_page_alloc>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 28                	js     80173d <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801718:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80171e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801720:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801723:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80172a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80172d:	83 ec 0c             	sub    $0xc,%esp
  801730:	50                   	push   %eax
  801731:	e8 0c f7 ff ff       	call   800e42 <fd2num>
  801736:	89 c3                	mov    %eax,%ebx
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	eb 0c                	jmp    801749 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80173d:	83 ec 0c             	sub    $0xc,%esp
  801740:	56                   	push   %esi
  801741:	e8 e4 01 00 00       	call   80192a <nsipc_close>
		return r;
  801746:	83 c4 10             	add    $0x10,%esp
}
  801749:	89 d8                	mov    %ebx,%eax
  80174b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174e:	5b                   	pop    %ebx
  80174f:	5e                   	pop    %esi
  801750:	5d                   	pop    %ebp
  801751:	c3                   	ret    

00801752 <accept>:
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	e8 4e ff ff ff       	call   8016ae <fd2sockid>
  801760:	85 c0                	test   %eax,%eax
  801762:	78 1b                	js     80177f <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801764:	83 ec 04             	sub    $0x4,%esp
  801767:	ff 75 10             	push   0x10(%ebp)
  80176a:	ff 75 0c             	push   0xc(%ebp)
  80176d:	50                   	push   %eax
  80176e:	e8 0e 01 00 00       	call   801881 <nsipc_accept>
  801773:	83 c4 10             	add    $0x10,%esp
  801776:	85 c0                	test   %eax,%eax
  801778:	78 05                	js     80177f <accept+0x2d>
	return alloc_sockfd(r);
  80177a:	e8 5f ff ff ff       	call   8016de <alloc_sockfd>
}
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <bind>:
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801787:	8b 45 08             	mov    0x8(%ebp),%eax
  80178a:	e8 1f ff ff ff       	call   8016ae <fd2sockid>
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 12                	js     8017a5 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801793:	83 ec 04             	sub    $0x4,%esp
  801796:	ff 75 10             	push   0x10(%ebp)
  801799:	ff 75 0c             	push   0xc(%ebp)
  80179c:	50                   	push   %eax
  80179d:	e8 31 01 00 00       	call   8018d3 <nsipc_bind>
  8017a2:	83 c4 10             	add    $0x10,%esp
}
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <shutdown>:
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	e8 f9 fe ff ff       	call   8016ae <fd2sockid>
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 0f                	js     8017c8 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	ff 75 0c             	push   0xc(%ebp)
  8017bf:	50                   	push   %eax
  8017c0:	e8 43 01 00 00       	call   801908 <nsipc_shutdown>
  8017c5:	83 c4 10             	add    $0x10,%esp
}
  8017c8:	c9                   	leave  
  8017c9:	c3                   	ret    

008017ca <connect>:
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	e8 d6 fe ff ff       	call   8016ae <fd2sockid>
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	78 12                	js     8017ee <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	ff 75 10             	push   0x10(%ebp)
  8017e2:	ff 75 0c             	push   0xc(%ebp)
  8017e5:	50                   	push   %eax
  8017e6:	e8 59 01 00 00       	call   801944 <nsipc_connect>
  8017eb:	83 c4 10             	add    $0x10,%esp
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <listen>:
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	e8 b0 fe ff ff       	call   8016ae <fd2sockid>
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 0f                	js     801811 <listen+0x21>
	return nsipc_listen(r, backlog);
  801802:	83 ec 08             	sub    $0x8,%esp
  801805:	ff 75 0c             	push   0xc(%ebp)
  801808:	50                   	push   %eax
  801809:	e8 6b 01 00 00       	call   801979 <nsipc_listen>
  80180e:	83 c4 10             	add    $0x10,%esp
}
  801811:	c9                   	leave  
  801812:	c3                   	ret    

00801813 <socket>:

int
socket(int domain, int type, int protocol)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801819:	ff 75 10             	push   0x10(%ebp)
  80181c:	ff 75 0c             	push   0xc(%ebp)
  80181f:	ff 75 08             	push   0x8(%ebp)
  801822:	e8 41 02 00 00       	call   801a68 <nsipc_socket>
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 05                	js     801833 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80182e:	e8 ab fe ff ff       	call   8016de <alloc_sockfd>
}
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	53                   	push   %ebx
  801839:	83 ec 04             	sub    $0x4,%esp
  80183c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80183e:	83 3d 00 80 c0 00 00 	cmpl   $0x0,0xc08000
  801845:	74 26                	je     80186d <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801847:	6a 07                	push   $0x7
  801849:	68 00 70 c0 00       	push   $0xc07000
  80184e:	53                   	push   %ebx
  80184f:	ff 35 00 80 c0 00    	push   0xc08000
  801855:	e8 66 07 00 00       	call   801fc0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80185a:	83 c4 0c             	add    $0xc,%esp
  80185d:	6a 00                	push   $0x0
  80185f:	6a 00                	push   $0x0
  801861:	6a 00                	push   $0x0
  801863:	e8 e8 06 00 00       	call   801f50 <ipc_recv>
}
  801868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	6a 02                	push   $0x2
  801872:	e8 9d 07 00 00       	call   802014 <ipc_find_env>
  801877:	a3 00 80 c0 00       	mov    %eax,0xc08000
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	eb c6                	jmp    801847 <nsipc+0x12>

00801881 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	a3 00 70 c0 00       	mov    %eax,0xc07000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801891:	8b 06                	mov    (%esi),%eax
  801893:	a3 04 70 c0 00       	mov    %eax,0xc07004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801898:	b8 01 00 00 00       	mov    $0x1,%eax
  80189d:	e8 93 ff ff ff       	call   801835 <nsipc>
  8018a2:	89 c3                	mov    %eax,%ebx
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	79 09                	jns    8018b1 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8018a8:	89 d8                	mov    %ebx,%eax
  8018aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ad:	5b                   	pop    %ebx
  8018ae:	5e                   	pop    %esi
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018b1:	83 ec 04             	sub    $0x4,%esp
  8018b4:	ff 35 10 70 c0 00    	push   0xc07010
  8018ba:	68 00 70 c0 00       	push   $0xc07000
  8018bf:	ff 75 0c             	push   0xc(%ebp)
  8018c2:	e8 c3 f0 ff ff       	call   80098a <memmove>
		*addrlen = ret->ret_addrlen;
  8018c7:	a1 10 70 c0 00       	mov    0xc07010,%eax
  8018cc:	89 06                	mov    %eax,(%esi)
  8018ce:	83 c4 10             	add    $0x10,%esp
	return r;
  8018d1:	eb d5                	jmp    8018a8 <nsipc_accept+0x27>

008018d3 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	53                   	push   %ebx
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e0:	a3 00 70 c0 00       	mov    %eax,0xc07000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018e5:	53                   	push   %ebx
  8018e6:	ff 75 0c             	push   0xc(%ebp)
  8018e9:	68 04 70 c0 00       	push   $0xc07004
  8018ee:	e8 97 f0 ff ff       	call   80098a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018f3:	89 1d 14 70 c0 00    	mov    %ebx,0xc07014
	return nsipc(NSREQ_BIND);
  8018f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8018fe:	e8 32 ff ff ff       	call   801835 <nsipc>
}
  801903:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80190e:	8b 45 08             	mov    0x8(%ebp),%eax
  801911:	a3 00 70 c0 00       	mov    %eax,0xc07000
	nsipcbuf.shutdown.req_how = how;
  801916:	8b 45 0c             	mov    0xc(%ebp),%eax
  801919:	a3 04 70 c0 00       	mov    %eax,0xc07004
	return nsipc(NSREQ_SHUTDOWN);
  80191e:	b8 03 00 00 00       	mov    $0x3,%eax
  801923:	e8 0d ff ff ff       	call   801835 <nsipc>
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <nsipc_close>:

int
nsipc_close(int s)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	a3 00 70 c0 00       	mov    %eax,0xc07000
	return nsipc(NSREQ_CLOSE);
  801938:	b8 04 00 00 00       	mov    $0x4,%eax
  80193d:	e8 f3 fe ff ff       	call   801835 <nsipc>
}
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	53                   	push   %ebx
  801948:	83 ec 08             	sub    $0x8,%esp
  80194b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	a3 00 70 c0 00       	mov    %eax,0xc07000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801956:	53                   	push   %ebx
  801957:	ff 75 0c             	push   0xc(%ebp)
  80195a:	68 04 70 c0 00       	push   $0xc07004
  80195f:	e8 26 f0 ff ff       	call   80098a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801964:	89 1d 14 70 c0 00    	mov    %ebx,0xc07014
	return nsipc(NSREQ_CONNECT);
  80196a:	b8 05 00 00 00       	mov    $0x5,%eax
  80196f:	e8 c1 fe ff ff       	call   801835 <nsipc>
}
  801974:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801977:	c9                   	leave  
  801978:	c3                   	ret    

00801979 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	a3 00 70 c0 00       	mov    %eax,0xc07000
	nsipcbuf.listen.req_backlog = backlog;
  801987:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198a:	a3 04 70 c0 00       	mov    %eax,0xc07004
	return nsipc(NSREQ_LISTEN);
  80198f:	b8 06 00 00 00       	mov    $0x6,%eax
  801994:	e8 9c fe ff ff       	call   801835 <nsipc>
}
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	56                   	push   %esi
  80199f:	53                   	push   %ebx
  8019a0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a6:	a3 00 70 c0 00       	mov    %eax,0xc07000
	nsipcbuf.recv.req_len = len;
  8019ab:	89 35 04 70 c0 00    	mov    %esi,0xc07004
	nsipcbuf.recv.req_flags = flags;
  8019b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b4:	a3 08 70 c0 00       	mov    %eax,0xc07008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019b9:	b8 07 00 00 00       	mov    $0x7,%eax
  8019be:	e8 72 fe ff ff       	call   801835 <nsipc>
  8019c3:	89 c3                	mov    %eax,%ebx
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 22                	js     8019eb <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8019c9:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019ce:	39 c6                	cmp    %eax,%esi
  8019d0:	0f 4e c6             	cmovle %esi,%eax
  8019d3:	39 c3                	cmp    %eax,%ebx
  8019d5:	7f 1d                	jg     8019f4 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019d7:	83 ec 04             	sub    $0x4,%esp
  8019da:	53                   	push   %ebx
  8019db:	68 00 70 c0 00       	push   $0xc07000
  8019e0:	ff 75 0c             	push   0xc(%ebp)
  8019e3:	e8 a2 ef ff ff       	call   80098a <memmove>
  8019e8:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019eb:	89 d8                	mov    %ebx,%eax
  8019ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f0:	5b                   	pop    %ebx
  8019f1:	5e                   	pop    %esi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8019f4:	68 bb 27 80 00       	push   $0x8027bb
  8019f9:	68 83 27 80 00       	push   $0x802783
  8019fe:	6a 62                	push   $0x62
  801a00:	68 d0 27 80 00       	push   $0x8027d0
  801a05:	e8 35 e7 ff ff       	call   80013f <_panic>

00801a0a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 04             	sub    $0x4,%esp
  801a11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a14:	8b 45 08             	mov    0x8(%ebp),%eax
  801a17:	a3 00 70 c0 00       	mov    %eax,0xc07000
	assert(size < 1600);
  801a1c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a22:	7f 2e                	jg     801a52 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	53                   	push   %ebx
  801a28:	ff 75 0c             	push   0xc(%ebp)
  801a2b:	68 0c 70 c0 00       	push   $0xc0700c
  801a30:	e8 55 ef ff ff       	call   80098a <memmove>
	nsipcbuf.send.req_size = size;
  801a35:	89 1d 04 70 c0 00    	mov    %ebx,0xc07004
	nsipcbuf.send.req_flags = flags;
  801a3b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3e:	a3 08 70 c0 00       	mov    %eax,0xc07008
	return nsipc(NSREQ_SEND);
  801a43:	b8 08 00 00 00       	mov    $0x8,%eax
  801a48:	e8 e8 fd ff ff       	call   801835 <nsipc>
}
  801a4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    
	assert(size < 1600);
  801a52:	68 dc 27 80 00       	push   $0x8027dc
  801a57:	68 83 27 80 00       	push   $0x802783
  801a5c:	6a 6d                	push   $0x6d
  801a5e:	68 d0 27 80 00       	push   $0x8027d0
  801a63:	e8 d7 e6 ff ff       	call   80013f <_panic>

00801a68 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	a3 00 70 c0 00       	mov    %eax,0xc07000
	nsipcbuf.socket.req_type = type;
  801a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a79:	a3 04 70 c0 00       	mov    %eax,0xc07004
	nsipcbuf.socket.req_protocol = protocol;
  801a7e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a81:	a3 08 70 c0 00       	mov    %eax,0xc07008
	return nsipc(NSREQ_SOCKET);
  801a86:	b8 09 00 00 00       	mov    $0x9,%eax
  801a8b:	e8 a5 fd ff ff       	call   801835 <nsipc>
}
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
  801a97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	ff 75 08             	push   0x8(%ebp)
  801aa0:	e8 ad f3 ff ff       	call   800e52 <fd2data>
  801aa5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aa7:	83 c4 08             	add    $0x8,%esp
  801aaa:	68 e8 27 80 00       	push   $0x8027e8
  801aaf:	53                   	push   %ebx
  801ab0:	e8 3f ed ff ff       	call   8007f4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ab5:	8b 46 04             	mov    0x4(%esi),%eax
  801ab8:	2b 06                	sub    (%esi),%eax
  801aba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ac0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ac7:	00 00 00 
	stat->st_dev = &devpipe;
  801aca:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ad1:	30 80 00 
	return 0;
}
  801ad4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aea:	53                   	push   %ebx
  801aeb:	6a 00                	push   $0x0
  801aed:	e8 83 f1 ff ff       	call   800c75 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801af2:	89 1c 24             	mov    %ebx,(%esp)
  801af5:	e8 58 f3 ff ff       	call   800e52 <fd2data>
  801afa:	83 c4 08             	add    $0x8,%esp
  801afd:	50                   	push   %eax
  801afe:	6a 00                	push   $0x0
  801b00:	e8 70 f1 ff ff       	call   800c75 <sys_page_unmap>
}
  801b05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <_pipeisclosed>:
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	57                   	push   %edi
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 1c             	sub    $0x1c,%esp
  801b13:	89 c7                	mov    %eax,%edi
  801b15:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b17:	a1 00 40 c0 00       	mov    0xc04000,%eax
  801b1c:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	57                   	push   %edi
  801b23:	e8 2b 05 00 00       	call   802053 <pageref>
  801b28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b2b:	89 34 24             	mov    %esi,(%esp)
  801b2e:	e8 20 05 00 00       	call   802053 <pageref>
		nn = thisenv->env_runs;
  801b33:	8b 15 00 40 c0 00    	mov    0xc04000,%edx
  801b39:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	39 cb                	cmp    %ecx,%ebx
  801b41:	74 1b                	je     801b5e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b43:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b46:	75 cf                	jne    801b17 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b48:	8b 42 68             	mov    0x68(%edx),%eax
  801b4b:	6a 01                	push   $0x1
  801b4d:	50                   	push   %eax
  801b4e:	53                   	push   %ebx
  801b4f:	68 ef 27 80 00       	push   $0x8027ef
  801b54:	e8 c1 e6 ff ff       	call   80021a <cprintf>
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	eb b9                	jmp    801b17 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b5e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b61:	0f 94 c0             	sete   %al
  801b64:	0f b6 c0             	movzbl %al,%eax
}
  801b67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6a:	5b                   	pop    %ebx
  801b6b:	5e                   	pop    %esi
  801b6c:	5f                   	pop    %edi
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <devpipe_write>:
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	57                   	push   %edi
  801b73:	56                   	push   %esi
  801b74:	53                   	push   %ebx
  801b75:	83 ec 28             	sub    $0x28,%esp
  801b78:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b7b:	56                   	push   %esi
  801b7c:	e8 d1 f2 ff ff       	call   800e52 <fd2data>
  801b81:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	bf 00 00 00 00       	mov    $0x0,%edi
  801b8b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b8e:	75 09                	jne    801b99 <devpipe_write+0x2a>
	return i;
  801b90:	89 f8                	mov    %edi,%eax
  801b92:	eb 23                	jmp    801bb7 <devpipe_write+0x48>
			sys_yield();
  801b94:	e8 38 f0 ff ff       	call   800bd1 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b99:	8b 43 04             	mov    0x4(%ebx),%eax
  801b9c:	8b 0b                	mov    (%ebx),%ecx
  801b9e:	8d 51 20             	lea    0x20(%ecx),%edx
  801ba1:	39 d0                	cmp    %edx,%eax
  801ba3:	72 1a                	jb     801bbf <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ba5:	89 da                	mov    %ebx,%edx
  801ba7:	89 f0                	mov    %esi,%eax
  801ba9:	e8 5c ff ff ff       	call   801b0a <_pipeisclosed>
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	74 e2                	je     801b94 <devpipe_write+0x25>
				return 0;
  801bb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5f                   	pop    %edi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bc6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc9:	89 c2                	mov    %eax,%edx
  801bcb:	c1 fa 1f             	sar    $0x1f,%edx
  801bce:	89 d1                	mov    %edx,%ecx
  801bd0:	c1 e9 1b             	shr    $0x1b,%ecx
  801bd3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bd6:	83 e2 1f             	and    $0x1f,%edx
  801bd9:	29 ca                	sub    %ecx,%edx
  801bdb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bdf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801be3:	83 c0 01             	add    $0x1,%eax
  801be6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801be9:	83 c7 01             	add    $0x1,%edi
  801bec:	eb 9d                	jmp    801b8b <devpipe_write+0x1c>

00801bee <devpipe_read>:
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 18             	sub    $0x18,%esp
  801bf7:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bfa:	57                   	push   %edi
  801bfb:	e8 52 f2 ff ff       	call   800e52 <fd2data>
  801c00:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	be 00 00 00 00       	mov    $0x0,%esi
  801c0a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c0d:	75 13                	jne    801c22 <devpipe_read+0x34>
	return i;
  801c0f:	89 f0                	mov    %esi,%eax
  801c11:	eb 02                	jmp    801c15 <devpipe_read+0x27>
				return i;
  801c13:	89 f0                	mov    %esi,%eax
}
  801c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c18:	5b                   	pop    %ebx
  801c19:	5e                   	pop    %esi
  801c1a:	5f                   	pop    %edi
  801c1b:	5d                   	pop    %ebp
  801c1c:	c3                   	ret    
			sys_yield();
  801c1d:	e8 af ef ff ff       	call   800bd1 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c22:	8b 03                	mov    (%ebx),%eax
  801c24:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c27:	75 18                	jne    801c41 <devpipe_read+0x53>
			if (i > 0)
  801c29:	85 f6                	test   %esi,%esi
  801c2b:	75 e6                	jne    801c13 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801c2d:	89 da                	mov    %ebx,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	e8 d4 fe ff ff       	call   801b0a <_pipeisclosed>
  801c36:	85 c0                	test   %eax,%eax
  801c38:	74 e3                	je     801c1d <devpipe_read+0x2f>
				return 0;
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3f:	eb d4                	jmp    801c15 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c41:	99                   	cltd   
  801c42:	c1 ea 1b             	shr    $0x1b,%edx
  801c45:	01 d0                	add    %edx,%eax
  801c47:	83 e0 1f             	and    $0x1f,%eax
  801c4a:	29 d0                	sub    %edx,%eax
  801c4c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c54:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c57:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c5a:	83 c6 01             	add    $0x1,%esi
  801c5d:	eb ab                	jmp    801c0a <devpipe_read+0x1c>

00801c5f <pipe>:
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6a:	50                   	push   %eax
  801c6b:	e8 f9 f1 ff ff       	call   800e69 <fd_alloc>
  801c70:	89 c3                	mov    %eax,%ebx
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	85 c0                	test   %eax,%eax
  801c77:	0f 88 23 01 00 00    	js     801da0 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7d:	83 ec 04             	sub    $0x4,%esp
  801c80:	68 07 04 00 00       	push   $0x407
  801c85:	ff 75 f4             	push   -0xc(%ebp)
  801c88:	6a 00                	push   $0x0
  801c8a:	e8 61 ef ff ff       	call   800bf0 <sys_page_alloc>
  801c8f:	89 c3                	mov    %eax,%ebx
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	85 c0                	test   %eax,%eax
  801c96:	0f 88 04 01 00 00    	js     801da0 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801c9c:	83 ec 0c             	sub    $0xc,%esp
  801c9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca2:	50                   	push   %eax
  801ca3:	e8 c1 f1 ff ff       	call   800e69 <fd_alloc>
  801ca8:	89 c3                	mov    %eax,%ebx
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	85 c0                	test   %eax,%eax
  801caf:	0f 88 db 00 00 00    	js     801d90 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb5:	83 ec 04             	sub    $0x4,%esp
  801cb8:	68 07 04 00 00       	push   $0x407
  801cbd:	ff 75 f0             	push   -0x10(%ebp)
  801cc0:	6a 00                	push   $0x0
  801cc2:	e8 29 ef ff ff       	call   800bf0 <sys_page_alloc>
  801cc7:	89 c3                	mov    %eax,%ebx
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	0f 88 bc 00 00 00    	js     801d90 <pipe+0x131>
	va = fd2data(fd0);
  801cd4:	83 ec 0c             	sub    $0xc,%esp
  801cd7:	ff 75 f4             	push   -0xc(%ebp)
  801cda:	e8 73 f1 ff ff       	call   800e52 <fd2data>
  801cdf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce1:	83 c4 0c             	add    $0xc,%esp
  801ce4:	68 07 04 00 00       	push   $0x407
  801ce9:	50                   	push   %eax
  801cea:	6a 00                	push   $0x0
  801cec:	e8 ff ee ff ff       	call   800bf0 <sys_page_alloc>
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	0f 88 82 00 00 00    	js     801d80 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	ff 75 f0             	push   -0x10(%ebp)
  801d04:	e8 49 f1 ff ff       	call   800e52 <fd2data>
  801d09:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d10:	50                   	push   %eax
  801d11:	6a 00                	push   $0x0
  801d13:	56                   	push   %esi
  801d14:	6a 00                	push   $0x0
  801d16:	e8 18 ef ff ff       	call   800c33 <sys_page_map>
  801d1b:	89 c3                	mov    %eax,%ebx
  801d1d:	83 c4 20             	add    $0x20,%esp
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 4e                	js     801d72 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801d24:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d2c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d31:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d3b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d40:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d47:	83 ec 0c             	sub    $0xc,%esp
  801d4a:	ff 75 f4             	push   -0xc(%ebp)
  801d4d:	e8 f0 f0 ff ff       	call   800e42 <fd2num>
  801d52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d55:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d57:	83 c4 04             	add    $0x4,%esp
  801d5a:	ff 75 f0             	push   -0x10(%ebp)
  801d5d:	e8 e0 f0 ff ff       	call   800e42 <fd2num>
  801d62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d65:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d70:	eb 2e                	jmp    801da0 <pipe+0x141>
	sys_page_unmap(0, va);
  801d72:	83 ec 08             	sub    $0x8,%esp
  801d75:	56                   	push   %esi
  801d76:	6a 00                	push   $0x0
  801d78:	e8 f8 ee ff ff       	call   800c75 <sys_page_unmap>
  801d7d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d80:	83 ec 08             	sub    $0x8,%esp
  801d83:	ff 75 f0             	push   -0x10(%ebp)
  801d86:	6a 00                	push   $0x0
  801d88:	e8 e8 ee ff ff       	call   800c75 <sys_page_unmap>
  801d8d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d90:	83 ec 08             	sub    $0x8,%esp
  801d93:	ff 75 f4             	push   -0xc(%ebp)
  801d96:	6a 00                	push   $0x0
  801d98:	e8 d8 ee ff ff       	call   800c75 <sys_page_unmap>
  801d9d:	83 c4 10             	add    $0x10,%esp
}
  801da0:	89 d8                	mov    %ebx,%eax
  801da2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da5:	5b                   	pop    %ebx
  801da6:	5e                   	pop    %esi
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    

00801da9 <pipeisclosed>:
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801daf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db2:	50                   	push   %eax
  801db3:	ff 75 08             	push   0x8(%ebp)
  801db6:	e8 fe f0 ff ff       	call   800eb9 <fd_lookup>
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	78 18                	js     801dda <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801dc2:	83 ec 0c             	sub    $0xc,%esp
  801dc5:	ff 75 f4             	push   -0xc(%ebp)
  801dc8:	e8 85 f0 ff ff       	call   800e52 <fd2data>
  801dcd:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd2:	e8 33 fd ff ff       	call   801b0a <_pipeisclosed>
  801dd7:	83 c4 10             	add    $0x10,%esp
}
  801dda:	c9                   	leave  
  801ddb:	c3                   	ret    

00801ddc <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801ddc:	b8 00 00 00 00       	mov    $0x0,%eax
  801de1:	c3                   	ret    

00801de2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801de8:	68 07 28 80 00       	push   $0x802807
  801ded:	ff 75 0c             	push   0xc(%ebp)
  801df0:	e8 ff e9 ff ff       	call   8007f4 <strcpy>
	return 0;
}
  801df5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <devcons_write>:
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	57                   	push   %edi
  801e00:	56                   	push   %esi
  801e01:	53                   	push   %ebx
  801e02:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e08:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e0d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e13:	eb 2e                	jmp    801e43 <devcons_write+0x47>
		m = n - tot;
  801e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e18:	29 f3                	sub    %esi,%ebx
  801e1a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e1f:	39 c3                	cmp    %eax,%ebx
  801e21:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e24:	83 ec 04             	sub    $0x4,%esp
  801e27:	53                   	push   %ebx
  801e28:	89 f0                	mov    %esi,%eax
  801e2a:	03 45 0c             	add    0xc(%ebp),%eax
  801e2d:	50                   	push   %eax
  801e2e:	57                   	push   %edi
  801e2f:	e8 56 eb ff ff       	call   80098a <memmove>
		sys_cputs(buf, m);
  801e34:	83 c4 08             	add    $0x8,%esp
  801e37:	53                   	push   %ebx
  801e38:	57                   	push   %edi
  801e39:	e8 f6 ec ff ff       	call   800b34 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e3e:	01 de                	add    %ebx,%esi
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e46:	72 cd                	jb     801e15 <devcons_write+0x19>
}
  801e48:	89 f0                	mov    %esi,%eax
  801e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5f                   	pop    %edi
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    

00801e52 <devcons_read>:
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 08             	sub    $0x8,%esp
  801e58:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e61:	75 07                	jne    801e6a <devcons_read+0x18>
  801e63:	eb 1f                	jmp    801e84 <devcons_read+0x32>
		sys_yield();
  801e65:	e8 67 ed ff ff       	call   800bd1 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e6a:	e8 e3 ec ff ff       	call   800b52 <sys_cgetc>
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	74 f2                	je     801e65 <devcons_read+0x13>
	if (c < 0)
  801e73:	78 0f                	js     801e84 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801e75:	83 f8 04             	cmp    $0x4,%eax
  801e78:	74 0c                	je     801e86 <devcons_read+0x34>
	*(char*)vbuf = c;
  801e7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e7d:	88 02                	mov    %al,(%edx)
	return 1;
  801e7f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    
		return 0;
  801e86:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8b:	eb f7                	jmp    801e84 <devcons_read+0x32>

00801e8d <cputchar>:
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e93:	8b 45 08             	mov    0x8(%ebp),%eax
  801e96:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e99:	6a 01                	push   $0x1
  801e9b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e9e:	50                   	push   %eax
  801e9f:	e8 90 ec ff ff       	call   800b34 <sys_cputs>
}
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    

00801ea9 <getchar>:
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801eaf:	6a 01                	push   $0x1
  801eb1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb4:	50                   	push   %eax
  801eb5:	6a 00                	push   $0x0
  801eb7:	e8 66 f2 ff ff       	call   801122 <read>
	if (r < 0)
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 06                	js     801ec9 <getchar+0x20>
	if (r < 1)
  801ec3:	74 06                	je     801ecb <getchar+0x22>
	return c;
  801ec5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    
		return -E_EOF;
  801ecb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ed0:	eb f7                	jmp    801ec9 <getchar+0x20>

00801ed2 <iscons>:
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edb:	50                   	push   %eax
  801edc:	ff 75 08             	push   0x8(%ebp)
  801edf:	e8 d5 ef ff ff       	call   800eb9 <fd_lookup>
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	78 11                	js     801efc <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eee:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ef4:	39 10                	cmp    %edx,(%eax)
  801ef6:	0f 94 c0             	sete   %al
  801ef9:	0f b6 c0             	movzbl %al,%eax
}
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <opencons>:
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f07:	50                   	push   %eax
  801f08:	e8 5c ef ff ff       	call   800e69 <fd_alloc>
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 3a                	js     801f4e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f14:	83 ec 04             	sub    $0x4,%esp
  801f17:	68 07 04 00 00       	push   $0x407
  801f1c:	ff 75 f4             	push   -0xc(%ebp)
  801f1f:	6a 00                	push   $0x0
  801f21:	e8 ca ec ff ff       	call   800bf0 <sys_page_alloc>
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 21                	js     801f4e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f30:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f36:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f42:	83 ec 0c             	sub    $0xc,%esp
  801f45:	50                   	push   %eax
  801f46:	e8 f7 ee ff ff       	call   800e42 <fd2num>
  801f4b:	83 c4 10             	add    $0x10,%esp
}
  801f4e:	c9                   	leave  
  801f4f:	c3                   	ret    

00801f50 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	56                   	push   %esi
  801f54:	53                   	push   %ebx
  801f55:	8b 75 08             	mov    0x8(%ebp),%esi
  801f58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f65:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f68:	83 ec 0c             	sub    $0xc,%esp
  801f6b:	50                   	push   %eax
  801f6c:	e8 2f ee ff ff       	call   800da0 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	85 f6                	test   %esi,%esi
  801f76:	74 17                	je     801f8f <ipc_recv+0x3f>
  801f78:	ba 00 00 00 00       	mov    $0x0,%edx
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	78 0c                	js     801f8d <ipc_recv+0x3d>
  801f81:	8b 15 00 40 c0 00    	mov    0xc04000,%edx
  801f87:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f8d:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f8f:	85 db                	test   %ebx,%ebx
  801f91:	74 17                	je     801faa <ipc_recv+0x5a>
  801f93:	ba 00 00 00 00       	mov    $0x0,%edx
  801f98:	85 c0                	test   %eax,%eax
  801f9a:	78 0c                	js     801fa8 <ipc_recv+0x58>
  801f9c:	8b 15 00 40 c0 00    	mov    0xc04000,%edx
  801fa2:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801fa8:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801faa:	85 c0                	test   %eax,%eax
  801fac:	78 0b                	js     801fb9 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801fae:	a1 00 40 c0 00       	mov    0xc04000,%eax
  801fb3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801fb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbc:	5b                   	pop    %ebx
  801fbd:	5e                   	pop    %esi
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    

00801fc0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	57                   	push   %edi
  801fc4:	56                   	push   %esi
  801fc5:	53                   	push   %ebx
  801fc6:	83 ec 0c             	sub    $0xc,%esp
  801fc9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fcc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801fd2:	85 db                	test   %ebx,%ebx
  801fd4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fd9:	0f 44 d8             	cmove  %eax,%ebx
  801fdc:	eb 05                	jmp    801fe3 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fde:	e8 ee eb ff ff       	call   800bd1 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801fe3:	ff 75 14             	push   0x14(%ebp)
  801fe6:	53                   	push   %ebx
  801fe7:	56                   	push   %esi
  801fe8:	57                   	push   %edi
  801fe9:	e8 8f ed ff ff       	call   800d7d <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff4:	74 e8                	je     801fde <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	78 08                	js     802002 <ipc_send+0x42>
	}while (r<0);

}
  801ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802002:	50                   	push   %eax
  802003:	68 13 28 80 00       	push   $0x802813
  802008:	6a 3d                	push   $0x3d
  80200a:	68 27 28 80 00       	push   $0x802827
  80200f:	e8 2b e1 ff ff       	call   80013f <_panic>

00802014 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80201a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80201f:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802025:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80202b:	8b 52 60             	mov    0x60(%edx),%edx
  80202e:	39 ca                	cmp    %ecx,%edx
  802030:	74 11                	je     802043 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802032:	83 c0 01             	add    $0x1,%eax
  802035:	3d 00 04 00 00       	cmp    $0x400,%eax
  80203a:	75 e3                	jne    80201f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80203c:	b8 00 00 00 00       	mov    $0x0,%eax
  802041:	eb 0e                	jmp    802051 <ipc_find_env+0x3d>
			return envs[i].env_id;
  802043:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802049:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80204e:	8b 40 58             	mov    0x58(%eax),%eax
}
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    

00802053 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802059:	89 c2                	mov    %eax,%edx
  80205b:	c1 ea 16             	shr    $0x16,%edx
  80205e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802065:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80206a:	f6 c1 01             	test   $0x1,%cl
  80206d:	74 1c                	je     80208b <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80206f:	c1 e8 0c             	shr    $0xc,%eax
  802072:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802079:	a8 01                	test   $0x1,%al
  80207b:	74 0e                	je     80208b <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80207d:	c1 e8 0c             	shr    $0xc,%eax
  802080:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802087:	ef 
  802088:	0f b7 d2             	movzwl %dx,%edx
}
  80208b:	89 d0                	mov    %edx,%eax
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    
  80208f:	90                   	nop

00802090 <__udivdi3>:
  802090:	f3 0f 1e fb          	endbr32 
  802094:	55                   	push   %ebp
  802095:	57                   	push   %edi
  802096:	56                   	push   %esi
  802097:	53                   	push   %ebx
  802098:	83 ec 1c             	sub    $0x1c,%esp
  80209b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80209f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	75 19                	jne    8020c8 <__udivdi3+0x38>
  8020af:	39 f3                	cmp    %esi,%ebx
  8020b1:	76 4d                	jbe    802100 <__udivdi3+0x70>
  8020b3:	31 ff                	xor    %edi,%edi
  8020b5:	89 e8                	mov    %ebp,%eax
  8020b7:	89 f2                	mov    %esi,%edx
  8020b9:	f7 f3                	div    %ebx
  8020bb:	89 fa                	mov    %edi,%edx
  8020bd:	83 c4 1c             	add    $0x1c,%esp
  8020c0:	5b                   	pop    %ebx
  8020c1:	5e                   	pop    %esi
  8020c2:	5f                   	pop    %edi
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    
  8020c5:	8d 76 00             	lea    0x0(%esi),%esi
  8020c8:	39 f0                	cmp    %esi,%eax
  8020ca:	76 14                	jbe    8020e0 <__udivdi3+0x50>
  8020cc:	31 ff                	xor    %edi,%edi
  8020ce:	31 c0                	xor    %eax,%eax
  8020d0:	89 fa                	mov    %edi,%edx
  8020d2:	83 c4 1c             	add    $0x1c,%esp
  8020d5:	5b                   	pop    %ebx
  8020d6:	5e                   	pop    %esi
  8020d7:	5f                   	pop    %edi
  8020d8:	5d                   	pop    %ebp
  8020d9:	c3                   	ret    
  8020da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e0:	0f bd f8             	bsr    %eax,%edi
  8020e3:	83 f7 1f             	xor    $0x1f,%edi
  8020e6:	75 48                	jne    802130 <__udivdi3+0xa0>
  8020e8:	39 f0                	cmp    %esi,%eax
  8020ea:	72 06                	jb     8020f2 <__udivdi3+0x62>
  8020ec:	31 c0                	xor    %eax,%eax
  8020ee:	39 eb                	cmp    %ebp,%ebx
  8020f0:	77 de                	ja     8020d0 <__udivdi3+0x40>
  8020f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f7:	eb d7                	jmp    8020d0 <__udivdi3+0x40>
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 d9                	mov    %ebx,%ecx
  802102:	85 db                	test   %ebx,%ebx
  802104:	75 0b                	jne    802111 <__udivdi3+0x81>
  802106:	b8 01 00 00 00       	mov    $0x1,%eax
  80210b:	31 d2                	xor    %edx,%edx
  80210d:	f7 f3                	div    %ebx
  80210f:	89 c1                	mov    %eax,%ecx
  802111:	31 d2                	xor    %edx,%edx
  802113:	89 f0                	mov    %esi,%eax
  802115:	f7 f1                	div    %ecx
  802117:	89 c6                	mov    %eax,%esi
  802119:	89 e8                	mov    %ebp,%eax
  80211b:	89 f7                	mov    %esi,%edi
  80211d:	f7 f1                	div    %ecx
  80211f:	89 fa                	mov    %edi,%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	89 f9                	mov    %edi,%ecx
  802132:	ba 20 00 00 00       	mov    $0x20,%edx
  802137:	29 fa                	sub    %edi,%edx
  802139:	d3 e0                	shl    %cl,%eax
  80213b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80213f:	89 d1                	mov    %edx,%ecx
  802141:	89 d8                	mov    %ebx,%eax
  802143:	d3 e8                	shr    %cl,%eax
  802145:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802149:	09 c1                	or     %eax,%ecx
  80214b:	89 f0                	mov    %esi,%eax
  80214d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e3                	shl    %cl,%ebx
  802155:	89 d1                	mov    %edx,%ecx
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 f9                	mov    %edi,%ecx
  80215b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80215f:	89 eb                	mov    %ebp,%ebx
  802161:	d3 e6                	shl    %cl,%esi
  802163:	89 d1                	mov    %edx,%ecx
  802165:	d3 eb                	shr    %cl,%ebx
  802167:	09 f3                	or     %esi,%ebx
  802169:	89 c6                	mov    %eax,%esi
  80216b:	89 f2                	mov    %esi,%edx
  80216d:	89 d8                	mov    %ebx,%eax
  80216f:	f7 74 24 08          	divl   0x8(%esp)
  802173:	89 d6                	mov    %edx,%esi
  802175:	89 c3                	mov    %eax,%ebx
  802177:	f7 64 24 0c          	mull   0xc(%esp)
  80217b:	39 d6                	cmp    %edx,%esi
  80217d:	72 19                	jb     802198 <__udivdi3+0x108>
  80217f:	89 f9                	mov    %edi,%ecx
  802181:	d3 e5                	shl    %cl,%ebp
  802183:	39 c5                	cmp    %eax,%ebp
  802185:	73 04                	jae    80218b <__udivdi3+0xfb>
  802187:	39 d6                	cmp    %edx,%esi
  802189:	74 0d                	je     802198 <__udivdi3+0x108>
  80218b:	89 d8                	mov    %ebx,%eax
  80218d:	31 ff                	xor    %edi,%edi
  80218f:	e9 3c ff ff ff       	jmp    8020d0 <__udivdi3+0x40>
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80219b:	31 ff                	xor    %edi,%edi
  80219d:	e9 2e ff ff ff       	jmp    8020d0 <__udivdi3+0x40>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	f3 0f 1e fb          	endbr32 
  8021b4:	55                   	push   %ebp
  8021b5:	57                   	push   %edi
  8021b6:	56                   	push   %esi
  8021b7:	53                   	push   %ebx
  8021b8:	83 ec 1c             	sub    $0x1c,%esp
  8021bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8021c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8021cb:	89 f0                	mov    %esi,%eax
  8021cd:	89 da                	mov    %ebx,%edx
  8021cf:	85 ff                	test   %edi,%edi
  8021d1:	75 15                	jne    8021e8 <__umoddi3+0x38>
  8021d3:	39 dd                	cmp    %ebx,%ebp
  8021d5:	76 39                	jbe    802210 <__umoddi3+0x60>
  8021d7:	f7 f5                	div    %ebp
  8021d9:	89 d0                	mov    %edx,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	83 c4 1c             	add    $0x1c,%esp
  8021e0:	5b                   	pop    %ebx
  8021e1:	5e                   	pop    %esi
  8021e2:	5f                   	pop    %edi
  8021e3:	5d                   	pop    %ebp
  8021e4:	c3                   	ret    
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
  8021e8:	39 df                	cmp    %ebx,%edi
  8021ea:	77 f1                	ja     8021dd <__umoddi3+0x2d>
  8021ec:	0f bd cf             	bsr    %edi,%ecx
  8021ef:	83 f1 1f             	xor    $0x1f,%ecx
  8021f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021f6:	75 40                	jne    802238 <__umoddi3+0x88>
  8021f8:	39 df                	cmp    %ebx,%edi
  8021fa:	72 04                	jb     802200 <__umoddi3+0x50>
  8021fc:	39 f5                	cmp    %esi,%ebp
  8021fe:	77 dd                	ja     8021dd <__umoddi3+0x2d>
  802200:	89 da                	mov    %ebx,%edx
  802202:	89 f0                	mov    %esi,%eax
  802204:	29 e8                	sub    %ebp,%eax
  802206:	19 fa                	sbb    %edi,%edx
  802208:	eb d3                	jmp    8021dd <__umoddi3+0x2d>
  80220a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802210:	89 e9                	mov    %ebp,%ecx
  802212:	85 ed                	test   %ebp,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x71>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f5                	div    %ebp
  80221f:	89 c1                	mov    %eax,%ecx
  802221:	89 d8                	mov    %ebx,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f1                	div    %ecx
  802227:	89 f0                	mov    %esi,%eax
  802229:	f7 f1                	div    %ecx
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	31 d2                	xor    %edx,%edx
  80222f:	eb ac                	jmp    8021dd <__umoddi3+0x2d>
  802231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802238:	8b 44 24 04          	mov    0x4(%esp),%eax
  80223c:	ba 20 00 00 00       	mov    $0x20,%edx
  802241:	29 c2                	sub    %eax,%edx
  802243:	89 c1                	mov    %eax,%ecx
  802245:	89 e8                	mov    %ebp,%eax
  802247:	d3 e7                	shl    %cl,%edi
  802249:	89 d1                	mov    %edx,%ecx
  80224b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80224f:	d3 e8                	shr    %cl,%eax
  802251:	89 c1                	mov    %eax,%ecx
  802253:	8b 44 24 04          	mov    0x4(%esp),%eax
  802257:	09 f9                	or     %edi,%ecx
  802259:	89 df                	mov    %ebx,%edi
  80225b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225f:	89 c1                	mov    %eax,%ecx
  802261:	d3 e5                	shl    %cl,%ebp
  802263:	89 d1                	mov    %edx,%ecx
  802265:	d3 ef                	shr    %cl,%edi
  802267:	89 c1                	mov    %eax,%ecx
  802269:	89 f0                	mov    %esi,%eax
  80226b:	d3 e3                	shl    %cl,%ebx
  80226d:	89 d1                	mov    %edx,%ecx
  80226f:	89 fa                	mov    %edi,%edx
  802271:	d3 e8                	shr    %cl,%eax
  802273:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802278:	09 d8                	or     %ebx,%eax
  80227a:	f7 74 24 08          	divl   0x8(%esp)
  80227e:	89 d3                	mov    %edx,%ebx
  802280:	d3 e6                	shl    %cl,%esi
  802282:	f7 e5                	mul    %ebp
  802284:	89 c7                	mov    %eax,%edi
  802286:	89 d1                	mov    %edx,%ecx
  802288:	39 d3                	cmp    %edx,%ebx
  80228a:	72 06                	jb     802292 <__umoddi3+0xe2>
  80228c:	75 0e                	jne    80229c <__umoddi3+0xec>
  80228e:	39 c6                	cmp    %eax,%esi
  802290:	73 0a                	jae    80229c <__umoddi3+0xec>
  802292:	29 e8                	sub    %ebp,%eax
  802294:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802298:	89 d1                	mov    %edx,%ecx
  80229a:	89 c7                	mov    %eax,%edi
  80229c:	89 f5                	mov    %esi,%ebp
  80229e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022a2:	29 fd                	sub    %edi,%ebp
  8022a4:	19 cb                	sbb    %ecx,%ebx
  8022a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022ab:	89 d8                	mov    %ebx,%eax
  8022ad:	d3 e0                	shl    %cl,%eax
  8022af:	89 f1                	mov    %esi,%ecx
  8022b1:	d3 ed                	shr    %cl,%ebp
  8022b3:	d3 eb                	shr    %cl,%ebx
  8022b5:	09 e8                	or     %ebp,%eax
  8022b7:	89 da                	mov    %ebx,%edx
  8022b9:	83 c4 1c             	add    $0x1c,%esp
  8022bc:	5b                   	pop    %ebx
  8022bd:	5e                   	pop    %esi
  8022be:	5f                   	pop    %edi
  8022bf:	5d                   	pop    %ebp
  8022c0:	c3                   	ret    
