
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
  800040:	68 80 1e 80 00       	push   $0x801e80
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
  800066:	68 cc 1e 80 00       	push   $0x801ecc
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
  800080:	68 a0 1e 80 00       	push   $0x801ea0
  800085:	6a 0f                	push   $0xf
  800087:	68 8a 1e 80 00       	push   $0x801e8a
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
  80009c:	e8 16 0d 00 00       	call   800db7 <set_pgfault_handler>
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
  800101:	e8 19 0f 00 00       	call   80101f <close_all>
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
  800133:	68 f8 1e 80 00       	push   $0x801ef8
  800138:	e8 b3 00 00 00       	call   8001f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	push   0x10(%ebp)
  800144:	e8 56 00 00 00       	call   80019f <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 a7 23 80 00 	movl   $0x8023a7,(%esp)
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
  800252:	e8 d9 19 00 00       	call   801c30 <__udivdi3>
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
  800290:	e8 bb 1a 00 00       	call   801d50 <__umoddi3>
  800295:	83 c4 14             	add    $0x14,%esp
  800298:	0f be 80 1b 1f 80 00 	movsbl 0x801f1b(%eax),%eax
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
  800352:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
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
  800420:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  800427:	85 d2                	test   %edx,%edx
  800429:	74 18                	je     800443 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80042b:	52                   	push   %edx
  80042c:	68 75 23 80 00       	push   $0x802375
  800431:	53                   	push   %ebx
  800432:	56                   	push   %esi
  800433:	e8 92 fe ff ff       	call   8002ca <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80043e:	e9 66 02 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800443:	50                   	push   %eax
  800444:	68 33 1f 80 00       	push   $0x801f33
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
  80046b:	b8 2c 1f 80 00       	mov    $0x801f2c,%eax
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
  800b77:	68 1f 22 80 00       	push   $0x80221f
  800b7c:	6a 2a                	push   $0x2a
  800b7e:	68 3c 22 80 00       	push   $0x80223c
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
  800bf8:	68 1f 22 80 00       	push   $0x80221f
  800bfd:	6a 2a                	push   $0x2a
  800bff:	68 3c 22 80 00       	push   $0x80223c
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
  800c3a:	68 1f 22 80 00       	push   $0x80221f
  800c3f:	6a 2a                	push   $0x2a
  800c41:	68 3c 22 80 00       	push   $0x80223c
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
  800c7c:	68 1f 22 80 00       	push   $0x80221f
  800c81:	6a 2a                	push   $0x2a
  800c83:	68 3c 22 80 00       	push   $0x80223c
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
  800cbe:	68 1f 22 80 00       	push   $0x80221f
  800cc3:	6a 2a                	push   $0x2a
  800cc5:	68 3c 22 80 00       	push   $0x80223c
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
  800d00:	68 1f 22 80 00       	push   $0x80221f
  800d05:	6a 2a                	push   $0x2a
  800d07:	68 3c 22 80 00       	push   $0x80223c
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
  800d42:	68 1f 22 80 00       	push   $0x80221f
  800d47:	6a 2a                	push   $0x2a
  800d49:	68 3c 22 80 00       	push   $0x80223c
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
  800da6:	68 1f 22 80 00       	push   $0x80221f
  800dab:	6a 2a                	push   $0x2a
  800dad:	68 3c 22 80 00       	push   $0x80223c
  800db2:	e8 5e f3 ff ff       	call   800115 <_panic>

00800db7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800dbd:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc4:	74 0a                	je     800dd0 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	a3 04 40 80 00       	mov    %eax,0x804004
}
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800dd0:	e8 b3 fd ff ff       	call   800b88 <sys_getenvid>
  800dd5:	83 ec 04             	sub    $0x4,%esp
  800dd8:	68 07 0e 00 00       	push   $0xe07
  800ddd:	68 00 f0 bf ee       	push   $0xeebff000
  800de2:	50                   	push   %eax
  800de3:	e8 de fd ff ff       	call   800bc6 <sys_page_alloc>
		if (r < 0) {
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	78 2c                	js     800e1b <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800def:	e8 94 fd ff ff       	call   800b88 <sys_getenvid>
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	68 2d 0e 80 00       	push   $0x800e2d
  800dfc:	50                   	push   %eax
  800dfd:	e8 0f ff ff ff       	call   800d11 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800e02:	83 c4 10             	add    $0x10,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	79 bd                	jns    800dc6 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800e09:	50                   	push   %eax
  800e0a:	68 8c 22 80 00       	push   $0x80228c
  800e0f:	6a 28                	push   $0x28
  800e11:	68 c2 22 80 00       	push   $0x8022c2
  800e16:	e8 fa f2 ff ff       	call   800115 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800e1b:	50                   	push   %eax
  800e1c:	68 4c 22 80 00       	push   $0x80224c
  800e21:	6a 23                	push   $0x23
  800e23:	68 c2 22 80 00       	push   $0x8022c2
  800e28:	e8 e8 f2 ff ff       	call   800115 <_panic>

00800e2d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e2d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e2e:	a1 04 40 80 00       	mov    0x804004,%eax
	call *%eax
  800e33:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e35:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800e38:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800e3c:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800e3f:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800e43:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800e47:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800e49:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800e4c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800e4d:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800e50:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800e51:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800e52:	c3                   	ret    

00800e53 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
  800e59:	05 00 00 00 30       	add    $0x30000000,%eax
  800e5e:	c1 e8 0c             	shr    $0xc,%eax
}
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e66:	8b 45 08             	mov    0x8(%ebp),%eax
  800e69:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e73:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e82:	89 c2                	mov    %eax,%edx
  800e84:	c1 ea 16             	shr    $0x16,%edx
  800e87:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8e:	f6 c2 01             	test   $0x1,%dl
  800e91:	74 29                	je     800ebc <fd_alloc+0x42>
  800e93:	89 c2                	mov    %eax,%edx
  800e95:	c1 ea 0c             	shr    $0xc,%edx
  800e98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e9f:	f6 c2 01             	test   $0x1,%dl
  800ea2:	74 18                	je     800ebc <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800ea4:	05 00 10 00 00       	add    $0x1000,%eax
  800ea9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eae:	75 d2                	jne    800e82 <fd_alloc+0x8>
  800eb0:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800eb5:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800eba:	eb 05                	jmp    800ec1 <fd_alloc+0x47>
			return 0;
  800ebc:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	89 02                	mov    %eax,(%edx)
}
  800ec6:	89 c8                	mov    %ecx,%eax
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ed0:	83 f8 1f             	cmp    $0x1f,%eax
  800ed3:	77 30                	ja     800f05 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed5:	c1 e0 0c             	shl    $0xc,%eax
  800ed8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800edd:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ee3:	f6 c2 01             	test   $0x1,%dl
  800ee6:	74 24                	je     800f0c <fd_lookup+0x42>
  800ee8:	89 c2                	mov    %eax,%edx
  800eea:	c1 ea 0c             	shr    $0xc,%edx
  800eed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef4:	f6 c2 01             	test   $0x1,%dl
  800ef7:	74 1a                	je     800f13 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ef9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efc:	89 02                	mov    %eax,(%edx)
	return 0;
  800efe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    
		return -E_INVAL;
  800f05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0a:	eb f7                	jmp    800f03 <fd_lookup+0x39>
		return -E_INVAL;
  800f0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f11:	eb f0                	jmp    800f03 <fd_lookup+0x39>
  800f13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f18:	eb e9                	jmp    800f03 <fd_lookup+0x39>

00800f1a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	53                   	push   %ebx
  800f1e:	83 ec 04             	sub    $0x4,%esp
  800f21:	8b 55 08             	mov    0x8(%ebp),%edx
  800f24:	b8 4c 23 80 00       	mov    $0x80234c,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800f29:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f2e:	39 13                	cmp    %edx,(%ebx)
  800f30:	74 32                	je     800f64 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800f32:	83 c0 04             	add    $0x4,%eax
  800f35:	8b 18                	mov    (%eax),%ebx
  800f37:	85 db                	test   %ebx,%ebx
  800f39:	75 f3                	jne    800f2e <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f3b:	a1 00 40 80 00       	mov    0x804000,%eax
  800f40:	8b 40 48             	mov    0x48(%eax),%eax
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	52                   	push   %edx
  800f47:	50                   	push   %eax
  800f48:	68 d0 22 80 00       	push   $0x8022d0
  800f4d:	e8 9e f2 ff ff       	call   8001f0 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5d:	89 1a                	mov    %ebx,(%edx)
}
  800f5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    
			return 0;
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
  800f69:	eb ef                	jmp    800f5a <dev_lookup+0x40>

00800f6b <fd_close>:
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	57                   	push   %edi
  800f6f:	56                   	push   %esi
  800f70:	53                   	push   %ebx
  800f71:	83 ec 24             	sub    $0x24,%esp
  800f74:	8b 75 08             	mov    0x8(%ebp),%esi
  800f77:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f7a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f7d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f7e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f84:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f87:	50                   	push   %eax
  800f88:	e8 3d ff ff ff       	call   800eca <fd_lookup>
  800f8d:	89 c3                	mov    %eax,%ebx
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	78 05                	js     800f9b <fd_close+0x30>
	    || fd != fd2)
  800f96:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f99:	74 16                	je     800fb1 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f9b:	89 f8                	mov    %edi,%eax
  800f9d:	84 c0                	test   %al,%al
  800f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa4:	0f 44 d8             	cmove  %eax,%ebx
}
  800fa7:	89 d8                	mov    %ebx,%eax
  800fa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fb1:	83 ec 08             	sub    $0x8,%esp
  800fb4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fb7:	50                   	push   %eax
  800fb8:	ff 36                	push   (%esi)
  800fba:	e8 5b ff ff ff       	call   800f1a <dev_lookup>
  800fbf:	89 c3                	mov    %eax,%ebx
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 1a                	js     800fe2 <fd_close+0x77>
		if (dev->dev_close)
  800fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fcb:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fce:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	74 0b                	je     800fe2 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	56                   	push   %esi
  800fdb:	ff d0                	call   *%eax
  800fdd:	89 c3                	mov    %eax,%ebx
  800fdf:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fe2:	83 ec 08             	sub    $0x8,%esp
  800fe5:	56                   	push   %esi
  800fe6:	6a 00                	push   $0x0
  800fe8:	e8 5e fc ff ff       	call   800c4b <sys_page_unmap>
	return r;
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	eb b5                	jmp    800fa7 <fd_close+0x3c>

00800ff2 <close>:

int
close(int fdnum)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	ff 75 08             	push   0x8(%ebp)
  800fff:	e8 c6 fe ff ff       	call   800eca <fd_lookup>
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	79 02                	jns    80100d <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80100b:	c9                   	leave  
  80100c:	c3                   	ret    
		return fd_close(fd, 1);
  80100d:	83 ec 08             	sub    $0x8,%esp
  801010:	6a 01                	push   $0x1
  801012:	ff 75 f4             	push   -0xc(%ebp)
  801015:	e8 51 ff ff ff       	call   800f6b <fd_close>
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	eb ec                	jmp    80100b <close+0x19>

0080101f <close_all>:

void
close_all(void)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	53                   	push   %ebx
  801023:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801026:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	53                   	push   %ebx
  80102f:	e8 be ff ff ff       	call   800ff2 <close>
	for (i = 0; i < MAXFD; i++)
  801034:	83 c3 01             	add    $0x1,%ebx
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	83 fb 20             	cmp    $0x20,%ebx
  80103d:	75 ec                	jne    80102b <close_all+0xc>
}
  80103f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	57                   	push   %edi
  801048:	56                   	push   %esi
  801049:	53                   	push   %ebx
  80104a:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80104d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801050:	50                   	push   %eax
  801051:	ff 75 08             	push   0x8(%ebp)
  801054:	e8 71 fe ff ff       	call   800eca <fd_lookup>
  801059:	89 c3                	mov    %eax,%ebx
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 7f                	js     8010e1 <dup+0x9d>
		return r;
	close(newfdnum);
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	ff 75 0c             	push   0xc(%ebp)
  801068:	e8 85 ff ff ff       	call   800ff2 <close>

	newfd = INDEX2FD(newfdnum);
  80106d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801070:	c1 e6 0c             	shl    $0xc,%esi
  801073:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801079:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80107c:	89 3c 24             	mov    %edi,(%esp)
  80107f:	e8 df fd ff ff       	call   800e63 <fd2data>
  801084:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801086:	89 34 24             	mov    %esi,(%esp)
  801089:	e8 d5 fd ff ff       	call   800e63 <fd2data>
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801094:	89 d8                	mov    %ebx,%eax
  801096:	c1 e8 16             	shr    $0x16,%eax
  801099:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a0:	a8 01                	test   $0x1,%al
  8010a2:	74 11                	je     8010b5 <dup+0x71>
  8010a4:	89 d8                	mov    %ebx,%eax
  8010a6:	c1 e8 0c             	shr    $0xc,%eax
  8010a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b0:	f6 c2 01             	test   $0x1,%dl
  8010b3:	75 36                	jne    8010eb <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b5:	89 f8                	mov    %edi,%eax
  8010b7:	c1 e8 0c             	shr    $0xc,%eax
  8010ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c9:	50                   	push   %eax
  8010ca:	56                   	push   %esi
  8010cb:	6a 00                	push   $0x0
  8010cd:	57                   	push   %edi
  8010ce:	6a 00                	push   $0x0
  8010d0:	e8 34 fb ff ff       	call   800c09 <sys_page_map>
  8010d5:	89 c3                	mov    %eax,%ebx
  8010d7:	83 c4 20             	add    $0x20,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	78 33                	js     801111 <dup+0xcd>
		goto err;

	return newfdnum;
  8010de:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010e1:	89 d8                	mov    %ebx,%eax
  8010e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fa:	50                   	push   %eax
  8010fb:	ff 75 d4             	push   -0x2c(%ebp)
  8010fe:	6a 00                	push   $0x0
  801100:	53                   	push   %ebx
  801101:	6a 00                	push   $0x0
  801103:	e8 01 fb ff ff       	call   800c09 <sys_page_map>
  801108:	89 c3                	mov    %eax,%ebx
  80110a:	83 c4 20             	add    $0x20,%esp
  80110d:	85 c0                	test   %eax,%eax
  80110f:	79 a4                	jns    8010b5 <dup+0x71>
	sys_page_unmap(0, newfd);
  801111:	83 ec 08             	sub    $0x8,%esp
  801114:	56                   	push   %esi
  801115:	6a 00                	push   $0x0
  801117:	e8 2f fb ff ff       	call   800c4b <sys_page_unmap>
	sys_page_unmap(0, nva);
  80111c:	83 c4 08             	add    $0x8,%esp
  80111f:	ff 75 d4             	push   -0x2c(%ebp)
  801122:	6a 00                	push   $0x0
  801124:	e8 22 fb ff ff       	call   800c4b <sys_page_unmap>
	return r;
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	eb b3                	jmp    8010e1 <dup+0x9d>

0080112e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	56                   	push   %esi
  801132:	53                   	push   %ebx
  801133:	83 ec 18             	sub    $0x18,%esp
  801136:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801139:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113c:	50                   	push   %eax
  80113d:	56                   	push   %esi
  80113e:	e8 87 fd ff ff       	call   800eca <fd_lookup>
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	78 3c                	js     801186 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801153:	50                   	push   %eax
  801154:	ff 33                	push   (%ebx)
  801156:	e8 bf fd ff ff       	call   800f1a <dev_lookup>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 24                	js     801186 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801162:	8b 43 08             	mov    0x8(%ebx),%eax
  801165:	83 e0 03             	and    $0x3,%eax
  801168:	83 f8 01             	cmp    $0x1,%eax
  80116b:	74 20                	je     80118d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80116d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801170:	8b 40 08             	mov    0x8(%eax),%eax
  801173:	85 c0                	test   %eax,%eax
  801175:	74 37                	je     8011ae <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801177:	83 ec 04             	sub    $0x4,%esp
  80117a:	ff 75 10             	push   0x10(%ebp)
  80117d:	ff 75 0c             	push   0xc(%ebp)
  801180:	53                   	push   %ebx
  801181:	ff d0                	call   *%eax
  801183:	83 c4 10             	add    $0x10,%esp
}
  801186:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80118d:	a1 00 40 80 00       	mov    0x804000,%eax
  801192:	8b 40 48             	mov    0x48(%eax),%eax
  801195:	83 ec 04             	sub    $0x4,%esp
  801198:	56                   	push   %esi
  801199:	50                   	push   %eax
  80119a:	68 11 23 80 00       	push   $0x802311
  80119f:	e8 4c f0 ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ac:	eb d8                	jmp    801186 <read+0x58>
		return -E_NOT_SUPP;
  8011ae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011b3:	eb d1                	jmp    801186 <read+0x58>

008011b5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	57                   	push   %edi
  8011b9:	56                   	push   %esi
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c9:	eb 02                	jmp    8011cd <readn+0x18>
  8011cb:	01 c3                	add    %eax,%ebx
  8011cd:	39 f3                	cmp    %esi,%ebx
  8011cf:	73 21                	jae    8011f2 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	89 f0                	mov    %esi,%eax
  8011d6:	29 d8                	sub    %ebx,%eax
  8011d8:	50                   	push   %eax
  8011d9:	89 d8                	mov    %ebx,%eax
  8011db:	03 45 0c             	add    0xc(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	57                   	push   %edi
  8011e0:	e8 49 ff ff ff       	call   80112e <read>
		if (m < 0)
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 04                	js     8011f0 <readn+0x3b>
			return m;
		if (m == 0)
  8011ec:	75 dd                	jne    8011cb <readn+0x16>
  8011ee:	eb 02                	jmp    8011f2 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011f0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011f2:	89 d8                	mov    %ebx,%eax
  8011f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f7:	5b                   	pop    %ebx
  8011f8:	5e                   	pop    %esi
  8011f9:	5f                   	pop    %edi
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	83 ec 18             	sub    $0x18,%esp
  801204:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801207:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120a:	50                   	push   %eax
  80120b:	53                   	push   %ebx
  80120c:	e8 b9 fc ff ff       	call   800eca <fd_lookup>
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	78 37                	js     80124f <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801218:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80121b:	83 ec 08             	sub    $0x8,%esp
  80121e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	ff 36                	push   (%esi)
  801224:	e8 f1 fc ff ff       	call   800f1a <dev_lookup>
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 1f                	js     80124f <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801230:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801234:	74 20                	je     801256 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801236:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801239:	8b 40 0c             	mov    0xc(%eax),%eax
  80123c:	85 c0                	test   %eax,%eax
  80123e:	74 37                	je     801277 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	ff 75 10             	push   0x10(%ebp)
  801246:	ff 75 0c             	push   0xc(%ebp)
  801249:	56                   	push   %esi
  80124a:	ff d0                	call   *%eax
  80124c:	83 c4 10             	add    $0x10,%esp
}
  80124f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801256:	a1 00 40 80 00       	mov    0x804000,%eax
  80125b:	8b 40 48             	mov    0x48(%eax),%eax
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	53                   	push   %ebx
  801262:	50                   	push   %eax
  801263:	68 2d 23 80 00       	push   $0x80232d
  801268:	e8 83 ef ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801275:	eb d8                	jmp    80124f <write+0x53>
		return -E_NOT_SUPP;
  801277:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80127c:	eb d1                	jmp    80124f <write+0x53>

0080127e <seek>:

int
seek(int fdnum, off_t offset)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801284:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801287:	50                   	push   %eax
  801288:	ff 75 08             	push   0x8(%ebp)
  80128b:	e8 3a fc ff ff       	call   800eca <fd_lookup>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 0e                	js     8012a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801297:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	56                   	push   %esi
  8012ab:	53                   	push   %ebx
  8012ac:	83 ec 18             	sub    $0x18,%esp
  8012af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b5:	50                   	push   %eax
  8012b6:	53                   	push   %ebx
  8012b7:	e8 0e fc ff ff       	call   800eca <fd_lookup>
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 34                	js     8012f7 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	ff 36                	push   (%esi)
  8012cf:	e8 46 fc ff ff       	call   800f1a <dev_lookup>
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 1c                	js     8012f7 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012db:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012df:	74 1d                	je     8012fe <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e4:	8b 40 18             	mov    0x18(%eax),%eax
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	74 34                	je     80131f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	ff 75 0c             	push   0xc(%ebp)
  8012f1:	56                   	push   %esi
  8012f2:	ff d0                	call   *%eax
  8012f4:	83 c4 10             	add    $0x10,%esp
}
  8012f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5e                   	pop    %esi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012fe:	a1 00 40 80 00       	mov    0x804000,%eax
  801303:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801306:	83 ec 04             	sub    $0x4,%esp
  801309:	53                   	push   %ebx
  80130a:	50                   	push   %eax
  80130b:	68 f0 22 80 00       	push   $0x8022f0
  801310:	e8 db ee ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131d:	eb d8                	jmp    8012f7 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80131f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801324:	eb d1                	jmp    8012f7 <ftruncate+0x50>

00801326 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
  80132b:	83 ec 18             	sub    $0x18,%esp
  80132e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801331:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801334:	50                   	push   %eax
  801335:	ff 75 08             	push   0x8(%ebp)
  801338:	e8 8d fb ff ff       	call   800eca <fd_lookup>
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	85 c0                	test   %eax,%eax
  801342:	78 49                	js     80138d <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801344:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	ff 36                	push   (%esi)
  801350:	e8 c5 fb ff ff       	call   800f1a <dev_lookup>
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 31                	js     80138d <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80135c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801363:	74 2f                	je     801394 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801365:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801368:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136f:	00 00 00 
	stat->st_isdir = 0;
  801372:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801379:	00 00 00 
	stat->st_dev = dev;
  80137c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	53                   	push   %ebx
  801386:	56                   	push   %esi
  801387:	ff 50 14             	call   *0x14(%eax)
  80138a:	83 c4 10             	add    $0x10,%esp
}
  80138d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    
		return -E_NOT_SUPP;
  801394:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801399:	eb f2                	jmp    80138d <fstat+0x67>

0080139b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	56                   	push   %esi
  80139f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	6a 00                	push   $0x0
  8013a5:	ff 75 08             	push   0x8(%ebp)
  8013a8:	e8 e4 01 00 00       	call   801591 <open>
  8013ad:	89 c3                	mov    %eax,%ebx
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 1b                	js     8013d1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	ff 75 0c             	push   0xc(%ebp)
  8013bc:	50                   	push   %eax
  8013bd:	e8 64 ff ff ff       	call   801326 <fstat>
  8013c2:	89 c6                	mov    %eax,%esi
	close(fd);
  8013c4:	89 1c 24             	mov    %ebx,(%esp)
  8013c7:	e8 26 fc ff ff       	call   800ff2 <close>
	return r;
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	89 f3                	mov    %esi,%ebx
}
  8013d1:	89 d8                	mov    %ebx,%eax
  8013d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	56                   	push   %esi
  8013de:	53                   	push   %ebx
  8013df:	89 c6                	mov    %eax,%esi
  8013e1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8013ea:	74 27                	je     801413 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ec:	6a 07                	push   $0x7
  8013ee:	68 00 50 80 00       	push   $0x805000
  8013f3:	56                   	push   %esi
  8013f4:	ff 35 00 60 80 00    	push   0x806000
  8013fa:	e8 5c 07 00 00       	call   801b5b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ff:	83 c4 0c             	add    $0xc,%esp
  801402:	6a 00                	push   $0x0
  801404:	53                   	push   %ebx
  801405:	6a 00                	push   $0x0
  801407:	e8 e8 06 00 00       	call   801af4 <ipc_recv>
}
  80140c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140f:	5b                   	pop    %ebx
  801410:	5e                   	pop    %esi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801413:	83 ec 0c             	sub    $0xc,%esp
  801416:	6a 01                	push   $0x1
  801418:	e8 92 07 00 00       	call   801baf <ipc_find_env>
  80141d:	a3 00 60 80 00       	mov    %eax,0x806000
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	eb c5                	jmp    8013ec <fsipc+0x12>

00801427 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	8b 40 0c             	mov    0xc(%eax),%eax
  801433:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801438:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801440:	ba 00 00 00 00       	mov    $0x0,%edx
  801445:	b8 02 00 00 00       	mov    $0x2,%eax
  80144a:	e8 8b ff ff ff       	call   8013da <fsipc>
}
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <devfile_flush>:
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801457:	8b 45 08             	mov    0x8(%ebp),%eax
  80145a:	8b 40 0c             	mov    0xc(%eax),%eax
  80145d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801462:	ba 00 00 00 00       	mov    $0x0,%edx
  801467:	b8 06 00 00 00       	mov    $0x6,%eax
  80146c:	e8 69 ff ff ff       	call   8013da <fsipc>
}
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <devfile_stat>:
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	53                   	push   %ebx
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80147d:	8b 45 08             	mov    0x8(%ebp),%eax
  801480:	8b 40 0c             	mov    0xc(%eax),%eax
  801483:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801488:	ba 00 00 00 00       	mov    $0x0,%edx
  80148d:	b8 05 00 00 00       	mov    $0x5,%eax
  801492:	e8 43 ff ff ff       	call   8013da <fsipc>
  801497:	85 c0                	test   %eax,%eax
  801499:	78 2c                	js     8014c7 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	68 00 50 80 00       	push   $0x805000
  8014a3:	53                   	push   %ebx
  8014a4:	e8 21 f3 ff ff       	call   8007ca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a9:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b4:	a1 84 50 80 00       	mov    0x805084,%eax
  8014b9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ca:	c9                   	leave  
  8014cb:	c3                   	ret    

008014cc <devfile_write>:
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8014d5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014da:	39 d0                	cmp    %edx,%eax
  8014dc:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014df:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014eb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014f0:	50                   	push   %eax
  8014f1:	ff 75 0c             	push   0xc(%ebp)
  8014f4:	68 08 50 80 00       	push   $0x805008
  8014f9:	e8 62 f4 ff ff       	call   800960 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8014fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801503:	b8 04 00 00 00       	mov    $0x4,%eax
  801508:	e8 cd fe ff ff       	call   8013da <fsipc>
}
  80150d:	c9                   	leave  
  80150e:	c3                   	ret    

0080150f <devfile_read>:
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	56                   	push   %esi
  801513:	53                   	push   %ebx
  801514:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801517:	8b 45 08             	mov    0x8(%ebp),%eax
  80151a:	8b 40 0c             	mov    0xc(%eax),%eax
  80151d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801522:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801528:	ba 00 00 00 00       	mov    $0x0,%edx
  80152d:	b8 03 00 00 00       	mov    $0x3,%eax
  801532:	e8 a3 fe ff ff       	call   8013da <fsipc>
  801537:	89 c3                	mov    %eax,%ebx
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 1f                	js     80155c <devfile_read+0x4d>
	assert(r <= n);
  80153d:	39 f0                	cmp    %esi,%eax
  80153f:	77 24                	ja     801565 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801541:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801546:	7f 33                	jg     80157b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801548:	83 ec 04             	sub    $0x4,%esp
  80154b:	50                   	push   %eax
  80154c:	68 00 50 80 00       	push   $0x805000
  801551:	ff 75 0c             	push   0xc(%ebp)
  801554:	e8 07 f4 ff ff       	call   800960 <memmove>
	return r;
  801559:	83 c4 10             	add    $0x10,%esp
}
  80155c:	89 d8                	mov    %ebx,%eax
  80155e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801561:	5b                   	pop    %ebx
  801562:	5e                   	pop    %esi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    
	assert(r <= n);
  801565:	68 5c 23 80 00       	push   $0x80235c
  80156a:	68 63 23 80 00       	push   $0x802363
  80156f:	6a 7c                	push   $0x7c
  801571:	68 78 23 80 00       	push   $0x802378
  801576:	e8 9a eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  80157b:	68 83 23 80 00       	push   $0x802383
  801580:	68 63 23 80 00       	push   $0x802363
  801585:	6a 7d                	push   $0x7d
  801587:	68 78 23 80 00       	push   $0x802378
  80158c:	e8 84 eb ff ff       	call   800115 <_panic>

00801591 <open>:
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	83 ec 1c             	sub    $0x1c,%esp
  801599:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80159c:	56                   	push   %esi
  80159d:	e8 ed f1 ff ff       	call   80078f <strlen>
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015aa:	7f 6c                	jg     801618 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015ac:	83 ec 0c             	sub    $0xc,%esp
  8015af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	e8 c2 f8 ff ff       	call   800e7a <fd_alloc>
  8015b8:	89 c3                	mov    %eax,%ebx
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 3c                	js     8015fd <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	56                   	push   %esi
  8015c5:	68 00 50 80 00       	push   $0x805000
  8015ca:	e8 fb f1 ff ff       	call   8007ca <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d2:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015da:	b8 01 00 00 00       	mov    $0x1,%eax
  8015df:	e8 f6 fd ff ff       	call   8013da <fsipc>
  8015e4:	89 c3                	mov    %eax,%ebx
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 19                	js     801606 <open+0x75>
	return fd2num(fd);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	ff 75 f4             	push   -0xc(%ebp)
  8015f3:	e8 5b f8 ff ff       	call   800e53 <fd2num>
  8015f8:	89 c3                	mov    %eax,%ebx
  8015fa:	83 c4 10             	add    $0x10,%esp
}
  8015fd:	89 d8                	mov    %ebx,%eax
  8015ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801602:	5b                   	pop    %ebx
  801603:	5e                   	pop    %esi
  801604:	5d                   	pop    %ebp
  801605:	c3                   	ret    
		fd_close(fd, 0);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	6a 00                	push   $0x0
  80160b:	ff 75 f4             	push   -0xc(%ebp)
  80160e:	e8 58 f9 ff ff       	call   800f6b <fd_close>
		return r;
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	eb e5                	jmp    8015fd <open+0x6c>
		return -E_BAD_PATH;
  801618:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80161d:	eb de                	jmp    8015fd <open+0x6c>

0080161f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801625:	ba 00 00 00 00       	mov    $0x0,%edx
  80162a:	b8 08 00 00 00       	mov    $0x8,%eax
  80162f:	e8 a6 fd ff ff       	call   8013da <fsipc>
}
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
  80163b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80163e:	83 ec 0c             	sub    $0xc,%esp
  801641:	ff 75 08             	push   0x8(%ebp)
  801644:	e8 1a f8 ff ff       	call   800e63 <fd2data>
  801649:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80164b:	83 c4 08             	add    $0x8,%esp
  80164e:	68 8f 23 80 00       	push   $0x80238f
  801653:	53                   	push   %ebx
  801654:	e8 71 f1 ff ff       	call   8007ca <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801659:	8b 46 04             	mov    0x4(%esi),%eax
  80165c:	2b 06                	sub    (%esi),%eax
  80165e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801664:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80166b:	00 00 00 
	stat->st_dev = &devpipe;
  80166e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801675:	30 80 00 
	return 0;
}
  801678:	b8 00 00 00 00       	mov    $0x0,%eax
  80167d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801680:	5b                   	pop    %ebx
  801681:	5e                   	pop    %esi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	53                   	push   %ebx
  801688:	83 ec 0c             	sub    $0xc,%esp
  80168b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80168e:	53                   	push   %ebx
  80168f:	6a 00                	push   $0x0
  801691:	e8 b5 f5 ff ff       	call   800c4b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801696:	89 1c 24             	mov    %ebx,(%esp)
  801699:	e8 c5 f7 ff ff       	call   800e63 <fd2data>
  80169e:	83 c4 08             	add    $0x8,%esp
  8016a1:	50                   	push   %eax
  8016a2:	6a 00                	push   $0x0
  8016a4:	e8 a2 f5 ff ff       	call   800c4b <sys_page_unmap>
}
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <_pipeisclosed>:
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	57                   	push   %edi
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 1c             	sub    $0x1c,%esp
  8016b7:	89 c7                	mov    %eax,%edi
  8016b9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016bb:	a1 00 40 80 00       	mov    0x804000,%eax
  8016c0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016c3:	83 ec 0c             	sub    $0xc,%esp
  8016c6:	57                   	push   %edi
  8016c7:	e8 1c 05 00 00       	call   801be8 <pageref>
  8016cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016cf:	89 34 24             	mov    %esi,(%esp)
  8016d2:	e8 11 05 00 00       	call   801be8 <pageref>
		nn = thisenv->env_runs;
  8016d7:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8016dd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	39 cb                	cmp    %ecx,%ebx
  8016e5:	74 1b                	je     801702 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016e7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016ea:	75 cf                	jne    8016bb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016ec:	8b 42 58             	mov    0x58(%edx),%eax
  8016ef:	6a 01                	push   $0x1
  8016f1:	50                   	push   %eax
  8016f2:	53                   	push   %ebx
  8016f3:	68 96 23 80 00       	push   $0x802396
  8016f8:	e8 f3 ea ff ff       	call   8001f0 <cprintf>
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	eb b9                	jmp    8016bb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801702:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801705:	0f 94 c0             	sete   %al
  801708:	0f b6 c0             	movzbl %al,%eax
}
  80170b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170e:	5b                   	pop    %ebx
  80170f:	5e                   	pop    %esi
  801710:	5f                   	pop    %edi
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    

00801713 <devpipe_write>:
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	57                   	push   %edi
  801717:	56                   	push   %esi
  801718:	53                   	push   %ebx
  801719:	83 ec 28             	sub    $0x28,%esp
  80171c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80171f:	56                   	push   %esi
  801720:	e8 3e f7 ff ff       	call   800e63 <fd2data>
  801725:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	bf 00 00 00 00       	mov    $0x0,%edi
  80172f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801732:	75 09                	jne    80173d <devpipe_write+0x2a>
	return i;
  801734:	89 f8                	mov    %edi,%eax
  801736:	eb 23                	jmp    80175b <devpipe_write+0x48>
			sys_yield();
  801738:	e8 6a f4 ff ff       	call   800ba7 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80173d:	8b 43 04             	mov    0x4(%ebx),%eax
  801740:	8b 0b                	mov    (%ebx),%ecx
  801742:	8d 51 20             	lea    0x20(%ecx),%edx
  801745:	39 d0                	cmp    %edx,%eax
  801747:	72 1a                	jb     801763 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801749:	89 da                	mov    %ebx,%edx
  80174b:	89 f0                	mov    %esi,%eax
  80174d:	e8 5c ff ff ff       	call   8016ae <_pipeisclosed>
  801752:	85 c0                	test   %eax,%eax
  801754:	74 e2                	je     801738 <devpipe_write+0x25>
				return 0;
  801756:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80175b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5f                   	pop    %edi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801766:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80176a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80176d:	89 c2                	mov    %eax,%edx
  80176f:	c1 fa 1f             	sar    $0x1f,%edx
  801772:	89 d1                	mov    %edx,%ecx
  801774:	c1 e9 1b             	shr    $0x1b,%ecx
  801777:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80177a:	83 e2 1f             	and    $0x1f,%edx
  80177d:	29 ca                	sub    %ecx,%edx
  80177f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801783:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801787:	83 c0 01             	add    $0x1,%eax
  80178a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80178d:	83 c7 01             	add    $0x1,%edi
  801790:	eb 9d                	jmp    80172f <devpipe_write+0x1c>

00801792 <devpipe_read>:
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	57                   	push   %edi
  801796:	56                   	push   %esi
  801797:	53                   	push   %ebx
  801798:	83 ec 18             	sub    $0x18,%esp
  80179b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80179e:	57                   	push   %edi
  80179f:	e8 bf f6 ff ff       	call   800e63 <fd2data>
  8017a4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	be 00 00 00 00       	mov    $0x0,%esi
  8017ae:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017b1:	75 13                	jne    8017c6 <devpipe_read+0x34>
	return i;
  8017b3:	89 f0                	mov    %esi,%eax
  8017b5:	eb 02                	jmp    8017b9 <devpipe_read+0x27>
				return i;
  8017b7:	89 f0                	mov    %esi,%eax
}
  8017b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017bc:	5b                   	pop    %ebx
  8017bd:	5e                   	pop    %esi
  8017be:	5f                   	pop    %edi
  8017bf:	5d                   	pop    %ebp
  8017c0:	c3                   	ret    
			sys_yield();
  8017c1:	e8 e1 f3 ff ff       	call   800ba7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017c6:	8b 03                	mov    (%ebx),%eax
  8017c8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017cb:	75 18                	jne    8017e5 <devpipe_read+0x53>
			if (i > 0)
  8017cd:	85 f6                	test   %esi,%esi
  8017cf:	75 e6                	jne    8017b7 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8017d1:	89 da                	mov    %ebx,%edx
  8017d3:	89 f8                	mov    %edi,%eax
  8017d5:	e8 d4 fe ff ff       	call   8016ae <_pipeisclosed>
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	74 e3                	je     8017c1 <devpipe_read+0x2f>
				return 0;
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e3:	eb d4                	jmp    8017b9 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017e5:	99                   	cltd   
  8017e6:	c1 ea 1b             	shr    $0x1b,%edx
  8017e9:	01 d0                	add    %edx,%eax
  8017eb:	83 e0 1f             	and    $0x1f,%eax
  8017ee:	29 d0                	sub    %edx,%eax
  8017f0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017fb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017fe:	83 c6 01             	add    $0x1,%esi
  801801:	eb ab                	jmp    8017ae <devpipe_read+0x1c>

00801803 <pipe>:
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	56                   	push   %esi
  801807:	53                   	push   %ebx
  801808:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80180b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180e:	50                   	push   %eax
  80180f:	e8 66 f6 ff ff       	call   800e7a <fd_alloc>
  801814:	89 c3                	mov    %eax,%ebx
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	85 c0                	test   %eax,%eax
  80181b:	0f 88 23 01 00 00    	js     801944 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801821:	83 ec 04             	sub    $0x4,%esp
  801824:	68 07 04 00 00       	push   $0x407
  801829:	ff 75 f4             	push   -0xc(%ebp)
  80182c:	6a 00                	push   $0x0
  80182e:	e8 93 f3 ff ff       	call   800bc6 <sys_page_alloc>
  801833:	89 c3                	mov    %eax,%ebx
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	0f 88 04 01 00 00    	js     801944 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801840:	83 ec 0c             	sub    $0xc,%esp
  801843:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801846:	50                   	push   %eax
  801847:	e8 2e f6 ff ff       	call   800e7a <fd_alloc>
  80184c:	89 c3                	mov    %eax,%ebx
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	85 c0                	test   %eax,%eax
  801853:	0f 88 db 00 00 00    	js     801934 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801859:	83 ec 04             	sub    $0x4,%esp
  80185c:	68 07 04 00 00       	push   $0x407
  801861:	ff 75 f0             	push   -0x10(%ebp)
  801864:	6a 00                	push   $0x0
  801866:	e8 5b f3 ff ff       	call   800bc6 <sys_page_alloc>
  80186b:	89 c3                	mov    %eax,%ebx
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	85 c0                	test   %eax,%eax
  801872:	0f 88 bc 00 00 00    	js     801934 <pipe+0x131>
	va = fd2data(fd0);
  801878:	83 ec 0c             	sub    $0xc,%esp
  80187b:	ff 75 f4             	push   -0xc(%ebp)
  80187e:	e8 e0 f5 ff ff       	call   800e63 <fd2data>
  801883:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801885:	83 c4 0c             	add    $0xc,%esp
  801888:	68 07 04 00 00       	push   $0x407
  80188d:	50                   	push   %eax
  80188e:	6a 00                	push   $0x0
  801890:	e8 31 f3 ff ff       	call   800bc6 <sys_page_alloc>
  801895:	89 c3                	mov    %eax,%ebx
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	0f 88 82 00 00 00    	js     801924 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a2:	83 ec 0c             	sub    $0xc,%esp
  8018a5:	ff 75 f0             	push   -0x10(%ebp)
  8018a8:	e8 b6 f5 ff ff       	call   800e63 <fd2data>
  8018ad:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018b4:	50                   	push   %eax
  8018b5:	6a 00                	push   $0x0
  8018b7:	56                   	push   %esi
  8018b8:	6a 00                	push   $0x0
  8018ba:	e8 4a f3 ff ff       	call   800c09 <sys_page_map>
  8018bf:	89 c3                	mov    %eax,%ebx
  8018c1:	83 c4 20             	add    $0x20,%esp
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 4e                	js     801916 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8018c8:	a1 20 30 80 00       	mov    0x803020,%eax
  8018cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d0:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8018d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d5:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8018dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018df:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8018e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	ff 75 f4             	push   -0xc(%ebp)
  8018f1:	e8 5d f5 ff ff       	call   800e53 <fd2num>
  8018f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018fb:	83 c4 04             	add    $0x4,%esp
  8018fe:	ff 75 f0             	push   -0x10(%ebp)
  801901:	e8 4d f5 ff ff       	call   800e53 <fd2num>
  801906:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801909:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801914:	eb 2e                	jmp    801944 <pipe+0x141>
	sys_page_unmap(0, va);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	56                   	push   %esi
  80191a:	6a 00                	push   $0x0
  80191c:	e8 2a f3 ff ff       	call   800c4b <sys_page_unmap>
  801921:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	ff 75 f0             	push   -0x10(%ebp)
  80192a:	6a 00                	push   $0x0
  80192c:	e8 1a f3 ff ff       	call   800c4b <sys_page_unmap>
  801931:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	ff 75 f4             	push   -0xc(%ebp)
  80193a:	6a 00                	push   $0x0
  80193c:	e8 0a f3 ff ff       	call   800c4b <sys_page_unmap>
  801941:	83 c4 10             	add    $0x10,%esp
}
  801944:	89 d8                	mov    %ebx,%eax
  801946:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801949:	5b                   	pop    %ebx
  80194a:	5e                   	pop    %esi
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    

0080194d <pipeisclosed>:
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801956:	50                   	push   %eax
  801957:	ff 75 08             	push   0x8(%ebp)
  80195a:	e8 6b f5 ff ff       	call   800eca <fd_lookup>
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	85 c0                	test   %eax,%eax
  801964:	78 18                	js     80197e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801966:	83 ec 0c             	sub    $0xc,%esp
  801969:	ff 75 f4             	push   -0xc(%ebp)
  80196c:	e8 f2 f4 ff ff       	call   800e63 <fd2data>
  801971:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801973:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801976:	e8 33 fd ff ff       	call   8016ae <_pipeisclosed>
  80197b:	83 c4 10             	add    $0x10,%esp
}
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801980:	b8 00 00 00 00       	mov    $0x0,%eax
  801985:	c3                   	ret    

00801986 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80198c:	68 ae 23 80 00       	push   $0x8023ae
  801991:	ff 75 0c             	push   0xc(%ebp)
  801994:	e8 31 ee ff ff       	call   8007ca <strcpy>
	return 0;
}
  801999:	b8 00 00 00 00       	mov    $0x0,%eax
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <devcons_write>:
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	57                   	push   %edi
  8019a4:	56                   	push   %esi
  8019a5:	53                   	push   %ebx
  8019a6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019ac:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019b1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019b7:	eb 2e                	jmp    8019e7 <devcons_write+0x47>
		m = n - tot;
  8019b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019bc:	29 f3                	sub    %esi,%ebx
  8019be:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8019c3:	39 c3                	cmp    %eax,%ebx
  8019c5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019c8:	83 ec 04             	sub    $0x4,%esp
  8019cb:	53                   	push   %ebx
  8019cc:	89 f0                	mov    %esi,%eax
  8019ce:	03 45 0c             	add    0xc(%ebp),%eax
  8019d1:	50                   	push   %eax
  8019d2:	57                   	push   %edi
  8019d3:	e8 88 ef ff ff       	call   800960 <memmove>
		sys_cputs(buf, m);
  8019d8:	83 c4 08             	add    $0x8,%esp
  8019db:	53                   	push   %ebx
  8019dc:	57                   	push   %edi
  8019dd:	e8 28 f1 ff ff       	call   800b0a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019e2:	01 de                	add    %ebx,%esi
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019ea:	72 cd                	jb     8019b9 <devcons_write+0x19>
}
  8019ec:	89 f0                	mov    %esi,%eax
  8019ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f1:	5b                   	pop    %ebx
  8019f2:	5e                   	pop    %esi
  8019f3:	5f                   	pop    %edi
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <devcons_read>:
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 08             	sub    $0x8,%esp
  8019fc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a05:	75 07                	jne    801a0e <devcons_read+0x18>
  801a07:	eb 1f                	jmp    801a28 <devcons_read+0x32>
		sys_yield();
  801a09:	e8 99 f1 ff ff       	call   800ba7 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a0e:	e8 15 f1 ff ff       	call   800b28 <sys_cgetc>
  801a13:	85 c0                	test   %eax,%eax
  801a15:	74 f2                	je     801a09 <devcons_read+0x13>
	if (c < 0)
  801a17:	78 0f                	js     801a28 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801a19:	83 f8 04             	cmp    $0x4,%eax
  801a1c:	74 0c                	je     801a2a <devcons_read+0x34>
	*(char*)vbuf = c;
  801a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a21:	88 02                	mov    %al,(%edx)
	return 1;
  801a23:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    
		return 0;
  801a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2f:	eb f7                	jmp    801a28 <devcons_read+0x32>

00801a31 <cputchar>:
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a37:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a3d:	6a 01                	push   $0x1
  801a3f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a42:	50                   	push   %eax
  801a43:	e8 c2 f0 ff ff       	call   800b0a <sys_cputs>
}
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	c9                   	leave  
  801a4c:	c3                   	ret    

00801a4d <getchar>:
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a53:	6a 01                	push   $0x1
  801a55:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a58:	50                   	push   %eax
  801a59:	6a 00                	push   $0x0
  801a5b:	e8 ce f6 ff ff       	call   80112e <read>
	if (r < 0)
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 06                	js     801a6d <getchar+0x20>
	if (r < 1)
  801a67:	74 06                	je     801a6f <getchar+0x22>
	return c;
  801a69:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    
		return -E_EOF;
  801a6f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a74:	eb f7                	jmp    801a6d <getchar+0x20>

00801a76 <iscons>:
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7f:	50                   	push   %eax
  801a80:	ff 75 08             	push   0x8(%ebp)
  801a83:	e8 42 f4 ff ff       	call   800eca <fd_lookup>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 11                	js     801aa0 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a92:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a98:	39 10                	cmp    %edx,(%eax)
  801a9a:	0f 94 c0             	sete   %al
  801a9d:	0f b6 c0             	movzbl %al,%eax
}
  801aa0:	c9                   	leave  
  801aa1:	c3                   	ret    

00801aa2 <opencons>:
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801aa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aab:	50                   	push   %eax
  801aac:	e8 c9 f3 ff ff       	call   800e7a <fd_alloc>
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	78 3a                	js     801af2 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab8:	83 ec 04             	sub    $0x4,%esp
  801abb:	68 07 04 00 00       	push   $0x407
  801ac0:	ff 75 f4             	push   -0xc(%ebp)
  801ac3:	6a 00                	push   $0x0
  801ac5:	e8 fc f0 ff ff       	call   800bc6 <sys_page_alloc>
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	78 21                	js     801af2 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ada:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	50                   	push   %eax
  801aea:	e8 64 f3 ff ff       	call   800e53 <fd2num>
  801aef:	83 c4 10             	add    $0x10,%esp
}
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	56                   	push   %esi
  801af8:	53                   	push   %ebx
  801af9:	8b 75 08             	mov    0x8(%ebp),%esi
  801afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801b02:	85 c0                	test   %eax,%eax
  801b04:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b09:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801b0c:	83 ec 0c             	sub    $0xc,%esp
  801b0f:	50                   	push   %eax
  801b10:	e8 61 f2 ff ff       	call   800d76 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	85 f6                	test   %esi,%esi
  801b1a:	74 14                	je     801b30 <ipc_recv+0x3c>
  801b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b21:	85 c0                	test   %eax,%eax
  801b23:	78 09                	js     801b2e <ipc_recv+0x3a>
  801b25:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801b2b:	8b 52 74             	mov    0x74(%edx),%edx
  801b2e:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801b30:	85 db                	test   %ebx,%ebx
  801b32:	74 14                	je     801b48 <ipc_recv+0x54>
  801b34:	ba 00 00 00 00       	mov    $0x0,%edx
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 09                	js     801b46 <ipc_recv+0x52>
  801b3d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801b43:	8b 52 78             	mov    0x78(%edx),%edx
  801b46:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	78 08                	js     801b54 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801b4c:	a1 00 40 80 00       	mov    0x804000,%eax
  801b51:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b57:	5b                   	pop    %ebx
  801b58:	5e                   	pop    %esi
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	57                   	push   %edi
  801b5f:	56                   	push   %esi
  801b60:	53                   	push   %ebx
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b67:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801b6d:	85 db                	test   %ebx,%ebx
  801b6f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b74:	0f 44 d8             	cmove  %eax,%ebx
  801b77:	eb 05                	jmp    801b7e <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b79:	e8 29 f0 ff ff       	call   800ba7 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801b7e:	ff 75 14             	push   0x14(%ebp)
  801b81:	53                   	push   %ebx
  801b82:	56                   	push   %esi
  801b83:	57                   	push   %edi
  801b84:	e8 ca f1 ff ff       	call   800d53 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b8f:	74 e8                	je     801b79 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801b91:	85 c0                	test   %eax,%eax
  801b93:	78 08                	js     801b9d <ipc_send+0x42>
	}while (r<0);

}
  801b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5e                   	pop    %esi
  801b9a:	5f                   	pop    %edi
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801b9d:	50                   	push   %eax
  801b9e:	68 ba 23 80 00       	push   $0x8023ba
  801ba3:	6a 3d                	push   $0x3d
  801ba5:	68 ce 23 80 00       	push   $0x8023ce
  801baa:	e8 66 e5 ff ff       	call   800115 <_panic>

00801baf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bbd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bc3:	8b 52 50             	mov    0x50(%edx),%edx
  801bc6:	39 ca                	cmp    %ecx,%edx
  801bc8:	74 11                	je     801bdb <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801bca:	83 c0 01             	add    $0x1,%eax
  801bcd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bd2:	75 e6                	jne    801bba <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd9:	eb 0b                	jmp    801be6 <ipc_find_env+0x37>
			return envs[i].env_id;
  801bdb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bde:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801be3:	8b 40 48             	mov    0x48(%eax),%eax
}
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bee:	89 c2                	mov    %eax,%edx
  801bf0:	c1 ea 16             	shr    $0x16,%edx
  801bf3:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801bfa:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801bff:	f6 c1 01             	test   $0x1,%cl
  801c02:	74 1c                	je     801c20 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801c04:	c1 e8 0c             	shr    $0xc,%eax
  801c07:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c0e:	a8 01                	test   $0x1,%al
  801c10:	74 0e                	je     801c20 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c12:	c1 e8 0c             	shr    $0xc,%eax
  801c15:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c1c:	ef 
  801c1d:	0f b7 d2             	movzwl %dx,%edx
}
  801c20:	89 d0                	mov    %edx,%eax
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    
  801c24:	66 90                	xchg   %ax,%ax
  801c26:	66 90                	xchg   %ax,%ax
  801c28:	66 90                	xchg   %ax,%ax
  801c2a:	66 90                	xchg   %ax,%ax
  801c2c:	66 90                	xchg   %ax,%ax
  801c2e:	66 90                	xchg   %ax,%ax

00801c30 <__udivdi3>:
  801c30:	f3 0f 1e fb          	endbr32 
  801c34:	55                   	push   %ebp
  801c35:	57                   	push   %edi
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	83 ec 1c             	sub    $0x1c,%esp
  801c3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c43:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	75 19                	jne    801c68 <__udivdi3+0x38>
  801c4f:	39 f3                	cmp    %esi,%ebx
  801c51:	76 4d                	jbe    801ca0 <__udivdi3+0x70>
  801c53:	31 ff                	xor    %edi,%edi
  801c55:	89 e8                	mov    %ebp,%eax
  801c57:	89 f2                	mov    %esi,%edx
  801c59:	f7 f3                	div    %ebx
  801c5b:	89 fa                	mov    %edi,%edx
  801c5d:	83 c4 1c             	add    $0x1c,%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    
  801c65:	8d 76 00             	lea    0x0(%esi),%esi
  801c68:	39 f0                	cmp    %esi,%eax
  801c6a:	76 14                	jbe    801c80 <__udivdi3+0x50>
  801c6c:	31 ff                	xor    %edi,%edi
  801c6e:	31 c0                	xor    %eax,%eax
  801c70:	89 fa                	mov    %edi,%edx
  801c72:	83 c4 1c             	add    $0x1c,%esp
  801c75:	5b                   	pop    %ebx
  801c76:	5e                   	pop    %esi
  801c77:	5f                   	pop    %edi
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    
  801c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c80:	0f bd f8             	bsr    %eax,%edi
  801c83:	83 f7 1f             	xor    $0x1f,%edi
  801c86:	75 48                	jne    801cd0 <__udivdi3+0xa0>
  801c88:	39 f0                	cmp    %esi,%eax
  801c8a:	72 06                	jb     801c92 <__udivdi3+0x62>
  801c8c:	31 c0                	xor    %eax,%eax
  801c8e:	39 eb                	cmp    %ebp,%ebx
  801c90:	77 de                	ja     801c70 <__udivdi3+0x40>
  801c92:	b8 01 00 00 00       	mov    $0x1,%eax
  801c97:	eb d7                	jmp    801c70 <__udivdi3+0x40>
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d9                	mov    %ebx,%ecx
  801ca2:	85 db                	test   %ebx,%ebx
  801ca4:	75 0b                	jne    801cb1 <__udivdi3+0x81>
  801ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	f7 f3                	div    %ebx
  801caf:	89 c1                	mov    %eax,%ecx
  801cb1:	31 d2                	xor    %edx,%edx
  801cb3:	89 f0                	mov    %esi,%eax
  801cb5:	f7 f1                	div    %ecx
  801cb7:	89 c6                	mov    %eax,%esi
  801cb9:	89 e8                	mov    %ebp,%eax
  801cbb:	89 f7                	mov    %esi,%edi
  801cbd:	f7 f1                	div    %ecx
  801cbf:	89 fa                	mov    %edi,%edx
  801cc1:	83 c4 1c             	add    $0x1c,%esp
  801cc4:	5b                   	pop    %ebx
  801cc5:	5e                   	pop    %esi
  801cc6:	5f                   	pop    %edi
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 f9                	mov    %edi,%ecx
  801cd2:	ba 20 00 00 00       	mov    $0x20,%edx
  801cd7:	29 fa                	sub    %edi,%edx
  801cd9:	d3 e0                	shl    %cl,%eax
  801cdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cdf:	89 d1                	mov    %edx,%ecx
  801ce1:	89 d8                	mov    %ebx,%eax
  801ce3:	d3 e8                	shr    %cl,%eax
  801ce5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ce9:	09 c1                	or     %eax,%ecx
  801ceb:	89 f0                	mov    %esi,%eax
  801ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cf1:	89 f9                	mov    %edi,%ecx
  801cf3:	d3 e3                	shl    %cl,%ebx
  801cf5:	89 d1                	mov    %edx,%ecx
  801cf7:	d3 e8                	shr    %cl,%eax
  801cf9:	89 f9                	mov    %edi,%ecx
  801cfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801cff:	89 eb                	mov    %ebp,%ebx
  801d01:	d3 e6                	shl    %cl,%esi
  801d03:	89 d1                	mov    %edx,%ecx
  801d05:	d3 eb                	shr    %cl,%ebx
  801d07:	09 f3                	or     %esi,%ebx
  801d09:	89 c6                	mov    %eax,%esi
  801d0b:	89 f2                	mov    %esi,%edx
  801d0d:	89 d8                	mov    %ebx,%eax
  801d0f:	f7 74 24 08          	divl   0x8(%esp)
  801d13:	89 d6                	mov    %edx,%esi
  801d15:	89 c3                	mov    %eax,%ebx
  801d17:	f7 64 24 0c          	mull   0xc(%esp)
  801d1b:	39 d6                	cmp    %edx,%esi
  801d1d:	72 19                	jb     801d38 <__udivdi3+0x108>
  801d1f:	89 f9                	mov    %edi,%ecx
  801d21:	d3 e5                	shl    %cl,%ebp
  801d23:	39 c5                	cmp    %eax,%ebp
  801d25:	73 04                	jae    801d2b <__udivdi3+0xfb>
  801d27:	39 d6                	cmp    %edx,%esi
  801d29:	74 0d                	je     801d38 <__udivdi3+0x108>
  801d2b:	89 d8                	mov    %ebx,%eax
  801d2d:	31 ff                	xor    %edi,%edi
  801d2f:	e9 3c ff ff ff       	jmp    801c70 <__udivdi3+0x40>
  801d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d38:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d3b:	31 ff                	xor    %edi,%edi
  801d3d:	e9 2e ff ff ff       	jmp    801c70 <__udivdi3+0x40>
  801d42:	66 90                	xchg   %ax,%ax
  801d44:	66 90                	xchg   %ax,%ax
  801d46:	66 90                	xchg   %ax,%ax
  801d48:	66 90                	xchg   %ax,%ax
  801d4a:	66 90                	xchg   %ax,%ax
  801d4c:	66 90                	xchg   %ax,%ax
  801d4e:	66 90                	xchg   %ax,%ax

00801d50 <__umoddi3>:
  801d50:	f3 0f 1e fb          	endbr32 
  801d54:	55                   	push   %ebp
  801d55:	57                   	push   %edi
  801d56:	56                   	push   %esi
  801d57:	53                   	push   %ebx
  801d58:	83 ec 1c             	sub    $0x1c,%esp
  801d5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d63:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801d67:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801d6b:	89 f0                	mov    %esi,%eax
  801d6d:	89 da                	mov    %ebx,%edx
  801d6f:	85 ff                	test   %edi,%edi
  801d71:	75 15                	jne    801d88 <__umoddi3+0x38>
  801d73:	39 dd                	cmp    %ebx,%ebp
  801d75:	76 39                	jbe    801db0 <__umoddi3+0x60>
  801d77:	f7 f5                	div    %ebp
  801d79:	89 d0                	mov    %edx,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	83 c4 1c             	add    $0x1c,%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    
  801d85:	8d 76 00             	lea    0x0(%esi),%esi
  801d88:	39 df                	cmp    %ebx,%edi
  801d8a:	77 f1                	ja     801d7d <__umoddi3+0x2d>
  801d8c:	0f bd cf             	bsr    %edi,%ecx
  801d8f:	83 f1 1f             	xor    $0x1f,%ecx
  801d92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d96:	75 40                	jne    801dd8 <__umoddi3+0x88>
  801d98:	39 df                	cmp    %ebx,%edi
  801d9a:	72 04                	jb     801da0 <__umoddi3+0x50>
  801d9c:	39 f5                	cmp    %esi,%ebp
  801d9e:	77 dd                	ja     801d7d <__umoddi3+0x2d>
  801da0:	89 da                	mov    %ebx,%edx
  801da2:	89 f0                	mov    %esi,%eax
  801da4:	29 e8                	sub    %ebp,%eax
  801da6:	19 fa                	sbb    %edi,%edx
  801da8:	eb d3                	jmp    801d7d <__umoddi3+0x2d>
  801daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db0:	89 e9                	mov    %ebp,%ecx
  801db2:	85 ed                	test   %ebp,%ebp
  801db4:	75 0b                	jne    801dc1 <__umoddi3+0x71>
  801db6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbb:	31 d2                	xor    %edx,%edx
  801dbd:	f7 f5                	div    %ebp
  801dbf:	89 c1                	mov    %eax,%ecx
  801dc1:	89 d8                	mov    %ebx,%eax
  801dc3:	31 d2                	xor    %edx,%edx
  801dc5:	f7 f1                	div    %ecx
  801dc7:	89 f0                	mov    %esi,%eax
  801dc9:	f7 f1                	div    %ecx
  801dcb:	89 d0                	mov    %edx,%eax
  801dcd:	31 d2                	xor    %edx,%edx
  801dcf:	eb ac                	jmp    801d7d <__umoddi3+0x2d>
  801dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ddc:	ba 20 00 00 00       	mov    $0x20,%edx
  801de1:	29 c2                	sub    %eax,%edx
  801de3:	89 c1                	mov    %eax,%ecx
  801de5:	89 e8                	mov    %ebp,%eax
  801de7:	d3 e7                	shl    %cl,%edi
  801de9:	89 d1                	mov    %edx,%ecx
  801deb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801def:	d3 e8                	shr    %cl,%eax
  801df1:	89 c1                	mov    %eax,%ecx
  801df3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801df7:	09 f9                	or     %edi,%ecx
  801df9:	89 df                	mov    %ebx,%edi
  801dfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dff:	89 c1                	mov    %eax,%ecx
  801e01:	d3 e5                	shl    %cl,%ebp
  801e03:	89 d1                	mov    %edx,%ecx
  801e05:	d3 ef                	shr    %cl,%edi
  801e07:	89 c1                	mov    %eax,%ecx
  801e09:	89 f0                	mov    %esi,%eax
  801e0b:	d3 e3                	shl    %cl,%ebx
  801e0d:	89 d1                	mov    %edx,%ecx
  801e0f:	89 fa                	mov    %edi,%edx
  801e11:	d3 e8                	shr    %cl,%eax
  801e13:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e18:	09 d8                	or     %ebx,%eax
  801e1a:	f7 74 24 08          	divl   0x8(%esp)
  801e1e:	89 d3                	mov    %edx,%ebx
  801e20:	d3 e6                	shl    %cl,%esi
  801e22:	f7 e5                	mul    %ebp
  801e24:	89 c7                	mov    %eax,%edi
  801e26:	89 d1                	mov    %edx,%ecx
  801e28:	39 d3                	cmp    %edx,%ebx
  801e2a:	72 06                	jb     801e32 <__umoddi3+0xe2>
  801e2c:	75 0e                	jne    801e3c <__umoddi3+0xec>
  801e2e:	39 c6                	cmp    %eax,%esi
  801e30:	73 0a                	jae    801e3c <__umoddi3+0xec>
  801e32:	29 e8                	sub    %ebp,%eax
  801e34:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e38:	89 d1                	mov    %edx,%ecx
  801e3a:	89 c7                	mov    %eax,%edi
  801e3c:	89 f5                	mov    %esi,%ebp
  801e3e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e42:	29 fd                	sub    %edi,%ebp
  801e44:	19 cb                	sbb    %ecx,%ebx
  801e46:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801e4b:	89 d8                	mov    %ebx,%eax
  801e4d:	d3 e0                	shl    %cl,%eax
  801e4f:	89 f1                	mov    %esi,%ecx
  801e51:	d3 ed                	shr    %cl,%ebp
  801e53:	d3 eb                	shr    %cl,%ebx
  801e55:	09 e8                	or     %ebp,%eax
  801e57:	89 da                	mov    %ebx,%edx
  801e59:	83 c4 1c             	add    $0x1c,%esp
  801e5c:	5b                   	pop    %ebx
  801e5d:	5e                   	pop    %esi
  801e5e:	5f                   	pop    %edi
  801e5f:	5d                   	pop    %ebp
  801e60:	c3                   	ret    
