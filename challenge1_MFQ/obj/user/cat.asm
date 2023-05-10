
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
  800049:	e8 25 11 00 00       	call   801173 <read>
  80004e:	89 c3                	mov    %eax,%ebx
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	7e 2f                	jle    800086 <cat+0x53>
		if ((r = write(1, buf, n)) != n)
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	53                   	push   %ebx
  80005b:	68 00 40 80 00       	push   $0x804000
  800060:	6a 01                	push   $0x1
  800062:	e8 da 11 00 00       	call   801241 <write>
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
  800081:	e8 0a 01 00 00       	call   800190 <_panic>
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
  8000a2:	e8 e9 00 00 00       	call   800190 <_panic>

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
  8000ee:	e8 85 16 00 00       	call   801778 <printf>
  8000f3:	83 c4 10             	add    $0x10,%esp
		for (i = 1; i < argc; i++) {
  8000f6:	83 c6 01             	add    $0x1,%esi
  8000f9:	3b 75 08             	cmp    0x8(%ebp),%esi
  8000fc:	7d dc                	jge    8000da <umain+0x33>
			f = open(argv[i], O_RDONLY);
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	6a 00                	push   $0x0
  800103:	ff 34 b7             	push   (%edi,%esi,4)
  800106:	e8 cb 14 00 00       	call   8015d6 <open>
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
  800123:	e8 0f 0f 00 00       	call   801037 <close>
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
  800138:	e8 c6 0a 00 00       	call   800c03 <sys_getenvid>
  80013d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800142:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800148:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80014d:	a3 00 60 80 00       	mov    %eax,0x806000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800152:	85 db                	test   %ebx,%ebx
  800154:	7e 07                	jle    80015d <libmain+0x30>
		binaryname = argv[0];
  800156:	8b 06                	mov    (%esi),%eax
  800158:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80015d:	83 ec 08             	sub    $0x8,%esp
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	e8 40 ff ff ff       	call   8000a7 <umain>

	// exit gracefully
	exit();
  800167:	e8 0a 00 00 00       	call   800176 <exit>
}
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800172:	5b                   	pop    %ebx
  800173:	5e                   	pop    %esi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017c:	e8 e3 0e 00 00       	call   801064 <close_all>
	sys_env_destroy(0);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	6a 00                	push   $0x0
  800186:	e8 37 0a 00 00       	call   800bc2 <sys_env_destroy>
}
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	56                   	push   %esi
  800194:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800195:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800198:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80019e:	e8 60 0a 00 00       	call   800c03 <sys_getenvid>
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	ff 75 0c             	push   0xc(%ebp)
  8001a9:	ff 75 08             	push   0x8(%ebp)
  8001ac:	56                   	push   %esi
  8001ad:	50                   	push   %eax
  8001ae:	68 a4 24 80 00       	push   $0x8024a4
  8001b3:	e8 b3 00 00 00       	call   80026b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b8:	83 c4 18             	add    $0x18,%esp
  8001bb:	53                   	push   %ebx
  8001bc:	ff 75 10             	push   0x10(%ebp)
  8001bf:	e8 56 00 00 00       	call   80021a <vcprintf>
	cprintf("\n");
  8001c4:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
  8001cb:	e8 9b 00 00 00       	call   80026b <cprintf>
  8001d0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d3:	cc                   	int3   
  8001d4:	eb fd                	jmp    8001d3 <_panic+0x43>

008001d6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	53                   	push   %ebx
  8001da:	83 ec 04             	sub    $0x4,%esp
  8001dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e0:	8b 13                	mov    (%ebx),%edx
  8001e2:	8d 42 01             	lea    0x1(%edx),%eax
  8001e5:	89 03                	mov    %eax,(%ebx)
  8001e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f3:	74 09                	je     8001fe <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001fc:	c9                   	leave  
  8001fd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	68 ff 00 00 00       	push   $0xff
  800206:	8d 43 08             	lea    0x8(%ebx),%eax
  800209:	50                   	push   %eax
  80020a:	e8 76 09 00 00       	call   800b85 <sys_cputs>
		b->idx = 0;
  80020f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	eb db                	jmp    8001f5 <putch+0x1f>

0080021a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800223:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022a:	00 00 00 
	b.cnt = 0;
  80022d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800234:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800237:	ff 75 0c             	push   0xc(%ebp)
  80023a:	ff 75 08             	push   0x8(%ebp)
  80023d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800243:	50                   	push   %eax
  800244:	68 d6 01 80 00       	push   $0x8001d6
  800249:	e8 14 01 00 00       	call   800362 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024e:	83 c4 08             	add    $0x8,%esp
  800251:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800257:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025d:	50                   	push   %eax
  80025e:	e8 22 09 00 00       	call   800b85 <sys_cputs>

	return b.cnt;
}
  800263:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800271:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 08             	push   0x8(%ebp)
  800278:	e8 9d ff ff ff       	call   80021a <vcprintf>
	va_end(ap);

	return cnt;
}
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 1c             	sub    $0x1c,%esp
  800288:	89 c7                	mov    %eax,%edi
  80028a:	89 d6                	mov    %edx,%esi
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800292:	89 d1                	mov    %edx,%ecx
  800294:	89 c2                	mov    %eax,%edx
  800296:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800299:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029c:	8b 45 10             	mov    0x10(%ebp),%eax
  80029f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002ac:	39 c2                	cmp    %eax,%edx
  8002ae:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b1:	72 3e                	jb     8002f1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b3:	83 ec 0c             	sub    $0xc,%esp
  8002b6:	ff 75 18             	push   0x18(%ebp)
  8002b9:	83 eb 01             	sub    $0x1,%ebx
  8002bc:	53                   	push   %ebx
  8002bd:	50                   	push   %eax
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	ff 75 e4             	push   -0x1c(%ebp)
  8002c4:	ff 75 e0             	push   -0x20(%ebp)
  8002c7:	ff 75 dc             	push   -0x24(%ebp)
  8002ca:	ff 75 d8             	push   -0x28(%ebp)
  8002cd:	e8 2e 1f 00 00       	call   802200 <__udivdi3>
  8002d2:	83 c4 18             	add    $0x18,%esp
  8002d5:	52                   	push   %edx
  8002d6:	50                   	push   %eax
  8002d7:	89 f2                	mov    %esi,%edx
  8002d9:	89 f8                	mov    %edi,%eax
  8002db:	e8 9f ff ff ff       	call   80027f <printnum>
  8002e0:	83 c4 20             	add    $0x20,%esp
  8002e3:	eb 13                	jmp    8002f8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	56                   	push   %esi
  8002e9:	ff 75 18             	push   0x18(%ebp)
  8002ec:	ff d7                	call   *%edi
  8002ee:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f1:	83 eb 01             	sub    $0x1,%ebx
  8002f4:	85 db                	test   %ebx,%ebx
  8002f6:	7f ed                	jg     8002e5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f8:	83 ec 08             	sub    $0x8,%esp
  8002fb:	56                   	push   %esi
  8002fc:	83 ec 04             	sub    $0x4,%esp
  8002ff:	ff 75 e4             	push   -0x1c(%ebp)
  800302:	ff 75 e0             	push   -0x20(%ebp)
  800305:	ff 75 dc             	push   -0x24(%ebp)
  800308:	ff 75 d8             	push   -0x28(%ebp)
  80030b:	e8 10 20 00 00       	call   802320 <__umoddi3>
  800310:	83 c4 14             	add    $0x14,%esp
  800313:	0f be 80 c7 24 80 00 	movsbl 0x8024c7(%eax),%eax
  80031a:	50                   	push   %eax
  80031b:	ff d7                	call   *%edi
}
  80031d:	83 c4 10             	add    $0x10,%esp
  800320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800332:	8b 10                	mov    (%eax),%edx
  800334:	3b 50 04             	cmp    0x4(%eax),%edx
  800337:	73 0a                	jae    800343 <sprintputch+0x1b>
		*b->buf++ = ch;
  800339:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033c:	89 08                	mov    %ecx,(%eax)
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	88 02                	mov    %al,(%edx)
}
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <printfmt>:
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80034b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034e:	50                   	push   %eax
  80034f:	ff 75 10             	push   0x10(%ebp)
  800352:	ff 75 0c             	push   0xc(%ebp)
  800355:	ff 75 08             	push   0x8(%ebp)
  800358:	e8 05 00 00 00       	call   800362 <vprintfmt>
}
  80035d:	83 c4 10             	add    $0x10,%esp
  800360:	c9                   	leave  
  800361:	c3                   	ret    

00800362 <vprintfmt>:
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	57                   	push   %edi
  800366:	56                   	push   %esi
  800367:	53                   	push   %ebx
  800368:	83 ec 3c             	sub    $0x3c,%esp
  80036b:	8b 75 08             	mov    0x8(%ebp),%esi
  80036e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800371:	8b 7d 10             	mov    0x10(%ebp),%edi
  800374:	eb 0a                	jmp    800380 <vprintfmt+0x1e>
			putch(ch, putdat);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	53                   	push   %ebx
  80037a:	50                   	push   %eax
  80037b:	ff d6                	call   *%esi
  80037d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800380:	83 c7 01             	add    $0x1,%edi
  800383:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800387:	83 f8 25             	cmp    $0x25,%eax
  80038a:	74 0c                	je     800398 <vprintfmt+0x36>
			if (ch == '\0')
  80038c:	85 c0                	test   %eax,%eax
  80038e:	75 e6                	jne    800376 <vprintfmt+0x14>
}
  800390:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800393:	5b                   	pop    %ebx
  800394:	5e                   	pop    %esi
  800395:	5f                   	pop    %edi
  800396:	5d                   	pop    %ebp
  800397:	c3                   	ret    
		padc = ' ';
  800398:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80039c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003a3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003aa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003b1:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8d 47 01             	lea    0x1(%edi),%eax
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	0f b6 17             	movzbl (%edi),%edx
  8003bf:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003c2:	3c 55                	cmp    $0x55,%al
  8003c4:	0f 87 bb 03 00 00    	ja     800785 <vprintfmt+0x423>
  8003ca:	0f b6 c0             	movzbl %al,%eax
  8003cd:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003d7:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003db:	eb d9                	jmp    8003b6 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e0:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003e4:	eb d0                	jmp    8003b6 <vprintfmt+0x54>
  8003e6:	0f b6 d2             	movzbl %dl,%edx
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003f4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003fb:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003fe:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800401:	83 f9 09             	cmp    $0x9,%ecx
  800404:	77 55                	ja     80045b <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800406:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800409:	eb e9                	jmp    8003f4 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 40 04             	lea    0x4(%eax),%eax
  800419:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80041f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800423:	79 91                	jns    8003b6 <vprintfmt+0x54>
				width = precision, precision = -1;
  800425:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800432:	eb 82                	jmp    8003b6 <vprintfmt+0x54>
  800434:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800437:	85 d2                	test   %edx,%edx
  800439:	b8 00 00 00 00       	mov    $0x0,%eax
  80043e:	0f 49 c2             	cmovns %edx,%eax
  800441:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800447:	e9 6a ff ff ff       	jmp    8003b6 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80044f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800456:	e9 5b ff ff ff       	jmp    8003b6 <vprintfmt+0x54>
  80045b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80045e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800461:	eb bc                	jmp    80041f <vprintfmt+0xbd>
			lflag++;
  800463:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800469:	e9 48 ff ff ff       	jmp    8003b6 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 78 04             	lea    0x4(%eax),%edi
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	53                   	push   %ebx
  800478:	ff 30                	push   (%eax)
  80047a:	ff d6                	call   *%esi
			break;
  80047c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80047f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800482:	e9 9d 02 00 00       	jmp    800724 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8d 78 04             	lea    0x4(%eax),%edi
  80048d:	8b 10                	mov    (%eax),%edx
  80048f:	89 d0                	mov    %edx,%eax
  800491:	f7 d8                	neg    %eax
  800493:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800496:	83 f8 0f             	cmp    $0xf,%eax
  800499:	7f 23                	jg     8004be <vprintfmt+0x15c>
  80049b:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  8004a2:	85 d2                	test   %edx,%edx
  8004a4:	74 18                	je     8004be <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004a6:	52                   	push   %edx
  8004a7:	68 95 28 80 00       	push   $0x802895
  8004ac:	53                   	push   %ebx
  8004ad:	56                   	push   %esi
  8004ae:	e8 92 fe ff ff       	call   800345 <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004b6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004b9:	e9 66 02 00 00       	jmp    800724 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004be:	50                   	push   %eax
  8004bf:	68 df 24 80 00       	push   $0x8024df
  8004c4:	53                   	push   %ebx
  8004c5:	56                   	push   %esi
  8004c6:	e8 7a fe ff ff       	call   800345 <printfmt>
  8004cb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ce:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004d1:	e9 4e 02 00 00       	jmp    800724 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	83 c0 04             	add    $0x4,%eax
  8004dc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004e4:	85 d2                	test   %edx,%edx
  8004e6:	b8 d8 24 80 00       	mov    $0x8024d8,%eax
  8004eb:	0f 45 c2             	cmovne %edx,%eax
  8004ee:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f5:	7e 06                	jle    8004fd <vprintfmt+0x19b>
  8004f7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004fb:	75 0d                	jne    80050a <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800500:	89 c7                	mov    %eax,%edi
  800502:	03 45 e0             	add    -0x20(%ebp),%eax
  800505:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800508:	eb 55                	jmp    80055f <vprintfmt+0x1fd>
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 d8             	push   -0x28(%ebp)
  800510:	ff 75 cc             	push   -0x34(%ebp)
  800513:	e8 0a 03 00 00       	call   800822 <strnlen>
  800518:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051b:	29 c1                	sub    %eax,%ecx
  80051d:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800525:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800529:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80052c:	eb 0f                	jmp    80053d <vprintfmt+0x1db>
					putch(padc, putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	53                   	push   %ebx
  800532:	ff 75 e0             	push   -0x20(%ebp)
  800535:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800537:	83 ef 01             	sub    $0x1,%edi
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	85 ff                	test   %edi,%edi
  80053f:	7f ed                	jg     80052e <vprintfmt+0x1cc>
  800541:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800544:	85 d2                	test   %edx,%edx
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
  80054b:	0f 49 c2             	cmovns %edx,%eax
  80054e:	29 c2                	sub    %eax,%edx
  800550:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800553:	eb a8                	jmp    8004fd <vprintfmt+0x19b>
					putch(ch, putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	52                   	push   %edx
  80055a:	ff d6                	call   *%esi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800562:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056b:	0f be d0             	movsbl %al,%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	74 4b                	je     8005bd <vprintfmt+0x25b>
  800572:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800576:	78 06                	js     80057e <vprintfmt+0x21c>
  800578:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80057c:	78 1e                	js     80059c <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80057e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800582:	74 d1                	je     800555 <vprintfmt+0x1f3>
  800584:	0f be c0             	movsbl %al,%eax
  800587:	83 e8 20             	sub    $0x20,%eax
  80058a:	83 f8 5e             	cmp    $0x5e,%eax
  80058d:	76 c6                	jbe    800555 <vprintfmt+0x1f3>
					putch('?', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 3f                	push   $0x3f
  800595:	ff d6                	call   *%esi
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	eb c3                	jmp    80055f <vprintfmt+0x1fd>
  80059c:	89 cf                	mov    %ecx,%edi
  80059e:	eb 0e                	jmp    8005ae <vprintfmt+0x24c>
				putch(' ', putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	6a 20                	push   $0x20
  8005a6:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005a8:	83 ef 01             	sub    $0x1,%edi
  8005ab:	83 c4 10             	add    $0x10,%esp
  8005ae:	85 ff                	test   %edi,%edi
  8005b0:	7f ee                	jg     8005a0 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005b2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b8:	e9 67 01 00 00       	jmp    800724 <vprintfmt+0x3c2>
  8005bd:	89 cf                	mov    %ecx,%edi
  8005bf:	eb ed                	jmp    8005ae <vprintfmt+0x24c>
	if (lflag >= 2)
  8005c1:	83 f9 01             	cmp    $0x1,%ecx
  8005c4:	7f 1b                	jg     8005e1 <vprintfmt+0x27f>
	else if (lflag)
  8005c6:	85 c9                	test   %ecx,%ecx
  8005c8:	74 63                	je     80062d <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 00                	mov    (%eax),%eax
  8005cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d2:	99                   	cltd   
  8005d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 40 04             	lea    0x4(%eax),%eax
  8005dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005df:	eb 17                	jmp    8005f8 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 50 04             	mov    0x4(%eax),%edx
  8005e7:	8b 00                	mov    (%eax),%eax
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 40 08             	lea    0x8(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005fe:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800603:	85 c9                	test   %ecx,%ecx
  800605:	0f 89 ff 00 00 00    	jns    80070a <vprintfmt+0x3a8>
				putch('-', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 2d                	push   $0x2d
  800611:	ff d6                	call   *%esi
				num = -(long long) num;
  800613:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800616:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800619:	f7 da                	neg    %edx
  80061b:	83 d1 00             	adc    $0x0,%ecx
  80061e:	f7 d9                	neg    %ecx
  800620:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800623:	bf 0a 00 00 00       	mov    $0xa,%edi
  800628:	e9 dd 00 00 00       	jmp    80070a <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8b 00                	mov    (%eax),%eax
  800632:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800635:	99                   	cltd   
  800636:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
  800642:	eb b4                	jmp    8005f8 <vprintfmt+0x296>
	if (lflag >= 2)
  800644:	83 f9 01             	cmp    $0x1,%ecx
  800647:	7f 1e                	jg     800667 <vprintfmt+0x305>
	else if (lflag)
  800649:	85 c9                	test   %ecx,%ecx
  80064b:	74 32                	je     80067f <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 10                	mov    (%eax),%edx
  800652:	b9 00 00 00 00       	mov    $0x0,%ecx
  800657:	8d 40 04             	lea    0x4(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80065d:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800662:	e9 a3 00 00 00       	jmp    80070a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	8b 48 04             	mov    0x4(%eax),%ecx
  80066f:	8d 40 08             	lea    0x8(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800675:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80067a:	e9 8b 00 00 00       	jmp    80070a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	b9 00 00 00 00       	mov    $0x0,%ecx
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800694:	eb 74                	jmp    80070a <vprintfmt+0x3a8>
	if (lflag >= 2)
  800696:	83 f9 01             	cmp    $0x1,%ecx
  800699:	7f 1b                	jg     8006b6 <vprintfmt+0x354>
	else if (lflag)
  80069b:	85 c9                	test   %ecx,%ecx
  80069d:	74 2c                	je     8006cb <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006af:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8006b4:	eb 54                	jmp    80070a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8b 10                	mov    (%eax),%edx
  8006bb:	8b 48 04             	mov    0x4(%eax),%ecx
  8006be:	8d 40 08             	lea    0x8(%eax),%eax
  8006c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006c4:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8006c9:	eb 3f                	jmp    80070a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 10                	mov    (%eax),%edx
  8006d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d5:	8d 40 04             	lea    0x4(%eax),%eax
  8006d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006db:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8006e0:	eb 28                	jmp    80070a <vprintfmt+0x3a8>
			putch('0', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 30                	push   $0x30
  8006e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ea:	83 c4 08             	add    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 78                	push   $0x78
  8006f0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 10                	mov    (%eax),%edx
  8006f7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006fc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800705:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80070a:	83 ec 0c             	sub    $0xc,%esp
  80070d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800711:	50                   	push   %eax
  800712:	ff 75 e0             	push   -0x20(%ebp)
  800715:	57                   	push   %edi
  800716:	51                   	push   %ecx
  800717:	52                   	push   %edx
  800718:	89 da                	mov    %ebx,%edx
  80071a:	89 f0                	mov    %esi,%eax
  80071c:	e8 5e fb ff ff       	call   80027f <printnum>
			break;
  800721:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800727:	e9 54 fc ff ff       	jmp    800380 <vprintfmt+0x1e>
	if (lflag >= 2)
  80072c:	83 f9 01             	cmp    $0x1,%ecx
  80072f:	7f 1b                	jg     80074c <vprintfmt+0x3ea>
	else if (lflag)
  800731:	85 c9                	test   %ecx,%ecx
  800733:	74 2c                	je     800761 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073f:	8d 40 04             	lea    0x4(%eax),%eax
  800742:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800745:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80074a:	eb be                	jmp    80070a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8b 10                	mov    (%eax),%edx
  800751:	8b 48 04             	mov    0x4(%eax),%ecx
  800754:	8d 40 08             	lea    0x8(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80075f:	eb a9                	jmp    80070a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8b 10                	mov    (%eax),%edx
  800766:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076b:	8d 40 04             	lea    0x4(%eax),%eax
  80076e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800771:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800776:	eb 92                	jmp    80070a <vprintfmt+0x3a8>
			putch(ch, putdat);
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	53                   	push   %ebx
  80077c:	6a 25                	push   $0x25
  80077e:	ff d6                	call   *%esi
			break;
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	eb 9f                	jmp    800724 <vprintfmt+0x3c2>
			putch('%', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 25                	push   $0x25
  80078b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	89 f8                	mov    %edi,%eax
  800792:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800796:	74 05                	je     80079d <vprintfmt+0x43b>
  800798:	83 e8 01             	sub    $0x1,%eax
  80079b:	eb f5                	jmp    800792 <vprintfmt+0x430>
  80079d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a0:	eb 82                	jmp    800724 <vprintfmt+0x3c2>

008007a2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 18             	sub    $0x18,%esp
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	74 26                	je     8007e9 <vsnprintf+0x47>
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	7e 22                	jle    8007e9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c7:	ff 75 14             	push   0x14(%ebp)
  8007ca:	ff 75 10             	push   0x10(%ebp)
  8007cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	68 28 03 80 00       	push   $0x800328
  8007d6:	e8 87 fb ff ff       	call   800362 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007de:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e4:	83 c4 10             	add    $0x10,%esp
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    
		return -E_INVAL;
  8007e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ee:	eb f7                	jmp    8007e7 <vsnprintf+0x45>

008007f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f9:	50                   	push   %eax
  8007fa:	ff 75 10             	push   0x10(%ebp)
  8007fd:	ff 75 0c             	push   0xc(%ebp)
  800800:	ff 75 08             	push   0x8(%ebp)
  800803:	e8 9a ff ff ff       	call   8007a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	eb 03                	jmp    80081a <strlen+0x10>
		n++;
  800817:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80081a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081e:	75 f7                	jne    800817 <strlen+0xd>
	return n;
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
  800830:	eb 03                	jmp    800835 <strnlen+0x13>
		n++;
  800832:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800835:	39 d0                	cmp    %edx,%eax
  800837:	74 08                	je     800841 <strnlen+0x1f>
  800839:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80083d:	75 f3                	jne    800832 <strnlen+0x10>
  80083f:	89 c2                	mov    %eax,%edx
	return n;
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800858:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	84 d2                	test   %dl,%dl
  800860:	75 f2                	jne    800854 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800862:	89 c8                	mov    %ecx,%eax
  800864:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	83 ec 10             	sub    $0x10,%esp
  800870:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800873:	53                   	push   %ebx
  800874:	e8 91 ff ff ff       	call   80080a <strlen>
  800879:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80087c:	ff 75 0c             	push   0xc(%ebp)
  80087f:	01 d8                	add    %ebx,%eax
  800881:	50                   	push   %eax
  800882:	e8 be ff ff ff       	call   800845 <strcpy>
	return dst;
}
  800887:	89 d8                	mov    %ebx,%eax
  800889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	56                   	push   %esi
  800892:	53                   	push   %ebx
  800893:	8b 75 08             	mov    0x8(%ebp),%esi
  800896:	8b 55 0c             	mov    0xc(%ebp),%edx
  800899:	89 f3                	mov    %esi,%ebx
  80089b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089e:	89 f0                	mov    %esi,%eax
  8008a0:	eb 0f                	jmp    8008b1 <strncpy+0x23>
		*dst++ = *src;
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	0f b6 0a             	movzbl (%edx),%ecx
  8008a8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ab:	80 f9 01             	cmp    $0x1,%cl
  8008ae:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008b1:	39 d8                	cmp    %ebx,%eax
  8008b3:	75 ed                	jne    8008a2 <strncpy+0x14>
	}
	return ret;
}
  8008b5:	89 f0                	mov    %esi,%eax
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c6:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008cb:	85 d2                	test   %edx,%edx
  8008cd:	74 21                	je     8008f0 <strlcpy+0x35>
  8008cf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d3:	89 f2                	mov    %esi,%edx
  8008d5:	eb 09                	jmp    8008e0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d7:	83 c1 01             	add    $0x1,%ecx
  8008da:	83 c2 01             	add    $0x1,%edx
  8008dd:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8008e0:	39 c2                	cmp    %eax,%edx
  8008e2:	74 09                	je     8008ed <strlcpy+0x32>
  8008e4:	0f b6 19             	movzbl (%ecx),%ebx
  8008e7:	84 db                	test   %bl,%bl
  8008e9:	75 ec                	jne    8008d7 <strlcpy+0x1c>
  8008eb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f0:	29 f0                	sub    %esi,%eax
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ff:	eb 06                	jmp    800907 <strcmp+0x11>
		p++, q++;
  800901:	83 c1 01             	add    $0x1,%ecx
  800904:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800907:	0f b6 01             	movzbl (%ecx),%eax
  80090a:	84 c0                	test   %al,%al
  80090c:	74 04                	je     800912 <strcmp+0x1c>
  80090e:	3a 02                	cmp    (%edx),%al
  800910:	74 ef                	je     800901 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800912:	0f b6 c0             	movzbl %al,%eax
  800915:	0f b6 12             	movzbl (%edx),%edx
  800918:	29 d0                	sub    %edx,%eax
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	53                   	push   %ebx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	89 c3                	mov    %eax,%ebx
  800928:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092b:	eb 06                	jmp    800933 <strncmp+0x17>
		n--, p++, q++;
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800933:	39 d8                	cmp    %ebx,%eax
  800935:	74 18                	je     80094f <strncmp+0x33>
  800937:	0f b6 08             	movzbl (%eax),%ecx
  80093a:	84 c9                	test   %cl,%cl
  80093c:	74 04                	je     800942 <strncmp+0x26>
  80093e:	3a 0a                	cmp    (%edx),%cl
  800940:	74 eb                	je     80092d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800942:	0f b6 00             	movzbl (%eax),%eax
  800945:	0f b6 12             	movzbl (%edx),%edx
  800948:	29 d0                	sub    %edx,%eax
}
  80094a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    
		return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb f4                	jmp    80094a <strncmp+0x2e>

00800956 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800960:	eb 03                	jmp    800965 <strchr+0xf>
  800962:	83 c0 01             	add    $0x1,%eax
  800965:	0f b6 10             	movzbl (%eax),%edx
  800968:	84 d2                	test   %dl,%dl
  80096a:	74 06                	je     800972 <strchr+0x1c>
		if (*s == c)
  80096c:	38 ca                	cmp    %cl,%dl
  80096e:	75 f2                	jne    800962 <strchr+0xc>
  800970:	eb 05                	jmp    800977 <strchr+0x21>
			return (char *) s;
	return 0;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800983:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800986:	38 ca                	cmp    %cl,%dl
  800988:	74 09                	je     800993 <strfind+0x1a>
  80098a:	84 d2                	test   %dl,%dl
  80098c:	74 05                	je     800993 <strfind+0x1a>
	for (; *s; s++)
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	eb f0                	jmp    800983 <strfind+0xa>
			break;
	return (char *) s;
}
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a1:	85 c9                	test   %ecx,%ecx
  8009a3:	74 2f                	je     8009d4 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a5:	89 f8                	mov    %edi,%eax
  8009a7:	09 c8                	or     %ecx,%eax
  8009a9:	a8 03                	test   $0x3,%al
  8009ab:	75 21                	jne    8009ce <memset+0x39>
		c &= 0xFF;
  8009ad:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c1 e0 08             	shl    $0x8,%eax
  8009b6:	89 d3                	mov    %edx,%ebx
  8009b8:	c1 e3 18             	shl    $0x18,%ebx
  8009bb:	89 d6                	mov    %edx,%esi
  8009bd:	c1 e6 10             	shl    $0x10,%esi
  8009c0:	09 f3                	or     %esi,%ebx
  8009c2:	09 da                	or     %ebx,%edx
  8009c4:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c9:	fc                   	cld    
  8009ca:	f3 ab                	rep stos %eax,%es:(%edi)
  8009cc:	eb 06                	jmp    8009d4 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d1:	fc                   	cld    
  8009d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d4:	89 f8                	mov    %edi,%eax
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e9:	39 c6                	cmp    %eax,%esi
  8009eb:	73 32                	jae    800a1f <memmove+0x44>
  8009ed:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f0:	39 c2                	cmp    %eax,%edx
  8009f2:	76 2b                	jbe    800a1f <memmove+0x44>
		s += n;
		d += n;
  8009f4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f7:	89 d6                	mov    %edx,%esi
  8009f9:	09 fe                	or     %edi,%esi
  8009fb:	09 ce                	or     %ecx,%esi
  8009fd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a03:	75 0e                	jne    800a13 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a05:	83 ef 04             	sub    $0x4,%edi
  800a08:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a0e:	fd                   	std    
  800a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a11:	eb 09                	jmp    800a1c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a13:	83 ef 01             	sub    $0x1,%edi
  800a16:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a19:	fd                   	std    
  800a1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1c:	fc                   	cld    
  800a1d:	eb 1a                	jmp    800a39 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1f:	89 f2                	mov    %esi,%edx
  800a21:	09 c2                	or     %eax,%edx
  800a23:	09 ca                	or     %ecx,%edx
  800a25:	f6 c2 03             	test   $0x3,%dl
  800a28:	75 0a                	jne    800a34 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a2d:	89 c7                	mov    %eax,%edi
  800a2f:	fc                   	cld    
  800a30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a32:	eb 05                	jmp    800a39 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a34:	89 c7                	mov    %eax,%edi
  800a36:	fc                   	cld    
  800a37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a43:	ff 75 10             	push   0x10(%ebp)
  800a46:	ff 75 0c             	push   0xc(%ebp)
  800a49:	ff 75 08             	push   0x8(%ebp)
  800a4c:	e8 8a ff ff ff       	call   8009db <memmove>
}
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    

00800a53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5e:	89 c6                	mov    %eax,%esi
  800a60:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a63:	eb 06                	jmp    800a6b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a65:	83 c0 01             	add    $0x1,%eax
  800a68:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a6b:	39 f0                	cmp    %esi,%eax
  800a6d:	74 14                	je     800a83 <memcmp+0x30>
		if (*s1 != *s2)
  800a6f:	0f b6 08             	movzbl (%eax),%ecx
  800a72:	0f b6 1a             	movzbl (%edx),%ebx
  800a75:	38 d9                	cmp    %bl,%cl
  800a77:	74 ec                	je     800a65 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a79:	0f b6 c1             	movzbl %cl,%eax
  800a7c:	0f b6 db             	movzbl %bl,%ebx
  800a7f:	29 d8                	sub    %ebx,%eax
  800a81:	eb 05                	jmp    800a88 <memcmp+0x35>
	}

	return 0;
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a95:	89 c2                	mov    %eax,%edx
  800a97:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a9a:	eb 03                	jmp    800a9f <memfind+0x13>
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	39 d0                	cmp    %edx,%eax
  800aa1:	73 04                	jae    800aa7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa3:	38 08                	cmp    %cl,(%eax)
  800aa5:	75 f5                	jne    800a9c <memfind+0x10>
			break;
	return (void *) s;
}
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab5:	eb 03                	jmp    800aba <strtol+0x11>
		s++;
  800ab7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800aba:	0f b6 02             	movzbl (%edx),%eax
  800abd:	3c 20                	cmp    $0x20,%al
  800abf:	74 f6                	je     800ab7 <strtol+0xe>
  800ac1:	3c 09                	cmp    $0x9,%al
  800ac3:	74 f2                	je     800ab7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ac5:	3c 2b                	cmp    $0x2b,%al
  800ac7:	74 2a                	je     800af3 <strtol+0x4a>
	int neg = 0;
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ace:	3c 2d                	cmp    $0x2d,%al
  800ad0:	74 2b                	je     800afd <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad8:	75 0f                	jne    800ae9 <strtol+0x40>
  800ada:	80 3a 30             	cmpb   $0x30,(%edx)
  800add:	74 28                	je     800b07 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adf:	85 db                	test   %ebx,%ebx
  800ae1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae6:	0f 44 d8             	cmove  %eax,%ebx
  800ae9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800af1:	eb 46                	jmp    800b39 <strtol+0x90>
		s++;
  800af3:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800af6:	bf 00 00 00 00       	mov    $0x0,%edi
  800afb:	eb d5                	jmp    800ad2 <strtol+0x29>
		s++, neg = 1;
  800afd:	83 c2 01             	add    $0x1,%edx
  800b00:	bf 01 00 00 00       	mov    $0x1,%edi
  800b05:	eb cb                	jmp    800ad2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b07:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b0b:	74 0e                	je     800b1b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b0d:	85 db                	test   %ebx,%ebx
  800b0f:	75 d8                	jne    800ae9 <strtol+0x40>
		s++, base = 8;
  800b11:	83 c2 01             	add    $0x1,%edx
  800b14:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b19:	eb ce                	jmp    800ae9 <strtol+0x40>
		s += 2, base = 16;
  800b1b:	83 c2 02             	add    $0x2,%edx
  800b1e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b23:	eb c4                	jmp    800ae9 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b25:	0f be c0             	movsbl %al,%eax
  800b28:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b2e:	7d 3a                	jge    800b6a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b30:	83 c2 01             	add    $0x1,%edx
  800b33:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b37:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b39:	0f b6 02             	movzbl (%edx),%eax
  800b3c:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 09             	cmp    $0x9,%bl
  800b44:	76 df                	jbe    800b25 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b46:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b49:	89 f3                	mov    %esi,%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 08                	ja     800b58 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b50:	0f be c0             	movsbl %al,%eax
  800b53:	83 e8 57             	sub    $0x57,%eax
  800b56:	eb d3                	jmp    800b2b <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b58:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 19             	cmp    $0x19,%bl
  800b60:	77 08                	ja     800b6a <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b62:	0f be c0             	movsbl %al,%eax
  800b65:	83 e8 37             	sub    $0x37,%eax
  800b68:	eb c1                	jmp    800b2b <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6e:	74 05                	je     800b75 <strtol+0xcc>
		*endptr = (char *) s;
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b75:	89 c8                	mov    %ecx,%eax
  800b77:	f7 d8                	neg    %eax
  800b79:	85 ff                	test   %edi,%edi
  800b7b:	0f 45 c8             	cmovne %eax,%ecx
}
  800b7e:	89 c8                	mov    %ecx,%eax
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	89 c3                	mov    %eax,%ebx
  800b98:	89 c7                	mov    %eax,%edi
  800b9a:	89 c6                	mov    %eax,%esi
  800b9c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd8:	89 cb                	mov    %ecx,%ebx
  800bda:	89 cf                	mov    %ecx,%edi
  800bdc:	89 ce                	mov    %ecx,%esi
  800bde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7f 08                	jg     800bec <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	50                   	push   %eax
  800bf0:	6a 03                	push   $0x3
  800bf2:	68 bf 27 80 00       	push   $0x8027bf
  800bf7:	6a 2a                	push   $0x2a
  800bf9:	68 dc 27 80 00       	push   $0x8027dc
  800bfe:	e8 8d f5 ff ff       	call   800190 <_panic>

00800c03 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c09:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c13:	89 d1                	mov    %edx,%ecx
  800c15:	89 d3                	mov    %edx,%ebx
  800c17:	89 d7                	mov    %edx,%edi
  800c19:	89 d6                	mov    %edx,%esi
  800c1b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_yield>:

void
sys_yield(void)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c32:	89 d1                	mov    %edx,%ecx
  800c34:	89 d3                	mov    %edx,%ebx
  800c36:	89 d7                	mov    %edx,%edi
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4a:	be 00 00 00 00       	mov    $0x0,%esi
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5d:	89 f7                	mov    %esi,%edi
  800c5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7f 08                	jg     800c6d <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 04                	push   $0x4
  800c73:	68 bf 27 80 00       	push   $0x8027bf
  800c78:	6a 2a                	push   $0x2a
  800c7a:	68 dc 27 80 00       	push   $0x8027dc
  800c7f:	e8 0c f5 ff ff       	call   800190 <_panic>

00800c84 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	b8 05 00 00 00       	mov    $0x5,%eax
  800c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c9e:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7f 08                	jg     800caf <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	50                   	push   %eax
  800cb3:	6a 05                	push   $0x5
  800cb5:	68 bf 27 80 00       	push   $0x8027bf
  800cba:	6a 2a                	push   $0x2a
  800cbc:	68 dc 27 80 00       	push   $0x8027dc
  800cc1:	e8 ca f4 ff ff       	call   800190 <_panic>

00800cc6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdf:	89 df                	mov    %ebx,%edi
  800ce1:	89 de                	mov    %ebx,%esi
  800ce3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7f 08                	jg     800cf1 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf1:	83 ec 0c             	sub    $0xc,%esp
  800cf4:	50                   	push   %eax
  800cf5:	6a 06                	push   $0x6
  800cf7:	68 bf 27 80 00       	push   $0x8027bf
  800cfc:	6a 2a                	push   $0x2a
  800cfe:	68 dc 27 80 00       	push   $0x8027dc
  800d03:	e8 88 f4 ff ff       	call   800190 <_panic>

00800d08 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d21:	89 df                	mov    %ebx,%edi
  800d23:	89 de                	mov    %ebx,%esi
  800d25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7f 08                	jg     800d33 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	50                   	push   %eax
  800d37:	6a 08                	push   $0x8
  800d39:	68 bf 27 80 00       	push   $0x8027bf
  800d3e:	6a 2a                	push   $0x2a
  800d40:	68 dc 27 80 00       	push   $0x8027dc
  800d45:	e8 46 f4 ff ff       	call   800190 <_panic>

00800d4a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7f 08                	jg     800d75 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	50                   	push   %eax
  800d79:	6a 09                	push   $0x9
  800d7b:	68 bf 27 80 00       	push   $0x8027bf
  800d80:	6a 2a                	push   $0x2a
  800d82:	68 dc 27 80 00       	push   $0x8027dc
  800d87:	e8 04 f4 ff ff       	call   800190 <_panic>

00800d8c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da5:	89 df                	mov    %ebx,%edi
  800da7:	89 de                	mov    %ebx,%esi
  800da9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7f 08                	jg     800db7 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800daf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	83 ec 0c             	sub    $0xc,%esp
  800dba:	50                   	push   %eax
  800dbb:	6a 0a                	push   $0xa
  800dbd:	68 bf 27 80 00       	push   $0x8027bf
  800dc2:	6a 2a                	push   $0x2a
  800dc4:	68 dc 27 80 00       	push   $0x8027dc
  800dc9:	e8 c2 f3 ff ff       	call   800190 <_panic>

00800dce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddf:	be 00 00 00 00       	mov    $0x0,%esi
  800de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dea:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
  800df7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dff:	8b 55 08             	mov    0x8(%ebp),%edx
  800e02:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e07:	89 cb                	mov    %ecx,%ebx
  800e09:	89 cf                	mov    %ecx,%edi
  800e0b:	89 ce                	mov    %ecx,%esi
  800e0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7f 08                	jg     800e1b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
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
  800e1f:	6a 0d                	push   $0xd
  800e21:	68 bf 27 80 00       	push   $0x8027bf
  800e26:	6a 2a                	push   $0x2a
  800e28:	68 dc 27 80 00       	push   $0x8027dc
  800e2d:	e8 5e f3 ff ff       	call   800190 <_panic>

00800e32 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e38:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e42:	89 d1                	mov    %edx,%ecx
  800e44:	89 d3                	mov    %edx,%ebx
  800e46:	89 d7                	mov    %edx,%edi
  800e48:	89 d6                	mov    %edx,%esi
  800e4a:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	57                   	push   %edi
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e67:	89 df                	mov    %ebx,%edi
  800e69:	89 de                	mov    %ebx,%esi
  800e6b:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e83:	b8 10 00 00 00       	mov    $0x10,%eax
  800e88:	89 df                	mov    %ebx,%edi
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
  800e99:	05 00 00 00 30       	add    $0x30000000,%eax
  800e9e:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eb3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec2:	89 c2                	mov    %eax,%edx
  800ec4:	c1 ea 16             	shr    $0x16,%edx
  800ec7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ece:	f6 c2 01             	test   $0x1,%dl
  800ed1:	74 29                	je     800efc <fd_alloc+0x42>
  800ed3:	89 c2                	mov    %eax,%edx
  800ed5:	c1 ea 0c             	shr    $0xc,%edx
  800ed8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edf:	f6 c2 01             	test   $0x1,%dl
  800ee2:	74 18                	je     800efc <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800ee4:	05 00 10 00 00       	add    $0x1000,%eax
  800ee9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eee:	75 d2                	jne    800ec2 <fd_alloc+0x8>
  800ef0:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800ef5:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800efa:	eb 05                	jmp    800f01 <fd_alloc+0x47>
			return 0;
  800efc:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	89 02                	mov    %eax,(%edx)
}
  800f06:	89 c8                	mov    %ecx,%eax
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f10:	83 f8 1f             	cmp    $0x1f,%eax
  800f13:	77 30                	ja     800f45 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f15:	c1 e0 0c             	shl    $0xc,%eax
  800f18:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f1d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f23:	f6 c2 01             	test   $0x1,%dl
  800f26:	74 24                	je     800f4c <fd_lookup+0x42>
  800f28:	89 c2                	mov    %eax,%edx
  800f2a:	c1 ea 0c             	shr    $0xc,%edx
  800f2d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f34:	f6 c2 01             	test   $0x1,%dl
  800f37:	74 1a                	je     800f53 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3c:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
		return -E_INVAL;
  800f45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4a:	eb f7                	jmp    800f43 <fd_lookup+0x39>
		return -E_INVAL;
  800f4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f51:	eb f0                	jmp    800f43 <fd_lookup+0x39>
  800f53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f58:	eb e9                	jmp    800f43 <fd_lookup+0x39>

00800f5a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	53                   	push   %ebx
  800f5e:	83 ec 04             	sub    $0x4,%esp
  800f61:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
  800f69:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f6e:	39 13                	cmp    %edx,(%ebx)
  800f70:	74 37                	je     800fa9 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f72:	83 c0 01             	add    $0x1,%eax
  800f75:	8b 1c 85 68 28 80 00 	mov    0x802868(,%eax,4),%ebx
  800f7c:	85 db                	test   %ebx,%ebx
  800f7e:	75 ee                	jne    800f6e <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f80:	a1 00 60 80 00       	mov    0x806000,%eax
  800f85:	8b 40 58             	mov    0x58(%eax),%eax
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	52                   	push   %edx
  800f8c:	50                   	push   %eax
  800f8d:	68 ec 27 80 00       	push   $0x8027ec
  800f92:	e8 d4 f2 ff ff       	call   80026b <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa2:	89 1a                	mov    %ebx,(%edx)
}
  800fa4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    
			return 0;
  800fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fae:	eb ef                	jmp    800f9f <dev_lookup+0x45>

00800fb0 <fd_close>:
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 24             	sub    $0x24,%esp
  800fb9:	8b 75 08             	mov    0x8(%ebp),%esi
  800fbc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fbf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc2:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fc3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc9:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fcc:	50                   	push   %eax
  800fcd:	e8 38 ff ff ff       	call   800f0a <fd_lookup>
  800fd2:	89 c3                	mov    %eax,%ebx
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 05                	js     800fe0 <fd_close+0x30>
	    || fd != fd2)
  800fdb:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fde:	74 16                	je     800ff6 <fd_close+0x46>
		return (must_exist ? r : 0);
  800fe0:	89 f8                	mov    %edi,%eax
  800fe2:	84 c0                	test   %al,%al
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe9:	0f 44 d8             	cmove  %eax,%ebx
}
  800fec:	89 d8                	mov    %ebx,%eax
  800fee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ff6:	83 ec 08             	sub    $0x8,%esp
  800ff9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ffc:	50                   	push   %eax
  800ffd:	ff 36                	push   (%esi)
  800fff:	e8 56 ff ff ff       	call   800f5a <dev_lookup>
  801004:	89 c3                	mov    %eax,%ebx
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 1a                	js     801027 <fd_close+0x77>
		if (dev->dev_close)
  80100d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801010:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801013:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801018:	85 c0                	test   %eax,%eax
  80101a:	74 0b                	je     801027 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	56                   	push   %esi
  801020:	ff d0                	call   *%eax
  801022:	89 c3                	mov    %eax,%ebx
  801024:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801027:	83 ec 08             	sub    $0x8,%esp
  80102a:	56                   	push   %esi
  80102b:	6a 00                	push   $0x0
  80102d:	e8 94 fc ff ff       	call   800cc6 <sys_page_unmap>
	return r;
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	eb b5                	jmp    800fec <fd_close+0x3c>

00801037 <close>:

int
close(int fdnum)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80103d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801040:	50                   	push   %eax
  801041:	ff 75 08             	push   0x8(%ebp)
  801044:	e8 c1 fe ff ff       	call   800f0a <fd_lookup>
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	85 c0                	test   %eax,%eax
  80104e:	79 02                	jns    801052 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801050:	c9                   	leave  
  801051:	c3                   	ret    
		return fd_close(fd, 1);
  801052:	83 ec 08             	sub    $0x8,%esp
  801055:	6a 01                	push   $0x1
  801057:	ff 75 f4             	push   -0xc(%ebp)
  80105a:	e8 51 ff ff ff       	call   800fb0 <fd_close>
  80105f:	83 c4 10             	add    $0x10,%esp
  801062:	eb ec                	jmp    801050 <close+0x19>

00801064 <close_all>:

void
close_all(void)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	53                   	push   %ebx
  801068:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80106b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	53                   	push   %ebx
  801074:	e8 be ff ff ff       	call   801037 <close>
	for (i = 0; i < MAXFD; i++)
  801079:	83 c3 01             	add    $0x1,%ebx
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	83 fb 20             	cmp    $0x20,%ebx
  801082:	75 ec                	jne    801070 <close_all+0xc>
}
  801084:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801087:	c9                   	leave  
  801088:	c3                   	ret    

00801089 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	57                   	push   %edi
  80108d:	56                   	push   %esi
  80108e:	53                   	push   %ebx
  80108f:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801092:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801095:	50                   	push   %eax
  801096:	ff 75 08             	push   0x8(%ebp)
  801099:	e8 6c fe ff ff       	call   800f0a <fd_lookup>
  80109e:	89 c3                	mov    %eax,%ebx
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	78 7f                	js     801126 <dup+0x9d>
		return r;
	close(newfdnum);
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	ff 75 0c             	push   0xc(%ebp)
  8010ad:	e8 85 ff ff ff       	call   801037 <close>

	newfd = INDEX2FD(newfdnum);
  8010b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b5:	c1 e6 0c             	shl    $0xc,%esi
  8010b8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010c1:	89 3c 24             	mov    %edi,(%esp)
  8010c4:	e8 da fd ff ff       	call   800ea3 <fd2data>
  8010c9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010cb:	89 34 24             	mov    %esi,(%esp)
  8010ce:	e8 d0 fd ff ff       	call   800ea3 <fd2data>
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010d9:	89 d8                	mov    %ebx,%eax
  8010db:	c1 e8 16             	shr    $0x16,%eax
  8010de:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e5:	a8 01                	test   $0x1,%al
  8010e7:	74 11                	je     8010fa <dup+0x71>
  8010e9:	89 d8                	mov    %ebx,%eax
  8010eb:	c1 e8 0c             	shr    $0xc,%eax
  8010ee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f5:	f6 c2 01             	test   $0x1,%dl
  8010f8:	75 36                	jne    801130 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010fa:	89 f8                	mov    %edi,%eax
  8010fc:	c1 e8 0c             	shr    $0xc,%eax
  8010ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801106:	83 ec 0c             	sub    $0xc,%esp
  801109:	25 07 0e 00 00       	and    $0xe07,%eax
  80110e:	50                   	push   %eax
  80110f:	56                   	push   %esi
  801110:	6a 00                	push   $0x0
  801112:	57                   	push   %edi
  801113:	6a 00                	push   $0x0
  801115:	e8 6a fb ff ff       	call   800c84 <sys_page_map>
  80111a:	89 c3                	mov    %eax,%ebx
  80111c:	83 c4 20             	add    $0x20,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 33                	js     801156 <dup+0xcd>
		goto err;

	return newfdnum;
  801123:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801126:	89 d8                	mov    %ebx,%eax
  801128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112b:	5b                   	pop    %ebx
  80112c:	5e                   	pop    %esi
  80112d:	5f                   	pop    %edi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801130:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	25 07 0e 00 00       	and    $0xe07,%eax
  80113f:	50                   	push   %eax
  801140:	ff 75 d4             	push   -0x2c(%ebp)
  801143:	6a 00                	push   $0x0
  801145:	53                   	push   %ebx
  801146:	6a 00                	push   $0x0
  801148:	e8 37 fb ff ff       	call   800c84 <sys_page_map>
  80114d:	89 c3                	mov    %eax,%ebx
  80114f:	83 c4 20             	add    $0x20,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	79 a4                	jns    8010fa <dup+0x71>
	sys_page_unmap(0, newfd);
  801156:	83 ec 08             	sub    $0x8,%esp
  801159:	56                   	push   %esi
  80115a:	6a 00                	push   $0x0
  80115c:	e8 65 fb ff ff       	call   800cc6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801161:	83 c4 08             	add    $0x8,%esp
  801164:	ff 75 d4             	push   -0x2c(%ebp)
  801167:	6a 00                	push   $0x0
  801169:	e8 58 fb ff ff       	call   800cc6 <sys_page_unmap>
	return r;
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	eb b3                	jmp    801126 <dup+0x9d>

00801173 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 18             	sub    $0x18,%esp
  80117b:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	56                   	push   %esi
  801183:	e8 82 fd ff ff       	call   800f0a <fd_lookup>
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 3c                	js     8011cb <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118f:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801192:	83 ec 08             	sub    $0x8,%esp
  801195:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801198:	50                   	push   %eax
  801199:	ff 33                	push   (%ebx)
  80119b:	e8 ba fd ff ff       	call   800f5a <dev_lookup>
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 24                	js     8011cb <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011a7:	8b 43 08             	mov    0x8(%ebx),%eax
  8011aa:	83 e0 03             	and    $0x3,%eax
  8011ad:	83 f8 01             	cmp    $0x1,%eax
  8011b0:	74 20                	je     8011d2 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b5:	8b 40 08             	mov    0x8(%eax),%eax
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	74 37                	je     8011f3 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	ff 75 10             	push   0x10(%ebp)
  8011c2:	ff 75 0c             	push   0xc(%ebp)
  8011c5:	53                   	push   %ebx
  8011c6:	ff d0                	call   *%eax
  8011c8:	83 c4 10             	add    $0x10,%esp
}
  8011cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d2:	a1 00 60 80 00       	mov    0x806000,%eax
  8011d7:	8b 40 58             	mov    0x58(%eax),%eax
  8011da:	83 ec 04             	sub    $0x4,%esp
  8011dd:	56                   	push   %esi
  8011de:	50                   	push   %eax
  8011df:	68 2d 28 80 00       	push   $0x80282d
  8011e4:	e8 82 f0 ff ff       	call   80026b <cprintf>
		return -E_INVAL;
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f1:	eb d8                	jmp    8011cb <read+0x58>
		return -E_NOT_SUPP;
  8011f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011f8:	eb d1                	jmp    8011cb <read+0x58>

008011fa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	57                   	push   %edi
  8011fe:	56                   	push   %esi
  8011ff:	53                   	push   %ebx
  801200:	83 ec 0c             	sub    $0xc,%esp
  801203:	8b 7d 08             	mov    0x8(%ebp),%edi
  801206:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801209:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120e:	eb 02                	jmp    801212 <readn+0x18>
  801210:	01 c3                	add    %eax,%ebx
  801212:	39 f3                	cmp    %esi,%ebx
  801214:	73 21                	jae    801237 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801216:	83 ec 04             	sub    $0x4,%esp
  801219:	89 f0                	mov    %esi,%eax
  80121b:	29 d8                	sub    %ebx,%eax
  80121d:	50                   	push   %eax
  80121e:	89 d8                	mov    %ebx,%eax
  801220:	03 45 0c             	add    0xc(%ebp),%eax
  801223:	50                   	push   %eax
  801224:	57                   	push   %edi
  801225:	e8 49 ff ff ff       	call   801173 <read>
		if (m < 0)
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 04                	js     801235 <readn+0x3b>
			return m;
		if (m == 0)
  801231:	75 dd                	jne    801210 <readn+0x16>
  801233:	eb 02                	jmp    801237 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801235:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801237:	89 d8                	mov    %ebx,%eax
  801239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5f                   	pop    %edi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	56                   	push   %esi
  801245:	53                   	push   %ebx
  801246:	83 ec 18             	sub    $0x18,%esp
  801249:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	53                   	push   %ebx
  801251:	e8 b4 fc ff ff       	call   800f0a <fd_lookup>
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 37                	js     801294 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	ff 36                	push   (%esi)
  801269:	e8 ec fc ff ff       	call   800f5a <dev_lookup>
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	85 c0                	test   %eax,%eax
  801273:	78 1f                	js     801294 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801275:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801279:	74 20                	je     80129b <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80127b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127e:	8b 40 0c             	mov    0xc(%eax),%eax
  801281:	85 c0                	test   %eax,%eax
  801283:	74 37                	je     8012bc <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	ff 75 10             	push   0x10(%ebp)
  80128b:	ff 75 0c             	push   0xc(%ebp)
  80128e:	56                   	push   %esi
  80128f:	ff d0                	call   *%eax
  801291:	83 c4 10             	add    $0x10,%esp
}
  801294:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801297:	5b                   	pop    %ebx
  801298:	5e                   	pop    %esi
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80129b:	a1 00 60 80 00       	mov    0x806000,%eax
  8012a0:	8b 40 58             	mov    0x58(%eax),%eax
  8012a3:	83 ec 04             	sub    $0x4,%esp
  8012a6:	53                   	push   %ebx
  8012a7:	50                   	push   %eax
  8012a8:	68 49 28 80 00       	push   $0x802849
  8012ad:	e8 b9 ef ff ff       	call   80026b <cprintf>
		return -E_INVAL;
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ba:	eb d8                	jmp    801294 <write+0x53>
		return -E_NOT_SUPP;
  8012bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c1:	eb d1                	jmp    801294 <write+0x53>

008012c3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	ff 75 08             	push   0x8(%ebp)
  8012d0:	e8 35 fc ff ff       	call   800f0a <fd_lookup>
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 0e                	js     8012ea <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ea:	c9                   	leave  
  8012eb:	c3                   	ret    

008012ec <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	56                   	push   %esi
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 18             	sub    $0x18,%esp
  8012f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fa:	50                   	push   %eax
  8012fb:	53                   	push   %ebx
  8012fc:	e8 09 fc ff ff       	call   800f0a <fd_lookup>
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 34                	js     80133c <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801308:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	ff 36                	push   (%esi)
  801314:	e8 41 fc ff ff       	call   800f5a <dev_lookup>
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 1c                	js     80133c <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801320:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801324:	74 1d                	je     801343 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801326:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801329:	8b 40 18             	mov    0x18(%eax),%eax
  80132c:	85 c0                	test   %eax,%eax
  80132e:	74 34                	je     801364 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	ff 75 0c             	push   0xc(%ebp)
  801336:	56                   	push   %esi
  801337:	ff d0                	call   *%eax
  801339:	83 c4 10             	add    $0x10,%esp
}
  80133c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133f:	5b                   	pop    %ebx
  801340:	5e                   	pop    %esi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    
			thisenv->env_id, fdnum);
  801343:	a1 00 60 80 00       	mov    0x806000,%eax
  801348:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80134b:	83 ec 04             	sub    $0x4,%esp
  80134e:	53                   	push   %ebx
  80134f:	50                   	push   %eax
  801350:	68 0c 28 80 00       	push   $0x80280c
  801355:	e8 11 ef ff ff       	call   80026b <cprintf>
		return -E_INVAL;
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801362:	eb d8                	jmp    80133c <ftruncate+0x50>
		return -E_NOT_SUPP;
  801364:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801369:	eb d1                	jmp    80133c <ftruncate+0x50>

0080136b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
  801370:	83 ec 18             	sub    $0x18,%esp
  801373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801376:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	ff 75 08             	push   0x8(%ebp)
  80137d:	e8 88 fb ff ff       	call   800f0a <fd_lookup>
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	78 49                	js     8013d2 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801389:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801392:	50                   	push   %eax
  801393:	ff 36                	push   (%esi)
  801395:	e8 c0 fb ff ff       	call   800f5a <dev_lookup>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 31                	js     8013d2 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013a8:	74 2f                	je     8013d9 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013b4:	00 00 00 
	stat->st_isdir = 0;
  8013b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013be:	00 00 00 
	stat->st_dev = dev;
  8013c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	53                   	push   %ebx
  8013cb:	56                   	push   %esi
  8013cc:	ff 50 14             	call   *0x14(%eax)
  8013cf:	83 c4 10             	add    $0x10,%esp
}
  8013d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    
		return -E_NOT_SUPP;
  8013d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013de:	eb f2                	jmp    8013d2 <fstat+0x67>

008013e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	56                   	push   %esi
  8013e4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	6a 00                	push   $0x0
  8013ea:	ff 75 08             	push   0x8(%ebp)
  8013ed:	e8 e4 01 00 00       	call   8015d6 <open>
  8013f2:	89 c3                	mov    %eax,%ebx
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 1b                	js     801416 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	ff 75 0c             	push   0xc(%ebp)
  801401:	50                   	push   %eax
  801402:	e8 64 ff ff ff       	call   80136b <fstat>
  801407:	89 c6                	mov    %eax,%esi
	close(fd);
  801409:	89 1c 24             	mov    %ebx,(%esp)
  80140c:	e8 26 fc ff ff       	call   801037 <close>
	return r;
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	89 f3                	mov    %esi,%ebx
}
  801416:	89 d8                	mov    %ebx,%eax
  801418:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5e                   	pop    %esi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    

0080141f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	56                   	push   %esi
  801423:	53                   	push   %ebx
  801424:	89 c6                	mov    %eax,%esi
  801426:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801428:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80142f:	74 27                	je     801458 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801431:	6a 07                	push   $0x7
  801433:	68 00 70 80 00       	push   $0x807000
  801438:	56                   	push   %esi
  801439:	ff 35 00 80 80 00    	push   0x808000
  80143f:	e8 e0 0c 00 00       	call   802124 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801444:	83 c4 0c             	add    $0xc,%esp
  801447:	6a 00                	push   $0x0
  801449:	53                   	push   %ebx
  80144a:	6a 00                	push   $0x0
  80144c:	e8 63 0c 00 00       	call   8020b4 <ipc_recv>
}
  801451:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801458:	83 ec 0c             	sub    $0xc,%esp
  80145b:	6a 01                	push   $0x1
  80145d:	e8 16 0d 00 00       	call   802178 <ipc_find_env>
  801462:	a3 00 80 80 00       	mov    %eax,0x808000
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	eb c5                	jmp    801431 <fsipc+0x12>

0080146c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801472:	8b 45 08             	mov    0x8(%ebp),%eax
  801475:	8b 40 0c             	mov    0xc(%eax),%eax
  801478:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80147d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801480:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801485:	ba 00 00 00 00       	mov    $0x0,%edx
  80148a:	b8 02 00 00 00       	mov    $0x2,%eax
  80148f:	e8 8b ff ff ff       	call   80141f <fsipc>
}
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <devfile_flush>:
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80149c:	8b 45 08             	mov    0x8(%ebp),%eax
  80149f:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a2:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8014a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8014b1:	e8 69 ff ff ff       	call   80141f <fsipc>
}
  8014b6:	c9                   	leave  
  8014b7:	c3                   	ret    

008014b8 <devfile_stat>:
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 04             	sub    $0x4,%esp
  8014bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c8:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8014d7:	e8 43 ff ff ff       	call   80141f <fsipc>
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 2c                	js     80150c <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	68 00 70 80 00       	push   $0x807000
  8014e8:	53                   	push   %ebx
  8014e9:	e8 57 f3 ff ff       	call   800845 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ee:	a1 80 70 80 00       	mov    0x807080,%eax
  8014f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014f9:	a1 84 70 80 00       	mov    0x807084,%eax
  8014fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <devfile_write>:
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	83 ec 0c             	sub    $0xc,%esp
  801517:	8b 45 10             	mov    0x10(%ebp),%eax
  80151a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80151f:	39 d0                	cmp    %edx,%eax
  801521:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801524:	8b 55 08             	mov    0x8(%ebp),%edx
  801527:	8b 52 0c             	mov    0xc(%edx),%edx
  80152a:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  801530:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801535:	50                   	push   %eax
  801536:	ff 75 0c             	push   0xc(%ebp)
  801539:	68 08 70 80 00       	push   $0x807008
  80153e:	e8 98 f4 ff ff       	call   8009db <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801543:	ba 00 00 00 00       	mov    $0x0,%edx
  801548:	b8 04 00 00 00       	mov    $0x4,%eax
  80154d:	e8 cd fe ff ff       	call   80141f <fsipc>
}
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <devfile_read>:
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	56                   	push   %esi
  801558:	53                   	push   %ebx
  801559:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80155c:	8b 45 08             	mov    0x8(%ebp),%eax
  80155f:	8b 40 0c             	mov    0xc(%eax),%eax
  801562:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801567:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80156d:	ba 00 00 00 00       	mov    $0x0,%edx
  801572:	b8 03 00 00 00       	mov    $0x3,%eax
  801577:	e8 a3 fe ff ff       	call   80141f <fsipc>
  80157c:	89 c3                	mov    %eax,%ebx
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 1f                	js     8015a1 <devfile_read+0x4d>
	assert(r <= n);
  801582:	39 f0                	cmp    %esi,%eax
  801584:	77 24                	ja     8015aa <devfile_read+0x56>
	assert(r <= PGSIZE);
  801586:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80158b:	7f 33                	jg     8015c0 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80158d:	83 ec 04             	sub    $0x4,%esp
  801590:	50                   	push   %eax
  801591:	68 00 70 80 00       	push   $0x807000
  801596:	ff 75 0c             	push   0xc(%ebp)
  801599:	e8 3d f4 ff ff       	call   8009db <memmove>
	return r;
  80159e:	83 c4 10             	add    $0x10,%esp
}
  8015a1:	89 d8                	mov    %ebx,%eax
  8015a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a6:	5b                   	pop    %ebx
  8015a7:	5e                   	pop    %esi
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    
	assert(r <= n);
  8015aa:	68 7c 28 80 00       	push   $0x80287c
  8015af:	68 83 28 80 00       	push   $0x802883
  8015b4:	6a 7c                	push   $0x7c
  8015b6:	68 98 28 80 00       	push   $0x802898
  8015bb:	e8 d0 eb ff ff       	call   800190 <_panic>
	assert(r <= PGSIZE);
  8015c0:	68 a3 28 80 00       	push   $0x8028a3
  8015c5:	68 83 28 80 00       	push   $0x802883
  8015ca:	6a 7d                	push   $0x7d
  8015cc:	68 98 28 80 00       	push   $0x802898
  8015d1:	e8 ba eb ff ff       	call   800190 <_panic>

008015d6 <open>:
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	56                   	push   %esi
  8015da:	53                   	push   %ebx
  8015db:	83 ec 1c             	sub    $0x1c,%esp
  8015de:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015e1:	56                   	push   %esi
  8015e2:	e8 23 f2 ff ff       	call   80080a <strlen>
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ef:	7f 6c                	jg     80165d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015f1:	83 ec 0c             	sub    $0xc,%esp
  8015f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f7:	50                   	push   %eax
  8015f8:	e8 bd f8 ff ff       	call   800eba <fd_alloc>
  8015fd:	89 c3                	mov    %eax,%ebx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 3c                	js     801642 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	56                   	push   %esi
  80160a:	68 00 70 80 00       	push   $0x807000
  80160f:	e8 31 f2 ff ff       	call   800845 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801614:	8b 45 0c             	mov    0xc(%ebp),%eax
  801617:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80161c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161f:	b8 01 00 00 00       	mov    $0x1,%eax
  801624:	e8 f6 fd ff ff       	call   80141f <fsipc>
  801629:	89 c3                	mov    %eax,%ebx
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 19                	js     80164b <open+0x75>
	return fd2num(fd);
  801632:	83 ec 0c             	sub    $0xc,%esp
  801635:	ff 75 f4             	push   -0xc(%ebp)
  801638:	e8 56 f8 ff ff       	call   800e93 <fd2num>
  80163d:	89 c3                	mov    %eax,%ebx
  80163f:	83 c4 10             	add    $0x10,%esp
}
  801642:	89 d8                	mov    %ebx,%eax
  801644:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    
		fd_close(fd, 0);
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	6a 00                	push   $0x0
  801650:	ff 75 f4             	push   -0xc(%ebp)
  801653:	e8 58 f9 ff ff       	call   800fb0 <fd_close>
		return r;
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	eb e5                	jmp    801642 <open+0x6c>
		return -E_BAD_PATH;
  80165d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801662:	eb de                	jmp    801642 <open+0x6c>

00801664 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80166a:	ba 00 00 00 00       	mov    $0x0,%edx
  80166f:	b8 08 00 00 00       	mov    $0x8,%eax
  801674:	e8 a6 fd ff ff       	call   80141f <fsipc>
}
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80167b:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80167f:	7f 01                	jg     801682 <writebuf+0x7>
  801681:	c3                   	ret    
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  80168b:	ff 70 04             	push   0x4(%eax)
  80168e:	8d 40 10             	lea    0x10(%eax),%eax
  801691:	50                   	push   %eax
  801692:	ff 33                	push   (%ebx)
  801694:	e8 a8 fb ff ff       	call   801241 <write>
		if (result > 0)
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	7e 03                	jle    8016a3 <writebuf+0x28>
			b->result += result;
  8016a0:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016a3:	39 43 04             	cmp    %eax,0x4(%ebx)
  8016a6:	74 0d                	je     8016b5 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8016af:	0f 4f c2             	cmovg  %edx,%eax
  8016b2:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <putch>:

static void
putch(int ch, void *thunk)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 04             	sub    $0x4,%esp
  8016c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016c4:	8b 53 04             	mov    0x4(%ebx),%edx
  8016c7:	8d 42 01             	lea    0x1(%edx),%eax
  8016ca:	89 43 04             	mov    %eax,0x4(%ebx)
  8016cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d0:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016d4:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016d9:	74 05                	je     8016e0 <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  8016db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    
		writebuf(b);
  8016e0:	89 d8                	mov    %ebx,%eax
  8016e2:	e8 94 ff ff ff       	call   80167b <writebuf>
		b->idx = 0;
  8016e7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8016ee:	eb eb                	jmp    8016db <putch+0x21>

008016f0 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fc:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801702:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801709:	00 00 00 
	b.result = 0;
  80170c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801713:	00 00 00 
	b.error = 1;
  801716:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80171d:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801720:	ff 75 10             	push   0x10(%ebp)
  801723:	ff 75 0c             	push   0xc(%ebp)
  801726:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80172c:	50                   	push   %eax
  80172d:	68 ba 16 80 00       	push   $0x8016ba
  801732:	e8 2b ec ff ff       	call   800362 <vprintfmt>
	if (b.idx > 0)
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801741:	7f 11                	jg     801754 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801743:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801749:	85 c0                	test   %eax,%eax
  80174b:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801752:	c9                   	leave  
  801753:	c3                   	ret    
		writebuf(&b);
  801754:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80175a:	e8 1c ff ff ff       	call   80167b <writebuf>
  80175f:	eb e2                	jmp    801743 <vfprintf+0x53>

00801761 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801767:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80176a:	50                   	push   %eax
  80176b:	ff 75 0c             	push   0xc(%ebp)
  80176e:	ff 75 08             	push   0x8(%ebp)
  801771:	e8 7a ff ff ff       	call   8016f0 <vfprintf>
	va_end(ap);

	return cnt;
}
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <printf>:

int
printf(const char *fmt, ...)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80177e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801781:	50                   	push   %eax
  801782:	ff 75 08             	push   0x8(%ebp)
  801785:	6a 01                	push   $0x1
  801787:	e8 64 ff ff ff       	call   8016f0 <vfprintf>
	va_end(ap);

	return cnt;
}
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801794:	68 af 28 80 00       	push   $0x8028af
  801799:	ff 75 0c             	push   0xc(%ebp)
  80179c:	e8 a4 f0 ff ff       	call   800845 <strcpy>
	return 0;
}
  8017a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <devsock_close>:
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	53                   	push   %ebx
  8017ac:	83 ec 10             	sub    $0x10,%esp
  8017af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8017b2:	53                   	push   %ebx
  8017b3:	e8 ff 09 00 00       	call   8021b7 <pageref>
  8017b8:	89 c2                	mov    %eax,%edx
  8017ba:	83 c4 10             	add    $0x10,%esp
		return 0;
  8017bd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8017c2:	83 fa 01             	cmp    $0x1,%edx
  8017c5:	74 05                	je     8017cc <devsock_close+0x24>
}
  8017c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8017cc:	83 ec 0c             	sub    $0xc,%esp
  8017cf:	ff 73 0c             	push   0xc(%ebx)
  8017d2:	e8 b7 02 00 00       	call   801a8e <nsipc_close>
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	eb eb                	jmp    8017c7 <devsock_close+0x1f>

008017dc <devsock_write>:
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017e2:	6a 00                	push   $0x0
  8017e4:	ff 75 10             	push   0x10(%ebp)
  8017e7:	ff 75 0c             	push   0xc(%ebp)
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	ff 70 0c             	push   0xc(%eax)
  8017f0:	e8 79 03 00 00       	call   801b6e <nsipc_send>
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devsock_read>:
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8017fd:	6a 00                	push   $0x0
  8017ff:	ff 75 10             	push   0x10(%ebp)
  801802:	ff 75 0c             	push   0xc(%ebp)
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	ff 70 0c             	push   0xc(%eax)
  80180b:	e8 ef 02 00 00       	call   801aff <nsipc_recv>
}
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <fd2sockid>:
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801818:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80181b:	52                   	push   %edx
  80181c:	50                   	push   %eax
  80181d:	e8 e8 f6 ff ff       	call   800f0a <fd_lookup>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	78 10                	js     801839 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801832:	39 08                	cmp    %ecx,(%eax)
  801834:	75 05                	jne    80183b <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801836:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801839:	c9                   	leave  
  80183a:	c3                   	ret    
		return -E_NOT_SUPP;
  80183b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801840:	eb f7                	jmp    801839 <fd2sockid+0x27>

00801842 <alloc_sockfd>:
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	56                   	push   %esi
  801846:	53                   	push   %ebx
  801847:	83 ec 1c             	sub    $0x1c,%esp
  80184a:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80184c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184f:	50                   	push   %eax
  801850:	e8 65 f6 ff ff       	call   800eba <fd_alloc>
  801855:	89 c3                	mov    %eax,%ebx
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 43                	js     8018a1 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80185e:	83 ec 04             	sub    $0x4,%esp
  801861:	68 07 04 00 00       	push   $0x407
  801866:	ff 75 f4             	push   -0xc(%ebp)
  801869:	6a 00                	push   $0x0
  80186b:	e8 d1 f3 ff ff       	call   800c41 <sys_page_alloc>
  801870:	89 c3                	mov    %eax,%ebx
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	85 c0                	test   %eax,%eax
  801877:	78 28                	js     8018a1 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801879:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801882:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801884:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801887:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80188e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	50                   	push   %eax
  801895:	e8 f9 f5 ff ff       	call   800e93 <fd2num>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	eb 0c                	jmp    8018ad <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8018a1:	83 ec 0c             	sub    $0xc,%esp
  8018a4:	56                   	push   %esi
  8018a5:	e8 e4 01 00 00       	call   801a8e <nsipc_close>
		return r;
  8018aa:	83 c4 10             	add    $0x10,%esp
}
  8018ad:	89 d8                	mov    %ebx,%eax
  8018af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b2:	5b                   	pop    %ebx
  8018b3:	5e                   	pop    %esi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <accept>:
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bf:	e8 4e ff ff ff       	call   801812 <fd2sockid>
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 1b                	js     8018e3 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018c8:	83 ec 04             	sub    $0x4,%esp
  8018cb:	ff 75 10             	push   0x10(%ebp)
  8018ce:	ff 75 0c             	push   0xc(%ebp)
  8018d1:	50                   	push   %eax
  8018d2:	e8 0e 01 00 00       	call   8019e5 <nsipc_accept>
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 05                	js     8018e3 <accept+0x2d>
	return alloc_sockfd(r);
  8018de:	e8 5f ff ff ff       	call   801842 <alloc_sockfd>
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <bind>:
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	e8 1f ff ff ff       	call   801812 <fd2sockid>
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 12                	js     801909 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8018f7:	83 ec 04             	sub    $0x4,%esp
  8018fa:	ff 75 10             	push   0x10(%ebp)
  8018fd:	ff 75 0c             	push   0xc(%ebp)
  801900:	50                   	push   %eax
  801901:	e8 31 01 00 00       	call   801a37 <nsipc_bind>
  801906:	83 c4 10             	add    $0x10,%esp
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <shutdown>:
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	e8 f9 fe ff ff       	call   801812 <fd2sockid>
  801919:	85 c0                	test   %eax,%eax
  80191b:	78 0f                	js     80192c <shutdown+0x21>
	return nsipc_shutdown(r, how);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	ff 75 0c             	push   0xc(%ebp)
  801923:	50                   	push   %eax
  801924:	e8 43 01 00 00       	call   801a6c <nsipc_shutdown>
  801929:	83 c4 10             	add    $0x10,%esp
}
  80192c:	c9                   	leave  
  80192d:	c3                   	ret    

0080192e <connect>:
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
  801937:	e8 d6 fe ff ff       	call   801812 <fd2sockid>
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 12                	js     801952 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801940:	83 ec 04             	sub    $0x4,%esp
  801943:	ff 75 10             	push   0x10(%ebp)
  801946:	ff 75 0c             	push   0xc(%ebp)
  801949:	50                   	push   %eax
  80194a:	e8 59 01 00 00       	call   801aa8 <nsipc_connect>
  80194f:	83 c4 10             	add    $0x10,%esp
}
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <listen>:
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
  80195d:	e8 b0 fe ff ff       	call   801812 <fd2sockid>
  801962:	85 c0                	test   %eax,%eax
  801964:	78 0f                	js     801975 <listen+0x21>
	return nsipc_listen(r, backlog);
  801966:	83 ec 08             	sub    $0x8,%esp
  801969:	ff 75 0c             	push   0xc(%ebp)
  80196c:	50                   	push   %eax
  80196d:	e8 6b 01 00 00       	call   801add <nsipc_listen>
  801972:	83 c4 10             	add    $0x10,%esp
}
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <socket>:

int
socket(int domain, int type, int protocol)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80197d:	ff 75 10             	push   0x10(%ebp)
  801980:	ff 75 0c             	push   0xc(%ebp)
  801983:	ff 75 08             	push   0x8(%ebp)
  801986:	e8 41 02 00 00       	call   801bcc <nsipc_socket>
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	85 c0                	test   %eax,%eax
  801990:	78 05                	js     801997 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801992:	e8 ab fe ff ff       	call   801842 <alloc_sockfd>
}
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	53                   	push   %ebx
  80199d:	83 ec 04             	sub    $0x4,%esp
  8019a0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019a2:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  8019a9:	74 26                	je     8019d1 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019ab:	6a 07                	push   $0x7
  8019ad:	68 00 90 80 00       	push   $0x809000
  8019b2:	53                   	push   %ebx
  8019b3:	ff 35 00 a0 80 00    	push   0x80a000
  8019b9:	e8 66 07 00 00       	call   802124 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019be:	83 c4 0c             	add    $0xc,%esp
  8019c1:	6a 00                	push   $0x0
  8019c3:	6a 00                	push   $0x0
  8019c5:	6a 00                	push   $0x0
  8019c7:	e8 e8 06 00 00       	call   8020b4 <ipc_recv>
}
  8019cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019d1:	83 ec 0c             	sub    $0xc,%esp
  8019d4:	6a 02                	push   $0x2
  8019d6:	e8 9d 07 00 00       	call   802178 <ipc_find_env>
  8019db:	a3 00 a0 80 00       	mov    %eax,0x80a000
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	eb c6                	jmp    8019ab <nsipc+0x12>

008019e5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
  8019ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8019ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f0:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8019f5:	8b 06                	mov    (%esi),%eax
  8019f7:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8019fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801a01:	e8 93 ff ff ff       	call   801999 <nsipc>
  801a06:	89 c3                	mov    %eax,%ebx
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	79 09                	jns    801a15 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801a0c:	89 d8                	mov    %ebx,%eax
  801a0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a11:	5b                   	pop    %ebx
  801a12:	5e                   	pop    %esi
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a15:	83 ec 04             	sub    $0x4,%esp
  801a18:	ff 35 10 90 80 00    	push   0x809010
  801a1e:	68 00 90 80 00       	push   $0x809000
  801a23:	ff 75 0c             	push   0xc(%ebp)
  801a26:	e8 b0 ef ff ff       	call   8009db <memmove>
		*addrlen = ret->ret_addrlen;
  801a2b:	a1 10 90 80 00       	mov    0x809010,%eax
  801a30:	89 06                	mov    %eax,(%esi)
  801a32:	83 c4 10             	add    $0x10,%esp
	return r;
  801a35:	eb d5                	jmp    801a0c <nsipc_accept+0x27>

00801a37 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	53                   	push   %ebx
  801a3b:	83 ec 08             	sub    $0x8,%esp
  801a3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a41:	8b 45 08             	mov    0x8(%ebp),%eax
  801a44:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a49:	53                   	push   %ebx
  801a4a:	ff 75 0c             	push   0xc(%ebp)
  801a4d:	68 04 90 80 00       	push   $0x809004
  801a52:	e8 84 ef ff ff       	call   8009db <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a57:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  801a5d:	b8 02 00 00 00       	mov    $0x2,%eax
  801a62:	e8 32 ff ff ff       	call   801999 <nsipc>
}
  801a67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a72:	8b 45 08             	mov    0x8(%ebp),%eax
  801a75:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  801a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7d:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  801a82:	b8 03 00 00 00       	mov    $0x3,%eax
  801a87:	e8 0d ff ff ff       	call   801999 <nsipc>
}
  801a8c:	c9                   	leave  
  801a8d:	c3                   	ret    

00801a8e <nsipc_close>:

int
nsipc_close(int s)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  801a9c:	b8 04 00 00 00       	mov    $0x4,%eax
  801aa1:	e8 f3 fe ff ff       	call   801999 <nsipc>
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	53                   	push   %ebx
  801aac:	83 ec 08             	sub    $0x8,%esp
  801aaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab5:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801aba:	53                   	push   %ebx
  801abb:	ff 75 0c             	push   0xc(%ebp)
  801abe:	68 04 90 80 00       	push   $0x809004
  801ac3:	e8 13 ef ff ff       	call   8009db <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ac8:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  801ace:	b8 05 00 00 00       	mov    $0x5,%eax
  801ad3:	e8 c1 fe ff ff       	call   801999 <nsipc>
}
  801ad8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae6:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  801aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aee:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  801af3:	b8 06 00 00 00       	mov    $0x6,%eax
  801af8:	e8 9c fe ff ff       	call   801999 <nsipc>
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b07:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0a:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  801b0f:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  801b15:	8b 45 14             	mov    0x14(%ebp),%eax
  801b18:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b1d:	b8 07 00 00 00       	mov    $0x7,%eax
  801b22:	e8 72 fe ff ff       	call   801999 <nsipc>
  801b27:	89 c3                	mov    %eax,%ebx
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 22                	js     801b4f <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801b2d:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801b32:	39 c6                	cmp    %eax,%esi
  801b34:	0f 4e c6             	cmovle %esi,%eax
  801b37:	39 c3                	cmp    %eax,%ebx
  801b39:	7f 1d                	jg     801b58 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b3b:	83 ec 04             	sub    $0x4,%esp
  801b3e:	53                   	push   %ebx
  801b3f:	68 00 90 80 00       	push   $0x809000
  801b44:	ff 75 0c             	push   0xc(%ebp)
  801b47:	e8 8f ee ff ff       	call   8009db <memmove>
  801b4c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b4f:	89 d8                	mov    %ebx,%eax
  801b51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801b58:	68 bb 28 80 00       	push   $0x8028bb
  801b5d:	68 83 28 80 00       	push   $0x802883
  801b62:	6a 62                	push   $0x62
  801b64:	68 d0 28 80 00       	push   $0x8028d0
  801b69:	e8 22 e6 ff ff       	call   800190 <_panic>

00801b6e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	83 ec 04             	sub    $0x4,%esp
  801b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  801b80:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b86:	7f 2e                	jg     801bb6 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b88:	83 ec 04             	sub    $0x4,%esp
  801b8b:	53                   	push   %ebx
  801b8c:	ff 75 0c             	push   0xc(%ebp)
  801b8f:	68 0c 90 80 00       	push   $0x80900c
  801b94:	e8 42 ee ff ff       	call   8009db <memmove>
	nsipcbuf.send.req_size = size;
  801b99:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  801b9f:	8b 45 14             	mov    0x14(%ebp),%eax
  801ba2:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  801ba7:	b8 08 00 00 00       	mov    $0x8,%eax
  801bac:	e8 e8 fd ff ff       	call   801999 <nsipc>
}
  801bb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    
	assert(size < 1600);
  801bb6:	68 dc 28 80 00       	push   $0x8028dc
  801bbb:	68 83 28 80 00       	push   $0x802883
  801bc0:	6a 6d                	push   $0x6d
  801bc2:	68 d0 28 80 00       	push   $0x8028d0
  801bc7:	e8 c4 e5 ff ff       	call   800190 <_panic>

00801bcc <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd5:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  801bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bdd:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  801be2:	8b 45 10             	mov    0x10(%ebp),%eax
  801be5:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  801bea:	b8 09 00 00 00       	mov    $0x9,%eax
  801bef:	e8 a5 fd ff ff       	call   801999 <nsipc>
}
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	56                   	push   %esi
  801bfa:	53                   	push   %ebx
  801bfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bfe:	83 ec 0c             	sub    $0xc,%esp
  801c01:	ff 75 08             	push   0x8(%ebp)
  801c04:	e8 9a f2 ff ff       	call   800ea3 <fd2data>
  801c09:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c0b:	83 c4 08             	add    $0x8,%esp
  801c0e:	68 e8 28 80 00       	push   $0x8028e8
  801c13:	53                   	push   %ebx
  801c14:	e8 2c ec ff ff       	call   800845 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c19:	8b 46 04             	mov    0x4(%esi),%eax
  801c1c:	2b 06                	sub    (%esi),%eax
  801c1e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c24:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c2b:	00 00 00 
	stat->st_dev = &devpipe;
  801c2e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801c35:	30 80 00 
	return 0;
}
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c40:	5b                   	pop    %ebx
  801c41:	5e                   	pop    %esi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	53                   	push   %ebx
  801c48:	83 ec 0c             	sub    $0xc,%esp
  801c4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c4e:	53                   	push   %ebx
  801c4f:	6a 00                	push   $0x0
  801c51:	e8 70 f0 ff ff       	call   800cc6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c56:	89 1c 24             	mov    %ebx,(%esp)
  801c59:	e8 45 f2 ff ff       	call   800ea3 <fd2data>
  801c5e:	83 c4 08             	add    $0x8,%esp
  801c61:	50                   	push   %eax
  801c62:	6a 00                	push   $0x0
  801c64:	e8 5d f0 ff ff       	call   800cc6 <sys_page_unmap>
}
  801c69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    

00801c6e <_pipeisclosed>:
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 1c             	sub    $0x1c,%esp
  801c77:	89 c7                	mov    %eax,%edi
  801c79:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c7b:	a1 00 60 80 00       	mov    0x806000,%eax
  801c80:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c83:	83 ec 0c             	sub    $0xc,%esp
  801c86:	57                   	push   %edi
  801c87:	e8 2b 05 00 00       	call   8021b7 <pageref>
  801c8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c8f:	89 34 24             	mov    %esi,(%esp)
  801c92:	e8 20 05 00 00       	call   8021b7 <pageref>
		nn = thisenv->env_runs;
  801c97:	8b 15 00 60 80 00    	mov    0x806000,%edx
  801c9d:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	39 cb                	cmp    %ecx,%ebx
  801ca5:	74 1b                	je     801cc2 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ca7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801caa:	75 cf                	jne    801c7b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cac:	8b 42 68             	mov    0x68(%edx),%eax
  801caf:	6a 01                	push   $0x1
  801cb1:	50                   	push   %eax
  801cb2:	53                   	push   %ebx
  801cb3:	68 ef 28 80 00       	push   $0x8028ef
  801cb8:	e8 ae e5 ff ff       	call   80026b <cprintf>
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	eb b9                	jmp    801c7b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801cc2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cc5:	0f 94 c0             	sete   %al
  801cc8:	0f b6 c0             	movzbl %al,%eax
}
  801ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cce:	5b                   	pop    %ebx
  801ccf:	5e                   	pop    %esi
  801cd0:	5f                   	pop    %edi
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <devpipe_write>:
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	57                   	push   %edi
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 28             	sub    $0x28,%esp
  801cdc:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801cdf:	56                   	push   %esi
  801ce0:	e8 be f1 ff ff       	call   800ea3 <fd2data>
  801ce5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	bf 00 00 00 00       	mov    $0x0,%edi
  801cef:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cf2:	75 09                	jne    801cfd <devpipe_write+0x2a>
	return i;
  801cf4:	89 f8                	mov    %edi,%eax
  801cf6:	eb 23                	jmp    801d1b <devpipe_write+0x48>
			sys_yield();
  801cf8:	e8 25 ef ff ff       	call   800c22 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cfd:	8b 43 04             	mov    0x4(%ebx),%eax
  801d00:	8b 0b                	mov    (%ebx),%ecx
  801d02:	8d 51 20             	lea    0x20(%ecx),%edx
  801d05:	39 d0                	cmp    %edx,%eax
  801d07:	72 1a                	jb     801d23 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801d09:	89 da                	mov    %ebx,%edx
  801d0b:	89 f0                	mov    %esi,%eax
  801d0d:	e8 5c ff ff ff       	call   801c6e <_pipeisclosed>
  801d12:	85 c0                	test   %eax,%eax
  801d14:	74 e2                	je     801cf8 <devpipe_write+0x25>
				return 0;
  801d16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d26:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d2a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d2d:	89 c2                	mov    %eax,%edx
  801d2f:	c1 fa 1f             	sar    $0x1f,%edx
  801d32:	89 d1                	mov    %edx,%ecx
  801d34:	c1 e9 1b             	shr    $0x1b,%ecx
  801d37:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d3a:	83 e2 1f             	and    $0x1f,%edx
  801d3d:	29 ca                	sub    %ecx,%edx
  801d3f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d43:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d47:	83 c0 01             	add    $0x1,%eax
  801d4a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d4d:	83 c7 01             	add    $0x1,%edi
  801d50:	eb 9d                	jmp    801cef <devpipe_write+0x1c>

00801d52 <devpipe_read>:
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	57                   	push   %edi
  801d56:	56                   	push   %esi
  801d57:	53                   	push   %ebx
  801d58:	83 ec 18             	sub    $0x18,%esp
  801d5b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d5e:	57                   	push   %edi
  801d5f:	e8 3f f1 ff ff       	call   800ea3 <fd2data>
  801d64:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	be 00 00 00 00       	mov    $0x0,%esi
  801d6e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d71:	75 13                	jne    801d86 <devpipe_read+0x34>
	return i;
  801d73:	89 f0                	mov    %esi,%eax
  801d75:	eb 02                	jmp    801d79 <devpipe_read+0x27>
				return i;
  801d77:	89 f0                	mov    %esi,%eax
}
  801d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d7c:	5b                   	pop    %ebx
  801d7d:	5e                   	pop    %esi
  801d7e:	5f                   	pop    %edi
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    
			sys_yield();
  801d81:	e8 9c ee ff ff       	call   800c22 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d86:	8b 03                	mov    (%ebx),%eax
  801d88:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d8b:	75 18                	jne    801da5 <devpipe_read+0x53>
			if (i > 0)
  801d8d:	85 f6                	test   %esi,%esi
  801d8f:	75 e6                	jne    801d77 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801d91:	89 da                	mov    %ebx,%edx
  801d93:	89 f8                	mov    %edi,%eax
  801d95:	e8 d4 fe ff ff       	call   801c6e <_pipeisclosed>
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	74 e3                	je     801d81 <devpipe_read+0x2f>
				return 0;
  801d9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801da3:	eb d4                	jmp    801d79 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801da5:	99                   	cltd   
  801da6:	c1 ea 1b             	shr    $0x1b,%edx
  801da9:	01 d0                	add    %edx,%eax
  801dab:	83 e0 1f             	and    $0x1f,%eax
  801dae:	29 d0                	sub    %edx,%eax
  801db0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801dbb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dbe:	83 c6 01             	add    $0x1,%esi
  801dc1:	eb ab                	jmp    801d6e <devpipe_read+0x1c>

00801dc3 <pipe>:
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	56                   	push   %esi
  801dc7:	53                   	push   %ebx
  801dc8:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801dcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dce:	50                   	push   %eax
  801dcf:	e8 e6 f0 ff ff       	call   800eba <fd_alloc>
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	0f 88 23 01 00 00    	js     801f04 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de1:	83 ec 04             	sub    $0x4,%esp
  801de4:	68 07 04 00 00       	push   $0x407
  801de9:	ff 75 f4             	push   -0xc(%ebp)
  801dec:	6a 00                	push   $0x0
  801dee:	e8 4e ee ff ff       	call   800c41 <sys_page_alloc>
  801df3:	89 c3                	mov    %eax,%ebx
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	0f 88 04 01 00 00    	js     801f04 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801e00:	83 ec 0c             	sub    $0xc,%esp
  801e03:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e06:	50                   	push   %eax
  801e07:	e8 ae f0 ff ff       	call   800eba <fd_alloc>
  801e0c:	89 c3                	mov    %eax,%ebx
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	85 c0                	test   %eax,%eax
  801e13:	0f 88 db 00 00 00    	js     801ef4 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e19:	83 ec 04             	sub    $0x4,%esp
  801e1c:	68 07 04 00 00       	push   $0x407
  801e21:	ff 75 f0             	push   -0x10(%ebp)
  801e24:	6a 00                	push   $0x0
  801e26:	e8 16 ee ff ff       	call   800c41 <sys_page_alloc>
  801e2b:	89 c3                	mov    %eax,%ebx
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	0f 88 bc 00 00 00    	js     801ef4 <pipe+0x131>
	va = fd2data(fd0);
  801e38:	83 ec 0c             	sub    $0xc,%esp
  801e3b:	ff 75 f4             	push   -0xc(%ebp)
  801e3e:	e8 60 f0 ff ff       	call   800ea3 <fd2data>
  801e43:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e45:	83 c4 0c             	add    $0xc,%esp
  801e48:	68 07 04 00 00       	push   $0x407
  801e4d:	50                   	push   %eax
  801e4e:	6a 00                	push   $0x0
  801e50:	e8 ec ed ff ff       	call   800c41 <sys_page_alloc>
  801e55:	89 c3                	mov    %eax,%ebx
  801e57:	83 c4 10             	add    $0x10,%esp
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	0f 88 82 00 00 00    	js     801ee4 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e62:	83 ec 0c             	sub    $0xc,%esp
  801e65:	ff 75 f0             	push   -0x10(%ebp)
  801e68:	e8 36 f0 ff ff       	call   800ea3 <fd2data>
  801e6d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e74:	50                   	push   %eax
  801e75:	6a 00                	push   $0x0
  801e77:	56                   	push   %esi
  801e78:	6a 00                	push   $0x0
  801e7a:	e8 05 ee ff ff       	call   800c84 <sys_page_map>
  801e7f:	89 c3                	mov    %eax,%ebx
  801e81:	83 c4 20             	add    $0x20,%esp
  801e84:	85 c0                	test   %eax,%eax
  801e86:	78 4e                	js     801ed6 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801e88:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801e8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e90:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e95:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e9f:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ea1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801eab:	83 ec 0c             	sub    $0xc,%esp
  801eae:	ff 75 f4             	push   -0xc(%ebp)
  801eb1:	e8 dd ef ff ff       	call   800e93 <fd2num>
  801eb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eb9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ebb:	83 c4 04             	add    $0x4,%esp
  801ebe:	ff 75 f0             	push   -0x10(%ebp)
  801ec1:	e8 cd ef ff ff       	call   800e93 <fd2num>
  801ec6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ed4:	eb 2e                	jmp    801f04 <pipe+0x141>
	sys_page_unmap(0, va);
  801ed6:	83 ec 08             	sub    $0x8,%esp
  801ed9:	56                   	push   %esi
  801eda:	6a 00                	push   $0x0
  801edc:	e8 e5 ed ff ff       	call   800cc6 <sys_page_unmap>
  801ee1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ee4:	83 ec 08             	sub    $0x8,%esp
  801ee7:	ff 75 f0             	push   -0x10(%ebp)
  801eea:	6a 00                	push   $0x0
  801eec:	e8 d5 ed ff ff       	call   800cc6 <sys_page_unmap>
  801ef1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ef4:	83 ec 08             	sub    $0x8,%esp
  801ef7:	ff 75 f4             	push   -0xc(%ebp)
  801efa:	6a 00                	push   $0x0
  801efc:	e8 c5 ed ff ff       	call   800cc6 <sys_page_unmap>
  801f01:	83 c4 10             	add    $0x10,%esp
}
  801f04:	89 d8                	mov    %ebx,%eax
  801f06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f09:	5b                   	pop    %ebx
  801f0a:	5e                   	pop    %esi
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    

00801f0d <pipeisclosed>:
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f16:	50                   	push   %eax
  801f17:	ff 75 08             	push   0x8(%ebp)
  801f1a:	e8 eb ef ff ff       	call   800f0a <fd_lookup>
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	85 c0                	test   %eax,%eax
  801f24:	78 18                	js     801f3e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801f26:	83 ec 0c             	sub    $0xc,%esp
  801f29:	ff 75 f4             	push   -0xc(%ebp)
  801f2c:	e8 72 ef ff ff       	call   800ea3 <fd2data>
  801f31:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f36:	e8 33 fd ff ff       	call   801c6e <_pipeisclosed>
  801f3b:	83 c4 10             	add    $0x10,%esp
}
  801f3e:	c9                   	leave  
  801f3f:	c3                   	ret    

00801f40 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801f40:	b8 00 00 00 00       	mov    $0x0,%eax
  801f45:	c3                   	ret    

00801f46 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f4c:	68 07 29 80 00       	push   $0x802907
  801f51:	ff 75 0c             	push   0xc(%ebp)
  801f54:	e8 ec e8 ff ff       	call   800845 <strcpy>
	return 0;
}
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5e:	c9                   	leave  
  801f5f:	c3                   	ret    

00801f60 <devcons_write>:
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	57                   	push   %edi
  801f64:	56                   	push   %esi
  801f65:	53                   	push   %ebx
  801f66:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f6c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f71:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f77:	eb 2e                	jmp    801fa7 <devcons_write+0x47>
		m = n - tot;
  801f79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f7c:	29 f3                	sub    %esi,%ebx
  801f7e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f83:	39 c3                	cmp    %eax,%ebx
  801f85:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f88:	83 ec 04             	sub    $0x4,%esp
  801f8b:	53                   	push   %ebx
  801f8c:	89 f0                	mov    %esi,%eax
  801f8e:	03 45 0c             	add    0xc(%ebp),%eax
  801f91:	50                   	push   %eax
  801f92:	57                   	push   %edi
  801f93:	e8 43 ea ff ff       	call   8009db <memmove>
		sys_cputs(buf, m);
  801f98:	83 c4 08             	add    $0x8,%esp
  801f9b:	53                   	push   %ebx
  801f9c:	57                   	push   %edi
  801f9d:	e8 e3 eb ff ff       	call   800b85 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fa2:	01 de                	add    %ebx,%esi
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801faa:	72 cd                	jb     801f79 <devcons_write+0x19>
}
  801fac:	89 f0                	mov    %esi,%eax
  801fae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb1:	5b                   	pop    %ebx
  801fb2:	5e                   	pop    %esi
  801fb3:	5f                   	pop    %edi
  801fb4:	5d                   	pop    %ebp
  801fb5:	c3                   	ret    

00801fb6 <devcons_read>:
{
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	83 ec 08             	sub    $0x8,%esp
  801fbc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fc5:	75 07                	jne    801fce <devcons_read+0x18>
  801fc7:	eb 1f                	jmp    801fe8 <devcons_read+0x32>
		sys_yield();
  801fc9:	e8 54 ec ff ff       	call   800c22 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801fce:	e8 d0 eb ff ff       	call   800ba3 <sys_cgetc>
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	74 f2                	je     801fc9 <devcons_read+0x13>
	if (c < 0)
  801fd7:	78 0f                	js     801fe8 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801fd9:	83 f8 04             	cmp    $0x4,%eax
  801fdc:	74 0c                	je     801fea <devcons_read+0x34>
	*(char*)vbuf = c;
  801fde:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fe1:	88 02                	mov    %al,(%edx)
	return 1;
  801fe3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    
		return 0;
  801fea:	b8 00 00 00 00       	mov    $0x0,%eax
  801fef:	eb f7                	jmp    801fe8 <devcons_read+0x32>

00801ff1 <cputchar>:
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffa:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ffd:	6a 01                	push   $0x1
  801fff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802002:	50                   	push   %eax
  802003:	e8 7d eb ff ff       	call   800b85 <sys_cputs>
}
  802008:	83 c4 10             	add    $0x10,%esp
  80200b:	c9                   	leave  
  80200c:	c3                   	ret    

0080200d <getchar>:
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802013:	6a 01                	push   $0x1
  802015:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802018:	50                   	push   %eax
  802019:	6a 00                	push   $0x0
  80201b:	e8 53 f1 ff ff       	call   801173 <read>
	if (r < 0)
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	85 c0                	test   %eax,%eax
  802025:	78 06                	js     80202d <getchar+0x20>
	if (r < 1)
  802027:	74 06                	je     80202f <getchar+0x22>
	return c;
  802029:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80202d:	c9                   	leave  
  80202e:	c3                   	ret    
		return -E_EOF;
  80202f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802034:	eb f7                	jmp    80202d <getchar+0x20>

00802036 <iscons>:
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80203c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203f:	50                   	push   %eax
  802040:	ff 75 08             	push   0x8(%ebp)
  802043:	e8 c2 ee ff ff       	call   800f0a <fd_lookup>
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 11                	js     802060 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80204f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802052:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802058:	39 10                	cmp    %edx,(%eax)
  80205a:	0f 94 c0             	sete   %al
  80205d:	0f b6 c0             	movzbl %al,%eax
}
  802060:	c9                   	leave  
  802061:	c3                   	ret    

00802062 <opencons>:
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802068:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206b:	50                   	push   %eax
  80206c:	e8 49 ee ff ff       	call   800eba <fd_alloc>
  802071:	83 c4 10             	add    $0x10,%esp
  802074:	85 c0                	test   %eax,%eax
  802076:	78 3a                	js     8020b2 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802078:	83 ec 04             	sub    $0x4,%esp
  80207b:	68 07 04 00 00       	push   $0x407
  802080:	ff 75 f4             	push   -0xc(%ebp)
  802083:	6a 00                	push   $0x0
  802085:	e8 b7 eb ff ff       	call   800c41 <sys_page_alloc>
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	85 c0                	test   %eax,%eax
  80208f:	78 21                	js     8020b2 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802091:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802094:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80209a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80209c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020a6:	83 ec 0c             	sub    $0xc,%esp
  8020a9:	50                   	push   %eax
  8020aa:	e8 e4 ed ff ff       	call   800e93 <fd2num>
  8020af:	83 c4 10             	add    $0x10,%esp
}
  8020b2:	c9                   	leave  
  8020b3:	c3                   	ret    

008020b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	56                   	push   %esi
  8020b8:	53                   	push   %ebx
  8020b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8020bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020c9:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8020cc:	83 ec 0c             	sub    $0xc,%esp
  8020cf:	50                   	push   %eax
  8020d0:	e8 1c ed ff ff       	call   800df1 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8020d5:	83 c4 10             	add    $0x10,%esp
  8020d8:	85 f6                	test   %esi,%esi
  8020da:	74 17                	je     8020f3 <ipc_recv+0x3f>
  8020dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 0c                	js     8020f1 <ipc_recv+0x3d>
  8020e5:	8b 15 00 60 80 00    	mov    0x806000,%edx
  8020eb:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8020f1:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8020f3:	85 db                	test   %ebx,%ebx
  8020f5:	74 17                	je     80210e <ipc_recv+0x5a>
  8020f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	78 0c                	js     80210c <ipc_recv+0x58>
  802100:	8b 15 00 60 80 00    	mov    0x806000,%edx
  802106:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80210c:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80210e:	85 c0                	test   %eax,%eax
  802110:	78 0b                	js     80211d <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802112:	a1 00 60 80 00       	mov    0x806000,%eax
  802117:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  80211d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	57                   	push   %edi
  802128:	56                   	push   %esi
  802129:	53                   	push   %ebx
  80212a:	83 ec 0c             	sub    $0xc,%esp
  80212d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802130:	8b 75 0c             	mov    0xc(%ebp),%esi
  802133:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802136:	85 db                	test   %ebx,%ebx
  802138:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80213d:	0f 44 d8             	cmove  %eax,%ebx
  802140:	eb 05                	jmp    802147 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802142:	e8 db ea ff ff       	call   800c22 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802147:	ff 75 14             	push   0x14(%ebp)
  80214a:	53                   	push   %ebx
  80214b:	56                   	push   %esi
  80214c:	57                   	push   %edi
  80214d:	e8 7c ec ff ff       	call   800dce <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802152:	83 c4 10             	add    $0x10,%esp
  802155:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802158:	74 e8                	je     802142 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80215a:	85 c0                	test   %eax,%eax
  80215c:	78 08                	js     802166 <ipc_send+0x42>
	}while (r<0);

}
  80215e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5f                   	pop    %edi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802166:	50                   	push   %eax
  802167:	68 13 29 80 00       	push   $0x802913
  80216c:	6a 3d                	push   $0x3d
  80216e:	68 27 29 80 00       	push   $0x802927
  802173:	e8 18 e0 ff ff       	call   800190 <_panic>

00802178 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80217e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802183:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802189:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80218f:	8b 52 60             	mov    0x60(%edx),%edx
  802192:	39 ca                	cmp    %ecx,%edx
  802194:	74 11                	je     8021a7 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802196:	83 c0 01             	add    $0x1,%eax
  802199:	3d 00 04 00 00       	cmp    $0x400,%eax
  80219e:	75 e3                	jne    802183 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8021a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a5:	eb 0e                	jmp    8021b5 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8021a7:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8021ad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021b2:	8b 40 58             	mov    0x58(%eax),%eax
}
  8021b5:	5d                   	pop    %ebp
  8021b6:	c3                   	ret    

008021b7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021b7:	55                   	push   %ebp
  8021b8:	89 e5                	mov    %esp,%ebp
  8021ba:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021bd:	89 c2                	mov    %eax,%edx
  8021bf:	c1 ea 16             	shr    $0x16,%edx
  8021c2:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8021c9:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8021ce:	f6 c1 01             	test   $0x1,%cl
  8021d1:	74 1c                	je     8021ef <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8021d3:	c1 e8 0c             	shr    $0xc,%eax
  8021d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021dd:	a8 01                	test   $0x1,%al
  8021df:	74 0e                	je     8021ef <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021e1:	c1 e8 0c             	shr    $0xc,%eax
  8021e4:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8021eb:	ef 
  8021ec:	0f b7 d2             	movzwl %dx,%edx
}
  8021ef:	89 d0                	mov    %edx,%eax
  8021f1:	5d                   	pop    %ebp
  8021f2:	c3                   	ret    
  8021f3:	66 90                	xchg   %ax,%ax
  8021f5:	66 90                	xchg   %ax,%ax
  8021f7:	66 90                	xchg   %ax,%ax
  8021f9:	66 90                	xchg   %ax,%ax
  8021fb:	66 90                	xchg   %ax,%ax
  8021fd:	66 90                	xchg   %ax,%ax
  8021ff:	90                   	nop

00802200 <__udivdi3>:
  802200:	f3 0f 1e fb          	endbr32 
  802204:	55                   	push   %ebp
  802205:	57                   	push   %edi
  802206:	56                   	push   %esi
  802207:	53                   	push   %ebx
  802208:	83 ec 1c             	sub    $0x1c,%esp
  80220b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80220f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802213:	8b 74 24 34          	mov    0x34(%esp),%esi
  802217:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80221b:	85 c0                	test   %eax,%eax
  80221d:	75 19                	jne    802238 <__udivdi3+0x38>
  80221f:	39 f3                	cmp    %esi,%ebx
  802221:	76 4d                	jbe    802270 <__udivdi3+0x70>
  802223:	31 ff                	xor    %edi,%edi
  802225:	89 e8                	mov    %ebp,%eax
  802227:	89 f2                	mov    %esi,%edx
  802229:	f7 f3                	div    %ebx
  80222b:	89 fa                	mov    %edi,%edx
  80222d:	83 c4 1c             	add    $0x1c,%esp
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    
  802235:	8d 76 00             	lea    0x0(%esi),%esi
  802238:	39 f0                	cmp    %esi,%eax
  80223a:	76 14                	jbe    802250 <__udivdi3+0x50>
  80223c:	31 ff                	xor    %edi,%edi
  80223e:	31 c0                	xor    %eax,%eax
  802240:	89 fa                	mov    %edi,%edx
  802242:	83 c4 1c             	add    $0x1c,%esp
  802245:	5b                   	pop    %ebx
  802246:	5e                   	pop    %esi
  802247:	5f                   	pop    %edi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    
  80224a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802250:	0f bd f8             	bsr    %eax,%edi
  802253:	83 f7 1f             	xor    $0x1f,%edi
  802256:	75 48                	jne    8022a0 <__udivdi3+0xa0>
  802258:	39 f0                	cmp    %esi,%eax
  80225a:	72 06                	jb     802262 <__udivdi3+0x62>
  80225c:	31 c0                	xor    %eax,%eax
  80225e:	39 eb                	cmp    %ebp,%ebx
  802260:	77 de                	ja     802240 <__udivdi3+0x40>
  802262:	b8 01 00 00 00       	mov    $0x1,%eax
  802267:	eb d7                	jmp    802240 <__udivdi3+0x40>
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d9                	mov    %ebx,%ecx
  802272:	85 db                	test   %ebx,%ebx
  802274:	75 0b                	jne    802281 <__udivdi3+0x81>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f3                	div    %ebx
  80227f:	89 c1                	mov    %eax,%ecx
  802281:	31 d2                	xor    %edx,%edx
  802283:	89 f0                	mov    %esi,%eax
  802285:	f7 f1                	div    %ecx
  802287:	89 c6                	mov    %eax,%esi
  802289:	89 e8                	mov    %ebp,%eax
  80228b:	89 f7                	mov    %esi,%edi
  80228d:	f7 f1                	div    %ecx
  80228f:	89 fa                	mov    %edi,%edx
  802291:	83 c4 1c             	add    $0x1c,%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	89 f9                	mov    %edi,%ecx
  8022a2:	ba 20 00 00 00       	mov    $0x20,%edx
  8022a7:	29 fa                	sub    %edi,%edx
  8022a9:	d3 e0                	shl    %cl,%eax
  8022ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022af:	89 d1                	mov    %edx,%ecx
  8022b1:	89 d8                	mov    %ebx,%eax
  8022b3:	d3 e8                	shr    %cl,%eax
  8022b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022b9:	09 c1                	or     %eax,%ecx
  8022bb:	89 f0                	mov    %esi,%eax
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	d3 e3                	shl    %cl,%ebx
  8022c5:	89 d1                	mov    %edx,%ecx
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 f9                	mov    %edi,%ecx
  8022cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8022cf:	89 eb                	mov    %ebp,%ebx
  8022d1:	d3 e6                	shl    %cl,%esi
  8022d3:	89 d1                	mov    %edx,%ecx
  8022d5:	d3 eb                	shr    %cl,%ebx
  8022d7:	09 f3                	or     %esi,%ebx
  8022d9:	89 c6                	mov    %eax,%esi
  8022db:	89 f2                	mov    %esi,%edx
  8022dd:	89 d8                	mov    %ebx,%eax
  8022df:	f7 74 24 08          	divl   0x8(%esp)
  8022e3:	89 d6                	mov    %edx,%esi
  8022e5:	89 c3                	mov    %eax,%ebx
  8022e7:	f7 64 24 0c          	mull   0xc(%esp)
  8022eb:	39 d6                	cmp    %edx,%esi
  8022ed:	72 19                	jb     802308 <__udivdi3+0x108>
  8022ef:	89 f9                	mov    %edi,%ecx
  8022f1:	d3 e5                	shl    %cl,%ebp
  8022f3:	39 c5                	cmp    %eax,%ebp
  8022f5:	73 04                	jae    8022fb <__udivdi3+0xfb>
  8022f7:	39 d6                	cmp    %edx,%esi
  8022f9:	74 0d                	je     802308 <__udivdi3+0x108>
  8022fb:	89 d8                	mov    %ebx,%eax
  8022fd:	31 ff                	xor    %edi,%edi
  8022ff:	e9 3c ff ff ff       	jmp    802240 <__udivdi3+0x40>
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80230b:	31 ff                	xor    %edi,%edi
  80230d:	e9 2e ff ff ff       	jmp    802240 <__udivdi3+0x40>
  802312:	66 90                	xchg   %ax,%ax
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__umoddi3>:
  802320:	f3 0f 1e fb          	endbr32 
  802324:	55                   	push   %ebp
  802325:	57                   	push   %edi
  802326:	56                   	push   %esi
  802327:	53                   	push   %ebx
  802328:	83 ec 1c             	sub    $0x1c,%esp
  80232b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80232f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802333:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802337:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80233b:	89 f0                	mov    %esi,%eax
  80233d:	89 da                	mov    %ebx,%edx
  80233f:	85 ff                	test   %edi,%edi
  802341:	75 15                	jne    802358 <__umoddi3+0x38>
  802343:	39 dd                	cmp    %ebx,%ebp
  802345:	76 39                	jbe    802380 <__umoddi3+0x60>
  802347:	f7 f5                	div    %ebp
  802349:	89 d0                	mov    %edx,%eax
  80234b:	31 d2                	xor    %edx,%edx
  80234d:	83 c4 1c             	add    $0x1c,%esp
  802350:	5b                   	pop    %ebx
  802351:	5e                   	pop    %esi
  802352:	5f                   	pop    %edi
  802353:	5d                   	pop    %ebp
  802354:	c3                   	ret    
  802355:	8d 76 00             	lea    0x0(%esi),%esi
  802358:	39 df                	cmp    %ebx,%edi
  80235a:	77 f1                	ja     80234d <__umoddi3+0x2d>
  80235c:	0f bd cf             	bsr    %edi,%ecx
  80235f:	83 f1 1f             	xor    $0x1f,%ecx
  802362:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802366:	75 40                	jne    8023a8 <__umoddi3+0x88>
  802368:	39 df                	cmp    %ebx,%edi
  80236a:	72 04                	jb     802370 <__umoddi3+0x50>
  80236c:	39 f5                	cmp    %esi,%ebp
  80236e:	77 dd                	ja     80234d <__umoddi3+0x2d>
  802370:	89 da                	mov    %ebx,%edx
  802372:	89 f0                	mov    %esi,%eax
  802374:	29 e8                	sub    %ebp,%eax
  802376:	19 fa                	sbb    %edi,%edx
  802378:	eb d3                	jmp    80234d <__umoddi3+0x2d>
  80237a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802380:	89 e9                	mov    %ebp,%ecx
  802382:	85 ed                	test   %ebp,%ebp
  802384:	75 0b                	jne    802391 <__umoddi3+0x71>
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f5                	div    %ebp
  80238f:	89 c1                	mov    %eax,%ecx
  802391:	89 d8                	mov    %ebx,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f1                	div    %ecx
  802397:	89 f0                	mov    %esi,%eax
  802399:	f7 f1                	div    %ecx
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	31 d2                	xor    %edx,%edx
  80239f:	eb ac                	jmp    80234d <__umoddi3+0x2d>
  8023a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023ac:	ba 20 00 00 00       	mov    $0x20,%edx
  8023b1:	29 c2                	sub    %eax,%edx
  8023b3:	89 c1                	mov    %eax,%ecx
  8023b5:	89 e8                	mov    %ebp,%eax
  8023b7:	d3 e7                	shl    %cl,%edi
  8023b9:	89 d1                	mov    %edx,%ecx
  8023bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8023bf:	d3 e8                	shr    %cl,%eax
  8023c1:	89 c1                	mov    %eax,%ecx
  8023c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023c7:	09 f9                	or     %edi,%ecx
  8023c9:	89 df                	mov    %ebx,%edi
  8023cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023cf:	89 c1                	mov    %eax,%ecx
  8023d1:	d3 e5                	shl    %cl,%ebp
  8023d3:	89 d1                	mov    %edx,%ecx
  8023d5:	d3 ef                	shr    %cl,%edi
  8023d7:	89 c1                	mov    %eax,%ecx
  8023d9:	89 f0                	mov    %esi,%eax
  8023db:	d3 e3                	shl    %cl,%ebx
  8023dd:	89 d1                	mov    %edx,%ecx
  8023df:	89 fa                	mov    %edi,%edx
  8023e1:	d3 e8                	shr    %cl,%eax
  8023e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023e8:	09 d8                	or     %ebx,%eax
  8023ea:	f7 74 24 08          	divl   0x8(%esp)
  8023ee:	89 d3                	mov    %edx,%ebx
  8023f0:	d3 e6                	shl    %cl,%esi
  8023f2:	f7 e5                	mul    %ebp
  8023f4:	89 c7                	mov    %eax,%edi
  8023f6:	89 d1                	mov    %edx,%ecx
  8023f8:	39 d3                	cmp    %edx,%ebx
  8023fa:	72 06                	jb     802402 <__umoddi3+0xe2>
  8023fc:	75 0e                	jne    80240c <__umoddi3+0xec>
  8023fe:	39 c6                	cmp    %eax,%esi
  802400:	73 0a                	jae    80240c <__umoddi3+0xec>
  802402:	29 e8                	sub    %ebp,%eax
  802404:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802408:	89 d1                	mov    %edx,%ecx
  80240a:	89 c7                	mov    %eax,%edi
  80240c:	89 f5                	mov    %esi,%ebp
  80240e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802412:	29 fd                	sub    %edi,%ebp
  802414:	19 cb                	sbb    %ecx,%ebx
  802416:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80241b:	89 d8                	mov    %ebx,%eax
  80241d:	d3 e0                	shl    %cl,%eax
  80241f:	89 f1                	mov    %esi,%ecx
  802421:	d3 ed                	shr    %cl,%ebp
  802423:	d3 eb                	shr    %cl,%ebx
  802425:	09 e8                	or     %ebp,%eax
  802427:	89 da                	mov    %ebx,%edx
  802429:	83 c4 1c             	add    $0x1c,%esp
  80242c:	5b                   	pop    %ebx
  80242d:	5e                   	pop    %esi
  80242e:	5f                   	pop    %edi
  80242f:	5d                   	pop    %ebp
  802430:	c3                   	ret    
