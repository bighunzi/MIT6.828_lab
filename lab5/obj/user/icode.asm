
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
  80003e:	c7 05 00 30 80 00 60 	movl   $0x802460,0x803000
  800045:	24 80 00 

	cprintf("icode startup\n");
  800048:	68 66 24 80 00       	push   $0x802466
  80004d:	e8 1d 02 00 00       	call   80026f <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 75 24 80 00 	movl   $0x802475,(%esp)
  800059:	e8 11 02 00 00       	call   80026f <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 88 24 80 00       	push   $0x802488
  800068:	e8 07 15 00 00       	call   801574 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	78 18                	js     80008e <umain+0x5b>
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
  800076:	83 ec 0c             	sub    $0xc,%esp
  800079:	68 b1 24 80 00       	push   $0x8024b1
  80007e:	e8 ec 01 00 00       	call   80026f <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80008c:	eb 1f                	jmp    8000ad <umain+0x7a>
		panic("icode: open /motd: %e", fd);
  80008e:	50                   	push   %eax
  80008f:	68 8e 24 80 00       	push   $0x80248e
  800094:	6a 0f                	push   $0xf
  800096:	68 a4 24 80 00       	push   $0x8024a4
  80009b:	e8 f4 00 00 00       	call   800194 <_panic>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 df 0a 00 00       	call   800b89 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 55 10 00 00       	call   801111 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 c4 24 80 00       	push   $0x8024c4
  8000cb:	e8 9f 01 00 00       	call   80026f <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 fd 0e 00 00       	call   800fd5 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  8000df:	e8 8b 01 00 00       	call   80026f <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 ec 24 80 00       	push   $0x8024ec
  8000f0:	68 f5 24 80 00       	push   $0x8024f5
  8000f5:	68 ff 24 80 00       	push   $0x8024ff
  8000fa:	68 fe 24 80 00       	push   $0x8024fe
  8000ff:	e8 82 1a 00 00       	call   801b86 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	78 17                	js     800122 <umain+0xef>
		panic("icode: spawn /init: %e", r);

	cprintf("icode: exiting\n");
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	68 1b 25 80 00       	push   $0x80251b
  800113:	e8 57 01 00 00       	call   80026f <cprintf>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    
		panic("icode: spawn /init: %e", r);
  800122:	50                   	push   %eax
  800123:	68 04 25 80 00       	push   $0x802504
  800128:	6a 1a                	push   $0x1a
  80012a:	68 a4 24 80 00       	push   $0x8024a4
  80012f:	e8 60 00 00 00       	call   800194 <_panic>

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
  80013f:	e8 c3 0a 00 00       	call   800c07 <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 7d 0e 00 00       	call   801002 <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 37 0a 00 00       	call   800bc6 <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 60 0a 00 00       	call   800c07 <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	push   0xc(%ebp)
  8001ad:	ff 75 08             	push   0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 38 25 80 00       	push   $0x802538
  8001b7:	e8 b3 00 00 00       	call   80026f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	push   0x10(%ebp)
  8001c3:	e8 56 00 00 00       	call   80021e <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 16 2a 80 00 	movl   $0x802a16,(%esp)
  8001cf:	e8 9b 00 00 00       	call   80026f <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	74 09                	je     800202 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800200:	c9                   	leave  
  800201:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800202:	83 ec 08             	sub    $0x8,%esp
  800205:	68 ff 00 00 00       	push   $0xff
  80020a:	8d 43 08             	lea    0x8(%ebx),%eax
  80020d:	50                   	push   %eax
  80020e:	e8 76 09 00 00       	call   800b89 <sys_cputs>
		b->idx = 0;
  800213:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800219:	83 c4 10             	add    $0x10,%esp
  80021c:	eb db                	jmp    8001f9 <putch+0x1f>

0080021e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800227:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022e:	00 00 00 
	b.cnt = 0;
  800231:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800238:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023b:	ff 75 0c             	push   0xc(%ebp)
  80023e:	ff 75 08             	push   0x8(%ebp)
  800241:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	68 da 01 80 00       	push   $0x8001da
  80024d:	e8 14 01 00 00       	call   800366 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800252:	83 c4 08             	add    $0x8,%esp
  800255:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80025b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800261:	50                   	push   %eax
  800262:	e8 22 09 00 00       	call   800b89 <sys_cputs>

	return b.cnt;
}
  800267:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800275:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800278:	50                   	push   %eax
  800279:	ff 75 08             	push   0x8(%ebp)
  80027c:	e8 9d ff ff ff       	call   80021e <vcprintf>
	va_end(ap);

	return cnt;
}
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 1c             	sub    $0x1c,%esp
  80028c:	89 c7                	mov    %eax,%edi
  80028e:	89 d6                	mov    %edx,%esi
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	8b 55 0c             	mov    0xc(%ebp),%edx
  800296:	89 d1                	mov    %edx,%ecx
  800298:	89 c2                	mov    %eax,%edx
  80029a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b0:	39 c2                	cmp    %eax,%edx
  8002b2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b5:	72 3e                	jb     8002f5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b7:	83 ec 0c             	sub    $0xc,%esp
  8002ba:	ff 75 18             	push   0x18(%ebp)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	53                   	push   %ebx
  8002c1:	50                   	push   %eax
  8002c2:	83 ec 08             	sub    $0x8,%esp
  8002c5:	ff 75 e4             	push   -0x1c(%ebp)
  8002c8:	ff 75 e0             	push   -0x20(%ebp)
  8002cb:	ff 75 dc             	push   -0x24(%ebp)
  8002ce:	ff 75 d8             	push   -0x28(%ebp)
  8002d1:	e8 4a 1f 00 00       	call   802220 <__udivdi3>
  8002d6:	83 c4 18             	add    $0x18,%esp
  8002d9:	52                   	push   %edx
  8002da:	50                   	push   %eax
  8002db:	89 f2                	mov    %esi,%edx
  8002dd:	89 f8                	mov    %edi,%eax
  8002df:	e8 9f ff ff ff       	call   800283 <printnum>
  8002e4:	83 c4 20             	add    $0x20,%esp
  8002e7:	eb 13                	jmp    8002fc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	56                   	push   %esi
  8002ed:	ff 75 18             	push   0x18(%ebp)
  8002f0:	ff d7                	call   *%edi
  8002f2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f5:	83 eb 01             	sub    $0x1,%ebx
  8002f8:	85 db                	test   %ebx,%ebx
  8002fa:	7f ed                	jg     8002e9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	83 ec 08             	sub    $0x8,%esp
  8002ff:	56                   	push   %esi
  800300:	83 ec 04             	sub    $0x4,%esp
  800303:	ff 75 e4             	push   -0x1c(%ebp)
  800306:	ff 75 e0             	push   -0x20(%ebp)
  800309:	ff 75 dc             	push   -0x24(%ebp)
  80030c:	ff 75 d8             	push   -0x28(%ebp)
  80030f:	e8 2c 20 00 00       	call   802340 <__umoddi3>
  800314:	83 c4 14             	add    $0x14,%esp
  800317:	0f be 80 5b 25 80 00 	movsbl 0x80255b(%eax),%eax
  80031e:	50                   	push   %eax
  80031f:	ff d7                	call   *%edi
}
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800327:	5b                   	pop    %ebx
  800328:	5e                   	pop    %esi
  800329:	5f                   	pop    %edi
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    

0080032c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800332:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800336:	8b 10                	mov    (%eax),%edx
  800338:	3b 50 04             	cmp    0x4(%eax),%edx
  80033b:	73 0a                	jae    800347 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800340:	89 08                	mov    %ecx,(%eax)
  800342:	8b 45 08             	mov    0x8(%ebp),%eax
  800345:	88 02                	mov    %al,(%edx)
}
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <printfmt>:
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80034f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800352:	50                   	push   %eax
  800353:	ff 75 10             	push   0x10(%ebp)
  800356:	ff 75 0c             	push   0xc(%ebp)
  800359:	ff 75 08             	push   0x8(%ebp)
  80035c:	e8 05 00 00 00       	call   800366 <vprintfmt>
}
  800361:	83 c4 10             	add    $0x10,%esp
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <vprintfmt>:
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
  80036c:	83 ec 3c             	sub    $0x3c,%esp
  80036f:	8b 75 08             	mov    0x8(%ebp),%esi
  800372:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800375:	8b 7d 10             	mov    0x10(%ebp),%edi
  800378:	eb 0a                	jmp    800384 <vprintfmt+0x1e>
			putch(ch, putdat);
  80037a:	83 ec 08             	sub    $0x8,%esp
  80037d:	53                   	push   %ebx
  80037e:	50                   	push   %eax
  80037f:	ff d6                	call   *%esi
  800381:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800384:	83 c7 01             	add    $0x1,%edi
  800387:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038b:	83 f8 25             	cmp    $0x25,%eax
  80038e:	74 0c                	je     80039c <vprintfmt+0x36>
			if (ch == '\0')
  800390:	85 c0                	test   %eax,%eax
  800392:	75 e6                	jne    80037a <vprintfmt+0x14>
}
  800394:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800397:	5b                   	pop    %ebx
  800398:	5e                   	pop    %esi
  800399:	5f                   	pop    %edi
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    
		padc = ' ';
  80039c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003a0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003a7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003ae:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003b5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8d 47 01             	lea    0x1(%edi),%eax
  8003bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c0:	0f b6 17             	movzbl (%edi),%edx
  8003c3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003c6:	3c 55                	cmp    $0x55,%al
  8003c8:	0f 87 bb 03 00 00    	ja     800789 <vprintfmt+0x423>
  8003ce:	0f b6 c0             	movzbl %al,%eax
  8003d1:	ff 24 85 a0 26 80 00 	jmp    *0x8026a0(,%eax,4)
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003db:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003df:	eb d9                	jmp    8003ba <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e4:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003e8:	eb d0                	jmp    8003ba <vprintfmt+0x54>
  8003ea:	0f b6 d2             	movzbl %dl,%edx
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ff:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800402:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800405:	83 f9 09             	cmp    $0x9,%ecx
  800408:	77 55                	ja     80045f <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80040a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80040d:	eb e9                	jmp    8003f8 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8b 00                	mov    (%eax),%eax
  800414:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 40 04             	lea    0x4(%eax),%eax
  80041d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800423:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800427:	79 91                	jns    8003ba <vprintfmt+0x54>
				width = precision, precision = -1;
  800429:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80042c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800436:	eb 82                	jmp    8003ba <vprintfmt+0x54>
  800438:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80043b:	85 d2                	test   %edx,%edx
  80043d:	b8 00 00 00 00       	mov    $0x0,%eax
  800442:	0f 49 c2             	cmovns %edx,%eax
  800445:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80044b:	e9 6a ff ff ff       	jmp    8003ba <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800453:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80045a:	e9 5b ff ff ff       	jmp    8003ba <vprintfmt+0x54>
  80045f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800462:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800465:	eb bc                	jmp    800423 <vprintfmt+0xbd>
			lflag++;
  800467:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80046d:	e9 48 ff ff ff       	jmp    8003ba <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 78 04             	lea    0x4(%eax),%edi
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	53                   	push   %ebx
  80047c:	ff 30                	push   (%eax)
  80047e:	ff d6                	call   *%esi
			break;
  800480:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800483:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800486:	e9 9d 02 00 00       	jmp    800728 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 78 04             	lea    0x4(%eax),%edi
  800491:	8b 10                	mov    (%eax),%edx
  800493:	89 d0                	mov    %edx,%eax
  800495:	f7 d8                	neg    %eax
  800497:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049a:	83 f8 0f             	cmp    $0xf,%eax
  80049d:	7f 23                	jg     8004c2 <vprintfmt+0x15c>
  80049f:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	74 18                	je     8004c2 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004aa:	52                   	push   %edx
  8004ab:	68 31 29 80 00       	push   $0x802931
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 92 fe ff ff       	call   800349 <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ba:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004bd:	e9 66 02 00 00       	jmp    800728 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004c2:	50                   	push   %eax
  8004c3:	68 73 25 80 00       	push   $0x802573
  8004c8:	53                   	push   %ebx
  8004c9:	56                   	push   %esi
  8004ca:	e8 7a fe ff ff       	call   800349 <printfmt>
  8004cf:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004d2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004d5:	e9 4e 02 00 00       	jmp    800728 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	83 c0 04             	add    $0x4,%eax
  8004e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	b8 6c 25 80 00       	mov    $0x80256c,%eax
  8004ef:	0f 45 c2             	cmovne %edx,%eax
  8004f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f9:	7e 06                	jle    800501 <vprintfmt+0x19b>
  8004fb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004ff:	75 0d                	jne    80050e <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800504:	89 c7                	mov    %eax,%edi
  800506:	03 45 e0             	add    -0x20(%ebp),%eax
  800509:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050c:	eb 55                	jmp    800563 <vprintfmt+0x1fd>
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	ff 75 d8             	push   -0x28(%ebp)
  800514:	ff 75 cc             	push   -0x34(%ebp)
  800517:	e8 0a 03 00 00       	call   800826 <strnlen>
  80051c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051f:	29 c1                	sub    %eax,%ecx
  800521:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800529:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80052d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800530:	eb 0f                	jmp    800541 <vprintfmt+0x1db>
					putch(padc, putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	ff 75 e0             	push   -0x20(%ebp)
  800539:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	83 ef 01             	sub    $0x1,%edi
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	85 ff                	test   %edi,%edi
  800543:	7f ed                	jg     800532 <vprintfmt+0x1cc>
  800545:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800548:	85 d2                	test   %edx,%edx
  80054a:	b8 00 00 00 00       	mov    $0x0,%eax
  80054f:	0f 49 c2             	cmovns %edx,%eax
  800552:	29 c2                	sub    %eax,%edx
  800554:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800557:	eb a8                	jmp    800501 <vprintfmt+0x19b>
					putch(ch, putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	52                   	push   %edx
  80055e:	ff d6                	call   *%esi
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800566:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800568:	83 c7 01             	add    $0x1,%edi
  80056b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056f:	0f be d0             	movsbl %al,%edx
  800572:	85 d2                	test   %edx,%edx
  800574:	74 4b                	je     8005c1 <vprintfmt+0x25b>
  800576:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80057a:	78 06                	js     800582 <vprintfmt+0x21c>
  80057c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800580:	78 1e                	js     8005a0 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800582:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800586:	74 d1                	je     800559 <vprintfmt+0x1f3>
  800588:	0f be c0             	movsbl %al,%eax
  80058b:	83 e8 20             	sub    $0x20,%eax
  80058e:	83 f8 5e             	cmp    $0x5e,%eax
  800591:	76 c6                	jbe    800559 <vprintfmt+0x1f3>
					putch('?', putdat);
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	53                   	push   %ebx
  800597:	6a 3f                	push   $0x3f
  800599:	ff d6                	call   *%esi
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	eb c3                	jmp    800563 <vprintfmt+0x1fd>
  8005a0:	89 cf                	mov    %ecx,%edi
  8005a2:	eb 0e                	jmp    8005b2 <vprintfmt+0x24c>
				putch(' ', putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	53                   	push   %ebx
  8005a8:	6a 20                	push   $0x20
  8005aa:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005ac:	83 ef 01             	sub    $0x1,%edi
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	7f ee                	jg     8005a4 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005b6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bc:	e9 67 01 00 00       	jmp    800728 <vprintfmt+0x3c2>
  8005c1:	89 cf                	mov    %ecx,%edi
  8005c3:	eb ed                	jmp    8005b2 <vprintfmt+0x24c>
	if (lflag >= 2)
  8005c5:	83 f9 01             	cmp    $0x1,%ecx
  8005c8:	7f 1b                	jg     8005e5 <vprintfmt+0x27f>
	else if (lflag)
  8005ca:	85 c9                	test   %ecx,%ecx
  8005cc:	74 63                	je     800631 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	99                   	cltd   
  8005d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 40 04             	lea    0x4(%eax),%eax
  8005e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e3:	eb 17                	jmp    8005fc <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 50 04             	mov    0x4(%eax),%edx
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 40 08             	lea    0x8(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800602:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800607:	85 c9                	test   %ecx,%ecx
  800609:	0f 89 ff 00 00 00    	jns    80070e <vprintfmt+0x3a8>
				putch('-', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 2d                	push   $0x2d
  800615:	ff d6                	call   *%esi
				num = -(long long) num;
  800617:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80061d:	f7 da                	neg    %edx
  80061f:	83 d1 00             	adc    $0x0,%ecx
  800622:	f7 d9                	neg    %ecx
  800624:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800627:	bf 0a 00 00 00       	mov    $0xa,%edi
  80062c:	e9 dd 00 00 00       	jmp    80070e <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	99                   	cltd   
  80063a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
  800646:	eb b4                	jmp    8005fc <vprintfmt+0x296>
	if (lflag >= 2)
  800648:	83 f9 01             	cmp    $0x1,%ecx
  80064b:	7f 1e                	jg     80066b <vprintfmt+0x305>
	else if (lflag)
  80064d:	85 c9                	test   %ecx,%ecx
  80064f:	74 32                	je     800683 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800661:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800666:	e9 a3 00 00 00       	jmp    80070e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 10                	mov    (%eax),%edx
  800670:	8b 48 04             	mov    0x4(%eax),%ecx
  800673:	8d 40 08             	lea    0x8(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800679:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80067e:	e9 8b 00 00 00       	jmp    80070e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800693:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800698:	eb 74                	jmp    80070e <vprintfmt+0x3a8>
	if (lflag >= 2)
  80069a:	83 f9 01             	cmp    $0x1,%ecx
  80069d:	7f 1b                	jg     8006ba <vprintfmt+0x354>
	else if (lflag)
  80069f:	85 c9                	test   %ecx,%ecx
  8006a1:	74 2c                	je     8006cf <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006b3:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8006b8:	eb 54                	jmp    80070e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c2:	8d 40 08             	lea    0x8(%eax),%eax
  8006c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006c8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8006cd:	eb 3f                	jmp    80070e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 10                	mov    (%eax),%edx
  8006d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d9:	8d 40 04             	lea    0x4(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006df:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8006e4:	eb 28                	jmp    80070e <vprintfmt+0x3a8>
			putch('0', putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 30                	push   $0x30
  8006ec:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ee:	83 c4 08             	add    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 78                	push   $0x78
  8006f4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 10                	mov    (%eax),%edx
  8006fb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800700:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800703:	8d 40 04             	lea    0x4(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800709:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80070e:	83 ec 0c             	sub    $0xc,%esp
  800711:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	ff 75 e0             	push   -0x20(%ebp)
  800719:	57                   	push   %edi
  80071a:	51                   	push   %ecx
  80071b:	52                   	push   %edx
  80071c:	89 da                	mov    %ebx,%edx
  80071e:	89 f0                	mov    %esi,%eax
  800720:	e8 5e fb ff ff       	call   800283 <printnum>
			break;
  800725:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80072b:	e9 54 fc ff ff       	jmp    800384 <vprintfmt+0x1e>
	if (lflag >= 2)
  800730:	83 f9 01             	cmp    $0x1,%ecx
  800733:	7f 1b                	jg     800750 <vprintfmt+0x3ea>
	else if (lflag)
  800735:	85 c9                	test   %ecx,%ecx
  800737:	74 2c                	je     800765 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8b 10                	mov    (%eax),%edx
  80073e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800743:	8d 40 04             	lea    0x4(%eax),%eax
  800746:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800749:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80074e:	eb be                	jmp    80070e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 10                	mov    (%eax),%edx
  800755:	8b 48 04             	mov    0x4(%eax),%ecx
  800758:	8d 40 08             	lea    0x8(%eax),%eax
  80075b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800763:	eb a9                	jmp    80070e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8b 10                	mov    (%eax),%edx
  80076a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076f:	8d 40 04             	lea    0x4(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800775:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80077a:	eb 92                	jmp    80070e <vprintfmt+0x3a8>
			putch(ch, putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 25                	push   $0x25
  800782:	ff d6                	call   *%esi
			break;
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 9f                	jmp    800728 <vprintfmt+0x3c2>
			putch('%', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	53                   	push   %ebx
  80078d:	6a 25                	push   $0x25
  80078f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	89 f8                	mov    %edi,%eax
  800796:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80079a:	74 05                	je     8007a1 <vprintfmt+0x43b>
  80079c:	83 e8 01             	sub    $0x1,%eax
  80079f:	eb f5                	jmp    800796 <vprintfmt+0x430>
  8007a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a4:	eb 82                	jmp    800728 <vprintfmt+0x3c2>

008007a6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	83 ec 18             	sub    $0x18,%esp
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	74 26                	je     8007ed <vsnprintf+0x47>
  8007c7:	85 d2                	test   %edx,%edx
  8007c9:	7e 22                	jle    8007ed <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cb:	ff 75 14             	push   0x14(%ebp)
  8007ce:	ff 75 10             	push   0x10(%ebp)
  8007d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	68 2c 03 80 00       	push   $0x80032c
  8007da:	e8 87 fb ff ff       	call   800366 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e8:	83 c4 10             	add    $0x10,%esp
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    
		return -E_INVAL;
  8007ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f2:	eb f7                	jmp    8007eb <vsnprintf+0x45>

008007f4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fd:	50                   	push   %eax
  8007fe:	ff 75 10             	push   0x10(%ebp)
  800801:	ff 75 0c             	push   0xc(%ebp)
  800804:	ff 75 08             	push   0x8(%ebp)
  800807:	e8 9a ff ff ff       	call   8007a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800814:	b8 00 00 00 00       	mov    $0x0,%eax
  800819:	eb 03                	jmp    80081e <strlen+0x10>
		n++;
  80081b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80081e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800822:	75 f7                	jne    80081b <strlen+0xd>
	return n;
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
  800834:	eb 03                	jmp    800839 <strnlen+0x13>
		n++;
  800836:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800839:	39 d0                	cmp    %edx,%eax
  80083b:	74 08                	je     800845 <strnlen+0x1f>
  80083d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800841:	75 f3                	jne    800836 <strnlen+0x10>
  800843:	89 c2                	mov    %eax,%edx
	return n;
}
  800845:	89 d0                	mov    %edx,%eax
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800850:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80085c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80085f:	83 c0 01             	add    $0x1,%eax
  800862:	84 d2                	test   %dl,%dl
  800864:	75 f2                	jne    800858 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800866:	89 c8                	mov    %ecx,%eax
  800868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	53                   	push   %ebx
  800871:	83 ec 10             	sub    $0x10,%esp
  800874:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800877:	53                   	push   %ebx
  800878:	e8 91 ff ff ff       	call   80080e <strlen>
  80087d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800880:	ff 75 0c             	push   0xc(%ebp)
  800883:	01 d8                	add    %ebx,%eax
  800885:	50                   	push   %eax
  800886:	e8 be ff ff ff       	call   800849 <strcpy>
	return dst;
}
  80088b:	89 d8                	mov    %ebx,%eax
  80088d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
  800897:	8b 75 08             	mov    0x8(%ebp),%esi
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089d:	89 f3                	mov    %esi,%ebx
  80089f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a2:	89 f0                	mov    %esi,%eax
  8008a4:	eb 0f                	jmp    8008b5 <strncpy+0x23>
		*dst++ = *src;
  8008a6:	83 c0 01             	add    $0x1,%eax
  8008a9:	0f b6 0a             	movzbl (%edx),%ecx
  8008ac:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008af:	80 f9 01             	cmp    $0x1,%cl
  8008b2:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008b5:	39 d8                	cmp    %ebx,%eax
  8008b7:	75 ed                	jne    8008a6 <strncpy+0x14>
	}
	return ret;
}
  8008b9:	89 f0                	mov    %esi,%eax
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ca:	8b 55 10             	mov    0x10(%ebp),%edx
  8008cd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008cf:	85 d2                	test   %edx,%edx
  8008d1:	74 21                	je     8008f4 <strlcpy+0x35>
  8008d3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d7:	89 f2                	mov    %esi,%edx
  8008d9:	eb 09                	jmp    8008e4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008db:	83 c1 01             	add    $0x1,%ecx
  8008de:	83 c2 01             	add    $0x1,%edx
  8008e1:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8008e4:	39 c2                	cmp    %eax,%edx
  8008e6:	74 09                	je     8008f1 <strlcpy+0x32>
  8008e8:	0f b6 19             	movzbl (%ecx),%ebx
  8008eb:	84 db                	test   %bl,%bl
  8008ed:	75 ec                	jne    8008db <strlcpy+0x1c>
  8008ef:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008f1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f4:	29 f0                	sub    %esi,%eax
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800900:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800903:	eb 06                	jmp    80090b <strcmp+0x11>
		p++, q++;
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80090b:	0f b6 01             	movzbl (%ecx),%eax
  80090e:	84 c0                	test   %al,%al
  800910:	74 04                	je     800916 <strcmp+0x1c>
  800912:	3a 02                	cmp    (%edx),%al
  800914:	74 ef                	je     800905 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800916:	0f b6 c0             	movzbl %al,%eax
  800919:	0f b6 12             	movzbl (%edx),%edx
  80091c:	29 d0                	sub    %edx,%eax
}
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	53                   	push   %ebx
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	89 c3                	mov    %eax,%ebx
  80092c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092f:	eb 06                	jmp    800937 <strncmp+0x17>
		n--, p++, q++;
  800931:	83 c0 01             	add    $0x1,%eax
  800934:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800937:	39 d8                	cmp    %ebx,%eax
  800939:	74 18                	je     800953 <strncmp+0x33>
  80093b:	0f b6 08             	movzbl (%eax),%ecx
  80093e:	84 c9                	test   %cl,%cl
  800940:	74 04                	je     800946 <strncmp+0x26>
  800942:	3a 0a                	cmp    (%edx),%cl
  800944:	74 eb                	je     800931 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800946:	0f b6 00             	movzbl (%eax),%eax
  800949:	0f b6 12             	movzbl (%edx),%edx
  80094c:	29 d0                	sub    %edx,%eax
}
  80094e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800951:	c9                   	leave  
  800952:	c3                   	ret    
		return 0;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
  800958:	eb f4                	jmp    80094e <strncmp+0x2e>

0080095a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800964:	eb 03                	jmp    800969 <strchr+0xf>
  800966:	83 c0 01             	add    $0x1,%eax
  800969:	0f b6 10             	movzbl (%eax),%edx
  80096c:	84 d2                	test   %dl,%dl
  80096e:	74 06                	je     800976 <strchr+0x1c>
		if (*s == c)
  800970:	38 ca                	cmp    %cl,%dl
  800972:	75 f2                	jne    800966 <strchr+0xc>
  800974:	eb 05                	jmp    80097b <strchr+0x21>
			return (char *) s;
	return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800987:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 09                	je     800997 <strfind+0x1a>
  80098e:	84 d2                	test   %dl,%dl
  800990:	74 05                	je     800997 <strfind+0x1a>
	for (; *s; s++)
  800992:	83 c0 01             	add    $0x1,%eax
  800995:	eb f0                	jmp    800987 <strfind+0xa>
			break;
	return (char *) s;
}
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
  80099f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a5:	85 c9                	test   %ecx,%ecx
  8009a7:	74 2f                	je     8009d8 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a9:	89 f8                	mov    %edi,%eax
  8009ab:	09 c8                	or     %ecx,%eax
  8009ad:	a8 03                	test   $0x3,%al
  8009af:	75 21                	jne    8009d2 <memset+0x39>
		c &= 0xFF;
  8009b1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b5:	89 d0                	mov    %edx,%eax
  8009b7:	c1 e0 08             	shl    $0x8,%eax
  8009ba:	89 d3                	mov    %edx,%ebx
  8009bc:	c1 e3 18             	shl    $0x18,%ebx
  8009bf:	89 d6                	mov    %edx,%esi
  8009c1:	c1 e6 10             	shl    $0x10,%esi
  8009c4:	09 f3                	or     %esi,%ebx
  8009c6:	09 da                	or     %ebx,%edx
  8009c8:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ca:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009cd:	fc                   	cld    
  8009ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d0:	eb 06                	jmp    8009d8 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d5:	fc                   	cld    
  8009d6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d8:	89 f8                	mov    %edi,%eax
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ed:	39 c6                	cmp    %eax,%esi
  8009ef:	73 32                	jae    800a23 <memmove+0x44>
  8009f1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f4:	39 c2                	cmp    %eax,%edx
  8009f6:	76 2b                	jbe    800a23 <memmove+0x44>
		s += n;
		d += n;
  8009f8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fb:	89 d6                	mov    %edx,%esi
  8009fd:	09 fe                	or     %edi,%esi
  8009ff:	09 ce                	or     %ecx,%esi
  800a01:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a07:	75 0e                	jne    800a17 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a09:	83 ef 04             	sub    $0x4,%edi
  800a0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a12:	fd                   	std    
  800a13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a15:	eb 09                	jmp    800a20 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a17:	83 ef 01             	sub    $0x1,%edi
  800a1a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a1d:	fd                   	std    
  800a1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a20:	fc                   	cld    
  800a21:	eb 1a                	jmp    800a3d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a23:	89 f2                	mov    %esi,%edx
  800a25:	09 c2                	or     %eax,%edx
  800a27:	09 ca                	or     %ecx,%edx
  800a29:	f6 c2 03             	test   $0x3,%dl
  800a2c:	75 0a                	jne    800a38 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	fc                   	cld    
  800a34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a36:	eb 05                	jmp    800a3d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a38:	89 c7                	mov    %eax,%edi
  800a3a:	fc                   	cld    
  800a3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3d:	5e                   	pop    %esi
  800a3e:	5f                   	pop    %edi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a47:	ff 75 10             	push   0x10(%ebp)
  800a4a:	ff 75 0c             	push   0xc(%ebp)
  800a4d:	ff 75 08             	push   0x8(%ebp)
  800a50:	e8 8a ff ff ff       	call   8009df <memmove>
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a62:	89 c6                	mov    %eax,%esi
  800a64:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a67:	eb 06                	jmp    800a6f <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a6f:	39 f0                	cmp    %esi,%eax
  800a71:	74 14                	je     800a87 <memcmp+0x30>
		if (*s1 != *s2)
  800a73:	0f b6 08             	movzbl (%eax),%ecx
  800a76:	0f b6 1a             	movzbl (%edx),%ebx
  800a79:	38 d9                	cmp    %bl,%cl
  800a7b:	74 ec                	je     800a69 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a7d:	0f b6 c1             	movzbl %cl,%eax
  800a80:	0f b6 db             	movzbl %bl,%ebx
  800a83:	29 d8                	sub    %ebx,%eax
  800a85:	eb 05                	jmp    800a8c <memcmp+0x35>
	}

	return 0;
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a99:	89 c2                	mov    %eax,%edx
  800a9b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a9e:	eb 03                	jmp    800aa3 <memfind+0x13>
  800aa0:	83 c0 01             	add    $0x1,%eax
  800aa3:	39 d0                	cmp    %edx,%eax
  800aa5:	73 04                	jae    800aab <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa7:	38 08                	cmp    %cl,(%eax)
  800aa9:	75 f5                	jne    800aa0 <memfind+0x10>
			break;
	return (void *) s;
}
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab9:	eb 03                	jmp    800abe <strtol+0x11>
		s++;
  800abb:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800abe:	0f b6 02             	movzbl (%edx),%eax
  800ac1:	3c 20                	cmp    $0x20,%al
  800ac3:	74 f6                	je     800abb <strtol+0xe>
  800ac5:	3c 09                	cmp    $0x9,%al
  800ac7:	74 f2                	je     800abb <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ac9:	3c 2b                	cmp    $0x2b,%al
  800acb:	74 2a                	je     800af7 <strtol+0x4a>
	int neg = 0;
  800acd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad2:	3c 2d                	cmp    $0x2d,%al
  800ad4:	74 2b                	je     800b01 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800adc:	75 0f                	jne    800aed <strtol+0x40>
  800ade:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae1:	74 28                	je     800b0b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae3:	85 db                	test   %ebx,%ebx
  800ae5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aea:	0f 44 d8             	cmove  %eax,%ebx
  800aed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800af5:	eb 46                	jmp    800b3d <strtol+0x90>
		s++;
  800af7:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800afa:	bf 00 00 00 00       	mov    $0x0,%edi
  800aff:	eb d5                	jmp    800ad6 <strtol+0x29>
		s++, neg = 1;
  800b01:	83 c2 01             	add    $0x1,%edx
  800b04:	bf 01 00 00 00       	mov    $0x1,%edi
  800b09:	eb cb                	jmp    800ad6 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b0f:	74 0e                	je     800b1f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b11:	85 db                	test   %ebx,%ebx
  800b13:	75 d8                	jne    800aed <strtol+0x40>
		s++, base = 8;
  800b15:	83 c2 01             	add    $0x1,%edx
  800b18:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b1d:	eb ce                	jmp    800aed <strtol+0x40>
		s += 2, base = 16;
  800b1f:	83 c2 02             	add    $0x2,%edx
  800b22:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b27:	eb c4                	jmp    800aed <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b29:	0f be c0             	movsbl %al,%eax
  800b2c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b32:	7d 3a                	jge    800b6e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b34:	83 c2 01             	add    $0x1,%edx
  800b37:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b3b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b3d:	0f b6 02             	movzbl (%edx),%eax
  800b40:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b43:	89 f3                	mov    %esi,%ebx
  800b45:	80 fb 09             	cmp    $0x9,%bl
  800b48:	76 df                	jbe    800b29 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b4a:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b4d:	89 f3                	mov    %esi,%ebx
  800b4f:	80 fb 19             	cmp    $0x19,%bl
  800b52:	77 08                	ja     800b5c <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b54:	0f be c0             	movsbl %al,%eax
  800b57:	83 e8 57             	sub    $0x57,%eax
  800b5a:	eb d3                	jmp    800b2f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b5c:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b5f:	89 f3                	mov    %esi,%ebx
  800b61:	80 fb 19             	cmp    $0x19,%bl
  800b64:	77 08                	ja     800b6e <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b66:	0f be c0             	movsbl %al,%eax
  800b69:	83 e8 37             	sub    $0x37,%eax
  800b6c:	eb c1                	jmp    800b2f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b72:	74 05                	je     800b79 <strtol+0xcc>
		*endptr = (char *) s;
  800b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b77:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b79:	89 c8                	mov    %ecx,%eax
  800b7b:	f7 d8                	neg    %eax
  800b7d:	85 ff                	test   %edi,%edi
  800b7f:	0f 45 c8             	cmovne %eax,%ecx
}
  800b82:	89 c8                	mov    %ecx,%eax
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9a:	89 c3                	mov    %eax,%ebx
  800b9c:	89 c7                	mov    %eax,%edi
  800b9e:	89 c6                	mov    %eax,%esi
  800ba0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb7:	89 d1                	mov    %edx,%ecx
  800bb9:	89 d3                	mov    %edx,%ebx
  800bbb:	89 d7                	mov    %edx,%edi
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bdc:	89 cb                	mov    %ecx,%ebx
  800bde:	89 cf                	mov    %ecx,%edi
  800be0:	89 ce                	mov    %ecx,%esi
  800be2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7f 08                	jg     800bf0 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 03                	push   $0x3
  800bf6:	68 5f 28 80 00       	push   $0x80285f
  800bfb:	6a 2a                	push   $0x2a
  800bfd:	68 7c 28 80 00       	push   $0x80287c
  800c02:	e8 8d f5 ff ff       	call   800194 <_panic>

00800c07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 02 00 00 00       	mov    $0x2,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_yield>:

void
sys_yield(void)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c36:	89 d1                	mov    %edx,%ecx
  800c38:	89 d3                	mov    %edx,%ebx
  800c3a:	89 d7                	mov    %edx,%edi
  800c3c:	89 d6                	mov    %edx,%esi
  800c3e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4e:	be 00 00 00 00       	mov    $0x0,%esi
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c61:	89 f7                	mov    %esi,%edi
  800c63:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7f 08                	jg     800c71 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	50                   	push   %eax
  800c75:	6a 04                	push   $0x4
  800c77:	68 5f 28 80 00       	push   $0x80285f
  800c7c:	6a 2a                	push   $0x2a
  800c7e:	68 7c 28 80 00       	push   $0x80287c
  800c83:	e8 0c f5 ff ff       	call   800194 <_panic>

00800c88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	b8 05 00 00 00       	mov    $0x5,%eax
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca2:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7f 08                	jg     800cb3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 05                	push   $0x5
  800cb9:	68 5f 28 80 00       	push   $0x80285f
  800cbe:	6a 2a                	push   $0x2a
  800cc0:	68 7c 28 80 00       	push   $0x80287c
  800cc5:	e8 ca f4 ff ff       	call   800194 <_panic>

00800cca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7f 08                	jg     800cf5 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	83 ec 0c             	sub    $0xc,%esp
  800cf8:	50                   	push   %eax
  800cf9:	6a 06                	push   $0x6
  800cfb:	68 5f 28 80 00       	push   $0x80285f
  800d00:	6a 2a                	push   $0x2a
  800d02:	68 7c 28 80 00       	push   $0x80287c
  800d07:	e8 88 f4 ff ff       	call   800194 <_panic>

00800d0c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	b8 08 00 00 00       	mov    $0x8,%eax
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7f 08                	jg     800d37 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	50                   	push   %eax
  800d3b:	6a 08                	push   $0x8
  800d3d:	68 5f 28 80 00       	push   $0x80285f
  800d42:	6a 2a                	push   $0x2a
  800d44:	68 7c 28 80 00       	push   $0x80287c
  800d49:	e8 46 f4 ff ff       	call   800194 <_panic>

00800d4e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	b8 09 00 00 00       	mov    $0x9,%eax
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7f 08                	jg     800d79 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	50                   	push   %eax
  800d7d:	6a 09                	push   $0x9
  800d7f:	68 5f 28 80 00       	push   $0x80285f
  800d84:	6a 2a                	push   $0x2a
  800d86:	68 7c 28 80 00       	push   $0x80287c
  800d8b:	e8 04 f4 ff ff       	call   800194 <_panic>

00800d90 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7f 08                	jg     800dbb <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	50                   	push   %eax
  800dbf:	6a 0a                	push   $0xa
  800dc1:	68 5f 28 80 00       	push   $0x80285f
  800dc6:	6a 2a                	push   $0x2a
  800dc8:	68 7c 28 80 00       	push   $0x80287c
  800dcd:	e8 c2 f3 ff ff       	call   800194 <_panic>

00800dd2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de3:	be 00 00 00 00       	mov    $0x0,%esi
  800de8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800deb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dee:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0b:	89 cb                	mov    %ecx,%ebx
  800e0d:	89 cf                	mov    %ecx,%edi
  800e0f:	89 ce                	mov    %ecx,%esi
  800e11:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e13:	85 c0                	test   %eax,%eax
  800e15:	7f 08                	jg     800e1f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	50                   	push   %eax
  800e23:	6a 0d                	push   $0xd
  800e25:	68 5f 28 80 00       	push   $0x80285f
  800e2a:	6a 2a                	push   $0x2a
  800e2c:	68 7c 28 80 00       	push   $0x80287c
  800e31:	e8 5e f3 ff ff       	call   800194 <_panic>

00800e36 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e41:	c1 e8 0c             	shr    $0xc,%eax
}
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e56:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e65:	89 c2                	mov    %eax,%edx
  800e67:	c1 ea 16             	shr    $0x16,%edx
  800e6a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	74 29                	je     800e9f <fd_alloc+0x42>
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	c1 ea 0c             	shr    $0xc,%edx
  800e7b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e82:	f6 c2 01             	test   $0x1,%dl
  800e85:	74 18                	je     800e9f <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e87:	05 00 10 00 00       	add    $0x1000,%eax
  800e8c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e91:	75 d2                	jne    800e65 <fd_alloc+0x8>
  800e93:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800e98:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800e9d:	eb 05                	jmp    800ea4 <fd_alloc+0x47>
			return 0;
  800e9f:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 02                	mov    %eax,(%edx)
}
  800ea9:	89 c8                	mov    %ecx,%eax
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eb3:	83 f8 1f             	cmp    $0x1f,%eax
  800eb6:	77 30                	ja     800ee8 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb8:	c1 e0 0c             	shl    $0xc,%eax
  800ebb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec0:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ec6:	f6 c2 01             	test   $0x1,%dl
  800ec9:	74 24                	je     800eef <fd_lookup+0x42>
  800ecb:	89 c2                	mov    %eax,%edx
  800ecd:	c1 ea 0c             	shr    $0xc,%edx
  800ed0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed7:	f6 c2 01             	test   $0x1,%dl
  800eda:	74 1a                	je     800ef6 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800edc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800edf:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    
		return -E_INVAL;
  800ee8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eed:	eb f7                	jmp    800ee6 <fd_lookup+0x39>
		return -E_INVAL;
  800eef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef4:	eb f0                	jmp    800ee6 <fd_lookup+0x39>
  800ef6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efb:	eb e9                	jmp    800ee6 <fd_lookup+0x39>

00800efd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	53                   	push   %ebx
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	8b 55 08             	mov    0x8(%ebp),%edx
  800f07:	b8 08 29 80 00       	mov    $0x802908,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800f0c:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f11:	39 13                	cmp    %edx,(%ebx)
  800f13:	74 32                	je     800f47 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800f15:	83 c0 04             	add    $0x4,%eax
  800f18:	8b 18                	mov    (%eax),%ebx
  800f1a:	85 db                	test   %ebx,%ebx
  800f1c:	75 f3                	jne    800f11 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f1e:	a1 00 40 80 00       	mov    0x804000,%eax
  800f23:	8b 40 48             	mov    0x48(%eax),%eax
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	52                   	push   %edx
  800f2a:	50                   	push   %eax
  800f2b:	68 8c 28 80 00       	push   $0x80288c
  800f30:	e8 3a f3 ff ff       	call   80026f <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f40:	89 1a                	mov    %ebx,(%edx)
}
  800f42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    
			return 0;
  800f47:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4c:	eb ef                	jmp    800f3d <dev_lookup+0x40>

00800f4e <fd_close>:
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 24             	sub    $0x24,%esp
  800f57:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f60:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f61:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f67:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f6a:	50                   	push   %eax
  800f6b:	e8 3d ff ff ff       	call   800ead <fd_lookup>
  800f70:	89 c3                	mov    %eax,%ebx
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	78 05                	js     800f7e <fd_close+0x30>
	    || fd != fd2)
  800f79:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f7c:	74 16                	je     800f94 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f7e:	89 f8                	mov    %edi,%eax
  800f80:	84 c0                	test   %al,%al
  800f82:	b8 00 00 00 00       	mov    $0x0,%eax
  800f87:	0f 44 d8             	cmove  %eax,%ebx
}
  800f8a:	89 d8                	mov    %ebx,%eax
  800f8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f94:	83 ec 08             	sub    $0x8,%esp
  800f97:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f9a:	50                   	push   %eax
  800f9b:	ff 36                	push   (%esi)
  800f9d:	e8 5b ff ff ff       	call   800efd <dev_lookup>
  800fa2:	89 c3                	mov    %eax,%ebx
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 1a                	js     800fc5 <fd_close+0x77>
		if (dev->dev_close)
  800fab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fae:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fb1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	74 0b                	je     800fc5 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	56                   	push   %esi
  800fbe:	ff d0                	call   *%eax
  800fc0:	89 c3                	mov    %eax,%ebx
  800fc2:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	56                   	push   %esi
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 fa fc ff ff       	call   800cca <sys_page_unmap>
	return r;
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	eb b5                	jmp    800f8a <fd_close+0x3c>

00800fd5 <close>:

int
close(int fdnum)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fde:	50                   	push   %eax
  800fdf:	ff 75 08             	push   0x8(%ebp)
  800fe2:	e8 c6 fe ff ff       	call   800ead <fd_lookup>
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	79 02                	jns    800ff0 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    
		return fd_close(fd, 1);
  800ff0:	83 ec 08             	sub    $0x8,%esp
  800ff3:	6a 01                	push   $0x1
  800ff5:	ff 75 f4             	push   -0xc(%ebp)
  800ff8:	e8 51 ff ff ff       	call   800f4e <fd_close>
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	eb ec                	jmp    800fee <close+0x19>

00801002 <close_all>:

void
close_all(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	53                   	push   %ebx
  801006:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801009:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	53                   	push   %ebx
  801012:	e8 be ff ff ff       	call   800fd5 <close>
	for (i = 0; i < MAXFD; i++)
  801017:	83 c3 01             	add    $0x1,%ebx
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	83 fb 20             	cmp    $0x20,%ebx
  801020:	75 ec                	jne    80100e <close_all+0xc>
}
  801022:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801030:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801033:	50                   	push   %eax
  801034:	ff 75 08             	push   0x8(%ebp)
  801037:	e8 71 fe ff ff       	call   800ead <fd_lookup>
  80103c:	89 c3                	mov    %eax,%ebx
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	78 7f                	js     8010c4 <dup+0x9d>
		return r;
	close(newfdnum);
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	ff 75 0c             	push   0xc(%ebp)
  80104b:	e8 85 ff ff ff       	call   800fd5 <close>

	newfd = INDEX2FD(newfdnum);
  801050:	8b 75 0c             	mov    0xc(%ebp),%esi
  801053:	c1 e6 0c             	shl    $0xc,%esi
  801056:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80105c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80105f:	89 3c 24             	mov    %edi,(%esp)
  801062:	e8 df fd ff ff       	call   800e46 <fd2data>
  801067:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801069:	89 34 24             	mov    %esi,(%esp)
  80106c:	e8 d5 fd ff ff       	call   800e46 <fd2data>
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801077:	89 d8                	mov    %ebx,%eax
  801079:	c1 e8 16             	shr    $0x16,%eax
  80107c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801083:	a8 01                	test   $0x1,%al
  801085:	74 11                	je     801098 <dup+0x71>
  801087:	89 d8                	mov    %ebx,%eax
  801089:	c1 e8 0c             	shr    $0xc,%eax
  80108c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801093:	f6 c2 01             	test   $0x1,%dl
  801096:	75 36                	jne    8010ce <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801098:	89 f8                	mov    %edi,%eax
  80109a:	c1 e8 0c             	shr    $0xc,%eax
  80109d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a4:	83 ec 0c             	sub    $0xc,%esp
  8010a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ac:	50                   	push   %eax
  8010ad:	56                   	push   %esi
  8010ae:	6a 00                	push   $0x0
  8010b0:	57                   	push   %edi
  8010b1:	6a 00                	push   $0x0
  8010b3:	e8 d0 fb ff ff       	call   800c88 <sys_page_map>
  8010b8:	89 c3                	mov    %eax,%ebx
  8010ba:	83 c4 20             	add    $0x20,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	78 33                	js     8010f4 <dup+0xcd>
		goto err;

	return newfdnum;
  8010c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010c4:	89 d8                	mov    %ebx,%eax
  8010c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c9:	5b                   	pop    %ebx
  8010ca:	5e                   	pop    %esi
  8010cb:	5f                   	pop    %edi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010dd:	50                   	push   %eax
  8010de:	ff 75 d4             	push   -0x2c(%ebp)
  8010e1:	6a 00                	push   $0x0
  8010e3:	53                   	push   %ebx
  8010e4:	6a 00                	push   $0x0
  8010e6:	e8 9d fb ff ff       	call   800c88 <sys_page_map>
  8010eb:	89 c3                	mov    %eax,%ebx
  8010ed:	83 c4 20             	add    $0x20,%esp
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	79 a4                	jns    801098 <dup+0x71>
	sys_page_unmap(0, newfd);
  8010f4:	83 ec 08             	sub    $0x8,%esp
  8010f7:	56                   	push   %esi
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 cb fb ff ff       	call   800cca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010ff:	83 c4 08             	add    $0x8,%esp
  801102:	ff 75 d4             	push   -0x2c(%ebp)
  801105:	6a 00                	push   $0x0
  801107:	e8 be fb ff ff       	call   800cca <sys_page_unmap>
	return r;
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	eb b3                	jmp    8010c4 <dup+0x9d>

00801111 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	56                   	push   %esi
  801115:	53                   	push   %ebx
  801116:	83 ec 18             	sub    $0x18,%esp
  801119:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111f:	50                   	push   %eax
  801120:	56                   	push   %esi
  801121:	e8 87 fd ff ff       	call   800ead <fd_lookup>
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 3c                	js     801169 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112d:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801136:	50                   	push   %eax
  801137:	ff 33                	push   (%ebx)
  801139:	e8 bf fd ff ff       	call   800efd <dev_lookup>
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	85 c0                	test   %eax,%eax
  801143:	78 24                	js     801169 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801145:	8b 43 08             	mov    0x8(%ebx),%eax
  801148:	83 e0 03             	and    $0x3,%eax
  80114b:	83 f8 01             	cmp    $0x1,%eax
  80114e:	74 20                	je     801170 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801150:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801153:	8b 40 08             	mov    0x8(%eax),%eax
  801156:	85 c0                	test   %eax,%eax
  801158:	74 37                	je     801191 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80115a:	83 ec 04             	sub    $0x4,%esp
  80115d:	ff 75 10             	push   0x10(%ebp)
  801160:	ff 75 0c             	push   0xc(%ebp)
  801163:	53                   	push   %ebx
  801164:	ff d0                	call   *%eax
  801166:	83 c4 10             	add    $0x10,%esp
}
  801169:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801170:	a1 00 40 80 00       	mov    0x804000,%eax
  801175:	8b 40 48             	mov    0x48(%eax),%eax
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	56                   	push   %esi
  80117c:	50                   	push   %eax
  80117d:	68 cd 28 80 00       	push   $0x8028cd
  801182:	e8 e8 f0 ff ff       	call   80026f <cprintf>
		return -E_INVAL;
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118f:	eb d8                	jmp    801169 <read+0x58>
		return -E_NOT_SUPP;
  801191:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801196:	eb d1                	jmp    801169 <read+0x58>

00801198 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	57                   	push   %edi
  80119c:	56                   	push   %esi
  80119d:	53                   	push   %ebx
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ac:	eb 02                	jmp    8011b0 <readn+0x18>
  8011ae:	01 c3                	add    %eax,%ebx
  8011b0:	39 f3                	cmp    %esi,%ebx
  8011b2:	73 21                	jae    8011d5 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	89 f0                	mov    %esi,%eax
  8011b9:	29 d8                	sub    %ebx,%eax
  8011bb:	50                   	push   %eax
  8011bc:	89 d8                	mov    %ebx,%eax
  8011be:	03 45 0c             	add    0xc(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	57                   	push   %edi
  8011c3:	e8 49 ff ff ff       	call   801111 <read>
		if (m < 0)
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	78 04                	js     8011d3 <readn+0x3b>
			return m;
		if (m == 0)
  8011cf:	75 dd                	jne    8011ae <readn+0x16>
  8011d1:	eb 02                	jmp    8011d5 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d3:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011d5:	89 d8                	mov    %ebx,%eax
  8011d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011da:	5b                   	pop    %ebx
  8011db:	5e                   	pop    %esi
  8011dc:	5f                   	pop    %edi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	56                   	push   %esi
  8011e3:	53                   	push   %ebx
  8011e4:	83 ec 18             	sub    $0x18,%esp
  8011e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ed:	50                   	push   %eax
  8011ee:	53                   	push   %ebx
  8011ef:	e8 b9 fc ff ff       	call   800ead <fd_lookup>
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 37                	js     801232 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fb:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	ff 36                	push   (%esi)
  801207:	e8 f1 fc ff ff       	call   800efd <dev_lookup>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 1f                	js     801232 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801213:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801217:	74 20                	je     801239 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121c:	8b 40 0c             	mov    0xc(%eax),%eax
  80121f:	85 c0                	test   %eax,%eax
  801221:	74 37                	je     80125a <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801223:	83 ec 04             	sub    $0x4,%esp
  801226:	ff 75 10             	push   0x10(%ebp)
  801229:	ff 75 0c             	push   0xc(%ebp)
  80122c:	56                   	push   %esi
  80122d:	ff d0                	call   *%eax
  80122f:	83 c4 10             	add    $0x10,%esp
}
  801232:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801235:	5b                   	pop    %ebx
  801236:	5e                   	pop    %esi
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801239:	a1 00 40 80 00       	mov    0x804000,%eax
  80123e:	8b 40 48             	mov    0x48(%eax),%eax
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	53                   	push   %ebx
  801245:	50                   	push   %eax
  801246:	68 e9 28 80 00       	push   $0x8028e9
  80124b:	e8 1f f0 ff ff       	call   80026f <cprintf>
		return -E_INVAL;
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801258:	eb d8                	jmp    801232 <write+0x53>
		return -E_NOT_SUPP;
  80125a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80125f:	eb d1                	jmp    801232 <write+0x53>

00801261 <seek>:

int
seek(int fdnum, off_t offset)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	ff 75 08             	push   0x8(%ebp)
  80126e:	e8 3a fc ff ff       	call   800ead <fd_lookup>
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	78 0e                	js     801288 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80127a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801280:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	56                   	push   %esi
  80128e:	53                   	push   %ebx
  80128f:	83 ec 18             	sub    $0x18,%esp
  801292:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801295:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	53                   	push   %ebx
  80129a:	e8 0e fc ff ff       	call   800ead <fd_lookup>
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 34                	js     8012da <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012af:	50                   	push   %eax
  8012b0:	ff 36                	push   (%esi)
  8012b2:	e8 46 fc ff ff       	call   800efd <dev_lookup>
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 1c                	js     8012da <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012be:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012c2:	74 1d                	je     8012e1 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c7:	8b 40 18             	mov    0x18(%eax),%eax
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	74 34                	je     801302 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	ff 75 0c             	push   0xc(%ebp)
  8012d4:	56                   	push   %esi
  8012d5:	ff d0                	call   *%eax
  8012d7:	83 c4 10             	add    $0x10,%esp
}
  8012da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012e1:	a1 00 40 80 00       	mov    0x804000,%eax
  8012e6:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e9:	83 ec 04             	sub    $0x4,%esp
  8012ec:	53                   	push   %ebx
  8012ed:	50                   	push   %eax
  8012ee:	68 ac 28 80 00       	push   $0x8028ac
  8012f3:	e8 77 ef ff ff       	call   80026f <cprintf>
		return -E_INVAL;
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801300:	eb d8                	jmp    8012da <ftruncate+0x50>
		return -E_NOT_SUPP;
  801302:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801307:	eb d1                	jmp    8012da <ftruncate+0x50>

00801309 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	56                   	push   %esi
  80130d:	53                   	push   %ebx
  80130e:	83 ec 18             	sub    $0x18,%esp
  801311:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801314:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801317:	50                   	push   %eax
  801318:	ff 75 08             	push   0x8(%ebp)
  80131b:	e8 8d fb ff ff       	call   800ead <fd_lookup>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 49                	js     801370 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801327:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	ff 36                	push   (%esi)
  801333:	e8 c5 fb ff ff       	call   800efd <dev_lookup>
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 31                	js     801370 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80133f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801342:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801346:	74 2f                	je     801377 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801348:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80134b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801352:	00 00 00 
	stat->st_isdir = 0;
  801355:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80135c:	00 00 00 
	stat->st_dev = dev;
  80135f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	53                   	push   %ebx
  801369:	56                   	push   %esi
  80136a:	ff 50 14             	call   *0x14(%eax)
  80136d:	83 c4 10             	add    $0x10,%esp
}
  801370:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801373:	5b                   	pop    %ebx
  801374:	5e                   	pop    %esi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    
		return -E_NOT_SUPP;
  801377:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80137c:	eb f2                	jmp    801370 <fstat+0x67>

0080137e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801383:	83 ec 08             	sub    $0x8,%esp
  801386:	6a 00                	push   $0x0
  801388:	ff 75 08             	push   0x8(%ebp)
  80138b:	e8 e4 01 00 00       	call   801574 <open>
  801390:	89 c3                	mov    %eax,%ebx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 1b                	js     8013b4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	ff 75 0c             	push   0xc(%ebp)
  80139f:	50                   	push   %eax
  8013a0:	e8 64 ff ff ff       	call   801309 <fstat>
  8013a5:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a7:	89 1c 24             	mov    %ebx,(%esp)
  8013aa:	e8 26 fc ff ff       	call   800fd5 <close>
	return r;
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	89 f3                	mov    %esi,%ebx
}
  8013b4:	89 d8                	mov    %ebx,%eax
  8013b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5e                   	pop    %esi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	56                   	push   %esi
  8013c1:	53                   	push   %ebx
  8013c2:	89 c6                	mov    %eax,%esi
  8013c4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8013cd:	74 27                	je     8013f6 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013cf:	6a 07                	push   $0x7
  8013d1:	68 00 50 80 00       	push   $0x805000
  8013d6:	56                   	push   %esi
  8013d7:	ff 35 00 60 80 00    	push   0x806000
  8013dd:	e8 6e 0d 00 00       	call   802150 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e2:	83 c4 0c             	add    $0xc,%esp
  8013e5:	6a 00                	push   $0x0
  8013e7:	53                   	push   %ebx
  8013e8:	6a 00                	push   $0x0
  8013ea:	e8 fa 0c 00 00       	call   8020e9 <ipc_recv>
}
  8013ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5e                   	pop    %esi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f6:	83 ec 0c             	sub    $0xc,%esp
  8013f9:	6a 01                	push   $0x1
  8013fb:	e8 a4 0d 00 00       	call   8021a4 <ipc_find_env>
  801400:	a3 00 60 80 00       	mov    %eax,0x806000
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	eb c5                	jmp    8013cf <fsipc+0x12>

0080140a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	8b 40 0c             	mov    0xc(%eax),%eax
  801416:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80141b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801423:	ba 00 00 00 00       	mov    $0x0,%edx
  801428:	b8 02 00 00 00       	mov    $0x2,%eax
  80142d:	e8 8b ff ff ff       	call   8013bd <fsipc>
}
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <devfile_flush>:
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80143a:	8b 45 08             	mov    0x8(%ebp),%eax
  80143d:	8b 40 0c             	mov    0xc(%eax),%eax
  801440:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801445:	ba 00 00 00 00       	mov    $0x0,%edx
  80144a:	b8 06 00 00 00       	mov    $0x6,%eax
  80144f:	e8 69 ff ff ff       	call   8013bd <fsipc>
}
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <devfile_stat>:
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	53                   	push   %ebx
  80145a:	83 ec 04             	sub    $0x4,%esp
  80145d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801460:	8b 45 08             	mov    0x8(%ebp),%eax
  801463:	8b 40 0c             	mov    0xc(%eax),%eax
  801466:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80146b:	ba 00 00 00 00       	mov    $0x0,%edx
  801470:	b8 05 00 00 00       	mov    $0x5,%eax
  801475:	e8 43 ff ff ff       	call   8013bd <fsipc>
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 2c                	js     8014aa <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147e:	83 ec 08             	sub    $0x8,%esp
  801481:	68 00 50 80 00       	push   $0x805000
  801486:	53                   	push   %ebx
  801487:	e8 bd f3 ff ff       	call   800849 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80148c:	a1 80 50 80 00       	mov    0x805080,%eax
  801491:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801497:	a1 84 50 80 00       	mov    0x805084,%eax
  80149c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <devfile_write>:
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8014b8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014bd:	39 d0                	cmp    %edx,%eax
  8014bf:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8014c8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014ce:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014d3:	50                   	push   %eax
  8014d4:	ff 75 0c             	push   0xc(%ebp)
  8014d7:	68 08 50 80 00       	push   $0x805008
  8014dc:	e8 fe f4 ff ff       	call   8009df <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8014e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e6:	b8 04 00 00 00       	mov    $0x4,%eax
  8014eb:	e8 cd fe ff ff       	call   8013bd <fsipc>
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devfile_read>:
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	56                   	push   %esi
  8014f6:	53                   	push   %ebx
  8014f7:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801500:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801505:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80150b:	ba 00 00 00 00       	mov    $0x0,%edx
  801510:	b8 03 00 00 00       	mov    $0x3,%eax
  801515:	e8 a3 fe ff ff       	call   8013bd <fsipc>
  80151a:	89 c3                	mov    %eax,%ebx
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 1f                	js     80153f <devfile_read+0x4d>
	assert(r <= n);
  801520:	39 f0                	cmp    %esi,%eax
  801522:	77 24                	ja     801548 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801524:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801529:	7f 33                	jg     80155e <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	50                   	push   %eax
  80152f:	68 00 50 80 00       	push   $0x805000
  801534:	ff 75 0c             	push   0xc(%ebp)
  801537:	e8 a3 f4 ff ff       	call   8009df <memmove>
	return r;
  80153c:	83 c4 10             	add    $0x10,%esp
}
  80153f:	89 d8                	mov    %ebx,%eax
  801541:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	5d                   	pop    %ebp
  801547:	c3                   	ret    
	assert(r <= n);
  801548:	68 18 29 80 00       	push   $0x802918
  80154d:	68 1f 29 80 00       	push   $0x80291f
  801552:	6a 7c                	push   $0x7c
  801554:	68 34 29 80 00       	push   $0x802934
  801559:	e8 36 ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  80155e:	68 3f 29 80 00       	push   $0x80293f
  801563:	68 1f 29 80 00       	push   $0x80291f
  801568:	6a 7d                	push   $0x7d
  80156a:	68 34 29 80 00       	push   $0x802934
  80156f:	e8 20 ec ff ff       	call   800194 <_panic>

00801574 <open>:
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	56                   	push   %esi
  801578:	53                   	push   %ebx
  801579:	83 ec 1c             	sub    $0x1c,%esp
  80157c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80157f:	56                   	push   %esi
  801580:	e8 89 f2 ff ff       	call   80080e <strlen>
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80158d:	7f 6c                	jg     8015fb <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80158f:	83 ec 0c             	sub    $0xc,%esp
  801592:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	e8 c2 f8 ff ff       	call   800e5d <fd_alloc>
  80159b:	89 c3                	mov    %eax,%ebx
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 3c                	js     8015e0 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	56                   	push   %esi
  8015a8:	68 00 50 80 00       	push   $0x805000
  8015ad:	e8 97 f2 ff ff       	call   800849 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b5:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c2:	e8 f6 fd ff ff       	call   8013bd <fsipc>
  8015c7:	89 c3                	mov    %eax,%ebx
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 19                	js     8015e9 <open+0x75>
	return fd2num(fd);
  8015d0:	83 ec 0c             	sub    $0xc,%esp
  8015d3:	ff 75 f4             	push   -0xc(%ebp)
  8015d6:	e8 5b f8 ff ff       	call   800e36 <fd2num>
  8015db:	89 c3                	mov    %eax,%ebx
  8015dd:	83 c4 10             	add    $0x10,%esp
}
  8015e0:	89 d8                	mov    %ebx,%eax
  8015e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e5:	5b                   	pop    %ebx
  8015e6:	5e                   	pop    %esi
  8015e7:	5d                   	pop    %ebp
  8015e8:	c3                   	ret    
		fd_close(fd, 0);
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	6a 00                	push   $0x0
  8015ee:	ff 75 f4             	push   -0xc(%ebp)
  8015f1:	e8 58 f9 ff ff       	call   800f4e <fd_close>
		return r;
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	eb e5                	jmp    8015e0 <open+0x6c>
		return -E_BAD_PATH;
  8015fb:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801600:	eb de                	jmp    8015e0 <open+0x6c>

00801602 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801608:	ba 00 00 00 00       	mov    $0x0,%edx
  80160d:	b8 08 00 00 00       	mov    $0x8,%eax
  801612:	e8 a6 fd ff ff       	call   8013bd <fsipc>
}
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	57                   	push   %edi
  80161d:	56                   	push   %esi
  80161e:	53                   	push   %ebx
  80161f:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801625:	6a 00                	push   $0x0
  801627:	ff 75 08             	push   0x8(%ebp)
  80162a:	e8 45 ff ff ff       	call   801574 <open>
  80162f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	0f 88 aa 04 00 00    	js     801aea <spawn+0x4d1>
  801640:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801642:	83 ec 04             	sub    $0x4,%esp
  801645:	68 00 02 00 00       	push   $0x200
  80164a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	57                   	push   %edi
  801652:	e8 41 fb ff ff       	call   801198 <readn>
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	3d 00 02 00 00       	cmp    $0x200,%eax
  80165f:	75 57                	jne    8016b8 <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  801661:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801668:	45 4c 46 
  80166b:	75 4b                	jne    8016b8 <spawn+0x9f>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80166d:	b8 07 00 00 00       	mov    $0x7,%eax
  801672:	cd 30                	int    $0x30
  801674:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80167a:	85 c0                	test   %eax,%eax
  80167c:	0f 88 5c 04 00 00    	js     801ade <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801682:	25 ff 03 00 00       	and    $0x3ff,%eax
  801687:	6b f0 7c             	imul   $0x7c,%eax,%esi
  80168a:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801690:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801696:	b9 11 00 00 00       	mov    $0x11,%ecx
  80169b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80169d:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016a3:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016a9:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8016ae:	be 00 00 00 00       	mov    $0x0,%esi
  8016b3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  8016b6:	eb 4b                	jmp    801703 <spawn+0xea>
		close(fd);
  8016b8:	83 ec 0c             	sub    $0xc,%esp
  8016bb:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8016c1:	e8 0f f9 ff ff       	call   800fd5 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016c6:	83 c4 0c             	add    $0xc,%esp
  8016c9:	68 7f 45 4c 46       	push   $0x464c457f
  8016ce:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  8016d4:	68 4b 29 80 00       	push   $0x80294b
  8016d9:	e8 91 eb ff ff       	call   80026f <cprintf>
		return -E_NOT_EXEC;
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  8016e8:	ff ff ff 
  8016eb:	e9 fa 03 00 00       	jmp    801aea <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	50                   	push   %eax
  8016f4:	e8 15 f1 ff ff       	call   80080e <strlen>
  8016f9:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8016fd:	83 c3 01             	add    $0x1,%ebx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80170a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80170d:	85 c0                	test   %eax,%eax
  80170f:	75 df                	jne    8016f0 <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801711:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801717:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  80171d:	b8 00 10 40 00       	mov    $0x401000,%eax
  801722:	29 f0                	sub    %esi,%eax
  801724:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801726:	89 c2                	mov    %eax,%edx
  801728:	83 e2 fc             	and    $0xfffffffc,%edx
  80172b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801732:	29 c2                	sub    %eax,%edx
  801734:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80173a:	8d 42 f8             	lea    -0x8(%edx),%eax
  80173d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801742:	0f 86 14 04 00 00    	jbe    801b5c <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	6a 07                	push   $0x7
  80174d:	68 00 00 40 00       	push   $0x400000
  801752:	6a 00                	push   $0x0
  801754:	e8 ec f4 ff ff       	call   800c45 <sys_page_alloc>
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	85 c0                	test   %eax,%eax
  80175e:	0f 88 fd 03 00 00    	js     801b61 <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801764:	be 00 00 00 00       	mov    $0x0,%esi
  801769:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80176f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801772:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801778:	7e 32                	jle    8017ac <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  80177a:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801780:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801786:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801789:	83 ec 08             	sub    $0x8,%esp
  80178c:	ff 34 b3             	push   (%ebx,%esi,4)
  80178f:	57                   	push   %edi
  801790:	e8 b4 f0 ff ff       	call   800849 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801795:	83 c4 04             	add    $0x4,%esp
  801798:	ff 34 b3             	push   (%ebx,%esi,4)
  80179b:	e8 6e f0 ff ff       	call   80080e <strlen>
  8017a0:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  8017a4:	83 c6 01             	add    $0x1,%esi
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	eb c6                	jmp    801772 <spawn+0x159>
	}
	argv_store[argc] = 0;
  8017ac:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017b2:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017b8:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017bf:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017c5:	0f 85 8c 00 00 00    	jne    801857 <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017cb:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017d1:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  8017d7:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8017da:	89 c8                	mov    %ecx,%eax
  8017dc:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  8017e2:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017e5:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8017ea:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017f0:	83 ec 0c             	sub    $0xc,%esp
  8017f3:	6a 07                	push   $0x7
  8017f5:	68 00 d0 bf ee       	push   $0xeebfd000
  8017fa:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801800:	68 00 00 40 00       	push   $0x400000
  801805:	6a 00                	push   $0x0
  801807:	e8 7c f4 ff ff       	call   800c88 <sys_page_map>
  80180c:	89 c3                	mov    %eax,%ebx
  80180e:	83 c4 20             	add    $0x20,%esp
  801811:	85 c0                	test   %eax,%eax
  801813:	0f 88 50 03 00 00    	js     801b69 <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801819:	83 ec 08             	sub    $0x8,%esp
  80181c:	68 00 00 40 00       	push   $0x400000
  801821:	6a 00                	push   $0x0
  801823:	e8 a2 f4 ff ff       	call   800cca <sys_page_unmap>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	0f 88 34 03 00 00    	js     801b69 <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801835:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80183b:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801842:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801848:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80184f:	00 00 00 
  801852:	e9 4e 01 00 00       	jmp    8019a5 <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801857:	68 d8 29 80 00       	push   $0x8029d8
  80185c:	68 1f 29 80 00       	push   $0x80291f
  801861:	68 f2 00 00 00       	push   $0xf2
  801866:	68 65 29 80 00       	push   $0x802965
  80186b:	e8 24 e9 ff ff       	call   800194 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801870:	83 ec 04             	sub    $0x4,%esp
  801873:	6a 07                	push   $0x7
  801875:	68 00 00 40 00       	push   $0x400000
  80187a:	6a 00                	push   $0x0
  80187c:	e8 c4 f3 ff ff       	call   800c45 <sys_page_alloc>
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	85 c0                	test   %eax,%eax
  801886:	0f 88 6c 02 00 00    	js     801af8 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801895:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80189b:	50                   	push   %eax
  80189c:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8018a2:	e8 ba f9 ff ff       	call   801261 <seek>
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	0f 88 4d 02 00 00    	js     801aff <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	89 f8                	mov    %edi,%eax
  8018b7:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018bd:	ba 00 10 00 00       	mov    $0x1000,%edx
  8018c2:	39 d0                	cmp    %edx,%eax
  8018c4:	0f 47 c2             	cmova  %edx,%eax
  8018c7:	50                   	push   %eax
  8018c8:	68 00 00 40 00       	push   $0x400000
  8018cd:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8018d3:	e8 c0 f8 ff ff       	call   801198 <readn>
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	0f 88 23 02 00 00    	js     801b06 <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8018e3:	83 ec 0c             	sub    $0xc,%esp
  8018e6:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  8018ec:	56                   	push   %esi
  8018ed:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8018f3:	68 00 00 40 00       	push   $0x400000
  8018f8:	6a 00                	push   $0x0
  8018fa:	e8 89 f3 ff ff       	call   800c88 <sys_page_map>
  8018ff:	83 c4 20             	add    $0x20,%esp
  801902:	85 c0                	test   %eax,%eax
  801904:	78 7c                	js     801982 <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	68 00 00 40 00       	push   $0x400000
  80190e:	6a 00                	push   $0x0
  801910:	e8 b5 f3 ff ff       	call   800cca <sys_page_unmap>
  801915:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801918:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80191e:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801924:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80192a:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801930:	76 65                	jbe    801997 <spawn+0x37e>
		if (i >= filesz) {
  801932:	39 df                	cmp    %ebx,%edi
  801934:	0f 87 36 ff ff ff    	ja     801870 <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80193a:	83 ec 04             	sub    $0x4,%esp
  80193d:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801943:	56                   	push   %esi
  801944:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80194a:	e8 f6 f2 ff ff       	call   800c45 <sys_page_alloc>
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	85 c0                	test   %eax,%eax
  801954:	79 c2                	jns    801918 <spawn+0x2ff>
  801956:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801961:	e8 60 f2 ff ff       	call   800bc6 <sys_env_destroy>
	close(fd);
  801966:	83 c4 04             	add    $0x4,%esp
  801969:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80196f:	e8 61 f6 ff ff       	call   800fd5 <close>
	return r;
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  80197d:	e9 68 01 00 00       	jmp    801aea <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  801982:	50                   	push   %eax
  801983:	68 71 29 80 00       	push   $0x802971
  801988:	68 25 01 00 00       	push   $0x125
  80198d:	68 65 29 80 00       	push   $0x802965
  801992:	e8 fd e7 ff ff       	call   800194 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801997:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  80199e:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  8019a5:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019ac:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  8019b2:	7e 67                	jle    801a1b <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  8019b4:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  8019ba:	83 39 01             	cmpl   $0x1,(%ecx)
  8019bd:	75 d8                	jne    801997 <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8019bf:	8b 41 18             	mov    0x18(%ecx),%eax
  8019c2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8019c8:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8019cb:	83 f8 01             	cmp    $0x1,%eax
  8019ce:	19 c0                	sbb    %eax,%eax
  8019d0:	83 e0 fe             	and    $0xfffffffe,%eax
  8019d3:	83 c0 07             	add    $0x7,%eax
  8019d6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8019dc:	8b 51 04             	mov    0x4(%ecx),%edx
  8019df:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  8019e5:	8b 79 10             	mov    0x10(%ecx),%edi
  8019e8:	8b 59 14             	mov    0x14(%ecx),%ebx
  8019eb:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019f1:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  8019f4:	89 f0                	mov    %esi,%eax
  8019f6:	25 ff 0f 00 00       	and    $0xfff,%eax
  8019fb:	74 14                	je     801a11 <spawn+0x3f8>
		va -= i;
  8019fd:	29 c6                	sub    %eax,%esi
		memsz += i;
  8019ff:	01 c3                	add    %eax,%ebx
  801a01:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801a07:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801a09:	29 c2                	sub    %eax,%edx
  801a0b:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801a11:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a16:	e9 09 ff ff ff       	jmp    801924 <spawn+0x30b>
	close(fd);
  801a1b:	83 ec 0c             	sub    $0xc,%esp
  801a1e:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801a24:	e8 ac f5 ff ff       	call   800fd5 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801a29:	e8 d9 f1 ff ff       	call   800c07 <sys_getenvid>
  801a2e:	89 c6                	mov    %eax,%esi
  801a30:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801a33:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801a38:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801a3e:	eb 12                	jmp    801a52 <spawn+0x439>
  801a40:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a46:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801a4c:	0f 84 bb 00 00 00    	je     801b0d <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801a52:	89 d8                	mov    %ebx,%eax
  801a54:	c1 e8 16             	shr    $0x16,%eax
  801a57:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a5e:	a8 01                	test   $0x1,%al
  801a60:	74 de                	je     801a40 <spawn+0x427>
  801a62:	89 d8                	mov    %ebx,%eax
  801a64:	c1 e8 0c             	shr    $0xc,%eax
  801a67:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a6e:	f6 c2 01             	test   $0x1,%dl
  801a71:	74 cd                	je     801a40 <spawn+0x427>
  801a73:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a7a:	f6 c6 04             	test   $0x4,%dh
  801a7d:	74 c1                	je     801a40 <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801a7f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	25 07 0e 00 00       	and    $0xe07,%eax
  801a8e:	50                   	push   %eax
  801a8f:	53                   	push   %ebx
  801a90:	57                   	push   %edi
  801a91:	53                   	push   %ebx
  801a92:	56                   	push   %esi
  801a93:	e8 f0 f1 ff ff       	call   800c88 <sys_page_map>
  801a98:	83 c4 20             	add    $0x20,%esp
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	79 a1                	jns    801a40 <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  801a9f:	50                   	push   %eax
  801aa0:	68 bf 29 80 00       	push   $0x8029bf
  801aa5:	68 82 00 00 00       	push   $0x82
  801aaa:	68 65 29 80 00       	push   $0x802965
  801aaf:	e8 e0 e6 ff ff       	call   800194 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801ab4:	50                   	push   %eax
  801ab5:	68 8e 29 80 00       	push   $0x80298e
  801aba:	68 86 00 00 00       	push   $0x86
  801abf:	68 65 29 80 00       	push   $0x802965
  801ac4:	e8 cb e6 ff ff       	call   800194 <_panic>
		panic("sys_env_set_status: %e", r);
  801ac9:	50                   	push   %eax
  801aca:	68 a8 29 80 00       	push   $0x8029a8
  801acf:	68 89 00 00 00       	push   $0x89
  801ad4:	68 65 29 80 00       	push   $0x802965
  801ad9:	e8 b6 e6 ff ff       	call   800194 <_panic>
		return r;
  801ade:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ae4:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801aea:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801af0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af3:	5b                   	pop    %ebx
  801af4:	5e                   	pop    %esi
  801af5:	5f                   	pop    %edi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    
  801af8:	89 c7                	mov    %eax,%edi
  801afa:	e9 59 fe ff ff       	jmp    801958 <spawn+0x33f>
  801aff:	89 c7                	mov    %eax,%edi
  801b01:	e9 52 fe ff ff       	jmp    801958 <spawn+0x33f>
  801b06:	89 c7                	mov    %eax,%edi
  801b08:	e9 4b fe ff ff       	jmp    801958 <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b0d:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b14:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b17:	83 ec 08             	sub    $0x8,%esp
  801b1a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b20:	50                   	push   %eax
  801b21:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801b27:	e8 22 f2 ff ff       	call   800d4e <sys_env_set_trapframe>
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 81                	js     801ab4 <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b33:	83 ec 08             	sub    $0x8,%esp
  801b36:	6a 02                	push   $0x2
  801b38:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801b3e:	e8 c9 f1 ff ff       	call   800d0c <sys_env_set_status>
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	85 c0                	test   %eax,%eax
  801b48:	0f 88 7b ff ff ff    	js     801ac9 <spawn+0x4b0>
	return child;
  801b4e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b54:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801b5a:	eb 8e                	jmp    801aea <spawn+0x4d1>
		return -E_NO_MEM;
  801b5c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801b61:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801b67:	eb 81                	jmp    801aea <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  801b69:	83 ec 08             	sub    $0x8,%esp
  801b6c:	68 00 00 40 00       	push   $0x400000
  801b71:	6a 00                	push   $0x0
  801b73:	e8 52 f1 ff ff       	call   800cca <sys_page_unmap>
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801b81:	e9 64 ff ff ff       	jmp    801aea <spawn+0x4d1>

00801b86 <spawnl>:
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	56                   	push   %esi
  801b8a:	53                   	push   %ebx
	va_start(vl, arg0);
  801b8b:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801b93:	eb 05                	jmp    801b9a <spawnl+0x14>
		argc++;
  801b95:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801b98:	89 ca                	mov    %ecx,%edx
  801b9a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b9d:	83 3a 00             	cmpl   $0x0,(%edx)
  801ba0:	75 f3                	jne    801b95 <spawnl+0xf>
	const char *argv[argc+2];
  801ba2:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801ba9:	89 d3                	mov    %edx,%ebx
  801bab:	83 e3 f0             	and    $0xfffffff0,%ebx
  801bae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801bb4:	89 e1                	mov    %esp,%ecx
  801bb6:	29 d1                	sub    %edx,%ecx
  801bb8:	39 cc                	cmp    %ecx,%esp
  801bba:	74 10                	je     801bcc <spawnl+0x46>
  801bbc:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801bc2:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801bc9:	00 
  801bca:	eb ec                	jmp    801bb8 <spawnl+0x32>
  801bcc:	89 da                	mov    %ebx,%edx
  801bce:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801bd4:	29 d4                	sub    %edx,%esp
  801bd6:	85 d2                	test   %edx,%edx
  801bd8:	74 05                	je     801bdf <spawnl+0x59>
  801bda:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801bdf:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801be3:	89 da                	mov    %ebx,%edx
  801be5:	c1 ea 02             	shr    $0x2,%edx
  801be8:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bee:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801bf5:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801bfc:	00 
	va_start(vl, arg0);
  801bfd:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801c00:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801c02:	b8 00 00 00 00       	mov    $0x0,%eax
  801c07:	eb 0b                	jmp    801c14 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801c09:	83 c0 01             	add    $0x1,%eax
  801c0c:	8b 31                	mov    (%ecx),%esi
  801c0e:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801c11:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801c14:	39 d0                	cmp    %edx,%eax
  801c16:	75 f1                	jne    801c09 <spawnl+0x83>
	return spawn(prog, argv);
  801c18:	83 ec 08             	sub    $0x8,%esp
  801c1b:	53                   	push   %ebx
  801c1c:	ff 75 08             	push   0x8(%ebp)
  801c1f:	e8 f5 f9 ff ff       	call   801619 <spawn>
}
  801c24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	56                   	push   %esi
  801c2f:	53                   	push   %ebx
  801c30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c33:	83 ec 0c             	sub    $0xc,%esp
  801c36:	ff 75 08             	push   0x8(%ebp)
  801c39:	e8 08 f2 ff ff       	call   800e46 <fd2data>
  801c3e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c40:	83 c4 08             	add    $0x8,%esp
  801c43:	68 fe 29 80 00       	push   $0x8029fe
  801c48:	53                   	push   %ebx
  801c49:	e8 fb eb ff ff       	call   800849 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c4e:	8b 46 04             	mov    0x4(%esi),%eax
  801c51:	2b 06                	sub    (%esi),%eax
  801c53:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c59:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c60:	00 00 00 
	stat->st_dev = &devpipe;
  801c63:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c6a:	30 80 00 
	return 0;
}
  801c6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c75:	5b                   	pop    %ebx
  801c76:	5e                   	pop    %esi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	53                   	push   %ebx
  801c7d:	83 ec 0c             	sub    $0xc,%esp
  801c80:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c83:	53                   	push   %ebx
  801c84:	6a 00                	push   $0x0
  801c86:	e8 3f f0 ff ff       	call   800cca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c8b:	89 1c 24             	mov    %ebx,(%esp)
  801c8e:	e8 b3 f1 ff ff       	call   800e46 <fd2data>
  801c93:	83 c4 08             	add    $0x8,%esp
  801c96:	50                   	push   %eax
  801c97:	6a 00                	push   $0x0
  801c99:	e8 2c f0 ff ff       	call   800cca <sys_page_unmap>
}
  801c9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <_pipeisclosed>:
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	57                   	push   %edi
  801ca7:	56                   	push   %esi
  801ca8:	53                   	push   %ebx
  801ca9:	83 ec 1c             	sub    $0x1c,%esp
  801cac:	89 c7                	mov    %eax,%edi
  801cae:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801cb0:	a1 00 40 80 00       	mov    0x804000,%eax
  801cb5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cb8:	83 ec 0c             	sub    $0xc,%esp
  801cbb:	57                   	push   %edi
  801cbc:	e8 1c 05 00 00       	call   8021dd <pageref>
  801cc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cc4:	89 34 24             	mov    %esi,(%esp)
  801cc7:	e8 11 05 00 00       	call   8021dd <pageref>
		nn = thisenv->env_runs;
  801ccc:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801cd2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	39 cb                	cmp    %ecx,%ebx
  801cda:	74 1b                	je     801cf7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801cdc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cdf:	75 cf                	jne    801cb0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ce1:	8b 42 58             	mov    0x58(%edx),%eax
  801ce4:	6a 01                	push   $0x1
  801ce6:	50                   	push   %eax
  801ce7:	53                   	push   %ebx
  801ce8:	68 05 2a 80 00       	push   $0x802a05
  801ced:	e8 7d e5 ff ff       	call   80026f <cprintf>
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	eb b9                	jmp    801cb0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801cf7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cfa:	0f 94 c0             	sete   %al
  801cfd:	0f b6 c0             	movzbl %al,%eax
}
  801d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    

00801d08 <devpipe_write>:
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	57                   	push   %edi
  801d0c:	56                   	push   %esi
  801d0d:	53                   	push   %ebx
  801d0e:	83 ec 28             	sub    $0x28,%esp
  801d11:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d14:	56                   	push   %esi
  801d15:	e8 2c f1 ff ff       	call   800e46 <fd2data>
  801d1a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	bf 00 00 00 00       	mov    $0x0,%edi
  801d24:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d27:	75 09                	jne    801d32 <devpipe_write+0x2a>
	return i;
  801d29:	89 f8                	mov    %edi,%eax
  801d2b:	eb 23                	jmp    801d50 <devpipe_write+0x48>
			sys_yield();
  801d2d:	e8 f4 ee ff ff       	call   800c26 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d32:	8b 43 04             	mov    0x4(%ebx),%eax
  801d35:	8b 0b                	mov    (%ebx),%ecx
  801d37:	8d 51 20             	lea    0x20(%ecx),%edx
  801d3a:	39 d0                	cmp    %edx,%eax
  801d3c:	72 1a                	jb     801d58 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801d3e:	89 da                	mov    %ebx,%edx
  801d40:	89 f0                	mov    %esi,%eax
  801d42:	e8 5c ff ff ff       	call   801ca3 <_pipeisclosed>
  801d47:	85 c0                	test   %eax,%eax
  801d49:	74 e2                	je     801d2d <devpipe_write+0x25>
				return 0;
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d53:	5b                   	pop    %ebx
  801d54:	5e                   	pop    %esi
  801d55:	5f                   	pop    %edi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d5b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d5f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d62:	89 c2                	mov    %eax,%edx
  801d64:	c1 fa 1f             	sar    $0x1f,%edx
  801d67:	89 d1                	mov    %edx,%ecx
  801d69:	c1 e9 1b             	shr    $0x1b,%ecx
  801d6c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d6f:	83 e2 1f             	and    $0x1f,%edx
  801d72:	29 ca                	sub    %ecx,%edx
  801d74:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d78:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d7c:	83 c0 01             	add    $0x1,%eax
  801d7f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d82:	83 c7 01             	add    $0x1,%edi
  801d85:	eb 9d                	jmp    801d24 <devpipe_write+0x1c>

00801d87 <devpipe_read>:
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	57                   	push   %edi
  801d8b:	56                   	push   %esi
  801d8c:	53                   	push   %ebx
  801d8d:	83 ec 18             	sub    $0x18,%esp
  801d90:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d93:	57                   	push   %edi
  801d94:	e8 ad f0 ff ff       	call   800e46 <fd2data>
  801d99:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	be 00 00 00 00       	mov    $0x0,%esi
  801da3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801da6:	75 13                	jne    801dbb <devpipe_read+0x34>
	return i;
  801da8:	89 f0                	mov    %esi,%eax
  801daa:	eb 02                	jmp    801dae <devpipe_read+0x27>
				return i;
  801dac:	89 f0                	mov    %esi,%eax
}
  801dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5f                   	pop    %edi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    
			sys_yield();
  801db6:	e8 6b ee ff ff       	call   800c26 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801dbb:	8b 03                	mov    (%ebx),%eax
  801dbd:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dc0:	75 18                	jne    801dda <devpipe_read+0x53>
			if (i > 0)
  801dc2:	85 f6                	test   %esi,%esi
  801dc4:	75 e6                	jne    801dac <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801dc6:	89 da                	mov    %ebx,%edx
  801dc8:	89 f8                	mov    %edi,%eax
  801dca:	e8 d4 fe ff ff       	call   801ca3 <_pipeisclosed>
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	74 e3                	je     801db6 <devpipe_read+0x2f>
				return 0;
  801dd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd8:	eb d4                	jmp    801dae <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dda:	99                   	cltd   
  801ddb:	c1 ea 1b             	shr    $0x1b,%edx
  801dde:	01 d0                	add    %edx,%eax
  801de0:	83 e0 1f             	and    $0x1f,%eax
  801de3:	29 d0                	sub    %edx,%eax
  801de5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ded:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801df0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801df3:	83 c6 01             	add    $0x1,%esi
  801df6:	eb ab                	jmp    801da3 <devpipe_read+0x1c>

00801df8 <pipe>:
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	56                   	push   %esi
  801dfc:	53                   	push   %ebx
  801dfd:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e03:	50                   	push   %eax
  801e04:	e8 54 f0 ff ff       	call   800e5d <fd_alloc>
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	83 c4 10             	add    $0x10,%esp
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	0f 88 23 01 00 00    	js     801f39 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e16:	83 ec 04             	sub    $0x4,%esp
  801e19:	68 07 04 00 00       	push   $0x407
  801e1e:	ff 75 f4             	push   -0xc(%ebp)
  801e21:	6a 00                	push   $0x0
  801e23:	e8 1d ee ff ff       	call   800c45 <sys_page_alloc>
  801e28:	89 c3                	mov    %eax,%ebx
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	0f 88 04 01 00 00    	js     801f39 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801e35:	83 ec 0c             	sub    $0xc,%esp
  801e38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e3b:	50                   	push   %eax
  801e3c:	e8 1c f0 ff ff       	call   800e5d <fd_alloc>
  801e41:	89 c3                	mov    %eax,%ebx
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	85 c0                	test   %eax,%eax
  801e48:	0f 88 db 00 00 00    	js     801f29 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4e:	83 ec 04             	sub    $0x4,%esp
  801e51:	68 07 04 00 00       	push   $0x407
  801e56:	ff 75 f0             	push   -0x10(%ebp)
  801e59:	6a 00                	push   $0x0
  801e5b:	e8 e5 ed ff ff       	call   800c45 <sys_page_alloc>
  801e60:	89 c3                	mov    %eax,%ebx
  801e62:	83 c4 10             	add    $0x10,%esp
  801e65:	85 c0                	test   %eax,%eax
  801e67:	0f 88 bc 00 00 00    	js     801f29 <pipe+0x131>
	va = fd2data(fd0);
  801e6d:	83 ec 0c             	sub    $0xc,%esp
  801e70:	ff 75 f4             	push   -0xc(%ebp)
  801e73:	e8 ce ef ff ff       	call   800e46 <fd2data>
  801e78:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7a:	83 c4 0c             	add    $0xc,%esp
  801e7d:	68 07 04 00 00       	push   $0x407
  801e82:	50                   	push   %eax
  801e83:	6a 00                	push   $0x0
  801e85:	e8 bb ed ff ff       	call   800c45 <sys_page_alloc>
  801e8a:	89 c3                	mov    %eax,%ebx
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	0f 88 82 00 00 00    	js     801f19 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e97:	83 ec 0c             	sub    $0xc,%esp
  801e9a:	ff 75 f0             	push   -0x10(%ebp)
  801e9d:	e8 a4 ef ff ff       	call   800e46 <fd2data>
  801ea2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ea9:	50                   	push   %eax
  801eaa:	6a 00                	push   $0x0
  801eac:	56                   	push   %esi
  801ead:	6a 00                	push   $0x0
  801eaf:	e8 d4 ed ff ff       	call   800c88 <sys_page_map>
  801eb4:	89 c3                	mov    %eax,%ebx
  801eb6:	83 c4 20             	add    $0x20,%esp
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	78 4e                	js     801f0b <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801ebd:	a1 20 30 80 00       	mov    0x803020,%eax
  801ec2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ec5:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ec7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801eca:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801ed1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ed4:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ed9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ee0:	83 ec 0c             	sub    $0xc,%esp
  801ee3:	ff 75 f4             	push   -0xc(%ebp)
  801ee6:	e8 4b ef ff ff       	call   800e36 <fd2num>
  801eeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eee:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ef0:	83 c4 04             	add    $0x4,%esp
  801ef3:	ff 75 f0             	push   -0x10(%ebp)
  801ef6:	e8 3b ef ff ff       	call   800e36 <fd2num>
  801efb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801efe:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f09:	eb 2e                	jmp    801f39 <pipe+0x141>
	sys_page_unmap(0, va);
  801f0b:	83 ec 08             	sub    $0x8,%esp
  801f0e:	56                   	push   %esi
  801f0f:	6a 00                	push   $0x0
  801f11:	e8 b4 ed ff ff       	call   800cca <sys_page_unmap>
  801f16:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f19:	83 ec 08             	sub    $0x8,%esp
  801f1c:	ff 75 f0             	push   -0x10(%ebp)
  801f1f:	6a 00                	push   $0x0
  801f21:	e8 a4 ed ff ff       	call   800cca <sys_page_unmap>
  801f26:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f29:	83 ec 08             	sub    $0x8,%esp
  801f2c:	ff 75 f4             	push   -0xc(%ebp)
  801f2f:	6a 00                	push   $0x0
  801f31:	e8 94 ed ff ff       	call   800cca <sys_page_unmap>
  801f36:	83 c4 10             	add    $0x10,%esp
}
  801f39:	89 d8                	mov    %ebx,%eax
  801f3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f3e:	5b                   	pop    %ebx
  801f3f:	5e                   	pop    %esi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <pipeisclosed>:
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4b:	50                   	push   %eax
  801f4c:	ff 75 08             	push   0x8(%ebp)
  801f4f:	e8 59 ef ff ff       	call   800ead <fd_lookup>
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 c0                	test   %eax,%eax
  801f59:	78 18                	js     801f73 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801f5b:	83 ec 0c             	sub    $0xc,%esp
  801f5e:	ff 75 f4             	push   -0xc(%ebp)
  801f61:	e8 e0 ee ff ff       	call   800e46 <fd2data>
  801f66:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6b:	e8 33 fd ff ff       	call   801ca3 <_pipeisclosed>
  801f70:	83 c4 10             	add    $0x10,%esp
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801f75:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7a:	c3                   	ret    

00801f7b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f81:	68 1d 2a 80 00       	push   $0x802a1d
  801f86:	ff 75 0c             	push   0xc(%ebp)
  801f89:	e8 bb e8 ff ff       	call   800849 <strcpy>
	return 0;
}
  801f8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f93:	c9                   	leave  
  801f94:	c3                   	ret    

00801f95 <devcons_write>:
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	57                   	push   %edi
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fa1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fa6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fac:	eb 2e                	jmp    801fdc <devcons_write+0x47>
		m = n - tot;
  801fae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fb1:	29 f3                	sub    %esi,%ebx
  801fb3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801fb8:	39 c3                	cmp    %eax,%ebx
  801fba:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fbd:	83 ec 04             	sub    $0x4,%esp
  801fc0:	53                   	push   %ebx
  801fc1:	89 f0                	mov    %esi,%eax
  801fc3:	03 45 0c             	add    0xc(%ebp),%eax
  801fc6:	50                   	push   %eax
  801fc7:	57                   	push   %edi
  801fc8:	e8 12 ea ff ff       	call   8009df <memmove>
		sys_cputs(buf, m);
  801fcd:	83 c4 08             	add    $0x8,%esp
  801fd0:	53                   	push   %ebx
  801fd1:	57                   	push   %edi
  801fd2:	e8 b2 eb ff ff       	call   800b89 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fd7:	01 de                	add    %ebx,%esi
  801fd9:	83 c4 10             	add    $0x10,%esp
  801fdc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fdf:	72 cd                	jb     801fae <devcons_write+0x19>
}
  801fe1:	89 f0                	mov    %esi,%eax
  801fe3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe6:	5b                   	pop    %ebx
  801fe7:	5e                   	pop    %esi
  801fe8:	5f                   	pop    %edi
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    

00801feb <devcons_read>:
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	83 ec 08             	sub    $0x8,%esp
  801ff1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ff6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ffa:	75 07                	jne    802003 <devcons_read+0x18>
  801ffc:	eb 1f                	jmp    80201d <devcons_read+0x32>
		sys_yield();
  801ffe:	e8 23 ec ff ff       	call   800c26 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802003:	e8 9f eb ff ff       	call   800ba7 <sys_cgetc>
  802008:	85 c0                	test   %eax,%eax
  80200a:	74 f2                	je     801ffe <devcons_read+0x13>
	if (c < 0)
  80200c:	78 0f                	js     80201d <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80200e:	83 f8 04             	cmp    $0x4,%eax
  802011:	74 0c                	je     80201f <devcons_read+0x34>
	*(char*)vbuf = c;
  802013:	8b 55 0c             	mov    0xc(%ebp),%edx
  802016:	88 02                	mov    %al,(%edx)
	return 1;
  802018:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    
		return 0;
  80201f:	b8 00 00 00 00       	mov    $0x0,%eax
  802024:	eb f7                	jmp    80201d <devcons_read+0x32>

00802026 <cputchar>:
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80202c:	8b 45 08             	mov    0x8(%ebp),%eax
  80202f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802032:	6a 01                	push   $0x1
  802034:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802037:	50                   	push   %eax
  802038:	e8 4c eb ff ff       	call   800b89 <sys_cputs>
}
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <getchar>:
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802048:	6a 01                	push   $0x1
  80204a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80204d:	50                   	push   %eax
  80204e:	6a 00                	push   $0x0
  802050:	e8 bc f0 ff ff       	call   801111 <read>
	if (r < 0)
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	85 c0                	test   %eax,%eax
  80205a:	78 06                	js     802062 <getchar+0x20>
	if (r < 1)
  80205c:	74 06                	je     802064 <getchar+0x22>
	return c;
  80205e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802062:	c9                   	leave  
  802063:	c3                   	ret    
		return -E_EOF;
  802064:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802069:	eb f7                	jmp    802062 <getchar+0x20>

0080206b <iscons>:
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802071:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802074:	50                   	push   %eax
  802075:	ff 75 08             	push   0x8(%ebp)
  802078:	e8 30 ee ff ff       	call   800ead <fd_lookup>
  80207d:	83 c4 10             	add    $0x10,%esp
  802080:	85 c0                	test   %eax,%eax
  802082:	78 11                	js     802095 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802084:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802087:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80208d:	39 10                	cmp    %edx,(%eax)
  80208f:	0f 94 c0             	sete   %al
  802092:	0f b6 c0             	movzbl %al,%eax
}
  802095:	c9                   	leave  
  802096:	c3                   	ret    

00802097 <opencons>:
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80209d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a0:	50                   	push   %eax
  8020a1:	e8 b7 ed ff ff       	call   800e5d <fd_alloc>
  8020a6:	83 c4 10             	add    $0x10,%esp
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	78 3a                	js     8020e7 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ad:	83 ec 04             	sub    $0x4,%esp
  8020b0:	68 07 04 00 00       	push   $0x407
  8020b5:	ff 75 f4             	push   -0xc(%ebp)
  8020b8:	6a 00                	push   $0x0
  8020ba:	e8 86 eb ff ff       	call   800c45 <sys_page_alloc>
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	78 21                	js     8020e7 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8020c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020cf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020db:	83 ec 0c             	sub    $0xc,%esp
  8020de:	50                   	push   %eax
  8020df:	e8 52 ed ff ff       	call   800e36 <fd2num>
  8020e4:	83 c4 10             	add    $0x10,%esp
}
  8020e7:	c9                   	leave  
  8020e8:	c3                   	ret    

008020e9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	56                   	push   %esi
  8020ed:	53                   	push   %ebx
  8020ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8020f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020fe:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802101:	83 ec 0c             	sub    $0xc,%esp
  802104:	50                   	push   %eax
  802105:	e8 eb ec ff ff       	call   800df5 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	85 f6                	test   %esi,%esi
  80210f:	74 14                	je     802125 <ipc_recv+0x3c>
  802111:	ba 00 00 00 00       	mov    $0x0,%edx
  802116:	85 c0                	test   %eax,%eax
  802118:	78 09                	js     802123 <ipc_recv+0x3a>
  80211a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802120:	8b 52 74             	mov    0x74(%edx),%edx
  802123:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802125:	85 db                	test   %ebx,%ebx
  802127:	74 14                	je     80213d <ipc_recv+0x54>
  802129:	ba 00 00 00 00       	mov    $0x0,%edx
  80212e:	85 c0                	test   %eax,%eax
  802130:	78 09                	js     80213b <ipc_recv+0x52>
  802132:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802138:	8b 52 78             	mov    0x78(%edx),%edx
  80213b:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80213d:	85 c0                	test   %eax,%eax
  80213f:	78 08                	js     802149 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802141:	a1 00 40 80 00       	mov    0x804000,%eax
  802146:	8b 40 70             	mov    0x70(%eax),%eax
}
  802149:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214c:	5b                   	pop    %ebx
  80214d:	5e                   	pop    %esi
  80214e:	5d                   	pop    %ebp
  80214f:	c3                   	ret    

00802150 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	57                   	push   %edi
  802154:	56                   	push   %esi
  802155:	53                   	push   %ebx
  802156:	83 ec 0c             	sub    $0xc,%esp
  802159:	8b 7d 08             	mov    0x8(%ebp),%edi
  80215c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80215f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802162:	85 db                	test   %ebx,%ebx
  802164:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802169:	0f 44 d8             	cmove  %eax,%ebx
  80216c:	eb 05                	jmp    802173 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80216e:	e8 b3 ea ff ff       	call   800c26 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802173:	ff 75 14             	push   0x14(%ebp)
  802176:	53                   	push   %ebx
  802177:	56                   	push   %esi
  802178:	57                   	push   %edi
  802179:	e8 54 ec ff ff       	call   800dd2 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80217e:	83 c4 10             	add    $0x10,%esp
  802181:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802184:	74 e8                	je     80216e <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802186:	85 c0                	test   %eax,%eax
  802188:	78 08                	js     802192 <ipc_send+0x42>
	}while (r<0);

}
  80218a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802192:	50                   	push   %eax
  802193:	68 29 2a 80 00       	push   $0x802a29
  802198:	6a 3d                	push   $0x3d
  80219a:	68 3d 2a 80 00       	push   $0x802a3d
  80219f:	e8 f0 df ff ff       	call   800194 <_panic>

008021a4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021aa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021af:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021b2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021b8:	8b 52 50             	mov    0x50(%edx),%edx
  8021bb:	39 ca                	cmp    %ecx,%edx
  8021bd:	74 11                	je     8021d0 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8021bf:	83 c0 01             	add    $0x1,%eax
  8021c2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021c7:	75 e6                	jne    8021af <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8021c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ce:	eb 0b                	jmp    8021db <ipc_find_env+0x37>
			return envs[i].env_id;
  8021d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021d8:	8b 40 48             	mov    0x48(%eax),%eax
}
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    

008021dd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021dd:	55                   	push   %ebp
  8021de:	89 e5                	mov    %esp,%ebp
  8021e0:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e3:	89 c2                	mov    %eax,%edx
  8021e5:	c1 ea 16             	shr    $0x16,%edx
  8021e8:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8021ef:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8021f4:	f6 c1 01             	test   $0x1,%cl
  8021f7:	74 1c                	je     802215 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8021f9:	c1 e8 0c             	shr    $0xc,%eax
  8021fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802203:	a8 01                	test   $0x1,%al
  802205:	74 0e                	je     802215 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802207:	c1 e8 0c             	shr    $0xc,%eax
  80220a:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802211:	ef 
  802212:	0f b7 d2             	movzwl %dx,%edx
}
  802215:	89 d0                	mov    %edx,%eax
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	66 90                	xchg   %ax,%ax
  80221b:	66 90                	xchg   %ax,%ax
  80221d:	66 90                	xchg   %ax,%ax
  80221f:	90                   	nop

00802220 <__udivdi3>:
  802220:	f3 0f 1e fb          	endbr32 
  802224:	55                   	push   %ebp
  802225:	57                   	push   %edi
  802226:	56                   	push   %esi
  802227:	53                   	push   %ebx
  802228:	83 ec 1c             	sub    $0x1c,%esp
  80222b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80222f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802233:	8b 74 24 34          	mov    0x34(%esp),%esi
  802237:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80223b:	85 c0                	test   %eax,%eax
  80223d:	75 19                	jne    802258 <__udivdi3+0x38>
  80223f:	39 f3                	cmp    %esi,%ebx
  802241:	76 4d                	jbe    802290 <__udivdi3+0x70>
  802243:	31 ff                	xor    %edi,%edi
  802245:	89 e8                	mov    %ebp,%eax
  802247:	89 f2                	mov    %esi,%edx
  802249:	f7 f3                	div    %ebx
  80224b:	89 fa                	mov    %edi,%edx
  80224d:	83 c4 1c             	add    $0x1c,%esp
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    
  802255:	8d 76 00             	lea    0x0(%esi),%esi
  802258:	39 f0                	cmp    %esi,%eax
  80225a:	76 14                	jbe    802270 <__udivdi3+0x50>
  80225c:	31 ff                	xor    %edi,%edi
  80225e:	31 c0                	xor    %eax,%eax
  802260:	89 fa                	mov    %edi,%edx
  802262:	83 c4 1c             	add    $0x1c,%esp
  802265:	5b                   	pop    %ebx
  802266:	5e                   	pop    %esi
  802267:	5f                   	pop    %edi
  802268:	5d                   	pop    %ebp
  802269:	c3                   	ret    
  80226a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802270:	0f bd f8             	bsr    %eax,%edi
  802273:	83 f7 1f             	xor    $0x1f,%edi
  802276:	75 48                	jne    8022c0 <__udivdi3+0xa0>
  802278:	39 f0                	cmp    %esi,%eax
  80227a:	72 06                	jb     802282 <__udivdi3+0x62>
  80227c:	31 c0                	xor    %eax,%eax
  80227e:	39 eb                	cmp    %ebp,%ebx
  802280:	77 de                	ja     802260 <__udivdi3+0x40>
  802282:	b8 01 00 00 00       	mov    $0x1,%eax
  802287:	eb d7                	jmp    802260 <__udivdi3+0x40>
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 d9                	mov    %ebx,%ecx
  802292:	85 db                	test   %ebx,%ebx
  802294:	75 0b                	jne    8022a1 <__udivdi3+0x81>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f3                	div    %ebx
  80229f:	89 c1                	mov    %eax,%ecx
  8022a1:	31 d2                	xor    %edx,%edx
  8022a3:	89 f0                	mov    %esi,%eax
  8022a5:	f7 f1                	div    %ecx
  8022a7:	89 c6                	mov    %eax,%esi
  8022a9:	89 e8                	mov    %ebp,%eax
  8022ab:	89 f7                	mov    %esi,%edi
  8022ad:	f7 f1                	div    %ecx
  8022af:	89 fa                	mov    %edi,%edx
  8022b1:	83 c4 1c             	add    $0x1c,%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	5e                   	pop    %esi
  8022b6:	5f                   	pop    %edi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 f9                	mov    %edi,%ecx
  8022c2:	ba 20 00 00 00       	mov    $0x20,%edx
  8022c7:	29 fa                	sub    %edi,%edx
  8022c9:	d3 e0                	shl    %cl,%eax
  8022cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022cf:	89 d1                	mov    %edx,%ecx
  8022d1:	89 d8                	mov    %ebx,%eax
  8022d3:	d3 e8                	shr    %cl,%eax
  8022d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022d9:	09 c1                	or     %eax,%ecx
  8022db:	89 f0                	mov    %esi,%eax
  8022dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	d3 e3                	shl    %cl,%ebx
  8022e5:	89 d1                	mov    %edx,%ecx
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 f9                	mov    %edi,%ecx
  8022eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8022ef:	89 eb                	mov    %ebp,%ebx
  8022f1:	d3 e6                	shl    %cl,%esi
  8022f3:	89 d1                	mov    %edx,%ecx
  8022f5:	d3 eb                	shr    %cl,%ebx
  8022f7:	09 f3                	or     %esi,%ebx
  8022f9:	89 c6                	mov    %eax,%esi
  8022fb:	89 f2                	mov    %esi,%edx
  8022fd:	89 d8                	mov    %ebx,%eax
  8022ff:	f7 74 24 08          	divl   0x8(%esp)
  802303:	89 d6                	mov    %edx,%esi
  802305:	89 c3                	mov    %eax,%ebx
  802307:	f7 64 24 0c          	mull   0xc(%esp)
  80230b:	39 d6                	cmp    %edx,%esi
  80230d:	72 19                	jb     802328 <__udivdi3+0x108>
  80230f:	89 f9                	mov    %edi,%ecx
  802311:	d3 e5                	shl    %cl,%ebp
  802313:	39 c5                	cmp    %eax,%ebp
  802315:	73 04                	jae    80231b <__udivdi3+0xfb>
  802317:	39 d6                	cmp    %edx,%esi
  802319:	74 0d                	je     802328 <__udivdi3+0x108>
  80231b:	89 d8                	mov    %ebx,%eax
  80231d:	31 ff                	xor    %edi,%edi
  80231f:	e9 3c ff ff ff       	jmp    802260 <__udivdi3+0x40>
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80232b:	31 ff                	xor    %edi,%edi
  80232d:	e9 2e ff ff ff       	jmp    802260 <__udivdi3+0x40>
  802332:	66 90                	xchg   %ax,%ax
  802334:	66 90                	xchg   %ax,%ax
  802336:	66 90                	xchg   %ax,%ax
  802338:	66 90                	xchg   %ax,%ax
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <__umoddi3>:
  802340:	f3 0f 1e fb          	endbr32 
  802344:	55                   	push   %ebp
  802345:	57                   	push   %edi
  802346:	56                   	push   %esi
  802347:	53                   	push   %ebx
  802348:	83 ec 1c             	sub    $0x1c,%esp
  80234b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80234f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802353:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802357:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80235b:	89 f0                	mov    %esi,%eax
  80235d:	89 da                	mov    %ebx,%edx
  80235f:	85 ff                	test   %edi,%edi
  802361:	75 15                	jne    802378 <__umoddi3+0x38>
  802363:	39 dd                	cmp    %ebx,%ebp
  802365:	76 39                	jbe    8023a0 <__umoddi3+0x60>
  802367:	f7 f5                	div    %ebp
  802369:	89 d0                	mov    %edx,%eax
  80236b:	31 d2                	xor    %edx,%edx
  80236d:	83 c4 1c             	add    $0x1c,%esp
  802370:	5b                   	pop    %ebx
  802371:	5e                   	pop    %esi
  802372:	5f                   	pop    %edi
  802373:	5d                   	pop    %ebp
  802374:	c3                   	ret    
  802375:	8d 76 00             	lea    0x0(%esi),%esi
  802378:	39 df                	cmp    %ebx,%edi
  80237a:	77 f1                	ja     80236d <__umoddi3+0x2d>
  80237c:	0f bd cf             	bsr    %edi,%ecx
  80237f:	83 f1 1f             	xor    $0x1f,%ecx
  802382:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802386:	75 40                	jne    8023c8 <__umoddi3+0x88>
  802388:	39 df                	cmp    %ebx,%edi
  80238a:	72 04                	jb     802390 <__umoddi3+0x50>
  80238c:	39 f5                	cmp    %esi,%ebp
  80238e:	77 dd                	ja     80236d <__umoddi3+0x2d>
  802390:	89 da                	mov    %ebx,%edx
  802392:	89 f0                	mov    %esi,%eax
  802394:	29 e8                	sub    %ebp,%eax
  802396:	19 fa                	sbb    %edi,%edx
  802398:	eb d3                	jmp    80236d <__umoddi3+0x2d>
  80239a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023a0:	89 e9                	mov    %ebp,%ecx
  8023a2:	85 ed                	test   %ebp,%ebp
  8023a4:	75 0b                	jne    8023b1 <__umoddi3+0x71>
  8023a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	f7 f5                	div    %ebp
  8023af:	89 c1                	mov    %eax,%ecx
  8023b1:	89 d8                	mov    %ebx,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f1                	div    %ecx
  8023b7:	89 f0                	mov    %esi,%eax
  8023b9:	f7 f1                	div    %ecx
  8023bb:	89 d0                	mov    %edx,%eax
  8023bd:	31 d2                	xor    %edx,%edx
  8023bf:	eb ac                	jmp    80236d <__umoddi3+0x2d>
  8023c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023cc:	ba 20 00 00 00       	mov    $0x20,%edx
  8023d1:	29 c2                	sub    %eax,%edx
  8023d3:	89 c1                	mov    %eax,%ecx
  8023d5:	89 e8                	mov    %ebp,%eax
  8023d7:	d3 e7                	shl    %cl,%edi
  8023d9:	89 d1                	mov    %edx,%ecx
  8023db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8023df:	d3 e8                	shr    %cl,%eax
  8023e1:	89 c1                	mov    %eax,%ecx
  8023e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023e7:	09 f9                	or     %edi,%ecx
  8023e9:	89 df                	mov    %ebx,%edi
  8023eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ef:	89 c1                	mov    %eax,%ecx
  8023f1:	d3 e5                	shl    %cl,%ebp
  8023f3:	89 d1                	mov    %edx,%ecx
  8023f5:	d3 ef                	shr    %cl,%edi
  8023f7:	89 c1                	mov    %eax,%ecx
  8023f9:	89 f0                	mov    %esi,%eax
  8023fb:	d3 e3                	shl    %cl,%ebx
  8023fd:	89 d1                	mov    %edx,%ecx
  8023ff:	89 fa                	mov    %edi,%edx
  802401:	d3 e8                	shr    %cl,%eax
  802403:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802408:	09 d8                	or     %ebx,%eax
  80240a:	f7 74 24 08          	divl   0x8(%esp)
  80240e:	89 d3                	mov    %edx,%ebx
  802410:	d3 e6                	shl    %cl,%esi
  802412:	f7 e5                	mul    %ebp
  802414:	89 c7                	mov    %eax,%edi
  802416:	89 d1                	mov    %edx,%ecx
  802418:	39 d3                	cmp    %edx,%ebx
  80241a:	72 06                	jb     802422 <__umoddi3+0xe2>
  80241c:	75 0e                	jne    80242c <__umoddi3+0xec>
  80241e:	39 c6                	cmp    %eax,%esi
  802420:	73 0a                	jae    80242c <__umoddi3+0xec>
  802422:	29 e8                	sub    %ebp,%eax
  802424:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802428:	89 d1                	mov    %edx,%ecx
  80242a:	89 c7                	mov    %eax,%edi
  80242c:	89 f5                	mov    %esi,%ebp
  80242e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802432:	29 fd                	sub    %edi,%ebp
  802434:	19 cb                	sbb    %ecx,%ebx
  802436:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80243b:	89 d8                	mov    %ebx,%eax
  80243d:	d3 e0                	shl    %cl,%eax
  80243f:	89 f1                	mov    %esi,%ecx
  802441:	d3 ed                	shr    %cl,%ebp
  802443:	d3 eb                	shr    %cl,%ebx
  802445:	09 e8                	or     %ebp,%eax
  802447:	89 da                	mov    %ebx,%edx
  802449:	83 c4 1c             	add    $0x1c,%esp
  80244c:	5b                   	pop    %ebx
  80244d:	5e                   	pop    %esi
  80244e:	5f                   	pop    %edi
  80244f:	5d                   	pop    %ebp
  802450:	c3                   	ret    
