
obj/user/icode.debug：     文件格式 elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 40 	movl   $0x802940,0x803000
  800045:	29 80 00 

	cprintf("icode startup\n");
  800048:	68 46 29 80 00       	push   $0x802946
  80004d:	e8 20 02 00 00       	call   800272 <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 55 29 80 00 	movl   $0x802955,(%esp)
  800059:	e8 14 02 00 00       	call   800272 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 68 29 80 00       	push   $0x802968
  800068:	e8 70 15 00 00       	call   8015dd <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	78 18                	js     80008e <umain+0x5b>
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
  800076:	83 ec 0c             	sub    $0xc,%esp
  800079:	68 91 29 80 00       	push   $0x802991
  80007e:	e8 ef 01 00 00       	call   800272 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80008c:	eb 1f                	jmp    8000ad <umain+0x7a>
		panic("icode: open /motd: %e", fd);
  80008e:	50                   	push   %eax
  80008f:	68 6e 29 80 00       	push   $0x80296e
  800094:	6a 0f                	push   $0xf
  800096:	68 84 29 80 00       	push   $0x802984
  80009b:	e8 f7 00 00 00       	call   800197 <_panic>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 e2 0a 00 00       	call   800b8c <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 be 10 00 00       	call   80117a <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 a4 29 80 00       	push   $0x8029a4
  8000cb:	e8 a2 01 00 00       	call   800272 <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 66 0f 00 00       	call   80103e <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  8000df:	e8 8e 01 00 00       	call   800272 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 cc 29 80 00       	push   $0x8029cc
  8000f0:	68 d5 29 80 00       	push   $0x8029d5
  8000f5:	68 df 29 80 00       	push   $0x8029df
  8000fa:	68 de 29 80 00       	push   $0x8029de
  8000ff:	e8 ee 1a 00 00       	call   801bf2 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	78 17                	js     800122 <umain+0xef>
		panic("icode: spawn /init: %e", r);

	cprintf("icode: exiting\n");
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	68 fb 29 80 00       	push   $0x8029fb
  800113:	e8 5a 01 00 00       	call   800272 <cprintf>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    
		panic("icode: spawn /init: %e", r);
  800122:	50                   	push   %eax
  800123:	68 e4 29 80 00       	push   $0x8029e4
  800128:	6a 1a                	push   $0x1a
  80012a:	68 84 29 80 00       	push   $0x802984
  80012f:	e8 63 00 00 00       	call   800197 <_panic>

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 c6 0a 00 00       	call   800c0a <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80014f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800154:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800159:	85 db                	test   %ebx,%ebx
  80015b:	7e 07                	jle    800164 <libmain+0x30>
		binaryname = argv[0];
  80015d:	8b 06                	mov    (%esi),%eax
  80015f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800164:	83 ec 08             	sub    $0x8,%esp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	e8 c5 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016e:	e8 0a 00 00 00       	call   80017d <exit>
}
  800173:	83 c4 10             	add    $0x10,%esp
  800176:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800183:	e8 e3 0e 00 00       	call   80106b <close_all>
	sys_env_destroy(0);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	6a 00                	push   $0x0
  80018d:	e8 37 0a 00 00       	call   800bc9 <sys_env_destroy>
}
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	56                   	push   %esi
  80019b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80019c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a5:	e8 60 0a 00 00       	call   800c0a <sys_getenvid>
  8001aa:	83 ec 0c             	sub    $0xc,%esp
  8001ad:	ff 75 0c             	push   0xc(%ebp)
  8001b0:	ff 75 08             	push   0x8(%ebp)
  8001b3:	56                   	push   %esi
  8001b4:	50                   	push   %eax
  8001b5:	68 18 2a 80 00       	push   $0x802a18
  8001ba:	e8 b3 00 00 00       	call   800272 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bf:	83 c4 18             	add    $0x18,%esp
  8001c2:	53                   	push   %ebx
  8001c3:	ff 75 10             	push   0x10(%ebp)
  8001c6:	e8 56 00 00 00       	call   800221 <vcprintf>
	cprintf("\n");
  8001cb:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
  8001d2:	e8 9b 00 00 00       	call   800272 <cprintf>
  8001d7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001da:	cc                   	int3   
  8001db:	eb fd                	jmp    8001da <_panic+0x43>

008001dd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 04             	sub    $0x4,%esp
  8001e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e7:	8b 13                	mov    (%ebx),%edx
  8001e9:	8d 42 01             	lea    0x1(%edx),%eax
  8001ec:	89 03                	mov    %eax,(%ebx)
  8001ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fa:	74 09                	je     800205 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800200:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800203:	c9                   	leave  
  800204:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	68 ff 00 00 00       	push   $0xff
  80020d:	8d 43 08             	lea    0x8(%ebx),%eax
  800210:	50                   	push   %eax
  800211:	e8 76 09 00 00       	call   800b8c <sys_cputs>
		b->idx = 0;
  800216:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	eb db                	jmp    8001fc <putch+0x1f>

00800221 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80022a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800231:	00 00 00 
	b.cnt = 0;
  800234:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023e:	ff 75 0c             	push   0xc(%ebp)
  800241:	ff 75 08             	push   0x8(%ebp)
  800244:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024a:	50                   	push   %eax
  80024b:	68 dd 01 80 00       	push   $0x8001dd
  800250:	e8 14 01 00 00       	call   800369 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800255:	83 c4 08             	add    $0x8,%esp
  800258:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80025e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	e8 22 09 00 00       	call   800b8c <sys_cputs>

	return b.cnt;
}
  80026a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800278:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80027b:	50                   	push   %eax
  80027c:	ff 75 08             	push   0x8(%ebp)
  80027f:	e8 9d ff ff ff       	call   800221 <vcprintf>
	va_end(ap);

	return cnt;
}
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	57                   	push   %edi
  80028a:	56                   	push   %esi
  80028b:	53                   	push   %ebx
  80028c:	83 ec 1c             	sub    $0x1c,%esp
  80028f:	89 c7                	mov    %eax,%edi
  800291:	89 d6                	mov    %edx,%esi
  800293:	8b 45 08             	mov    0x8(%ebp),%eax
  800296:	8b 55 0c             	mov    0xc(%ebp),%edx
  800299:	89 d1                	mov    %edx,%ecx
  80029b:	89 c2                	mov    %eax,%edx
  80029d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b3:	39 c2                	cmp    %eax,%edx
  8002b5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b8:	72 3e                	jb     8002f8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ba:	83 ec 0c             	sub    $0xc,%esp
  8002bd:	ff 75 18             	push   0x18(%ebp)
  8002c0:	83 eb 01             	sub    $0x1,%ebx
  8002c3:	53                   	push   %ebx
  8002c4:	50                   	push   %eax
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	ff 75 e4             	push   -0x1c(%ebp)
  8002cb:	ff 75 e0             	push   -0x20(%ebp)
  8002ce:	ff 75 dc             	push   -0x24(%ebp)
  8002d1:	ff 75 d8             	push   -0x28(%ebp)
  8002d4:	e8 27 24 00 00       	call   802700 <__udivdi3>
  8002d9:	83 c4 18             	add    $0x18,%esp
  8002dc:	52                   	push   %edx
  8002dd:	50                   	push   %eax
  8002de:	89 f2                	mov    %esi,%edx
  8002e0:	89 f8                	mov    %edi,%eax
  8002e2:	e8 9f ff ff ff       	call   800286 <printnum>
  8002e7:	83 c4 20             	add    $0x20,%esp
  8002ea:	eb 13                	jmp    8002ff <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ec:	83 ec 08             	sub    $0x8,%esp
  8002ef:	56                   	push   %esi
  8002f0:	ff 75 18             	push   0x18(%ebp)
  8002f3:	ff d7                	call   *%edi
  8002f5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f ed                	jg     8002ec <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	push   -0x1c(%ebp)
  800309:	ff 75 e0             	push   -0x20(%ebp)
  80030c:	ff 75 dc             	push   -0x24(%ebp)
  80030f:	ff 75 d8             	push   -0x28(%ebp)
  800312:	e8 09 25 00 00       	call   802820 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 3b 2a 80 00 	movsbl 0x802a3b(%eax),%eax
  800321:	50                   	push   %eax
  800322:	ff d7                	call   *%edi
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800335:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	3b 50 04             	cmp    0x4(%eax),%edx
  80033e:	73 0a                	jae    80034a <sprintputch+0x1b>
		*b->buf++ = ch;
  800340:	8d 4a 01             	lea    0x1(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	88 02                	mov    %al,(%edx)
}
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <printfmt>:
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800352:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800355:	50                   	push   %eax
  800356:	ff 75 10             	push   0x10(%ebp)
  800359:	ff 75 0c             	push   0xc(%ebp)
  80035c:	ff 75 08             	push   0x8(%ebp)
  80035f:	e8 05 00 00 00       	call   800369 <vprintfmt>
}
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <vprintfmt>:
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	57                   	push   %edi
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
  80036f:	83 ec 3c             	sub    $0x3c,%esp
  800372:	8b 75 08             	mov    0x8(%ebp),%esi
  800375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800378:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037b:	eb 0a                	jmp    800387 <vprintfmt+0x1e>
			putch(ch, putdat);
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	53                   	push   %ebx
  800381:	50                   	push   %eax
  800382:	ff d6                	call   *%esi
  800384:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800387:	83 c7 01             	add    $0x1,%edi
  80038a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038e:	83 f8 25             	cmp    $0x25,%eax
  800391:	74 0c                	je     80039f <vprintfmt+0x36>
			if (ch == '\0')
  800393:	85 c0                	test   %eax,%eax
  800395:	75 e6                	jne    80037d <vprintfmt+0x14>
}
  800397:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039a:	5b                   	pop    %ebx
  80039b:	5e                   	pop    %esi
  80039c:	5f                   	pop    %edi
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    
		padc = ' ';
  80039f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003a3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003aa:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003b1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8d 47 01             	lea    0x1(%edi),%eax
  8003c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c3:	0f b6 17             	movzbl (%edi),%edx
  8003c6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003c9:	3c 55                	cmp    $0x55,%al
  8003cb:	0f 87 bb 03 00 00    	ja     80078c <vprintfmt+0x423>
  8003d1:	0f b6 c0             	movzbl %al,%eax
  8003d4:	ff 24 85 80 2b 80 00 	jmp    *0x802b80(,%eax,4)
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003de:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003e2:	eb d9                	jmp    8003bd <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003eb:	eb d0                	jmp    8003bd <vprintfmt+0x54>
  8003ed:	0f b6 d2             	movzbl %dl,%edx
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fe:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800402:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800405:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800408:	83 f9 09             	cmp    $0x9,%ecx
  80040b:	77 55                	ja     800462 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80040d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800410:	eb e9                	jmp    8003fb <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8b 00                	mov    (%eax),%eax
  800417:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 40 04             	lea    0x4(%eax),%eax
  800420:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800426:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042a:	79 91                	jns    8003bd <vprintfmt+0x54>
				width = precision, precision = -1;
  80042c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80042f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800432:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800439:	eb 82                	jmp    8003bd <vprintfmt+0x54>
  80043b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80043e:	85 d2                	test   %edx,%edx
  800440:	b8 00 00 00 00       	mov    $0x0,%eax
  800445:	0f 49 c2             	cmovns %edx,%eax
  800448:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80044e:	e9 6a ff ff ff       	jmp    8003bd <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800456:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80045d:	e9 5b ff ff ff       	jmp    8003bd <vprintfmt+0x54>
  800462:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800465:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800468:	eb bc                	jmp    800426 <vprintfmt+0xbd>
			lflag++;
  80046a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800470:	e9 48 ff ff ff       	jmp    8003bd <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 78 04             	lea    0x4(%eax),%edi
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	53                   	push   %ebx
  80047f:	ff 30                	push   (%eax)
  800481:	ff d6                	call   *%esi
			break;
  800483:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800486:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800489:	e9 9d 02 00 00       	jmp    80072b <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8d 78 04             	lea    0x4(%eax),%edi
  800494:	8b 10                	mov    (%eax),%edx
  800496:	89 d0                	mov    %edx,%eax
  800498:	f7 d8                	neg    %eax
  80049a:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049d:	83 f8 0f             	cmp    $0xf,%eax
  8004a0:	7f 23                	jg     8004c5 <vprintfmt+0x15c>
  8004a2:	8b 14 85 e0 2c 80 00 	mov    0x802ce0(,%eax,4),%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	74 18                	je     8004c5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004ad:	52                   	push   %edx
  8004ae:	68 15 2e 80 00       	push   $0x802e15
  8004b3:	53                   	push   %ebx
  8004b4:	56                   	push   %esi
  8004b5:	e8 92 fe ff ff       	call   80034c <printfmt>
  8004ba:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004bd:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c0:	e9 66 02 00 00       	jmp    80072b <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004c5:	50                   	push   %eax
  8004c6:	68 53 2a 80 00       	push   $0x802a53
  8004cb:	53                   	push   %ebx
  8004cc:	56                   	push   %esi
  8004cd:	e8 7a fe ff ff       	call   80034c <printfmt>
  8004d2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004d5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004d8:	e9 4e 02 00 00       	jmp    80072b <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	83 c0 04             	add    $0x4,%eax
  8004e3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004eb:	85 d2                	test   %edx,%edx
  8004ed:	b8 4c 2a 80 00       	mov    $0x802a4c,%eax
  8004f2:	0f 45 c2             	cmovne %edx,%eax
  8004f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fc:	7e 06                	jle    800504 <vprintfmt+0x19b>
  8004fe:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800502:	75 0d                	jne    800511 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800504:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800507:	89 c7                	mov    %eax,%edi
  800509:	03 45 e0             	add    -0x20(%ebp),%eax
  80050c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050f:	eb 55                	jmp    800566 <vprintfmt+0x1fd>
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	ff 75 d8             	push   -0x28(%ebp)
  800517:	ff 75 cc             	push   -0x34(%ebp)
  80051a:	e8 0a 03 00 00       	call   800829 <strnlen>
  80051f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800522:	29 c1                	sub    %eax,%ecx
  800524:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80052c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800530:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	eb 0f                	jmp    800544 <vprintfmt+0x1db>
					putch(padc, putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	ff 75 e0             	push   -0x20(%ebp)
  80053c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80053e:	83 ef 01             	sub    $0x1,%edi
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	85 ff                	test   %edi,%edi
  800546:	7f ed                	jg     800535 <vprintfmt+0x1cc>
  800548:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80054b:	85 d2                	test   %edx,%edx
  80054d:	b8 00 00 00 00       	mov    $0x0,%eax
  800552:	0f 49 c2             	cmovns %edx,%eax
  800555:	29 c2                	sub    %eax,%edx
  800557:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80055a:	eb a8                	jmp    800504 <vprintfmt+0x19b>
					putch(ch, putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	52                   	push   %edx
  800561:	ff d6                	call   *%esi
  800563:	83 c4 10             	add    $0x10,%esp
  800566:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800569:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056b:	83 c7 01             	add    $0x1,%edi
  80056e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800572:	0f be d0             	movsbl %al,%edx
  800575:	85 d2                	test   %edx,%edx
  800577:	74 4b                	je     8005c4 <vprintfmt+0x25b>
  800579:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80057d:	78 06                	js     800585 <vprintfmt+0x21c>
  80057f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800583:	78 1e                	js     8005a3 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800585:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800589:	74 d1                	je     80055c <vprintfmt+0x1f3>
  80058b:	0f be c0             	movsbl %al,%eax
  80058e:	83 e8 20             	sub    $0x20,%eax
  800591:	83 f8 5e             	cmp    $0x5e,%eax
  800594:	76 c6                	jbe    80055c <vprintfmt+0x1f3>
					putch('?', putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	53                   	push   %ebx
  80059a:	6a 3f                	push   $0x3f
  80059c:	ff d6                	call   *%esi
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	eb c3                	jmp    800566 <vprintfmt+0x1fd>
  8005a3:	89 cf                	mov    %ecx,%edi
  8005a5:	eb 0e                	jmp    8005b5 <vprintfmt+0x24c>
				putch(' ', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	53                   	push   %ebx
  8005ab:	6a 20                	push   $0x20
  8005ad:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005af:	83 ef 01             	sub    $0x1,%edi
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	85 ff                	test   %edi,%edi
  8005b7:	7f ee                	jg     8005a7 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005b9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bf:	e9 67 01 00 00       	jmp    80072b <vprintfmt+0x3c2>
  8005c4:	89 cf                	mov    %ecx,%edi
  8005c6:	eb ed                	jmp    8005b5 <vprintfmt+0x24c>
	if (lflag >= 2)
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	7f 1b                	jg     8005e8 <vprintfmt+0x27f>
	else if (lflag)
  8005cd:	85 c9                	test   %ecx,%ecx
  8005cf:	74 63                	je     800634 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	99                   	cltd   
  8005da:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e6:	eb 17                	jmp    8005ff <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 50 04             	mov    0x4(%eax),%edx
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 40 08             	lea    0x8(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800602:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800605:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80060a:	85 c9                	test   %ecx,%ecx
  80060c:	0f 89 ff 00 00 00    	jns    800711 <vprintfmt+0x3a8>
				putch('-', putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 2d                	push   $0x2d
  800618:	ff d6                	call   *%esi
				num = -(long long) num;
  80061a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800620:	f7 da                	neg    %edx
  800622:	83 d1 00             	adc    $0x0,%ecx
  800625:	f7 d9                	neg    %ecx
  800627:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80062a:	bf 0a 00 00 00       	mov    $0xa,%edi
  80062f:	e9 dd 00 00 00       	jmp    800711 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 00                	mov    (%eax),%eax
  800639:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063c:	99                   	cltd   
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 40 04             	lea    0x4(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
  800649:	eb b4                	jmp    8005ff <vprintfmt+0x296>
	if (lflag >= 2)
  80064b:	83 f9 01             	cmp    $0x1,%ecx
  80064e:	7f 1e                	jg     80066e <vprintfmt+0x305>
	else if (lflag)
  800650:	85 c9                	test   %ecx,%ecx
  800652:	74 32                	je     800686 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 10                	mov    (%eax),%edx
  800659:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065e:	8d 40 04             	lea    0x4(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800664:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800669:	e9 a3 00 00 00       	jmp    800711 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8b 10                	mov    (%eax),%edx
  800673:	8b 48 04             	mov    0x4(%eax),%ecx
  800676:	8d 40 08             	lea    0x8(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80067c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800681:	e9 8b 00 00 00       	jmp    800711 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8b 10                	mov    (%eax),%edx
  80068b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800696:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80069b:	eb 74                	jmp    800711 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80069d:	83 f9 01             	cmp    $0x1,%ecx
  8006a0:	7f 1b                	jg     8006bd <vprintfmt+0x354>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	74 2c                	je     8006d2 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b0:	8d 40 04             	lea    0x4(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006b6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8006bb:	eb 54                	jmp    800711 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c5:	8d 40 08             	lea    0x8(%eax),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006cb:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8006d0:	eb 3f                	jmp    800711 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 10                	mov    (%eax),%edx
  8006d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dc:	8d 40 04             	lea    0x4(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006e2:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8006e7:	eb 28                	jmp    800711 <vprintfmt+0x3a8>
			putch('0', putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	53                   	push   %ebx
  8006ed:	6a 30                	push   $0x30
  8006ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f1:	83 c4 08             	add    $0x8,%esp
  8006f4:	53                   	push   %ebx
  8006f5:	6a 78                	push   $0x78
  8006f7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 10                	mov    (%eax),%edx
  8006fe:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800703:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800706:	8d 40 04             	lea    0x4(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070c:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800718:	50                   	push   %eax
  800719:	ff 75 e0             	push   -0x20(%ebp)
  80071c:	57                   	push   %edi
  80071d:	51                   	push   %ecx
  80071e:	52                   	push   %edx
  80071f:	89 da                	mov    %ebx,%edx
  800721:	89 f0                	mov    %esi,%eax
  800723:	e8 5e fb ff ff       	call   800286 <printnum>
			break;
  800728:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80072b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80072e:	e9 54 fc ff ff       	jmp    800387 <vprintfmt+0x1e>
	if (lflag >= 2)
  800733:	83 f9 01             	cmp    $0x1,%ecx
  800736:	7f 1b                	jg     800753 <vprintfmt+0x3ea>
	else if (lflag)
  800738:	85 c9                	test   %ecx,%ecx
  80073a:	74 2c                	je     800768 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 10                	mov    (%eax),%edx
  800741:	b9 00 00 00 00       	mov    $0x0,%ecx
  800746:	8d 40 04             	lea    0x4(%eax),%eax
  800749:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800751:	eb be                	jmp    800711 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8b 10                	mov    (%eax),%edx
  800758:	8b 48 04             	mov    0x4(%eax),%ecx
  80075b:	8d 40 08             	lea    0x8(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800761:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800766:	eb a9                	jmp    800711 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 10                	mov    (%eax),%edx
  80076d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800772:	8d 40 04             	lea    0x4(%eax),%eax
  800775:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800778:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80077d:	eb 92                	jmp    800711 <vprintfmt+0x3a8>
			putch(ch, putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 25                	push   $0x25
  800785:	ff d6                	call   *%esi
			break;
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	eb 9f                	jmp    80072b <vprintfmt+0x3c2>
			putch('%', putdat);
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	6a 25                	push   $0x25
  800792:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	89 f8                	mov    %edi,%eax
  800799:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80079d:	74 05                	je     8007a4 <vprintfmt+0x43b>
  80079f:	83 e8 01             	sub    $0x1,%eax
  8007a2:	eb f5                	jmp    800799 <vprintfmt+0x430>
  8007a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a7:	eb 82                	jmp    80072b <vprintfmt+0x3c2>

008007a9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 18             	sub    $0x18,%esp
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	74 26                	je     8007f0 <vsnprintf+0x47>
  8007ca:	85 d2                	test   %edx,%edx
  8007cc:	7e 22                	jle    8007f0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ce:	ff 75 14             	push   0x14(%ebp)
  8007d1:	ff 75 10             	push   0x10(%ebp)
  8007d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d7:	50                   	push   %eax
  8007d8:	68 2f 03 80 00       	push   $0x80032f
  8007dd:	e8 87 fb ff ff       	call   800369 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007eb:	83 c4 10             	add    $0x10,%esp
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    
		return -E_INVAL;
  8007f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f5:	eb f7                	jmp    8007ee <vsnprintf+0x45>

008007f7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800800:	50                   	push   %eax
  800801:	ff 75 10             	push   0x10(%ebp)
  800804:	ff 75 0c             	push   0xc(%ebp)
  800807:	ff 75 08             	push   0x8(%ebp)
  80080a:	e8 9a ff ff ff       	call   8007a9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80080f:	c9                   	leave  
  800810:	c3                   	ret    

00800811 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
  80081c:	eb 03                	jmp    800821 <strlen+0x10>
		n++;
  80081e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800821:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800825:	75 f7                	jne    80081e <strlen+0xd>
	return n;
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
  800837:	eb 03                	jmp    80083c <strnlen+0x13>
		n++;
  800839:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083c:	39 d0                	cmp    %edx,%eax
  80083e:	74 08                	je     800848 <strnlen+0x1f>
  800840:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800844:	75 f3                	jne    800839 <strnlen+0x10>
  800846:	89 c2                	mov    %eax,%edx
	return n;
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	53                   	push   %ebx
  800850:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800853:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80085f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800862:	83 c0 01             	add    $0x1,%eax
  800865:	84 d2                	test   %dl,%dl
  800867:	75 f2                	jne    80085b <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800869:	89 c8                	mov    %ecx,%eax
  80086b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086e:	c9                   	leave  
  80086f:	c3                   	ret    

00800870 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	53                   	push   %ebx
  800874:	83 ec 10             	sub    $0x10,%esp
  800877:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087a:	53                   	push   %ebx
  80087b:	e8 91 ff ff ff       	call   800811 <strlen>
  800880:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800883:	ff 75 0c             	push   0xc(%ebp)
  800886:	01 d8                	add    %ebx,%eax
  800888:	50                   	push   %eax
  800889:	e8 be ff ff ff       	call   80084c <strcpy>
	return dst;
}
  80088e:	89 d8                	mov    %ebx,%eax
  800890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	8b 75 08             	mov    0x8(%ebp),%esi
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a0:	89 f3                	mov    %esi,%ebx
  8008a2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a5:	89 f0                	mov    %esi,%eax
  8008a7:	eb 0f                	jmp    8008b8 <strncpy+0x23>
		*dst++ = *src;
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	0f b6 0a             	movzbl (%edx),%ecx
  8008af:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b2:	80 f9 01             	cmp    $0x1,%cl
  8008b5:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008b8:	39 d8                	cmp    %ebx,%eax
  8008ba:	75 ed                	jne    8008a9 <strncpy+0x14>
	}
	return ret;
}
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d2:	85 d2                	test   %edx,%edx
  8008d4:	74 21                	je     8008f7 <strlcpy+0x35>
  8008d6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008da:	89 f2                	mov    %esi,%edx
  8008dc:	eb 09                	jmp    8008e7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008de:	83 c1 01             	add    $0x1,%ecx
  8008e1:	83 c2 01             	add    $0x1,%edx
  8008e4:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8008e7:	39 c2                	cmp    %eax,%edx
  8008e9:	74 09                	je     8008f4 <strlcpy+0x32>
  8008eb:	0f b6 19             	movzbl (%ecx),%ebx
  8008ee:	84 db                	test   %bl,%bl
  8008f0:	75 ec                	jne    8008de <strlcpy+0x1c>
  8008f2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008f4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f7:	29 f0                	sub    %esi,%eax
}
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800903:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800906:	eb 06                	jmp    80090e <strcmp+0x11>
		p++, q++;
  800908:	83 c1 01             	add    $0x1,%ecx
  80090b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80090e:	0f b6 01             	movzbl (%ecx),%eax
  800911:	84 c0                	test   %al,%al
  800913:	74 04                	je     800919 <strcmp+0x1c>
  800915:	3a 02                	cmp    (%edx),%al
  800917:	74 ef                	je     800908 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800919:	0f b6 c0             	movzbl %al,%eax
  80091c:	0f b6 12             	movzbl (%edx),%edx
  80091f:	29 d0                	sub    %edx,%eax
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092d:	89 c3                	mov    %eax,%ebx
  80092f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800932:	eb 06                	jmp    80093a <strncmp+0x17>
		n--, p++, q++;
  800934:	83 c0 01             	add    $0x1,%eax
  800937:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80093a:	39 d8                	cmp    %ebx,%eax
  80093c:	74 18                	je     800956 <strncmp+0x33>
  80093e:	0f b6 08             	movzbl (%eax),%ecx
  800941:	84 c9                	test   %cl,%cl
  800943:	74 04                	je     800949 <strncmp+0x26>
  800945:	3a 0a                	cmp    (%edx),%cl
  800947:	74 eb                	je     800934 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800949:	0f b6 00             	movzbl (%eax),%eax
  80094c:	0f b6 12             	movzbl (%edx),%edx
  80094f:	29 d0                	sub    %edx,%eax
}
  800951:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800954:	c9                   	leave  
  800955:	c3                   	ret    
		return 0;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	eb f4                	jmp    800951 <strncmp+0x2e>

0080095d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800967:	eb 03                	jmp    80096c <strchr+0xf>
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	0f b6 10             	movzbl (%eax),%edx
  80096f:	84 d2                	test   %dl,%dl
  800971:	74 06                	je     800979 <strchr+0x1c>
		if (*s == c)
  800973:	38 ca                	cmp    %cl,%dl
  800975:	75 f2                	jne    800969 <strchr+0xc>
  800977:	eb 05                	jmp    80097e <strchr+0x21>
			return (char *) s;
	return 0;
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098d:	38 ca                	cmp    %cl,%dl
  80098f:	74 09                	je     80099a <strfind+0x1a>
  800991:	84 d2                	test   %dl,%dl
  800993:	74 05                	je     80099a <strfind+0x1a>
	for (; *s; s++)
  800995:	83 c0 01             	add    $0x1,%eax
  800998:	eb f0                	jmp    80098a <strfind+0xa>
			break;
	return (char *) s;
}
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a8:	85 c9                	test   %ecx,%ecx
  8009aa:	74 2f                	je     8009db <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ac:	89 f8                	mov    %edi,%eax
  8009ae:	09 c8                	or     %ecx,%eax
  8009b0:	a8 03                	test   $0x3,%al
  8009b2:	75 21                	jne    8009d5 <memset+0x39>
		c &= 0xFF;
  8009b4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b8:	89 d0                	mov    %edx,%eax
  8009ba:	c1 e0 08             	shl    $0x8,%eax
  8009bd:	89 d3                	mov    %edx,%ebx
  8009bf:	c1 e3 18             	shl    $0x18,%ebx
  8009c2:	89 d6                	mov    %edx,%esi
  8009c4:	c1 e6 10             	shl    $0x10,%esi
  8009c7:	09 f3                	or     %esi,%ebx
  8009c9:	09 da                	or     %ebx,%edx
  8009cb:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009cd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d0:	fc                   	cld    
  8009d1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d3:	eb 06                	jmp    8009db <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d8:	fc                   	cld    
  8009d9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009db:	89 f8                	mov    %edi,%eax
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5f                   	pop    %edi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f0:	39 c6                	cmp    %eax,%esi
  8009f2:	73 32                	jae    800a26 <memmove+0x44>
  8009f4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f7:	39 c2                	cmp    %eax,%edx
  8009f9:	76 2b                	jbe    800a26 <memmove+0x44>
		s += n;
		d += n;
  8009fb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fe:	89 d6                	mov    %edx,%esi
  800a00:	09 fe                	or     %edi,%esi
  800a02:	09 ce                	or     %ecx,%esi
  800a04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0a:	75 0e                	jne    800a1a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a0c:	83 ef 04             	sub    $0x4,%edi
  800a0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a12:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a15:	fd                   	std    
  800a16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a18:	eb 09                	jmp    800a23 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1a:	83 ef 01             	sub    $0x1,%edi
  800a1d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a20:	fd                   	std    
  800a21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a23:	fc                   	cld    
  800a24:	eb 1a                	jmp    800a40 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a26:	89 f2                	mov    %esi,%edx
  800a28:	09 c2                	or     %eax,%edx
  800a2a:	09 ca                	or     %ecx,%edx
  800a2c:	f6 c2 03             	test   $0x3,%dl
  800a2f:	75 0a                	jne    800a3b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a31:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a34:	89 c7                	mov    %eax,%edi
  800a36:	fc                   	cld    
  800a37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a39:	eb 05                	jmp    800a40 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a3b:	89 c7                	mov    %eax,%edi
  800a3d:	fc                   	cld    
  800a3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a40:	5e                   	pop    %esi
  800a41:	5f                   	pop    %edi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a4a:	ff 75 10             	push   0x10(%ebp)
  800a4d:	ff 75 0c             	push   0xc(%ebp)
  800a50:	ff 75 08             	push   0x8(%ebp)
  800a53:	e8 8a ff ff ff       	call   8009e2 <memmove>
}
  800a58:	c9                   	leave  
  800a59:	c3                   	ret    

00800a5a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 c6                	mov    %eax,%esi
  800a67:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6a:	eb 06                	jmp    800a72 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a72:	39 f0                	cmp    %esi,%eax
  800a74:	74 14                	je     800a8a <memcmp+0x30>
		if (*s1 != *s2)
  800a76:	0f b6 08             	movzbl (%eax),%ecx
  800a79:	0f b6 1a             	movzbl (%edx),%ebx
  800a7c:	38 d9                	cmp    %bl,%cl
  800a7e:	74 ec                	je     800a6c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a80:	0f b6 c1             	movzbl %cl,%eax
  800a83:	0f b6 db             	movzbl %bl,%ebx
  800a86:	29 d8                	sub    %ebx,%eax
  800a88:	eb 05                	jmp    800a8f <memcmp+0x35>
	}

	return 0;
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9c:	89 c2                	mov    %eax,%edx
  800a9e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa1:	eb 03                	jmp    800aa6 <memfind+0x13>
  800aa3:	83 c0 01             	add    $0x1,%eax
  800aa6:	39 d0                	cmp    %edx,%eax
  800aa8:	73 04                	jae    800aae <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aaa:	38 08                	cmp    %cl,(%eax)
  800aac:	75 f5                	jne    800aa3 <memfind+0x10>
			break;
	return (void *) s;
}
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abc:	eb 03                	jmp    800ac1 <strtol+0x11>
		s++;
  800abe:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800ac1:	0f b6 02             	movzbl (%edx),%eax
  800ac4:	3c 20                	cmp    $0x20,%al
  800ac6:	74 f6                	je     800abe <strtol+0xe>
  800ac8:	3c 09                	cmp    $0x9,%al
  800aca:	74 f2                	je     800abe <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800acc:	3c 2b                	cmp    $0x2b,%al
  800ace:	74 2a                	je     800afa <strtol+0x4a>
	int neg = 0;
  800ad0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad5:	3c 2d                	cmp    $0x2d,%al
  800ad7:	74 2b                	je     800b04 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800adf:	75 0f                	jne    800af0 <strtol+0x40>
  800ae1:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae4:	74 28                	je     800b0e <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae6:	85 db                	test   %ebx,%ebx
  800ae8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aed:	0f 44 d8             	cmove  %eax,%ebx
  800af0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800af8:	eb 46                	jmp    800b40 <strtol+0x90>
		s++;
  800afa:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800afd:	bf 00 00 00 00       	mov    $0x0,%edi
  800b02:	eb d5                	jmp    800ad9 <strtol+0x29>
		s++, neg = 1;
  800b04:	83 c2 01             	add    $0x1,%edx
  800b07:	bf 01 00 00 00       	mov    $0x1,%edi
  800b0c:	eb cb                	jmp    800ad9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b12:	74 0e                	je     800b22 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b14:	85 db                	test   %ebx,%ebx
  800b16:	75 d8                	jne    800af0 <strtol+0x40>
		s++, base = 8;
  800b18:	83 c2 01             	add    $0x1,%edx
  800b1b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b20:	eb ce                	jmp    800af0 <strtol+0x40>
		s += 2, base = 16;
  800b22:	83 c2 02             	add    $0x2,%edx
  800b25:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2a:	eb c4                	jmp    800af0 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b2c:	0f be c0             	movsbl %al,%eax
  800b2f:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b32:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b35:	7d 3a                	jge    800b71 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b37:	83 c2 01             	add    $0x1,%edx
  800b3a:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b3e:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b40:	0f b6 02             	movzbl (%edx),%eax
  800b43:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b46:	89 f3                	mov    %esi,%ebx
  800b48:	80 fb 09             	cmp    $0x9,%bl
  800b4b:	76 df                	jbe    800b2c <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b4d:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b50:	89 f3                	mov    %esi,%ebx
  800b52:	80 fb 19             	cmp    $0x19,%bl
  800b55:	77 08                	ja     800b5f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b57:	0f be c0             	movsbl %al,%eax
  800b5a:	83 e8 57             	sub    $0x57,%eax
  800b5d:	eb d3                	jmp    800b32 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b5f:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b62:	89 f3                	mov    %esi,%ebx
  800b64:	80 fb 19             	cmp    $0x19,%bl
  800b67:	77 08                	ja     800b71 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b69:	0f be c0             	movsbl %al,%eax
  800b6c:	83 e8 37             	sub    $0x37,%eax
  800b6f:	eb c1                	jmp    800b32 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b75:	74 05                	je     800b7c <strtol+0xcc>
		*endptr = (char *) s;
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b7c:	89 c8                	mov    %ecx,%eax
  800b7e:	f7 d8                	neg    %eax
  800b80:	85 ff                	test   %edi,%edi
  800b82:	0f 45 c8             	cmovne %eax,%ecx
}
  800b85:	89 c8                	mov    %ecx,%eax
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9d:	89 c3                	mov    %eax,%ebx
  800b9f:	89 c7                	mov    %eax,%edi
  800ba1:	89 c6                	mov    %eax,%esi
  800ba3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_cgetc>:

int
sys_cgetc(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	b8 03 00 00 00       	mov    $0x3,%eax
  800bdf:	89 cb                	mov    %ecx,%ebx
  800be1:	89 cf                	mov    %ecx,%edi
  800be3:	89 ce                	mov    %ecx,%esi
  800be5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7f 08                	jg     800bf3 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	50                   	push   %eax
  800bf7:	6a 03                	push   $0x3
  800bf9:	68 3f 2d 80 00       	push   $0x802d3f
  800bfe:	6a 2a                	push   $0x2a
  800c00:	68 5c 2d 80 00       	push   $0x802d5c
  800c05:	e8 8d f5 ff ff       	call   800197 <_panic>

00800c0a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c10:	ba 00 00 00 00       	mov    $0x0,%edx
  800c15:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1a:	89 d1                	mov    %edx,%ecx
  800c1c:	89 d3                	mov    %edx,%ebx
  800c1e:	89 d7                	mov    %edx,%edi
  800c20:	89 d6                	mov    %edx,%esi
  800c22:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <sys_yield>:

void
sys_yield(void)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c34:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c39:	89 d1                	mov    %edx,%ecx
  800c3b:	89 d3                	mov    %edx,%ebx
  800c3d:	89 d7                	mov    %edx,%edi
  800c3f:	89 d6                	mov    %edx,%esi
  800c41:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c51:	be 00 00 00 00       	mov    $0x0,%esi
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c64:	89 f7                	mov    %esi,%edi
  800c66:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7f 08                	jg     800c74 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 04                	push   $0x4
  800c7a:	68 3f 2d 80 00       	push   $0x802d3f
  800c7f:	6a 2a                	push   $0x2a
  800c81:	68 5c 2d 80 00       	push   $0x802d5c
  800c86:	e8 0c f5 ff ff       	call   800197 <_panic>

00800c8b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca5:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7f 08                	jg     800cb6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	50                   	push   %eax
  800cba:	6a 05                	push   $0x5
  800cbc:	68 3f 2d 80 00       	push   $0x802d3f
  800cc1:	6a 2a                	push   $0x2a
  800cc3:	68 5c 2d 80 00       	push   $0x802d5c
  800cc8:	e8 ca f4 ff ff       	call   800197 <_panic>

00800ccd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce6:	89 df                	mov    %ebx,%edi
  800ce8:	89 de                	mov    %ebx,%esi
  800cea:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7f 08                	jg     800cf8 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	83 ec 0c             	sub    $0xc,%esp
  800cfb:	50                   	push   %eax
  800cfc:	6a 06                	push   $0x6
  800cfe:	68 3f 2d 80 00       	push   $0x802d3f
  800d03:	6a 2a                	push   $0x2a
  800d05:	68 5c 2d 80 00       	push   $0x802d5c
  800d0a:	e8 88 f4 ff ff       	call   800197 <_panic>

00800d0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	b8 08 00 00 00       	mov    $0x8,%eax
  800d28:	89 df                	mov    %ebx,%edi
  800d2a:	89 de                	mov    %ebx,%esi
  800d2c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	7f 08                	jg     800d3a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 08                	push   $0x8
  800d40:	68 3f 2d 80 00       	push   $0x802d3f
  800d45:	6a 2a                	push   $0x2a
  800d47:	68 5c 2d 80 00       	push   $0x802d5c
  800d4c:	e8 46 f4 ff ff       	call   800197 <_panic>

00800d51 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
  800d57:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6a:	89 df                	mov    %ebx,%edi
  800d6c:	89 de                	mov    %ebx,%esi
  800d6e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d70:	85 c0                	test   %eax,%eax
  800d72:	7f 08                	jg     800d7c <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	50                   	push   %eax
  800d80:	6a 09                	push   $0x9
  800d82:	68 3f 2d 80 00       	push   $0x802d3f
  800d87:	6a 2a                	push   $0x2a
  800d89:	68 5c 2d 80 00       	push   $0x802d5c
  800d8e:	e8 04 f4 ff ff       	call   800197 <_panic>

00800d93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dac:	89 df                	mov    %ebx,%edi
  800dae:	89 de                	mov    %ebx,%esi
  800db0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db2:	85 c0                	test   %eax,%eax
  800db4:	7f 08                	jg     800dbe <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	50                   	push   %eax
  800dc2:	6a 0a                	push   $0xa
  800dc4:	68 3f 2d 80 00       	push   $0x802d3f
  800dc9:	6a 2a                	push   $0x2a
  800dcb:	68 5c 2d 80 00       	push   $0x802d5c
  800dd0:	e8 c2 f3 ff ff       	call   800197 <_panic>

00800dd5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	57                   	push   %edi
  800dd9:	56                   	push   %esi
  800dda:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de6:	be 00 00 00 00       	mov    $0x0,%esi
  800deb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0e:	89 cb                	mov    %ecx,%ebx
  800e10:	89 cf                	mov    %ecx,%edi
  800e12:	89 ce                	mov    %ecx,%esi
  800e14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e16:	85 c0                	test   %eax,%eax
  800e18:	7f 08                	jg     800e22 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	50                   	push   %eax
  800e26:	6a 0d                	push   $0xd
  800e28:	68 3f 2d 80 00       	push   $0x802d3f
  800e2d:	6a 2a                	push   $0x2a
  800e2f:	68 5c 2d 80 00       	push   $0x802d5c
  800e34:	e8 5e f3 ff ff       	call   800197 <_panic>

00800e39 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e44:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e49:	89 d1                	mov    %edx,%ecx
  800e4b:	89 d3                	mov    %edx,%ebx
  800e4d:	89 d7                	mov    %edx,%edi
  800e4f:	89 d6                	mov    %edx,%esi
  800e51:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e69:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e6e:	89 df                	mov    %ebx,%edi
  800e70:	89 de                	mov    %ebx,%esi
  800e72:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8a:	b8 10 00 00 00       	mov    $0x10,%eax
  800e8f:	89 df                	mov    %ebx,%edi
  800e91:	89 de                	mov    %ebx,%esi
  800e93:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea5:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eb5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eba:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec9:	89 c2                	mov    %eax,%edx
  800ecb:	c1 ea 16             	shr    $0x16,%edx
  800ece:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed5:	f6 c2 01             	test   $0x1,%dl
  800ed8:	74 29                	je     800f03 <fd_alloc+0x42>
  800eda:	89 c2                	mov    %eax,%edx
  800edc:	c1 ea 0c             	shr    $0xc,%edx
  800edf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee6:	f6 c2 01             	test   $0x1,%dl
  800ee9:	74 18                	je     800f03 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800eeb:	05 00 10 00 00       	add    $0x1000,%eax
  800ef0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef5:	75 d2                	jne    800ec9 <fd_alloc+0x8>
  800ef7:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800efc:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f01:	eb 05                	jmp    800f08 <fd_alloc+0x47>
			return 0;
  800f03:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f08:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0b:	89 02                	mov    %eax,(%edx)
}
  800f0d:	89 c8                	mov    %ecx,%eax
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f17:	83 f8 1f             	cmp    $0x1f,%eax
  800f1a:	77 30                	ja     800f4c <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f1c:	c1 e0 0c             	shl    $0xc,%eax
  800f1f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f24:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f2a:	f6 c2 01             	test   $0x1,%dl
  800f2d:	74 24                	je     800f53 <fd_lookup+0x42>
  800f2f:	89 c2                	mov    %eax,%edx
  800f31:	c1 ea 0c             	shr    $0xc,%edx
  800f34:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3b:	f6 c2 01             	test   $0x1,%dl
  800f3e:	74 1a                	je     800f5a <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f40:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f43:	89 02                	mov    %eax,(%edx)
	return 0;
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    
		return -E_INVAL;
  800f4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f51:	eb f7                	jmp    800f4a <fd_lookup+0x39>
		return -E_INVAL;
  800f53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f58:	eb f0                	jmp    800f4a <fd_lookup+0x39>
  800f5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5f:	eb e9                	jmp    800f4a <fd_lookup+0x39>

00800f61 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	53                   	push   %ebx
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f70:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f75:	39 13                	cmp    %edx,(%ebx)
  800f77:	74 37                	je     800fb0 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f79:	83 c0 01             	add    $0x1,%eax
  800f7c:	8b 1c 85 e8 2d 80 00 	mov    0x802de8(,%eax,4),%ebx
  800f83:	85 db                	test   %ebx,%ebx
  800f85:	75 ee                	jne    800f75 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f87:	a1 00 40 80 00       	mov    0x804000,%eax
  800f8c:	8b 40 58             	mov    0x58(%eax),%eax
  800f8f:	83 ec 04             	sub    $0x4,%esp
  800f92:	52                   	push   %edx
  800f93:	50                   	push   %eax
  800f94:	68 6c 2d 80 00       	push   $0x802d6c
  800f99:	e8 d4 f2 ff ff       	call   800272 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800fa6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa9:	89 1a                	mov    %ebx,(%edx)
}
  800fab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    
			return 0;
  800fb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb5:	eb ef                	jmp    800fa6 <dev_lookup+0x45>

00800fb7 <fd_close>:
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	57                   	push   %edi
  800fbb:	56                   	push   %esi
  800fbc:	53                   	push   %ebx
  800fbd:	83 ec 24             	sub    $0x24,%esp
  800fc0:	8b 75 08             	mov    0x8(%ebp),%esi
  800fc3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc9:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fca:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fd0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd3:	50                   	push   %eax
  800fd4:	e8 38 ff ff ff       	call   800f11 <fd_lookup>
  800fd9:	89 c3                	mov    %eax,%ebx
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 05                	js     800fe7 <fd_close+0x30>
	    || fd != fd2)
  800fe2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fe5:	74 16                	je     800ffd <fd_close+0x46>
		return (must_exist ? r : 0);
  800fe7:	89 f8                	mov    %edi,%eax
  800fe9:	84 c0                	test   %al,%al
  800feb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff0:	0f 44 d8             	cmove  %eax,%ebx
}
  800ff3:	89 d8                	mov    %ebx,%eax
  800ff5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801003:	50                   	push   %eax
  801004:	ff 36                	push   (%esi)
  801006:	e8 56 ff ff ff       	call   800f61 <dev_lookup>
  80100b:	89 c3                	mov    %eax,%ebx
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 1a                	js     80102e <fd_close+0x77>
		if (dev->dev_close)
  801014:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801017:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80101a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80101f:	85 c0                	test   %eax,%eax
  801021:	74 0b                	je     80102e <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	56                   	push   %esi
  801027:	ff d0                	call   *%eax
  801029:	89 c3                	mov    %eax,%ebx
  80102b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	56                   	push   %esi
  801032:	6a 00                	push   $0x0
  801034:	e8 94 fc ff ff       	call   800ccd <sys_page_unmap>
	return r;
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	eb b5                	jmp    800ff3 <fd_close+0x3c>

0080103e <close>:

int
close(int fdnum)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801044:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801047:	50                   	push   %eax
  801048:	ff 75 08             	push   0x8(%ebp)
  80104b:	e8 c1 fe ff ff       	call   800f11 <fd_lookup>
  801050:	83 c4 10             	add    $0x10,%esp
  801053:	85 c0                	test   %eax,%eax
  801055:	79 02                	jns    801059 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801057:	c9                   	leave  
  801058:	c3                   	ret    
		return fd_close(fd, 1);
  801059:	83 ec 08             	sub    $0x8,%esp
  80105c:	6a 01                	push   $0x1
  80105e:	ff 75 f4             	push   -0xc(%ebp)
  801061:	e8 51 ff ff ff       	call   800fb7 <fd_close>
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	eb ec                	jmp    801057 <close+0x19>

0080106b <close_all>:

void
close_all(void)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	53                   	push   %ebx
  80106f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801072:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	53                   	push   %ebx
  80107b:	e8 be ff ff ff       	call   80103e <close>
	for (i = 0; i < MAXFD; i++)
  801080:	83 c3 01             	add    $0x1,%ebx
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	83 fb 20             	cmp    $0x20,%ebx
  801089:	75 ec                	jne    801077 <close_all+0xc>
}
  80108b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801099:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80109c:	50                   	push   %eax
  80109d:	ff 75 08             	push   0x8(%ebp)
  8010a0:	e8 6c fe ff ff       	call   800f11 <fd_lookup>
  8010a5:	89 c3                	mov    %eax,%ebx
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 7f                	js     80112d <dup+0x9d>
		return r;
	close(newfdnum);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	ff 75 0c             	push   0xc(%ebp)
  8010b4:	e8 85 ff ff ff       	call   80103e <close>

	newfd = INDEX2FD(newfdnum);
  8010b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010bc:	c1 e6 0c             	shl    $0xc,%esi
  8010bf:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010c8:	89 3c 24             	mov    %edi,(%esp)
  8010cb:	e8 da fd ff ff       	call   800eaa <fd2data>
  8010d0:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010d2:	89 34 24             	mov    %esi,(%esp)
  8010d5:	e8 d0 fd ff ff       	call   800eaa <fd2data>
  8010da:	83 c4 10             	add    $0x10,%esp
  8010dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010e0:	89 d8                	mov    %ebx,%eax
  8010e2:	c1 e8 16             	shr    $0x16,%eax
  8010e5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ec:	a8 01                	test   $0x1,%al
  8010ee:	74 11                	je     801101 <dup+0x71>
  8010f0:	89 d8                	mov    %ebx,%eax
  8010f2:	c1 e8 0c             	shr    $0xc,%eax
  8010f5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010fc:	f6 c2 01             	test   $0x1,%dl
  8010ff:	75 36                	jne    801137 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801101:	89 f8                	mov    %edi,%eax
  801103:	c1 e8 0c             	shr    $0xc,%eax
  801106:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	25 07 0e 00 00       	and    $0xe07,%eax
  801115:	50                   	push   %eax
  801116:	56                   	push   %esi
  801117:	6a 00                	push   $0x0
  801119:	57                   	push   %edi
  80111a:	6a 00                	push   $0x0
  80111c:	e8 6a fb ff ff       	call   800c8b <sys_page_map>
  801121:	89 c3                	mov    %eax,%ebx
  801123:	83 c4 20             	add    $0x20,%esp
  801126:	85 c0                	test   %eax,%eax
  801128:	78 33                	js     80115d <dup+0xcd>
		goto err;

	return newfdnum;
  80112a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80112d:	89 d8                	mov    %ebx,%eax
  80112f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801137:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	25 07 0e 00 00       	and    $0xe07,%eax
  801146:	50                   	push   %eax
  801147:	ff 75 d4             	push   -0x2c(%ebp)
  80114a:	6a 00                	push   $0x0
  80114c:	53                   	push   %ebx
  80114d:	6a 00                	push   $0x0
  80114f:	e8 37 fb ff ff       	call   800c8b <sys_page_map>
  801154:	89 c3                	mov    %eax,%ebx
  801156:	83 c4 20             	add    $0x20,%esp
  801159:	85 c0                	test   %eax,%eax
  80115b:	79 a4                	jns    801101 <dup+0x71>
	sys_page_unmap(0, newfd);
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	56                   	push   %esi
  801161:	6a 00                	push   $0x0
  801163:	e8 65 fb ff ff       	call   800ccd <sys_page_unmap>
	sys_page_unmap(0, nva);
  801168:	83 c4 08             	add    $0x8,%esp
  80116b:	ff 75 d4             	push   -0x2c(%ebp)
  80116e:	6a 00                	push   $0x0
  801170:	e8 58 fb ff ff       	call   800ccd <sys_page_unmap>
	return r;
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	eb b3                	jmp    80112d <dup+0x9d>

0080117a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	56                   	push   %esi
  80117e:	53                   	push   %ebx
  80117f:	83 ec 18             	sub    $0x18,%esp
  801182:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801185:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801188:	50                   	push   %eax
  801189:	56                   	push   %esi
  80118a:	e8 82 fd ff ff       	call   800f11 <fd_lookup>
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	85 c0                	test   %eax,%eax
  801194:	78 3c                	js     8011d2 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801196:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801199:	83 ec 08             	sub    $0x8,%esp
  80119c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119f:	50                   	push   %eax
  8011a0:	ff 33                	push   (%ebx)
  8011a2:	e8 ba fd ff ff       	call   800f61 <dev_lookup>
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 24                	js     8011d2 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011ae:	8b 43 08             	mov    0x8(%ebx),%eax
  8011b1:	83 e0 03             	and    $0x3,%eax
  8011b4:	83 f8 01             	cmp    $0x1,%eax
  8011b7:	74 20                	je     8011d9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bc:	8b 40 08             	mov    0x8(%eax),%eax
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	74 37                	je     8011fa <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011c3:	83 ec 04             	sub    $0x4,%esp
  8011c6:	ff 75 10             	push   0x10(%ebp)
  8011c9:	ff 75 0c             	push   0xc(%ebp)
  8011cc:	53                   	push   %ebx
  8011cd:	ff d0                	call   *%eax
  8011cf:	83 c4 10             	add    $0x10,%esp
}
  8011d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d9:	a1 00 40 80 00       	mov    0x804000,%eax
  8011de:	8b 40 58             	mov    0x58(%eax),%eax
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	56                   	push   %esi
  8011e5:	50                   	push   %eax
  8011e6:	68 ad 2d 80 00       	push   $0x802dad
  8011eb:	e8 82 f0 ff ff       	call   800272 <cprintf>
		return -E_INVAL;
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f8:	eb d8                	jmp    8011d2 <read+0x58>
		return -E_NOT_SUPP;
  8011fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ff:	eb d1                	jmp    8011d2 <read+0x58>

00801201 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	57                   	push   %edi
  801205:	56                   	push   %esi
  801206:	53                   	push   %ebx
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801210:	bb 00 00 00 00       	mov    $0x0,%ebx
  801215:	eb 02                	jmp    801219 <readn+0x18>
  801217:	01 c3                	add    %eax,%ebx
  801219:	39 f3                	cmp    %esi,%ebx
  80121b:	73 21                	jae    80123e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80121d:	83 ec 04             	sub    $0x4,%esp
  801220:	89 f0                	mov    %esi,%eax
  801222:	29 d8                	sub    %ebx,%eax
  801224:	50                   	push   %eax
  801225:	89 d8                	mov    %ebx,%eax
  801227:	03 45 0c             	add    0xc(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	57                   	push   %edi
  80122c:	e8 49 ff ff ff       	call   80117a <read>
		if (m < 0)
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	85 c0                	test   %eax,%eax
  801236:	78 04                	js     80123c <readn+0x3b>
			return m;
		if (m == 0)
  801238:	75 dd                	jne    801217 <readn+0x16>
  80123a:	eb 02                	jmp    80123e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80123c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80123e:	89 d8                	mov    %ebx,%eax
  801240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801243:	5b                   	pop    %ebx
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	56                   	push   %esi
  80124c:	53                   	push   %ebx
  80124d:	83 ec 18             	sub    $0x18,%esp
  801250:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801253:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801256:	50                   	push   %eax
  801257:	53                   	push   %ebx
  801258:	e8 b4 fc ff ff       	call   800f11 <fd_lookup>
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	78 37                	js     80129b <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801264:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	ff 36                	push   (%esi)
  801270:	e8 ec fc ff ff       	call   800f61 <dev_lookup>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 1f                	js     80129b <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801280:	74 20                	je     8012a2 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801282:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801285:	8b 40 0c             	mov    0xc(%eax),%eax
  801288:	85 c0                	test   %eax,%eax
  80128a:	74 37                	je     8012c3 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80128c:	83 ec 04             	sub    $0x4,%esp
  80128f:	ff 75 10             	push   0x10(%ebp)
  801292:	ff 75 0c             	push   0xc(%ebp)
  801295:	56                   	push   %esi
  801296:	ff d0                	call   *%eax
  801298:	83 c4 10             	add    $0x10,%esp
}
  80129b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129e:	5b                   	pop    %ebx
  80129f:	5e                   	pop    %esi
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a2:	a1 00 40 80 00       	mov    0x804000,%eax
  8012a7:	8b 40 58             	mov    0x58(%eax),%eax
  8012aa:	83 ec 04             	sub    $0x4,%esp
  8012ad:	53                   	push   %ebx
  8012ae:	50                   	push   %eax
  8012af:	68 c9 2d 80 00       	push   $0x802dc9
  8012b4:	e8 b9 ef ff ff       	call   800272 <cprintf>
		return -E_INVAL;
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c1:	eb d8                	jmp    80129b <write+0x53>
		return -E_NOT_SUPP;
  8012c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c8:	eb d1                	jmp    80129b <write+0x53>

008012ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d3:	50                   	push   %eax
  8012d4:	ff 75 08             	push   0x8(%ebp)
  8012d7:	e8 35 fc ff ff       	call   800f11 <fd_lookup>
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 0e                	js     8012f1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 18             	sub    $0x18,%esp
  8012fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	53                   	push   %ebx
  801303:	e8 09 fc ff ff       	call   800f11 <fd_lookup>
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 34                	js     801343 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 36                	push   (%esi)
  80131b:	e8 41 fc ff ff       	call   800f61 <dev_lookup>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 1c                	js     801343 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801327:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80132b:	74 1d                	je     80134a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80132d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801330:	8b 40 18             	mov    0x18(%eax),%eax
  801333:	85 c0                	test   %eax,%eax
  801335:	74 34                	je     80136b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	ff 75 0c             	push   0xc(%ebp)
  80133d:	56                   	push   %esi
  80133e:	ff d0                	call   *%eax
  801340:	83 c4 10             	add    $0x10,%esp
}
  801343:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    
			thisenv->env_id, fdnum);
  80134a:	a1 00 40 80 00       	mov    0x804000,%eax
  80134f:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801352:	83 ec 04             	sub    $0x4,%esp
  801355:	53                   	push   %ebx
  801356:	50                   	push   %eax
  801357:	68 8c 2d 80 00       	push   $0x802d8c
  80135c:	e8 11 ef ff ff       	call   800272 <cprintf>
		return -E_INVAL;
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801369:	eb d8                	jmp    801343 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80136b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801370:	eb d1                	jmp    801343 <ftruncate+0x50>

00801372 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	56                   	push   %esi
  801376:	53                   	push   %ebx
  801377:	83 ec 18             	sub    $0x18,%esp
  80137a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801380:	50                   	push   %eax
  801381:	ff 75 08             	push   0x8(%ebp)
  801384:	e8 88 fb ff ff       	call   800f11 <fd_lookup>
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 49                	js     8013d9 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801390:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	ff 36                	push   (%esi)
  80139c:	e8 c0 fb ff ff       	call   800f61 <dev_lookup>
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 31                	js     8013d9 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ab:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013af:	74 2f                	je     8013e0 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013bb:	00 00 00 
	stat->st_isdir = 0;
  8013be:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013c5:	00 00 00 
	stat->st_dev = dev;
  8013c8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013ce:	83 ec 08             	sub    $0x8,%esp
  8013d1:	53                   	push   %ebx
  8013d2:	56                   	push   %esi
  8013d3:	ff 50 14             	call   *0x14(%eax)
  8013d6:	83 c4 10             	add    $0x10,%esp
}
  8013d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    
		return -E_NOT_SUPP;
  8013e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e5:	eb f2                	jmp    8013d9 <fstat+0x67>

008013e7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	56                   	push   %esi
  8013eb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	6a 00                	push   $0x0
  8013f1:	ff 75 08             	push   0x8(%ebp)
  8013f4:	e8 e4 01 00 00       	call   8015dd <open>
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 1b                	js     80141d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	ff 75 0c             	push   0xc(%ebp)
  801408:	50                   	push   %eax
  801409:	e8 64 ff ff ff       	call   801372 <fstat>
  80140e:	89 c6                	mov    %eax,%esi
	close(fd);
  801410:	89 1c 24             	mov    %ebx,(%esp)
  801413:	e8 26 fc ff ff       	call   80103e <close>
	return r;
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	89 f3                	mov    %esi,%ebx
}
  80141d:	89 d8                	mov    %ebx,%eax
  80141f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801422:	5b                   	pop    %ebx
  801423:	5e                   	pop    %esi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	56                   	push   %esi
  80142a:	53                   	push   %ebx
  80142b:	89 c6                	mov    %eax,%esi
  80142d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80142f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801436:	74 27                	je     80145f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801438:	6a 07                	push   $0x7
  80143a:	68 00 50 80 00       	push   $0x805000
  80143f:	56                   	push   %esi
  801440:	ff 35 00 60 80 00    	push   0x806000
  801446:	e8 e2 11 00 00       	call   80262d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80144b:	83 c4 0c             	add    $0xc,%esp
  80144e:	6a 00                	push   $0x0
  801450:	53                   	push   %ebx
  801451:	6a 00                	push   $0x0
  801453:	e8 65 11 00 00       	call   8025bd <ipc_recv>
}
  801458:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80145f:	83 ec 0c             	sub    $0xc,%esp
  801462:	6a 01                	push   $0x1
  801464:	e8 18 12 00 00       	call   802681 <ipc_find_env>
  801469:	a3 00 60 80 00       	mov    %eax,0x806000
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	eb c5                	jmp    801438 <fsipc+0x12>

00801473 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
  80147c:	8b 40 0c             	mov    0xc(%eax),%eax
  80147f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801484:	8b 45 0c             	mov    0xc(%ebp),%eax
  801487:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80148c:	ba 00 00 00 00       	mov    $0x0,%edx
  801491:	b8 02 00 00 00       	mov    $0x2,%eax
  801496:	e8 8b ff ff ff       	call   801426 <fsipc>
}
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <devfile_flush>:
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b3:	b8 06 00 00 00       	mov    $0x6,%eax
  8014b8:	e8 69 ff ff ff       	call   801426 <fsipc>
}
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <devfile_stat>:
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 04             	sub    $0x4,%esp
  8014c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014de:	e8 43 ff ff ff       	call   801426 <fsipc>
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 2c                	js     801513 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	68 00 50 80 00       	push   $0x805000
  8014ef:	53                   	push   %ebx
  8014f0:	e8 57 f3 ff ff       	call   80084c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014f5:	a1 80 50 80 00       	mov    0x805080,%eax
  8014fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801500:	a1 84 50 80 00       	mov    0x805084,%eax
  801505:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801513:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801516:	c9                   	leave  
  801517:	c3                   	ret    

00801518 <devfile_write>:
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	83 ec 0c             	sub    $0xc,%esp
  80151e:	8b 45 10             	mov    0x10(%ebp),%eax
  801521:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801526:	39 d0                	cmp    %edx,%eax
  801528:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80152b:	8b 55 08             	mov    0x8(%ebp),%edx
  80152e:	8b 52 0c             	mov    0xc(%edx),%edx
  801531:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801537:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80153c:	50                   	push   %eax
  80153d:	ff 75 0c             	push   0xc(%ebp)
  801540:	68 08 50 80 00       	push   $0x805008
  801545:	e8 98 f4 ff ff       	call   8009e2 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80154a:	ba 00 00 00 00       	mov    $0x0,%edx
  80154f:	b8 04 00 00 00       	mov    $0x4,%eax
  801554:	e8 cd fe ff ff       	call   801426 <fsipc>
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <devfile_read>:
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	56                   	push   %esi
  80155f:	53                   	push   %ebx
  801560:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801563:	8b 45 08             	mov    0x8(%ebp),%eax
  801566:	8b 40 0c             	mov    0xc(%eax),%eax
  801569:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80156e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801574:	ba 00 00 00 00       	mov    $0x0,%edx
  801579:	b8 03 00 00 00       	mov    $0x3,%eax
  80157e:	e8 a3 fe ff ff       	call   801426 <fsipc>
  801583:	89 c3                	mov    %eax,%ebx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 1f                	js     8015a8 <devfile_read+0x4d>
	assert(r <= n);
  801589:	39 f0                	cmp    %esi,%eax
  80158b:	77 24                	ja     8015b1 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80158d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801592:	7f 33                	jg     8015c7 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801594:	83 ec 04             	sub    $0x4,%esp
  801597:	50                   	push   %eax
  801598:	68 00 50 80 00       	push   $0x805000
  80159d:	ff 75 0c             	push   0xc(%ebp)
  8015a0:	e8 3d f4 ff ff       	call   8009e2 <memmove>
	return r;
  8015a5:	83 c4 10             	add    $0x10,%esp
}
  8015a8:	89 d8                	mov    %ebx,%eax
  8015aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ad:	5b                   	pop    %ebx
  8015ae:	5e                   	pop    %esi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    
	assert(r <= n);
  8015b1:	68 fc 2d 80 00       	push   $0x802dfc
  8015b6:	68 03 2e 80 00       	push   $0x802e03
  8015bb:	6a 7c                	push   $0x7c
  8015bd:	68 18 2e 80 00       	push   $0x802e18
  8015c2:	e8 d0 eb ff ff       	call   800197 <_panic>
	assert(r <= PGSIZE);
  8015c7:	68 23 2e 80 00       	push   $0x802e23
  8015cc:	68 03 2e 80 00       	push   $0x802e03
  8015d1:	6a 7d                	push   $0x7d
  8015d3:	68 18 2e 80 00       	push   $0x802e18
  8015d8:	e8 ba eb ff ff       	call   800197 <_panic>

008015dd <open>:
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	56                   	push   %esi
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 1c             	sub    $0x1c,%esp
  8015e5:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015e8:	56                   	push   %esi
  8015e9:	e8 23 f2 ff ff       	call   800811 <strlen>
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015f6:	7f 6c                	jg     801664 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015f8:	83 ec 0c             	sub    $0xc,%esp
  8015fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fe:	50                   	push   %eax
  8015ff:	e8 bd f8 ff ff       	call   800ec1 <fd_alloc>
  801604:	89 c3                	mov    %eax,%ebx
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 3c                	js     801649 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80160d:	83 ec 08             	sub    $0x8,%esp
  801610:	56                   	push   %esi
  801611:	68 00 50 80 00       	push   $0x805000
  801616:	e8 31 f2 ff ff       	call   80084c <strcpy>
	fsipcbuf.open.req_omode = mode;
  80161b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801623:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801626:	b8 01 00 00 00       	mov    $0x1,%eax
  80162b:	e8 f6 fd ff ff       	call   801426 <fsipc>
  801630:	89 c3                	mov    %eax,%ebx
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	85 c0                	test   %eax,%eax
  801637:	78 19                	js     801652 <open+0x75>
	return fd2num(fd);
  801639:	83 ec 0c             	sub    $0xc,%esp
  80163c:	ff 75 f4             	push   -0xc(%ebp)
  80163f:	e8 56 f8 ff ff       	call   800e9a <fd2num>
  801644:	89 c3                	mov    %eax,%ebx
  801646:	83 c4 10             	add    $0x10,%esp
}
  801649:	89 d8                	mov    %ebx,%eax
  80164b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164e:	5b                   	pop    %ebx
  80164f:	5e                   	pop    %esi
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    
		fd_close(fd, 0);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	6a 00                	push   $0x0
  801657:	ff 75 f4             	push   -0xc(%ebp)
  80165a:	e8 58 f9 ff ff       	call   800fb7 <fd_close>
		return r;
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	eb e5                	jmp    801649 <open+0x6c>
		return -E_BAD_PATH;
  801664:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801669:	eb de                	jmp    801649 <open+0x6c>

0080166b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801671:	ba 00 00 00 00       	mov    $0x0,%edx
  801676:	b8 08 00 00 00       	mov    $0x8,%eax
  80167b:	e8 a6 fd ff ff       	call   801426 <fsipc>
}
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	57                   	push   %edi
  801686:	56                   	push   %esi
  801687:	53                   	push   %ebx
  801688:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80168e:	6a 00                	push   $0x0
  801690:	ff 75 08             	push   0x8(%ebp)
  801693:	e8 45 ff ff ff       	call   8015dd <open>
  801698:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	0f 88 ad 04 00 00    	js     801b56 <spawn+0x4d4>
  8016a9:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8016ab:	83 ec 04             	sub    $0x4,%esp
  8016ae:	68 00 02 00 00       	push   $0x200
  8016b3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016b9:	50                   	push   %eax
  8016ba:	57                   	push   %edi
  8016bb:	e8 41 fb ff ff       	call   801201 <readn>
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016c8:	75 5a                	jne    801724 <spawn+0xa2>
	    || elf->e_magic != ELF_MAGIC) {
  8016ca:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016d1:	45 4c 46 
  8016d4:	75 4e                	jne    801724 <spawn+0xa2>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016d6:	b8 07 00 00 00       	mov    $0x7,%eax
  8016db:	cd 30                	int    $0x30
  8016dd:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	0f 88 5f 04 00 00    	js     801b4a <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016f0:	69 f0 8c 00 00 00    	imul   $0x8c,%eax,%esi
  8016f6:	81 c6 10 00 c0 ee    	add    $0xeec00010,%esi
  8016fc:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801702:	b9 11 00 00 00       	mov    $0x11,%ecx
  801707:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801709:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80170f:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801715:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80171a:	be 00 00 00 00       	mov    $0x0,%esi
  80171f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  801722:	eb 4b                	jmp    80176f <spawn+0xed>
		close(fd);
  801724:	83 ec 0c             	sub    $0xc,%esp
  801727:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80172d:	e8 0c f9 ff ff       	call   80103e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801732:	83 c4 0c             	add    $0xc,%esp
  801735:	68 7f 45 4c 46       	push   $0x464c457f
  80173a:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  801740:	68 2f 2e 80 00       	push   $0x802e2f
  801745:	e8 28 eb ff ff       	call   800272 <cprintf>
		return -E_NOT_EXEC;
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  801754:	ff ff ff 
  801757:	e9 fa 03 00 00       	jmp    801b56 <spawn+0x4d4>
		string_size += strlen(argv[argc]) + 1;
  80175c:	83 ec 0c             	sub    $0xc,%esp
  80175f:	50                   	push   %eax
  801760:	e8 ac f0 ff ff       	call   800811 <strlen>
  801765:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801769:	83 c3 01             	add    $0x1,%ebx
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801776:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801779:	85 c0                	test   %eax,%eax
  80177b:	75 df                	jne    80175c <spawn+0xda>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80177d:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801783:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801789:	b8 00 10 40 00       	mov    $0x401000,%eax
  80178e:	29 f0                	sub    %esi,%eax
  801790:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801792:	89 c2                	mov    %eax,%edx
  801794:	83 e2 fc             	and    $0xfffffffc,%edx
  801797:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80179e:	29 c2                	sub    %eax,%edx
  8017a0:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8017a6:	8d 42 f8             	lea    -0x8(%edx),%eax
  8017a9:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8017ae:	0f 86 14 04 00 00    	jbe    801bc8 <spawn+0x546>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017b4:	83 ec 04             	sub    $0x4,%esp
  8017b7:	6a 07                	push   $0x7
  8017b9:	68 00 00 40 00       	push   $0x400000
  8017be:	6a 00                	push   $0x0
  8017c0:	e8 83 f4 ff ff       	call   800c48 <sys_page_alloc>
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	0f 88 fd 03 00 00    	js     801bcd <spawn+0x54b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017d0:	be 00 00 00 00       	mov    $0x0,%esi
  8017d5:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8017db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017de:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017e4:	7e 32                	jle    801818 <spawn+0x196>
		argv_store[i] = UTEMP2USTACK(string_store);
  8017e6:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017ec:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017f2:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	ff 34 b3             	push   (%ebx,%esi,4)
  8017fb:	57                   	push   %edi
  8017fc:	e8 4b f0 ff ff       	call   80084c <strcpy>
		string_store += strlen(argv[i]) + 1;
  801801:	83 c4 04             	add    $0x4,%esp
  801804:	ff 34 b3             	push   (%ebx,%esi,4)
  801807:	e8 05 f0 ff ff       	call   800811 <strlen>
  80180c:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801810:	83 c6 01             	add    $0x1,%esi
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	eb c6                	jmp    8017de <spawn+0x15c>
	}
	argv_store[argc] = 0;
  801818:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80181e:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801824:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80182b:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801831:	0f 85 8c 00 00 00    	jne    8018c3 <spawn+0x241>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801837:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80183d:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801843:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801846:	89 c8                	mov    %ecx,%eax
  801848:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  80184e:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801851:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801856:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80185c:	83 ec 0c             	sub    $0xc,%esp
  80185f:	6a 07                	push   $0x7
  801861:	68 00 d0 bf ee       	push   $0xeebfd000
  801866:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80186c:	68 00 00 40 00       	push   $0x400000
  801871:	6a 00                	push   $0x0
  801873:	e8 13 f4 ff ff       	call   800c8b <sys_page_map>
  801878:	89 c3                	mov    %eax,%ebx
  80187a:	83 c4 20             	add    $0x20,%esp
  80187d:	85 c0                	test   %eax,%eax
  80187f:	0f 88 50 03 00 00    	js     801bd5 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	68 00 00 40 00       	push   $0x400000
  80188d:	6a 00                	push   $0x0
  80188f:	e8 39 f4 ff ff       	call   800ccd <sys_page_unmap>
  801894:	89 c3                	mov    %eax,%ebx
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	85 c0                	test   %eax,%eax
  80189b:	0f 88 34 03 00 00    	js     801bd5 <spawn+0x553>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018a1:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8018a7:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8018ae:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018b4:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8018bb:	00 00 00 
  8018be:	e9 4e 01 00 00       	jmp    801a11 <spawn+0x38f>
	assert(string_store == (char*)UTEMP + PGSIZE);
  8018c3:	68 bc 2e 80 00       	push   $0x802ebc
  8018c8:	68 03 2e 80 00       	push   $0x802e03
  8018cd:	68 f2 00 00 00       	push   $0xf2
  8018d2:	68 49 2e 80 00       	push   $0x802e49
  8018d7:	e8 bb e8 ff ff       	call   800197 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018dc:	83 ec 04             	sub    $0x4,%esp
  8018df:	6a 07                	push   $0x7
  8018e1:	68 00 00 40 00       	push   $0x400000
  8018e6:	6a 00                	push   $0x0
  8018e8:	e8 5b f3 ff ff       	call   800c48 <sys_page_alloc>
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	0f 88 6c 02 00 00    	js     801b64 <spawn+0x4e2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801901:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801907:	50                   	push   %eax
  801908:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80190e:	e8 b7 f9 ff ff       	call   8012ca <seek>
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	0f 88 4d 02 00 00    	js     801b6b <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80191e:	83 ec 04             	sub    $0x4,%esp
  801921:	89 f8                	mov    %edi,%eax
  801923:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801929:	ba 00 10 00 00       	mov    $0x1000,%edx
  80192e:	39 d0                	cmp    %edx,%eax
  801930:	0f 47 c2             	cmova  %edx,%eax
  801933:	50                   	push   %eax
  801934:	68 00 00 40 00       	push   $0x400000
  801939:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80193f:	e8 bd f8 ff ff       	call   801201 <readn>
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	85 c0                	test   %eax,%eax
  801949:	0f 88 23 02 00 00    	js     801b72 <spawn+0x4f0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801958:	56                   	push   %esi
  801959:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80195f:	68 00 00 40 00       	push   $0x400000
  801964:	6a 00                	push   $0x0
  801966:	e8 20 f3 ff ff       	call   800c8b <sys_page_map>
  80196b:	83 c4 20             	add    $0x20,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 7c                	js     8019ee <spawn+0x36c>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801972:	83 ec 08             	sub    $0x8,%esp
  801975:	68 00 00 40 00       	push   $0x400000
  80197a:	6a 00                	push   $0x0
  80197c:	e8 4c f3 ff ff       	call   800ccd <sys_page_unmap>
  801981:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801984:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80198a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801990:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801996:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  80199c:	76 65                	jbe    801a03 <spawn+0x381>
		if (i >= filesz) {
  80199e:	39 df                	cmp    %ebx,%edi
  8019a0:	0f 87 36 ff ff ff    	ja     8018dc <spawn+0x25a>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8019a6:	83 ec 04             	sub    $0x4,%esp
  8019a9:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  8019af:	56                   	push   %esi
  8019b0:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8019b6:	e8 8d f2 ff ff       	call   800c48 <sys_page_alloc>
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	79 c2                	jns    801984 <spawn+0x302>
  8019c2:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8019c4:	83 ec 0c             	sub    $0xc,%esp
  8019c7:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8019cd:	e8 f7 f1 ff ff       	call   800bc9 <sys_env_destroy>
	close(fd);
  8019d2:	83 c4 04             	add    $0x4,%esp
  8019d5:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8019db:	e8 5e f6 ff ff       	call   80103e <close>
	return r;
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  8019e9:	e9 68 01 00 00       	jmp    801b56 <spawn+0x4d4>
				panic("spawn: sys_page_map data: %e", r);
  8019ee:	50                   	push   %eax
  8019ef:	68 55 2e 80 00       	push   $0x802e55
  8019f4:	68 25 01 00 00       	push   $0x125
  8019f9:	68 49 2e 80 00       	push   $0x802e49
  8019fe:	e8 94 e7 ff ff       	call   800197 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a03:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801a0a:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801a11:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a18:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801a1e:	7e 67                	jle    801a87 <spawn+0x405>
		if (ph->p_type != ELF_PROG_LOAD)
  801a20:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801a26:	83 39 01             	cmpl   $0x1,(%ecx)
  801a29:	75 d8                	jne    801a03 <spawn+0x381>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a2b:	8b 41 18             	mov    0x18(%ecx),%eax
  801a2e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801a34:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801a37:	83 f8 01             	cmp    $0x1,%eax
  801a3a:	19 c0                	sbb    %eax,%eax
  801a3c:	83 e0 fe             	and    $0xfffffffe,%eax
  801a3f:	83 c0 07             	add    $0x7,%eax
  801a42:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a48:	8b 51 04             	mov    0x4(%ecx),%edx
  801a4b:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801a51:	8b 79 10             	mov    0x10(%ecx),%edi
  801a54:	8b 59 14             	mov    0x14(%ecx),%ebx
  801a57:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a5d:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  801a60:	89 f0                	mov    %esi,%eax
  801a62:	25 ff 0f 00 00       	and    $0xfff,%eax
  801a67:	74 14                	je     801a7d <spawn+0x3fb>
		va -= i;
  801a69:	29 c6                	sub    %eax,%esi
		memsz += i;
  801a6b:	01 c3                	add    %eax,%ebx
  801a6d:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801a73:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801a75:	29 c2                	sub    %eax,%edx
  801a77:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801a7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a82:	e9 09 ff ff ff       	jmp    801990 <spawn+0x30e>
	close(fd);
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801a90:	e8 a9 f5 ff ff       	call   80103e <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801a95:	e8 70 f1 ff ff       	call   800c0a <sys_getenvid>
  801a9a:	89 c6                	mov    %eax,%esi
  801a9c:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801a9f:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801aa4:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801aaa:	eb 12                	jmp    801abe <spawn+0x43c>
  801aac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ab2:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801ab8:	0f 84 bb 00 00 00    	je     801b79 <spawn+0x4f7>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801abe:	89 d8                	mov    %ebx,%eax
  801ac0:	c1 e8 16             	shr    $0x16,%eax
  801ac3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801aca:	a8 01                	test   $0x1,%al
  801acc:	74 de                	je     801aac <spawn+0x42a>
  801ace:	89 d8                	mov    %ebx,%eax
  801ad0:	c1 e8 0c             	shr    $0xc,%eax
  801ad3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ada:	f6 c2 01             	test   $0x1,%dl
  801add:	74 cd                	je     801aac <spawn+0x42a>
  801adf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ae6:	f6 c6 04             	test   $0x4,%dh
  801ae9:	74 c1                	je     801aac <spawn+0x42a>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801aeb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	25 07 0e 00 00       	and    $0xe07,%eax
  801afa:	50                   	push   %eax
  801afb:	53                   	push   %ebx
  801afc:	57                   	push   %edi
  801afd:	53                   	push   %ebx
  801afe:	56                   	push   %esi
  801aff:	e8 87 f1 ff ff       	call   800c8b <sys_page_map>
  801b04:	83 c4 20             	add    $0x20,%esp
  801b07:	85 c0                	test   %eax,%eax
  801b09:	79 a1                	jns    801aac <spawn+0x42a>
		panic("copy_shared_pages: %e", r);
  801b0b:	50                   	push   %eax
  801b0c:	68 a3 2e 80 00       	push   $0x802ea3
  801b11:	68 82 00 00 00       	push   $0x82
  801b16:	68 49 2e 80 00       	push   $0x802e49
  801b1b:	e8 77 e6 ff ff       	call   800197 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801b20:	50                   	push   %eax
  801b21:	68 72 2e 80 00       	push   $0x802e72
  801b26:	68 86 00 00 00       	push   $0x86
  801b2b:	68 49 2e 80 00       	push   $0x802e49
  801b30:	e8 62 e6 ff ff       	call   800197 <_panic>
		panic("sys_env_set_status: %e", r);
  801b35:	50                   	push   %eax
  801b36:	68 8c 2e 80 00       	push   $0x802e8c
  801b3b:	68 89 00 00 00       	push   $0x89
  801b40:	68 49 2e 80 00       	push   $0x802e49
  801b45:	e8 4d e6 ff ff       	call   800197 <_panic>
		return r;
  801b4a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b50:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801b56:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5e                   	pop    %esi
  801b61:	5f                   	pop    %edi
  801b62:	5d                   	pop    %ebp
  801b63:	c3                   	ret    
  801b64:	89 c7                	mov    %eax,%edi
  801b66:	e9 59 fe ff ff       	jmp    8019c4 <spawn+0x342>
  801b6b:	89 c7                	mov    %eax,%edi
  801b6d:	e9 52 fe ff ff       	jmp    8019c4 <spawn+0x342>
  801b72:	89 c7                	mov    %eax,%edi
  801b74:	e9 4b fe ff ff       	jmp    8019c4 <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b79:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b80:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b83:	83 ec 08             	sub    $0x8,%esp
  801b86:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b8c:	50                   	push   %eax
  801b8d:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801b93:	e8 b9 f1 ff ff       	call   800d51 <sys_env_set_trapframe>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	78 81                	js     801b20 <spawn+0x49e>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b9f:	83 ec 08             	sub    $0x8,%esp
  801ba2:	6a 02                	push   $0x2
  801ba4:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801baa:	e8 60 f1 ff ff       	call   800d0f <sys_env_set_status>
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	0f 88 7b ff ff ff    	js     801b35 <spawn+0x4b3>
	return child;
  801bba:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bc0:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bc6:	eb 8e                	jmp    801b56 <spawn+0x4d4>
		return -E_NO_MEM;
  801bc8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801bcd:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bd3:	eb 81                	jmp    801b56 <spawn+0x4d4>
	sys_page_unmap(0, UTEMP);
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	68 00 00 40 00       	push   $0x400000
  801bdd:	6a 00                	push   $0x0
  801bdf:	e8 e9 f0 ff ff       	call   800ccd <sys_page_unmap>
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801bed:	e9 64 ff ff ff       	jmp    801b56 <spawn+0x4d4>

00801bf2 <spawnl>:
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
	va_start(vl, arg0);
  801bf7:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801bfa:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801bff:	eb 05                	jmp    801c06 <spawnl+0x14>
		argc++;
  801c01:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801c04:	89 ca                	mov    %ecx,%edx
  801c06:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c09:	83 3a 00             	cmpl   $0x0,(%edx)
  801c0c:	75 f3                	jne    801c01 <spawnl+0xf>
	const char *argv[argc+2];
  801c0e:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801c15:	89 d3                	mov    %edx,%ebx
  801c17:	83 e3 f0             	and    $0xfffffff0,%ebx
  801c1a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801c20:	89 e1                	mov    %esp,%ecx
  801c22:	29 d1                	sub    %edx,%ecx
  801c24:	39 cc                	cmp    %ecx,%esp
  801c26:	74 10                	je     801c38 <spawnl+0x46>
  801c28:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801c2e:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801c35:	00 
  801c36:	eb ec                	jmp    801c24 <spawnl+0x32>
  801c38:	89 da                	mov    %ebx,%edx
  801c3a:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801c40:	29 d4                	sub    %edx,%esp
  801c42:	85 d2                	test   %edx,%edx
  801c44:	74 05                	je     801c4b <spawnl+0x59>
  801c46:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801c4b:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801c4f:	89 da                	mov    %ebx,%edx
  801c51:	c1 ea 02             	shr    $0x2,%edx
  801c54:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c5a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c61:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801c68:	00 
	va_start(vl, arg0);
  801c69:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801c6c:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c73:	eb 0b                	jmp    801c80 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801c75:	83 c0 01             	add    $0x1,%eax
  801c78:	8b 31                	mov    (%ecx),%esi
  801c7a:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801c7d:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801c80:	39 d0                	cmp    %edx,%eax
  801c82:	75 f1                	jne    801c75 <spawnl+0x83>
	return spawn(prog, argv);
  801c84:	83 ec 08             	sub    $0x8,%esp
  801c87:	53                   	push   %ebx
  801c88:	ff 75 08             	push   0x8(%ebp)
  801c8b:	e8 f2 f9 ff ff       	call   801682 <spawn>
}
  801c90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c9d:	68 e2 2e 80 00       	push   $0x802ee2
  801ca2:	ff 75 0c             	push   0xc(%ebp)
  801ca5:	e8 a2 eb ff ff       	call   80084c <strcpy>
	return 0;
}
  801caa:	b8 00 00 00 00       	mov    $0x0,%eax
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <devsock_close>:
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	53                   	push   %ebx
  801cb5:	83 ec 10             	sub    $0x10,%esp
  801cb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cbb:	53                   	push   %ebx
  801cbc:	e8 ff 09 00 00       	call   8026c0 <pageref>
  801cc1:	89 c2                	mov    %eax,%edx
  801cc3:	83 c4 10             	add    $0x10,%esp
		return 0;
  801cc6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801ccb:	83 fa 01             	cmp    $0x1,%edx
  801cce:	74 05                	je     801cd5 <devsock_close+0x24>
}
  801cd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	ff 73 0c             	push   0xc(%ebx)
  801cdb:	e8 b7 02 00 00       	call   801f97 <nsipc_close>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	eb eb                	jmp    801cd0 <devsock_close+0x1f>

00801ce5 <devsock_write>:
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ceb:	6a 00                	push   $0x0
  801ced:	ff 75 10             	push   0x10(%ebp)
  801cf0:	ff 75 0c             	push   0xc(%ebp)
  801cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf6:	ff 70 0c             	push   0xc(%eax)
  801cf9:	e8 79 03 00 00       	call   802077 <nsipc_send>
}
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <devsock_read>:
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d06:	6a 00                	push   $0x0
  801d08:	ff 75 10             	push   0x10(%ebp)
  801d0b:	ff 75 0c             	push   0xc(%ebp)
  801d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d11:	ff 70 0c             	push   0xc(%eax)
  801d14:	e8 ef 02 00 00       	call   802008 <nsipc_recv>
}
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <fd2sockid>:
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d21:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d24:	52                   	push   %edx
  801d25:	50                   	push   %eax
  801d26:	e8 e6 f1 ff ff       	call   800f11 <fd_lookup>
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 10                	js     801d42 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801d3b:	39 08                	cmp    %ecx,(%eax)
  801d3d:	75 05                	jne    801d44 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801d3f:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    
		return -E_NOT_SUPP;
  801d44:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d49:	eb f7                	jmp    801d42 <fd2sockid+0x27>

00801d4b <alloc_sockfd>:
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	56                   	push   %esi
  801d4f:	53                   	push   %ebx
  801d50:	83 ec 1c             	sub    $0x1c,%esp
  801d53:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801d55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d58:	50                   	push   %eax
  801d59:	e8 63 f1 ff ff       	call   800ec1 <fd_alloc>
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 43                	js     801daa <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d67:	83 ec 04             	sub    $0x4,%esp
  801d6a:	68 07 04 00 00       	push   $0x407
  801d6f:	ff 75 f4             	push   -0xc(%ebp)
  801d72:	6a 00                	push   $0x0
  801d74:	e8 cf ee ff ff       	call   800c48 <sys_page_alloc>
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 28                	js     801daa <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d85:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d8b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d90:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d97:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d9a:	83 ec 0c             	sub    $0xc,%esp
  801d9d:	50                   	push   %eax
  801d9e:	e8 f7 f0 ff ff       	call   800e9a <fd2num>
  801da3:	89 c3                	mov    %eax,%ebx
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	eb 0c                	jmp    801db6 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	56                   	push   %esi
  801dae:	e8 e4 01 00 00       	call   801f97 <nsipc_close>
		return r;
  801db3:	83 c4 10             	add    $0x10,%esp
}
  801db6:	89 d8                	mov    %ebx,%eax
  801db8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <accept>:
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	e8 4e ff ff ff       	call   801d1b <fd2sockid>
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	78 1b                	js     801dec <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dd1:	83 ec 04             	sub    $0x4,%esp
  801dd4:	ff 75 10             	push   0x10(%ebp)
  801dd7:	ff 75 0c             	push   0xc(%ebp)
  801dda:	50                   	push   %eax
  801ddb:	e8 0e 01 00 00       	call   801eee <nsipc_accept>
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	85 c0                	test   %eax,%eax
  801de5:	78 05                	js     801dec <accept+0x2d>
	return alloc_sockfd(r);
  801de7:	e8 5f ff ff ff       	call   801d4b <alloc_sockfd>
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <bind>:
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	e8 1f ff ff ff       	call   801d1b <fd2sockid>
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 12                	js     801e12 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801e00:	83 ec 04             	sub    $0x4,%esp
  801e03:	ff 75 10             	push   0x10(%ebp)
  801e06:	ff 75 0c             	push   0xc(%ebp)
  801e09:	50                   	push   %eax
  801e0a:	e8 31 01 00 00       	call   801f40 <nsipc_bind>
  801e0f:	83 c4 10             	add    $0x10,%esp
}
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <shutdown>:
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	e8 f9 fe ff ff       	call   801d1b <fd2sockid>
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 0f                	js     801e35 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801e26:	83 ec 08             	sub    $0x8,%esp
  801e29:	ff 75 0c             	push   0xc(%ebp)
  801e2c:	50                   	push   %eax
  801e2d:	e8 43 01 00 00       	call   801f75 <nsipc_shutdown>
  801e32:	83 c4 10             	add    $0x10,%esp
}
  801e35:	c9                   	leave  
  801e36:	c3                   	ret    

00801e37 <connect>:
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e40:	e8 d6 fe ff ff       	call   801d1b <fd2sockid>
  801e45:	85 c0                	test   %eax,%eax
  801e47:	78 12                	js     801e5b <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801e49:	83 ec 04             	sub    $0x4,%esp
  801e4c:	ff 75 10             	push   0x10(%ebp)
  801e4f:	ff 75 0c             	push   0xc(%ebp)
  801e52:	50                   	push   %eax
  801e53:	e8 59 01 00 00       	call   801fb1 <nsipc_connect>
  801e58:	83 c4 10             	add    $0x10,%esp
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <listen>:
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e63:	8b 45 08             	mov    0x8(%ebp),%eax
  801e66:	e8 b0 fe ff ff       	call   801d1b <fd2sockid>
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 0f                	js     801e7e <listen+0x21>
	return nsipc_listen(r, backlog);
  801e6f:	83 ec 08             	sub    $0x8,%esp
  801e72:	ff 75 0c             	push   0xc(%ebp)
  801e75:	50                   	push   %eax
  801e76:	e8 6b 01 00 00       	call   801fe6 <nsipc_listen>
  801e7b:	83 c4 10             	add    $0x10,%esp
}
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <socket>:

int
socket(int domain, int type, int protocol)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e86:	ff 75 10             	push   0x10(%ebp)
  801e89:	ff 75 0c             	push   0xc(%ebp)
  801e8c:	ff 75 08             	push   0x8(%ebp)
  801e8f:	e8 41 02 00 00       	call   8020d5 <nsipc_socket>
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	85 c0                	test   %eax,%eax
  801e99:	78 05                	js     801ea0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e9b:	e8 ab fe ff ff       	call   801d4b <alloc_sockfd>
}
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	53                   	push   %ebx
  801ea6:	83 ec 04             	sub    $0x4,%esp
  801ea9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801eab:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801eb2:	74 26                	je     801eda <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801eb4:	6a 07                	push   $0x7
  801eb6:	68 00 70 80 00       	push   $0x807000
  801ebb:	53                   	push   %ebx
  801ebc:	ff 35 00 80 80 00    	push   0x808000
  801ec2:	e8 66 07 00 00       	call   80262d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ec7:	83 c4 0c             	add    $0xc,%esp
  801eca:	6a 00                	push   $0x0
  801ecc:	6a 00                	push   $0x0
  801ece:	6a 00                	push   $0x0
  801ed0:	e8 e8 06 00 00       	call   8025bd <ipc_recv>
}
  801ed5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801eda:	83 ec 0c             	sub    $0xc,%esp
  801edd:	6a 02                	push   $0x2
  801edf:	e8 9d 07 00 00       	call   802681 <ipc_find_env>
  801ee4:	a3 00 80 80 00       	mov    %eax,0x808000
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	eb c6                	jmp    801eb4 <nsipc+0x12>

00801eee <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	56                   	push   %esi
  801ef2:	53                   	push   %ebx
  801ef3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801efe:	8b 06                	mov    (%esi),%eax
  801f00:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f05:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0a:	e8 93 ff ff ff       	call   801ea2 <nsipc>
  801f0f:	89 c3                	mov    %eax,%ebx
  801f11:	85 c0                	test   %eax,%eax
  801f13:	79 09                	jns    801f1e <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801f15:	89 d8                	mov    %ebx,%eax
  801f17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f1e:	83 ec 04             	sub    $0x4,%esp
  801f21:	ff 35 10 70 80 00    	push   0x807010
  801f27:	68 00 70 80 00       	push   $0x807000
  801f2c:	ff 75 0c             	push   0xc(%ebp)
  801f2f:	e8 ae ea ff ff       	call   8009e2 <memmove>
		*addrlen = ret->ret_addrlen;
  801f34:	a1 10 70 80 00       	mov    0x807010,%eax
  801f39:	89 06                	mov    %eax,(%esi)
  801f3b:	83 c4 10             	add    $0x10,%esp
	return r;
  801f3e:	eb d5                	jmp    801f15 <nsipc_accept+0x27>

00801f40 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	53                   	push   %ebx
  801f44:	83 ec 08             	sub    $0x8,%esp
  801f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f52:	53                   	push   %ebx
  801f53:	ff 75 0c             	push   0xc(%ebp)
  801f56:	68 04 70 80 00       	push   $0x807004
  801f5b:	e8 82 ea ff ff       	call   8009e2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f60:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f66:	b8 02 00 00 00       	mov    $0x2,%eax
  801f6b:	e8 32 ff ff ff       	call   801ea2 <nsipc>
}
  801f70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f83:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f86:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f8b:	b8 03 00 00 00       	mov    $0x3,%eax
  801f90:	e8 0d ff ff ff       	call   801ea2 <nsipc>
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <nsipc_close>:

int
nsipc_close(int s)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa0:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801fa5:	b8 04 00 00 00       	mov    $0x4,%eax
  801faa:	e8 f3 fe ff ff       	call   801ea2 <nsipc>
}
  801faf:	c9                   	leave  
  801fb0:	c3                   	ret    

00801fb1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	53                   	push   %ebx
  801fb5:	83 ec 08             	sub    $0x8,%esp
  801fb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbe:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fc3:	53                   	push   %ebx
  801fc4:	ff 75 0c             	push   0xc(%ebp)
  801fc7:	68 04 70 80 00       	push   $0x807004
  801fcc:	e8 11 ea ff ff       	call   8009e2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fd1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801fd7:	b8 05 00 00 00       	mov    $0x5,%eax
  801fdc:	e8 c1 fe ff ff       	call   801ea2 <nsipc>
}
  801fe1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    

00801fe6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fec:	8b 45 08             	mov    0x8(%ebp),%eax
  801fef:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff7:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801ffc:	b8 06 00 00 00       	mov    $0x6,%eax
  802001:	e8 9c fe ff ff       	call   801ea2 <nsipc>
}
  802006:	c9                   	leave  
  802007:	c3                   	ret    

00802008 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	56                   	push   %esi
  80200c:	53                   	push   %ebx
  80200d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802010:	8b 45 08             	mov    0x8(%ebp),%eax
  802013:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802018:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80201e:	8b 45 14             	mov    0x14(%ebp),%eax
  802021:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802026:	b8 07 00 00 00       	mov    $0x7,%eax
  80202b:	e8 72 fe ff ff       	call   801ea2 <nsipc>
  802030:	89 c3                	mov    %eax,%ebx
  802032:	85 c0                	test   %eax,%eax
  802034:	78 22                	js     802058 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  802036:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80203b:	39 c6                	cmp    %eax,%esi
  80203d:	0f 4e c6             	cmovle %esi,%eax
  802040:	39 c3                	cmp    %eax,%ebx
  802042:	7f 1d                	jg     802061 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802044:	83 ec 04             	sub    $0x4,%esp
  802047:	53                   	push   %ebx
  802048:	68 00 70 80 00       	push   $0x807000
  80204d:	ff 75 0c             	push   0xc(%ebp)
  802050:	e8 8d e9 ff ff       	call   8009e2 <memmove>
  802055:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5d                   	pop    %ebp
  802060:	c3                   	ret    
		assert(r < 1600 && r <= len);
  802061:	68 ee 2e 80 00       	push   $0x802eee
  802066:	68 03 2e 80 00       	push   $0x802e03
  80206b:	6a 62                	push   $0x62
  80206d:	68 03 2f 80 00       	push   $0x802f03
  802072:	e8 20 e1 ff ff       	call   800197 <_panic>

00802077 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802077:	55                   	push   %ebp
  802078:	89 e5                	mov    %esp,%ebp
  80207a:	53                   	push   %ebx
  80207b:	83 ec 04             	sub    $0x4,%esp
  80207e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802081:	8b 45 08             	mov    0x8(%ebp),%eax
  802084:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802089:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80208f:	7f 2e                	jg     8020bf <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802091:	83 ec 04             	sub    $0x4,%esp
  802094:	53                   	push   %ebx
  802095:	ff 75 0c             	push   0xc(%ebp)
  802098:	68 0c 70 80 00       	push   $0x80700c
  80209d:	e8 40 e9 ff ff       	call   8009e2 <memmove>
	nsipcbuf.send.req_size = size;
  8020a2:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8020a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ab:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8020b0:	b8 08 00 00 00       	mov    $0x8,%eax
  8020b5:	e8 e8 fd ff ff       	call   801ea2 <nsipc>
}
  8020ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    
	assert(size < 1600);
  8020bf:	68 0f 2f 80 00       	push   $0x802f0f
  8020c4:	68 03 2e 80 00       	push   $0x802e03
  8020c9:	6a 6d                	push   $0x6d
  8020cb:	68 03 2f 80 00       	push   $0x802f03
  8020d0:	e8 c2 e0 ff ff       	call   800197 <_panic>

008020d5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020db:	8b 45 08             	mov    0x8(%ebp),%eax
  8020de:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8020e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e6:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8020eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ee:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8020f3:	b8 09 00 00 00       	mov    $0x9,%eax
  8020f8:	e8 a5 fd ff ff       	call   801ea2 <nsipc>
}
  8020fd:	c9                   	leave  
  8020fe:	c3                   	ret    

008020ff <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802107:	83 ec 0c             	sub    $0xc,%esp
  80210a:	ff 75 08             	push   0x8(%ebp)
  80210d:	e8 98 ed ff ff       	call   800eaa <fd2data>
  802112:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802114:	83 c4 08             	add    $0x8,%esp
  802117:	68 1b 2f 80 00       	push   $0x802f1b
  80211c:	53                   	push   %ebx
  80211d:	e8 2a e7 ff ff       	call   80084c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802122:	8b 46 04             	mov    0x4(%esi),%eax
  802125:	2b 06                	sub    (%esi),%eax
  802127:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80212d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802134:	00 00 00 
	stat->st_dev = &devpipe;
  802137:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80213e:	30 80 00 
	return 0;
}
  802141:	b8 00 00 00 00       	mov    $0x0,%eax
  802146:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802149:	5b                   	pop    %ebx
  80214a:	5e                   	pop    %esi
  80214b:	5d                   	pop    %ebp
  80214c:	c3                   	ret    

0080214d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
  802150:	53                   	push   %ebx
  802151:	83 ec 0c             	sub    $0xc,%esp
  802154:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802157:	53                   	push   %ebx
  802158:	6a 00                	push   $0x0
  80215a:	e8 6e eb ff ff       	call   800ccd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80215f:	89 1c 24             	mov    %ebx,(%esp)
  802162:	e8 43 ed ff ff       	call   800eaa <fd2data>
  802167:	83 c4 08             	add    $0x8,%esp
  80216a:	50                   	push   %eax
  80216b:	6a 00                	push   $0x0
  80216d:	e8 5b eb ff ff       	call   800ccd <sys_page_unmap>
}
  802172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802175:	c9                   	leave  
  802176:	c3                   	ret    

00802177 <_pipeisclosed>:
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	57                   	push   %edi
  80217b:	56                   	push   %esi
  80217c:	53                   	push   %ebx
  80217d:	83 ec 1c             	sub    $0x1c,%esp
  802180:	89 c7                	mov    %eax,%edi
  802182:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802184:	a1 00 40 80 00       	mov    0x804000,%eax
  802189:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80218c:	83 ec 0c             	sub    $0xc,%esp
  80218f:	57                   	push   %edi
  802190:	e8 2b 05 00 00       	call   8026c0 <pageref>
  802195:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802198:	89 34 24             	mov    %esi,(%esp)
  80219b:	e8 20 05 00 00       	call   8026c0 <pageref>
		nn = thisenv->env_runs;
  8021a0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8021a6:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8021a9:	83 c4 10             	add    $0x10,%esp
  8021ac:	39 cb                	cmp    %ecx,%ebx
  8021ae:	74 1b                	je     8021cb <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8021b0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021b3:	75 cf                	jne    802184 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021b5:	8b 42 68             	mov    0x68(%edx),%eax
  8021b8:	6a 01                	push   $0x1
  8021ba:	50                   	push   %eax
  8021bb:	53                   	push   %ebx
  8021bc:	68 22 2f 80 00       	push   $0x802f22
  8021c1:	e8 ac e0 ff ff       	call   800272 <cprintf>
  8021c6:	83 c4 10             	add    $0x10,%esp
  8021c9:	eb b9                	jmp    802184 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8021cb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021ce:	0f 94 c0             	sete   %al
  8021d1:	0f b6 c0             	movzbl %al,%eax
}
  8021d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d7:	5b                   	pop    %ebx
  8021d8:	5e                   	pop    %esi
  8021d9:	5f                   	pop    %edi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    

008021dc <devpipe_write>:
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	57                   	push   %edi
  8021e0:	56                   	push   %esi
  8021e1:	53                   	push   %ebx
  8021e2:	83 ec 28             	sub    $0x28,%esp
  8021e5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8021e8:	56                   	push   %esi
  8021e9:	e8 bc ec ff ff       	call   800eaa <fd2data>
  8021ee:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021f0:	83 c4 10             	add    $0x10,%esp
  8021f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8021f8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021fb:	75 09                	jne    802206 <devpipe_write+0x2a>
	return i;
  8021fd:	89 f8                	mov    %edi,%eax
  8021ff:	eb 23                	jmp    802224 <devpipe_write+0x48>
			sys_yield();
  802201:	e8 23 ea ff ff       	call   800c29 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802206:	8b 43 04             	mov    0x4(%ebx),%eax
  802209:	8b 0b                	mov    (%ebx),%ecx
  80220b:	8d 51 20             	lea    0x20(%ecx),%edx
  80220e:	39 d0                	cmp    %edx,%eax
  802210:	72 1a                	jb     80222c <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802212:	89 da                	mov    %ebx,%edx
  802214:	89 f0                	mov    %esi,%eax
  802216:	e8 5c ff ff ff       	call   802177 <_pipeisclosed>
  80221b:	85 c0                	test   %eax,%eax
  80221d:	74 e2                	je     802201 <devpipe_write+0x25>
				return 0;
  80221f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802224:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802227:	5b                   	pop    %ebx
  802228:	5e                   	pop    %esi
  802229:	5f                   	pop    %edi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80222c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80222f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802233:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802236:	89 c2                	mov    %eax,%edx
  802238:	c1 fa 1f             	sar    $0x1f,%edx
  80223b:	89 d1                	mov    %edx,%ecx
  80223d:	c1 e9 1b             	shr    $0x1b,%ecx
  802240:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802243:	83 e2 1f             	and    $0x1f,%edx
  802246:	29 ca                	sub    %ecx,%edx
  802248:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80224c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802250:	83 c0 01             	add    $0x1,%eax
  802253:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802256:	83 c7 01             	add    $0x1,%edi
  802259:	eb 9d                	jmp    8021f8 <devpipe_write+0x1c>

0080225b <devpipe_read>:
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	57                   	push   %edi
  80225f:	56                   	push   %esi
  802260:	53                   	push   %ebx
  802261:	83 ec 18             	sub    $0x18,%esp
  802264:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802267:	57                   	push   %edi
  802268:	e8 3d ec ff ff       	call   800eaa <fd2data>
  80226d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80226f:	83 c4 10             	add    $0x10,%esp
  802272:	be 00 00 00 00       	mov    $0x0,%esi
  802277:	3b 75 10             	cmp    0x10(%ebp),%esi
  80227a:	75 13                	jne    80228f <devpipe_read+0x34>
	return i;
  80227c:	89 f0                	mov    %esi,%eax
  80227e:	eb 02                	jmp    802282 <devpipe_read+0x27>
				return i;
  802280:	89 f0                	mov    %esi,%eax
}
  802282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802285:	5b                   	pop    %ebx
  802286:	5e                   	pop    %esi
  802287:	5f                   	pop    %edi
  802288:	5d                   	pop    %ebp
  802289:	c3                   	ret    
			sys_yield();
  80228a:	e8 9a e9 ff ff       	call   800c29 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80228f:	8b 03                	mov    (%ebx),%eax
  802291:	3b 43 04             	cmp    0x4(%ebx),%eax
  802294:	75 18                	jne    8022ae <devpipe_read+0x53>
			if (i > 0)
  802296:	85 f6                	test   %esi,%esi
  802298:	75 e6                	jne    802280 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80229a:	89 da                	mov    %ebx,%edx
  80229c:	89 f8                	mov    %edi,%eax
  80229e:	e8 d4 fe ff ff       	call   802177 <_pipeisclosed>
  8022a3:	85 c0                	test   %eax,%eax
  8022a5:	74 e3                	je     80228a <devpipe_read+0x2f>
				return 0;
  8022a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ac:	eb d4                	jmp    802282 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022ae:	99                   	cltd   
  8022af:	c1 ea 1b             	shr    $0x1b,%edx
  8022b2:	01 d0                	add    %edx,%eax
  8022b4:	83 e0 1f             	and    $0x1f,%eax
  8022b7:	29 d0                	sub    %edx,%eax
  8022b9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8022be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022c1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8022c4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8022c7:	83 c6 01             	add    $0x1,%esi
  8022ca:	eb ab                	jmp    802277 <devpipe_read+0x1c>

008022cc <pipe>:
{
  8022cc:	55                   	push   %ebp
  8022cd:	89 e5                	mov    %esp,%ebp
  8022cf:	56                   	push   %esi
  8022d0:	53                   	push   %ebx
  8022d1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8022d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d7:	50                   	push   %eax
  8022d8:	e8 e4 eb ff ff       	call   800ec1 <fd_alloc>
  8022dd:	89 c3                	mov    %eax,%ebx
  8022df:	83 c4 10             	add    $0x10,%esp
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	0f 88 23 01 00 00    	js     80240d <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ea:	83 ec 04             	sub    $0x4,%esp
  8022ed:	68 07 04 00 00       	push   $0x407
  8022f2:	ff 75 f4             	push   -0xc(%ebp)
  8022f5:	6a 00                	push   $0x0
  8022f7:	e8 4c e9 ff ff       	call   800c48 <sys_page_alloc>
  8022fc:	89 c3                	mov    %eax,%ebx
  8022fe:	83 c4 10             	add    $0x10,%esp
  802301:	85 c0                	test   %eax,%eax
  802303:	0f 88 04 01 00 00    	js     80240d <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802309:	83 ec 0c             	sub    $0xc,%esp
  80230c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80230f:	50                   	push   %eax
  802310:	e8 ac eb ff ff       	call   800ec1 <fd_alloc>
  802315:	89 c3                	mov    %eax,%ebx
  802317:	83 c4 10             	add    $0x10,%esp
  80231a:	85 c0                	test   %eax,%eax
  80231c:	0f 88 db 00 00 00    	js     8023fd <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802322:	83 ec 04             	sub    $0x4,%esp
  802325:	68 07 04 00 00       	push   $0x407
  80232a:	ff 75 f0             	push   -0x10(%ebp)
  80232d:	6a 00                	push   $0x0
  80232f:	e8 14 e9 ff ff       	call   800c48 <sys_page_alloc>
  802334:	89 c3                	mov    %eax,%ebx
  802336:	83 c4 10             	add    $0x10,%esp
  802339:	85 c0                	test   %eax,%eax
  80233b:	0f 88 bc 00 00 00    	js     8023fd <pipe+0x131>
	va = fd2data(fd0);
  802341:	83 ec 0c             	sub    $0xc,%esp
  802344:	ff 75 f4             	push   -0xc(%ebp)
  802347:	e8 5e eb ff ff       	call   800eaa <fd2data>
  80234c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80234e:	83 c4 0c             	add    $0xc,%esp
  802351:	68 07 04 00 00       	push   $0x407
  802356:	50                   	push   %eax
  802357:	6a 00                	push   $0x0
  802359:	e8 ea e8 ff ff       	call   800c48 <sys_page_alloc>
  80235e:	89 c3                	mov    %eax,%ebx
  802360:	83 c4 10             	add    $0x10,%esp
  802363:	85 c0                	test   %eax,%eax
  802365:	0f 88 82 00 00 00    	js     8023ed <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80236b:	83 ec 0c             	sub    $0xc,%esp
  80236e:	ff 75 f0             	push   -0x10(%ebp)
  802371:	e8 34 eb ff ff       	call   800eaa <fd2data>
  802376:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80237d:	50                   	push   %eax
  80237e:	6a 00                	push   $0x0
  802380:	56                   	push   %esi
  802381:	6a 00                	push   $0x0
  802383:	e8 03 e9 ff ff       	call   800c8b <sys_page_map>
  802388:	89 c3                	mov    %eax,%ebx
  80238a:	83 c4 20             	add    $0x20,%esp
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 4e                	js     8023df <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802391:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802396:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802399:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80239b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80239e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8023a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8023a8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8023aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023ad:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8023b4:	83 ec 0c             	sub    $0xc,%esp
  8023b7:	ff 75 f4             	push   -0xc(%ebp)
  8023ba:	e8 db ea ff ff       	call   800e9a <fd2num>
  8023bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023c2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023c4:	83 c4 04             	add    $0x4,%esp
  8023c7:	ff 75 f0             	push   -0x10(%ebp)
  8023ca:	e8 cb ea ff ff       	call   800e9a <fd2num>
  8023cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023d2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023d5:	83 c4 10             	add    $0x10,%esp
  8023d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023dd:	eb 2e                	jmp    80240d <pipe+0x141>
	sys_page_unmap(0, va);
  8023df:	83 ec 08             	sub    $0x8,%esp
  8023e2:	56                   	push   %esi
  8023e3:	6a 00                	push   $0x0
  8023e5:	e8 e3 e8 ff ff       	call   800ccd <sys_page_unmap>
  8023ea:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8023ed:	83 ec 08             	sub    $0x8,%esp
  8023f0:	ff 75 f0             	push   -0x10(%ebp)
  8023f3:	6a 00                	push   $0x0
  8023f5:	e8 d3 e8 ff ff       	call   800ccd <sys_page_unmap>
  8023fa:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8023fd:	83 ec 08             	sub    $0x8,%esp
  802400:	ff 75 f4             	push   -0xc(%ebp)
  802403:	6a 00                	push   $0x0
  802405:	e8 c3 e8 ff ff       	call   800ccd <sys_page_unmap>
  80240a:	83 c4 10             	add    $0x10,%esp
}
  80240d:	89 d8                	mov    %ebx,%eax
  80240f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802412:	5b                   	pop    %ebx
  802413:	5e                   	pop    %esi
  802414:	5d                   	pop    %ebp
  802415:	c3                   	ret    

00802416 <pipeisclosed>:
{
  802416:	55                   	push   %ebp
  802417:	89 e5                	mov    %esp,%ebp
  802419:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80241c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80241f:	50                   	push   %eax
  802420:	ff 75 08             	push   0x8(%ebp)
  802423:	e8 e9 ea ff ff       	call   800f11 <fd_lookup>
  802428:	83 c4 10             	add    $0x10,%esp
  80242b:	85 c0                	test   %eax,%eax
  80242d:	78 18                	js     802447 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80242f:	83 ec 0c             	sub    $0xc,%esp
  802432:	ff 75 f4             	push   -0xc(%ebp)
  802435:	e8 70 ea ff ff       	call   800eaa <fd2data>
  80243a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80243c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80243f:	e8 33 fd ff ff       	call   802177 <_pipeisclosed>
  802444:	83 c4 10             	add    $0x10,%esp
}
  802447:	c9                   	leave  
  802448:	c3                   	ret    

00802449 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802449:	b8 00 00 00 00       	mov    $0x0,%eax
  80244e:	c3                   	ret    

0080244f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80244f:	55                   	push   %ebp
  802450:	89 e5                	mov    %esp,%ebp
  802452:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802455:	68 3a 2f 80 00       	push   $0x802f3a
  80245a:	ff 75 0c             	push   0xc(%ebp)
  80245d:	e8 ea e3 ff ff       	call   80084c <strcpy>
	return 0;
}
  802462:	b8 00 00 00 00       	mov    $0x0,%eax
  802467:	c9                   	leave  
  802468:	c3                   	ret    

00802469 <devcons_write>:
{
  802469:	55                   	push   %ebp
  80246a:	89 e5                	mov    %esp,%ebp
  80246c:	57                   	push   %edi
  80246d:	56                   	push   %esi
  80246e:	53                   	push   %ebx
  80246f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802475:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80247a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802480:	eb 2e                	jmp    8024b0 <devcons_write+0x47>
		m = n - tot;
  802482:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802485:	29 f3                	sub    %esi,%ebx
  802487:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80248c:	39 c3                	cmp    %eax,%ebx
  80248e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802491:	83 ec 04             	sub    $0x4,%esp
  802494:	53                   	push   %ebx
  802495:	89 f0                	mov    %esi,%eax
  802497:	03 45 0c             	add    0xc(%ebp),%eax
  80249a:	50                   	push   %eax
  80249b:	57                   	push   %edi
  80249c:	e8 41 e5 ff ff       	call   8009e2 <memmove>
		sys_cputs(buf, m);
  8024a1:	83 c4 08             	add    $0x8,%esp
  8024a4:	53                   	push   %ebx
  8024a5:	57                   	push   %edi
  8024a6:	e8 e1 e6 ff ff       	call   800b8c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8024ab:	01 de                	add    %ebx,%esi
  8024ad:	83 c4 10             	add    $0x10,%esp
  8024b0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024b3:	72 cd                	jb     802482 <devcons_write+0x19>
}
  8024b5:	89 f0                	mov    %esi,%eax
  8024b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024ba:	5b                   	pop    %ebx
  8024bb:	5e                   	pop    %esi
  8024bc:	5f                   	pop    %edi
  8024bd:	5d                   	pop    %ebp
  8024be:	c3                   	ret    

008024bf <devcons_read>:
{
  8024bf:	55                   	push   %ebp
  8024c0:	89 e5                	mov    %esp,%ebp
  8024c2:	83 ec 08             	sub    $0x8,%esp
  8024c5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8024ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024ce:	75 07                	jne    8024d7 <devcons_read+0x18>
  8024d0:	eb 1f                	jmp    8024f1 <devcons_read+0x32>
		sys_yield();
  8024d2:	e8 52 e7 ff ff       	call   800c29 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8024d7:	e8 ce e6 ff ff       	call   800baa <sys_cgetc>
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	74 f2                	je     8024d2 <devcons_read+0x13>
	if (c < 0)
  8024e0:	78 0f                	js     8024f1 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8024e2:	83 f8 04             	cmp    $0x4,%eax
  8024e5:	74 0c                	je     8024f3 <devcons_read+0x34>
	*(char*)vbuf = c;
  8024e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024ea:	88 02                	mov    %al,(%edx)
	return 1;
  8024ec:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8024f1:	c9                   	leave  
  8024f2:	c3                   	ret    
		return 0;
  8024f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f8:	eb f7                	jmp    8024f1 <devcons_read+0x32>

008024fa <cputchar>:
{
  8024fa:	55                   	push   %ebp
  8024fb:	89 e5                	mov    %esp,%ebp
  8024fd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802500:	8b 45 08             	mov    0x8(%ebp),%eax
  802503:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802506:	6a 01                	push   $0x1
  802508:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80250b:	50                   	push   %eax
  80250c:	e8 7b e6 ff ff       	call   800b8c <sys_cputs>
}
  802511:	83 c4 10             	add    $0x10,%esp
  802514:	c9                   	leave  
  802515:	c3                   	ret    

00802516 <getchar>:
{
  802516:	55                   	push   %ebp
  802517:	89 e5                	mov    %esp,%ebp
  802519:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80251c:	6a 01                	push   $0x1
  80251e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802521:	50                   	push   %eax
  802522:	6a 00                	push   $0x0
  802524:	e8 51 ec ff ff       	call   80117a <read>
	if (r < 0)
  802529:	83 c4 10             	add    $0x10,%esp
  80252c:	85 c0                	test   %eax,%eax
  80252e:	78 06                	js     802536 <getchar+0x20>
	if (r < 1)
  802530:	74 06                	je     802538 <getchar+0x22>
	return c;
  802532:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802536:	c9                   	leave  
  802537:	c3                   	ret    
		return -E_EOF;
  802538:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80253d:	eb f7                	jmp    802536 <getchar+0x20>

0080253f <iscons>:
{
  80253f:	55                   	push   %ebp
  802540:	89 e5                	mov    %esp,%ebp
  802542:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802548:	50                   	push   %eax
  802549:	ff 75 08             	push   0x8(%ebp)
  80254c:	e8 c0 e9 ff ff       	call   800f11 <fd_lookup>
  802551:	83 c4 10             	add    $0x10,%esp
  802554:	85 c0                	test   %eax,%eax
  802556:	78 11                	js     802569 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802558:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802561:	39 10                	cmp    %edx,(%eax)
  802563:	0f 94 c0             	sete   %al
  802566:	0f b6 c0             	movzbl %al,%eax
}
  802569:	c9                   	leave  
  80256a:	c3                   	ret    

0080256b <opencons>:
{
  80256b:	55                   	push   %ebp
  80256c:	89 e5                	mov    %esp,%ebp
  80256e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802571:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802574:	50                   	push   %eax
  802575:	e8 47 e9 ff ff       	call   800ec1 <fd_alloc>
  80257a:	83 c4 10             	add    $0x10,%esp
  80257d:	85 c0                	test   %eax,%eax
  80257f:	78 3a                	js     8025bb <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802581:	83 ec 04             	sub    $0x4,%esp
  802584:	68 07 04 00 00       	push   $0x407
  802589:	ff 75 f4             	push   -0xc(%ebp)
  80258c:	6a 00                	push   $0x0
  80258e:	e8 b5 e6 ff ff       	call   800c48 <sys_page_alloc>
  802593:	83 c4 10             	add    $0x10,%esp
  802596:	85 c0                	test   %eax,%eax
  802598:	78 21                	js     8025bb <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80259a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80259d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8025a3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025af:	83 ec 0c             	sub    $0xc,%esp
  8025b2:	50                   	push   %eax
  8025b3:	e8 e2 e8 ff ff       	call   800e9a <fd2num>
  8025b8:	83 c4 10             	add    $0x10,%esp
}
  8025bb:	c9                   	leave  
  8025bc:	c3                   	ret    

008025bd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025bd:	55                   	push   %ebp
  8025be:	89 e5                	mov    %esp,%ebp
  8025c0:	56                   	push   %esi
  8025c1:	53                   	push   %ebx
  8025c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8025c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8025cb:	85 c0                	test   %eax,%eax
  8025cd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8025d2:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8025d5:	83 ec 0c             	sub    $0xc,%esp
  8025d8:	50                   	push   %eax
  8025d9:	e8 1a e8 ff ff       	call   800df8 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8025de:	83 c4 10             	add    $0x10,%esp
  8025e1:	85 f6                	test   %esi,%esi
  8025e3:	74 17                	je     8025fc <ipc_recv+0x3f>
  8025e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8025ea:	85 c0                	test   %eax,%eax
  8025ec:	78 0c                	js     8025fa <ipc_recv+0x3d>
  8025ee:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8025f4:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8025fa:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8025fc:	85 db                	test   %ebx,%ebx
  8025fe:	74 17                	je     802617 <ipc_recv+0x5a>
  802600:	ba 00 00 00 00       	mov    $0x0,%edx
  802605:	85 c0                	test   %eax,%eax
  802607:	78 0c                	js     802615 <ipc_recv+0x58>
  802609:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80260f:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  802615:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802617:	85 c0                	test   %eax,%eax
  802619:	78 0b                	js     802626 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  80261b:	a1 00 40 80 00       	mov    0x804000,%eax
  802620:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  802626:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802629:	5b                   	pop    %ebx
  80262a:	5e                   	pop    %esi
  80262b:	5d                   	pop    %ebp
  80262c:	c3                   	ret    

0080262d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80262d:	55                   	push   %ebp
  80262e:	89 e5                	mov    %esp,%ebp
  802630:	57                   	push   %edi
  802631:	56                   	push   %esi
  802632:	53                   	push   %ebx
  802633:	83 ec 0c             	sub    $0xc,%esp
  802636:	8b 7d 08             	mov    0x8(%ebp),%edi
  802639:	8b 75 0c             	mov    0xc(%ebp),%esi
  80263c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80263f:	85 db                	test   %ebx,%ebx
  802641:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802646:	0f 44 d8             	cmove  %eax,%ebx
  802649:	eb 05                	jmp    802650 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80264b:	e8 d9 e5 ff ff       	call   800c29 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802650:	ff 75 14             	push   0x14(%ebp)
  802653:	53                   	push   %ebx
  802654:	56                   	push   %esi
  802655:	57                   	push   %edi
  802656:	e8 7a e7 ff ff       	call   800dd5 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80265b:	83 c4 10             	add    $0x10,%esp
  80265e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802661:	74 e8                	je     80264b <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802663:	85 c0                	test   %eax,%eax
  802665:	78 08                	js     80266f <ipc_send+0x42>
	}while (r<0);

}
  802667:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80266a:	5b                   	pop    %ebx
  80266b:	5e                   	pop    %esi
  80266c:	5f                   	pop    %edi
  80266d:	5d                   	pop    %ebp
  80266e:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80266f:	50                   	push   %eax
  802670:	68 46 2f 80 00       	push   $0x802f46
  802675:	6a 3d                	push   $0x3d
  802677:	68 5a 2f 80 00       	push   $0x802f5a
  80267c:	e8 16 db ff ff       	call   800197 <_panic>

00802681 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802681:	55                   	push   %ebp
  802682:	89 e5                	mov    %esp,%ebp
  802684:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802687:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80268c:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802692:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802698:	8b 52 60             	mov    0x60(%edx),%edx
  80269b:	39 ca                	cmp    %ecx,%edx
  80269d:	74 11                	je     8026b0 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  80269f:	83 c0 01             	add    $0x1,%eax
  8026a2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026a7:	75 e3                	jne    80268c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8026a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8026ae:	eb 0e                	jmp    8026be <ipc_find_env+0x3d>
			return envs[i].env_id;
  8026b0:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8026b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026bb:	8b 40 58             	mov    0x58(%eax),%eax
}
  8026be:	5d                   	pop    %ebp
  8026bf:	c3                   	ret    

008026c0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026c0:	55                   	push   %ebp
  8026c1:	89 e5                	mov    %esp,%ebp
  8026c3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026c6:	89 c2                	mov    %eax,%edx
  8026c8:	c1 ea 16             	shr    $0x16,%edx
  8026cb:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8026d2:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8026d7:	f6 c1 01             	test   $0x1,%cl
  8026da:	74 1c                	je     8026f8 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8026dc:	c1 e8 0c             	shr    $0xc,%eax
  8026df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026e6:	a8 01                	test   $0x1,%al
  8026e8:	74 0e                	je     8026f8 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026ea:	c1 e8 0c             	shr    $0xc,%eax
  8026ed:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8026f4:	ef 
  8026f5:	0f b7 d2             	movzwl %dx,%edx
}
  8026f8:	89 d0                	mov    %edx,%eax
  8026fa:	5d                   	pop    %ebp
  8026fb:	c3                   	ret    
  8026fc:	66 90                	xchg   %ax,%ax
  8026fe:	66 90                	xchg   %ax,%ax

00802700 <__udivdi3>:
  802700:	f3 0f 1e fb          	endbr32 
  802704:	55                   	push   %ebp
  802705:	57                   	push   %edi
  802706:	56                   	push   %esi
  802707:	53                   	push   %ebx
  802708:	83 ec 1c             	sub    $0x1c,%esp
  80270b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80270f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802713:	8b 74 24 34          	mov    0x34(%esp),%esi
  802717:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80271b:	85 c0                	test   %eax,%eax
  80271d:	75 19                	jne    802738 <__udivdi3+0x38>
  80271f:	39 f3                	cmp    %esi,%ebx
  802721:	76 4d                	jbe    802770 <__udivdi3+0x70>
  802723:	31 ff                	xor    %edi,%edi
  802725:	89 e8                	mov    %ebp,%eax
  802727:	89 f2                	mov    %esi,%edx
  802729:	f7 f3                	div    %ebx
  80272b:	89 fa                	mov    %edi,%edx
  80272d:	83 c4 1c             	add    $0x1c,%esp
  802730:	5b                   	pop    %ebx
  802731:	5e                   	pop    %esi
  802732:	5f                   	pop    %edi
  802733:	5d                   	pop    %ebp
  802734:	c3                   	ret    
  802735:	8d 76 00             	lea    0x0(%esi),%esi
  802738:	39 f0                	cmp    %esi,%eax
  80273a:	76 14                	jbe    802750 <__udivdi3+0x50>
  80273c:	31 ff                	xor    %edi,%edi
  80273e:	31 c0                	xor    %eax,%eax
  802740:	89 fa                	mov    %edi,%edx
  802742:	83 c4 1c             	add    $0x1c,%esp
  802745:	5b                   	pop    %ebx
  802746:	5e                   	pop    %esi
  802747:	5f                   	pop    %edi
  802748:	5d                   	pop    %ebp
  802749:	c3                   	ret    
  80274a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802750:	0f bd f8             	bsr    %eax,%edi
  802753:	83 f7 1f             	xor    $0x1f,%edi
  802756:	75 48                	jne    8027a0 <__udivdi3+0xa0>
  802758:	39 f0                	cmp    %esi,%eax
  80275a:	72 06                	jb     802762 <__udivdi3+0x62>
  80275c:	31 c0                	xor    %eax,%eax
  80275e:	39 eb                	cmp    %ebp,%ebx
  802760:	77 de                	ja     802740 <__udivdi3+0x40>
  802762:	b8 01 00 00 00       	mov    $0x1,%eax
  802767:	eb d7                	jmp    802740 <__udivdi3+0x40>
  802769:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802770:	89 d9                	mov    %ebx,%ecx
  802772:	85 db                	test   %ebx,%ebx
  802774:	75 0b                	jne    802781 <__udivdi3+0x81>
  802776:	b8 01 00 00 00       	mov    $0x1,%eax
  80277b:	31 d2                	xor    %edx,%edx
  80277d:	f7 f3                	div    %ebx
  80277f:	89 c1                	mov    %eax,%ecx
  802781:	31 d2                	xor    %edx,%edx
  802783:	89 f0                	mov    %esi,%eax
  802785:	f7 f1                	div    %ecx
  802787:	89 c6                	mov    %eax,%esi
  802789:	89 e8                	mov    %ebp,%eax
  80278b:	89 f7                	mov    %esi,%edi
  80278d:	f7 f1                	div    %ecx
  80278f:	89 fa                	mov    %edi,%edx
  802791:	83 c4 1c             	add    $0x1c,%esp
  802794:	5b                   	pop    %ebx
  802795:	5e                   	pop    %esi
  802796:	5f                   	pop    %edi
  802797:	5d                   	pop    %ebp
  802798:	c3                   	ret    
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	89 f9                	mov    %edi,%ecx
  8027a2:	ba 20 00 00 00       	mov    $0x20,%edx
  8027a7:	29 fa                	sub    %edi,%edx
  8027a9:	d3 e0                	shl    %cl,%eax
  8027ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027af:	89 d1                	mov    %edx,%ecx
  8027b1:	89 d8                	mov    %ebx,%eax
  8027b3:	d3 e8                	shr    %cl,%eax
  8027b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8027b9:	09 c1                	or     %eax,%ecx
  8027bb:	89 f0                	mov    %esi,%eax
  8027bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027c1:	89 f9                	mov    %edi,%ecx
  8027c3:	d3 e3                	shl    %cl,%ebx
  8027c5:	89 d1                	mov    %edx,%ecx
  8027c7:	d3 e8                	shr    %cl,%eax
  8027c9:	89 f9                	mov    %edi,%ecx
  8027cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8027cf:	89 eb                	mov    %ebp,%ebx
  8027d1:	d3 e6                	shl    %cl,%esi
  8027d3:	89 d1                	mov    %edx,%ecx
  8027d5:	d3 eb                	shr    %cl,%ebx
  8027d7:	09 f3                	or     %esi,%ebx
  8027d9:	89 c6                	mov    %eax,%esi
  8027db:	89 f2                	mov    %esi,%edx
  8027dd:	89 d8                	mov    %ebx,%eax
  8027df:	f7 74 24 08          	divl   0x8(%esp)
  8027e3:	89 d6                	mov    %edx,%esi
  8027e5:	89 c3                	mov    %eax,%ebx
  8027e7:	f7 64 24 0c          	mull   0xc(%esp)
  8027eb:	39 d6                	cmp    %edx,%esi
  8027ed:	72 19                	jb     802808 <__udivdi3+0x108>
  8027ef:	89 f9                	mov    %edi,%ecx
  8027f1:	d3 e5                	shl    %cl,%ebp
  8027f3:	39 c5                	cmp    %eax,%ebp
  8027f5:	73 04                	jae    8027fb <__udivdi3+0xfb>
  8027f7:	39 d6                	cmp    %edx,%esi
  8027f9:	74 0d                	je     802808 <__udivdi3+0x108>
  8027fb:	89 d8                	mov    %ebx,%eax
  8027fd:	31 ff                	xor    %edi,%edi
  8027ff:	e9 3c ff ff ff       	jmp    802740 <__udivdi3+0x40>
  802804:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802808:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80280b:	31 ff                	xor    %edi,%edi
  80280d:	e9 2e ff ff ff       	jmp    802740 <__udivdi3+0x40>
  802812:	66 90                	xchg   %ax,%ax
  802814:	66 90                	xchg   %ax,%ax
  802816:	66 90                	xchg   %ax,%ax
  802818:	66 90                	xchg   %ax,%ax
  80281a:	66 90                	xchg   %ax,%ax
  80281c:	66 90                	xchg   %ax,%ax
  80281e:	66 90                	xchg   %ax,%ax

00802820 <__umoddi3>:
  802820:	f3 0f 1e fb          	endbr32 
  802824:	55                   	push   %ebp
  802825:	57                   	push   %edi
  802826:	56                   	push   %esi
  802827:	53                   	push   %ebx
  802828:	83 ec 1c             	sub    $0x1c,%esp
  80282b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80282f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802833:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802837:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80283b:	89 f0                	mov    %esi,%eax
  80283d:	89 da                	mov    %ebx,%edx
  80283f:	85 ff                	test   %edi,%edi
  802841:	75 15                	jne    802858 <__umoddi3+0x38>
  802843:	39 dd                	cmp    %ebx,%ebp
  802845:	76 39                	jbe    802880 <__umoddi3+0x60>
  802847:	f7 f5                	div    %ebp
  802849:	89 d0                	mov    %edx,%eax
  80284b:	31 d2                	xor    %edx,%edx
  80284d:	83 c4 1c             	add    $0x1c,%esp
  802850:	5b                   	pop    %ebx
  802851:	5e                   	pop    %esi
  802852:	5f                   	pop    %edi
  802853:	5d                   	pop    %ebp
  802854:	c3                   	ret    
  802855:	8d 76 00             	lea    0x0(%esi),%esi
  802858:	39 df                	cmp    %ebx,%edi
  80285a:	77 f1                	ja     80284d <__umoddi3+0x2d>
  80285c:	0f bd cf             	bsr    %edi,%ecx
  80285f:	83 f1 1f             	xor    $0x1f,%ecx
  802862:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802866:	75 40                	jne    8028a8 <__umoddi3+0x88>
  802868:	39 df                	cmp    %ebx,%edi
  80286a:	72 04                	jb     802870 <__umoddi3+0x50>
  80286c:	39 f5                	cmp    %esi,%ebp
  80286e:	77 dd                	ja     80284d <__umoddi3+0x2d>
  802870:	89 da                	mov    %ebx,%edx
  802872:	89 f0                	mov    %esi,%eax
  802874:	29 e8                	sub    %ebp,%eax
  802876:	19 fa                	sbb    %edi,%edx
  802878:	eb d3                	jmp    80284d <__umoddi3+0x2d>
  80287a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802880:	89 e9                	mov    %ebp,%ecx
  802882:	85 ed                	test   %ebp,%ebp
  802884:	75 0b                	jne    802891 <__umoddi3+0x71>
  802886:	b8 01 00 00 00       	mov    $0x1,%eax
  80288b:	31 d2                	xor    %edx,%edx
  80288d:	f7 f5                	div    %ebp
  80288f:	89 c1                	mov    %eax,%ecx
  802891:	89 d8                	mov    %ebx,%eax
  802893:	31 d2                	xor    %edx,%edx
  802895:	f7 f1                	div    %ecx
  802897:	89 f0                	mov    %esi,%eax
  802899:	f7 f1                	div    %ecx
  80289b:	89 d0                	mov    %edx,%eax
  80289d:	31 d2                	xor    %edx,%edx
  80289f:	eb ac                	jmp    80284d <__umoddi3+0x2d>
  8028a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8028ac:	ba 20 00 00 00       	mov    $0x20,%edx
  8028b1:	29 c2                	sub    %eax,%edx
  8028b3:	89 c1                	mov    %eax,%ecx
  8028b5:	89 e8                	mov    %ebp,%eax
  8028b7:	d3 e7                	shl    %cl,%edi
  8028b9:	89 d1                	mov    %edx,%ecx
  8028bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8028bf:	d3 e8                	shr    %cl,%eax
  8028c1:	89 c1                	mov    %eax,%ecx
  8028c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8028c7:	09 f9                	or     %edi,%ecx
  8028c9:	89 df                	mov    %ebx,%edi
  8028cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028cf:	89 c1                	mov    %eax,%ecx
  8028d1:	d3 e5                	shl    %cl,%ebp
  8028d3:	89 d1                	mov    %edx,%ecx
  8028d5:	d3 ef                	shr    %cl,%edi
  8028d7:	89 c1                	mov    %eax,%ecx
  8028d9:	89 f0                	mov    %esi,%eax
  8028db:	d3 e3                	shl    %cl,%ebx
  8028dd:	89 d1                	mov    %edx,%ecx
  8028df:	89 fa                	mov    %edi,%edx
  8028e1:	d3 e8                	shr    %cl,%eax
  8028e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028e8:	09 d8                	or     %ebx,%eax
  8028ea:	f7 74 24 08          	divl   0x8(%esp)
  8028ee:	89 d3                	mov    %edx,%ebx
  8028f0:	d3 e6                	shl    %cl,%esi
  8028f2:	f7 e5                	mul    %ebp
  8028f4:	89 c7                	mov    %eax,%edi
  8028f6:	89 d1                	mov    %edx,%ecx
  8028f8:	39 d3                	cmp    %edx,%ebx
  8028fa:	72 06                	jb     802902 <__umoddi3+0xe2>
  8028fc:	75 0e                	jne    80290c <__umoddi3+0xec>
  8028fe:	39 c6                	cmp    %eax,%esi
  802900:	73 0a                	jae    80290c <__umoddi3+0xec>
  802902:	29 e8                	sub    %ebp,%eax
  802904:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802908:	89 d1                	mov    %edx,%ecx
  80290a:	89 c7                	mov    %eax,%edi
  80290c:	89 f5                	mov    %esi,%ebp
  80290e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802912:	29 fd                	sub    %edi,%ebp
  802914:	19 cb                	sbb    %ecx,%ebx
  802916:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80291b:	89 d8                	mov    %ebx,%eax
  80291d:	d3 e0                	shl    %cl,%eax
  80291f:	89 f1                	mov    %esi,%ecx
  802921:	d3 ed                	shr    %cl,%ebp
  802923:	d3 eb                	shr    %cl,%ebx
  802925:	09 e8                	or     %ebp,%eax
  802927:	89 da                	mov    %ebx,%edx
  802929:	83 c4 1c             	add    $0x1c,%esp
  80292c:	5b                   	pop    %ebx
  80292d:	5e                   	pop    %esi
  80292e:	5f                   	pop    %edi
  80292f:	5d                   	pop    %ebp
  802930:	c3                   	ret    
