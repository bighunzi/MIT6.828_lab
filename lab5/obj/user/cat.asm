
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
  800049:	e8 bc 10 00 00       	call   80110a <read>
  80004e:	89 c3                	mov    %eax,%ebx
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	7e 2f                	jle    800086 <cat+0x53>
		if ((r = write(1, buf, n)) != n)
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	53                   	push   %ebx
  80005b:	68 00 40 80 00       	push   $0x804000
  800060:	6a 01                	push   $0x1
  800062:	e8 71 11 00 00       	call   8011d8 <write>
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	39 c3                	cmp    %eax,%ebx
  80006c:	74 cd                	je     80003b <cat+0x8>
			panic("write error copying %s: %e", s, r);
  80006e:	83 ec 0c             	sub    $0xc,%esp
  800071:	50                   	push   %eax
  800072:	ff 75 0c             	push   0xc(%ebp)
  800075:	68 60 1f 80 00       	push   $0x801f60
  80007a:	6a 0d                	push   $0xd
  80007c:	68 7b 1f 80 00       	push   $0x801f7b
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
  800096:	68 86 1f 80 00       	push   $0x801f86
  80009b:	6a 0f                	push   $0xf
  80009d:	68 7b 1f 80 00       	push   $0x801f7b
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
  8000b3:	c7 05 00 30 80 00 9b 	movl   $0x801f9b,0x803000
  8000ba:	1f 80 00 
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
  8000cb:	68 9f 1f 80 00       	push   $0x801f9f
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
  8000e9:	68 a7 1f 80 00       	push   $0x801fa7
  8000ee:	e8 1c 16 00 00       	call   80170f <printf>
  8000f3:	83 c4 10             	add    $0x10,%esp
		for (i = 1; i < argc; i++) {
  8000f6:	83 c6 01             	add    $0x1,%esi
  8000f9:	3b 75 08             	cmp    0x8(%ebp),%esi
  8000fc:	7d dc                	jge    8000da <umain+0x33>
			f = open(argv[i], O_RDONLY);
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	6a 00                	push   $0x0
  800103:	ff 34 b7             	push   (%edi,%esi,4)
  800106:	e8 62 14 00 00       	call   80156d <open>
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
  800123:	e8 a6 0e 00 00       	call   800fce <close>
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
  800179:	e8 7d 0e 00 00       	call   800ffb <close_all>
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
  8001ab:	68 c4 1f 80 00       	push   $0x801fc4
  8001b0:	e8 b3 00 00 00       	call   800268 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b5:	83 c4 18             	add    $0x18,%esp
  8001b8:	53                   	push   %ebx
  8001b9:	ff 75 10             	push   0x10(%ebp)
  8001bc:	e8 56 00 00 00       	call   800217 <vcprintf>
	cprintf("\n");
  8001c1:	c7 04 24 e3 23 80 00 	movl   $0x8023e3,(%esp)
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
  8002ca:	e8 51 1a 00 00       	call   801d20 <__udivdi3>
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
  800308:	e8 33 1b 00 00       	call   801e40 <__umoddi3>
  80030d:	83 c4 14             	add    $0x14,%esp
  800310:	0f be 80 e7 1f 80 00 	movsbl 0x801fe7(%eax),%eax
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
  8003ca:	ff 24 85 20 21 80 00 	jmp    *0x802120(,%eax,4)
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
  800498:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  80049f:	85 d2                	test   %edx,%edx
  8004a1:	74 18                	je     8004bb <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004a3:	52                   	push   %edx
  8004a4:	68 b1 23 80 00       	push   $0x8023b1
  8004a9:	53                   	push   %ebx
  8004aa:	56                   	push   %esi
  8004ab:	e8 92 fe ff ff       	call   800342 <printfmt>
  8004b0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004b3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004b6:	e9 66 02 00 00       	jmp    800721 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004bb:	50                   	push   %eax
  8004bc:	68 ff 1f 80 00       	push   $0x801fff
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
  8004e3:	b8 f8 1f 80 00       	mov    $0x801ff8,%eax
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
  800bef:	68 df 22 80 00       	push   $0x8022df
  800bf4:	6a 2a                	push   $0x2a
  800bf6:	68 fc 22 80 00       	push   $0x8022fc
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
  800c70:	68 df 22 80 00       	push   $0x8022df
  800c75:	6a 2a                	push   $0x2a
  800c77:	68 fc 22 80 00       	push   $0x8022fc
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
  800cb2:	68 df 22 80 00       	push   $0x8022df
  800cb7:	6a 2a                	push   $0x2a
  800cb9:	68 fc 22 80 00       	push   $0x8022fc
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
  800cf4:	68 df 22 80 00       	push   $0x8022df
  800cf9:	6a 2a                	push   $0x2a
  800cfb:	68 fc 22 80 00       	push   $0x8022fc
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
  800d36:	68 df 22 80 00       	push   $0x8022df
  800d3b:	6a 2a                	push   $0x2a
  800d3d:	68 fc 22 80 00       	push   $0x8022fc
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
  800d78:	68 df 22 80 00       	push   $0x8022df
  800d7d:	6a 2a                	push   $0x2a
  800d7f:	68 fc 22 80 00       	push   $0x8022fc
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
  800dba:	68 df 22 80 00       	push   $0x8022df
  800dbf:	6a 2a                	push   $0x2a
  800dc1:	68 fc 22 80 00       	push   $0x8022fc
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
  800e1e:	68 df 22 80 00       	push   $0x8022df
  800e23:	6a 2a                	push   $0x2a
  800e25:	68 fc 22 80 00       	push   $0x8022fc
  800e2a:	e8 5e f3 ff ff       	call   80018d <_panic>

00800e2f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3a:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e4f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e5e:	89 c2                	mov    %eax,%edx
  800e60:	c1 ea 16             	shr    $0x16,%edx
  800e63:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6a:	f6 c2 01             	test   $0x1,%dl
  800e6d:	74 29                	je     800e98 <fd_alloc+0x42>
  800e6f:	89 c2                	mov    %eax,%edx
  800e71:	c1 ea 0c             	shr    $0xc,%edx
  800e74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7b:	f6 c2 01             	test   $0x1,%dl
  800e7e:	74 18                	je     800e98 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e80:	05 00 10 00 00       	add    $0x1000,%eax
  800e85:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e8a:	75 d2                	jne    800e5e <fd_alloc+0x8>
  800e8c:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800e91:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800e96:	eb 05                	jmp    800e9d <fd_alloc+0x47>
			return 0;
  800e98:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	89 02                	mov    %eax,(%edx)
}
  800ea2:	89 c8                	mov    %ecx,%eax
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eac:	83 f8 1f             	cmp    $0x1f,%eax
  800eaf:	77 30                	ja     800ee1 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb1:	c1 e0 0c             	shl    $0xc,%eax
  800eb4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb9:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ebf:	f6 c2 01             	test   $0x1,%dl
  800ec2:	74 24                	je     800ee8 <fd_lookup+0x42>
  800ec4:	89 c2                	mov    %eax,%edx
  800ec6:	c1 ea 0c             	shr    $0xc,%edx
  800ec9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed0:	f6 c2 01             	test   $0x1,%dl
  800ed3:	74 1a                	je     800eef <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ed5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed8:	89 02                	mov    %eax,(%edx)
	return 0;
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    
		return -E_INVAL;
  800ee1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee6:	eb f7                	jmp    800edf <fd_lookup+0x39>
		return -E_INVAL;
  800ee8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eed:	eb f0                	jmp    800edf <fd_lookup+0x39>
  800eef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef4:	eb e9                	jmp    800edf <fd_lookup+0x39>

00800ef6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 04             	sub    $0x4,%esp
  800efd:	8b 55 08             	mov    0x8(%ebp),%edx
  800f00:	b8 88 23 80 00       	mov    $0x802388,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800f05:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f0a:	39 13                	cmp    %edx,(%ebx)
  800f0c:	74 32                	je     800f40 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800f0e:	83 c0 04             	add    $0x4,%eax
  800f11:	8b 18                	mov    (%eax),%ebx
  800f13:	85 db                	test   %ebx,%ebx
  800f15:	75 f3                	jne    800f0a <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f17:	a1 00 60 80 00       	mov    0x806000,%eax
  800f1c:	8b 40 48             	mov    0x48(%eax),%eax
  800f1f:	83 ec 04             	sub    $0x4,%esp
  800f22:	52                   	push   %edx
  800f23:	50                   	push   %eax
  800f24:	68 0c 23 80 00       	push   $0x80230c
  800f29:	e8 3a f3 ff ff       	call   800268 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f39:	89 1a                	mov    %ebx,(%edx)
}
  800f3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    
			return 0;
  800f40:	b8 00 00 00 00       	mov    $0x0,%eax
  800f45:	eb ef                	jmp    800f36 <dev_lookup+0x40>

00800f47 <fd_close>:
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 24             	sub    $0x24,%esp
  800f50:	8b 75 08             	mov    0x8(%ebp),%esi
  800f53:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f59:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f5a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f60:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f63:	50                   	push   %eax
  800f64:	e8 3d ff ff ff       	call   800ea6 <fd_lookup>
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 05                	js     800f77 <fd_close+0x30>
	    || fd != fd2)
  800f72:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f75:	74 16                	je     800f8d <fd_close+0x46>
		return (must_exist ? r : 0);
  800f77:	89 f8                	mov    %edi,%eax
  800f79:	84 c0                	test   %al,%al
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f80:	0f 44 d8             	cmove  %eax,%ebx
}
  800f83:	89 d8                	mov    %ebx,%eax
  800f85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	ff 36                	push   (%esi)
  800f96:	e8 5b ff ff ff       	call   800ef6 <dev_lookup>
  800f9b:	89 c3                	mov    %eax,%ebx
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	78 1a                	js     800fbe <fd_close+0x77>
		if (dev->dev_close)
  800fa4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fa7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800faa:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	74 0b                	je     800fbe <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	56                   	push   %esi
  800fb7:	ff d0                	call   *%eax
  800fb9:	89 c3                	mov    %eax,%ebx
  800fbb:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	56                   	push   %esi
  800fc2:	6a 00                	push   $0x0
  800fc4:	e8 fa fc ff ff       	call   800cc3 <sys_page_unmap>
	return r;
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	eb b5                	jmp    800f83 <fd_close+0x3c>

00800fce <close>:

int
close(int fdnum)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	ff 75 08             	push   0x8(%ebp)
  800fdb:	e8 c6 fe ff ff       	call   800ea6 <fd_lookup>
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	79 02                	jns    800fe9 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    
		return fd_close(fd, 1);
  800fe9:	83 ec 08             	sub    $0x8,%esp
  800fec:	6a 01                	push   $0x1
  800fee:	ff 75 f4             	push   -0xc(%ebp)
  800ff1:	e8 51 ff ff ff       	call   800f47 <fd_close>
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	eb ec                	jmp    800fe7 <close+0x19>

00800ffb <close_all>:

void
close_all(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	53                   	push   %ebx
  80100b:	e8 be ff ff ff       	call   800fce <close>
	for (i = 0; i < MAXFD; i++)
  801010:	83 c3 01             	add    $0x1,%ebx
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	83 fb 20             	cmp    $0x20,%ebx
  801019:	75 ec                	jne    801007 <close_all+0xc>
}
  80101b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	53                   	push   %ebx
  801026:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801029:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102c:	50                   	push   %eax
  80102d:	ff 75 08             	push   0x8(%ebp)
  801030:	e8 71 fe ff ff       	call   800ea6 <fd_lookup>
  801035:	89 c3                	mov    %eax,%ebx
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 7f                	js     8010bd <dup+0x9d>
		return r;
	close(newfdnum);
  80103e:	83 ec 0c             	sub    $0xc,%esp
  801041:	ff 75 0c             	push   0xc(%ebp)
  801044:	e8 85 ff ff ff       	call   800fce <close>

	newfd = INDEX2FD(newfdnum);
  801049:	8b 75 0c             	mov    0xc(%ebp),%esi
  80104c:	c1 e6 0c             	shl    $0xc,%esi
  80104f:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801055:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801058:	89 3c 24             	mov    %edi,(%esp)
  80105b:	e8 df fd ff ff       	call   800e3f <fd2data>
  801060:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801062:	89 34 24             	mov    %esi,(%esp)
  801065:	e8 d5 fd ff ff       	call   800e3f <fd2data>
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801070:	89 d8                	mov    %ebx,%eax
  801072:	c1 e8 16             	shr    $0x16,%eax
  801075:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107c:	a8 01                	test   $0x1,%al
  80107e:	74 11                	je     801091 <dup+0x71>
  801080:	89 d8                	mov    %ebx,%eax
  801082:	c1 e8 0c             	shr    $0xc,%eax
  801085:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108c:	f6 c2 01             	test   $0x1,%dl
  80108f:	75 36                	jne    8010c7 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801091:	89 f8                	mov    %edi,%eax
  801093:	c1 e8 0c             	shr    $0xc,%eax
  801096:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a5:	50                   	push   %eax
  8010a6:	56                   	push   %esi
  8010a7:	6a 00                	push   $0x0
  8010a9:	57                   	push   %edi
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 d0 fb ff ff       	call   800c81 <sys_page_map>
  8010b1:	89 c3                	mov    %eax,%ebx
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 33                	js     8010ed <dup+0xcd>
		goto err;

	return newfdnum;
  8010ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010bd:	89 d8                	mov    %ebx,%eax
  8010bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c2:	5b                   	pop    %ebx
  8010c3:	5e                   	pop    %esi
  8010c4:	5f                   	pop    %edi
  8010c5:	5d                   	pop    %ebp
  8010c6:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ce:	83 ec 0c             	sub    $0xc,%esp
  8010d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d6:	50                   	push   %eax
  8010d7:	ff 75 d4             	push   -0x2c(%ebp)
  8010da:	6a 00                	push   $0x0
  8010dc:	53                   	push   %ebx
  8010dd:	6a 00                	push   $0x0
  8010df:	e8 9d fb ff ff       	call   800c81 <sys_page_map>
  8010e4:	89 c3                	mov    %eax,%ebx
  8010e6:	83 c4 20             	add    $0x20,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	79 a4                	jns    801091 <dup+0x71>
	sys_page_unmap(0, newfd);
  8010ed:	83 ec 08             	sub    $0x8,%esp
  8010f0:	56                   	push   %esi
  8010f1:	6a 00                	push   $0x0
  8010f3:	e8 cb fb ff ff       	call   800cc3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f8:	83 c4 08             	add    $0x8,%esp
  8010fb:	ff 75 d4             	push   -0x2c(%ebp)
  8010fe:	6a 00                	push   $0x0
  801100:	e8 be fb ff ff       	call   800cc3 <sys_page_unmap>
	return r;
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	eb b3                	jmp    8010bd <dup+0x9d>

0080110a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	56                   	push   %esi
  80110e:	53                   	push   %ebx
  80110f:	83 ec 18             	sub    $0x18,%esp
  801112:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801115:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801118:	50                   	push   %eax
  801119:	56                   	push   %esi
  80111a:	e8 87 fd ff ff       	call   800ea6 <fd_lookup>
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	78 3c                	js     801162 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801126:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112f:	50                   	push   %eax
  801130:	ff 33                	push   (%ebx)
  801132:	e8 bf fd ff ff       	call   800ef6 <dev_lookup>
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	85 c0                	test   %eax,%eax
  80113c:	78 24                	js     801162 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80113e:	8b 43 08             	mov    0x8(%ebx),%eax
  801141:	83 e0 03             	and    $0x3,%eax
  801144:	83 f8 01             	cmp    $0x1,%eax
  801147:	74 20                	je     801169 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114c:	8b 40 08             	mov    0x8(%eax),%eax
  80114f:	85 c0                	test   %eax,%eax
  801151:	74 37                	je     80118a <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	ff 75 10             	push   0x10(%ebp)
  801159:	ff 75 0c             	push   0xc(%ebp)
  80115c:	53                   	push   %ebx
  80115d:	ff d0                	call   *%eax
  80115f:	83 c4 10             	add    $0x10,%esp
}
  801162:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801169:	a1 00 60 80 00       	mov    0x806000,%eax
  80116e:	8b 40 48             	mov    0x48(%eax),%eax
  801171:	83 ec 04             	sub    $0x4,%esp
  801174:	56                   	push   %esi
  801175:	50                   	push   %eax
  801176:	68 4d 23 80 00       	push   $0x80234d
  80117b:	e8 e8 f0 ff ff       	call   800268 <cprintf>
		return -E_INVAL;
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801188:	eb d8                	jmp    801162 <read+0x58>
		return -E_NOT_SUPP;
  80118a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80118f:	eb d1                	jmp    801162 <read+0x58>

00801191 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80119d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a5:	eb 02                	jmp    8011a9 <readn+0x18>
  8011a7:	01 c3                	add    %eax,%ebx
  8011a9:	39 f3                	cmp    %esi,%ebx
  8011ab:	73 21                	jae    8011ce <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011ad:	83 ec 04             	sub    $0x4,%esp
  8011b0:	89 f0                	mov    %esi,%eax
  8011b2:	29 d8                	sub    %ebx,%eax
  8011b4:	50                   	push   %eax
  8011b5:	89 d8                	mov    %ebx,%eax
  8011b7:	03 45 0c             	add    0xc(%ebp),%eax
  8011ba:	50                   	push   %eax
  8011bb:	57                   	push   %edi
  8011bc:	e8 49 ff ff ff       	call   80110a <read>
		if (m < 0)
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 04                	js     8011cc <readn+0x3b>
			return m;
		if (m == 0)
  8011c8:	75 dd                	jne    8011a7 <readn+0x16>
  8011ca:	eb 02                	jmp    8011ce <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011cc:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011ce:	89 d8                	mov    %ebx,%eax
  8011d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 18             	sub    $0x18,%esp
  8011e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e6:	50                   	push   %eax
  8011e7:	53                   	push   %ebx
  8011e8:	e8 b9 fc ff ff       	call   800ea6 <fd_lookup>
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 37                	js     80122b <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	ff 36                	push   (%esi)
  801200:	e8 f1 fc ff ff       	call   800ef6 <dev_lookup>
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 1f                	js     80122b <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801210:	74 20                	je     801232 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801212:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801215:	8b 40 0c             	mov    0xc(%eax),%eax
  801218:	85 c0                	test   %eax,%eax
  80121a:	74 37                	je     801253 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80121c:	83 ec 04             	sub    $0x4,%esp
  80121f:	ff 75 10             	push   0x10(%ebp)
  801222:	ff 75 0c             	push   0xc(%ebp)
  801225:	56                   	push   %esi
  801226:	ff d0                	call   *%eax
  801228:	83 c4 10             	add    $0x10,%esp
}
  80122b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122e:	5b                   	pop    %ebx
  80122f:	5e                   	pop    %esi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801232:	a1 00 60 80 00       	mov    0x806000,%eax
  801237:	8b 40 48             	mov    0x48(%eax),%eax
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	53                   	push   %ebx
  80123e:	50                   	push   %eax
  80123f:	68 69 23 80 00       	push   $0x802369
  801244:	e8 1f f0 ff ff       	call   800268 <cprintf>
		return -E_INVAL;
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801251:	eb d8                	jmp    80122b <write+0x53>
		return -E_NOT_SUPP;
  801253:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801258:	eb d1                	jmp    80122b <write+0x53>

0080125a <seek>:

int
seek(int fdnum, off_t offset)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801263:	50                   	push   %eax
  801264:	ff 75 08             	push   0x8(%ebp)
  801267:	e8 3a fc ff ff       	call   800ea6 <fd_lookup>
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 0e                	js     801281 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801273:	8b 55 0c             	mov    0xc(%ebp),%edx
  801276:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801279:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80127c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801281:	c9                   	leave  
  801282:	c3                   	ret    

00801283 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	56                   	push   %esi
  801287:	53                   	push   %ebx
  801288:	83 ec 18             	sub    $0x18,%esp
  80128b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801291:	50                   	push   %eax
  801292:	53                   	push   %ebx
  801293:	e8 0e fc ff ff       	call   800ea6 <fd_lookup>
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 34                	js     8012d3 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	ff 36                	push   (%esi)
  8012ab:	e8 46 fc ff ff       	call   800ef6 <dev_lookup>
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 1c                	js     8012d3 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b7:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012bb:	74 1d                	je     8012da <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c0:	8b 40 18             	mov    0x18(%eax),%eax
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	74 34                	je     8012fb <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	ff 75 0c             	push   0xc(%ebp)
  8012cd:	56                   	push   %esi
  8012ce:	ff d0                	call   *%eax
  8012d0:	83 c4 10             	add    $0x10,%esp
}
  8012d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d6:	5b                   	pop    %ebx
  8012d7:	5e                   	pop    %esi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012da:	a1 00 60 80 00       	mov    0x806000,%eax
  8012df:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e2:	83 ec 04             	sub    $0x4,%esp
  8012e5:	53                   	push   %ebx
  8012e6:	50                   	push   %eax
  8012e7:	68 2c 23 80 00       	push   $0x80232c
  8012ec:	e8 77 ef ff ff       	call   800268 <cprintf>
		return -E_INVAL;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f9:	eb d8                	jmp    8012d3 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8012fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801300:	eb d1                	jmp    8012d3 <ftruncate+0x50>

00801302 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	56                   	push   %esi
  801306:	53                   	push   %ebx
  801307:	83 ec 18             	sub    $0x18,%esp
  80130a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	ff 75 08             	push   0x8(%ebp)
  801314:	e8 8d fb ff ff       	call   800ea6 <fd_lookup>
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 49                	js     801369 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801320:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801329:	50                   	push   %eax
  80132a:	ff 36                	push   (%esi)
  80132c:	e8 c5 fb ff ff       	call   800ef6 <dev_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 31                	js     801369 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801338:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80133f:	74 2f                	je     801370 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801341:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801344:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80134b:	00 00 00 
	stat->st_isdir = 0;
  80134e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801355:	00 00 00 
	stat->st_dev = dev;
  801358:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	53                   	push   %ebx
  801362:	56                   	push   %esi
  801363:	ff 50 14             	call   *0x14(%eax)
  801366:	83 c4 10             	add    $0x10,%esp
}
  801369:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136c:	5b                   	pop    %ebx
  80136d:	5e                   	pop    %esi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    
		return -E_NOT_SUPP;
  801370:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801375:	eb f2                	jmp    801369 <fstat+0x67>

00801377 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	56                   	push   %esi
  80137b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	6a 00                	push   $0x0
  801381:	ff 75 08             	push   0x8(%ebp)
  801384:	e8 e4 01 00 00       	call   80156d <open>
  801389:	89 c3                	mov    %eax,%ebx
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 1b                	js     8013ad <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	ff 75 0c             	push   0xc(%ebp)
  801398:	50                   	push   %eax
  801399:	e8 64 ff ff ff       	call   801302 <fstat>
  80139e:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a0:	89 1c 24             	mov    %ebx,(%esp)
  8013a3:	e8 26 fc ff ff       	call   800fce <close>
	return r;
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	89 f3                	mov    %esi,%ebx
}
  8013ad:	89 d8                	mov    %ebx,%eax
  8013af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b2:	5b                   	pop    %ebx
  8013b3:	5e                   	pop    %esi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	56                   	push   %esi
  8013ba:	53                   	push   %ebx
  8013bb:	89 c6                	mov    %eax,%esi
  8013bd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013bf:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8013c6:	74 27                	je     8013ef <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013c8:	6a 07                	push   $0x7
  8013ca:	68 00 70 80 00       	push   $0x807000
  8013cf:	56                   	push   %esi
  8013d0:	ff 35 00 80 80 00    	push   0x808000
  8013d6:	e8 6f 08 00 00       	call   801c4a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013db:	83 c4 0c             	add    $0xc,%esp
  8013de:	6a 00                	push   $0x0
  8013e0:	53                   	push   %ebx
  8013e1:	6a 00                	push   $0x0
  8013e3:	e8 fb 07 00 00       	call   801be3 <ipc_recv>
}
  8013e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013eb:	5b                   	pop    %ebx
  8013ec:	5e                   	pop    %esi
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ef:	83 ec 0c             	sub    $0xc,%esp
  8013f2:	6a 01                	push   $0x1
  8013f4:	e8 a5 08 00 00       	call   801c9e <ipc_find_env>
  8013f9:	a3 00 80 80 00       	mov    %eax,0x808000
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	eb c5                	jmp    8013c8 <fsipc+0x12>

00801403 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
  80140c:	8b 40 0c             	mov    0xc(%eax),%eax
  80140f:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801414:	8b 45 0c             	mov    0xc(%ebp),%eax
  801417:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80141c:	ba 00 00 00 00       	mov    $0x0,%edx
  801421:	b8 02 00 00 00       	mov    $0x2,%eax
  801426:	e8 8b ff ff ff       	call   8013b6 <fsipc>
}
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    

0080142d <devfile_flush>:
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801433:	8b 45 08             	mov    0x8(%ebp),%eax
  801436:	8b 40 0c             	mov    0xc(%eax),%eax
  801439:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80143e:	ba 00 00 00 00       	mov    $0x0,%edx
  801443:	b8 06 00 00 00       	mov    $0x6,%eax
  801448:	e8 69 ff ff ff       	call   8013b6 <fsipc>
}
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <devfile_stat>:
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	53                   	push   %ebx
  801453:	83 ec 04             	sub    $0x4,%esp
  801456:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	8b 40 0c             	mov    0xc(%eax),%eax
  80145f:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801464:	ba 00 00 00 00       	mov    $0x0,%edx
  801469:	b8 05 00 00 00       	mov    $0x5,%eax
  80146e:	e8 43 ff ff ff       	call   8013b6 <fsipc>
  801473:	85 c0                	test   %eax,%eax
  801475:	78 2c                	js     8014a3 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	68 00 70 80 00       	push   $0x807000
  80147f:	53                   	push   %ebx
  801480:	e8 bd f3 ff ff       	call   800842 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801485:	a1 80 70 80 00       	mov    0x807080,%eax
  80148a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801490:	a1 84 70 80 00       	mov    0x807084,%eax
  801495:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <devfile_write>:
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8014b1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014b6:	39 d0                	cmp    %edx,%eax
  8014b8:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014be:	8b 52 0c             	mov    0xc(%edx),%edx
  8014c1:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  8014c7:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014cc:	50                   	push   %eax
  8014cd:	ff 75 0c             	push   0xc(%ebp)
  8014d0:	68 08 70 80 00       	push   $0x807008
  8014d5:	e8 fe f4 ff ff       	call   8009d8 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8014da:	ba 00 00 00 00       	mov    $0x0,%edx
  8014df:	b8 04 00 00 00       	mov    $0x4,%eax
  8014e4:	e8 cd fe ff ff       	call   8013b6 <fsipc>
}
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <devfile_read>:
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f9:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8014fe:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801504:	ba 00 00 00 00       	mov    $0x0,%edx
  801509:	b8 03 00 00 00       	mov    $0x3,%eax
  80150e:	e8 a3 fe ff ff       	call   8013b6 <fsipc>
  801513:	89 c3                	mov    %eax,%ebx
  801515:	85 c0                	test   %eax,%eax
  801517:	78 1f                	js     801538 <devfile_read+0x4d>
	assert(r <= n);
  801519:	39 f0                	cmp    %esi,%eax
  80151b:	77 24                	ja     801541 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80151d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801522:	7f 33                	jg     801557 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	50                   	push   %eax
  801528:	68 00 70 80 00       	push   $0x807000
  80152d:	ff 75 0c             	push   0xc(%ebp)
  801530:	e8 a3 f4 ff ff       	call   8009d8 <memmove>
	return r;
  801535:	83 c4 10             	add    $0x10,%esp
}
  801538:	89 d8                	mov    %ebx,%eax
  80153a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153d:	5b                   	pop    %ebx
  80153e:	5e                   	pop    %esi
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    
	assert(r <= n);
  801541:	68 98 23 80 00       	push   $0x802398
  801546:	68 9f 23 80 00       	push   $0x80239f
  80154b:	6a 7c                	push   $0x7c
  80154d:	68 b4 23 80 00       	push   $0x8023b4
  801552:	e8 36 ec ff ff       	call   80018d <_panic>
	assert(r <= PGSIZE);
  801557:	68 bf 23 80 00       	push   $0x8023bf
  80155c:	68 9f 23 80 00       	push   $0x80239f
  801561:	6a 7d                	push   $0x7d
  801563:	68 b4 23 80 00       	push   $0x8023b4
  801568:	e8 20 ec ff ff       	call   80018d <_panic>

0080156d <open>:
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	56                   	push   %esi
  801571:	53                   	push   %ebx
  801572:	83 ec 1c             	sub    $0x1c,%esp
  801575:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801578:	56                   	push   %esi
  801579:	e8 89 f2 ff ff       	call   800807 <strlen>
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801586:	7f 6c                	jg     8015f4 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801588:	83 ec 0c             	sub    $0xc,%esp
  80158b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158e:	50                   	push   %eax
  80158f:	e8 c2 f8 ff ff       	call   800e56 <fd_alloc>
  801594:	89 c3                	mov    %eax,%ebx
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 3c                	js     8015d9 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	56                   	push   %esi
  8015a1:	68 00 70 80 00       	push   $0x807000
  8015a6:	e8 97 f2 ff ff       	call   800842 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ae:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015bb:	e8 f6 fd ff ff       	call   8013b6 <fsipc>
  8015c0:	89 c3                	mov    %eax,%ebx
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 19                	js     8015e2 <open+0x75>
	return fd2num(fd);
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	ff 75 f4             	push   -0xc(%ebp)
  8015cf:	e8 5b f8 ff ff       	call   800e2f <fd2num>
  8015d4:	89 c3                	mov    %eax,%ebx
  8015d6:	83 c4 10             	add    $0x10,%esp
}
  8015d9:	89 d8                	mov    %ebx,%eax
  8015db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015de:	5b                   	pop    %ebx
  8015df:	5e                   	pop    %esi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    
		fd_close(fd, 0);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	6a 00                	push   $0x0
  8015e7:	ff 75 f4             	push   -0xc(%ebp)
  8015ea:	e8 58 f9 ff ff       	call   800f47 <fd_close>
		return r;
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	eb e5                	jmp    8015d9 <open+0x6c>
		return -E_BAD_PATH;
  8015f4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015f9:	eb de                	jmp    8015d9 <open+0x6c>

008015fb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801601:	ba 00 00 00 00       	mov    $0x0,%edx
  801606:	b8 08 00 00 00       	mov    $0x8,%eax
  80160b:	e8 a6 fd ff ff       	call   8013b6 <fsipc>
}
  801610:	c9                   	leave  
  801611:	c3                   	ret    

00801612 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801612:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801616:	7f 01                	jg     801619 <writebuf+0x7>
  801618:	c3                   	ret    
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	53                   	push   %ebx
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801622:	ff 70 04             	push   0x4(%eax)
  801625:	8d 40 10             	lea    0x10(%eax),%eax
  801628:	50                   	push   %eax
  801629:	ff 33                	push   (%ebx)
  80162b:	e8 a8 fb ff ff       	call   8011d8 <write>
		if (result > 0)
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	7e 03                	jle    80163a <writebuf+0x28>
			b->result += result;
  801637:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80163a:	39 43 04             	cmp    %eax,0x4(%ebx)
  80163d:	74 0d                	je     80164c <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  80163f:	85 c0                	test   %eax,%eax
  801641:	ba 00 00 00 00       	mov    $0x0,%edx
  801646:	0f 4f c2             	cmovg  %edx,%eax
  801649:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80164c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164f:	c9                   	leave  
  801650:	c3                   	ret    

00801651 <putch>:

static void
putch(int ch, void *thunk)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	53                   	push   %ebx
  801655:	83 ec 04             	sub    $0x4,%esp
  801658:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80165b:	8b 53 04             	mov    0x4(%ebx),%edx
  80165e:	8d 42 01             	lea    0x1(%edx),%eax
  801661:	89 43 04             	mov    %eax,0x4(%ebx)
  801664:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801667:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80166b:	3d 00 01 00 00       	cmp    $0x100,%eax
  801670:	74 05                	je     801677 <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  801672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801675:	c9                   	leave  
  801676:	c3                   	ret    
		writebuf(b);
  801677:	89 d8                	mov    %ebx,%eax
  801679:	e8 94 ff ff ff       	call   801612 <writebuf>
		b->idx = 0;
  80167e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  801685:	eb eb                	jmp    801672 <putch+0x21>

00801687 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801690:	8b 45 08             	mov    0x8(%ebp),%eax
  801693:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801699:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016a0:	00 00 00 
	b.result = 0;
  8016a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016aa:	00 00 00 
	b.error = 1;
  8016ad:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016b4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016b7:	ff 75 10             	push   0x10(%ebp)
  8016ba:	ff 75 0c             	push   0xc(%ebp)
  8016bd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	68 51 16 80 00       	push   $0x801651
  8016c9:	e8 91 ec ff ff       	call   80035f <vprintfmt>
	if (b.idx > 0)
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016d8:	7f 11                	jg     8016eb <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  8016da:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    
		writebuf(&b);
  8016eb:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016f1:	e8 1c ff ff ff       	call   801612 <writebuf>
  8016f6:	eb e2                	jmp    8016da <vfprintf+0x53>

008016f8 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016fe:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801701:	50                   	push   %eax
  801702:	ff 75 0c             	push   0xc(%ebp)
  801705:	ff 75 08             	push   0x8(%ebp)
  801708:	e8 7a ff ff ff       	call   801687 <vfprintf>
	va_end(ap);

	return cnt;
}
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <printf>:

int
printf(const char *fmt, ...)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801715:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801718:	50                   	push   %eax
  801719:	ff 75 08             	push   0x8(%ebp)
  80171c:	6a 01                	push   $0x1
  80171e:	e8 64 ff ff ff       	call   801687 <vfprintf>
	va_end(ap);

	return cnt;
}
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	56                   	push   %esi
  801729:	53                   	push   %ebx
  80172a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80172d:	83 ec 0c             	sub    $0xc,%esp
  801730:	ff 75 08             	push   0x8(%ebp)
  801733:	e8 07 f7 ff ff       	call   800e3f <fd2data>
  801738:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80173a:	83 c4 08             	add    $0x8,%esp
  80173d:	68 cb 23 80 00       	push   $0x8023cb
  801742:	53                   	push   %ebx
  801743:	e8 fa f0 ff ff       	call   800842 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801748:	8b 46 04             	mov    0x4(%esi),%eax
  80174b:	2b 06                	sub    (%esi),%eax
  80174d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801753:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80175a:	00 00 00 
	stat->st_dev = &devpipe;
  80175d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801764:	30 80 00 
	return 0;
}
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
  80176c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176f:	5b                   	pop    %ebx
  801770:	5e                   	pop    %esi
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    

00801773 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	53                   	push   %ebx
  801777:	83 ec 0c             	sub    $0xc,%esp
  80177a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80177d:	53                   	push   %ebx
  80177e:	6a 00                	push   $0x0
  801780:	e8 3e f5 ff ff       	call   800cc3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801785:	89 1c 24             	mov    %ebx,(%esp)
  801788:	e8 b2 f6 ff ff       	call   800e3f <fd2data>
  80178d:	83 c4 08             	add    $0x8,%esp
  801790:	50                   	push   %eax
  801791:	6a 00                	push   $0x0
  801793:	e8 2b f5 ff ff       	call   800cc3 <sys_page_unmap>
}
  801798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <_pipeisclosed>:
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	57                   	push   %edi
  8017a1:	56                   	push   %esi
  8017a2:	53                   	push   %ebx
  8017a3:	83 ec 1c             	sub    $0x1c,%esp
  8017a6:	89 c7                	mov    %eax,%edi
  8017a8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8017aa:	a1 00 60 80 00       	mov    0x806000,%eax
  8017af:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017b2:	83 ec 0c             	sub    $0xc,%esp
  8017b5:	57                   	push   %edi
  8017b6:	e8 1c 05 00 00       	call   801cd7 <pageref>
  8017bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017be:	89 34 24             	mov    %esi,(%esp)
  8017c1:	e8 11 05 00 00       	call   801cd7 <pageref>
		nn = thisenv->env_runs;
  8017c6:	8b 15 00 60 80 00    	mov    0x806000,%edx
  8017cc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	39 cb                	cmp    %ecx,%ebx
  8017d4:	74 1b                	je     8017f1 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8017d6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8017d9:	75 cf                	jne    8017aa <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017db:	8b 42 58             	mov    0x58(%edx),%eax
  8017de:	6a 01                	push   $0x1
  8017e0:	50                   	push   %eax
  8017e1:	53                   	push   %ebx
  8017e2:	68 d2 23 80 00       	push   $0x8023d2
  8017e7:	e8 7c ea ff ff       	call   800268 <cprintf>
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	eb b9                	jmp    8017aa <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8017f1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8017f4:	0f 94 c0             	sete   %al
  8017f7:	0f b6 c0             	movzbl %al,%eax
}
  8017fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5e                   	pop    %esi
  8017ff:	5f                   	pop    %edi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <devpipe_write>:
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	57                   	push   %edi
  801806:	56                   	push   %esi
  801807:	53                   	push   %ebx
  801808:	83 ec 28             	sub    $0x28,%esp
  80180b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80180e:	56                   	push   %esi
  80180f:	e8 2b f6 ff ff       	call   800e3f <fd2data>
  801814:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	bf 00 00 00 00       	mov    $0x0,%edi
  80181e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801821:	75 09                	jne    80182c <devpipe_write+0x2a>
	return i;
  801823:	89 f8                	mov    %edi,%eax
  801825:	eb 23                	jmp    80184a <devpipe_write+0x48>
			sys_yield();
  801827:	e8 f3 f3 ff ff       	call   800c1f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80182c:	8b 43 04             	mov    0x4(%ebx),%eax
  80182f:	8b 0b                	mov    (%ebx),%ecx
  801831:	8d 51 20             	lea    0x20(%ecx),%edx
  801834:	39 d0                	cmp    %edx,%eax
  801836:	72 1a                	jb     801852 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801838:	89 da                	mov    %ebx,%edx
  80183a:	89 f0                	mov    %esi,%eax
  80183c:	e8 5c ff ff ff       	call   80179d <_pipeisclosed>
  801841:	85 c0                	test   %eax,%eax
  801843:	74 e2                	je     801827 <devpipe_write+0x25>
				return 0;
  801845:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80184d:	5b                   	pop    %ebx
  80184e:	5e                   	pop    %esi
  80184f:	5f                   	pop    %edi
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801855:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801859:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80185c:	89 c2                	mov    %eax,%edx
  80185e:	c1 fa 1f             	sar    $0x1f,%edx
  801861:	89 d1                	mov    %edx,%ecx
  801863:	c1 e9 1b             	shr    $0x1b,%ecx
  801866:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801869:	83 e2 1f             	and    $0x1f,%edx
  80186c:	29 ca                	sub    %ecx,%edx
  80186e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801872:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801876:	83 c0 01             	add    $0x1,%eax
  801879:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80187c:	83 c7 01             	add    $0x1,%edi
  80187f:	eb 9d                	jmp    80181e <devpipe_write+0x1c>

00801881 <devpipe_read>:
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	57                   	push   %edi
  801885:	56                   	push   %esi
  801886:	53                   	push   %ebx
  801887:	83 ec 18             	sub    $0x18,%esp
  80188a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80188d:	57                   	push   %edi
  80188e:	e8 ac f5 ff ff       	call   800e3f <fd2data>
  801893:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	be 00 00 00 00       	mov    $0x0,%esi
  80189d:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018a0:	75 13                	jne    8018b5 <devpipe_read+0x34>
	return i;
  8018a2:	89 f0                	mov    %esi,%eax
  8018a4:	eb 02                	jmp    8018a8 <devpipe_read+0x27>
				return i;
  8018a6:	89 f0                	mov    %esi,%eax
}
  8018a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ab:	5b                   	pop    %ebx
  8018ac:	5e                   	pop    %esi
  8018ad:	5f                   	pop    %edi
  8018ae:	5d                   	pop    %ebp
  8018af:	c3                   	ret    
			sys_yield();
  8018b0:	e8 6a f3 ff ff       	call   800c1f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8018b5:	8b 03                	mov    (%ebx),%eax
  8018b7:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018ba:	75 18                	jne    8018d4 <devpipe_read+0x53>
			if (i > 0)
  8018bc:	85 f6                	test   %esi,%esi
  8018be:	75 e6                	jne    8018a6 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8018c0:	89 da                	mov    %ebx,%edx
  8018c2:	89 f8                	mov    %edi,%eax
  8018c4:	e8 d4 fe ff ff       	call   80179d <_pipeisclosed>
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	74 e3                	je     8018b0 <devpipe_read+0x2f>
				return 0;
  8018cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d2:	eb d4                	jmp    8018a8 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018d4:	99                   	cltd   
  8018d5:	c1 ea 1b             	shr    $0x1b,%edx
  8018d8:	01 d0                	add    %edx,%eax
  8018da:	83 e0 1f             	and    $0x1f,%eax
  8018dd:	29 d0                	sub    %edx,%eax
  8018df:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8018e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018e7:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8018ea:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8018ed:	83 c6 01             	add    $0x1,%esi
  8018f0:	eb ab                	jmp    80189d <devpipe_read+0x1c>

008018f2 <pipe>:
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	56                   	push   %esi
  8018f6:	53                   	push   %ebx
  8018f7:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8018fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fd:	50                   	push   %eax
  8018fe:	e8 53 f5 ff ff       	call   800e56 <fd_alloc>
  801903:	89 c3                	mov    %eax,%ebx
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	0f 88 23 01 00 00    	js     801a33 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801910:	83 ec 04             	sub    $0x4,%esp
  801913:	68 07 04 00 00       	push   $0x407
  801918:	ff 75 f4             	push   -0xc(%ebp)
  80191b:	6a 00                	push   $0x0
  80191d:	e8 1c f3 ff ff       	call   800c3e <sys_page_alloc>
  801922:	89 c3                	mov    %eax,%ebx
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	85 c0                	test   %eax,%eax
  801929:	0f 88 04 01 00 00    	js     801a33 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80192f:	83 ec 0c             	sub    $0xc,%esp
  801932:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801935:	50                   	push   %eax
  801936:	e8 1b f5 ff ff       	call   800e56 <fd_alloc>
  80193b:	89 c3                	mov    %eax,%ebx
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	85 c0                	test   %eax,%eax
  801942:	0f 88 db 00 00 00    	js     801a23 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801948:	83 ec 04             	sub    $0x4,%esp
  80194b:	68 07 04 00 00       	push   $0x407
  801950:	ff 75 f0             	push   -0x10(%ebp)
  801953:	6a 00                	push   $0x0
  801955:	e8 e4 f2 ff ff       	call   800c3e <sys_page_alloc>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	0f 88 bc 00 00 00    	js     801a23 <pipe+0x131>
	va = fd2data(fd0);
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	ff 75 f4             	push   -0xc(%ebp)
  80196d:	e8 cd f4 ff ff       	call   800e3f <fd2data>
  801972:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801974:	83 c4 0c             	add    $0xc,%esp
  801977:	68 07 04 00 00       	push   $0x407
  80197c:	50                   	push   %eax
  80197d:	6a 00                	push   $0x0
  80197f:	e8 ba f2 ff ff       	call   800c3e <sys_page_alloc>
  801984:	89 c3                	mov    %eax,%ebx
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	0f 88 82 00 00 00    	js     801a13 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	ff 75 f0             	push   -0x10(%ebp)
  801997:	e8 a3 f4 ff ff       	call   800e3f <fd2data>
  80199c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019a3:	50                   	push   %eax
  8019a4:	6a 00                	push   $0x0
  8019a6:	56                   	push   %esi
  8019a7:	6a 00                	push   $0x0
  8019a9:	e8 d3 f2 ff ff       	call   800c81 <sys_page_map>
  8019ae:	89 c3                	mov    %eax,%ebx
  8019b0:	83 c4 20             	add    $0x20,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 4e                	js     801a05 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8019b7:	a1 20 30 80 00       	mov    0x803020,%eax
  8019bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019bf:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8019c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c4:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8019cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019ce:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8019d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	ff 75 f4             	push   -0xc(%ebp)
  8019e0:	e8 4a f4 ff ff       	call   800e2f <fd2num>
  8019e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019e8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019ea:	83 c4 04             	add    $0x4,%esp
  8019ed:	ff 75 f0             	push   -0x10(%ebp)
  8019f0:	e8 3a f4 ff ff       	call   800e2f <fd2num>
  8019f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a03:	eb 2e                	jmp    801a33 <pipe+0x141>
	sys_page_unmap(0, va);
  801a05:	83 ec 08             	sub    $0x8,%esp
  801a08:	56                   	push   %esi
  801a09:	6a 00                	push   $0x0
  801a0b:	e8 b3 f2 ff ff       	call   800cc3 <sys_page_unmap>
  801a10:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801a13:	83 ec 08             	sub    $0x8,%esp
  801a16:	ff 75 f0             	push   -0x10(%ebp)
  801a19:	6a 00                	push   $0x0
  801a1b:	e8 a3 f2 ff ff       	call   800cc3 <sys_page_unmap>
  801a20:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801a23:	83 ec 08             	sub    $0x8,%esp
  801a26:	ff 75 f4             	push   -0xc(%ebp)
  801a29:	6a 00                	push   $0x0
  801a2b:	e8 93 f2 ff ff       	call   800cc3 <sys_page_unmap>
  801a30:	83 c4 10             	add    $0x10,%esp
}
  801a33:	89 d8                	mov    %ebx,%eax
  801a35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <pipeisclosed>:
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a45:	50                   	push   %eax
  801a46:	ff 75 08             	push   0x8(%ebp)
  801a49:	e8 58 f4 ff ff       	call   800ea6 <fd_lookup>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	78 18                	js     801a6d <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	ff 75 f4             	push   -0xc(%ebp)
  801a5b:	e8 df f3 ff ff       	call   800e3f <fd2data>
  801a60:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a65:	e8 33 fd ff ff       	call   80179d <_pipeisclosed>
  801a6a:	83 c4 10             	add    $0x10,%esp
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a74:	c3                   	ret    

00801a75 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a7b:	68 ea 23 80 00       	push   $0x8023ea
  801a80:	ff 75 0c             	push   0xc(%ebp)
  801a83:	e8 ba ed ff ff       	call   800842 <strcpy>
	return 0;
}
  801a88:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <devcons_write>:
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	57                   	push   %edi
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a9b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801aa0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801aa6:	eb 2e                	jmp    801ad6 <devcons_write+0x47>
		m = n - tot;
  801aa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aab:	29 f3                	sub    %esi,%ebx
  801aad:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ab2:	39 c3                	cmp    %eax,%ebx
  801ab4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ab7:	83 ec 04             	sub    $0x4,%esp
  801aba:	53                   	push   %ebx
  801abb:	89 f0                	mov    %esi,%eax
  801abd:	03 45 0c             	add    0xc(%ebp),%eax
  801ac0:	50                   	push   %eax
  801ac1:	57                   	push   %edi
  801ac2:	e8 11 ef ff ff       	call   8009d8 <memmove>
		sys_cputs(buf, m);
  801ac7:	83 c4 08             	add    $0x8,%esp
  801aca:	53                   	push   %ebx
  801acb:	57                   	push   %edi
  801acc:	e8 b1 f0 ff ff       	call   800b82 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ad1:	01 de                	add    %ebx,%esi
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ad9:	72 cd                	jb     801aa8 <devcons_write+0x19>
}
  801adb:	89 f0                	mov    %esi,%eax
  801add:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae0:	5b                   	pop    %ebx
  801ae1:	5e                   	pop    %esi
  801ae2:	5f                   	pop    %edi
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <devcons_read>:
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	83 ec 08             	sub    $0x8,%esp
  801aeb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801af0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801af4:	75 07                	jne    801afd <devcons_read+0x18>
  801af6:	eb 1f                	jmp    801b17 <devcons_read+0x32>
		sys_yield();
  801af8:	e8 22 f1 ff ff       	call   800c1f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801afd:	e8 9e f0 ff ff       	call   800ba0 <sys_cgetc>
  801b02:	85 c0                	test   %eax,%eax
  801b04:	74 f2                	je     801af8 <devcons_read+0x13>
	if (c < 0)
  801b06:	78 0f                	js     801b17 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801b08:	83 f8 04             	cmp    $0x4,%eax
  801b0b:	74 0c                	je     801b19 <devcons_read+0x34>
	*(char*)vbuf = c;
  801b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b10:	88 02                	mov    %al,(%edx)
	return 1;
  801b12:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    
		return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	eb f7                	jmp    801b17 <devcons_read+0x32>

00801b20 <cputchar>:
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b26:	8b 45 08             	mov    0x8(%ebp),%eax
  801b29:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b2c:	6a 01                	push   $0x1
  801b2e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b31:	50                   	push   %eax
  801b32:	e8 4b f0 ff ff       	call   800b82 <sys_cputs>
}
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <getchar>:
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801b42:	6a 01                	push   $0x1
  801b44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b47:	50                   	push   %eax
  801b48:	6a 00                	push   $0x0
  801b4a:	e8 bb f5 ff ff       	call   80110a <read>
	if (r < 0)
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	85 c0                	test   %eax,%eax
  801b54:	78 06                	js     801b5c <getchar+0x20>
	if (r < 1)
  801b56:	74 06                	je     801b5e <getchar+0x22>
	return c;
  801b58:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    
		return -E_EOF;
  801b5e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801b63:	eb f7                	jmp    801b5c <getchar+0x20>

00801b65 <iscons>:
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6e:	50                   	push   %eax
  801b6f:	ff 75 08             	push   0x8(%ebp)
  801b72:	e8 2f f3 ff ff       	call   800ea6 <fd_lookup>
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 11                	js     801b8f <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b81:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b87:	39 10                	cmp    %edx,(%eax)
  801b89:	0f 94 c0             	sete   %al
  801b8c:	0f b6 c0             	movzbl %al,%eax
}
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    

00801b91 <opencons>:
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9a:	50                   	push   %eax
  801b9b:	e8 b6 f2 ff ff       	call   800e56 <fd_alloc>
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	78 3a                	js     801be1 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ba7:	83 ec 04             	sub    $0x4,%esp
  801baa:	68 07 04 00 00       	push   $0x407
  801baf:	ff 75 f4             	push   -0xc(%ebp)
  801bb2:	6a 00                	push   $0x0
  801bb4:	e8 85 f0 ff ff       	call   800c3e <sys_page_alloc>
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	78 21                	js     801be1 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bc9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	50                   	push   %eax
  801bd9:	e8 51 f2 ff ff       	call   800e2f <fd2num>
  801bde:	83 c4 10             	add    $0x10,%esp
}
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	56                   	push   %esi
  801be7:	53                   	push   %ebx
  801be8:	8b 75 08             	mov    0x8(%ebp),%esi
  801beb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bf8:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801bfb:	83 ec 0c             	sub    $0xc,%esp
  801bfe:	50                   	push   %eax
  801bff:	e8 ea f1 ff ff       	call   800dee <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 f6                	test   %esi,%esi
  801c09:	74 14                	je     801c1f <ipc_recv+0x3c>
  801c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c10:	85 c0                	test   %eax,%eax
  801c12:	78 09                	js     801c1d <ipc_recv+0x3a>
  801c14:	8b 15 00 60 80 00    	mov    0x806000,%edx
  801c1a:	8b 52 74             	mov    0x74(%edx),%edx
  801c1d:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801c1f:	85 db                	test   %ebx,%ebx
  801c21:	74 14                	je     801c37 <ipc_recv+0x54>
  801c23:	ba 00 00 00 00       	mov    $0x0,%edx
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	78 09                	js     801c35 <ipc_recv+0x52>
  801c2c:	8b 15 00 60 80 00    	mov    0x806000,%edx
  801c32:	8b 52 78             	mov    0x78(%edx),%edx
  801c35:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801c37:	85 c0                	test   %eax,%eax
  801c39:	78 08                	js     801c43 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801c3b:	a1 00 60 80 00       	mov    0x806000,%eax
  801c40:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c46:	5b                   	pop    %ebx
  801c47:	5e                   	pop    %esi
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	57                   	push   %edi
  801c4e:	56                   	push   %esi
  801c4f:	53                   	push   %ebx
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c56:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801c5c:	85 db                	test   %ebx,%ebx
  801c5e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c63:	0f 44 d8             	cmove  %eax,%ebx
  801c66:	eb 05                	jmp    801c6d <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801c68:	e8 b2 ef ff ff       	call   800c1f <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801c6d:	ff 75 14             	push   0x14(%ebp)
  801c70:	53                   	push   %ebx
  801c71:	56                   	push   %esi
  801c72:	57                   	push   %edi
  801c73:	e8 53 f1 ff ff       	call   800dcb <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c7e:	74 e8                	je     801c68 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801c80:	85 c0                	test   %eax,%eax
  801c82:	78 08                	js     801c8c <ipc_send+0x42>
	}while (r<0);

}
  801c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c87:	5b                   	pop    %ebx
  801c88:	5e                   	pop    %esi
  801c89:	5f                   	pop    %edi
  801c8a:	5d                   	pop    %ebp
  801c8b:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801c8c:	50                   	push   %eax
  801c8d:	68 f6 23 80 00       	push   $0x8023f6
  801c92:	6a 3d                	push   $0x3d
  801c94:	68 0a 24 80 00       	push   $0x80240a
  801c99:	e8 ef e4 ff ff       	call   80018d <_panic>

00801c9e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ca9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cac:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cb2:	8b 52 50             	mov    0x50(%edx),%edx
  801cb5:	39 ca                	cmp    %ecx,%edx
  801cb7:	74 11                	je     801cca <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801cb9:	83 c0 01             	add    $0x1,%eax
  801cbc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cc1:	75 e6                	jne    801ca9 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc8:	eb 0b                	jmp    801cd5 <ipc_find_env+0x37>
			return envs[i].env_id;
  801cca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ccd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cd2:	8b 40 48             	mov    0x48(%eax),%eax
}
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cdd:	89 c2                	mov    %eax,%edx
  801cdf:	c1 ea 16             	shr    $0x16,%edx
  801ce2:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ce9:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801cee:	f6 c1 01             	test   $0x1,%cl
  801cf1:	74 1c                	je     801d0f <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801cf3:	c1 e8 0c             	shr    $0xc,%eax
  801cf6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cfd:	a8 01                	test   $0x1,%al
  801cff:	74 0e                	je     801d0f <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d01:	c1 e8 0c             	shr    $0xc,%eax
  801d04:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801d0b:	ef 
  801d0c:	0f b7 d2             	movzwl %dx,%edx
}
  801d0f:	89 d0                	mov    %edx,%eax
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    
  801d13:	66 90                	xchg   %ax,%ax
  801d15:	66 90                	xchg   %ax,%ax
  801d17:	66 90                	xchg   %ax,%ax
  801d19:	66 90                	xchg   %ax,%ax
  801d1b:	66 90                	xchg   %ax,%ax
  801d1d:	66 90                	xchg   %ax,%ax
  801d1f:	90                   	nop

00801d20 <__udivdi3>:
  801d20:	f3 0f 1e fb          	endbr32 
  801d24:	55                   	push   %ebp
  801d25:	57                   	push   %edi
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	83 ec 1c             	sub    $0x1c,%esp
  801d2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d33:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	75 19                	jne    801d58 <__udivdi3+0x38>
  801d3f:	39 f3                	cmp    %esi,%ebx
  801d41:	76 4d                	jbe    801d90 <__udivdi3+0x70>
  801d43:	31 ff                	xor    %edi,%edi
  801d45:	89 e8                	mov    %ebp,%eax
  801d47:	89 f2                	mov    %esi,%edx
  801d49:	f7 f3                	div    %ebx
  801d4b:	89 fa                	mov    %edi,%edx
  801d4d:	83 c4 1c             	add    $0x1c,%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5e                   	pop    %esi
  801d52:	5f                   	pop    %edi
  801d53:	5d                   	pop    %ebp
  801d54:	c3                   	ret    
  801d55:	8d 76 00             	lea    0x0(%esi),%esi
  801d58:	39 f0                	cmp    %esi,%eax
  801d5a:	76 14                	jbe    801d70 <__udivdi3+0x50>
  801d5c:	31 ff                	xor    %edi,%edi
  801d5e:	31 c0                	xor    %eax,%eax
  801d60:	89 fa                	mov    %edi,%edx
  801d62:	83 c4 1c             	add    $0x1c,%esp
  801d65:	5b                   	pop    %ebx
  801d66:	5e                   	pop    %esi
  801d67:	5f                   	pop    %edi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    
  801d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d70:	0f bd f8             	bsr    %eax,%edi
  801d73:	83 f7 1f             	xor    $0x1f,%edi
  801d76:	75 48                	jne    801dc0 <__udivdi3+0xa0>
  801d78:	39 f0                	cmp    %esi,%eax
  801d7a:	72 06                	jb     801d82 <__udivdi3+0x62>
  801d7c:	31 c0                	xor    %eax,%eax
  801d7e:	39 eb                	cmp    %ebp,%ebx
  801d80:	77 de                	ja     801d60 <__udivdi3+0x40>
  801d82:	b8 01 00 00 00       	mov    $0x1,%eax
  801d87:	eb d7                	jmp    801d60 <__udivdi3+0x40>
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	89 d9                	mov    %ebx,%ecx
  801d92:	85 db                	test   %ebx,%ebx
  801d94:	75 0b                	jne    801da1 <__udivdi3+0x81>
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f3                	div    %ebx
  801d9f:	89 c1                	mov    %eax,%ecx
  801da1:	31 d2                	xor    %edx,%edx
  801da3:	89 f0                	mov    %esi,%eax
  801da5:	f7 f1                	div    %ecx
  801da7:	89 c6                	mov    %eax,%esi
  801da9:	89 e8                	mov    %ebp,%eax
  801dab:	89 f7                	mov    %esi,%edi
  801dad:	f7 f1                	div    %ecx
  801daf:	89 fa                	mov    %edi,%edx
  801db1:	83 c4 1c             	add    $0x1c,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5f                   	pop    %edi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	89 f9                	mov    %edi,%ecx
  801dc2:	ba 20 00 00 00       	mov    $0x20,%edx
  801dc7:	29 fa                	sub    %edi,%edx
  801dc9:	d3 e0                	shl    %cl,%eax
  801dcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dcf:	89 d1                	mov    %edx,%ecx
  801dd1:	89 d8                	mov    %ebx,%eax
  801dd3:	d3 e8                	shr    %cl,%eax
  801dd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801dd9:	09 c1                	or     %eax,%ecx
  801ddb:	89 f0                	mov    %esi,%eax
  801ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de1:	89 f9                	mov    %edi,%ecx
  801de3:	d3 e3                	shl    %cl,%ebx
  801de5:	89 d1                	mov    %edx,%ecx
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 f9                	mov    %edi,%ecx
  801deb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801def:	89 eb                	mov    %ebp,%ebx
  801df1:	d3 e6                	shl    %cl,%esi
  801df3:	89 d1                	mov    %edx,%ecx
  801df5:	d3 eb                	shr    %cl,%ebx
  801df7:	09 f3                	or     %esi,%ebx
  801df9:	89 c6                	mov    %eax,%esi
  801dfb:	89 f2                	mov    %esi,%edx
  801dfd:	89 d8                	mov    %ebx,%eax
  801dff:	f7 74 24 08          	divl   0x8(%esp)
  801e03:	89 d6                	mov    %edx,%esi
  801e05:	89 c3                	mov    %eax,%ebx
  801e07:	f7 64 24 0c          	mull   0xc(%esp)
  801e0b:	39 d6                	cmp    %edx,%esi
  801e0d:	72 19                	jb     801e28 <__udivdi3+0x108>
  801e0f:	89 f9                	mov    %edi,%ecx
  801e11:	d3 e5                	shl    %cl,%ebp
  801e13:	39 c5                	cmp    %eax,%ebp
  801e15:	73 04                	jae    801e1b <__udivdi3+0xfb>
  801e17:	39 d6                	cmp    %edx,%esi
  801e19:	74 0d                	je     801e28 <__udivdi3+0x108>
  801e1b:	89 d8                	mov    %ebx,%eax
  801e1d:	31 ff                	xor    %edi,%edi
  801e1f:	e9 3c ff ff ff       	jmp    801d60 <__udivdi3+0x40>
  801e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e28:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e2b:	31 ff                	xor    %edi,%edi
  801e2d:	e9 2e ff ff ff       	jmp    801d60 <__udivdi3+0x40>
  801e32:	66 90                	xchg   %ax,%ax
  801e34:	66 90                	xchg   %ax,%ax
  801e36:	66 90                	xchg   %ax,%ax
  801e38:	66 90                	xchg   %ax,%ax
  801e3a:	66 90                	xchg   %ax,%ax
  801e3c:	66 90                	xchg   %ax,%ax
  801e3e:	66 90                	xchg   %ax,%ax

00801e40 <__umoddi3>:
  801e40:	f3 0f 1e fb          	endbr32 
  801e44:	55                   	push   %ebp
  801e45:	57                   	push   %edi
  801e46:	56                   	push   %esi
  801e47:	53                   	push   %ebx
  801e48:	83 ec 1c             	sub    $0x1c,%esp
  801e4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801e4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801e53:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801e57:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801e5b:	89 f0                	mov    %esi,%eax
  801e5d:	89 da                	mov    %ebx,%edx
  801e5f:	85 ff                	test   %edi,%edi
  801e61:	75 15                	jne    801e78 <__umoddi3+0x38>
  801e63:	39 dd                	cmp    %ebx,%ebp
  801e65:	76 39                	jbe    801ea0 <__umoddi3+0x60>
  801e67:	f7 f5                	div    %ebp
  801e69:	89 d0                	mov    %edx,%eax
  801e6b:	31 d2                	xor    %edx,%edx
  801e6d:	83 c4 1c             	add    $0x1c,%esp
  801e70:	5b                   	pop    %ebx
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    
  801e75:	8d 76 00             	lea    0x0(%esi),%esi
  801e78:	39 df                	cmp    %ebx,%edi
  801e7a:	77 f1                	ja     801e6d <__umoddi3+0x2d>
  801e7c:	0f bd cf             	bsr    %edi,%ecx
  801e7f:	83 f1 1f             	xor    $0x1f,%ecx
  801e82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801e86:	75 40                	jne    801ec8 <__umoddi3+0x88>
  801e88:	39 df                	cmp    %ebx,%edi
  801e8a:	72 04                	jb     801e90 <__umoddi3+0x50>
  801e8c:	39 f5                	cmp    %esi,%ebp
  801e8e:	77 dd                	ja     801e6d <__umoddi3+0x2d>
  801e90:	89 da                	mov    %ebx,%edx
  801e92:	89 f0                	mov    %esi,%eax
  801e94:	29 e8                	sub    %ebp,%eax
  801e96:	19 fa                	sbb    %edi,%edx
  801e98:	eb d3                	jmp    801e6d <__umoddi3+0x2d>
  801e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ea0:	89 e9                	mov    %ebp,%ecx
  801ea2:	85 ed                	test   %ebp,%ebp
  801ea4:	75 0b                	jne    801eb1 <__umoddi3+0x71>
  801ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  801eab:	31 d2                	xor    %edx,%edx
  801ead:	f7 f5                	div    %ebp
  801eaf:	89 c1                	mov    %eax,%ecx
  801eb1:	89 d8                	mov    %ebx,%eax
  801eb3:	31 d2                	xor    %edx,%edx
  801eb5:	f7 f1                	div    %ecx
  801eb7:	89 f0                	mov    %esi,%eax
  801eb9:	f7 f1                	div    %ecx
  801ebb:	89 d0                	mov    %edx,%eax
  801ebd:	31 d2                	xor    %edx,%edx
  801ebf:	eb ac                	jmp    801e6d <__umoddi3+0x2d>
  801ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ecc:	ba 20 00 00 00       	mov    $0x20,%edx
  801ed1:	29 c2                	sub    %eax,%edx
  801ed3:	89 c1                	mov    %eax,%ecx
  801ed5:	89 e8                	mov    %ebp,%eax
  801ed7:	d3 e7                	shl    %cl,%edi
  801ed9:	89 d1                	mov    %edx,%ecx
  801edb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801edf:	d3 e8                	shr    %cl,%eax
  801ee1:	89 c1                	mov    %eax,%ecx
  801ee3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ee7:	09 f9                	or     %edi,%ecx
  801ee9:	89 df                	mov    %ebx,%edi
  801eeb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eef:	89 c1                	mov    %eax,%ecx
  801ef1:	d3 e5                	shl    %cl,%ebp
  801ef3:	89 d1                	mov    %edx,%ecx
  801ef5:	d3 ef                	shr    %cl,%edi
  801ef7:	89 c1                	mov    %eax,%ecx
  801ef9:	89 f0                	mov    %esi,%eax
  801efb:	d3 e3                	shl    %cl,%ebx
  801efd:	89 d1                	mov    %edx,%ecx
  801eff:	89 fa                	mov    %edi,%edx
  801f01:	d3 e8                	shr    %cl,%eax
  801f03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f08:	09 d8                	or     %ebx,%eax
  801f0a:	f7 74 24 08          	divl   0x8(%esp)
  801f0e:	89 d3                	mov    %edx,%ebx
  801f10:	d3 e6                	shl    %cl,%esi
  801f12:	f7 e5                	mul    %ebp
  801f14:	89 c7                	mov    %eax,%edi
  801f16:	89 d1                	mov    %edx,%ecx
  801f18:	39 d3                	cmp    %edx,%ebx
  801f1a:	72 06                	jb     801f22 <__umoddi3+0xe2>
  801f1c:	75 0e                	jne    801f2c <__umoddi3+0xec>
  801f1e:	39 c6                	cmp    %eax,%esi
  801f20:	73 0a                	jae    801f2c <__umoddi3+0xec>
  801f22:	29 e8                	sub    %ebp,%eax
  801f24:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801f28:	89 d1                	mov    %edx,%ecx
  801f2a:	89 c7                	mov    %eax,%edi
  801f2c:	89 f5                	mov    %esi,%ebp
  801f2e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801f32:	29 fd                	sub    %edi,%ebp
  801f34:	19 cb                	sbb    %ecx,%ebx
  801f36:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801f3b:	89 d8                	mov    %ebx,%eax
  801f3d:	d3 e0                	shl    %cl,%eax
  801f3f:	89 f1                	mov    %esi,%ecx
  801f41:	d3 ed                	shr    %cl,%ebp
  801f43:	d3 eb                	shr    %cl,%ebx
  801f45:	09 e8                	or     %ebp,%eax
  801f47:	89 da                	mov    %ebx,%edx
  801f49:	83 c4 1c             	add    $0x1c,%esp
  801f4c:	5b                   	pop    %ebx
  801f4d:	5e                   	pop    %esi
  801f4e:	5f                   	pop    %edi
  801f4f:	5d                   	pop    %ebp
  801f50:	c3                   	ret    
