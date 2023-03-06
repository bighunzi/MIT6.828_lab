
obj/user/faultallocbad：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800045:	e8 9e 01 00 00       	call   8001e8 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 60 0b 00 00       	call   800bbe <sys_page_alloc>
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
  80006e:	e8 fa 06 00 00       	call   80076d <snprintf>
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
  800085:	6a 0f                	push   $0xf
  800087:	68 6a 10 80 00       	push   $0x80106a
  80008c:	e8 7c 00 00 00       	call   80010d <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 cc 0c 00 00       	call   800d6d <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 52 0a 00 00       	call   800b02 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 bb 0a 00 00       	call   800b80 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 37 0a 00 00       	call   800b3f <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800112:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800115:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80011b:	e8 60 0a 00 00       	call   800b80 <sys_getenvid>
  800120:	83 ec 0c             	sub    $0xc,%esp
  800123:	ff 75 0c             	push   0xc(%ebp)
  800126:	ff 75 08             	push   0x8(%ebp)
  800129:	56                   	push   %esi
  80012a:	50                   	push   %eax
  80012b:	68 d8 10 80 00       	push   $0x8010d8
  800130:	e8 b3 00 00 00       	call   8001e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800135:	83 c4 18             	add    $0x18,%esp
  800138:	53                   	push   %ebx
  800139:	ff 75 10             	push   0x10(%ebp)
  80013c:	e8 56 00 00 00       	call   800197 <vcprintf>
	cprintf("\n");
  800141:	c7 04 24 68 10 80 00 	movl   $0x801068,(%esp)
  800148:	e8 9b 00 00 00       	call   8001e8 <cprintf>
  80014d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800150:	cc                   	int3   
  800151:	eb fd                	jmp    800150 <_panic+0x43>

00800153 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 13                	mov    (%ebx),%edx
  80015f:	8d 42 01             	lea    0x1(%edx),%eax
  800162:	89 03                	mov    %eax,(%ebx)
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	74 09                	je     80017b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80017b:	83 ec 08             	sub    $0x8,%esp
  80017e:	68 ff 00 00 00       	push   $0xff
  800183:	8d 43 08             	lea    0x8(%ebx),%eax
  800186:	50                   	push   %eax
  800187:	e8 76 09 00 00       	call   800b02 <sys_cputs>
		b->idx = 0;
  80018c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	eb db                	jmp    800172 <putch+0x1f>

00800197 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a7:	00 00 00 
	b.cnt = 0;
  8001aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b4:	ff 75 0c             	push   0xc(%ebp)
  8001b7:	ff 75 08             	push   0x8(%ebp)
  8001ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c0:	50                   	push   %eax
  8001c1:	68 53 01 80 00       	push   $0x800153
  8001c6:	e8 14 01 00 00       	call   8002df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cb:	83 c4 08             	add    $0x8,%esp
  8001ce:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001da:	50                   	push   %eax
  8001db:	e8 22 09 00 00       	call   800b02 <sys_cputs>

	return b.cnt;
}
  8001e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f1:	50                   	push   %eax
  8001f2:	ff 75 08             	push   0x8(%ebp)
  8001f5:	e8 9d ff ff ff       	call   800197 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	57                   	push   %edi
  800200:	56                   	push   %esi
  800201:	53                   	push   %ebx
  800202:	83 ec 1c             	sub    $0x1c,%esp
  800205:	89 c7                	mov    %eax,%edi
  800207:	89 d6                	mov    %edx,%esi
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020f:	89 d1                	mov    %edx,%ecx
  800211:	89 c2                	mov    %eax,%edx
  800213:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800216:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800219:	8b 45 10             	mov    0x10(%ebp),%eax
  80021c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800222:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800229:	39 c2                	cmp    %eax,%edx
  80022b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80022e:	72 3e                	jb     80026e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	ff 75 18             	push   0x18(%ebp)
  800236:	83 eb 01             	sub    $0x1,%ebx
  800239:	53                   	push   %ebx
  80023a:	50                   	push   %eax
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	ff 75 e4             	push   -0x1c(%ebp)
  800241:	ff 75 e0             	push   -0x20(%ebp)
  800244:	ff 75 dc             	push   -0x24(%ebp)
  800247:	ff 75 d8             	push   -0x28(%ebp)
  80024a:	e8 c1 0b 00 00       	call   800e10 <__udivdi3>
  80024f:	83 c4 18             	add    $0x18,%esp
  800252:	52                   	push   %edx
  800253:	50                   	push   %eax
  800254:	89 f2                	mov    %esi,%edx
  800256:	89 f8                	mov    %edi,%eax
  800258:	e8 9f ff ff ff       	call   8001fc <printnum>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	eb 13                	jmp    800275 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	56                   	push   %esi
  800266:	ff 75 18             	push   0x18(%ebp)
  800269:	ff d7                	call   *%edi
  80026b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80026e:	83 eb 01             	sub    $0x1,%ebx
  800271:	85 db                	test   %ebx,%ebx
  800273:	7f ed                	jg     800262 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800275:	83 ec 08             	sub    $0x8,%esp
  800278:	56                   	push   %esi
  800279:	83 ec 04             	sub    $0x4,%esp
  80027c:	ff 75 e4             	push   -0x1c(%ebp)
  80027f:	ff 75 e0             	push   -0x20(%ebp)
  800282:	ff 75 dc             	push   -0x24(%ebp)
  800285:	ff 75 d8             	push   -0x28(%ebp)
  800288:	e8 a3 0c 00 00       	call   800f30 <__umoddi3>
  80028d:	83 c4 14             	add    $0x14,%esp
  800290:	0f be 80 fb 10 80 00 	movsbl 0x8010fb(%eax),%eax
  800297:	50                   	push   %eax
  800298:	ff d7                	call   *%edi
}
  80029a:	83 c4 10             	add    $0x10,%esp
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b4:	73 0a                	jae    8002c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002be:	88 02                	mov    %al,(%edx)
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <printfmt>:
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 10             	push   0x10(%ebp)
  8002cf:	ff 75 0c             	push   0xc(%ebp)
  8002d2:	ff 75 08             	push   0x8(%ebp)
  8002d5:	e8 05 00 00 00       	call   8002df <vprintfmt>
}
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <vprintfmt>:
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 3c             	sub    $0x3c,%esp
  8002e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f1:	eb 0a                	jmp    8002fd <vprintfmt+0x1e>
			putch(ch, putdat);
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	53                   	push   %ebx
  8002f7:	50                   	push   %eax
  8002f8:	ff d6                	call   *%esi
  8002fa:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fd:	83 c7 01             	add    $0x1,%edi
  800300:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800304:	83 f8 25             	cmp    $0x25,%eax
  800307:	74 0c                	je     800315 <vprintfmt+0x36>
			if (ch == '\0')
  800309:	85 c0                	test   %eax,%eax
  80030b:	75 e6                	jne    8002f3 <vprintfmt+0x14>
}
  80030d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800310:	5b                   	pop    %ebx
  800311:	5e                   	pop    %esi
  800312:	5f                   	pop    %edi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    
		padc = ' ';
  800315:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800319:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800320:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800327:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80032e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8d 47 01             	lea    0x1(%edi),%eax
  800336:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800339:	0f b6 17             	movzbl (%edi),%edx
  80033c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80033f:	3c 55                	cmp    $0x55,%al
  800341:	0f 87 bb 03 00 00    	ja     800702 <vprintfmt+0x423>
  800347:	0f b6 c0             	movzbl %al,%eax
  80034a:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800354:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800358:	eb d9                	jmp    800333 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800361:	eb d0                	jmp    800333 <vprintfmt+0x54>
  800363:	0f b6 d2             	movzbl %dl,%edx
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800369:	b8 00 00 00 00       	mov    $0x0,%eax
  80036e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800371:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800374:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800378:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80037b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80037e:	83 f9 09             	cmp    $0x9,%ecx
  800381:	77 55                	ja     8003d8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800383:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800386:	eb e9                	jmp    800371 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 40 04             	lea    0x4(%eax),%eax
  800396:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80039c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a0:	79 91                	jns    800333 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003af:	eb 82                	jmp    800333 <vprintfmt+0x54>
  8003b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003b4:	85 d2                	test   %edx,%edx
  8003b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bb:	0f 49 c2             	cmovns %edx,%eax
  8003be:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003c4:	e9 6a ff ff ff       	jmp    800333 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003cc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003d3:	e9 5b ff ff ff       	jmp    800333 <vprintfmt+0x54>
  8003d8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003de:	eb bc                	jmp    80039c <vprintfmt+0xbd>
			lflag++;
  8003e0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e6:	e9 48 ff ff ff       	jmp    800333 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 78 04             	lea    0x4(%eax),%edi
  8003f1:	83 ec 08             	sub    $0x8,%esp
  8003f4:	53                   	push   %ebx
  8003f5:	ff 30                	push   (%eax)
  8003f7:	ff d6                	call   *%esi
			break;
  8003f9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003fc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ff:	e9 9d 02 00 00       	jmp    8006a1 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 78 04             	lea    0x4(%eax),%edi
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	89 d0                	mov    %edx,%eax
  80040e:	f7 d8                	neg    %eax
  800410:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800413:	83 f8 08             	cmp    $0x8,%eax
  800416:	7f 23                	jg     80043b <vprintfmt+0x15c>
  800418:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  80041f:	85 d2                	test   %edx,%edx
  800421:	74 18                	je     80043b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800423:	52                   	push   %edx
  800424:	68 1c 11 80 00       	push   $0x80111c
  800429:	53                   	push   %ebx
  80042a:	56                   	push   %esi
  80042b:	e8 92 fe ff ff       	call   8002c2 <printfmt>
  800430:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800433:	89 7d 14             	mov    %edi,0x14(%ebp)
  800436:	e9 66 02 00 00       	jmp    8006a1 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80043b:	50                   	push   %eax
  80043c:	68 13 11 80 00       	push   $0x801113
  800441:	53                   	push   %ebx
  800442:	56                   	push   %esi
  800443:	e8 7a fe ff ff       	call   8002c2 <printfmt>
  800448:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80044b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80044e:	e9 4e 02 00 00       	jmp    8006a1 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	83 c0 04             	add    $0x4,%eax
  800459:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800461:	85 d2                	test   %edx,%edx
  800463:	b8 0c 11 80 00       	mov    $0x80110c,%eax
  800468:	0f 45 c2             	cmovne %edx,%eax
  80046b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80046e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800472:	7e 06                	jle    80047a <vprintfmt+0x19b>
  800474:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800478:	75 0d                	jne    800487 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80047d:	89 c7                	mov    %eax,%edi
  80047f:	03 45 e0             	add    -0x20(%ebp),%eax
  800482:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800485:	eb 55                	jmp    8004dc <vprintfmt+0x1fd>
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 d8             	push   -0x28(%ebp)
  80048d:	ff 75 cc             	push   -0x34(%ebp)
  800490:	e8 0a 03 00 00       	call   80079f <strnlen>
  800495:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800498:	29 c1                	sub    %eax,%ecx
  80049a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004a2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	push   -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1cc>
  8004be:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	0f 49 c2             	cmovns %edx,%eax
  8004cb:	29 c2                	sub    %eax,%edx
  8004cd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004d0:	eb a8                	jmp    80047a <vprintfmt+0x19b>
					putch(ch, putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	52                   	push   %edx
  8004d7:	ff d6                	call   *%esi
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004df:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e1:	83 c7 01             	add    $0x1,%edi
  8004e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e8:	0f be d0             	movsbl %al,%edx
  8004eb:	85 d2                	test   %edx,%edx
  8004ed:	74 4b                	je     80053a <vprintfmt+0x25b>
  8004ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f3:	78 06                	js     8004fb <vprintfmt+0x21c>
  8004f5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004f9:	78 1e                	js     800519 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ff:	74 d1                	je     8004d2 <vprintfmt+0x1f3>
  800501:	0f be c0             	movsbl %al,%eax
  800504:	83 e8 20             	sub    $0x20,%eax
  800507:	83 f8 5e             	cmp    $0x5e,%eax
  80050a:	76 c6                	jbe    8004d2 <vprintfmt+0x1f3>
					putch('?', putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	6a 3f                	push   $0x3f
  800512:	ff d6                	call   *%esi
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	eb c3                	jmp    8004dc <vprintfmt+0x1fd>
  800519:	89 cf                	mov    %ecx,%edi
  80051b:	eb 0e                	jmp    80052b <vprintfmt+0x24c>
				putch(' ', putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	6a 20                	push   $0x20
  800523:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800525:	83 ef 01             	sub    $0x1,%edi
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	85 ff                	test   %edi,%edi
  80052d:	7f ee                	jg     80051d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80052f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800532:	89 45 14             	mov    %eax,0x14(%ebp)
  800535:	e9 67 01 00 00       	jmp    8006a1 <vprintfmt+0x3c2>
  80053a:	89 cf                	mov    %ecx,%edi
  80053c:	eb ed                	jmp    80052b <vprintfmt+0x24c>
	if (lflag >= 2)
  80053e:	83 f9 01             	cmp    $0x1,%ecx
  800541:	7f 1b                	jg     80055e <vprintfmt+0x27f>
	else if (lflag)
  800543:	85 c9                	test   %ecx,%ecx
  800545:	74 63                	je     8005aa <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054f:	99                   	cltd   
  800550:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 40 04             	lea    0x4(%eax),%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
  80055c:	eb 17                	jmp    800575 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8b 50 04             	mov    0x4(%eax),%edx
  800564:	8b 00                	mov    (%eax),%eax
  800566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800569:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 40 08             	lea    0x8(%eax),%eax
  800572:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800575:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800578:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80057b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800580:	85 c9                	test   %ecx,%ecx
  800582:	0f 89 ff 00 00 00    	jns    800687 <vprintfmt+0x3a8>
				putch('-', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 2d                	push   $0x2d
  80058e:	ff d6                	call   *%esi
				num = -(long long) num;
  800590:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800593:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800596:	f7 da                	neg    %edx
  800598:	83 d1 00             	adc    $0x0,%ecx
  80059b:	f7 d9                	neg    %ecx
  80059d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a0:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005a5:	e9 dd 00 00 00       	jmp    800687 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b2:	99                   	cltd   
  8005b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 40 04             	lea    0x4(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bf:	eb b4                	jmp    800575 <vprintfmt+0x296>
	if (lflag >= 2)
  8005c1:	83 f9 01             	cmp    $0x1,%ecx
  8005c4:	7f 1e                	jg     8005e4 <vprintfmt+0x305>
	else if (lflag)
  8005c6:	85 c9                	test   %ecx,%ecx
  8005c8:	74 32                	je     8005fc <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 10                	mov    (%eax),%edx
  8005cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d4:	8d 40 04             	lea    0x4(%eax),%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005da:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005df:	e9 a3 00 00 00       	jmp    800687 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ec:	8d 40 08             	lea    0x8(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005f7:	e9 8b 00 00 00       	jmp    800687 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 10                	mov    (%eax),%edx
  800601:	b9 00 00 00 00       	mov    $0x0,%ecx
  800606:	8d 40 04             	lea    0x4(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800611:	eb 74                	jmp    800687 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800613:	83 f9 01             	cmp    $0x1,%ecx
  800616:	7f 1b                	jg     800633 <vprintfmt+0x354>
	else if (lflag)
  800618:	85 c9                	test   %ecx,%ecx
  80061a:	74 2c                	je     800648 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8b 10                	mov    (%eax),%edx
  800621:	b9 00 00 00 00       	mov    $0x0,%ecx
  800626:	8d 40 04             	lea    0x4(%eax),%eax
  800629:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80062c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800631:	eb 54                	jmp    800687 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 10                	mov    (%eax),%edx
  800638:	8b 48 04             	mov    0x4(%eax),%ecx
  80063b:	8d 40 08             	lea    0x8(%eax),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800641:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800646:	eb 3f                	jmp    800687 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 10                	mov    (%eax),%edx
  80064d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800652:	8d 40 04             	lea    0x4(%eax),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800658:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80065d:	eb 28                	jmp    800687 <vprintfmt+0x3a8>
			putch('0', putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	6a 30                	push   $0x30
  800665:	ff d6                	call   *%esi
			putch('x', putdat);
  800667:	83 c4 08             	add    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 78                	push   $0x78
  80066d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800679:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800682:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800687:	83 ec 0c             	sub    $0xc,%esp
  80068a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80068e:	50                   	push   %eax
  80068f:	ff 75 e0             	push   -0x20(%ebp)
  800692:	57                   	push   %edi
  800693:	51                   	push   %ecx
  800694:	52                   	push   %edx
  800695:	89 da                	mov    %ebx,%edx
  800697:	89 f0                	mov    %esi,%eax
  800699:	e8 5e fb ff ff       	call   8001fc <printnum>
			break;
  80069e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a4:	e9 54 fc ff ff       	jmp    8002fd <vprintfmt+0x1e>
	if (lflag >= 2)
  8006a9:	83 f9 01             	cmp    $0x1,%ecx
  8006ac:	7f 1b                	jg     8006c9 <vprintfmt+0x3ea>
	else if (lflag)
  8006ae:	85 c9                	test   %ecx,%ecx
  8006b0:	74 2c                	je     8006de <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8b 10                	mov    (%eax),%edx
  8006b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bc:	8d 40 04             	lea    0x4(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006c7:	eb be                	jmp    800687 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d1:	8d 40 08             	lea    0x8(%eax),%eax
  8006d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006dc:	eb a9                	jmp    800687 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8b 10                	mov    (%eax),%edx
  8006e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e8:	8d 40 04             	lea    0x4(%eax),%eax
  8006eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ee:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006f3:	eb 92                	jmp    800687 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 25                	push   $0x25
  8006fb:	ff d6                	call   *%esi
			break;
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	eb 9f                	jmp    8006a1 <vprintfmt+0x3c2>
			putch('%', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 25                	push   $0x25
  800708:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	89 f8                	mov    %edi,%eax
  80070f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800713:	74 05                	je     80071a <vprintfmt+0x43b>
  800715:	83 e8 01             	sub    $0x1,%eax
  800718:	eb f5                	jmp    80070f <vprintfmt+0x430>
  80071a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071d:	eb 82                	jmp    8006a1 <vprintfmt+0x3c2>

0080071f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 18             	sub    $0x18,%esp
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800732:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800735:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073c:	85 c0                	test   %eax,%eax
  80073e:	74 26                	je     800766 <vsnprintf+0x47>
  800740:	85 d2                	test   %edx,%edx
  800742:	7e 22                	jle    800766 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800744:	ff 75 14             	push   0x14(%ebp)
  800747:	ff 75 10             	push   0x10(%ebp)
  80074a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074d:	50                   	push   %eax
  80074e:	68 a5 02 80 00       	push   $0x8002a5
  800753:	e8 87 fb ff ff       	call   8002df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800758:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800761:	83 c4 10             	add    $0x10,%esp
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    
		return -E_INVAL;
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076b:	eb f7                	jmp    800764 <vsnprintf+0x45>

0080076d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800776:	50                   	push   %eax
  800777:	ff 75 10             	push   0x10(%ebp)
  80077a:	ff 75 0c             	push   0xc(%ebp)
  80077d:	ff 75 08             	push   0x8(%ebp)
  800780:	e8 9a ff ff ff       	call   80071f <vsnprintf>
	va_end(ap);

	return rc;
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	eb 03                	jmp    800797 <strlen+0x10>
		n++;
  800794:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800797:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079b:	75 f7                	jne    800794 <strlen+0xd>
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ad:	eb 03                	jmp    8007b2 <strnlen+0x13>
		n++;
  8007af:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b2:	39 d0                	cmp    %edx,%eax
  8007b4:	74 08                	je     8007be <strnlen+0x1f>
  8007b6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ba:	75 f3                	jne    8007af <strnlen+0x10>
  8007bc:	89 c2                	mov    %eax,%edx
	return n;
}
  8007be:	89 d0                	mov    %edx,%eax
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007d5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007d8:	83 c0 01             	add    $0x1,%eax
  8007db:	84 d2                	test   %dl,%dl
  8007dd:	75 f2                	jne    8007d1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007df:	89 c8                	mov    %ecx,%eax
  8007e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    

008007e6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	53                   	push   %ebx
  8007ea:	83 ec 10             	sub    $0x10,%esp
  8007ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f0:	53                   	push   %ebx
  8007f1:	e8 91 ff ff ff       	call   800787 <strlen>
  8007f6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007f9:	ff 75 0c             	push   0xc(%ebp)
  8007fc:	01 d8                	add    %ebx,%eax
  8007fe:	50                   	push   %eax
  8007ff:	e8 be ff ff ff       	call   8007c2 <strcpy>
	return dst;
}
  800804:	89 d8                	mov    %ebx,%eax
  800806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
  800816:	89 f3                	mov    %esi,%ebx
  800818:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	89 f0                	mov    %esi,%eax
  80081d:	eb 0f                	jmp    80082e <strncpy+0x23>
		*dst++ = *src;
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	0f b6 0a             	movzbl (%edx),%ecx
  800825:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800828:	80 f9 01             	cmp    $0x1,%cl
  80082b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80082e:	39 d8                	cmp    %ebx,%eax
  800830:	75 ed                	jne    80081f <strncpy+0x14>
	}
	return ret;
}
  800832:	89 f0                	mov    %esi,%eax
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800843:	8b 55 10             	mov    0x10(%ebp),%edx
  800846:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800848:	85 d2                	test   %edx,%edx
  80084a:	74 21                	je     80086d <strlcpy+0x35>
  80084c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800850:	89 f2                	mov    %esi,%edx
  800852:	eb 09                	jmp    80085d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800854:	83 c1 01             	add    $0x1,%ecx
  800857:	83 c2 01             	add    $0x1,%edx
  80085a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80085d:	39 c2                	cmp    %eax,%edx
  80085f:	74 09                	je     80086a <strlcpy+0x32>
  800861:	0f b6 19             	movzbl (%ecx),%ebx
  800864:	84 db                	test   %bl,%bl
  800866:	75 ec                	jne    800854 <strlcpy+0x1c>
  800868:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80086a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086d:	29 f0                	sub    %esi,%eax
}
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087c:	eb 06                	jmp    800884 <strcmp+0x11>
		p++, q++;
  80087e:	83 c1 01             	add    $0x1,%ecx
  800881:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800884:	0f b6 01             	movzbl (%ecx),%eax
  800887:	84 c0                	test   %al,%al
  800889:	74 04                	je     80088f <strcmp+0x1c>
  80088b:	3a 02                	cmp    (%edx),%al
  80088d:	74 ef                	je     80087e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 c0             	movzbl %al,%eax
  800892:	0f b6 12             	movzbl (%edx),%edx
  800895:	29 d0                	sub    %edx,%eax
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a3:	89 c3                	mov    %eax,%ebx
  8008a5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a8:	eb 06                	jmp    8008b0 <strncmp+0x17>
		n--, p++, q++;
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b0:	39 d8                	cmp    %ebx,%eax
  8008b2:	74 18                	je     8008cc <strncmp+0x33>
  8008b4:	0f b6 08             	movzbl (%eax),%ecx
  8008b7:	84 c9                	test   %cl,%cl
  8008b9:	74 04                	je     8008bf <strncmp+0x26>
  8008bb:	3a 0a                	cmp    (%edx),%cl
  8008bd:	74 eb                	je     8008aa <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bf:	0f b6 00             	movzbl (%eax),%eax
  8008c2:	0f b6 12             	movzbl (%edx),%edx
  8008c5:	29 d0                	sub    %edx,%eax
}
  8008c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    
		return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb f4                	jmp    8008c7 <strncmp+0x2e>

008008d3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dd:	eb 03                	jmp    8008e2 <strchr+0xf>
  8008df:	83 c0 01             	add    $0x1,%eax
  8008e2:	0f b6 10             	movzbl (%eax),%edx
  8008e5:	84 d2                	test   %dl,%dl
  8008e7:	74 06                	je     8008ef <strchr+0x1c>
		if (*s == c)
  8008e9:	38 ca                	cmp    %cl,%dl
  8008eb:	75 f2                	jne    8008df <strchr+0xc>
  8008ed:	eb 05                	jmp    8008f4 <strchr+0x21>
			return (char *) s;
	return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800900:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800903:	38 ca                	cmp    %cl,%dl
  800905:	74 09                	je     800910 <strfind+0x1a>
  800907:	84 d2                	test   %dl,%dl
  800909:	74 05                	je     800910 <strfind+0x1a>
	for (; *s; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	eb f0                	jmp    800900 <strfind+0xa>
			break;
	return (char *) s;
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091e:	85 c9                	test   %ecx,%ecx
  800920:	74 2f                	je     800951 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800922:	89 f8                	mov    %edi,%eax
  800924:	09 c8                	or     %ecx,%eax
  800926:	a8 03                	test   $0x3,%al
  800928:	75 21                	jne    80094b <memset+0x39>
		c &= 0xFF;
  80092a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092e:	89 d0                	mov    %edx,%eax
  800930:	c1 e0 08             	shl    $0x8,%eax
  800933:	89 d3                	mov    %edx,%ebx
  800935:	c1 e3 18             	shl    $0x18,%ebx
  800938:	89 d6                	mov    %edx,%esi
  80093a:	c1 e6 10             	shl    $0x10,%esi
  80093d:	09 f3                	or     %esi,%ebx
  80093f:	09 da                	or     %ebx,%edx
  800941:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800943:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800946:	fc                   	cld    
  800947:	f3 ab                	rep stos %eax,%es:(%edi)
  800949:	eb 06                	jmp    800951 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	fc                   	cld    
  80094f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800951:	89 f8                	mov    %edi,%eax
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5f                   	pop    %edi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 75 0c             	mov    0xc(%ebp),%esi
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800966:	39 c6                	cmp    %eax,%esi
  800968:	73 32                	jae    80099c <memmove+0x44>
  80096a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096d:	39 c2                	cmp    %eax,%edx
  80096f:	76 2b                	jbe    80099c <memmove+0x44>
		s += n;
		d += n;
  800971:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	89 d6                	mov    %edx,%esi
  800976:	09 fe                	or     %edi,%esi
  800978:	09 ce                	or     %ecx,%esi
  80097a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800980:	75 0e                	jne    800990 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800982:	83 ef 04             	sub    $0x4,%edi
  800985:	8d 72 fc             	lea    -0x4(%edx),%esi
  800988:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80098b:	fd                   	std    
  80098c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098e:	eb 09                	jmp    800999 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800990:	83 ef 01             	sub    $0x1,%edi
  800993:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800996:	fd                   	std    
  800997:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800999:	fc                   	cld    
  80099a:	eb 1a                	jmp    8009b6 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099c:	89 f2                	mov    %esi,%edx
  80099e:	09 c2                	or     %eax,%edx
  8009a0:	09 ca                	or     %ecx,%edx
  8009a2:	f6 c2 03             	test   $0x3,%dl
  8009a5:	75 0a                	jne    8009b1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 05                	jmp    8009b6 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009b1:	89 c7                	mov    %eax,%edi
  8009b3:	fc                   	cld    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c0:	ff 75 10             	push   0x10(%ebp)
  8009c3:	ff 75 0c             	push   0xc(%ebp)
  8009c6:	ff 75 08             	push   0x8(%ebp)
  8009c9:	e8 8a ff ff ff       	call   800958 <memmove>
}
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009db:	89 c6                	mov    %eax,%esi
  8009dd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e0:	eb 06                	jmp    8009e8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009e8:	39 f0                	cmp    %esi,%eax
  8009ea:	74 14                	je     800a00 <memcmp+0x30>
		if (*s1 != *s2)
  8009ec:	0f b6 08             	movzbl (%eax),%ecx
  8009ef:	0f b6 1a             	movzbl (%edx),%ebx
  8009f2:	38 d9                	cmp    %bl,%cl
  8009f4:	74 ec                	je     8009e2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009f6:	0f b6 c1             	movzbl %cl,%eax
  8009f9:	0f b6 db             	movzbl %bl,%ebx
  8009fc:	29 d8                	sub    %ebx,%eax
  8009fe:	eb 05                	jmp    800a05 <memcmp+0x35>
	}

	return 0;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a05:	5b                   	pop    %ebx
  800a06:	5e                   	pop    %esi
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a12:	89 c2                	mov    %eax,%edx
  800a14:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a17:	eb 03                	jmp    800a1c <memfind+0x13>
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	39 d0                	cmp    %edx,%eax
  800a1e:	73 04                	jae    800a24 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a20:	38 08                	cmp    %cl,(%eax)
  800a22:	75 f5                	jne    800a19 <memfind+0x10>
			break;
	return (void *) s;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a32:	eb 03                	jmp    800a37 <strtol+0x11>
		s++;
  800a34:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a37:	0f b6 02             	movzbl (%edx),%eax
  800a3a:	3c 20                	cmp    $0x20,%al
  800a3c:	74 f6                	je     800a34 <strtol+0xe>
  800a3e:	3c 09                	cmp    $0x9,%al
  800a40:	74 f2                	je     800a34 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a42:	3c 2b                	cmp    $0x2b,%al
  800a44:	74 2a                	je     800a70 <strtol+0x4a>
	int neg = 0;
  800a46:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4b:	3c 2d                	cmp    $0x2d,%al
  800a4d:	74 2b                	je     800a7a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a55:	75 0f                	jne    800a66 <strtol+0x40>
  800a57:	80 3a 30             	cmpb   $0x30,(%edx)
  800a5a:	74 28                	je     800a84 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5c:	85 db                	test   %ebx,%ebx
  800a5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a63:	0f 44 d8             	cmove  %eax,%ebx
  800a66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a6e:	eb 46                	jmp    800ab6 <strtol+0x90>
		s++;
  800a70:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a73:	bf 00 00 00 00       	mov    $0x0,%edi
  800a78:	eb d5                	jmp    800a4f <strtol+0x29>
		s++, neg = 1;
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a82:	eb cb                	jmp    800a4f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a84:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a88:	74 0e                	je     800a98 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a8a:	85 db                	test   %ebx,%ebx
  800a8c:	75 d8                	jne    800a66 <strtol+0x40>
		s++, base = 8;
  800a8e:	83 c2 01             	add    $0x1,%edx
  800a91:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a96:	eb ce                	jmp    800a66 <strtol+0x40>
		s += 2, base = 16;
  800a98:	83 c2 02             	add    $0x2,%edx
  800a9b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa0:	eb c4                	jmp    800a66 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aa2:	0f be c0             	movsbl %al,%eax
  800aa5:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa8:	3b 45 10             	cmp    0x10(%ebp),%eax
  800aab:	7d 3a                	jge    800ae7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800aad:	83 c2 01             	add    $0x1,%edx
  800ab0:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ab4:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ab6:	0f b6 02             	movzbl (%edx),%eax
  800ab9:	8d 70 d0             	lea    -0x30(%eax),%esi
  800abc:	89 f3                	mov    %esi,%ebx
  800abe:	80 fb 09             	cmp    $0x9,%bl
  800ac1:	76 df                	jbe    800aa2 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ac3:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800acd:	0f be c0             	movsbl %al,%eax
  800ad0:	83 e8 57             	sub    $0x57,%eax
  800ad3:	eb d3                	jmp    800aa8 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ad5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 19             	cmp    $0x19,%bl
  800add:	77 08                	ja     800ae7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800adf:	0f be c0             	movsbl %al,%eax
  800ae2:	83 e8 37             	sub    $0x37,%eax
  800ae5:	eb c1                	jmp    800aa8 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aeb:	74 05                	je     800af2 <strtol+0xcc>
		*endptr = (char *) s;
  800aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800af2:	89 c8                	mov    %ecx,%eax
  800af4:	f7 d8                	neg    %eax
  800af6:	85 ff                	test   %edi,%edi
  800af8:	0f 45 c8             	cmovne %eax,%ecx
}
  800afb:	89 c8                	mov    %ecx,%eax
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b13:	89 c3                	mov    %eax,%ebx
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	89 c6                	mov    %eax,%esi
  800b19:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	89 d7                	mov    %edx,%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	b8 03 00 00 00       	mov    $0x3,%eax
  800b55:	89 cb                	mov    %ecx,%ebx
  800b57:	89 cf                	mov    %ecx,%edi
  800b59:	89 ce                	mov    %ecx,%esi
  800b5b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7f 08                	jg     800b69 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	50                   	push   %eax
  800b6d:	6a 03                	push   $0x3
  800b6f:	68 44 13 80 00       	push   $0x801344
  800b74:	6a 2a                	push   $0x2a
  800b76:	68 61 13 80 00       	push   $0x801361
  800b7b:	e8 8d f5 ff ff       	call   80010d <_panic>

00800b80 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b90:	89 d1                	mov    %edx,%ecx
  800b92:	89 d3                	mov    %edx,%ebx
  800b94:	89 d7                	mov    %edx,%edi
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_yield>:

void
sys_yield(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800baf:	89 d1                	mov    %edx,%ecx
  800bb1:	89 d3                	mov    %edx,%ebx
  800bb3:	89 d7                	mov    %edx,%edi
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc7:	be 00 00 00 00       	mov    $0x0,%esi
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bda:	89 f7                	mov    %esi,%edi
  800bdc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7f 08                	jg     800bea <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	50                   	push   %eax
  800bee:	6a 04                	push   $0x4
  800bf0:	68 44 13 80 00       	push   $0x801344
  800bf5:	6a 2a                	push   $0x2a
  800bf7:	68 61 13 80 00       	push   $0x801361
  800bfc:	e8 0c f5 ff ff       	call   80010d <_panic>

00800c01 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	b8 05 00 00 00       	mov    $0x5,%eax
  800c15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7f 08                	jg     800c2c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 05                	push   $0x5
  800c32:	68 44 13 80 00       	push   $0x801344
  800c37:	6a 2a                	push   $0x2a
  800c39:	68 61 13 80 00       	push   $0x801361
  800c3e:	e8 ca f4 ff ff       	call   80010d <_panic>

00800c43 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7f 08                	jg     800c6e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 06                	push   $0x6
  800c74:	68 44 13 80 00       	push   $0x801344
  800c79:	6a 2a                	push   $0x2a
  800c7b:	68 61 13 80 00       	push   $0x801361
  800c80:	e8 88 f4 ff ff       	call   80010d <_panic>

00800c85 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7f 08                	jg     800cb0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 08                	push   $0x8
  800cb6:	68 44 13 80 00       	push   $0x801344
  800cbb:	6a 2a                	push   $0x2a
  800cbd:	68 61 13 80 00       	push   $0x801361
  800cc2:	e8 46 f4 ff ff       	call   80010d <_panic>

00800cc7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7f 08                	jg     800cf2 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 09                	push   $0x9
  800cf8:	68 44 13 80 00       	push   $0x801344
  800cfd:	6a 2a                	push   $0x2a
  800cff:	68 61 13 80 00       	push   $0x801361
  800d04:	e8 04 f4 ff ff       	call   80010d <_panic>

00800d09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d1a:	be 00 00 00 00       	mov    $0x0,%esi
  800d1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d25:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d42:	89 cb                	mov    %ecx,%ebx
  800d44:	89 cf                	mov    %ecx,%edi
  800d46:	89 ce                	mov    %ecx,%esi
  800d48:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7f 08                	jg     800d56 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 0c                	push   $0xc
  800d5c:	68 44 13 80 00       	push   $0x801344
  800d61:	6a 2a                	push   $0x2a
  800d63:	68 61 13 80 00       	push   $0x801361
  800d68:	e8 a0 f3 ff ff       	call   80010d <_panic>

00800d6d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800d73:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d7a:	74 0a                	je     800d86 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d84:	c9                   	leave  
  800d85:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800d86:	e8 f5 fd ff ff       	call   800b80 <sys_getenvid>
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	68 07 0e 00 00       	push   $0xe07
  800d93:	68 00 f0 bf ee       	push   $0xeebff000
  800d98:	50                   	push   %eax
  800d99:	e8 20 fe ff ff       	call   800bbe <sys_page_alloc>
		if (r < 0) {
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	85 c0                	test   %eax,%eax
  800da3:	78 2c                	js     800dd1 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800da5:	e8 d6 fd ff ff       	call   800b80 <sys_getenvid>
  800daa:	83 ec 08             	sub    $0x8,%esp
  800dad:	68 e3 0d 80 00       	push   $0x800de3
  800db2:	50                   	push   %eax
  800db3:	e8 0f ff ff ff       	call   800cc7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800db8:	83 c4 10             	add    $0x10,%esp
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	79 bd                	jns    800d7c <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800dbf:	50                   	push   %eax
  800dc0:	68 b0 13 80 00       	push   $0x8013b0
  800dc5:	6a 28                	push   $0x28
  800dc7:	68 e6 13 80 00       	push   $0x8013e6
  800dcc:	e8 3c f3 ff ff       	call   80010d <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800dd1:	50                   	push   %eax
  800dd2:	68 70 13 80 00       	push   $0x801370
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 e6 13 80 00       	push   $0x8013e6
  800dde:	e8 2a f3 ff ff       	call   80010d <_panic>

00800de3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800de3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800de4:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800de9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800deb:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800dee:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800df2:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800df5:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800df9:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800dfd:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800dff:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800e02:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800e03:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800e06:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800e07:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800e08:	c3                   	ret    
  800e09:	66 90                	xchg   %ax,%ax
  800e0b:	66 90                	xchg   %ax,%ax
  800e0d:	66 90                	xchg   %ax,%ax
  800e0f:	90                   	nop

00800e10 <__udivdi3>:
  800e10:	f3 0f 1e fb          	endbr32 
  800e14:	55                   	push   %ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 1c             	sub    $0x1c,%esp
  800e1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800e1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	75 19                	jne    800e48 <__udivdi3+0x38>
  800e2f:	39 f3                	cmp    %esi,%ebx
  800e31:	76 4d                	jbe    800e80 <__udivdi3+0x70>
  800e33:	31 ff                	xor    %edi,%edi
  800e35:	89 e8                	mov    %ebp,%eax
  800e37:	89 f2                	mov    %esi,%edx
  800e39:	f7 f3                	div    %ebx
  800e3b:	89 fa                	mov    %edi,%edx
  800e3d:	83 c4 1c             	add    $0x1c,%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
  800e48:	39 f0                	cmp    %esi,%eax
  800e4a:	76 14                	jbe    800e60 <__udivdi3+0x50>
  800e4c:	31 ff                	xor    %edi,%edi
  800e4e:	31 c0                	xor    %eax,%eax
  800e50:	89 fa                	mov    %edi,%edx
  800e52:	83 c4 1c             	add    $0x1c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    
  800e5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e60:	0f bd f8             	bsr    %eax,%edi
  800e63:	83 f7 1f             	xor    $0x1f,%edi
  800e66:	75 48                	jne    800eb0 <__udivdi3+0xa0>
  800e68:	39 f0                	cmp    %esi,%eax
  800e6a:	72 06                	jb     800e72 <__udivdi3+0x62>
  800e6c:	31 c0                	xor    %eax,%eax
  800e6e:	39 eb                	cmp    %ebp,%ebx
  800e70:	77 de                	ja     800e50 <__udivdi3+0x40>
  800e72:	b8 01 00 00 00       	mov    $0x1,%eax
  800e77:	eb d7                	jmp    800e50 <__udivdi3+0x40>
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 d9                	mov    %ebx,%ecx
  800e82:	85 db                	test   %ebx,%ebx
  800e84:	75 0b                	jne    800e91 <__udivdi3+0x81>
  800e86:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	f7 f3                	div    %ebx
  800e8f:	89 c1                	mov    %eax,%ecx
  800e91:	31 d2                	xor    %edx,%edx
  800e93:	89 f0                	mov    %esi,%eax
  800e95:	f7 f1                	div    %ecx
  800e97:	89 c6                	mov    %eax,%esi
  800e99:	89 e8                	mov    %ebp,%eax
  800e9b:	89 f7                	mov    %esi,%edi
  800e9d:	f7 f1                	div    %ecx
  800e9f:	89 fa                	mov    %edi,%edx
  800ea1:	83 c4 1c             	add    $0x1c,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 f9                	mov    %edi,%ecx
  800eb2:	ba 20 00 00 00       	mov    $0x20,%edx
  800eb7:	29 fa                	sub    %edi,%edx
  800eb9:	d3 e0                	shl    %cl,%eax
  800ebb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ebf:	89 d1                	mov    %edx,%ecx
  800ec1:	89 d8                	mov    %ebx,%eax
  800ec3:	d3 e8                	shr    %cl,%eax
  800ec5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ec9:	09 c1                	or     %eax,%ecx
  800ecb:	89 f0                	mov    %esi,%eax
  800ecd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	d3 e3                	shl    %cl,%ebx
  800ed5:	89 d1                	mov    %edx,%ecx
  800ed7:	d3 e8                	shr    %cl,%eax
  800ed9:	89 f9                	mov    %edi,%ecx
  800edb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800edf:	89 eb                	mov    %ebp,%ebx
  800ee1:	d3 e6                	shl    %cl,%esi
  800ee3:	89 d1                	mov    %edx,%ecx
  800ee5:	d3 eb                	shr    %cl,%ebx
  800ee7:	09 f3                	or     %esi,%ebx
  800ee9:	89 c6                	mov    %eax,%esi
  800eeb:	89 f2                	mov    %esi,%edx
  800eed:	89 d8                	mov    %ebx,%eax
  800eef:	f7 74 24 08          	divl   0x8(%esp)
  800ef3:	89 d6                	mov    %edx,%esi
  800ef5:	89 c3                	mov    %eax,%ebx
  800ef7:	f7 64 24 0c          	mull   0xc(%esp)
  800efb:	39 d6                	cmp    %edx,%esi
  800efd:	72 19                	jb     800f18 <__udivdi3+0x108>
  800eff:	89 f9                	mov    %edi,%ecx
  800f01:	d3 e5                	shl    %cl,%ebp
  800f03:	39 c5                	cmp    %eax,%ebp
  800f05:	73 04                	jae    800f0b <__udivdi3+0xfb>
  800f07:	39 d6                	cmp    %edx,%esi
  800f09:	74 0d                	je     800f18 <__udivdi3+0x108>
  800f0b:	89 d8                	mov    %ebx,%eax
  800f0d:	31 ff                	xor    %edi,%edi
  800f0f:	e9 3c ff ff ff       	jmp    800e50 <__udivdi3+0x40>
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f1b:	31 ff                	xor    %edi,%edi
  800f1d:	e9 2e ff ff ff       	jmp    800e50 <__udivdi3+0x40>
  800f22:	66 90                	xchg   %ax,%ax
  800f24:	66 90                	xchg   %ax,%ax
  800f26:	66 90                	xchg   %ax,%ax
  800f28:	66 90                	xchg   %ax,%ax
  800f2a:	66 90                	xchg   %ax,%ax
  800f2c:	66 90                	xchg   %ax,%ax
  800f2e:	66 90                	xchg   %ax,%ax

00800f30 <__umoddi3>:
  800f30:	f3 0f 1e fb          	endbr32 
  800f34:	55                   	push   %ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	83 ec 1c             	sub    $0x1c,%esp
  800f3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800f47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800f4b:	89 f0                	mov    %esi,%eax
  800f4d:	89 da                	mov    %ebx,%edx
  800f4f:	85 ff                	test   %edi,%edi
  800f51:	75 15                	jne    800f68 <__umoddi3+0x38>
  800f53:	39 dd                	cmp    %ebx,%ebp
  800f55:	76 39                	jbe    800f90 <__umoddi3+0x60>
  800f57:	f7 f5                	div    %ebp
  800f59:	89 d0                	mov    %edx,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	83 c4 1c             	add    $0x1c,%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    
  800f65:	8d 76 00             	lea    0x0(%esi),%esi
  800f68:	39 df                	cmp    %ebx,%edi
  800f6a:	77 f1                	ja     800f5d <__umoddi3+0x2d>
  800f6c:	0f bd cf             	bsr    %edi,%ecx
  800f6f:	83 f1 1f             	xor    $0x1f,%ecx
  800f72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f76:	75 40                	jne    800fb8 <__umoddi3+0x88>
  800f78:	39 df                	cmp    %ebx,%edi
  800f7a:	72 04                	jb     800f80 <__umoddi3+0x50>
  800f7c:	39 f5                	cmp    %esi,%ebp
  800f7e:	77 dd                	ja     800f5d <__umoddi3+0x2d>
  800f80:	89 da                	mov    %ebx,%edx
  800f82:	89 f0                	mov    %esi,%eax
  800f84:	29 e8                	sub    %ebp,%eax
  800f86:	19 fa                	sbb    %edi,%edx
  800f88:	eb d3                	jmp    800f5d <__umoddi3+0x2d>
  800f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f90:	89 e9                	mov    %ebp,%ecx
  800f92:	85 ed                	test   %ebp,%ebp
  800f94:	75 0b                	jne    800fa1 <__umoddi3+0x71>
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f5                	div    %ebp
  800f9f:	89 c1                	mov    %eax,%ecx
  800fa1:	89 d8                	mov    %ebx,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	f7 f1                	div    %ecx
  800fa7:	89 f0                	mov    %esi,%eax
  800fa9:	f7 f1                	div    %ecx
  800fab:	89 d0                	mov    %edx,%eax
  800fad:	31 d2                	xor    %edx,%edx
  800faf:	eb ac                	jmp    800f5d <__umoddi3+0x2d>
  800fb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fbc:	ba 20 00 00 00       	mov    $0x20,%edx
  800fc1:	29 c2                	sub    %eax,%edx
  800fc3:	89 c1                	mov    %eax,%ecx
  800fc5:	89 e8                	mov    %ebp,%eax
  800fc7:	d3 e7                	shl    %cl,%edi
  800fc9:	89 d1                	mov    %edx,%ecx
  800fcb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fcf:	d3 e8                	shr    %cl,%eax
  800fd1:	89 c1                	mov    %eax,%ecx
  800fd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fd7:	09 f9                	or     %edi,%ecx
  800fd9:	89 df                	mov    %ebx,%edi
  800fdb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fdf:	89 c1                	mov    %eax,%ecx
  800fe1:	d3 e5                	shl    %cl,%ebp
  800fe3:	89 d1                	mov    %edx,%ecx
  800fe5:	d3 ef                	shr    %cl,%edi
  800fe7:	89 c1                	mov    %eax,%ecx
  800fe9:	89 f0                	mov    %esi,%eax
  800feb:	d3 e3                	shl    %cl,%ebx
  800fed:	89 d1                	mov    %edx,%ecx
  800fef:	89 fa                	mov    %edi,%edx
  800ff1:	d3 e8                	shr    %cl,%eax
  800ff3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ff8:	09 d8                	or     %ebx,%eax
  800ffa:	f7 74 24 08          	divl   0x8(%esp)
  800ffe:	89 d3                	mov    %edx,%ebx
  801000:	d3 e6                	shl    %cl,%esi
  801002:	f7 e5                	mul    %ebp
  801004:	89 c7                	mov    %eax,%edi
  801006:	89 d1                	mov    %edx,%ecx
  801008:	39 d3                	cmp    %edx,%ebx
  80100a:	72 06                	jb     801012 <__umoddi3+0xe2>
  80100c:	75 0e                	jne    80101c <__umoddi3+0xec>
  80100e:	39 c6                	cmp    %eax,%esi
  801010:	73 0a                	jae    80101c <__umoddi3+0xec>
  801012:	29 e8                	sub    %ebp,%eax
  801014:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801018:	89 d1                	mov    %edx,%ecx
  80101a:	89 c7                	mov    %eax,%edi
  80101c:	89 f5                	mov    %esi,%ebp
  80101e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801022:	29 fd                	sub    %edi,%ebp
  801024:	19 cb                	sbb    %ecx,%ebx
  801026:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80102b:	89 d8                	mov    %ebx,%eax
  80102d:	d3 e0                	shl    %cl,%eax
  80102f:	89 f1                	mov    %esi,%ecx
  801031:	d3 ed                	shr    %cl,%ebp
  801033:	d3 eb                	shr    %cl,%ebx
  801035:	09 e8                	or     %ebp,%eax
  801037:	89 da                	mov    %ebx,%edx
  801039:	83 c4 1c             	add    $0x1c,%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    
