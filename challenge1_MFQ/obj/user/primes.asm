
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
  800047:	e8 8f 10 00 00       	call   8010db <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 00 40 80 00       	mov    0x804000,%eax
  800053:	8b 40 6c             	mov    0x6c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 20 26 80 00       	push   $0x802620
  800060:	e8 cd 01 00 00       	call   800232 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 ee 0e 00 00       	call   800f58 <fork>
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
  800080:	e8 56 10 00 00       	call   8010db <ipc_recv>
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
  800097:	e8 af 10 00 00       	call   80114b <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb d7                	jmp    800078 <primeproc+0x45>
		panic("fork: %e", id);
  8000a1:	50                   	push   %eax
  8000a2:	68 38 2a 80 00       	push   $0x802a38
  8000a7:	6a 1a                	push   $0x1a
  8000a9:	68 2c 26 80 00       	push   $0x80262c
  8000ae:	e8 a4 00 00 00       	call   800157 <_panic>

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
  8000b8:	e8 9b 0e 00 00       	call   800f58 <fork>
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
  8000d0:	e8 76 10 00 00       	call   80114b <ipc_send>
	for (i = 2; ; i++)
  8000d5:	83 c3 01             	add    $0x1,%ebx
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	eb ed                	jmp    8000ca <umain+0x17>
		panic("fork: %e", id);
  8000dd:	50                   	push   %eax
  8000de:	68 38 2a 80 00       	push   $0x802a38
  8000e3:	6a 2d                	push   $0x2d
  8000e5:	68 2c 26 80 00       	push   $0x80262c
  8000ea:	e8 68 00 00 00       	call   800157 <_panic>
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
  8000ff:	e8 c6 0a 00 00       	call   800bca <sys_getenvid>
  800104:	25 ff 03 00 00       	and    $0x3ff,%eax
  800109:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x30>
		binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
  800129:	e8 85 ff ff ff       	call   8000b3 <umain>

	// exit gracefully
	exit();
  80012e:	e8 0a 00 00 00       	call   80013d <exit>
}
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800143:	e8 67 12 00 00       	call   8013af <close_all>
	sys_env_destroy(0);
  800148:	83 ec 0c             	sub    $0xc,%esp
  80014b:	6a 00                	push   $0x0
  80014d:	e8 37 0a 00 00       	call   800b89 <sys_env_destroy>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800165:	e8 60 0a 00 00       	call   800bca <sys_getenvid>
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	ff 75 0c             	push   0xc(%ebp)
  800170:	ff 75 08             	push   0x8(%ebp)
  800173:	56                   	push   %esi
  800174:	50                   	push   %eax
  800175:	68 44 26 80 00       	push   $0x802644
  80017a:	e8 b3 00 00 00       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017f:	83 c4 18             	add    $0x18,%esp
  800182:	53                   	push   %ebx
  800183:	ff 75 10             	push   0x10(%ebp)
  800186:	e8 56 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  80018b:	c7 04 24 8c 2b 80 00 	movl   $0x802b8c,(%esp)
  800192:	e8 9b 00 00 00       	call   800232 <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019a:	cc                   	int3   
  80019b:	eb fd                	jmp    80019a <_panic+0x43>

0080019d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 04             	sub    $0x4,%esp
  8001a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a7:	8b 13                	mov    (%ebx),%edx
  8001a9:	8d 42 01             	lea    0x1(%edx),%eax
  8001ac:	89 03                	mov    %eax,(%ebx)
  8001ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ba:	74 09                	je     8001c5 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001bc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	68 ff 00 00 00       	push   $0xff
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	50                   	push   %eax
  8001d1:	e8 76 09 00 00       	call   800b4c <sys_cputs>
		b->idx = 0;
  8001d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dc:	83 c4 10             	add    $0x10,%esp
  8001df:	eb db                	jmp    8001bc <putch+0x1f>

008001e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f1:	00 00 00 
	b.cnt = 0;
  8001f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fe:	ff 75 0c             	push   0xc(%ebp)
  800201:	ff 75 08             	push   0x8(%ebp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	68 9d 01 80 00       	push   $0x80019d
  800210:	e8 14 01 00 00       	call   800329 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800215:	83 c4 08             	add    $0x8,%esp
  800218:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80021e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800224:	50                   	push   %eax
  800225:	e8 22 09 00 00       	call   800b4c <sys_cputs>

	return b.cnt;
}
  80022a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 08             	push   0x8(%ebp)
  80023f:	e8 9d ff ff ff       	call   8001e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 1c             	sub    $0x1c,%esp
  80024f:	89 c7                	mov    %eax,%edi
  800251:	89 d6                	mov    %edx,%esi
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	89 d1                	mov    %edx,%ecx
  80025b:	89 c2                	mov    %eax,%edx
  80025d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800260:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800263:	8b 45 10             	mov    0x10(%ebp),%eax
  800266:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800269:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800273:	39 c2                	cmp    %eax,%edx
  800275:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800278:	72 3e                	jb     8002b8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	ff 75 18             	push   0x18(%ebp)
  800280:	83 eb 01             	sub    $0x1,%ebx
  800283:	53                   	push   %ebx
  800284:	50                   	push   %eax
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	push   -0x1c(%ebp)
  80028b:	ff 75 e0             	push   -0x20(%ebp)
  80028e:	ff 75 dc             	push   -0x24(%ebp)
  800291:	ff 75 d8             	push   -0x28(%ebp)
  800294:	e8 37 21 00 00       	call   8023d0 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9f ff ff ff       	call   800246 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 13                	jmp    8002bf <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	push   0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	7f ed                	jg     8002ac <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bf:	83 ec 08             	sub    $0x8,%esp
  8002c2:	56                   	push   %esi
  8002c3:	83 ec 04             	sub    $0x4,%esp
  8002c6:	ff 75 e4             	push   -0x1c(%ebp)
  8002c9:	ff 75 e0             	push   -0x20(%ebp)
  8002cc:	ff 75 dc             	push   -0x24(%ebp)
  8002cf:	ff 75 d8             	push   -0x28(%ebp)
  8002d2:	e8 19 22 00 00       	call   8024f0 <__umoddi3>
  8002d7:	83 c4 14             	add    $0x14,%esp
  8002da:	0f be 80 67 26 80 00 	movsbl 0x802667(%eax),%eax
  8002e1:	50                   	push   %eax
  8002e2:	ff d7                	call   *%edi
}
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fe:	73 0a                	jae    80030a <sprintputch+0x1b>
		*b->buf++ = ch;
  800300:	8d 4a 01             	lea    0x1(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	88 02                	mov    %al,(%edx)
}
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <printfmt>:
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800312:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800315:	50                   	push   %eax
  800316:	ff 75 10             	push   0x10(%ebp)
  800319:	ff 75 0c             	push   0xc(%ebp)
  80031c:	ff 75 08             	push   0x8(%ebp)
  80031f:	e8 05 00 00 00       	call   800329 <vprintfmt>
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	c9                   	leave  
  800328:	c3                   	ret    

00800329 <vprintfmt>:
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 3c             	sub    $0x3c,%esp
  800332:	8b 75 08             	mov    0x8(%ebp),%esi
  800335:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800338:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033b:	eb 0a                	jmp    800347 <vprintfmt+0x1e>
			putch(ch, putdat);
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	53                   	push   %ebx
  800341:	50                   	push   %eax
  800342:	ff d6                	call   *%esi
  800344:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800347:	83 c7 01             	add    $0x1,%edi
  80034a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80034e:	83 f8 25             	cmp    $0x25,%eax
  800351:	74 0c                	je     80035f <vprintfmt+0x36>
			if (ch == '\0')
  800353:	85 c0                	test   %eax,%eax
  800355:	75 e6                	jne    80033d <vprintfmt+0x14>
}
  800357:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    
		padc = ' ';
  80035f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800363:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80036a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800371:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800378:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8d 47 01             	lea    0x1(%edi),%eax
  800380:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800383:	0f b6 17             	movzbl (%edi),%edx
  800386:	8d 42 dd             	lea    -0x23(%edx),%eax
  800389:	3c 55                	cmp    $0x55,%al
  80038b:	0f 87 bb 03 00 00    	ja     80074c <vprintfmt+0x423>
  800391:	0f b6 c0             	movzbl %al,%eax
  800394:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80039e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003a2:	eb d9                	jmp    80037d <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003ab:	eb d0                	jmp    80037d <vprintfmt+0x54>
  8003ad:	0f b6 d2             	movzbl %dl,%edx
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003bb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003be:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c8:	83 f9 09             	cmp    $0x9,%ecx
  8003cb:	77 55                	ja     800422 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003cd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003d0:	eb e9                	jmp    8003bb <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 40 04             	lea    0x4(%eax),%eax
  8003e0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ea:	79 91                	jns    80037d <vprintfmt+0x54>
				width = precision, precision = -1;
  8003ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003f9:	eb 82                	jmp    80037d <vprintfmt+0x54>
  8003fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003fe:	85 d2                	test   %edx,%edx
  800400:	b8 00 00 00 00       	mov    $0x0,%eax
  800405:	0f 49 c2             	cmovns %edx,%eax
  800408:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040e:	e9 6a ff ff ff       	jmp    80037d <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800416:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80041d:	e9 5b ff ff ff       	jmp    80037d <vprintfmt+0x54>
  800422:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800425:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800428:	eb bc                	jmp    8003e6 <vprintfmt+0xbd>
			lflag++;
  80042a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800430:	e9 48 ff ff ff       	jmp    80037d <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 78 04             	lea    0x4(%eax),%edi
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	53                   	push   %ebx
  80043f:	ff 30                	push   (%eax)
  800441:	ff d6                	call   *%esi
			break;
  800443:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800446:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800449:	e9 9d 02 00 00       	jmp    8006eb <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 78 04             	lea    0x4(%eax),%edi
  800454:	8b 10                	mov    (%eax),%edx
  800456:	89 d0                	mov    %edx,%eax
  800458:	f7 d8                	neg    %eax
  80045a:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045d:	83 f8 0f             	cmp    $0xf,%eax
  800460:	7f 23                	jg     800485 <vprintfmt+0x15c>
  800462:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  800469:	85 d2                	test   %edx,%edx
  80046b:	74 18                	je     800485 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80046d:	52                   	push   %edx
  80046e:	68 21 2b 80 00       	push   $0x802b21
  800473:	53                   	push   %ebx
  800474:	56                   	push   %esi
  800475:	e8 92 fe ff ff       	call   80030c <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800480:	e9 66 02 00 00       	jmp    8006eb <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800485:	50                   	push   %eax
  800486:	68 7f 26 80 00       	push   $0x80267f
  80048b:	53                   	push   %ebx
  80048c:	56                   	push   %esi
  80048d:	e8 7a fe ff ff       	call   80030c <printfmt>
  800492:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800495:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800498:	e9 4e 02 00 00       	jmp    8006eb <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	83 c0 04             	add    $0x4,%eax
  8004a3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	b8 78 26 80 00       	mov    $0x802678,%eax
  8004b2:	0f 45 c2             	cmovne %edx,%eax
  8004b5:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bc:	7e 06                	jle    8004c4 <vprintfmt+0x19b>
  8004be:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004c2:	75 0d                	jne    8004d1 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c7:	89 c7                	mov    %eax,%edi
  8004c9:	03 45 e0             	add    -0x20(%ebp),%eax
  8004cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cf:	eb 55                	jmp    800526 <vprintfmt+0x1fd>
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 d8             	push   -0x28(%ebp)
  8004d7:	ff 75 cc             	push   -0x34(%ebp)
  8004da:	e8 0a 03 00 00       	call   8007e9 <strnlen>
  8004df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e2:	29 c1                	sub    %eax,%ecx
  8004e4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004ec:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	eb 0f                	jmp    800504 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	53                   	push   %ebx
  8004f9:	ff 75 e0             	push   -0x20(%ebp)
  8004fc:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fe:	83 ef 01             	sub    $0x1,%edi
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	85 ff                	test   %edi,%edi
  800506:	7f ed                	jg     8004f5 <vprintfmt+0x1cc>
  800508:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80050b:	85 d2                	test   %edx,%edx
  80050d:	b8 00 00 00 00       	mov    $0x0,%eax
  800512:	0f 49 c2             	cmovns %edx,%eax
  800515:	29 c2                	sub    %eax,%edx
  800517:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80051a:	eb a8                	jmp    8004c4 <vprintfmt+0x19b>
					putch(ch, putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	52                   	push   %edx
  800521:	ff d6                	call   *%esi
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800529:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052b:	83 c7 01             	add    $0x1,%edi
  80052e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800532:	0f be d0             	movsbl %al,%edx
  800535:	85 d2                	test   %edx,%edx
  800537:	74 4b                	je     800584 <vprintfmt+0x25b>
  800539:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053d:	78 06                	js     800545 <vprintfmt+0x21c>
  80053f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800543:	78 1e                	js     800563 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800545:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800549:	74 d1                	je     80051c <vprintfmt+0x1f3>
  80054b:	0f be c0             	movsbl %al,%eax
  80054e:	83 e8 20             	sub    $0x20,%eax
  800551:	83 f8 5e             	cmp    $0x5e,%eax
  800554:	76 c6                	jbe    80051c <vprintfmt+0x1f3>
					putch('?', putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	53                   	push   %ebx
  80055a:	6a 3f                	push   $0x3f
  80055c:	ff d6                	call   *%esi
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	eb c3                	jmp    800526 <vprintfmt+0x1fd>
  800563:	89 cf                	mov    %ecx,%edi
  800565:	eb 0e                	jmp    800575 <vprintfmt+0x24c>
				putch(' ', putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	53                   	push   %ebx
  80056b:	6a 20                	push   $0x20
  80056d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80056f:	83 ef 01             	sub    $0x1,%edi
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	85 ff                	test   %edi,%edi
  800577:	7f ee                	jg     800567 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800579:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
  80057f:	e9 67 01 00 00       	jmp    8006eb <vprintfmt+0x3c2>
  800584:	89 cf                	mov    %ecx,%edi
  800586:	eb ed                	jmp    800575 <vprintfmt+0x24c>
	if (lflag >= 2)
  800588:	83 f9 01             	cmp    $0x1,%ecx
  80058b:	7f 1b                	jg     8005a8 <vprintfmt+0x27f>
	else if (lflag)
  80058d:	85 c9                	test   %ecx,%ecx
  80058f:	74 63                	je     8005f4 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	99                   	cltd   
  80059a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 40 04             	lea    0x4(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a6:	eb 17                	jmp    8005bf <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8b 50 04             	mov    0x4(%eax),%edx
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 40 08             	lea    0x8(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c5:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005ca:	85 c9                	test   %ecx,%ecx
  8005cc:	0f 89 ff 00 00 00    	jns    8006d1 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 2d                	push   $0x2d
  8005d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 d1 00             	adc    $0x0,%ecx
  8005e5:	f7 d9                	neg    %ecx
  8005e7:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ea:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005ef:	e9 dd 00 00 00       	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	99                   	cltd   
  8005fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 40 04             	lea    0x4(%eax),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
  800609:	eb b4                	jmp    8005bf <vprintfmt+0x296>
	if (lflag >= 2)
  80060b:	83 f9 01             	cmp    $0x1,%ecx
  80060e:	7f 1e                	jg     80062e <vprintfmt+0x305>
	else if (lflag)
  800610:	85 c9                	test   %ecx,%ecx
  800612:	74 32                	je     800646 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8b 10                	mov    (%eax),%edx
  800619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061e:	8d 40 04             	lea    0x4(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800624:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800629:	e9 a3 00 00 00       	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	8b 48 04             	mov    0x4(%eax),%ecx
  800636:	8d 40 08             	lea    0x8(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800641:	e9 8b 00 00 00       	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8b 10                	mov    (%eax),%edx
  80064b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800650:	8d 40 04             	lea    0x4(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800656:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80065b:	eb 74                	jmp    8006d1 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80065d:	83 f9 01             	cmp    $0x1,%ecx
  800660:	7f 1b                	jg     80067d <vprintfmt+0x354>
	else if (lflag)
  800662:	85 c9                	test   %ecx,%ecx
  800664:	74 2c                	je     800692 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800676:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80067b:	eb 54                	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 10                	mov    (%eax),%edx
  800682:	8b 48 04             	mov    0x4(%eax),%ecx
  800685:	8d 40 08             	lea    0x8(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80068b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800690:	eb 3f                	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069c:	8d 40 04             	lea    0x4(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006a2:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8006a7:	eb 28                	jmp    8006d1 <vprintfmt+0x3a8>
			putch('0', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 30                	push   $0x30
  8006af:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b1:	83 c4 08             	add    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 78                	push   $0x78
  8006b7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cc:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006d1:	83 ec 0c             	sub    $0xc,%esp
  8006d4:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 e0             	push   -0x20(%ebp)
  8006dc:	57                   	push   %edi
  8006dd:	51                   	push   %ecx
  8006de:	52                   	push   %edx
  8006df:	89 da                	mov    %ebx,%edx
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	e8 5e fb ff ff       	call   800246 <printnum>
			break;
  8006e8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ee:	e9 54 fc ff ff       	jmp    800347 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006f3:	83 f9 01             	cmp    $0x1,%ecx
  8006f6:	7f 1b                	jg     800713 <vprintfmt+0x3ea>
	else if (lflag)
  8006f8:	85 c9                	test   %ecx,%ecx
  8006fa:	74 2c                	je     800728 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	b9 00 00 00 00       	mov    $0x0,%ecx
  800706:	8d 40 04             	lea    0x4(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800711:	eb be                	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8b 10                	mov    (%eax),%edx
  800718:	8b 48 04             	mov    0x4(%eax),%ecx
  80071b:	8d 40 08             	lea    0x8(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800721:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800726:	eb a9                	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800738:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80073d:	eb 92                	jmp    8006d1 <vprintfmt+0x3a8>
			putch(ch, putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	53                   	push   %ebx
  800743:	6a 25                	push   $0x25
  800745:	ff d6                	call   *%esi
			break;
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 9f                	jmp    8006eb <vprintfmt+0x3c2>
			putch('%', putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	53                   	push   %ebx
  800750:	6a 25                	push   $0x25
  800752:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	89 f8                	mov    %edi,%eax
  800759:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075d:	74 05                	je     800764 <vprintfmt+0x43b>
  80075f:	83 e8 01             	sub    $0x1,%eax
  800762:	eb f5                	jmp    800759 <vprintfmt+0x430>
  800764:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800767:	eb 82                	jmp    8006eb <vprintfmt+0x3c2>

00800769 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	83 ec 18             	sub    $0x18,%esp
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800775:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800778:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800786:	85 c0                	test   %eax,%eax
  800788:	74 26                	je     8007b0 <vsnprintf+0x47>
  80078a:	85 d2                	test   %edx,%edx
  80078c:	7e 22                	jle    8007b0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078e:	ff 75 14             	push   0x14(%ebp)
  800791:	ff 75 10             	push   0x10(%ebp)
  800794:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800797:	50                   	push   %eax
  800798:	68 ef 02 80 00       	push   $0x8002ef
  80079d:	e8 87 fb ff ff       	call   800329 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ab:	83 c4 10             	add    $0x10,%esp
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    
		return -E_INVAL;
  8007b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b5:	eb f7                	jmp    8007ae <vsnprintf+0x45>

008007b7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c0:	50                   	push   %eax
  8007c1:	ff 75 10             	push   0x10(%ebp)
  8007c4:	ff 75 0c             	push   0xc(%ebp)
  8007c7:	ff 75 08             	push   0x8(%ebp)
  8007ca:	e8 9a ff ff ff       	call   800769 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dc:	eb 03                	jmp    8007e1 <strlen+0x10>
		n++;
  8007de:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007e1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e5:	75 f7                	jne    8007de <strlen+0xd>
	return n;
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f7:	eb 03                	jmp    8007fc <strnlen+0x13>
		n++;
  8007f9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	39 d0                	cmp    %edx,%eax
  8007fe:	74 08                	je     800808 <strnlen+0x1f>
  800800:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800804:	75 f3                	jne    8007f9 <strnlen+0x10>
  800806:	89 c2                	mov    %eax,%edx
	return n;
}
  800808:	89 d0                	mov    %edx,%eax
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
  80081b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80081f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800822:	83 c0 01             	add    $0x1,%eax
  800825:	84 d2                	test   %dl,%dl
  800827:	75 f2                	jne    80081b <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800829:	89 c8                	mov    %ecx,%eax
  80082b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	83 ec 10             	sub    $0x10,%esp
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	53                   	push   %ebx
  80083b:	e8 91 ff ff ff       	call   8007d1 <strlen>
  800840:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800843:	ff 75 0c             	push   0xc(%ebp)
  800846:	01 d8                	add    %ebx,%eax
  800848:	50                   	push   %eax
  800849:	e8 be ff ff ff       	call   80080c <strcpy>
	return dst;
}
  80084e:	89 d8                	mov    %ebx,%eax
  800850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	56                   	push   %esi
  800859:	53                   	push   %ebx
  80085a:	8b 75 08             	mov    0x8(%ebp),%esi
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800860:	89 f3                	mov    %esi,%ebx
  800862:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	89 f0                	mov    %esi,%eax
  800867:	eb 0f                	jmp    800878 <strncpy+0x23>
		*dst++ = *src;
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	0f b6 0a             	movzbl (%edx),%ecx
  80086f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800872:	80 f9 01             	cmp    $0x1,%cl
  800875:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800878:	39 d8                	cmp    %ebx,%eax
  80087a:	75 ed                	jne    800869 <strncpy+0x14>
	}
	return ret;
}
  80087c:	89 f0                	mov    %esi,%eax
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 75 08             	mov    0x8(%ebp),%esi
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088d:	8b 55 10             	mov    0x10(%ebp),%edx
  800890:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 d2                	test   %edx,%edx
  800894:	74 21                	je     8008b7 <strlcpy+0x35>
  800896:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089a:	89 f2                	mov    %esi,%edx
  80089c:	eb 09                	jmp    8008a7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089e:	83 c1 01             	add    $0x1,%ecx
  8008a1:	83 c2 01             	add    $0x1,%edx
  8008a4:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8008a7:	39 c2                	cmp    %eax,%edx
  8008a9:	74 09                	je     8008b4 <strlcpy+0x32>
  8008ab:	0f b6 19             	movzbl (%ecx),%ebx
  8008ae:	84 db                	test   %bl,%bl
  8008b0:	75 ec                	jne    80089e <strlcpy+0x1c>
  8008b2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b7:	29 f0                	sub    %esi,%eax
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c6:	eb 06                	jmp    8008ce <strcmp+0x11>
		p++, q++;
  8008c8:	83 c1 01             	add    $0x1,%ecx
  8008cb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ce:	0f b6 01             	movzbl (%ecx),%eax
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x1c>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	74 ef                	je     8008c8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	29 d0                	sub    %edx,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 c3                	mov    %eax,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f2:	eb 06                	jmp    8008fa <strncmp+0x17>
		n--, p++, q++;
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008fa:	39 d8                	cmp    %ebx,%eax
  8008fc:	74 18                	je     800916 <strncmp+0x33>
  8008fe:	0f b6 08             	movzbl (%eax),%ecx
  800901:	84 c9                	test   %cl,%cl
  800903:	74 04                	je     800909 <strncmp+0x26>
  800905:	3a 0a                	cmp    (%edx),%cl
  800907:	74 eb                	je     8008f4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800909:	0f b6 00             	movzbl (%eax),%eax
  80090c:	0f b6 12             	movzbl (%edx),%edx
  80090f:	29 d0                	sub    %edx,%eax
}
  800911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800914:	c9                   	leave  
  800915:	c3                   	ret    
		return 0;
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb f4                	jmp    800911 <strncmp+0x2e>

0080091d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800927:	eb 03                	jmp    80092c <strchr+0xf>
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	0f b6 10             	movzbl (%eax),%edx
  80092f:	84 d2                	test   %dl,%dl
  800931:	74 06                	je     800939 <strchr+0x1c>
		if (*s == c)
  800933:	38 ca                	cmp    %cl,%dl
  800935:	75 f2                	jne    800929 <strchr+0xc>
  800937:	eb 05                	jmp    80093e <strchr+0x21>
			return (char *) s;
	return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094d:	38 ca                	cmp    %cl,%dl
  80094f:	74 09                	je     80095a <strfind+0x1a>
  800951:	84 d2                	test   %dl,%dl
  800953:	74 05                	je     80095a <strfind+0x1a>
	for (; *s; s++)
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	eb f0                	jmp    80094a <strfind+0xa>
			break;
	return (char *) s;
}
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	57                   	push   %edi
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	8b 7d 08             	mov    0x8(%ebp),%edi
  800965:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800968:	85 c9                	test   %ecx,%ecx
  80096a:	74 2f                	je     80099b <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096c:	89 f8                	mov    %edi,%eax
  80096e:	09 c8                	or     %ecx,%eax
  800970:	a8 03                	test   $0x3,%al
  800972:	75 21                	jne    800995 <memset+0x39>
		c &= 0xFF;
  800974:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800978:	89 d0                	mov    %edx,%eax
  80097a:	c1 e0 08             	shl    $0x8,%eax
  80097d:	89 d3                	mov    %edx,%ebx
  80097f:	c1 e3 18             	shl    $0x18,%ebx
  800982:	89 d6                	mov    %edx,%esi
  800984:	c1 e6 10             	shl    $0x10,%esi
  800987:	09 f3                	or     %esi,%ebx
  800989:	09 da                	or     %ebx,%edx
  80098b:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800990:	fc                   	cld    
  800991:	f3 ab                	rep stos %eax,%es:(%edi)
  800993:	eb 06                	jmp    80099b <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	fc                   	cld    
  800999:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099b:	89 f8                	mov    %edi,%eax
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5f                   	pop    %edi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b0:	39 c6                	cmp    %eax,%esi
  8009b2:	73 32                	jae    8009e6 <memmove+0x44>
  8009b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b7:	39 c2                	cmp    %eax,%edx
  8009b9:	76 2b                	jbe    8009e6 <memmove+0x44>
		s += n;
		d += n;
  8009bb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009be:	89 d6                	mov    %edx,%esi
  8009c0:	09 fe                	or     %edi,%esi
  8009c2:	09 ce                	or     %ecx,%esi
  8009c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ca:	75 0e                	jne    8009da <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009cc:	83 ef 04             	sub    $0x4,%edi
  8009cf:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d5:	fd                   	std    
  8009d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d8:	eb 09                	jmp    8009e3 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009da:	83 ef 01             	sub    $0x1,%edi
  8009dd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009e0:	fd                   	std    
  8009e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e3:	fc                   	cld    
  8009e4:	eb 1a                	jmp    800a00 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e6:	89 f2                	mov    %esi,%edx
  8009e8:	09 c2                	or     %eax,%edx
  8009ea:	09 ca                	or     %ecx,%edx
  8009ec:	f6 c2 03             	test   $0x3,%dl
  8009ef:	75 0a                	jne    8009fb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f4:	89 c7                	mov    %eax,%edi
  8009f6:	fc                   	cld    
  8009f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f9:	eb 05                	jmp    800a00 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009fb:	89 c7                	mov    %eax,%edi
  8009fd:	fc                   	cld    
  8009fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a0a:	ff 75 10             	push   0x10(%ebp)
  800a0d:	ff 75 0c             	push   0xc(%ebp)
  800a10:	ff 75 08             	push   0x8(%ebp)
  800a13:	e8 8a ff ff ff       	call   8009a2 <memmove>
}
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    

00800a1a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a25:	89 c6                	mov    %eax,%esi
  800a27:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	eb 06                	jmp    800a32 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a32:	39 f0                	cmp    %esi,%eax
  800a34:	74 14                	je     800a4a <memcmp+0x30>
		if (*s1 != *s2)
  800a36:	0f b6 08             	movzbl (%eax),%ecx
  800a39:	0f b6 1a             	movzbl (%edx),%ebx
  800a3c:	38 d9                	cmp    %bl,%cl
  800a3e:	74 ec                	je     800a2c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a40:	0f b6 c1             	movzbl %cl,%eax
  800a43:	0f b6 db             	movzbl %bl,%ebx
  800a46:	29 d8                	sub    %ebx,%eax
  800a48:	eb 05                	jmp    800a4f <memcmp+0x35>
	}

	return 0;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5c:	89 c2                	mov    %eax,%edx
  800a5e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a61:	eb 03                	jmp    800a66 <memfind+0x13>
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	39 d0                	cmp    %edx,%eax
  800a68:	73 04                	jae    800a6e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6a:	38 08                	cmp    %cl,(%eax)
  800a6c:	75 f5                	jne    800a63 <memfind+0x10>
			break;
	return (void *) s;
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
  800a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7c:	eb 03                	jmp    800a81 <strtol+0x11>
		s++;
  800a7e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a81:	0f b6 02             	movzbl (%edx),%eax
  800a84:	3c 20                	cmp    $0x20,%al
  800a86:	74 f6                	je     800a7e <strtol+0xe>
  800a88:	3c 09                	cmp    $0x9,%al
  800a8a:	74 f2                	je     800a7e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a8c:	3c 2b                	cmp    $0x2b,%al
  800a8e:	74 2a                	je     800aba <strtol+0x4a>
	int neg = 0;
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a95:	3c 2d                	cmp    $0x2d,%al
  800a97:	74 2b                	je     800ac4 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9f:	75 0f                	jne    800ab0 <strtol+0x40>
  800aa1:	80 3a 30             	cmpb   $0x30,(%edx)
  800aa4:	74 28                	je     800ace <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aad:	0f 44 d8             	cmove  %eax,%ebx
  800ab0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab8:	eb 46                	jmp    800b00 <strtol+0x90>
		s++;
  800aba:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac2:	eb d5                	jmp    800a99 <strtol+0x29>
		s++, neg = 1;
  800ac4:	83 c2 01             	add    $0x1,%edx
  800ac7:	bf 01 00 00 00       	mov    $0x1,%edi
  800acc:	eb cb                	jmp    800a99 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ace:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad2:	74 0e                	je     800ae2 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ad4:	85 db                	test   %ebx,%ebx
  800ad6:	75 d8                	jne    800ab0 <strtol+0x40>
		s++, base = 8;
  800ad8:	83 c2 01             	add    $0x1,%edx
  800adb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ae0:	eb ce                	jmp    800ab0 <strtol+0x40>
		s += 2, base = 16;
  800ae2:	83 c2 02             	add    $0x2,%edx
  800ae5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aea:	eb c4                	jmp    800ab0 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aec:	0f be c0             	movsbl %al,%eax
  800aef:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af2:	3b 45 10             	cmp    0x10(%ebp),%eax
  800af5:	7d 3a                	jge    800b31 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800af7:	83 c2 01             	add    $0x1,%edx
  800afa:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800afe:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b00:	0f b6 02             	movzbl (%edx),%eax
  800b03:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 09             	cmp    $0x9,%bl
  800b0b:	76 df                	jbe    800aec <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b0d:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b10:	89 f3                	mov    %esi,%ebx
  800b12:	80 fb 19             	cmp    $0x19,%bl
  800b15:	77 08                	ja     800b1f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b17:	0f be c0             	movsbl %al,%eax
  800b1a:	83 e8 57             	sub    $0x57,%eax
  800b1d:	eb d3                	jmp    800af2 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b1f:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b22:	89 f3                	mov    %esi,%ebx
  800b24:	80 fb 19             	cmp    $0x19,%bl
  800b27:	77 08                	ja     800b31 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b29:	0f be c0             	movsbl %al,%eax
  800b2c:	83 e8 37             	sub    $0x37,%eax
  800b2f:	eb c1                	jmp    800af2 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b35:	74 05                	je     800b3c <strtol+0xcc>
		*endptr = (char *) s;
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b3c:	89 c8                	mov    %ecx,%eax
  800b3e:	f7 d8                	neg    %eax
  800b40:	85 ff                	test   %edi,%edi
  800b42:	0f 45 c8             	cmovne %eax,%ecx
}
  800b45:	89 c8                	mov    %ecx,%eax
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5d:	89 c3                	mov    %eax,%ebx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	89 c6                	mov    %eax,%esi
  800b63:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9f:	89 cb                	mov    %ecx,%ebx
  800ba1:	89 cf                	mov    %ecx,%edi
  800ba3:	89 ce                	mov    %ecx,%esi
  800ba5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	7f 08                	jg     800bb3 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 03                	push   $0x3
  800bb9:	68 5f 29 80 00       	push   $0x80295f
  800bbe:	6a 2a                	push   $0x2a
  800bc0:	68 7c 29 80 00       	push   $0x80297c
  800bc5:	e8 8d f5 ff ff       	call   800157 <_panic>

00800bca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bda:	89 d1                	mov    %edx,%ecx
  800bdc:	89 d3                	mov    %edx,%ebx
  800bde:	89 d7                	mov    %edx,%edi
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_yield>:

void
sys_yield(void)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bef:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf9:	89 d1                	mov    %edx,%ecx
  800bfb:	89 d3                	mov    %edx,%ebx
  800bfd:	89 d7                	mov    %edx,%edi
  800bff:	89 d6                	mov    %edx,%esi
  800c01:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c11:	be 00 00 00 00       	mov    $0x0,%esi
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c24:	89 f7                	mov    %esi,%edi
  800c26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7f 08                	jg     800c34 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	50                   	push   %eax
  800c38:	6a 04                	push   $0x4
  800c3a:	68 5f 29 80 00       	push   $0x80295f
  800c3f:	6a 2a                	push   $0x2a
  800c41:	68 7c 29 80 00       	push   $0x80297c
  800c46:	e8 0c f5 ff ff       	call   800157 <_panic>

00800c4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c65:	8b 75 18             	mov    0x18(%ebp),%esi
  800c68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7f 08                	jg     800c76 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c76:	83 ec 0c             	sub    $0xc,%esp
  800c79:	50                   	push   %eax
  800c7a:	6a 05                	push   $0x5
  800c7c:	68 5f 29 80 00       	push   $0x80295f
  800c81:	6a 2a                	push   $0x2a
  800c83:	68 7c 29 80 00       	push   $0x80297c
  800c88:	e8 ca f4 ff ff       	call   800157 <_panic>

00800c8d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7f 08                	jg     800cb8 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 06                	push   $0x6
  800cbe:	68 5f 29 80 00       	push   $0x80295f
  800cc3:	6a 2a                	push   $0x2a
  800cc5:	68 7c 29 80 00       	push   $0x80297c
  800cca:	e8 88 f4 ff ff       	call   800157 <_panic>

00800ccf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7f 08                	jg     800cfa <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 08                	push   $0x8
  800d00:	68 5f 29 80 00       	push   $0x80295f
  800d05:	6a 2a                	push   $0x2a
  800d07:	68 7c 29 80 00       	push   $0x80297c
  800d0c:	e8 46 f4 ff ff       	call   800157 <_panic>

00800d11 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2a:	89 df                	mov    %ebx,%edi
  800d2c:	89 de                	mov    %ebx,%esi
  800d2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7f 08                	jg     800d3c <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 09                	push   $0x9
  800d42:	68 5f 29 80 00       	push   $0x80295f
  800d47:	6a 2a                	push   $0x2a
  800d49:	68 7c 29 80 00       	push   $0x80297c
  800d4e:	e8 04 f4 ff ff       	call   800157 <_panic>

00800d53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7f 08                	jg     800d7e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	50                   	push   %eax
  800d82:	6a 0a                	push   $0xa
  800d84:	68 5f 29 80 00       	push   $0x80295f
  800d89:	6a 2a                	push   $0x2a
  800d8b:	68 7c 29 80 00       	push   $0x80297c
  800d90:	e8 c2 f3 ff ff       	call   800157 <_panic>

00800d95 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da6:	be 00 00 00 00       	mov    $0x0,%esi
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dce:	89 cb                	mov    %ecx,%ebx
  800dd0:	89 cf                	mov    %ecx,%edi
  800dd2:	89 ce                	mov    %ecx,%esi
  800dd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7f 08                	jg     800de2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 0d                	push   $0xd
  800de8:	68 5f 29 80 00       	push   $0x80295f
  800ded:	6a 2a                	push   $0x2a
  800def:	68 7c 29 80 00       	push   $0x80297c
  800df4:	e8 5e f3 ff ff       	call   800157 <_panic>

00800df9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dff:	ba 00 00 00 00       	mov    $0x0,%edx
  800e04:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e09:	89 d1                	mov    %edx,%ecx
  800e0b:	89 d3                	mov    %edx,%ebx
  800e0d:	89 d7                	mov    %edx,%edi
  800e0f:	89 d6                	mov    %edx,%esi
  800e11:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e2e:	89 df                	mov    %ebx,%edi
  800e30:	89 de                	mov    %ebx,%esi
  800e32:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4a:	b8 10 00 00 00       	mov    $0x10,%eax
  800e4f:	89 df                	mov    %ebx,%edi
  800e51:	89 de                	mov    %ebx,%esi
  800e53:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e62:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e64:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e68:	0f 84 8e 00 00 00    	je     800efc <pgfault+0xa2>
  800e6e:	89 f0                	mov    %esi,%eax
  800e70:	c1 e8 0c             	shr    $0xc,%eax
  800e73:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e7a:	f6 c4 08             	test   $0x8,%ah
  800e7d:	74 7d                	je     800efc <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e7f:	e8 46 fd ff ff       	call   800bca <sys_getenvid>
  800e84:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e86:	83 ec 04             	sub    $0x4,%esp
  800e89:	6a 07                	push   $0x7
  800e8b:	68 00 f0 7f 00       	push   $0x7ff000
  800e90:	50                   	push   %eax
  800e91:	e8 72 fd ff ff       	call   800c08 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	78 73                	js     800f10 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e9d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	68 00 10 00 00       	push   $0x1000
  800eab:	56                   	push   %esi
  800eac:	68 00 f0 7f 00       	push   $0x7ff000
  800eb1:	e8 ec fa ff ff       	call   8009a2 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800eb6:	83 c4 08             	add    $0x8,%esp
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
  800ebb:	e8 cd fd ff ff       	call   800c8d <sys_page_unmap>
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	78 5b                	js     800f22 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	6a 07                	push   $0x7
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	68 00 f0 7f 00       	push   $0x7ff000
  800ed3:	53                   	push   %ebx
  800ed4:	e8 72 fd ff ff       	call   800c4b <sys_page_map>
  800ed9:	83 c4 20             	add    $0x20,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	78 54                	js     800f34 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	68 00 f0 7f 00       	push   $0x7ff000
  800ee8:	53                   	push   %ebx
  800ee9:	e8 9f fd ff ff       	call   800c8d <sys_page_unmap>
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	78 51                	js     800f46 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800ef5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800efc:	83 ec 04             	sub    $0x4,%esp
  800eff:	68 8c 29 80 00       	push   $0x80298c
  800f04:	6a 1d                	push   $0x1d
  800f06:	68 08 2a 80 00       	push   $0x802a08
  800f0b:	e8 47 f2 ff ff       	call   800157 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f10:	50                   	push   %eax
  800f11:	68 c4 29 80 00       	push   $0x8029c4
  800f16:	6a 29                	push   $0x29
  800f18:	68 08 2a 80 00       	push   $0x802a08
  800f1d:	e8 35 f2 ff ff       	call   800157 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f22:	50                   	push   %eax
  800f23:	68 e8 29 80 00       	push   $0x8029e8
  800f28:	6a 2e                	push   $0x2e
  800f2a:	68 08 2a 80 00       	push   $0x802a08
  800f2f:	e8 23 f2 ff ff       	call   800157 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800f34:	50                   	push   %eax
  800f35:	68 13 2a 80 00       	push   $0x802a13
  800f3a:	6a 30                	push   $0x30
  800f3c:	68 08 2a 80 00       	push   $0x802a08
  800f41:	e8 11 f2 ff ff       	call   800157 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f46:	50                   	push   %eax
  800f47:	68 e8 29 80 00       	push   $0x8029e8
  800f4c:	6a 32                	push   $0x32
  800f4e:	68 08 2a 80 00       	push   $0x802a08
  800f53:	e8 ff f1 ff ff       	call   800157 <_panic>

00800f58 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
  800f5e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f61:	68 5a 0e 80 00       	push   $0x800e5a
  800f66:	e8 81 13 00 00       	call   8022ec <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f6b:	b8 07 00 00 00       	mov    $0x7,%eax
  800f70:	cd 30                	int    $0x30
  800f72:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 30                	js     800fac <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f7c:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f81:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f85:	75 76                	jne    800ffd <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f87:	e8 3e fc ff ff       	call   800bca <sys_getenvid>
  800f8c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f91:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800f97:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9c:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800fa1:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800fac:	50                   	push   %eax
  800fad:	68 31 2a 80 00       	push   $0x802a31
  800fb2:	6a 78                	push   $0x78
  800fb4:	68 08 2a 80 00       	push   $0x802a08
  800fb9:	e8 99 f1 ff ff       	call   800157 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	ff 75 e4             	push   -0x1c(%ebp)
  800fc4:	57                   	push   %edi
  800fc5:	ff 75 dc             	push   -0x24(%ebp)
  800fc8:	57                   	push   %edi
  800fc9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fcc:	56                   	push   %esi
  800fcd:	e8 79 fc ff ff       	call   800c4b <sys_page_map>
	if(r<0) return r;
  800fd2:	83 c4 20             	add    $0x20,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	78 cb                	js     800fa4 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800fd9:	83 ec 0c             	sub    $0xc,%esp
  800fdc:	ff 75 e4             	push   -0x1c(%ebp)
  800fdf:	57                   	push   %edi
  800fe0:	56                   	push   %esi
  800fe1:	57                   	push   %edi
  800fe2:	56                   	push   %esi
  800fe3:	e8 63 fc ff ff       	call   800c4b <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800fe8:	83 c4 20             	add    $0x20,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 76                	js     801065 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ff5:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800ffb:	74 75                	je     801072 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800ffd:	89 d8                	mov    %ebx,%eax
  800fff:	c1 e8 16             	shr    $0x16,%eax
  801002:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801009:	a8 01                	test   $0x1,%al
  80100b:	74 e2                	je     800fef <fork+0x97>
  80100d:	89 de                	mov    %ebx,%esi
  80100f:	c1 ee 0c             	shr    $0xc,%esi
  801012:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801019:	a8 01                	test   $0x1,%al
  80101b:	74 d2                	je     800fef <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  80101d:	e8 a8 fb ff ff       	call   800bca <sys_getenvid>
  801022:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801025:	89 f7                	mov    %esi,%edi
  801027:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  80102a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801031:	89 c1                	mov    %eax,%ecx
  801033:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801039:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  80103c:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801043:	f6 c6 04             	test   $0x4,%dh
  801046:	0f 85 72 ff ff ff    	jne    800fbe <fork+0x66>
		perm &= ~PTE_W;
  80104c:	25 05 0e 00 00       	and    $0xe05,%eax
  801051:	80 cc 08             	or     $0x8,%ah
  801054:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  80105a:	0f 44 c1             	cmove  %ecx,%eax
  80105d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801060:	e9 59 ff ff ff       	jmp    800fbe <fork+0x66>
  801065:	ba 00 00 00 00       	mov    $0x0,%edx
  80106a:	0f 4f c2             	cmovg  %edx,%eax
  80106d:	e9 32 ff ff ff       	jmp    800fa4 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	6a 07                	push   $0x7
  801077:	68 00 f0 bf ee       	push   $0xeebff000
  80107c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80107f:	57                   	push   %edi
  801080:	e8 83 fb ff ff       	call   800c08 <sys_page_alloc>
	if(r<0) return r;
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	0f 88 14 ff ff ff    	js     800fa4 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	68 62 23 80 00       	push   $0x802362
  801098:	57                   	push   %edi
  801099:	e8 b5 fc ff ff       	call   800d53 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	0f 88 fb fe ff ff    	js     800fa4 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010a9:	83 ec 08             	sub    $0x8,%esp
  8010ac:	6a 02                	push   $0x2
  8010ae:	57                   	push   %edi
  8010af:	e8 1b fc ff ff       	call   800ccf <sys_env_set_status>
	if(r<0) return r;
  8010b4:	83 c4 10             	add    $0x10,%esp
	return envid;
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	0f 49 c7             	cmovns %edi,%eax
  8010bc:	e9 e3 fe ff ff       	jmp    800fa4 <fork+0x4c>

008010c1 <sfork>:

// Challenge!
int
sfork(void)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c7:	68 41 2a 80 00       	push   $0x802a41
  8010cc:	68 a1 00 00 00       	push   $0xa1
  8010d1:	68 08 2a 80 00       	push   $0x802a08
  8010d6:	e8 7c f0 ff ff       	call   800157 <_panic>

008010db <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
  8010e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010f0:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	50                   	push   %eax
  8010f7:	e8 bc fc ff ff       	call   800db8 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 f6                	test   %esi,%esi
  801101:	74 17                	je     80111a <ipc_recv+0x3f>
  801103:	ba 00 00 00 00       	mov    $0x0,%edx
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 0c                	js     801118 <ipc_recv+0x3d>
  80110c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801112:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801118:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80111a:	85 db                	test   %ebx,%ebx
  80111c:	74 17                	je     801135 <ipc_recv+0x5a>
  80111e:	ba 00 00 00 00       	mov    $0x0,%edx
  801123:	85 c0                	test   %eax,%eax
  801125:	78 0c                	js     801133 <ipc_recv+0x58>
  801127:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80112d:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801133:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801135:	85 c0                	test   %eax,%eax
  801137:	78 0b                	js     801144 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801139:	a1 00 40 80 00       	mov    0x804000,%eax
  80113e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801144:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	57                   	push   %edi
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
  801151:	83 ec 0c             	sub    $0xc,%esp
  801154:	8b 7d 08             	mov    0x8(%ebp),%edi
  801157:	8b 75 0c             	mov    0xc(%ebp),%esi
  80115a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80115d:	85 db                	test   %ebx,%ebx
  80115f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801164:	0f 44 d8             	cmove  %eax,%ebx
  801167:	eb 05                	jmp    80116e <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801169:	e8 7b fa ff ff       	call   800be9 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80116e:	ff 75 14             	push   0x14(%ebp)
  801171:	53                   	push   %ebx
  801172:	56                   	push   %esi
  801173:	57                   	push   %edi
  801174:	e8 1c fc ff ff       	call   800d95 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80117f:	74 e8                	je     801169 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801181:	85 c0                	test   %eax,%eax
  801183:	78 08                	js     80118d <ipc_send+0x42>
	}while (r<0);

}
  801185:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5f                   	pop    %edi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80118d:	50                   	push   %eax
  80118e:	68 57 2a 80 00       	push   $0x802a57
  801193:	6a 3d                	push   $0x3d
  801195:	68 6b 2a 80 00       	push   $0x802a6b
  80119a:	e8 b8 ef ff ff       	call   800157 <_panic>

0080119f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011a5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011aa:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8011b0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011b6:	8b 52 60             	mov    0x60(%edx),%edx
  8011b9:	39 ca                	cmp    %ecx,%edx
  8011bb:	74 11                	je     8011ce <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8011bd:	83 c0 01             	add    $0x1,%eax
  8011c0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011c5:	75 e3                	jne    8011aa <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8011c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cc:	eb 0e                	jmp    8011dc <ipc_find_env+0x3d>
			return envs[i].env_id;
  8011ce:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8011d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011d9:	8b 40 58             	mov    0x58(%eax),%eax
}
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e4:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e9:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f4:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011fe:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	c1 ea 16             	shr    $0x16,%edx
  801212:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801219:	f6 c2 01             	test   $0x1,%dl
  80121c:	74 29                	je     801247 <fd_alloc+0x42>
  80121e:	89 c2                	mov    %eax,%edx
  801220:	c1 ea 0c             	shr    $0xc,%edx
  801223:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122a:	f6 c2 01             	test   $0x1,%dl
  80122d:	74 18                	je     801247 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80122f:	05 00 10 00 00       	add    $0x1000,%eax
  801234:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801239:	75 d2                	jne    80120d <fd_alloc+0x8>
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801240:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801245:	eb 05                	jmp    80124c <fd_alloc+0x47>
			return 0;
  801247:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80124c:	8b 55 08             	mov    0x8(%ebp),%edx
  80124f:	89 02                	mov    %eax,(%edx)
}
  801251:	89 c8                	mov    %ecx,%eax
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80125b:	83 f8 1f             	cmp    $0x1f,%eax
  80125e:	77 30                	ja     801290 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801260:	c1 e0 0c             	shl    $0xc,%eax
  801263:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801268:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80126e:	f6 c2 01             	test   $0x1,%dl
  801271:	74 24                	je     801297 <fd_lookup+0x42>
  801273:	89 c2                	mov    %eax,%edx
  801275:	c1 ea 0c             	shr    $0xc,%edx
  801278:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127f:	f6 c2 01             	test   $0x1,%dl
  801282:	74 1a                	je     80129e <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801284:	8b 55 0c             	mov    0xc(%ebp),%edx
  801287:	89 02                	mov    %eax,(%edx)
	return 0;
  801289:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    
		return -E_INVAL;
  801290:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801295:	eb f7                	jmp    80128e <fd_lookup+0x39>
		return -E_INVAL;
  801297:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129c:	eb f0                	jmp    80128e <fd_lookup+0x39>
  80129e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a3:	eb e9                	jmp    80128e <fd_lookup+0x39>

008012a5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 04             	sub    $0x4,%esp
  8012ac:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012af:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b4:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8012b9:	39 13                	cmp    %edx,(%ebx)
  8012bb:	74 37                	je     8012f4 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8012bd:	83 c0 01             	add    $0x1,%eax
  8012c0:	8b 1c 85 f4 2a 80 00 	mov    0x802af4(,%eax,4),%ebx
  8012c7:	85 db                	test   %ebx,%ebx
  8012c9:	75 ee                	jne    8012b9 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012cb:	a1 00 40 80 00       	mov    0x804000,%eax
  8012d0:	8b 40 58             	mov    0x58(%eax),%eax
  8012d3:	83 ec 04             	sub    $0x4,%esp
  8012d6:	52                   	push   %edx
  8012d7:	50                   	push   %eax
  8012d8:	68 78 2a 80 00       	push   $0x802a78
  8012dd:	e8 50 ef ff ff       	call   800232 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ed:	89 1a                	mov    %ebx,(%edx)
}
  8012ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f2:	c9                   	leave  
  8012f3:	c3                   	ret    
			return 0;
  8012f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f9:	eb ef                	jmp    8012ea <dev_lookup+0x45>

008012fb <fd_close>:
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	57                   	push   %edi
  8012ff:	56                   	push   %esi
  801300:	53                   	push   %ebx
  801301:	83 ec 24             	sub    $0x24,%esp
  801304:	8b 75 08             	mov    0x8(%ebp),%esi
  801307:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80130d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80130e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801314:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801317:	50                   	push   %eax
  801318:	e8 38 ff ff ff       	call   801255 <fd_lookup>
  80131d:	89 c3                	mov    %eax,%ebx
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 05                	js     80132b <fd_close+0x30>
	    || fd != fd2)
  801326:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801329:	74 16                	je     801341 <fd_close+0x46>
		return (must_exist ? r : 0);
  80132b:	89 f8                	mov    %edi,%eax
  80132d:	84 c0                	test   %al,%al
  80132f:	b8 00 00 00 00       	mov    $0x0,%eax
  801334:	0f 44 d8             	cmove  %eax,%ebx
}
  801337:	89 d8                	mov    %ebx,%eax
  801339:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133c:	5b                   	pop    %ebx
  80133d:	5e                   	pop    %esi
  80133e:	5f                   	pop    %edi
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	ff 36                	push   (%esi)
  80134a:	e8 56 ff ff ff       	call   8012a5 <dev_lookup>
  80134f:	89 c3                	mov    %eax,%ebx
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	78 1a                	js     801372 <fd_close+0x77>
		if (dev->dev_close)
  801358:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135b:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80135e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801363:	85 c0                	test   %eax,%eax
  801365:	74 0b                	je     801372 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801367:	83 ec 0c             	sub    $0xc,%esp
  80136a:	56                   	push   %esi
  80136b:	ff d0                	call   *%eax
  80136d:	89 c3                	mov    %eax,%ebx
  80136f:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	56                   	push   %esi
  801376:	6a 00                	push   $0x0
  801378:	e8 10 f9 ff ff       	call   800c8d <sys_page_unmap>
	return r;
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	eb b5                	jmp    801337 <fd_close+0x3c>

00801382 <close>:

int
close(int fdnum)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801388:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138b:	50                   	push   %eax
  80138c:	ff 75 08             	push   0x8(%ebp)
  80138f:	e8 c1 fe ff ff       	call   801255 <fd_lookup>
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	79 02                	jns    80139d <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    
		return fd_close(fd, 1);
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	6a 01                	push   $0x1
  8013a2:	ff 75 f4             	push   -0xc(%ebp)
  8013a5:	e8 51 ff ff ff       	call   8012fb <fd_close>
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	eb ec                	jmp    80139b <close+0x19>

008013af <close_all>:

void
close_all(void)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013bb:	83 ec 0c             	sub    $0xc,%esp
  8013be:	53                   	push   %ebx
  8013bf:	e8 be ff ff ff       	call   801382 <close>
	for (i = 0; i < MAXFD; i++)
  8013c4:	83 c3 01             	add    $0x1,%ebx
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	83 fb 20             	cmp    $0x20,%ebx
  8013cd:	75 ec                	jne    8013bb <close_all+0xc>
}
  8013cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	57                   	push   %edi
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 75 08             	push   0x8(%ebp)
  8013e4:	e8 6c fe ff ff       	call   801255 <fd_lookup>
  8013e9:	89 c3                	mov    %eax,%ebx
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 7f                	js     801471 <dup+0x9d>
		return r;
	close(newfdnum);
  8013f2:	83 ec 0c             	sub    $0xc,%esp
  8013f5:	ff 75 0c             	push   0xc(%ebp)
  8013f8:	e8 85 ff ff ff       	call   801382 <close>

	newfd = INDEX2FD(newfdnum);
  8013fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801400:	c1 e6 0c             	shl    $0xc,%esi
  801403:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80140c:	89 3c 24             	mov    %edi,(%esp)
  80140f:	e8 da fd ff ff       	call   8011ee <fd2data>
  801414:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801416:	89 34 24             	mov    %esi,(%esp)
  801419:	e8 d0 fd ff ff       	call   8011ee <fd2data>
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801424:	89 d8                	mov    %ebx,%eax
  801426:	c1 e8 16             	shr    $0x16,%eax
  801429:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801430:	a8 01                	test   $0x1,%al
  801432:	74 11                	je     801445 <dup+0x71>
  801434:	89 d8                	mov    %ebx,%eax
  801436:	c1 e8 0c             	shr    $0xc,%eax
  801439:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801440:	f6 c2 01             	test   $0x1,%dl
  801443:	75 36                	jne    80147b <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801445:	89 f8                	mov    %edi,%eax
  801447:	c1 e8 0c             	shr    $0xc,%eax
  80144a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	25 07 0e 00 00       	and    $0xe07,%eax
  801459:	50                   	push   %eax
  80145a:	56                   	push   %esi
  80145b:	6a 00                	push   $0x0
  80145d:	57                   	push   %edi
  80145e:	6a 00                	push   $0x0
  801460:	e8 e6 f7 ff ff       	call   800c4b <sys_page_map>
  801465:	89 c3                	mov    %eax,%ebx
  801467:	83 c4 20             	add    $0x20,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 33                	js     8014a1 <dup+0xcd>
		goto err;

	return newfdnum;
  80146e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801471:	89 d8                	mov    %ebx,%eax
  801473:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801476:	5b                   	pop    %ebx
  801477:	5e                   	pop    %esi
  801478:	5f                   	pop    %edi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80147b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	25 07 0e 00 00       	and    $0xe07,%eax
  80148a:	50                   	push   %eax
  80148b:	ff 75 d4             	push   -0x2c(%ebp)
  80148e:	6a 00                	push   $0x0
  801490:	53                   	push   %ebx
  801491:	6a 00                	push   $0x0
  801493:	e8 b3 f7 ff ff       	call   800c4b <sys_page_map>
  801498:	89 c3                	mov    %eax,%ebx
  80149a:	83 c4 20             	add    $0x20,%esp
  80149d:	85 c0                	test   %eax,%eax
  80149f:	79 a4                	jns    801445 <dup+0x71>
	sys_page_unmap(0, newfd);
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	56                   	push   %esi
  8014a5:	6a 00                	push   $0x0
  8014a7:	e8 e1 f7 ff ff       	call   800c8d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ac:	83 c4 08             	add    $0x8,%esp
  8014af:	ff 75 d4             	push   -0x2c(%ebp)
  8014b2:	6a 00                	push   $0x0
  8014b4:	e8 d4 f7 ff ff       	call   800c8d <sys_page_unmap>
	return r;
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	eb b3                	jmp    801471 <dup+0x9d>

008014be <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 18             	sub    $0x18,%esp
  8014c6:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	56                   	push   %esi
  8014ce:	e8 82 fd ff ff       	call   801255 <fd_lookup>
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 3c                	js     801516 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	ff 33                	push   (%ebx)
  8014e6:	e8 ba fd ff ff       	call   8012a5 <dev_lookup>
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 24                	js     801516 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f2:	8b 43 08             	mov    0x8(%ebx),%eax
  8014f5:	83 e0 03             	and    $0x3,%eax
  8014f8:	83 f8 01             	cmp    $0x1,%eax
  8014fb:	74 20                	je     80151d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801500:	8b 40 08             	mov    0x8(%eax),%eax
  801503:	85 c0                	test   %eax,%eax
  801505:	74 37                	je     80153e <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	ff 75 10             	push   0x10(%ebp)
  80150d:	ff 75 0c             	push   0xc(%ebp)
  801510:	53                   	push   %ebx
  801511:	ff d0                	call   *%eax
  801513:	83 c4 10             	add    $0x10,%esp
}
  801516:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801519:	5b                   	pop    %ebx
  80151a:	5e                   	pop    %esi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80151d:	a1 00 40 80 00       	mov    0x804000,%eax
  801522:	8b 40 58             	mov    0x58(%eax),%eax
  801525:	83 ec 04             	sub    $0x4,%esp
  801528:	56                   	push   %esi
  801529:	50                   	push   %eax
  80152a:	68 b9 2a 80 00       	push   $0x802ab9
  80152f:	e8 fe ec ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153c:	eb d8                	jmp    801516 <read+0x58>
		return -E_NOT_SUPP;
  80153e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801543:	eb d1                	jmp    801516 <read+0x58>

00801545 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	57                   	push   %edi
  801549:	56                   	push   %esi
  80154a:	53                   	push   %ebx
  80154b:	83 ec 0c             	sub    $0xc,%esp
  80154e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801551:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801554:	bb 00 00 00 00       	mov    $0x0,%ebx
  801559:	eb 02                	jmp    80155d <readn+0x18>
  80155b:	01 c3                	add    %eax,%ebx
  80155d:	39 f3                	cmp    %esi,%ebx
  80155f:	73 21                	jae    801582 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	89 f0                	mov    %esi,%eax
  801566:	29 d8                	sub    %ebx,%eax
  801568:	50                   	push   %eax
  801569:	89 d8                	mov    %ebx,%eax
  80156b:	03 45 0c             	add    0xc(%ebp),%eax
  80156e:	50                   	push   %eax
  80156f:	57                   	push   %edi
  801570:	e8 49 ff ff ff       	call   8014be <read>
		if (m < 0)
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 04                	js     801580 <readn+0x3b>
			return m;
		if (m == 0)
  80157c:	75 dd                	jne    80155b <readn+0x16>
  80157e:	eb 02                	jmp    801582 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801580:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801582:	89 d8                	mov    %ebx,%eax
  801584:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5f                   	pop    %edi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
  801591:	83 ec 18             	sub    $0x18,%esp
  801594:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801597:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	53                   	push   %ebx
  80159c:	e8 b4 fc ff ff       	call   801255 <fd_lookup>
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 37                	js     8015df <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a8:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	ff 36                	push   (%esi)
  8015b4:	e8 ec fc ff ff       	call   8012a5 <dev_lookup>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 1f                	js     8015df <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c0:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015c4:	74 20                	je     8015e6 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	74 37                	je     801607 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d0:	83 ec 04             	sub    $0x4,%esp
  8015d3:	ff 75 10             	push   0x10(%ebp)
  8015d6:	ff 75 0c             	push   0xc(%ebp)
  8015d9:	56                   	push   %esi
  8015da:	ff d0                	call   *%eax
  8015dc:	83 c4 10             	add    $0x10,%esp
}
  8015df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e2:	5b                   	pop    %ebx
  8015e3:	5e                   	pop    %esi
  8015e4:	5d                   	pop    %ebp
  8015e5:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e6:	a1 00 40 80 00       	mov    0x804000,%eax
  8015eb:	8b 40 58             	mov    0x58(%eax),%eax
  8015ee:	83 ec 04             	sub    $0x4,%esp
  8015f1:	53                   	push   %ebx
  8015f2:	50                   	push   %eax
  8015f3:	68 d5 2a 80 00       	push   $0x802ad5
  8015f8:	e8 35 ec ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801605:	eb d8                	jmp    8015df <write+0x53>
		return -E_NOT_SUPP;
  801607:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80160c:	eb d1                	jmp    8015df <write+0x53>

0080160e <seek>:

int
seek(int fdnum, off_t offset)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	ff 75 08             	push   0x8(%ebp)
  80161b:	e8 35 fc ff ff       	call   801255 <fd_lookup>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	78 0e                	js     801635 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801627:	8b 55 0c             	mov    0xc(%ebp),%edx
  80162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801630:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	56                   	push   %esi
  80163b:	53                   	push   %ebx
  80163c:	83 ec 18             	sub    $0x18,%esp
  80163f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801642:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	53                   	push   %ebx
  801647:	e8 09 fc ff ff       	call   801255 <fd_lookup>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 34                	js     801687 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801653:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	ff 36                	push   (%esi)
  80165f:	e8 41 fc ff ff       	call   8012a5 <dev_lookup>
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	85 c0                	test   %eax,%eax
  801669:	78 1c                	js     801687 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80166b:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80166f:	74 1d                	je     80168e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801674:	8b 40 18             	mov    0x18(%eax),%eax
  801677:	85 c0                	test   %eax,%eax
  801679:	74 34                	je     8016af <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80167b:	83 ec 08             	sub    $0x8,%esp
  80167e:	ff 75 0c             	push   0xc(%ebp)
  801681:	56                   	push   %esi
  801682:	ff d0                	call   *%eax
  801684:	83 c4 10             	add    $0x10,%esp
}
  801687:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168a:	5b                   	pop    %ebx
  80168b:	5e                   	pop    %esi
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80168e:	a1 00 40 80 00       	mov    0x804000,%eax
  801693:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801696:	83 ec 04             	sub    $0x4,%esp
  801699:	53                   	push   %ebx
  80169a:	50                   	push   %eax
  80169b:	68 98 2a 80 00       	push   $0x802a98
  8016a0:	e8 8d eb ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ad:	eb d8                	jmp    801687 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8016af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016b4:	eb d1                	jmp    801687 <ftruncate+0x50>

008016b6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	56                   	push   %esi
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 18             	sub    $0x18,%esp
  8016be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c4:	50                   	push   %eax
  8016c5:	ff 75 08             	push   0x8(%ebp)
  8016c8:	e8 88 fb ff ff       	call   801255 <fd_lookup>
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 49                	js     80171d <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	ff 36                	push   (%esi)
  8016e0:	e8 c0 fb ff ff       	call   8012a5 <dev_lookup>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	85 c0                	test   %eax,%eax
  8016ea:	78 31                	js     80171d <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f3:	74 2f                	je     801724 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ff:	00 00 00 
	stat->st_isdir = 0;
  801702:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801709:	00 00 00 
	stat->st_dev = dev;
  80170c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801712:	83 ec 08             	sub    $0x8,%esp
  801715:	53                   	push   %ebx
  801716:	56                   	push   %esi
  801717:	ff 50 14             	call   *0x14(%eax)
  80171a:	83 c4 10             	add    $0x10,%esp
}
  80171d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801720:	5b                   	pop    %ebx
  801721:	5e                   	pop    %esi
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    
		return -E_NOT_SUPP;
  801724:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801729:	eb f2                	jmp    80171d <fstat+0x67>

0080172b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	56                   	push   %esi
  80172f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801730:	83 ec 08             	sub    $0x8,%esp
  801733:	6a 00                	push   $0x0
  801735:	ff 75 08             	push   0x8(%ebp)
  801738:	e8 e4 01 00 00       	call   801921 <open>
  80173d:	89 c3                	mov    %eax,%ebx
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 1b                	js     801761 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801746:	83 ec 08             	sub    $0x8,%esp
  801749:	ff 75 0c             	push   0xc(%ebp)
  80174c:	50                   	push   %eax
  80174d:	e8 64 ff ff ff       	call   8016b6 <fstat>
  801752:	89 c6                	mov    %eax,%esi
	close(fd);
  801754:	89 1c 24             	mov    %ebx,(%esp)
  801757:	e8 26 fc ff ff       	call   801382 <close>
	return r;
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	89 f3                	mov    %esi,%ebx
}
  801761:	89 d8                	mov    %ebx,%eax
  801763:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	56                   	push   %esi
  80176e:	53                   	push   %ebx
  80176f:	89 c6                	mov    %eax,%esi
  801771:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801773:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80177a:	74 27                	je     8017a3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80177c:	6a 07                	push   $0x7
  80177e:	68 00 50 80 00       	push   $0x805000
  801783:	56                   	push   %esi
  801784:	ff 35 00 60 80 00    	push   0x806000
  80178a:	e8 bc f9 ff ff       	call   80114b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80178f:	83 c4 0c             	add    $0xc,%esp
  801792:	6a 00                	push   $0x0
  801794:	53                   	push   %ebx
  801795:	6a 00                	push   $0x0
  801797:	e8 3f f9 ff ff       	call   8010db <ipc_recv>
}
  80179c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5e                   	pop    %esi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a3:	83 ec 0c             	sub    $0xc,%esp
  8017a6:	6a 01                	push   $0x1
  8017a8:	e8 f2 f9 ff ff       	call   80119f <ipc_find_env>
  8017ad:	a3 00 60 80 00       	mov    %eax,0x806000
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	eb c5                	jmp    80177c <fsipc+0x12>

008017b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017da:	e8 8b ff ff ff       	call   80176a <fsipc>
}
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <devfile_flush>:
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ed:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017fc:	e8 69 ff ff ff       	call   80176a <fsipc>
}
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <devfile_stat>:
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	53                   	push   %ebx
  801807:	83 ec 04             	sub    $0x4,%esp
  80180a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	8b 40 0c             	mov    0xc(%eax),%eax
  801813:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801818:	ba 00 00 00 00       	mov    $0x0,%edx
  80181d:	b8 05 00 00 00       	mov    $0x5,%eax
  801822:	e8 43 ff ff ff       	call   80176a <fsipc>
  801827:	85 c0                	test   %eax,%eax
  801829:	78 2c                	js     801857 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	68 00 50 80 00       	push   $0x805000
  801833:	53                   	push   %ebx
  801834:	e8 d3 ef ff ff       	call   80080c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801839:	a1 80 50 80 00       	mov    0x805080,%eax
  80183e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801844:	a1 84 50 80 00       	mov    0x805084,%eax
  801849:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <devfile_write>:
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	8b 45 10             	mov    0x10(%ebp),%eax
  801865:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80186a:	39 d0                	cmp    %edx,%eax
  80186c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80186f:	8b 55 08             	mov    0x8(%ebp),%edx
  801872:	8b 52 0c             	mov    0xc(%edx),%edx
  801875:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80187b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801880:	50                   	push   %eax
  801881:	ff 75 0c             	push   0xc(%ebp)
  801884:	68 08 50 80 00       	push   $0x805008
  801889:	e8 14 f1 ff ff       	call   8009a2 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80188e:	ba 00 00 00 00       	mov    $0x0,%edx
  801893:	b8 04 00 00 00       	mov    $0x4,%eax
  801898:	e8 cd fe ff ff       	call   80176a <fsipc>
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <devfile_read>:
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	56                   	push   %esi
  8018a3:	53                   	push   %ebx
  8018a4:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c2:	e8 a3 fe ff ff       	call   80176a <fsipc>
  8018c7:	89 c3                	mov    %eax,%ebx
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 1f                	js     8018ec <devfile_read+0x4d>
	assert(r <= n);
  8018cd:	39 f0                	cmp    %esi,%eax
  8018cf:	77 24                	ja     8018f5 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d6:	7f 33                	jg     80190b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d8:	83 ec 04             	sub    $0x4,%esp
  8018db:	50                   	push   %eax
  8018dc:	68 00 50 80 00       	push   $0x805000
  8018e1:	ff 75 0c             	push   0xc(%ebp)
  8018e4:	e8 b9 f0 ff ff       	call   8009a2 <memmove>
	return r;
  8018e9:	83 c4 10             	add    $0x10,%esp
}
  8018ec:	89 d8                	mov    %ebx,%eax
  8018ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f1:	5b                   	pop    %ebx
  8018f2:	5e                   	pop    %esi
  8018f3:	5d                   	pop    %ebp
  8018f4:	c3                   	ret    
	assert(r <= n);
  8018f5:	68 08 2b 80 00       	push   $0x802b08
  8018fa:	68 0f 2b 80 00       	push   $0x802b0f
  8018ff:	6a 7c                	push   $0x7c
  801901:	68 24 2b 80 00       	push   $0x802b24
  801906:	e8 4c e8 ff ff       	call   800157 <_panic>
	assert(r <= PGSIZE);
  80190b:	68 2f 2b 80 00       	push   $0x802b2f
  801910:	68 0f 2b 80 00       	push   $0x802b0f
  801915:	6a 7d                	push   $0x7d
  801917:	68 24 2b 80 00       	push   $0x802b24
  80191c:	e8 36 e8 ff ff       	call   800157 <_panic>

00801921 <open>:
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	56                   	push   %esi
  801925:	53                   	push   %ebx
  801926:	83 ec 1c             	sub    $0x1c,%esp
  801929:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80192c:	56                   	push   %esi
  80192d:	e8 9f ee ff ff       	call   8007d1 <strlen>
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80193a:	7f 6c                	jg     8019a8 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80193c:	83 ec 0c             	sub    $0xc,%esp
  80193f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801942:	50                   	push   %eax
  801943:	e8 bd f8 ff ff       	call   801205 <fd_alloc>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 3c                	js     80198d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	56                   	push   %esi
  801955:	68 00 50 80 00       	push   $0x805000
  80195a:	e8 ad ee ff ff       	call   80080c <strcpy>
	fsipcbuf.open.req_omode = mode;
  80195f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801962:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801967:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196a:	b8 01 00 00 00       	mov    $0x1,%eax
  80196f:	e8 f6 fd ff ff       	call   80176a <fsipc>
  801974:	89 c3                	mov    %eax,%ebx
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	85 c0                	test   %eax,%eax
  80197b:	78 19                	js     801996 <open+0x75>
	return fd2num(fd);
  80197d:	83 ec 0c             	sub    $0xc,%esp
  801980:	ff 75 f4             	push   -0xc(%ebp)
  801983:	e8 56 f8 ff ff       	call   8011de <fd2num>
  801988:	89 c3                	mov    %eax,%ebx
  80198a:	83 c4 10             	add    $0x10,%esp
}
  80198d:	89 d8                	mov    %ebx,%eax
  80198f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801992:	5b                   	pop    %ebx
  801993:	5e                   	pop    %esi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    
		fd_close(fd, 0);
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	6a 00                	push   $0x0
  80199b:	ff 75 f4             	push   -0xc(%ebp)
  80199e:	e8 58 f9 ff ff       	call   8012fb <fd_close>
		return r;
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	eb e5                	jmp    80198d <open+0x6c>
		return -E_BAD_PATH;
  8019a8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ad:	eb de                	jmp    80198d <open+0x6c>

008019af <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8019bf:	e8 a6 fd ff ff       	call   80176a <fsipc>
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019cc:	68 3b 2b 80 00       	push   $0x802b3b
  8019d1:	ff 75 0c             	push   0xc(%ebp)
  8019d4:	e8 33 ee ff ff       	call   80080c <strcpy>
	return 0;
}
  8019d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <devsock_close>:
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 10             	sub    $0x10,%esp
  8019e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019ea:	53                   	push   %ebx
  8019eb:	e8 98 09 00 00       	call   802388 <pageref>
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019fa:	83 fa 01             	cmp    $0x1,%edx
  8019fd:	74 05                	je     801a04 <devsock_close+0x24>
}
  8019ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a02:	c9                   	leave  
  801a03:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a04:	83 ec 0c             	sub    $0xc,%esp
  801a07:	ff 73 0c             	push   0xc(%ebx)
  801a0a:	e8 b7 02 00 00       	call   801cc6 <nsipc_close>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	eb eb                	jmp    8019ff <devsock_close+0x1f>

00801a14 <devsock_write>:
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a1a:	6a 00                	push   $0x0
  801a1c:	ff 75 10             	push   0x10(%ebp)
  801a1f:	ff 75 0c             	push   0xc(%ebp)
  801a22:	8b 45 08             	mov    0x8(%ebp),%eax
  801a25:	ff 70 0c             	push   0xc(%eax)
  801a28:	e8 79 03 00 00       	call   801da6 <nsipc_send>
}
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <devsock_read>:
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a35:	6a 00                	push   $0x0
  801a37:	ff 75 10             	push   0x10(%ebp)
  801a3a:	ff 75 0c             	push   0xc(%ebp)
  801a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a40:	ff 70 0c             	push   0xc(%eax)
  801a43:	e8 ef 02 00 00       	call   801d37 <nsipc_recv>
}
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <fd2sockid>:
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a50:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a53:	52                   	push   %edx
  801a54:	50                   	push   %eax
  801a55:	e8 fb f7 ff ff       	call   801255 <fd_lookup>
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	78 10                	js     801a71 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a64:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a6a:	39 08                	cmp    %ecx,(%eax)
  801a6c:	75 05                	jne    801a73 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a6e:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    
		return -E_NOT_SUPP;
  801a73:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a78:	eb f7                	jmp    801a71 <fd2sockid+0x27>

00801a7a <alloc_sockfd>:
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	83 ec 1c             	sub    $0x1c,%esp
  801a82:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a87:	50                   	push   %eax
  801a88:	e8 78 f7 ff ff       	call   801205 <fd_alloc>
  801a8d:	89 c3                	mov    %eax,%ebx
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	85 c0                	test   %eax,%eax
  801a94:	78 43                	js     801ad9 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a96:	83 ec 04             	sub    $0x4,%esp
  801a99:	68 07 04 00 00       	push   $0x407
  801a9e:	ff 75 f4             	push   -0xc(%ebp)
  801aa1:	6a 00                	push   $0x0
  801aa3:	e8 60 f1 ff ff       	call   800c08 <sys_page_alloc>
  801aa8:	89 c3                	mov    %eax,%ebx
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	78 28                	js     801ad9 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aba:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ac6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	50                   	push   %eax
  801acd:	e8 0c f7 ff ff       	call   8011de <fd2num>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	eb 0c                	jmp    801ae5 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	56                   	push   %esi
  801add:	e8 e4 01 00 00       	call   801cc6 <nsipc_close>
		return r;
  801ae2:	83 c4 10             	add    $0x10,%esp
}
  801ae5:	89 d8                	mov    %ebx,%eax
  801ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <accept>:
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801af4:	8b 45 08             	mov    0x8(%ebp),%eax
  801af7:	e8 4e ff ff ff       	call   801a4a <fd2sockid>
  801afc:	85 c0                	test   %eax,%eax
  801afe:	78 1b                	js     801b1b <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	ff 75 10             	push   0x10(%ebp)
  801b06:	ff 75 0c             	push   0xc(%ebp)
  801b09:	50                   	push   %eax
  801b0a:	e8 0e 01 00 00       	call   801c1d <nsipc_accept>
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 05                	js     801b1b <accept+0x2d>
	return alloc_sockfd(r);
  801b16:	e8 5f ff ff ff       	call   801a7a <alloc_sockfd>
}
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <bind>:
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	e8 1f ff ff ff       	call   801a4a <fd2sockid>
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	78 12                	js     801b41 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b2f:	83 ec 04             	sub    $0x4,%esp
  801b32:	ff 75 10             	push   0x10(%ebp)
  801b35:	ff 75 0c             	push   0xc(%ebp)
  801b38:	50                   	push   %eax
  801b39:	e8 31 01 00 00       	call   801c6f <nsipc_bind>
  801b3e:	83 c4 10             	add    $0x10,%esp
}
  801b41:	c9                   	leave  
  801b42:	c3                   	ret    

00801b43 <shutdown>:
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	e8 f9 fe ff ff       	call   801a4a <fd2sockid>
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 0f                	js     801b64 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b55:	83 ec 08             	sub    $0x8,%esp
  801b58:	ff 75 0c             	push   0xc(%ebp)
  801b5b:	50                   	push   %eax
  801b5c:	e8 43 01 00 00       	call   801ca4 <nsipc_shutdown>
  801b61:	83 c4 10             	add    $0x10,%esp
}
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <connect>:
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6f:	e8 d6 fe ff ff       	call   801a4a <fd2sockid>
  801b74:	85 c0                	test   %eax,%eax
  801b76:	78 12                	js     801b8a <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b78:	83 ec 04             	sub    $0x4,%esp
  801b7b:	ff 75 10             	push   0x10(%ebp)
  801b7e:	ff 75 0c             	push   0xc(%ebp)
  801b81:	50                   	push   %eax
  801b82:	e8 59 01 00 00       	call   801ce0 <nsipc_connect>
  801b87:	83 c4 10             	add    $0x10,%esp
}
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <listen>:
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b92:	8b 45 08             	mov    0x8(%ebp),%eax
  801b95:	e8 b0 fe ff ff       	call   801a4a <fd2sockid>
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 0f                	js     801bad <listen+0x21>
	return nsipc_listen(r, backlog);
  801b9e:	83 ec 08             	sub    $0x8,%esp
  801ba1:	ff 75 0c             	push   0xc(%ebp)
  801ba4:	50                   	push   %eax
  801ba5:	e8 6b 01 00 00       	call   801d15 <nsipc_listen>
  801baa:	83 c4 10             	add    $0x10,%esp
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <socket>:

int
socket(int domain, int type, int protocol)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bb5:	ff 75 10             	push   0x10(%ebp)
  801bb8:	ff 75 0c             	push   0xc(%ebp)
  801bbb:	ff 75 08             	push   0x8(%ebp)
  801bbe:	e8 41 02 00 00       	call   801e04 <nsipc_socket>
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	78 05                	js     801bcf <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bca:	e8 ab fe ff ff       	call   801a7a <alloc_sockfd>
}
  801bcf:	c9                   	leave  
  801bd0:	c3                   	ret    

00801bd1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 04             	sub    $0x4,%esp
  801bd8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bda:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801be1:	74 26                	je     801c09 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801be3:	6a 07                	push   $0x7
  801be5:	68 00 70 80 00       	push   $0x807000
  801bea:	53                   	push   %ebx
  801beb:	ff 35 00 80 80 00    	push   0x808000
  801bf1:	e8 55 f5 ff ff       	call   80114b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bf6:	83 c4 0c             	add    $0xc,%esp
  801bf9:	6a 00                	push   $0x0
  801bfb:	6a 00                	push   $0x0
  801bfd:	6a 00                	push   $0x0
  801bff:	e8 d7 f4 ff ff       	call   8010db <ipc_recv>
}
  801c04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c09:	83 ec 0c             	sub    $0xc,%esp
  801c0c:	6a 02                	push   $0x2
  801c0e:	e8 8c f5 ff ff       	call   80119f <ipc_find_env>
  801c13:	a3 00 80 80 00       	mov    %eax,0x808000
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	eb c6                	jmp    801be3 <nsipc+0x12>

00801c1d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c2d:	8b 06                	mov    (%esi),%eax
  801c2f:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c34:	b8 01 00 00 00       	mov    $0x1,%eax
  801c39:	e8 93 ff ff ff       	call   801bd1 <nsipc>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	85 c0                	test   %eax,%eax
  801c42:	79 09                	jns    801c4d <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c44:	89 d8                	mov    %ebx,%eax
  801c46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c49:	5b                   	pop    %ebx
  801c4a:	5e                   	pop    %esi
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c4d:	83 ec 04             	sub    $0x4,%esp
  801c50:	ff 35 10 70 80 00    	push   0x807010
  801c56:	68 00 70 80 00       	push   $0x807000
  801c5b:	ff 75 0c             	push   0xc(%ebp)
  801c5e:	e8 3f ed ff ff       	call   8009a2 <memmove>
		*addrlen = ret->ret_addrlen;
  801c63:	a1 10 70 80 00       	mov    0x807010,%eax
  801c68:	89 06                	mov    %eax,(%esi)
  801c6a:	83 c4 10             	add    $0x10,%esp
	return r;
  801c6d:	eb d5                	jmp    801c44 <nsipc_accept+0x27>

00801c6f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	53                   	push   %ebx
  801c73:	83 ec 08             	sub    $0x8,%esp
  801c76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c79:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c81:	53                   	push   %ebx
  801c82:	ff 75 0c             	push   0xc(%ebp)
  801c85:	68 04 70 80 00       	push   $0x807004
  801c8a:	e8 13 ed ff ff       	call   8009a2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c8f:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c95:	b8 02 00 00 00       	mov    $0x2,%eax
  801c9a:	e8 32 ff ff ff       	call   801bd1 <nsipc>
}
  801c9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca2:	c9                   	leave  
  801ca3:	c3                   	ret    

00801ca4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801caa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cad:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb5:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801cba:	b8 03 00 00 00       	mov    $0x3,%eax
  801cbf:	e8 0d ff ff ff       	call   801bd1 <nsipc>
}
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <nsipc_close>:

int
nsipc_close(int s)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801cd4:	b8 04 00 00 00       	mov    $0x4,%eax
  801cd9:	e8 f3 fe ff ff       	call   801bd1 <nsipc>
}
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 08             	sub    $0x8,%esp
  801ce7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ced:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cf2:	53                   	push   %ebx
  801cf3:	ff 75 0c             	push   0xc(%ebp)
  801cf6:	68 04 70 80 00       	push   $0x807004
  801cfb:	e8 a2 ec ff ff       	call   8009a2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d00:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801d06:	b8 05 00 00 00       	mov    $0x5,%eax
  801d0b:	e8 c1 fe ff ff       	call   801bd1 <nsipc>
}
  801d10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d26:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d2b:	b8 06 00 00 00       	mov    $0x6,%eax
  801d30:	e8 9c fe ff ff       	call   801bd1 <nsipc>
}
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	56                   	push   %esi
  801d3b:	53                   	push   %ebx
  801d3c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d47:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d4d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d50:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d55:	b8 07 00 00 00       	mov    $0x7,%eax
  801d5a:	e8 72 fe ff ff       	call   801bd1 <nsipc>
  801d5f:	89 c3                	mov    %eax,%ebx
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 22                	js     801d87 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d65:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d6a:	39 c6                	cmp    %eax,%esi
  801d6c:	0f 4e c6             	cmovle %esi,%eax
  801d6f:	39 c3                	cmp    %eax,%ebx
  801d71:	7f 1d                	jg     801d90 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d73:	83 ec 04             	sub    $0x4,%esp
  801d76:	53                   	push   %ebx
  801d77:	68 00 70 80 00       	push   $0x807000
  801d7c:	ff 75 0c             	push   0xc(%ebp)
  801d7f:	e8 1e ec ff ff       	call   8009a2 <memmove>
  801d84:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d87:	89 d8                	mov    %ebx,%eax
  801d89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8c:	5b                   	pop    %ebx
  801d8d:	5e                   	pop    %esi
  801d8e:	5d                   	pop    %ebp
  801d8f:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d90:	68 47 2b 80 00       	push   $0x802b47
  801d95:	68 0f 2b 80 00       	push   $0x802b0f
  801d9a:	6a 62                	push   $0x62
  801d9c:	68 5c 2b 80 00       	push   $0x802b5c
  801da1:	e8 b1 e3 ff ff       	call   800157 <_panic>

00801da6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	53                   	push   %ebx
  801daa:	83 ec 04             	sub    $0x4,%esp
  801dad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801db0:	8b 45 08             	mov    0x8(%ebp),%eax
  801db3:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801db8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dbe:	7f 2e                	jg     801dee <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dc0:	83 ec 04             	sub    $0x4,%esp
  801dc3:	53                   	push   %ebx
  801dc4:	ff 75 0c             	push   0xc(%ebp)
  801dc7:	68 0c 70 80 00       	push   $0x80700c
  801dcc:	e8 d1 eb ff ff       	call   8009a2 <memmove>
	nsipcbuf.send.req_size = size;
  801dd1:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801dd7:	8b 45 14             	mov    0x14(%ebp),%eax
  801dda:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801ddf:	b8 08 00 00 00       	mov    $0x8,%eax
  801de4:	e8 e8 fd ff ff       	call   801bd1 <nsipc>
}
  801de9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    
	assert(size < 1600);
  801dee:	68 68 2b 80 00       	push   $0x802b68
  801df3:	68 0f 2b 80 00       	push   $0x802b0f
  801df8:	6a 6d                	push   $0x6d
  801dfa:	68 5c 2b 80 00       	push   $0x802b5c
  801dff:	e8 53 e3 ff ff       	call   800157 <_panic>

00801e04 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801e12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e15:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801e1a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e1d:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e22:	b8 09 00 00 00       	mov    $0x9,%eax
  801e27:	e8 a5 fd ff ff       	call   801bd1 <nsipc>
}
  801e2c:	c9                   	leave  
  801e2d:	c3                   	ret    

00801e2e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	56                   	push   %esi
  801e32:	53                   	push   %ebx
  801e33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e36:	83 ec 0c             	sub    $0xc,%esp
  801e39:	ff 75 08             	push   0x8(%ebp)
  801e3c:	e8 ad f3 ff ff       	call   8011ee <fd2data>
  801e41:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e43:	83 c4 08             	add    $0x8,%esp
  801e46:	68 74 2b 80 00       	push   $0x802b74
  801e4b:	53                   	push   %ebx
  801e4c:	e8 bb e9 ff ff       	call   80080c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e51:	8b 46 04             	mov    0x4(%esi),%eax
  801e54:	2b 06                	sub    (%esi),%eax
  801e56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e5c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e63:	00 00 00 
	stat->st_dev = &devpipe;
  801e66:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e6d:	30 80 00 
	return 0;
}
  801e70:	b8 00 00 00 00       	mov    $0x0,%eax
  801e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	53                   	push   %ebx
  801e80:	83 ec 0c             	sub    $0xc,%esp
  801e83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e86:	53                   	push   %ebx
  801e87:	6a 00                	push   $0x0
  801e89:	e8 ff ed ff ff       	call   800c8d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e8e:	89 1c 24             	mov    %ebx,(%esp)
  801e91:	e8 58 f3 ff ff       	call   8011ee <fd2data>
  801e96:	83 c4 08             	add    $0x8,%esp
  801e99:	50                   	push   %eax
  801e9a:	6a 00                	push   $0x0
  801e9c:	e8 ec ed ff ff       	call   800c8d <sys_page_unmap>
}
  801ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <_pipeisclosed>:
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	57                   	push   %edi
  801eaa:	56                   	push   %esi
  801eab:	53                   	push   %ebx
  801eac:	83 ec 1c             	sub    $0x1c,%esp
  801eaf:	89 c7                	mov    %eax,%edi
  801eb1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801eb3:	a1 00 40 80 00       	mov    0x804000,%eax
  801eb8:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ebb:	83 ec 0c             	sub    $0xc,%esp
  801ebe:	57                   	push   %edi
  801ebf:	e8 c4 04 00 00       	call   802388 <pageref>
  801ec4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ec7:	89 34 24             	mov    %esi,(%esp)
  801eca:	e8 b9 04 00 00       	call   802388 <pageref>
		nn = thisenv->env_runs;
  801ecf:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ed5:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	39 cb                	cmp    %ecx,%ebx
  801edd:	74 1b                	je     801efa <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801edf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ee2:	75 cf                	jne    801eb3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ee4:	8b 42 68             	mov    0x68(%edx),%eax
  801ee7:	6a 01                	push   $0x1
  801ee9:	50                   	push   %eax
  801eea:	53                   	push   %ebx
  801eeb:	68 7b 2b 80 00       	push   $0x802b7b
  801ef0:	e8 3d e3 ff ff       	call   800232 <cprintf>
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	eb b9                	jmp    801eb3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801efa:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801efd:	0f 94 c0             	sete   %al
  801f00:	0f b6 c0             	movzbl %al,%eax
}
  801f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f06:	5b                   	pop    %ebx
  801f07:	5e                   	pop    %esi
  801f08:	5f                   	pop    %edi
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    

00801f0b <devpipe_write>:
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	57                   	push   %edi
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
  801f11:	83 ec 28             	sub    $0x28,%esp
  801f14:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f17:	56                   	push   %esi
  801f18:	e8 d1 f2 ff ff       	call   8011ee <fd2data>
  801f1d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	bf 00 00 00 00       	mov    $0x0,%edi
  801f27:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f2a:	75 09                	jne    801f35 <devpipe_write+0x2a>
	return i;
  801f2c:	89 f8                	mov    %edi,%eax
  801f2e:	eb 23                	jmp    801f53 <devpipe_write+0x48>
			sys_yield();
  801f30:	e8 b4 ec ff ff       	call   800be9 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f35:	8b 43 04             	mov    0x4(%ebx),%eax
  801f38:	8b 0b                	mov    (%ebx),%ecx
  801f3a:	8d 51 20             	lea    0x20(%ecx),%edx
  801f3d:	39 d0                	cmp    %edx,%eax
  801f3f:	72 1a                	jb     801f5b <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f41:	89 da                	mov    %ebx,%edx
  801f43:	89 f0                	mov    %esi,%eax
  801f45:	e8 5c ff ff ff       	call   801ea6 <_pipeisclosed>
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	74 e2                	je     801f30 <devpipe_write+0x25>
				return 0;
  801f4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f56:	5b                   	pop    %ebx
  801f57:	5e                   	pop    %esi
  801f58:	5f                   	pop    %edi
  801f59:	5d                   	pop    %ebp
  801f5a:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f5e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f62:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f65:	89 c2                	mov    %eax,%edx
  801f67:	c1 fa 1f             	sar    $0x1f,%edx
  801f6a:	89 d1                	mov    %edx,%ecx
  801f6c:	c1 e9 1b             	shr    $0x1b,%ecx
  801f6f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f72:	83 e2 1f             	and    $0x1f,%edx
  801f75:	29 ca                	sub    %ecx,%edx
  801f77:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f7b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f7f:	83 c0 01             	add    $0x1,%eax
  801f82:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f85:	83 c7 01             	add    $0x1,%edi
  801f88:	eb 9d                	jmp    801f27 <devpipe_write+0x1c>

00801f8a <devpipe_read>:
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	57                   	push   %edi
  801f8e:	56                   	push   %esi
  801f8f:	53                   	push   %ebx
  801f90:	83 ec 18             	sub    $0x18,%esp
  801f93:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f96:	57                   	push   %edi
  801f97:	e8 52 f2 ff ff       	call   8011ee <fd2data>
  801f9c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	be 00 00 00 00       	mov    $0x0,%esi
  801fa6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fa9:	75 13                	jne    801fbe <devpipe_read+0x34>
	return i;
  801fab:	89 f0                	mov    %esi,%eax
  801fad:	eb 02                	jmp    801fb1 <devpipe_read+0x27>
				return i;
  801faf:	89 f0                	mov    %esi,%eax
}
  801fb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb4:	5b                   	pop    %ebx
  801fb5:	5e                   	pop    %esi
  801fb6:	5f                   	pop    %edi
  801fb7:	5d                   	pop    %ebp
  801fb8:	c3                   	ret    
			sys_yield();
  801fb9:	e8 2b ec ff ff       	call   800be9 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801fbe:	8b 03                	mov    (%ebx),%eax
  801fc0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fc3:	75 18                	jne    801fdd <devpipe_read+0x53>
			if (i > 0)
  801fc5:	85 f6                	test   %esi,%esi
  801fc7:	75 e6                	jne    801faf <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801fc9:	89 da                	mov    %ebx,%edx
  801fcb:	89 f8                	mov    %edi,%eax
  801fcd:	e8 d4 fe ff ff       	call   801ea6 <_pipeisclosed>
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	74 e3                	je     801fb9 <devpipe_read+0x2f>
				return 0;
  801fd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdb:	eb d4                	jmp    801fb1 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fdd:	99                   	cltd   
  801fde:	c1 ea 1b             	shr    $0x1b,%edx
  801fe1:	01 d0                	add    %edx,%eax
  801fe3:	83 e0 1f             	and    $0x1f,%eax
  801fe6:	29 d0                	sub    %edx,%eax
  801fe8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ff0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ff3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ff6:	83 c6 01             	add    $0x1,%esi
  801ff9:	eb ab                	jmp    801fa6 <devpipe_read+0x1c>

00801ffb <pipe>:
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	56                   	push   %esi
  801fff:	53                   	push   %ebx
  802000:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802003:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802006:	50                   	push   %eax
  802007:	e8 f9 f1 ff ff       	call   801205 <fd_alloc>
  80200c:	89 c3                	mov    %eax,%ebx
  80200e:	83 c4 10             	add    $0x10,%esp
  802011:	85 c0                	test   %eax,%eax
  802013:	0f 88 23 01 00 00    	js     80213c <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802019:	83 ec 04             	sub    $0x4,%esp
  80201c:	68 07 04 00 00       	push   $0x407
  802021:	ff 75 f4             	push   -0xc(%ebp)
  802024:	6a 00                	push   $0x0
  802026:	e8 dd eb ff ff       	call   800c08 <sys_page_alloc>
  80202b:	89 c3                	mov    %eax,%ebx
  80202d:	83 c4 10             	add    $0x10,%esp
  802030:	85 c0                	test   %eax,%eax
  802032:	0f 88 04 01 00 00    	js     80213c <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802038:	83 ec 0c             	sub    $0xc,%esp
  80203b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80203e:	50                   	push   %eax
  80203f:	e8 c1 f1 ff ff       	call   801205 <fd_alloc>
  802044:	89 c3                	mov    %eax,%ebx
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	85 c0                	test   %eax,%eax
  80204b:	0f 88 db 00 00 00    	js     80212c <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802051:	83 ec 04             	sub    $0x4,%esp
  802054:	68 07 04 00 00       	push   $0x407
  802059:	ff 75 f0             	push   -0x10(%ebp)
  80205c:	6a 00                	push   $0x0
  80205e:	e8 a5 eb ff ff       	call   800c08 <sys_page_alloc>
  802063:	89 c3                	mov    %eax,%ebx
  802065:	83 c4 10             	add    $0x10,%esp
  802068:	85 c0                	test   %eax,%eax
  80206a:	0f 88 bc 00 00 00    	js     80212c <pipe+0x131>
	va = fd2data(fd0);
  802070:	83 ec 0c             	sub    $0xc,%esp
  802073:	ff 75 f4             	push   -0xc(%ebp)
  802076:	e8 73 f1 ff ff       	call   8011ee <fd2data>
  80207b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80207d:	83 c4 0c             	add    $0xc,%esp
  802080:	68 07 04 00 00       	push   $0x407
  802085:	50                   	push   %eax
  802086:	6a 00                	push   $0x0
  802088:	e8 7b eb ff ff       	call   800c08 <sys_page_alloc>
  80208d:	89 c3                	mov    %eax,%ebx
  80208f:	83 c4 10             	add    $0x10,%esp
  802092:	85 c0                	test   %eax,%eax
  802094:	0f 88 82 00 00 00    	js     80211c <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209a:	83 ec 0c             	sub    $0xc,%esp
  80209d:	ff 75 f0             	push   -0x10(%ebp)
  8020a0:	e8 49 f1 ff ff       	call   8011ee <fd2data>
  8020a5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020ac:	50                   	push   %eax
  8020ad:	6a 00                	push   $0x0
  8020af:	56                   	push   %esi
  8020b0:	6a 00                	push   $0x0
  8020b2:	e8 94 eb ff ff       	call   800c4b <sys_page_map>
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	83 c4 20             	add    $0x20,%esp
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	78 4e                	js     80210e <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8020c0:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8020c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020c8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8020ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020cd:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020d7:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020dc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020e3:	83 ec 0c             	sub    $0xc,%esp
  8020e6:	ff 75 f4             	push   -0xc(%ebp)
  8020e9:	e8 f0 f0 ff ff       	call   8011de <fd2num>
  8020ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020f1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020f3:	83 c4 04             	add    $0x4,%esp
  8020f6:	ff 75 f0             	push   -0x10(%ebp)
  8020f9:	e8 e0 f0 ff ff       	call   8011de <fd2num>
  8020fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802101:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802104:	83 c4 10             	add    $0x10,%esp
  802107:	bb 00 00 00 00       	mov    $0x0,%ebx
  80210c:	eb 2e                	jmp    80213c <pipe+0x141>
	sys_page_unmap(0, va);
  80210e:	83 ec 08             	sub    $0x8,%esp
  802111:	56                   	push   %esi
  802112:	6a 00                	push   $0x0
  802114:	e8 74 eb ff ff       	call   800c8d <sys_page_unmap>
  802119:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80211c:	83 ec 08             	sub    $0x8,%esp
  80211f:	ff 75 f0             	push   -0x10(%ebp)
  802122:	6a 00                	push   $0x0
  802124:	e8 64 eb ff ff       	call   800c8d <sys_page_unmap>
  802129:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80212c:	83 ec 08             	sub    $0x8,%esp
  80212f:	ff 75 f4             	push   -0xc(%ebp)
  802132:	6a 00                	push   $0x0
  802134:	e8 54 eb ff ff       	call   800c8d <sys_page_unmap>
  802139:	83 c4 10             	add    $0x10,%esp
}
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802141:	5b                   	pop    %ebx
  802142:	5e                   	pop    %esi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    

00802145 <pipeisclosed>:
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80214e:	50                   	push   %eax
  80214f:	ff 75 08             	push   0x8(%ebp)
  802152:	e8 fe f0 ff ff       	call   801255 <fd_lookup>
  802157:	83 c4 10             	add    $0x10,%esp
  80215a:	85 c0                	test   %eax,%eax
  80215c:	78 18                	js     802176 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80215e:	83 ec 0c             	sub    $0xc,%esp
  802161:	ff 75 f4             	push   -0xc(%ebp)
  802164:	e8 85 f0 ff ff       	call   8011ee <fd2data>
  802169:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80216b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216e:	e8 33 fd ff ff       	call   801ea6 <_pipeisclosed>
  802173:	83 c4 10             	add    $0x10,%esp
}
  802176:	c9                   	leave  
  802177:	c3                   	ret    

00802178 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802178:	b8 00 00 00 00       	mov    $0x0,%eax
  80217d:	c3                   	ret    

0080217e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80217e:	55                   	push   %ebp
  80217f:	89 e5                	mov    %esp,%ebp
  802181:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802184:	68 93 2b 80 00       	push   $0x802b93
  802189:	ff 75 0c             	push   0xc(%ebp)
  80218c:	e8 7b e6 ff ff       	call   80080c <strcpy>
	return 0;
}
  802191:	b8 00 00 00 00       	mov    $0x0,%eax
  802196:	c9                   	leave  
  802197:	c3                   	ret    

00802198 <devcons_write>:
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	57                   	push   %edi
  80219c:	56                   	push   %esi
  80219d:	53                   	push   %ebx
  80219e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8021a4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021a9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8021af:	eb 2e                	jmp    8021df <devcons_write+0x47>
		m = n - tot;
  8021b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021b4:	29 f3                	sub    %esi,%ebx
  8021b6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8021bb:	39 c3                	cmp    %eax,%ebx
  8021bd:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021c0:	83 ec 04             	sub    $0x4,%esp
  8021c3:	53                   	push   %ebx
  8021c4:	89 f0                	mov    %esi,%eax
  8021c6:	03 45 0c             	add    0xc(%ebp),%eax
  8021c9:	50                   	push   %eax
  8021ca:	57                   	push   %edi
  8021cb:	e8 d2 e7 ff ff       	call   8009a2 <memmove>
		sys_cputs(buf, m);
  8021d0:	83 c4 08             	add    $0x8,%esp
  8021d3:	53                   	push   %ebx
  8021d4:	57                   	push   %edi
  8021d5:	e8 72 e9 ff ff       	call   800b4c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021da:	01 de                	add    %ebx,%esi
  8021dc:	83 c4 10             	add    $0x10,%esp
  8021df:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021e2:	72 cd                	jb     8021b1 <devcons_write+0x19>
}
  8021e4:	89 f0                	mov    %esi,%eax
  8021e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021e9:	5b                   	pop    %ebx
  8021ea:	5e                   	pop    %esi
  8021eb:	5f                   	pop    %edi
  8021ec:	5d                   	pop    %ebp
  8021ed:	c3                   	ret    

008021ee <devcons_read>:
{
  8021ee:	55                   	push   %ebp
  8021ef:	89 e5                	mov    %esp,%ebp
  8021f1:	83 ec 08             	sub    $0x8,%esp
  8021f4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8021f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021fd:	75 07                	jne    802206 <devcons_read+0x18>
  8021ff:	eb 1f                	jmp    802220 <devcons_read+0x32>
		sys_yield();
  802201:	e8 e3 e9 ff ff       	call   800be9 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802206:	e8 5f e9 ff ff       	call   800b6a <sys_cgetc>
  80220b:	85 c0                	test   %eax,%eax
  80220d:	74 f2                	je     802201 <devcons_read+0x13>
	if (c < 0)
  80220f:	78 0f                	js     802220 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802211:	83 f8 04             	cmp    $0x4,%eax
  802214:	74 0c                	je     802222 <devcons_read+0x34>
	*(char*)vbuf = c;
  802216:	8b 55 0c             	mov    0xc(%ebp),%edx
  802219:	88 02                	mov    %al,(%edx)
	return 1;
  80221b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802220:	c9                   	leave  
  802221:	c3                   	ret    
		return 0;
  802222:	b8 00 00 00 00       	mov    $0x0,%eax
  802227:	eb f7                	jmp    802220 <devcons_read+0x32>

00802229 <cputchar>:
{
  802229:	55                   	push   %ebp
  80222a:	89 e5                	mov    %esp,%ebp
  80222c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80222f:	8b 45 08             	mov    0x8(%ebp),%eax
  802232:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802235:	6a 01                	push   $0x1
  802237:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80223a:	50                   	push   %eax
  80223b:	e8 0c e9 ff ff       	call   800b4c <sys_cputs>
}
  802240:	83 c4 10             	add    $0x10,%esp
  802243:	c9                   	leave  
  802244:	c3                   	ret    

00802245 <getchar>:
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80224b:	6a 01                	push   $0x1
  80224d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802250:	50                   	push   %eax
  802251:	6a 00                	push   $0x0
  802253:	e8 66 f2 ff ff       	call   8014be <read>
	if (r < 0)
  802258:	83 c4 10             	add    $0x10,%esp
  80225b:	85 c0                	test   %eax,%eax
  80225d:	78 06                	js     802265 <getchar+0x20>
	if (r < 1)
  80225f:	74 06                	je     802267 <getchar+0x22>
	return c;
  802261:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802265:	c9                   	leave  
  802266:	c3                   	ret    
		return -E_EOF;
  802267:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80226c:	eb f7                	jmp    802265 <getchar+0x20>

0080226e <iscons>:
{
  80226e:	55                   	push   %ebp
  80226f:	89 e5                	mov    %esp,%ebp
  802271:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802274:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802277:	50                   	push   %eax
  802278:	ff 75 08             	push   0x8(%ebp)
  80227b:	e8 d5 ef ff ff       	call   801255 <fd_lookup>
  802280:	83 c4 10             	add    $0x10,%esp
  802283:	85 c0                	test   %eax,%eax
  802285:	78 11                	js     802298 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802287:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802290:	39 10                	cmp    %edx,(%eax)
  802292:	0f 94 c0             	sete   %al
  802295:	0f b6 c0             	movzbl %al,%eax
}
  802298:	c9                   	leave  
  802299:	c3                   	ret    

0080229a <opencons>:
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8022a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a3:	50                   	push   %eax
  8022a4:	e8 5c ef ff ff       	call   801205 <fd_alloc>
  8022a9:	83 c4 10             	add    $0x10,%esp
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	78 3a                	js     8022ea <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022b0:	83 ec 04             	sub    $0x4,%esp
  8022b3:	68 07 04 00 00       	push   $0x407
  8022b8:	ff 75 f4             	push   -0xc(%ebp)
  8022bb:	6a 00                	push   $0x0
  8022bd:	e8 46 e9 ff ff       	call   800c08 <sys_page_alloc>
  8022c2:	83 c4 10             	add    $0x10,%esp
  8022c5:	85 c0                	test   %eax,%eax
  8022c7:	78 21                	js     8022ea <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022d2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022de:	83 ec 0c             	sub    $0xc,%esp
  8022e1:	50                   	push   %eax
  8022e2:	e8 f7 ee ff ff       	call   8011de <fd2num>
  8022e7:	83 c4 10             	add    $0x10,%esp
}
  8022ea:	c9                   	leave  
  8022eb:	c3                   	ret    

008022ec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8022f2:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8022f9:	74 0a                	je     802305 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fe:	a3 04 80 80 00       	mov    %eax,0x808004
}
  802303:	c9                   	leave  
  802304:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802305:	e8 c0 e8 ff ff       	call   800bca <sys_getenvid>
  80230a:	83 ec 04             	sub    $0x4,%esp
  80230d:	68 07 0e 00 00       	push   $0xe07
  802312:	68 00 f0 bf ee       	push   $0xeebff000
  802317:	50                   	push   %eax
  802318:	e8 eb e8 ff ff       	call   800c08 <sys_page_alloc>
		if (r < 0) {
  80231d:	83 c4 10             	add    $0x10,%esp
  802320:	85 c0                	test   %eax,%eax
  802322:	78 2c                	js     802350 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802324:	e8 a1 e8 ff ff       	call   800bca <sys_getenvid>
  802329:	83 ec 08             	sub    $0x8,%esp
  80232c:	68 62 23 80 00       	push   $0x802362
  802331:	50                   	push   %eax
  802332:	e8 1c ea ff ff       	call   800d53 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802337:	83 c4 10             	add    $0x10,%esp
  80233a:	85 c0                	test   %eax,%eax
  80233c:	79 bd                	jns    8022fb <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80233e:	50                   	push   %eax
  80233f:	68 e0 2b 80 00       	push   $0x802be0
  802344:	6a 28                	push   $0x28
  802346:	68 16 2c 80 00       	push   $0x802c16
  80234b:	e8 07 de ff ff       	call   800157 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802350:	50                   	push   %eax
  802351:	68 a0 2b 80 00       	push   $0x802ba0
  802356:	6a 23                	push   $0x23
  802358:	68 16 2c 80 00       	push   $0x802c16
  80235d:	e8 f5 dd ff ff       	call   800157 <_panic>

00802362 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802362:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802363:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802368:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80236a:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80236d:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802371:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802374:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802378:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80237c:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80237e:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802381:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802382:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802385:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802386:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802387:	c3                   	ret    

00802388 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802388:	55                   	push   %ebp
  802389:	89 e5                	mov    %esp,%ebp
  80238b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80238e:	89 c2                	mov    %eax,%edx
  802390:	c1 ea 16             	shr    $0x16,%edx
  802393:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80239a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80239f:	f6 c1 01             	test   $0x1,%cl
  8023a2:	74 1c                	je     8023c0 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8023a4:	c1 e8 0c             	shr    $0xc,%eax
  8023a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023ae:	a8 01                	test   $0x1,%al
  8023b0:	74 0e                	je     8023c0 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023b2:	c1 e8 0c             	shr    $0xc,%eax
  8023b5:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8023bc:	ef 
  8023bd:	0f b7 d2             	movzwl %dx,%edx
}
  8023c0:	89 d0                	mov    %edx,%eax
  8023c2:	5d                   	pop    %ebp
  8023c3:	c3                   	ret    
  8023c4:	66 90                	xchg   %ax,%ax
  8023c6:	66 90                	xchg   %ax,%ax
  8023c8:	66 90                	xchg   %ax,%ax
  8023ca:	66 90                	xchg   %ax,%ax
  8023cc:	66 90                	xchg   %ax,%ax
  8023ce:	66 90                	xchg   %ax,%ax

008023d0 <__udivdi3>:
  8023d0:	f3 0f 1e fb          	endbr32 
  8023d4:	55                   	push   %ebp
  8023d5:	57                   	push   %edi
  8023d6:	56                   	push   %esi
  8023d7:	53                   	push   %ebx
  8023d8:	83 ec 1c             	sub    $0x1c,%esp
  8023db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	75 19                	jne    802408 <__udivdi3+0x38>
  8023ef:	39 f3                	cmp    %esi,%ebx
  8023f1:	76 4d                	jbe    802440 <__udivdi3+0x70>
  8023f3:	31 ff                	xor    %edi,%edi
  8023f5:	89 e8                	mov    %ebp,%eax
  8023f7:	89 f2                	mov    %esi,%edx
  8023f9:	f7 f3                	div    %ebx
  8023fb:	89 fa                	mov    %edi,%edx
  8023fd:	83 c4 1c             	add    $0x1c,%esp
  802400:	5b                   	pop    %ebx
  802401:	5e                   	pop    %esi
  802402:	5f                   	pop    %edi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    
  802405:	8d 76 00             	lea    0x0(%esi),%esi
  802408:	39 f0                	cmp    %esi,%eax
  80240a:	76 14                	jbe    802420 <__udivdi3+0x50>
  80240c:	31 ff                	xor    %edi,%edi
  80240e:	31 c0                	xor    %eax,%eax
  802410:	89 fa                	mov    %edi,%edx
  802412:	83 c4 1c             	add    $0x1c,%esp
  802415:	5b                   	pop    %ebx
  802416:	5e                   	pop    %esi
  802417:	5f                   	pop    %edi
  802418:	5d                   	pop    %ebp
  802419:	c3                   	ret    
  80241a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802420:	0f bd f8             	bsr    %eax,%edi
  802423:	83 f7 1f             	xor    $0x1f,%edi
  802426:	75 48                	jne    802470 <__udivdi3+0xa0>
  802428:	39 f0                	cmp    %esi,%eax
  80242a:	72 06                	jb     802432 <__udivdi3+0x62>
  80242c:	31 c0                	xor    %eax,%eax
  80242e:	39 eb                	cmp    %ebp,%ebx
  802430:	77 de                	ja     802410 <__udivdi3+0x40>
  802432:	b8 01 00 00 00       	mov    $0x1,%eax
  802437:	eb d7                	jmp    802410 <__udivdi3+0x40>
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	89 d9                	mov    %ebx,%ecx
  802442:	85 db                	test   %ebx,%ebx
  802444:	75 0b                	jne    802451 <__udivdi3+0x81>
  802446:	b8 01 00 00 00       	mov    $0x1,%eax
  80244b:	31 d2                	xor    %edx,%edx
  80244d:	f7 f3                	div    %ebx
  80244f:	89 c1                	mov    %eax,%ecx
  802451:	31 d2                	xor    %edx,%edx
  802453:	89 f0                	mov    %esi,%eax
  802455:	f7 f1                	div    %ecx
  802457:	89 c6                	mov    %eax,%esi
  802459:	89 e8                	mov    %ebp,%eax
  80245b:	89 f7                	mov    %esi,%edi
  80245d:	f7 f1                	div    %ecx
  80245f:	89 fa                	mov    %edi,%edx
  802461:	83 c4 1c             	add    $0x1c,%esp
  802464:	5b                   	pop    %ebx
  802465:	5e                   	pop    %esi
  802466:	5f                   	pop    %edi
  802467:	5d                   	pop    %ebp
  802468:	c3                   	ret    
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	89 f9                	mov    %edi,%ecx
  802472:	ba 20 00 00 00       	mov    $0x20,%edx
  802477:	29 fa                	sub    %edi,%edx
  802479:	d3 e0                	shl    %cl,%eax
  80247b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80247f:	89 d1                	mov    %edx,%ecx
  802481:	89 d8                	mov    %ebx,%eax
  802483:	d3 e8                	shr    %cl,%eax
  802485:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802489:	09 c1                	or     %eax,%ecx
  80248b:	89 f0                	mov    %esi,%eax
  80248d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802491:	89 f9                	mov    %edi,%ecx
  802493:	d3 e3                	shl    %cl,%ebx
  802495:	89 d1                	mov    %edx,%ecx
  802497:	d3 e8                	shr    %cl,%eax
  802499:	89 f9                	mov    %edi,%ecx
  80249b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80249f:	89 eb                	mov    %ebp,%ebx
  8024a1:	d3 e6                	shl    %cl,%esi
  8024a3:	89 d1                	mov    %edx,%ecx
  8024a5:	d3 eb                	shr    %cl,%ebx
  8024a7:	09 f3                	or     %esi,%ebx
  8024a9:	89 c6                	mov    %eax,%esi
  8024ab:	89 f2                	mov    %esi,%edx
  8024ad:	89 d8                	mov    %ebx,%eax
  8024af:	f7 74 24 08          	divl   0x8(%esp)
  8024b3:	89 d6                	mov    %edx,%esi
  8024b5:	89 c3                	mov    %eax,%ebx
  8024b7:	f7 64 24 0c          	mull   0xc(%esp)
  8024bb:	39 d6                	cmp    %edx,%esi
  8024bd:	72 19                	jb     8024d8 <__udivdi3+0x108>
  8024bf:	89 f9                	mov    %edi,%ecx
  8024c1:	d3 e5                	shl    %cl,%ebp
  8024c3:	39 c5                	cmp    %eax,%ebp
  8024c5:	73 04                	jae    8024cb <__udivdi3+0xfb>
  8024c7:	39 d6                	cmp    %edx,%esi
  8024c9:	74 0d                	je     8024d8 <__udivdi3+0x108>
  8024cb:	89 d8                	mov    %ebx,%eax
  8024cd:	31 ff                	xor    %edi,%edi
  8024cf:	e9 3c ff ff ff       	jmp    802410 <__udivdi3+0x40>
  8024d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024d8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024db:	31 ff                	xor    %edi,%edi
  8024dd:	e9 2e ff ff ff       	jmp    802410 <__udivdi3+0x40>
  8024e2:	66 90                	xchg   %ax,%ax
  8024e4:	66 90                	xchg   %ax,%ax
  8024e6:	66 90                	xchg   %ax,%ax
  8024e8:	66 90                	xchg   %ax,%ax
  8024ea:	66 90                	xchg   %ax,%ax
  8024ec:	66 90                	xchg   %ax,%ax
  8024ee:	66 90                	xchg   %ax,%ax

008024f0 <__umoddi3>:
  8024f0:	f3 0f 1e fb          	endbr32 
  8024f4:	55                   	push   %ebp
  8024f5:	57                   	push   %edi
  8024f6:	56                   	push   %esi
  8024f7:	53                   	push   %ebx
  8024f8:	83 ec 1c             	sub    $0x1c,%esp
  8024fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802503:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802507:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80250b:	89 f0                	mov    %esi,%eax
  80250d:	89 da                	mov    %ebx,%edx
  80250f:	85 ff                	test   %edi,%edi
  802511:	75 15                	jne    802528 <__umoddi3+0x38>
  802513:	39 dd                	cmp    %ebx,%ebp
  802515:	76 39                	jbe    802550 <__umoddi3+0x60>
  802517:	f7 f5                	div    %ebp
  802519:	89 d0                	mov    %edx,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	83 c4 1c             	add    $0x1c,%esp
  802520:	5b                   	pop    %ebx
  802521:	5e                   	pop    %esi
  802522:	5f                   	pop    %edi
  802523:	5d                   	pop    %ebp
  802524:	c3                   	ret    
  802525:	8d 76 00             	lea    0x0(%esi),%esi
  802528:	39 df                	cmp    %ebx,%edi
  80252a:	77 f1                	ja     80251d <__umoddi3+0x2d>
  80252c:	0f bd cf             	bsr    %edi,%ecx
  80252f:	83 f1 1f             	xor    $0x1f,%ecx
  802532:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802536:	75 40                	jne    802578 <__umoddi3+0x88>
  802538:	39 df                	cmp    %ebx,%edi
  80253a:	72 04                	jb     802540 <__umoddi3+0x50>
  80253c:	39 f5                	cmp    %esi,%ebp
  80253e:	77 dd                	ja     80251d <__umoddi3+0x2d>
  802540:	89 da                	mov    %ebx,%edx
  802542:	89 f0                	mov    %esi,%eax
  802544:	29 e8                	sub    %ebp,%eax
  802546:	19 fa                	sbb    %edi,%edx
  802548:	eb d3                	jmp    80251d <__umoddi3+0x2d>
  80254a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802550:	89 e9                	mov    %ebp,%ecx
  802552:	85 ed                	test   %ebp,%ebp
  802554:	75 0b                	jne    802561 <__umoddi3+0x71>
  802556:	b8 01 00 00 00       	mov    $0x1,%eax
  80255b:	31 d2                	xor    %edx,%edx
  80255d:	f7 f5                	div    %ebp
  80255f:	89 c1                	mov    %eax,%ecx
  802561:	89 d8                	mov    %ebx,%eax
  802563:	31 d2                	xor    %edx,%edx
  802565:	f7 f1                	div    %ecx
  802567:	89 f0                	mov    %esi,%eax
  802569:	f7 f1                	div    %ecx
  80256b:	89 d0                	mov    %edx,%eax
  80256d:	31 d2                	xor    %edx,%edx
  80256f:	eb ac                	jmp    80251d <__umoddi3+0x2d>
  802571:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802578:	8b 44 24 04          	mov    0x4(%esp),%eax
  80257c:	ba 20 00 00 00       	mov    $0x20,%edx
  802581:	29 c2                	sub    %eax,%edx
  802583:	89 c1                	mov    %eax,%ecx
  802585:	89 e8                	mov    %ebp,%eax
  802587:	d3 e7                	shl    %cl,%edi
  802589:	89 d1                	mov    %edx,%ecx
  80258b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80258f:	d3 e8                	shr    %cl,%eax
  802591:	89 c1                	mov    %eax,%ecx
  802593:	8b 44 24 04          	mov    0x4(%esp),%eax
  802597:	09 f9                	or     %edi,%ecx
  802599:	89 df                	mov    %ebx,%edi
  80259b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80259f:	89 c1                	mov    %eax,%ecx
  8025a1:	d3 e5                	shl    %cl,%ebp
  8025a3:	89 d1                	mov    %edx,%ecx
  8025a5:	d3 ef                	shr    %cl,%edi
  8025a7:	89 c1                	mov    %eax,%ecx
  8025a9:	89 f0                	mov    %esi,%eax
  8025ab:	d3 e3                	shl    %cl,%ebx
  8025ad:	89 d1                	mov    %edx,%ecx
  8025af:	89 fa                	mov    %edi,%edx
  8025b1:	d3 e8                	shr    %cl,%eax
  8025b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025b8:	09 d8                	or     %ebx,%eax
  8025ba:	f7 74 24 08          	divl   0x8(%esp)
  8025be:	89 d3                	mov    %edx,%ebx
  8025c0:	d3 e6                	shl    %cl,%esi
  8025c2:	f7 e5                	mul    %ebp
  8025c4:	89 c7                	mov    %eax,%edi
  8025c6:	89 d1                	mov    %edx,%ecx
  8025c8:	39 d3                	cmp    %edx,%ebx
  8025ca:	72 06                	jb     8025d2 <__umoddi3+0xe2>
  8025cc:	75 0e                	jne    8025dc <__umoddi3+0xec>
  8025ce:	39 c6                	cmp    %eax,%esi
  8025d0:	73 0a                	jae    8025dc <__umoddi3+0xec>
  8025d2:	29 e8                	sub    %ebp,%eax
  8025d4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8025d8:	89 d1                	mov    %edx,%ecx
  8025da:	89 c7                	mov    %eax,%edi
  8025dc:	89 f5                	mov    %esi,%ebp
  8025de:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025e2:	29 fd                	sub    %edi,%ebp
  8025e4:	19 cb                	sbb    %ecx,%ebx
  8025e6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8025eb:	89 d8                	mov    %ebx,%eax
  8025ed:	d3 e0                	shl    %cl,%eax
  8025ef:	89 f1                	mov    %esi,%ecx
  8025f1:	d3 ed                	shr    %cl,%ebp
  8025f3:	d3 eb                	shr    %cl,%ebx
  8025f5:	09 e8                	or     %ebp,%eax
  8025f7:	89 da                	mov    %ebx,%edx
  8025f9:	83 c4 1c             	add    $0x1c,%esp
  8025fc:	5b                   	pop    %ebx
  8025fd:	5e                   	pop    %esi
  8025fe:	5f                   	pop    %edi
  8025ff:	5d                   	pop    %ebp
  802600:	c3                   	ret    
