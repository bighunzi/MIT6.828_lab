
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
  80004b:	e8 dc 11 00 00       	call   80122c <write>
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
  800065:	e8 f4 10 00 00       	call   80115e <read>
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
  80008b:	68 c0 1f 80 00       	push   $0x801fc0
  800090:	e8 ce 16 00 00       	call   801763 <printf>
			bol = 0;
  800095:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80009c:	00 00 00 
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	eb 9f                	jmp    800043 <num+0x10>
			panic("write error copying %s: %e", s, r);
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 75 0c             	push   0xc(%ebp)
  8000ab:	68 c5 1f 80 00       	push   $0x801fc5
  8000b0:	6a 13                	push   $0x13
  8000b2:	68 e0 1f 80 00       	push   $0x801fe0
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
  8000d8:	68 eb 1f 80 00       	push   $0x801feb
  8000dd:	6a 18                	push   $0x18
  8000df:	68 e0 1f 80 00       	push   $0x801fe0
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
  8000f2:	c7 05 04 30 80 00 00 	movl   $0x802000,0x803004
  8000f9:	20 80 00 
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
  800112:	68 04 20 80 00       	push   $0x802004
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
  80013c:	e8 e1 0e 00 00       	call   801022 <close>
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
  800159:	e8 63 14 00 00       	call   8015c1 <open>
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
  800170:	68 0c 20 80 00       	push   $0x80200c
  800175:	6a 27                	push   $0x27
  800177:	68 e0 1f 80 00       	push   $0x801fe0
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
  8001cd:	e8 7d 0e 00 00       	call   80104f <close_all>
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
  8001ff:	68 28 20 80 00       	push   $0x802028
  800204:	e8 b3 00 00 00       	call   8002bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800209:	83 c4 18             	add    $0x18,%esp
  80020c:	53                   	push   %ebx
  80020d:	ff 75 10             	push   0x10(%ebp)
  800210:	e8 56 00 00 00       	call   80026b <vcprintf>
	cprintf("\n");
  800215:	c7 04 24 43 24 80 00 	movl   $0x802443,(%esp)
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
  80031e:	e8 4d 1a 00 00       	call   801d70 <__udivdi3>
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
  80035c:	e8 2f 1b 00 00       	call   801e90 <__umoddi3>
  800361:	83 c4 14             	add    $0x14,%esp
  800364:	0f be 80 4b 20 80 00 	movsbl 0x80204b(%eax),%eax
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
  80041e:	ff 24 85 80 21 80 00 	jmp    *0x802180(,%eax,4)
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
  8004ec:	8b 14 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 18                	je     80050f <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004f7:	52                   	push   %edx
  8004f8:	68 11 24 80 00       	push   $0x802411
  8004fd:	53                   	push   %ebx
  8004fe:	56                   	push   %esi
  8004ff:	e8 92 fe ff ff       	call   800396 <printfmt>
  800504:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800507:	89 7d 14             	mov    %edi,0x14(%ebp)
  80050a:	e9 66 02 00 00       	jmp    800775 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80050f:	50                   	push   %eax
  800510:	68 63 20 80 00       	push   $0x802063
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
  800537:	b8 5c 20 80 00       	mov    $0x80205c,%eax
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
  800c43:	68 3f 23 80 00       	push   $0x80233f
  800c48:	6a 2a                	push   $0x2a
  800c4a:	68 5c 23 80 00       	push   $0x80235c
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
  800cc4:	68 3f 23 80 00       	push   $0x80233f
  800cc9:	6a 2a                	push   $0x2a
  800ccb:	68 5c 23 80 00       	push   $0x80235c
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
  800d06:	68 3f 23 80 00       	push   $0x80233f
  800d0b:	6a 2a                	push   $0x2a
  800d0d:	68 5c 23 80 00       	push   $0x80235c
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
  800d48:	68 3f 23 80 00       	push   $0x80233f
  800d4d:	6a 2a                	push   $0x2a
  800d4f:	68 5c 23 80 00       	push   $0x80235c
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
  800d8a:	68 3f 23 80 00       	push   $0x80233f
  800d8f:	6a 2a                	push   $0x2a
  800d91:	68 5c 23 80 00       	push   $0x80235c
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
  800dcc:	68 3f 23 80 00       	push   $0x80233f
  800dd1:	6a 2a                	push   $0x2a
  800dd3:	68 5c 23 80 00       	push   $0x80235c
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
  800e0e:	68 3f 23 80 00       	push   $0x80233f
  800e13:	6a 2a                	push   $0x2a
  800e15:	68 5c 23 80 00       	push   $0x80235c
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
  800e72:	68 3f 23 80 00       	push   $0x80233f
  800e77:	6a 2a                	push   $0x2a
  800e79:	68 5c 23 80 00       	push   $0x80235c
  800e7e:	e8 5e f3 ff ff       	call   8001e1 <_panic>

00800e83 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	05 00 00 00 30       	add    $0x30000000,%eax
  800e8e:	c1 e8 0c             	shr    $0xc,%eax
}
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
  800e99:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eb2:	89 c2                	mov    %eax,%edx
  800eb4:	c1 ea 16             	shr    $0x16,%edx
  800eb7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ebe:	f6 c2 01             	test   $0x1,%dl
  800ec1:	74 29                	je     800eec <fd_alloc+0x42>
  800ec3:	89 c2                	mov    %eax,%edx
  800ec5:	c1 ea 0c             	shr    $0xc,%edx
  800ec8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ecf:	f6 c2 01             	test   $0x1,%dl
  800ed2:	74 18                	je     800eec <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800ed4:	05 00 10 00 00       	add    $0x1000,%eax
  800ed9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ede:	75 d2                	jne    800eb2 <fd_alloc+0x8>
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800ee5:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800eea:	eb 05                	jmp    800ef1 <fd_alloc+0x47>
			return 0;
  800eec:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800ef1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef4:	89 02                	mov    %eax,(%edx)
}
  800ef6:	89 c8                	mov    %ecx,%eax
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f00:	83 f8 1f             	cmp    $0x1f,%eax
  800f03:	77 30                	ja     800f35 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f05:	c1 e0 0c             	shl    $0xc,%eax
  800f08:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f0d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f13:	f6 c2 01             	test   $0x1,%dl
  800f16:	74 24                	je     800f3c <fd_lookup+0x42>
  800f18:	89 c2                	mov    %eax,%edx
  800f1a:	c1 ea 0c             	shr    $0xc,%edx
  800f1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f24:	f6 c2 01             	test   $0x1,%dl
  800f27:	74 1a                	je     800f43 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2c:	89 02                	mov    %eax,(%edx)
	return 0;
  800f2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
		return -E_INVAL;
  800f35:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3a:	eb f7                	jmp    800f33 <fd_lookup+0x39>
		return -E_INVAL;
  800f3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f41:	eb f0                	jmp    800f33 <fd_lookup+0x39>
  800f43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f48:	eb e9                	jmp    800f33 <fd_lookup+0x39>

00800f4a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	53                   	push   %ebx
  800f4e:	83 ec 04             	sub    $0x4,%esp
  800f51:	8b 55 08             	mov    0x8(%ebp),%edx
  800f54:	b8 e8 23 80 00       	mov    $0x8023e8,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800f59:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f5e:	39 13                	cmp    %edx,(%ebx)
  800f60:	74 32                	je     800f94 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800f62:	83 c0 04             	add    $0x4,%eax
  800f65:	8b 18                	mov    (%eax),%ebx
  800f67:	85 db                	test   %ebx,%ebx
  800f69:	75 f3                	jne    800f5e <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f6b:	a1 04 40 80 00       	mov    0x804004,%eax
  800f70:	8b 40 48             	mov    0x48(%eax),%eax
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	52                   	push   %edx
  800f77:	50                   	push   %eax
  800f78:	68 6c 23 80 00       	push   $0x80236c
  800f7d:	e8 3a f3 ff ff       	call   8002bc <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8d:	89 1a                	mov    %ebx,(%edx)
}
  800f8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    
			return 0;
  800f94:	b8 00 00 00 00       	mov    $0x0,%eax
  800f99:	eb ef                	jmp    800f8a <dev_lookup+0x40>

00800f9b <fd_close>:
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 24             	sub    $0x24,%esp
  800fa4:	8b 75 08             	mov    0x8(%ebp),%esi
  800fa7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800faa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fad:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fae:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fb4:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb7:	50                   	push   %eax
  800fb8:	e8 3d ff ff ff       	call   800efa <fd_lookup>
  800fbd:	89 c3                	mov    %eax,%ebx
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 05                	js     800fcb <fd_close+0x30>
	    || fd != fd2)
  800fc6:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fc9:	74 16                	je     800fe1 <fd_close+0x46>
		return (must_exist ? r : 0);
  800fcb:	89 f8                	mov    %edi,%eax
  800fcd:	84 c0                	test   %al,%al
  800fcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd4:	0f 44 d8             	cmove  %eax,%ebx
}
  800fd7:	89 d8                	mov    %ebx,%eax
  800fd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5e                   	pop    %esi
  800fde:	5f                   	pop    %edi
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	ff 36                	push   (%esi)
  800fea:	e8 5b ff ff ff       	call   800f4a <dev_lookup>
  800fef:	89 c3                	mov    %eax,%ebx
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	78 1a                	js     801012 <fd_close+0x77>
		if (dev->dev_close)
  800ff8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ffb:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801003:	85 c0                	test   %eax,%eax
  801005:	74 0b                	je     801012 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	56                   	push   %esi
  80100b:	ff d0                	call   *%eax
  80100d:	89 c3                	mov    %eax,%ebx
  80100f:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801012:	83 ec 08             	sub    $0x8,%esp
  801015:	56                   	push   %esi
  801016:	6a 00                	push   $0x0
  801018:	e8 fa fc ff ff       	call   800d17 <sys_page_unmap>
	return r;
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	eb b5                	jmp    800fd7 <fd_close+0x3c>

00801022 <close>:

int
close(int fdnum)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801028:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102b:	50                   	push   %eax
  80102c:	ff 75 08             	push   0x8(%ebp)
  80102f:	e8 c6 fe ff ff       	call   800efa <fd_lookup>
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	79 02                	jns    80103d <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80103b:	c9                   	leave  
  80103c:	c3                   	ret    
		return fd_close(fd, 1);
  80103d:	83 ec 08             	sub    $0x8,%esp
  801040:	6a 01                	push   $0x1
  801042:	ff 75 f4             	push   -0xc(%ebp)
  801045:	e8 51 ff ff ff       	call   800f9b <fd_close>
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	eb ec                	jmp    80103b <close+0x19>

0080104f <close_all>:

void
close_all(void)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	53                   	push   %ebx
  801053:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801056:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	53                   	push   %ebx
  80105f:	e8 be ff ff ff       	call   801022 <close>
	for (i = 0; i < MAXFD; i++)
  801064:	83 c3 01             	add    $0x1,%ebx
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	83 fb 20             	cmp    $0x20,%ebx
  80106d:	75 ec                	jne    80105b <close_all+0xc>
}
  80106f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801072:	c9                   	leave  
  801073:	c3                   	ret    

00801074 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80107d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801080:	50                   	push   %eax
  801081:	ff 75 08             	push   0x8(%ebp)
  801084:	e8 71 fe ff ff       	call   800efa <fd_lookup>
  801089:	89 c3                	mov    %eax,%ebx
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 7f                	js     801111 <dup+0x9d>
		return r;
	close(newfdnum);
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	ff 75 0c             	push   0xc(%ebp)
  801098:	e8 85 ff ff ff       	call   801022 <close>

	newfd = INDEX2FD(newfdnum);
  80109d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a0:	c1 e6 0c             	shl    $0xc,%esi
  8010a3:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010ac:	89 3c 24             	mov    %edi,(%esp)
  8010af:	e8 df fd ff ff       	call   800e93 <fd2data>
  8010b4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010b6:	89 34 24             	mov    %esi,(%esp)
  8010b9:	e8 d5 fd ff ff       	call   800e93 <fd2data>
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010c4:	89 d8                	mov    %ebx,%eax
  8010c6:	c1 e8 16             	shr    $0x16,%eax
  8010c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d0:	a8 01                	test   $0x1,%al
  8010d2:	74 11                	je     8010e5 <dup+0x71>
  8010d4:	89 d8                	mov    %ebx,%eax
  8010d6:	c1 e8 0c             	shr    $0xc,%eax
  8010d9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e0:	f6 c2 01             	test   $0x1,%dl
  8010e3:	75 36                	jne    80111b <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e5:	89 f8                	mov    %edi,%eax
  8010e7:	c1 e8 0c             	shr    $0xc,%eax
  8010ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f9:	50                   	push   %eax
  8010fa:	56                   	push   %esi
  8010fb:	6a 00                	push   $0x0
  8010fd:	57                   	push   %edi
  8010fe:	6a 00                	push   $0x0
  801100:	e8 d0 fb ff ff       	call   800cd5 <sys_page_map>
  801105:	89 c3                	mov    %eax,%ebx
  801107:	83 c4 20             	add    $0x20,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	78 33                	js     801141 <dup+0xcd>
		goto err;

	return newfdnum;
  80110e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801111:	89 d8                	mov    %ebx,%eax
  801113:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801116:	5b                   	pop    %ebx
  801117:	5e                   	pop    %esi
  801118:	5f                   	pop    %edi
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80111b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	25 07 0e 00 00       	and    $0xe07,%eax
  80112a:	50                   	push   %eax
  80112b:	ff 75 d4             	push   -0x2c(%ebp)
  80112e:	6a 00                	push   $0x0
  801130:	53                   	push   %ebx
  801131:	6a 00                	push   $0x0
  801133:	e8 9d fb ff ff       	call   800cd5 <sys_page_map>
  801138:	89 c3                	mov    %eax,%ebx
  80113a:	83 c4 20             	add    $0x20,%esp
  80113d:	85 c0                	test   %eax,%eax
  80113f:	79 a4                	jns    8010e5 <dup+0x71>
	sys_page_unmap(0, newfd);
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	56                   	push   %esi
  801145:	6a 00                	push   $0x0
  801147:	e8 cb fb ff ff       	call   800d17 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114c:	83 c4 08             	add    $0x8,%esp
  80114f:	ff 75 d4             	push   -0x2c(%ebp)
  801152:	6a 00                	push   $0x0
  801154:	e8 be fb ff ff       	call   800d17 <sys_page_unmap>
	return r;
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	eb b3                	jmp    801111 <dup+0x9d>

0080115e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	83 ec 18             	sub    $0x18,%esp
  801166:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801169:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116c:	50                   	push   %eax
  80116d:	56                   	push   %esi
  80116e:	e8 87 fd ff ff       	call   800efa <fd_lookup>
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	78 3c                	js     8011b6 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801183:	50                   	push   %eax
  801184:	ff 33                	push   (%ebx)
  801186:	e8 bf fd ff ff       	call   800f4a <dev_lookup>
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 24                	js     8011b6 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801192:	8b 43 08             	mov    0x8(%ebx),%eax
  801195:	83 e0 03             	and    $0x3,%eax
  801198:	83 f8 01             	cmp    $0x1,%eax
  80119b:	74 20                	je     8011bd <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80119d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a0:	8b 40 08             	mov    0x8(%eax),%eax
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	74 37                	je     8011de <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	ff 75 10             	push   0x10(%ebp)
  8011ad:	ff 75 0c             	push   0xc(%ebp)
  8011b0:	53                   	push   %ebx
  8011b1:	ff d0                	call   *%eax
  8011b3:	83 c4 10             	add    $0x10,%esp
}
  8011b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b9:	5b                   	pop    %ebx
  8011ba:	5e                   	pop    %esi
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c2:	8b 40 48             	mov    0x48(%eax),%eax
  8011c5:	83 ec 04             	sub    $0x4,%esp
  8011c8:	56                   	push   %esi
  8011c9:	50                   	push   %eax
  8011ca:	68 ad 23 80 00       	push   $0x8023ad
  8011cf:	e8 e8 f0 ff ff       	call   8002bc <cprintf>
		return -E_INVAL;
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011dc:	eb d8                	jmp    8011b6 <read+0x58>
		return -E_NOT_SUPP;
  8011de:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011e3:	eb d1                	jmp    8011b6 <read+0x58>

008011e5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 0c             	sub    $0xc,%esp
  8011ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011f1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f9:	eb 02                	jmp    8011fd <readn+0x18>
  8011fb:	01 c3                	add    %eax,%ebx
  8011fd:	39 f3                	cmp    %esi,%ebx
  8011ff:	73 21                	jae    801222 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	89 f0                	mov    %esi,%eax
  801206:	29 d8                	sub    %ebx,%eax
  801208:	50                   	push   %eax
  801209:	89 d8                	mov    %ebx,%eax
  80120b:	03 45 0c             	add    0xc(%ebp),%eax
  80120e:	50                   	push   %eax
  80120f:	57                   	push   %edi
  801210:	e8 49 ff ff ff       	call   80115e <read>
		if (m < 0)
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 04                	js     801220 <readn+0x3b>
			return m;
		if (m == 0)
  80121c:	75 dd                	jne    8011fb <readn+0x16>
  80121e:	eb 02                	jmp    801222 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801220:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801222:	89 d8                	mov    %ebx,%eax
  801224:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	83 ec 18             	sub    $0x18,%esp
  801234:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801237:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	53                   	push   %ebx
  80123c:	e8 b9 fc ff ff       	call   800efa <fd_lookup>
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 37                	js     80127f <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801248:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	ff 36                	push   (%esi)
  801254:	e8 f1 fc ff ff       	call   800f4a <dev_lookup>
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 1f                	js     80127f <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801260:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801264:	74 20                	je     801286 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801266:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801269:	8b 40 0c             	mov    0xc(%eax),%eax
  80126c:	85 c0                	test   %eax,%eax
  80126e:	74 37                	je     8012a7 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801270:	83 ec 04             	sub    $0x4,%esp
  801273:	ff 75 10             	push   0x10(%ebp)
  801276:	ff 75 0c             	push   0xc(%ebp)
  801279:	56                   	push   %esi
  80127a:	ff d0                	call   *%eax
  80127c:	83 c4 10             	add    $0x10,%esp
}
  80127f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801282:	5b                   	pop    %ebx
  801283:	5e                   	pop    %esi
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801286:	a1 04 40 80 00       	mov    0x804004,%eax
  80128b:	8b 40 48             	mov    0x48(%eax),%eax
  80128e:	83 ec 04             	sub    $0x4,%esp
  801291:	53                   	push   %ebx
  801292:	50                   	push   %eax
  801293:	68 c9 23 80 00       	push   $0x8023c9
  801298:	e8 1f f0 ff ff       	call   8002bc <cprintf>
		return -E_INVAL;
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a5:	eb d8                	jmp    80127f <write+0x53>
		return -E_NOT_SUPP;
  8012a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012ac:	eb d1                	jmp    80127f <write+0x53>

008012ae <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
  8012b1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	ff 75 08             	push   0x8(%ebp)
  8012bb:	e8 3a fc ff ff       	call   800efa <fd_lookup>
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 0e                	js     8012d5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012cd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d5:	c9                   	leave  
  8012d6:	c3                   	ret    

008012d7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	56                   	push   %esi
  8012db:	53                   	push   %ebx
  8012dc:	83 ec 18             	sub    $0x18,%esp
  8012df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	53                   	push   %ebx
  8012e7:	e8 0e fc ff ff       	call   800efa <fd_lookup>
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 34                	js     801327 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fc:	50                   	push   %eax
  8012fd:	ff 36                	push   (%esi)
  8012ff:	e8 46 fc ff ff       	call   800f4a <dev_lookup>
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	78 1c                	js     801327 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80130b:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80130f:	74 1d                	je     80132e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801311:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801314:	8b 40 18             	mov    0x18(%eax),%eax
  801317:	85 c0                	test   %eax,%eax
  801319:	74 34                	je     80134f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	ff 75 0c             	push   0xc(%ebp)
  801321:	56                   	push   %esi
  801322:	ff d0                	call   *%eax
  801324:	83 c4 10             	add    $0x10,%esp
}
  801327:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132a:	5b                   	pop    %ebx
  80132b:	5e                   	pop    %esi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80132e:	a1 04 40 80 00       	mov    0x804004,%eax
  801333:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801336:	83 ec 04             	sub    $0x4,%esp
  801339:	53                   	push   %ebx
  80133a:	50                   	push   %eax
  80133b:	68 8c 23 80 00       	push   $0x80238c
  801340:	e8 77 ef ff ff       	call   8002bc <cprintf>
		return -E_INVAL;
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134d:	eb d8                	jmp    801327 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80134f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801354:	eb d1                	jmp    801327 <ftruncate+0x50>

00801356 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	56                   	push   %esi
  80135a:	53                   	push   %ebx
  80135b:	83 ec 18             	sub    $0x18,%esp
  80135e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801361:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801364:	50                   	push   %eax
  801365:	ff 75 08             	push   0x8(%ebp)
  801368:	e8 8d fb ff ff       	call   800efa <fd_lookup>
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	85 c0                	test   %eax,%eax
  801372:	78 49                	js     8013bd <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801374:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	ff 36                	push   (%esi)
  801380:	e8 c5 fb ff ff       	call   800f4a <dev_lookup>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 31                	js     8013bd <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80138c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801393:	74 2f                	je     8013c4 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801395:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801398:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80139f:	00 00 00 
	stat->st_isdir = 0;
  8013a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013a9:	00 00 00 
	stat->st_dev = dev;
  8013ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b2:	83 ec 08             	sub    $0x8,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	56                   	push   %esi
  8013b7:	ff 50 14             	call   *0x14(%eax)
  8013ba:	83 c4 10             	add    $0x10,%esp
}
  8013bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5e                   	pop    %esi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    
		return -E_NOT_SUPP;
  8013c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013c9:	eb f2                	jmp    8013bd <fstat+0x67>

008013cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	6a 00                	push   $0x0
  8013d5:	ff 75 08             	push   0x8(%ebp)
  8013d8:	e8 e4 01 00 00       	call   8015c1 <open>
  8013dd:	89 c3                	mov    %eax,%ebx
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 1b                	js     801401 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	ff 75 0c             	push   0xc(%ebp)
  8013ec:	50                   	push   %eax
  8013ed:	e8 64 ff ff ff       	call   801356 <fstat>
  8013f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8013f4:	89 1c 24             	mov    %ebx,(%esp)
  8013f7:	e8 26 fc ff ff       	call   801022 <close>
	return r;
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	89 f3                	mov    %esi,%ebx
}
  801401:	89 d8                	mov    %ebx,%eax
  801403:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	56                   	push   %esi
  80140e:	53                   	push   %ebx
  80140f:	89 c6                	mov    %eax,%esi
  801411:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801413:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80141a:	74 27                	je     801443 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80141c:	6a 07                	push   $0x7
  80141e:	68 00 50 80 00       	push   $0x805000
  801423:	56                   	push   %esi
  801424:	ff 35 00 60 80 00    	push   0x806000
  80142a:	e8 6f 08 00 00       	call   801c9e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80142f:	83 c4 0c             	add    $0xc,%esp
  801432:	6a 00                	push   $0x0
  801434:	53                   	push   %ebx
  801435:	6a 00                	push   $0x0
  801437:	e8 fb 07 00 00       	call   801c37 <ipc_recv>
}
  80143c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801443:	83 ec 0c             	sub    $0xc,%esp
  801446:	6a 01                	push   $0x1
  801448:	e8 a5 08 00 00       	call   801cf2 <ipc_find_env>
  80144d:	a3 00 60 80 00       	mov    %eax,0x806000
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	eb c5                	jmp    80141c <fsipc+0x12>

00801457 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
  801460:	8b 40 0c             	mov    0xc(%eax),%eax
  801463:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801468:	8b 45 0c             	mov    0xc(%ebp),%eax
  80146b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801470:	ba 00 00 00 00       	mov    $0x0,%edx
  801475:	b8 02 00 00 00       	mov    $0x2,%eax
  80147a:	e8 8b ff ff ff       	call   80140a <fsipc>
}
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <devfile_flush>:
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801487:	8b 45 08             	mov    0x8(%ebp),%eax
  80148a:	8b 40 0c             	mov    0xc(%eax),%eax
  80148d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801492:	ba 00 00 00 00       	mov    $0x0,%edx
  801497:	b8 06 00 00 00       	mov    $0x6,%eax
  80149c:	e8 69 ff ff ff       	call   80140a <fsipc>
}
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <devfile_stat>:
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 04             	sub    $0x4,%esp
  8014aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8014c2:	e8 43 ff ff ff       	call   80140a <fsipc>
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 2c                	js     8014f7 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	68 00 50 80 00       	push   $0x805000
  8014d3:	53                   	push   %ebx
  8014d4:	e8 bd f3 ff ff       	call   800896 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8014de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8014e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <devfile_write>:
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	8b 45 10             	mov    0x10(%ebp),%eax
  801505:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80150a:	39 d0                	cmp    %edx,%eax
  80150c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80150f:	8b 55 08             	mov    0x8(%ebp),%edx
  801512:	8b 52 0c             	mov    0xc(%edx),%edx
  801515:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80151b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801520:	50                   	push   %eax
  801521:	ff 75 0c             	push   0xc(%ebp)
  801524:	68 08 50 80 00       	push   $0x805008
  801529:	e8 fe f4 ff ff       	call   800a2c <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80152e:	ba 00 00 00 00       	mov    $0x0,%edx
  801533:	b8 04 00 00 00       	mov    $0x4,%eax
  801538:	e8 cd fe ff ff       	call   80140a <fsipc>
}
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <devfile_read>:
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	56                   	push   %esi
  801543:	53                   	push   %ebx
  801544:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801547:	8b 45 08             	mov    0x8(%ebp),%eax
  80154a:	8b 40 0c             	mov    0xc(%eax),%eax
  80154d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801552:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801558:	ba 00 00 00 00       	mov    $0x0,%edx
  80155d:	b8 03 00 00 00       	mov    $0x3,%eax
  801562:	e8 a3 fe ff ff       	call   80140a <fsipc>
  801567:	89 c3                	mov    %eax,%ebx
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 1f                	js     80158c <devfile_read+0x4d>
	assert(r <= n);
  80156d:	39 f0                	cmp    %esi,%eax
  80156f:	77 24                	ja     801595 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801571:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801576:	7f 33                	jg     8015ab <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801578:	83 ec 04             	sub    $0x4,%esp
  80157b:	50                   	push   %eax
  80157c:	68 00 50 80 00       	push   $0x805000
  801581:	ff 75 0c             	push   0xc(%ebp)
  801584:	e8 a3 f4 ff ff       	call   800a2c <memmove>
	return r;
  801589:	83 c4 10             	add    $0x10,%esp
}
  80158c:	89 d8                	mov    %ebx,%eax
  80158e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801591:	5b                   	pop    %ebx
  801592:	5e                   	pop    %esi
  801593:	5d                   	pop    %ebp
  801594:	c3                   	ret    
	assert(r <= n);
  801595:	68 f8 23 80 00       	push   $0x8023f8
  80159a:	68 ff 23 80 00       	push   $0x8023ff
  80159f:	6a 7c                	push   $0x7c
  8015a1:	68 14 24 80 00       	push   $0x802414
  8015a6:	e8 36 ec ff ff       	call   8001e1 <_panic>
	assert(r <= PGSIZE);
  8015ab:	68 1f 24 80 00       	push   $0x80241f
  8015b0:	68 ff 23 80 00       	push   $0x8023ff
  8015b5:	6a 7d                	push   $0x7d
  8015b7:	68 14 24 80 00       	push   $0x802414
  8015bc:	e8 20 ec ff ff       	call   8001e1 <_panic>

008015c1 <open>:
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
  8015c6:	83 ec 1c             	sub    $0x1c,%esp
  8015c9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015cc:	56                   	push   %esi
  8015cd:	e8 89 f2 ff ff       	call   80085b <strlen>
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015da:	7f 6c                	jg     801648 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015dc:	83 ec 0c             	sub    $0xc,%esp
  8015df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	e8 c2 f8 ff ff       	call   800eaa <fd_alloc>
  8015e8:	89 c3                	mov    %eax,%ebx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 3c                	js     80162d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	56                   	push   %esi
  8015f5:	68 00 50 80 00       	push   $0x805000
  8015fa:	e8 97 f2 ff ff       	call   800896 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801602:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801607:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160a:	b8 01 00 00 00       	mov    $0x1,%eax
  80160f:	e8 f6 fd ff ff       	call   80140a <fsipc>
  801614:	89 c3                	mov    %eax,%ebx
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 19                	js     801636 <open+0x75>
	return fd2num(fd);
  80161d:	83 ec 0c             	sub    $0xc,%esp
  801620:	ff 75 f4             	push   -0xc(%ebp)
  801623:	e8 5b f8 ff ff       	call   800e83 <fd2num>
  801628:	89 c3                	mov    %eax,%ebx
  80162a:	83 c4 10             	add    $0x10,%esp
}
  80162d:	89 d8                	mov    %ebx,%eax
  80162f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801632:	5b                   	pop    %ebx
  801633:	5e                   	pop    %esi
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    
		fd_close(fd, 0);
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	6a 00                	push   $0x0
  80163b:	ff 75 f4             	push   -0xc(%ebp)
  80163e:	e8 58 f9 ff ff       	call   800f9b <fd_close>
		return r;
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	eb e5                	jmp    80162d <open+0x6c>
		return -E_BAD_PATH;
  801648:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80164d:	eb de                	jmp    80162d <open+0x6c>

0080164f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801655:	ba 00 00 00 00       	mov    $0x0,%edx
  80165a:	b8 08 00 00 00       	mov    $0x8,%eax
  80165f:	e8 a6 fd ff ff       	call   80140a <fsipc>
}
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801666:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80166a:	7f 01                	jg     80166d <writebuf+0x7>
  80166c:	c3                   	ret    
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	53                   	push   %ebx
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801676:	ff 70 04             	push   0x4(%eax)
  801679:	8d 40 10             	lea    0x10(%eax),%eax
  80167c:	50                   	push   %eax
  80167d:	ff 33                	push   (%ebx)
  80167f:	e8 a8 fb ff ff       	call   80122c <write>
		if (result > 0)
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	7e 03                	jle    80168e <writebuf+0x28>
			b->result += result;
  80168b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80168e:	39 43 04             	cmp    %eax,0x4(%ebx)
  801691:	74 0d                	je     8016a0 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801693:	85 c0                	test   %eax,%eax
  801695:	ba 00 00 00 00       	mov    $0x0,%edx
  80169a:	0f 4f c2             	cmovg  %edx,%eax
  80169d:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <putch>:

static void
putch(int ch, void *thunk)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 04             	sub    $0x4,%esp
  8016ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016af:	8b 53 04             	mov    0x4(%ebx),%edx
  8016b2:	8d 42 01             	lea    0x1(%edx),%eax
  8016b5:	89 43 04             	mov    %eax,0x4(%ebx)
  8016b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016bb:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016bf:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016c4:	74 05                	je     8016cb <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  8016c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    
		writebuf(b);
  8016cb:	89 d8                	mov    %ebx,%eax
  8016cd:	e8 94 ff ff ff       	call   801666 <writebuf>
		b->idx = 0;
  8016d2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8016d9:	eb eb                	jmp    8016c6 <putch+0x21>

008016db <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016ed:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016f4:	00 00 00 
	b.result = 0;
  8016f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016fe:	00 00 00 
	b.error = 1;
  801701:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801708:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80170b:	ff 75 10             	push   0x10(%ebp)
  80170e:	ff 75 0c             	push   0xc(%ebp)
  801711:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	68 a5 16 80 00       	push   $0x8016a5
  80171d:	e8 91 ec ff ff       	call   8003b3 <vprintfmt>
	if (b.idx > 0)
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80172c:	7f 11                	jg     80173f <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  80172e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801734:	85 c0                	test   %eax,%eax
  801736:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    
		writebuf(&b);
  80173f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801745:	e8 1c ff ff ff       	call   801666 <writebuf>
  80174a:	eb e2                	jmp    80172e <vfprintf+0x53>

0080174c <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801752:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801755:	50                   	push   %eax
  801756:	ff 75 0c             	push   0xc(%ebp)
  801759:	ff 75 08             	push   0x8(%ebp)
  80175c:	e8 7a ff ff ff       	call   8016db <vfprintf>
	va_end(ap);

	return cnt;
}
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <printf>:

int
printf(const char *fmt, ...)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801769:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80176c:	50                   	push   %eax
  80176d:	ff 75 08             	push   0x8(%ebp)
  801770:	6a 01                	push   $0x1
  801772:	e8 64 ff ff ff       	call   8016db <vfprintf>
	va_end(ap);

	return cnt;
}
  801777:	c9                   	leave  
  801778:	c3                   	ret    

00801779 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	56                   	push   %esi
  80177d:	53                   	push   %ebx
  80177e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801781:	83 ec 0c             	sub    $0xc,%esp
  801784:	ff 75 08             	push   0x8(%ebp)
  801787:	e8 07 f7 ff ff       	call   800e93 <fd2data>
  80178c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80178e:	83 c4 08             	add    $0x8,%esp
  801791:	68 2b 24 80 00       	push   $0x80242b
  801796:	53                   	push   %ebx
  801797:	e8 fa f0 ff ff       	call   800896 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80179c:	8b 46 04             	mov    0x4(%esi),%eax
  80179f:	2b 06                	sub    (%esi),%eax
  8017a1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ae:	00 00 00 
	stat->st_dev = &devpipe;
  8017b1:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8017b8:	30 80 00 
	return 0;
}
  8017bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017d1:	53                   	push   %ebx
  8017d2:	6a 00                	push   $0x0
  8017d4:	e8 3e f5 ff ff       	call   800d17 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017d9:	89 1c 24             	mov    %ebx,(%esp)
  8017dc:	e8 b2 f6 ff ff       	call   800e93 <fd2data>
  8017e1:	83 c4 08             	add    $0x8,%esp
  8017e4:	50                   	push   %eax
  8017e5:	6a 00                	push   $0x0
  8017e7:	e8 2b f5 ff ff       	call   800d17 <sys_page_unmap>
}
  8017ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <_pipeisclosed>:
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	57                   	push   %edi
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	83 ec 1c             	sub    $0x1c,%esp
  8017fa:	89 c7                	mov    %eax,%edi
  8017fc:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8017fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801803:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801806:	83 ec 0c             	sub    $0xc,%esp
  801809:	57                   	push   %edi
  80180a:	e8 1c 05 00 00       	call   801d2b <pageref>
  80180f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801812:	89 34 24             	mov    %esi,(%esp)
  801815:	e8 11 05 00 00       	call   801d2b <pageref>
		nn = thisenv->env_runs;
  80181a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801820:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	39 cb                	cmp    %ecx,%ebx
  801828:	74 1b                	je     801845 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80182a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80182d:	75 cf                	jne    8017fe <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80182f:	8b 42 58             	mov    0x58(%edx),%eax
  801832:	6a 01                	push   $0x1
  801834:	50                   	push   %eax
  801835:	53                   	push   %ebx
  801836:	68 32 24 80 00       	push   $0x802432
  80183b:	e8 7c ea ff ff       	call   8002bc <cprintf>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	eb b9                	jmp    8017fe <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801845:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801848:	0f 94 c0             	sete   %al
  80184b:	0f b6 c0             	movzbl %al,%eax
}
  80184e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801851:	5b                   	pop    %ebx
  801852:	5e                   	pop    %esi
  801853:	5f                   	pop    %edi
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <devpipe_write>:
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	57                   	push   %edi
  80185a:	56                   	push   %esi
  80185b:	53                   	push   %ebx
  80185c:	83 ec 28             	sub    $0x28,%esp
  80185f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801862:	56                   	push   %esi
  801863:	e8 2b f6 ff ff       	call   800e93 <fd2data>
  801868:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	bf 00 00 00 00       	mov    $0x0,%edi
  801872:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801875:	75 09                	jne    801880 <devpipe_write+0x2a>
	return i;
  801877:	89 f8                	mov    %edi,%eax
  801879:	eb 23                	jmp    80189e <devpipe_write+0x48>
			sys_yield();
  80187b:	e8 f3 f3 ff ff       	call   800c73 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801880:	8b 43 04             	mov    0x4(%ebx),%eax
  801883:	8b 0b                	mov    (%ebx),%ecx
  801885:	8d 51 20             	lea    0x20(%ecx),%edx
  801888:	39 d0                	cmp    %edx,%eax
  80188a:	72 1a                	jb     8018a6 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80188c:	89 da                	mov    %ebx,%edx
  80188e:	89 f0                	mov    %esi,%eax
  801890:	e8 5c ff ff ff       	call   8017f1 <_pipeisclosed>
  801895:	85 c0                	test   %eax,%eax
  801897:	74 e2                	je     80187b <devpipe_write+0x25>
				return 0;
  801899:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80189e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a1:	5b                   	pop    %ebx
  8018a2:	5e                   	pop    %esi
  8018a3:	5f                   	pop    %edi
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018ad:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018b0:	89 c2                	mov    %eax,%edx
  8018b2:	c1 fa 1f             	sar    $0x1f,%edx
  8018b5:	89 d1                	mov    %edx,%ecx
  8018b7:	c1 e9 1b             	shr    $0x1b,%ecx
  8018ba:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018bd:	83 e2 1f             	and    $0x1f,%edx
  8018c0:	29 ca                	sub    %ecx,%edx
  8018c2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018c6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018ca:	83 c0 01             	add    $0x1,%eax
  8018cd:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8018d0:	83 c7 01             	add    $0x1,%edi
  8018d3:	eb 9d                	jmp    801872 <devpipe_write+0x1c>

008018d5 <devpipe_read>:
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	57                   	push   %edi
  8018d9:	56                   	push   %esi
  8018da:	53                   	push   %ebx
  8018db:	83 ec 18             	sub    $0x18,%esp
  8018de:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018e1:	57                   	push   %edi
  8018e2:	e8 ac f5 ff ff       	call   800e93 <fd2data>
  8018e7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	be 00 00 00 00       	mov    $0x0,%esi
  8018f1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018f4:	75 13                	jne    801909 <devpipe_read+0x34>
	return i;
  8018f6:	89 f0                	mov    %esi,%eax
  8018f8:	eb 02                	jmp    8018fc <devpipe_read+0x27>
				return i;
  8018fa:	89 f0                	mov    %esi,%eax
}
  8018fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	5f                   	pop    %edi
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    
			sys_yield();
  801904:	e8 6a f3 ff ff       	call   800c73 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801909:	8b 03                	mov    (%ebx),%eax
  80190b:	3b 43 04             	cmp    0x4(%ebx),%eax
  80190e:	75 18                	jne    801928 <devpipe_read+0x53>
			if (i > 0)
  801910:	85 f6                	test   %esi,%esi
  801912:	75 e6                	jne    8018fa <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801914:	89 da                	mov    %ebx,%edx
  801916:	89 f8                	mov    %edi,%eax
  801918:	e8 d4 fe ff ff       	call   8017f1 <_pipeisclosed>
  80191d:	85 c0                	test   %eax,%eax
  80191f:	74 e3                	je     801904 <devpipe_read+0x2f>
				return 0;
  801921:	b8 00 00 00 00       	mov    $0x0,%eax
  801926:	eb d4                	jmp    8018fc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801928:	99                   	cltd   
  801929:	c1 ea 1b             	shr    $0x1b,%edx
  80192c:	01 d0                	add    %edx,%eax
  80192e:	83 e0 1f             	and    $0x1f,%eax
  801931:	29 d0                	sub    %edx,%eax
  801933:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801938:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80193b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80193e:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801941:	83 c6 01             	add    $0x1,%esi
  801944:	eb ab                	jmp    8018f1 <devpipe_read+0x1c>

00801946 <pipe>:
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	56                   	push   %esi
  80194a:	53                   	push   %ebx
  80194b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80194e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801951:	50                   	push   %eax
  801952:	e8 53 f5 ff ff       	call   800eaa <fd_alloc>
  801957:	89 c3                	mov    %eax,%ebx
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	85 c0                	test   %eax,%eax
  80195e:	0f 88 23 01 00 00    	js     801a87 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	68 07 04 00 00       	push   $0x407
  80196c:	ff 75 f4             	push   -0xc(%ebp)
  80196f:	6a 00                	push   $0x0
  801971:	e8 1c f3 ff ff       	call   800c92 <sys_page_alloc>
  801976:	89 c3                	mov    %eax,%ebx
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	85 c0                	test   %eax,%eax
  80197d:	0f 88 04 01 00 00    	js     801a87 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801989:	50                   	push   %eax
  80198a:	e8 1b f5 ff ff       	call   800eaa <fd_alloc>
  80198f:	89 c3                	mov    %eax,%ebx
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	85 c0                	test   %eax,%eax
  801996:	0f 88 db 00 00 00    	js     801a77 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80199c:	83 ec 04             	sub    $0x4,%esp
  80199f:	68 07 04 00 00       	push   $0x407
  8019a4:	ff 75 f0             	push   -0x10(%ebp)
  8019a7:	6a 00                	push   $0x0
  8019a9:	e8 e4 f2 ff ff       	call   800c92 <sys_page_alloc>
  8019ae:	89 c3                	mov    %eax,%ebx
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	0f 88 bc 00 00 00    	js     801a77 <pipe+0x131>
	va = fd2data(fd0);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	ff 75 f4             	push   -0xc(%ebp)
  8019c1:	e8 cd f4 ff ff       	call   800e93 <fd2data>
  8019c6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c8:	83 c4 0c             	add    $0xc,%esp
  8019cb:	68 07 04 00 00       	push   $0x407
  8019d0:	50                   	push   %eax
  8019d1:	6a 00                	push   $0x0
  8019d3:	e8 ba f2 ff ff       	call   800c92 <sys_page_alloc>
  8019d8:	89 c3                	mov    %eax,%ebx
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	0f 88 82 00 00 00    	js     801a67 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	ff 75 f0             	push   -0x10(%ebp)
  8019eb:	e8 a3 f4 ff ff       	call   800e93 <fd2data>
  8019f0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019f7:	50                   	push   %eax
  8019f8:	6a 00                	push   $0x0
  8019fa:	56                   	push   %esi
  8019fb:	6a 00                	push   $0x0
  8019fd:	e8 d3 f2 ff ff       	call   800cd5 <sys_page_map>
  801a02:	89 c3                	mov    %eax,%ebx
  801a04:	83 c4 20             	add    $0x20,%esp
  801a07:	85 c0                	test   %eax,%eax
  801a09:	78 4e                	js     801a59 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801a0b:	a1 24 30 80 00       	mov    0x803024,%eax
  801a10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a13:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801a15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a18:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801a1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a22:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a27:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	ff 75 f4             	push   -0xc(%ebp)
  801a34:	e8 4a f4 ff ff       	call   800e83 <fd2num>
  801a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a3c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a3e:	83 c4 04             	add    $0x4,%esp
  801a41:	ff 75 f0             	push   -0x10(%ebp)
  801a44:	e8 3a f4 ff ff       	call   800e83 <fd2num>
  801a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a4c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a57:	eb 2e                	jmp    801a87 <pipe+0x141>
	sys_page_unmap(0, va);
  801a59:	83 ec 08             	sub    $0x8,%esp
  801a5c:	56                   	push   %esi
  801a5d:	6a 00                	push   $0x0
  801a5f:	e8 b3 f2 ff ff       	call   800d17 <sys_page_unmap>
  801a64:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	ff 75 f0             	push   -0x10(%ebp)
  801a6d:	6a 00                	push   $0x0
  801a6f:	e8 a3 f2 ff ff       	call   800d17 <sys_page_unmap>
  801a74:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801a77:	83 ec 08             	sub    $0x8,%esp
  801a7a:	ff 75 f4             	push   -0xc(%ebp)
  801a7d:	6a 00                	push   $0x0
  801a7f:	e8 93 f2 ff ff       	call   800d17 <sys_page_unmap>
  801a84:	83 c4 10             	add    $0x10,%esp
}
  801a87:	89 d8                	mov    %ebx,%eax
  801a89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8c:	5b                   	pop    %ebx
  801a8d:	5e                   	pop    %esi
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <pipeisclosed>:
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a99:	50                   	push   %eax
  801a9a:	ff 75 08             	push   0x8(%ebp)
  801a9d:	e8 58 f4 ff ff       	call   800efa <fd_lookup>
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 18                	js     801ac1 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	ff 75 f4             	push   -0xc(%ebp)
  801aaf:	e8 df f3 ff ff       	call   800e93 <fd2data>
  801ab4:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab9:	e8 33 fd ff ff       	call   8017f1 <_pipeisclosed>
  801abe:	83 c4 10             	add    $0x10,%esp
}
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac8:	c3                   	ret    

00801ac9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801acf:	68 4a 24 80 00       	push   $0x80244a
  801ad4:	ff 75 0c             	push   0xc(%ebp)
  801ad7:	e8 ba ed ff ff       	call   800896 <strcpy>
	return 0;
}
  801adc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <devcons_write>:
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	57                   	push   %edi
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801aef:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801af4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801afa:	eb 2e                	jmp    801b2a <devcons_write+0x47>
		m = n - tot;
  801afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aff:	29 f3                	sub    %esi,%ebx
  801b01:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801b06:	39 c3                	cmp    %eax,%ebx
  801b08:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b0b:	83 ec 04             	sub    $0x4,%esp
  801b0e:	53                   	push   %ebx
  801b0f:	89 f0                	mov    %esi,%eax
  801b11:	03 45 0c             	add    0xc(%ebp),%eax
  801b14:	50                   	push   %eax
  801b15:	57                   	push   %edi
  801b16:	e8 11 ef ff ff       	call   800a2c <memmove>
		sys_cputs(buf, m);
  801b1b:	83 c4 08             	add    $0x8,%esp
  801b1e:	53                   	push   %ebx
  801b1f:	57                   	push   %edi
  801b20:	e8 b1 f0 ff ff       	call   800bd6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b25:	01 de                	add    %ebx,%esi
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b2d:	72 cd                	jb     801afc <devcons_write+0x19>
}
  801b2f:	89 f0                	mov    %esi,%eax
  801b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5e                   	pop    %esi
  801b36:	5f                   	pop    %edi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <devcons_read>:
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 08             	sub    $0x8,%esp
  801b3f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b48:	75 07                	jne    801b51 <devcons_read+0x18>
  801b4a:	eb 1f                	jmp    801b6b <devcons_read+0x32>
		sys_yield();
  801b4c:	e8 22 f1 ff ff       	call   800c73 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801b51:	e8 9e f0 ff ff       	call   800bf4 <sys_cgetc>
  801b56:	85 c0                	test   %eax,%eax
  801b58:	74 f2                	je     801b4c <devcons_read+0x13>
	if (c < 0)
  801b5a:	78 0f                	js     801b6b <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801b5c:	83 f8 04             	cmp    $0x4,%eax
  801b5f:	74 0c                	je     801b6d <devcons_read+0x34>
	*(char*)vbuf = c;
  801b61:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b64:	88 02                	mov    %al,(%edx)
	return 1;
  801b66:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801b6b:	c9                   	leave  
  801b6c:	c3                   	ret    
		return 0;
  801b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b72:	eb f7                	jmp    801b6b <devcons_read+0x32>

00801b74 <cputchar>:
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b80:	6a 01                	push   $0x1
  801b82:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b85:	50                   	push   %eax
  801b86:	e8 4b f0 ff ff       	call   800bd6 <sys_cputs>
}
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <getchar>:
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801b96:	6a 01                	push   $0x1
  801b98:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b9b:	50                   	push   %eax
  801b9c:	6a 00                	push   $0x0
  801b9e:	e8 bb f5 ff ff       	call   80115e <read>
	if (r < 0)
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 06                	js     801bb0 <getchar+0x20>
	if (r < 1)
  801baa:	74 06                	je     801bb2 <getchar+0x22>
	return c;
  801bac:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    
		return -E_EOF;
  801bb2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801bb7:	eb f7                	jmp    801bb0 <getchar+0x20>

00801bb9 <iscons>:
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc2:	50                   	push   %eax
  801bc3:	ff 75 08             	push   0x8(%ebp)
  801bc6:	e8 2f f3 ff ff       	call   800efa <fd_lookup>
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 11                	js     801be3 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd5:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801bdb:	39 10                	cmp    %edx,(%eax)
  801bdd:	0f 94 c0             	sete   %al
  801be0:	0f b6 c0             	movzbl %al,%eax
}
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <opencons>:
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801beb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bee:	50                   	push   %eax
  801bef:	e8 b6 f2 ff ff       	call   800eaa <fd_alloc>
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 3a                	js     801c35 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bfb:	83 ec 04             	sub    $0x4,%esp
  801bfe:	68 07 04 00 00       	push   $0x407
  801c03:	ff 75 f4             	push   -0xc(%ebp)
  801c06:	6a 00                	push   $0x0
  801c08:	e8 85 f0 ff ff       	call   800c92 <sys_page_alloc>
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	85 c0                	test   %eax,%eax
  801c12:	78 21                	js     801c35 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c17:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c1d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c22:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	50                   	push   %eax
  801c2d:	e8 51 f2 ff ff       	call   800e83 <fd2num>
  801c32:	83 c4 10             	add    $0x10,%esp
}
  801c35:	c9                   	leave  
  801c36:	c3                   	ret    

00801c37 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	56                   	push   %esi
  801c3b:	53                   	push   %ebx
  801c3c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801c45:	85 c0                	test   %eax,%eax
  801c47:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c4c:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	50                   	push   %eax
  801c53:	e8 ea f1 ff ff       	call   800e42 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	85 f6                	test   %esi,%esi
  801c5d:	74 14                	je     801c73 <ipc_recv+0x3c>
  801c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c64:	85 c0                	test   %eax,%eax
  801c66:	78 09                	js     801c71 <ipc_recv+0x3a>
  801c68:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c6e:	8b 52 74             	mov    0x74(%edx),%edx
  801c71:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801c73:	85 db                	test   %ebx,%ebx
  801c75:	74 14                	je     801c8b <ipc_recv+0x54>
  801c77:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	78 09                	js     801c89 <ipc_recv+0x52>
  801c80:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c86:	8b 52 78             	mov    0x78(%edx),%edx
  801c89:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	78 08                	js     801c97 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801c8f:	a1 04 40 80 00       	mov    0x804004,%eax
  801c94:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 0c             	sub    $0xc,%esp
  801ca7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801caa:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801cb0:	85 db                	test   %ebx,%ebx
  801cb2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801cb7:	0f 44 d8             	cmove  %eax,%ebx
  801cba:	eb 05                	jmp    801cc1 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801cbc:	e8 b2 ef ff ff       	call   800c73 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801cc1:	ff 75 14             	push   0x14(%ebp)
  801cc4:	53                   	push   %ebx
  801cc5:	56                   	push   %esi
  801cc6:	57                   	push   %edi
  801cc7:	e8 53 f1 ff ff       	call   800e1f <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cd2:	74 e8                	je     801cbc <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	78 08                	js     801ce0 <ipc_send+0x42>
	}while (r<0);

}
  801cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdb:	5b                   	pop    %ebx
  801cdc:	5e                   	pop    %esi
  801cdd:	5f                   	pop    %edi
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ce0:	50                   	push   %eax
  801ce1:	68 56 24 80 00       	push   $0x802456
  801ce6:	6a 3d                	push   $0x3d
  801ce8:	68 6a 24 80 00       	push   $0x80246a
  801ced:	e8 ef e4 ff ff       	call   8001e1 <_panic>

00801cf2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cf8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cfd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d00:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d06:	8b 52 50             	mov    0x50(%edx),%edx
  801d09:	39 ca                	cmp    %ecx,%edx
  801d0b:	74 11                	je     801d1e <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801d0d:	83 c0 01             	add    $0x1,%eax
  801d10:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d15:	75 e6                	jne    801cfd <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801d17:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1c:	eb 0b                	jmp    801d29 <ipc_find_env+0x37>
			return envs[i].env_id;
  801d1e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d21:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d26:	8b 40 48             	mov    0x48(%eax),%eax
}
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d31:	89 c2                	mov    %eax,%edx
  801d33:	c1 ea 16             	shr    $0x16,%edx
  801d36:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801d3d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801d42:	f6 c1 01             	test   $0x1,%cl
  801d45:	74 1c                	je     801d63 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801d47:	c1 e8 0c             	shr    $0xc,%eax
  801d4a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d51:	a8 01                	test   $0x1,%al
  801d53:	74 0e                	je     801d63 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d55:	c1 e8 0c             	shr    $0xc,%eax
  801d58:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801d5f:	ef 
  801d60:	0f b7 d2             	movzwl %dx,%edx
}
  801d63:	89 d0                	mov    %edx,%eax
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    
  801d67:	66 90                	xchg   %ax,%ax
  801d69:	66 90                	xchg   %ax,%ax
  801d6b:	66 90                	xchg   %ax,%ax
  801d6d:	66 90                	xchg   %ax,%ax
  801d6f:	90                   	nop

00801d70 <__udivdi3>:
  801d70:	f3 0f 1e fb          	endbr32 
  801d74:	55                   	push   %ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	83 ec 1c             	sub    $0x1c,%esp
  801d7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d83:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	75 19                	jne    801da8 <__udivdi3+0x38>
  801d8f:	39 f3                	cmp    %esi,%ebx
  801d91:	76 4d                	jbe    801de0 <__udivdi3+0x70>
  801d93:	31 ff                	xor    %edi,%edi
  801d95:	89 e8                	mov    %ebp,%eax
  801d97:	89 f2                	mov    %esi,%edx
  801d99:	f7 f3                	div    %ebx
  801d9b:	89 fa                	mov    %edi,%edx
  801d9d:	83 c4 1c             	add    $0x1c,%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	39 f0                	cmp    %esi,%eax
  801daa:	76 14                	jbe    801dc0 <__udivdi3+0x50>
  801dac:	31 ff                	xor    %edi,%edi
  801dae:	31 c0                	xor    %eax,%eax
  801db0:	89 fa                	mov    %edi,%edx
  801db2:	83 c4 1c             	add    $0x1c,%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5f                   	pop    %edi
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    
  801dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc0:	0f bd f8             	bsr    %eax,%edi
  801dc3:	83 f7 1f             	xor    $0x1f,%edi
  801dc6:	75 48                	jne    801e10 <__udivdi3+0xa0>
  801dc8:	39 f0                	cmp    %esi,%eax
  801dca:	72 06                	jb     801dd2 <__udivdi3+0x62>
  801dcc:	31 c0                	xor    %eax,%eax
  801dce:	39 eb                	cmp    %ebp,%ebx
  801dd0:	77 de                	ja     801db0 <__udivdi3+0x40>
  801dd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd7:	eb d7                	jmp    801db0 <__udivdi3+0x40>
  801dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de0:	89 d9                	mov    %ebx,%ecx
  801de2:	85 db                	test   %ebx,%ebx
  801de4:	75 0b                	jne    801df1 <__udivdi3+0x81>
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f3                	div    %ebx
  801def:	89 c1                	mov    %eax,%ecx
  801df1:	31 d2                	xor    %edx,%edx
  801df3:	89 f0                	mov    %esi,%eax
  801df5:	f7 f1                	div    %ecx
  801df7:	89 c6                	mov    %eax,%esi
  801df9:	89 e8                	mov    %ebp,%eax
  801dfb:	89 f7                	mov    %esi,%edi
  801dfd:	f7 f1                	div    %ecx
  801dff:	89 fa                	mov    %edi,%edx
  801e01:	83 c4 1c             	add    $0x1c,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	89 f9                	mov    %edi,%ecx
  801e12:	ba 20 00 00 00       	mov    $0x20,%edx
  801e17:	29 fa                	sub    %edi,%edx
  801e19:	d3 e0                	shl    %cl,%eax
  801e1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1f:	89 d1                	mov    %edx,%ecx
  801e21:	89 d8                	mov    %ebx,%eax
  801e23:	d3 e8                	shr    %cl,%eax
  801e25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e29:	09 c1                	or     %eax,%ecx
  801e2b:	89 f0                	mov    %esi,%eax
  801e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e31:	89 f9                	mov    %edi,%ecx
  801e33:	d3 e3                	shl    %cl,%ebx
  801e35:	89 d1                	mov    %edx,%ecx
  801e37:	d3 e8                	shr    %cl,%eax
  801e39:	89 f9                	mov    %edi,%ecx
  801e3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e3f:	89 eb                	mov    %ebp,%ebx
  801e41:	d3 e6                	shl    %cl,%esi
  801e43:	89 d1                	mov    %edx,%ecx
  801e45:	d3 eb                	shr    %cl,%ebx
  801e47:	09 f3                	or     %esi,%ebx
  801e49:	89 c6                	mov    %eax,%esi
  801e4b:	89 f2                	mov    %esi,%edx
  801e4d:	89 d8                	mov    %ebx,%eax
  801e4f:	f7 74 24 08          	divl   0x8(%esp)
  801e53:	89 d6                	mov    %edx,%esi
  801e55:	89 c3                	mov    %eax,%ebx
  801e57:	f7 64 24 0c          	mull   0xc(%esp)
  801e5b:	39 d6                	cmp    %edx,%esi
  801e5d:	72 19                	jb     801e78 <__udivdi3+0x108>
  801e5f:	89 f9                	mov    %edi,%ecx
  801e61:	d3 e5                	shl    %cl,%ebp
  801e63:	39 c5                	cmp    %eax,%ebp
  801e65:	73 04                	jae    801e6b <__udivdi3+0xfb>
  801e67:	39 d6                	cmp    %edx,%esi
  801e69:	74 0d                	je     801e78 <__udivdi3+0x108>
  801e6b:	89 d8                	mov    %ebx,%eax
  801e6d:	31 ff                	xor    %edi,%edi
  801e6f:	e9 3c ff ff ff       	jmp    801db0 <__udivdi3+0x40>
  801e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e78:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e7b:	31 ff                	xor    %edi,%edi
  801e7d:	e9 2e ff ff ff       	jmp    801db0 <__udivdi3+0x40>
  801e82:	66 90                	xchg   %ax,%ax
  801e84:	66 90                	xchg   %ax,%ax
  801e86:	66 90                	xchg   %ax,%ax
  801e88:	66 90                	xchg   %ax,%ax
  801e8a:	66 90                	xchg   %ax,%ax
  801e8c:	66 90                	xchg   %ax,%ax
  801e8e:	66 90                	xchg   %ax,%ax

00801e90 <__umoddi3>:
  801e90:	f3 0f 1e fb          	endbr32 
  801e94:	55                   	push   %ebp
  801e95:	57                   	push   %edi
  801e96:	56                   	push   %esi
  801e97:	53                   	push   %ebx
  801e98:	83 ec 1c             	sub    $0x1c,%esp
  801e9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801e9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ea3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801ea7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801eab:	89 f0                	mov    %esi,%eax
  801ead:	89 da                	mov    %ebx,%edx
  801eaf:	85 ff                	test   %edi,%edi
  801eb1:	75 15                	jne    801ec8 <__umoddi3+0x38>
  801eb3:	39 dd                	cmp    %ebx,%ebp
  801eb5:	76 39                	jbe    801ef0 <__umoddi3+0x60>
  801eb7:	f7 f5                	div    %ebp
  801eb9:	89 d0                	mov    %edx,%eax
  801ebb:	31 d2                	xor    %edx,%edx
  801ebd:	83 c4 1c             	add    $0x1c,%esp
  801ec0:	5b                   	pop    %ebx
  801ec1:	5e                   	pop    %esi
  801ec2:	5f                   	pop    %edi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    
  801ec5:	8d 76 00             	lea    0x0(%esi),%esi
  801ec8:	39 df                	cmp    %ebx,%edi
  801eca:	77 f1                	ja     801ebd <__umoddi3+0x2d>
  801ecc:	0f bd cf             	bsr    %edi,%ecx
  801ecf:	83 f1 1f             	xor    $0x1f,%ecx
  801ed2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ed6:	75 40                	jne    801f18 <__umoddi3+0x88>
  801ed8:	39 df                	cmp    %ebx,%edi
  801eda:	72 04                	jb     801ee0 <__umoddi3+0x50>
  801edc:	39 f5                	cmp    %esi,%ebp
  801ede:	77 dd                	ja     801ebd <__umoddi3+0x2d>
  801ee0:	89 da                	mov    %ebx,%edx
  801ee2:	89 f0                	mov    %esi,%eax
  801ee4:	29 e8                	sub    %ebp,%eax
  801ee6:	19 fa                	sbb    %edi,%edx
  801ee8:	eb d3                	jmp    801ebd <__umoddi3+0x2d>
  801eea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ef0:	89 e9                	mov    %ebp,%ecx
  801ef2:	85 ed                	test   %ebp,%ebp
  801ef4:	75 0b                	jne    801f01 <__umoddi3+0x71>
  801ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  801efb:	31 d2                	xor    %edx,%edx
  801efd:	f7 f5                	div    %ebp
  801eff:	89 c1                	mov    %eax,%ecx
  801f01:	89 d8                	mov    %ebx,%eax
  801f03:	31 d2                	xor    %edx,%edx
  801f05:	f7 f1                	div    %ecx
  801f07:	89 f0                	mov    %esi,%eax
  801f09:	f7 f1                	div    %ecx
  801f0b:	89 d0                	mov    %edx,%eax
  801f0d:	31 d2                	xor    %edx,%edx
  801f0f:	eb ac                	jmp    801ebd <__umoddi3+0x2d>
  801f11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f18:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f1c:	ba 20 00 00 00       	mov    $0x20,%edx
  801f21:	29 c2                	sub    %eax,%edx
  801f23:	89 c1                	mov    %eax,%ecx
  801f25:	89 e8                	mov    %ebp,%eax
  801f27:	d3 e7                	shl    %cl,%edi
  801f29:	89 d1                	mov    %edx,%ecx
  801f2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f2f:	d3 e8                	shr    %cl,%eax
  801f31:	89 c1                	mov    %eax,%ecx
  801f33:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f37:	09 f9                	or     %edi,%ecx
  801f39:	89 df                	mov    %ebx,%edi
  801f3b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f3f:	89 c1                	mov    %eax,%ecx
  801f41:	d3 e5                	shl    %cl,%ebp
  801f43:	89 d1                	mov    %edx,%ecx
  801f45:	d3 ef                	shr    %cl,%edi
  801f47:	89 c1                	mov    %eax,%ecx
  801f49:	89 f0                	mov    %esi,%eax
  801f4b:	d3 e3                	shl    %cl,%ebx
  801f4d:	89 d1                	mov    %edx,%ecx
  801f4f:	89 fa                	mov    %edi,%edx
  801f51:	d3 e8                	shr    %cl,%eax
  801f53:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f58:	09 d8                	or     %ebx,%eax
  801f5a:	f7 74 24 08          	divl   0x8(%esp)
  801f5e:	89 d3                	mov    %edx,%ebx
  801f60:	d3 e6                	shl    %cl,%esi
  801f62:	f7 e5                	mul    %ebp
  801f64:	89 c7                	mov    %eax,%edi
  801f66:	89 d1                	mov    %edx,%ecx
  801f68:	39 d3                	cmp    %edx,%ebx
  801f6a:	72 06                	jb     801f72 <__umoddi3+0xe2>
  801f6c:	75 0e                	jne    801f7c <__umoddi3+0xec>
  801f6e:	39 c6                	cmp    %eax,%esi
  801f70:	73 0a                	jae    801f7c <__umoddi3+0xec>
  801f72:	29 e8                	sub    %ebp,%eax
  801f74:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801f78:	89 d1                	mov    %edx,%ecx
  801f7a:	89 c7                	mov    %eax,%edi
  801f7c:	89 f5                	mov    %esi,%ebp
  801f7e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801f82:	29 fd                	sub    %edi,%ebp
  801f84:	19 cb                	sbb    %ecx,%ebx
  801f86:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801f8b:	89 d8                	mov    %ebx,%eax
  801f8d:	d3 e0                	shl    %cl,%eax
  801f8f:	89 f1                	mov    %esi,%ecx
  801f91:	d3 ed                	shr    %cl,%ebp
  801f93:	d3 eb                	shr    %cl,%ebx
  801f95:	09 e8                	or     %ebp,%eax
  801f97:	89 da                	mov    %ebx,%edx
  801f99:	83 c4 1c             	add    $0x1c,%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    
