
obj/user/faultallocbad.debug：     文件格式 elf32-i386


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
  800040:	68 40 23 80 00       	push   $0x802340
  800045:	e8 a6 01 00 00       	call   8001f0 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 68 0b 00 00       	call   800bc6 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 8c 23 80 00       	push   $0x80238c
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 02 07 00 00       	call   800775 <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 60 23 80 00       	push   $0x802360
  800085:	6a 0f                	push   $0xf
  800087:	68 4a 23 80 00       	push   $0x80234a
  80008c:	e8 84 00 00 00       	call   800115 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 77 0d 00 00       	call   800e18 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 5a 0a 00 00       	call   800b0a <sys_cputs>
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
  8000c0:	e8 c3 0a 00 00       	call   800b88 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 7f 0f 00 00       	call   801085 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 37 0a 00 00       	call   800b47 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 60 0a 00 00       	call   800b88 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	push   0xc(%ebp)
  80012e:	ff 75 08             	push   0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 b8 23 80 00       	push   $0x8023b8
  800138:	e8 b3 00 00 00       	call   8001f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	push   0x10(%ebp)
  800144:	e8 56 00 00 00       	call   80019f <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 a4 28 80 00 	movl   $0x8028a4,(%esp)
  800150:	e8 9b 00 00 00       	call   8001f0 <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	74 09                	je     800183 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 76 09 00 00       	call   800b0a <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	eb db                	jmp    80017a <putch+0x1f>

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001af:	00 00 00 
	b.cnt = 0;
  8001b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bc:	ff 75 0c             	push   0xc(%ebp)
  8001bf:	ff 75 08             	push   0x8(%ebp)
  8001c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c8:	50                   	push   %eax
  8001c9:	68 5b 01 80 00       	push   $0x80015b
  8001ce:	e8 14 01 00 00       	call   8002e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d3:	83 c4 08             	add    $0x8,%esp
  8001d6:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	e8 22 09 00 00       	call   800b0a <sys_cputs>

	return b.cnt;
}
  8001e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	50                   	push   %eax
  8001fa:	ff 75 08             	push   0x8(%ebp)
  8001fd:	e8 9d ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	89 c7                	mov    %eax,%edi
  80020f:	89 d6                	mov    %edx,%esi
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 d1                	mov    %edx,%ecx
  800219:	89 c2                	mov    %eax,%edx
  80021b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800221:	8b 45 10             	mov    0x10(%ebp),%eax
  800224:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800227:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800231:	39 c2                	cmp    %eax,%edx
  800233:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800236:	72 3e                	jb     800276 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	ff 75 18             	push   0x18(%ebp)
  80023e:	83 eb 01             	sub    $0x1,%ebx
  800241:	53                   	push   %ebx
  800242:	50                   	push   %eax
  800243:	83 ec 08             	sub    $0x8,%esp
  800246:	ff 75 e4             	push   -0x1c(%ebp)
  800249:	ff 75 e0             	push   -0x20(%ebp)
  80024c:	ff 75 dc             	push   -0x24(%ebp)
  80024f:	ff 75 d8             	push   -0x28(%ebp)
  800252:	e8 a9 1e 00 00       	call   802100 <__udivdi3>
  800257:	83 c4 18             	add    $0x18,%esp
  80025a:	52                   	push   %edx
  80025b:	50                   	push   %eax
  80025c:	89 f2                	mov    %esi,%edx
  80025e:	89 f8                	mov    %edi,%eax
  800260:	e8 9f ff ff ff       	call   800204 <printnum>
  800265:	83 c4 20             	add    $0x20,%esp
  800268:	eb 13                	jmp    80027d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	56                   	push   %esi
  80026e:	ff 75 18             	push   0x18(%ebp)
  800271:	ff d7                	call   *%edi
  800273:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800276:	83 eb 01             	sub    $0x1,%ebx
  800279:	85 db                	test   %ebx,%ebx
  80027b:	7f ed                	jg     80026a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	56                   	push   %esi
  800281:	83 ec 04             	sub    $0x4,%esp
  800284:	ff 75 e4             	push   -0x1c(%ebp)
  800287:	ff 75 e0             	push   -0x20(%ebp)
  80028a:	ff 75 dc             	push   -0x24(%ebp)
  80028d:	ff 75 d8             	push   -0x28(%ebp)
  800290:	e8 8b 1f 00 00       	call   802220 <__umoddi3>
  800295:	83 c4 14             	add    $0x14,%esp
  800298:	0f be 80 db 23 80 00 	movsbl 0x8023db(%eax),%eax
  80029f:	50                   	push   %eax
  8002a0:	ff d7                	call   *%edi
}
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bc:	73 0a                	jae    8002c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	88 02                	mov    %al,(%edx)
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <printfmt>:
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 10             	push   0x10(%ebp)
  8002d7:	ff 75 0c             	push   0xc(%ebp)
  8002da:	ff 75 08             	push   0x8(%ebp)
  8002dd:	e8 05 00 00 00       	call   8002e7 <vprintfmt>
}
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	c9                   	leave  
  8002e6:	c3                   	ret    

008002e7 <vprintfmt>:
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 3c             	sub    $0x3c,%esp
  8002f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f9:	eb 0a                	jmp    800305 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	ff d6                	call   *%esi
  800302:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	83 c7 01             	add    $0x1,%edi
  800308:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	74 0c                	je     80031d <vprintfmt+0x36>
			if (ch == '\0')
  800311:	85 c0                	test   %eax,%eax
  800313:	75 e6                	jne    8002fb <vprintfmt+0x14>
}
  800315:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    
		padc = ' ';
  80031d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800321:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800328:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800336:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8d 47 01             	lea    0x1(%edi),%eax
  80033e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800341:	0f b6 17             	movzbl (%edi),%edx
  800344:	8d 42 dd             	lea    -0x23(%edx),%eax
  800347:	3c 55                	cmp    $0x55,%al
  800349:	0f 87 bb 03 00 00    	ja     80070a <vprintfmt+0x423>
  80034f:	0f b6 c0             	movzbl %al,%eax
  800352:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80035c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800360:	eb d9                	jmp    80033b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800365:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800369:	eb d0                	jmp    80033b <vprintfmt+0x54>
  80036b:	0f b6 d2             	movzbl %dl,%edx
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800383:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800386:	83 f9 09             	cmp    $0x9,%ecx
  800389:	77 55                	ja     8003e0 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8b 00                	mov    (%eax),%eax
  800395:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 40 04             	lea    0x4(%eax),%eax
  80039e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a8:	79 91                	jns    80033b <vprintfmt+0x54>
				width = precision, precision = -1;
  8003aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003b7:	eb 82                	jmp    80033b <vprintfmt+0x54>
  8003b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c3:	0f 49 c2             	cmovns %edx,%eax
  8003c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cc:	e9 6a ff ff ff       	jmp    80033b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003db:	e9 5b ff ff ff       	jmp    80033b <vprintfmt+0x54>
  8003e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e6:	eb bc                	jmp    8003a4 <vprintfmt+0xbd>
			lflag++;
  8003e8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ee:	e9 48 ff ff ff       	jmp    80033b <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 78 04             	lea    0x4(%eax),%edi
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	53                   	push   %ebx
  8003fd:	ff 30                	push   (%eax)
  8003ff:	ff d6                	call   *%esi
			break;
  800401:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800404:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800407:	e9 9d 02 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	8b 10                	mov    (%eax),%edx
  800414:	89 d0                	mov    %edx,%eax
  800416:	f7 d8                	neg    %eax
  800418:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041b:	83 f8 0f             	cmp    $0xf,%eax
  80041e:	7f 23                	jg     800443 <vprintfmt+0x15c>
  800420:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  800427:	85 d2                	test   %edx,%edx
  800429:	74 18                	je     800443 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80042b:	52                   	push   %edx
  80042c:	68 39 28 80 00       	push   $0x802839
  800431:	53                   	push   %ebx
  800432:	56                   	push   %esi
  800433:	e8 92 fe ff ff       	call   8002ca <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80043e:	e9 66 02 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800443:	50                   	push   %eax
  800444:	68 f3 23 80 00       	push   $0x8023f3
  800449:	53                   	push   %ebx
  80044a:	56                   	push   %esi
  80044b:	e8 7a fe ff ff       	call   8002ca <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800453:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800456:	e9 4e 02 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	83 c0 04             	add    $0x4,%eax
  800461:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800469:	85 d2                	test   %edx,%edx
  80046b:	b8 ec 23 80 00       	mov    $0x8023ec,%eax
  800470:	0f 45 c2             	cmovne %edx,%eax
  800473:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800476:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047a:	7e 06                	jle    800482 <vprintfmt+0x19b>
  80047c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800480:	75 0d                	jne    80048f <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800485:	89 c7                	mov    %eax,%edi
  800487:	03 45 e0             	add    -0x20(%ebp),%eax
  80048a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048d:	eb 55                	jmp    8004e4 <vprintfmt+0x1fd>
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 d8             	push   -0x28(%ebp)
  800495:	ff 75 cc             	push   -0x34(%ebp)
  800498:	e8 0a 03 00 00       	call   8007a7 <strnlen>
  80049d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a0:	29 c1                	sub    %eax,%ecx
  8004a2:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004aa:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	eb 0f                	jmp    8004c2 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	ff 75 e0             	push   -0x20(%ebp)
  8004ba:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	83 ef 01             	sub    $0x1,%edi
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 ff                	test   %edi,%edi
  8004c4:	7f ed                	jg     8004b3 <vprintfmt+0x1cc>
  8004c6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c9:	85 d2                	test   %edx,%edx
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	0f 49 c2             	cmovns %edx,%eax
  8004d3:	29 c2                	sub    %eax,%edx
  8004d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004d8:	eb a8                	jmp    800482 <vprintfmt+0x19b>
					putch(ch, putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	53                   	push   %ebx
  8004de:	52                   	push   %edx
  8004df:	ff d6                	call   *%esi
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	0f be d0             	movsbl %al,%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 4b                	je     800542 <vprintfmt+0x25b>
  8004f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fb:	78 06                	js     800503 <vprintfmt+0x21c>
  8004fd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800501:	78 1e                	js     800521 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800503:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800507:	74 d1                	je     8004da <vprintfmt+0x1f3>
  800509:	0f be c0             	movsbl %al,%eax
  80050c:	83 e8 20             	sub    $0x20,%eax
  80050f:	83 f8 5e             	cmp    $0x5e,%eax
  800512:	76 c6                	jbe    8004da <vprintfmt+0x1f3>
					putch('?', putdat);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	53                   	push   %ebx
  800518:	6a 3f                	push   $0x3f
  80051a:	ff d6                	call   *%esi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb c3                	jmp    8004e4 <vprintfmt+0x1fd>
  800521:	89 cf                	mov    %ecx,%edi
  800523:	eb 0e                	jmp    800533 <vprintfmt+0x24c>
				putch(' ', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	53                   	push   %ebx
  800529:	6a 20                	push   $0x20
  80052b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80052d:	83 ef 01             	sub    $0x1,%edi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	85 ff                	test   %edi,%edi
  800535:	7f ee                	jg     800525 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
  80053d:	e9 67 01 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
  800542:	89 cf                	mov    %ecx,%edi
  800544:	eb ed                	jmp    800533 <vprintfmt+0x24c>
	if (lflag >= 2)
  800546:	83 f9 01             	cmp    $0x1,%ecx
  800549:	7f 1b                	jg     800566 <vprintfmt+0x27f>
	else if (lflag)
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	74 63                	je     8005b2 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8b 00                	mov    (%eax),%eax
  800554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800557:	99                   	cltd   
  800558:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 40 04             	lea    0x4(%eax),%eax
  800561:	89 45 14             	mov    %eax,0x14(%ebp)
  800564:	eb 17                	jmp    80057d <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 50 04             	mov    0x4(%eax),%edx
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 08             	lea    0x8(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80057d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800580:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800583:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800588:	85 c9                	test   %ecx,%ecx
  80058a:	0f 89 ff 00 00 00    	jns    80068f <vprintfmt+0x3a8>
				putch('-', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	53                   	push   %ebx
  800594:	6a 2d                	push   $0x2d
  800596:	ff d6                	call   *%esi
				num = -(long long) num;
  800598:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059e:	f7 da                	neg    %edx
  8005a0:	83 d1 00             	adc    $0x0,%ecx
  8005a3:	f7 d9                	neg    %ecx
  8005a5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a8:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005ad:	e9 dd 00 00 00       	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	99                   	cltd   
  8005bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 40 04             	lea    0x4(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c7:	eb b4                	jmp    80057d <vprintfmt+0x296>
	if (lflag >= 2)
  8005c9:	83 f9 01             	cmp    $0x1,%ecx
  8005cc:	7f 1e                	jg     8005ec <vprintfmt+0x305>
	else if (lflag)
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	74 32                	je     800604 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 10                	mov    (%eax),%edx
  8005d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005dc:	8d 40 04             	lea    0x4(%eax),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005e7:	e9 a3 00 00 00       	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 10                	mov    (%eax),%edx
  8005f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f4:	8d 40 08             	lea    0x8(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fa:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005ff:	e9 8b 00 00 00       	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060e:	8d 40 04             	lea    0x4(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800614:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800619:	eb 74                	jmp    80068f <vprintfmt+0x3a8>
	if (lflag >= 2)
  80061b:	83 f9 01             	cmp    $0x1,%ecx
  80061e:	7f 1b                	jg     80063b <vprintfmt+0x354>
	else if (lflag)
  800620:	85 c9                	test   %ecx,%ecx
  800622:	74 2c                	je     800650 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 10                	mov    (%eax),%edx
  800629:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062e:	8d 40 04             	lea    0x4(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800634:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800639:	eb 54                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	8b 48 04             	mov    0x4(%eax),%ecx
  800643:	8d 40 08             	lea    0x8(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800649:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80064e:	eb 3f                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800660:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800665:	eb 28                	jmp    80068f <vprintfmt+0x3a8>
			putch('0', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 30                	push   $0x30
  80066d:	ff d6                	call   *%esi
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 78                	push   $0x78
  800675:	ff d6                	call   *%esi
			num = (unsigned long long)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800681:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800684:	8d 40 04             	lea    0x4(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068a:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800696:	50                   	push   %eax
  800697:	ff 75 e0             	push   -0x20(%ebp)
  80069a:	57                   	push   %edi
  80069b:	51                   	push   %ecx
  80069c:	52                   	push   %edx
  80069d:	89 da                	mov    %ebx,%edx
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	e8 5e fb ff ff       	call   800204 <printnum>
			break;
  8006a6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ac:	e9 54 fc ff ff       	jmp    800305 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006b1:	83 f9 01             	cmp    $0x1,%ecx
  8006b4:	7f 1b                	jg     8006d1 <vprintfmt+0x3ea>
	else if (lflag)
  8006b6:	85 c9                	test   %ecx,%ecx
  8006b8:	74 2c                	je     8006e6 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ca:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006cf:	eb be                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d9:	8d 40 08             	lea    0x8(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006df:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006e4:	eb a9                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f0:	8d 40 04             	lea    0x4(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006fb:	eb 92                	jmp    80068f <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	6a 25                	push   $0x25
  800703:	ff d6                	call   *%esi
			break;
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	eb 9f                	jmp    8006a9 <vprintfmt+0x3c2>
			putch('%', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 25                	push   $0x25
  800710:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	89 f8                	mov    %edi,%eax
  800717:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80071b:	74 05                	je     800722 <vprintfmt+0x43b>
  80071d:	83 e8 01             	sub    $0x1,%eax
  800720:	eb f5                	jmp    800717 <vprintfmt+0x430>
  800722:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800725:	eb 82                	jmp    8006a9 <vprintfmt+0x3c2>

00800727 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 18             	sub    $0x18,%esp
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800733:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800736:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800744:	85 c0                	test   %eax,%eax
  800746:	74 26                	je     80076e <vsnprintf+0x47>
  800748:	85 d2                	test   %edx,%edx
  80074a:	7e 22                	jle    80076e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074c:	ff 75 14             	push   0x14(%ebp)
  80074f:	ff 75 10             	push   0x10(%ebp)
  800752:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800755:	50                   	push   %eax
  800756:	68 ad 02 80 00       	push   $0x8002ad
  80075b:	e8 87 fb ff ff       	call   8002e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800763:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800766:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800769:	83 c4 10             	add    $0x10,%esp
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    
		return -E_INVAL;
  80076e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800773:	eb f7                	jmp    80076c <vsnprintf+0x45>

00800775 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077e:	50                   	push   %eax
  80077f:	ff 75 10             	push   0x10(%ebp)
  800782:	ff 75 0c             	push   0xc(%ebp)
  800785:	ff 75 08             	push   0x8(%ebp)
  800788:	e8 9a ff ff ff       	call   800727 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	eb 03                	jmp    80079f <strlen+0x10>
		n++;
  80079c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80079f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a3:	75 f7                	jne    80079c <strlen+0xd>
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	eb 03                	jmp    8007ba <strnlen+0x13>
		n++;
  8007b7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ba:	39 d0                	cmp    %edx,%eax
  8007bc:	74 08                	je     8007c6 <strnlen+0x1f>
  8007be:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c2:	75 f3                	jne    8007b7 <strnlen+0x10>
  8007c4:	89 c2                	mov    %eax,%edx
	return n;
}
  8007c6:	89 d0                	mov    %edx,%eax
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007dd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e0:	83 c0 01             	add    $0x1,%eax
  8007e3:	84 d2                	test   %dl,%dl
  8007e5:	75 f2                	jne    8007d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e7:	89 c8                	mov    %ecx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	53                   	push   %ebx
  8007f2:	83 ec 10             	sub    $0x10,%esp
  8007f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f8:	53                   	push   %ebx
  8007f9:	e8 91 ff ff ff       	call   80078f <strlen>
  8007fe:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800801:	ff 75 0c             	push   0xc(%ebp)
  800804:	01 d8                	add    %ebx,%eax
  800806:	50                   	push   %eax
  800807:	e8 be ff ff ff       	call   8007ca <strcpy>
	return dst;
}
  80080c:	89 d8                	mov    %ebx,%eax
  80080e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	56                   	push   %esi
  800817:	53                   	push   %ebx
  800818:	8b 75 08             	mov    0x8(%ebp),%esi
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	89 f3                	mov    %esi,%ebx
  800820:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800823:	89 f0                	mov    %esi,%eax
  800825:	eb 0f                	jmp    800836 <strncpy+0x23>
		*dst++ = *src;
  800827:	83 c0 01             	add    $0x1,%eax
  80082a:	0f b6 0a             	movzbl (%edx),%ecx
  80082d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800830:	80 f9 01             	cmp    $0x1,%cl
  800833:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800836:	39 d8                	cmp    %ebx,%eax
  800838:	75 ed                	jne    800827 <strncpy+0x14>
	}
	return ret;
}
  80083a:	89 f0                	mov    %esi,%eax
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	56                   	push   %esi
  800844:	53                   	push   %ebx
  800845:	8b 75 08             	mov    0x8(%ebp),%esi
  800848:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084b:	8b 55 10             	mov    0x10(%ebp),%edx
  80084e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800850:	85 d2                	test   %edx,%edx
  800852:	74 21                	je     800875 <strlcpy+0x35>
  800854:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800858:	89 f2                	mov    %esi,%edx
  80085a:	eb 09                	jmp    800865 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085c:	83 c1 01             	add    $0x1,%ecx
  80085f:	83 c2 01             	add    $0x1,%edx
  800862:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800865:	39 c2                	cmp    %eax,%edx
  800867:	74 09                	je     800872 <strlcpy+0x32>
  800869:	0f b6 19             	movzbl (%ecx),%ebx
  80086c:	84 db                	test   %bl,%bl
  80086e:	75 ec                	jne    80085c <strlcpy+0x1c>
  800870:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800872:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800875:	29 f0                	sub    %esi,%eax
}
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800884:	eb 06                	jmp    80088c <strcmp+0x11>
		p++, q++;
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088c:	0f b6 01             	movzbl (%ecx),%eax
  80088f:	84 c0                	test   %al,%al
  800891:	74 04                	je     800897 <strcmp+0x1c>
  800893:	3a 02                	cmp    (%edx),%al
  800895:	74 ef                	je     800886 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800897:	0f b6 c0             	movzbl %al,%eax
  80089a:	0f b6 12             	movzbl (%edx),%edx
  80089d:	29 d0                	sub    %edx,%eax
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ab:	89 c3                	mov    %eax,%ebx
  8008ad:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b0:	eb 06                	jmp    8008b8 <strncmp+0x17>
		n--, p++, q++;
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b8:	39 d8                	cmp    %ebx,%eax
  8008ba:	74 18                	je     8008d4 <strncmp+0x33>
  8008bc:	0f b6 08             	movzbl (%eax),%ecx
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 04                	je     8008c7 <strncmp+0x26>
  8008c3:	3a 0a                	cmp    (%edx),%cl
  8008c5:	74 eb                	je     8008b2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c7:	0f b6 00             	movzbl (%eax),%eax
  8008ca:	0f b6 12             	movzbl (%edx),%edx
  8008cd:	29 d0                	sub    %edx,%eax
}
  8008cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    
		return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d9:	eb f4                	jmp    8008cf <strncmp+0x2e>

008008db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e5:	eb 03                	jmp    8008ea <strchr+0xf>
  8008e7:	83 c0 01             	add    $0x1,%eax
  8008ea:	0f b6 10             	movzbl (%eax),%edx
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	74 06                	je     8008f7 <strchr+0x1c>
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	75 f2                	jne    8008e7 <strchr+0xc>
  8008f5:	eb 05                	jmp    8008fc <strchr+0x21>
			return (char *) s;
	return 0;
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800908:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	74 09                	je     800918 <strfind+0x1a>
  80090f:	84 d2                	test   %dl,%dl
  800911:	74 05                	je     800918 <strfind+0x1a>
	for (; *s; s++)
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	eb f0                	jmp    800908 <strfind+0xa>
			break;
	return (char *) s;
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 7d 08             	mov    0x8(%ebp),%edi
  800923:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800926:	85 c9                	test   %ecx,%ecx
  800928:	74 2f                	je     800959 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092a:	89 f8                	mov    %edi,%eax
  80092c:	09 c8                	or     %ecx,%eax
  80092e:	a8 03                	test   $0x3,%al
  800930:	75 21                	jne    800953 <memset+0x39>
		c &= 0xFF;
  800932:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800936:	89 d0                	mov    %edx,%eax
  800938:	c1 e0 08             	shl    $0x8,%eax
  80093b:	89 d3                	mov    %edx,%ebx
  80093d:	c1 e3 18             	shl    $0x18,%ebx
  800940:	89 d6                	mov    %edx,%esi
  800942:	c1 e6 10             	shl    $0x10,%esi
  800945:	09 f3                	or     %esi,%ebx
  800947:	09 da                	or     %ebx,%edx
  800949:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80094e:	fc                   	cld    
  80094f:	f3 ab                	rep stos %eax,%es:(%edi)
  800951:	eb 06                	jmp    800959 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	fc                   	cld    
  800957:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800959:	89 f8                	mov    %edi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5f                   	pop    %edi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096e:	39 c6                	cmp    %eax,%esi
  800970:	73 32                	jae    8009a4 <memmove+0x44>
  800972:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800975:	39 c2                	cmp    %eax,%edx
  800977:	76 2b                	jbe    8009a4 <memmove+0x44>
		s += n;
		d += n;
  800979:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	89 d6                	mov    %edx,%esi
  80097e:	09 fe                	or     %edi,%esi
  800980:	09 ce                	or     %ecx,%esi
  800982:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800988:	75 0e                	jne    800998 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098a:	83 ef 04             	sub    $0x4,%edi
  80098d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800990:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800993:	fd                   	std    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 09                	jmp    8009a1 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800998:	83 ef 01             	sub    $0x1,%edi
  80099b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80099e:	fd                   	std    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a1:	fc                   	cld    
  8009a2:	eb 1a                	jmp    8009be <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	89 f2                	mov    %esi,%edx
  8009a6:	09 c2                	or     %eax,%edx
  8009a8:	09 ca                	or     %ecx,%edx
  8009aa:	f6 c2 03             	test   $0x3,%dl
  8009ad:	75 0a                	jne    8009b9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009af:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b7:	eb 05                	jmp    8009be <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c8:	ff 75 10             	push   0x10(%ebp)
  8009cb:	ff 75 0c             	push   0xc(%ebp)
  8009ce:	ff 75 08             	push   0x8(%ebp)
  8009d1:	e8 8a ff ff ff       	call   800960 <memmove>
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e3:	89 c6                	mov    %eax,%esi
  8009e5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e8:	eb 06                	jmp    8009f0 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009f0:	39 f0                	cmp    %esi,%eax
  8009f2:	74 14                	je     800a08 <memcmp+0x30>
		if (*s1 != *s2)
  8009f4:	0f b6 08             	movzbl (%eax),%ecx
  8009f7:	0f b6 1a             	movzbl (%edx),%ebx
  8009fa:	38 d9                	cmp    %bl,%cl
  8009fc:	74 ec                	je     8009ea <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009fe:	0f b6 c1             	movzbl %cl,%eax
  800a01:	0f b6 db             	movzbl %bl,%ebx
  800a04:	29 d8                	sub    %ebx,%eax
  800a06:	eb 05                	jmp    800a0d <memcmp+0x35>
	}

	return 0;
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1a:	89 c2                	mov    %eax,%edx
  800a1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1f:	eb 03                	jmp    800a24 <memfind+0x13>
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	39 d0                	cmp    %edx,%eax
  800a26:	73 04                	jae    800a2c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a28:	38 08                	cmp    %cl,(%eax)
  800a2a:	75 f5                	jne    800a21 <memfind+0x10>
			break;
	return (void *) s;
}
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 55 08             	mov    0x8(%ebp),%edx
  800a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3a:	eb 03                	jmp    800a3f <strtol+0x11>
		s++;
  800a3c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a3f:	0f b6 02             	movzbl (%edx),%eax
  800a42:	3c 20                	cmp    $0x20,%al
  800a44:	74 f6                	je     800a3c <strtol+0xe>
  800a46:	3c 09                	cmp    $0x9,%al
  800a48:	74 f2                	je     800a3c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a4a:	3c 2b                	cmp    $0x2b,%al
  800a4c:	74 2a                	je     800a78 <strtol+0x4a>
	int neg = 0;
  800a4e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a53:	3c 2d                	cmp    $0x2d,%al
  800a55:	74 2b                	je     800a82 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a57:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5d:	75 0f                	jne    800a6e <strtol+0x40>
  800a5f:	80 3a 30             	cmpb   $0x30,(%edx)
  800a62:	74 28                	je     800a8c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a6b:	0f 44 d8             	cmove  %eax,%ebx
  800a6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a73:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a76:	eb 46                	jmp    800abe <strtol+0x90>
		s++;
  800a78:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a80:	eb d5                	jmp    800a57 <strtol+0x29>
		s++, neg = 1;
  800a82:	83 c2 01             	add    $0x1,%edx
  800a85:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8a:	eb cb                	jmp    800a57 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a90:	74 0e                	je     800aa0 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	75 d8                	jne    800a6e <strtol+0x40>
		s++, base = 8;
  800a96:	83 c2 01             	add    $0x1,%edx
  800a99:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a9e:	eb ce                	jmp    800a6e <strtol+0x40>
		s += 2, base = 16;
  800aa0:	83 c2 02             	add    $0x2,%edx
  800aa3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa8:	eb c4                	jmp    800a6e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aaa:	0f be c0             	movsbl %al,%eax
  800aad:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab0:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ab3:	7d 3a                	jge    800aef <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ab5:	83 c2 01             	add    $0x1,%edx
  800ab8:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800abc:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800abe:	0f b6 02             	movzbl (%edx),%eax
  800ac1:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 09             	cmp    $0x9,%bl
  800ac9:	76 df                	jbe    800aaa <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800acb:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ace:	89 f3                	mov    %esi,%ebx
  800ad0:	80 fb 19             	cmp    $0x19,%bl
  800ad3:	77 08                	ja     800add <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ad5:	0f be c0             	movsbl %al,%eax
  800ad8:	83 e8 57             	sub    $0x57,%eax
  800adb:	eb d3                	jmp    800ab0 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800add:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 19             	cmp    $0x19,%bl
  800ae5:	77 08                	ja     800aef <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ae7:	0f be c0             	movsbl %al,%eax
  800aea:	83 e8 37             	sub    $0x37,%eax
  800aed:	eb c1                	jmp    800ab0 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af3:	74 05                	je     800afa <strtol+0xcc>
		*endptr = (char *) s;
  800af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800afa:	89 c8                	mov    %ecx,%eax
  800afc:	f7 d8                	neg    %eax
  800afe:	85 ff                	test   %edi,%edi
  800b00:	0f 45 c8             	cmovne %eax,%ecx
}
  800b03:	89 c8                	mov    %ecx,%eax
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b10:	b8 00 00 00 00       	mov    $0x0,%eax
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1b:	89 c3                	mov    %eax,%ebx
  800b1d:	89 c7                	mov    %eax,%edi
  800b1f:	89 c6                	mov    %eax,%esi
  800b21:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b33:	b8 01 00 00 00       	mov    $0x1,%eax
  800b38:	89 d1                	mov    %edx,%ecx
  800b3a:	89 d3                	mov    %edx,%ebx
  800b3c:	89 d7                	mov    %edx,%edi
  800b3e:	89 d6                	mov    %edx,%esi
  800b40:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5d:	89 cb                	mov    %ecx,%ebx
  800b5f:	89 cf                	mov    %ecx,%edi
  800b61:	89 ce                	mov    %ecx,%esi
  800b63:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b65:	85 c0                	test   %eax,%eax
  800b67:	7f 08                	jg     800b71 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	50                   	push   %eax
  800b75:	6a 03                	push   $0x3
  800b77:	68 df 26 80 00       	push   $0x8026df
  800b7c:	6a 2a                	push   $0x2a
  800b7e:	68 fc 26 80 00       	push   $0x8026fc
  800b83:	e8 8d f5 ff ff       	call   800115 <_panic>

00800b88 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 02 00 00 00       	mov    $0x2,%eax
  800b98:	89 d1                	mov    %edx,%ecx
  800b9a:	89 d3                	mov    %edx,%ebx
  800b9c:	89 d7                	mov    %edx,%edi
  800b9e:	89 d6                	mov    %edx,%esi
  800ba0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_yield>:

void
sys_yield(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb7:	89 d1                	mov    %edx,%ecx
  800bb9:	89 d3                	mov    %edx,%ebx
  800bbb:	89 d7                	mov    %edx,%edi
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcf:	be 00 00 00 00       	mov    $0x0,%esi
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be2:	89 f7                	mov    %esi,%edi
  800be4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be6:	85 c0                	test   %eax,%eax
  800be8:	7f 08                	jg     800bf2 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf2:	83 ec 0c             	sub    $0xc,%esp
  800bf5:	50                   	push   %eax
  800bf6:	6a 04                	push   $0x4
  800bf8:	68 df 26 80 00       	push   $0x8026df
  800bfd:	6a 2a                	push   $0x2a
  800bff:	68 fc 26 80 00       	push   $0x8026fc
  800c04:	e8 0c f5 ff ff       	call   800115 <_panic>

00800c09 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c23:	8b 75 18             	mov    0x18(%ebp),%esi
  800c26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7f 08                	jg     800c34 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	50                   	push   %eax
  800c38:	6a 05                	push   $0x5
  800c3a:	68 df 26 80 00       	push   $0x8026df
  800c3f:	6a 2a                	push   $0x2a
  800c41:	68 fc 26 80 00       	push   $0x8026fc
  800c46:	e8 ca f4 ff ff       	call   800115 <_panic>

00800c4b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c64:	89 df                	mov    %ebx,%edi
  800c66:	89 de                	mov    %ebx,%esi
  800c68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7f 08                	jg     800c76 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c76:	83 ec 0c             	sub    $0xc,%esp
  800c79:	50                   	push   %eax
  800c7a:	6a 06                	push   $0x6
  800c7c:	68 df 26 80 00       	push   $0x8026df
  800c81:	6a 2a                	push   $0x2a
  800c83:	68 fc 26 80 00       	push   $0x8026fc
  800c88:	e8 88 f4 ff ff       	call   800115 <_panic>

00800c8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7f 08                	jg     800cb8 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 08                	push   $0x8
  800cbe:	68 df 26 80 00       	push   $0x8026df
  800cc3:	6a 2a                	push   $0x2a
  800cc5:	68 fc 26 80 00       	push   $0x8026fc
  800cca:	e8 46 f4 ff ff       	call   800115 <_panic>

00800ccf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7f 08                	jg     800cfa <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 09                	push   $0x9
  800d00:	68 df 26 80 00       	push   $0x8026df
  800d05:	6a 2a                	push   $0x2a
  800d07:	68 fc 26 80 00       	push   $0x8026fc
  800d0c:	e8 04 f4 ff ff       	call   800115 <_panic>

00800d11 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2a:	89 df                	mov    %ebx,%edi
  800d2c:	89 de                	mov    %ebx,%esi
  800d2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7f 08                	jg     800d3c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 0a                	push   $0xa
  800d42:	68 df 26 80 00       	push   $0x8026df
  800d47:	6a 2a                	push   $0x2a
  800d49:	68 fc 26 80 00       	push   $0x8026fc
  800d4e:	e8 c2 f3 ff ff       	call   800115 <_panic>

00800d53 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d64:	be 00 00 00 00       	mov    $0x0,%esi
  800d69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d8c:	89 cb                	mov    %ecx,%ebx
  800d8e:	89 cf                	mov    %ecx,%edi
  800d90:	89 ce                	mov    %ecx,%esi
  800d92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d94:	85 c0                	test   %eax,%eax
  800d96:	7f 08                	jg     800da0 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 0d                	push   $0xd
  800da6:	68 df 26 80 00       	push   $0x8026df
  800dab:	6a 2a                	push   $0x2a
  800dad:	68 fc 26 80 00       	push   $0x8026fc
  800db2:	e8 5e f3 ff ff       	call   800115 <_panic>

00800db7 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc7:	89 d1                	mov    %edx,%ecx
  800dc9:	89 d3                	mov    %edx,%ebx
  800dcb:	89 d7                	mov    %edx,%edi
  800dcd:	89 d6                	mov    %edx,%esi
  800dcf:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ddc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dec:	89 df                	mov    %ebx,%edi
  800dee:	89 de                	mov    %ebx,%esi
  800df0:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	b8 10 00 00 00       	mov    $0x10,%eax
  800e0d:	89 df                	mov    %ebx,%edi
  800e0f:	89 de                	mov    %ebx,%esi
  800e11:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800e1e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e25:	74 0a                	je     800e31 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	a3 04 40 80 00       	mov    %eax,0x804004
}
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800e31:	e8 52 fd ff ff       	call   800b88 <sys_getenvid>
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	68 07 0e 00 00       	push   $0xe07
  800e3e:	68 00 f0 bf ee       	push   $0xeebff000
  800e43:	50                   	push   %eax
  800e44:	e8 7d fd ff ff       	call   800bc6 <sys_page_alloc>
		if (r < 0) {
  800e49:	83 c4 10             	add    $0x10,%esp
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	78 2c                	js     800e7c <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800e50:	e8 33 fd ff ff       	call   800b88 <sys_getenvid>
  800e55:	83 ec 08             	sub    $0x8,%esp
  800e58:	68 8e 0e 80 00       	push   $0x800e8e
  800e5d:	50                   	push   %eax
  800e5e:	e8 ae fe ff ff       	call   800d11 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	85 c0                	test   %eax,%eax
  800e68:	79 bd                	jns    800e27 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800e6a:	50                   	push   %eax
  800e6b:	68 4c 27 80 00       	push   $0x80274c
  800e70:	6a 28                	push   $0x28
  800e72:	68 82 27 80 00       	push   $0x802782
  800e77:	e8 99 f2 ff ff       	call   800115 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800e7c:	50                   	push   %eax
  800e7d:	68 0c 27 80 00       	push   $0x80270c
  800e82:	6a 23                	push   $0x23
  800e84:	68 82 27 80 00       	push   $0x802782
  800e89:	e8 87 f2 ff ff       	call   800115 <_panic>

00800e8e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e8e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e8f:	a1 04 40 80 00       	mov    0x804004,%eax
	call *%eax
  800e94:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e96:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800e99:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800e9d:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800ea0:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800ea4:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800ea8:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800eaa:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800ead:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800eae:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800eb1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800eb2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800eb3:	c3                   	ret    

00800eb4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	05 00 00 00 30       	add    $0x30000000,%eax
  800ebf:	c1 e8 0c             	shr    $0xc,%eax
}
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ecf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ed4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ee3:	89 c2                	mov    %eax,%edx
  800ee5:	c1 ea 16             	shr    $0x16,%edx
  800ee8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eef:	f6 c2 01             	test   $0x1,%dl
  800ef2:	74 29                	je     800f1d <fd_alloc+0x42>
  800ef4:	89 c2                	mov    %eax,%edx
  800ef6:	c1 ea 0c             	shr    $0xc,%edx
  800ef9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f00:	f6 c2 01             	test   $0x1,%dl
  800f03:	74 18                	je     800f1d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f05:	05 00 10 00 00       	add    $0x1000,%eax
  800f0a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f0f:	75 d2                	jne    800ee3 <fd_alloc+0x8>
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f16:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f1b:	eb 05                	jmp    800f22 <fd_alloc+0x47>
			return 0;
  800f1d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f22:	8b 55 08             	mov    0x8(%ebp),%edx
  800f25:	89 02                	mov    %eax,(%edx)
}
  800f27:	89 c8                	mov    %ecx,%eax
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f31:	83 f8 1f             	cmp    $0x1f,%eax
  800f34:	77 30                	ja     800f66 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f36:	c1 e0 0c             	shl    $0xc,%eax
  800f39:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f3e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f44:	f6 c2 01             	test   $0x1,%dl
  800f47:	74 24                	je     800f6d <fd_lookup+0x42>
  800f49:	89 c2                	mov    %eax,%edx
  800f4b:	c1 ea 0c             	shr    $0xc,%edx
  800f4e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f55:	f6 c2 01             	test   $0x1,%dl
  800f58:	74 1a                	je     800f74 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5d:	89 02                	mov    %eax,(%edx)
	return 0;
  800f5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    
		return -E_INVAL;
  800f66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6b:	eb f7                	jmp    800f64 <fd_lookup+0x39>
		return -E_INVAL;
  800f6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f72:	eb f0                	jmp    800f64 <fd_lookup+0x39>
  800f74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f79:	eb e9                	jmp    800f64 <fd_lookup+0x39>

00800f7b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	53                   	push   %ebx
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8a:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f8f:	39 13                	cmp    %edx,(%ebx)
  800f91:	74 37                	je     800fca <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f93:	83 c0 01             	add    $0x1,%eax
  800f96:	8b 1c 85 0c 28 80 00 	mov    0x80280c(,%eax,4),%ebx
  800f9d:	85 db                	test   %ebx,%ebx
  800f9f:	75 ee                	jne    800f8f <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fa1:	a1 00 40 80 00       	mov    0x804000,%eax
  800fa6:	8b 40 48             	mov    0x48(%eax),%eax
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	52                   	push   %edx
  800fad:	50                   	push   %eax
  800fae:	68 90 27 80 00       	push   $0x802790
  800fb3:	e8 38 f2 ff ff       	call   8001f0 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800fc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc3:	89 1a                	mov    %ebx,(%edx)
}
  800fc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    
			return 0;
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcf:	eb ef                	jmp    800fc0 <dev_lookup+0x45>

00800fd1 <fd_close>:
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	57                   	push   %edi
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
  800fd7:	83 ec 24             	sub    $0x24,%esp
  800fda:	8b 75 08             	mov    0x8(%ebp),%esi
  800fdd:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fe4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fea:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fed:	50                   	push   %eax
  800fee:	e8 38 ff ff ff       	call   800f2b <fd_lookup>
  800ff3:	89 c3                	mov    %eax,%ebx
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 05                	js     801001 <fd_close+0x30>
	    || fd != fd2)
  800ffc:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fff:	74 16                	je     801017 <fd_close+0x46>
		return (must_exist ? r : 0);
  801001:	89 f8                	mov    %edi,%eax
  801003:	84 c0                	test   %al,%al
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
  80100a:	0f 44 d8             	cmove  %eax,%ebx
}
  80100d:	89 d8                	mov    %ebx,%eax
  80100f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801012:	5b                   	pop    %ebx
  801013:	5e                   	pop    %esi
  801014:	5f                   	pop    %edi
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801017:	83 ec 08             	sub    $0x8,%esp
  80101a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80101d:	50                   	push   %eax
  80101e:	ff 36                	push   (%esi)
  801020:	e8 56 ff ff ff       	call   800f7b <dev_lookup>
  801025:	89 c3                	mov    %eax,%ebx
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	85 c0                	test   %eax,%eax
  80102c:	78 1a                	js     801048 <fd_close+0x77>
		if (dev->dev_close)
  80102e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801031:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801034:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801039:	85 c0                	test   %eax,%eax
  80103b:	74 0b                	je     801048 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	56                   	push   %esi
  801041:	ff d0                	call   *%eax
  801043:	89 c3                	mov    %eax,%ebx
  801045:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801048:	83 ec 08             	sub    $0x8,%esp
  80104b:	56                   	push   %esi
  80104c:	6a 00                	push   $0x0
  80104e:	e8 f8 fb ff ff       	call   800c4b <sys_page_unmap>
	return r;
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	eb b5                	jmp    80100d <fd_close+0x3c>

00801058 <close>:

int
close(int fdnum)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	ff 75 08             	push   0x8(%ebp)
  801065:	e8 c1 fe ff ff       	call   800f2b <fd_lookup>
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	79 02                	jns    801073 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801071:	c9                   	leave  
  801072:	c3                   	ret    
		return fd_close(fd, 1);
  801073:	83 ec 08             	sub    $0x8,%esp
  801076:	6a 01                	push   $0x1
  801078:	ff 75 f4             	push   -0xc(%ebp)
  80107b:	e8 51 ff ff ff       	call   800fd1 <fd_close>
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	eb ec                	jmp    801071 <close+0x19>

00801085 <close_all>:

void
close_all(void)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	53                   	push   %ebx
  801089:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80108c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	53                   	push   %ebx
  801095:	e8 be ff ff ff       	call   801058 <close>
	for (i = 0; i < MAXFD; i++)
  80109a:	83 c3 01             	add    $0x1,%ebx
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	83 fb 20             	cmp    $0x20,%ebx
  8010a3:	75 ec                	jne    801091 <close_all+0xc>
}
  8010a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a8:	c9                   	leave  
  8010a9:	c3                   	ret    

008010aa <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	57                   	push   %edi
  8010ae:	56                   	push   %esi
  8010af:	53                   	push   %ebx
  8010b0:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010b6:	50                   	push   %eax
  8010b7:	ff 75 08             	push   0x8(%ebp)
  8010ba:	e8 6c fe ff ff       	call   800f2b <fd_lookup>
  8010bf:	89 c3                	mov    %eax,%ebx
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 7f                	js     801147 <dup+0x9d>
		return r;
	close(newfdnum);
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	ff 75 0c             	push   0xc(%ebp)
  8010ce:	e8 85 ff ff ff       	call   801058 <close>

	newfd = INDEX2FD(newfdnum);
  8010d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d6:	c1 e6 0c             	shl    $0xc,%esi
  8010d9:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010e2:	89 3c 24             	mov    %edi,(%esp)
  8010e5:	e8 da fd ff ff       	call   800ec4 <fd2data>
  8010ea:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010ec:	89 34 24             	mov    %esi,(%esp)
  8010ef:	e8 d0 fd ff ff       	call   800ec4 <fd2data>
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010fa:	89 d8                	mov    %ebx,%eax
  8010fc:	c1 e8 16             	shr    $0x16,%eax
  8010ff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801106:	a8 01                	test   $0x1,%al
  801108:	74 11                	je     80111b <dup+0x71>
  80110a:	89 d8                	mov    %ebx,%eax
  80110c:	c1 e8 0c             	shr    $0xc,%eax
  80110f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801116:	f6 c2 01             	test   $0x1,%dl
  801119:	75 36                	jne    801151 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80111b:	89 f8                	mov    %edi,%eax
  80111d:	c1 e8 0c             	shr    $0xc,%eax
  801120:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	25 07 0e 00 00       	and    $0xe07,%eax
  80112f:	50                   	push   %eax
  801130:	56                   	push   %esi
  801131:	6a 00                	push   $0x0
  801133:	57                   	push   %edi
  801134:	6a 00                	push   $0x0
  801136:	e8 ce fa ff ff       	call   800c09 <sys_page_map>
  80113b:	89 c3                	mov    %eax,%ebx
  80113d:	83 c4 20             	add    $0x20,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	78 33                	js     801177 <dup+0xcd>
		goto err;

	return newfdnum;
  801144:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801147:	89 d8                	mov    %ebx,%eax
  801149:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801151:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	25 07 0e 00 00       	and    $0xe07,%eax
  801160:	50                   	push   %eax
  801161:	ff 75 d4             	push   -0x2c(%ebp)
  801164:	6a 00                	push   $0x0
  801166:	53                   	push   %ebx
  801167:	6a 00                	push   $0x0
  801169:	e8 9b fa ff ff       	call   800c09 <sys_page_map>
  80116e:	89 c3                	mov    %eax,%ebx
  801170:	83 c4 20             	add    $0x20,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	79 a4                	jns    80111b <dup+0x71>
	sys_page_unmap(0, newfd);
  801177:	83 ec 08             	sub    $0x8,%esp
  80117a:	56                   	push   %esi
  80117b:	6a 00                	push   $0x0
  80117d:	e8 c9 fa ff ff       	call   800c4b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801182:	83 c4 08             	add    $0x8,%esp
  801185:	ff 75 d4             	push   -0x2c(%ebp)
  801188:	6a 00                	push   $0x0
  80118a:	e8 bc fa ff ff       	call   800c4b <sys_page_unmap>
	return r;
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	eb b3                	jmp    801147 <dup+0x9d>

00801194 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 18             	sub    $0x18,%esp
  80119c:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	56                   	push   %esi
  8011a4:	e8 82 fd ff ff       	call   800f2b <fd_lookup>
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	78 3c                	js     8011ec <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	ff 33                	push   (%ebx)
  8011bc:	e8 ba fd ff ff       	call   800f7b <dev_lookup>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 24                	js     8011ec <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011c8:	8b 43 08             	mov    0x8(%ebx),%eax
  8011cb:	83 e0 03             	and    $0x3,%eax
  8011ce:	83 f8 01             	cmp    $0x1,%eax
  8011d1:	74 20                	je     8011f3 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d6:	8b 40 08             	mov    0x8(%eax),%eax
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	74 37                	je     801214 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011dd:	83 ec 04             	sub    $0x4,%esp
  8011e0:	ff 75 10             	push   0x10(%ebp)
  8011e3:	ff 75 0c             	push   0xc(%ebp)
  8011e6:	53                   	push   %ebx
  8011e7:	ff d0                	call   *%eax
  8011e9:	83 c4 10             	add    $0x10,%esp
}
  8011ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f3:	a1 00 40 80 00       	mov    0x804000,%eax
  8011f8:	8b 40 48             	mov    0x48(%eax),%eax
  8011fb:	83 ec 04             	sub    $0x4,%esp
  8011fe:	56                   	push   %esi
  8011ff:	50                   	push   %eax
  801200:	68 d1 27 80 00       	push   $0x8027d1
  801205:	e8 e6 ef ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801212:	eb d8                	jmp    8011ec <read+0x58>
		return -E_NOT_SUPP;
  801214:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801219:	eb d1                	jmp    8011ec <read+0x58>

0080121b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	83 ec 0c             	sub    $0xc,%esp
  801224:	8b 7d 08             	mov    0x8(%ebp),%edi
  801227:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122f:	eb 02                	jmp    801233 <readn+0x18>
  801231:	01 c3                	add    %eax,%ebx
  801233:	39 f3                	cmp    %esi,%ebx
  801235:	73 21                	jae    801258 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801237:	83 ec 04             	sub    $0x4,%esp
  80123a:	89 f0                	mov    %esi,%eax
  80123c:	29 d8                	sub    %ebx,%eax
  80123e:	50                   	push   %eax
  80123f:	89 d8                	mov    %ebx,%eax
  801241:	03 45 0c             	add    0xc(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	57                   	push   %edi
  801246:	e8 49 ff ff ff       	call   801194 <read>
		if (m < 0)
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 04                	js     801256 <readn+0x3b>
			return m;
		if (m == 0)
  801252:	75 dd                	jne    801231 <readn+0x16>
  801254:	eb 02                	jmp    801258 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801256:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801258:	89 d8                	mov    %ebx,%eax
  80125a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	56                   	push   %esi
  801266:	53                   	push   %ebx
  801267:	83 ec 18             	sub    $0x18,%esp
  80126a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801270:	50                   	push   %eax
  801271:	53                   	push   %ebx
  801272:	e8 b4 fc ff ff       	call   800f2b <fd_lookup>
  801277:	83 c4 10             	add    $0x10,%esp
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 37                	js     8012b5 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801287:	50                   	push   %eax
  801288:	ff 36                	push   (%esi)
  80128a:	e8 ec fc ff ff       	call   800f7b <dev_lookup>
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	78 1f                	js     8012b5 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801296:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80129a:	74 20                	je     8012bc <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80129c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129f:	8b 40 0c             	mov    0xc(%eax),%eax
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	74 37                	je     8012dd <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012a6:	83 ec 04             	sub    $0x4,%esp
  8012a9:	ff 75 10             	push   0x10(%ebp)
  8012ac:	ff 75 0c             	push   0xc(%ebp)
  8012af:	56                   	push   %esi
  8012b0:	ff d0                	call   *%eax
  8012b2:	83 c4 10             	add    $0x10,%esp
}
  8012b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012bc:	a1 00 40 80 00       	mov    0x804000,%eax
  8012c1:	8b 40 48             	mov    0x48(%eax),%eax
  8012c4:	83 ec 04             	sub    $0x4,%esp
  8012c7:	53                   	push   %ebx
  8012c8:	50                   	push   %eax
  8012c9:	68 ed 27 80 00       	push   $0x8027ed
  8012ce:	e8 1d ef ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012db:	eb d8                	jmp    8012b5 <write+0x53>
		return -E_NOT_SUPP;
  8012dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e2:	eb d1                	jmp    8012b5 <write+0x53>

008012e4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	ff 75 08             	push   0x8(%ebp)
  8012f1:	e8 35 fc ff ff       	call   800f2b <fd_lookup>
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 0e                	js     80130b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801300:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801303:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801306:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    

0080130d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	56                   	push   %esi
  801311:	53                   	push   %ebx
  801312:	83 ec 18             	sub    $0x18,%esp
  801315:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801318:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	53                   	push   %ebx
  80131d:	e8 09 fc ff ff       	call   800f2b <fd_lookup>
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	85 c0                	test   %eax,%eax
  801327:	78 34                	js     80135d <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801329:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	ff 36                	push   (%esi)
  801335:	e8 41 fc ff ff       	call   800f7b <dev_lookup>
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 1c                	js     80135d <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801341:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801345:	74 1d                	je     801364 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801347:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134a:	8b 40 18             	mov    0x18(%eax),%eax
  80134d:	85 c0                	test   %eax,%eax
  80134f:	74 34                	je     801385 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	ff 75 0c             	push   0xc(%ebp)
  801357:	56                   	push   %esi
  801358:	ff d0                	call   *%eax
  80135a:	83 c4 10             	add    $0x10,%esp
}
  80135d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801360:	5b                   	pop    %ebx
  801361:	5e                   	pop    %esi
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    
			thisenv->env_id, fdnum);
  801364:	a1 00 40 80 00       	mov    0x804000,%eax
  801369:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80136c:	83 ec 04             	sub    $0x4,%esp
  80136f:	53                   	push   %ebx
  801370:	50                   	push   %eax
  801371:	68 b0 27 80 00       	push   $0x8027b0
  801376:	e8 75 ee ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801383:	eb d8                	jmp    80135d <ftruncate+0x50>
		return -E_NOT_SUPP;
  801385:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80138a:	eb d1                	jmp    80135d <ftruncate+0x50>

0080138c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	83 ec 18             	sub    $0x18,%esp
  801394:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801397:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	ff 75 08             	push   0x8(%ebp)
  80139e:	e8 88 fb ff ff       	call   800f2b <fd_lookup>
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	78 49                	js     8013f3 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013aa:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 36                	push   (%esi)
  8013b6:	e8 c0 fb ff ff       	call   800f7b <dev_lookup>
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 31                	js     8013f3 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013c9:	74 2f                	je     8013fa <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013cb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ce:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013d5:	00 00 00 
	stat->st_isdir = 0;
  8013d8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013df:	00 00 00 
	stat->st_dev = dev;
  8013e2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	53                   	push   %ebx
  8013ec:	56                   	push   %esi
  8013ed:	ff 50 14             	call   *0x14(%eax)
  8013f0:	83 c4 10             	add    $0x10,%esp
}
  8013f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f6:	5b                   	pop    %ebx
  8013f7:	5e                   	pop    %esi
  8013f8:	5d                   	pop    %ebp
  8013f9:	c3                   	ret    
		return -E_NOT_SUPP;
  8013fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ff:	eb f2                	jmp    8013f3 <fstat+0x67>

00801401 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	56                   	push   %esi
  801405:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	6a 00                	push   $0x0
  80140b:	ff 75 08             	push   0x8(%ebp)
  80140e:	e8 e4 01 00 00       	call   8015f7 <open>
  801413:	89 c3                	mov    %eax,%ebx
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 1b                	js     801437 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80141c:	83 ec 08             	sub    $0x8,%esp
  80141f:	ff 75 0c             	push   0xc(%ebp)
  801422:	50                   	push   %eax
  801423:	e8 64 ff ff ff       	call   80138c <fstat>
  801428:	89 c6                	mov    %eax,%esi
	close(fd);
  80142a:	89 1c 24             	mov    %ebx,(%esp)
  80142d:	e8 26 fc ff ff       	call   801058 <close>
	return r;
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	89 f3                	mov    %esi,%ebx
}
  801437:	89 d8                	mov    %ebx,%eax
  801439:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143c:	5b                   	pop    %ebx
  80143d:	5e                   	pop    %esi
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	56                   	push   %esi
  801444:	53                   	push   %ebx
  801445:	89 c6                	mov    %eax,%esi
  801447:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801449:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801450:	74 27                	je     801479 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801452:	6a 07                	push   $0x7
  801454:	68 00 50 80 00       	push   $0x805000
  801459:	56                   	push   %esi
  80145a:	ff 35 00 60 80 00    	push   0x806000
  801460:	e8 c4 0b 00 00       	call   802029 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801465:	83 c4 0c             	add    $0xc,%esp
  801468:	6a 00                	push   $0x0
  80146a:	53                   	push   %ebx
  80146b:	6a 00                	push   $0x0
  80146d:	e8 50 0b 00 00       	call   801fc2 <ipc_recv>
}
  801472:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801475:	5b                   	pop    %ebx
  801476:	5e                   	pop    %esi
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801479:	83 ec 0c             	sub    $0xc,%esp
  80147c:	6a 01                	push   $0x1
  80147e:	e8 fa 0b 00 00       	call   80207d <ipc_find_env>
  801483:	a3 00 60 80 00       	mov    %eax,0x806000
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	eb c5                	jmp    801452 <fsipc+0x12>

0080148d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	8b 40 0c             	mov    0xc(%eax),%eax
  801499:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80149e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ab:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b0:	e8 8b ff ff ff       	call   801440 <fsipc>
}
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <devfile_flush>:
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8014d2:	e8 69 ff ff ff       	call   801440 <fsipc>
}
  8014d7:	c9                   	leave  
  8014d8:	c3                   	ret    

008014d9 <devfile_stat>:
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f3:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f8:	e8 43 ff ff ff       	call   801440 <fsipc>
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 2c                	js     80152d <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	68 00 50 80 00       	push   $0x805000
  801509:	53                   	push   %ebx
  80150a:	e8 bb f2 ff ff       	call   8007ca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80150f:	a1 80 50 80 00       	mov    0x805080,%eax
  801514:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80151a:	a1 84 50 80 00       	mov    0x805084,%eax
  80151f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <devfile_write>:
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	8b 45 10             	mov    0x10(%ebp),%eax
  80153b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801540:	39 d0                	cmp    %edx,%eax
  801542:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801545:	8b 55 08             	mov    0x8(%ebp),%edx
  801548:	8b 52 0c             	mov    0xc(%edx),%edx
  80154b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801551:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801556:	50                   	push   %eax
  801557:	ff 75 0c             	push   0xc(%ebp)
  80155a:	68 08 50 80 00       	push   $0x805008
  80155f:	e8 fc f3 ff ff       	call   800960 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801564:	ba 00 00 00 00       	mov    $0x0,%edx
  801569:	b8 04 00 00 00       	mov    $0x4,%eax
  80156e:	e8 cd fe ff ff       	call   801440 <fsipc>
}
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <devfile_read>:
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	56                   	push   %esi
  801579:	53                   	push   %ebx
  80157a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80157d:	8b 45 08             	mov    0x8(%ebp),%eax
  801580:	8b 40 0c             	mov    0xc(%eax),%eax
  801583:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801588:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80158e:	ba 00 00 00 00       	mov    $0x0,%edx
  801593:	b8 03 00 00 00       	mov    $0x3,%eax
  801598:	e8 a3 fe ff ff       	call   801440 <fsipc>
  80159d:	89 c3                	mov    %eax,%ebx
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 1f                	js     8015c2 <devfile_read+0x4d>
	assert(r <= n);
  8015a3:	39 f0                	cmp    %esi,%eax
  8015a5:	77 24                	ja     8015cb <devfile_read+0x56>
	assert(r <= PGSIZE);
  8015a7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015ac:	7f 33                	jg     8015e1 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	50                   	push   %eax
  8015b2:	68 00 50 80 00       	push   $0x805000
  8015b7:	ff 75 0c             	push   0xc(%ebp)
  8015ba:	e8 a1 f3 ff ff       	call   800960 <memmove>
	return r;
  8015bf:	83 c4 10             	add    $0x10,%esp
}
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    
	assert(r <= n);
  8015cb:	68 20 28 80 00       	push   $0x802820
  8015d0:	68 27 28 80 00       	push   $0x802827
  8015d5:	6a 7c                	push   $0x7c
  8015d7:	68 3c 28 80 00       	push   $0x80283c
  8015dc:	e8 34 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  8015e1:	68 47 28 80 00       	push   $0x802847
  8015e6:	68 27 28 80 00       	push   $0x802827
  8015eb:	6a 7d                	push   $0x7d
  8015ed:	68 3c 28 80 00       	push   $0x80283c
  8015f2:	e8 1e eb ff ff       	call   800115 <_panic>

008015f7 <open>:
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	56                   	push   %esi
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 1c             	sub    $0x1c,%esp
  8015ff:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801602:	56                   	push   %esi
  801603:	e8 87 f1 ff ff       	call   80078f <strlen>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801610:	7f 6c                	jg     80167e <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	e8 bd f8 ff ff       	call   800edb <fd_alloc>
  80161e:	89 c3                	mov    %eax,%ebx
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	78 3c                	js     801663 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	56                   	push   %esi
  80162b:	68 00 50 80 00       	push   $0x805000
  801630:	e8 95 f1 ff ff       	call   8007ca <strcpy>
	fsipcbuf.open.req_omode = mode;
  801635:	8b 45 0c             	mov    0xc(%ebp),%eax
  801638:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80163d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801640:	b8 01 00 00 00       	mov    $0x1,%eax
  801645:	e8 f6 fd ff ff       	call   801440 <fsipc>
  80164a:	89 c3                	mov    %eax,%ebx
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 19                	js     80166c <open+0x75>
	return fd2num(fd);
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	ff 75 f4             	push   -0xc(%ebp)
  801659:	e8 56 f8 ff ff       	call   800eb4 <fd2num>
  80165e:	89 c3                	mov    %eax,%ebx
  801660:	83 c4 10             	add    $0x10,%esp
}
  801663:	89 d8                	mov    %ebx,%eax
  801665:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    
		fd_close(fd, 0);
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	6a 00                	push   $0x0
  801671:	ff 75 f4             	push   -0xc(%ebp)
  801674:	e8 58 f9 ff ff       	call   800fd1 <fd_close>
		return r;
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	eb e5                	jmp    801663 <open+0x6c>
		return -E_BAD_PATH;
  80167e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801683:	eb de                	jmp    801663 <open+0x6c>

00801685 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80168b:	ba 00 00 00 00       	mov    $0x0,%edx
  801690:	b8 08 00 00 00       	mov    $0x8,%eax
  801695:	e8 a6 fd ff ff       	call   801440 <fsipc>
}
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016a2:	68 53 28 80 00       	push   $0x802853
  8016a7:	ff 75 0c             	push   0xc(%ebp)
  8016aa:	e8 1b f1 ff ff       	call   8007ca <strcpy>
	return 0;
}
  8016af:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <devsock_close>:
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 10             	sub    $0x10,%esp
  8016bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016c0:	53                   	push   %ebx
  8016c1:	e8 f0 09 00 00       	call   8020b6 <pageref>
  8016c6:	89 c2                	mov    %eax,%edx
  8016c8:	83 c4 10             	add    $0x10,%esp
		return 0;
  8016cb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8016d0:	83 fa 01             	cmp    $0x1,%edx
  8016d3:	74 05                	je     8016da <devsock_close+0x24>
}
  8016d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8016da:	83 ec 0c             	sub    $0xc,%esp
  8016dd:	ff 73 0c             	push   0xc(%ebx)
  8016e0:	e8 b7 02 00 00       	call   80199c <nsipc_close>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	eb eb                	jmp    8016d5 <devsock_close+0x1f>

008016ea <devsock_write>:
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016f0:	6a 00                	push   $0x0
  8016f2:	ff 75 10             	push   0x10(%ebp)
  8016f5:	ff 75 0c             	push   0xc(%ebp)
  8016f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fb:	ff 70 0c             	push   0xc(%eax)
  8016fe:	e8 79 03 00 00       	call   801a7c <nsipc_send>
}
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <devsock_read>:
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80170b:	6a 00                	push   $0x0
  80170d:	ff 75 10             	push   0x10(%ebp)
  801710:	ff 75 0c             	push   0xc(%ebp)
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	ff 70 0c             	push   0xc(%eax)
  801719:	e8 ef 02 00 00       	call   801a0d <nsipc_recv>
}
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <fd2sockid>:
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801726:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801729:	52                   	push   %edx
  80172a:	50                   	push   %eax
  80172b:	e8 fb f7 ff ff       	call   800f2b <fd_lookup>
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	85 c0                	test   %eax,%eax
  801735:	78 10                	js     801747 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801740:	39 08                	cmp    %ecx,(%eax)
  801742:	75 05                	jne    801749 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801744:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801747:	c9                   	leave  
  801748:	c3                   	ret    
		return -E_NOT_SUPP;
  801749:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80174e:	eb f7                	jmp    801747 <fd2sockid+0x27>

00801750 <alloc_sockfd>:
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	56                   	push   %esi
  801754:	53                   	push   %ebx
  801755:	83 ec 1c             	sub    $0x1c,%esp
  801758:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80175a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	e8 78 f7 ff ff       	call   800edb <fd_alloc>
  801763:	89 c3                	mov    %eax,%ebx
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 43                	js     8017af <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80176c:	83 ec 04             	sub    $0x4,%esp
  80176f:	68 07 04 00 00       	push   $0x407
  801774:	ff 75 f4             	push   -0xc(%ebp)
  801777:	6a 00                	push   $0x0
  801779:	e8 48 f4 ff ff       	call   800bc6 <sys_page_alloc>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	78 28                	js     8017af <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801787:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801790:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801795:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80179c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80179f:	83 ec 0c             	sub    $0xc,%esp
  8017a2:	50                   	push   %eax
  8017a3:	e8 0c f7 ff ff       	call   800eb4 <fd2num>
  8017a8:	89 c3                	mov    %eax,%ebx
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	eb 0c                	jmp    8017bb <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	56                   	push   %esi
  8017b3:	e8 e4 01 00 00       	call   80199c <nsipc_close>
		return r;
  8017b8:	83 c4 10             	add    $0x10,%esp
}
  8017bb:	89 d8                	mov    %ebx,%eax
  8017bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c0:	5b                   	pop    %ebx
  8017c1:	5e                   	pop    %esi
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <accept>:
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cd:	e8 4e ff ff ff       	call   801720 <fd2sockid>
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	78 1b                	js     8017f1 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	ff 75 10             	push   0x10(%ebp)
  8017dc:	ff 75 0c             	push   0xc(%ebp)
  8017df:	50                   	push   %eax
  8017e0:	e8 0e 01 00 00       	call   8018f3 <nsipc_accept>
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 05                	js     8017f1 <accept+0x2d>
	return alloc_sockfd(r);
  8017ec:	e8 5f ff ff ff       	call   801750 <alloc_sockfd>
}
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <bind>:
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fc:	e8 1f ff ff ff       	call   801720 <fd2sockid>
  801801:	85 c0                	test   %eax,%eax
  801803:	78 12                	js     801817 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801805:	83 ec 04             	sub    $0x4,%esp
  801808:	ff 75 10             	push   0x10(%ebp)
  80180b:	ff 75 0c             	push   0xc(%ebp)
  80180e:	50                   	push   %eax
  80180f:	e8 31 01 00 00       	call   801945 <nsipc_bind>
  801814:	83 c4 10             	add    $0x10,%esp
}
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <shutdown>:
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
  801822:	e8 f9 fe ff ff       	call   801720 <fd2sockid>
  801827:	85 c0                	test   %eax,%eax
  801829:	78 0f                	js     80183a <shutdown+0x21>
	return nsipc_shutdown(r, how);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	ff 75 0c             	push   0xc(%ebp)
  801831:	50                   	push   %eax
  801832:	e8 43 01 00 00       	call   80197a <nsipc_shutdown>
  801837:	83 c4 10             	add    $0x10,%esp
}
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <connect>:
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	e8 d6 fe ff ff       	call   801720 <fd2sockid>
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 12                	js     801860 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  80184e:	83 ec 04             	sub    $0x4,%esp
  801851:	ff 75 10             	push   0x10(%ebp)
  801854:	ff 75 0c             	push   0xc(%ebp)
  801857:	50                   	push   %eax
  801858:	e8 59 01 00 00       	call   8019b6 <nsipc_connect>
  80185d:	83 c4 10             	add    $0x10,%esp
}
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <listen>:
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801868:	8b 45 08             	mov    0x8(%ebp),%eax
  80186b:	e8 b0 fe ff ff       	call   801720 <fd2sockid>
  801870:	85 c0                	test   %eax,%eax
  801872:	78 0f                	js     801883 <listen+0x21>
	return nsipc_listen(r, backlog);
  801874:	83 ec 08             	sub    $0x8,%esp
  801877:	ff 75 0c             	push   0xc(%ebp)
  80187a:	50                   	push   %eax
  80187b:	e8 6b 01 00 00       	call   8019eb <nsipc_listen>
  801880:	83 c4 10             	add    $0x10,%esp
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <socket>:

int
socket(int domain, int type, int protocol)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80188b:	ff 75 10             	push   0x10(%ebp)
  80188e:	ff 75 0c             	push   0xc(%ebp)
  801891:	ff 75 08             	push   0x8(%ebp)
  801894:	e8 41 02 00 00       	call   801ada <nsipc_socket>
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 05                	js     8018a5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018a0:	e8 ab fe ff ff       	call   801750 <alloc_sockfd>
}
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018b0:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8018b7:	74 26                	je     8018df <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018b9:	6a 07                	push   $0x7
  8018bb:	68 00 70 80 00       	push   $0x807000
  8018c0:	53                   	push   %ebx
  8018c1:	ff 35 00 80 80 00    	push   0x808000
  8018c7:	e8 5d 07 00 00       	call   802029 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018cc:	83 c4 0c             	add    $0xc,%esp
  8018cf:	6a 00                	push   $0x0
  8018d1:	6a 00                	push   $0x0
  8018d3:	6a 00                	push   $0x0
  8018d5:	e8 e8 06 00 00       	call   801fc2 <ipc_recv>
}
  8018da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018df:	83 ec 0c             	sub    $0xc,%esp
  8018e2:	6a 02                	push   $0x2
  8018e4:	e8 94 07 00 00       	call   80207d <ipc_find_env>
  8018e9:	a3 00 80 80 00       	mov    %eax,0x808000
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	eb c6                	jmp    8018b9 <nsipc+0x12>

008018f3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	56                   	push   %esi
  8018f7:	53                   	push   %ebx
  8018f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801903:	8b 06                	mov    (%esi),%eax
  801905:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80190a:	b8 01 00 00 00       	mov    $0x1,%eax
  80190f:	e8 93 ff ff ff       	call   8018a7 <nsipc>
  801914:	89 c3                	mov    %eax,%ebx
  801916:	85 c0                	test   %eax,%eax
  801918:	79 09                	jns    801923 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80191a:	89 d8                	mov    %ebx,%eax
  80191c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191f:	5b                   	pop    %ebx
  801920:	5e                   	pop    %esi
  801921:	5d                   	pop    %ebp
  801922:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801923:	83 ec 04             	sub    $0x4,%esp
  801926:	ff 35 10 70 80 00    	push   0x807010
  80192c:	68 00 70 80 00       	push   $0x807000
  801931:	ff 75 0c             	push   0xc(%ebp)
  801934:	e8 27 f0 ff ff       	call   800960 <memmove>
		*addrlen = ret->ret_addrlen;
  801939:	a1 10 70 80 00       	mov    0x807010,%eax
  80193e:	89 06                	mov    %eax,(%esi)
  801940:	83 c4 10             	add    $0x10,%esp
	return r;
  801943:	eb d5                	jmp    80191a <nsipc_accept+0x27>

00801945 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	53                   	push   %ebx
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80194f:	8b 45 08             	mov    0x8(%ebp),%eax
  801952:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801957:	53                   	push   %ebx
  801958:	ff 75 0c             	push   0xc(%ebp)
  80195b:	68 04 70 80 00       	push   $0x807004
  801960:	e8 fb ef ff ff       	call   800960 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801965:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80196b:	b8 02 00 00 00       	mov    $0x2,%eax
  801970:	e8 32 ff ff ff       	call   8018a7 <nsipc>
}
  801975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801980:	8b 45 08             	mov    0x8(%ebp),%eax
  801983:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801988:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801990:	b8 03 00 00 00       	mov    $0x3,%eax
  801995:	e8 0d ff ff ff       	call   8018a7 <nsipc>
}
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <nsipc_close>:

int
nsipc_close(int s)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a5:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8019aa:	b8 04 00 00 00       	mov    $0x4,%eax
  8019af:	e8 f3 fe ff ff       	call   8018a7 <nsipc>
}
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	53                   	push   %ebx
  8019ba:	83 ec 08             	sub    $0x8,%esp
  8019bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c3:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019c8:	53                   	push   %ebx
  8019c9:	ff 75 0c             	push   0xc(%ebp)
  8019cc:	68 04 70 80 00       	push   $0x807004
  8019d1:	e8 8a ef ff ff       	call   800960 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019d6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8019dc:	b8 05 00 00 00       	mov    $0x5,%eax
  8019e1:	e8 c1 fe ff ff       	call   8018a7 <nsipc>
}
  8019e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e9:	c9                   	leave  
  8019ea:	c3                   	ret    

008019eb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8019f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fc:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801a01:	b8 06 00 00 00       	mov    $0x6,%eax
  801a06:	e8 9c fe ff ff       	call   8018a7 <nsipc>
}
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a15:	8b 45 08             	mov    0x8(%ebp),%eax
  801a18:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801a1d:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801a23:	8b 45 14             	mov    0x14(%ebp),%eax
  801a26:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a2b:	b8 07 00 00 00       	mov    $0x7,%eax
  801a30:	e8 72 fe ff ff       	call   8018a7 <nsipc>
  801a35:	89 c3                	mov    %eax,%ebx
  801a37:	85 c0                	test   %eax,%eax
  801a39:	78 22                	js     801a5d <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801a3b:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801a40:	39 c6                	cmp    %eax,%esi
  801a42:	0f 4e c6             	cmovle %esi,%eax
  801a45:	39 c3                	cmp    %eax,%ebx
  801a47:	7f 1d                	jg     801a66 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a49:	83 ec 04             	sub    $0x4,%esp
  801a4c:	53                   	push   %ebx
  801a4d:	68 00 70 80 00       	push   $0x807000
  801a52:	ff 75 0c             	push   0xc(%ebp)
  801a55:	e8 06 ef ff ff       	call   800960 <memmove>
  801a5a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a5d:	89 d8                	mov    %ebx,%eax
  801a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801a66:	68 5f 28 80 00       	push   $0x80285f
  801a6b:	68 27 28 80 00       	push   $0x802827
  801a70:	6a 62                	push   $0x62
  801a72:	68 74 28 80 00       	push   $0x802874
  801a77:	e8 99 e6 ff ff       	call   800115 <_panic>

00801a7c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	53                   	push   %ebx
  801a80:	83 ec 04             	sub    $0x4,%esp
  801a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a86:	8b 45 08             	mov    0x8(%ebp),%eax
  801a89:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801a8e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a94:	7f 2e                	jg     801ac4 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a96:	83 ec 04             	sub    $0x4,%esp
  801a99:	53                   	push   %ebx
  801a9a:	ff 75 0c             	push   0xc(%ebp)
  801a9d:	68 0c 70 80 00       	push   $0x80700c
  801aa2:	e8 b9 ee ff ff       	call   800960 <memmove>
	nsipcbuf.send.req_size = size;
  801aa7:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801aad:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801ab5:	b8 08 00 00 00       	mov    $0x8,%eax
  801aba:	e8 e8 fd ff ff       	call   8018a7 <nsipc>
}
  801abf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac2:	c9                   	leave  
  801ac3:	c3                   	ret    
	assert(size < 1600);
  801ac4:	68 80 28 80 00       	push   $0x802880
  801ac9:	68 27 28 80 00       	push   $0x802827
  801ace:	6a 6d                	push   $0x6d
  801ad0:	68 74 28 80 00       	push   $0x802874
  801ad5:	e8 3b e6 ff ff       	call   800115 <_panic>

00801ada <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aeb:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801af0:	8b 45 10             	mov    0x10(%ebp),%eax
  801af3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801af8:	b8 09 00 00 00       	mov    $0x9,%eax
  801afd:	e8 a5 fd ff ff       	call   8018a7 <nsipc>
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	56                   	push   %esi
  801b08:	53                   	push   %ebx
  801b09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b0c:	83 ec 0c             	sub    $0xc,%esp
  801b0f:	ff 75 08             	push   0x8(%ebp)
  801b12:	e8 ad f3 ff ff       	call   800ec4 <fd2data>
  801b17:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b19:	83 c4 08             	add    $0x8,%esp
  801b1c:	68 8c 28 80 00       	push   $0x80288c
  801b21:	53                   	push   %ebx
  801b22:	e8 a3 ec ff ff       	call   8007ca <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b27:	8b 46 04             	mov    0x4(%esi),%eax
  801b2a:	2b 06                	sub    (%esi),%eax
  801b2c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b32:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b39:	00 00 00 
	stat->st_dev = &devpipe;
  801b3c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b43:	30 80 00 
	return 0;
}
  801b46:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5e                   	pop    %esi
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	53                   	push   %ebx
  801b56:	83 ec 0c             	sub    $0xc,%esp
  801b59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b5c:	53                   	push   %ebx
  801b5d:	6a 00                	push   $0x0
  801b5f:	e8 e7 f0 ff ff       	call   800c4b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b64:	89 1c 24             	mov    %ebx,(%esp)
  801b67:	e8 58 f3 ff ff       	call   800ec4 <fd2data>
  801b6c:	83 c4 08             	add    $0x8,%esp
  801b6f:	50                   	push   %eax
  801b70:	6a 00                	push   $0x0
  801b72:	e8 d4 f0 ff ff       	call   800c4b <sys_page_unmap>
}
  801b77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7a:	c9                   	leave  
  801b7b:	c3                   	ret    

00801b7c <_pipeisclosed>:
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	57                   	push   %edi
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 1c             	sub    $0x1c,%esp
  801b85:	89 c7                	mov    %eax,%edi
  801b87:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b89:	a1 00 40 80 00       	mov    0x804000,%eax
  801b8e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b91:	83 ec 0c             	sub    $0xc,%esp
  801b94:	57                   	push   %edi
  801b95:	e8 1c 05 00 00       	call   8020b6 <pageref>
  801b9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b9d:	89 34 24             	mov    %esi,(%esp)
  801ba0:	e8 11 05 00 00       	call   8020b6 <pageref>
		nn = thisenv->env_runs;
  801ba5:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801bab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	39 cb                	cmp    %ecx,%ebx
  801bb3:	74 1b                	je     801bd0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bb5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bb8:	75 cf                	jne    801b89 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bba:	8b 42 58             	mov    0x58(%edx),%eax
  801bbd:	6a 01                	push   $0x1
  801bbf:	50                   	push   %eax
  801bc0:	53                   	push   %ebx
  801bc1:	68 93 28 80 00       	push   $0x802893
  801bc6:	e8 25 e6 ff ff       	call   8001f0 <cprintf>
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	eb b9                	jmp    801b89 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801bd0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bd3:	0f 94 c0             	sete   %al
  801bd6:	0f b6 c0             	movzbl %al,%eax
}
  801bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdc:	5b                   	pop    %ebx
  801bdd:	5e                   	pop    %esi
  801bde:	5f                   	pop    %edi
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    

00801be1 <devpipe_write>:
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	57                   	push   %edi
  801be5:	56                   	push   %esi
  801be6:	53                   	push   %ebx
  801be7:	83 ec 28             	sub    $0x28,%esp
  801bea:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801bed:	56                   	push   %esi
  801bee:	e8 d1 f2 ff ff       	call   800ec4 <fd2data>
  801bf3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bf5:	83 c4 10             	add    $0x10,%esp
  801bf8:	bf 00 00 00 00       	mov    $0x0,%edi
  801bfd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c00:	75 09                	jne    801c0b <devpipe_write+0x2a>
	return i;
  801c02:	89 f8                	mov    %edi,%eax
  801c04:	eb 23                	jmp    801c29 <devpipe_write+0x48>
			sys_yield();
  801c06:	e8 9c ef ff ff       	call   800ba7 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c0b:	8b 43 04             	mov    0x4(%ebx),%eax
  801c0e:	8b 0b                	mov    (%ebx),%ecx
  801c10:	8d 51 20             	lea    0x20(%ecx),%edx
  801c13:	39 d0                	cmp    %edx,%eax
  801c15:	72 1a                	jb     801c31 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801c17:	89 da                	mov    %ebx,%edx
  801c19:	89 f0                	mov    %esi,%eax
  801c1b:	e8 5c ff ff ff       	call   801b7c <_pipeisclosed>
  801c20:	85 c0                	test   %eax,%eax
  801c22:	74 e2                	je     801c06 <devpipe_write+0x25>
				return 0;
  801c24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2c:	5b                   	pop    %ebx
  801c2d:	5e                   	pop    %esi
  801c2e:	5f                   	pop    %edi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c34:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c38:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c3b:	89 c2                	mov    %eax,%edx
  801c3d:	c1 fa 1f             	sar    $0x1f,%edx
  801c40:	89 d1                	mov    %edx,%ecx
  801c42:	c1 e9 1b             	shr    $0x1b,%ecx
  801c45:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c48:	83 e2 1f             	and    $0x1f,%edx
  801c4b:	29 ca                	sub    %ecx,%edx
  801c4d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c51:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c55:	83 c0 01             	add    $0x1,%eax
  801c58:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c5b:	83 c7 01             	add    $0x1,%edi
  801c5e:	eb 9d                	jmp    801bfd <devpipe_write+0x1c>

00801c60 <devpipe_read>:
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	57                   	push   %edi
  801c64:	56                   	push   %esi
  801c65:	53                   	push   %ebx
  801c66:	83 ec 18             	sub    $0x18,%esp
  801c69:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c6c:	57                   	push   %edi
  801c6d:	e8 52 f2 ff ff       	call   800ec4 <fd2data>
  801c72:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	be 00 00 00 00       	mov    $0x0,%esi
  801c7c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c7f:	75 13                	jne    801c94 <devpipe_read+0x34>
	return i;
  801c81:	89 f0                	mov    %esi,%eax
  801c83:	eb 02                	jmp    801c87 <devpipe_read+0x27>
				return i;
  801c85:	89 f0                	mov    %esi,%eax
}
  801c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8a:	5b                   	pop    %ebx
  801c8b:	5e                   	pop    %esi
  801c8c:	5f                   	pop    %edi
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    
			sys_yield();
  801c8f:	e8 13 ef ff ff       	call   800ba7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c94:	8b 03                	mov    (%ebx),%eax
  801c96:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c99:	75 18                	jne    801cb3 <devpipe_read+0x53>
			if (i > 0)
  801c9b:	85 f6                	test   %esi,%esi
  801c9d:	75 e6                	jne    801c85 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801c9f:	89 da                	mov    %ebx,%edx
  801ca1:	89 f8                	mov    %edi,%eax
  801ca3:	e8 d4 fe ff ff       	call   801b7c <_pipeisclosed>
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	74 e3                	je     801c8f <devpipe_read+0x2f>
				return 0;
  801cac:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb1:	eb d4                	jmp    801c87 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cb3:	99                   	cltd   
  801cb4:	c1 ea 1b             	shr    $0x1b,%edx
  801cb7:	01 d0                	add    %edx,%eax
  801cb9:	83 e0 1f             	and    $0x1f,%eax
  801cbc:	29 d0                	sub    %edx,%eax
  801cbe:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cc9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ccc:	83 c6 01             	add    $0x1,%esi
  801ccf:	eb ab                	jmp    801c7c <devpipe_read+0x1c>

00801cd1 <pipe>:
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	56                   	push   %esi
  801cd5:	53                   	push   %ebx
  801cd6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801cd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdc:	50                   	push   %eax
  801cdd:	e8 f9 f1 ff ff       	call   800edb <fd_alloc>
  801ce2:	89 c3                	mov    %eax,%ebx
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	0f 88 23 01 00 00    	js     801e12 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cef:	83 ec 04             	sub    $0x4,%esp
  801cf2:	68 07 04 00 00       	push   $0x407
  801cf7:	ff 75 f4             	push   -0xc(%ebp)
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 c5 ee ff ff       	call   800bc6 <sys_page_alloc>
  801d01:	89 c3                	mov    %eax,%ebx
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	85 c0                	test   %eax,%eax
  801d08:	0f 88 04 01 00 00    	js     801e12 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801d0e:	83 ec 0c             	sub    $0xc,%esp
  801d11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d14:	50                   	push   %eax
  801d15:	e8 c1 f1 ff ff       	call   800edb <fd_alloc>
  801d1a:	89 c3                	mov    %eax,%ebx
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	0f 88 db 00 00 00    	js     801e02 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d27:	83 ec 04             	sub    $0x4,%esp
  801d2a:	68 07 04 00 00       	push   $0x407
  801d2f:	ff 75 f0             	push   -0x10(%ebp)
  801d32:	6a 00                	push   $0x0
  801d34:	e8 8d ee ff ff       	call   800bc6 <sys_page_alloc>
  801d39:	89 c3                	mov    %eax,%ebx
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	0f 88 bc 00 00 00    	js     801e02 <pipe+0x131>
	va = fd2data(fd0);
  801d46:	83 ec 0c             	sub    $0xc,%esp
  801d49:	ff 75 f4             	push   -0xc(%ebp)
  801d4c:	e8 73 f1 ff ff       	call   800ec4 <fd2data>
  801d51:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d53:	83 c4 0c             	add    $0xc,%esp
  801d56:	68 07 04 00 00       	push   $0x407
  801d5b:	50                   	push   %eax
  801d5c:	6a 00                	push   $0x0
  801d5e:	e8 63 ee ff ff       	call   800bc6 <sys_page_alloc>
  801d63:	89 c3                	mov    %eax,%ebx
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	0f 88 82 00 00 00    	js     801df2 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d70:	83 ec 0c             	sub    $0xc,%esp
  801d73:	ff 75 f0             	push   -0x10(%ebp)
  801d76:	e8 49 f1 ff ff       	call   800ec4 <fd2data>
  801d7b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d82:	50                   	push   %eax
  801d83:	6a 00                	push   $0x0
  801d85:	56                   	push   %esi
  801d86:	6a 00                	push   $0x0
  801d88:	e8 7c ee ff ff       	call   800c09 <sys_page_map>
  801d8d:	89 c3                	mov    %eax,%ebx
  801d8f:	83 c4 20             	add    $0x20,%esp
  801d92:	85 c0                	test   %eax,%eax
  801d94:	78 4e                	js     801de4 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801d96:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d9e:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801da0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801da3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801daa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dad:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801db9:	83 ec 0c             	sub    $0xc,%esp
  801dbc:	ff 75 f4             	push   -0xc(%ebp)
  801dbf:	e8 f0 f0 ff ff       	call   800eb4 <fd2num>
  801dc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc9:	83 c4 04             	add    $0x4,%esp
  801dcc:	ff 75 f0             	push   -0x10(%ebp)
  801dcf:	e8 e0 f0 ff ff       	call   800eb4 <fd2num>
  801dd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801de2:	eb 2e                	jmp    801e12 <pipe+0x141>
	sys_page_unmap(0, va);
  801de4:	83 ec 08             	sub    $0x8,%esp
  801de7:	56                   	push   %esi
  801de8:	6a 00                	push   $0x0
  801dea:	e8 5c ee ff ff       	call   800c4b <sys_page_unmap>
  801def:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801df2:	83 ec 08             	sub    $0x8,%esp
  801df5:	ff 75 f0             	push   -0x10(%ebp)
  801df8:	6a 00                	push   $0x0
  801dfa:	e8 4c ee ff ff       	call   800c4b <sys_page_unmap>
  801dff:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e02:	83 ec 08             	sub    $0x8,%esp
  801e05:	ff 75 f4             	push   -0xc(%ebp)
  801e08:	6a 00                	push   $0x0
  801e0a:	e8 3c ee ff ff       	call   800c4b <sys_page_unmap>
  801e0f:	83 c4 10             	add    $0x10,%esp
}
  801e12:	89 d8                	mov    %ebx,%eax
  801e14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e17:	5b                   	pop    %ebx
  801e18:	5e                   	pop    %esi
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    

00801e1b <pipeisclosed>:
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e24:	50                   	push   %eax
  801e25:	ff 75 08             	push   0x8(%ebp)
  801e28:	e8 fe f0 ff ff       	call   800f2b <fd_lookup>
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	78 18                	js     801e4c <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	ff 75 f4             	push   -0xc(%ebp)
  801e3a:	e8 85 f0 ff ff       	call   800ec4 <fd2data>
  801e3f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e44:	e8 33 fd ff ff       	call   801b7c <_pipeisclosed>
  801e49:	83 c4 10             	add    $0x10,%esp
}
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801e4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e53:	c3                   	ret    

00801e54 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e5a:	68 ab 28 80 00       	push   $0x8028ab
  801e5f:	ff 75 0c             	push   0xc(%ebp)
  801e62:	e8 63 e9 ff ff       	call   8007ca <strcpy>
	return 0;
}
  801e67:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <devcons_write>:
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
  801e74:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e7a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e7f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e85:	eb 2e                	jmp    801eb5 <devcons_write+0x47>
		m = n - tot;
  801e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e8a:	29 f3                	sub    %esi,%ebx
  801e8c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e91:	39 c3                	cmp    %eax,%ebx
  801e93:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e96:	83 ec 04             	sub    $0x4,%esp
  801e99:	53                   	push   %ebx
  801e9a:	89 f0                	mov    %esi,%eax
  801e9c:	03 45 0c             	add    0xc(%ebp),%eax
  801e9f:	50                   	push   %eax
  801ea0:	57                   	push   %edi
  801ea1:	e8 ba ea ff ff       	call   800960 <memmove>
		sys_cputs(buf, m);
  801ea6:	83 c4 08             	add    $0x8,%esp
  801ea9:	53                   	push   %ebx
  801eaa:	57                   	push   %edi
  801eab:	e8 5a ec ff ff       	call   800b0a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801eb0:	01 de                	add    %ebx,%esi
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb8:	72 cd                	jb     801e87 <devcons_write+0x19>
}
  801eba:	89 f0                	mov    %esi,%eax
  801ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5f                   	pop    %edi
  801ec2:	5d                   	pop    %ebp
  801ec3:	c3                   	ret    

00801ec4 <devcons_read>:
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 08             	sub    $0x8,%esp
  801eca:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ecf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed3:	75 07                	jne    801edc <devcons_read+0x18>
  801ed5:	eb 1f                	jmp    801ef6 <devcons_read+0x32>
		sys_yield();
  801ed7:	e8 cb ec ff ff       	call   800ba7 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801edc:	e8 47 ec ff ff       	call   800b28 <sys_cgetc>
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	74 f2                	je     801ed7 <devcons_read+0x13>
	if (c < 0)
  801ee5:	78 0f                	js     801ef6 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801ee7:	83 f8 04             	cmp    $0x4,%eax
  801eea:	74 0c                	je     801ef8 <devcons_read+0x34>
	*(char*)vbuf = c;
  801eec:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eef:	88 02                	mov    %al,(%edx)
	return 1;
  801ef1:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    
		return 0;
  801ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  801efd:	eb f7                	jmp    801ef6 <devcons_read+0x32>

00801eff <cputchar>:
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f05:	8b 45 08             	mov    0x8(%ebp),%eax
  801f08:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f0b:	6a 01                	push   $0x1
  801f0d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f10:	50                   	push   %eax
  801f11:	e8 f4 eb ff ff       	call   800b0a <sys_cputs>
}
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <getchar>:
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f21:	6a 01                	push   $0x1
  801f23:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f26:	50                   	push   %eax
  801f27:	6a 00                	push   $0x0
  801f29:	e8 66 f2 ff ff       	call   801194 <read>
	if (r < 0)
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	85 c0                	test   %eax,%eax
  801f33:	78 06                	js     801f3b <getchar+0x20>
	if (r < 1)
  801f35:	74 06                	je     801f3d <getchar+0x22>
	return c;
  801f37:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f3b:	c9                   	leave  
  801f3c:	c3                   	ret    
		return -E_EOF;
  801f3d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f42:	eb f7                	jmp    801f3b <getchar+0x20>

00801f44 <iscons>:
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4d:	50                   	push   %eax
  801f4e:	ff 75 08             	push   0x8(%ebp)
  801f51:	e8 d5 ef ff ff       	call   800f2b <fd_lookup>
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 11                	js     801f6e <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f60:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f66:	39 10                	cmp    %edx,(%eax)
  801f68:	0f 94 c0             	sete   %al
  801f6b:	0f b6 c0             	movzbl %al,%eax
}
  801f6e:	c9                   	leave  
  801f6f:	c3                   	ret    

00801f70 <opencons>:
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f79:	50                   	push   %eax
  801f7a:	e8 5c ef ff ff       	call   800edb <fd_alloc>
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	85 c0                	test   %eax,%eax
  801f84:	78 3a                	js     801fc0 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f86:	83 ec 04             	sub    $0x4,%esp
  801f89:	68 07 04 00 00       	push   $0x407
  801f8e:	ff 75 f4             	push   -0xc(%ebp)
  801f91:	6a 00                	push   $0x0
  801f93:	e8 2e ec ff ff       	call   800bc6 <sys_page_alloc>
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 21                	js     801fc0 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fa8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fad:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb4:	83 ec 0c             	sub    $0xc,%esp
  801fb7:	50                   	push   %eax
  801fb8:	e8 f7 ee ff ff       	call   800eb4 <fd2num>
  801fbd:	83 c4 10             	add    $0x10,%esp
}
  801fc0:	c9                   	leave  
  801fc1:	c3                   	ret    

00801fc2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc2:	55                   	push   %ebp
  801fc3:	89 e5                	mov    %esp,%ebp
  801fc5:	56                   	push   %esi
  801fc6:	53                   	push   %ebx
  801fc7:	8b 75 08             	mov    0x8(%ebp),%esi
  801fca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fd7:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801fda:	83 ec 0c             	sub    $0xc,%esp
  801fdd:	50                   	push   %eax
  801fde:	e8 93 ed ff ff       	call   800d76 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	85 f6                	test   %esi,%esi
  801fe8:	74 14                	je     801ffe <ipc_recv+0x3c>
  801fea:	ba 00 00 00 00       	mov    $0x0,%edx
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 09                	js     801ffc <ipc_recv+0x3a>
  801ff3:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ff9:	8b 52 74             	mov    0x74(%edx),%edx
  801ffc:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ffe:	85 db                	test   %ebx,%ebx
  802000:	74 14                	je     802016 <ipc_recv+0x54>
  802002:	ba 00 00 00 00       	mov    $0x0,%edx
  802007:	85 c0                	test   %eax,%eax
  802009:	78 09                	js     802014 <ipc_recv+0x52>
  80200b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802011:	8b 52 78             	mov    0x78(%edx),%edx
  802014:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802016:	85 c0                	test   %eax,%eax
  802018:	78 08                	js     802022 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  80201a:	a1 00 40 80 00       	mov    0x804000,%eax
  80201f:	8b 40 70             	mov    0x70(%eax),%eax
}
  802022:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802025:	5b                   	pop    %ebx
  802026:	5e                   	pop    %esi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	57                   	push   %edi
  80202d:	56                   	push   %esi
  80202e:	53                   	push   %ebx
  80202f:	83 ec 0c             	sub    $0xc,%esp
  802032:	8b 7d 08             	mov    0x8(%ebp),%edi
  802035:	8b 75 0c             	mov    0xc(%ebp),%esi
  802038:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80203b:	85 db                	test   %ebx,%ebx
  80203d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802042:	0f 44 d8             	cmove  %eax,%ebx
  802045:	eb 05                	jmp    80204c <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802047:	e8 5b eb ff ff       	call   800ba7 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80204c:	ff 75 14             	push   0x14(%ebp)
  80204f:	53                   	push   %ebx
  802050:	56                   	push   %esi
  802051:	57                   	push   %edi
  802052:	e8 fc ec ff ff       	call   800d53 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80205d:	74 e8                	je     802047 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80205f:	85 c0                	test   %eax,%eax
  802061:	78 08                	js     80206b <ipc_send+0x42>
	}while (r<0);

}
  802063:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802066:	5b                   	pop    %ebx
  802067:	5e                   	pop    %esi
  802068:	5f                   	pop    %edi
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80206b:	50                   	push   %eax
  80206c:	68 b7 28 80 00       	push   $0x8028b7
  802071:	6a 3d                	push   $0x3d
  802073:	68 cb 28 80 00       	push   $0x8028cb
  802078:	e8 98 e0 ff ff       	call   800115 <_panic>

0080207d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802083:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802088:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80208b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802091:	8b 52 50             	mov    0x50(%edx),%edx
  802094:	39 ca                	cmp    %ecx,%edx
  802096:	74 11                	je     8020a9 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802098:	83 c0 01             	add    $0x1,%eax
  80209b:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020a0:	75 e6                	jne    802088 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8020a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a7:	eb 0b                	jmp    8020b4 <ipc_find_env+0x37>
			return envs[i].env_id;
  8020a9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020b1:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020b4:	5d                   	pop    %ebp
  8020b5:	c3                   	ret    

008020b6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020bc:	89 c2                	mov    %eax,%edx
  8020be:	c1 ea 16             	shr    $0x16,%edx
  8020c1:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020c8:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020cd:	f6 c1 01             	test   $0x1,%cl
  8020d0:	74 1c                	je     8020ee <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8020d2:	c1 e8 0c             	shr    $0xc,%eax
  8020d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020dc:	a8 01                	test   $0x1,%al
  8020de:	74 0e                	je     8020ee <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020e0:	c1 e8 0c             	shr    $0xc,%eax
  8020e3:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020ea:	ef 
  8020eb:	0f b7 d2             	movzwl %dx,%edx
}
  8020ee:	89 d0                	mov    %edx,%eax
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__udivdi3>:
  802100:	f3 0f 1e fb          	endbr32 
  802104:	55                   	push   %ebp
  802105:	57                   	push   %edi
  802106:	56                   	push   %esi
  802107:	53                   	push   %ebx
  802108:	83 ec 1c             	sub    $0x1c,%esp
  80210b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80210f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802113:	8b 74 24 34          	mov    0x34(%esp),%esi
  802117:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80211b:	85 c0                	test   %eax,%eax
  80211d:	75 19                	jne    802138 <__udivdi3+0x38>
  80211f:	39 f3                	cmp    %esi,%ebx
  802121:	76 4d                	jbe    802170 <__udivdi3+0x70>
  802123:	31 ff                	xor    %edi,%edi
  802125:	89 e8                	mov    %ebp,%eax
  802127:	89 f2                	mov    %esi,%edx
  802129:	f7 f3                	div    %ebx
  80212b:	89 fa                	mov    %edi,%edx
  80212d:	83 c4 1c             	add    $0x1c,%esp
  802130:	5b                   	pop    %ebx
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	39 f0                	cmp    %esi,%eax
  80213a:	76 14                	jbe    802150 <__udivdi3+0x50>
  80213c:	31 ff                	xor    %edi,%edi
  80213e:	31 c0                	xor    %eax,%eax
  802140:	89 fa                	mov    %edi,%edx
  802142:	83 c4 1c             	add    $0x1c,%esp
  802145:	5b                   	pop    %ebx
  802146:	5e                   	pop    %esi
  802147:	5f                   	pop    %edi
  802148:	5d                   	pop    %ebp
  802149:	c3                   	ret    
  80214a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802150:	0f bd f8             	bsr    %eax,%edi
  802153:	83 f7 1f             	xor    $0x1f,%edi
  802156:	75 48                	jne    8021a0 <__udivdi3+0xa0>
  802158:	39 f0                	cmp    %esi,%eax
  80215a:	72 06                	jb     802162 <__udivdi3+0x62>
  80215c:	31 c0                	xor    %eax,%eax
  80215e:	39 eb                	cmp    %ebp,%ebx
  802160:	77 de                	ja     802140 <__udivdi3+0x40>
  802162:	b8 01 00 00 00       	mov    $0x1,%eax
  802167:	eb d7                	jmp    802140 <__udivdi3+0x40>
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d9                	mov    %ebx,%ecx
  802172:	85 db                	test   %ebx,%ebx
  802174:	75 0b                	jne    802181 <__udivdi3+0x81>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f3                	div    %ebx
  80217f:	89 c1                	mov    %eax,%ecx
  802181:	31 d2                	xor    %edx,%edx
  802183:	89 f0                	mov    %esi,%eax
  802185:	f7 f1                	div    %ecx
  802187:	89 c6                	mov    %eax,%esi
  802189:	89 e8                	mov    %ebp,%eax
  80218b:	89 f7                	mov    %esi,%edi
  80218d:	f7 f1                	div    %ecx
  80218f:	89 fa                	mov    %edi,%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 f9                	mov    %edi,%ecx
  8021a2:	ba 20 00 00 00       	mov    $0x20,%edx
  8021a7:	29 fa                	sub    %edi,%edx
  8021a9:	d3 e0                	shl    %cl,%eax
  8021ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021af:	89 d1                	mov    %edx,%ecx
  8021b1:	89 d8                	mov    %ebx,%eax
  8021b3:	d3 e8                	shr    %cl,%eax
  8021b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021b9:	09 c1                	or     %eax,%ecx
  8021bb:	89 f0                	mov    %esi,%eax
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	d3 e3                	shl    %cl,%ebx
  8021c5:	89 d1                	mov    %edx,%ecx
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 f9                	mov    %edi,%ecx
  8021cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021cf:	89 eb                	mov    %ebp,%ebx
  8021d1:	d3 e6                	shl    %cl,%esi
  8021d3:	89 d1                	mov    %edx,%ecx
  8021d5:	d3 eb                	shr    %cl,%ebx
  8021d7:	09 f3                	or     %esi,%ebx
  8021d9:	89 c6                	mov    %eax,%esi
  8021db:	89 f2                	mov    %esi,%edx
  8021dd:	89 d8                	mov    %ebx,%eax
  8021df:	f7 74 24 08          	divl   0x8(%esp)
  8021e3:	89 d6                	mov    %edx,%esi
  8021e5:	89 c3                	mov    %eax,%ebx
  8021e7:	f7 64 24 0c          	mull   0xc(%esp)
  8021eb:	39 d6                	cmp    %edx,%esi
  8021ed:	72 19                	jb     802208 <__udivdi3+0x108>
  8021ef:	89 f9                	mov    %edi,%ecx
  8021f1:	d3 e5                	shl    %cl,%ebp
  8021f3:	39 c5                	cmp    %eax,%ebp
  8021f5:	73 04                	jae    8021fb <__udivdi3+0xfb>
  8021f7:	39 d6                	cmp    %edx,%esi
  8021f9:	74 0d                	je     802208 <__udivdi3+0x108>
  8021fb:	89 d8                	mov    %ebx,%eax
  8021fd:	31 ff                	xor    %edi,%edi
  8021ff:	e9 3c ff ff ff       	jmp    802140 <__udivdi3+0x40>
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80220b:	31 ff                	xor    %edi,%edi
  80220d:	e9 2e ff ff ff       	jmp    802140 <__udivdi3+0x40>
  802212:	66 90                	xchg   %ax,%ax
  802214:	66 90                	xchg   %ax,%ax
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	f3 0f 1e fb          	endbr32 
  802224:	55                   	push   %ebp
  802225:	57                   	push   %edi
  802226:	56                   	push   %esi
  802227:	53                   	push   %ebx
  802228:	83 ec 1c             	sub    $0x1c,%esp
  80222b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80222f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802233:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802237:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80223b:	89 f0                	mov    %esi,%eax
  80223d:	89 da                	mov    %ebx,%edx
  80223f:	85 ff                	test   %edi,%edi
  802241:	75 15                	jne    802258 <__umoddi3+0x38>
  802243:	39 dd                	cmp    %ebx,%ebp
  802245:	76 39                	jbe    802280 <__umoddi3+0x60>
  802247:	f7 f5                	div    %ebp
  802249:	89 d0                	mov    %edx,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	83 c4 1c             	add    $0x1c,%esp
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    
  802255:	8d 76 00             	lea    0x0(%esi),%esi
  802258:	39 df                	cmp    %ebx,%edi
  80225a:	77 f1                	ja     80224d <__umoddi3+0x2d>
  80225c:	0f bd cf             	bsr    %edi,%ecx
  80225f:	83 f1 1f             	xor    $0x1f,%ecx
  802262:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802266:	75 40                	jne    8022a8 <__umoddi3+0x88>
  802268:	39 df                	cmp    %ebx,%edi
  80226a:	72 04                	jb     802270 <__umoddi3+0x50>
  80226c:	39 f5                	cmp    %esi,%ebp
  80226e:	77 dd                	ja     80224d <__umoddi3+0x2d>
  802270:	89 da                	mov    %ebx,%edx
  802272:	89 f0                	mov    %esi,%eax
  802274:	29 e8                	sub    %ebp,%eax
  802276:	19 fa                	sbb    %edi,%edx
  802278:	eb d3                	jmp    80224d <__umoddi3+0x2d>
  80227a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802280:	89 e9                	mov    %ebp,%ecx
  802282:	85 ed                	test   %ebp,%ebp
  802284:	75 0b                	jne    802291 <__umoddi3+0x71>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f5                	div    %ebp
  80228f:	89 c1                	mov    %eax,%ecx
  802291:	89 d8                	mov    %ebx,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f1                	div    %ecx
  802297:	89 f0                	mov    %esi,%eax
  802299:	f7 f1                	div    %ecx
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	31 d2                	xor    %edx,%edx
  80229f:	eb ac                	jmp    80224d <__umoddi3+0x2d>
  8022a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022ac:	ba 20 00 00 00       	mov    $0x20,%edx
  8022b1:	29 c2                	sub    %eax,%edx
  8022b3:	89 c1                	mov    %eax,%ecx
  8022b5:	89 e8                	mov    %ebp,%eax
  8022b7:	d3 e7                	shl    %cl,%edi
  8022b9:	89 d1                	mov    %edx,%ecx
  8022bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022bf:	d3 e8                	shr    %cl,%eax
  8022c1:	89 c1                	mov    %eax,%ecx
  8022c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022c7:	09 f9                	or     %edi,%ecx
  8022c9:	89 df                	mov    %ebx,%edi
  8022cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022cf:	89 c1                	mov    %eax,%ecx
  8022d1:	d3 e5                	shl    %cl,%ebp
  8022d3:	89 d1                	mov    %edx,%ecx
  8022d5:	d3 ef                	shr    %cl,%edi
  8022d7:	89 c1                	mov    %eax,%ecx
  8022d9:	89 f0                	mov    %esi,%eax
  8022db:	d3 e3                	shl    %cl,%ebx
  8022dd:	89 d1                	mov    %edx,%ecx
  8022df:	89 fa                	mov    %edi,%edx
  8022e1:	d3 e8                	shr    %cl,%eax
  8022e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022e8:	09 d8                	or     %ebx,%eax
  8022ea:	f7 74 24 08          	divl   0x8(%esp)
  8022ee:	89 d3                	mov    %edx,%ebx
  8022f0:	d3 e6                	shl    %cl,%esi
  8022f2:	f7 e5                	mul    %ebp
  8022f4:	89 c7                	mov    %eax,%edi
  8022f6:	89 d1                	mov    %edx,%ecx
  8022f8:	39 d3                	cmp    %edx,%ebx
  8022fa:	72 06                	jb     802302 <__umoddi3+0xe2>
  8022fc:	75 0e                	jne    80230c <__umoddi3+0xec>
  8022fe:	39 c6                	cmp    %eax,%esi
  802300:	73 0a                	jae    80230c <__umoddi3+0xec>
  802302:	29 e8                	sub    %ebp,%eax
  802304:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802308:	89 d1                	mov    %edx,%ecx
  80230a:	89 c7                	mov    %eax,%edi
  80230c:	89 f5                	mov    %esi,%ebp
  80230e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802312:	29 fd                	sub    %edi,%ebp
  802314:	19 cb                	sbb    %ecx,%ebx
  802316:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80231b:	89 d8                	mov    %ebx,%eax
  80231d:	d3 e0                	shl    %cl,%eax
  80231f:	89 f1                	mov    %esi,%ecx
  802321:	d3 ed                	shr    %cl,%ebp
  802323:	d3 eb                	shr    %cl,%ebx
  802325:	09 e8                	or     %ebp,%eax
  802327:	89 da                	mov    %ebx,%edx
  802329:	83 c4 1c             	add    $0x1c,%esp
  80232c:	5b                   	pop    %ebx
  80232d:	5e                   	pop    %esi
  80232e:	5f                   	pop    %edi
  80232f:	5d                   	pop    %ebp
  802330:	c3                   	ret    
