
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
  800040:	68 60 23 80 00       	push   $0x802360
  800045:	e8 a9 01 00 00       	call   8001f3 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 6b 0b 00 00       	call   800bc9 <sys_page_alloc>
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
  80006e:	e8 05 07 00 00       	call   800778 <snprintf>
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
  800085:	6a 0f                	push   $0xf
  800087:	68 6a 23 80 00       	push   $0x80236a
  80008c:	e8 87 00 00 00       	call   800118 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 7a 0d 00 00       	call   800e1b <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 5d 0a 00 00       	call   800b0d <sys_cputs>
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
  8000c0:	e8 c6 0a 00 00       	call   800b8b <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8000d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d5:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000da:	85 db                	test   %ebx,%ebx
  8000dc:	7e 07                	jle    8000e5 <libmain+0x30>
		binaryname = argv[0];
  8000de:	8b 06                	mov    (%esi),%eax
  8000e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e5:	83 ec 08             	sub    $0x8,%esp
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	e8 a2 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ef:	e8 0a 00 00 00       	call   8000fe <exit>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800104:	e8 7f 0f 00 00       	call   801088 <close_all>
	sys_env_destroy(0);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	6a 00                	push   $0x0
  80010e:	e8 37 0a 00 00       	call   800b4a <sys_env_destroy>
}
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800120:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800126:	e8 60 0a 00 00       	call   800b8b <sys_getenvid>
  80012b:	83 ec 0c             	sub    $0xc,%esp
  80012e:	ff 75 0c             	push   0xc(%ebp)
  800131:	ff 75 08             	push   0x8(%ebp)
  800134:	56                   	push   %esi
  800135:	50                   	push   %eax
  800136:	68 d8 23 80 00       	push   $0x8023d8
  80013b:	e8 b3 00 00 00       	call   8001f3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800140:	83 c4 18             	add    $0x18,%esp
  800143:	53                   	push   %ebx
  800144:	ff 75 10             	push   0x10(%ebp)
  800147:	e8 56 00 00 00       	call   8001a2 <vcprintf>
	cprintf("\n");
  80014c:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  800153:	e8 9b 00 00 00       	call   8001f3 <cprintf>
  800158:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80015b:	cc                   	int3   
  80015c:	eb fd                	jmp    80015b <_panic+0x43>

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	74 09                	je     800186 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800181:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800184:	c9                   	leave  
  800185:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800186:	83 ec 08             	sub    $0x8,%esp
  800189:	68 ff 00 00 00       	push   $0xff
  80018e:	8d 43 08             	lea    0x8(%ebx),%eax
  800191:	50                   	push   %eax
  800192:	e8 76 09 00 00       	call   800b0d <sys_cputs>
		b->idx = 0;
  800197:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb db                	jmp    80017d <putch+0x1f>

008001a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b2:	00 00 00 
	b.cnt = 0;
  8001b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bf:	ff 75 0c             	push   0xc(%ebp)
  8001c2:	ff 75 08             	push   0x8(%ebp)
  8001c5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 5e 01 80 00       	push   $0x80015e
  8001d1:	e8 14 01 00 00       	call   8002ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d6:	83 c4 08             	add    $0x8,%esp
  8001d9:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001df:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e5:	50                   	push   %eax
  8001e6:	e8 22 09 00 00       	call   800b0d <sys_cputs>

	return b.cnt;
}
  8001eb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fc:	50                   	push   %eax
  8001fd:	ff 75 08             	push   0x8(%ebp)
  800200:	e8 9d ff ff ff       	call   8001a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	57                   	push   %edi
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	83 ec 1c             	sub    $0x1c,%esp
  800210:	89 c7                	mov    %eax,%edi
  800212:	89 d6                	mov    %edx,%esi
  800214:	8b 45 08             	mov    0x8(%ebp),%eax
  800217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021a:	89 d1                	mov    %edx,%ecx
  80021c:	89 c2                	mov    %eax,%edx
  80021e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800221:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800224:	8b 45 10             	mov    0x10(%ebp),%eax
  800227:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800234:	39 c2                	cmp    %eax,%edx
  800236:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800239:	72 3e                	jb     800279 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	ff 75 18             	push   0x18(%ebp)
  800241:	83 eb 01             	sub    $0x1,%ebx
  800244:	53                   	push   %ebx
  800245:	50                   	push   %eax
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	ff 75 e4             	push   -0x1c(%ebp)
  80024c:	ff 75 e0             	push   -0x20(%ebp)
  80024f:	ff 75 dc             	push   -0x24(%ebp)
  800252:	ff 75 d8             	push   -0x28(%ebp)
  800255:	e8 b6 1e 00 00       	call   802110 <__udivdi3>
  80025a:	83 c4 18             	add    $0x18,%esp
  80025d:	52                   	push   %edx
  80025e:	50                   	push   %eax
  80025f:	89 f2                	mov    %esi,%edx
  800261:	89 f8                	mov    %edi,%eax
  800263:	e8 9f ff ff ff       	call   800207 <printnum>
  800268:	83 c4 20             	add    $0x20,%esp
  80026b:	eb 13                	jmp    800280 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	56                   	push   %esi
  800271:	ff 75 18             	push   0x18(%ebp)
  800274:	ff d7                	call   *%edi
  800276:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800279:	83 eb 01             	sub    $0x1,%ebx
  80027c:	85 db                	test   %ebx,%ebx
  80027e:	7f ed                	jg     80026d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	83 ec 04             	sub    $0x4,%esp
  800287:	ff 75 e4             	push   -0x1c(%ebp)
  80028a:	ff 75 e0             	push   -0x20(%ebp)
  80028d:	ff 75 dc             	push   -0x24(%ebp)
  800290:	ff 75 d8             	push   -0x28(%ebp)
  800293:	e8 98 1f 00 00       	call   802230 <__umoddi3>
  800298:	83 c4 14             	add    $0x14,%esp
  80029b:	0f be 80 fb 23 80 00 	movsbl 0x8023fb(%eax),%eax
  8002a2:	50                   	push   %eax
  8002a3:	ff d7                	call   *%edi
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5f                   	pop    %edi
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bf:	73 0a                	jae    8002cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c9:	88 02                	mov    %al,(%edx)
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <printfmt>:
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d6:	50                   	push   %eax
  8002d7:	ff 75 10             	push   0x10(%ebp)
  8002da:	ff 75 0c             	push   0xc(%ebp)
  8002dd:	ff 75 08             	push   0x8(%ebp)
  8002e0:	e8 05 00 00 00       	call   8002ea <vprintfmt>
}
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <vprintfmt>:
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	57                   	push   %edi
  8002ee:	56                   	push   %esi
  8002ef:	53                   	push   %ebx
  8002f0:	83 ec 3c             	sub    $0x3c,%esp
  8002f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fc:	eb 0a                	jmp    800308 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002fe:	83 ec 08             	sub    $0x8,%esp
  800301:	53                   	push   %ebx
  800302:	50                   	push   %eax
  800303:	ff d6                	call   *%esi
  800305:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800308:	83 c7 01             	add    $0x1,%edi
  80030b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030f:	83 f8 25             	cmp    $0x25,%eax
  800312:	74 0c                	je     800320 <vprintfmt+0x36>
			if (ch == '\0')
  800314:	85 c0                	test   %eax,%eax
  800316:	75 e6                	jne    8002fe <vprintfmt+0x14>
}
  800318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    
		padc = ' ';
  800320:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800324:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80032b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800332:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800339:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8d 47 01             	lea    0x1(%edi),%eax
  800341:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800344:	0f b6 17             	movzbl (%edi),%edx
  800347:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034a:	3c 55                	cmp    $0x55,%al
  80034c:	0f 87 bb 03 00 00    	ja     80070d <vprintfmt+0x423>
  800352:	0f b6 c0             	movzbl %al,%eax
  800355:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80035f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800363:	eb d9                	jmp    80033e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800368:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80036c:	eb d0                	jmp    80033e <vprintfmt+0x54>
  80036e:	0f b6 d2             	movzbl %dl,%edx
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800374:	b8 00 00 00 00       	mov    $0x0,%eax
  800379:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80037c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800383:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800386:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800389:	83 f9 09             	cmp    $0x9,%ecx
  80038c:	77 55                	ja     8003e3 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80038e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800391:	eb e9                	jmp    80037c <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8d 40 04             	lea    0x4(%eax),%eax
  8003a1:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ab:	79 91                	jns    80033e <vprintfmt+0x54>
				width = precision, precision = -1;
  8003ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003ba:	eb 82                	jmp    80033e <vprintfmt+0x54>
  8003bc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003bf:	85 d2                	test   %edx,%edx
  8003c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c6:	0f 49 c2             	cmovns %edx,%eax
  8003c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cf:	e9 6a ff ff ff       	jmp    80033e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003de:	e9 5b ff ff ff       	jmp    80033e <vprintfmt+0x54>
  8003e3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e9:	eb bc                	jmp    8003a7 <vprintfmt+0xbd>
			lflag++;
  8003eb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f1:	e9 48 ff ff ff       	jmp    80033e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8d 78 04             	lea    0x4(%eax),%edi
  8003fc:	83 ec 08             	sub    $0x8,%esp
  8003ff:	53                   	push   %ebx
  800400:	ff 30                	push   (%eax)
  800402:	ff d6                	call   *%esi
			break;
  800404:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800407:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80040a:	e9 9d 02 00 00       	jmp    8006ac <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 78 04             	lea    0x4(%eax),%edi
  800415:	8b 10                	mov    (%eax),%edx
  800417:	89 d0                	mov    %edx,%eax
  800419:	f7 d8                	neg    %eax
  80041b:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041e:	83 f8 0f             	cmp    $0xf,%eax
  800421:	7f 23                	jg     800446 <vprintfmt+0x15c>
  800423:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80042a:	85 d2                	test   %edx,%edx
  80042c:	74 18                	je     800446 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80042e:	52                   	push   %edx
  80042f:	68 59 28 80 00       	push   $0x802859
  800434:	53                   	push   %ebx
  800435:	56                   	push   %esi
  800436:	e8 92 fe ff ff       	call   8002cd <printfmt>
  80043b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800441:	e9 66 02 00 00       	jmp    8006ac <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800446:	50                   	push   %eax
  800447:	68 13 24 80 00       	push   $0x802413
  80044c:	53                   	push   %ebx
  80044d:	56                   	push   %esi
  80044e:	e8 7a fe ff ff       	call   8002cd <printfmt>
  800453:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800456:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800459:	e9 4e 02 00 00       	jmp    8006ac <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	83 c0 04             	add    $0x4,%eax
  800464:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80046c:	85 d2                	test   %edx,%edx
  80046e:	b8 0c 24 80 00       	mov    $0x80240c,%eax
  800473:	0f 45 c2             	cmovne %edx,%eax
  800476:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800479:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047d:	7e 06                	jle    800485 <vprintfmt+0x19b>
  80047f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800483:	75 0d                	jne    800492 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800488:	89 c7                	mov    %eax,%edi
  80048a:	03 45 e0             	add    -0x20(%ebp),%eax
  80048d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800490:	eb 55                	jmp    8004e7 <vprintfmt+0x1fd>
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	ff 75 d8             	push   -0x28(%ebp)
  800498:	ff 75 cc             	push   -0x34(%ebp)
  80049b:	e8 0a 03 00 00       	call   8007aa <strnlen>
  8004a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a3:	29 c1                	sub    %eax,%ecx
  8004a5:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004ad:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	eb 0f                	jmp    8004c5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	53                   	push   %ebx
  8004ba:	ff 75 e0             	push   -0x20(%ebp)
  8004bd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	83 ef 01             	sub    $0x1,%edi
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	85 ff                	test   %edi,%edi
  8004c7:	7f ed                	jg     8004b6 <vprintfmt+0x1cc>
  8004c9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d3:	0f 49 c2             	cmovns %edx,%eax
  8004d6:	29 c2                	sub    %eax,%edx
  8004d8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004db:	eb a8                	jmp    800485 <vprintfmt+0x19b>
					putch(ch, putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	52                   	push   %edx
  8004e2:	ff d6                	call   *%esi
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ea:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ec:	83 c7 01             	add    $0x1,%edi
  8004ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f3:	0f be d0             	movsbl %al,%edx
  8004f6:	85 d2                	test   %edx,%edx
  8004f8:	74 4b                	je     800545 <vprintfmt+0x25b>
  8004fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fe:	78 06                	js     800506 <vprintfmt+0x21c>
  800500:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800504:	78 1e                	js     800524 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800506:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80050a:	74 d1                	je     8004dd <vprintfmt+0x1f3>
  80050c:	0f be c0             	movsbl %al,%eax
  80050f:	83 e8 20             	sub    $0x20,%eax
  800512:	83 f8 5e             	cmp    $0x5e,%eax
  800515:	76 c6                	jbe    8004dd <vprintfmt+0x1f3>
					putch('?', putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	53                   	push   %ebx
  80051b:	6a 3f                	push   $0x3f
  80051d:	ff d6                	call   *%esi
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	eb c3                	jmp    8004e7 <vprintfmt+0x1fd>
  800524:	89 cf                	mov    %ecx,%edi
  800526:	eb 0e                	jmp    800536 <vprintfmt+0x24c>
				putch(' ', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	6a 20                	push   $0x20
  80052e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800530:	83 ef 01             	sub    $0x1,%edi
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	85 ff                	test   %edi,%edi
  800538:	7f ee                	jg     800528 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80053a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80053d:	89 45 14             	mov    %eax,0x14(%ebp)
  800540:	e9 67 01 00 00       	jmp    8006ac <vprintfmt+0x3c2>
  800545:	89 cf                	mov    %ecx,%edi
  800547:	eb ed                	jmp    800536 <vprintfmt+0x24c>
	if (lflag >= 2)
  800549:	83 f9 01             	cmp    $0x1,%ecx
  80054c:	7f 1b                	jg     800569 <vprintfmt+0x27f>
	else if (lflag)
  80054e:	85 c9                	test   %ecx,%ecx
  800550:	74 63                	je     8005b5 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8b 00                	mov    (%eax),%eax
  800557:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055a:	99                   	cltd   
  80055b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 40 04             	lea    0x4(%eax),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
  800567:	eb 17                	jmp    800580 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 50 04             	mov    0x4(%eax),%edx
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 40 08             	lea    0x8(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800580:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800583:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800586:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80058b:	85 c9                	test   %ecx,%ecx
  80058d:	0f 89 ff 00 00 00    	jns    800692 <vprintfmt+0x3a8>
				putch('-', putdat);
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	53                   	push   %ebx
  800597:	6a 2d                	push   $0x2d
  800599:	ff d6                	call   *%esi
				num = -(long long) num;
  80059b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a1:	f7 da                	neg    %edx
  8005a3:	83 d1 00             	adc    $0x0,%ecx
  8005a6:	f7 d9                	neg    %ecx
  8005a8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ab:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005b0:	e9 dd 00 00 00       	jmp    800692 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bd:	99                   	cltd   
  8005be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 40 04             	lea    0x4(%eax),%eax
  8005c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ca:	eb b4                	jmp    800580 <vprintfmt+0x296>
	if (lflag >= 2)
  8005cc:	83 f9 01             	cmp    $0x1,%ecx
  8005cf:	7f 1e                	jg     8005ef <vprintfmt+0x305>
	else if (lflag)
  8005d1:	85 c9                	test   %ecx,%ecx
  8005d3:	74 32                	je     800607 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005ea:	e9 a3 00 00 00       	jmp    800692 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f7:	8d 40 08             	lea    0x8(%eax),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800602:	e9 8b 00 00 00       	jmp    800692 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8b 10                	mov    (%eax),%edx
  80060c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800611:	8d 40 04             	lea    0x4(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800617:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80061c:	eb 74                	jmp    800692 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80061e:	83 f9 01             	cmp    $0x1,%ecx
  800621:	7f 1b                	jg     80063e <vprintfmt+0x354>
	else if (lflag)
  800623:	85 c9                	test   %ecx,%ecx
  800625:	74 2c                	je     800653 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800631:	8d 40 04             	lea    0x4(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800637:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80063c:	eb 54                	jmp    800692 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 10                	mov    (%eax),%edx
  800643:	8b 48 04             	mov    0x4(%eax),%ecx
  800646:	8d 40 08             	lea    0x8(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80064c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800651:	eb 3f                	jmp    800692 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
  800658:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800663:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800668:	eb 28                	jmp    800692 <vprintfmt+0x3a8>
			putch('0', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 30                	push   $0x30
  800670:	ff d6                	call   *%esi
			putch('x', putdat);
  800672:	83 c4 08             	add    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 78                	push   $0x78
  800678:	ff d6                	call   *%esi
			num = (unsigned long long)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800684:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800687:	8d 40 04             	lea    0x4(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068d:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800692:	83 ec 0c             	sub    $0xc,%esp
  800695:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800699:	50                   	push   %eax
  80069a:	ff 75 e0             	push   -0x20(%ebp)
  80069d:	57                   	push   %edi
  80069e:	51                   	push   %ecx
  80069f:	52                   	push   %edx
  8006a0:	89 da                	mov    %ebx,%edx
  8006a2:	89 f0                	mov    %esi,%eax
  8006a4:	e8 5e fb ff ff       	call   800207 <printnum>
			break;
  8006a9:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006af:	e9 54 fc ff ff       	jmp    800308 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006b4:	83 f9 01             	cmp    $0x1,%ecx
  8006b7:	7f 1b                	jg     8006d4 <vprintfmt+0x3ea>
	else if (lflag)
  8006b9:	85 c9                	test   %ecx,%ecx
  8006bb:	74 2c                	je     8006e9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cd:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006d2:	eb be                	jmp    800692 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 10                	mov    (%eax),%edx
  8006d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006dc:	8d 40 08             	lea    0x8(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006e7:	eb a9                	jmp    800692 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8b 10                	mov    (%eax),%edx
  8006ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f3:	8d 40 04             	lea    0x4(%eax),%eax
  8006f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f9:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006fe:	eb 92                	jmp    800692 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	6a 25                	push   $0x25
  800706:	ff d6                	call   *%esi
			break;
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb 9f                	jmp    8006ac <vprintfmt+0x3c2>
			putch('%', putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 25                	push   $0x25
  800713:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	89 f8                	mov    %edi,%eax
  80071a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80071e:	74 05                	je     800725 <vprintfmt+0x43b>
  800720:	83 e8 01             	sub    $0x1,%eax
  800723:	eb f5                	jmp    80071a <vprintfmt+0x430>
  800725:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800728:	eb 82                	jmp    8006ac <vprintfmt+0x3c2>

0080072a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 18             	sub    $0x18,%esp
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800736:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800739:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800747:	85 c0                	test   %eax,%eax
  800749:	74 26                	je     800771 <vsnprintf+0x47>
  80074b:	85 d2                	test   %edx,%edx
  80074d:	7e 22                	jle    800771 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074f:	ff 75 14             	push   0x14(%ebp)
  800752:	ff 75 10             	push   0x10(%ebp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	50                   	push   %eax
  800759:	68 b0 02 80 00       	push   $0x8002b0
  80075e:	e8 87 fb ff ff       	call   8002ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800763:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800766:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076c:	83 c4 10             	add    $0x10,%esp
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    
		return -E_INVAL;
  800771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800776:	eb f7                	jmp    80076f <vsnprintf+0x45>

00800778 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800781:	50                   	push   %eax
  800782:	ff 75 10             	push   0x10(%ebp)
  800785:	ff 75 0c             	push   0xc(%ebp)
  800788:	ff 75 08             	push   0x8(%ebp)
  80078b:	e8 9a ff ff ff       	call   80072a <vsnprintf>
	va_end(ap);

	return rc;
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
  80079d:	eb 03                	jmp    8007a2 <strlen+0x10>
		n++;
  80079f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a6:	75 f7                	jne    80079f <strlen+0xd>
	return n;
}
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b8:	eb 03                	jmp    8007bd <strnlen+0x13>
		n++;
  8007ba:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bd:	39 d0                	cmp    %edx,%eax
  8007bf:	74 08                	je     8007c9 <strnlen+0x1f>
  8007c1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c5:	75 f3                	jne    8007ba <strnlen+0x10>
  8007c7:	89 c2                	mov    %eax,%edx
	return n;
}
  8007c9:	89 d0                	mov    %edx,%eax
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	53                   	push   %ebx
  8007d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007e0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e3:	83 c0 01             	add    $0x1,%eax
  8007e6:	84 d2                	test   %dl,%dl
  8007e8:	75 f2                	jne    8007dc <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ea:	89 c8                	mov    %ecx,%eax
  8007ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	83 ec 10             	sub    $0x10,%esp
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fb:	53                   	push   %ebx
  8007fc:	e8 91 ff ff ff       	call   800792 <strlen>
  800801:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800804:	ff 75 0c             	push   0xc(%ebp)
  800807:	01 d8                	add    %ebx,%eax
  800809:	50                   	push   %eax
  80080a:	e8 be ff ff ff       	call   8007cd <strcpy>
	return dst;
}
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800821:	89 f3                	mov    %esi,%ebx
  800823:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800826:	89 f0                	mov    %esi,%eax
  800828:	eb 0f                	jmp    800839 <strncpy+0x23>
		*dst++ = *src;
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	0f b6 0a             	movzbl (%edx),%ecx
  800830:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800833:	80 f9 01             	cmp    $0x1,%cl
  800836:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800839:	39 d8                	cmp    %ebx,%eax
  80083b:	75 ed                	jne    80082a <strncpy+0x14>
	}
	return ret;
}
  80083d:	89 f0                	mov    %esi,%eax
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 75 08             	mov    0x8(%ebp),%esi
  80084b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084e:	8b 55 10             	mov    0x10(%ebp),%edx
  800851:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800853:	85 d2                	test   %edx,%edx
  800855:	74 21                	je     800878 <strlcpy+0x35>
  800857:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085b:	89 f2                	mov    %esi,%edx
  80085d:	eb 09                	jmp    800868 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085f:	83 c1 01             	add    $0x1,%ecx
  800862:	83 c2 01             	add    $0x1,%edx
  800865:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	74 09                	je     800875 <strlcpy+0x32>
  80086c:	0f b6 19             	movzbl (%ecx),%ebx
  80086f:	84 db                	test   %bl,%bl
  800871:	75 ec                	jne    80085f <strlcpy+0x1c>
  800873:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800875:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800878:	29 f0                	sub    %esi,%eax
}
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800887:	eb 06                	jmp    80088f <strcmp+0x11>
		p++, q++;
  800889:	83 c1 01             	add    $0x1,%ecx
  80088c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	84 c0                	test   %al,%al
  800894:	74 04                	je     80089a <strcmp+0x1c>
  800896:	3a 02                	cmp    (%edx),%al
  800898:	74 ef                	je     800889 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089a:	0f b6 c0             	movzbl %al,%eax
  80089d:	0f b6 12             	movzbl (%edx),%edx
  8008a0:	29 d0                	sub    %edx,%eax
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	89 c3                	mov    %eax,%ebx
  8008b0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b3:	eb 06                	jmp    8008bb <strncmp+0x17>
		n--, p++, q++;
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008bb:	39 d8                	cmp    %ebx,%eax
  8008bd:	74 18                	je     8008d7 <strncmp+0x33>
  8008bf:	0f b6 08             	movzbl (%eax),%ecx
  8008c2:	84 c9                	test   %cl,%cl
  8008c4:	74 04                	je     8008ca <strncmp+0x26>
  8008c6:	3a 0a                	cmp    (%edx),%cl
  8008c8:	74 eb                	je     8008b5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ca:	0f b6 00             	movzbl (%eax),%eax
  8008cd:	0f b6 12             	movzbl (%edx),%edx
  8008d0:	29 d0                	sub    %edx,%eax
}
  8008d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    
		return 0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dc:	eb f4                	jmp    8008d2 <strncmp+0x2e>

008008de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e8:	eb 03                	jmp    8008ed <strchr+0xf>
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	0f b6 10             	movzbl (%eax),%edx
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	74 06                	je     8008fa <strchr+0x1c>
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	75 f2                	jne    8008ea <strchr+0xc>
  8008f8:	eb 05                	jmp    8008ff <strchr+0x21>
			return (char *) s;
	return 0;
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 09                	je     80091b <strfind+0x1a>
  800912:	84 d2                	test   %dl,%dl
  800914:	74 05                	je     80091b <strfind+0x1a>
	for (; *s; s++)
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	eb f0                	jmp    80090b <strfind+0xa>
			break;
	return (char *) s;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 7d 08             	mov    0x8(%ebp),%edi
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800929:	85 c9                	test   %ecx,%ecx
  80092b:	74 2f                	je     80095c <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	09 c8                	or     %ecx,%eax
  800931:	a8 03                	test   $0x3,%al
  800933:	75 21                	jne    800956 <memset+0x39>
		c &= 0xFF;
  800935:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800939:	89 d0                	mov    %edx,%eax
  80093b:	c1 e0 08             	shl    $0x8,%eax
  80093e:	89 d3                	mov    %edx,%ebx
  800940:	c1 e3 18             	shl    $0x18,%ebx
  800943:	89 d6                	mov    %edx,%esi
  800945:	c1 e6 10             	shl    $0x10,%esi
  800948:	09 f3                	or     %esi,%ebx
  80094a:	09 da                	or     %ebx,%edx
  80094c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800951:	fc                   	cld    
  800952:	f3 ab                	rep stos %eax,%es:(%edi)
  800954:	eb 06                	jmp    80095c <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	fc                   	cld    
  80095a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095c:	89 f8                	mov    %edi,%eax
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5f                   	pop    %edi
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800971:	39 c6                	cmp    %eax,%esi
  800973:	73 32                	jae    8009a7 <memmove+0x44>
  800975:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800978:	39 c2                	cmp    %eax,%edx
  80097a:	76 2b                	jbe    8009a7 <memmove+0x44>
		s += n;
		d += n;
  80097c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	89 d6                	mov    %edx,%esi
  800981:	09 fe                	or     %edi,%esi
  800983:	09 ce                	or     %ecx,%esi
  800985:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098b:	75 0e                	jne    80099b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098d:	83 ef 04             	sub    $0x4,%edi
  800990:	8d 72 fc             	lea    -0x4(%edx),%esi
  800993:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800996:	fd                   	std    
  800997:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800999:	eb 09                	jmp    8009a4 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099b:	83 ef 01             	sub    $0x1,%edi
  80099e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a1:	fd                   	std    
  8009a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a4:	fc                   	cld    
  8009a5:	eb 1a                	jmp    8009c1 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a7:	89 f2                	mov    %esi,%edx
  8009a9:	09 c2                	or     %eax,%edx
  8009ab:	09 ca                	or     %ecx,%edx
  8009ad:	f6 c2 03             	test   $0x3,%dl
  8009b0:	75 0a                	jne    8009bc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b5:	89 c7                	mov    %eax,%edi
  8009b7:	fc                   	cld    
  8009b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ba:	eb 05                	jmp    8009c1 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009bc:	89 c7                	mov    %eax,%edi
  8009be:	fc                   	cld    
  8009bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c1:	5e                   	pop    %esi
  8009c2:	5f                   	pop    %edi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009cb:	ff 75 10             	push   0x10(%ebp)
  8009ce:	ff 75 0c             	push   0xc(%ebp)
  8009d1:	ff 75 08             	push   0x8(%ebp)
  8009d4:	e8 8a ff ff ff       	call   800963 <memmove>
}
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	56                   	push   %esi
  8009df:	53                   	push   %ebx
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e6:	89 c6                	mov    %eax,%esi
  8009e8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009eb:	eb 06                	jmp    8009f3 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009f3:	39 f0                	cmp    %esi,%eax
  8009f5:	74 14                	je     800a0b <memcmp+0x30>
		if (*s1 != *s2)
  8009f7:	0f b6 08             	movzbl (%eax),%ecx
  8009fa:	0f b6 1a             	movzbl (%edx),%ebx
  8009fd:	38 d9                	cmp    %bl,%cl
  8009ff:	74 ec                	je     8009ed <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a01:	0f b6 c1             	movzbl %cl,%eax
  800a04:	0f b6 db             	movzbl %bl,%ebx
  800a07:	29 d8                	sub    %ebx,%eax
  800a09:	eb 05                	jmp    800a10 <memcmp+0x35>
	}

	return 0;
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1d:	89 c2                	mov    %eax,%edx
  800a1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a22:	eb 03                	jmp    800a27 <memfind+0x13>
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	39 d0                	cmp    %edx,%eax
  800a29:	73 04                	jae    800a2f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2b:	38 08                	cmp    %cl,(%eax)
  800a2d:	75 f5                	jne    800a24 <memfind+0x10>
			break;
	return (void *) s;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3d:	eb 03                	jmp    800a42 <strtol+0x11>
		s++;
  800a3f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a42:	0f b6 02             	movzbl (%edx),%eax
  800a45:	3c 20                	cmp    $0x20,%al
  800a47:	74 f6                	je     800a3f <strtol+0xe>
  800a49:	3c 09                	cmp    $0x9,%al
  800a4b:	74 f2                	je     800a3f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a4d:	3c 2b                	cmp    $0x2b,%al
  800a4f:	74 2a                	je     800a7b <strtol+0x4a>
	int neg = 0;
  800a51:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a56:	3c 2d                	cmp    $0x2d,%al
  800a58:	74 2b                	je     800a85 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a60:	75 0f                	jne    800a71 <strtol+0x40>
  800a62:	80 3a 30             	cmpb   $0x30,(%edx)
  800a65:	74 28                	je     800a8f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a67:	85 db                	test   %ebx,%ebx
  800a69:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a6e:	0f 44 d8             	cmove  %eax,%ebx
  800a71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a76:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a79:	eb 46                	jmp    800ac1 <strtol+0x90>
		s++;
  800a7b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a83:	eb d5                	jmp    800a5a <strtol+0x29>
		s++, neg = 1;
  800a85:	83 c2 01             	add    $0x1,%edx
  800a88:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8d:	eb cb                	jmp    800a5a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a93:	74 0e                	je     800aa3 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a95:	85 db                	test   %ebx,%ebx
  800a97:	75 d8                	jne    800a71 <strtol+0x40>
		s++, base = 8;
  800a99:	83 c2 01             	add    $0x1,%edx
  800a9c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa1:	eb ce                	jmp    800a71 <strtol+0x40>
		s += 2, base = 16;
  800aa3:	83 c2 02             	add    $0x2,%edx
  800aa6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aab:	eb c4                	jmp    800a71 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aad:	0f be c0             	movsbl %al,%eax
  800ab0:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab3:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ab6:	7d 3a                	jge    800af2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ab8:	83 c2 01             	add    $0x1,%edx
  800abb:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800abf:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ac1:	0f b6 02             	movzbl (%edx),%eax
  800ac4:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ac7:	89 f3                	mov    %esi,%ebx
  800ac9:	80 fb 09             	cmp    $0x9,%bl
  800acc:	76 df                	jbe    800aad <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ace:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ad1:	89 f3                	mov    %esi,%ebx
  800ad3:	80 fb 19             	cmp    $0x19,%bl
  800ad6:	77 08                	ja     800ae0 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ad8:	0f be c0             	movsbl %al,%eax
  800adb:	83 e8 57             	sub    $0x57,%eax
  800ade:	eb d3                	jmp    800ab3 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ae0:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ae3:	89 f3                	mov    %esi,%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 08                	ja     800af2 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800aea:	0f be c0             	movsbl %al,%eax
  800aed:	83 e8 37             	sub    $0x37,%eax
  800af0:	eb c1                	jmp    800ab3 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af6:	74 05                	je     800afd <strtol+0xcc>
		*endptr = (char *) s;
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800afd:	89 c8                	mov    %ecx,%eax
  800aff:	f7 d8                	neg    %eax
  800b01:	85 ff                	test   %edi,%edi
  800b03:	0f 45 c8             	cmovne %eax,%ecx
}
  800b06:	89 c8                	mov    %ecx,%eax
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b13:	b8 00 00 00 00       	mov    $0x0,%eax
  800b18:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1e:	89 c3                	mov    %eax,%ebx
  800b20:	89 c7                	mov    %eax,%edi
  800b22:	89 c6                	mov    %eax,%esi
  800b24:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b31:	ba 00 00 00 00       	mov    $0x0,%edx
  800b36:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3b:	89 d1                	mov    %edx,%ecx
  800b3d:	89 d3                	mov    %edx,%ebx
  800b3f:	89 d7                	mov    %edx,%edi
  800b41:	89 d6                	mov    %edx,%esi
  800b43:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b60:	89 cb                	mov    %ecx,%ebx
  800b62:	89 cf                	mov    %ecx,%edi
  800b64:	89 ce                	mov    %ecx,%esi
  800b66:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7f 08                	jg     800b74 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b74:	83 ec 0c             	sub    $0xc,%esp
  800b77:	50                   	push   %eax
  800b78:	6a 03                	push   $0x3
  800b7a:	68 ff 26 80 00       	push   $0x8026ff
  800b7f:	6a 2a                	push   $0x2a
  800b81:	68 1c 27 80 00       	push   $0x80271c
  800b86:	e8 8d f5 ff ff       	call   800118 <_panic>

00800b8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
  800b96:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9b:	89 d1                	mov    %edx,%ecx
  800b9d:	89 d3                	mov    %edx,%ebx
  800b9f:	89 d7                	mov    %edx,%edi
  800ba1:	89 d6                	mov    %edx,%esi
  800ba3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_yield>:

void
sys_yield(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd2:	be 00 00 00 00       	mov    $0x0,%esi
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	b8 04 00 00 00       	mov    $0x4,%eax
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be5:	89 f7                	mov    %esi,%edi
  800be7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be9:	85 c0                	test   %eax,%eax
  800beb:	7f 08                	jg     800bf5 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf5:	83 ec 0c             	sub    $0xc,%esp
  800bf8:	50                   	push   %eax
  800bf9:	6a 04                	push   $0x4
  800bfb:	68 ff 26 80 00       	push   $0x8026ff
  800c00:	6a 2a                	push   $0x2a
  800c02:	68 1c 27 80 00       	push   $0x80271c
  800c07:	e8 0c f5 ff ff       	call   800118 <_panic>

00800c0c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c23:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c26:	8b 75 18             	mov    0x18(%ebp),%esi
  800c29:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	7f 08                	jg     800c37 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	50                   	push   %eax
  800c3b:	6a 05                	push   $0x5
  800c3d:	68 ff 26 80 00       	push   $0x8026ff
  800c42:	6a 2a                	push   $0x2a
  800c44:	68 1c 27 80 00       	push   $0x80271c
  800c49:	e8 ca f4 ff ff       	call   800118 <_panic>

00800c4e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	b8 06 00 00 00       	mov    $0x6,%eax
  800c67:	89 df                	mov    %ebx,%edi
  800c69:	89 de                	mov    %ebx,%esi
  800c6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	7f 08                	jg     800c79 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	50                   	push   %eax
  800c7d:	6a 06                	push   $0x6
  800c7f:	68 ff 26 80 00       	push   $0x8026ff
  800c84:	6a 2a                	push   $0x2a
  800c86:	68 1c 27 80 00       	push   $0x80271c
  800c8b:	e8 88 f4 ff ff       	call   800118 <_panic>

00800c90 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca9:	89 df                	mov    %ebx,%edi
  800cab:	89 de                	mov    %ebx,%esi
  800cad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7f 08                	jg     800cbb <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 08                	push   $0x8
  800cc1:	68 ff 26 80 00       	push   $0x8026ff
  800cc6:	6a 2a                	push   $0x2a
  800cc8:	68 1c 27 80 00       	push   $0x80271c
  800ccd:	e8 46 f4 ff ff       	call   800118 <_panic>

00800cd2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	b8 09 00 00 00       	mov    $0x9,%eax
  800ceb:	89 df                	mov    %ebx,%edi
  800ced:	89 de                	mov    %ebx,%esi
  800cef:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7f 08                	jg     800cfd <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 09                	push   $0x9
  800d03:	68 ff 26 80 00       	push   $0x8026ff
  800d08:	6a 2a                	push   $0x2a
  800d0a:	68 1c 27 80 00       	push   $0x80271c
  800d0f:	e8 04 f4 ff ff       	call   800118 <_panic>

00800d14 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2d:	89 df                	mov    %ebx,%edi
  800d2f:	89 de                	mov    %ebx,%esi
  800d31:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7f 08                	jg     800d3f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 0a                	push   $0xa
  800d45:	68 ff 26 80 00       	push   $0x8026ff
  800d4a:	6a 2a                	push   $0x2a
  800d4c:	68 1c 27 80 00       	push   $0x80271c
  800d51:	e8 c2 f3 ff ff       	call   800118 <_panic>

00800d56 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d67:	be 00 00 00 00       	mov    $0x0,%esi
  800d6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d72:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
  800d7f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d8f:	89 cb                	mov    %ecx,%ebx
  800d91:	89 cf                	mov    %ecx,%edi
  800d93:	89 ce                	mov    %ecx,%esi
  800d95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d97:	85 c0                	test   %eax,%eax
  800d99:	7f 08                	jg     800da3 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	50                   	push   %eax
  800da7:	6a 0d                	push   $0xd
  800da9:	68 ff 26 80 00       	push   $0x8026ff
  800dae:	6a 2a                	push   $0x2a
  800db0:	68 1c 27 80 00       	push   $0x80271c
  800db5:	e8 5e f3 ff ff       	call   800118 <_panic>

00800dba <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dca:	89 d1                	mov    %edx,%ecx
  800dcc:	89 d3                	mov    %edx,%ebx
  800dce:	89 d7                	mov    %edx,%edi
  800dd0:	89 d6                	mov    %edx,%esi
  800dd2:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ddf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	b8 0f 00 00 00       	mov    $0xf,%eax
  800def:	89 df                	mov    %ebx,%edi
  800df1:	89 de                	mov    %ebx,%esi
  800df3:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	b8 10 00 00 00       	mov    $0x10,%eax
  800e10:	89 df                	mov    %ebx,%edi
  800e12:	89 de                	mov    %ebx,%esi
  800e14:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800e21:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e28:	74 0a                	je     800e34 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	a3 04 40 80 00       	mov    %eax,0x804004
}
  800e32:	c9                   	leave  
  800e33:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800e34:	e8 52 fd ff ff       	call   800b8b <sys_getenvid>
  800e39:	83 ec 04             	sub    $0x4,%esp
  800e3c:	68 07 0e 00 00       	push   $0xe07
  800e41:	68 00 f0 bf ee       	push   $0xeebff000
  800e46:	50                   	push   %eax
  800e47:	e8 7d fd ff ff       	call   800bc9 <sys_page_alloc>
		if (r < 0) {
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	78 2c                	js     800e7f <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800e53:	e8 33 fd ff ff       	call   800b8b <sys_getenvid>
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	68 91 0e 80 00       	push   $0x800e91
  800e60:	50                   	push   %eax
  800e61:	e8 ae fe ff ff       	call   800d14 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	79 bd                	jns    800e2a <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800e6d:	50                   	push   %eax
  800e6e:	68 6c 27 80 00       	push   $0x80276c
  800e73:	6a 28                	push   $0x28
  800e75:	68 a2 27 80 00       	push   $0x8027a2
  800e7a:	e8 99 f2 ff ff       	call   800118 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800e7f:	50                   	push   %eax
  800e80:	68 2c 27 80 00       	push   $0x80272c
  800e85:	6a 23                	push   $0x23
  800e87:	68 a2 27 80 00       	push   $0x8027a2
  800e8c:	e8 87 f2 ff ff       	call   800118 <_panic>

00800e91 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e91:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e92:	a1 04 40 80 00       	mov    0x804004,%eax
	call *%eax
  800e97:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e99:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800e9c:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800ea0:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800ea3:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800ea7:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800eab:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800ead:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800eb0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800eb1:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800eb4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800eb5:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800eb6:	c3                   	ret    

00800eb7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebd:	05 00 00 00 30       	add    $0x30000000,%eax
  800ec2:	c1 e8 0c             	shr    $0xc,%eax
}
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecd:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ed2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ed7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	c1 ea 16             	shr    $0x16,%edx
  800eeb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef2:	f6 c2 01             	test   $0x1,%dl
  800ef5:	74 29                	je     800f20 <fd_alloc+0x42>
  800ef7:	89 c2                	mov    %eax,%edx
  800ef9:	c1 ea 0c             	shr    $0xc,%edx
  800efc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f03:	f6 c2 01             	test   $0x1,%dl
  800f06:	74 18                	je     800f20 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f08:	05 00 10 00 00       	add    $0x1000,%eax
  800f0d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f12:	75 d2                	jne    800ee6 <fd_alloc+0x8>
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f19:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f1e:	eb 05                	jmp    800f25 <fd_alloc+0x47>
			return 0;
  800f20:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	89 02                	mov    %eax,(%edx)
}
  800f2a:	89 c8                	mov    %ecx,%eax
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f34:	83 f8 1f             	cmp    $0x1f,%eax
  800f37:	77 30                	ja     800f69 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f39:	c1 e0 0c             	shl    $0xc,%eax
  800f3c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f41:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f47:	f6 c2 01             	test   $0x1,%dl
  800f4a:	74 24                	je     800f70 <fd_lookup+0x42>
  800f4c:	89 c2                	mov    %eax,%edx
  800f4e:	c1 ea 0c             	shr    $0xc,%edx
  800f51:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f58:	f6 c2 01             	test   $0x1,%dl
  800f5b:	74 1a                	je     800f77 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f60:	89 02                	mov    %eax,(%edx)
	return 0;
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
		return -E_INVAL;
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6e:	eb f7                	jmp    800f67 <fd_lookup+0x39>
		return -E_INVAL;
  800f70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f75:	eb f0                	jmp    800f67 <fd_lookup+0x39>
  800f77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f7c:	eb e9                	jmp    800f67 <fd_lookup+0x39>

00800f7e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	53                   	push   %ebx
  800f82:	83 ec 04             	sub    $0x4,%esp
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f88:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8d:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f92:	39 13                	cmp    %edx,(%ebx)
  800f94:	74 37                	je     800fcd <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f96:	83 c0 01             	add    $0x1,%eax
  800f99:	8b 1c 85 2c 28 80 00 	mov    0x80282c(,%eax,4),%ebx
  800fa0:	85 db                	test   %ebx,%ebx
  800fa2:	75 ee                	jne    800f92 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fa4:	a1 00 40 80 00       	mov    0x804000,%eax
  800fa9:	8b 40 58             	mov    0x58(%eax),%eax
  800fac:	83 ec 04             	sub    $0x4,%esp
  800faf:	52                   	push   %edx
  800fb0:	50                   	push   %eax
  800fb1:	68 b0 27 80 00       	push   $0x8027b0
  800fb6:	e8 38 f2 ff ff       	call   8001f3 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800fc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc6:	89 1a                	mov    %ebx,(%edx)
}
  800fc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    
			return 0;
  800fcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd2:	eb ef                	jmp    800fc3 <dev_lookup+0x45>

00800fd4 <fd_close>:
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 24             	sub    $0x24,%esp
  800fdd:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fe7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fed:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff0:	50                   	push   %eax
  800ff1:	e8 38 ff ff ff       	call   800f2e <fd_lookup>
  800ff6:	89 c3                	mov    %eax,%ebx
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	78 05                	js     801004 <fd_close+0x30>
	    || fd != fd2)
  800fff:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801002:	74 16                	je     80101a <fd_close+0x46>
		return (must_exist ? r : 0);
  801004:	89 f8                	mov    %edi,%eax
  801006:	84 c0                	test   %al,%al
  801008:	b8 00 00 00 00       	mov    $0x0,%eax
  80100d:	0f 44 d8             	cmove  %eax,%ebx
}
  801010:	89 d8                	mov    %ebx,%eax
  801012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80101a:	83 ec 08             	sub    $0x8,%esp
  80101d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801020:	50                   	push   %eax
  801021:	ff 36                	push   (%esi)
  801023:	e8 56 ff ff ff       	call   800f7e <dev_lookup>
  801028:	89 c3                	mov    %eax,%ebx
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	78 1a                	js     80104b <fd_close+0x77>
		if (dev->dev_close)
  801031:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801034:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801037:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80103c:	85 c0                	test   %eax,%eax
  80103e:	74 0b                	je     80104b <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	56                   	push   %esi
  801044:	ff d0                	call   *%eax
  801046:	89 c3                	mov    %eax,%ebx
  801048:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80104b:	83 ec 08             	sub    $0x8,%esp
  80104e:	56                   	push   %esi
  80104f:	6a 00                	push   $0x0
  801051:	e8 f8 fb ff ff       	call   800c4e <sys_page_unmap>
	return r;
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	eb b5                	jmp    801010 <fd_close+0x3c>

0080105b <close>:

int
close(int fdnum)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801061:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801064:	50                   	push   %eax
  801065:	ff 75 08             	push   0x8(%ebp)
  801068:	e8 c1 fe ff ff       	call   800f2e <fd_lookup>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	79 02                	jns    801076 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801074:	c9                   	leave  
  801075:	c3                   	ret    
		return fd_close(fd, 1);
  801076:	83 ec 08             	sub    $0x8,%esp
  801079:	6a 01                	push   $0x1
  80107b:	ff 75 f4             	push   -0xc(%ebp)
  80107e:	e8 51 ff ff ff       	call   800fd4 <fd_close>
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	eb ec                	jmp    801074 <close+0x19>

00801088 <close_all>:

void
close_all(void)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	53                   	push   %ebx
  80108c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80108f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	53                   	push   %ebx
  801098:	e8 be ff ff ff       	call   80105b <close>
	for (i = 0; i < MAXFD; i++)
  80109d:	83 c3 01             	add    $0x1,%ebx
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	83 fb 20             	cmp    $0x20,%ebx
  8010a6:	75 ec                	jne    801094 <close_all+0xc>
}
  8010a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ab:	c9                   	leave  
  8010ac:	c3                   	ret    

008010ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	57                   	push   %edi
  8010b1:	56                   	push   %esi
  8010b2:	53                   	push   %ebx
  8010b3:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010b9:	50                   	push   %eax
  8010ba:	ff 75 08             	push   0x8(%ebp)
  8010bd:	e8 6c fe ff ff       	call   800f2e <fd_lookup>
  8010c2:	89 c3                	mov    %eax,%ebx
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 7f                	js     80114a <dup+0x9d>
		return r;
	close(newfdnum);
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	ff 75 0c             	push   0xc(%ebp)
  8010d1:	e8 85 ff ff ff       	call   80105b <close>

	newfd = INDEX2FD(newfdnum);
  8010d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d9:	c1 e6 0c             	shl    $0xc,%esi
  8010dc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010e5:	89 3c 24             	mov    %edi,(%esp)
  8010e8:	e8 da fd ff ff       	call   800ec7 <fd2data>
  8010ed:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010ef:	89 34 24             	mov    %esi,(%esp)
  8010f2:	e8 d0 fd ff ff       	call   800ec7 <fd2data>
  8010f7:	83 c4 10             	add    $0x10,%esp
  8010fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010fd:	89 d8                	mov    %ebx,%eax
  8010ff:	c1 e8 16             	shr    $0x16,%eax
  801102:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801109:	a8 01                	test   $0x1,%al
  80110b:	74 11                	je     80111e <dup+0x71>
  80110d:	89 d8                	mov    %ebx,%eax
  80110f:	c1 e8 0c             	shr    $0xc,%eax
  801112:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801119:	f6 c2 01             	test   $0x1,%dl
  80111c:	75 36                	jne    801154 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80111e:	89 f8                	mov    %edi,%eax
  801120:	c1 e8 0c             	shr    $0xc,%eax
  801123:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	25 07 0e 00 00       	and    $0xe07,%eax
  801132:	50                   	push   %eax
  801133:	56                   	push   %esi
  801134:	6a 00                	push   $0x0
  801136:	57                   	push   %edi
  801137:	6a 00                	push   $0x0
  801139:	e8 ce fa ff ff       	call   800c0c <sys_page_map>
  80113e:	89 c3                	mov    %eax,%ebx
  801140:	83 c4 20             	add    $0x20,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	78 33                	js     80117a <dup+0xcd>
		goto err;

	return newfdnum;
  801147:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80114a:	89 d8                	mov    %ebx,%eax
  80114c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5f                   	pop    %edi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801154:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115b:	83 ec 0c             	sub    $0xc,%esp
  80115e:	25 07 0e 00 00       	and    $0xe07,%eax
  801163:	50                   	push   %eax
  801164:	ff 75 d4             	push   -0x2c(%ebp)
  801167:	6a 00                	push   $0x0
  801169:	53                   	push   %ebx
  80116a:	6a 00                	push   $0x0
  80116c:	e8 9b fa ff ff       	call   800c0c <sys_page_map>
  801171:	89 c3                	mov    %eax,%ebx
  801173:	83 c4 20             	add    $0x20,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	79 a4                	jns    80111e <dup+0x71>
	sys_page_unmap(0, newfd);
  80117a:	83 ec 08             	sub    $0x8,%esp
  80117d:	56                   	push   %esi
  80117e:	6a 00                	push   $0x0
  801180:	e8 c9 fa ff ff       	call   800c4e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801185:	83 c4 08             	add    $0x8,%esp
  801188:	ff 75 d4             	push   -0x2c(%ebp)
  80118b:	6a 00                	push   $0x0
  80118d:	e8 bc fa ff ff       	call   800c4e <sys_page_unmap>
	return r;
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	eb b3                	jmp    80114a <dup+0x9d>

00801197 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
  80119c:	83 ec 18             	sub    $0x18,%esp
  80119f:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a5:	50                   	push   %eax
  8011a6:	56                   	push   %esi
  8011a7:	e8 82 fd ff ff       	call   800f2e <fd_lookup>
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 3c                	js     8011ef <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b3:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bc:	50                   	push   %eax
  8011bd:	ff 33                	push   (%ebx)
  8011bf:	e8 ba fd ff ff       	call   800f7e <dev_lookup>
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 24                	js     8011ef <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011cb:	8b 43 08             	mov    0x8(%ebx),%eax
  8011ce:	83 e0 03             	and    $0x3,%eax
  8011d1:	83 f8 01             	cmp    $0x1,%eax
  8011d4:	74 20                	je     8011f6 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d9:	8b 40 08             	mov    0x8(%eax),%eax
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	74 37                	je     801217 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011e0:	83 ec 04             	sub    $0x4,%esp
  8011e3:	ff 75 10             	push   0x10(%ebp)
  8011e6:	ff 75 0c             	push   0xc(%ebp)
  8011e9:	53                   	push   %ebx
  8011ea:	ff d0                	call   *%eax
  8011ec:	83 c4 10             	add    $0x10,%esp
}
  8011ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f6:	a1 00 40 80 00       	mov    0x804000,%eax
  8011fb:	8b 40 58             	mov    0x58(%eax),%eax
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	56                   	push   %esi
  801202:	50                   	push   %eax
  801203:	68 f1 27 80 00       	push   $0x8027f1
  801208:	e8 e6 ef ff ff       	call   8001f3 <cprintf>
		return -E_INVAL;
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801215:	eb d8                	jmp    8011ef <read+0x58>
		return -E_NOT_SUPP;
  801217:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80121c:	eb d1                	jmp    8011ef <read+0x58>

0080121e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801232:	eb 02                	jmp    801236 <readn+0x18>
  801234:	01 c3                	add    %eax,%ebx
  801236:	39 f3                	cmp    %esi,%ebx
  801238:	73 21                	jae    80125b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	89 f0                	mov    %esi,%eax
  80123f:	29 d8                	sub    %ebx,%eax
  801241:	50                   	push   %eax
  801242:	89 d8                	mov    %ebx,%eax
  801244:	03 45 0c             	add    0xc(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	57                   	push   %edi
  801249:	e8 49 ff ff ff       	call   801197 <read>
		if (m < 0)
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	78 04                	js     801259 <readn+0x3b>
			return m;
		if (m == 0)
  801255:	75 dd                	jne    801234 <readn+0x16>
  801257:	eb 02                	jmp    80125b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801259:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80125b:	89 d8                	mov    %ebx,%eax
  80125d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	56                   	push   %esi
  801269:	53                   	push   %ebx
  80126a:	83 ec 18             	sub    $0x18,%esp
  80126d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801270:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	53                   	push   %ebx
  801275:	e8 b4 fc ff ff       	call   800f2e <fd_lookup>
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 37                	js     8012b8 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801281:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128a:	50                   	push   %eax
  80128b:	ff 36                	push   (%esi)
  80128d:	e8 ec fc ff ff       	call   800f7e <dev_lookup>
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	85 c0                	test   %eax,%eax
  801297:	78 1f                	js     8012b8 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801299:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80129d:	74 20                	je     8012bf <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80129f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	74 37                	je     8012e0 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012a9:	83 ec 04             	sub    $0x4,%esp
  8012ac:	ff 75 10             	push   0x10(%ebp)
  8012af:	ff 75 0c             	push   0xc(%ebp)
  8012b2:	56                   	push   %esi
  8012b3:	ff d0                	call   *%eax
  8012b5:	83 c4 10             	add    $0x10,%esp
}
  8012b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bb:	5b                   	pop    %ebx
  8012bc:	5e                   	pop    %esi
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012bf:	a1 00 40 80 00       	mov    0x804000,%eax
  8012c4:	8b 40 58             	mov    0x58(%eax),%eax
  8012c7:	83 ec 04             	sub    $0x4,%esp
  8012ca:	53                   	push   %ebx
  8012cb:	50                   	push   %eax
  8012cc:	68 0d 28 80 00       	push   $0x80280d
  8012d1:	e8 1d ef ff ff       	call   8001f3 <cprintf>
		return -E_INVAL;
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012de:	eb d8                	jmp    8012b8 <write+0x53>
		return -E_NOT_SUPP;
  8012e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e5:	eb d1                	jmp    8012b8 <write+0x53>

008012e7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	ff 75 08             	push   0x8(%ebp)
  8012f4:	e8 35 fc ff ff       	call   800f2e <fd_lookup>
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 0e                	js     80130e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801300:	8b 55 0c             	mov    0xc(%ebp),%edx
  801303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801306:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801309:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130e:	c9                   	leave  
  80130f:	c3                   	ret    

00801310 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	56                   	push   %esi
  801314:	53                   	push   %ebx
  801315:	83 ec 18             	sub    $0x18,%esp
  801318:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131e:	50                   	push   %eax
  80131f:	53                   	push   %ebx
  801320:	e8 09 fc ff ff       	call   800f2e <fd_lookup>
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 34                	js     801360 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	ff 36                	push   (%esi)
  801338:	e8 41 fc ff ff       	call   800f7e <dev_lookup>
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	85 c0                	test   %eax,%eax
  801342:	78 1c                	js     801360 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801344:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801348:	74 1d                	je     801367 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80134a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134d:	8b 40 18             	mov    0x18(%eax),%eax
  801350:	85 c0                	test   %eax,%eax
  801352:	74 34                	je     801388 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801354:	83 ec 08             	sub    $0x8,%esp
  801357:	ff 75 0c             	push   0xc(%ebp)
  80135a:	56                   	push   %esi
  80135b:	ff d0                	call   *%eax
  80135d:	83 c4 10             	add    $0x10,%esp
}
  801360:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801363:	5b                   	pop    %ebx
  801364:	5e                   	pop    %esi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    
			thisenv->env_id, fdnum);
  801367:	a1 00 40 80 00       	mov    0x804000,%eax
  80136c:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80136f:	83 ec 04             	sub    $0x4,%esp
  801372:	53                   	push   %ebx
  801373:	50                   	push   %eax
  801374:	68 d0 27 80 00       	push   $0x8027d0
  801379:	e8 75 ee ff ff       	call   8001f3 <cprintf>
		return -E_INVAL;
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801386:	eb d8                	jmp    801360 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801388:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80138d:	eb d1                	jmp    801360 <ftruncate+0x50>

0080138f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	83 ec 18             	sub    $0x18,%esp
  801397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	ff 75 08             	push   0x8(%ebp)
  8013a1:	e8 88 fb ff ff       	call   800f2e <fd_lookup>
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 49                	js     8013f6 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ad:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013b0:	83 ec 08             	sub    $0x8,%esp
  8013b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	ff 36                	push   (%esi)
  8013b9:	e8 c0 fb ff ff       	call   800f7e <dev_lookup>
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 31                	js     8013f6 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013cc:	74 2f                	je     8013fd <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013ce:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013d1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013d8:	00 00 00 
	stat->st_isdir = 0;
  8013db:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013e2:	00 00 00 
	stat->st_dev = dev;
  8013e5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	53                   	push   %ebx
  8013ef:	56                   	push   %esi
  8013f0:	ff 50 14             	call   *0x14(%eax)
  8013f3:	83 c4 10             	add    $0x10,%esp
}
  8013f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5e                   	pop    %esi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    
		return -E_NOT_SUPP;
  8013fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801402:	eb f2                	jmp    8013f6 <fstat+0x67>

00801404 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	56                   	push   %esi
  801408:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	6a 00                	push   $0x0
  80140e:	ff 75 08             	push   0x8(%ebp)
  801411:	e8 e4 01 00 00       	call   8015fa <open>
  801416:	89 c3                	mov    %eax,%ebx
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 1b                	js     80143a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	ff 75 0c             	push   0xc(%ebp)
  801425:	50                   	push   %eax
  801426:	e8 64 ff ff ff       	call   80138f <fstat>
  80142b:	89 c6                	mov    %eax,%esi
	close(fd);
  80142d:	89 1c 24             	mov    %ebx,(%esp)
  801430:	e8 26 fc ff ff       	call   80105b <close>
	return r;
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	89 f3                	mov    %esi,%ebx
}
  80143a:	89 d8                	mov    %ebx,%eax
  80143c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    

00801443 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	56                   	push   %esi
  801447:	53                   	push   %ebx
  801448:	89 c6                	mov    %eax,%esi
  80144a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80144c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801453:	74 27                	je     80147c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801455:	6a 07                	push   $0x7
  801457:	68 00 50 80 00       	push   $0x805000
  80145c:	56                   	push   %esi
  80145d:	ff 35 00 60 80 00    	push   0x806000
  801463:	e8 cd 0b 00 00       	call   802035 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801468:	83 c4 0c             	add    $0xc,%esp
  80146b:	6a 00                	push   $0x0
  80146d:	53                   	push   %ebx
  80146e:	6a 00                	push   $0x0
  801470:	e8 50 0b 00 00       	call   801fc5 <ipc_recv>
}
  801475:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801478:	5b                   	pop    %ebx
  801479:	5e                   	pop    %esi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80147c:	83 ec 0c             	sub    $0xc,%esp
  80147f:	6a 01                	push   $0x1
  801481:	e8 03 0c 00 00       	call   802089 <ipc_find_env>
  801486:	a3 00 60 80 00       	mov    %eax,0x806000
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	eb c5                	jmp    801455 <fsipc+0x12>

00801490 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801496:	8b 45 08             	mov    0x8(%ebp),%eax
  801499:	8b 40 0c             	mov    0xc(%eax),%eax
  80149c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b3:	e8 8b ff ff ff       	call   801443 <fsipc>
}
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <devfile_flush>:
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d0:	b8 06 00 00 00       	mov    $0x6,%eax
  8014d5:	e8 69 ff ff ff       	call   801443 <fsipc>
}
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <devfile_stat>:
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	53                   	push   %ebx
  8014e0:	83 ec 04             	sub    $0x4,%esp
  8014e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ec:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8014fb:	e8 43 ff ff ff       	call   801443 <fsipc>
  801500:	85 c0                	test   %eax,%eax
  801502:	78 2c                	js     801530 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	68 00 50 80 00       	push   $0x805000
  80150c:	53                   	push   %ebx
  80150d:	e8 bb f2 ff ff       	call   8007cd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801512:	a1 80 50 80 00       	mov    0x805080,%eax
  801517:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80151d:	a1 84 50 80 00       	mov    0x805084,%eax
  801522:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801530:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801533:	c9                   	leave  
  801534:	c3                   	ret    

00801535 <devfile_write>:
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	8b 45 10             	mov    0x10(%ebp),%eax
  80153e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801543:	39 d0                	cmp    %edx,%eax
  801545:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801548:	8b 55 08             	mov    0x8(%ebp),%edx
  80154b:	8b 52 0c             	mov    0xc(%edx),%edx
  80154e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801554:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801559:	50                   	push   %eax
  80155a:	ff 75 0c             	push   0xc(%ebp)
  80155d:	68 08 50 80 00       	push   $0x805008
  801562:	e8 fc f3 ff ff       	call   800963 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801567:	ba 00 00 00 00       	mov    $0x0,%edx
  80156c:	b8 04 00 00 00       	mov    $0x4,%eax
  801571:	e8 cd fe ff ff       	call   801443 <fsipc>
}
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <devfile_read>:
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
  80157d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801580:	8b 45 08             	mov    0x8(%ebp),%eax
  801583:	8b 40 0c             	mov    0xc(%eax),%eax
  801586:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80158b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801591:	ba 00 00 00 00       	mov    $0x0,%edx
  801596:	b8 03 00 00 00       	mov    $0x3,%eax
  80159b:	e8 a3 fe ff ff       	call   801443 <fsipc>
  8015a0:	89 c3                	mov    %eax,%ebx
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 1f                	js     8015c5 <devfile_read+0x4d>
	assert(r <= n);
  8015a6:	39 f0                	cmp    %esi,%eax
  8015a8:	77 24                	ja     8015ce <devfile_read+0x56>
	assert(r <= PGSIZE);
  8015aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015af:	7f 33                	jg     8015e4 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b1:	83 ec 04             	sub    $0x4,%esp
  8015b4:	50                   	push   %eax
  8015b5:	68 00 50 80 00       	push   $0x805000
  8015ba:	ff 75 0c             	push   0xc(%ebp)
  8015bd:	e8 a1 f3 ff ff       	call   800963 <memmove>
	return r;
  8015c2:	83 c4 10             	add    $0x10,%esp
}
  8015c5:	89 d8                	mov    %ebx,%eax
  8015c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    
	assert(r <= n);
  8015ce:	68 40 28 80 00       	push   $0x802840
  8015d3:	68 47 28 80 00       	push   $0x802847
  8015d8:	6a 7c                	push   $0x7c
  8015da:	68 5c 28 80 00       	push   $0x80285c
  8015df:	e8 34 eb ff ff       	call   800118 <_panic>
	assert(r <= PGSIZE);
  8015e4:	68 67 28 80 00       	push   $0x802867
  8015e9:	68 47 28 80 00       	push   $0x802847
  8015ee:	6a 7d                	push   $0x7d
  8015f0:	68 5c 28 80 00       	push   $0x80285c
  8015f5:	e8 1e eb ff ff       	call   800118 <_panic>

008015fa <open>:
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	56                   	push   %esi
  8015fe:	53                   	push   %ebx
  8015ff:	83 ec 1c             	sub    $0x1c,%esp
  801602:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801605:	56                   	push   %esi
  801606:	e8 87 f1 ff ff       	call   800792 <strlen>
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801613:	7f 6c                	jg     801681 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801615:	83 ec 0c             	sub    $0xc,%esp
  801618:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	e8 bd f8 ff ff       	call   800ede <fd_alloc>
  801621:	89 c3                	mov    %eax,%ebx
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 3c                	js     801666 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	56                   	push   %esi
  80162e:	68 00 50 80 00       	push   $0x805000
  801633:	e8 95 f1 ff ff       	call   8007cd <strcpy>
	fsipcbuf.open.req_omode = mode;
  801638:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801640:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801643:	b8 01 00 00 00       	mov    $0x1,%eax
  801648:	e8 f6 fd ff ff       	call   801443 <fsipc>
  80164d:	89 c3                	mov    %eax,%ebx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 19                	js     80166f <open+0x75>
	return fd2num(fd);
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	ff 75 f4             	push   -0xc(%ebp)
  80165c:	e8 56 f8 ff ff       	call   800eb7 <fd2num>
  801661:	89 c3                	mov    %eax,%ebx
  801663:	83 c4 10             	add    $0x10,%esp
}
  801666:	89 d8                	mov    %ebx,%eax
  801668:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166b:	5b                   	pop    %ebx
  80166c:	5e                   	pop    %esi
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    
		fd_close(fd, 0);
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	6a 00                	push   $0x0
  801674:	ff 75 f4             	push   -0xc(%ebp)
  801677:	e8 58 f9 ff ff       	call   800fd4 <fd_close>
		return r;
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	eb e5                	jmp    801666 <open+0x6c>
		return -E_BAD_PATH;
  801681:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801686:	eb de                	jmp    801666 <open+0x6c>

00801688 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80168e:	ba 00 00 00 00       	mov    $0x0,%edx
  801693:	b8 08 00 00 00       	mov    $0x8,%eax
  801698:	e8 a6 fd ff ff       	call   801443 <fsipc>
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016a5:	68 73 28 80 00       	push   $0x802873
  8016aa:	ff 75 0c             	push   0xc(%ebp)
  8016ad:	e8 1b f1 ff ff       	call   8007cd <strcpy>
	return 0;
}
  8016b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b7:	c9                   	leave  
  8016b8:	c3                   	ret    

008016b9 <devsock_close>:
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	53                   	push   %ebx
  8016bd:	83 ec 10             	sub    $0x10,%esp
  8016c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016c3:	53                   	push   %ebx
  8016c4:	e8 ff 09 00 00       	call   8020c8 <pageref>
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	83 c4 10             	add    $0x10,%esp
		return 0;
  8016ce:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8016d3:	83 fa 01             	cmp    $0x1,%edx
  8016d6:	74 05                	je     8016dd <devsock_close+0x24>
}
  8016d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016db:	c9                   	leave  
  8016dc:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8016dd:	83 ec 0c             	sub    $0xc,%esp
  8016e0:	ff 73 0c             	push   0xc(%ebx)
  8016e3:	e8 b7 02 00 00       	call   80199f <nsipc_close>
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	eb eb                	jmp    8016d8 <devsock_close+0x1f>

008016ed <devsock_write>:
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016f3:	6a 00                	push   $0x0
  8016f5:	ff 75 10             	push   0x10(%ebp)
  8016f8:	ff 75 0c             	push   0xc(%ebp)
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	ff 70 0c             	push   0xc(%eax)
  801701:	e8 79 03 00 00       	call   801a7f <nsipc_send>
}
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <devsock_read>:
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80170e:	6a 00                	push   $0x0
  801710:	ff 75 10             	push   0x10(%ebp)
  801713:	ff 75 0c             	push   0xc(%ebp)
  801716:	8b 45 08             	mov    0x8(%ebp),%eax
  801719:	ff 70 0c             	push   0xc(%eax)
  80171c:	e8 ef 02 00 00       	call   801a10 <nsipc_recv>
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <fd2sockid>:
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801729:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80172c:	52                   	push   %edx
  80172d:	50                   	push   %eax
  80172e:	e8 fb f7 ff ff       	call   800f2e <fd_lookup>
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	85 c0                	test   %eax,%eax
  801738:	78 10                	js     80174a <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80173a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801743:	39 08                	cmp    %ecx,(%eax)
  801745:	75 05                	jne    80174c <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801747:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    
		return -E_NOT_SUPP;
  80174c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801751:	eb f7                	jmp    80174a <fd2sockid+0x27>

00801753 <alloc_sockfd>:
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
  801758:	83 ec 1c             	sub    $0x1c,%esp
  80175b:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80175d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801760:	50                   	push   %eax
  801761:	e8 78 f7 ff ff       	call   800ede <fd_alloc>
  801766:	89 c3                	mov    %eax,%ebx
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 43                	js     8017b2 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80176f:	83 ec 04             	sub    $0x4,%esp
  801772:	68 07 04 00 00       	push   $0x407
  801777:	ff 75 f4             	push   -0xc(%ebp)
  80177a:	6a 00                	push   $0x0
  80177c:	e8 48 f4 ff ff       	call   800bc9 <sys_page_alloc>
  801781:	89 c3                	mov    %eax,%ebx
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	78 28                	js     8017b2 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80178a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801793:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801795:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801798:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80179f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	50                   	push   %eax
  8017a6:	e8 0c f7 ff ff       	call   800eb7 <fd2num>
  8017ab:	89 c3                	mov    %eax,%ebx
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	eb 0c                	jmp    8017be <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8017b2:	83 ec 0c             	sub    $0xc,%esp
  8017b5:	56                   	push   %esi
  8017b6:	e8 e4 01 00 00       	call   80199f <nsipc_close>
		return r;
  8017bb:	83 c4 10             	add    $0x10,%esp
}
  8017be:	89 d8                	mov    %ebx,%eax
  8017c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <accept>:
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	e8 4e ff ff ff       	call   801723 <fd2sockid>
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 1b                	js     8017f4 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017d9:	83 ec 04             	sub    $0x4,%esp
  8017dc:	ff 75 10             	push   0x10(%ebp)
  8017df:	ff 75 0c             	push   0xc(%ebp)
  8017e2:	50                   	push   %eax
  8017e3:	e8 0e 01 00 00       	call   8018f6 <nsipc_accept>
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 05                	js     8017f4 <accept+0x2d>
	return alloc_sockfd(r);
  8017ef:	e8 5f ff ff ff       	call   801753 <alloc_sockfd>
}
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <bind>:
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	e8 1f ff ff ff       	call   801723 <fd2sockid>
  801804:	85 c0                	test   %eax,%eax
  801806:	78 12                	js     80181a <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801808:	83 ec 04             	sub    $0x4,%esp
  80180b:	ff 75 10             	push   0x10(%ebp)
  80180e:	ff 75 0c             	push   0xc(%ebp)
  801811:	50                   	push   %eax
  801812:	e8 31 01 00 00       	call   801948 <nsipc_bind>
  801817:	83 c4 10             	add    $0x10,%esp
}
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <shutdown>:
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	e8 f9 fe ff ff       	call   801723 <fd2sockid>
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 0f                	js     80183d <shutdown+0x21>
	return nsipc_shutdown(r, how);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	ff 75 0c             	push   0xc(%ebp)
  801834:	50                   	push   %eax
  801835:	e8 43 01 00 00       	call   80197d <nsipc_shutdown>
  80183a:	83 c4 10             	add    $0x10,%esp
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <connect>:
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	e8 d6 fe ff ff       	call   801723 <fd2sockid>
  80184d:	85 c0                	test   %eax,%eax
  80184f:	78 12                	js     801863 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801851:	83 ec 04             	sub    $0x4,%esp
  801854:	ff 75 10             	push   0x10(%ebp)
  801857:	ff 75 0c             	push   0xc(%ebp)
  80185a:	50                   	push   %eax
  80185b:	e8 59 01 00 00       	call   8019b9 <nsipc_connect>
  801860:	83 c4 10             	add    $0x10,%esp
}
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <listen>:
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	e8 b0 fe ff ff       	call   801723 <fd2sockid>
  801873:	85 c0                	test   %eax,%eax
  801875:	78 0f                	js     801886 <listen+0x21>
	return nsipc_listen(r, backlog);
  801877:	83 ec 08             	sub    $0x8,%esp
  80187a:	ff 75 0c             	push   0xc(%ebp)
  80187d:	50                   	push   %eax
  80187e:	e8 6b 01 00 00       	call   8019ee <nsipc_listen>
  801883:	83 c4 10             	add    $0x10,%esp
}
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <socket>:

int
socket(int domain, int type, int protocol)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80188e:	ff 75 10             	push   0x10(%ebp)
  801891:	ff 75 0c             	push   0xc(%ebp)
  801894:	ff 75 08             	push   0x8(%ebp)
  801897:	e8 41 02 00 00       	call   801add <nsipc_socket>
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	78 05                	js     8018a8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018a3:	e8 ab fe ff ff       	call   801753 <alloc_sockfd>
}
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018b3:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8018ba:	74 26                	je     8018e2 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018bc:	6a 07                	push   $0x7
  8018be:	68 00 70 80 00       	push   $0x807000
  8018c3:	53                   	push   %ebx
  8018c4:	ff 35 00 80 80 00    	push   0x808000
  8018ca:	e8 66 07 00 00       	call   802035 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018cf:	83 c4 0c             	add    $0xc,%esp
  8018d2:	6a 00                	push   $0x0
  8018d4:	6a 00                	push   $0x0
  8018d6:	6a 00                	push   $0x0
  8018d8:	e8 e8 06 00 00       	call   801fc5 <ipc_recv>
}
  8018dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	6a 02                	push   $0x2
  8018e7:	e8 9d 07 00 00       	call   802089 <ipc_find_env>
  8018ec:	a3 00 80 80 00       	mov    %eax,0x808000
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	eb c6                	jmp    8018bc <nsipc+0x12>

008018f6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	56                   	push   %esi
  8018fa:	53                   	push   %ebx
  8018fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801906:	8b 06                	mov    (%esi),%eax
  801908:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80190d:	b8 01 00 00 00       	mov    $0x1,%eax
  801912:	e8 93 ff ff ff       	call   8018aa <nsipc>
  801917:	89 c3                	mov    %eax,%ebx
  801919:	85 c0                	test   %eax,%eax
  80191b:	79 09                	jns    801926 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80191d:	89 d8                	mov    %ebx,%eax
  80191f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801926:	83 ec 04             	sub    $0x4,%esp
  801929:	ff 35 10 70 80 00    	push   0x807010
  80192f:	68 00 70 80 00       	push   $0x807000
  801934:	ff 75 0c             	push   0xc(%ebp)
  801937:	e8 27 f0 ff ff       	call   800963 <memmove>
		*addrlen = ret->ret_addrlen;
  80193c:	a1 10 70 80 00       	mov    0x807010,%eax
  801941:	89 06                	mov    %eax,(%esi)
  801943:	83 c4 10             	add    $0x10,%esp
	return r;
  801946:	eb d5                	jmp    80191d <nsipc_accept+0x27>

00801948 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	53                   	push   %ebx
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801952:	8b 45 08             	mov    0x8(%ebp),%eax
  801955:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80195a:	53                   	push   %ebx
  80195b:	ff 75 0c             	push   0xc(%ebp)
  80195e:	68 04 70 80 00       	push   $0x807004
  801963:	e8 fb ef ff ff       	call   800963 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801968:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80196e:	b8 02 00 00 00       	mov    $0x2,%eax
  801973:	e8 32 ff ff ff       	call   8018aa <nsipc>
}
  801978:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80198b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801993:	b8 03 00 00 00       	mov    $0x3,%eax
  801998:	e8 0d ff ff ff       	call   8018aa <nsipc>
}
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <nsipc_close>:

int
nsipc_close(int s)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a8:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8019ad:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b2:	e8 f3 fe ff ff       	call   8018aa <nsipc>
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	53                   	push   %ebx
  8019bd:	83 ec 08             	sub    $0x8,%esp
  8019c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019cb:	53                   	push   %ebx
  8019cc:	ff 75 0c             	push   0xc(%ebp)
  8019cf:	68 04 70 80 00       	push   $0x807004
  8019d4:	e8 8a ef ff ff       	call   800963 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019d9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8019df:	b8 05 00 00 00       	mov    $0x5,%eax
  8019e4:	e8 c1 fe ff ff       	call   8018aa <nsipc>
}
  8019e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8019fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ff:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801a04:	b8 06 00 00 00       	mov    $0x6,%eax
  801a09:	e8 9c fe ff ff       	call   8018aa <nsipc>
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
  801a15:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801a20:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801a26:	8b 45 14             	mov    0x14(%ebp),%eax
  801a29:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a2e:	b8 07 00 00 00       	mov    $0x7,%eax
  801a33:	e8 72 fe ff ff       	call   8018aa <nsipc>
  801a38:	89 c3                	mov    %eax,%ebx
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	78 22                	js     801a60 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801a3e:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801a43:	39 c6                	cmp    %eax,%esi
  801a45:	0f 4e c6             	cmovle %esi,%eax
  801a48:	39 c3                	cmp    %eax,%ebx
  801a4a:	7f 1d                	jg     801a69 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a4c:	83 ec 04             	sub    $0x4,%esp
  801a4f:	53                   	push   %ebx
  801a50:	68 00 70 80 00       	push   $0x807000
  801a55:	ff 75 0c             	push   0xc(%ebp)
  801a58:	e8 06 ef ff ff       	call   800963 <memmove>
  801a5d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a60:	89 d8                	mov    %ebx,%eax
  801a62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801a69:	68 7f 28 80 00       	push   $0x80287f
  801a6e:	68 47 28 80 00       	push   $0x802847
  801a73:	6a 62                	push   $0x62
  801a75:	68 94 28 80 00       	push   $0x802894
  801a7a:	e8 99 e6 ff ff       	call   800118 <_panic>

00801a7f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	53                   	push   %ebx
  801a83:	83 ec 04             	sub    $0x4,%esp
  801a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a89:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8c:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801a91:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a97:	7f 2e                	jg     801ac7 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a99:	83 ec 04             	sub    $0x4,%esp
  801a9c:	53                   	push   %ebx
  801a9d:	ff 75 0c             	push   0xc(%ebp)
  801aa0:	68 0c 70 80 00       	push   $0x80700c
  801aa5:	e8 b9 ee ff ff       	call   800963 <memmove>
	nsipcbuf.send.req_size = size;
  801aaa:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801ab0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801ab8:	b8 08 00 00 00       	mov    $0x8,%eax
  801abd:	e8 e8 fd ff ff       	call   8018aa <nsipc>
}
  801ac2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    
	assert(size < 1600);
  801ac7:	68 a0 28 80 00       	push   $0x8028a0
  801acc:	68 47 28 80 00       	push   $0x802847
  801ad1:	6a 6d                	push   $0x6d
  801ad3:	68 94 28 80 00       	push   $0x802894
  801ad8:	e8 3b e6 ff ff       	call   800118 <_panic>

00801add <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aee:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801af3:	8b 45 10             	mov    0x10(%ebp),%eax
  801af6:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801afb:	b8 09 00 00 00       	mov    $0x9,%eax
  801b00:	e8 a5 fd ff ff       	call   8018aa <nsipc>
}
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	ff 75 08             	push   0x8(%ebp)
  801b15:	e8 ad f3 ff ff       	call   800ec7 <fd2data>
  801b1a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b1c:	83 c4 08             	add    $0x8,%esp
  801b1f:	68 ac 28 80 00       	push   $0x8028ac
  801b24:	53                   	push   %ebx
  801b25:	e8 a3 ec ff ff       	call   8007cd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b2a:	8b 46 04             	mov    0x4(%esi),%eax
  801b2d:	2b 06                	sub    (%esi),%eax
  801b2f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b35:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b3c:	00 00 00 
	stat->st_dev = &devpipe;
  801b3f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b46:	30 80 00 
	return 0;
}
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	53                   	push   %ebx
  801b59:	83 ec 0c             	sub    $0xc,%esp
  801b5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b5f:	53                   	push   %ebx
  801b60:	6a 00                	push   $0x0
  801b62:	e8 e7 f0 ff ff       	call   800c4e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b67:	89 1c 24             	mov    %ebx,(%esp)
  801b6a:	e8 58 f3 ff ff       	call   800ec7 <fd2data>
  801b6f:	83 c4 08             	add    $0x8,%esp
  801b72:	50                   	push   %eax
  801b73:	6a 00                	push   $0x0
  801b75:	e8 d4 f0 ff ff       	call   800c4e <sys_page_unmap>
}
  801b7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <_pipeisclosed>:
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	57                   	push   %edi
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	83 ec 1c             	sub    $0x1c,%esp
  801b88:	89 c7                	mov    %eax,%edi
  801b8a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b8c:	a1 00 40 80 00       	mov    0x804000,%eax
  801b91:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b94:	83 ec 0c             	sub    $0xc,%esp
  801b97:	57                   	push   %edi
  801b98:	e8 2b 05 00 00       	call   8020c8 <pageref>
  801b9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ba0:	89 34 24             	mov    %esi,(%esp)
  801ba3:	e8 20 05 00 00       	call   8020c8 <pageref>
		nn = thisenv->env_runs;
  801ba8:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801bae:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	39 cb                	cmp    %ecx,%ebx
  801bb6:	74 1b                	je     801bd3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bb8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bbb:	75 cf                	jne    801b8c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bbd:	8b 42 68             	mov    0x68(%edx),%eax
  801bc0:	6a 01                	push   $0x1
  801bc2:	50                   	push   %eax
  801bc3:	53                   	push   %ebx
  801bc4:	68 b3 28 80 00       	push   $0x8028b3
  801bc9:	e8 25 e6 ff ff       	call   8001f3 <cprintf>
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	eb b9                	jmp    801b8c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801bd3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bd6:	0f 94 c0             	sete   %al
  801bd9:	0f b6 c0             	movzbl %al,%eax
}
  801bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdf:	5b                   	pop    %ebx
  801be0:	5e                   	pop    %esi
  801be1:	5f                   	pop    %edi
  801be2:	5d                   	pop    %ebp
  801be3:	c3                   	ret    

00801be4 <devpipe_write>:
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	57                   	push   %edi
  801be8:	56                   	push   %esi
  801be9:	53                   	push   %ebx
  801bea:	83 ec 28             	sub    $0x28,%esp
  801bed:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801bf0:	56                   	push   %esi
  801bf1:	e8 d1 f2 ff ff       	call   800ec7 <fd2data>
  801bf6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	bf 00 00 00 00       	mov    $0x0,%edi
  801c00:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c03:	75 09                	jne    801c0e <devpipe_write+0x2a>
	return i;
  801c05:	89 f8                	mov    %edi,%eax
  801c07:	eb 23                	jmp    801c2c <devpipe_write+0x48>
			sys_yield();
  801c09:	e8 9c ef ff ff       	call   800baa <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c0e:	8b 43 04             	mov    0x4(%ebx),%eax
  801c11:	8b 0b                	mov    (%ebx),%ecx
  801c13:	8d 51 20             	lea    0x20(%ecx),%edx
  801c16:	39 d0                	cmp    %edx,%eax
  801c18:	72 1a                	jb     801c34 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801c1a:	89 da                	mov    %ebx,%edx
  801c1c:	89 f0                	mov    %esi,%eax
  801c1e:	e8 5c ff ff ff       	call   801b7f <_pipeisclosed>
  801c23:	85 c0                	test   %eax,%eax
  801c25:	74 e2                	je     801c09 <devpipe_write+0x25>
				return 0;
  801c27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c37:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c3b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c3e:	89 c2                	mov    %eax,%edx
  801c40:	c1 fa 1f             	sar    $0x1f,%edx
  801c43:	89 d1                	mov    %edx,%ecx
  801c45:	c1 e9 1b             	shr    $0x1b,%ecx
  801c48:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c4b:	83 e2 1f             	and    $0x1f,%edx
  801c4e:	29 ca                	sub    %ecx,%edx
  801c50:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c54:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c58:	83 c0 01             	add    $0x1,%eax
  801c5b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c5e:	83 c7 01             	add    $0x1,%edi
  801c61:	eb 9d                	jmp    801c00 <devpipe_write+0x1c>

00801c63 <devpipe_read>:
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	57                   	push   %edi
  801c67:	56                   	push   %esi
  801c68:	53                   	push   %ebx
  801c69:	83 ec 18             	sub    $0x18,%esp
  801c6c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c6f:	57                   	push   %edi
  801c70:	e8 52 f2 ff ff       	call   800ec7 <fd2data>
  801c75:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	be 00 00 00 00       	mov    $0x0,%esi
  801c7f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c82:	75 13                	jne    801c97 <devpipe_read+0x34>
	return i;
  801c84:	89 f0                	mov    %esi,%eax
  801c86:	eb 02                	jmp    801c8a <devpipe_read+0x27>
				return i;
  801c88:	89 f0                	mov    %esi,%eax
}
  801c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
			sys_yield();
  801c92:	e8 13 ef ff ff       	call   800baa <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c97:	8b 03                	mov    (%ebx),%eax
  801c99:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c9c:	75 18                	jne    801cb6 <devpipe_read+0x53>
			if (i > 0)
  801c9e:	85 f6                	test   %esi,%esi
  801ca0:	75 e6                	jne    801c88 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801ca2:	89 da                	mov    %ebx,%edx
  801ca4:	89 f8                	mov    %edi,%eax
  801ca6:	e8 d4 fe ff ff       	call   801b7f <_pipeisclosed>
  801cab:	85 c0                	test   %eax,%eax
  801cad:	74 e3                	je     801c92 <devpipe_read+0x2f>
				return 0;
  801caf:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb4:	eb d4                	jmp    801c8a <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cb6:	99                   	cltd   
  801cb7:	c1 ea 1b             	shr    $0x1b,%edx
  801cba:	01 d0                	add    %edx,%eax
  801cbc:	83 e0 1f             	and    $0x1f,%eax
  801cbf:	29 d0                	sub    %edx,%eax
  801cc1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ccc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ccf:	83 c6 01             	add    $0x1,%esi
  801cd2:	eb ab                	jmp    801c7f <devpipe_read+0x1c>

00801cd4 <pipe>:
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801cdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdf:	50                   	push   %eax
  801ce0:	e8 f9 f1 ff ff       	call   800ede <fd_alloc>
  801ce5:	89 c3                	mov    %eax,%ebx
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	0f 88 23 01 00 00    	js     801e15 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf2:	83 ec 04             	sub    $0x4,%esp
  801cf5:	68 07 04 00 00       	push   $0x407
  801cfa:	ff 75 f4             	push   -0xc(%ebp)
  801cfd:	6a 00                	push   $0x0
  801cff:	e8 c5 ee ff ff       	call   800bc9 <sys_page_alloc>
  801d04:	89 c3                	mov    %eax,%ebx
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	0f 88 04 01 00 00    	js     801e15 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	e8 c1 f1 ff ff       	call   800ede <fd_alloc>
  801d1d:	89 c3                	mov    %eax,%ebx
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	85 c0                	test   %eax,%eax
  801d24:	0f 88 db 00 00 00    	js     801e05 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d2a:	83 ec 04             	sub    $0x4,%esp
  801d2d:	68 07 04 00 00       	push   $0x407
  801d32:	ff 75 f0             	push   -0x10(%ebp)
  801d35:	6a 00                	push   $0x0
  801d37:	e8 8d ee ff ff       	call   800bc9 <sys_page_alloc>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 c0                	test   %eax,%eax
  801d43:	0f 88 bc 00 00 00    	js     801e05 <pipe+0x131>
	va = fd2data(fd0);
  801d49:	83 ec 0c             	sub    $0xc,%esp
  801d4c:	ff 75 f4             	push   -0xc(%ebp)
  801d4f:	e8 73 f1 ff ff       	call   800ec7 <fd2data>
  801d54:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d56:	83 c4 0c             	add    $0xc,%esp
  801d59:	68 07 04 00 00       	push   $0x407
  801d5e:	50                   	push   %eax
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 63 ee ff ff       	call   800bc9 <sys_page_alloc>
  801d66:	89 c3                	mov    %eax,%ebx
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	0f 88 82 00 00 00    	js     801df5 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	ff 75 f0             	push   -0x10(%ebp)
  801d79:	e8 49 f1 ff ff       	call   800ec7 <fd2data>
  801d7e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d85:	50                   	push   %eax
  801d86:	6a 00                	push   $0x0
  801d88:	56                   	push   %esi
  801d89:	6a 00                	push   $0x0
  801d8b:	e8 7c ee ff ff       	call   800c0c <sys_page_map>
  801d90:	89 c3                	mov    %eax,%ebx
  801d92:	83 c4 20             	add    $0x20,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 4e                	js     801de7 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801d99:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801da1:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801da3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801da6:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801dad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801db0:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	ff 75 f4             	push   -0xc(%ebp)
  801dc2:	e8 f0 f0 ff ff       	call   800eb7 <fd2num>
  801dc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dca:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dcc:	83 c4 04             	add    $0x4,%esp
  801dcf:	ff 75 f0             	push   -0x10(%ebp)
  801dd2:	e8 e0 f0 ff ff       	call   800eb7 <fd2num>
  801dd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dda:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801de5:	eb 2e                	jmp    801e15 <pipe+0x141>
	sys_page_unmap(0, va);
  801de7:	83 ec 08             	sub    $0x8,%esp
  801dea:	56                   	push   %esi
  801deb:	6a 00                	push   $0x0
  801ded:	e8 5c ee ff ff       	call   800c4e <sys_page_unmap>
  801df2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801df5:	83 ec 08             	sub    $0x8,%esp
  801df8:	ff 75 f0             	push   -0x10(%ebp)
  801dfb:	6a 00                	push   $0x0
  801dfd:	e8 4c ee ff ff       	call   800c4e <sys_page_unmap>
  801e02:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e05:	83 ec 08             	sub    $0x8,%esp
  801e08:	ff 75 f4             	push   -0xc(%ebp)
  801e0b:	6a 00                	push   $0x0
  801e0d:	e8 3c ee ff ff       	call   800c4e <sys_page_unmap>
  801e12:	83 c4 10             	add    $0x10,%esp
}
  801e15:	89 d8                	mov    %ebx,%eax
  801e17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e1a:	5b                   	pop    %ebx
  801e1b:	5e                   	pop    %esi
  801e1c:	5d                   	pop    %ebp
  801e1d:	c3                   	ret    

00801e1e <pipeisclosed>:
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e27:	50                   	push   %eax
  801e28:	ff 75 08             	push   0x8(%ebp)
  801e2b:	e8 fe f0 ff ff       	call   800f2e <fd_lookup>
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 18                	js     801e4f <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e37:	83 ec 0c             	sub    $0xc,%esp
  801e3a:	ff 75 f4             	push   -0xc(%ebp)
  801e3d:	e8 85 f0 ff ff       	call   800ec7 <fd2data>
  801e42:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e47:	e8 33 fd ff ff       	call   801b7f <_pipeisclosed>
  801e4c:	83 c4 10             	add    $0x10,%esp
}
  801e4f:	c9                   	leave  
  801e50:	c3                   	ret    

00801e51 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801e51:	b8 00 00 00 00       	mov    $0x0,%eax
  801e56:	c3                   	ret    

00801e57 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e5d:	68 cb 28 80 00       	push   $0x8028cb
  801e62:	ff 75 0c             	push   0xc(%ebp)
  801e65:	e8 63 e9 ff ff       	call   8007cd <strcpy>
	return 0;
}
  801e6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <devcons_write>:
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	57                   	push   %edi
  801e75:	56                   	push   %esi
  801e76:	53                   	push   %ebx
  801e77:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e7d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e82:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e88:	eb 2e                	jmp    801eb8 <devcons_write+0x47>
		m = n - tot;
  801e8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e8d:	29 f3                	sub    %esi,%ebx
  801e8f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e94:	39 c3                	cmp    %eax,%ebx
  801e96:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e99:	83 ec 04             	sub    $0x4,%esp
  801e9c:	53                   	push   %ebx
  801e9d:	89 f0                	mov    %esi,%eax
  801e9f:	03 45 0c             	add    0xc(%ebp),%eax
  801ea2:	50                   	push   %eax
  801ea3:	57                   	push   %edi
  801ea4:	e8 ba ea ff ff       	call   800963 <memmove>
		sys_cputs(buf, m);
  801ea9:	83 c4 08             	add    $0x8,%esp
  801eac:	53                   	push   %ebx
  801ead:	57                   	push   %edi
  801eae:	e8 5a ec ff ff       	call   800b0d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801eb3:	01 de                	add    %ebx,%esi
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ebb:	72 cd                	jb     801e8a <devcons_write+0x19>
}
  801ebd:	89 f0                	mov    %esi,%eax
  801ebf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec2:	5b                   	pop    %ebx
  801ec3:	5e                   	pop    %esi
  801ec4:	5f                   	pop    %edi
  801ec5:	5d                   	pop    %ebp
  801ec6:	c3                   	ret    

00801ec7 <devcons_read>:
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ed2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed6:	75 07                	jne    801edf <devcons_read+0x18>
  801ed8:	eb 1f                	jmp    801ef9 <devcons_read+0x32>
		sys_yield();
  801eda:	e8 cb ec ff ff       	call   800baa <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801edf:	e8 47 ec ff ff       	call   800b2b <sys_cgetc>
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	74 f2                	je     801eda <devcons_read+0x13>
	if (c < 0)
  801ee8:	78 0f                	js     801ef9 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801eea:	83 f8 04             	cmp    $0x4,%eax
  801eed:	74 0c                	je     801efb <devcons_read+0x34>
	*(char*)vbuf = c;
  801eef:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef2:	88 02                	mov    %al,(%edx)
	return 1;
  801ef4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    
		return 0;
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
  801f00:	eb f7                	jmp    801ef9 <devcons_read+0x32>

00801f02 <cputchar>:
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f08:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f0e:	6a 01                	push   $0x1
  801f10:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f13:	50                   	push   %eax
  801f14:	e8 f4 eb ff ff       	call   800b0d <sys_cputs>
}
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    

00801f1e <getchar>:
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f24:	6a 01                	push   $0x1
  801f26:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f29:	50                   	push   %eax
  801f2a:	6a 00                	push   $0x0
  801f2c:	e8 66 f2 ff ff       	call   801197 <read>
	if (r < 0)
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	85 c0                	test   %eax,%eax
  801f36:	78 06                	js     801f3e <getchar+0x20>
	if (r < 1)
  801f38:	74 06                	je     801f40 <getchar+0x22>
	return c;
  801f3a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f3e:	c9                   	leave  
  801f3f:	c3                   	ret    
		return -E_EOF;
  801f40:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f45:	eb f7                	jmp    801f3e <getchar+0x20>

00801f47 <iscons>:
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f50:	50                   	push   %eax
  801f51:	ff 75 08             	push   0x8(%ebp)
  801f54:	e8 d5 ef ff ff       	call   800f2e <fd_lookup>
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 11                	js     801f71 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f63:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f69:	39 10                	cmp    %edx,(%eax)
  801f6b:	0f 94 c0             	sete   %al
  801f6e:	0f b6 c0             	movzbl %al,%eax
}
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    

00801f73 <opencons>:
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7c:	50                   	push   %eax
  801f7d:	e8 5c ef ff ff       	call   800ede <fd_alloc>
  801f82:	83 c4 10             	add    $0x10,%esp
  801f85:	85 c0                	test   %eax,%eax
  801f87:	78 3a                	js     801fc3 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f89:	83 ec 04             	sub    $0x4,%esp
  801f8c:	68 07 04 00 00       	push   $0x407
  801f91:	ff 75 f4             	push   -0xc(%ebp)
  801f94:	6a 00                	push   $0x0
  801f96:	e8 2e ec ff ff       	call   800bc9 <sys_page_alloc>
  801f9b:	83 c4 10             	add    $0x10,%esp
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	78 21                	js     801fc3 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fab:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb7:	83 ec 0c             	sub    $0xc,%esp
  801fba:	50                   	push   %eax
  801fbb:	e8 f7 ee ff ff       	call   800eb7 <fd2num>
  801fc0:	83 c4 10             	add    $0x10,%esp
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	56                   	push   %esi
  801fc9:	53                   	push   %ebx
  801fca:	8b 75 08             	mov    0x8(%ebp),%esi
  801fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fda:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801fdd:	83 ec 0c             	sub    $0xc,%esp
  801fe0:	50                   	push   %eax
  801fe1:	e8 93 ed ff ff       	call   800d79 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	85 f6                	test   %esi,%esi
  801feb:	74 17                	je     802004 <ipc_recv+0x3f>
  801fed:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	78 0c                	js     802002 <ipc_recv+0x3d>
  801ff6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ffc:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802002:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802004:	85 db                	test   %ebx,%ebx
  802006:	74 17                	je     80201f <ipc_recv+0x5a>
  802008:	ba 00 00 00 00       	mov    $0x0,%edx
  80200d:	85 c0                	test   %eax,%eax
  80200f:	78 0c                	js     80201d <ipc_recv+0x58>
  802011:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802017:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80201d:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80201f:	85 c0                	test   %eax,%eax
  802021:	78 0b                	js     80202e <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802023:	a1 00 40 80 00       	mov    0x804000,%eax
  802028:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  80202e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802031:	5b                   	pop    %ebx
  802032:	5e                   	pop    %esi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    

00802035 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	57                   	push   %edi
  802039:	56                   	push   %esi
  80203a:	53                   	push   %ebx
  80203b:	83 ec 0c             	sub    $0xc,%esp
  80203e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802041:	8b 75 0c             	mov    0xc(%ebp),%esi
  802044:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802047:	85 db                	test   %ebx,%ebx
  802049:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80204e:	0f 44 d8             	cmove  %eax,%ebx
  802051:	eb 05                	jmp    802058 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802053:	e8 52 eb ff ff       	call   800baa <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802058:	ff 75 14             	push   0x14(%ebp)
  80205b:	53                   	push   %ebx
  80205c:	56                   	push   %esi
  80205d:	57                   	push   %edi
  80205e:	e8 f3 ec ff ff       	call   800d56 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802063:	83 c4 10             	add    $0x10,%esp
  802066:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802069:	74 e8                	je     802053 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80206b:	85 c0                	test   %eax,%eax
  80206d:	78 08                	js     802077 <ipc_send+0x42>
	}while (r<0);

}
  80206f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802072:	5b                   	pop    %ebx
  802073:	5e                   	pop    %esi
  802074:	5f                   	pop    %edi
  802075:	5d                   	pop    %ebp
  802076:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802077:	50                   	push   %eax
  802078:	68 d7 28 80 00       	push   $0x8028d7
  80207d:	6a 3d                	push   $0x3d
  80207f:	68 eb 28 80 00       	push   $0x8028eb
  802084:	e8 8f e0 ff ff       	call   800118 <_panic>

00802089 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80208f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802094:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80209a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a0:	8b 52 60             	mov    0x60(%edx),%edx
  8020a3:	39 ca                	cmp    %ecx,%edx
  8020a5:	74 11                	je     8020b8 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8020a7:	83 c0 01             	add    $0x1,%eax
  8020aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020af:	75 e3                	jne    802094 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8020b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b6:	eb 0e                	jmp    8020c6 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8020b8:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8020be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c3:	8b 40 58             	mov    0x58(%eax),%eax
}
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    

008020c8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ce:	89 c2                	mov    %eax,%edx
  8020d0:	c1 ea 16             	shr    $0x16,%edx
  8020d3:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020da:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020df:	f6 c1 01             	test   $0x1,%cl
  8020e2:	74 1c                	je     802100 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8020e4:	c1 e8 0c             	shr    $0xc,%eax
  8020e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020ee:	a8 01                	test   $0x1,%al
  8020f0:	74 0e                	je     802100 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f2:	c1 e8 0c             	shr    $0xc,%eax
  8020f5:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020fc:	ef 
  8020fd:	0f b7 d2             	movzwl %dx,%edx
}
  802100:	89 d0                	mov    %edx,%eax
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__udivdi3>:
  802110:	f3 0f 1e fb          	endbr32 
  802114:	55                   	push   %ebp
  802115:	57                   	push   %edi
  802116:	56                   	push   %esi
  802117:	53                   	push   %ebx
  802118:	83 ec 1c             	sub    $0x1c,%esp
  80211b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80211f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802123:	8b 74 24 34          	mov    0x34(%esp),%esi
  802127:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80212b:	85 c0                	test   %eax,%eax
  80212d:	75 19                	jne    802148 <__udivdi3+0x38>
  80212f:	39 f3                	cmp    %esi,%ebx
  802131:	76 4d                	jbe    802180 <__udivdi3+0x70>
  802133:	31 ff                	xor    %edi,%edi
  802135:	89 e8                	mov    %ebp,%eax
  802137:	89 f2                	mov    %esi,%edx
  802139:	f7 f3                	div    %ebx
  80213b:	89 fa                	mov    %edi,%edx
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	39 f0                	cmp    %esi,%eax
  80214a:	76 14                	jbe    802160 <__udivdi3+0x50>
  80214c:	31 ff                	xor    %edi,%edi
  80214e:	31 c0                	xor    %eax,%eax
  802150:	89 fa                	mov    %edi,%edx
  802152:	83 c4 1c             	add    $0x1c,%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5f                   	pop    %edi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	0f bd f8             	bsr    %eax,%edi
  802163:	83 f7 1f             	xor    $0x1f,%edi
  802166:	75 48                	jne    8021b0 <__udivdi3+0xa0>
  802168:	39 f0                	cmp    %esi,%eax
  80216a:	72 06                	jb     802172 <__udivdi3+0x62>
  80216c:	31 c0                	xor    %eax,%eax
  80216e:	39 eb                	cmp    %ebp,%ebx
  802170:	77 de                	ja     802150 <__udivdi3+0x40>
  802172:	b8 01 00 00 00       	mov    $0x1,%eax
  802177:	eb d7                	jmp    802150 <__udivdi3+0x40>
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d9                	mov    %ebx,%ecx
  802182:	85 db                	test   %ebx,%ebx
  802184:	75 0b                	jne    802191 <__udivdi3+0x81>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f3                	div    %ebx
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	31 d2                	xor    %edx,%edx
  802193:	89 f0                	mov    %esi,%eax
  802195:	f7 f1                	div    %ecx
  802197:	89 c6                	mov    %eax,%esi
  802199:	89 e8                	mov    %ebp,%eax
  80219b:	89 f7                	mov    %esi,%edi
  80219d:	f7 f1                	div    %ecx
  80219f:	89 fa                	mov    %edi,%edx
  8021a1:	83 c4 1c             	add    $0x1c,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 f9                	mov    %edi,%ecx
  8021b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8021b7:	29 fa                	sub    %edi,%edx
  8021b9:	d3 e0                	shl    %cl,%eax
  8021bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021bf:	89 d1                	mov    %edx,%ecx
  8021c1:	89 d8                	mov    %ebx,%eax
  8021c3:	d3 e8                	shr    %cl,%eax
  8021c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021c9:	09 c1                	or     %eax,%ecx
  8021cb:	89 f0                	mov    %esi,%eax
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	d3 e3                	shl    %cl,%ebx
  8021d5:	89 d1                	mov    %edx,%ecx
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 f9                	mov    %edi,%ecx
  8021db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021df:	89 eb                	mov    %ebp,%ebx
  8021e1:	d3 e6                	shl    %cl,%esi
  8021e3:	89 d1                	mov    %edx,%ecx
  8021e5:	d3 eb                	shr    %cl,%ebx
  8021e7:	09 f3                	or     %esi,%ebx
  8021e9:	89 c6                	mov    %eax,%esi
  8021eb:	89 f2                	mov    %esi,%edx
  8021ed:	89 d8                	mov    %ebx,%eax
  8021ef:	f7 74 24 08          	divl   0x8(%esp)
  8021f3:	89 d6                	mov    %edx,%esi
  8021f5:	89 c3                	mov    %eax,%ebx
  8021f7:	f7 64 24 0c          	mull   0xc(%esp)
  8021fb:	39 d6                	cmp    %edx,%esi
  8021fd:	72 19                	jb     802218 <__udivdi3+0x108>
  8021ff:	89 f9                	mov    %edi,%ecx
  802201:	d3 e5                	shl    %cl,%ebp
  802203:	39 c5                	cmp    %eax,%ebp
  802205:	73 04                	jae    80220b <__udivdi3+0xfb>
  802207:	39 d6                	cmp    %edx,%esi
  802209:	74 0d                	je     802218 <__udivdi3+0x108>
  80220b:	89 d8                	mov    %ebx,%eax
  80220d:	31 ff                	xor    %edi,%edi
  80220f:	e9 3c ff ff ff       	jmp    802150 <__udivdi3+0x40>
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80221b:	31 ff                	xor    %edi,%edi
  80221d:	e9 2e ff ff ff       	jmp    802150 <__udivdi3+0x40>
  802222:	66 90                	xchg   %ax,%ax
  802224:	66 90                	xchg   %ax,%ax
  802226:	66 90                	xchg   %ax,%ax
  802228:	66 90                	xchg   %ax,%ax
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__umoddi3>:
  802230:	f3 0f 1e fb          	endbr32 
  802234:	55                   	push   %ebp
  802235:	57                   	push   %edi
  802236:	56                   	push   %esi
  802237:	53                   	push   %ebx
  802238:	83 ec 1c             	sub    $0x1c,%esp
  80223b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80223f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802243:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802247:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80224b:	89 f0                	mov    %esi,%eax
  80224d:	89 da                	mov    %ebx,%edx
  80224f:	85 ff                	test   %edi,%edi
  802251:	75 15                	jne    802268 <__umoddi3+0x38>
  802253:	39 dd                	cmp    %ebx,%ebp
  802255:	76 39                	jbe    802290 <__umoddi3+0x60>
  802257:	f7 f5                	div    %ebp
  802259:	89 d0                	mov    %edx,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	83 c4 1c             	add    $0x1c,%esp
  802260:	5b                   	pop    %ebx
  802261:	5e                   	pop    %esi
  802262:	5f                   	pop    %edi
  802263:	5d                   	pop    %ebp
  802264:	c3                   	ret    
  802265:	8d 76 00             	lea    0x0(%esi),%esi
  802268:	39 df                	cmp    %ebx,%edi
  80226a:	77 f1                	ja     80225d <__umoddi3+0x2d>
  80226c:	0f bd cf             	bsr    %edi,%ecx
  80226f:	83 f1 1f             	xor    $0x1f,%ecx
  802272:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802276:	75 40                	jne    8022b8 <__umoddi3+0x88>
  802278:	39 df                	cmp    %ebx,%edi
  80227a:	72 04                	jb     802280 <__umoddi3+0x50>
  80227c:	39 f5                	cmp    %esi,%ebp
  80227e:	77 dd                	ja     80225d <__umoddi3+0x2d>
  802280:	89 da                	mov    %ebx,%edx
  802282:	89 f0                	mov    %esi,%eax
  802284:	29 e8                	sub    %ebp,%eax
  802286:	19 fa                	sbb    %edi,%edx
  802288:	eb d3                	jmp    80225d <__umoddi3+0x2d>
  80228a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802290:	89 e9                	mov    %ebp,%ecx
  802292:	85 ed                	test   %ebp,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x71>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f5                	div    %ebp
  80229f:	89 c1                	mov    %eax,%ecx
  8022a1:	89 d8                	mov    %ebx,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f1                	div    %ecx
  8022a7:	89 f0                	mov    %esi,%eax
  8022a9:	f7 f1                	div    %ecx
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	31 d2                	xor    %edx,%edx
  8022af:	eb ac                	jmp    80225d <__umoddi3+0x2d>
  8022b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8022c1:	29 c2                	sub    %eax,%edx
  8022c3:	89 c1                	mov    %eax,%ecx
  8022c5:	89 e8                	mov    %ebp,%eax
  8022c7:	d3 e7                	shl    %cl,%edi
  8022c9:	89 d1                	mov    %edx,%ecx
  8022cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022cf:	d3 e8                	shr    %cl,%eax
  8022d1:	89 c1                	mov    %eax,%ecx
  8022d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022d7:	09 f9                	or     %edi,%ecx
  8022d9:	89 df                	mov    %ebx,%edi
  8022db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022df:	89 c1                	mov    %eax,%ecx
  8022e1:	d3 e5                	shl    %cl,%ebp
  8022e3:	89 d1                	mov    %edx,%ecx
  8022e5:	d3 ef                	shr    %cl,%edi
  8022e7:	89 c1                	mov    %eax,%ecx
  8022e9:	89 f0                	mov    %esi,%eax
  8022eb:	d3 e3                	shl    %cl,%ebx
  8022ed:	89 d1                	mov    %edx,%ecx
  8022ef:	89 fa                	mov    %edi,%edx
  8022f1:	d3 e8                	shr    %cl,%eax
  8022f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022f8:	09 d8                	or     %ebx,%eax
  8022fa:	f7 74 24 08          	divl   0x8(%esp)
  8022fe:	89 d3                	mov    %edx,%ebx
  802300:	d3 e6                	shl    %cl,%esi
  802302:	f7 e5                	mul    %ebp
  802304:	89 c7                	mov    %eax,%edi
  802306:	89 d1                	mov    %edx,%ecx
  802308:	39 d3                	cmp    %edx,%ebx
  80230a:	72 06                	jb     802312 <__umoddi3+0xe2>
  80230c:	75 0e                	jne    80231c <__umoddi3+0xec>
  80230e:	39 c6                	cmp    %eax,%esi
  802310:	73 0a                	jae    80231c <__umoddi3+0xec>
  802312:	29 e8                	sub    %ebp,%eax
  802314:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802318:	89 d1                	mov    %edx,%ecx
  80231a:	89 c7                	mov    %eax,%edi
  80231c:	89 f5                	mov    %esi,%ebp
  80231e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802322:	29 fd                	sub    %edi,%ebp
  802324:	19 cb                	sbb    %ecx,%ebx
  802326:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80232b:	89 d8                	mov    %ebx,%eax
  80232d:	d3 e0                	shl    %cl,%eax
  80232f:	89 f1                	mov    %esi,%ecx
  802331:	d3 ed                	shr    %cl,%ebp
  802333:	d3 eb                	shr    %cl,%ebx
  802335:	09 e8                	or     %ebp,%eax
  802337:	89 da                	mov    %ebx,%edx
  802339:	83 c4 1c             	add    $0x1c,%esp
  80233c:	5b                   	pop    %ebx
  80233d:	5e                   	pop    %esi
  80233e:	5f                   	pop    %edi
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    
