
obj/user/faultalloc：     文件格式 elf32-i386


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
  800040:	68 60 10 80 00       	push   $0x801060
  800045:	e8 b3 01 00 00       	call   8001fd <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 75 0b 00 00       	call   800bd3 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 ac 10 80 00       	push   $0x8010ac
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 0f 07 00 00       	call   800782 <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 80 10 80 00       	push   $0x801080
  800085:	6a 0e                	push   $0xe
  800087:	68 6a 10 80 00       	push   $0x80106a
  80008c:	e8 91 00 00 00       	call   800122 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 e1 0c 00 00       	call   800d82 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 7c 10 80 00       	push   $0x80107c
  8000ae:	e8 4a 01 00 00       	call   8001fd <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 7c 10 80 00       	push   $0x80107c
  8000c0:	e8 38 01 00 00       	call   8001fd <cprintf>
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
  8000d5:	e8 bb 0a 00 00       	call   800b95 <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 37 0a 00 00       	call   800b54 <sys_env_destroy>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800127:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800130:	e8 60 0a 00 00       	call   800b95 <sys_getenvid>
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	ff 75 0c             	push   0xc(%ebp)
  80013b:	ff 75 08             	push   0x8(%ebp)
  80013e:	56                   	push   %esi
  80013f:	50                   	push   %eax
  800140:	68 d8 10 80 00       	push   $0x8010d8
  800145:	e8 b3 00 00 00       	call   8001fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014a:	83 c4 18             	add    $0x18,%esp
  80014d:	53                   	push   %ebx
  80014e:	ff 75 10             	push   0x10(%ebp)
  800151:	e8 56 00 00 00       	call   8001ac <vcprintf>
	cprintf("\n");
  800156:	c7 04 24 7e 10 80 00 	movl   $0x80107e,(%esp)
  80015d:	e8 9b 00 00 00       	call   8001fd <cprintf>
  800162:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800165:	cc                   	int3   
  800166:	eb fd                	jmp    800165 <_panic+0x43>

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 13                	mov    (%ebx),%edx
  800174:	8d 42 01             	lea    0x1(%edx),%eax
  800177:	89 03                	mov    %eax,(%ebx)
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	74 09                	je     800190 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800187:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	68 ff 00 00 00       	push   $0xff
  800198:	8d 43 08             	lea    0x8(%ebx),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 76 09 00 00       	call   800b17 <sys_cputs>
		b->idx = 0;
  8001a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	eb db                	jmp    800187 <putch+0x1f>

008001ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bc:	00 00 00 
	b.cnt = 0;
  8001bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c9:	ff 75 0c             	push   0xc(%ebp)
  8001cc:	ff 75 08             	push   0x8(%ebp)
  8001cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d5:	50                   	push   %eax
  8001d6:	68 68 01 80 00       	push   $0x800168
  8001db:	e8 14 01 00 00       	call   8002f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e0:	83 c4 08             	add    $0x8,%esp
  8001e3:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	e8 22 09 00 00       	call   800b17 <sys_cputs>

	return b.cnt;
}
  8001f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800203:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800206:	50                   	push   %eax
  800207:	ff 75 08             	push   0x8(%ebp)
  80020a:	e8 9d ff ff ff       	call   8001ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	57                   	push   %edi
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	83 ec 1c             	sub    $0x1c,%esp
  80021a:	89 c7                	mov    %eax,%edi
  80021c:	89 d6                	mov    %edx,%esi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	8b 55 0c             	mov    0xc(%ebp),%edx
  800224:	89 d1                	mov    %edx,%ecx
  800226:	89 c2                	mov    %eax,%edx
  800228:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022e:	8b 45 10             	mov    0x10(%ebp),%eax
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800234:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800237:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80023e:	39 c2                	cmp    %eax,%edx
  800240:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800243:	72 3e                	jb     800283 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	ff 75 18             	push   0x18(%ebp)
  80024b:	83 eb 01             	sub    $0x1,%ebx
  80024e:	53                   	push   %ebx
  80024f:	50                   	push   %eax
  800250:	83 ec 08             	sub    $0x8,%esp
  800253:	ff 75 e4             	push   -0x1c(%ebp)
  800256:	ff 75 e0             	push   -0x20(%ebp)
  800259:	ff 75 dc             	push   -0x24(%ebp)
  80025c:	ff 75 d8             	push   -0x28(%ebp)
  80025f:	e8 bc 0b 00 00       	call   800e20 <__udivdi3>
  800264:	83 c4 18             	add    $0x18,%esp
  800267:	52                   	push   %edx
  800268:	50                   	push   %eax
  800269:	89 f2                	mov    %esi,%edx
  80026b:	89 f8                	mov    %edi,%eax
  80026d:	e8 9f ff ff ff       	call   800211 <printnum>
  800272:	83 c4 20             	add    $0x20,%esp
  800275:	eb 13                	jmp    80028a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	56                   	push   %esi
  80027b:	ff 75 18             	push   0x18(%ebp)
  80027e:	ff d7                	call   *%edi
  800280:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800283:	83 eb 01             	sub    $0x1,%ebx
  800286:	85 db                	test   %ebx,%ebx
  800288:	7f ed                	jg     800277 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	56                   	push   %esi
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	ff 75 e4             	push   -0x1c(%ebp)
  800294:	ff 75 e0             	push   -0x20(%ebp)
  800297:	ff 75 dc             	push   -0x24(%ebp)
  80029a:	ff 75 d8             	push   -0x28(%ebp)
  80029d:	e8 9e 0c 00 00       	call   800f40 <__umoddi3>
  8002a2:	83 c4 14             	add    $0x14,%esp
  8002a5:	0f be 80 fb 10 80 00 	movsbl 0x8010fb(%eax),%eax
  8002ac:	50                   	push   %eax
  8002ad:	ff d7                	call   *%edi
}
  8002af:	83 c4 10             	add    $0x10,%esp
  8002b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c9:	73 0a                	jae    8002d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	88 02                	mov    %al,(%edx)
}
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <printfmt>:
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e0:	50                   	push   %eax
  8002e1:	ff 75 10             	push   0x10(%ebp)
  8002e4:	ff 75 0c             	push   0xc(%ebp)
  8002e7:	ff 75 08             	push   0x8(%ebp)
  8002ea:	e8 05 00 00 00       	call   8002f4 <vprintfmt>
}
  8002ef:	83 c4 10             	add    $0x10,%esp
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <vprintfmt>:
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	57                   	push   %edi
  8002f8:	56                   	push   %esi
  8002f9:	53                   	push   %ebx
  8002fa:	83 ec 3c             	sub    $0x3c,%esp
  8002fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800300:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800303:	8b 7d 10             	mov    0x10(%ebp),%edi
  800306:	eb 0a                	jmp    800312 <vprintfmt+0x1e>
			putch(ch, putdat);
  800308:	83 ec 08             	sub    $0x8,%esp
  80030b:	53                   	push   %ebx
  80030c:	50                   	push   %eax
  80030d:	ff d6                	call   *%esi
  80030f:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800312:	83 c7 01             	add    $0x1,%edi
  800315:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800319:	83 f8 25             	cmp    $0x25,%eax
  80031c:	74 0c                	je     80032a <vprintfmt+0x36>
			if (ch == '\0')
  80031e:	85 c0                	test   %eax,%eax
  800320:	75 e6                	jne    800308 <vprintfmt+0x14>
}
  800322:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    
		padc = ' ';
  80032a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80032e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800335:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80033c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800343:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8d 47 01             	lea    0x1(%edi),%eax
  80034b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034e:	0f b6 17             	movzbl (%edi),%edx
  800351:	8d 42 dd             	lea    -0x23(%edx),%eax
  800354:	3c 55                	cmp    $0x55,%al
  800356:	0f 87 bb 03 00 00    	ja     800717 <vprintfmt+0x423>
  80035c:	0f b6 c0             	movzbl %al,%eax
  80035f:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800369:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80036d:	eb d9                	jmp    800348 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800372:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800376:	eb d0                	jmp    800348 <vprintfmt+0x54>
  800378:	0f b6 d2             	movzbl %dl,%edx
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80037e:	b8 00 00 00 00       	mov    $0x0,%eax
  800383:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800386:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800389:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80038d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800390:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800393:	83 f9 09             	cmp    $0x9,%ecx
  800396:	77 55                	ja     8003ed <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800398:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80039b:	eb e9                	jmp    800386 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 40 04             	lea    0x4(%eax),%eax
  8003ab:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b5:	79 91                	jns    800348 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c4:	eb 82                	jmp    800348 <vprintfmt+0x54>
  8003c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c9:	85 d2                	test   %edx,%edx
  8003cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d0:	0f 49 c2             	cmovns %edx,%eax
  8003d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d9:	e9 6a ff ff ff       	jmp    800348 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003e8:	e9 5b ff ff ff       	jmp    800348 <vprintfmt+0x54>
  8003ed:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f3:	eb bc                	jmp    8003b1 <vprintfmt+0xbd>
			lflag++;
  8003f5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fb:	e9 48 ff ff ff       	jmp    800348 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 78 04             	lea    0x4(%eax),%edi
  800406:	83 ec 08             	sub    $0x8,%esp
  800409:	53                   	push   %ebx
  80040a:	ff 30                	push   (%eax)
  80040c:	ff d6                	call   *%esi
			break;
  80040e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800411:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800414:	e9 9d 02 00 00       	jmp    8006b6 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 78 04             	lea    0x4(%eax),%edi
  80041f:	8b 10                	mov    (%eax),%edx
  800421:	89 d0                	mov    %edx,%eax
  800423:	f7 d8                	neg    %eax
  800425:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800428:	83 f8 08             	cmp    $0x8,%eax
  80042b:	7f 23                	jg     800450 <vprintfmt+0x15c>
  80042d:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  800434:	85 d2                	test   %edx,%edx
  800436:	74 18                	je     800450 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800438:	52                   	push   %edx
  800439:	68 1c 11 80 00       	push   $0x80111c
  80043e:	53                   	push   %ebx
  80043f:	56                   	push   %esi
  800440:	e8 92 fe ff ff       	call   8002d7 <printfmt>
  800445:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800448:	89 7d 14             	mov    %edi,0x14(%ebp)
  80044b:	e9 66 02 00 00       	jmp    8006b6 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800450:	50                   	push   %eax
  800451:	68 13 11 80 00       	push   $0x801113
  800456:	53                   	push   %ebx
  800457:	56                   	push   %esi
  800458:	e8 7a fe ff ff       	call   8002d7 <printfmt>
  80045d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800460:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 4e 02 00 00       	jmp    8006b6 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	83 c0 04             	add    $0x4,%eax
  80046e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800476:	85 d2                	test   %edx,%edx
  800478:	b8 0c 11 80 00       	mov    $0x80110c,%eax
  80047d:	0f 45 c2             	cmovne %edx,%eax
  800480:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800483:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800487:	7e 06                	jle    80048f <vprintfmt+0x19b>
  800489:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80048d:	75 0d                	jne    80049c <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800492:	89 c7                	mov    %eax,%edi
  800494:	03 45 e0             	add    -0x20(%ebp),%eax
  800497:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049a:	eb 55                	jmp    8004f1 <vprintfmt+0x1fd>
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	ff 75 d8             	push   -0x28(%ebp)
  8004a2:	ff 75 cc             	push   -0x34(%ebp)
  8004a5:	e8 0a 03 00 00       	call   8007b4 <strnlen>
  8004aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ad:	29 c1                	sub    %eax,%ecx
  8004af:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004b7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004be:	eb 0f                	jmp    8004cf <vprintfmt+0x1db>
					putch(padc, putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	53                   	push   %ebx
  8004c4:	ff 75 e0             	push   -0x20(%ebp)
  8004c7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	83 ef 01             	sub    $0x1,%edi
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	85 ff                	test   %edi,%edi
  8004d1:	7f ed                	jg     8004c0 <vprintfmt+0x1cc>
  8004d3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	0f 49 c2             	cmovns %edx,%eax
  8004e0:	29 c2                	sub    %eax,%edx
  8004e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004e5:	eb a8                	jmp    80048f <vprintfmt+0x19b>
					putch(ch, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	52                   	push   %edx
  8004ec:	ff d6                	call   *%esi
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f6:	83 c7 01             	add    $0x1,%edi
  8004f9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fd:	0f be d0             	movsbl %al,%edx
  800500:	85 d2                	test   %edx,%edx
  800502:	74 4b                	je     80054f <vprintfmt+0x25b>
  800504:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800508:	78 06                	js     800510 <vprintfmt+0x21c>
  80050a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80050e:	78 1e                	js     80052e <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800510:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800514:	74 d1                	je     8004e7 <vprintfmt+0x1f3>
  800516:	0f be c0             	movsbl %al,%eax
  800519:	83 e8 20             	sub    $0x20,%eax
  80051c:	83 f8 5e             	cmp    $0x5e,%eax
  80051f:	76 c6                	jbe    8004e7 <vprintfmt+0x1f3>
					putch('?', putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	53                   	push   %ebx
  800525:	6a 3f                	push   $0x3f
  800527:	ff d6                	call   *%esi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	eb c3                	jmp    8004f1 <vprintfmt+0x1fd>
  80052e:	89 cf                	mov    %ecx,%edi
  800530:	eb 0e                	jmp    800540 <vprintfmt+0x24c>
				putch(' ', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	6a 20                	push   $0x20
  800538:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80053a:	83 ef 01             	sub    $0x1,%edi
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	85 ff                	test   %edi,%edi
  800542:	7f ee                	jg     800532 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800544:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800547:	89 45 14             	mov    %eax,0x14(%ebp)
  80054a:	e9 67 01 00 00       	jmp    8006b6 <vprintfmt+0x3c2>
  80054f:	89 cf                	mov    %ecx,%edi
  800551:	eb ed                	jmp    800540 <vprintfmt+0x24c>
	if (lflag >= 2)
  800553:	83 f9 01             	cmp    $0x1,%ecx
  800556:	7f 1b                	jg     800573 <vprintfmt+0x27f>
	else if (lflag)
  800558:	85 c9                	test   %ecx,%ecx
  80055a:	74 63                	je     8005bf <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800564:	99                   	cltd   
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 40 04             	lea    0x4(%eax),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	eb 17                	jmp    80058a <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8b 50 04             	mov    0x4(%eax),%edx
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 08             	lea    0x8(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80058a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800590:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800595:	85 c9                	test   %ecx,%ecx
  800597:	0f 89 ff 00 00 00    	jns    80069c <vprintfmt+0x3a8>
				putch('-', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	6a 2d                	push   $0x2d
  8005a3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ab:	f7 da                	neg    %edx
  8005ad:	83 d1 00             	adc    $0x0,%ecx
  8005b0:	f7 d9                	neg    %ecx
  8005b2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b5:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005ba:	e9 dd 00 00 00       	jmp    80069c <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	99                   	cltd   
  8005c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 40 04             	lea    0x4(%eax),%eax
  8005d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d4:	eb b4                	jmp    80058a <vprintfmt+0x296>
	if (lflag >= 2)
  8005d6:	83 f9 01             	cmp    $0x1,%ecx
  8005d9:	7f 1e                	jg     8005f9 <vprintfmt+0x305>
	else if (lflag)
  8005db:	85 c9                	test   %ecx,%ecx
  8005dd:	74 32                	je     800611 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e9:	8d 40 04             	lea    0x4(%eax),%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ef:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005f4:	e9 a3 00 00 00       	jmp    80069c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	8b 48 04             	mov    0x4(%eax),%ecx
  800601:	8d 40 08             	lea    0x8(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800607:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80060c:	e9 8b 00 00 00       	jmp    80069c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8b 10                	mov    (%eax),%edx
  800616:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061b:	8d 40 04             	lea    0x4(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800621:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800626:	eb 74                	jmp    80069c <vprintfmt+0x3a8>
	if (lflag >= 2)
  800628:	83 f9 01             	cmp    $0x1,%ecx
  80062b:	7f 1b                	jg     800648 <vprintfmt+0x354>
	else if (lflag)
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	74 2c                	je     80065d <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063b:	8d 40 04             	lea    0x4(%eax),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800641:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800646:	eb 54                	jmp    80069c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 10                	mov    (%eax),%edx
  80064d:	8b 48 04             	mov    0x4(%eax),%ecx
  800650:	8d 40 08             	lea    0x8(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800656:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80065b:	eb 3f                	jmp    80069c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 10                	mov    (%eax),%edx
  800662:	b9 00 00 00 00       	mov    $0x0,%ecx
  800667:	8d 40 04             	lea    0x4(%eax),%eax
  80066a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80066d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800672:	eb 28                	jmp    80069c <vprintfmt+0x3a8>
			putch('0', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 30                	push   $0x30
  80067a:	ff d6                	call   *%esi
			putch('x', putdat);
  80067c:	83 c4 08             	add    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 78                	push   $0x78
  800682:	ff d6                	call   *%esi
			num = (unsigned long long)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80068e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800691:	8d 40 04             	lea    0x4(%eax),%eax
  800694:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800697:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006a3:	50                   	push   %eax
  8006a4:	ff 75 e0             	push   -0x20(%ebp)
  8006a7:	57                   	push   %edi
  8006a8:	51                   	push   %ecx
  8006a9:	52                   	push   %edx
  8006aa:	89 da                	mov    %ebx,%edx
  8006ac:	89 f0                	mov    %esi,%eax
  8006ae:	e8 5e fb ff ff       	call   800211 <printnum>
			break;
  8006b3:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006b9:	e9 54 fc ff ff       	jmp    800312 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006be:	83 f9 01             	cmp    $0x1,%ecx
  8006c1:	7f 1b                	jg     8006de <vprintfmt+0x3ea>
	else if (lflag)
  8006c3:	85 c9                	test   %ecx,%ecx
  8006c5:	74 2c                	je     8006f3 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d1:	8d 40 04             	lea    0x4(%eax),%eax
  8006d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006dc:	eb be                	jmp    80069c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8b 10                	mov    (%eax),%edx
  8006e3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e6:	8d 40 08             	lea    0x8(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ec:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006f1:	eb a9                	jmp    80069c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 10                	mov    (%eax),%edx
  8006f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fd:	8d 40 04             	lea    0x4(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800703:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800708:	eb 92                	jmp    80069c <vprintfmt+0x3a8>
			putch(ch, putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 25                	push   $0x25
  800710:	ff d6                	call   *%esi
			break;
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	eb 9f                	jmp    8006b6 <vprintfmt+0x3c2>
			putch('%', putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	53                   	push   %ebx
  80071b:	6a 25                	push   $0x25
  80071d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	89 f8                	mov    %edi,%eax
  800724:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800728:	74 05                	je     80072f <vprintfmt+0x43b>
  80072a:	83 e8 01             	sub    $0x1,%eax
  80072d:	eb f5                	jmp    800724 <vprintfmt+0x430>
  80072f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800732:	eb 82                	jmp    8006b6 <vprintfmt+0x3c2>

00800734 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	83 ec 18             	sub    $0x18,%esp
  80073a:	8b 45 08             	mov    0x8(%ebp),%eax
  80073d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800740:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800743:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800747:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800751:	85 c0                	test   %eax,%eax
  800753:	74 26                	je     80077b <vsnprintf+0x47>
  800755:	85 d2                	test   %edx,%edx
  800757:	7e 22                	jle    80077b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800759:	ff 75 14             	push   0x14(%ebp)
  80075c:	ff 75 10             	push   0x10(%ebp)
  80075f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800762:	50                   	push   %eax
  800763:	68 ba 02 80 00       	push   $0x8002ba
  800768:	e8 87 fb ff ff       	call   8002f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800770:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800773:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800776:	83 c4 10             	add    $0x10,%esp
}
  800779:	c9                   	leave  
  80077a:	c3                   	ret    
		return -E_INVAL;
  80077b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800780:	eb f7                	jmp    800779 <vsnprintf+0x45>

00800782 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800788:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078b:	50                   	push   %eax
  80078c:	ff 75 10             	push   0x10(%ebp)
  80078f:	ff 75 0c             	push   0xc(%ebp)
  800792:	ff 75 08             	push   0x8(%ebp)
  800795:	e8 9a ff ff ff       	call   800734 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a7:	eb 03                	jmp    8007ac <strlen+0x10>
		n++;
  8007a9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007ac:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b0:	75 f7                	jne    8007a9 <strlen+0xd>
	return n;
}
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c2:	eb 03                	jmp    8007c7 <strnlen+0x13>
		n++;
  8007c4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c7:	39 d0                	cmp    %edx,%eax
  8007c9:	74 08                	je     8007d3 <strnlen+0x1f>
  8007cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cf:	75 f3                	jne    8007c4 <strnlen+0x10>
  8007d1:	89 c2                	mov    %eax,%edx
	return n;
}
  8007d3:	89 d0                	mov    %edx,%eax
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007ea:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007ed:	83 c0 01             	add    $0x1,%eax
  8007f0:	84 d2                	test   %dl,%dl
  8007f2:	75 f2                	jne    8007e6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f4:	89 c8                	mov    %ecx,%eax
  8007f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 10             	sub    $0x10,%esp
  800802:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800805:	53                   	push   %ebx
  800806:	e8 91 ff ff ff       	call   80079c <strlen>
  80080b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80080e:	ff 75 0c             	push   0xc(%ebp)
  800811:	01 d8                	add    %ebx,%eax
  800813:	50                   	push   %eax
  800814:	e8 be ff ff ff       	call   8007d7 <strcpy>
	return dst;
}
  800819:	89 d8                	mov    %ebx,%eax
  80081b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	56                   	push   %esi
  800824:	53                   	push   %ebx
  800825:	8b 75 08             	mov    0x8(%ebp),%esi
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082b:	89 f3                	mov    %esi,%ebx
  80082d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800830:	89 f0                	mov    %esi,%eax
  800832:	eb 0f                	jmp    800843 <strncpy+0x23>
		*dst++ = *src;
  800834:	83 c0 01             	add    $0x1,%eax
  800837:	0f b6 0a             	movzbl (%edx),%ecx
  80083a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083d:	80 f9 01             	cmp    $0x1,%cl
  800840:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800843:	39 d8                	cmp    %ebx,%eax
  800845:	75 ed                	jne    800834 <strncpy+0x14>
	}
	return ret;
}
  800847:	89 f0                	mov    %esi,%eax
  800849:	5b                   	pop    %ebx
  80084a:	5e                   	pop    %esi
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	8b 75 08             	mov    0x8(%ebp),%esi
  800855:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800858:	8b 55 10             	mov    0x10(%ebp),%edx
  80085b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085d:	85 d2                	test   %edx,%edx
  80085f:	74 21                	je     800882 <strlcpy+0x35>
  800861:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800865:	89 f2                	mov    %esi,%edx
  800867:	eb 09                	jmp    800872 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800869:	83 c1 01             	add    $0x1,%ecx
  80086c:	83 c2 01             	add    $0x1,%edx
  80086f:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800872:	39 c2                	cmp    %eax,%edx
  800874:	74 09                	je     80087f <strlcpy+0x32>
  800876:	0f b6 19             	movzbl (%ecx),%ebx
  800879:	84 db                	test   %bl,%bl
  80087b:	75 ec                	jne    800869 <strlcpy+0x1c>
  80087d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80087f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800882:	29 f0                	sub    %esi,%eax
}
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800891:	eb 06                	jmp    800899 <strcmp+0x11>
		p++, q++;
  800893:	83 c1 01             	add    $0x1,%ecx
  800896:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800899:	0f b6 01             	movzbl (%ecx),%eax
  80089c:	84 c0                	test   %al,%al
  80089e:	74 04                	je     8008a4 <strcmp+0x1c>
  8008a0:	3a 02                	cmp    (%edx),%al
  8008a2:	74 ef                	je     800893 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a4:	0f b6 c0             	movzbl %al,%eax
  8008a7:	0f b6 12             	movzbl (%edx),%edx
  8008aa:	29 d0                	sub    %edx,%eax
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	53                   	push   %ebx
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b8:	89 c3                	mov    %eax,%ebx
  8008ba:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bd:	eb 06                	jmp    8008c5 <strncmp+0x17>
		n--, p++, q++;
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008c5:	39 d8                	cmp    %ebx,%eax
  8008c7:	74 18                	je     8008e1 <strncmp+0x33>
  8008c9:	0f b6 08             	movzbl (%eax),%ecx
  8008cc:	84 c9                	test   %cl,%cl
  8008ce:	74 04                	je     8008d4 <strncmp+0x26>
  8008d0:	3a 0a                	cmp    (%edx),%cl
  8008d2:	74 eb                	je     8008bf <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d4:	0f b6 00             	movzbl (%eax),%eax
  8008d7:	0f b6 12             	movzbl (%edx),%edx
  8008da:	29 d0                	sub    %edx,%eax
}
  8008dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008df:	c9                   	leave  
  8008e0:	c3                   	ret    
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e6:	eb f4                	jmp    8008dc <strncmp+0x2e>

008008e8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f2:	eb 03                	jmp    8008f7 <strchr+0xf>
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	0f b6 10             	movzbl (%eax),%edx
  8008fa:	84 d2                	test   %dl,%dl
  8008fc:	74 06                	je     800904 <strchr+0x1c>
		if (*s == c)
  8008fe:	38 ca                	cmp    %cl,%dl
  800900:	75 f2                	jne    8008f4 <strchr+0xc>
  800902:	eb 05                	jmp    800909 <strchr+0x21>
			return (char *) s;
	return 0;
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800915:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 09                	je     800925 <strfind+0x1a>
  80091c:	84 d2                	test   %dl,%dl
  80091e:	74 05                	je     800925 <strfind+0x1a>
	for (; *s; s++)
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	eb f0                	jmp    800915 <strfind+0xa>
			break;
	return (char *) s;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	57                   	push   %edi
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800930:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800933:	85 c9                	test   %ecx,%ecx
  800935:	74 2f                	je     800966 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800937:	89 f8                	mov    %edi,%eax
  800939:	09 c8                	or     %ecx,%eax
  80093b:	a8 03                	test   $0x3,%al
  80093d:	75 21                	jne    800960 <memset+0x39>
		c &= 0xFF;
  80093f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800943:	89 d0                	mov    %edx,%eax
  800945:	c1 e0 08             	shl    $0x8,%eax
  800948:	89 d3                	mov    %edx,%ebx
  80094a:	c1 e3 18             	shl    $0x18,%ebx
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	c1 e6 10             	shl    $0x10,%esi
  800952:	09 f3                	or     %esi,%ebx
  800954:	09 da                	or     %ebx,%edx
  800956:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800958:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095b:	fc                   	cld    
  80095c:	f3 ab                	rep stos %eax,%es:(%edi)
  80095e:	eb 06                	jmp    800966 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800960:	8b 45 0c             	mov    0xc(%ebp),%eax
  800963:	fc                   	cld    
  800964:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800966:	89 f8                	mov    %edi,%eax
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	57                   	push   %edi
  800971:	56                   	push   %esi
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 75 0c             	mov    0xc(%ebp),%esi
  800978:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097b:	39 c6                	cmp    %eax,%esi
  80097d:	73 32                	jae    8009b1 <memmove+0x44>
  80097f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800982:	39 c2                	cmp    %eax,%edx
  800984:	76 2b                	jbe    8009b1 <memmove+0x44>
		s += n;
		d += n;
  800986:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800989:	89 d6                	mov    %edx,%esi
  80098b:	09 fe                	or     %edi,%esi
  80098d:	09 ce                	or     %ecx,%esi
  80098f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800995:	75 0e                	jne    8009a5 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800997:	83 ef 04             	sub    $0x4,%edi
  80099a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a0:	fd                   	std    
  8009a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a3:	eb 09                	jmp    8009ae <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a5:	83 ef 01             	sub    $0x1,%edi
  8009a8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ae:	fc                   	cld    
  8009af:	eb 1a                	jmp    8009cb <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	89 f2                	mov    %esi,%edx
  8009b3:	09 c2                	or     %eax,%edx
  8009b5:	09 ca                	or     %ecx,%edx
  8009b7:	f6 c2 03             	test   $0x3,%dl
  8009ba:	75 0a                	jne    8009c6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009bf:	89 c7                	mov    %eax,%edi
  8009c1:	fc                   	cld    
  8009c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c4:	eb 05                	jmp    8009cb <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009c6:	89 c7                	mov    %eax,%edi
  8009c8:	fc                   	cld    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009cb:	5e                   	pop    %esi
  8009cc:	5f                   	pop    %edi
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d5:	ff 75 10             	push   0x10(%ebp)
  8009d8:	ff 75 0c             	push   0xc(%ebp)
  8009db:	ff 75 08             	push   0x8(%ebp)
  8009de:	e8 8a ff ff ff       	call   80096d <memmove>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 c6                	mov    %eax,%esi
  8009f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f5:	eb 06                	jmp    8009fd <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009fd:	39 f0                	cmp    %esi,%eax
  8009ff:	74 14                	je     800a15 <memcmp+0x30>
		if (*s1 != *s2)
  800a01:	0f b6 08             	movzbl (%eax),%ecx
  800a04:	0f b6 1a             	movzbl (%edx),%ebx
  800a07:	38 d9                	cmp    %bl,%cl
  800a09:	74 ec                	je     8009f7 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a0b:	0f b6 c1             	movzbl %cl,%eax
  800a0e:	0f b6 db             	movzbl %bl,%ebx
  800a11:	29 d8                	sub    %ebx,%eax
  800a13:	eb 05                	jmp    800a1a <memcmp+0x35>
	}

	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a27:	89 c2                	mov    %eax,%edx
  800a29:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2c:	eb 03                	jmp    800a31 <memfind+0x13>
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	39 d0                	cmp    %edx,%eax
  800a33:	73 04                	jae    800a39 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a35:	38 08                	cmp    %cl,(%eax)
  800a37:	75 f5                	jne    800a2e <memfind+0x10>
			break;
	return (void *) s;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 55 08             	mov    0x8(%ebp),%edx
  800a44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a47:	eb 03                	jmp    800a4c <strtol+0x11>
		s++;
  800a49:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a4c:	0f b6 02             	movzbl (%edx),%eax
  800a4f:	3c 20                	cmp    $0x20,%al
  800a51:	74 f6                	je     800a49 <strtol+0xe>
  800a53:	3c 09                	cmp    $0x9,%al
  800a55:	74 f2                	je     800a49 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a57:	3c 2b                	cmp    $0x2b,%al
  800a59:	74 2a                	je     800a85 <strtol+0x4a>
	int neg = 0;
  800a5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a60:	3c 2d                	cmp    $0x2d,%al
  800a62:	74 2b                	je     800a8f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6a:	75 0f                	jne    800a7b <strtol+0x40>
  800a6c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a6f:	74 28                	je     800a99 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a71:	85 db                	test   %ebx,%ebx
  800a73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a78:	0f 44 d8             	cmove  %eax,%ebx
  800a7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a80:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a83:	eb 46                	jmp    800acb <strtol+0x90>
		s++;
  800a85:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8d:	eb d5                	jmp    800a64 <strtol+0x29>
		s++, neg = 1;
  800a8f:	83 c2 01             	add    $0x1,%edx
  800a92:	bf 01 00 00 00       	mov    $0x1,%edi
  800a97:	eb cb                	jmp    800a64 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9d:	74 0e                	je     800aad <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a9f:	85 db                	test   %ebx,%ebx
  800aa1:	75 d8                	jne    800a7b <strtol+0x40>
		s++, base = 8;
  800aa3:	83 c2 01             	add    $0x1,%edx
  800aa6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aab:	eb ce                	jmp    800a7b <strtol+0x40>
		s += 2, base = 16;
  800aad:	83 c2 02             	add    $0x2,%edx
  800ab0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab5:	eb c4                	jmp    800a7b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ab7:	0f be c0             	movsbl %al,%eax
  800aba:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abd:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ac0:	7d 3a                	jge    800afc <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ac2:	83 c2 01             	add    $0x1,%edx
  800ac5:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ac9:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800acb:	0f b6 02             	movzbl (%edx),%eax
  800ace:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ad1:	89 f3                	mov    %esi,%ebx
  800ad3:	80 fb 09             	cmp    $0x9,%bl
  800ad6:	76 df                	jbe    800ab7 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ad8:	8d 70 9f             	lea    -0x61(%eax),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 08                	ja     800aea <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ae2:	0f be c0             	movsbl %al,%eax
  800ae5:	83 e8 57             	sub    $0x57,%eax
  800ae8:	eb d3                	jmp    800abd <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800aea:	8d 70 bf             	lea    -0x41(%eax),%esi
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	80 fb 19             	cmp    $0x19,%bl
  800af2:	77 08                	ja     800afc <strtol+0xc1>
			dig = *s - 'A' + 10;
  800af4:	0f be c0             	movsbl %al,%eax
  800af7:	83 e8 37             	sub    $0x37,%eax
  800afa:	eb c1                	jmp    800abd <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800afc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b00:	74 05                	je     800b07 <strtol+0xcc>
		*endptr = (char *) s;
  800b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b05:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b07:	89 c8                	mov    %ecx,%eax
  800b09:	f7 d8                	neg    %eax
  800b0b:	85 ff                	test   %edi,%edi
  800b0d:	0f 45 c8             	cmovne %eax,%ecx
}
  800b10:	89 c8                	mov    %ecx,%eax
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	89 c7                	mov    %eax,%edi
  800b2c:	89 c6                	mov    %eax,%esi
  800b2e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	b8 01 00 00 00       	mov    $0x1,%eax
  800b45:	89 d1                	mov    %edx,%ecx
  800b47:	89 d3                	mov    %edx,%ebx
  800b49:	89 d7                	mov    %edx,%edi
  800b4b:	89 d6                	mov    %edx,%esi
  800b4d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
  800b65:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6a:	89 cb                	mov    %ecx,%ebx
  800b6c:	89 cf                	mov    %ecx,%edi
  800b6e:	89 ce                	mov    %ecx,%esi
  800b70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b72:	85 c0                	test   %eax,%eax
  800b74:	7f 08                	jg     800b7e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 03                	push   $0x3
  800b84:	68 44 13 80 00       	push   $0x801344
  800b89:	6a 2a                	push   $0x2a
  800b8b:	68 61 13 80 00       	push   $0x801361
  800b90:	e8 8d f5 ff ff       	call   800122 <_panic>

00800b95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba5:	89 d1                	mov    %edx,%ecx
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	89 d7                	mov    %edx,%edi
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_yield>:

void
sys_yield(void)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bba:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc4:	89 d1                	mov    %edx,%ecx
  800bc6:	89 d3                	mov    %edx,%ebx
  800bc8:	89 d7                	mov    %edx,%edi
  800bca:	89 d6                	mov    %edx,%esi
  800bcc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bdc:	be 00 00 00 00       	mov    $0x0,%esi
  800be1:	8b 55 08             	mov    0x8(%ebp),%edx
  800be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bef:	89 f7                	mov    %esi,%edi
  800bf1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7f 08                	jg     800bff <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 04                	push   $0x4
  800c05:	68 44 13 80 00       	push   $0x801344
  800c0a:	6a 2a                	push   $0x2a
  800c0c:	68 61 13 80 00       	push   $0x801361
  800c11:	e8 0c f5 ff ff       	call   800122 <_panic>

00800c16 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c30:	8b 75 18             	mov    0x18(%ebp),%esi
  800c33:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7f 08                	jg     800c41 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 05                	push   $0x5
  800c47:	68 44 13 80 00       	push   $0x801344
  800c4c:	6a 2a                	push   $0x2a
  800c4e:	68 61 13 80 00       	push   $0x801361
  800c53:	e8 ca f4 ff ff       	call   800122 <_panic>

00800c58 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c71:	89 df                	mov    %ebx,%edi
  800c73:	89 de                	mov    %ebx,%esi
  800c75:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7f 08                	jg     800c83 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 06                	push   $0x6
  800c89:	68 44 13 80 00       	push   $0x801344
  800c8e:	6a 2a                	push   $0x2a
  800c90:	68 61 13 80 00       	push   $0x801361
  800c95:	e8 88 f4 ff ff       	call   800122 <_panic>

00800c9a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb3:	89 df                	mov    %ebx,%edi
  800cb5:	89 de                	mov    %ebx,%esi
  800cb7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7f 08                	jg     800cc5 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 08                	push   $0x8
  800ccb:	68 44 13 80 00       	push   $0x801344
  800cd0:	6a 2a                	push   $0x2a
  800cd2:	68 61 13 80 00       	push   $0x801361
  800cd7:	e8 46 f4 ff ff       	call   800122 <_panic>

00800cdc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf5:	89 df                	mov    %ebx,%edi
  800cf7:	89 de                	mov    %ebx,%esi
  800cf9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7f 08                	jg     800d07 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 09                	push   $0x9
  800d0d:	68 44 13 80 00       	push   $0x801344
  800d12:	6a 2a                	push   $0x2a
  800d14:	68 61 13 80 00       	push   $0x801361
  800d19:	e8 04 f4 ff ff       	call   800122 <_panic>

00800d1e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2f:	be 00 00 00 00       	mov    $0x0,%esi
  800d34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d37:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d57:	89 cb                	mov    %ecx,%ebx
  800d59:	89 cf                	mov    %ecx,%edi
  800d5b:	89 ce                	mov    %ecx,%esi
  800d5d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7f 08                	jg     800d6b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 0c                	push   $0xc
  800d71:	68 44 13 80 00       	push   $0x801344
  800d76:	6a 2a                	push   $0x2a
  800d78:	68 61 13 80 00       	push   $0x801361
  800d7d:	e8 a0 f3 ff ff       	call   800122 <_panic>

00800d82 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800d88:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d8f:	74 0a                	je     800d9b <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800d9b:	e8 f5 fd ff ff       	call   800b95 <sys_getenvid>
  800da0:	83 ec 04             	sub    $0x4,%esp
  800da3:	68 07 0e 00 00       	push   $0xe07
  800da8:	68 00 f0 bf ee       	push   $0xeebff000
  800dad:	50                   	push   %eax
  800dae:	e8 20 fe ff ff       	call   800bd3 <sys_page_alloc>
		if (r < 0) {
  800db3:	83 c4 10             	add    $0x10,%esp
  800db6:	85 c0                	test   %eax,%eax
  800db8:	78 2c                	js     800de6 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800dba:	e8 d6 fd ff ff       	call   800b95 <sys_getenvid>
  800dbf:	83 ec 08             	sub    $0x8,%esp
  800dc2:	68 f8 0d 80 00       	push   $0x800df8
  800dc7:	50                   	push   %eax
  800dc8:	e8 0f ff ff ff       	call   800cdc <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	79 bd                	jns    800d91 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800dd4:	50                   	push   %eax
  800dd5:	68 b0 13 80 00       	push   $0x8013b0
  800dda:	6a 28                	push   $0x28
  800ddc:	68 e6 13 80 00       	push   $0x8013e6
  800de1:	e8 3c f3 ff ff       	call   800122 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800de6:	50                   	push   %eax
  800de7:	68 70 13 80 00       	push   $0x801370
  800dec:	6a 23                	push   $0x23
  800dee:	68 e6 13 80 00       	push   $0x8013e6
  800df3:	e8 2a f3 ff ff       	call   800122 <_panic>

00800df8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800df8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800df9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800dfe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e00:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800e03:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800e07:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800e0a:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800e0e:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800e12:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800e14:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800e17:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800e18:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800e1b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800e1c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800e1d:	c3                   	ret    
  800e1e:	66 90                	xchg   %ax,%ax

00800e20 <__udivdi3>:
  800e20:	f3 0f 1e fb          	endbr32 
  800e24:	55                   	push   %ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	83 ec 1c             	sub    $0x1c,%esp
  800e2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800e2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e33:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	75 19                	jne    800e58 <__udivdi3+0x38>
  800e3f:	39 f3                	cmp    %esi,%ebx
  800e41:	76 4d                	jbe    800e90 <__udivdi3+0x70>
  800e43:	31 ff                	xor    %edi,%edi
  800e45:	89 e8                	mov    %ebp,%eax
  800e47:	89 f2                	mov    %esi,%edx
  800e49:	f7 f3                	div    %ebx
  800e4b:	89 fa                	mov    %edi,%edx
  800e4d:	83 c4 1c             	add    $0x1c,%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
  800e55:	8d 76 00             	lea    0x0(%esi),%esi
  800e58:	39 f0                	cmp    %esi,%eax
  800e5a:	76 14                	jbe    800e70 <__udivdi3+0x50>
  800e5c:	31 ff                	xor    %edi,%edi
  800e5e:	31 c0                	xor    %eax,%eax
  800e60:	89 fa                	mov    %edi,%edx
  800e62:	83 c4 1c             	add    $0x1c,%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    
  800e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e70:	0f bd f8             	bsr    %eax,%edi
  800e73:	83 f7 1f             	xor    $0x1f,%edi
  800e76:	75 48                	jne    800ec0 <__udivdi3+0xa0>
  800e78:	39 f0                	cmp    %esi,%eax
  800e7a:	72 06                	jb     800e82 <__udivdi3+0x62>
  800e7c:	31 c0                	xor    %eax,%eax
  800e7e:	39 eb                	cmp    %ebp,%ebx
  800e80:	77 de                	ja     800e60 <__udivdi3+0x40>
  800e82:	b8 01 00 00 00       	mov    $0x1,%eax
  800e87:	eb d7                	jmp    800e60 <__udivdi3+0x40>
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	89 d9                	mov    %ebx,%ecx
  800e92:	85 db                	test   %ebx,%ebx
  800e94:	75 0b                	jne    800ea1 <__udivdi3+0x81>
  800e96:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	f7 f3                	div    %ebx
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	31 d2                	xor    %edx,%edx
  800ea3:	89 f0                	mov    %esi,%eax
  800ea5:	f7 f1                	div    %ecx
  800ea7:	89 c6                	mov    %eax,%esi
  800ea9:	89 e8                	mov    %ebp,%eax
  800eab:	89 f7                	mov    %esi,%edi
  800ead:	f7 f1                	div    %ecx
  800eaf:	89 fa                	mov    %edi,%edx
  800eb1:	83 c4 1c             	add    $0x1c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	89 f9                	mov    %edi,%ecx
  800ec2:	ba 20 00 00 00       	mov    $0x20,%edx
  800ec7:	29 fa                	sub    %edi,%edx
  800ec9:	d3 e0                	shl    %cl,%eax
  800ecb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ecf:	89 d1                	mov    %edx,%ecx
  800ed1:	89 d8                	mov    %ebx,%eax
  800ed3:	d3 e8                	shr    %cl,%eax
  800ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ed9:	09 c1                	or     %eax,%ecx
  800edb:	89 f0                	mov    %esi,%eax
  800edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee1:	89 f9                	mov    %edi,%ecx
  800ee3:	d3 e3                	shl    %cl,%ebx
  800ee5:	89 d1                	mov    %edx,%ecx
  800ee7:	d3 e8                	shr    %cl,%eax
  800ee9:	89 f9                	mov    %edi,%ecx
  800eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eef:	89 eb                	mov    %ebp,%ebx
  800ef1:	d3 e6                	shl    %cl,%esi
  800ef3:	89 d1                	mov    %edx,%ecx
  800ef5:	d3 eb                	shr    %cl,%ebx
  800ef7:	09 f3                	or     %esi,%ebx
  800ef9:	89 c6                	mov    %eax,%esi
  800efb:	89 f2                	mov    %esi,%edx
  800efd:	89 d8                	mov    %ebx,%eax
  800eff:	f7 74 24 08          	divl   0x8(%esp)
  800f03:	89 d6                	mov    %edx,%esi
  800f05:	89 c3                	mov    %eax,%ebx
  800f07:	f7 64 24 0c          	mull   0xc(%esp)
  800f0b:	39 d6                	cmp    %edx,%esi
  800f0d:	72 19                	jb     800f28 <__udivdi3+0x108>
  800f0f:	89 f9                	mov    %edi,%ecx
  800f11:	d3 e5                	shl    %cl,%ebp
  800f13:	39 c5                	cmp    %eax,%ebp
  800f15:	73 04                	jae    800f1b <__udivdi3+0xfb>
  800f17:	39 d6                	cmp    %edx,%esi
  800f19:	74 0d                	je     800f28 <__udivdi3+0x108>
  800f1b:	89 d8                	mov    %ebx,%eax
  800f1d:	31 ff                	xor    %edi,%edi
  800f1f:	e9 3c ff ff ff       	jmp    800e60 <__udivdi3+0x40>
  800f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f28:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f2b:	31 ff                	xor    %edi,%edi
  800f2d:	e9 2e ff ff ff       	jmp    800e60 <__udivdi3+0x40>
  800f32:	66 90                	xchg   %ax,%ax
  800f34:	66 90                	xchg   %ax,%ax
  800f36:	66 90                	xchg   %ax,%ax
  800f38:	66 90                	xchg   %ax,%ax
  800f3a:	66 90                	xchg   %ax,%ax
  800f3c:	66 90                	xchg   %ax,%ax
  800f3e:	66 90                	xchg   %ax,%ax

00800f40 <__umoddi3>:
  800f40:	f3 0f 1e fb          	endbr32 
  800f44:	55                   	push   %ebp
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
  800f48:	83 ec 1c             	sub    $0x1c,%esp
  800f4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f53:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800f57:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800f5b:	89 f0                	mov    %esi,%eax
  800f5d:	89 da                	mov    %ebx,%edx
  800f5f:	85 ff                	test   %edi,%edi
  800f61:	75 15                	jne    800f78 <__umoddi3+0x38>
  800f63:	39 dd                	cmp    %ebx,%ebp
  800f65:	76 39                	jbe    800fa0 <__umoddi3+0x60>
  800f67:	f7 f5                	div    %ebp
  800f69:	89 d0                	mov    %edx,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	83 c4 1c             	add    $0x1c,%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    
  800f75:	8d 76 00             	lea    0x0(%esi),%esi
  800f78:	39 df                	cmp    %ebx,%edi
  800f7a:	77 f1                	ja     800f6d <__umoddi3+0x2d>
  800f7c:	0f bd cf             	bsr    %edi,%ecx
  800f7f:	83 f1 1f             	xor    $0x1f,%ecx
  800f82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f86:	75 40                	jne    800fc8 <__umoddi3+0x88>
  800f88:	39 df                	cmp    %ebx,%edi
  800f8a:	72 04                	jb     800f90 <__umoddi3+0x50>
  800f8c:	39 f5                	cmp    %esi,%ebp
  800f8e:	77 dd                	ja     800f6d <__umoddi3+0x2d>
  800f90:	89 da                	mov    %ebx,%edx
  800f92:	89 f0                	mov    %esi,%eax
  800f94:	29 e8                	sub    %ebp,%eax
  800f96:	19 fa                	sbb    %edi,%edx
  800f98:	eb d3                	jmp    800f6d <__umoddi3+0x2d>
  800f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa0:	89 e9                	mov    %ebp,%ecx
  800fa2:	85 ed                	test   %ebp,%ebp
  800fa4:	75 0b                	jne    800fb1 <__umoddi3+0x71>
  800fa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	f7 f5                	div    %ebp
  800faf:	89 c1                	mov    %eax,%ecx
  800fb1:	89 d8                	mov    %ebx,%eax
  800fb3:	31 d2                	xor    %edx,%edx
  800fb5:	f7 f1                	div    %ecx
  800fb7:	89 f0                	mov    %esi,%eax
  800fb9:	f7 f1                	div    %ecx
  800fbb:	89 d0                	mov    %edx,%eax
  800fbd:	31 d2                	xor    %edx,%edx
  800fbf:	eb ac                	jmp    800f6d <__umoddi3+0x2d>
  800fc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fcc:	ba 20 00 00 00       	mov    $0x20,%edx
  800fd1:	29 c2                	sub    %eax,%edx
  800fd3:	89 c1                	mov    %eax,%ecx
  800fd5:	89 e8                	mov    %ebp,%eax
  800fd7:	d3 e7                	shl    %cl,%edi
  800fd9:	89 d1                	mov    %edx,%ecx
  800fdb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fdf:	d3 e8                	shr    %cl,%eax
  800fe1:	89 c1                	mov    %eax,%ecx
  800fe3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fe7:	09 f9                	or     %edi,%ecx
  800fe9:	89 df                	mov    %ebx,%edi
  800feb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fef:	89 c1                	mov    %eax,%ecx
  800ff1:	d3 e5                	shl    %cl,%ebp
  800ff3:	89 d1                	mov    %edx,%ecx
  800ff5:	d3 ef                	shr    %cl,%edi
  800ff7:	89 c1                	mov    %eax,%ecx
  800ff9:	89 f0                	mov    %esi,%eax
  800ffb:	d3 e3                	shl    %cl,%ebx
  800ffd:	89 d1                	mov    %edx,%ecx
  800fff:	89 fa                	mov    %edi,%edx
  801001:	d3 e8                	shr    %cl,%eax
  801003:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801008:	09 d8                	or     %ebx,%eax
  80100a:	f7 74 24 08          	divl   0x8(%esp)
  80100e:	89 d3                	mov    %edx,%ebx
  801010:	d3 e6                	shl    %cl,%esi
  801012:	f7 e5                	mul    %ebp
  801014:	89 c7                	mov    %eax,%edi
  801016:	89 d1                	mov    %edx,%ecx
  801018:	39 d3                	cmp    %edx,%ebx
  80101a:	72 06                	jb     801022 <__umoddi3+0xe2>
  80101c:	75 0e                	jne    80102c <__umoddi3+0xec>
  80101e:	39 c6                	cmp    %eax,%esi
  801020:	73 0a                	jae    80102c <__umoddi3+0xec>
  801022:	29 e8                	sub    %ebp,%eax
  801024:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801028:	89 d1                	mov    %edx,%ecx
  80102a:	89 c7                	mov    %eax,%edi
  80102c:	89 f5                	mov    %esi,%ebp
  80102e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801032:	29 fd                	sub    %edi,%ebp
  801034:	19 cb                	sbb    %ecx,%ebx
  801036:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80103b:	89 d8                	mov    %ebx,%eax
  80103d:	d3 e0                	shl    %cl,%eax
  80103f:	89 f1                	mov    %esi,%ecx
  801041:	d3 ed                	shr    %cl,%ebp
  801043:	d3 eb                	shr    %cl,%ebx
  801045:	09 e8                	or     %ebp,%eax
  801047:	89 da                	mov    %ebx,%edx
  801049:	83 c4 1c             	add    $0x1c,%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    
