
obj/user/primes：     文件格式 elf32-i386


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
  800047:	e8 cc 0f 00 00       	call   801018 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 00 14 80 00       	push   $0x801400
  800060:	e8 c2 01 00 00       	call   800227 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 40 0e 00 00       	call   800eaa <fork>
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
  800080:	e8 93 0f 00 00       	call   801018 <ipc_recv>
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
  800097:	e8 e3 0f 00 00       	call   80107f <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb d7                	jmp    800078 <primeproc+0x45>
		panic("fork: %e", id);
  8000a1:	50                   	push   %eax
  8000a2:	68 5c 17 80 00       	push   $0x80175c
  8000a7:	6a 1a                	push   $0x1a
  8000a9:	68 0c 14 80 00       	push   $0x80140c
  8000ae:	e8 99 00 00 00       	call   80014c <_panic>

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
  8000b8:	e8 ed 0d 00 00       	call   800eaa <fork>
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
  8000d0:	e8 aa 0f 00 00       	call   80107f <ipc_send>
	for (i = 2; ; i++)
  8000d5:	83 c3 01             	add    $0x1,%ebx
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	eb ed                	jmp    8000ca <umain+0x17>
		panic("fork: %e", id);
  8000dd:	50                   	push   %eax
  8000de:	68 5c 17 80 00       	push   $0x80175c
  8000e3:	6a 2d                	push   $0x2d
  8000e5:	68 0c 14 80 00       	push   $0x80140c
  8000ea:	e8 5d 00 00 00       	call   80014c <_panic>
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
  8000ff:	e8 bb 0a 00 00       	call   800bbf <sys_getenvid>
  800104:	25 ff 03 00 00       	and    $0x3ff,%eax
  800109:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800111:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800116:	85 db                	test   %ebx,%ebx
  800118:	7e 07                	jle    800121 <libmain+0x2d>
		binaryname = argv[0];
  80011a:	8b 06                	mov    (%esi),%eax
  80011c:	a3 00 20 80 00       	mov    %eax,0x802000

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
  80013d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800140:	6a 00                	push   $0x0
  800142:	e8 37 0a 00 00       	call   800b7e <sys_env_destroy>
}
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800151:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800154:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015a:	e8 60 0a 00 00       	call   800bbf <sys_getenvid>
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	ff 75 0c             	push   0xc(%ebp)
  800165:	ff 75 08             	push   0x8(%ebp)
  800168:	56                   	push   %esi
  800169:	50                   	push   %eax
  80016a:	68 24 14 80 00       	push   $0x801424
  80016f:	e8 b3 00 00 00       	call   800227 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	83 c4 18             	add    $0x18,%esp
  800177:	53                   	push   %ebx
  800178:	ff 75 10             	push   0x10(%ebp)
  80017b:	e8 56 00 00 00       	call   8001d6 <vcprintf>
	cprintf("\n");
  800180:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  800187:	e8 9b 00 00 00       	call   800227 <cprintf>
  80018c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x43>

00800192 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	53                   	push   %ebx
  800196:	83 ec 04             	sub    $0x4,%esp
  800199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019c:	8b 13                	mov    (%ebx),%edx
  80019e:	8d 42 01             	lea    0x1(%edx),%eax
  8001a1:	89 03                	mov    %eax,(%ebx)
  8001a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001af:	74 09                	je     8001ba <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ba:	83 ec 08             	sub    $0x8,%esp
  8001bd:	68 ff 00 00 00       	push   $0xff
  8001c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c5:	50                   	push   %eax
  8001c6:	e8 76 09 00 00       	call   800b41 <sys_cputs>
		b->idx = 0;
  8001cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d1:	83 c4 10             	add    $0x10,%esp
  8001d4:	eb db                	jmp    8001b1 <putch+0x1f>

008001d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e6:	00 00 00 
	b.cnt = 0;
  8001e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f3:	ff 75 0c             	push   0xc(%ebp)
  8001f6:	ff 75 08             	push   0x8(%ebp)
  8001f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ff:	50                   	push   %eax
  800200:	68 92 01 80 00       	push   $0x800192
  800205:	e8 14 01 00 00       	call   80031e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020a:	83 c4 08             	add    $0x8,%esp
  80020d:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800213:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800219:	50                   	push   %eax
  80021a:	e8 22 09 00 00       	call   800b41 <sys_cputs>

	return b.cnt;
}
  80021f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800230:	50                   	push   %eax
  800231:	ff 75 08             	push   0x8(%ebp)
  800234:	e8 9d ff ff ff       	call   8001d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	57                   	push   %edi
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
  800241:	83 ec 1c             	sub    $0x1c,%esp
  800244:	89 c7                	mov    %eax,%edi
  800246:	89 d6                	mov    %edx,%esi
  800248:	8b 45 08             	mov    0x8(%ebp),%eax
  80024b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024e:	89 d1                	mov    %edx,%ecx
  800250:	89 c2                	mov    %eax,%edx
  800252:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800255:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800258:	8b 45 10             	mov    0x10(%ebp),%eax
  80025b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800261:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800268:	39 c2                	cmp    %eax,%edx
  80026a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80026d:	72 3e                	jb     8002ad <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026f:	83 ec 0c             	sub    $0xc,%esp
  800272:	ff 75 18             	push   0x18(%ebp)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	53                   	push   %ebx
  800279:	50                   	push   %eax
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	push   -0x1c(%ebp)
  800280:	ff 75 e0             	push   -0x20(%ebp)
  800283:	ff 75 dc             	push   -0x24(%ebp)
  800286:	ff 75 d8             	push   -0x28(%ebp)
  800289:	e8 22 0f 00 00       	call   8011b0 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9f ff ff ff       	call   80023b <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 13                	jmp    8002b4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	push   0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ad:	83 eb 01             	sub    $0x1,%ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7f ed                	jg     8002a1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	56                   	push   %esi
  8002b8:	83 ec 04             	sub    $0x4,%esp
  8002bb:	ff 75 e4             	push   -0x1c(%ebp)
  8002be:	ff 75 e0             	push   -0x20(%ebp)
  8002c1:	ff 75 dc             	push   -0x24(%ebp)
  8002c4:	ff 75 d8             	push   -0x28(%ebp)
  8002c7:	e8 04 10 00 00       	call   8012d0 <__umoddi3>
  8002cc:	83 c4 14             	add    $0x14,%esp
  8002cf:	0f be 80 49 14 80 00 	movsbl 0x801449(%eax),%eax
  8002d6:	50                   	push   %eax
  8002d7:	ff d7                	call   *%edi
}
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	5d                   	pop    %ebp
  8002e3:	c3                   	ret    

008002e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ea:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f3:	73 0a                	jae    8002ff <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f8:	89 08                	mov    %ecx,(%eax)
  8002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fd:	88 02                	mov    %al,(%edx)
}
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <printfmt>:
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800307:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030a:	50                   	push   %eax
  80030b:	ff 75 10             	push   0x10(%ebp)
  80030e:	ff 75 0c             	push   0xc(%ebp)
  800311:	ff 75 08             	push   0x8(%ebp)
  800314:	e8 05 00 00 00       	call   80031e <vprintfmt>
}
  800319:	83 c4 10             	add    $0x10,%esp
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <vprintfmt>:
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 3c             	sub    $0x3c,%esp
  800327:	8b 75 08             	mov    0x8(%ebp),%esi
  80032a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800330:	eb 0a                	jmp    80033c <vprintfmt+0x1e>
			putch(ch, putdat);
  800332:	83 ec 08             	sub    $0x8,%esp
  800335:	53                   	push   %ebx
  800336:	50                   	push   %eax
  800337:	ff d6                	call   *%esi
  800339:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033c:	83 c7 01             	add    $0x1,%edi
  80033f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800343:	83 f8 25             	cmp    $0x25,%eax
  800346:	74 0c                	je     800354 <vprintfmt+0x36>
			if (ch == '\0')
  800348:	85 c0                	test   %eax,%eax
  80034a:	75 e6                	jne    800332 <vprintfmt+0x14>
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    
		padc = ' ';
  800354:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800358:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80035f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800366:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80036d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8d 47 01             	lea    0x1(%edi),%eax
  800375:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800378:	0f b6 17             	movzbl (%edi),%edx
  80037b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80037e:	3c 55                	cmp    $0x55,%al
  800380:	0f 87 bb 03 00 00    	ja     800741 <vprintfmt+0x423>
  800386:	0f b6 c0             	movzbl %al,%eax
  800389:	ff 24 85 00 15 80 00 	jmp    *0x801500(,%eax,4)
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800393:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800397:	eb d9                	jmp    800372 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003a0:	eb d0                	jmp    800372 <vprintfmt+0x54>
  8003a2:	0f b6 d2             	movzbl %dl,%edx
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ad:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ba:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003bd:	83 f9 09             	cmp    $0x9,%ecx
  8003c0:	77 55                	ja     800417 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003c2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003c5:	eb e9                	jmp    8003b0 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 40 04             	lea    0x4(%eax),%eax
  8003d5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003df:	79 91                	jns    800372 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003ee:	eb 82                	jmp    800372 <vprintfmt+0x54>
  8003f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f3:	85 d2                	test   %edx,%edx
  8003f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fa:	0f 49 c2             	cmovns %edx,%eax
  8003fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800403:	e9 6a ff ff ff       	jmp    800372 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80040b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800412:	e9 5b ff ff ff       	jmp    800372 <vprintfmt+0x54>
  800417:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80041a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041d:	eb bc                	jmp    8003db <vprintfmt+0xbd>
			lflag++;
  80041f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800425:	e9 48 ff ff ff       	jmp    800372 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	8d 78 04             	lea    0x4(%eax),%edi
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	53                   	push   %ebx
  800434:	ff 30                	push   (%eax)
  800436:	ff d6                	call   *%esi
			break;
  800438:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80043b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80043e:	e9 9d 02 00 00       	jmp    8006e0 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 78 04             	lea    0x4(%eax),%edi
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	89 d0                	mov    %edx,%eax
  80044d:	f7 d8                	neg    %eax
  80044f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800452:	83 f8 08             	cmp    $0x8,%eax
  800455:	7f 23                	jg     80047a <vprintfmt+0x15c>
  800457:	8b 14 85 60 16 80 00 	mov    0x801660(,%eax,4),%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	74 18                	je     80047a <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800462:	52                   	push   %edx
  800463:	68 6a 14 80 00       	push   $0x80146a
  800468:	53                   	push   %ebx
  800469:	56                   	push   %esi
  80046a:	e8 92 fe ff ff       	call   800301 <printfmt>
  80046f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800472:	89 7d 14             	mov    %edi,0x14(%ebp)
  800475:	e9 66 02 00 00       	jmp    8006e0 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80047a:	50                   	push   %eax
  80047b:	68 61 14 80 00       	push   $0x801461
  800480:	53                   	push   %ebx
  800481:	56                   	push   %esi
  800482:	e8 7a fe ff ff       	call   800301 <printfmt>
  800487:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80048a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80048d:	e9 4e 02 00 00       	jmp    8006e0 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	83 c0 04             	add    $0x4,%eax
  800498:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004a0:	85 d2                	test   %edx,%edx
  8004a2:	b8 5a 14 80 00       	mov    $0x80145a,%eax
  8004a7:	0f 45 c2             	cmovne %edx,%eax
  8004aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b1:	7e 06                	jle    8004b9 <vprintfmt+0x19b>
  8004b3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004b7:	75 0d                	jne    8004c6 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004bc:	89 c7                	mov    %eax,%edi
  8004be:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	eb 55                	jmp    80051b <vprintfmt+0x1fd>
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 d8             	push   -0x28(%ebp)
  8004cc:	ff 75 cc             	push   -0x34(%ebp)
  8004cf:	e8 0a 03 00 00       	call   8007de <strnlen>
  8004d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d7:	29 c1                	sub    %eax,%ecx
  8004d9:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004e1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e8:	eb 0f                	jmp    8004f9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	ff 75 e0             	push   -0x20(%ebp)
  8004f1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	83 ef 01             	sub    $0x1,%edi
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	85 ff                	test   %edi,%edi
  8004fb:	7f ed                	jg     8004ea <vprintfmt+0x1cc>
  8004fd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800500:	85 d2                	test   %edx,%edx
  800502:	b8 00 00 00 00       	mov    $0x0,%eax
  800507:	0f 49 c2             	cmovns %edx,%eax
  80050a:	29 c2                	sub    %eax,%edx
  80050c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80050f:	eb a8                	jmp    8004b9 <vprintfmt+0x19b>
					putch(ch, putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	52                   	push   %edx
  800516:	ff d6                	call   *%esi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800520:	83 c7 01             	add    $0x1,%edi
  800523:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800527:	0f be d0             	movsbl %al,%edx
  80052a:	85 d2                	test   %edx,%edx
  80052c:	74 4b                	je     800579 <vprintfmt+0x25b>
  80052e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800532:	78 06                	js     80053a <vprintfmt+0x21c>
  800534:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800538:	78 1e                	js     800558 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80053a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053e:	74 d1                	je     800511 <vprintfmt+0x1f3>
  800540:	0f be c0             	movsbl %al,%eax
  800543:	83 e8 20             	sub    $0x20,%eax
  800546:	83 f8 5e             	cmp    $0x5e,%eax
  800549:	76 c6                	jbe    800511 <vprintfmt+0x1f3>
					putch('?', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 3f                	push   $0x3f
  800551:	ff d6                	call   *%esi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb c3                	jmp    80051b <vprintfmt+0x1fd>
  800558:	89 cf                	mov    %ecx,%edi
  80055a:	eb 0e                	jmp    80056a <vprintfmt+0x24c>
				putch(' ', putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	6a 20                	push   $0x20
  800562:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800564:	83 ef 01             	sub    $0x1,%edi
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	85 ff                	test   %edi,%edi
  80056c:	7f ee                	jg     80055c <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80056e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
  800574:	e9 67 01 00 00       	jmp    8006e0 <vprintfmt+0x3c2>
  800579:	89 cf                	mov    %ecx,%edi
  80057b:	eb ed                	jmp    80056a <vprintfmt+0x24c>
	if (lflag >= 2)
  80057d:	83 f9 01             	cmp    $0x1,%ecx
  800580:	7f 1b                	jg     80059d <vprintfmt+0x27f>
	else if (lflag)
  800582:	85 c9                	test   %ecx,%ecx
  800584:	74 63                	je     8005e9 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058e:	99                   	cltd   
  80058f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 40 04             	lea    0x4(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
  80059b:	eb 17                	jmp    8005b4 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8b 50 04             	mov    0x4(%eax),%edx
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 40 08             	lea    0x8(%eax),%eax
  8005b1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ba:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005bf:	85 c9                	test   %ecx,%ecx
  8005c1:	0f 89 ff 00 00 00    	jns    8006c6 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	53                   	push   %ebx
  8005cb:	6a 2d                	push   $0x2d
  8005cd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d5:	f7 da                	neg    %edx
  8005d7:	83 d1 00             	adc    $0x0,%ecx
  8005da:	f7 d9                	neg    %ecx
  8005dc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005df:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005e4:	e9 dd 00 00 00       	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	99                   	cltd   
  8005f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fe:	eb b4                	jmp    8005b4 <vprintfmt+0x296>
	if (lflag >= 2)
  800600:	83 f9 01             	cmp    $0x1,%ecx
  800603:	7f 1e                	jg     800623 <vprintfmt+0x305>
	else if (lflag)
  800605:	85 c9                	test   %ecx,%ecx
  800607:	74 32                	je     80063b <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 10                	mov    (%eax),%edx
  80060e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800613:	8d 40 04             	lea    0x4(%eax),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800619:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80061e:	e9 a3 00 00 00       	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	8b 48 04             	mov    0x4(%eax),%ecx
  80062b:	8d 40 08             	lea    0x8(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800631:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800636:	e9 8b 00 00 00       	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	b9 00 00 00 00       	mov    $0x0,%ecx
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800650:	eb 74                	jmp    8006c6 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800652:	83 f9 01             	cmp    $0x1,%ecx
  800655:	7f 1b                	jg     800672 <vprintfmt+0x354>
	else if (lflag)
  800657:	85 c9                	test   %ecx,%ecx
  800659:	74 2c                	je     800687 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	b9 00 00 00 00       	mov    $0x0,%ecx
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80066b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800670:	eb 54                	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 10                	mov    (%eax),%edx
  800677:	8b 48 04             	mov    0x4(%eax),%ecx
  80067a:	8d 40 08             	lea    0x8(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800680:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800685:	eb 3f                	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800691:	8d 40 04             	lea    0x4(%eax),%eax
  800694:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800697:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80069c:	eb 28                	jmp    8006c6 <vprintfmt+0x3a8>
			putch('0', putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 30                	push   $0x30
  8006a4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a6:	83 c4 08             	add    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 78                	push   $0x78
  8006ac:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 10                	mov    (%eax),%edx
  8006b3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c1:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006c6:	83 ec 0c             	sub    $0xc,%esp
  8006c9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006cd:	50                   	push   %eax
  8006ce:	ff 75 e0             	push   -0x20(%ebp)
  8006d1:	57                   	push   %edi
  8006d2:	51                   	push   %ecx
  8006d3:	52                   	push   %edx
  8006d4:	89 da                	mov    %ebx,%edx
  8006d6:	89 f0                	mov    %esi,%eax
  8006d8:	e8 5e fb ff ff       	call   80023b <printnum>
			break;
  8006dd:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e3:	e9 54 fc ff ff       	jmp    80033c <vprintfmt+0x1e>
	if (lflag >= 2)
  8006e8:	83 f9 01             	cmp    $0x1,%ecx
  8006eb:	7f 1b                	jg     800708 <vprintfmt+0x3ea>
	else if (lflag)
  8006ed:	85 c9                	test   %ecx,%ecx
  8006ef:	74 2c                	je     80071d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8b 10                	mov    (%eax),%edx
  8006f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800701:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800706:	eb be                	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	8b 48 04             	mov    0x4(%eax),%ecx
  800710:	8d 40 08             	lea    0x8(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800716:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80071b:	eb a9                	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800732:	eb 92                	jmp    8006c6 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 25                	push   $0x25
  80073a:	ff d6                	call   *%esi
			break;
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	eb 9f                	jmp    8006e0 <vprintfmt+0x3c2>
			putch('%', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	6a 25                	push   $0x25
  800747:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	89 f8                	mov    %edi,%eax
  80074e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800752:	74 05                	je     800759 <vprintfmt+0x43b>
  800754:	83 e8 01             	sub    $0x1,%eax
  800757:	eb f5                	jmp    80074e <vprintfmt+0x430>
  800759:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80075c:	eb 82                	jmp    8006e0 <vprintfmt+0x3c2>

0080075e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 18             	sub    $0x18,%esp
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800771:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077b:	85 c0                	test   %eax,%eax
  80077d:	74 26                	je     8007a5 <vsnprintf+0x47>
  80077f:	85 d2                	test   %edx,%edx
  800781:	7e 22                	jle    8007a5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	ff 75 14             	push   0x14(%ebp)
  800786:	ff 75 10             	push   0x10(%ebp)
  800789:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078c:	50                   	push   %eax
  80078d:	68 e4 02 80 00       	push   $0x8002e4
  800792:	e8 87 fb ff ff       	call   80031e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800797:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a0:	83 c4 10             	add    $0x10,%esp
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    
		return -E_INVAL;
  8007a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007aa:	eb f7                	jmp    8007a3 <vsnprintf+0x45>

008007ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b5:	50                   	push   %eax
  8007b6:	ff 75 10             	push   0x10(%ebp)
  8007b9:	ff 75 0c             	push   0xc(%ebp)
  8007bc:	ff 75 08             	push   0x8(%ebp)
  8007bf:	e8 9a ff ff ff       	call   80075e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	eb 03                	jmp    8007d6 <strlen+0x10>
		n++;
  8007d3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	75 f7                	jne    8007d3 <strlen+0xd>
	return n;
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 03                	jmp    8007f1 <strnlen+0x13>
		n++;
  8007ee:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f1:	39 d0                	cmp    %edx,%eax
  8007f3:	74 08                	je     8007fd <strnlen+0x1f>
  8007f5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f9:	75 f3                	jne    8007ee <strnlen+0x10>
  8007fb:	89 c2                	mov    %eax,%edx
	return n;
}
  8007fd:	89 d0                	mov    %edx,%eax
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	53                   	push   %ebx
  800805:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800808:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
  800810:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800814:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	84 d2                	test   %dl,%dl
  80081c:	75 f2                	jne    800810 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80081e:	89 c8                	mov    %ecx,%eax
  800820:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	83 ec 10             	sub    $0x10,%esp
  80082c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082f:	53                   	push   %ebx
  800830:	e8 91 ff ff ff       	call   8007c6 <strlen>
  800835:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800838:	ff 75 0c             	push   0xc(%ebp)
  80083b:	01 d8                	add    %ebx,%eax
  80083d:	50                   	push   %eax
  80083e:	e8 be ff ff ff       	call   800801 <strcpy>
	return dst;
}
  800843:	89 d8                	mov    %ebx,%eax
  800845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 75 08             	mov    0x8(%ebp),%esi
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	89 f3                	mov    %esi,%ebx
  800857:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085a:	89 f0                	mov    %esi,%eax
  80085c:	eb 0f                	jmp    80086d <strncpy+0x23>
		*dst++ = *src;
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	0f b6 0a             	movzbl (%edx),%ecx
  800864:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800867:	80 f9 01             	cmp    $0x1,%cl
  80086a:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80086d:	39 d8                	cmp    %ebx,%eax
  80086f:	75 ed                	jne    80085e <strncpy+0x14>
	}
	return ret;
}
  800871:	89 f0                	mov    %esi,%eax
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 75 08             	mov    0x8(%ebp),%esi
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800882:	8b 55 10             	mov    0x10(%ebp),%edx
  800885:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800887:	85 d2                	test   %edx,%edx
  800889:	74 21                	je     8008ac <strlcpy+0x35>
  80088b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088f:	89 f2                	mov    %esi,%edx
  800891:	eb 09                	jmp    80089c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800893:	83 c1 01             	add    $0x1,%ecx
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80089c:	39 c2                	cmp    %eax,%edx
  80089e:	74 09                	je     8008a9 <strlcpy+0x32>
  8008a0:	0f b6 19             	movzbl (%ecx),%ebx
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ec                	jne    800893 <strlcpy+0x1c>
  8008a7:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008a9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ac:	29 f0                	sub    %esi,%eax
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bb:	eb 06                	jmp    8008c3 <strcmp+0x11>
		p++, q++;
  8008bd:	83 c1 01             	add    $0x1,%ecx
  8008c0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008c3:	0f b6 01             	movzbl (%ecx),%eax
  8008c6:	84 c0                	test   %al,%al
  8008c8:	74 04                	je     8008ce <strcmp+0x1c>
  8008ca:	3a 02                	cmp    (%edx),%al
  8008cc:	74 ef                	je     8008bd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	0f b6 c0             	movzbl %al,%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e2:	89 c3                	mov    %eax,%ebx
  8008e4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e7:	eb 06                	jmp    8008ef <strncmp+0x17>
		n--, p++, q++;
  8008e9:	83 c0 01             	add    $0x1,%eax
  8008ec:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ef:	39 d8                	cmp    %ebx,%eax
  8008f1:	74 18                	je     80090b <strncmp+0x33>
  8008f3:	0f b6 08             	movzbl (%eax),%ecx
  8008f6:	84 c9                	test   %cl,%cl
  8008f8:	74 04                	je     8008fe <strncmp+0x26>
  8008fa:	3a 0a                	cmp    (%edx),%cl
  8008fc:	74 eb                	je     8008e9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fe:	0f b6 00             	movzbl (%eax),%eax
  800901:	0f b6 12             	movzbl (%edx),%edx
  800904:	29 d0                	sub    %edx,%eax
}
  800906:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800909:	c9                   	leave  
  80090a:	c3                   	ret    
		return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	eb f4                	jmp    800906 <strncmp+0x2e>

00800912 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091c:	eb 03                	jmp    800921 <strchr+0xf>
  80091e:	83 c0 01             	add    $0x1,%eax
  800921:	0f b6 10             	movzbl (%eax),%edx
  800924:	84 d2                	test   %dl,%dl
  800926:	74 06                	je     80092e <strchr+0x1c>
		if (*s == c)
  800928:	38 ca                	cmp    %cl,%dl
  80092a:	75 f2                	jne    80091e <strchr+0xc>
  80092c:	eb 05                	jmp    800933 <strchr+0x21>
			return (char *) s;
	return 0;
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800942:	38 ca                	cmp    %cl,%dl
  800944:	74 09                	je     80094f <strfind+0x1a>
  800946:	84 d2                	test   %dl,%dl
  800948:	74 05                	je     80094f <strfind+0x1a>
	for (; *s; s++)
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	eb f0                	jmp    80093f <strfind+0xa>
			break;
	return (char *) s;
}
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	57                   	push   %edi
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095d:	85 c9                	test   %ecx,%ecx
  80095f:	74 2f                	je     800990 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800961:	89 f8                	mov    %edi,%eax
  800963:	09 c8                	or     %ecx,%eax
  800965:	a8 03                	test   $0x3,%al
  800967:	75 21                	jne    80098a <memset+0x39>
		c &= 0xFF;
  800969:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d0                	mov    %edx,%eax
  80096f:	c1 e0 08             	shl    $0x8,%eax
  800972:	89 d3                	mov    %edx,%ebx
  800974:	c1 e3 18             	shl    $0x18,%ebx
  800977:	89 d6                	mov    %edx,%esi
  800979:	c1 e6 10             	shl    $0x10,%esi
  80097c:	09 f3                	or     %esi,%ebx
  80097e:	09 da                	or     %ebx,%edx
  800980:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800982:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800985:	fc                   	cld    
  800986:	f3 ab                	rep stos %eax,%es:(%edi)
  800988:	eb 06                	jmp    800990 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098d:	fc                   	cld    
  80098e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800990:	89 f8                	mov    %edi,%eax
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a5:	39 c6                	cmp    %eax,%esi
  8009a7:	73 32                	jae    8009db <memmove+0x44>
  8009a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ac:	39 c2                	cmp    %eax,%edx
  8009ae:	76 2b                	jbe    8009db <memmove+0x44>
		s += n;
		d += n;
  8009b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b3:	89 d6                	mov    %edx,%esi
  8009b5:	09 fe                	or     %edi,%esi
  8009b7:	09 ce                	or     %ecx,%esi
  8009b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bf:	75 0e                	jne    8009cf <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c1:	83 ef 04             	sub    $0x4,%edi
  8009c4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ca:	fd                   	std    
  8009cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cd:	eb 09                	jmp    8009d8 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cf:	83 ef 01             	sub    $0x1,%edi
  8009d2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009d5:	fd                   	std    
  8009d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d8:	fc                   	cld    
  8009d9:	eb 1a                	jmp    8009f5 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009db:	89 f2                	mov    %esi,%edx
  8009dd:	09 c2                	or     %eax,%edx
  8009df:	09 ca                	or     %ecx,%edx
  8009e1:	f6 c2 03             	test   $0x3,%dl
  8009e4:	75 0a                	jne    8009f0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ee:	eb 05                	jmp    8009f5 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009f0:	89 c7                	mov    %eax,%edi
  8009f2:	fc                   	cld    
  8009f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ff:	ff 75 10             	push   0x10(%ebp)
  800a02:	ff 75 0c             	push   0xc(%ebp)
  800a05:	ff 75 08             	push   0x8(%ebp)
  800a08:	e8 8a ff ff ff       	call   800997 <memmove>
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	89 c6                	mov    %eax,%esi
  800a1c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	eb 06                	jmp    800a27 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a27:	39 f0                	cmp    %esi,%eax
  800a29:	74 14                	je     800a3f <memcmp+0x30>
		if (*s1 != *s2)
  800a2b:	0f b6 08             	movzbl (%eax),%ecx
  800a2e:	0f b6 1a             	movzbl (%edx),%ebx
  800a31:	38 d9                	cmp    %bl,%cl
  800a33:	74 ec                	je     800a21 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c1             	movzbl %cl,%eax
  800a38:	0f b6 db             	movzbl %bl,%ebx
  800a3b:	29 d8                	sub    %ebx,%eax
  800a3d:	eb 05                	jmp    800a44 <memcmp+0x35>
	}

	return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a56:	eb 03                	jmp    800a5b <memfind+0x13>
  800a58:	83 c0 01             	add    $0x1,%eax
  800a5b:	39 d0                	cmp    %edx,%eax
  800a5d:	73 04                	jae    800a63 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5f:	38 08                	cmp    %cl,(%eax)
  800a61:	75 f5                	jne    800a58 <memfind+0x10>
			break;
	return (void *) s;
}
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a71:	eb 03                	jmp    800a76 <strtol+0x11>
		s++;
  800a73:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a76:	0f b6 02             	movzbl (%edx),%eax
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f6                	je     800a73 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f2                	je     800a73 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	74 2a                	je     800aaf <strtol+0x4a>
	int neg = 0;
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a8a:	3c 2d                	cmp    $0x2d,%al
  800a8c:	74 2b                	je     800ab9 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a94:	75 0f                	jne    800aa5 <strtol+0x40>
  800a96:	80 3a 30             	cmpb   $0x30,(%edx)
  800a99:	74 28                	je     800ac3 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aa2:	0f 44 d8             	cmove  %eax,%ebx
  800aa5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaa:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aad:	eb 46                	jmp    800af5 <strtol+0x90>
		s++;
  800aaf:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800ab2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab7:	eb d5                	jmp    800a8e <strtol+0x29>
		s++, neg = 1;
  800ab9:	83 c2 01             	add    $0x1,%edx
  800abc:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac1:	eb cb                	jmp    800a8e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac7:	74 0e                	je     800ad7 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ac9:	85 db                	test   %ebx,%ebx
  800acb:	75 d8                	jne    800aa5 <strtol+0x40>
		s++, base = 8;
  800acd:	83 c2 01             	add    $0x1,%edx
  800ad0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad5:	eb ce                	jmp    800aa5 <strtol+0x40>
		s += 2, base = 16;
  800ad7:	83 c2 02             	add    $0x2,%edx
  800ada:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adf:	eb c4                	jmp    800aa5 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ae1:	0f be c0             	movsbl %al,%eax
  800ae4:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae7:	3b 45 10             	cmp    0x10(%ebp),%eax
  800aea:	7d 3a                	jge    800b26 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800aec:	83 c2 01             	add    $0x1,%edx
  800aef:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800af3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800af5:	0f b6 02             	movzbl (%edx),%eax
  800af8:	8d 70 d0             	lea    -0x30(%eax),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 09             	cmp    $0x9,%bl
  800b00:	76 df                	jbe    800ae1 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b02:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b05:	89 f3                	mov    %esi,%ebx
  800b07:	80 fb 19             	cmp    $0x19,%bl
  800b0a:	77 08                	ja     800b14 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b0c:	0f be c0             	movsbl %al,%eax
  800b0f:	83 e8 57             	sub    $0x57,%eax
  800b12:	eb d3                	jmp    800ae7 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b14:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b17:	89 f3                	mov    %esi,%ebx
  800b19:	80 fb 19             	cmp    $0x19,%bl
  800b1c:	77 08                	ja     800b26 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b1e:	0f be c0             	movsbl %al,%eax
  800b21:	83 e8 37             	sub    $0x37,%eax
  800b24:	eb c1                	jmp    800ae7 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2a:	74 05                	je     800b31 <strtol+0xcc>
		*endptr = (char *) s;
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b31:	89 c8                	mov    %ecx,%eax
  800b33:	f7 d8                	neg    %eax
  800b35:	85 ff                	test   %edi,%edi
  800b37:	0f 45 c8             	cmovne %eax,%ecx
}
  800b3a:	89 c8                	mov    %ecx,%eax
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	89 c6                	mov    %eax,%esi
  800b58:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b94:	89 cb                	mov    %ecx,%ebx
  800b96:	89 cf                	mov    %ecx,%edi
  800b98:	89 ce                	mov    %ecx,%esi
  800b9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7f 08                	jg     800ba8 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	50                   	push   %eax
  800bac:	6a 03                	push   $0x3
  800bae:	68 84 16 80 00       	push   $0x801684
  800bb3:	6a 2a                	push   $0x2a
  800bb5:	68 a1 16 80 00       	push   $0x8016a1
  800bba:	e8 8d f5 ff ff       	call   80014c <_panic>

00800bbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_yield>:

void
sys_yield(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c06:	be 00 00 00 00       	mov    $0x0,%esi
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	b8 04 00 00 00       	mov    $0x4,%eax
  800c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c19:	89 f7                	mov    %esi,%edi
  800c1b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7f 08                	jg     800c29 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 04                	push   $0x4
  800c2f:	68 84 16 80 00       	push   $0x801684
  800c34:	6a 2a                	push   $0x2a
  800c36:	68 a1 16 80 00       	push   $0x8016a1
  800c3b:	e8 0c f5 ff ff       	call   80014c <_panic>

00800c40 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7f 08                	jg     800c6b <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 05                	push   $0x5
  800c71:	68 84 16 80 00       	push   $0x801684
  800c76:	6a 2a                	push   $0x2a
  800c78:	68 a1 16 80 00       	push   $0x8016a1
  800c7d:	e8 ca f4 ff ff       	call   80014c <_panic>

00800c82 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7f 08                	jg     800cad <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 06                	push   $0x6
  800cb3:	68 84 16 80 00       	push   $0x801684
  800cb8:	6a 2a                	push   $0x2a
  800cba:	68 a1 16 80 00       	push   $0x8016a1
  800cbf:	e8 88 f4 ff ff       	call   80014c <_panic>

00800cc4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7f 08                	jg     800cef <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 08                	push   $0x8
  800cf5:	68 84 16 80 00       	push   $0x801684
  800cfa:	6a 2a                	push   $0x2a
  800cfc:	68 a1 16 80 00       	push   $0x8016a1
  800d01:	e8 46 f4 ff ff       	call   80014c <_panic>

00800d06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7f 08                	jg     800d31 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 09                	push   $0x9
  800d37:	68 84 16 80 00       	push   $0x801684
  800d3c:	6a 2a                	push   $0x2a
  800d3e:	68 a1 16 80 00       	push   $0x8016a1
  800d43:	e8 04 f4 ff ff       	call   80014c <_panic>

00800d48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d59:	be 00 00 00 00       	mov    $0x0,%esi
  800d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d64:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7f 08                	jg     800d95 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 0c                	push   $0xc
  800d9b:	68 84 16 80 00       	push   $0x801684
  800da0:	6a 2a                	push   $0x2a
  800da2:	68 a1 16 80 00       	push   $0x8016a1
  800da7:	e8 a0 f3 ff ff       	call   80014c <_panic>

00800dac <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db4:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800db6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dba:	0f 84 8e 00 00 00    	je     800e4e <pgfault+0xa2>
  800dc0:	89 f0                	mov    %esi,%eax
  800dc2:	c1 e8 0c             	shr    $0xc,%eax
  800dc5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dcc:	f6 c4 08             	test   $0x8,%ah
  800dcf:	74 7d                	je     800e4e <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800dd1:	e8 e9 fd ff ff       	call   800bbf <sys_getenvid>
  800dd6:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800dd8:	83 ec 04             	sub    $0x4,%esp
  800ddb:	6a 07                	push   $0x7
  800ddd:	68 00 f0 7f 00       	push   $0x7ff000
  800de2:	50                   	push   %eax
  800de3:	e8 15 fe ff ff       	call   800bfd <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	78 73                	js     800e62 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800def:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800df5:	83 ec 04             	sub    $0x4,%esp
  800df8:	68 00 10 00 00       	push   $0x1000
  800dfd:	56                   	push   %esi
  800dfe:	68 00 f0 7f 00       	push   $0x7ff000
  800e03:	e8 8f fb ff ff       	call   800997 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e08:	83 c4 08             	add    $0x8,%esp
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	e8 70 fe ff ff       	call   800c82 <sys_page_unmap>
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	85 c0                	test   %eax,%eax
  800e17:	78 5b                	js     800e74 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	6a 07                	push   $0x7
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	68 00 f0 7f 00       	push   $0x7ff000
  800e25:	53                   	push   %ebx
  800e26:	e8 15 fe ff ff       	call   800c40 <sys_page_map>
  800e2b:	83 c4 20             	add    $0x20,%esp
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	78 54                	js     800e86 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e32:	83 ec 08             	sub    $0x8,%esp
  800e35:	68 00 f0 7f 00       	push   $0x7ff000
  800e3a:	53                   	push   %ebx
  800e3b:	e8 42 fe ff ff       	call   800c82 <sys_page_unmap>
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	78 51                	js     800e98 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e4e:	83 ec 04             	sub    $0x4,%esp
  800e51:	68 b0 16 80 00       	push   $0x8016b0
  800e56:	6a 1d                	push   $0x1d
  800e58:	68 2c 17 80 00       	push   $0x80172c
  800e5d:	e8 ea f2 ff ff       	call   80014c <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e62:	50                   	push   %eax
  800e63:	68 e8 16 80 00       	push   $0x8016e8
  800e68:	6a 29                	push   $0x29
  800e6a:	68 2c 17 80 00       	push   $0x80172c
  800e6f:	e8 d8 f2 ff ff       	call   80014c <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e74:	50                   	push   %eax
  800e75:	68 0c 17 80 00       	push   $0x80170c
  800e7a:	6a 2e                	push   $0x2e
  800e7c:	68 2c 17 80 00       	push   $0x80172c
  800e81:	e8 c6 f2 ff ff       	call   80014c <_panic>
		panic("pgfault: page map failed (%e)", r);
  800e86:	50                   	push   %eax
  800e87:	68 37 17 80 00       	push   $0x801737
  800e8c:	6a 30                	push   $0x30
  800e8e:	68 2c 17 80 00       	push   $0x80172c
  800e93:	e8 b4 f2 ff ff       	call   80014c <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e98:	50                   	push   %eax
  800e99:	68 0c 17 80 00       	push   $0x80170c
  800e9e:	6a 32                	push   $0x32
  800ea0:	68 2c 17 80 00       	push   $0x80172c
  800ea5:	e8 a2 f2 ff ff       	call   80014c <_panic>

00800eaa <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800eb3:	68 ac 0d 80 00       	push   $0x800dac
  800eb8:	e8 4f 02 00 00       	call   80110c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ebd:	b8 07 00 00 00       	mov    $0x7,%eax
  800ec2:	cd 30                	int    $0x30
  800ec4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800ec7:	83 c4 10             	add    $0x10,%esp
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	78 2a                	js     800ef8 <fork+0x4e>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800ece:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800ed3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ed7:	75 5e                	jne    800f37 <fork+0x8d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ed9:	e8 e1 fc ff ff       	call   800bbf <sys_getenvid>
  800ede:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ee3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eeb:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ef3:	e9 b0 00 00 00       	jmp    800fa8 <fork+0xfe>
		panic("sys_exofork: %e", envid);
  800ef8:	50                   	push   %eax
  800ef9:	68 55 17 80 00       	push   $0x801755
  800efe:	6a 75                	push   $0x75
  800f00:	68 2c 17 80 00       	push   $0x80172c
  800f05:	e8 42 f2 ff ff       	call   80014c <_panic>
	r=sys_page_map(this_envid, va, this_envid, va, perm);//一定要用系统调用， 因为权限！！
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	56                   	push   %esi
  800f0e:	57                   	push   %edi
  800f0f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800f12:	51                   	push   %ecx
  800f13:	57                   	push   %edi
  800f14:	51                   	push   %ecx
  800f15:	e8 26 fd ff ff       	call   800c40 <sys_page_map>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
		    // dup page to child
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f1a:	83 c4 20             	add    $0x20,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	0f 88 8b 00 00 00    	js     800fb0 <fork+0x106>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f25:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f2b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f31:	0f 84 83 00 00 00    	je     800fba <fork+0x110>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	c1 e8 16             	shr    $0x16,%eax
  800f3c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f43:	a8 01                	test   $0x1,%al
  800f45:	74 de                	je     800f25 <fork+0x7b>
  800f47:	89 de                	mov    %ebx,%esi
  800f49:	c1 ee 0c             	shr    $0xc,%esi
  800f4c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f53:	a8 01                	test   $0x1,%al
  800f55:	74 ce                	je     800f25 <fork+0x7b>
	envid_t this_envid = sys_getenvid();//父进程号
  800f57:	e8 63 fc ff ff       	call   800bbf <sys_getenvid>
  800f5c:	89 c1                	mov    %eax,%ecx
	void * va = (void *)(pn * PGSIZE);
  800f5e:	89 f7                	mov    %esi,%edi
  800f60:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & 0xFFF;
  800f63:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
		perm &= ~PTE_W;
  800f6a:	89 d0                	mov    %edx,%eax
  800f6c:	25 fd 0f 00 00       	and    $0xffd,%eax
  800f71:	80 cc 08             	or     $0x8,%ah
  800f74:	89 d6                	mov    %edx,%esi
  800f76:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
  800f7c:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f82:	0f 45 f0             	cmovne %eax,%esi
	perm&=PTE_SYSCALL; // 写sys_page_map函数时 perm必须要达成的要求
  800f85:	81 e6 07 0e 00 00    	and    $0xe07,%esi
	r=sys_page_map(this_envid, va, envid, va, perm);
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	56                   	push   %esi
  800f8f:	57                   	push   %edi
  800f90:	ff 75 e0             	push   -0x20(%ebp)
  800f93:	57                   	push   %edi
  800f94:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800f97:	51                   	push   %ecx
  800f98:	e8 a3 fc ff ff       	call   800c40 <sys_page_map>
	if(r<0) return r;
  800f9d:	83 c4 20             	add    $0x20,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	0f 89 62 ff ff ff    	jns    800f0a <fork+0x60>
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800fa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    
  800fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb5:	0f 4f c2             	cmovg  %edx,%eax
  800fb8:	eb ee                	jmp    800fa8 <fork+0xfe>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800fba:	83 ec 04             	sub    $0x4,%esp
  800fbd:	6a 07                	push   $0x7
  800fbf:	68 00 f0 bf ee       	push   $0xeebff000
  800fc4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800fc7:	57                   	push   %edi
  800fc8:	e8 30 fc ff ff       	call   800bfd <sys_page_alloc>
	if(r<0) return r;
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 d4                	js     800fa8 <fork+0xfe>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fd4:	83 ec 08             	sub    $0x8,%esp
  800fd7:	68 82 11 80 00       	push   $0x801182
  800fdc:	57                   	push   %edi
  800fdd:	e8 24 fd ff ff       	call   800d06 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 bf                	js     800fa8 <fork+0xfe>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fe9:	83 ec 08             	sub    $0x8,%esp
  800fec:	6a 02                	push   $0x2
  800fee:	57                   	push   %edi
  800fef:	e8 d0 fc ff ff       	call   800cc4 <sys_env_set_status>
	if(r<0) return r;
  800ff4:	83 c4 10             	add    $0x10,%esp
	return envid;
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	0f 49 c7             	cmovns %edi,%eax
  800ffc:	eb aa                	jmp    800fa8 <fork+0xfe>

00800ffe <sfork>:

// Challenge!
int
sfork(void)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801004:	68 65 17 80 00       	push   $0x801765
  801009:	68 9e 00 00 00       	push   $0x9e
  80100e:	68 2c 17 80 00       	push   $0x80172c
  801013:	e8 34 f1 ff ff       	call   80014c <_panic>

00801018 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
  80101d:	8b 75 08             	mov    0x8(%ebp),%esi
  801020:	8b 45 0c             	mov    0xc(%ebp),%eax
  801023:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801026:	85 c0                	test   %eax,%eax
  801028:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80102d:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	50                   	push   %eax
  801034:	e8 32 fd ff ff       	call   800d6b <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	85 f6                	test   %esi,%esi
  80103e:	74 14                	je     801054 <ipc_recv+0x3c>
  801040:	ba 00 00 00 00       	mov    $0x0,%edx
  801045:	85 c0                	test   %eax,%eax
  801047:	78 09                	js     801052 <ipc_recv+0x3a>
  801049:	8b 15 04 20 80 00    	mov    0x802004,%edx
  80104f:	8b 52 74             	mov    0x74(%edx),%edx
  801052:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801054:	85 db                	test   %ebx,%ebx
  801056:	74 14                	je     80106c <ipc_recv+0x54>
  801058:	ba 00 00 00 00       	mov    $0x0,%edx
  80105d:	85 c0                	test   %eax,%eax
  80105f:	78 09                	js     80106a <ipc_recv+0x52>
  801061:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801067:	8b 52 78             	mov    0x78(%edx),%edx
  80106a:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80106c:	85 c0                	test   %eax,%eax
  80106e:	78 08                	js     801078 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801070:	a1 04 20 80 00       	mov    0x802004,%eax
  801075:	8b 40 70             	mov    0x70(%eax),%eax
}
  801078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    

0080107f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	57                   	push   %edi
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80108e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801091:	85 db                	test   %ebx,%ebx
  801093:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801098:	0f 44 d8             	cmove  %eax,%ebx
  80109b:	eb 05                	jmp    8010a2 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80109d:	e8 3c fb ff ff       	call   800bde <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8010a2:	ff 75 14             	push   0x14(%ebp)
  8010a5:	53                   	push   %ebx
  8010a6:	56                   	push   %esi
  8010a7:	57                   	push   %edi
  8010a8:	e8 9b fc ff ff       	call   800d48 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010b3:	74 e8                	je     80109d <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	78 08                	js     8010c1 <ipc_send+0x42>
	}while (r<0);

}
  8010b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8010c1:	50                   	push   %eax
  8010c2:	68 7b 17 80 00       	push   $0x80177b
  8010c7:	6a 3d                	push   $0x3d
  8010c9:	68 8f 17 80 00       	push   $0x80178f
  8010ce:	e8 79 f0 ff ff       	call   80014c <_panic>

008010d3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010d9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010de:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010e1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010e7:	8b 52 50             	mov    0x50(%edx),%edx
  8010ea:	39 ca                	cmp    %ecx,%edx
  8010ec:	74 11                	je     8010ff <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8010ee:	83 c0 01             	add    $0x1,%eax
  8010f1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010f6:	75 e6                	jne    8010de <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8010f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fd:	eb 0b                	jmp    80110a <ipc_find_env+0x37>
			return envs[i].env_id;
  8010ff:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801102:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801107:	8b 40 48             	mov    0x48(%eax),%eax
}
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801112:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801119:	74 0a                	je     801125 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801123:	c9                   	leave  
  801124:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801125:	e8 95 fa ff ff       	call   800bbf <sys_getenvid>
  80112a:	83 ec 04             	sub    $0x4,%esp
  80112d:	68 07 0e 00 00       	push   $0xe07
  801132:	68 00 f0 bf ee       	push   $0xeebff000
  801137:	50                   	push   %eax
  801138:	e8 c0 fa ff ff       	call   800bfd <sys_page_alloc>
		if (r < 0) {
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	78 2c                	js     801170 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801144:	e8 76 fa ff ff       	call   800bbf <sys_getenvid>
  801149:	83 ec 08             	sub    $0x8,%esp
  80114c:	68 82 11 80 00       	push   $0x801182
  801151:	50                   	push   %eax
  801152:	e8 af fb ff ff       	call   800d06 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	85 c0                	test   %eax,%eax
  80115c:	79 bd                	jns    80111b <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80115e:	50                   	push   %eax
  80115f:	68 dc 17 80 00       	push   $0x8017dc
  801164:	6a 28                	push   $0x28
  801166:	68 12 18 80 00       	push   $0x801812
  80116b:	e8 dc ef ff ff       	call   80014c <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801170:	50                   	push   %eax
  801171:	68 9c 17 80 00       	push   $0x80179c
  801176:	6a 23                	push   $0x23
  801178:	68 12 18 80 00       	push   $0x801812
  80117d:	e8 ca ef ff ff       	call   80014c <_panic>

00801182 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801182:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801183:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801188:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80118a:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80118d:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801191:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801194:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801198:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80119c:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80119e:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8011a1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8011a2:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8011a5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8011a6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8011a7:	c3                   	ret    
  8011a8:	66 90                	xchg   %ax,%ax
  8011aa:	66 90                	xchg   %ax,%ax
  8011ac:	66 90                	xchg   %ax,%ax
  8011ae:	66 90                	xchg   %ax,%ax

008011b0 <__udivdi3>:
  8011b0:	f3 0f 1e fb          	endbr32 
  8011b4:	55                   	push   %ebp
  8011b5:	57                   	push   %edi
  8011b6:	56                   	push   %esi
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 1c             	sub    $0x1c,%esp
  8011bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8011bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8011c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	75 19                	jne    8011e8 <__udivdi3+0x38>
  8011cf:	39 f3                	cmp    %esi,%ebx
  8011d1:	76 4d                	jbe    801220 <__udivdi3+0x70>
  8011d3:	31 ff                	xor    %edi,%edi
  8011d5:	89 e8                	mov    %ebp,%eax
  8011d7:	89 f2                	mov    %esi,%edx
  8011d9:	f7 f3                	div    %ebx
  8011db:	89 fa                	mov    %edi,%edx
  8011dd:	83 c4 1c             	add    $0x1c,%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    
  8011e5:	8d 76 00             	lea    0x0(%esi),%esi
  8011e8:	39 f0                	cmp    %esi,%eax
  8011ea:	76 14                	jbe    801200 <__udivdi3+0x50>
  8011ec:	31 ff                	xor    %edi,%edi
  8011ee:	31 c0                	xor    %eax,%eax
  8011f0:	89 fa                	mov    %edi,%edx
  8011f2:	83 c4 1c             	add    $0x1c,%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    
  8011fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801200:	0f bd f8             	bsr    %eax,%edi
  801203:	83 f7 1f             	xor    $0x1f,%edi
  801206:	75 48                	jne    801250 <__udivdi3+0xa0>
  801208:	39 f0                	cmp    %esi,%eax
  80120a:	72 06                	jb     801212 <__udivdi3+0x62>
  80120c:	31 c0                	xor    %eax,%eax
  80120e:	39 eb                	cmp    %ebp,%ebx
  801210:	77 de                	ja     8011f0 <__udivdi3+0x40>
  801212:	b8 01 00 00 00       	mov    $0x1,%eax
  801217:	eb d7                	jmp    8011f0 <__udivdi3+0x40>
  801219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801220:	89 d9                	mov    %ebx,%ecx
  801222:	85 db                	test   %ebx,%ebx
  801224:	75 0b                	jne    801231 <__udivdi3+0x81>
  801226:	b8 01 00 00 00       	mov    $0x1,%eax
  80122b:	31 d2                	xor    %edx,%edx
  80122d:	f7 f3                	div    %ebx
  80122f:	89 c1                	mov    %eax,%ecx
  801231:	31 d2                	xor    %edx,%edx
  801233:	89 f0                	mov    %esi,%eax
  801235:	f7 f1                	div    %ecx
  801237:	89 c6                	mov    %eax,%esi
  801239:	89 e8                	mov    %ebp,%eax
  80123b:	89 f7                	mov    %esi,%edi
  80123d:	f7 f1                	div    %ecx
  80123f:	89 fa                	mov    %edi,%edx
  801241:	83 c4 1c             	add    $0x1c,%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    
  801249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801250:	89 f9                	mov    %edi,%ecx
  801252:	ba 20 00 00 00       	mov    $0x20,%edx
  801257:	29 fa                	sub    %edi,%edx
  801259:	d3 e0                	shl    %cl,%eax
  80125b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80125f:	89 d1                	mov    %edx,%ecx
  801261:	89 d8                	mov    %ebx,%eax
  801263:	d3 e8                	shr    %cl,%eax
  801265:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801269:	09 c1                	or     %eax,%ecx
  80126b:	89 f0                	mov    %esi,%eax
  80126d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801271:	89 f9                	mov    %edi,%ecx
  801273:	d3 e3                	shl    %cl,%ebx
  801275:	89 d1                	mov    %edx,%ecx
  801277:	d3 e8                	shr    %cl,%eax
  801279:	89 f9                	mov    %edi,%ecx
  80127b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80127f:	89 eb                	mov    %ebp,%ebx
  801281:	d3 e6                	shl    %cl,%esi
  801283:	89 d1                	mov    %edx,%ecx
  801285:	d3 eb                	shr    %cl,%ebx
  801287:	09 f3                	or     %esi,%ebx
  801289:	89 c6                	mov    %eax,%esi
  80128b:	89 f2                	mov    %esi,%edx
  80128d:	89 d8                	mov    %ebx,%eax
  80128f:	f7 74 24 08          	divl   0x8(%esp)
  801293:	89 d6                	mov    %edx,%esi
  801295:	89 c3                	mov    %eax,%ebx
  801297:	f7 64 24 0c          	mull   0xc(%esp)
  80129b:	39 d6                	cmp    %edx,%esi
  80129d:	72 19                	jb     8012b8 <__udivdi3+0x108>
  80129f:	89 f9                	mov    %edi,%ecx
  8012a1:	d3 e5                	shl    %cl,%ebp
  8012a3:	39 c5                	cmp    %eax,%ebp
  8012a5:	73 04                	jae    8012ab <__udivdi3+0xfb>
  8012a7:	39 d6                	cmp    %edx,%esi
  8012a9:	74 0d                	je     8012b8 <__udivdi3+0x108>
  8012ab:	89 d8                	mov    %ebx,%eax
  8012ad:	31 ff                	xor    %edi,%edi
  8012af:	e9 3c ff ff ff       	jmp    8011f0 <__udivdi3+0x40>
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8012bb:	31 ff                	xor    %edi,%edi
  8012bd:	e9 2e ff ff ff       	jmp    8011f0 <__udivdi3+0x40>
  8012c2:	66 90                	xchg   %ax,%ax
  8012c4:	66 90                	xchg   %ax,%ax
  8012c6:	66 90                	xchg   %ax,%ax
  8012c8:	66 90                	xchg   %ax,%ax
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__umoddi3>:
  8012d0:	f3 0f 1e fb          	endbr32 
  8012d4:	55                   	push   %ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 1c             	sub    $0x1c,%esp
  8012db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8012df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8012e3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8012e7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8012eb:	89 f0                	mov    %esi,%eax
  8012ed:	89 da                	mov    %ebx,%edx
  8012ef:	85 ff                	test   %edi,%edi
  8012f1:	75 15                	jne    801308 <__umoddi3+0x38>
  8012f3:	39 dd                	cmp    %ebx,%ebp
  8012f5:	76 39                	jbe    801330 <__umoddi3+0x60>
  8012f7:	f7 f5                	div    %ebp
  8012f9:	89 d0                	mov    %edx,%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	83 c4 1c             	add    $0x1c,%esp
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    
  801305:	8d 76 00             	lea    0x0(%esi),%esi
  801308:	39 df                	cmp    %ebx,%edi
  80130a:	77 f1                	ja     8012fd <__umoddi3+0x2d>
  80130c:	0f bd cf             	bsr    %edi,%ecx
  80130f:	83 f1 1f             	xor    $0x1f,%ecx
  801312:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801316:	75 40                	jne    801358 <__umoddi3+0x88>
  801318:	39 df                	cmp    %ebx,%edi
  80131a:	72 04                	jb     801320 <__umoddi3+0x50>
  80131c:	39 f5                	cmp    %esi,%ebp
  80131e:	77 dd                	ja     8012fd <__umoddi3+0x2d>
  801320:	89 da                	mov    %ebx,%edx
  801322:	89 f0                	mov    %esi,%eax
  801324:	29 e8                	sub    %ebp,%eax
  801326:	19 fa                	sbb    %edi,%edx
  801328:	eb d3                	jmp    8012fd <__umoddi3+0x2d>
  80132a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801330:	89 e9                	mov    %ebp,%ecx
  801332:	85 ed                	test   %ebp,%ebp
  801334:	75 0b                	jne    801341 <__umoddi3+0x71>
  801336:	b8 01 00 00 00       	mov    $0x1,%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	f7 f5                	div    %ebp
  80133f:	89 c1                	mov    %eax,%ecx
  801341:	89 d8                	mov    %ebx,%eax
  801343:	31 d2                	xor    %edx,%edx
  801345:	f7 f1                	div    %ecx
  801347:	89 f0                	mov    %esi,%eax
  801349:	f7 f1                	div    %ecx
  80134b:	89 d0                	mov    %edx,%eax
  80134d:	31 d2                	xor    %edx,%edx
  80134f:	eb ac                	jmp    8012fd <__umoddi3+0x2d>
  801351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801358:	8b 44 24 04          	mov    0x4(%esp),%eax
  80135c:	ba 20 00 00 00       	mov    $0x20,%edx
  801361:	29 c2                	sub    %eax,%edx
  801363:	89 c1                	mov    %eax,%ecx
  801365:	89 e8                	mov    %ebp,%eax
  801367:	d3 e7                	shl    %cl,%edi
  801369:	89 d1                	mov    %edx,%ecx
  80136b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80136f:	d3 e8                	shr    %cl,%eax
  801371:	89 c1                	mov    %eax,%ecx
  801373:	8b 44 24 04          	mov    0x4(%esp),%eax
  801377:	09 f9                	or     %edi,%ecx
  801379:	89 df                	mov    %ebx,%edi
  80137b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80137f:	89 c1                	mov    %eax,%ecx
  801381:	d3 e5                	shl    %cl,%ebp
  801383:	89 d1                	mov    %edx,%ecx
  801385:	d3 ef                	shr    %cl,%edi
  801387:	89 c1                	mov    %eax,%ecx
  801389:	89 f0                	mov    %esi,%eax
  80138b:	d3 e3                	shl    %cl,%ebx
  80138d:	89 d1                	mov    %edx,%ecx
  80138f:	89 fa                	mov    %edi,%edx
  801391:	d3 e8                	shr    %cl,%eax
  801393:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801398:	09 d8                	or     %ebx,%eax
  80139a:	f7 74 24 08          	divl   0x8(%esp)
  80139e:	89 d3                	mov    %edx,%ebx
  8013a0:	d3 e6                	shl    %cl,%esi
  8013a2:	f7 e5                	mul    %ebp
  8013a4:	89 c7                	mov    %eax,%edi
  8013a6:	89 d1                	mov    %edx,%ecx
  8013a8:	39 d3                	cmp    %edx,%ebx
  8013aa:	72 06                	jb     8013b2 <__umoddi3+0xe2>
  8013ac:	75 0e                	jne    8013bc <__umoddi3+0xec>
  8013ae:	39 c6                	cmp    %eax,%esi
  8013b0:	73 0a                	jae    8013bc <__umoddi3+0xec>
  8013b2:	29 e8                	sub    %ebp,%eax
  8013b4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8013b8:	89 d1                	mov    %edx,%ecx
  8013ba:	89 c7                	mov    %eax,%edi
  8013bc:	89 f5                	mov    %esi,%ebp
  8013be:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013c2:	29 fd                	sub    %edi,%ebp
  8013c4:	19 cb                	sbb    %ecx,%ebx
  8013c6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8013cb:	89 d8                	mov    %ebx,%eax
  8013cd:	d3 e0                	shl    %cl,%eax
  8013cf:	89 f1                	mov    %esi,%ecx
  8013d1:	d3 ed                	shr    %cl,%ebp
  8013d3:	d3 eb                	shr    %cl,%ebx
  8013d5:	09 e8                	or     %ebp,%eax
  8013d7:	89 da                	mov    %ebx,%edx
  8013d9:	83 c4 1c             	add    $0x1c,%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5f                   	pop    %edi
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    
