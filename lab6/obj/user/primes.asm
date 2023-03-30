
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
  800047:	e8 89 10 00 00       	call   8010d5 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 00 40 80 00       	mov    0x804000,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 00 26 80 00       	push   $0x802600
  800060:	e8 ca 01 00 00       	call   80022f <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 eb 0e 00 00       	call   800f55 <fork>
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
  800080:	e8 50 10 00 00       	call   8010d5 <ipc_recv>
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
  800097:	e8 a0 10 00 00       	call   80113c <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb d7                	jmp    800078 <primeproc+0x45>
		panic("fork: %e", id);
  8000a1:	50                   	push   %eax
  8000a2:	68 18 2a 80 00       	push   $0x802a18
  8000a7:	6a 1a                	push   $0x1a
  8000a9:	68 0c 26 80 00       	push   $0x80260c
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
  8000b8:	e8 98 0e 00 00       	call   800f55 <fork>
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
  8000d0:	e8 67 10 00 00       	call   80113c <ipc_send>
	for (i = 2; ; i++)
  8000d5:	83 c3 01             	add    $0x1,%ebx
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	eb ed                	jmp    8000ca <umain+0x17>
		panic("fork: %e", id);
  8000dd:	50                   	push   %eax
  8000de:	68 18 2a 80 00       	push   $0x802a18
  8000e3:	6a 2d                	push   $0x2d
  8000e5:	68 0c 26 80 00       	push   $0x80260c
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
  800140:	e8 55 12 00 00       	call   80139a <close_all>
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
  800172:	68 24 26 80 00       	push   $0x802624
  800177:	e8 b3 00 00 00       	call   80022f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017c:	83 c4 18             	add    $0x18,%esp
  80017f:	53                   	push   %ebx
  800180:	ff 75 10             	push   0x10(%ebp)
  800183:	e8 56 00 00 00       	call   8001de <vcprintf>
	cprintf("\n");
  800188:	c7 04 24 6c 2b 80 00 	movl   $0x802b6c,(%esp)
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
  800291:	e8 1a 21 00 00       	call   8023b0 <__udivdi3>
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
  8002cf:	e8 fc 21 00 00       	call   8024d0 <__umoddi3>
  8002d4:	83 c4 14             	add    $0x14,%esp
  8002d7:	0f be 80 47 26 80 00 	movsbl 0x802647(%eax),%eax
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
  800391:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
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
  80045f:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	74 18                	je     800482 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80046a:	52                   	push   %edx
  80046b:	68 01 2b 80 00       	push   $0x802b01
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 92 fe ff ff       	call   800309 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80047d:	e9 66 02 00 00       	jmp    8006e8 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800482:	50                   	push   %eax
  800483:	68 5f 26 80 00       	push   $0x80265f
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
  8004aa:	b8 58 26 80 00       	mov    $0x802658,%eax
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
  800bb6:	68 3f 29 80 00       	push   $0x80293f
  800bbb:	6a 2a                	push   $0x2a
  800bbd:	68 5c 29 80 00       	push   $0x80295c
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
  800c37:	68 3f 29 80 00       	push   $0x80293f
  800c3c:	6a 2a                	push   $0x2a
  800c3e:	68 5c 29 80 00       	push   $0x80295c
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
  800c79:	68 3f 29 80 00       	push   $0x80293f
  800c7e:	6a 2a                	push   $0x2a
  800c80:	68 5c 29 80 00       	push   $0x80295c
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
  800cbb:	68 3f 29 80 00       	push   $0x80293f
  800cc0:	6a 2a                	push   $0x2a
  800cc2:	68 5c 29 80 00       	push   $0x80295c
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
  800cfd:	68 3f 29 80 00       	push   $0x80293f
  800d02:	6a 2a                	push   $0x2a
  800d04:	68 5c 29 80 00       	push   $0x80295c
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
  800d3f:	68 3f 29 80 00       	push   $0x80293f
  800d44:	6a 2a                	push   $0x2a
  800d46:	68 5c 29 80 00       	push   $0x80295c
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
  800d81:	68 3f 29 80 00       	push   $0x80293f
  800d86:	6a 2a                	push   $0x2a
  800d88:	68 5c 29 80 00       	push   $0x80295c
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
  800de5:	68 3f 29 80 00       	push   $0x80293f
  800dea:	6a 2a                	push   $0x2a
  800dec:	68 5c 29 80 00       	push   $0x80295c
  800df1:	e8 5e f3 ff ff       	call   800154 <_panic>

00800df6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800e01:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e06:	89 d1                	mov    %edx,%ecx
  800e08:	89 d3                	mov    %edx,%ebx
  800e0a:	89 d7                	mov    %edx,%edi
  800e0c:	89 d6                	mov    %edx,%esi
  800e0e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	57                   	push   %edi
  800e19:	56                   	push   %esi
  800e1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e26:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e2b:	89 df                	mov    %ebx,%edi
  800e2d:	89 de                	mov    %ebx,%esi
  800e2f:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e47:	b8 10 00 00 00       	mov    $0x10,%eax
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e5f:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e61:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e65:	0f 84 8e 00 00 00    	je     800ef9 <pgfault+0xa2>
  800e6b:	89 f0                	mov    %esi,%eax
  800e6d:	c1 e8 0c             	shr    $0xc,%eax
  800e70:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e77:	f6 c4 08             	test   $0x8,%ah
  800e7a:	74 7d                	je     800ef9 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e7c:	e8 46 fd ff ff       	call   800bc7 <sys_getenvid>
  800e81:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e83:	83 ec 04             	sub    $0x4,%esp
  800e86:	6a 07                	push   $0x7
  800e88:	68 00 f0 7f 00       	push   $0x7ff000
  800e8d:	50                   	push   %eax
  800e8e:	e8 72 fd ff ff       	call   800c05 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e93:	83 c4 10             	add    $0x10,%esp
  800e96:	85 c0                	test   %eax,%eax
  800e98:	78 73                	js     800f0d <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e9a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800ea0:	83 ec 04             	sub    $0x4,%esp
  800ea3:	68 00 10 00 00       	push   $0x1000
  800ea8:	56                   	push   %esi
  800ea9:	68 00 f0 7f 00       	push   $0x7ff000
  800eae:	e8 ec fa ff ff       	call   80099f <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800eb3:	83 c4 08             	add    $0x8,%esp
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	e8 cd fd ff ff       	call   800c8a <sys_page_unmap>
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	78 5b                	js     800f1f <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800ec4:	83 ec 0c             	sub    $0xc,%esp
  800ec7:	6a 07                	push   $0x7
  800ec9:	56                   	push   %esi
  800eca:	53                   	push   %ebx
  800ecb:	68 00 f0 7f 00       	push   $0x7ff000
  800ed0:	53                   	push   %ebx
  800ed1:	e8 72 fd ff ff       	call   800c48 <sys_page_map>
  800ed6:	83 c4 20             	add    $0x20,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	78 54                	js     800f31 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800edd:	83 ec 08             	sub    $0x8,%esp
  800ee0:	68 00 f0 7f 00       	push   $0x7ff000
  800ee5:	53                   	push   %ebx
  800ee6:	e8 9f fd ff ff       	call   800c8a <sys_page_unmap>
  800eeb:	83 c4 10             	add    $0x10,%esp
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	78 51                	js     800f43 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800ef2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ef9:	83 ec 04             	sub    $0x4,%esp
  800efc:	68 6c 29 80 00       	push   $0x80296c
  800f01:	6a 1d                	push   $0x1d
  800f03:	68 e8 29 80 00       	push   $0x8029e8
  800f08:	e8 47 f2 ff ff       	call   800154 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f0d:	50                   	push   %eax
  800f0e:	68 a4 29 80 00       	push   $0x8029a4
  800f13:	6a 29                	push   $0x29
  800f15:	68 e8 29 80 00       	push   $0x8029e8
  800f1a:	e8 35 f2 ff ff       	call   800154 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f1f:	50                   	push   %eax
  800f20:	68 c8 29 80 00       	push   $0x8029c8
  800f25:	6a 2e                	push   $0x2e
  800f27:	68 e8 29 80 00       	push   $0x8029e8
  800f2c:	e8 23 f2 ff ff       	call   800154 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800f31:	50                   	push   %eax
  800f32:	68 f3 29 80 00       	push   $0x8029f3
  800f37:	6a 30                	push   $0x30
  800f39:	68 e8 29 80 00       	push   $0x8029e8
  800f3e:	e8 11 f2 ff ff       	call   800154 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f43:	50                   	push   %eax
  800f44:	68 c8 29 80 00       	push   $0x8029c8
  800f49:	6a 32                	push   $0x32
  800f4b:	68 e8 29 80 00       	push   $0x8029e8
  800f50:	e8 ff f1 ff ff       	call   800154 <_panic>

00800f55 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	57                   	push   %edi
  800f59:	56                   	push   %esi
  800f5a:	53                   	push   %ebx
  800f5b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f5e:	68 57 0e 80 00       	push   $0x800e57
  800f63:	e8 6f 13 00 00       	call   8022d7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f68:	b8 07 00 00 00       	mov    $0x7,%eax
  800f6d:	cd 30                	int    $0x30
  800f6f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	78 2d                	js     800fa6 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f79:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f7e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f82:	75 73                	jne    800ff7 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f84:	e8 3e fc ff ff       	call   800bc7 <sys_getenvid>
  800f89:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f91:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f96:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800f9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800fa6:	50                   	push   %eax
  800fa7:	68 11 2a 80 00       	push   $0x802a11
  800fac:	6a 78                	push   $0x78
  800fae:	68 e8 29 80 00       	push   $0x8029e8
  800fb3:	e8 9c f1 ff ff       	call   800154 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	ff 75 e4             	push   -0x1c(%ebp)
  800fbe:	57                   	push   %edi
  800fbf:	ff 75 dc             	push   -0x24(%ebp)
  800fc2:	57                   	push   %edi
  800fc3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fc6:	56                   	push   %esi
  800fc7:	e8 7c fc ff ff       	call   800c48 <sys_page_map>
	if(r<0) return r;
  800fcc:	83 c4 20             	add    $0x20,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 cb                	js     800f9e <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	ff 75 e4             	push   -0x1c(%ebp)
  800fd9:	57                   	push   %edi
  800fda:	56                   	push   %esi
  800fdb:	57                   	push   %edi
  800fdc:	56                   	push   %esi
  800fdd:	e8 66 fc ff ff       	call   800c48 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800fe2:	83 c4 20             	add    $0x20,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 76                	js     80105f <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fe9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fef:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800ff5:	74 75                	je     80106c <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	c1 e8 16             	shr    $0x16,%eax
  800ffc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801003:	a8 01                	test   $0x1,%al
  801005:	74 e2                	je     800fe9 <fork+0x94>
  801007:	89 de                	mov    %ebx,%esi
  801009:	c1 ee 0c             	shr    $0xc,%esi
  80100c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801013:	a8 01                	test   $0x1,%al
  801015:	74 d2                	je     800fe9 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801017:	e8 ab fb ff ff       	call   800bc7 <sys_getenvid>
  80101c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  80101f:	89 f7                	mov    %esi,%edi
  801021:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801024:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80102b:	89 c1                	mov    %eax,%ecx
  80102d:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801033:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801036:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  80103d:	f6 c6 04             	test   $0x4,%dh
  801040:	0f 85 72 ff ff ff    	jne    800fb8 <fork+0x63>
		perm &= ~PTE_W;
  801046:	25 05 0e 00 00       	and    $0xe05,%eax
  80104b:	80 cc 08             	or     $0x8,%ah
  80104e:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801054:	0f 44 c1             	cmove  %ecx,%eax
  801057:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80105a:	e9 59 ff ff ff       	jmp    800fb8 <fork+0x63>
  80105f:	ba 00 00 00 00       	mov    $0x0,%edx
  801064:	0f 4f c2             	cmovg  %edx,%eax
  801067:	e9 32 ff ff ff       	jmp    800f9e <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80106c:	83 ec 04             	sub    $0x4,%esp
  80106f:	6a 07                	push   $0x7
  801071:	68 00 f0 bf ee       	push   $0xeebff000
  801076:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801079:	57                   	push   %edi
  80107a:	e8 86 fb ff ff       	call   800c05 <sys_page_alloc>
	if(r<0) return r;
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	0f 88 14 ff ff ff    	js     800f9e <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80108a:	83 ec 08             	sub    $0x8,%esp
  80108d:	68 4d 23 80 00       	push   $0x80234d
  801092:	57                   	push   %edi
  801093:	e8 b8 fc ff ff       	call   800d50 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	0f 88 fb fe ff ff    	js     800f9e <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	6a 02                	push   $0x2
  8010a8:	57                   	push   %edi
  8010a9:	e8 1e fc ff ff       	call   800ccc <sys_env_set_status>
	if(r<0) return r;
  8010ae:	83 c4 10             	add    $0x10,%esp
	return envid;
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	0f 49 c7             	cmovns %edi,%eax
  8010b6:	e9 e3 fe ff ff       	jmp    800f9e <fork+0x49>

008010bb <sfork>:

// Challenge!
int
sfork(void)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c1:	68 21 2a 80 00       	push   $0x802a21
  8010c6:	68 a1 00 00 00       	push   $0xa1
  8010cb:	68 e8 29 80 00       	push   $0x8029e8
  8010d0:	e8 7f f0 ff ff       	call   800154 <_panic>

008010d5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
  8010da:	8b 75 08             	mov    0x8(%ebp),%esi
  8010dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010ea:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8010ed:	83 ec 0c             	sub    $0xc,%esp
  8010f0:	50                   	push   %eax
  8010f1:	e8 bf fc ff ff       	call   800db5 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	85 f6                	test   %esi,%esi
  8010fb:	74 14                	je     801111 <ipc_recv+0x3c>
  8010fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801102:	85 c0                	test   %eax,%eax
  801104:	78 09                	js     80110f <ipc_recv+0x3a>
  801106:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80110c:	8b 52 74             	mov    0x74(%edx),%edx
  80110f:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801111:	85 db                	test   %ebx,%ebx
  801113:	74 14                	je     801129 <ipc_recv+0x54>
  801115:	ba 00 00 00 00       	mov    $0x0,%edx
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 09                	js     801127 <ipc_recv+0x52>
  80111e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801124:	8b 52 78             	mov    0x78(%edx),%edx
  801127:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 08                	js     801135 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  80112d:	a1 00 40 80 00       	mov    0x804000,%eax
  801132:	8b 40 70             	mov    0x70(%eax),%eax
}
  801135:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	57                   	push   %edi
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	8b 7d 08             	mov    0x8(%ebp),%edi
  801148:	8b 75 0c             	mov    0xc(%ebp),%esi
  80114b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80114e:	85 db                	test   %ebx,%ebx
  801150:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801155:	0f 44 d8             	cmove  %eax,%ebx
  801158:	eb 05                	jmp    80115f <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80115a:	e8 87 fa ff ff       	call   800be6 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80115f:	ff 75 14             	push   0x14(%ebp)
  801162:	53                   	push   %ebx
  801163:	56                   	push   %esi
  801164:	57                   	push   %edi
  801165:	e8 28 fc ff ff       	call   800d92 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801170:	74 e8                	je     80115a <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801172:	85 c0                	test   %eax,%eax
  801174:	78 08                	js     80117e <ipc_send+0x42>
	}while (r<0);

}
  801176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80117e:	50                   	push   %eax
  80117f:	68 37 2a 80 00       	push   $0x802a37
  801184:	6a 3d                	push   $0x3d
  801186:	68 4b 2a 80 00       	push   $0x802a4b
  80118b:	e8 c4 ef ff ff       	call   800154 <_panic>

00801190 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801196:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80119b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80119e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011a4:	8b 52 50             	mov    0x50(%edx),%edx
  8011a7:	39 ca                	cmp    %ecx,%edx
  8011a9:	74 11                	je     8011bc <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8011ab:	83 c0 01             	add    $0x1,%eax
  8011ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011b3:	75 e6                	jne    80119b <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8011b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ba:	eb 0b                	jmp    8011c7 <ipc_find_env+0x37>
			return envs[i].env_id;
  8011bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c4:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    

008011c9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cf:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d4:	c1 e8 0c             	shr    $0xc,%eax
}
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011df:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	c1 ea 16             	shr    $0x16,%edx
  8011fd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801204:	f6 c2 01             	test   $0x1,%dl
  801207:	74 29                	je     801232 <fd_alloc+0x42>
  801209:	89 c2                	mov    %eax,%edx
  80120b:	c1 ea 0c             	shr    $0xc,%edx
  80120e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801215:	f6 c2 01             	test   $0x1,%dl
  801218:	74 18                	je     801232 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80121a:	05 00 10 00 00       	add    $0x1000,%eax
  80121f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801224:	75 d2                	jne    8011f8 <fd_alloc+0x8>
  801226:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80122b:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801230:	eb 05                	jmp    801237 <fd_alloc+0x47>
			return 0;
  801232:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801237:	8b 55 08             	mov    0x8(%ebp),%edx
  80123a:	89 02                	mov    %eax,(%edx)
}
  80123c:	89 c8                	mov    %ecx,%eax
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801246:	83 f8 1f             	cmp    $0x1f,%eax
  801249:	77 30                	ja     80127b <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80124b:	c1 e0 0c             	shl    $0xc,%eax
  80124e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801253:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801259:	f6 c2 01             	test   $0x1,%dl
  80125c:	74 24                	je     801282 <fd_lookup+0x42>
  80125e:	89 c2                	mov    %eax,%edx
  801260:	c1 ea 0c             	shr    $0xc,%edx
  801263:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126a:	f6 c2 01             	test   $0x1,%dl
  80126d:	74 1a                	je     801289 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80126f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801272:	89 02                	mov    %eax,(%edx)
	return 0;
  801274:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    
		return -E_INVAL;
  80127b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801280:	eb f7                	jmp    801279 <fd_lookup+0x39>
		return -E_INVAL;
  801282:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801287:	eb f0                	jmp    801279 <fd_lookup+0x39>
  801289:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128e:	eb e9                	jmp    801279 <fd_lookup+0x39>

00801290 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	53                   	push   %ebx
  801294:	83 ec 04             	sub    $0x4,%esp
  801297:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80129a:	b8 00 00 00 00       	mov    $0x0,%eax
  80129f:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8012a4:	39 13                	cmp    %edx,(%ebx)
  8012a6:	74 37                	je     8012df <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8012a8:	83 c0 01             	add    $0x1,%eax
  8012ab:	8b 1c 85 d4 2a 80 00 	mov    0x802ad4(,%eax,4),%ebx
  8012b2:	85 db                	test   %ebx,%ebx
  8012b4:	75 ee                	jne    8012a4 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b6:	a1 00 40 80 00       	mov    0x804000,%eax
  8012bb:	8b 40 48             	mov    0x48(%eax),%eax
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	52                   	push   %edx
  8012c2:	50                   	push   %eax
  8012c3:	68 58 2a 80 00       	push   $0x802a58
  8012c8:	e8 62 ef ff ff       	call   80022f <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d8:	89 1a                	mov    %ebx,(%edx)
}
  8012da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    
			return 0;
  8012df:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e4:	eb ef                	jmp    8012d5 <dev_lookup+0x45>

008012e6 <fd_close>:
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	57                   	push   %edi
  8012ea:	56                   	push   %esi
  8012eb:	53                   	push   %ebx
  8012ec:	83 ec 24             	sub    $0x24,%esp
  8012ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f8:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ff:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801302:	50                   	push   %eax
  801303:	e8 38 ff ff ff       	call   801240 <fd_lookup>
  801308:	89 c3                	mov    %eax,%ebx
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 05                	js     801316 <fd_close+0x30>
	    || fd != fd2)
  801311:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801314:	74 16                	je     80132c <fd_close+0x46>
		return (must_exist ? r : 0);
  801316:	89 f8                	mov    %edi,%eax
  801318:	84 c0                	test   %al,%al
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
  80131f:	0f 44 d8             	cmove  %eax,%ebx
}
  801322:	89 d8                	mov    %ebx,%eax
  801324:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801327:	5b                   	pop    %ebx
  801328:	5e                   	pop    %esi
  801329:	5f                   	pop    %edi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	ff 36                	push   (%esi)
  801335:	e8 56 ff ff ff       	call   801290 <dev_lookup>
  80133a:	89 c3                	mov    %eax,%ebx
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 1a                	js     80135d <fd_close+0x77>
		if (dev->dev_close)
  801343:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801346:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801349:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80134e:	85 c0                	test   %eax,%eax
  801350:	74 0b                	je     80135d <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	56                   	push   %esi
  801356:	ff d0                	call   *%eax
  801358:	89 c3                	mov    %eax,%ebx
  80135a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	56                   	push   %esi
  801361:	6a 00                	push   $0x0
  801363:	e8 22 f9 ff ff       	call   800c8a <sys_page_unmap>
	return r;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	eb b5                	jmp    801322 <fd_close+0x3c>

0080136d <close>:

int
close(int fdnum)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801373:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 75 08             	push   0x8(%ebp)
  80137a:	e8 c1 fe ff ff       	call   801240 <fd_lookup>
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	79 02                	jns    801388 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    
		return fd_close(fd, 1);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	6a 01                	push   $0x1
  80138d:	ff 75 f4             	push   -0xc(%ebp)
  801390:	e8 51 ff ff ff       	call   8012e6 <fd_close>
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	eb ec                	jmp    801386 <close+0x19>

0080139a <close_all>:

void
close_all(void)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	53                   	push   %ebx
  80139e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013a6:	83 ec 0c             	sub    $0xc,%esp
  8013a9:	53                   	push   %ebx
  8013aa:	e8 be ff ff ff       	call   80136d <close>
	for (i = 0; i < MAXFD; i++)
  8013af:	83 c3 01             	add    $0x1,%ebx
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	83 fb 20             	cmp    $0x20,%ebx
  8013b8:	75 ec                	jne    8013a6 <close_all+0xc>
}
  8013ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bd:	c9                   	leave  
  8013be:	c3                   	ret    

008013bf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	57                   	push   %edi
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	ff 75 08             	push   0x8(%ebp)
  8013cf:	e8 6c fe ff ff       	call   801240 <fd_lookup>
  8013d4:	89 c3                	mov    %eax,%ebx
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 7f                	js     80145c <dup+0x9d>
		return r;
	close(newfdnum);
  8013dd:	83 ec 0c             	sub    $0xc,%esp
  8013e0:	ff 75 0c             	push   0xc(%ebp)
  8013e3:	e8 85 ff ff ff       	call   80136d <close>

	newfd = INDEX2FD(newfdnum);
  8013e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013eb:	c1 e6 0c             	shl    $0xc,%esi
  8013ee:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013f7:	89 3c 24             	mov    %edi,(%esp)
  8013fa:	e8 da fd ff ff       	call   8011d9 <fd2data>
  8013ff:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801401:	89 34 24             	mov    %esi,(%esp)
  801404:	e8 d0 fd ff ff       	call   8011d9 <fd2data>
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80140f:	89 d8                	mov    %ebx,%eax
  801411:	c1 e8 16             	shr    $0x16,%eax
  801414:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80141b:	a8 01                	test   $0x1,%al
  80141d:	74 11                	je     801430 <dup+0x71>
  80141f:	89 d8                	mov    %ebx,%eax
  801421:	c1 e8 0c             	shr    $0xc,%eax
  801424:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80142b:	f6 c2 01             	test   $0x1,%dl
  80142e:	75 36                	jne    801466 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801430:	89 f8                	mov    %edi,%eax
  801432:	c1 e8 0c             	shr    $0xc,%eax
  801435:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143c:	83 ec 0c             	sub    $0xc,%esp
  80143f:	25 07 0e 00 00       	and    $0xe07,%eax
  801444:	50                   	push   %eax
  801445:	56                   	push   %esi
  801446:	6a 00                	push   $0x0
  801448:	57                   	push   %edi
  801449:	6a 00                	push   $0x0
  80144b:	e8 f8 f7 ff ff       	call   800c48 <sys_page_map>
  801450:	89 c3                	mov    %eax,%ebx
  801452:	83 c4 20             	add    $0x20,%esp
  801455:	85 c0                	test   %eax,%eax
  801457:	78 33                	js     80148c <dup+0xcd>
		goto err;

	return newfdnum;
  801459:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80145c:	89 d8                	mov    %ebx,%eax
  80145e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801461:	5b                   	pop    %ebx
  801462:	5e                   	pop    %esi
  801463:	5f                   	pop    %edi
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801466:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	25 07 0e 00 00       	and    $0xe07,%eax
  801475:	50                   	push   %eax
  801476:	ff 75 d4             	push   -0x2c(%ebp)
  801479:	6a 00                	push   $0x0
  80147b:	53                   	push   %ebx
  80147c:	6a 00                	push   $0x0
  80147e:	e8 c5 f7 ff ff       	call   800c48 <sys_page_map>
  801483:	89 c3                	mov    %eax,%ebx
  801485:	83 c4 20             	add    $0x20,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	79 a4                	jns    801430 <dup+0x71>
	sys_page_unmap(0, newfd);
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	56                   	push   %esi
  801490:	6a 00                	push   $0x0
  801492:	e8 f3 f7 ff ff       	call   800c8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801497:	83 c4 08             	add    $0x8,%esp
  80149a:	ff 75 d4             	push   -0x2c(%ebp)
  80149d:	6a 00                	push   $0x0
  80149f:	e8 e6 f7 ff ff       	call   800c8a <sys_page_unmap>
	return r;
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	eb b3                	jmp    80145c <dup+0x9d>

008014a9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	56                   	push   %esi
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 18             	sub    $0x18,%esp
  8014b1:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	56                   	push   %esi
  8014b9:	e8 82 fd ff ff       	call   801240 <fd_lookup>
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 3c                	js     801501 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	ff 33                	push   (%ebx)
  8014d1:	e8 ba fd ff ff       	call   801290 <dev_lookup>
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 24                	js     801501 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014dd:	8b 43 08             	mov    0x8(%ebx),%eax
  8014e0:	83 e0 03             	and    $0x3,%eax
  8014e3:	83 f8 01             	cmp    $0x1,%eax
  8014e6:	74 20                	je     801508 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014eb:	8b 40 08             	mov    0x8(%eax),%eax
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	74 37                	je     801529 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	ff 75 10             	push   0x10(%ebp)
  8014f8:	ff 75 0c             	push   0xc(%ebp)
  8014fb:	53                   	push   %ebx
  8014fc:	ff d0                	call   *%eax
  8014fe:	83 c4 10             	add    $0x10,%esp
}
  801501:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801504:	5b                   	pop    %ebx
  801505:	5e                   	pop    %esi
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801508:	a1 00 40 80 00       	mov    0x804000,%eax
  80150d:	8b 40 48             	mov    0x48(%eax),%eax
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	56                   	push   %esi
  801514:	50                   	push   %eax
  801515:	68 99 2a 80 00       	push   $0x802a99
  80151a:	e8 10 ed ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801527:	eb d8                	jmp    801501 <read+0x58>
		return -E_NOT_SUPP;
  801529:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80152e:	eb d1                	jmp    801501 <read+0x58>

00801530 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	57                   	push   %edi
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	83 ec 0c             	sub    $0xc,%esp
  801539:	8b 7d 08             	mov    0x8(%ebp),%edi
  80153c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801544:	eb 02                	jmp    801548 <readn+0x18>
  801546:	01 c3                	add    %eax,%ebx
  801548:	39 f3                	cmp    %esi,%ebx
  80154a:	73 21                	jae    80156d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80154c:	83 ec 04             	sub    $0x4,%esp
  80154f:	89 f0                	mov    %esi,%eax
  801551:	29 d8                	sub    %ebx,%eax
  801553:	50                   	push   %eax
  801554:	89 d8                	mov    %ebx,%eax
  801556:	03 45 0c             	add    0xc(%ebp),%eax
  801559:	50                   	push   %eax
  80155a:	57                   	push   %edi
  80155b:	e8 49 ff ff ff       	call   8014a9 <read>
		if (m < 0)
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 04                	js     80156b <readn+0x3b>
			return m;
		if (m == 0)
  801567:	75 dd                	jne    801546 <readn+0x16>
  801569:	eb 02                	jmp    80156d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80156d:	89 d8                	mov    %ebx,%eax
  80156f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801572:	5b                   	pop    %ebx
  801573:	5e                   	pop    %esi
  801574:	5f                   	pop    %edi
  801575:	5d                   	pop    %ebp
  801576:	c3                   	ret    

00801577 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	56                   	push   %esi
  80157b:	53                   	push   %ebx
  80157c:	83 ec 18             	sub    $0x18,%esp
  80157f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801582:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	53                   	push   %ebx
  801587:	e8 b4 fc ff ff       	call   801240 <fd_lookup>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 37                	js     8015ca <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801593:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	ff 36                	push   (%esi)
  80159f:	e8 ec fc ff ff       	call   801290 <dev_lookup>
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 1f                	js     8015ca <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ab:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015af:	74 20                	je     8015d1 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	74 37                	je     8015f2 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015bb:	83 ec 04             	sub    $0x4,%esp
  8015be:	ff 75 10             	push   0x10(%ebp)
  8015c1:	ff 75 0c             	push   0xc(%ebp)
  8015c4:	56                   	push   %esi
  8015c5:	ff d0                	call   *%eax
  8015c7:	83 c4 10             	add    $0x10,%esp
}
  8015ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d1:	a1 00 40 80 00       	mov    0x804000,%eax
  8015d6:	8b 40 48             	mov    0x48(%eax),%eax
  8015d9:	83 ec 04             	sub    $0x4,%esp
  8015dc:	53                   	push   %ebx
  8015dd:	50                   	push   %eax
  8015de:	68 b5 2a 80 00       	push   $0x802ab5
  8015e3:	e8 47 ec ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f0:	eb d8                	jmp    8015ca <write+0x53>
		return -E_NOT_SUPP;
  8015f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015f7:	eb d1                	jmp    8015ca <write+0x53>

008015f9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	ff 75 08             	push   0x8(%ebp)
  801606:	e8 35 fc ff ff       	call   801240 <fd_lookup>
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 0e                	js     801620 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801612:	8b 55 0c             	mov    0xc(%ebp),%edx
  801615:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801618:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80161b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801620:	c9                   	leave  
  801621:	c3                   	ret    

00801622 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	56                   	push   %esi
  801626:	53                   	push   %ebx
  801627:	83 ec 18             	sub    $0x18,%esp
  80162a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	53                   	push   %ebx
  801632:	e8 09 fc ff ff       	call   801240 <fd_lookup>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 34                	js     801672 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	ff 36                	push   (%esi)
  80164a:	e8 41 fc ff ff       	call   801290 <dev_lookup>
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 1c                	js     801672 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801656:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80165a:	74 1d                	je     801679 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80165c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165f:	8b 40 18             	mov    0x18(%eax),%eax
  801662:	85 c0                	test   %eax,%eax
  801664:	74 34                	je     80169a <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	ff 75 0c             	push   0xc(%ebp)
  80166c:	56                   	push   %esi
  80166d:	ff d0                	call   *%eax
  80166f:	83 c4 10             	add    $0x10,%esp
}
  801672:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    
			thisenv->env_id, fdnum);
  801679:	a1 00 40 80 00       	mov    0x804000,%eax
  80167e:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801681:	83 ec 04             	sub    $0x4,%esp
  801684:	53                   	push   %ebx
  801685:	50                   	push   %eax
  801686:	68 78 2a 80 00       	push   $0x802a78
  80168b:	e8 9f eb ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801698:	eb d8                	jmp    801672 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80169a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80169f:	eb d1                	jmp    801672 <ftruncate+0x50>

008016a1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 18             	sub    $0x18,%esp
  8016a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	ff 75 08             	push   0x8(%ebp)
  8016b3:	e8 88 fb ff ff       	call   801240 <fd_lookup>
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 49                	js     801708 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bf:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	ff 36                	push   (%esi)
  8016cb:	e8 c0 fb ff ff       	call   801290 <dev_lookup>
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 31                	js     801708 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016da:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016de:	74 2f                	je     80170f <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ea:	00 00 00 
	stat->st_isdir = 0;
  8016ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f4:	00 00 00 
	stat->st_dev = dev;
  8016f7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	53                   	push   %ebx
  801701:	56                   	push   %esi
  801702:	ff 50 14             	call   *0x14(%eax)
  801705:	83 c4 10             	add    $0x10,%esp
}
  801708:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    
		return -E_NOT_SUPP;
  80170f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801714:	eb f2                	jmp    801708 <fstat+0x67>

00801716 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	56                   	push   %esi
  80171a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	6a 00                	push   $0x0
  801720:	ff 75 08             	push   0x8(%ebp)
  801723:	e8 e4 01 00 00       	call   80190c <open>
  801728:	89 c3                	mov    %eax,%ebx
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 1b                	js     80174c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	ff 75 0c             	push   0xc(%ebp)
  801737:	50                   	push   %eax
  801738:	e8 64 ff ff ff       	call   8016a1 <fstat>
  80173d:	89 c6                	mov    %eax,%esi
	close(fd);
  80173f:	89 1c 24             	mov    %ebx,(%esp)
  801742:	e8 26 fc ff ff       	call   80136d <close>
	return r;
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	89 f3                	mov    %esi,%ebx
}
  80174c:	89 d8                	mov    %ebx,%eax
  80174e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801751:	5b                   	pop    %ebx
  801752:	5e                   	pop    %esi
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	56                   	push   %esi
  801759:	53                   	push   %ebx
  80175a:	89 c6                	mov    %eax,%esi
  80175c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80175e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801765:	74 27                	je     80178e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801767:	6a 07                	push   $0x7
  801769:	68 00 50 80 00       	push   $0x805000
  80176e:	56                   	push   %esi
  80176f:	ff 35 00 60 80 00    	push   0x806000
  801775:	e8 c2 f9 ff ff       	call   80113c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80177a:	83 c4 0c             	add    $0xc,%esp
  80177d:	6a 00                	push   $0x0
  80177f:	53                   	push   %ebx
  801780:	6a 00                	push   $0x0
  801782:	e8 4e f9 ff ff       	call   8010d5 <ipc_recv>
}
  801787:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80178e:	83 ec 0c             	sub    $0xc,%esp
  801791:	6a 01                	push   $0x1
  801793:	e8 f8 f9 ff ff       	call   801190 <ipc_find_env>
  801798:	a3 00 60 80 00       	mov    %eax,0x806000
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	eb c5                	jmp    801767 <fsipc+0x12>

008017a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c5:	e8 8b ff ff ff       	call   801755 <fsipc>
}
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <devfile_flush>:
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017e7:	e8 69 ff ff ff       	call   801755 <fsipc>
}
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <devfile_stat>:
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 04             	sub    $0x4,%esp
  8017f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801803:	ba 00 00 00 00       	mov    $0x0,%edx
  801808:	b8 05 00 00 00       	mov    $0x5,%eax
  80180d:	e8 43 ff ff ff       	call   801755 <fsipc>
  801812:	85 c0                	test   %eax,%eax
  801814:	78 2c                	js     801842 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	68 00 50 80 00       	push   $0x805000
  80181e:	53                   	push   %ebx
  80181f:	e8 e5 ef ff ff       	call   800809 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801824:	a1 80 50 80 00       	mov    0x805080,%eax
  801829:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80182f:	a1 84 50 80 00       	mov    0x805084,%eax
  801834:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801842:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801845:	c9                   	leave  
  801846:	c3                   	ret    

00801847 <devfile_write>:
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	83 ec 0c             	sub    $0xc,%esp
  80184d:	8b 45 10             	mov    0x10(%ebp),%eax
  801850:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801855:	39 d0                	cmp    %edx,%eax
  801857:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80185a:	8b 55 08             	mov    0x8(%ebp),%edx
  80185d:	8b 52 0c             	mov    0xc(%edx),%edx
  801860:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801866:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80186b:	50                   	push   %eax
  80186c:	ff 75 0c             	push   0xc(%ebp)
  80186f:	68 08 50 80 00       	push   $0x805008
  801874:	e8 26 f1 ff ff       	call   80099f <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801879:	ba 00 00 00 00       	mov    $0x0,%edx
  80187e:	b8 04 00 00 00       	mov    $0x4,%eax
  801883:	e8 cd fe ff ff       	call   801755 <fsipc>
}
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <devfile_read>:
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	56                   	push   %esi
  80188e:	53                   	push   %ebx
  80188f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801892:	8b 45 08             	mov    0x8(%ebp),%eax
  801895:	8b 40 0c             	mov    0xc(%eax),%eax
  801898:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80189d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ad:	e8 a3 fe ff ff       	call   801755 <fsipc>
  8018b2:	89 c3                	mov    %eax,%ebx
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 1f                	js     8018d7 <devfile_read+0x4d>
	assert(r <= n);
  8018b8:	39 f0                	cmp    %esi,%eax
  8018ba:	77 24                	ja     8018e0 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018bc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c1:	7f 33                	jg     8018f6 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c3:	83 ec 04             	sub    $0x4,%esp
  8018c6:	50                   	push   %eax
  8018c7:	68 00 50 80 00       	push   $0x805000
  8018cc:	ff 75 0c             	push   0xc(%ebp)
  8018cf:	e8 cb f0 ff ff       	call   80099f <memmove>
	return r;
  8018d4:	83 c4 10             	add    $0x10,%esp
}
  8018d7:	89 d8                	mov    %ebx,%eax
  8018d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018dc:	5b                   	pop    %ebx
  8018dd:	5e                   	pop    %esi
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    
	assert(r <= n);
  8018e0:	68 e8 2a 80 00       	push   $0x802ae8
  8018e5:	68 ef 2a 80 00       	push   $0x802aef
  8018ea:	6a 7c                	push   $0x7c
  8018ec:	68 04 2b 80 00       	push   $0x802b04
  8018f1:	e8 5e e8 ff ff       	call   800154 <_panic>
	assert(r <= PGSIZE);
  8018f6:	68 0f 2b 80 00       	push   $0x802b0f
  8018fb:	68 ef 2a 80 00       	push   $0x802aef
  801900:	6a 7d                	push   $0x7d
  801902:	68 04 2b 80 00       	push   $0x802b04
  801907:	e8 48 e8 ff ff       	call   800154 <_panic>

0080190c <open>:
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	56                   	push   %esi
  801910:	53                   	push   %ebx
  801911:	83 ec 1c             	sub    $0x1c,%esp
  801914:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801917:	56                   	push   %esi
  801918:	e8 b1 ee ff ff       	call   8007ce <strlen>
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801925:	7f 6c                	jg     801993 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801927:	83 ec 0c             	sub    $0xc,%esp
  80192a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192d:	50                   	push   %eax
  80192e:	e8 bd f8 ff ff       	call   8011f0 <fd_alloc>
  801933:	89 c3                	mov    %eax,%ebx
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 3c                	js     801978 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	56                   	push   %esi
  801940:	68 00 50 80 00       	push   $0x805000
  801945:	e8 bf ee ff ff       	call   800809 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80194a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194d:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801952:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801955:	b8 01 00 00 00       	mov    $0x1,%eax
  80195a:	e8 f6 fd ff ff       	call   801755 <fsipc>
  80195f:	89 c3                	mov    %eax,%ebx
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	85 c0                	test   %eax,%eax
  801966:	78 19                	js     801981 <open+0x75>
	return fd2num(fd);
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	ff 75 f4             	push   -0xc(%ebp)
  80196e:	e8 56 f8 ff ff       	call   8011c9 <fd2num>
  801973:	89 c3                	mov    %eax,%ebx
  801975:	83 c4 10             	add    $0x10,%esp
}
  801978:	89 d8                	mov    %ebx,%eax
  80197a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197d:	5b                   	pop    %ebx
  80197e:	5e                   	pop    %esi
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    
		fd_close(fd, 0);
  801981:	83 ec 08             	sub    $0x8,%esp
  801984:	6a 00                	push   $0x0
  801986:	ff 75 f4             	push   -0xc(%ebp)
  801989:	e8 58 f9 ff ff       	call   8012e6 <fd_close>
		return r;
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	eb e5                	jmp    801978 <open+0x6c>
		return -E_BAD_PATH;
  801993:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801998:	eb de                	jmp    801978 <open+0x6c>

0080199a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8019aa:	e8 a6 fd ff ff       	call   801755 <fsipc>
}
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019b7:	68 1b 2b 80 00       	push   $0x802b1b
  8019bc:	ff 75 0c             	push   0xc(%ebp)
  8019bf:	e8 45 ee ff ff       	call   800809 <strcpy>
	return 0;
}
  8019c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <devsock_close>:
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	53                   	push   %ebx
  8019cf:	83 ec 10             	sub    $0x10,%esp
  8019d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019d5:	53                   	push   %ebx
  8019d6:	e8 98 09 00 00       	call   802373 <pageref>
  8019db:	89 c2                	mov    %eax,%edx
  8019dd:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019e5:	83 fa 01             	cmp    $0x1,%edx
  8019e8:	74 05                	je     8019ef <devsock_close+0x24>
}
  8019ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8019ef:	83 ec 0c             	sub    $0xc,%esp
  8019f2:	ff 73 0c             	push   0xc(%ebx)
  8019f5:	e8 b7 02 00 00       	call   801cb1 <nsipc_close>
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	eb eb                	jmp    8019ea <devsock_close+0x1f>

008019ff <devsock_write>:
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a05:	6a 00                	push   $0x0
  801a07:	ff 75 10             	push   0x10(%ebp)
  801a0a:	ff 75 0c             	push   0xc(%ebp)
  801a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a10:	ff 70 0c             	push   0xc(%eax)
  801a13:	e8 79 03 00 00       	call   801d91 <nsipc_send>
}
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <devsock_read>:
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a20:	6a 00                	push   $0x0
  801a22:	ff 75 10             	push   0x10(%ebp)
  801a25:	ff 75 0c             	push   0xc(%ebp)
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	ff 70 0c             	push   0xc(%eax)
  801a2e:	e8 ef 02 00 00       	call   801d22 <nsipc_recv>
}
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <fd2sockid>:
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a3b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a3e:	52                   	push   %edx
  801a3f:	50                   	push   %eax
  801a40:	e8 fb f7 ff ff       	call   801240 <fd_lookup>
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	78 10                	js     801a5c <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4f:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a55:	39 08                	cmp    %ecx,(%eax)
  801a57:	75 05                	jne    801a5e <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a59:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    
		return -E_NOT_SUPP;
  801a5e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a63:	eb f7                	jmp    801a5c <fd2sockid+0x27>

00801a65 <alloc_sockfd>:
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 1c             	sub    $0x1c,%esp
  801a6d:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a72:	50                   	push   %eax
  801a73:	e8 78 f7 ff ff       	call   8011f0 <fd_alloc>
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 43                	js     801ac4 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a81:	83 ec 04             	sub    $0x4,%esp
  801a84:	68 07 04 00 00       	push   $0x407
  801a89:	ff 75 f4             	push   -0xc(%ebp)
  801a8c:	6a 00                	push   $0x0
  801a8e:	e8 72 f1 ff ff       	call   800c05 <sys_page_alloc>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 28                	js     801ac4 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aa5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aaa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ab1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ab4:	83 ec 0c             	sub    $0xc,%esp
  801ab7:	50                   	push   %eax
  801ab8:	e8 0c f7 ff ff       	call   8011c9 <fd2num>
  801abd:	89 c3                	mov    %eax,%ebx
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	eb 0c                	jmp    801ad0 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	56                   	push   %esi
  801ac8:	e8 e4 01 00 00       	call   801cb1 <nsipc_close>
		return r;
  801acd:	83 c4 10             	add    $0x10,%esp
}
  801ad0:	89 d8                	mov    %ebx,%eax
  801ad2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad5:	5b                   	pop    %ebx
  801ad6:	5e                   	pop    %esi
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    

00801ad9 <accept>:
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801adf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae2:	e8 4e ff ff ff       	call   801a35 <fd2sockid>
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 1b                	js     801b06 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aeb:	83 ec 04             	sub    $0x4,%esp
  801aee:	ff 75 10             	push   0x10(%ebp)
  801af1:	ff 75 0c             	push   0xc(%ebp)
  801af4:	50                   	push   %eax
  801af5:	e8 0e 01 00 00       	call   801c08 <nsipc_accept>
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	85 c0                	test   %eax,%eax
  801aff:	78 05                	js     801b06 <accept+0x2d>
	return alloc_sockfd(r);
  801b01:	e8 5f ff ff ff       	call   801a65 <alloc_sockfd>
}
  801b06:	c9                   	leave  
  801b07:	c3                   	ret    

00801b08 <bind>:
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b11:	e8 1f ff ff ff       	call   801a35 <fd2sockid>
  801b16:	85 c0                	test   %eax,%eax
  801b18:	78 12                	js     801b2c <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b1a:	83 ec 04             	sub    $0x4,%esp
  801b1d:	ff 75 10             	push   0x10(%ebp)
  801b20:	ff 75 0c             	push   0xc(%ebp)
  801b23:	50                   	push   %eax
  801b24:	e8 31 01 00 00       	call   801c5a <nsipc_bind>
  801b29:	83 c4 10             	add    $0x10,%esp
}
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <shutdown>:
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
  801b37:	e8 f9 fe ff ff       	call   801a35 <fd2sockid>
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 0f                	js     801b4f <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b40:	83 ec 08             	sub    $0x8,%esp
  801b43:	ff 75 0c             	push   0xc(%ebp)
  801b46:	50                   	push   %eax
  801b47:	e8 43 01 00 00       	call   801c8f <nsipc_shutdown>
  801b4c:	83 c4 10             	add    $0x10,%esp
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <connect>:
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b57:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5a:	e8 d6 fe ff ff       	call   801a35 <fd2sockid>
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 12                	js     801b75 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b63:	83 ec 04             	sub    $0x4,%esp
  801b66:	ff 75 10             	push   0x10(%ebp)
  801b69:	ff 75 0c             	push   0xc(%ebp)
  801b6c:	50                   	push   %eax
  801b6d:	e8 59 01 00 00       	call   801ccb <nsipc_connect>
  801b72:	83 c4 10             	add    $0x10,%esp
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <listen>:
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b80:	e8 b0 fe ff ff       	call   801a35 <fd2sockid>
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 0f                	js     801b98 <listen+0x21>
	return nsipc_listen(r, backlog);
  801b89:	83 ec 08             	sub    $0x8,%esp
  801b8c:	ff 75 0c             	push   0xc(%ebp)
  801b8f:	50                   	push   %eax
  801b90:	e8 6b 01 00 00       	call   801d00 <nsipc_listen>
  801b95:	83 c4 10             	add    $0x10,%esp
}
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <socket>:

int
socket(int domain, int type, int protocol)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ba0:	ff 75 10             	push   0x10(%ebp)
  801ba3:	ff 75 0c             	push   0xc(%ebp)
  801ba6:	ff 75 08             	push   0x8(%ebp)
  801ba9:	e8 41 02 00 00       	call   801def <nsipc_socket>
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 05                	js     801bba <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bb5:	e8 ab fe ff ff       	call   801a65 <alloc_sockfd>
}
  801bba:	c9                   	leave  
  801bbb:	c3                   	ret    

00801bbc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	53                   	push   %ebx
  801bc0:	83 ec 04             	sub    $0x4,%esp
  801bc3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bc5:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801bcc:	74 26                	je     801bf4 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bce:	6a 07                	push   $0x7
  801bd0:	68 00 70 80 00       	push   $0x807000
  801bd5:	53                   	push   %ebx
  801bd6:	ff 35 00 80 80 00    	push   0x808000
  801bdc:	e8 5b f5 ff ff       	call   80113c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801be1:	83 c4 0c             	add    $0xc,%esp
  801be4:	6a 00                	push   $0x0
  801be6:	6a 00                	push   $0x0
  801be8:	6a 00                	push   $0x0
  801bea:	e8 e6 f4 ff ff       	call   8010d5 <ipc_recv>
}
  801bef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf2:	c9                   	leave  
  801bf3:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bf4:	83 ec 0c             	sub    $0xc,%esp
  801bf7:	6a 02                	push   $0x2
  801bf9:	e8 92 f5 ff ff       	call   801190 <ipc_find_env>
  801bfe:	a3 00 80 80 00       	mov    %eax,0x808000
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	eb c6                	jmp    801bce <nsipc+0x12>

00801c08 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c10:	8b 45 08             	mov    0x8(%ebp),%eax
  801c13:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c18:	8b 06                	mov    (%esi),%eax
  801c1a:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c1f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c24:	e8 93 ff ff ff       	call   801bbc <nsipc>
  801c29:	89 c3                	mov    %eax,%ebx
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	79 09                	jns    801c38 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c2f:	89 d8                	mov    %ebx,%eax
  801c31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c38:	83 ec 04             	sub    $0x4,%esp
  801c3b:	ff 35 10 70 80 00    	push   0x807010
  801c41:	68 00 70 80 00       	push   $0x807000
  801c46:	ff 75 0c             	push   0xc(%ebp)
  801c49:	e8 51 ed ff ff       	call   80099f <memmove>
		*addrlen = ret->ret_addrlen;
  801c4e:	a1 10 70 80 00       	mov    0x807010,%eax
  801c53:	89 06                	mov    %eax,(%esi)
  801c55:	83 c4 10             	add    $0x10,%esp
	return r;
  801c58:	eb d5                	jmp    801c2f <nsipc_accept+0x27>

00801c5a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	53                   	push   %ebx
  801c5e:	83 ec 08             	sub    $0x8,%esp
  801c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c6c:	53                   	push   %ebx
  801c6d:	ff 75 0c             	push   0xc(%ebp)
  801c70:	68 04 70 80 00       	push   $0x807004
  801c75:	e8 25 ed ff ff       	call   80099f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c7a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c80:	b8 02 00 00 00       	mov    $0x2,%eax
  801c85:	e8 32 ff ff ff       	call   801bbc <nsipc>
}
  801c8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca0:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ca5:	b8 03 00 00 00       	mov    $0x3,%eax
  801caa:	e8 0d ff ff ff       	call   801bbc <nsipc>
}
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <nsipc_close>:

int
nsipc_close(int s)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cba:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801cbf:	b8 04 00 00 00       	mov    $0x4,%eax
  801cc4:	e8 f3 fe ff ff       	call   801bbc <nsipc>
}
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	53                   	push   %ebx
  801ccf:	83 ec 08             	sub    $0x8,%esp
  801cd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cdd:	53                   	push   %ebx
  801cde:	ff 75 0c             	push   0xc(%ebp)
  801ce1:	68 04 70 80 00       	push   $0x807004
  801ce6:	e8 b4 ec ff ff       	call   80099f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ceb:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801cf1:	b8 05 00 00 00       	mov    $0x5,%eax
  801cf6:	e8 c1 fe ff ff       	call   801bbc <nsipc>
}
  801cfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d06:	8b 45 08             	mov    0x8(%ebp),%eax
  801d09:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d11:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d16:	b8 06 00 00 00       	mov    $0x6,%eax
  801d1b:	e8 9c fe ff ff       	call   801bbc <nsipc>
}
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	56                   	push   %esi
  801d26:	53                   	push   %ebx
  801d27:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d32:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d38:	8b 45 14             	mov    0x14(%ebp),%eax
  801d3b:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d40:	b8 07 00 00 00       	mov    $0x7,%eax
  801d45:	e8 72 fe ff ff       	call   801bbc <nsipc>
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	78 22                	js     801d72 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d50:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d55:	39 c6                	cmp    %eax,%esi
  801d57:	0f 4e c6             	cmovle %esi,%eax
  801d5a:	39 c3                	cmp    %eax,%ebx
  801d5c:	7f 1d                	jg     801d7b <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d5e:	83 ec 04             	sub    $0x4,%esp
  801d61:	53                   	push   %ebx
  801d62:	68 00 70 80 00       	push   $0x807000
  801d67:	ff 75 0c             	push   0xc(%ebp)
  801d6a:	e8 30 ec ff ff       	call   80099f <memmove>
  801d6f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d72:	89 d8                	mov    %ebx,%eax
  801d74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5e                   	pop    %esi
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d7b:	68 27 2b 80 00       	push   $0x802b27
  801d80:	68 ef 2a 80 00       	push   $0x802aef
  801d85:	6a 62                	push   $0x62
  801d87:	68 3c 2b 80 00       	push   $0x802b3c
  801d8c:	e8 c3 e3 ff ff       	call   800154 <_panic>

00801d91 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	53                   	push   %ebx
  801d95:	83 ec 04             	sub    $0x4,%esp
  801d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801da3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801da9:	7f 2e                	jg     801dd9 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dab:	83 ec 04             	sub    $0x4,%esp
  801dae:	53                   	push   %ebx
  801daf:	ff 75 0c             	push   0xc(%ebp)
  801db2:	68 0c 70 80 00       	push   $0x80700c
  801db7:	e8 e3 eb ff ff       	call   80099f <memmove>
	nsipcbuf.send.req_size = size;
  801dbc:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801dc2:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc5:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801dca:	b8 08 00 00 00       	mov    $0x8,%eax
  801dcf:	e8 e8 fd ff ff       	call   801bbc <nsipc>
}
  801dd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd7:	c9                   	leave  
  801dd8:	c3                   	ret    
	assert(size < 1600);
  801dd9:	68 48 2b 80 00       	push   $0x802b48
  801dde:	68 ef 2a 80 00       	push   $0x802aef
  801de3:	6a 6d                	push   $0x6d
  801de5:	68 3c 2b 80 00       	push   $0x802b3c
  801dea:	e8 65 e3 ff ff       	call   800154 <_panic>

00801def <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801df5:	8b 45 08             	mov    0x8(%ebp),%eax
  801df8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e00:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801e05:	8b 45 10             	mov    0x10(%ebp),%eax
  801e08:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e0d:	b8 09 00 00 00       	mov    $0x9,%eax
  801e12:	e8 a5 fd ff ff       	call   801bbc <nsipc>
}
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    

00801e19 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	56                   	push   %esi
  801e1d:	53                   	push   %ebx
  801e1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e21:	83 ec 0c             	sub    $0xc,%esp
  801e24:	ff 75 08             	push   0x8(%ebp)
  801e27:	e8 ad f3 ff ff       	call   8011d9 <fd2data>
  801e2c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e2e:	83 c4 08             	add    $0x8,%esp
  801e31:	68 54 2b 80 00       	push   $0x802b54
  801e36:	53                   	push   %ebx
  801e37:	e8 cd e9 ff ff       	call   800809 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e3c:	8b 46 04             	mov    0x4(%esi),%eax
  801e3f:	2b 06                	sub    (%esi),%eax
  801e41:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e47:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e4e:	00 00 00 
	stat->st_dev = &devpipe;
  801e51:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e58:	30 80 00 
	return 0;
}
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	53                   	push   %ebx
  801e6b:	83 ec 0c             	sub    $0xc,%esp
  801e6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e71:	53                   	push   %ebx
  801e72:	6a 00                	push   $0x0
  801e74:	e8 11 ee ff ff       	call   800c8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e79:	89 1c 24             	mov    %ebx,(%esp)
  801e7c:	e8 58 f3 ff ff       	call   8011d9 <fd2data>
  801e81:	83 c4 08             	add    $0x8,%esp
  801e84:	50                   	push   %eax
  801e85:	6a 00                	push   $0x0
  801e87:	e8 fe ed ff ff       	call   800c8a <sys_page_unmap>
}
  801e8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e8f:	c9                   	leave  
  801e90:	c3                   	ret    

00801e91 <_pipeisclosed>:
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	57                   	push   %edi
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	83 ec 1c             	sub    $0x1c,%esp
  801e9a:	89 c7                	mov    %eax,%edi
  801e9c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e9e:	a1 00 40 80 00       	mov    0x804000,%eax
  801ea3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	57                   	push   %edi
  801eaa:	e8 c4 04 00 00       	call   802373 <pageref>
  801eaf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801eb2:	89 34 24             	mov    %esi,(%esp)
  801eb5:	e8 b9 04 00 00       	call   802373 <pageref>
		nn = thisenv->env_runs;
  801eba:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ec0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	39 cb                	cmp    %ecx,%ebx
  801ec8:	74 1b                	je     801ee5 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801eca:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ecd:	75 cf                	jne    801e9e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ecf:	8b 42 58             	mov    0x58(%edx),%eax
  801ed2:	6a 01                	push   $0x1
  801ed4:	50                   	push   %eax
  801ed5:	53                   	push   %ebx
  801ed6:	68 5b 2b 80 00       	push   $0x802b5b
  801edb:	e8 4f e3 ff ff       	call   80022f <cprintf>
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	eb b9                	jmp    801e9e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ee5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ee8:	0f 94 c0             	sete   %al
  801eeb:	0f b6 c0             	movzbl %al,%eax
}
  801eee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef1:	5b                   	pop    %ebx
  801ef2:	5e                   	pop    %esi
  801ef3:	5f                   	pop    %edi
  801ef4:	5d                   	pop    %ebp
  801ef5:	c3                   	ret    

00801ef6 <devpipe_write>:
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	57                   	push   %edi
  801efa:	56                   	push   %esi
  801efb:	53                   	push   %ebx
  801efc:	83 ec 28             	sub    $0x28,%esp
  801eff:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f02:	56                   	push   %esi
  801f03:	e8 d1 f2 ff ff       	call   8011d9 <fd2data>
  801f08:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	bf 00 00 00 00       	mov    $0x0,%edi
  801f12:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f15:	75 09                	jne    801f20 <devpipe_write+0x2a>
	return i;
  801f17:	89 f8                	mov    %edi,%eax
  801f19:	eb 23                	jmp    801f3e <devpipe_write+0x48>
			sys_yield();
  801f1b:	e8 c6 ec ff ff       	call   800be6 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f20:	8b 43 04             	mov    0x4(%ebx),%eax
  801f23:	8b 0b                	mov    (%ebx),%ecx
  801f25:	8d 51 20             	lea    0x20(%ecx),%edx
  801f28:	39 d0                	cmp    %edx,%eax
  801f2a:	72 1a                	jb     801f46 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f2c:	89 da                	mov    %ebx,%edx
  801f2e:	89 f0                	mov    %esi,%eax
  801f30:	e8 5c ff ff ff       	call   801e91 <_pipeisclosed>
  801f35:	85 c0                	test   %eax,%eax
  801f37:	74 e2                	je     801f1b <devpipe_write+0x25>
				return 0;
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f41:	5b                   	pop    %ebx
  801f42:	5e                   	pop    %esi
  801f43:	5f                   	pop    %edi
  801f44:	5d                   	pop    %ebp
  801f45:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f49:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f4d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f50:	89 c2                	mov    %eax,%edx
  801f52:	c1 fa 1f             	sar    $0x1f,%edx
  801f55:	89 d1                	mov    %edx,%ecx
  801f57:	c1 e9 1b             	shr    $0x1b,%ecx
  801f5a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f5d:	83 e2 1f             	and    $0x1f,%edx
  801f60:	29 ca                	sub    %ecx,%edx
  801f62:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f66:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f6a:	83 c0 01             	add    $0x1,%eax
  801f6d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f70:	83 c7 01             	add    $0x1,%edi
  801f73:	eb 9d                	jmp    801f12 <devpipe_write+0x1c>

00801f75 <devpipe_read>:
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	57                   	push   %edi
  801f79:	56                   	push   %esi
  801f7a:	53                   	push   %ebx
  801f7b:	83 ec 18             	sub    $0x18,%esp
  801f7e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f81:	57                   	push   %edi
  801f82:	e8 52 f2 ff ff       	call   8011d9 <fd2data>
  801f87:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	be 00 00 00 00       	mov    $0x0,%esi
  801f91:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f94:	75 13                	jne    801fa9 <devpipe_read+0x34>
	return i;
  801f96:	89 f0                	mov    %esi,%eax
  801f98:	eb 02                	jmp    801f9c <devpipe_read+0x27>
				return i;
  801f9a:	89 f0                	mov    %esi,%eax
}
  801f9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9f:	5b                   	pop    %ebx
  801fa0:	5e                   	pop    %esi
  801fa1:	5f                   	pop    %edi
  801fa2:	5d                   	pop    %ebp
  801fa3:	c3                   	ret    
			sys_yield();
  801fa4:	e8 3d ec ff ff       	call   800be6 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801fa9:	8b 03                	mov    (%ebx),%eax
  801fab:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fae:	75 18                	jne    801fc8 <devpipe_read+0x53>
			if (i > 0)
  801fb0:	85 f6                	test   %esi,%esi
  801fb2:	75 e6                	jne    801f9a <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801fb4:	89 da                	mov    %ebx,%edx
  801fb6:	89 f8                	mov    %edi,%eax
  801fb8:	e8 d4 fe ff ff       	call   801e91 <_pipeisclosed>
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	74 e3                	je     801fa4 <devpipe_read+0x2f>
				return 0;
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc6:	eb d4                	jmp    801f9c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fc8:	99                   	cltd   
  801fc9:	c1 ea 1b             	shr    $0x1b,%edx
  801fcc:	01 d0                	add    %edx,%eax
  801fce:	83 e0 1f             	and    $0x1f,%eax
  801fd1:	29 d0                	sub    %edx,%eax
  801fd3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fdb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801fde:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801fe1:	83 c6 01             	add    $0x1,%esi
  801fe4:	eb ab                	jmp    801f91 <devpipe_read+0x1c>

00801fe6 <pipe>:
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	56                   	push   %esi
  801fea:	53                   	push   %ebx
  801feb:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff1:	50                   	push   %eax
  801ff2:	e8 f9 f1 ff ff       	call   8011f0 <fd_alloc>
  801ff7:	89 c3                	mov    %eax,%ebx
  801ff9:	83 c4 10             	add    $0x10,%esp
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	0f 88 23 01 00 00    	js     802127 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802004:	83 ec 04             	sub    $0x4,%esp
  802007:	68 07 04 00 00       	push   $0x407
  80200c:	ff 75 f4             	push   -0xc(%ebp)
  80200f:	6a 00                	push   $0x0
  802011:	e8 ef eb ff ff       	call   800c05 <sys_page_alloc>
  802016:	89 c3                	mov    %eax,%ebx
  802018:	83 c4 10             	add    $0x10,%esp
  80201b:	85 c0                	test   %eax,%eax
  80201d:	0f 88 04 01 00 00    	js     802127 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802023:	83 ec 0c             	sub    $0xc,%esp
  802026:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802029:	50                   	push   %eax
  80202a:	e8 c1 f1 ff ff       	call   8011f0 <fd_alloc>
  80202f:	89 c3                	mov    %eax,%ebx
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	85 c0                	test   %eax,%eax
  802036:	0f 88 db 00 00 00    	js     802117 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80203c:	83 ec 04             	sub    $0x4,%esp
  80203f:	68 07 04 00 00       	push   $0x407
  802044:	ff 75 f0             	push   -0x10(%ebp)
  802047:	6a 00                	push   $0x0
  802049:	e8 b7 eb ff ff       	call   800c05 <sys_page_alloc>
  80204e:	89 c3                	mov    %eax,%ebx
  802050:	83 c4 10             	add    $0x10,%esp
  802053:	85 c0                	test   %eax,%eax
  802055:	0f 88 bc 00 00 00    	js     802117 <pipe+0x131>
	va = fd2data(fd0);
  80205b:	83 ec 0c             	sub    $0xc,%esp
  80205e:	ff 75 f4             	push   -0xc(%ebp)
  802061:	e8 73 f1 ff ff       	call   8011d9 <fd2data>
  802066:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802068:	83 c4 0c             	add    $0xc,%esp
  80206b:	68 07 04 00 00       	push   $0x407
  802070:	50                   	push   %eax
  802071:	6a 00                	push   $0x0
  802073:	e8 8d eb ff ff       	call   800c05 <sys_page_alloc>
  802078:	89 c3                	mov    %eax,%ebx
  80207a:	83 c4 10             	add    $0x10,%esp
  80207d:	85 c0                	test   %eax,%eax
  80207f:	0f 88 82 00 00 00    	js     802107 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802085:	83 ec 0c             	sub    $0xc,%esp
  802088:	ff 75 f0             	push   -0x10(%ebp)
  80208b:	e8 49 f1 ff ff       	call   8011d9 <fd2data>
  802090:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802097:	50                   	push   %eax
  802098:	6a 00                	push   $0x0
  80209a:	56                   	push   %esi
  80209b:	6a 00                	push   $0x0
  80209d:	e8 a6 eb ff ff       	call   800c48 <sys_page_map>
  8020a2:	89 c3                	mov    %eax,%ebx
  8020a4:	83 c4 20             	add    $0x20,%esp
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	78 4e                	js     8020f9 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8020ab:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8020b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020b3:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8020b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020b8:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020c2:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020c7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020ce:	83 ec 0c             	sub    $0xc,%esp
  8020d1:	ff 75 f4             	push   -0xc(%ebp)
  8020d4:	e8 f0 f0 ff ff       	call   8011c9 <fd2num>
  8020d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020dc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020de:	83 c4 04             	add    $0x4,%esp
  8020e1:	ff 75 f0             	push   -0x10(%ebp)
  8020e4:	e8 e0 f0 ff ff       	call   8011c9 <fd2num>
  8020e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020f7:	eb 2e                	jmp    802127 <pipe+0x141>
	sys_page_unmap(0, va);
  8020f9:	83 ec 08             	sub    $0x8,%esp
  8020fc:	56                   	push   %esi
  8020fd:	6a 00                	push   $0x0
  8020ff:	e8 86 eb ff ff       	call   800c8a <sys_page_unmap>
  802104:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802107:	83 ec 08             	sub    $0x8,%esp
  80210a:	ff 75 f0             	push   -0x10(%ebp)
  80210d:	6a 00                	push   $0x0
  80210f:	e8 76 eb ff ff       	call   800c8a <sys_page_unmap>
  802114:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802117:	83 ec 08             	sub    $0x8,%esp
  80211a:	ff 75 f4             	push   -0xc(%ebp)
  80211d:	6a 00                	push   $0x0
  80211f:	e8 66 eb ff ff       	call   800c8a <sys_page_unmap>
  802124:	83 c4 10             	add    $0x10,%esp
}
  802127:	89 d8                	mov    %ebx,%eax
  802129:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80212c:	5b                   	pop    %ebx
  80212d:	5e                   	pop    %esi
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    

00802130 <pipeisclosed>:
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802136:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802139:	50                   	push   %eax
  80213a:	ff 75 08             	push   0x8(%ebp)
  80213d:	e8 fe f0 ff ff       	call   801240 <fd_lookup>
  802142:	83 c4 10             	add    $0x10,%esp
  802145:	85 c0                	test   %eax,%eax
  802147:	78 18                	js     802161 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802149:	83 ec 0c             	sub    $0xc,%esp
  80214c:	ff 75 f4             	push   -0xc(%ebp)
  80214f:	e8 85 f0 ff ff       	call   8011d9 <fd2data>
  802154:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802156:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802159:	e8 33 fd ff ff       	call   801e91 <_pipeisclosed>
  80215e:	83 c4 10             	add    $0x10,%esp
}
  802161:	c9                   	leave  
  802162:	c3                   	ret    

00802163 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802163:	b8 00 00 00 00       	mov    $0x0,%eax
  802168:	c3                   	ret    

00802169 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80216f:	68 73 2b 80 00       	push   $0x802b73
  802174:	ff 75 0c             	push   0xc(%ebp)
  802177:	e8 8d e6 ff ff       	call   800809 <strcpy>
	return 0;
}
  80217c:	b8 00 00 00 00       	mov    $0x0,%eax
  802181:	c9                   	leave  
  802182:	c3                   	ret    

00802183 <devcons_write>:
{
  802183:	55                   	push   %ebp
  802184:	89 e5                	mov    %esp,%ebp
  802186:	57                   	push   %edi
  802187:	56                   	push   %esi
  802188:	53                   	push   %ebx
  802189:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80218f:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802194:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80219a:	eb 2e                	jmp    8021ca <devcons_write+0x47>
		m = n - tot;
  80219c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80219f:	29 f3                	sub    %esi,%ebx
  8021a1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8021a6:	39 c3                	cmp    %eax,%ebx
  8021a8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021ab:	83 ec 04             	sub    $0x4,%esp
  8021ae:	53                   	push   %ebx
  8021af:	89 f0                	mov    %esi,%eax
  8021b1:	03 45 0c             	add    0xc(%ebp),%eax
  8021b4:	50                   	push   %eax
  8021b5:	57                   	push   %edi
  8021b6:	e8 e4 e7 ff ff       	call   80099f <memmove>
		sys_cputs(buf, m);
  8021bb:	83 c4 08             	add    $0x8,%esp
  8021be:	53                   	push   %ebx
  8021bf:	57                   	push   %edi
  8021c0:	e8 84 e9 ff ff       	call   800b49 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021c5:	01 de                	add    %ebx,%esi
  8021c7:	83 c4 10             	add    $0x10,%esp
  8021ca:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021cd:	72 cd                	jb     80219c <devcons_write+0x19>
}
  8021cf:	89 f0                	mov    %esi,%eax
  8021d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    

008021d9 <devcons_read>:
{
  8021d9:	55                   	push   %ebp
  8021da:	89 e5                	mov    %esp,%ebp
  8021dc:	83 ec 08             	sub    $0x8,%esp
  8021df:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8021e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021e8:	75 07                	jne    8021f1 <devcons_read+0x18>
  8021ea:	eb 1f                	jmp    80220b <devcons_read+0x32>
		sys_yield();
  8021ec:	e8 f5 e9 ff ff       	call   800be6 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8021f1:	e8 71 e9 ff ff       	call   800b67 <sys_cgetc>
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	74 f2                	je     8021ec <devcons_read+0x13>
	if (c < 0)
  8021fa:	78 0f                	js     80220b <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8021fc:	83 f8 04             	cmp    $0x4,%eax
  8021ff:	74 0c                	je     80220d <devcons_read+0x34>
	*(char*)vbuf = c;
  802201:	8b 55 0c             	mov    0xc(%ebp),%edx
  802204:	88 02                	mov    %al,(%edx)
	return 1;
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80220b:	c9                   	leave  
  80220c:	c3                   	ret    
		return 0;
  80220d:	b8 00 00 00 00       	mov    $0x0,%eax
  802212:	eb f7                	jmp    80220b <devcons_read+0x32>

00802214 <cputchar>:
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80221a:	8b 45 08             	mov    0x8(%ebp),%eax
  80221d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802220:	6a 01                	push   $0x1
  802222:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802225:	50                   	push   %eax
  802226:	e8 1e e9 ff ff       	call   800b49 <sys_cputs>
}
  80222b:	83 c4 10             	add    $0x10,%esp
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    

00802230 <getchar>:
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802236:	6a 01                	push   $0x1
  802238:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80223b:	50                   	push   %eax
  80223c:	6a 00                	push   $0x0
  80223e:	e8 66 f2 ff ff       	call   8014a9 <read>
	if (r < 0)
  802243:	83 c4 10             	add    $0x10,%esp
  802246:	85 c0                	test   %eax,%eax
  802248:	78 06                	js     802250 <getchar+0x20>
	if (r < 1)
  80224a:	74 06                	je     802252 <getchar+0x22>
	return c;
  80224c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802250:	c9                   	leave  
  802251:	c3                   	ret    
		return -E_EOF;
  802252:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802257:	eb f7                	jmp    802250 <getchar+0x20>

00802259 <iscons>:
{
  802259:	55                   	push   %ebp
  80225a:	89 e5                	mov    %esp,%ebp
  80225c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80225f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802262:	50                   	push   %eax
  802263:	ff 75 08             	push   0x8(%ebp)
  802266:	e8 d5 ef ff ff       	call   801240 <fd_lookup>
  80226b:	83 c4 10             	add    $0x10,%esp
  80226e:	85 c0                	test   %eax,%eax
  802270:	78 11                	js     802283 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802272:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802275:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80227b:	39 10                	cmp    %edx,(%eax)
  80227d:	0f 94 c0             	sete   %al
  802280:	0f b6 c0             	movzbl %al,%eax
}
  802283:	c9                   	leave  
  802284:	c3                   	ret    

00802285 <opencons>:
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80228b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228e:	50                   	push   %eax
  80228f:	e8 5c ef ff ff       	call   8011f0 <fd_alloc>
  802294:	83 c4 10             	add    $0x10,%esp
  802297:	85 c0                	test   %eax,%eax
  802299:	78 3a                	js     8022d5 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80229b:	83 ec 04             	sub    $0x4,%esp
  80229e:	68 07 04 00 00       	push   $0x407
  8022a3:	ff 75 f4             	push   -0xc(%ebp)
  8022a6:	6a 00                	push   $0x0
  8022a8:	e8 58 e9 ff ff       	call   800c05 <sys_page_alloc>
  8022ad:	83 c4 10             	add    $0x10,%esp
  8022b0:	85 c0                	test   %eax,%eax
  8022b2:	78 21                	js     8022d5 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8022b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022bd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022c9:	83 ec 0c             	sub    $0xc,%esp
  8022cc:	50                   	push   %eax
  8022cd:	e8 f7 ee ff ff       	call   8011c9 <fd2num>
  8022d2:	83 c4 10             	add    $0x10,%esp
}
  8022d5:	c9                   	leave  
  8022d6:	c3                   	ret    

008022d7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8022dd:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8022e4:	74 0a                	je     8022f0 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e9:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8022ee:	c9                   	leave  
  8022ef:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8022f0:	e8 d2 e8 ff ff       	call   800bc7 <sys_getenvid>
  8022f5:	83 ec 04             	sub    $0x4,%esp
  8022f8:	68 07 0e 00 00       	push   $0xe07
  8022fd:	68 00 f0 bf ee       	push   $0xeebff000
  802302:	50                   	push   %eax
  802303:	e8 fd e8 ff ff       	call   800c05 <sys_page_alloc>
		if (r < 0) {
  802308:	83 c4 10             	add    $0x10,%esp
  80230b:	85 c0                	test   %eax,%eax
  80230d:	78 2c                	js     80233b <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80230f:	e8 b3 e8 ff ff       	call   800bc7 <sys_getenvid>
  802314:	83 ec 08             	sub    $0x8,%esp
  802317:	68 4d 23 80 00       	push   $0x80234d
  80231c:	50                   	push   %eax
  80231d:	e8 2e ea ff ff       	call   800d50 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802322:	83 c4 10             	add    $0x10,%esp
  802325:	85 c0                	test   %eax,%eax
  802327:	79 bd                	jns    8022e6 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802329:	50                   	push   %eax
  80232a:	68 c0 2b 80 00       	push   $0x802bc0
  80232f:	6a 28                	push   $0x28
  802331:	68 f6 2b 80 00       	push   $0x802bf6
  802336:	e8 19 de ff ff       	call   800154 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80233b:	50                   	push   %eax
  80233c:	68 80 2b 80 00       	push   $0x802b80
  802341:	6a 23                	push   $0x23
  802343:	68 f6 2b 80 00       	push   $0x802bf6
  802348:	e8 07 de ff ff       	call   800154 <_panic>

0080234d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80234d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80234e:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802353:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802355:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802358:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80235c:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80235f:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802363:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802367:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802369:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80236c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80236d:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802370:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802371:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802372:	c3                   	ret    

00802373 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802373:	55                   	push   %ebp
  802374:	89 e5                	mov    %esp,%ebp
  802376:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802379:	89 c2                	mov    %eax,%edx
  80237b:	c1 ea 16             	shr    $0x16,%edx
  80237e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802385:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80238a:	f6 c1 01             	test   $0x1,%cl
  80238d:	74 1c                	je     8023ab <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80238f:	c1 e8 0c             	shr    $0xc,%eax
  802392:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802399:	a8 01                	test   $0x1,%al
  80239b:	74 0e                	je     8023ab <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80239d:	c1 e8 0c             	shr    $0xc,%eax
  8023a0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8023a7:	ef 
  8023a8:	0f b7 d2             	movzwl %dx,%edx
}
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	5d                   	pop    %ebp
  8023ae:	c3                   	ret    
  8023af:	90                   	nop

008023b0 <__udivdi3>:
  8023b0:	f3 0f 1e fb          	endbr32 
  8023b4:	55                   	push   %ebp
  8023b5:	57                   	push   %edi
  8023b6:	56                   	push   %esi
  8023b7:	53                   	push   %ebx
  8023b8:	83 ec 1c             	sub    $0x1c,%esp
  8023bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023cb:	85 c0                	test   %eax,%eax
  8023cd:	75 19                	jne    8023e8 <__udivdi3+0x38>
  8023cf:	39 f3                	cmp    %esi,%ebx
  8023d1:	76 4d                	jbe    802420 <__udivdi3+0x70>
  8023d3:	31 ff                	xor    %edi,%edi
  8023d5:	89 e8                	mov    %ebp,%eax
  8023d7:	89 f2                	mov    %esi,%edx
  8023d9:	f7 f3                	div    %ebx
  8023db:	89 fa                	mov    %edi,%edx
  8023dd:	83 c4 1c             	add    $0x1c,%esp
  8023e0:	5b                   	pop    %ebx
  8023e1:	5e                   	pop    %esi
  8023e2:	5f                   	pop    %edi
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    
  8023e5:	8d 76 00             	lea    0x0(%esi),%esi
  8023e8:	39 f0                	cmp    %esi,%eax
  8023ea:	76 14                	jbe    802400 <__udivdi3+0x50>
  8023ec:	31 ff                	xor    %edi,%edi
  8023ee:	31 c0                	xor    %eax,%eax
  8023f0:	89 fa                	mov    %edi,%edx
  8023f2:	83 c4 1c             	add    $0x1c,%esp
  8023f5:	5b                   	pop    %ebx
  8023f6:	5e                   	pop    %esi
  8023f7:	5f                   	pop    %edi
  8023f8:	5d                   	pop    %ebp
  8023f9:	c3                   	ret    
  8023fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802400:	0f bd f8             	bsr    %eax,%edi
  802403:	83 f7 1f             	xor    $0x1f,%edi
  802406:	75 48                	jne    802450 <__udivdi3+0xa0>
  802408:	39 f0                	cmp    %esi,%eax
  80240a:	72 06                	jb     802412 <__udivdi3+0x62>
  80240c:	31 c0                	xor    %eax,%eax
  80240e:	39 eb                	cmp    %ebp,%ebx
  802410:	77 de                	ja     8023f0 <__udivdi3+0x40>
  802412:	b8 01 00 00 00       	mov    $0x1,%eax
  802417:	eb d7                	jmp    8023f0 <__udivdi3+0x40>
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	89 d9                	mov    %ebx,%ecx
  802422:	85 db                	test   %ebx,%ebx
  802424:	75 0b                	jne    802431 <__udivdi3+0x81>
  802426:	b8 01 00 00 00       	mov    $0x1,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	f7 f3                	div    %ebx
  80242f:	89 c1                	mov    %eax,%ecx
  802431:	31 d2                	xor    %edx,%edx
  802433:	89 f0                	mov    %esi,%eax
  802435:	f7 f1                	div    %ecx
  802437:	89 c6                	mov    %eax,%esi
  802439:	89 e8                	mov    %ebp,%eax
  80243b:	89 f7                	mov    %esi,%edi
  80243d:	f7 f1                	div    %ecx
  80243f:	89 fa                	mov    %edi,%edx
  802441:	83 c4 1c             	add    $0x1c,%esp
  802444:	5b                   	pop    %ebx
  802445:	5e                   	pop    %esi
  802446:	5f                   	pop    %edi
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	89 f9                	mov    %edi,%ecx
  802452:	ba 20 00 00 00       	mov    $0x20,%edx
  802457:	29 fa                	sub    %edi,%edx
  802459:	d3 e0                	shl    %cl,%eax
  80245b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80245f:	89 d1                	mov    %edx,%ecx
  802461:	89 d8                	mov    %ebx,%eax
  802463:	d3 e8                	shr    %cl,%eax
  802465:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802469:	09 c1                	or     %eax,%ecx
  80246b:	89 f0                	mov    %esi,%eax
  80246d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802471:	89 f9                	mov    %edi,%ecx
  802473:	d3 e3                	shl    %cl,%ebx
  802475:	89 d1                	mov    %edx,%ecx
  802477:	d3 e8                	shr    %cl,%eax
  802479:	89 f9                	mov    %edi,%ecx
  80247b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80247f:	89 eb                	mov    %ebp,%ebx
  802481:	d3 e6                	shl    %cl,%esi
  802483:	89 d1                	mov    %edx,%ecx
  802485:	d3 eb                	shr    %cl,%ebx
  802487:	09 f3                	or     %esi,%ebx
  802489:	89 c6                	mov    %eax,%esi
  80248b:	89 f2                	mov    %esi,%edx
  80248d:	89 d8                	mov    %ebx,%eax
  80248f:	f7 74 24 08          	divl   0x8(%esp)
  802493:	89 d6                	mov    %edx,%esi
  802495:	89 c3                	mov    %eax,%ebx
  802497:	f7 64 24 0c          	mull   0xc(%esp)
  80249b:	39 d6                	cmp    %edx,%esi
  80249d:	72 19                	jb     8024b8 <__udivdi3+0x108>
  80249f:	89 f9                	mov    %edi,%ecx
  8024a1:	d3 e5                	shl    %cl,%ebp
  8024a3:	39 c5                	cmp    %eax,%ebp
  8024a5:	73 04                	jae    8024ab <__udivdi3+0xfb>
  8024a7:	39 d6                	cmp    %edx,%esi
  8024a9:	74 0d                	je     8024b8 <__udivdi3+0x108>
  8024ab:	89 d8                	mov    %ebx,%eax
  8024ad:	31 ff                	xor    %edi,%edi
  8024af:	e9 3c ff ff ff       	jmp    8023f0 <__udivdi3+0x40>
  8024b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024b8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024bb:	31 ff                	xor    %edi,%edi
  8024bd:	e9 2e ff ff ff       	jmp    8023f0 <__udivdi3+0x40>
  8024c2:	66 90                	xchg   %ax,%ax
  8024c4:	66 90                	xchg   %ax,%ax
  8024c6:	66 90                	xchg   %ax,%ax
  8024c8:	66 90                	xchg   %ax,%ax
  8024ca:	66 90                	xchg   %ax,%ax
  8024cc:	66 90                	xchg   %ax,%ax
  8024ce:	66 90                	xchg   %ax,%ax

008024d0 <__umoddi3>:
  8024d0:	f3 0f 1e fb          	endbr32 
  8024d4:	55                   	push   %ebp
  8024d5:	57                   	push   %edi
  8024d6:	56                   	push   %esi
  8024d7:	53                   	push   %ebx
  8024d8:	83 ec 1c             	sub    $0x1c,%esp
  8024db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024e3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8024e7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8024eb:	89 f0                	mov    %esi,%eax
  8024ed:	89 da                	mov    %ebx,%edx
  8024ef:	85 ff                	test   %edi,%edi
  8024f1:	75 15                	jne    802508 <__umoddi3+0x38>
  8024f3:	39 dd                	cmp    %ebx,%ebp
  8024f5:	76 39                	jbe    802530 <__umoddi3+0x60>
  8024f7:	f7 f5                	div    %ebp
  8024f9:	89 d0                	mov    %edx,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	83 c4 1c             	add    $0x1c,%esp
  802500:	5b                   	pop    %ebx
  802501:	5e                   	pop    %esi
  802502:	5f                   	pop    %edi
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    
  802505:	8d 76 00             	lea    0x0(%esi),%esi
  802508:	39 df                	cmp    %ebx,%edi
  80250a:	77 f1                	ja     8024fd <__umoddi3+0x2d>
  80250c:	0f bd cf             	bsr    %edi,%ecx
  80250f:	83 f1 1f             	xor    $0x1f,%ecx
  802512:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802516:	75 40                	jne    802558 <__umoddi3+0x88>
  802518:	39 df                	cmp    %ebx,%edi
  80251a:	72 04                	jb     802520 <__umoddi3+0x50>
  80251c:	39 f5                	cmp    %esi,%ebp
  80251e:	77 dd                	ja     8024fd <__umoddi3+0x2d>
  802520:	89 da                	mov    %ebx,%edx
  802522:	89 f0                	mov    %esi,%eax
  802524:	29 e8                	sub    %ebp,%eax
  802526:	19 fa                	sbb    %edi,%edx
  802528:	eb d3                	jmp    8024fd <__umoddi3+0x2d>
  80252a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802530:	89 e9                	mov    %ebp,%ecx
  802532:	85 ed                	test   %ebp,%ebp
  802534:	75 0b                	jne    802541 <__umoddi3+0x71>
  802536:	b8 01 00 00 00       	mov    $0x1,%eax
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	f7 f5                	div    %ebp
  80253f:	89 c1                	mov    %eax,%ecx
  802541:	89 d8                	mov    %ebx,%eax
  802543:	31 d2                	xor    %edx,%edx
  802545:	f7 f1                	div    %ecx
  802547:	89 f0                	mov    %esi,%eax
  802549:	f7 f1                	div    %ecx
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	31 d2                	xor    %edx,%edx
  80254f:	eb ac                	jmp    8024fd <__umoddi3+0x2d>
  802551:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802558:	8b 44 24 04          	mov    0x4(%esp),%eax
  80255c:	ba 20 00 00 00       	mov    $0x20,%edx
  802561:	29 c2                	sub    %eax,%edx
  802563:	89 c1                	mov    %eax,%ecx
  802565:	89 e8                	mov    %ebp,%eax
  802567:	d3 e7                	shl    %cl,%edi
  802569:	89 d1                	mov    %edx,%ecx
  80256b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80256f:	d3 e8                	shr    %cl,%eax
  802571:	89 c1                	mov    %eax,%ecx
  802573:	8b 44 24 04          	mov    0x4(%esp),%eax
  802577:	09 f9                	or     %edi,%ecx
  802579:	89 df                	mov    %ebx,%edi
  80257b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257f:	89 c1                	mov    %eax,%ecx
  802581:	d3 e5                	shl    %cl,%ebp
  802583:	89 d1                	mov    %edx,%ecx
  802585:	d3 ef                	shr    %cl,%edi
  802587:	89 c1                	mov    %eax,%ecx
  802589:	89 f0                	mov    %esi,%eax
  80258b:	d3 e3                	shl    %cl,%ebx
  80258d:	89 d1                	mov    %edx,%ecx
  80258f:	89 fa                	mov    %edi,%edx
  802591:	d3 e8                	shr    %cl,%eax
  802593:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802598:	09 d8                	or     %ebx,%eax
  80259a:	f7 74 24 08          	divl   0x8(%esp)
  80259e:	89 d3                	mov    %edx,%ebx
  8025a0:	d3 e6                	shl    %cl,%esi
  8025a2:	f7 e5                	mul    %ebp
  8025a4:	89 c7                	mov    %eax,%edi
  8025a6:	89 d1                	mov    %edx,%ecx
  8025a8:	39 d3                	cmp    %edx,%ebx
  8025aa:	72 06                	jb     8025b2 <__umoddi3+0xe2>
  8025ac:	75 0e                	jne    8025bc <__umoddi3+0xec>
  8025ae:	39 c6                	cmp    %eax,%esi
  8025b0:	73 0a                	jae    8025bc <__umoddi3+0xec>
  8025b2:	29 e8                	sub    %ebp,%eax
  8025b4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8025b8:	89 d1                	mov    %edx,%ecx
  8025ba:	89 c7                	mov    %eax,%edi
  8025bc:	89 f5                	mov    %esi,%ebp
  8025be:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025c2:	29 fd                	sub    %edi,%ebp
  8025c4:	19 cb                	sbb    %ecx,%ebx
  8025c6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8025cb:	89 d8                	mov    %ebx,%eax
  8025cd:	d3 e0                	shl    %cl,%eax
  8025cf:	89 f1                	mov    %esi,%ecx
  8025d1:	d3 ed                	shr    %cl,%ebp
  8025d3:	d3 eb                	shr    %cl,%ebx
  8025d5:	09 e8                	or     %ebp,%eax
  8025d7:	89 da                	mov    %ebx,%edx
  8025d9:	83 c4 1c             	add    $0x1c,%esp
  8025dc:	5b                   	pop    %ebx
  8025dd:	5e                   	pop    %esi
  8025de:	5f                   	pop    %edi
  8025df:	5d                   	pop    %ebp
  8025e0:	c3                   	ret    
