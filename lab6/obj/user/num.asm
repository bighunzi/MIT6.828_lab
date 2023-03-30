
obj/user/num.debug：     文件格式 elf32-i386


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
  80002c:	e8 50 01 00 00       	call   800181 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 1b                	jmp    80005e <num+0x2b>
		if (bol) {
			printf("%5d ", ++line);
			bol = 0;
		}
		if ((r = write(1, &c, 1)) != 1)
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	6a 01                	push   $0x1
  800048:	53                   	push   %ebx
  800049:	6a 01                	push   $0x1
  80004b:	e8 42 12 00 00       	call   801292 <write>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	83 f8 01             	cmp    $0x1,%eax
  800056:	75 4c                	jne    8000a4 <num+0x71>
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
  800058:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  80005c:	74 5e                	je     8000bc <num+0x89>
	while ((n = read(f, &c, 1)) > 0) {
  80005e:	83 ec 04             	sub    $0x4,%esp
  800061:	6a 01                	push   $0x1
  800063:	53                   	push   %ebx
  800064:	56                   	push   %esi
  800065:	e8 5a 11 00 00       	call   8011c4 <read>
  80006a:	83 c4 10             	add    $0x10,%esp
  80006d:	85 c0                	test   %eax,%eax
  80006f:	7e 57                	jle    8000c8 <num+0x95>
		if (bol) {
  800071:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  800078:	74 c9                	je     800043 <num+0x10>
			printf("%5d ", ++line);
  80007a:	a1 00 40 80 00       	mov    0x804000,%eax
  80007f:	83 c0 01             	add    $0x1,%eax
  800082:	a3 00 40 80 00       	mov    %eax,0x804000
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	50                   	push   %eax
  80008b:	68 80 24 80 00       	push   $0x802480
  800090:	e8 34 17 00 00       	call   8017c9 <printf>
			bol = 0;
  800095:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80009c:	00 00 00 
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	eb 9f                	jmp    800043 <num+0x10>
			panic("write error copying %s: %e", s, r);
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 75 0c             	push   0xc(%ebp)
  8000ab:	68 85 24 80 00       	push   $0x802485
  8000b0:	6a 13                	push   $0x13
  8000b2:	68 a0 24 80 00       	push   $0x8024a0
  8000b7:	e8 25 01 00 00       	call   8001e1 <_panic>
			bol = 1;
  8000bc:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c3:	00 00 00 
  8000c6:	eb 96                	jmp    80005e <num+0x2b>
	}
	if (n < 0)
  8000c8:	78 07                	js     8000d1 <num+0x9e>
		panic("error reading %s: %e", s, n);
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    
		panic("error reading %s: %e", s, n);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	50                   	push   %eax
  8000d5:	ff 75 0c             	push   0xc(%ebp)
  8000d8:	68 ab 24 80 00       	push   $0x8024ab
  8000dd:	6a 18                	push   $0x18
  8000df:	68 a0 24 80 00       	push   $0x8024a0
  8000e4:	e8 f8 00 00 00       	call   8001e1 <_panic>

008000e9 <umain>:

void
umain(int argc, char **argv)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f2:	c7 05 04 30 80 00 c0 	movl   $0x8024c0,0x803004
  8000f9:	24 80 00 
	if (argc == 1)
  8000fc:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800100:	74 0d                	je     80010f <umain+0x26>
  800102:	8b 45 0c             	mov    0xc(%ebp),%eax
  800105:	8d 70 04             	lea    0x4(%eax),%esi
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800108:	bf 01 00 00 00       	mov    $0x1,%edi
  80010d:	eb 3b                	jmp    80014a <umain+0x61>
		num(0, "<stdin>");
  80010f:	83 ec 08             	sub    $0x8,%esp
  800112:	68 c4 24 80 00       	push   $0x8024c4
  800117:	6a 00                	push   $0x0
  800119:	e8 15 ff ff ff       	call   800033 <num>
  80011e:	83 c4 10             	add    $0x10,%esp
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800121:	e8 a1 00 00 00       	call   8001c7 <exit>
}
  800126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    
				num(f, argv[i]);
  80012e:	83 ec 08             	sub    $0x8,%esp
  800131:	ff 36                	push   (%esi)
  800133:	50                   	push   %eax
  800134:	e8 fa fe ff ff       	call   800033 <num>
				close(f);
  800139:	89 1c 24             	mov    %ebx,(%esp)
  80013c:	e8 47 0f 00 00       	call   801088 <close>
		for (i = 1; i < argc; i++) {
  800141:	83 c7 01             	add    $0x1,%edi
  800144:	83 c6 04             	add    $0x4,%esi
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	3b 7d 08             	cmp    0x8(%ebp),%edi
  80014d:	7d d2                	jge    800121 <umain+0x38>
			f = open(argv[i], O_RDONLY);
  80014f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800152:	83 ec 08             	sub    $0x8,%esp
  800155:	6a 00                	push   $0x0
  800157:	ff 36                	push   (%esi)
  800159:	e8 c9 14 00 00       	call   801627 <open>
  80015e:	89 c3                	mov    %eax,%ebx
			if (f < 0)
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	85 c0                	test   %eax,%eax
  800165:	79 c7                	jns    80012e <umain+0x45>
				panic("can't open %s: %e", argv[i], f);
  800167:	83 ec 0c             	sub    $0xc,%esp
  80016a:	50                   	push   %eax
  80016b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80016e:	ff 30                	push   (%eax)
  800170:	68 cc 24 80 00       	push   $0x8024cc
  800175:	6a 27                	push   $0x27
  800177:	68 a0 24 80 00       	push   $0x8024a0
  80017c:	e8 60 00 00 00       	call   8001e1 <_panic>

00800181 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800189:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80018c:	e8 c3 0a 00 00       	call   800c54 <sys_getenvid>
  800191:	25 ff 03 00 00       	and    $0x3ff,%eax
  800196:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800199:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80019e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a3:	85 db                	test   %ebx,%ebx
  8001a5:	7e 07                	jle    8001ae <libmain+0x2d>
		binaryname = argv[0];
  8001a7:	8b 06                	mov    (%esi),%eax
  8001a9:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	e8 31 ff ff ff       	call   8000e9 <umain>

	// exit gracefully
	exit();
  8001b8:	e8 0a 00 00 00       	call   8001c7 <exit>
}
  8001bd:	83 c4 10             	add    $0x10,%esp
  8001c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c3:	5b                   	pop    %ebx
  8001c4:	5e                   	pop    %esi
  8001c5:	5d                   	pop    %ebp
  8001c6:	c3                   	ret    

008001c7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001cd:	e8 e3 0e 00 00       	call   8010b5 <close_all>
	sys_env_destroy(0);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	6a 00                	push   $0x0
  8001d7:	e8 37 0a 00 00       	call   800c13 <sys_env_destroy>
}
  8001dc:	83 c4 10             	add    $0x10,%esp
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e9:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001ef:	e8 60 0a 00 00       	call   800c54 <sys_getenvid>
  8001f4:	83 ec 0c             	sub    $0xc,%esp
  8001f7:	ff 75 0c             	push   0xc(%ebp)
  8001fa:	ff 75 08             	push   0x8(%ebp)
  8001fd:	56                   	push   %esi
  8001fe:	50                   	push   %eax
  8001ff:	68 e8 24 80 00       	push   $0x8024e8
  800204:	e8 b3 00 00 00       	call   8002bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800209:	83 c4 18             	add    $0x18,%esp
  80020c:	53                   	push   %ebx
  80020d:	ff 75 10             	push   0x10(%ebp)
  800210:	e8 56 00 00 00       	call   80026b <vcprintf>
	cprintf("\n");
  800215:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  80021c:	e8 9b 00 00 00       	call   8002bc <cprintf>
  800221:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800224:	cc                   	int3   
  800225:	eb fd                	jmp    800224 <_panic+0x43>

00800227 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	53                   	push   %ebx
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800231:	8b 13                	mov    (%ebx),%edx
  800233:	8d 42 01             	lea    0x1(%edx),%eax
  800236:	89 03                	mov    %eax,(%ebx)
  800238:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80023f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800244:	74 09                	je     80024f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800246:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80024a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	68 ff 00 00 00       	push   $0xff
  800257:	8d 43 08             	lea    0x8(%ebx),%eax
  80025a:	50                   	push   %eax
  80025b:	e8 76 09 00 00       	call   800bd6 <sys_cputs>
		b->idx = 0;
  800260:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800266:	83 c4 10             	add    $0x10,%esp
  800269:	eb db                	jmp    800246 <putch+0x1f>

0080026b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800274:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027b:	00 00 00 
	b.cnt = 0;
  80027e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800285:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800288:	ff 75 0c             	push   0xc(%ebp)
  80028b:	ff 75 08             	push   0x8(%ebp)
  80028e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800294:	50                   	push   %eax
  800295:	68 27 02 80 00       	push   $0x800227
  80029a:	e8 14 01 00 00       	call   8003b3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80029f:	83 c4 08             	add    $0x8,%esp
  8002a2:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ae:	50                   	push   %eax
  8002af:	e8 22 09 00 00       	call   800bd6 <sys_cputs>

	return b.cnt;
}
  8002b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c5:	50                   	push   %eax
  8002c6:	ff 75 08             	push   0x8(%ebp)
  8002c9:	e8 9d ff ff ff       	call   80026b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 1c             	sub    $0x1c,%esp
  8002d9:	89 c7                	mov    %eax,%edi
  8002db:	89 d6                	mov    %edx,%esi
  8002dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e3:	89 d1                	mov    %edx,%ecx
  8002e5:	89 c2                	mov    %eax,%edx
  8002e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002fd:	39 c2                	cmp    %eax,%edx
  8002ff:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800302:	72 3e                	jb     800342 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800304:	83 ec 0c             	sub    $0xc,%esp
  800307:	ff 75 18             	push   0x18(%ebp)
  80030a:	83 eb 01             	sub    $0x1,%ebx
  80030d:	53                   	push   %ebx
  80030e:	50                   	push   %eax
  80030f:	83 ec 08             	sub    $0x8,%esp
  800312:	ff 75 e4             	push   -0x1c(%ebp)
  800315:	ff 75 e0             	push   -0x20(%ebp)
  800318:	ff 75 dc             	push   -0x24(%ebp)
  80031b:	ff 75 d8             	push   -0x28(%ebp)
  80031e:	e8 1d 1f 00 00       	call   802240 <__udivdi3>
  800323:	83 c4 18             	add    $0x18,%esp
  800326:	52                   	push   %edx
  800327:	50                   	push   %eax
  800328:	89 f2                	mov    %esi,%edx
  80032a:	89 f8                	mov    %edi,%eax
  80032c:	e8 9f ff ff ff       	call   8002d0 <printnum>
  800331:	83 c4 20             	add    $0x20,%esp
  800334:	eb 13                	jmp    800349 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	56                   	push   %esi
  80033a:	ff 75 18             	push   0x18(%ebp)
  80033d:	ff d7                	call   *%edi
  80033f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800342:	83 eb 01             	sub    $0x1,%ebx
  800345:	85 db                	test   %ebx,%ebx
  800347:	7f ed                	jg     800336 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800349:	83 ec 08             	sub    $0x8,%esp
  80034c:	56                   	push   %esi
  80034d:	83 ec 04             	sub    $0x4,%esp
  800350:	ff 75 e4             	push   -0x1c(%ebp)
  800353:	ff 75 e0             	push   -0x20(%ebp)
  800356:	ff 75 dc             	push   -0x24(%ebp)
  800359:	ff 75 d8             	push   -0x28(%ebp)
  80035c:	e8 ff 1f 00 00       	call   802360 <__umoddi3>
  800361:	83 c4 14             	add    $0x14,%esp
  800364:	0f be 80 0b 25 80 00 	movsbl 0x80250b(%eax),%eax
  80036b:	50                   	push   %eax
  80036c:	ff d7                	call   *%edi
}
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800374:	5b                   	pop    %ebx
  800375:	5e                   	pop    %esi
  800376:	5f                   	pop    %edi
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800383:	8b 10                	mov    (%eax),%edx
  800385:	3b 50 04             	cmp    0x4(%eax),%edx
  800388:	73 0a                	jae    800394 <sprintputch+0x1b>
		*b->buf++ = ch;
  80038a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038d:	89 08                	mov    %ecx,(%eax)
  80038f:	8b 45 08             	mov    0x8(%ebp),%eax
  800392:	88 02                	mov    %al,(%edx)
}
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <printfmt>:
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80039c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039f:	50                   	push   %eax
  8003a0:	ff 75 10             	push   0x10(%ebp)
  8003a3:	ff 75 0c             	push   0xc(%ebp)
  8003a6:	ff 75 08             	push   0x8(%ebp)
  8003a9:	e8 05 00 00 00       	call   8003b3 <vprintfmt>
}
  8003ae:	83 c4 10             	add    $0x10,%esp
  8003b1:	c9                   	leave  
  8003b2:	c3                   	ret    

008003b3 <vprintfmt>:
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	57                   	push   %edi
  8003b7:	56                   	push   %esi
  8003b8:	53                   	push   %ebx
  8003b9:	83 ec 3c             	sub    $0x3c,%esp
  8003bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8003bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c5:	eb 0a                	jmp    8003d1 <vprintfmt+0x1e>
			putch(ch, putdat);
  8003c7:	83 ec 08             	sub    $0x8,%esp
  8003ca:	53                   	push   %ebx
  8003cb:	50                   	push   %eax
  8003cc:	ff d6                	call   *%esi
  8003ce:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d1:	83 c7 01             	add    $0x1,%edi
  8003d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d8:	83 f8 25             	cmp    $0x25,%eax
  8003db:	74 0c                	je     8003e9 <vprintfmt+0x36>
			if (ch == '\0')
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	75 e6                	jne    8003c7 <vprintfmt+0x14>
}
  8003e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5f                   	pop    %edi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    
		padc = ' ';
  8003e9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003ed:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003f4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003fb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800402:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8d 47 01             	lea    0x1(%edi),%eax
  80040a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040d:	0f b6 17             	movzbl (%edi),%edx
  800410:	8d 42 dd             	lea    -0x23(%edx),%eax
  800413:	3c 55                	cmp    $0x55,%al
  800415:	0f 87 bb 03 00 00    	ja     8007d6 <vprintfmt+0x423>
  80041b:	0f b6 c0             	movzbl %al,%eax
  80041e:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800428:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80042c:	eb d9                	jmp    800407 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800431:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800435:	eb d0                	jmp    800407 <vprintfmt+0x54>
  800437:	0f b6 d2             	movzbl %dl,%edx
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80043d:	b8 00 00 00 00       	mov    $0x0,%eax
  800442:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800445:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800448:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80044c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80044f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800452:	83 f9 09             	cmp    $0x9,%ecx
  800455:	77 55                	ja     8004ac <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800457:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80045a:	eb e9                	jmp    800445 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 40 04             	lea    0x4(%eax),%eax
  80046a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800470:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800474:	79 91                	jns    800407 <vprintfmt+0x54>
				width = precision, precision = -1;
  800476:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800483:	eb 82                	jmp    800407 <vprintfmt+0x54>
  800485:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800488:	85 d2                	test   %edx,%edx
  80048a:	b8 00 00 00 00       	mov    $0x0,%eax
  80048f:	0f 49 c2             	cmovns %edx,%eax
  800492:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800498:	e9 6a ff ff ff       	jmp    800407 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004a0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004a7:	e9 5b ff ff ff       	jmp    800407 <vprintfmt+0x54>
  8004ac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b2:	eb bc                	jmp    800470 <vprintfmt+0xbd>
			lflag++;
  8004b4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ba:	e9 48 ff ff ff       	jmp    800407 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8d 78 04             	lea    0x4(%eax),%edi
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	53                   	push   %ebx
  8004c9:	ff 30                	push   (%eax)
  8004cb:	ff d6                	call   *%esi
			break;
  8004cd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004d0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004d3:	e9 9d 02 00 00       	jmp    800775 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 78 04             	lea    0x4(%eax),%edi
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	89 d0                	mov    %edx,%eax
  8004e2:	f7 d8                	neg    %eax
  8004e4:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e7:	83 f8 0f             	cmp    $0xf,%eax
  8004ea:	7f 23                	jg     80050f <vprintfmt+0x15c>
  8004ec:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 18                	je     80050f <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004f7:	52                   	push   %edx
  8004f8:	68 d5 28 80 00       	push   $0x8028d5
  8004fd:	53                   	push   %ebx
  8004fe:	56                   	push   %esi
  8004ff:	e8 92 fe ff ff       	call   800396 <printfmt>
  800504:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800507:	89 7d 14             	mov    %edi,0x14(%ebp)
  80050a:	e9 66 02 00 00       	jmp    800775 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80050f:	50                   	push   %eax
  800510:	68 23 25 80 00       	push   $0x802523
  800515:	53                   	push   %ebx
  800516:	56                   	push   %esi
  800517:	e8 7a fe ff ff       	call   800396 <printfmt>
  80051c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800522:	e9 4e 02 00 00       	jmp    800775 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	83 c0 04             	add    $0x4,%eax
  80052d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800535:	85 d2                	test   %edx,%edx
  800537:	b8 1c 25 80 00       	mov    $0x80251c,%eax
  80053c:	0f 45 c2             	cmovne %edx,%eax
  80053f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800542:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800546:	7e 06                	jle    80054e <vprintfmt+0x19b>
  800548:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80054c:	75 0d                	jne    80055b <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800551:	89 c7                	mov    %eax,%edi
  800553:	03 45 e0             	add    -0x20(%ebp),%eax
  800556:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800559:	eb 55                	jmp    8005b0 <vprintfmt+0x1fd>
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	ff 75 d8             	push   -0x28(%ebp)
  800561:	ff 75 cc             	push   -0x34(%ebp)
  800564:	e8 0a 03 00 00       	call   800873 <strnlen>
  800569:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056c:	29 c1                	sub    %eax,%ecx
  80056e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800576:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80057a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80057d:	eb 0f                	jmp    80058e <vprintfmt+0x1db>
					putch(padc, putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	53                   	push   %ebx
  800583:	ff 75 e0             	push   -0x20(%ebp)
  800586:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800588:	83 ef 01             	sub    $0x1,%edi
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	85 ff                	test   %edi,%edi
  800590:	7f ed                	jg     80057f <vprintfmt+0x1cc>
  800592:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	0f 49 c2             	cmovns %edx,%eax
  80059f:	29 c2                	sub    %eax,%edx
  8005a1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005a4:	eb a8                	jmp    80054e <vprintfmt+0x19b>
					putch(ch, putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	52                   	push   %edx
  8005ab:	ff d6                	call   *%esi
  8005ad:	83 c4 10             	add    $0x10,%esp
  8005b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b5:	83 c7 01             	add    $0x1,%edi
  8005b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005bc:	0f be d0             	movsbl %al,%edx
  8005bf:	85 d2                	test   %edx,%edx
  8005c1:	74 4b                	je     80060e <vprintfmt+0x25b>
  8005c3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c7:	78 06                	js     8005cf <vprintfmt+0x21c>
  8005c9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005cd:	78 1e                	js     8005ed <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d3:	74 d1                	je     8005a6 <vprintfmt+0x1f3>
  8005d5:	0f be c0             	movsbl %al,%eax
  8005d8:	83 e8 20             	sub    $0x20,%eax
  8005db:	83 f8 5e             	cmp    $0x5e,%eax
  8005de:	76 c6                	jbe    8005a6 <vprintfmt+0x1f3>
					putch('?', putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	53                   	push   %ebx
  8005e4:	6a 3f                	push   $0x3f
  8005e6:	ff d6                	call   *%esi
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	eb c3                	jmp    8005b0 <vprintfmt+0x1fd>
  8005ed:	89 cf                	mov    %ecx,%edi
  8005ef:	eb 0e                	jmp    8005ff <vprintfmt+0x24c>
				putch(' ', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	6a 20                	push   $0x20
  8005f7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005f9:	83 ef 01             	sub    $0x1,%edi
  8005fc:	83 c4 10             	add    $0x10,%esp
  8005ff:	85 ff                	test   %edi,%edi
  800601:	7f ee                	jg     8005f1 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800603:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
  800609:	e9 67 01 00 00       	jmp    800775 <vprintfmt+0x3c2>
  80060e:	89 cf                	mov    %ecx,%edi
  800610:	eb ed                	jmp    8005ff <vprintfmt+0x24c>
	if (lflag >= 2)
  800612:	83 f9 01             	cmp    $0x1,%ecx
  800615:	7f 1b                	jg     800632 <vprintfmt+0x27f>
	else if (lflag)
  800617:	85 c9                	test   %ecx,%ecx
  800619:	74 63                	je     80067e <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800623:	99                   	cltd   
  800624:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 40 04             	lea    0x4(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
  800630:	eb 17                	jmp    800649 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 40 08             	lea    0x8(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800649:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80064f:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800654:	85 c9                	test   %ecx,%ecx
  800656:	0f 89 ff 00 00 00    	jns    80075b <vprintfmt+0x3a8>
				putch('-', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 2d                	push   $0x2d
  800662:	ff d6                	call   *%esi
				num = -(long long) num;
  800664:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800667:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80066a:	f7 da                	neg    %edx
  80066c:	83 d1 00             	adc    $0x0,%ecx
  80066f:	f7 d9                	neg    %ecx
  800671:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800674:	bf 0a 00 00 00       	mov    $0xa,%edi
  800679:	e9 dd 00 00 00       	jmp    80075b <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800686:	99                   	cltd   
  800687:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
  800693:	eb b4                	jmp    800649 <vprintfmt+0x296>
	if (lflag >= 2)
  800695:	83 f9 01             	cmp    $0x1,%ecx
  800698:	7f 1e                	jg     8006b8 <vprintfmt+0x305>
	else if (lflag)
  80069a:	85 c9                	test   %ecx,%ecx
  80069c:	74 32                	je     8006d0 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8b 10                	mov    (%eax),%edx
  8006a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a8:	8d 40 04             	lea    0x4(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ae:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8006b3:	e9 a3 00 00 00       	jmp    80075b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c0:	8d 40 08             	lea    0x8(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8006cb:	e9 8b 00 00 00       	jmp    80075b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8006e5:	eb 74                	jmp    80075b <vprintfmt+0x3a8>
	if (lflag >= 2)
  8006e7:	83 f9 01             	cmp    $0x1,%ecx
  8006ea:	7f 1b                	jg     800707 <vprintfmt+0x354>
	else if (lflag)
  8006ec:	85 c9                	test   %ecx,%ecx
  8006ee:	74 2c                	je     80071c <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 10                	mov    (%eax),%edx
  8006f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fa:	8d 40 04             	lea    0x4(%eax),%eax
  8006fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800700:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800705:	eb 54                	jmp    80075b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	8b 48 04             	mov    0x4(%eax),%ecx
  80070f:	8d 40 08             	lea    0x8(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800715:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80071a:	eb 3f                	jmp    80075b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	b9 00 00 00 00       	mov    $0x0,%ecx
  800726:	8d 40 04             	lea    0x4(%eax),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80072c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800731:	eb 28                	jmp    80075b <vprintfmt+0x3a8>
			putch('0', putdat);
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	53                   	push   %ebx
  800737:	6a 30                	push   $0x30
  800739:	ff d6                	call   *%esi
			putch('x', putdat);
  80073b:	83 c4 08             	add    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	6a 78                	push   $0x78
  800741:	ff d6                	call   *%esi
			num = (unsigned long long)
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8b 10                	mov    (%eax),%edx
  800748:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80074d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800750:	8d 40 04             	lea    0x4(%eax),%eax
  800753:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800756:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80075b:	83 ec 0c             	sub    $0xc,%esp
  80075e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800762:	50                   	push   %eax
  800763:	ff 75 e0             	push   -0x20(%ebp)
  800766:	57                   	push   %edi
  800767:	51                   	push   %ecx
  800768:	52                   	push   %edx
  800769:	89 da                	mov    %ebx,%edx
  80076b:	89 f0                	mov    %esi,%eax
  80076d:	e8 5e fb ff ff       	call   8002d0 <printnum>
			break;
  800772:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800778:	e9 54 fc ff ff       	jmp    8003d1 <vprintfmt+0x1e>
	if (lflag >= 2)
  80077d:	83 f9 01             	cmp    $0x1,%ecx
  800780:	7f 1b                	jg     80079d <vprintfmt+0x3ea>
	else if (lflag)
  800782:	85 c9                	test   %ecx,%ecx
  800784:	74 2c                	je     8007b2 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 10                	mov    (%eax),%edx
  80078b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800790:	8d 40 04             	lea    0x4(%eax),%eax
  800793:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800796:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80079b:	eb be                	jmp    80075b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 10                	mov    (%eax),%edx
  8007a2:	8b 48 04             	mov    0x4(%eax),%ecx
  8007a5:	8d 40 08             	lea    0x8(%eax),%eax
  8007a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ab:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8007b0:	eb a9                	jmp    80075b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8007c7:	eb 92                	jmp    80075b <vprintfmt+0x3a8>
			putch(ch, putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	53                   	push   %ebx
  8007cd:	6a 25                	push   $0x25
  8007cf:	ff d6                	call   *%esi
			break;
  8007d1:	83 c4 10             	add    $0x10,%esp
  8007d4:	eb 9f                	jmp    800775 <vprintfmt+0x3c2>
			putch('%', putdat);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	53                   	push   %ebx
  8007da:	6a 25                	push   $0x25
  8007dc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	89 f8                	mov    %edi,%eax
  8007e3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e7:	74 05                	je     8007ee <vprintfmt+0x43b>
  8007e9:	83 e8 01             	sub    $0x1,%eax
  8007ec:	eb f5                	jmp    8007e3 <vprintfmt+0x430>
  8007ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f1:	eb 82                	jmp    800775 <vprintfmt+0x3c2>

008007f3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 18             	sub    $0x18,%esp
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800810:	85 c0                	test   %eax,%eax
  800812:	74 26                	je     80083a <vsnprintf+0x47>
  800814:	85 d2                	test   %edx,%edx
  800816:	7e 22                	jle    80083a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800818:	ff 75 14             	push   0x14(%ebp)
  80081b:	ff 75 10             	push   0x10(%ebp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	68 79 03 80 00       	push   $0x800379
  800827:	e8 87 fb ff ff       	call   8003b3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800835:	83 c4 10             	add    $0x10,%esp
}
  800838:	c9                   	leave  
  800839:	c3                   	ret    
		return -E_INVAL;
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083f:	eb f7                	jmp    800838 <vsnprintf+0x45>

00800841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	push   0x10(%ebp)
  80084e:	ff 75 0c             	push   0xc(%ebp)
  800851:	ff 75 08             	push   0x8(%ebp)
  800854:	e8 9a ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strlen+0x10>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80086b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086f:	75 f7                	jne    800868 <strlen+0xd>
	return n;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
  800881:	eb 03                	jmp    800886 <strnlen+0x13>
		n++;
  800883:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 d0                	cmp    %edx,%eax
  800888:	74 08                	je     800892 <strnlen+0x1f>
  80088a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x10>
  800890:	89 c2                	mov    %eax,%edx
	return n;
}
  800892:	89 d0                	mov    %edx,%eax
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008a9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	84 d2                	test   %dl,%dl
  8008b1:	75 f2                	jne    8008a5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b3:	89 c8                	mov    %ecx,%eax
  8008b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	83 ec 10             	sub    $0x10,%esp
  8008c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c4:	53                   	push   %ebx
  8008c5:	e8 91 ff ff ff       	call   80085b <strlen>
  8008ca:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008cd:	ff 75 0c             	push   0xc(%ebp)
  8008d0:	01 d8                	add    %ebx,%eax
  8008d2:	50                   	push   %eax
  8008d3:	e8 be ff ff ff       	call   800896 <strcpy>
	return dst;
}
  8008d8:	89 d8                	mov    %ebx,%eax
  8008da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    

008008df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	89 f3                	mov    %esi,%ebx
  8008ec:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ef:	89 f0                	mov    %esi,%eax
  8008f1:	eb 0f                	jmp    800902 <strncpy+0x23>
		*dst++ = *src;
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	0f b6 0a             	movzbl (%edx),%ecx
  8008f9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008fc:	80 f9 01             	cmp    $0x1,%cl
  8008ff:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800902:	39 d8                	cmp    %ebx,%eax
  800904:	75 ed                	jne    8008f3 <strncpy+0x14>
	}
	return ret;
}
  800906:	89 f0                	mov    %esi,%eax
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
  800911:	8b 75 08             	mov    0x8(%ebp),%esi
  800914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800917:	8b 55 10             	mov    0x10(%ebp),%edx
  80091a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091c:	85 d2                	test   %edx,%edx
  80091e:	74 21                	je     800941 <strlcpy+0x35>
  800920:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800924:	89 f2                	mov    %esi,%edx
  800926:	eb 09                	jmp    800931 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800928:	83 c1 01             	add    $0x1,%ecx
  80092b:	83 c2 01             	add    $0x1,%edx
  80092e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800931:	39 c2                	cmp    %eax,%edx
  800933:	74 09                	je     80093e <strlcpy+0x32>
  800935:	0f b6 19             	movzbl (%ecx),%ebx
  800938:	84 db                	test   %bl,%bl
  80093a:	75 ec                	jne    800928 <strlcpy+0x1c>
  80093c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80093e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800941:	29 f0                	sub    %esi,%eax
}
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800950:	eb 06                	jmp    800958 <strcmp+0x11>
		p++, q++;
  800952:	83 c1 01             	add    $0x1,%ecx
  800955:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800958:	0f b6 01             	movzbl (%ecx),%eax
  80095b:	84 c0                	test   %al,%al
  80095d:	74 04                	je     800963 <strcmp+0x1c>
  80095f:	3a 02                	cmp    (%edx),%al
  800961:	74 ef                	je     800952 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800963:	0f b6 c0             	movzbl %al,%eax
  800966:	0f b6 12             	movzbl (%edx),%edx
  800969:	29 d0                	sub    %edx,%eax
}
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	53                   	push   %ebx
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 55 0c             	mov    0xc(%ebp),%edx
  800977:	89 c3                	mov    %eax,%ebx
  800979:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80097c:	eb 06                	jmp    800984 <strncmp+0x17>
		n--, p++, q++;
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800984:	39 d8                	cmp    %ebx,%eax
  800986:	74 18                	je     8009a0 <strncmp+0x33>
  800988:	0f b6 08             	movzbl (%eax),%ecx
  80098b:	84 c9                	test   %cl,%cl
  80098d:	74 04                	je     800993 <strncmp+0x26>
  80098f:	3a 0a                	cmp    (%edx),%cl
  800991:	74 eb                	je     80097e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800993:	0f b6 00             	movzbl (%eax),%eax
  800996:	0f b6 12             	movzbl (%edx),%edx
  800999:	29 d0                	sub    %edx,%eax
}
  80099b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    
		return 0;
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a5:	eb f4                	jmp    80099b <strncmp+0x2e>

008009a7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b1:	eb 03                	jmp    8009b6 <strchr+0xf>
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	0f b6 10             	movzbl (%eax),%edx
  8009b9:	84 d2                	test   %dl,%dl
  8009bb:	74 06                	je     8009c3 <strchr+0x1c>
		if (*s == c)
  8009bd:	38 ca                	cmp    %cl,%dl
  8009bf:	75 f2                	jne    8009b3 <strchr+0xc>
  8009c1:	eb 05                	jmp    8009c8 <strchr+0x21>
			return (char *) s;
	return 0;
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d7:	38 ca                	cmp    %cl,%dl
  8009d9:	74 09                	je     8009e4 <strfind+0x1a>
  8009db:	84 d2                	test   %dl,%dl
  8009dd:	74 05                	je     8009e4 <strfind+0x1a>
	for (; *s; s++)
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	eb f0                	jmp    8009d4 <strfind+0xa>
			break;
	return (char *) s;
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f2:	85 c9                	test   %ecx,%ecx
  8009f4:	74 2f                	je     800a25 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f6:	89 f8                	mov    %edi,%eax
  8009f8:	09 c8                	or     %ecx,%eax
  8009fa:	a8 03                	test   $0x3,%al
  8009fc:	75 21                	jne    800a1f <memset+0x39>
		c &= 0xFF;
  8009fe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	c1 e0 08             	shl    $0x8,%eax
  800a07:	89 d3                	mov    %edx,%ebx
  800a09:	c1 e3 18             	shl    $0x18,%ebx
  800a0c:	89 d6                	mov    %edx,%esi
  800a0e:	c1 e6 10             	shl    $0x10,%esi
  800a11:	09 f3                	or     %esi,%ebx
  800a13:	09 da                	or     %ebx,%edx
  800a15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a17:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a1a:	fc                   	cld    
  800a1b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1d:	eb 06                	jmp    800a25 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a22:	fc                   	cld    
  800a23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a25:	89 f8                	mov    %edi,%eax
  800a27:	5b                   	pop    %ebx
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3a:	39 c6                	cmp    %eax,%esi
  800a3c:	73 32                	jae    800a70 <memmove+0x44>
  800a3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a41:	39 c2                	cmp    %eax,%edx
  800a43:	76 2b                	jbe    800a70 <memmove+0x44>
		s += n;
		d += n;
  800a45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a48:	89 d6                	mov    %edx,%esi
  800a4a:	09 fe                	or     %edi,%esi
  800a4c:	09 ce                	or     %ecx,%esi
  800a4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a54:	75 0e                	jne    800a64 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a56:	83 ef 04             	sub    $0x4,%edi
  800a59:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a5f:	fd                   	std    
  800a60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a62:	eb 09                	jmp    800a6d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a64:	83 ef 01             	sub    $0x1,%edi
  800a67:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6a:	fd                   	std    
  800a6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6d:	fc                   	cld    
  800a6e:	eb 1a                	jmp    800a8a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a70:	89 f2                	mov    %esi,%edx
  800a72:	09 c2                	or     %eax,%edx
  800a74:	09 ca                	or     %ecx,%edx
  800a76:	f6 c2 03             	test   $0x3,%dl
  800a79:	75 0a                	jne    800a85 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a7e:	89 c7                	mov    %eax,%edi
  800a80:	fc                   	cld    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 05                	jmp    800a8a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a85:	89 c7                	mov    %eax,%edi
  800a87:	fc                   	cld    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a94:	ff 75 10             	push   0x10(%ebp)
  800a97:	ff 75 0c             	push   0xc(%ebp)
  800a9a:	ff 75 08             	push   0x8(%ebp)
  800a9d:	e8 8a ff ff ff       	call   800a2c <memmove>
}
  800aa2:	c9                   	leave  
  800aa3:	c3                   	ret    

00800aa4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaf:	89 c6                	mov    %eax,%esi
  800ab1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab4:	eb 06                	jmp    800abc <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab6:	83 c0 01             	add    $0x1,%eax
  800ab9:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800abc:	39 f0                	cmp    %esi,%eax
  800abe:	74 14                	je     800ad4 <memcmp+0x30>
		if (*s1 != *s2)
  800ac0:	0f b6 08             	movzbl (%eax),%ecx
  800ac3:	0f b6 1a             	movzbl (%edx),%ebx
  800ac6:	38 d9                	cmp    %bl,%cl
  800ac8:	74 ec                	je     800ab6 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800aca:	0f b6 c1             	movzbl %cl,%eax
  800acd:	0f b6 db             	movzbl %bl,%ebx
  800ad0:	29 d8                	sub    %ebx,%eax
  800ad2:	eb 05                	jmp    800ad9 <memcmp+0x35>
	}

	return 0;
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae6:	89 c2                	mov    %eax,%edx
  800ae8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aeb:	eb 03                	jmp    800af0 <memfind+0x13>
  800aed:	83 c0 01             	add    $0x1,%eax
  800af0:	39 d0                	cmp    %edx,%eax
  800af2:	73 04                	jae    800af8 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af4:	38 08                	cmp    %cl,(%eax)
  800af6:	75 f5                	jne    800aed <memfind+0x10>
			break;
	return (void *) s;
}
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b06:	eb 03                	jmp    800b0b <strtol+0x11>
		s++;
  800b08:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b0b:	0f b6 02             	movzbl (%edx),%eax
  800b0e:	3c 20                	cmp    $0x20,%al
  800b10:	74 f6                	je     800b08 <strtol+0xe>
  800b12:	3c 09                	cmp    $0x9,%al
  800b14:	74 f2                	je     800b08 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b16:	3c 2b                	cmp    $0x2b,%al
  800b18:	74 2a                	je     800b44 <strtol+0x4a>
	int neg = 0;
  800b1a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1f:	3c 2d                	cmp    $0x2d,%al
  800b21:	74 2b                	je     800b4e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b23:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b29:	75 0f                	jne    800b3a <strtol+0x40>
  800b2b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2e:	74 28                	je     800b58 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b30:	85 db                	test   %ebx,%ebx
  800b32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b37:	0f 44 d8             	cmove  %eax,%ebx
  800b3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b42:	eb 46                	jmp    800b8a <strtol+0x90>
		s++;
  800b44:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b47:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4c:	eb d5                	jmp    800b23 <strtol+0x29>
		s++, neg = 1;
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	bf 01 00 00 00       	mov    $0x1,%edi
  800b56:	eb cb                	jmp    800b23 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b58:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b5c:	74 0e                	je     800b6c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b5e:	85 db                	test   %ebx,%ebx
  800b60:	75 d8                	jne    800b3a <strtol+0x40>
		s++, base = 8;
  800b62:	83 c2 01             	add    $0x1,%edx
  800b65:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b6a:	eb ce                	jmp    800b3a <strtol+0x40>
		s += 2, base = 16;
  800b6c:	83 c2 02             	add    $0x2,%edx
  800b6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b74:	eb c4                	jmp    800b3a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b76:	0f be c0             	movsbl %al,%eax
  800b79:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7c:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b7f:	7d 3a                	jge    800bbb <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b81:	83 c2 01             	add    $0x1,%edx
  800b84:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b88:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b8a:	0f b6 02             	movzbl (%edx),%eax
  800b8d:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	80 fb 09             	cmp    $0x9,%bl
  800b95:	76 df                	jbe    800b76 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b97:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b9a:	89 f3                	mov    %esi,%ebx
  800b9c:	80 fb 19             	cmp    $0x19,%bl
  800b9f:	77 08                	ja     800ba9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ba1:	0f be c0             	movsbl %al,%eax
  800ba4:	83 e8 57             	sub    $0x57,%eax
  800ba7:	eb d3                	jmp    800b7c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ba9:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 08                	ja     800bbb <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bb3:	0f be c0             	movsbl %al,%eax
  800bb6:	83 e8 37             	sub    $0x37,%eax
  800bb9:	eb c1                	jmp    800b7c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bbb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbf:	74 05                	je     800bc6 <strtol+0xcc>
		*endptr = (char *) s;
  800bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bc6:	89 c8                	mov    %ecx,%eax
  800bc8:	f7 d8                	neg    %eax
  800bca:	85 ff                	test   %edi,%edi
  800bcc:	0f 45 c8             	cmovne %eax,%ecx
}
  800bcf:	89 c8                	mov    %ecx,%eax
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800be1:	8b 55 08             	mov    0x8(%ebp),%edx
  800be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be7:	89 c3                	mov    %eax,%ebx
  800be9:	89 c7                	mov    %eax,%edi
  800beb:	89 c6                	mov    %eax,%esi
  800bed:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 01 00 00 00       	mov    $0x1,%eax
  800c04:	89 d1                	mov    %edx,%ecx
  800c06:	89 d3                	mov    %edx,%ebx
  800c08:	89 d7                	mov    %edx,%edi
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	b8 03 00 00 00       	mov    $0x3,%eax
  800c29:	89 cb                	mov    %ecx,%ebx
  800c2b:	89 cf                	mov    %ecx,%edi
  800c2d:	89 ce                	mov    %ecx,%esi
  800c2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7f 08                	jg     800c3d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 03                	push   $0x3
  800c43:	68 ff 27 80 00       	push   $0x8027ff
  800c48:	6a 2a                	push   $0x2a
  800c4a:	68 1c 28 80 00       	push   $0x80281c
  800c4f:	e8 8d f5 ff ff       	call   8001e1 <_panic>

00800c54 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c64:	89 d1                	mov    %edx,%ecx
  800c66:	89 d3                	mov    %edx,%ebx
  800c68:	89 d7                	mov    %edx,%edi
  800c6a:	89 d6                	mov    %edx,%esi
  800c6c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_yield>:

void
sys_yield(void)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c79:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c83:	89 d1                	mov    %edx,%ecx
  800c85:	89 d3                	mov    %edx,%ebx
  800c87:	89 d7                	mov    %edx,%edi
  800c89:	89 d6                	mov    %edx,%esi
  800c8b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9b:	be 00 00 00 00       	mov    $0x0,%esi
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	b8 04 00 00 00       	mov    $0x4,%eax
  800cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cae:	89 f7                	mov    %esi,%edi
  800cb0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7f 08                	jg     800cbe <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 04                	push   $0x4
  800cc4:	68 ff 27 80 00       	push   $0x8027ff
  800cc9:	6a 2a                	push   $0x2a
  800ccb:	68 1c 28 80 00       	push   $0x80281c
  800cd0:	e8 0c f5 ff ff       	call   8001e1 <_panic>

00800cd5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cef:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7f 08                	jg     800d00 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	83 ec 0c             	sub    $0xc,%esp
  800d03:	50                   	push   %eax
  800d04:	6a 05                	push   $0x5
  800d06:	68 ff 27 80 00       	push   $0x8027ff
  800d0b:	6a 2a                	push   $0x2a
  800d0d:	68 1c 28 80 00       	push   $0x80281c
  800d12:	e8 ca f4 ff ff       	call   8001e1 <_panic>

00800d17 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d30:	89 df                	mov    %ebx,%edi
  800d32:	89 de                	mov    %ebx,%esi
  800d34:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7f 08                	jg     800d42 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	83 ec 0c             	sub    $0xc,%esp
  800d45:	50                   	push   %eax
  800d46:	6a 06                	push   $0x6
  800d48:	68 ff 27 80 00       	push   $0x8027ff
  800d4d:	6a 2a                	push   $0x2a
  800d4f:	68 1c 28 80 00       	push   $0x80281c
  800d54:	e8 88 f4 ff ff       	call   8001e1 <_panic>

00800d59 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d72:	89 df                	mov    %ebx,%edi
  800d74:	89 de                	mov    %ebx,%esi
  800d76:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7f 08                	jg     800d84 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	50                   	push   %eax
  800d88:	6a 08                	push   $0x8
  800d8a:	68 ff 27 80 00       	push   $0x8027ff
  800d8f:	6a 2a                	push   $0x2a
  800d91:	68 1c 28 80 00       	push   $0x80281c
  800d96:	e8 46 f4 ff ff       	call   8001e1 <_panic>

00800d9b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	b8 09 00 00 00       	mov    $0x9,%eax
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7f 08                	jg     800dc6 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	50                   	push   %eax
  800dca:	6a 09                	push   $0x9
  800dcc:	68 ff 27 80 00       	push   $0x8027ff
  800dd1:	6a 2a                	push   $0x2a
  800dd3:	68 1c 28 80 00       	push   $0x80281c
  800dd8:	e8 04 f4 ff ff       	call   8001e1 <_panic>

00800ddd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7f 08                	jg     800e08 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	50                   	push   %eax
  800e0c:	6a 0a                	push   $0xa
  800e0e:	68 ff 27 80 00       	push   $0x8027ff
  800e13:	6a 2a                	push   $0x2a
  800e15:	68 1c 28 80 00       	push   $0x80281c
  800e1a:	e8 c2 f3 ff ff       	call   8001e1 <_panic>

00800e1f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e30:	be 00 00 00 00       	mov    $0x0,%esi
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e58:	89 cb                	mov    %ecx,%ebx
  800e5a:	89 cf                	mov    %ecx,%edi
  800e5c:	89 ce                	mov    %ecx,%esi
  800e5e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	7f 08                	jg     800e6c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	50                   	push   %eax
  800e70:	6a 0d                	push   $0xd
  800e72:	68 ff 27 80 00       	push   $0x8027ff
  800e77:	6a 2a                	push   $0x2a
  800e79:	68 1c 28 80 00       	push   $0x80281c
  800e7e:	e8 5e f3 ff ff       	call   8001e1 <_panic>

00800e83 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e89:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e93:	89 d1                	mov    %edx,%ecx
  800e95:	89 d3                	mov    %edx,%ebx
  800e97:	89 d7                	mov    %edx,%edi
  800e99:	89 d6                	mov    %edx,%esi
  800e9b:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	57                   	push   %edi
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ead:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800eb8:	89 df                	mov    %ebx,%edi
  800eba:	89 de                	mov    %ebx,%esi
  800ebc:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ece:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed4:	b8 10 00 00 00       	mov    $0x10,%eax
  800ed9:	89 df                	mov    %ebx,%edi
  800edb:	89 de                	mov    %ebx,%esi
  800edd:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5f                   	pop    %edi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    

00800ee4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	05 00 00 00 30       	add    $0x30000000,%eax
  800eef:	c1 e8 0c             	shr    $0xc,%eax
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f04:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f13:	89 c2                	mov    %eax,%edx
  800f15:	c1 ea 16             	shr    $0x16,%edx
  800f18:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1f:	f6 c2 01             	test   $0x1,%dl
  800f22:	74 29                	je     800f4d <fd_alloc+0x42>
  800f24:	89 c2                	mov    %eax,%edx
  800f26:	c1 ea 0c             	shr    $0xc,%edx
  800f29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f30:	f6 c2 01             	test   $0x1,%dl
  800f33:	74 18                	je     800f4d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f35:	05 00 10 00 00       	add    $0x1000,%eax
  800f3a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f3f:	75 d2                	jne    800f13 <fd_alloc+0x8>
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f46:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f4b:	eb 05                	jmp    800f52 <fd_alloc+0x47>
			return 0;
  800f4d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f52:	8b 55 08             	mov    0x8(%ebp),%edx
  800f55:	89 02                	mov    %eax,(%edx)
}
  800f57:	89 c8                	mov    %ecx,%eax
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f61:	83 f8 1f             	cmp    $0x1f,%eax
  800f64:	77 30                	ja     800f96 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f66:	c1 e0 0c             	shl    $0xc,%eax
  800f69:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f6e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f74:	f6 c2 01             	test   $0x1,%dl
  800f77:	74 24                	je     800f9d <fd_lookup+0x42>
  800f79:	89 c2                	mov    %eax,%edx
  800f7b:	c1 ea 0c             	shr    $0xc,%edx
  800f7e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f85:	f6 c2 01             	test   $0x1,%dl
  800f88:	74 1a                	je     800fa4 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8d:	89 02                	mov    %eax,(%edx)
	return 0;
  800f8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    
		return -E_INVAL;
  800f96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9b:	eb f7                	jmp    800f94 <fd_lookup+0x39>
		return -E_INVAL;
  800f9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa2:	eb f0                	jmp    800f94 <fd_lookup+0x39>
  800fa4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa9:	eb e9                	jmp    800f94 <fd_lookup+0x39>

00800fab <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	53                   	push   %ebx
  800faf:	83 ec 04             	sub    $0x4,%esp
  800fb2:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fba:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800fbf:	39 13                	cmp    %edx,(%ebx)
  800fc1:	74 37                	je     800ffa <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800fc3:	83 c0 01             	add    $0x1,%eax
  800fc6:	8b 1c 85 a8 28 80 00 	mov    0x8028a8(,%eax,4),%ebx
  800fcd:	85 db                	test   %ebx,%ebx
  800fcf:	75 ee                	jne    800fbf <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fd1:	a1 04 40 80 00       	mov    0x804004,%eax
  800fd6:	8b 40 48             	mov    0x48(%eax),%eax
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	52                   	push   %edx
  800fdd:	50                   	push   %eax
  800fde:	68 2c 28 80 00       	push   $0x80282c
  800fe3:	e8 d4 f2 ff ff       	call   8002bc <cprintf>
	*dev = 0;
	return -E_INVAL;
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800ff0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff3:	89 1a                	mov    %ebx,(%edx)
}
  800ff5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff8:	c9                   	leave  
  800ff9:	c3                   	ret    
			return 0;
  800ffa:	b8 00 00 00 00       	mov    $0x0,%eax
  800fff:	eb ef                	jmp    800ff0 <dev_lookup+0x45>

00801001 <fd_close>:
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	83 ec 24             	sub    $0x24,%esp
  80100a:	8b 75 08             	mov    0x8(%ebp),%esi
  80100d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801010:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801013:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801014:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80101a:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80101d:	50                   	push   %eax
  80101e:	e8 38 ff ff ff       	call   800f5b <fd_lookup>
  801023:	89 c3                	mov    %eax,%ebx
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 05                	js     801031 <fd_close+0x30>
	    || fd != fd2)
  80102c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80102f:	74 16                	je     801047 <fd_close+0x46>
		return (must_exist ? r : 0);
  801031:	89 f8                	mov    %edi,%eax
  801033:	84 c0                	test   %al,%al
  801035:	b8 00 00 00 00       	mov    $0x0,%eax
  80103a:	0f 44 d8             	cmove  %eax,%ebx
}
  80103d:	89 d8                	mov    %ebx,%eax
  80103f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5f                   	pop    %edi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801047:	83 ec 08             	sub    $0x8,%esp
  80104a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80104d:	50                   	push   %eax
  80104e:	ff 36                	push   (%esi)
  801050:	e8 56 ff ff ff       	call   800fab <dev_lookup>
  801055:	89 c3                	mov    %eax,%ebx
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 1a                	js     801078 <fd_close+0x77>
		if (dev->dev_close)
  80105e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801061:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801064:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801069:	85 c0                	test   %eax,%eax
  80106b:	74 0b                	je     801078 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	56                   	push   %esi
  801071:	ff d0                	call   *%eax
  801073:	89 c3                	mov    %eax,%ebx
  801075:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801078:	83 ec 08             	sub    $0x8,%esp
  80107b:	56                   	push   %esi
  80107c:	6a 00                	push   $0x0
  80107e:	e8 94 fc ff ff       	call   800d17 <sys_page_unmap>
	return r;
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	eb b5                	jmp    80103d <fd_close+0x3c>

00801088 <close>:

int
close(int fdnum)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80108e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801091:	50                   	push   %eax
  801092:	ff 75 08             	push   0x8(%ebp)
  801095:	e8 c1 fe ff ff       	call   800f5b <fd_lookup>
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	85 c0                	test   %eax,%eax
  80109f:	79 02                	jns    8010a3 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    
		return fd_close(fd, 1);
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	6a 01                	push   $0x1
  8010a8:	ff 75 f4             	push   -0xc(%ebp)
  8010ab:	e8 51 ff ff ff       	call   801001 <fd_close>
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	eb ec                	jmp    8010a1 <close+0x19>

008010b5 <close_all>:

void
close_all(void)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	53                   	push   %ebx
  8010c5:	e8 be ff ff ff       	call   801088 <close>
	for (i = 0; i < MAXFD; i++)
  8010ca:	83 c3 01             	add    $0x1,%ebx
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	83 fb 20             	cmp    $0x20,%ebx
  8010d3:	75 ec                	jne    8010c1 <close_all+0xc>
}
  8010d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d8:	c9                   	leave  
  8010d9:	c3                   	ret    

008010da <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	57                   	push   %edi
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
  8010e0:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	ff 75 08             	push   0x8(%ebp)
  8010ea:	e8 6c fe ff ff       	call   800f5b <fd_lookup>
  8010ef:	89 c3                	mov    %eax,%ebx
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 7f                	js     801177 <dup+0x9d>
		return r;
	close(newfdnum);
  8010f8:	83 ec 0c             	sub    $0xc,%esp
  8010fb:	ff 75 0c             	push   0xc(%ebp)
  8010fe:	e8 85 ff ff ff       	call   801088 <close>

	newfd = INDEX2FD(newfdnum);
  801103:	8b 75 0c             	mov    0xc(%ebp),%esi
  801106:	c1 e6 0c             	shl    $0xc,%esi
  801109:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80110f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801112:	89 3c 24             	mov    %edi,(%esp)
  801115:	e8 da fd ff ff       	call   800ef4 <fd2data>
  80111a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80111c:	89 34 24             	mov    %esi,(%esp)
  80111f:	e8 d0 fd ff ff       	call   800ef4 <fd2data>
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80112a:	89 d8                	mov    %ebx,%eax
  80112c:	c1 e8 16             	shr    $0x16,%eax
  80112f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801136:	a8 01                	test   $0x1,%al
  801138:	74 11                	je     80114b <dup+0x71>
  80113a:	89 d8                	mov    %ebx,%eax
  80113c:	c1 e8 0c             	shr    $0xc,%eax
  80113f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801146:	f6 c2 01             	test   $0x1,%dl
  801149:	75 36                	jne    801181 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114b:	89 f8                	mov    %edi,%eax
  80114d:	c1 e8 0c             	shr    $0xc,%eax
  801150:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801157:	83 ec 0c             	sub    $0xc,%esp
  80115a:	25 07 0e 00 00       	and    $0xe07,%eax
  80115f:	50                   	push   %eax
  801160:	56                   	push   %esi
  801161:	6a 00                	push   $0x0
  801163:	57                   	push   %edi
  801164:	6a 00                	push   $0x0
  801166:	e8 6a fb ff ff       	call   800cd5 <sys_page_map>
  80116b:	89 c3                	mov    %eax,%ebx
  80116d:	83 c4 20             	add    $0x20,%esp
  801170:	85 c0                	test   %eax,%eax
  801172:	78 33                	js     8011a7 <dup+0xcd>
		goto err;

	return newfdnum;
  801174:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801177:	89 d8                	mov    %ebx,%eax
  801179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801181:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801188:	83 ec 0c             	sub    $0xc,%esp
  80118b:	25 07 0e 00 00       	and    $0xe07,%eax
  801190:	50                   	push   %eax
  801191:	ff 75 d4             	push   -0x2c(%ebp)
  801194:	6a 00                	push   $0x0
  801196:	53                   	push   %ebx
  801197:	6a 00                	push   $0x0
  801199:	e8 37 fb ff ff       	call   800cd5 <sys_page_map>
  80119e:	89 c3                	mov    %eax,%ebx
  8011a0:	83 c4 20             	add    $0x20,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	79 a4                	jns    80114b <dup+0x71>
	sys_page_unmap(0, newfd);
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	56                   	push   %esi
  8011ab:	6a 00                	push   $0x0
  8011ad:	e8 65 fb ff ff       	call   800d17 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011b2:	83 c4 08             	add    $0x8,%esp
  8011b5:	ff 75 d4             	push   -0x2c(%ebp)
  8011b8:	6a 00                	push   $0x0
  8011ba:	e8 58 fb ff ff       	call   800d17 <sys_page_unmap>
	return r;
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	eb b3                	jmp    801177 <dup+0x9d>

008011c4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	56                   	push   %esi
  8011c8:	53                   	push   %ebx
  8011c9:	83 ec 18             	sub    $0x18,%esp
  8011cc:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d2:	50                   	push   %eax
  8011d3:	56                   	push   %esi
  8011d4:	e8 82 fd ff ff       	call   800f5b <fd_lookup>
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 3c                	js     80121c <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	ff 33                	push   (%ebx)
  8011ec:	e8 ba fd ff ff       	call   800fab <dev_lookup>
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 24                	js     80121c <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011f8:	8b 43 08             	mov    0x8(%ebx),%eax
  8011fb:	83 e0 03             	and    $0x3,%eax
  8011fe:	83 f8 01             	cmp    $0x1,%eax
  801201:	74 20                	je     801223 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801203:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801206:	8b 40 08             	mov    0x8(%eax),%eax
  801209:	85 c0                	test   %eax,%eax
  80120b:	74 37                	je     801244 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	ff 75 10             	push   0x10(%ebp)
  801213:	ff 75 0c             	push   0xc(%ebp)
  801216:	53                   	push   %ebx
  801217:	ff d0                	call   *%eax
  801219:	83 c4 10             	add    $0x10,%esp
}
  80121c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80121f:	5b                   	pop    %ebx
  801220:	5e                   	pop    %esi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801223:	a1 04 40 80 00       	mov    0x804004,%eax
  801228:	8b 40 48             	mov    0x48(%eax),%eax
  80122b:	83 ec 04             	sub    $0x4,%esp
  80122e:	56                   	push   %esi
  80122f:	50                   	push   %eax
  801230:	68 6d 28 80 00       	push   $0x80286d
  801235:	e8 82 f0 ff ff       	call   8002bc <cprintf>
		return -E_INVAL;
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801242:	eb d8                	jmp    80121c <read+0x58>
		return -E_NOT_SUPP;
  801244:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801249:	eb d1                	jmp    80121c <read+0x58>

0080124b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	8b 7d 08             	mov    0x8(%ebp),%edi
  801257:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80125a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125f:	eb 02                	jmp    801263 <readn+0x18>
  801261:	01 c3                	add    %eax,%ebx
  801263:	39 f3                	cmp    %esi,%ebx
  801265:	73 21                	jae    801288 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801267:	83 ec 04             	sub    $0x4,%esp
  80126a:	89 f0                	mov    %esi,%eax
  80126c:	29 d8                	sub    %ebx,%eax
  80126e:	50                   	push   %eax
  80126f:	89 d8                	mov    %ebx,%eax
  801271:	03 45 0c             	add    0xc(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	57                   	push   %edi
  801276:	e8 49 ff ff ff       	call   8011c4 <read>
		if (m < 0)
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 04                	js     801286 <readn+0x3b>
			return m;
		if (m == 0)
  801282:	75 dd                	jne    801261 <readn+0x16>
  801284:	eb 02                	jmp    801288 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801286:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801288:	89 d8                	mov    %ebx,%eax
  80128a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5f                   	pop    %edi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	56                   	push   %esi
  801296:	53                   	push   %ebx
  801297:	83 ec 18             	sub    $0x18,%esp
  80129a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a0:	50                   	push   %eax
  8012a1:	53                   	push   %ebx
  8012a2:	e8 b4 fc ff ff       	call   800f5b <fd_lookup>
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 37                	js     8012e5 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ae:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	ff 36                	push   (%esi)
  8012ba:	e8 ec fc ff ff       	call   800fab <dev_lookup>
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	78 1f                	js     8012e5 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c6:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012ca:	74 20                	je     8012ec <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	74 37                	je     80130d <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012d6:	83 ec 04             	sub    $0x4,%esp
  8012d9:	ff 75 10             	push   0x10(%ebp)
  8012dc:	ff 75 0c             	push   0xc(%ebp)
  8012df:	56                   	push   %esi
  8012e0:	ff d0                	call   *%eax
  8012e2:	83 c4 10             	add    $0x10,%esp
}
  8012e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f1:	8b 40 48             	mov    0x48(%eax),%eax
  8012f4:	83 ec 04             	sub    $0x4,%esp
  8012f7:	53                   	push   %ebx
  8012f8:	50                   	push   %eax
  8012f9:	68 89 28 80 00       	push   $0x802889
  8012fe:	e8 b9 ef ff ff       	call   8002bc <cprintf>
		return -E_INVAL;
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130b:	eb d8                	jmp    8012e5 <write+0x53>
		return -E_NOT_SUPP;
  80130d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801312:	eb d1                	jmp    8012e5 <write+0x53>

00801314 <seek>:

int
seek(int fdnum, off_t offset)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131d:	50                   	push   %eax
  80131e:	ff 75 08             	push   0x8(%ebp)
  801321:	e8 35 fc ff ff       	call   800f5b <fd_lookup>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 0e                	js     80133b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80132d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801330:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801333:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801336:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	56                   	push   %esi
  801341:	53                   	push   %ebx
  801342:	83 ec 18             	sub    $0x18,%esp
  801345:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801348:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	53                   	push   %ebx
  80134d:	e8 09 fc ff ff       	call   800f5b <fd_lookup>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 34                	js     80138d <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801359:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801362:	50                   	push   %eax
  801363:	ff 36                	push   (%esi)
  801365:	e8 41 fc ff ff       	call   800fab <dev_lookup>
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 1c                	js     80138d <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801371:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801375:	74 1d                	je     801394 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801377:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137a:	8b 40 18             	mov    0x18(%eax),%eax
  80137d:	85 c0                	test   %eax,%eax
  80137f:	74 34                	je     8013b5 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	ff 75 0c             	push   0xc(%ebp)
  801387:	56                   	push   %esi
  801388:	ff d0                	call   *%eax
  80138a:	83 c4 10             	add    $0x10,%esp
}
  80138d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    
			thisenv->env_id, fdnum);
  801394:	a1 04 40 80 00       	mov    0x804004,%eax
  801399:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80139c:	83 ec 04             	sub    $0x4,%esp
  80139f:	53                   	push   %ebx
  8013a0:	50                   	push   %eax
  8013a1:	68 4c 28 80 00       	push   $0x80284c
  8013a6:	e8 11 ef ff ff       	call   8002bc <cprintf>
		return -E_INVAL;
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b3:	eb d8                	jmp    80138d <ftruncate+0x50>
		return -E_NOT_SUPP;
  8013b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ba:	eb d1                	jmp    80138d <ftruncate+0x50>

008013bc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 18             	sub    $0x18,%esp
  8013c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ca:	50                   	push   %eax
  8013cb:	ff 75 08             	push   0x8(%ebp)
  8013ce:	e8 88 fb ff ff       	call   800f5b <fd_lookup>
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 49                	js     801423 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013da:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e3:	50                   	push   %eax
  8013e4:	ff 36                	push   (%esi)
  8013e6:	e8 c0 fb ff ff       	call   800fab <dev_lookup>
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 31                	js     801423 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013f9:	74 2f                	je     80142a <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013fb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013fe:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801405:	00 00 00 
	stat->st_isdir = 0;
  801408:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80140f:	00 00 00 
	stat->st_dev = dev;
  801412:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	53                   	push   %ebx
  80141c:	56                   	push   %esi
  80141d:	ff 50 14             	call   *0x14(%eax)
  801420:	83 c4 10             	add    $0x10,%esp
}
  801423:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801426:	5b                   	pop    %ebx
  801427:	5e                   	pop    %esi
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    
		return -E_NOT_SUPP;
  80142a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80142f:	eb f2                	jmp    801423 <fstat+0x67>

00801431 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	6a 00                	push   $0x0
  80143b:	ff 75 08             	push   0x8(%ebp)
  80143e:	e8 e4 01 00 00       	call   801627 <open>
  801443:	89 c3                	mov    %eax,%ebx
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 1b                	js     801467 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	ff 75 0c             	push   0xc(%ebp)
  801452:	50                   	push   %eax
  801453:	e8 64 ff ff ff       	call   8013bc <fstat>
  801458:	89 c6                	mov    %eax,%esi
	close(fd);
  80145a:	89 1c 24             	mov    %ebx,(%esp)
  80145d:	e8 26 fc ff ff       	call   801088 <close>
	return r;
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	89 f3                	mov    %esi,%ebx
}
  801467:	89 d8                	mov    %ebx,%eax
  801469:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146c:	5b                   	pop    %ebx
  80146d:	5e                   	pop    %esi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	56                   	push   %esi
  801474:	53                   	push   %ebx
  801475:	89 c6                	mov    %eax,%esi
  801477:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801479:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801480:	74 27                	je     8014a9 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801482:	6a 07                	push   $0x7
  801484:	68 00 50 80 00       	push   $0x805000
  801489:	56                   	push   %esi
  80148a:	ff 35 00 60 80 00    	push   0x806000
  801490:	e8 d7 0c 00 00       	call   80216c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801495:	83 c4 0c             	add    $0xc,%esp
  801498:	6a 00                	push   $0x0
  80149a:	53                   	push   %ebx
  80149b:	6a 00                	push   $0x0
  80149d:	e8 63 0c 00 00       	call   802105 <ipc_recv>
}
  8014a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a5:	5b                   	pop    %ebx
  8014a6:	5e                   	pop    %esi
  8014a7:	5d                   	pop    %ebp
  8014a8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014a9:	83 ec 0c             	sub    $0xc,%esp
  8014ac:	6a 01                	push   $0x1
  8014ae:	e8 0d 0d 00 00       	call   8021c0 <ipc_find_env>
  8014b3:	a3 00 60 80 00       	mov    %eax,0x806000
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	eb c5                	jmp    801482 <fsipc+0x12>

008014bd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014db:	b8 02 00 00 00       	mov    $0x2,%eax
  8014e0:	e8 8b ff ff ff       	call   801470 <fsipc>
}
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <devfile_flush>:
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fd:	b8 06 00 00 00       	mov    $0x6,%eax
  801502:	e8 69 ff ff ff       	call   801470 <fsipc>
}
  801507:	c9                   	leave  
  801508:	c3                   	ret    

00801509 <devfile_stat>:
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	53                   	push   %ebx
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	8b 40 0c             	mov    0xc(%eax),%eax
  801519:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80151e:	ba 00 00 00 00       	mov    $0x0,%edx
  801523:	b8 05 00 00 00       	mov    $0x5,%eax
  801528:	e8 43 ff ff ff       	call   801470 <fsipc>
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 2c                	js     80155d <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	68 00 50 80 00       	push   $0x805000
  801539:	53                   	push   %ebx
  80153a:	e8 57 f3 ff ff       	call   800896 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80153f:	a1 80 50 80 00       	mov    0x805080,%eax
  801544:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80154a:	a1 84 50 80 00       	mov    0x805084,%eax
  80154f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801560:	c9                   	leave  
  801561:	c3                   	ret    

00801562 <devfile_write>:
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	83 ec 0c             	sub    $0xc,%esp
  801568:	8b 45 10             	mov    0x10(%ebp),%eax
  80156b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801570:	39 d0                	cmp    %edx,%eax
  801572:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801575:	8b 55 08             	mov    0x8(%ebp),%edx
  801578:	8b 52 0c             	mov    0xc(%edx),%edx
  80157b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801581:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801586:	50                   	push   %eax
  801587:	ff 75 0c             	push   0xc(%ebp)
  80158a:	68 08 50 80 00       	push   $0x805008
  80158f:	e8 98 f4 ff ff       	call   800a2c <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801594:	ba 00 00 00 00       	mov    $0x0,%edx
  801599:	b8 04 00 00 00       	mov    $0x4,%eax
  80159e:	e8 cd fe ff ff       	call   801470 <fsipc>
}
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <devfile_read>:
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	56                   	push   %esi
  8015a9:	53                   	push   %ebx
  8015aa:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015b8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015be:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c3:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c8:	e8 a3 fe ff ff       	call   801470 <fsipc>
  8015cd:	89 c3                	mov    %eax,%ebx
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 1f                	js     8015f2 <devfile_read+0x4d>
	assert(r <= n);
  8015d3:	39 f0                	cmp    %esi,%eax
  8015d5:	77 24                	ja     8015fb <devfile_read+0x56>
	assert(r <= PGSIZE);
  8015d7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015dc:	7f 33                	jg     801611 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015de:	83 ec 04             	sub    $0x4,%esp
  8015e1:	50                   	push   %eax
  8015e2:	68 00 50 80 00       	push   $0x805000
  8015e7:	ff 75 0c             	push   0xc(%ebp)
  8015ea:	e8 3d f4 ff ff       	call   800a2c <memmove>
	return r;
  8015ef:	83 c4 10             	add    $0x10,%esp
}
  8015f2:	89 d8                	mov    %ebx,%eax
  8015f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f7:	5b                   	pop    %ebx
  8015f8:	5e                   	pop    %esi
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    
	assert(r <= n);
  8015fb:	68 bc 28 80 00       	push   $0x8028bc
  801600:	68 c3 28 80 00       	push   $0x8028c3
  801605:	6a 7c                	push   $0x7c
  801607:	68 d8 28 80 00       	push   $0x8028d8
  80160c:	e8 d0 eb ff ff       	call   8001e1 <_panic>
	assert(r <= PGSIZE);
  801611:	68 e3 28 80 00       	push   $0x8028e3
  801616:	68 c3 28 80 00       	push   $0x8028c3
  80161b:	6a 7d                	push   $0x7d
  80161d:	68 d8 28 80 00       	push   $0x8028d8
  801622:	e8 ba eb ff ff       	call   8001e1 <_panic>

00801627 <open>:
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	56                   	push   %esi
  80162b:	53                   	push   %ebx
  80162c:	83 ec 1c             	sub    $0x1c,%esp
  80162f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801632:	56                   	push   %esi
  801633:	e8 23 f2 ff ff       	call   80085b <strlen>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801640:	7f 6c                	jg     8016ae <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	e8 bd f8 ff ff       	call   800f0b <fd_alloc>
  80164e:	89 c3                	mov    %eax,%ebx
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	85 c0                	test   %eax,%eax
  801655:	78 3c                	js     801693 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	56                   	push   %esi
  80165b:	68 00 50 80 00       	push   $0x805000
  801660:	e8 31 f2 ff ff       	call   800896 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801665:	8b 45 0c             	mov    0xc(%ebp),%eax
  801668:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80166d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801670:	b8 01 00 00 00       	mov    $0x1,%eax
  801675:	e8 f6 fd ff ff       	call   801470 <fsipc>
  80167a:	89 c3                	mov    %eax,%ebx
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 19                	js     80169c <open+0x75>
	return fd2num(fd);
  801683:	83 ec 0c             	sub    $0xc,%esp
  801686:	ff 75 f4             	push   -0xc(%ebp)
  801689:	e8 56 f8 ff ff       	call   800ee4 <fd2num>
  80168e:	89 c3                	mov    %eax,%ebx
  801690:	83 c4 10             	add    $0x10,%esp
}
  801693:	89 d8                	mov    %ebx,%eax
  801695:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801698:	5b                   	pop    %ebx
  801699:	5e                   	pop    %esi
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    
		fd_close(fd, 0);
  80169c:	83 ec 08             	sub    $0x8,%esp
  80169f:	6a 00                	push   $0x0
  8016a1:	ff 75 f4             	push   -0xc(%ebp)
  8016a4:	e8 58 f9 ff ff       	call   801001 <fd_close>
		return r;
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	eb e5                	jmp    801693 <open+0x6c>
		return -E_BAD_PATH;
  8016ae:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016b3:	eb de                	jmp    801693 <open+0x6c>

008016b5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c5:	e8 a6 fd ff ff       	call   801470 <fsipc>
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016cc:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016d0:	7f 01                	jg     8016d3 <writebuf+0x7>
  8016d2:	c3                   	ret    
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	53                   	push   %ebx
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016dc:	ff 70 04             	push   0x4(%eax)
  8016df:	8d 40 10             	lea    0x10(%eax),%eax
  8016e2:	50                   	push   %eax
  8016e3:	ff 33                	push   (%ebx)
  8016e5:	e8 a8 fb ff ff       	call   801292 <write>
		if (result > 0)
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	7e 03                	jle    8016f4 <writebuf+0x28>
			b->result += result;
  8016f1:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016f4:	39 43 04             	cmp    %eax,0x4(%ebx)
  8016f7:	74 0d                	je     801706 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801700:	0f 4f c2             	cmovg  %edx,%eax
  801703:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <putch>:

static void
putch(int ch, void *thunk)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	53                   	push   %ebx
  80170f:	83 ec 04             	sub    $0x4,%esp
  801712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801715:	8b 53 04             	mov    0x4(%ebx),%edx
  801718:	8d 42 01             	lea    0x1(%edx),%eax
  80171b:	89 43 04             	mov    %eax,0x4(%ebx)
  80171e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801721:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801725:	3d 00 01 00 00       	cmp    $0x100,%eax
  80172a:	74 05                	je     801731 <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  80172c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172f:	c9                   	leave  
  801730:	c3                   	ret    
		writebuf(b);
  801731:	89 d8                	mov    %ebx,%eax
  801733:	e8 94 ff ff ff       	call   8016cc <writebuf>
		b->idx = 0;
  801738:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  80173f:	eb eb                	jmp    80172c <putch+0x21>

00801741 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80174a:	8b 45 08             	mov    0x8(%ebp),%eax
  80174d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801753:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80175a:	00 00 00 
	b.result = 0;
  80175d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801764:	00 00 00 
	b.error = 1;
  801767:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80176e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801771:	ff 75 10             	push   0x10(%ebp)
  801774:	ff 75 0c             	push   0xc(%ebp)
  801777:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80177d:	50                   	push   %eax
  80177e:	68 0b 17 80 00       	push   $0x80170b
  801783:	e8 2b ec ff ff       	call   8003b3 <vprintfmt>
	if (b.idx > 0)
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801792:	7f 11                	jg     8017a5 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801794:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80179a:	85 c0                	test   %eax,%eax
  80179c:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017a3:	c9                   	leave  
  8017a4:	c3                   	ret    
		writebuf(&b);
  8017a5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017ab:	e8 1c ff ff ff       	call   8016cc <writebuf>
  8017b0:	eb e2                	jmp    801794 <vfprintf+0x53>

008017b2 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017b8:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017bb:	50                   	push   %eax
  8017bc:	ff 75 0c             	push   0xc(%ebp)
  8017bf:	ff 75 08             	push   0x8(%ebp)
  8017c2:	e8 7a ff ff ff       	call   801741 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    

008017c9 <printf>:

int
printf(const char *fmt, ...)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017cf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017d2:	50                   	push   %eax
  8017d3:	ff 75 08             	push   0x8(%ebp)
  8017d6:	6a 01                	push   $0x1
  8017d8:	e8 64 ff ff ff       	call   801741 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    

008017df <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8017e5:	68 ef 28 80 00       	push   $0x8028ef
  8017ea:	ff 75 0c             	push   0xc(%ebp)
  8017ed:	e8 a4 f0 ff ff       	call   800896 <strcpy>
	return 0;
}
  8017f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <devsock_close>:
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 10             	sub    $0x10,%esp
  801800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801803:	53                   	push   %ebx
  801804:	e8 f0 09 00 00       	call   8021f9 <pageref>
  801809:	89 c2                	mov    %eax,%edx
  80180b:	83 c4 10             	add    $0x10,%esp
		return 0;
  80180e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801813:	83 fa 01             	cmp    $0x1,%edx
  801816:	74 05                	je     80181d <devsock_close+0x24>
}
  801818:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80181d:	83 ec 0c             	sub    $0xc,%esp
  801820:	ff 73 0c             	push   0xc(%ebx)
  801823:	e8 b7 02 00 00       	call   801adf <nsipc_close>
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	eb eb                	jmp    801818 <devsock_close+0x1f>

0080182d <devsock_write>:
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801833:	6a 00                	push   $0x0
  801835:	ff 75 10             	push   0x10(%ebp)
  801838:	ff 75 0c             	push   0xc(%ebp)
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	ff 70 0c             	push   0xc(%eax)
  801841:	e8 79 03 00 00       	call   801bbf <nsipc_send>
}
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <devsock_read>:
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80184e:	6a 00                	push   $0x0
  801850:	ff 75 10             	push   0x10(%ebp)
  801853:	ff 75 0c             	push   0xc(%ebp)
  801856:	8b 45 08             	mov    0x8(%ebp),%eax
  801859:	ff 70 0c             	push   0xc(%eax)
  80185c:	e8 ef 02 00 00       	call   801b50 <nsipc_recv>
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <fd2sockid>:
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801869:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80186c:	52                   	push   %edx
  80186d:	50                   	push   %eax
  80186e:	e8 e8 f6 ff ff       	call   800f5b <fd_lookup>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 c0                	test   %eax,%eax
  801878:	78 10                	js     80188a <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80187a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187d:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801883:	39 08                	cmp    %ecx,(%eax)
  801885:	75 05                	jne    80188c <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801887:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    
		return -E_NOT_SUPP;
  80188c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801891:	eb f7                	jmp    80188a <fd2sockid+0x27>

00801893 <alloc_sockfd>:
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	56                   	push   %esi
  801897:	53                   	push   %ebx
  801898:	83 ec 1c             	sub    $0x1c,%esp
  80189b:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80189d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a0:	50                   	push   %eax
  8018a1:	e8 65 f6 ff ff       	call   800f0b <fd_alloc>
  8018a6:	89 c3                	mov    %eax,%ebx
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 43                	js     8018f2 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018af:	83 ec 04             	sub    $0x4,%esp
  8018b2:	68 07 04 00 00       	push   $0x407
  8018b7:	ff 75 f4             	push   -0xc(%ebp)
  8018ba:	6a 00                	push   $0x0
  8018bc:	e8 d1 f3 ff ff       	call   800c92 <sys_page_alloc>
  8018c1:	89 c3                	mov    %eax,%ebx
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	78 28                	js     8018f2 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8018ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018cd:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8018d3:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8018d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8018df:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	50                   	push   %eax
  8018e6:	e8 f9 f5 ff ff       	call   800ee4 <fd2num>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	eb 0c                	jmp    8018fe <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8018f2:	83 ec 0c             	sub    $0xc,%esp
  8018f5:	56                   	push   %esi
  8018f6:	e8 e4 01 00 00       	call   801adf <nsipc_close>
		return r;
  8018fb:	83 c4 10             	add    $0x10,%esp
}
  8018fe:	89 d8                	mov    %ebx,%eax
  801900:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801903:	5b                   	pop    %ebx
  801904:	5e                   	pop    %esi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <accept>:
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	e8 4e ff ff ff       	call   801863 <fd2sockid>
  801915:	85 c0                	test   %eax,%eax
  801917:	78 1b                	js     801934 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801919:	83 ec 04             	sub    $0x4,%esp
  80191c:	ff 75 10             	push   0x10(%ebp)
  80191f:	ff 75 0c             	push   0xc(%ebp)
  801922:	50                   	push   %eax
  801923:	e8 0e 01 00 00       	call   801a36 <nsipc_accept>
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	85 c0                	test   %eax,%eax
  80192d:	78 05                	js     801934 <accept+0x2d>
	return alloc_sockfd(r);
  80192f:	e8 5f ff ff ff       	call   801893 <alloc_sockfd>
}
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <bind>:
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	e8 1f ff ff ff       	call   801863 <fd2sockid>
  801944:	85 c0                	test   %eax,%eax
  801946:	78 12                	js     80195a <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801948:	83 ec 04             	sub    $0x4,%esp
  80194b:	ff 75 10             	push   0x10(%ebp)
  80194e:	ff 75 0c             	push   0xc(%ebp)
  801951:	50                   	push   %eax
  801952:	e8 31 01 00 00       	call   801a88 <nsipc_bind>
  801957:	83 c4 10             	add    $0x10,%esp
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <shutdown>:
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	e8 f9 fe ff ff       	call   801863 <fd2sockid>
  80196a:	85 c0                	test   %eax,%eax
  80196c:	78 0f                	js     80197d <shutdown+0x21>
	return nsipc_shutdown(r, how);
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	ff 75 0c             	push   0xc(%ebp)
  801974:	50                   	push   %eax
  801975:	e8 43 01 00 00       	call   801abd <nsipc_shutdown>
  80197a:	83 c4 10             	add    $0x10,%esp
}
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <connect>:
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801985:	8b 45 08             	mov    0x8(%ebp),%eax
  801988:	e8 d6 fe ff ff       	call   801863 <fd2sockid>
  80198d:	85 c0                	test   %eax,%eax
  80198f:	78 12                	js     8019a3 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801991:	83 ec 04             	sub    $0x4,%esp
  801994:	ff 75 10             	push   0x10(%ebp)
  801997:	ff 75 0c             	push   0xc(%ebp)
  80199a:	50                   	push   %eax
  80199b:	e8 59 01 00 00       	call   801af9 <nsipc_connect>
  8019a0:	83 c4 10             	add    $0x10,%esp
}
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <listen>:
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ae:	e8 b0 fe ff ff       	call   801863 <fd2sockid>
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 0f                	js     8019c6 <listen+0x21>
	return nsipc_listen(r, backlog);
  8019b7:	83 ec 08             	sub    $0x8,%esp
  8019ba:	ff 75 0c             	push   0xc(%ebp)
  8019bd:	50                   	push   %eax
  8019be:	e8 6b 01 00 00       	call   801b2e <nsipc_listen>
  8019c3:	83 c4 10             	add    $0x10,%esp
}
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <socket>:

int
socket(int domain, int type, int protocol)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019ce:	ff 75 10             	push   0x10(%ebp)
  8019d1:	ff 75 0c             	push   0xc(%ebp)
  8019d4:	ff 75 08             	push   0x8(%ebp)
  8019d7:	e8 41 02 00 00       	call   801c1d <nsipc_socket>
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	85 c0                	test   %eax,%eax
  8019e1:	78 05                	js     8019e8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8019e3:	e8 ab fe ff ff       	call   801893 <alloc_sockfd>
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	53                   	push   %ebx
  8019ee:	83 ec 04             	sub    $0x4,%esp
  8019f1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019f3:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8019fa:	74 26                	je     801a22 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019fc:	6a 07                	push   $0x7
  8019fe:	68 00 70 80 00       	push   $0x807000
  801a03:	53                   	push   %ebx
  801a04:	ff 35 00 80 80 00    	push   0x808000
  801a0a:	e8 5d 07 00 00       	call   80216c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a0f:	83 c4 0c             	add    $0xc,%esp
  801a12:	6a 00                	push   $0x0
  801a14:	6a 00                	push   $0x0
  801a16:	6a 00                	push   $0x0
  801a18:	e8 e8 06 00 00       	call   802105 <ipc_recv>
}
  801a1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	6a 02                	push   $0x2
  801a27:	e8 94 07 00 00       	call   8021c0 <ipc_find_env>
  801a2c:	a3 00 80 80 00       	mov    %eax,0x808000
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	eb c6                	jmp    8019fc <nsipc+0x12>

00801a36 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	56                   	push   %esi
  801a3a:	53                   	push   %ebx
  801a3b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a46:	8b 06                	mov    (%esi),%eax
  801a48:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a4d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a52:	e8 93 ff ff ff       	call   8019ea <nsipc>
  801a57:	89 c3                	mov    %eax,%ebx
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	79 09                	jns    801a66 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801a5d:	89 d8                	mov    %ebx,%eax
  801a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a66:	83 ec 04             	sub    $0x4,%esp
  801a69:	ff 35 10 70 80 00    	push   0x807010
  801a6f:	68 00 70 80 00       	push   $0x807000
  801a74:	ff 75 0c             	push   0xc(%ebp)
  801a77:	e8 b0 ef ff ff       	call   800a2c <memmove>
		*addrlen = ret->ret_addrlen;
  801a7c:	a1 10 70 80 00       	mov    0x807010,%eax
  801a81:	89 06                	mov    %eax,(%esi)
  801a83:	83 c4 10             	add    $0x10,%esp
	return r;
  801a86:	eb d5                	jmp    801a5d <nsipc_accept+0x27>

00801a88 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 08             	sub    $0x8,%esp
  801a8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a9a:	53                   	push   %ebx
  801a9b:	ff 75 0c             	push   0xc(%ebp)
  801a9e:	68 04 70 80 00       	push   $0x807004
  801aa3:	e8 84 ef ff ff       	call   800a2c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801aa8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801aae:	b8 02 00 00 00       	mov    $0x2,%eax
  801ab3:	e8 32 ff ff ff       	call   8019ea <nsipc>
}
  801ab8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abb:	c9                   	leave  
  801abc:	c3                   	ret    

00801abd <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801acb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ace:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ad3:	b8 03 00 00 00       	mov    $0x3,%eax
  801ad8:	e8 0d ff ff ff       	call   8019ea <nsipc>
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <nsipc_close>:

int
nsipc_close(int s)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801aed:	b8 04 00 00 00       	mov    $0x4,%eax
  801af2:	e8 f3 fe ff ff       	call   8019ea <nsipc>
}
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	53                   	push   %ebx
  801afd:	83 ec 08             	sub    $0x8,%esp
  801b00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b0b:	53                   	push   %ebx
  801b0c:	ff 75 0c             	push   0xc(%ebp)
  801b0f:	68 04 70 80 00       	push   $0x807004
  801b14:	e8 13 ef ff ff       	call   800a2c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b19:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801b1f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b24:	e8 c1 fe ff ff       	call   8019ea <nsipc>
}
  801b29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
  801b37:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801b44:	b8 06 00 00 00       	mov    $0x6,%eax
  801b49:	e8 9c fe ff ff       	call   8019ea <nsipc>
}
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
  801b55:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b58:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801b60:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801b66:	8b 45 14             	mov    0x14(%ebp),%eax
  801b69:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b6e:	b8 07 00 00 00       	mov    $0x7,%eax
  801b73:	e8 72 fe ff ff       	call   8019ea <nsipc>
  801b78:	89 c3                	mov    %eax,%ebx
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 22                	js     801ba0 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801b7e:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801b83:	39 c6                	cmp    %eax,%esi
  801b85:	0f 4e c6             	cmovle %esi,%eax
  801b88:	39 c3                	cmp    %eax,%ebx
  801b8a:	7f 1d                	jg     801ba9 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b8c:	83 ec 04             	sub    $0x4,%esp
  801b8f:	53                   	push   %ebx
  801b90:	68 00 70 80 00       	push   $0x807000
  801b95:	ff 75 0c             	push   0xc(%ebp)
  801b98:	e8 8f ee ff ff       	call   800a2c <memmove>
  801b9d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ba0:	89 d8                	mov    %ebx,%eax
  801ba2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba5:	5b                   	pop    %ebx
  801ba6:	5e                   	pop    %esi
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801ba9:	68 fb 28 80 00       	push   $0x8028fb
  801bae:	68 c3 28 80 00       	push   $0x8028c3
  801bb3:	6a 62                	push   $0x62
  801bb5:	68 10 29 80 00       	push   $0x802910
  801bba:	e8 22 e6 ff ff       	call   8001e1 <_panic>

00801bbf <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 04             	sub    $0x4,%esp
  801bc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801bd1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801bd7:	7f 2e                	jg     801c07 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801bd9:	83 ec 04             	sub    $0x4,%esp
  801bdc:	53                   	push   %ebx
  801bdd:	ff 75 0c             	push   0xc(%ebp)
  801be0:	68 0c 70 80 00       	push   $0x80700c
  801be5:	e8 42 ee ff ff       	call   800a2c <memmove>
	nsipcbuf.send.req_size = size;
  801bea:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801bf0:	8b 45 14             	mov    0x14(%ebp),%eax
  801bf3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801bf8:	b8 08 00 00 00       	mov    $0x8,%eax
  801bfd:	e8 e8 fd ff ff       	call   8019ea <nsipc>
}
  801c02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    
	assert(size < 1600);
  801c07:	68 1c 29 80 00       	push   $0x80291c
  801c0c:	68 c3 28 80 00       	push   $0x8028c3
  801c11:	6a 6d                	push   $0x6d
  801c13:	68 10 29 80 00       	push   $0x802910
  801c18:	e8 c4 e5 ff ff       	call   8001e1 <_panic>

00801c1d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c23:	8b 45 08             	mov    0x8(%ebp),%eax
  801c26:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2e:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801c33:	8b 45 10             	mov    0x10(%ebp),%eax
  801c36:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801c3b:	b8 09 00 00 00       	mov    $0x9,%eax
  801c40:	e8 a5 fd ff ff       	call   8019ea <nsipc>
}
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	56                   	push   %esi
  801c4b:	53                   	push   %ebx
  801c4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	ff 75 08             	push   0x8(%ebp)
  801c55:	e8 9a f2 ff ff       	call   800ef4 <fd2data>
  801c5a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c5c:	83 c4 08             	add    $0x8,%esp
  801c5f:	68 28 29 80 00       	push   $0x802928
  801c64:	53                   	push   %ebx
  801c65:	e8 2c ec ff ff       	call   800896 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c6a:	8b 46 04             	mov    0x4(%esi),%eax
  801c6d:	2b 06                	sub    (%esi),%eax
  801c6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c75:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c7c:	00 00 00 
	stat->st_dev = &devpipe;
  801c7f:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801c86:	30 80 00 
	return 0;
}
  801c89:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c91:	5b                   	pop    %ebx
  801c92:	5e                   	pop    %esi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	53                   	push   %ebx
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c9f:	53                   	push   %ebx
  801ca0:	6a 00                	push   $0x0
  801ca2:	e8 70 f0 ff ff       	call   800d17 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ca7:	89 1c 24             	mov    %ebx,(%esp)
  801caa:	e8 45 f2 ff ff       	call   800ef4 <fd2data>
  801caf:	83 c4 08             	add    $0x8,%esp
  801cb2:	50                   	push   %eax
  801cb3:	6a 00                	push   $0x0
  801cb5:	e8 5d f0 ff ff       	call   800d17 <sys_page_unmap>
}
  801cba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <_pipeisclosed>:
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	57                   	push   %edi
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 1c             	sub    $0x1c,%esp
  801cc8:	89 c7                	mov    %eax,%edi
  801cca:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ccc:	a1 04 40 80 00       	mov    0x804004,%eax
  801cd1:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cd4:	83 ec 0c             	sub    $0xc,%esp
  801cd7:	57                   	push   %edi
  801cd8:	e8 1c 05 00 00       	call   8021f9 <pageref>
  801cdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ce0:	89 34 24             	mov    %esi,(%esp)
  801ce3:	e8 11 05 00 00       	call   8021f9 <pageref>
		nn = thisenv->env_runs;
  801ce8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cee:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	39 cb                	cmp    %ecx,%ebx
  801cf6:	74 1b                	je     801d13 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801cf8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cfb:	75 cf                	jne    801ccc <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cfd:	8b 42 58             	mov    0x58(%edx),%eax
  801d00:	6a 01                	push   $0x1
  801d02:	50                   	push   %eax
  801d03:	53                   	push   %ebx
  801d04:	68 2f 29 80 00       	push   $0x80292f
  801d09:	e8 ae e5 ff ff       	call   8002bc <cprintf>
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	eb b9                	jmp    801ccc <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d13:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d16:	0f 94 c0             	sete   %al
  801d19:	0f b6 c0             	movzbl %al,%eax
}
  801d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5f                   	pop    %edi
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    

00801d24 <devpipe_write>:
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	57                   	push   %edi
  801d28:	56                   	push   %esi
  801d29:	53                   	push   %ebx
  801d2a:	83 ec 28             	sub    $0x28,%esp
  801d2d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d30:	56                   	push   %esi
  801d31:	e8 be f1 ff ff       	call   800ef4 <fd2data>
  801d36:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	bf 00 00 00 00       	mov    $0x0,%edi
  801d40:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d43:	75 09                	jne    801d4e <devpipe_write+0x2a>
	return i;
  801d45:	89 f8                	mov    %edi,%eax
  801d47:	eb 23                	jmp    801d6c <devpipe_write+0x48>
			sys_yield();
  801d49:	e8 25 ef ff ff       	call   800c73 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d4e:	8b 43 04             	mov    0x4(%ebx),%eax
  801d51:	8b 0b                	mov    (%ebx),%ecx
  801d53:	8d 51 20             	lea    0x20(%ecx),%edx
  801d56:	39 d0                	cmp    %edx,%eax
  801d58:	72 1a                	jb     801d74 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801d5a:	89 da                	mov    %ebx,%edx
  801d5c:	89 f0                	mov    %esi,%eax
  801d5e:	e8 5c ff ff ff       	call   801cbf <_pipeisclosed>
  801d63:	85 c0                	test   %eax,%eax
  801d65:	74 e2                	je     801d49 <devpipe_write+0x25>
				return 0;
  801d67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6f:	5b                   	pop    %ebx
  801d70:	5e                   	pop    %esi
  801d71:	5f                   	pop    %edi
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d77:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d7b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d7e:	89 c2                	mov    %eax,%edx
  801d80:	c1 fa 1f             	sar    $0x1f,%edx
  801d83:	89 d1                	mov    %edx,%ecx
  801d85:	c1 e9 1b             	shr    $0x1b,%ecx
  801d88:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d8b:	83 e2 1f             	and    $0x1f,%edx
  801d8e:	29 ca                	sub    %ecx,%edx
  801d90:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d94:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d98:	83 c0 01             	add    $0x1,%eax
  801d9b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d9e:	83 c7 01             	add    $0x1,%edi
  801da1:	eb 9d                	jmp    801d40 <devpipe_write+0x1c>

00801da3 <devpipe_read>:
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	57                   	push   %edi
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	83 ec 18             	sub    $0x18,%esp
  801dac:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801daf:	57                   	push   %edi
  801db0:	e8 3f f1 ff ff       	call   800ef4 <fd2data>
  801db5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	be 00 00 00 00       	mov    $0x0,%esi
  801dbf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc2:	75 13                	jne    801dd7 <devpipe_read+0x34>
	return i;
  801dc4:	89 f0                	mov    %esi,%eax
  801dc6:	eb 02                	jmp    801dca <devpipe_read+0x27>
				return i;
  801dc8:	89 f0                	mov    %esi,%eax
}
  801dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5f                   	pop    %edi
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    
			sys_yield();
  801dd2:	e8 9c ee ff ff       	call   800c73 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801dd7:	8b 03                	mov    (%ebx),%eax
  801dd9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ddc:	75 18                	jne    801df6 <devpipe_read+0x53>
			if (i > 0)
  801dde:	85 f6                	test   %esi,%esi
  801de0:	75 e6                	jne    801dc8 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801de2:	89 da                	mov    %ebx,%edx
  801de4:	89 f8                	mov    %edi,%eax
  801de6:	e8 d4 fe ff ff       	call   801cbf <_pipeisclosed>
  801deb:	85 c0                	test   %eax,%eax
  801ded:	74 e3                	je     801dd2 <devpipe_read+0x2f>
				return 0;
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
  801df4:	eb d4                	jmp    801dca <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801df6:	99                   	cltd   
  801df7:	c1 ea 1b             	shr    $0x1b,%edx
  801dfa:	01 d0                	add    %edx,%eax
  801dfc:	83 e0 1f             	and    $0x1f,%eax
  801dff:	29 d0                	sub    %edx,%eax
  801e01:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e09:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e0c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e0f:	83 c6 01             	add    $0x1,%esi
  801e12:	eb ab                	jmp    801dbf <devpipe_read+0x1c>

00801e14 <pipe>:
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	56                   	push   %esi
  801e18:	53                   	push   %ebx
  801e19:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1f:	50                   	push   %eax
  801e20:	e8 e6 f0 ff ff       	call   800f0b <fd_alloc>
  801e25:	89 c3                	mov    %eax,%ebx
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	0f 88 23 01 00 00    	js     801f55 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e32:	83 ec 04             	sub    $0x4,%esp
  801e35:	68 07 04 00 00       	push   $0x407
  801e3a:	ff 75 f4             	push   -0xc(%ebp)
  801e3d:	6a 00                	push   $0x0
  801e3f:	e8 4e ee ff ff       	call   800c92 <sys_page_alloc>
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	0f 88 04 01 00 00    	js     801f55 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801e51:	83 ec 0c             	sub    $0xc,%esp
  801e54:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e57:	50                   	push   %eax
  801e58:	e8 ae f0 ff ff       	call   800f0b <fd_alloc>
  801e5d:	89 c3                	mov    %eax,%ebx
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	85 c0                	test   %eax,%eax
  801e64:	0f 88 db 00 00 00    	js     801f45 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6a:	83 ec 04             	sub    $0x4,%esp
  801e6d:	68 07 04 00 00       	push   $0x407
  801e72:	ff 75 f0             	push   -0x10(%ebp)
  801e75:	6a 00                	push   $0x0
  801e77:	e8 16 ee ff ff       	call   800c92 <sys_page_alloc>
  801e7c:	89 c3                	mov    %eax,%ebx
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	85 c0                	test   %eax,%eax
  801e83:	0f 88 bc 00 00 00    	js     801f45 <pipe+0x131>
	va = fd2data(fd0);
  801e89:	83 ec 0c             	sub    $0xc,%esp
  801e8c:	ff 75 f4             	push   -0xc(%ebp)
  801e8f:	e8 60 f0 ff ff       	call   800ef4 <fd2data>
  801e94:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e96:	83 c4 0c             	add    $0xc,%esp
  801e99:	68 07 04 00 00       	push   $0x407
  801e9e:	50                   	push   %eax
  801e9f:	6a 00                	push   $0x0
  801ea1:	e8 ec ed ff ff       	call   800c92 <sys_page_alloc>
  801ea6:	89 c3                	mov    %eax,%ebx
  801ea8:	83 c4 10             	add    $0x10,%esp
  801eab:	85 c0                	test   %eax,%eax
  801ead:	0f 88 82 00 00 00    	js     801f35 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb3:	83 ec 0c             	sub    $0xc,%esp
  801eb6:	ff 75 f0             	push   -0x10(%ebp)
  801eb9:	e8 36 f0 ff ff       	call   800ef4 <fd2data>
  801ebe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ec5:	50                   	push   %eax
  801ec6:	6a 00                	push   $0x0
  801ec8:	56                   	push   %esi
  801ec9:	6a 00                	push   $0x0
  801ecb:	e8 05 ee ff ff       	call   800cd5 <sys_page_map>
  801ed0:	89 c3                	mov    %eax,%ebx
  801ed2:	83 c4 20             	add    $0x20,%esp
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	78 4e                	js     801f27 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801ed9:	a1 40 30 80 00       	mov    0x803040,%eax
  801ede:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ee1:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ee3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ee6:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801eed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ef0:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ef2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ef5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801efc:	83 ec 0c             	sub    $0xc,%esp
  801eff:	ff 75 f4             	push   -0xc(%ebp)
  801f02:	e8 dd ef ff ff       	call   800ee4 <fd2num>
  801f07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f0a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f0c:	83 c4 04             	add    $0x4,%esp
  801f0f:	ff 75 f0             	push   -0x10(%ebp)
  801f12:	e8 cd ef ff ff       	call   800ee4 <fd2num>
  801f17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f1a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f25:	eb 2e                	jmp    801f55 <pipe+0x141>
	sys_page_unmap(0, va);
  801f27:	83 ec 08             	sub    $0x8,%esp
  801f2a:	56                   	push   %esi
  801f2b:	6a 00                	push   $0x0
  801f2d:	e8 e5 ed ff ff       	call   800d17 <sys_page_unmap>
  801f32:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f35:	83 ec 08             	sub    $0x8,%esp
  801f38:	ff 75 f0             	push   -0x10(%ebp)
  801f3b:	6a 00                	push   $0x0
  801f3d:	e8 d5 ed ff ff       	call   800d17 <sys_page_unmap>
  801f42:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f45:	83 ec 08             	sub    $0x8,%esp
  801f48:	ff 75 f4             	push   -0xc(%ebp)
  801f4b:	6a 00                	push   $0x0
  801f4d:	e8 c5 ed ff ff       	call   800d17 <sys_page_unmap>
  801f52:	83 c4 10             	add    $0x10,%esp
}
  801f55:	89 d8                	mov    %ebx,%eax
  801f57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f5a:	5b                   	pop    %ebx
  801f5b:	5e                   	pop    %esi
  801f5c:	5d                   	pop    %ebp
  801f5d:	c3                   	ret    

00801f5e <pipeisclosed>:
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f67:	50                   	push   %eax
  801f68:	ff 75 08             	push   0x8(%ebp)
  801f6b:	e8 eb ef ff ff       	call   800f5b <fd_lookup>
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 18                	js     801f8f <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801f77:	83 ec 0c             	sub    $0xc,%esp
  801f7a:	ff 75 f4             	push   -0xc(%ebp)
  801f7d:	e8 72 ef ff ff       	call   800ef4 <fd2data>
  801f82:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f87:	e8 33 fd ff ff       	call   801cbf <_pipeisclosed>
  801f8c:	83 c4 10             	add    $0x10,%esp
}
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801f91:	b8 00 00 00 00       	mov    $0x0,%eax
  801f96:	c3                   	ret    

00801f97 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f9d:	68 47 29 80 00       	push   $0x802947
  801fa2:	ff 75 0c             	push   0xc(%ebp)
  801fa5:	e8 ec e8 ff ff       	call   800896 <strcpy>
	return 0;
}
  801faa:	b8 00 00 00 00       	mov    $0x0,%eax
  801faf:	c9                   	leave  
  801fb0:	c3                   	ret    

00801fb1 <devcons_write>:
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	57                   	push   %edi
  801fb5:	56                   	push   %esi
  801fb6:	53                   	push   %ebx
  801fb7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fbd:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fc2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fc8:	eb 2e                	jmp    801ff8 <devcons_write+0x47>
		m = n - tot;
  801fca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fcd:	29 f3                	sub    %esi,%ebx
  801fcf:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801fd4:	39 c3                	cmp    %eax,%ebx
  801fd6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fd9:	83 ec 04             	sub    $0x4,%esp
  801fdc:	53                   	push   %ebx
  801fdd:	89 f0                	mov    %esi,%eax
  801fdf:	03 45 0c             	add    0xc(%ebp),%eax
  801fe2:	50                   	push   %eax
  801fe3:	57                   	push   %edi
  801fe4:	e8 43 ea ff ff       	call   800a2c <memmove>
		sys_cputs(buf, m);
  801fe9:	83 c4 08             	add    $0x8,%esp
  801fec:	53                   	push   %ebx
  801fed:	57                   	push   %edi
  801fee:	e8 e3 eb ff ff       	call   800bd6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ff3:	01 de                	add    %ebx,%esi
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ffb:	72 cd                	jb     801fca <devcons_write+0x19>
}
  801ffd:	89 f0                	mov    %esi,%eax
  801fff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802002:	5b                   	pop    %ebx
  802003:	5e                   	pop    %esi
  802004:	5f                   	pop    %edi
  802005:	5d                   	pop    %ebp
  802006:	c3                   	ret    

00802007 <devcons_read>:
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	83 ec 08             	sub    $0x8,%esp
  80200d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802012:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802016:	75 07                	jne    80201f <devcons_read+0x18>
  802018:	eb 1f                	jmp    802039 <devcons_read+0x32>
		sys_yield();
  80201a:	e8 54 ec ff ff       	call   800c73 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80201f:	e8 d0 eb ff ff       	call   800bf4 <sys_cgetc>
  802024:	85 c0                	test   %eax,%eax
  802026:	74 f2                	je     80201a <devcons_read+0x13>
	if (c < 0)
  802028:	78 0f                	js     802039 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80202a:	83 f8 04             	cmp    $0x4,%eax
  80202d:	74 0c                	je     80203b <devcons_read+0x34>
	*(char*)vbuf = c;
  80202f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802032:	88 02                	mov    %al,(%edx)
	return 1;
  802034:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802039:	c9                   	leave  
  80203a:	c3                   	ret    
		return 0;
  80203b:	b8 00 00 00 00       	mov    $0x0,%eax
  802040:	eb f7                	jmp    802039 <devcons_read+0x32>

00802042 <cputchar>:
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802048:	8b 45 08             	mov    0x8(%ebp),%eax
  80204b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80204e:	6a 01                	push   $0x1
  802050:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802053:	50                   	push   %eax
  802054:	e8 7d eb ff ff       	call   800bd6 <sys_cputs>
}
  802059:	83 c4 10             	add    $0x10,%esp
  80205c:	c9                   	leave  
  80205d:	c3                   	ret    

0080205e <getchar>:
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802064:	6a 01                	push   $0x1
  802066:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802069:	50                   	push   %eax
  80206a:	6a 00                	push   $0x0
  80206c:	e8 53 f1 ff ff       	call   8011c4 <read>
	if (r < 0)
  802071:	83 c4 10             	add    $0x10,%esp
  802074:	85 c0                	test   %eax,%eax
  802076:	78 06                	js     80207e <getchar+0x20>
	if (r < 1)
  802078:	74 06                	je     802080 <getchar+0x22>
	return c;
  80207a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80207e:	c9                   	leave  
  80207f:	c3                   	ret    
		return -E_EOF;
  802080:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802085:	eb f7                	jmp    80207e <getchar+0x20>

00802087 <iscons>:
{
  802087:	55                   	push   %ebp
  802088:	89 e5                	mov    %esp,%ebp
  80208a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80208d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802090:	50                   	push   %eax
  802091:	ff 75 08             	push   0x8(%ebp)
  802094:	e8 c2 ee ff ff       	call   800f5b <fd_lookup>
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	85 c0                	test   %eax,%eax
  80209e:	78 11                	js     8020b1 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8020a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a3:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8020a9:	39 10                	cmp    %edx,(%eax)
  8020ab:	0f 94 c0             	sete   %al
  8020ae:	0f b6 c0             	movzbl %al,%eax
}
  8020b1:	c9                   	leave  
  8020b2:	c3                   	ret    

008020b3 <opencons>:
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020bc:	50                   	push   %eax
  8020bd:	e8 49 ee ff ff       	call   800f0b <fd_alloc>
  8020c2:	83 c4 10             	add    $0x10,%esp
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	78 3a                	js     802103 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020c9:	83 ec 04             	sub    $0x4,%esp
  8020cc:	68 07 04 00 00       	push   $0x407
  8020d1:	ff 75 f4             	push   -0xc(%ebp)
  8020d4:	6a 00                	push   $0x0
  8020d6:	e8 b7 eb ff ff       	call   800c92 <sys_page_alloc>
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	78 21                	js     802103 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8020e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e5:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8020eb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020f7:	83 ec 0c             	sub    $0xc,%esp
  8020fa:	50                   	push   %eax
  8020fb:	e8 e4 ed ff ff       	call   800ee4 <fd2num>
  802100:	83 c4 10             	add    $0x10,%esp
}
  802103:	c9                   	leave  
  802104:	c3                   	ret    

00802105 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	56                   	push   %esi
  802109:	53                   	push   %ebx
  80210a:	8b 75 08             	mov    0x8(%ebp),%esi
  80210d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802110:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802113:	85 c0                	test   %eax,%eax
  802115:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80211a:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80211d:	83 ec 0c             	sub    $0xc,%esp
  802120:	50                   	push   %eax
  802121:	e8 1c ed ff ff       	call   800e42 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	85 f6                	test   %esi,%esi
  80212b:	74 14                	je     802141 <ipc_recv+0x3c>
  80212d:	ba 00 00 00 00       	mov    $0x0,%edx
  802132:	85 c0                	test   %eax,%eax
  802134:	78 09                	js     80213f <ipc_recv+0x3a>
  802136:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80213c:	8b 52 74             	mov    0x74(%edx),%edx
  80213f:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802141:	85 db                	test   %ebx,%ebx
  802143:	74 14                	je     802159 <ipc_recv+0x54>
  802145:	ba 00 00 00 00       	mov    $0x0,%edx
  80214a:	85 c0                	test   %eax,%eax
  80214c:	78 09                	js     802157 <ipc_recv+0x52>
  80214e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802154:	8b 52 78             	mov    0x78(%edx),%edx
  802157:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802159:	85 c0                	test   %eax,%eax
  80215b:	78 08                	js     802165 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  80215d:	a1 04 40 80 00       	mov    0x804004,%eax
  802162:	8b 40 70             	mov    0x70(%eax),%eax
}
  802165:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    

0080216c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	57                   	push   %edi
  802170:	56                   	push   %esi
  802171:	53                   	push   %ebx
  802172:	83 ec 0c             	sub    $0xc,%esp
  802175:	8b 7d 08             	mov    0x8(%ebp),%edi
  802178:	8b 75 0c             	mov    0xc(%ebp),%esi
  80217b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80217e:	85 db                	test   %ebx,%ebx
  802180:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802185:	0f 44 d8             	cmove  %eax,%ebx
  802188:	eb 05                	jmp    80218f <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80218a:	e8 e4 ea ff ff       	call   800c73 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80218f:	ff 75 14             	push   0x14(%ebp)
  802192:	53                   	push   %ebx
  802193:	56                   	push   %esi
  802194:	57                   	push   %edi
  802195:	e8 85 ec ff ff       	call   800e1f <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80219a:	83 c4 10             	add    $0x10,%esp
  80219d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021a0:	74 e8                	je     80218a <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	78 08                	js     8021ae <ipc_send+0x42>
	}while (r<0);

}
  8021a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a9:	5b                   	pop    %ebx
  8021aa:	5e                   	pop    %esi
  8021ab:	5f                   	pop    %edi
  8021ac:	5d                   	pop    %ebp
  8021ad:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8021ae:	50                   	push   %eax
  8021af:	68 53 29 80 00       	push   $0x802953
  8021b4:	6a 3d                	push   $0x3d
  8021b6:	68 67 29 80 00       	push   $0x802967
  8021bb:	e8 21 e0 ff ff       	call   8001e1 <_panic>

008021c0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021c6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021cb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021ce:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021d4:	8b 52 50             	mov    0x50(%edx),%edx
  8021d7:	39 ca                	cmp    %ecx,%edx
  8021d9:	74 11                	je     8021ec <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8021db:	83 c0 01             	add    $0x1,%eax
  8021de:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021e3:	75 e6                	jne    8021cb <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8021e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ea:	eb 0b                	jmp    8021f7 <ipc_find_env+0x37>
			return envs[i].env_id;
  8021ec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021f4:	8b 40 48             	mov    0x48(%eax),%eax
}
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    

008021f9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ff:	89 c2                	mov    %eax,%edx
  802201:	c1 ea 16             	shr    $0x16,%edx
  802204:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80220b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802210:	f6 c1 01             	test   $0x1,%cl
  802213:	74 1c                	je     802231 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802215:	c1 e8 0c             	shr    $0xc,%eax
  802218:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80221f:	a8 01                	test   $0x1,%al
  802221:	74 0e                	je     802231 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802223:	c1 e8 0c             	shr    $0xc,%eax
  802226:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80222d:	ef 
  80222e:	0f b7 d2             	movzwl %dx,%edx
}
  802231:	89 d0                	mov    %edx,%eax
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    
  802235:	66 90                	xchg   %ax,%ax
  802237:	66 90                	xchg   %ax,%ax
  802239:	66 90                	xchg   %ax,%ax
  80223b:	66 90                	xchg   %ax,%ax
  80223d:	66 90                	xchg   %ax,%ax
  80223f:	90                   	nop

00802240 <__udivdi3>:
  802240:	f3 0f 1e fb          	endbr32 
  802244:	55                   	push   %ebp
  802245:	57                   	push   %edi
  802246:	56                   	push   %esi
  802247:	53                   	push   %ebx
  802248:	83 ec 1c             	sub    $0x1c,%esp
  80224b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80224f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802253:	8b 74 24 34          	mov    0x34(%esp),%esi
  802257:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80225b:	85 c0                	test   %eax,%eax
  80225d:	75 19                	jne    802278 <__udivdi3+0x38>
  80225f:	39 f3                	cmp    %esi,%ebx
  802261:	76 4d                	jbe    8022b0 <__udivdi3+0x70>
  802263:	31 ff                	xor    %edi,%edi
  802265:	89 e8                	mov    %ebp,%eax
  802267:	89 f2                	mov    %esi,%edx
  802269:	f7 f3                	div    %ebx
  80226b:	89 fa                	mov    %edi,%edx
  80226d:	83 c4 1c             	add    $0x1c,%esp
  802270:	5b                   	pop    %ebx
  802271:	5e                   	pop    %esi
  802272:	5f                   	pop    %edi
  802273:	5d                   	pop    %ebp
  802274:	c3                   	ret    
  802275:	8d 76 00             	lea    0x0(%esi),%esi
  802278:	39 f0                	cmp    %esi,%eax
  80227a:	76 14                	jbe    802290 <__udivdi3+0x50>
  80227c:	31 ff                	xor    %edi,%edi
  80227e:	31 c0                	xor    %eax,%eax
  802280:	89 fa                	mov    %edi,%edx
  802282:	83 c4 1c             	add    $0x1c,%esp
  802285:	5b                   	pop    %ebx
  802286:	5e                   	pop    %esi
  802287:	5f                   	pop    %edi
  802288:	5d                   	pop    %ebp
  802289:	c3                   	ret    
  80228a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802290:	0f bd f8             	bsr    %eax,%edi
  802293:	83 f7 1f             	xor    $0x1f,%edi
  802296:	75 48                	jne    8022e0 <__udivdi3+0xa0>
  802298:	39 f0                	cmp    %esi,%eax
  80229a:	72 06                	jb     8022a2 <__udivdi3+0x62>
  80229c:	31 c0                	xor    %eax,%eax
  80229e:	39 eb                	cmp    %ebp,%ebx
  8022a0:	77 de                	ja     802280 <__udivdi3+0x40>
  8022a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a7:	eb d7                	jmp    802280 <__udivdi3+0x40>
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	89 d9                	mov    %ebx,%ecx
  8022b2:	85 db                	test   %ebx,%ebx
  8022b4:	75 0b                	jne    8022c1 <__udivdi3+0x81>
  8022b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	f7 f3                	div    %ebx
  8022bf:	89 c1                	mov    %eax,%ecx
  8022c1:	31 d2                	xor    %edx,%edx
  8022c3:	89 f0                	mov    %esi,%eax
  8022c5:	f7 f1                	div    %ecx
  8022c7:	89 c6                	mov    %eax,%esi
  8022c9:	89 e8                	mov    %ebp,%eax
  8022cb:	89 f7                	mov    %esi,%edi
  8022cd:	f7 f1                	div    %ecx
  8022cf:	89 fa                	mov    %edi,%edx
  8022d1:	83 c4 1c             	add    $0x1c,%esp
  8022d4:	5b                   	pop    %ebx
  8022d5:	5e                   	pop    %esi
  8022d6:	5f                   	pop    %edi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	89 f9                	mov    %edi,%ecx
  8022e2:	ba 20 00 00 00       	mov    $0x20,%edx
  8022e7:	29 fa                	sub    %edi,%edx
  8022e9:	d3 e0                	shl    %cl,%eax
  8022eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022ef:	89 d1                	mov    %edx,%ecx
  8022f1:	89 d8                	mov    %ebx,%eax
  8022f3:	d3 e8                	shr    %cl,%eax
  8022f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022f9:	09 c1                	or     %eax,%ecx
  8022fb:	89 f0                	mov    %esi,%eax
  8022fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802301:	89 f9                	mov    %edi,%ecx
  802303:	d3 e3                	shl    %cl,%ebx
  802305:	89 d1                	mov    %edx,%ecx
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 f9                	mov    %edi,%ecx
  80230b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80230f:	89 eb                	mov    %ebp,%ebx
  802311:	d3 e6                	shl    %cl,%esi
  802313:	89 d1                	mov    %edx,%ecx
  802315:	d3 eb                	shr    %cl,%ebx
  802317:	09 f3                	or     %esi,%ebx
  802319:	89 c6                	mov    %eax,%esi
  80231b:	89 f2                	mov    %esi,%edx
  80231d:	89 d8                	mov    %ebx,%eax
  80231f:	f7 74 24 08          	divl   0x8(%esp)
  802323:	89 d6                	mov    %edx,%esi
  802325:	89 c3                	mov    %eax,%ebx
  802327:	f7 64 24 0c          	mull   0xc(%esp)
  80232b:	39 d6                	cmp    %edx,%esi
  80232d:	72 19                	jb     802348 <__udivdi3+0x108>
  80232f:	89 f9                	mov    %edi,%ecx
  802331:	d3 e5                	shl    %cl,%ebp
  802333:	39 c5                	cmp    %eax,%ebp
  802335:	73 04                	jae    80233b <__udivdi3+0xfb>
  802337:	39 d6                	cmp    %edx,%esi
  802339:	74 0d                	je     802348 <__udivdi3+0x108>
  80233b:	89 d8                	mov    %ebx,%eax
  80233d:	31 ff                	xor    %edi,%edi
  80233f:	e9 3c ff ff ff       	jmp    802280 <__udivdi3+0x40>
  802344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802348:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80234b:	31 ff                	xor    %edi,%edi
  80234d:	e9 2e ff ff ff       	jmp    802280 <__udivdi3+0x40>
  802352:	66 90                	xchg   %ax,%ax
  802354:	66 90                	xchg   %ax,%ax
  802356:	66 90                	xchg   %ax,%ax
  802358:	66 90                	xchg   %ax,%ax
  80235a:	66 90                	xchg   %ax,%ax
  80235c:	66 90                	xchg   %ax,%ax
  80235e:	66 90                	xchg   %ax,%ax

00802360 <__umoddi3>:
  802360:	f3 0f 1e fb          	endbr32 
  802364:	55                   	push   %ebp
  802365:	57                   	push   %edi
  802366:	56                   	push   %esi
  802367:	53                   	push   %ebx
  802368:	83 ec 1c             	sub    $0x1c,%esp
  80236b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80236f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802373:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802377:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80237b:	89 f0                	mov    %esi,%eax
  80237d:	89 da                	mov    %ebx,%edx
  80237f:	85 ff                	test   %edi,%edi
  802381:	75 15                	jne    802398 <__umoddi3+0x38>
  802383:	39 dd                	cmp    %ebx,%ebp
  802385:	76 39                	jbe    8023c0 <__umoddi3+0x60>
  802387:	f7 f5                	div    %ebp
  802389:	89 d0                	mov    %edx,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	83 c4 1c             	add    $0x1c,%esp
  802390:	5b                   	pop    %ebx
  802391:	5e                   	pop    %esi
  802392:	5f                   	pop    %edi
  802393:	5d                   	pop    %ebp
  802394:	c3                   	ret    
  802395:	8d 76 00             	lea    0x0(%esi),%esi
  802398:	39 df                	cmp    %ebx,%edi
  80239a:	77 f1                	ja     80238d <__umoddi3+0x2d>
  80239c:	0f bd cf             	bsr    %edi,%ecx
  80239f:	83 f1 1f             	xor    $0x1f,%ecx
  8023a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023a6:	75 40                	jne    8023e8 <__umoddi3+0x88>
  8023a8:	39 df                	cmp    %ebx,%edi
  8023aa:	72 04                	jb     8023b0 <__umoddi3+0x50>
  8023ac:	39 f5                	cmp    %esi,%ebp
  8023ae:	77 dd                	ja     80238d <__umoddi3+0x2d>
  8023b0:	89 da                	mov    %ebx,%edx
  8023b2:	89 f0                	mov    %esi,%eax
  8023b4:	29 e8                	sub    %ebp,%eax
  8023b6:	19 fa                	sbb    %edi,%edx
  8023b8:	eb d3                	jmp    80238d <__umoddi3+0x2d>
  8023ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023c0:	89 e9                	mov    %ebp,%ecx
  8023c2:	85 ed                	test   %ebp,%ebp
  8023c4:	75 0b                	jne    8023d1 <__umoddi3+0x71>
  8023c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	f7 f5                	div    %ebp
  8023cf:	89 c1                	mov    %eax,%ecx
  8023d1:	89 d8                	mov    %ebx,%eax
  8023d3:	31 d2                	xor    %edx,%edx
  8023d5:	f7 f1                	div    %ecx
  8023d7:	89 f0                	mov    %esi,%eax
  8023d9:	f7 f1                	div    %ecx
  8023db:	89 d0                	mov    %edx,%eax
  8023dd:	31 d2                	xor    %edx,%edx
  8023df:	eb ac                	jmp    80238d <__umoddi3+0x2d>
  8023e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023ec:	ba 20 00 00 00       	mov    $0x20,%edx
  8023f1:	29 c2                	sub    %eax,%edx
  8023f3:	89 c1                	mov    %eax,%ecx
  8023f5:	89 e8                	mov    %ebp,%eax
  8023f7:	d3 e7                	shl    %cl,%edi
  8023f9:	89 d1                	mov    %edx,%ecx
  8023fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8023ff:	d3 e8                	shr    %cl,%eax
  802401:	89 c1                	mov    %eax,%ecx
  802403:	8b 44 24 04          	mov    0x4(%esp),%eax
  802407:	09 f9                	or     %edi,%ecx
  802409:	89 df                	mov    %ebx,%edi
  80240b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80240f:	89 c1                	mov    %eax,%ecx
  802411:	d3 e5                	shl    %cl,%ebp
  802413:	89 d1                	mov    %edx,%ecx
  802415:	d3 ef                	shr    %cl,%edi
  802417:	89 c1                	mov    %eax,%ecx
  802419:	89 f0                	mov    %esi,%eax
  80241b:	d3 e3                	shl    %cl,%ebx
  80241d:	89 d1                	mov    %edx,%ecx
  80241f:	89 fa                	mov    %edi,%edx
  802421:	d3 e8                	shr    %cl,%eax
  802423:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802428:	09 d8                	or     %ebx,%eax
  80242a:	f7 74 24 08          	divl   0x8(%esp)
  80242e:	89 d3                	mov    %edx,%ebx
  802430:	d3 e6                	shl    %cl,%esi
  802432:	f7 e5                	mul    %ebp
  802434:	89 c7                	mov    %eax,%edi
  802436:	89 d1                	mov    %edx,%ecx
  802438:	39 d3                	cmp    %edx,%ebx
  80243a:	72 06                	jb     802442 <__umoddi3+0xe2>
  80243c:	75 0e                	jne    80244c <__umoddi3+0xec>
  80243e:	39 c6                	cmp    %eax,%esi
  802440:	73 0a                	jae    80244c <__umoddi3+0xec>
  802442:	29 e8                	sub    %ebp,%eax
  802444:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802448:	89 d1                	mov    %edx,%ecx
  80244a:	89 c7                	mov    %eax,%edi
  80244c:	89 f5                	mov    %esi,%ebp
  80244e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802452:	29 fd                	sub    %edi,%ebp
  802454:	19 cb                	sbb    %ecx,%ebx
  802456:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80245b:	89 d8                	mov    %ebx,%eax
  80245d:	d3 e0                	shl    %cl,%eax
  80245f:	89 f1                	mov    %esi,%ecx
  802461:	d3 ed                	shr    %cl,%ebp
  802463:	d3 eb                	shr    %cl,%ebx
  802465:	09 e8                	or     %ebp,%eax
  802467:	89 da                	mov    %ebx,%edx
  802469:	83 c4 1c             	add    $0x1c,%esp
  80246c:	5b                   	pop    %ebx
  80246d:	5e                   	pop    %esi
  80246e:	5f                   	pop    %edi
  80246f:	5d                   	pop    %ebp
  802470:	c3                   	ret    
