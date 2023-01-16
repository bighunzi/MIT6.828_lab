
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
	call libmain
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 b9 00 00 00       	call   8000f8 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	int i;

	cprintf("Making sure bss works right...\n");
  800045:	8d 83 04 ef ff ff    	lea    -0x10fc(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 1d 02 00 00       	call   80026e <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800054:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  800059:	83 bc 83 40 00 00 00 	cmpl   $0x0,0x40(%ebx,%eax,4)
  800060:	00 
  800061:	75 69                	jne    8000cc <umain+0x99>
	for (i = 0; i < ARRAYSIZE; i++)
  800063:	83 c0 01             	add    $0x1,%eax
  800066:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006b:	75 ec                	jne    800059 <umain+0x26>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80006d:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800072:	89 84 83 40 00 00 00 	mov    %eax,0x40(%ebx,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  800079:	83 c0 01             	add    $0x1,%eax
  80007c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800081:	75 ef                	jne    800072 <umain+0x3f>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  800088:	39 84 83 40 00 00 00 	cmp    %eax,0x40(%ebx,%eax,4)
  80008f:	75 51                	jne    8000e2 <umain+0xaf>
	for (i = 0; i < ARRAYSIZE; i++)
  800091:	83 c0 01             	add    $0x1,%eax
  800094:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800099:	75 ed                	jne    800088 <umain+0x55>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	8d 83 4c ef ff ff    	lea    -0x10b4(%ebx),%eax
  8000a4:	50                   	push   %eax
  8000a5:	e8 c4 01 00 00       	call   80026e <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000aa:	c7 83 40 10 40 00 00 	movl   $0x0,0x401040(%ebx)
  8000b1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000b4:	83 c4 0c             	add    $0xc,%esp
  8000b7:	8d 83 ab ef ff ff    	lea    -0x1055(%ebx),%eax
  8000bd:	50                   	push   %eax
  8000be:	6a 1a                	push   $0x1a
  8000c0:	8d 83 9c ef ff ff    	lea    -0x1064(%ebx),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 96 00 00 00       	call   800162 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000cc:	50                   	push   %eax
  8000cd:	8d 83 7f ef ff ff    	lea    -0x1081(%ebx),%eax
  8000d3:	50                   	push   %eax
  8000d4:	6a 11                	push   $0x11
  8000d6:	8d 83 9c ef ff ff    	lea    -0x1064(%ebx),%eax
  8000dc:	50                   	push   %eax
  8000dd:	e8 80 00 00 00       	call   800162 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000e2:	50                   	push   %eax
  8000e3:	8d 83 24 ef ff ff    	lea    -0x10dc(%ebx),%eax
  8000e9:	50                   	push   %eax
  8000ea:	6a 16                	push   $0x16
  8000ec:	8d 83 9c ef ff ff    	lea    -0x1064(%ebx),%eax
  8000f2:	50                   	push   %eax
  8000f3:	e8 6a 00 00 00       	call   800162 <_panic>

008000f8 <__x86.get_pc_thunk.bx>:
  8000f8:	8b 1c 24             	mov    (%esp),%ebx
  8000fb:	c3                   	ret    

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	53                   	push   %ebx
  800100:	83 ec 04             	sub    $0x4,%esp
  800103:	e8 f0 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  800108:	81 c3 f8 1e 00 00    	add    $0x1ef8,%ebx
  80010e:	8b 45 08             	mov    0x8(%ebp),%eax
  800111:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800114:	c7 83 40 00 40 00 00 	movl   $0x0,0x400040(%ebx)
  80011b:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011e:	85 c0                	test   %eax,%eax
  800120:	7e 08                	jle    80012a <libmain+0x2e>
		binaryname = argv[0];
  800122:	8b 0a                	mov    (%edx),%ecx
  800124:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	52                   	push   %edx
  80012e:	50                   	push   %eax
  80012f:	e8 ff fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800134:	e8 08 00 00 00       	call   800141 <exit>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 10             	sub    $0x10,%esp
  800148:	e8 ab ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  80014d:	81 c3 b3 1e 00 00    	add    $0x1eb3,%ebx
	sys_env_destroy(0);
  800153:	6a 00                	push   $0x0
  800155:	e8 fd 0a 00 00       	call   800c57 <sys_env_destroy>
}
  80015a:	83 c4 10             	add    $0x10,%esp
  80015d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
  80016b:	e8 88 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  800170:	81 c3 90 1e 00 00    	add    $0x1e90,%ebx
	va_list ap;

	va_start(ap, fmt);
  800176:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800179:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80017f:	8b 38                	mov    (%eax),%edi
  800181:	e8 26 0b 00 00       	call   800cac <sys_getenvid>
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	ff 75 0c             	push   0xc(%ebp)
  80018c:	ff 75 08             	push   0x8(%ebp)
  80018f:	57                   	push   %edi
  800190:	50                   	push   %eax
  800191:	8d 83 cc ef ff ff    	lea    -0x1034(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 d1 00 00 00       	call   80026e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019d:	83 c4 18             	add    $0x18,%esp
  8001a0:	56                   	push   %esi
  8001a1:	ff 75 10             	push   0x10(%ebp)
  8001a4:	e8 63 00 00 00       	call   80020c <vcprintf>
	cprintf("\n");
  8001a9:	8d 83 9a ef ff ff    	lea    -0x1066(%ebx),%eax
  8001af:	89 04 24             	mov    %eax,(%esp)
  8001b2:	e8 b7 00 00 00       	call   80026e <cprintf>
  8001b7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ba:	cc                   	int3   
  8001bb:	eb fd                	jmp    8001ba <_panic+0x58>

008001bd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	e8 31 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  8001c7:	81 c3 39 1e 00 00    	add    $0x1e39,%ebx
  8001cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001d0:	8b 16                	mov    (%esi),%edx
  8001d2:	8d 42 01             	lea    0x1(%edx),%eax
  8001d5:	89 06                	mov    %eax,(%esi)
  8001d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001da:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e3:	74 0b                	je     8001f0 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001e5:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5d                   	pop    %ebp
  8001ef:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	68 ff 00 00 00       	push   $0xff
  8001f8:	8d 46 08             	lea    0x8(%esi),%eax
  8001fb:	50                   	push   %eax
  8001fc:	e8 19 0a 00 00       	call   800c1a <sys_cputs>
		b->idx = 0;
  800201:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	eb d9                	jmp    8001e5 <putch+0x28>

0080020c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	53                   	push   %ebx
  800210:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800216:	e8 dd fe ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  80021b:	81 c3 e5 1d 00 00    	add    $0x1de5,%ebx
	struct printbuf b;

	b.idx = 0;
  800221:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800228:	00 00 00 
	b.cnt = 0;
  80022b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800232:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800235:	ff 75 0c             	push   0xc(%ebp)
  800238:	ff 75 08             	push   0x8(%ebp)
  80023b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800241:	50                   	push   %eax
  800242:	8d 83 bd e1 ff ff    	lea    -0x1e43(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 2c 01 00 00       	call   80037a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024e:	83 c4 08             	add    $0x8,%esp
  800251:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800257:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025d:	50                   	push   %eax
  80025e:	e8 b7 09 00 00       	call   800c1a <sys_cputs>

	return b.cnt;
}
  800263:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800269:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800274:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800277:	50                   	push   %eax
  800278:	ff 75 08             	push   0x8(%ebp)
  80027b:	e8 8c ff ff ff       	call   80020c <vcprintf>
	va_end(ap);

	return cnt;
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 2c             	sub    $0x2c,%esp
  80028b:	e8 0b 06 00 00       	call   80089b <__x86.get_pc_thunk.cx>
  800290:	81 c1 70 1d 00 00    	add    $0x1d70,%ecx
  800296:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800299:	89 c7                	mov    %eax,%edi
  80029b:	89 d6                	mov    %edx,%esi
  80029d:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a3:	89 d1                	mov    %edx,%ecx
  8002a5:	89 c2                	mov    %eax,%edx
  8002a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002aa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002bd:	39 c2                	cmp    %eax,%edx
  8002bf:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002c2:	72 41                	jb     800305 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	ff 75 18             	push   0x18(%ebp)
  8002ca:	83 eb 01             	sub    $0x1,%ebx
  8002cd:	53                   	push   %ebx
  8002ce:	50                   	push   %eax
  8002cf:	83 ec 08             	sub    $0x8,%esp
  8002d2:	ff 75 e4             	push   -0x1c(%ebp)
  8002d5:	ff 75 e0             	push   -0x20(%ebp)
  8002d8:	ff 75 d4             	push   -0x2c(%ebp)
  8002db:	ff 75 d0             	push   -0x30(%ebp)
  8002de:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e1:	e8 ea 09 00 00       	call   800cd0 <__udivdi3>
  8002e6:	83 c4 18             	add    $0x18,%esp
  8002e9:	52                   	push   %edx
  8002ea:	50                   	push   %eax
  8002eb:	89 f2                	mov    %esi,%edx
  8002ed:	89 f8                	mov    %edi,%eax
  8002ef:	e8 8e ff ff ff       	call   800282 <printnum>
  8002f4:	83 c4 20             	add    $0x20,%esp
  8002f7:	eb 13                	jmp    80030c <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f9:	83 ec 08             	sub    $0x8,%esp
  8002fc:	56                   	push   %esi
  8002fd:	ff 75 18             	push   0x18(%ebp)
  800300:	ff d7                	call   *%edi
  800302:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800305:	83 eb 01             	sub    $0x1,%ebx
  800308:	85 db                	test   %ebx,%ebx
  80030a:	7f ed                	jg     8002f9 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	56                   	push   %esi
  800310:	83 ec 04             	sub    $0x4,%esp
  800313:	ff 75 e4             	push   -0x1c(%ebp)
  800316:	ff 75 e0             	push   -0x20(%ebp)
  800319:	ff 75 d4             	push   -0x2c(%ebp)
  80031c:	ff 75 d0             	push   -0x30(%ebp)
  80031f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800322:	e8 c9 0a 00 00       	call   800df0 <__umoddi3>
  800327:	83 c4 14             	add    $0x14,%esp
  80032a:	0f be 84 03 ef ef ff 	movsbl -0x1011(%ebx,%eax,1),%eax
  800331:	ff 
  800332:	50                   	push   %eax
  800333:	ff d7                	call   *%edi
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800346:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	3b 50 04             	cmp    0x4(%eax),%edx
  80034f:	73 0a                	jae    80035b <sprintputch+0x1b>
		*b->buf++ = ch;
  800351:	8d 4a 01             	lea    0x1(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 45 08             	mov    0x8(%ebp),%eax
  800359:	88 02                	mov    %al,(%edx)
}
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <printfmt>:
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800363:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800366:	50                   	push   %eax
  800367:	ff 75 10             	push   0x10(%ebp)
  80036a:	ff 75 0c             	push   0xc(%ebp)
  80036d:	ff 75 08             	push   0x8(%ebp)
  800370:	e8 05 00 00 00       	call   80037a <vprintfmt>
}
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	c9                   	leave  
  800379:	c3                   	ret    

0080037a <vprintfmt>:
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
  800380:	83 ec 3c             	sub    $0x3c,%esp
  800383:	e8 0f 05 00 00       	call   800897 <__x86.get_pc_thunk.ax>
  800388:	05 78 1c 00 00       	add    $0x1c78,%eax
  80038d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800390:	8b 75 08             	mov    0x8(%ebp),%esi
  800393:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800396:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800399:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  80039f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003a2:	eb 0a                	jmp    8003ae <vprintfmt+0x34>
			putch(ch, putdat);
  8003a4:	83 ec 08             	sub    $0x8,%esp
  8003a7:	57                   	push   %edi
  8003a8:	50                   	push   %eax
  8003a9:	ff d6                	call   *%esi
  8003ab:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ae:	83 c3 01             	add    $0x1,%ebx
  8003b1:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003b5:	83 f8 25             	cmp    $0x25,%eax
  8003b8:	74 0c                	je     8003c6 <vprintfmt+0x4c>
			if (ch == '\0')
  8003ba:	85 c0                	test   %eax,%eax
  8003bc:	75 e6                	jne    8003a4 <vprintfmt+0x2a>
}
  8003be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c1:	5b                   	pop    %ebx
  8003c2:	5e                   	pop    %esi
  8003c3:	5f                   	pop    %edi
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    
		padc = ' ';
  8003c6:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003ca:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8003d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003d8:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  8003df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003e7:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8d 43 01             	lea    0x1(%ebx),%eax
  8003ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f0:	0f b6 13             	movzbl (%ebx),%edx
  8003f3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f6:	3c 55                	cmp    $0x55,%al
  8003f8:	0f 87 fd 03 00 00    	ja     8007fb <.L20>
  8003fe:	0f b6 c0             	movzbl %al,%eax
  800401:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800404:	89 ce                	mov    %ecx,%esi
  800406:	03 b4 81 7c f0 ff ff 	add    -0xf84(%ecx,%eax,4),%esi
  80040d:	ff e6                	jmp    *%esi

0080040f <.L68>:
  80040f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800412:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800416:	eb d2                	jmp    8003ea <vprintfmt+0x70>

00800418 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80041b:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80041f:	eb c9                	jmp    8003ea <vprintfmt+0x70>

00800421 <.L31>:
  800421:	0f b6 d2             	movzbl %dl,%edx
  800424:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800427:	b8 00 00 00 00       	mov    $0x0,%eax
  80042c:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80042f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800432:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800436:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800439:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80043c:	83 f9 09             	cmp    $0x9,%ecx
  80043f:	77 58                	ja     800499 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800441:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800444:	eb e9                	jmp    80042f <.L31+0xe>

00800446 <.L34>:
			precision = va_arg(ap, int);
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 40 04             	lea    0x4(%eax),%eax
  800454:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80045a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045e:	79 8a                	jns    8003ea <vprintfmt+0x70>
				width = precision, precision = -1;
  800460:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800463:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800466:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80046d:	e9 78 ff ff ff       	jmp    8003ea <vprintfmt+0x70>

00800472 <.L33>:
  800472:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	0f 49 c2             	cmovns %edx,%eax
  80047f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800485:	e9 60 ff ff ff       	jmp    8003ea <vprintfmt+0x70>

0080048a <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80048d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800494:	e9 51 ff ff ff       	jmp    8003ea <vprintfmt+0x70>
  800499:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80049c:	89 75 08             	mov    %esi,0x8(%ebp)
  80049f:	eb b9                	jmp    80045a <.L34+0x14>

008004a1 <.L27>:
			lflag++;
  8004a1:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004a8:	e9 3d ff ff ff       	jmp    8003ea <vprintfmt+0x70>

008004ad <.L30>:
			putch(va_arg(ap, int), putdat);
  8004ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 58 04             	lea    0x4(%eax),%ebx
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	57                   	push   %edi
  8004ba:	ff 30                	push   (%eax)
  8004bc:	ff d6                	call   *%esi
			break;
  8004be:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004c1:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004c4:	e9 c8 02 00 00       	jmp    800791 <.L25+0x45>

008004c9 <.L28>:
			err = va_arg(ap, int);
  8004c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 58 04             	lea    0x4(%eax),%ebx
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	89 d0                	mov    %edx,%eax
  8004d6:	f7 d8                	neg    %eax
  8004d8:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004db:	83 f8 06             	cmp    $0x6,%eax
  8004de:	7f 27                	jg     800507 <.L28+0x3e>
  8004e0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e3:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	74 1d                	je     800507 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004ea:	52                   	push   %edx
  8004eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ee:	8d 80 10 f0 ff ff    	lea    -0xff0(%eax),%eax
  8004f4:	50                   	push   %eax
  8004f5:	57                   	push   %edi
  8004f6:	56                   	push   %esi
  8004f7:	e8 61 fe ff ff       	call   80035d <printfmt>
  8004fc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ff:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800502:	e9 8a 02 00 00       	jmp    800791 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800507:	50                   	push   %eax
  800508:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050b:	8d 80 07 f0 ff ff    	lea    -0xff9(%eax),%eax
  800511:	50                   	push   %eax
  800512:	57                   	push   %edi
  800513:	56                   	push   %esi
  800514:	e8 44 fe ff ff       	call   80035d <printfmt>
  800519:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051c:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051f:	e9 6d 02 00 00       	jmp    800791 <.L25+0x45>

00800524 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800524:	8b 75 08             	mov    0x8(%ebp),%esi
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	83 c0 04             	add    $0x4,%eax
  80052d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800535:	85 d2                	test   %edx,%edx
  800537:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053a:	8d 80 00 f0 ff ff    	lea    -0x1000(%eax),%eax
  800540:	0f 45 c2             	cmovne %edx,%eax
  800543:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800546:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054a:	7e 06                	jle    800552 <.L24+0x2e>
  80054c:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800550:	75 0d                	jne    80055f <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800552:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800555:	89 c3                	mov    %eax,%ebx
  800557:	03 45 d4             	add    -0x2c(%ebp),%eax
  80055a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80055d:	eb 58                	jmp    8005b7 <.L24+0x93>
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 d8             	push   -0x28(%ebp)
  800565:	ff 75 c8             	push   -0x38(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	e8 47 03 00 00       	call   8008b7 <strnlen>
  800570:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800573:	29 c2                	sub    %eax,%edx
  800575:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80057d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800581:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	eb 0f                	jmp    800595 <.L24+0x71>
					putch(padc, putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	57                   	push   %edi
  80058a:	ff 75 d4             	push   -0x2c(%ebp)
  80058d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	83 eb 01             	sub    $0x1,%ebx
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	85 db                	test   %ebx,%ebx
  800597:	7f ed                	jg     800586 <.L24+0x62>
  800599:	8b 55 bc             	mov    -0x44(%ebp),%edx
  80059c:	85 d2                	test   %edx,%edx
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	0f 49 c2             	cmovns %edx,%eax
  8005a6:	29 c2                	sub    %eax,%edx
  8005a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005ab:	eb a5                	jmp    800552 <.L24+0x2e>
					putch(ch, putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	57                   	push   %edi
  8005b1:	52                   	push   %edx
  8005b2:	ff d6                	call   *%esi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005ba:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bc:	83 c3 01             	add    $0x1,%ebx
  8005bf:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005c3:	0f be d0             	movsbl %al,%edx
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 4b                	je     800615 <.L24+0xf1>
  8005ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ce:	78 06                	js     8005d6 <.L24+0xb2>
  8005d0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005d4:	78 1e                	js     8005f4 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d6:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005da:	74 d1                	je     8005ad <.L24+0x89>
  8005dc:	0f be c0             	movsbl %al,%eax
  8005df:	83 e8 20             	sub    $0x20,%eax
  8005e2:	83 f8 5e             	cmp    $0x5e,%eax
  8005e5:	76 c6                	jbe    8005ad <.L24+0x89>
					putch('?', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	57                   	push   %edi
  8005eb:	6a 3f                	push   $0x3f
  8005ed:	ff d6                	call   *%esi
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	eb c3                	jmp    8005b7 <.L24+0x93>
  8005f4:	89 cb                	mov    %ecx,%ebx
  8005f6:	eb 0e                	jmp    800606 <.L24+0xe2>
				putch(' ', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	57                   	push   %edi
  8005fc:	6a 20                	push   $0x20
  8005fe:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800600:	83 eb 01             	sub    $0x1,%ebx
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	85 db                	test   %ebx,%ebx
  800608:	7f ee                	jg     8005f8 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80060a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
  800610:	e9 7c 01 00 00       	jmp    800791 <.L25+0x45>
  800615:	89 cb                	mov    %ecx,%ebx
  800617:	eb ed                	jmp    800606 <.L24+0xe2>

00800619 <.L29>:
	if (lflag >= 2)
  800619:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80061c:	8b 75 08             	mov    0x8(%ebp),%esi
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7f 1b                	jg     80063f <.L29+0x26>
	else if (lflag)
  800624:	85 c9                	test   %ecx,%ecx
  800626:	74 63                	je     80068b <.L29+0x72>
		return va_arg(*ap, long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800630:	99                   	cltd   
  800631:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 40 04             	lea    0x4(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
  80063d:	eb 17                	jmp    800656 <.L29+0x3d>
		return va_arg(*ap, long long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 50 04             	mov    0x4(%eax),%edx
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8d 40 08             	lea    0x8(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800656:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800659:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80065c:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800661:	85 db                	test   %ebx,%ebx
  800663:	0f 89 0e 01 00 00    	jns    800777 <.L25+0x2b>
				putch('-', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	57                   	push   %edi
  80066d:	6a 2d                	push   $0x2d
  80066f:	ff d6                	call   *%esi
				num = -(long long) num;
  800671:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800674:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800677:	f7 d9                	neg    %ecx
  800679:	83 d3 00             	adc    $0x0,%ebx
  80067c:	f7 db                	neg    %ebx
  80067e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800681:	ba 0a 00 00 00       	mov    $0xa,%edx
  800686:	e9 ec 00 00 00       	jmp    800777 <.L25+0x2b>
		return va_arg(*ap, int);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800693:	99                   	cltd   
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 40 04             	lea    0x4(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a0:	eb b4                	jmp    800656 <.L29+0x3d>

008006a2 <.L23>:
	if (lflag >= 2)
  8006a2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a8:	83 f9 01             	cmp    $0x1,%ecx
  8006ab:	7f 1e                	jg     8006cb <.L23+0x29>
	else if (lflag)
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	74 32                	je     8006e3 <.L23+0x41>
		return va_arg(*ap, unsigned long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 08                	mov    (%eax),%ecx
  8006b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c1:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006c6:	e9 ac 00 00 00       	jmp    800777 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 08                	mov    (%eax),%ecx
  8006d0:	8b 58 04             	mov    0x4(%eax),%ebx
  8006d3:	8d 40 08             	lea    0x8(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d9:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006de:	e9 94 00 00 00       	jmp    800777 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 08                	mov    (%eax),%ecx
  8006e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f3:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006f8:	eb 7d                	jmp    800777 <.L25+0x2b>

008006fa <.L26>:
	if (lflag >= 2)
  8006fa:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	83 f9 01             	cmp    $0x1,%ecx
  800703:	7f 1b                	jg     800720 <.L26+0x26>
	else if (lflag)
  800705:	85 c9                	test   %ecx,%ecx
  800707:	74 2c                	je     800735 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8b 08                	mov    (%eax),%ecx
  80070e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800713:	8d 40 04             	lea    0x4(%eax),%eax
  800716:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800719:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
  80071e:	eb 57                	jmp    800777 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8b 08                	mov    (%eax),%ecx
  800725:	8b 58 04             	mov    0x4(%eax),%ebx
  800728:	8d 40 08             	lea    0x8(%eax),%eax
  80072b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80072e:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
  800733:	eb 42                	jmp    800777 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 08                	mov    (%eax),%ecx
  80073a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073f:	8d 40 04             	lea    0x4(%eax),%eax
  800742:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800745:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
  80074a:	eb 2b                	jmp    800777 <.L25+0x2b>

0080074c <.L25>:
			putch('0', putdat);
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	57                   	push   %edi
  800753:	6a 30                	push   $0x30
  800755:	ff d6                	call   *%esi
			putch('x', putdat);
  800757:	83 c4 08             	add    $0x8,%esp
  80075a:	57                   	push   %edi
  80075b:	6a 78                	push   $0x78
  80075d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8b 08                	mov    (%eax),%ecx
  800764:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800769:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80076c:	8d 40 04             	lea    0x4(%eax),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800772:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800777:	83 ec 0c             	sub    $0xc,%esp
  80077a:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	ff 75 d4             	push   -0x2c(%ebp)
  800782:	52                   	push   %edx
  800783:	53                   	push   %ebx
  800784:	51                   	push   %ecx
  800785:	89 fa                	mov    %edi,%edx
  800787:	89 f0                	mov    %esi,%eax
  800789:	e8 f4 fa ff ff       	call   800282 <printnum>
			break;
  80078e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800791:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800794:	e9 15 fc ff ff       	jmp    8003ae <vprintfmt+0x34>

00800799 <.L21>:
	if (lflag >= 2)
  800799:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80079c:	8b 75 08             	mov    0x8(%ebp),%esi
  80079f:	83 f9 01             	cmp    $0x1,%ecx
  8007a2:	7f 1b                	jg     8007bf <.L21+0x26>
	else if (lflag)
  8007a4:	85 c9                	test   %ecx,%ecx
  8007a6:	74 2c                	je     8007d4 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8b 08                	mov    (%eax),%ecx
  8007ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b2:	8d 40 04             	lea    0x4(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b8:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8007bd:	eb b8                	jmp    800777 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8b 08                	mov    (%eax),%ecx
  8007c4:	8b 58 04             	mov    0x4(%eax),%ebx
  8007c7:	8d 40 08             	lea    0x8(%eax),%eax
  8007ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cd:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007d2:	eb a3                	jmp    800777 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8b 08                	mov    (%eax),%ecx
  8007d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007de:	8d 40 04             	lea    0x4(%eax),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e4:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007e9:	eb 8c                	jmp    800777 <.L25+0x2b>

008007eb <.L35>:
			putch(ch, putdat);
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	57                   	push   %edi
  8007f2:	6a 25                	push   $0x25
  8007f4:	ff d6                	call   *%esi
			break;
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	eb 96                	jmp    800791 <.L25+0x45>

008007fb <.L20>:
			putch('%', putdat);
  8007fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	57                   	push   %edi
  800802:	6a 25                	push   $0x25
  800804:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	89 d8                	mov    %ebx,%eax
  80080b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80080f:	74 05                	je     800816 <.L20+0x1b>
  800811:	83 e8 01             	sub    $0x1,%eax
  800814:	eb f5                	jmp    80080b <.L20+0x10>
  800816:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800819:	e9 73 ff ff ff       	jmp    800791 <.L25+0x45>

0080081e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	53                   	push   %ebx
  800822:	83 ec 14             	sub    $0x14,%esp
  800825:	e8 ce f8 ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  80082a:	81 c3 d6 17 00 00    	add    $0x17d6,%ebx
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800836:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800839:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80083d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800840:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800847:	85 c0                	test   %eax,%eax
  800849:	74 2b                	je     800876 <vsnprintf+0x58>
  80084b:	85 d2                	test   %edx,%edx
  80084d:	7e 27                	jle    800876 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80084f:	ff 75 14             	push   0x14(%ebp)
  800852:	ff 75 10             	push   0x10(%ebp)
  800855:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	8d 83 40 e3 ff ff    	lea    -0x1cc0(%ebx),%eax
  80085f:	50                   	push   %eax
  800860:	e8 15 fb ff ff       	call   80037a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800865:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800868:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086e:	83 c4 10             	add    $0x10,%esp
}
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    
		return -E_INVAL;
  800876:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087b:	eb f4                	jmp    800871 <vsnprintf+0x53>

0080087d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800883:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800886:	50                   	push   %eax
  800887:	ff 75 10             	push   0x10(%ebp)
  80088a:	ff 75 0c             	push   0xc(%ebp)
  80088d:	ff 75 08             	push   0x8(%ebp)
  800890:	e8 89 ff ff ff       	call   80081e <vsnprintf>
	va_end(ap);

	return rc;
}
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <__x86.get_pc_thunk.ax>:
  800897:	8b 04 24             	mov    (%esp),%eax
  80089a:	c3                   	ret    

0080089b <__x86.get_pc_thunk.cx>:
  80089b:	8b 0c 24             	mov    (%esp),%ecx
  80089e:	c3                   	ret    

0080089f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008aa:	eb 03                	jmp    8008af <strlen+0x10>
		n++;
  8008ac:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b3:	75 f7                	jne    8008ac <strlen+0xd>
	return n;
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c5:	eb 03                	jmp    8008ca <strnlen+0x13>
		n++;
  8008c7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ca:	39 d0                	cmp    %edx,%eax
  8008cc:	74 08                	je     8008d6 <strnlen+0x1f>
  8008ce:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d2:	75 f3                	jne    8008c7 <strnlen+0x10>
  8008d4:	89 c2                	mov    %eax,%edx
	return n;
}
  8008d6:	89 d0                	mov    %edx,%eax
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	53                   	push   %ebx
  8008de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008ed:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	84 d2                	test   %dl,%dl
  8008f5:	75 f2                	jne    8008e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008f7:	89 c8                	mov    %ecx,%eax
  8008f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    

008008fe <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	53                   	push   %ebx
  800902:	83 ec 10             	sub    $0x10,%esp
  800905:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800908:	53                   	push   %ebx
  800909:	e8 91 ff ff ff       	call   80089f <strlen>
  80090e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800911:	ff 75 0c             	push   0xc(%ebp)
  800914:	01 d8                	add    %ebx,%eax
  800916:	50                   	push   %eax
  800917:	e8 be ff ff ff       	call   8008da <strcpy>
	return dst;
}
  80091c:	89 d8                	mov    %ebx,%eax
  80091e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 75 08             	mov    0x8(%ebp),%esi
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092e:	89 f3                	mov    %esi,%ebx
  800930:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800933:	89 f0                	mov    %esi,%eax
  800935:	eb 0f                	jmp    800946 <strncpy+0x23>
		*dst++ = *src;
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	0f b6 0a             	movzbl (%edx),%ecx
  80093d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800940:	80 f9 01             	cmp    $0x1,%cl
  800943:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800946:	39 d8                	cmp    %ebx,%eax
  800948:	75 ed                	jne    800937 <strncpy+0x14>
	}
	return ret;
}
  80094a:	89 f0                	mov    %esi,%eax
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	8b 75 08             	mov    0x8(%ebp),%esi
  800958:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095b:	8b 55 10             	mov    0x10(%ebp),%edx
  80095e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800960:	85 d2                	test   %edx,%edx
  800962:	74 21                	je     800985 <strlcpy+0x35>
  800964:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800968:	89 f2                	mov    %esi,%edx
  80096a:	eb 09                	jmp    800975 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096c:	83 c1 01             	add    $0x1,%ecx
  80096f:	83 c2 01             	add    $0x1,%edx
  800972:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800975:	39 c2                	cmp    %eax,%edx
  800977:	74 09                	je     800982 <strlcpy+0x32>
  800979:	0f b6 19             	movzbl (%ecx),%ebx
  80097c:	84 db                	test   %bl,%bl
  80097e:	75 ec                	jne    80096c <strlcpy+0x1c>
  800980:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800982:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800985:	29 f0                	sub    %esi,%eax
}
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800994:	eb 06                	jmp    80099c <strcmp+0x11>
		p++, q++;
  800996:	83 c1 01             	add    $0x1,%ecx
  800999:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80099c:	0f b6 01             	movzbl (%ecx),%eax
  80099f:	84 c0                	test   %al,%al
  8009a1:	74 04                	je     8009a7 <strcmp+0x1c>
  8009a3:	3a 02                	cmp    (%edx),%al
  8009a5:	74 ef                	je     800996 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a7:	0f b6 c0             	movzbl %al,%eax
  8009aa:	0f b6 12             	movzbl (%edx),%edx
  8009ad:	29 d0                	sub    %edx,%eax
}
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	53                   	push   %ebx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	89 c3                	mov    %eax,%ebx
  8009bd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c0:	eb 06                	jmp    8009c8 <strncmp+0x17>
		n--, p++, q++;
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c8:	39 d8                	cmp    %ebx,%eax
  8009ca:	74 18                	je     8009e4 <strncmp+0x33>
  8009cc:	0f b6 08             	movzbl (%eax),%ecx
  8009cf:	84 c9                	test   %cl,%cl
  8009d1:	74 04                	je     8009d7 <strncmp+0x26>
  8009d3:	3a 0a                	cmp    (%edx),%cl
  8009d5:	74 eb                	je     8009c2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d7:	0f b6 00             	movzbl (%eax),%eax
  8009da:	0f b6 12             	movzbl (%edx),%edx
  8009dd:	29 d0                	sub    %edx,%eax
}
  8009df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    
		return 0;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e9:	eb f4                	jmp    8009df <strncmp+0x2e>

008009eb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f5:	eb 03                	jmp    8009fa <strchr+0xf>
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	0f b6 10             	movzbl (%eax),%edx
  8009fd:	84 d2                	test   %dl,%dl
  8009ff:	74 06                	je     800a07 <strchr+0x1c>
		if (*s == c)
  800a01:	38 ca                	cmp    %cl,%dl
  800a03:	75 f2                	jne    8009f7 <strchr+0xc>
  800a05:	eb 05                	jmp    800a0c <strchr+0x21>
			return (char *) s;
	return 0;
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a18:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a1b:	38 ca                	cmp    %cl,%dl
  800a1d:	74 09                	je     800a28 <strfind+0x1a>
  800a1f:	84 d2                	test   %dl,%dl
  800a21:	74 05                	je     800a28 <strfind+0x1a>
	for (; *s; s++)
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	eb f0                	jmp    800a18 <strfind+0xa>
			break;
	return (char *) s;
}
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a36:	85 c9                	test   %ecx,%ecx
  800a38:	74 2f                	je     800a69 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3a:	89 f8                	mov    %edi,%eax
  800a3c:	09 c8                	or     %ecx,%eax
  800a3e:	a8 03                	test   $0x3,%al
  800a40:	75 21                	jne    800a63 <memset+0x39>
		c &= 0xFF;
  800a42:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a46:	89 d0                	mov    %edx,%eax
  800a48:	c1 e0 08             	shl    $0x8,%eax
  800a4b:	89 d3                	mov    %edx,%ebx
  800a4d:	c1 e3 18             	shl    $0x18,%ebx
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	c1 e6 10             	shl    $0x10,%esi
  800a55:	09 f3                	or     %esi,%ebx
  800a57:	09 da                	or     %ebx,%edx
  800a59:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a5e:	fc                   	cld    
  800a5f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a61:	eb 06                	jmp    800a69 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a66:	fc                   	cld    
  800a67:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a69:	89 f8                	mov    %edi,%eax
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7e:	39 c6                	cmp    %eax,%esi
  800a80:	73 32                	jae    800ab4 <memmove+0x44>
  800a82:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a85:	39 c2                	cmp    %eax,%edx
  800a87:	76 2b                	jbe    800ab4 <memmove+0x44>
		s += n;
		d += n;
  800a89:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8c:	89 d6                	mov    %edx,%esi
  800a8e:	09 fe                	or     %edi,%esi
  800a90:	09 ce                	or     %ecx,%esi
  800a92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a98:	75 0e                	jne    800aa8 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a9a:	83 ef 04             	sub    $0x4,%edi
  800a9d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aa3:	fd                   	std    
  800aa4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa6:	eb 09                	jmp    800ab1 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa8:	83 ef 01             	sub    $0x1,%edi
  800aab:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aae:	fd                   	std    
  800aaf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab1:	fc                   	cld    
  800ab2:	eb 1a                	jmp    800ace <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab4:	89 f2                	mov    %esi,%edx
  800ab6:	09 c2                	or     %eax,%edx
  800ab8:	09 ca                	or     %ecx,%edx
  800aba:	f6 c2 03             	test   $0x3,%dl
  800abd:	75 0a                	jne    800ac9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ac2:	89 c7                	mov    %eax,%edi
  800ac4:	fc                   	cld    
  800ac5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac7:	eb 05                	jmp    800ace <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ac9:	89 c7                	mov    %eax,%edi
  800acb:	fc                   	cld    
  800acc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad8:	ff 75 10             	push   0x10(%ebp)
  800adb:	ff 75 0c             	push   0xc(%ebp)
  800ade:	ff 75 08             	push   0x8(%ebp)
  800ae1:	e8 8a ff ff ff       	call   800a70 <memmove>
}
  800ae6:	c9                   	leave  
  800ae7:	c3                   	ret    

00800ae8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af3:	89 c6                	mov    %eax,%esi
  800af5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af8:	eb 06                	jmp    800b00 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b00:	39 f0                	cmp    %esi,%eax
  800b02:	74 14                	je     800b18 <memcmp+0x30>
		if (*s1 != *s2)
  800b04:	0f b6 08             	movzbl (%eax),%ecx
  800b07:	0f b6 1a             	movzbl (%edx),%ebx
  800b0a:	38 d9                	cmp    %bl,%cl
  800b0c:	74 ec                	je     800afa <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b0e:	0f b6 c1             	movzbl %cl,%eax
  800b11:	0f b6 db             	movzbl %bl,%ebx
  800b14:	29 d8                	sub    %ebx,%eax
  800b16:	eb 05                	jmp    800b1d <memcmp+0x35>
	}

	return 0;
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2a:	89 c2                	mov    %eax,%edx
  800b2c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b2f:	eb 03                	jmp    800b34 <memfind+0x13>
  800b31:	83 c0 01             	add    $0x1,%eax
  800b34:	39 d0                	cmp    %edx,%eax
  800b36:	73 04                	jae    800b3c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b38:	38 08                	cmp    %cl,(%eax)
  800b3a:	75 f5                	jne    800b31 <memfind+0x10>
			break;
	return (void *) s;
}
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4a:	eb 03                	jmp    800b4f <strtol+0x11>
		s++;
  800b4c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b4f:	0f b6 02             	movzbl (%edx),%eax
  800b52:	3c 20                	cmp    $0x20,%al
  800b54:	74 f6                	je     800b4c <strtol+0xe>
  800b56:	3c 09                	cmp    $0x9,%al
  800b58:	74 f2                	je     800b4c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b5a:	3c 2b                	cmp    $0x2b,%al
  800b5c:	74 2a                	je     800b88 <strtol+0x4a>
	int neg = 0;
  800b5e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b63:	3c 2d                	cmp    $0x2d,%al
  800b65:	74 2b                	je     800b92 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b67:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6d:	75 0f                	jne    800b7e <strtol+0x40>
  800b6f:	80 3a 30             	cmpb   $0x30,(%edx)
  800b72:	74 28                	je     800b9c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b74:	85 db                	test   %ebx,%ebx
  800b76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7b:	0f 44 d8             	cmove  %eax,%ebx
  800b7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b83:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b86:	eb 46                	jmp    800bce <strtol+0x90>
		s++;
  800b88:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b90:	eb d5                	jmp    800b67 <strtol+0x29>
		s++, neg = 1;
  800b92:	83 c2 01             	add    $0x1,%edx
  800b95:	bf 01 00 00 00       	mov    $0x1,%edi
  800b9a:	eb cb                	jmp    800b67 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba0:	74 0e                	je     800bb0 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ba2:	85 db                	test   %ebx,%ebx
  800ba4:	75 d8                	jne    800b7e <strtol+0x40>
		s++, base = 8;
  800ba6:	83 c2 01             	add    $0x1,%edx
  800ba9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bae:	eb ce                	jmp    800b7e <strtol+0x40>
		s += 2, base = 16;
  800bb0:	83 c2 02             	add    $0x2,%edx
  800bb3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb8:	eb c4                	jmp    800b7e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bba:	0f be c0             	movsbl %al,%eax
  800bbd:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc0:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bc3:	7d 3a                	jge    800bff <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bc5:	83 c2 01             	add    $0x1,%edx
  800bc8:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bcc:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bce:	0f b6 02             	movzbl (%edx),%eax
  800bd1:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bd4:	89 f3                	mov    %esi,%ebx
  800bd6:	80 fb 09             	cmp    $0x9,%bl
  800bd9:	76 df                	jbe    800bba <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bdb:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bde:	89 f3                	mov    %esi,%ebx
  800be0:	80 fb 19             	cmp    $0x19,%bl
  800be3:	77 08                	ja     800bed <strtol+0xaf>
			dig = *s - 'a' + 10;
  800be5:	0f be c0             	movsbl %al,%eax
  800be8:	83 e8 57             	sub    $0x57,%eax
  800beb:	eb d3                	jmp    800bc0 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bed:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bf0:	89 f3                	mov    %esi,%ebx
  800bf2:	80 fb 19             	cmp    $0x19,%bl
  800bf5:	77 08                	ja     800bff <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bf7:	0f be c0             	movsbl %al,%eax
  800bfa:	83 e8 37             	sub    $0x37,%eax
  800bfd:	eb c1                	jmp    800bc0 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c03:	74 05                	je     800c0a <strtol+0xcc>
		*endptr = (char *) s;
  800c05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c08:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c0a:	89 c8                	mov    %ecx,%eax
  800c0c:	f7 d8                	neg    %eax
  800c0e:	85 ff                	test   %edi,%edi
  800c10:	0f 45 c8             	cmovne %eax,%ecx
}
  800c13:	89 c8                	mov    %ecx,%eax
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c20:	b8 00 00 00 00       	mov    $0x0,%eax
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	89 c3                	mov    %eax,%ebx
  800c2d:	89 c7                	mov    %eax,%edi
  800c2f:	89 c6                	mov    %eax,%esi
  800c31:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c43:	b8 01 00 00 00       	mov    $0x1,%eax
  800c48:	89 d1                	mov    %edx,%ecx
  800c4a:	89 d3                	mov    %edx,%ebx
  800c4c:	89 d7                	mov    %edx,%edi
  800c4e:	89 d6                	mov    %edx,%esi
  800c50:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 1c             	sub    $0x1c,%esp
  800c60:	e8 32 fc ff ff       	call   800897 <__x86.get_pc_thunk.ax>
  800c65:	05 9b 13 00 00       	add    $0x139b,%eax
  800c6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	b8 03 00 00 00       	mov    $0x3,%eax
  800c7a:	89 cb                	mov    %ecx,%ebx
  800c7c:	89 cf                	mov    %ecx,%edi
  800c7e:	89 ce                	mov    %ecx,%esi
  800c80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7f 08                	jg     800c8e <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 03                	push   $0x3
  800c94:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c97:	8d 83 d4 f1 ff ff    	lea    -0xe2c(%ebx),%eax
  800c9d:	50                   	push   %eax
  800c9e:	6a 23                	push   $0x23
  800ca0:	8d 83 f1 f1 ff ff    	lea    -0xe0f(%ebx),%eax
  800ca6:	50                   	push   %eax
  800ca7:	e8 b6 f4 ff ff       	call   800162 <_panic>

00800cac <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb7:	b8 02 00 00 00       	mov    $0x2,%eax
  800cbc:	89 d1                	mov    %edx,%ecx
  800cbe:	89 d3                	mov    %edx,%ebx
  800cc0:	89 d7                	mov    %edx,%edi
  800cc2:	89 d6                	mov    %edx,%esi
  800cc4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    
  800ccb:	66 90                	xchg   %ax,%ax
  800ccd:	66 90                	xchg   %ax,%ax
  800ccf:	90                   	nop

00800cd0 <__udivdi3>:
  800cd0:	f3 0f 1e fb          	endbr32 
  800cd4:	55                   	push   %ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 1c             	sub    $0x1c,%esp
  800cdb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800cdf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ce3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ce7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	75 19                	jne    800d08 <__udivdi3+0x38>
  800cef:	39 f3                	cmp    %esi,%ebx
  800cf1:	76 4d                	jbe    800d40 <__udivdi3+0x70>
  800cf3:	31 ff                	xor    %edi,%edi
  800cf5:	89 e8                	mov    %ebp,%eax
  800cf7:	89 f2                	mov    %esi,%edx
  800cf9:	f7 f3                	div    %ebx
  800cfb:	89 fa                	mov    %edi,%edx
  800cfd:	83 c4 1c             	add    $0x1c,%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    
  800d05:	8d 76 00             	lea    0x0(%esi),%esi
  800d08:	39 f0                	cmp    %esi,%eax
  800d0a:	76 14                	jbe    800d20 <__udivdi3+0x50>
  800d0c:	31 ff                	xor    %edi,%edi
  800d0e:	31 c0                	xor    %eax,%eax
  800d10:	89 fa                	mov    %edi,%edx
  800d12:	83 c4 1c             	add    $0x1c,%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
  800d1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d20:	0f bd f8             	bsr    %eax,%edi
  800d23:	83 f7 1f             	xor    $0x1f,%edi
  800d26:	75 48                	jne    800d70 <__udivdi3+0xa0>
  800d28:	39 f0                	cmp    %esi,%eax
  800d2a:	72 06                	jb     800d32 <__udivdi3+0x62>
  800d2c:	31 c0                	xor    %eax,%eax
  800d2e:	39 eb                	cmp    %ebp,%ebx
  800d30:	77 de                	ja     800d10 <__udivdi3+0x40>
  800d32:	b8 01 00 00 00       	mov    $0x1,%eax
  800d37:	eb d7                	jmp    800d10 <__udivdi3+0x40>
  800d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d40:	89 d9                	mov    %ebx,%ecx
  800d42:	85 db                	test   %ebx,%ebx
  800d44:	75 0b                	jne    800d51 <__udivdi3+0x81>
  800d46:	b8 01 00 00 00       	mov    $0x1,%eax
  800d4b:	31 d2                	xor    %edx,%edx
  800d4d:	f7 f3                	div    %ebx
  800d4f:	89 c1                	mov    %eax,%ecx
  800d51:	31 d2                	xor    %edx,%edx
  800d53:	89 f0                	mov    %esi,%eax
  800d55:	f7 f1                	div    %ecx
  800d57:	89 c6                	mov    %eax,%esi
  800d59:	89 e8                	mov    %ebp,%eax
  800d5b:	89 f7                	mov    %esi,%edi
  800d5d:	f7 f1                	div    %ecx
  800d5f:	89 fa                	mov    %edi,%edx
  800d61:	83 c4 1c             	add    $0x1c,%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	89 f9                	mov    %edi,%ecx
  800d72:	ba 20 00 00 00       	mov    $0x20,%edx
  800d77:	29 fa                	sub    %edi,%edx
  800d79:	d3 e0                	shl    %cl,%eax
  800d7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7f:	89 d1                	mov    %edx,%ecx
  800d81:	89 d8                	mov    %ebx,%eax
  800d83:	d3 e8                	shr    %cl,%eax
  800d85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d89:	09 c1                	or     %eax,%ecx
  800d8b:	89 f0                	mov    %esi,%eax
  800d8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	d3 e3                	shl    %cl,%ebx
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	d3 e8                	shr    %cl,%eax
  800d99:	89 f9                	mov    %edi,%ecx
  800d9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d9f:	89 eb                	mov    %ebp,%ebx
  800da1:	d3 e6                	shl    %cl,%esi
  800da3:	89 d1                	mov    %edx,%ecx
  800da5:	d3 eb                	shr    %cl,%ebx
  800da7:	09 f3                	or     %esi,%ebx
  800da9:	89 c6                	mov    %eax,%esi
  800dab:	89 f2                	mov    %esi,%edx
  800dad:	89 d8                	mov    %ebx,%eax
  800daf:	f7 74 24 08          	divl   0x8(%esp)
  800db3:	89 d6                	mov    %edx,%esi
  800db5:	89 c3                	mov    %eax,%ebx
  800db7:	f7 64 24 0c          	mull   0xc(%esp)
  800dbb:	39 d6                	cmp    %edx,%esi
  800dbd:	72 19                	jb     800dd8 <__udivdi3+0x108>
  800dbf:	89 f9                	mov    %edi,%ecx
  800dc1:	d3 e5                	shl    %cl,%ebp
  800dc3:	39 c5                	cmp    %eax,%ebp
  800dc5:	73 04                	jae    800dcb <__udivdi3+0xfb>
  800dc7:	39 d6                	cmp    %edx,%esi
  800dc9:	74 0d                	je     800dd8 <__udivdi3+0x108>
  800dcb:	89 d8                	mov    %ebx,%eax
  800dcd:	31 ff                	xor    %edi,%edi
  800dcf:	e9 3c ff ff ff       	jmp    800d10 <__udivdi3+0x40>
  800dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dd8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ddb:	31 ff                	xor    %edi,%edi
  800ddd:	e9 2e ff ff ff       	jmp    800d10 <__udivdi3+0x40>
  800de2:	66 90                	xchg   %ax,%ax
  800de4:	66 90                	xchg   %ax,%ax
  800de6:	66 90                	xchg   %ax,%ax
  800de8:	66 90                	xchg   %ax,%ax
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	66 90                	xchg   %ax,%ax
  800dee:	66 90                	xchg   %ax,%ax

00800df0 <__umoddi3>:
  800df0:	f3 0f 1e fb          	endbr32 
  800df4:	55                   	push   %ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 1c             	sub    $0x1c,%esp
  800dfb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e03:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e07:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e0b:	89 f0                	mov    %esi,%eax
  800e0d:	89 da                	mov    %ebx,%edx
  800e0f:	85 ff                	test   %edi,%edi
  800e11:	75 15                	jne    800e28 <__umoddi3+0x38>
  800e13:	39 dd                	cmp    %ebx,%ebp
  800e15:	76 39                	jbe    800e50 <__umoddi3+0x60>
  800e17:	f7 f5                	div    %ebp
  800e19:	89 d0                	mov    %edx,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	83 c4 1c             	add    $0x1c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	39 df                	cmp    %ebx,%edi
  800e2a:	77 f1                	ja     800e1d <__umoddi3+0x2d>
  800e2c:	0f bd cf             	bsr    %edi,%ecx
  800e2f:	83 f1 1f             	xor    $0x1f,%ecx
  800e32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e36:	75 40                	jne    800e78 <__umoddi3+0x88>
  800e38:	39 df                	cmp    %ebx,%edi
  800e3a:	72 04                	jb     800e40 <__umoddi3+0x50>
  800e3c:	39 f5                	cmp    %esi,%ebp
  800e3e:	77 dd                	ja     800e1d <__umoddi3+0x2d>
  800e40:	89 da                	mov    %ebx,%edx
  800e42:	89 f0                	mov    %esi,%eax
  800e44:	29 e8                	sub    %ebp,%eax
  800e46:	19 fa                	sbb    %edi,%edx
  800e48:	eb d3                	jmp    800e1d <__umoddi3+0x2d>
  800e4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e50:	89 e9                	mov    %ebp,%ecx
  800e52:	85 ed                	test   %ebp,%ebp
  800e54:	75 0b                	jne    800e61 <__umoddi3+0x71>
  800e56:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	f7 f5                	div    %ebp
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	89 d8                	mov    %ebx,%eax
  800e63:	31 d2                	xor    %edx,%edx
  800e65:	f7 f1                	div    %ecx
  800e67:	89 f0                	mov    %esi,%eax
  800e69:	f7 f1                	div    %ecx
  800e6b:	89 d0                	mov    %edx,%eax
  800e6d:	31 d2                	xor    %edx,%edx
  800e6f:	eb ac                	jmp    800e1d <__umoddi3+0x2d>
  800e71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e78:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e7c:	ba 20 00 00 00       	mov    $0x20,%edx
  800e81:	29 c2                	sub    %eax,%edx
  800e83:	89 c1                	mov    %eax,%ecx
  800e85:	89 e8                	mov    %ebp,%eax
  800e87:	d3 e7                	shl    %cl,%edi
  800e89:	89 d1                	mov    %edx,%ecx
  800e8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e8f:	d3 e8                	shr    %cl,%eax
  800e91:	89 c1                	mov    %eax,%ecx
  800e93:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e97:	09 f9                	or     %edi,%ecx
  800e99:	89 df                	mov    %ebx,%edi
  800e9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	d3 e5                	shl    %cl,%ebp
  800ea3:	89 d1                	mov    %edx,%ecx
  800ea5:	d3 ef                	shr    %cl,%edi
  800ea7:	89 c1                	mov    %eax,%ecx
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	d3 e3                	shl    %cl,%ebx
  800ead:	89 d1                	mov    %edx,%ecx
  800eaf:	89 fa                	mov    %edi,%edx
  800eb1:	d3 e8                	shr    %cl,%eax
  800eb3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eb8:	09 d8                	or     %ebx,%eax
  800eba:	f7 74 24 08          	divl   0x8(%esp)
  800ebe:	89 d3                	mov    %edx,%ebx
  800ec0:	d3 e6                	shl    %cl,%esi
  800ec2:	f7 e5                	mul    %ebp
  800ec4:	89 c7                	mov    %eax,%edi
  800ec6:	89 d1                	mov    %edx,%ecx
  800ec8:	39 d3                	cmp    %edx,%ebx
  800eca:	72 06                	jb     800ed2 <__umoddi3+0xe2>
  800ecc:	75 0e                	jne    800edc <__umoddi3+0xec>
  800ece:	39 c6                	cmp    %eax,%esi
  800ed0:	73 0a                	jae    800edc <__umoddi3+0xec>
  800ed2:	29 e8                	sub    %ebp,%eax
  800ed4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ed8:	89 d1                	mov    %edx,%ecx
  800eda:	89 c7                	mov    %eax,%edi
  800edc:	89 f5                	mov    %esi,%ebp
  800ede:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ee2:	29 fd                	sub    %edi,%ebp
  800ee4:	19 cb                	sbb    %ecx,%ebx
  800ee6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800eeb:	89 d8                	mov    %ebx,%eax
  800eed:	d3 e0                	shl    %cl,%eax
  800eef:	89 f1                	mov    %esi,%ecx
  800ef1:	d3 ed                	shr    %cl,%ebp
  800ef3:	d3 eb                	shr    %cl,%ebx
  800ef5:	09 e8                	or     %ebp,%eax
  800ef7:	89 da                	mov    %ebx,%edx
  800ef9:	83 c4 1c             	add    $0x1c,%esp
  800efc:	5b                   	pop    %ebx
  800efd:	5e                   	pop    %esi
  800efe:	5f                   	pop    %edi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    
