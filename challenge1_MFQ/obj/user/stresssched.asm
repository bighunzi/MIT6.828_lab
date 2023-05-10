
obj/user/stresssched.debug：     文件格式 elf32-i386


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
  80002c:	e8 b5 00 00 00       	call   8000e6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 7f 0b 00 00       	call   800bbc <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 01 0f 00 00       	call   800f4a <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 81 0b 00 00       	call   800bdb <sys_yield>
		return;
  80005a:	eb 6c                	jmp    8000c8 <umain+0x95>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005c:	89 f0                	mov    %esi,%eax
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	eb 02                	jmp    800072 <umain+0x3f>
		asm volatile("pause");
  800070:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800072:	8b 50 64             	mov    0x64(%eax),%edx
  800075:	85 d2                	test   %edx,%edx
  800077:	75 f7                	jne    800070 <umain+0x3d>
  800079:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80007e:	e8 58 0b 00 00       	call   800bdb <sys_yield>
  800083:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800088:	a1 00 40 80 00       	mov    0x804000,%eax
  80008d:	83 c0 01             	add    $0x1,%eax
  800090:	a3 00 40 80 00       	mov    %eax,0x804000
		for (j = 0; j < 10000; j++)
  800095:	83 ea 01             	sub    $0x1,%edx
  800098:	75 ee                	jne    800088 <umain+0x55>
	for (i = 0; i < 10; i++) {
  80009a:	83 eb 01             	sub    $0x1,%ebx
  80009d:	75 df                	jne    80007e <umain+0x4b>
	}

	if (counter != 10*10000)
  80009f:	a1 00 40 80 00       	mov    0x804000,%eax
  8000a4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000a9:	75 24                	jne    8000cf <umain+0x9c>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b0:	8b 50 6c             	mov    0x6c(%eax),%edx
  8000b3:	8b 40 58             	mov    0x58(%eax),%eax
  8000b6:	83 ec 04             	sub    $0x4,%esp
  8000b9:	52                   	push   %edx
  8000ba:	50                   	push   %eax
  8000bb:	68 3b 26 80 00       	push   $0x80263b
  8000c0:	e8 5f 01 00 00       	call   800224 <cprintf>
  8000c5:	83 c4 10             	add    $0x10,%esp

}
  8000c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cb:	5b                   	pop    %ebx
  8000cc:	5e                   	pop    %esi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000cf:	a1 00 40 80 00       	mov    0x804000,%eax
  8000d4:	50                   	push   %eax
  8000d5:	68 00 26 80 00       	push   $0x802600
  8000da:	6a 21                	push   $0x21
  8000dc:	68 28 26 80 00       	push   $0x802628
  8000e1:	e8 63 00 00 00       	call   800149 <_panic>

008000e6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ee:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f1:	e8 c6 0a 00 00       	call   800bbc <sys_getenvid>
  8000f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fb:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800101:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800106:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010b:	85 db                	test   %ebx,%ebx
  80010d:	7e 07                	jle    800116 <libmain+0x30>
		binaryname = argv[0];
  80010f:	8b 06                	mov    (%esi),%eax
  800111:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800116:	83 ec 08             	sub    $0x8,%esp
  800119:	56                   	push   %esi
  80011a:	53                   	push   %ebx
  80011b:	e8 13 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800120:	e8 0a 00 00 00       	call   80012f <exit>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012b:	5b                   	pop    %ebx
  80012c:	5e                   	pop    %esi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800135:	e8 64 11 00 00       	call   80129e <close_all>
	sys_env_destroy(0);
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	6a 00                	push   $0x0
  80013f:	e8 37 0a 00 00       	call   800b7b <sys_env_destroy>
}
  800144:	83 c4 10             	add    $0x10,%esp
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	56                   	push   %esi
  80014d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800151:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800157:	e8 60 0a 00 00       	call   800bbc <sys_getenvid>
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	ff 75 0c             	push   0xc(%ebp)
  800162:	ff 75 08             	push   0x8(%ebp)
  800165:	56                   	push   %esi
  800166:	50                   	push   %eax
  800167:	68 64 26 80 00       	push   $0x802664
  80016c:	e8 b3 00 00 00       	call   800224 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800171:	83 c4 18             	add    $0x18,%esp
  800174:	53                   	push   %ebx
  800175:	ff 75 10             	push   0x10(%ebp)
  800178:	e8 56 00 00 00       	call   8001d3 <vcprintf>
	cprintf("\n");
  80017d:	c7 04 24 57 26 80 00 	movl   $0x802657,(%esp)
  800184:	e8 9b 00 00 00       	call   800224 <cprintf>
  800189:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018c:	cc                   	int3   
  80018d:	eb fd                	jmp    80018c <_panic+0x43>

0080018f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	53                   	push   %ebx
  800193:	83 ec 04             	sub    $0x4,%esp
  800196:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800199:	8b 13                	mov    (%ebx),%edx
  80019b:	8d 42 01             	lea    0x1(%edx),%eax
  80019e:	89 03                	mov    %eax,(%ebx)
  8001a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ac:	74 09                	je     8001b7 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ae:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	68 ff 00 00 00       	push   $0xff
  8001bf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c2:	50                   	push   %eax
  8001c3:	e8 76 09 00 00       	call   800b3e <sys_cputs>
		b->idx = 0;
  8001c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	eb db                	jmp    8001ae <putch+0x1f>

008001d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e3:	00 00 00 
	b.cnt = 0;
  8001e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f0:	ff 75 0c             	push   0xc(%ebp)
  8001f3:	ff 75 08             	push   0x8(%ebp)
  8001f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fc:	50                   	push   %eax
  8001fd:	68 8f 01 80 00       	push   $0x80018f
  800202:	e8 14 01 00 00       	call   80031b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800207:	83 c4 08             	add    $0x8,%esp
  80020a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800210:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800216:	50                   	push   %eax
  800217:	e8 22 09 00 00       	call   800b3e <sys_cputs>

	return b.cnt;
}
  80021c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022d:	50                   	push   %eax
  80022e:	ff 75 08             	push   0x8(%ebp)
  800231:	e8 9d ff ff ff       	call   8001d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 1c             	sub    $0x1c,%esp
  800241:	89 c7                	mov    %eax,%edi
  800243:	89 d6                	mov    %edx,%esi
  800245:	8b 45 08             	mov    0x8(%ebp),%eax
  800248:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024b:	89 d1                	mov    %edx,%ecx
  80024d:	89 c2                	mov    %eax,%edx
  80024f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800252:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800255:	8b 45 10             	mov    0x10(%ebp),%eax
  800258:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800265:	39 c2                	cmp    %eax,%edx
  800267:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80026a:	72 3e                	jb     8002aa <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	ff 75 18             	push   0x18(%ebp)
  800272:	83 eb 01             	sub    $0x1,%ebx
  800275:	53                   	push   %ebx
  800276:	50                   	push   %eax
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	ff 75 e4             	push   -0x1c(%ebp)
  80027d:	ff 75 e0             	push   -0x20(%ebp)
  800280:	ff 75 dc             	push   -0x24(%ebp)
  800283:	ff 75 d8             	push   -0x28(%ebp)
  800286:	e8 35 21 00 00       	call   8023c0 <__udivdi3>
  80028b:	83 c4 18             	add    $0x18,%esp
  80028e:	52                   	push   %edx
  80028f:	50                   	push   %eax
  800290:	89 f2                	mov    %esi,%edx
  800292:	89 f8                	mov    %edi,%eax
  800294:	e8 9f ff ff ff       	call   800238 <printnum>
  800299:	83 c4 20             	add    $0x20,%esp
  80029c:	eb 13                	jmp    8002b1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	56                   	push   %esi
  8002a2:	ff 75 18             	push   0x18(%ebp)
  8002a5:	ff d7                	call   *%edi
  8002a7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	85 db                	test   %ebx,%ebx
  8002af:	7f ed                	jg     80029e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	ff 75 e4             	push   -0x1c(%ebp)
  8002bb:	ff 75 e0             	push   -0x20(%ebp)
  8002be:	ff 75 dc             	push   -0x24(%ebp)
  8002c1:	ff 75 d8             	push   -0x28(%ebp)
  8002c4:	e8 17 22 00 00       	call   8024e0 <__umoddi3>
  8002c9:	83 c4 14             	add    $0x14,%esp
  8002cc:	0f be 80 87 26 80 00 	movsbl 0x802687(%eax),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff d7                	call   *%edi
}
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f0:	73 0a                	jae    8002fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	88 02                	mov    %al,(%edx)
}
  8002fc:	5d                   	pop    %ebp
  8002fd:	c3                   	ret    

008002fe <printfmt>:
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800304:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800307:	50                   	push   %eax
  800308:	ff 75 10             	push   0x10(%ebp)
  80030b:	ff 75 0c             	push   0xc(%ebp)
  80030e:	ff 75 08             	push   0x8(%ebp)
  800311:	e8 05 00 00 00       	call   80031b <vprintfmt>
}
  800316:	83 c4 10             	add    $0x10,%esp
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <vprintfmt>:
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 3c             	sub    $0x3c,%esp
  800324:	8b 75 08             	mov    0x8(%ebp),%esi
  800327:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032d:	eb 0a                	jmp    800339 <vprintfmt+0x1e>
			putch(ch, putdat);
  80032f:	83 ec 08             	sub    $0x8,%esp
  800332:	53                   	push   %ebx
  800333:	50                   	push   %eax
  800334:	ff d6                	call   *%esi
  800336:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800339:	83 c7 01             	add    $0x1,%edi
  80033c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800340:	83 f8 25             	cmp    $0x25,%eax
  800343:	74 0c                	je     800351 <vprintfmt+0x36>
			if (ch == '\0')
  800345:	85 c0                	test   %eax,%eax
  800347:	75 e6                	jne    80032f <vprintfmt+0x14>
}
  800349:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034c:	5b                   	pop    %ebx
  80034d:	5e                   	pop    %esi
  80034e:	5f                   	pop    %edi
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    
		padc = ' ';
  800351:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800355:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80035c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800363:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80036a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8d 47 01             	lea    0x1(%edi),%eax
  800372:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800375:	0f b6 17             	movzbl (%edi),%edx
  800378:	8d 42 dd             	lea    -0x23(%edx),%eax
  80037b:	3c 55                	cmp    $0x55,%al
  80037d:	0f 87 bb 03 00 00    	ja     80073e <vprintfmt+0x423>
  800383:	0f b6 c0             	movzbl %al,%eax
  800386:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800390:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800394:	eb d9                	jmp    80036f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800399:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80039d:	eb d0                	jmp    80036f <vprintfmt+0x54>
  80039f:	0f b6 d2             	movzbl %dl,%edx
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ad:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ba:	83 f9 09             	cmp    $0x9,%ecx
  8003bd:	77 55                	ja     800414 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003bf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003c2:	eb e9                	jmp    8003ad <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8b 00                	mov    (%eax),%eax
  8003c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 40 04             	lea    0x4(%eax),%eax
  8003d2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003dc:	79 91                	jns    80036f <vprintfmt+0x54>
				width = precision, precision = -1;
  8003de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003eb:	eb 82                	jmp    80036f <vprintfmt+0x54>
  8003ed:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f0:	85 d2                	test   %edx,%edx
  8003f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f7:	0f 49 c2             	cmovns %edx,%eax
  8003fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800400:	e9 6a ff ff ff       	jmp    80036f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800408:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80040f:	e9 5b ff ff ff       	jmp    80036f <vprintfmt+0x54>
  800414:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800417:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041a:	eb bc                	jmp    8003d8 <vprintfmt+0xbd>
			lflag++;
  80041c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800422:	e9 48 ff ff ff       	jmp    80036f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 78 04             	lea    0x4(%eax),%edi
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	53                   	push   %ebx
  800431:	ff 30                	push   (%eax)
  800433:	ff d6                	call   *%esi
			break;
  800435:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800438:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80043b:	e9 9d 02 00 00       	jmp    8006dd <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 78 04             	lea    0x4(%eax),%edi
  800446:	8b 10                	mov    (%eax),%edx
  800448:	89 d0                	mov    %edx,%eax
  80044a:	f7 d8                	neg    %eax
  80044c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044f:	83 f8 0f             	cmp    $0xf,%eax
  800452:	7f 23                	jg     800477 <vprintfmt+0x15c>
  800454:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  80045b:	85 d2                	test   %edx,%edx
  80045d:	74 18                	je     800477 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80045f:	52                   	push   %edx
  800460:	68 21 2b 80 00       	push   $0x802b21
  800465:	53                   	push   %ebx
  800466:	56                   	push   %esi
  800467:	e8 92 fe ff ff       	call   8002fe <printfmt>
  80046c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800472:	e9 66 02 00 00       	jmp    8006dd <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800477:	50                   	push   %eax
  800478:	68 9f 26 80 00       	push   $0x80269f
  80047d:	53                   	push   %ebx
  80047e:	56                   	push   %esi
  80047f:	e8 7a fe ff ff       	call   8002fe <printfmt>
  800484:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800487:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80048a:	e9 4e 02 00 00       	jmp    8006dd <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	83 c0 04             	add    $0x4,%eax
  800495:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80049d:	85 d2                	test   %edx,%edx
  80049f:	b8 98 26 80 00       	mov    $0x802698,%eax
  8004a4:	0f 45 c2             	cmovne %edx,%eax
  8004a7:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ae:	7e 06                	jle    8004b6 <vprintfmt+0x19b>
  8004b0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004b4:	75 0d                	jne    8004c3 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b9:	89 c7                	mov    %eax,%edi
  8004bb:	03 45 e0             	add    -0x20(%ebp),%eax
  8004be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c1:	eb 55                	jmp    800518 <vprintfmt+0x1fd>
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 d8             	push   -0x28(%ebp)
  8004c9:	ff 75 cc             	push   -0x34(%ebp)
  8004cc:	e8 0a 03 00 00       	call   8007db <strnlen>
  8004d1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d4:	29 c1                	sub    %eax,%ecx
  8004d6:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004de:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	eb 0f                	jmp    8004f6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	ff 75 e0             	push   -0x20(%ebp)
  8004ee:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	83 ef 01             	sub    $0x1,%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7f ed                	jg     8004e7 <vprintfmt+0x1cc>
  8004fa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004fd:	85 d2                	test   %edx,%edx
  8004ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800504:	0f 49 c2             	cmovns %edx,%eax
  800507:	29 c2                	sub    %eax,%edx
  800509:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80050c:	eb a8                	jmp    8004b6 <vprintfmt+0x19b>
					putch(ch, putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	52                   	push   %edx
  800513:	ff d6                	call   *%esi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051d:	83 c7 01             	add    $0x1,%edi
  800520:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800524:	0f be d0             	movsbl %al,%edx
  800527:	85 d2                	test   %edx,%edx
  800529:	74 4b                	je     800576 <vprintfmt+0x25b>
  80052b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052f:	78 06                	js     800537 <vprintfmt+0x21c>
  800531:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800535:	78 1e                	js     800555 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800537:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053b:	74 d1                	je     80050e <vprintfmt+0x1f3>
  80053d:	0f be c0             	movsbl %al,%eax
  800540:	83 e8 20             	sub    $0x20,%eax
  800543:	83 f8 5e             	cmp    $0x5e,%eax
  800546:	76 c6                	jbe    80050e <vprintfmt+0x1f3>
					putch('?', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 3f                	push   $0x3f
  80054e:	ff d6                	call   *%esi
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	eb c3                	jmp    800518 <vprintfmt+0x1fd>
  800555:	89 cf                	mov    %ecx,%edi
  800557:	eb 0e                	jmp    800567 <vprintfmt+0x24c>
				putch(' ', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	6a 20                	push   $0x20
  80055f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800561:	83 ef 01             	sub    $0x1,%edi
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	85 ff                	test   %edi,%edi
  800569:	7f ee                	jg     800559 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80056b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	e9 67 01 00 00       	jmp    8006dd <vprintfmt+0x3c2>
  800576:	89 cf                	mov    %ecx,%edi
  800578:	eb ed                	jmp    800567 <vprintfmt+0x24c>
	if (lflag >= 2)
  80057a:	83 f9 01             	cmp    $0x1,%ecx
  80057d:	7f 1b                	jg     80059a <vprintfmt+0x27f>
	else if (lflag)
  80057f:	85 c9                	test   %ecx,%ecx
  800581:	74 63                	je     8005e6 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058b:	99                   	cltd   
  80058c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 40 04             	lea    0x4(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
  800598:	eb 17                	jmp    8005b1 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 50 04             	mov    0x4(%eax),%edx
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 40 08             	lea    0x8(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b7:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005bc:	85 c9                	test   %ecx,%ecx
  8005be:	0f 89 ff 00 00 00    	jns    8006c3 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	6a 2d                	push   $0x2d
  8005ca:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d2:	f7 da                	neg    %edx
  8005d4:	83 d1 00             	adc    $0x0,%ecx
  8005d7:	f7 d9                	neg    %ecx
  8005d9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005dc:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005e1:	e9 dd 00 00 00       	jmp    8006c3 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	99                   	cltd   
  8005ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fb:	eb b4                	jmp    8005b1 <vprintfmt+0x296>
	if (lflag >= 2)
  8005fd:	83 f9 01             	cmp    $0x1,%ecx
  800600:	7f 1e                	jg     800620 <vprintfmt+0x305>
	else if (lflag)
  800602:	85 c9                	test   %ecx,%ecx
  800604:	74 32                	je     800638 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8b 10                	mov    (%eax),%edx
  80060b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800610:	8d 40 04             	lea    0x4(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800616:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80061b:	e9 a3 00 00 00       	jmp    8006c3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8b 10                	mov    (%eax),%edx
  800625:	8b 48 04             	mov    0x4(%eax),%ecx
  800628:	8d 40 08             	lea    0x8(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800633:	e9 8b 00 00 00       	jmp    8006c3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800648:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80064d:	eb 74                	jmp    8006c3 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80064f:	83 f9 01             	cmp    $0x1,%ecx
  800652:	7f 1b                	jg     80066f <vprintfmt+0x354>
	else if (lflag)
  800654:	85 c9                	test   %ecx,%ecx
  800656:	74 2c                	je     800684 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800668:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80066d:	eb 54                	jmp    8006c3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8b 48 04             	mov    0x4(%eax),%ecx
  800677:	8d 40 08             	lea    0x8(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80067d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800682:	eb 3f                	jmp    8006c3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800694:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800699:	eb 28                	jmp    8006c3 <vprintfmt+0x3a8>
			putch('0', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 30                	push   $0x30
  8006a1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 78                	push   $0x78
  8006a9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006be:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006c3:	83 ec 0c             	sub    $0xc,%esp
  8006c6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006ca:	50                   	push   %eax
  8006cb:	ff 75 e0             	push   -0x20(%ebp)
  8006ce:	57                   	push   %edi
  8006cf:	51                   	push   %ecx
  8006d0:	52                   	push   %edx
  8006d1:	89 da                	mov    %ebx,%edx
  8006d3:	89 f0                	mov    %esi,%eax
  8006d5:	e8 5e fb ff ff       	call   800238 <printnum>
			break;
  8006da:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e0:	e9 54 fc ff ff       	jmp    800339 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006e5:	83 f9 01             	cmp    $0x1,%ecx
  8006e8:	7f 1b                	jg     800705 <vprintfmt+0x3ea>
	else if (lflag)
  8006ea:	85 c9                	test   %ecx,%ecx
  8006ec:	74 2c                	je     80071a <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f8:	8d 40 04             	lea    0x4(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fe:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800703:	eb be                	jmp    8006c3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	8b 48 04             	mov    0x4(%eax),%ecx
  80070d:	8d 40 08             	lea    0x8(%eax),%eax
  800710:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800713:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800718:	eb a9                	jmp    8006c3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800724:	8d 40 04             	lea    0x4(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80072f:	eb 92                	jmp    8006c3 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	6a 25                	push   $0x25
  800737:	ff d6                	call   *%esi
			break;
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 9f                	jmp    8006dd <vprintfmt+0x3c2>
			putch('%', putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	53                   	push   %ebx
  800742:	6a 25                	push   $0x25
  800744:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	89 f8                	mov    %edi,%eax
  80074b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80074f:	74 05                	je     800756 <vprintfmt+0x43b>
  800751:	83 e8 01             	sub    $0x1,%eax
  800754:	eb f5                	jmp    80074b <vprintfmt+0x430>
  800756:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800759:	eb 82                	jmp    8006dd <vprintfmt+0x3c2>

0080075b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	83 ec 18             	sub    $0x18,%esp
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800767:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800771:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800778:	85 c0                	test   %eax,%eax
  80077a:	74 26                	je     8007a2 <vsnprintf+0x47>
  80077c:	85 d2                	test   %edx,%edx
  80077e:	7e 22                	jle    8007a2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800780:	ff 75 14             	push   0x14(%ebp)
  800783:	ff 75 10             	push   0x10(%ebp)
  800786:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800789:	50                   	push   %eax
  80078a:	68 e1 02 80 00       	push   $0x8002e1
  80078f:	e8 87 fb ff ff       	call   80031b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800794:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800797:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079d:	83 c4 10             	add    $0x10,%esp
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    
		return -E_INVAL;
  8007a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a7:	eb f7                	jmp    8007a0 <vsnprintf+0x45>

008007a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b2:	50                   	push   %eax
  8007b3:	ff 75 10             	push   0x10(%ebp)
  8007b6:	ff 75 0c             	push   0xc(%ebp)
  8007b9:	ff 75 08             	push   0x8(%ebp)
  8007bc:	e8 9a ff ff ff       	call   80075b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ce:	eb 03                	jmp    8007d3 <strlen+0x10>
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	75 f7                	jne    8007d0 <strlen+0xd>
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e9:	eb 03                	jmp    8007ee <strnlen+0x13>
		n++;
  8007eb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ee:	39 d0                	cmp    %edx,%eax
  8007f0:	74 08                	je     8007fa <strnlen+0x1f>
  8007f2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f6:	75 f3                	jne    8007eb <strnlen+0x10>
  8007f8:	89 c2                	mov    %eax,%edx
	return n;
}
  8007fa:	89 d0                	mov    %edx,%eax
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800805:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
  80080d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800811:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800814:	83 c0 01             	add    $0x1,%eax
  800817:	84 d2                	test   %dl,%dl
  800819:	75 f2                	jne    80080d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80081b:	89 c8                	mov    %ecx,%eax
  80081d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	53                   	push   %ebx
  800826:	83 ec 10             	sub    $0x10,%esp
  800829:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082c:	53                   	push   %ebx
  80082d:	e8 91 ff ff ff       	call   8007c3 <strlen>
  800832:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800835:	ff 75 0c             	push   0xc(%ebp)
  800838:	01 d8                	add    %ebx,%eax
  80083a:	50                   	push   %eax
  80083b:	e8 be ff ff ff       	call   8007fe <strcpy>
	return dst;
}
  800840:	89 d8                	mov    %ebx,%eax
  800842:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 75 08             	mov    0x8(%ebp),%esi
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800852:	89 f3                	mov    %esi,%ebx
  800854:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	89 f0                	mov    %esi,%eax
  800859:	eb 0f                	jmp    80086a <strncpy+0x23>
		*dst++ = *src;
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	0f b6 0a             	movzbl (%edx),%ecx
  800861:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800864:	80 f9 01             	cmp    $0x1,%cl
  800867:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80086a:	39 d8                	cmp    %ebx,%eax
  80086c:	75 ed                	jne    80085b <strncpy+0x14>
	}
	return ret;
}
  80086e:	89 f0                	mov    %esi,%eax
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	56                   	push   %esi
  800878:	53                   	push   %ebx
  800879:	8b 75 08             	mov    0x8(%ebp),%esi
  80087c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087f:	8b 55 10             	mov    0x10(%ebp),%edx
  800882:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800884:	85 d2                	test   %edx,%edx
  800886:	74 21                	je     8008a9 <strlcpy+0x35>
  800888:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088c:	89 f2                	mov    %esi,%edx
  80088e:	eb 09                	jmp    800899 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800890:	83 c1 01             	add    $0x1,%ecx
  800893:	83 c2 01             	add    $0x1,%edx
  800896:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800899:	39 c2                	cmp    %eax,%edx
  80089b:	74 09                	je     8008a6 <strlcpy+0x32>
  80089d:	0f b6 19             	movzbl (%ecx),%ebx
  8008a0:	84 db                	test   %bl,%bl
  8008a2:	75 ec                	jne    800890 <strlcpy+0x1c>
  8008a4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008a6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a9:	29 f0                	sub    %esi,%eax
}
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b8:	eb 06                	jmp    8008c0 <strcmp+0x11>
		p++, q++;
  8008ba:	83 c1 01             	add    $0x1,%ecx
  8008bd:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008c0:	0f b6 01             	movzbl (%ecx),%eax
  8008c3:	84 c0                	test   %al,%al
  8008c5:	74 04                	je     8008cb <strcmp+0x1c>
  8008c7:	3a 02                	cmp    (%edx),%al
  8008c9:	74 ef                	je     8008ba <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cb:	0f b6 c0             	movzbl %al,%eax
  8008ce:	0f b6 12             	movzbl (%edx),%edx
  8008d1:	29 d0                	sub    %edx,%eax
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e4:	eb 06                	jmp    8008ec <strncmp+0x17>
		n--, p++, q++;
  8008e6:	83 c0 01             	add    $0x1,%eax
  8008e9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ec:	39 d8                	cmp    %ebx,%eax
  8008ee:	74 18                	je     800908 <strncmp+0x33>
  8008f0:	0f b6 08             	movzbl (%eax),%ecx
  8008f3:	84 c9                	test   %cl,%cl
  8008f5:	74 04                	je     8008fb <strncmp+0x26>
  8008f7:	3a 0a                	cmp    (%edx),%cl
  8008f9:	74 eb                	je     8008e6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fb:	0f b6 00             	movzbl (%eax),%eax
  8008fe:	0f b6 12             	movzbl (%edx),%edx
  800901:	29 d0                	sub    %edx,%eax
}
  800903:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800906:	c9                   	leave  
  800907:	c3                   	ret    
		return 0;
  800908:	b8 00 00 00 00       	mov    $0x0,%eax
  80090d:	eb f4                	jmp    800903 <strncmp+0x2e>

0080090f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800919:	eb 03                	jmp    80091e <strchr+0xf>
  80091b:	83 c0 01             	add    $0x1,%eax
  80091e:	0f b6 10             	movzbl (%eax),%edx
  800921:	84 d2                	test   %dl,%dl
  800923:	74 06                	je     80092b <strchr+0x1c>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	75 f2                	jne    80091b <strchr+0xc>
  800929:	eb 05                	jmp    800930 <strchr+0x21>
			return (char *) s;
	return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093f:	38 ca                	cmp    %cl,%dl
  800941:	74 09                	je     80094c <strfind+0x1a>
  800943:	84 d2                	test   %dl,%dl
  800945:	74 05                	je     80094c <strfind+0x1a>
	for (; *s; s++)
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	eb f0                	jmp    80093c <strfind+0xa>
			break;
	return (char *) s;
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	57                   	push   %edi
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	8b 7d 08             	mov    0x8(%ebp),%edi
  800957:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095a:	85 c9                	test   %ecx,%ecx
  80095c:	74 2f                	je     80098d <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095e:	89 f8                	mov    %edi,%eax
  800960:	09 c8                	or     %ecx,%eax
  800962:	a8 03                	test   $0x3,%al
  800964:	75 21                	jne    800987 <memset+0x39>
		c &= 0xFF;
  800966:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096a:	89 d0                	mov    %edx,%eax
  80096c:	c1 e0 08             	shl    $0x8,%eax
  80096f:	89 d3                	mov    %edx,%ebx
  800971:	c1 e3 18             	shl    $0x18,%ebx
  800974:	89 d6                	mov    %edx,%esi
  800976:	c1 e6 10             	shl    $0x10,%esi
  800979:	09 f3                	or     %esi,%ebx
  80097b:	09 da                	or     %ebx,%edx
  80097d:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800982:	fc                   	cld    
  800983:	f3 ab                	rep stos %eax,%es:(%edi)
  800985:	eb 06                	jmp    80098d <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800987:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098a:	fc                   	cld    
  80098b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098d:	89 f8                	mov    %edi,%eax
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a2:	39 c6                	cmp    %eax,%esi
  8009a4:	73 32                	jae    8009d8 <memmove+0x44>
  8009a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a9:	39 c2                	cmp    %eax,%edx
  8009ab:	76 2b                	jbe    8009d8 <memmove+0x44>
		s += n;
		d += n;
  8009ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	89 d6                	mov    %edx,%esi
  8009b2:	09 fe                	or     %edi,%esi
  8009b4:	09 ce                	or     %ecx,%esi
  8009b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bc:	75 0e                	jne    8009cc <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009be:	83 ef 04             	sub    $0x4,%edi
  8009c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb 09                	jmp    8009d5 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cc:	83 ef 01             	sub    $0x1,%edi
  8009cf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009d2:	fd                   	std    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d5:	fc                   	cld    
  8009d6:	eb 1a                	jmp    8009f2 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d8:	89 f2                	mov    %esi,%edx
  8009da:	09 c2                	or     %eax,%edx
  8009dc:	09 ca                	or     %ecx,%edx
  8009de:	f6 c2 03             	test   $0x3,%dl
  8009e1:	75 0a                	jne    8009ed <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb 05                	jmp    8009f2 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009fc:	ff 75 10             	push   0x10(%ebp)
  8009ff:	ff 75 0c             	push   0xc(%ebp)
  800a02:	ff 75 08             	push   0x8(%ebp)
  800a05:	e8 8a ff ff ff       	call   800994 <memmove>
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a17:	89 c6                	mov    %eax,%esi
  800a19:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1c:	eb 06                	jmp    800a24 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a24:	39 f0                	cmp    %esi,%eax
  800a26:	74 14                	je     800a3c <memcmp+0x30>
		if (*s1 != *s2)
  800a28:	0f b6 08             	movzbl (%eax),%ecx
  800a2b:	0f b6 1a             	movzbl (%edx),%ebx
  800a2e:	38 d9                	cmp    %bl,%cl
  800a30:	74 ec                	je     800a1e <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a32:	0f b6 c1             	movzbl %cl,%eax
  800a35:	0f b6 db             	movzbl %bl,%ebx
  800a38:	29 d8                	sub    %ebx,%eax
  800a3a:	eb 05                	jmp    800a41 <memcmp+0x35>
	}

	return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4e:	89 c2                	mov    %eax,%edx
  800a50:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a53:	eb 03                	jmp    800a58 <memfind+0x13>
  800a55:	83 c0 01             	add    $0x1,%eax
  800a58:	39 d0                	cmp    %edx,%eax
  800a5a:	73 04                	jae    800a60 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5c:	38 08                	cmp    %cl,(%eax)
  800a5e:	75 f5                	jne    800a55 <memfind+0x10>
			break;
	return (void *) s;
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6e:	eb 03                	jmp    800a73 <strtol+0x11>
		s++;
  800a70:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a73:	0f b6 02             	movzbl (%edx),%eax
  800a76:	3c 20                	cmp    $0x20,%al
  800a78:	74 f6                	je     800a70 <strtol+0xe>
  800a7a:	3c 09                	cmp    $0x9,%al
  800a7c:	74 f2                	je     800a70 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a7e:	3c 2b                	cmp    $0x2b,%al
  800a80:	74 2a                	je     800aac <strtol+0x4a>
	int neg = 0;
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a87:	3c 2d                	cmp    $0x2d,%al
  800a89:	74 2b                	je     800ab6 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a91:	75 0f                	jne    800aa2 <strtol+0x40>
  800a93:	80 3a 30             	cmpb   $0x30,(%edx)
  800a96:	74 28                	je     800ac0 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a98:	85 db                	test   %ebx,%ebx
  800a9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a9f:	0f 44 d8             	cmove  %eax,%ebx
  800aa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aaa:	eb 46                	jmp    800af2 <strtol+0x90>
		s++;
  800aac:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aaf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab4:	eb d5                	jmp    800a8b <strtol+0x29>
		s++, neg = 1;
  800ab6:	83 c2 01             	add    $0x1,%edx
  800ab9:	bf 01 00 00 00       	mov    $0x1,%edi
  800abe:	eb cb                	jmp    800a8b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac4:	74 0e                	je     800ad4 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ac6:	85 db                	test   %ebx,%ebx
  800ac8:	75 d8                	jne    800aa2 <strtol+0x40>
		s++, base = 8;
  800aca:	83 c2 01             	add    $0x1,%edx
  800acd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad2:	eb ce                	jmp    800aa2 <strtol+0x40>
		s += 2, base = 16;
  800ad4:	83 c2 02             	add    $0x2,%edx
  800ad7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adc:	eb c4                	jmp    800aa2 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ade:	0f be c0             	movsbl %al,%eax
  800ae1:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae4:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ae7:	7d 3a                	jge    800b23 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ae9:	83 c2 01             	add    $0x1,%edx
  800aec:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800af0:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800af2:	0f b6 02             	movzbl (%edx),%eax
  800af5:	8d 70 d0             	lea    -0x30(%eax),%esi
  800af8:	89 f3                	mov    %esi,%ebx
  800afa:	80 fb 09             	cmp    $0x9,%bl
  800afd:	76 df                	jbe    800ade <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800aff:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b02:	89 f3                	mov    %esi,%ebx
  800b04:	80 fb 19             	cmp    $0x19,%bl
  800b07:	77 08                	ja     800b11 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b09:	0f be c0             	movsbl %al,%eax
  800b0c:	83 e8 57             	sub    $0x57,%eax
  800b0f:	eb d3                	jmp    800ae4 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b11:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b14:	89 f3                	mov    %esi,%ebx
  800b16:	80 fb 19             	cmp    $0x19,%bl
  800b19:	77 08                	ja     800b23 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b1b:	0f be c0             	movsbl %al,%eax
  800b1e:	83 e8 37             	sub    $0x37,%eax
  800b21:	eb c1                	jmp    800ae4 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b27:	74 05                	je     800b2e <strtol+0xcc>
		*endptr = (char *) s;
  800b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b2e:	89 c8                	mov    %ecx,%eax
  800b30:	f7 d8                	neg    %eax
  800b32:	85 ff                	test   %edi,%edi
  800b34:	0f 45 c8             	cmovne %eax,%ecx
}
  800b37:	89 c8                	mov    %ecx,%eax
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b44:	b8 00 00 00 00       	mov    $0x0,%eax
  800b49:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	89 c3                	mov    %eax,%ebx
  800b51:	89 c7                	mov    %eax,%edi
  800b53:	89 c6                	mov    %eax,%esi
  800b55:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6c:	89 d1                	mov    %edx,%ecx
  800b6e:	89 d3                	mov    %edx,%ebx
  800b70:	89 d7                	mov    %edx,%edi
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b91:	89 cb                	mov    %ecx,%ebx
  800b93:	89 cf                	mov    %ecx,%edi
  800b95:	89 ce                	mov    %ecx,%esi
  800b97:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	7f 08                	jg     800ba5 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 03                	push   $0x3
  800bab:	68 7f 29 80 00       	push   $0x80297f
  800bb0:	6a 2a                	push   $0x2a
  800bb2:	68 9c 29 80 00       	push   $0x80299c
  800bb7:	e8 8d f5 ff ff       	call   800149 <_panic>

00800bbc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcc:	89 d1                	mov    %edx,%ecx
  800bce:	89 d3                	mov    %edx,%ebx
  800bd0:	89 d7                	mov    %edx,%edi
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_yield>:

void
sys_yield(void)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c03:	be 00 00 00 00       	mov    $0x0,%esi
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c16:	89 f7                	mov    %esi,%edi
  800c18:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7f 08                	jg     800c26 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 04                	push   $0x4
  800c2c:	68 7f 29 80 00       	push   $0x80297f
  800c31:	6a 2a                	push   $0x2a
  800c33:	68 9c 29 80 00       	push   $0x80299c
  800c38:	e8 0c f5 ff ff       	call   800149 <_panic>

00800c3d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c57:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7f 08                	jg     800c68 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 05                	push   $0x5
  800c6e:	68 7f 29 80 00       	push   $0x80297f
  800c73:	6a 2a                	push   $0x2a
  800c75:	68 9c 29 80 00       	push   $0x80299c
  800c7a:	e8 ca f4 ff ff       	call   800149 <_panic>

00800c7f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	b8 06 00 00 00       	mov    $0x6,%eax
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7f 08                	jg     800caa <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 06                	push   $0x6
  800cb0:	68 7f 29 80 00       	push   $0x80297f
  800cb5:	6a 2a                	push   $0x2a
  800cb7:	68 9c 29 80 00       	push   $0x80299c
  800cbc:	e8 88 f4 ff ff       	call   800149 <_panic>

00800cc1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7f 08                	jg     800cec <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 08                	push   $0x8
  800cf2:	68 7f 29 80 00       	push   $0x80297f
  800cf7:	6a 2a                	push   $0x2a
  800cf9:	68 9c 29 80 00       	push   $0x80299c
  800cfe:	e8 46 f4 ff ff       	call   800149 <_panic>

00800d03 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7f 08                	jg     800d2e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 09                	push   $0x9
  800d34:	68 7f 29 80 00       	push   $0x80297f
  800d39:	6a 2a                	push   $0x2a
  800d3b:	68 9c 29 80 00       	push   $0x80299c
  800d40:	e8 04 f4 ff ff       	call   800149 <_panic>

00800d45 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5e:	89 df                	mov    %ebx,%edi
  800d60:	89 de                	mov    %ebx,%esi
  800d62:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7f 08                	jg     800d70 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 0a                	push   $0xa
  800d76:	68 7f 29 80 00       	push   $0x80297f
  800d7b:	6a 2a                	push   $0x2a
  800d7d:	68 9c 29 80 00       	push   $0x80299c
  800d82:	e8 c2 f3 ff ff       	call   800149 <_panic>

00800d87 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d98:	be 00 00 00 00       	mov    $0x0,%esi
  800d9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc0:	89 cb                	mov    %ecx,%ebx
  800dc2:	89 cf                	mov    %ecx,%edi
  800dc4:	89 ce                	mov    %ecx,%esi
  800dc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7f 08                	jg     800dd4 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 0d                	push   $0xd
  800dda:	68 7f 29 80 00       	push   $0x80297f
  800ddf:	6a 2a                	push   $0x2a
  800de1:	68 9c 29 80 00       	push   $0x80299c
  800de6:	e8 5e f3 ff ff       	call   800149 <_panic>

00800deb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df1:	ba 00 00 00 00       	mov    $0x0,%edx
  800df6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dfb:	89 d1                	mov    %edx,%ecx
  800dfd:	89 d3                	mov    %edx,%ebx
  800dff:	89 d7                	mov    %edx,%edi
  800e01:	89 d6                	mov    %edx,%esi
  800e03:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	89 de                	mov    %ebx,%esi
  800e24:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	b8 10 00 00 00       	mov    $0x10,%eax
  800e41:	89 df                	mov    %ebx,%edi
  800e43:	89 de                	mov    %ebx,%esi
  800e45:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e54:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e56:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e5a:	0f 84 8e 00 00 00    	je     800eee <pgfault+0xa2>
  800e60:	89 f0                	mov    %esi,%eax
  800e62:	c1 e8 0c             	shr    $0xc,%eax
  800e65:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e6c:	f6 c4 08             	test   $0x8,%ah
  800e6f:	74 7d                	je     800eee <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e71:	e8 46 fd ff ff       	call   800bbc <sys_getenvid>
  800e76:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	6a 07                	push   $0x7
  800e7d:	68 00 f0 7f 00       	push   $0x7ff000
  800e82:	50                   	push   %eax
  800e83:	e8 72 fd ff ff       	call   800bfa <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	78 73                	js     800f02 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e8f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	68 00 10 00 00       	push   $0x1000
  800e9d:	56                   	push   %esi
  800e9e:	68 00 f0 7f 00       	push   $0x7ff000
  800ea3:	e8 ec fa ff ff       	call   800994 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800ea8:	83 c4 08             	add    $0x8,%esp
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	e8 cd fd ff ff       	call   800c7f <sys_page_unmap>
  800eb2:	83 c4 10             	add    $0x10,%esp
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	78 5b                	js     800f14 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	6a 07                	push   $0x7
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	68 00 f0 7f 00       	push   $0x7ff000
  800ec5:	53                   	push   %ebx
  800ec6:	e8 72 fd ff ff       	call   800c3d <sys_page_map>
  800ecb:	83 c4 20             	add    $0x20,%esp
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	78 54                	js     800f26 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800ed2:	83 ec 08             	sub    $0x8,%esp
  800ed5:	68 00 f0 7f 00       	push   $0x7ff000
  800eda:	53                   	push   %ebx
  800edb:	e8 9f fd ff ff       	call   800c7f <sys_page_unmap>
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	78 51                	js     800f38 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	68 ac 29 80 00       	push   $0x8029ac
  800ef6:	6a 1d                	push   $0x1d
  800ef8:	68 28 2a 80 00       	push   $0x802a28
  800efd:	e8 47 f2 ff ff       	call   800149 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f02:	50                   	push   %eax
  800f03:	68 e4 29 80 00       	push   $0x8029e4
  800f08:	6a 29                	push   $0x29
  800f0a:	68 28 2a 80 00       	push   $0x802a28
  800f0f:	e8 35 f2 ff ff       	call   800149 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f14:	50                   	push   %eax
  800f15:	68 08 2a 80 00       	push   $0x802a08
  800f1a:	6a 2e                	push   $0x2e
  800f1c:	68 28 2a 80 00       	push   $0x802a28
  800f21:	e8 23 f2 ff ff       	call   800149 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800f26:	50                   	push   %eax
  800f27:	68 33 2a 80 00       	push   $0x802a33
  800f2c:	6a 30                	push   $0x30
  800f2e:	68 28 2a 80 00       	push   $0x802a28
  800f33:	e8 11 f2 ff ff       	call   800149 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f38:	50                   	push   %eax
  800f39:	68 08 2a 80 00       	push   $0x802a08
  800f3e:	6a 32                	push   $0x32
  800f40:	68 28 2a 80 00       	push   $0x802a28
  800f45:	e8 ff f1 ff ff       	call   800149 <_panic>

00800f4a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f53:	68 4c 0e 80 00       	push   $0x800e4c
  800f58:	e8 7e 12 00 00       	call   8021db <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f5d:	b8 07 00 00 00       	mov    $0x7,%eax
  800f62:	cd 30                	int    $0x30
  800f64:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 30                	js     800f9e <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f6e:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f73:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f77:	75 76                	jne    800fef <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f79:	e8 3e fc ff ff       	call   800bbc <sys_getenvid>
  800f7e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f83:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800f89:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f8e:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f93:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f99:	5b                   	pop    %ebx
  800f9a:	5e                   	pop    %esi
  800f9b:	5f                   	pop    %edi
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f9e:	50                   	push   %eax
  800f9f:	68 51 2a 80 00       	push   $0x802a51
  800fa4:	6a 78                	push   $0x78
  800fa6:	68 28 2a 80 00       	push   $0x802a28
  800fab:	e8 99 f1 ff ff       	call   800149 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	ff 75 e4             	push   -0x1c(%ebp)
  800fb6:	57                   	push   %edi
  800fb7:	ff 75 dc             	push   -0x24(%ebp)
  800fba:	57                   	push   %edi
  800fbb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fbe:	56                   	push   %esi
  800fbf:	e8 79 fc ff ff       	call   800c3d <sys_page_map>
	if(r<0) return r;
  800fc4:	83 c4 20             	add    $0x20,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 cb                	js     800f96 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800fcb:	83 ec 0c             	sub    $0xc,%esp
  800fce:	ff 75 e4             	push   -0x1c(%ebp)
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	e8 63 fc ff ff       	call   800c3d <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 76                	js     801057 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fe1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fe7:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fed:	74 75                	je     801064 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800fef:	89 d8                	mov    %ebx,%eax
  800ff1:	c1 e8 16             	shr    $0x16,%eax
  800ff4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ffb:	a8 01                	test   $0x1,%al
  800ffd:	74 e2                	je     800fe1 <fork+0x97>
  800fff:	89 de                	mov    %ebx,%esi
  801001:	c1 ee 0c             	shr    $0xc,%esi
  801004:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100b:	a8 01                	test   $0x1,%al
  80100d:	74 d2                	je     800fe1 <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  80100f:	e8 a8 fb ff ff       	call   800bbc <sys_getenvid>
  801014:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801017:	89 f7                	mov    %esi,%edi
  801019:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  80101c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801023:	89 c1                	mov    %eax,%ecx
  801025:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80102b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  80102e:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801035:	f6 c6 04             	test   $0x4,%dh
  801038:	0f 85 72 ff ff ff    	jne    800fb0 <fork+0x66>
		perm &= ~PTE_W;
  80103e:	25 05 0e 00 00       	and    $0xe05,%eax
  801043:	80 cc 08             	or     $0x8,%ah
  801046:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  80104c:	0f 44 c1             	cmove  %ecx,%eax
  80104f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801052:	e9 59 ff ff ff       	jmp    800fb0 <fork+0x66>
  801057:	ba 00 00 00 00       	mov    $0x0,%edx
  80105c:	0f 4f c2             	cmovg  %edx,%eax
  80105f:	e9 32 ff ff ff       	jmp    800f96 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801064:	83 ec 04             	sub    $0x4,%esp
  801067:	6a 07                	push   $0x7
  801069:	68 00 f0 bf ee       	push   $0xeebff000
  80106e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801071:	57                   	push   %edi
  801072:	e8 83 fb ff ff       	call   800bfa <sys_page_alloc>
	if(r<0) return r;
  801077:	83 c4 10             	add    $0x10,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	0f 88 14 ff ff ff    	js     800f96 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	68 51 22 80 00       	push   $0x802251
  80108a:	57                   	push   %edi
  80108b:	e8 b5 fc ff ff       	call   800d45 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	0f 88 fb fe ff ff    	js     800f96 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80109b:	83 ec 08             	sub    $0x8,%esp
  80109e:	6a 02                	push   $0x2
  8010a0:	57                   	push   %edi
  8010a1:	e8 1b fc ff ff       	call   800cc1 <sys_env_set_status>
	if(r<0) return r;
  8010a6:	83 c4 10             	add    $0x10,%esp
	return envid;
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	0f 49 c7             	cmovns %edi,%eax
  8010ae:	e9 e3 fe ff ff       	jmp    800f96 <fork+0x4c>

008010b3 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b9:	68 61 2a 80 00       	push   $0x802a61
  8010be:	68 a1 00 00 00       	push   $0xa1
  8010c3:	68 28 2a 80 00       	push   $0x802a28
  8010c8:	e8 7c f0 ff ff       	call   800149 <_panic>

008010cd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d8:	c1 e8 0c             	shr    $0xc,%eax
}
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010ed:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010fc:	89 c2                	mov    %eax,%edx
  8010fe:	c1 ea 16             	shr    $0x16,%edx
  801101:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801108:	f6 c2 01             	test   $0x1,%dl
  80110b:	74 29                	je     801136 <fd_alloc+0x42>
  80110d:	89 c2                	mov    %eax,%edx
  80110f:	c1 ea 0c             	shr    $0xc,%edx
  801112:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801119:	f6 c2 01             	test   $0x1,%dl
  80111c:	74 18                	je     801136 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80111e:	05 00 10 00 00       	add    $0x1000,%eax
  801123:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801128:	75 d2                	jne    8010fc <fd_alloc+0x8>
  80112a:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80112f:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801134:	eb 05                	jmp    80113b <fd_alloc+0x47>
			return 0;
  801136:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80113b:	8b 55 08             	mov    0x8(%ebp),%edx
  80113e:	89 02                	mov    %eax,(%edx)
}
  801140:	89 c8                	mov    %ecx,%eax
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114a:	83 f8 1f             	cmp    $0x1f,%eax
  80114d:	77 30                	ja     80117f <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80114f:	c1 e0 0c             	shl    $0xc,%eax
  801152:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801157:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80115d:	f6 c2 01             	test   $0x1,%dl
  801160:	74 24                	je     801186 <fd_lookup+0x42>
  801162:	89 c2                	mov    %eax,%edx
  801164:	c1 ea 0c             	shr    $0xc,%edx
  801167:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80116e:	f6 c2 01             	test   $0x1,%dl
  801171:	74 1a                	je     80118d <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801173:	8b 55 0c             	mov    0xc(%ebp),%edx
  801176:	89 02                	mov    %eax,(%edx)
	return 0;
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    
		return -E_INVAL;
  80117f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801184:	eb f7                	jmp    80117d <fd_lookup+0x39>
		return -E_INVAL;
  801186:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118b:	eb f0                	jmp    80117d <fd_lookup+0x39>
  80118d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801192:	eb e9                	jmp    80117d <fd_lookup+0x39>

00801194 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	53                   	push   %ebx
  801198:	83 ec 04             	sub    $0x4,%esp
  80119b:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a3:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8011a8:	39 13                	cmp    %edx,(%ebx)
  8011aa:	74 37                	je     8011e3 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8011ac:	83 c0 01             	add    $0x1,%eax
  8011af:	8b 1c 85 f4 2a 80 00 	mov    0x802af4(,%eax,4),%ebx
  8011b6:	85 db                	test   %ebx,%ebx
  8011b8:	75 ee                	jne    8011a8 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8011bf:	8b 40 58             	mov    0x58(%eax),%eax
  8011c2:	83 ec 04             	sub    $0x4,%esp
  8011c5:	52                   	push   %edx
  8011c6:	50                   	push   %eax
  8011c7:	68 78 2a 80 00       	push   $0x802a78
  8011cc:	e8 53 f0 ff ff       	call   800224 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8011d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011dc:	89 1a                	mov    %ebx,(%edx)
}
  8011de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    
			return 0;
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e8:	eb ef                	jmp    8011d9 <dev_lookup+0x45>

008011ea <fd_close>:
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	57                   	push   %edi
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 24             	sub    $0x24,%esp
  8011f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011fc:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011fd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801203:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801206:	50                   	push   %eax
  801207:	e8 38 ff ff ff       	call   801144 <fd_lookup>
  80120c:	89 c3                	mov    %eax,%ebx
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	78 05                	js     80121a <fd_close+0x30>
	    || fd != fd2)
  801215:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801218:	74 16                	je     801230 <fd_close+0x46>
		return (must_exist ? r : 0);
  80121a:	89 f8                	mov    %edi,%eax
  80121c:	84 c0                	test   %al,%al
  80121e:	b8 00 00 00 00       	mov    $0x0,%eax
  801223:	0f 44 d8             	cmove  %eax,%ebx
}
  801226:	89 d8                	mov    %ebx,%eax
  801228:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	ff 36                	push   (%esi)
  801239:	e8 56 ff ff ff       	call   801194 <dev_lookup>
  80123e:	89 c3                	mov    %eax,%ebx
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 1a                	js     801261 <fd_close+0x77>
		if (dev->dev_close)
  801247:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80124a:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80124d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801252:	85 c0                	test   %eax,%eax
  801254:	74 0b                	je     801261 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801256:	83 ec 0c             	sub    $0xc,%esp
  801259:	56                   	push   %esi
  80125a:	ff d0                	call   *%eax
  80125c:	89 c3                	mov    %eax,%ebx
  80125e:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	56                   	push   %esi
  801265:	6a 00                	push   $0x0
  801267:	e8 13 fa ff ff       	call   800c7f <sys_page_unmap>
	return r;
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	eb b5                	jmp    801226 <fd_close+0x3c>

00801271 <close>:

int
close(int fdnum)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	ff 75 08             	push   0x8(%ebp)
  80127e:	e8 c1 fe ff ff       	call   801144 <fd_lookup>
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	79 02                	jns    80128c <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80128a:	c9                   	leave  
  80128b:	c3                   	ret    
		return fd_close(fd, 1);
  80128c:	83 ec 08             	sub    $0x8,%esp
  80128f:	6a 01                	push   $0x1
  801291:	ff 75 f4             	push   -0xc(%ebp)
  801294:	e8 51 ff ff ff       	call   8011ea <fd_close>
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	eb ec                	jmp    80128a <close+0x19>

0080129e <close_all>:

void
close_all(void)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	53                   	push   %ebx
  8012ae:	e8 be ff ff ff       	call   801271 <close>
	for (i = 0; i < MAXFD; i++)
  8012b3:	83 c3 01             	add    $0x1,%ebx
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	83 fb 20             	cmp    $0x20,%ebx
  8012bc:	75 ec                	jne    8012aa <close_all+0xc>
}
  8012be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	57                   	push   %edi
  8012c7:	56                   	push   %esi
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	ff 75 08             	push   0x8(%ebp)
  8012d3:	e8 6c fe ff ff       	call   801144 <fd_lookup>
  8012d8:	89 c3                	mov    %eax,%ebx
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 7f                	js     801360 <dup+0x9d>
		return r;
	close(newfdnum);
  8012e1:	83 ec 0c             	sub    $0xc,%esp
  8012e4:	ff 75 0c             	push   0xc(%ebp)
  8012e7:	e8 85 ff ff ff       	call   801271 <close>

	newfd = INDEX2FD(newfdnum);
  8012ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012ef:	c1 e6 0c             	shl    $0xc,%esi
  8012f2:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012fb:	89 3c 24             	mov    %edi,(%esp)
  8012fe:	e8 da fd ff ff       	call   8010dd <fd2data>
  801303:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801305:	89 34 24             	mov    %esi,(%esp)
  801308:	e8 d0 fd ff ff       	call   8010dd <fd2data>
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801313:	89 d8                	mov    %ebx,%eax
  801315:	c1 e8 16             	shr    $0x16,%eax
  801318:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80131f:	a8 01                	test   $0x1,%al
  801321:	74 11                	je     801334 <dup+0x71>
  801323:	89 d8                	mov    %ebx,%eax
  801325:	c1 e8 0c             	shr    $0xc,%eax
  801328:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80132f:	f6 c2 01             	test   $0x1,%dl
  801332:	75 36                	jne    80136a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801334:	89 f8                	mov    %edi,%eax
  801336:	c1 e8 0c             	shr    $0xc,%eax
  801339:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801340:	83 ec 0c             	sub    $0xc,%esp
  801343:	25 07 0e 00 00       	and    $0xe07,%eax
  801348:	50                   	push   %eax
  801349:	56                   	push   %esi
  80134a:	6a 00                	push   $0x0
  80134c:	57                   	push   %edi
  80134d:	6a 00                	push   $0x0
  80134f:	e8 e9 f8 ff ff       	call   800c3d <sys_page_map>
  801354:	89 c3                	mov    %eax,%ebx
  801356:	83 c4 20             	add    $0x20,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 33                	js     801390 <dup+0xcd>
		goto err;

	return newfdnum;
  80135d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801360:	89 d8                	mov    %ebx,%eax
  801362:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801365:	5b                   	pop    %ebx
  801366:	5e                   	pop    %esi
  801367:	5f                   	pop    %edi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80136a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	25 07 0e 00 00       	and    $0xe07,%eax
  801379:	50                   	push   %eax
  80137a:	ff 75 d4             	push   -0x2c(%ebp)
  80137d:	6a 00                	push   $0x0
  80137f:	53                   	push   %ebx
  801380:	6a 00                	push   $0x0
  801382:	e8 b6 f8 ff ff       	call   800c3d <sys_page_map>
  801387:	89 c3                	mov    %eax,%ebx
  801389:	83 c4 20             	add    $0x20,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	79 a4                	jns    801334 <dup+0x71>
	sys_page_unmap(0, newfd);
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	56                   	push   %esi
  801394:	6a 00                	push   $0x0
  801396:	e8 e4 f8 ff ff       	call   800c7f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80139b:	83 c4 08             	add    $0x8,%esp
  80139e:	ff 75 d4             	push   -0x2c(%ebp)
  8013a1:	6a 00                	push   $0x0
  8013a3:	e8 d7 f8 ff ff       	call   800c7f <sys_page_unmap>
	return r;
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	eb b3                	jmp    801360 <dup+0x9d>

008013ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	56                   	push   %esi
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 18             	sub    $0x18,%esp
  8013b5:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	56                   	push   %esi
  8013bd:	e8 82 fd ff ff       	call   801144 <fd_lookup>
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 3c                	js     801405 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d2:	50                   	push   %eax
  8013d3:	ff 33                	push   (%ebx)
  8013d5:	e8 ba fd ff ff       	call   801194 <dev_lookup>
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 24                	js     801405 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013e1:	8b 43 08             	mov    0x8(%ebx),%eax
  8013e4:	83 e0 03             	and    $0x3,%eax
  8013e7:	83 f8 01             	cmp    $0x1,%eax
  8013ea:	74 20                	je     80140c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ef:	8b 40 08             	mov    0x8(%eax),%eax
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	74 37                	je     80142d <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013f6:	83 ec 04             	sub    $0x4,%esp
  8013f9:	ff 75 10             	push   0x10(%ebp)
  8013fc:	ff 75 0c             	push   0xc(%ebp)
  8013ff:	53                   	push   %ebx
  801400:	ff d0                	call   *%eax
  801402:	83 c4 10             	add    $0x10,%esp
}
  801405:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80140c:	a1 04 40 80 00       	mov    0x804004,%eax
  801411:	8b 40 58             	mov    0x58(%eax),%eax
  801414:	83 ec 04             	sub    $0x4,%esp
  801417:	56                   	push   %esi
  801418:	50                   	push   %eax
  801419:	68 b9 2a 80 00       	push   $0x802ab9
  80141e:	e8 01 ee ff ff       	call   800224 <cprintf>
		return -E_INVAL;
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142b:	eb d8                	jmp    801405 <read+0x58>
		return -E_NOT_SUPP;
  80142d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801432:	eb d1                	jmp    801405 <read+0x58>

00801434 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	57                   	push   %edi
  801438:	56                   	push   %esi
  801439:	53                   	push   %ebx
  80143a:	83 ec 0c             	sub    $0xc,%esp
  80143d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801440:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801443:	bb 00 00 00 00       	mov    $0x0,%ebx
  801448:	eb 02                	jmp    80144c <readn+0x18>
  80144a:	01 c3                	add    %eax,%ebx
  80144c:	39 f3                	cmp    %esi,%ebx
  80144e:	73 21                	jae    801471 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801450:	83 ec 04             	sub    $0x4,%esp
  801453:	89 f0                	mov    %esi,%eax
  801455:	29 d8                	sub    %ebx,%eax
  801457:	50                   	push   %eax
  801458:	89 d8                	mov    %ebx,%eax
  80145a:	03 45 0c             	add    0xc(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	57                   	push   %edi
  80145f:	e8 49 ff ff ff       	call   8013ad <read>
		if (m < 0)
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	85 c0                	test   %eax,%eax
  801469:	78 04                	js     80146f <readn+0x3b>
			return m;
		if (m == 0)
  80146b:	75 dd                	jne    80144a <readn+0x16>
  80146d:	eb 02                	jmp    801471 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801471:	89 d8                	mov    %ebx,%eax
  801473:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801476:	5b                   	pop    %ebx
  801477:	5e                   	pop    %esi
  801478:	5f                   	pop    %edi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	56                   	push   %esi
  80147f:	53                   	push   %ebx
  801480:	83 ec 18             	sub    $0x18,%esp
  801483:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801486:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	53                   	push   %ebx
  80148b:	e8 b4 fc ff ff       	call   801144 <fd_lookup>
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	78 37                	js     8014ce <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801497:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a0:	50                   	push   %eax
  8014a1:	ff 36                	push   (%esi)
  8014a3:	e8 ec fc ff ff       	call   801194 <dev_lookup>
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 1f                	js     8014ce <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014af:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014b3:	74 20                	je     8014d5 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	74 37                	je     8014f6 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	ff 75 10             	push   0x10(%ebp)
  8014c5:	ff 75 0c             	push   0xc(%ebp)
  8014c8:	56                   	push   %esi
  8014c9:	ff d0                	call   *%eax
  8014cb:	83 c4 10             	add    $0x10,%esp
}
  8014ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d1:	5b                   	pop    %ebx
  8014d2:	5e                   	pop    %esi
  8014d3:	5d                   	pop    %ebp
  8014d4:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8014da:	8b 40 58             	mov    0x58(%eax),%eax
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	53                   	push   %ebx
  8014e1:	50                   	push   %eax
  8014e2:	68 d5 2a 80 00       	push   $0x802ad5
  8014e7:	e8 38 ed ff ff       	call   800224 <cprintf>
		return -E_INVAL;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f4:	eb d8                	jmp    8014ce <write+0x53>
		return -E_NOT_SUPP;
  8014f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014fb:	eb d1                	jmp    8014ce <write+0x53>

008014fd <seek>:

int
seek(int fdnum, off_t offset)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801503:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801506:	50                   	push   %eax
  801507:	ff 75 08             	push   0x8(%ebp)
  80150a:	e8 35 fc ff ff       	call   801144 <fd_lookup>
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	85 c0                	test   %eax,%eax
  801514:	78 0e                	js     801524 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801516:	8b 55 0c             	mov    0xc(%ebp),%edx
  801519:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80151f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	56                   	push   %esi
  80152a:	53                   	push   %ebx
  80152b:	83 ec 18             	sub    $0x18,%esp
  80152e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801531:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	53                   	push   %ebx
  801536:	e8 09 fc ff ff       	call   801144 <fd_lookup>
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 34                	js     801576 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801542:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	ff 36                	push   (%esi)
  80154e:	e8 41 fc ff ff       	call   801194 <dev_lookup>
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 1c                	js     801576 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155a:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80155e:	74 1d                	je     80157d <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801560:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801563:	8b 40 18             	mov    0x18(%eax),%eax
  801566:	85 c0                	test   %eax,%eax
  801568:	74 34                	je     80159e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	ff 75 0c             	push   0xc(%ebp)
  801570:	56                   	push   %esi
  801571:	ff d0                	call   *%eax
  801573:	83 c4 10             	add    $0x10,%esp
}
  801576:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801579:	5b                   	pop    %ebx
  80157a:	5e                   	pop    %esi
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80157d:	a1 04 40 80 00       	mov    0x804004,%eax
  801582:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801585:	83 ec 04             	sub    $0x4,%esp
  801588:	53                   	push   %ebx
  801589:	50                   	push   %eax
  80158a:	68 98 2a 80 00       	push   $0x802a98
  80158f:	e8 90 ec ff ff       	call   800224 <cprintf>
		return -E_INVAL;
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159c:	eb d8                	jmp    801576 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80159e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a3:	eb d1                	jmp    801576 <ftruncate+0x50>

008015a5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	56                   	push   %esi
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 18             	sub    $0x18,%esp
  8015ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	ff 75 08             	push   0x8(%ebp)
  8015b7:	e8 88 fb ff ff       	call   801144 <fd_lookup>
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 49                	js     80160c <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	ff 36                	push   (%esi)
  8015cf:	e8 c0 fb ff ff       	call   801194 <dev_lookup>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 31                	js     80160c <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8015db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015e2:	74 2f                	je     801613 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ee:	00 00 00 
	stat->st_isdir = 0;
  8015f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015f8:	00 00 00 
	stat->st_dev = dev;
  8015fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	53                   	push   %ebx
  801605:	56                   	push   %esi
  801606:	ff 50 14             	call   *0x14(%eax)
  801609:	83 c4 10             	add    $0x10,%esp
}
  80160c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    
		return -E_NOT_SUPP;
  801613:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801618:	eb f2                	jmp    80160c <fstat+0x67>

0080161a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	56                   	push   %esi
  80161e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	6a 00                	push   $0x0
  801624:	ff 75 08             	push   0x8(%ebp)
  801627:	e8 e4 01 00 00       	call   801810 <open>
  80162c:	89 c3                	mov    %eax,%ebx
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 1b                	js     801650 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	ff 75 0c             	push   0xc(%ebp)
  80163b:	50                   	push   %eax
  80163c:	e8 64 ff ff ff       	call   8015a5 <fstat>
  801641:	89 c6                	mov    %eax,%esi
	close(fd);
  801643:	89 1c 24             	mov    %ebx,(%esp)
  801646:	e8 26 fc ff ff       	call   801271 <close>
	return r;
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	89 f3                	mov    %esi,%ebx
}
  801650:	89 d8                	mov    %ebx,%eax
  801652:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801655:	5b                   	pop    %ebx
  801656:	5e                   	pop    %esi
  801657:	5d                   	pop    %ebp
  801658:	c3                   	ret    

00801659 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
  80165e:	89 c6                	mov    %eax,%esi
  801660:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801662:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801669:	74 27                	je     801692 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80166b:	6a 07                	push   $0x7
  80166d:	68 00 50 80 00       	push   $0x805000
  801672:	56                   	push   %esi
  801673:	ff 35 00 60 80 00    	push   0x806000
  801679:	e8 69 0c 00 00       	call   8022e7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80167e:	83 c4 0c             	add    $0xc,%esp
  801681:	6a 00                	push   $0x0
  801683:	53                   	push   %ebx
  801684:	6a 00                	push   $0x0
  801686:	e8 ec 0b 00 00       	call   802277 <ipc_recv>
}
  80168b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168e:	5b                   	pop    %ebx
  80168f:	5e                   	pop    %esi
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	6a 01                	push   $0x1
  801697:	e8 9f 0c 00 00       	call   80233b <ipc_find_env>
  80169c:	a3 00 60 80 00       	mov    %eax,0x806000
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	eb c5                	jmp    80166b <fsipc+0x12>

008016a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8016af:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c9:	e8 8b ff ff ff       	call   801659 <fsipc>
}
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <devfile_flush>:
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8016eb:	e8 69 ff ff ff       	call   801659 <fsipc>
}
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    

008016f2 <devfile_stat>:
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 04             	sub    $0x4,%esp
  8016f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801702:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801707:	ba 00 00 00 00       	mov    $0x0,%edx
  80170c:	b8 05 00 00 00       	mov    $0x5,%eax
  801711:	e8 43 ff ff ff       	call   801659 <fsipc>
  801716:	85 c0                	test   %eax,%eax
  801718:	78 2c                	js     801746 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	68 00 50 80 00       	push   $0x805000
  801722:	53                   	push   %ebx
  801723:	e8 d6 f0 ff ff       	call   8007fe <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801728:	a1 80 50 80 00       	mov    0x805080,%eax
  80172d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801733:	a1 84 50 80 00       	mov    0x805084,%eax
  801738:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <devfile_write>:
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	83 ec 0c             	sub    $0xc,%esp
  801751:	8b 45 10             	mov    0x10(%ebp),%eax
  801754:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801759:	39 d0                	cmp    %edx,%eax
  80175b:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80175e:	8b 55 08             	mov    0x8(%ebp),%edx
  801761:	8b 52 0c             	mov    0xc(%edx),%edx
  801764:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80176a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80176f:	50                   	push   %eax
  801770:	ff 75 0c             	push   0xc(%ebp)
  801773:	68 08 50 80 00       	push   $0x805008
  801778:	e8 17 f2 ff ff       	call   800994 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	b8 04 00 00 00       	mov    $0x4,%eax
  801787:	e8 cd fe ff ff       	call   801659 <fsipc>
}
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <devfile_read>:
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801796:	8b 45 08             	mov    0x8(%ebp),%eax
  801799:	8b 40 0c             	mov    0xc(%eax),%eax
  80179c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017a1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ac:	b8 03 00 00 00       	mov    $0x3,%eax
  8017b1:	e8 a3 fe ff ff       	call   801659 <fsipc>
  8017b6:	89 c3                	mov    %eax,%ebx
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	78 1f                	js     8017db <devfile_read+0x4d>
	assert(r <= n);
  8017bc:	39 f0                	cmp    %esi,%eax
  8017be:	77 24                	ja     8017e4 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017c0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c5:	7f 33                	jg     8017fa <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c7:	83 ec 04             	sub    $0x4,%esp
  8017ca:	50                   	push   %eax
  8017cb:	68 00 50 80 00       	push   $0x805000
  8017d0:	ff 75 0c             	push   0xc(%ebp)
  8017d3:	e8 bc f1 ff ff       	call   800994 <memmove>
	return r;
  8017d8:	83 c4 10             	add    $0x10,%esp
}
  8017db:	89 d8                	mov    %ebx,%eax
  8017dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    
	assert(r <= n);
  8017e4:	68 08 2b 80 00       	push   $0x802b08
  8017e9:	68 0f 2b 80 00       	push   $0x802b0f
  8017ee:	6a 7c                	push   $0x7c
  8017f0:	68 24 2b 80 00       	push   $0x802b24
  8017f5:	e8 4f e9 ff ff       	call   800149 <_panic>
	assert(r <= PGSIZE);
  8017fa:	68 2f 2b 80 00       	push   $0x802b2f
  8017ff:	68 0f 2b 80 00       	push   $0x802b0f
  801804:	6a 7d                	push   $0x7d
  801806:	68 24 2b 80 00       	push   $0x802b24
  80180b:	e8 39 e9 ff ff       	call   800149 <_panic>

00801810 <open>:
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	83 ec 1c             	sub    $0x1c,%esp
  801818:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80181b:	56                   	push   %esi
  80181c:	e8 a2 ef ff ff       	call   8007c3 <strlen>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801829:	7f 6c                	jg     801897 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80182b:	83 ec 0c             	sub    $0xc,%esp
  80182e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	e8 bd f8 ff ff       	call   8010f4 <fd_alloc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 3c                	js     80187c <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	56                   	push   %esi
  801844:	68 00 50 80 00       	push   $0x805000
  801849:	e8 b0 ef ff ff       	call   8007fe <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801851:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801856:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801859:	b8 01 00 00 00       	mov    $0x1,%eax
  80185e:	e8 f6 fd ff ff       	call   801659 <fsipc>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 19                	js     801885 <open+0x75>
	return fd2num(fd);
  80186c:	83 ec 0c             	sub    $0xc,%esp
  80186f:	ff 75 f4             	push   -0xc(%ebp)
  801872:	e8 56 f8 ff ff       	call   8010cd <fd2num>
  801877:	89 c3                	mov    %eax,%ebx
  801879:	83 c4 10             	add    $0x10,%esp
}
  80187c:	89 d8                	mov    %ebx,%eax
  80187e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801881:	5b                   	pop    %ebx
  801882:	5e                   	pop    %esi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    
		fd_close(fd, 0);
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	6a 00                	push   $0x0
  80188a:	ff 75 f4             	push   -0xc(%ebp)
  80188d:	e8 58 f9 ff ff       	call   8011ea <fd_close>
		return r;
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	eb e5                	jmp    80187c <open+0x6c>
		return -E_BAD_PATH;
  801897:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80189c:	eb de                	jmp    80187c <open+0x6c>

0080189e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8018ae:	e8 a6 fd ff ff       	call   801659 <fsipc>
}
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018bb:	68 3b 2b 80 00       	push   $0x802b3b
  8018c0:	ff 75 0c             	push   0xc(%ebp)
  8018c3:	e8 36 ef ff ff       	call   8007fe <strcpy>
	return 0;
}
  8018c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <devsock_close>:
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	53                   	push   %ebx
  8018d3:	83 ec 10             	sub    $0x10,%esp
  8018d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018d9:	53                   	push   %ebx
  8018da:	e8 9b 0a 00 00       	call   80237a <pageref>
  8018df:	89 c2                	mov    %eax,%edx
  8018e1:	83 c4 10             	add    $0x10,%esp
		return 0;
  8018e4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8018e9:	83 fa 01             	cmp    $0x1,%edx
  8018ec:	74 05                	je     8018f3 <devsock_close+0x24>
}
  8018ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8018f3:	83 ec 0c             	sub    $0xc,%esp
  8018f6:	ff 73 0c             	push   0xc(%ebx)
  8018f9:	e8 b7 02 00 00       	call   801bb5 <nsipc_close>
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	eb eb                	jmp    8018ee <devsock_close+0x1f>

00801903 <devsock_write>:
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801909:	6a 00                	push   $0x0
  80190b:	ff 75 10             	push   0x10(%ebp)
  80190e:	ff 75 0c             	push   0xc(%ebp)
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	ff 70 0c             	push   0xc(%eax)
  801917:	e8 79 03 00 00       	call   801c95 <nsipc_send>
}
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <devsock_read>:
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801924:	6a 00                	push   $0x0
  801926:	ff 75 10             	push   0x10(%ebp)
  801929:	ff 75 0c             	push   0xc(%ebp)
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	ff 70 0c             	push   0xc(%eax)
  801932:	e8 ef 02 00 00       	call   801c26 <nsipc_recv>
}
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <fd2sockid>:
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80193f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801942:	52                   	push   %edx
  801943:	50                   	push   %eax
  801944:	e8 fb f7 ff ff       	call   801144 <fd_lookup>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 10                	js     801960 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801953:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801959:	39 08                	cmp    %ecx,(%eax)
  80195b:	75 05                	jne    801962 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80195d:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    
		return -E_NOT_SUPP;
  801962:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801967:	eb f7                	jmp    801960 <fd2sockid+0x27>

00801969 <alloc_sockfd>:
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	83 ec 1c             	sub    $0x1c,%esp
  801971:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801973:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	e8 78 f7 ff ff       	call   8010f4 <fd_alloc>
  80197c:	89 c3                	mov    %eax,%ebx
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	85 c0                	test   %eax,%eax
  801983:	78 43                	js     8019c8 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801985:	83 ec 04             	sub    $0x4,%esp
  801988:	68 07 04 00 00       	push   $0x407
  80198d:	ff 75 f4             	push   -0xc(%ebp)
  801990:	6a 00                	push   $0x0
  801992:	e8 63 f2 ff ff       	call   800bfa <sys_page_alloc>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 28                	js     8019c8 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019a9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019b5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019b8:	83 ec 0c             	sub    $0xc,%esp
  8019bb:	50                   	push   %eax
  8019bc:	e8 0c f7 ff ff       	call   8010cd <fd2num>
  8019c1:	89 c3                	mov    %eax,%ebx
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	eb 0c                	jmp    8019d4 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	56                   	push   %esi
  8019cc:	e8 e4 01 00 00       	call   801bb5 <nsipc_close>
		return r;
  8019d1:	83 c4 10             	add    $0x10,%esp
}
  8019d4:	89 d8                	mov    %ebx,%eax
  8019d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5e                   	pop    %esi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <accept>:
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	e8 4e ff ff ff       	call   801939 <fd2sockid>
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 1b                	js     801a0a <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019ef:	83 ec 04             	sub    $0x4,%esp
  8019f2:	ff 75 10             	push   0x10(%ebp)
  8019f5:	ff 75 0c             	push   0xc(%ebp)
  8019f8:	50                   	push   %eax
  8019f9:	e8 0e 01 00 00       	call   801b0c <nsipc_accept>
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	85 c0                	test   %eax,%eax
  801a03:	78 05                	js     801a0a <accept+0x2d>
	return alloc_sockfd(r);
  801a05:	e8 5f ff ff ff       	call   801969 <alloc_sockfd>
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <bind>:
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	e8 1f ff ff ff       	call   801939 <fd2sockid>
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 12                	js     801a30 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801a1e:	83 ec 04             	sub    $0x4,%esp
  801a21:	ff 75 10             	push   0x10(%ebp)
  801a24:	ff 75 0c             	push   0xc(%ebp)
  801a27:	50                   	push   %eax
  801a28:	e8 31 01 00 00       	call   801b5e <nsipc_bind>
  801a2d:	83 c4 10             	add    $0x10,%esp
}
  801a30:	c9                   	leave  
  801a31:	c3                   	ret    

00801a32 <shutdown>:
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a38:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3b:	e8 f9 fe ff ff       	call   801939 <fd2sockid>
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 0f                	js     801a53 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	ff 75 0c             	push   0xc(%ebp)
  801a4a:	50                   	push   %eax
  801a4b:	e8 43 01 00 00       	call   801b93 <nsipc_shutdown>
  801a50:	83 c4 10             	add    $0x10,%esp
}
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <connect>:
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	e8 d6 fe ff ff       	call   801939 <fd2sockid>
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 12                	js     801a79 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801a67:	83 ec 04             	sub    $0x4,%esp
  801a6a:	ff 75 10             	push   0x10(%ebp)
  801a6d:	ff 75 0c             	push   0xc(%ebp)
  801a70:	50                   	push   %eax
  801a71:	e8 59 01 00 00       	call   801bcf <nsipc_connect>
  801a76:	83 c4 10             	add    $0x10,%esp
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <listen>:
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	e8 b0 fe ff ff       	call   801939 <fd2sockid>
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 0f                	js     801a9c <listen+0x21>
	return nsipc_listen(r, backlog);
  801a8d:	83 ec 08             	sub    $0x8,%esp
  801a90:	ff 75 0c             	push   0xc(%ebp)
  801a93:	50                   	push   %eax
  801a94:	e8 6b 01 00 00       	call   801c04 <nsipc_listen>
  801a99:	83 c4 10             	add    $0x10,%esp
}
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <socket>:

int
socket(int domain, int type, int protocol)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801aa4:	ff 75 10             	push   0x10(%ebp)
  801aa7:	ff 75 0c             	push   0xc(%ebp)
  801aaa:	ff 75 08             	push   0x8(%ebp)
  801aad:	e8 41 02 00 00       	call   801cf3 <nsipc_socket>
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 05                	js     801abe <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ab9:	e8 ab fe ff ff       	call   801969 <alloc_sockfd>
}
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 04             	sub    $0x4,%esp
  801ac7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ac9:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801ad0:	74 26                	je     801af8 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ad2:	6a 07                	push   $0x7
  801ad4:	68 00 70 80 00       	push   $0x807000
  801ad9:	53                   	push   %ebx
  801ada:	ff 35 00 80 80 00    	push   0x808000
  801ae0:	e8 02 08 00 00       	call   8022e7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ae5:	83 c4 0c             	add    $0xc,%esp
  801ae8:	6a 00                	push   $0x0
  801aea:	6a 00                	push   $0x0
  801aec:	6a 00                	push   $0x0
  801aee:	e8 84 07 00 00       	call   802277 <ipc_recv>
}
  801af3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	6a 02                	push   $0x2
  801afd:	e8 39 08 00 00       	call   80233b <ipc_find_env>
  801b02:	a3 00 80 80 00       	mov    %eax,0x808000
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	eb c6                	jmp    801ad2 <nsipc+0x12>

00801b0c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b1c:	8b 06                	mov    (%esi),%eax
  801b1e:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b23:	b8 01 00 00 00       	mov    $0x1,%eax
  801b28:	e8 93 ff ff ff       	call   801ac0 <nsipc>
  801b2d:	89 c3                	mov    %eax,%ebx
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	79 09                	jns    801b3c <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801b33:	89 d8                	mov    %ebx,%eax
  801b35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5e                   	pop    %esi
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b3c:	83 ec 04             	sub    $0x4,%esp
  801b3f:	ff 35 10 70 80 00    	push   0x807010
  801b45:	68 00 70 80 00       	push   $0x807000
  801b4a:	ff 75 0c             	push   0xc(%ebp)
  801b4d:	e8 42 ee ff ff       	call   800994 <memmove>
		*addrlen = ret->ret_addrlen;
  801b52:	a1 10 70 80 00       	mov    0x807010,%eax
  801b57:	89 06                	mov    %eax,(%esi)
  801b59:	83 c4 10             	add    $0x10,%esp
	return r;
  801b5c:	eb d5                	jmp    801b33 <nsipc_accept+0x27>

00801b5e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	53                   	push   %ebx
  801b62:	83 ec 08             	sub    $0x8,%esp
  801b65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b68:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6b:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b70:	53                   	push   %ebx
  801b71:	ff 75 0c             	push   0xc(%ebp)
  801b74:	68 04 70 80 00       	push   $0x807004
  801b79:	e8 16 ee ff ff       	call   800994 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b7e:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801b84:	b8 02 00 00 00       	mov    $0x2,%eax
  801b89:	e8 32 ff ff ff       	call   801ac0 <nsipc>
}
  801b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b99:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba4:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ba9:	b8 03 00 00 00       	mov    $0x3,%eax
  801bae:	e8 0d ff ff ff       	call   801ac0 <nsipc>
}
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <nsipc_close>:

int
nsipc_close(int s)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801bc3:	b8 04 00 00 00       	mov    $0x4,%eax
  801bc8:	e8 f3 fe ff ff       	call   801ac0 <nsipc>
}
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    

00801bcf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	53                   	push   %ebx
  801bd3:	83 ec 08             	sub    $0x8,%esp
  801bd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdc:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801be1:	53                   	push   %ebx
  801be2:	ff 75 0c             	push   0xc(%ebp)
  801be5:	68 04 70 80 00       	push   $0x807004
  801bea:	e8 a5 ed ff ff       	call   800994 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bef:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801bf5:	b8 05 00 00 00       	mov    $0x5,%eax
  801bfa:	e8 c1 fe ff ff       	call   801ac0 <nsipc>
}
  801bff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c02:	c9                   	leave  
  801c03:	c3                   	ret    

00801c04 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c15:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801c1a:	b8 06 00 00 00       	mov    $0x6,%eax
  801c1f:	e8 9c fe ff ff       	call   801ac0 <nsipc>
}
  801c24:	c9                   	leave  
  801c25:	c3                   	ret    

00801c26 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	56                   	push   %esi
  801c2a:	53                   	push   %ebx
  801c2b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c31:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801c36:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801c3c:	8b 45 14             	mov    0x14(%ebp),%eax
  801c3f:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c44:	b8 07 00 00 00       	mov    $0x7,%eax
  801c49:	e8 72 fe ff ff       	call   801ac0 <nsipc>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 22                	js     801c76 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801c54:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801c59:	39 c6                	cmp    %eax,%esi
  801c5b:	0f 4e c6             	cmovle %esi,%eax
  801c5e:	39 c3                	cmp    %eax,%ebx
  801c60:	7f 1d                	jg     801c7f <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c62:	83 ec 04             	sub    $0x4,%esp
  801c65:	53                   	push   %ebx
  801c66:	68 00 70 80 00       	push   $0x807000
  801c6b:	ff 75 0c             	push   0xc(%ebp)
  801c6e:	e8 21 ed ff ff       	call   800994 <memmove>
  801c73:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c76:	89 d8                	mov    %ebx,%eax
  801c78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7b:	5b                   	pop    %ebx
  801c7c:	5e                   	pop    %esi
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801c7f:	68 47 2b 80 00       	push   $0x802b47
  801c84:	68 0f 2b 80 00       	push   $0x802b0f
  801c89:	6a 62                	push   $0x62
  801c8b:	68 5c 2b 80 00       	push   $0x802b5c
  801c90:	e8 b4 e4 ff ff       	call   800149 <_panic>

00801c95 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	53                   	push   %ebx
  801c99:	83 ec 04             	sub    $0x4,%esp
  801c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801ca7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cad:	7f 2e                	jg     801cdd <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801caf:	83 ec 04             	sub    $0x4,%esp
  801cb2:	53                   	push   %ebx
  801cb3:	ff 75 0c             	push   0xc(%ebp)
  801cb6:	68 0c 70 80 00       	push   $0x80700c
  801cbb:	e8 d4 ec ff ff       	call   800994 <memmove>
	nsipcbuf.send.req_size = size;
  801cc0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801cc6:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801cce:	b8 08 00 00 00       	mov    $0x8,%eax
  801cd3:	e8 e8 fd ff ff       	call   801ac0 <nsipc>
}
  801cd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    
	assert(size < 1600);
  801cdd:	68 68 2b 80 00       	push   $0x802b68
  801ce2:	68 0f 2b 80 00       	push   $0x802b0f
  801ce7:	6a 6d                	push   $0x6d
  801ce9:	68 5c 2b 80 00       	push   $0x802b5c
  801cee:	e8 56 e4 ff ff       	call   800149 <_panic>

00801cf3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801d01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d04:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801d09:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801d11:	b8 09 00 00 00       	mov    $0x9,%eax
  801d16:	e8 a5 fd ff ff       	call   801ac0 <nsipc>
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	56                   	push   %esi
  801d21:	53                   	push   %ebx
  801d22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d25:	83 ec 0c             	sub    $0xc,%esp
  801d28:	ff 75 08             	push   0x8(%ebp)
  801d2b:	e8 ad f3 ff ff       	call   8010dd <fd2data>
  801d30:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d32:	83 c4 08             	add    $0x8,%esp
  801d35:	68 74 2b 80 00       	push   $0x802b74
  801d3a:	53                   	push   %ebx
  801d3b:	e8 be ea ff ff       	call   8007fe <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d40:	8b 46 04             	mov    0x4(%esi),%eax
  801d43:	2b 06                	sub    (%esi),%eax
  801d45:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d4b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d52:	00 00 00 
	stat->st_dev = &devpipe;
  801d55:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d5c:	30 80 00 
	return 0;
}
  801d5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	53                   	push   %ebx
  801d6f:	83 ec 0c             	sub    $0xc,%esp
  801d72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d75:	53                   	push   %ebx
  801d76:	6a 00                	push   $0x0
  801d78:	e8 02 ef ff ff       	call   800c7f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d7d:	89 1c 24             	mov    %ebx,(%esp)
  801d80:	e8 58 f3 ff ff       	call   8010dd <fd2data>
  801d85:	83 c4 08             	add    $0x8,%esp
  801d88:	50                   	push   %eax
  801d89:	6a 00                	push   $0x0
  801d8b:	e8 ef ee ff ff       	call   800c7f <sys_page_unmap>
}
  801d90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <_pipeisclosed>:
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	57                   	push   %edi
  801d99:	56                   	push   %esi
  801d9a:	53                   	push   %ebx
  801d9b:	83 ec 1c             	sub    $0x1c,%esp
  801d9e:	89 c7                	mov    %eax,%edi
  801da0:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801da2:	a1 04 40 80 00       	mov    0x804004,%eax
  801da7:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	57                   	push   %edi
  801dae:	e8 c7 05 00 00       	call   80237a <pageref>
  801db3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801db6:	89 34 24             	mov    %esi,(%esp)
  801db9:	e8 bc 05 00 00       	call   80237a <pageref>
		nn = thisenv->env_runs;
  801dbe:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dc4:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	39 cb                	cmp    %ecx,%ebx
  801dcc:	74 1b                	je     801de9 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801dce:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dd1:	75 cf                	jne    801da2 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dd3:	8b 42 68             	mov    0x68(%edx),%eax
  801dd6:	6a 01                	push   $0x1
  801dd8:	50                   	push   %eax
  801dd9:	53                   	push   %ebx
  801dda:	68 7b 2b 80 00       	push   $0x802b7b
  801ddf:	e8 40 e4 ff ff       	call   800224 <cprintf>
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	eb b9                	jmp    801da2 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801de9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dec:	0f 94 c0             	sete   %al
  801def:	0f b6 c0             	movzbl %al,%eax
}
  801df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5f                   	pop    %edi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    

00801dfa <devpipe_write>:
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	57                   	push   %edi
  801dfe:	56                   	push   %esi
  801dff:	53                   	push   %ebx
  801e00:	83 ec 28             	sub    $0x28,%esp
  801e03:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e06:	56                   	push   %esi
  801e07:	e8 d1 f2 ff ff       	call   8010dd <fd2data>
  801e0c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	bf 00 00 00 00       	mov    $0x0,%edi
  801e16:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e19:	75 09                	jne    801e24 <devpipe_write+0x2a>
	return i;
  801e1b:	89 f8                	mov    %edi,%eax
  801e1d:	eb 23                	jmp    801e42 <devpipe_write+0x48>
			sys_yield();
  801e1f:	e8 b7 ed ff ff       	call   800bdb <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e24:	8b 43 04             	mov    0x4(%ebx),%eax
  801e27:	8b 0b                	mov    (%ebx),%ecx
  801e29:	8d 51 20             	lea    0x20(%ecx),%edx
  801e2c:	39 d0                	cmp    %edx,%eax
  801e2e:	72 1a                	jb     801e4a <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801e30:	89 da                	mov    %ebx,%edx
  801e32:	89 f0                	mov    %esi,%eax
  801e34:	e8 5c ff ff ff       	call   801d95 <_pipeisclosed>
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	74 e2                	je     801e1f <devpipe_write+0x25>
				return 0;
  801e3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e45:	5b                   	pop    %ebx
  801e46:	5e                   	pop    %esi
  801e47:	5f                   	pop    %edi
  801e48:	5d                   	pop    %ebp
  801e49:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e4d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e51:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e54:	89 c2                	mov    %eax,%edx
  801e56:	c1 fa 1f             	sar    $0x1f,%edx
  801e59:	89 d1                	mov    %edx,%ecx
  801e5b:	c1 e9 1b             	shr    $0x1b,%ecx
  801e5e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e61:	83 e2 1f             	and    $0x1f,%edx
  801e64:	29 ca                	sub    %ecx,%edx
  801e66:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e6a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e6e:	83 c0 01             	add    $0x1,%eax
  801e71:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e74:	83 c7 01             	add    $0x1,%edi
  801e77:	eb 9d                	jmp    801e16 <devpipe_write+0x1c>

00801e79 <devpipe_read>:
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	57                   	push   %edi
  801e7d:	56                   	push   %esi
  801e7e:	53                   	push   %ebx
  801e7f:	83 ec 18             	sub    $0x18,%esp
  801e82:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e85:	57                   	push   %edi
  801e86:	e8 52 f2 ff ff       	call   8010dd <fd2data>
  801e8b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	be 00 00 00 00       	mov    $0x0,%esi
  801e95:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e98:	75 13                	jne    801ead <devpipe_read+0x34>
	return i;
  801e9a:	89 f0                	mov    %esi,%eax
  801e9c:	eb 02                	jmp    801ea0 <devpipe_read+0x27>
				return i;
  801e9e:	89 f0                	mov    %esi,%eax
}
  801ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5f                   	pop    %edi
  801ea6:	5d                   	pop    %ebp
  801ea7:	c3                   	ret    
			sys_yield();
  801ea8:	e8 2e ed ff ff       	call   800bdb <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ead:	8b 03                	mov    (%ebx),%eax
  801eaf:	3b 43 04             	cmp    0x4(%ebx),%eax
  801eb2:	75 18                	jne    801ecc <devpipe_read+0x53>
			if (i > 0)
  801eb4:	85 f6                	test   %esi,%esi
  801eb6:	75 e6                	jne    801e9e <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801eb8:	89 da                	mov    %ebx,%edx
  801eba:	89 f8                	mov    %edi,%eax
  801ebc:	e8 d4 fe ff ff       	call   801d95 <_pipeisclosed>
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	74 e3                	je     801ea8 <devpipe_read+0x2f>
				return 0;
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eca:	eb d4                	jmp    801ea0 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ecc:	99                   	cltd   
  801ecd:	c1 ea 1b             	shr    $0x1b,%edx
  801ed0:	01 d0                	add    %edx,%eax
  801ed2:	83 e0 1f             	and    $0x1f,%eax
  801ed5:	29 d0                	sub    %edx,%eax
  801ed7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801edf:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ee2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ee5:	83 c6 01             	add    $0x1,%esi
  801ee8:	eb ab                	jmp    801e95 <devpipe_read+0x1c>

00801eea <pipe>:
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ef2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef5:	50                   	push   %eax
  801ef6:	e8 f9 f1 ff ff       	call   8010f4 <fd_alloc>
  801efb:	89 c3                	mov    %eax,%ebx
  801efd:	83 c4 10             	add    $0x10,%esp
  801f00:	85 c0                	test   %eax,%eax
  801f02:	0f 88 23 01 00 00    	js     80202b <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f08:	83 ec 04             	sub    $0x4,%esp
  801f0b:	68 07 04 00 00       	push   $0x407
  801f10:	ff 75 f4             	push   -0xc(%ebp)
  801f13:	6a 00                	push   $0x0
  801f15:	e8 e0 ec ff ff       	call   800bfa <sys_page_alloc>
  801f1a:	89 c3                	mov    %eax,%ebx
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	0f 88 04 01 00 00    	js     80202b <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f2d:	50                   	push   %eax
  801f2e:	e8 c1 f1 ff ff       	call   8010f4 <fd_alloc>
  801f33:	89 c3                	mov    %eax,%ebx
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	0f 88 db 00 00 00    	js     80201b <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f40:	83 ec 04             	sub    $0x4,%esp
  801f43:	68 07 04 00 00       	push   $0x407
  801f48:	ff 75 f0             	push   -0x10(%ebp)
  801f4b:	6a 00                	push   $0x0
  801f4d:	e8 a8 ec ff ff       	call   800bfa <sys_page_alloc>
  801f52:	89 c3                	mov    %eax,%ebx
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 c0                	test   %eax,%eax
  801f59:	0f 88 bc 00 00 00    	js     80201b <pipe+0x131>
	va = fd2data(fd0);
  801f5f:	83 ec 0c             	sub    $0xc,%esp
  801f62:	ff 75 f4             	push   -0xc(%ebp)
  801f65:	e8 73 f1 ff ff       	call   8010dd <fd2data>
  801f6a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f6c:	83 c4 0c             	add    $0xc,%esp
  801f6f:	68 07 04 00 00       	push   $0x407
  801f74:	50                   	push   %eax
  801f75:	6a 00                	push   $0x0
  801f77:	e8 7e ec ff ff       	call   800bfa <sys_page_alloc>
  801f7c:	89 c3                	mov    %eax,%ebx
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	85 c0                	test   %eax,%eax
  801f83:	0f 88 82 00 00 00    	js     80200b <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f89:	83 ec 0c             	sub    $0xc,%esp
  801f8c:	ff 75 f0             	push   -0x10(%ebp)
  801f8f:	e8 49 f1 ff ff       	call   8010dd <fd2data>
  801f94:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f9b:	50                   	push   %eax
  801f9c:	6a 00                	push   $0x0
  801f9e:	56                   	push   %esi
  801f9f:	6a 00                	push   $0x0
  801fa1:	e8 97 ec ff ff       	call   800c3d <sys_page_map>
  801fa6:	89 c3                	mov    %eax,%ebx
  801fa8:	83 c4 20             	add    $0x20,%esp
  801fab:	85 c0                	test   %eax,%eax
  801fad:	78 4e                	js     801ffd <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801faf:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801fb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fb7:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801fb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fbc:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801fc3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fc6:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fcb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801fd2:	83 ec 0c             	sub    $0xc,%esp
  801fd5:	ff 75 f4             	push   -0xc(%ebp)
  801fd8:	e8 f0 f0 ff ff       	call   8010cd <fd2num>
  801fdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fe0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fe2:	83 c4 04             	add    $0x4,%esp
  801fe5:	ff 75 f0             	push   -0x10(%ebp)
  801fe8:	e8 e0 f0 ff ff       	call   8010cd <fd2num>
  801fed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ff0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ff3:	83 c4 10             	add    $0x10,%esp
  801ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ffb:	eb 2e                	jmp    80202b <pipe+0x141>
	sys_page_unmap(0, va);
  801ffd:	83 ec 08             	sub    $0x8,%esp
  802000:	56                   	push   %esi
  802001:	6a 00                	push   $0x0
  802003:	e8 77 ec ff ff       	call   800c7f <sys_page_unmap>
  802008:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80200b:	83 ec 08             	sub    $0x8,%esp
  80200e:	ff 75 f0             	push   -0x10(%ebp)
  802011:	6a 00                	push   $0x0
  802013:	e8 67 ec ff ff       	call   800c7f <sys_page_unmap>
  802018:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80201b:	83 ec 08             	sub    $0x8,%esp
  80201e:	ff 75 f4             	push   -0xc(%ebp)
  802021:	6a 00                	push   $0x0
  802023:	e8 57 ec ff ff       	call   800c7f <sys_page_unmap>
  802028:	83 c4 10             	add    $0x10,%esp
}
  80202b:	89 d8                	mov    %ebx,%eax
  80202d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <pipeisclosed>:
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80203a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203d:	50                   	push   %eax
  80203e:	ff 75 08             	push   0x8(%ebp)
  802041:	e8 fe f0 ff ff       	call   801144 <fd_lookup>
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	85 c0                	test   %eax,%eax
  80204b:	78 18                	js     802065 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80204d:	83 ec 0c             	sub    $0xc,%esp
  802050:	ff 75 f4             	push   -0xc(%ebp)
  802053:	e8 85 f0 ff ff       	call   8010dd <fd2data>
  802058:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	e8 33 fd ff ff       	call   801d95 <_pipeisclosed>
  802062:	83 c4 10             	add    $0x10,%esp
}
  802065:	c9                   	leave  
  802066:	c3                   	ret    

00802067 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802067:	b8 00 00 00 00       	mov    $0x0,%eax
  80206c:	c3                   	ret    

0080206d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802073:	68 93 2b 80 00       	push   $0x802b93
  802078:	ff 75 0c             	push   0xc(%ebp)
  80207b:	e8 7e e7 ff ff       	call   8007fe <strcpy>
	return 0;
}
  802080:	b8 00 00 00 00       	mov    $0x0,%eax
  802085:	c9                   	leave  
  802086:	c3                   	ret    

00802087 <devcons_write>:
{
  802087:	55                   	push   %ebp
  802088:	89 e5                	mov    %esp,%ebp
  80208a:	57                   	push   %edi
  80208b:	56                   	push   %esi
  80208c:	53                   	push   %ebx
  80208d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802093:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802098:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80209e:	eb 2e                	jmp    8020ce <devcons_write+0x47>
		m = n - tot;
  8020a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020a3:	29 f3                	sub    %esi,%ebx
  8020a5:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8020aa:	39 c3                	cmp    %eax,%ebx
  8020ac:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8020af:	83 ec 04             	sub    $0x4,%esp
  8020b2:	53                   	push   %ebx
  8020b3:	89 f0                	mov    %esi,%eax
  8020b5:	03 45 0c             	add    0xc(%ebp),%eax
  8020b8:	50                   	push   %eax
  8020b9:	57                   	push   %edi
  8020ba:	e8 d5 e8 ff ff       	call   800994 <memmove>
		sys_cputs(buf, m);
  8020bf:	83 c4 08             	add    $0x8,%esp
  8020c2:	53                   	push   %ebx
  8020c3:	57                   	push   %edi
  8020c4:	e8 75 ea ff ff       	call   800b3e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8020c9:	01 de                	add    %ebx,%esi
  8020cb:	83 c4 10             	add    $0x10,%esp
  8020ce:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020d1:	72 cd                	jb     8020a0 <devcons_write+0x19>
}
  8020d3:	89 f0                	mov    %esi,%eax
  8020d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d8:	5b                   	pop    %ebx
  8020d9:	5e                   	pop    %esi
  8020da:	5f                   	pop    %edi
  8020db:	5d                   	pop    %ebp
  8020dc:	c3                   	ret    

008020dd <devcons_read>:
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	83 ec 08             	sub    $0x8,%esp
  8020e3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8020e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020ec:	75 07                	jne    8020f5 <devcons_read+0x18>
  8020ee:	eb 1f                	jmp    80210f <devcons_read+0x32>
		sys_yield();
  8020f0:	e8 e6 ea ff ff       	call   800bdb <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8020f5:	e8 62 ea ff ff       	call   800b5c <sys_cgetc>
  8020fa:	85 c0                	test   %eax,%eax
  8020fc:	74 f2                	je     8020f0 <devcons_read+0x13>
	if (c < 0)
  8020fe:	78 0f                	js     80210f <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802100:	83 f8 04             	cmp    $0x4,%eax
  802103:	74 0c                	je     802111 <devcons_read+0x34>
	*(char*)vbuf = c;
  802105:	8b 55 0c             	mov    0xc(%ebp),%edx
  802108:	88 02                	mov    %al,(%edx)
	return 1;
  80210a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80210f:	c9                   	leave  
  802110:	c3                   	ret    
		return 0;
  802111:	b8 00 00 00 00       	mov    $0x0,%eax
  802116:	eb f7                	jmp    80210f <devcons_read+0x32>

00802118 <cputchar>:
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80211e:	8b 45 08             	mov    0x8(%ebp),%eax
  802121:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802124:	6a 01                	push   $0x1
  802126:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802129:	50                   	push   %eax
  80212a:	e8 0f ea ff ff       	call   800b3e <sys_cputs>
}
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	c9                   	leave  
  802133:	c3                   	ret    

00802134 <getchar>:
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80213a:	6a 01                	push   $0x1
  80213c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80213f:	50                   	push   %eax
  802140:	6a 00                	push   $0x0
  802142:	e8 66 f2 ff ff       	call   8013ad <read>
	if (r < 0)
  802147:	83 c4 10             	add    $0x10,%esp
  80214a:	85 c0                	test   %eax,%eax
  80214c:	78 06                	js     802154 <getchar+0x20>
	if (r < 1)
  80214e:	74 06                	je     802156 <getchar+0x22>
	return c;
  802150:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802154:	c9                   	leave  
  802155:	c3                   	ret    
		return -E_EOF;
  802156:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80215b:	eb f7                	jmp    802154 <getchar+0x20>

0080215d <iscons>:
{
  80215d:	55                   	push   %ebp
  80215e:	89 e5                	mov    %esp,%ebp
  802160:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802163:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802166:	50                   	push   %eax
  802167:	ff 75 08             	push   0x8(%ebp)
  80216a:	e8 d5 ef ff ff       	call   801144 <fd_lookup>
  80216f:	83 c4 10             	add    $0x10,%esp
  802172:	85 c0                	test   %eax,%eax
  802174:	78 11                	js     802187 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802176:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802179:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80217f:	39 10                	cmp    %edx,(%eax)
  802181:	0f 94 c0             	sete   %al
  802184:	0f b6 c0             	movzbl %al,%eax
}
  802187:	c9                   	leave  
  802188:	c3                   	ret    

00802189 <opencons>:
{
  802189:	55                   	push   %ebp
  80218a:	89 e5                	mov    %esp,%ebp
  80218c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80218f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802192:	50                   	push   %eax
  802193:	e8 5c ef ff ff       	call   8010f4 <fd_alloc>
  802198:	83 c4 10             	add    $0x10,%esp
  80219b:	85 c0                	test   %eax,%eax
  80219d:	78 3a                	js     8021d9 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80219f:	83 ec 04             	sub    $0x4,%esp
  8021a2:	68 07 04 00 00       	push   $0x407
  8021a7:	ff 75 f4             	push   -0xc(%ebp)
  8021aa:	6a 00                	push   $0x0
  8021ac:	e8 49 ea ff ff       	call   800bfa <sys_page_alloc>
  8021b1:	83 c4 10             	add    $0x10,%esp
  8021b4:	85 c0                	test   %eax,%eax
  8021b6:	78 21                	js     8021d9 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8021b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021c1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021cd:	83 ec 0c             	sub    $0xc,%esp
  8021d0:	50                   	push   %eax
  8021d1:	e8 f7 ee ff ff       	call   8010cd <fd2num>
  8021d6:	83 c4 10             	add    $0x10,%esp
}
  8021d9:	c9                   	leave  
  8021da:	c3                   	ret    

008021db <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8021e1:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8021e8:	74 0a                	je     8021f4 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ed:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8021f2:	c9                   	leave  
  8021f3:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8021f4:	e8 c3 e9 ff ff       	call   800bbc <sys_getenvid>
  8021f9:	83 ec 04             	sub    $0x4,%esp
  8021fc:	68 07 0e 00 00       	push   $0xe07
  802201:	68 00 f0 bf ee       	push   $0xeebff000
  802206:	50                   	push   %eax
  802207:	e8 ee e9 ff ff       	call   800bfa <sys_page_alloc>
		if (r < 0) {
  80220c:	83 c4 10             	add    $0x10,%esp
  80220f:	85 c0                	test   %eax,%eax
  802211:	78 2c                	js     80223f <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802213:	e8 a4 e9 ff ff       	call   800bbc <sys_getenvid>
  802218:	83 ec 08             	sub    $0x8,%esp
  80221b:	68 51 22 80 00       	push   $0x802251
  802220:	50                   	push   %eax
  802221:	e8 1f eb ff ff       	call   800d45 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802226:	83 c4 10             	add    $0x10,%esp
  802229:	85 c0                	test   %eax,%eax
  80222b:	79 bd                	jns    8021ea <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80222d:	50                   	push   %eax
  80222e:	68 e0 2b 80 00       	push   $0x802be0
  802233:	6a 28                	push   $0x28
  802235:	68 16 2c 80 00       	push   $0x802c16
  80223a:	e8 0a df ff ff       	call   800149 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80223f:	50                   	push   %eax
  802240:	68 a0 2b 80 00       	push   $0x802ba0
  802245:	6a 23                	push   $0x23
  802247:	68 16 2c 80 00       	push   $0x802c16
  80224c:	e8 f8 de ff ff       	call   800149 <_panic>

00802251 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802251:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802252:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802257:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802259:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80225c:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802260:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802263:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802267:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80226b:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80226d:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802270:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802271:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802274:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802275:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802276:	c3                   	ret    

00802277 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	56                   	push   %esi
  80227b:	53                   	push   %ebx
  80227c:	8b 75 08             	mov    0x8(%ebp),%esi
  80227f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802282:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802285:	85 c0                	test   %eax,%eax
  802287:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80228c:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80228f:	83 ec 0c             	sub    $0xc,%esp
  802292:	50                   	push   %eax
  802293:	e8 12 eb ff ff       	call   800daa <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	85 f6                	test   %esi,%esi
  80229d:	74 17                	je     8022b6 <ipc_recv+0x3f>
  80229f:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a4:	85 c0                	test   %eax,%eax
  8022a6:	78 0c                	js     8022b4 <ipc_recv+0x3d>
  8022a8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8022ae:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8022b4:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8022b6:	85 db                	test   %ebx,%ebx
  8022b8:	74 17                	je     8022d1 <ipc_recv+0x5a>
  8022ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8022bf:	85 c0                	test   %eax,%eax
  8022c1:	78 0c                	js     8022cf <ipc_recv+0x58>
  8022c3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8022c9:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8022cf:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8022d1:	85 c0                	test   %eax,%eax
  8022d3:	78 0b                	js     8022e0 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8022d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8022da:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8022e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5d                   	pop    %ebp
  8022e6:	c3                   	ret    

008022e7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022e7:	55                   	push   %ebp
  8022e8:	89 e5                	mov    %esp,%ebp
  8022ea:	57                   	push   %edi
  8022eb:	56                   	push   %esi
  8022ec:	53                   	push   %ebx
  8022ed:	83 ec 0c             	sub    $0xc,%esp
  8022f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8022f9:	85 db                	test   %ebx,%ebx
  8022fb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802300:	0f 44 d8             	cmove  %eax,%ebx
  802303:	eb 05                	jmp    80230a <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802305:	e8 d1 e8 ff ff       	call   800bdb <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80230a:	ff 75 14             	push   0x14(%ebp)
  80230d:	53                   	push   %ebx
  80230e:	56                   	push   %esi
  80230f:	57                   	push   %edi
  802310:	e8 72 ea ff ff       	call   800d87 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802315:	83 c4 10             	add    $0x10,%esp
  802318:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80231b:	74 e8                	je     802305 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80231d:	85 c0                	test   %eax,%eax
  80231f:	78 08                	js     802329 <ipc_send+0x42>
	}while (r<0);

}
  802321:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802329:	50                   	push   %eax
  80232a:	68 24 2c 80 00       	push   $0x802c24
  80232f:	6a 3d                	push   $0x3d
  802331:	68 38 2c 80 00       	push   $0x802c38
  802336:	e8 0e de ff ff       	call   800149 <_panic>

0080233b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
  80233e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802341:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802346:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80234c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802352:	8b 52 60             	mov    0x60(%edx),%edx
  802355:	39 ca                	cmp    %ecx,%edx
  802357:	74 11                	je     80236a <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802359:	83 c0 01             	add    $0x1,%eax
  80235c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802361:	75 e3                	jne    802346 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802363:	b8 00 00 00 00       	mov    $0x0,%eax
  802368:	eb 0e                	jmp    802378 <ipc_find_env+0x3d>
			return envs[i].env_id;
  80236a:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802370:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802375:	8b 40 58             	mov    0x58(%eax),%eax
}
  802378:	5d                   	pop    %ebp
  802379:	c3                   	ret    

0080237a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80237a:	55                   	push   %ebp
  80237b:	89 e5                	mov    %esp,%ebp
  80237d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802380:	89 c2                	mov    %eax,%edx
  802382:	c1 ea 16             	shr    $0x16,%edx
  802385:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80238c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802391:	f6 c1 01             	test   $0x1,%cl
  802394:	74 1c                	je     8023b2 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802396:	c1 e8 0c             	shr    $0xc,%eax
  802399:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023a0:	a8 01                	test   $0x1,%al
  8023a2:	74 0e                	je     8023b2 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023a4:	c1 e8 0c             	shr    $0xc,%eax
  8023a7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8023ae:	ef 
  8023af:	0f b7 d2             	movzwl %dx,%edx
}
  8023b2:	89 d0                	mov    %edx,%eax
  8023b4:	5d                   	pop    %ebp
  8023b5:	c3                   	ret    
  8023b6:	66 90                	xchg   %ax,%ax
  8023b8:	66 90                	xchg   %ax,%ax
  8023ba:	66 90                	xchg   %ax,%ax
  8023bc:	66 90                	xchg   %ax,%ax
  8023be:	66 90                	xchg   %ax,%ax

008023c0 <__udivdi3>:
  8023c0:	f3 0f 1e fb          	endbr32 
  8023c4:	55                   	push   %ebp
  8023c5:	57                   	push   %edi
  8023c6:	56                   	push   %esi
  8023c7:	53                   	push   %ebx
  8023c8:	83 ec 1c             	sub    $0x1c,%esp
  8023cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023db:	85 c0                	test   %eax,%eax
  8023dd:	75 19                	jne    8023f8 <__udivdi3+0x38>
  8023df:	39 f3                	cmp    %esi,%ebx
  8023e1:	76 4d                	jbe    802430 <__udivdi3+0x70>
  8023e3:	31 ff                	xor    %edi,%edi
  8023e5:	89 e8                	mov    %ebp,%eax
  8023e7:	89 f2                	mov    %esi,%edx
  8023e9:	f7 f3                	div    %ebx
  8023eb:	89 fa                	mov    %edi,%edx
  8023ed:	83 c4 1c             	add    $0x1c,%esp
  8023f0:	5b                   	pop    %ebx
  8023f1:	5e                   	pop    %esi
  8023f2:	5f                   	pop    %edi
  8023f3:	5d                   	pop    %ebp
  8023f4:	c3                   	ret    
  8023f5:	8d 76 00             	lea    0x0(%esi),%esi
  8023f8:	39 f0                	cmp    %esi,%eax
  8023fa:	76 14                	jbe    802410 <__udivdi3+0x50>
  8023fc:	31 ff                	xor    %edi,%edi
  8023fe:	31 c0                	xor    %eax,%eax
  802400:	89 fa                	mov    %edi,%edx
  802402:	83 c4 1c             	add    $0x1c,%esp
  802405:	5b                   	pop    %ebx
  802406:	5e                   	pop    %esi
  802407:	5f                   	pop    %edi
  802408:	5d                   	pop    %ebp
  802409:	c3                   	ret    
  80240a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802410:	0f bd f8             	bsr    %eax,%edi
  802413:	83 f7 1f             	xor    $0x1f,%edi
  802416:	75 48                	jne    802460 <__udivdi3+0xa0>
  802418:	39 f0                	cmp    %esi,%eax
  80241a:	72 06                	jb     802422 <__udivdi3+0x62>
  80241c:	31 c0                	xor    %eax,%eax
  80241e:	39 eb                	cmp    %ebp,%ebx
  802420:	77 de                	ja     802400 <__udivdi3+0x40>
  802422:	b8 01 00 00 00       	mov    $0x1,%eax
  802427:	eb d7                	jmp    802400 <__udivdi3+0x40>
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	89 d9                	mov    %ebx,%ecx
  802432:	85 db                	test   %ebx,%ebx
  802434:	75 0b                	jne    802441 <__udivdi3+0x81>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f3                	div    %ebx
  80243f:	89 c1                	mov    %eax,%ecx
  802441:	31 d2                	xor    %edx,%edx
  802443:	89 f0                	mov    %esi,%eax
  802445:	f7 f1                	div    %ecx
  802447:	89 c6                	mov    %eax,%esi
  802449:	89 e8                	mov    %ebp,%eax
  80244b:	89 f7                	mov    %esi,%edi
  80244d:	f7 f1                	div    %ecx
  80244f:	89 fa                	mov    %edi,%edx
  802451:	83 c4 1c             	add    $0x1c,%esp
  802454:	5b                   	pop    %ebx
  802455:	5e                   	pop    %esi
  802456:	5f                   	pop    %edi
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    
  802459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802460:	89 f9                	mov    %edi,%ecx
  802462:	ba 20 00 00 00       	mov    $0x20,%edx
  802467:	29 fa                	sub    %edi,%edx
  802469:	d3 e0                	shl    %cl,%eax
  80246b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80246f:	89 d1                	mov    %edx,%ecx
  802471:	89 d8                	mov    %ebx,%eax
  802473:	d3 e8                	shr    %cl,%eax
  802475:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802479:	09 c1                	or     %eax,%ecx
  80247b:	89 f0                	mov    %esi,%eax
  80247d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802481:	89 f9                	mov    %edi,%ecx
  802483:	d3 e3                	shl    %cl,%ebx
  802485:	89 d1                	mov    %edx,%ecx
  802487:	d3 e8                	shr    %cl,%eax
  802489:	89 f9                	mov    %edi,%ecx
  80248b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80248f:	89 eb                	mov    %ebp,%ebx
  802491:	d3 e6                	shl    %cl,%esi
  802493:	89 d1                	mov    %edx,%ecx
  802495:	d3 eb                	shr    %cl,%ebx
  802497:	09 f3                	or     %esi,%ebx
  802499:	89 c6                	mov    %eax,%esi
  80249b:	89 f2                	mov    %esi,%edx
  80249d:	89 d8                	mov    %ebx,%eax
  80249f:	f7 74 24 08          	divl   0x8(%esp)
  8024a3:	89 d6                	mov    %edx,%esi
  8024a5:	89 c3                	mov    %eax,%ebx
  8024a7:	f7 64 24 0c          	mull   0xc(%esp)
  8024ab:	39 d6                	cmp    %edx,%esi
  8024ad:	72 19                	jb     8024c8 <__udivdi3+0x108>
  8024af:	89 f9                	mov    %edi,%ecx
  8024b1:	d3 e5                	shl    %cl,%ebp
  8024b3:	39 c5                	cmp    %eax,%ebp
  8024b5:	73 04                	jae    8024bb <__udivdi3+0xfb>
  8024b7:	39 d6                	cmp    %edx,%esi
  8024b9:	74 0d                	je     8024c8 <__udivdi3+0x108>
  8024bb:	89 d8                	mov    %ebx,%eax
  8024bd:	31 ff                	xor    %edi,%edi
  8024bf:	e9 3c ff ff ff       	jmp    802400 <__udivdi3+0x40>
  8024c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024cb:	31 ff                	xor    %edi,%edi
  8024cd:	e9 2e ff ff ff       	jmp    802400 <__udivdi3+0x40>
  8024d2:	66 90                	xchg   %ax,%ax
  8024d4:	66 90                	xchg   %ax,%ax
  8024d6:	66 90                	xchg   %ax,%ax
  8024d8:	66 90                	xchg   %ax,%ax
  8024da:	66 90                	xchg   %ax,%ax
  8024dc:	66 90                	xchg   %ax,%ax
  8024de:	66 90                	xchg   %ax,%ax

008024e0 <__umoddi3>:
  8024e0:	f3 0f 1e fb          	endbr32 
  8024e4:	55                   	push   %ebp
  8024e5:	57                   	push   %edi
  8024e6:	56                   	push   %esi
  8024e7:	53                   	push   %ebx
  8024e8:	83 ec 1c             	sub    $0x1c,%esp
  8024eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024f3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8024f7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8024fb:	89 f0                	mov    %esi,%eax
  8024fd:	89 da                	mov    %ebx,%edx
  8024ff:	85 ff                	test   %edi,%edi
  802501:	75 15                	jne    802518 <__umoddi3+0x38>
  802503:	39 dd                	cmp    %ebx,%ebp
  802505:	76 39                	jbe    802540 <__umoddi3+0x60>
  802507:	f7 f5                	div    %ebp
  802509:	89 d0                	mov    %edx,%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	83 c4 1c             	add    $0x1c,%esp
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    
  802515:	8d 76 00             	lea    0x0(%esi),%esi
  802518:	39 df                	cmp    %ebx,%edi
  80251a:	77 f1                	ja     80250d <__umoddi3+0x2d>
  80251c:	0f bd cf             	bsr    %edi,%ecx
  80251f:	83 f1 1f             	xor    $0x1f,%ecx
  802522:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802526:	75 40                	jne    802568 <__umoddi3+0x88>
  802528:	39 df                	cmp    %ebx,%edi
  80252a:	72 04                	jb     802530 <__umoddi3+0x50>
  80252c:	39 f5                	cmp    %esi,%ebp
  80252e:	77 dd                	ja     80250d <__umoddi3+0x2d>
  802530:	89 da                	mov    %ebx,%edx
  802532:	89 f0                	mov    %esi,%eax
  802534:	29 e8                	sub    %ebp,%eax
  802536:	19 fa                	sbb    %edi,%edx
  802538:	eb d3                	jmp    80250d <__umoddi3+0x2d>
  80253a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802540:	89 e9                	mov    %ebp,%ecx
  802542:	85 ed                	test   %ebp,%ebp
  802544:	75 0b                	jne    802551 <__umoddi3+0x71>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f5                	div    %ebp
  80254f:	89 c1                	mov    %eax,%ecx
  802551:	89 d8                	mov    %ebx,%eax
  802553:	31 d2                	xor    %edx,%edx
  802555:	f7 f1                	div    %ecx
  802557:	89 f0                	mov    %esi,%eax
  802559:	f7 f1                	div    %ecx
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	31 d2                	xor    %edx,%edx
  80255f:	eb ac                	jmp    80250d <__umoddi3+0x2d>
  802561:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802568:	8b 44 24 04          	mov    0x4(%esp),%eax
  80256c:	ba 20 00 00 00       	mov    $0x20,%edx
  802571:	29 c2                	sub    %eax,%edx
  802573:	89 c1                	mov    %eax,%ecx
  802575:	89 e8                	mov    %ebp,%eax
  802577:	d3 e7                	shl    %cl,%edi
  802579:	89 d1                	mov    %edx,%ecx
  80257b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80257f:	d3 e8                	shr    %cl,%eax
  802581:	89 c1                	mov    %eax,%ecx
  802583:	8b 44 24 04          	mov    0x4(%esp),%eax
  802587:	09 f9                	or     %edi,%ecx
  802589:	89 df                	mov    %ebx,%edi
  80258b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80258f:	89 c1                	mov    %eax,%ecx
  802591:	d3 e5                	shl    %cl,%ebp
  802593:	89 d1                	mov    %edx,%ecx
  802595:	d3 ef                	shr    %cl,%edi
  802597:	89 c1                	mov    %eax,%ecx
  802599:	89 f0                	mov    %esi,%eax
  80259b:	d3 e3                	shl    %cl,%ebx
  80259d:	89 d1                	mov    %edx,%ecx
  80259f:	89 fa                	mov    %edi,%edx
  8025a1:	d3 e8                	shr    %cl,%eax
  8025a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025a8:	09 d8                	or     %ebx,%eax
  8025aa:	f7 74 24 08          	divl   0x8(%esp)
  8025ae:	89 d3                	mov    %edx,%ebx
  8025b0:	d3 e6                	shl    %cl,%esi
  8025b2:	f7 e5                	mul    %ebp
  8025b4:	89 c7                	mov    %eax,%edi
  8025b6:	89 d1                	mov    %edx,%ecx
  8025b8:	39 d3                	cmp    %edx,%ebx
  8025ba:	72 06                	jb     8025c2 <__umoddi3+0xe2>
  8025bc:	75 0e                	jne    8025cc <__umoddi3+0xec>
  8025be:	39 c6                	cmp    %eax,%esi
  8025c0:	73 0a                	jae    8025cc <__umoddi3+0xec>
  8025c2:	29 e8                	sub    %ebp,%eax
  8025c4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8025c8:	89 d1                	mov    %edx,%ecx
  8025ca:	89 c7                	mov    %eax,%edi
  8025cc:	89 f5                	mov    %esi,%ebp
  8025ce:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025d2:	29 fd                	sub    %edi,%ebp
  8025d4:	19 cb                	sbb    %ecx,%ebx
  8025d6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8025db:	89 d8                	mov    %ebx,%eax
  8025dd:	d3 e0                	shl    %cl,%eax
  8025df:	89 f1                	mov    %esi,%ecx
  8025e1:	d3 ed                	shr    %cl,%ebp
  8025e3:	d3 eb                	shr    %cl,%ebx
  8025e5:	09 e8                	or     %ebp,%eax
  8025e7:	89 da                	mov    %ebx,%edx
  8025e9:	83 c4 1c             	add    $0x1c,%esp
  8025ec:	5b                   	pop    %ebx
  8025ed:	5e                   	pop    %esi
  8025ee:	5f                   	pop    %edi
  8025ef:	5d                   	pop    %ebp
  8025f0:	c3                   	ret    
