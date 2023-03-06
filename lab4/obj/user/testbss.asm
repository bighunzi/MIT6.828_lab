
obj/user/testbss：     文件格式 elf32-i386


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
  800039:	68 e0 0f 80 00       	push   $0x800fe0
  80003e:	e8 cc 01 00 00       	call   80020f <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
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
  800064:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006b:	83 c0 01             	add    $0x1,%eax
  80006e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800073:	75 ef                	jne    800064 <umain+0x31>
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007a:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800081:	75 47                	jne    8000ca <umain+0x97>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 ed                	jne    80007a <umain+0x47>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	68 28 10 80 00       	push   $0x801028
  800095:	e8 75 01 00 00       	call   80020f <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009a:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000a1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	68 87 10 80 00       	push   $0x801087
  8000ac:	6a 1a                	push   $0x1a
  8000ae:	68 78 10 80 00       	push   $0x801078
  8000b3:	e8 7c 00 00 00       	call   800134 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b8:	50                   	push   %eax
  8000b9:	68 5b 10 80 00       	push   $0x80105b
  8000be:	6a 11                	push   $0x11
  8000c0:	68 78 10 80 00       	push   $0x801078
  8000c5:	e8 6a 00 00 00       	call   800134 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ca:	50                   	push   %eax
  8000cb:	68 00 10 80 00       	push   $0x801000
  8000d0:	6a 16                	push   $0x16
  8000d2:	68 78 10 80 00       	push   $0x801078
  8000d7:	e8 58 00 00 00       	call   800134 <_panic>

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
  8000e7:	e8 bb 0a 00 00       	call   800ba7 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800125:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800128:	6a 00                	push   $0x0
  80012a:	e8 37 0a 00 00       	call   800b66 <sys_env_destroy>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800139:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800142:	e8 60 0a 00 00       	call   800ba7 <sys_getenvid>
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	ff 75 0c             	push   0xc(%ebp)
  80014d:	ff 75 08             	push   0x8(%ebp)
  800150:	56                   	push   %esi
  800151:	50                   	push   %eax
  800152:	68 a8 10 80 00       	push   $0x8010a8
  800157:	e8 b3 00 00 00       	call   80020f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015c:	83 c4 18             	add    $0x18,%esp
  80015f:	53                   	push   %ebx
  800160:	ff 75 10             	push   0x10(%ebp)
  800163:	e8 56 00 00 00       	call   8001be <vcprintf>
	cprintf("\n");
  800168:	c7 04 24 76 10 80 00 	movl   $0x801076,(%esp)
  80016f:	e8 9b 00 00 00       	call   80020f <cprintf>
  800174:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800177:	cc                   	int3   
  800178:	eb fd                	jmp    800177 <_panic+0x43>

0080017a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	53                   	push   %ebx
  80017e:	83 ec 04             	sub    $0x4,%esp
  800181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800184:	8b 13                	mov    (%ebx),%edx
  800186:	8d 42 01             	lea    0x1(%edx),%eax
  800189:	89 03                	mov    %eax,(%ebx)
  80018b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800192:	3d ff 00 00 00       	cmp    $0xff,%eax
  800197:	74 09                	je     8001a2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800199:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a2:	83 ec 08             	sub    $0x8,%esp
  8001a5:	68 ff 00 00 00       	push   $0xff
  8001aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ad:	50                   	push   %eax
  8001ae:	e8 76 09 00 00       	call   800b29 <sys_cputs>
		b->idx = 0;
  8001b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b9:	83 c4 10             	add    $0x10,%esp
  8001bc:	eb db                	jmp    800199 <putch+0x1f>

008001be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ce:	00 00 00 
	b.cnt = 0;
  8001d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001db:	ff 75 0c             	push   0xc(%ebp)
  8001de:	ff 75 08             	push   0x8(%ebp)
  8001e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e7:	50                   	push   %eax
  8001e8:	68 7a 01 80 00       	push   $0x80017a
  8001ed:	e8 14 01 00 00       	call   800306 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f2:	83 c4 08             	add    $0x8,%esp
  8001f5:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	e8 22 09 00 00       	call   800b29 <sys_cputs>

	return b.cnt;
}
  800207:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800215:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800218:	50                   	push   %eax
  800219:	ff 75 08             	push   0x8(%ebp)
  80021c:	e8 9d ff ff ff       	call   8001be <vcprintf>
	va_end(ap);

	return cnt;
}
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 1c             	sub    $0x1c,%esp
  80022c:	89 c7                	mov    %eax,%edi
  80022e:	89 d6                	mov    %edx,%esi
  800230:	8b 45 08             	mov    0x8(%ebp),%eax
  800233:	8b 55 0c             	mov    0xc(%ebp),%edx
  800236:	89 d1                	mov    %edx,%ecx
  800238:	89 c2                	mov    %eax,%edx
  80023a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800240:	8b 45 10             	mov    0x10(%ebp),%eax
  800243:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800246:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800249:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800250:	39 c2                	cmp    %eax,%edx
  800252:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800255:	72 3e                	jb     800295 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 18             	push   0x18(%ebp)
  80025d:	83 eb 01             	sub    $0x1,%ebx
  800260:	53                   	push   %ebx
  800261:	50                   	push   %eax
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	ff 75 e4             	push   -0x1c(%ebp)
  800268:	ff 75 e0             	push   -0x20(%ebp)
  80026b:	ff 75 dc             	push   -0x24(%ebp)
  80026e:	ff 75 d8             	push   -0x28(%ebp)
  800271:	e8 2a 0b 00 00       	call   800da0 <__udivdi3>
  800276:	83 c4 18             	add    $0x18,%esp
  800279:	52                   	push   %edx
  80027a:	50                   	push   %eax
  80027b:	89 f2                	mov    %esi,%edx
  80027d:	89 f8                	mov    %edi,%eax
  80027f:	e8 9f ff ff ff       	call   800223 <printnum>
  800284:	83 c4 20             	add    $0x20,%esp
  800287:	eb 13                	jmp    80029c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	ff 75 18             	push   0x18(%ebp)
  800290:	ff d7                	call   *%edi
  800292:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800295:	83 eb 01             	sub    $0x1,%ebx
  800298:	85 db                	test   %ebx,%ebx
  80029a:	7f ed                	jg     800289 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	56                   	push   %esi
  8002a0:	83 ec 04             	sub    $0x4,%esp
  8002a3:	ff 75 e4             	push   -0x1c(%ebp)
  8002a6:	ff 75 e0             	push   -0x20(%ebp)
  8002a9:	ff 75 dc             	push   -0x24(%ebp)
  8002ac:	ff 75 d8             	push   -0x28(%ebp)
  8002af:	e8 0c 0c 00 00       	call   800ec0 <__umoddi3>
  8002b4:	83 c4 14             	add    $0x14,%esp
  8002b7:	0f be 80 cb 10 80 00 	movsbl 0x8010cb(%eax),%eax
  8002be:	50                   	push   %eax
  8002bf:	ff d7                	call   *%edi
}
  8002c1:	83 c4 10             	add    $0x10,%esp
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002db:	73 0a                	jae    8002e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	88 02                	mov    %al,(%edx)
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <printfmt>:
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f2:	50                   	push   %eax
  8002f3:	ff 75 10             	push   0x10(%ebp)
  8002f6:	ff 75 0c             	push   0xc(%ebp)
  8002f9:	ff 75 08             	push   0x8(%ebp)
  8002fc:	e8 05 00 00 00       	call   800306 <vprintfmt>
}
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <vprintfmt>:
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 3c             	sub    $0x3c,%esp
  80030f:	8b 75 08             	mov    0x8(%ebp),%esi
  800312:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800315:	8b 7d 10             	mov    0x10(%ebp),%edi
  800318:	eb 0a                	jmp    800324 <vprintfmt+0x1e>
			putch(ch, putdat);
  80031a:	83 ec 08             	sub    $0x8,%esp
  80031d:	53                   	push   %ebx
  80031e:	50                   	push   %eax
  80031f:	ff d6                	call   *%esi
  800321:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800324:	83 c7 01             	add    $0x1,%edi
  800327:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032b:	83 f8 25             	cmp    $0x25,%eax
  80032e:	74 0c                	je     80033c <vprintfmt+0x36>
			if (ch == '\0')
  800330:	85 c0                	test   %eax,%eax
  800332:	75 e6                	jne    80031a <vprintfmt+0x14>
}
  800334:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800337:	5b                   	pop    %ebx
  800338:	5e                   	pop    %esi
  800339:	5f                   	pop    %edi
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    
		padc = ' ';
  80033c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800340:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800347:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80034e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800355:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8d 47 01             	lea    0x1(%edi),%eax
  80035d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800360:	0f b6 17             	movzbl (%edi),%edx
  800363:	8d 42 dd             	lea    -0x23(%edx),%eax
  800366:	3c 55                	cmp    $0x55,%al
  800368:	0f 87 bb 03 00 00    	ja     800729 <vprintfmt+0x423>
  80036e:	0f b6 c0             	movzbl %al,%eax
  800371:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80037b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80037f:	eb d9                	jmp    80035a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800384:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800388:	eb d0                	jmp    80035a <vprintfmt+0x54>
  80038a:	0f b6 d2             	movzbl %dl,%edx
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800390:	b8 00 00 00 00       	mov    $0x0,%eax
  800395:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800398:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a5:	83 f9 09             	cmp    $0x9,%ecx
  8003a8:	77 55                	ja     8003ff <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003aa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ad:	eb e9                	jmp    800398 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8b 00                	mov    (%eax),%eax
  8003b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8d 40 04             	lea    0x4(%eax),%eax
  8003bd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c7:	79 91                	jns    80035a <vprintfmt+0x54>
				width = precision, precision = -1;
  8003c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cf:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d6:	eb 82                	jmp    80035a <vprintfmt+0x54>
  8003d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003db:	85 d2                	test   %edx,%edx
  8003dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e2:	0f 49 c2             	cmovns %edx,%eax
  8003e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003eb:	e9 6a ff ff ff       	jmp    80035a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003fa:	e9 5b ff ff ff       	jmp    80035a <vprintfmt+0x54>
  8003ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800402:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800405:	eb bc                	jmp    8003c3 <vprintfmt+0xbd>
			lflag++;
  800407:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040d:	e9 48 ff ff ff       	jmp    80035a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 78 04             	lea    0x4(%eax),%edi
  800418:	83 ec 08             	sub    $0x8,%esp
  80041b:	53                   	push   %ebx
  80041c:	ff 30                	push   (%eax)
  80041e:	ff d6                	call   *%esi
			break;
  800420:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800423:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800426:	e9 9d 02 00 00       	jmp    8006c8 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 78 04             	lea    0x4(%eax),%edi
  800431:	8b 10                	mov    (%eax),%edx
  800433:	89 d0                	mov    %edx,%eax
  800435:	f7 d8                	neg    %eax
  800437:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043a:	83 f8 08             	cmp    $0x8,%eax
  80043d:	7f 23                	jg     800462 <vprintfmt+0x15c>
  80043f:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800446:	85 d2                	test   %edx,%edx
  800448:	74 18                	je     800462 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80044a:	52                   	push   %edx
  80044b:	68 ec 10 80 00       	push   $0x8010ec
  800450:	53                   	push   %ebx
  800451:	56                   	push   %esi
  800452:	e8 92 fe ff ff       	call   8002e9 <printfmt>
  800457:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80045d:	e9 66 02 00 00       	jmp    8006c8 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800462:	50                   	push   %eax
  800463:	68 e3 10 80 00       	push   $0x8010e3
  800468:	53                   	push   %ebx
  800469:	56                   	push   %esi
  80046a:	e8 7a fe ff ff       	call   8002e9 <printfmt>
  80046f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800472:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800475:	e9 4e 02 00 00       	jmp    8006c8 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	83 c0 04             	add    $0x4,%eax
  800480:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800488:	85 d2                	test   %edx,%edx
  80048a:	b8 dc 10 80 00       	mov    $0x8010dc,%eax
  80048f:	0f 45 c2             	cmovne %edx,%eax
  800492:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800495:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800499:	7e 06                	jle    8004a1 <vprintfmt+0x19b>
  80049b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80049f:	75 0d                	jne    8004ae <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a4:	89 c7                	mov    %eax,%edi
  8004a6:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ac:	eb 55                	jmp    800503 <vprintfmt+0x1fd>
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	ff 75 d8             	push   -0x28(%ebp)
  8004b4:	ff 75 cc             	push   -0x34(%ebp)
  8004b7:	e8 0a 03 00 00       	call   8007c6 <strnlen>
  8004bc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004bf:	29 c1                	sub    %eax,%ecx
  8004c1:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004c9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d0:	eb 0f                	jmp    8004e1 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	ff 75 e0             	push   -0x20(%ebp)
  8004d9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	83 ef 01             	sub    $0x1,%edi
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	7f ed                	jg     8004d2 <vprintfmt+0x1cc>
  8004e5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ef:	0f 49 c2             	cmovns %edx,%eax
  8004f2:	29 c2                	sub    %eax,%edx
  8004f4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f7:	eb a8                	jmp    8004a1 <vprintfmt+0x19b>
					putch(ch, putdat);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	53                   	push   %ebx
  8004fd:	52                   	push   %edx
  8004fe:	ff d6                	call   *%esi
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800506:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	83 c7 01             	add    $0x1,%edi
  80050b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050f:	0f be d0             	movsbl %al,%edx
  800512:	85 d2                	test   %edx,%edx
  800514:	74 4b                	je     800561 <vprintfmt+0x25b>
  800516:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051a:	78 06                	js     800522 <vprintfmt+0x21c>
  80051c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800520:	78 1e                	js     800540 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800522:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800526:	74 d1                	je     8004f9 <vprintfmt+0x1f3>
  800528:	0f be c0             	movsbl %al,%eax
  80052b:	83 e8 20             	sub    $0x20,%eax
  80052e:	83 f8 5e             	cmp    $0x5e,%eax
  800531:	76 c6                	jbe    8004f9 <vprintfmt+0x1f3>
					putch('?', putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	53                   	push   %ebx
  800537:	6a 3f                	push   $0x3f
  800539:	ff d6                	call   *%esi
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	eb c3                	jmp    800503 <vprintfmt+0x1fd>
  800540:	89 cf                	mov    %ecx,%edi
  800542:	eb 0e                	jmp    800552 <vprintfmt+0x24c>
				putch(' ', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	53                   	push   %ebx
  800548:	6a 20                	push   $0x20
  80054a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80054c:	83 ef 01             	sub    $0x1,%edi
  80054f:	83 c4 10             	add    $0x10,%esp
  800552:	85 ff                	test   %edi,%edi
  800554:	7f ee                	jg     800544 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800556:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
  80055c:	e9 67 01 00 00       	jmp    8006c8 <vprintfmt+0x3c2>
  800561:	89 cf                	mov    %ecx,%edi
  800563:	eb ed                	jmp    800552 <vprintfmt+0x24c>
	if (lflag >= 2)
  800565:	83 f9 01             	cmp    $0x1,%ecx
  800568:	7f 1b                	jg     800585 <vprintfmt+0x27f>
	else if (lflag)
  80056a:	85 c9                	test   %ecx,%ecx
  80056c:	74 63                	je     8005d1 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8b 00                	mov    (%eax),%eax
  800573:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800576:	99                   	cltd   
  800577:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 40 04             	lea    0x4(%eax),%eax
  800580:	89 45 14             	mov    %eax,0x14(%ebp)
  800583:	eb 17                	jmp    80059c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 50 04             	mov    0x4(%eax),%edx
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 40 08             	lea    0x8(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80059c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005a2:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005a7:	85 c9                	test   %ecx,%ecx
  8005a9:	0f 89 ff 00 00 00    	jns    8006ae <vprintfmt+0x3a8>
				putch('-', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 2d                	push   $0x2d
  8005b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bd:	f7 da                	neg    %edx
  8005bf:	83 d1 00             	adc    $0x0,%ecx
  8005c2:	f7 d9                	neg    %ecx
  8005c4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c7:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005cc:	e9 dd 00 00 00       	jmp    8006ae <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	99                   	cltd   
  8005da:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e6:	eb b4                	jmp    80059c <vprintfmt+0x296>
	if (lflag >= 2)
  8005e8:	83 f9 01             	cmp    $0x1,%ecx
  8005eb:	7f 1e                	jg     80060b <vprintfmt+0x305>
	else if (lflag)
  8005ed:	85 c9                	test   %ecx,%ecx
  8005ef:	74 32                	je     800623 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fb:	8d 40 04             	lea    0x4(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800601:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800606:	e9 a3 00 00 00       	jmp    8006ae <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	8b 48 04             	mov    0x4(%eax),%ecx
  800613:	8d 40 08             	lea    0x8(%eax),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800619:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80061e:	e9 8b 00 00 00       	jmp    8006ae <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062d:	8d 40 04             	lea    0x4(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800633:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800638:	eb 74                	jmp    8006ae <vprintfmt+0x3a8>
	if (lflag >= 2)
  80063a:	83 f9 01             	cmp    $0x1,%ecx
  80063d:	7f 1b                	jg     80065a <vprintfmt+0x354>
	else if (lflag)
  80063f:	85 c9                	test   %ecx,%ecx
  800641:	74 2c                	je     80066f <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800653:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800658:	eb 54                	jmp    8006ae <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	8b 48 04             	mov    0x4(%eax),%ecx
  800662:	8d 40 08             	lea    0x8(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800668:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80066d:	eb 3f                	jmp    8006ae <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	b9 00 00 00 00       	mov    $0x0,%ecx
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80067f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800684:	eb 28                	jmp    8006ae <vprintfmt+0x3a8>
			putch('0', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 30                	push   $0x30
  80068c:	ff d6                	call   *%esi
			putch('x', putdat);
  80068e:	83 c4 08             	add    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 78                	push   $0x78
  800694:	ff d6                	call   *%esi
			num = (unsigned long long)
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8b 10                	mov    (%eax),%edx
  80069b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006a0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006a3:	8d 40 04             	lea    0x4(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a9:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006ae:	83 ec 0c             	sub    $0xc,%esp
  8006b1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006b5:	50                   	push   %eax
  8006b6:	ff 75 e0             	push   -0x20(%ebp)
  8006b9:	57                   	push   %edi
  8006ba:	51                   	push   %ecx
  8006bb:	52                   	push   %edx
  8006bc:	89 da                	mov    %ebx,%edx
  8006be:	89 f0                	mov    %esi,%eax
  8006c0:	e8 5e fb ff ff       	call   800223 <printnum>
			break;
  8006c5:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006cb:	e9 54 fc ff ff       	jmp    800324 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006d0:	83 f9 01             	cmp    $0x1,%ecx
  8006d3:	7f 1b                	jg     8006f0 <vprintfmt+0x3ea>
	else if (lflag)
  8006d5:	85 c9                	test   %ecx,%ecx
  8006d7:	74 2c                	je     800705 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e9:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006ee:	eb be                	jmp    8006ae <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 10                	mov    (%eax),%edx
  8006f5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f8:	8d 40 08             	lea    0x8(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fe:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800703:	eb a9                	jmp    8006ae <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070f:	8d 40 04             	lea    0x4(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800715:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80071a:	eb 92                	jmp    8006ae <vprintfmt+0x3a8>
			putch(ch, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 25                	push   $0x25
  800722:	ff d6                	call   *%esi
			break;
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb 9f                	jmp    8006c8 <vprintfmt+0x3c2>
			putch('%', putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	53                   	push   %ebx
  80072d:	6a 25                	push   $0x25
  80072f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	89 f8                	mov    %edi,%eax
  800736:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80073a:	74 05                	je     800741 <vprintfmt+0x43b>
  80073c:	83 e8 01             	sub    $0x1,%eax
  80073f:	eb f5                	jmp    800736 <vprintfmt+0x430>
  800741:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800744:	eb 82                	jmp    8006c8 <vprintfmt+0x3c2>

00800746 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 18             	sub    $0x18,%esp
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800752:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800755:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800759:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800763:	85 c0                	test   %eax,%eax
  800765:	74 26                	je     80078d <vsnprintf+0x47>
  800767:	85 d2                	test   %edx,%edx
  800769:	7e 22                	jle    80078d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076b:	ff 75 14             	push   0x14(%ebp)
  80076e:	ff 75 10             	push   0x10(%ebp)
  800771:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800774:	50                   	push   %eax
  800775:	68 cc 02 80 00       	push   $0x8002cc
  80077a:	e8 87 fb ff ff       	call   800306 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800782:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800788:	83 c4 10             	add    $0x10,%esp
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    
		return -E_INVAL;
  80078d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800792:	eb f7                	jmp    80078b <vsnprintf+0x45>

00800794 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079d:	50                   	push   %eax
  80079e:	ff 75 10             	push   0x10(%ebp)
  8007a1:	ff 75 0c             	push   0xc(%ebp)
  8007a4:	ff 75 08             	push   0x8(%ebp)
  8007a7:	e8 9a ff ff ff       	call   800746 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ac:	c9                   	leave  
  8007ad:	c3                   	ret    

008007ae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b9:	eb 03                	jmp    8007be <strlen+0x10>
		n++;
  8007bb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c2:	75 f7                	jne    8007bb <strlen+0xd>
	return n;
}
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d4:	eb 03                	jmp    8007d9 <strnlen+0x13>
		n++;
  8007d6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d9:	39 d0                	cmp    %edx,%eax
  8007db:	74 08                	je     8007e5 <strnlen+0x1f>
  8007dd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e1:	75 f3                	jne    8007d6 <strnlen+0x10>
  8007e3:	89 c2                	mov    %eax,%edx
	return n;
}
  8007e5:	89 d0                	mov    %edx,%eax
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007fc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007ff:	83 c0 01             	add    $0x1,%eax
  800802:	84 d2                	test   %dl,%dl
  800804:	75 f2                	jne    8007f8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800806:	89 c8                	mov    %ecx,%eax
  800808:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080b:	c9                   	leave  
  80080c:	c3                   	ret    

0080080d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	53                   	push   %ebx
  800811:	83 ec 10             	sub    $0x10,%esp
  800814:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800817:	53                   	push   %ebx
  800818:	e8 91 ff ff ff       	call   8007ae <strlen>
  80081d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800820:	ff 75 0c             	push   0xc(%ebp)
  800823:	01 d8                	add    %ebx,%eax
  800825:	50                   	push   %eax
  800826:	e8 be ff ff ff       	call   8007e9 <strcpy>
	return dst;
}
  80082b:	89 d8                	mov    %ebx,%eax
  80082d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083d:	89 f3                	mov    %esi,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	89 f0                	mov    %esi,%eax
  800844:	eb 0f                	jmp    800855 <strncpy+0x23>
		*dst++ = *src;
  800846:	83 c0 01             	add    $0x1,%eax
  800849:	0f b6 0a             	movzbl (%edx),%ecx
  80084c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084f:	80 f9 01             	cmp    $0x1,%cl
  800852:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800855:	39 d8                	cmp    %ebx,%eax
  800857:	75 ed                	jne    800846 <strncpy+0x14>
	}
	return ret;
}
  800859:	89 f0                	mov    %esi,%eax
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086a:	8b 55 10             	mov    0x10(%ebp),%edx
  80086d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086f:	85 d2                	test   %edx,%edx
  800871:	74 21                	je     800894 <strlcpy+0x35>
  800873:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800877:	89 f2                	mov    %esi,%edx
  800879:	eb 09                	jmp    800884 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087b:	83 c1 01             	add    $0x1,%ecx
  80087e:	83 c2 01             	add    $0x1,%edx
  800881:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800884:	39 c2                	cmp    %eax,%edx
  800886:	74 09                	je     800891 <strlcpy+0x32>
  800888:	0f b6 19             	movzbl (%ecx),%ebx
  80088b:	84 db                	test   %bl,%bl
  80088d:	75 ec                	jne    80087b <strlcpy+0x1c>
  80088f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800891:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800894:	29 f0                	sub    %esi,%eax
}
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a3:	eb 06                	jmp    8008ab <strcmp+0x11>
		p++, q++;
  8008a5:	83 c1 01             	add    $0x1,%ecx
  8008a8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ab:	0f b6 01             	movzbl (%ecx),%eax
  8008ae:	84 c0                	test   %al,%al
  8008b0:	74 04                	je     8008b6 <strcmp+0x1c>
  8008b2:	3a 02                	cmp    (%edx),%al
  8008b4:	74 ef                	je     8008a5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b6:	0f b6 c0             	movzbl %al,%eax
  8008b9:	0f b6 12             	movzbl (%edx),%edx
  8008bc:	29 d0                	sub    %edx,%eax
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cf:	eb 06                	jmp    8008d7 <strncmp+0x17>
		n--, p++, q++;
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d7:	39 d8                	cmp    %ebx,%eax
  8008d9:	74 18                	je     8008f3 <strncmp+0x33>
  8008db:	0f b6 08             	movzbl (%eax),%ecx
  8008de:	84 c9                	test   %cl,%cl
  8008e0:	74 04                	je     8008e6 <strncmp+0x26>
  8008e2:	3a 0a                	cmp    (%edx),%cl
  8008e4:	74 eb                	je     8008d1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 00             	movzbl (%eax),%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
}
  8008ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    
		return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f8:	eb f4                	jmp    8008ee <strncmp+0x2e>

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 03                	jmp    800909 <strchr+0xf>
  800906:	83 c0 01             	add    $0x1,%eax
  800909:	0f b6 10             	movzbl (%eax),%edx
  80090c:	84 d2                	test   %dl,%dl
  80090e:	74 06                	je     800916 <strchr+0x1c>
		if (*s == c)
  800910:	38 ca                	cmp    %cl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
  800914:	eb 05                	jmp    80091b <strchr+0x21>
			return (char *) s;
	return 0;
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800927:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092a:	38 ca                	cmp    %cl,%dl
  80092c:	74 09                	je     800937 <strfind+0x1a>
  80092e:	84 d2                	test   %dl,%dl
  800930:	74 05                	je     800937 <strfind+0x1a>
	for (; *s; s++)
  800932:	83 c0 01             	add    $0x1,%eax
  800935:	eb f0                	jmp    800927 <strfind+0xa>
			break;
	return (char *) s;
}
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800942:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800945:	85 c9                	test   %ecx,%ecx
  800947:	74 2f                	je     800978 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800949:	89 f8                	mov    %edi,%eax
  80094b:	09 c8                	or     %ecx,%eax
  80094d:	a8 03                	test   $0x3,%al
  80094f:	75 21                	jne    800972 <memset+0x39>
		c &= 0xFF;
  800951:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800955:	89 d0                	mov    %edx,%eax
  800957:	c1 e0 08             	shl    $0x8,%eax
  80095a:	89 d3                	mov    %edx,%ebx
  80095c:	c1 e3 18             	shl    $0x18,%ebx
  80095f:	89 d6                	mov    %edx,%esi
  800961:	c1 e6 10             	shl    $0x10,%esi
  800964:	09 f3                	or     %esi,%ebx
  800966:	09 da                	or     %ebx,%edx
  800968:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80096d:	fc                   	cld    
  80096e:	f3 ab                	rep stos %eax,%es:(%edi)
  800970:	eb 06                	jmp    800978 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800972:	8b 45 0c             	mov    0xc(%ebp),%eax
  800975:	fc                   	cld    
  800976:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800978:	89 f8                	mov    %edi,%eax
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098d:	39 c6                	cmp    %eax,%esi
  80098f:	73 32                	jae    8009c3 <memmove+0x44>
  800991:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800994:	39 c2                	cmp    %eax,%edx
  800996:	76 2b                	jbe    8009c3 <memmove+0x44>
		s += n;
		d += n;
  800998:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099b:	89 d6                	mov    %edx,%esi
  80099d:	09 fe                	or     %edi,%esi
  80099f:	09 ce                	or     %ecx,%esi
  8009a1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a7:	75 0e                	jne    8009b7 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a9:	83 ef 04             	sub    $0x4,%edi
  8009ac:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009af:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009b2:	fd                   	std    
  8009b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b5:	eb 09                	jmp    8009c0 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b7:	83 ef 01             	sub    $0x1,%edi
  8009ba:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009bd:	fd                   	std    
  8009be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c0:	fc                   	cld    
  8009c1:	eb 1a                	jmp    8009dd <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c3:	89 f2                	mov    %esi,%edx
  8009c5:	09 c2                	or     %eax,%edx
  8009c7:	09 ca                	or     %ecx,%edx
  8009c9:	f6 c2 03             	test   $0x3,%dl
  8009cc:	75 0a                	jne    8009d8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ce:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009d1:	89 c7                	mov    %eax,%edi
  8009d3:	fc                   	cld    
  8009d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d6:	eb 05                	jmp    8009dd <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009d8:	89 c7                	mov    %eax,%edi
  8009da:	fc                   	cld    
  8009db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009dd:	5e                   	pop    %esi
  8009de:	5f                   	pop    %edi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e7:	ff 75 10             	push   0x10(%ebp)
  8009ea:	ff 75 0c             	push   0xc(%ebp)
  8009ed:	ff 75 08             	push   0x8(%ebp)
  8009f0:	e8 8a ff ff ff       	call   80097f <memmove>
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a02:	89 c6                	mov    %eax,%esi
  800a04:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	eb 06                	jmp    800a0f <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a0f:	39 f0                	cmp    %esi,%eax
  800a11:	74 14                	je     800a27 <memcmp+0x30>
		if (*s1 != *s2)
  800a13:	0f b6 08             	movzbl (%eax),%ecx
  800a16:	0f b6 1a             	movzbl (%edx),%ebx
  800a19:	38 d9                	cmp    %bl,%cl
  800a1b:	74 ec                	je     800a09 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a1d:	0f b6 c1             	movzbl %cl,%eax
  800a20:	0f b6 db             	movzbl %bl,%ebx
  800a23:	29 d8                	sub    %ebx,%eax
  800a25:	eb 05                	jmp    800a2c <memcmp+0x35>
	}

	return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a39:	89 c2                	mov    %eax,%edx
  800a3b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3e:	eb 03                	jmp    800a43 <memfind+0x13>
  800a40:	83 c0 01             	add    $0x1,%eax
  800a43:	39 d0                	cmp    %edx,%eax
  800a45:	73 04                	jae    800a4b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a47:	38 08                	cmp    %cl,(%eax)
  800a49:	75 f5                	jne    800a40 <memfind+0x10>
			break;
	return (void *) s;
}
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	57                   	push   %edi
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 55 08             	mov    0x8(%ebp),%edx
  800a56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a59:	eb 03                	jmp    800a5e <strtol+0x11>
		s++;
  800a5b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a5e:	0f b6 02             	movzbl (%edx),%eax
  800a61:	3c 20                	cmp    $0x20,%al
  800a63:	74 f6                	je     800a5b <strtol+0xe>
  800a65:	3c 09                	cmp    $0x9,%al
  800a67:	74 f2                	je     800a5b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a69:	3c 2b                	cmp    $0x2b,%al
  800a6b:	74 2a                	je     800a97 <strtol+0x4a>
	int neg = 0;
  800a6d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a72:	3c 2d                	cmp    $0x2d,%al
  800a74:	74 2b                	je     800aa1 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a76:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7c:	75 0f                	jne    800a8d <strtol+0x40>
  800a7e:	80 3a 30             	cmpb   $0x30,(%edx)
  800a81:	74 28                	je     800aab <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a83:	85 db                	test   %ebx,%ebx
  800a85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a8a:	0f 44 d8             	cmove  %eax,%ebx
  800a8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a92:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a95:	eb 46                	jmp    800add <strtol+0x90>
		s++;
  800a97:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9f:	eb d5                	jmp    800a76 <strtol+0x29>
		s++, neg = 1;
  800aa1:	83 c2 01             	add    $0x1,%edx
  800aa4:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa9:	eb cb                	jmp    800a76 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aab:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aaf:	74 0e                	je     800abf <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ab1:	85 db                	test   %ebx,%ebx
  800ab3:	75 d8                	jne    800a8d <strtol+0x40>
		s++, base = 8;
  800ab5:	83 c2 01             	add    $0x1,%edx
  800ab8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800abd:	eb ce                	jmp    800a8d <strtol+0x40>
		s += 2, base = 16;
  800abf:	83 c2 02             	add    $0x2,%edx
  800ac2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac7:	eb c4                	jmp    800a8d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ac9:	0f be c0             	movsbl %al,%eax
  800acc:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800acf:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ad2:	7d 3a                	jge    800b0e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ad4:	83 c2 01             	add    $0x1,%edx
  800ad7:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800adb:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800add:	0f b6 02             	movzbl (%edx),%eax
  800ae0:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ae3:	89 f3                	mov    %esi,%ebx
  800ae5:	80 fb 09             	cmp    $0x9,%bl
  800ae8:	76 df                	jbe    800ac9 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800aea:	8d 70 9f             	lea    -0x61(%eax),%esi
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	80 fb 19             	cmp    $0x19,%bl
  800af2:	77 08                	ja     800afc <strtol+0xaf>
			dig = *s - 'a' + 10;
  800af4:	0f be c0             	movsbl %al,%eax
  800af7:	83 e8 57             	sub    $0x57,%eax
  800afa:	eb d3                	jmp    800acf <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800afc:	8d 70 bf             	lea    -0x41(%eax),%esi
  800aff:	89 f3                	mov    %esi,%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 08                	ja     800b0e <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b06:	0f be c0             	movsbl %al,%eax
  800b09:	83 e8 37             	sub    $0x37,%eax
  800b0c:	eb c1                	jmp    800acf <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b12:	74 05                	je     800b19 <strtol+0xcc>
		*endptr = (char *) s;
  800b14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b17:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b19:	89 c8                	mov    %ecx,%eax
  800b1b:	f7 d8                	neg    %eax
  800b1d:	85 ff                	test   %edi,%edi
  800b1f:	0f 45 c8             	cmovne %eax,%ecx
}
  800b22:	89 c8                	mov    %ecx,%eax
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3a:	89 c3                	mov    %eax,%ebx
  800b3c:	89 c7                	mov    %eax,%edi
  800b3e:	89 c6                	mov    %eax,%esi
  800b40:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 01 00 00 00       	mov    $0x1,%eax
  800b57:	89 d1                	mov    %edx,%ecx
  800b59:	89 d3                	mov    %edx,%ebx
  800b5b:	89 d7                	mov    %edx,%edi
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7c:	89 cb                	mov    %ecx,%ebx
  800b7e:	89 cf                	mov    %ecx,%edi
  800b80:	89 ce                	mov    %ecx,%esi
  800b82:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7f 08                	jg     800b90 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	50                   	push   %eax
  800b94:	6a 03                	push   $0x3
  800b96:	68 24 13 80 00       	push   $0x801324
  800b9b:	6a 2a                	push   $0x2a
  800b9d:	68 41 13 80 00       	push   $0x801341
  800ba2:	e8 8d f5 ff ff       	call   800134 <_panic>

00800ba7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb7:	89 d1                	mov    %edx,%ecx
  800bb9:	89 d3                	mov    %edx,%ebx
  800bbb:	89 d7                	mov    %edx,%edi
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_yield>:

void
sys_yield(void)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd6:	89 d1                	mov    %edx,%ecx
  800bd8:	89 d3                	mov    %edx,%ebx
  800bda:	89 d7                	mov    %edx,%edi
  800bdc:	89 d6                	mov    %edx,%esi
  800bde:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bee:	be 00 00 00 00       	mov    $0x0,%esi
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c01:	89 f7                	mov    %esi,%edi
  800c03:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c05:	85 c0                	test   %eax,%eax
  800c07:	7f 08                	jg     800c11 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	50                   	push   %eax
  800c15:	6a 04                	push   $0x4
  800c17:	68 24 13 80 00       	push   $0x801324
  800c1c:	6a 2a                	push   $0x2a
  800c1e:	68 41 13 80 00       	push   $0x801341
  800c23:	e8 0c f5 ff ff       	call   800134 <_panic>

00800c28 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c42:	8b 75 18             	mov    0x18(%ebp),%esi
  800c45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7f 08                	jg     800c53 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 05                	push   $0x5
  800c59:	68 24 13 80 00       	push   $0x801324
  800c5e:	6a 2a                	push   $0x2a
  800c60:	68 41 13 80 00       	push   $0x801341
  800c65:	e8 ca f4 ff ff       	call   800134 <_panic>

00800c6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c83:	89 df                	mov    %ebx,%edi
  800c85:	89 de                	mov    %ebx,%esi
  800c87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7f 08                	jg     800c95 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	50                   	push   %eax
  800c99:	6a 06                	push   $0x6
  800c9b:	68 24 13 80 00       	push   $0x801324
  800ca0:	6a 2a                	push   $0x2a
  800ca2:	68 41 13 80 00       	push   $0x801341
  800ca7:	e8 88 f4 ff ff       	call   800134 <_panic>

00800cac <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc5:	89 df                	mov    %ebx,%edi
  800cc7:	89 de                	mov    %ebx,%esi
  800cc9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7f 08                	jg     800cd7 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 08                	push   $0x8
  800cdd:	68 24 13 80 00       	push   $0x801324
  800ce2:	6a 2a                	push   $0x2a
  800ce4:	68 41 13 80 00       	push   $0x801341
  800ce9:	e8 46 f4 ff ff       	call   800134 <_panic>

00800cee <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	b8 09 00 00 00       	mov    $0x9,%eax
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7f 08                	jg     800d19 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	50                   	push   %eax
  800d1d:	6a 09                	push   $0x9
  800d1f:	68 24 13 80 00       	push   $0x801324
  800d24:	6a 2a                	push   $0x2a
  800d26:	68 41 13 80 00       	push   $0x801341
  800d2b:	e8 04 f4 ff ff       	call   800134 <_panic>

00800d30 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d49:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d69:	89 cb                	mov    %ecx,%ebx
  800d6b:	89 cf                	mov    %ecx,%edi
  800d6d:	89 ce                	mov    %ecx,%esi
  800d6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d71:	85 c0                	test   %eax,%eax
  800d73:	7f 08                	jg     800d7d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	50                   	push   %eax
  800d81:	6a 0c                	push   $0xc
  800d83:	68 24 13 80 00       	push   $0x801324
  800d88:	6a 2a                	push   $0x2a
  800d8a:	68 41 13 80 00       	push   $0x801341
  800d8f:	e8 a0 f3 ff ff       	call   800134 <_panic>
  800d94:	66 90                	xchg   %ax,%ax
  800d96:	66 90                	xchg   %ax,%ax
  800d98:	66 90                	xchg   %ax,%ax
  800d9a:	66 90                	xchg   %ax,%ax
  800d9c:	66 90                	xchg   %ax,%ax
  800d9e:	66 90                	xchg   %ax,%ax

00800da0 <__udivdi3>:
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 1c             	sub    $0x1c,%esp
  800dab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800daf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800db3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800db7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	75 19                	jne    800dd8 <__udivdi3+0x38>
  800dbf:	39 f3                	cmp    %esi,%ebx
  800dc1:	76 4d                	jbe    800e10 <__udivdi3+0x70>
  800dc3:	31 ff                	xor    %edi,%edi
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	89 f2                	mov    %esi,%edx
  800dc9:	f7 f3                	div    %ebx
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	83 c4 1c             	add    $0x1c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	39 f0                	cmp    %esi,%eax
  800dda:	76 14                	jbe    800df0 <__udivdi3+0x50>
  800ddc:	31 ff                	xor    %edi,%edi
  800dde:	31 c0                	xor    %eax,%eax
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	83 c4 1c             	add    $0x1c,%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
  800dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df0:	0f bd f8             	bsr    %eax,%edi
  800df3:	83 f7 1f             	xor    $0x1f,%edi
  800df6:	75 48                	jne    800e40 <__udivdi3+0xa0>
  800df8:	39 f0                	cmp    %esi,%eax
  800dfa:	72 06                	jb     800e02 <__udivdi3+0x62>
  800dfc:	31 c0                	xor    %eax,%eax
  800dfe:	39 eb                	cmp    %ebp,%ebx
  800e00:	77 de                	ja     800de0 <__udivdi3+0x40>
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	eb d7                	jmp    800de0 <__udivdi3+0x40>
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d9                	mov    %ebx,%ecx
  800e12:	85 db                	test   %ebx,%ebx
  800e14:	75 0b                	jne    800e21 <__udivdi3+0x81>
  800e16:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	f7 f3                	div    %ebx
  800e1f:	89 c1                	mov    %eax,%ecx
  800e21:	31 d2                	xor    %edx,%edx
  800e23:	89 f0                	mov    %esi,%eax
  800e25:	f7 f1                	div    %ecx
  800e27:	89 c6                	mov    %eax,%esi
  800e29:	89 e8                	mov    %ebp,%eax
  800e2b:	89 f7                	mov    %esi,%edi
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	83 c4 1c             	add    $0x1c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 f9                	mov    %edi,%ecx
  800e42:	ba 20 00 00 00       	mov    $0x20,%edx
  800e47:	29 fa                	sub    %edi,%edx
  800e49:	d3 e0                	shl    %cl,%eax
  800e4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e4f:	89 d1                	mov    %edx,%ecx
  800e51:	89 d8                	mov    %ebx,%eax
  800e53:	d3 e8                	shr    %cl,%eax
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 c1                	or     %eax,%ecx
  800e5b:	89 f0                	mov    %esi,%eax
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e3                	shl    %cl,%ebx
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	d3 e8                	shr    %cl,%eax
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6f:	89 eb                	mov    %ebp,%ebx
  800e71:	d3 e6                	shl    %cl,%esi
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	d3 eb                	shr    %cl,%ebx
  800e77:	09 f3                	or     %esi,%ebx
  800e79:	89 c6                	mov    %eax,%esi
  800e7b:	89 f2                	mov    %esi,%edx
  800e7d:	89 d8                	mov    %ebx,%eax
  800e7f:	f7 74 24 08          	divl   0x8(%esp)
  800e83:	89 d6                	mov    %edx,%esi
  800e85:	89 c3                	mov    %eax,%ebx
  800e87:	f7 64 24 0c          	mull   0xc(%esp)
  800e8b:	39 d6                	cmp    %edx,%esi
  800e8d:	72 19                	jb     800ea8 <__udivdi3+0x108>
  800e8f:	89 f9                	mov    %edi,%ecx
  800e91:	d3 e5                	shl    %cl,%ebp
  800e93:	39 c5                	cmp    %eax,%ebp
  800e95:	73 04                	jae    800e9b <__udivdi3+0xfb>
  800e97:	39 d6                	cmp    %edx,%esi
  800e99:	74 0d                	je     800ea8 <__udivdi3+0x108>
  800e9b:	89 d8                	mov    %ebx,%eax
  800e9d:	31 ff                	xor    %edi,%edi
  800e9f:	e9 3c ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eab:	31 ff                	xor    %edi,%edi
  800ead:	e9 2e ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800eb2:	66 90                	xchg   %ax,%ax
  800eb4:	66 90                	xchg   %ax,%ax
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	f3 0f 1e fb          	endbr32 
  800ec4:	55                   	push   %ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 1c             	sub    $0x1c,%esp
  800ecb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ecf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ed3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800ed7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800edb:	89 f0                	mov    %esi,%eax
  800edd:	89 da                	mov    %ebx,%edx
  800edf:	85 ff                	test   %edi,%edi
  800ee1:	75 15                	jne    800ef8 <__umoddi3+0x38>
  800ee3:	39 dd                	cmp    %ebx,%ebp
  800ee5:	76 39                	jbe    800f20 <__umoddi3+0x60>
  800ee7:	f7 f5                	div    %ebp
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	83 c4 1c             	add    $0x1c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	39 df                	cmp    %ebx,%edi
  800efa:	77 f1                	ja     800eed <__umoddi3+0x2d>
  800efc:	0f bd cf             	bsr    %edi,%ecx
  800eff:	83 f1 1f             	xor    $0x1f,%ecx
  800f02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f06:	75 40                	jne    800f48 <__umoddi3+0x88>
  800f08:	39 df                	cmp    %ebx,%edi
  800f0a:	72 04                	jb     800f10 <__umoddi3+0x50>
  800f0c:	39 f5                	cmp    %esi,%ebp
  800f0e:	77 dd                	ja     800eed <__umoddi3+0x2d>
  800f10:	89 da                	mov    %ebx,%edx
  800f12:	89 f0                	mov    %esi,%eax
  800f14:	29 e8                	sub    %ebp,%eax
  800f16:	19 fa                	sbb    %edi,%edx
  800f18:	eb d3                	jmp    800eed <__umoddi3+0x2d>
  800f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f20:	89 e9                	mov    %ebp,%ecx
  800f22:	85 ed                	test   %ebp,%ebp
  800f24:	75 0b                	jne    800f31 <__umoddi3+0x71>
  800f26:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	f7 f5                	div    %ebp
  800f2f:	89 c1                	mov    %eax,%ecx
  800f31:	89 d8                	mov    %ebx,%eax
  800f33:	31 d2                	xor    %edx,%edx
  800f35:	f7 f1                	div    %ecx
  800f37:	89 f0                	mov    %esi,%eax
  800f39:	f7 f1                	div    %ecx
  800f3b:	89 d0                	mov    %edx,%eax
  800f3d:	31 d2                	xor    %edx,%edx
  800f3f:	eb ac                	jmp    800eed <__umoddi3+0x2d>
  800f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f48:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f4c:	ba 20 00 00 00       	mov    $0x20,%edx
  800f51:	29 c2                	sub    %eax,%edx
  800f53:	89 c1                	mov    %eax,%ecx
  800f55:	89 e8                	mov    %ebp,%eax
  800f57:	d3 e7                	shl    %cl,%edi
  800f59:	89 d1                	mov    %edx,%ecx
  800f5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f5f:	d3 e8                	shr    %cl,%eax
  800f61:	89 c1                	mov    %eax,%ecx
  800f63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f67:	09 f9                	or     %edi,%ecx
  800f69:	89 df                	mov    %ebx,%edi
  800f6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f6f:	89 c1                	mov    %eax,%ecx
  800f71:	d3 e5                	shl    %cl,%ebp
  800f73:	89 d1                	mov    %edx,%ecx
  800f75:	d3 ef                	shr    %cl,%edi
  800f77:	89 c1                	mov    %eax,%ecx
  800f79:	89 f0                	mov    %esi,%eax
  800f7b:	d3 e3                	shl    %cl,%ebx
  800f7d:	89 d1                	mov    %edx,%ecx
  800f7f:	89 fa                	mov    %edi,%edx
  800f81:	d3 e8                	shr    %cl,%eax
  800f83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f88:	09 d8                	or     %ebx,%eax
  800f8a:	f7 74 24 08          	divl   0x8(%esp)
  800f8e:	89 d3                	mov    %edx,%ebx
  800f90:	d3 e6                	shl    %cl,%esi
  800f92:	f7 e5                	mul    %ebp
  800f94:	89 c7                	mov    %eax,%edi
  800f96:	89 d1                	mov    %edx,%ecx
  800f98:	39 d3                	cmp    %edx,%ebx
  800f9a:	72 06                	jb     800fa2 <__umoddi3+0xe2>
  800f9c:	75 0e                	jne    800fac <__umoddi3+0xec>
  800f9e:	39 c6                	cmp    %eax,%esi
  800fa0:	73 0a                	jae    800fac <__umoddi3+0xec>
  800fa2:	29 e8                	sub    %ebp,%eax
  800fa4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fa8:	89 d1                	mov    %edx,%ecx
  800faa:	89 c7                	mov    %eax,%edi
  800fac:	89 f5                	mov    %esi,%ebp
  800fae:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fb2:	29 fd                	sub    %edi,%ebp
  800fb4:	19 cb                	sbb    %ecx,%ebx
  800fb6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	d3 e0                	shl    %cl,%eax
  800fbf:	89 f1                	mov    %esi,%ecx
  800fc1:	d3 ed                	shr    %cl,%ebp
  800fc3:	d3 eb                	shr    %cl,%ebx
  800fc5:	09 e8                	or     %ebp,%eax
  800fc7:	89 da                	mov    %ebx,%edx
  800fc9:	83 c4 1c             	add    $0x1c,%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    
