
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
  800039:	ff 35 00 30 80 00    	push   0x803000
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
  800083:	e8 0c 0f 00 00       	call   800f94 <fork>
  800088:	89 c3                	mov    %eax,%ebx
  80008a:	85 c0                	test   %eax,%eax
  80008c:	0f 88 be 00 00 00    	js     800150 <umain+0xfd>
	if (r == 0) {
  800092:	0f 84 ca 00 00 00    	je     800162 <umain+0x10f>
	wait(r);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	53                   	push   %ebx
  80009c:	e8 b2 21 00 00       	call   802253 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	ff 35 04 30 80 00    	push   0x803004
  8000aa:	68 00 00 00 a0       	push   $0xa0000000
  8000af:	e8 a6 08 00 00       	call   80095a <strcmp>
  8000b4:	83 c4 08             	add    $0x8,%esp
  8000b7:	85 c0                	test   %eax,%eax
  8000b9:	b8 40 28 80 00       	mov    $0x802840,%eax
  8000be:	ba 46 28 80 00       	mov    $0x802846,%edx
  8000c3:	0f 45 c2             	cmovne %edx,%eax
  8000c6:	50                   	push   %eax
  8000c7:	68 73 28 80 00       	push   $0x802873
  8000cc:	e8 fe 01 00 00       	call   8002cf <cprintf>
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  8000d1:	6a 00                	push   $0x0
  8000d3:	68 8e 28 80 00       	push   $0x80288e
  8000d8:	68 93 28 80 00       	push   $0x802893
  8000dd:	68 92 28 80 00       	push   $0x802892
  8000e2:	e8 7d 1d 00 00       	call   801e64 <spawnl>
  8000e7:	83 c4 20             	add    $0x20,%esp
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	0f 88 90 00 00 00    	js     800182 <umain+0x12f>
	wait(r);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	e8 58 21 00 00       	call   802253 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  8000fb:	83 c4 08             	add    $0x8,%esp
  8000fe:	ff 35 00 30 80 00    	push   0x803000
  800104:	68 00 00 00 a0       	push   $0xa0000000
  800109:	e8 4c 08 00 00       	call   80095a <strcmp>
  80010e:	83 c4 08             	add    $0x8,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	b8 40 28 80 00       	mov    $0x802840,%eax
  800118:	ba 46 28 80 00       	mov    $0x802846,%edx
  80011d:	0f 45 c2             	cmovne %edx,%eax
  800120:	50                   	push   %eax
  800121:	68 aa 28 80 00       	push   $0x8028aa
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
  80013f:	68 4c 28 80 00       	push   $0x80284c
  800144:	6a 13                	push   $0x13
  800146:	68 5f 28 80 00       	push   $0x80285f
  80014b:	e8 a4 00 00 00       	call   8001f4 <_panic>
		panic("fork: %e", r);
  800150:	50                   	push   %eax
  800151:	68 f8 2c 80 00       	push   $0x802cf8
  800156:	6a 17                	push   $0x17
  800158:	68 5f 28 80 00       	push   $0x80285f
  80015d:	e8 92 00 00 00       	call   8001f4 <_panic>
		strcpy(VA, msg);
  800162:	83 ec 08             	sub    $0x8,%esp
  800165:	ff 35 04 30 80 00    	push   0x803004
  80016b:	68 00 00 00 a0       	push   $0xa0000000
  800170:	e8 34 07 00 00       	call   8008a9 <strcpy>
		exit();
  800175:	e8 60 00 00 00       	call   8001da <exit>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	e9 16 ff ff ff       	jmp    800098 <umain+0x45>
		panic("spawn: %e", r);
  800182:	50                   	push   %eax
  800183:	68 a0 28 80 00       	push   $0x8028a0
  800188:	6a 21                	push   $0x21
  80018a:	68 5f 28 80 00       	push   $0x80285f
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
  8001b1:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001b6:	85 db                	test   %ebx,%ebx
  8001b8:	7e 07                	jle    8001c1 <libmain+0x2d>
		binaryname = argv[0];
  8001ba:	8b 06                	mov    (%esi),%eax
  8001bc:	a3 08 30 80 00       	mov    %eax,0x803008

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
  8001e0:	e8 fb 10 00 00       	call   8012e0 <close_all>
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
  8001fc:	8b 35 08 30 80 00    	mov    0x803008,%esi
  800202:	e8 60 0a 00 00       	call   800c67 <sys_getenvid>
  800207:	83 ec 0c             	sub    $0xc,%esp
  80020a:	ff 75 0c             	push   0xc(%ebp)
  80020d:	ff 75 08             	push   0x8(%ebp)
  800210:	56                   	push   %esi
  800211:	50                   	push   %eax
  800212:	68 f0 28 80 00       	push   $0x8028f0
  800217:	e8 b3 00 00 00       	call   8002cf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	53                   	push   %ebx
  800220:	ff 75 10             	push   0x10(%ebp)
  800223:	e8 56 00 00 00       	call   80027e <vcprintf>
	cprintf("\n");
  800228:	c7 04 24 a2 2e 80 00 	movl   $0x802ea2,(%esp)
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
  800331:	e8 ba 22 00 00       	call   8025f0 <__udivdi3>
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
  80036f:	e8 9c 23 00 00       	call   802710 <__umoddi3>
  800374:	83 c4 14             	add    $0x14,%esp
  800377:	0f be 80 13 29 80 00 	movsbl 0x802913(%eax),%eax
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
  800431:	ff 24 85 60 2a 80 00 	jmp    *0x802a60(,%eax,4)
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
  8004ff:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  800506:	85 d2                	test   %edx,%edx
  800508:	74 18                	je     800522 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80050a:	52                   	push   %edx
  80050b:	68 bd 2d 80 00       	push   $0x802dbd
  800510:	53                   	push   %ebx
  800511:	56                   	push   %esi
  800512:	e8 92 fe ff ff       	call   8003a9 <printfmt>
  800517:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80051d:	e9 66 02 00 00       	jmp    800788 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800522:	50                   	push   %eax
  800523:	68 2b 29 80 00       	push   $0x80292b
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
  80054a:	b8 24 29 80 00       	mov    $0x802924,%eax
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
  800c56:	68 1f 2c 80 00       	push   $0x802c1f
  800c5b:	6a 2a                	push   $0x2a
  800c5d:	68 3c 2c 80 00       	push   $0x802c3c
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
  800cd7:	68 1f 2c 80 00       	push   $0x802c1f
  800cdc:	6a 2a                	push   $0x2a
  800cde:	68 3c 2c 80 00       	push   $0x802c3c
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
  800d19:	68 1f 2c 80 00       	push   $0x802c1f
  800d1e:	6a 2a                	push   $0x2a
  800d20:	68 3c 2c 80 00       	push   $0x802c3c
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
  800d5b:	68 1f 2c 80 00       	push   $0x802c1f
  800d60:	6a 2a                	push   $0x2a
  800d62:	68 3c 2c 80 00       	push   $0x802c3c
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
  800d9d:	68 1f 2c 80 00       	push   $0x802c1f
  800da2:	6a 2a                	push   $0x2a
  800da4:	68 3c 2c 80 00       	push   $0x802c3c
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
  800ddf:	68 1f 2c 80 00       	push   $0x802c1f
  800de4:	6a 2a                	push   $0x2a
  800de6:	68 3c 2c 80 00       	push   $0x802c3c
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
  800e21:	68 1f 2c 80 00       	push   $0x802c1f
  800e26:	6a 2a                	push   $0x2a
  800e28:	68 3c 2c 80 00       	push   $0x802c3c
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
  800e85:	68 1f 2c 80 00       	push   $0x802c1f
  800e8a:	6a 2a                	push   $0x2a
  800e8c:	68 3c 2c 80 00       	push   $0x802c3c
  800e91:	e8 5e f3 ff ff       	call   8001f4 <_panic>

00800e96 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e9e:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ea0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ea4:	0f 84 8e 00 00 00    	je     800f38 <pgfault+0xa2>
  800eaa:	89 f0                	mov    %esi,%eax
  800eac:	c1 e8 0c             	shr    $0xc,%eax
  800eaf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb6:	f6 c4 08             	test   $0x8,%ah
  800eb9:	74 7d                	je     800f38 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800ebb:	e8 a7 fd ff ff       	call   800c67 <sys_getenvid>
  800ec0:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	6a 07                	push   $0x7
  800ec7:	68 00 f0 7f 00       	push   $0x7ff000
  800ecc:	50                   	push   %eax
  800ecd:	e8 d3 fd ff ff       	call   800ca5 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800ed2:	83 c4 10             	add    $0x10,%esp
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	78 73                	js     800f4c <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800ed9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800edf:	83 ec 04             	sub    $0x4,%esp
  800ee2:	68 00 10 00 00       	push   $0x1000
  800ee7:	56                   	push   %esi
  800ee8:	68 00 f0 7f 00       	push   $0x7ff000
  800eed:	e8 4d fb ff ff       	call   800a3f <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800ef2:	83 c4 08             	add    $0x8,%esp
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	e8 2e fe ff ff       	call   800d2a <sys_page_unmap>
  800efc:	83 c4 10             	add    $0x10,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	78 5b                	js     800f5e <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	6a 07                	push   $0x7
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	68 00 f0 7f 00       	push   $0x7ff000
  800f0f:	53                   	push   %ebx
  800f10:	e8 d3 fd ff ff       	call   800ce8 <sys_page_map>
  800f15:	83 c4 20             	add    $0x20,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 54                	js     800f70 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	68 00 f0 7f 00       	push   $0x7ff000
  800f24:	53                   	push   %ebx
  800f25:	e8 00 fe ff ff       	call   800d2a <sys_page_unmap>
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 51                	js     800f82 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800f31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	68 4c 2c 80 00       	push   $0x802c4c
  800f40:	6a 1d                	push   $0x1d
  800f42:	68 c8 2c 80 00       	push   $0x802cc8
  800f47:	e8 a8 f2 ff ff       	call   8001f4 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f4c:	50                   	push   %eax
  800f4d:	68 84 2c 80 00       	push   $0x802c84
  800f52:	6a 29                	push   $0x29
  800f54:	68 c8 2c 80 00       	push   $0x802cc8
  800f59:	e8 96 f2 ff ff       	call   8001f4 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f5e:	50                   	push   %eax
  800f5f:	68 a8 2c 80 00       	push   $0x802ca8
  800f64:	6a 2e                	push   $0x2e
  800f66:	68 c8 2c 80 00       	push   $0x802cc8
  800f6b:	e8 84 f2 ff ff       	call   8001f4 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800f70:	50                   	push   %eax
  800f71:	68 d3 2c 80 00       	push   $0x802cd3
  800f76:	6a 30                	push   $0x30
  800f78:	68 c8 2c 80 00       	push   $0x802cc8
  800f7d:	e8 72 f2 ff ff       	call   8001f4 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f82:	50                   	push   %eax
  800f83:	68 a8 2c 80 00       	push   $0x802ca8
  800f88:	6a 32                	push   $0x32
  800f8a:	68 c8 2c 80 00       	push   $0x802cc8
  800f8f:	e8 60 f2 ff ff       	call   8001f4 <_panic>

00800f94 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	57                   	push   %edi
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f9d:	68 96 0e 80 00       	push   $0x800e96
  800fa2:	e8 6f 14 00 00       	call   802416 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fa7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fac:	cd 30                	int    $0x30
  800fae:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 2d                	js     800fe5 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fb8:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800fbd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fc1:	75 73                	jne    801036 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fc3:	e8 9f fc ff ff       	call   800c67 <sys_getenvid>
  800fc8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fcd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fd0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd5:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800fda:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800fdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800fe5:	50                   	push   %eax
  800fe6:	68 f1 2c 80 00       	push   $0x802cf1
  800feb:	6a 78                	push   $0x78
  800fed:	68 c8 2c 80 00       	push   $0x802cc8
  800ff2:	e8 fd f1 ff ff       	call   8001f4 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800ff7:	83 ec 0c             	sub    $0xc,%esp
  800ffa:	ff 75 e4             	push   -0x1c(%ebp)
  800ffd:	57                   	push   %edi
  800ffe:	ff 75 dc             	push   -0x24(%ebp)
  801001:	57                   	push   %edi
  801002:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801005:	56                   	push   %esi
  801006:	e8 dd fc ff ff       	call   800ce8 <sys_page_map>
	if(r<0) return r;
  80100b:	83 c4 20             	add    $0x20,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 cb                	js     800fdd <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	ff 75 e4             	push   -0x1c(%ebp)
  801018:	57                   	push   %edi
  801019:	56                   	push   %esi
  80101a:	57                   	push   %edi
  80101b:	56                   	push   %esi
  80101c:	e8 c7 fc ff ff       	call   800ce8 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801021:	83 c4 20             	add    $0x20,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	78 76                	js     80109e <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801028:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80102e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801034:	74 75                	je     8010ab <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801036:	89 d8                	mov    %ebx,%eax
  801038:	c1 e8 16             	shr    $0x16,%eax
  80103b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801042:	a8 01                	test   $0x1,%al
  801044:	74 e2                	je     801028 <fork+0x94>
  801046:	89 de                	mov    %ebx,%esi
  801048:	c1 ee 0c             	shr    $0xc,%esi
  80104b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801052:	a8 01                	test   $0x1,%al
  801054:	74 d2                	je     801028 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801056:	e8 0c fc ff ff       	call   800c67 <sys_getenvid>
  80105b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  80105e:	89 f7                	mov    %esi,%edi
  801060:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801063:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80106a:	89 c1                	mov    %eax,%ecx
  80106c:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801072:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801075:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  80107c:	f6 c6 04             	test   $0x4,%dh
  80107f:	0f 85 72 ff ff ff    	jne    800ff7 <fork+0x63>
		perm &= ~PTE_W;
  801085:	25 05 0e 00 00       	and    $0xe05,%eax
  80108a:	80 cc 08             	or     $0x8,%ah
  80108d:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801093:	0f 44 c1             	cmove  %ecx,%eax
  801096:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801099:	e9 59 ff ff ff       	jmp    800ff7 <fork+0x63>
  80109e:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a3:	0f 4f c2             	cmovg  %edx,%eax
  8010a6:	e9 32 ff ff ff       	jmp    800fdd <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  8010ab:	83 ec 04             	sub    $0x4,%esp
  8010ae:	6a 07                	push   $0x7
  8010b0:	68 00 f0 bf ee       	push   $0xeebff000
  8010b5:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010b8:	57                   	push   %edi
  8010b9:	e8 e7 fb ff ff       	call   800ca5 <sys_page_alloc>
	if(r<0) return r;
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	0f 88 14 ff ff ff    	js     800fdd <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010c9:	83 ec 08             	sub    $0x8,%esp
  8010cc:	68 8c 24 80 00       	push   $0x80248c
  8010d1:	57                   	push   %edi
  8010d2:	e8 19 fd ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	0f 88 fb fe ff ff    	js     800fdd <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010e2:	83 ec 08             	sub    $0x8,%esp
  8010e5:	6a 02                	push   $0x2
  8010e7:	57                   	push   %edi
  8010e8:	e8 7f fc ff ff       	call   800d6c <sys_env_set_status>
	if(r<0) return r;
  8010ed:	83 c4 10             	add    $0x10,%esp
	return envid;
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	0f 49 c7             	cmovns %edi,%eax
  8010f5:	e9 e3 fe ff ff       	jmp    800fdd <fork+0x49>

008010fa <sfork>:

// Challenge!
int
sfork(void)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801100:	68 01 2d 80 00       	push   $0x802d01
  801105:	68 a1 00 00 00       	push   $0xa1
  80110a:	68 c8 2c 80 00       	push   $0x802cc8
  80110f:	e8 e0 f0 ff ff       	call   8001f4 <_panic>

00801114 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801117:	8b 45 08             	mov    0x8(%ebp),%eax
  80111a:	05 00 00 00 30       	add    $0x30000000,%eax
  80111f:	c1 e8 0c             	shr    $0xc,%eax
}
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801127:	8b 45 08             	mov    0x8(%ebp),%eax
  80112a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80112f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801134:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801143:	89 c2                	mov    %eax,%edx
  801145:	c1 ea 16             	shr    $0x16,%edx
  801148:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114f:	f6 c2 01             	test   $0x1,%dl
  801152:	74 29                	je     80117d <fd_alloc+0x42>
  801154:	89 c2                	mov    %eax,%edx
  801156:	c1 ea 0c             	shr    $0xc,%edx
  801159:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801160:	f6 c2 01             	test   $0x1,%dl
  801163:	74 18                	je     80117d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801165:	05 00 10 00 00       	add    $0x1000,%eax
  80116a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80116f:	75 d2                	jne    801143 <fd_alloc+0x8>
  801171:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801176:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80117b:	eb 05                	jmp    801182 <fd_alloc+0x47>
			return 0;
  80117d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801182:	8b 55 08             	mov    0x8(%ebp),%edx
  801185:	89 02                	mov    %eax,(%edx)
}
  801187:	89 c8                	mov    %ecx,%eax
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    

0080118b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801191:	83 f8 1f             	cmp    $0x1f,%eax
  801194:	77 30                	ja     8011c6 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801196:	c1 e0 0c             	shl    $0xc,%eax
  801199:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80119e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8011a4:	f6 c2 01             	test   $0x1,%dl
  8011a7:	74 24                	je     8011cd <fd_lookup+0x42>
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	c1 ea 0c             	shr    $0xc,%edx
  8011ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b5:	f6 c2 01             	test   $0x1,%dl
  8011b8:	74 1a                	je     8011d4 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011bd:	89 02                	mov    %eax,(%edx)
	return 0;
  8011bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    
		return -E_INVAL;
  8011c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011cb:	eb f7                	jmp    8011c4 <fd_lookup+0x39>
		return -E_INVAL;
  8011cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d2:	eb f0                	jmp    8011c4 <fd_lookup+0x39>
  8011d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d9:	eb e9                	jmp    8011c4 <fd_lookup+0x39>

008011db <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	53                   	push   %ebx
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e5:	b8 94 2d 80 00       	mov    $0x802d94,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  8011ea:	bb 0c 30 80 00       	mov    $0x80300c,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8011ef:	39 13                	cmp    %edx,(%ebx)
  8011f1:	74 32                	je     801225 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  8011f3:	83 c0 04             	add    $0x4,%eax
  8011f6:	8b 18                	mov    (%eax),%ebx
  8011f8:	85 db                	test   %ebx,%ebx
  8011fa:	75 f3                	jne    8011ef <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011fc:	a1 00 40 80 00       	mov    0x804000,%eax
  801201:	8b 40 48             	mov    0x48(%eax),%eax
  801204:	83 ec 04             	sub    $0x4,%esp
  801207:	52                   	push   %edx
  801208:	50                   	push   %eax
  801209:	68 18 2d 80 00       	push   $0x802d18
  80120e:	e8 bc f0 ff ff       	call   8002cf <cprintf>
	*dev = 0;
	return -E_INVAL;
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80121b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121e:	89 1a                	mov    %ebx,(%edx)
}
  801220:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801223:	c9                   	leave  
  801224:	c3                   	ret    
			return 0;
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
  80122a:	eb ef                	jmp    80121b <dev_lookup+0x40>

0080122c <fd_close>:
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	57                   	push   %edi
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
  801232:	83 ec 24             	sub    $0x24,%esp
  801235:	8b 75 08             	mov    0x8(%ebp),%esi
  801238:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80123b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80123e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80123f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801245:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801248:	50                   	push   %eax
  801249:	e8 3d ff ff ff       	call   80118b <fd_lookup>
  80124e:	89 c3                	mov    %eax,%ebx
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 05                	js     80125c <fd_close+0x30>
	    || fd != fd2)
  801257:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80125a:	74 16                	je     801272 <fd_close+0x46>
		return (must_exist ? r : 0);
  80125c:	89 f8                	mov    %edi,%eax
  80125e:	84 c0                	test   %al,%al
  801260:	b8 00 00 00 00       	mov    $0x0,%eax
  801265:	0f 44 d8             	cmove  %eax,%ebx
}
  801268:	89 d8                	mov    %ebx,%eax
  80126a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5f                   	pop    %edi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801272:	83 ec 08             	sub    $0x8,%esp
  801275:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	ff 36                	push   (%esi)
  80127b:	e8 5b ff ff ff       	call   8011db <dev_lookup>
  801280:	89 c3                	mov    %eax,%ebx
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	78 1a                	js     8012a3 <fd_close+0x77>
		if (dev->dev_close)
  801289:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80128c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80128f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801294:	85 c0                	test   %eax,%eax
  801296:	74 0b                	je     8012a3 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	56                   	push   %esi
  80129c:	ff d0                	call   *%eax
  80129e:	89 c3                	mov    %eax,%ebx
  8012a0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012a3:	83 ec 08             	sub    $0x8,%esp
  8012a6:	56                   	push   %esi
  8012a7:	6a 00                	push   $0x0
  8012a9:	e8 7c fa ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	eb b5                	jmp    801268 <fd_close+0x3c>

008012b3 <close>:

int
close(int fdnum)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bc:	50                   	push   %eax
  8012bd:	ff 75 08             	push   0x8(%ebp)
  8012c0:	e8 c6 fe ff ff       	call   80118b <fd_lookup>
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	79 02                	jns    8012ce <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8012cc:	c9                   	leave  
  8012cd:	c3                   	ret    
		return fd_close(fd, 1);
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	6a 01                	push   $0x1
  8012d3:	ff 75 f4             	push   -0xc(%ebp)
  8012d6:	e8 51 ff ff ff       	call   80122c <fd_close>
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	eb ec                	jmp    8012cc <close+0x19>

008012e0 <close_all>:

void
close_all(void)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ec:	83 ec 0c             	sub    $0xc,%esp
  8012ef:	53                   	push   %ebx
  8012f0:	e8 be ff ff ff       	call   8012b3 <close>
	for (i = 0; i < MAXFD; i++)
  8012f5:	83 c3 01             	add    $0x1,%ebx
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	83 fb 20             	cmp    $0x20,%ebx
  8012fe:	75 ec                	jne    8012ec <close_all+0xc>
}
  801300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	57                   	push   %edi
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
  80130b:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80130e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	ff 75 08             	push   0x8(%ebp)
  801315:	e8 71 fe ff ff       	call   80118b <fd_lookup>
  80131a:	89 c3                	mov    %eax,%ebx
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 7f                	js     8013a2 <dup+0x9d>
		return r;
	close(newfdnum);
  801323:	83 ec 0c             	sub    $0xc,%esp
  801326:	ff 75 0c             	push   0xc(%ebp)
  801329:	e8 85 ff ff ff       	call   8012b3 <close>

	newfd = INDEX2FD(newfdnum);
  80132e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801331:	c1 e6 0c             	shl    $0xc,%esi
  801334:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80133a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80133d:	89 3c 24             	mov    %edi,(%esp)
  801340:	e8 df fd ff ff       	call   801124 <fd2data>
  801345:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801347:	89 34 24             	mov    %esi,(%esp)
  80134a:	e8 d5 fd ff ff       	call   801124 <fd2data>
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801355:	89 d8                	mov    %ebx,%eax
  801357:	c1 e8 16             	shr    $0x16,%eax
  80135a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801361:	a8 01                	test   $0x1,%al
  801363:	74 11                	je     801376 <dup+0x71>
  801365:	89 d8                	mov    %ebx,%eax
  801367:	c1 e8 0c             	shr    $0xc,%eax
  80136a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801371:	f6 c2 01             	test   $0x1,%dl
  801374:	75 36                	jne    8013ac <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801376:	89 f8                	mov    %edi,%eax
  801378:	c1 e8 0c             	shr    $0xc,%eax
  80137b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801382:	83 ec 0c             	sub    $0xc,%esp
  801385:	25 07 0e 00 00       	and    $0xe07,%eax
  80138a:	50                   	push   %eax
  80138b:	56                   	push   %esi
  80138c:	6a 00                	push   $0x0
  80138e:	57                   	push   %edi
  80138f:	6a 00                	push   $0x0
  801391:	e8 52 f9 ff ff       	call   800ce8 <sys_page_map>
  801396:	89 c3                	mov    %eax,%ebx
  801398:	83 c4 20             	add    $0x20,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 33                	js     8013d2 <dup+0xcd>
		goto err;

	return newfdnum;
  80139f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013a2:	89 d8                	mov    %ebx,%eax
  8013a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	5f                   	pop    %edi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 75 d4             	push   -0x2c(%ebp)
  8013bf:	6a 00                	push   $0x0
  8013c1:	53                   	push   %ebx
  8013c2:	6a 00                	push   $0x0
  8013c4:	e8 1f f9 ff ff       	call   800ce8 <sys_page_map>
  8013c9:	89 c3                	mov    %eax,%ebx
  8013cb:	83 c4 20             	add    $0x20,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	79 a4                	jns    801376 <dup+0x71>
	sys_page_unmap(0, newfd);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	56                   	push   %esi
  8013d6:	6a 00                	push   $0x0
  8013d8:	e8 4d f9 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013dd:	83 c4 08             	add    $0x8,%esp
  8013e0:	ff 75 d4             	push   -0x2c(%ebp)
  8013e3:	6a 00                	push   $0x0
  8013e5:	e8 40 f9 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	eb b3                	jmp    8013a2 <dup+0x9d>

008013ef <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 18             	sub    $0x18,%esp
  8013f7:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	56                   	push   %esi
  8013ff:	e8 87 fd ff ff       	call   80118b <fd_lookup>
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	85 c0                	test   %eax,%eax
  801409:	78 3c                	js     801447 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140b:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	ff 33                	push   (%ebx)
  801417:	e8 bf fd ff ff       	call   8011db <dev_lookup>
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 24                	js     801447 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801423:	8b 43 08             	mov    0x8(%ebx),%eax
  801426:	83 e0 03             	and    $0x3,%eax
  801429:	83 f8 01             	cmp    $0x1,%eax
  80142c:	74 20                	je     80144e <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80142e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801431:	8b 40 08             	mov    0x8(%eax),%eax
  801434:	85 c0                	test   %eax,%eax
  801436:	74 37                	je     80146f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801438:	83 ec 04             	sub    $0x4,%esp
  80143b:	ff 75 10             	push   0x10(%ebp)
  80143e:	ff 75 0c             	push   0xc(%ebp)
  801441:	53                   	push   %ebx
  801442:	ff d0                	call   *%eax
  801444:	83 c4 10             	add    $0x10,%esp
}
  801447:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144a:	5b                   	pop    %ebx
  80144b:	5e                   	pop    %esi
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80144e:	a1 00 40 80 00       	mov    0x804000,%eax
  801453:	8b 40 48             	mov    0x48(%eax),%eax
  801456:	83 ec 04             	sub    $0x4,%esp
  801459:	56                   	push   %esi
  80145a:	50                   	push   %eax
  80145b:	68 59 2d 80 00       	push   $0x802d59
  801460:	e8 6a ee ff ff       	call   8002cf <cprintf>
		return -E_INVAL;
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146d:	eb d8                	jmp    801447 <read+0x58>
		return -E_NOT_SUPP;
  80146f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801474:	eb d1                	jmp    801447 <read+0x58>

00801476 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	57                   	push   %edi
  80147a:	56                   	push   %esi
  80147b:	53                   	push   %ebx
  80147c:	83 ec 0c             	sub    $0xc,%esp
  80147f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801482:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801485:	bb 00 00 00 00       	mov    $0x0,%ebx
  80148a:	eb 02                	jmp    80148e <readn+0x18>
  80148c:	01 c3                	add    %eax,%ebx
  80148e:	39 f3                	cmp    %esi,%ebx
  801490:	73 21                	jae    8014b3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801492:	83 ec 04             	sub    $0x4,%esp
  801495:	89 f0                	mov    %esi,%eax
  801497:	29 d8                	sub    %ebx,%eax
  801499:	50                   	push   %eax
  80149a:	89 d8                	mov    %ebx,%eax
  80149c:	03 45 0c             	add    0xc(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	57                   	push   %edi
  8014a1:	e8 49 ff ff ff       	call   8013ef <read>
		if (m < 0)
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 04                	js     8014b1 <readn+0x3b>
			return m;
		if (m == 0)
  8014ad:	75 dd                	jne    80148c <readn+0x16>
  8014af:	eb 02                	jmp    8014b3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014b3:	89 d8                	mov    %ebx,%eax
  8014b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b8:	5b                   	pop    %ebx
  8014b9:	5e                   	pop    %esi
  8014ba:	5f                   	pop    %edi
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    

008014bd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	56                   	push   %esi
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 18             	sub    $0x18,%esp
  8014c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cb:	50                   	push   %eax
  8014cc:	53                   	push   %ebx
  8014cd:	e8 b9 fc ff ff       	call   80118b <fd_lookup>
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 37                	js     801510 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e2:	50                   	push   %eax
  8014e3:	ff 36                	push   (%esi)
  8014e5:	e8 f1 fc ff ff       	call   8011db <dev_lookup>
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 1f                	js     801510 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f1:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014f5:	74 20                	je     801517 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	74 37                	je     801538 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	ff 75 10             	push   0x10(%ebp)
  801507:	ff 75 0c             	push   0xc(%ebp)
  80150a:	56                   	push   %esi
  80150b:	ff d0                	call   *%eax
  80150d:	83 c4 10             	add    $0x10,%esp
}
  801510:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801513:	5b                   	pop    %ebx
  801514:	5e                   	pop    %esi
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801517:	a1 00 40 80 00       	mov    0x804000,%eax
  80151c:	8b 40 48             	mov    0x48(%eax),%eax
  80151f:	83 ec 04             	sub    $0x4,%esp
  801522:	53                   	push   %ebx
  801523:	50                   	push   %eax
  801524:	68 75 2d 80 00       	push   $0x802d75
  801529:	e8 a1 ed ff ff       	call   8002cf <cprintf>
		return -E_INVAL;
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801536:	eb d8                	jmp    801510 <write+0x53>
		return -E_NOT_SUPP;
  801538:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80153d:	eb d1                	jmp    801510 <write+0x53>

0080153f <seek>:

int
seek(int fdnum, off_t offset)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	ff 75 08             	push   0x8(%ebp)
  80154c:	e8 3a fc ff ff       	call   80118b <fd_lookup>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 0e                	js     801566 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801558:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801561:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	56                   	push   %esi
  80156c:	53                   	push   %ebx
  80156d:	83 ec 18             	sub    $0x18,%esp
  801570:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801573:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	53                   	push   %ebx
  801578:	e8 0e fc ff ff       	call   80118b <fd_lookup>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	78 34                	js     8015b8 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801584:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	ff 36                	push   (%esi)
  801590:	e8 46 fc ff ff       	call   8011db <dev_lookup>
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 1c                	js     8015b8 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015a0:	74 1d                	je     8015bf <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a5:	8b 40 18             	mov    0x18(%eax),%eax
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	74 34                	je     8015e0 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	ff 75 0c             	push   0xc(%ebp)
  8015b2:	56                   	push   %esi
  8015b3:	ff d0                	call   *%eax
  8015b5:	83 c4 10             	add    $0x10,%esp
}
  8015b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bb:	5b                   	pop    %ebx
  8015bc:	5e                   	pop    %esi
  8015bd:	5d                   	pop    %ebp
  8015be:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015bf:	a1 00 40 80 00       	mov    0x804000,%eax
  8015c4:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	50                   	push   %eax
  8015cc:	68 38 2d 80 00       	push   $0x802d38
  8015d1:	e8 f9 ec ff ff       	call   8002cf <cprintf>
		return -E_INVAL;
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015de:	eb d8                	jmp    8015b8 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8015e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015e5:	eb d1                	jmp    8015b8 <ftruncate+0x50>

008015e7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	56                   	push   %esi
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 18             	sub    $0x18,%esp
  8015ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	ff 75 08             	push   0x8(%ebp)
  8015f9:	e8 8d fb ff ff       	call   80118b <fd_lookup>
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	78 49                	js     80164e <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	ff 36                	push   (%esi)
  801611:	e8 c5 fb ff ff       	call   8011db <dev_lookup>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 31                	js     80164e <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80161d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801620:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801624:	74 2f                	je     801655 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801626:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801629:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801630:	00 00 00 
	stat->st_isdir = 0;
  801633:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80163a:	00 00 00 
	stat->st_dev = dev;
  80163d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	53                   	push   %ebx
  801647:	56                   	push   %esi
  801648:	ff 50 14             	call   *0x14(%eax)
  80164b:	83 c4 10             	add    $0x10,%esp
}
  80164e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801651:	5b                   	pop    %ebx
  801652:	5e                   	pop    %esi
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    
		return -E_NOT_SUPP;
  801655:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80165a:	eb f2                	jmp    80164e <fstat+0x67>

0080165c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	6a 00                	push   $0x0
  801666:	ff 75 08             	push   0x8(%ebp)
  801669:	e8 e4 01 00 00       	call   801852 <open>
  80166e:	89 c3                	mov    %eax,%ebx
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	78 1b                	js     801692 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801677:	83 ec 08             	sub    $0x8,%esp
  80167a:	ff 75 0c             	push   0xc(%ebp)
  80167d:	50                   	push   %eax
  80167e:	e8 64 ff ff ff       	call   8015e7 <fstat>
  801683:	89 c6                	mov    %eax,%esi
	close(fd);
  801685:	89 1c 24             	mov    %ebx,(%esp)
  801688:	e8 26 fc ff ff       	call   8012b3 <close>
	return r;
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	89 f3                	mov    %esi,%ebx
}
  801692:	89 d8                	mov    %ebx,%eax
  801694:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801697:	5b                   	pop    %ebx
  801698:	5e                   	pop    %esi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	56                   	push   %esi
  80169f:	53                   	push   %ebx
  8016a0:	89 c6                	mov    %eax,%esi
  8016a2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016ab:	74 27                	je     8016d4 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ad:	6a 07                	push   $0x7
  8016af:	68 00 50 80 00       	push   $0x805000
  8016b4:	56                   	push   %esi
  8016b5:	ff 35 00 60 80 00    	push   0x806000
  8016bb:	e8 59 0e 00 00       	call   802519 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016c0:	83 c4 0c             	add    $0xc,%esp
  8016c3:	6a 00                	push   $0x0
  8016c5:	53                   	push   %ebx
  8016c6:	6a 00                	push   $0x0
  8016c8:	e8 e5 0d 00 00       	call   8024b2 <ipc_recv>
}
  8016cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d0:	5b                   	pop    %ebx
  8016d1:	5e                   	pop    %esi
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016d4:	83 ec 0c             	sub    $0xc,%esp
  8016d7:	6a 01                	push   $0x1
  8016d9:	e8 8f 0e 00 00       	call   80256d <ipc_find_env>
  8016de:	a3 00 60 80 00       	mov    %eax,0x806000
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	eb c5                	jmp    8016ad <fsipc+0x12>

008016e8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801701:	ba 00 00 00 00       	mov    $0x0,%edx
  801706:	b8 02 00 00 00       	mov    $0x2,%eax
  80170b:	e8 8b ff ff ff       	call   80169b <fsipc>
}
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <devfile_flush>:
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	8b 40 0c             	mov    0xc(%eax),%eax
  80171e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801723:	ba 00 00 00 00       	mov    $0x0,%edx
  801728:	b8 06 00 00 00       	mov    $0x6,%eax
  80172d:	e8 69 ff ff ff       	call   80169b <fsipc>
}
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <devfile_stat>:
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	83 ec 04             	sub    $0x4,%esp
  80173b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	8b 40 0c             	mov    0xc(%eax),%eax
  801744:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	b8 05 00 00 00       	mov    $0x5,%eax
  801753:	e8 43 ff ff ff       	call   80169b <fsipc>
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 2c                	js     801788 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80175c:	83 ec 08             	sub    $0x8,%esp
  80175f:	68 00 50 80 00       	push   $0x805000
  801764:	53                   	push   %ebx
  801765:	e8 3f f1 ff ff       	call   8008a9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80176a:	a1 80 50 80 00       	mov    0x805080,%eax
  80176f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801775:	a1 84 50 80 00       	mov    0x805084,%eax
  80177a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    

0080178d <devfile_write>:
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	83 ec 0c             	sub    $0xc,%esp
  801793:	8b 45 10             	mov    0x10(%ebp),%eax
  801796:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80179b:	39 d0                	cmp    %edx,%eax
  80179d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017ac:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017b1:	50                   	push   %eax
  8017b2:	ff 75 0c             	push   0xc(%ebp)
  8017b5:	68 08 50 80 00       	push   $0x805008
  8017ba:	e8 80 f2 ff ff       	call   800a3f <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8017bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c9:	e8 cd fe ff ff       	call   80169b <fsipc>
}
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    

008017d0 <devfile_read>:
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	56                   	push   %esi
  8017d4:	53                   	push   %ebx
  8017d5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	8b 40 0c             	mov    0xc(%eax),%eax
  8017de:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017e3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8017f3:	e8 a3 fe ff ff       	call   80169b <fsipc>
  8017f8:	89 c3                	mov    %eax,%ebx
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 1f                	js     80181d <devfile_read+0x4d>
	assert(r <= n);
  8017fe:	39 f0                	cmp    %esi,%eax
  801800:	77 24                	ja     801826 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801802:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801807:	7f 33                	jg     80183c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801809:	83 ec 04             	sub    $0x4,%esp
  80180c:	50                   	push   %eax
  80180d:	68 00 50 80 00       	push   $0x805000
  801812:	ff 75 0c             	push   0xc(%ebp)
  801815:	e8 25 f2 ff ff       	call   800a3f <memmove>
	return r;
  80181a:	83 c4 10             	add    $0x10,%esp
}
  80181d:	89 d8                	mov    %ebx,%eax
  80181f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    
	assert(r <= n);
  801826:	68 a4 2d 80 00       	push   $0x802da4
  80182b:	68 ab 2d 80 00       	push   $0x802dab
  801830:	6a 7c                	push   $0x7c
  801832:	68 c0 2d 80 00       	push   $0x802dc0
  801837:	e8 b8 e9 ff ff       	call   8001f4 <_panic>
	assert(r <= PGSIZE);
  80183c:	68 cb 2d 80 00       	push   $0x802dcb
  801841:	68 ab 2d 80 00       	push   $0x802dab
  801846:	6a 7d                	push   $0x7d
  801848:	68 c0 2d 80 00       	push   $0x802dc0
  80184d:	e8 a2 e9 ff ff       	call   8001f4 <_panic>

00801852 <open>:
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	56                   	push   %esi
  801856:	53                   	push   %ebx
  801857:	83 ec 1c             	sub    $0x1c,%esp
  80185a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80185d:	56                   	push   %esi
  80185e:	e8 0b f0 ff ff       	call   80086e <strlen>
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80186b:	7f 6c                	jg     8018d9 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801873:	50                   	push   %eax
  801874:	e8 c2 f8 ff ff       	call   80113b <fd_alloc>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	85 c0                	test   %eax,%eax
  801880:	78 3c                	js     8018be <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801882:	83 ec 08             	sub    $0x8,%esp
  801885:	56                   	push   %esi
  801886:	68 00 50 80 00       	push   $0x805000
  80188b:	e8 19 f0 ff ff       	call   8008a9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801890:	8b 45 0c             	mov    0xc(%ebp),%eax
  801893:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801898:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189b:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a0:	e8 f6 fd ff ff       	call   80169b <fsipc>
  8018a5:	89 c3                	mov    %eax,%ebx
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 19                	js     8018c7 <open+0x75>
	return fd2num(fd);
  8018ae:	83 ec 0c             	sub    $0xc,%esp
  8018b1:	ff 75 f4             	push   -0xc(%ebp)
  8018b4:	e8 5b f8 ff ff       	call   801114 <fd2num>
  8018b9:	89 c3                	mov    %eax,%ebx
  8018bb:	83 c4 10             	add    $0x10,%esp
}
  8018be:	89 d8                	mov    %ebx,%eax
  8018c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    
		fd_close(fd, 0);
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	6a 00                	push   $0x0
  8018cc:	ff 75 f4             	push   -0xc(%ebp)
  8018cf:	e8 58 f9 ff ff       	call   80122c <fd_close>
		return r;
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	eb e5                	jmp    8018be <open+0x6c>
		return -E_BAD_PATH;
  8018d9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018de:	eb de                	jmp    8018be <open+0x6c>

008018e0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8018f0:	e8 a6 fd ff ff       	call   80169b <fsipc>
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	57                   	push   %edi
  8018fb:	56                   	push   %esi
  8018fc:	53                   	push   %ebx
  8018fd:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801903:	6a 00                	push   $0x0
  801905:	ff 75 08             	push   0x8(%ebp)
  801908:	e8 45 ff ff ff       	call   801852 <open>
  80190d:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	0f 88 aa 04 00 00    	js     801dc8 <spawn+0x4d1>
  80191e:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801920:	83 ec 04             	sub    $0x4,%esp
  801923:	68 00 02 00 00       	push   $0x200
  801928:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80192e:	50                   	push   %eax
  80192f:	57                   	push   %edi
  801930:	e8 41 fb ff ff       	call   801476 <readn>
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	3d 00 02 00 00       	cmp    $0x200,%eax
  80193d:	75 57                	jne    801996 <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  80193f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801946:	45 4c 46 
  801949:	75 4b                	jne    801996 <spawn+0x9f>
  80194b:	b8 07 00 00 00       	mov    $0x7,%eax
  801950:	cd 30                	int    $0x30
  801952:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801958:	85 c0                	test   %eax,%eax
  80195a:	0f 88 5c 04 00 00    	js     801dbc <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801960:	25 ff 03 00 00       	and    $0x3ff,%eax
  801965:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801968:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80196e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801974:	b9 11 00 00 00       	mov    $0x11,%ecx
  801979:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80197b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801981:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801987:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80198c:	be 00 00 00 00       	mov    $0x0,%esi
  801991:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  801994:	eb 4b                	jmp    8019e1 <spawn+0xea>
		close(fd);
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80199f:	e8 0f f9 ff ff       	call   8012b3 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019a4:	83 c4 0c             	add    $0xc,%esp
  8019a7:	68 7f 45 4c 46       	push   $0x464c457f
  8019ac:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  8019b2:	68 d7 2d 80 00       	push   $0x802dd7
  8019b7:	e8 13 e9 ff ff       	call   8002cf <cprintf>
		return -E_NOT_EXEC;
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  8019c6:	ff ff ff 
  8019c9:	e9 fa 03 00 00       	jmp    801dc8 <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	50                   	push   %eax
  8019d2:	e8 97 ee ff ff       	call   80086e <strlen>
  8019d7:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8019db:	83 c3 01             	add    $0x1,%ebx
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019e8:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	75 df                	jne    8019ce <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019ef:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8019f5:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8019fb:	b8 00 10 40 00       	mov    $0x401000,%eax
  801a00:	29 f0                	sub    %esi,%eax
  801a02:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a04:	89 c2                	mov    %eax,%edx
  801a06:	83 e2 fc             	and    $0xfffffffc,%edx
  801a09:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a10:	29 c2                	sub    %eax,%edx
  801a12:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a18:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a1b:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a20:	0f 86 14 04 00 00    	jbe    801e3a <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a26:	83 ec 04             	sub    $0x4,%esp
  801a29:	6a 07                	push   $0x7
  801a2b:	68 00 00 40 00       	push   $0x400000
  801a30:	6a 00                	push   $0x0
  801a32:	e8 6e f2 ff ff       	call   800ca5 <sys_page_alloc>
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	0f 88 fd 03 00 00    	js     801e3f <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a42:	be 00 00 00 00       	mov    $0x0,%esi
  801a47:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a50:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a56:	7e 32                	jle    801a8a <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  801a58:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a5e:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a64:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	ff 34 b3             	push   (%ebx,%esi,4)
  801a6d:	57                   	push   %edi
  801a6e:	e8 36 ee ff ff       	call   8008a9 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a73:	83 c4 04             	add    $0x4,%esp
  801a76:	ff 34 b3             	push   (%ebx,%esi,4)
  801a79:	e8 f0 ed ff ff       	call   80086e <strlen>
  801a7e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801a82:	83 c6 01             	add    $0x1,%esi
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	eb c6                	jmp    801a50 <spawn+0x159>
	}
	argv_store[argc] = 0;
  801a8a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a90:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a96:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a9d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801aa3:	0f 85 8c 00 00 00    	jne    801b35 <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801aa9:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801aaf:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801ab5:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801ab8:	89 c8                	mov    %ecx,%eax
  801aba:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801ac0:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ac3:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801ac8:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	6a 07                	push   $0x7
  801ad3:	68 00 d0 bf ee       	push   $0xeebfd000
  801ad8:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801ade:	68 00 00 40 00       	push   $0x400000
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 fe f1 ff ff       	call   800ce8 <sys_page_map>
  801aea:	89 c3                	mov    %eax,%ebx
  801aec:	83 c4 20             	add    $0x20,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	0f 88 50 03 00 00    	js     801e47 <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801af7:	83 ec 08             	sub    $0x8,%esp
  801afa:	68 00 00 40 00       	push   $0x400000
  801aff:	6a 00                	push   $0x0
  801b01:	e8 24 f2 ff ff       	call   800d2a <sys_page_unmap>
  801b06:	89 c3                	mov    %eax,%ebx
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	0f 88 34 03 00 00    	js     801e47 <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b13:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b19:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b20:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b26:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801b2d:	00 00 00 
  801b30:	e9 4e 01 00 00       	jmp    801c83 <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b35:	68 64 2e 80 00       	push   $0x802e64
  801b3a:	68 ab 2d 80 00       	push   $0x802dab
  801b3f:	68 f2 00 00 00       	push   $0xf2
  801b44:	68 f1 2d 80 00       	push   $0x802df1
  801b49:	e8 a6 e6 ff ff       	call   8001f4 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b4e:	83 ec 04             	sub    $0x4,%esp
  801b51:	6a 07                	push   $0x7
  801b53:	68 00 00 40 00       	push   $0x400000
  801b58:	6a 00                	push   $0x0
  801b5a:	e8 46 f1 ff ff       	call   800ca5 <sys_page_alloc>
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	85 c0                	test   %eax,%eax
  801b64:	0f 88 6c 02 00 00    	js     801dd6 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b6a:	83 ec 08             	sub    $0x8,%esp
  801b6d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b73:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801b79:	50                   	push   %eax
  801b7a:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801b80:	e8 ba f9 ff ff       	call   80153f <seek>
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	0f 88 4d 02 00 00    	js     801ddd <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b90:	83 ec 04             	sub    $0x4,%esp
  801b93:	89 f8                	mov    %edi,%eax
  801b95:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801b9b:	ba 00 10 00 00       	mov    $0x1000,%edx
  801ba0:	39 d0                	cmp    %edx,%eax
  801ba2:	0f 47 c2             	cmova  %edx,%eax
  801ba5:	50                   	push   %eax
  801ba6:	68 00 00 40 00       	push   $0x400000
  801bab:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801bb1:	e8 c0 f8 ff ff       	call   801476 <readn>
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	0f 88 23 02 00 00    	js     801de4 <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801bc1:	83 ec 0c             	sub    $0xc,%esp
  801bc4:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801bca:	56                   	push   %esi
  801bcb:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801bd1:	68 00 00 40 00       	push   $0x400000
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 0b f1 ff ff       	call   800ce8 <sys_page_map>
  801bdd:	83 c4 20             	add    $0x20,%esp
  801be0:	85 c0                	test   %eax,%eax
  801be2:	78 7c                	js     801c60 <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801be4:	83 ec 08             	sub    $0x8,%esp
  801be7:	68 00 00 40 00       	push   $0x400000
  801bec:	6a 00                	push   $0x0
  801bee:	e8 37 f1 ff ff       	call   800d2a <sys_page_unmap>
  801bf3:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801bf6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801bfc:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c02:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c08:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c0e:	76 65                	jbe    801c75 <spawn+0x37e>
		if (i >= filesz) {
  801c10:	39 df                	cmp    %ebx,%edi
  801c12:	0f 87 36 ff ff ff    	ja     801b4e <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801c21:	56                   	push   %esi
  801c22:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801c28:	e8 78 f0 ff ff       	call   800ca5 <sys_page_alloc>
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	85 c0                	test   %eax,%eax
  801c32:	79 c2                	jns    801bf6 <spawn+0x2ff>
  801c34:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801c36:	83 ec 0c             	sub    $0xc,%esp
  801c39:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801c3f:	e8 e2 ef ff ff       	call   800c26 <sys_env_destroy>
	close(fd);
  801c44:	83 c4 04             	add    $0x4,%esp
  801c47:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801c4d:	e8 61 f6 ff ff       	call   8012b3 <close>
	return r;
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  801c5b:	e9 68 01 00 00       	jmp    801dc8 <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  801c60:	50                   	push   %eax
  801c61:	68 fd 2d 80 00       	push   $0x802dfd
  801c66:	68 25 01 00 00       	push   $0x125
  801c6b:	68 f1 2d 80 00       	push   $0x802df1
  801c70:	e8 7f e5 ff ff       	call   8001f4 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c75:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801c7c:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801c83:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c8a:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801c90:	7e 67                	jle    801cf9 <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  801c92:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801c98:	83 39 01             	cmpl   $0x1,(%ecx)
  801c9b:	75 d8                	jne    801c75 <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c9d:	8b 41 18             	mov    0x18(%ecx),%eax
  801ca0:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ca6:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ca9:	83 f8 01             	cmp    $0x1,%eax
  801cac:	19 c0                	sbb    %eax,%eax
  801cae:	83 e0 fe             	and    $0xfffffffe,%eax
  801cb1:	83 c0 07             	add    $0x7,%eax
  801cb4:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801cba:	8b 51 04             	mov    0x4(%ecx),%edx
  801cbd:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801cc3:	8b 79 10             	mov    0x10(%ecx),%edi
  801cc6:	8b 59 14             	mov    0x14(%ecx),%ebx
  801cc9:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801ccf:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  801cd2:	89 f0                	mov    %esi,%eax
  801cd4:	25 ff 0f 00 00       	and    $0xfff,%eax
  801cd9:	74 14                	je     801cef <spawn+0x3f8>
		va -= i;
  801cdb:	29 c6                	sub    %eax,%esi
		memsz += i;
  801cdd:	01 c3                	add    %eax,%ebx
  801cdf:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801ce5:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ce7:	29 c2                	sub    %eax,%edx
  801ce9:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cf4:	e9 09 ff ff ff       	jmp    801c02 <spawn+0x30b>
	close(fd);
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801d02:	e8 ac f5 ff ff       	call   8012b3 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801d07:	e8 5b ef ff ff       	call   800c67 <sys_getenvid>
  801d0c:	89 c6                	mov    %eax,%esi
  801d0e:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801d11:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801d16:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801d1c:	eb 12                	jmp    801d30 <spawn+0x439>
  801d1e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d24:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d2a:	0f 84 bb 00 00 00    	je     801deb <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801d30:	89 d8                	mov    %ebx,%eax
  801d32:	c1 e8 16             	shr    $0x16,%eax
  801d35:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d3c:	a8 01                	test   $0x1,%al
  801d3e:	74 de                	je     801d1e <spawn+0x427>
  801d40:	89 d8                	mov    %ebx,%eax
  801d42:	c1 e8 0c             	shr    $0xc,%eax
  801d45:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d4c:	f6 c2 01             	test   $0x1,%dl
  801d4f:	74 cd                	je     801d1e <spawn+0x427>
  801d51:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d58:	f6 c6 04             	test   $0x4,%dh
  801d5b:	74 c1                	je     801d1e <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801d5d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d64:	83 ec 0c             	sub    $0xc,%esp
  801d67:	25 07 0e 00 00       	and    $0xe07,%eax
  801d6c:	50                   	push   %eax
  801d6d:	53                   	push   %ebx
  801d6e:	57                   	push   %edi
  801d6f:	53                   	push   %ebx
  801d70:	56                   	push   %esi
  801d71:	e8 72 ef ff ff       	call   800ce8 <sys_page_map>
  801d76:	83 c4 20             	add    $0x20,%esp
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	79 a1                	jns    801d1e <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  801d7d:	50                   	push   %eax
  801d7e:	68 4b 2e 80 00       	push   $0x802e4b
  801d83:	68 82 00 00 00       	push   $0x82
  801d88:	68 f1 2d 80 00       	push   $0x802df1
  801d8d:	e8 62 e4 ff ff       	call   8001f4 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801d92:	50                   	push   %eax
  801d93:	68 1a 2e 80 00       	push   $0x802e1a
  801d98:	68 86 00 00 00       	push   $0x86
  801d9d:	68 f1 2d 80 00       	push   $0x802df1
  801da2:	e8 4d e4 ff ff       	call   8001f4 <_panic>
		panic("sys_env_set_status: %e", r);
  801da7:	50                   	push   %eax
  801da8:	68 34 2e 80 00       	push   $0x802e34
  801dad:	68 89 00 00 00       	push   $0x89
  801db2:	68 f1 2d 80 00       	push   $0x802df1
  801db7:	e8 38 e4 ff ff       	call   8001f4 <_panic>
		return r;
  801dbc:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801dc2:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801dc8:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801dce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5f                   	pop    %edi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    
  801dd6:	89 c7                	mov    %eax,%edi
  801dd8:	e9 59 fe ff ff       	jmp    801c36 <spawn+0x33f>
  801ddd:	89 c7                	mov    %eax,%edi
  801ddf:	e9 52 fe ff ff       	jmp    801c36 <spawn+0x33f>
  801de4:	89 c7                	mov    %eax,%edi
  801de6:	e9 4b fe ff ff       	jmp    801c36 <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801deb:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801df2:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801df5:	83 ec 08             	sub    $0x8,%esp
  801df8:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801e05:	e8 a4 ef ff ff       	call   800dae <sys_env_set_trapframe>
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	78 81                	js     801d92 <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e11:	83 ec 08             	sub    $0x8,%esp
  801e14:	6a 02                	push   $0x2
  801e16:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801e1c:	e8 4b ef ff ff       	call   800d6c <sys_env_set_status>
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	85 c0                	test   %eax,%eax
  801e26:	0f 88 7b ff ff ff    	js     801da7 <spawn+0x4b0>
	return child;
  801e2c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e32:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801e38:	eb 8e                	jmp    801dc8 <spawn+0x4d1>
		return -E_NO_MEM;
  801e3a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801e3f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801e45:	eb 81                	jmp    801dc8 <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  801e47:	83 ec 08             	sub    $0x8,%esp
  801e4a:	68 00 00 40 00       	push   $0x400000
  801e4f:	6a 00                	push   $0x0
  801e51:	e8 d4 ee ff ff       	call   800d2a <sys_page_unmap>
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801e5f:	e9 64 ff ff ff       	jmp    801dc8 <spawn+0x4d1>

00801e64 <spawnl>:
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	56                   	push   %esi
  801e68:	53                   	push   %ebx
	va_start(vl, arg0);
  801e69:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801e6c:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801e71:	eb 05                	jmp    801e78 <spawnl+0x14>
		argc++;
  801e73:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801e76:	89 ca                	mov    %ecx,%edx
  801e78:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e7b:	83 3a 00             	cmpl   $0x0,(%edx)
  801e7e:	75 f3                	jne    801e73 <spawnl+0xf>
	const char *argv[argc+2];
  801e80:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801e87:	89 d3                	mov    %edx,%ebx
  801e89:	83 e3 f0             	and    $0xfffffff0,%ebx
  801e8c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801e92:	89 e1                	mov    %esp,%ecx
  801e94:	29 d1                	sub    %edx,%ecx
  801e96:	39 cc                	cmp    %ecx,%esp
  801e98:	74 10                	je     801eaa <spawnl+0x46>
  801e9a:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801ea0:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801ea7:	00 
  801ea8:	eb ec                	jmp    801e96 <spawnl+0x32>
  801eaa:	89 da                	mov    %ebx,%edx
  801eac:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801eb2:	29 d4                	sub    %edx,%esp
  801eb4:	85 d2                	test   %edx,%edx
  801eb6:	74 05                	je     801ebd <spawnl+0x59>
  801eb8:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801ebd:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801ec1:	89 da                	mov    %ebx,%edx
  801ec3:	c1 ea 02             	shr    $0x2,%edx
  801ec6:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801ec9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ecc:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ed3:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801eda:	00 
	va_start(vl, arg0);
  801edb:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801ede:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee5:	eb 0b                	jmp    801ef2 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801ee7:	83 c0 01             	add    $0x1,%eax
  801eea:	8b 31                	mov    (%ecx),%esi
  801eec:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801eef:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801ef2:	39 d0                	cmp    %edx,%eax
  801ef4:	75 f1                	jne    801ee7 <spawnl+0x83>
	return spawn(prog, argv);
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	53                   	push   %ebx
  801efa:	ff 75 08             	push   0x8(%ebp)
  801efd:	e8 f5 f9 ff ff       	call   8018f7 <spawn>
}
  801f02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f05:	5b                   	pop    %ebx
  801f06:	5e                   	pop    %esi
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    

00801f09 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
  801f0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	ff 75 08             	push   0x8(%ebp)
  801f17:	e8 08 f2 ff ff       	call   801124 <fd2data>
  801f1c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f1e:	83 c4 08             	add    $0x8,%esp
  801f21:	68 8a 2e 80 00       	push   $0x802e8a
  801f26:	53                   	push   %ebx
  801f27:	e8 7d e9 ff ff       	call   8008a9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f2c:	8b 46 04             	mov    0x4(%esi),%eax
  801f2f:	2b 06                	sub    (%esi),%eax
  801f31:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f37:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f3e:	00 00 00 
	stat->st_dev = &devpipe;
  801f41:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801f48:	30 80 00 
	return 0;
}
  801f4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	53                   	push   %ebx
  801f5b:	83 ec 0c             	sub    $0xc,%esp
  801f5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f61:	53                   	push   %ebx
  801f62:	6a 00                	push   $0x0
  801f64:	e8 c1 ed ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f69:	89 1c 24             	mov    %ebx,(%esp)
  801f6c:	e8 b3 f1 ff ff       	call   801124 <fd2data>
  801f71:	83 c4 08             	add    $0x8,%esp
  801f74:	50                   	push   %eax
  801f75:	6a 00                	push   $0x0
  801f77:	e8 ae ed ff ff       	call   800d2a <sys_page_unmap>
}
  801f7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    

00801f81 <_pipeisclosed>:
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	57                   	push   %edi
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
  801f87:	83 ec 1c             	sub    $0x1c,%esp
  801f8a:	89 c7                	mov    %eax,%edi
  801f8c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f8e:	a1 00 40 80 00       	mov    0x804000,%eax
  801f93:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f96:	83 ec 0c             	sub    $0xc,%esp
  801f99:	57                   	push   %edi
  801f9a:	e8 07 06 00 00       	call   8025a6 <pageref>
  801f9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801fa2:	89 34 24             	mov    %esi,(%esp)
  801fa5:	e8 fc 05 00 00       	call   8025a6 <pageref>
		nn = thisenv->env_runs;
  801faa:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fb0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	39 cb                	cmp    %ecx,%ebx
  801fb8:	74 1b                	je     801fd5 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801fba:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fbd:	75 cf                	jne    801f8e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fbf:	8b 42 58             	mov    0x58(%edx),%eax
  801fc2:	6a 01                	push   $0x1
  801fc4:	50                   	push   %eax
  801fc5:	53                   	push   %ebx
  801fc6:	68 91 2e 80 00       	push   $0x802e91
  801fcb:	e8 ff e2 ff ff       	call   8002cf <cprintf>
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	eb b9                	jmp    801f8e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801fd5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fd8:	0f 94 c0             	sete   %al
  801fdb:	0f b6 c0             	movzbl %al,%eax
}
  801fde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe1:	5b                   	pop    %ebx
  801fe2:	5e                   	pop    %esi
  801fe3:	5f                   	pop    %edi
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    

00801fe6 <devpipe_write>:
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	57                   	push   %edi
  801fea:	56                   	push   %esi
  801feb:	53                   	push   %ebx
  801fec:	83 ec 28             	sub    $0x28,%esp
  801fef:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ff2:	56                   	push   %esi
  801ff3:	e8 2c f1 ff ff       	call   801124 <fd2data>
  801ff8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	bf 00 00 00 00       	mov    $0x0,%edi
  802002:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802005:	75 09                	jne    802010 <devpipe_write+0x2a>
	return i;
  802007:	89 f8                	mov    %edi,%eax
  802009:	eb 23                	jmp    80202e <devpipe_write+0x48>
			sys_yield();
  80200b:	e8 76 ec ff ff       	call   800c86 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802010:	8b 43 04             	mov    0x4(%ebx),%eax
  802013:	8b 0b                	mov    (%ebx),%ecx
  802015:	8d 51 20             	lea    0x20(%ecx),%edx
  802018:	39 d0                	cmp    %edx,%eax
  80201a:	72 1a                	jb     802036 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80201c:	89 da                	mov    %ebx,%edx
  80201e:	89 f0                	mov    %esi,%eax
  802020:	e8 5c ff ff ff       	call   801f81 <_pipeisclosed>
  802025:	85 c0                	test   %eax,%eax
  802027:	74 e2                	je     80200b <devpipe_write+0x25>
				return 0;
  802029:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80202e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802031:	5b                   	pop    %ebx
  802032:	5e                   	pop    %esi
  802033:	5f                   	pop    %edi
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802036:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802039:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80203d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802040:	89 c2                	mov    %eax,%edx
  802042:	c1 fa 1f             	sar    $0x1f,%edx
  802045:	89 d1                	mov    %edx,%ecx
  802047:	c1 e9 1b             	shr    $0x1b,%ecx
  80204a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80204d:	83 e2 1f             	and    $0x1f,%edx
  802050:	29 ca                	sub    %ecx,%edx
  802052:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802056:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80205a:	83 c0 01             	add    $0x1,%eax
  80205d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802060:	83 c7 01             	add    $0x1,%edi
  802063:	eb 9d                	jmp    802002 <devpipe_write+0x1c>

00802065 <devpipe_read>:
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	57                   	push   %edi
  802069:	56                   	push   %esi
  80206a:	53                   	push   %ebx
  80206b:	83 ec 18             	sub    $0x18,%esp
  80206e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802071:	57                   	push   %edi
  802072:	e8 ad f0 ff ff       	call   801124 <fd2data>
  802077:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802079:	83 c4 10             	add    $0x10,%esp
  80207c:	be 00 00 00 00       	mov    $0x0,%esi
  802081:	3b 75 10             	cmp    0x10(%ebp),%esi
  802084:	75 13                	jne    802099 <devpipe_read+0x34>
	return i;
  802086:	89 f0                	mov    %esi,%eax
  802088:	eb 02                	jmp    80208c <devpipe_read+0x27>
				return i;
  80208a:	89 f0                	mov    %esi,%eax
}
  80208c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
			sys_yield();
  802094:	e8 ed eb ff ff       	call   800c86 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802099:	8b 03                	mov    (%ebx),%eax
  80209b:	3b 43 04             	cmp    0x4(%ebx),%eax
  80209e:	75 18                	jne    8020b8 <devpipe_read+0x53>
			if (i > 0)
  8020a0:	85 f6                	test   %esi,%esi
  8020a2:	75 e6                	jne    80208a <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8020a4:	89 da                	mov    %ebx,%edx
  8020a6:	89 f8                	mov    %edi,%eax
  8020a8:	e8 d4 fe ff ff       	call   801f81 <_pipeisclosed>
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	74 e3                	je     802094 <devpipe_read+0x2f>
				return 0;
  8020b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b6:	eb d4                	jmp    80208c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020b8:	99                   	cltd   
  8020b9:	c1 ea 1b             	shr    $0x1b,%edx
  8020bc:	01 d0                	add    %edx,%eax
  8020be:	83 e0 1f             	and    $0x1f,%eax
  8020c1:	29 d0                	sub    %edx,%eax
  8020c3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020cb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020ce:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020d1:	83 c6 01             	add    $0x1,%esi
  8020d4:	eb ab                	jmp    802081 <devpipe_read+0x1c>

008020d6 <pipe>:
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	56                   	push   %esi
  8020da:	53                   	push   %ebx
  8020db:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e1:	50                   	push   %eax
  8020e2:	e8 54 f0 ff ff       	call   80113b <fd_alloc>
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	83 c4 10             	add    $0x10,%esp
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	0f 88 23 01 00 00    	js     802217 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f4:	83 ec 04             	sub    $0x4,%esp
  8020f7:	68 07 04 00 00       	push   $0x407
  8020fc:	ff 75 f4             	push   -0xc(%ebp)
  8020ff:	6a 00                	push   $0x0
  802101:	e8 9f eb ff ff       	call   800ca5 <sys_page_alloc>
  802106:	89 c3                	mov    %eax,%ebx
  802108:	83 c4 10             	add    $0x10,%esp
  80210b:	85 c0                	test   %eax,%eax
  80210d:	0f 88 04 01 00 00    	js     802217 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802113:	83 ec 0c             	sub    $0xc,%esp
  802116:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802119:	50                   	push   %eax
  80211a:	e8 1c f0 ff ff       	call   80113b <fd_alloc>
  80211f:	89 c3                	mov    %eax,%ebx
  802121:	83 c4 10             	add    $0x10,%esp
  802124:	85 c0                	test   %eax,%eax
  802126:	0f 88 db 00 00 00    	js     802207 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212c:	83 ec 04             	sub    $0x4,%esp
  80212f:	68 07 04 00 00       	push   $0x407
  802134:	ff 75 f0             	push   -0x10(%ebp)
  802137:	6a 00                	push   $0x0
  802139:	e8 67 eb ff ff       	call   800ca5 <sys_page_alloc>
  80213e:	89 c3                	mov    %eax,%ebx
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	85 c0                	test   %eax,%eax
  802145:	0f 88 bc 00 00 00    	js     802207 <pipe+0x131>
	va = fd2data(fd0);
  80214b:	83 ec 0c             	sub    $0xc,%esp
  80214e:	ff 75 f4             	push   -0xc(%ebp)
  802151:	e8 ce ef ff ff       	call   801124 <fd2data>
  802156:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802158:	83 c4 0c             	add    $0xc,%esp
  80215b:	68 07 04 00 00       	push   $0x407
  802160:	50                   	push   %eax
  802161:	6a 00                	push   $0x0
  802163:	e8 3d eb ff ff       	call   800ca5 <sys_page_alloc>
  802168:	89 c3                	mov    %eax,%ebx
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	85 c0                	test   %eax,%eax
  80216f:	0f 88 82 00 00 00    	js     8021f7 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802175:	83 ec 0c             	sub    $0xc,%esp
  802178:	ff 75 f0             	push   -0x10(%ebp)
  80217b:	e8 a4 ef ff ff       	call   801124 <fd2data>
  802180:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802187:	50                   	push   %eax
  802188:	6a 00                	push   $0x0
  80218a:	56                   	push   %esi
  80218b:	6a 00                	push   $0x0
  80218d:	e8 56 eb ff ff       	call   800ce8 <sys_page_map>
  802192:	89 c3                	mov    %eax,%ebx
  802194:	83 c4 20             	add    $0x20,%esp
  802197:	85 c0                	test   %eax,%eax
  802199:	78 4e                	js     8021e9 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80219b:	a1 28 30 80 00       	mov    0x803028,%eax
  8021a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a3:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8021a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a8:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8021af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021b2:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8021b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8021be:	83 ec 0c             	sub    $0xc,%esp
  8021c1:	ff 75 f4             	push   -0xc(%ebp)
  8021c4:	e8 4b ef ff ff       	call   801114 <fd2num>
  8021c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021cc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021ce:	83 c4 04             	add    $0x4,%esp
  8021d1:	ff 75 f0             	push   -0x10(%ebp)
  8021d4:	e8 3b ef ff ff       	call   801114 <fd2num>
  8021d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021dc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021df:	83 c4 10             	add    $0x10,%esp
  8021e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021e7:	eb 2e                	jmp    802217 <pipe+0x141>
	sys_page_unmap(0, va);
  8021e9:	83 ec 08             	sub    $0x8,%esp
  8021ec:	56                   	push   %esi
  8021ed:	6a 00                	push   $0x0
  8021ef:	e8 36 eb ff ff       	call   800d2a <sys_page_unmap>
  8021f4:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8021f7:	83 ec 08             	sub    $0x8,%esp
  8021fa:	ff 75 f0             	push   -0x10(%ebp)
  8021fd:	6a 00                	push   $0x0
  8021ff:	e8 26 eb ff ff       	call   800d2a <sys_page_unmap>
  802204:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802207:	83 ec 08             	sub    $0x8,%esp
  80220a:	ff 75 f4             	push   -0xc(%ebp)
  80220d:	6a 00                	push   $0x0
  80220f:	e8 16 eb ff ff       	call   800d2a <sys_page_unmap>
  802214:	83 c4 10             	add    $0x10,%esp
}
  802217:	89 d8                	mov    %ebx,%eax
  802219:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80221c:	5b                   	pop    %ebx
  80221d:	5e                   	pop    %esi
  80221e:	5d                   	pop    %ebp
  80221f:	c3                   	ret    

00802220 <pipeisclosed>:
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802226:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802229:	50                   	push   %eax
  80222a:	ff 75 08             	push   0x8(%ebp)
  80222d:	e8 59 ef ff ff       	call   80118b <fd_lookup>
  802232:	83 c4 10             	add    $0x10,%esp
  802235:	85 c0                	test   %eax,%eax
  802237:	78 18                	js     802251 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802239:	83 ec 0c             	sub    $0xc,%esp
  80223c:	ff 75 f4             	push   -0xc(%ebp)
  80223f:	e8 e0 ee ff ff       	call   801124 <fd2data>
  802244:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802246:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802249:	e8 33 fd ff ff       	call   801f81 <_pipeisclosed>
  80224e:	83 c4 10             	add    $0x10,%esp
}
  802251:	c9                   	leave  
  802252:	c3                   	ret    

00802253 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	56                   	push   %esi
  802257:	53                   	push   %ebx
  802258:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80225b:	85 f6                	test   %esi,%esi
  80225d:	74 13                	je     802272 <wait+0x1f>
	e = &envs[ENVX(envid)];
  80225f:	89 f3                	mov    %esi,%ebx
  802261:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802267:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80226a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802270:	eb 1b                	jmp    80228d <wait+0x3a>
	assert(envid != 0);
  802272:	68 a9 2e 80 00       	push   $0x802ea9
  802277:	68 ab 2d 80 00       	push   $0x802dab
  80227c:	6a 09                	push   $0x9
  80227e:	68 b4 2e 80 00       	push   $0x802eb4
  802283:	e8 6c df ff ff       	call   8001f4 <_panic>
		sys_yield();
  802288:	e8 f9 e9 ff ff       	call   800c86 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80228d:	8b 43 48             	mov    0x48(%ebx),%eax
  802290:	39 f0                	cmp    %esi,%eax
  802292:	75 07                	jne    80229b <wait+0x48>
  802294:	8b 43 54             	mov    0x54(%ebx),%eax
  802297:	85 c0                	test   %eax,%eax
  802299:	75 ed                	jne    802288 <wait+0x35>
}
  80229b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80229e:	5b                   	pop    %ebx
  80229f:	5e                   	pop    %esi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    

008022a2 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8022a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a7:	c3                   	ret    

008022a8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022ae:	68 bf 2e 80 00       	push   $0x802ebf
  8022b3:	ff 75 0c             	push   0xc(%ebp)
  8022b6:	e8 ee e5 ff ff       	call   8008a9 <strcpy>
	return 0;
}
  8022bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c0:	c9                   	leave  
  8022c1:	c3                   	ret    

008022c2 <devcons_write>:
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	57                   	push   %edi
  8022c6:	56                   	push   %esi
  8022c7:	53                   	push   %ebx
  8022c8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8022ce:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022d3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022d9:	eb 2e                	jmp    802309 <devcons_write+0x47>
		m = n - tot;
  8022db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022de:	29 f3                	sub    %esi,%ebx
  8022e0:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8022e5:	39 c3                	cmp    %eax,%ebx
  8022e7:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022ea:	83 ec 04             	sub    $0x4,%esp
  8022ed:	53                   	push   %ebx
  8022ee:	89 f0                	mov    %esi,%eax
  8022f0:	03 45 0c             	add    0xc(%ebp),%eax
  8022f3:	50                   	push   %eax
  8022f4:	57                   	push   %edi
  8022f5:	e8 45 e7 ff ff       	call   800a3f <memmove>
		sys_cputs(buf, m);
  8022fa:	83 c4 08             	add    $0x8,%esp
  8022fd:	53                   	push   %ebx
  8022fe:	57                   	push   %edi
  8022ff:	e8 e5 e8 ff ff       	call   800be9 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802304:	01 de                	add    %ebx,%esi
  802306:	83 c4 10             	add    $0x10,%esp
  802309:	3b 75 10             	cmp    0x10(%ebp),%esi
  80230c:	72 cd                	jb     8022db <devcons_write+0x19>
}
  80230e:	89 f0                	mov    %esi,%eax
  802310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802313:	5b                   	pop    %ebx
  802314:	5e                   	pop    %esi
  802315:	5f                   	pop    %edi
  802316:	5d                   	pop    %ebp
  802317:	c3                   	ret    

00802318 <devcons_read>:
{
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	83 ec 08             	sub    $0x8,%esp
  80231e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802323:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802327:	75 07                	jne    802330 <devcons_read+0x18>
  802329:	eb 1f                	jmp    80234a <devcons_read+0x32>
		sys_yield();
  80232b:	e8 56 e9 ff ff       	call   800c86 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802330:	e8 d2 e8 ff ff       	call   800c07 <sys_cgetc>
  802335:	85 c0                	test   %eax,%eax
  802337:	74 f2                	je     80232b <devcons_read+0x13>
	if (c < 0)
  802339:	78 0f                	js     80234a <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80233b:	83 f8 04             	cmp    $0x4,%eax
  80233e:	74 0c                	je     80234c <devcons_read+0x34>
	*(char*)vbuf = c;
  802340:	8b 55 0c             	mov    0xc(%ebp),%edx
  802343:	88 02                	mov    %al,(%edx)
	return 1;
  802345:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80234a:	c9                   	leave  
  80234b:	c3                   	ret    
		return 0;
  80234c:	b8 00 00 00 00       	mov    $0x0,%eax
  802351:	eb f7                	jmp    80234a <devcons_read+0x32>

00802353 <cputchar>:
{
  802353:	55                   	push   %ebp
  802354:	89 e5                	mov    %esp,%ebp
  802356:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802359:	8b 45 08             	mov    0x8(%ebp),%eax
  80235c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80235f:	6a 01                	push   $0x1
  802361:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802364:	50                   	push   %eax
  802365:	e8 7f e8 ff ff       	call   800be9 <sys_cputs>
}
  80236a:	83 c4 10             	add    $0x10,%esp
  80236d:	c9                   	leave  
  80236e:	c3                   	ret    

0080236f <getchar>:
{
  80236f:	55                   	push   %ebp
  802370:	89 e5                	mov    %esp,%ebp
  802372:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802375:	6a 01                	push   $0x1
  802377:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80237a:	50                   	push   %eax
  80237b:	6a 00                	push   $0x0
  80237d:	e8 6d f0 ff ff       	call   8013ef <read>
	if (r < 0)
  802382:	83 c4 10             	add    $0x10,%esp
  802385:	85 c0                	test   %eax,%eax
  802387:	78 06                	js     80238f <getchar+0x20>
	if (r < 1)
  802389:	74 06                	je     802391 <getchar+0x22>
	return c;
  80238b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80238f:	c9                   	leave  
  802390:	c3                   	ret    
		return -E_EOF;
  802391:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802396:	eb f7                	jmp    80238f <getchar+0x20>

00802398 <iscons>:
{
  802398:	55                   	push   %ebp
  802399:	89 e5                	mov    %esp,%ebp
  80239b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80239e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023a1:	50                   	push   %eax
  8023a2:	ff 75 08             	push   0x8(%ebp)
  8023a5:	e8 e1 ed ff ff       	call   80118b <fd_lookup>
  8023aa:	83 c4 10             	add    $0x10,%esp
  8023ad:	85 c0                	test   %eax,%eax
  8023af:	78 11                	js     8023c2 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8023b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b4:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023ba:	39 10                	cmp    %edx,(%eax)
  8023bc:	0f 94 c0             	sete   %al
  8023bf:	0f b6 c0             	movzbl %al,%eax
}
  8023c2:	c9                   	leave  
  8023c3:	c3                   	ret    

008023c4 <opencons>:
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023cd:	50                   	push   %eax
  8023ce:	e8 68 ed ff ff       	call   80113b <fd_alloc>
  8023d3:	83 c4 10             	add    $0x10,%esp
  8023d6:	85 c0                	test   %eax,%eax
  8023d8:	78 3a                	js     802414 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023da:	83 ec 04             	sub    $0x4,%esp
  8023dd:	68 07 04 00 00       	push   $0x407
  8023e2:	ff 75 f4             	push   -0xc(%ebp)
  8023e5:	6a 00                	push   $0x0
  8023e7:	e8 b9 e8 ff ff       	call   800ca5 <sys_page_alloc>
  8023ec:	83 c4 10             	add    $0x10,%esp
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	78 21                	js     802414 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8023f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f6:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802401:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802408:	83 ec 0c             	sub    $0xc,%esp
  80240b:	50                   	push   %eax
  80240c:	e8 03 ed ff ff       	call   801114 <fd2num>
  802411:	83 c4 10             	add    $0x10,%esp
}
  802414:	c9                   	leave  
  802415:	c3                   	ret    

00802416 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802416:	55                   	push   %ebp
  802417:	89 e5                	mov    %esp,%ebp
  802419:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80241c:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  802423:	74 0a                	je     80242f <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802425:	8b 45 08             	mov    0x8(%ebp),%eax
  802428:	a3 04 60 80 00       	mov    %eax,0x806004
}
  80242d:	c9                   	leave  
  80242e:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  80242f:	e8 33 e8 ff ff       	call   800c67 <sys_getenvid>
  802434:	83 ec 04             	sub    $0x4,%esp
  802437:	68 07 0e 00 00       	push   $0xe07
  80243c:	68 00 f0 bf ee       	push   $0xeebff000
  802441:	50                   	push   %eax
  802442:	e8 5e e8 ff ff       	call   800ca5 <sys_page_alloc>
		if (r < 0) {
  802447:	83 c4 10             	add    $0x10,%esp
  80244a:	85 c0                	test   %eax,%eax
  80244c:	78 2c                	js     80247a <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80244e:	e8 14 e8 ff ff       	call   800c67 <sys_getenvid>
  802453:	83 ec 08             	sub    $0x8,%esp
  802456:	68 8c 24 80 00       	push   $0x80248c
  80245b:	50                   	push   %eax
  80245c:	e8 8f e9 ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802461:	83 c4 10             	add    $0x10,%esp
  802464:	85 c0                	test   %eax,%eax
  802466:	79 bd                	jns    802425 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802468:	50                   	push   %eax
  802469:	68 0c 2f 80 00       	push   $0x802f0c
  80246e:	6a 28                	push   $0x28
  802470:	68 42 2f 80 00       	push   $0x802f42
  802475:	e8 7a dd ff ff       	call   8001f4 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80247a:	50                   	push   %eax
  80247b:	68 cc 2e 80 00       	push   $0x802ecc
  802480:	6a 23                	push   $0x23
  802482:	68 42 2f 80 00       	push   $0x802f42
  802487:	e8 68 dd ff ff       	call   8001f4 <_panic>

0080248c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80248c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80248d:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  802492:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802494:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802497:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80249b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80249e:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8024a2:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8024a6:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8024a8:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8024ab:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8024ac:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8024af:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8024b0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8024b1:	c3                   	ret    

008024b2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024b2:	55                   	push   %ebp
  8024b3:	89 e5                	mov    %esp,%ebp
  8024b5:	56                   	push   %esi
  8024b6:	53                   	push   %ebx
  8024b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8024ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8024c0:	85 c0                	test   %eax,%eax
  8024c2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024c7:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8024ca:	83 ec 0c             	sub    $0xc,%esp
  8024cd:	50                   	push   %eax
  8024ce:	e8 82 e9 ff ff       	call   800e55 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8024d3:	83 c4 10             	add    $0x10,%esp
  8024d6:	85 f6                	test   %esi,%esi
  8024d8:	74 14                	je     8024ee <ipc_recv+0x3c>
  8024da:	ba 00 00 00 00       	mov    $0x0,%edx
  8024df:	85 c0                	test   %eax,%eax
  8024e1:	78 09                	js     8024ec <ipc_recv+0x3a>
  8024e3:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8024e9:	8b 52 74             	mov    0x74(%edx),%edx
  8024ec:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8024ee:	85 db                	test   %ebx,%ebx
  8024f0:	74 14                	je     802506 <ipc_recv+0x54>
  8024f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	78 09                	js     802504 <ipc_recv+0x52>
  8024fb:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802501:	8b 52 78             	mov    0x78(%edx),%edx
  802504:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802506:	85 c0                	test   %eax,%eax
  802508:	78 08                	js     802512 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  80250a:	a1 00 40 80 00       	mov    0x804000,%eax
  80250f:	8b 40 70             	mov    0x70(%eax),%eax
}
  802512:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802515:	5b                   	pop    %ebx
  802516:	5e                   	pop    %esi
  802517:	5d                   	pop    %ebp
  802518:	c3                   	ret    

00802519 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802519:	55                   	push   %ebp
  80251a:	89 e5                	mov    %esp,%ebp
  80251c:	57                   	push   %edi
  80251d:	56                   	push   %esi
  80251e:	53                   	push   %ebx
  80251f:	83 ec 0c             	sub    $0xc,%esp
  802522:	8b 7d 08             	mov    0x8(%ebp),%edi
  802525:	8b 75 0c             	mov    0xc(%ebp),%esi
  802528:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80252b:	85 db                	test   %ebx,%ebx
  80252d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802532:	0f 44 d8             	cmove  %eax,%ebx
  802535:	eb 05                	jmp    80253c <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802537:	e8 4a e7 ff ff       	call   800c86 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80253c:	ff 75 14             	push   0x14(%ebp)
  80253f:	53                   	push   %ebx
  802540:	56                   	push   %esi
  802541:	57                   	push   %edi
  802542:	e8 eb e8 ff ff       	call   800e32 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802547:	83 c4 10             	add    $0x10,%esp
  80254a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80254d:	74 e8                	je     802537 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80254f:	85 c0                	test   %eax,%eax
  802551:	78 08                	js     80255b <ipc_send+0x42>
	}while (r<0);

}
  802553:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802556:	5b                   	pop    %ebx
  802557:	5e                   	pop    %esi
  802558:	5f                   	pop    %edi
  802559:	5d                   	pop    %ebp
  80255a:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80255b:	50                   	push   %eax
  80255c:	68 50 2f 80 00       	push   $0x802f50
  802561:	6a 3d                	push   $0x3d
  802563:	68 64 2f 80 00       	push   $0x802f64
  802568:	e8 87 dc ff ff       	call   8001f4 <_panic>

0080256d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80256d:	55                   	push   %ebp
  80256e:	89 e5                	mov    %esp,%ebp
  802570:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802573:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802578:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80257b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802581:	8b 52 50             	mov    0x50(%edx),%edx
  802584:	39 ca                	cmp    %ecx,%edx
  802586:	74 11                	je     802599 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802588:	83 c0 01             	add    $0x1,%eax
  80258b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802590:	75 e6                	jne    802578 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802592:	b8 00 00 00 00       	mov    $0x0,%eax
  802597:	eb 0b                	jmp    8025a4 <ipc_find_env+0x37>
			return envs[i].env_id;
  802599:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80259c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025a1:	8b 40 48             	mov    0x48(%eax),%eax
}
  8025a4:	5d                   	pop    %ebp
  8025a5:	c3                   	ret    

008025a6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025a6:	55                   	push   %ebp
  8025a7:	89 e5                	mov    %esp,%ebp
  8025a9:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025ac:	89 c2                	mov    %eax,%edx
  8025ae:	c1 ea 16             	shr    $0x16,%edx
  8025b1:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8025b8:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8025bd:	f6 c1 01             	test   $0x1,%cl
  8025c0:	74 1c                	je     8025de <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8025c2:	c1 e8 0c             	shr    $0xc,%eax
  8025c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025cc:	a8 01                	test   $0x1,%al
  8025ce:	74 0e                	je     8025de <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025d0:	c1 e8 0c             	shr    $0xc,%eax
  8025d3:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8025da:	ef 
  8025db:	0f b7 d2             	movzwl %dx,%edx
}
  8025de:	89 d0                	mov    %edx,%eax
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    
  8025e2:	66 90                	xchg   %ax,%ax
  8025e4:	66 90                	xchg   %ax,%ax
  8025e6:	66 90                	xchg   %ax,%ax
  8025e8:	66 90                	xchg   %ax,%ax
  8025ea:	66 90                	xchg   %ax,%ax
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__udivdi3>:
  8025f0:	f3 0f 1e fb          	endbr32 
  8025f4:	55                   	push   %ebp
  8025f5:	57                   	push   %edi
  8025f6:	56                   	push   %esi
  8025f7:	53                   	push   %ebx
  8025f8:	83 ec 1c             	sub    $0x1c,%esp
  8025fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802603:	8b 74 24 34          	mov    0x34(%esp),%esi
  802607:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80260b:	85 c0                	test   %eax,%eax
  80260d:	75 19                	jne    802628 <__udivdi3+0x38>
  80260f:	39 f3                	cmp    %esi,%ebx
  802611:	76 4d                	jbe    802660 <__udivdi3+0x70>
  802613:	31 ff                	xor    %edi,%edi
  802615:	89 e8                	mov    %ebp,%eax
  802617:	89 f2                	mov    %esi,%edx
  802619:	f7 f3                	div    %ebx
  80261b:	89 fa                	mov    %edi,%edx
  80261d:	83 c4 1c             	add    $0x1c,%esp
  802620:	5b                   	pop    %ebx
  802621:	5e                   	pop    %esi
  802622:	5f                   	pop    %edi
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    
  802625:	8d 76 00             	lea    0x0(%esi),%esi
  802628:	39 f0                	cmp    %esi,%eax
  80262a:	76 14                	jbe    802640 <__udivdi3+0x50>
  80262c:	31 ff                	xor    %edi,%edi
  80262e:	31 c0                	xor    %eax,%eax
  802630:	89 fa                	mov    %edi,%edx
  802632:	83 c4 1c             	add    $0x1c,%esp
  802635:	5b                   	pop    %ebx
  802636:	5e                   	pop    %esi
  802637:	5f                   	pop    %edi
  802638:	5d                   	pop    %ebp
  802639:	c3                   	ret    
  80263a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802640:	0f bd f8             	bsr    %eax,%edi
  802643:	83 f7 1f             	xor    $0x1f,%edi
  802646:	75 48                	jne    802690 <__udivdi3+0xa0>
  802648:	39 f0                	cmp    %esi,%eax
  80264a:	72 06                	jb     802652 <__udivdi3+0x62>
  80264c:	31 c0                	xor    %eax,%eax
  80264e:	39 eb                	cmp    %ebp,%ebx
  802650:	77 de                	ja     802630 <__udivdi3+0x40>
  802652:	b8 01 00 00 00       	mov    $0x1,%eax
  802657:	eb d7                	jmp    802630 <__udivdi3+0x40>
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	89 d9                	mov    %ebx,%ecx
  802662:	85 db                	test   %ebx,%ebx
  802664:	75 0b                	jne    802671 <__udivdi3+0x81>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f3                	div    %ebx
  80266f:	89 c1                	mov    %eax,%ecx
  802671:	31 d2                	xor    %edx,%edx
  802673:	89 f0                	mov    %esi,%eax
  802675:	f7 f1                	div    %ecx
  802677:	89 c6                	mov    %eax,%esi
  802679:	89 e8                	mov    %ebp,%eax
  80267b:	89 f7                	mov    %esi,%edi
  80267d:	f7 f1                	div    %ecx
  80267f:	89 fa                	mov    %edi,%edx
  802681:	83 c4 1c             	add    $0x1c,%esp
  802684:	5b                   	pop    %ebx
  802685:	5e                   	pop    %esi
  802686:	5f                   	pop    %edi
  802687:	5d                   	pop    %ebp
  802688:	c3                   	ret    
  802689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802690:	89 f9                	mov    %edi,%ecx
  802692:	ba 20 00 00 00       	mov    $0x20,%edx
  802697:	29 fa                	sub    %edi,%edx
  802699:	d3 e0                	shl    %cl,%eax
  80269b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80269f:	89 d1                	mov    %edx,%ecx
  8026a1:	89 d8                	mov    %ebx,%eax
  8026a3:	d3 e8                	shr    %cl,%eax
  8026a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026a9:	09 c1                	or     %eax,%ecx
  8026ab:	89 f0                	mov    %esi,%eax
  8026ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026b1:	89 f9                	mov    %edi,%ecx
  8026b3:	d3 e3                	shl    %cl,%ebx
  8026b5:	89 d1                	mov    %edx,%ecx
  8026b7:	d3 e8                	shr    %cl,%eax
  8026b9:	89 f9                	mov    %edi,%ecx
  8026bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8026bf:	89 eb                	mov    %ebp,%ebx
  8026c1:	d3 e6                	shl    %cl,%esi
  8026c3:	89 d1                	mov    %edx,%ecx
  8026c5:	d3 eb                	shr    %cl,%ebx
  8026c7:	09 f3                	or     %esi,%ebx
  8026c9:	89 c6                	mov    %eax,%esi
  8026cb:	89 f2                	mov    %esi,%edx
  8026cd:	89 d8                	mov    %ebx,%eax
  8026cf:	f7 74 24 08          	divl   0x8(%esp)
  8026d3:	89 d6                	mov    %edx,%esi
  8026d5:	89 c3                	mov    %eax,%ebx
  8026d7:	f7 64 24 0c          	mull   0xc(%esp)
  8026db:	39 d6                	cmp    %edx,%esi
  8026dd:	72 19                	jb     8026f8 <__udivdi3+0x108>
  8026df:	89 f9                	mov    %edi,%ecx
  8026e1:	d3 e5                	shl    %cl,%ebp
  8026e3:	39 c5                	cmp    %eax,%ebp
  8026e5:	73 04                	jae    8026eb <__udivdi3+0xfb>
  8026e7:	39 d6                	cmp    %edx,%esi
  8026e9:	74 0d                	je     8026f8 <__udivdi3+0x108>
  8026eb:	89 d8                	mov    %ebx,%eax
  8026ed:	31 ff                	xor    %edi,%edi
  8026ef:	e9 3c ff ff ff       	jmp    802630 <__udivdi3+0x40>
  8026f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8026fb:	31 ff                	xor    %edi,%edi
  8026fd:	e9 2e ff ff ff       	jmp    802630 <__udivdi3+0x40>
  802702:	66 90                	xchg   %ax,%ax
  802704:	66 90                	xchg   %ax,%ax
  802706:	66 90                	xchg   %ax,%ax
  802708:	66 90                	xchg   %ax,%ax
  80270a:	66 90                	xchg   %ax,%ax
  80270c:	66 90                	xchg   %ax,%ax
  80270e:	66 90                	xchg   %ax,%ax

00802710 <__umoddi3>:
  802710:	f3 0f 1e fb          	endbr32 
  802714:	55                   	push   %ebp
  802715:	57                   	push   %edi
  802716:	56                   	push   %esi
  802717:	53                   	push   %ebx
  802718:	83 ec 1c             	sub    $0x1c,%esp
  80271b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80271f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802723:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802727:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80272b:	89 f0                	mov    %esi,%eax
  80272d:	89 da                	mov    %ebx,%edx
  80272f:	85 ff                	test   %edi,%edi
  802731:	75 15                	jne    802748 <__umoddi3+0x38>
  802733:	39 dd                	cmp    %ebx,%ebp
  802735:	76 39                	jbe    802770 <__umoddi3+0x60>
  802737:	f7 f5                	div    %ebp
  802739:	89 d0                	mov    %edx,%eax
  80273b:	31 d2                	xor    %edx,%edx
  80273d:	83 c4 1c             	add    $0x1c,%esp
  802740:	5b                   	pop    %ebx
  802741:	5e                   	pop    %esi
  802742:	5f                   	pop    %edi
  802743:	5d                   	pop    %ebp
  802744:	c3                   	ret    
  802745:	8d 76 00             	lea    0x0(%esi),%esi
  802748:	39 df                	cmp    %ebx,%edi
  80274a:	77 f1                	ja     80273d <__umoddi3+0x2d>
  80274c:	0f bd cf             	bsr    %edi,%ecx
  80274f:	83 f1 1f             	xor    $0x1f,%ecx
  802752:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802756:	75 40                	jne    802798 <__umoddi3+0x88>
  802758:	39 df                	cmp    %ebx,%edi
  80275a:	72 04                	jb     802760 <__umoddi3+0x50>
  80275c:	39 f5                	cmp    %esi,%ebp
  80275e:	77 dd                	ja     80273d <__umoddi3+0x2d>
  802760:	89 da                	mov    %ebx,%edx
  802762:	89 f0                	mov    %esi,%eax
  802764:	29 e8                	sub    %ebp,%eax
  802766:	19 fa                	sbb    %edi,%edx
  802768:	eb d3                	jmp    80273d <__umoddi3+0x2d>
  80276a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802770:	89 e9                	mov    %ebp,%ecx
  802772:	85 ed                	test   %ebp,%ebp
  802774:	75 0b                	jne    802781 <__umoddi3+0x71>
  802776:	b8 01 00 00 00       	mov    $0x1,%eax
  80277b:	31 d2                	xor    %edx,%edx
  80277d:	f7 f5                	div    %ebp
  80277f:	89 c1                	mov    %eax,%ecx
  802781:	89 d8                	mov    %ebx,%eax
  802783:	31 d2                	xor    %edx,%edx
  802785:	f7 f1                	div    %ecx
  802787:	89 f0                	mov    %esi,%eax
  802789:	f7 f1                	div    %ecx
  80278b:	89 d0                	mov    %edx,%eax
  80278d:	31 d2                	xor    %edx,%edx
  80278f:	eb ac                	jmp    80273d <__umoddi3+0x2d>
  802791:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802798:	8b 44 24 04          	mov    0x4(%esp),%eax
  80279c:	ba 20 00 00 00       	mov    $0x20,%edx
  8027a1:	29 c2                	sub    %eax,%edx
  8027a3:	89 c1                	mov    %eax,%ecx
  8027a5:	89 e8                	mov    %ebp,%eax
  8027a7:	d3 e7                	shl    %cl,%edi
  8027a9:	89 d1                	mov    %edx,%ecx
  8027ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8027af:	d3 e8                	shr    %cl,%eax
  8027b1:	89 c1                	mov    %eax,%ecx
  8027b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027b7:	09 f9                	or     %edi,%ecx
  8027b9:	89 df                	mov    %ebx,%edi
  8027bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027bf:	89 c1                	mov    %eax,%ecx
  8027c1:	d3 e5                	shl    %cl,%ebp
  8027c3:	89 d1                	mov    %edx,%ecx
  8027c5:	d3 ef                	shr    %cl,%edi
  8027c7:	89 c1                	mov    %eax,%ecx
  8027c9:	89 f0                	mov    %esi,%eax
  8027cb:	d3 e3                	shl    %cl,%ebx
  8027cd:	89 d1                	mov    %edx,%ecx
  8027cf:	89 fa                	mov    %edi,%edx
  8027d1:	d3 e8                	shr    %cl,%eax
  8027d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027d8:	09 d8                	or     %ebx,%eax
  8027da:	f7 74 24 08          	divl   0x8(%esp)
  8027de:	89 d3                	mov    %edx,%ebx
  8027e0:	d3 e6                	shl    %cl,%esi
  8027e2:	f7 e5                	mul    %ebp
  8027e4:	89 c7                	mov    %eax,%edi
  8027e6:	89 d1                	mov    %edx,%ecx
  8027e8:	39 d3                	cmp    %edx,%ebx
  8027ea:	72 06                	jb     8027f2 <__umoddi3+0xe2>
  8027ec:	75 0e                	jne    8027fc <__umoddi3+0xec>
  8027ee:	39 c6                	cmp    %eax,%esi
  8027f0:	73 0a                	jae    8027fc <__umoddi3+0xec>
  8027f2:	29 e8                	sub    %ebp,%eax
  8027f4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8027f8:	89 d1                	mov    %edx,%ecx
  8027fa:	89 c7                	mov    %eax,%edi
  8027fc:	89 f5                	mov    %esi,%ebp
  8027fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802802:	29 fd                	sub    %edi,%ebp
  802804:	19 cb                	sbb    %ecx,%ebx
  802806:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80280b:	89 d8                	mov    %ebx,%eax
  80280d:	d3 e0                	shl    %cl,%eax
  80280f:	89 f1                	mov    %esi,%ecx
  802811:	d3 ed                	shr    %cl,%ebp
  802813:	d3 eb                	shr    %cl,%ebx
  802815:	09 e8                	or     %ebp,%eax
  802817:	89 da                	mov    %ebx,%edx
  802819:	83 c4 1c             	add    $0x1c,%esp
  80281c:	5b                   	pop    %ebx
  80281d:	5e                   	pop    %esi
  80281e:	5f                   	pop    %edi
  80281f:	5d                   	pop    %ebp
  802820:	c3                   	ret    
