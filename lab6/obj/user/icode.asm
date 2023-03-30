
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
  80004d:	e8 1d 02 00 00       	call   80026f <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 55 29 80 00 	movl   $0x802955,(%esp)
  800059:	e8 11 02 00 00       	call   80026f <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 68 29 80 00       	push   $0x802968
  800068:	e8 6d 15 00 00       	call   8015da <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	78 18                	js     80008e <umain+0x5b>
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
  800076:	83 ec 0c             	sub    $0xc,%esp
  800079:	68 91 29 80 00       	push   $0x802991
  80007e:	e8 ec 01 00 00       	call   80026f <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80008c:	eb 1f                	jmp    8000ad <umain+0x7a>
		panic("icode: open /motd: %e", fd);
  80008e:	50                   	push   %eax
  80008f:	68 6e 29 80 00       	push   $0x80296e
  800094:	6a 0f                	push   $0xf
  800096:	68 84 29 80 00       	push   $0x802984
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
  8000b7:	e8 bb 10 00 00       	call   801177 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 a4 29 80 00       	push   $0x8029a4
  8000cb:	e8 9f 01 00 00       	call   80026f <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 63 0f 00 00       	call   80103b <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  8000df:	e8 8b 01 00 00       	call   80026f <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 cc 29 80 00       	push   $0x8029cc
  8000f0:	68 d5 29 80 00       	push   $0x8029d5
  8000f5:	68 df 29 80 00       	push   $0x8029df
  8000fa:	68 de 29 80 00       	push   $0x8029de
  8000ff:	e8 e8 1a 00 00       	call   801bec <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	78 17                	js     800122 <umain+0xef>
		panic("icode: spawn /init: %e", r);

	cprintf("icode: exiting\n");
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	68 fb 29 80 00       	push   $0x8029fb
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
  800123:	68 e4 29 80 00       	push   $0x8029e4
  800128:	6a 1a                	push   $0x1a
  80012a:	68 84 29 80 00       	push   $0x802984
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
  800180:	e8 e3 0e 00 00       	call   801068 <close_all>
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
  8001b2:	68 18 2a 80 00       	push   $0x802a18
  8001b7:	e8 b3 00 00 00       	call   80026f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	push   0x10(%ebp)
  8001c3:	e8 56 00 00 00       	call   80021e <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 33 2f 80 00 	movl   $0x802f33,(%esp)
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
  8002d1:	e8 1a 24 00 00       	call   8026f0 <__udivdi3>
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
  80030f:	e8 fc 24 00 00       	call   802810 <__umoddi3>
  800314:	83 c4 14             	add    $0x14,%esp
  800317:	0f be 80 3b 2a 80 00 	movsbl 0x802a3b(%eax),%eax
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
  8003d1:	ff 24 85 80 2b 80 00 	jmp    *0x802b80(,%eax,4)
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
  80049f:	8b 14 85 e0 2c 80 00 	mov    0x802ce0(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	74 18                	je     8004c2 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004aa:	52                   	push   %edx
  8004ab:	68 15 2e 80 00       	push   $0x802e15
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 92 fe ff ff       	call   800349 <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ba:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004bd:	e9 66 02 00 00       	jmp    800728 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004c2:	50                   	push   %eax
  8004c3:	68 53 2a 80 00       	push   $0x802a53
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
  8004ea:	b8 4c 2a 80 00       	mov    $0x802a4c,%eax
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
  800bf6:	68 3f 2d 80 00       	push   $0x802d3f
  800bfb:	6a 2a                	push   $0x2a
  800bfd:	68 5c 2d 80 00       	push   $0x802d5c
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
  800c77:	68 3f 2d 80 00       	push   $0x802d3f
  800c7c:	6a 2a                	push   $0x2a
  800c7e:	68 5c 2d 80 00       	push   $0x802d5c
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
  800cb9:	68 3f 2d 80 00       	push   $0x802d3f
  800cbe:	6a 2a                	push   $0x2a
  800cc0:	68 5c 2d 80 00       	push   $0x802d5c
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
  800cfb:	68 3f 2d 80 00       	push   $0x802d3f
  800d00:	6a 2a                	push   $0x2a
  800d02:	68 5c 2d 80 00       	push   $0x802d5c
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
  800d3d:	68 3f 2d 80 00       	push   $0x802d3f
  800d42:	6a 2a                	push   $0x2a
  800d44:	68 5c 2d 80 00       	push   $0x802d5c
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
  800d7f:	68 3f 2d 80 00       	push   $0x802d3f
  800d84:	6a 2a                	push   $0x2a
  800d86:	68 5c 2d 80 00       	push   $0x802d5c
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
  800dc1:	68 3f 2d 80 00       	push   $0x802d3f
  800dc6:	6a 2a                	push   $0x2a
  800dc8:	68 5c 2d 80 00       	push   $0x802d5c
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
  800e25:	68 3f 2d 80 00       	push   $0x802d3f
  800e2a:	6a 2a                	push   $0x2a
  800e2c:	68 5c 2d 80 00       	push   $0x802d5c
  800e31:	e8 5e f3 ff ff       	call   800194 <_panic>

00800e36 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e41:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e46:	89 d1                	mov    %edx,%ecx
  800e48:	89 d3                	mov    %edx,%ebx
  800e4a:	89 d7                	mov    %edx,%edi
  800e4c:	89 d6                	mov    %edx,%esi
  800e4e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e6b:	89 df                	mov    %ebx,%edi
  800e6d:	89 de                	mov    %ebx,%esi
  800e6f:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e81:	8b 55 08             	mov    0x8(%ebp),%edx
  800e84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e87:	b8 10 00 00 00       	mov    $0x10,%eax
  800e8c:	89 df                	mov    %ebx,%edi
  800e8e:	89 de                	mov    %ebx,%esi
  800e90:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea2:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ead:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eb2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eb7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec6:	89 c2                	mov    %eax,%edx
  800ec8:	c1 ea 16             	shr    $0x16,%edx
  800ecb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed2:	f6 c2 01             	test   $0x1,%dl
  800ed5:	74 29                	je     800f00 <fd_alloc+0x42>
  800ed7:	89 c2                	mov    %eax,%edx
  800ed9:	c1 ea 0c             	shr    $0xc,%edx
  800edc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee3:	f6 c2 01             	test   $0x1,%dl
  800ee6:	74 18                	je     800f00 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800ee8:	05 00 10 00 00       	add    $0x1000,%eax
  800eed:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef2:	75 d2                	jne    800ec6 <fd_alloc+0x8>
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800ef9:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800efe:	eb 05                	jmp    800f05 <fd_alloc+0x47>
			return 0;
  800f00:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f05:	8b 55 08             	mov    0x8(%ebp),%edx
  800f08:	89 02                	mov    %eax,(%edx)
}
  800f0a:	89 c8                	mov    %ecx,%eax
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f14:	83 f8 1f             	cmp    $0x1f,%eax
  800f17:	77 30                	ja     800f49 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f19:	c1 e0 0c             	shl    $0xc,%eax
  800f1c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f21:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f27:	f6 c2 01             	test   $0x1,%dl
  800f2a:	74 24                	je     800f50 <fd_lookup+0x42>
  800f2c:	89 c2                	mov    %eax,%edx
  800f2e:	c1 ea 0c             	shr    $0xc,%edx
  800f31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f38:	f6 c2 01             	test   $0x1,%dl
  800f3b:	74 1a                	je     800f57 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f40:	89 02                	mov    %eax,(%edx)
	return 0;
  800f42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
		return -E_INVAL;
  800f49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4e:	eb f7                	jmp    800f47 <fd_lookup+0x39>
		return -E_INVAL;
  800f50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f55:	eb f0                	jmp    800f47 <fd_lookup+0x39>
  800f57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5c:	eb e9                	jmp    800f47 <fd_lookup+0x39>

00800f5e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	53                   	push   %ebx
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f68:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6d:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f72:	39 13                	cmp    %edx,(%ebx)
  800f74:	74 37                	je     800fad <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f76:	83 c0 01             	add    $0x1,%eax
  800f79:	8b 1c 85 e8 2d 80 00 	mov    0x802de8(,%eax,4),%ebx
  800f80:	85 db                	test   %ebx,%ebx
  800f82:	75 ee                	jne    800f72 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f84:	a1 00 40 80 00       	mov    0x804000,%eax
  800f89:	8b 40 48             	mov    0x48(%eax),%eax
  800f8c:	83 ec 04             	sub    $0x4,%esp
  800f8f:	52                   	push   %edx
  800f90:	50                   	push   %eax
  800f91:	68 6c 2d 80 00       	push   $0x802d6c
  800f96:	e8 d4 f2 ff ff       	call   80026f <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800fa3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa6:	89 1a                	mov    %ebx,(%edx)
}
  800fa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    
			return 0;
  800fad:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb2:	eb ef                	jmp    800fa3 <dev_lookup+0x45>

00800fb4 <fd_close>:
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	83 ec 24             	sub    $0x24,%esp
  800fbd:	8b 75 08             	mov    0x8(%ebp),%esi
  800fc0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fc7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fcd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd0:	50                   	push   %eax
  800fd1:	e8 38 ff ff ff       	call   800f0e <fd_lookup>
  800fd6:	89 c3                	mov    %eax,%ebx
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 05                	js     800fe4 <fd_close+0x30>
	    || fd != fd2)
  800fdf:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fe2:	74 16                	je     800ffa <fd_close+0x46>
		return (must_exist ? r : 0);
  800fe4:	89 f8                	mov    %edi,%eax
  800fe6:	84 c0                	test   %al,%al
  800fe8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fed:	0f 44 d8             	cmove  %eax,%ebx
}
  800ff0:	89 d8                	mov    %ebx,%eax
  800ff2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff5:	5b                   	pop    %ebx
  800ff6:	5e                   	pop    %esi
  800ff7:	5f                   	pop    %edi
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ffa:	83 ec 08             	sub    $0x8,%esp
  800ffd:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801000:	50                   	push   %eax
  801001:	ff 36                	push   (%esi)
  801003:	e8 56 ff ff ff       	call   800f5e <dev_lookup>
  801008:	89 c3                	mov    %eax,%ebx
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 1a                	js     80102b <fd_close+0x77>
		if (dev->dev_close)
  801011:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801014:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801017:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	74 0b                	je     80102b <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	56                   	push   %esi
  801024:	ff d0                	call   *%eax
  801026:	89 c3                	mov    %eax,%ebx
  801028:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80102b:	83 ec 08             	sub    $0x8,%esp
  80102e:	56                   	push   %esi
  80102f:	6a 00                	push   $0x0
  801031:	e8 94 fc ff ff       	call   800cca <sys_page_unmap>
	return r;
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	eb b5                	jmp    800ff0 <fd_close+0x3c>

0080103b <close>:

int
close(int fdnum)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801041:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801044:	50                   	push   %eax
  801045:	ff 75 08             	push   0x8(%ebp)
  801048:	e8 c1 fe ff ff       	call   800f0e <fd_lookup>
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	79 02                	jns    801056 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801054:	c9                   	leave  
  801055:	c3                   	ret    
		return fd_close(fd, 1);
  801056:	83 ec 08             	sub    $0x8,%esp
  801059:	6a 01                	push   $0x1
  80105b:	ff 75 f4             	push   -0xc(%ebp)
  80105e:	e8 51 ff ff ff       	call   800fb4 <fd_close>
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	eb ec                	jmp    801054 <close+0x19>

00801068 <close_all>:

void
close_all(void)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	53                   	push   %ebx
  80106c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80106f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	53                   	push   %ebx
  801078:	e8 be ff ff ff       	call   80103b <close>
	for (i = 0; i < MAXFD; i++)
  80107d:	83 c3 01             	add    $0x1,%ebx
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	83 fb 20             	cmp    $0x20,%ebx
  801086:	75 ec                	jne    801074 <close_all+0xc>
}
  801088:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801096:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801099:	50                   	push   %eax
  80109a:	ff 75 08             	push   0x8(%ebp)
  80109d:	e8 6c fe ff ff       	call   800f0e <fd_lookup>
  8010a2:	89 c3                	mov    %eax,%ebx
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 7f                	js     80112a <dup+0x9d>
		return r;
	close(newfdnum);
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	ff 75 0c             	push   0xc(%ebp)
  8010b1:	e8 85 ff ff ff       	call   80103b <close>

	newfd = INDEX2FD(newfdnum);
  8010b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b9:	c1 e6 0c             	shl    $0xc,%esi
  8010bc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010c5:	89 3c 24             	mov    %edi,(%esp)
  8010c8:	e8 da fd ff ff       	call   800ea7 <fd2data>
  8010cd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010cf:	89 34 24             	mov    %esi,(%esp)
  8010d2:	e8 d0 fd ff ff       	call   800ea7 <fd2data>
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010dd:	89 d8                	mov    %ebx,%eax
  8010df:	c1 e8 16             	shr    $0x16,%eax
  8010e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e9:	a8 01                	test   $0x1,%al
  8010eb:	74 11                	je     8010fe <dup+0x71>
  8010ed:	89 d8                	mov    %ebx,%eax
  8010ef:	c1 e8 0c             	shr    $0xc,%eax
  8010f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f9:	f6 c2 01             	test   $0x1,%dl
  8010fc:	75 36                	jne    801134 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010fe:	89 f8                	mov    %edi,%eax
  801100:	c1 e8 0c             	shr    $0xc,%eax
  801103:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	25 07 0e 00 00       	and    $0xe07,%eax
  801112:	50                   	push   %eax
  801113:	56                   	push   %esi
  801114:	6a 00                	push   $0x0
  801116:	57                   	push   %edi
  801117:	6a 00                	push   $0x0
  801119:	e8 6a fb ff ff       	call   800c88 <sys_page_map>
  80111e:	89 c3                	mov    %eax,%ebx
  801120:	83 c4 20             	add    $0x20,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	78 33                	js     80115a <dup+0xcd>
		goto err;

	return newfdnum;
  801127:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80112a:	89 d8                	mov    %ebx,%eax
  80112c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801134:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	25 07 0e 00 00       	and    $0xe07,%eax
  801143:	50                   	push   %eax
  801144:	ff 75 d4             	push   -0x2c(%ebp)
  801147:	6a 00                	push   $0x0
  801149:	53                   	push   %ebx
  80114a:	6a 00                	push   $0x0
  80114c:	e8 37 fb ff ff       	call   800c88 <sys_page_map>
  801151:	89 c3                	mov    %eax,%ebx
  801153:	83 c4 20             	add    $0x20,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	79 a4                	jns    8010fe <dup+0x71>
	sys_page_unmap(0, newfd);
  80115a:	83 ec 08             	sub    $0x8,%esp
  80115d:	56                   	push   %esi
  80115e:	6a 00                	push   $0x0
  801160:	e8 65 fb ff ff       	call   800cca <sys_page_unmap>
	sys_page_unmap(0, nva);
  801165:	83 c4 08             	add    $0x8,%esp
  801168:	ff 75 d4             	push   -0x2c(%ebp)
  80116b:	6a 00                	push   $0x0
  80116d:	e8 58 fb ff ff       	call   800cca <sys_page_unmap>
	return r;
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	eb b3                	jmp    80112a <dup+0x9d>

00801177 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	56                   	push   %esi
  80117b:	53                   	push   %ebx
  80117c:	83 ec 18             	sub    $0x18,%esp
  80117f:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801182:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801185:	50                   	push   %eax
  801186:	56                   	push   %esi
  801187:	e8 82 fd ff ff       	call   800f0e <fd_lookup>
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	85 c0                	test   %eax,%eax
  801191:	78 3c                	js     8011cf <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801193:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	ff 33                	push   (%ebx)
  80119f:	e8 ba fd ff ff       	call   800f5e <dev_lookup>
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 24                	js     8011cf <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011ab:	8b 43 08             	mov    0x8(%ebx),%eax
  8011ae:	83 e0 03             	and    $0x3,%eax
  8011b1:	83 f8 01             	cmp    $0x1,%eax
  8011b4:	74 20                	je     8011d6 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b9:	8b 40 08             	mov    0x8(%eax),%eax
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	74 37                	je     8011f7 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	ff 75 10             	push   0x10(%ebp)
  8011c6:	ff 75 0c             	push   0xc(%ebp)
  8011c9:	53                   	push   %ebx
  8011ca:	ff d0                	call   *%eax
  8011cc:	83 c4 10             	add    $0x10,%esp
}
  8011cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d6:	a1 00 40 80 00       	mov    0x804000,%eax
  8011db:	8b 40 48             	mov    0x48(%eax),%eax
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	56                   	push   %esi
  8011e2:	50                   	push   %eax
  8011e3:	68 ad 2d 80 00       	push   $0x802dad
  8011e8:	e8 82 f0 ff ff       	call   80026f <cprintf>
		return -E_INVAL;
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f5:	eb d8                	jmp    8011cf <read+0x58>
		return -E_NOT_SUPP;
  8011f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011fc:	eb d1                	jmp    8011cf <read+0x58>

008011fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80120d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801212:	eb 02                	jmp    801216 <readn+0x18>
  801214:	01 c3                	add    %eax,%ebx
  801216:	39 f3                	cmp    %esi,%ebx
  801218:	73 21                	jae    80123b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80121a:	83 ec 04             	sub    $0x4,%esp
  80121d:	89 f0                	mov    %esi,%eax
  80121f:	29 d8                	sub    %ebx,%eax
  801221:	50                   	push   %eax
  801222:	89 d8                	mov    %ebx,%eax
  801224:	03 45 0c             	add    0xc(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	57                   	push   %edi
  801229:	e8 49 ff ff ff       	call   801177 <read>
		if (m < 0)
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	78 04                	js     801239 <readn+0x3b>
			return m;
		if (m == 0)
  801235:	75 dd                	jne    801214 <readn+0x16>
  801237:	eb 02                	jmp    80123b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801239:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80123b:	89 d8                	mov    %ebx,%eax
  80123d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	56                   	push   %esi
  801249:	53                   	push   %ebx
  80124a:	83 ec 18             	sub    $0x18,%esp
  80124d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801250:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801253:	50                   	push   %eax
  801254:	53                   	push   %ebx
  801255:	e8 b4 fc ff ff       	call   800f0e <fd_lookup>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 37                	js     801298 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801261:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	ff 36                	push   (%esi)
  80126d:	e8 ec fc ff ff       	call   800f5e <dev_lookup>
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	78 1f                	js     801298 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801279:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80127d:	74 20                	je     80129f <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80127f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801282:	8b 40 0c             	mov    0xc(%eax),%eax
  801285:	85 c0                	test   %eax,%eax
  801287:	74 37                	je     8012c0 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	ff 75 10             	push   0x10(%ebp)
  80128f:	ff 75 0c             	push   0xc(%ebp)
  801292:	56                   	push   %esi
  801293:	ff d0                	call   *%eax
  801295:	83 c4 10             	add    $0x10,%esp
}
  801298:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80129f:	a1 00 40 80 00       	mov    0x804000,%eax
  8012a4:	8b 40 48             	mov    0x48(%eax),%eax
  8012a7:	83 ec 04             	sub    $0x4,%esp
  8012aa:	53                   	push   %ebx
  8012ab:	50                   	push   %eax
  8012ac:	68 c9 2d 80 00       	push   $0x802dc9
  8012b1:	e8 b9 ef ff ff       	call   80026f <cprintf>
		return -E_INVAL;
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012be:	eb d8                	jmp    801298 <write+0x53>
		return -E_NOT_SUPP;
  8012c0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c5:	eb d1                	jmp    801298 <write+0x53>

008012c7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d0:	50                   	push   %eax
  8012d1:	ff 75 08             	push   0x8(%ebp)
  8012d4:	e8 35 fc ff ff       	call   800f0e <fd_lookup>
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 0e                	js     8012ee <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	56                   	push   %esi
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 18             	sub    $0x18,%esp
  8012f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fe:	50                   	push   %eax
  8012ff:	53                   	push   %ebx
  801300:	e8 09 fc ff ff       	call   800f0e <fd_lookup>
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	78 34                	js     801340 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801315:	50                   	push   %eax
  801316:	ff 36                	push   (%esi)
  801318:	e8 41 fc ff ff       	call   800f5e <dev_lookup>
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 1c                	js     801340 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801324:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801328:	74 1d                	je     801347 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132d:	8b 40 18             	mov    0x18(%eax),%eax
  801330:	85 c0                	test   %eax,%eax
  801332:	74 34                	je     801368 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	ff 75 0c             	push   0xc(%ebp)
  80133a:	56                   	push   %esi
  80133b:	ff d0                	call   *%eax
  80133d:	83 c4 10             	add    $0x10,%esp
}
  801340:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801343:	5b                   	pop    %ebx
  801344:	5e                   	pop    %esi
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    
			thisenv->env_id, fdnum);
  801347:	a1 00 40 80 00       	mov    0x804000,%eax
  80134c:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80134f:	83 ec 04             	sub    $0x4,%esp
  801352:	53                   	push   %ebx
  801353:	50                   	push   %eax
  801354:	68 8c 2d 80 00       	push   $0x802d8c
  801359:	e8 11 ef ff ff       	call   80026f <cprintf>
		return -E_INVAL;
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801366:	eb d8                	jmp    801340 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801368:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80136d:	eb d1                	jmp    801340 <ftruncate+0x50>

0080136f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
  801374:	83 ec 18             	sub    $0x18,%esp
  801377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	ff 75 08             	push   0x8(%ebp)
  801381:	e8 88 fb ff ff       	call   800f0e <fd_lookup>
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 49                	js     8013d6 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801396:	50                   	push   %eax
  801397:	ff 36                	push   (%esi)
  801399:	e8 c0 fb ff ff       	call   800f5e <dev_lookup>
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 31                	js     8013d6 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ac:	74 2f                	je     8013dd <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013ae:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013b8:	00 00 00 
	stat->st_isdir = 0;
  8013bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013c2:	00 00 00 
	stat->st_dev = dev;
  8013c5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	53                   	push   %ebx
  8013cf:	56                   	push   %esi
  8013d0:	ff 50 14             	call   *0x14(%eax)
  8013d3:	83 c4 10             	add    $0x10,%esp
}
  8013d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    
		return -E_NOT_SUPP;
  8013dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e2:	eb f2                	jmp    8013d6 <fstat+0x67>

008013e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	56                   	push   %esi
  8013e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	6a 00                	push   $0x0
  8013ee:	ff 75 08             	push   0x8(%ebp)
  8013f1:	e8 e4 01 00 00       	call   8015da <open>
  8013f6:	89 c3                	mov    %eax,%ebx
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 1b                	js     80141a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	ff 75 0c             	push   0xc(%ebp)
  801405:	50                   	push   %eax
  801406:	e8 64 ff ff ff       	call   80136f <fstat>
  80140b:	89 c6                	mov    %eax,%esi
	close(fd);
  80140d:	89 1c 24             	mov    %ebx,(%esp)
  801410:	e8 26 fc ff ff       	call   80103b <close>
	return r;
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	89 f3                	mov    %esi,%ebx
}
  80141a:	89 d8                	mov    %ebx,%eax
  80141c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141f:	5b                   	pop    %ebx
  801420:	5e                   	pop    %esi
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    

00801423 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	56                   	push   %esi
  801427:	53                   	push   %ebx
  801428:	89 c6                	mov    %eax,%esi
  80142a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80142c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801433:	74 27                	je     80145c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801435:	6a 07                	push   $0x7
  801437:	68 00 50 80 00       	push   $0x805000
  80143c:	56                   	push   %esi
  80143d:	ff 35 00 60 80 00    	push   0x806000
  801443:	e8 d6 11 00 00       	call   80261e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801448:	83 c4 0c             	add    $0xc,%esp
  80144b:	6a 00                	push   $0x0
  80144d:	53                   	push   %ebx
  80144e:	6a 00                	push   $0x0
  801450:	e8 62 11 00 00       	call   8025b7 <ipc_recv>
}
  801455:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801458:	5b                   	pop    %ebx
  801459:	5e                   	pop    %esi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	6a 01                	push   $0x1
  801461:	e8 0c 12 00 00       	call   802672 <ipc_find_env>
  801466:	a3 00 60 80 00       	mov    %eax,0x806000
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	eb c5                	jmp    801435 <fsipc+0x12>

00801470 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	8b 40 0c             	mov    0xc(%eax),%eax
  80147c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801481:	8b 45 0c             	mov    0xc(%ebp),%eax
  801484:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801489:	ba 00 00 00 00       	mov    $0x0,%edx
  80148e:	b8 02 00 00 00       	mov    $0x2,%eax
  801493:	e8 8b ff ff ff       	call   801423 <fsipc>
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <devfile_flush>:
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8014b5:	e8 69 ff ff ff       	call   801423 <fsipc>
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <devfile_stat>:
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8014db:	e8 43 ff ff ff       	call   801423 <fsipc>
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 2c                	js     801510 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	68 00 50 80 00       	push   $0x805000
  8014ec:	53                   	push   %ebx
  8014ed:	e8 57 f3 ff ff       	call   800849 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801502:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <devfile_write>:
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	8b 45 10             	mov    0x10(%ebp),%eax
  80151e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801523:	39 d0                	cmp    %edx,%eax
  801525:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801528:	8b 55 08             	mov    0x8(%ebp),%edx
  80152b:	8b 52 0c             	mov    0xc(%edx),%edx
  80152e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801534:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801539:	50                   	push   %eax
  80153a:	ff 75 0c             	push   0xc(%ebp)
  80153d:	68 08 50 80 00       	push   $0x805008
  801542:	e8 98 f4 ff ff       	call   8009df <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801547:	ba 00 00 00 00       	mov    $0x0,%edx
  80154c:	b8 04 00 00 00       	mov    $0x4,%eax
  801551:	e8 cd fe ff ff       	call   801423 <fsipc>
}
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <devfile_read>:
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
  80155d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801560:	8b 45 08             	mov    0x8(%ebp),%eax
  801563:	8b 40 0c             	mov    0xc(%eax),%eax
  801566:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80156b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801571:	ba 00 00 00 00       	mov    $0x0,%edx
  801576:	b8 03 00 00 00       	mov    $0x3,%eax
  80157b:	e8 a3 fe ff ff       	call   801423 <fsipc>
  801580:	89 c3                	mov    %eax,%ebx
  801582:	85 c0                	test   %eax,%eax
  801584:	78 1f                	js     8015a5 <devfile_read+0x4d>
	assert(r <= n);
  801586:	39 f0                	cmp    %esi,%eax
  801588:	77 24                	ja     8015ae <devfile_read+0x56>
	assert(r <= PGSIZE);
  80158a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80158f:	7f 33                	jg     8015c4 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801591:	83 ec 04             	sub    $0x4,%esp
  801594:	50                   	push   %eax
  801595:	68 00 50 80 00       	push   $0x805000
  80159a:	ff 75 0c             	push   0xc(%ebp)
  80159d:	e8 3d f4 ff ff       	call   8009df <memmove>
	return r;
  8015a2:	83 c4 10             	add    $0x10,%esp
}
  8015a5:	89 d8                	mov    %ebx,%eax
  8015a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015aa:	5b                   	pop    %ebx
  8015ab:	5e                   	pop    %esi
  8015ac:	5d                   	pop    %ebp
  8015ad:	c3                   	ret    
	assert(r <= n);
  8015ae:	68 fc 2d 80 00       	push   $0x802dfc
  8015b3:	68 03 2e 80 00       	push   $0x802e03
  8015b8:	6a 7c                	push   $0x7c
  8015ba:	68 18 2e 80 00       	push   $0x802e18
  8015bf:	e8 d0 eb ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  8015c4:	68 23 2e 80 00       	push   $0x802e23
  8015c9:	68 03 2e 80 00       	push   $0x802e03
  8015ce:	6a 7d                	push   $0x7d
  8015d0:	68 18 2e 80 00       	push   $0x802e18
  8015d5:	e8 ba eb ff ff       	call   800194 <_panic>

008015da <open>:
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	56                   	push   %esi
  8015de:	53                   	push   %ebx
  8015df:	83 ec 1c             	sub    $0x1c,%esp
  8015e2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015e5:	56                   	push   %esi
  8015e6:	e8 23 f2 ff ff       	call   80080e <strlen>
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015f3:	7f 6c                	jg     801661 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015f5:	83 ec 0c             	sub    $0xc,%esp
  8015f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	e8 bd f8 ff ff       	call   800ebe <fd_alloc>
  801601:	89 c3                	mov    %eax,%ebx
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	85 c0                	test   %eax,%eax
  801608:	78 3c                	js     801646 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	56                   	push   %esi
  80160e:	68 00 50 80 00       	push   $0x805000
  801613:	e8 31 f2 ff ff       	call   800849 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801618:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801620:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801623:	b8 01 00 00 00       	mov    $0x1,%eax
  801628:	e8 f6 fd ff ff       	call   801423 <fsipc>
  80162d:	89 c3                	mov    %eax,%ebx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 19                	js     80164f <open+0x75>
	return fd2num(fd);
  801636:	83 ec 0c             	sub    $0xc,%esp
  801639:	ff 75 f4             	push   -0xc(%ebp)
  80163c:	e8 56 f8 ff ff       	call   800e97 <fd2num>
  801641:	89 c3                	mov    %eax,%ebx
  801643:	83 c4 10             	add    $0x10,%esp
}
  801646:	89 d8                	mov    %ebx,%eax
  801648:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    
		fd_close(fd, 0);
  80164f:	83 ec 08             	sub    $0x8,%esp
  801652:	6a 00                	push   $0x0
  801654:	ff 75 f4             	push   -0xc(%ebp)
  801657:	e8 58 f9 ff ff       	call   800fb4 <fd_close>
		return r;
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb e5                	jmp    801646 <open+0x6c>
		return -E_BAD_PATH;
  801661:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801666:	eb de                	jmp    801646 <open+0x6c>

00801668 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80166e:	ba 00 00 00 00       	mov    $0x0,%edx
  801673:	b8 08 00 00 00       	mov    $0x8,%eax
  801678:	e8 a6 fd ff ff       	call   801423 <fsipc>
}
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	57                   	push   %edi
  801683:	56                   	push   %esi
  801684:	53                   	push   %ebx
  801685:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80168b:	6a 00                	push   $0x0
  80168d:	ff 75 08             	push   0x8(%ebp)
  801690:	e8 45 ff ff ff       	call   8015da <open>
  801695:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	0f 88 aa 04 00 00    	js     801b50 <spawn+0x4d1>
  8016a6:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8016a8:	83 ec 04             	sub    $0x4,%esp
  8016ab:	68 00 02 00 00       	push   $0x200
  8016b0:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	57                   	push   %edi
  8016b8:	e8 41 fb ff ff       	call   8011fe <readn>
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016c5:	75 57                	jne    80171e <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  8016c7:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016ce:	45 4c 46 
  8016d1:	75 4b                	jne    80171e <spawn+0x9f>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016d3:	b8 07 00 00 00       	mov    $0x7,%eax
  8016d8:	cd 30                	int    $0x30
  8016da:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	0f 88 5c 04 00 00    	js     801b44 <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016ed:	6b f0 7c             	imul   $0x7c,%eax,%esi
  8016f0:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016f6:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016fc:	b9 11 00 00 00       	mov    $0x11,%ecx
  801701:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801703:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801709:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80170f:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801714:	be 00 00 00 00       	mov    $0x0,%esi
  801719:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  80171c:	eb 4b                	jmp    801769 <spawn+0xea>
		close(fd);
  80171e:	83 ec 0c             	sub    $0xc,%esp
  801721:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801727:	e8 0f f9 ff ff       	call   80103b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80172c:	83 c4 0c             	add    $0xc,%esp
  80172f:	68 7f 45 4c 46       	push   $0x464c457f
  801734:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  80173a:	68 2f 2e 80 00       	push   $0x802e2f
  80173f:	e8 2b eb ff ff       	call   80026f <cprintf>
		return -E_NOT_EXEC;
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  80174e:	ff ff ff 
  801751:	e9 fa 03 00 00       	jmp    801b50 <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  801756:	83 ec 0c             	sub    $0xc,%esp
  801759:	50                   	push   %eax
  80175a:	e8 af f0 ff ff       	call   80080e <strlen>
  80175f:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801763:	83 c3 01             	add    $0x1,%ebx
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801770:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801773:	85 c0                	test   %eax,%eax
  801775:	75 df                	jne    801756 <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801777:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  80177d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801783:	b8 00 10 40 00       	mov    $0x401000,%eax
  801788:	29 f0                	sub    %esi,%eax
  80178a:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80178c:	89 c2                	mov    %eax,%edx
  80178e:	83 e2 fc             	and    $0xfffffffc,%edx
  801791:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801798:	29 c2                	sub    %eax,%edx
  80179a:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8017a0:	8d 42 f8             	lea    -0x8(%edx),%eax
  8017a3:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8017a8:	0f 86 14 04 00 00    	jbe    801bc2 <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017ae:	83 ec 04             	sub    $0x4,%esp
  8017b1:	6a 07                	push   $0x7
  8017b3:	68 00 00 40 00       	push   $0x400000
  8017b8:	6a 00                	push   $0x0
  8017ba:	e8 86 f4 ff ff       	call   800c45 <sys_page_alloc>
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	0f 88 fd 03 00 00    	js     801bc7 <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017ca:	be 00 00 00 00       	mov    $0x0,%esi
  8017cf:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8017d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017d8:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017de:	7e 32                	jle    801812 <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  8017e0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017e6:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017ec:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	ff 34 b3             	push   (%ebx,%esi,4)
  8017f5:	57                   	push   %edi
  8017f6:	e8 4e f0 ff ff       	call   800849 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017fb:	83 c4 04             	add    $0x4,%esp
  8017fe:	ff 34 b3             	push   (%ebx,%esi,4)
  801801:	e8 08 f0 ff ff       	call   80080e <strlen>
  801806:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  80180a:	83 c6 01             	add    $0x1,%esi
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	eb c6                	jmp    8017d8 <spawn+0x159>
	}
	argv_store[argc] = 0;
  801812:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801818:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80181e:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801825:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80182b:	0f 85 8c 00 00 00    	jne    8018bd <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801831:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801837:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  80183d:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801840:	89 c8                	mov    %ecx,%eax
  801842:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801848:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80184b:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801850:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801856:	83 ec 0c             	sub    $0xc,%esp
  801859:	6a 07                	push   $0x7
  80185b:	68 00 d0 bf ee       	push   $0xeebfd000
  801860:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801866:	68 00 00 40 00       	push   $0x400000
  80186b:	6a 00                	push   $0x0
  80186d:	e8 16 f4 ff ff       	call   800c88 <sys_page_map>
  801872:	89 c3                	mov    %eax,%ebx
  801874:	83 c4 20             	add    $0x20,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	0f 88 50 03 00 00    	js     801bcf <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80187f:	83 ec 08             	sub    $0x8,%esp
  801882:	68 00 00 40 00       	push   $0x400000
  801887:	6a 00                	push   $0x0
  801889:	e8 3c f4 ff ff       	call   800cca <sys_page_unmap>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	0f 88 34 03 00 00    	js     801bcf <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80189b:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8018a1:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8018a8:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018ae:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8018b5:	00 00 00 
  8018b8:	e9 4e 01 00 00       	jmp    801a0b <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  8018bd:	68 bc 2e 80 00       	push   $0x802ebc
  8018c2:	68 03 2e 80 00       	push   $0x802e03
  8018c7:	68 f2 00 00 00       	push   $0xf2
  8018cc:	68 49 2e 80 00       	push   $0x802e49
  8018d1:	e8 be e8 ff ff       	call   800194 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018d6:	83 ec 04             	sub    $0x4,%esp
  8018d9:	6a 07                	push   $0x7
  8018db:	68 00 00 40 00       	push   $0x400000
  8018e0:	6a 00                	push   $0x0
  8018e2:	e8 5e f3 ff ff       	call   800c45 <sys_page_alloc>
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	0f 88 6c 02 00 00    	js     801b5e <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018fb:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801901:	50                   	push   %eax
  801902:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801908:	e8 ba f9 ff ff       	call   8012c7 <seek>
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	85 c0                	test   %eax,%eax
  801912:	0f 88 4d 02 00 00    	js     801b65 <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801918:	83 ec 04             	sub    $0x4,%esp
  80191b:	89 f8                	mov    %edi,%eax
  80191d:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801923:	ba 00 10 00 00       	mov    $0x1000,%edx
  801928:	39 d0                	cmp    %edx,%eax
  80192a:	0f 47 c2             	cmova  %edx,%eax
  80192d:	50                   	push   %eax
  80192e:	68 00 00 40 00       	push   $0x400000
  801933:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801939:	e8 c0 f8 ff ff       	call   8011fe <readn>
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	85 c0                	test   %eax,%eax
  801943:	0f 88 23 02 00 00    	js     801b6c <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801949:	83 ec 0c             	sub    $0xc,%esp
  80194c:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801952:	56                   	push   %esi
  801953:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801959:	68 00 00 40 00       	push   $0x400000
  80195e:	6a 00                	push   $0x0
  801960:	e8 23 f3 ff ff       	call   800c88 <sys_page_map>
  801965:	83 c4 20             	add    $0x20,%esp
  801968:	85 c0                	test   %eax,%eax
  80196a:	78 7c                	js     8019e8 <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	68 00 00 40 00       	push   $0x400000
  801974:	6a 00                	push   $0x0
  801976:	e8 4f f3 ff ff       	call   800cca <sys_page_unmap>
  80197b:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  80197e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801984:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80198a:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801990:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801996:	76 65                	jbe    8019fd <spawn+0x37e>
		if (i >= filesz) {
  801998:	39 df                	cmp    %ebx,%edi
  80199a:	0f 87 36 ff ff ff    	ja     8018d6 <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8019a0:	83 ec 04             	sub    $0x4,%esp
  8019a3:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  8019a9:	56                   	push   %esi
  8019aa:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8019b0:	e8 90 f2 ff ff       	call   800c45 <sys_page_alloc>
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	79 c2                	jns    80197e <spawn+0x2ff>
  8019bc:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8019c7:	e8 fa f1 ff ff       	call   800bc6 <sys_env_destroy>
	close(fd);
  8019cc:	83 c4 04             	add    $0x4,%esp
  8019cf:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8019d5:	e8 61 f6 ff ff       	call   80103b <close>
	return r;
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  8019e3:	e9 68 01 00 00       	jmp    801b50 <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  8019e8:	50                   	push   %eax
  8019e9:	68 55 2e 80 00       	push   $0x802e55
  8019ee:	68 25 01 00 00       	push   $0x125
  8019f3:	68 49 2e 80 00       	push   $0x802e49
  8019f8:	e8 97 e7 ff ff       	call   800194 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019fd:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801a04:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801a0b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a12:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801a18:	7e 67                	jle    801a81 <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  801a1a:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801a20:	83 39 01             	cmpl   $0x1,(%ecx)
  801a23:	75 d8                	jne    8019fd <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a25:	8b 41 18             	mov    0x18(%ecx),%eax
  801a28:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801a2e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801a31:	83 f8 01             	cmp    $0x1,%eax
  801a34:	19 c0                	sbb    %eax,%eax
  801a36:	83 e0 fe             	and    $0xfffffffe,%eax
  801a39:	83 c0 07             	add    $0x7,%eax
  801a3c:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a42:	8b 51 04             	mov    0x4(%ecx),%edx
  801a45:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801a4b:	8b 79 10             	mov    0x10(%ecx),%edi
  801a4e:	8b 59 14             	mov    0x14(%ecx),%ebx
  801a51:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a57:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  801a5a:	89 f0                	mov    %esi,%eax
  801a5c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801a61:	74 14                	je     801a77 <spawn+0x3f8>
		va -= i;
  801a63:	29 c6                	sub    %eax,%esi
		memsz += i;
  801a65:	01 c3                	add    %eax,%ebx
  801a67:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801a6d:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801a6f:	29 c2                	sub    %eax,%edx
  801a71:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801a77:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a7c:	e9 09 ff ff ff       	jmp    80198a <spawn+0x30b>
	close(fd);
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801a8a:	e8 ac f5 ff ff       	call   80103b <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801a8f:	e8 73 f1 ff ff       	call   800c07 <sys_getenvid>
  801a94:	89 c6                	mov    %eax,%esi
  801a96:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801a99:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801a9e:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801aa4:	eb 12                	jmp    801ab8 <spawn+0x439>
  801aa6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801aac:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801ab2:	0f 84 bb 00 00 00    	je     801b73 <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801ab8:	89 d8                	mov    %ebx,%eax
  801aba:	c1 e8 16             	shr    $0x16,%eax
  801abd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ac4:	a8 01                	test   $0x1,%al
  801ac6:	74 de                	je     801aa6 <spawn+0x427>
  801ac8:	89 d8                	mov    %ebx,%eax
  801aca:	c1 e8 0c             	shr    $0xc,%eax
  801acd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ad4:	f6 c2 01             	test   $0x1,%dl
  801ad7:	74 cd                	je     801aa6 <spawn+0x427>
  801ad9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ae0:	f6 c6 04             	test   $0x4,%dh
  801ae3:	74 c1                	je     801aa6 <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801ae5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801aec:	83 ec 0c             	sub    $0xc,%esp
  801aef:	25 07 0e 00 00       	and    $0xe07,%eax
  801af4:	50                   	push   %eax
  801af5:	53                   	push   %ebx
  801af6:	57                   	push   %edi
  801af7:	53                   	push   %ebx
  801af8:	56                   	push   %esi
  801af9:	e8 8a f1 ff ff       	call   800c88 <sys_page_map>
  801afe:	83 c4 20             	add    $0x20,%esp
  801b01:	85 c0                	test   %eax,%eax
  801b03:	79 a1                	jns    801aa6 <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  801b05:	50                   	push   %eax
  801b06:	68 a3 2e 80 00       	push   $0x802ea3
  801b0b:	68 82 00 00 00       	push   $0x82
  801b10:	68 49 2e 80 00       	push   $0x802e49
  801b15:	e8 7a e6 ff ff       	call   800194 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801b1a:	50                   	push   %eax
  801b1b:	68 72 2e 80 00       	push   $0x802e72
  801b20:	68 86 00 00 00       	push   $0x86
  801b25:	68 49 2e 80 00       	push   $0x802e49
  801b2a:	e8 65 e6 ff ff       	call   800194 <_panic>
		panic("sys_env_set_status: %e", r);
  801b2f:	50                   	push   %eax
  801b30:	68 8c 2e 80 00       	push   $0x802e8c
  801b35:	68 89 00 00 00       	push   $0x89
  801b3a:	68 49 2e 80 00       	push   $0x802e49
  801b3f:	e8 50 e6 ff ff       	call   800194 <_panic>
		return r;
  801b44:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b4a:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801b50:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    
  801b5e:	89 c7                	mov    %eax,%edi
  801b60:	e9 59 fe ff ff       	jmp    8019be <spawn+0x33f>
  801b65:	89 c7                	mov    %eax,%edi
  801b67:	e9 52 fe ff ff       	jmp    8019be <spawn+0x33f>
  801b6c:	89 c7                	mov    %eax,%edi
  801b6e:	e9 4b fe ff ff       	jmp    8019be <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b73:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b7a:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b7d:	83 ec 08             	sub    $0x8,%esp
  801b80:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b86:	50                   	push   %eax
  801b87:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801b8d:	e8 bc f1 ff ff       	call   800d4e <sys_env_set_trapframe>
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	85 c0                	test   %eax,%eax
  801b97:	78 81                	js     801b1a <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b99:	83 ec 08             	sub    $0x8,%esp
  801b9c:	6a 02                	push   $0x2
  801b9e:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801ba4:	e8 63 f1 ff ff       	call   800d0c <sys_env_set_status>
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	0f 88 7b ff ff ff    	js     801b2f <spawn+0x4b0>
	return child;
  801bb4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bba:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bc0:	eb 8e                	jmp    801b50 <spawn+0x4d1>
		return -E_NO_MEM;
  801bc2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801bc7:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bcd:	eb 81                	jmp    801b50 <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  801bcf:	83 ec 08             	sub    $0x8,%esp
  801bd2:	68 00 00 40 00       	push   $0x400000
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 ec f0 ff ff       	call   800cca <sys_page_unmap>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801be7:	e9 64 ff ff ff       	jmp    801b50 <spawn+0x4d1>

00801bec <spawnl>:
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	56                   	push   %esi
  801bf0:	53                   	push   %ebx
	va_start(vl, arg0);
  801bf1:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801bf4:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801bf9:	eb 05                	jmp    801c00 <spawnl+0x14>
		argc++;
  801bfb:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801bfe:	89 ca                	mov    %ecx,%edx
  801c00:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c03:	83 3a 00             	cmpl   $0x0,(%edx)
  801c06:	75 f3                	jne    801bfb <spawnl+0xf>
	const char *argv[argc+2];
  801c08:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801c0f:	89 d3                	mov    %edx,%ebx
  801c11:	83 e3 f0             	and    $0xfffffff0,%ebx
  801c14:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801c1a:	89 e1                	mov    %esp,%ecx
  801c1c:	29 d1                	sub    %edx,%ecx
  801c1e:	39 cc                	cmp    %ecx,%esp
  801c20:	74 10                	je     801c32 <spawnl+0x46>
  801c22:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801c28:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801c2f:	00 
  801c30:	eb ec                	jmp    801c1e <spawnl+0x32>
  801c32:	89 da                	mov    %ebx,%edx
  801c34:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801c3a:	29 d4                	sub    %edx,%esp
  801c3c:	85 d2                	test   %edx,%edx
  801c3e:	74 05                	je     801c45 <spawnl+0x59>
  801c40:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801c45:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801c49:	89 da                	mov    %ebx,%edx
  801c4b:	c1 ea 02             	shr    $0x2,%edx
  801c4e:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c54:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c5b:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801c62:	00 
	va_start(vl, arg0);
  801c63:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801c66:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6d:	eb 0b                	jmp    801c7a <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801c6f:	83 c0 01             	add    $0x1,%eax
  801c72:	8b 31                	mov    (%ecx),%esi
  801c74:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801c77:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801c7a:	39 d0                	cmp    %edx,%eax
  801c7c:	75 f1                	jne    801c6f <spawnl+0x83>
	return spawn(prog, argv);
  801c7e:	83 ec 08             	sub    $0x8,%esp
  801c81:	53                   	push   %ebx
  801c82:	ff 75 08             	push   0x8(%ebp)
  801c85:	e8 f5 f9 ff ff       	call   80167f <spawn>
}
  801c8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c97:	68 e2 2e 80 00       	push   $0x802ee2
  801c9c:	ff 75 0c             	push   0xc(%ebp)
  801c9f:	e8 a5 eb ff ff       	call   800849 <strcpy>
	return 0;
}
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca9:	c9                   	leave  
  801caa:	c3                   	ret    

00801cab <devsock_close>:
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	53                   	push   %ebx
  801caf:	83 ec 10             	sub    $0x10,%esp
  801cb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cb5:	53                   	push   %ebx
  801cb6:	e8 f0 09 00 00       	call   8026ab <pageref>
  801cbb:	89 c2                	mov    %eax,%edx
  801cbd:	83 c4 10             	add    $0x10,%esp
		return 0;
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801cc5:	83 fa 01             	cmp    $0x1,%edx
  801cc8:	74 05                	je     801ccf <devsock_close+0x24>
}
  801cca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801ccf:	83 ec 0c             	sub    $0xc,%esp
  801cd2:	ff 73 0c             	push   0xc(%ebx)
  801cd5:	e8 b7 02 00 00       	call   801f91 <nsipc_close>
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	eb eb                	jmp    801cca <devsock_close+0x1f>

00801cdf <devsock_write>:
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ce5:	6a 00                	push   $0x0
  801ce7:	ff 75 10             	push   0x10(%ebp)
  801cea:	ff 75 0c             	push   0xc(%ebp)
  801ced:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf0:	ff 70 0c             	push   0xc(%eax)
  801cf3:	e8 79 03 00 00       	call   802071 <nsipc_send>
}
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <devsock_read>:
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d00:	6a 00                	push   $0x0
  801d02:	ff 75 10             	push   0x10(%ebp)
  801d05:	ff 75 0c             	push   0xc(%ebp)
  801d08:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0b:	ff 70 0c             	push   0xc(%eax)
  801d0e:	e8 ef 02 00 00       	call   802002 <nsipc_recv>
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <fd2sockid>:
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d1b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d1e:	52                   	push   %edx
  801d1f:	50                   	push   %eax
  801d20:	e8 e9 f1 ff ff       	call   800f0e <fd_lookup>
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	78 10                	js     801d3c <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2f:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801d35:	39 08                	cmp    %ecx,(%eax)
  801d37:	75 05                	jne    801d3e <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801d39:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801d3c:	c9                   	leave  
  801d3d:	c3                   	ret    
		return -E_NOT_SUPP;
  801d3e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d43:	eb f7                	jmp    801d3c <fd2sockid+0x27>

00801d45 <alloc_sockfd>:
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	56                   	push   %esi
  801d49:	53                   	push   %ebx
  801d4a:	83 ec 1c             	sub    $0x1c,%esp
  801d4d:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801d4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d52:	50                   	push   %eax
  801d53:	e8 66 f1 ff ff       	call   800ebe <fd_alloc>
  801d58:	89 c3                	mov    %eax,%ebx
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 43                	js     801da4 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d61:	83 ec 04             	sub    $0x4,%esp
  801d64:	68 07 04 00 00       	push   $0x407
  801d69:	ff 75 f4             	push   -0xc(%ebp)
  801d6c:	6a 00                	push   $0x0
  801d6e:	e8 d2 ee ff ff       	call   800c45 <sys_page_alloc>
  801d73:	89 c3                	mov    %eax,%ebx
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	78 28                	js     801da4 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d85:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d91:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d94:	83 ec 0c             	sub    $0xc,%esp
  801d97:	50                   	push   %eax
  801d98:	e8 fa f0 ff ff       	call   800e97 <fd2num>
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	83 c4 10             	add    $0x10,%esp
  801da2:	eb 0c                	jmp    801db0 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	56                   	push   %esi
  801da8:	e8 e4 01 00 00       	call   801f91 <nsipc_close>
		return r;
  801dad:	83 c4 10             	add    $0x10,%esp
}
  801db0:	89 d8                	mov    %ebx,%eax
  801db2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    

00801db9 <accept>:
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc2:	e8 4e ff ff ff       	call   801d15 <fd2sockid>
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 1b                	js     801de6 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dcb:	83 ec 04             	sub    $0x4,%esp
  801dce:	ff 75 10             	push   0x10(%ebp)
  801dd1:	ff 75 0c             	push   0xc(%ebp)
  801dd4:	50                   	push   %eax
  801dd5:	e8 0e 01 00 00       	call   801ee8 <nsipc_accept>
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 05                	js     801de6 <accept+0x2d>
	return alloc_sockfd(r);
  801de1:	e8 5f ff ff ff       	call   801d45 <alloc_sockfd>
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <bind>:
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801dee:	8b 45 08             	mov    0x8(%ebp),%eax
  801df1:	e8 1f ff ff ff       	call   801d15 <fd2sockid>
  801df6:	85 c0                	test   %eax,%eax
  801df8:	78 12                	js     801e0c <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801dfa:	83 ec 04             	sub    $0x4,%esp
  801dfd:	ff 75 10             	push   0x10(%ebp)
  801e00:	ff 75 0c             	push   0xc(%ebp)
  801e03:	50                   	push   %eax
  801e04:	e8 31 01 00 00       	call   801f3a <nsipc_bind>
  801e09:	83 c4 10             	add    $0x10,%esp
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <shutdown>:
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	e8 f9 fe ff ff       	call   801d15 <fd2sockid>
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	78 0f                	js     801e2f <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801e20:	83 ec 08             	sub    $0x8,%esp
  801e23:	ff 75 0c             	push   0xc(%ebp)
  801e26:	50                   	push   %eax
  801e27:	e8 43 01 00 00       	call   801f6f <nsipc_shutdown>
  801e2c:	83 c4 10             	add    $0x10,%esp
}
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <connect>:
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	e8 d6 fe ff ff       	call   801d15 <fd2sockid>
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	78 12                	js     801e55 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801e43:	83 ec 04             	sub    $0x4,%esp
  801e46:	ff 75 10             	push   0x10(%ebp)
  801e49:	ff 75 0c             	push   0xc(%ebp)
  801e4c:	50                   	push   %eax
  801e4d:	e8 59 01 00 00       	call   801fab <nsipc_connect>
  801e52:	83 c4 10             	add    $0x10,%esp
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <listen>:
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e60:	e8 b0 fe ff ff       	call   801d15 <fd2sockid>
  801e65:	85 c0                	test   %eax,%eax
  801e67:	78 0f                	js     801e78 <listen+0x21>
	return nsipc_listen(r, backlog);
  801e69:	83 ec 08             	sub    $0x8,%esp
  801e6c:	ff 75 0c             	push   0xc(%ebp)
  801e6f:	50                   	push   %eax
  801e70:	e8 6b 01 00 00       	call   801fe0 <nsipc_listen>
  801e75:	83 c4 10             	add    $0x10,%esp
}
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    

00801e7a <socket>:

int
socket(int domain, int type, int protocol)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e80:	ff 75 10             	push   0x10(%ebp)
  801e83:	ff 75 0c             	push   0xc(%ebp)
  801e86:	ff 75 08             	push   0x8(%ebp)
  801e89:	e8 41 02 00 00       	call   8020cf <nsipc_socket>
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	85 c0                	test   %eax,%eax
  801e93:	78 05                	js     801e9a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e95:	e8 ab fe ff ff       	call   801d45 <alloc_sockfd>
}
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	53                   	push   %ebx
  801ea0:	83 ec 04             	sub    $0x4,%esp
  801ea3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ea5:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801eac:	74 26                	je     801ed4 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801eae:	6a 07                	push   $0x7
  801eb0:	68 00 70 80 00       	push   $0x807000
  801eb5:	53                   	push   %ebx
  801eb6:	ff 35 00 80 80 00    	push   0x808000
  801ebc:	e8 5d 07 00 00       	call   80261e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ec1:	83 c4 0c             	add    $0xc,%esp
  801ec4:	6a 00                	push   $0x0
  801ec6:	6a 00                	push   $0x0
  801ec8:	6a 00                	push   $0x0
  801eca:	e8 e8 06 00 00       	call   8025b7 <ipc_recv>
}
  801ecf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ed4:	83 ec 0c             	sub    $0xc,%esp
  801ed7:	6a 02                	push   $0x2
  801ed9:	e8 94 07 00 00       	call   802672 <ipc_find_env>
  801ede:	a3 00 80 80 00       	mov    %eax,0x808000
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	eb c6                	jmp    801eae <nsipc+0x12>

00801ee8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	56                   	push   %esi
  801eec:	53                   	push   %ebx
  801eed:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ef8:	8b 06                	mov    (%esi),%eax
  801efa:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801eff:	b8 01 00 00 00       	mov    $0x1,%eax
  801f04:	e8 93 ff ff ff       	call   801e9c <nsipc>
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	79 09                	jns    801f18 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801f0f:	89 d8                	mov    %ebx,%eax
  801f11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f14:	5b                   	pop    %ebx
  801f15:	5e                   	pop    %esi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f18:	83 ec 04             	sub    $0x4,%esp
  801f1b:	ff 35 10 70 80 00    	push   0x807010
  801f21:	68 00 70 80 00       	push   $0x807000
  801f26:	ff 75 0c             	push   0xc(%ebp)
  801f29:	e8 b1 ea ff ff       	call   8009df <memmove>
		*addrlen = ret->ret_addrlen;
  801f2e:	a1 10 70 80 00       	mov    0x807010,%eax
  801f33:	89 06                	mov    %eax,(%esi)
  801f35:	83 c4 10             	add    $0x10,%esp
	return r;
  801f38:	eb d5                	jmp    801f0f <nsipc_accept+0x27>

00801f3a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	53                   	push   %ebx
  801f3e:	83 ec 08             	sub    $0x8,%esp
  801f41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f44:	8b 45 08             	mov    0x8(%ebp),%eax
  801f47:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f4c:	53                   	push   %ebx
  801f4d:	ff 75 0c             	push   0xc(%ebp)
  801f50:	68 04 70 80 00       	push   $0x807004
  801f55:	e8 85 ea ff ff       	call   8009df <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f5a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f60:	b8 02 00 00 00       	mov    $0x2,%eax
  801f65:	e8 32 ff ff ff       	call   801e9c <nsipc>
}
  801f6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f75:	8b 45 08             	mov    0x8(%ebp),%eax
  801f78:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f80:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f85:	b8 03 00 00 00       	mov    $0x3,%eax
  801f8a:	e8 0d ff ff ff       	call   801e9c <nsipc>
}
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <nsipc_close>:

int
nsipc_close(int s)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f97:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9a:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801f9f:	b8 04 00 00 00       	mov    $0x4,%eax
  801fa4:	e8 f3 fe ff ff       	call   801e9c <nsipc>
}
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    

00801fab <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	53                   	push   %ebx
  801faf:	83 ec 08             	sub    $0x8,%esp
  801fb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fbd:	53                   	push   %ebx
  801fbe:	ff 75 0c             	push   0xc(%ebp)
  801fc1:	68 04 70 80 00       	push   $0x807004
  801fc6:	e8 14 ea ff ff       	call   8009df <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fcb:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801fd1:	b8 05 00 00 00       	mov    $0x5,%eax
  801fd6:	e8 c1 fe ff ff       	call   801e9c <nsipc>
}
  801fdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fde:	c9                   	leave  
  801fdf:	c3                   	ret    

00801fe0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801fee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801ff6:	b8 06 00 00 00       	mov    $0x6,%eax
  801ffb:	e8 9c fe ff ff       	call   801e9c <nsipc>
}
  802000:	c9                   	leave  
  802001:	c3                   	ret    

00802002 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	56                   	push   %esi
  802006:	53                   	push   %ebx
  802007:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80200a:	8b 45 08             	mov    0x8(%ebp),%eax
  80200d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802012:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802018:	8b 45 14             	mov    0x14(%ebp),%eax
  80201b:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802020:	b8 07 00 00 00       	mov    $0x7,%eax
  802025:	e8 72 fe ff ff       	call   801e9c <nsipc>
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	85 c0                	test   %eax,%eax
  80202e:	78 22                	js     802052 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  802030:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802035:	39 c6                	cmp    %eax,%esi
  802037:	0f 4e c6             	cmovle %esi,%eax
  80203a:	39 c3                	cmp    %eax,%ebx
  80203c:	7f 1d                	jg     80205b <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80203e:	83 ec 04             	sub    $0x4,%esp
  802041:	53                   	push   %ebx
  802042:	68 00 70 80 00       	push   $0x807000
  802047:	ff 75 0c             	push   0xc(%ebp)
  80204a:	e8 90 e9 ff ff       	call   8009df <memmove>
  80204f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802052:	89 d8                	mov    %ebx,%eax
  802054:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802057:	5b                   	pop    %ebx
  802058:	5e                   	pop    %esi
  802059:	5d                   	pop    %ebp
  80205a:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80205b:	68 ee 2e 80 00       	push   $0x802eee
  802060:	68 03 2e 80 00       	push   $0x802e03
  802065:	6a 62                	push   $0x62
  802067:	68 03 2f 80 00       	push   $0x802f03
  80206c:	e8 23 e1 ff ff       	call   800194 <_panic>

00802071 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	53                   	push   %ebx
  802075:	83 ec 04             	sub    $0x4,%esp
  802078:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80207b:	8b 45 08             	mov    0x8(%ebp),%eax
  80207e:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802083:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802089:	7f 2e                	jg     8020b9 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80208b:	83 ec 04             	sub    $0x4,%esp
  80208e:	53                   	push   %ebx
  80208f:	ff 75 0c             	push   0xc(%ebp)
  802092:	68 0c 70 80 00       	push   $0x80700c
  802097:	e8 43 e9 ff ff       	call   8009df <memmove>
	nsipcbuf.send.req_size = size;
  80209c:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8020a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8020a5:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8020aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8020af:	e8 e8 fd ff ff       	call   801e9c <nsipc>
}
  8020b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b7:	c9                   	leave  
  8020b8:	c3                   	ret    
	assert(size < 1600);
  8020b9:	68 0f 2f 80 00       	push   $0x802f0f
  8020be:	68 03 2e 80 00       	push   $0x802e03
  8020c3:	6a 6d                	push   $0x6d
  8020c5:	68 03 2f 80 00       	push   $0x802f03
  8020ca:	e8 c5 e0 ff ff       	call   800194 <_panic>

008020cf <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020cf:	55                   	push   %ebp
  8020d0:	89 e5                	mov    %esp,%ebp
  8020d2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8020dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e0:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8020e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8020ed:	b8 09 00 00 00       	mov    $0x9,%eax
  8020f2:	e8 a5 fd ff ff       	call   801e9c <nsipc>
}
  8020f7:	c9                   	leave  
  8020f8:	c3                   	ret    

008020f9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	56                   	push   %esi
  8020fd:	53                   	push   %ebx
  8020fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802101:	83 ec 0c             	sub    $0xc,%esp
  802104:	ff 75 08             	push   0x8(%ebp)
  802107:	e8 9b ed ff ff       	call   800ea7 <fd2data>
  80210c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80210e:	83 c4 08             	add    $0x8,%esp
  802111:	68 1b 2f 80 00       	push   $0x802f1b
  802116:	53                   	push   %ebx
  802117:	e8 2d e7 ff ff       	call   800849 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80211c:	8b 46 04             	mov    0x4(%esi),%eax
  80211f:	2b 06                	sub    (%esi),%eax
  802121:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802127:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80212e:	00 00 00 
	stat->st_dev = &devpipe;
  802131:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  802138:	30 80 00 
	return 0;
}
  80213b:	b8 00 00 00 00       	mov    $0x0,%eax
  802140:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5d                   	pop    %ebp
  802146:	c3                   	ret    

00802147 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	53                   	push   %ebx
  80214b:	83 ec 0c             	sub    $0xc,%esp
  80214e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802151:	53                   	push   %ebx
  802152:	6a 00                	push   $0x0
  802154:	e8 71 eb ff ff       	call   800cca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802159:	89 1c 24             	mov    %ebx,(%esp)
  80215c:	e8 46 ed ff ff       	call   800ea7 <fd2data>
  802161:	83 c4 08             	add    $0x8,%esp
  802164:	50                   	push   %eax
  802165:	6a 00                	push   $0x0
  802167:	e8 5e eb ff ff       	call   800cca <sys_page_unmap>
}
  80216c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80216f:	c9                   	leave  
  802170:	c3                   	ret    

00802171 <_pipeisclosed>:
{
  802171:	55                   	push   %ebp
  802172:	89 e5                	mov    %esp,%ebp
  802174:	57                   	push   %edi
  802175:	56                   	push   %esi
  802176:	53                   	push   %ebx
  802177:	83 ec 1c             	sub    $0x1c,%esp
  80217a:	89 c7                	mov    %eax,%edi
  80217c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80217e:	a1 00 40 80 00       	mov    0x804000,%eax
  802183:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802186:	83 ec 0c             	sub    $0xc,%esp
  802189:	57                   	push   %edi
  80218a:	e8 1c 05 00 00       	call   8026ab <pageref>
  80218f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802192:	89 34 24             	mov    %esi,(%esp)
  802195:	e8 11 05 00 00       	call   8026ab <pageref>
		nn = thisenv->env_runs;
  80219a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8021a0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021a3:	83 c4 10             	add    $0x10,%esp
  8021a6:	39 cb                	cmp    %ecx,%ebx
  8021a8:	74 1b                	je     8021c5 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8021aa:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021ad:	75 cf                	jne    80217e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021af:	8b 42 58             	mov    0x58(%edx),%eax
  8021b2:	6a 01                	push   $0x1
  8021b4:	50                   	push   %eax
  8021b5:	53                   	push   %ebx
  8021b6:	68 22 2f 80 00       	push   $0x802f22
  8021bb:	e8 af e0 ff ff       	call   80026f <cprintf>
  8021c0:	83 c4 10             	add    $0x10,%esp
  8021c3:	eb b9                	jmp    80217e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8021c5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021c8:	0f 94 c0             	sete   %al
  8021cb:	0f b6 c0             	movzbl %al,%eax
}
  8021ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d1:	5b                   	pop    %ebx
  8021d2:	5e                   	pop    %esi
  8021d3:	5f                   	pop    %edi
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <devpipe_write>:
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	57                   	push   %edi
  8021da:	56                   	push   %esi
  8021db:	53                   	push   %ebx
  8021dc:	83 ec 28             	sub    $0x28,%esp
  8021df:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8021e2:	56                   	push   %esi
  8021e3:	e8 bf ec ff ff       	call   800ea7 <fd2data>
  8021e8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021ea:	83 c4 10             	add    $0x10,%esp
  8021ed:	bf 00 00 00 00       	mov    $0x0,%edi
  8021f2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021f5:	75 09                	jne    802200 <devpipe_write+0x2a>
	return i;
  8021f7:	89 f8                	mov    %edi,%eax
  8021f9:	eb 23                	jmp    80221e <devpipe_write+0x48>
			sys_yield();
  8021fb:	e8 26 ea ff ff       	call   800c26 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802200:	8b 43 04             	mov    0x4(%ebx),%eax
  802203:	8b 0b                	mov    (%ebx),%ecx
  802205:	8d 51 20             	lea    0x20(%ecx),%edx
  802208:	39 d0                	cmp    %edx,%eax
  80220a:	72 1a                	jb     802226 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80220c:	89 da                	mov    %ebx,%edx
  80220e:	89 f0                	mov    %esi,%eax
  802210:	e8 5c ff ff ff       	call   802171 <_pipeisclosed>
  802215:	85 c0                	test   %eax,%eax
  802217:	74 e2                	je     8021fb <devpipe_write+0x25>
				return 0;
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80221e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5f                   	pop    %edi
  802224:	5d                   	pop    %ebp
  802225:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802229:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80222d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802230:	89 c2                	mov    %eax,%edx
  802232:	c1 fa 1f             	sar    $0x1f,%edx
  802235:	89 d1                	mov    %edx,%ecx
  802237:	c1 e9 1b             	shr    $0x1b,%ecx
  80223a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80223d:	83 e2 1f             	and    $0x1f,%edx
  802240:	29 ca                	sub    %ecx,%edx
  802242:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802246:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80224a:	83 c0 01             	add    $0x1,%eax
  80224d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802250:	83 c7 01             	add    $0x1,%edi
  802253:	eb 9d                	jmp    8021f2 <devpipe_write+0x1c>

00802255 <devpipe_read>:
{
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	57                   	push   %edi
  802259:	56                   	push   %esi
  80225a:	53                   	push   %ebx
  80225b:	83 ec 18             	sub    $0x18,%esp
  80225e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802261:	57                   	push   %edi
  802262:	e8 40 ec ff ff       	call   800ea7 <fd2data>
  802267:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802269:	83 c4 10             	add    $0x10,%esp
  80226c:	be 00 00 00 00       	mov    $0x0,%esi
  802271:	3b 75 10             	cmp    0x10(%ebp),%esi
  802274:	75 13                	jne    802289 <devpipe_read+0x34>
	return i;
  802276:	89 f0                	mov    %esi,%eax
  802278:	eb 02                	jmp    80227c <devpipe_read+0x27>
				return i;
  80227a:	89 f0                	mov    %esi,%eax
}
  80227c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
			sys_yield();
  802284:	e8 9d e9 ff ff       	call   800c26 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802289:	8b 03                	mov    (%ebx),%eax
  80228b:	3b 43 04             	cmp    0x4(%ebx),%eax
  80228e:	75 18                	jne    8022a8 <devpipe_read+0x53>
			if (i > 0)
  802290:	85 f6                	test   %esi,%esi
  802292:	75 e6                	jne    80227a <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802294:	89 da                	mov    %ebx,%edx
  802296:	89 f8                	mov    %edi,%eax
  802298:	e8 d4 fe ff ff       	call   802171 <_pipeisclosed>
  80229d:	85 c0                	test   %eax,%eax
  80229f:	74 e3                	je     802284 <devpipe_read+0x2f>
				return 0;
  8022a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a6:	eb d4                	jmp    80227c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022a8:	99                   	cltd   
  8022a9:	c1 ea 1b             	shr    $0x1b,%edx
  8022ac:	01 d0                	add    %edx,%eax
  8022ae:	83 e0 1f             	and    $0x1f,%eax
  8022b1:	29 d0                	sub    %edx,%eax
  8022b3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8022b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022bb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8022be:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8022c1:	83 c6 01             	add    $0x1,%esi
  8022c4:	eb ab                	jmp    802271 <devpipe_read+0x1c>

008022c6 <pipe>:
{
  8022c6:	55                   	push   %ebp
  8022c7:	89 e5                	mov    %esp,%ebp
  8022c9:	56                   	push   %esi
  8022ca:	53                   	push   %ebx
  8022cb:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8022ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d1:	50                   	push   %eax
  8022d2:	e8 e7 eb ff ff       	call   800ebe <fd_alloc>
  8022d7:	89 c3                	mov    %eax,%ebx
  8022d9:	83 c4 10             	add    $0x10,%esp
  8022dc:	85 c0                	test   %eax,%eax
  8022de:	0f 88 23 01 00 00    	js     802407 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e4:	83 ec 04             	sub    $0x4,%esp
  8022e7:	68 07 04 00 00       	push   $0x407
  8022ec:	ff 75 f4             	push   -0xc(%ebp)
  8022ef:	6a 00                	push   $0x0
  8022f1:	e8 4f e9 ff ff       	call   800c45 <sys_page_alloc>
  8022f6:	89 c3                	mov    %eax,%ebx
  8022f8:	83 c4 10             	add    $0x10,%esp
  8022fb:	85 c0                	test   %eax,%eax
  8022fd:	0f 88 04 01 00 00    	js     802407 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802303:	83 ec 0c             	sub    $0xc,%esp
  802306:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802309:	50                   	push   %eax
  80230a:	e8 af eb ff ff       	call   800ebe <fd_alloc>
  80230f:	89 c3                	mov    %eax,%ebx
  802311:	83 c4 10             	add    $0x10,%esp
  802314:	85 c0                	test   %eax,%eax
  802316:	0f 88 db 00 00 00    	js     8023f7 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80231c:	83 ec 04             	sub    $0x4,%esp
  80231f:	68 07 04 00 00       	push   $0x407
  802324:	ff 75 f0             	push   -0x10(%ebp)
  802327:	6a 00                	push   $0x0
  802329:	e8 17 e9 ff ff       	call   800c45 <sys_page_alloc>
  80232e:	89 c3                	mov    %eax,%ebx
  802330:	83 c4 10             	add    $0x10,%esp
  802333:	85 c0                	test   %eax,%eax
  802335:	0f 88 bc 00 00 00    	js     8023f7 <pipe+0x131>
	va = fd2data(fd0);
  80233b:	83 ec 0c             	sub    $0xc,%esp
  80233e:	ff 75 f4             	push   -0xc(%ebp)
  802341:	e8 61 eb ff ff       	call   800ea7 <fd2data>
  802346:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802348:	83 c4 0c             	add    $0xc,%esp
  80234b:	68 07 04 00 00       	push   $0x407
  802350:	50                   	push   %eax
  802351:	6a 00                	push   $0x0
  802353:	e8 ed e8 ff ff       	call   800c45 <sys_page_alloc>
  802358:	89 c3                	mov    %eax,%ebx
  80235a:	83 c4 10             	add    $0x10,%esp
  80235d:	85 c0                	test   %eax,%eax
  80235f:	0f 88 82 00 00 00    	js     8023e7 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802365:	83 ec 0c             	sub    $0xc,%esp
  802368:	ff 75 f0             	push   -0x10(%ebp)
  80236b:	e8 37 eb ff ff       	call   800ea7 <fd2data>
  802370:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802377:	50                   	push   %eax
  802378:	6a 00                	push   $0x0
  80237a:	56                   	push   %esi
  80237b:	6a 00                	push   $0x0
  80237d:	e8 06 e9 ff ff       	call   800c88 <sys_page_map>
  802382:	89 c3                	mov    %eax,%ebx
  802384:	83 c4 20             	add    $0x20,%esp
  802387:	85 c0                	test   %eax,%eax
  802389:	78 4e                	js     8023d9 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80238b:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802390:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802393:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802395:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802398:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80239f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8023a2:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8023a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023a7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8023ae:	83 ec 0c             	sub    $0xc,%esp
  8023b1:	ff 75 f4             	push   -0xc(%ebp)
  8023b4:	e8 de ea ff ff       	call   800e97 <fd2num>
  8023b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023bc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023be:	83 c4 04             	add    $0x4,%esp
  8023c1:	ff 75 f0             	push   -0x10(%ebp)
  8023c4:	e8 ce ea ff ff       	call   800e97 <fd2num>
  8023c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023cc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023cf:	83 c4 10             	add    $0x10,%esp
  8023d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023d7:	eb 2e                	jmp    802407 <pipe+0x141>
	sys_page_unmap(0, va);
  8023d9:	83 ec 08             	sub    $0x8,%esp
  8023dc:	56                   	push   %esi
  8023dd:	6a 00                	push   $0x0
  8023df:	e8 e6 e8 ff ff       	call   800cca <sys_page_unmap>
  8023e4:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8023e7:	83 ec 08             	sub    $0x8,%esp
  8023ea:	ff 75 f0             	push   -0x10(%ebp)
  8023ed:	6a 00                	push   $0x0
  8023ef:	e8 d6 e8 ff ff       	call   800cca <sys_page_unmap>
  8023f4:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8023f7:	83 ec 08             	sub    $0x8,%esp
  8023fa:	ff 75 f4             	push   -0xc(%ebp)
  8023fd:	6a 00                	push   $0x0
  8023ff:	e8 c6 e8 ff ff       	call   800cca <sys_page_unmap>
  802404:	83 c4 10             	add    $0x10,%esp
}
  802407:	89 d8                	mov    %ebx,%eax
  802409:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80240c:	5b                   	pop    %ebx
  80240d:	5e                   	pop    %esi
  80240e:	5d                   	pop    %ebp
  80240f:	c3                   	ret    

00802410 <pipeisclosed>:
{
  802410:	55                   	push   %ebp
  802411:	89 e5                	mov    %esp,%ebp
  802413:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802416:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802419:	50                   	push   %eax
  80241a:	ff 75 08             	push   0x8(%ebp)
  80241d:	e8 ec ea ff ff       	call   800f0e <fd_lookup>
  802422:	83 c4 10             	add    $0x10,%esp
  802425:	85 c0                	test   %eax,%eax
  802427:	78 18                	js     802441 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802429:	83 ec 0c             	sub    $0xc,%esp
  80242c:	ff 75 f4             	push   -0xc(%ebp)
  80242f:	e8 73 ea ff ff       	call   800ea7 <fd2data>
  802434:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802439:	e8 33 fd ff ff       	call   802171 <_pipeisclosed>
  80243e:	83 c4 10             	add    $0x10,%esp
}
  802441:	c9                   	leave  
  802442:	c3                   	ret    

00802443 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802443:	b8 00 00 00 00       	mov    $0x0,%eax
  802448:	c3                   	ret    

00802449 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802449:	55                   	push   %ebp
  80244a:	89 e5                	mov    %esp,%ebp
  80244c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80244f:	68 3a 2f 80 00       	push   $0x802f3a
  802454:	ff 75 0c             	push   0xc(%ebp)
  802457:	e8 ed e3 ff ff       	call   800849 <strcpy>
	return 0;
}
  80245c:	b8 00 00 00 00       	mov    $0x0,%eax
  802461:	c9                   	leave  
  802462:	c3                   	ret    

00802463 <devcons_write>:
{
  802463:	55                   	push   %ebp
  802464:	89 e5                	mov    %esp,%ebp
  802466:	57                   	push   %edi
  802467:	56                   	push   %esi
  802468:	53                   	push   %ebx
  802469:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80246f:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802474:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80247a:	eb 2e                	jmp    8024aa <devcons_write+0x47>
		m = n - tot;
  80247c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80247f:	29 f3                	sub    %esi,%ebx
  802481:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802486:	39 c3                	cmp    %eax,%ebx
  802488:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80248b:	83 ec 04             	sub    $0x4,%esp
  80248e:	53                   	push   %ebx
  80248f:	89 f0                	mov    %esi,%eax
  802491:	03 45 0c             	add    0xc(%ebp),%eax
  802494:	50                   	push   %eax
  802495:	57                   	push   %edi
  802496:	e8 44 e5 ff ff       	call   8009df <memmove>
		sys_cputs(buf, m);
  80249b:	83 c4 08             	add    $0x8,%esp
  80249e:	53                   	push   %ebx
  80249f:	57                   	push   %edi
  8024a0:	e8 e4 e6 ff ff       	call   800b89 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8024a5:	01 de                	add    %ebx,%esi
  8024a7:	83 c4 10             	add    $0x10,%esp
  8024aa:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024ad:	72 cd                	jb     80247c <devcons_write+0x19>
}
  8024af:	89 f0                	mov    %esi,%eax
  8024b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024b4:	5b                   	pop    %ebx
  8024b5:	5e                   	pop    %esi
  8024b6:	5f                   	pop    %edi
  8024b7:	5d                   	pop    %ebp
  8024b8:	c3                   	ret    

008024b9 <devcons_read>:
{
  8024b9:	55                   	push   %ebp
  8024ba:	89 e5                	mov    %esp,%ebp
  8024bc:	83 ec 08             	sub    $0x8,%esp
  8024bf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8024c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024c8:	75 07                	jne    8024d1 <devcons_read+0x18>
  8024ca:	eb 1f                	jmp    8024eb <devcons_read+0x32>
		sys_yield();
  8024cc:	e8 55 e7 ff ff       	call   800c26 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8024d1:	e8 d1 e6 ff ff       	call   800ba7 <sys_cgetc>
  8024d6:	85 c0                	test   %eax,%eax
  8024d8:	74 f2                	je     8024cc <devcons_read+0x13>
	if (c < 0)
  8024da:	78 0f                	js     8024eb <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8024dc:	83 f8 04             	cmp    $0x4,%eax
  8024df:	74 0c                	je     8024ed <devcons_read+0x34>
	*(char*)vbuf = c;
  8024e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024e4:	88 02                	mov    %al,(%edx)
	return 1;
  8024e6:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8024eb:	c9                   	leave  
  8024ec:	c3                   	ret    
		return 0;
  8024ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f2:	eb f7                	jmp    8024eb <devcons_read+0x32>

008024f4 <cputchar>:
{
  8024f4:	55                   	push   %ebp
  8024f5:	89 e5                	mov    %esp,%ebp
  8024f7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fd:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802500:	6a 01                	push   $0x1
  802502:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802505:	50                   	push   %eax
  802506:	e8 7e e6 ff ff       	call   800b89 <sys_cputs>
}
  80250b:	83 c4 10             	add    $0x10,%esp
  80250e:	c9                   	leave  
  80250f:	c3                   	ret    

00802510 <getchar>:
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802516:	6a 01                	push   $0x1
  802518:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80251b:	50                   	push   %eax
  80251c:	6a 00                	push   $0x0
  80251e:	e8 54 ec ff ff       	call   801177 <read>
	if (r < 0)
  802523:	83 c4 10             	add    $0x10,%esp
  802526:	85 c0                	test   %eax,%eax
  802528:	78 06                	js     802530 <getchar+0x20>
	if (r < 1)
  80252a:	74 06                	je     802532 <getchar+0x22>
	return c;
  80252c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802530:	c9                   	leave  
  802531:	c3                   	ret    
		return -E_EOF;
  802532:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802537:	eb f7                	jmp    802530 <getchar+0x20>

00802539 <iscons>:
{
  802539:	55                   	push   %ebp
  80253a:	89 e5                	mov    %esp,%ebp
  80253c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80253f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802542:	50                   	push   %eax
  802543:	ff 75 08             	push   0x8(%ebp)
  802546:	e8 c3 e9 ff ff       	call   800f0e <fd_lookup>
  80254b:	83 c4 10             	add    $0x10,%esp
  80254e:	85 c0                	test   %eax,%eax
  802550:	78 11                	js     802563 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802555:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80255b:	39 10                	cmp    %edx,(%eax)
  80255d:	0f 94 c0             	sete   %al
  802560:	0f b6 c0             	movzbl %al,%eax
}
  802563:	c9                   	leave  
  802564:	c3                   	ret    

00802565 <opencons>:
{
  802565:	55                   	push   %ebp
  802566:	89 e5                	mov    %esp,%ebp
  802568:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80256b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80256e:	50                   	push   %eax
  80256f:	e8 4a e9 ff ff       	call   800ebe <fd_alloc>
  802574:	83 c4 10             	add    $0x10,%esp
  802577:	85 c0                	test   %eax,%eax
  802579:	78 3a                	js     8025b5 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80257b:	83 ec 04             	sub    $0x4,%esp
  80257e:	68 07 04 00 00       	push   $0x407
  802583:	ff 75 f4             	push   -0xc(%ebp)
  802586:	6a 00                	push   $0x0
  802588:	e8 b8 e6 ff ff       	call   800c45 <sys_page_alloc>
  80258d:	83 c4 10             	add    $0x10,%esp
  802590:	85 c0                	test   %eax,%eax
  802592:	78 21                	js     8025b5 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802594:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802597:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80259d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80259f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025a9:	83 ec 0c             	sub    $0xc,%esp
  8025ac:	50                   	push   %eax
  8025ad:	e8 e5 e8 ff ff       	call   800e97 <fd2num>
  8025b2:	83 c4 10             	add    $0x10,%esp
}
  8025b5:	c9                   	leave  
  8025b6:	c3                   	ret    

008025b7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025b7:	55                   	push   %ebp
  8025b8:	89 e5                	mov    %esp,%ebp
  8025ba:	56                   	push   %esi
  8025bb:	53                   	push   %ebx
  8025bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8025bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8025c5:	85 c0                	test   %eax,%eax
  8025c7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8025cc:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8025cf:	83 ec 0c             	sub    $0xc,%esp
  8025d2:	50                   	push   %eax
  8025d3:	e8 1d e8 ff ff       	call   800df5 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8025d8:	83 c4 10             	add    $0x10,%esp
  8025db:	85 f6                	test   %esi,%esi
  8025dd:	74 14                	je     8025f3 <ipc_recv+0x3c>
  8025df:	ba 00 00 00 00       	mov    $0x0,%edx
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	78 09                	js     8025f1 <ipc_recv+0x3a>
  8025e8:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8025ee:	8b 52 74             	mov    0x74(%edx),%edx
  8025f1:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8025f3:	85 db                	test   %ebx,%ebx
  8025f5:	74 14                	je     80260b <ipc_recv+0x54>
  8025f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8025fc:	85 c0                	test   %eax,%eax
  8025fe:	78 09                	js     802609 <ipc_recv+0x52>
  802600:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802606:	8b 52 78             	mov    0x78(%edx),%edx
  802609:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80260b:	85 c0                	test   %eax,%eax
  80260d:	78 08                	js     802617 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  80260f:	a1 00 40 80 00       	mov    0x804000,%eax
  802614:	8b 40 70             	mov    0x70(%eax),%eax
}
  802617:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80261a:	5b                   	pop    %ebx
  80261b:	5e                   	pop    %esi
  80261c:	5d                   	pop    %ebp
  80261d:	c3                   	ret    

0080261e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80261e:	55                   	push   %ebp
  80261f:	89 e5                	mov    %esp,%ebp
  802621:	57                   	push   %edi
  802622:	56                   	push   %esi
  802623:	53                   	push   %ebx
  802624:	83 ec 0c             	sub    $0xc,%esp
  802627:	8b 7d 08             	mov    0x8(%ebp),%edi
  80262a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80262d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802630:	85 db                	test   %ebx,%ebx
  802632:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802637:	0f 44 d8             	cmove  %eax,%ebx
  80263a:	eb 05                	jmp    802641 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80263c:	e8 e5 e5 ff ff       	call   800c26 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802641:	ff 75 14             	push   0x14(%ebp)
  802644:	53                   	push   %ebx
  802645:	56                   	push   %esi
  802646:	57                   	push   %edi
  802647:	e8 86 e7 ff ff       	call   800dd2 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80264c:	83 c4 10             	add    $0x10,%esp
  80264f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802652:	74 e8                	je     80263c <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802654:	85 c0                	test   %eax,%eax
  802656:	78 08                	js     802660 <ipc_send+0x42>
	}while (r<0);

}
  802658:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80265b:	5b                   	pop    %ebx
  80265c:	5e                   	pop    %esi
  80265d:	5f                   	pop    %edi
  80265e:	5d                   	pop    %ebp
  80265f:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802660:	50                   	push   %eax
  802661:	68 46 2f 80 00       	push   $0x802f46
  802666:	6a 3d                	push   $0x3d
  802668:	68 5a 2f 80 00       	push   $0x802f5a
  80266d:	e8 22 db ff ff       	call   800194 <_panic>

00802672 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802672:	55                   	push   %ebp
  802673:	89 e5                	mov    %esp,%ebp
  802675:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802678:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80267d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802680:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802686:	8b 52 50             	mov    0x50(%edx),%edx
  802689:	39 ca                	cmp    %ecx,%edx
  80268b:	74 11                	je     80269e <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80268d:	83 c0 01             	add    $0x1,%eax
  802690:	3d 00 04 00 00       	cmp    $0x400,%eax
  802695:	75 e6                	jne    80267d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802697:	b8 00 00 00 00       	mov    $0x0,%eax
  80269c:	eb 0b                	jmp    8026a9 <ipc_find_env+0x37>
			return envs[i].env_id;
  80269e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026a6:	8b 40 48             	mov    0x48(%eax),%eax
}
  8026a9:	5d                   	pop    %ebp
  8026aa:	c3                   	ret    

008026ab <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026ab:	55                   	push   %ebp
  8026ac:	89 e5                	mov    %esp,%ebp
  8026ae:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026b1:	89 c2                	mov    %eax,%edx
  8026b3:	c1 ea 16             	shr    $0x16,%edx
  8026b6:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8026bd:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8026c2:	f6 c1 01             	test   $0x1,%cl
  8026c5:	74 1c                	je     8026e3 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8026c7:	c1 e8 0c             	shr    $0xc,%eax
  8026ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026d1:	a8 01                	test   $0x1,%al
  8026d3:	74 0e                	je     8026e3 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026d5:	c1 e8 0c             	shr    $0xc,%eax
  8026d8:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8026df:	ef 
  8026e0:	0f b7 d2             	movzwl %dx,%edx
}
  8026e3:	89 d0                	mov    %edx,%eax
  8026e5:	5d                   	pop    %ebp
  8026e6:	c3                   	ret    
  8026e7:	66 90                	xchg   %ax,%ax
  8026e9:	66 90                	xchg   %ax,%ax
  8026eb:	66 90                	xchg   %ax,%ax
  8026ed:	66 90                	xchg   %ax,%ax
  8026ef:	90                   	nop

008026f0 <__udivdi3>:
  8026f0:	f3 0f 1e fb          	endbr32 
  8026f4:	55                   	push   %ebp
  8026f5:	57                   	push   %edi
  8026f6:	56                   	push   %esi
  8026f7:	53                   	push   %ebx
  8026f8:	83 ec 1c             	sub    $0x1c,%esp
  8026fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8026ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802703:	8b 74 24 34          	mov    0x34(%esp),%esi
  802707:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80270b:	85 c0                	test   %eax,%eax
  80270d:	75 19                	jne    802728 <__udivdi3+0x38>
  80270f:	39 f3                	cmp    %esi,%ebx
  802711:	76 4d                	jbe    802760 <__udivdi3+0x70>
  802713:	31 ff                	xor    %edi,%edi
  802715:	89 e8                	mov    %ebp,%eax
  802717:	89 f2                	mov    %esi,%edx
  802719:	f7 f3                	div    %ebx
  80271b:	89 fa                	mov    %edi,%edx
  80271d:	83 c4 1c             	add    $0x1c,%esp
  802720:	5b                   	pop    %ebx
  802721:	5e                   	pop    %esi
  802722:	5f                   	pop    %edi
  802723:	5d                   	pop    %ebp
  802724:	c3                   	ret    
  802725:	8d 76 00             	lea    0x0(%esi),%esi
  802728:	39 f0                	cmp    %esi,%eax
  80272a:	76 14                	jbe    802740 <__udivdi3+0x50>
  80272c:	31 ff                	xor    %edi,%edi
  80272e:	31 c0                	xor    %eax,%eax
  802730:	89 fa                	mov    %edi,%edx
  802732:	83 c4 1c             	add    $0x1c,%esp
  802735:	5b                   	pop    %ebx
  802736:	5e                   	pop    %esi
  802737:	5f                   	pop    %edi
  802738:	5d                   	pop    %ebp
  802739:	c3                   	ret    
  80273a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802740:	0f bd f8             	bsr    %eax,%edi
  802743:	83 f7 1f             	xor    $0x1f,%edi
  802746:	75 48                	jne    802790 <__udivdi3+0xa0>
  802748:	39 f0                	cmp    %esi,%eax
  80274a:	72 06                	jb     802752 <__udivdi3+0x62>
  80274c:	31 c0                	xor    %eax,%eax
  80274e:	39 eb                	cmp    %ebp,%ebx
  802750:	77 de                	ja     802730 <__udivdi3+0x40>
  802752:	b8 01 00 00 00       	mov    $0x1,%eax
  802757:	eb d7                	jmp    802730 <__udivdi3+0x40>
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	89 d9                	mov    %ebx,%ecx
  802762:	85 db                	test   %ebx,%ebx
  802764:	75 0b                	jne    802771 <__udivdi3+0x81>
  802766:	b8 01 00 00 00       	mov    $0x1,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	f7 f3                	div    %ebx
  80276f:	89 c1                	mov    %eax,%ecx
  802771:	31 d2                	xor    %edx,%edx
  802773:	89 f0                	mov    %esi,%eax
  802775:	f7 f1                	div    %ecx
  802777:	89 c6                	mov    %eax,%esi
  802779:	89 e8                	mov    %ebp,%eax
  80277b:	89 f7                	mov    %esi,%edi
  80277d:	f7 f1                	div    %ecx
  80277f:	89 fa                	mov    %edi,%edx
  802781:	83 c4 1c             	add    $0x1c,%esp
  802784:	5b                   	pop    %ebx
  802785:	5e                   	pop    %esi
  802786:	5f                   	pop    %edi
  802787:	5d                   	pop    %ebp
  802788:	c3                   	ret    
  802789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802790:	89 f9                	mov    %edi,%ecx
  802792:	ba 20 00 00 00       	mov    $0x20,%edx
  802797:	29 fa                	sub    %edi,%edx
  802799:	d3 e0                	shl    %cl,%eax
  80279b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80279f:	89 d1                	mov    %edx,%ecx
  8027a1:	89 d8                	mov    %ebx,%eax
  8027a3:	d3 e8                	shr    %cl,%eax
  8027a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8027a9:	09 c1                	or     %eax,%ecx
  8027ab:	89 f0                	mov    %esi,%eax
  8027ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	d3 e3                	shl    %cl,%ebx
  8027b5:	89 d1                	mov    %edx,%ecx
  8027b7:	d3 e8                	shr    %cl,%eax
  8027b9:	89 f9                	mov    %edi,%ecx
  8027bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8027bf:	89 eb                	mov    %ebp,%ebx
  8027c1:	d3 e6                	shl    %cl,%esi
  8027c3:	89 d1                	mov    %edx,%ecx
  8027c5:	d3 eb                	shr    %cl,%ebx
  8027c7:	09 f3                	or     %esi,%ebx
  8027c9:	89 c6                	mov    %eax,%esi
  8027cb:	89 f2                	mov    %esi,%edx
  8027cd:	89 d8                	mov    %ebx,%eax
  8027cf:	f7 74 24 08          	divl   0x8(%esp)
  8027d3:	89 d6                	mov    %edx,%esi
  8027d5:	89 c3                	mov    %eax,%ebx
  8027d7:	f7 64 24 0c          	mull   0xc(%esp)
  8027db:	39 d6                	cmp    %edx,%esi
  8027dd:	72 19                	jb     8027f8 <__udivdi3+0x108>
  8027df:	89 f9                	mov    %edi,%ecx
  8027e1:	d3 e5                	shl    %cl,%ebp
  8027e3:	39 c5                	cmp    %eax,%ebp
  8027e5:	73 04                	jae    8027eb <__udivdi3+0xfb>
  8027e7:	39 d6                	cmp    %edx,%esi
  8027e9:	74 0d                	je     8027f8 <__udivdi3+0x108>
  8027eb:	89 d8                	mov    %ebx,%eax
  8027ed:	31 ff                	xor    %edi,%edi
  8027ef:	e9 3c ff ff ff       	jmp    802730 <__udivdi3+0x40>
  8027f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027f8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8027fb:	31 ff                	xor    %edi,%edi
  8027fd:	e9 2e ff ff ff       	jmp    802730 <__udivdi3+0x40>
  802802:	66 90                	xchg   %ax,%ax
  802804:	66 90                	xchg   %ax,%ax
  802806:	66 90                	xchg   %ax,%ax
  802808:	66 90                	xchg   %ax,%ax
  80280a:	66 90                	xchg   %ax,%ax
  80280c:	66 90                	xchg   %ax,%ax
  80280e:	66 90                	xchg   %ax,%ax

00802810 <__umoddi3>:
  802810:	f3 0f 1e fb          	endbr32 
  802814:	55                   	push   %ebp
  802815:	57                   	push   %edi
  802816:	56                   	push   %esi
  802817:	53                   	push   %ebx
  802818:	83 ec 1c             	sub    $0x1c,%esp
  80281b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80281f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802823:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802827:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80282b:	89 f0                	mov    %esi,%eax
  80282d:	89 da                	mov    %ebx,%edx
  80282f:	85 ff                	test   %edi,%edi
  802831:	75 15                	jne    802848 <__umoddi3+0x38>
  802833:	39 dd                	cmp    %ebx,%ebp
  802835:	76 39                	jbe    802870 <__umoddi3+0x60>
  802837:	f7 f5                	div    %ebp
  802839:	89 d0                	mov    %edx,%eax
  80283b:	31 d2                	xor    %edx,%edx
  80283d:	83 c4 1c             	add    $0x1c,%esp
  802840:	5b                   	pop    %ebx
  802841:	5e                   	pop    %esi
  802842:	5f                   	pop    %edi
  802843:	5d                   	pop    %ebp
  802844:	c3                   	ret    
  802845:	8d 76 00             	lea    0x0(%esi),%esi
  802848:	39 df                	cmp    %ebx,%edi
  80284a:	77 f1                	ja     80283d <__umoddi3+0x2d>
  80284c:	0f bd cf             	bsr    %edi,%ecx
  80284f:	83 f1 1f             	xor    $0x1f,%ecx
  802852:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802856:	75 40                	jne    802898 <__umoddi3+0x88>
  802858:	39 df                	cmp    %ebx,%edi
  80285a:	72 04                	jb     802860 <__umoddi3+0x50>
  80285c:	39 f5                	cmp    %esi,%ebp
  80285e:	77 dd                	ja     80283d <__umoddi3+0x2d>
  802860:	89 da                	mov    %ebx,%edx
  802862:	89 f0                	mov    %esi,%eax
  802864:	29 e8                	sub    %ebp,%eax
  802866:	19 fa                	sbb    %edi,%edx
  802868:	eb d3                	jmp    80283d <__umoddi3+0x2d>
  80286a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802870:	89 e9                	mov    %ebp,%ecx
  802872:	85 ed                	test   %ebp,%ebp
  802874:	75 0b                	jne    802881 <__umoddi3+0x71>
  802876:	b8 01 00 00 00       	mov    $0x1,%eax
  80287b:	31 d2                	xor    %edx,%edx
  80287d:	f7 f5                	div    %ebp
  80287f:	89 c1                	mov    %eax,%ecx
  802881:	89 d8                	mov    %ebx,%eax
  802883:	31 d2                	xor    %edx,%edx
  802885:	f7 f1                	div    %ecx
  802887:	89 f0                	mov    %esi,%eax
  802889:	f7 f1                	div    %ecx
  80288b:	89 d0                	mov    %edx,%eax
  80288d:	31 d2                	xor    %edx,%edx
  80288f:	eb ac                	jmp    80283d <__umoddi3+0x2d>
  802891:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802898:	8b 44 24 04          	mov    0x4(%esp),%eax
  80289c:	ba 20 00 00 00       	mov    $0x20,%edx
  8028a1:	29 c2                	sub    %eax,%edx
  8028a3:	89 c1                	mov    %eax,%ecx
  8028a5:	89 e8                	mov    %ebp,%eax
  8028a7:	d3 e7                	shl    %cl,%edi
  8028a9:	89 d1                	mov    %edx,%ecx
  8028ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8028af:	d3 e8                	shr    %cl,%eax
  8028b1:	89 c1                	mov    %eax,%ecx
  8028b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8028b7:	09 f9                	or     %edi,%ecx
  8028b9:	89 df                	mov    %ebx,%edi
  8028bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028bf:	89 c1                	mov    %eax,%ecx
  8028c1:	d3 e5                	shl    %cl,%ebp
  8028c3:	89 d1                	mov    %edx,%ecx
  8028c5:	d3 ef                	shr    %cl,%edi
  8028c7:	89 c1                	mov    %eax,%ecx
  8028c9:	89 f0                	mov    %esi,%eax
  8028cb:	d3 e3                	shl    %cl,%ebx
  8028cd:	89 d1                	mov    %edx,%ecx
  8028cf:	89 fa                	mov    %edi,%edx
  8028d1:	d3 e8                	shr    %cl,%eax
  8028d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028d8:	09 d8                	or     %ebx,%eax
  8028da:	f7 74 24 08          	divl   0x8(%esp)
  8028de:	89 d3                	mov    %edx,%ebx
  8028e0:	d3 e6                	shl    %cl,%esi
  8028e2:	f7 e5                	mul    %ebp
  8028e4:	89 c7                	mov    %eax,%edi
  8028e6:	89 d1                	mov    %edx,%ecx
  8028e8:	39 d3                	cmp    %edx,%ebx
  8028ea:	72 06                	jb     8028f2 <__umoddi3+0xe2>
  8028ec:	75 0e                	jne    8028fc <__umoddi3+0xec>
  8028ee:	39 c6                	cmp    %eax,%esi
  8028f0:	73 0a                	jae    8028fc <__umoddi3+0xec>
  8028f2:	29 e8                	sub    %ebp,%eax
  8028f4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8028f8:	89 d1                	mov    %edx,%ecx
  8028fa:	89 c7                	mov    %eax,%edi
  8028fc:	89 f5                	mov    %esi,%ebp
  8028fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802902:	29 fd                	sub    %edi,%ebp
  802904:	19 cb                	sbb    %ecx,%ebx
  802906:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80290b:	89 d8                	mov    %ebx,%eax
  80290d:	d3 e0                	shl    %cl,%eax
  80290f:	89 f1                	mov    %esi,%ecx
  802911:	d3 ed                	shr    %cl,%ebp
  802913:	d3 eb                	shr    %cl,%ebx
  802915:	09 e8                	or     %ebp,%eax
  802917:	89 da                	mov    %ebx,%edx
  802919:	83 c4 1c             	add    $0x1c,%esp
  80291c:	5b                   	pop    %ebx
  80291d:	5e                   	pop    %esi
  80291e:	5f                   	pop    %edi
  80291f:	5d                   	pop    %ebp
  802920:	c3                   	ret    
