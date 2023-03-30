
obj/user/spawnhello.debug：     文件格式 elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 00 40 80 00       	mov    0x804000,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 80 28 80 00       	push   $0x802880
  800047:	e8 6a 01 00 00       	call   8001b6 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 9e 28 80 00       	push   $0x80289e
  800056:	68 9e 28 80 00       	push   $0x80289e
  80005b:	e8 d3 1a 00 00       	call   801b33 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	78 02                	js     800069 <umain+0x36>
		panic("spawn(hello) failed: %e", r);
}
  800067:	c9                   	leave  
  800068:	c3                   	ret    
		panic("spawn(hello) failed: %e", r);
  800069:	50                   	push   %eax
  80006a:	68 a4 28 80 00       	push   $0x8028a4
  80006f:	6a 09                	push   $0x9
  800071:	68 bc 28 80 00       	push   $0x8028bc
  800076:	e8 60 00 00 00       	call   8000db <_panic>

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 c3 0a 00 00       	call   800b4e <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 e3 0e 00 00       	call   800faf <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 37 0a 00 00       	call   800b0d <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 60 0a 00 00       	call   800b4e <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	push   0xc(%ebp)
  8000f4:	ff 75 08             	push   0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 d8 28 80 00       	push   $0x8028d8
  8000fe:	e8 b3 00 00 00       	call   8001b6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	push   0x10(%ebp)
  80010a:	e8 56 00 00 00       	call   800165 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 f3 2d 80 00 	movl   $0x802df3,(%esp)
  800116:	e8 9b 00 00 00       	call   8001b6 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	74 09                	je     800149 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800140:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800144:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800147:	c9                   	leave  
  800148:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800149:	83 ec 08             	sub    $0x8,%esp
  80014c:	68 ff 00 00 00       	push   $0xff
  800151:	8d 43 08             	lea    0x8(%ebx),%eax
  800154:	50                   	push   %eax
  800155:	e8 76 09 00 00       	call   800ad0 <sys_cputs>
		b->idx = 0;
  80015a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	eb db                	jmp    800140 <putch+0x1f>

00800165 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800175:	00 00 00 
	b.cnt = 0;
  800178:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800182:	ff 75 0c             	push   0xc(%ebp)
  800185:	ff 75 08             	push   0x8(%ebp)
  800188:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018e:	50                   	push   %eax
  80018f:	68 21 01 80 00       	push   $0x800121
  800194:	e8 14 01 00 00       	call   8002ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800199:	83 c4 08             	add    $0x8,%esp
  80019c:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 22 09 00 00       	call   800ad0 <sys_cputs>

	return b.cnt;
}
  8001ae:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bf:	50                   	push   %eax
  8001c0:	ff 75 08             	push   0x8(%ebp)
  8001c3:	e8 9d ff ff ff       	call   800165 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	57                   	push   %edi
  8001ce:	56                   	push   %esi
  8001cf:	53                   	push   %ebx
  8001d0:	83 ec 1c             	sub    $0x1c,%esp
  8001d3:	89 c7                	mov    %eax,%edi
  8001d5:	89 d6                	mov    %edx,%esi
  8001d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dd:	89 d1                	mov    %edx,%ecx
  8001df:	89 c2                	mov    %eax,%edx
  8001e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f7:	39 c2                	cmp    %eax,%edx
  8001f9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001fc:	72 3e                	jb     80023c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	ff 75 18             	push   0x18(%ebp)
  800204:	83 eb 01             	sub    $0x1,%ebx
  800207:	53                   	push   %ebx
  800208:	50                   	push   %eax
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	ff 75 e4             	push   -0x1c(%ebp)
  80020f:	ff 75 e0             	push   -0x20(%ebp)
  800212:	ff 75 dc             	push   -0x24(%ebp)
  800215:	ff 75 d8             	push   -0x28(%ebp)
  800218:	e8 13 24 00 00       	call   802630 <__udivdi3>
  80021d:	83 c4 18             	add    $0x18,%esp
  800220:	52                   	push   %edx
  800221:	50                   	push   %eax
  800222:	89 f2                	mov    %esi,%edx
  800224:	89 f8                	mov    %edi,%eax
  800226:	e8 9f ff ff ff       	call   8001ca <printnum>
  80022b:	83 c4 20             	add    $0x20,%esp
  80022e:	eb 13                	jmp    800243 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800230:	83 ec 08             	sub    $0x8,%esp
  800233:	56                   	push   %esi
  800234:	ff 75 18             	push   0x18(%ebp)
  800237:	ff d7                	call   *%edi
  800239:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023c:	83 eb 01             	sub    $0x1,%ebx
  80023f:	85 db                	test   %ebx,%ebx
  800241:	7f ed                	jg     800230 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800243:	83 ec 08             	sub    $0x8,%esp
  800246:	56                   	push   %esi
  800247:	83 ec 04             	sub    $0x4,%esp
  80024a:	ff 75 e4             	push   -0x1c(%ebp)
  80024d:	ff 75 e0             	push   -0x20(%ebp)
  800250:	ff 75 dc             	push   -0x24(%ebp)
  800253:	ff 75 d8             	push   -0x28(%ebp)
  800256:	e8 f5 24 00 00       	call   802750 <__umoddi3>
  80025b:	83 c4 14             	add    $0x14,%esp
  80025e:	0f be 80 fb 28 80 00 	movsbl 0x8028fb(%eax),%eax
  800265:	50                   	push   %eax
  800266:	ff d7                	call   *%edi
}
  800268:	83 c4 10             	add    $0x10,%esp
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800279:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	3b 50 04             	cmp    0x4(%eax),%edx
  800282:	73 0a                	jae    80028e <sprintputch+0x1b>
		*b->buf++ = ch;
  800284:	8d 4a 01             	lea    0x1(%edx),%ecx
  800287:	89 08                	mov    %ecx,(%eax)
  800289:	8b 45 08             	mov    0x8(%ebp),%eax
  80028c:	88 02                	mov    %al,(%edx)
}
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    

00800290 <printfmt>:
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800296:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800299:	50                   	push   %eax
  80029a:	ff 75 10             	push   0x10(%ebp)
  80029d:	ff 75 0c             	push   0xc(%ebp)
  8002a0:	ff 75 08             	push   0x8(%ebp)
  8002a3:	e8 05 00 00 00       	call   8002ad <vprintfmt>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <vprintfmt>:
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
  8002b3:	83 ec 3c             	sub    $0x3c,%esp
  8002b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bf:	eb 0a                	jmp    8002cb <vprintfmt+0x1e>
			putch(ch, putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	ff d6                	call   *%esi
  8002c8:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cb:	83 c7 01             	add    $0x1,%edi
  8002ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d2:	83 f8 25             	cmp    $0x25,%eax
  8002d5:	74 0c                	je     8002e3 <vprintfmt+0x36>
			if (ch == '\0')
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	75 e6                	jne    8002c1 <vprintfmt+0x14>
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    
		padc = ' ';
  8002e3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002e7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ee:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002fc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800301:	8d 47 01             	lea    0x1(%edi),%eax
  800304:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800307:	0f b6 17             	movzbl (%edi),%edx
  80030a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80030d:	3c 55                	cmp    $0x55,%al
  80030f:	0f 87 bb 03 00 00    	ja     8006d0 <vprintfmt+0x423>
  800315:	0f b6 c0             	movzbl %al,%eax
  800318:	ff 24 85 40 2a 80 00 	jmp    *0x802a40(,%eax,4)
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800322:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800326:	eb d9                	jmp    800301 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80032f:	eb d0                	jmp    800301 <vprintfmt+0x54>
  800331:	0f b6 d2             	movzbl %dl,%edx
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800337:	b8 00 00 00 00       	mov    $0x0,%eax
  80033c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80033f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800342:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800346:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800349:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034c:	83 f9 09             	cmp    $0x9,%ecx
  80034f:	77 55                	ja     8003a6 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800351:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800354:	eb e9                	jmp    80033f <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8b 00                	mov    (%eax),%eax
  80035b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 40 04             	lea    0x4(%eax),%eax
  800364:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80036a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036e:	79 91                	jns    800301 <vprintfmt+0x54>
				width = precision, precision = -1;
  800370:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800373:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800376:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80037d:	eb 82                	jmp    800301 <vprintfmt+0x54>
  80037f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800382:	85 d2                	test   %edx,%edx
  800384:	b8 00 00 00 00       	mov    $0x0,%eax
  800389:	0f 49 c2             	cmovns %edx,%eax
  80038c:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800392:	e9 6a ff ff ff       	jmp    800301 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80039a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a1:	e9 5b ff ff ff       	jmp    800301 <vprintfmt+0x54>
  8003a6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ac:	eb bc                	jmp    80036a <vprintfmt+0xbd>
			lflag++;
  8003ae:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b4:	e9 48 ff ff ff       	jmp    800301 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 78 04             	lea    0x4(%eax),%edi
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	53                   	push   %ebx
  8003c3:	ff 30                	push   (%eax)
  8003c5:	ff d6                	call   *%esi
			break;
  8003c7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003ca:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003cd:	e9 9d 02 00 00       	jmp    80066f <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 78 04             	lea    0x4(%eax),%edi
  8003d8:	8b 10                	mov    (%eax),%edx
  8003da:	89 d0                	mov    %edx,%eax
  8003dc:	f7 d8                	neg    %eax
  8003de:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e1:	83 f8 0f             	cmp    $0xf,%eax
  8003e4:	7f 23                	jg     800409 <vprintfmt+0x15c>
  8003e6:	8b 14 85 a0 2b 80 00 	mov    0x802ba0(,%eax,4),%edx
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	74 18                	je     800409 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003f1:	52                   	push   %edx
  8003f2:	68 d5 2c 80 00       	push   $0x802cd5
  8003f7:	53                   	push   %ebx
  8003f8:	56                   	push   %esi
  8003f9:	e8 92 fe ff ff       	call   800290 <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800401:	89 7d 14             	mov    %edi,0x14(%ebp)
  800404:	e9 66 02 00 00       	jmp    80066f <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800409:	50                   	push   %eax
  80040a:	68 13 29 80 00       	push   $0x802913
  80040f:	53                   	push   %ebx
  800410:	56                   	push   %esi
  800411:	e8 7a fe ff ff       	call   800290 <printfmt>
  800416:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800419:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80041c:	e9 4e 02 00 00       	jmp    80066f <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	83 c0 04             	add    $0x4,%eax
  800427:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80042f:	85 d2                	test   %edx,%edx
  800431:	b8 0c 29 80 00       	mov    $0x80290c,%eax
  800436:	0f 45 c2             	cmovne %edx,%eax
  800439:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	7e 06                	jle    800448 <vprintfmt+0x19b>
  800442:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800446:	75 0d                	jne    800455 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80044b:	89 c7                	mov    %eax,%edi
  80044d:	03 45 e0             	add    -0x20(%ebp),%eax
  800450:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800453:	eb 55                	jmp    8004aa <vprintfmt+0x1fd>
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 d8             	push   -0x28(%ebp)
  80045b:	ff 75 cc             	push   -0x34(%ebp)
  80045e:	e8 0a 03 00 00       	call   80076d <strnlen>
  800463:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800466:	29 c1                	sub    %eax,%ecx
  800468:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800470:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800474:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	eb 0f                	jmp    800488 <vprintfmt+0x1db>
					putch(padc, putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	53                   	push   %ebx
  80047d:	ff 75 e0             	push   -0x20(%ebp)
  800480:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	83 ef 01             	sub    $0x1,%edi
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	85 ff                	test   %edi,%edi
  80048a:	7f ed                	jg     800479 <vprintfmt+0x1cc>
  80048c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80048f:	85 d2                	test   %edx,%edx
  800491:	b8 00 00 00 00       	mov    $0x0,%eax
  800496:	0f 49 c2             	cmovns %edx,%eax
  800499:	29 c2                	sub    %eax,%edx
  80049b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80049e:	eb a8                	jmp    800448 <vprintfmt+0x19b>
					putch(ch, putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	53                   	push   %ebx
  8004a4:	52                   	push   %edx
  8004a5:	ff d6                	call   *%esi
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ad:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004af:	83 c7 01             	add    $0x1,%edi
  8004b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b6:	0f be d0             	movsbl %al,%edx
  8004b9:	85 d2                	test   %edx,%edx
  8004bb:	74 4b                	je     800508 <vprintfmt+0x25b>
  8004bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c1:	78 06                	js     8004c9 <vprintfmt+0x21c>
  8004c3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004c7:	78 1e                	js     8004e7 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004cd:	74 d1                	je     8004a0 <vprintfmt+0x1f3>
  8004cf:	0f be c0             	movsbl %al,%eax
  8004d2:	83 e8 20             	sub    $0x20,%eax
  8004d5:	83 f8 5e             	cmp    $0x5e,%eax
  8004d8:	76 c6                	jbe    8004a0 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	53                   	push   %ebx
  8004de:	6a 3f                	push   $0x3f
  8004e0:	ff d6                	call   *%esi
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	eb c3                	jmp    8004aa <vprintfmt+0x1fd>
  8004e7:	89 cf                	mov    %ecx,%edi
  8004e9:	eb 0e                	jmp    8004f9 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	6a 20                	push   $0x20
  8004f1:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004f3:	83 ef 01             	sub    $0x1,%edi
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	85 ff                	test   %edi,%edi
  8004fb:	7f ee                	jg     8004eb <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004fd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800500:	89 45 14             	mov    %eax,0x14(%ebp)
  800503:	e9 67 01 00 00       	jmp    80066f <vprintfmt+0x3c2>
  800508:	89 cf                	mov    %ecx,%edi
  80050a:	eb ed                	jmp    8004f9 <vprintfmt+0x24c>
	if (lflag >= 2)
  80050c:	83 f9 01             	cmp    $0x1,%ecx
  80050f:	7f 1b                	jg     80052c <vprintfmt+0x27f>
	else if (lflag)
  800511:	85 c9                	test   %ecx,%ecx
  800513:	74 63                	je     800578 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8b 00                	mov    (%eax),%eax
  80051a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051d:	99                   	cltd   
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 40 04             	lea    0x4(%eax),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
  80052a:	eb 17                	jmp    800543 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8b 50 04             	mov    0x4(%eax),%edx
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800537:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 40 08             	lea    0x8(%eax),%eax
  800540:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800543:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800546:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800549:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80054e:	85 c9                	test   %ecx,%ecx
  800550:	0f 89 ff 00 00 00    	jns    800655 <vprintfmt+0x3a8>
				putch('-', putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	53                   	push   %ebx
  80055a:	6a 2d                	push   $0x2d
  80055c:	ff d6                	call   *%esi
				num = -(long long) num;
  80055e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800561:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800564:	f7 da                	neg    %edx
  800566:	83 d1 00             	adc    $0x0,%ecx
  800569:	f7 d9                	neg    %ecx
  80056b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80056e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800573:	e9 dd 00 00 00       	jmp    800655 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	99                   	cltd   
  800581:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
  80058d:	eb b4                	jmp    800543 <vprintfmt+0x296>
	if (lflag >= 2)
  80058f:	83 f9 01             	cmp    $0x1,%ecx
  800592:	7f 1e                	jg     8005b2 <vprintfmt+0x305>
	else if (lflag)
  800594:	85 c9                	test   %ecx,%ecx
  800596:	74 32                	je     8005ca <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 10                	mov    (%eax),%edx
  80059d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a2:	8d 40 04             	lea    0x4(%eax),%eax
  8005a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005ad:	e9 a3 00 00 00       	jmp    800655 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ba:	8d 40 08             	lea    0x8(%eax),%eax
  8005bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005c5:	e9 8b 00 00 00       	jmp    800655 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 10                	mov    (%eax),%edx
  8005cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d4:	8d 40 04             	lea    0x4(%eax),%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005da:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005df:	eb 74                	jmp    800655 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005e1:	83 f9 01             	cmp    $0x1,%ecx
  8005e4:	7f 1b                	jg     800601 <vprintfmt+0x354>
	else if (lflag)
  8005e6:	85 c9                	test   %ecx,%ecx
  8005e8:	74 2c                	je     800616 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8b 10                	mov    (%eax),%edx
  8005ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f4:	8d 40 04             	lea    0x4(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005fa:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005ff:	eb 54                	jmp    800655 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8b 10                	mov    (%eax),%edx
  800606:	8b 48 04             	mov    0x4(%eax),%ecx
  800609:	8d 40 08             	lea    0x8(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80060f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800614:	eb 3f                	jmp    800655 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800620:	8d 40 04             	lea    0x4(%eax),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800626:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80062b:	eb 28                	jmp    800655 <vprintfmt+0x3a8>
			putch('0', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 30                	push   $0x30
  800633:	ff d6                	call   *%esi
			putch('x', putdat);
  800635:	83 c4 08             	add    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	6a 78                	push   $0x78
  80063b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 10                	mov    (%eax),%edx
  800642:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800647:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80064a:	8d 40 04             	lea    0x4(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800650:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800655:	83 ec 0c             	sub    $0xc,%esp
  800658:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80065c:	50                   	push   %eax
  80065d:	ff 75 e0             	push   -0x20(%ebp)
  800660:	57                   	push   %edi
  800661:	51                   	push   %ecx
  800662:	52                   	push   %edx
  800663:	89 da                	mov    %ebx,%edx
  800665:	89 f0                	mov    %esi,%eax
  800667:	e8 5e fb ff ff       	call   8001ca <printnum>
			break;
  80066c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80066f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800672:	e9 54 fc ff ff       	jmp    8002cb <vprintfmt+0x1e>
	if (lflag >= 2)
  800677:	83 f9 01             	cmp    $0x1,%ecx
  80067a:	7f 1b                	jg     800697 <vprintfmt+0x3ea>
	else if (lflag)
  80067c:	85 c9                	test   %ecx,%ecx
  80067e:	74 2c                	je     8006ac <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8b 10                	mov    (%eax),%edx
  800685:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068a:	8d 40 04             	lea    0x4(%eax),%eax
  80068d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800690:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800695:	eb be                	jmp    800655 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8b 48 04             	mov    0x4(%eax),%ecx
  80069f:	8d 40 08             	lea    0x8(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006aa:	eb a9                	jmp    800655 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bc:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006c1:	eb 92                	jmp    800655 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 25                	push   $0x25
  8006c9:	ff d6                	call   *%esi
			break;
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	eb 9f                	jmp    80066f <vprintfmt+0x3c2>
			putch('%', putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	6a 25                	push   $0x25
  8006d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	89 f8                	mov    %edi,%eax
  8006dd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e1:	74 05                	je     8006e8 <vprintfmt+0x43b>
  8006e3:	83 e8 01             	sub    $0x1,%eax
  8006e6:	eb f5                	jmp    8006dd <vprintfmt+0x430>
  8006e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006eb:	eb 82                	jmp    80066f <vprintfmt+0x3c2>

008006ed <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	83 ec 18             	sub    $0x18,%esp
  8006f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800700:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070a:	85 c0                	test   %eax,%eax
  80070c:	74 26                	je     800734 <vsnprintf+0x47>
  80070e:	85 d2                	test   %edx,%edx
  800710:	7e 22                	jle    800734 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800712:	ff 75 14             	push   0x14(%ebp)
  800715:	ff 75 10             	push   0x10(%ebp)
  800718:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071b:	50                   	push   %eax
  80071c:	68 73 02 80 00       	push   $0x800273
  800721:	e8 87 fb ff ff       	call   8002ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800726:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800729:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072f:	83 c4 10             	add    $0x10,%esp
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    
		return -E_INVAL;
  800734:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800739:	eb f7                	jmp    800732 <vsnprintf+0x45>

0080073b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800741:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800744:	50                   	push   %eax
  800745:	ff 75 10             	push   0x10(%ebp)
  800748:	ff 75 0c             	push   0xc(%ebp)
  80074b:	ff 75 08             	push   0x8(%ebp)
  80074e:	e8 9a ff ff ff       	call   8006ed <vsnprintf>
	va_end(ap);

	return rc;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075b:	b8 00 00 00 00       	mov    $0x0,%eax
  800760:	eb 03                	jmp    800765 <strlen+0x10>
		n++;
  800762:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800765:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800769:	75 f7                	jne    800762 <strlen+0xd>
	return n;
}
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	eb 03                	jmp    800780 <strnlen+0x13>
		n++;
  80077d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800780:	39 d0                	cmp    %edx,%eax
  800782:	74 08                	je     80078c <strnlen+0x1f>
  800784:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800788:	75 f3                	jne    80077d <strnlen+0x10>
  80078a:	89 c2                	mov    %eax,%edx
	return n;
}
  80078c:	89 d0                	mov    %edx,%eax
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079a:	b8 00 00 00 00       	mov    $0x0,%eax
  80079f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007a3:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007a6:	83 c0 01             	add    $0x1,%eax
  8007a9:	84 d2                	test   %dl,%dl
  8007ab:	75 f2                	jne    80079f <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ad:	89 c8                	mov    %ecx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	83 ec 10             	sub    $0x10,%esp
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007be:	53                   	push   %ebx
  8007bf:	e8 91 ff ff ff       	call   800755 <strlen>
  8007c4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007c7:	ff 75 0c             	push   0xc(%ebp)
  8007ca:	01 d8                	add    %ebx,%eax
  8007cc:	50                   	push   %eax
  8007cd:	e8 be ff ff ff       	call   800790 <strcpy>
	return dst;
}
  8007d2:	89 d8                	mov    %ebx,%eax
  8007d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	56                   	push   %esi
  8007dd:	53                   	push   %ebx
  8007de:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e4:	89 f3                	mov    %esi,%ebx
  8007e6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e9:	89 f0                	mov    %esi,%eax
  8007eb:	eb 0f                	jmp    8007fc <strncpy+0x23>
		*dst++ = *src;
  8007ed:	83 c0 01             	add    $0x1,%eax
  8007f0:	0f b6 0a             	movzbl (%edx),%ecx
  8007f3:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f6:	80 f9 01             	cmp    $0x1,%cl
  8007f9:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007fc:	39 d8                	cmp    %ebx,%eax
  8007fe:	75 ed                	jne    8007ed <strncpy+0x14>
	}
	return ret;
}
  800800:	89 f0                	mov    %esi,%eax
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800811:	8b 55 10             	mov    0x10(%ebp),%edx
  800814:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800816:	85 d2                	test   %edx,%edx
  800818:	74 21                	je     80083b <strlcpy+0x35>
  80081a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081e:	89 f2                	mov    %esi,%edx
  800820:	eb 09                	jmp    80082b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800822:	83 c1 01             	add    $0x1,%ecx
  800825:	83 c2 01             	add    $0x1,%edx
  800828:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80082b:	39 c2                	cmp    %eax,%edx
  80082d:	74 09                	je     800838 <strlcpy+0x32>
  80082f:	0f b6 19             	movzbl (%ecx),%ebx
  800832:	84 db                	test   %bl,%bl
  800834:	75 ec                	jne    800822 <strlcpy+0x1c>
  800836:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800838:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083b:	29 f0                	sub    %esi,%eax
}
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084a:	eb 06                	jmp    800852 <strcmp+0x11>
		p++, q++;
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800852:	0f b6 01             	movzbl (%ecx),%eax
  800855:	84 c0                	test   %al,%al
  800857:	74 04                	je     80085d <strcmp+0x1c>
  800859:	3a 02                	cmp    (%edx),%al
  80085b:	74 ef                	je     80084c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085d:	0f b6 c0             	movzbl %al,%eax
  800860:	0f b6 12             	movzbl (%edx),%edx
  800863:	29 d0                	sub    %edx,%eax
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 c3                	mov    %eax,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800876:	eb 06                	jmp    80087e <strncmp+0x17>
		n--, p++, q++;
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 18                	je     80089a <strncmp+0x33>
  800882:	0f b6 08             	movzbl (%eax),%ecx
  800885:	84 c9                	test   %cl,%cl
  800887:	74 04                	je     80088d <strncmp+0x26>
  800889:	3a 0a                	cmp    (%edx),%cl
  80088b:	74 eb                	je     800878 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 00             	movzbl (%eax),%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
}
  800895:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800898:	c9                   	leave  
  800899:	c3                   	ret    
		return 0;
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	eb f4                	jmp    800895 <strncmp+0x2e>

008008a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ab:	eb 03                	jmp    8008b0 <strchr+0xf>
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	0f b6 10             	movzbl (%eax),%edx
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	74 06                	je     8008bd <strchr+0x1c>
		if (*s == c)
  8008b7:	38 ca                	cmp    %cl,%dl
  8008b9:	75 f2                	jne    8008ad <strchr+0xc>
  8008bb:	eb 05                	jmp    8008c2 <strchr+0x21>
			return (char *) s;
	return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 09                	je     8008de <strfind+0x1a>
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	74 05                	je     8008de <strfind+0x1a>
	for (; *s; s++)
  8008d9:	83 c0 01             	add    $0x1,%eax
  8008dc:	eb f0                	jmp    8008ce <strfind+0xa>
			break;
	return (char *) s;
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	57                   	push   %edi
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ec:	85 c9                	test   %ecx,%ecx
  8008ee:	74 2f                	je     80091f <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f0:	89 f8                	mov    %edi,%eax
  8008f2:	09 c8                	or     %ecx,%eax
  8008f4:	a8 03                	test   $0x3,%al
  8008f6:	75 21                	jne    800919 <memset+0x39>
		c &= 0xFF;
  8008f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	c1 e0 08             	shl    $0x8,%eax
  800901:	89 d3                	mov    %edx,%ebx
  800903:	c1 e3 18             	shl    $0x18,%ebx
  800906:	89 d6                	mov    %edx,%esi
  800908:	c1 e6 10             	shl    $0x10,%esi
  80090b:	09 f3                	or     %esi,%ebx
  80090d:	09 da                	or     %ebx,%edx
  80090f:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800911:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800914:	fc                   	cld    
  800915:	f3 ab                	rep stos %eax,%es:(%edi)
  800917:	eb 06                	jmp    80091f <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091c:	fc                   	cld    
  80091d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091f:	89 f8                	mov    %edi,%eax
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5f                   	pop    %edi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800931:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800934:	39 c6                	cmp    %eax,%esi
  800936:	73 32                	jae    80096a <memmove+0x44>
  800938:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093b:	39 c2                	cmp    %eax,%edx
  80093d:	76 2b                	jbe    80096a <memmove+0x44>
		s += n;
		d += n;
  80093f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	89 d6                	mov    %edx,%esi
  800944:	09 fe                	or     %edi,%esi
  800946:	09 ce                	or     %ecx,%esi
  800948:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094e:	75 0e                	jne    80095e <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800950:	83 ef 04             	sub    $0x4,%edi
  800953:	8d 72 fc             	lea    -0x4(%edx),%esi
  800956:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800959:	fd                   	std    
  80095a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095c:	eb 09                	jmp    800967 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095e:	83 ef 01             	sub    $0x1,%edi
  800961:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800964:	fd                   	std    
  800965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800967:	fc                   	cld    
  800968:	eb 1a                	jmp    800984 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	89 f2                	mov    %esi,%edx
  80096c:	09 c2                	or     %eax,%edx
  80096e:	09 ca                	or     %ecx,%edx
  800970:	f6 c2 03             	test   $0x3,%dl
  800973:	75 0a                	jne    80097f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800975:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800978:	89 c7                	mov    %eax,%edi
  80097a:	fc                   	cld    
  80097b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097d:	eb 05                	jmp    800984 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80097f:	89 c7                	mov    %eax,%edi
  800981:	fc                   	cld    
  800982:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80098e:	ff 75 10             	push   0x10(%ebp)
  800991:	ff 75 0c             	push   0xc(%ebp)
  800994:	ff 75 08             	push   0x8(%ebp)
  800997:	e8 8a ff ff ff       	call   800926 <memmove>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 c6                	mov    %eax,%esi
  8009ab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	eb 06                	jmp    8009b6 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009b6:	39 f0                	cmp    %esi,%eax
  8009b8:	74 14                	je     8009ce <memcmp+0x30>
		if (*s1 != *s2)
  8009ba:	0f b6 08             	movzbl (%eax),%ecx
  8009bd:	0f b6 1a             	movzbl (%edx),%ebx
  8009c0:	38 d9                	cmp    %bl,%cl
  8009c2:	74 ec                	je     8009b0 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009c4:	0f b6 c1             	movzbl %cl,%eax
  8009c7:	0f b6 db             	movzbl %bl,%ebx
  8009ca:	29 d8                	sub    %ebx,%eax
  8009cc:	eb 05                	jmp    8009d3 <memcmp+0x35>
	}

	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e0:	89 c2                	mov    %eax,%edx
  8009e2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e5:	eb 03                	jmp    8009ea <memfind+0x13>
  8009e7:	83 c0 01             	add    $0x1,%eax
  8009ea:	39 d0                	cmp    %edx,%eax
  8009ec:	73 04                	jae    8009f2 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ee:	38 08                	cmp    %cl,(%eax)
  8009f0:	75 f5                	jne    8009e7 <memfind+0x10>
			break;
	return (void *) s;
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a00:	eb 03                	jmp    800a05 <strtol+0x11>
		s++;
  800a02:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a05:	0f b6 02             	movzbl (%edx),%eax
  800a08:	3c 20                	cmp    $0x20,%al
  800a0a:	74 f6                	je     800a02 <strtol+0xe>
  800a0c:	3c 09                	cmp    $0x9,%al
  800a0e:	74 f2                	je     800a02 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a10:	3c 2b                	cmp    $0x2b,%al
  800a12:	74 2a                	je     800a3e <strtol+0x4a>
	int neg = 0;
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a19:	3c 2d                	cmp    $0x2d,%al
  800a1b:	74 2b                	je     800a48 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a23:	75 0f                	jne    800a34 <strtol+0x40>
  800a25:	80 3a 30             	cmpb   $0x30,(%edx)
  800a28:	74 28                	je     800a52 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2a:	85 db                	test   %ebx,%ebx
  800a2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a31:	0f 44 d8             	cmove  %eax,%ebx
  800a34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a39:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a3c:	eb 46                	jmp    800a84 <strtol+0x90>
		s++;
  800a3e:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a41:	bf 00 00 00 00       	mov    $0x0,%edi
  800a46:	eb d5                	jmp    800a1d <strtol+0x29>
		s++, neg = 1;
  800a48:	83 c2 01             	add    $0x1,%edx
  800a4b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a50:	eb cb                	jmp    800a1d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a52:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a56:	74 0e                	je     800a66 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a58:	85 db                	test   %ebx,%ebx
  800a5a:	75 d8                	jne    800a34 <strtol+0x40>
		s++, base = 8;
  800a5c:	83 c2 01             	add    $0x1,%edx
  800a5f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a64:	eb ce                	jmp    800a34 <strtol+0x40>
		s += 2, base = 16;
  800a66:	83 c2 02             	add    $0x2,%edx
  800a69:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6e:	eb c4                	jmp    800a34 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a70:	0f be c0             	movsbl %al,%eax
  800a73:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a76:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a79:	7d 3a                	jge    800ab5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a7b:	83 c2 01             	add    $0x1,%edx
  800a7e:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a82:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a84:	0f b6 02             	movzbl (%edx),%eax
  800a87:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a8a:	89 f3                	mov    %esi,%ebx
  800a8c:	80 fb 09             	cmp    $0x9,%bl
  800a8f:	76 df                	jbe    800a70 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a91:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a94:	89 f3                	mov    %esi,%ebx
  800a96:	80 fb 19             	cmp    $0x19,%bl
  800a99:	77 08                	ja     800aa3 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a9b:	0f be c0             	movsbl %al,%eax
  800a9e:	83 e8 57             	sub    $0x57,%eax
  800aa1:	eb d3                	jmp    800a76 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800aa3:	8d 70 bf             	lea    -0x41(%eax),%esi
  800aa6:	89 f3                	mov    %esi,%ebx
  800aa8:	80 fb 19             	cmp    $0x19,%bl
  800aab:	77 08                	ja     800ab5 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800aad:	0f be c0             	movsbl %al,%eax
  800ab0:	83 e8 37             	sub    $0x37,%eax
  800ab3:	eb c1                	jmp    800a76 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab9:	74 05                	je     800ac0 <strtol+0xcc>
		*endptr = (char *) s;
  800abb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abe:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ac0:	89 c8                	mov    %ecx,%eax
  800ac2:	f7 d8                	neg    %eax
  800ac4:	85 ff                	test   %edi,%edi
  800ac6:	0f 45 c8             	cmovne %eax,%ecx
}
  800ac9:	89 c8                	mov    %ecx,%eax
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  800adb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ade:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae1:	89 c3                	mov    %eax,%ebx
  800ae3:	89 c7                	mov    %eax,%edi
  800ae5:	89 c6                	mov    %eax,%esi
  800ae7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_cgetc>:

int
sys_cgetc(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	b8 01 00 00 00       	mov    $0x1,%eax
  800afe:	89 d1                	mov    %edx,%ecx
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	89 d7                	mov    %edx,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b23:	89 cb                	mov    %ecx,%ebx
  800b25:	89 cf                	mov    %ecx,%edi
  800b27:	89 ce                	mov    %ecx,%esi
  800b29:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	7f 08                	jg     800b37 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	50                   	push   %eax
  800b3b:	6a 03                	push   $0x3
  800b3d:	68 ff 2b 80 00       	push   $0x802bff
  800b42:	6a 2a                	push   $0x2a
  800b44:	68 1c 2c 80 00       	push   $0x802c1c
  800b49:	e8 8d f5 ff ff       	call   8000db <_panic>

00800b4e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5e:	89 d1                	mov    %edx,%ecx
  800b60:	89 d3                	mov    %edx,%ebx
  800b62:	89 d7                	mov    %edx,%edi
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_yield>:

void
sys_yield(void)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b73:	ba 00 00 00 00       	mov    $0x0,%edx
  800b78:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7d:	89 d1                	mov    %edx,%ecx
  800b7f:	89 d3                	mov    %edx,%ebx
  800b81:	89 d7                	mov    %edx,%edi
  800b83:	89 d6                	mov    %edx,%esi
  800b85:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b95:	be 00 00 00 00       	mov    $0x0,%esi
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba8:	89 f7                	mov    %esi,%edi
  800baa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bac:	85 c0                	test   %eax,%eax
  800bae:	7f 08                	jg     800bb8 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	50                   	push   %eax
  800bbc:	6a 04                	push   $0x4
  800bbe:	68 ff 2b 80 00       	push   $0x802bff
  800bc3:	6a 2a                	push   $0x2a
  800bc5:	68 1c 2c 80 00       	push   $0x802c1c
  800bca:	e8 0c f5 ff ff       	call   8000db <_panic>

00800bcf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
  800bd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	b8 05 00 00 00       	mov    $0x5,%eax
  800be3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bee:	85 c0                	test   %eax,%eax
  800bf0:	7f 08                	jg     800bfa <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 05                	push   $0x5
  800c00:	68 ff 2b 80 00       	push   $0x802bff
  800c05:	6a 2a                	push   $0x2a
  800c07:	68 1c 2c 80 00       	push   $0x802c1c
  800c0c:	e8 ca f4 ff ff       	call   8000db <_panic>

00800c11 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2a:	89 df                	mov    %ebx,%edi
  800c2c:	89 de                	mov    %ebx,%esi
  800c2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	7f 08                	jg     800c3c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 06                	push   $0x6
  800c42:	68 ff 2b 80 00       	push   $0x802bff
  800c47:	6a 2a                	push   $0x2a
  800c49:	68 1c 2c 80 00       	push   $0x802c1c
  800c4e:	e8 88 f4 ff ff       	call   8000db <_panic>

00800c53 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6c:	89 df                	mov    %ebx,%edi
  800c6e:	89 de                	mov    %ebx,%esi
  800c70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c72:	85 c0                	test   %eax,%eax
  800c74:	7f 08                	jg     800c7e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 08                	push   $0x8
  800c84:	68 ff 2b 80 00       	push   $0x802bff
  800c89:	6a 2a                	push   $0x2a
  800c8b:	68 1c 2c 80 00       	push   $0x802c1c
  800c90:	e8 46 f4 ff ff       	call   8000db <_panic>

00800c95 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 09 00 00 00       	mov    $0x9,%eax
  800cae:	89 df                	mov    %ebx,%edi
  800cb0:	89 de                	mov    %ebx,%esi
  800cb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7f 08                	jg     800cc0 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 09                	push   $0x9
  800cc6:	68 ff 2b 80 00       	push   $0x802bff
  800ccb:	6a 2a                	push   $0x2a
  800ccd:	68 1c 2c 80 00       	push   $0x802c1c
  800cd2:	e8 04 f4 ff ff       	call   8000db <_panic>

00800cd7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf0:	89 df                	mov    %ebx,%edi
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7f 08                	jg     800d02 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0a                	push   $0xa
  800d08:	68 ff 2b 80 00       	push   $0x802bff
  800d0d:	6a 2a                	push   $0x2a
  800d0f:	68 1c 2c 80 00       	push   $0x802c1c
  800d14:	e8 c2 f3 ff ff       	call   8000db <_panic>

00800d19 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2a:	be 00 00 00 00       	mov    $0x0,%esi
  800d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d35:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d52:	89 cb                	mov    %ecx,%ebx
  800d54:	89 cf                	mov    %ecx,%edi
  800d56:	89 ce                	mov    %ecx,%esi
  800d58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7f 08                	jg     800d66 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
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
  800d6a:	6a 0d                	push   $0xd
  800d6c:	68 ff 2b 80 00       	push   $0x802bff
  800d71:	6a 2a                	push   $0x2a
  800d73:	68 1c 2c 80 00       	push   $0x802c1c
  800d78:	e8 5e f3 ff ff       	call   8000db <_panic>

00800d7d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d83:	ba 00 00 00 00       	mov    $0x0,%edx
  800d88:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d8d:	89 d1                	mov    %edx,%ecx
  800d8f:	89 d3                	mov    %edx,%ebx
  800d91:	89 d7                	mov    %edx,%edi
  800d93:	89 d6                	mov    %edx,%esi
  800d95:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	b8 0f 00 00 00       	mov    $0xf,%eax
  800db2:	89 df                	mov    %ebx,%edi
  800db4:	89 de                	mov    %ebx,%esi
  800db6:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dce:	b8 10 00 00 00       	mov    $0x10,%eax
  800dd3:	89 df                	mov    %ebx,%edi
  800dd5:	89 de                	mov    %ebx,%esi
  800dd7:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

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
	int i;
	for (i = 0; devtab[i]; i++)
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800eb9:	39 13                	cmp    %edx,(%ebx)
  800ebb:	74 37                	je     800ef4 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800ebd:	83 c0 01             	add    $0x1,%eax
  800ec0:	8b 1c 85 a8 2c 80 00 	mov    0x802ca8(,%eax,4),%ebx
  800ec7:	85 db                	test   %ebx,%ebx
  800ec9:	75 ee                	jne    800eb9 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ecb:	a1 00 40 80 00       	mov    0x804000,%eax
  800ed0:	8b 40 48             	mov    0x48(%eax),%eax
  800ed3:	83 ec 04             	sub    $0x4,%esp
  800ed6:	52                   	push   %edx
  800ed7:	50                   	push   %eax
  800ed8:	68 2c 2c 80 00       	push   $0x802c2c
  800edd:	e8 d4 f2 ff ff       	call   8001b6 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800eea:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eed:	89 1a                	mov    %ebx,(%edx)
}
  800eef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    
			return 0;
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef9:	eb ef                	jmp    800eea <dev_lookup+0x45>

00800efb <fd_close>:
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 24             	sub    $0x24,%esp
  800f04:	8b 75 08             	mov    0x8(%ebp),%esi
  800f07:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f0d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f0e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f14:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f17:	50                   	push   %eax
  800f18:	e8 38 ff ff ff       	call   800e55 <fd_lookup>
  800f1d:	89 c3                	mov    %eax,%ebx
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	78 05                	js     800f2b <fd_close+0x30>
	    || fd != fd2)
  800f26:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f29:	74 16                	je     800f41 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f2b:	89 f8                	mov    %edi,%eax
  800f2d:	84 c0                	test   %al,%al
  800f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f34:	0f 44 d8             	cmove  %eax,%ebx
}
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f41:	83 ec 08             	sub    $0x8,%esp
  800f44:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f47:	50                   	push   %eax
  800f48:	ff 36                	push   (%esi)
  800f4a:	e8 56 ff ff ff       	call   800ea5 <dev_lookup>
  800f4f:	89 c3                	mov    %eax,%ebx
  800f51:	83 c4 10             	add    $0x10,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	78 1a                	js     800f72 <fd_close+0x77>
		if (dev->dev_close)
  800f58:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f5b:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f63:	85 c0                	test   %eax,%eax
  800f65:	74 0b                	je     800f72 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	56                   	push   %esi
  800f6b:	ff d0                	call   *%eax
  800f6d:	89 c3                	mov    %eax,%ebx
  800f6f:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	56                   	push   %esi
  800f76:	6a 00                	push   $0x0
  800f78:	e8 94 fc ff ff       	call   800c11 <sys_page_unmap>
	return r;
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	eb b5                	jmp    800f37 <fd_close+0x3c>

00800f82 <close>:

int
close(int fdnum)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8b:	50                   	push   %eax
  800f8c:	ff 75 08             	push   0x8(%ebp)
  800f8f:	e8 c1 fe ff ff       	call   800e55 <fd_lookup>
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	79 02                	jns    800f9d <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    
		return fd_close(fd, 1);
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	6a 01                	push   $0x1
  800fa2:	ff 75 f4             	push   -0xc(%ebp)
  800fa5:	e8 51 ff ff ff       	call   800efb <fd_close>
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	eb ec                	jmp    800f9b <close+0x19>

00800faf <close_all>:

void
close_all(void)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	53                   	push   %ebx
  800fbf:	e8 be ff ff ff       	call   800f82 <close>
	for (i = 0; i < MAXFD; i++)
  800fc4:	83 c3 01             	add    $0x1,%ebx
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	83 fb 20             	cmp    $0x20,%ebx
  800fcd:	75 ec                	jne    800fbb <close_all+0xc>
}
  800fcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    

00800fd4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fdd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	ff 75 08             	push   0x8(%ebp)
  800fe4:	e8 6c fe ff ff       	call   800e55 <fd_lookup>
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 7f                	js     801071 <dup+0x9d>
		return r;
	close(newfdnum);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	ff 75 0c             	push   0xc(%ebp)
  800ff8:	e8 85 ff ff ff       	call   800f82 <close>

	newfd = INDEX2FD(newfdnum);
  800ffd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801000:	c1 e6 0c             	shl    $0xc,%esi
  801003:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801009:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80100c:	89 3c 24             	mov    %edi,(%esp)
  80100f:	e8 da fd ff ff       	call   800dee <fd2data>
  801014:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801016:	89 34 24             	mov    %esi,(%esp)
  801019:	e8 d0 fd ff ff       	call   800dee <fd2data>
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801024:	89 d8                	mov    %ebx,%eax
  801026:	c1 e8 16             	shr    $0x16,%eax
  801029:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801030:	a8 01                	test   $0x1,%al
  801032:	74 11                	je     801045 <dup+0x71>
  801034:	89 d8                	mov    %ebx,%eax
  801036:	c1 e8 0c             	shr    $0xc,%eax
  801039:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801040:	f6 c2 01             	test   $0x1,%dl
  801043:	75 36                	jne    80107b <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801045:	89 f8                	mov    %edi,%eax
  801047:	c1 e8 0c             	shr    $0xc,%eax
  80104a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	25 07 0e 00 00       	and    $0xe07,%eax
  801059:	50                   	push   %eax
  80105a:	56                   	push   %esi
  80105b:	6a 00                	push   $0x0
  80105d:	57                   	push   %edi
  80105e:	6a 00                	push   $0x0
  801060:	e8 6a fb ff ff       	call   800bcf <sys_page_map>
  801065:	89 c3                	mov    %eax,%ebx
  801067:	83 c4 20             	add    $0x20,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 33                	js     8010a1 <dup+0xcd>
		goto err;

	return newfdnum;
  80106e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801071:	89 d8                	mov    %ebx,%eax
  801073:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5f                   	pop    %edi
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80107b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	25 07 0e 00 00       	and    $0xe07,%eax
  80108a:	50                   	push   %eax
  80108b:	ff 75 d4             	push   -0x2c(%ebp)
  80108e:	6a 00                	push   $0x0
  801090:	53                   	push   %ebx
  801091:	6a 00                	push   $0x0
  801093:	e8 37 fb ff ff       	call   800bcf <sys_page_map>
  801098:	89 c3                	mov    %eax,%ebx
  80109a:	83 c4 20             	add    $0x20,%esp
  80109d:	85 c0                	test   %eax,%eax
  80109f:	79 a4                	jns    801045 <dup+0x71>
	sys_page_unmap(0, newfd);
  8010a1:	83 ec 08             	sub    $0x8,%esp
  8010a4:	56                   	push   %esi
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 65 fb ff ff       	call   800c11 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010ac:	83 c4 08             	add    $0x8,%esp
  8010af:	ff 75 d4             	push   -0x2c(%ebp)
  8010b2:	6a 00                	push   $0x0
  8010b4:	e8 58 fb ff ff       	call   800c11 <sys_page_unmap>
	return r;
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	eb b3                	jmp    801071 <dup+0x9d>

008010be <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	56                   	push   %esi
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 18             	sub    $0x18,%esp
  8010c6:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010cc:	50                   	push   %eax
  8010cd:	56                   	push   %esi
  8010ce:	e8 82 fd ff ff       	call   800e55 <fd_lookup>
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	78 3c                	js     801116 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010da:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8010dd:	83 ec 08             	sub    $0x8,%esp
  8010e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e3:	50                   	push   %eax
  8010e4:	ff 33                	push   (%ebx)
  8010e6:	e8 ba fd ff ff       	call   800ea5 <dev_lookup>
  8010eb:	83 c4 10             	add    $0x10,%esp
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	78 24                	js     801116 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010f2:	8b 43 08             	mov    0x8(%ebx),%eax
  8010f5:	83 e0 03             	and    $0x3,%eax
  8010f8:	83 f8 01             	cmp    $0x1,%eax
  8010fb:	74 20                	je     80111d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801100:	8b 40 08             	mov    0x8(%eax),%eax
  801103:	85 c0                	test   %eax,%eax
  801105:	74 37                	je     80113e <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	ff 75 10             	push   0x10(%ebp)
  80110d:	ff 75 0c             	push   0xc(%ebp)
  801110:	53                   	push   %ebx
  801111:	ff d0                	call   *%eax
  801113:	83 c4 10             	add    $0x10,%esp
}
  801116:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80111d:	a1 00 40 80 00       	mov    0x804000,%eax
  801122:	8b 40 48             	mov    0x48(%eax),%eax
  801125:	83 ec 04             	sub    $0x4,%esp
  801128:	56                   	push   %esi
  801129:	50                   	push   %eax
  80112a:	68 6d 2c 80 00       	push   $0x802c6d
  80112f:	e8 82 f0 ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113c:	eb d8                	jmp    801116 <read+0x58>
		return -E_NOT_SUPP;
  80113e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801143:	eb d1                	jmp    801116 <read+0x58>

00801145 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 0c             	sub    $0xc,%esp
  80114e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801151:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801154:	bb 00 00 00 00       	mov    $0x0,%ebx
  801159:	eb 02                	jmp    80115d <readn+0x18>
  80115b:	01 c3                	add    %eax,%ebx
  80115d:	39 f3                	cmp    %esi,%ebx
  80115f:	73 21                	jae    801182 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	89 f0                	mov    %esi,%eax
  801166:	29 d8                	sub    %ebx,%eax
  801168:	50                   	push   %eax
  801169:	89 d8                	mov    %ebx,%eax
  80116b:	03 45 0c             	add    0xc(%ebp),%eax
  80116e:	50                   	push   %eax
  80116f:	57                   	push   %edi
  801170:	e8 49 ff ff ff       	call   8010be <read>
		if (m < 0)
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	85 c0                	test   %eax,%eax
  80117a:	78 04                	js     801180 <readn+0x3b>
			return m;
		if (m == 0)
  80117c:	75 dd                	jne    80115b <readn+0x16>
  80117e:	eb 02                	jmp    801182 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801180:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801182:	89 d8                	mov    %ebx,%eax
  801184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	56                   	push   %esi
  801190:	53                   	push   %ebx
  801191:	83 ec 18             	sub    $0x18,%esp
  801194:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801197:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119a:	50                   	push   %eax
  80119b:	53                   	push   %ebx
  80119c:	e8 b4 fc ff ff       	call   800e55 <fd_lookup>
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	78 37                	js     8011df <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a8:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011ab:	83 ec 08             	sub    $0x8,%esp
  8011ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	ff 36                	push   (%esi)
  8011b4:	e8 ec fc ff ff       	call   800ea5 <dev_lookup>
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 1f                	js     8011df <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c0:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011c4:	74 20                	je     8011e6 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	74 37                	je     801207 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011d0:	83 ec 04             	sub    $0x4,%esp
  8011d3:	ff 75 10             	push   0x10(%ebp)
  8011d6:	ff 75 0c             	push   0xc(%ebp)
  8011d9:	56                   	push   %esi
  8011da:	ff d0                	call   *%eax
  8011dc:	83 c4 10             	add    $0x10,%esp
}
  8011df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e6:	a1 00 40 80 00       	mov    0x804000,%eax
  8011eb:	8b 40 48             	mov    0x48(%eax),%eax
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	53                   	push   %ebx
  8011f2:	50                   	push   %eax
  8011f3:	68 89 2c 80 00       	push   $0x802c89
  8011f8:	e8 b9 ef ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801205:	eb d8                	jmp    8011df <write+0x53>
		return -E_NOT_SUPP;
  801207:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80120c:	eb d1                	jmp    8011df <write+0x53>

0080120e <seek>:

int
seek(int fdnum, off_t offset)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801214:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801217:	50                   	push   %eax
  801218:	ff 75 08             	push   0x8(%ebp)
  80121b:	e8 35 fc ff ff       	call   800e55 <fd_lookup>
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	78 0e                	js     801235 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801235:	c9                   	leave  
  801236:	c3                   	ret    

00801237 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	56                   	push   %esi
  80123b:	53                   	push   %ebx
  80123c:	83 ec 18             	sub    $0x18,%esp
  80123f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801242:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801245:	50                   	push   %eax
  801246:	53                   	push   %ebx
  801247:	e8 09 fc ff ff       	call   800e55 <fd_lookup>
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	78 34                	js     801287 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801253:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801256:	83 ec 08             	sub    $0x8,%esp
  801259:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 36                	push   (%esi)
  80125f:	e8 41 fc ff ff       	call   800ea5 <dev_lookup>
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 1c                	js     801287 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126b:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80126f:	74 1d                	je     80128e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801271:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801274:	8b 40 18             	mov    0x18(%eax),%eax
  801277:	85 c0                	test   %eax,%eax
  801279:	74 34                	je     8012af <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	ff 75 0c             	push   0xc(%ebp)
  801281:	56                   	push   %esi
  801282:	ff d0                	call   *%eax
  801284:	83 c4 10             	add    $0x10,%esp
}
  801287:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80128a:	5b                   	pop    %ebx
  80128b:	5e                   	pop    %esi
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80128e:	a1 00 40 80 00       	mov    0x804000,%eax
  801293:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801296:	83 ec 04             	sub    $0x4,%esp
  801299:	53                   	push   %ebx
  80129a:	50                   	push   %eax
  80129b:	68 4c 2c 80 00       	push   $0x802c4c
  8012a0:	e8 11 ef ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ad:	eb d8                	jmp    801287 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8012af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012b4:	eb d1                	jmp    801287 <ftruncate+0x50>

008012b6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	56                   	push   %esi
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 18             	sub    $0x18,%esp
  8012be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	ff 75 08             	push   0x8(%ebp)
  8012c8:	e8 88 fb ff ff       	call   800e55 <fd_lookup>
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 49                	js     80131d <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012dd:	50                   	push   %eax
  8012de:	ff 36                	push   (%esi)
  8012e0:	e8 c0 fb ff ff       	call   800ea5 <dev_lookup>
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 31                	js     80131d <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8012ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012f3:	74 2f                	je     801324 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012ff:	00 00 00 
	stat->st_isdir = 0;
  801302:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801309:	00 00 00 
	stat->st_dev = dev;
  80130c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	53                   	push   %ebx
  801316:	56                   	push   %esi
  801317:	ff 50 14             	call   *0x14(%eax)
  80131a:	83 c4 10             	add    $0x10,%esp
}
  80131d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    
		return -E_NOT_SUPP;
  801324:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801329:	eb f2                	jmp    80131d <fstat+0x67>

0080132b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	56                   	push   %esi
  80132f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	6a 00                	push   $0x0
  801335:	ff 75 08             	push   0x8(%ebp)
  801338:	e8 e4 01 00 00       	call   801521 <open>
  80133d:	89 c3                	mov    %eax,%ebx
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	78 1b                	js     801361 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	ff 75 0c             	push   0xc(%ebp)
  80134c:	50                   	push   %eax
  80134d:	e8 64 ff ff ff       	call   8012b6 <fstat>
  801352:	89 c6                	mov    %eax,%esi
	close(fd);
  801354:	89 1c 24             	mov    %ebx,(%esp)
  801357:	e8 26 fc ff ff       	call   800f82 <close>
	return r;
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	89 f3                	mov    %esi,%ebx
}
  801361:	89 d8                	mov    %ebx,%eax
  801363:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801366:	5b                   	pop    %ebx
  801367:	5e                   	pop    %esi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	56                   	push   %esi
  80136e:	53                   	push   %ebx
  80136f:	89 c6                	mov    %eax,%esi
  801371:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801373:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80137a:	74 27                	je     8013a3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80137c:	6a 07                	push   $0x7
  80137e:	68 00 50 80 00       	push   $0x805000
  801383:	56                   	push   %esi
  801384:	ff 35 00 60 80 00    	push   0x806000
  80138a:	e8 d6 11 00 00       	call   802565 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80138f:	83 c4 0c             	add    $0xc,%esp
  801392:	6a 00                	push   $0x0
  801394:	53                   	push   %ebx
  801395:	6a 00                	push   $0x0
  801397:	e8 62 11 00 00       	call   8024fe <ipc_recv>
}
  80139c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013a3:	83 ec 0c             	sub    $0xc,%esp
  8013a6:	6a 01                	push   $0x1
  8013a8:	e8 0c 12 00 00       	call   8025b9 <ipc_find_env>
  8013ad:	a3 00 60 80 00       	mov    %eax,0x806000
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	eb c5                	jmp    80137c <fsipc+0x12>

008013b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013cb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8013da:	e8 8b ff ff ff       	call   80136a <fsipc>
}
  8013df:	c9                   	leave  
  8013e0:	c3                   	ret    

008013e1 <devfile_flush>:
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ed:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8013fc:	e8 69 ff ff ff       	call   80136a <fsipc>
}
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <devfile_stat>:
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	53                   	push   %ebx
  801407:	83 ec 04             	sub    $0x4,%esp
  80140a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
  801410:	8b 40 0c             	mov    0xc(%eax),%eax
  801413:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801418:	ba 00 00 00 00       	mov    $0x0,%edx
  80141d:	b8 05 00 00 00       	mov    $0x5,%eax
  801422:	e8 43 ff ff ff       	call   80136a <fsipc>
  801427:	85 c0                	test   %eax,%eax
  801429:	78 2c                	js     801457 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	68 00 50 80 00       	push   $0x805000
  801433:	53                   	push   %ebx
  801434:	e8 57 f3 ff ff       	call   800790 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801439:	a1 80 50 80 00       	mov    0x805080,%eax
  80143e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801444:	a1 84 50 80 00       	mov    0x805084,%eax
  801449:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801457:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145a:	c9                   	leave  
  80145b:	c3                   	ret    

0080145c <devfile_write>:
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 0c             	sub    $0xc,%esp
  801462:	8b 45 10             	mov    0x10(%ebp),%eax
  801465:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80146a:	39 d0                	cmp    %edx,%eax
  80146c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80146f:	8b 55 08             	mov    0x8(%ebp),%edx
  801472:	8b 52 0c             	mov    0xc(%edx),%edx
  801475:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80147b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801480:	50                   	push   %eax
  801481:	ff 75 0c             	push   0xc(%ebp)
  801484:	68 08 50 80 00       	push   $0x805008
  801489:	e8 98 f4 ff ff       	call   800926 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80148e:	ba 00 00 00 00       	mov    $0x0,%edx
  801493:	b8 04 00 00 00       	mov    $0x4,%eax
  801498:	e8 cd fe ff ff       	call   80136a <fsipc>
}
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <devfile_read>:
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	56                   	push   %esi
  8014a3:	53                   	push   %ebx
  8014a4:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014b2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c2:	e8 a3 fe ff ff       	call   80136a <fsipc>
  8014c7:	89 c3                	mov    %eax,%ebx
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 1f                	js     8014ec <devfile_read+0x4d>
	assert(r <= n);
  8014cd:	39 f0                	cmp    %esi,%eax
  8014cf:	77 24                	ja     8014f5 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8014d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014d6:	7f 33                	jg     80150b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	50                   	push   %eax
  8014dc:	68 00 50 80 00       	push   $0x805000
  8014e1:	ff 75 0c             	push   0xc(%ebp)
  8014e4:	e8 3d f4 ff ff       	call   800926 <memmove>
	return r;
  8014e9:	83 c4 10             	add    $0x10,%esp
}
  8014ec:	89 d8                	mov    %ebx,%eax
  8014ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5e                   	pop    %esi
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    
	assert(r <= n);
  8014f5:	68 bc 2c 80 00       	push   $0x802cbc
  8014fa:	68 c3 2c 80 00       	push   $0x802cc3
  8014ff:	6a 7c                	push   $0x7c
  801501:	68 d8 2c 80 00       	push   $0x802cd8
  801506:	e8 d0 eb ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  80150b:	68 e3 2c 80 00       	push   $0x802ce3
  801510:	68 c3 2c 80 00       	push   $0x802cc3
  801515:	6a 7d                	push   $0x7d
  801517:	68 d8 2c 80 00       	push   $0x802cd8
  80151c:	e8 ba eb ff ff       	call   8000db <_panic>

00801521 <open>:
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	56                   	push   %esi
  801525:	53                   	push   %ebx
  801526:	83 ec 1c             	sub    $0x1c,%esp
  801529:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80152c:	56                   	push   %esi
  80152d:	e8 23 f2 ff ff       	call   800755 <strlen>
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80153a:	7f 6c                	jg     8015a8 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80153c:	83 ec 0c             	sub    $0xc,%esp
  80153f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801542:	50                   	push   %eax
  801543:	e8 bd f8 ff ff       	call   800e05 <fd_alloc>
  801548:	89 c3                	mov    %eax,%ebx
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 3c                	js     80158d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	56                   	push   %esi
  801555:	68 00 50 80 00       	push   $0x805000
  80155a:	e8 31 f2 ff ff       	call   800790 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80155f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801562:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801567:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156a:	b8 01 00 00 00       	mov    $0x1,%eax
  80156f:	e8 f6 fd ff ff       	call   80136a <fsipc>
  801574:	89 c3                	mov    %eax,%ebx
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 19                	js     801596 <open+0x75>
	return fd2num(fd);
  80157d:	83 ec 0c             	sub    $0xc,%esp
  801580:	ff 75 f4             	push   -0xc(%ebp)
  801583:	e8 56 f8 ff ff       	call   800dde <fd2num>
  801588:	89 c3                	mov    %eax,%ebx
  80158a:	83 c4 10             	add    $0x10,%esp
}
  80158d:	89 d8                	mov    %ebx,%eax
  80158f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    
		fd_close(fd, 0);
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	6a 00                	push   $0x0
  80159b:	ff 75 f4             	push   -0xc(%ebp)
  80159e:	e8 58 f9 ff ff       	call   800efb <fd_close>
		return r;
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	eb e5                	jmp    80158d <open+0x6c>
		return -E_BAD_PATH;
  8015a8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015ad:	eb de                	jmp    80158d <open+0x6c>

008015af <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8015bf:	e8 a6 fd ff ff       	call   80136a <fsipc>
}
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	57                   	push   %edi
  8015ca:	56                   	push   %esi
  8015cb:	53                   	push   %ebx
  8015cc:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015d2:	6a 00                	push   $0x0
  8015d4:	ff 75 08             	push   0x8(%ebp)
  8015d7:	e8 45 ff ff ff       	call   801521 <open>
  8015dc:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	0f 88 aa 04 00 00    	js     801a97 <spawn+0x4d1>
  8015ed:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015ef:	83 ec 04             	sub    $0x4,%esp
  8015f2:	68 00 02 00 00       	push   $0x200
  8015f7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	57                   	push   %edi
  8015ff:	e8 41 fb ff ff       	call   801145 <readn>
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	3d 00 02 00 00       	cmp    $0x200,%eax
  80160c:	75 57                	jne    801665 <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  80160e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801615:	45 4c 46 
  801618:	75 4b                	jne    801665 <spawn+0x9f>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80161a:	b8 07 00 00 00       	mov    $0x7,%eax
  80161f:	cd 30                	int    $0x30
  801621:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801627:	85 c0                	test   %eax,%eax
  801629:	0f 88 5c 04 00 00    	js     801a8b <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80162f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801634:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801637:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80163d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801643:	b9 11 00 00 00       	mov    $0x11,%ecx
  801648:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80164a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801650:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801656:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80165b:	be 00 00 00 00       	mov    $0x0,%esi
  801660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  801663:	eb 4b                	jmp    8016b0 <spawn+0xea>
		close(fd);
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80166e:	e8 0f f9 ff ff       	call   800f82 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801673:	83 c4 0c             	add    $0xc,%esp
  801676:	68 7f 45 4c 46       	push   $0x464c457f
  80167b:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  801681:	68 ef 2c 80 00       	push   $0x802cef
  801686:	e8 2b eb ff ff       	call   8001b6 <cprintf>
		return -E_NOT_EXEC;
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  801695:	ff ff ff 
  801698:	e9 fa 03 00 00       	jmp    801a97 <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  80169d:	83 ec 0c             	sub    $0xc,%esp
  8016a0:	50                   	push   %eax
  8016a1:	e8 af f0 ff ff       	call   800755 <strlen>
  8016a6:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8016aa:	83 c3 01             	add    $0x1,%ebx
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016b7:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	75 df                	jne    80169d <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016be:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8016c4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8016ca:	b8 00 10 40 00       	mov    $0x401000,%eax
  8016cf:	29 f0                	sub    %esi,%eax
  8016d1:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	83 e2 fc             	and    $0xfffffffc,%edx
  8016d8:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016df:	29 c2                	sub    %eax,%edx
  8016e1:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016e7:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016ea:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016ef:	0f 86 14 04 00 00    	jbe    801b09 <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016f5:	83 ec 04             	sub    $0x4,%esp
  8016f8:	6a 07                	push   $0x7
  8016fa:	68 00 00 40 00       	push   $0x400000
  8016ff:	6a 00                	push   $0x0
  801701:	e8 86 f4 ff ff       	call   800b8c <sys_page_alloc>
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	85 c0                	test   %eax,%eax
  80170b:	0f 88 fd 03 00 00    	js     801b0e <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801711:	be 00 00 00 00       	mov    $0x0,%esi
  801716:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80171c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80171f:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801725:	7e 32                	jle    801759 <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  801727:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80172d:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801733:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801736:	83 ec 08             	sub    $0x8,%esp
  801739:	ff 34 b3             	push   (%ebx,%esi,4)
  80173c:	57                   	push   %edi
  80173d:	e8 4e f0 ff ff       	call   800790 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801742:	83 c4 04             	add    $0x4,%esp
  801745:	ff 34 b3             	push   (%ebx,%esi,4)
  801748:	e8 08 f0 ff ff       	call   800755 <strlen>
  80174d:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801751:	83 c6 01             	add    $0x1,%esi
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	eb c6                	jmp    80171f <spawn+0x159>
	}
	argv_store[argc] = 0;
  801759:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80175f:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801765:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80176c:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801772:	0f 85 8c 00 00 00    	jne    801804 <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801778:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80177e:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801784:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801787:	89 c8                	mov    %ecx,%eax
  801789:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  80178f:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801792:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801797:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	6a 07                	push   $0x7
  8017a2:	68 00 d0 bf ee       	push   $0xeebfd000
  8017a7:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8017ad:	68 00 00 40 00       	push   $0x400000
  8017b2:	6a 00                	push   $0x0
  8017b4:	e8 16 f4 ff ff       	call   800bcf <sys_page_map>
  8017b9:	89 c3                	mov    %eax,%ebx
  8017bb:	83 c4 20             	add    $0x20,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	0f 88 50 03 00 00    	js     801b16 <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	68 00 00 40 00       	push   $0x400000
  8017ce:	6a 00                	push   $0x0
  8017d0:	e8 3c f4 ff ff       	call   800c11 <sys_page_unmap>
  8017d5:	89 c3                	mov    %eax,%ebx
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	0f 88 34 03 00 00    	js     801b16 <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017e2:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017e8:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017ef:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017f5:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8017fc:	00 00 00 
  8017ff:	e9 4e 01 00 00       	jmp    801952 <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801804:	68 7c 2d 80 00       	push   $0x802d7c
  801809:	68 c3 2c 80 00       	push   $0x802cc3
  80180e:	68 f2 00 00 00       	push   $0xf2
  801813:	68 09 2d 80 00       	push   $0x802d09
  801818:	e8 be e8 ff ff       	call   8000db <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80181d:	83 ec 04             	sub    $0x4,%esp
  801820:	6a 07                	push   $0x7
  801822:	68 00 00 40 00       	push   $0x400000
  801827:	6a 00                	push   $0x0
  801829:	e8 5e f3 ff ff       	call   800b8c <sys_page_alloc>
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	85 c0                	test   %eax,%eax
  801833:	0f 88 6c 02 00 00    	js     801aa5 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801839:	83 ec 08             	sub    $0x8,%esp
  80183c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801842:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801848:	50                   	push   %eax
  801849:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80184f:	e8 ba f9 ff ff       	call   80120e <seek>
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	0f 88 4d 02 00 00    	js     801aac <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	89 f8                	mov    %edi,%eax
  801864:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80186a:	ba 00 10 00 00       	mov    $0x1000,%edx
  80186f:	39 d0                	cmp    %edx,%eax
  801871:	0f 47 c2             	cmova  %edx,%eax
  801874:	50                   	push   %eax
  801875:	68 00 00 40 00       	push   $0x400000
  80187a:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801880:	e8 c0 f8 ff ff       	call   801145 <readn>
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	0f 88 23 02 00 00    	js     801ab3 <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801890:	83 ec 0c             	sub    $0xc,%esp
  801893:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801899:	56                   	push   %esi
  80189a:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8018a0:	68 00 00 40 00       	push   $0x400000
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 23 f3 ff ff       	call   800bcf <sys_page_map>
  8018ac:	83 c4 20             	add    $0x20,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 7c                	js     80192f <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	68 00 00 40 00       	push   $0x400000
  8018bb:	6a 00                	push   $0x0
  8018bd:	e8 4f f3 ff ff       	call   800c11 <sys_page_unmap>
  8018c2:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  8018c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8018cb:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8018d1:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8018d7:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8018dd:	76 65                	jbe    801944 <spawn+0x37e>
		if (i >= filesz) {
  8018df:	39 df                	cmp    %ebx,%edi
  8018e1:	0f 87 36 ff ff ff    	ja     80181d <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018e7:	83 ec 04             	sub    $0x4,%esp
  8018ea:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  8018f0:	56                   	push   %esi
  8018f1:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8018f7:	e8 90 f2 ff ff       	call   800b8c <sys_page_alloc>
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	85 c0                	test   %eax,%eax
  801901:	79 c2                	jns    8018c5 <spawn+0x2ff>
  801903:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801905:	83 ec 0c             	sub    $0xc,%esp
  801908:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80190e:	e8 fa f1 ff ff       	call   800b0d <sys_env_destroy>
	close(fd);
  801913:	83 c4 04             	add    $0x4,%esp
  801916:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80191c:	e8 61 f6 ff ff       	call   800f82 <close>
	return r;
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  80192a:	e9 68 01 00 00       	jmp    801a97 <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  80192f:	50                   	push   %eax
  801930:	68 15 2d 80 00       	push   $0x802d15
  801935:	68 25 01 00 00       	push   $0x125
  80193a:	68 09 2d 80 00       	push   $0x802d09
  80193f:	e8 97 e7 ff ff       	call   8000db <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801944:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  80194b:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801952:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801959:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  80195f:	7e 67                	jle    8019c8 <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  801961:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801967:	83 39 01             	cmpl   $0x1,(%ecx)
  80196a:	75 d8                	jne    801944 <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80196c:	8b 41 18             	mov    0x18(%ecx),%eax
  80196f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801975:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801978:	83 f8 01             	cmp    $0x1,%eax
  80197b:	19 c0                	sbb    %eax,%eax
  80197d:	83 e0 fe             	and    $0xfffffffe,%eax
  801980:	83 c0 07             	add    $0x7,%eax
  801983:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801989:	8b 51 04             	mov    0x4(%ecx),%edx
  80198c:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801992:	8b 79 10             	mov    0x10(%ecx),%edi
  801995:	8b 59 14             	mov    0x14(%ecx),%ebx
  801998:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80199e:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  8019a1:	89 f0                	mov    %esi,%eax
  8019a3:	25 ff 0f 00 00       	and    $0xfff,%eax
  8019a8:	74 14                	je     8019be <spawn+0x3f8>
		va -= i;
  8019aa:	29 c6                	sub    %eax,%esi
		memsz += i;
  8019ac:	01 c3                	add    %eax,%ebx
  8019ae:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  8019b4:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8019b6:	29 c2                	sub    %eax,%edx
  8019b8:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8019be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019c3:	e9 09 ff ff ff       	jmp    8018d1 <spawn+0x30b>
	close(fd);
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8019d1:	e8 ac f5 ff ff       	call   800f82 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  8019d6:	e8 73 f1 ff ff       	call   800b4e <sys_getenvid>
  8019db:	89 c6                	mov    %eax,%esi
  8019dd:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8019e0:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8019e5:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  8019eb:	eb 12                	jmp    8019ff <spawn+0x439>
  8019ed:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019f3:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8019f9:	0f 84 bb 00 00 00    	je     801aba <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  8019ff:	89 d8                	mov    %ebx,%eax
  801a01:	c1 e8 16             	shr    $0x16,%eax
  801a04:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a0b:	a8 01                	test   $0x1,%al
  801a0d:	74 de                	je     8019ed <spawn+0x427>
  801a0f:	89 d8                	mov    %ebx,%eax
  801a11:	c1 e8 0c             	shr    $0xc,%eax
  801a14:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a1b:	f6 c2 01             	test   $0x1,%dl
  801a1e:	74 cd                	je     8019ed <spawn+0x427>
  801a20:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a27:	f6 c6 04             	test   $0x4,%dh
  801a2a:	74 c1                	je     8019ed <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801a2c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	25 07 0e 00 00       	and    $0xe07,%eax
  801a3b:	50                   	push   %eax
  801a3c:	53                   	push   %ebx
  801a3d:	57                   	push   %edi
  801a3e:	53                   	push   %ebx
  801a3f:	56                   	push   %esi
  801a40:	e8 8a f1 ff ff       	call   800bcf <sys_page_map>
  801a45:	83 c4 20             	add    $0x20,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	79 a1                	jns    8019ed <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  801a4c:	50                   	push   %eax
  801a4d:	68 63 2d 80 00       	push   $0x802d63
  801a52:	68 82 00 00 00       	push   $0x82
  801a57:	68 09 2d 80 00       	push   $0x802d09
  801a5c:	e8 7a e6 ff ff       	call   8000db <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801a61:	50                   	push   %eax
  801a62:	68 32 2d 80 00       	push   $0x802d32
  801a67:	68 86 00 00 00       	push   $0x86
  801a6c:	68 09 2d 80 00       	push   $0x802d09
  801a71:	e8 65 e6 ff ff       	call   8000db <_panic>
		panic("sys_env_set_status: %e", r);
  801a76:	50                   	push   %eax
  801a77:	68 4c 2d 80 00       	push   $0x802d4c
  801a7c:	68 89 00 00 00       	push   $0x89
  801a81:	68 09 2d 80 00       	push   $0x802d09
  801a86:	e8 50 e6 ff ff       	call   8000db <_panic>
		return r;
  801a8b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a91:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801a97:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5f                   	pop    %edi
  801aa3:	5d                   	pop    %ebp
  801aa4:	c3                   	ret    
  801aa5:	89 c7                	mov    %eax,%edi
  801aa7:	e9 59 fe ff ff       	jmp    801905 <spawn+0x33f>
  801aac:	89 c7                	mov    %eax,%edi
  801aae:	e9 52 fe ff ff       	jmp    801905 <spawn+0x33f>
  801ab3:	89 c7                	mov    %eax,%edi
  801ab5:	e9 4b fe ff ff       	jmp    801905 <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801aba:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ac1:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ac4:	83 ec 08             	sub    $0x8,%esp
  801ac7:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801acd:	50                   	push   %eax
  801ace:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801ad4:	e8 bc f1 ff ff       	call   800c95 <sys_env_set_trapframe>
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	85 c0                	test   %eax,%eax
  801ade:	78 81                	js     801a61 <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	6a 02                	push   $0x2
  801ae5:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801aeb:	e8 63 f1 ff ff       	call   800c53 <sys_env_set_status>
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	0f 88 7b ff ff ff    	js     801a76 <spawn+0x4b0>
	return child;
  801afb:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b01:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801b07:	eb 8e                	jmp    801a97 <spawn+0x4d1>
		return -E_NO_MEM;
  801b09:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801b0e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801b14:	eb 81                	jmp    801a97 <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  801b16:	83 ec 08             	sub    $0x8,%esp
  801b19:	68 00 00 40 00       	push   $0x400000
  801b1e:	6a 00                	push   $0x0
  801b20:	e8 ec f0 ff ff       	call   800c11 <sys_page_unmap>
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801b2e:	e9 64 ff ff ff       	jmp    801a97 <spawn+0x4d1>

00801b33 <spawnl>:
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
	va_start(vl, arg0);
  801b38:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801b3b:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801b40:	eb 05                	jmp    801b47 <spawnl+0x14>
		argc++;
  801b42:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801b45:	89 ca                	mov    %ecx,%edx
  801b47:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b4a:	83 3a 00             	cmpl   $0x0,(%edx)
  801b4d:	75 f3                	jne    801b42 <spawnl+0xf>
	const char *argv[argc+2];
  801b4f:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801b56:	89 d3                	mov    %edx,%ebx
  801b58:	83 e3 f0             	and    $0xfffffff0,%ebx
  801b5b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801b61:	89 e1                	mov    %esp,%ecx
  801b63:	29 d1                	sub    %edx,%ecx
  801b65:	39 cc                	cmp    %ecx,%esp
  801b67:	74 10                	je     801b79 <spawnl+0x46>
  801b69:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801b6f:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801b76:	00 
  801b77:	eb ec                	jmp    801b65 <spawnl+0x32>
  801b79:	89 da                	mov    %ebx,%edx
  801b7b:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801b81:	29 d4                	sub    %edx,%esp
  801b83:	85 d2                	test   %edx,%edx
  801b85:	74 05                	je     801b8c <spawnl+0x59>
  801b87:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801b8c:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801b90:	89 da                	mov    %ebx,%edx
  801b92:	c1 ea 02             	shr    $0x2,%edx
  801b95:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801b98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ba2:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801ba9:	00 
	va_start(vl, arg0);
  801baa:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801bad:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801baf:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb4:	eb 0b                	jmp    801bc1 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801bb6:	83 c0 01             	add    $0x1,%eax
  801bb9:	8b 31                	mov    (%ecx),%esi
  801bbb:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801bbe:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801bc1:	39 d0                	cmp    %edx,%eax
  801bc3:	75 f1                	jne    801bb6 <spawnl+0x83>
	return spawn(prog, argv);
  801bc5:	83 ec 08             	sub    $0x8,%esp
  801bc8:	53                   	push   %ebx
  801bc9:	ff 75 08             	push   0x8(%ebp)
  801bcc:	e8 f5 f9 ff ff       	call   8015c6 <spawn>
}
  801bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801bde:	68 a2 2d 80 00       	push   $0x802da2
  801be3:	ff 75 0c             	push   0xc(%ebp)
  801be6:	e8 a5 eb ff ff       	call   800790 <strcpy>
	return 0;
}
  801beb:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <devsock_close>:
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	53                   	push   %ebx
  801bf6:	83 ec 10             	sub    $0x10,%esp
  801bf9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bfc:	53                   	push   %ebx
  801bfd:	e8 f0 09 00 00       	call   8025f2 <pageref>
  801c02:	89 c2                	mov    %eax,%edx
  801c04:	83 c4 10             	add    $0x10,%esp
		return 0;
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801c0c:	83 fa 01             	cmp    $0x1,%edx
  801c0f:	74 05                	je     801c16 <devsock_close+0x24>
}
  801c11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801c16:	83 ec 0c             	sub    $0xc,%esp
  801c19:	ff 73 0c             	push   0xc(%ebx)
  801c1c:	e8 b7 02 00 00       	call   801ed8 <nsipc_close>
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	eb eb                	jmp    801c11 <devsock_close+0x1f>

00801c26 <devsock_write>:
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c2c:	6a 00                	push   $0x0
  801c2e:	ff 75 10             	push   0x10(%ebp)
  801c31:	ff 75 0c             	push   0xc(%ebp)
  801c34:	8b 45 08             	mov    0x8(%ebp),%eax
  801c37:	ff 70 0c             	push   0xc(%eax)
  801c3a:	e8 79 03 00 00       	call   801fb8 <nsipc_send>
}
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <devsock_read>:
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c47:	6a 00                	push   $0x0
  801c49:	ff 75 10             	push   0x10(%ebp)
  801c4c:	ff 75 0c             	push   0xc(%ebp)
  801c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c52:	ff 70 0c             	push   0xc(%eax)
  801c55:	e8 ef 02 00 00       	call   801f49 <nsipc_recv>
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <fd2sockid>:
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c62:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c65:	52                   	push   %edx
  801c66:	50                   	push   %eax
  801c67:	e8 e9 f1 ff ff       	call   800e55 <fd_lookup>
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 10                	js     801c83 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c76:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c7c:	39 08                	cmp    %ecx,(%eax)
  801c7e:	75 05                	jne    801c85 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801c80:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801c83:	c9                   	leave  
  801c84:	c3                   	ret    
		return -E_NOT_SUPP;
  801c85:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c8a:	eb f7                	jmp    801c83 <fd2sockid+0x27>

00801c8c <alloc_sockfd>:
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	56                   	push   %esi
  801c90:	53                   	push   %ebx
  801c91:	83 ec 1c             	sub    $0x1c,%esp
  801c94:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801c96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c99:	50                   	push   %eax
  801c9a:	e8 66 f1 ff ff       	call   800e05 <fd_alloc>
  801c9f:	89 c3                	mov    %eax,%ebx
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	78 43                	js     801ceb <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ca8:	83 ec 04             	sub    $0x4,%esp
  801cab:	68 07 04 00 00       	push   $0x407
  801cb0:	ff 75 f4             	push   -0xc(%ebp)
  801cb3:	6a 00                	push   $0x0
  801cb5:	e8 d2 ee ff ff       	call   800b8c <sys_page_alloc>
  801cba:	89 c3                	mov    %eax,%ebx
  801cbc:	83 c4 10             	add    $0x10,%esp
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 28                	js     801ceb <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ccc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801cd8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801cdb:	83 ec 0c             	sub    $0xc,%esp
  801cde:	50                   	push   %eax
  801cdf:	e8 fa f0 ff ff       	call   800dde <fd2num>
  801ce4:	89 c3                	mov    %eax,%ebx
  801ce6:	83 c4 10             	add    $0x10,%esp
  801ce9:	eb 0c                	jmp    801cf7 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	56                   	push   %esi
  801cef:	e8 e4 01 00 00       	call   801ed8 <nsipc_close>
		return r;
  801cf4:	83 c4 10             	add    $0x10,%esp
}
  801cf7:	89 d8                	mov    %ebx,%eax
  801cf9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5d                   	pop    %ebp
  801cff:	c3                   	ret    

00801d00 <accept>:
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d06:	8b 45 08             	mov    0x8(%ebp),%eax
  801d09:	e8 4e ff ff ff       	call   801c5c <fd2sockid>
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 1b                	js     801d2d <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d12:	83 ec 04             	sub    $0x4,%esp
  801d15:	ff 75 10             	push   0x10(%ebp)
  801d18:	ff 75 0c             	push   0xc(%ebp)
  801d1b:	50                   	push   %eax
  801d1c:	e8 0e 01 00 00       	call   801e2f <nsipc_accept>
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	85 c0                	test   %eax,%eax
  801d26:	78 05                	js     801d2d <accept+0x2d>
	return alloc_sockfd(r);
  801d28:	e8 5f ff ff ff       	call   801c8c <alloc_sockfd>
}
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    

00801d2f <bind>:
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d35:	8b 45 08             	mov    0x8(%ebp),%eax
  801d38:	e8 1f ff ff ff       	call   801c5c <fd2sockid>
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	78 12                	js     801d53 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801d41:	83 ec 04             	sub    $0x4,%esp
  801d44:	ff 75 10             	push   0x10(%ebp)
  801d47:	ff 75 0c             	push   0xc(%ebp)
  801d4a:	50                   	push   %eax
  801d4b:	e8 31 01 00 00       	call   801e81 <nsipc_bind>
  801d50:	83 c4 10             	add    $0x10,%esp
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <shutdown>:
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	e8 f9 fe ff ff       	call   801c5c <fd2sockid>
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 0f                	js     801d76 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801d67:	83 ec 08             	sub    $0x8,%esp
  801d6a:	ff 75 0c             	push   0xc(%ebp)
  801d6d:	50                   	push   %eax
  801d6e:	e8 43 01 00 00       	call   801eb6 <nsipc_shutdown>
  801d73:	83 c4 10             	add    $0x10,%esp
}
  801d76:	c9                   	leave  
  801d77:	c3                   	ret    

00801d78 <connect>:
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d81:	e8 d6 fe ff ff       	call   801c5c <fd2sockid>
  801d86:	85 c0                	test   %eax,%eax
  801d88:	78 12                	js     801d9c <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801d8a:	83 ec 04             	sub    $0x4,%esp
  801d8d:	ff 75 10             	push   0x10(%ebp)
  801d90:	ff 75 0c             	push   0xc(%ebp)
  801d93:	50                   	push   %eax
  801d94:	e8 59 01 00 00       	call   801ef2 <nsipc_connect>
  801d99:	83 c4 10             	add    $0x10,%esp
}
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    

00801d9e <listen>:
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
  801da7:	e8 b0 fe ff ff       	call   801c5c <fd2sockid>
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 0f                	js     801dbf <listen+0x21>
	return nsipc_listen(r, backlog);
  801db0:	83 ec 08             	sub    $0x8,%esp
  801db3:	ff 75 0c             	push   0xc(%ebp)
  801db6:	50                   	push   %eax
  801db7:	e8 6b 01 00 00       	call   801f27 <nsipc_listen>
  801dbc:	83 c4 10             	add    $0x10,%esp
}
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <socket>:

int
socket(int domain, int type, int protocol)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801dc7:	ff 75 10             	push   0x10(%ebp)
  801dca:	ff 75 0c             	push   0xc(%ebp)
  801dcd:	ff 75 08             	push   0x8(%ebp)
  801dd0:	e8 41 02 00 00       	call   802016 <nsipc_socket>
  801dd5:	83 c4 10             	add    $0x10,%esp
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	78 05                	js     801de1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ddc:	e8 ab fe ff ff       	call   801c8c <alloc_sockfd>
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    

00801de3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	53                   	push   %ebx
  801de7:	83 ec 04             	sub    $0x4,%esp
  801dea:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801dec:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801df3:	74 26                	je     801e1b <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801df5:	6a 07                	push   $0x7
  801df7:	68 00 70 80 00       	push   $0x807000
  801dfc:	53                   	push   %ebx
  801dfd:	ff 35 00 80 80 00    	push   0x808000
  801e03:	e8 5d 07 00 00       	call   802565 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e08:	83 c4 0c             	add    $0xc,%esp
  801e0b:	6a 00                	push   $0x0
  801e0d:	6a 00                	push   $0x0
  801e0f:	6a 00                	push   $0x0
  801e11:	e8 e8 06 00 00       	call   8024fe <ipc_recv>
}
  801e16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e1b:	83 ec 0c             	sub    $0xc,%esp
  801e1e:	6a 02                	push   $0x2
  801e20:	e8 94 07 00 00       	call   8025b9 <ipc_find_env>
  801e25:	a3 00 80 80 00       	mov    %eax,0x808000
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	eb c6                	jmp    801df5 <nsipc+0x12>

00801e2f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e3f:	8b 06                	mov    (%esi),%eax
  801e41:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4b:	e8 93 ff ff ff       	call   801de3 <nsipc>
  801e50:	89 c3                	mov    %eax,%ebx
  801e52:	85 c0                	test   %eax,%eax
  801e54:	79 09                	jns    801e5f <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801e56:	89 d8                	mov    %ebx,%eax
  801e58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5b:	5b                   	pop    %ebx
  801e5c:	5e                   	pop    %esi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e5f:	83 ec 04             	sub    $0x4,%esp
  801e62:	ff 35 10 70 80 00    	push   0x807010
  801e68:	68 00 70 80 00       	push   $0x807000
  801e6d:	ff 75 0c             	push   0xc(%ebp)
  801e70:	e8 b1 ea ff ff       	call   800926 <memmove>
		*addrlen = ret->ret_addrlen;
  801e75:	a1 10 70 80 00       	mov    0x807010,%eax
  801e7a:	89 06                	mov    %eax,(%esi)
  801e7c:	83 c4 10             	add    $0x10,%esp
	return r;
  801e7f:	eb d5                	jmp    801e56 <nsipc_accept+0x27>

00801e81 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	53                   	push   %ebx
  801e85:	83 ec 08             	sub    $0x8,%esp
  801e88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e93:	53                   	push   %ebx
  801e94:	ff 75 0c             	push   0xc(%ebp)
  801e97:	68 04 70 80 00       	push   $0x807004
  801e9c:	e8 85 ea ff ff       	call   800926 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ea1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801ea7:	b8 02 00 00 00       	mov    $0x2,%eax
  801eac:	e8 32 ff ff ff       	call   801de3 <nsipc>
}
  801eb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb4:	c9                   	leave  
  801eb5:	c3                   	ret    

00801eb6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec7:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ecc:	b8 03 00 00 00       	mov    $0x3,%eax
  801ed1:	e8 0d ff ff ff       	call   801de3 <nsipc>
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <nsipc_close>:

int
nsipc_close(int s)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ede:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee1:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801ee6:	b8 04 00 00 00       	mov    $0x4,%eax
  801eeb:	e8 f3 fe ff ff       	call   801de3 <nsipc>
}
  801ef0:	c9                   	leave  
  801ef1:	c3                   	ret    

00801ef2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	53                   	push   %ebx
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801efc:	8b 45 08             	mov    0x8(%ebp),%eax
  801eff:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f04:	53                   	push   %ebx
  801f05:	ff 75 0c             	push   0xc(%ebp)
  801f08:	68 04 70 80 00       	push   $0x807004
  801f0d:	e8 14 ea ff ff       	call   800926 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f12:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801f18:	b8 05 00 00 00       	mov    $0x5,%eax
  801f1d:	e8 c1 fe ff ff       	call   801de3 <nsipc>
}
  801f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f30:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801f35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f38:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801f3d:	b8 06 00 00 00       	mov    $0x6,%eax
  801f42:	e8 9c fe ff ff       	call   801de3 <nsipc>
}
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	56                   	push   %esi
  801f4d:	53                   	push   %ebx
  801f4e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f51:	8b 45 08             	mov    0x8(%ebp),%eax
  801f54:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801f59:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801f5f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f62:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f67:	b8 07 00 00 00       	mov    $0x7,%eax
  801f6c:	e8 72 fe ff ff       	call   801de3 <nsipc>
  801f71:	89 c3                	mov    %eax,%ebx
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 22                	js     801f99 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801f77:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801f7c:	39 c6                	cmp    %eax,%esi
  801f7e:	0f 4e c6             	cmovle %esi,%eax
  801f81:	39 c3                	cmp    %eax,%ebx
  801f83:	7f 1d                	jg     801fa2 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f85:	83 ec 04             	sub    $0x4,%esp
  801f88:	53                   	push   %ebx
  801f89:	68 00 70 80 00       	push   $0x807000
  801f8e:	ff 75 0c             	push   0xc(%ebp)
  801f91:	e8 90 e9 ff ff       	call   800926 <memmove>
  801f96:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f99:	89 d8                	mov    %ebx,%eax
  801f9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f9e:	5b                   	pop    %ebx
  801f9f:	5e                   	pop    %esi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801fa2:	68 ae 2d 80 00       	push   $0x802dae
  801fa7:	68 c3 2c 80 00       	push   $0x802cc3
  801fac:	6a 62                	push   $0x62
  801fae:	68 c3 2d 80 00       	push   $0x802dc3
  801fb3:	e8 23 e1 ff ff       	call   8000db <_panic>

00801fb8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	53                   	push   %ebx
  801fbc:	83 ec 04             	sub    $0x4,%esp
  801fbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc5:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801fca:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fd0:	7f 2e                	jg     802000 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fd2:	83 ec 04             	sub    $0x4,%esp
  801fd5:	53                   	push   %ebx
  801fd6:	ff 75 0c             	push   0xc(%ebp)
  801fd9:	68 0c 70 80 00       	push   $0x80700c
  801fde:	e8 43 e9 ff ff       	call   800926 <memmove>
	nsipcbuf.send.req_size = size;
  801fe3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801fe9:	8b 45 14             	mov    0x14(%ebp),%eax
  801fec:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801ff1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ff6:	e8 e8 fd ff ff       	call   801de3 <nsipc>
}
  801ffb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ffe:	c9                   	leave  
  801fff:	c3                   	ret    
	assert(size < 1600);
  802000:	68 cf 2d 80 00       	push   $0x802dcf
  802005:	68 c3 2c 80 00       	push   $0x802cc3
  80200a:	6a 6d                	push   $0x6d
  80200c:	68 c3 2d 80 00       	push   $0x802dc3
  802011:	e8 c5 e0 ff ff       	call   8000db <_panic>

00802016 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80201c:	8b 45 08             	mov    0x8(%ebp),%eax
  80201f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802024:	8b 45 0c             	mov    0xc(%ebp),%eax
  802027:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80202c:	8b 45 10             	mov    0x10(%ebp),%eax
  80202f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802034:	b8 09 00 00 00       	mov    $0x9,%eax
  802039:	e8 a5 fd ff ff       	call   801de3 <nsipc>
}
  80203e:	c9                   	leave  
  80203f:	c3                   	ret    

00802040 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	56                   	push   %esi
  802044:	53                   	push   %ebx
  802045:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802048:	83 ec 0c             	sub    $0xc,%esp
  80204b:	ff 75 08             	push   0x8(%ebp)
  80204e:	e8 9b ed ff ff       	call   800dee <fd2data>
  802053:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802055:	83 c4 08             	add    $0x8,%esp
  802058:	68 db 2d 80 00       	push   $0x802ddb
  80205d:	53                   	push   %ebx
  80205e:	e8 2d e7 ff ff       	call   800790 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802063:	8b 46 04             	mov    0x4(%esi),%eax
  802066:	2b 06                	sub    (%esi),%eax
  802068:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80206e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802075:	00 00 00 
	stat->st_dev = &devpipe;
  802078:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80207f:	30 80 00 
	return 0;
}
  802082:	b8 00 00 00 00       	mov    $0x0,%eax
  802087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208a:	5b                   	pop    %ebx
  80208b:	5e                   	pop    %esi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    

0080208e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	53                   	push   %ebx
  802092:	83 ec 0c             	sub    $0xc,%esp
  802095:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802098:	53                   	push   %ebx
  802099:	6a 00                	push   $0x0
  80209b:	e8 71 eb ff ff       	call   800c11 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020a0:	89 1c 24             	mov    %ebx,(%esp)
  8020a3:	e8 46 ed ff ff       	call   800dee <fd2data>
  8020a8:	83 c4 08             	add    $0x8,%esp
  8020ab:	50                   	push   %eax
  8020ac:	6a 00                	push   $0x0
  8020ae:	e8 5e eb ff ff       	call   800c11 <sys_page_unmap>
}
  8020b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b6:	c9                   	leave  
  8020b7:	c3                   	ret    

008020b8 <_pipeisclosed>:
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	57                   	push   %edi
  8020bc:	56                   	push   %esi
  8020bd:	53                   	push   %ebx
  8020be:	83 ec 1c             	sub    $0x1c,%esp
  8020c1:	89 c7                	mov    %eax,%edi
  8020c3:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8020c5:	a1 00 40 80 00       	mov    0x804000,%eax
  8020ca:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020cd:	83 ec 0c             	sub    $0xc,%esp
  8020d0:	57                   	push   %edi
  8020d1:	e8 1c 05 00 00       	call   8025f2 <pageref>
  8020d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8020d9:	89 34 24             	mov    %esi,(%esp)
  8020dc:	e8 11 05 00 00       	call   8025f2 <pageref>
		nn = thisenv->env_runs;
  8020e1:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8020e7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020ea:	83 c4 10             	add    $0x10,%esp
  8020ed:	39 cb                	cmp    %ecx,%ebx
  8020ef:	74 1b                	je     80210c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8020f1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020f4:	75 cf                	jne    8020c5 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020f6:	8b 42 58             	mov    0x58(%edx),%eax
  8020f9:	6a 01                	push   $0x1
  8020fb:	50                   	push   %eax
  8020fc:	53                   	push   %ebx
  8020fd:	68 e2 2d 80 00       	push   $0x802de2
  802102:	e8 af e0 ff ff       	call   8001b6 <cprintf>
  802107:	83 c4 10             	add    $0x10,%esp
  80210a:	eb b9                	jmp    8020c5 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80210c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80210f:	0f 94 c0             	sete   %al
  802112:	0f b6 c0             	movzbl %al,%eax
}
  802115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802118:	5b                   	pop    %ebx
  802119:	5e                   	pop    %esi
  80211a:	5f                   	pop    %edi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    

0080211d <devpipe_write>:
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	57                   	push   %edi
  802121:	56                   	push   %esi
  802122:	53                   	push   %ebx
  802123:	83 ec 28             	sub    $0x28,%esp
  802126:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802129:	56                   	push   %esi
  80212a:	e8 bf ec ff ff       	call   800dee <fd2data>
  80212f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	bf 00 00 00 00       	mov    $0x0,%edi
  802139:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80213c:	75 09                	jne    802147 <devpipe_write+0x2a>
	return i;
  80213e:	89 f8                	mov    %edi,%eax
  802140:	eb 23                	jmp    802165 <devpipe_write+0x48>
			sys_yield();
  802142:	e8 26 ea ff ff       	call   800b6d <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802147:	8b 43 04             	mov    0x4(%ebx),%eax
  80214a:	8b 0b                	mov    (%ebx),%ecx
  80214c:	8d 51 20             	lea    0x20(%ecx),%edx
  80214f:	39 d0                	cmp    %edx,%eax
  802151:	72 1a                	jb     80216d <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802153:	89 da                	mov    %ebx,%edx
  802155:	89 f0                	mov    %esi,%eax
  802157:	e8 5c ff ff ff       	call   8020b8 <_pipeisclosed>
  80215c:	85 c0                	test   %eax,%eax
  80215e:	74 e2                	je     802142 <devpipe_write+0x25>
				return 0;
  802160:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802165:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5f                   	pop    %edi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80216d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802170:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802174:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802177:	89 c2                	mov    %eax,%edx
  802179:	c1 fa 1f             	sar    $0x1f,%edx
  80217c:	89 d1                	mov    %edx,%ecx
  80217e:	c1 e9 1b             	shr    $0x1b,%ecx
  802181:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802184:	83 e2 1f             	and    $0x1f,%edx
  802187:	29 ca                	sub    %ecx,%edx
  802189:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80218d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802191:	83 c0 01             	add    $0x1,%eax
  802194:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802197:	83 c7 01             	add    $0x1,%edi
  80219a:	eb 9d                	jmp    802139 <devpipe_write+0x1c>

0080219c <devpipe_read>:
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	57                   	push   %edi
  8021a0:	56                   	push   %esi
  8021a1:	53                   	push   %ebx
  8021a2:	83 ec 18             	sub    $0x18,%esp
  8021a5:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8021a8:	57                   	push   %edi
  8021a9:	e8 40 ec ff ff       	call   800dee <fd2data>
  8021ae:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021b0:	83 c4 10             	add    $0x10,%esp
  8021b3:	be 00 00 00 00       	mov    $0x0,%esi
  8021b8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021bb:	75 13                	jne    8021d0 <devpipe_read+0x34>
	return i;
  8021bd:	89 f0                	mov    %esi,%eax
  8021bf:	eb 02                	jmp    8021c3 <devpipe_read+0x27>
				return i;
  8021c1:	89 f0                	mov    %esi,%eax
}
  8021c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c6:	5b                   	pop    %ebx
  8021c7:	5e                   	pop    %esi
  8021c8:	5f                   	pop    %edi
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    
			sys_yield();
  8021cb:	e8 9d e9 ff ff       	call   800b6d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8021d0:	8b 03                	mov    (%ebx),%eax
  8021d2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021d5:	75 18                	jne    8021ef <devpipe_read+0x53>
			if (i > 0)
  8021d7:	85 f6                	test   %esi,%esi
  8021d9:	75 e6                	jne    8021c1 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8021db:	89 da                	mov    %ebx,%edx
  8021dd:	89 f8                	mov    %edi,%eax
  8021df:	e8 d4 fe ff ff       	call   8020b8 <_pipeisclosed>
  8021e4:	85 c0                	test   %eax,%eax
  8021e6:	74 e3                	je     8021cb <devpipe_read+0x2f>
				return 0;
  8021e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ed:	eb d4                	jmp    8021c3 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021ef:	99                   	cltd   
  8021f0:	c1 ea 1b             	shr    $0x1b,%edx
  8021f3:	01 d0                	add    %edx,%eax
  8021f5:	83 e0 1f             	and    $0x1f,%eax
  8021f8:	29 d0                	sub    %edx,%eax
  8021fa:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8021ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802202:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802205:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802208:	83 c6 01             	add    $0x1,%esi
  80220b:	eb ab                	jmp    8021b8 <devpipe_read+0x1c>

0080220d <pipe>:
{
  80220d:	55                   	push   %ebp
  80220e:	89 e5                	mov    %esp,%ebp
  802210:	56                   	push   %esi
  802211:	53                   	push   %ebx
  802212:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802218:	50                   	push   %eax
  802219:	e8 e7 eb ff ff       	call   800e05 <fd_alloc>
  80221e:	89 c3                	mov    %eax,%ebx
  802220:	83 c4 10             	add    $0x10,%esp
  802223:	85 c0                	test   %eax,%eax
  802225:	0f 88 23 01 00 00    	js     80234e <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222b:	83 ec 04             	sub    $0x4,%esp
  80222e:	68 07 04 00 00       	push   $0x407
  802233:	ff 75 f4             	push   -0xc(%ebp)
  802236:	6a 00                	push   $0x0
  802238:	e8 4f e9 ff ff       	call   800b8c <sys_page_alloc>
  80223d:	89 c3                	mov    %eax,%ebx
  80223f:	83 c4 10             	add    $0x10,%esp
  802242:	85 c0                	test   %eax,%eax
  802244:	0f 88 04 01 00 00    	js     80234e <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80224a:	83 ec 0c             	sub    $0xc,%esp
  80224d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802250:	50                   	push   %eax
  802251:	e8 af eb ff ff       	call   800e05 <fd_alloc>
  802256:	89 c3                	mov    %eax,%ebx
  802258:	83 c4 10             	add    $0x10,%esp
  80225b:	85 c0                	test   %eax,%eax
  80225d:	0f 88 db 00 00 00    	js     80233e <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802263:	83 ec 04             	sub    $0x4,%esp
  802266:	68 07 04 00 00       	push   $0x407
  80226b:	ff 75 f0             	push   -0x10(%ebp)
  80226e:	6a 00                	push   $0x0
  802270:	e8 17 e9 ff ff       	call   800b8c <sys_page_alloc>
  802275:	89 c3                	mov    %eax,%ebx
  802277:	83 c4 10             	add    $0x10,%esp
  80227a:	85 c0                	test   %eax,%eax
  80227c:	0f 88 bc 00 00 00    	js     80233e <pipe+0x131>
	va = fd2data(fd0);
  802282:	83 ec 0c             	sub    $0xc,%esp
  802285:	ff 75 f4             	push   -0xc(%ebp)
  802288:	e8 61 eb ff ff       	call   800dee <fd2data>
  80228d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80228f:	83 c4 0c             	add    $0xc,%esp
  802292:	68 07 04 00 00       	push   $0x407
  802297:	50                   	push   %eax
  802298:	6a 00                	push   $0x0
  80229a:	e8 ed e8 ff ff       	call   800b8c <sys_page_alloc>
  80229f:	89 c3                	mov    %eax,%ebx
  8022a1:	83 c4 10             	add    $0x10,%esp
  8022a4:	85 c0                	test   %eax,%eax
  8022a6:	0f 88 82 00 00 00    	js     80232e <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ac:	83 ec 0c             	sub    $0xc,%esp
  8022af:	ff 75 f0             	push   -0x10(%ebp)
  8022b2:	e8 37 eb ff ff       	call   800dee <fd2data>
  8022b7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022be:	50                   	push   %eax
  8022bf:	6a 00                	push   $0x0
  8022c1:	56                   	push   %esi
  8022c2:	6a 00                	push   $0x0
  8022c4:	e8 06 e9 ff ff       	call   800bcf <sys_page_map>
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	83 c4 20             	add    $0x20,%esp
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	78 4e                	js     802320 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8022d2:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8022d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022da:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8022dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022df:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8022e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022e9:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8022eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022ee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8022f5:	83 ec 0c             	sub    $0xc,%esp
  8022f8:	ff 75 f4             	push   -0xc(%ebp)
  8022fb:	e8 de ea ff ff       	call   800dde <fd2num>
  802300:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802303:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802305:	83 c4 04             	add    $0x4,%esp
  802308:	ff 75 f0             	push   -0x10(%ebp)
  80230b:	e8 ce ea ff ff       	call   800dde <fd2num>
  802310:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802313:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802316:	83 c4 10             	add    $0x10,%esp
  802319:	bb 00 00 00 00       	mov    $0x0,%ebx
  80231e:	eb 2e                	jmp    80234e <pipe+0x141>
	sys_page_unmap(0, va);
  802320:	83 ec 08             	sub    $0x8,%esp
  802323:	56                   	push   %esi
  802324:	6a 00                	push   $0x0
  802326:	e8 e6 e8 ff ff       	call   800c11 <sys_page_unmap>
  80232b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80232e:	83 ec 08             	sub    $0x8,%esp
  802331:	ff 75 f0             	push   -0x10(%ebp)
  802334:	6a 00                	push   $0x0
  802336:	e8 d6 e8 ff ff       	call   800c11 <sys_page_unmap>
  80233b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80233e:	83 ec 08             	sub    $0x8,%esp
  802341:	ff 75 f4             	push   -0xc(%ebp)
  802344:	6a 00                	push   $0x0
  802346:	e8 c6 e8 ff ff       	call   800c11 <sys_page_unmap>
  80234b:	83 c4 10             	add    $0x10,%esp
}
  80234e:	89 d8                	mov    %ebx,%eax
  802350:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5d                   	pop    %ebp
  802356:	c3                   	ret    

00802357 <pipeisclosed>:
{
  802357:	55                   	push   %ebp
  802358:	89 e5                	mov    %esp,%ebp
  80235a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80235d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802360:	50                   	push   %eax
  802361:	ff 75 08             	push   0x8(%ebp)
  802364:	e8 ec ea ff ff       	call   800e55 <fd_lookup>
  802369:	83 c4 10             	add    $0x10,%esp
  80236c:	85 c0                	test   %eax,%eax
  80236e:	78 18                	js     802388 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802370:	83 ec 0c             	sub    $0xc,%esp
  802373:	ff 75 f4             	push   -0xc(%ebp)
  802376:	e8 73 ea ff ff       	call   800dee <fd2data>
  80237b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80237d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802380:	e8 33 fd ff ff       	call   8020b8 <_pipeisclosed>
  802385:	83 c4 10             	add    $0x10,%esp
}
  802388:	c9                   	leave  
  802389:	c3                   	ret    

0080238a <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80238a:	b8 00 00 00 00       	mov    $0x0,%eax
  80238f:	c3                   	ret    

00802390 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802396:	68 fa 2d 80 00       	push   $0x802dfa
  80239b:	ff 75 0c             	push   0xc(%ebp)
  80239e:	e8 ed e3 ff ff       	call   800790 <strcpy>
	return 0;
}
  8023a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a8:	c9                   	leave  
  8023a9:	c3                   	ret    

008023aa <devcons_write>:
{
  8023aa:	55                   	push   %ebp
  8023ab:	89 e5                	mov    %esp,%ebp
  8023ad:	57                   	push   %edi
  8023ae:	56                   	push   %esi
  8023af:	53                   	push   %ebx
  8023b0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8023b6:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8023bb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8023c1:	eb 2e                	jmp    8023f1 <devcons_write+0x47>
		m = n - tot;
  8023c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023c6:	29 f3                	sub    %esi,%ebx
  8023c8:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8023cd:	39 c3                	cmp    %eax,%ebx
  8023cf:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8023d2:	83 ec 04             	sub    $0x4,%esp
  8023d5:	53                   	push   %ebx
  8023d6:	89 f0                	mov    %esi,%eax
  8023d8:	03 45 0c             	add    0xc(%ebp),%eax
  8023db:	50                   	push   %eax
  8023dc:	57                   	push   %edi
  8023dd:	e8 44 e5 ff ff       	call   800926 <memmove>
		sys_cputs(buf, m);
  8023e2:	83 c4 08             	add    $0x8,%esp
  8023e5:	53                   	push   %ebx
  8023e6:	57                   	push   %edi
  8023e7:	e8 e4 e6 ff ff       	call   800ad0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8023ec:	01 de                	add    %ebx,%esi
  8023ee:	83 c4 10             	add    $0x10,%esp
  8023f1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023f4:	72 cd                	jb     8023c3 <devcons_write+0x19>
}
  8023f6:	89 f0                	mov    %esi,%eax
  8023f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023fb:	5b                   	pop    %ebx
  8023fc:	5e                   	pop    %esi
  8023fd:	5f                   	pop    %edi
  8023fe:	5d                   	pop    %ebp
  8023ff:	c3                   	ret    

00802400 <devcons_read>:
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	83 ec 08             	sub    $0x8,%esp
  802406:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80240b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80240f:	75 07                	jne    802418 <devcons_read+0x18>
  802411:	eb 1f                	jmp    802432 <devcons_read+0x32>
		sys_yield();
  802413:	e8 55 e7 ff ff       	call   800b6d <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802418:	e8 d1 e6 ff ff       	call   800aee <sys_cgetc>
  80241d:	85 c0                	test   %eax,%eax
  80241f:	74 f2                	je     802413 <devcons_read+0x13>
	if (c < 0)
  802421:	78 0f                	js     802432 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802423:	83 f8 04             	cmp    $0x4,%eax
  802426:	74 0c                	je     802434 <devcons_read+0x34>
	*(char*)vbuf = c;
  802428:	8b 55 0c             	mov    0xc(%ebp),%edx
  80242b:	88 02                	mov    %al,(%edx)
	return 1;
  80242d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802432:	c9                   	leave  
  802433:	c3                   	ret    
		return 0;
  802434:	b8 00 00 00 00       	mov    $0x0,%eax
  802439:	eb f7                	jmp    802432 <devcons_read+0x32>

0080243b <cputchar>:
{
  80243b:	55                   	push   %ebp
  80243c:	89 e5                	mov    %esp,%ebp
  80243e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802441:	8b 45 08             	mov    0x8(%ebp),%eax
  802444:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802447:	6a 01                	push   $0x1
  802449:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80244c:	50                   	push   %eax
  80244d:	e8 7e e6 ff ff       	call   800ad0 <sys_cputs>
}
  802452:	83 c4 10             	add    $0x10,%esp
  802455:	c9                   	leave  
  802456:	c3                   	ret    

00802457 <getchar>:
{
  802457:	55                   	push   %ebp
  802458:	89 e5                	mov    %esp,%ebp
  80245a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80245d:	6a 01                	push   $0x1
  80245f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802462:	50                   	push   %eax
  802463:	6a 00                	push   $0x0
  802465:	e8 54 ec ff ff       	call   8010be <read>
	if (r < 0)
  80246a:	83 c4 10             	add    $0x10,%esp
  80246d:	85 c0                	test   %eax,%eax
  80246f:	78 06                	js     802477 <getchar+0x20>
	if (r < 1)
  802471:	74 06                	je     802479 <getchar+0x22>
	return c;
  802473:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802477:	c9                   	leave  
  802478:	c3                   	ret    
		return -E_EOF;
  802479:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80247e:	eb f7                	jmp    802477 <getchar+0x20>

00802480 <iscons>:
{
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802486:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802489:	50                   	push   %eax
  80248a:	ff 75 08             	push   0x8(%ebp)
  80248d:	e8 c3 e9 ff ff       	call   800e55 <fd_lookup>
  802492:	83 c4 10             	add    $0x10,%esp
  802495:	85 c0                	test   %eax,%eax
  802497:	78 11                	js     8024aa <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802499:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80249c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024a2:	39 10                	cmp    %edx,(%eax)
  8024a4:	0f 94 c0             	sete   %al
  8024a7:	0f b6 c0             	movzbl %al,%eax
}
  8024aa:	c9                   	leave  
  8024ab:	c3                   	ret    

008024ac <opencons>:
{
  8024ac:	55                   	push   %ebp
  8024ad:	89 e5                	mov    %esp,%ebp
  8024af:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8024b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024b5:	50                   	push   %eax
  8024b6:	e8 4a e9 ff ff       	call   800e05 <fd_alloc>
  8024bb:	83 c4 10             	add    $0x10,%esp
  8024be:	85 c0                	test   %eax,%eax
  8024c0:	78 3a                	js     8024fc <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024c2:	83 ec 04             	sub    $0x4,%esp
  8024c5:	68 07 04 00 00       	push   $0x407
  8024ca:	ff 75 f4             	push   -0xc(%ebp)
  8024cd:	6a 00                	push   $0x0
  8024cf:	e8 b8 e6 ff ff       	call   800b8c <sys_page_alloc>
  8024d4:	83 c4 10             	add    $0x10,%esp
  8024d7:	85 c0                	test   %eax,%eax
  8024d9:	78 21                	js     8024fc <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8024db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024de:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024e4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024f0:	83 ec 0c             	sub    $0xc,%esp
  8024f3:	50                   	push   %eax
  8024f4:	e8 e5 e8 ff ff       	call   800dde <fd2num>
  8024f9:	83 c4 10             	add    $0x10,%esp
}
  8024fc:	c9                   	leave  
  8024fd:	c3                   	ret    

008024fe <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024fe:	55                   	push   %ebp
  8024ff:	89 e5                	mov    %esp,%ebp
  802501:	56                   	push   %esi
  802502:	53                   	push   %ebx
  802503:	8b 75 08             	mov    0x8(%ebp),%esi
  802506:	8b 45 0c             	mov    0xc(%ebp),%eax
  802509:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80250c:	85 c0                	test   %eax,%eax
  80250e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802513:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802516:	83 ec 0c             	sub    $0xc,%esp
  802519:	50                   	push   %eax
  80251a:	e8 1d e8 ff ff       	call   800d3c <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80251f:	83 c4 10             	add    $0x10,%esp
  802522:	85 f6                	test   %esi,%esi
  802524:	74 14                	je     80253a <ipc_recv+0x3c>
  802526:	ba 00 00 00 00       	mov    $0x0,%edx
  80252b:	85 c0                	test   %eax,%eax
  80252d:	78 09                	js     802538 <ipc_recv+0x3a>
  80252f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802535:	8b 52 74             	mov    0x74(%edx),%edx
  802538:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80253a:	85 db                	test   %ebx,%ebx
  80253c:	74 14                	je     802552 <ipc_recv+0x54>
  80253e:	ba 00 00 00 00       	mov    $0x0,%edx
  802543:	85 c0                	test   %eax,%eax
  802545:	78 09                	js     802550 <ipc_recv+0x52>
  802547:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80254d:	8b 52 78             	mov    0x78(%edx),%edx
  802550:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802552:	85 c0                	test   %eax,%eax
  802554:	78 08                	js     80255e <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802556:	a1 00 40 80 00       	mov    0x804000,%eax
  80255b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80255e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802561:	5b                   	pop    %ebx
  802562:	5e                   	pop    %esi
  802563:	5d                   	pop    %ebp
  802564:	c3                   	ret    

00802565 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802565:	55                   	push   %ebp
  802566:	89 e5                	mov    %esp,%ebp
  802568:	57                   	push   %edi
  802569:	56                   	push   %esi
  80256a:	53                   	push   %ebx
  80256b:	83 ec 0c             	sub    $0xc,%esp
  80256e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802571:	8b 75 0c             	mov    0xc(%ebp),%esi
  802574:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802577:	85 db                	test   %ebx,%ebx
  802579:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80257e:	0f 44 d8             	cmove  %eax,%ebx
  802581:	eb 05                	jmp    802588 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802583:	e8 e5 e5 ff ff       	call   800b6d <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802588:	ff 75 14             	push   0x14(%ebp)
  80258b:	53                   	push   %ebx
  80258c:	56                   	push   %esi
  80258d:	57                   	push   %edi
  80258e:	e8 86 e7 ff ff       	call   800d19 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802593:	83 c4 10             	add    $0x10,%esp
  802596:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802599:	74 e8                	je     802583 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80259b:	85 c0                	test   %eax,%eax
  80259d:	78 08                	js     8025a7 <ipc_send+0x42>
	}while (r<0);

}
  80259f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025a2:	5b                   	pop    %ebx
  8025a3:	5e                   	pop    %esi
  8025a4:	5f                   	pop    %edi
  8025a5:	5d                   	pop    %ebp
  8025a6:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8025a7:	50                   	push   %eax
  8025a8:	68 06 2e 80 00       	push   $0x802e06
  8025ad:	6a 3d                	push   $0x3d
  8025af:	68 1a 2e 80 00       	push   $0x802e1a
  8025b4:	e8 22 db ff ff       	call   8000db <_panic>

008025b9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025b9:	55                   	push   %ebp
  8025ba:	89 e5                	mov    %esp,%ebp
  8025bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025bf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025c4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025c7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025cd:	8b 52 50             	mov    0x50(%edx),%edx
  8025d0:	39 ca                	cmp    %ecx,%edx
  8025d2:	74 11                	je     8025e5 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8025d4:	83 c0 01             	add    $0x1,%eax
  8025d7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025dc:	75 e6                	jne    8025c4 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8025de:	b8 00 00 00 00       	mov    $0x0,%eax
  8025e3:	eb 0b                	jmp    8025f0 <ipc_find_env+0x37>
			return envs[i].env_id;
  8025e5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025ed:	8b 40 48             	mov    0x48(%eax),%eax
}
  8025f0:	5d                   	pop    %ebp
  8025f1:	c3                   	ret    

008025f2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025f2:	55                   	push   %ebp
  8025f3:	89 e5                	mov    %esp,%ebp
  8025f5:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025f8:	89 c2                	mov    %eax,%edx
  8025fa:	c1 ea 16             	shr    $0x16,%edx
  8025fd:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802604:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802609:	f6 c1 01             	test   $0x1,%cl
  80260c:	74 1c                	je     80262a <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80260e:	c1 e8 0c             	shr    $0xc,%eax
  802611:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802618:	a8 01                	test   $0x1,%al
  80261a:	74 0e                	je     80262a <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80261c:	c1 e8 0c             	shr    $0xc,%eax
  80261f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802626:	ef 
  802627:	0f b7 d2             	movzwl %dx,%edx
}
  80262a:	89 d0                	mov    %edx,%eax
  80262c:	5d                   	pop    %ebp
  80262d:	c3                   	ret    
  80262e:	66 90                	xchg   %ax,%ax

00802630 <__udivdi3>:
  802630:	f3 0f 1e fb          	endbr32 
  802634:	55                   	push   %ebp
  802635:	57                   	push   %edi
  802636:	56                   	push   %esi
  802637:	53                   	push   %ebx
  802638:	83 ec 1c             	sub    $0x1c,%esp
  80263b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80263f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802643:	8b 74 24 34          	mov    0x34(%esp),%esi
  802647:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80264b:	85 c0                	test   %eax,%eax
  80264d:	75 19                	jne    802668 <__udivdi3+0x38>
  80264f:	39 f3                	cmp    %esi,%ebx
  802651:	76 4d                	jbe    8026a0 <__udivdi3+0x70>
  802653:	31 ff                	xor    %edi,%edi
  802655:	89 e8                	mov    %ebp,%eax
  802657:	89 f2                	mov    %esi,%edx
  802659:	f7 f3                	div    %ebx
  80265b:	89 fa                	mov    %edi,%edx
  80265d:	83 c4 1c             	add    $0x1c,%esp
  802660:	5b                   	pop    %ebx
  802661:	5e                   	pop    %esi
  802662:	5f                   	pop    %edi
  802663:	5d                   	pop    %ebp
  802664:	c3                   	ret    
  802665:	8d 76 00             	lea    0x0(%esi),%esi
  802668:	39 f0                	cmp    %esi,%eax
  80266a:	76 14                	jbe    802680 <__udivdi3+0x50>
  80266c:	31 ff                	xor    %edi,%edi
  80266e:	31 c0                	xor    %eax,%eax
  802670:	89 fa                	mov    %edi,%edx
  802672:	83 c4 1c             	add    $0x1c,%esp
  802675:	5b                   	pop    %ebx
  802676:	5e                   	pop    %esi
  802677:	5f                   	pop    %edi
  802678:	5d                   	pop    %ebp
  802679:	c3                   	ret    
  80267a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802680:	0f bd f8             	bsr    %eax,%edi
  802683:	83 f7 1f             	xor    $0x1f,%edi
  802686:	75 48                	jne    8026d0 <__udivdi3+0xa0>
  802688:	39 f0                	cmp    %esi,%eax
  80268a:	72 06                	jb     802692 <__udivdi3+0x62>
  80268c:	31 c0                	xor    %eax,%eax
  80268e:	39 eb                	cmp    %ebp,%ebx
  802690:	77 de                	ja     802670 <__udivdi3+0x40>
  802692:	b8 01 00 00 00       	mov    $0x1,%eax
  802697:	eb d7                	jmp    802670 <__udivdi3+0x40>
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 d9                	mov    %ebx,%ecx
  8026a2:	85 db                	test   %ebx,%ebx
  8026a4:	75 0b                	jne    8026b1 <__udivdi3+0x81>
  8026a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ab:	31 d2                	xor    %edx,%edx
  8026ad:	f7 f3                	div    %ebx
  8026af:	89 c1                	mov    %eax,%ecx
  8026b1:	31 d2                	xor    %edx,%edx
  8026b3:	89 f0                	mov    %esi,%eax
  8026b5:	f7 f1                	div    %ecx
  8026b7:	89 c6                	mov    %eax,%esi
  8026b9:	89 e8                	mov    %ebp,%eax
  8026bb:	89 f7                	mov    %esi,%edi
  8026bd:	f7 f1                	div    %ecx
  8026bf:	89 fa                	mov    %edi,%edx
  8026c1:	83 c4 1c             	add    $0x1c,%esp
  8026c4:	5b                   	pop    %ebx
  8026c5:	5e                   	pop    %esi
  8026c6:	5f                   	pop    %edi
  8026c7:	5d                   	pop    %ebp
  8026c8:	c3                   	ret    
  8026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	89 f9                	mov    %edi,%ecx
  8026d2:	ba 20 00 00 00       	mov    $0x20,%edx
  8026d7:	29 fa                	sub    %edi,%edx
  8026d9:	d3 e0                	shl    %cl,%eax
  8026db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026df:	89 d1                	mov    %edx,%ecx
  8026e1:	89 d8                	mov    %ebx,%eax
  8026e3:	d3 e8                	shr    %cl,%eax
  8026e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026e9:	09 c1                	or     %eax,%ecx
  8026eb:	89 f0                	mov    %esi,%eax
  8026ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026f1:	89 f9                	mov    %edi,%ecx
  8026f3:	d3 e3                	shl    %cl,%ebx
  8026f5:	89 d1                	mov    %edx,%ecx
  8026f7:	d3 e8                	shr    %cl,%eax
  8026f9:	89 f9                	mov    %edi,%ecx
  8026fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8026ff:	89 eb                	mov    %ebp,%ebx
  802701:	d3 e6                	shl    %cl,%esi
  802703:	89 d1                	mov    %edx,%ecx
  802705:	d3 eb                	shr    %cl,%ebx
  802707:	09 f3                	or     %esi,%ebx
  802709:	89 c6                	mov    %eax,%esi
  80270b:	89 f2                	mov    %esi,%edx
  80270d:	89 d8                	mov    %ebx,%eax
  80270f:	f7 74 24 08          	divl   0x8(%esp)
  802713:	89 d6                	mov    %edx,%esi
  802715:	89 c3                	mov    %eax,%ebx
  802717:	f7 64 24 0c          	mull   0xc(%esp)
  80271b:	39 d6                	cmp    %edx,%esi
  80271d:	72 19                	jb     802738 <__udivdi3+0x108>
  80271f:	89 f9                	mov    %edi,%ecx
  802721:	d3 e5                	shl    %cl,%ebp
  802723:	39 c5                	cmp    %eax,%ebp
  802725:	73 04                	jae    80272b <__udivdi3+0xfb>
  802727:	39 d6                	cmp    %edx,%esi
  802729:	74 0d                	je     802738 <__udivdi3+0x108>
  80272b:	89 d8                	mov    %ebx,%eax
  80272d:	31 ff                	xor    %edi,%edi
  80272f:	e9 3c ff ff ff       	jmp    802670 <__udivdi3+0x40>
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80273b:	31 ff                	xor    %edi,%edi
  80273d:	e9 2e ff ff ff       	jmp    802670 <__udivdi3+0x40>
  802742:	66 90                	xchg   %ax,%ax
  802744:	66 90                	xchg   %ax,%ax
  802746:	66 90                	xchg   %ax,%ax
  802748:	66 90                	xchg   %ax,%ax
  80274a:	66 90                	xchg   %ax,%ax
  80274c:	66 90                	xchg   %ax,%ax
  80274e:	66 90                	xchg   %ax,%ax

00802750 <__umoddi3>:
  802750:	f3 0f 1e fb          	endbr32 
  802754:	55                   	push   %ebp
  802755:	57                   	push   %edi
  802756:	56                   	push   %esi
  802757:	53                   	push   %ebx
  802758:	83 ec 1c             	sub    $0x1c,%esp
  80275b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80275f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802763:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802767:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80276b:	89 f0                	mov    %esi,%eax
  80276d:	89 da                	mov    %ebx,%edx
  80276f:	85 ff                	test   %edi,%edi
  802771:	75 15                	jne    802788 <__umoddi3+0x38>
  802773:	39 dd                	cmp    %ebx,%ebp
  802775:	76 39                	jbe    8027b0 <__umoddi3+0x60>
  802777:	f7 f5                	div    %ebp
  802779:	89 d0                	mov    %edx,%eax
  80277b:	31 d2                	xor    %edx,%edx
  80277d:	83 c4 1c             	add    $0x1c,%esp
  802780:	5b                   	pop    %ebx
  802781:	5e                   	pop    %esi
  802782:	5f                   	pop    %edi
  802783:	5d                   	pop    %ebp
  802784:	c3                   	ret    
  802785:	8d 76 00             	lea    0x0(%esi),%esi
  802788:	39 df                	cmp    %ebx,%edi
  80278a:	77 f1                	ja     80277d <__umoddi3+0x2d>
  80278c:	0f bd cf             	bsr    %edi,%ecx
  80278f:	83 f1 1f             	xor    $0x1f,%ecx
  802792:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802796:	75 40                	jne    8027d8 <__umoddi3+0x88>
  802798:	39 df                	cmp    %ebx,%edi
  80279a:	72 04                	jb     8027a0 <__umoddi3+0x50>
  80279c:	39 f5                	cmp    %esi,%ebp
  80279e:	77 dd                	ja     80277d <__umoddi3+0x2d>
  8027a0:	89 da                	mov    %ebx,%edx
  8027a2:	89 f0                	mov    %esi,%eax
  8027a4:	29 e8                	sub    %ebp,%eax
  8027a6:	19 fa                	sbb    %edi,%edx
  8027a8:	eb d3                	jmp    80277d <__umoddi3+0x2d>
  8027aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b0:	89 e9                	mov    %ebp,%ecx
  8027b2:	85 ed                	test   %ebp,%ebp
  8027b4:	75 0b                	jne    8027c1 <__umoddi3+0x71>
  8027b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027bb:	31 d2                	xor    %edx,%edx
  8027bd:	f7 f5                	div    %ebp
  8027bf:	89 c1                	mov    %eax,%ecx
  8027c1:	89 d8                	mov    %ebx,%eax
  8027c3:	31 d2                	xor    %edx,%edx
  8027c5:	f7 f1                	div    %ecx
  8027c7:	89 f0                	mov    %esi,%eax
  8027c9:	f7 f1                	div    %ecx
  8027cb:	89 d0                	mov    %edx,%eax
  8027cd:	31 d2                	xor    %edx,%edx
  8027cf:	eb ac                	jmp    80277d <__umoddi3+0x2d>
  8027d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027dc:	ba 20 00 00 00       	mov    $0x20,%edx
  8027e1:	29 c2                	sub    %eax,%edx
  8027e3:	89 c1                	mov    %eax,%ecx
  8027e5:	89 e8                	mov    %ebp,%eax
  8027e7:	d3 e7                	shl    %cl,%edi
  8027e9:	89 d1                	mov    %edx,%ecx
  8027eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8027ef:	d3 e8                	shr    %cl,%eax
  8027f1:	89 c1                	mov    %eax,%ecx
  8027f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027f7:	09 f9                	or     %edi,%ecx
  8027f9:	89 df                	mov    %ebx,%edi
  8027fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ff:	89 c1                	mov    %eax,%ecx
  802801:	d3 e5                	shl    %cl,%ebp
  802803:	89 d1                	mov    %edx,%ecx
  802805:	d3 ef                	shr    %cl,%edi
  802807:	89 c1                	mov    %eax,%ecx
  802809:	89 f0                	mov    %esi,%eax
  80280b:	d3 e3                	shl    %cl,%ebx
  80280d:	89 d1                	mov    %edx,%ecx
  80280f:	89 fa                	mov    %edi,%edx
  802811:	d3 e8                	shr    %cl,%eax
  802813:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802818:	09 d8                	or     %ebx,%eax
  80281a:	f7 74 24 08          	divl   0x8(%esp)
  80281e:	89 d3                	mov    %edx,%ebx
  802820:	d3 e6                	shl    %cl,%esi
  802822:	f7 e5                	mul    %ebp
  802824:	89 c7                	mov    %eax,%edi
  802826:	89 d1                	mov    %edx,%ecx
  802828:	39 d3                	cmp    %edx,%ebx
  80282a:	72 06                	jb     802832 <__umoddi3+0xe2>
  80282c:	75 0e                	jne    80283c <__umoddi3+0xec>
  80282e:	39 c6                	cmp    %eax,%esi
  802830:	73 0a                	jae    80283c <__umoddi3+0xec>
  802832:	29 e8                	sub    %ebp,%eax
  802834:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802838:	89 d1                	mov    %edx,%ecx
  80283a:	89 c7                	mov    %eax,%edi
  80283c:	89 f5                	mov    %esi,%ebp
  80283e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802842:	29 fd                	sub    %edi,%ebp
  802844:	19 cb                	sbb    %ecx,%ebx
  802846:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80284b:	89 d8                	mov    %ebx,%eax
  80284d:	d3 e0                	shl    %cl,%eax
  80284f:	89 f1                	mov    %esi,%ecx
  802851:	d3 ed                	shr    %cl,%ebp
  802853:	d3 eb                	shr    %cl,%ebx
  802855:	09 e8                	or     %ebp,%eax
  802857:	89 da                	mov    %ebx,%edx
  802859:	83 c4 1c             	add    $0x1c,%esp
  80285c:	5b                   	pop    %ebx
  80285d:	5e                   	pop    %esi
  80285e:	5f                   	pop    %edi
  80285f:	5d                   	pop    %ebp
  802860:	c3                   	ret    
