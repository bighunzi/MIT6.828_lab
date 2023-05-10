
obj/user/faultalloc.debug：     文件格式 elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 60 23 80 00       	push   $0x802360
  800045:	e8 be 01 00 00       	call   800208 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 80 0b 00 00       	call   800bde <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 ac 23 80 00       	push   $0x8023ac
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 1a 07 00 00       	call   80078d <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 80 23 80 00       	push   $0x802380
  800085:	6a 0e                	push   $0xe
  800087:	68 6a 23 80 00       	push   $0x80236a
  80008c:	e8 9c 00 00 00       	call   80012d <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 8f 0d 00 00       	call   800e30 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 7c 23 80 00       	push   $0x80237c
  8000ae:	e8 55 01 00 00       	call   800208 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 7c 23 80 00       	push   $0x80237c
  8000c0:	e8 43 01 00 00       	call   800208 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 c6 0a 00 00       	call   800ba0 <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8000e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ea:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ef:	85 db                	test   %ebx,%ebx
  8000f1:	7e 07                	jle    8000fa <libmain+0x30>
		binaryname = argv[0];
  8000f3:	8b 06                	mov    (%esi),%eax
  8000f5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000fa:	83 ec 08             	sub    $0x8,%esp
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	e8 8d ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800104:	e8 0a 00 00 00       	call   800113 <exit>
}
  800109:	83 c4 10             	add    $0x10,%esp
  80010c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800119:	e8 7f 0f 00 00       	call   80109d <close_all>
	sys_env_destroy(0);
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	6a 00                	push   $0x0
  800123:	e8 37 0a 00 00       	call   800b5f <sys_env_destroy>
}
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    

0080012d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800132:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800135:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80013b:	e8 60 0a 00 00       	call   800ba0 <sys_getenvid>
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	ff 75 0c             	push   0xc(%ebp)
  800146:	ff 75 08             	push   0x8(%ebp)
  800149:	56                   	push   %esi
  80014a:	50                   	push   %eax
  80014b:	68 d8 23 80 00       	push   $0x8023d8
  800150:	e8 b3 00 00 00       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800155:	83 c4 18             	add    $0x18,%esp
  800158:	53                   	push   %ebx
  800159:	ff 75 10             	push   0x10(%ebp)
  80015c:	e8 56 00 00 00       	call   8001b7 <vcprintf>
	cprintf("\n");
  800161:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  800168:	e8 9b 00 00 00       	call   800208 <cprintf>
  80016d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800170:	cc                   	int3   
  800171:	eb fd                	jmp    800170 <_panic+0x43>

00800173 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	53                   	push   %ebx
  800177:	83 ec 04             	sub    $0x4,%esp
  80017a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017d:	8b 13                	mov    (%ebx),%edx
  80017f:	8d 42 01             	lea    0x1(%edx),%eax
  800182:	89 03                	mov    %eax,(%ebx)
  800184:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800187:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800190:	74 09                	je     80019b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800192:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800196:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800199:	c9                   	leave  
  80019a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80019b:	83 ec 08             	sub    $0x8,%esp
  80019e:	68 ff 00 00 00       	push   $0xff
  8001a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 76 09 00 00       	call   800b22 <sys_cputs>
		b->idx = 0;
  8001ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b2:	83 c4 10             	add    $0x10,%esp
  8001b5:	eb db                	jmp    800192 <putch+0x1f>

008001b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c7:	00 00 00 
	b.cnt = 0;
  8001ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d4:	ff 75 0c             	push   0xc(%ebp)
  8001d7:	ff 75 08             	push   0x8(%ebp)
  8001da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	68 73 01 80 00       	push   $0x800173
  8001e6:	e8 14 01 00 00       	call   8002ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 22 09 00 00       	call   800b22 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	push   0x8(%ebp)
  800215:	e8 9d ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 1c             	sub    $0x1c,%esp
  800225:	89 c7                	mov    %eax,%edi
  800227:	89 d6                	mov    %edx,%esi
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022f:	89 d1                	mov    %edx,%ecx
  800231:	89 c2                	mov    %eax,%edx
  800233:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800236:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800239:	8b 45 10             	mov    0x10(%ebp),%eax
  80023c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800249:	39 c2                	cmp    %eax,%edx
  80024b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80024e:	72 3e                	jb     80028e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	ff 75 18             	push   0x18(%ebp)
  800256:	83 eb 01             	sub    $0x1,%ebx
  800259:	53                   	push   %ebx
  80025a:	50                   	push   %eax
  80025b:	83 ec 08             	sub    $0x8,%esp
  80025e:	ff 75 e4             	push   -0x1c(%ebp)
  800261:	ff 75 e0             	push   -0x20(%ebp)
  800264:	ff 75 dc             	push   -0x24(%ebp)
  800267:	ff 75 d8             	push   -0x28(%ebp)
  80026a:	e8 b1 1e 00 00       	call   802120 <__udivdi3>
  80026f:	83 c4 18             	add    $0x18,%esp
  800272:	52                   	push   %edx
  800273:	50                   	push   %eax
  800274:	89 f2                	mov    %esi,%edx
  800276:	89 f8                	mov    %edi,%eax
  800278:	e8 9f ff ff ff       	call   80021c <printnum>
  80027d:	83 c4 20             	add    $0x20,%esp
  800280:	eb 13                	jmp    800295 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	56                   	push   %esi
  800286:	ff 75 18             	push   0x18(%ebp)
  800289:	ff d7                	call   *%edi
  80028b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028e:	83 eb 01             	sub    $0x1,%ebx
  800291:	85 db                	test   %ebx,%ebx
  800293:	7f ed                	jg     800282 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	83 ec 04             	sub    $0x4,%esp
  80029c:	ff 75 e4             	push   -0x1c(%ebp)
  80029f:	ff 75 e0             	push   -0x20(%ebp)
  8002a2:	ff 75 dc             	push   -0x24(%ebp)
  8002a5:	ff 75 d8             	push   -0x28(%ebp)
  8002a8:	e8 93 1f 00 00       	call   802240 <__umoddi3>
  8002ad:	83 c4 14             	add    $0x14,%esp
  8002b0:	0f be 80 fb 23 80 00 	movsbl 0x8023fb(%eax),%eax
  8002b7:	50                   	push   %eax
  8002b8:	ff d7                	call   *%edi
}
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d4:	73 0a                	jae    8002e0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 45 08             	mov    0x8(%ebp),%eax
  8002de:	88 02                	mov    %al,(%edx)
}
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <printfmt>:
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002eb:	50                   	push   %eax
  8002ec:	ff 75 10             	push   0x10(%ebp)
  8002ef:	ff 75 0c             	push   0xc(%ebp)
  8002f2:	ff 75 08             	push   0x8(%ebp)
  8002f5:	e8 05 00 00 00       	call   8002ff <vprintfmt>
}
  8002fa:	83 c4 10             	add    $0x10,%esp
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    

008002ff <vprintfmt>:
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	57                   	push   %edi
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
  800305:	83 ec 3c             	sub    $0x3c,%esp
  800308:	8b 75 08             	mov    0x8(%ebp),%esi
  80030b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800311:	eb 0a                	jmp    80031d <vprintfmt+0x1e>
			putch(ch, putdat);
  800313:	83 ec 08             	sub    $0x8,%esp
  800316:	53                   	push   %ebx
  800317:	50                   	push   %eax
  800318:	ff d6                	call   *%esi
  80031a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031d:	83 c7 01             	add    $0x1,%edi
  800320:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800324:	83 f8 25             	cmp    $0x25,%eax
  800327:	74 0c                	je     800335 <vprintfmt+0x36>
			if (ch == '\0')
  800329:	85 c0                	test   %eax,%eax
  80032b:	75 e6                	jne    800313 <vprintfmt+0x14>
}
  80032d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800330:	5b                   	pop    %ebx
  800331:	5e                   	pop    %esi
  800332:	5f                   	pop    %edi
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    
		padc = ' ';
  800335:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800339:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800340:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800347:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80034e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8d 47 01             	lea    0x1(%edi),%eax
  800356:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800359:	0f b6 17             	movzbl (%edi),%edx
  80035c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80035f:	3c 55                	cmp    $0x55,%al
  800361:	0f 87 bb 03 00 00    	ja     800722 <vprintfmt+0x423>
  800367:	0f b6 c0             	movzbl %al,%eax
  80036a:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800374:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800378:	eb d9                	jmp    800353 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800381:	eb d0                	jmp    800353 <vprintfmt+0x54>
  800383:	0f b6 d2             	movzbl %dl,%edx
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800389:	b8 00 00 00 00       	mov    $0x0,%eax
  80038e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800391:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800394:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800398:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039e:	83 f9 09             	cmp    $0x9,%ecx
  8003a1:	77 55                	ja     8003f8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a6:	eb e9                	jmp    800391 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 40 04             	lea    0x4(%eax),%eax
  8003b6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c0:	79 91                	jns    800353 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003cf:	eb 82                	jmp    800353 <vprintfmt+0x54>
  8003d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d4:	85 d2                	test   %edx,%edx
  8003d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003db:	0f 49 c2             	cmovns %edx,%eax
  8003de:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e4:	e9 6a ff ff ff       	jmp    800353 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ec:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003f3:	e9 5b ff ff ff       	jmp    800353 <vprintfmt+0x54>
  8003f8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fe:	eb bc                	jmp    8003bc <vprintfmt+0xbd>
			lflag++;
  800400:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800406:	e9 48 ff ff ff       	jmp    800353 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 78 04             	lea    0x4(%eax),%edi
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	ff 30                	push   (%eax)
  800417:	ff d6                	call   *%esi
			break;
  800419:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80041f:	e9 9d 02 00 00       	jmp    8006c1 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 78 04             	lea    0x4(%eax),%edi
  80042a:	8b 10                	mov    (%eax),%edx
  80042c:	89 d0                	mov    %edx,%eax
  80042e:	f7 d8                	neg    %eax
  800430:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800433:	83 f8 0f             	cmp    $0xf,%eax
  800436:	7f 23                	jg     80045b <vprintfmt+0x15c>
  800438:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80043f:	85 d2                	test   %edx,%edx
  800441:	74 18                	je     80045b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800443:	52                   	push   %edx
  800444:	68 59 28 80 00       	push   $0x802859
  800449:	53                   	push   %ebx
  80044a:	56                   	push   %esi
  80044b:	e8 92 fe ff ff       	call   8002e2 <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800453:	89 7d 14             	mov    %edi,0x14(%ebp)
  800456:	e9 66 02 00 00       	jmp    8006c1 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80045b:	50                   	push   %eax
  80045c:	68 13 24 80 00       	push   $0x802413
  800461:	53                   	push   %ebx
  800462:	56                   	push   %esi
  800463:	e8 7a fe ff ff       	call   8002e2 <printfmt>
  800468:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046e:	e9 4e 02 00 00       	jmp    8006c1 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	83 c0 04             	add    $0x4,%eax
  800479:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800481:	85 d2                	test   %edx,%edx
  800483:	b8 0c 24 80 00       	mov    $0x80240c,%eax
  800488:	0f 45 c2             	cmovne %edx,%eax
  80048b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80048e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800492:	7e 06                	jle    80049a <vprintfmt+0x19b>
  800494:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800498:	75 0d                	jne    8004a7 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049d:	89 c7                	mov    %eax,%edi
  80049f:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a5:	eb 55                	jmp    8004fc <vprintfmt+0x1fd>
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 d8             	push   -0x28(%ebp)
  8004ad:	ff 75 cc             	push   -0x34(%ebp)
  8004b0:	e8 0a 03 00 00       	call   8007bf <strnlen>
  8004b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b8:	29 c1                	sub    %eax,%ecx
  8004ba:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004c2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	eb 0f                	jmp    8004da <vprintfmt+0x1db>
					putch(padc, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	ff 75 e0             	push   -0x20(%ebp)
  8004d2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	83 ef 01             	sub    $0x1,%edi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	7f ed                	jg     8004cb <vprintfmt+0x1cc>
  8004de:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e8:	0f 49 c2             	cmovns %edx,%eax
  8004eb:	29 c2                	sub    %eax,%edx
  8004ed:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f0:	eb a8                	jmp    80049a <vprintfmt+0x19b>
					putch(ch, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	52                   	push   %edx
  8004f7:	ff d6                	call   *%esi
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ff:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800501:	83 c7 01             	add    $0x1,%edi
  800504:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800508:	0f be d0             	movsbl %al,%edx
  80050b:	85 d2                	test   %edx,%edx
  80050d:	74 4b                	je     80055a <vprintfmt+0x25b>
  80050f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800513:	78 06                	js     80051b <vprintfmt+0x21c>
  800515:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800519:	78 1e                	js     800539 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80051b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051f:	74 d1                	je     8004f2 <vprintfmt+0x1f3>
  800521:	0f be c0             	movsbl %al,%eax
  800524:	83 e8 20             	sub    $0x20,%eax
  800527:	83 f8 5e             	cmp    $0x5e,%eax
  80052a:	76 c6                	jbe    8004f2 <vprintfmt+0x1f3>
					putch('?', putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	53                   	push   %ebx
  800530:	6a 3f                	push   $0x3f
  800532:	ff d6                	call   *%esi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	eb c3                	jmp    8004fc <vprintfmt+0x1fd>
  800539:	89 cf                	mov    %ecx,%edi
  80053b:	eb 0e                	jmp    80054b <vprintfmt+0x24c>
				putch(' ', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	6a 20                	push   $0x20
  800543:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800545:	83 ef 01             	sub    $0x1,%edi
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	85 ff                	test   %edi,%edi
  80054d:	7f ee                	jg     80053d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80054f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800552:	89 45 14             	mov    %eax,0x14(%ebp)
  800555:	e9 67 01 00 00       	jmp    8006c1 <vprintfmt+0x3c2>
  80055a:	89 cf                	mov    %ecx,%edi
  80055c:	eb ed                	jmp    80054b <vprintfmt+0x24c>
	if (lflag >= 2)
  80055e:	83 f9 01             	cmp    $0x1,%ecx
  800561:	7f 1b                	jg     80057e <vprintfmt+0x27f>
	else if (lflag)
  800563:	85 c9                	test   %ecx,%ecx
  800565:	74 63                	je     8005ca <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056f:	99                   	cltd   
  800570:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 40 04             	lea    0x4(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
  80057c:	eb 17                	jmp    800595 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8b 50 04             	mov    0x4(%eax),%edx
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 40 08             	lea    0x8(%eax),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800595:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800598:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80059b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	0f 89 ff 00 00 00    	jns    8006a7 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	6a 2d                	push   $0x2d
  8005ae:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b6:	f7 da                	neg    %edx
  8005b8:	83 d1 00             	adc    $0x0,%ecx
  8005bb:	f7 d9                	neg    %ecx
  8005bd:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c0:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005c5:	e9 dd 00 00 00       	jmp    8006a7 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 00                	mov    (%eax),%eax
  8005cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d2:	99                   	cltd   
  8005d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 40 04             	lea    0x4(%eax),%eax
  8005dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005df:	eb b4                	jmp    800595 <vprintfmt+0x296>
	if (lflag >= 2)
  8005e1:	83 f9 01             	cmp    $0x1,%ecx
  8005e4:	7f 1e                	jg     800604 <vprintfmt+0x305>
	else if (lflag)
  8005e6:	85 c9                	test   %ecx,%ecx
  8005e8:	74 32                	je     80061c <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8b 10                	mov    (%eax),%edx
  8005ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f4:	8d 40 04             	lea    0x4(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fa:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005ff:	e9 a3 00 00 00       	jmp    8006a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	8b 48 04             	mov    0x4(%eax),%ecx
  80060c:	8d 40 08             	lea    0x8(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800612:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800617:	e9 8b 00 00 00       	jmp    8006a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8b 10                	mov    (%eax),%edx
  800621:	b9 00 00 00 00       	mov    $0x0,%ecx
  800626:	8d 40 04             	lea    0x4(%eax),%eax
  800629:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800631:	eb 74                	jmp    8006a7 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800633:	83 f9 01             	cmp    $0x1,%ecx
  800636:	7f 1b                	jg     800653 <vprintfmt+0x354>
	else if (lflag)
  800638:	85 c9                	test   %ecx,%ecx
  80063a:	74 2c                	je     800668 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	b9 00 00 00 00       	mov    $0x0,%ecx
  800646:	8d 40 04             	lea    0x4(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80064c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800651:	eb 54                	jmp    8006a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
  800658:	8b 48 04             	mov    0x4(%eax),%ecx
  80065b:	8d 40 08             	lea    0x8(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800661:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800666:	eb 3f                	jmp    8006a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800678:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80067d:	eb 28                	jmp    8006a7 <vprintfmt+0x3a8>
			putch('0', putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	6a 30                	push   $0x30
  800685:	ff d6                	call   *%esi
			putch('x', putdat);
  800687:	83 c4 08             	add    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 78                	push   $0x78
  80068d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8b 10                	mov    (%eax),%edx
  800694:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800699:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80069c:	8d 40 04             	lea    0x4(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a2:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006a7:	83 ec 0c             	sub    $0xc,%esp
  8006aa:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006ae:	50                   	push   %eax
  8006af:	ff 75 e0             	push   -0x20(%ebp)
  8006b2:	57                   	push   %edi
  8006b3:	51                   	push   %ecx
  8006b4:	52                   	push   %edx
  8006b5:	89 da                	mov    %ebx,%edx
  8006b7:	89 f0                	mov    %esi,%eax
  8006b9:	e8 5e fb ff ff       	call   80021c <printnum>
			break;
  8006be:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c4:	e9 54 fc ff ff       	jmp    80031d <vprintfmt+0x1e>
	if (lflag >= 2)
  8006c9:	83 f9 01             	cmp    $0x1,%ecx
  8006cc:	7f 1b                	jg     8006e9 <vprintfmt+0x3ea>
	else if (lflag)
  8006ce:	85 c9                	test   %ecx,%ecx
  8006d0:	74 2c                	je     8006fe <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 10                	mov    (%eax),%edx
  8006d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dc:	8d 40 04             	lea    0x4(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006e7:	eb be                	jmp    8006a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8b 10                	mov    (%eax),%edx
  8006ee:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f1:	8d 40 08             	lea    0x8(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006fc:	eb a9                	jmp    8006a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	b9 00 00 00 00       	mov    $0x0,%ecx
  800708:	8d 40 04             	lea    0x4(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800713:	eb 92                	jmp    8006a7 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	53                   	push   %ebx
  800719:	6a 25                	push   $0x25
  80071b:	ff d6                	call   *%esi
			break;
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	eb 9f                	jmp    8006c1 <vprintfmt+0x3c2>
			putch('%', putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	53                   	push   %ebx
  800726:	6a 25                	push   $0x25
  800728:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	89 f8                	mov    %edi,%eax
  80072f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800733:	74 05                	je     80073a <vprintfmt+0x43b>
  800735:	83 e8 01             	sub    $0x1,%eax
  800738:	eb f5                	jmp    80072f <vprintfmt+0x430>
  80073a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073d:	eb 82                	jmp    8006c1 <vprintfmt+0x3c2>

0080073f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	83 ec 18             	sub    $0x18,%esp
  800745:	8b 45 08             	mov    0x8(%ebp),%eax
  800748:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800752:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800755:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075c:	85 c0                	test   %eax,%eax
  80075e:	74 26                	je     800786 <vsnprintf+0x47>
  800760:	85 d2                	test   %edx,%edx
  800762:	7e 22                	jle    800786 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800764:	ff 75 14             	push   0x14(%ebp)
  800767:	ff 75 10             	push   0x10(%ebp)
  80076a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076d:	50                   	push   %eax
  80076e:	68 c5 02 80 00       	push   $0x8002c5
  800773:	e8 87 fb ff ff       	call   8002ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800778:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800781:	83 c4 10             	add    $0x10,%esp
}
  800784:	c9                   	leave  
  800785:	c3                   	ret    
		return -E_INVAL;
  800786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078b:	eb f7                	jmp    800784 <vsnprintf+0x45>

0080078d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800796:	50                   	push   %eax
  800797:	ff 75 10             	push   0x10(%ebp)
  80079a:	ff 75 0c             	push   0xc(%ebp)
  80079d:	ff 75 08             	push   0x8(%ebp)
  8007a0:	e8 9a ff ff ff       	call   80073f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b2:	eb 03                	jmp    8007b7 <strlen+0x10>
		n++;
  8007b4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007b7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bb:	75 f7                	jne    8007b4 <strlen+0xd>
	return n;
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cd:	eb 03                	jmp    8007d2 <strnlen+0x13>
		n++;
  8007cf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d2:	39 d0                	cmp    %edx,%eax
  8007d4:	74 08                	je     8007de <strnlen+0x1f>
  8007d6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007da:	75 f3                	jne    8007cf <strnlen+0x10>
  8007dc:	89 c2                	mov    %eax,%edx
	return n;
}
  8007de:	89 d0                	mov    %edx,%eax
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007f5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007f8:	83 c0 01             	add    $0x1,%eax
  8007fb:	84 d2                	test   %dl,%dl
  8007fd:	75 f2                	jne    8007f1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ff:	89 c8                	mov    %ecx,%eax
  800801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	83 ec 10             	sub    $0x10,%esp
  80080d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800810:	53                   	push   %ebx
  800811:	e8 91 ff ff ff       	call   8007a7 <strlen>
  800816:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800819:	ff 75 0c             	push   0xc(%ebp)
  80081c:	01 d8                	add    %ebx,%eax
  80081e:	50                   	push   %eax
  80081f:	e8 be ff ff ff       	call   8007e2 <strcpy>
	return dst;
}
  800824:	89 d8                	mov    %ebx,%eax
  800826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 75 08             	mov    0x8(%ebp),%esi
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
  800836:	89 f3                	mov    %esi,%ebx
  800838:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083b:	89 f0                	mov    %esi,%eax
  80083d:	eb 0f                	jmp    80084e <strncpy+0x23>
		*dst++ = *src;
  80083f:	83 c0 01             	add    $0x1,%eax
  800842:	0f b6 0a             	movzbl (%edx),%ecx
  800845:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800848:	80 f9 01             	cmp    $0x1,%cl
  80084b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80084e:	39 d8                	cmp    %ebx,%eax
  800850:	75 ed                	jne    80083f <strncpy+0x14>
	}
	return ret;
}
  800852:	89 f0                	mov    %esi,%eax
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 75 08             	mov    0x8(%ebp),%esi
  800860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800863:	8b 55 10             	mov    0x10(%ebp),%edx
  800866:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800868:	85 d2                	test   %edx,%edx
  80086a:	74 21                	je     80088d <strlcpy+0x35>
  80086c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800870:	89 f2                	mov    %esi,%edx
  800872:	eb 09                	jmp    80087d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800874:	83 c1 01             	add    $0x1,%ecx
  800877:	83 c2 01             	add    $0x1,%edx
  80087a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80087d:	39 c2                	cmp    %eax,%edx
  80087f:	74 09                	je     80088a <strlcpy+0x32>
  800881:	0f b6 19             	movzbl (%ecx),%ebx
  800884:	84 db                	test   %bl,%bl
  800886:	75 ec                	jne    800874 <strlcpy+0x1c>
  800888:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80088a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088d:	29 f0                	sub    %esi,%eax
}
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089c:	eb 06                	jmp    8008a4 <strcmp+0x11>
		p++, q++;
  80089e:	83 c1 01             	add    $0x1,%ecx
  8008a1:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008a4:	0f b6 01             	movzbl (%ecx),%eax
  8008a7:	84 c0                	test   %al,%al
  8008a9:	74 04                	je     8008af <strcmp+0x1c>
  8008ab:	3a 02                	cmp    (%edx),%al
  8008ad:	74 ef                	je     80089e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 c0             	movzbl %al,%eax
  8008b2:	0f b6 12             	movzbl (%edx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c3:	89 c3                	mov    %eax,%ebx
  8008c5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c8:	eb 06                	jmp    8008d0 <strncmp+0x17>
		n--, p++, q++;
  8008ca:	83 c0 01             	add    $0x1,%eax
  8008cd:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d0:	39 d8                	cmp    %ebx,%eax
  8008d2:	74 18                	je     8008ec <strncmp+0x33>
  8008d4:	0f b6 08             	movzbl (%eax),%ecx
  8008d7:	84 c9                	test   %cl,%cl
  8008d9:	74 04                	je     8008df <strncmp+0x26>
  8008db:	3a 0a                	cmp    (%edx),%cl
  8008dd:	74 eb                	je     8008ca <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008df:	0f b6 00             	movzbl (%eax),%eax
  8008e2:	0f b6 12             	movzbl (%edx),%edx
  8008e5:	29 d0                	sub    %edx,%eax
}
  8008e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    
		return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	eb f4                	jmp    8008e7 <strncmp+0x2e>

008008f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fd:	eb 03                	jmp    800902 <strchr+0xf>
  8008ff:	83 c0 01             	add    $0x1,%eax
  800902:	0f b6 10             	movzbl (%eax),%edx
  800905:	84 d2                	test   %dl,%dl
  800907:	74 06                	je     80090f <strchr+0x1c>
		if (*s == c)
  800909:	38 ca                	cmp    %cl,%dl
  80090b:	75 f2                	jne    8008ff <strchr+0xc>
  80090d:	eb 05                	jmp    800914 <strchr+0x21>
			return (char *) s;
	return 0;
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800920:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800923:	38 ca                	cmp    %cl,%dl
  800925:	74 09                	je     800930 <strfind+0x1a>
  800927:	84 d2                	test   %dl,%dl
  800929:	74 05                	je     800930 <strfind+0x1a>
	for (; *s; s++)
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	eb f0                	jmp    800920 <strfind+0xa>
			break;
	return (char *) s;
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	57                   	push   %edi
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093e:	85 c9                	test   %ecx,%ecx
  800940:	74 2f                	je     800971 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800942:	89 f8                	mov    %edi,%eax
  800944:	09 c8                	or     %ecx,%eax
  800946:	a8 03                	test   $0x3,%al
  800948:	75 21                	jne    80096b <memset+0x39>
		c &= 0xFF;
  80094a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094e:	89 d0                	mov    %edx,%eax
  800950:	c1 e0 08             	shl    $0x8,%eax
  800953:	89 d3                	mov    %edx,%ebx
  800955:	c1 e3 18             	shl    $0x18,%ebx
  800958:	89 d6                	mov    %edx,%esi
  80095a:	c1 e6 10             	shl    $0x10,%esi
  80095d:	09 f3                	or     %esi,%ebx
  80095f:	09 da                	or     %ebx,%edx
  800961:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800963:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800966:	fc                   	cld    
  800967:	f3 ab                	rep stos %eax,%es:(%edi)
  800969:	eb 06                	jmp    800971 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096e:	fc                   	cld    
  80096f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800971:	89 f8                	mov    %edi,%eax
  800973:	5b                   	pop    %ebx
  800974:	5e                   	pop    %esi
  800975:	5f                   	pop    %edi
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	57                   	push   %edi
  80097c:	56                   	push   %esi
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 75 0c             	mov    0xc(%ebp),%esi
  800983:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800986:	39 c6                	cmp    %eax,%esi
  800988:	73 32                	jae    8009bc <memmove+0x44>
  80098a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098d:	39 c2                	cmp    %eax,%edx
  80098f:	76 2b                	jbe    8009bc <memmove+0x44>
		s += n;
		d += n;
  800991:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800994:	89 d6                	mov    %edx,%esi
  800996:	09 fe                	or     %edi,%esi
  800998:	09 ce                	or     %ecx,%esi
  80099a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a0:	75 0e                	jne    8009b0 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a2:	83 ef 04             	sub    $0x4,%edi
  8009a5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ae:	eb 09                	jmp    8009b9 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b0:	83 ef 01             	sub    $0x1,%edi
  8009b3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b6:	fd                   	std    
  8009b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b9:	fc                   	cld    
  8009ba:	eb 1a                	jmp    8009d6 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bc:	89 f2                	mov    %esi,%edx
  8009be:	09 c2                	or     %eax,%edx
  8009c0:	09 ca                	or     %ecx,%edx
  8009c2:	f6 c2 03             	test   $0x3,%dl
  8009c5:	75 0a                	jne    8009d1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ca:	89 c7                	mov    %eax,%edi
  8009cc:	fc                   	cld    
  8009cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cf:	eb 05                	jmp    8009d6 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009d1:	89 c7                	mov    %eax,%edi
  8009d3:	fc                   	cld    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d6:	5e                   	pop    %esi
  8009d7:	5f                   	pop    %edi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e0:	ff 75 10             	push   0x10(%ebp)
  8009e3:	ff 75 0c             	push   0xc(%ebp)
  8009e6:	ff 75 08             	push   0x8(%ebp)
  8009e9:	e8 8a ff ff ff       	call   800978 <memmove>
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fb:	89 c6                	mov    %eax,%esi
  8009fd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a00:	eb 06                	jmp    800a08 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a08:	39 f0                	cmp    %esi,%eax
  800a0a:	74 14                	je     800a20 <memcmp+0x30>
		if (*s1 != *s2)
  800a0c:	0f b6 08             	movzbl (%eax),%ecx
  800a0f:	0f b6 1a             	movzbl (%edx),%ebx
  800a12:	38 d9                	cmp    %bl,%cl
  800a14:	74 ec                	je     800a02 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a16:	0f b6 c1             	movzbl %cl,%eax
  800a19:	0f b6 db             	movzbl %bl,%ebx
  800a1c:	29 d8                	sub    %ebx,%eax
  800a1e:	eb 05                	jmp    800a25 <memcmp+0x35>
	}

	return 0;
  800a20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a32:	89 c2                	mov    %eax,%edx
  800a34:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a37:	eb 03                	jmp    800a3c <memfind+0x13>
  800a39:	83 c0 01             	add    $0x1,%eax
  800a3c:	39 d0                	cmp    %edx,%eax
  800a3e:	73 04                	jae    800a44 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a40:	38 08                	cmp    %cl,(%eax)
  800a42:	75 f5                	jne    800a39 <memfind+0x10>
			break;
	return (void *) s;
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	eb 03                	jmp    800a57 <strtol+0x11>
		s++;
  800a54:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a57:	0f b6 02             	movzbl (%edx),%eax
  800a5a:	3c 20                	cmp    $0x20,%al
  800a5c:	74 f6                	je     800a54 <strtol+0xe>
  800a5e:	3c 09                	cmp    $0x9,%al
  800a60:	74 f2                	je     800a54 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a62:	3c 2b                	cmp    $0x2b,%al
  800a64:	74 2a                	je     800a90 <strtol+0x4a>
	int neg = 0;
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a6b:	3c 2d                	cmp    $0x2d,%al
  800a6d:	74 2b                	je     800a9a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a75:	75 0f                	jne    800a86 <strtol+0x40>
  800a77:	80 3a 30             	cmpb   $0x30,(%edx)
  800a7a:	74 28                	je     800aa4 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a83:	0f 44 d8             	cmove  %eax,%ebx
  800a86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8e:	eb 46                	jmp    800ad6 <strtol+0x90>
		s++;
  800a90:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
  800a98:	eb d5                	jmp    800a6f <strtol+0x29>
		s++, neg = 1;
  800a9a:	83 c2 01             	add    $0x1,%edx
  800a9d:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa2:	eb cb                	jmp    800a6f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa4:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa8:	74 0e                	je     800ab8 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	75 d8                	jne    800a86 <strtol+0x40>
		s++, base = 8;
  800aae:	83 c2 01             	add    $0x1,%edx
  800ab1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab6:	eb ce                	jmp    800a86 <strtol+0x40>
		s += 2, base = 16;
  800ab8:	83 c2 02             	add    $0x2,%edx
  800abb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac0:	eb c4                	jmp    800a86 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ac2:	0f be c0             	movsbl %al,%eax
  800ac5:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac8:	3b 45 10             	cmp    0x10(%ebp),%eax
  800acb:	7d 3a                	jge    800b07 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800acd:	83 c2 01             	add    $0x1,%edx
  800ad0:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ad4:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ad6:	0f b6 02             	movzbl (%edx),%eax
  800ad9:	8d 70 d0             	lea    -0x30(%eax),%esi
  800adc:	89 f3                	mov    %esi,%ebx
  800ade:	80 fb 09             	cmp    $0x9,%bl
  800ae1:	76 df                	jbe    800ac2 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ae3:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ae6:	89 f3                	mov    %esi,%ebx
  800ae8:	80 fb 19             	cmp    $0x19,%bl
  800aeb:	77 08                	ja     800af5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800aed:	0f be c0             	movsbl %al,%eax
  800af0:	83 e8 57             	sub    $0x57,%eax
  800af3:	eb d3                	jmp    800ac8 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800af5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800af8:	89 f3                	mov    %esi,%ebx
  800afa:	80 fb 19             	cmp    $0x19,%bl
  800afd:	77 08                	ja     800b07 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800aff:	0f be c0             	movsbl %al,%eax
  800b02:	83 e8 37             	sub    $0x37,%eax
  800b05:	eb c1                	jmp    800ac8 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0b:	74 05                	je     800b12 <strtol+0xcc>
		*endptr = (char *) s;
  800b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b10:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b12:	89 c8                	mov    %ecx,%eax
  800b14:	f7 d8                	neg    %eax
  800b16:	85 ff                	test   %edi,%edi
  800b18:	0f 45 c8             	cmovne %eax,%ecx
}
  800b1b:	89 c8                	mov    %ecx,%eax
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b33:	89 c3                	mov    %eax,%ebx
  800b35:	89 c7                	mov    %eax,%edi
  800b37:	89 c6                	mov    %eax,%esi
  800b39:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b50:	89 d1                	mov    %edx,%ecx
  800b52:	89 d3                	mov    %edx,%ebx
  800b54:	89 d7                	mov    %edx,%edi
  800b56:	89 d6                	mov    %edx,%esi
  800b58:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	b8 03 00 00 00       	mov    $0x3,%eax
  800b75:	89 cb                	mov    %ecx,%ebx
  800b77:	89 cf                	mov    %ecx,%edi
  800b79:	89 ce                	mov    %ecx,%esi
  800b7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7f 08                	jg     800b89 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	50                   	push   %eax
  800b8d:	6a 03                	push   $0x3
  800b8f:	68 ff 26 80 00       	push   $0x8026ff
  800b94:	6a 2a                	push   $0x2a
  800b96:	68 1c 27 80 00       	push   $0x80271c
  800b9b:	e8 8d f5 ff ff       	call   80012d <_panic>

00800ba0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bab:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb0:	89 d1                	mov    %edx,%ecx
  800bb2:	89 d3                	mov    %edx,%ebx
  800bb4:	89 d7                	mov    %edx,%edi
  800bb6:	89 d6                	mov    %edx,%esi
  800bb8:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_yield>:

void
sys_yield(void)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be7:	be 00 00 00 00       	mov    $0x0,%esi
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfa:	89 f7                	mov    %esi,%edi
  800bfc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7f 08                	jg     800c0a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 04                	push   $0x4
  800c10:	68 ff 26 80 00       	push   $0x8026ff
  800c15:	6a 2a                	push   $0x2a
  800c17:	68 1c 27 80 00       	push   $0x80271c
  800c1c:	e8 0c f5 ff ff       	call   80012d <_panic>

00800c21 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c30:	b8 05 00 00 00       	mov    $0x5,%eax
  800c35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7f 08                	jg     800c4c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 05                	push   $0x5
  800c52:	68 ff 26 80 00       	push   $0x8026ff
  800c57:	6a 2a                	push   $0x2a
  800c59:	68 1c 27 80 00       	push   $0x80271c
  800c5e:	e8 ca f4 ff ff       	call   80012d <_panic>

00800c63 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7c:	89 df                	mov    %ebx,%edi
  800c7e:	89 de                	mov    %ebx,%esi
  800c80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7f 08                	jg     800c8e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 06                	push   $0x6
  800c94:	68 ff 26 80 00       	push   $0x8026ff
  800c99:	6a 2a                	push   $0x2a
  800c9b:	68 1c 27 80 00       	push   $0x80271c
  800ca0:	e8 88 f4 ff ff       	call   80012d <_panic>

00800ca5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbe:	89 df                	mov    %ebx,%edi
  800cc0:	89 de                	mov    %ebx,%esi
  800cc2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7f 08                	jg     800cd0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 08                	push   $0x8
  800cd6:	68 ff 26 80 00       	push   $0x8026ff
  800cdb:	6a 2a                	push   $0x2a
  800cdd:	68 1c 27 80 00       	push   $0x80271c
  800ce2:	e8 46 f4 ff ff       	call   80012d <_panic>

00800ce7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	b8 09 00 00 00       	mov    $0x9,%eax
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7f 08                	jg     800d12 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	50                   	push   %eax
  800d16:	6a 09                	push   $0x9
  800d18:	68 ff 26 80 00       	push   $0x8026ff
  800d1d:	6a 2a                	push   $0x2a
  800d1f:	68 1c 27 80 00       	push   $0x80271c
  800d24:	e8 04 f4 ff ff       	call   80012d <_panic>

00800d29 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d42:	89 df                	mov    %ebx,%edi
  800d44:	89 de                	mov    %ebx,%esi
  800d46:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7f 08                	jg     800d54 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d54:	83 ec 0c             	sub    $0xc,%esp
  800d57:	50                   	push   %eax
  800d58:	6a 0a                	push   $0xa
  800d5a:	68 ff 26 80 00       	push   $0x8026ff
  800d5f:	6a 2a                	push   $0x2a
  800d61:	68 1c 27 80 00       	push   $0x80271c
  800d66:	e8 c2 f3 ff ff       	call   80012d <_panic>

00800d6b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7c:	be 00 00 00 00       	mov    $0x0,%esi
  800d81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d84:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d87:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da4:	89 cb                	mov    %ecx,%ebx
  800da6:	89 cf                	mov    %ecx,%edi
  800da8:	89 ce                	mov    %ecx,%esi
  800daa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7f 08                	jg     800db8 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	50                   	push   %eax
  800dbc:	6a 0d                	push   $0xd
  800dbe:	68 ff 26 80 00       	push   $0x8026ff
  800dc3:	6a 2a                	push   $0x2a
  800dc5:	68 1c 27 80 00       	push   $0x80271c
  800dca:	e8 5e f3 ff ff       	call   80012d <_panic>

00800dcf <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	57                   	push   %edi
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dda:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ddf:	89 d1                	mov    %edx,%ecx
  800de1:	89 d3                	mov    %edx,%ebx
  800de3:	89 d7                	mov    %edx,%edi
  800de5:	89 d6                	mov    %edx,%esi
  800de7:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dff:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e04:	89 df                	mov    %ebx,%edi
  800e06:	89 de                	mov    %ebx,%esi
  800e08:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	b8 10 00 00 00       	mov    $0x10,%eax
  800e25:	89 df                	mov    %ebx,%edi
  800e27:	89 de                	mov    %ebx,%esi
  800e29:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800e36:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e3d:	74 0a                	je     800e49 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e42:	a3 04 40 80 00       	mov    %eax,0x804004
}
  800e47:	c9                   	leave  
  800e48:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800e49:	e8 52 fd ff ff       	call   800ba0 <sys_getenvid>
  800e4e:	83 ec 04             	sub    $0x4,%esp
  800e51:	68 07 0e 00 00       	push   $0xe07
  800e56:	68 00 f0 bf ee       	push   $0xeebff000
  800e5b:	50                   	push   %eax
  800e5c:	e8 7d fd ff ff       	call   800bde <sys_page_alloc>
		if (r < 0) {
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	78 2c                	js     800e94 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800e68:	e8 33 fd ff ff       	call   800ba0 <sys_getenvid>
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	68 a6 0e 80 00       	push   $0x800ea6
  800e75:	50                   	push   %eax
  800e76:	e8 ae fe ff ff       	call   800d29 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800e7b:	83 c4 10             	add    $0x10,%esp
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	79 bd                	jns    800e3f <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800e82:	50                   	push   %eax
  800e83:	68 6c 27 80 00       	push   $0x80276c
  800e88:	6a 28                	push   $0x28
  800e8a:	68 a2 27 80 00       	push   $0x8027a2
  800e8f:	e8 99 f2 ff ff       	call   80012d <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800e94:	50                   	push   %eax
  800e95:	68 2c 27 80 00       	push   $0x80272c
  800e9a:	6a 23                	push   $0x23
  800e9c:	68 a2 27 80 00       	push   $0x8027a2
  800ea1:	e8 87 f2 ff ff       	call   80012d <_panic>

00800ea6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ea6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ea7:	a1 04 40 80 00       	mov    0x804004,%eax
	call *%eax
  800eac:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800eae:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800eb1:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800eb5:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800eb8:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800ebc:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800ec0:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800ec2:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800ec5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800ec6:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800ec9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800eca:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800ecb:	c3                   	ret    

00800ecc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed7:	c1 e8 0c             	shr    $0xc,%eax
}
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ee7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eec:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800efb:	89 c2                	mov    %eax,%edx
  800efd:	c1 ea 16             	shr    $0x16,%edx
  800f00:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f07:	f6 c2 01             	test   $0x1,%dl
  800f0a:	74 29                	je     800f35 <fd_alloc+0x42>
  800f0c:	89 c2                	mov    %eax,%edx
  800f0e:	c1 ea 0c             	shr    $0xc,%edx
  800f11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f18:	f6 c2 01             	test   $0x1,%dl
  800f1b:	74 18                	je     800f35 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f1d:	05 00 10 00 00       	add    $0x1000,%eax
  800f22:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f27:	75 d2                	jne    800efb <fd_alloc+0x8>
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f2e:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f33:	eb 05                	jmp    800f3a <fd_alloc+0x47>
			return 0;
  800f35:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3d:	89 02                	mov    %eax,(%edx)
}
  800f3f:	89 c8                	mov    %ecx,%eax
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f49:	83 f8 1f             	cmp    $0x1f,%eax
  800f4c:	77 30                	ja     800f7e <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f4e:	c1 e0 0c             	shl    $0xc,%eax
  800f51:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f56:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f5c:	f6 c2 01             	test   $0x1,%dl
  800f5f:	74 24                	je     800f85 <fd_lookup+0x42>
  800f61:	89 c2                	mov    %eax,%edx
  800f63:	c1 ea 0c             	shr    $0xc,%edx
  800f66:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6d:	f6 c2 01             	test   $0x1,%dl
  800f70:	74 1a                	je     800f8c <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f75:	89 02                	mov    %eax,(%edx)
	return 0;
  800f77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    
		return -E_INVAL;
  800f7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f83:	eb f7                	jmp    800f7c <fd_lookup+0x39>
		return -E_INVAL;
  800f85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8a:	eb f0                	jmp    800f7c <fd_lookup+0x39>
  800f8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f91:	eb e9                	jmp    800f7c <fd_lookup+0x39>

00800f93 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	53                   	push   %ebx
  800f97:	83 ec 04             	sub    $0x4,%esp
  800f9a:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa2:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800fa7:	39 13                	cmp    %edx,(%ebx)
  800fa9:	74 37                	je     800fe2 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800fab:	83 c0 01             	add    $0x1,%eax
  800fae:	8b 1c 85 2c 28 80 00 	mov    0x80282c(,%eax,4),%ebx
  800fb5:	85 db                	test   %ebx,%ebx
  800fb7:	75 ee                	jne    800fa7 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb9:	a1 00 40 80 00       	mov    0x804000,%eax
  800fbe:	8b 40 58             	mov    0x58(%eax),%eax
  800fc1:	83 ec 04             	sub    $0x4,%esp
  800fc4:	52                   	push   %edx
  800fc5:	50                   	push   %eax
  800fc6:	68 b0 27 80 00       	push   $0x8027b0
  800fcb:	e8 38 f2 ff ff       	call   800208 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800fd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fdb:	89 1a                	mov    %ebx,(%edx)
}
  800fdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    
			return 0;
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe7:	eb ef                	jmp    800fd8 <dev_lookup+0x45>

00800fe9 <fd_close>:
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
  800fef:	83 ec 24             	sub    $0x24,%esp
  800ff2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ffb:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ffc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801002:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801005:	50                   	push   %eax
  801006:	e8 38 ff ff ff       	call   800f43 <fd_lookup>
  80100b:	89 c3                	mov    %eax,%ebx
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 05                	js     801019 <fd_close+0x30>
	    || fd != fd2)
  801014:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801017:	74 16                	je     80102f <fd_close+0x46>
		return (must_exist ? r : 0);
  801019:	89 f8                	mov    %edi,%eax
  80101b:	84 c0                	test   %al,%al
  80101d:	b8 00 00 00 00       	mov    $0x0,%eax
  801022:	0f 44 d8             	cmove  %eax,%ebx
}
  801025:	89 d8                	mov    %ebx,%eax
  801027:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	ff 36                	push   (%esi)
  801038:	e8 56 ff ff ff       	call   800f93 <dev_lookup>
  80103d:	89 c3                	mov    %eax,%ebx
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	78 1a                	js     801060 <fd_close+0x77>
		if (dev->dev_close)
  801046:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801049:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80104c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801051:	85 c0                	test   %eax,%eax
  801053:	74 0b                	je     801060 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	56                   	push   %esi
  801059:	ff d0                	call   *%eax
  80105b:	89 c3                	mov    %eax,%ebx
  80105d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	e8 f8 fb ff ff       	call   800c63 <sys_page_unmap>
	return r;
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	eb b5                	jmp    801025 <fd_close+0x3c>

00801070 <close>:

int
close(int fdnum)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801076:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801079:	50                   	push   %eax
  80107a:	ff 75 08             	push   0x8(%ebp)
  80107d:	e8 c1 fe ff ff       	call   800f43 <fd_lookup>
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	85 c0                	test   %eax,%eax
  801087:	79 02                	jns    80108b <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    
		return fd_close(fd, 1);
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	6a 01                	push   $0x1
  801090:	ff 75 f4             	push   -0xc(%ebp)
  801093:	e8 51 ff ff ff       	call   800fe9 <fd_close>
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	eb ec                	jmp    801089 <close+0x19>

0080109d <close_all>:

void
close_all(void)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	53                   	push   %ebx
  8010ad:	e8 be ff ff ff       	call   801070 <close>
	for (i = 0; i < MAXFD; i++)
  8010b2:	83 c3 01             	add    $0x1,%ebx
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	83 fb 20             	cmp    $0x20,%ebx
  8010bb:	75 ec                	jne    8010a9 <close_all+0xc>
}
  8010bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    

008010c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ce:	50                   	push   %eax
  8010cf:	ff 75 08             	push   0x8(%ebp)
  8010d2:	e8 6c fe ff ff       	call   800f43 <fd_lookup>
  8010d7:	89 c3                	mov    %eax,%ebx
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	78 7f                	js     80115f <dup+0x9d>
		return r;
	close(newfdnum);
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	ff 75 0c             	push   0xc(%ebp)
  8010e6:	e8 85 ff ff ff       	call   801070 <close>

	newfd = INDEX2FD(newfdnum);
  8010eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ee:	c1 e6 0c             	shl    $0xc,%esi
  8010f1:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010fa:	89 3c 24             	mov    %edi,(%esp)
  8010fd:	e8 da fd ff ff       	call   800edc <fd2data>
  801102:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801104:	89 34 24             	mov    %esi,(%esp)
  801107:	e8 d0 fd ff ff       	call   800edc <fd2data>
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801112:	89 d8                	mov    %ebx,%eax
  801114:	c1 e8 16             	shr    $0x16,%eax
  801117:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80111e:	a8 01                	test   $0x1,%al
  801120:	74 11                	je     801133 <dup+0x71>
  801122:	89 d8                	mov    %ebx,%eax
  801124:	c1 e8 0c             	shr    $0xc,%eax
  801127:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80112e:	f6 c2 01             	test   $0x1,%dl
  801131:	75 36                	jne    801169 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801133:	89 f8                	mov    %edi,%eax
  801135:	c1 e8 0c             	shr    $0xc,%eax
  801138:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113f:	83 ec 0c             	sub    $0xc,%esp
  801142:	25 07 0e 00 00       	and    $0xe07,%eax
  801147:	50                   	push   %eax
  801148:	56                   	push   %esi
  801149:	6a 00                	push   $0x0
  80114b:	57                   	push   %edi
  80114c:	6a 00                	push   $0x0
  80114e:	e8 ce fa ff ff       	call   800c21 <sys_page_map>
  801153:	89 c3                	mov    %eax,%ebx
  801155:	83 c4 20             	add    $0x20,%esp
  801158:	85 c0                	test   %eax,%eax
  80115a:	78 33                	js     80118f <dup+0xcd>
		goto err;

	return newfdnum;
  80115c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80115f:	89 d8                	mov    %ebx,%eax
  801161:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801169:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801170:	83 ec 0c             	sub    $0xc,%esp
  801173:	25 07 0e 00 00       	and    $0xe07,%eax
  801178:	50                   	push   %eax
  801179:	ff 75 d4             	push   -0x2c(%ebp)
  80117c:	6a 00                	push   $0x0
  80117e:	53                   	push   %ebx
  80117f:	6a 00                	push   $0x0
  801181:	e8 9b fa ff ff       	call   800c21 <sys_page_map>
  801186:	89 c3                	mov    %eax,%ebx
  801188:	83 c4 20             	add    $0x20,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	79 a4                	jns    801133 <dup+0x71>
	sys_page_unmap(0, newfd);
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	56                   	push   %esi
  801193:	6a 00                	push   $0x0
  801195:	e8 c9 fa ff ff       	call   800c63 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80119a:	83 c4 08             	add    $0x8,%esp
  80119d:	ff 75 d4             	push   -0x2c(%ebp)
  8011a0:	6a 00                	push   $0x0
  8011a2:	e8 bc fa ff ff       	call   800c63 <sys_page_unmap>
	return r;
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	eb b3                	jmp    80115f <dup+0x9d>

008011ac <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	56                   	push   %esi
  8011b0:	53                   	push   %ebx
  8011b1:	83 ec 18             	sub    $0x18,%esp
  8011b4:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ba:	50                   	push   %eax
  8011bb:	56                   	push   %esi
  8011bc:	e8 82 fd ff ff       	call   800f43 <fd_lookup>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 3c                	js     801204 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8011cb:	83 ec 08             	sub    $0x8,%esp
  8011ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d1:	50                   	push   %eax
  8011d2:	ff 33                	push   (%ebx)
  8011d4:	e8 ba fd ff ff       	call   800f93 <dev_lookup>
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 24                	js     801204 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011e0:	8b 43 08             	mov    0x8(%ebx),%eax
  8011e3:	83 e0 03             	and    $0x3,%eax
  8011e6:	83 f8 01             	cmp    $0x1,%eax
  8011e9:	74 20                	je     80120b <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ee:	8b 40 08             	mov    0x8(%eax),%eax
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	74 37                	je     80122c <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	ff 75 10             	push   0x10(%ebp)
  8011fb:	ff 75 0c             	push   0xc(%ebp)
  8011fe:	53                   	push   %ebx
  8011ff:	ff d0                	call   *%eax
  801201:	83 c4 10             	add    $0x10,%esp
}
  801204:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801207:	5b                   	pop    %ebx
  801208:	5e                   	pop    %esi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80120b:	a1 00 40 80 00       	mov    0x804000,%eax
  801210:	8b 40 58             	mov    0x58(%eax),%eax
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	56                   	push   %esi
  801217:	50                   	push   %eax
  801218:	68 f1 27 80 00       	push   $0x8027f1
  80121d:	e8 e6 ef ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122a:	eb d8                	jmp    801204 <read+0x58>
		return -E_NOT_SUPP;
  80122c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801231:	eb d1                	jmp    801204 <read+0x58>

00801233 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
  801239:	83 ec 0c             	sub    $0xc,%esp
  80123c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801242:	bb 00 00 00 00       	mov    $0x0,%ebx
  801247:	eb 02                	jmp    80124b <readn+0x18>
  801249:	01 c3                	add    %eax,%ebx
  80124b:	39 f3                	cmp    %esi,%ebx
  80124d:	73 21                	jae    801270 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124f:	83 ec 04             	sub    $0x4,%esp
  801252:	89 f0                	mov    %esi,%eax
  801254:	29 d8                	sub    %ebx,%eax
  801256:	50                   	push   %eax
  801257:	89 d8                	mov    %ebx,%eax
  801259:	03 45 0c             	add    0xc(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	57                   	push   %edi
  80125e:	e8 49 ff ff ff       	call   8011ac <read>
		if (m < 0)
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 04                	js     80126e <readn+0x3b>
			return m;
		if (m == 0)
  80126a:	75 dd                	jne    801249 <readn+0x16>
  80126c:	eb 02                	jmp    801270 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80126e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801270:	89 d8                	mov    %ebx,%eax
  801272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801275:	5b                   	pop    %ebx
  801276:	5e                   	pop    %esi
  801277:	5f                   	pop    %edi
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	83 ec 18             	sub    $0x18,%esp
  801282:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801285:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801288:	50                   	push   %eax
  801289:	53                   	push   %ebx
  80128a:	e8 b4 fc ff ff       	call   800f43 <fd_lookup>
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	78 37                	js     8012cd <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801296:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	ff 36                	push   (%esi)
  8012a2:	e8 ec fc ff ff       	call   800f93 <dev_lookup>
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 1f                	js     8012cd <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ae:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012b2:	74 20                	je     8012d4 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	74 37                	je     8012f5 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	ff 75 10             	push   0x10(%ebp)
  8012c4:	ff 75 0c             	push   0xc(%ebp)
  8012c7:	56                   	push   %esi
  8012c8:	ff d0                	call   *%eax
  8012ca:	83 c4 10             	add    $0x10,%esp
}
  8012cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d4:	a1 00 40 80 00       	mov    0x804000,%eax
  8012d9:	8b 40 58             	mov    0x58(%eax),%eax
  8012dc:	83 ec 04             	sub    $0x4,%esp
  8012df:	53                   	push   %ebx
  8012e0:	50                   	push   %eax
  8012e1:	68 0d 28 80 00       	push   $0x80280d
  8012e6:	e8 1d ef ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f3:	eb d8                	jmp    8012cd <write+0x53>
		return -E_NOT_SUPP;
  8012f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012fa:	eb d1                	jmp    8012cd <write+0x53>

008012fc <seek>:

int
seek(int fdnum, off_t offset)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801302:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	ff 75 08             	push   0x8(%ebp)
  801309:	e8 35 fc ff ff       	call   800f43 <fd_lookup>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 0e                	js     801323 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801315:	8b 55 0c             	mov    0xc(%ebp),%edx
  801318:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80131e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801323:	c9                   	leave  
  801324:	c3                   	ret    

00801325 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	56                   	push   %esi
  801329:	53                   	push   %ebx
  80132a:	83 ec 18             	sub    $0x18,%esp
  80132d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801330:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801333:	50                   	push   %eax
  801334:	53                   	push   %ebx
  801335:	e8 09 fc ff ff       	call   800f43 <fd_lookup>
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 34                	js     801375 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801341:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134a:	50                   	push   %eax
  80134b:	ff 36                	push   (%esi)
  80134d:	e8 41 fc ff ff       	call   800f93 <dev_lookup>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 1c                	js     801375 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801359:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80135d:	74 1d                	je     80137c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80135f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801362:	8b 40 18             	mov    0x18(%eax),%eax
  801365:	85 c0                	test   %eax,%eax
  801367:	74 34                	je     80139d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	ff 75 0c             	push   0xc(%ebp)
  80136f:	56                   	push   %esi
  801370:	ff d0                	call   *%eax
  801372:	83 c4 10             	add    $0x10,%esp
}
  801375:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80137c:	a1 00 40 80 00       	mov    0x804000,%eax
  801381:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801384:	83 ec 04             	sub    $0x4,%esp
  801387:	53                   	push   %ebx
  801388:	50                   	push   %eax
  801389:	68 d0 27 80 00       	push   $0x8027d0
  80138e:	e8 75 ee ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139b:	eb d8                	jmp    801375 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80139d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a2:	eb d1                	jmp    801375 <ftruncate+0x50>

008013a4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	56                   	push   %esi
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 18             	sub    $0x18,%esp
  8013ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b2:	50                   	push   %eax
  8013b3:	ff 75 08             	push   0x8(%ebp)
  8013b6:	e8 88 fb ff ff       	call   800f43 <fd_lookup>
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 49                	js     80140b <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	ff 36                	push   (%esi)
  8013ce:	e8 c0 fb ff ff       	call   800f93 <dev_lookup>
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 31                	js     80140b <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013dd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e1:	74 2f                	je     801412 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ed:	00 00 00 
	stat->st_isdir = 0;
  8013f0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f7:	00 00 00 
	stat->st_dev = dev;
  8013fa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	53                   	push   %ebx
  801404:	56                   	push   %esi
  801405:	ff 50 14             	call   *0x14(%eax)
  801408:	83 c4 10             	add    $0x10,%esp
}
  80140b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140e:	5b                   	pop    %ebx
  80140f:	5e                   	pop    %esi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    
		return -E_NOT_SUPP;
  801412:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801417:	eb f2                	jmp    80140b <fstat+0x67>

00801419 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	56                   	push   %esi
  80141d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80141e:	83 ec 08             	sub    $0x8,%esp
  801421:	6a 00                	push   $0x0
  801423:	ff 75 08             	push   0x8(%ebp)
  801426:	e8 e4 01 00 00       	call   80160f <open>
  80142b:	89 c3                	mov    %eax,%ebx
  80142d:	83 c4 10             	add    $0x10,%esp
  801430:	85 c0                	test   %eax,%eax
  801432:	78 1b                	js     80144f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	ff 75 0c             	push   0xc(%ebp)
  80143a:	50                   	push   %eax
  80143b:	e8 64 ff ff ff       	call   8013a4 <fstat>
  801440:	89 c6                	mov    %eax,%esi
	close(fd);
  801442:	89 1c 24             	mov    %ebx,(%esp)
  801445:	e8 26 fc ff ff       	call   801070 <close>
	return r;
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	89 f3                	mov    %esi,%ebx
}
  80144f:	89 d8                	mov    %ebx,%eax
  801451:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	56                   	push   %esi
  80145c:	53                   	push   %ebx
  80145d:	89 c6                	mov    %eax,%esi
  80145f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801461:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801468:	74 27                	je     801491 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80146a:	6a 07                	push   $0x7
  80146c:	68 00 50 80 00       	push   $0x805000
  801471:	56                   	push   %esi
  801472:	ff 35 00 60 80 00    	push   0x806000
  801478:	e8 cd 0b 00 00       	call   80204a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80147d:	83 c4 0c             	add    $0xc,%esp
  801480:	6a 00                	push   $0x0
  801482:	53                   	push   %ebx
  801483:	6a 00                	push   $0x0
  801485:	e8 50 0b 00 00       	call   801fda <ipc_recv>
}
  80148a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5e                   	pop    %esi
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801491:	83 ec 0c             	sub    $0xc,%esp
  801494:	6a 01                	push   $0x1
  801496:	e8 03 0c 00 00       	call   80209e <ipc_find_env>
  80149b:	a3 00 60 80 00       	mov    %eax,0x806000
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	eb c5                	jmp    80146a <fsipc+0x12>

008014a5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014be:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c3:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c8:	e8 8b ff ff ff       	call   801458 <fsipc>
}
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <devfile_flush>:
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014db:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8014ea:	e8 69 ff ff ff       	call   801458 <fsipc>
}
  8014ef:	c9                   	leave  
  8014f0:	c3                   	ret    

008014f1 <devfile_stat>:
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 04             	sub    $0x4,%esp
  8014f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801501:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801506:	ba 00 00 00 00       	mov    $0x0,%edx
  80150b:	b8 05 00 00 00       	mov    $0x5,%eax
  801510:	e8 43 ff ff ff       	call   801458 <fsipc>
  801515:	85 c0                	test   %eax,%eax
  801517:	78 2c                	js     801545 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	68 00 50 80 00       	push   $0x805000
  801521:	53                   	push   %ebx
  801522:	e8 bb f2 ff ff       	call   8007e2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801527:	a1 80 50 80 00       	mov    0x805080,%eax
  80152c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801532:	a1 84 50 80 00       	mov    0x805084,%eax
  801537:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801545:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <devfile_write>:
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	8b 45 10             	mov    0x10(%ebp),%eax
  801553:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801558:	39 d0                	cmp    %edx,%eax
  80155a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80155d:	8b 55 08             	mov    0x8(%ebp),%edx
  801560:	8b 52 0c             	mov    0xc(%edx),%edx
  801563:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801569:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80156e:	50                   	push   %eax
  80156f:	ff 75 0c             	push   0xc(%ebp)
  801572:	68 08 50 80 00       	push   $0x805008
  801577:	e8 fc f3 ff ff       	call   800978 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80157c:	ba 00 00 00 00       	mov    $0x0,%edx
  801581:	b8 04 00 00 00       	mov    $0x4,%eax
  801586:	e8 cd fe ff ff       	call   801458 <fsipc>
}
  80158b:	c9                   	leave  
  80158c:	c3                   	ret    

0080158d <devfile_read>:
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	56                   	push   %esi
  801591:	53                   	push   %ebx
  801592:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801595:	8b 45 08             	mov    0x8(%ebp),%eax
  801598:	8b 40 0c             	mov    0xc(%eax),%eax
  80159b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015a0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ab:	b8 03 00 00 00       	mov    $0x3,%eax
  8015b0:	e8 a3 fe ff ff       	call   801458 <fsipc>
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 1f                	js     8015da <devfile_read+0x4d>
	assert(r <= n);
  8015bb:	39 f0                	cmp    %esi,%eax
  8015bd:	77 24                	ja     8015e3 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8015bf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015c4:	7f 33                	jg     8015f9 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c6:	83 ec 04             	sub    $0x4,%esp
  8015c9:	50                   	push   %eax
  8015ca:	68 00 50 80 00       	push   $0x805000
  8015cf:	ff 75 0c             	push   0xc(%ebp)
  8015d2:	e8 a1 f3 ff ff       	call   800978 <memmove>
	return r;
  8015d7:	83 c4 10             	add    $0x10,%esp
}
  8015da:	89 d8                	mov    %ebx,%eax
  8015dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015df:	5b                   	pop    %ebx
  8015e0:	5e                   	pop    %esi
  8015e1:	5d                   	pop    %ebp
  8015e2:	c3                   	ret    
	assert(r <= n);
  8015e3:	68 40 28 80 00       	push   $0x802840
  8015e8:	68 47 28 80 00       	push   $0x802847
  8015ed:	6a 7c                	push   $0x7c
  8015ef:	68 5c 28 80 00       	push   $0x80285c
  8015f4:	e8 34 eb ff ff       	call   80012d <_panic>
	assert(r <= PGSIZE);
  8015f9:	68 67 28 80 00       	push   $0x802867
  8015fe:	68 47 28 80 00       	push   $0x802847
  801603:	6a 7d                	push   $0x7d
  801605:	68 5c 28 80 00       	push   $0x80285c
  80160a:	e8 1e eb ff ff       	call   80012d <_panic>

0080160f <open>:
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 1c             	sub    $0x1c,%esp
  801617:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80161a:	56                   	push   %esi
  80161b:	e8 87 f1 ff ff       	call   8007a7 <strlen>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801628:	7f 6c                	jg     801696 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80162a:	83 ec 0c             	sub    $0xc,%esp
  80162d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	e8 bd f8 ff ff       	call   800ef3 <fd_alloc>
  801636:	89 c3                	mov    %eax,%ebx
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 3c                	js     80167b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	56                   	push   %esi
  801643:	68 00 50 80 00       	push   $0x805000
  801648:	e8 95 f1 ff ff       	call   8007e2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80164d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801650:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801655:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801658:	b8 01 00 00 00       	mov    $0x1,%eax
  80165d:	e8 f6 fd ff ff       	call   801458 <fsipc>
  801662:	89 c3                	mov    %eax,%ebx
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	85 c0                	test   %eax,%eax
  801669:	78 19                	js     801684 <open+0x75>
	return fd2num(fd);
  80166b:	83 ec 0c             	sub    $0xc,%esp
  80166e:	ff 75 f4             	push   -0xc(%ebp)
  801671:	e8 56 f8 ff ff       	call   800ecc <fd2num>
  801676:	89 c3                	mov    %eax,%ebx
  801678:	83 c4 10             	add    $0x10,%esp
}
  80167b:	89 d8                	mov    %ebx,%eax
  80167d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801680:	5b                   	pop    %ebx
  801681:	5e                   	pop    %esi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    
		fd_close(fd, 0);
  801684:	83 ec 08             	sub    $0x8,%esp
  801687:	6a 00                	push   $0x0
  801689:	ff 75 f4             	push   -0xc(%ebp)
  80168c:	e8 58 f9 ff ff       	call   800fe9 <fd_close>
		return r;
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	eb e5                	jmp    80167b <open+0x6c>
		return -E_BAD_PATH;
  801696:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80169b:	eb de                	jmp    80167b <open+0x6c>

0080169d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ad:	e8 a6 fd ff ff       	call   801458 <fsipc>
}
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016ba:	68 73 28 80 00       	push   $0x802873
  8016bf:	ff 75 0c             	push   0xc(%ebp)
  8016c2:	e8 1b f1 ff ff       	call   8007e2 <strcpy>
	return 0;
}
  8016c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <devsock_close>:
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	53                   	push   %ebx
  8016d2:	83 ec 10             	sub    $0x10,%esp
  8016d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016d8:	53                   	push   %ebx
  8016d9:	e8 ff 09 00 00       	call   8020dd <pageref>
  8016de:	89 c2                	mov    %eax,%edx
  8016e0:	83 c4 10             	add    $0x10,%esp
		return 0;
  8016e3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8016e8:	83 fa 01             	cmp    $0x1,%edx
  8016eb:	74 05                	je     8016f2 <devsock_close+0x24>
}
  8016ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8016f2:	83 ec 0c             	sub    $0xc,%esp
  8016f5:	ff 73 0c             	push   0xc(%ebx)
  8016f8:	e8 b7 02 00 00       	call   8019b4 <nsipc_close>
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	eb eb                	jmp    8016ed <devsock_close+0x1f>

00801702 <devsock_write>:
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801708:	6a 00                	push   $0x0
  80170a:	ff 75 10             	push   0x10(%ebp)
  80170d:	ff 75 0c             	push   0xc(%ebp)
  801710:	8b 45 08             	mov    0x8(%ebp),%eax
  801713:	ff 70 0c             	push   0xc(%eax)
  801716:	e8 79 03 00 00       	call   801a94 <nsipc_send>
}
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <devsock_read>:
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801723:	6a 00                	push   $0x0
  801725:	ff 75 10             	push   0x10(%ebp)
  801728:	ff 75 0c             	push   0xc(%ebp)
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	ff 70 0c             	push   0xc(%eax)
  801731:	e8 ef 02 00 00       	call   801a25 <nsipc_recv>
}
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <fd2sockid>:
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80173e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801741:	52                   	push   %edx
  801742:	50                   	push   %eax
  801743:	e8 fb f7 ff ff       	call   800f43 <fd_lookup>
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 10                	js     80175f <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801752:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801758:	39 08                	cmp    %ecx,(%eax)
  80175a:	75 05                	jne    801761 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80175c:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80175f:	c9                   	leave  
  801760:	c3                   	ret    
		return -E_NOT_SUPP;
  801761:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801766:	eb f7                	jmp    80175f <fd2sockid+0x27>

00801768 <alloc_sockfd>:
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	56                   	push   %esi
  80176c:	53                   	push   %ebx
  80176d:	83 ec 1c             	sub    $0x1c,%esp
  801770:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801772:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801775:	50                   	push   %eax
  801776:	e8 78 f7 ff ff       	call   800ef3 <fd_alloc>
  80177b:	89 c3                	mov    %eax,%ebx
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	85 c0                	test   %eax,%eax
  801782:	78 43                	js     8017c7 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801784:	83 ec 04             	sub    $0x4,%esp
  801787:	68 07 04 00 00       	push   $0x407
  80178c:	ff 75 f4             	push   -0xc(%ebp)
  80178f:	6a 00                	push   $0x0
  801791:	e8 48 f4 ff ff       	call   800bde <sys_page_alloc>
  801796:	89 c3                	mov    %eax,%ebx
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 28                	js     8017c7 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ad:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017b4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017b7:	83 ec 0c             	sub    $0xc,%esp
  8017ba:	50                   	push   %eax
  8017bb:	e8 0c f7 ff ff       	call   800ecc <fd2num>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	eb 0c                	jmp    8017d3 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8017c7:	83 ec 0c             	sub    $0xc,%esp
  8017ca:	56                   	push   %esi
  8017cb:	e8 e4 01 00 00       	call   8019b4 <nsipc_close>
		return r;
  8017d0:	83 c4 10             	add    $0x10,%esp
}
  8017d3:	89 d8                	mov    %ebx,%eax
  8017d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5e                   	pop    %esi
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <accept>:
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	e8 4e ff ff ff       	call   801738 <fd2sockid>
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 1b                	js     801809 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017ee:	83 ec 04             	sub    $0x4,%esp
  8017f1:	ff 75 10             	push   0x10(%ebp)
  8017f4:	ff 75 0c             	push   0xc(%ebp)
  8017f7:	50                   	push   %eax
  8017f8:	e8 0e 01 00 00       	call   80190b <nsipc_accept>
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	85 c0                	test   %eax,%eax
  801802:	78 05                	js     801809 <accept+0x2d>
	return alloc_sockfd(r);
  801804:	e8 5f ff ff ff       	call   801768 <alloc_sockfd>
}
  801809:	c9                   	leave  
  80180a:	c3                   	ret    

0080180b <bind>:
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	e8 1f ff ff ff       	call   801738 <fd2sockid>
  801819:	85 c0                	test   %eax,%eax
  80181b:	78 12                	js     80182f <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80181d:	83 ec 04             	sub    $0x4,%esp
  801820:	ff 75 10             	push   0x10(%ebp)
  801823:	ff 75 0c             	push   0xc(%ebp)
  801826:	50                   	push   %eax
  801827:	e8 31 01 00 00       	call   80195d <nsipc_bind>
  80182c:	83 c4 10             	add    $0x10,%esp
}
  80182f:	c9                   	leave  
  801830:	c3                   	ret    

00801831 <shutdown>:
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	e8 f9 fe ff ff       	call   801738 <fd2sockid>
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 0f                	js     801852 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	ff 75 0c             	push   0xc(%ebp)
  801849:	50                   	push   %eax
  80184a:	e8 43 01 00 00       	call   801992 <nsipc_shutdown>
  80184f:	83 c4 10             	add    $0x10,%esp
}
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <connect>:
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	e8 d6 fe ff ff       	call   801738 <fd2sockid>
  801862:	85 c0                	test   %eax,%eax
  801864:	78 12                	js     801878 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801866:	83 ec 04             	sub    $0x4,%esp
  801869:	ff 75 10             	push   0x10(%ebp)
  80186c:	ff 75 0c             	push   0xc(%ebp)
  80186f:	50                   	push   %eax
  801870:	e8 59 01 00 00       	call   8019ce <nsipc_connect>
  801875:	83 c4 10             	add    $0x10,%esp
}
  801878:	c9                   	leave  
  801879:	c3                   	ret    

0080187a <listen>:
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	e8 b0 fe ff ff       	call   801738 <fd2sockid>
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 0f                	js     80189b <listen+0x21>
	return nsipc_listen(r, backlog);
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	ff 75 0c             	push   0xc(%ebp)
  801892:	50                   	push   %eax
  801893:	e8 6b 01 00 00       	call   801a03 <nsipc_listen>
  801898:	83 c4 10             	add    $0x10,%esp
}
  80189b:	c9                   	leave  
  80189c:	c3                   	ret    

0080189d <socket>:

int
socket(int domain, int type, int protocol)
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018a3:	ff 75 10             	push   0x10(%ebp)
  8018a6:	ff 75 0c             	push   0xc(%ebp)
  8018a9:	ff 75 08             	push   0x8(%ebp)
  8018ac:	e8 41 02 00 00       	call   801af2 <nsipc_socket>
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 05                	js     8018bd <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018b8:	e8 ab fe ff ff       	call   801768 <alloc_sockfd>
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 04             	sub    $0x4,%esp
  8018c6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018c8:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8018cf:	74 26                	je     8018f7 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018d1:	6a 07                	push   $0x7
  8018d3:	68 00 70 80 00       	push   $0x807000
  8018d8:	53                   	push   %ebx
  8018d9:	ff 35 00 80 80 00    	push   0x808000
  8018df:	e8 66 07 00 00       	call   80204a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018e4:	83 c4 0c             	add    $0xc,%esp
  8018e7:	6a 00                	push   $0x0
  8018e9:	6a 00                	push   $0x0
  8018eb:	6a 00                	push   $0x0
  8018ed:	e8 e8 06 00 00       	call   801fda <ipc_recv>
}
  8018f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	6a 02                	push   $0x2
  8018fc:	e8 9d 07 00 00       	call   80209e <ipc_find_env>
  801901:	a3 00 80 80 00       	mov    %eax,0x808000
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	eb c6                	jmp    8018d1 <nsipc+0x12>

0080190b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
  801910:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80191b:	8b 06                	mov    (%esi),%eax
  80191d:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801922:	b8 01 00 00 00       	mov    $0x1,%eax
  801927:	e8 93 ff ff ff       	call   8018bf <nsipc>
  80192c:	89 c3                	mov    %eax,%ebx
  80192e:	85 c0                	test   %eax,%eax
  801930:	79 09                	jns    80193b <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801932:	89 d8                	mov    %ebx,%eax
  801934:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801937:	5b                   	pop    %ebx
  801938:	5e                   	pop    %esi
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80193b:	83 ec 04             	sub    $0x4,%esp
  80193e:	ff 35 10 70 80 00    	push   0x807010
  801944:	68 00 70 80 00       	push   $0x807000
  801949:	ff 75 0c             	push   0xc(%ebp)
  80194c:	e8 27 f0 ff ff       	call   800978 <memmove>
		*addrlen = ret->ret_addrlen;
  801951:	a1 10 70 80 00       	mov    0x807010,%eax
  801956:	89 06                	mov    %eax,(%esi)
  801958:	83 c4 10             	add    $0x10,%esp
	return r;
  80195b:	eb d5                	jmp    801932 <nsipc_accept+0x27>

0080195d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	53                   	push   %ebx
  801961:	83 ec 08             	sub    $0x8,%esp
  801964:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801967:	8b 45 08             	mov    0x8(%ebp),%eax
  80196a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80196f:	53                   	push   %ebx
  801970:	ff 75 0c             	push   0xc(%ebp)
  801973:	68 04 70 80 00       	push   $0x807004
  801978:	e8 fb ef ff ff       	call   800978 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80197d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801983:	b8 02 00 00 00       	mov    $0x2,%eax
  801988:	e8 32 ff ff ff       	call   8018bf <nsipc>
}
  80198d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801998:	8b 45 08             	mov    0x8(%ebp),%eax
  80199b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8019a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8019a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ad:	e8 0d ff ff ff       	call   8018bf <nsipc>
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <nsipc_close>:

int
nsipc_close(int s)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8019c2:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c7:	e8 f3 fe ff ff       	call   8018bf <nsipc>
}
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 08             	sub    $0x8,%esp
  8019d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019db:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019e0:	53                   	push   %ebx
  8019e1:	ff 75 0c             	push   0xc(%ebp)
  8019e4:	68 04 70 80 00       	push   $0x807004
  8019e9:	e8 8a ef ff ff       	call   800978 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019ee:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8019f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8019f9:	e8 c1 fe ff ff       	call   8018bf <nsipc>
}
  8019fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a14:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801a19:	b8 06 00 00 00       	mov    $0x6,%eax
  801a1e:	e8 9c fe ff ff       	call   8018bf <nsipc>
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	56                   	push   %esi
  801a29:	53                   	push   %ebx
  801a2a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a30:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801a35:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801a3b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3e:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a43:	b8 07 00 00 00       	mov    $0x7,%eax
  801a48:	e8 72 fe ff ff       	call   8018bf <nsipc>
  801a4d:	89 c3                	mov    %eax,%ebx
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	78 22                	js     801a75 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801a53:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801a58:	39 c6                	cmp    %eax,%esi
  801a5a:	0f 4e c6             	cmovle %esi,%eax
  801a5d:	39 c3                	cmp    %eax,%ebx
  801a5f:	7f 1d                	jg     801a7e <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a61:	83 ec 04             	sub    $0x4,%esp
  801a64:	53                   	push   %ebx
  801a65:	68 00 70 80 00       	push   $0x807000
  801a6a:	ff 75 0c             	push   0xc(%ebp)
  801a6d:	e8 06 ef ff ff       	call   800978 <memmove>
  801a72:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a75:	89 d8                	mov    %ebx,%eax
  801a77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801a7e:	68 7f 28 80 00       	push   $0x80287f
  801a83:	68 47 28 80 00       	push   $0x802847
  801a88:	6a 62                	push   $0x62
  801a8a:	68 94 28 80 00       	push   $0x802894
  801a8f:	e8 99 e6 ff ff       	call   80012d <_panic>

00801a94 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	53                   	push   %ebx
  801a98:	83 ec 04             	sub    $0x4,%esp
  801a9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801aa6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801aac:	7f 2e                	jg     801adc <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801aae:	83 ec 04             	sub    $0x4,%esp
  801ab1:	53                   	push   %ebx
  801ab2:	ff 75 0c             	push   0xc(%ebp)
  801ab5:	68 0c 70 80 00       	push   $0x80700c
  801aba:	e8 b9 ee ff ff       	call   800978 <memmove>
	nsipcbuf.send.req_size = size;
  801abf:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801ac5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801acd:	b8 08 00 00 00       	mov    $0x8,%eax
  801ad2:	e8 e8 fd ff ff       	call   8018bf <nsipc>
}
  801ad7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    
	assert(size < 1600);
  801adc:	68 a0 28 80 00       	push   $0x8028a0
  801ae1:	68 47 28 80 00       	push   $0x802847
  801ae6:	6a 6d                	push   $0x6d
  801ae8:	68 94 28 80 00       	push   $0x802894
  801aed:	e8 3b e6 ff ff       	call   80012d <_panic>

00801af2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b03:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801b08:	8b 45 10             	mov    0x10(%ebp),%eax
  801b0b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801b10:	b8 09 00 00 00       	mov    $0x9,%eax
  801b15:	e8 a5 fd ff ff       	call   8018bf <nsipc>
}
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	56                   	push   %esi
  801b20:	53                   	push   %ebx
  801b21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	ff 75 08             	push   0x8(%ebp)
  801b2a:	e8 ad f3 ff ff       	call   800edc <fd2data>
  801b2f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b31:	83 c4 08             	add    $0x8,%esp
  801b34:	68 ac 28 80 00       	push   $0x8028ac
  801b39:	53                   	push   %ebx
  801b3a:	e8 a3 ec ff ff       	call   8007e2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b3f:	8b 46 04             	mov    0x4(%esi),%eax
  801b42:	2b 06                	sub    (%esi),%eax
  801b44:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b4a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b51:	00 00 00 
	stat->st_dev = &devpipe;
  801b54:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b5b:	30 80 00 
	return 0;
}
  801b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b66:	5b                   	pop    %ebx
  801b67:	5e                   	pop    %esi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	53                   	push   %ebx
  801b6e:	83 ec 0c             	sub    $0xc,%esp
  801b71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b74:	53                   	push   %ebx
  801b75:	6a 00                	push   $0x0
  801b77:	e8 e7 f0 ff ff       	call   800c63 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b7c:	89 1c 24             	mov    %ebx,(%esp)
  801b7f:	e8 58 f3 ff ff       	call   800edc <fd2data>
  801b84:	83 c4 08             	add    $0x8,%esp
  801b87:	50                   	push   %eax
  801b88:	6a 00                	push   $0x0
  801b8a:	e8 d4 f0 ff ff       	call   800c63 <sys_page_unmap>
}
  801b8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <_pipeisclosed>:
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	57                   	push   %edi
  801b98:	56                   	push   %esi
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 1c             	sub    $0x1c,%esp
  801b9d:	89 c7                	mov    %eax,%edi
  801b9f:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ba1:	a1 00 40 80 00       	mov    0x804000,%eax
  801ba6:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ba9:	83 ec 0c             	sub    $0xc,%esp
  801bac:	57                   	push   %edi
  801bad:	e8 2b 05 00 00       	call   8020dd <pageref>
  801bb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bb5:	89 34 24             	mov    %esi,(%esp)
  801bb8:	e8 20 05 00 00       	call   8020dd <pageref>
		nn = thisenv->env_runs;
  801bbd:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801bc3:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	39 cb                	cmp    %ecx,%ebx
  801bcb:	74 1b                	je     801be8 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bcd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bd0:	75 cf                	jne    801ba1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bd2:	8b 42 68             	mov    0x68(%edx),%eax
  801bd5:	6a 01                	push   $0x1
  801bd7:	50                   	push   %eax
  801bd8:	53                   	push   %ebx
  801bd9:	68 b3 28 80 00       	push   $0x8028b3
  801bde:	e8 25 e6 ff ff       	call   800208 <cprintf>
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	eb b9                	jmp    801ba1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801be8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801beb:	0f 94 c0             	sete   %al
  801bee:	0f b6 c0             	movzbl %al,%eax
}
  801bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5f                   	pop    %edi
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    

00801bf9 <devpipe_write>:
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	57                   	push   %edi
  801bfd:	56                   	push   %esi
  801bfe:	53                   	push   %ebx
  801bff:	83 ec 28             	sub    $0x28,%esp
  801c02:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c05:	56                   	push   %esi
  801c06:	e8 d1 f2 ff ff       	call   800edc <fd2data>
  801c0b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	bf 00 00 00 00       	mov    $0x0,%edi
  801c15:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c18:	75 09                	jne    801c23 <devpipe_write+0x2a>
	return i;
  801c1a:	89 f8                	mov    %edi,%eax
  801c1c:	eb 23                	jmp    801c41 <devpipe_write+0x48>
			sys_yield();
  801c1e:	e8 9c ef ff ff       	call   800bbf <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c23:	8b 43 04             	mov    0x4(%ebx),%eax
  801c26:	8b 0b                	mov    (%ebx),%ecx
  801c28:	8d 51 20             	lea    0x20(%ecx),%edx
  801c2b:	39 d0                	cmp    %edx,%eax
  801c2d:	72 1a                	jb     801c49 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801c2f:	89 da                	mov    %ebx,%edx
  801c31:	89 f0                	mov    %esi,%eax
  801c33:	e8 5c ff ff ff       	call   801b94 <_pipeisclosed>
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	74 e2                	je     801c1e <devpipe_write+0x25>
				return 0;
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5e                   	pop    %esi
  801c46:	5f                   	pop    %edi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c50:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c53:	89 c2                	mov    %eax,%edx
  801c55:	c1 fa 1f             	sar    $0x1f,%edx
  801c58:	89 d1                	mov    %edx,%ecx
  801c5a:	c1 e9 1b             	shr    $0x1b,%ecx
  801c5d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c60:	83 e2 1f             	and    $0x1f,%edx
  801c63:	29 ca                	sub    %ecx,%edx
  801c65:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c69:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c6d:	83 c0 01             	add    $0x1,%eax
  801c70:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c73:	83 c7 01             	add    $0x1,%edi
  801c76:	eb 9d                	jmp    801c15 <devpipe_write+0x1c>

00801c78 <devpipe_read>:
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	57                   	push   %edi
  801c7c:	56                   	push   %esi
  801c7d:	53                   	push   %ebx
  801c7e:	83 ec 18             	sub    $0x18,%esp
  801c81:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c84:	57                   	push   %edi
  801c85:	e8 52 f2 ff ff       	call   800edc <fd2data>
  801c8a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	be 00 00 00 00       	mov    $0x0,%esi
  801c94:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c97:	75 13                	jne    801cac <devpipe_read+0x34>
	return i;
  801c99:	89 f0                	mov    %esi,%eax
  801c9b:	eb 02                	jmp    801c9f <devpipe_read+0x27>
				return i;
  801c9d:	89 f0                	mov    %esi,%eax
}
  801c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    
			sys_yield();
  801ca7:	e8 13 ef ff ff       	call   800bbf <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801cac:	8b 03                	mov    (%ebx),%eax
  801cae:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cb1:	75 18                	jne    801ccb <devpipe_read+0x53>
			if (i > 0)
  801cb3:	85 f6                	test   %esi,%esi
  801cb5:	75 e6                	jne    801c9d <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801cb7:	89 da                	mov    %ebx,%edx
  801cb9:	89 f8                	mov    %edi,%eax
  801cbb:	e8 d4 fe ff ff       	call   801b94 <_pipeisclosed>
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	74 e3                	je     801ca7 <devpipe_read+0x2f>
				return 0;
  801cc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc9:	eb d4                	jmp    801c9f <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ccb:	99                   	cltd   
  801ccc:	c1 ea 1b             	shr    $0x1b,%edx
  801ccf:	01 d0                	add    %edx,%eax
  801cd1:	83 e0 1f             	and    $0x1f,%eax
  801cd4:	29 d0                	sub    %edx,%eax
  801cd6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cde:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ce1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ce4:	83 c6 01             	add    $0x1,%esi
  801ce7:	eb ab                	jmp    801c94 <devpipe_read+0x1c>

00801ce9 <pipe>:
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	56                   	push   %esi
  801ced:	53                   	push   %ebx
  801cee:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801cf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf4:	50                   	push   %eax
  801cf5:	e8 f9 f1 ff ff       	call   800ef3 <fd_alloc>
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	85 c0                	test   %eax,%eax
  801d01:	0f 88 23 01 00 00    	js     801e2a <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d07:	83 ec 04             	sub    $0x4,%esp
  801d0a:	68 07 04 00 00       	push   $0x407
  801d0f:	ff 75 f4             	push   -0xc(%ebp)
  801d12:	6a 00                	push   $0x0
  801d14:	e8 c5 ee ff ff       	call   800bde <sys_page_alloc>
  801d19:	89 c3                	mov    %eax,%ebx
  801d1b:	83 c4 10             	add    $0x10,%esp
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	0f 88 04 01 00 00    	js     801e2a <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801d26:	83 ec 0c             	sub    $0xc,%esp
  801d29:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d2c:	50                   	push   %eax
  801d2d:	e8 c1 f1 ff ff       	call   800ef3 <fd_alloc>
  801d32:	89 c3                	mov    %eax,%ebx
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	85 c0                	test   %eax,%eax
  801d39:	0f 88 db 00 00 00    	js     801e1a <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3f:	83 ec 04             	sub    $0x4,%esp
  801d42:	68 07 04 00 00       	push   $0x407
  801d47:	ff 75 f0             	push   -0x10(%ebp)
  801d4a:	6a 00                	push   $0x0
  801d4c:	e8 8d ee ff ff       	call   800bde <sys_page_alloc>
  801d51:	89 c3                	mov    %eax,%ebx
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	85 c0                	test   %eax,%eax
  801d58:	0f 88 bc 00 00 00    	js     801e1a <pipe+0x131>
	va = fd2data(fd0);
  801d5e:	83 ec 0c             	sub    $0xc,%esp
  801d61:	ff 75 f4             	push   -0xc(%ebp)
  801d64:	e8 73 f1 ff ff       	call   800edc <fd2data>
  801d69:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6b:	83 c4 0c             	add    $0xc,%esp
  801d6e:	68 07 04 00 00       	push   $0x407
  801d73:	50                   	push   %eax
  801d74:	6a 00                	push   $0x0
  801d76:	e8 63 ee ff ff       	call   800bde <sys_page_alloc>
  801d7b:	89 c3                	mov    %eax,%ebx
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	85 c0                	test   %eax,%eax
  801d82:	0f 88 82 00 00 00    	js     801e0a <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d88:	83 ec 0c             	sub    $0xc,%esp
  801d8b:	ff 75 f0             	push   -0x10(%ebp)
  801d8e:	e8 49 f1 ff ff       	call   800edc <fd2data>
  801d93:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d9a:	50                   	push   %eax
  801d9b:	6a 00                	push   $0x0
  801d9d:	56                   	push   %esi
  801d9e:	6a 00                	push   $0x0
  801da0:	e8 7c ee ff ff       	call   800c21 <sys_page_map>
  801da5:	89 c3                	mov    %eax,%ebx
  801da7:	83 c4 20             	add    $0x20,%esp
  801daa:	85 c0                	test   %eax,%eax
  801dac:	78 4e                	js     801dfc <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801dae:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801db3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801db6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801db8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dbb:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801dc2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dc5:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801dd1:	83 ec 0c             	sub    $0xc,%esp
  801dd4:	ff 75 f4             	push   -0xc(%ebp)
  801dd7:	e8 f0 f0 ff ff       	call   800ecc <fd2num>
  801ddc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801de1:	83 c4 04             	add    $0x4,%esp
  801de4:	ff 75 f0             	push   -0x10(%ebp)
  801de7:	e8 e0 f0 ff ff       	call   800ecc <fd2num>
  801dec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801def:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dfa:	eb 2e                	jmp    801e2a <pipe+0x141>
	sys_page_unmap(0, va);
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	56                   	push   %esi
  801e00:	6a 00                	push   $0x0
  801e02:	e8 5c ee ff ff       	call   800c63 <sys_page_unmap>
  801e07:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e0a:	83 ec 08             	sub    $0x8,%esp
  801e0d:	ff 75 f0             	push   -0x10(%ebp)
  801e10:	6a 00                	push   $0x0
  801e12:	e8 4c ee ff ff       	call   800c63 <sys_page_unmap>
  801e17:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e1a:	83 ec 08             	sub    $0x8,%esp
  801e1d:	ff 75 f4             	push   -0xc(%ebp)
  801e20:	6a 00                	push   $0x0
  801e22:	e8 3c ee ff ff       	call   800c63 <sys_page_unmap>
  801e27:	83 c4 10             	add    $0x10,%esp
}
  801e2a:	89 d8                	mov    %ebx,%eax
  801e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2f:	5b                   	pop    %ebx
  801e30:	5e                   	pop    %esi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <pipeisclosed>:
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	ff 75 08             	push   0x8(%ebp)
  801e40:	e8 fe f0 ff ff       	call   800f43 <fd_lookup>
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	78 18                	js     801e64 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e4c:	83 ec 0c             	sub    $0xc,%esp
  801e4f:	ff 75 f4             	push   -0xc(%ebp)
  801e52:	e8 85 f0 ff ff       	call   800edc <fd2data>
  801e57:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5c:	e8 33 fd ff ff       	call   801b94 <_pipeisclosed>
  801e61:	83 c4 10             	add    $0x10,%esp
}
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801e66:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6b:	c3                   	ret    

00801e6c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e72:	68 cb 28 80 00       	push   $0x8028cb
  801e77:	ff 75 0c             	push   0xc(%ebp)
  801e7a:	e8 63 e9 ff ff       	call   8007e2 <strcpy>
	return 0;
}
  801e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <devcons_write>:
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	57                   	push   %edi
  801e8a:	56                   	push   %esi
  801e8b:	53                   	push   %ebx
  801e8c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e92:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e97:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e9d:	eb 2e                	jmp    801ecd <devcons_write+0x47>
		m = n - tot;
  801e9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea2:	29 f3                	sub    %esi,%ebx
  801ea4:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ea9:	39 c3                	cmp    %eax,%ebx
  801eab:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801eae:	83 ec 04             	sub    $0x4,%esp
  801eb1:	53                   	push   %ebx
  801eb2:	89 f0                	mov    %esi,%eax
  801eb4:	03 45 0c             	add    0xc(%ebp),%eax
  801eb7:	50                   	push   %eax
  801eb8:	57                   	push   %edi
  801eb9:	e8 ba ea ff ff       	call   800978 <memmove>
		sys_cputs(buf, m);
  801ebe:	83 c4 08             	add    $0x8,%esp
  801ec1:	53                   	push   %ebx
  801ec2:	57                   	push   %edi
  801ec3:	e8 5a ec ff ff       	call   800b22 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ec8:	01 de                	add    %ebx,%esi
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ed0:	72 cd                	jb     801e9f <devcons_write+0x19>
}
  801ed2:	89 f0                	mov    %esi,%eax
  801ed4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed7:	5b                   	pop    %ebx
  801ed8:	5e                   	pop    %esi
  801ed9:	5f                   	pop    %edi
  801eda:	5d                   	pop    %ebp
  801edb:	c3                   	ret    

00801edc <devcons_read>:
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	83 ec 08             	sub    $0x8,%esp
  801ee2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ee7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eeb:	75 07                	jne    801ef4 <devcons_read+0x18>
  801eed:	eb 1f                	jmp    801f0e <devcons_read+0x32>
		sys_yield();
  801eef:	e8 cb ec ff ff       	call   800bbf <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801ef4:	e8 47 ec ff ff       	call   800b40 <sys_cgetc>
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	74 f2                	je     801eef <devcons_read+0x13>
	if (c < 0)
  801efd:	78 0f                	js     801f0e <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801eff:	83 f8 04             	cmp    $0x4,%eax
  801f02:	74 0c                	je     801f10 <devcons_read+0x34>
	*(char*)vbuf = c;
  801f04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f07:	88 02                	mov    %al,(%edx)
	return 1;
  801f09:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f0e:	c9                   	leave  
  801f0f:	c3                   	ret    
		return 0;
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
  801f15:	eb f7                	jmp    801f0e <devcons_read+0x32>

00801f17 <cputchar>:
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f20:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f23:	6a 01                	push   $0x1
  801f25:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f28:	50                   	push   %eax
  801f29:	e8 f4 eb ff ff       	call   800b22 <sys_cputs>
}
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <getchar>:
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f39:	6a 01                	push   $0x1
  801f3b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f3e:	50                   	push   %eax
  801f3f:	6a 00                	push   $0x0
  801f41:	e8 66 f2 ff ff       	call   8011ac <read>
	if (r < 0)
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	78 06                	js     801f53 <getchar+0x20>
	if (r < 1)
  801f4d:	74 06                	je     801f55 <getchar+0x22>
	return c;
  801f4f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    
		return -E_EOF;
  801f55:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f5a:	eb f7                	jmp    801f53 <getchar+0x20>

00801f5c <iscons>:
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f65:	50                   	push   %eax
  801f66:	ff 75 08             	push   0x8(%ebp)
  801f69:	e8 d5 ef ff ff       	call   800f43 <fd_lookup>
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	85 c0                	test   %eax,%eax
  801f73:	78 11                	js     801f86 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f78:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f7e:	39 10                	cmp    %edx,(%eax)
  801f80:	0f 94 c0             	sete   %al
  801f83:	0f b6 c0             	movzbl %al,%eax
}
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <opencons>:
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f91:	50                   	push   %eax
  801f92:	e8 5c ef ff ff       	call   800ef3 <fd_alloc>
  801f97:	83 c4 10             	add    $0x10,%esp
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	78 3a                	js     801fd8 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f9e:	83 ec 04             	sub    $0x4,%esp
  801fa1:	68 07 04 00 00       	push   $0x407
  801fa6:	ff 75 f4             	push   -0xc(%ebp)
  801fa9:	6a 00                	push   $0x0
  801fab:	e8 2e ec ff ff       	call   800bde <sys_page_alloc>
  801fb0:	83 c4 10             	add    $0x10,%esp
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	78 21                	js     801fd8 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fba:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fc0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fcc:	83 ec 0c             	sub    $0xc,%esp
  801fcf:	50                   	push   %eax
  801fd0:	e8 f7 ee ff ff       	call   800ecc <fd2num>
  801fd5:	83 c4 10             	add    $0x10,%esp
}
  801fd8:	c9                   	leave  
  801fd9:	c3                   	ret    

00801fda <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	56                   	push   %esi
  801fde:	53                   	push   %ebx
  801fdf:	8b 75 08             	mov    0x8(%ebp),%esi
  801fe2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fef:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ff2:	83 ec 0c             	sub    $0xc,%esp
  801ff5:	50                   	push   %eax
  801ff6:	e8 93 ed ff ff       	call   800d8e <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ffb:	83 c4 10             	add    $0x10,%esp
  801ffe:	85 f6                	test   %esi,%esi
  802000:	74 17                	je     802019 <ipc_recv+0x3f>
  802002:	ba 00 00 00 00       	mov    $0x0,%edx
  802007:	85 c0                	test   %eax,%eax
  802009:	78 0c                	js     802017 <ipc_recv+0x3d>
  80200b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802011:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802017:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802019:	85 db                	test   %ebx,%ebx
  80201b:	74 17                	je     802034 <ipc_recv+0x5a>
  80201d:	ba 00 00 00 00       	mov    $0x0,%edx
  802022:	85 c0                	test   %eax,%eax
  802024:	78 0c                	js     802032 <ipc_recv+0x58>
  802026:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80202c:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  802032:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802034:	85 c0                	test   %eax,%eax
  802036:	78 0b                	js     802043 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802038:	a1 00 40 80 00       	mov    0x804000,%eax
  80203d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  802043:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802046:	5b                   	pop    %ebx
  802047:	5e                   	pop    %esi
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    

0080204a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	57                   	push   %edi
  80204e:	56                   	push   %esi
  80204f:	53                   	push   %ebx
  802050:	83 ec 0c             	sub    $0xc,%esp
  802053:	8b 7d 08             	mov    0x8(%ebp),%edi
  802056:	8b 75 0c             	mov    0xc(%ebp),%esi
  802059:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80205c:	85 db                	test   %ebx,%ebx
  80205e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802063:	0f 44 d8             	cmove  %eax,%ebx
  802066:	eb 05                	jmp    80206d <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802068:	e8 52 eb ff ff       	call   800bbf <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80206d:	ff 75 14             	push   0x14(%ebp)
  802070:	53                   	push   %ebx
  802071:	56                   	push   %esi
  802072:	57                   	push   %edi
  802073:	e8 f3 ec ff ff       	call   800d6b <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80207e:	74 e8                	je     802068 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802080:	85 c0                	test   %eax,%eax
  802082:	78 08                	js     80208c <ipc_send+0x42>
	}while (r<0);

}
  802084:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802087:	5b                   	pop    %ebx
  802088:	5e                   	pop    %esi
  802089:	5f                   	pop    %edi
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80208c:	50                   	push   %eax
  80208d:	68 d7 28 80 00       	push   $0x8028d7
  802092:	6a 3d                	push   $0x3d
  802094:	68 eb 28 80 00       	push   $0x8028eb
  802099:	e8 8f e0 ff ff       	call   80012d <_panic>

0080209e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020a9:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8020af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020b5:	8b 52 60             	mov    0x60(%edx),%edx
  8020b8:	39 ca                	cmp    %ecx,%edx
  8020ba:	74 11                	je     8020cd <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8020bc:	83 c0 01             	add    $0x1,%eax
  8020bf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020c4:	75 e3                	jne    8020a9 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8020c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8020cb:	eb 0e                	jmp    8020db <ipc_find_env+0x3d>
			return envs[i].env_id;
  8020cd:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8020d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020d8:	8b 40 58             	mov    0x58(%eax),%eax
}
  8020db:	5d                   	pop    %ebp
  8020dc:	c3                   	ret    

008020dd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e3:	89 c2                	mov    %eax,%edx
  8020e5:	c1 ea 16             	shr    $0x16,%edx
  8020e8:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020ef:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020f4:	f6 c1 01             	test   $0x1,%cl
  8020f7:	74 1c                	je     802115 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8020f9:	c1 e8 0c             	shr    $0xc,%eax
  8020fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802103:	a8 01                	test   $0x1,%al
  802105:	74 0e                	je     802115 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802107:	c1 e8 0c             	shr    $0xc,%eax
  80210a:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802111:	ef 
  802112:	0f b7 d2             	movzwl %dx,%edx
}
  802115:	89 d0                	mov    %edx,%eax
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	66 90                	xchg   %ax,%ax
  80211b:	66 90                	xchg   %ax,%ax
  80211d:	66 90                	xchg   %ax,%ax
  80211f:	90                   	nop

00802120 <__udivdi3>:
  802120:	f3 0f 1e fb          	endbr32 
  802124:	55                   	push   %ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 1c             	sub    $0x1c,%esp
  80212b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80212f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802133:	8b 74 24 34          	mov    0x34(%esp),%esi
  802137:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80213b:	85 c0                	test   %eax,%eax
  80213d:	75 19                	jne    802158 <__udivdi3+0x38>
  80213f:	39 f3                	cmp    %esi,%ebx
  802141:	76 4d                	jbe    802190 <__udivdi3+0x70>
  802143:	31 ff                	xor    %edi,%edi
  802145:	89 e8                	mov    %ebp,%eax
  802147:	89 f2                	mov    %esi,%edx
  802149:	f7 f3                	div    %ebx
  80214b:	89 fa                	mov    %edi,%edx
  80214d:	83 c4 1c             	add    $0x1c,%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	39 f0                	cmp    %esi,%eax
  80215a:	76 14                	jbe    802170 <__udivdi3+0x50>
  80215c:	31 ff                	xor    %edi,%edi
  80215e:	31 c0                	xor    %eax,%eax
  802160:	89 fa                	mov    %edi,%edx
  802162:	83 c4 1c             	add    $0x1c,%esp
  802165:	5b                   	pop    %ebx
  802166:	5e                   	pop    %esi
  802167:	5f                   	pop    %edi
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    
  80216a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802170:	0f bd f8             	bsr    %eax,%edi
  802173:	83 f7 1f             	xor    $0x1f,%edi
  802176:	75 48                	jne    8021c0 <__udivdi3+0xa0>
  802178:	39 f0                	cmp    %esi,%eax
  80217a:	72 06                	jb     802182 <__udivdi3+0x62>
  80217c:	31 c0                	xor    %eax,%eax
  80217e:	39 eb                	cmp    %ebp,%ebx
  802180:	77 de                	ja     802160 <__udivdi3+0x40>
  802182:	b8 01 00 00 00       	mov    $0x1,%eax
  802187:	eb d7                	jmp    802160 <__udivdi3+0x40>
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 d9                	mov    %ebx,%ecx
  802192:	85 db                	test   %ebx,%ebx
  802194:	75 0b                	jne    8021a1 <__udivdi3+0x81>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f3                	div    %ebx
  80219f:	89 c1                	mov    %eax,%ecx
  8021a1:	31 d2                	xor    %edx,%edx
  8021a3:	89 f0                	mov    %esi,%eax
  8021a5:	f7 f1                	div    %ecx
  8021a7:	89 c6                	mov    %eax,%esi
  8021a9:	89 e8                	mov    %ebp,%eax
  8021ab:	89 f7                	mov    %esi,%edi
  8021ad:	f7 f1                	div    %ecx
  8021af:	89 fa                	mov    %edi,%edx
  8021b1:	83 c4 1c             	add    $0x1c,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5f                   	pop    %edi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 f9                	mov    %edi,%ecx
  8021c2:	ba 20 00 00 00       	mov    $0x20,%edx
  8021c7:	29 fa                	sub    %edi,%edx
  8021c9:	d3 e0                	shl    %cl,%eax
  8021cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021cf:	89 d1                	mov    %edx,%ecx
  8021d1:	89 d8                	mov    %ebx,%eax
  8021d3:	d3 e8                	shr    %cl,%eax
  8021d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021d9:	09 c1                	or     %eax,%ecx
  8021db:	89 f0                	mov    %esi,%eax
  8021dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	d3 e3                	shl    %cl,%ebx
  8021e5:	89 d1                	mov    %edx,%ecx
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 f9                	mov    %edi,%ecx
  8021eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021ef:	89 eb                	mov    %ebp,%ebx
  8021f1:	d3 e6                	shl    %cl,%esi
  8021f3:	89 d1                	mov    %edx,%ecx
  8021f5:	d3 eb                	shr    %cl,%ebx
  8021f7:	09 f3                	or     %esi,%ebx
  8021f9:	89 c6                	mov    %eax,%esi
  8021fb:	89 f2                	mov    %esi,%edx
  8021fd:	89 d8                	mov    %ebx,%eax
  8021ff:	f7 74 24 08          	divl   0x8(%esp)
  802203:	89 d6                	mov    %edx,%esi
  802205:	89 c3                	mov    %eax,%ebx
  802207:	f7 64 24 0c          	mull   0xc(%esp)
  80220b:	39 d6                	cmp    %edx,%esi
  80220d:	72 19                	jb     802228 <__udivdi3+0x108>
  80220f:	89 f9                	mov    %edi,%ecx
  802211:	d3 e5                	shl    %cl,%ebp
  802213:	39 c5                	cmp    %eax,%ebp
  802215:	73 04                	jae    80221b <__udivdi3+0xfb>
  802217:	39 d6                	cmp    %edx,%esi
  802219:	74 0d                	je     802228 <__udivdi3+0x108>
  80221b:	89 d8                	mov    %ebx,%eax
  80221d:	31 ff                	xor    %edi,%edi
  80221f:	e9 3c ff ff ff       	jmp    802160 <__udivdi3+0x40>
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80222b:	31 ff                	xor    %edi,%edi
  80222d:	e9 2e ff ff ff       	jmp    802160 <__udivdi3+0x40>
  802232:	66 90                	xchg   %ax,%ax
  802234:	66 90                	xchg   %ax,%ax
  802236:	66 90                	xchg   %ax,%ax
  802238:	66 90                	xchg   %ax,%ax
  80223a:	66 90                	xchg   %ax,%ax
  80223c:	66 90                	xchg   %ax,%ax
  80223e:	66 90                	xchg   %ax,%ax

00802240 <__umoddi3>:
  802240:	f3 0f 1e fb          	endbr32 
  802244:	55                   	push   %ebp
  802245:	57                   	push   %edi
  802246:	56                   	push   %esi
  802247:	53                   	push   %ebx
  802248:	83 ec 1c             	sub    $0x1c,%esp
  80224b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80224f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802253:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802257:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80225b:	89 f0                	mov    %esi,%eax
  80225d:	89 da                	mov    %ebx,%edx
  80225f:	85 ff                	test   %edi,%edi
  802261:	75 15                	jne    802278 <__umoddi3+0x38>
  802263:	39 dd                	cmp    %ebx,%ebp
  802265:	76 39                	jbe    8022a0 <__umoddi3+0x60>
  802267:	f7 f5                	div    %ebp
  802269:	89 d0                	mov    %edx,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	83 c4 1c             	add    $0x1c,%esp
  802270:	5b                   	pop    %ebx
  802271:	5e                   	pop    %esi
  802272:	5f                   	pop    %edi
  802273:	5d                   	pop    %ebp
  802274:	c3                   	ret    
  802275:	8d 76 00             	lea    0x0(%esi),%esi
  802278:	39 df                	cmp    %ebx,%edi
  80227a:	77 f1                	ja     80226d <__umoddi3+0x2d>
  80227c:	0f bd cf             	bsr    %edi,%ecx
  80227f:	83 f1 1f             	xor    $0x1f,%ecx
  802282:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802286:	75 40                	jne    8022c8 <__umoddi3+0x88>
  802288:	39 df                	cmp    %ebx,%edi
  80228a:	72 04                	jb     802290 <__umoddi3+0x50>
  80228c:	39 f5                	cmp    %esi,%ebp
  80228e:	77 dd                	ja     80226d <__umoddi3+0x2d>
  802290:	89 da                	mov    %ebx,%edx
  802292:	89 f0                	mov    %esi,%eax
  802294:	29 e8                	sub    %ebp,%eax
  802296:	19 fa                	sbb    %edi,%edx
  802298:	eb d3                	jmp    80226d <__umoddi3+0x2d>
  80229a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a0:	89 e9                	mov    %ebp,%ecx
  8022a2:	85 ed                	test   %ebp,%ebp
  8022a4:	75 0b                	jne    8022b1 <__umoddi3+0x71>
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f5                	div    %ebp
  8022af:	89 c1                	mov    %eax,%ecx
  8022b1:	89 d8                	mov    %ebx,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f1                	div    %ecx
  8022b7:	89 f0                	mov    %esi,%eax
  8022b9:	f7 f1                	div    %ecx
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	31 d2                	xor    %edx,%edx
  8022bf:	eb ac                	jmp    80226d <__umoddi3+0x2d>
  8022c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022cc:	ba 20 00 00 00       	mov    $0x20,%edx
  8022d1:	29 c2                	sub    %eax,%edx
  8022d3:	89 c1                	mov    %eax,%ecx
  8022d5:	89 e8                	mov    %ebp,%eax
  8022d7:	d3 e7                	shl    %cl,%edi
  8022d9:	89 d1                	mov    %edx,%ecx
  8022db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022df:	d3 e8                	shr    %cl,%eax
  8022e1:	89 c1                	mov    %eax,%ecx
  8022e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022e7:	09 f9                	or     %edi,%ecx
  8022e9:	89 df                	mov    %ebx,%edi
  8022eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ef:	89 c1                	mov    %eax,%ecx
  8022f1:	d3 e5                	shl    %cl,%ebp
  8022f3:	89 d1                	mov    %edx,%ecx
  8022f5:	d3 ef                	shr    %cl,%edi
  8022f7:	89 c1                	mov    %eax,%ecx
  8022f9:	89 f0                	mov    %esi,%eax
  8022fb:	d3 e3                	shl    %cl,%ebx
  8022fd:	89 d1                	mov    %edx,%ecx
  8022ff:	89 fa                	mov    %edi,%edx
  802301:	d3 e8                	shr    %cl,%eax
  802303:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802308:	09 d8                	or     %ebx,%eax
  80230a:	f7 74 24 08          	divl   0x8(%esp)
  80230e:	89 d3                	mov    %edx,%ebx
  802310:	d3 e6                	shl    %cl,%esi
  802312:	f7 e5                	mul    %ebp
  802314:	89 c7                	mov    %eax,%edi
  802316:	89 d1                	mov    %edx,%ecx
  802318:	39 d3                	cmp    %edx,%ebx
  80231a:	72 06                	jb     802322 <__umoddi3+0xe2>
  80231c:	75 0e                	jne    80232c <__umoddi3+0xec>
  80231e:	39 c6                	cmp    %eax,%esi
  802320:	73 0a                	jae    80232c <__umoddi3+0xec>
  802322:	29 e8                	sub    %ebp,%eax
  802324:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802328:	89 d1                	mov    %edx,%ecx
  80232a:	89 c7                	mov    %eax,%edi
  80232c:	89 f5                	mov    %esi,%ebp
  80232e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802332:	29 fd                	sub    %edi,%ebp
  802334:	19 cb                	sbb    %ecx,%ebx
  802336:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80233b:	89 d8                	mov    %ebx,%eax
  80233d:	d3 e0                	shl    %cl,%eax
  80233f:	89 f1                	mov    %esi,%ecx
  802341:	d3 ed                	shr    %cl,%ebp
  802343:	d3 eb                	shr    %cl,%ebx
  802345:	09 e8                	or     %ebp,%eax
  802347:	89 da                	mov    %ebx,%edx
  802349:	83 c4 1c             	add    $0x1c,%esp
  80234c:	5b                   	pop    %ebx
  80234d:	5e                   	pop    %esi
  80234e:	5f                   	pop    %edi
  80234f:	5d                   	pop    %ebp
  802350:	c3                   	ret    
