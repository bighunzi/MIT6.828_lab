
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
  80004b:	e8 45 12 00 00       	call   801295 <write>
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
  800065:	e8 5d 11 00 00       	call   8011c7 <read>
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
  80008b:	68 a0 24 80 00       	push   $0x8024a0
  800090:	e8 37 17 00 00       	call   8017cc <printf>
			bol = 0;
  800095:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80009c:	00 00 00 
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	eb 9f                	jmp    800043 <num+0x10>
			panic("write error copying %s: %e", s, r);
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 75 0c             	push   0xc(%ebp)
  8000ab:	68 a5 24 80 00       	push   $0x8024a5
  8000b0:	6a 13                	push   $0x13
  8000b2:	68 c0 24 80 00       	push   $0x8024c0
  8000b7:	e8 28 01 00 00       	call   8001e4 <_panic>
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
  8000d8:	68 cb 24 80 00       	push   $0x8024cb
  8000dd:	6a 18                	push   $0x18
  8000df:	68 c0 24 80 00       	push   $0x8024c0
  8000e4:	e8 fb 00 00 00       	call   8001e4 <_panic>

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
  8000f2:	c7 05 04 30 80 00 e0 	movl   $0x8024e0,0x803004
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
  800112:	68 e4 24 80 00       	push   $0x8024e4
  800117:	6a 00                	push   $0x0
  800119:	e8 15 ff ff ff       	call   800033 <num>
  80011e:	83 c4 10             	add    $0x10,%esp
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800121:	e8 a4 00 00 00       	call   8001ca <exit>
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
  80013c:	e8 4a 0f 00 00       	call   80108b <close>
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
  800159:	e8 cc 14 00 00       	call   80162a <open>
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
  800170:	68 ec 24 80 00       	push   $0x8024ec
  800175:	6a 27                	push   $0x27
  800177:	68 c0 24 80 00       	push   $0x8024c0
  80017c:	e8 63 00 00 00       	call   8001e4 <_panic>

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
  80018c:	e8 c6 0a 00 00       	call   800c57 <sys_getenvid>
  800191:	25 ff 03 00 00       	and    $0x3ff,%eax
  800196:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80019c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a6:	85 db                	test   %ebx,%ebx
  8001a8:	7e 07                	jle    8001b1 <libmain+0x30>
		binaryname = argv[0];
  8001aa:	8b 06                	mov    (%esi),%eax
  8001ac:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b1:	83 ec 08             	sub    $0x8,%esp
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	e8 2e ff ff ff       	call   8000e9 <umain>

	// exit gracefully
	exit();
  8001bb:	e8 0a 00 00 00       	call   8001ca <exit>
}
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c6:	5b                   	pop    %ebx
  8001c7:	5e                   	pop    %esi
  8001c8:	5d                   	pop    %ebp
  8001c9:	c3                   	ret    

008001ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d0:	e8 e3 0e 00 00       	call   8010b8 <close_all>
	sys_env_destroy(0);
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	6a 00                	push   $0x0
  8001da:	e8 37 0a 00 00       	call   800c16 <sys_env_destroy>
}
  8001df:	83 c4 10             	add    $0x10,%esp
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ec:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f2:	e8 60 0a 00 00       	call   800c57 <sys_getenvid>
  8001f7:	83 ec 0c             	sub    $0xc,%esp
  8001fa:	ff 75 0c             	push   0xc(%ebp)
  8001fd:	ff 75 08             	push   0x8(%ebp)
  800200:	56                   	push   %esi
  800201:	50                   	push   %eax
  800202:	68 08 25 80 00       	push   $0x802508
  800207:	e8 b3 00 00 00       	call   8002bf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020c:	83 c4 18             	add    $0x18,%esp
  80020f:	53                   	push   %ebx
  800210:	ff 75 10             	push   0x10(%ebp)
  800213:	e8 56 00 00 00       	call   80026e <vcprintf>
	cprintf("\n");
  800218:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  80021f:	e8 9b 00 00 00       	call   8002bf <cprintf>
  800224:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800227:	cc                   	int3   
  800228:	eb fd                	jmp    800227 <_panic+0x43>

0080022a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	53                   	push   %ebx
  80022e:	83 ec 04             	sub    $0x4,%esp
  800231:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800234:	8b 13                	mov    (%ebx),%edx
  800236:	8d 42 01             	lea    0x1(%edx),%eax
  800239:	89 03                	mov    %eax,(%ebx)
  80023b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800242:	3d ff 00 00 00       	cmp    $0xff,%eax
  800247:	74 09                	je     800252 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800249:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80024d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800250:	c9                   	leave  
  800251:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800252:	83 ec 08             	sub    $0x8,%esp
  800255:	68 ff 00 00 00       	push   $0xff
  80025a:	8d 43 08             	lea    0x8(%ebx),%eax
  80025d:	50                   	push   %eax
  80025e:	e8 76 09 00 00       	call   800bd9 <sys_cputs>
		b->idx = 0;
  800263:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	eb db                	jmp    800249 <putch+0x1f>

0080026e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800277:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027e:	00 00 00 
	b.cnt = 0;
  800281:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800288:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028b:	ff 75 0c             	push   0xc(%ebp)
  80028e:	ff 75 08             	push   0x8(%ebp)
  800291:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800297:	50                   	push   %eax
  800298:	68 2a 02 80 00       	push   $0x80022a
  80029d:	e8 14 01 00 00       	call   8003b6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a2:	83 c4 08             	add    $0x8,%esp
  8002a5:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b1:	50                   	push   %eax
  8002b2:	e8 22 09 00 00       	call   800bd9 <sys_cputs>

	return b.cnt;
}
  8002b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c8:	50                   	push   %eax
  8002c9:	ff 75 08             	push   0x8(%ebp)
  8002cc:	e8 9d ff ff ff       	call   80026e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d1:	c9                   	leave  
  8002d2:	c3                   	ret    

008002d3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	57                   	push   %edi
  8002d7:	56                   	push   %esi
  8002d8:	53                   	push   %ebx
  8002d9:	83 ec 1c             	sub    $0x1c,%esp
  8002dc:	89 c7                	mov    %eax,%edi
  8002de:	89 d6                	mov    %edx,%esi
  8002e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e6:	89 d1                	mov    %edx,%ecx
  8002e8:	89 c2                	mov    %eax,%edx
  8002ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800300:	39 c2                	cmp    %eax,%edx
  800302:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800305:	72 3e                	jb     800345 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800307:	83 ec 0c             	sub    $0xc,%esp
  80030a:	ff 75 18             	push   0x18(%ebp)
  80030d:	83 eb 01             	sub    $0x1,%ebx
  800310:	53                   	push   %ebx
  800311:	50                   	push   %eax
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	push   -0x1c(%ebp)
  800318:	ff 75 e0             	push   -0x20(%ebp)
  80031b:	ff 75 dc             	push   -0x24(%ebp)
  80031e:	ff 75 d8             	push   -0x28(%ebp)
  800321:	e8 2a 1f 00 00       	call   802250 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9f ff ff ff       	call   8002d3 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 13                	jmp    80034c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	push   0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800345:	83 eb 01             	sub    $0x1,%ebx
  800348:	85 db                	test   %ebx,%ebx
  80034a:	7f ed                	jg     800339 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	56                   	push   %esi
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	ff 75 e4             	push   -0x1c(%ebp)
  800356:	ff 75 e0             	push   -0x20(%ebp)
  800359:	ff 75 dc             	push   -0x24(%ebp)
  80035c:	ff 75 d8             	push   -0x28(%ebp)
  80035f:	e8 0c 20 00 00       	call   802370 <__umoddi3>
  800364:	83 c4 14             	add    $0x14,%esp
  800367:	0f be 80 2b 25 80 00 	movsbl 0x80252b(%eax),%eax
  80036e:	50                   	push   %eax
  80036f:	ff d7                	call   *%edi
}
  800371:	83 c4 10             	add    $0x10,%esp
  800374:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800382:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800386:	8b 10                	mov    (%eax),%edx
  800388:	3b 50 04             	cmp    0x4(%eax),%edx
  80038b:	73 0a                	jae    800397 <sprintputch+0x1b>
		*b->buf++ = ch;
  80038d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800390:	89 08                	mov    %ecx,(%eax)
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	88 02                	mov    %al,(%edx)
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <printfmt>:
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80039f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a2:	50                   	push   %eax
  8003a3:	ff 75 10             	push   0x10(%ebp)
  8003a6:	ff 75 0c             	push   0xc(%ebp)
  8003a9:	ff 75 08             	push   0x8(%ebp)
  8003ac:	e8 05 00 00 00       	call   8003b6 <vprintfmt>
}
  8003b1:	83 c4 10             	add    $0x10,%esp
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    

008003b6 <vprintfmt>:
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	57                   	push   %edi
  8003ba:	56                   	push   %esi
  8003bb:	53                   	push   %ebx
  8003bc:	83 ec 3c             	sub    $0x3c,%esp
  8003bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c8:	eb 0a                	jmp    8003d4 <vprintfmt+0x1e>
			putch(ch, putdat);
  8003ca:	83 ec 08             	sub    $0x8,%esp
  8003cd:	53                   	push   %ebx
  8003ce:	50                   	push   %eax
  8003cf:	ff d6                	call   *%esi
  8003d1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d4:	83 c7 01             	add    $0x1,%edi
  8003d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003db:	83 f8 25             	cmp    $0x25,%eax
  8003de:	74 0c                	je     8003ec <vprintfmt+0x36>
			if (ch == '\0')
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	75 e6                	jne    8003ca <vprintfmt+0x14>
}
  8003e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e7:	5b                   	pop    %ebx
  8003e8:	5e                   	pop    %esi
  8003e9:	5f                   	pop    %edi
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    
		padc = ' ';
  8003ec:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003f0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003f7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800405:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8d 47 01             	lea    0x1(%edi),%eax
  80040d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800410:	0f b6 17             	movzbl (%edi),%edx
  800413:	8d 42 dd             	lea    -0x23(%edx),%eax
  800416:	3c 55                	cmp    $0x55,%al
  800418:	0f 87 bb 03 00 00    	ja     8007d9 <vprintfmt+0x423>
  80041e:	0f b6 c0             	movzbl %al,%eax
  800421:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80042b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80042f:	eb d9                	jmp    80040a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800434:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800438:	eb d0                	jmp    80040a <vprintfmt+0x54>
  80043a:	0f b6 d2             	movzbl %dl,%edx
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800440:	b8 00 00 00 00       	mov    $0x0,%eax
  800445:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800448:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80044f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800452:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800455:	83 f9 09             	cmp    $0x9,%ecx
  800458:	77 55                	ja     8004af <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80045a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80045d:	eb e9                	jmp    800448 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	8b 00                	mov    (%eax),%eax
  800464:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 40 04             	lea    0x4(%eax),%eax
  80046d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800473:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800477:	79 91                	jns    80040a <vprintfmt+0x54>
				width = precision, precision = -1;
  800479:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80047c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800486:	eb 82                	jmp    80040a <vprintfmt+0x54>
  800488:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80048b:	85 d2                	test   %edx,%edx
  80048d:	b8 00 00 00 00       	mov    $0x0,%eax
  800492:	0f 49 c2             	cmovns %edx,%eax
  800495:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80049b:	e9 6a ff ff ff       	jmp    80040a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004a3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004aa:	e9 5b ff ff ff       	jmp    80040a <vprintfmt+0x54>
  8004af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b5:	eb bc                	jmp    800473 <vprintfmt+0xbd>
			lflag++;
  8004b7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004bd:	e9 48 ff ff ff       	jmp    80040a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 78 04             	lea    0x4(%eax),%edi
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	53                   	push   %ebx
  8004cc:	ff 30                	push   (%eax)
  8004ce:	ff d6                	call   *%esi
			break;
  8004d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004d6:	e9 9d 02 00 00       	jmp    800778 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 78 04             	lea    0x4(%eax),%edi
  8004e1:	8b 10                	mov    (%eax),%edx
  8004e3:	89 d0                	mov    %edx,%eax
  8004e5:	f7 d8                	neg    %eax
  8004e7:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ea:	83 f8 0f             	cmp    $0xf,%eax
  8004ed:	7f 23                	jg     800512 <vprintfmt+0x15c>
  8004ef:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  8004f6:	85 d2                	test   %edx,%edx
  8004f8:	74 18                	je     800512 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004fa:	52                   	push   %edx
  8004fb:	68 f5 28 80 00       	push   $0x8028f5
  800500:	53                   	push   %ebx
  800501:	56                   	push   %esi
  800502:	e8 92 fe ff ff       	call   800399 <printfmt>
  800507:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80050a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80050d:	e9 66 02 00 00       	jmp    800778 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800512:	50                   	push   %eax
  800513:	68 43 25 80 00       	push   $0x802543
  800518:	53                   	push   %ebx
  800519:	56                   	push   %esi
  80051a:	e8 7a fe ff ff       	call   800399 <printfmt>
  80051f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800522:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800525:	e9 4e 02 00 00       	jmp    800778 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	83 c0 04             	add    $0x4,%eax
  800530:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800538:	85 d2                	test   %edx,%edx
  80053a:	b8 3c 25 80 00       	mov    $0x80253c,%eax
  80053f:	0f 45 c2             	cmovne %edx,%eax
  800542:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800545:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800549:	7e 06                	jle    800551 <vprintfmt+0x19b>
  80054b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80054f:	75 0d                	jne    80055e <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800551:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800554:	89 c7                	mov    %eax,%edi
  800556:	03 45 e0             	add    -0x20(%ebp),%eax
  800559:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055c:	eb 55                	jmp    8005b3 <vprintfmt+0x1fd>
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 d8             	push   -0x28(%ebp)
  800564:	ff 75 cc             	push   -0x34(%ebp)
  800567:	e8 0a 03 00 00       	call   800876 <strnlen>
  80056c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056f:	29 c1                	sub    %eax,%ecx
  800571:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800579:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80057d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800580:	eb 0f                	jmp    800591 <vprintfmt+0x1db>
					putch(padc, putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	53                   	push   %ebx
  800586:	ff 75 e0             	push   -0x20(%ebp)
  800589:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	83 ef 01             	sub    $0x1,%edi
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	85 ff                	test   %edi,%edi
  800593:	7f ed                	jg     800582 <vprintfmt+0x1cc>
  800595:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800598:	85 d2                	test   %edx,%edx
  80059a:	b8 00 00 00 00       	mov    $0x0,%eax
  80059f:	0f 49 c2             	cmovns %edx,%eax
  8005a2:	29 c2                	sub    %eax,%edx
  8005a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005a7:	eb a8                	jmp    800551 <vprintfmt+0x19b>
					putch(ch, putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	52                   	push   %edx
  8005ae:	ff d6                	call   *%esi
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b8:	83 c7 01             	add    $0x1,%edi
  8005bb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005bf:	0f be d0             	movsbl %al,%edx
  8005c2:	85 d2                	test   %edx,%edx
  8005c4:	74 4b                	je     800611 <vprintfmt+0x25b>
  8005c6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ca:	78 06                	js     8005d2 <vprintfmt+0x21c>
  8005cc:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005d0:	78 1e                	js     8005f0 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d6:	74 d1                	je     8005a9 <vprintfmt+0x1f3>
  8005d8:	0f be c0             	movsbl %al,%eax
  8005db:	83 e8 20             	sub    $0x20,%eax
  8005de:	83 f8 5e             	cmp    $0x5e,%eax
  8005e1:	76 c6                	jbe    8005a9 <vprintfmt+0x1f3>
					putch('?', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 3f                	push   $0x3f
  8005e9:	ff d6                	call   *%esi
  8005eb:	83 c4 10             	add    $0x10,%esp
  8005ee:	eb c3                	jmp    8005b3 <vprintfmt+0x1fd>
  8005f0:	89 cf                	mov    %ecx,%edi
  8005f2:	eb 0e                	jmp    800602 <vprintfmt+0x24c>
				putch(' ', putdat);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	6a 20                	push   $0x20
  8005fa:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005fc:	83 ef 01             	sub    $0x1,%edi
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	85 ff                	test   %edi,%edi
  800604:	7f ee                	jg     8005f4 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800606:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
  80060c:	e9 67 01 00 00       	jmp    800778 <vprintfmt+0x3c2>
  800611:	89 cf                	mov    %ecx,%edi
  800613:	eb ed                	jmp    800602 <vprintfmt+0x24c>
	if (lflag >= 2)
  800615:	83 f9 01             	cmp    $0x1,%ecx
  800618:	7f 1b                	jg     800635 <vprintfmt+0x27f>
	else if (lflag)
  80061a:	85 c9                	test   %ecx,%ecx
  80061c:	74 63                	je     800681 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	99                   	cltd   
  800627:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 40 04             	lea    0x4(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
  800633:	eb 17                	jmp    80064c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 50 04             	mov    0x4(%eax),%edx
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800640:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 40 08             	lea    0x8(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80064c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800652:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800657:	85 c9                	test   %ecx,%ecx
  800659:	0f 89 ff 00 00 00    	jns    80075e <vprintfmt+0x3a8>
				putch('-', putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	6a 2d                	push   $0x2d
  800665:	ff d6                	call   *%esi
				num = -(long long) num;
  800667:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80066a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80066d:	f7 da                	neg    %edx
  80066f:	83 d1 00             	adc    $0x0,%ecx
  800672:	f7 d9                	neg    %ecx
  800674:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800677:	bf 0a 00 00 00       	mov    $0xa,%edi
  80067c:	e9 dd 00 00 00       	jmp    80075e <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 00                	mov    (%eax),%eax
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	99                   	cltd   
  80068a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
  800696:	eb b4                	jmp    80064c <vprintfmt+0x296>
	if (lflag >= 2)
  800698:	83 f9 01             	cmp    $0x1,%ecx
  80069b:	7f 1e                	jg     8006bb <vprintfmt+0x305>
	else if (lflag)
  80069d:	85 c9                	test   %ecx,%ecx
  80069f:	74 32                	je     8006d3 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8b 10                	mov    (%eax),%edx
  8006a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ab:	8d 40 04             	lea    0x4(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8006b6:	e9 a3 00 00 00       	jmp    80075e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8b 10                	mov    (%eax),%edx
  8006c0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c3:	8d 40 08             	lea    0x8(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8006ce:	e9 8b 00 00 00       	jmp    80075e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8006e8:	eb 74                	jmp    80075e <vprintfmt+0x3a8>
	if (lflag >= 2)
  8006ea:	83 f9 01             	cmp    $0x1,%ecx
  8006ed:	7f 1b                	jg     80070a <vprintfmt+0x354>
	else if (lflag)
  8006ef:	85 c9                	test   %ecx,%ecx
  8006f1:	74 2c                	je     80071f <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 10                	mov    (%eax),%edx
  8006f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fd:	8d 40 04             	lea    0x4(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800703:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800708:	eb 54                	jmp    80075e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8b 10                	mov    (%eax),%edx
  80070f:	8b 48 04             	mov    0x4(%eax),%ecx
  800712:	8d 40 08             	lea    0x8(%eax),%eax
  800715:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800718:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80071d:	eb 3f                	jmp    80075e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8b 10                	mov    (%eax),%edx
  800724:	b9 00 00 00 00       	mov    $0x0,%ecx
  800729:	8d 40 04             	lea    0x4(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80072f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800734:	eb 28                	jmp    80075e <vprintfmt+0x3a8>
			putch('0', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 30                	push   $0x30
  80073c:	ff d6                	call   *%esi
			putch('x', putdat);
  80073e:	83 c4 08             	add    $0x8,%esp
  800741:	53                   	push   %ebx
  800742:	6a 78                	push   $0x78
  800744:	ff d6                	call   *%esi
			num = (unsigned long long)
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8b 10                	mov    (%eax),%edx
  80074b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800750:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800753:	8d 40 04             	lea    0x4(%eax),%eax
  800756:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800759:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80075e:	83 ec 0c             	sub    $0xc,%esp
  800761:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800765:	50                   	push   %eax
  800766:	ff 75 e0             	push   -0x20(%ebp)
  800769:	57                   	push   %edi
  80076a:	51                   	push   %ecx
  80076b:	52                   	push   %edx
  80076c:	89 da                	mov    %ebx,%edx
  80076e:	89 f0                	mov    %esi,%eax
  800770:	e8 5e fb ff ff       	call   8002d3 <printnum>
			break;
  800775:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800778:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80077b:	e9 54 fc ff ff       	jmp    8003d4 <vprintfmt+0x1e>
	if (lflag >= 2)
  800780:	83 f9 01             	cmp    $0x1,%ecx
  800783:	7f 1b                	jg     8007a0 <vprintfmt+0x3ea>
	else if (lflag)
  800785:	85 c9                	test   %ecx,%ecx
  800787:	74 2c                	je     8007b5 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8b 10                	mov    (%eax),%edx
  80078e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800793:	8d 40 04             	lea    0x4(%eax),%eax
  800796:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800799:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80079e:	eb be                	jmp    80075e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 10                	mov    (%eax),%edx
  8007a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8007a8:	8d 40 08             	lea    0x8(%eax),%eax
  8007ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ae:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8007b3:	eb a9                	jmp    80075e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8b 10                	mov    (%eax),%edx
  8007ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bf:	8d 40 04             	lea    0x4(%eax),%eax
  8007c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8007ca:	eb 92                	jmp    80075e <vprintfmt+0x3a8>
			putch(ch, putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	6a 25                	push   $0x25
  8007d2:	ff d6                	call   *%esi
			break;
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	eb 9f                	jmp    800778 <vprintfmt+0x3c2>
			putch('%', putdat);
  8007d9:	83 ec 08             	sub    $0x8,%esp
  8007dc:	53                   	push   %ebx
  8007dd:	6a 25                	push   $0x25
  8007df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e1:	83 c4 10             	add    $0x10,%esp
  8007e4:	89 f8                	mov    %edi,%eax
  8007e6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ea:	74 05                	je     8007f1 <vprintfmt+0x43b>
  8007ec:	83 e8 01             	sub    $0x1,%eax
  8007ef:	eb f5                	jmp    8007e6 <vprintfmt+0x430>
  8007f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f4:	eb 82                	jmp    800778 <vprintfmt+0x3c2>

008007f6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	83 ec 18             	sub    $0x18,%esp
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800802:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800805:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800809:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800813:	85 c0                	test   %eax,%eax
  800815:	74 26                	je     80083d <vsnprintf+0x47>
  800817:	85 d2                	test   %edx,%edx
  800819:	7e 22                	jle    80083d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081b:	ff 75 14             	push   0x14(%ebp)
  80081e:	ff 75 10             	push   0x10(%ebp)
  800821:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	68 7c 03 80 00       	push   $0x80037c
  80082a:	e8 87 fb ff ff       	call   8003b6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800832:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800835:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800838:	83 c4 10             	add    $0x10,%esp
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    
		return -E_INVAL;
  80083d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800842:	eb f7                	jmp    80083b <vsnprintf+0x45>

00800844 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084d:	50                   	push   %eax
  80084e:	ff 75 10             	push   0x10(%ebp)
  800851:	ff 75 0c             	push   0xc(%ebp)
  800854:	ff 75 08             	push   0x8(%ebp)
  800857:	e8 9a ff ff ff       	call   8007f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
  800869:	eb 03                	jmp    80086e <strlen+0x10>
		n++;
  80086b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80086e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800872:	75 f7                	jne    80086b <strlen+0xd>
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	eb 03                	jmp    800889 <strnlen+0x13>
		n++;
  800886:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800889:	39 d0                	cmp    %edx,%eax
  80088b:	74 08                	je     800895 <strnlen+0x1f>
  80088d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800891:	75 f3                	jne    800886 <strnlen+0x10>
  800893:	89 c2                	mov    %eax,%edx
	return n;
}
  800895:	89 d0                	mov    %edx,%eax
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008ac:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b6:	89 c8                	mov    %ecx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	53                   	push   %ebx
  8008c1:	83 ec 10             	sub    $0x10,%esp
  8008c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c7:	53                   	push   %ebx
  8008c8:	e8 91 ff ff ff       	call   80085e <strlen>
  8008cd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008d0:	ff 75 0c             	push   0xc(%ebp)
  8008d3:	01 d8                	add    %ebx,%eax
  8008d5:	50                   	push   %eax
  8008d6:	e8 be ff ff ff       	call   800899 <strcpy>
	return dst;
}
  8008db:	89 d8                	mov    %ebx,%eax
  8008dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 f3                	mov    %esi,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f2:	89 f0                	mov    %esi,%eax
  8008f4:	eb 0f                	jmp    800905 <strncpy+0x23>
		*dst++ = *src;
  8008f6:	83 c0 01             	add    $0x1,%eax
  8008f9:	0f b6 0a             	movzbl (%edx),%ecx
  8008fc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ff:	80 f9 01             	cmp    $0x1,%cl
  800902:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800905:	39 d8                	cmp    %ebx,%eax
  800907:	75 ed                	jne    8008f6 <strncpy+0x14>
	}
	return ret;
}
  800909:	89 f0                	mov    %esi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 75 08             	mov    0x8(%ebp),%esi
  800917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091a:	8b 55 10             	mov    0x10(%ebp),%edx
  80091d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091f:	85 d2                	test   %edx,%edx
  800921:	74 21                	je     800944 <strlcpy+0x35>
  800923:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800927:	89 f2                	mov    %esi,%edx
  800929:	eb 09                	jmp    800934 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092b:	83 c1 01             	add    $0x1,%ecx
  80092e:	83 c2 01             	add    $0x1,%edx
  800931:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800934:	39 c2                	cmp    %eax,%edx
  800936:	74 09                	je     800941 <strlcpy+0x32>
  800938:	0f b6 19             	movzbl (%ecx),%ebx
  80093b:	84 db                	test   %bl,%bl
  80093d:	75 ec                	jne    80092b <strlcpy+0x1c>
  80093f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800941:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800944:	29 f0                	sub    %esi,%eax
}
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800953:	eb 06                	jmp    80095b <strcmp+0x11>
		p++, q++;
  800955:	83 c1 01             	add    $0x1,%ecx
  800958:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80095b:	0f b6 01             	movzbl (%ecx),%eax
  80095e:	84 c0                	test   %al,%al
  800960:	74 04                	je     800966 <strcmp+0x1c>
  800962:	3a 02                	cmp    (%edx),%al
  800964:	74 ef                	je     800955 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800966:	0f b6 c0             	movzbl %al,%eax
  800969:	0f b6 12             	movzbl (%edx),%edx
  80096c:	29 d0                	sub    %edx,%eax
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097a:	89 c3                	mov    %eax,%ebx
  80097c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80097f:	eb 06                	jmp    800987 <strncmp+0x17>
		n--, p++, q++;
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800987:	39 d8                	cmp    %ebx,%eax
  800989:	74 18                	je     8009a3 <strncmp+0x33>
  80098b:	0f b6 08             	movzbl (%eax),%ecx
  80098e:	84 c9                	test   %cl,%cl
  800990:	74 04                	je     800996 <strncmp+0x26>
  800992:	3a 0a                	cmp    (%edx),%cl
  800994:	74 eb                	je     800981 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800996:	0f b6 00             	movzbl (%eax),%eax
  800999:	0f b6 12             	movzbl (%edx),%edx
  80099c:	29 d0                	sub    %edx,%eax
}
  80099e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    
		return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a8:	eb f4                	jmp    80099e <strncmp+0x2e>

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 03                	jmp    8009b9 <strchr+0xf>
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	0f b6 10             	movzbl (%eax),%edx
  8009bc:	84 d2                	test   %dl,%dl
  8009be:	74 06                	je     8009c6 <strchr+0x1c>
		if (*s == c)
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
  8009c4:	eb 05                	jmp    8009cb <strchr+0x21>
			return (char *) s;
	return 0;
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009da:	38 ca                	cmp    %cl,%dl
  8009dc:	74 09                	je     8009e7 <strfind+0x1a>
  8009de:	84 d2                	test   %dl,%dl
  8009e0:	74 05                	je     8009e7 <strfind+0x1a>
	for (; *s; s++)
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	eb f0                	jmp    8009d7 <strfind+0xa>
			break;
	return (char *) s;
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	57                   	push   %edi
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f5:	85 c9                	test   %ecx,%ecx
  8009f7:	74 2f                	je     800a28 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f9:	89 f8                	mov    %edi,%eax
  8009fb:	09 c8                	or     %ecx,%eax
  8009fd:	a8 03                	test   $0x3,%al
  8009ff:	75 21                	jne    800a22 <memset+0x39>
		c &= 0xFF;
  800a01:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a05:	89 d0                	mov    %edx,%eax
  800a07:	c1 e0 08             	shl    $0x8,%eax
  800a0a:	89 d3                	mov    %edx,%ebx
  800a0c:	c1 e3 18             	shl    $0x18,%ebx
  800a0f:	89 d6                	mov    %edx,%esi
  800a11:	c1 e6 10             	shl    $0x10,%esi
  800a14:	09 f3                	or     %esi,%ebx
  800a16:	09 da                	or     %ebx,%edx
  800a18:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a1a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a1d:	fc                   	cld    
  800a1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a20:	eb 06                	jmp    800a28 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a25:	fc                   	cld    
  800a26:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a28:	89 f8                	mov    %edi,%eax
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5f                   	pop    %edi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3d:	39 c6                	cmp    %eax,%esi
  800a3f:	73 32                	jae    800a73 <memmove+0x44>
  800a41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a44:	39 c2                	cmp    %eax,%edx
  800a46:	76 2b                	jbe    800a73 <memmove+0x44>
		s += n;
		d += n;
  800a48:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4b:	89 d6                	mov    %edx,%esi
  800a4d:	09 fe                	or     %edi,%esi
  800a4f:	09 ce                	or     %ecx,%esi
  800a51:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a57:	75 0e                	jne    800a67 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a59:	83 ef 04             	sub    $0x4,%edi
  800a5c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a62:	fd                   	std    
  800a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a65:	eb 09                	jmp    800a70 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a67:	83 ef 01             	sub    $0x1,%edi
  800a6a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6d:	fd                   	std    
  800a6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a70:	fc                   	cld    
  800a71:	eb 1a                	jmp    800a8d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a73:	89 f2                	mov    %esi,%edx
  800a75:	09 c2                	or     %eax,%edx
  800a77:	09 ca                	or     %ecx,%edx
  800a79:	f6 c2 03             	test   $0x3,%dl
  800a7c:	75 0a                	jne    800a88 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a81:	89 c7                	mov    %eax,%edi
  800a83:	fc                   	cld    
  800a84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a86:	eb 05                	jmp    800a8d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a88:	89 c7                	mov    %eax,%edi
  800a8a:	fc                   	cld    
  800a8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a97:	ff 75 10             	push   0x10(%ebp)
  800a9a:	ff 75 0c             	push   0xc(%ebp)
  800a9d:	ff 75 08             	push   0x8(%ebp)
  800aa0:	e8 8a ff ff ff       	call   800a2f <memmove>
}
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab2:	89 c6                	mov    %eax,%esi
  800ab4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab7:	eb 06                	jmp    800abf <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800abf:	39 f0                	cmp    %esi,%eax
  800ac1:	74 14                	je     800ad7 <memcmp+0x30>
		if (*s1 != *s2)
  800ac3:	0f b6 08             	movzbl (%eax),%ecx
  800ac6:	0f b6 1a             	movzbl (%edx),%ebx
  800ac9:	38 d9                	cmp    %bl,%cl
  800acb:	74 ec                	je     800ab9 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800acd:	0f b6 c1             	movzbl %cl,%eax
  800ad0:	0f b6 db             	movzbl %bl,%ebx
  800ad3:	29 d8                	sub    %ebx,%eax
  800ad5:	eb 05                	jmp    800adc <memcmp+0x35>
	}

	return 0;
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae9:	89 c2                	mov    %eax,%edx
  800aeb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aee:	eb 03                	jmp    800af3 <memfind+0x13>
  800af0:	83 c0 01             	add    $0x1,%eax
  800af3:	39 d0                	cmp    %edx,%eax
  800af5:	73 04                	jae    800afb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af7:	38 08                	cmp    %cl,(%eax)
  800af9:	75 f5                	jne    800af0 <memfind+0x10>
			break;
	return (void *) s;
}
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b09:	eb 03                	jmp    800b0e <strtol+0x11>
		s++;
  800b0b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b0e:	0f b6 02             	movzbl (%edx),%eax
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f6                	je     800b0b <strtol+0xe>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f2                	je     800b0b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	74 2a                	je     800b47 <strtol+0x4a>
	int neg = 0;
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b22:	3c 2d                	cmp    $0x2d,%al
  800b24:	74 2b                	je     800b51 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b2c:	75 0f                	jne    800b3d <strtol+0x40>
  800b2e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b31:	74 28                	je     800b5b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b33:	85 db                	test   %ebx,%ebx
  800b35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3a:	0f 44 d8             	cmove  %eax,%ebx
  800b3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b42:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b45:	eb 46                	jmp    800b8d <strtol+0x90>
		s++;
  800b47:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4f:	eb d5                	jmp    800b26 <strtol+0x29>
		s++, neg = 1;
  800b51:	83 c2 01             	add    $0x1,%edx
  800b54:	bf 01 00 00 00       	mov    $0x1,%edi
  800b59:	eb cb                	jmp    800b26 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b5f:	74 0e                	je     800b6f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b61:	85 db                	test   %ebx,%ebx
  800b63:	75 d8                	jne    800b3d <strtol+0x40>
		s++, base = 8;
  800b65:	83 c2 01             	add    $0x1,%edx
  800b68:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b6d:	eb ce                	jmp    800b3d <strtol+0x40>
		s += 2, base = 16;
  800b6f:	83 c2 02             	add    $0x2,%edx
  800b72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b77:	eb c4                	jmp    800b3d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b79:	0f be c0             	movsbl %al,%eax
  800b7c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b82:	7d 3a                	jge    800bbe <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b84:	83 c2 01             	add    $0x1,%edx
  800b87:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b8b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b8d:	0f b6 02             	movzbl (%edx),%eax
  800b90:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b93:	89 f3                	mov    %esi,%ebx
  800b95:	80 fb 09             	cmp    $0x9,%bl
  800b98:	76 df                	jbe    800b79 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b9a:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 19             	cmp    $0x19,%bl
  800ba2:	77 08                	ja     800bac <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ba4:	0f be c0             	movsbl %al,%eax
  800ba7:	83 e8 57             	sub    $0x57,%eax
  800baa:	eb d3                	jmp    800b7f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bac:	8d 70 bf             	lea    -0x41(%eax),%esi
  800baf:	89 f3                	mov    %esi,%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bb6:	0f be c0             	movsbl %al,%eax
  800bb9:	83 e8 37             	sub    $0x37,%eax
  800bbc:	eb c1                	jmp    800b7f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bbe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc2:	74 05                	je     800bc9 <strtol+0xcc>
		*endptr = (char *) s;
  800bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bc9:	89 c8                	mov    %ecx,%eax
  800bcb:	f7 d8                	neg    %eax
  800bcd:	85 ff                	test   %edi,%edi
  800bcf:	0f 45 c8             	cmovne %eax,%ecx
}
  800bd2:	89 c8                	mov    %ecx,%eax
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bea:	89 c3                	mov    %eax,%ebx
  800bec:	89 c7                	mov    %eax,%edi
  800bee:	89 c6                	mov    %eax,%esi
  800bf0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800c02:	b8 01 00 00 00       	mov    $0x1,%eax
  800c07:	89 d1                	mov    %edx,%ecx
  800c09:	89 d3                	mov    %edx,%ebx
  800c0b:	89 d7                	mov    %edx,%edi
  800c0d:	89 d6                	mov    %edx,%esi
  800c0f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2c:	89 cb                	mov    %ecx,%ebx
  800c2e:	89 cf                	mov    %ecx,%edi
  800c30:	89 ce                	mov    %ecx,%esi
  800c32:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7f 08                	jg     800c40 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 03                	push   $0x3
  800c46:	68 1f 28 80 00       	push   $0x80281f
  800c4b:	6a 2a                	push   $0x2a
  800c4d:	68 3c 28 80 00       	push   $0x80283c
  800c52:	e8 8d f5 ff ff       	call   8001e4 <_panic>

00800c57 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c62:	b8 02 00 00 00       	mov    $0x2,%eax
  800c67:	89 d1                	mov    %edx,%ecx
  800c69:	89 d3                	mov    %edx,%ebx
  800c6b:	89 d7                	mov    %edx,%edi
  800c6d:	89 d6                	mov    %edx,%esi
  800c6f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_yield>:

void
sys_yield(void)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c81:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c86:	89 d1                	mov    %edx,%ecx
  800c88:	89 d3                	mov    %edx,%ebx
  800c8a:	89 d7                	mov    %edx,%edi
  800c8c:	89 d6                	mov    %edx,%esi
  800c8e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9e:	be 00 00 00 00       	mov    $0x0,%esi
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 04 00 00 00       	mov    $0x4,%eax
  800cae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb1:	89 f7                	mov    %esi,%edi
  800cb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7f 08                	jg     800cc1 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 04                	push   $0x4
  800cc7:	68 1f 28 80 00       	push   $0x80281f
  800ccc:	6a 2a                	push   $0x2a
  800cce:	68 3c 28 80 00       	push   $0x80283c
  800cd3:	e8 0c f5 ff ff       	call   8001e4 <_panic>

00800cd8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	b8 05 00 00 00       	mov    $0x5,%eax
  800cec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cef:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf2:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7f 08                	jg     800d03 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 05                	push   $0x5
  800d09:	68 1f 28 80 00       	push   $0x80281f
  800d0e:	6a 2a                	push   $0x2a
  800d10:	68 3c 28 80 00       	push   $0x80283c
  800d15:	e8 ca f4 ff ff       	call   8001e4 <_panic>

00800d1a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d33:	89 df                	mov    %ebx,%edi
  800d35:	89 de                	mov    %ebx,%esi
  800d37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7f 08                	jg     800d45 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 06                	push   $0x6
  800d4b:	68 1f 28 80 00       	push   $0x80281f
  800d50:	6a 2a                	push   $0x2a
  800d52:	68 3c 28 80 00       	push   $0x80283c
  800d57:	e8 88 f4 ff ff       	call   8001e4 <_panic>

00800d5c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	b8 08 00 00 00       	mov    $0x8,%eax
  800d75:	89 df                	mov    %ebx,%edi
  800d77:	89 de                	mov    %ebx,%esi
  800d79:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	7f 08                	jg     800d87 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	50                   	push   %eax
  800d8b:	6a 08                	push   $0x8
  800d8d:	68 1f 28 80 00       	push   $0x80281f
  800d92:	6a 2a                	push   $0x2a
  800d94:	68 3c 28 80 00       	push   $0x80283c
  800d99:	e8 46 f4 ff ff       	call   8001e4 <_panic>

00800d9e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	b8 09 00 00 00       	mov    $0x9,%eax
  800db7:	89 df                	mov    %ebx,%edi
  800db9:	89 de                	mov    %ebx,%esi
  800dbb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	7f 08                	jg     800dc9 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	50                   	push   %eax
  800dcd:	6a 09                	push   $0x9
  800dcf:	68 1f 28 80 00       	push   $0x80281f
  800dd4:	6a 2a                	push   $0x2a
  800dd6:	68 3c 28 80 00       	push   $0x80283c
  800ddb:	e8 04 f4 ff ff       	call   8001e4 <_panic>

00800de0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 de                	mov    %ebx,%esi
  800dfd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7f 08                	jg     800e0b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 0a                	push   $0xa
  800e11:	68 1f 28 80 00       	push   $0x80281f
  800e16:	6a 2a                	push   $0x2a
  800e18:	68 3c 28 80 00       	push   $0x80283c
  800e1d:	e8 c2 f3 ff ff       	call   8001e4 <_panic>

00800e22 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e33:	be 00 00 00 00       	mov    $0x0,%esi
  800e38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	57                   	push   %edi
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
  800e4b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
  800e56:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5b:	89 cb                	mov    %ecx,%ebx
  800e5d:	89 cf                	mov    %ecx,%edi
  800e5f:	89 ce                	mov    %ecx,%esi
  800e61:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7f 08                	jg     800e6f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 0d                	push   $0xd
  800e75:	68 1f 28 80 00       	push   $0x80281f
  800e7a:	6a 2a                	push   $0x2a
  800e7c:	68 3c 28 80 00       	push   $0x80283c
  800e81:	e8 5e f3 ff ff       	call   8001e4 <_panic>

00800e86 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e91:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e96:	89 d1                	mov    %edx,%ecx
  800e98:	89 d3                	mov    %edx,%ebx
  800e9a:	89 d7                	mov    %edx,%edi
  800e9c:	89 d6                	mov    %edx,%esi
  800e9e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ebb:	89 df                	mov    %ebx,%edi
  800ebd:	89 de                	mov    %ebx,%esi
  800ebf:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed7:	b8 10 00 00 00       	mov    $0x10,%eax
  800edc:	89 df                	mov    %ebx,%edi
  800ede:	89 de                	mov    %ebx,%esi
  800ee0:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eea:	8b 45 08             	mov    0x8(%ebp),%eax
  800eed:	05 00 00 00 30       	add    $0x30000000,%eax
  800ef2:	c1 e8 0c             	shr    $0xc,%eax
}
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800efa:	8b 45 08             	mov    0x8(%ebp),%eax
  800efd:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f07:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f16:	89 c2                	mov    %eax,%edx
  800f18:	c1 ea 16             	shr    $0x16,%edx
  800f1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f22:	f6 c2 01             	test   $0x1,%dl
  800f25:	74 29                	je     800f50 <fd_alloc+0x42>
  800f27:	89 c2                	mov    %eax,%edx
  800f29:	c1 ea 0c             	shr    $0xc,%edx
  800f2c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f33:	f6 c2 01             	test   $0x1,%dl
  800f36:	74 18                	je     800f50 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f38:	05 00 10 00 00       	add    $0x1000,%eax
  800f3d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f42:	75 d2                	jne    800f16 <fd_alloc+0x8>
  800f44:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f49:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f4e:	eb 05                	jmp    800f55 <fd_alloc+0x47>
			return 0;
  800f50:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f55:	8b 55 08             	mov    0x8(%ebp),%edx
  800f58:	89 02                	mov    %eax,(%edx)
}
  800f5a:	89 c8                	mov    %ecx,%eax
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    

00800f5e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f64:	83 f8 1f             	cmp    $0x1f,%eax
  800f67:	77 30                	ja     800f99 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f69:	c1 e0 0c             	shl    $0xc,%eax
  800f6c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f71:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f77:	f6 c2 01             	test   $0x1,%dl
  800f7a:	74 24                	je     800fa0 <fd_lookup+0x42>
  800f7c:	89 c2                	mov    %eax,%edx
  800f7e:	c1 ea 0c             	shr    $0xc,%edx
  800f81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f88:	f6 c2 01             	test   $0x1,%dl
  800f8b:	74 1a                	je     800fa7 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f90:	89 02                	mov    %eax,(%edx)
	return 0;
  800f92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    
		return -E_INVAL;
  800f99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9e:	eb f7                	jmp    800f97 <fd_lookup+0x39>
		return -E_INVAL;
  800fa0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa5:	eb f0                	jmp    800f97 <fd_lookup+0x39>
  800fa7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fac:	eb e9                	jmp    800f97 <fd_lookup+0x39>

00800fae <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	53                   	push   %ebx
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbd:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800fc2:	39 13                	cmp    %edx,(%ebx)
  800fc4:	74 37                	je     800ffd <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800fc6:	83 c0 01             	add    $0x1,%eax
  800fc9:	8b 1c 85 c8 28 80 00 	mov    0x8028c8(,%eax,4),%ebx
  800fd0:	85 db                	test   %ebx,%ebx
  800fd2:	75 ee                	jne    800fc2 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fd4:	a1 04 40 80 00       	mov    0x804004,%eax
  800fd9:	8b 40 58             	mov    0x58(%eax),%eax
  800fdc:	83 ec 04             	sub    $0x4,%esp
  800fdf:	52                   	push   %edx
  800fe0:	50                   	push   %eax
  800fe1:	68 4c 28 80 00       	push   $0x80284c
  800fe6:	e8 d4 f2 ff ff       	call   8002bf <cprintf>
	*dev = 0;
	return -E_INVAL;
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800ff3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff6:	89 1a                	mov    %ebx,(%edx)
}
  800ff8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    
			return 0;
  800ffd:	b8 00 00 00 00       	mov    $0x0,%eax
  801002:	eb ef                	jmp    800ff3 <dev_lookup+0x45>

00801004 <fd_close>:
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	57                   	push   %edi
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	83 ec 24             	sub    $0x24,%esp
  80100d:	8b 75 08             	mov    0x8(%ebp),%esi
  801010:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801013:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801016:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801017:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80101d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801020:	50                   	push   %eax
  801021:	e8 38 ff ff ff       	call   800f5e <fd_lookup>
  801026:	89 c3                	mov    %eax,%ebx
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	78 05                	js     801034 <fd_close+0x30>
	    || fd != fd2)
  80102f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801032:	74 16                	je     80104a <fd_close+0x46>
		return (must_exist ? r : 0);
  801034:	89 f8                	mov    %edi,%eax
  801036:	84 c0                	test   %al,%al
  801038:	b8 00 00 00 00       	mov    $0x0,%eax
  80103d:	0f 44 d8             	cmove  %eax,%ebx
}
  801040:	89 d8                	mov    %ebx,%eax
  801042:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5f                   	pop    %edi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80104a:	83 ec 08             	sub    $0x8,%esp
  80104d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801050:	50                   	push   %eax
  801051:	ff 36                	push   (%esi)
  801053:	e8 56 ff ff ff       	call   800fae <dev_lookup>
  801058:	89 c3                	mov    %eax,%ebx
  80105a:	83 c4 10             	add    $0x10,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	78 1a                	js     80107b <fd_close+0x77>
		if (dev->dev_close)
  801061:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801064:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801067:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80106c:	85 c0                	test   %eax,%eax
  80106e:	74 0b                	je     80107b <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	56                   	push   %esi
  801074:	ff d0                	call   *%eax
  801076:	89 c3                	mov    %eax,%ebx
  801078:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80107b:	83 ec 08             	sub    $0x8,%esp
  80107e:	56                   	push   %esi
  80107f:	6a 00                	push   $0x0
  801081:	e8 94 fc ff ff       	call   800d1a <sys_page_unmap>
	return r;
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	eb b5                	jmp    801040 <fd_close+0x3c>

0080108b <close>:

int
close(int fdnum)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801091:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801094:	50                   	push   %eax
  801095:	ff 75 08             	push   0x8(%ebp)
  801098:	e8 c1 fe ff ff       	call   800f5e <fd_lookup>
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	79 02                	jns    8010a6 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    
		return fd_close(fd, 1);
  8010a6:	83 ec 08             	sub    $0x8,%esp
  8010a9:	6a 01                	push   $0x1
  8010ab:	ff 75 f4             	push   -0xc(%ebp)
  8010ae:	e8 51 ff ff ff       	call   801004 <fd_close>
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	eb ec                	jmp    8010a4 <close+0x19>

008010b8 <close_all>:

void
close_all(void)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	53                   	push   %ebx
  8010bc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010bf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	53                   	push   %ebx
  8010c8:	e8 be ff ff ff       	call   80108b <close>
	for (i = 0; i < MAXFD; i++)
  8010cd:	83 c3 01             	add    $0x1,%ebx
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	83 fb 20             	cmp    $0x20,%ebx
  8010d6:	75 ec                	jne    8010c4 <close_all+0xc>
}
  8010d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010db:	c9                   	leave  
  8010dc:	c3                   	ret    

008010dd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	57                   	push   %edi
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e9:	50                   	push   %eax
  8010ea:	ff 75 08             	push   0x8(%ebp)
  8010ed:	e8 6c fe ff ff       	call   800f5e <fd_lookup>
  8010f2:	89 c3                	mov    %eax,%ebx
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 7f                	js     80117a <dup+0x9d>
		return r;
	close(newfdnum);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	ff 75 0c             	push   0xc(%ebp)
  801101:	e8 85 ff ff ff       	call   80108b <close>

	newfd = INDEX2FD(newfdnum);
  801106:	8b 75 0c             	mov    0xc(%ebp),%esi
  801109:	c1 e6 0c             	shl    $0xc,%esi
  80110c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801112:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801115:	89 3c 24             	mov    %edi,(%esp)
  801118:	e8 da fd ff ff       	call   800ef7 <fd2data>
  80111d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80111f:	89 34 24             	mov    %esi,(%esp)
  801122:	e8 d0 fd ff ff       	call   800ef7 <fd2data>
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80112d:	89 d8                	mov    %ebx,%eax
  80112f:	c1 e8 16             	shr    $0x16,%eax
  801132:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801139:	a8 01                	test   $0x1,%al
  80113b:	74 11                	je     80114e <dup+0x71>
  80113d:	89 d8                	mov    %ebx,%eax
  80113f:	c1 e8 0c             	shr    $0xc,%eax
  801142:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801149:	f6 c2 01             	test   $0x1,%dl
  80114c:	75 36                	jne    801184 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114e:	89 f8                	mov    %edi,%eax
  801150:	c1 e8 0c             	shr    $0xc,%eax
  801153:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115a:	83 ec 0c             	sub    $0xc,%esp
  80115d:	25 07 0e 00 00       	and    $0xe07,%eax
  801162:	50                   	push   %eax
  801163:	56                   	push   %esi
  801164:	6a 00                	push   $0x0
  801166:	57                   	push   %edi
  801167:	6a 00                	push   $0x0
  801169:	e8 6a fb ff ff       	call   800cd8 <sys_page_map>
  80116e:	89 c3                	mov    %eax,%ebx
  801170:	83 c4 20             	add    $0x20,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	78 33                	js     8011aa <dup+0xcd>
		goto err;

	return newfdnum;
  801177:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80117a:	89 d8                	mov    %ebx,%eax
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801184:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	25 07 0e 00 00       	and    $0xe07,%eax
  801193:	50                   	push   %eax
  801194:	ff 75 d4             	push   -0x2c(%ebp)
  801197:	6a 00                	push   $0x0
  801199:	53                   	push   %ebx
  80119a:	6a 00                	push   $0x0
  80119c:	e8 37 fb ff ff       	call   800cd8 <sys_page_map>
  8011a1:	89 c3                	mov    %eax,%ebx
  8011a3:	83 c4 20             	add    $0x20,%esp
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	79 a4                	jns    80114e <dup+0x71>
	sys_page_unmap(0, newfd);
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	56                   	push   %esi
  8011ae:	6a 00                	push   $0x0
  8011b0:	e8 65 fb ff ff       	call   800d1a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011b5:	83 c4 08             	add    $0x8,%esp
  8011b8:	ff 75 d4             	push   -0x2c(%ebp)
  8011bb:	6a 00                	push   $0x0
  8011bd:	e8 58 fb ff ff       	call   800d1a <sys_page_unmap>
	return r;
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	eb b3                	jmp    80117a <dup+0x9d>

008011c7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 18             	sub    $0x18,%esp
  8011cf:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	56                   	push   %esi
  8011d7:	e8 82 fd ff ff       	call   800f5e <fd_lookup>
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 3c                	js     80121f <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e3:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8011e6:	83 ec 08             	sub    $0x8,%esp
  8011e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ec:	50                   	push   %eax
  8011ed:	ff 33                	push   (%ebx)
  8011ef:	e8 ba fd ff ff       	call   800fae <dev_lookup>
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 24                	js     80121f <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011fb:	8b 43 08             	mov    0x8(%ebx),%eax
  8011fe:	83 e0 03             	and    $0x3,%eax
  801201:	83 f8 01             	cmp    $0x1,%eax
  801204:	74 20                	je     801226 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801206:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801209:	8b 40 08             	mov    0x8(%eax),%eax
  80120c:	85 c0                	test   %eax,%eax
  80120e:	74 37                	je     801247 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801210:	83 ec 04             	sub    $0x4,%esp
  801213:	ff 75 10             	push   0x10(%ebp)
  801216:	ff 75 0c             	push   0xc(%ebp)
  801219:	53                   	push   %ebx
  80121a:	ff d0                	call   *%eax
  80121c:	83 c4 10             	add    $0x10,%esp
}
  80121f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801222:	5b                   	pop    %ebx
  801223:	5e                   	pop    %esi
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801226:	a1 04 40 80 00       	mov    0x804004,%eax
  80122b:	8b 40 58             	mov    0x58(%eax),%eax
  80122e:	83 ec 04             	sub    $0x4,%esp
  801231:	56                   	push   %esi
  801232:	50                   	push   %eax
  801233:	68 8d 28 80 00       	push   $0x80288d
  801238:	e8 82 f0 ff ff       	call   8002bf <cprintf>
		return -E_INVAL;
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801245:	eb d8                	jmp    80121f <read+0x58>
		return -E_NOT_SUPP;
  801247:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80124c:	eb d1                	jmp    80121f <read+0x58>

0080124e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	57                   	push   %edi
  801252:	56                   	push   %esi
  801253:	53                   	push   %ebx
  801254:	83 ec 0c             	sub    $0xc,%esp
  801257:	8b 7d 08             	mov    0x8(%ebp),%edi
  80125a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80125d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801262:	eb 02                	jmp    801266 <readn+0x18>
  801264:	01 c3                	add    %eax,%ebx
  801266:	39 f3                	cmp    %esi,%ebx
  801268:	73 21                	jae    80128b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80126a:	83 ec 04             	sub    $0x4,%esp
  80126d:	89 f0                	mov    %esi,%eax
  80126f:	29 d8                	sub    %ebx,%eax
  801271:	50                   	push   %eax
  801272:	89 d8                	mov    %ebx,%eax
  801274:	03 45 0c             	add    0xc(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	57                   	push   %edi
  801279:	e8 49 ff ff ff       	call   8011c7 <read>
		if (m < 0)
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 04                	js     801289 <readn+0x3b>
			return m;
		if (m == 0)
  801285:	75 dd                	jne    801264 <readn+0x16>
  801287:	eb 02                	jmp    80128b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801289:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80128b:	89 d8                	mov    %ebx,%eax
  80128d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801290:	5b                   	pop    %ebx
  801291:	5e                   	pop    %esi
  801292:	5f                   	pop    %edi
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 18             	sub    $0x18,%esp
  80129d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a3:	50                   	push   %eax
  8012a4:	53                   	push   %ebx
  8012a5:	e8 b4 fc ff ff       	call   800f5e <fd_lookup>
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 37                	js     8012e8 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ba:	50                   	push   %eax
  8012bb:	ff 36                	push   (%esi)
  8012bd:	e8 ec fc ff ff       	call   800fae <dev_lookup>
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 1f                	js     8012e8 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c9:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012cd:	74 20                	je     8012ef <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	74 37                	je     801310 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	ff 75 10             	push   0x10(%ebp)
  8012df:	ff 75 0c             	push   0xc(%ebp)
  8012e2:	56                   	push   %esi
  8012e3:	ff d0                	call   *%eax
  8012e5:	83 c4 10             	add    $0x10,%esp
}
  8012e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012eb:	5b                   	pop    %ebx
  8012ec:	5e                   	pop    %esi
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f4:	8b 40 58             	mov    0x58(%eax),%eax
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	53                   	push   %ebx
  8012fb:	50                   	push   %eax
  8012fc:	68 a9 28 80 00       	push   $0x8028a9
  801301:	e8 b9 ef ff ff       	call   8002bf <cprintf>
		return -E_INVAL;
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130e:	eb d8                	jmp    8012e8 <write+0x53>
		return -E_NOT_SUPP;
  801310:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801315:	eb d1                	jmp    8012e8 <write+0x53>

00801317 <seek>:

int
seek(int fdnum, off_t offset)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	ff 75 08             	push   0x8(%ebp)
  801324:	e8 35 fc ff ff       	call   800f5e <fd_lookup>
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 0e                	js     80133e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801330:	8b 55 0c             	mov    0xc(%ebp),%edx
  801333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801336:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801339:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	56                   	push   %esi
  801344:	53                   	push   %ebx
  801345:	83 ec 18             	sub    $0x18,%esp
  801348:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134e:	50                   	push   %eax
  80134f:	53                   	push   %ebx
  801350:	e8 09 fc ff ff       	call   800f5e <fd_lookup>
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 34                	js     801390 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80135f:	83 ec 08             	sub    $0x8,%esp
  801362:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	ff 36                	push   (%esi)
  801368:	e8 41 fc ff ff       	call   800fae <dev_lookup>
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	85 c0                	test   %eax,%eax
  801372:	78 1c                	js     801390 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801374:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801378:	74 1d                	je     801397 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80137a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137d:	8b 40 18             	mov    0x18(%eax),%eax
  801380:	85 c0                	test   %eax,%eax
  801382:	74 34                	je     8013b8 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	ff 75 0c             	push   0xc(%ebp)
  80138a:	56                   	push   %esi
  80138b:	ff d0                	call   *%eax
  80138d:	83 c4 10             	add    $0x10,%esp
}
  801390:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	5d                   	pop    %ebp
  801396:	c3                   	ret    
			thisenv->env_id, fdnum);
  801397:	a1 04 40 80 00       	mov    0x804004,%eax
  80139c:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80139f:	83 ec 04             	sub    $0x4,%esp
  8013a2:	53                   	push   %ebx
  8013a3:	50                   	push   %eax
  8013a4:	68 6c 28 80 00       	push   $0x80286c
  8013a9:	e8 11 ef ff ff       	call   8002bf <cprintf>
		return -E_INVAL;
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b6:	eb d8                	jmp    801390 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8013b8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013bd:	eb d1                	jmp    801390 <ftruncate+0x50>

008013bf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	56                   	push   %esi
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 18             	sub    $0x18,%esp
  8013c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cd:	50                   	push   %eax
  8013ce:	ff 75 08             	push   0x8(%ebp)
  8013d1:	e8 88 fb ff ff       	call   800f5e <fd_lookup>
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 49                	js     801426 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013dd:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	ff 36                	push   (%esi)
  8013e9:	e8 c0 fb ff ff       	call   800fae <dev_lookup>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 31                	js     801426 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013fc:	74 2f                	je     80142d <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013fe:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801401:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801408:	00 00 00 
	stat->st_isdir = 0;
  80140b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801412:	00 00 00 
	stat->st_dev = dev;
  801415:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	53                   	push   %ebx
  80141f:	56                   	push   %esi
  801420:	ff 50 14             	call   *0x14(%eax)
  801423:	83 c4 10             	add    $0x10,%esp
}
  801426:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801429:	5b                   	pop    %ebx
  80142a:	5e                   	pop    %esi
  80142b:	5d                   	pop    %ebp
  80142c:	c3                   	ret    
		return -E_NOT_SUPP;
  80142d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801432:	eb f2                	jmp    801426 <fstat+0x67>

00801434 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	56                   	push   %esi
  801438:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	6a 00                	push   $0x0
  80143e:	ff 75 08             	push   0x8(%ebp)
  801441:	e8 e4 01 00 00       	call   80162a <open>
  801446:	89 c3                	mov    %eax,%ebx
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	85 c0                	test   %eax,%eax
  80144d:	78 1b                	js     80146a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	ff 75 0c             	push   0xc(%ebp)
  801455:	50                   	push   %eax
  801456:	e8 64 ff ff ff       	call   8013bf <fstat>
  80145b:	89 c6                	mov    %eax,%esi
	close(fd);
  80145d:	89 1c 24             	mov    %ebx,(%esp)
  801460:	e8 26 fc ff ff       	call   80108b <close>
	return r;
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	89 f3                	mov    %esi,%ebx
}
  80146a:	89 d8                	mov    %ebx,%eax
  80146c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146f:	5b                   	pop    %ebx
  801470:	5e                   	pop    %esi
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	56                   	push   %esi
  801477:	53                   	push   %ebx
  801478:	89 c6                	mov    %eax,%esi
  80147a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80147c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801483:	74 27                	je     8014ac <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801485:	6a 07                	push   $0x7
  801487:	68 00 50 80 00       	push   $0x805000
  80148c:	56                   	push   %esi
  80148d:	ff 35 00 60 80 00    	push   0x806000
  801493:	e8 e0 0c 00 00       	call   802178 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801498:	83 c4 0c             	add    $0xc,%esp
  80149b:	6a 00                	push   $0x0
  80149d:	53                   	push   %ebx
  80149e:	6a 00                	push   $0x0
  8014a0:	e8 63 0c 00 00       	call   802108 <ipc_recv>
}
  8014a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a8:	5b                   	pop    %ebx
  8014a9:	5e                   	pop    %esi
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	6a 01                	push   $0x1
  8014b1:	e8 16 0d 00 00       	call   8021cc <ipc_find_env>
  8014b6:	a3 00 60 80 00       	mov    %eax,0x806000
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	eb c5                	jmp    801485 <fsipc+0x12>

008014c0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014de:	b8 02 00 00 00       	mov    $0x2,%eax
  8014e3:	e8 8b ff ff ff       	call   801473 <fsipc>
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <devfile_flush>:
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801500:	b8 06 00 00 00       	mov    $0x6,%eax
  801505:	e8 69 ff ff ff       	call   801473 <fsipc>
}
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    

0080150c <devfile_stat>:
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	53                   	push   %ebx
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801516:	8b 45 08             	mov    0x8(%ebp),%eax
  801519:	8b 40 0c             	mov    0xc(%eax),%eax
  80151c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801521:	ba 00 00 00 00       	mov    $0x0,%edx
  801526:	b8 05 00 00 00       	mov    $0x5,%eax
  80152b:	e8 43 ff ff ff       	call   801473 <fsipc>
  801530:	85 c0                	test   %eax,%eax
  801532:	78 2c                	js     801560 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801534:	83 ec 08             	sub    $0x8,%esp
  801537:	68 00 50 80 00       	push   $0x805000
  80153c:	53                   	push   %ebx
  80153d:	e8 57 f3 ff ff       	call   800899 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801542:	a1 80 50 80 00       	mov    0x805080,%eax
  801547:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80154d:	a1 84 50 80 00       	mov    0x805084,%eax
  801552:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801560:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801563:	c9                   	leave  
  801564:	c3                   	ret    

00801565 <devfile_write>:
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 0c             	sub    $0xc,%esp
  80156b:	8b 45 10             	mov    0x10(%ebp),%eax
  80156e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801573:	39 d0                	cmp    %edx,%eax
  801575:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801578:	8b 55 08             	mov    0x8(%ebp),%edx
  80157b:	8b 52 0c             	mov    0xc(%edx),%edx
  80157e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801584:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801589:	50                   	push   %eax
  80158a:	ff 75 0c             	push   0xc(%ebp)
  80158d:	68 08 50 80 00       	push   $0x805008
  801592:	e8 98 f4 ff ff       	call   800a2f <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801597:	ba 00 00 00 00       	mov    $0x0,%edx
  80159c:	b8 04 00 00 00       	mov    $0x4,%eax
  8015a1:	e8 cd fe ff ff       	call   801473 <fsipc>
}
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <devfile_read>:
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015bb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c6:	b8 03 00 00 00       	mov    $0x3,%eax
  8015cb:	e8 a3 fe ff ff       	call   801473 <fsipc>
  8015d0:	89 c3                	mov    %eax,%ebx
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 1f                	js     8015f5 <devfile_read+0x4d>
	assert(r <= n);
  8015d6:	39 f0                	cmp    %esi,%eax
  8015d8:	77 24                	ja     8015fe <devfile_read+0x56>
	assert(r <= PGSIZE);
  8015da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015df:	7f 33                	jg     801614 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015e1:	83 ec 04             	sub    $0x4,%esp
  8015e4:	50                   	push   %eax
  8015e5:	68 00 50 80 00       	push   $0x805000
  8015ea:	ff 75 0c             	push   0xc(%ebp)
  8015ed:	e8 3d f4 ff ff       	call   800a2f <memmove>
	return r;
  8015f2:	83 c4 10             	add    $0x10,%esp
}
  8015f5:	89 d8                	mov    %ebx,%eax
  8015f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fa:	5b                   	pop    %ebx
  8015fb:	5e                   	pop    %esi
  8015fc:	5d                   	pop    %ebp
  8015fd:	c3                   	ret    
	assert(r <= n);
  8015fe:	68 dc 28 80 00       	push   $0x8028dc
  801603:	68 e3 28 80 00       	push   $0x8028e3
  801608:	6a 7c                	push   $0x7c
  80160a:	68 f8 28 80 00       	push   $0x8028f8
  80160f:	e8 d0 eb ff ff       	call   8001e4 <_panic>
	assert(r <= PGSIZE);
  801614:	68 03 29 80 00       	push   $0x802903
  801619:	68 e3 28 80 00       	push   $0x8028e3
  80161e:	6a 7d                	push   $0x7d
  801620:	68 f8 28 80 00       	push   $0x8028f8
  801625:	e8 ba eb ff ff       	call   8001e4 <_panic>

0080162a <open>:
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
  80162f:	83 ec 1c             	sub    $0x1c,%esp
  801632:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801635:	56                   	push   %esi
  801636:	e8 23 f2 ff ff       	call   80085e <strlen>
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801643:	7f 6c                	jg     8016b1 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801645:	83 ec 0c             	sub    $0xc,%esp
  801648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	e8 bd f8 ff ff       	call   800f0e <fd_alloc>
  801651:	89 c3                	mov    %eax,%ebx
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 3c                	js     801696 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	56                   	push   %esi
  80165e:	68 00 50 80 00       	push   $0x805000
  801663:	e8 31 f2 ff ff       	call   800899 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801668:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801670:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801673:	b8 01 00 00 00       	mov    $0x1,%eax
  801678:	e8 f6 fd ff ff       	call   801473 <fsipc>
  80167d:	89 c3                	mov    %eax,%ebx
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	85 c0                	test   %eax,%eax
  801684:	78 19                	js     80169f <open+0x75>
	return fd2num(fd);
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	ff 75 f4             	push   -0xc(%ebp)
  80168c:	e8 56 f8 ff ff       	call   800ee7 <fd2num>
  801691:	89 c3                	mov    %eax,%ebx
  801693:	83 c4 10             	add    $0x10,%esp
}
  801696:	89 d8                	mov    %ebx,%eax
  801698:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5e                   	pop    %esi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    
		fd_close(fd, 0);
  80169f:	83 ec 08             	sub    $0x8,%esp
  8016a2:	6a 00                	push   $0x0
  8016a4:	ff 75 f4             	push   -0xc(%ebp)
  8016a7:	e8 58 f9 ff ff       	call   801004 <fd_close>
		return r;
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	eb e5                	jmp    801696 <open+0x6c>
		return -E_BAD_PATH;
  8016b1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016b6:	eb de                	jmp    801696 <open+0x6c>

008016b8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016be:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c8:	e8 a6 fd ff ff       	call   801473 <fsipc>
}
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016cf:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016d3:	7f 01                	jg     8016d6 <writebuf+0x7>
  8016d5:	c3                   	ret    
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016df:	ff 70 04             	push   0x4(%eax)
  8016e2:	8d 40 10             	lea    0x10(%eax),%eax
  8016e5:	50                   	push   %eax
  8016e6:	ff 33                	push   (%ebx)
  8016e8:	e8 a8 fb ff ff       	call   801295 <write>
		if (result > 0)
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	7e 03                	jle    8016f7 <writebuf+0x28>
			b->result += result;
  8016f4:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016f7:	39 43 04             	cmp    %eax,0x4(%ebx)
  8016fa:	74 0d                	je     801709 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801703:	0f 4f c2             	cmovg  %edx,%eax
  801706:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <putch>:

static void
putch(int ch, void *thunk)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801718:	8b 53 04             	mov    0x4(%ebx),%edx
  80171b:	8d 42 01             	lea    0x1(%edx),%eax
  80171e:	89 43 04             	mov    %eax,0x4(%ebx)
  801721:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801724:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801728:	3d 00 01 00 00       	cmp    $0x100,%eax
  80172d:	74 05                	je     801734 <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  80172f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801732:	c9                   	leave  
  801733:	c3                   	ret    
		writebuf(b);
  801734:	89 d8                	mov    %ebx,%eax
  801736:	e8 94 ff ff ff       	call   8016cf <writebuf>
		b->idx = 0;
  80173b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  801742:	eb eb                	jmp    80172f <putch+0x21>

00801744 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80174d:	8b 45 08             	mov    0x8(%ebp),%eax
  801750:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801756:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80175d:	00 00 00 
	b.result = 0;
  801760:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801767:	00 00 00 
	b.error = 1;
  80176a:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801771:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801774:	ff 75 10             	push   0x10(%ebp)
  801777:	ff 75 0c             	push   0xc(%ebp)
  80177a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801780:	50                   	push   %eax
  801781:	68 0e 17 80 00       	push   $0x80170e
  801786:	e8 2b ec ff ff       	call   8003b6 <vprintfmt>
	if (b.idx > 0)
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801795:	7f 11                	jg     8017a8 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801797:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80179d:	85 c0                	test   %eax,%eax
  80179f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    
		writebuf(&b);
  8017a8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017ae:	e8 1c ff ff ff       	call   8016cf <writebuf>
  8017b3:	eb e2                	jmp    801797 <vfprintf+0x53>

008017b5 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017bb:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017be:	50                   	push   %eax
  8017bf:	ff 75 0c             	push   0xc(%ebp)
  8017c2:	ff 75 08             	push   0x8(%ebp)
  8017c5:	e8 7a ff ff ff       	call   801744 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <printf>:

int
printf(const char *fmt, ...)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017d5:	50                   	push   %eax
  8017d6:	ff 75 08             	push   0x8(%ebp)
  8017d9:	6a 01                	push   $0x1
  8017db:	e8 64 ff ff ff       	call   801744 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8017e8:	68 0f 29 80 00       	push   $0x80290f
  8017ed:	ff 75 0c             	push   0xc(%ebp)
  8017f0:	e8 a4 f0 ff ff       	call   800899 <strcpy>
	return 0;
}
  8017f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <devsock_close>:
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	53                   	push   %ebx
  801800:	83 ec 10             	sub    $0x10,%esp
  801803:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801806:	53                   	push   %ebx
  801807:	e8 ff 09 00 00       	call   80220b <pageref>
  80180c:	89 c2                	mov    %eax,%edx
  80180e:	83 c4 10             	add    $0x10,%esp
		return 0;
  801811:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801816:	83 fa 01             	cmp    $0x1,%edx
  801819:	74 05                	je     801820 <devsock_close+0x24>
}
  80181b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	ff 73 0c             	push   0xc(%ebx)
  801826:	e8 b7 02 00 00       	call   801ae2 <nsipc_close>
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	eb eb                	jmp    80181b <devsock_close+0x1f>

00801830 <devsock_write>:
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801836:	6a 00                	push   $0x0
  801838:	ff 75 10             	push   0x10(%ebp)
  80183b:	ff 75 0c             	push   0xc(%ebp)
  80183e:	8b 45 08             	mov    0x8(%ebp),%eax
  801841:	ff 70 0c             	push   0xc(%eax)
  801844:	e8 79 03 00 00       	call   801bc2 <nsipc_send>
}
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <devsock_read>:
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801851:	6a 00                	push   $0x0
  801853:	ff 75 10             	push   0x10(%ebp)
  801856:	ff 75 0c             	push   0xc(%ebp)
  801859:	8b 45 08             	mov    0x8(%ebp),%eax
  80185c:	ff 70 0c             	push   0xc(%eax)
  80185f:	e8 ef 02 00 00       	call   801b53 <nsipc_recv>
}
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <fd2sockid>:
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80186c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80186f:	52                   	push   %edx
  801870:	50                   	push   %eax
  801871:	e8 e8 f6 ff ff       	call   800f5e <fd_lookup>
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 10                	js     80188d <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80187d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801880:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801886:	39 08                	cmp    %ecx,(%eax)
  801888:	75 05                	jne    80188f <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80188a:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    
		return -E_NOT_SUPP;
  80188f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801894:	eb f7                	jmp    80188d <fd2sockid+0x27>

00801896 <alloc_sockfd>:
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
  80189b:	83 ec 1c             	sub    $0x1c,%esp
  80189e:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8018a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a3:	50                   	push   %eax
  8018a4:	e8 65 f6 ff ff       	call   800f0e <fd_alloc>
  8018a9:	89 c3                	mov    %eax,%ebx
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 43                	js     8018f5 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	68 07 04 00 00       	push   $0x407
  8018ba:	ff 75 f4             	push   -0xc(%ebp)
  8018bd:	6a 00                	push   $0x0
  8018bf:	e8 d1 f3 ff ff       	call   800c95 <sys_page_alloc>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 28                	js     8018f5 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8018cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d0:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8018d6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8018d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018db:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8018e2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8018e5:	83 ec 0c             	sub    $0xc,%esp
  8018e8:	50                   	push   %eax
  8018e9:	e8 f9 f5 ff ff       	call   800ee7 <fd2num>
  8018ee:	89 c3                	mov    %eax,%ebx
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	eb 0c                	jmp    801901 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8018f5:	83 ec 0c             	sub    $0xc,%esp
  8018f8:	56                   	push   %esi
  8018f9:	e8 e4 01 00 00       	call   801ae2 <nsipc_close>
		return r;
  8018fe:	83 c4 10             	add    $0x10,%esp
}
  801901:	89 d8                	mov    %ebx,%eax
  801903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <accept>:
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801910:	8b 45 08             	mov    0x8(%ebp),%eax
  801913:	e8 4e ff ff ff       	call   801866 <fd2sockid>
  801918:	85 c0                	test   %eax,%eax
  80191a:	78 1b                	js     801937 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80191c:	83 ec 04             	sub    $0x4,%esp
  80191f:	ff 75 10             	push   0x10(%ebp)
  801922:	ff 75 0c             	push   0xc(%ebp)
  801925:	50                   	push   %eax
  801926:	e8 0e 01 00 00       	call   801a39 <nsipc_accept>
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 05                	js     801937 <accept+0x2d>
	return alloc_sockfd(r);
  801932:	e8 5f ff ff ff       	call   801896 <alloc_sockfd>
}
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <bind>:
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80193f:	8b 45 08             	mov    0x8(%ebp),%eax
  801942:	e8 1f ff ff ff       	call   801866 <fd2sockid>
  801947:	85 c0                	test   %eax,%eax
  801949:	78 12                	js     80195d <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80194b:	83 ec 04             	sub    $0x4,%esp
  80194e:	ff 75 10             	push   0x10(%ebp)
  801951:	ff 75 0c             	push   0xc(%ebp)
  801954:	50                   	push   %eax
  801955:	e8 31 01 00 00       	call   801a8b <nsipc_bind>
  80195a:	83 c4 10             	add    $0x10,%esp
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <shutdown>:
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801965:	8b 45 08             	mov    0x8(%ebp),%eax
  801968:	e8 f9 fe ff ff       	call   801866 <fd2sockid>
  80196d:	85 c0                	test   %eax,%eax
  80196f:	78 0f                	js     801980 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	ff 75 0c             	push   0xc(%ebp)
  801977:	50                   	push   %eax
  801978:	e8 43 01 00 00       	call   801ac0 <nsipc_shutdown>
  80197d:	83 c4 10             	add    $0x10,%esp
}
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <connect>:
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801988:	8b 45 08             	mov    0x8(%ebp),%eax
  80198b:	e8 d6 fe ff ff       	call   801866 <fd2sockid>
  801990:	85 c0                	test   %eax,%eax
  801992:	78 12                	js     8019a6 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801994:	83 ec 04             	sub    $0x4,%esp
  801997:	ff 75 10             	push   0x10(%ebp)
  80199a:	ff 75 0c             	push   0xc(%ebp)
  80199d:	50                   	push   %eax
  80199e:	e8 59 01 00 00       	call   801afc <nsipc_connect>
  8019a3:	83 c4 10             	add    $0x10,%esp
}
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <listen>:
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	e8 b0 fe ff ff       	call   801866 <fd2sockid>
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 0f                	js     8019c9 <listen+0x21>
	return nsipc_listen(r, backlog);
  8019ba:	83 ec 08             	sub    $0x8,%esp
  8019bd:	ff 75 0c             	push   0xc(%ebp)
  8019c0:	50                   	push   %eax
  8019c1:	e8 6b 01 00 00       	call   801b31 <nsipc_listen>
  8019c6:	83 c4 10             	add    $0x10,%esp
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <socket>:

int
socket(int domain, int type, int protocol)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019d1:	ff 75 10             	push   0x10(%ebp)
  8019d4:	ff 75 0c             	push   0xc(%ebp)
  8019d7:	ff 75 08             	push   0x8(%ebp)
  8019da:	e8 41 02 00 00       	call   801c20 <nsipc_socket>
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	78 05                	js     8019eb <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8019e6:	e8 ab fe ff ff       	call   801896 <alloc_sockfd>
}
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	53                   	push   %ebx
  8019f1:	83 ec 04             	sub    $0x4,%esp
  8019f4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019f6:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8019fd:	74 26                	je     801a25 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019ff:	6a 07                	push   $0x7
  801a01:	68 00 70 80 00       	push   $0x807000
  801a06:	53                   	push   %ebx
  801a07:	ff 35 00 80 80 00    	push   0x808000
  801a0d:	e8 66 07 00 00       	call   802178 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a12:	83 c4 0c             	add    $0xc,%esp
  801a15:	6a 00                	push   $0x0
  801a17:	6a 00                	push   $0x0
  801a19:	6a 00                	push   $0x0
  801a1b:	e8 e8 06 00 00       	call   802108 <ipc_recv>
}
  801a20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a25:	83 ec 0c             	sub    $0xc,%esp
  801a28:	6a 02                	push   $0x2
  801a2a:	e8 9d 07 00 00       	call   8021cc <ipc_find_env>
  801a2f:	a3 00 80 80 00       	mov    %eax,0x808000
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	eb c6                	jmp    8019ff <nsipc+0x12>

00801a39 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
  801a3e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a41:	8b 45 08             	mov    0x8(%ebp),%eax
  801a44:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a49:	8b 06                	mov    (%esi),%eax
  801a4b:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a50:	b8 01 00 00 00       	mov    $0x1,%eax
  801a55:	e8 93 ff ff ff       	call   8019ed <nsipc>
  801a5a:	89 c3                	mov    %eax,%ebx
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	79 09                	jns    801a69 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801a60:	89 d8                	mov    %ebx,%eax
  801a62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a69:	83 ec 04             	sub    $0x4,%esp
  801a6c:	ff 35 10 70 80 00    	push   0x807010
  801a72:	68 00 70 80 00       	push   $0x807000
  801a77:	ff 75 0c             	push   0xc(%ebp)
  801a7a:	e8 b0 ef ff ff       	call   800a2f <memmove>
		*addrlen = ret->ret_addrlen;
  801a7f:	a1 10 70 80 00       	mov    0x807010,%eax
  801a84:	89 06                	mov    %eax,(%esi)
  801a86:	83 c4 10             	add    $0x10,%esp
	return r;
  801a89:	eb d5                	jmp    801a60 <nsipc_accept+0x27>

00801a8b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	53                   	push   %ebx
  801a8f:	83 ec 08             	sub    $0x8,%esp
  801a92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a95:	8b 45 08             	mov    0x8(%ebp),%eax
  801a98:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a9d:	53                   	push   %ebx
  801a9e:	ff 75 0c             	push   0xc(%ebp)
  801aa1:	68 04 70 80 00       	push   $0x807004
  801aa6:	e8 84 ef ff ff       	call   800a2f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801aab:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801ab1:	b8 02 00 00 00       	mov    $0x2,%eax
  801ab6:	e8 32 ff ff ff       	call   8019ed <nsipc>
}
  801abb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ad6:	b8 03 00 00 00       	mov    $0x3,%eax
  801adb:	e8 0d ff ff ff       	call   8019ed <nsipc>
}
  801ae0:	c9                   	leave  
  801ae1:	c3                   	ret    

00801ae2 <nsipc_close>:

int
nsipc_close(int s)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  801aeb:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801af0:	b8 04 00 00 00       	mov    $0x4,%eax
  801af5:	e8 f3 fe ff ff       	call   8019ed <nsipc>
}
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    

00801afc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	53                   	push   %ebx
  801b00:	83 ec 08             	sub    $0x8,%esp
  801b03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b06:	8b 45 08             	mov    0x8(%ebp),%eax
  801b09:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b0e:	53                   	push   %ebx
  801b0f:	ff 75 0c             	push   0xc(%ebp)
  801b12:	68 04 70 80 00       	push   $0x807004
  801b17:	e8 13 ef ff ff       	call   800a2f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b1c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801b22:	b8 05 00 00 00       	mov    $0x5,%eax
  801b27:	e8 c1 fe ff ff       	call   8019ed <nsipc>
}
  801b2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2f:	c9                   	leave  
  801b30:	c3                   	ret    

00801b31 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b37:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b42:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801b47:	b8 06 00 00 00       	mov    $0x6,%eax
  801b4c:	e8 9c fe ff ff       	call   8019ed <nsipc>
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801b63:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801b69:	8b 45 14             	mov    0x14(%ebp),%eax
  801b6c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b71:	b8 07 00 00 00       	mov    $0x7,%eax
  801b76:	e8 72 fe ff ff       	call   8019ed <nsipc>
  801b7b:	89 c3                	mov    %eax,%ebx
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	78 22                	js     801ba3 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801b81:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801b86:	39 c6                	cmp    %eax,%esi
  801b88:	0f 4e c6             	cmovle %esi,%eax
  801b8b:	39 c3                	cmp    %eax,%ebx
  801b8d:	7f 1d                	jg     801bac <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b8f:	83 ec 04             	sub    $0x4,%esp
  801b92:	53                   	push   %ebx
  801b93:	68 00 70 80 00       	push   $0x807000
  801b98:	ff 75 0c             	push   0xc(%ebp)
  801b9b:	e8 8f ee ff ff       	call   800a2f <memmove>
  801ba0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ba3:	89 d8                	mov    %ebx,%eax
  801ba5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5e                   	pop    %esi
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801bac:	68 1b 29 80 00       	push   $0x80291b
  801bb1:	68 e3 28 80 00       	push   $0x8028e3
  801bb6:	6a 62                	push   $0x62
  801bb8:	68 30 29 80 00       	push   $0x802930
  801bbd:	e8 22 e6 ff ff       	call   8001e4 <_panic>

00801bc2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	53                   	push   %ebx
  801bc6:	83 ec 04             	sub    $0x4,%esp
  801bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcf:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801bd4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801bda:	7f 2e                	jg     801c0a <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801bdc:	83 ec 04             	sub    $0x4,%esp
  801bdf:	53                   	push   %ebx
  801be0:	ff 75 0c             	push   0xc(%ebp)
  801be3:	68 0c 70 80 00       	push   $0x80700c
  801be8:	e8 42 ee ff ff       	call   800a2f <memmove>
	nsipcbuf.send.req_size = size;
  801bed:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801bf3:	8b 45 14             	mov    0x14(%ebp),%eax
  801bf6:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801bfb:	b8 08 00 00 00       	mov    $0x8,%eax
  801c00:	e8 e8 fd ff ff       	call   8019ed <nsipc>
}
  801c05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    
	assert(size < 1600);
  801c0a:	68 3c 29 80 00       	push   $0x80293c
  801c0f:	68 e3 28 80 00       	push   $0x8028e3
  801c14:	6a 6d                	push   $0x6d
  801c16:	68 30 29 80 00       	push   $0x802930
  801c1b:	e8 c4 e5 ff ff       	call   8001e4 <_panic>

00801c20 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c31:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801c36:	8b 45 10             	mov    0x10(%ebp),%eax
  801c39:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801c3e:	b8 09 00 00 00       	mov    $0x9,%eax
  801c43:	e8 a5 fd ff ff       	call   8019ed <nsipc>
}
  801c48:	c9                   	leave  
  801c49:	c3                   	ret    

00801c4a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	56                   	push   %esi
  801c4e:	53                   	push   %ebx
  801c4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c52:	83 ec 0c             	sub    $0xc,%esp
  801c55:	ff 75 08             	push   0x8(%ebp)
  801c58:	e8 9a f2 ff ff       	call   800ef7 <fd2data>
  801c5d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c5f:	83 c4 08             	add    $0x8,%esp
  801c62:	68 48 29 80 00       	push   $0x802948
  801c67:	53                   	push   %ebx
  801c68:	e8 2c ec ff ff       	call   800899 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c6d:	8b 46 04             	mov    0x4(%esi),%eax
  801c70:	2b 06                	sub    (%esi),%eax
  801c72:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c78:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c7f:	00 00 00 
	stat->st_dev = &devpipe;
  801c82:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801c89:	30 80 00 
	return 0;
}
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	53                   	push   %ebx
  801c9c:	83 ec 0c             	sub    $0xc,%esp
  801c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ca2:	53                   	push   %ebx
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 70 f0 ff ff       	call   800d1a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801caa:	89 1c 24             	mov    %ebx,(%esp)
  801cad:	e8 45 f2 ff ff       	call   800ef7 <fd2data>
  801cb2:	83 c4 08             	add    $0x8,%esp
  801cb5:	50                   	push   %eax
  801cb6:	6a 00                	push   $0x0
  801cb8:	e8 5d f0 ff ff       	call   800d1a <sys_page_unmap>
}
  801cbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <_pipeisclosed>:
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	57                   	push   %edi
  801cc6:	56                   	push   %esi
  801cc7:	53                   	push   %ebx
  801cc8:	83 ec 1c             	sub    $0x1c,%esp
  801ccb:	89 c7                	mov    %eax,%edi
  801ccd:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ccf:	a1 04 40 80 00       	mov    0x804004,%eax
  801cd4:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cd7:	83 ec 0c             	sub    $0xc,%esp
  801cda:	57                   	push   %edi
  801cdb:	e8 2b 05 00 00       	call   80220b <pageref>
  801ce0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ce3:	89 34 24             	mov    %esi,(%esp)
  801ce6:	e8 20 05 00 00       	call   80220b <pageref>
		nn = thisenv->env_runs;
  801ceb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cf1:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	39 cb                	cmp    %ecx,%ebx
  801cf9:	74 1b                	je     801d16 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801cfb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cfe:	75 cf                	jne    801ccf <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d00:	8b 42 68             	mov    0x68(%edx),%eax
  801d03:	6a 01                	push   $0x1
  801d05:	50                   	push   %eax
  801d06:	53                   	push   %ebx
  801d07:	68 4f 29 80 00       	push   $0x80294f
  801d0c:	e8 ae e5 ff ff       	call   8002bf <cprintf>
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	eb b9                	jmp    801ccf <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d16:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d19:	0f 94 c0             	sete   %al
  801d1c:	0f b6 c0             	movzbl %al,%eax
}
  801d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5e                   	pop    %esi
  801d24:	5f                   	pop    %edi
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <devpipe_write>:
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	57                   	push   %edi
  801d2b:	56                   	push   %esi
  801d2c:	53                   	push   %ebx
  801d2d:	83 ec 28             	sub    $0x28,%esp
  801d30:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d33:	56                   	push   %esi
  801d34:	e8 be f1 ff ff       	call   800ef7 <fd2data>
  801d39:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	bf 00 00 00 00       	mov    $0x0,%edi
  801d43:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d46:	75 09                	jne    801d51 <devpipe_write+0x2a>
	return i;
  801d48:	89 f8                	mov    %edi,%eax
  801d4a:	eb 23                	jmp    801d6f <devpipe_write+0x48>
			sys_yield();
  801d4c:	e8 25 ef ff ff       	call   800c76 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d51:	8b 43 04             	mov    0x4(%ebx),%eax
  801d54:	8b 0b                	mov    (%ebx),%ecx
  801d56:	8d 51 20             	lea    0x20(%ecx),%edx
  801d59:	39 d0                	cmp    %edx,%eax
  801d5b:	72 1a                	jb     801d77 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801d5d:	89 da                	mov    %ebx,%edx
  801d5f:	89 f0                	mov    %esi,%eax
  801d61:	e8 5c ff ff ff       	call   801cc2 <_pipeisclosed>
  801d66:	85 c0                	test   %eax,%eax
  801d68:	74 e2                	je     801d4c <devpipe_write+0x25>
				return 0;
  801d6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d72:	5b                   	pop    %ebx
  801d73:	5e                   	pop    %esi
  801d74:	5f                   	pop    %edi
  801d75:	5d                   	pop    %ebp
  801d76:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d7a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d7e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d81:	89 c2                	mov    %eax,%edx
  801d83:	c1 fa 1f             	sar    $0x1f,%edx
  801d86:	89 d1                	mov    %edx,%ecx
  801d88:	c1 e9 1b             	shr    $0x1b,%ecx
  801d8b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d8e:	83 e2 1f             	and    $0x1f,%edx
  801d91:	29 ca                	sub    %ecx,%edx
  801d93:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d97:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d9b:	83 c0 01             	add    $0x1,%eax
  801d9e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801da1:	83 c7 01             	add    $0x1,%edi
  801da4:	eb 9d                	jmp    801d43 <devpipe_write+0x1c>

00801da6 <devpipe_read>:
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	57                   	push   %edi
  801daa:	56                   	push   %esi
  801dab:	53                   	push   %ebx
  801dac:	83 ec 18             	sub    $0x18,%esp
  801daf:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801db2:	57                   	push   %edi
  801db3:	e8 3f f1 ff ff       	call   800ef7 <fd2data>
  801db8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dba:	83 c4 10             	add    $0x10,%esp
  801dbd:	be 00 00 00 00       	mov    $0x0,%esi
  801dc2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc5:	75 13                	jne    801dda <devpipe_read+0x34>
	return i;
  801dc7:	89 f0                	mov    %esi,%eax
  801dc9:	eb 02                	jmp    801dcd <devpipe_read+0x27>
				return i;
  801dcb:	89 f0                	mov    %esi,%eax
}
  801dcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
			sys_yield();
  801dd5:	e8 9c ee ff ff       	call   800c76 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801dda:	8b 03                	mov    (%ebx),%eax
  801ddc:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ddf:	75 18                	jne    801df9 <devpipe_read+0x53>
			if (i > 0)
  801de1:	85 f6                	test   %esi,%esi
  801de3:	75 e6                	jne    801dcb <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801de5:	89 da                	mov    %ebx,%edx
  801de7:	89 f8                	mov    %edi,%eax
  801de9:	e8 d4 fe ff ff       	call   801cc2 <_pipeisclosed>
  801dee:	85 c0                	test   %eax,%eax
  801df0:	74 e3                	je     801dd5 <devpipe_read+0x2f>
				return 0;
  801df2:	b8 00 00 00 00       	mov    $0x0,%eax
  801df7:	eb d4                	jmp    801dcd <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801df9:	99                   	cltd   
  801dfa:	c1 ea 1b             	shr    $0x1b,%edx
  801dfd:	01 d0                	add    %edx,%eax
  801dff:	83 e0 1f             	and    $0x1f,%eax
  801e02:	29 d0                	sub    %edx,%eax
  801e04:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e0c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e0f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e12:	83 c6 01             	add    $0x1,%esi
  801e15:	eb ab                	jmp    801dc2 <devpipe_read+0x1c>

00801e17 <pipe>:
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
  801e1c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e22:	50                   	push   %eax
  801e23:	e8 e6 f0 ff ff       	call   800f0e <fd_alloc>
  801e28:	89 c3                	mov    %eax,%ebx
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	0f 88 23 01 00 00    	js     801f58 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e35:	83 ec 04             	sub    $0x4,%esp
  801e38:	68 07 04 00 00       	push   $0x407
  801e3d:	ff 75 f4             	push   -0xc(%ebp)
  801e40:	6a 00                	push   $0x0
  801e42:	e8 4e ee ff ff       	call   800c95 <sys_page_alloc>
  801e47:	89 c3                	mov    %eax,%ebx
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	0f 88 04 01 00 00    	js     801f58 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801e54:	83 ec 0c             	sub    $0xc,%esp
  801e57:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e5a:	50                   	push   %eax
  801e5b:	e8 ae f0 ff ff       	call   800f0e <fd_alloc>
  801e60:	89 c3                	mov    %eax,%ebx
  801e62:	83 c4 10             	add    $0x10,%esp
  801e65:	85 c0                	test   %eax,%eax
  801e67:	0f 88 db 00 00 00    	js     801f48 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6d:	83 ec 04             	sub    $0x4,%esp
  801e70:	68 07 04 00 00       	push   $0x407
  801e75:	ff 75 f0             	push   -0x10(%ebp)
  801e78:	6a 00                	push   $0x0
  801e7a:	e8 16 ee ff ff       	call   800c95 <sys_page_alloc>
  801e7f:	89 c3                	mov    %eax,%ebx
  801e81:	83 c4 10             	add    $0x10,%esp
  801e84:	85 c0                	test   %eax,%eax
  801e86:	0f 88 bc 00 00 00    	js     801f48 <pipe+0x131>
	va = fd2data(fd0);
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	ff 75 f4             	push   -0xc(%ebp)
  801e92:	e8 60 f0 ff ff       	call   800ef7 <fd2data>
  801e97:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e99:	83 c4 0c             	add    $0xc,%esp
  801e9c:	68 07 04 00 00       	push   $0x407
  801ea1:	50                   	push   %eax
  801ea2:	6a 00                	push   $0x0
  801ea4:	e8 ec ed ff ff       	call   800c95 <sys_page_alloc>
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	0f 88 82 00 00 00    	js     801f38 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb6:	83 ec 0c             	sub    $0xc,%esp
  801eb9:	ff 75 f0             	push   -0x10(%ebp)
  801ebc:	e8 36 f0 ff ff       	call   800ef7 <fd2data>
  801ec1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ec8:	50                   	push   %eax
  801ec9:	6a 00                	push   $0x0
  801ecb:	56                   	push   %esi
  801ecc:	6a 00                	push   $0x0
  801ece:	e8 05 ee ff ff       	call   800cd8 <sys_page_map>
  801ed3:	89 c3                	mov    %eax,%ebx
  801ed5:	83 c4 20             	add    $0x20,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 4e                	js     801f2a <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801edc:	a1 40 30 80 00       	mov    0x803040,%eax
  801ee1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ee4:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ee6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ee9:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801ef0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ef3:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ef8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	ff 75 f4             	push   -0xc(%ebp)
  801f05:	e8 dd ef ff ff       	call   800ee7 <fd2num>
  801f0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f0d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f0f:	83 c4 04             	add    $0x4,%esp
  801f12:	ff 75 f0             	push   -0x10(%ebp)
  801f15:	e8 cd ef ff ff       	call   800ee7 <fd2num>
  801f1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f1d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f28:	eb 2e                	jmp    801f58 <pipe+0x141>
	sys_page_unmap(0, va);
  801f2a:	83 ec 08             	sub    $0x8,%esp
  801f2d:	56                   	push   %esi
  801f2e:	6a 00                	push   $0x0
  801f30:	e8 e5 ed ff ff       	call   800d1a <sys_page_unmap>
  801f35:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f38:	83 ec 08             	sub    $0x8,%esp
  801f3b:	ff 75 f0             	push   -0x10(%ebp)
  801f3e:	6a 00                	push   $0x0
  801f40:	e8 d5 ed ff ff       	call   800d1a <sys_page_unmap>
  801f45:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f48:	83 ec 08             	sub    $0x8,%esp
  801f4b:	ff 75 f4             	push   -0xc(%ebp)
  801f4e:	6a 00                	push   $0x0
  801f50:	e8 c5 ed ff ff       	call   800d1a <sys_page_unmap>
  801f55:	83 c4 10             	add    $0x10,%esp
}
  801f58:	89 d8                	mov    %ebx,%eax
  801f5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f5d:	5b                   	pop    %ebx
  801f5e:	5e                   	pop    %esi
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <pipeisclosed>:
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6a:	50                   	push   %eax
  801f6b:	ff 75 08             	push   0x8(%ebp)
  801f6e:	e8 eb ef ff ff       	call   800f5e <fd_lookup>
  801f73:	83 c4 10             	add    $0x10,%esp
  801f76:	85 c0                	test   %eax,%eax
  801f78:	78 18                	js     801f92 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801f7a:	83 ec 0c             	sub    $0xc,%esp
  801f7d:	ff 75 f4             	push   -0xc(%ebp)
  801f80:	e8 72 ef ff ff       	call   800ef7 <fd2data>
  801f85:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8a:	e8 33 fd ff ff       	call   801cc2 <_pipeisclosed>
  801f8f:	83 c4 10             	add    $0x10,%esp
}
  801f92:	c9                   	leave  
  801f93:	c3                   	ret    

00801f94 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801f94:	b8 00 00 00 00       	mov    $0x0,%eax
  801f99:	c3                   	ret    

00801f9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fa0:	68 67 29 80 00       	push   $0x802967
  801fa5:	ff 75 0c             	push   0xc(%ebp)
  801fa8:	e8 ec e8 ff ff       	call   800899 <strcpy>
	return 0;
}
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb2:	c9                   	leave  
  801fb3:	c3                   	ret    

00801fb4 <devcons_write>:
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	57                   	push   %edi
  801fb8:	56                   	push   %esi
  801fb9:	53                   	push   %ebx
  801fba:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fc0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fc5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fcb:	eb 2e                	jmp    801ffb <devcons_write+0x47>
		m = n - tot;
  801fcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fd0:	29 f3                	sub    %esi,%ebx
  801fd2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801fd7:	39 c3                	cmp    %eax,%ebx
  801fd9:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fdc:	83 ec 04             	sub    $0x4,%esp
  801fdf:	53                   	push   %ebx
  801fe0:	89 f0                	mov    %esi,%eax
  801fe2:	03 45 0c             	add    0xc(%ebp),%eax
  801fe5:	50                   	push   %eax
  801fe6:	57                   	push   %edi
  801fe7:	e8 43 ea ff ff       	call   800a2f <memmove>
		sys_cputs(buf, m);
  801fec:	83 c4 08             	add    $0x8,%esp
  801fef:	53                   	push   %ebx
  801ff0:	57                   	push   %edi
  801ff1:	e8 e3 eb ff ff       	call   800bd9 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ff6:	01 de                	add    %ebx,%esi
  801ff8:	83 c4 10             	add    $0x10,%esp
  801ffb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ffe:	72 cd                	jb     801fcd <devcons_write+0x19>
}
  802000:	89 f0                	mov    %esi,%eax
  802002:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802005:	5b                   	pop    %ebx
  802006:	5e                   	pop    %esi
  802007:	5f                   	pop    %edi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    

0080200a <devcons_read>:
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	83 ec 08             	sub    $0x8,%esp
  802010:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802015:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802019:	75 07                	jne    802022 <devcons_read+0x18>
  80201b:	eb 1f                	jmp    80203c <devcons_read+0x32>
		sys_yield();
  80201d:	e8 54 ec ff ff       	call   800c76 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802022:	e8 d0 eb ff ff       	call   800bf7 <sys_cgetc>
  802027:	85 c0                	test   %eax,%eax
  802029:	74 f2                	je     80201d <devcons_read+0x13>
	if (c < 0)
  80202b:	78 0f                	js     80203c <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80202d:	83 f8 04             	cmp    $0x4,%eax
  802030:	74 0c                	je     80203e <devcons_read+0x34>
	*(char*)vbuf = c;
  802032:	8b 55 0c             	mov    0xc(%ebp),%edx
  802035:	88 02                	mov    %al,(%edx)
	return 1;
  802037:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    
		return 0;
  80203e:	b8 00 00 00 00       	mov    $0x0,%eax
  802043:	eb f7                	jmp    80203c <devcons_read+0x32>

00802045 <cputchar>:
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80204b:	8b 45 08             	mov    0x8(%ebp),%eax
  80204e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802051:	6a 01                	push   $0x1
  802053:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802056:	50                   	push   %eax
  802057:	e8 7d eb ff ff       	call   800bd9 <sys_cputs>
}
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	c9                   	leave  
  802060:	c3                   	ret    

00802061 <getchar>:
{
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802067:	6a 01                	push   $0x1
  802069:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80206c:	50                   	push   %eax
  80206d:	6a 00                	push   $0x0
  80206f:	e8 53 f1 ff ff       	call   8011c7 <read>
	if (r < 0)
  802074:	83 c4 10             	add    $0x10,%esp
  802077:	85 c0                	test   %eax,%eax
  802079:	78 06                	js     802081 <getchar+0x20>
	if (r < 1)
  80207b:	74 06                	je     802083 <getchar+0x22>
	return c;
  80207d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802081:	c9                   	leave  
  802082:	c3                   	ret    
		return -E_EOF;
  802083:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802088:	eb f7                	jmp    802081 <getchar+0x20>

0080208a <iscons>:
{
  80208a:	55                   	push   %ebp
  80208b:	89 e5                	mov    %esp,%ebp
  80208d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802093:	50                   	push   %eax
  802094:	ff 75 08             	push   0x8(%ebp)
  802097:	e8 c2 ee ff ff       	call   800f5e <fd_lookup>
  80209c:	83 c4 10             	add    $0x10,%esp
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	78 11                	js     8020b4 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8020a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a6:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8020ac:	39 10                	cmp    %edx,(%eax)
  8020ae:	0f 94 c0             	sete   %al
  8020b1:	0f b6 c0             	movzbl %al,%eax
}
  8020b4:	c9                   	leave  
  8020b5:	c3                   	ret    

008020b6 <opencons>:
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020bf:	50                   	push   %eax
  8020c0:	e8 49 ee ff ff       	call   800f0e <fd_alloc>
  8020c5:	83 c4 10             	add    $0x10,%esp
  8020c8:	85 c0                	test   %eax,%eax
  8020ca:	78 3a                	js     802106 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020cc:	83 ec 04             	sub    $0x4,%esp
  8020cf:	68 07 04 00 00       	push   $0x407
  8020d4:	ff 75 f4             	push   -0xc(%ebp)
  8020d7:	6a 00                	push   $0x0
  8020d9:	e8 b7 eb ff ff       	call   800c95 <sys_page_alloc>
  8020de:	83 c4 10             	add    $0x10,%esp
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 21                	js     802106 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8020e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e8:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8020ee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020fa:	83 ec 0c             	sub    $0xc,%esp
  8020fd:	50                   	push   %eax
  8020fe:	e8 e4 ed ff ff       	call   800ee7 <fd2num>
  802103:	83 c4 10             	add    $0x10,%esp
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	56                   	push   %esi
  80210c:	53                   	push   %ebx
  80210d:	8b 75 08             	mov    0x8(%ebp),%esi
  802110:	8b 45 0c             	mov    0xc(%ebp),%eax
  802113:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802116:	85 c0                	test   %eax,%eax
  802118:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80211d:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802120:	83 ec 0c             	sub    $0xc,%esp
  802123:	50                   	push   %eax
  802124:	e8 1c ed ff ff       	call   800e45 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	85 f6                	test   %esi,%esi
  80212e:	74 17                	je     802147 <ipc_recv+0x3f>
  802130:	ba 00 00 00 00       	mov    $0x0,%edx
  802135:	85 c0                	test   %eax,%eax
  802137:	78 0c                	js     802145 <ipc_recv+0x3d>
  802139:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80213f:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802145:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802147:	85 db                	test   %ebx,%ebx
  802149:	74 17                	je     802162 <ipc_recv+0x5a>
  80214b:	ba 00 00 00 00       	mov    $0x0,%edx
  802150:	85 c0                	test   %eax,%eax
  802152:	78 0c                	js     802160 <ipc_recv+0x58>
  802154:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80215a:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  802160:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802162:	85 c0                	test   %eax,%eax
  802164:	78 0b                	js     802171 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802166:	a1 04 40 80 00       	mov    0x804004,%eax
  80216b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  802171:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    

00802178 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	57                   	push   %edi
  80217c:	56                   	push   %esi
  80217d:	53                   	push   %ebx
  80217e:	83 ec 0c             	sub    $0xc,%esp
  802181:	8b 7d 08             	mov    0x8(%ebp),%edi
  802184:	8b 75 0c             	mov    0xc(%ebp),%esi
  802187:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80218a:	85 db                	test   %ebx,%ebx
  80218c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802191:	0f 44 d8             	cmove  %eax,%ebx
  802194:	eb 05                	jmp    80219b <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802196:	e8 db ea ff ff       	call   800c76 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80219b:	ff 75 14             	push   0x14(%ebp)
  80219e:	53                   	push   %ebx
  80219f:	56                   	push   %esi
  8021a0:	57                   	push   %edi
  8021a1:	e8 7c ec ff ff       	call   800e22 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8021a6:	83 c4 10             	add    $0x10,%esp
  8021a9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021ac:	74 e8                	je     802196 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8021ae:	85 c0                	test   %eax,%eax
  8021b0:	78 08                	js     8021ba <ipc_send+0x42>
	}while (r<0);

}
  8021b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b5:	5b                   	pop    %ebx
  8021b6:	5e                   	pop    %esi
  8021b7:	5f                   	pop    %edi
  8021b8:	5d                   	pop    %ebp
  8021b9:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8021ba:	50                   	push   %eax
  8021bb:	68 73 29 80 00       	push   $0x802973
  8021c0:	6a 3d                	push   $0x3d
  8021c2:	68 87 29 80 00       	push   $0x802987
  8021c7:	e8 18 e0 ff ff       	call   8001e4 <_panic>

008021cc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021d2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021d7:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8021dd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021e3:	8b 52 60             	mov    0x60(%edx),%edx
  8021e6:	39 ca                	cmp    %ecx,%edx
  8021e8:	74 11                	je     8021fb <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8021ea:	83 c0 01             	add    $0x1,%eax
  8021ed:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021f2:	75 e3                	jne    8021d7 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8021f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f9:	eb 0e                	jmp    802209 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8021fb:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802201:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802206:	8b 40 58             	mov    0x58(%eax),%eax
}
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    

0080220b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802211:	89 c2                	mov    %eax,%edx
  802213:	c1 ea 16             	shr    $0x16,%edx
  802216:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80221d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802222:	f6 c1 01             	test   $0x1,%cl
  802225:	74 1c                	je     802243 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802227:	c1 e8 0c             	shr    $0xc,%eax
  80222a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802231:	a8 01                	test   $0x1,%al
  802233:	74 0e                	je     802243 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802235:	c1 e8 0c             	shr    $0xc,%eax
  802238:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80223f:	ef 
  802240:	0f b7 d2             	movzwl %dx,%edx
}
  802243:	89 d0                	mov    %edx,%eax
  802245:	5d                   	pop    %ebp
  802246:	c3                   	ret    
  802247:	66 90                	xchg   %ax,%ax
  802249:	66 90                	xchg   %ax,%ax
  80224b:	66 90                	xchg   %ax,%ax
  80224d:	66 90                	xchg   %ax,%ax
  80224f:	90                   	nop

00802250 <__udivdi3>:
  802250:	f3 0f 1e fb          	endbr32 
  802254:	55                   	push   %ebp
  802255:	57                   	push   %edi
  802256:	56                   	push   %esi
  802257:	53                   	push   %ebx
  802258:	83 ec 1c             	sub    $0x1c,%esp
  80225b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80225f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802263:	8b 74 24 34          	mov    0x34(%esp),%esi
  802267:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80226b:	85 c0                	test   %eax,%eax
  80226d:	75 19                	jne    802288 <__udivdi3+0x38>
  80226f:	39 f3                	cmp    %esi,%ebx
  802271:	76 4d                	jbe    8022c0 <__udivdi3+0x70>
  802273:	31 ff                	xor    %edi,%edi
  802275:	89 e8                	mov    %ebp,%eax
  802277:	89 f2                	mov    %esi,%edx
  802279:	f7 f3                	div    %ebx
  80227b:	89 fa                	mov    %edi,%edx
  80227d:	83 c4 1c             	add    $0x1c,%esp
  802280:	5b                   	pop    %ebx
  802281:	5e                   	pop    %esi
  802282:	5f                   	pop    %edi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    
  802285:	8d 76 00             	lea    0x0(%esi),%esi
  802288:	39 f0                	cmp    %esi,%eax
  80228a:	76 14                	jbe    8022a0 <__udivdi3+0x50>
  80228c:	31 ff                	xor    %edi,%edi
  80228e:	31 c0                	xor    %eax,%eax
  802290:	89 fa                	mov    %edi,%edx
  802292:	83 c4 1c             	add    $0x1c,%esp
  802295:	5b                   	pop    %ebx
  802296:	5e                   	pop    %esi
  802297:	5f                   	pop    %edi
  802298:	5d                   	pop    %ebp
  802299:	c3                   	ret    
  80229a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a0:	0f bd f8             	bsr    %eax,%edi
  8022a3:	83 f7 1f             	xor    $0x1f,%edi
  8022a6:	75 48                	jne    8022f0 <__udivdi3+0xa0>
  8022a8:	39 f0                	cmp    %esi,%eax
  8022aa:	72 06                	jb     8022b2 <__udivdi3+0x62>
  8022ac:	31 c0                	xor    %eax,%eax
  8022ae:	39 eb                	cmp    %ebp,%ebx
  8022b0:	77 de                	ja     802290 <__udivdi3+0x40>
  8022b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b7:	eb d7                	jmp    802290 <__udivdi3+0x40>
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d9                	mov    %ebx,%ecx
  8022c2:	85 db                	test   %ebx,%ebx
  8022c4:	75 0b                	jne    8022d1 <__udivdi3+0x81>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f3                	div    %ebx
  8022cf:	89 c1                	mov    %eax,%ecx
  8022d1:	31 d2                	xor    %edx,%edx
  8022d3:	89 f0                	mov    %esi,%eax
  8022d5:	f7 f1                	div    %ecx
  8022d7:	89 c6                	mov    %eax,%esi
  8022d9:	89 e8                	mov    %ebp,%eax
  8022db:	89 f7                	mov    %esi,%edi
  8022dd:	f7 f1                	div    %ecx
  8022df:	89 fa                	mov    %edi,%edx
  8022e1:	83 c4 1c             	add    $0x1c,%esp
  8022e4:	5b                   	pop    %ebx
  8022e5:	5e                   	pop    %esi
  8022e6:	5f                   	pop    %edi
  8022e7:	5d                   	pop    %ebp
  8022e8:	c3                   	ret    
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	89 f9                	mov    %edi,%ecx
  8022f2:	ba 20 00 00 00       	mov    $0x20,%edx
  8022f7:	29 fa                	sub    %edi,%edx
  8022f9:	d3 e0                	shl    %cl,%eax
  8022fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022ff:	89 d1                	mov    %edx,%ecx
  802301:	89 d8                	mov    %ebx,%eax
  802303:	d3 e8                	shr    %cl,%eax
  802305:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802309:	09 c1                	or     %eax,%ecx
  80230b:	89 f0                	mov    %esi,%eax
  80230d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802311:	89 f9                	mov    %edi,%ecx
  802313:	d3 e3                	shl    %cl,%ebx
  802315:	89 d1                	mov    %edx,%ecx
  802317:	d3 e8                	shr    %cl,%eax
  802319:	89 f9                	mov    %edi,%ecx
  80231b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80231f:	89 eb                	mov    %ebp,%ebx
  802321:	d3 e6                	shl    %cl,%esi
  802323:	89 d1                	mov    %edx,%ecx
  802325:	d3 eb                	shr    %cl,%ebx
  802327:	09 f3                	or     %esi,%ebx
  802329:	89 c6                	mov    %eax,%esi
  80232b:	89 f2                	mov    %esi,%edx
  80232d:	89 d8                	mov    %ebx,%eax
  80232f:	f7 74 24 08          	divl   0x8(%esp)
  802333:	89 d6                	mov    %edx,%esi
  802335:	89 c3                	mov    %eax,%ebx
  802337:	f7 64 24 0c          	mull   0xc(%esp)
  80233b:	39 d6                	cmp    %edx,%esi
  80233d:	72 19                	jb     802358 <__udivdi3+0x108>
  80233f:	89 f9                	mov    %edi,%ecx
  802341:	d3 e5                	shl    %cl,%ebp
  802343:	39 c5                	cmp    %eax,%ebp
  802345:	73 04                	jae    80234b <__udivdi3+0xfb>
  802347:	39 d6                	cmp    %edx,%esi
  802349:	74 0d                	je     802358 <__udivdi3+0x108>
  80234b:	89 d8                	mov    %ebx,%eax
  80234d:	31 ff                	xor    %edi,%edi
  80234f:	e9 3c ff ff ff       	jmp    802290 <__udivdi3+0x40>
  802354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802358:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80235b:	31 ff                	xor    %edi,%edi
  80235d:	e9 2e ff ff ff       	jmp    802290 <__udivdi3+0x40>
  802362:	66 90                	xchg   %ax,%ax
  802364:	66 90                	xchg   %ax,%ax
  802366:	66 90                	xchg   %ax,%ax
  802368:	66 90                	xchg   %ax,%ax
  80236a:	66 90                	xchg   %ax,%ax
  80236c:	66 90                	xchg   %ax,%ax
  80236e:	66 90                	xchg   %ax,%ax

00802370 <__umoddi3>:
  802370:	f3 0f 1e fb          	endbr32 
  802374:	55                   	push   %ebp
  802375:	57                   	push   %edi
  802376:	56                   	push   %esi
  802377:	53                   	push   %ebx
  802378:	83 ec 1c             	sub    $0x1c,%esp
  80237b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80237f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802383:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802387:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80238b:	89 f0                	mov    %esi,%eax
  80238d:	89 da                	mov    %ebx,%edx
  80238f:	85 ff                	test   %edi,%edi
  802391:	75 15                	jne    8023a8 <__umoddi3+0x38>
  802393:	39 dd                	cmp    %ebx,%ebp
  802395:	76 39                	jbe    8023d0 <__umoddi3+0x60>
  802397:	f7 f5                	div    %ebp
  802399:	89 d0                	mov    %edx,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	83 c4 1c             	add    $0x1c,%esp
  8023a0:	5b                   	pop    %ebx
  8023a1:	5e                   	pop    %esi
  8023a2:	5f                   	pop    %edi
  8023a3:	5d                   	pop    %ebp
  8023a4:	c3                   	ret    
  8023a5:	8d 76 00             	lea    0x0(%esi),%esi
  8023a8:	39 df                	cmp    %ebx,%edi
  8023aa:	77 f1                	ja     80239d <__umoddi3+0x2d>
  8023ac:	0f bd cf             	bsr    %edi,%ecx
  8023af:	83 f1 1f             	xor    $0x1f,%ecx
  8023b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023b6:	75 40                	jne    8023f8 <__umoddi3+0x88>
  8023b8:	39 df                	cmp    %ebx,%edi
  8023ba:	72 04                	jb     8023c0 <__umoddi3+0x50>
  8023bc:	39 f5                	cmp    %esi,%ebp
  8023be:	77 dd                	ja     80239d <__umoddi3+0x2d>
  8023c0:	89 da                	mov    %ebx,%edx
  8023c2:	89 f0                	mov    %esi,%eax
  8023c4:	29 e8                	sub    %ebp,%eax
  8023c6:	19 fa                	sbb    %edi,%edx
  8023c8:	eb d3                	jmp    80239d <__umoddi3+0x2d>
  8023ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d0:	89 e9                	mov    %ebp,%ecx
  8023d2:	85 ed                	test   %ebp,%ebp
  8023d4:	75 0b                	jne    8023e1 <__umoddi3+0x71>
  8023d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	f7 f5                	div    %ebp
  8023df:	89 c1                	mov    %eax,%ecx
  8023e1:	89 d8                	mov    %ebx,%eax
  8023e3:	31 d2                	xor    %edx,%edx
  8023e5:	f7 f1                	div    %ecx
  8023e7:	89 f0                	mov    %esi,%eax
  8023e9:	f7 f1                	div    %ecx
  8023eb:	89 d0                	mov    %edx,%eax
  8023ed:	31 d2                	xor    %edx,%edx
  8023ef:	eb ac                	jmp    80239d <__umoddi3+0x2d>
  8023f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023fc:	ba 20 00 00 00       	mov    $0x20,%edx
  802401:	29 c2                	sub    %eax,%edx
  802403:	89 c1                	mov    %eax,%ecx
  802405:	89 e8                	mov    %ebp,%eax
  802407:	d3 e7                	shl    %cl,%edi
  802409:	89 d1                	mov    %edx,%ecx
  80240b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80240f:	d3 e8                	shr    %cl,%eax
  802411:	89 c1                	mov    %eax,%ecx
  802413:	8b 44 24 04          	mov    0x4(%esp),%eax
  802417:	09 f9                	or     %edi,%ecx
  802419:	89 df                	mov    %ebx,%edi
  80241b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80241f:	89 c1                	mov    %eax,%ecx
  802421:	d3 e5                	shl    %cl,%ebp
  802423:	89 d1                	mov    %edx,%ecx
  802425:	d3 ef                	shr    %cl,%edi
  802427:	89 c1                	mov    %eax,%ecx
  802429:	89 f0                	mov    %esi,%eax
  80242b:	d3 e3                	shl    %cl,%ebx
  80242d:	89 d1                	mov    %edx,%ecx
  80242f:	89 fa                	mov    %edi,%edx
  802431:	d3 e8                	shr    %cl,%eax
  802433:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802438:	09 d8                	or     %ebx,%eax
  80243a:	f7 74 24 08          	divl   0x8(%esp)
  80243e:	89 d3                	mov    %edx,%ebx
  802440:	d3 e6                	shl    %cl,%esi
  802442:	f7 e5                	mul    %ebp
  802444:	89 c7                	mov    %eax,%edi
  802446:	89 d1                	mov    %edx,%ecx
  802448:	39 d3                	cmp    %edx,%ebx
  80244a:	72 06                	jb     802452 <__umoddi3+0xe2>
  80244c:	75 0e                	jne    80245c <__umoddi3+0xec>
  80244e:	39 c6                	cmp    %eax,%esi
  802450:	73 0a                	jae    80245c <__umoddi3+0xec>
  802452:	29 e8                	sub    %ebp,%eax
  802454:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802458:	89 d1                	mov    %edx,%ecx
  80245a:	89 c7                	mov    %eax,%edi
  80245c:	89 f5                	mov    %esi,%ebp
  80245e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802462:	29 fd                	sub    %edi,%ebp
  802464:	19 cb                	sbb    %ecx,%ebx
  802466:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80246b:	89 d8                	mov    %ebx,%eax
  80246d:	d3 e0                	shl    %cl,%eax
  80246f:	89 f1                	mov    %esi,%ecx
  802471:	d3 ed                	shr    %cl,%ebp
  802473:	d3 eb                	shr    %cl,%ebx
  802475:	09 e8                	or     %ebp,%eax
  802477:	89 da                	mov    %ebx,%edx
  802479:	83 c4 1c             	add    $0x1c,%esp
  80247c:	5b                   	pop    %ebx
  80247d:	5e                   	pop    %esi
  80247e:	5f                   	pop    %edi
  80247f:	5d                   	pop    %ebp
  802480:	c3                   	ret    
