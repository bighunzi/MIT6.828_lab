
obj/user/testpteshare.debug：     文件格式 elf32-i386


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
  80002c:	e8 63 01 00 00       	call   800194 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	push   0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 60 08 00 00       	call   8008a9 <strcpy>
	exit();
  800049:	e8 8c 01 00 00       	call   8001da <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	0f 85 d0 00 00 00    	jne    800134 <umain+0xe1>
	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800064:	83 ec 04             	sub    $0x4,%esp
  800067:	68 07 04 00 00       	push   $0x407
  80006c:	68 00 00 00 a0       	push   $0xa0000000
  800071:	6a 00                	push   $0x0
  800073:	e8 2d 0c 00 00       	call   800ca5 <sys_page_alloc>
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	85 c0                	test   %eax,%eax
  80007d:	0f 88 bb 00 00 00    	js     80013e <umain+0xeb>
	if ((r = fork()) < 0)
  800083:	e8 6d 0f 00 00       	call   800ff5 <fork>
  800088:	89 c3                	mov    %eax,%ebx
  80008a:	85 c0                	test   %eax,%eax
  80008c:	0f 88 be 00 00 00    	js     800150 <umain+0xfd>
	if (r == 0) {
  800092:	0f 84 ca 00 00 00    	je     800162 <umain+0x10f>
	wait(r);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	53                   	push   %ebx
  80009c:	e8 80 26 00 00       	call   802721 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	ff 35 04 40 80 00    	push   0x804004
  8000aa:	68 00 00 00 a0       	push   $0xa0000000
  8000af:	e8 a6 08 00 00       	call   80095a <strcmp>
  8000b4:	83 c4 08             	add    $0x8,%esp
  8000b7:	85 c0                	test   %eax,%eax
  8000b9:	b8 00 2d 80 00       	mov    $0x802d00,%eax
  8000be:	ba 06 2d 80 00       	mov    $0x802d06,%edx
  8000c3:	0f 45 c2             	cmovne %edx,%eax
  8000c6:	50                   	push   %eax
  8000c7:	68 33 2d 80 00       	push   $0x802d33
  8000cc:	e8 fe 01 00 00       	call   8002cf <cprintf>
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  8000d1:	6a 00                	push   $0x0
  8000d3:	68 4e 2d 80 00       	push   $0x802d4e
  8000d8:	68 53 2d 80 00       	push   $0x802d53
  8000dd:	68 52 2d 80 00       	push   $0x802d52
  8000e2:	e8 e3 1d 00 00       	call   801eca <spawnl>
  8000e7:	83 c4 20             	add    $0x20,%esp
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	0f 88 90 00 00 00    	js     800182 <umain+0x12f>
	wait(r);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	e8 26 26 00 00       	call   802721 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  8000fb:	83 c4 08             	add    $0x8,%esp
  8000fe:	ff 35 00 40 80 00    	push   0x804000
  800104:	68 00 00 00 a0       	push   $0xa0000000
  800109:	e8 4c 08 00 00       	call   80095a <strcmp>
  80010e:	83 c4 08             	add    $0x8,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	b8 00 2d 80 00       	mov    $0x802d00,%eax
  800118:	ba 06 2d 80 00       	mov    $0x802d06,%edx
  80011d:	0f 45 c2             	cmovne %edx,%eax
  800120:	50                   	push   %eax
  800121:	68 6a 2d 80 00       	push   $0x802d6a
  800126:	e8 a4 01 00 00       	call   8002cf <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80012b:	cc                   	int3   
}
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800132:	c9                   	leave  
  800133:	c3                   	ret    
		childofspawn();
  800134:	e8 fa fe ff ff       	call   800033 <childofspawn>
  800139:	e9 26 ff ff ff       	jmp    800064 <umain+0x11>
		panic("sys_page_alloc: %e", r);
  80013e:	50                   	push   %eax
  80013f:	68 0c 2d 80 00       	push   $0x802d0c
  800144:	6a 13                	push   $0x13
  800146:	68 1f 2d 80 00       	push   $0x802d1f
  80014b:	e8 a4 00 00 00       	call   8001f4 <_panic>
		panic("fork: %e", r);
  800150:	50                   	push   %eax
  800151:	68 b8 31 80 00       	push   $0x8031b8
  800156:	6a 17                	push   $0x17
  800158:	68 1f 2d 80 00       	push   $0x802d1f
  80015d:	e8 92 00 00 00       	call   8001f4 <_panic>
		strcpy(VA, msg);
  800162:	83 ec 08             	sub    $0x8,%esp
  800165:	ff 35 04 40 80 00    	push   0x804004
  80016b:	68 00 00 00 a0       	push   $0xa0000000
  800170:	e8 34 07 00 00       	call   8008a9 <strcpy>
		exit();
  800175:	e8 60 00 00 00       	call   8001da <exit>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	e9 16 ff ff ff       	jmp    800098 <umain+0x45>
		panic("spawn: %e", r);
  800182:	50                   	push   %eax
  800183:	68 60 2d 80 00       	push   $0x802d60
  800188:	6a 21                	push   $0x21
  80018a:	68 1f 2d 80 00       	push   $0x802d1f
  80018f:	e8 60 00 00 00       	call   8001f4 <_panic>

00800194 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
  800199:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80019c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80019f:	e8 c3 0a 00 00       	call   800c67 <sys_getenvid>
  8001a4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001a9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b1:	a3 00 50 80 00       	mov    %eax,0x805000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001b6:	85 db                	test   %ebx,%ebx
  8001b8:	7e 07                	jle    8001c1 <libmain+0x2d>
		binaryname = argv[0];
  8001ba:	8b 06                	mov    (%esi),%eax
  8001bc:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001c1:	83 ec 08             	sub    $0x8,%esp
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	e8 88 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001cb:	e8 0a 00 00 00       	call   8001da <exit>
}
  8001d0:	83 c4 10             	add    $0x10,%esp
  8001d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e0:	e8 61 11 00 00       	call   801346 <close_all>
	sys_env_destroy(0);
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	6a 00                	push   $0x0
  8001ea:	e8 37 0a 00 00       	call   800c26 <sys_env_destroy>
}
  8001ef:	83 c4 10             	add    $0x10,%esp
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	56                   	push   %esi
  8001f8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001f9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001fc:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800202:	e8 60 0a 00 00       	call   800c67 <sys_getenvid>
  800207:	83 ec 0c             	sub    $0xc,%esp
  80020a:	ff 75 0c             	push   0xc(%ebp)
  80020d:	ff 75 08             	push   0x8(%ebp)
  800210:	56                   	push   %esi
  800211:	50                   	push   %eax
  800212:	68 b0 2d 80 00       	push   $0x802db0
  800217:	e8 b3 00 00 00       	call   8002cf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	53                   	push   %ebx
  800220:	ff 75 10             	push   0x10(%ebp)
  800223:	e8 56 00 00 00       	call   80027e <vcprintf>
	cprintf("\n");
  800228:	c7 04 24 9f 33 80 00 	movl   $0x80339f,(%esp)
  80022f:	e8 9b 00 00 00       	call   8002cf <cprintf>
  800234:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800237:	cc                   	int3   
  800238:	eb fd                	jmp    800237 <_panic+0x43>

0080023a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	53                   	push   %ebx
  80023e:	83 ec 04             	sub    $0x4,%esp
  800241:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800244:	8b 13                	mov    (%ebx),%edx
  800246:	8d 42 01             	lea    0x1(%edx),%eax
  800249:	89 03                	mov    %eax,(%ebx)
  80024b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800252:	3d ff 00 00 00       	cmp    $0xff,%eax
  800257:	74 09                	je     800262 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800259:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800260:	c9                   	leave  
  800261:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	68 ff 00 00 00       	push   $0xff
  80026a:	8d 43 08             	lea    0x8(%ebx),%eax
  80026d:	50                   	push   %eax
  80026e:	e8 76 09 00 00       	call   800be9 <sys_cputs>
		b->idx = 0;
  800273:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800279:	83 c4 10             	add    $0x10,%esp
  80027c:	eb db                	jmp    800259 <putch+0x1f>

0080027e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800287:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028e:	00 00 00 
	b.cnt = 0;
  800291:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800298:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80029b:	ff 75 0c             	push   0xc(%ebp)
  80029e:	ff 75 08             	push   0x8(%ebp)
  8002a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a7:	50                   	push   %eax
  8002a8:	68 3a 02 80 00       	push   $0x80023a
  8002ad:	e8 14 01 00 00       	call   8003c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b2:	83 c4 08             	add    $0x8,%esp
  8002b5:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002bb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c1:	50                   	push   %eax
  8002c2:	e8 22 09 00 00       	call   800be9 <sys_cputs>

	return b.cnt;
}
  8002c7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002cd:	c9                   	leave  
  8002ce:	c3                   	ret    

008002cf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d8:	50                   	push   %eax
  8002d9:	ff 75 08             	push   0x8(%ebp)
  8002dc:	e8 9d ff ff ff       	call   80027e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e1:	c9                   	leave  
  8002e2:	c3                   	ret    

008002e3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
  8002e9:	83 ec 1c             	sub    $0x1c,%esp
  8002ec:	89 c7                	mov    %eax,%edi
  8002ee:	89 d6                	mov    %edx,%esi
  8002f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f6:	89 d1                	mov    %edx,%ecx
  8002f8:	89 c2                	mov    %eax,%edx
  8002fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800300:	8b 45 10             	mov    0x10(%ebp),%eax
  800303:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800306:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800309:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800310:	39 c2                	cmp    %eax,%edx
  800312:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800315:	72 3e                	jb     800355 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800317:	83 ec 0c             	sub    $0xc,%esp
  80031a:	ff 75 18             	push   0x18(%ebp)
  80031d:	83 eb 01             	sub    $0x1,%ebx
  800320:	53                   	push   %ebx
  800321:	50                   	push   %eax
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	ff 75 e4             	push   -0x1c(%ebp)
  800328:	ff 75 e0             	push   -0x20(%ebp)
  80032b:	ff 75 dc             	push   -0x24(%ebp)
  80032e:	ff 75 d8             	push   -0x28(%ebp)
  800331:	e8 7a 27 00 00       	call   802ab0 <__udivdi3>
  800336:	83 c4 18             	add    $0x18,%esp
  800339:	52                   	push   %edx
  80033a:	50                   	push   %eax
  80033b:	89 f2                	mov    %esi,%edx
  80033d:	89 f8                	mov    %edi,%eax
  80033f:	e8 9f ff ff ff       	call   8002e3 <printnum>
  800344:	83 c4 20             	add    $0x20,%esp
  800347:	eb 13                	jmp    80035c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800349:	83 ec 08             	sub    $0x8,%esp
  80034c:	56                   	push   %esi
  80034d:	ff 75 18             	push   0x18(%ebp)
  800350:	ff d7                	call   *%edi
  800352:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800355:	83 eb 01             	sub    $0x1,%ebx
  800358:	85 db                	test   %ebx,%ebx
  80035a:	7f ed                	jg     800349 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035c:	83 ec 08             	sub    $0x8,%esp
  80035f:	56                   	push   %esi
  800360:	83 ec 04             	sub    $0x4,%esp
  800363:	ff 75 e4             	push   -0x1c(%ebp)
  800366:	ff 75 e0             	push   -0x20(%ebp)
  800369:	ff 75 dc             	push   -0x24(%ebp)
  80036c:	ff 75 d8             	push   -0x28(%ebp)
  80036f:	e8 5c 28 00 00       	call   802bd0 <__umoddi3>
  800374:	83 c4 14             	add    $0x14,%esp
  800377:	0f be 80 d3 2d 80 00 	movsbl 0x802dd3(%eax),%eax
  80037e:	50                   	push   %eax
  80037f:	ff d7                	call   *%edi
}
  800381:	83 c4 10             	add    $0x10,%esp
  800384:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800387:	5b                   	pop    %ebx
  800388:	5e                   	pop    %esi
  800389:	5f                   	pop    %edi
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800392:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800396:	8b 10                	mov    (%eax),%edx
  800398:	3b 50 04             	cmp    0x4(%eax),%edx
  80039b:	73 0a                	jae    8003a7 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039d:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a0:	89 08                	mov    %ecx,(%eax)
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	88 02                	mov    %al,(%edx)
}
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <printfmt>:
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003af:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b2:	50                   	push   %eax
  8003b3:	ff 75 10             	push   0x10(%ebp)
  8003b6:	ff 75 0c             	push   0xc(%ebp)
  8003b9:	ff 75 08             	push   0x8(%ebp)
  8003bc:	e8 05 00 00 00       	call   8003c6 <vprintfmt>
}
  8003c1:	83 c4 10             	add    $0x10,%esp
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <vprintfmt>:
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	57                   	push   %edi
  8003ca:	56                   	push   %esi
  8003cb:	53                   	push   %ebx
  8003cc:	83 ec 3c             	sub    $0x3c,%esp
  8003cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d8:	eb 0a                	jmp    8003e4 <vprintfmt+0x1e>
			putch(ch, putdat);
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	53                   	push   %ebx
  8003de:	50                   	push   %eax
  8003df:	ff d6                	call   *%esi
  8003e1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e4:	83 c7 01             	add    $0x1,%edi
  8003e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003eb:	83 f8 25             	cmp    $0x25,%eax
  8003ee:	74 0c                	je     8003fc <vprintfmt+0x36>
			if (ch == '\0')
  8003f0:	85 c0                	test   %eax,%eax
  8003f2:	75 e6                	jne    8003da <vprintfmt+0x14>
}
  8003f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f7:	5b                   	pop    %ebx
  8003f8:	5e                   	pop    %esi
  8003f9:	5f                   	pop    %edi
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    
		padc = ' ';
  8003fc:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800400:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800407:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80040e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8d 47 01             	lea    0x1(%edi),%eax
  80041d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800420:	0f b6 17             	movzbl (%edi),%edx
  800423:	8d 42 dd             	lea    -0x23(%edx),%eax
  800426:	3c 55                	cmp    $0x55,%al
  800428:	0f 87 bb 03 00 00    	ja     8007e9 <vprintfmt+0x423>
  80042e:	0f b6 c0             	movzbl %al,%eax
  800431:	ff 24 85 20 2f 80 00 	jmp    *0x802f20(,%eax,4)
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80043b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80043f:	eb d9                	jmp    80041a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800444:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800448:	eb d0                	jmp    80041a <vprintfmt+0x54>
  80044a:	0f b6 d2             	movzbl %dl,%edx
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800450:	b8 00 00 00 00       	mov    $0x0,%eax
  800455:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800458:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80045b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80045f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800462:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800465:	83 f9 09             	cmp    $0x9,%ecx
  800468:	77 55                	ja     8004bf <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80046a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80046d:	eb e9                	jmp    800458 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8b 00                	mov    (%eax),%eax
  800474:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 40 04             	lea    0x4(%eax),%eax
  80047d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800483:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800487:	79 91                	jns    80041a <vprintfmt+0x54>
				width = precision, precision = -1;
  800489:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80048c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800496:	eb 82                	jmp    80041a <vprintfmt+0x54>
  800498:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a2:	0f 49 c2             	cmovns %edx,%eax
  8004a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ab:	e9 6a ff ff ff       	jmp    80041a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004ba:	e9 5b ff ff ff       	jmp    80041a <vprintfmt+0x54>
  8004bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c5:	eb bc                	jmp    800483 <vprintfmt+0xbd>
			lflag++;
  8004c7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004cd:	e9 48 ff ff ff       	jmp    80041a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 78 04             	lea    0x4(%eax),%edi
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	ff 30                	push   (%eax)
  8004de:	ff d6                	call   *%esi
			break;
  8004e0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004e3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004e6:	e9 9d 02 00 00       	jmp    800788 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 78 04             	lea    0x4(%eax),%edi
  8004f1:	8b 10                	mov    (%eax),%edx
  8004f3:	89 d0                	mov    %edx,%eax
  8004f5:	f7 d8                	neg    %eax
  8004f7:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fa:	83 f8 0f             	cmp    $0xf,%eax
  8004fd:	7f 23                	jg     800522 <vprintfmt+0x15c>
  8004ff:	8b 14 85 80 30 80 00 	mov    0x803080(,%eax,4),%edx
  800506:	85 d2                	test   %edx,%edx
  800508:	74 18                	je     800522 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80050a:	52                   	push   %edx
  80050b:	68 81 32 80 00       	push   $0x803281
  800510:	53                   	push   %ebx
  800511:	56                   	push   %esi
  800512:	e8 92 fe ff ff       	call   8003a9 <printfmt>
  800517:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80051d:	e9 66 02 00 00       	jmp    800788 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800522:	50                   	push   %eax
  800523:	68 eb 2d 80 00       	push   $0x802deb
  800528:	53                   	push   %ebx
  800529:	56                   	push   %esi
  80052a:	e8 7a fe ff ff       	call   8003a9 <printfmt>
  80052f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800532:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800535:	e9 4e 02 00 00       	jmp    800788 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	83 c0 04             	add    $0x4,%eax
  800540:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800548:	85 d2                	test   %edx,%edx
  80054a:	b8 e4 2d 80 00       	mov    $0x802de4,%eax
  80054f:	0f 45 c2             	cmovne %edx,%eax
  800552:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800555:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800559:	7e 06                	jle    800561 <vprintfmt+0x19b>
  80055b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80055f:	75 0d                	jne    80056e <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800564:	89 c7                	mov    %eax,%edi
  800566:	03 45 e0             	add    -0x20(%ebp),%eax
  800569:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056c:	eb 55                	jmp    8005c3 <vprintfmt+0x1fd>
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 d8             	push   -0x28(%ebp)
  800574:	ff 75 cc             	push   -0x34(%ebp)
  800577:	e8 0a 03 00 00       	call   800886 <strnlen>
  80057c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80057f:	29 c1                	sub    %eax,%ecx
  800581:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800589:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80058d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	eb 0f                	jmp    8005a1 <vprintfmt+0x1db>
					putch(padc, putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	ff 75 e0             	push   -0x20(%ebp)
  800599:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80059b:	83 ef 01             	sub    $0x1,%edi
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	85 ff                	test   %edi,%edi
  8005a3:	7f ed                	jg     800592 <vprintfmt+0x1cc>
  8005a5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005a8:	85 d2                	test   %edx,%edx
  8005aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8005af:	0f 49 c2             	cmovns %edx,%eax
  8005b2:	29 c2                	sub    %eax,%edx
  8005b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005b7:	eb a8                	jmp    800561 <vprintfmt+0x19b>
					putch(ch, putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	52                   	push   %edx
  8005be:	ff d6                	call   *%esi
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c8:	83 c7 01             	add    $0x1,%edi
  8005cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005cf:	0f be d0             	movsbl %al,%edx
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	74 4b                	je     800621 <vprintfmt+0x25b>
  8005d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005da:	78 06                	js     8005e2 <vprintfmt+0x21c>
  8005dc:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005e0:	78 1e                	js     800600 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005e6:	74 d1                	je     8005b9 <vprintfmt+0x1f3>
  8005e8:	0f be c0             	movsbl %al,%eax
  8005eb:	83 e8 20             	sub    $0x20,%eax
  8005ee:	83 f8 5e             	cmp    $0x5e,%eax
  8005f1:	76 c6                	jbe    8005b9 <vprintfmt+0x1f3>
					putch('?', putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	6a 3f                	push   $0x3f
  8005f9:	ff d6                	call   *%esi
  8005fb:	83 c4 10             	add    $0x10,%esp
  8005fe:	eb c3                	jmp    8005c3 <vprintfmt+0x1fd>
  800600:	89 cf                	mov    %ecx,%edi
  800602:	eb 0e                	jmp    800612 <vprintfmt+0x24c>
				putch(' ', putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	53                   	push   %ebx
  800608:	6a 20                	push   $0x20
  80060a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80060c:	83 ef 01             	sub    $0x1,%edi
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	85 ff                	test   %edi,%edi
  800614:	7f ee                	jg     800604 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800616:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
  80061c:	e9 67 01 00 00       	jmp    800788 <vprintfmt+0x3c2>
  800621:	89 cf                	mov    %ecx,%edi
  800623:	eb ed                	jmp    800612 <vprintfmt+0x24c>
	if (lflag >= 2)
  800625:	83 f9 01             	cmp    $0x1,%ecx
  800628:	7f 1b                	jg     800645 <vprintfmt+0x27f>
	else if (lflag)
  80062a:	85 c9                	test   %ecx,%ecx
  80062c:	74 63                	je     800691 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 00                	mov    (%eax),%eax
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	99                   	cltd   
  800637:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 40 04             	lea    0x4(%eax),%eax
  800640:	89 45 14             	mov    %eax,0x14(%ebp)
  800643:	eb 17                	jmp    80065c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 50 04             	mov    0x4(%eax),%edx
  80064b:	8b 00                	mov    (%eax),%eax
  80064d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800650:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8d 40 08             	lea    0x8(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80065c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80065f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800662:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800667:	85 c9                	test   %ecx,%ecx
  800669:	0f 89 ff 00 00 00    	jns    80076e <vprintfmt+0x3a8>
				putch('-', putdat);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 2d                	push   $0x2d
  800675:	ff d6                	call   *%esi
				num = -(long long) num;
  800677:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80067d:	f7 da                	neg    %edx
  80067f:	83 d1 00             	adc    $0x0,%ecx
  800682:	f7 d9                	neg    %ecx
  800684:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800687:	bf 0a 00 00 00       	mov    $0xa,%edi
  80068c:	e9 dd 00 00 00       	jmp    80076e <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	99                   	cltd   
  80069a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 40 04             	lea    0x4(%eax),%eax
  8006a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a6:	eb b4                	jmp    80065c <vprintfmt+0x296>
	if (lflag >= 2)
  8006a8:	83 f9 01             	cmp    $0x1,%ecx
  8006ab:	7f 1e                	jg     8006cb <vprintfmt+0x305>
	else if (lflag)
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	74 32                	je     8006e3 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8006c6:	e9 a3 00 00 00       	jmp    80076e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 10                	mov    (%eax),%edx
  8006d0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d3:	8d 40 08             	lea    0x8(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8006de:	e9 8b 00 00 00       	jmp    80076e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8006f8:	eb 74                	jmp    80076e <vprintfmt+0x3a8>
	if (lflag >= 2)
  8006fa:	83 f9 01             	cmp    $0x1,%ecx
  8006fd:	7f 1b                	jg     80071a <vprintfmt+0x354>
	else if (lflag)
  8006ff:	85 c9                	test   %ecx,%ecx
  800701:	74 2c                	je     80072f <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8b 10                	mov    (%eax),%edx
  800708:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070d:	8d 40 04             	lea    0x4(%eax),%eax
  800710:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800713:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800718:	eb 54                	jmp    80076e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	8b 48 04             	mov    0x4(%eax),%ecx
  800722:	8d 40 08             	lea    0x8(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800728:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80072d:	eb 3f                	jmp    80076e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8b 10                	mov    (%eax),%edx
  800734:	b9 00 00 00 00       	mov    $0x0,%ecx
  800739:	8d 40 04             	lea    0x4(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80073f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800744:	eb 28                	jmp    80076e <vprintfmt+0x3a8>
			putch('0', putdat);
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	53                   	push   %ebx
  80074a:	6a 30                	push   $0x30
  80074c:	ff d6                	call   *%esi
			putch('x', putdat);
  80074e:	83 c4 08             	add    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 78                	push   $0x78
  800754:	ff d6                	call   *%esi
			num = (unsigned long long)
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8b 10                	mov    (%eax),%edx
  80075b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800760:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800763:	8d 40 04             	lea    0x4(%eax),%eax
  800766:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800769:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80076e:	83 ec 0c             	sub    $0xc,%esp
  800771:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800775:	50                   	push   %eax
  800776:	ff 75 e0             	push   -0x20(%ebp)
  800779:	57                   	push   %edi
  80077a:	51                   	push   %ecx
  80077b:	52                   	push   %edx
  80077c:	89 da                	mov    %ebx,%edx
  80077e:	89 f0                	mov    %esi,%eax
  800780:	e8 5e fb ff ff       	call   8002e3 <printnum>
			break;
  800785:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800788:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078b:	e9 54 fc ff ff       	jmp    8003e4 <vprintfmt+0x1e>
	if (lflag >= 2)
  800790:	83 f9 01             	cmp    $0x1,%ecx
  800793:	7f 1b                	jg     8007b0 <vprintfmt+0x3ea>
	else if (lflag)
  800795:	85 c9                	test   %ecx,%ecx
  800797:	74 2c                	je     8007c5 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8b 10                	mov    (%eax),%edx
  80079e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a3:	8d 40 04             	lea    0x4(%eax),%eax
  8007a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a9:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8007ae:	eb be                	jmp    80076e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8b 10                	mov    (%eax),%edx
  8007b5:	8b 48 04             	mov    0x4(%eax),%ecx
  8007b8:	8d 40 08             	lea    0x8(%eax),%eax
  8007bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007be:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8007c3:	eb a9                	jmp    80076e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8b 10                	mov    (%eax),%edx
  8007ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cf:	8d 40 04             	lea    0x4(%eax),%eax
  8007d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8007da:	eb 92                	jmp    80076e <vprintfmt+0x3a8>
			putch(ch, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	6a 25                	push   $0x25
  8007e2:	ff d6                	call   *%esi
			break;
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	eb 9f                	jmp    800788 <vprintfmt+0x3c2>
			putch('%', putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	6a 25                	push   $0x25
  8007ef:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f1:	83 c4 10             	add    $0x10,%esp
  8007f4:	89 f8                	mov    %edi,%eax
  8007f6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007fa:	74 05                	je     800801 <vprintfmt+0x43b>
  8007fc:	83 e8 01             	sub    $0x1,%eax
  8007ff:	eb f5                	jmp    8007f6 <vprintfmt+0x430>
  800801:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800804:	eb 82                	jmp    800788 <vprintfmt+0x3c2>

00800806 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	83 ec 18             	sub    $0x18,%esp
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800812:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800815:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800819:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800823:	85 c0                	test   %eax,%eax
  800825:	74 26                	je     80084d <vsnprintf+0x47>
  800827:	85 d2                	test   %edx,%edx
  800829:	7e 22                	jle    80084d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082b:	ff 75 14             	push   0x14(%ebp)
  80082e:	ff 75 10             	push   0x10(%ebp)
  800831:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800834:	50                   	push   %eax
  800835:	68 8c 03 80 00       	push   $0x80038c
  80083a:	e8 87 fb ff ff       	call   8003c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800842:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800845:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800848:	83 c4 10             	add    $0x10,%esp
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    
		return -E_INVAL;
  80084d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800852:	eb f7                	jmp    80084b <vsnprintf+0x45>

00800854 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80085d:	50                   	push   %eax
  80085e:	ff 75 10             	push   0x10(%ebp)
  800861:	ff 75 0c             	push   0xc(%ebp)
  800864:	ff 75 08             	push   0x8(%ebp)
  800867:	e8 9a ff ff ff       	call   800806 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
  800879:	eb 03                	jmp    80087e <strlen+0x10>
		n++;
  80087b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80087e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800882:	75 f7                	jne    80087b <strlen+0xd>
	return n;
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
  800894:	eb 03                	jmp    800899 <strnlen+0x13>
		n++;
  800896:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800899:	39 d0                	cmp    %edx,%eax
  80089b:	74 08                	je     8008a5 <strnlen+0x1f>
  80089d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a1:	75 f3                	jne    800896 <strnlen+0x10>
  8008a3:	89 c2                	mov    %eax,%edx
	return n;
}
  8008a5:	89 d0                	mov    %edx,%eax
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008bc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	84 d2                	test   %dl,%dl
  8008c4:	75 f2                	jne    8008b8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c6:	89 c8                	mov    %ecx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	53                   	push   %ebx
  8008d1:	83 ec 10             	sub    $0x10,%esp
  8008d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d7:	53                   	push   %ebx
  8008d8:	e8 91 ff ff ff       	call   80086e <strlen>
  8008dd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008e0:	ff 75 0c             	push   0xc(%ebp)
  8008e3:	01 d8                	add    %ebx,%eax
  8008e5:	50                   	push   %eax
  8008e6:	e8 be ff ff ff       	call   8008a9 <strcpy>
	return dst;
}
  8008eb:	89 d8                	mov    %ebx,%eax
  8008ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	89 f3                	mov    %esi,%ebx
  8008ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800902:	89 f0                	mov    %esi,%eax
  800904:	eb 0f                	jmp    800915 <strncpy+0x23>
		*dst++ = *src;
  800906:	83 c0 01             	add    $0x1,%eax
  800909:	0f b6 0a             	movzbl (%edx),%ecx
  80090c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090f:	80 f9 01             	cmp    $0x1,%cl
  800912:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800915:	39 d8                	cmp    %ebx,%eax
  800917:	75 ed                	jne    800906 <strncpy+0x14>
	}
	return ret;
}
  800919:	89 f0                	mov    %esi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 75 08             	mov    0x8(%ebp),%esi
  800927:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092a:	8b 55 10             	mov    0x10(%ebp),%edx
  80092d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092f:	85 d2                	test   %edx,%edx
  800931:	74 21                	je     800954 <strlcpy+0x35>
  800933:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800937:	89 f2                	mov    %esi,%edx
  800939:	eb 09                	jmp    800944 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093b:	83 c1 01             	add    $0x1,%ecx
  80093e:	83 c2 01             	add    $0x1,%edx
  800941:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800944:	39 c2                	cmp    %eax,%edx
  800946:	74 09                	je     800951 <strlcpy+0x32>
  800948:	0f b6 19             	movzbl (%ecx),%ebx
  80094b:	84 db                	test   %bl,%bl
  80094d:	75 ec                	jne    80093b <strlcpy+0x1c>
  80094f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800951:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800954:	29 f0                	sub    %esi,%eax
}
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800963:	eb 06                	jmp    80096b <strcmp+0x11>
		p++, q++;
  800965:	83 c1 01             	add    $0x1,%ecx
  800968:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80096b:	0f b6 01             	movzbl (%ecx),%eax
  80096e:	84 c0                	test   %al,%al
  800970:	74 04                	je     800976 <strcmp+0x1c>
  800972:	3a 02                	cmp    (%edx),%al
  800974:	74 ef                	je     800965 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800976:	0f b6 c0             	movzbl %al,%eax
  800979:	0f b6 12             	movzbl (%edx),%edx
  80097c:	29 d0                	sub    %edx,%eax
}
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	89 c3                	mov    %eax,%ebx
  80098c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098f:	eb 06                	jmp    800997 <strncmp+0x17>
		n--, p++, q++;
  800991:	83 c0 01             	add    $0x1,%eax
  800994:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800997:	39 d8                	cmp    %ebx,%eax
  800999:	74 18                	je     8009b3 <strncmp+0x33>
  80099b:	0f b6 08             	movzbl (%eax),%ecx
  80099e:	84 c9                	test   %cl,%cl
  8009a0:	74 04                	je     8009a6 <strncmp+0x26>
  8009a2:	3a 0a                	cmp    (%edx),%cl
  8009a4:	74 eb                	je     800991 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a6:	0f b6 00             	movzbl (%eax),%eax
  8009a9:	0f b6 12             	movzbl (%edx),%edx
  8009ac:	29 d0                	sub    %edx,%eax
}
  8009ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    
		return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b8:	eb f4                	jmp    8009ae <strncmp+0x2e>

008009ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c4:	eb 03                	jmp    8009c9 <strchr+0xf>
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	0f b6 10             	movzbl (%eax),%edx
  8009cc:	84 d2                	test   %dl,%dl
  8009ce:	74 06                	je     8009d6 <strchr+0x1c>
		if (*s == c)
  8009d0:	38 ca                	cmp    %cl,%dl
  8009d2:	75 f2                	jne    8009c6 <strchr+0xc>
  8009d4:	eb 05                	jmp    8009db <strchr+0x21>
			return (char *) s;
	return 0;
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ea:	38 ca                	cmp    %cl,%dl
  8009ec:	74 09                	je     8009f7 <strfind+0x1a>
  8009ee:	84 d2                	test   %dl,%dl
  8009f0:	74 05                	je     8009f7 <strfind+0x1a>
	for (; *s; s++)
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	eb f0                	jmp    8009e7 <strfind+0xa>
			break;
	return (char *) s;
}
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a05:	85 c9                	test   %ecx,%ecx
  800a07:	74 2f                	je     800a38 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a09:	89 f8                	mov    %edi,%eax
  800a0b:	09 c8                	or     %ecx,%eax
  800a0d:	a8 03                	test   $0x3,%al
  800a0f:	75 21                	jne    800a32 <memset+0x39>
		c &= 0xFF;
  800a11:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a15:	89 d0                	mov    %edx,%eax
  800a17:	c1 e0 08             	shl    $0x8,%eax
  800a1a:	89 d3                	mov    %edx,%ebx
  800a1c:	c1 e3 18             	shl    $0x18,%ebx
  800a1f:	89 d6                	mov    %edx,%esi
  800a21:	c1 e6 10             	shl    $0x10,%esi
  800a24:	09 f3                	or     %esi,%ebx
  800a26:	09 da                	or     %ebx,%edx
  800a28:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a2a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a2d:	fc                   	cld    
  800a2e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a30:	eb 06                	jmp    800a38 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a35:	fc                   	cld    
  800a36:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a38:	89 f8                	mov    %edi,%eax
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4d:	39 c6                	cmp    %eax,%esi
  800a4f:	73 32                	jae    800a83 <memmove+0x44>
  800a51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a54:	39 c2                	cmp    %eax,%edx
  800a56:	76 2b                	jbe    800a83 <memmove+0x44>
		s += n;
		d += n;
  800a58:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5b:	89 d6                	mov    %edx,%esi
  800a5d:	09 fe                	or     %edi,%esi
  800a5f:	09 ce                	or     %ecx,%esi
  800a61:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a67:	75 0e                	jne    800a77 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a69:	83 ef 04             	sub    $0x4,%edi
  800a6c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a72:	fd                   	std    
  800a73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a75:	eb 09                	jmp    800a80 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a77:	83 ef 01             	sub    $0x1,%edi
  800a7a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a7d:	fd                   	std    
  800a7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a80:	fc                   	cld    
  800a81:	eb 1a                	jmp    800a9d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a83:	89 f2                	mov    %esi,%edx
  800a85:	09 c2                	or     %eax,%edx
  800a87:	09 ca                	or     %ecx,%edx
  800a89:	f6 c2 03             	test   $0x3,%dl
  800a8c:	75 0a                	jne    800a98 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a8e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a91:	89 c7                	mov    %eax,%edi
  800a93:	fc                   	cld    
  800a94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a96:	eb 05                	jmp    800a9d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a98:	89 c7                	mov    %eax,%edi
  800a9a:	fc                   	cld    
  800a9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa7:	ff 75 10             	push   0x10(%ebp)
  800aaa:	ff 75 0c             	push   0xc(%ebp)
  800aad:	ff 75 08             	push   0x8(%ebp)
  800ab0:	e8 8a ff ff ff       	call   800a3f <memmove>
}
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    

00800ab7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac2:	89 c6                	mov    %eax,%esi
  800ac4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac7:	eb 06                	jmp    800acf <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ac9:	83 c0 01             	add    $0x1,%eax
  800acc:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800acf:	39 f0                	cmp    %esi,%eax
  800ad1:	74 14                	je     800ae7 <memcmp+0x30>
		if (*s1 != *s2)
  800ad3:	0f b6 08             	movzbl (%eax),%ecx
  800ad6:	0f b6 1a             	movzbl (%edx),%ebx
  800ad9:	38 d9                	cmp    %bl,%cl
  800adb:	74 ec                	je     800ac9 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800add:	0f b6 c1             	movzbl %cl,%eax
  800ae0:	0f b6 db             	movzbl %bl,%ebx
  800ae3:	29 d8                	sub    %ebx,%eax
  800ae5:	eb 05                	jmp    800aec <memcmp+0x35>
	}

	return 0;
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af9:	89 c2                	mov    %eax,%edx
  800afb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800afe:	eb 03                	jmp    800b03 <memfind+0x13>
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	39 d0                	cmp    %edx,%eax
  800b05:	73 04                	jae    800b0b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b07:	38 08                	cmp    %cl,(%eax)
  800b09:	75 f5                	jne    800b00 <memfind+0x10>
			break;
	return (void *) s;
}
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b19:	eb 03                	jmp    800b1e <strtol+0x11>
		s++;
  800b1b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b1e:	0f b6 02             	movzbl (%edx),%eax
  800b21:	3c 20                	cmp    $0x20,%al
  800b23:	74 f6                	je     800b1b <strtol+0xe>
  800b25:	3c 09                	cmp    $0x9,%al
  800b27:	74 f2                	je     800b1b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b29:	3c 2b                	cmp    $0x2b,%al
  800b2b:	74 2a                	je     800b57 <strtol+0x4a>
	int neg = 0;
  800b2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b32:	3c 2d                	cmp    $0x2d,%al
  800b34:	74 2b                	je     800b61 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b36:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3c:	75 0f                	jne    800b4d <strtol+0x40>
  800b3e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b41:	74 28                	je     800b6b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b43:	85 db                	test   %ebx,%ebx
  800b45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4a:	0f 44 d8             	cmove  %eax,%ebx
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b55:	eb 46                	jmp    800b9d <strtol+0x90>
		s++;
  800b57:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5f:	eb d5                	jmp    800b36 <strtol+0x29>
		s++, neg = 1;
  800b61:	83 c2 01             	add    $0x1,%edx
  800b64:	bf 01 00 00 00       	mov    $0x1,%edi
  800b69:	eb cb                	jmp    800b36 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b6f:	74 0e                	je     800b7f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b71:	85 db                	test   %ebx,%ebx
  800b73:	75 d8                	jne    800b4d <strtol+0x40>
		s++, base = 8;
  800b75:	83 c2 01             	add    $0x1,%edx
  800b78:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b7d:	eb ce                	jmp    800b4d <strtol+0x40>
		s += 2, base = 16;
  800b7f:	83 c2 02             	add    $0x2,%edx
  800b82:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b87:	eb c4                	jmp    800b4d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b89:	0f be c0             	movsbl %al,%eax
  800b8c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b8f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b92:	7d 3a                	jge    800bce <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b94:	83 c2 01             	add    $0x1,%edx
  800b97:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b9b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b9d:	0f b6 02             	movzbl (%edx),%eax
  800ba0:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ba3:	89 f3                	mov    %esi,%ebx
  800ba5:	80 fb 09             	cmp    $0x9,%bl
  800ba8:	76 df                	jbe    800b89 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800baa:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bad:	89 f3                	mov    %esi,%ebx
  800baf:	80 fb 19             	cmp    $0x19,%bl
  800bb2:	77 08                	ja     800bbc <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bb4:	0f be c0             	movsbl %al,%eax
  800bb7:	83 e8 57             	sub    $0x57,%eax
  800bba:	eb d3                	jmp    800b8f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bbc:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bbf:	89 f3                	mov    %esi,%ebx
  800bc1:	80 fb 19             	cmp    $0x19,%bl
  800bc4:	77 08                	ja     800bce <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bc6:	0f be c0             	movsbl %al,%eax
  800bc9:	83 e8 37             	sub    $0x37,%eax
  800bcc:	eb c1                	jmp    800b8f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd2:	74 05                	je     800bd9 <strtol+0xcc>
		*endptr = (char *) s;
  800bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bd9:	89 c8                	mov    %ecx,%eax
  800bdb:	f7 d8                	neg    %eax
  800bdd:	85 ff                	test   %edi,%edi
  800bdf:	0f 45 c8             	cmovne %eax,%ecx
}
  800be2:	89 c8                	mov    %ecx,%eax
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	89 c3                	mov    %eax,%ebx
  800bfc:	89 c7                	mov    %eax,%edi
  800bfe:	89 c6                	mov    %eax,%esi
  800c00:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 01 00 00 00       	mov    $0x1,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	b8 03 00 00 00       	mov    $0x3,%eax
  800c3c:	89 cb                	mov    %ecx,%ebx
  800c3e:	89 cf                	mov    %ecx,%edi
  800c40:	89 ce                	mov    %ecx,%esi
  800c42:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7f 08                	jg     800c50 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 03                	push   $0x3
  800c56:	68 df 30 80 00       	push   $0x8030df
  800c5b:	6a 2a                	push   $0x2a
  800c5d:	68 fc 30 80 00       	push   $0x8030fc
  800c62:	e8 8d f5 ff ff       	call   8001f4 <_panic>

00800c67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	b8 02 00 00 00       	mov    $0x2,%eax
  800c77:	89 d1                	mov    %edx,%ecx
  800c79:	89 d3                	mov    %edx,%ebx
  800c7b:	89 d7                	mov    %edx,%edi
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_yield>:

void
sys_yield(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cae:	be 00 00 00 00       	mov    $0x0,%esi
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	b8 04 00 00 00       	mov    $0x4,%eax
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	89 f7                	mov    %esi,%edi
  800cc3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7f 08                	jg     800cd1 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	50                   	push   %eax
  800cd5:	6a 04                	push   $0x4
  800cd7:	68 df 30 80 00       	push   $0x8030df
  800cdc:	6a 2a                	push   $0x2a
  800cde:	68 fc 30 80 00       	push   $0x8030fc
  800ce3:	e8 0c f5 ff ff       	call   8001f4 <_panic>

00800ce8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d02:	8b 75 18             	mov    0x18(%ebp),%esi
  800d05:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7f 08                	jg     800d13 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 05                	push   $0x5
  800d19:	68 df 30 80 00       	push   $0x8030df
  800d1e:	6a 2a                	push   $0x2a
  800d20:	68 fc 30 80 00       	push   $0x8030fc
  800d25:	e8 ca f4 ff ff       	call   8001f4 <_panic>

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7f 08                	jg     800d55 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 06                	push   $0x6
  800d5b:	68 df 30 80 00       	push   $0x8030df
  800d60:	6a 2a                	push   $0x2a
  800d62:	68 fc 30 80 00       	push   $0x8030fc
  800d67:	e8 88 f4 ff ff       	call   8001f4 <_panic>

00800d6c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	b8 08 00 00 00       	mov    $0x8,%eax
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7f 08                	jg     800d97 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 08                	push   $0x8
  800d9d:	68 df 30 80 00       	push   $0x8030df
  800da2:	6a 2a                	push   $0x2a
  800da4:	68 fc 30 80 00       	push   $0x8030fc
  800da9:	e8 46 f4 ff ff       	call   8001f4 <_panic>

00800dae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7f 08                	jg     800dd9 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	6a 09                	push   $0x9
  800ddf:	68 df 30 80 00       	push   $0x8030df
  800de4:	6a 2a                	push   $0x2a
  800de6:	68 fc 30 80 00       	push   $0x8030fc
  800deb:	e8 04 f4 ff ff       	call   8001f4 <_panic>

00800df0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7f 08                	jg     800e1b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	50                   	push   %eax
  800e1f:	6a 0a                	push   $0xa
  800e21:	68 df 30 80 00       	push   $0x8030df
  800e26:	6a 2a                	push   $0x2a
  800e28:	68 fc 30 80 00       	push   $0x8030fc
  800e2d:	e8 c2 f3 ff ff       	call   8001f4 <_panic>

00800e32 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e43:	be 00 00 00 00       	mov    $0x0,%esi
  800e48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e6b:	89 cb                	mov    %ecx,%ebx
  800e6d:	89 cf                	mov    %ecx,%edi
  800e6f:	89 ce                	mov    %ecx,%esi
  800e71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7f 08                	jg     800e7f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5f                   	pop    %edi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7f:	83 ec 0c             	sub    $0xc,%esp
  800e82:	50                   	push   %eax
  800e83:	6a 0d                	push   $0xd
  800e85:	68 df 30 80 00       	push   $0x8030df
  800e8a:	6a 2a                	push   $0x2a
  800e8c:	68 fc 30 80 00       	push   $0x8030fc
  800e91:	e8 5e f3 ff ff       	call   8001f4 <_panic>

00800e96 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea6:	89 d1                	mov    %edx,%ecx
  800ea8:	89 d3                	mov    %edx,%ebx
  800eaa:	89 d7                	mov    %edx,%edi
  800eac:	89 d6                	mov    %edx,%esi
  800eae:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec6:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ecb:	89 df                	mov    %ebx,%edi
  800ecd:	89 de                	mov    %ebx,%esi
  800ecf:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800edc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	b8 10 00 00 00       	mov    $0x10,%eax
  800eec:	89 df                	mov    %ebx,%edi
  800eee:	89 de                	mov    %ebx,%esi
  800ef0:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eff:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f01:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f05:	0f 84 8e 00 00 00    	je     800f99 <pgfault+0xa2>
  800f0b:	89 f0                	mov    %esi,%eax
  800f0d:	c1 e8 0c             	shr    $0xc,%eax
  800f10:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f17:	f6 c4 08             	test   $0x8,%ah
  800f1a:	74 7d                	je     800f99 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800f1c:	e8 46 fd ff ff       	call   800c67 <sys_getenvid>
  800f21:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800f23:	83 ec 04             	sub    $0x4,%esp
  800f26:	6a 07                	push   $0x7
  800f28:	68 00 f0 7f 00       	push   $0x7ff000
  800f2d:	50                   	push   %eax
  800f2e:	e8 72 fd ff ff       	call   800ca5 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	78 73                	js     800fad <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f3a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	68 00 10 00 00       	push   $0x1000
  800f48:	56                   	push   %esi
  800f49:	68 00 f0 7f 00       	push   $0x7ff000
  800f4e:	e8 ec fa ff ff       	call   800a3f <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f53:	83 c4 08             	add    $0x8,%esp
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	e8 cd fd ff ff       	call   800d2a <sys_page_unmap>
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	78 5b                	js     800fbf <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	6a 07                	push   $0x7
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
  800f6b:	68 00 f0 7f 00       	push   $0x7ff000
  800f70:	53                   	push   %ebx
  800f71:	e8 72 fd ff ff       	call   800ce8 <sys_page_map>
  800f76:	83 c4 20             	add    $0x20,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 54                	js     800fd1 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f7d:	83 ec 08             	sub    $0x8,%esp
  800f80:	68 00 f0 7f 00       	push   $0x7ff000
  800f85:	53                   	push   %ebx
  800f86:	e8 9f fd ff ff       	call   800d2a <sys_page_unmap>
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	78 51                	js     800fe3 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800f92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	68 0c 31 80 00       	push   $0x80310c
  800fa1:	6a 1d                	push   $0x1d
  800fa3:	68 88 31 80 00       	push   $0x803188
  800fa8:	e8 47 f2 ff ff       	call   8001f4 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800fad:	50                   	push   %eax
  800fae:	68 44 31 80 00       	push   $0x803144
  800fb3:	6a 29                	push   $0x29
  800fb5:	68 88 31 80 00       	push   $0x803188
  800fba:	e8 35 f2 ff ff       	call   8001f4 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800fbf:	50                   	push   %eax
  800fc0:	68 68 31 80 00       	push   $0x803168
  800fc5:	6a 2e                	push   $0x2e
  800fc7:	68 88 31 80 00       	push   $0x803188
  800fcc:	e8 23 f2 ff ff       	call   8001f4 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800fd1:	50                   	push   %eax
  800fd2:	68 93 31 80 00       	push   $0x803193
  800fd7:	6a 30                	push   $0x30
  800fd9:	68 88 31 80 00       	push   $0x803188
  800fde:	e8 11 f2 ff ff       	call   8001f4 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800fe3:	50                   	push   %eax
  800fe4:	68 68 31 80 00       	push   $0x803168
  800fe9:	6a 32                	push   $0x32
  800feb:	68 88 31 80 00       	push   $0x803188
  800ff0:	e8 ff f1 ff ff       	call   8001f4 <_panic>

00800ff5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800ffe:	68 f7 0e 80 00       	push   $0x800ef7
  801003:	e8 dc 18 00 00       	call   8028e4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801008:	b8 07 00 00 00       	mov    $0x7,%eax
  80100d:	cd 30                	int    $0x30
  80100f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	78 2d                	js     801046 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801019:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80101e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801022:	75 73                	jne    801097 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  801024:	e8 3e fc ff ff       	call   800c67 <sys_getenvid>
  801029:	25 ff 03 00 00       	and    $0x3ff,%eax
  80102e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801031:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801036:	a3 00 50 80 00       	mov    %eax,0x805000
		return 0;
  80103b:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  80103e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801046:	50                   	push   %eax
  801047:	68 b1 31 80 00       	push   $0x8031b1
  80104c:	6a 78                	push   $0x78
  80104e:	68 88 31 80 00       	push   $0x803188
  801053:	e8 9c f1 ff ff       	call   8001f4 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	ff 75 e4             	push   -0x1c(%ebp)
  80105e:	57                   	push   %edi
  80105f:	ff 75 dc             	push   -0x24(%ebp)
  801062:	57                   	push   %edi
  801063:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801066:	56                   	push   %esi
  801067:	e8 7c fc ff ff       	call   800ce8 <sys_page_map>
	if(r<0) return r;
  80106c:	83 c4 20             	add    $0x20,%esp
  80106f:	85 c0                	test   %eax,%eax
  801071:	78 cb                	js     80103e <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801073:	83 ec 0c             	sub    $0xc,%esp
  801076:	ff 75 e4             	push   -0x1c(%ebp)
  801079:	57                   	push   %edi
  80107a:	56                   	push   %esi
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	e8 66 fc ff ff       	call   800ce8 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801082:	83 c4 20             	add    $0x20,%esp
  801085:	85 c0                	test   %eax,%eax
  801087:	78 76                	js     8010ff <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801089:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80108f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801095:	74 75                	je     80110c <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801097:	89 d8                	mov    %ebx,%eax
  801099:	c1 e8 16             	shr    $0x16,%eax
  80109c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a3:	a8 01                	test   $0x1,%al
  8010a5:	74 e2                	je     801089 <fork+0x94>
  8010a7:	89 de                	mov    %ebx,%esi
  8010a9:	c1 ee 0c             	shr    $0xc,%esi
  8010ac:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b3:	a8 01                	test   $0x1,%al
  8010b5:	74 d2                	je     801089 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  8010b7:	e8 ab fb ff ff       	call   800c67 <sys_getenvid>
  8010bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8010bf:	89 f7                	mov    %esi,%edi
  8010c1:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  8010c4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010cb:	89 c1                	mov    %eax,%ecx
  8010cd:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8010d3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8010d6:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8010dd:	f6 c6 04             	test   $0x4,%dh
  8010e0:	0f 85 72 ff ff ff    	jne    801058 <fork+0x63>
		perm &= ~PTE_W;
  8010e6:	25 05 0e 00 00       	and    $0xe05,%eax
  8010eb:	80 cc 08             	or     $0x8,%ah
  8010ee:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8010f4:	0f 44 c1             	cmove  %ecx,%eax
  8010f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010fa:	e9 59 ff ff ff       	jmp    801058 <fork+0x63>
  8010ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801104:	0f 4f c2             	cmovg  %edx,%eax
  801107:	e9 32 ff ff ff       	jmp    80103e <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	6a 07                	push   $0x7
  801111:	68 00 f0 bf ee       	push   $0xeebff000
  801116:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801119:	57                   	push   %edi
  80111a:	e8 86 fb ff ff       	call   800ca5 <sys_page_alloc>
	if(r<0) return r;
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	0f 88 14 ff ff ff    	js     80103e <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	68 5a 29 80 00       	push   $0x80295a
  801132:	57                   	push   %edi
  801133:	e8 b8 fc ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	0f 88 fb fe ff ff    	js     80103e <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801143:	83 ec 08             	sub    $0x8,%esp
  801146:	6a 02                	push   $0x2
  801148:	57                   	push   %edi
  801149:	e8 1e fc ff ff       	call   800d6c <sys_env_set_status>
	if(r<0) return r;
  80114e:	83 c4 10             	add    $0x10,%esp
	return envid;
  801151:	85 c0                	test   %eax,%eax
  801153:	0f 49 c7             	cmovns %edi,%eax
  801156:	e9 e3 fe ff ff       	jmp    80103e <fork+0x49>

0080115b <sfork>:

// Challenge!
int
sfork(void)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801161:	68 c1 31 80 00       	push   $0x8031c1
  801166:	68 a1 00 00 00       	push   $0xa1
  80116b:	68 88 31 80 00       	push   $0x803188
  801170:	e8 7f f0 ff ff       	call   8001f4 <_panic>

00801175 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801178:	8b 45 08             	mov    0x8(%ebp),%eax
  80117b:	05 00 00 00 30       	add    $0x30000000,%eax
  801180:	c1 e8 0c             	shr    $0xc,%eax
}
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801188:	8b 45 08             	mov    0x8(%ebp),%eax
  80118b:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801190:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801195:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 ea 16             	shr    $0x16,%edx
  8011a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b0:	f6 c2 01             	test   $0x1,%dl
  8011b3:	74 29                	je     8011de <fd_alloc+0x42>
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	c1 ea 0c             	shr    $0xc,%edx
  8011ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c1:	f6 c2 01             	test   $0x1,%dl
  8011c4:	74 18                	je     8011de <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011c6:	05 00 10 00 00       	add    $0x1000,%eax
  8011cb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d0:	75 d2                	jne    8011a4 <fd_alloc+0x8>
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8011d7:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8011dc:	eb 05                	jmp    8011e3 <fd_alloc+0x47>
			return 0;
  8011de:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8011e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e6:	89 02                	mov    %eax,(%edx)
}
  8011e8:	89 c8                	mov    %ecx,%eax
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f2:	83 f8 1f             	cmp    $0x1f,%eax
  8011f5:	77 30                	ja     801227 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f7:	c1 e0 0c             	shl    $0xc,%eax
  8011fa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ff:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801205:	f6 c2 01             	test   $0x1,%dl
  801208:	74 24                	je     80122e <fd_lookup+0x42>
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	c1 ea 0c             	shr    $0xc,%edx
  80120f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801216:	f6 c2 01             	test   $0x1,%dl
  801219:	74 1a                	je     801235 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80121b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121e:	89 02                	mov    %eax,(%edx)
	return 0;
  801220:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    
		return -E_INVAL;
  801227:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122c:	eb f7                	jmp    801225 <fd_lookup+0x39>
		return -E_INVAL;
  80122e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801233:	eb f0                	jmp    801225 <fd_lookup+0x39>
  801235:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123a:	eb e9                	jmp    801225 <fd_lookup+0x39>

0080123c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	53                   	push   %ebx
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801246:	b8 00 00 00 00       	mov    $0x0,%eax
  80124b:	bb 0c 40 80 00       	mov    $0x80400c,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801250:	39 13                	cmp    %edx,(%ebx)
  801252:	74 37                	je     80128b <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801254:	83 c0 01             	add    $0x1,%eax
  801257:	8b 1c 85 54 32 80 00 	mov    0x803254(,%eax,4),%ebx
  80125e:	85 db                	test   %ebx,%ebx
  801260:	75 ee                	jne    801250 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801262:	a1 00 50 80 00       	mov    0x805000,%eax
  801267:	8b 40 48             	mov    0x48(%eax),%eax
  80126a:	83 ec 04             	sub    $0x4,%esp
  80126d:	52                   	push   %edx
  80126e:	50                   	push   %eax
  80126f:	68 d8 31 80 00       	push   $0x8031d8
  801274:	e8 56 f0 ff ff       	call   8002cf <cprintf>
	*dev = 0;
	return -E_INVAL;
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801281:	8b 55 0c             	mov    0xc(%ebp),%edx
  801284:	89 1a                	mov    %ebx,(%edx)
}
  801286:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801289:	c9                   	leave  
  80128a:	c3                   	ret    
			return 0;
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
  801290:	eb ef                	jmp    801281 <dev_lookup+0x45>

00801292 <fd_close>:
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 24             	sub    $0x24,%esp
  80129b:	8b 75 08             	mov    0x8(%ebp),%esi
  80129e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012a4:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ab:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ae:	50                   	push   %eax
  8012af:	e8 38 ff ff ff       	call   8011ec <fd_lookup>
  8012b4:	89 c3                	mov    %eax,%ebx
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	78 05                	js     8012c2 <fd_close+0x30>
	    || fd != fd2)
  8012bd:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012c0:	74 16                	je     8012d8 <fd_close+0x46>
		return (must_exist ? r : 0);
  8012c2:	89 f8                	mov    %edi,%eax
  8012c4:	84 c0                	test   %al,%al
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cb:	0f 44 d8             	cmove  %eax,%ebx
}
  8012ce:	89 d8                	mov    %ebx,%eax
  8012d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	ff 36                	push   (%esi)
  8012e1:	e8 56 ff ff ff       	call   80123c <dev_lookup>
  8012e6:	89 c3                	mov    %eax,%ebx
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 1a                	js     801309 <fd_close+0x77>
		if (dev->dev_close)
  8012ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f2:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	74 0b                	je     801309 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8012fe:	83 ec 0c             	sub    $0xc,%esp
  801301:	56                   	push   %esi
  801302:	ff d0                	call   *%eax
  801304:	89 c3                	mov    %eax,%ebx
  801306:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	56                   	push   %esi
  80130d:	6a 00                	push   $0x0
  80130f:	e8 16 fa ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	eb b5                	jmp    8012ce <fd_close+0x3c>

00801319 <close>:

int
close(int fdnum)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801322:	50                   	push   %eax
  801323:	ff 75 08             	push   0x8(%ebp)
  801326:	e8 c1 fe ff ff       	call   8011ec <fd_lookup>
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	79 02                	jns    801334 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801332:	c9                   	leave  
  801333:	c3                   	ret    
		return fd_close(fd, 1);
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	6a 01                	push   $0x1
  801339:	ff 75 f4             	push   -0xc(%ebp)
  80133c:	e8 51 ff ff ff       	call   801292 <fd_close>
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	eb ec                	jmp    801332 <close+0x19>

00801346 <close_all>:

void
close_all(void)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	53                   	push   %ebx
  80134a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	53                   	push   %ebx
  801356:	e8 be ff ff ff       	call   801319 <close>
	for (i = 0; i < MAXFD; i++)
  80135b:	83 c3 01             	add    $0x1,%ebx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	83 fb 20             	cmp    $0x20,%ebx
  801364:	75 ec                	jne    801352 <close_all+0xc>
}
  801366:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	57                   	push   %edi
  80136f:	56                   	push   %esi
  801370:	53                   	push   %ebx
  801371:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801374:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801377:	50                   	push   %eax
  801378:	ff 75 08             	push   0x8(%ebp)
  80137b:	e8 6c fe ff ff       	call   8011ec <fd_lookup>
  801380:	89 c3                	mov    %eax,%ebx
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	78 7f                	js     801408 <dup+0x9d>
		return r;
	close(newfdnum);
  801389:	83 ec 0c             	sub    $0xc,%esp
  80138c:	ff 75 0c             	push   0xc(%ebp)
  80138f:	e8 85 ff ff ff       	call   801319 <close>

	newfd = INDEX2FD(newfdnum);
  801394:	8b 75 0c             	mov    0xc(%ebp),%esi
  801397:	c1 e6 0c             	shl    $0xc,%esi
  80139a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013a3:	89 3c 24             	mov    %edi,(%esp)
  8013a6:	e8 da fd ff ff       	call   801185 <fd2data>
  8013ab:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013ad:	89 34 24             	mov    %esi,(%esp)
  8013b0:	e8 d0 fd ff ff       	call   801185 <fd2data>
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013bb:	89 d8                	mov    %ebx,%eax
  8013bd:	c1 e8 16             	shr    $0x16,%eax
  8013c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c7:	a8 01                	test   $0x1,%al
  8013c9:	74 11                	je     8013dc <dup+0x71>
  8013cb:	89 d8                	mov    %ebx,%eax
  8013cd:	c1 e8 0c             	shr    $0xc,%eax
  8013d0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d7:	f6 c2 01             	test   $0x1,%dl
  8013da:	75 36                	jne    801412 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013dc:	89 f8                	mov    %edi,%eax
  8013de:	c1 e8 0c             	shr    $0xc,%eax
  8013e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e8:	83 ec 0c             	sub    $0xc,%esp
  8013eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f0:	50                   	push   %eax
  8013f1:	56                   	push   %esi
  8013f2:	6a 00                	push   $0x0
  8013f4:	57                   	push   %edi
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 ec f8 ff ff       	call   800ce8 <sys_page_map>
  8013fc:	89 c3                	mov    %eax,%ebx
  8013fe:	83 c4 20             	add    $0x20,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 33                	js     801438 <dup+0xcd>
		goto err;

	return newfdnum;
  801405:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801408:	89 d8                	mov    %ebx,%eax
  80140a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801412:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	25 07 0e 00 00       	and    $0xe07,%eax
  801421:	50                   	push   %eax
  801422:	ff 75 d4             	push   -0x2c(%ebp)
  801425:	6a 00                	push   $0x0
  801427:	53                   	push   %ebx
  801428:	6a 00                	push   $0x0
  80142a:	e8 b9 f8 ff ff       	call   800ce8 <sys_page_map>
  80142f:	89 c3                	mov    %eax,%ebx
  801431:	83 c4 20             	add    $0x20,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	79 a4                	jns    8013dc <dup+0x71>
	sys_page_unmap(0, newfd);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	56                   	push   %esi
  80143c:	6a 00                	push   $0x0
  80143e:	e8 e7 f8 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801443:	83 c4 08             	add    $0x8,%esp
  801446:	ff 75 d4             	push   -0x2c(%ebp)
  801449:	6a 00                	push   $0x0
  80144b:	e8 da f8 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	eb b3                	jmp    801408 <dup+0x9d>

00801455 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	56                   	push   %esi
  801459:	53                   	push   %ebx
  80145a:	83 ec 18             	sub    $0x18,%esp
  80145d:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801460:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	56                   	push   %esi
  801465:	e8 82 fd ff ff       	call   8011ec <fd_lookup>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 3c                	js     8014ad <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801471:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	ff 33                	push   (%ebx)
  80147d:	e8 ba fd ff ff       	call   80123c <dev_lookup>
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	85 c0                	test   %eax,%eax
  801487:	78 24                	js     8014ad <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801489:	8b 43 08             	mov    0x8(%ebx),%eax
  80148c:	83 e0 03             	and    $0x3,%eax
  80148f:	83 f8 01             	cmp    $0x1,%eax
  801492:	74 20                	je     8014b4 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801494:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801497:	8b 40 08             	mov    0x8(%eax),%eax
  80149a:	85 c0                	test   %eax,%eax
  80149c:	74 37                	je     8014d5 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	ff 75 10             	push   0x10(%ebp)
  8014a4:	ff 75 0c             	push   0xc(%ebp)
  8014a7:	53                   	push   %ebx
  8014a8:	ff d0                	call   *%eax
  8014aa:	83 c4 10             	add    $0x10,%esp
}
  8014ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b4:	a1 00 50 80 00       	mov    0x805000,%eax
  8014b9:	8b 40 48             	mov    0x48(%eax),%eax
  8014bc:	83 ec 04             	sub    $0x4,%esp
  8014bf:	56                   	push   %esi
  8014c0:	50                   	push   %eax
  8014c1:	68 19 32 80 00       	push   $0x803219
  8014c6:	e8 04 ee ff ff       	call   8002cf <cprintf>
		return -E_INVAL;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d3:	eb d8                	jmp    8014ad <read+0x58>
		return -E_NOT_SUPP;
  8014d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014da:	eb d1                	jmp    8014ad <read+0x58>

008014dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	57                   	push   %edi
  8014e0:	56                   	push   %esi
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 0c             	sub    $0xc,%esp
  8014e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f0:	eb 02                	jmp    8014f4 <readn+0x18>
  8014f2:	01 c3                	add    %eax,%ebx
  8014f4:	39 f3                	cmp    %esi,%ebx
  8014f6:	73 21                	jae    801519 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	89 f0                	mov    %esi,%eax
  8014fd:	29 d8                	sub    %ebx,%eax
  8014ff:	50                   	push   %eax
  801500:	89 d8                	mov    %ebx,%eax
  801502:	03 45 0c             	add    0xc(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	57                   	push   %edi
  801507:	e8 49 ff ff ff       	call   801455 <read>
		if (m < 0)
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 04                	js     801517 <readn+0x3b>
			return m;
		if (m == 0)
  801513:	75 dd                	jne    8014f2 <readn+0x16>
  801515:	eb 02                	jmp    801519 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801517:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801519:	89 d8                	mov    %ebx,%eax
  80151b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5e                   	pop    %esi
  801520:	5f                   	pop    %edi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	83 ec 18             	sub    $0x18,%esp
  80152b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801531:	50                   	push   %eax
  801532:	53                   	push   %ebx
  801533:	e8 b4 fc ff ff       	call   8011ec <fd_lookup>
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	85 c0                	test   %eax,%eax
  80153d:	78 37                	js     801576 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	ff 36                	push   (%esi)
  80154b:	e8 ec fc ff ff       	call   80123c <dev_lookup>
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 1f                	js     801576 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801557:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80155b:	74 20                	je     80157d <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80155d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801560:	8b 40 0c             	mov    0xc(%eax),%eax
  801563:	85 c0                	test   %eax,%eax
  801565:	74 37                	je     80159e <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	ff 75 10             	push   0x10(%ebp)
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
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80157d:	a1 00 50 80 00       	mov    0x805000,%eax
  801582:	8b 40 48             	mov    0x48(%eax),%eax
  801585:	83 ec 04             	sub    $0x4,%esp
  801588:	53                   	push   %ebx
  801589:	50                   	push   %eax
  80158a:	68 35 32 80 00       	push   $0x803235
  80158f:	e8 3b ed ff ff       	call   8002cf <cprintf>
		return -E_INVAL;
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159c:	eb d8                	jmp    801576 <write+0x53>
		return -E_NOT_SUPP;
  80159e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a3:	eb d1                	jmp    801576 <write+0x53>

008015a5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	ff 75 08             	push   0x8(%ebp)
  8015b2:	e8 35 fc ff ff       	call   8011ec <fd_lookup>
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 0e                	js     8015cc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 18             	sub    $0x18,%esp
  8015d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	53                   	push   %ebx
  8015de:	e8 09 fc ff ff       	call   8011ec <fd_lookup>
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 34                	js     80161e <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ea:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	ff 36                	push   (%esi)
  8015f6:	e8 41 fc ff ff       	call   80123c <dev_lookup>
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 1c                	js     80161e <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801602:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801606:	74 1d                	je     801625 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801608:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160b:	8b 40 18             	mov    0x18(%eax),%eax
  80160e:	85 c0                	test   %eax,%eax
  801610:	74 34                	je     801646 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	ff 75 0c             	push   0xc(%ebp)
  801618:	56                   	push   %esi
  801619:	ff d0                	call   *%eax
  80161b:	83 c4 10             	add    $0x10,%esp
}
  80161e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801621:	5b                   	pop    %ebx
  801622:	5e                   	pop    %esi
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    
			thisenv->env_id, fdnum);
  801625:	a1 00 50 80 00       	mov    0x805000,%eax
  80162a:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80162d:	83 ec 04             	sub    $0x4,%esp
  801630:	53                   	push   %ebx
  801631:	50                   	push   %eax
  801632:	68 f8 31 80 00       	push   $0x8031f8
  801637:	e8 93 ec ff ff       	call   8002cf <cprintf>
		return -E_INVAL;
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801644:	eb d8                	jmp    80161e <ftruncate+0x50>
		return -E_NOT_SUPP;
  801646:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80164b:	eb d1                	jmp    80161e <ftruncate+0x50>

0080164d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	56                   	push   %esi
  801651:	53                   	push   %ebx
  801652:	83 ec 18             	sub    $0x18,%esp
  801655:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165b:	50                   	push   %eax
  80165c:	ff 75 08             	push   0x8(%ebp)
  80165f:	e8 88 fb ff ff       	call   8011ec <fd_lookup>
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	85 c0                	test   %eax,%eax
  801669:	78 49                	js     8016b4 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	ff 36                	push   (%esi)
  801677:	e8 c0 fb ff ff       	call   80123c <dev_lookup>
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 31                	js     8016b4 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801686:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80168a:	74 2f                	je     8016bb <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80168c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80168f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801696:	00 00 00 
	stat->st_isdir = 0;
  801699:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a0:	00 00 00 
	stat->st_dev = dev;
  8016a3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	53                   	push   %ebx
  8016ad:	56                   	push   %esi
  8016ae:	ff 50 14             	call   *0x14(%eax)
  8016b1:	83 c4 10             	add    $0x10,%esp
}
  8016b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    
		return -E_NOT_SUPP;
  8016bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016c0:	eb f2                	jmp    8016b4 <fstat+0x67>

008016c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	6a 00                	push   $0x0
  8016cc:	ff 75 08             	push   0x8(%ebp)
  8016cf:	e8 e4 01 00 00       	call   8018b8 <open>
  8016d4:	89 c3                	mov    %eax,%ebx
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 1b                	js     8016f8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	ff 75 0c             	push   0xc(%ebp)
  8016e3:	50                   	push   %eax
  8016e4:	e8 64 ff ff ff       	call   80164d <fstat>
  8016e9:	89 c6                	mov    %eax,%esi
	close(fd);
  8016eb:	89 1c 24             	mov    %ebx,(%esp)
  8016ee:	e8 26 fc ff ff       	call   801319 <close>
	return r;
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	89 f3                	mov    %esi,%ebx
}
  8016f8:	89 d8                	mov    %ebx,%eax
  8016fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	5d                   	pop    %ebp
  801700:	c3                   	ret    

00801701 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
  801706:	89 c6                	mov    %eax,%esi
  801708:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80170a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801711:	74 27                	je     80173a <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801713:	6a 07                	push   $0x7
  801715:	68 00 60 80 00       	push   $0x806000
  80171a:	56                   	push   %esi
  80171b:	ff 35 00 70 80 00    	push   0x807000
  801721:	e8 c1 12 00 00       	call   8029e7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801726:	83 c4 0c             	add    $0xc,%esp
  801729:	6a 00                	push   $0x0
  80172b:	53                   	push   %ebx
  80172c:	6a 00                	push   $0x0
  80172e:	e8 4d 12 00 00       	call   802980 <ipc_recv>
}
  801733:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801736:	5b                   	pop    %ebx
  801737:	5e                   	pop    %esi
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	6a 01                	push   $0x1
  80173f:	e8 f7 12 00 00       	call   802a3b <ipc_find_env>
  801744:	a3 00 70 80 00       	mov    %eax,0x807000
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	eb c5                	jmp    801713 <fsipc+0x12>

0080174e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801754:	8b 45 08             	mov    0x8(%ebp),%eax
  801757:	8b 40 0c             	mov    0xc(%eax),%eax
  80175a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80175f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801762:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801767:	ba 00 00 00 00       	mov    $0x0,%edx
  80176c:	b8 02 00 00 00       	mov    $0x2,%eax
  801771:	e8 8b ff ff ff       	call   801701 <fsipc>
}
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <devfile_flush>:
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 06 00 00 00       	mov    $0x6,%eax
  801793:	e8 69 ff ff ff       	call   801701 <fsipc>
}
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <devfile_stat>:
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	53                   	push   %ebx
  80179e:	83 ec 04             	sub    $0x4,%esp
  8017a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017aa:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017af:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b9:	e8 43 ff ff ff       	call   801701 <fsipc>
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 2c                	js     8017ee <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c2:	83 ec 08             	sub    $0x8,%esp
  8017c5:	68 00 60 80 00       	push   $0x806000
  8017ca:	53                   	push   %ebx
  8017cb:	e8 d9 f0 ff ff       	call   8008a9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d0:	a1 80 60 80 00       	mov    0x806080,%eax
  8017d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017db:	a1 84 60 80 00       	mov    0x806084,%eax
  8017e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <devfile_write>:
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017fc:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801801:	39 d0                	cmp    %edx,%eax
  801803:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801806:	8b 55 08             	mov    0x8(%ebp),%edx
  801809:	8b 52 0c             	mov    0xc(%edx),%edx
  80180c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801812:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801817:	50                   	push   %eax
  801818:	ff 75 0c             	push   0xc(%ebp)
  80181b:	68 08 60 80 00       	push   $0x806008
  801820:	e8 1a f2 ff ff       	call   800a3f <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801825:	ba 00 00 00 00       	mov    $0x0,%edx
  80182a:	b8 04 00 00 00       	mov    $0x4,%eax
  80182f:	e8 cd fe ff ff       	call   801701 <fsipc>
}
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <devfile_read>:
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	56                   	push   %esi
  80183a:	53                   	push   %ebx
  80183b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80183e:	8b 45 08             	mov    0x8(%ebp),%eax
  801841:	8b 40 0c             	mov    0xc(%eax),%eax
  801844:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801849:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 03 00 00 00       	mov    $0x3,%eax
  801859:	e8 a3 fe ff ff       	call   801701 <fsipc>
  80185e:	89 c3                	mov    %eax,%ebx
  801860:	85 c0                	test   %eax,%eax
  801862:	78 1f                	js     801883 <devfile_read+0x4d>
	assert(r <= n);
  801864:	39 f0                	cmp    %esi,%eax
  801866:	77 24                	ja     80188c <devfile_read+0x56>
	assert(r <= PGSIZE);
  801868:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186d:	7f 33                	jg     8018a2 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	50                   	push   %eax
  801873:	68 00 60 80 00       	push   $0x806000
  801878:	ff 75 0c             	push   0xc(%ebp)
  80187b:	e8 bf f1 ff ff       	call   800a3f <memmove>
	return r;
  801880:	83 c4 10             	add    $0x10,%esp
}
  801883:	89 d8                	mov    %ebx,%eax
  801885:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801888:	5b                   	pop    %ebx
  801889:	5e                   	pop    %esi
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    
	assert(r <= n);
  80188c:	68 68 32 80 00       	push   $0x803268
  801891:	68 6f 32 80 00       	push   $0x80326f
  801896:	6a 7c                	push   $0x7c
  801898:	68 84 32 80 00       	push   $0x803284
  80189d:	e8 52 e9 ff ff       	call   8001f4 <_panic>
	assert(r <= PGSIZE);
  8018a2:	68 8f 32 80 00       	push   $0x80328f
  8018a7:	68 6f 32 80 00       	push   $0x80326f
  8018ac:	6a 7d                	push   $0x7d
  8018ae:	68 84 32 80 00       	push   $0x803284
  8018b3:	e8 3c e9 ff ff       	call   8001f4 <_panic>

008018b8 <open>:
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	56                   	push   %esi
  8018bc:	53                   	push   %ebx
  8018bd:	83 ec 1c             	sub    $0x1c,%esp
  8018c0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018c3:	56                   	push   %esi
  8018c4:	e8 a5 ef ff ff       	call   80086e <strlen>
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d1:	7f 6c                	jg     80193f <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018d3:	83 ec 0c             	sub    $0xc,%esp
  8018d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d9:	50                   	push   %eax
  8018da:	e8 bd f8 ff ff       	call   80119c <fd_alloc>
  8018df:	89 c3                	mov    %eax,%ebx
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	78 3c                	js     801924 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018e8:	83 ec 08             	sub    $0x8,%esp
  8018eb:	56                   	push   %esi
  8018ec:	68 00 60 80 00       	push   $0x806000
  8018f1:	e8 b3 ef ff ff       	call   8008a9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f9:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801901:	b8 01 00 00 00       	mov    $0x1,%eax
  801906:	e8 f6 fd ff ff       	call   801701 <fsipc>
  80190b:	89 c3                	mov    %eax,%ebx
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	85 c0                	test   %eax,%eax
  801912:	78 19                	js     80192d <open+0x75>
	return fd2num(fd);
  801914:	83 ec 0c             	sub    $0xc,%esp
  801917:	ff 75 f4             	push   -0xc(%ebp)
  80191a:	e8 56 f8 ff ff       	call   801175 <fd2num>
  80191f:	89 c3                	mov    %eax,%ebx
  801921:	83 c4 10             	add    $0x10,%esp
}
  801924:	89 d8                	mov    %ebx,%eax
  801926:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801929:	5b                   	pop    %ebx
  80192a:	5e                   	pop    %esi
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    
		fd_close(fd, 0);
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	6a 00                	push   $0x0
  801932:	ff 75 f4             	push   -0xc(%ebp)
  801935:	e8 58 f9 ff ff       	call   801292 <fd_close>
		return r;
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	eb e5                	jmp    801924 <open+0x6c>
		return -E_BAD_PATH;
  80193f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801944:	eb de                	jmp    801924 <open+0x6c>

00801946 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80194c:	ba 00 00 00 00       	mov    $0x0,%edx
  801951:	b8 08 00 00 00       	mov    $0x8,%eax
  801956:	e8 a6 fd ff ff       	call   801701 <fsipc>
}
  80195b:	c9                   	leave  
  80195c:	c3                   	ret    

0080195d <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	57                   	push   %edi
  801961:	56                   	push   %esi
  801962:	53                   	push   %ebx
  801963:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801969:	6a 00                	push   $0x0
  80196b:	ff 75 08             	push   0x8(%ebp)
  80196e:	e8 45 ff ff ff       	call   8018b8 <open>
  801973:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	85 c0                	test   %eax,%eax
  80197e:	0f 88 aa 04 00 00    	js     801e2e <spawn+0x4d1>
  801984:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801986:	83 ec 04             	sub    $0x4,%esp
  801989:	68 00 02 00 00       	push   $0x200
  80198e:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801994:	50                   	push   %eax
  801995:	57                   	push   %edi
  801996:	e8 41 fb ff ff       	call   8014dc <readn>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019a3:	75 57                	jne    8019fc <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  8019a5:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019ac:	45 4c 46 
  8019af:	75 4b                	jne    8019fc <spawn+0x9f>
  8019b1:	b8 07 00 00 00       	mov    $0x7,%eax
  8019b6:	cd 30                	int    $0x30
  8019b8:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	0f 88 5c 04 00 00    	js     801e22 <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019c6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019cb:	6b f0 7c             	imul   $0x7c,%eax,%esi
  8019ce:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019d4:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019da:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019e1:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019e7:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019ed:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8019f2:	be 00 00 00 00       	mov    $0x0,%esi
  8019f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  8019fa:	eb 4b                	jmp    801a47 <spawn+0xea>
		close(fd);
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801a05:	e8 0f f9 ff ff       	call   801319 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a0a:	83 c4 0c             	add    $0xc,%esp
  801a0d:	68 7f 45 4c 46       	push   $0x464c457f
  801a12:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  801a18:	68 9b 32 80 00       	push   $0x80329b
  801a1d:	e8 ad e8 ff ff       	call   8002cf <cprintf>
		return -E_NOT_EXEC;
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  801a2c:	ff ff ff 
  801a2f:	e9 fa 03 00 00       	jmp    801e2e <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	50                   	push   %eax
  801a38:	e8 31 ee ff ff       	call   80086e <strlen>
  801a3d:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801a41:	83 c3 01             	add    $0x1,%ebx
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a4e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a51:	85 c0                	test   %eax,%eax
  801a53:	75 df                	jne    801a34 <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a55:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801a5b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801a61:	b8 00 10 40 00       	mov    $0x401000,%eax
  801a66:	29 f0                	sub    %esi,%eax
  801a68:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a6a:	89 c2                	mov    %eax,%edx
  801a6c:	83 e2 fc             	and    $0xfffffffc,%edx
  801a6f:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a76:	29 c2                	sub    %eax,%edx
  801a78:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a7e:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a81:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a86:	0f 86 14 04 00 00    	jbe    801ea0 <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a8c:	83 ec 04             	sub    $0x4,%esp
  801a8f:	6a 07                	push   $0x7
  801a91:	68 00 00 40 00       	push   $0x400000
  801a96:	6a 00                	push   $0x0
  801a98:	e8 08 f2 ff ff       	call   800ca5 <sys_page_alloc>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	0f 88 fd 03 00 00    	js     801ea5 <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801aa8:	be 00 00 00 00       	mov    $0x0,%esi
  801aad:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801ab3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ab6:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801abc:	7e 32                	jle    801af0 <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  801abe:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ac4:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801aca:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801acd:	83 ec 08             	sub    $0x8,%esp
  801ad0:	ff 34 b3             	push   (%ebx,%esi,4)
  801ad3:	57                   	push   %edi
  801ad4:	e8 d0 ed ff ff       	call   8008a9 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801ad9:	83 c4 04             	add    $0x4,%esp
  801adc:	ff 34 b3             	push   (%ebx,%esi,4)
  801adf:	e8 8a ed ff ff       	call   80086e <strlen>
  801ae4:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801ae8:	83 c6 01             	add    $0x1,%esi
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	eb c6                	jmp    801ab6 <spawn+0x159>
	}
	argv_store[argc] = 0;
  801af0:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801af6:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801afc:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b03:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b09:	0f 85 8c 00 00 00    	jne    801b9b <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b0f:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b15:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801b1b:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801b1e:	89 c8                	mov    %ecx,%eax
  801b20:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801b26:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b29:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801b2e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b34:	83 ec 0c             	sub    $0xc,%esp
  801b37:	6a 07                	push   $0x7
  801b39:	68 00 d0 bf ee       	push   $0xeebfd000
  801b3e:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801b44:	68 00 00 40 00       	push   $0x400000
  801b49:	6a 00                	push   $0x0
  801b4b:	e8 98 f1 ff ff       	call   800ce8 <sys_page_map>
  801b50:	89 c3                	mov    %eax,%ebx
  801b52:	83 c4 20             	add    $0x20,%esp
  801b55:	85 c0                	test   %eax,%eax
  801b57:	0f 88 50 03 00 00    	js     801ead <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b5d:	83 ec 08             	sub    $0x8,%esp
  801b60:	68 00 00 40 00       	push   $0x400000
  801b65:	6a 00                	push   $0x0
  801b67:	e8 be f1 ff ff       	call   800d2a <sys_page_unmap>
  801b6c:	89 c3                	mov    %eax,%ebx
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	85 c0                	test   %eax,%eax
  801b73:	0f 88 34 03 00 00    	js     801ead <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b79:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b7f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b86:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b8c:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801b93:	00 00 00 
  801b96:	e9 4e 01 00 00       	jmp    801ce9 <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b9b:	68 28 33 80 00       	push   $0x803328
  801ba0:	68 6f 32 80 00       	push   $0x80326f
  801ba5:	68 f2 00 00 00       	push   $0xf2
  801baa:	68 b5 32 80 00       	push   $0x8032b5
  801baf:	e8 40 e6 ff ff       	call   8001f4 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bb4:	83 ec 04             	sub    $0x4,%esp
  801bb7:	6a 07                	push   $0x7
  801bb9:	68 00 00 40 00       	push   $0x400000
  801bbe:	6a 00                	push   $0x0
  801bc0:	e8 e0 f0 ff ff       	call   800ca5 <sys_page_alloc>
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	0f 88 6c 02 00 00    	js     801e3c <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bd0:	83 ec 08             	sub    $0x8,%esp
  801bd3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bd9:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bdf:	50                   	push   %eax
  801be0:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801be6:	e8 ba f9 ff ff       	call   8015a5 <seek>
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	0f 88 4d 02 00 00    	js     801e43 <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bf6:	83 ec 04             	sub    $0x4,%esp
  801bf9:	89 f8                	mov    %edi,%eax
  801bfb:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c01:	ba 00 10 00 00       	mov    $0x1000,%edx
  801c06:	39 d0                	cmp    %edx,%eax
  801c08:	0f 47 c2             	cmova  %edx,%eax
  801c0b:	50                   	push   %eax
  801c0c:	68 00 00 40 00       	push   $0x400000
  801c11:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801c17:	e8 c0 f8 ff ff       	call   8014dc <readn>
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	0f 88 23 02 00 00    	js     801e4a <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c27:	83 ec 0c             	sub    $0xc,%esp
  801c2a:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801c30:	56                   	push   %esi
  801c31:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801c37:	68 00 00 40 00       	push   $0x400000
  801c3c:	6a 00                	push   $0x0
  801c3e:	e8 a5 f0 ff ff       	call   800ce8 <sys_page_map>
  801c43:	83 c4 20             	add    $0x20,%esp
  801c46:	85 c0                	test   %eax,%eax
  801c48:	78 7c                	js     801cc6 <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801c4a:	83 ec 08             	sub    $0x8,%esp
  801c4d:	68 00 00 40 00       	push   $0x400000
  801c52:	6a 00                	push   $0x0
  801c54:	e8 d1 f0 ff ff       	call   800d2a <sys_page_unmap>
  801c59:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801c5c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c62:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c68:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c6e:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c74:	76 65                	jbe    801cdb <spawn+0x37e>
		if (i >= filesz) {
  801c76:	39 df                	cmp    %ebx,%edi
  801c78:	0f 87 36 ff ff ff    	ja     801bb4 <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c7e:	83 ec 04             	sub    $0x4,%esp
  801c81:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801c87:	56                   	push   %esi
  801c88:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801c8e:	e8 12 f0 ff ff       	call   800ca5 <sys_page_alloc>
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	85 c0                	test   %eax,%eax
  801c98:	79 c2                	jns    801c5c <spawn+0x2ff>
  801c9a:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801c9c:	83 ec 0c             	sub    $0xc,%esp
  801c9f:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801ca5:	e8 7c ef ff ff       	call   800c26 <sys_env_destroy>
	close(fd);
  801caa:	83 c4 04             	add    $0x4,%esp
  801cad:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801cb3:	e8 61 f6 ff ff       	call   801319 <close>
	return r;
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  801cc1:	e9 68 01 00 00       	jmp    801e2e <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  801cc6:	50                   	push   %eax
  801cc7:	68 c1 32 80 00       	push   $0x8032c1
  801ccc:	68 25 01 00 00       	push   $0x125
  801cd1:	68 b5 32 80 00       	push   $0x8032b5
  801cd6:	e8 19 e5 ff ff       	call   8001f4 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cdb:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801ce2:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801ce9:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cf0:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801cf6:	7e 67                	jle    801d5f <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  801cf8:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801cfe:	83 39 01             	cmpl   $0x1,(%ecx)
  801d01:	75 d8                	jne    801cdb <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d03:	8b 41 18             	mov    0x18(%ecx),%eax
  801d06:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801d0c:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801d0f:	83 f8 01             	cmp    $0x1,%eax
  801d12:	19 c0                	sbb    %eax,%eax
  801d14:	83 e0 fe             	and    $0xfffffffe,%eax
  801d17:	83 c0 07             	add    $0x7,%eax
  801d1a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d20:	8b 51 04             	mov    0x4(%ecx),%edx
  801d23:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801d29:	8b 79 10             	mov    0x10(%ecx),%edi
  801d2c:	8b 59 14             	mov    0x14(%ecx),%ebx
  801d2f:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d35:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  801d38:	89 f0                	mov    %esi,%eax
  801d3a:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d3f:	74 14                	je     801d55 <spawn+0x3f8>
		va -= i;
  801d41:	29 c6                	sub    %eax,%esi
		memsz += i;
  801d43:	01 c3                	add    %eax,%ebx
  801d45:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801d4b:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801d4d:	29 c2                	sub    %eax,%edx
  801d4f:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d5a:	e9 09 ff ff ff       	jmp    801c68 <spawn+0x30b>
	close(fd);
  801d5f:	83 ec 0c             	sub    $0xc,%esp
  801d62:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801d68:	e8 ac f5 ff ff       	call   801319 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801d6d:	e8 f5 ee ff ff       	call   800c67 <sys_getenvid>
  801d72:	89 c6                	mov    %eax,%esi
  801d74:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801d77:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801d7c:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801d82:	eb 12                	jmp    801d96 <spawn+0x439>
  801d84:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d8a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d90:	0f 84 bb 00 00 00    	je     801e51 <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801d96:	89 d8                	mov    %ebx,%eax
  801d98:	c1 e8 16             	shr    $0x16,%eax
  801d9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801da2:	a8 01                	test   $0x1,%al
  801da4:	74 de                	je     801d84 <spawn+0x427>
  801da6:	89 d8                	mov    %ebx,%eax
  801da8:	c1 e8 0c             	shr    $0xc,%eax
  801dab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801db2:	f6 c2 01             	test   $0x1,%dl
  801db5:	74 cd                	je     801d84 <spawn+0x427>
  801db7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dbe:	f6 c6 04             	test   $0x4,%dh
  801dc1:	74 c1                	je     801d84 <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801dc3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dca:	83 ec 0c             	sub    $0xc,%esp
  801dcd:	25 07 0e 00 00       	and    $0xe07,%eax
  801dd2:	50                   	push   %eax
  801dd3:	53                   	push   %ebx
  801dd4:	57                   	push   %edi
  801dd5:	53                   	push   %ebx
  801dd6:	56                   	push   %esi
  801dd7:	e8 0c ef ff ff       	call   800ce8 <sys_page_map>
  801ddc:	83 c4 20             	add    $0x20,%esp
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	79 a1                	jns    801d84 <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  801de3:	50                   	push   %eax
  801de4:	68 0f 33 80 00       	push   $0x80330f
  801de9:	68 82 00 00 00       	push   $0x82
  801dee:	68 b5 32 80 00       	push   $0x8032b5
  801df3:	e8 fc e3 ff ff       	call   8001f4 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801df8:	50                   	push   %eax
  801df9:	68 de 32 80 00       	push   $0x8032de
  801dfe:	68 86 00 00 00       	push   $0x86
  801e03:	68 b5 32 80 00       	push   $0x8032b5
  801e08:	e8 e7 e3 ff ff       	call   8001f4 <_panic>
		panic("sys_env_set_status: %e", r);
  801e0d:	50                   	push   %eax
  801e0e:	68 f8 32 80 00       	push   $0x8032f8
  801e13:	68 89 00 00 00       	push   $0x89
  801e18:	68 b5 32 80 00       	push   $0x8032b5
  801e1d:	e8 d2 e3 ff ff       	call   8001f4 <_panic>
		return r;
  801e22:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e28:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801e2e:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801e34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e37:	5b                   	pop    %ebx
  801e38:	5e                   	pop    %esi
  801e39:	5f                   	pop    %edi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    
  801e3c:	89 c7                	mov    %eax,%edi
  801e3e:	e9 59 fe ff ff       	jmp    801c9c <spawn+0x33f>
  801e43:	89 c7                	mov    %eax,%edi
  801e45:	e9 52 fe ff ff       	jmp    801c9c <spawn+0x33f>
  801e4a:	89 c7                	mov    %eax,%edi
  801e4c:	e9 4b fe ff ff       	jmp    801c9c <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e51:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e58:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e64:	50                   	push   %eax
  801e65:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801e6b:	e8 3e ef ff ff       	call   800dae <sys_env_set_trapframe>
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 81                	js     801df8 <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e77:	83 ec 08             	sub    $0x8,%esp
  801e7a:	6a 02                	push   $0x2
  801e7c:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801e82:	e8 e5 ee ff ff       	call   800d6c <sys_env_set_status>
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	0f 88 7b ff ff ff    	js     801e0d <spawn+0x4b0>
	return child;
  801e92:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e98:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801e9e:	eb 8e                	jmp    801e2e <spawn+0x4d1>
		return -E_NO_MEM;
  801ea0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801ea5:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801eab:	eb 81                	jmp    801e2e <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  801ead:	83 ec 08             	sub    $0x8,%esp
  801eb0:	68 00 00 40 00       	push   $0x400000
  801eb5:	6a 00                	push   $0x0
  801eb7:	e8 6e ee ff ff       	call   800d2a <sys_page_unmap>
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801ec5:	e9 64 ff ff ff       	jmp    801e2e <spawn+0x4d1>

00801eca <spawnl>:
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	56                   	push   %esi
  801ece:	53                   	push   %ebx
	va_start(vl, arg0);
  801ecf:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801ed2:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801ed7:	eb 05                	jmp    801ede <spawnl+0x14>
		argc++;
  801ed9:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801edc:	89 ca                	mov    %ecx,%edx
  801ede:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ee1:	83 3a 00             	cmpl   $0x0,(%edx)
  801ee4:	75 f3                	jne    801ed9 <spawnl+0xf>
	const char *argv[argc+2];
  801ee6:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801eed:	89 d3                	mov    %edx,%ebx
  801eef:	83 e3 f0             	and    $0xfffffff0,%ebx
  801ef2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801ef8:	89 e1                	mov    %esp,%ecx
  801efa:	29 d1                	sub    %edx,%ecx
  801efc:	39 cc                	cmp    %ecx,%esp
  801efe:	74 10                	je     801f10 <spawnl+0x46>
  801f00:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801f06:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801f0d:	00 
  801f0e:	eb ec                	jmp    801efc <spawnl+0x32>
  801f10:	89 da                	mov    %ebx,%edx
  801f12:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801f18:	29 d4                	sub    %edx,%esp
  801f1a:	85 d2                	test   %edx,%edx
  801f1c:	74 05                	je     801f23 <spawnl+0x59>
  801f1e:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801f23:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801f27:	89 da                	mov    %ebx,%edx
  801f29:	c1 ea 02             	shr    $0x2,%edx
  801f2c:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801f2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f32:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f39:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801f40:	00 
	va_start(vl, arg0);
  801f41:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801f44:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801f46:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4b:	eb 0b                	jmp    801f58 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801f4d:	83 c0 01             	add    $0x1,%eax
  801f50:	8b 31                	mov    (%ecx),%esi
  801f52:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801f55:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801f58:	39 d0                	cmp    %edx,%eax
  801f5a:	75 f1                	jne    801f4d <spawnl+0x83>
	return spawn(prog, argv);
  801f5c:	83 ec 08             	sub    $0x8,%esp
  801f5f:	53                   	push   %ebx
  801f60:	ff 75 08             	push   0x8(%ebp)
  801f63:	e8 f5 f9 ff ff       	call   80195d <spawn>
}
  801f68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6b:	5b                   	pop    %ebx
  801f6c:	5e                   	pop    %esi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    

00801f6f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801f75:	68 4e 33 80 00       	push   $0x80334e
  801f7a:	ff 75 0c             	push   0xc(%ebp)
  801f7d:	e8 27 e9 ff ff       	call   8008a9 <strcpy>
	return 0;
}
  801f82:	b8 00 00 00 00       	mov    $0x0,%eax
  801f87:	c9                   	leave  
  801f88:	c3                   	ret    

00801f89 <devsock_close>:
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	53                   	push   %ebx
  801f8d:	83 ec 10             	sub    $0x10,%esp
  801f90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f93:	53                   	push   %ebx
  801f94:	e8 db 0a 00 00       	call   802a74 <pageref>
  801f99:	89 c2                	mov    %eax,%edx
  801f9b:	83 c4 10             	add    $0x10,%esp
		return 0;
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801fa3:	83 fa 01             	cmp    $0x1,%edx
  801fa6:	74 05                	je     801fad <devsock_close+0x24>
}
  801fa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801fad:	83 ec 0c             	sub    $0xc,%esp
  801fb0:	ff 73 0c             	push   0xc(%ebx)
  801fb3:	e8 b7 02 00 00       	call   80226f <nsipc_close>
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	eb eb                	jmp    801fa8 <devsock_close+0x1f>

00801fbd <devsock_write>:
{
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
  801fc0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801fc3:	6a 00                	push   $0x0
  801fc5:	ff 75 10             	push   0x10(%ebp)
  801fc8:	ff 75 0c             	push   0xc(%ebp)
  801fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fce:	ff 70 0c             	push   0xc(%eax)
  801fd1:	e8 79 03 00 00       	call   80234f <nsipc_send>
}
  801fd6:	c9                   	leave  
  801fd7:	c3                   	ret    

00801fd8 <devsock_read>:
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801fde:	6a 00                	push   $0x0
  801fe0:	ff 75 10             	push   0x10(%ebp)
  801fe3:	ff 75 0c             	push   0xc(%ebp)
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	ff 70 0c             	push   0xc(%eax)
  801fec:	e8 ef 02 00 00       	call   8022e0 <nsipc_recv>
}
  801ff1:	c9                   	leave  
  801ff2:	c3                   	ret    

00801ff3 <fd2sockid>:
{
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ff9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ffc:	52                   	push   %edx
  801ffd:	50                   	push   %eax
  801ffe:	e8 e9 f1 ff ff       	call   8011ec <fd_lookup>
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	85 c0                	test   %eax,%eax
  802008:	78 10                	js     80201a <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80200a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200d:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  802013:	39 08                	cmp    %ecx,(%eax)
  802015:	75 05                	jne    80201c <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  802017:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    
		return -E_NOT_SUPP;
  80201c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802021:	eb f7                	jmp    80201a <fd2sockid+0x27>

00802023 <alloc_sockfd>:
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	56                   	push   %esi
  802027:	53                   	push   %ebx
  802028:	83 ec 1c             	sub    $0x1c,%esp
  80202b:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80202d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802030:	50                   	push   %eax
  802031:	e8 66 f1 ff ff       	call   80119c <fd_alloc>
  802036:	89 c3                	mov    %eax,%ebx
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	85 c0                	test   %eax,%eax
  80203d:	78 43                	js     802082 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80203f:	83 ec 04             	sub    $0x4,%esp
  802042:	68 07 04 00 00       	push   $0x407
  802047:	ff 75 f4             	push   -0xc(%ebp)
  80204a:	6a 00                	push   $0x0
  80204c:	e8 54 ec ff ff       	call   800ca5 <sys_page_alloc>
  802051:	89 c3                	mov    %eax,%ebx
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	85 c0                	test   %eax,%eax
  802058:	78 28                	js     802082 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802063:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802068:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80206f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802072:	83 ec 0c             	sub    $0xc,%esp
  802075:	50                   	push   %eax
  802076:	e8 fa f0 ff ff       	call   801175 <fd2num>
  80207b:	89 c3                	mov    %eax,%ebx
  80207d:	83 c4 10             	add    $0x10,%esp
  802080:	eb 0c                	jmp    80208e <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  802082:	83 ec 0c             	sub    $0xc,%esp
  802085:	56                   	push   %esi
  802086:	e8 e4 01 00 00       	call   80226f <nsipc_close>
		return r;
  80208b:	83 c4 10             	add    $0x10,%esp
}
  80208e:	89 d8                	mov    %ebx,%eax
  802090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    

00802097 <accept>:
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80209d:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a0:	e8 4e ff ff ff       	call   801ff3 <fd2sockid>
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	78 1b                	js     8020c4 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8020a9:	83 ec 04             	sub    $0x4,%esp
  8020ac:	ff 75 10             	push   0x10(%ebp)
  8020af:	ff 75 0c             	push   0xc(%ebp)
  8020b2:	50                   	push   %eax
  8020b3:	e8 0e 01 00 00       	call   8021c6 <nsipc_accept>
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	78 05                	js     8020c4 <accept+0x2d>
	return alloc_sockfd(r);
  8020bf:	e8 5f ff ff ff       	call   802023 <alloc_sockfd>
}
  8020c4:	c9                   	leave  
  8020c5:	c3                   	ret    

008020c6 <bind>:
{
  8020c6:	55                   	push   %ebp
  8020c7:	89 e5                	mov    %esp,%ebp
  8020c9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8020cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cf:	e8 1f ff ff ff       	call   801ff3 <fd2sockid>
  8020d4:	85 c0                	test   %eax,%eax
  8020d6:	78 12                	js     8020ea <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8020d8:	83 ec 04             	sub    $0x4,%esp
  8020db:	ff 75 10             	push   0x10(%ebp)
  8020de:	ff 75 0c             	push   0xc(%ebp)
  8020e1:	50                   	push   %eax
  8020e2:	e8 31 01 00 00       	call   802218 <nsipc_bind>
  8020e7:	83 c4 10             	add    $0x10,%esp
}
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    

008020ec <shutdown>:
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8020f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f5:	e8 f9 fe ff ff       	call   801ff3 <fd2sockid>
  8020fa:	85 c0                	test   %eax,%eax
  8020fc:	78 0f                	js     80210d <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8020fe:	83 ec 08             	sub    $0x8,%esp
  802101:	ff 75 0c             	push   0xc(%ebp)
  802104:	50                   	push   %eax
  802105:	e8 43 01 00 00       	call   80224d <nsipc_shutdown>
  80210a:	83 c4 10             	add    $0x10,%esp
}
  80210d:	c9                   	leave  
  80210e:	c3                   	ret    

0080210f <connect>:
{
  80210f:	55                   	push   %ebp
  802110:	89 e5                	mov    %esp,%ebp
  802112:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802115:	8b 45 08             	mov    0x8(%ebp),%eax
  802118:	e8 d6 fe ff ff       	call   801ff3 <fd2sockid>
  80211d:	85 c0                	test   %eax,%eax
  80211f:	78 12                	js     802133 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  802121:	83 ec 04             	sub    $0x4,%esp
  802124:	ff 75 10             	push   0x10(%ebp)
  802127:	ff 75 0c             	push   0xc(%ebp)
  80212a:	50                   	push   %eax
  80212b:	e8 59 01 00 00       	call   802289 <nsipc_connect>
  802130:	83 c4 10             	add    $0x10,%esp
}
  802133:	c9                   	leave  
  802134:	c3                   	ret    

00802135 <listen>:
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80213b:	8b 45 08             	mov    0x8(%ebp),%eax
  80213e:	e8 b0 fe ff ff       	call   801ff3 <fd2sockid>
  802143:	85 c0                	test   %eax,%eax
  802145:	78 0f                	js     802156 <listen+0x21>
	return nsipc_listen(r, backlog);
  802147:	83 ec 08             	sub    $0x8,%esp
  80214a:	ff 75 0c             	push   0xc(%ebp)
  80214d:	50                   	push   %eax
  80214e:	e8 6b 01 00 00       	call   8022be <nsipc_listen>
  802153:	83 c4 10             	add    $0x10,%esp
}
  802156:	c9                   	leave  
  802157:	c3                   	ret    

00802158 <socket>:

int
socket(int domain, int type, int protocol)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80215e:	ff 75 10             	push   0x10(%ebp)
  802161:	ff 75 0c             	push   0xc(%ebp)
  802164:	ff 75 08             	push   0x8(%ebp)
  802167:	e8 41 02 00 00       	call   8023ad <nsipc_socket>
  80216c:	83 c4 10             	add    $0x10,%esp
  80216f:	85 c0                	test   %eax,%eax
  802171:	78 05                	js     802178 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802173:	e8 ab fe ff ff       	call   802023 <alloc_sockfd>
}
  802178:	c9                   	leave  
  802179:	c3                   	ret    

0080217a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80217a:	55                   	push   %ebp
  80217b:	89 e5                	mov    %esp,%ebp
  80217d:	53                   	push   %ebx
  80217e:	83 ec 04             	sub    $0x4,%esp
  802181:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802183:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  80218a:	74 26                	je     8021b2 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80218c:	6a 07                	push   $0x7
  80218e:	68 00 80 80 00       	push   $0x808000
  802193:	53                   	push   %ebx
  802194:	ff 35 00 90 80 00    	push   0x809000
  80219a:	e8 48 08 00 00       	call   8029e7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80219f:	83 c4 0c             	add    $0xc,%esp
  8021a2:	6a 00                	push   $0x0
  8021a4:	6a 00                	push   $0x0
  8021a6:	6a 00                	push   $0x0
  8021a8:	e8 d3 07 00 00       	call   802980 <ipc_recv>
}
  8021ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021b0:	c9                   	leave  
  8021b1:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8021b2:	83 ec 0c             	sub    $0xc,%esp
  8021b5:	6a 02                	push   $0x2
  8021b7:	e8 7f 08 00 00       	call   802a3b <ipc_find_env>
  8021bc:	a3 00 90 80 00       	mov    %eax,0x809000
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	eb c6                	jmp    80218c <nsipc+0x12>

008021c6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	56                   	push   %esi
  8021ca:	53                   	push   %ebx
  8021cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8021ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d1:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8021d6:	8b 06                	mov    (%esi),%eax
  8021d8:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8021dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e2:	e8 93 ff ff ff       	call   80217a <nsipc>
  8021e7:	89 c3                	mov    %eax,%ebx
  8021e9:	85 c0                	test   %eax,%eax
  8021eb:	79 09                	jns    8021f6 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8021ed:	89 d8                	mov    %ebx,%eax
  8021ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f2:	5b                   	pop    %ebx
  8021f3:	5e                   	pop    %esi
  8021f4:	5d                   	pop    %ebp
  8021f5:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021f6:	83 ec 04             	sub    $0x4,%esp
  8021f9:	ff 35 10 80 80 00    	push   0x808010
  8021ff:	68 00 80 80 00       	push   $0x808000
  802204:	ff 75 0c             	push   0xc(%ebp)
  802207:	e8 33 e8 ff ff       	call   800a3f <memmove>
		*addrlen = ret->ret_addrlen;
  80220c:	a1 10 80 80 00       	mov    0x808010,%eax
  802211:	89 06                	mov    %eax,(%esi)
  802213:	83 c4 10             	add    $0x10,%esp
	return r;
  802216:	eb d5                	jmp    8021ed <nsipc_accept+0x27>

00802218 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802218:	55                   	push   %ebp
  802219:	89 e5                	mov    %esp,%ebp
  80221b:	53                   	push   %ebx
  80221c:	83 ec 08             	sub    $0x8,%esp
  80221f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802222:	8b 45 08             	mov    0x8(%ebp),%eax
  802225:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80222a:	53                   	push   %ebx
  80222b:	ff 75 0c             	push   0xc(%ebp)
  80222e:	68 04 80 80 00       	push   $0x808004
  802233:	e8 07 e8 ff ff       	call   800a3f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802238:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  80223e:	b8 02 00 00 00       	mov    $0x2,%eax
  802243:	e8 32 ff ff ff       	call   80217a <nsipc>
}
  802248:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80224b:	c9                   	leave  
  80224c:	c3                   	ret    

0080224d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802253:	8b 45 08             	mov    0x8(%ebp),%eax
  802256:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  80225b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225e:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  802263:	b8 03 00 00 00       	mov    $0x3,%eax
  802268:	e8 0d ff ff ff       	call   80217a <nsipc>
}
  80226d:	c9                   	leave  
  80226e:	c3                   	ret    

0080226f <nsipc_close>:

int
nsipc_close(int s)
{
  80226f:	55                   	push   %ebp
  802270:	89 e5                	mov    %esp,%ebp
  802272:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802275:	8b 45 08             	mov    0x8(%ebp),%eax
  802278:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  80227d:	b8 04 00 00 00       	mov    $0x4,%eax
  802282:	e8 f3 fe ff ff       	call   80217a <nsipc>
}
  802287:	c9                   	leave  
  802288:	c3                   	ret    

00802289 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802289:	55                   	push   %ebp
  80228a:	89 e5                	mov    %esp,%ebp
  80228c:	53                   	push   %ebx
  80228d:	83 ec 08             	sub    $0x8,%esp
  802290:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802293:	8b 45 08             	mov    0x8(%ebp),%eax
  802296:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80229b:	53                   	push   %ebx
  80229c:	ff 75 0c             	push   0xc(%ebp)
  80229f:	68 04 80 80 00       	push   $0x808004
  8022a4:	e8 96 e7 ff ff       	call   800a3f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8022a9:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  8022af:	b8 05 00 00 00       	mov    $0x5,%eax
  8022b4:	e8 c1 fe ff ff       	call   80217a <nsipc>
}
  8022b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022bc:	c9                   	leave  
  8022bd:	c3                   	ret    

008022be <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8022be:	55                   	push   %ebp
  8022bf:	89 e5                	mov    %esp,%ebp
  8022c1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c7:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  8022cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022cf:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  8022d4:	b8 06 00 00 00       	mov    $0x6,%eax
  8022d9:	e8 9c fe ff ff       	call   80217a <nsipc>
}
  8022de:	c9                   	leave  
  8022df:	c3                   	ret    

008022e0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
  8022e3:	56                   	push   %esi
  8022e4:	53                   	push   %ebx
  8022e5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022eb:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  8022f0:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  8022f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8022f9:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022fe:	b8 07 00 00 00       	mov    $0x7,%eax
  802303:	e8 72 fe ff ff       	call   80217a <nsipc>
  802308:	89 c3                	mov    %eax,%ebx
  80230a:	85 c0                	test   %eax,%eax
  80230c:	78 22                	js     802330 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  80230e:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802313:	39 c6                	cmp    %eax,%esi
  802315:	0f 4e c6             	cmovle %esi,%eax
  802318:	39 c3                	cmp    %eax,%ebx
  80231a:	7f 1d                	jg     802339 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80231c:	83 ec 04             	sub    $0x4,%esp
  80231f:	53                   	push   %ebx
  802320:	68 00 80 80 00       	push   $0x808000
  802325:	ff 75 0c             	push   0xc(%ebp)
  802328:	e8 12 e7 ff ff       	call   800a3f <memmove>
  80232d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802330:	89 d8                	mov    %ebx,%eax
  802332:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802335:	5b                   	pop    %ebx
  802336:	5e                   	pop    %esi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
		assert(r < 1600 && r <= len);
  802339:	68 5a 33 80 00       	push   $0x80335a
  80233e:	68 6f 32 80 00       	push   $0x80326f
  802343:	6a 62                	push   $0x62
  802345:	68 6f 33 80 00       	push   $0x80336f
  80234a:	e8 a5 de ff ff       	call   8001f4 <_panic>

0080234f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80234f:	55                   	push   %ebp
  802350:	89 e5                	mov    %esp,%ebp
  802352:	53                   	push   %ebx
  802353:	83 ec 04             	sub    $0x4,%esp
  802356:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802359:	8b 45 08             	mov    0x8(%ebp),%eax
  80235c:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  802361:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802367:	7f 2e                	jg     802397 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802369:	83 ec 04             	sub    $0x4,%esp
  80236c:	53                   	push   %ebx
  80236d:	ff 75 0c             	push   0xc(%ebp)
  802370:	68 0c 80 80 00       	push   $0x80800c
  802375:	e8 c5 e6 ff ff       	call   800a3f <memmove>
	nsipcbuf.send.req_size = size;
  80237a:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  802380:	8b 45 14             	mov    0x14(%ebp),%eax
  802383:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  802388:	b8 08 00 00 00       	mov    $0x8,%eax
  80238d:	e8 e8 fd ff ff       	call   80217a <nsipc>
}
  802392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802395:	c9                   	leave  
  802396:	c3                   	ret    
	assert(size < 1600);
  802397:	68 7b 33 80 00       	push   $0x80337b
  80239c:	68 6f 32 80 00       	push   $0x80326f
  8023a1:	6a 6d                	push   $0x6d
  8023a3:	68 6f 33 80 00       	push   $0x80336f
  8023a8:	e8 47 de ff ff       	call   8001f4 <_panic>

008023ad <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8023ad:	55                   	push   %ebp
  8023ae:	89 e5                	mov    %esp,%ebp
  8023b0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b6:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  8023bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023be:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  8023c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8023c6:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  8023cb:	b8 09 00 00 00       	mov    $0x9,%eax
  8023d0:	e8 a5 fd ff ff       	call   80217a <nsipc>
}
  8023d5:	c9                   	leave  
  8023d6:	c3                   	ret    

008023d7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023d7:	55                   	push   %ebp
  8023d8:	89 e5                	mov    %esp,%ebp
  8023da:	56                   	push   %esi
  8023db:	53                   	push   %ebx
  8023dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023df:	83 ec 0c             	sub    $0xc,%esp
  8023e2:	ff 75 08             	push   0x8(%ebp)
  8023e5:	e8 9b ed ff ff       	call   801185 <fd2data>
  8023ea:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8023ec:	83 c4 08             	add    $0x8,%esp
  8023ef:	68 87 33 80 00       	push   $0x803387
  8023f4:	53                   	push   %ebx
  8023f5:	e8 af e4 ff ff       	call   8008a9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8023fa:	8b 46 04             	mov    0x4(%esi),%eax
  8023fd:	2b 06                	sub    (%esi),%eax
  8023ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802405:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80240c:	00 00 00 
	stat->st_dev = &devpipe;
  80240f:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  802416:	40 80 00 
	return 0;
}
  802419:	b8 00 00 00 00       	mov    $0x0,%eax
  80241e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802421:	5b                   	pop    %ebx
  802422:	5e                   	pop    %esi
  802423:	5d                   	pop    %ebp
  802424:	c3                   	ret    

00802425 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802425:	55                   	push   %ebp
  802426:	89 e5                	mov    %esp,%ebp
  802428:	53                   	push   %ebx
  802429:	83 ec 0c             	sub    $0xc,%esp
  80242c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80242f:	53                   	push   %ebx
  802430:	6a 00                	push   $0x0
  802432:	e8 f3 e8 ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802437:	89 1c 24             	mov    %ebx,(%esp)
  80243a:	e8 46 ed ff ff       	call   801185 <fd2data>
  80243f:	83 c4 08             	add    $0x8,%esp
  802442:	50                   	push   %eax
  802443:	6a 00                	push   $0x0
  802445:	e8 e0 e8 ff ff       	call   800d2a <sys_page_unmap>
}
  80244a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80244d:	c9                   	leave  
  80244e:	c3                   	ret    

0080244f <_pipeisclosed>:
{
  80244f:	55                   	push   %ebp
  802450:	89 e5                	mov    %esp,%ebp
  802452:	57                   	push   %edi
  802453:	56                   	push   %esi
  802454:	53                   	push   %ebx
  802455:	83 ec 1c             	sub    $0x1c,%esp
  802458:	89 c7                	mov    %eax,%edi
  80245a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80245c:	a1 00 50 80 00       	mov    0x805000,%eax
  802461:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802464:	83 ec 0c             	sub    $0xc,%esp
  802467:	57                   	push   %edi
  802468:	e8 07 06 00 00       	call   802a74 <pageref>
  80246d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802470:	89 34 24             	mov    %esi,(%esp)
  802473:	e8 fc 05 00 00       	call   802a74 <pageref>
		nn = thisenv->env_runs;
  802478:	8b 15 00 50 80 00    	mov    0x805000,%edx
  80247e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802481:	83 c4 10             	add    $0x10,%esp
  802484:	39 cb                	cmp    %ecx,%ebx
  802486:	74 1b                	je     8024a3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802488:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80248b:	75 cf                	jne    80245c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80248d:	8b 42 58             	mov    0x58(%edx),%eax
  802490:	6a 01                	push   $0x1
  802492:	50                   	push   %eax
  802493:	53                   	push   %ebx
  802494:	68 8e 33 80 00       	push   $0x80338e
  802499:	e8 31 de ff ff       	call   8002cf <cprintf>
  80249e:	83 c4 10             	add    $0x10,%esp
  8024a1:	eb b9                	jmp    80245c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8024a3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8024a6:	0f 94 c0             	sete   %al
  8024a9:	0f b6 c0             	movzbl %al,%eax
}
  8024ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024af:	5b                   	pop    %ebx
  8024b0:	5e                   	pop    %esi
  8024b1:	5f                   	pop    %edi
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    

008024b4 <devpipe_write>:
{
  8024b4:	55                   	push   %ebp
  8024b5:	89 e5                	mov    %esp,%ebp
  8024b7:	57                   	push   %edi
  8024b8:	56                   	push   %esi
  8024b9:	53                   	push   %ebx
  8024ba:	83 ec 28             	sub    $0x28,%esp
  8024bd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8024c0:	56                   	push   %esi
  8024c1:	e8 bf ec ff ff       	call   801185 <fd2data>
  8024c6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8024c8:	83 c4 10             	add    $0x10,%esp
  8024cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8024d0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8024d3:	75 09                	jne    8024de <devpipe_write+0x2a>
	return i;
  8024d5:	89 f8                	mov    %edi,%eax
  8024d7:	eb 23                	jmp    8024fc <devpipe_write+0x48>
			sys_yield();
  8024d9:	e8 a8 e7 ff ff       	call   800c86 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8024de:	8b 43 04             	mov    0x4(%ebx),%eax
  8024e1:	8b 0b                	mov    (%ebx),%ecx
  8024e3:	8d 51 20             	lea    0x20(%ecx),%edx
  8024e6:	39 d0                	cmp    %edx,%eax
  8024e8:	72 1a                	jb     802504 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8024ea:	89 da                	mov    %ebx,%edx
  8024ec:	89 f0                	mov    %esi,%eax
  8024ee:	e8 5c ff ff ff       	call   80244f <_pipeisclosed>
  8024f3:	85 c0                	test   %eax,%eax
  8024f5:	74 e2                	je     8024d9 <devpipe_write+0x25>
				return 0;
  8024f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024ff:	5b                   	pop    %ebx
  802500:	5e                   	pop    %esi
  802501:	5f                   	pop    %edi
  802502:	5d                   	pop    %ebp
  802503:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802504:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802507:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80250b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80250e:	89 c2                	mov    %eax,%edx
  802510:	c1 fa 1f             	sar    $0x1f,%edx
  802513:	89 d1                	mov    %edx,%ecx
  802515:	c1 e9 1b             	shr    $0x1b,%ecx
  802518:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80251b:	83 e2 1f             	and    $0x1f,%edx
  80251e:	29 ca                	sub    %ecx,%edx
  802520:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802524:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802528:	83 c0 01             	add    $0x1,%eax
  80252b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80252e:	83 c7 01             	add    $0x1,%edi
  802531:	eb 9d                	jmp    8024d0 <devpipe_write+0x1c>

00802533 <devpipe_read>:
{
  802533:	55                   	push   %ebp
  802534:	89 e5                	mov    %esp,%ebp
  802536:	57                   	push   %edi
  802537:	56                   	push   %esi
  802538:	53                   	push   %ebx
  802539:	83 ec 18             	sub    $0x18,%esp
  80253c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80253f:	57                   	push   %edi
  802540:	e8 40 ec ff ff       	call   801185 <fd2data>
  802545:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802547:	83 c4 10             	add    $0x10,%esp
  80254a:	be 00 00 00 00       	mov    $0x0,%esi
  80254f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802552:	75 13                	jne    802567 <devpipe_read+0x34>
	return i;
  802554:	89 f0                	mov    %esi,%eax
  802556:	eb 02                	jmp    80255a <devpipe_read+0x27>
				return i;
  802558:	89 f0                	mov    %esi,%eax
}
  80255a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5f                   	pop    %edi
  802560:	5d                   	pop    %ebp
  802561:	c3                   	ret    
			sys_yield();
  802562:	e8 1f e7 ff ff       	call   800c86 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802567:	8b 03                	mov    (%ebx),%eax
  802569:	3b 43 04             	cmp    0x4(%ebx),%eax
  80256c:	75 18                	jne    802586 <devpipe_read+0x53>
			if (i > 0)
  80256e:	85 f6                	test   %esi,%esi
  802570:	75 e6                	jne    802558 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802572:	89 da                	mov    %ebx,%edx
  802574:	89 f8                	mov    %edi,%eax
  802576:	e8 d4 fe ff ff       	call   80244f <_pipeisclosed>
  80257b:	85 c0                	test   %eax,%eax
  80257d:	74 e3                	je     802562 <devpipe_read+0x2f>
				return 0;
  80257f:	b8 00 00 00 00       	mov    $0x0,%eax
  802584:	eb d4                	jmp    80255a <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802586:	99                   	cltd   
  802587:	c1 ea 1b             	shr    $0x1b,%edx
  80258a:	01 d0                	add    %edx,%eax
  80258c:	83 e0 1f             	and    $0x1f,%eax
  80258f:	29 d0                	sub    %edx,%eax
  802591:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802596:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802599:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80259c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80259f:	83 c6 01             	add    $0x1,%esi
  8025a2:	eb ab                	jmp    80254f <devpipe_read+0x1c>

008025a4 <pipe>:
{
  8025a4:	55                   	push   %ebp
  8025a5:	89 e5                	mov    %esp,%ebp
  8025a7:	56                   	push   %esi
  8025a8:	53                   	push   %ebx
  8025a9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8025ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025af:	50                   	push   %eax
  8025b0:	e8 e7 eb ff ff       	call   80119c <fd_alloc>
  8025b5:	89 c3                	mov    %eax,%ebx
  8025b7:	83 c4 10             	add    $0x10,%esp
  8025ba:	85 c0                	test   %eax,%eax
  8025bc:	0f 88 23 01 00 00    	js     8026e5 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025c2:	83 ec 04             	sub    $0x4,%esp
  8025c5:	68 07 04 00 00       	push   $0x407
  8025ca:	ff 75 f4             	push   -0xc(%ebp)
  8025cd:	6a 00                	push   $0x0
  8025cf:	e8 d1 e6 ff ff       	call   800ca5 <sys_page_alloc>
  8025d4:	89 c3                	mov    %eax,%ebx
  8025d6:	83 c4 10             	add    $0x10,%esp
  8025d9:	85 c0                	test   %eax,%eax
  8025db:	0f 88 04 01 00 00    	js     8026e5 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8025e1:	83 ec 0c             	sub    $0xc,%esp
  8025e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8025e7:	50                   	push   %eax
  8025e8:	e8 af eb ff ff       	call   80119c <fd_alloc>
  8025ed:	89 c3                	mov    %eax,%ebx
  8025ef:	83 c4 10             	add    $0x10,%esp
  8025f2:	85 c0                	test   %eax,%eax
  8025f4:	0f 88 db 00 00 00    	js     8026d5 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025fa:	83 ec 04             	sub    $0x4,%esp
  8025fd:	68 07 04 00 00       	push   $0x407
  802602:	ff 75 f0             	push   -0x10(%ebp)
  802605:	6a 00                	push   $0x0
  802607:	e8 99 e6 ff ff       	call   800ca5 <sys_page_alloc>
  80260c:	89 c3                	mov    %eax,%ebx
  80260e:	83 c4 10             	add    $0x10,%esp
  802611:	85 c0                	test   %eax,%eax
  802613:	0f 88 bc 00 00 00    	js     8026d5 <pipe+0x131>
	va = fd2data(fd0);
  802619:	83 ec 0c             	sub    $0xc,%esp
  80261c:	ff 75 f4             	push   -0xc(%ebp)
  80261f:	e8 61 eb ff ff       	call   801185 <fd2data>
  802624:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802626:	83 c4 0c             	add    $0xc,%esp
  802629:	68 07 04 00 00       	push   $0x407
  80262e:	50                   	push   %eax
  80262f:	6a 00                	push   $0x0
  802631:	e8 6f e6 ff ff       	call   800ca5 <sys_page_alloc>
  802636:	89 c3                	mov    %eax,%ebx
  802638:	83 c4 10             	add    $0x10,%esp
  80263b:	85 c0                	test   %eax,%eax
  80263d:	0f 88 82 00 00 00    	js     8026c5 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802643:	83 ec 0c             	sub    $0xc,%esp
  802646:	ff 75 f0             	push   -0x10(%ebp)
  802649:	e8 37 eb ff ff       	call   801185 <fd2data>
  80264e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802655:	50                   	push   %eax
  802656:	6a 00                	push   $0x0
  802658:	56                   	push   %esi
  802659:	6a 00                	push   $0x0
  80265b:	e8 88 e6 ff ff       	call   800ce8 <sys_page_map>
  802660:	89 c3                	mov    %eax,%ebx
  802662:	83 c4 20             	add    $0x20,%esp
  802665:	85 c0                	test   %eax,%eax
  802667:	78 4e                	js     8026b7 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802669:	a1 44 40 80 00       	mov    0x804044,%eax
  80266e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802671:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802673:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802676:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80267d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802680:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802682:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802685:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80268c:	83 ec 0c             	sub    $0xc,%esp
  80268f:	ff 75 f4             	push   -0xc(%ebp)
  802692:	e8 de ea ff ff       	call   801175 <fd2num>
  802697:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80269a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80269c:	83 c4 04             	add    $0x4,%esp
  80269f:	ff 75 f0             	push   -0x10(%ebp)
  8026a2:	e8 ce ea ff ff       	call   801175 <fd2num>
  8026a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026aa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8026ad:	83 c4 10             	add    $0x10,%esp
  8026b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026b5:	eb 2e                	jmp    8026e5 <pipe+0x141>
	sys_page_unmap(0, va);
  8026b7:	83 ec 08             	sub    $0x8,%esp
  8026ba:	56                   	push   %esi
  8026bb:	6a 00                	push   $0x0
  8026bd:	e8 68 e6 ff ff       	call   800d2a <sys_page_unmap>
  8026c2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8026c5:	83 ec 08             	sub    $0x8,%esp
  8026c8:	ff 75 f0             	push   -0x10(%ebp)
  8026cb:	6a 00                	push   $0x0
  8026cd:	e8 58 e6 ff ff       	call   800d2a <sys_page_unmap>
  8026d2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8026d5:	83 ec 08             	sub    $0x8,%esp
  8026d8:	ff 75 f4             	push   -0xc(%ebp)
  8026db:	6a 00                	push   $0x0
  8026dd:	e8 48 e6 ff ff       	call   800d2a <sys_page_unmap>
  8026e2:	83 c4 10             	add    $0x10,%esp
}
  8026e5:	89 d8                	mov    %ebx,%eax
  8026e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026ea:	5b                   	pop    %ebx
  8026eb:	5e                   	pop    %esi
  8026ec:	5d                   	pop    %ebp
  8026ed:	c3                   	ret    

008026ee <pipeisclosed>:
{
  8026ee:	55                   	push   %ebp
  8026ef:	89 e5                	mov    %esp,%ebp
  8026f1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026f7:	50                   	push   %eax
  8026f8:	ff 75 08             	push   0x8(%ebp)
  8026fb:	e8 ec ea ff ff       	call   8011ec <fd_lookup>
  802700:	83 c4 10             	add    $0x10,%esp
  802703:	85 c0                	test   %eax,%eax
  802705:	78 18                	js     80271f <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802707:	83 ec 0c             	sub    $0xc,%esp
  80270a:	ff 75 f4             	push   -0xc(%ebp)
  80270d:	e8 73 ea ff ff       	call   801185 <fd2data>
  802712:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802717:	e8 33 fd ff ff       	call   80244f <_pipeisclosed>
  80271c:	83 c4 10             	add    $0x10,%esp
}
  80271f:	c9                   	leave  
  802720:	c3                   	ret    

00802721 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802721:	55                   	push   %ebp
  802722:	89 e5                	mov    %esp,%ebp
  802724:	56                   	push   %esi
  802725:	53                   	push   %ebx
  802726:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802729:	85 f6                	test   %esi,%esi
  80272b:	74 13                	je     802740 <wait+0x1f>
	e = &envs[ENVX(envid)];
  80272d:	89 f3                	mov    %esi,%ebx
  80272f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802735:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802738:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80273e:	eb 1b                	jmp    80275b <wait+0x3a>
	assert(envid != 0);
  802740:	68 a6 33 80 00       	push   $0x8033a6
  802745:	68 6f 32 80 00       	push   $0x80326f
  80274a:	6a 09                	push   $0x9
  80274c:	68 b1 33 80 00       	push   $0x8033b1
  802751:	e8 9e da ff ff       	call   8001f4 <_panic>
		sys_yield();
  802756:	e8 2b e5 ff ff       	call   800c86 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80275b:	8b 43 48             	mov    0x48(%ebx),%eax
  80275e:	39 f0                	cmp    %esi,%eax
  802760:	75 07                	jne    802769 <wait+0x48>
  802762:	8b 43 54             	mov    0x54(%ebx),%eax
  802765:	85 c0                	test   %eax,%eax
  802767:	75 ed                	jne    802756 <wait+0x35>
}
  802769:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80276c:	5b                   	pop    %ebx
  80276d:	5e                   	pop    %esi
  80276e:	5d                   	pop    %ebp
  80276f:	c3                   	ret    

00802770 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802770:	b8 00 00 00 00       	mov    $0x0,%eax
  802775:	c3                   	ret    

00802776 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802776:	55                   	push   %ebp
  802777:	89 e5                	mov    %esp,%ebp
  802779:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80277c:	68 bc 33 80 00       	push   $0x8033bc
  802781:	ff 75 0c             	push   0xc(%ebp)
  802784:	e8 20 e1 ff ff       	call   8008a9 <strcpy>
	return 0;
}
  802789:	b8 00 00 00 00       	mov    $0x0,%eax
  80278e:	c9                   	leave  
  80278f:	c3                   	ret    

00802790 <devcons_write>:
{
  802790:	55                   	push   %ebp
  802791:	89 e5                	mov    %esp,%ebp
  802793:	57                   	push   %edi
  802794:	56                   	push   %esi
  802795:	53                   	push   %ebx
  802796:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80279c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8027a1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8027a7:	eb 2e                	jmp    8027d7 <devcons_write+0x47>
		m = n - tot;
  8027a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027ac:	29 f3                	sub    %esi,%ebx
  8027ae:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8027b3:	39 c3                	cmp    %eax,%ebx
  8027b5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8027b8:	83 ec 04             	sub    $0x4,%esp
  8027bb:	53                   	push   %ebx
  8027bc:	89 f0                	mov    %esi,%eax
  8027be:	03 45 0c             	add    0xc(%ebp),%eax
  8027c1:	50                   	push   %eax
  8027c2:	57                   	push   %edi
  8027c3:	e8 77 e2 ff ff       	call   800a3f <memmove>
		sys_cputs(buf, m);
  8027c8:	83 c4 08             	add    $0x8,%esp
  8027cb:	53                   	push   %ebx
  8027cc:	57                   	push   %edi
  8027cd:	e8 17 e4 ff ff       	call   800be9 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8027d2:	01 de                	add    %ebx,%esi
  8027d4:	83 c4 10             	add    $0x10,%esp
  8027d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027da:	72 cd                	jb     8027a9 <devcons_write+0x19>
}
  8027dc:	89 f0                	mov    %esi,%eax
  8027de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027e1:	5b                   	pop    %ebx
  8027e2:	5e                   	pop    %esi
  8027e3:	5f                   	pop    %edi
  8027e4:	5d                   	pop    %ebp
  8027e5:	c3                   	ret    

008027e6 <devcons_read>:
{
  8027e6:	55                   	push   %ebp
  8027e7:	89 e5                	mov    %esp,%ebp
  8027e9:	83 ec 08             	sub    $0x8,%esp
  8027ec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8027f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027f5:	75 07                	jne    8027fe <devcons_read+0x18>
  8027f7:	eb 1f                	jmp    802818 <devcons_read+0x32>
		sys_yield();
  8027f9:	e8 88 e4 ff ff       	call   800c86 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8027fe:	e8 04 e4 ff ff       	call   800c07 <sys_cgetc>
  802803:	85 c0                	test   %eax,%eax
  802805:	74 f2                	je     8027f9 <devcons_read+0x13>
	if (c < 0)
  802807:	78 0f                	js     802818 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802809:	83 f8 04             	cmp    $0x4,%eax
  80280c:	74 0c                	je     80281a <devcons_read+0x34>
	*(char*)vbuf = c;
  80280e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802811:	88 02                	mov    %al,(%edx)
	return 1;
  802813:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802818:	c9                   	leave  
  802819:	c3                   	ret    
		return 0;
  80281a:	b8 00 00 00 00       	mov    $0x0,%eax
  80281f:	eb f7                	jmp    802818 <devcons_read+0x32>

00802821 <cputchar>:
{
  802821:	55                   	push   %ebp
  802822:	89 e5                	mov    %esp,%ebp
  802824:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802827:	8b 45 08             	mov    0x8(%ebp),%eax
  80282a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80282d:	6a 01                	push   $0x1
  80282f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802832:	50                   	push   %eax
  802833:	e8 b1 e3 ff ff       	call   800be9 <sys_cputs>
}
  802838:	83 c4 10             	add    $0x10,%esp
  80283b:	c9                   	leave  
  80283c:	c3                   	ret    

0080283d <getchar>:
{
  80283d:	55                   	push   %ebp
  80283e:	89 e5                	mov    %esp,%ebp
  802840:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802843:	6a 01                	push   $0x1
  802845:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802848:	50                   	push   %eax
  802849:	6a 00                	push   $0x0
  80284b:	e8 05 ec ff ff       	call   801455 <read>
	if (r < 0)
  802850:	83 c4 10             	add    $0x10,%esp
  802853:	85 c0                	test   %eax,%eax
  802855:	78 06                	js     80285d <getchar+0x20>
	if (r < 1)
  802857:	74 06                	je     80285f <getchar+0x22>
	return c;
  802859:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80285d:	c9                   	leave  
  80285e:	c3                   	ret    
		return -E_EOF;
  80285f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802864:	eb f7                	jmp    80285d <getchar+0x20>

00802866 <iscons>:
{
  802866:	55                   	push   %ebp
  802867:	89 e5                	mov    %esp,%ebp
  802869:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80286c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80286f:	50                   	push   %eax
  802870:	ff 75 08             	push   0x8(%ebp)
  802873:	e8 74 e9 ff ff       	call   8011ec <fd_lookup>
  802878:	83 c4 10             	add    $0x10,%esp
  80287b:	85 c0                	test   %eax,%eax
  80287d:	78 11                	js     802890 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80287f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802882:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802888:	39 10                	cmp    %edx,(%eax)
  80288a:	0f 94 c0             	sete   %al
  80288d:	0f b6 c0             	movzbl %al,%eax
}
  802890:	c9                   	leave  
  802891:	c3                   	ret    

00802892 <opencons>:
{
  802892:	55                   	push   %ebp
  802893:	89 e5                	mov    %esp,%ebp
  802895:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802898:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80289b:	50                   	push   %eax
  80289c:	e8 fb e8 ff ff       	call   80119c <fd_alloc>
  8028a1:	83 c4 10             	add    $0x10,%esp
  8028a4:	85 c0                	test   %eax,%eax
  8028a6:	78 3a                	js     8028e2 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028a8:	83 ec 04             	sub    $0x4,%esp
  8028ab:	68 07 04 00 00       	push   $0x407
  8028b0:	ff 75 f4             	push   -0xc(%ebp)
  8028b3:	6a 00                	push   $0x0
  8028b5:	e8 eb e3 ff ff       	call   800ca5 <sys_page_alloc>
  8028ba:	83 c4 10             	add    $0x10,%esp
  8028bd:	85 c0                	test   %eax,%eax
  8028bf:	78 21                	js     8028e2 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8028c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028c4:	8b 15 60 40 80 00    	mov    0x804060,%edx
  8028ca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028cf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028d6:	83 ec 0c             	sub    $0xc,%esp
  8028d9:	50                   	push   %eax
  8028da:	e8 96 e8 ff ff       	call   801175 <fd2num>
  8028df:	83 c4 10             	add    $0x10,%esp
}
  8028e2:	c9                   	leave  
  8028e3:	c3                   	ret    

008028e4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028e4:	55                   	push   %ebp
  8028e5:	89 e5                	mov    %esp,%ebp
  8028e7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8028ea:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  8028f1:	74 0a                	je     8028fd <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8028f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8028f6:	a3 04 90 80 00       	mov    %eax,0x809004
}
  8028fb:	c9                   	leave  
  8028fc:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8028fd:	e8 65 e3 ff ff       	call   800c67 <sys_getenvid>
  802902:	83 ec 04             	sub    $0x4,%esp
  802905:	68 07 0e 00 00       	push   $0xe07
  80290a:	68 00 f0 bf ee       	push   $0xeebff000
  80290f:	50                   	push   %eax
  802910:	e8 90 e3 ff ff       	call   800ca5 <sys_page_alloc>
		if (r < 0) {
  802915:	83 c4 10             	add    $0x10,%esp
  802918:	85 c0                	test   %eax,%eax
  80291a:	78 2c                	js     802948 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80291c:	e8 46 e3 ff ff       	call   800c67 <sys_getenvid>
  802921:	83 ec 08             	sub    $0x8,%esp
  802924:	68 5a 29 80 00       	push   $0x80295a
  802929:	50                   	push   %eax
  80292a:	e8 c1 e4 ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80292f:	83 c4 10             	add    $0x10,%esp
  802932:	85 c0                	test   %eax,%eax
  802934:	79 bd                	jns    8028f3 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802936:	50                   	push   %eax
  802937:	68 08 34 80 00       	push   $0x803408
  80293c:	6a 28                	push   $0x28
  80293e:	68 3e 34 80 00       	push   $0x80343e
  802943:	e8 ac d8 ff ff       	call   8001f4 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802948:	50                   	push   %eax
  802949:	68 c8 33 80 00       	push   $0x8033c8
  80294e:	6a 23                	push   $0x23
  802950:	68 3e 34 80 00       	push   $0x80343e
  802955:	e8 9a d8 ff ff       	call   8001f4 <_panic>

0080295a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80295a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80295b:	a1 04 90 80 00       	mov    0x809004,%eax
	call *%eax
  802960:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802962:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802965:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802969:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80296c:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802970:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802974:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802976:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802979:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80297a:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80297d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80297e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80297f:	c3                   	ret    

00802980 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802980:	55                   	push   %ebp
  802981:	89 e5                	mov    %esp,%ebp
  802983:	56                   	push   %esi
  802984:	53                   	push   %ebx
  802985:	8b 75 08             	mov    0x8(%ebp),%esi
  802988:	8b 45 0c             	mov    0xc(%ebp),%eax
  80298b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80298e:	85 c0                	test   %eax,%eax
  802990:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802995:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802998:	83 ec 0c             	sub    $0xc,%esp
  80299b:	50                   	push   %eax
  80299c:	e8 b4 e4 ff ff       	call   800e55 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8029a1:	83 c4 10             	add    $0x10,%esp
  8029a4:	85 f6                	test   %esi,%esi
  8029a6:	74 14                	je     8029bc <ipc_recv+0x3c>
  8029a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8029ad:	85 c0                	test   %eax,%eax
  8029af:	78 09                	js     8029ba <ipc_recv+0x3a>
  8029b1:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8029b7:	8b 52 74             	mov    0x74(%edx),%edx
  8029ba:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8029bc:	85 db                	test   %ebx,%ebx
  8029be:	74 14                	je     8029d4 <ipc_recv+0x54>
  8029c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8029c5:	85 c0                	test   %eax,%eax
  8029c7:	78 09                	js     8029d2 <ipc_recv+0x52>
  8029c9:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8029cf:	8b 52 78             	mov    0x78(%edx),%edx
  8029d2:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8029d4:	85 c0                	test   %eax,%eax
  8029d6:	78 08                	js     8029e0 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8029d8:	a1 00 50 80 00       	mov    0x805000,%eax
  8029dd:	8b 40 70             	mov    0x70(%eax),%eax
}
  8029e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029e3:	5b                   	pop    %ebx
  8029e4:	5e                   	pop    %esi
  8029e5:	5d                   	pop    %ebp
  8029e6:	c3                   	ret    

008029e7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029e7:	55                   	push   %ebp
  8029e8:	89 e5                	mov    %esp,%ebp
  8029ea:	57                   	push   %edi
  8029eb:	56                   	push   %esi
  8029ec:	53                   	push   %ebx
  8029ed:	83 ec 0c             	sub    $0xc,%esp
  8029f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8029f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8029f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8029f9:	85 db                	test   %ebx,%ebx
  8029fb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802a00:	0f 44 d8             	cmove  %eax,%ebx
  802a03:	eb 05                	jmp    802a0a <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802a05:	e8 7c e2 ff ff       	call   800c86 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802a0a:	ff 75 14             	push   0x14(%ebp)
  802a0d:	53                   	push   %ebx
  802a0e:	56                   	push   %esi
  802a0f:	57                   	push   %edi
  802a10:	e8 1d e4 ff ff       	call   800e32 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802a15:	83 c4 10             	add    $0x10,%esp
  802a18:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a1b:	74 e8                	je     802a05 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802a1d:	85 c0                	test   %eax,%eax
  802a1f:	78 08                	js     802a29 <ipc_send+0x42>
	}while (r<0);

}
  802a21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a24:	5b                   	pop    %ebx
  802a25:	5e                   	pop    %esi
  802a26:	5f                   	pop    %edi
  802a27:	5d                   	pop    %ebp
  802a28:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802a29:	50                   	push   %eax
  802a2a:	68 4c 34 80 00       	push   $0x80344c
  802a2f:	6a 3d                	push   $0x3d
  802a31:	68 60 34 80 00       	push   $0x803460
  802a36:	e8 b9 d7 ff ff       	call   8001f4 <_panic>

00802a3b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a3b:	55                   	push   %ebp
  802a3c:	89 e5                	mov    %esp,%ebp
  802a3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a41:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a46:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a49:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a4f:	8b 52 50             	mov    0x50(%edx),%edx
  802a52:	39 ca                	cmp    %ecx,%edx
  802a54:	74 11                	je     802a67 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802a56:	83 c0 01             	add    $0x1,%eax
  802a59:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a5e:	75 e6                	jne    802a46 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802a60:	b8 00 00 00 00       	mov    $0x0,%eax
  802a65:	eb 0b                	jmp    802a72 <ipc_find_env+0x37>
			return envs[i].env_id;
  802a67:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a6a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a6f:	8b 40 48             	mov    0x48(%eax),%eax
}
  802a72:	5d                   	pop    %ebp
  802a73:	c3                   	ret    

00802a74 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a74:	55                   	push   %ebp
  802a75:	89 e5                	mov    %esp,%ebp
  802a77:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a7a:	89 c2                	mov    %eax,%edx
  802a7c:	c1 ea 16             	shr    $0x16,%edx
  802a7f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802a86:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802a8b:	f6 c1 01             	test   $0x1,%cl
  802a8e:	74 1c                	je     802aac <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802a90:	c1 e8 0c             	shr    $0xc,%eax
  802a93:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802a9a:	a8 01                	test   $0x1,%al
  802a9c:	74 0e                	je     802aac <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a9e:	c1 e8 0c             	shr    $0xc,%eax
  802aa1:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802aa8:	ef 
  802aa9:	0f b7 d2             	movzwl %dx,%edx
}
  802aac:	89 d0                	mov    %edx,%eax
  802aae:	5d                   	pop    %ebp
  802aaf:	c3                   	ret    

00802ab0 <__udivdi3>:
  802ab0:	f3 0f 1e fb          	endbr32 
  802ab4:	55                   	push   %ebp
  802ab5:	57                   	push   %edi
  802ab6:	56                   	push   %esi
  802ab7:	53                   	push   %ebx
  802ab8:	83 ec 1c             	sub    $0x1c,%esp
  802abb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802abf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802ac3:	8b 74 24 34          	mov    0x34(%esp),%esi
  802ac7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802acb:	85 c0                	test   %eax,%eax
  802acd:	75 19                	jne    802ae8 <__udivdi3+0x38>
  802acf:	39 f3                	cmp    %esi,%ebx
  802ad1:	76 4d                	jbe    802b20 <__udivdi3+0x70>
  802ad3:	31 ff                	xor    %edi,%edi
  802ad5:	89 e8                	mov    %ebp,%eax
  802ad7:	89 f2                	mov    %esi,%edx
  802ad9:	f7 f3                	div    %ebx
  802adb:	89 fa                	mov    %edi,%edx
  802add:	83 c4 1c             	add    $0x1c,%esp
  802ae0:	5b                   	pop    %ebx
  802ae1:	5e                   	pop    %esi
  802ae2:	5f                   	pop    %edi
  802ae3:	5d                   	pop    %ebp
  802ae4:	c3                   	ret    
  802ae5:	8d 76 00             	lea    0x0(%esi),%esi
  802ae8:	39 f0                	cmp    %esi,%eax
  802aea:	76 14                	jbe    802b00 <__udivdi3+0x50>
  802aec:	31 ff                	xor    %edi,%edi
  802aee:	31 c0                	xor    %eax,%eax
  802af0:	89 fa                	mov    %edi,%edx
  802af2:	83 c4 1c             	add    $0x1c,%esp
  802af5:	5b                   	pop    %ebx
  802af6:	5e                   	pop    %esi
  802af7:	5f                   	pop    %edi
  802af8:	5d                   	pop    %ebp
  802af9:	c3                   	ret    
  802afa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b00:	0f bd f8             	bsr    %eax,%edi
  802b03:	83 f7 1f             	xor    $0x1f,%edi
  802b06:	75 48                	jne    802b50 <__udivdi3+0xa0>
  802b08:	39 f0                	cmp    %esi,%eax
  802b0a:	72 06                	jb     802b12 <__udivdi3+0x62>
  802b0c:	31 c0                	xor    %eax,%eax
  802b0e:	39 eb                	cmp    %ebp,%ebx
  802b10:	77 de                	ja     802af0 <__udivdi3+0x40>
  802b12:	b8 01 00 00 00       	mov    $0x1,%eax
  802b17:	eb d7                	jmp    802af0 <__udivdi3+0x40>
  802b19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b20:	89 d9                	mov    %ebx,%ecx
  802b22:	85 db                	test   %ebx,%ebx
  802b24:	75 0b                	jne    802b31 <__udivdi3+0x81>
  802b26:	b8 01 00 00 00       	mov    $0x1,%eax
  802b2b:	31 d2                	xor    %edx,%edx
  802b2d:	f7 f3                	div    %ebx
  802b2f:	89 c1                	mov    %eax,%ecx
  802b31:	31 d2                	xor    %edx,%edx
  802b33:	89 f0                	mov    %esi,%eax
  802b35:	f7 f1                	div    %ecx
  802b37:	89 c6                	mov    %eax,%esi
  802b39:	89 e8                	mov    %ebp,%eax
  802b3b:	89 f7                	mov    %esi,%edi
  802b3d:	f7 f1                	div    %ecx
  802b3f:	89 fa                	mov    %edi,%edx
  802b41:	83 c4 1c             	add    $0x1c,%esp
  802b44:	5b                   	pop    %ebx
  802b45:	5e                   	pop    %esi
  802b46:	5f                   	pop    %edi
  802b47:	5d                   	pop    %ebp
  802b48:	c3                   	ret    
  802b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b50:	89 f9                	mov    %edi,%ecx
  802b52:	ba 20 00 00 00       	mov    $0x20,%edx
  802b57:	29 fa                	sub    %edi,%edx
  802b59:	d3 e0                	shl    %cl,%eax
  802b5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b5f:	89 d1                	mov    %edx,%ecx
  802b61:	89 d8                	mov    %ebx,%eax
  802b63:	d3 e8                	shr    %cl,%eax
  802b65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802b69:	09 c1                	or     %eax,%ecx
  802b6b:	89 f0                	mov    %esi,%eax
  802b6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b71:	89 f9                	mov    %edi,%ecx
  802b73:	d3 e3                	shl    %cl,%ebx
  802b75:	89 d1                	mov    %edx,%ecx
  802b77:	d3 e8                	shr    %cl,%eax
  802b79:	89 f9                	mov    %edi,%ecx
  802b7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802b7f:	89 eb                	mov    %ebp,%ebx
  802b81:	d3 e6                	shl    %cl,%esi
  802b83:	89 d1                	mov    %edx,%ecx
  802b85:	d3 eb                	shr    %cl,%ebx
  802b87:	09 f3                	or     %esi,%ebx
  802b89:	89 c6                	mov    %eax,%esi
  802b8b:	89 f2                	mov    %esi,%edx
  802b8d:	89 d8                	mov    %ebx,%eax
  802b8f:	f7 74 24 08          	divl   0x8(%esp)
  802b93:	89 d6                	mov    %edx,%esi
  802b95:	89 c3                	mov    %eax,%ebx
  802b97:	f7 64 24 0c          	mull   0xc(%esp)
  802b9b:	39 d6                	cmp    %edx,%esi
  802b9d:	72 19                	jb     802bb8 <__udivdi3+0x108>
  802b9f:	89 f9                	mov    %edi,%ecx
  802ba1:	d3 e5                	shl    %cl,%ebp
  802ba3:	39 c5                	cmp    %eax,%ebp
  802ba5:	73 04                	jae    802bab <__udivdi3+0xfb>
  802ba7:	39 d6                	cmp    %edx,%esi
  802ba9:	74 0d                	je     802bb8 <__udivdi3+0x108>
  802bab:	89 d8                	mov    %ebx,%eax
  802bad:	31 ff                	xor    %edi,%edi
  802baf:	e9 3c ff ff ff       	jmp    802af0 <__udivdi3+0x40>
  802bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bb8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802bbb:	31 ff                	xor    %edi,%edi
  802bbd:	e9 2e ff ff ff       	jmp    802af0 <__udivdi3+0x40>
  802bc2:	66 90                	xchg   %ax,%ax
  802bc4:	66 90                	xchg   %ax,%ax
  802bc6:	66 90                	xchg   %ax,%ax
  802bc8:	66 90                	xchg   %ax,%ax
  802bca:	66 90                	xchg   %ax,%ax
  802bcc:	66 90                	xchg   %ax,%ax
  802bce:	66 90                	xchg   %ax,%ax

00802bd0 <__umoddi3>:
  802bd0:	f3 0f 1e fb          	endbr32 
  802bd4:	55                   	push   %ebp
  802bd5:	57                   	push   %edi
  802bd6:	56                   	push   %esi
  802bd7:	53                   	push   %ebx
  802bd8:	83 ec 1c             	sub    $0x1c,%esp
  802bdb:	8b 74 24 30          	mov    0x30(%esp),%esi
  802bdf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802be3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802be7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  802beb:	89 f0                	mov    %esi,%eax
  802bed:	89 da                	mov    %ebx,%edx
  802bef:	85 ff                	test   %edi,%edi
  802bf1:	75 15                	jne    802c08 <__umoddi3+0x38>
  802bf3:	39 dd                	cmp    %ebx,%ebp
  802bf5:	76 39                	jbe    802c30 <__umoddi3+0x60>
  802bf7:	f7 f5                	div    %ebp
  802bf9:	89 d0                	mov    %edx,%eax
  802bfb:	31 d2                	xor    %edx,%edx
  802bfd:	83 c4 1c             	add    $0x1c,%esp
  802c00:	5b                   	pop    %ebx
  802c01:	5e                   	pop    %esi
  802c02:	5f                   	pop    %edi
  802c03:	5d                   	pop    %ebp
  802c04:	c3                   	ret    
  802c05:	8d 76 00             	lea    0x0(%esi),%esi
  802c08:	39 df                	cmp    %ebx,%edi
  802c0a:	77 f1                	ja     802bfd <__umoddi3+0x2d>
  802c0c:	0f bd cf             	bsr    %edi,%ecx
  802c0f:	83 f1 1f             	xor    $0x1f,%ecx
  802c12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802c16:	75 40                	jne    802c58 <__umoddi3+0x88>
  802c18:	39 df                	cmp    %ebx,%edi
  802c1a:	72 04                	jb     802c20 <__umoddi3+0x50>
  802c1c:	39 f5                	cmp    %esi,%ebp
  802c1e:	77 dd                	ja     802bfd <__umoddi3+0x2d>
  802c20:	89 da                	mov    %ebx,%edx
  802c22:	89 f0                	mov    %esi,%eax
  802c24:	29 e8                	sub    %ebp,%eax
  802c26:	19 fa                	sbb    %edi,%edx
  802c28:	eb d3                	jmp    802bfd <__umoddi3+0x2d>
  802c2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c30:	89 e9                	mov    %ebp,%ecx
  802c32:	85 ed                	test   %ebp,%ebp
  802c34:	75 0b                	jne    802c41 <__umoddi3+0x71>
  802c36:	b8 01 00 00 00       	mov    $0x1,%eax
  802c3b:	31 d2                	xor    %edx,%edx
  802c3d:	f7 f5                	div    %ebp
  802c3f:	89 c1                	mov    %eax,%ecx
  802c41:	89 d8                	mov    %ebx,%eax
  802c43:	31 d2                	xor    %edx,%edx
  802c45:	f7 f1                	div    %ecx
  802c47:	89 f0                	mov    %esi,%eax
  802c49:	f7 f1                	div    %ecx
  802c4b:	89 d0                	mov    %edx,%eax
  802c4d:	31 d2                	xor    %edx,%edx
  802c4f:	eb ac                	jmp    802bfd <__umoddi3+0x2d>
  802c51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c58:	8b 44 24 04          	mov    0x4(%esp),%eax
  802c5c:	ba 20 00 00 00       	mov    $0x20,%edx
  802c61:	29 c2                	sub    %eax,%edx
  802c63:	89 c1                	mov    %eax,%ecx
  802c65:	89 e8                	mov    %ebp,%eax
  802c67:	d3 e7                	shl    %cl,%edi
  802c69:	89 d1                	mov    %edx,%ecx
  802c6b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802c6f:	d3 e8                	shr    %cl,%eax
  802c71:	89 c1                	mov    %eax,%ecx
  802c73:	8b 44 24 04          	mov    0x4(%esp),%eax
  802c77:	09 f9                	or     %edi,%ecx
  802c79:	89 df                	mov    %ebx,%edi
  802c7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c7f:	89 c1                	mov    %eax,%ecx
  802c81:	d3 e5                	shl    %cl,%ebp
  802c83:	89 d1                	mov    %edx,%ecx
  802c85:	d3 ef                	shr    %cl,%edi
  802c87:	89 c1                	mov    %eax,%ecx
  802c89:	89 f0                	mov    %esi,%eax
  802c8b:	d3 e3                	shl    %cl,%ebx
  802c8d:	89 d1                	mov    %edx,%ecx
  802c8f:	89 fa                	mov    %edi,%edx
  802c91:	d3 e8                	shr    %cl,%eax
  802c93:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802c98:	09 d8                	or     %ebx,%eax
  802c9a:	f7 74 24 08          	divl   0x8(%esp)
  802c9e:	89 d3                	mov    %edx,%ebx
  802ca0:	d3 e6                	shl    %cl,%esi
  802ca2:	f7 e5                	mul    %ebp
  802ca4:	89 c7                	mov    %eax,%edi
  802ca6:	89 d1                	mov    %edx,%ecx
  802ca8:	39 d3                	cmp    %edx,%ebx
  802caa:	72 06                	jb     802cb2 <__umoddi3+0xe2>
  802cac:	75 0e                	jne    802cbc <__umoddi3+0xec>
  802cae:	39 c6                	cmp    %eax,%esi
  802cb0:	73 0a                	jae    802cbc <__umoddi3+0xec>
  802cb2:	29 e8                	sub    %ebp,%eax
  802cb4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802cb8:	89 d1                	mov    %edx,%ecx
  802cba:	89 c7                	mov    %eax,%edi
  802cbc:	89 f5                	mov    %esi,%ebp
  802cbe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802cc2:	29 fd                	sub    %edi,%ebp
  802cc4:	19 cb                	sbb    %ecx,%ebx
  802cc6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802ccb:	89 d8                	mov    %ebx,%eax
  802ccd:	d3 e0                	shl    %cl,%eax
  802ccf:	89 f1                	mov    %esi,%ecx
  802cd1:	d3 ed                	shr    %cl,%ebp
  802cd3:	d3 eb                	shr    %cl,%ebx
  802cd5:	09 e8                	or     %ebp,%eax
  802cd7:	89 da                	mov    %ebx,%edx
  802cd9:	83 c4 1c             	add    $0x1c,%esp
  802cdc:	5b                   	pop    %ebx
  802cdd:	5e                   	pop    %esi
  802cde:	5f                   	pop    %edi
  802cdf:	5d                   	pop    %ebp
  802ce0:	c3                   	ret    
