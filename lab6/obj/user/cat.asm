
obj/user/cat.debug：     文件格式 elf32-i386


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
  80002c:	e8 fc 00 00 00       	call   80012d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	68 00 20 00 00       	push   $0x2000
  800043:	68 00 40 80 00       	push   $0x804000
  800048:	56                   	push   %esi
  800049:	e8 22 11 00 00       	call   801170 <read>
  80004e:	89 c3                	mov    %eax,%ebx
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	7e 2f                	jle    800086 <cat+0x53>
		if ((r = write(1, buf, n)) != n)
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	53                   	push   %ebx
  80005b:	68 00 40 80 00       	push   $0x804000
  800060:	6a 01                	push   $0x1
  800062:	e8 d7 11 00 00       	call   80123e <write>
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	39 c3                	cmp    %eax,%ebx
  80006c:	74 cd                	je     80003b <cat+0x8>
			panic("write error copying %s: %e", s, r);
  80006e:	83 ec 0c             	sub    $0xc,%esp
  800071:	50                   	push   %eax
  800072:	ff 75 0c             	push   0xc(%ebp)
  800075:	68 40 24 80 00       	push   $0x802440
  80007a:	6a 0d                	push   $0xd
  80007c:	68 5b 24 80 00       	push   $0x80245b
  800081:	e8 07 01 00 00       	call   80018d <_panic>
	if (n < 0)
  800086:	78 07                	js     80008f <cat+0x5c>
		panic("error reading %s: %e", s, n);
}
  800088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    
		panic("error reading %s: %e", s, n);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	50                   	push   %eax
  800093:	ff 75 0c             	push   0xc(%ebp)
  800096:	68 66 24 80 00       	push   $0x802466
  80009b:	6a 0f                	push   $0xf
  80009d:	68 5b 24 80 00       	push   $0x80245b
  8000a2:	e8 e6 00 00 00       	call   80018d <_panic>

008000a7 <umain>:

void
umain(int argc, char **argv)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	83 ec 0c             	sub    $0xc,%esp
  8000b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b3:	c7 05 00 30 80 00 7b 	movl   $0x80247b,0x803000
  8000ba:	24 80 00 
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8000bd:	be 01 00 00 00       	mov    $0x1,%esi
	if (argc == 1)
  8000c2:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000c6:	75 31                	jne    8000f9 <umain+0x52>
		cat(0, "<stdin>");
  8000c8:	83 ec 08             	sub    $0x8,%esp
  8000cb:	68 7f 24 80 00       	push   $0x80247f
  8000d0:	6a 00                	push   $0x0
  8000d2:	e8 5c ff ff ff       	call   800033 <cat>
  8000d7:	83 c4 10             	add    $0x10,%esp
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  8000da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    
				printf("can't open %s: %e\n", argv[i], f);
  8000e2:	83 ec 04             	sub    $0x4,%esp
  8000e5:	50                   	push   %eax
  8000e6:	ff 34 b7             	push   (%edi,%esi,4)
  8000e9:	68 87 24 80 00       	push   $0x802487
  8000ee:	e8 82 16 00 00       	call   801775 <printf>
  8000f3:	83 c4 10             	add    $0x10,%esp
		for (i = 1; i < argc; i++) {
  8000f6:	83 c6 01             	add    $0x1,%esi
  8000f9:	3b 75 08             	cmp    0x8(%ebp),%esi
  8000fc:	7d dc                	jge    8000da <umain+0x33>
			f = open(argv[i], O_RDONLY);
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	6a 00                	push   $0x0
  800103:	ff 34 b7             	push   (%edi,%esi,4)
  800106:	e8 c8 14 00 00       	call   8015d3 <open>
  80010b:	89 c3                	mov    %eax,%ebx
			if (f < 0)
  80010d:	83 c4 10             	add    $0x10,%esp
  800110:	85 c0                	test   %eax,%eax
  800112:	78 ce                	js     8000e2 <umain+0x3b>
				cat(f, argv[i]);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	ff 34 b7             	push   (%edi,%esi,4)
  80011a:	50                   	push   %eax
  80011b:	e8 13 ff ff ff       	call   800033 <cat>
				close(f);
  800120:	89 1c 24             	mov    %ebx,(%esp)
  800123:	e8 0c 0f 00 00       	call   801034 <close>
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	eb c9                	jmp    8000f6 <umain+0x4f>

0080012d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
  800132:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800135:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800138:	e8 c3 0a 00 00       	call   800c00 <sys_getenvid>
  80013d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800142:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800145:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80014a:	a3 00 60 80 00       	mov    %eax,0x806000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80014f:	85 db                	test   %ebx,%ebx
  800151:	7e 07                	jle    80015a <libmain+0x2d>
		binaryname = argv[0];
  800153:	8b 06                	mov    (%esi),%eax
  800155:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80015a:	83 ec 08             	sub    $0x8,%esp
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 43 ff ff ff       	call   8000a7 <umain>

	// exit gracefully
	exit();
  800164:	e8 0a 00 00 00       	call   800173 <exit>
}
  800169:	83 c4 10             	add    $0x10,%esp
  80016c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80016f:	5b                   	pop    %ebx
  800170:	5e                   	pop    %esi
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800179:	e8 e3 0e 00 00       	call   801061 <close_all>
	sys_env_destroy(0);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	6a 00                	push   $0x0
  800183:	e8 37 0a 00 00       	call   800bbf <sys_env_destroy>
}
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800192:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800195:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80019b:	e8 60 0a 00 00       	call   800c00 <sys_getenvid>
  8001a0:	83 ec 0c             	sub    $0xc,%esp
  8001a3:	ff 75 0c             	push   0xc(%ebp)
  8001a6:	ff 75 08             	push   0x8(%ebp)
  8001a9:	56                   	push   %esi
  8001aa:	50                   	push   %eax
  8001ab:	68 a4 24 80 00       	push   $0x8024a4
  8001b0:	e8 b3 00 00 00       	call   800268 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b5:	83 c4 18             	add    $0x18,%esp
  8001b8:	53                   	push   %ebx
  8001b9:	ff 75 10             	push   0x10(%ebp)
  8001bc:	e8 56 00 00 00       	call   800217 <vcprintf>
	cprintf("\n");
  8001c1:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
  8001c8:	e8 9b 00 00 00       	call   800268 <cprintf>
  8001cd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d0:	cc                   	int3   
  8001d1:	eb fd                	jmp    8001d0 <_panic+0x43>

008001d3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	53                   	push   %ebx
  8001d7:	83 ec 04             	sub    $0x4,%esp
  8001da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001dd:	8b 13                	mov    (%ebx),%edx
  8001df:	8d 42 01             	lea    0x1(%edx),%eax
  8001e2:	89 03                	mov    %eax,(%ebx)
  8001e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001eb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f0:	74 09                	je     8001fb <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	68 ff 00 00 00       	push   $0xff
  800203:	8d 43 08             	lea    0x8(%ebx),%eax
  800206:	50                   	push   %eax
  800207:	e8 76 09 00 00       	call   800b82 <sys_cputs>
		b->idx = 0;
  80020c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	eb db                	jmp    8001f2 <putch+0x1f>

00800217 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800220:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800227:	00 00 00 
	b.cnt = 0;
  80022a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800231:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800234:	ff 75 0c             	push   0xc(%ebp)
  800237:	ff 75 08             	push   0x8(%ebp)
  80023a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800240:	50                   	push   %eax
  800241:	68 d3 01 80 00       	push   $0x8001d3
  800246:	e8 14 01 00 00       	call   80035f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024b:	83 c4 08             	add    $0x8,%esp
  80024e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800254:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025a:	50                   	push   %eax
  80025b:	e8 22 09 00 00       	call   800b82 <sys_cputs>

	return b.cnt;
}
  800260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800271:	50                   	push   %eax
  800272:	ff 75 08             	push   0x8(%ebp)
  800275:	e8 9d ff ff ff       	call   800217 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 1c             	sub    $0x1c,%esp
  800285:	89 c7                	mov    %eax,%edi
  800287:	89 d6                	mov    %edx,%esi
  800289:	8b 45 08             	mov    0x8(%ebp),%eax
  80028c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80028f:	89 d1                	mov    %edx,%ecx
  800291:	89 c2                	mov    %eax,%edx
  800293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800296:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800299:	8b 45 10             	mov    0x10(%ebp),%eax
  80029c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002a9:	39 c2                	cmp    %eax,%edx
  8002ab:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002ae:	72 3e                	jb     8002ee <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	ff 75 18             	push   0x18(%ebp)
  8002b6:	83 eb 01             	sub    $0x1,%ebx
  8002b9:	53                   	push   %ebx
  8002ba:	50                   	push   %eax
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	ff 75 e4             	push   -0x1c(%ebp)
  8002c1:	ff 75 e0             	push   -0x20(%ebp)
  8002c4:	ff 75 dc             	push   -0x24(%ebp)
  8002c7:	ff 75 d8             	push   -0x28(%ebp)
  8002ca:	e8 21 1f 00 00       	call   8021f0 <__udivdi3>
  8002cf:	83 c4 18             	add    $0x18,%esp
  8002d2:	52                   	push   %edx
  8002d3:	50                   	push   %eax
  8002d4:	89 f2                	mov    %esi,%edx
  8002d6:	89 f8                	mov    %edi,%eax
  8002d8:	e8 9f ff ff ff       	call   80027c <printnum>
  8002dd:	83 c4 20             	add    $0x20,%esp
  8002e0:	eb 13                	jmp    8002f5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	56                   	push   %esi
  8002e6:	ff 75 18             	push   0x18(%ebp)
  8002e9:	ff d7                	call   *%edi
  8002eb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ee:	83 eb 01             	sub    $0x1,%ebx
  8002f1:	85 db                	test   %ebx,%ebx
  8002f3:	7f ed                	jg     8002e2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f5:	83 ec 08             	sub    $0x8,%esp
  8002f8:	56                   	push   %esi
  8002f9:	83 ec 04             	sub    $0x4,%esp
  8002fc:	ff 75 e4             	push   -0x1c(%ebp)
  8002ff:	ff 75 e0             	push   -0x20(%ebp)
  800302:	ff 75 dc             	push   -0x24(%ebp)
  800305:	ff 75 d8             	push   -0x28(%ebp)
  800308:	e8 03 20 00 00       	call   802310 <__umoddi3>
  80030d:	83 c4 14             	add    $0x14,%esp
  800310:	0f be 80 c7 24 80 00 	movsbl 0x8024c7(%eax),%eax
  800317:	50                   	push   %eax
  800318:	ff d7                	call   *%edi
}
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	3b 50 04             	cmp    0x4(%eax),%edx
  800334:	73 0a                	jae    800340 <sprintputch+0x1b>
		*b->buf++ = ch;
  800336:	8d 4a 01             	lea    0x1(%edx),%ecx
  800339:	89 08                	mov    %ecx,(%eax)
  80033b:	8b 45 08             	mov    0x8(%ebp),%eax
  80033e:	88 02                	mov    %al,(%edx)
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <printfmt>:
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800348:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034b:	50                   	push   %eax
  80034c:	ff 75 10             	push   0x10(%ebp)
  80034f:	ff 75 0c             	push   0xc(%ebp)
  800352:	ff 75 08             	push   0x8(%ebp)
  800355:	e8 05 00 00 00       	call   80035f <vprintfmt>
}
  80035a:	83 c4 10             	add    $0x10,%esp
  80035d:	c9                   	leave  
  80035e:	c3                   	ret    

0080035f <vprintfmt>:
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	57                   	push   %edi
  800363:	56                   	push   %esi
  800364:	53                   	push   %ebx
  800365:	83 ec 3c             	sub    $0x3c,%esp
  800368:	8b 75 08             	mov    0x8(%ebp),%esi
  80036b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800371:	eb 0a                	jmp    80037d <vprintfmt+0x1e>
			putch(ch, putdat);
  800373:	83 ec 08             	sub    $0x8,%esp
  800376:	53                   	push   %ebx
  800377:	50                   	push   %eax
  800378:	ff d6                	call   *%esi
  80037a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037d:	83 c7 01             	add    $0x1,%edi
  800380:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800384:	83 f8 25             	cmp    $0x25,%eax
  800387:	74 0c                	je     800395 <vprintfmt+0x36>
			if (ch == '\0')
  800389:	85 c0                	test   %eax,%eax
  80038b:	75 e6                	jne    800373 <vprintfmt+0x14>
}
  80038d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    
		padc = ' ';
  800395:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800399:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003a0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003a7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003ae:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8d 47 01             	lea    0x1(%edi),%eax
  8003b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b9:	0f b6 17             	movzbl (%edi),%edx
  8003bc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003bf:	3c 55                	cmp    $0x55,%al
  8003c1:	0f 87 bb 03 00 00    	ja     800782 <vprintfmt+0x423>
  8003c7:	0f b6 c0             	movzbl %al,%eax
  8003ca:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003d4:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003d8:	eb d9                	jmp    8003b3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003dd:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003e1:	eb d0                	jmp    8003b3 <vprintfmt+0x54>
  8003e3:	0f b6 d2             	movzbl %dl,%edx
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003f1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003f8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003fb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003fe:	83 f9 09             	cmp    $0x9,%ecx
  800401:	77 55                	ja     800458 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800403:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800406:	eb e9                	jmp    8003f1 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 40 04             	lea    0x4(%eax),%eax
  800416:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80041c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800420:	79 91                	jns    8003b3 <vprintfmt+0x54>
				width = precision, precision = -1;
  800422:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800425:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800428:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80042f:	eb 82                	jmp    8003b3 <vprintfmt+0x54>
  800431:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800434:	85 d2                	test   %edx,%edx
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	0f 49 c2             	cmovns %edx,%eax
  80043e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800444:	e9 6a ff ff ff       	jmp    8003b3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80044c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800453:	e9 5b ff ff ff       	jmp    8003b3 <vprintfmt+0x54>
  800458:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80045b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80045e:	eb bc                	jmp    80041c <vprintfmt+0xbd>
			lflag++;
  800460:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800466:	e9 48 ff ff ff       	jmp    8003b3 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 78 04             	lea    0x4(%eax),%edi
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	ff 30                	push   (%eax)
  800477:	ff d6                	call   *%esi
			break;
  800479:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80047c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80047f:	e9 9d 02 00 00       	jmp    800721 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8d 78 04             	lea    0x4(%eax),%edi
  80048a:	8b 10                	mov    (%eax),%edx
  80048c:	89 d0                	mov    %edx,%eax
  80048e:	f7 d8                	neg    %eax
  800490:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800493:	83 f8 0f             	cmp    $0xf,%eax
  800496:	7f 23                	jg     8004bb <vprintfmt+0x15c>
  800498:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  80049f:	85 d2                	test   %edx,%edx
  8004a1:	74 18                	je     8004bb <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004a3:	52                   	push   %edx
  8004a4:	68 95 28 80 00       	push   $0x802895
  8004a9:	53                   	push   %ebx
  8004aa:	56                   	push   %esi
  8004ab:	e8 92 fe ff ff       	call   800342 <printfmt>
  8004b0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004b3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004b6:	e9 66 02 00 00       	jmp    800721 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004bb:	50                   	push   %eax
  8004bc:	68 df 24 80 00       	push   $0x8024df
  8004c1:	53                   	push   %ebx
  8004c2:	56                   	push   %esi
  8004c3:	e8 7a fe ff ff       	call   800342 <printfmt>
  8004c8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004cb:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004ce:	e9 4e 02 00 00       	jmp    800721 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	83 c0 04             	add    $0x4,%eax
  8004d9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	b8 d8 24 80 00       	mov    $0x8024d8,%eax
  8004e8:	0f 45 c2             	cmovne %edx,%eax
  8004eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f2:	7e 06                	jle    8004fa <vprintfmt+0x19b>
  8004f4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004f8:	75 0d                	jne    800507 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004fd:	89 c7                	mov    %eax,%edi
  8004ff:	03 45 e0             	add    -0x20(%ebp),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800505:	eb 55                	jmp    80055c <vprintfmt+0x1fd>
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	ff 75 d8             	push   -0x28(%ebp)
  80050d:	ff 75 cc             	push   -0x34(%ebp)
  800510:	e8 0a 03 00 00       	call   80081f <strnlen>
  800515:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800518:	29 c1                	sub    %eax,%ecx
  80051a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800522:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800526:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	eb 0f                	jmp    80053a <vprintfmt+0x1db>
					putch(padc, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	ff 75 e0             	push   -0x20(%ebp)
  800532:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	83 ef 01             	sub    $0x1,%edi
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	85 ff                	test   %edi,%edi
  80053c:	7f ed                	jg     80052b <vprintfmt+0x1cc>
  80053e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800541:	85 d2                	test   %edx,%edx
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	0f 49 c2             	cmovns %edx,%eax
  80054b:	29 c2                	sub    %eax,%edx
  80054d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800550:	eb a8                	jmp    8004fa <vprintfmt+0x19b>
					putch(ch, putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	53                   	push   %ebx
  800556:	52                   	push   %edx
  800557:	ff d6                	call   *%esi
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80055f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800561:	83 c7 01             	add    $0x1,%edi
  800564:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800568:	0f be d0             	movsbl %al,%edx
  80056b:	85 d2                	test   %edx,%edx
  80056d:	74 4b                	je     8005ba <vprintfmt+0x25b>
  80056f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800573:	78 06                	js     80057b <vprintfmt+0x21c>
  800575:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800579:	78 1e                	js     800599 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80057b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80057f:	74 d1                	je     800552 <vprintfmt+0x1f3>
  800581:	0f be c0             	movsbl %al,%eax
  800584:	83 e8 20             	sub    $0x20,%eax
  800587:	83 f8 5e             	cmp    $0x5e,%eax
  80058a:	76 c6                	jbe    800552 <vprintfmt+0x1f3>
					putch('?', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 3f                	push   $0x3f
  800592:	ff d6                	call   *%esi
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	eb c3                	jmp    80055c <vprintfmt+0x1fd>
  800599:	89 cf                	mov    %ecx,%edi
  80059b:	eb 0e                	jmp    8005ab <vprintfmt+0x24c>
				putch(' ', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	6a 20                	push   $0x20
  8005a3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005a5:	83 ef 01             	sub    $0x1,%edi
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	85 ff                	test   %edi,%edi
  8005ad:	7f ee                	jg     80059d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005af:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b5:	e9 67 01 00 00       	jmp    800721 <vprintfmt+0x3c2>
  8005ba:	89 cf                	mov    %ecx,%edi
  8005bc:	eb ed                	jmp    8005ab <vprintfmt+0x24c>
	if (lflag >= 2)
  8005be:	83 f9 01             	cmp    $0x1,%ecx
  8005c1:	7f 1b                	jg     8005de <vprintfmt+0x27f>
	else if (lflag)
  8005c3:	85 c9                	test   %ecx,%ecx
  8005c5:	74 63                	je     80062a <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cf:	99                   	cltd   
  8005d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 40 04             	lea    0x4(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dc:	eb 17                	jmp    8005f5 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 50 04             	mov    0x4(%eax),%edx
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 40 08             	lea    0x8(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005fb:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800600:	85 c9                	test   %ecx,%ecx
  800602:	0f 89 ff 00 00 00    	jns    800707 <vprintfmt+0x3a8>
				putch('-', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 2d                	push   $0x2d
  80060e:	ff d6                	call   *%esi
				num = -(long long) num;
  800610:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800613:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800616:	f7 da                	neg    %edx
  800618:	83 d1 00             	adc    $0x0,%ecx
  80061b:	f7 d9                	neg    %ecx
  80061d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800620:	bf 0a 00 00 00       	mov    $0xa,%edi
  800625:	e9 dd 00 00 00       	jmp    800707 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800632:	99                   	cltd   
  800633:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
  80063f:	eb b4                	jmp    8005f5 <vprintfmt+0x296>
	if (lflag >= 2)
  800641:	83 f9 01             	cmp    $0x1,%ecx
  800644:	7f 1e                	jg     800664 <vprintfmt+0x305>
	else if (lflag)
  800646:	85 c9                	test   %ecx,%ecx
  800648:	74 32                	je     80067c <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 10                	mov    (%eax),%edx
  80064f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80065a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80065f:	e9 a3 00 00 00       	jmp    800707 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8b 10                	mov    (%eax),%edx
  800669:	8b 48 04             	mov    0x4(%eax),%ecx
  80066c:	8d 40 08             	lea    0x8(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800672:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800677:	e9 8b 00 00 00       	jmp    800707 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	b9 00 00 00 00       	mov    $0x0,%ecx
  800686:	8d 40 04             	lea    0x4(%eax),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800691:	eb 74                	jmp    800707 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800693:	83 f9 01             	cmp    $0x1,%ecx
  800696:	7f 1b                	jg     8006b3 <vprintfmt+0x354>
	else if (lflag)
  800698:	85 c9                	test   %ecx,%ecx
  80069a:	74 2c                	je     8006c8 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006ac:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8006b1:	eb 54                	jmp    800707 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bb:	8d 40 08             	lea    0x8(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006c1:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8006c6:	eb 3f                	jmp    800707 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006d8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8006dd:	eb 28                	jmp    800707 <vprintfmt+0x3a8>
			putch('0', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	6a 30                	push   $0x30
  8006e5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006e7:	83 c4 08             	add    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	6a 78                	push   $0x78
  8006ed:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006f9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006fc:	8d 40 04             	lea    0x4(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800702:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800707:	83 ec 0c             	sub    $0xc,%esp
  80070a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	ff 75 e0             	push   -0x20(%ebp)
  800712:	57                   	push   %edi
  800713:	51                   	push   %ecx
  800714:	52                   	push   %edx
  800715:	89 da                	mov    %ebx,%edx
  800717:	89 f0                	mov    %esi,%eax
  800719:	e8 5e fb ff ff       	call   80027c <printnum>
			break;
  80071e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800721:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800724:	e9 54 fc ff ff       	jmp    80037d <vprintfmt+0x1e>
	if (lflag >= 2)
  800729:	83 f9 01             	cmp    $0x1,%ecx
  80072c:	7f 1b                	jg     800749 <vprintfmt+0x3ea>
	else if (lflag)
  80072e:	85 c9                	test   %ecx,%ecx
  800730:	74 2c                	je     80075e <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	8d 40 04             	lea    0x4(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800742:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800747:	eb be                	jmp    800707 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8b 10                	mov    (%eax),%edx
  80074e:	8b 48 04             	mov    0x4(%eax),%ecx
  800751:	8d 40 08             	lea    0x8(%eax),%eax
  800754:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800757:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80075c:	eb a9                	jmp    800707 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 10                	mov    (%eax),%edx
  800763:	b9 00 00 00 00       	mov    $0x0,%ecx
  800768:	8d 40 04             	lea    0x4(%eax),%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800773:	eb 92                	jmp    800707 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 25                	push   $0x25
  80077b:	ff d6                	call   *%esi
			break;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	eb 9f                	jmp    800721 <vprintfmt+0x3c2>
			putch('%', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	53                   	push   %ebx
  800786:	6a 25                	push   $0x25
  800788:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	89 f8                	mov    %edi,%eax
  80078f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800793:	74 05                	je     80079a <vprintfmt+0x43b>
  800795:	83 e8 01             	sub    $0x1,%eax
  800798:	eb f5                	jmp    80078f <vprintfmt+0x430>
  80079a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80079d:	eb 82                	jmp    800721 <vprintfmt+0x3c2>

0080079f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 18             	sub    $0x18,%esp
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	74 26                	je     8007e6 <vsnprintf+0x47>
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	7e 22                	jle    8007e6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c4:	ff 75 14             	push   0x14(%ebp)
  8007c7:	ff 75 10             	push   0x10(%ebp)
  8007ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007cd:	50                   	push   %eax
  8007ce:	68 25 03 80 00       	push   $0x800325
  8007d3:	e8 87 fb ff ff       	call   80035f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e1:	83 c4 10             	add    $0x10,%esp
}
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    
		return -E_INVAL;
  8007e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007eb:	eb f7                	jmp    8007e4 <vsnprintf+0x45>

008007ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f6:	50                   	push   %eax
  8007f7:	ff 75 10             	push   0x10(%ebp)
  8007fa:	ff 75 0c             	push   0xc(%ebp)
  8007fd:	ff 75 08             	push   0x8(%ebp)
  800800:	e8 9a ff ff ff       	call   80079f <vsnprintf>
	va_end(ap);

	return rc;
}
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
  800812:	eb 03                	jmp    800817 <strlen+0x10>
		n++;
  800814:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800817:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081b:	75 f7                	jne    800814 <strlen+0xd>
	return n;
}
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
  80082d:	eb 03                	jmp    800832 <strnlen+0x13>
		n++;
  80082f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800832:	39 d0                	cmp    %edx,%eax
  800834:	74 08                	je     80083e <strnlen+0x1f>
  800836:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80083a:	75 f3                	jne    80082f <strnlen+0x10>
  80083c:	89 c2                	mov    %eax,%edx
	return n;
}
  80083e:	89 d0                	mov    %edx,%eax
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800849:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084c:	b8 00 00 00 00       	mov    $0x0,%eax
  800851:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800855:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	84 d2                	test   %dl,%dl
  80085d:	75 f2                	jne    800851 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80085f:	89 c8                	mov    %ecx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 10             	sub    $0x10,%esp
  80086d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800870:	53                   	push   %ebx
  800871:	e8 91 ff ff ff       	call   800807 <strlen>
  800876:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800879:	ff 75 0c             	push   0xc(%ebp)
  80087c:	01 d8                	add    %ebx,%eax
  80087e:	50                   	push   %eax
  80087f:	e8 be ff ff ff       	call   800842 <strcpy>
	return dst;
}
  800884:	89 d8                	mov    %ebx,%eax
  800886:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 75 08             	mov    0x8(%ebp),%esi
  800893:	8b 55 0c             	mov    0xc(%ebp),%edx
  800896:	89 f3                	mov    %esi,%ebx
  800898:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089b:	89 f0                	mov    %esi,%eax
  80089d:	eb 0f                	jmp    8008ae <strncpy+0x23>
		*dst++ = *src;
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	0f b6 0a             	movzbl (%edx),%ecx
  8008a5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a8:	80 f9 01             	cmp    $0x1,%cl
  8008ab:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008ae:	39 d8                	cmp    %ebx,%eax
  8008b0:	75 ed                	jne    80089f <strncpy+0x14>
	}
	return ret;
}
  8008b2:	89 f0                	mov    %esi,%eax
  8008b4:	5b                   	pop    %ebx
  8008b5:	5e                   	pop    %esi
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c8:	85 d2                	test   %edx,%edx
  8008ca:	74 21                	je     8008ed <strlcpy+0x35>
  8008cc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d0:	89 f2                	mov    %esi,%edx
  8008d2:	eb 09                	jmp    8008dd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d4:	83 c1 01             	add    $0x1,%ecx
  8008d7:	83 c2 01             	add    $0x1,%edx
  8008da:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8008dd:	39 c2                	cmp    %eax,%edx
  8008df:	74 09                	je     8008ea <strlcpy+0x32>
  8008e1:	0f b6 19             	movzbl (%ecx),%ebx
  8008e4:	84 db                	test   %bl,%bl
  8008e6:	75 ec                	jne    8008d4 <strlcpy+0x1c>
  8008e8:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ed:	29 f0                	sub    %esi,%eax
}
  8008ef:	5b                   	pop    %ebx
  8008f0:	5e                   	pop    %esi
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008fc:	eb 06                	jmp    800904 <strcmp+0x11>
		p++, q++;
  8008fe:	83 c1 01             	add    $0x1,%ecx
  800901:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800904:	0f b6 01             	movzbl (%ecx),%eax
  800907:	84 c0                	test   %al,%al
  800909:	74 04                	je     80090f <strcmp+0x1c>
  80090b:	3a 02                	cmp    (%edx),%al
  80090d:	74 ef                	je     8008fe <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090f:	0f b6 c0             	movzbl %al,%eax
  800912:	0f b6 12             	movzbl (%edx),%edx
  800915:	29 d0                	sub    %edx,%eax
}
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	53                   	push   %ebx
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
  800923:	89 c3                	mov    %eax,%ebx
  800925:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800928:	eb 06                	jmp    800930 <strncmp+0x17>
		n--, p++, q++;
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800930:	39 d8                	cmp    %ebx,%eax
  800932:	74 18                	je     80094c <strncmp+0x33>
  800934:	0f b6 08             	movzbl (%eax),%ecx
  800937:	84 c9                	test   %cl,%cl
  800939:	74 04                	je     80093f <strncmp+0x26>
  80093b:	3a 0a                	cmp    (%edx),%cl
  80093d:	74 eb                	je     80092a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093f:	0f b6 00             	movzbl (%eax),%eax
  800942:	0f b6 12             	movzbl (%edx),%edx
  800945:	29 d0                	sub    %edx,%eax
}
  800947:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80094a:	c9                   	leave  
  80094b:	c3                   	ret    
		return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
  800951:	eb f4                	jmp    800947 <strncmp+0x2e>

00800953 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095d:	eb 03                	jmp    800962 <strchr+0xf>
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	0f b6 10             	movzbl (%eax),%edx
  800965:	84 d2                	test   %dl,%dl
  800967:	74 06                	je     80096f <strchr+0x1c>
		if (*s == c)
  800969:	38 ca                	cmp    %cl,%dl
  80096b:	75 f2                	jne    80095f <strchr+0xc>
  80096d:	eb 05                	jmp    800974 <strchr+0x21>
			return (char *) s;
	return 0;
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800980:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800983:	38 ca                	cmp    %cl,%dl
  800985:	74 09                	je     800990 <strfind+0x1a>
  800987:	84 d2                	test   %dl,%dl
  800989:	74 05                	je     800990 <strfind+0x1a>
	for (; *s; s++)
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	eb f0                	jmp    800980 <strfind+0xa>
			break;
	return (char *) s;
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099e:	85 c9                	test   %ecx,%ecx
  8009a0:	74 2f                	je     8009d1 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a2:	89 f8                	mov    %edi,%eax
  8009a4:	09 c8                	or     %ecx,%eax
  8009a6:	a8 03                	test   $0x3,%al
  8009a8:	75 21                	jne    8009cb <memset+0x39>
		c &= 0xFF;
  8009aa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ae:	89 d0                	mov    %edx,%eax
  8009b0:	c1 e0 08             	shl    $0x8,%eax
  8009b3:	89 d3                	mov    %edx,%ebx
  8009b5:	c1 e3 18             	shl    $0x18,%ebx
  8009b8:	89 d6                	mov    %edx,%esi
  8009ba:	c1 e6 10             	shl    $0x10,%esi
  8009bd:	09 f3                	or     %esi,%ebx
  8009bf:	09 da                	or     %ebx,%edx
  8009c1:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c6:	fc                   	cld    
  8009c7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c9:	eb 06                	jmp    8009d1 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ce:	fc                   	cld    
  8009cf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d1:	89 f8                	mov    %edi,%eax
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5f                   	pop    %edi
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e6:	39 c6                	cmp    %eax,%esi
  8009e8:	73 32                	jae    800a1c <memmove+0x44>
  8009ea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ed:	39 c2                	cmp    %eax,%edx
  8009ef:	76 2b                	jbe    800a1c <memmove+0x44>
		s += n;
		d += n;
  8009f1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f4:	89 d6                	mov    %edx,%esi
  8009f6:	09 fe                	or     %edi,%esi
  8009f8:	09 ce                	or     %ecx,%esi
  8009fa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a00:	75 0e                	jne    800a10 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a02:	83 ef 04             	sub    $0x4,%edi
  800a05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a08:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a0b:	fd                   	std    
  800a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0e:	eb 09                	jmp    800a19 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a10:	83 ef 01             	sub    $0x1,%edi
  800a13:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a16:	fd                   	std    
  800a17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a19:	fc                   	cld    
  800a1a:	eb 1a                	jmp    800a36 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1c:	89 f2                	mov    %esi,%edx
  800a1e:	09 c2                	or     %eax,%edx
  800a20:	09 ca                	or     %ecx,%edx
  800a22:	f6 c2 03             	test   $0x3,%dl
  800a25:	75 0a                	jne    800a31 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a27:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a2a:	89 c7                	mov    %eax,%edi
  800a2c:	fc                   	cld    
  800a2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2f:	eb 05                	jmp    800a36 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	fc                   	cld    
  800a34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a40:	ff 75 10             	push   0x10(%ebp)
  800a43:	ff 75 0c             	push   0xc(%ebp)
  800a46:	ff 75 08             	push   0x8(%ebp)
  800a49:	e8 8a ff ff ff       	call   8009d8 <memmove>
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5b:	89 c6                	mov    %eax,%esi
  800a5d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a60:	eb 06                	jmp    800a68 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a68:	39 f0                	cmp    %esi,%eax
  800a6a:	74 14                	je     800a80 <memcmp+0x30>
		if (*s1 != *s2)
  800a6c:	0f b6 08             	movzbl (%eax),%ecx
  800a6f:	0f b6 1a             	movzbl (%edx),%ebx
  800a72:	38 d9                	cmp    %bl,%cl
  800a74:	74 ec                	je     800a62 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a76:	0f b6 c1             	movzbl %cl,%eax
  800a79:	0f b6 db             	movzbl %bl,%ebx
  800a7c:	29 d8                	sub    %ebx,%eax
  800a7e:	eb 05                	jmp    800a85 <memcmp+0x35>
	}

	return 0;
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a92:	89 c2                	mov    %eax,%edx
  800a94:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a97:	eb 03                	jmp    800a9c <memfind+0x13>
  800a99:	83 c0 01             	add    $0x1,%eax
  800a9c:	39 d0                	cmp    %edx,%eax
  800a9e:	73 04                	jae    800aa4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa0:	38 08                	cmp    %cl,(%eax)
  800aa2:	75 f5                	jne    800a99 <memfind+0x10>
			break;
	return (void *) s;
}
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 55 08             	mov    0x8(%ebp),%edx
  800aaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab2:	eb 03                	jmp    800ab7 <strtol+0x11>
		s++;
  800ab4:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800ab7:	0f b6 02             	movzbl (%edx),%eax
  800aba:	3c 20                	cmp    $0x20,%al
  800abc:	74 f6                	je     800ab4 <strtol+0xe>
  800abe:	3c 09                	cmp    $0x9,%al
  800ac0:	74 f2                	je     800ab4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ac2:	3c 2b                	cmp    $0x2b,%al
  800ac4:	74 2a                	je     800af0 <strtol+0x4a>
	int neg = 0;
  800ac6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800acb:	3c 2d                	cmp    $0x2d,%al
  800acd:	74 2b                	je     800afa <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800acf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad5:	75 0f                	jne    800ae6 <strtol+0x40>
  800ad7:	80 3a 30             	cmpb   $0x30,(%edx)
  800ada:	74 28                	je     800b04 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adc:	85 db                	test   %ebx,%ebx
  800ade:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae3:	0f 44 d8             	cmove  %eax,%ebx
  800ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aeb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aee:	eb 46                	jmp    800b36 <strtol+0x90>
		s++;
  800af0:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800af3:	bf 00 00 00 00       	mov    $0x0,%edi
  800af8:	eb d5                	jmp    800acf <strtol+0x29>
		s++, neg = 1;
  800afa:	83 c2 01             	add    $0x1,%edx
  800afd:	bf 01 00 00 00       	mov    $0x1,%edi
  800b02:	eb cb                	jmp    800acf <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b04:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b08:	74 0e                	je     800b18 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b0a:	85 db                	test   %ebx,%ebx
  800b0c:	75 d8                	jne    800ae6 <strtol+0x40>
		s++, base = 8;
  800b0e:	83 c2 01             	add    $0x1,%edx
  800b11:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b16:	eb ce                	jmp    800ae6 <strtol+0x40>
		s += 2, base = 16;
  800b18:	83 c2 02             	add    $0x2,%edx
  800b1b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b20:	eb c4                	jmp    800ae6 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b22:	0f be c0             	movsbl %al,%eax
  800b25:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b28:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b2b:	7d 3a                	jge    800b67 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b2d:	83 c2 01             	add    $0x1,%edx
  800b30:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b34:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b36:	0f b6 02             	movzbl (%edx),%eax
  800b39:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b3c:	89 f3                	mov    %esi,%ebx
  800b3e:	80 fb 09             	cmp    $0x9,%bl
  800b41:	76 df                	jbe    800b22 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b43:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b46:	89 f3                	mov    %esi,%ebx
  800b48:	80 fb 19             	cmp    $0x19,%bl
  800b4b:	77 08                	ja     800b55 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b4d:	0f be c0             	movsbl %al,%eax
  800b50:	83 e8 57             	sub    $0x57,%eax
  800b53:	eb d3                	jmp    800b28 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b55:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b58:	89 f3                	mov    %esi,%ebx
  800b5a:	80 fb 19             	cmp    $0x19,%bl
  800b5d:	77 08                	ja     800b67 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b5f:	0f be c0             	movsbl %al,%eax
  800b62:	83 e8 37             	sub    $0x37,%eax
  800b65:	eb c1                	jmp    800b28 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6b:	74 05                	je     800b72 <strtol+0xcc>
		*endptr = (char *) s;
  800b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b70:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b72:	89 c8                	mov    %ecx,%eax
  800b74:	f7 d8                	neg    %eax
  800b76:	85 ff                	test   %edi,%edi
  800b78:	0f 45 c8             	cmovne %eax,%ecx
}
  800b7b:	89 c8                	mov    %ecx,%eax
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b88:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b93:	89 c3                	mov    %eax,%ebx
  800b95:	89 c7                	mov    %eax,%edi
  800b97:	89 c6                	mov    %eax,%esi
  800b99:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bab:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb0:	89 d1                	mov    %edx,%ecx
  800bb2:	89 d3                	mov    %edx,%ebx
  800bb4:	89 d7                	mov    %edx,%edi
  800bb6:	89 d6                	mov    %edx,%esi
  800bb8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd5:	89 cb                	mov    %ecx,%ebx
  800bd7:	89 cf                	mov    %ecx,%edi
  800bd9:	89 ce                	mov    %ecx,%esi
  800bdb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7f 08                	jg     800be9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 03                	push   $0x3
  800bef:	68 bf 27 80 00       	push   $0x8027bf
  800bf4:	6a 2a                	push   $0x2a
  800bf6:	68 dc 27 80 00       	push   $0x8027dc
  800bfb:	e8 8d f5 ff ff       	call   80018d <_panic>

00800c00 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c06:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c10:	89 d1                	mov    %edx,%ecx
  800c12:	89 d3                	mov    %edx,%ebx
  800c14:	89 d7                	mov    %edx,%edi
  800c16:	89 d6                	mov    %edx,%esi
  800c18:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_yield>:

void
sys_yield(void)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2f:	89 d1                	mov    %edx,%ecx
  800c31:	89 d3                	mov    %edx,%ebx
  800c33:	89 d7                	mov    %edx,%edi
  800c35:	89 d6                	mov    %edx,%esi
  800c37:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c47:	be 00 00 00 00       	mov    $0x0,%esi
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	b8 04 00 00 00       	mov    $0x4,%eax
  800c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5a:	89 f7                	mov    %esi,%edi
  800c5c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7f 08                	jg     800c6a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 04                	push   $0x4
  800c70:	68 bf 27 80 00       	push   $0x8027bf
  800c75:	6a 2a                	push   $0x2a
  800c77:	68 dc 27 80 00       	push   $0x8027dc
  800c7c:	e8 0c f5 ff ff       	call   80018d <_panic>

00800c81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	b8 05 00 00 00       	mov    $0x5,%eax
  800c95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c98:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c9b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7f 08                	jg     800cac <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 05                	push   $0x5
  800cb2:	68 bf 27 80 00       	push   $0x8027bf
  800cb7:	6a 2a                	push   $0x2a
  800cb9:	68 dc 27 80 00       	push   $0x8027dc
  800cbe:	e8 ca f4 ff ff       	call   80018d <_panic>

00800cc3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdc:	89 df                	mov    %ebx,%edi
  800cde:	89 de                	mov    %ebx,%esi
  800ce0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7f 08                	jg     800cee <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 06                	push   $0x6
  800cf4:	68 bf 27 80 00       	push   $0x8027bf
  800cf9:	6a 2a                	push   $0x2a
  800cfb:	68 dc 27 80 00       	push   $0x8027dc
  800d00:	e8 88 f4 ff ff       	call   80018d <_panic>

00800d05 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1e:	89 df                	mov    %ebx,%edi
  800d20:	89 de                	mov    %ebx,%esi
  800d22:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7f 08                	jg     800d30 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 08                	push   $0x8
  800d36:	68 bf 27 80 00       	push   $0x8027bf
  800d3b:	6a 2a                	push   $0x2a
  800d3d:	68 dc 27 80 00       	push   $0x8027dc
  800d42:	e8 46 f4 ff ff       	call   80018d <_panic>

00800d47 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d60:	89 df                	mov    %ebx,%edi
  800d62:	89 de                	mov    %ebx,%esi
  800d64:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	7f 08                	jg     800d72 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	50                   	push   %eax
  800d76:	6a 09                	push   $0x9
  800d78:	68 bf 27 80 00       	push   $0x8027bf
  800d7d:	6a 2a                	push   $0x2a
  800d7f:	68 dc 27 80 00       	push   $0x8027dc
  800d84:	e8 04 f4 ff ff       	call   80018d <_panic>

00800d89 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da2:	89 df                	mov    %ebx,%edi
  800da4:	89 de                	mov    %ebx,%esi
  800da6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7f 08                	jg     800db4 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 0a                	push   $0xa
  800dba:	68 bf 27 80 00       	push   $0x8027bf
  800dbf:	6a 2a                	push   $0x2a
  800dc1:	68 dc 27 80 00       	push   $0x8027dc
  800dc6:	e8 c2 f3 ff ff       	call   80018d <_panic>

00800dcb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddc:	be 00 00 00 00       	mov    $0x0,%esi
  800de1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e04:	89 cb                	mov    %ecx,%ebx
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	89 ce                	mov    %ecx,%esi
  800e0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7f 08                	jg     800e18 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	50                   	push   %eax
  800e1c:	6a 0d                	push   $0xd
  800e1e:	68 bf 27 80 00       	push   $0x8027bf
  800e23:	6a 2a                	push   $0x2a
  800e25:	68 dc 27 80 00       	push   $0x8027dc
  800e2a:	e8 5e f3 ff ff       	call   80018d <_panic>

00800e2f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
  800e33:	56                   	push   %esi
  800e34:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e35:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e3f:	89 d1                	mov    %edx,%ecx
  800e41:	89 d3                	mov    %edx,%ebx
  800e43:	89 d7                	mov    %edx,%edi
  800e45:	89 d6                	mov    %edx,%esi
  800e47:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e64:	89 df                	mov    %ebx,%edi
  800e66:	89 de                	mov    %ebx,%esi
  800e68:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	b8 10 00 00 00       	mov    $0x10,%eax
  800e85:	89 df                	mov    %ebx,%edi
  800e87:	89 de                	mov    %ebx,%esi
  800e89:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e93:	8b 45 08             	mov    0x8(%ebp),%eax
  800e96:	05 00 00 00 30       	add    $0x30000000,%eax
  800e9b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eb0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ebf:	89 c2                	mov    %eax,%edx
  800ec1:	c1 ea 16             	shr    $0x16,%edx
  800ec4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecb:	f6 c2 01             	test   $0x1,%dl
  800ece:	74 29                	je     800ef9 <fd_alloc+0x42>
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	c1 ea 0c             	shr    $0xc,%edx
  800ed5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edc:	f6 c2 01             	test   $0x1,%dl
  800edf:	74 18                	je     800ef9 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800ee1:	05 00 10 00 00       	add    $0x1000,%eax
  800ee6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eeb:	75 d2                	jne    800ebf <fd_alloc+0x8>
  800eed:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800ef2:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800ef7:	eb 05                	jmp    800efe <fd_alloc+0x47>
			return 0;
  800ef9:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800efe:	8b 55 08             	mov    0x8(%ebp),%edx
  800f01:	89 02                	mov    %eax,(%edx)
}
  800f03:	89 c8                	mov    %ecx,%eax
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f0d:	83 f8 1f             	cmp    $0x1f,%eax
  800f10:	77 30                	ja     800f42 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f12:	c1 e0 0c             	shl    $0xc,%eax
  800f15:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f1a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f20:	f6 c2 01             	test   $0x1,%dl
  800f23:	74 24                	je     800f49 <fd_lookup+0x42>
  800f25:	89 c2                	mov    %eax,%edx
  800f27:	c1 ea 0c             	shr    $0xc,%edx
  800f2a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f31:	f6 c2 01             	test   $0x1,%dl
  800f34:	74 1a                	je     800f50 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f39:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
		return -E_INVAL;
  800f42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f47:	eb f7                	jmp    800f40 <fd_lookup+0x39>
		return -E_INVAL;
  800f49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4e:	eb f0                	jmp    800f40 <fd_lookup+0x39>
  800f50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f55:	eb e9                	jmp    800f40 <fd_lookup+0x39>

00800f57 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	53                   	push   %ebx
  800f5b:	83 ec 04             	sub    $0x4,%esp
  800f5e:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f61:	b8 00 00 00 00       	mov    $0x0,%eax
  800f66:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f6b:	39 13                	cmp    %edx,(%ebx)
  800f6d:	74 37                	je     800fa6 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f6f:	83 c0 01             	add    $0x1,%eax
  800f72:	8b 1c 85 68 28 80 00 	mov    0x802868(,%eax,4),%ebx
  800f79:	85 db                	test   %ebx,%ebx
  800f7b:	75 ee                	jne    800f6b <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f7d:	a1 00 60 80 00       	mov    0x806000,%eax
  800f82:	8b 40 48             	mov    0x48(%eax),%eax
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	52                   	push   %edx
  800f89:	50                   	push   %eax
  800f8a:	68 ec 27 80 00       	push   $0x8027ec
  800f8f:	e8 d4 f2 ff ff       	call   800268 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9f:	89 1a                	mov    %ebx,(%edx)
}
  800fa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    
			return 0;
  800fa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fab:	eb ef                	jmp    800f9c <dev_lookup+0x45>

00800fad <fd_close>:
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 24             	sub    $0x24,%esp
  800fb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fbc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fbf:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fc0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc6:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc9:	50                   	push   %eax
  800fca:	e8 38 ff ff ff       	call   800f07 <fd_lookup>
  800fcf:	89 c3                	mov    %eax,%ebx
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 05                	js     800fdd <fd_close+0x30>
	    || fd != fd2)
  800fd8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fdb:	74 16                	je     800ff3 <fd_close+0x46>
		return (must_exist ? r : 0);
  800fdd:	89 f8                	mov    %edi,%eax
  800fdf:	84 c0                	test   %al,%al
  800fe1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe6:	0f 44 d8             	cmove  %eax,%ebx
}
  800fe9:	89 d8                	mov    %ebx,%eax
  800feb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5f                   	pop    %edi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ff3:	83 ec 08             	sub    $0x8,%esp
  800ff6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ff9:	50                   	push   %eax
  800ffa:	ff 36                	push   (%esi)
  800ffc:	e8 56 ff ff ff       	call   800f57 <dev_lookup>
  801001:	89 c3                	mov    %eax,%ebx
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 1a                	js     801024 <fd_close+0x77>
		if (dev->dev_close)
  80100a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80100d:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801010:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801015:	85 c0                	test   %eax,%eax
  801017:	74 0b                	je     801024 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	56                   	push   %esi
  80101d:	ff d0                	call   *%eax
  80101f:	89 c3                	mov    %eax,%ebx
  801021:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	56                   	push   %esi
  801028:	6a 00                	push   $0x0
  80102a:	e8 94 fc ff ff       	call   800cc3 <sys_page_unmap>
	return r;
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	eb b5                	jmp    800fe9 <fd_close+0x3c>

00801034 <close>:

int
close(int fdnum)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80103a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103d:	50                   	push   %eax
  80103e:	ff 75 08             	push   0x8(%ebp)
  801041:	e8 c1 fe ff ff       	call   800f07 <fd_lookup>
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 02                	jns    80104f <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    
		return fd_close(fd, 1);
  80104f:	83 ec 08             	sub    $0x8,%esp
  801052:	6a 01                	push   $0x1
  801054:	ff 75 f4             	push   -0xc(%ebp)
  801057:	e8 51 ff ff ff       	call   800fad <fd_close>
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	eb ec                	jmp    80104d <close+0x19>

00801061 <close_all>:

void
close_all(void)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	53                   	push   %ebx
  801065:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801068:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	53                   	push   %ebx
  801071:	e8 be ff ff ff       	call   801034 <close>
	for (i = 0; i < MAXFD; i++)
  801076:	83 c3 01             	add    $0x1,%ebx
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	83 fb 20             	cmp    $0x20,%ebx
  80107f:	75 ec                	jne    80106d <close_all+0xc>
}
  801081:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	57                   	push   %edi
  80108a:	56                   	push   %esi
  80108b:	53                   	push   %ebx
  80108c:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80108f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801092:	50                   	push   %eax
  801093:	ff 75 08             	push   0x8(%ebp)
  801096:	e8 6c fe ff ff       	call   800f07 <fd_lookup>
  80109b:	89 c3                	mov    %eax,%ebx
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 7f                	js     801123 <dup+0x9d>
		return r;
	close(newfdnum);
  8010a4:	83 ec 0c             	sub    $0xc,%esp
  8010a7:	ff 75 0c             	push   0xc(%ebp)
  8010aa:	e8 85 ff ff ff       	call   801034 <close>

	newfd = INDEX2FD(newfdnum);
  8010af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b2:	c1 e6 0c             	shl    $0xc,%esi
  8010b5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010be:	89 3c 24             	mov    %edi,(%esp)
  8010c1:	e8 da fd ff ff       	call   800ea0 <fd2data>
  8010c6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010c8:	89 34 24             	mov    %esi,(%esp)
  8010cb:	e8 d0 fd ff ff       	call   800ea0 <fd2data>
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010d6:	89 d8                	mov    %ebx,%eax
  8010d8:	c1 e8 16             	shr    $0x16,%eax
  8010db:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e2:	a8 01                	test   $0x1,%al
  8010e4:	74 11                	je     8010f7 <dup+0x71>
  8010e6:	89 d8                	mov    %ebx,%eax
  8010e8:	c1 e8 0c             	shr    $0xc,%eax
  8010eb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f2:	f6 c2 01             	test   $0x1,%dl
  8010f5:	75 36                	jne    80112d <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f7:	89 f8                	mov    %edi,%eax
  8010f9:	c1 e8 0c             	shr    $0xc,%eax
  8010fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	25 07 0e 00 00       	and    $0xe07,%eax
  80110b:	50                   	push   %eax
  80110c:	56                   	push   %esi
  80110d:	6a 00                	push   $0x0
  80110f:	57                   	push   %edi
  801110:	6a 00                	push   $0x0
  801112:	e8 6a fb ff ff       	call   800c81 <sys_page_map>
  801117:	89 c3                	mov    %eax,%ebx
  801119:	83 c4 20             	add    $0x20,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 33                	js     801153 <dup+0xcd>
		goto err;

	return newfdnum;
  801120:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801123:	89 d8                	mov    %ebx,%eax
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80112d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	25 07 0e 00 00       	and    $0xe07,%eax
  80113c:	50                   	push   %eax
  80113d:	ff 75 d4             	push   -0x2c(%ebp)
  801140:	6a 00                	push   $0x0
  801142:	53                   	push   %ebx
  801143:	6a 00                	push   $0x0
  801145:	e8 37 fb ff ff       	call   800c81 <sys_page_map>
  80114a:	89 c3                	mov    %eax,%ebx
  80114c:	83 c4 20             	add    $0x20,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	79 a4                	jns    8010f7 <dup+0x71>
	sys_page_unmap(0, newfd);
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	56                   	push   %esi
  801157:	6a 00                	push   $0x0
  801159:	e8 65 fb ff ff       	call   800cc3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80115e:	83 c4 08             	add    $0x8,%esp
  801161:	ff 75 d4             	push   -0x2c(%ebp)
  801164:	6a 00                	push   $0x0
  801166:	e8 58 fb ff ff       	call   800cc3 <sys_page_unmap>
	return r;
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	eb b3                	jmp    801123 <dup+0x9d>

00801170 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	83 ec 18             	sub    $0x18,%esp
  801178:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	56                   	push   %esi
  801180:	e8 82 fd ff ff       	call   800f07 <fd_lookup>
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 3c                	js     8011c8 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	ff 33                	push   (%ebx)
  801198:	e8 ba fd ff ff       	call   800f57 <dev_lookup>
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 24                	js     8011c8 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011a4:	8b 43 08             	mov    0x8(%ebx),%eax
  8011a7:	83 e0 03             	and    $0x3,%eax
  8011aa:	83 f8 01             	cmp    $0x1,%eax
  8011ad:	74 20                	je     8011cf <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b2:	8b 40 08             	mov    0x8(%eax),%eax
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	74 37                	je     8011f0 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011b9:	83 ec 04             	sub    $0x4,%esp
  8011bc:	ff 75 10             	push   0x10(%ebp)
  8011bf:	ff 75 0c             	push   0xc(%ebp)
  8011c2:	53                   	push   %ebx
  8011c3:	ff d0                	call   *%eax
  8011c5:	83 c4 10             	add    $0x10,%esp
}
  8011c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cf:	a1 00 60 80 00       	mov    0x806000,%eax
  8011d4:	8b 40 48             	mov    0x48(%eax),%eax
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	56                   	push   %esi
  8011db:	50                   	push   %eax
  8011dc:	68 2d 28 80 00       	push   $0x80282d
  8011e1:	e8 82 f0 ff ff       	call   800268 <cprintf>
		return -E_INVAL;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ee:	eb d8                	jmp    8011c8 <read+0x58>
		return -E_NOT_SUPP;
  8011f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011f5:	eb d1                	jmp    8011c8 <read+0x58>

008011f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	57                   	push   %edi
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	8b 7d 08             	mov    0x8(%ebp),%edi
  801203:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801206:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120b:	eb 02                	jmp    80120f <readn+0x18>
  80120d:	01 c3                	add    %eax,%ebx
  80120f:	39 f3                	cmp    %esi,%ebx
  801211:	73 21                	jae    801234 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	89 f0                	mov    %esi,%eax
  801218:	29 d8                	sub    %ebx,%eax
  80121a:	50                   	push   %eax
  80121b:	89 d8                	mov    %ebx,%eax
  80121d:	03 45 0c             	add    0xc(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	57                   	push   %edi
  801222:	e8 49 ff ff ff       	call   801170 <read>
		if (m < 0)
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 04                	js     801232 <readn+0x3b>
			return m;
		if (m == 0)
  80122e:	75 dd                	jne    80120d <readn+0x16>
  801230:	eb 02                	jmp    801234 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801232:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801234:	89 d8                	mov    %ebx,%eax
  801236:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801239:	5b                   	pop    %ebx
  80123a:	5e                   	pop    %esi
  80123b:	5f                   	pop    %edi
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	56                   	push   %esi
  801242:	53                   	push   %ebx
  801243:	83 ec 18             	sub    $0x18,%esp
  801246:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801249:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	53                   	push   %ebx
  80124e:	e8 b4 fc ff ff       	call   800f07 <fd_lookup>
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	78 37                	js     801291 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80125d:	83 ec 08             	sub    $0x8,%esp
  801260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801263:	50                   	push   %eax
  801264:	ff 36                	push   (%esi)
  801266:	e8 ec fc ff ff       	call   800f57 <dev_lookup>
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 1f                	js     801291 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801272:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801276:	74 20                	je     801298 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127b:	8b 40 0c             	mov    0xc(%eax),%eax
  80127e:	85 c0                	test   %eax,%eax
  801280:	74 37                	je     8012b9 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801282:	83 ec 04             	sub    $0x4,%esp
  801285:	ff 75 10             	push   0x10(%ebp)
  801288:	ff 75 0c             	push   0xc(%ebp)
  80128b:	56                   	push   %esi
  80128c:	ff d0                	call   *%eax
  80128e:	83 c4 10             	add    $0x10,%esp
}
  801291:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801298:	a1 00 60 80 00       	mov    0x806000,%eax
  80129d:	8b 40 48             	mov    0x48(%eax),%eax
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	53                   	push   %ebx
  8012a4:	50                   	push   %eax
  8012a5:	68 49 28 80 00       	push   $0x802849
  8012aa:	e8 b9 ef ff ff       	call   800268 <cprintf>
		return -E_INVAL;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b7:	eb d8                	jmp    801291 <write+0x53>
		return -E_NOT_SUPP;
  8012b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012be:	eb d1                	jmp    801291 <write+0x53>

008012c0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	ff 75 08             	push   0x8(%ebp)
  8012cd:	e8 35 fc ff ff       	call   800f07 <fd_lookup>
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 0e                	js     8012e7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012df:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    

008012e9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	56                   	push   %esi
  8012ed:	53                   	push   %ebx
  8012ee:	83 ec 18             	sub    $0x18,%esp
  8012f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	53                   	push   %ebx
  8012f9:	e8 09 fc ff ff       	call   800f07 <fd_lookup>
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	78 34                	js     801339 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801305:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130e:	50                   	push   %eax
  80130f:	ff 36                	push   (%esi)
  801311:	e8 41 fc ff ff       	call   800f57 <dev_lookup>
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 1c                	js     801339 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801321:	74 1d                	je     801340 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801323:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801326:	8b 40 18             	mov    0x18(%eax),%eax
  801329:	85 c0                	test   %eax,%eax
  80132b:	74 34                	je     801361 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132d:	83 ec 08             	sub    $0x8,%esp
  801330:	ff 75 0c             	push   0xc(%ebp)
  801333:	56                   	push   %esi
  801334:	ff d0                	call   *%eax
  801336:	83 c4 10             	add    $0x10,%esp
}
  801339:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133c:	5b                   	pop    %ebx
  80133d:	5e                   	pop    %esi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    
			thisenv->env_id, fdnum);
  801340:	a1 00 60 80 00       	mov    0x806000,%eax
  801345:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801348:	83 ec 04             	sub    $0x4,%esp
  80134b:	53                   	push   %ebx
  80134c:	50                   	push   %eax
  80134d:	68 0c 28 80 00       	push   $0x80280c
  801352:	e8 11 ef ff ff       	call   800268 <cprintf>
		return -E_INVAL;
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135f:	eb d8                	jmp    801339 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801361:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801366:	eb d1                	jmp    801339 <ftruncate+0x50>

00801368 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	56                   	push   %esi
  80136c:	53                   	push   %ebx
  80136d:	83 ec 18             	sub    $0x18,%esp
  801370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801373:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 75 08             	push   0x8(%ebp)
  80137a:	e8 88 fb ff ff       	call   800f07 <fd_lookup>
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 49                	js     8013cf <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801386:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	ff 36                	push   (%esi)
  801392:	e8 c0 fb ff ff       	call   800f57 <dev_lookup>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 31                	js     8013cf <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80139e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013a5:	74 2f                	je     8013d6 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013b1:	00 00 00 
	stat->st_isdir = 0;
  8013b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013bb:	00 00 00 
	stat->st_dev = dev;
  8013be:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	53                   	push   %ebx
  8013c8:	56                   	push   %esi
  8013c9:	ff 50 14             	call   *0x14(%eax)
  8013cc:	83 c4 10             	add    $0x10,%esp
}
  8013cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d2:	5b                   	pop    %ebx
  8013d3:	5e                   	pop    %esi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    
		return -E_NOT_SUPP;
  8013d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013db:	eb f2                	jmp    8013cf <fstat+0x67>

008013dd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	6a 00                	push   $0x0
  8013e7:	ff 75 08             	push   0x8(%ebp)
  8013ea:	e8 e4 01 00 00       	call   8015d3 <open>
  8013ef:	89 c3                	mov    %eax,%ebx
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 1b                	js     801413 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	ff 75 0c             	push   0xc(%ebp)
  8013fe:	50                   	push   %eax
  8013ff:	e8 64 ff ff ff       	call   801368 <fstat>
  801404:	89 c6                	mov    %eax,%esi
	close(fd);
  801406:	89 1c 24             	mov    %ebx,(%esp)
  801409:	e8 26 fc ff ff       	call   801034 <close>
	return r;
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	89 f3                	mov    %esi,%ebx
}
  801413:	89 d8                	mov    %ebx,%eax
  801415:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	56                   	push   %esi
  801420:	53                   	push   %ebx
  801421:	89 c6                	mov    %eax,%esi
  801423:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801425:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80142c:	74 27                	je     801455 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80142e:	6a 07                	push   $0x7
  801430:	68 00 70 80 00       	push   $0x807000
  801435:	56                   	push   %esi
  801436:	ff 35 00 80 80 00    	push   0x808000
  80143c:	e8 d7 0c 00 00       	call   802118 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801441:	83 c4 0c             	add    $0xc,%esp
  801444:	6a 00                	push   $0x0
  801446:	53                   	push   %ebx
  801447:	6a 00                	push   $0x0
  801449:	e8 63 0c 00 00       	call   8020b1 <ipc_recv>
}
  80144e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	6a 01                	push   $0x1
  80145a:	e8 0d 0d 00 00       	call   80216c <ipc_find_env>
  80145f:	a3 00 80 80 00       	mov    %eax,0x808000
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	eb c5                	jmp    80142e <fsipc+0x12>

00801469 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	8b 40 0c             	mov    0xc(%eax),%eax
  801475:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80147a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147d:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801482:	ba 00 00 00 00       	mov    $0x0,%edx
  801487:	b8 02 00 00 00       	mov    $0x2,%eax
  80148c:	e8 8b ff ff ff       	call   80141c <fsipc>
}
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <devfile_flush>:
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801499:	8b 45 08             	mov    0x8(%ebp),%eax
  80149c:	8b 40 0c             	mov    0xc(%eax),%eax
  80149f:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8014a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a9:	b8 06 00 00 00       	mov    $0x6,%eax
  8014ae:	e8 69 ff ff ff       	call   80141c <fsipc>
}
  8014b3:	c9                   	leave  
  8014b4:	c3                   	ret    

008014b5 <devfile_stat>:
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 04             	sub    $0x4,%esp
  8014bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c5:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8014d4:	e8 43 ff ff ff       	call   80141c <fsipc>
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 2c                	js     801509 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	68 00 70 80 00       	push   $0x807000
  8014e5:	53                   	push   %ebx
  8014e6:	e8 57 f3 ff ff       	call   800842 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014eb:	a1 80 70 80 00       	mov    0x807080,%eax
  8014f0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014f6:	a1 84 70 80 00       	mov    0x807084,%eax
  8014fb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801509:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <devfile_write>:
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	83 ec 0c             	sub    $0xc,%esp
  801514:	8b 45 10             	mov    0x10(%ebp),%eax
  801517:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80151c:	39 d0                	cmp    %edx,%eax
  80151e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801521:	8b 55 08             	mov    0x8(%ebp),%edx
  801524:	8b 52 0c             	mov    0xc(%edx),%edx
  801527:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  80152d:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801532:	50                   	push   %eax
  801533:	ff 75 0c             	push   0xc(%ebp)
  801536:	68 08 70 80 00       	push   $0x807008
  80153b:	e8 98 f4 ff ff       	call   8009d8 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801540:	ba 00 00 00 00       	mov    $0x0,%edx
  801545:	b8 04 00 00 00       	mov    $0x4,%eax
  80154a:	e8 cd fe ff ff       	call   80141c <fsipc>
}
  80154f:	c9                   	leave  
  801550:	c3                   	ret    

00801551 <devfile_read>:
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	56                   	push   %esi
  801555:	53                   	push   %ebx
  801556:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801559:	8b 45 08             	mov    0x8(%ebp),%eax
  80155c:	8b 40 0c             	mov    0xc(%eax),%eax
  80155f:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801564:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80156a:	ba 00 00 00 00       	mov    $0x0,%edx
  80156f:	b8 03 00 00 00       	mov    $0x3,%eax
  801574:	e8 a3 fe ff ff       	call   80141c <fsipc>
  801579:	89 c3                	mov    %eax,%ebx
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 1f                	js     80159e <devfile_read+0x4d>
	assert(r <= n);
  80157f:	39 f0                	cmp    %esi,%eax
  801581:	77 24                	ja     8015a7 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801583:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801588:	7f 33                	jg     8015bd <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80158a:	83 ec 04             	sub    $0x4,%esp
  80158d:	50                   	push   %eax
  80158e:	68 00 70 80 00       	push   $0x807000
  801593:	ff 75 0c             	push   0xc(%ebp)
  801596:	e8 3d f4 ff ff       	call   8009d8 <memmove>
	return r;
  80159b:	83 c4 10             	add    $0x10,%esp
}
  80159e:	89 d8                	mov    %ebx,%eax
  8015a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a3:	5b                   	pop    %ebx
  8015a4:	5e                   	pop    %esi
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    
	assert(r <= n);
  8015a7:	68 7c 28 80 00       	push   $0x80287c
  8015ac:	68 83 28 80 00       	push   $0x802883
  8015b1:	6a 7c                	push   $0x7c
  8015b3:	68 98 28 80 00       	push   $0x802898
  8015b8:	e8 d0 eb ff ff       	call   80018d <_panic>
	assert(r <= PGSIZE);
  8015bd:	68 a3 28 80 00       	push   $0x8028a3
  8015c2:	68 83 28 80 00       	push   $0x802883
  8015c7:	6a 7d                	push   $0x7d
  8015c9:	68 98 28 80 00       	push   $0x802898
  8015ce:	e8 ba eb ff ff       	call   80018d <_panic>

008015d3 <open>:
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	56                   	push   %esi
  8015d7:	53                   	push   %ebx
  8015d8:	83 ec 1c             	sub    $0x1c,%esp
  8015db:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015de:	56                   	push   %esi
  8015df:	e8 23 f2 ff ff       	call   800807 <strlen>
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ec:	7f 6c                	jg     80165a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	e8 bd f8 ff ff       	call   800eb7 <fd_alloc>
  8015fa:	89 c3                	mov    %eax,%ebx
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 3c                	js     80163f <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	56                   	push   %esi
  801607:	68 00 70 80 00       	push   $0x807000
  80160c:	e8 31 f2 ff ff       	call   800842 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801611:	8b 45 0c             	mov    0xc(%ebp),%eax
  801614:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801619:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161c:	b8 01 00 00 00       	mov    $0x1,%eax
  801621:	e8 f6 fd ff ff       	call   80141c <fsipc>
  801626:	89 c3                	mov    %eax,%ebx
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 19                	js     801648 <open+0x75>
	return fd2num(fd);
  80162f:	83 ec 0c             	sub    $0xc,%esp
  801632:	ff 75 f4             	push   -0xc(%ebp)
  801635:	e8 56 f8 ff ff       	call   800e90 <fd2num>
  80163a:	89 c3                	mov    %eax,%ebx
  80163c:	83 c4 10             	add    $0x10,%esp
}
  80163f:	89 d8                	mov    %ebx,%eax
  801641:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801644:	5b                   	pop    %ebx
  801645:	5e                   	pop    %esi
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    
		fd_close(fd, 0);
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	6a 00                	push   $0x0
  80164d:	ff 75 f4             	push   -0xc(%ebp)
  801650:	e8 58 f9 ff ff       	call   800fad <fd_close>
		return r;
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	eb e5                	jmp    80163f <open+0x6c>
		return -E_BAD_PATH;
  80165a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80165f:	eb de                	jmp    80163f <open+0x6c>

00801661 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801667:	ba 00 00 00 00       	mov    $0x0,%edx
  80166c:	b8 08 00 00 00       	mov    $0x8,%eax
  801671:	e8 a6 fd ff ff       	call   80141c <fsipc>
}
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801678:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80167c:	7f 01                	jg     80167f <writebuf+0x7>
  80167e:	c3                   	ret    
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	53                   	push   %ebx
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801688:	ff 70 04             	push   0x4(%eax)
  80168b:	8d 40 10             	lea    0x10(%eax),%eax
  80168e:	50                   	push   %eax
  80168f:	ff 33                	push   (%ebx)
  801691:	e8 a8 fb ff ff       	call   80123e <write>
		if (result > 0)
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	85 c0                	test   %eax,%eax
  80169b:	7e 03                	jle    8016a0 <writebuf+0x28>
			b->result += result;
  80169d:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016a0:	39 43 04             	cmp    %eax,0x4(%ebx)
  8016a3:	74 0d                	je     8016b2 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ac:	0f 4f c2             	cmovg  %edx,%eax
  8016af:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <putch>:

static void
putch(int ch, void *thunk)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 04             	sub    $0x4,%esp
  8016be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016c1:	8b 53 04             	mov    0x4(%ebx),%edx
  8016c4:	8d 42 01             	lea    0x1(%edx),%eax
  8016c7:	89 43 04             	mov    %eax,0x4(%ebx)
  8016ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016cd:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016d1:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016d6:	74 05                	je     8016dd <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  8016d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016db:	c9                   	leave  
  8016dc:	c3                   	ret    
		writebuf(b);
  8016dd:	89 d8                	mov    %ebx,%eax
  8016df:	e8 94 ff ff ff       	call   801678 <writebuf>
		b->idx = 0;
  8016e4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8016eb:	eb eb                	jmp    8016d8 <putch+0x21>

008016ed <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016ff:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801706:	00 00 00 
	b.result = 0;
  801709:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801710:	00 00 00 
	b.error = 1;
  801713:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80171a:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80171d:	ff 75 10             	push   0x10(%ebp)
  801720:	ff 75 0c             	push   0xc(%ebp)
  801723:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	68 b7 16 80 00       	push   $0x8016b7
  80172f:	e8 2b ec ff ff       	call   80035f <vprintfmt>
	if (b.idx > 0)
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80173e:	7f 11                	jg     801751 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801740:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801746:	85 c0                	test   %eax,%eax
  801748:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80174f:	c9                   	leave  
  801750:	c3                   	ret    
		writebuf(&b);
  801751:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801757:	e8 1c ff ff ff       	call   801678 <writebuf>
  80175c:	eb e2                	jmp    801740 <vfprintf+0x53>

0080175e <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801764:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801767:	50                   	push   %eax
  801768:	ff 75 0c             	push   0xc(%ebp)
  80176b:	ff 75 08             	push   0x8(%ebp)
  80176e:	e8 7a ff ff ff       	call   8016ed <vfprintf>
	va_end(ap);

	return cnt;
}
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <printf>:

int
printf(const char *fmt, ...)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80177b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80177e:	50                   	push   %eax
  80177f:	ff 75 08             	push   0x8(%ebp)
  801782:	6a 01                	push   $0x1
  801784:	e8 64 ff ff ff       	call   8016ed <vfprintf>
	va_end(ap);

	return cnt;
}
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801791:	68 af 28 80 00       	push   $0x8028af
  801796:	ff 75 0c             	push   0xc(%ebp)
  801799:	e8 a4 f0 ff ff       	call   800842 <strcpy>
	return 0;
}
  80179e:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a3:	c9                   	leave  
  8017a4:	c3                   	ret    

008017a5 <devsock_close>:
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 10             	sub    $0x10,%esp
  8017ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8017af:	53                   	push   %ebx
  8017b0:	e8 f0 09 00 00       	call   8021a5 <pageref>
  8017b5:	89 c2                	mov    %eax,%edx
  8017b7:	83 c4 10             	add    $0x10,%esp
		return 0;
  8017ba:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8017bf:	83 fa 01             	cmp    $0x1,%edx
  8017c2:	74 05                	je     8017c9 <devsock_close+0x24>
}
  8017c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8017c9:	83 ec 0c             	sub    $0xc,%esp
  8017cc:	ff 73 0c             	push   0xc(%ebx)
  8017cf:	e8 b7 02 00 00       	call   801a8b <nsipc_close>
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	eb eb                	jmp    8017c4 <devsock_close+0x1f>

008017d9 <devsock_write>:
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017df:	6a 00                	push   $0x0
  8017e1:	ff 75 10             	push   0x10(%ebp)
  8017e4:	ff 75 0c             	push   0xc(%ebp)
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	ff 70 0c             	push   0xc(%eax)
  8017ed:	e8 79 03 00 00       	call   801b6b <nsipc_send>
}
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <devsock_read>:
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8017fa:	6a 00                	push   $0x0
  8017fc:	ff 75 10             	push   0x10(%ebp)
  8017ff:	ff 75 0c             	push   0xc(%ebp)
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	ff 70 0c             	push   0xc(%eax)
  801808:	e8 ef 02 00 00       	call   801afc <nsipc_recv>
}
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <fd2sockid>:
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801815:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801818:	52                   	push   %edx
  801819:	50                   	push   %eax
  80181a:	e8 e8 f6 ff ff       	call   800f07 <fd_lookup>
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	85 c0                	test   %eax,%eax
  801824:	78 10                	js     801836 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801826:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801829:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80182f:	39 08                	cmp    %ecx,(%eax)
  801831:	75 05                	jne    801838 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801833:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801836:	c9                   	leave  
  801837:	c3                   	ret    
		return -E_NOT_SUPP;
  801838:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80183d:	eb f7                	jmp    801836 <fd2sockid+0x27>

0080183f <alloc_sockfd>:
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	56                   	push   %esi
  801843:	53                   	push   %ebx
  801844:	83 ec 1c             	sub    $0x1c,%esp
  801847:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801849:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184c:	50                   	push   %eax
  80184d:	e8 65 f6 ff ff       	call   800eb7 <fd_alloc>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	78 43                	js     80189e <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80185b:	83 ec 04             	sub    $0x4,%esp
  80185e:	68 07 04 00 00       	push   $0x407
  801863:	ff 75 f4             	push   -0xc(%ebp)
  801866:	6a 00                	push   $0x0
  801868:	e8 d1 f3 ff ff       	call   800c3e <sys_page_alloc>
  80186d:	89 c3                	mov    %eax,%ebx
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	78 28                	js     80189e <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801879:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80187f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801884:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80188b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	50                   	push   %eax
  801892:	e8 f9 f5 ff ff       	call   800e90 <fd2num>
  801897:	89 c3                	mov    %eax,%ebx
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	eb 0c                	jmp    8018aa <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	56                   	push   %esi
  8018a2:	e8 e4 01 00 00       	call   801a8b <nsipc_close>
		return r;
  8018a7:	83 c4 10             	add    $0x10,%esp
}
  8018aa:	89 d8                	mov    %ebx,%eax
  8018ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5e                   	pop    %esi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <accept>:
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	e8 4e ff ff ff       	call   80180f <fd2sockid>
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	78 1b                	js     8018e0 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018c5:	83 ec 04             	sub    $0x4,%esp
  8018c8:	ff 75 10             	push   0x10(%ebp)
  8018cb:	ff 75 0c             	push   0xc(%ebp)
  8018ce:	50                   	push   %eax
  8018cf:	e8 0e 01 00 00       	call   8019e2 <nsipc_accept>
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 05                	js     8018e0 <accept+0x2d>
	return alloc_sockfd(r);
  8018db:	e8 5f ff ff ff       	call   80183f <alloc_sockfd>
}
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <bind>:
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018eb:	e8 1f ff ff ff       	call   80180f <fd2sockid>
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 12                	js     801906 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8018f4:	83 ec 04             	sub    $0x4,%esp
  8018f7:	ff 75 10             	push   0x10(%ebp)
  8018fa:	ff 75 0c             	push   0xc(%ebp)
  8018fd:	50                   	push   %eax
  8018fe:	e8 31 01 00 00       	call   801a34 <nsipc_bind>
  801903:	83 c4 10             	add    $0x10,%esp
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <shutdown>:
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80190e:	8b 45 08             	mov    0x8(%ebp),%eax
  801911:	e8 f9 fe ff ff       	call   80180f <fd2sockid>
  801916:	85 c0                	test   %eax,%eax
  801918:	78 0f                	js     801929 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	ff 75 0c             	push   0xc(%ebp)
  801920:	50                   	push   %eax
  801921:	e8 43 01 00 00       	call   801a69 <nsipc_shutdown>
  801926:	83 c4 10             	add    $0x10,%esp
}
  801929:	c9                   	leave  
  80192a:	c3                   	ret    

0080192b <connect>:
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801931:	8b 45 08             	mov    0x8(%ebp),%eax
  801934:	e8 d6 fe ff ff       	call   80180f <fd2sockid>
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 12                	js     80194f <connect+0x24>
	return nsipc_connect(r, name, namelen);
  80193d:	83 ec 04             	sub    $0x4,%esp
  801940:	ff 75 10             	push   0x10(%ebp)
  801943:	ff 75 0c             	push   0xc(%ebp)
  801946:	50                   	push   %eax
  801947:	e8 59 01 00 00       	call   801aa5 <nsipc_connect>
  80194c:	83 c4 10             	add    $0x10,%esp
}
  80194f:	c9                   	leave  
  801950:	c3                   	ret    

00801951 <listen>:
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
  80195a:	e8 b0 fe ff ff       	call   80180f <fd2sockid>
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 0f                	js     801972 <listen+0x21>
	return nsipc_listen(r, backlog);
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	ff 75 0c             	push   0xc(%ebp)
  801969:	50                   	push   %eax
  80196a:	e8 6b 01 00 00       	call   801ada <nsipc_listen>
  80196f:	83 c4 10             	add    $0x10,%esp
}
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <socket>:

int
socket(int domain, int type, int protocol)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80197a:	ff 75 10             	push   0x10(%ebp)
  80197d:	ff 75 0c             	push   0xc(%ebp)
  801980:	ff 75 08             	push   0x8(%ebp)
  801983:	e8 41 02 00 00       	call   801bc9 <nsipc_socket>
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	78 05                	js     801994 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80198f:	e8 ab fe ff ff       	call   80183f <alloc_sockfd>
}
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	53                   	push   %ebx
  80199a:	83 ec 04             	sub    $0x4,%esp
  80199d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80199f:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  8019a6:	74 26                	je     8019ce <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019a8:	6a 07                	push   $0x7
  8019aa:	68 00 90 80 00       	push   $0x809000
  8019af:	53                   	push   %ebx
  8019b0:	ff 35 00 a0 80 00    	push   0x80a000
  8019b6:	e8 5d 07 00 00       	call   802118 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019bb:	83 c4 0c             	add    $0xc,%esp
  8019be:	6a 00                	push   $0x0
  8019c0:	6a 00                	push   $0x0
  8019c2:	6a 00                	push   $0x0
  8019c4:	e8 e8 06 00 00       	call   8020b1 <ipc_recv>
}
  8019c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	6a 02                	push   $0x2
  8019d3:	e8 94 07 00 00       	call   80216c <ipc_find_env>
  8019d8:	a3 00 a0 80 00       	mov    %eax,0x80a000
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	eb c6                	jmp    8019a8 <nsipc+0x12>

008019e2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	56                   	push   %esi
  8019e6:	53                   	push   %ebx
  8019e7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8019ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ed:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8019f2:	8b 06                	mov    (%esi),%eax
  8019f4:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8019f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fe:	e8 93 ff ff ff       	call   801996 <nsipc>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	85 c0                	test   %eax,%eax
  801a07:	79 09                	jns    801a12 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801a09:	89 d8                	mov    %ebx,%eax
  801a0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a12:	83 ec 04             	sub    $0x4,%esp
  801a15:	ff 35 10 90 80 00    	push   0x809010
  801a1b:	68 00 90 80 00       	push   $0x809000
  801a20:	ff 75 0c             	push   0xc(%ebp)
  801a23:	e8 b0 ef ff ff       	call   8009d8 <memmove>
		*addrlen = ret->ret_addrlen;
  801a28:	a1 10 90 80 00       	mov    0x809010,%eax
  801a2d:	89 06                	mov    %eax,(%esi)
  801a2f:	83 c4 10             	add    $0x10,%esp
	return r;
  801a32:	eb d5                	jmp    801a09 <nsipc_accept+0x27>

00801a34 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	53                   	push   %ebx
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a46:	53                   	push   %ebx
  801a47:	ff 75 0c             	push   0xc(%ebp)
  801a4a:	68 04 90 80 00       	push   $0x809004
  801a4f:	e8 84 ef ff ff       	call   8009d8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a54:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  801a5a:	b8 02 00 00 00       	mov    $0x2,%eax
  801a5f:	e8 32 ff ff ff       	call   801996 <nsipc>
}
  801a64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    

00801a69 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a72:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  801a77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7a:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  801a7f:	b8 03 00 00 00       	mov    $0x3,%eax
  801a84:	e8 0d ff ff ff       	call   801996 <nsipc>
}
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <nsipc_close>:

int
nsipc_close(int s)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a91:	8b 45 08             	mov    0x8(%ebp),%eax
  801a94:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  801a99:	b8 04 00 00 00       	mov    $0x4,%eax
  801a9e:	e8 f3 fe ff ff       	call   801996 <nsipc>
}
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 08             	sub    $0x8,%esp
  801aac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab2:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ab7:	53                   	push   %ebx
  801ab8:	ff 75 0c             	push   0xc(%ebp)
  801abb:	68 04 90 80 00       	push   $0x809004
  801ac0:	e8 13 ef ff ff       	call   8009d8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ac5:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  801acb:	b8 05 00 00 00       	mov    $0x5,%eax
  801ad0:	e8 c1 fe ff ff       	call   801996 <nsipc>
}
  801ad5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  801ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aeb:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  801af0:	b8 06 00 00 00       	mov    $0x6,%eax
  801af5:	e8 9c fe ff ff       	call   801996 <nsipc>
}
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    

00801afc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b04:	8b 45 08             	mov    0x8(%ebp),%eax
  801b07:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  801b0c:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  801b12:	8b 45 14             	mov    0x14(%ebp),%eax
  801b15:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b1a:	b8 07 00 00 00       	mov    $0x7,%eax
  801b1f:	e8 72 fe ff ff       	call   801996 <nsipc>
  801b24:	89 c3                	mov    %eax,%ebx
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 22                	js     801b4c <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801b2a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801b2f:	39 c6                	cmp    %eax,%esi
  801b31:	0f 4e c6             	cmovle %esi,%eax
  801b34:	39 c3                	cmp    %eax,%ebx
  801b36:	7f 1d                	jg     801b55 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b38:	83 ec 04             	sub    $0x4,%esp
  801b3b:	53                   	push   %ebx
  801b3c:	68 00 90 80 00       	push   $0x809000
  801b41:	ff 75 0c             	push   0xc(%ebp)
  801b44:	e8 8f ee ff ff       	call   8009d8 <memmove>
  801b49:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b4c:	89 d8                	mov    %ebx,%eax
  801b4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801b55:	68 bb 28 80 00       	push   $0x8028bb
  801b5a:	68 83 28 80 00       	push   $0x802883
  801b5f:	6a 62                	push   $0x62
  801b61:	68 d0 28 80 00       	push   $0x8028d0
  801b66:	e8 22 e6 ff ff       	call   80018d <_panic>

00801b6b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	53                   	push   %ebx
  801b6f:	83 ec 04             	sub    $0x4,%esp
  801b72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b75:	8b 45 08             	mov    0x8(%ebp),%eax
  801b78:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  801b7d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b83:	7f 2e                	jg     801bb3 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b85:	83 ec 04             	sub    $0x4,%esp
  801b88:	53                   	push   %ebx
  801b89:	ff 75 0c             	push   0xc(%ebp)
  801b8c:	68 0c 90 80 00       	push   $0x80900c
  801b91:	e8 42 ee ff ff       	call   8009d8 <memmove>
	nsipcbuf.send.req_size = size;
  801b96:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  801b9c:	8b 45 14             	mov    0x14(%ebp),%eax
  801b9f:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  801ba4:	b8 08 00 00 00       	mov    $0x8,%eax
  801ba9:	e8 e8 fd ff ff       	call   801996 <nsipc>
}
  801bae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    
	assert(size < 1600);
  801bb3:	68 dc 28 80 00       	push   $0x8028dc
  801bb8:	68 83 28 80 00       	push   $0x802883
  801bbd:	6a 6d                	push   $0x6d
  801bbf:	68 d0 28 80 00       	push   $0x8028d0
  801bc4:	e8 c4 e5 ff ff       	call   80018d <_panic>

00801bc9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd2:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  801bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bda:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  801bdf:	8b 45 10             	mov    0x10(%ebp),%eax
  801be2:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  801be7:	b8 09 00 00 00       	mov    $0x9,%eax
  801bec:	e8 a5 fd ff ff       	call   801996 <nsipc>
}
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    

00801bf3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
  801bf8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bfb:	83 ec 0c             	sub    $0xc,%esp
  801bfe:	ff 75 08             	push   0x8(%ebp)
  801c01:	e8 9a f2 ff ff       	call   800ea0 <fd2data>
  801c06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c08:	83 c4 08             	add    $0x8,%esp
  801c0b:	68 e8 28 80 00       	push   $0x8028e8
  801c10:	53                   	push   %ebx
  801c11:	e8 2c ec ff ff       	call   800842 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c16:	8b 46 04             	mov    0x4(%esi),%eax
  801c19:	2b 06                	sub    (%esi),%eax
  801c1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c28:	00 00 00 
	stat->st_dev = &devpipe;
  801c2b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801c32:	30 80 00 
	return 0;
}
  801c35:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	53                   	push   %ebx
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c4b:	53                   	push   %ebx
  801c4c:	6a 00                	push   $0x0
  801c4e:	e8 70 f0 ff ff       	call   800cc3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c53:	89 1c 24             	mov    %ebx,(%esp)
  801c56:	e8 45 f2 ff ff       	call   800ea0 <fd2data>
  801c5b:	83 c4 08             	add    $0x8,%esp
  801c5e:	50                   	push   %eax
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 5d f0 ff ff       	call   800cc3 <sys_page_unmap>
}
  801c66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    

00801c6b <_pipeisclosed>:
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	57                   	push   %edi
  801c6f:	56                   	push   %esi
  801c70:	53                   	push   %ebx
  801c71:	83 ec 1c             	sub    $0x1c,%esp
  801c74:	89 c7                	mov    %eax,%edi
  801c76:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c78:	a1 00 60 80 00       	mov    0x806000,%eax
  801c7d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c80:	83 ec 0c             	sub    $0xc,%esp
  801c83:	57                   	push   %edi
  801c84:	e8 1c 05 00 00       	call   8021a5 <pageref>
  801c89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c8c:	89 34 24             	mov    %esi,(%esp)
  801c8f:	e8 11 05 00 00       	call   8021a5 <pageref>
		nn = thisenv->env_runs;
  801c94:	8b 15 00 60 80 00    	mov    0x806000,%edx
  801c9a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	39 cb                	cmp    %ecx,%ebx
  801ca2:	74 1b                	je     801cbf <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ca4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ca7:	75 cf                	jne    801c78 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ca9:	8b 42 58             	mov    0x58(%edx),%eax
  801cac:	6a 01                	push   $0x1
  801cae:	50                   	push   %eax
  801caf:	53                   	push   %ebx
  801cb0:	68 ef 28 80 00       	push   $0x8028ef
  801cb5:	e8 ae e5 ff ff       	call   800268 <cprintf>
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	eb b9                	jmp    801c78 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801cbf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cc2:	0f 94 c0             	sete   %al
  801cc5:	0f b6 c0             	movzbl %al,%eax
}
  801cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5f                   	pop    %edi
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <devpipe_write>:
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	57                   	push   %edi
  801cd4:	56                   	push   %esi
  801cd5:	53                   	push   %ebx
  801cd6:	83 ec 28             	sub    $0x28,%esp
  801cd9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801cdc:	56                   	push   %esi
  801cdd:	e8 be f1 ff ff       	call   800ea0 <fd2data>
  801ce2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	bf 00 00 00 00       	mov    $0x0,%edi
  801cec:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cef:	75 09                	jne    801cfa <devpipe_write+0x2a>
	return i;
  801cf1:	89 f8                	mov    %edi,%eax
  801cf3:	eb 23                	jmp    801d18 <devpipe_write+0x48>
			sys_yield();
  801cf5:	e8 25 ef ff ff       	call   800c1f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cfa:	8b 43 04             	mov    0x4(%ebx),%eax
  801cfd:	8b 0b                	mov    (%ebx),%ecx
  801cff:	8d 51 20             	lea    0x20(%ecx),%edx
  801d02:	39 d0                	cmp    %edx,%eax
  801d04:	72 1a                	jb     801d20 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801d06:	89 da                	mov    %ebx,%edx
  801d08:	89 f0                	mov    %esi,%eax
  801d0a:	e8 5c ff ff ff       	call   801c6b <_pipeisclosed>
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	74 e2                	je     801cf5 <devpipe_write+0x25>
				return 0;
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1b:	5b                   	pop    %ebx
  801d1c:	5e                   	pop    %esi
  801d1d:	5f                   	pop    %edi
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d23:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d27:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d2a:	89 c2                	mov    %eax,%edx
  801d2c:	c1 fa 1f             	sar    $0x1f,%edx
  801d2f:	89 d1                	mov    %edx,%ecx
  801d31:	c1 e9 1b             	shr    $0x1b,%ecx
  801d34:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d37:	83 e2 1f             	and    $0x1f,%edx
  801d3a:	29 ca                	sub    %ecx,%edx
  801d3c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d40:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d44:	83 c0 01             	add    $0x1,%eax
  801d47:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d4a:	83 c7 01             	add    $0x1,%edi
  801d4d:	eb 9d                	jmp    801cec <devpipe_write+0x1c>

00801d4f <devpipe_read>:
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	57                   	push   %edi
  801d53:	56                   	push   %esi
  801d54:	53                   	push   %ebx
  801d55:	83 ec 18             	sub    $0x18,%esp
  801d58:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d5b:	57                   	push   %edi
  801d5c:	e8 3f f1 ff ff       	call   800ea0 <fd2data>
  801d61:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	be 00 00 00 00       	mov    $0x0,%esi
  801d6b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d6e:	75 13                	jne    801d83 <devpipe_read+0x34>
	return i;
  801d70:	89 f0                	mov    %esi,%eax
  801d72:	eb 02                	jmp    801d76 <devpipe_read+0x27>
				return i;
  801d74:	89 f0                	mov    %esi,%eax
}
  801d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5f                   	pop    %edi
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    
			sys_yield();
  801d7e:	e8 9c ee ff ff       	call   800c1f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d83:	8b 03                	mov    (%ebx),%eax
  801d85:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d88:	75 18                	jne    801da2 <devpipe_read+0x53>
			if (i > 0)
  801d8a:	85 f6                	test   %esi,%esi
  801d8c:	75 e6                	jne    801d74 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801d8e:	89 da                	mov    %ebx,%edx
  801d90:	89 f8                	mov    %edi,%eax
  801d92:	e8 d4 fe ff ff       	call   801c6b <_pipeisclosed>
  801d97:	85 c0                	test   %eax,%eax
  801d99:	74 e3                	je     801d7e <devpipe_read+0x2f>
				return 0;
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801da0:	eb d4                	jmp    801d76 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801da2:	99                   	cltd   
  801da3:	c1 ea 1b             	shr    $0x1b,%edx
  801da6:	01 d0                	add    %edx,%eax
  801da8:	83 e0 1f             	and    $0x1f,%eax
  801dab:	29 d0                	sub    %edx,%eax
  801dad:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801db8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dbb:	83 c6 01             	add    $0x1,%esi
  801dbe:	eb ab                	jmp    801d6b <devpipe_read+0x1c>

00801dc0 <pipe>:
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	56                   	push   %esi
  801dc4:	53                   	push   %ebx
  801dc5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801dc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcb:	50                   	push   %eax
  801dcc:	e8 e6 f0 ff ff       	call   800eb7 <fd_alloc>
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	0f 88 23 01 00 00    	js     801f01 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dde:	83 ec 04             	sub    $0x4,%esp
  801de1:	68 07 04 00 00       	push   $0x407
  801de6:	ff 75 f4             	push   -0xc(%ebp)
  801de9:	6a 00                	push   $0x0
  801deb:	e8 4e ee ff ff       	call   800c3e <sys_page_alloc>
  801df0:	89 c3                	mov    %eax,%ebx
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	85 c0                	test   %eax,%eax
  801df7:	0f 88 04 01 00 00    	js     801f01 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801dfd:	83 ec 0c             	sub    $0xc,%esp
  801e00:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e03:	50                   	push   %eax
  801e04:	e8 ae f0 ff ff       	call   800eb7 <fd_alloc>
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	83 c4 10             	add    $0x10,%esp
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	0f 88 db 00 00 00    	js     801ef1 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e16:	83 ec 04             	sub    $0x4,%esp
  801e19:	68 07 04 00 00       	push   $0x407
  801e1e:	ff 75 f0             	push   -0x10(%ebp)
  801e21:	6a 00                	push   $0x0
  801e23:	e8 16 ee ff ff       	call   800c3e <sys_page_alloc>
  801e28:	89 c3                	mov    %eax,%ebx
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	0f 88 bc 00 00 00    	js     801ef1 <pipe+0x131>
	va = fd2data(fd0);
  801e35:	83 ec 0c             	sub    $0xc,%esp
  801e38:	ff 75 f4             	push   -0xc(%ebp)
  801e3b:	e8 60 f0 ff ff       	call   800ea0 <fd2data>
  801e40:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e42:	83 c4 0c             	add    $0xc,%esp
  801e45:	68 07 04 00 00       	push   $0x407
  801e4a:	50                   	push   %eax
  801e4b:	6a 00                	push   $0x0
  801e4d:	e8 ec ed ff ff       	call   800c3e <sys_page_alloc>
  801e52:	89 c3                	mov    %eax,%ebx
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	85 c0                	test   %eax,%eax
  801e59:	0f 88 82 00 00 00    	js     801ee1 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5f:	83 ec 0c             	sub    $0xc,%esp
  801e62:	ff 75 f0             	push   -0x10(%ebp)
  801e65:	e8 36 f0 ff ff       	call   800ea0 <fd2data>
  801e6a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e71:	50                   	push   %eax
  801e72:	6a 00                	push   $0x0
  801e74:	56                   	push   %esi
  801e75:	6a 00                	push   $0x0
  801e77:	e8 05 ee ff ff       	call   800c81 <sys_page_map>
  801e7c:	89 c3                	mov    %eax,%ebx
  801e7e:	83 c4 20             	add    $0x20,%esp
  801e81:	85 c0                	test   %eax,%eax
  801e83:	78 4e                	js     801ed3 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801e85:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801e8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e8d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e92:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e99:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e9c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ea8:	83 ec 0c             	sub    $0xc,%esp
  801eab:	ff 75 f4             	push   -0xc(%ebp)
  801eae:	e8 dd ef ff ff       	call   800e90 <fd2num>
  801eb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eb6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801eb8:	83 c4 04             	add    $0x4,%esp
  801ebb:	ff 75 f0             	push   -0x10(%ebp)
  801ebe:	e8 cd ef ff ff       	call   800e90 <fd2num>
  801ec3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ed1:	eb 2e                	jmp    801f01 <pipe+0x141>
	sys_page_unmap(0, va);
  801ed3:	83 ec 08             	sub    $0x8,%esp
  801ed6:	56                   	push   %esi
  801ed7:	6a 00                	push   $0x0
  801ed9:	e8 e5 ed ff ff       	call   800cc3 <sys_page_unmap>
  801ede:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ee1:	83 ec 08             	sub    $0x8,%esp
  801ee4:	ff 75 f0             	push   -0x10(%ebp)
  801ee7:	6a 00                	push   $0x0
  801ee9:	e8 d5 ed ff ff       	call   800cc3 <sys_page_unmap>
  801eee:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ef1:	83 ec 08             	sub    $0x8,%esp
  801ef4:	ff 75 f4             	push   -0xc(%ebp)
  801ef7:	6a 00                	push   $0x0
  801ef9:	e8 c5 ed ff ff       	call   800cc3 <sys_page_unmap>
  801efe:	83 c4 10             	add    $0x10,%esp
}
  801f01:	89 d8                	mov    %ebx,%eax
  801f03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f06:	5b                   	pop    %ebx
  801f07:	5e                   	pop    %esi
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    

00801f0a <pipeisclosed>:
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f13:	50                   	push   %eax
  801f14:	ff 75 08             	push   0x8(%ebp)
  801f17:	e8 eb ef ff ff       	call   800f07 <fd_lookup>
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 18                	js     801f3b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801f23:	83 ec 0c             	sub    $0xc,%esp
  801f26:	ff 75 f4             	push   -0xc(%ebp)
  801f29:	e8 72 ef ff ff       	call   800ea0 <fd2data>
  801f2e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f33:	e8 33 fd ff ff       	call   801c6b <_pipeisclosed>
  801f38:	83 c4 10             	add    $0x10,%esp
}
  801f3b:	c9                   	leave  
  801f3c:	c3                   	ret    

00801f3d <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f42:	c3                   	ret    

00801f43 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f49:	68 07 29 80 00       	push   $0x802907
  801f4e:	ff 75 0c             	push   0xc(%ebp)
  801f51:	e8 ec e8 ff ff       	call   800842 <strcpy>
	return 0;
}
  801f56:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <devcons_write>:
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	57                   	push   %edi
  801f61:	56                   	push   %esi
  801f62:	53                   	push   %ebx
  801f63:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f69:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f6e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f74:	eb 2e                	jmp    801fa4 <devcons_write+0x47>
		m = n - tot;
  801f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f79:	29 f3                	sub    %esi,%ebx
  801f7b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f80:	39 c3                	cmp    %eax,%ebx
  801f82:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f85:	83 ec 04             	sub    $0x4,%esp
  801f88:	53                   	push   %ebx
  801f89:	89 f0                	mov    %esi,%eax
  801f8b:	03 45 0c             	add    0xc(%ebp),%eax
  801f8e:	50                   	push   %eax
  801f8f:	57                   	push   %edi
  801f90:	e8 43 ea ff ff       	call   8009d8 <memmove>
		sys_cputs(buf, m);
  801f95:	83 c4 08             	add    $0x8,%esp
  801f98:	53                   	push   %ebx
  801f99:	57                   	push   %edi
  801f9a:	e8 e3 eb ff ff       	call   800b82 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f9f:	01 de                	add    %ebx,%esi
  801fa1:	83 c4 10             	add    $0x10,%esp
  801fa4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fa7:	72 cd                	jb     801f76 <devcons_write+0x19>
}
  801fa9:	89 f0                	mov    %esi,%eax
  801fab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fae:	5b                   	pop    %ebx
  801faf:	5e                   	pop    %esi
  801fb0:	5f                   	pop    %edi
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    

00801fb3 <devcons_read>:
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	83 ec 08             	sub    $0x8,%esp
  801fb9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fc2:	75 07                	jne    801fcb <devcons_read+0x18>
  801fc4:	eb 1f                	jmp    801fe5 <devcons_read+0x32>
		sys_yield();
  801fc6:	e8 54 ec ff ff       	call   800c1f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801fcb:	e8 d0 eb ff ff       	call   800ba0 <sys_cgetc>
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	74 f2                	je     801fc6 <devcons_read+0x13>
	if (c < 0)
  801fd4:	78 0f                	js     801fe5 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801fd6:	83 f8 04             	cmp    $0x4,%eax
  801fd9:	74 0c                	je     801fe7 <devcons_read+0x34>
	*(char*)vbuf = c;
  801fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fde:	88 02                	mov    %al,(%edx)
	return 1;
  801fe0:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    
		return 0;
  801fe7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fec:	eb f7                	jmp    801fe5 <devcons_read+0x32>

00801fee <cputchar>:
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff7:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ffa:	6a 01                	push   $0x1
  801ffc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fff:	50                   	push   %eax
  802000:	e8 7d eb ff ff       	call   800b82 <sys_cputs>
}
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	c9                   	leave  
  802009:	c3                   	ret    

0080200a <getchar>:
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802010:	6a 01                	push   $0x1
  802012:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802015:	50                   	push   %eax
  802016:	6a 00                	push   $0x0
  802018:	e8 53 f1 ff ff       	call   801170 <read>
	if (r < 0)
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	85 c0                	test   %eax,%eax
  802022:	78 06                	js     80202a <getchar+0x20>
	if (r < 1)
  802024:	74 06                	je     80202c <getchar+0x22>
	return c;
  802026:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    
		return -E_EOF;
  80202c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802031:	eb f7                	jmp    80202a <getchar+0x20>

00802033 <iscons>:
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203c:	50                   	push   %eax
  80203d:	ff 75 08             	push   0x8(%ebp)
  802040:	e8 c2 ee ff ff       	call   800f07 <fd_lookup>
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	85 c0                	test   %eax,%eax
  80204a:	78 11                	js     80205d <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80204c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802055:	39 10                	cmp    %edx,(%eax)
  802057:	0f 94 c0             	sete   %al
  80205a:	0f b6 c0             	movzbl %al,%eax
}
  80205d:	c9                   	leave  
  80205e:	c3                   	ret    

0080205f <opencons>:
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802065:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802068:	50                   	push   %eax
  802069:	e8 49 ee ff ff       	call   800eb7 <fd_alloc>
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	78 3a                	js     8020af <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802075:	83 ec 04             	sub    $0x4,%esp
  802078:	68 07 04 00 00       	push   $0x407
  80207d:	ff 75 f4             	push   -0xc(%ebp)
  802080:	6a 00                	push   $0x0
  802082:	e8 b7 eb ff ff       	call   800c3e <sys_page_alloc>
  802087:	83 c4 10             	add    $0x10,%esp
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 21                	js     8020af <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80208e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802091:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802097:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802099:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020a3:	83 ec 0c             	sub    $0xc,%esp
  8020a6:	50                   	push   %eax
  8020a7:	e8 e4 ed ff ff       	call   800e90 <fd2num>
  8020ac:	83 c4 10             	add    $0x10,%esp
}
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    

008020b1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	56                   	push   %esi
  8020b5:	53                   	push   %ebx
  8020b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020c6:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8020c9:	83 ec 0c             	sub    $0xc,%esp
  8020cc:	50                   	push   %eax
  8020cd:	e8 1c ed ff ff       	call   800dee <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8020d2:	83 c4 10             	add    $0x10,%esp
  8020d5:	85 f6                	test   %esi,%esi
  8020d7:	74 14                	je     8020ed <ipc_recv+0x3c>
  8020d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	78 09                	js     8020eb <ipc_recv+0x3a>
  8020e2:	8b 15 00 60 80 00    	mov    0x806000,%edx
  8020e8:	8b 52 74             	mov    0x74(%edx),%edx
  8020eb:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8020ed:	85 db                	test   %ebx,%ebx
  8020ef:	74 14                	je     802105 <ipc_recv+0x54>
  8020f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	78 09                	js     802103 <ipc_recv+0x52>
  8020fa:	8b 15 00 60 80 00    	mov    0x806000,%edx
  802100:	8b 52 78             	mov    0x78(%edx),%edx
  802103:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802105:	85 c0                	test   %eax,%eax
  802107:	78 08                	js     802111 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802109:	a1 00 60 80 00       	mov    0x806000,%eax
  80210e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    

00802118 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	57                   	push   %edi
  80211c:	56                   	push   %esi
  80211d:	53                   	push   %ebx
  80211e:	83 ec 0c             	sub    $0xc,%esp
  802121:	8b 7d 08             	mov    0x8(%ebp),%edi
  802124:	8b 75 0c             	mov    0xc(%ebp),%esi
  802127:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80212a:	85 db                	test   %ebx,%ebx
  80212c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802131:	0f 44 d8             	cmove  %eax,%ebx
  802134:	eb 05                	jmp    80213b <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802136:	e8 e4 ea ff ff       	call   800c1f <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80213b:	ff 75 14             	push   0x14(%ebp)
  80213e:	53                   	push   %ebx
  80213f:	56                   	push   %esi
  802140:	57                   	push   %edi
  802141:	e8 85 ec ff ff       	call   800dcb <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80214c:	74 e8                	je     802136 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80214e:	85 c0                	test   %eax,%eax
  802150:	78 08                	js     80215a <ipc_send+0x42>
	}while (r<0);

}
  802152:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5f                   	pop    %edi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80215a:	50                   	push   %eax
  80215b:	68 13 29 80 00       	push   $0x802913
  802160:	6a 3d                	push   $0x3d
  802162:	68 27 29 80 00       	push   $0x802927
  802167:	e8 21 e0 ff ff       	call   80018d <_panic>

0080216c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802172:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802177:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80217a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802180:	8b 52 50             	mov    0x50(%edx),%edx
  802183:	39 ca                	cmp    %ecx,%edx
  802185:	74 11                	je     802198 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802187:	83 c0 01             	add    $0x1,%eax
  80218a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80218f:	75 e6                	jne    802177 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802191:	b8 00 00 00 00       	mov    $0x0,%eax
  802196:	eb 0b                	jmp    8021a3 <ipc_find_env+0x37>
			return envs[i].env_id;
  802198:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80219b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021a0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    

008021a5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ab:	89 c2                	mov    %eax,%edx
  8021ad:	c1 ea 16             	shr    $0x16,%edx
  8021b0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8021b7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8021bc:	f6 c1 01             	test   $0x1,%cl
  8021bf:	74 1c                	je     8021dd <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8021c1:	c1 e8 0c             	shr    $0xc,%eax
  8021c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021cb:	a8 01                	test   $0x1,%al
  8021cd:	74 0e                	je     8021dd <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021cf:	c1 e8 0c             	shr    $0xc,%eax
  8021d2:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8021d9:	ef 
  8021da:	0f b7 d2             	movzwl %dx,%edx
}
  8021dd:	89 d0                	mov    %edx,%eax
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    
  8021e1:	66 90                	xchg   %ax,%ax
  8021e3:	66 90                	xchg   %ax,%ax
  8021e5:	66 90                	xchg   %ax,%ax
  8021e7:	66 90                	xchg   %ax,%ax
  8021e9:	66 90                	xchg   %ax,%ax
  8021eb:	66 90                	xchg   %ax,%ax
  8021ed:	66 90                	xchg   %ax,%ax
  8021ef:	90                   	nop

008021f0 <__udivdi3>:
  8021f0:	f3 0f 1e fb          	endbr32 
  8021f4:	55                   	push   %ebp
  8021f5:	57                   	push   %edi
  8021f6:	56                   	push   %esi
  8021f7:	53                   	push   %ebx
  8021f8:	83 ec 1c             	sub    $0x1c,%esp
  8021fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802203:	8b 74 24 34          	mov    0x34(%esp),%esi
  802207:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80220b:	85 c0                	test   %eax,%eax
  80220d:	75 19                	jne    802228 <__udivdi3+0x38>
  80220f:	39 f3                	cmp    %esi,%ebx
  802211:	76 4d                	jbe    802260 <__udivdi3+0x70>
  802213:	31 ff                	xor    %edi,%edi
  802215:	89 e8                	mov    %ebp,%eax
  802217:	89 f2                	mov    %esi,%edx
  802219:	f7 f3                	div    %ebx
  80221b:	89 fa                	mov    %edi,%edx
  80221d:	83 c4 1c             	add    $0x1c,%esp
  802220:	5b                   	pop    %ebx
  802221:	5e                   	pop    %esi
  802222:	5f                   	pop    %edi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    
  802225:	8d 76 00             	lea    0x0(%esi),%esi
  802228:	39 f0                	cmp    %esi,%eax
  80222a:	76 14                	jbe    802240 <__udivdi3+0x50>
  80222c:	31 ff                	xor    %edi,%edi
  80222e:	31 c0                	xor    %eax,%eax
  802230:	89 fa                	mov    %edi,%edx
  802232:	83 c4 1c             	add    $0x1c,%esp
  802235:	5b                   	pop    %ebx
  802236:	5e                   	pop    %esi
  802237:	5f                   	pop    %edi
  802238:	5d                   	pop    %ebp
  802239:	c3                   	ret    
  80223a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802240:	0f bd f8             	bsr    %eax,%edi
  802243:	83 f7 1f             	xor    $0x1f,%edi
  802246:	75 48                	jne    802290 <__udivdi3+0xa0>
  802248:	39 f0                	cmp    %esi,%eax
  80224a:	72 06                	jb     802252 <__udivdi3+0x62>
  80224c:	31 c0                	xor    %eax,%eax
  80224e:	39 eb                	cmp    %ebp,%ebx
  802250:	77 de                	ja     802230 <__udivdi3+0x40>
  802252:	b8 01 00 00 00       	mov    $0x1,%eax
  802257:	eb d7                	jmp    802230 <__udivdi3+0x40>
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 d9                	mov    %ebx,%ecx
  802262:	85 db                	test   %ebx,%ebx
  802264:	75 0b                	jne    802271 <__udivdi3+0x81>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f3                	div    %ebx
  80226f:	89 c1                	mov    %eax,%ecx
  802271:	31 d2                	xor    %edx,%edx
  802273:	89 f0                	mov    %esi,%eax
  802275:	f7 f1                	div    %ecx
  802277:	89 c6                	mov    %eax,%esi
  802279:	89 e8                	mov    %ebp,%eax
  80227b:	89 f7                	mov    %esi,%edi
  80227d:	f7 f1                	div    %ecx
  80227f:	89 fa                	mov    %edi,%edx
  802281:	83 c4 1c             	add    $0x1c,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 f9                	mov    %edi,%ecx
  802292:	ba 20 00 00 00       	mov    $0x20,%edx
  802297:	29 fa                	sub    %edi,%edx
  802299:	d3 e0                	shl    %cl,%eax
  80229b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80229f:	89 d1                	mov    %edx,%ecx
  8022a1:	89 d8                	mov    %ebx,%eax
  8022a3:	d3 e8                	shr    %cl,%eax
  8022a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022a9:	09 c1                	or     %eax,%ecx
  8022ab:	89 f0                	mov    %esi,%eax
  8022ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	d3 e3                	shl    %cl,%ebx
  8022b5:	89 d1                	mov    %edx,%ecx
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 f9                	mov    %edi,%ecx
  8022bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8022bf:	89 eb                	mov    %ebp,%ebx
  8022c1:	d3 e6                	shl    %cl,%esi
  8022c3:	89 d1                	mov    %edx,%ecx
  8022c5:	d3 eb                	shr    %cl,%ebx
  8022c7:	09 f3                	or     %esi,%ebx
  8022c9:	89 c6                	mov    %eax,%esi
  8022cb:	89 f2                	mov    %esi,%edx
  8022cd:	89 d8                	mov    %ebx,%eax
  8022cf:	f7 74 24 08          	divl   0x8(%esp)
  8022d3:	89 d6                	mov    %edx,%esi
  8022d5:	89 c3                	mov    %eax,%ebx
  8022d7:	f7 64 24 0c          	mull   0xc(%esp)
  8022db:	39 d6                	cmp    %edx,%esi
  8022dd:	72 19                	jb     8022f8 <__udivdi3+0x108>
  8022df:	89 f9                	mov    %edi,%ecx
  8022e1:	d3 e5                	shl    %cl,%ebp
  8022e3:	39 c5                	cmp    %eax,%ebp
  8022e5:	73 04                	jae    8022eb <__udivdi3+0xfb>
  8022e7:	39 d6                	cmp    %edx,%esi
  8022e9:	74 0d                	je     8022f8 <__udivdi3+0x108>
  8022eb:	89 d8                	mov    %ebx,%eax
  8022ed:	31 ff                	xor    %edi,%edi
  8022ef:	e9 3c ff ff ff       	jmp    802230 <__udivdi3+0x40>
  8022f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022fb:	31 ff                	xor    %edi,%edi
  8022fd:	e9 2e ff ff ff       	jmp    802230 <__udivdi3+0x40>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	f3 0f 1e fb          	endbr32 
  802314:	55                   	push   %ebp
  802315:	57                   	push   %edi
  802316:	56                   	push   %esi
  802317:	53                   	push   %ebx
  802318:	83 ec 1c             	sub    $0x1c,%esp
  80231b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80231f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802323:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802327:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80232b:	89 f0                	mov    %esi,%eax
  80232d:	89 da                	mov    %ebx,%edx
  80232f:	85 ff                	test   %edi,%edi
  802331:	75 15                	jne    802348 <__umoddi3+0x38>
  802333:	39 dd                	cmp    %ebx,%ebp
  802335:	76 39                	jbe    802370 <__umoddi3+0x60>
  802337:	f7 f5                	div    %ebp
  802339:	89 d0                	mov    %edx,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	83 c4 1c             	add    $0x1c,%esp
  802340:	5b                   	pop    %ebx
  802341:	5e                   	pop    %esi
  802342:	5f                   	pop    %edi
  802343:	5d                   	pop    %ebp
  802344:	c3                   	ret    
  802345:	8d 76 00             	lea    0x0(%esi),%esi
  802348:	39 df                	cmp    %ebx,%edi
  80234a:	77 f1                	ja     80233d <__umoddi3+0x2d>
  80234c:	0f bd cf             	bsr    %edi,%ecx
  80234f:	83 f1 1f             	xor    $0x1f,%ecx
  802352:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802356:	75 40                	jne    802398 <__umoddi3+0x88>
  802358:	39 df                	cmp    %ebx,%edi
  80235a:	72 04                	jb     802360 <__umoddi3+0x50>
  80235c:	39 f5                	cmp    %esi,%ebp
  80235e:	77 dd                	ja     80233d <__umoddi3+0x2d>
  802360:	89 da                	mov    %ebx,%edx
  802362:	89 f0                	mov    %esi,%eax
  802364:	29 e8                	sub    %ebp,%eax
  802366:	19 fa                	sbb    %edi,%edx
  802368:	eb d3                	jmp    80233d <__umoddi3+0x2d>
  80236a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802370:	89 e9                	mov    %ebp,%ecx
  802372:	85 ed                	test   %ebp,%ebp
  802374:	75 0b                	jne    802381 <__umoddi3+0x71>
  802376:	b8 01 00 00 00       	mov    $0x1,%eax
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	f7 f5                	div    %ebp
  80237f:	89 c1                	mov    %eax,%ecx
  802381:	89 d8                	mov    %ebx,%eax
  802383:	31 d2                	xor    %edx,%edx
  802385:	f7 f1                	div    %ecx
  802387:	89 f0                	mov    %esi,%eax
  802389:	f7 f1                	div    %ecx
  80238b:	89 d0                	mov    %edx,%eax
  80238d:	31 d2                	xor    %edx,%edx
  80238f:	eb ac                	jmp    80233d <__umoddi3+0x2d>
  802391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802398:	8b 44 24 04          	mov    0x4(%esp),%eax
  80239c:	ba 20 00 00 00       	mov    $0x20,%edx
  8023a1:	29 c2                	sub    %eax,%edx
  8023a3:	89 c1                	mov    %eax,%ecx
  8023a5:	89 e8                	mov    %ebp,%eax
  8023a7:	d3 e7                	shl    %cl,%edi
  8023a9:	89 d1                	mov    %edx,%ecx
  8023ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8023af:	d3 e8                	shr    %cl,%eax
  8023b1:	89 c1                	mov    %eax,%ecx
  8023b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023b7:	09 f9                	or     %edi,%ecx
  8023b9:	89 df                	mov    %ebx,%edi
  8023bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023bf:	89 c1                	mov    %eax,%ecx
  8023c1:	d3 e5                	shl    %cl,%ebp
  8023c3:	89 d1                	mov    %edx,%ecx
  8023c5:	d3 ef                	shr    %cl,%edi
  8023c7:	89 c1                	mov    %eax,%ecx
  8023c9:	89 f0                	mov    %esi,%eax
  8023cb:	d3 e3                	shl    %cl,%ebx
  8023cd:	89 d1                	mov    %edx,%ecx
  8023cf:	89 fa                	mov    %edi,%edx
  8023d1:	d3 e8                	shr    %cl,%eax
  8023d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023d8:	09 d8                	or     %ebx,%eax
  8023da:	f7 74 24 08          	divl   0x8(%esp)
  8023de:	89 d3                	mov    %edx,%ebx
  8023e0:	d3 e6                	shl    %cl,%esi
  8023e2:	f7 e5                	mul    %ebp
  8023e4:	89 c7                	mov    %eax,%edi
  8023e6:	89 d1                	mov    %edx,%ecx
  8023e8:	39 d3                	cmp    %edx,%ebx
  8023ea:	72 06                	jb     8023f2 <__umoddi3+0xe2>
  8023ec:	75 0e                	jne    8023fc <__umoddi3+0xec>
  8023ee:	39 c6                	cmp    %eax,%esi
  8023f0:	73 0a                	jae    8023fc <__umoddi3+0xec>
  8023f2:	29 e8                	sub    %ebp,%eax
  8023f4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023f8:	89 d1                	mov    %edx,%ecx
  8023fa:	89 c7                	mov    %eax,%edi
  8023fc:	89 f5                	mov    %esi,%ebp
  8023fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802402:	29 fd                	sub    %edi,%ebp
  802404:	19 cb                	sbb    %ecx,%ebx
  802406:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80240b:	89 d8                	mov    %ebx,%eax
  80240d:	d3 e0                	shl    %cl,%eax
  80240f:	89 f1                	mov    %esi,%ecx
  802411:	d3 ed                	shr    %cl,%ebp
  802413:	d3 eb                	shr    %cl,%ebx
  802415:	09 e8                	or     %ebp,%eax
  802417:	89 da                	mov    %ebx,%edx
  802419:	83 c4 1c             	add    $0x1c,%esp
  80241c:	5b                   	pop    %ebx
  80241d:	5e                   	pop    %esi
  80241e:	5f                   	pop    %edi
  80241f:	5d                   	pop    %ebp
  802420:	c3                   	ret    
