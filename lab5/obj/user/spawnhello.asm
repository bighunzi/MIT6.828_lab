
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
  800042:	68 a0 23 80 00       	push   $0x8023a0
  800047:	e8 6a 01 00 00       	call   8001b6 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 be 23 80 00       	push   $0x8023be
  800056:	68 be 23 80 00       	push   $0x8023be
  80005b:	e8 6d 1a 00 00       	call   801acd <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	78 02                	js     800069 <umain+0x36>
		panic("spawn(hello) failed: %e", r);
}
  800067:	c9                   	leave  
  800068:	c3                   	ret    
		panic("spawn(hello) failed: %e", r);
  800069:	50                   	push   %eax
  80006a:	68 c4 23 80 00       	push   $0x8023c4
  80006f:	6a 09                	push   $0x9
  800071:	68 dc 23 80 00       	push   $0x8023dc
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
  8000c7:	e8 7d 0e 00 00       	call   800f49 <close_all>
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
  8000f9:	68 f8 23 80 00       	push   $0x8023f8
  8000fe:	e8 b3 00 00 00       	call   8001b6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	push   0x10(%ebp)
  80010a:	e8 56 00 00 00       	call   800165 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 d6 28 80 00 	movl   $0x8028d6,(%esp)
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
  800218:	e8 43 1f 00 00       	call   802160 <__udivdi3>
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
  800256:	e8 25 20 00 00       	call   802280 <__umoddi3>
  80025b:	83 c4 14             	add    $0x14,%esp
  80025e:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
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
  800318:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
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
  8003e6:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	74 18                	je     800409 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003f1:	52                   	push   %edx
  8003f2:	68 f1 27 80 00       	push   $0x8027f1
  8003f7:	53                   	push   %ebx
  8003f8:	56                   	push   %esi
  8003f9:	e8 92 fe ff ff       	call   800290 <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800401:	89 7d 14             	mov    %edi,0x14(%ebp)
  800404:	e9 66 02 00 00       	jmp    80066f <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800409:	50                   	push   %eax
  80040a:	68 33 24 80 00       	push   $0x802433
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
  800431:	b8 2c 24 80 00       	mov    $0x80242c,%eax
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
  800b3d:	68 1f 27 80 00       	push   $0x80271f
  800b42:	6a 2a                	push   $0x2a
  800b44:	68 3c 27 80 00       	push   $0x80273c
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
  800bbe:	68 1f 27 80 00       	push   $0x80271f
  800bc3:	6a 2a                	push   $0x2a
  800bc5:	68 3c 27 80 00       	push   $0x80273c
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
  800c00:	68 1f 27 80 00       	push   $0x80271f
  800c05:	6a 2a                	push   $0x2a
  800c07:	68 3c 27 80 00       	push   $0x80273c
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
  800c42:	68 1f 27 80 00       	push   $0x80271f
  800c47:	6a 2a                	push   $0x2a
  800c49:	68 3c 27 80 00       	push   $0x80273c
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
  800c84:	68 1f 27 80 00       	push   $0x80271f
  800c89:	6a 2a                	push   $0x2a
  800c8b:	68 3c 27 80 00       	push   $0x80273c
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
  800cc6:	68 1f 27 80 00       	push   $0x80271f
  800ccb:	6a 2a                	push   $0x2a
  800ccd:	68 3c 27 80 00       	push   $0x80273c
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
  800d08:	68 1f 27 80 00       	push   $0x80271f
  800d0d:	6a 2a                	push   $0x2a
  800d0f:	68 3c 27 80 00       	push   $0x80273c
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
  800d6c:	68 1f 27 80 00       	push   $0x80271f
  800d71:	6a 2a                	push   $0x2a
  800d73:	68 3c 27 80 00       	push   $0x80273c
  800d78:	e8 5e f3 ff ff       	call   8000db <_panic>

00800d7d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	05 00 00 00 30       	add    $0x30000000,%eax
  800d88:	c1 e8 0c             	shr    $0xc,%eax
}
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d9d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dac:	89 c2                	mov    %eax,%edx
  800dae:	c1 ea 16             	shr    $0x16,%edx
  800db1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db8:	f6 c2 01             	test   $0x1,%dl
  800dbb:	74 29                	je     800de6 <fd_alloc+0x42>
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	c1 ea 0c             	shr    $0xc,%edx
  800dc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc9:	f6 c2 01             	test   $0x1,%dl
  800dcc:	74 18                	je     800de6 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800dce:	05 00 10 00 00       	add    $0x1000,%eax
  800dd3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dd8:	75 d2                	jne    800dac <fd_alloc+0x8>
  800dda:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800ddf:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800de4:	eb 05                	jmp    800deb <fd_alloc+0x47>
			return 0;
  800de6:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	89 02                	mov    %eax,(%edx)
}
  800df0:	89 c8                	mov    %ecx,%eax
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dfa:	83 f8 1f             	cmp    $0x1f,%eax
  800dfd:	77 30                	ja     800e2f <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dff:	c1 e0 0c             	shl    $0xc,%eax
  800e02:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e07:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e0d:	f6 c2 01             	test   $0x1,%dl
  800e10:	74 24                	je     800e36 <fd_lookup+0x42>
  800e12:	89 c2                	mov    %eax,%edx
  800e14:	c1 ea 0c             	shr    $0xc,%edx
  800e17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1e:	f6 c2 01             	test   $0x1,%dl
  800e21:	74 1a                	je     800e3d <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e26:	89 02                	mov    %eax,(%edx)
	return 0;
  800e28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    
		return -E_INVAL;
  800e2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e34:	eb f7                	jmp    800e2d <fd_lookup+0x39>
		return -E_INVAL;
  800e36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3b:	eb f0                	jmp    800e2d <fd_lookup+0x39>
  800e3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e42:	eb e9                	jmp    800e2d <fd_lookup+0x39>

00800e44 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	53                   	push   %ebx
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4e:	b8 c8 27 80 00       	mov    $0x8027c8,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800e53:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e58:	39 13                	cmp    %edx,(%ebx)
  800e5a:	74 32                	je     800e8e <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800e5c:	83 c0 04             	add    $0x4,%eax
  800e5f:	8b 18                	mov    (%eax),%ebx
  800e61:	85 db                	test   %ebx,%ebx
  800e63:	75 f3                	jne    800e58 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e65:	a1 00 40 80 00       	mov    0x804000,%eax
  800e6a:	8b 40 48             	mov    0x48(%eax),%eax
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	52                   	push   %edx
  800e71:	50                   	push   %eax
  800e72:	68 4c 27 80 00       	push   $0x80274c
  800e77:	e8 3a f3 ff ff       	call   8001b6 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e87:	89 1a                	mov    %ebx,(%edx)
}
  800e89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    
			return 0;
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e93:	eb ef                	jmp    800e84 <dev_lookup+0x40>

00800e95 <fd_close>:
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	57                   	push   %edi
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
  800e9b:	83 ec 24             	sub    $0x24,%esp
  800e9e:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ea7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eae:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb1:	50                   	push   %eax
  800eb2:	e8 3d ff ff ff       	call   800df4 <fd_lookup>
  800eb7:	89 c3                	mov    %eax,%ebx
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	78 05                	js     800ec5 <fd_close+0x30>
	    || fd != fd2)
  800ec0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ec3:	74 16                	je     800edb <fd_close+0x46>
		return (must_exist ? r : 0);
  800ec5:	89 f8                	mov    %edi,%eax
  800ec7:	84 c0                	test   %al,%al
  800ec9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ece:	0f 44 d8             	cmove  %eax,%ebx
}
  800ed1:	89 d8                	mov    %ebx,%eax
  800ed3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800edb:	83 ec 08             	sub    $0x8,%esp
  800ede:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ee1:	50                   	push   %eax
  800ee2:	ff 36                	push   (%esi)
  800ee4:	e8 5b ff ff ff       	call   800e44 <dev_lookup>
  800ee9:	89 c3                	mov    %eax,%ebx
  800eeb:	83 c4 10             	add    $0x10,%esp
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	78 1a                	js     800f0c <fd_close+0x77>
		if (dev->dev_close)
  800ef2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ef5:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800efd:	85 c0                	test   %eax,%eax
  800eff:	74 0b                	je     800f0c <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	56                   	push   %esi
  800f05:	ff d0                	call   *%eax
  800f07:	89 c3                	mov    %eax,%ebx
  800f09:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f0c:	83 ec 08             	sub    $0x8,%esp
  800f0f:	56                   	push   %esi
  800f10:	6a 00                	push   $0x0
  800f12:	e8 fa fc ff ff       	call   800c11 <sys_page_unmap>
	return r;
  800f17:	83 c4 10             	add    $0x10,%esp
  800f1a:	eb b5                	jmp    800ed1 <fd_close+0x3c>

00800f1c <close>:

int
close(int fdnum)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f25:	50                   	push   %eax
  800f26:	ff 75 08             	push   0x8(%ebp)
  800f29:	e8 c6 fe ff ff       	call   800df4 <fd_lookup>
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	85 c0                	test   %eax,%eax
  800f33:	79 02                	jns    800f37 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    
		return fd_close(fd, 1);
  800f37:	83 ec 08             	sub    $0x8,%esp
  800f3a:	6a 01                	push   $0x1
  800f3c:	ff 75 f4             	push   -0xc(%ebp)
  800f3f:	e8 51 ff ff ff       	call   800e95 <fd_close>
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	eb ec                	jmp    800f35 <close+0x19>

00800f49 <close_all>:

void
close_all(void)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f55:	83 ec 0c             	sub    $0xc,%esp
  800f58:	53                   	push   %ebx
  800f59:	e8 be ff ff ff       	call   800f1c <close>
	for (i = 0; i < MAXFD; i++)
  800f5e:	83 c3 01             	add    $0x1,%ebx
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	83 fb 20             	cmp    $0x20,%ebx
  800f67:	75 ec                	jne    800f55 <close_all+0xc>
}
  800f69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6c:	c9                   	leave  
  800f6d:	c3                   	ret    

00800f6e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f77:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f7a:	50                   	push   %eax
  800f7b:	ff 75 08             	push   0x8(%ebp)
  800f7e:	e8 71 fe ff ff       	call   800df4 <fd_lookup>
  800f83:	89 c3                	mov    %eax,%ebx
  800f85:	83 c4 10             	add    $0x10,%esp
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	78 7f                	js     80100b <dup+0x9d>
		return r;
	close(newfdnum);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	ff 75 0c             	push   0xc(%ebp)
  800f92:	e8 85 ff ff ff       	call   800f1c <close>

	newfd = INDEX2FD(newfdnum);
  800f97:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f9a:	c1 e6 0c             	shl    $0xc,%esi
  800f9d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fa3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fa6:	89 3c 24             	mov    %edi,(%esp)
  800fa9:	e8 df fd ff ff       	call   800d8d <fd2data>
  800fae:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fb0:	89 34 24             	mov    %esi,(%esp)
  800fb3:	e8 d5 fd ff ff       	call   800d8d <fd2data>
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fbe:	89 d8                	mov    %ebx,%eax
  800fc0:	c1 e8 16             	shr    $0x16,%eax
  800fc3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fca:	a8 01                	test   $0x1,%al
  800fcc:	74 11                	je     800fdf <dup+0x71>
  800fce:	89 d8                	mov    %ebx,%eax
  800fd0:	c1 e8 0c             	shr    $0xc,%eax
  800fd3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fda:	f6 c2 01             	test   $0x1,%dl
  800fdd:	75 36                	jne    801015 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fdf:	89 f8                	mov    %edi,%eax
  800fe1:	c1 e8 0c             	shr    $0xc,%eax
  800fe4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff3:	50                   	push   %eax
  800ff4:	56                   	push   %esi
  800ff5:	6a 00                	push   $0x0
  800ff7:	57                   	push   %edi
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 d0 fb ff ff       	call   800bcf <sys_page_map>
  800fff:	89 c3                	mov    %eax,%ebx
  801001:	83 c4 20             	add    $0x20,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	78 33                	js     80103b <dup+0xcd>
		goto err;

	return newfdnum;
  801008:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801015:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	25 07 0e 00 00       	and    $0xe07,%eax
  801024:	50                   	push   %eax
  801025:	ff 75 d4             	push   -0x2c(%ebp)
  801028:	6a 00                	push   $0x0
  80102a:	53                   	push   %ebx
  80102b:	6a 00                	push   $0x0
  80102d:	e8 9d fb ff ff       	call   800bcf <sys_page_map>
  801032:	89 c3                	mov    %eax,%ebx
  801034:	83 c4 20             	add    $0x20,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	79 a4                	jns    800fdf <dup+0x71>
	sys_page_unmap(0, newfd);
  80103b:	83 ec 08             	sub    $0x8,%esp
  80103e:	56                   	push   %esi
  80103f:	6a 00                	push   $0x0
  801041:	e8 cb fb ff ff       	call   800c11 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801046:	83 c4 08             	add    $0x8,%esp
  801049:	ff 75 d4             	push   -0x2c(%ebp)
  80104c:	6a 00                	push   $0x0
  80104e:	e8 be fb ff ff       	call   800c11 <sys_page_unmap>
	return r;
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	eb b3                	jmp    80100b <dup+0x9d>

00801058 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 18             	sub    $0x18,%esp
  801060:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801063:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801066:	50                   	push   %eax
  801067:	56                   	push   %esi
  801068:	e8 87 fd ff ff       	call   800df4 <fd_lookup>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	78 3c                	js     8010b0 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801074:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801077:	83 ec 08             	sub    $0x8,%esp
  80107a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107d:	50                   	push   %eax
  80107e:	ff 33                	push   (%ebx)
  801080:	e8 bf fd ff ff       	call   800e44 <dev_lookup>
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	78 24                	js     8010b0 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80108c:	8b 43 08             	mov    0x8(%ebx),%eax
  80108f:	83 e0 03             	and    $0x3,%eax
  801092:	83 f8 01             	cmp    $0x1,%eax
  801095:	74 20                	je     8010b7 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801097:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109a:	8b 40 08             	mov    0x8(%eax),%eax
  80109d:	85 c0                	test   %eax,%eax
  80109f:	74 37                	je     8010d8 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010a1:	83 ec 04             	sub    $0x4,%esp
  8010a4:	ff 75 10             	push   0x10(%ebp)
  8010a7:	ff 75 0c             	push   0xc(%ebp)
  8010aa:	53                   	push   %ebx
  8010ab:	ff d0                	call   *%eax
  8010ad:	83 c4 10             	add    $0x10,%esp
}
  8010b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010b7:	a1 00 40 80 00       	mov    0x804000,%eax
  8010bc:	8b 40 48             	mov    0x48(%eax),%eax
  8010bf:	83 ec 04             	sub    $0x4,%esp
  8010c2:	56                   	push   %esi
  8010c3:	50                   	push   %eax
  8010c4:	68 8d 27 80 00       	push   $0x80278d
  8010c9:	e8 e8 f0 ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d6:	eb d8                	jmp    8010b0 <read+0x58>
		return -E_NOT_SUPP;
  8010d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010dd:	eb d1                	jmp    8010b0 <read+0x58>

008010df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	57                   	push   %edi
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f3:	eb 02                	jmp    8010f7 <readn+0x18>
  8010f5:	01 c3                	add    %eax,%ebx
  8010f7:	39 f3                	cmp    %esi,%ebx
  8010f9:	73 21                	jae    80111c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010fb:	83 ec 04             	sub    $0x4,%esp
  8010fe:	89 f0                	mov    %esi,%eax
  801100:	29 d8                	sub    %ebx,%eax
  801102:	50                   	push   %eax
  801103:	89 d8                	mov    %ebx,%eax
  801105:	03 45 0c             	add    0xc(%ebp),%eax
  801108:	50                   	push   %eax
  801109:	57                   	push   %edi
  80110a:	e8 49 ff ff ff       	call   801058 <read>
		if (m < 0)
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 04                	js     80111a <readn+0x3b>
			return m;
		if (m == 0)
  801116:	75 dd                	jne    8010f5 <readn+0x16>
  801118:	eb 02                	jmp    80111c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80111a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80111c:	89 d8                	mov    %ebx,%eax
  80111e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801121:	5b                   	pop    %ebx
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	83 ec 18             	sub    $0x18,%esp
  80112e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801131:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801134:	50                   	push   %eax
  801135:	53                   	push   %ebx
  801136:	e8 b9 fc ff ff       	call   800df4 <fd_lookup>
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 37                	js     801179 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801142:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801145:	83 ec 08             	sub    $0x8,%esp
  801148:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114b:	50                   	push   %eax
  80114c:	ff 36                	push   (%esi)
  80114e:	e8 f1 fc ff ff       	call   800e44 <dev_lookup>
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	78 1f                	js     801179 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80115a:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80115e:	74 20                	je     801180 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801160:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801163:	8b 40 0c             	mov    0xc(%eax),%eax
  801166:	85 c0                	test   %eax,%eax
  801168:	74 37                	je     8011a1 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	ff 75 10             	push   0x10(%ebp)
  801170:	ff 75 0c             	push   0xc(%ebp)
  801173:	56                   	push   %esi
  801174:	ff d0                	call   *%eax
  801176:	83 c4 10             	add    $0x10,%esp
}
  801179:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801180:	a1 00 40 80 00       	mov    0x804000,%eax
  801185:	8b 40 48             	mov    0x48(%eax),%eax
  801188:	83 ec 04             	sub    $0x4,%esp
  80118b:	53                   	push   %ebx
  80118c:	50                   	push   %eax
  80118d:	68 a9 27 80 00       	push   $0x8027a9
  801192:	e8 1f f0 ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80119f:	eb d8                	jmp    801179 <write+0x53>
		return -E_NOT_SUPP;
  8011a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011a6:	eb d1                	jmp    801179 <write+0x53>

008011a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	ff 75 08             	push   0x8(%ebp)
  8011b5:	e8 3a fc ff ff       	call   800df4 <fd_lookup>
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 0e                	js     8011cf <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    

008011d1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	56                   	push   %esi
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 18             	sub    $0x18,%esp
  8011d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	53                   	push   %ebx
  8011e1:	e8 0e fc ff ff       	call   800df4 <fd_lookup>
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	78 34                	js     801221 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ed:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011f0:	83 ec 08             	sub    $0x8,%esp
  8011f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	ff 36                	push   (%esi)
  8011f9:	e8 46 fc ff ff       	call   800e44 <dev_lookup>
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	85 c0                	test   %eax,%eax
  801203:	78 1c                	js     801221 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801205:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801209:	74 1d                	je     801228 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80120b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120e:	8b 40 18             	mov    0x18(%eax),%eax
  801211:	85 c0                	test   %eax,%eax
  801213:	74 34                	je     801249 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801215:	83 ec 08             	sub    $0x8,%esp
  801218:	ff 75 0c             	push   0xc(%ebp)
  80121b:	56                   	push   %esi
  80121c:	ff d0                	call   *%eax
  80121e:	83 c4 10             	add    $0x10,%esp
}
  801221:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    
			thisenv->env_id, fdnum);
  801228:	a1 00 40 80 00       	mov    0x804000,%eax
  80122d:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	53                   	push   %ebx
  801234:	50                   	push   %eax
  801235:	68 6c 27 80 00       	push   $0x80276c
  80123a:	e8 77 ef ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801247:	eb d8                	jmp    801221 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801249:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80124e:	eb d1                	jmp    801221 <ftruncate+0x50>

00801250 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
  801255:	83 ec 18             	sub    $0x18,%esp
  801258:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	ff 75 08             	push   0x8(%ebp)
  801262:	e8 8d fb ff ff       	call   800df4 <fd_lookup>
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 49                	js     8012b7 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	ff 36                	push   (%esi)
  80127a:	e8 c5 fb ff ff       	call   800e44 <dev_lookup>
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 31                	js     8012b7 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801286:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801289:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80128d:	74 2f                	je     8012be <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80128f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801292:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801299:	00 00 00 
	stat->st_isdir = 0;
  80129c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a3:	00 00 00 
	stat->st_dev = dev;
  8012a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012ac:	83 ec 08             	sub    $0x8,%esp
  8012af:	53                   	push   %ebx
  8012b0:	56                   	push   %esi
  8012b1:	ff 50 14             	call   *0x14(%eax)
  8012b4:	83 c4 10             	add    $0x10,%esp
}
  8012b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ba:	5b                   	pop    %ebx
  8012bb:	5e                   	pop    %esi
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    
		return -E_NOT_SUPP;
  8012be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c3:	eb f2                	jmp    8012b7 <fstat+0x67>

008012c5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ca:	83 ec 08             	sub    $0x8,%esp
  8012cd:	6a 00                	push   $0x0
  8012cf:	ff 75 08             	push   0x8(%ebp)
  8012d2:	e8 e4 01 00 00       	call   8014bb <open>
  8012d7:	89 c3                	mov    %eax,%ebx
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 1b                	js     8012fb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012e0:	83 ec 08             	sub    $0x8,%esp
  8012e3:	ff 75 0c             	push   0xc(%ebp)
  8012e6:	50                   	push   %eax
  8012e7:	e8 64 ff ff ff       	call   801250 <fstat>
  8012ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8012ee:	89 1c 24             	mov    %ebx,(%esp)
  8012f1:	e8 26 fc ff ff       	call   800f1c <close>
	return r;
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	89 f3                	mov    %esi,%ebx
}
  8012fb:	89 d8                	mov    %ebx,%eax
  8012fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    

00801304 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	56                   	push   %esi
  801308:	53                   	push   %ebx
  801309:	89 c6                	mov    %eax,%esi
  80130b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80130d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801314:	74 27                	je     80133d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801316:	6a 07                	push   $0x7
  801318:	68 00 50 80 00       	push   $0x805000
  80131d:	56                   	push   %esi
  80131e:	ff 35 00 60 80 00    	push   0x806000
  801324:	e8 6e 0d 00 00       	call   802097 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801329:	83 c4 0c             	add    $0xc,%esp
  80132c:	6a 00                	push   $0x0
  80132e:	53                   	push   %ebx
  80132f:	6a 00                	push   $0x0
  801331:	e8 fa 0c 00 00       	call   802030 <ipc_recv>
}
  801336:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80133d:	83 ec 0c             	sub    $0xc,%esp
  801340:	6a 01                	push   $0x1
  801342:	e8 a4 0d 00 00       	call   8020eb <ipc_find_env>
  801347:	a3 00 60 80 00       	mov    %eax,0x806000
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	eb c5                	jmp    801316 <fsipc+0x12>

00801351 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801357:	8b 45 08             	mov    0x8(%ebp),%eax
  80135a:	8b 40 0c             	mov    0xc(%eax),%eax
  80135d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801362:	8b 45 0c             	mov    0xc(%ebp),%eax
  801365:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80136a:	ba 00 00 00 00       	mov    $0x0,%edx
  80136f:	b8 02 00 00 00       	mov    $0x2,%eax
  801374:	e8 8b ff ff ff       	call   801304 <fsipc>
}
  801379:	c9                   	leave  
  80137a:	c3                   	ret    

0080137b <devfile_flush>:
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801381:	8b 45 08             	mov    0x8(%ebp),%eax
  801384:	8b 40 0c             	mov    0xc(%eax),%eax
  801387:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80138c:	ba 00 00 00 00       	mov    $0x0,%edx
  801391:	b8 06 00 00 00       	mov    $0x6,%eax
  801396:	e8 69 ff ff ff       	call   801304 <fsipc>
}
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <devfile_stat>:
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 04             	sub    $0x4,%esp
  8013a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8013bc:	e8 43 ff ff ff       	call   801304 <fsipc>
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 2c                	js     8013f1 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	68 00 50 80 00       	push   $0x805000
  8013cd:	53                   	push   %ebx
  8013ce:	e8 bd f3 ff ff       	call   800790 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8013d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013de:	a1 84 50 80 00       	mov    0x805084,%eax
  8013e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <devfile_write>:
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ff:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801404:	39 d0                	cmp    %edx,%eax
  801406:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801409:	8b 55 08             	mov    0x8(%ebp),%edx
  80140c:	8b 52 0c             	mov    0xc(%edx),%edx
  80140f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801415:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80141a:	50                   	push   %eax
  80141b:	ff 75 0c             	push   0xc(%ebp)
  80141e:	68 08 50 80 00       	push   $0x805008
  801423:	e8 fe f4 ff ff       	call   800926 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801428:	ba 00 00 00 00       	mov    $0x0,%edx
  80142d:	b8 04 00 00 00       	mov    $0x4,%eax
  801432:	e8 cd fe ff ff       	call   801304 <fsipc>
}
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <devfile_read>:
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	56                   	push   %esi
  80143d:	53                   	push   %ebx
  80143e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801441:	8b 45 08             	mov    0x8(%ebp),%eax
  801444:	8b 40 0c             	mov    0xc(%eax),%eax
  801447:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80144c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801452:	ba 00 00 00 00       	mov    $0x0,%edx
  801457:	b8 03 00 00 00       	mov    $0x3,%eax
  80145c:	e8 a3 fe ff ff       	call   801304 <fsipc>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	85 c0                	test   %eax,%eax
  801465:	78 1f                	js     801486 <devfile_read+0x4d>
	assert(r <= n);
  801467:	39 f0                	cmp    %esi,%eax
  801469:	77 24                	ja     80148f <devfile_read+0x56>
	assert(r <= PGSIZE);
  80146b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801470:	7f 33                	jg     8014a5 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801472:	83 ec 04             	sub    $0x4,%esp
  801475:	50                   	push   %eax
  801476:	68 00 50 80 00       	push   $0x805000
  80147b:	ff 75 0c             	push   0xc(%ebp)
  80147e:	e8 a3 f4 ff ff       	call   800926 <memmove>
	return r;
  801483:	83 c4 10             	add    $0x10,%esp
}
  801486:	89 d8                	mov    %ebx,%eax
  801488:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148b:	5b                   	pop    %ebx
  80148c:	5e                   	pop    %esi
  80148d:	5d                   	pop    %ebp
  80148e:	c3                   	ret    
	assert(r <= n);
  80148f:	68 d8 27 80 00       	push   $0x8027d8
  801494:	68 df 27 80 00       	push   $0x8027df
  801499:	6a 7c                	push   $0x7c
  80149b:	68 f4 27 80 00       	push   $0x8027f4
  8014a0:	e8 36 ec ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  8014a5:	68 ff 27 80 00       	push   $0x8027ff
  8014aa:	68 df 27 80 00       	push   $0x8027df
  8014af:	6a 7d                	push   $0x7d
  8014b1:	68 f4 27 80 00       	push   $0x8027f4
  8014b6:	e8 20 ec ff ff       	call   8000db <_panic>

008014bb <open>:
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 1c             	sub    $0x1c,%esp
  8014c3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014c6:	56                   	push   %esi
  8014c7:	e8 89 f2 ff ff       	call   800755 <strlen>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d4:	7f 6c                	jg     801542 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	e8 c2 f8 ff ff       	call   800da4 <fd_alloc>
  8014e2:	89 c3                	mov    %eax,%ebx
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 3c                	js     801527 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	56                   	push   %esi
  8014ef:	68 00 50 80 00       	push   $0x805000
  8014f4:	e8 97 f2 ff ff       	call   800790 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fc:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801501:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801504:	b8 01 00 00 00       	mov    $0x1,%eax
  801509:	e8 f6 fd ff ff       	call   801304 <fsipc>
  80150e:	89 c3                	mov    %eax,%ebx
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	78 19                	js     801530 <open+0x75>
	return fd2num(fd);
  801517:	83 ec 0c             	sub    $0xc,%esp
  80151a:	ff 75 f4             	push   -0xc(%ebp)
  80151d:	e8 5b f8 ff ff       	call   800d7d <fd2num>
  801522:	89 c3                	mov    %eax,%ebx
  801524:	83 c4 10             	add    $0x10,%esp
}
  801527:	89 d8                	mov    %ebx,%eax
  801529:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5e                   	pop    %esi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    
		fd_close(fd, 0);
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	6a 00                	push   $0x0
  801535:	ff 75 f4             	push   -0xc(%ebp)
  801538:	e8 58 f9 ff ff       	call   800e95 <fd_close>
		return r;
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	eb e5                	jmp    801527 <open+0x6c>
		return -E_BAD_PATH;
  801542:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801547:	eb de                	jmp    801527 <open+0x6c>

00801549 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 08 00 00 00       	mov    $0x8,%eax
  801559:	e8 a6 fd ff ff       	call   801304 <fsipc>
}
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	57                   	push   %edi
  801564:	56                   	push   %esi
  801565:	53                   	push   %ebx
  801566:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80156c:	6a 00                	push   $0x0
  80156e:	ff 75 08             	push   0x8(%ebp)
  801571:	e8 45 ff ff ff       	call   8014bb <open>
  801576:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	85 c0                	test   %eax,%eax
  801581:	0f 88 aa 04 00 00    	js     801a31 <spawn+0x4d1>
  801587:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801589:	83 ec 04             	sub    $0x4,%esp
  80158c:	68 00 02 00 00       	push   $0x200
  801591:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	57                   	push   %edi
  801599:	e8 41 fb ff ff       	call   8010df <readn>
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015a6:	75 57                	jne    8015ff <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  8015a8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015af:	45 4c 46 
  8015b2:	75 4b                	jne    8015ff <spawn+0x9f>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8015b4:	b8 07 00 00 00       	mov    $0x7,%eax
  8015b9:	cd 30                	int    $0x30
  8015bb:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	0f 88 5c 04 00 00    	js     801a25 <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8015c9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015ce:	6b f0 7c             	imul   $0x7c,%eax,%esi
  8015d1:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8015d7:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8015dd:	b9 11 00 00 00       	mov    $0x11,%ecx
  8015e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8015e4:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8015ea:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8015f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8015f5:	be 00 00 00 00       	mov    $0x0,%esi
  8015fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  8015fd:	eb 4b                	jmp    80164a <spawn+0xea>
		close(fd);
  8015ff:	83 ec 0c             	sub    $0xc,%esp
  801602:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801608:	e8 0f f9 ff ff       	call   800f1c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80160d:	83 c4 0c             	add    $0xc,%esp
  801610:	68 7f 45 4c 46       	push   $0x464c457f
  801615:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  80161b:	68 0b 28 80 00       	push   $0x80280b
  801620:	e8 91 eb ff ff       	call   8001b6 <cprintf>
		return -E_NOT_EXEC;
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  80162f:	ff ff ff 
  801632:	e9 fa 03 00 00       	jmp    801a31 <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  801637:	83 ec 0c             	sub    $0xc,%esp
  80163a:	50                   	push   %eax
  80163b:	e8 15 f1 ff ff       	call   800755 <strlen>
  801640:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801644:	83 c3 01             	add    $0x1,%ebx
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801651:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801654:	85 c0                	test   %eax,%eax
  801656:	75 df                	jne    801637 <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801658:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  80165e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801664:	b8 00 10 40 00       	mov    $0x401000,%eax
  801669:	29 f0                	sub    %esi,%eax
  80166b:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	83 e2 fc             	and    $0xfffffffc,%edx
  801672:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801679:	29 c2                	sub    %eax,%edx
  80167b:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801681:	8d 42 f8             	lea    -0x8(%edx),%eax
  801684:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801689:	0f 86 14 04 00 00    	jbe    801aa3 <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80168f:	83 ec 04             	sub    $0x4,%esp
  801692:	6a 07                	push   $0x7
  801694:	68 00 00 40 00       	push   $0x400000
  801699:	6a 00                	push   $0x0
  80169b:	e8 ec f4 ff ff       	call   800b8c <sys_page_alloc>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	0f 88 fd 03 00 00    	js     801aa8 <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8016ab:	be 00 00 00 00       	mov    $0x0,%esi
  8016b0:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8016b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016b9:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8016bf:	7e 32                	jle    8016f3 <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  8016c1:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8016c7:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8016cd:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8016d0:	83 ec 08             	sub    $0x8,%esp
  8016d3:	ff 34 b3             	push   (%ebx,%esi,4)
  8016d6:	57                   	push   %edi
  8016d7:	e8 b4 f0 ff ff       	call   800790 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8016dc:	83 c4 04             	add    $0x4,%esp
  8016df:	ff 34 b3             	push   (%ebx,%esi,4)
  8016e2:	e8 6e f0 ff ff       	call   800755 <strlen>
  8016e7:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  8016eb:	83 c6 01             	add    $0x1,%esi
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	eb c6                	jmp    8016b9 <spawn+0x159>
	}
	argv_store[argc] = 0;
  8016f3:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8016f9:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8016ff:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801706:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80170c:	0f 85 8c 00 00 00    	jne    80179e <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801712:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801718:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  80171e:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801721:	89 c8                	mov    %ecx,%eax
  801723:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801729:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80172c:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801731:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801737:	83 ec 0c             	sub    $0xc,%esp
  80173a:	6a 07                	push   $0x7
  80173c:	68 00 d0 bf ee       	push   $0xeebfd000
  801741:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801747:	68 00 00 40 00       	push   $0x400000
  80174c:	6a 00                	push   $0x0
  80174e:	e8 7c f4 ff ff       	call   800bcf <sys_page_map>
  801753:	89 c3                	mov    %eax,%ebx
  801755:	83 c4 20             	add    $0x20,%esp
  801758:	85 c0                	test   %eax,%eax
  80175a:	0f 88 50 03 00 00    	js     801ab0 <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	68 00 00 40 00       	push   $0x400000
  801768:	6a 00                	push   $0x0
  80176a:	e8 a2 f4 ff ff       	call   800c11 <sys_page_unmap>
  80176f:	89 c3                	mov    %eax,%ebx
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	85 c0                	test   %eax,%eax
  801776:	0f 88 34 03 00 00    	js     801ab0 <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80177c:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801782:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801789:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80178f:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801796:	00 00 00 
  801799:	e9 4e 01 00 00       	jmp    8018ec <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  80179e:	68 98 28 80 00       	push   $0x802898
  8017a3:	68 df 27 80 00       	push   $0x8027df
  8017a8:	68 f2 00 00 00       	push   $0xf2
  8017ad:	68 25 28 80 00       	push   $0x802825
  8017b2:	e8 24 e9 ff ff       	call   8000db <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	6a 07                	push   $0x7
  8017bc:	68 00 00 40 00       	push   $0x400000
  8017c1:	6a 00                	push   $0x0
  8017c3:	e8 c4 f3 ff ff       	call   800b8c <sys_page_alloc>
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	0f 88 6c 02 00 00    	js     801a3f <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8017d3:	83 ec 08             	sub    $0x8,%esp
  8017d6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8017dc:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8017e2:	50                   	push   %eax
  8017e3:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8017e9:	e8 ba f9 ff ff       	call   8011a8 <seek>
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	0f 88 4d 02 00 00    	js     801a46 <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8017f9:	83 ec 04             	sub    $0x4,%esp
  8017fc:	89 f8                	mov    %edi,%eax
  8017fe:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801804:	ba 00 10 00 00       	mov    $0x1000,%edx
  801809:	39 d0                	cmp    %edx,%eax
  80180b:	0f 47 c2             	cmova  %edx,%eax
  80180e:	50                   	push   %eax
  80180f:	68 00 00 40 00       	push   $0x400000
  801814:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80181a:	e8 c0 f8 ff ff       	call   8010df <readn>
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	85 c0                	test   %eax,%eax
  801824:	0f 88 23 02 00 00    	js     801a4d <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801833:	56                   	push   %esi
  801834:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80183a:	68 00 00 40 00       	push   $0x400000
  80183f:	6a 00                	push   $0x0
  801841:	e8 89 f3 ff ff       	call   800bcf <sys_page_map>
  801846:	83 c4 20             	add    $0x20,%esp
  801849:	85 c0                	test   %eax,%eax
  80184b:	78 7c                	js     8018c9 <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  80184d:	83 ec 08             	sub    $0x8,%esp
  801850:	68 00 00 40 00       	push   $0x400000
  801855:	6a 00                	push   $0x0
  801857:	e8 b5 f3 ff ff       	call   800c11 <sys_page_unmap>
  80185c:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  80185f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801865:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80186b:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801871:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801877:	76 65                	jbe    8018de <spawn+0x37e>
		if (i >= filesz) {
  801879:	39 df                	cmp    %ebx,%edi
  80187b:	0f 87 36 ff ff ff    	ja     8017b7 <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801881:	83 ec 04             	sub    $0x4,%esp
  801884:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  80188a:	56                   	push   %esi
  80188b:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801891:	e8 f6 f2 ff ff       	call   800b8c <sys_page_alloc>
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	85 c0                	test   %eax,%eax
  80189b:	79 c2                	jns    80185f <spawn+0x2ff>
  80189d:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  80189f:	83 ec 0c             	sub    $0xc,%esp
  8018a2:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8018a8:	e8 60 f2 ff ff       	call   800b0d <sys_env_destroy>
	close(fd);
  8018ad:	83 c4 04             	add    $0x4,%esp
  8018b0:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8018b6:	e8 61 f6 ff ff       	call   800f1c <close>
	return r;
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  8018c4:	e9 68 01 00 00       	jmp    801a31 <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  8018c9:	50                   	push   %eax
  8018ca:	68 31 28 80 00       	push   $0x802831
  8018cf:	68 25 01 00 00       	push   $0x125
  8018d4:	68 25 28 80 00       	push   $0x802825
  8018d9:	e8 fd e7 ff ff       	call   8000db <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018de:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  8018e5:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  8018ec:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8018f3:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  8018f9:	7e 67                	jle    801962 <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  8018fb:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801901:	83 39 01             	cmpl   $0x1,(%ecx)
  801904:	75 d8                	jne    8018de <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801906:	8b 41 18             	mov    0x18(%ecx),%eax
  801909:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80190f:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801912:	83 f8 01             	cmp    $0x1,%eax
  801915:	19 c0                	sbb    %eax,%eax
  801917:	83 e0 fe             	and    $0xfffffffe,%eax
  80191a:	83 c0 07             	add    $0x7,%eax
  80191d:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801923:	8b 51 04             	mov    0x4(%ecx),%edx
  801926:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  80192c:	8b 79 10             	mov    0x10(%ecx),%edi
  80192f:	8b 59 14             	mov    0x14(%ecx),%ebx
  801932:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801938:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  80193b:	89 f0                	mov    %esi,%eax
  80193d:	25 ff 0f 00 00       	and    $0xfff,%eax
  801942:	74 14                	je     801958 <spawn+0x3f8>
		va -= i;
  801944:	29 c6                	sub    %eax,%esi
		memsz += i;
  801946:	01 c3                	add    %eax,%ebx
  801948:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  80194e:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801950:	29 c2                	sub    %eax,%edx
  801952:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801958:	bb 00 00 00 00       	mov    $0x0,%ebx
  80195d:	e9 09 ff ff ff       	jmp    80186b <spawn+0x30b>
	close(fd);
  801962:	83 ec 0c             	sub    $0xc,%esp
  801965:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80196b:	e8 ac f5 ff ff       	call   800f1c <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801970:	e8 d9 f1 ff ff       	call   800b4e <sys_getenvid>
  801975:	89 c6                	mov    %eax,%esi
  801977:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80197a:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80197f:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801985:	eb 12                	jmp    801999 <spawn+0x439>
  801987:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80198d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801993:	0f 84 bb 00 00 00    	je     801a54 <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801999:	89 d8                	mov    %ebx,%eax
  80199b:	c1 e8 16             	shr    $0x16,%eax
  80199e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019a5:	a8 01                	test   $0x1,%al
  8019a7:	74 de                	je     801987 <spawn+0x427>
  8019a9:	89 d8                	mov    %ebx,%eax
  8019ab:	c1 e8 0c             	shr    $0xc,%eax
  8019ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019b5:	f6 c2 01             	test   $0x1,%dl
  8019b8:	74 cd                	je     801987 <spawn+0x427>
  8019ba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019c1:	f6 c6 04             	test   $0x4,%dh
  8019c4:	74 c1                	je     801987 <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  8019c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019cd:	83 ec 0c             	sub    $0xc,%esp
  8019d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8019d5:	50                   	push   %eax
  8019d6:	53                   	push   %ebx
  8019d7:	57                   	push   %edi
  8019d8:	53                   	push   %ebx
  8019d9:	56                   	push   %esi
  8019da:	e8 f0 f1 ff ff       	call   800bcf <sys_page_map>
  8019df:	83 c4 20             	add    $0x20,%esp
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	79 a1                	jns    801987 <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  8019e6:	50                   	push   %eax
  8019e7:	68 7f 28 80 00       	push   $0x80287f
  8019ec:	68 82 00 00 00       	push   $0x82
  8019f1:	68 25 28 80 00       	push   $0x802825
  8019f6:	e8 e0 e6 ff ff       	call   8000db <_panic>
		panic("sys_env_set_trapframe: %e", r);
  8019fb:	50                   	push   %eax
  8019fc:	68 4e 28 80 00       	push   $0x80284e
  801a01:	68 86 00 00 00       	push   $0x86
  801a06:	68 25 28 80 00       	push   $0x802825
  801a0b:	e8 cb e6 ff ff       	call   8000db <_panic>
		panic("sys_env_set_status: %e", r);
  801a10:	50                   	push   %eax
  801a11:	68 68 28 80 00       	push   $0x802868
  801a16:	68 89 00 00 00       	push   $0x89
  801a1b:	68 25 28 80 00       	push   $0x802825
  801a20:	e8 b6 e6 ff ff       	call   8000db <_panic>
		return r;
  801a25:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a2b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801a31:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801a37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5f                   	pop    %edi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    
  801a3f:	89 c7                	mov    %eax,%edi
  801a41:	e9 59 fe ff ff       	jmp    80189f <spawn+0x33f>
  801a46:	89 c7                	mov    %eax,%edi
  801a48:	e9 52 fe ff ff       	jmp    80189f <spawn+0x33f>
  801a4d:	89 c7                	mov    %eax,%edi
  801a4f:	e9 4b fe ff ff       	jmp    80189f <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801a54:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801a5b:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801a67:	50                   	push   %eax
  801a68:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801a6e:	e8 22 f2 ff ff       	call   800c95 <sys_env_set_trapframe>
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 81                	js     8019fb <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a7a:	83 ec 08             	sub    $0x8,%esp
  801a7d:	6a 02                	push   $0x2
  801a7f:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801a85:	e8 c9 f1 ff ff       	call   800c53 <sys_env_set_status>
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	0f 88 7b ff ff ff    	js     801a10 <spawn+0x4b0>
	return child;
  801a95:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a9b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801aa1:	eb 8e                	jmp    801a31 <spawn+0x4d1>
		return -E_NO_MEM;
  801aa3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801aa8:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801aae:	eb 81                	jmp    801a31 <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  801ab0:	83 ec 08             	sub    $0x8,%esp
  801ab3:	68 00 00 40 00       	push   $0x400000
  801ab8:	6a 00                	push   $0x0
  801aba:	e8 52 f1 ff ff       	call   800c11 <sys_page_unmap>
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801ac8:	e9 64 ff ff ff       	jmp    801a31 <spawn+0x4d1>

00801acd <spawnl>:
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
	va_start(vl, arg0);
  801ad2:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801ada:	eb 05                	jmp    801ae1 <spawnl+0x14>
		argc++;
  801adc:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801adf:	89 ca                	mov    %ecx,%edx
  801ae1:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ae4:	83 3a 00             	cmpl   $0x0,(%edx)
  801ae7:	75 f3                	jne    801adc <spawnl+0xf>
	const char *argv[argc+2];
  801ae9:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801af0:	89 d3                	mov    %edx,%ebx
  801af2:	83 e3 f0             	and    $0xfffffff0,%ebx
  801af5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801afb:	89 e1                	mov    %esp,%ecx
  801afd:	29 d1                	sub    %edx,%ecx
  801aff:	39 cc                	cmp    %ecx,%esp
  801b01:	74 10                	je     801b13 <spawnl+0x46>
  801b03:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801b09:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801b10:	00 
  801b11:	eb ec                	jmp    801aff <spawnl+0x32>
  801b13:	89 da                	mov    %ebx,%edx
  801b15:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801b1b:	29 d4                	sub    %edx,%esp
  801b1d:	85 d2                	test   %edx,%edx
  801b1f:	74 05                	je     801b26 <spawnl+0x59>
  801b21:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801b26:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801b2a:	89 da                	mov    %ebx,%edx
  801b2c:	c1 ea 02             	shr    $0x2,%edx
  801b2f:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b35:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b3c:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801b43:	00 
	va_start(vl, arg0);
  801b44:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801b47:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4e:	eb 0b                	jmp    801b5b <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801b50:	83 c0 01             	add    $0x1,%eax
  801b53:	8b 31                	mov    (%ecx),%esi
  801b55:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801b58:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801b5b:	39 d0                	cmp    %edx,%eax
  801b5d:	75 f1                	jne    801b50 <spawnl+0x83>
	return spawn(prog, argv);
  801b5f:	83 ec 08             	sub    $0x8,%esp
  801b62:	53                   	push   %ebx
  801b63:	ff 75 08             	push   0x8(%ebp)
  801b66:	e8 f5 f9 ff ff       	call   801560 <spawn>
}
  801b6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6e:	5b                   	pop    %ebx
  801b6f:	5e                   	pop    %esi
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	56                   	push   %esi
  801b76:	53                   	push   %ebx
  801b77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b7a:	83 ec 0c             	sub    $0xc,%esp
  801b7d:	ff 75 08             	push   0x8(%ebp)
  801b80:	e8 08 f2 ff ff       	call   800d8d <fd2data>
  801b85:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b87:	83 c4 08             	add    $0x8,%esp
  801b8a:	68 be 28 80 00       	push   $0x8028be
  801b8f:	53                   	push   %ebx
  801b90:	e8 fb eb ff ff       	call   800790 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b95:	8b 46 04             	mov    0x4(%esi),%eax
  801b98:	2b 06                	sub    (%esi),%eax
  801b9a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ba0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ba7:	00 00 00 
	stat->st_dev = &devpipe;
  801baa:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bb1:	30 80 00 
	return 0;
}
  801bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbc:	5b                   	pop    %ebx
  801bbd:	5e                   	pop    %esi
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 0c             	sub    $0xc,%esp
  801bc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bca:	53                   	push   %ebx
  801bcb:	6a 00                	push   $0x0
  801bcd:	e8 3f f0 ff ff       	call   800c11 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bd2:	89 1c 24             	mov    %ebx,(%esp)
  801bd5:	e8 b3 f1 ff ff       	call   800d8d <fd2data>
  801bda:	83 c4 08             	add    $0x8,%esp
  801bdd:	50                   	push   %eax
  801bde:	6a 00                	push   $0x0
  801be0:	e8 2c f0 ff ff       	call   800c11 <sys_page_unmap>
}
  801be5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    

00801bea <_pipeisclosed>:
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	57                   	push   %edi
  801bee:	56                   	push   %esi
  801bef:	53                   	push   %ebx
  801bf0:	83 ec 1c             	sub    $0x1c,%esp
  801bf3:	89 c7                	mov    %eax,%edi
  801bf5:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801bf7:	a1 00 40 80 00       	mov    0x804000,%eax
  801bfc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	57                   	push   %edi
  801c03:	e8 1c 05 00 00       	call   802124 <pageref>
  801c08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c0b:	89 34 24             	mov    %esi,(%esp)
  801c0e:	e8 11 05 00 00       	call   802124 <pageref>
		nn = thisenv->env_runs;
  801c13:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801c19:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	39 cb                	cmp    %ecx,%ebx
  801c21:	74 1b                	je     801c3e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c23:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c26:	75 cf                	jne    801bf7 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c28:	8b 42 58             	mov    0x58(%edx),%eax
  801c2b:	6a 01                	push   $0x1
  801c2d:	50                   	push   %eax
  801c2e:	53                   	push   %ebx
  801c2f:	68 c5 28 80 00       	push   $0x8028c5
  801c34:	e8 7d e5 ff ff       	call   8001b6 <cprintf>
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	eb b9                	jmp    801bf7 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c3e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c41:	0f 94 c0             	sete   %al
  801c44:	0f b6 c0             	movzbl %al,%eax
}
  801c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4a:	5b                   	pop    %ebx
  801c4b:	5e                   	pop    %esi
  801c4c:	5f                   	pop    %edi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <devpipe_write>:
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	57                   	push   %edi
  801c53:	56                   	push   %esi
  801c54:	53                   	push   %ebx
  801c55:	83 ec 28             	sub    $0x28,%esp
  801c58:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c5b:	56                   	push   %esi
  801c5c:	e8 2c f1 ff ff       	call   800d8d <fd2data>
  801c61:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	bf 00 00 00 00       	mov    $0x0,%edi
  801c6b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c6e:	75 09                	jne    801c79 <devpipe_write+0x2a>
	return i;
  801c70:	89 f8                	mov    %edi,%eax
  801c72:	eb 23                	jmp    801c97 <devpipe_write+0x48>
			sys_yield();
  801c74:	e8 f4 ee ff ff       	call   800b6d <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c79:	8b 43 04             	mov    0x4(%ebx),%eax
  801c7c:	8b 0b                	mov    (%ebx),%ecx
  801c7e:	8d 51 20             	lea    0x20(%ecx),%edx
  801c81:	39 d0                	cmp    %edx,%eax
  801c83:	72 1a                	jb     801c9f <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801c85:	89 da                	mov    %ebx,%edx
  801c87:	89 f0                	mov    %esi,%eax
  801c89:	e8 5c ff ff ff       	call   801bea <_pipeisclosed>
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	74 e2                	je     801c74 <devpipe_write+0x25>
				return 0;
  801c92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5f                   	pop    %edi
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ca6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ca9:	89 c2                	mov    %eax,%edx
  801cab:	c1 fa 1f             	sar    $0x1f,%edx
  801cae:	89 d1                	mov    %edx,%ecx
  801cb0:	c1 e9 1b             	shr    $0x1b,%ecx
  801cb3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cb6:	83 e2 1f             	and    $0x1f,%edx
  801cb9:	29 ca                	sub    %ecx,%edx
  801cbb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cbf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cc3:	83 c0 01             	add    $0x1,%eax
  801cc6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cc9:	83 c7 01             	add    $0x1,%edi
  801ccc:	eb 9d                	jmp    801c6b <devpipe_write+0x1c>

00801cce <devpipe_read>:
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 18             	sub    $0x18,%esp
  801cd7:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cda:	57                   	push   %edi
  801cdb:	e8 ad f0 ff ff       	call   800d8d <fd2data>
  801ce0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	be 00 00 00 00       	mov    $0x0,%esi
  801cea:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ced:	75 13                	jne    801d02 <devpipe_read+0x34>
	return i;
  801cef:	89 f0                	mov    %esi,%eax
  801cf1:	eb 02                	jmp    801cf5 <devpipe_read+0x27>
				return i;
  801cf3:	89 f0                	mov    %esi,%eax
}
  801cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf8:	5b                   	pop    %ebx
  801cf9:	5e                   	pop    %esi
  801cfa:	5f                   	pop    %edi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    
			sys_yield();
  801cfd:	e8 6b ee ff ff       	call   800b6d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d02:	8b 03                	mov    (%ebx),%eax
  801d04:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d07:	75 18                	jne    801d21 <devpipe_read+0x53>
			if (i > 0)
  801d09:	85 f6                	test   %esi,%esi
  801d0b:	75 e6                	jne    801cf3 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801d0d:	89 da                	mov    %ebx,%edx
  801d0f:	89 f8                	mov    %edi,%eax
  801d11:	e8 d4 fe ff ff       	call   801bea <_pipeisclosed>
  801d16:	85 c0                	test   %eax,%eax
  801d18:	74 e3                	je     801cfd <devpipe_read+0x2f>
				return 0;
  801d1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1f:	eb d4                	jmp    801cf5 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d21:	99                   	cltd   
  801d22:	c1 ea 1b             	shr    $0x1b,%edx
  801d25:	01 d0                	add    %edx,%eax
  801d27:	83 e0 1f             	and    $0x1f,%eax
  801d2a:	29 d0                	sub    %edx,%eax
  801d2c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d34:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d37:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d3a:	83 c6 01             	add    $0x1,%esi
  801d3d:	eb ab                	jmp    801cea <devpipe_read+0x1c>

00801d3f <pipe>:
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4a:	50                   	push   %eax
  801d4b:	e8 54 f0 ff ff       	call   800da4 <fd_alloc>
  801d50:	89 c3                	mov    %eax,%ebx
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	85 c0                	test   %eax,%eax
  801d57:	0f 88 23 01 00 00    	js     801e80 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5d:	83 ec 04             	sub    $0x4,%esp
  801d60:	68 07 04 00 00       	push   $0x407
  801d65:	ff 75 f4             	push   -0xc(%ebp)
  801d68:	6a 00                	push   $0x0
  801d6a:	e8 1d ee ff ff       	call   800b8c <sys_page_alloc>
  801d6f:	89 c3                	mov    %eax,%ebx
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	85 c0                	test   %eax,%eax
  801d76:	0f 88 04 01 00 00    	js     801e80 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801d7c:	83 ec 0c             	sub    $0xc,%esp
  801d7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d82:	50                   	push   %eax
  801d83:	e8 1c f0 ff ff       	call   800da4 <fd_alloc>
  801d88:	89 c3                	mov    %eax,%ebx
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	0f 88 db 00 00 00    	js     801e70 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d95:	83 ec 04             	sub    $0x4,%esp
  801d98:	68 07 04 00 00       	push   $0x407
  801d9d:	ff 75 f0             	push   -0x10(%ebp)
  801da0:	6a 00                	push   $0x0
  801da2:	e8 e5 ed ff ff       	call   800b8c <sys_page_alloc>
  801da7:	89 c3                	mov    %eax,%ebx
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	0f 88 bc 00 00 00    	js     801e70 <pipe+0x131>
	va = fd2data(fd0);
  801db4:	83 ec 0c             	sub    $0xc,%esp
  801db7:	ff 75 f4             	push   -0xc(%ebp)
  801dba:	e8 ce ef ff ff       	call   800d8d <fd2data>
  801dbf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc1:	83 c4 0c             	add    $0xc,%esp
  801dc4:	68 07 04 00 00       	push   $0x407
  801dc9:	50                   	push   %eax
  801dca:	6a 00                	push   $0x0
  801dcc:	e8 bb ed ff ff       	call   800b8c <sys_page_alloc>
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	0f 88 82 00 00 00    	js     801e60 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	ff 75 f0             	push   -0x10(%ebp)
  801de4:	e8 a4 ef ff ff       	call   800d8d <fd2data>
  801de9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801df0:	50                   	push   %eax
  801df1:	6a 00                	push   $0x0
  801df3:	56                   	push   %esi
  801df4:	6a 00                	push   $0x0
  801df6:	e8 d4 ed ff ff       	call   800bcf <sys_page_map>
  801dfb:	89 c3                	mov    %eax,%ebx
  801dfd:	83 c4 20             	add    $0x20,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 4e                	js     801e52 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801e04:	a1 20 30 80 00       	mov    0x803020,%eax
  801e09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e0c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e11:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e1b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e20:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e27:	83 ec 0c             	sub    $0xc,%esp
  801e2a:	ff 75 f4             	push   -0xc(%ebp)
  801e2d:	e8 4b ef ff ff       	call   800d7d <fd2num>
  801e32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e35:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e37:	83 c4 04             	add    $0x4,%esp
  801e3a:	ff 75 f0             	push   -0x10(%ebp)
  801e3d:	e8 3b ef ff ff       	call   800d7d <fd2num>
  801e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e45:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e48:	83 c4 10             	add    $0x10,%esp
  801e4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e50:	eb 2e                	jmp    801e80 <pipe+0x141>
	sys_page_unmap(0, va);
  801e52:	83 ec 08             	sub    $0x8,%esp
  801e55:	56                   	push   %esi
  801e56:	6a 00                	push   $0x0
  801e58:	e8 b4 ed ff ff       	call   800c11 <sys_page_unmap>
  801e5d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e60:	83 ec 08             	sub    $0x8,%esp
  801e63:	ff 75 f0             	push   -0x10(%ebp)
  801e66:	6a 00                	push   $0x0
  801e68:	e8 a4 ed ff ff       	call   800c11 <sys_page_unmap>
  801e6d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e70:	83 ec 08             	sub    $0x8,%esp
  801e73:	ff 75 f4             	push   -0xc(%ebp)
  801e76:	6a 00                	push   $0x0
  801e78:	e8 94 ed ff ff       	call   800c11 <sys_page_unmap>
  801e7d:	83 c4 10             	add    $0x10,%esp
}
  801e80:	89 d8                	mov    %ebx,%eax
  801e82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e85:	5b                   	pop    %ebx
  801e86:	5e                   	pop    %esi
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    

00801e89 <pipeisclosed>:
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e92:	50                   	push   %eax
  801e93:	ff 75 08             	push   0x8(%ebp)
  801e96:	e8 59 ef ff ff       	call   800df4 <fd_lookup>
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 18                	js     801eba <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801ea2:	83 ec 0c             	sub    $0xc,%esp
  801ea5:	ff 75 f4             	push   -0xc(%ebp)
  801ea8:	e8 e0 ee ff ff       	call   800d8d <fd2data>
  801ead:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb2:	e8 33 fd ff ff       	call   801bea <_pipeisclosed>
  801eb7:	83 c4 10             	add    $0x10,%esp
}
  801eba:	c9                   	leave  
  801ebb:	c3                   	ret    

00801ebc <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801ebc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec1:	c3                   	ret    

00801ec2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ec8:	68 dd 28 80 00       	push   $0x8028dd
  801ecd:	ff 75 0c             	push   0xc(%ebp)
  801ed0:	e8 bb e8 ff ff       	call   800790 <strcpy>
	return 0;
}
  801ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eda:	c9                   	leave  
  801edb:	c3                   	ret    

00801edc <devcons_write>:
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	57                   	push   %edi
  801ee0:	56                   	push   %esi
  801ee1:	53                   	push   %ebx
  801ee2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ee8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801eed:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ef3:	eb 2e                	jmp    801f23 <devcons_write+0x47>
		m = n - tot;
  801ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ef8:	29 f3                	sub    %esi,%ebx
  801efa:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801eff:	39 c3                	cmp    %eax,%ebx
  801f01:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f04:	83 ec 04             	sub    $0x4,%esp
  801f07:	53                   	push   %ebx
  801f08:	89 f0                	mov    %esi,%eax
  801f0a:	03 45 0c             	add    0xc(%ebp),%eax
  801f0d:	50                   	push   %eax
  801f0e:	57                   	push   %edi
  801f0f:	e8 12 ea ff ff       	call   800926 <memmove>
		sys_cputs(buf, m);
  801f14:	83 c4 08             	add    $0x8,%esp
  801f17:	53                   	push   %ebx
  801f18:	57                   	push   %edi
  801f19:	e8 b2 eb ff ff       	call   800ad0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f1e:	01 de                	add    %ebx,%esi
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f26:	72 cd                	jb     801ef5 <devcons_write+0x19>
}
  801f28:	89 f0                	mov    %esi,%eax
  801f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5f                   	pop    %edi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <devcons_read>:
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 08             	sub    $0x8,%esp
  801f38:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f41:	75 07                	jne    801f4a <devcons_read+0x18>
  801f43:	eb 1f                	jmp    801f64 <devcons_read+0x32>
		sys_yield();
  801f45:	e8 23 ec ff ff       	call   800b6d <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f4a:	e8 9f eb ff ff       	call   800aee <sys_cgetc>
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	74 f2                	je     801f45 <devcons_read+0x13>
	if (c < 0)
  801f53:	78 0f                	js     801f64 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801f55:	83 f8 04             	cmp    $0x4,%eax
  801f58:	74 0c                	je     801f66 <devcons_read+0x34>
	*(char*)vbuf = c;
  801f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f5d:	88 02                	mov    %al,(%edx)
	return 1;
  801f5f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f64:	c9                   	leave  
  801f65:	c3                   	ret    
		return 0;
  801f66:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6b:	eb f7                	jmp    801f64 <devcons_read+0x32>

00801f6d <cputchar>:
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f73:	8b 45 08             	mov    0x8(%ebp),%eax
  801f76:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f79:	6a 01                	push   $0x1
  801f7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f7e:	50                   	push   %eax
  801f7f:	e8 4c eb ff ff       	call   800ad0 <sys_cputs>
}
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	c9                   	leave  
  801f88:	c3                   	ret    

00801f89 <getchar>:
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f8f:	6a 01                	push   $0x1
  801f91:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f94:	50                   	push   %eax
  801f95:	6a 00                	push   $0x0
  801f97:	e8 bc f0 ff ff       	call   801058 <read>
	if (r < 0)
  801f9c:	83 c4 10             	add    $0x10,%esp
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	78 06                	js     801fa9 <getchar+0x20>
	if (r < 1)
  801fa3:	74 06                	je     801fab <getchar+0x22>
	return c;
  801fa5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    
		return -E_EOF;
  801fab:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fb0:	eb f7                	jmp    801fa9 <getchar+0x20>

00801fb2 <iscons>:
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbb:	50                   	push   %eax
  801fbc:	ff 75 08             	push   0x8(%ebp)
  801fbf:	e8 30 ee ff ff       	call   800df4 <fd_lookup>
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	78 11                	js     801fdc <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd4:	39 10                	cmp    %edx,(%eax)
  801fd6:	0f 94 c0             	sete   %al
  801fd9:	0f b6 c0             	movzbl %al,%eax
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <opencons>:
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe7:	50                   	push   %eax
  801fe8:	e8 b7 ed ff ff       	call   800da4 <fd_alloc>
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	85 c0                	test   %eax,%eax
  801ff2:	78 3a                	js     80202e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff4:	83 ec 04             	sub    $0x4,%esp
  801ff7:	68 07 04 00 00       	push   $0x407
  801ffc:	ff 75 f4             	push   -0xc(%ebp)
  801fff:	6a 00                	push   $0x0
  802001:	e8 86 eb ff ff       	call   800b8c <sys_page_alloc>
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	85 c0                	test   %eax,%eax
  80200b:	78 21                	js     80202e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80200d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802010:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802016:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802022:	83 ec 0c             	sub    $0xc,%esp
  802025:	50                   	push   %eax
  802026:	e8 52 ed ff ff       	call   800d7d <fd2num>
  80202b:	83 c4 10             	add    $0x10,%esp
}
  80202e:	c9                   	leave  
  80202f:	c3                   	ret    

00802030 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	56                   	push   %esi
  802034:	53                   	push   %ebx
  802035:	8b 75 08             	mov    0x8(%ebp),%esi
  802038:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80203e:	85 c0                	test   %eax,%eax
  802040:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802045:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802048:	83 ec 0c             	sub    $0xc,%esp
  80204b:	50                   	push   %eax
  80204c:	e8 eb ec ff ff       	call   800d3c <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802051:	83 c4 10             	add    $0x10,%esp
  802054:	85 f6                	test   %esi,%esi
  802056:	74 14                	je     80206c <ipc_recv+0x3c>
  802058:	ba 00 00 00 00       	mov    $0x0,%edx
  80205d:	85 c0                	test   %eax,%eax
  80205f:	78 09                	js     80206a <ipc_recv+0x3a>
  802061:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802067:	8b 52 74             	mov    0x74(%edx),%edx
  80206a:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80206c:	85 db                	test   %ebx,%ebx
  80206e:	74 14                	je     802084 <ipc_recv+0x54>
  802070:	ba 00 00 00 00       	mov    $0x0,%edx
  802075:	85 c0                	test   %eax,%eax
  802077:	78 09                	js     802082 <ipc_recv+0x52>
  802079:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80207f:	8b 52 78             	mov    0x78(%edx),%edx
  802082:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802084:	85 c0                	test   %eax,%eax
  802086:	78 08                	js     802090 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802088:	a1 00 40 80 00       	mov    0x804000,%eax
  80208d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    

00802097 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	57                   	push   %edi
  80209b:	56                   	push   %esi
  80209c:	53                   	push   %ebx
  80209d:	83 ec 0c             	sub    $0xc,%esp
  8020a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8020a9:	85 db                	test   %ebx,%ebx
  8020ab:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020b0:	0f 44 d8             	cmove  %eax,%ebx
  8020b3:	eb 05                	jmp    8020ba <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8020b5:	e8 b3 ea ff ff       	call   800b6d <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8020ba:	ff 75 14             	push   0x14(%ebp)
  8020bd:	53                   	push   %ebx
  8020be:	56                   	push   %esi
  8020bf:	57                   	push   %edi
  8020c0:	e8 54 ec ff ff       	call   800d19 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8020c5:	83 c4 10             	add    $0x10,%esp
  8020c8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020cb:	74 e8                	je     8020b5 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 08                	js     8020d9 <ipc_send+0x42>
	}while (r<0);

}
  8020d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8020d9:	50                   	push   %eax
  8020da:	68 e9 28 80 00       	push   $0x8028e9
  8020df:	6a 3d                	push   $0x3d
  8020e1:	68 fd 28 80 00       	push   $0x8028fd
  8020e6:	e8 f0 df ff ff       	call   8000db <_panic>

008020eb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020f1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020f6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020f9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ff:	8b 52 50             	mov    0x50(%edx),%edx
  802102:	39 ca                	cmp    %ecx,%edx
  802104:	74 11                	je     802117 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802106:	83 c0 01             	add    $0x1,%eax
  802109:	3d 00 04 00 00       	cmp    $0x400,%eax
  80210e:	75 e6                	jne    8020f6 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802110:	b8 00 00 00 00       	mov    $0x0,%eax
  802115:	eb 0b                	jmp    802122 <ipc_find_env+0x37>
			return envs[i].env_id;
  802117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80211a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80211f:	8b 40 48             	mov    0x48(%eax),%eax
}
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212a:	89 c2                	mov    %eax,%edx
  80212c:	c1 ea 16             	shr    $0x16,%edx
  80212f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802136:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80213b:	f6 c1 01             	test   $0x1,%cl
  80213e:	74 1c                	je     80215c <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802140:	c1 e8 0c             	shr    $0xc,%eax
  802143:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80214a:	a8 01                	test   $0x1,%al
  80214c:	74 0e                	je     80215c <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80214e:	c1 e8 0c             	shr    $0xc,%eax
  802151:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802158:	ef 
  802159:	0f b7 d2             	movzwl %dx,%edx
}
  80215c:	89 d0                	mov    %edx,%eax
  80215e:	5d                   	pop    %ebp
  80215f:	c3                   	ret    

00802160 <__udivdi3>:
  802160:	f3 0f 1e fb          	endbr32 
  802164:	55                   	push   %ebp
  802165:	57                   	push   %edi
  802166:	56                   	push   %esi
  802167:	53                   	push   %ebx
  802168:	83 ec 1c             	sub    $0x1c,%esp
  80216b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80216f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802173:	8b 74 24 34          	mov    0x34(%esp),%esi
  802177:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80217b:	85 c0                	test   %eax,%eax
  80217d:	75 19                	jne    802198 <__udivdi3+0x38>
  80217f:	39 f3                	cmp    %esi,%ebx
  802181:	76 4d                	jbe    8021d0 <__udivdi3+0x70>
  802183:	31 ff                	xor    %edi,%edi
  802185:	89 e8                	mov    %ebp,%eax
  802187:	89 f2                	mov    %esi,%edx
  802189:	f7 f3                	div    %ebx
  80218b:	89 fa                	mov    %edi,%edx
  80218d:	83 c4 1c             	add    $0x1c,%esp
  802190:	5b                   	pop    %ebx
  802191:	5e                   	pop    %esi
  802192:	5f                   	pop    %edi
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    
  802195:	8d 76 00             	lea    0x0(%esi),%esi
  802198:	39 f0                	cmp    %esi,%eax
  80219a:	76 14                	jbe    8021b0 <__udivdi3+0x50>
  80219c:	31 ff                	xor    %edi,%edi
  80219e:	31 c0                	xor    %eax,%eax
  8021a0:	89 fa                	mov    %edi,%edx
  8021a2:	83 c4 1c             	add    $0x1c,%esp
  8021a5:	5b                   	pop    %ebx
  8021a6:	5e                   	pop    %esi
  8021a7:	5f                   	pop    %edi
  8021a8:	5d                   	pop    %ebp
  8021a9:	c3                   	ret    
  8021aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b0:	0f bd f8             	bsr    %eax,%edi
  8021b3:	83 f7 1f             	xor    $0x1f,%edi
  8021b6:	75 48                	jne    802200 <__udivdi3+0xa0>
  8021b8:	39 f0                	cmp    %esi,%eax
  8021ba:	72 06                	jb     8021c2 <__udivdi3+0x62>
  8021bc:	31 c0                	xor    %eax,%eax
  8021be:	39 eb                	cmp    %ebp,%ebx
  8021c0:	77 de                	ja     8021a0 <__udivdi3+0x40>
  8021c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c7:	eb d7                	jmp    8021a0 <__udivdi3+0x40>
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d9                	mov    %ebx,%ecx
  8021d2:	85 db                	test   %ebx,%ebx
  8021d4:	75 0b                	jne    8021e1 <__udivdi3+0x81>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f3                	div    %ebx
  8021df:	89 c1                	mov    %eax,%ecx
  8021e1:	31 d2                	xor    %edx,%edx
  8021e3:	89 f0                	mov    %esi,%eax
  8021e5:	f7 f1                	div    %ecx
  8021e7:	89 c6                	mov    %eax,%esi
  8021e9:	89 e8                	mov    %ebp,%eax
  8021eb:	89 f7                	mov    %esi,%edi
  8021ed:	f7 f1                	div    %ecx
  8021ef:	89 fa                	mov    %edi,%edx
  8021f1:	83 c4 1c             	add    $0x1c,%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 f9                	mov    %edi,%ecx
  802202:	ba 20 00 00 00       	mov    $0x20,%edx
  802207:	29 fa                	sub    %edi,%edx
  802209:	d3 e0                	shl    %cl,%eax
  80220b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80220f:	89 d1                	mov    %edx,%ecx
  802211:	89 d8                	mov    %ebx,%eax
  802213:	d3 e8                	shr    %cl,%eax
  802215:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802219:	09 c1                	or     %eax,%ecx
  80221b:	89 f0                	mov    %esi,%eax
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f9                	mov    %edi,%ecx
  802223:	d3 e3                	shl    %cl,%ebx
  802225:	89 d1                	mov    %edx,%ecx
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 f9                	mov    %edi,%ecx
  80222b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80222f:	89 eb                	mov    %ebp,%ebx
  802231:	d3 e6                	shl    %cl,%esi
  802233:	89 d1                	mov    %edx,%ecx
  802235:	d3 eb                	shr    %cl,%ebx
  802237:	09 f3                	or     %esi,%ebx
  802239:	89 c6                	mov    %eax,%esi
  80223b:	89 f2                	mov    %esi,%edx
  80223d:	89 d8                	mov    %ebx,%eax
  80223f:	f7 74 24 08          	divl   0x8(%esp)
  802243:	89 d6                	mov    %edx,%esi
  802245:	89 c3                	mov    %eax,%ebx
  802247:	f7 64 24 0c          	mull   0xc(%esp)
  80224b:	39 d6                	cmp    %edx,%esi
  80224d:	72 19                	jb     802268 <__udivdi3+0x108>
  80224f:	89 f9                	mov    %edi,%ecx
  802251:	d3 e5                	shl    %cl,%ebp
  802253:	39 c5                	cmp    %eax,%ebp
  802255:	73 04                	jae    80225b <__udivdi3+0xfb>
  802257:	39 d6                	cmp    %edx,%esi
  802259:	74 0d                	je     802268 <__udivdi3+0x108>
  80225b:	89 d8                	mov    %ebx,%eax
  80225d:	31 ff                	xor    %edi,%edi
  80225f:	e9 3c ff ff ff       	jmp    8021a0 <__udivdi3+0x40>
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80226b:	31 ff                	xor    %edi,%edi
  80226d:	e9 2e ff ff ff       	jmp    8021a0 <__udivdi3+0x40>
  802272:	66 90                	xchg   %ax,%ax
  802274:	66 90                	xchg   %ax,%ax
  802276:	66 90                	xchg   %ax,%ax
  802278:	66 90                	xchg   %ax,%ax
  80227a:	66 90                	xchg   %ax,%ax
  80227c:	66 90                	xchg   %ax,%ax
  80227e:	66 90                	xchg   %ax,%ax

00802280 <__umoddi3>:
  802280:	f3 0f 1e fb          	endbr32 
  802284:	55                   	push   %ebp
  802285:	57                   	push   %edi
  802286:	56                   	push   %esi
  802287:	53                   	push   %ebx
  802288:	83 ec 1c             	sub    $0x1c,%esp
  80228b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80228f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802293:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802297:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80229b:	89 f0                	mov    %esi,%eax
  80229d:	89 da                	mov    %ebx,%edx
  80229f:	85 ff                	test   %edi,%edi
  8022a1:	75 15                	jne    8022b8 <__umoddi3+0x38>
  8022a3:	39 dd                	cmp    %ebx,%ebp
  8022a5:	76 39                	jbe    8022e0 <__umoddi3+0x60>
  8022a7:	f7 f5                	div    %ebp
  8022a9:	89 d0                	mov    %edx,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	83 c4 1c             	add    $0x1c,%esp
  8022b0:	5b                   	pop    %ebx
  8022b1:	5e                   	pop    %esi
  8022b2:	5f                   	pop    %edi
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    
  8022b5:	8d 76 00             	lea    0x0(%esi),%esi
  8022b8:	39 df                	cmp    %ebx,%edi
  8022ba:	77 f1                	ja     8022ad <__umoddi3+0x2d>
  8022bc:	0f bd cf             	bsr    %edi,%ecx
  8022bf:	83 f1 1f             	xor    $0x1f,%ecx
  8022c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8022c6:	75 40                	jne    802308 <__umoddi3+0x88>
  8022c8:	39 df                	cmp    %ebx,%edi
  8022ca:	72 04                	jb     8022d0 <__umoddi3+0x50>
  8022cc:	39 f5                	cmp    %esi,%ebp
  8022ce:	77 dd                	ja     8022ad <__umoddi3+0x2d>
  8022d0:	89 da                	mov    %ebx,%edx
  8022d2:	89 f0                	mov    %esi,%eax
  8022d4:	29 e8                	sub    %ebp,%eax
  8022d6:	19 fa                	sbb    %edi,%edx
  8022d8:	eb d3                	jmp    8022ad <__umoddi3+0x2d>
  8022da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e0:	89 e9                	mov    %ebp,%ecx
  8022e2:	85 ed                	test   %ebp,%ebp
  8022e4:	75 0b                	jne    8022f1 <__umoddi3+0x71>
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f5                	div    %ebp
  8022ef:	89 c1                	mov    %eax,%ecx
  8022f1:	89 d8                	mov    %ebx,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f1                	div    %ecx
  8022f7:	89 f0                	mov    %esi,%eax
  8022f9:	f7 f1                	div    %ecx
  8022fb:	89 d0                	mov    %edx,%eax
  8022fd:	31 d2                	xor    %edx,%edx
  8022ff:	eb ac                	jmp    8022ad <__umoddi3+0x2d>
  802301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802308:	8b 44 24 04          	mov    0x4(%esp),%eax
  80230c:	ba 20 00 00 00       	mov    $0x20,%edx
  802311:	29 c2                	sub    %eax,%edx
  802313:	89 c1                	mov    %eax,%ecx
  802315:	89 e8                	mov    %ebp,%eax
  802317:	d3 e7                	shl    %cl,%edi
  802319:	89 d1                	mov    %edx,%ecx
  80231b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80231f:	d3 e8                	shr    %cl,%eax
  802321:	89 c1                	mov    %eax,%ecx
  802323:	8b 44 24 04          	mov    0x4(%esp),%eax
  802327:	09 f9                	or     %edi,%ecx
  802329:	89 df                	mov    %ebx,%edi
  80232b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232f:	89 c1                	mov    %eax,%ecx
  802331:	d3 e5                	shl    %cl,%ebp
  802333:	89 d1                	mov    %edx,%ecx
  802335:	d3 ef                	shr    %cl,%edi
  802337:	89 c1                	mov    %eax,%ecx
  802339:	89 f0                	mov    %esi,%eax
  80233b:	d3 e3                	shl    %cl,%ebx
  80233d:	89 d1                	mov    %edx,%ecx
  80233f:	89 fa                	mov    %edi,%edx
  802341:	d3 e8                	shr    %cl,%eax
  802343:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802348:	09 d8                	or     %ebx,%eax
  80234a:	f7 74 24 08          	divl   0x8(%esp)
  80234e:	89 d3                	mov    %edx,%ebx
  802350:	d3 e6                	shl    %cl,%esi
  802352:	f7 e5                	mul    %ebp
  802354:	89 c7                	mov    %eax,%edi
  802356:	89 d1                	mov    %edx,%ecx
  802358:	39 d3                	cmp    %edx,%ebx
  80235a:	72 06                	jb     802362 <__umoddi3+0xe2>
  80235c:	75 0e                	jne    80236c <__umoddi3+0xec>
  80235e:	39 c6                	cmp    %eax,%esi
  802360:	73 0a                	jae    80236c <__umoddi3+0xec>
  802362:	29 e8                	sub    %ebp,%eax
  802364:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802368:	89 d1                	mov    %edx,%ecx
  80236a:	89 c7                	mov    %eax,%edi
  80236c:	89 f5                	mov    %esi,%ebp
  80236e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802372:	29 fd                	sub    %edi,%ebp
  802374:	19 cb                	sbb    %ecx,%ebx
  802376:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80237b:	89 d8                	mov    %ebx,%eax
  80237d:	d3 e0                	shl    %cl,%eax
  80237f:	89 f1                	mov    %esi,%ecx
  802381:	d3 ed                	shr    %cl,%ebp
  802383:	d3 eb                	shr    %cl,%ebx
  802385:	09 e8                	or     %ebp,%eax
  802387:	89 da                	mov    %ebx,%edx
  802389:	83 c4 1c             	add    $0x1c,%esp
  80238c:	5b                   	pop    %ebx
  80238d:	5e                   	pop    %esi
  80238e:	5f                   	pop    %edi
  80238f:	5d                   	pop    %ebp
  802390:	c3                   	ret    
