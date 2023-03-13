
obj/user/primes.debug：     文件格式 elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 28 10 00 00       	call   801074 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 00 40 80 00       	mov    0x804000,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 40 21 80 00       	push   $0x802140
  800060:	e8 ca 01 00 00       	call   80022f <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 8a 0e 00 00       	call   800ef4 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	78 2e                	js     8000a1 <primeproc+0x6e>
		panic("fork: %e", id);
	if (id == 0)
  800073:	74 ca                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800075:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800078:	83 ec 04             	sub    $0x4,%esp
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	56                   	push   %esi
  800080:	e8 ef 0f 00 00       	call   801074 <ipc_recv>
  800085:	89 c1                	mov    %eax,%ecx
		if (i % p)
  800087:	99                   	cltd   
  800088:	f7 fb                	idiv   %ebx
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	85 d2                	test   %edx,%edx
  80008f:	74 e7                	je     800078 <primeproc+0x45>
			ipc_send(id, i, 0, 0);
  800091:	6a 00                	push   $0x0
  800093:	6a 00                	push   $0x0
  800095:	51                   	push   %ecx
  800096:	57                   	push   %edi
  800097:	e8 3f 10 00 00       	call   8010db <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb d7                	jmp    800078 <primeproc+0x45>
		panic("fork: %e", id);
  8000a1:	50                   	push   %eax
  8000a2:	68 58 25 80 00       	push   $0x802558
  8000a7:	6a 1a                	push   $0x1a
  8000a9:	68 4c 21 80 00       	push   $0x80214c
  8000ae:	e8 a1 00 00 00       	call   800154 <_panic>

008000b3 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000b8:	e8 37 0e 00 00       	call   800ef4 <fork>
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	78 1a                	js     8000dd <umain+0x2a>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000c3:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000c8:	74 25                	je     8000ef <umain+0x3c>
		ipc_send(id, i, 0, 0);
  8000ca:	6a 00                	push   $0x0
  8000cc:	6a 00                	push   $0x0
  8000ce:	53                   	push   %ebx
  8000cf:	56                   	push   %esi
  8000d0:	e8 06 10 00 00       	call   8010db <ipc_send>
	for (i = 2; ; i++)
  8000d5:	83 c3 01             	add    $0x1,%ebx
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	eb ed                	jmp    8000ca <umain+0x17>
		panic("fork: %e", id);
  8000dd:	50                   	push   %eax
  8000de:	68 58 25 80 00       	push   $0x802558
  8000e3:	6a 2d                	push   $0x2d
  8000e5:	68 4c 21 80 00       	push   $0x80214c
  8000ea:	e8 65 00 00 00       	call   800154 <_panic>
		primeproc();
  8000ef:	e8 3f ff ff ff       	call   800033 <primeproc>

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ff:	e8 c3 0a 00 00       	call   800bc7 <sys_getenvid>
  800104:	25 ff 03 00 00       	and    $0x3ff,%eax
  800109:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800111:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800116:	85 db                	test   %ebx,%ebx
  800118:	7e 07                	jle    800121 <libmain+0x2d>
		binaryname = argv[0];
  80011a:	8b 06                	mov    (%esi),%eax
  80011c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800121:	83 ec 08             	sub    $0x8,%esp
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
  800126:	e8 88 ff ff ff       	call   8000b3 <umain>

	// exit gracefully
	exit();
  80012b:	e8 0a 00 00 00       	call   80013a <exit>
}
  800130:	83 c4 10             	add    $0x10,%esp
  800133:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800140:	e8 ef 11 00 00       	call   801334 <close_all>
	sys_env_destroy(0);
  800145:	83 ec 0c             	sub    $0xc,%esp
  800148:	6a 00                	push   $0x0
  80014a:	e8 37 0a 00 00       	call   800b86 <sys_env_destroy>
}
  80014f:	83 c4 10             	add    $0x10,%esp
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800159:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800162:	e8 60 0a 00 00       	call   800bc7 <sys_getenvid>
  800167:	83 ec 0c             	sub    $0xc,%esp
  80016a:	ff 75 0c             	push   0xc(%ebp)
  80016d:	ff 75 08             	push   0x8(%ebp)
  800170:	56                   	push   %esi
  800171:	50                   	push   %eax
  800172:	68 64 21 80 00       	push   $0x802164
  800177:	e8 b3 00 00 00       	call   80022f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017c:	83 c4 18             	add    $0x18,%esp
  80017f:	53                   	push   %ebx
  800180:	ff 75 10             	push   0x10(%ebp)
  800183:	e8 56 00 00 00       	call   8001de <vcprintf>
	cprintf("\n");
  800188:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  80018f:	e8 9b 00 00 00       	call   80022f <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800197:	cc                   	int3   
  800198:	eb fd                	jmp    800197 <_panic+0x43>

0080019a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	53                   	push   %ebx
  80019e:	83 ec 04             	sub    $0x4,%esp
  8001a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a4:	8b 13                	mov    (%ebx),%edx
  8001a6:	8d 42 01             	lea    0x1(%edx),%eax
  8001a9:	89 03                	mov    %eax,(%ebx)
  8001ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b7:	74 09                	je     8001c2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c2:	83 ec 08             	sub    $0x8,%esp
  8001c5:	68 ff 00 00 00       	push   $0xff
  8001ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cd:	50                   	push   %eax
  8001ce:	e8 76 09 00 00       	call   800b49 <sys_cputs>
		b->idx = 0;
  8001d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	eb db                	jmp    8001b9 <putch+0x1f>

008001de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ee:	00 00 00 
	b.cnt = 0;
  8001f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fb:	ff 75 0c             	push   0xc(%ebp)
  8001fe:	ff 75 08             	push   0x8(%ebp)
  800201:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	68 9a 01 80 00       	push   $0x80019a
  80020d:	e8 14 01 00 00       	call   800326 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800212:	83 c4 08             	add    $0x8,%esp
  800215:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80021b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800221:	50                   	push   %eax
  800222:	e8 22 09 00 00       	call   800b49 <sys_cputs>

	return b.cnt;
}
  800227:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800235:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800238:	50                   	push   %eax
  800239:	ff 75 08             	push   0x8(%ebp)
  80023c:	e8 9d ff ff ff       	call   8001de <vcprintf>
	va_end(ap);

	return cnt;
}
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	57                   	push   %edi
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
  800249:	83 ec 1c             	sub    $0x1c,%esp
  80024c:	89 c7                	mov    %eax,%edi
  80024e:	89 d6                	mov    %edx,%esi
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	8b 55 0c             	mov    0xc(%ebp),%edx
  800256:	89 d1                	mov    %edx,%ecx
  800258:	89 c2                	mov    %eax,%edx
  80025a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800260:	8b 45 10             	mov    0x10(%ebp),%eax
  800263:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800266:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800269:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800270:	39 c2                	cmp    %eax,%edx
  800272:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800275:	72 3e                	jb     8002b5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	ff 75 18             	push   0x18(%ebp)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	53                   	push   %ebx
  800281:	50                   	push   %eax
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	ff 75 e4             	push   -0x1c(%ebp)
  800288:	ff 75 e0             	push   -0x20(%ebp)
  80028b:	ff 75 dc             	push   -0x24(%ebp)
  80028e:	ff 75 d8             	push   -0x28(%ebp)
  800291:	e8 5a 1c 00 00       	call   801ef0 <__udivdi3>
  800296:	83 c4 18             	add    $0x18,%esp
  800299:	52                   	push   %edx
  80029a:	50                   	push   %eax
  80029b:	89 f2                	mov    %esi,%edx
  80029d:	89 f8                	mov    %edi,%eax
  80029f:	e8 9f ff ff ff       	call   800243 <printnum>
  8002a4:	83 c4 20             	add    $0x20,%esp
  8002a7:	eb 13                	jmp    8002bc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	56                   	push   %esi
  8002ad:	ff 75 18             	push   0x18(%ebp)
  8002b0:	ff d7                	call   *%edi
  8002b2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b5:	83 eb 01             	sub    $0x1,%ebx
  8002b8:	85 db                	test   %ebx,%ebx
  8002ba:	7f ed                	jg     8002a9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	56                   	push   %esi
  8002c0:	83 ec 04             	sub    $0x4,%esp
  8002c3:	ff 75 e4             	push   -0x1c(%ebp)
  8002c6:	ff 75 e0             	push   -0x20(%ebp)
  8002c9:	ff 75 dc             	push   -0x24(%ebp)
  8002cc:	ff 75 d8             	push   -0x28(%ebp)
  8002cf:	e8 3c 1d 00 00       	call   802010 <__umoddi3>
  8002d4:	83 c4 14             	add    $0x14,%esp
  8002d7:	0f be 80 87 21 80 00 	movsbl 0x802187(%eax),%eax
  8002de:	50                   	push   %eax
  8002df:	ff d7                	call   *%edi
}
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fb:	73 0a                	jae    800307 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fd:	8d 4a 01             	lea    0x1(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	88 02                	mov    %al,(%edx)
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <printfmt>:
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800312:	50                   	push   %eax
  800313:	ff 75 10             	push   0x10(%ebp)
  800316:	ff 75 0c             	push   0xc(%ebp)
  800319:	ff 75 08             	push   0x8(%ebp)
  80031c:	e8 05 00 00 00       	call   800326 <vprintfmt>
}
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <vprintfmt>:
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	57                   	push   %edi
  80032a:	56                   	push   %esi
  80032b:	53                   	push   %ebx
  80032c:	83 ec 3c             	sub    $0x3c,%esp
  80032f:	8b 75 08             	mov    0x8(%ebp),%esi
  800332:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800335:	8b 7d 10             	mov    0x10(%ebp),%edi
  800338:	eb 0a                	jmp    800344 <vprintfmt+0x1e>
			putch(ch, putdat);
  80033a:	83 ec 08             	sub    $0x8,%esp
  80033d:	53                   	push   %ebx
  80033e:	50                   	push   %eax
  80033f:	ff d6                	call   *%esi
  800341:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800344:	83 c7 01             	add    $0x1,%edi
  800347:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80034b:	83 f8 25             	cmp    $0x25,%eax
  80034e:	74 0c                	je     80035c <vprintfmt+0x36>
			if (ch == '\0')
  800350:	85 c0                	test   %eax,%eax
  800352:	75 e6                	jne    80033a <vprintfmt+0x14>
}
  800354:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800357:	5b                   	pop    %ebx
  800358:	5e                   	pop    %esi
  800359:	5f                   	pop    %edi
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    
		padc = ' ';
  80035c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800360:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800367:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80036e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800375:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8d 47 01             	lea    0x1(%edi),%eax
  80037d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800380:	0f b6 17             	movzbl (%edi),%edx
  800383:	8d 42 dd             	lea    -0x23(%edx),%eax
  800386:	3c 55                	cmp    $0x55,%al
  800388:	0f 87 bb 03 00 00    	ja     800749 <vprintfmt+0x423>
  80038e:	0f b6 c0             	movzbl %al,%eax
  800391:	ff 24 85 c0 22 80 00 	jmp    *0x8022c0(,%eax,4)
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80039b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80039f:	eb d9                	jmp    80037a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a4:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003a8:	eb d0                	jmp    80037a <vprintfmt+0x54>
  8003aa:	0f b6 d2             	movzbl %dl,%edx
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003b8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003bf:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c5:	83 f9 09             	cmp    $0x9,%ecx
  8003c8:	77 55                	ja     80041f <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003ca:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003cd:	eb e9                	jmp    8003b8 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8b 00                	mov    (%eax),%eax
  8003d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 40 04             	lea    0x4(%eax),%eax
  8003dd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e7:	79 91                	jns    80037a <vprintfmt+0x54>
				width = precision, precision = -1;
  8003e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ef:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003f6:	eb 82                	jmp    80037a <vprintfmt+0x54>
  8003f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003fb:	85 d2                	test   %edx,%edx
  8003fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800402:	0f 49 c2             	cmovns %edx,%eax
  800405:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040b:	e9 6a ff ff ff       	jmp    80037a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800413:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80041a:	e9 5b ff ff ff       	jmp    80037a <vprintfmt+0x54>
  80041f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800422:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800425:	eb bc                	jmp    8003e3 <vprintfmt+0xbd>
			lflag++;
  800427:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80042d:	e9 48 ff ff ff       	jmp    80037a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 78 04             	lea    0x4(%eax),%edi
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	53                   	push   %ebx
  80043c:	ff 30                	push   (%eax)
  80043e:	ff d6                	call   *%esi
			break;
  800440:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800443:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800446:	e9 9d 02 00 00       	jmp    8006e8 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 78 04             	lea    0x4(%eax),%edi
  800451:	8b 10                	mov    (%eax),%edx
  800453:	89 d0                	mov    %edx,%eax
  800455:	f7 d8                	neg    %eax
  800457:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 0f             	cmp    $0xf,%eax
  80045d:	7f 23                	jg     800482 <vprintfmt+0x15c>
  80045f:	8b 14 85 20 24 80 00 	mov    0x802420(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	74 18                	je     800482 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80046a:	52                   	push   %edx
  80046b:	68 3d 26 80 00       	push   $0x80263d
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 92 fe ff ff       	call   800309 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80047d:	e9 66 02 00 00       	jmp    8006e8 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800482:	50                   	push   %eax
  800483:	68 9f 21 80 00       	push   $0x80219f
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 7a fe ff ff       	call   800309 <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800492:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800495:	e9 4e 02 00 00       	jmp    8006e8 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	83 c0 04             	add    $0x4,%eax
  8004a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004a8:	85 d2                	test   %edx,%edx
  8004aa:	b8 98 21 80 00       	mov    $0x802198,%eax
  8004af:	0f 45 c2             	cmovne %edx,%eax
  8004b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b9:	7e 06                	jle    8004c1 <vprintfmt+0x19b>
  8004bb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004bf:	75 0d                	jne    8004ce <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c4:	89 c7                	mov    %eax,%edi
  8004c6:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cc:	eb 55                	jmp    800523 <vprintfmt+0x1fd>
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 d8             	push   -0x28(%ebp)
  8004d4:	ff 75 cc             	push   -0x34(%ebp)
  8004d7:	e8 0a 03 00 00       	call   8007e6 <strnlen>
  8004dc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004df:	29 c1                	sub    %eax,%ecx
  8004e1:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004e9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	eb 0f                	jmp    800501 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	ff 75 e0             	push   -0x20(%ebp)
  8004f9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 ef 01             	sub    $0x1,%edi
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 ff                	test   %edi,%edi
  800503:	7f ed                	jg     8004f2 <vprintfmt+0x1cc>
  800505:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800508:	85 d2                	test   %edx,%edx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c2             	cmovns %edx,%eax
  800512:	29 c2                	sub    %eax,%edx
  800514:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800517:	eb a8                	jmp    8004c1 <vprintfmt+0x19b>
					putch(ch, putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	53                   	push   %ebx
  80051d:	52                   	push   %edx
  80051e:	ff d6                	call   *%esi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800526:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800528:	83 c7 01             	add    $0x1,%edi
  80052b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052f:	0f be d0             	movsbl %al,%edx
  800532:	85 d2                	test   %edx,%edx
  800534:	74 4b                	je     800581 <vprintfmt+0x25b>
  800536:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053a:	78 06                	js     800542 <vprintfmt+0x21c>
  80053c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800540:	78 1e                	js     800560 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800542:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800546:	74 d1                	je     800519 <vprintfmt+0x1f3>
  800548:	0f be c0             	movsbl %al,%eax
  80054b:	83 e8 20             	sub    $0x20,%eax
  80054e:	83 f8 5e             	cmp    $0x5e,%eax
  800551:	76 c6                	jbe    800519 <vprintfmt+0x1f3>
					putch('?', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	53                   	push   %ebx
  800557:	6a 3f                	push   $0x3f
  800559:	ff d6                	call   *%esi
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	eb c3                	jmp    800523 <vprintfmt+0x1fd>
  800560:	89 cf                	mov    %ecx,%edi
  800562:	eb 0e                	jmp    800572 <vprintfmt+0x24c>
				putch(' ', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	6a 20                	push   $0x20
  80056a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80056c:	83 ef 01             	sub    $0x1,%edi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	85 ff                	test   %edi,%edi
  800574:	7f ee                	jg     800564 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800576:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
  80057c:	e9 67 01 00 00       	jmp    8006e8 <vprintfmt+0x3c2>
  800581:	89 cf                	mov    %ecx,%edi
  800583:	eb ed                	jmp    800572 <vprintfmt+0x24c>
	if (lflag >= 2)
  800585:	83 f9 01             	cmp    $0x1,%ecx
  800588:	7f 1b                	jg     8005a5 <vprintfmt+0x27f>
	else if (lflag)
  80058a:	85 c9                	test   %ecx,%ecx
  80058c:	74 63                	je     8005f1 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	99                   	cltd   
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 40 04             	lea    0x4(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a3:	eb 17                	jmp    8005bc <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8b 50 04             	mov    0x4(%eax),%edx
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 40 08             	lea    0x8(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c2:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005c7:	85 c9                	test   %ecx,%ecx
  8005c9:	0f 89 ff 00 00 00    	jns    8006ce <vprintfmt+0x3a8>
				putch('-', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	6a 2d                	push   $0x2d
  8005d5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005dd:	f7 da                	neg    %edx
  8005df:	83 d1 00             	adc    $0x0,%ecx
  8005e2:	f7 d9                	neg    %ecx
  8005e4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e7:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005ec:	e9 dd 00 00 00       	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	99                   	cltd   
  8005fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 40 04             	lea    0x4(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
  800606:	eb b4                	jmp    8005bc <vprintfmt+0x296>
	if (lflag >= 2)
  800608:	83 f9 01             	cmp    $0x1,%ecx
  80060b:	7f 1e                	jg     80062b <vprintfmt+0x305>
	else if (lflag)
  80060d:	85 c9                	test   %ecx,%ecx
  80060f:	74 32                	je     800643 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8b 10                	mov    (%eax),%edx
  800616:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061b:	8d 40 04             	lea    0x4(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800621:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800626:	e9 a3 00 00 00       	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	8b 48 04             	mov    0x4(%eax),%ecx
  800633:	8d 40 08             	lea    0x8(%eax),%eax
  800636:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800639:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80063e:	e9 8b 00 00 00       	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800653:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800658:	eb 74                	jmp    8006ce <vprintfmt+0x3a8>
	if (lflag >= 2)
  80065a:	83 f9 01             	cmp    $0x1,%ecx
  80065d:	7f 1b                	jg     80067a <vprintfmt+0x354>
	else if (lflag)
  80065f:	85 c9                	test   %ecx,%ecx
  800661:	74 2c                	je     80068f <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 10                	mov    (%eax),%edx
  800668:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800673:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800678:	eb 54                	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8b 48 04             	mov    0x4(%eax),%ecx
  800682:	8d 40 08             	lea    0x8(%eax),%eax
  800685:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800688:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80068d:	eb 3f                	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8b 10                	mov    (%eax),%edx
  800694:	b9 00 00 00 00       	mov    $0x0,%ecx
  800699:	8d 40 04             	lea    0x4(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80069f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8006a4:	eb 28                	jmp    8006ce <vprintfmt+0x3a8>
			putch('0', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 30                	push   $0x30
  8006ac:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ae:	83 c4 08             	add    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 78                	push   $0x78
  8006b4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8b 10                	mov    (%eax),%edx
  8006bb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c3:	8d 40 04             	lea    0x4(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c9:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d5:	50                   	push   %eax
  8006d6:	ff 75 e0             	push   -0x20(%ebp)
  8006d9:	57                   	push   %edi
  8006da:	51                   	push   %ecx
  8006db:	52                   	push   %edx
  8006dc:	89 da                	mov    %ebx,%edx
  8006de:	89 f0                	mov    %esi,%eax
  8006e0:	e8 5e fb ff ff       	call   800243 <printnum>
			break;
  8006e5:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006eb:	e9 54 fc ff ff       	jmp    800344 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006f0:	83 f9 01             	cmp    $0x1,%ecx
  8006f3:	7f 1b                	jg     800710 <vprintfmt+0x3ea>
	else if (lflag)
  8006f5:	85 c9                	test   %ecx,%ecx
  8006f7:	74 2c                	je     800725 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 10                	mov    (%eax),%edx
  8006fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800703:	8d 40 04             	lea    0x4(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800709:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80070e:	eb be                	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8b 10                	mov    (%eax),%edx
  800715:	8b 48 04             	mov    0x4(%eax),%ecx
  800718:	8d 40 08             	lea    0x8(%eax),%eax
  80071b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800723:	eb a9                	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800735:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80073a:	eb 92                	jmp    8006ce <vprintfmt+0x3a8>
			putch(ch, putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 25                	push   $0x25
  800742:	ff d6                	call   *%esi
			break;
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	eb 9f                	jmp    8006e8 <vprintfmt+0x3c2>
			putch('%', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 25                	push   $0x25
  80074f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	89 f8                	mov    %edi,%eax
  800756:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075a:	74 05                	je     800761 <vprintfmt+0x43b>
  80075c:	83 e8 01             	sub    $0x1,%eax
  80075f:	eb f5                	jmp    800756 <vprintfmt+0x430>
  800761:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800764:	eb 82                	jmp    8006e8 <vprintfmt+0x3c2>

00800766 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 18             	sub    $0x18,%esp
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800779:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800783:	85 c0                	test   %eax,%eax
  800785:	74 26                	je     8007ad <vsnprintf+0x47>
  800787:	85 d2                	test   %edx,%edx
  800789:	7e 22                	jle    8007ad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078b:	ff 75 14             	push   0x14(%ebp)
  80078e:	ff 75 10             	push   0x10(%ebp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	68 ec 02 80 00       	push   $0x8002ec
  80079a:	e8 87 fb ff ff       	call   800326 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a8:	83 c4 10             	add    $0x10,%esp
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    
		return -E_INVAL;
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b2:	eb f7                	jmp    8007ab <vsnprintf+0x45>

008007b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bd:	50                   	push   %eax
  8007be:	ff 75 10             	push   0x10(%ebp)
  8007c1:	ff 75 0c             	push   0xc(%ebp)
  8007c4:	ff 75 08             	push   0x8(%ebp)
  8007c7:	e8 9a ff ff ff       	call   800766 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	eb 03                	jmp    8007de <strlen+0x10>
		n++;
  8007db:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e2:	75 f7                	jne    8007db <strlen+0xd>
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f4:	eb 03                	jmp    8007f9 <strnlen+0x13>
		n++;
  8007f6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	39 d0                	cmp    %edx,%eax
  8007fb:	74 08                	je     800805 <strnlen+0x1f>
  8007fd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800801:	75 f3                	jne    8007f6 <strnlen+0x10>
  800803:	89 c2                	mov    %eax,%edx
	return n;
}
  800805:	89 d0                	mov    %edx,%eax
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800810:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
  800818:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80081c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	84 d2                	test   %dl,%dl
  800824:	75 f2                	jne    800818 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800826:	89 c8                	mov    %ecx,%eax
  800828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	53                   	push   %ebx
  800831:	83 ec 10             	sub    $0x10,%esp
  800834:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800837:	53                   	push   %ebx
  800838:	e8 91 ff ff ff       	call   8007ce <strlen>
  80083d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800840:	ff 75 0c             	push   0xc(%ebp)
  800843:	01 d8                	add    %ebx,%eax
  800845:	50                   	push   %eax
  800846:	e8 be ff ff ff       	call   800809 <strcpy>
	return dst;
}
  80084b:	89 d8                	mov    %ebx,%eax
  80084d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 75 08             	mov    0x8(%ebp),%esi
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	89 f3                	mov    %esi,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800862:	89 f0                	mov    %esi,%eax
  800864:	eb 0f                	jmp    800875 <strncpy+0x23>
		*dst++ = *src;
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	0f b6 0a             	movzbl (%edx),%ecx
  80086c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086f:	80 f9 01             	cmp    $0x1,%cl
  800872:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800875:	39 d8                	cmp    %ebx,%eax
  800877:	75 ed                	jne    800866 <strncpy+0x14>
	}
	return ret;
}
  800879:	89 f0                	mov    %esi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 75 08             	mov    0x8(%ebp),%esi
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088a:	8b 55 10             	mov    0x10(%ebp),%edx
  80088d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088f:	85 d2                	test   %edx,%edx
  800891:	74 21                	je     8008b4 <strlcpy+0x35>
  800893:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800897:	89 f2                	mov    %esi,%edx
  800899:	eb 09                	jmp    8008a4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089b:	83 c1 01             	add    $0x1,%ecx
  80089e:	83 c2 01             	add    $0x1,%edx
  8008a1:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8008a4:	39 c2                	cmp    %eax,%edx
  8008a6:	74 09                	je     8008b1 <strlcpy+0x32>
  8008a8:	0f b6 19             	movzbl (%ecx),%ebx
  8008ab:	84 db                	test   %bl,%bl
  8008ad:	75 ec                	jne    80089b <strlcpy+0x1c>
  8008af:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b4:	29 f0                	sub    %esi,%eax
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c3:	eb 06                	jmp    8008cb <strcmp+0x11>
		p++, q++;
  8008c5:	83 c1 01             	add    $0x1,%ecx
  8008c8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008cb:	0f b6 01             	movzbl (%ecx),%eax
  8008ce:	84 c0                	test   %al,%al
  8008d0:	74 04                	je     8008d6 <strcmp+0x1c>
  8008d2:	3a 02                	cmp    (%edx),%al
  8008d4:	74 ef                	je     8008c5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d6:	0f b6 c0             	movzbl %al,%eax
  8008d9:	0f b6 12             	movzbl (%edx),%edx
  8008dc:	29 d0                	sub    %edx,%eax
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	89 c3                	mov    %eax,%ebx
  8008ec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ef:	eb 06                	jmp    8008f7 <strncmp+0x17>
		n--, p++, q++;
  8008f1:	83 c0 01             	add    $0x1,%eax
  8008f4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f7:	39 d8                	cmp    %ebx,%eax
  8008f9:	74 18                	je     800913 <strncmp+0x33>
  8008fb:	0f b6 08             	movzbl (%eax),%ecx
  8008fe:	84 c9                	test   %cl,%cl
  800900:	74 04                	je     800906 <strncmp+0x26>
  800902:	3a 0a                	cmp    (%edx),%cl
  800904:	74 eb                	je     8008f1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800906:	0f b6 00             	movzbl (%eax),%eax
  800909:	0f b6 12             	movzbl (%edx),%edx
  80090c:	29 d0                	sub    %edx,%eax
}
  80090e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800911:	c9                   	leave  
  800912:	c3                   	ret    
		return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
  800918:	eb f4                	jmp    80090e <strncmp+0x2e>

0080091a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800924:	eb 03                	jmp    800929 <strchr+0xf>
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	0f b6 10             	movzbl (%eax),%edx
  80092c:	84 d2                	test   %dl,%dl
  80092e:	74 06                	je     800936 <strchr+0x1c>
		if (*s == c)
  800930:	38 ca                	cmp    %cl,%dl
  800932:	75 f2                	jne    800926 <strchr+0xc>
  800934:	eb 05                	jmp    80093b <strchr+0x21>
			return (char *) s;
	return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800947:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 09                	je     800957 <strfind+0x1a>
  80094e:	84 d2                	test   %dl,%dl
  800950:	74 05                	je     800957 <strfind+0x1a>
	for (; *s; s++)
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	eb f0                	jmp    800947 <strfind+0xa>
			break;
	return (char *) s;
}
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 2f                	je     800998 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800969:	89 f8                	mov    %edi,%eax
  80096b:	09 c8                	or     %ecx,%eax
  80096d:	a8 03                	test   $0x3,%al
  80096f:	75 21                	jne    800992 <memset+0x39>
		c &= 0xFF;
  800971:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800975:	89 d0                	mov    %edx,%eax
  800977:	c1 e0 08             	shl    $0x8,%eax
  80097a:	89 d3                	mov    %edx,%ebx
  80097c:	c1 e3 18             	shl    $0x18,%ebx
  80097f:	89 d6                	mov    %edx,%esi
  800981:	c1 e6 10             	shl    $0x10,%esi
  800984:	09 f3                	or     %esi,%ebx
  800986:	09 da                	or     %ebx,%edx
  800988:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80098d:	fc                   	cld    
  80098e:	f3 ab                	rep stos %eax,%es:(%edi)
  800990:	eb 06                	jmp    800998 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
  800995:	fc                   	cld    
  800996:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800998:	89 f8                	mov    %edi,%eax
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5f                   	pop    %edi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ad:	39 c6                	cmp    %eax,%esi
  8009af:	73 32                	jae    8009e3 <memmove+0x44>
  8009b1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b4:	39 c2                	cmp    %eax,%edx
  8009b6:	76 2b                	jbe    8009e3 <memmove+0x44>
		s += n;
		d += n;
  8009b8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	89 d6                	mov    %edx,%esi
  8009bd:	09 fe                	or     %edi,%esi
  8009bf:	09 ce                	or     %ecx,%esi
  8009c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c7:	75 0e                	jne    8009d7 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c9:	83 ef 04             	sub    $0x4,%edi
  8009cc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d2:	fd                   	std    
  8009d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d5:	eb 09                	jmp    8009e0 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d7:	83 ef 01             	sub    $0x1,%edi
  8009da:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009dd:	fd                   	std    
  8009de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e0:	fc                   	cld    
  8009e1:	eb 1a                	jmp    8009fd <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e3:	89 f2                	mov    %esi,%edx
  8009e5:	09 c2                	or     %eax,%edx
  8009e7:	09 ca                	or     %ecx,%edx
  8009e9:	f6 c2 03             	test   $0x3,%dl
  8009ec:	75 0a                	jne    8009f8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f6:	eb 05                	jmp    8009fd <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009f8:	89 c7                	mov    %eax,%edi
  8009fa:	fc                   	cld    
  8009fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a07:	ff 75 10             	push   0x10(%ebp)
  800a0a:	ff 75 0c             	push   0xc(%ebp)
  800a0d:	ff 75 08             	push   0x8(%ebp)
  800a10:	e8 8a ff ff ff       	call   80099f <memmove>
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a22:	89 c6                	mov    %eax,%esi
  800a24:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a27:	eb 06                	jmp    800a2f <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a2f:	39 f0                	cmp    %esi,%eax
  800a31:	74 14                	je     800a47 <memcmp+0x30>
		if (*s1 != *s2)
  800a33:	0f b6 08             	movzbl (%eax),%ecx
  800a36:	0f b6 1a             	movzbl (%edx),%ebx
  800a39:	38 d9                	cmp    %bl,%cl
  800a3b:	74 ec                	je     800a29 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a3d:	0f b6 c1             	movzbl %cl,%eax
  800a40:	0f b6 db             	movzbl %bl,%ebx
  800a43:	29 d8                	sub    %ebx,%eax
  800a45:	eb 05                	jmp    800a4c <memcmp+0x35>
	}

	return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a59:	89 c2                	mov    %eax,%edx
  800a5b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5e:	eb 03                	jmp    800a63 <memfind+0x13>
  800a60:	83 c0 01             	add    $0x1,%eax
  800a63:	39 d0                	cmp    %edx,%eax
  800a65:	73 04                	jae    800a6b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a67:	38 08                	cmp    %cl,(%eax)
  800a69:	75 f5                	jne    800a60 <memfind+0x10>
			break;
	return (void *) s;
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
  800a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a79:	eb 03                	jmp    800a7e <strtol+0x11>
		s++;
  800a7b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a7e:	0f b6 02             	movzbl (%edx),%eax
  800a81:	3c 20                	cmp    $0x20,%al
  800a83:	74 f6                	je     800a7b <strtol+0xe>
  800a85:	3c 09                	cmp    $0x9,%al
  800a87:	74 f2                	je     800a7b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a89:	3c 2b                	cmp    $0x2b,%al
  800a8b:	74 2a                	je     800ab7 <strtol+0x4a>
	int neg = 0;
  800a8d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a92:	3c 2d                	cmp    $0x2d,%al
  800a94:	74 2b                	je     800ac1 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9c:	75 0f                	jne    800aad <strtol+0x40>
  800a9e:	80 3a 30             	cmpb   $0x30,(%edx)
  800aa1:	74 28                	je     800acb <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa3:	85 db                	test   %ebx,%ebx
  800aa5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aaa:	0f 44 d8             	cmove  %eax,%ebx
  800aad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab5:	eb 46                	jmp    800afd <strtol+0x90>
		s++;
  800ab7:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aba:	bf 00 00 00 00       	mov    $0x0,%edi
  800abf:	eb d5                	jmp    800a96 <strtol+0x29>
		s++, neg = 1;
  800ac1:	83 c2 01             	add    $0x1,%edx
  800ac4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac9:	eb cb                	jmp    800a96 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800acb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800acf:	74 0e                	je     800adf <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ad1:	85 db                	test   %ebx,%ebx
  800ad3:	75 d8                	jne    800aad <strtol+0x40>
		s++, base = 8;
  800ad5:	83 c2 01             	add    $0x1,%edx
  800ad8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800add:	eb ce                	jmp    800aad <strtol+0x40>
		s += 2, base = 16;
  800adf:	83 c2 02             	add    $0x2,%edx
  800ae2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae7:	eb c4                	jmp    800aad <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ae9:	0f be c0             	movsbl %al,%eax
  800aec:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aef:	3b 45 10             	cmp    0x10(%ebp),%eax
  800af2:	7d 3a                	jge    800b2e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800af4:	83 c2 01             	add    $0x1,%edx
  800af7:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800afb:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800afd:	0f b6 02             	movzbl (%edx),%eax
  800b00:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b03:	89 f3                	mov    %esi,%ebx
  800b05:	80 fb 09             	cmp    $0x9,%bl
  800b08:	76 df                	jbe    800ae9 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b0a:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b0d:	89 f3                	mov    %esi,%ebx
  800b0f:	80 fb 19             	cmp    $0x19,%bl
  800b12:	77 08                	ja     800b1c <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b14:	0f be c0             	movsbl %al,%eax
  800b17:	83 e8 57             	sub    $0x57,%eax
  800b1a:	eb d3                	jmp    800aef <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b1c:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b1f:	89 f3                	mov    %esi,%ebx
  800b21:	80 fb 19             	cmp    $0x19,%bl
  800b24:	77 08                	ja     800b2e <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b26:	0f be c0             	movsbl %al,%eax
  800b29:	83 e8 37             	sub    $0x37,%eax
  800b2c:	eb c1                	jmp    800aef <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b32:	74 05                	je     800b39 <strtol+0xcc>
		*endptr = (char *) s;
  800b34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b37:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b39:	89 c8                	mov    %ecx,%eax
  800b3b:	f7 d8                	neg    %eax
  800b3d:	85 ff                	test   %edi,%edi
  800b3f:	0f 45 c8             	cmovne %eax,%ecx
}
  800b42:	89 c8                	mov    %ecx,%eax
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5a:	89 c3                	mov    %eax,%ebx
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	89 c6                	mov    %eax,%esi
  800b60:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 01 00 00 00       	mov    $0x1,%eax
  800b77:	89 d1                	mov    %edx,%ecx
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	89 d7                	mov    %edx,%edi
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9c:	89 cb                	mov    %ecx,%ebx
  800b9e:	89 cf                	mov    %ecx,%edi
  800ba0:	89 ce                	mov    %ecx,%esi
  800ba2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba4:	85 c0                	test   %eax,%eax
  800ba6:	7f 08                	jg     800bb0 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb0:	83 ec 0c             	sub    $0xc,%esp
  800bb3:	50                   	push   %eax
  800bb4:	6a 03                	push   $0x3
  800bb6:	68 7f 24 80 00       	push   $0x80247f
  800bbb:	6a 2a                	push   $0x2a
  800bbd:	68 9c 24 80 00       	push   $0x80249c
  800bc2:	e8 8d f5 ff ff       	call   800154 <_panic>

00800bc7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd7:	89 d1                	mov    %edx,%ecx
  800bd9:	89 d3                	mov    %edx,%ebx
  800bdb:	89 d7                	mov    %edx,%edi
  800bdd:	89 d6                	mov    %edx,%esi
  800bdf:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_yield>:

void
sys_yield(void)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bec:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf6:	89 d1                	mov    %edx,%ecx
  800bf8:	89 d3                	mov    %edx,%ebx
  800bfa:	89 d7                	mov    %edx,%edi
  800bfc:	89 d6                	mov    %edx,%esi
  800bfe:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0e:	be 00 00 00 00       	mov    $0x0,%esi
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c21:	89 f7                	mov    %esi,%edi
  800c23:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7f 08                	jg     800c31 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	50                   	push   %eax
  800c35:	6a 04                	push   $0x4
  800c37:	68 7f 24 80 00       	push   $0x80247f
  800c3c:	6a 2a                	push   $0x2a
  800c3e:	68 9c 24 80 00       	push   $0x80249c
  800c43:	e8 0c f5 ff ff       	call   800154 <_panic>

00800c48 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c62:	8b 75 18             	mov    0x18(%ebp),%esi
  800c65:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7f 08                	jg     800c73 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	50                   	push   %eax
  800c77:	6a 05                	push   $0x5
  800c79:	68 7f 24 80 00       	push   $0x80247f
  800c7e:	6a 2a                	push   $0x2a
  800c80:	68 9c 24 80 00       	push   $0x80249c
  800c85:	e8 ca f4 ff ff       	call   800154 <_panic>

00800c8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7f 08                	jg     800cb5 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	50                   	push   %eax
  800cb9:	6a 06                	push   $0x6
  800cbb:	68 7f 24 80 00       	push   $0x80247f
  800cc0:	6a 2a                	push   $0x2a
  800cc2:	68 9c 24 80 00       	push   $0x80249c
  800cc7:	e8 88 f4 ff ff       	call   800154 <_panic>

00800ccc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7f 08                	jg     800cf7 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	50                   	push   %eax
  800cfb:	6a 08                	push   $0x8
  800cfd:	68 7f 24 80 00       	push   $0x80247f
  800d02:	6a 2a                	push   $0x2a
  800d04:	68 9c 24 80 00       	push   $0x80249c
  800d09:	e8 46 f4 ff ff       	call   800154 <_panic>

00800d0e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	b8 09 00 00 00       	mov    $0x9,%eax
  800d27:	89 df                	mov    %ebx,%edi
  800d29:	89 de                	mov    %ebx,%esi
  800d2b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7f 08                	jg     800d39 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	50                   	push   %eax
  800d3d:	6a 09                	push   $0x9
  800d3f:	68 7f 24 80 00       	push   $0x80247f
  800d44:	6a 2a                	push   $0x2a
  800d46:	68 9c 24 80 00       	push   $0x80249c
  800d4b:	e8 04 f4 ff ff       	call   800154 <_panic>

00800d50 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7f 08                	jg     800d7b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	50                   	push   %eax
  800d7f:	6a 0a                	push   $0xa
  800d81:	68 7f 24 80 00       	push   $0x80247f
  800d86:	6a 2a                	push   $0x2a
  800d88:	68 9c 24 80 00       	push   $0x80249c
  800d8d:	e8 c2 f3 ff ff       	call   800154 <_panic>

00800d92 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da3:	be 00 00 00 00       	mov    $0x0,%esi
  800da8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dab:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dae:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dcb:	89 cb                	mov    %ecx,%ebx
  800dcd:	89 cf                	mov    %ecx,%edi
  800dcf:	89 ce                	mov    %ecx,%esi
  800dd1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7f 08                	jg     800ddf <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddf:	83 ec 0c             	sub    $0xc,%esp
  800de2:	50                   	push   %eax
  800de3:	6a 0d                	push   $0xd
  800de5:	68 7f 24 80 00       	push   $0x80247f
  800dea:	6a 2a                	push   $0x2a
  800dec:	68 9c 24 80 00       	push   $0x80249c
  800df1:	e8 5e f3 ff ff       	call   800154 <_panic>

00800df6 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dfe:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e00:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e04:	0f 84 8e 00 00 00    	je     800e98 <pgfault+0xa2>
  800e0a:	89 f0                	mov    %esi,%eax
  800e0c:	c1 e8 0c             	shr    $0xc,%eax
  800e0f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e16:	f6 c4 08             	test   $0x8,%ah
  800e19:	74 7d                	je     800e98 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e1b:	e8 a7 fd ff ff       	call   800bc7 <sys_getenvid>
  800e20:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e22:	83 ec 04             	sub    $0x4,%esp
  800e25:	6a 07                	push   $0x7
  800e27:	68 00 f0 7f 00       	push   $0x7ff000
  800e2c:	50                   	push   %eax
  800e2d:	e8 d3 fd ff ff       	call   800c05 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e32:	83 c4 10             	add    $0x10,%esp
  800e35:	85 c0                	test   %eax,%eax
  800e37:	78 73                	js     800eac <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e39:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e3f:	83 ec 04             	sub    $0x4,%esp
  800e42:	68 00 10 00 00       	push   $0x1000
  800e47:	56                   	push   %esi
  800e48:	68 00 f0 7f 00       	push   $0x7ff000
  800e4d:	e8 4d fb ff ff       	call   80099f <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e52:	83 c4 08             	add    $0x8,%esp
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
  800e57:	e8 2e fe ff ff       	call   800c8a <sys_page_unmap>
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	78 5b                	js     800ebe <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	6a 07                	push   $0x7
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
  800e6a:	68 00 f0 7f 00       	push   $0x7ff000
  800e6f:	53                   	push   %ebx
  800e70:	e8 d3 fd ff ff       	call   800c48 <sys_page_map>
  800e75:	83 c4 20             	add    $0x20,%esp
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	78 54                	js     800ed0 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e7c:	83 ec 08             	sub    $0x8,%esp
  800e7f:	68 00 f0 7f 00       	push   $0x7ff000
  800e84:	53                   	push   %ebx
  800e85:	e8 00 fe ff ff       	call   800c8a <sys_page_unmap>
  800e8a:	83 c4 10             	add    $0x10,%esp
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	78 51                	js     800ee2 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e98:	83 ec 04             	sub    $0x4,%esp
  800e9b:	68 ac 24 80 00       	push   $0x8024ac
  800ea0:	6a 1d                	push   $0x1d
  800ea2:	68 28 25 80 00       	push   $0x802528
  800ea7:	e8 a8 f2 ff ff       	call   800154 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800eac:	50                   	push   %eax
  800ead:	68 e4 24 80 00       	push   $0x8024e4
  800eb2:	6a 29                	push   $0x29
  800eb4:	68 28 25 80 00       	push   $0x802528
  800eb9:	e8 96 f2 ff ff       	call   800154 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ebe:	50                   	push   %eax
  800ebf:	68 08 25 80 00       	push   $0x802508
  800ec4:	6a 2e                	push   $0x2e
  800ec6:	68 28 25 80 00       	push   $0x802528
  800ecb:	e8 84 f2 ff ff       	call   800154 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800ed0:	50                   	push   %eax
  800ed1:	68 33 25 80 00       	push   $0x802533
  800ed6:	6a 30                	push   $0x30
  800ed8:	68 28 25 80 00       	push   $0x802528
  800edd:	e8 72 f2 ff ff       	call   800154 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ee2:	50                   	push   %eax
  800ee3:	68 08 25 80 00       	push   $0x802508
  800ee8:	6a 32                	push   $0x32
  800eea:	68 28 25 80 00       	push   $0x802528
  800eef:	e8 60 f2 ff ff       	call   800154 <_panic>

00800ef4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800efd:	68 f6 0d 80 00       	push   $0x800df6
  800f02:	e8 02 0f 00 00       	call   801e09 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f07:	b8 07 00 00 00       	mov    $0x7,%eax
  800f0c:	cd 30                	int    $0x30
  800f0e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	78 2d                	js     800f45 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f18:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f1d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f21:	75 73                	jne    800f96 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f23:	e8 9f fc ff ff       	call   800bc7 <sys_getenvid>
  800f28:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f2d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f30:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f35:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800f3a:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f45:	50                   	push   %eax
  800f46:	68 51 25 80 00       	push   $0x802551
  800f4b:	6a 78                	push   $0x78
  800f4d:	68 28 25 80 00       	push   $0x802528
  800f52:	e8 fd f1 ff ff       	call   800154 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	ff 75 e4             	push   -0x1c(%ebp)
  800f5d:	57                   	push   %edi
  800f5e:	ff 75 dc             	push   -0x24(%ebp)
  800f61:	57                   	push   %edi
  800f62:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f65:	56                   	push   %esi
  800f66:	e8 dd fc ff ff       	call   800c48 <sys_page_map>
	if(r<0) return r;
  800f6b:	83 c4 20             	add    $0x20,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 cb                	js     800f3d <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f72:	83 ec 0c             	sub    $0xc,%esp
  800f75:	ff 75 e4             	push   -0x1c(%ebp)
  800f78:	57                   	push   %edi
  800f79:	56                   	push   %esi
  800f7a:	57                   	push   %edi
  800f7b:	56                   	push   %esi
  800f7c:	e8 c7 fc ff ff       	call   800c48 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f81:	83 c4 20             	add    $0x20,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	78 76                	js     800ffe <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f88:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f8e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f94:	74 75                	je     80100b <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f96:	89 d8                	mov    %ebx,%eax
  800f98:	c1 e8 16             	shr    $0x16,%eax
  800f9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa2:	a8 01                	test   $0x1,%al
  800fa4:	74 e2                	je     800f88 <fork+0x94>
  800fa6:	89 de                	mov    %ebx,%esi
  800fa8:	c1 ee 0c             	shr    $0xc,%esi
  800fab:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb2:	a8 01                	test   $0x1,%al
  800fb4:	74 d2                	je     800f88 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  800fb6:	e8 0c fc ff ff       	call   800bc7 <sys_getenvid>
  800fbb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800fbe:	89 f7                	mov    %esi,%edi
  800fc0:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800fc3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fca:	89 c1                	mov    %eax,%ecx
  800fcc:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800fd2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800fd5:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800fdc:	f6 c6 04             	test   $0x4,%dh
  800fdf:	0f 85 72 ff ff ff    	jne    800f57 <fork+0x63>
		perm &= ~PTE_W;
  800fe5:	25 05 0e 00 00       	and    $0xe05,%eax
  800fea:	80 cc 08             	or     $0x8,%ah
  800fed:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800ff3:	0f 44 c1             	cmove  %ecx,%eax
  800ff6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ff9:	e9 59 ff ff ff       	jmp    800f57 <fork+0x63>
  800ffe:	ba 00 00 00 00       	mov    $0x0,%edx
  801003:	0f 4f c2             	cmovg  %edx,%eax
  801006:	e9 32 ff ff ff       	jmp    800f3d <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80100b:	83 ec 04             	sub    $0x4,%esp
  80100e:	6a 07                	push   $0x7
  801010:	68 00 f0 bf ee       	push   $0xeebff000
  801015:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801018:	57                   	push   %edi
  801019:	e8 e7 fb ff ff       	call   800c05 <sys_page_alloc>
	if(r<0) return r;
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	0f 88 14 ff ff ff    	js     800f3d <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801029:	83 ec 08             	sub    $0x8,%esp
  80102c:	68 7f 1e 80 00       	push   $0x801e7f
  801031:	57                   	push   %edi
  801032:	e8 19 fd ff ff       	call   800d50 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	0f 88 fb fe ff ff    	js     800f3d <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801042:	83 ec 08             	sub    $0x8,%esp
  801045:	6a 02                	push   $0x2
  801047:	57                   	push   %edi
  801048:	e8 7f fc ff ff       	call   800ccc <sys_env_set_status>
	if(r<0) return r;
  80104d:	83 c4 10             	add    $0x10,%esp
	return envid;
  801050:	85 c0                	test   %eax,%eax
  801052:	0f 49 c7             	cmovns %edi,%eax
  801055:	e9 e3 fe ff ff       	jmp    800f3d <fork+0x49>

0080105a <sfork>:

// Challenge!
int
sfork(void)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801060:	68 61 25 80 00       	push   $0x802561
  801065:	68 a1 00 00 00       	push   $0xa1
  80106a:	68 28 25 80 00       	push   $0x802528
  80106f:	e8 e0 f0 ff ff       	call   800154 <_panic>

00801074 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	8b 75 08             	mov    0x8(%ebp),%esi
  80107c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801082:	85 c0                	test   %eax,%eax
  801084:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801089:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	50                   	push   %eax
  801090:	e8 20 fd ff ff       	call   800db5 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	85 f6                	test   %esi,%esi
  80109a:	74 14                	je     8010b0 <ipc_recv+0x3c>
  80109c:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	78 09                	js     8010ae <ipc_recv+0x3a>
  8010a5:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010ab:	8b 52 74             	mov    0x74(%edx),%edx
  8010ae:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8010b0:	85 db                	test   %ebx,%ebx
  8010b2:	74 14                	je     8010c8 <ipc_recv+0x54>
  8010b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 09                	js     8010c6 <ipc_recv+0x52>
  8010bd:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010c3:	8b 52 78             	mov    0x78(%edx),%edx
  8010c6:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 08                	js     8010d4 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8010cc:	a1 00 40 80 00       	mov    0x804000,%eax
  8010d1:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8010ed:	85 db                	test   %ebx,%ebx
  8010ef:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010f4:	0f 44 d8             	cmove  %eax,%ebx
  8010f7:	eb 05                	jmp    8010fe <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8010f9:	e8 e8 fa ff ff       	call   800be6 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8010fe:	ff 75 14             	push   0x14(%ebp)
  801101:	53                   	push   %ebx
  801102:	56                   	push   %esi
  801103:	57                   	push   %edi
  801104:	e8 89 fc ff ff       	call   800d92 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80110f:	74 e8                	je     8010f9 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801111:	85 c0                	test   %eax,%eax
  801113:	78 08                	js     80111d <ipc_send+0x42>
	}while (r<0);

}
  801115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801118:	5b                   	pop    %ebx
  801119:	5e                   	pop    %esi
  80111a:	5f                   	pop    %edi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80111d:	50                   	push   %eax
  80111e:	68 77 25 80 00       	push   $0x802577
  801123:	6a 3d                	push   $0x3d
  801125:	68 8b 25 80 00       	push   $0x80258b
  80112a:	e8 25 f0 ff ff       	call   800154 <_panic>

0080112f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801135:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80113a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80113d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801143:	8b 52 50             	mov    0x50(%edx),%edx
  801146:	39 ca                	cmp    %ecx,%edx
  801148:	74 11                	je     80115b <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80114a:	83 c0 01             	add    $0x1,%eax
  80114d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801152:	75 e6                	jne    80113a <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801154:	b8 00 00 00 00       	mov    $0x0,%eax
  801159:	eb 0b                	jmp    801166 <ipc_find_env+0x37>
			return envs[i].env_id;
  80115b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80115e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801163:	8b 40 48             	mov    0x48(%eax),%eax
}
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
  80116e:	05 00 00 00 30       	add    $0x30000000,%eax
  801173:	c1 e8 0c             	shr    $0xc,%eax
}
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801183:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801188:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801197:	89 c2                	mov    %eax,%edx
  801199:	c1 ea 16             	shr    $0x16,%edx
  80119c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a3:	f6 c2 01             	test   $0x1,%dl
  8011a6:	74 29                	je     8011d1 <fd_alloc+0x42>
  8011a8:	89 c2                	mov    %eax,%edx
  8011aa:	c1 ea 0c             	shr    $0xc,%edx
  8011ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b4:	f6 c2 01             	test   $0x1,%dl
  8011b7:	74 18                	je     8011d1 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011b9:	05 00 10 00 00       	add    $0x1000,%eax
  8011be:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c3:	75 d2                	jne    801197 <fd_alloc+0x8>
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8011ca:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8011cf:	eb 05                	jmp    8011d6 <fd_alloc+0x47>
			return 0;
  8011d1:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8011d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d9:	89 02                	mov    %eax,(%edx)
}
  8011db:	89 c8                	mov    %ecx,%eax
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011e5:	83 f8 1f             	cmp    $0x1f,%eax
  8011e8:	77 30                	ja     80121a <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ea:	c1 e0 0c             	shl    $0xc,%eax
  8011ed:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011f2:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8011f8:	f6 c2 01             	test   $0x1,%dl
  8011fb:	74 24                	je     801221 <fd_lookup+0x42>
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	c1 ea 0c             	shr    $0xc,%edx
  801202:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801209:	f6 c2 01             	test   $0x1,%dl
  80120c:	74 1a                	je     801228 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80120e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801211:	89 02                	mov    %eax,(%edx)
	return 0;
  801213:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    
		return -E_INVAL;
  80121a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121f:	eb f7                	jmp    801218 <fd_lookup+0x39>
		return -E_INVAL;
  801221:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801226:	eb f0                	jmp    801218 <fd_lookup+0x39>
  801228:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122d:	eb e9                	jmp    801218 <fd_lookup+0x39>

0080122f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	53                   	push   %ebx
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	8b 55 08             	mov    0x8(%ebp),%edx
  801239:	b8 14 26 80 00       	mov    $0x802614,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  80123e:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801243:	39 13                	cmp    %edx,(%ebx)
  801245:	74 32                	je     801279 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  801247:	83 c0 04             	add    $0x4,%eax
  80124a:	8b 18                	mov    (%eax),%ebx
  80124c:	85 db                	test   %ebx,%ebx
  80124e:	75 f3                	jne    801243 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801250:	a1 00 40 80 00       	mov    0x804000,%eax
  801255:	8b 40 48             	mov    0x48(%eax),%eax
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	52                   	push   %edx
  80125c:	50                   	push   %eax
  80125d:	68 98 25 80 00       	push   $0x802598
  801262:	e8 c8 ef ff ff       	call   80022f <cprintf>
	*dev = 0;
	return -E_INVAL;
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80126f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801272:	89 1a                	mov    %ebx,(%edx)
}
  801274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801277:	c9                   	leave  
  801278:	c3                   	ret    
			return 0;
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
  80127e:	eb ef                	jmp    80126f <dev_lookup+0x40>

00801280 <fd_close>:
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 24             	sub    $0x24,%esp
  801289:	8b 75 08             	mov    0x8(%ebp),%esi
  80128c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80128f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801292:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801293:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801299:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129c:	50                   	push   %eax
  80129d:	e8 3d ff ff ff       	call   8011df <fd_lookup>
  8012a2:	89 c3                	mov    %eax,%ebx
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 05                	js     8012b0 <fd_close+0x30>
	    || fd != fd2)
  8012ab:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012ae:	74 16                	je     8012c6 <fd_close+0x46>
		return (must_exist ? r : 0);
  8012b0:	89 f8                	mov    %edi,%eax
  8012b2:	84 c0                	test   %al,%al
  8012b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b9:	0f 44 d8             	cmove  %eax,%ebx
}
  8012bc:	89 d8                	mov    %ebx,%eax
  8012be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5f                   	pop    %edi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	ff 36                	push   (%esi)
  8012cf:	e8 5b ff ff ff       	call   80122f <dev_lookup>
  8012d4:	89 c3                	mov    %eax,%ebx
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 1a                	js     8012f7 <fd_close+0x77>
		if (dev->dev_close)
  8012dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e0:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	74 0b                	je     8012f7 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8012ec:	83 ec 0c             	sub    $0xc,%esp
  8012ef:	56                   	push   %esi
  8012f0:	ff d0                	call   *%eax
  8012f2:	89 c3                	mov    %eax,%ebx
  8012f4:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012f7:	83 ec 08             	sub    $0x8,%esp
  8012fa:	56                   	push   %esi
  8012fb:	6a 00                	push   $0x0
  8012fd:	e8 88 f9 ff ff       	call   800c8a <sys_page_unmap>
	return r;
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	eb b5                	jmp    8012bc <fd_close+0x3c>

00801307 <close>:

int
close(int fdnum)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80130d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	ff 75 08             	push   0x8(%ebp)
  801314:	e8 c6 fe ff ff       	call   8011df <fd_lookup>
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	79 02                	jns    801322 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801320:	c9                   	leave  
  801321:	c3                   	ret    
		return fd_close(fd, 1);
  801322:	83 ec 08             	sub    $0x8,%esp
  801325:	6a 01                	push   $0x1
  801327:	ff 75 f4             	push   -0xc(%ebp)
  80132a:	e8 51 ff ff ff       	call   801280 <fd_close>
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	eb ec                	jmp    801320 <close+0x19>

00801334 <close_all>:

void
close_all(void)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	53                   	push   %ebx
  801338:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80133b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801340:	83 ec 0c             	sub    $0xc,%esp
  801343:	53                   	push   %ebx
  801344:	e8 be ff ff ff       	call   801307 <close>
	for (i = 0; i < MAXFD; i++)
  801349:	83 c3 01             	add    $0x1,%ebx
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	83 fb 20             	cmp    $0x20,%ebx
  801352:	75 ec                	jne    801340 <close_all+0xc>
}
  801354:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	57                   	push   %edi
  80135d:	56                   	push   %esi
  80135e:	53                   	push   %ebx
  80135f:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801362:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	ff 75 08             	push   0x8(%ebp)
  801369:	e8 71 fe ff ff       	call   8011df <fd_lookup>
  80136e:	89 c3                	mov    %eax,%ebx
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 7f                	js     8013f6 <dup+0x9d>
		return r;
	close(newfdnum);
  801377:	83 ec 0c             	sub    $0xc,%esp
  80137a:	ff 75 0c             	push   0xc(%ebp)
  80137d:	e8 85 ff ff ff       	call   801307 <close>

	newfd = INDEX2FD(newfdnum);
  801382:	8b 75 0c             	mov    0xc(%ebp),%esi
  801385:	c1 e6 0c             	shl    $0xc,%esi
  801388:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80138e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801391:	89 3c 24             	mov    %edi,(%esp)
  801394:	e8 df fd ff ff       	call   801178 <fd2data>
  801399:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80139b:	89 34 24             	mov    %esi,(%esp)
  80139e:	e8 d5 fd ff ff       	call   801178 <fd2data>
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013a9:	89 d8                	mov    %ebx,%eax
  8013ab:	c1 e8 16             	shr    $0x16,%eax
  8013ae:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013b5:	a8 01                	test   $0x1,%al
  8013b7:	74 11                	je     8013ca <dup+0x71>
  8013b9:	89 d8                	mov    %ebx,%eax
  8013bb:	c1 e8 0c             	shr    $0xc,%eax
  8013be:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c5:	f6 c2 01             	test   $0x1,%dl
  8013c8:	75 36                	jne    801400 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ca:	89 f8                	mov    %edi,%eax
  8013cc:	c1 e8 0c             	shr    $0xc,%eax
  8013cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013de:	50                   	push   %eax
  8013df:	56                   	push   %esi
  8013e0:	6a 00                	push   $0x0
  8013e2:	57                   	push   %edi
  8013e3:	6a 00                	push   $0x0
  8013e5:	e8 5e f8 ff ff       	call   800c48 <sys_page_map>
  8013ea:	89 c3                	mov    %eax,%ebx
  8013ec:	83 c4 20             	add    $0x20,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 33                	js     801426 <dup+0xcd>
		goto err;

	return newfdnum;
  8013f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013f6:	89 d8                	mov    %ebx,%eax
  8013f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	5f                   	pop    %edi
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801400:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801407:	83 ec 0c             	sub    $0xc,%esp
  80140a:	25 07 0e 00 00       	and    $0xe07,%eax
  80140f:	50                   	push   %eax
  801410:	ff 75 d4             	push   -0x2c(%ebp)
  801413:	6a 00                	push   $0x0
  801415:	53                   	push   %ebx
  801416:	6a 00                	push   $0x0
  801418:	e8 2b f8 ff ff       	call   800c48 <sys_page_map>
  80141d:	89 c3                	mov    %eax,%ebx
  80141f:	83 c4 20             	add    $0x20,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	79 a4                	jns    8013ca <dup+0x71>
	sys_page_unmap(0, newfd);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	56                   	push   %esi
  80142a:	6a 00                	push   $0x0
  80142c:	e8 59 f8 ff ff       	call   800c8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801431:	83 c4 08             	add    $0x8,%esp
  801434:	ff 75 d4             	push   -0x2c(%ebp)
  801437:	6a 00                	push   $0x0
  801439:	e8 4c f8 ff ff       	call   800c8a <sys_page_unmap>
	return r;
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	eb b3                	jmp    8013f6 <dup+0x9d>

00801443 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	56                   	push   %esi
  801447:	53                   	push   %ebx
  801448:	83 ec 18             	sub    $0x18,%esp
  80144b:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	56                   	push   %esi
  801453:	e8 87 fd ff ff       	call   8011df <fd_lookup>
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 3c                	js     80149b <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145f:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	ff 33                	push   (%ebx)
  80146b:	e8 bf fd ff ff       	call   80122f <dev_lookup>
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 24                	js     80149b <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801477:	8b 43 08             	mov    0x8(%ebx),%eax
  80147a:	83 e0 03             	and    $0x3,%eax
  80147d:	83 f8 01             	cmp    $0x1,%eax
  801480:	74 20                	je     8014a2 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801482:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801485:	8b 40 08             	mov    0x8(%eax),%eax
  801488:	85 c0                	test   %eax,%eax
  80148a:	74 37                	je     8014c3 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	ff 75 10             	push   0x10(%ebp)
  801492:	ff 75 0c             	push   0xc(%ebp)
  801495:	53                   	push   %ebx
  801496:	ff d0                	call   *%eax
  801498:	83 c4 10             	add    $0x10,%esp
}
  80149b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a2:	a1 00 40 80 00       	mov    0x804000,%eax
  8014a7:	8b 40 48             	mov    0x48(%eax),%eax
  8014aa:	83 ec 04             	sub    $0x4,%esp
  8014ad:	56                   	push   %esi
  8014ae:	50                   	push   %eax
  8014af:	68 d9 25 80 00       	push   $0x8025d9
  8014b4:	e8 76 ed ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c1:	eb d8                	jmp    80149b <read+0x58>
		return -E_NOT_SUPP;
  8014c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014c8:	eb d1                	jmp    80149b <read+0x58>

008014ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	57                   	push   %edi
  8014ce:	56                   	push   %esi
  8014cf:	53                   	push   %ebx
  8014d0:	83 ec 0c             	sub    $0xc,%esp
  8014d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014de:	eb 02                	jmp    8014e2 <readn+0x18>
  8014e0:	01 c3                	add    %eax,%ebx
  8014e2:	39 f3                	cmp    %esi,%ebx
  8014e4:	73 21                	jae    801507 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e6:	83 ec 04             	sub    $0x4,%esp
  8014e9:	89 f0                	mov    %esi,%eax
  8014eb:	29 d8                	sub    %ebx,%eax
  8014ed:	50                   	push   %eax
  8014ee:	89 d8                	mov    %ebx,%eax
  8014f0:	03 45 0c             	add    0xc(%ebp),%eax
  8014f3:	50                   	push   %eax
  8014f4:	57                   	push   %edi
  8014f5:	e8 49 ff ff ff       	call   801443 <read>
		if (m < 0)
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 04                	js     801505 <readn+0x3b>
			return m;
		if (m == 0)
  801501:	75 dd                	jne    8014e0 <readn+0x16>
  801503:	eb 02                	jmp    801507 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801505:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801507:	89 d8                	mov    %ebx,%eax
  801509:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150c:	5b                   	pop    %ebx
  80150d:	5e                   	pop    %esi
  80150e:	5f                   	pop    %edi
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	56                   	push   %esi
  801515:	53                   	push   %ebx
  801516:	83 ec 18             	sub    $0x18,%esp
  801519:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	53                   	push   %ebx
  801521:	e8 b9 fc ff ff       	call   8011df <fd_lookup>
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 37                	js     801564 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801536:	50                   	push   %eax
  801537:	ff 36                	push   (%esi)
  801539:	e8 f1 fc ff ff       	call   80122f <dev_lookup>
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 1f                	js     801564 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801545:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801549:	74 20                	je     80156b <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154e:	8b 40 0c             	mov    0xc(%eax),%eax
  801551:	85 c0                	test   %eax,%eax
  801553:	74 37                	je     80158c <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	ff 75 10             	push   0x10(%ebp)
  80155b:	ff 75 0c             	push   0xc(%ebp)
  80155e:	56                   	push   %esi
  80155f:	ff d0                	call   *%eax
  801561:	83 c4 10             	add    $0x10,%esp
}
  801564:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801567:	5b                   	pop    %ebx
  801568:	5e                   	pop    %esi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156b:	a1 00 40 80 00       	mov    0x804000,%eax
  801570:	8b 40 48             	mov    0x48(%eax),%eax
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	53                   	push   %ebx
  801577:	50                   	push   %eax
  801578:	68 f5 25 80 00       	push   $0x8025f5
  80157d:	e8 ad ec ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158a:	eb d8                	jmp    801564 <write+0x53>
		return -E_NOT_SUPP;
  80158c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801591:	eb d1                	jmp    801564 <write+0x53>

00801593 <seek>:

int
seek(int fdnum, off_t offset)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801599:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	ff 75 08             	push   0x8(%ebp)
  8015a0:	e8 3a fc ff ff       	call   8011df <fd_lookup>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 0e                	js     8015ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	56                   	push   %esi
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 18             	sub    $0x18,%esp
  8015c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	53                   	push   %ebx
  8015cc:	e8 0e fc ff ff       	call   8011df <fd_lookup>
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 34                	js     80160c <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d8:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	ff 36                	push   (%esi)
  8015e4:	e8 46 fc ff ff       	call   80122f <dev_lookup>
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 1c                	js     80160c <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f0:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015f4:	74 1d                	je     801613 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f9:	8b 40 18             	mov    0x18(%eax),%eax
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	74 34                	je     801634 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	ff 75 0c             	push   0xc(%ebp)
  801606:	56                   	push   %esi
  801607:	ff d0                	call   *%eax
  801609:	83 c4 10             	add    $0x10,%esp
}
  80160c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    
			thisenv->env_id, fdnum);
  801613:	a1 00 40 80 00       	mov    0x804000,%eax
  801618:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161b:	83 ec 04             	sub    $0x4,%esp
  80161e:	53                   	push   %ebx
  80161f:	50                   	push   %eax
  801620:	68 b8 25 80 00       	push   $0x8025b8
  801625:	e8 05 ec ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801632:	eb d8                	jmp    80160c <ftruncate+0x50>
		return -E_NOT_SUPP;
  801634:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801639:	eb d1                	jmp    80160c <ftruncate+0x50>

0080163b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	56                   	push   %esi
  80163f:	53                   	push   %ebx
  801640:	83 ec 18             	sub    $0x18,%esp
  801643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801646:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	ff 75 08             	push   0x8(%ebp)
  80164d:	e8 8d fb ff ff       	call   8011df <fd_lookup>
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	78 49                	js     8016a2 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801659:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	ff 36                	push   (%esi)
  801665:	e8 c5 fb ff ff       	call   80122f <dev_lookup>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 31                	js     8016a2 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801674:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801678:	74 2f                	je     8016a9 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80167a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80167d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801684:	00 00 00 
	stat->st_isdir = 0;
  801687:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80168e:	00 00 00 
	stat->st_dev = dev;
  801691:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	53                   	push   %ebx
  80169b:	56                   	push   %esi
  80169c:	ff 50 14             	call   *0x14(%eax)
  80169f:	83 c4 10             	add    $0x10,%esp
}
  8016a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a5:	5b                   	pop    %ebx
  8016a6:	5e                   	pop    %esi
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    
		return -E_NOT_SUPP;
  8016a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016ae:	eb f2                	jmp    8016a2 <fstat+0x67>

008016b0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	6a 00                	push   $0x0
  8016ba:	ff 75 08             	push   0x8(%ebp)
  8016bd:	e8 e4 01 00 00       	call   8018a6 <open>
  8016c2:	89 c3                	mov    %eax,%ebx
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 1b                	js     8016e6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016cb:	83 ec 08             	sub    $0x8,%esp
  8016ce:	ff 75 0c             	push   0xc(%ebp)
  8016d1:	50                   	push   %eax
  8016d2:	e8 64 ff ff ff       	call   80163b <fstat>
  8016d7:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d9:	89 1c 24             	mov    %ebx,(%esp)
  8016dc:	e8 26 fc ff ff       	call   801307 <close>
	return r;
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	89 f3                	mov    %esi,%ebx
}
  8016e6:	89 d8                	mov    %ebx,%eax
  8016e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016eb:	5b                   	pop    %ebx
  8016ec:	5e                   	pop    %esi
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
  8016f4:	89 c6                	mov    %eax,%esi
  8016f6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016ff:	74 27                	je     801728 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801701:	6a 07                	push   $0x7
  801703:	68 00 50 80 00       	push   $0x805000
  801708:	56                   	push   %esi
  801709:	ff 35 00 60 80 00    	push   0x806000
  80170f:	e8 c7 f9 ff ff       	call   8010db <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801714:	83 c4 0c             	add    $0xc,%esp
  801717:	6a 00                	push   $0x0
  801719:	53                   	push   %ebx
  80171a:	6a 00                	push   $0x0
  80171c:	e8 53 f9 ff ff       	call   801074 <ipc_recv>
}
  801721:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801724:	5b                   	pop    %ebx
  801725:	5e                   	pop    %esi
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801728:	83 ec 0c             	sub    $0xc,%esp
  80172b:	6a 01                	push   $0x1
  80172d:	e8 fd f9 ff ff       	call   80112f <ipc_find_env>
  801732:	a3 00 60 80 00       	mov    %eax,0x806000
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	eb c5                	jmp    801701 <fsipc+0x12>

0080173c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	8b 40 0c             	mov    0xc(%eax),%eax
  801748:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80174d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801750:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801755:	ba 00 00 00 00       	mov    $0x0,%edx
  80175a:	b8 02 00 00 00       	mov    $0x2,%eax
  80175f:	e8 8b ff ff ff       	call   8016ef <fsipc>
}
  801764:	c9                   	leave  
  801765:	c3                   	ret    

00801766 <devfile_flush>:
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80176c:	8b 45 08             	mov    0x8(%ebp),%eax
  80176f:	8b 40 0c             	mov    0xc(%eax),%eax
  801772:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801777:	ba 00 00 00 00       	mov    $0x0,%edx
  80177c:	b8 06 00 00 00       	mov    $0x6,%eax
  801781:	e8 69 ff ff ff       	call   8016ef <fsipc>
}
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <devfile_stat>:
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	83 ec 04             	sub    $0x4,%esp
  80178f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	8b 40 0c             	mov    0xc(%eax),%eax
  801798:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80179d:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a7:	e8 43 ff ff ff       	call   8016ef <fsipc>
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 2c                	js     8017dc <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	68 00 50 80 00       	push   $0x805000
  8017b8:	53                   	push   %ebx
  8017b9:	e8 4b f0 ff ff       	call   800809 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017be:	a1 80 50 80 00       	mov    0x805080,%eax
  8017c3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c9:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ce:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <devfile_write>:
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ea:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017ef:	39 d0                	cmp    %edx,%eax
  8017f1:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fa:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801800:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801805:	50                   	push   %eax
  801806:	ff 75 0c             	push   0xc(%ebp)
  801809:	68 08 50 80 00       	push   $0x805008
  80180e:	e8 8c f1 ff ff       	call   80099f <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801813:	ba 00 00 00 00       	mov    $0x0,%edx
  801818:	b8 04 00 00 00       	mov    $0x4,%eax
  80181d:	e8 cd fe ff ff       	call   8016ef <fsipc>
}
  801822:	c9                   	leave  
  801823:	c3                   	ret    

00801824 <devfile_read>:
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	8b 40 0c             	mov    0xc(%eax),%eax
  801832:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801837:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
  801842:	b8 03 00 00 00       	mov    $0x3,%eax
  801847:	e8 a3 fe ff ff       	call   8016ef <fsipc>
  80184c:	89 c3                	mov    %eax,%ebx
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 1f                	js     801871 <devfile_read+0x4d>
	assert(r <= n);
  801852:	39 f0                	cmp    %esi,%eax
  801854:	77 24                	ja     80187a <devfile_read+0x56>
	assert(r <= PGSIZE);
  801856:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80185b:	7f 33                	jg     801890 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80185d:	83 ec 04             	sub    $0x4,%esp
  801860:	50                   	push   %eax
  801861:	68 00 50 80 00       	push   $0x805000
  801866:	ff 75 0c             	push   0xc(%ebp)
  801869:	e8 31 f1 ff ff       	call   80099f <memmove>
	return r;
  80186e:	83 c4 10             	add    $0x10,%esp
}
  801871:	89 d8                	mov    %ebx,%eax
  801873:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801876:	5b                   	pop    %ebx
  801877:	5e                   	pop    %esi
  801878:	5d                   	pop    %ebp
  801879:	c3                   	ret    
	assert(r <= n);
  80187a:	68 24 26 80 00       	push   $0x802624
  80187f:	68 2b 26 80 00       	push   $0x80262b
  801884:	6a 7c                	push   $0x7c
  801886:	68 40 26 80 00       	push   $0x802640
  80188b:	e8 c4 e8 ff ff       	call   800154 <_panic>
	assert(r <= PGSIZE);
  801890:	68 4b 26 80 00       	push   $0x80264b
  801895:	68 2b 26 80 00       	push   $0x80262b
  80189a:	6a 7d                	push   $0x7d
  80189c:	68 40 26 80 00       	push   $0x802640
  8018a1:	e8 ae e8 ff ff       	call   800154 <_panic>

008018a6 <open>:
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	56                   	push   %esi
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 1c             	sub    $0x1c,%esp
  8018ae:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018b1:	56                   	push   %esi
  8018b2:	e8 17 ef ff ff       	call   8007ce <strlen>
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018bf:	7f 6c                	jg     80192d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018c1:	83 ec 0c             	sub    $0xc,%esp
  8018c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c7:	50                   	push   %eax
  8018c8:	e8 c2 f8 ff ff       	call   80118f <fd_alloc>
  8018cd:	89 c3                	mov    %eax,%ebx
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 3c                	js     801912 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	56                   	push   %esi
  8018da:	68 00 50 80 00       	push   $0x805000
  8018df:	e8 25 ef ff ff       	call   800809 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e7:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f4:	e8 f6 fd ff ff       	call   8016ef <fsipc>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 19                	js     80191b <open+0x75>
	return fd2num(fd);
  801902:	83 ec 0c             	sub    $0xc,%esp
  801905:	ff 75 f4             	push   -0xc(%ebp)
  801908:	e8 5b f8 ff ff       	call   801168 <fd2num>
  80190d:	89 c3                	mov    %eax,%ebx
  80190f:	83 c4 10             	add    $0x10,%esp
}
  801912:	89 d8                	mov    %ebx,%eax
  801914:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801917:	5b                   	pop    %ebx
  801918:	5e                   	pop    %esi
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    
		fd_close(fd, 0);
  80191b:	83 ec 08             	sub    $0x8,%esp
  80191e:	6a 00                	push   $0x0
  801920:	ff 75 f4             	push   -0xc(%ebp)
  801923:	e8 58 f9 ff ff       	call   801280 <fd_close>
		return r;
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	eb e5                	jmp    801912 <open+0x6c>
		return -E_BAD_PATH;
  80192d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801932:	eb de                	jmp    801912 <open+0x6c>

00801934 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80193a:	ba 00 00 00 00       	mov    $0x0,%edx
  80193f:	b8 08 00 00 00       	mov    $0x8,%eax
  801944:	e8 a6 fd ff ff       	call   8016ef <fsipc>
}
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	56                   	push   %esi
  80194f:	53                   	push   %ebx
  801950:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	ff 75 08             	push   0x8(%ebp)
  801959:	e8 1a f8 ff ff       	call   801178 <fd2data>
  80195e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801960:	83 c4 08             	add    $0x8,%esp
  801963:	68 57 26 80 00       	push   $0x802657
  801968:	53                   	push   %ebx
  801969:	e8 9b ee ff ff       	call   800809 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80196e:	8b 46 04             	mov    0x4(%esi),%eax
  801971:	2b 06                	sub    (%esi),%eax
  801973:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801979:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801980:	00 00 00 
	stat->st_dev = &devpipe;
  801983:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80198a:	30 80 00 
	return 0;
}
  80198d:	b8 00 00 00 00       	mov    $0x0,%eax
  801992:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801995:	5b                   	pop    %ebx
  801996:	5e                   	pop    %esi
  801997:	5d                   	pop    %ebp
  801998:	c3                   	ret    

00801999 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	53                   	push   %ebx
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a3:	53                   	push   %ebx
  8019a4:	6a 00                	push   $0x0
  8019a6:	e8 df f2 ff ff       	call   800c8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ab:	89 1c 24             	mov    %ebx,(%esp)
  8019ae:	e8 c5 f7 ff ff       	call   801178 <fd2data>
  8019b3:	83 c4 08             	add    $0x8,%esp
  8019b6:	50                   	push   %eax
  8019b7:	6a 00                	push   $0x0
  8019b9:	e8 cc f2 ff ff       	call   800c8a <sys_page_unmap>
}
  8019be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <_pipeisclosed>:
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	57                   	push   %edi
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
  8019c9:	83 ec 1c             	sub    $0x1c,%esp
  8019cc:	89 c7                	mov    %eax,%edi
  8019ce:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8019d0:	a1 00 40 80 00       	mov    0x804000,%eax
  8019d5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	57                   	push   %edi
  8019dc:	e8 c4 04 00 00       	call   801ea5 <pageref>
  8019e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019e4:	89 34 24             	mov    %esi,(%esp)
  8019e7:	e8 b9 04 00 00       	call   801ea5 <pageref>
		nn = thisenv->env_runs;
  8019ec:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8019f2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	39 cb                	cmp    %ecx,%ebx
  8019fa:	74 1b                	je     801a17 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8019fc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019ff:	75 cf                	jne    8019d0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a01:	8b 42 58             	mov    0x58(%edx),%eax
  801a04:	6a 01                	push   $0x1
  801a06:	50                   	push   %eax
  801a07:	53                   	push   %ebx
  801a08:	68 5e 26 80 00       	push   $0x80265e
  801a0d:	e8 1d e8 ff ff       	call   80022f <cprintf>
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	eb b9                	jmp    8019d0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a17:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a1a:	0f 94 c0             	sete   %al
  801a1d:	0f b6 c0             	movzbl %al,%eax
}
  801a20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a23:	5b                   	pop    %ebx
  801a24:	5e                   	pop    %esi
  801a25:	5f                   	pop    %edi
  801a26:	5d                   	pop    %ebp
  801a27:	c3                   	ret    

00801a28 <devpipe_write>:
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	57                   	push   %edi
  801a2c:	56                   	push   %esi
  801a2d:	53                   	push   %ebx
  801a2e:	83 ec 28             	sub    $0x28,%esp
  801a31:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a34:	56                   	push   %esi
  801a35:	e8 3e f7 ff ff       	call   801178 <fd2data>
  801a3a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	bf 00 00 00 00       	mov    $0x0,%edi
  801a44:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a47:	75 09                	jne    801a52 <devpipe_write+0x2a>
	return i;
  801a49:	89 f8                	mov    %edi,%eax
  801a4b:	eb 23                	jmp    801a70 <devpipe_write+0x48>
			sys_yield();
  801a4d:	e8 94 f1 ff ff       	call   800be6 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a52:	8b 43 04             	mov    0x4(%ebx),%eax
  801a55:	8b 0b                	mov    (%ebx),%ecx
  801a57:	8d 51 20             	lea    0x20(%ecx),%edx
  801a5a:	39 d0                	cmp    %edx,%eax
  801a5c:	72 1a                	jb     801a78 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801a5e:	89 da                	mov    %ebx,%edx
  801a60:	89 f0                	mov    %esi,%eax
  801a62:	e8 5c ff ff ff       	call   8019c3 <_pipeisclosed>
  801a67:	85 c0                	test   %eax,%eax
  801a69:	74 e2                	je     801a4d <devpipe_write+0x25>
				return 0;
  801a6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a73:	5b                   	pop    %ebx
  801a74:	5e                   	pop    %esi
  801a75:	5f                   	pop    %edi
  801a76:	5d                   	pop    %ebp
  801a77:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a7f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a82:	89 c2                	mov    %eax,%edx
  801a84:	c1 fa 1f             	sar    $0x1f,%edx
  801a87:	89 d1                	mov    %edx,%ecx
  801a89:	c1 e9 1b             	shr    $0x1b,%ecx
  801a8c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a8f:	83 e2 1f             	and    $0x1f,%edx
  801a92:	29 ca                	sub    %ecx,%edx
  801a94:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a98:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a9c:	83 c0 01             	add    $0x1,%eax
  801a9f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801aa2:	83 c7 01             	add    $0x1,%edi
  801aa5:	eb 9d                	jmp    801a44 <devpipe_write+0x1c>

00801aa7 <devpipe_read>:
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	57                   	push   %edi
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
  801aad:	83 ec 18             	sub    $0x18,%esp
  801ab0:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ab3:	57                   	push   %edi
  801ab4:	e8 bf f6 ff ff       	call   801178 <fd2data>
  801ab9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	be 00 00 00 00       	mov    $0x0,%esi
  801ac3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ac6:	75 13                	jne    801adb <devpipe_read+0x34>
	return i;
  801ac8:	89 f0                	mov    %esi,%eax
  801aca:	eb 02                	jmp    801ace <devpipe_read+0x27>
				return i;
  801acc:	89 f0                	mov    %esi,%eax
}
  801ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5f                   	pop    %edi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    
			sys_yield();
  801ad6:	e8 0b f1 ff ff       	call   800be6 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801adb:	8b 03                	mov    (%ebx),%eax
  801add:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ae0:	75 18                	jne    801afa <devpipe_read+0x53>
			if (i > 0)
  801ae2:	85 f6                	test   %esi,%esi
  801ae4:	75 e6                	jne    801acc <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801ae6:	89 da                	mov    %ebx,%edx
  801ae8:	89 f8                	mov    %edi,%eax
  801aea:	e8 d4 fe ff ff       	call   8019c3 <_pipeisclosed>
  801aef:	85 c0                	test   %eax,%eax
  801af1:	74 e3                	je     801ad6 <devpipe_read+0x2f>
				return 0;
  801af3:	b8 00 00 00 00       	mov    $0x0,%eax
  801af8:	eb d4                	jmp    801ace <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801afa:	99                   	cltd   
  801afb:	c1 ea 1b             	shr    $0x1b,%edx
  801afe:	01 d0                	add    %edx,%eax
  801b00:	83 e0 1f             	and    $0x1f,%eax
  801b03:	29 d0                	sub    %edx,%eax
  801b05:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b10:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b13:	83 c6 01             	add    $0x1,%esi
  801b16:	eb ab                	jmp    801ac3 <devpipe_read+0x1c>

00801b18 <pipe>:
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	56                   	push   %esi
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b23:	50                   	push   %eax
  801b24:	e8 66 f6 ff ff       	call   80118f <fd_alloc>
  801b29:	89 c3                	mov    %eax,%ebx
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	0f 88 23 01 00 00    	js     801c59 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b36:	83 ec 04             	sub    $0x4,%esp
  801b39:	68 07 04 00 00       	push   $0x407
  801b3e:	ff 75 f4             	push   -0xc(%ebp)
  801b41:	6a 00                	push   $0x0
  801b43:	e8 bd f0 ff ff       	call   800c05 <sys_page_alloc>
  801b48:	89 c3                	mov    %eax,%ebx
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	0f 88 04 01 00 00    	js     801c59 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b5b:	50                   	push   %eax
  801b5c:	e8 2e f6 ff ff       	call   80118f <fd_alloc>
  801b61:	89 c3                	mov    %eax,%ebx
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	85 c0                	test   %eax,%eax
  801b68:	0f 88 db 00 00 00    	js     801c49 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6e:	83 ec 04             	sub    $0x4,%esp
  801b71:	68 07 04 00 00       	push   $0x407
  801b76:	ff 75 f0             	push   -0x10(%ebp)
  801b79:	6a 00                	push   $0x0
  801b7b:	e8 85 f0 ff ff       	call   800c05 <sys_page_alloc>
  801b80:	89 c3                	mov    %eax,%ebx
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	85 c0                	test   %eax,%eax
  801b87:	0f 88 bc 00 00 00    	js     801c49 <pipe+0x131>
	va = fd2data(fd0);
  801b8d:	83 ec 0c             	sub    $0xc,%esp
  801b90:	ff 75 f4             	push   -0xc(%ebp)
  801b93:	e8 e0 f5 ff ff       	call   801178 <fd2data>
  801b98:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9a:	83 c4 0c             	add    $0xc,%esp
  801b9d:	68 07 04 00 00       	push   $0x407
  801ba2:	50                   	push   %eax
  801ba3:	6a 00                	push   $0x0
  801ba5:	e8 5b f0 ff ff       	call   800c05 <sys_page_alloc>
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	0f 88 82 00 00 00    	js     801c39 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	ff 75 f0             	push   -0x10(%ebp)
  801bbd:	e8 b6 f5 ff ff       	call   801178 <fd2data>
  801bc2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bc9:	50                   	push   %eax
  801bca:	6a 00                	push   $0x0
  801bcc:	56                   	push   %esi
  801bcd:	6a 00                	push   $0x0
  801bcf:	e8 74 f0 ff ff       	call   800c48 <sys_page_map>
  801bd4:	89 c3                	mov    %eax,%ebx
  801bd6:	83 c4 20             	add    $0x20,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	78 4e                	js     801c2b <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801bdd:	a1 20 30 80 00       	mov    0x803020,%eax
  801be2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be5:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801be7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bea:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801bf1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bf4:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c00:	83 ec 0c             	sub    $0xc,%esp
  801c03:	ff 75 f4             	push   -0xc(%ebp)
  801c06:	e8 5d f5 ff ff       	call   801168 <fd2num>
  801c0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c10:	83 c4 04             	add    $0x4,%esp
  801c13:	ff 75 f0             	push   -0x10(%ebp)
  801c16:	e8 4d f5 ff ff       	call   801168 <fd2num>
  801c1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c29:	eb 2e                	jmp    801c59 <pipe+0x141>
	sys_page_unmap(0, va);
  801c2b:	83 ec 08             	sub    $0x8,%esp
  801c2e:	56                   	push   %esi
  801c2f:	6a 00                	push   $0x0
  801c31:	e8 54 f0 ff ff       	call   800c8a <sys_page_unmap>
  801c36:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c39:	83 ec 08             	sub    $0x8,%esp
  801c3c:	ff 75 f0             	push   -0x10(%ebp)
  801c3f:	6a 00                	push   $0x0
  801c41:	e8 44 f0 ff ff       	call   800c8a <sys_page_unmap>
  801c46:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801c49:	83 ec 08             	sub    $0x8,%esp
  801c4c:	ff 75 f4             	push   -0xc(%ebp)
  801c4f:	6a 00                	push   $0x0
  801c51:	e8 34 f0 ff ff       	call   800c8a <sys_page_unmap>
  801c56:	83 c4 10             	add    $0x10,%esp
}
  801c59:	89 d8                	mov    %ebx,%eax
  801c5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c5e:	5b                   	pop    %ebx
  801c5f:	5e                   	pop    %esi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <pipeisclosed>:
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6b:	50                   	push   %eax
  801c6c:	ff 75 08             	push   0x8(%ebp)
  801c6f:	e8 6b f5 ff ff       	call   8011df <fd_lookup>
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	85 c0                	test   %eax,%eax
  801c79:	78 18                	js     801c93 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801c7b:	83 ec 0c             	sub    $0xc,%esp
  801c7e:	ff 75 f4             	push   -0xc(%ebp)
  801c81:	e8 f2 f4 ff ff       	call   801178 <fd2data>
  801c86:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8b:	e8 33 fd ff ff       	call   8019c3 <_pipeisclosed>
  801c90:	83 c4 10             	add    $0x10,%esp
}
  801c93:	c9                   	leave  
  801c94:	c3                   	ret    

00801c95 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9a:	c3                   	ret    

00801c9b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ca1:	68 76 26 80 00       	push   $0x802676
  801ca6:	ff 75 0c             	push   0xc(%ebp)
  801ca9:	e8 5b eb ff ff       	call   800809 <strcpy>
	return 0;
}
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <devcons_write>:
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	57                   	push   %edi
  801cb9:	56                   	push   %esi
  801cba:	53                   	push   %ebx
  801cbb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801cc1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cc6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ccc:	eb 2e                	jmp    801cfc <devcons_write+0x47>
		m = n - tot;
  801cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cd1:	29 f3                	sub    %esi,%ebx
  801cd3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801cd8:	39 c3                	cmp    %eax,%ebx
  801cda:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801cdd:	83 ec 04             	sub    $0x4,%esp
  801ce0:	53                   	push   %ebx
  801ce1:	89 f0                	mov    %esi,%eax
  801ce3:	03 45 0c             	add    0xc(%ebp),%eax
  801ce6:	50                   	push   %eax
  801ce7:	57                   	push   %edi
  801ce8:	e8 b2 ec ff ff       	call   80099f <memmove>
		sys_cputs(buf, m);
  801ced:	83 c4 08             	add    $0x8,%esp
  801cf0:	53                   	push   %ebx
  801cf1:	57                   	push   %edi
  801cf2:	e8 52 ee ff ff       	call   800b49 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801cf7:	01 de                	add    %ebx,%esi
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cff:	72 cd                	jb     801cce <devcons_write+0x19>
}
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d06:	5b                   	pop    %ebx
  801d07:	5e                   	pop    %esi
  801d08:	5f                   	pop    %edi
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <devcons_read>:
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	83 ec 08             	sub    $0x8,%esp
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d1a:	75 07                	jne    801d23 <devcons_read+0x18>
  801d1c:	eb 1f                	jmp    801d3d <devcons_read+0x32>
		sys_yield();
  801d1e:	e8 c3 ee ff ff       	call   800be6 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d23:	e8 3f ee ff ff       	call   800b67 <sys_cgetc>
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	74 f2                	je     801d1e <devcons_read+0x13>
	if (c < 0)
  801d2c:	78 0f                	js     801d3d <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801d2e:	83 f8 04             	cmp    $0x4,%eax
  801d31:	74 0c                	je     801d3f <devcons_read+0x34>
	*(char*)vbuf = c;
  801d33:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d36:	88 02                	mov    %al,(%edx)
	return 1;
  801d38:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    
		return 0;
  801d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d44:	eb f7                	jmp    801d3d <devcons_read+0x32>

00801d46 <cputchar>:
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d52:	6a 01                	push   $0x1
  801d54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d57:	50                   	push   %eax
  801d58:	e8 ec ed ff ff       	call   800b49 <sys_cputs>
}
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <getchar>:
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d68:	6a 01                	push   $0x1
  801d6a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d6d:	50                   	push   %eax
  801d6e:	6a 00                	push   $0x0
  801d70:	e8 ce f6 ff ff       	call   801443 <read>
	if (r < 0)
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	78 06                	js     801d82 <getchar+0x20>
	if (r < 1)
  801d7c:	74 06                	je     801d84 <getchar+0x22>
	return c;
  801d7e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d82:	c9                   	leave  
  801d83:	c3                   	ret    
		return -E_EOF;
  801d84:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d89:	eb f7                	jmp    801d82 <getchar+0x20>

00801d8b <iscons>:
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d94:	50                   	push   %eax
  801d95:	ff 75 08             	push   0x8(%ebp)
  801d98:	e8 42 f4 ff ff       	call   8011df <fd_lookup>
  801d9d:	83 c4 10             	add    $0x10,%esp
  801da0:	85 c0                	test   %eax,%eax
  801da2:	78 11                	js     801db5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dad:	39 10                	cmp    %edx,(%eax)
  801daf:	0f 94 c0             	sete   %al
  801db2:	0f b6 c0             	movzbl %al,%eax
}
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <opencons>:
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801dbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc0:	50                   	push   %eax
  801dc1:	e8 c9 f3 ff ff       	call   80118f <fd_alloc>
  801dc6:	83 c4 10             	add    $0x10,%esp
  801dc9:	85 c0                	test   %eax,%eax
  801dcb:	78 3a                	js     801e07 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dcd:	83 ec 04             	sub    $0x4,%esp
  801dd0:	68 07 04 00 00       	push   $0x407
  801dd5:	ff 75 f4             	push   -0xc(%ebp)
  801dd8:	6a 00                	push   $0x0
  801dda:	e8 26 ee ff ff       	call   800c05 <sys_page_alloc>
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	85 c0                	test   %eax,%eax
  801de4:	78 21                	js     801e07 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801def:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dfb:	83 ec 0c             	sub    $0xc,%esp
  801dfe:	50                   	push   %eax
  801dff:	e8 64 f3 ff ff       	call   801168 <fd2num>
  801e04:	83 c4 10             	add    $0x10,%esp
}
  801e07:	c9                   	leave  
  801e08:	c3                   	ret    

00801e09 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801e0f:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801e16:	74 0a                	je     801e22 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801e22:	e8 a0 ed ff ff       	call   800bc7 <sys_getenvid>
  801e27:	83 ec 04             	sub    $0x4,%esp
  801e2a:	68 07 0e 00 00       	push   $0xe07
  801e2f:	68 00 f0 bf ee       	push   $0xeebff000
  801e34:	50                   	push   %eax
  801e35:	e8 cb ed ff ff       	call   800c05 <sys_page_alloc>
		if (r < 0) {
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	78 2c                	js     801e6d <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e41:	e8 81 ed ff ff       	call   800bc7 <sys_getenvid>
  801e46:	83 ec 08             	sub    $0x8,%esp
  801e49:	68 7f 1e 80 00       	push   $0x801e7f
  801e4e:	50                   	push   %eax
  801e4f:	e8 fc ee ff ff       	call   800d50 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	85 c0                	test   %eax,%eax
  801e59:	79 bd                	jns    801e18 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801e5b:	50                   	push   %eax
  801e5c:	68 c4 26 80 00       	push   $0x8026c4
  801e61:	6a 28                	push   $0x28
  801e63:	68 fa 26 80 00       	push   $0x8026fa
  801e68:	e8 e7 e2 ff ff       	call   800154 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801e6d:	50                   	push   %eax
  801e6e:	68 84 26 80 00       	push   $0x802684
  801e73:	6a 23                	push   $0x23
  801e75:	68 fa 26 80 00       	push   $0x8026fa
  801e7a:	e8 d5 e2 ff ff       	call   800154 <_panic>

00801e7f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e7f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e80:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801e85:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e87:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801e8a:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801e8e:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801e91:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801e95:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801e99:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801e9b:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801e9e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801e9f:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801ea2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801ea3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801ea4:	c3                   	ret    

00801ea5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eab:	89 c2                	mov    %eax,%edx
  801ead:	c1 ea 16             	shr    $0x16,%edx
  801eb0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801eb7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ebc:	f6 c1 01             	test   $0x1,%cl
  801ebf:	74 1c                	je     801edd <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ec1:	c1 e8 0c             	shr    $0xc,%eax
  801ec4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ecb:	a8 01                	test   $0x1,%al
  801ecd:	74 0e                	je     801edd <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ecf:	c1 e8 0c             	shr    $0xc,%eax
  801ed2:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ed9:	ef 
  801eda:	0f b7 d2             	movzwl %dx,%edx
}
  801edd:	89 d0                	mov    %edx,%eax
  801edf:	5d                   	pop    %ebp
  801ee0:	c3                   	ret    
  801ee1:	66 90                	xchg   %ax,%ax
  801ee3:	66 90                	xchg   %ax,%ax
  801ee5:	66 90                	xchg   %ax,%ax
  801ee7:	66 90                	xchg   %ax,%ax
  801ee9:	66 90                	xchg   %ax,%ax
  801eeb:	66 90                	xchg   %ax,%ax
  801eed:	66 90                	xchg   %ax,%ax
  801eef:	90                   	nop

00801ef0 <__udivdi3>:
  801ef0:	f3 0f 1e fb          	endbr32 
  801ef4:	55                   	push   %ebp
  801ef5:	57                   	push   %edi
  801ef6:	56                   	push   %esi
  801ef7:	53                   	push   %ebx
  801ef8:	83 ec 1c             	sub    $0x1c,%esp
  801efb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801eff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801f03:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	75 19                	jne    801f28 <__udivdi3+0x38>
  801f0f:	39 f3                	cmp    %esi,%ebx
  801f11:	76 4d                	jbe    801f60 <__udivdi3+0x70>
  801f13:	31 ff                	xor    %edi,%edi
  801f15:	89 e8                	mov    %ebp,%eax
  801f17:	89 f2                	mov    %esi,%edx
  801f19:	f7 f3                	div    %ebx
  801f1b:	89 fa                	mov    %edi,%edx
  801f1d:	83 c4 1c             	add    $0x1c,%esp
  801f20:	5b                   	pop    %ebx
  801f21:	5e                   	pop    %esi
  801f22:	5f                   	pop    %edi
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    
  801f25:	8d 76 00             	lea    0x0(%esi),%esi
  801f28:	39 f0                	cmp    %esi,%eax
  801f2a:	76 14                	jbe    801f40 <__udivdi3+0x50>
  801f2c:	31 ff                	xor    %edi,%edi
  801f2e:	31 c0                	xor    %eax,%eax
  801f30:	89 fa                	mov    %edi,%edx
  801f32:	83 c4 1c             	add    $0x1c,%esp
  801f35:	5b                   	pop    %ebx
  801f36:	5e                   	pop    %esi
  801f37:	5f                   	pop    %edi
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    
  801f3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f40:	0f bd f8             	bsr    %eax,%edi
  801f43:	83 f7 1f             	xor    $0x1f,%edi
  801f46:	75 48                	jne    801f90 <__udivdi3+0xa0>
  801f48:	39 f0                	cmp    %esi,%eax
  801f4a:	72 06                	jb     801f52 <__udivdi3+0x62>
  801f4c:	31 c0                	xor    %eax,%eax
  801f4e:	39 eb                	cmp    %ebp,%ebx
  801f50:	77 de                	ja     801f30 <__udivdi3+0x40>
  801f52:	b8 01 00 00 00       	mov    $0x1,%eax
  801f57:	eb d7                	jmp    801f30 <__udivdi3+0x40>
  801f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f60:	89 d9                	mov    %ebx,%ecx
  801f62:	85 db                	test   %ebx,%ebx
  801f64:	75 0b                	jne    801f71 <__udivdi3+0x81>
  801f66:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6b:	31 d2                	xor    %edx,%edx
  801f6d:	f7 f3                	div    %ebx
  801f6f:	89 c1                	mov    %eax,%ecx
  801f71:	31 d2                	xor    %edx,%edx
  801f73:	89 f0                	mov    %esi,%eax
  801f75:	f7 f1                	div    %ecx
  801f77:	89 c6                	mov    %eax,%esi
  801f79:	89 e8                	mov    %ebp,%eax
  801f7b:	89 f7                	mov    %esi,%edi
  801f7d:	f7 f1                	div    %ecx
  801f7f:	89 fa                	mov    %edi,%edx
  801f81:	83 c4 1c             	add    $0x1c,%esp
  801f84:	5b                   	pop    %ebx
  801f85:	5e                   	pop    %esi
  801f86:	5f                   	pop    %edi
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	89 f9                	mov    %edi,%ecx
  801f92:	ba 20 00 00 00       	mov    $0x20,%edx
  801f97:	29 fa                	sub    %edi,%edx
  801f99:	d3 e0                	shl    %cl,%eax
  801f9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f9f:	89 d1                	mov    %edx,%ecx
  801fa1:	89 d8                	mov    %ebx,%eax
  801fa3:	d3 e8                	shr    %cl,%eax
  801fa5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801fa9:	09 c1                	or     %eax,%ecx
  801fab:	89 f0                	mov    %esi,%eax
  801fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	d3 e3                	shl    %cl,%ebx
  801fb5:	89 d1                	mov    %edx,%ecx
  801fb7:	d3 e8                	shr    %cl,%eax
  801fb9:	89 f9                	mov    %edi,%ecx
  801fbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801fbf:	89 eb                	mov    %ebp,%ebx
  801fc1:	d3 e6                	shl    %cl,%esi
  801fc3:	89 d1                	mov    %edx,%ecx
  801fc5:	d3 eb                	shr    %cl,%ebx
  801fc7:	09 f3                	or     %esi,%ebx
  801fc9:	89 c6                	mov    %eax,%esi
  801fcb:	89 f2                	mov    %esi,%edx
  801fcd:	89 d8                	mov    %ebx,%eax
  801fcf:	f7 74 24 08          	divl   0x8(%esp)
  801fd3:	89 d6                	mov    %edx,%esi
  801fd5:	89 c3                	mov    %eax,%ebx
  801fd7:	f7 64 24 0c          	mull   0xc(%esp)
  801fdb:	39 d6                	cmp    %edx,%esi
  801fdd:	72 19                	jb     801ff8 <__udivdi3+0x108>
  801fdf:	89 f9                	mov    %edi,%ecx
  801fe1:	d3 e5                	shl    %cl,%ebp
  801fe3:	39 c5                	cmp    %eax,%ebp
  801fe5:	73 04                	jae    801feb <__udivdi3+0xfb>
  801fe7:	39 d6                	cmp    %edx,%esi
  801fe9:	74 0d                	je     801ff8 <__udivdi3+0x108>
  801feb:	89 d8                	mov    %ebx,%eax
  801fed:	31 ff                	xor    %edi,%edi
  801fef:	e9 3c ff ff ff       	jmp    801f30 <__udivdi3+0x40>
  801ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801ffb:	31 ff                	xor    %edi,%edi
  801ffd:	e9 2e ff ff ff       	jmp    801f30 <__udivdi3+0x40>
  802002:	66 90                	xchg   %ax,%ax
  802004:	66 90                	xchg   %ax,%ax
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__umoddi3>:
  802010:	f3 0f 1e fb          	endbr32 
  802014:	55                   	push   %ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 1c             	sub    $0x1c,%esp
  80201b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80201f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802023:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802027:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80202b:	89 f0                	mov    %esi,%eax
  80202d:	89 da                	mov    %ebx,%edx
  80202f:	85 ff                	test   %edi,%edi
  802031:	75 15                	jne    802048 <__umoddi3+0x38>
  802033:	39 dd                	cmp    %ebx,%ebp
  802035:	76 39                	jbe    802070 <__umoddi3+0x60>
  802037:	f7 f5                	div    %ebp
  802039:	89 d0                	mov    %edx,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	83 c4 1c             	add    $0x1c,%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
  802048:	39 df                	cmp    %ebx,%edi
  80204a:	77 f1                	ja     80203d <__umoddi3+0x2d>
  80204c:	0f bd cf             	bsr    %edi,%ecx
  80204f:	83 f1 1f             	xor    $0x1f,%ecx
  802052:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802056:	75 40                	jne    802098 <__umoddi3+0x88>
  802058:	39 df                	cmp    %ebx,%edi
  80205a:	72 04                	jb     802060 <__umoddi3+0x50>
  80205c:	39 f5                	cmp    %esi,%ebp
  80205e:	77 dd                	ja     80203d <__umoddi3+0x2d>
  802060:	89 da                	mov    %ebx,%edx
  802062:	89 f0                	mov    %esi,%eax
  802064:	29 e8                	sub    %ebp,%eax
  802066:	19 fa                	sbb    %edi,%edx
  802068:	eb d3                	jmp    80203d <__umoddi3+0x2d>
  80206a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802070:	89 e9                	mov    %ebp,%ecx
  802072:	85 ed                	test   %ebp,%ebp
  802074:	75 0b                	jne    802081 <__umoddi3+0x71>
  802076:	b8 01 00 00 00       	mov    $0x1,%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	f7 f5                	div    %ebp
  80207f:	89 c1                	mov    %eax,%ecx
  802081:	89 d8                	mov    %ebx,%eax
  802083:	31 d2                	xor    %edx,%edx
  802085:	f7 f1                	div    %ecx
  802087:	89 f0                	mov    %esi,%eax
  802089:	f7 f1                	div    %ecx
  80208b:	89 d0                	mov    %edx,%eax
  80208d:	31 d2                	xor    %edx,%edx
  80208f:	eb ac                	jmp    80203d <__umoddi3+0x2d>
  802091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802098:	8b 44 24 04          	mov    0x4(%esp),%eax
  80209c:	ba 20 00 00 00       	mov    $0x20,%edx
  8020a1:	29 c2                	sub    %eax,%edx
  8020a3:	89 c1                	mov    %eax,%ecx
  8020a5:	89 e8                	mov    %ebp,%eax
  8020a7:	d3 e7                	shl    %cl,%edi
  8020a9:	89 d1                	mov    %edx,%ecx
  8020ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020af:	d3 e8                	shr    %cl,%eax
  8020b1:	89 c1                	mov    %eax,%ecx
  8020b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020b7:	09 f9                	or     %edi,%ecx
  8020b9:	89 df                	mov    %ebx,%edi
  8020bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020bf:	89 c1                	mov    %eax,%ecx
  8020c1:	d3 e5                	shl    %cl,%ebp
  8020c3:	89 d1                	mov    %edx,%ecx
  8020c5:	d3 ef                	shr    %cl,%edi
  8020c7:	89 c1                	mov    %eax,%ecx
  8020c9:	89 f0                	mov    %esi,%eax
  8020cb:	d3 e3                	shl    %cl,%ebx
  8020cd:	89 d1                	mov    %edx,%ecx
  8020cf:	89 fa                	mov    %edi,%edx
  8020d1:	d3 e8                	shr    %cl,%eax
  8020d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8020d8:	09 d8                	or     %ebx,%eax
  8020da:	f7 74 24 08          	divl   0x8(%esp)
  8020de:	89 d3                	mov    %edx,%ebx
  8020e0:	d3 e6                	shl    %cl,%esi
  8020e2:	f7 e5                	mul    %ebp
  8020e4:	89 c7                	mov    %eax,%edi
  8020e6:	89 d1                	mov    %edx,%ecx
  8020e8:	39 d3                	cmp    %edx,%ebx
  8020ea:	72 06                	jb     8020f2 <__umoddi3+0xe2>
  8020ec:	75 0e                	jne    8020fc <__umoddi3+0xec>
  8020ee:	39 c6                	cmp    %eax,%esi
  8020f0:	73 0a                	jae    8020fc <__umoddi3+0xec>
  8020f2:	29 e8                	sub    %ebp,%eax
  8020f4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8020f8:	89 d1                	mov    %edx,%ecx
  8020fa:	89 c7                	mov    %eax,%edi
  8020fc:	89 f5                	mov    %esi,%ebp
  8020fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802102:	29 fd                	sub    %edi,%ebp
  802104:	19 cb                	sbb    %ecx,%ebx
  802106:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80210b:	89 d8                	mov    %ebx,%eax
  80210d:	d3 e0                	shl    %cl,%eax
  80210f:	89 f1                	mov    %esi,%ecx
  802111:	d3 ed                	shr    %cl,%ebp
  802113:	d3 eb                	shr    %cl,%ebx
  802115:	09 e8                	or     %ebp,%eax
  802117:	89 da                	mov    %ebx,%edx
  802119:	83 c4 1c             	add    $0x1c,%esp
  80211c:	5b                   	pop    %ebx
  80211d:	5e                   	pop    %esi
  80211e:	5f                   	pop    %edi
  80211f:	5d                   	pop    %ebp
  802120:	c3                   	ret    
