
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
  80003e:	8b 40 58             	mov    0x58(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 a0 28 80 00       	push   $0x8028a0
  800047:	e8 6d 01 00 00       	call   8001b9 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 be 28 80 00       	push   $0x8028be
  800056:	68 be 28 80 00       	push   $0x8028be
  80005b:	e8 d9 1a 00 00       	call   801b39 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	78 02                	js     800069 <umain+0x36>
		panic("spawn(hello) failed: %e", r);
}
  800067:	c9                   	leave  
  800068:	c3                   	ret    
		panic("spawn(hello) failed: %e", r);
  800069:	50                   	push   %eax
  80006a:	68 c4 28 80 00       	push   $0x8028c4
  80006f:	6a 09                	push   $0x9
  800071:	68 dc 28 80 00       	push   $0x8028dc
  800076:	e8 63 00 00 00       	call   8000de <_panic>

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
  800086:	e8 c6 0a 00 00       	call   800b51 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800096:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009b:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a0:	85 db                	test   %ebx,%ebx
  8000a2:	7e 07                	jle    8000ab <libmain+0x30>
		binaryname = argv[0];
  8000a4:	8b 06                	mov    (%esi),%eax
  8000a6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
  8000b0:	e8 7e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b5:	e8 0a 00 00 00       	call   8000c4 <exit>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ca:	e8 e3 0e 00 00       	call   800fb2 <close_all>
	sys_env_destroy(0);
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	6a 00                	push   $0x0
  8000d4:	e8 37 0a 00 00       	call   800b10 <sys_env_destroy>
}
  8000d9:	83 c4 10             	add    $0x10,%esp
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    

008000de <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000ec:	e8 60 0a 00 00       	call   800b51 <sys_getenvid>
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	ff 75 0c             	push   0xc(%ebp)
  8000f7:	ff 75 08             	push   0x8(%ebp)
  8000fa:	56                   	push   %esi
  8000fb:	50                   	push   %eax
  8000fc:	68 f8 28 80 00       	push   $0x8028f8
  800101:	e8 b3 00 00 00       	call   8001b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800106:	83 c4 18             	add    $0x18,%esp
  800109:	53                   	push   %ebx
  80010a:	ff 75 10             	push   0x10(%ebp)
  80010d:	e8 56 00 00 00       	call   800168 <vcprintf>
	cprintf("\n");
  800112:	c7 04 24 13 2e 80 00 	movl   $0x802e13,(%esp)
  800119:	e8 9b 00 00 00       	call   8001b9 <cprintf>
  80011e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800121:	cc                   	int3   
  800122:	eb fd                	jmp    800121 <_panic+0x43>

00800124 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	53                   	push   %ebx
  800128:	83 ec 04             	sub    $0x4,%esp
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012e:	8b 13                	mov    (%ebx),%edx
  800130:	8d 42 01             	lea    0x1(%edx),%eax
  800133:	89 03                	mov    %eax,(%ebx)
  800135:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800138:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800141:	74 09                	je     80014c <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800143:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800147:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80014c:	83 ec 08             	sub    $0x8,%esp
  80014f:	68 ff 00 00 00       	push   $0xff
  800154:	8d 43 08             	lea    0x8(%ebx),%eax
  800157:	50                   	push   %eax
  800158:	e8 76 09 00 00       	call   800ad3 <sys_cputs>
		b->idx = 0;
  80015d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800163:	83 c4 10             	add    $0x10,%esp
  800166:	eb db                	jmp    800143 <putch+0x1f>

00800168 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800171:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800178:	00 00 00 
	b.cnt = 0;
  80017b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800182:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800185:	ff 75 0c             	push   0xc(%ebp)
  800188:	ff 75 08             	push   0x8(%ebp)
  80018b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800191:	50                   	push   %eax
  800192:	68 24 01 80 00       	push   $0x800124
  800197:	e8 14 01 00 00       	call   8002b0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019c:	83 c4 08             	add    $0x8,%esp
  80019f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ab:	50                   	push   %eax
  8001ac:	e8 22 09 00 00       	call   800ad3 <sys_cputs>

	return b.cnt;
}
  8001b1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c2:	50                   	push   %eax
  8001c3:	ff 75 08             	push   0x8(%ebp)
  8001c6:	e8 9d ff ff ff       	call   800168 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 1c             	sub    $0x1c,%esp
  8001d6:	89 c7                	mov    %eax,%edi
  8001d8:	89 d6                	mov    %edx,%esi
  8001da:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e0:	89 d1                	mov    %edx,%ecx
  8001e2:	89 c2                	mov    %eax,%edx
  8001e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001fa:	39 c2                	cmp    %eax,%edx
  8001fc:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ff:	72 3e                	jb     80023f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800201:	83 ec 0c             	sub    $0xc,%esp
  800204:	ff 75 18             	push   0x18(%ebp)
  800207:	83 eb 01             	sub    $0x1,%ebx
  80020a:	53                   	push   %ebx
  80020b:	50                   	push   %eax
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	ff 75 e4             	push   -0x1c(%ebp)
  800212:	ff 75 e0             	push   -0x20(%ebp)
  800215:	ff 75 dc             	push   -0x24(%ebp)
  800218:	ff 75 d8             	push   -0x28(%ebp)
  80021b:	e8 30 24 00 00       	call   802650 <__udivdi3>
  800220:	83 c4 18             	add    $0x18,%esp
  800223:	52                   	push   %edx
  800224:	50                   	push   %eax
  800225:	89 f2                	mov    %esi,%edx
  800227:	89 f8                	mov    %edi,%eax
  800229:	e8 9f ff ff ff       	call   8001cd <printnum>
  80022e:	83 c4 20             	add    $0x20,%esp
  800231:	eb 13                	jmp    800246 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	ff 75 18             	push   0x18(%ebp)
  80023a:	ff d7                	call   *%edi
  80023c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023f:	83 eb 01             	sub    $0x1,%ebx
  800242:	85 db                	test   %ebx,%ebx
  800244:	7f ed                	jg     800233 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	56                   	push   %esi
  80024a:	83 ec 04             	sub    $0x4,%esp
  80024d:	ff 75 e4             	push   -0x1c(%ebp)
  800250:	ff 75 e0             	push   -0x20(%ebp)
  800253:	ff 75 dc             	push   -0x24(%ebp)
  800256:	ff 75 d8             	push   -0x28(%ebp)
  800259:	e8 12 25 00 00       	call   802770 <__umoddi3>
  80025e:	83 c4 14             	add    $0x14,%esp
  800261:	0f be 80 1b 29 80 00 	movsbl 0x80291b(%eax),%eax
  800268:	50                   	push   %eax
  800269:	ff d7                	call   *%edi
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800280:	8b 10                	mov    (%eax),%edx
  800282:	3b 50 04             	cmp    0x4(%eax),%edx
  800285:	73 0a                	jae    800291 <sprintputch+0x1b>
		*b->buf++ = ch;
  800287:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	88 02                	mov    %al,(%edx)
}
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <printfmt>:
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800299:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029c:	50                   	push   %eax
  80029d:	ff 75 10             	push   0x10(%ebp)
  8002a0:	ff 75 0c             	push   0xc(%ebp)
  8002a3:	ff 75 08             	push   0x8(%ebp)
  8002a6:	e8 05 00 00 00       	call   8002b0 <vprintfmt>
}
  8002ab:	83 c4 10             	add    $0x10,%esp
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <vprintfmt>:
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 3c             	sub    $0x3c,%esp
  8002b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bf:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c2:	eb 0a                	jmp    8002ce <vprintfmt+0x1e>
			putch(ch, putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	53                   	push   %ebx
  8002c8:	50                   	push   %eax
  8002c9:	ff d6                	call   *%esi
  8002cb:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ce:	83 c7 01             	add    $0x1,%edi
  8002d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d5:	83 f8 25             	cmp    $0x25,%eax
  8002d8:	74 0c                	je     8002e6 <vprintfmt+0x36>
			if (ch == '\0')
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	75 e6                	jne    8002c4 <vprintfmt+0x14>
}
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    
		padc = ' ';
  8002e6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002ea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002f1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ff:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8d 47 01             	lea    0x1(%edi),%eax
  800307:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030a:	0f b6 17             	movzbl (%edi),%edx
  80030d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800310:	3c 55                	cmp    $0x55,%al
  800312:	0f 87 bb 03 00 00    	ja     8006d3 <vprintfmt+0x423>
  800318:	0f b6 c0             	movzbl %al,%eax
  80031b:	ff 24 85 60 2a 80 00 	jmp    *0x802a60(,%eax,4)
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800325:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800329:	eb d9                	jmp    800304 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800332:	eb d0                	jmp    800304 <vprintfmt+0x54>
  800334:	0f b6 d2             	movzbl %dl,%edx
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80033a:	b8 00 00 00 00       	mov    $0x0,%eax
  80033f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800342:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800345:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800349:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80034c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034f:	83 f9 09             	cmp    $0x9,%ecx
  800352:	77 55                	ja     8003a9 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800354:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800357:	eb e9                	jmp    800342 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8b 00                	mov    (%eax),%eax
  80035e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8d 40 04             	lea    0x4(%eax),%eax
  800367:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80036d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800371:	79 91                	jns    800304 <vprintfmt+0x54>
				width = precision, precision = -1;
  800373:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800376:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800379:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800380:	eb 82                	jmp    800304 <vprintfmt+0x54>
  800382:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800385:	85 d2                	test   %edx,%edx
  800387:	b8 00 00 00 00       	mov    $0x0,%eax
  80038c:	0f 49 c2             	cmovns %edx,%eax
  80038f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800395:	e9 6a ff ff ff       	jmp    800304 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80039d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a4:	e9 5b ff ff ff       	jmp    800304 <vprintfmt+0x54>
  8003a9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003af:	eb bc                	jmp    80036d <vprintfmt+0xbd>
			lflag++;
  8003b1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b7:	e9 48 ff ff ff       	jmp    800304 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8d 78 04             	lea    0x4(%eax),%edi
  8003c2:	83 ec 08             	sub    $0x8,%esp
  8003c5:	53                   	push   %ebx
  8003c6:	ff 30                	push   (%eax)
  8003c8:	ff d6                	call   *%esi
			break;
  8003ca:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003cd:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d0:	e9 9d 02 00 00       	jmp    800672 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d8:	8d 78 04             	lea    0x4(%eax),%edi
  8003db:	8b 10                	mov    (%eax),%edx
  8003dd:	89 d0                	mov    %edx,%eax
  8003df:	f7 d8                	neg    %eax
  8003e1:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e4:	83 f8 0f             	cmp    $0xf,%eax
  8003e7:	7f 23                	jg     80040c <vprintfmt+0x15c>
  8003e9:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  8003f0:	85 d2                	test   %edx,%edx
  8003f2:	74 18                	je     80040c <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003f4:	52                   	push   %edx
  8003f5:	68 f5 2c 80 00       	push   $0x802cf5
  8003fa:	53                   	push   %ebx
  8003fb:	56                   	push   %esi
  8003fc:	e8 92 fe ff ff       	call   800293 <printfmt>
  800401:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800404:	89 7d 14             	mov    %edi,0x14(%ebp)
  800407:	e9 66 02 00 00       	jmp    800672 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80040c:	50                   	push   %eax
  80040d:	68 33 29 80 00       	push   $0x802933
  800412:	53                   	push   %ebx
  800413:	56                   	push   %esi
  800414:	e8 7a fe ff ff       	call   800293 <printfmt>
  800419:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80041f:	e9 4e 02 00 00       	jmp    800672 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	83 c0 04             	add    $0x4,%eax
  80042a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800432:	85 d2                	test   %edx,%edx
  800434:	b8 2c 29 80 00       	mov    $0x80292c,%eax
  800439:	0f 45 c2             	cmovne %edx,%eax
  80043c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80043f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800443:	7e 06                	jle    80044b <vprintfmt+0x19b>
  800445:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800449:	75 0d                	jne    800458 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80044e:	89 c7                	mov    %eax,%edi
  800450:	03 45 e0             	add    -0x20(%ebp),%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800456:	eb 55                	jmp    8004ad <vprintfmt+0x1fd>
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	ff 75 d8             	push   -0x28(%ebp)
  80045e:	ff 75 cc             	push   -0x34(%ebp)
  800461:	e8 0a 03 00 00       	call   800770 <strnlen>
  800466:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800469:	29 c1                	sub    %eax,%ecx
  80046b:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800473:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800477:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	eb 0f                	jmp    80048b <vprintfmt+0x1db>
					putch(padc, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	ff 75 e0             	push   -0x20(%ebp)
  800483:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	83 ef 01             	sub    $0x1,%edi
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	85 ff                	test   %edi,%edi
  80048d:	7f ed                	jg     80047c <vprintfmt+0x1cc>
  80048f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800492:	85 d2                	test   %edx,%edx
  800494:	b8 00 00 00 00       	mov    $0x0,%eax
  800499:	0f 49 c2             	cmovns %edx,%eax
  80049c:	29 c2                	sub    %eax,%edx
  80049e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a1:	eb a8                	jmp    80044b <vprintfmt+0x19b>
					putch(ch, putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	53                   	push   %ebx
  8004a7:	52                   	push   %edx
  8004a8:	ff d6                	call   *%esi
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b2:	83 c7 01             	add    $0x1,%edi
  8004b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b9:	0f be d0             	movsbl %al,%edx
  8004bc:	85 d2                	test   %edx,%edx
  8004be:	74 4b                	je     80050b <vprintfmt+0x25b>
  8004c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c4:	78 06                	js     8004cc <vprintfmt+0x21c>
  8004c6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ca:	78 1e                	js     8004ea <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004d0:	74 d1                	je     8004a3 <vprintfmt+0x1f3>
  8004d2:	0f be c0             	movsbl %al,%eax
  8004d5:	83 e8 20             	sub    $0x20,%eax
  8004d8:	83 f8 5e             	cmp    $0x5e,%eax
  8004db:	76 c6                	jbe    8004a3 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	6a 3f                	push   $0x3f
  8004e3:	ff d6                	call   *%esi
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb c3                	jmp    8004ad <vprintfmt+0x1fd>
  8004ea:	89 cf                	mov    %ecx,%edi
  8004ec:	eb 0e                	jmp    8004fc <vprintfmt+0x24c>
				putch(' ', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	53                   	push   %ebx
  8004f2:	6a 20                	push   $0x20
  8004f4:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004f6:	83 ef 01             	sub    $0x1,%edi
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 ff                	test   %edi,%edi
  8004fe:	7f ee                	jg     8004ee <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800500:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800503:	89 45 14             	mov    %eax,0x14(%ebp)
  800506:	e9 67 01 00 00       	jmp    800672 <vprintfmt+0x3c2>
  80050b:	89 cf                	mov    %ecx,%edi
  80050d:	eb ed                	jmp    8004fc <vprintfmt+0x24c>
	if (lflag >= 2)
  80050f:	83 f9 01             	cmp    $0x1,%ecx
  800512:	7f 1b                	jg     80052f <vprintfmt+0x27f>
	else if (lflag)
  800514:	85 c9                	test   %ecx,%ecx
  800516:	74 63                	je     80057b <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800520:	99                   	cltd   
  800521:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 40 04             	lea    0x4(%eax),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
  80052d:	eb 17                	jmp    800546 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8b 50 04             	mov    0x4(%eax),%edx
  800535:	8b 00                	mov    (%eax),%eax
  800537:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 40 08             	lea    0x8(%eax),%eax
  800543:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800546:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800549:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80054c:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800551:	85 c9                	test   %ecx,%ecx
  800553:	0f 89 ff 00 00 00    	jns    800658 <vprintfmt+0x3a8>
				putch('-', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	6a 2d                	push   $0x2d
  80055f:	ff d6                	call   *%esi
				num = -(long long) num;
  800561:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800564:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800567:	f7 da                	neg    %edx
  800569:	83 d1 00             	adc    $0x0,%ecx
  80056c:	f7 d9                	neg    %ecx
  80056e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800571:	bf 0a 00 00 00       	mov    $0xa,%edi
  800576:	e9 dd 00 00 00       	jmp    800658 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800583:	99                   	cltd   
  800584:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8d 40 04             	lea    0x4(%eax),%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
  800590:	eb b4                	jmp    800546 <vprintfmt+0x296>
	if (lflag >= 2)
  800592:	83 f9 01             	cmp    $0x1,%ecx
  800595:	7f 1e                	jg     8005b5 <vprintfmt+0x305>
	else if (lflag)
  800597:	85 c9                	test   %ecx,%ecx
  800599:	74 32                	je     8005cd <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a5:	8d 40 04             	lea    0x4(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ab:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005b0:	e9 a3 00 00 00       	jmp    800658 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bd:	8d 40 08             	lea    0x8(%eax),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005c8:	e9 8b 00 00 00       	jmp    800658 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005e2:	eb 74                	jmp    800658 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005e4:	83 f9 01             	cmp    $0x1,%ecx
  8005e7:	7f 1b                	jg     800604 <vprintfmt+0x354>
	else if (lflag)
  8005e9:	85 c9                	test   %ecx,%ecx
  8005eb:	74 2c                	je     800619 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f7:	8d 40 04             	lea    0x4(%eax),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005fd:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800602:	eb 54                	jmp    800658 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	8b 48 04             	mov    0x4(%eax),%ecx
  80060c:	8d 40 08             	lea    0x8(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800612:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800617:	eb 3f                	jmp    800658 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8b 10                	mov    (%eax),%edx
  80061e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800623:	8d 40 04             	lea    0x4(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800629:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80062e:	eb 28                	jmp    800658 <vprintfmt+0x3a8>
			putch('0', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 30                	push   $0x30
  800636:	ff d6                	call   *%esi
			putch('x', putdat);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 78                	push   $0x78
  80063e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80064a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800653:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800658:	83 ec 0c             	sub    $0xc,%esp
  80065b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	ff 75 e0             	push   -0x20(%ebp)
  800663:	57                   	push   %edi
  800664:	51                   	push   %ecx
  800665:	52                   	push   %edx
  800666:	89 da                	mov    %ebx,%edx
  800668:	89 f0                	mov    %esi,%eax
  80066a:	e8 5e fb ff ff       	call   8001cd <printnum>
			break;
  80066f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800675:	e9 54 fc ff ff       	jmp    8002ce <vprintfmt+0x1e>
	if (lflag >= 2)
  80067a:	83 f9 01             	cmp    $0x1,%ecx
  80067d:	7f 1b                	jg     80069a <vprintfmt+0x3ea>
	else if (lflag)
  80067f:	85 c9                	test   %ecx,%ecx
  800681:	74 2c                	je     8006af <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800693:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800698:	eb be                	jmp    800658 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a2:	8d 40 08             	lea    0x8(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006ad:	eb a9                	jmp    800658 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b9:	8d 40 04             	lea    0x4(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bf:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006c4:	eb 92                	jmp    800658 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 25                	push   $0x25
  8006cc:	ff d6                	call   *%esi
			break;
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 9f                	jmp    800672 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	6a 25                	push   $0x25
  8006d9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	89 f8                	mov    %edi,%eax
  8006e0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e4:	74 05                	je     8006eb <vprintfmt+0x43b>
  8006e6:	83 e8 01             	sub    $0x1,%eax
  8006e9:	eb f5                	jmp    8006e0 <vprintfmt+0x430>
  8006eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ee:	eb 82                	jmp    800672 <vprintfmt+0x3c2>

008006f0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	83 ec 18             	sub    $0x18,%esp
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800703:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800706:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 26                	je     800737 <vsnprintf+0x47>
  800711:	85 d2                	test   %edx,%edx
  800713:	7e 22                	jle    800737 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800715:	ff 75 14             	push   0x14(%ebp)
  800718:	ff 75 10             	push   0x10(%ebp)
  80071b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	68 76 02 80 00       	push   $0x800276
  800724:	e8 87 fb ff ff       	call   8002b0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800729:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800732:	83 c4 10             	add    $0x10,%esp
}
  800735:	c9                   	leave  
  800736:	c3                   	ret    
		return -E_INVAL;
  800737:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80073c:	eb f7                	jmp    800735 <vsnprintf+0x45>

0080073e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800747:	50                   	push   %eax
  800748:	ff 75 10             	push   0x10(%ebp)
  80074b:	ff 75 0c             	push   0xc(%ebp)
  80074e:	ff 75 08             	push   0x8(%ebp)
  800751:	e8 9a ff ff ff       	call   8006f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	eb 03                	jmp    800768 <strlen+0x10>
		n++;
  800765:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800768:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076c:	75 f7                	jne    800765 <strlen+0xd>
	return n;
}
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
  80077e:	eb 03                	jmp    800783 <strnlen+0x13>
		n++;
  800780:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800783:	39 d0                	cmp    %edx,%eax
  800785:	74 08                	je     80078f <strnlen+0x1f>
  800787:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80078b:	75 f3                	jne    800780 <strnlen+0x10>
  80078d:	89 c2                	mov    %eax,%edx
	return n;
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007a6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007a9:	83 c0 01             	add    $0x1,%eax
  8007ac:	84 d2                	test   %dl,%dl
  8007ae:	75 f2                	jne    8007a2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b0:	89 c8                	mov    %ecx,%eax
  8007b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	83 ec 10             	sub    $0x10,%esp
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c1:	53                   	push   %ebx
  8007c2:	e8 91 ff ff ff       	call   800758 <strlen>
  8007c7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007ca:	ff 75 0c             	push   0xc(%ebp)
  8007cd:	01 d8                	add    %ebx,%eax
  8007cf:	50                   	push   %eax
  8007d0:	e8 be ff ff ff       	call   800793 <strcpy>
	return dst;
}
  8007d5:	89 d8                	mov    %ebx,%eax
  8007d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e7:	89 f3                	mov    %esi,%ebx
  8007e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	eb 0f                	jmp    8007ff <strncpy+0x23>
		*dst++ = *src;
  8007f0:	83 c0 01             	add    $0x1,%eax
  8007f3:	0f b6 0a             	movzbl (%edx),%ecx
  8007f6:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f9:	80 f9 01             	cmp    $0x1,%cl
  8007fc:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007ff:	39 d8                	cmp    %ebx,%eax
  800801:	75 ed                	jne    8007f0 <strncpy+0x14>
	}
	return ret;
}
  800803:	89 f0                	mov    %esi,%eax
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	8b 75 08             	mov    0x8(%ebp),%esi
  800811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800814:	8b 55 10             	mov    0x10(%ebp),%edx
  800817:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 21                	je     80083e <strlcpy+0x35>
  80081d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800821:	89 f2                	mov    %esi,%edx
  800823:	eb 09                	jmp    80082e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	83 c2 01             	add    $0x1,%edx
  80082b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80082e:	39 c2                	cmp    %eax,%edx
  800830:	74 09                	je     80083b <strlcpy+0x32>
  800832:	0f b6 19             	movzbl (%ecx),%ebx
  800835:	84 db                	test   %bl,%bl
  800837:	75 ec                	jne    800825 <strlcpy+0x1c>
  800839:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80083b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083e:	29 f0                	sub    %esi,%eax
}
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084d:	eb 06                	jmp    800855 <strcmp+0x11>
		p++, q++;
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800855:	0f b6 01             	movzbl (%ecx),%eax
  800858:	84 c0                	test   %al,%al
  80085a:	74 04                	je     800860 <strcmp+0x1c>
  80085c:	3a 02                	cmp    (%edx),%al
  80085e:	74 ef                	je     80084f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800860:	0f b6 c0             	movzbl %al,%eax
  800863:	0f b6 12             	movzbl (%edx),%edx
  800866:	29 d0                	sub    %edx,%eax
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
  800874:	89 c3                	mov    %eax,%ebx
  800876:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800879:	eb 06                	jmp    800881 <strncmp+0x17>
		n--, p++, q++;
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800881:	39 d8                	cmp    %ebx,%eax
  800883:	74 18                	je     80089d <strncmp+0x33>
  800885:	0f b6 08             	movzbl (%eax),%ecx
  800888:	84 c9                	test   %cl,%cl
  80088a:	74 04                	je     800890 <strncmp+0x26>
  80088c:	3a 0a                	cmp    (%edx),%cl
  80088e:	74 eb                	je     80087b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800890:	0f b6 00             	movzbl (%eax),%eax
  800893:	0f b6 12             	movzbl (%edx),%edx
  800896:	29 d0                	sub    %edx,%eax
}
  800898:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    
		return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	eb f4                	jmp    800898 <strncmp+0x2e>

008008a4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ae:	eb 03                	jmp    8008b3 <strchr+0xf>
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	0f b6 10             	movzbl (%eax),%edx
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	74 06                	je     8008c0 <strchr+0x1c>
		if (*s == c)
  8008ba:	38 ca                	cmp    %cl,%dl
  8008bc:	75 f2                	jne    8008b0 <strchr+0xc>
  8008be:	eb 05                	jmp    8008c5 <strchr+0x21>
			return (char *) s;
	return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	74 09                	je     8008e1 <strfind+0x1a>
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	74 05                	je     8008e1 <strfind+0x1a>
	for (; *s; s++)
  8008dc:	83 c0 01             	add    $0x1,%eax
  8008df:	eb f0                	jmp    8008d1 <strfind+0xa>
			break;
	return (char *) s;
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	57                   	push   %edi
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ef:	85 c9                	test   %ecx,%ecx
  8008f1:	74 2f                	je     800922 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f3:	89 f8                	mov    %edi,%eax
  8008f5:	09 c8                	or     %ecx,%eax
  8008f7:	a8 03                	test   $0x3,%al
  8008f9:	75 21                	jne    80091c <memset+0x39>
		c &= 0xFF;
  8008fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ff:	89 d0                	mov    %edx,%eax
  800901:	c1 e0 08             	shl    $0x8,%eax
  800904:	89 d3                	mov    %edx,%ebx
  800906:	c1 e3 18             	shl    $0x18,%ebx
  800909:	89 d6                	mov    %edx,%esi
  80090b:	c1 e6 10             	shl    $0x10,%esi
  80090e:	09 f3                	or     %esi,%ebx
  800910:	09 da                	or     %ebx,%edx
  800912:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800914:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800917:	fc                   	cld    
  800918:	f3 ab                	rep stos %eax,%es:(%edi)
  80091a:	eb 06                	jmp    800922 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091f:	fc                   	cld    
  800920:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800922:	89 f8                	mov    %edi,%eax
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 75 0c             	mov    0xc(%ebp),%esi
  800934:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800937:	39 c6                	cmp    %eax,%esi
  800939:	73 32                	jae    80096d <memmove+0x44>
  80093b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093e:	39 c2                	cmp    %eax,%edx
  800940:	76 2b                	jbe    80096d <memmove+0x44>
		s += n;
		d += n;
  800942:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800945:	89 d6                	mov    %edx,%esi
  800947:	09 fe                	or     %edi,%esi
  800949:	09 ce                	or     %ecx,%esi
  80094b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800951:	75 0e                	jne    800961 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800953:	83 ef 04             	sub    $0x4,%edi
  800956:	8d 72 fc             	lea    -0x4(%edx),%esi
  800959:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80095c:	fd                   	std    
  80095d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095f:	eb 09                	jmp    80096a <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800961:	83 ef 01             	sub    $0x1,%edi
  800964:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800967:	fd                   	std    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096a:	fc                   	cld    
  80096b:	eb 1a                	jmp    800987 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096d:	89 f2                	mov    %esi,%edx
  80096f:	09 c2                	or     %eax,%edx
  800971:	09 ca                	or     %ecx,%edx
  800973:	f6 c2 03             	test   $0x3,%dl
  800976:	75 0a                	jne    800982 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800978:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80097b:	89 c7                	mov    %eax,%edi
  80097d:	fc                   	cld    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 05                	jmp    800987 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800991:	ff 75 10             	push   0x10(%ebp)
  800994:	ff 75 0c             	push   0xc(%ebp)
  800997:	ff 75 08             	push   0x8(%ebp)
  80099a:	e8 8a ff ff ff       	call   800929 <memmove>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	89 c6                	mov    %eax,%esi
  8009ae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b1:	eb 06                	jmp    8009b9 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009b9:	39 f0                	cmp    %esi,%eax
  8009bb:	74 14                	je     8009d1 <memcmp+0x30>
		if (*s1 != *s2)
  8009bd:	0f b6 08             	movzbl (%eax),%ecx
  8009c0:	0f b6 1a             	movzbl (%edx),%ebx
  8009c3:	38 d9                	cmp    %bl,%cl
  8009c5:	74 ec                	je     8009b3 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009c7:	0f b6 c1             	movzbl %cl,%eax
  8009ca:	0f b6 db             	movzbl %bl,%ebx
  8009cd:	29 d8                	sub    %ebx,%eax
  8009cf:	eb 05                	jmp    8009d6 <memcmp+0x35>
	}

	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e3:	89 c2                	mov    %eax,%edx
  8009e5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e8:	eb 03                	jmp    8009ed <memfind+0x13>
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	39 d0                	cmp    %edx,%eax
  8009ef:	73 04                	jae    8009f5 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f1:	38 08                	cmp    %cl,(%eax)
  8009f3:	75 f5                	jne    8009ea <memfind+0x10>
			break;
	return (void *) s;
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800a00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a03:	eb 03                	jmp    800a08 <strtol+0x11>
		s++;
  800a05:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a08:	0f b6 02             	movzbl (%edx),%eax
  800a0b:	3c 20                	cmp    $0x20,%al
  800a0d:	74 f6                	je     800a05 <strtol+0xe>
  800a0f:	3c 09                	cmp    $0x9,%al
  800a11:	74 f2                	je     800a05 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a13:	3c 2b                	cmp    $0x2b,%al
  800a15:	74 2a                	je     800a41 <strtol+0x4a>
	int neg = 0;
  800a17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a1c:	3c 2d                	cmp    $0x2d,%al
  800a1e:	74 2b                	je     800a4b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a20:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a26:	75 0f                	jne    800a37 <strtol+0x40>
  800a28:	80 3a 30             	cmpb   $0x30,(%edx)
  800a2b:	74 28                	je     800a55 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2d:	85 db                	test   %ebx,%ebx
  800a2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a34:	0f 44 d8             	cmove  %eax,%ebx
  800a37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a3c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a3f:	eb 46                	jmp    800a87 <strtol+0x90>
		s++;
  800a41:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
  800a49:	eb d5                	jmp    800a20 <strtol+0x29>
		s++, neg = 1;
  800a4b:	83 c2 01             	add    $0x1,%edx
  800a4e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a53:	eb cb                	jmp    800a20 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a55:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a59:	74 0e                	je     800a69 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a5b:	85 db                	test   %ebx,%ebx
  800a5d:	75 d8                	jne    800a37 <strtol+0x40>
		s++, base = 8;
  800a5f:	83 c2 01             	add    $0x1,%edx
  800a62:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a67:	eb ce                	jmp    800a37 <strtol+0x40>
		s += 2, base = 16;
  800a69:	83 c2 02             	add    $0x2,%edx
  800a6c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a71:	eb c4                	jmp    800a37 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a73:	0f be c0             	movsbl %al,%eax
  800a76:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a79:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a7c:	7d 3a                	jge    800ab8 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a7e:	83 c2 01             	add    $0x1,%edx
  800a81:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a85:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a87:	0f b6 02             	movzbl (%edx),%eax
  800a8a:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	80 fb 09             	cmp    $0x9,%bl
  800a92:	76 df                	jbe    800a73 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a94:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a97:	89 f3                	mov    %esi,%ebx
  800a99:	80 fb 19             	cmp    $0x19,%bl
  800a9c:	77 08                	ja     800aa6 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a9e:	0f be c0             	movsbl %al,%eax
  800aa1:	83 e8 57             	sub    $0x57,%eax
  800aa4:	eb d3                	jmp    800a79 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800aa6:	8d 70 bf             	lea    -0x41(%eax),%esi
  800aa9:	89 f3                	mov    %esi,%ebx
  800aab:	80 fb 19             	cmp    $0x19,%bl
  800aae:	77 08                	ja     800ab8 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ab0:	0f be c0             	movsbl %al,%eax
  800ab3:	83 e8 37             	sub    $0x37,%eax
  800ab6:	eb c1                	jmp    800a79 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abc:	74 05                	je     800ac3 <strtol+0xcc>
		*endptr = (char *) s;
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ac3:	89 c8                	mov    %ecx,%eax
  800ac5:	f7 d8                	neg    %eax
  800ac7:	85 ff                	test   %edi,%edi
  800ac9:	0f 45 c8             	cmovne %eax,%ecx
}
  800acc:	89 c8                	mov    %ecx,%eax
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae4:	89 c3                	mov    %eax,%ebx
  800ae6:	89 c7                	mov    %eax,%edi
  800ae8:	89 c6                	mov    %eax,%esi
  800aea:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	57                   	push   %edi
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af7:	ba 00 00 00 00       	mov    $0x0,%edx
  800afc:	b8 01 00 00 00       	mov    $0x1,%eax
  800b01:	89 d1                	mov    %edx,%ecx
  800b03:	89 d3                	mov    %edx,%ebx
  800b05:	89 d7                	mov    %edx,%edi
  800b07:	89 d6                	mov    %edx,%esi
  800b09:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
  800b16:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b21:	b8 03 00 00 00       	mov    $0x3,%eax
  800b26:	89 cb                	mov    %ecx,%ebx
  800b28:	89 cf                	mov    %ecx,%edi
  800b2a:	89 ce                	mov    %ecx,%esi
  800b2c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	7f 08                	jg     800b3a <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3a:	83 ec 0c             	sub    $0xc,%esp
  800b3d:	50                   	push   %eax
  800b3e:	6a 03                	push   $0x3
  800b40:	68 1f 2c 80 00       	push   $0x802c1f
  800b45:	6a 2a                	push   $0x2a
  800b47:	68 3c 2c 80 00       	push   $0x802c3c
  800b4c:	e8 8d f5 ff ff       	call   8000de <_panic>

00800b51 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b61:	89 d1                	mov    %edx,%ecx
  800b63:	89 d3                	mov    %edx,%ebx
  800b65:	89 d7                	mov    %edx,%edi
  800b67:	89 d6                	mov    %edx,%esi
  800b69:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_yield>:

void
sys_yield(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b98:	be 00 00 00 00       	mov    $0x0,%esi
  800b9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba3:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bab:	89 f7                	mov    %esi,%edi
  800bad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	7f 08                	jg     800bbb <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 04                	push   $0x4
  800bc1:	68 1f 2c 80 00       	push   $0x802c1f
  800bc6:	6a 2a                	push   $0x2a
  800bc8:	68 3c 2c 80 00       	push   $0x802c3c
  800bcd:	e8 0c f5 ff ff       	call   8000de <_panic>

00800bd2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be1:	b8 05 00 00 00       	mov    $0x5,%eax
  800be6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bec:	8b 75 18             	mov    0x18(%ebp),%esi
  800bef:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	7f 08                	jg     800bfd <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	50                   	push   %eax
  800c01:	6a 05                	push   $0x5
  800c03:	68 1f 2c 80 00       	push   $0x802c1f
  800c08:	6a 2a                	push   $0x2a
  800c0a:	68 3c 2c 80 00       	push   $0x802c3c
  800c0f:	e8 ca f4 ff ff       	call   8000de <_panic>

00800c14 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c28:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2d:	89 df                	mov    %ebx,%edi
  800c2f:	89 de                	mov    %ebx,%esi
  800c31:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7f 08                	jg     800c3f <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 06                	push   $0x6
  800c45:	68 1f 2c 80 00       	push   $0x802c1f
  800c4a:	6a 2a                	push   $0x2a
  800c4c:	68 3c 2c 80 00       	push   $0x802c3c
  800c51:	e8 88 f4 ff ff       	call   8000de <_panic>

00800c56 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6f:	89 df                	mov    %ebx,%edi
  800c71:	89 de                	mov    %ebx,%esi
  800c73:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7f 08                	jg     800c81 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 08                	push   $0x8
  800c87:	68 1f 2c 80 00       	push   $0x802c1f
  800c8c:	6a 2a                	push   $0x2a
  800c8e:	68 3c 2c 80 00       	push   $0x802c3c
  800c93:	e8 46 f4 ff ff       	call   8000de <_panic>

00800c98 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cac:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb1:	89 df                	mov    %ebx,%edi
  800cb3:	89 de                	mov    %ebx,%esi
  800cb5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7f 08                	jg     800cc3 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	6a 09                	push   $0x9
  800cc9:	68 1f 2c 80 00       	push   $0x802c1f
  800cce:	6a 2a                	push   $0x2a
  800cd0:	68 3c 2c 80 00       	push   $0x802c3c
  800cd5:	e8 04 f4 ff ff       	call   8000de <_panic>

00800cda <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7f 08                	jg     800d05 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 0a                	push   $0xa
  800d0b:	68 1f 2c 80 00       	push   $0x802c1f
  800d10:	6a 2a                	push   $0x2a
  800d12:	68 3c 2c 80 00       	push   $0x802c3c
  800d17:	e8 c2 f3 ff ff       	call   8000de <_panic>

00800d1c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2d:	be 00 00 00 00       	mov    $0x0,%esi
  800d32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d38:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d55:	89 cb                	mov    %ecx,%ebx
  800d57:	89 cf                	mov    %ecx,%edi
  800d59:	89 ce                	mov    %ecx,%esi
  800d5b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	7f 08                	jg     800d69 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	50                   	push   %eax
  800d6d:	6a 0d                	push   $0xd
  800d6f:	68 1f 2c 80 00       	push   $0x802c1f
  800d74:	6a 2a                	push   $0x2a
  800d76:	68 3c 2c 80 00       	push   $0x802c3c
  800d7b:	e8 5e f3 ff ff       	call   8000de <_panic>

00800d80 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d86:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d90:	89 d1                	mov    %edx,%ecx
  800d92:	89 d3                	mov    %edx,%ebx
  800d94:	89 d7                	mov    %edx,%edi
  800d96:	89 d6                	mov    %edx,%esi
  800d98:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	b8 0f 00 00 00       	mov    $0xf,%eax
  800db5:	89 df                	mov    %ebx,%edi
  800db7:	89 de                	mov    %ebx,%esi
  800db9:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	b8 10 00 00 00       	mov    $0x10,%eax
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	05 00 00 00 30       	add    $0x30000000,%eax
  800dec:	c1 e8 0c             	shr    $0xc,%eax
}
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df4:	8b 45 08             	mov    0x8(%ebp),%eax
  800df7:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800dfc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e01:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e10:	89 c2                	mov    %eax,%edx
  800e12:	c1 ea 16             	shr    $0x16,%edx
  800e15:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1c:	f6 c2 01             	test   $0x1,%dl
  800e1f:	74 29                	je     800e4a <fd_alloc+0x42>
  800e21:	89 c2                	mov    %eax,%edx
  800e23:	c1 ea 0c             	shr    $0xc,%edx
  800e26:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2d:	f6 c2 01             	test   $0x1,%dl
  800e30:	74 18                	je     800e4a <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e32:	05 00 10 00 00       	add    $0x1000,%eax
  800e37:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3c:	75 d2                	jne    800e10 <fd_alloc+0x8>
  800e3e:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800e43:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800e48:	eb 05                	jmp    800e4f <fd_alloc+0x47>
			return 0;
  800e4a:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	89 02                	mov    %eax,(%edx)
}
  800e54:	89 c8                	mov    %ecx,%eax
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e5e:	83 f8 1f             	cmp    $0x1f,%eax
  800e61:	77 30                	ja     800e93 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e63:	c1 e0 0c             	shl    $0xc,%eax
  800e66:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e6b:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	74 24                	je     800e9a <fd_lookup+0x42>
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	c1 ea 0c             	shr    $0xc,%edx
  800e7b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e82:	f6 c2 01             	test   $0x1,%dl
  800e85:	74 1a                	je     800ea1 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8a:	89 02                	mov    %eax,(%edx)
	return 0;
  800e8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    
		return -E_INVAL;
  800e93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e98:	eb f7                	jmp    800e91 <fd_lookup+0x39>
		return -E_INVAL;
  800e9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9f:	eb f0                	jmp    800e91 <fd_lookup+0x39>
  800ea1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea6:	eb e9                	jmp    800e91 <fd_lookup+0x39>

00800ea8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	53                   	push   %ebx
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800ebc:	39 13                	cmp    %edx,(%ebx)
  800ebe:	74 37                	je     800ef7 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800ec0:	83 c0 01             	add    $0x1,%eax
  800ec3:	8b 1c 85 c8 2c 80 00 	mov    0x802cc8(,%eax,4),%ebx
  800eca:	85 db                	test   %ebx,%ebx
  800ecc:	75 ee                	jne    800ebc <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ece:	a1 00 40 80 00       	mov    0x804000,%eax
  800ed3:	8b 40 58             	mov    0x58(%eax),%eax
  800ed6:	83 ec 04             	sub    $0x4,%esp
  800ed9:	52                   	push   %edx
  800eda:	50                   	push   %eax
  800edb:	68 4c 2c 80 00       	push   $0x802c4c
  800ee0:	e8 d4 f2 ff ff       	call   8001b9 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800eed:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef0:	89 1a                	mov    %ebx,(%edx)
}
  800ef2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    
			return 0;
  800ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  800efc:	eb ef                	jmp    800eed <dev_lookup+0x45>

00800efe <fd_close>:
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 24             	sub    $0x24,%esp
  800f07:	8b 75 08             	mov    0x8(%ebp),%esi
  800f0a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f10:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f11:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f17:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f1a:	50                   	push   %eax
  800f1b:	e8 38 ff ff ff       	call   800e58 <fd_lookup>
  800f20:	89 c3                	mov    %eax,%ebx
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	85 c0                	test   %eax,%eax
  800f27:	78 05                	js     800f2e <fd_close+0x30>
	    || fd != fd2)
  800f29:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f2c:	74 16                	je     800f44 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f2e:	89 f8                	mov    %edi,%eax
  800f30:	84 c0                	test   %al,%al
  800f32:	b8 00 00 00 00       	mov    $0x0,%eax
  800f37:	0f 44 d8             	cmove  %eax,%ebx
}
  800f3a:	89 d8                	mov    %ebx,%eax
  800f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5f                   	pop    %edi
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	ff 36                	push   (%esi)
  800f4d:	e8 56 ff ff ff       	call   800ea8 <dev_lookup>
  800f52:	89 c3                	mov    %eax,%ebx
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	78 1a                	js     800f75 <fd_close+0x77>
		if (dev->dev_close)
  800f5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f5e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f61:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	74 0b                	je     800f75 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	56                   	push   %esi
  800f6e:	ff d0                	call   *%eax
  800f70:	89 c3                	mov    %eax,%ebx
  800f72:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f75:	83 ec 08             	sub    $0x8,%esp
  800f78:	56                   	push   %esi
  800f79:	6a 00                	push   $0x0
  800f7b:	e8 94 fc ff ff       	call   800c14 <sys_page_unmap>
	return r;
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	eb b5                	jmp    800f3a <fd_close+0x3c>

00800f85 <close>:

int
close(int fdnum)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	ff 75 08             	push   0x8(%ebp)
  800f92:	e8 c1 fe ff ff       	call   800e58 <fd_lookup>
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	79 02                	jns    800fa0 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f9e:	c9                   	leave  
  800f9f:	c3                   	ret    
		return fd_close(fd, 1);
  800fa0:	83 ec 08             	sub    $0x8,%esp
  800fa3:	6a 01                	push   $0x1
  800fa5:	ff 75 f4             	push   -0xc(%ebp)
  800fa8:	e8 51 ff ff ff       	call   800efe <fd_close>
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	eb ec                	jmp    800f9e <close+0x19>

00800fb2 <close_all>:

void
close_all(void)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	53                   	push   %ebx
  800fc2:	e8 be ff ff ff       	call   800f85 <close>
	for (i = 0; i < MAXFD; i++)
  800fc7:	83 c3 01             	add    $0x1,%ebx
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	83 fb 20             	cmp    $0x20,%ebx
  800fd0:	75 ec                	jne    800fbe <close_all+0xc>
}
  800fd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	57                   	push   %edi
  800fdb:	56                   	push   %esi
  800fdc:	53                   	push   %ebx
  800fdd:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe3:	50                   	push   %eax
  800fe4:	ff 75 08             	push   0x8(%ebp)
  800fe7:	e8 6c fe ff ff       	call   800e58 <fd_lookup>
  800fec:	89 c3                	mov    %eax,%ebx
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 7f                	js     801074 <dup+0x9d>
		return r;
	close(newfdnum);
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	ff 75 0c             	push   0xc(%ebp)
  800ffb:	e8 85 ff ff ff       	call   800f85 <close>

	newfd = INDEX2FD(newfdnum);
  801000:	8b 75 0c             	mov    0xc(%ebp),%esi
  801003:	c1 e6 0c             	shl    $0xc,%esi
  801006:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80100c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80100f:	89 3c 24             	mov    %edi,(%esp)
  801012:	e8 da fd ff ff       	call   800df1 <fd2data>
  801017:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801019:	89 34 24             	mov    %esi,(%esp)
  80101c:	e8 d0 fd ff ff       	call   800df1 <fd2data>
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801027:	89 d8                	mov    %ebx,%eax
  801029:	c1 e8 16             	shr    $0x16,%eax
  80102c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801033:	a8 01                	test   $0x1,%al
  801035:	74 11                	je     801048 <dup+0x71>
  801037:	89 d8                	mov    %ebx,%eax
  801039:	c1 e8 0c             	shr    $0xc,%eax
  80103c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801043:	f6 c2 01             	test   $0x1,%dl
  801046:	75 36                	jne    80107e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801048:	89 f8                	mov    %edi,%eax
  80104a:	c1 e8 0c             	shr    $0xc,%eax
  80104d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	25 07 0e 00 00       	and    $0xe07,%eax
  80105c:	50                   	push   %eax
  80105d:	56                   	push   %esi
  80105e:	6a 00                	push   $0x0
  801060:	57                   	push   %edi
  801061:	6a 00                	push   $0x0
  801063:	e8 6a fb ff ff       	call   800bd2 <sys_page_map>
  801068:	89 c3                	mov    %eax,%ebx
  80106a:	83 c4 20             	add    $0x20,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	78 33                	js     8010a4 <dup+0xcd>
		goto err;

	return newfdnum;
  801071:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801074:	89 d8                	mov    %ebx,%eax
  801076:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801079:	5b                   	pop    %ebx
  80107a:	5e                   	pop    %esi
  80107b:	5f                   	pop    %edi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80107e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	25 07 0e 00 00       	and    $0xe07,%eax
  80108d:	50                   	push   %eax
  80108e:	ff 75 d4             	push   -0x2c(%ebp)
  801091:	6a 00                	push   $0x0
  801093:	53                   	push   %ebx
  801094:	6a 00                	push   $0x0
  801096:	e8 37 fb ff ff       	call   800bd2 <sys_page_map>
  80109b:	89 c3                	mov    %eax,%ebx
  80109d:	83 c4 20             	add    $0x20,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	79 a4                	jns    801048 <dup+0x71>
	sys_page_unmap(0, newfd);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	56                   	push   %esi
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 65 fb ff ff       	call   800c14 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010af:	83 c4 08             	add    $0x8,%esp
  8010b2:	ff 75 d4             	push   -0x2c(%ebp)
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 58 fb ff ff       	call   800c14 <sys_page_unmap>
	return r;
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	eb b3                	jmp    801074 <dup+0x9d>

008010c1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	56                   	push   %esi
  8010c5:	53                   	push   %ebx
  8010c6:	83 ec 18             	sub    $0x18,%esp
  8010c9:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010cf:	50                   	push   %eax
  8010d0:	56                   	push   %esi
  8010d1:	e8 82 fd ff ff       	call   800e58 <fd_lookup>
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	78 3c                	js     801119 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010dd:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	ff 33                	push   (%ebx)
  8010e9:	e8 ba fd ff ff       	call   800ea8 <dev_lookup>
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 24                	js     801119 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010f5:	8b 43 08             	mov    0x8(%ebx),%eax
  8010f8:	83 e0 03             	and    $0x3,%eax
  8010fb:	83 f8 01             	cmp    $0x1,%eax
  8010fe:	74 20                	je     801120 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801100:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801103:	8b 40 08             	mov    0x8(%eax),%eax
  801106:	85 c0                	test   %eax,%eax
  801108:	74 37                	je     801141 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80110a:	83 ec 04             	sub    $0x4,%esp
  80110d:	ff 75 10             	push   0x10(%ebp)
  801110:	ff 75 0c             	push   0xc(%ebp)
  801113:	53                   	push   %ebx
  801114:	ff d0                	call   *%eax
  801116:	83 c4 10             	add    $0x10,%esp
}
  801119:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80111c:	5b                   	pop    %ebx
  80111d:	5e                   	pop    %esi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801120:	a1 00 40 80 00       	mov    0x804000,%eax
  801125:	8b 40 58             	mov    0x58(%eax),%eax
  801128:	83 ec 04             	sub    $0x4,%esp
  80112b:	56                   	push   %esi
  80112c:	50                   	push   %eax
  80112d:	68 8d 2c 80 00       	push   $0x802c8d
  801132:	e8 82 f0 ff ff       	call   8001b9 <cprintf>
		return -E_INVAL;
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113f:	eb d8                	jmp    801119 <read+0x58>
		return -E_NOT_SUPP;
  801141:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801146:	eb d1                	jmp    801119 <read+0x58>

00801148 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	57                   	push   %edi
  80114c:	56                   	push   %esi
  80114d:	53                   	push   %ebx
  80114e:	83 ec 0c             	sub    $0xc,%esp
  801151:	8b 7d 08             	mov    0x8(%ebp),%edi
  801154:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801157:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115c:	eb 02                	jmp    801160 <readn+0x18>
  80115e:	01 c3                	add    %eax,%ebx
  801160:	39 f3                	cmp    %esi,%ebx
  801162:	73 21                	jae    801185 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	89 f0                	mov    %esi,%eax
  801169:	29 d8                	sub    %ebx,%eax
  80116b:	50                   	push   %eax
  80116c:	89 d8                	mov    %ebx,%eax
  80116e:	03 45 0c             	add    0xc(%ebp),%eax
  801171:	50                   	push   %eax
  801172:	57                   	push   %edi
  801173:	e8 49 ff ff ff       	call   8010c1 <read>
		if (m < 0)
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 04                	js     801183 <readn+0x3b>
			return m;
		if (m == 0)
  80117f:	75 dd                	jne    80115e <readn+0x16>
  801181:	eb 02                	jmp    801185 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801183:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801185:	89 d8                	mov    %ebx,%eax
  801187:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118a:	5b                   	pop    %ebx
  80118b:	5e                   	pop    %esi
  80118c:	5f                   	pop    %edi
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 18             	sub    $0x18,%esp
  801197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	53                   	push   %ebx
  80119f:	e8 b4 fc ff ff       	call   800e58 <fd_lookup>
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 37                	js     8011e2 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ab:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	ff 36                	push   (%esi)
  8011b7:	e8 ec fc ff ff       	call   800ea8 <dev_lookup>
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 1f                	js     8011e2 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c3:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011c7:	74 20                	je     8011e9 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	74 37                	je     80120a <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	ff 75 10             	push   0x10(%ebp)
  8011d9:	ff 75 0c             	push   0xc(%ebp)
  8011dc:	56                   	push   %esi
  8011dd:	ff d0                	call   *%eax
  8011df:	83 c4 10             	add    $0x10,%esp
}
  8011e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5e                   	pop    %esi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e9:	a1 00 40 80 00       	mov    0x804000,%eax
  8011ee:	8b 40 58             	mov    0x58(%eax),%eax
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	53                   	push   %ebx
  8011f5:	50                   	push   %eax
  8011f6:	68 a9 2c 80 00       	push   $0x802ca9
  8011fb:	e8 b9 ef ff ff       	call   8001b9 <cprintf>
		return -E_INVAL;
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801208:	eb d8                	jmp    8011e2 <write+0x53>
		return -E_NOT_SUPP;
  80120a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80120f:	eb d1                	jmp    8011e2 <write+0x53>

00801211 <seek>:

int
seek(int fdnum, off_t offset)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801217:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	ff 75 08             	push   0x8(%ebp)
  80121e:	e8 35 fc ff ff       	call   800e58 <fd_lookup>
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	85 c0                	test   %eax,%eax
  801228:	78 0e                	js     801238 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80122a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801230:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801233:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	56                   	push   %esi
  80123e:	53                   	push   %ebx
  80123f:	83 ec 18             	sub    $0x18,%esp
  801242:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801245:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801248:	50                   	push   %eax
  801249:	53                   	push   %ebx
  80124a:	e8 09 fc ff ff       	call   800e58 <fd_lookup>
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	85 c0                	test   %eax,%eax
  801254:	78 34                	js     80128a <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801256:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801259:	83 ec 08             	sub    $0x8,%esp
  80125c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125f:	50                   	push   %eax
  801260:	ff 36                	push   (%esi)
  801262:	e8 41 fc ff ff       	call   800ea8 <dev_lookup>
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 1c                	js     80128a <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801272:	74 1d                	je     801291 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801274:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801277:	8b 40 18             	mov    0x18(%eax),%eax
  80127a:	85 c0                	test   %eax,%eax
  80127c:	74 34                	je     8012b2 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80127e:	83 ec 08             	sub    $0x8,%esp
  801281:	ff 75 0c             	push   0xc(%ebp)
  801284:	56                   	push   %esi
  801285:	ff d0                	call   *%eax
  801287:	83 c4 10             	add    $0x10,%esp
}
  80128a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    
			thisenv->env_id, fdnum);
  801291:	a1 00 40 80 00       	mov    0x804000,%eax
  801296:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801299:	83 ec 04             	sub    $0x4,%esp
  80129c:	53                   	push   %ebx
  80129d:	50                   	push   %eax
  80129e:	68 6c 2c 80 00       	push   $0x802c6c
  8012a3:	e8 11 ef ff ff       	call   8001b9 <cprintf>
		return -E_INVAL;
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b0:	eb d8                	jmp    80128a <ftruncate+0x50>
		return -E_NOT_SUPP;
  8012b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012b7:	eb d1                	jmp    80128a <ftruncate+0x50>

008012b9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	56                   	push   %esi
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 18             	sub    $0x18,%esp
  8012c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c7:	50                   	push   %eax
  8012c8:	ff 75 08             	push   0x8(%ebp)
  8012cb:	e8 88 fb ff ff       	call   800e58 <fd_lookup>
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 49                	js     801320 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d7:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012da:	83 ec 08             	sub    $0x8,%esp
  8012dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	ff 36                	push   (%esi)
  8012e3:	e8 c0 fb ff ff       	call   800ea8 <dev_lookup>
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 31                	js     801320 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8012ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012f6:	74 2f                	je     801327 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801302:	00 00 00 
	stat->st_isdir = 0;
  801305:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80130c:	00 00 00 
	stat->st_dev = dev;
  80130f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	53                   	push   %ebx
  801319:	56                   	push   %esi
  80131a:	ff 50 14             	call   *0x14(%eax)
  80131d:	83 c4 10             	add    $0x10,%esp
}
  801320:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801323:	5b                   	pop    %ebx
  801324:	5e                   	pop    %esi
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    
		return -E_NOT_SUPP;
  801327:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80132c:	eb f2                	jmp    801320 <fstat+0x67>

0080132e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	56                   	push   %esi
  801332:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	6a 00                	push   $0x0
  801338:	ff 75 08             	push   0x8(%ebp)
  80133b:	e8 e4 01 00 00       	call   801524 <open>
  801340:	89 c3                	mov    %eax,%ebx
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	85 c0                	test   %eax,%eax
  801347:	78 1b                	js     801364 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	ff 75 0c             	push   0xc(%ebp)
  80134f:	50                   	push   %eax
  801350:	e8 64 ff ff ff       	call   8012b9 <fstat>
  801355:	89 c6                	mov    %eax,%esi
	close(fd);
  801357:	89 1c 24             	mov    %ebx,(%esp)
  80135a:	e8 26 fc ff ff       	call   800f85 <close>
	return r;
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	89 f3                	mov    %esi,%ebx
}
  801364:	89 d8                	mov    %ebx,%eax
  801366:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801369:	5b                   	pop    %ebx
  80136a:	5e                   	pop    %esi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    

0080136d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
  801372:	89 c6                	mov    %eax,%esi
  801374:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801376:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80137d:	74 27                	je     8013a6 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80137f:	6a 07                	push   $0x7
  801381:	68 00 50 80 00       	push   $0x805000
  801386:	56                   	push   %esi
  801387:	ff 35 00 60 80 00    	push   0x806000
  80138d:	e8 e2 11 00 00       	call   802574 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801392:	83 c4 0c             	add    $0xc,%esp
  801395:	6a 00                	push   $0x0
  801397:	53                   	push   %ebx
  801398:	6a 00                	push   $0x0
  80139a:	e8 65 11 00 00       	call   802504 <ipc_recv>
}
  80139f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a2:	5b                   	pop    %ebx
  8013a3:	5e                   	pop    %esi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013a6:	83 ec 0c             	sub    $0xc,%esp
  8013a9:	6a 01                	push   $0x1
  8013ab:	e8 18 12 00 00       	call   8025c8 <ipc_find_env>
  8013b0:	a3 00 60 80 00       	mov    %eax,0x806000
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	eb c5                	jmp    80137f <fsipc+0x12>

008013ba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ce:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d8:	b8 02 00 00 00       	mov    $0x2,%eax
  8013dd:	e8 8b ff ff ff       	call   80136d <fsipc>
}
  8013e2:	c9                   	leave  
  8013e3:	c3                   	ret    

008013e4 <devfile_flush>:
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8013ff:	e8 69 ff ff ff       	call   80136d <fsipc>
}
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <devfile_stat>:
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	53                   	push   %ebx
  80140a:	83 ec 04             	sub    $0x4,%esp
  80140d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	8b 40 0c             	mov    0xc(%eax),%eax
  801416:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80141b:	ba 00 00 00 00       	mov    $0x0,%edx
  801420:	b8 05 00 00 00       	mov    $0x5,%eax
  801425:	e8 43 ff ff ff       	call   80136d <fsipc>
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 2c                	js     80145a <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	68 00 50 80 00       	push   $0x805000
  801436:	53                   	push   %ebx
  801437:	e8 57 f3 ff ff       	call   800793 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80143c:	a1 80 50 80 00       	mov    0x805080,%eax
  801441:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801447:	a1 84 50 80 00       	mov    0x805084,%eax
  80144c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145d:	c9                   	leave  
  80145e:	c3                   	ret    

0080145f <devfile_write>:
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	83 ec 0c             	sub    $0xc,%esp
  801465:	8b 45 10             	mov    0x10(%ebp),%eax
  801468:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80146d:	39 d0                	cmp    %edx,%eax
  80146f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801472:	8b 55 08             	mov    0x8(%ebp),%edx
  801475:	8b 52 0c             	mov    0xc(%edx),%edx
  801478:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80147e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801483:	50                   	push   %eax
  801484:	ff 75 0c             	push   0xc(%ebp)
  801487:	68 08 50 80 00       	push   $0x805008
  80148c:	e8 98 f4 ff ff       	call   800929 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801491:	ba 00 00 00 00       	mov    $0x0,%edx
  801496:	b8 04 00 00 00       	mov    $0x4,%eax
  80149b:	e8 cd fe ff ff       	call   80136d <fsipc>
}
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <devfile_read>:
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	56                   	push   %esi
  8014a6:	53                   	push   %ebx
  8014a7:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014b5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c5:	e8 a3 fe ff ff       	call   80136d <fsipc>
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 1f                	js     8014ef <devfile_read+0x4d>
	assert(r <= n);
  8014d0:	39 f0                	cmp    %esi,%eax
  8014d2:	77 24                	ja     8014f8 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8014d4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014d9:	7f 33                	jg     80150e <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014db:	83 ec 04             	sub    $0x4,%esp
  8014de:	50                   	push   %eax
  8014df:	68 00 50 80 00       	push   $0x805000
  8014e4:	ff 75 0c             	push   0xc(%ebp)
  8014e7:	e8 3d f4 ff ff       	call   800929 <memmove>
	return r;
  8014ec:	83 c4 10             	add    $0x10,%esp
}
  8014ef:	89 d8                	mov    %ebx,%eax
  8014f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    
	assert(r <= n);
  8014f8:	68 dc 2c 80 00       	push   $0x802cdc
  8014fd:	68 e3 2c 80 00       	push   $0x802ce3
  801502:	6a 7c                	push   $0x7c
  801504:	68 f8 2c 80 00       	push   $0x802cf8
  801509:	e8 d0 eb ff ff       	call   8000de <_panic>
	assert(r <= PGSIZE);
  80150e:	68 03 2d 80 00       	push   $0x802d03
  801513:	68 e3 2c 80 00       	push   $0x802ce3
  801518:	6a 7d                	push   $0x7d
  80151a:	68 f8 2c 80 00       	push   $0x802cf8
  80151f:	e8 ba eb ff ff       	call   8000de <_panic>

00801524 <open>:
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	56                   	push   %esi
  801528:	53                   	push   %ebx
  801529:	83 ec 1c             	sub    $0x1c,%esp
  80152c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80152f:	56                   	push   %esi
  801530:	e8 23 f2 ff ff       	call   800758 <strlen>
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80153d:	7f 6c                	jg     8015ab <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80153f:	83 ec 0c             	sub    $0xc,%esp
  801542:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801545:	50                   	push   %eax
  801546:	e8 bd f8 ff ff       	call   800e08 <fd_alloc>
  80154b:	89 c3                	mov    %eax,%ebx
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	78 3c                	js     801590 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801554:	83 ec 08             	sub    $0x8,%esp
  801557:	56                   	push   %esi
  801558:	68 00 50 80 00       	push   $0x805000
  80155d:	e8 31 f2 ff ff       	call   800793 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801562:	8b 45 0c             	mov    0xc(%ebp),%eax
  801565:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80156a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156d:	b8 01 00 00 00       	mov    $0x1,%eax
  801572:	e8 f6 fd ff ff       	call   80136d <fsipc>
  801577:	89 c3                	mov    %eax,%ebx
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 19                	js     801599 <open+0x75>
	return fd2num(fd);
  801580:	83 ec 0c             	sub    $0xc,%esp
  801583:	ff 75 f4             	push   -0xc(%ebp)
  801586:	e8 56 f8 ff ff       	call   800de1 <fd2num>
  80158b:	89 c3                	mov    %eax,%ebx
  80158d:	83 c4 10             	add    $0x10,%esp
}
  801590:	89 d8                	mov    %ebx,%eax
  801592:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801595:	5b                   	pop    %ebx
  801596:	5e                   	pop    %esi
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    
		fd_close(fd, 0);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	6a 00                	push   $0x0
  80159e:	ff 75 f4             	push   -0xc(%ebp)
  8015a1:	e8 58 f9 ff ff       	call   800efe <fd_close>
		return r;
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	eb e5                	jmp    801590 <open+0x6c>
		return -E_BAD_PATH;
  8015ab:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015b0:	eb de                	jmp    801590 <open+0x6c>

008015b2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c2:	e8 a6 fd ff ff       	call   80136d <fsipc>
}
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	57                   	push   %edi
  8015cd:	56                   	push   %esi
  8015ce:	53                   	push   %ebx
  8015cf:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015d5:	6a 00                	push   $0x0
  8015d7:	ff 75 08             	push   0x8(%ebp)
  8015da:	e8 45 ff ff ff       	call   801524 <open>
  8015df:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	0f 88 ad 04 00 00    	js     801a9d <spawn+0x4d4>
  8015f0:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015f2:	83 ec 04             	sub    $0x4,%esp
  8015f5:	68 00 02 00 00       	push   $0x200
  8015fa:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	57                   	push   %edi
  801602:	e8 41 fb ff ff       	call   801148 <readn>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	3d 00 02 00 00       	cmp    $0x200,%eax
  80160f:	75 5a                	jne    80166b <spawn+0xa2>
	    || elf->e_magic != ELF_MAGIC) {
  801611:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801618:	45 4c 46 
  80161b:	75 4e                	jne    80166b <spawn+0xa2>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80161d:	b8 07 00 00 00       	mov    $0x7,%eax
  801622:	cd 30                	int    $0x30
  801624:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80162a:	85 c0                	test   %eax,%eax
  80162c:	0f 88 5f 04 00 00    	js     801a91 <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801632:	25 ff 03 00 00       	and    $0x3ff,%eax
  801637:	69 f0 8c 00 00 00    	imul   $0x8c,%eax,%esi
  80163d:	81 c6 10 00 c0 ee    	add    $0xeec00010,%esi
  801643:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801649:	b9 11 00 00 00       	mov    $0x11,%ecx
  80164e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801650:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801656:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80165c:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801661:	be 00 00 00 00       	mov    $0x0,%esi
  801666:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  801669:	eb 4b                	jmp    8016b6 <spawn+0xed>
		close(fd);
  80166b:	83 ec 0c             	sub    $0xc,%esp
  80166e:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801674:	e8 0c f9 ff ff       	call   800f85 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801679:	83 c4 0c             	add    $0xc,%esp
  80167c:	68 7f 45 4c 46       	push   $0x464c457f
  801681:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  801687:	68 0f 2d 80 00       	push   $0x802d0f
  80168c:	e8 28 eb ff ff       	call   8001b9 <cprintf>
		return -E_NOT_EXEC;
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  80169b:	ff ff ff 
  80169e:	e9 fa 03 00 00       	jmp    801a9d <spawn+0x4d4>
		string_size += strlen(argv[argc]) + 1;
  8016a3:	83 ec 0c             	sub    $0xc,%esp
  8016a6:	50                   	push   %eax
  8016a7:	e8 ac f0 ff ff       	call   800758 <strlen>
  8016ac:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8016b0:	83 c3 01             	add    $0x1,%ebx
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016bd:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	75 df                	jne    8016a3 <spawn+0xda>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016c4:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8016ca:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8016d0:	b8 00 10 40 00       	mov    $0x401000,%eax
  8016d5:	29 f0                	sub    %esi,%eax
  8016d7:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016d9:	89 c2                	mov    %eax,%edx
  8016db:	83 e2 fc             	and    $0xfffffffc,%edx
  8016de:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016e5:	29 c2                	sub    %eax,%edx
  8016e7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016ed:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016f0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016f5:	0f 86 14 04 00 00    	jbe    801b0f <spawn+0x546>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016fb:	83 ec 04             	sub    $0x4,%esp
  8016fe:	6a 07                	push   $0x7
  801700:	68 00 00 40 00       	push   $0x400000
  801705:	6a 00                	push   $0x0
  801707:	e8 83 f4 ff ff       	call   800b8f <sys_page_alloc>
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	0f 88 fd 03 00 00    	js     801b14 <spawn+0x54b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801717:	be 00 00 00 00       	mov    $0x0,%esi
  80171c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801725:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80172b:	7e 32                	jle    80175f <spawn+0x196>
		argv_store[i] = UTEMP2USTACK(string_store);
  80172d:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801733:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801739:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80173c:	83 ec 08             	sub    $0x8,%esp
  80173f:	ff 34 b3             	push   (%ebx,%esi,4)
  801742:	57                   	push   %edi
  801743:	e8 4b f0 ff ff       	call   800793 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801748:	83 c4 04             	add    $0x4,%esp
  80174b:	ff 34 b3             	push   (%ebx,%esi,4)
  80174e:	e8 05 f0 ff ff       	call   800758 <strlen>
  801753:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801757:	83 c6 01             	add    $0x1,%esi
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	eb c6                	jmp    801725 <spawn+0x15c>
	}
	argv_store[argc] = 0;
  80175f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801765:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80176b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801772:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801778:	0f 85 8c 00 00 00    	jne    80180a <spawn+0x241>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80177e:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801784:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  80178a:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  80178d:	89 c8                	mov    %ecx,%eax
  80178f:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801795:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801798:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80179d:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017a3:	83 ec 0c             	sub    $0xc,%esp
  8017a6:	6a 07                	push   $0x7
  8017a8:	68 00 d0 bf ee       	push   $0xeebfd000
  8017ad:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8017b3:	68 00 00 40 00       	push   $0x400000
  8017b8:	6a 00                	push   $0x0
  8017ba:	e8 13 f4 ff ff       	call   800bd2 <sys_page_map>
  8017bf:	89 c3                	mov    %eax,%ebx
  8017c1:	83 c4 20             	add    $0x20,%esp
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	0f 88 50 03 00 00    	js     801b1c <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	68 00 00 40 00       	push   $0x400000
  8017d4:	6a 00                	push   $0x0
  8017d6:	e8 39 f4 ff ff       	call   800c14 <sys_page_unmap>
  8017db:	89 c3                	mov    %eax,%ebx
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	0f 88 34 03 00 00    	js     801b1c <spawn+0x553>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017e8:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017ee:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017f5:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017fb:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801802:	00 00 00 
  801805:	e9 4e 01 00 00       	jmp    801958 <spawn+0x38f>
	assert(string_store == (char*)UTEMP + PGSIZE);
  80180a:	68 9c 2d 80 00       	push   $0x802d9c
  80180f:	68 e3 2c 80 00       	push   $0x802ce3
  801814:	68 f2 00 00 00       	push   $0xf2
  801819:	68 29 2d 80 00       	push   $0x802d29
  80181e:	e8 bb e8 ff ff       	call   8000de <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	6a 07                	push   $0x7
  801828:	68 00 00 40 00       	push   $0x400000
  80182d:	6a 00                	push   $0x0
  80182f:	e8 5b f3 ff ff       	call   800b8f <sys_page_alloc>
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	0f 88 6c 02 00 00    	js     801aab <spawn+0x4e2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801848:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80184e:	50                   	push   %eax
  80184f:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801855:	e8 b7 f9 ff ff       	call   801211 <seek>
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	0f 88 4d 02 00 00    	js     801ab2 <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801865:	83 ec 04             	sub    $0x4,%esp
  801868:	89 f8                	mov    %edi,%eax
  80186a:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801870:	ba 00 10 00 00       	mov    $0x1000,%edx
  801875:	39 d0                	cmp    %edx,%eax
  801877:	0f 47 c2             	cmova  %edx,%eax
  80187a:	50                   	push   %eax
  80187b:	68 00 00 40 00       	push   $0x400000
  801880:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801886:	e8 bd f8 ff ff       	call   801148 <readn>
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	0f 88 23 02 00 00    	js     801ab9 <spawn+0x4f0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801896:	83 ec 0c             	sub    $0xc,%esp
  801899:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  80189f:	56                   	push   %esi
  8018a0:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8018a6:	68 00 00 40 00       	push   $0x400000
  8018ab:	6a 00                	push   $0x0
  8018ad:	e8 20 f3 ff ff       	call   800bd2 <sys_page_map>
  8018b2:	83 c4 20             	add    $0x20,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	78 7c                	js     801935 <spawn+0x36c>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  8018b9:	83 ec 08             	sub    $0x8,%esp
  8018bc:	68 00 00 40 00       	push   $0x400000
  8018c1:	6a 00                	push   $0x0
  8018c3:	e8 4c f3 ff ff       	call   800c14 <sys_page_unmap>
  8018c8:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  8018cb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8018d1:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8018d7:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8018dd:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8018e3:	76 65                	jbe    80194a <spawn+0x381>
		if (i >= filesz) {
  8018e5:	39 df                	cmp    %ebx,%edi
  8018e7:	0f 87 36 ff ff ff    	ja     801823 <spawn+0x25a>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018ed:	83 ec 04             	sub    $0x4,%esp
  8018f0:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  8018f6:	56                   	push   %esi
  8018f7:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  8018fd:	e8 8d f2 ff ff       	call   800b8f <sys_page_alloc>
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	85 c0                	test   %eax,%eax
  801907:	79 c2                	jns    8018cb <spawn+0x302>
  801909:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  80190b:	83 ec 0c             	sub    $0xc,%esp
  80190e:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801914:	e8 f7 f1 ff ff       	call   800b10 <sys_env_destroy>
	close(fd);
  801919:	83 c4 04             	add    $0x4,%esp
  80191c:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801922:	e8 5e f6 ff ff       	call   800f85 <close>
	return r;
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  801930:	e9 68 01 00 00       	jmp    801a9d <spawn+0x4d4>
				panic("spawn: sys_page_map data: %e", r);
  801935:	50                   	push   %eax
  801936:	68 35 2d 80 00       	push   $0x802d35
  80193b:	68 25 01 00 00       	push   $0x125
  801940:	68 29 2d 80 00       	push   $0x802d29
  801945:	e8 94 e7 ff ff       	call   8000de <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80194a:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801951:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801958:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80195f:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801965:	7e 67                	jle    8019ce <spawn+0x405>
		if (ph->p_type != ELF_PROG_LOAD)
  801967:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  80196d:	83 39 01             	cmpl   $0x1,(%ecx)
  801970:	75 d8                	jne    80194a <spawn+0x381>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801972:	8b 41 18             	mov    0x18(%ecx),%eax
  801975:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80197b:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80197e:	83 f8 01             	cmp    $0x1,%eax
  801981:	19 c0                	sbb    %eax,%eax
  801983:	83 e0 fe             	and    $0xfffffffe,%eax
  801986:	83 c0 07             	add    $0x7,%eax
  801989:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80198f:	8b 51 04             	mov    0x4(%ecx),%edx
  801992:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801998:	8b 79 10             	mov    0x10(%ecx),%edi
  80199b:	8b 59 14             	mov    0x14(%ecx),%ebx
  80199e:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019a4:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  8019a7:	89 f0                	mov    %esi,%eax
  8019a9:	25 ff 0f 00 00       	and    $0xfff,%eax
  8019ae:	74 14                	je     8019c4 <spawn+0x3fb>
		va -= i;
  8019b0:	29 c6                	sub    %eax,%esi
		memsz += i;
  8019b2:	01 c3                	add    %eax,%ebx
  8019b4:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  8019ba:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8019bc:	29 c2                	sub    %eax,%edx
  8019be:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8019c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019c9:	e9 09 ff ff ff       	jmp    8018d7 <spawn+0x30e>
	close(fd);
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  8019d7:	e8 a9 f5 ff ff       	call   800f85 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  8019dc:	e8 70 f1 ff ff       	call   800b51 <sys_getenvid>
  8019e1:	89 c6                	mov    %eax,%esi
  8019e3:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8019e6:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8019eb:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  8019f1:	eb 12                	jmp    801a05 <spawn+0x43c>
  8019f3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019f9:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8019ff:	0f 84 bb 00 00 00    	je     801ac0 <spawn+0x4f7>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801a05:	89 d8                	mov    %ebx,%eax
  801a07:	c1 e8 16             	shr    $0x16,%eax
  801a0a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a11:	a8 01                	test   $0x1,%al
  801a13:	74 de                	je     8019f3 <spawn+0x42a>
  801a15:	89 d8                	mov    %ebx,%eax
  801a17:	c1 e8 0c             	shr    $0xc,%eax
  801a1a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a21:	f6 c2 01             	test   $0x1,%dl
  801a24:	74 cd                	je     8019f3 <spawn+0x42a>
  801a26:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a2d:	f6 c6 04             	test   $0x4,%dh
  801a30:	74 c1                	je     8019f3 <spawn+0x42a>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801a32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a39:	83 ec 0c             	sub    $0xc,%esp
  801a3c:	25 07 0e 00 00       	and    $0xe07,%eax
  801a41:	50                   	push   %eax
  801a42:	53                   	push   %ebx
  801a43:	57                   	push   %edi
  801a44:	53                   	push   %ebx
  801a45:	56                   	push   %esi
  801a46:	e8 87 f1 ff ff       	call   800bd2 <sys_page_map>
  801a4b:	83 c4 20             	add    $0x20,%esp
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	79 a1                	jns    8019f3 <spawn+0x42a>
		panic("copy_shared_pages: %e", r);
  801a52:	50                   	push   %eax
  801a53:	68 83 2d 80 00       	push   $0x802d83
  801a58:	68 82 00 00 00       	push   $0x82
  801a5d:	68 29 2d 80 00       	push   $0x802d29
  801a62:	e8 77 e6 ff ff       	call   8000de <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801a67:	50                   	push   %eax
  801a68:	68 52 2d 80 00       	push   $0x802d52
  801a6d:	68 86 00 00 00       	push   $0x86
  801a72:	68 29 2d 80 00       	push   $0x802d29
  801a77:	e8 62 e6 ff ff       	call   8000de <_panic>
		panic("sys_env_set_status: %e", r);
  801a7c:	50                   	push   %eax
  801a7d:	68 6c 2d 80 00       	push   $0x802d6c
  801a82:	68 89 00 00 00       	push   $0x89
  801a87:	68 29 2d 80 00       	push   $0x802d29
  801a8c:	e8 4d e6 ff ff       	call   8000de <_panic>
		return r;
  801a91:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a97:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801a9d:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5f                   	pop    %edi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    
  801aab:	89 c7                	mov    %eax,%edi
  801aad:	e9 59 fe ff ff       	jmp    80190b <spawn+0x342>
  801ab2:	89 c7                	mov    %eax,%edi
  801ab4:	e9 52 fe ff ff       	jmp    80190b <spawn+0x342>
  801ab9:	89 c7                	mov    %eax,%edi
  801abb:	e9 4b fe ff ff       	jmp    80190b <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ac0:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ac7:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801aca:	83 ec 08             	sub    $0x8,%esp
  801acd:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ad3:	50                   	push   %eax
  801ad4:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801ada:	e8 b9 f1 ff ff       	call   800c98 <sys_env_set_trapframe>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	78 81                	js     801a67 <spawn+0x49e>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ae6:	83 ec 08             	sub    $0x8,%esp
  801ae9:	6a 02                	push   $0x2
  801aeb:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801af1:	e8 60 f1 ff ff       	call   800c56 <sys_env_set_status>
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	85 c0                	test   %eax,%eax
  801afb:	0f 88 7b ff ff ff    	js     801a7c <spawn+0x4b3>
	return child;
  801b01:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b07:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801b0d:	eb 8e                	jmp    801a9d <spawn+0x4d4>
		return -E_NO_MEM;
  801b0f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801b14:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801b1a:	eb 81                	jmp    801a9d <spawn+0x4d4>
	sys_page_unmap(0, UTEMP);
  801b1c:	83 ec 08             	sub    $0x8,%esp
  801b1f:	68 00 00 40 00       	push   $0x400000
  801b24:	6a 00                	push   $0x0
  801b26:	e8 e9 f0 ff ff       	call   800c14 <sys_page_unmap>
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801b34:	e9 64 ff ff ff       	jmp    801a9d <spawn+0x4d4>

00801b39 <spawnl>:
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	56                   	push   %esi
  801b3d:	53                   	push   %ebx
	va_start(vl, arg0);
  801b3e:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801b41:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801b46:	eb 05                	jmp    801b4d <spawnl+0x14>
		argc++;
  801b48:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801b4b:	89 ca                	mov    %ecx,%edx
  801b4d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b50:	83 3a 00             	cmpl   $0x0,(%edx)
  801b53:	75 f3                	jne    801b48 <spawnl+0xf>
	const char *argv[argc+2];
  801b55:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801b5c:	89 d3                	mov    %edx,%ebx
  801b5e:	83 e3 f0             	and    $0xfffffff0,%ebx
  801b61:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801b67:	89 e1                	mov    %esp,%ecx
  801b69:	29 d1                	sub    %edx,%ecx
  801b6b:	39 cc                	cmp    %ecx,%esp
  801b6d:	74 10                	je     801b7f <spawnl+0x46>
  801b6f:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801b75:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801b7c:	00 
  801b7d:	eb ec                	jmp    801b6b <spawnl+0x32>
  801b7f:	89 da                	mov    %ebx,%edx
  801b81:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801b87:	29 d4                	sub    %edx,%esp
  801b89:	85 d2                	test   %edx,%edx
  801b8b:	74 05                	je     801b92 <spawnl+0x59>
  801b8d:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801b92:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801b96:	89 da                	mov    %ebx,%edx
  801b98:	c1 ea 02             	shr    $0x2,%edx
  801b9b:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba1:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ba8:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801baf:	00 
	va_start(vl, arg0);
  801bb0:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801bb3:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bba:	eb 0b                	jmp    801bc7 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801bbc:	83 c0 01             	add    $0x1,%eax
  801bbf:	8b 31                	mov    (%ecx),%esi
  801bc1:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801bc4:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801bc7:	39 d0                	cmp    %edx,%eax
  801bc9:	75 f1                	jne    801bbc <spawnl+0x83>
	return spawn(prog, argv);
  801bcb:	83 ec 08             	sub    $0x8,%esp
  801bce:	53                   	push   %ebx
  801bcf:	ff 75 08             	push   0x8(%ebp)
  801bd2:	e8 f2 f9 ff ff       	call   8015c9 <spawn>
}
  801bd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5e                   	pop    %esi
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801be4:	68 c2 2d 80 00       	push   $0x802dc2
  801be9:	ff 75 0c             	push   0xc(%ebp)
  801bec:	e8 a2 eb ff ff       	call   800793 <strcpy>
	return 0;
}
  801bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <devsock_close>:
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	53                   	push   %ebx
  801bfc:	83 ec 10             	sub    $0x10,%esp
  801bff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c02:	53                   	push   %ebx
  801c03:	e8 ff 09 00 00       	call   802607 <pageref>
  801c08:	89 c2                	mov    %eax,%edx
  801c0a:	83 c4 10             	add    $0x10,%esp
		return 0;
  801c0d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801c12:	83 fa 01             	cmp    $0x1,%edx
  801c15:	74 05                	je     801c1c <devsock_close+0x24>
}
  801c17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1a:	c9                   	leave  
  801c1b:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	ff 73 0c             	push   0xc(%ebx)
  801c22:	e8 b7 02 00 00       	call   801ede <nsipc_close>
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	eb eb                	jmp    801c17 <devsock_close+0x1f>

00801c2c <devsock_write>:
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c32:	6a 00                	push   $0x0
  801c34:	ff 75 10             	push   0x10(%ebp)
  801c37:	ff 75 0c             	push   0xc(%ebp)
  801c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3d:	ff 70 0c             	push   0xc(%eax)
  801c40:	e8 79 03 00 00       	call   801fbe <nsipc_send>
}
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <devsock_read>:
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c4d:	6a 00                	push   $0x0
  801c4f:	ff 75 10             	push   0x10(%ebp)
  801c52:	ff 75 0c             	push   0xc(%ebp)
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
  801c58:	ff 70 0c             	push   0xc(%eax)
  801c5b:	e8 ef 02 00 00       	call   801f4f <nsipc_recv>
}
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <fd2sockid>:
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c68:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c6b:	52                   	push   %edx
  801c6c:	50                   	push   %eax
  801c6d:	e8 e6 f1 ff ff       	call   800e58 <fd_lookup>
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	85 c0                	test   %eax,%eax
  801c77:	78 10                	js     801c89 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c82:	39 08                	cmp    %ecx,(%eax)
  801c84:	75 05                	jne    801c8b <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801c86:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    
		return -E_NOT_SUPP;
  801c8b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c90:	eb f7                	jmp    801c89 <fd2sockid+0x27>

00801c92 <alloc_sockfd>:
{
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	56                   	push   %esi
  801c96:	53                   	push   %ebx
  801c97:	83 ec 1c             	sub    $0x1c,%esp
  801c9a:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801c9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9f:	50                   	push   %eax
  801ca0:	e8 63 f1 ff ff       	call   800e08 <fd_alloc>
  801ca5:	89 c3                	mov    %eax,%ebx
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 43                	js     801cf1 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cae:	83 ec 04             	sub    $0x4,%esp
  801cb1:	68 07 04 00 00       	push   $0x407
  801cb6:	ff 75 f4             	push   -0xc(%ebp)
  801cb9:	6a 00                	push   $0x0
  801cbb:	e8 cf ee ff ff       	call   800b8f <sys_page_alloc>
  801cc0:	89 c3                	mov    %eax,%ebx
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 28                	js     801cf1 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801cde:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ce1:	83 ec 0c             	sub    $0xc,%esp
  801ce4:	50                   	push   %eax
  801ce5:	e8 f7 f0 ff ff       	call   800de1 <fd2num>
  801cea:	89 c3                	mov    %eax,%ebx
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	eb 0c                	jmp    801cfd <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801cf1:	83 ec 0c             	sub    $0xc,%esp
  801cf4:	56                   	push   %esi
  801cf5:	e8 e4 01 00 00       	call   801ede <nsipc_close>
		return r;
  801cfa:	83 c4 10             	add    $0x10,%esp
}
  801cfd:	89 d8                	mov    %ebx,%eax
  801cff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d02:	5b                   	pop    %ebx
  801d03:	5e                   	pop    %esi
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    

00801d06 <accept>:
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	e8 4e ff ff ff       	call   801c62 <fd2sockid>
  801d14:	85 c0                	test   %eax,%eax
  801d16:	78 1b                	js     801d33 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d18:	83 ec 04             	sub    $0x4,%esp
  801d1b:	ff 75 10             	push   0x10(%ebp)
  801d1e:	ff 75 0c             	push   0xc(%ebp)
  801d21:	50                   	push   %eax
  801d22:	e8 0e 01 00 00       	call   801e35 <nsipc_accept>
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 05                	js     801d33 <accept+0x2d>
	return alloc_sockfd(r);
  801d2e:	e8 5f ff ff ff       	call   801c92 <alloc_sockfd>
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <bind>:
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3e:	e8 1f ff ff ff       	call   801c62 <fd2sockid>
  801d43:	85 c0                	test   %eax,%eax
  801d45:	78 12                	js     801d59 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801d47:	83 ec 04             	sub    $0x4,%esp
  801d4a:	ff 75 10             	push   0x10(%ebp)
  801d4d:	ff 75 0c             	push   0xc(%ebp)
  801d50:	50                   	push   %eax
  801d51:	e8 31 01 00 00       	call   801e87 <nsipc_bind>
  801d56:	83 c4 10             	add    $0x10,%esp
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <shutdown>:
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d61:	8b 45 08             	mov    0x8(%ebp),%eax
  801d64:	e8 f9 fe ff ff       	call   801c62 <fd2sockid>
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	78 0f                	js     801d7c <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801d6d:	83 ec 08             	sub    $0x8,%esp
  801d70:	ff 75 0c             	push   0xc(%ebp)
  801d73:	50                   	push   %eax
  801d74:	e8 43 01 00 00       	call   801ebc <nsipc_shutdown>
  801d79:	83 c4 10             	add    $0x10,%esp
}
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <connect>:
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d84:	8b 45 08             	mov    0x8(%ebp),%eax
  801d87:	e8 d6 fe ff ff       	call   801c62 <fd2sockid>
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	78 12                	js     801da2 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801d90:	83 ec 04             	sub    $0x4,%esp
  801d93:	ff 75 10             	push   0x10(%ebp)
  801d96:	ff 75 0c             	push   0xc(%ebp)
  801d99:	50                   	push   %eax
  801d9a:	e8 59 01 00 00       	call   801ef8 <nsipc_connect>
  801d9f:	83 c4 10             	add    $0x10,%esp
}
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <listen>:
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801daa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dad:	e8 b0 fe ff ff       	call   801c62 <fd2sockid>
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 0f                	js     801dc5 <listen+0x21>
	return nsipc_listen(r, backlog);
  801db6:	83 ec 08             	sub    $0x8,%esp
  801db9:	ff 75 0c             	push   0xc(%ebp)
  801dbc:	50                   	push   %eax
  801dbd:	e8 6b 01 00 00       	call   801f2d <nsipc_listen>
  801dc2:	83 c4 10             	add    $0x10,%esp
}
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    

00801dc7 <socket>:

int
socket(int domain, int type, int protocol)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801dcd:	ff 75 10             	push   0x10(%ebp)
  801dd0:	ff 75 0c             	push   0xc(%ebp)
  801dd3:	ff 75 08             	push   0x8(%ebp)
  801dd6:	e8 41 02 00 00       	call   80201c <nsipc_socket>
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 05                	js     801de7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801de2:	e8 ab fe ff ff       	call   801c92 <alloc_sockfd>
}
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	53                   	push   %ebx
  801ded:	83 ec 04             	sub    $0x4,%esp
  801df0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801df2:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801df9:	74 26                	je     801e21 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801dfb:	6a 07                	push   $0x7
  801dfd:	68 00 70 80 00       	push   $0x807000
  801e02:	53                   	push   %ebx
  801e03:	ff 35 00 80 80 00    	push   0x808000
  801e09:	e8 66 07 00 00       	call   802574 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e0e:	83 c4 0c             	add    $0xc,%esp
  801e11:	6a 00                	push   $0x0
  801e13:	6a 00                	push   $0x0
  801e15:	6a 00                	push   $0x0
  801e17:	e8 e8 06 00 00       	call   802504 <ipc_recv>
}
  801e1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e21:	83 ec 0c             	sub    $0xc,%esp
  801e24:	6a 02                	push   $0x2
  801e26:	e8 9d 07 00 00       	call   8025c8 <ipc_find_env>
  801e2b:	a3 00 80 80 00       	mov    %eax,0x808000
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	eb c6                	jmp    801dfb <nsipc+0x12>

00801e35 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	56                   	push   %esi
  801e39:	53                   	push   %ebx
  801e3a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e40:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e45:	8b 06                	mov    (%esi),%eax
  801e47:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e51:	e8 93 ff ff ff       	call   801de9 <nsipc>
  801e56:	89 c3                	mov    %eax,%ebx
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	79 09                	jns    801e65 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801e5c:	89 d8                	mov    %ebx,%eax
  801e5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e61:	5b                   	pop    %ebx
  801e62:	5e                   	pop    %esi
  801e63:	5d                   	pop    %ebp
  801e64:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e65:	83 ec 04             	sub    $0x4,%esp
  801e68:	ff 35 10 70 80 00    	push   0x807010
  801e6e:	68 00 70 80 00       	push   $0x807000
  801e73:	ff 75 0c             	push   0xc(%ebp)
  801e76:	e8 ae ea ff ff       	call   800929 <memmove>
		*addrlen = ret->ret_addrlen;
  801e7b:	a1 10 70 80 00       	mov    0x807010,%eax
  801e80:	89 06                	mov    %eax,(%esi)
  801e82:	83 c4 10             	add    $0x10,%esp
	return r;
  801e85:	eb d5                	jmp    801e5c <nsipc_accept+0x27>

00801e87 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	53                   	push   %ebx
  801e8b:	83 ec 08             	sub    $0x8,%esp
  801e8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e91:	8b 45 08             	mov    0x8(%ebp),%eax
  801e94:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e99:	53                   	push   %ebx
  801e9a:	ff 75 0c             	push   0xc(%ebp)
  801e9d:	68 04 70 80 00       	push   $0x807004
  801ea2:	e8 82 ea ff ff       	call   800929 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ea7:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801ead:	b8 02 00 00 00       	mov    $0x2,%eax
  801eb2:	e8 32 ff ff ff       	call   801de9 <nsipc>
}
  801eb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eba:	c9                   	leave  
  801ebb:	c3                   	ret    

00801ebc <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ec2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ed2:	b8 03 00 00 00       	mov    $0x3,%eax
  801ed7:	e8 0d ff ff ff       	call   801de9 <nsipc>
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <nsipc_close>:

int
nsipc_close(int s)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee7:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801eec:	b8 04 00 00 00       	mov    $0x4,%eax
  801ef1:	e8 f3 fe ff ff       	call   801de9 <nsipc>
}
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	53                   	push   %ebx
  801efc:	83 ec 08             	sub    $0x8,%esp
  801eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f02:	8b 45 08             	mov    0x8(%ebp),%eax
  801f05:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f0a:	53                   	push   %ebx
  801f0b:	ff 75 0c             	push   0xc(%ebp)
  801f0e:	68 04 70 80 00       	push   $0x807004
  801f13:	e8 11 ea ff ff       	call   800929 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f18:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801f1e:	b8 05 00 00 00       	mov    $0x5,%eax
  801f23:	e8 c1 fe ff ff       	call   801de9 <nsipc>
}
  801f28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    

00801f2d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f33:	8b 45 08             	mov    0x8(%ebp),%eax
  801f36:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801f43:	b8 06 00 00 00       	mov    $0x6,%eax
  801f48:	e8 9c fe ff ff       	call   801de9 <nsipc>
}
  801f4d:	c9                   	leave  
  801f4e:	c3                   	ret    

00801f4f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f57:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801f5f:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801f65:	8b 45 14             	mov    0x14(%ebp),%eax
  801f68:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f6d:	b8 07 00 00 00       	mov    $0x7,%eax
  801f72:	e8 72 fe ff ff       	call   801de9 <nsipc>
  801f77:	89 c3                	mov    %eax,%ebx
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	78 22                	js     801f9f <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801f7d:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801f82:	39 c6                	cmp    %eax,%esi
  801f84:	0f 4e c6             	cmovle %esi,%eax
  801f87:	39 c3                	cmp    %eax,%ebx
  801f89:	7f 1d                	jg     801fa8 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f8b:	83 ec 04             	sub    $0x4,%esp
  801f8e:	53                   	push   %ebx
  801f8f:	68 00 70 80 00       	push   $0x807000
  801f94:	ff 75 0c             	push   0xc(%ebp)
  801f97:	e8 8d e9 ff ff       	call   800929 <memmove>
  801f9c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f9f:	89 d8                	mov    %ebx,%eax
  801fa1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa4:	5b                   	pop    %ebx
  801fa5:	5e                   	pop    %esi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801fa8:	68 ce 2d 80 00       	push   $0x802dce
  801fad:	68 e3 2c 80 00       	push   $0x802ce3
  801fb2:	6a 62                	push   $0x62
  801fb4:	68 e3 2d 80 00       	push   $0x802de3
  801fb9:	e8 20 e1 ff ff       	call   8000de <_panic>

00801fbe <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 04             	sub    $0x4,%esp
  801fc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801fd0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fd6:	7f 2e                	jg     802006 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fd8:	83 ec 04             	sub    $0x4,%esp
  801fdb:	53                   	push   %ebx
  801fdc:	ff 75 0c             	push   0xc(%ebp)
  801fdf:	68 0c 70 80 00       	push   $0x80700c
  801fe4:	e8 40 e9 ff ff       	call   800929 <memmove>
	nsipcbuf.send.req_size = size;
  801fe9:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801fef:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801ff7:	b8 08 00 00 00       	mov    $0x8,%eax
  801ffc:	e8 e8 fd ff ff       	call   801de9 <nsipc>
}
  802001:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802004:	c9                   	leave  
  802005:	c3                   	ret    
	assert(size < 1600);
  802006:	68 ef 2d 80 00       	push   $0x802def
  80200b:	68 e3 2c 80 00       	push   $0x802ce3
  802010:	6a 6d                	push   $0x6d
  802012:	68 e3 2d 80 00       	push   $0x802de3
  802017:	e8 c2 e0 ff ff       	call   8000de <_panic>

0080201c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802022:	8b 45 08             	mov    0x8(%ebp),%eax
  802025:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80202a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80202d:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802032:	8b 45 10             	mov    0x10(%ebp),%eax
  802035:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80203a:	b8 09 00 00 00       	mov    $0x9,%eax
  80203f:	e8 a5 fd ff ff       	call   801de9 <nsipc>
}
  802044:	c9                   	leave  
  802045:	c3                   	ret    

00802046 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	56                   	push   %esi
  80204a:	53                   	push   %ebx
  80204b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80204e:	83 ec 0c             	sub    $0xc,%esp
  802051:	ff 75 08             	push   0x8(%ebp)
  802054:	e8 98 ed ff ff       	call   800df1 <fd2data>
  802059:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80205b:	83 c4 08             	add    $0x8,%esp
  80205e:	68 fb 2d 80 00       	push   $0x802dfb
  802063:	53                   	push   %ebx
  802064:	e8 2a e7 ff ff       	call   800793 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802069:	8b 46 04             	mov    0x4(%esi),%eax
  80206c:	2b 06                	sub    (%esi),%eax
  80206e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802074:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80207b:	00 00 00 
	stat->st_dev = &devpipe;
  80207e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  802085:	30 80 00 
	return 0;
}
  802088:	b8 00 00 00 00       	mov    $0x0,%eax
  80208d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802090:	5b                   	pop    %ebx
  802091:	5e                   	pop    %esi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    

00802094 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	53                   	push   %ebx
  802098:	83 ec 0c             	sub    $0xc,%esp
  80209b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80209e:	53                   	push   %ebx
  80209f:	6a 00                	push   $0x0
  8020a1:	e8 6e eb ff ff       	call   800c14 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020a6:	89 1c 24             	mov    %ebx,(%esp)
  8020a9:	e8 43 ed ff ff       	call   800df1 <fd2data>
  8020ae:	83 c4 08             	add    $0x8,%esp
  8020b1:	50                   	push   %eax
  8020b2:	6a 00                	push   $0x0
  8020b4:	e8 5b eb ff ff       	call   800c14 <sys_page_unmap>
}
  8020b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020bc:	c9                   	leave  
  8020bd:	c3                   	ret    

008020be <_pipeisclosed>:
{
  8020be:	55                   	push   %ebp
  8020bf:	89 e5                	mov    %esp,%ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	89 c7                	mov    %eax,%edi
  8020c9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8020cb:	a1 00 40 80 00       	mov    0x804000,%eax
  8020d0:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020d3:	83 ec 0c             	sub    $0xc,%esp
  8020d6:	57                   	push   %edi
  8020d7:	e8 2b 05 00 00       	call   802607 <pageref>
  8020dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8020df:	89 34 24             	mov    %esi,(%esp)
  8020e2:	e8 20 05 00 00       	call   802607 <pageref>
		nn = thisenv->env_runs;
  8020e7:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8020ed:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8020f0:	83 c4 10             	add    $0x10,%esp
  8020f3:	39 cb                	cmp    %ecx,%ebx
  8020f5:	74 1b                	je     802112 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8020f7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020fa:	75 cf                	jne    8020cb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020fc:	8b 42 68             	mov    0x68(%edx),%eax
  8020ff:	6a 01                	push   $0x1
  802101:	50                   	push   %eax
  802102:	53                   	push   %ebx
  802103:	68 02 2e 80 00       	push   $0x802e02
  802108:	e8 ac e0 ff ff       	call   8001b9 <cprintf>
  80210d:	83 c4 10             	add    $0x10,%esp
  802110:	eb b9                	jmp    8020cb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802112:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802115:	0f 94 c0             	sete   %al
  802118:	0f b6 c0             	movzbl %al,%eax
}
  80211b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80211e:	5b                   	pop    %ebx
  80211f:	5e                   	pop    %esi
  802120:	5f                   	pop    %edi
  802121:	5d                   	pop    %ebp
  802122:	c3                   	ret    

00802123 <devpipe_write>:
{
  802123:	55                   	push   %ebp
  802124:	89 e5                	mov    %esp,%ebp
  802126:	57                   	push   %edi
  802127:	56                   	push   %esi
  802128:	53                   	push   %ebx
  802129:	83 ec 28             	sub    $0x28,%esp
  80212c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80212f:	56                   	push   %esi
  802130:	e8 bc ec ff ff       	call   800df1 <fd2data>
  802135:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802137:	83 c4 10             	add    $0x10,%esp
  80213a:	bf 00 00 00 00       	mov    $0x0,%edi
  80213f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802142:	75 09                	jne    80214d <devpipe_write+0x2a>
	return i;
  802144:	89 f8                	mov    %edi,%eax
  802146:	eb 23                	jmp    80216b <devpipe_write+0x48>
			sys_yield();
  802148:	e8 23 ea ff ff       	call   800b70 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80214d:	8b 43 04             	mov    0x4(%ebx),%eax
  802150:	8b 0b                	mov    (%ebx),%ecx
  802152:	8d 51 20             	lea    0x20(%ecx),%edx
  802155:	39 d0                	cmp    %edx,%eax
  802157:	72 1a                	jb     802173 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802159:	89 da                	mov    %ebx,%edx
  80215b:	89 f0                	mov    %esi,%eax
  80215d:	e8 5c ff ff ff       	call   8020be <_pipeisclosed>
  802162:	85 c0                	test   %eax,%eax
  802164:	74 e2                	je     802148 <devpipe_write+0x25>
				return 0;
  802166:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80216b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216e:	5b                   	pop    %ebx
  80216f:	5e                   	pop    %esi
  802170:	5f                   	pop    %edi
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802176:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80217a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80217d:	89 c2                	mov    %eax,%edx
  80217f:	c1 fa 1f             	sar    $0x1f,%edx
  802182:	89 d1                	mov    %edx,%ecx
  802184:	c1 e9 1b             	shr    $0x1b,%ecx
  802187:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80218a:	83 e2 1f             	and    $0x1f,%edx
  80218d:	29 ca                	sub    %ecx,%edx
  80218f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802193:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802197:	83 c0 01             	add    $0x1,%eax
  80219a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80219d:	83 c7 01             	add    $0x1,%edi
  8021a0:	eb 9d                	jmp    80213f <devpipe_write+0x1c>

008021a2 <devpipe_read>:
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	57                   	push   %edi
  8021a6:	56                   	push   %esi
  8021a7:	53                   	push   %ebx
  8021a8:	83 ec 18             	sub    $0x18,%esp
  8021ab:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8021ae:	57                   	push   %edi
  8021af:	e8 3d ec ff ff       	call   800df1 <fd2data>
  8021b4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021b6:	83 c4 10             	add    $0x10,%esp
  8021b9:	be 00 00 00 00       	mov    $0x0,%esi
  8021be:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021c1:	75 13                	jne    8021d6 <devpipe_read+0x34>
	return i;
  8021c3:	89 f0                	mov    %esi,%eax
  8021c5:	eb 02                	jmp    8021c9 <devpipe_read+0x27>
				return i;
  8021c7:	89 f0                	mov    %esi,%eax
}
  8021c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021cc:	5b                   	pop    %ebx
  8021cd:	5e                   	pop    %esi
  8021ce:	5f                   	pop    %edi
  8021cf:	5d                   	pop    %ebp
  8021d0:	c3                   	ret    
			sys_yield();
  8021d1:	e8 9a e9 ff ff       	call   800b70 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8021d6:	8b 03                	mov    (%ebx),%eax
  8021d8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021db:	75 18                	jne    8021f5 <devpipe_read+0x53>
			if (i > 0)
  8021dd:	85 f6                	test   %esi,%esi
  8021df:	75 e6                	jne    8021c7 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8021e1:	89 da                	mov    %ebx,%edx
  8021e3:	89 f8                	mov    %edi,%eax
  8021e5:	e8 d4 fe ff ff       	call   8020be <_pipeisclosed>
  8021ea:	85 c0                	test   %eax,%eax
  8021ec:	74 e3                	je     8021d1 <devpipe_read+0x2f>
				return 0;
  8021ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f3:	eb d4                	jmp    8021c9 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021f5:	99                   	cltd   
  8021f6:	c1 ea 1b             	shr    $0x1b,%edx
  8021f9:	01 d0                	add    %edx,%eax
  8021fb:	83 e0 1f             	and    $0x1f,%eax
  8021fe:	29 d0                	sub    %edx,%eax
  802200:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802208:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80220b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80220e:	83 c6 01             	add    $0x1,%esi
  802211:	eb ab                	jmp    8021be <devpipe_read+0x1c>

00802213 <pipe>:
{
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	56                   	push   %esi
  802217:	53                   	push   %ebx
  802218:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80221b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80221e:	50                   	push   %eax
  80221f:	e8 e4 eb ff ff       	call   800e08 <fd_alloc>
  802224:	89 c3                	mov    %eax,%ebx
  802226:	83 c4 10             	add    $0x10,%esp
  802229:	85 c0                	test   %eax,%eax
  80222b:	0f 88 23 01 00 00    	js     802354 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802231:	83 ec 04             	sub    $0x4,%esp
  802234:	68 07 04 00 00       	push   $0x407
  802239:	ff 75 f4             	push   -0xc(%ebp)
  80223c:	6a 00                	push   $0x0
  80223e:	e8 4c e9 ff ff       	call   800b8f <sys_page_alloc>
  802243:	89 c3                	mov    %eax,%ebx
  802245:	83 c4 10             	add    $0x10,%esp
  802248:	85 c0                	test   %eax,%eax
  80224a:	0f 88 04 01 00 00    	js     802354 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802250:	83 ec 0c             	sub    $0xc,%esp
  802253:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802256:	50                   	push   %eax
  802257:	e8 ac eb ff ff       	call   800e08 <fd_alloc>
  80225c:	89 c3                	mov    %eax,%ebx
  80225e:	83 c4 10             	add    $0x10,%esp
  802261:	85 c0                	test   %eax,%eax
  802263:	0f 88 db 00 00 00    	js     802344 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802269:	83 ec 04             	sub    $0x4,%esp
  80226c:	68 07 04 00 00       	push   $0x407
  802271:	ff 75 f0             	push   -0x10(%ebp)
  802274:	6a 00                	push   $0x0
  802276:	e8 14 e9 ff ff       	call   800b8f <sys_page_alloc>
  80227b:	89 c3                	mov    %eax,%ebx
  80227d:	83 c4 10             	add    $0x10,%esp
  802280:	85 c0                	test   %eax,%eax
  802282:	0f 88 bc 00 00 00    	js     802344 <pipe+0x131>
	va = fd2data(fd0);
  802288:	83 ec 0c             	sub    $0xc,%esp
  80228b:	ff 75 f4             	push   -0xc(%ebp)
  80228e:	e8 5e eb ff ff       	call   800df1 <fd2data>
  802293:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802295:	83 c4 0c             	add    $0xc,%esp
  802298:	68 07 04 00 00       	push   $0x407
  80229d:	50                   	push   %eax
  80229e:	6a 00                	push   $0x0
  8022a0:	e8 ea e8 ff ff       	call   800b8f <sys_page_alloc>
  8022a5:	89 c3                	mov    %eax,%ebx
  8022a7:	83 c4 10             	add    $0x10,%esp
  8022aa:	85 c0                	test   %eax,%eax
  8022ac:	0f 88 82 00 00 00    	js     802334 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022b2:	83 ec 0c             	sub    $0xc,%esp
  8022b5:	ff 75 f0             	push   -0x10(%ebp)
  8022b8:	e8 34 eb ff ff       	call   800df1 <fd2data>
  8022bd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022c4:	50                   	push   %eax
  8022c5:	6a 00                	push   $0x0
  8022c7:	56                   	push   %esi
  8022c8:	6a 00                	push   $0x0
  8022ca:	e8 03 e9 ff ff       	call   800bd2 <sys_page_map>
  8022cf:	89 c3                	mov    %eax,%ebx
  8022d1:	83 c4 20             	add    $0x20,%esp
  8022d4:	85 c0                	test   %eax,%eax
  8022d6:	78 4e                	js     802326 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8022d8:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8022dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022e0:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8022e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022e5:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8022ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022ef:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8022f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8022fb:	83 ec 0c             	sub    $0xc,%esp
  8022fe:	ff 75 f4             	push   -0xc(%ebp)
  802301:	e8 db ea ff ff       	call   800de1 <fd2num>
  802306:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802309:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80230b:	83 c4 04             	add    $0x4,%esp
  80230e:	ff 75 f0             	push   -0x10(%ebp)
  802311:	e8 cb ea ff ff       	call   800de1 <fd2num>
  802316:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802319:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80231c:	83 c4 10             	add    $0x10,%esp
  80231f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802324:	eb 2e                	jmp    802354 <pipe+0x141>
	sys_page_unmap(0, va);
  802326:	83 ec 08             	sub    $0x8,%esp
  802329:	56                   	push   %esi
  80232a:	6a 00                	push   $0x0
  80232c:	e8 e3 e8 ff ff       	call   800c14 <sys_page_unmap>
  802331:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802334:	83 ec 08             	sub    $0x8,%esp
  802337:	ff 75 f0             	push   -0x10(%ebp)
  80233a:	6a 00                	push   $0x0
  80233c:	e8 d3 e8 ff ff       	call   800c14 <sys_page_unmap>
  802341:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802344:	83 ec 08             	sub    $0x8,%esp
  802347:	ff 75 f4             	push   -0xc(%ebp)
  80234a:	6a 00                	push   $0x0
  80234c:	e8 c3 e8 ff ff       	call   800c14 <sys_page_unmap>
  802351:	83 c4 10             	add    $0x10,%esp
}
  802354:	89 d8                	mov    %ebx,%eax
  802356:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802359:	5b                   	pop    %ebx
  80235a:	5e                   	pop    %esi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    

0080235d <pipeisclosed>:
{
  80235d:	55                   	push   %ebp
  80235e:	89 e5                	mov    %esp,%ebp
  802360:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802363:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802366:	50                   	push   %eax
  802367:	ff 75 08             	push   0x8(%ebp)
  80236a:	e8 e9 ea ff ff       	call   800e58 <fd_lookup>
  80236f:	83 c4 10             	add    $0x10,%esp
  802372:	85 c0                	test   %eax,%eax
  802374:	78 18                	js     80238e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802376:	83 ec 0c             	sub    $0xc,%esp
  802379:	ff 75 f4             	push   -0xc(%ebp)
  80237c:	e8 70 ea ff ff       	call   800df1 <fd2data>
  802381:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802386:	e8 33 fd ff ff       	call   8020be <_pipeisclosed>
  80238b:	83 c4 10             	add    $0x10,%esp
}
  80238e:	c9                   	leave  
  80238f:	c3                   	ret    

00802390 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802390:	b8 00 00 00 00       	mov    $0x0,%eax
  802395:	c3                   	ret    

00802396 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802396:	55                   	push   %ebp
  802397:	89 e5                	mov    %esp,%ebp
  802399:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80239c:	68 1a 2e 80 00       	push   $0x802e1a
  8023a1:	ff 75 0c             	push   0xc(%ebp)
  8023a4:	e8 ea e3 ff ff       	call   800793 <strcpy>
	return 0;
}
  8023a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ae:	c9                   	leave  
  8023af:	c3                   	ret    

008023b0 <devcons_write>:
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	57                   	push   %edi
  8023b4:	56                   	push   %esi
  8023b5:	53                   	push   %ebx
  8023b6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8023bc:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8023c1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8023c7:	eb 2e                	jmp    8023f7 <devcons_write+0x47>
		m = n - tot;
  8023c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023cc:	29 f3                	sub    %esi,%ebx
  8023ce:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8023d3:	39 c3                	cmp    %eax,%ebx
  8023d5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8023d8:	83 ec 04             	sub    $0x4,%esp
  8023db:	53                   	push   %ebx
  8023dc:	89 f0                	mov    %esi,%eax
  8023de:	03 45 0c             	add    0xc(%ebp),%eax
  8023e1:	50                   	push   %eax
  8023e2:	57                   	push   %edi
  8023e3:	e8 41 e5 ff ff       	call   800929 <memmove>
		sys_cputs(buf, m);
  8023e8:	83 c4 08             	add    $0x8,%esp
  8023eb:	53                   	push   %ebx
  8023ec:	57                   	push   %edi
  8023ed:	e8 e1 e6 ff ff       	call   800ad3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8023f2:	01 de                	add    %ebx,%esi
  8023f4:	83 c4 10             	add    $0x10,%esp
  8023f7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023fa:	72 cd                	jb     8023c9 <devcons_write+0x19>
}
  8023fc:	89 f0                	mov    %esi,%eax
  8023fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802401:	5b                   	pop    %ebx
  802402:	5e                   	pop    %esi
  802403:	5f                   	pop    %edi
  802404:	5d                   	pop    %ebp
  802405:	c3                   	ret    

00802406 <devcons_read>:
{
  802406:	55                   	push   %ebp
  802407:	89 e5                	mov    %esp,%ebp
  802409:	83 ec 08             	sub    $0x8,%esp
  80240c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802411:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802415:	75 07                	jne    80241e <devcons_read+0x18>
  802417:	eb 1f                	jmp    802438 <devcons_read+0x32>
		sys_yield();
  802419:	e8 52 e7 ff ff       	call   800b70 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80241e:	e8 ce e6 ff ff       	call   800af1 <sys_cgetc>
  802423:	85 c0                	test   %eax,%eax
  802425:	74 f2                	je     802419 <devcons_read+0x13>
	if (c < 0)
  802427:	78 0f                	js     802438 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802429:	83 f8 04             	cmp    $0x4,%eax
  80242c:	74 0c                	je     80243a <devcons_read+0x34>
	*(char*)vbuf = c;
  80242e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802431:	88 02                	mov    %al,(%edx)
	return 1;
  802433:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802438:	c9                   	leave  
  802439:	c3                   	ret    
		return 0;
  80243a:	b8 00 00 00 00       	mov    $0x0,%eax
  80243f:	eb f7                	jmp    802438 <devcons_read+0x32>

00802441 <cputchar>:
{
  802441:	55                   	push   %ebp
  802442:	89 e5                	mov    %esp,%ebp
  802444:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802447:	8b 45 08             	mov    0x8(%ebp),%eax
  80244a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80244d:	6a 01                	push   $0x1
  80244f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802452:	50                   	push   %eax
  802453:	e8 7b e6 ff ff       	call   800ad3 <sys_cputs>
}
  802458:	83 c4 10             	add    $0x10,%esp
  80245b:	c9                   	leave  
  80245c:	c3                   	ret    

0080245d <getchar>:
{
  80245d:	55                   	push   %ebp
  80245e:	89 e5                	mov    %esp,%ebp
  802460:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802463:	6a 01                	push   $0x1
  802465:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802468:	50                   	push   %eax
  802469:	6a 00                	push   $0x0
  80246b:	e8 51 ec ff ff       	call   8010c1 <read>
	if (r < 0)
  802470:	83 c4 10             	add    $0x10,%esp
  802473:	85 c0                	test   %eax,%eax
  802475:	78 06                	js     80247d <getchar+0x20>
	if (r < 1)
  802477:	74 06                	je     80247f <getchar+0x22>
	return c;
  802479:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80247d:	c9                   	leave  
  80247e:	c3                   	ret    
		return -E_EOF;
  80247f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802484:	eb f7                	jmp    80247d <getchar+0x20>

00802486 <iscons>:
{
  802486:	55                   	push   %ebp
  802487:	89 e5                	mov    %esp,%ebp
  802489:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80248c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80248f:	50                   	push   %eax
  802490:	ff 75 08             	push   0x8(%ebp)
  802493:	e8 c0 e9 ff ff       	call   800e58 <fd_lookup>
  802498:	83 c4 10             	add    $0x10,%esp
  80249b:	85 c0                	test   %eax,%eax
  80249d:	78 11                	js     8024b0 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80249f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024a8:	39 10                	cmp    %edx,(%eax)
  8024aa:	0f 94 c0             	sete   %al
  8024ad:	0f b6 c0             	movzbl %al,%eax
}
  8024b0:	c9                   	leave  
  8024b1:	c3                   	ret    

008024b2 <opencons>:
{
  8024b2:	55                   	push   %ebp
  8024b3:	89 e5                	mov    %esp,%ebp
  8024b5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8024b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024bb:	50                   	push   %eax
  8024bc:	e8 47 e9 ff ff       	call   800e08 <fd_alloc>
  8024c1:	83 c4 10             	add    $0x10,%esp
  8024c4:	85 c0                	test   %eax,%eax
  8024c6:	78 3a                	js     802502 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024c8:	83 ec 04             	sub    $0x4,%esp
  8024cb:	68 07 04 00 00       	push   $0x407
  8024d0:	ff 75 f4             	push   -0xc(%ebp)
  8024d3:	6a 00                	push   $0x0
  8024d5:	e8 b5 e6 ff ff       	call   800b8f <sys_page_alloc>
  8024da:	83 c4 10             	add    $0x10,%esp
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	78 21                	js     802502 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8024e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024ea:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024f6:	83 ec 0c             	sub    $0xc,%esp
  8024f9:	50                   	push   %eax
  8024fa:	e8 e2 e8 ff ff       	call   800de1 <fd2num>
  8024ff:	83 c4 10             	add    $0x10,%esp
}
  802502:	c9                   	leave  
  802503:	c3                   	ret    

00802504 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802504:	55                   	push   %ebp
  802505:	89 e5                	mov    %esp,%ebp
  802507:	56                   	push   %esi
  802508:	53                   	push   %ebx
  802509:	8b 75 08             	mov    0x8(%ebp),%esi
  80250c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80250f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802512:	85 c0                	test   %eax,%eax
  802514:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802519:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80251c:	83 ec 0c             	sub    $0xc,%esp
  80251f:	50                   	push   %eax
  802520:	e8 1a e8 ff ff       	call   800d3f <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802525:	83 c4 10             	add    $0x10,%esp
  802528:	85 f6                	test   %esi,%esi
  80252a:	74 17                	je     802543 <ipc_recv+0x3f>
  80252c:	ba 00 00 00 00       	mov    $0x0,%edx
  802531:	85 c0                	test   %eax,%eax
  802533:	78 0c                	js     802541 <ipc_recv+0x3d>
  802535:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80253b:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802541:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802543:	85 db                	test   %ebx,%ebx
  802545:	74 17                	je     80255e <ipc_recv+0x5a>
  802547:	ba 00 00 00 00       	mov    $0x0,%edx
  80254c:	85 c0                	test   %eax,%eax
  80254e:	78 0c                	js     80255c <ipc_recv+0x58>
  802550:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802556:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80255c:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80255e:	85 c0                	test   %eax,%eax
  802560:	78 0b                	js     80256d <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802562:	a1 00 40 80 00       	mov    0x804000,%eax
  802567:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  80256d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802570:	5b                   	pop    %ebx
  802571:	5e                   	pop    %esi
  802572:	5d                   	pop    %ebp
  802573:	c3                   	ret    

00802574 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802574:	55                   	push   %ebp
  802575:	89 e5                	mov    %esp,%ebp
  802577:	57                   	push   %edi
  802578:	56                   	push   %esi
  802579:	53                   	push   %ebx
  80257a:	83 ec 0c             	sub    $0xc,%esp
  80257d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802580:	8b 75 0c             	mov    0xc(%ebp),%esi
  802583:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802586:	85 db                	test   %ebx,%ebx
  802588:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80258d:	0f 44 d8             	cmove  %eax,%ebx
  802590:	eb 05                	jmp    802597 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802592:	e8 d9 e5 ff ff       	call   800b70 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802597:	ff 75 14             	push   0x14(%ebp)
  80259a:	53                   	push   %ebx
  80259b:	56                   	push   %esi
  80259c:	57                   	push   %edi
  80259d:	e8 7a e7 ff ff       	call   800d1c <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8025a2:	83 c4 10             	add    $0x10,%esp
  8025a5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025a8:	74 e8                	je     802592 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8025aa:	85 c0                	test   %eax,%eax
  8025ac:	78 08                	js     8025b6 <ipc_send+0x42>
	}while (r<0);

}
  8025ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025b1:	5b                   	pop    %ebx
  8025b2:	5e                   	pop    %esi
  8025b3:	5f                   	pop    %edi
  8025b4:	5d                   	pop    %ebp
  8025b5:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8025b6:	50                   	push   %eax
  8025b7:	68 26 2e 80 00       	push   $0x802e26
  8025bc:	6a 3d                	push   $0x3d
  8025be:	68 3a 2e 80 00       	push   $0x802e3a
  8025c3:	e8 16 db ff ff       	call   8000de <_panic>

008025c8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025c8:	55                   	push   %ebp
  8025c9:	89 e5                	mov    %esp,%ebp
  8025cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025ce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025d3:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8025d9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025df:	8b 52 60             	mov    0x60(%edx),%edx
  8025e2:	39 ca                	cmp    %ecx,%edx
  8025e4:	74 11                	je     8025f7 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8025e6:	83 c0 01             	add    $0x1,%eax
  8025e9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025ee:	75 e3                	jne    8025d3 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8025f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8025f5:	eb 0e                	jmp    802605 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8025f7:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8025fd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802602:	8b 40 58             	mov    0x58(%eax),%eax
}
  802605:	5d                   	pop    %ebp
  802606:	c3                   	ret    

00802607 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802607:	55                   	push   %ebp
  802608:	89 e5                	mov    %esp,%ebp
  80260a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80260d:	89 c2                	mov    %eax,%edx
  80260f:	c1 ea 16             	shr    $0x16,%edx
  802612:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802619:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80261e:	f6 c1 01             	test   $0x1,%cl
  802621:	74 1c                	je     80263f <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802623:	c1 e8 0c             	shr    $0xc,%eax
  802626:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80262d:	a8 01                	test   $0x1,%al
  80262f:	74 0e                	je     80263f <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802631:	c1 e8 0c             	shr    $0xc,%eax
  802634:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80263b:	ef 
  80263c:	0f b7 d2             	movzwl %dx,%edx
}
  80263f:	89 d0                	mov    %edx,%eax
  802641:	5d                   	pop    %ebp
  802642:	c3                   	ret    
  802643:	66 90                	xchg   %ax,%ax
  802645:	66 90                	xchg   %ax,%ax
  802647:	66 90                	xchg   %ax,%ax
  802649:	66 90                	xchg   %ax,%ax
  80264b:	66 90                	xchg   %ax,%ax
  80264d:	66 90                	xchg   %ax,%ax
  80264f:	90                   	nop

00802650 <__udivdi3>:
  802650:	f3 0f 1e fb          	endbr32 
  802654:	55                   	push   %ebp
  802655:	57                   	push   %edi
  802656:	56                   	push   %esi
  802657:	53                   	push   %ebx
  802658:	83 ec 1c             	sub    $0x1c,%esp
  80265b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80265f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802663:	8b 74 24 34          	mov    0x34(%esp),%esi
  802667:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80266b:	85 c0                	test   %eax,%eax
  80266d:	75 19                	jne    802688 <__udivdi3+0x38>
  80266f:	39 f3                	cmp    %esi,%ebx
  802671:	76 4d                	jbe    8026c0 <__udivdi3+0x70>
  802673:	31 ff                	xor    %edi,%edi
  802675:	89 e8                	mov    %ebp,%eax
  802677:	89 f2                	mov    %esi,%edx
  802679:	f7 f3                	div    %ebx
  80267b:	89 fa                	mov    %edi,%edx
  80267d:	83 c4 1c             	add    $0x1c,%esp
  802680:	5b                   	pop    %ebx
  802681:	5e                   	pop    %esi
  802682:	5f                   	pop    %edi
  802683:	5d                   	pop    %ebp
  802684:	c3                   	ret    
  802685:	8d 76 00             	lea    0x0(%esi),%esi
  802688:	39 f0                	cmp    %esi,%eax
  80268a:	76 14                	jbe    8026a0 <__udivdi3+0x50>
  80268c:	31 ff                	xor    %edi,%edi
  80268e:	31 c0                	xor    %eax,%eax
  802690:	89 fa                	mov    %edi,%edx
  802692:	83 c4 1c             	add    $0x1c,%esp
  802695:	5b                   	pop    %ebx
  802696:	5e                   	pop    %esi
  802697:	5f                   	pop    %edi
  802698:	5d                   	pop    %ebp
  802699:	c3                   	ret    
  80269a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026a0:	0f bd f8             	bsr    %eax,%edi
  8026a3:	83 f7 1f             	xor    $0x1f,%edi
  8026a6:	75 48                	jne    8026f0 <__udivdi3+0xa0>
  8026a8:	39 f0                	cmp    %esi,%eax
  8026aa:	72 06                	jb     8026b2 <__udivdi3+0x62>
  8026ac:	31 c0                	xor    %eax,%eax
  8026ae:	39 eb                	cmp    %ebp,%ebx
  8026b0:	77 de                	ja     802690 <__udivdi3+0x40>
  8026b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8026b7:	eb d7                	jmp    802690 <__udivdi3+0x40>
  8026b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	89 d9                	mov    %ebx,%ecx
  8026c2:	85 db                	test   %ebx,%ebx
  8026c4:	75 0b                	jne    8026d1 <__udivdi3+0x81>
  8026c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026cb:	31 d2                	xor    %edx,%edx
  8026cd:	f7 f3                	div    %ebx
  8026cf:	89 c1                	mov    %eax,%ecx
  8026d1:	31 d2                	xor    %edx,%edx
  8026d3:	89 f0                	mov    %esi,%eax
  8026d5:	f7 f1                	div    %ecx
  8026d7:	89 c6                	mov    %eax,%esi
  8026d9:	89 e8                	mov    %ebp,%eax
  8026db:	89 f7                	mov    %esi,%edi
  8026dd:	f7 f1                	div    %ecx
  8026df:	89 fa                	mov    %edi,%edx
  8026e1:	83 c4 1c             	add    $0x1c,%esp
  8026e4:	5b                   	pop    %ebx
  8026e5:	5e                   	pop    %esi
  8026e6:	5f                   	pop    %edi
  8026e7:	5d                   	pop    %ebp
  8026e8:	c3                   	ret    
  8026e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026f0:	89 f9                	mov    %edi,%ecx
  8026f2:	ba 20 00 00 00       	mov    $0x20,%edx
  8026f7:	29 fa                	sub    %edi,%edx
  8026f9:	d3 e0                	shl    %cl,%eax
  8026fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026ff:	89 d1                	mov    %edx,%ecx
  802701:	89 d8                	mov    %ebx,%eax
  802703:	d3 e8                	shr    %cl,%eax
  802705:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802709:	09 c1                	or     %eax,%ecx
  80270b:	89 f0                	mov    %esi,%eax
  80270d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802711:	89 f9                	mov    %edi,%ecx
  802713:	d3 e3                	shl    %cl,%ebx
  802715:	89 d1                	mov    %edx,%ecx
  802717:	d3 e8                	shr    %cl,%eax
  802719:	89 f9                	mov    %edi,%ecx
  80271b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80271f:	89 eb                	mov    %ebp,%ebx
  802721:	d3 e6                	shl    %cl,%esi
  802723:	89 d1                	mov    %edx,%ecx
  802725:	d3 eb                	shr    %cl,%ebx
  802727:	09 f3                	or     %esi,%ebx
  802729:	89 c6                	mov    %eax,%esi
  80272b:	89 f2                	mov    %esi,%edx
  80272d:	89 d8                	mov    %ebx,%eax
  80272f:	f7 74 24 08          	divl   0x8(%esp)
  802733:	89 d6                	mov    %edx,%esi
  802735:	89 c3                	mov    %eax,%ebx
  802737:	f7 64 24 0c          	mull   0xc(%esp)
  80273b:	39 d6                	cmp    %edx,%esi
  80273d:	72 19                	jb     802758 <__udivdi3+0x108>
  80273f:	89 f9                	mov    %edi,%ecx
  802741:	d3 e5                	shl    %cl,%ebp
  802743:	39 c5                	cmp    %eax,%ebp
  802745:	73 04                	jae    80274b <__udivdi3+0xfb>
  802747:	39 d6                	cmp    %edx,%esi
  802749:	74 0d                	je     802758 <__udivdi3+0x108>
  80274b:	89 d8                	mov    %ebx,%eax
  80274d:	31 ff                	xor    %edi,%edi
  80274f:	e9 3c ff ff ff       	jmp    802690 <__udivdi3+0x40>
  802754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802758:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80275b:	31 ff                	xor    %edi,%edi
  80275d:	e9 2e ff ff ff       	jmp    802690 <__udivdi3+0x40>
  802762:	66 90                	xchg   %ax,%ax
  802764:	66 90                	xchg   %ax,%ax
  802766:	66 90                	xchg   %ax,%ax
  802768:	66 90                	xchg   %ax,%ax
  80276a:	66 90                	xchg   %ax,%ax
  80276c:	66 90                	xchg   %ax,%ax
  80276e:	66 90                	xchg   %ax,%ax

00802770 <__umoddi3>:
  802770:	f3 0f 1e fb          	endbr32 
  802774:	55                   	push   %ebp
  802775:	57                   	push   %edi
  802776:	56                   	push   %esi
  802777:	53                   	push   %ebx
  802778:	83 ec 1c             	sub    $0x1c,%esp
  80277b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80277f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802783:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802787:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80278b:	89 f0                	mov    %esi,%eax
  80278d:	89 da                	mov    %ebx,%edx
  80278f:	85 ff                	test   %edi,%edi
  802791:	75 15                	jne    8027a8 <__umoddi3+0x38>
  802793:	39 dd                	cmp    %ebx,%ebp
  802795:	76 39                	jbe    8027d0 <__umoddi3+0x60>
  802797:	f7 f5                	div    %ebp
  802799:	89 d0                	mov    %edx,%eax
  80279b:	31 d2                	xor    %edx,%edx
  80279d:	83 c4 1c             	add    $0x1c,%esp
  8027a0:	5b                   	pop    %ebx
  8027a1:	5e                   	pop    %esi
  8027a2:	5f                   	pop    %edi
  8027a3:	5d                   	pop    %ebp
  8027a4:	c3                   	ret    
  8027a5:	8d 76 00             	lea    0x0(%esi),%esi
  8027a8:	39 df                	cmp    %ebx,%edi
  8027aa:	77 f1                	ja     80279d <__umoddi3+0x2d>
  8027ac:	0f bd cf             	bsr    %edi,%ecx
  8027af:	83 f1 1f             	xor    $0x1f,%ecx
  8027b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8027b6:	75 40                	jne    8027f8 <__umoddi3+0x88>
  8027b8:	39 df                	cmp    %ebx,%edi
  8027ba:	72 04                	jb     8027c0 <__umoddi3+0x50>
  8027bc:	39 f5                	cmp    %esi,%ebp
  8027be:	77 dd                	ja     80279d <__umoddi3+0x2d>
  8027c0:	89 da                	mov    %ebx,%edx
  8027c2:	89 f0                	mov    %esi,%eax
  8027c4:	29 e8                	sub    %ebp,%eax
  8027c6:	19 fa                	sbb    %edi,%edx
  8027c8:	eb d3                	jmp    80279d <__umoddi3+0x2d>
  8027ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027d0:	89 e9                	mov    %ebp,%ecx
  8027d2:	85 ed                	test   %ebp,%ebp
  8027d4:	75 0b                	jne    8027e1 <__umoddi3+0x71>
  8027d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027db:	31 d2                	xor    %edx,%edx
  8027dd:	f7 f5                	div    %ebp
  8027df:	89 c1                	mov    %eax,%ecx
  8027e1:	89 d8                	mov    %ebx,%eax
  8027e3:	31 d2                	xor    %edx,%edx
  8027e5:	f7 f1                	div    %ecx
  8027e7:	89 f0                	mov    %esi,%eax
  8027e9:	f7 f1                	div    %ecx
  8027eb:	89 d0                	mov    %edx,%eax
  8027ed:	31 d2                	xor    %edx,%edx
  8027ef:	eb ac                	jmp    80279d <__umoddi3+0x2d>
  8027f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027fc:	ba 20 00 00 00       	mov    $0x20,%edx
  802801:	29 c2                	sub    %eax,%edx
  802803:	89 c1                	mov    %eax,%ecx
  802805:	89 e8                	mov    %ebp,%eax
  802807:	d3 e7                	shl    %cl,%edi
  802809:	89 d1                	mov    %edx,%ecx
  80280b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80280f:	d3 e8                	shr    %cl,%eax
  802811:	89 c1                	mov    %eax,%ecx
  802813:	8b 44 24 04          	mov    0x4(%esp),%eax
  802817:	09 f9                	or     %edi,%ecx
  802819:	89 df                	mov    %ebx,%edi
  80281b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80281f:	89 c1                	mov    %eax,%ecx
  802821:	d3 e5                	shl    %cl,%ebp
  802823:	89 d1                	mov    %edx,%ecx
  802825:	d3 ef                	shr    %cl,%edi
  802827:	89 c1                	mov    %eax,%ecx
  802829:	89 f0                	mov    %esi,%eax
  80282b:	d3 e3                	shl    %cl,%ebx
  80282d:	89 d1                	mov    %edx,%ecx
  80282f:	89 fa                	mov    %edi,%edx
  802831:	d3 e8                	shr    %cl,%eax
  802833:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802838:	09 d8                	or     %ebx,%eax
  80283a:	f7 74 24 08          	divl   0x8(%esp)
  80283e:	89 d3                	mov    %edx,%ebx
  802840:	d3 e6                	shl    %cl,%esi
  802842:	f7 e5                	mul    %ebp
  802844:	89 c7                	mov    %eax,%edi
  802846:	89 d1                	mov    %edx,%ecx
  802848:	39 d3                	cmp    %edx,%ebx
  80284a:	72 06                	jb     802852 <__umoddi3+0xe2>
  80284c:	75 0e                	jne    80285c <__umoddi3+0xec>
  80284e:	39 c6                	cmp    %eax,%esi
  802850:	73 0a                	jae    80285c <__umoddi3+0xec>
  802852:	29 e8                	sub    %ebp,%eax
  802854:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802858:	89 d1                	mov    %edx,%ecx
  80285a:	89 c7                	mov    %eax,%edi
  80285c:	89 f5                	mov    %esi,%ebp
  80285e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802862:	29 fd                	sub    %edi,%ebp
  802864:	19 cb                	sbb    %ecx,%ebx
  802866:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80286b:	89 d8                	mov    %ebx,%eax
  80286d:	d3 e0                	shl    %cl,%eax
  80286f:	89 f1                	mov    %esi,%ecx
  802871:	d3 ed                	shr    %cl,%ebp
  802873:	d3 eb                	shr    %cl,%ebx
  802875:	09 e8                	or     %ebp,%eax
  802877:	89 da                	mov    %ebx,%edx
  802879:	83 c4 1c             	add    $0x1c,%esp
  80287c:	5b                   	pop    %ebx
  80287d:	5e                   	pop    %esi
  80287e:	5f                   	pop    %edi
  80287f:	5d                   	pop    %ebp
  802880:	c3                   	ret    
