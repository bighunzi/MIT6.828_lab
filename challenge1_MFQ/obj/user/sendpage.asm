
obj/user/sendpage.debug：     文件格式 elf32-i386


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
  80002c:	e8 73 01 00 00       	call   8001a4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 84 0f 00 00       	call   800fc2 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 84 a5 00 00 00    	je     8000ee <umain+0xbb>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800049:	a1 00 40 80 00       	mov    0x804000,%eax
  80004e:	8b 40 58             	mov    0x58(%eax),%eax
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 a0 00       	push   $0xa00000
  80005b:	50                   	push   %eax
  80005c:	e8 11 0c 00 00       	call   800c72 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800061:	83 c4 04             	add    $0x4,%esp
  800064:	ff 35 04 30 80 00    	push   0x803004
  80006a:	e8 cc 07 00 00       	call   80083b <strlen>
  80006f:	83 c4 0c             	add    $0xc,%esp
  800072:	83 c0 01             	add    $0x1,%eax
  800075:	50                   	push   %eax
  800076:	ff 35 04 30 80 00    	push   0x803004
  80007c:	68 00 00 a0 00       	push   $0xa00000
  800081:	e8 e8 09 00 00       	call   800a6e <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800086:	6a 07                	push   $0x7
  800088:	68 00 00 a0 00       	push   $0xa00000
  80008d:	6a 00                	push   $0x0
  80008f:	ff 75 f4             	push   -0xc(%ebp)
  800092:	e8 1e 11 00 00       	call   8011b5 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800097:	83 c4 1c             	add    $0x1c,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	68 00 00 a0 00       	push   $0xa00000
  8000a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a4:	50                   	push   %eax
  8000a5:	e8 9b 10 00 00       	call   801145 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000aa:	83 c4 0c             	add    $0xc,%esp
  8000ad:	68 00 00 a0 00       	push   $0xa00000
  8000b2:	ff 75 f4             	push   -0xc(%ebp)
  8000b5:	68 c0 26 80 00       	push   $0x8026c0
  8000ba:	e8 dd 01 00 00       	call   80029c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000bf:	83 c4 04             	add    $0x4,%esp
  8000c2:	ff 35 00 30 80 00    	push   0x803000
  8000c8:	e8 6e 07 00 00       	call   80083b <strlen>
  8000cd:	83 c4 0c             	add    $0xc,%esp
  8000d0:	50                   	push   %eax
  8000d1:	ff 35 00 30 80 00    	push   0x803000
  8000d7:	68 00 00 a0 00       	push   $0xa00000
  8000dc:	e8 6c 08 00 00       	call   80094d <strncmp>
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	85 c0                	test   %eax,%eax
  8000e6:	0f 84 a3 00 00 00    	je     80018f <umain+0x15c>
		cprintf("parent received correct message\n");
	return;
}
  8000ec:	c9                   	leave  
  8000ed:	c3                   	ret    
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  8000ee:	83 ec 04             	sub    $0x4,%esp
  8000f1:	6a 00                	push   $0x0
  8000f3:	68 00 00 b0 00       	push   $0xb00000
  8000f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000fb:	50                   	push   %eax
  8000fc:	e8 44 10 00 00       	call   801145 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800101:	83 c4 0c             	add    $0xc,%esp
  800104:	68 00 00 b0 00       	push   $0xb00000
  800109:	ff 75 f4             	push   -0xc(%ebp)
  80010c:	68 c0 26 80 00       	push   $0x8026c0
  800111:	e8 86 01 00 00       	call   80029c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800116:	83 c4 04             	add    $0x4,%esp
  800119:	ff 35 04 30 80 00    	push   0x803004
  80011f:	e8 17 07 00 00       	call   80083b <strlen>
  800124:	83 c4 0c             	add    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	ff 35 04 30 80 00    	push   0x803004
  80012e:	68 00 00 b0 00       	push   $0xb00000
  800133:	e8 15 08 00 00       	call   80094d <strncmp>
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	85 c0                	test   %eax,%eax
  80013d:	74 3e                	je     80017d <umain+0x14a>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	ff 35 00 30 80 00    	push   0x803000
  800148:	e8 ee 06 00 00       	call   80083b <strlen>
  80014d:	83 c4 0c             	add    $0xc,%esp
  800150:	83 c0 01             	add    $0x1,%eax
  800153:	50                   	push   %eax
  800154:	ff 35 00 30 80 00    	push   0x803000
  80015a:	68 00 00 b0 00       	push   $0xb00000
  80015f:	e8 0a 09 00 00       	call   800a6e <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800164:	6a 07                	push   $0x7
  800166:	68 00 00 b0 00       	push   $0xb00000
  80016b:	6a 00                	push   $0x0
  80016d:	ff 75 f4             	push   -0xc(%ebp)
  800170:	e8 40 10 00 00       	call   8011b5 <ipc_send>
		return;
  800175:	83 c4 20             	add    $0x20,%esp
  800178:	e9 6f ff ff ff       	jmp    8000ec <umain+0xb9>
			cprintf("child received correct message\n");
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	68 d4 26 80 00       	push   $0x8026d4
  800185:	e8 12 01 00 00       	call   80029c <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	eb b0                	jmp    80013f <umain+0x10c>
		cprintf("parent received correct message\n");
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	68 f4 26 80 00       	push   $0x8026f4
  800197:	e8 00 01 00 00       	call   80029c <cprintf>
  80019c:	83 c4 10             	add    $0x10,%esp
  80019f:	e9 48 ff ff ff       	jmp    8000ec <umain+0xb9>

008001a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ac:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8001af:	e8 80 0a 00 00       	call   800c34 <sys_getenvid>
  8001b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b9:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8001bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c4:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c9:	85 db                	test   %ebx,%ebx
  8001cb:	7e 07                	jle    8001d4 <libmain+0x30>
		binaryname = argv[0];
  8001cd:	8b 06                	mov    (%esi),%eax
  8001cf:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	e8 55 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001de:	e8 0a 00 00 00       	call   8001ed <exit>
}
  8001e3:	83 c4 10             	add    $0x10,%esp
  8001e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001f3:	e8 21 12 00 00       	call   801419 <close_all>
	sys_env_destroy(0);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	6a 00                	push   $0x0
  8001fd:	e8 f1 09 00 00       	call   800bf3 <sys_env_destroy>
}
  800202:	83 c4 10             	add    $0x10,%esp
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	53                   	push   %ebx
  80020b:	83 ec 04             	sub    $0x4,%esp
  80020e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800211:	8b 13                	mov    (%ebx),%edx
  800213:	8d 42 01             	lea    0x1(%edx),%eax
  800216:	89 03                	mov    %eax,(%ebx)
  800218:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80021f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800224:	74 09                	je     80022f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800226:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	68 ff 00 00 00       	push   $0xff
  800237:	8d 43 08             	lea    0x8(%ebx),%eax
  80023a:	50                   	push   %eax
  80023b:	e8 76 09 00 00       	call   800bb6 <sys_cputs>
		b->idx = 0;
  800240:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800246:	83 c4 10             	add    $0x10,%esp
  800249:	eb db                	jmp    800226 <putch+0x1f>

0080024b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800254:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025b:	00 00 00 
	b.cnt = 0;
  80025e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800265:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800268:	ff 75 0c             	push   0xc(%ebp)
  80026b:	ff 75 08             	push   0x8(%ebp)
  80026e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800274:	50                   	push   %eax
  800275:	68 07 02 80 00       	push   $0x800207
  80027a:	e8 14 01 00 00       	call   800393 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027f:	83 c4 08             	add    $0x8,%esp
  800282:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800288:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028e:	50                   	push   %eax
  80028f:	e8 22 09 00 00       	call   800bb6 <sys_cputs>

	return b.cnt;
}
  800294:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a5:	50                   	push   %eax
  8002a6:	ff 75 08             	push   0x8(%ebp)
  8002a9:	e8 9d ff ff ff       	call   80024b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 1c             	sub    $0x1c,%esp
  8002b9:	89 c7                	mov    %eax,%edi
  8002bb:	89 d6                	mov    %edx,%esi
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c3:	89 d1                	mov    %edx,%ecx
  8002c5:	89 c2                	mov    %eax,%edx
  8002c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002dd:	39 c2                	cmp    %eax,%edx
  8002df:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002e2:	72 3e                	jb     800322 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e4:	83 ec 0c             	sub    $0xc,%esp
  8002e7:	ff 75 18             	push   0x18(%ebp)
  8002ea:	83 eb 01             	sub    $0x1,%ebx
  8002ed:	53                   	push   %ebx
  8002ee:	50                   	push   %eax
  8002ef:	83 ec 08             	sub    $0x8,%esp
  8002f2:	ff 75 e4             	push   -0x1c(%ebp)
  8002f5:	ff 75 e0             	push   -0x20(%ebp)
  8002f8:	ff 75 dc             	push   -0x24(%ebp)
  8002fb:	ff 75 d8             	push   -0x28(%ebp)
  8002fe:	e8 7d 21 00 00       	call   802480 <__udivdi3>
  800303:	83 c4 18             	add    $0x18,%esp
  800306:	52                   	push   %edx
  800307:	50                   	push   %eax
  800308:	89 f2                	mov    %esi,%edx
  80030a:	89 f8                	mov    %edi,%eax
  80030c:	e8 9f ff ff ff       	call   8002b0 <printnum>
  800311:	83 c4 20             	add    $0x20,%esp
  800314:	eb 13                	jmp    800329 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800316:	83 ec 08             	sub    $0x8,%esp
  800319:	56                   	push   %esi
  80031a:	ff 75 18             	push   0x18(%ebp)
  80031d:	ff d7                	call   *%edi
  80031f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800322:	83 eb 01             	sub    $0x1,%ebx
  800325:	85 db                	test   %ebx,%ebx
  800327:	7f ed                	jg     800316 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800329:	83 ec 08             	sub    $0x8,%esp
  80032c:	56                   	push   %esi
  80032d:	83 ec 04             	sub    $0x4,%esp
  800330:	ff 75 e4             	push   -0x1c(%ebp)
  800333:	ff 75 e0             	push   -0x20(%ebp)
  800336:	ff 75 dc             	push   -0x24(%ebp)
  800339:	ff 75 d8             	push   -0x28(%ebp)
  80033c:	e8 5f 22 00 00       	call   8025a0 <__umoddi3>
  800341:	83 c4 14             	add    $0x14,%esp
  800344:	0f be 80 6c 27 80 00 	movsbl 0x80276c(%eax),%eax
  80034b:	50                   	push   %eax
  80034c:	ff d7                	call   *%edi
}
  80034e:	83 c4 10             	add    $0x10,%esp
  800351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800354:	5b                   	pop    %ebx
  800355:	5e                   	pop    %esi
  800356:	5f                   	pop    %edi
  800357:	5d                   	pop    %ebp
  800358:	c3                   	ret    

00800359 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800363:	8b 10                	mov    (%eax),%edx
  800365:	3b 50 04             	cmp    0x4(%eax),%edx
  800368:	73 0a                	jae    800374 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 45 08             	mov    0x8(%ebp),%eax
  800372:	88 02                	mov    %al,(%edx)
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <printfmt>:
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037f:	50                   	push   %eax
  800380:	ff 75 10             	push   0x10(%ebp)
  800383:	ff 75 0c             	push   0xc(%ebp)
  800386:	ff 75 08             	push   0x8(%ebp)
  800389:	e8 05 00 00 00       	call   800393 <vprintfmt>
}
  80038e:	83 c4 10             	add    $0x10,%esp
  800391:	c9                   	leave  
  800392:	c3                   	ret    

00800393 <vprintfmt>:
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	57                   	push   %edi
  800397:	56                   	push   %esi
  800398:	53                   	push   %ebx
  800399:	83 ec 3c             	sub    $0x3c,%esp
  80039c:	8b 75 08             	mov    0x8(%ebp),%esi
  80039f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a5:	eb 0a                	jmp    8003b1 <vprintfmt+0x1e>
			putch(ch, putdat);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	53                   	push   %ebx
  8003ab:	50                   	push   %eax
  8003ac:	ff d6                	call   *%esi
  8003ae:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b1:	83 c7 01             	add    $0x1,%edi
  8003b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b8:	83 f8 25             	cmp    $0x25,%eax
  8003bb:	74 0c                	je     8003c9 <vprintfmt+0x36>
			if (ch == '\0')
  8003bd:	85 c0                	test   %eax,%eax
  8003bf:	75 e6                	jne    8003a7 <vprintfmt+0x14>
}
  8003c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c4:	5b                   	pop    %ebx
  8003c5:	5e                   	pop    %esi
  8003c6:	5f                   	pop    %edi
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    
		padc = ' ';
  8003c9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003cd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003d4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8d 47 01             	lea    0x1(%edi),%eax
  8003ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ed:	0f b6 17             	movzbl (%edi),%edx
  8003f0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f3:	3c 55                	cmp    $0x55,%al
  8003f5:	0f 87 bb 03 00 00    	ja     8007b6 <vprintfmt+0x423>
  8003fb:	0f b6 c0             	movzbl %al,%eax
  8003fe:	ff 24 85 a0 28 80 00 	jmp    *0x8028a0(,%eax,4)
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800408:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80040c:	eb d9                	jmp    8003e7 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800411:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800415:	eb d0                	jmp    8003e7 <vprintfmt+0x54>
  800417:	0f b6 d2             	movzbl %dl,%edx
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
  800422:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800425:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800428:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80042f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800432:	83 f9 09             	cmp    $0x9,%ecx
  800435:	77 55                	ja     80048c <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800437:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80043a:	eb e9                	jmp    800425 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 40 04             	lea    0x4(%eax),%eax
  80044a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800450:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800454:	79 91                	jns    8003e7 <vprintfmt+0x54>
				width = precision, precision = -1;
  800456:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800459:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800463:	eb 82                	jmp    8003e7 <vprintfmt+0x54>
  800465:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800468:	85 d2                	test   %edx,%edx
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	0f 49 c2             	cmovns %edx,%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800478:	e9 6a ff ff ff       	jmp    8003e7 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800480:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800487:	e9 5b ff ff ff       	jmp    8003e7 <vprintfmt+0x54>
  80048c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80048f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800492:	eb bc                	jmp    800450 <vprintfmt+0xbd>
			lflag++;
  800494:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80049a:	e9 48 ff ff ff       	jmp    8003e7 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8d 78 04             	lea    0x4(%eax),%edi
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	53                   	push   %ebx
  8004a9:	ff 30                	push   (%eax)
  8004ab:	ff d6                	call   *%esi
			break;
  8004ad:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004b3:	e9 9d 02 00 00       	jmp    800755 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 78 04             	lea    0x4(%eax),%edi
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	89 d0                	mov    %edx,%eax
  8004c2:	f7 d8                	neg    %eax
  8004c4:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c7:	83 f8 0f             	cmp    $0xf,%eax
  8004ca:	7f 23                	jg     8004ef <vprintfmt+0x15c>
  8004cc:	8b 14 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%edx
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	74 18                	je     8004ef <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004d7:	52                   	push   %edx
  8004d8:	68 21 2c 80 00       	push   $0x802c21
  8004dd:	53                   	push   %ebx
  8004de:	56                   	push   %esi
  8004df:	e8 92 fe ff ff       	call   800376 <printfmt>
  8004e4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004ea:	e9 66 02 00 00       	jmp    800755 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004ef:	50                   	push   %eax
  8004f0:	68 84 27 80 00       	push   $0x802784
  8004f5:	53                   	push   %ebx
  8004f6:	56                   	push   %esi
  8004f7:	e8 7a fe ff ff       	call   800376 <printfmt>
  8004fc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ff:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800502:	e9 4e 02 00 00       	jmp    800755 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	83 c0 04             	add    $0x4,%eax
  80050d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800515:	85 d2                	test   %edx,%edx
  800517:	b8 7d 27 80 00       	mov    $0x80277d,%eax
  80051c:	0f 45 c2             	cmovne %edx,%eax
  80051f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800522:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800526:	7e 06                	jle    80052e <vprintfmt+0x19b>
  800528:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80052c:	75 0d                	jne    80053b <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800531:	89 c7                	mov    %eax,%edi
  800533:	03 45 e0             	add    -0x20(%ebp),%eax
  800536:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800539:	eb 55                	jmp    800590 <vprintfmt+0x1fd>
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 d8             	push   -0x28(%ebp)
  800541:	ff 75 cc             	push   -0x34(%ebp)
  800544:	e8 0a 03 00 00       	call   800853 <strnlen>
  800549:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054c:	29 c1                	sub    %eax,%ecx
  80054e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800556:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80055a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80055d:	eb 0f                	jmp    80056e <vprintfmt+0x1db>
					putch(padc, putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	53                   	push   %ebx
  800563:	ff 75 e0             	push   -0x20(%ebp)
  800566:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800568:	83 ef 01             	sub    $0x1,%edi
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	85 ff                	test   %edi,%edi
  800570:	7f ed                	jg     80055f <vprintfmt+0x1cc>
  800572:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800575:	85 d2                	test   %edx,%edx
  800577:	b8 00 00 00 00       	mov    $0x0,%eax
  80057c:	0f 49 c2             	cmovns %edx,%eax
  80057f:	29 c2                	sub    %eax,%edx
  800581:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800584:	eb a8                	jmp    80052e <vprintfmt+0x19b>
					putch(ch, putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	53                   	push   %ebx
  80058a:	52                   	push   %edx
  80058b:	ff d6                	call   *%esi
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800593:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800595:	83 c7 01             	add    $0x1,%edi
  800598:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059c:	0f be d0             	movsbl %al,%edx
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	74 4b                	je     8005ee <vprintfmt+0x25b>
  8005a3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a7:	78 06                	js     8005af <vprintfmt+0x21c>
  8005a9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005ad:	78 1e                	js     8005cd <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8005af:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b3:	74 d1                	je     800586 <vprintfmt+0x1f3>
  8005b5:	0f be c0             	movsbl %al,%eax
  8005b8:	83 e8 20             	sub    $0x20,%eax
  8005bb:	83 f8 5e             	cmp    $0x5e,%eax
  8005be:	76 c6                	jbe    800586 <vprintfmt+0x1f3>
					putch('?', putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	53                   	push   %ebx
  8005c4:	6a 3f                	push   $0x3f
  8005c6:	ff d6                	call   *%esi
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb c3                	jmp    800590 <vprintfmt+0x1fd>
  8005cd:	89 cf                	mov    %ecx,%edi
  8005cf:	eb 0e                	jmp    8005df <vprintfmt+0x24c>
				putch(' ', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 20                	push   $0x20
  8005d7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005d9:	83 ef 01             	sub    $0x1,%edi
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	85 ff                	test   %edi,%edi
  8005e1:	7f ee                	jg     8005d1 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005e3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e9:	e9 67 01 00 00       	jmp    800755 <vprintfmt+0x3c2>
  8005ee:	89 cf                	mov    %ecx,%edi
  8005f0:	eb ed                	jmp    8005df <vprintfmt+0x24c>
	if (lflag >= 2)
  8005f2:	83 f9 01             	cmp    $0x1,%ecx
  8005f5:	7f 1b                	jg     800612 <vprintfmt+0x27f>
	else if (lflag)
  8005f7:	85 c9                	test   %ecx,%ecx
  8005f9:	74 63                	je     80065e <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	99                   	cltd   
  800604:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 40 04             	lea    0x4(%eax),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
  800610:	eb 17                	jmp    800629 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 50 04             	mov    0x4(%eax),%edx
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 40 08             	lea    0x8(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800629:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80062f:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800634:	85 c9                	test   %ecx,%ecx
  800636:	0f 89 ff 00 00 00    	jns    80073b <vprintfmt+0x3a8>
				putch('-', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 2d                	push   $0x2d
  800642:	ff d6                	call   *%esi
				num = -(long long) num;
  800644:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800647:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80064a:	f7 da                	neg    %edx
  80064c:	83 d1 00             	adc    $0x0,%ecx
  80064f:	f7 d9                	neg    %ecx
  800651:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800654:	bf 0a 00 00 00       	mov    $0xa,%edi
  800659:	e9 dd 00 00 00       	jmp    80073b <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 00                	mov    (%eax),%eax
  800663:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800666:	99                   	cltd   
  800667:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
  800673:	eb b4                	jmp    800629 <vprintfmt+0x296>
	if (lflag >= 2)
  800675:	83 f9 01             	cmp    $0x1,%ecx
  800678:	7f 1e                	jg     800698 <vprintfmt+0x305>
	else if (lflag)
  80067a:	85 c9                	test   %ecx,%ecx
  80067c:	74 32                	je     8006b0 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 10                	mov    (%eax),%edx
  800683:	b9 00 00 00 00       	mov    $0x0,%ecx
  800688:	8d 40 04             	lea    0x4(%eax),%eax
  80068b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800693:	e9 a3 00 00 00       	jmp    80073b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a0:	8d 40 08             	lea    0x8(%eax),%eax
  8006a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8006ab:	e9 8b 00 00 00       	jmp    80073b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ba:	8d 40 04             	lea    0x4(%eax),%eax
  8006bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8006c5:	eb 74                	jmp    80073b <vprintfmt+0x3a8>
	if (lflag >= 2)
  8006c7:	83 f9 01             	cmp    $0x1,%ecx
  8006ca:	7f 1b                	jg     8006e7 <vprintfmt+0x354>
	else if (lflag)
  8006cc:	85 c9                	test   %ecx,%ecx
  8006ce:	74 2c                	je     8006fc <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006e0:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8006e5:	eb 54                	jmp    80073b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ef:	8d 40 08             	lea    0x8(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006f5:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8006fa:	eb 3f                	jmp    80073b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	b9 00 00 00 00       	mov    $0x0,%ecx
  800706:	8d 40 04             	lea    0x4(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80070c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800711:	eb 28                	jmp    80073b <vprintfmt+0x3a8>
			putch('0', putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	6a 30                	push   $0x30
  800719:	ff d6                	call   *%esi
			putch('x', putdat);
  80071b:	83 c4 08             	add    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	6a 78                	push   $0x78
  800721:	ff d6                	call   *%esi
			num = (unsigned long long)
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	8b 10                	mov    (%eax),%edx
  800728:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80072d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800730:	8d 40 04             	lea    0x4(%eax),%eax
  800733:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800736:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80073b:	83 ec 0c             	sub    $0xc,%esp
  80073e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800742:	50                   	push   %eax
  800743:	ff 75 e0             	push   -0x20(%ebp)
  800746:	57                   	push   %edi
  800747:	51                   	push   %ecx
  800748:	52                   	push   %edx
  800749:	89 da                	mov    %ebx,%edx
  80074b:	89 f0                	mov    %esi,%eax
  80074d:	e8 5e fb ff ff       	call   8002b0 <printnum>
			break;
  800752:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800758:	e9 54 fc ff ff       	jmp    8003b1 <vprintfmt+0x1e>
	if (lflag >= 2)
  80075d:	83 f9 01             	cmp    $0x1,%ecx
  800760:	7f 1b                	jg     80077d <vprintfmt+0x3ea>
	else if (lflag)
  800762:	85 c9                	test   %ecx,%ecx
  800764:	74 2c                	je     800792 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 10                	mov    (%eax),%edx
  80076b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800770:	8d 40 04             	lea    0x4(%eax),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800776:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80077b:	eb be                	jmp    80073b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80077d:	8b 45 14             	mov    0x14(%ebp),%eax
  800780:	8b 10                	mov    (%eax),%edx
  800782:	8b 48 04             	mov    0x4(%eax),%ecx
  800785:	8d 40 08             	lea    0x8(%eax),%eax
  800788:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80078b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800790:	eb a9                	jmp    80073b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8b 10                	mov    (%eax),%edx
  800797:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079c:	8d 40 04             	lea    0x4(%eax),%eax
  80079f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8007a7:	eb 92                	jmp    80073b <vprintfmt+0x3a8>
			putch(ch, putdat);
  8007a9:	83 ec 08             	sub    $0x8,%esp
  8007ac:	53                   	push   %ebx
  8007ad:	6a 25                	push   $0x25
  8007af:	ff d6                	call   *%esi
			break;
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	eb 9f                	jmp    800755 <vprintfmt+0x3c2>
			putch('%', putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	53                   	push   %ebx
  8007ba:	6a 25                	push   $0x25
  8007bc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	89 f8                	mov    %edi,%eax
  8007c3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007c7:	74 05                	je     8007ce <vprintfmt+0x43b>
  8007c9:	83 e8 01             	sub    $0x1,%eax
  8007cc:	eb f5                	jmp    8007c3 <vprintfmt+0x430>
  8007ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d1:	eb 82                	jmp    800755 <vprintfmt+0x3c2>

008007d3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 18             	sub    $0x18,%esp
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	74 26                	je     80081a <vsnprintf+0x47>
  8007f4:	85 d2                	test   %edx,%edx
  8007f6:	7e 22                	jle    80081a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f8:	ff 75 14             	push   0x14(%ebp)
  8007fb:	ff 75 10             	push   0x10(%ebp)
  8007fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800801:	50                   	push   %eax
  800802:	68 59 03 80 00       	push   $0x800359
  800807:	e8 87 fb ff ff       	call   800393 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80080f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800812:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800815:	83 c4 10             	add    $0x10,%esp
}
  800818:	c9                   	leave  
  800819:	c3                   	ret    
		return -E_INVAL;
  80081a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081f:	eb f7                	jmp    800818 <vsnprintf+0x45>

00800821 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800827:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082a:	50                   	push   %eax
  80082b:	ff 75 10             	push   0x10(%ebp)
  80082e:	ff 75 0c             	push   0xc(%ebp)
  800831:	ff 75 08             	push   0x8(%ebp)
  800834:	e8 9a ff ff ff       	call   8007d3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
  800846:	eb 03                	jmp    80084b <strlen+0x10>
		n++;
  800848:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80084b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80084f:	75 f7                	jne    800848 <strlen+0xd>
	return n;
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
  800861:	eb 03                	jmp    800866 <strnlen+0x13>
		n++;
  800863:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800866:	39 d0                	cmp    %edx,%eax
  800868:	74 08                	je     800872 <strnlen+0x1f>
  80086a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086e:	75 f3                	jne    800863 <strnlen+0x10>
  800870:	89 c2                	mov    %eax,%edx
	return n;
}
  800872:	89 d0                	mov    %edx,%eax
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
  800885:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800889:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	84 d2                	test   %dl,%dl
  800891:	75 f2                	jne    800885 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800893:	89 c8                	mov    %ecx,%eax
  800895:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	83 ec 10             	sub    $0x10,%esp
  8008a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a4:	53                   	push   %ebx
  8008a5:	e8 91 ff ff ff       	call   80083b <strlen>
  8008aa:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ad:	ff 75 0c             	push   0xc(%ebp)
  8008b0:	01 d8                	add    %ebx,%eax
  8008b2:	50                   	push   %eax
  8008b3:	e8 be ff ff ff       	call   800876 <strcpy>
	return dst;
}
  8008b8:	89 d8                	mov    %ebx,%eax
  8008ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	89 f3                	mov    %esi,%ebx
  8008cc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cf:	89 f0                	mov    %esi,%eax
  8008d1:	eb 0f                	jmp    8008e2 <strncpy+0x23>
		*dst++ = *src;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	0f b6 0a             	movzbl (%edx),%ecx
  8008d9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008dc:	80 f9 01             	cmp    $0x1,%cl
  8008df:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008e2:	39 d8                	cmp    %ebx,%eax
  8008e4:	75 ed                	jne    8008d3 <strncpy+0x14>
	}
	return ret;
}
  8008e6:	89 f0                	mov    %esi,%eax
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
  8008f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f7:	8b 55 10             	mov    0x10(%ebp),%edx
  8008fa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008fc:	85 d2                	test   %edx,%edx
  8008fe:	74 21                	je     800921 <strlcpy+0x35>
  800900:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800904:	89 f2                	mov    %esi,%edx
  800906:	eb 09                	jmp    800911 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800908:	83 c1 01             	add    $0x1,%ecx
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800911:	39 c2                	cmp    %eax,%edx
  800913:	74 09                	je     80091e <strlcpy+0x32>
  800915:	0f b6 19             	movzbl (%ecx),%ebx
  800918:	84 db                	test   %bl,%bl
  80091a:	75 ec                	jne    800908 <strlcpy+0x1c>
  80091c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80091e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800921:	29 f0                	sub    %esi,%eax
}
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800930:	eb 06                	jmp    800938 <strcmp+0x11>
		p++, q++;
  800932:	83 c1 01             	add    $0x1,%ecx
  800935:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800938:	0f b6 01             	movzbl (%ecx),%eax
  80093b:	84 c0                	test   %al,%al
  80093d:	74 04                	je     800943 <strcmp+0x1c>
  80093f:	3a 02                	cmp    (%edx),%al
  800941:	74 ef                	je     800932 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800943:	0f b6 c0             	movzbl %al,%eax
  800946:	0f b6 12             	movzbl (%edx),%edx
  800949:	29 d0                	sub    %edx,%eax
}
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	53                   	push   %ebx
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
  800957:	89 c3                	mov    %eax,%ebx
  800959:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80095c:	eb 06                	jmp    800964 <strncmp+0x17>
		n--, p++, q++;
  80095e:	83 c0 01             	add    $0x1,%eax
  800961:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800964:	39 d8                	cmp    %ebx,%eax
  800966:	74 18                	je     800980 <strncmp+0x33>
  800968:	0f b6 08             	movzbl (%eax),%ecx
  80096b:	84 c9                	test   %cl,%cl
  80096d:	74 04                	je     800973 <strncmp+0x26>
  80096f:	3a 0a                	cmp    (%edx),%cl
  800971:	74 eb                	je     80095e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800973:	0f b6 00             	movzbl (%eax),%eax
  800976:	0f b6 12             	movzbl (%edx),%edx
  800979:	29 d0                	sub    %edx,%eax
}
  80097b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    
		return 0;
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
  800985:	eb f4                	jmp    80097b <strncmp+0x2e>

00800987 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800991:	eb 03                	jmp    800996 <strchr+0xf>
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	0f b6 10             	movzbl (%eax),%edx
  800999:	84 d2                	test   %dl,%dl
  80099b:	74 06                	je     8009a3 <strchr+0x1c>
		if (*s == c)
  80099d:	38 ca                	cmp    %cl,%dl
  80099f:	75 f2                	jne    800993 <strchr+0xc>
  8009a1:	eb 05                	jmp    8009a8 <strchr+0x21>
			return (char *) s;
	return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b7:	38 ca                	cmp    %cl,%dl
  8009b9:	74 09                	je     8009c4 <strfind+0x1a>
  8009bb:	84 d2                	test   %dl,%dl
  8009bd:	74 05                	je     8009c4 <strfind+0x1a>
	for (; *s; s++)
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	eb f0                	jmp    8009b4 <strfind+0xa>
			break;
	return (char *) s;
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d2:	85 c9                	test   %ecx,%ecx
  8009d4:	74 2f                	je     800a05 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d6:	89 f8                	mov    %edi,%eax
  8009d8:	09 c8                	or     %ecx,%eax
  8009da:	a8 03                	test   $0x3,%al
  8009dc:	75 21                	jne    8009ff <memset+0x39>
		c &= 0xFF;
  8009de:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e2:	89 d0                	mov    %edx,%eax
  8009e4:	c1 e0 08             	shl    $0x8,%eax
  8009e7:	89 d3                	mov    %edx,%ebx
  8009e9:	c1 e3 18             	shl    $0x18,%ebx
  8009ec:	89 d6                	mov    %edx,%esi
  8009ee:	c1 e6 10             	shl    $0x10,%esi
  8009f1:	09 f3                	or     %esi,%ebx
  8009f3:	09 da                	or     %ebx,%edx
  8009f5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009fa:	fc                   	cld    
  8009fb:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fd:	eb 06                	jmp    800a05 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	fc                   	cld    
  800a03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a05:	89 f8                	mov    %edi,%eax
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a1a:	39 c6                	cmp    %eax,%esi
  800a1c:	73 32                	jae    800a50 <memmove+0x44>
  800a1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a21:	39 c2                	cmp    %eax,%edx
  800a23:	76 2b                	jbe    800a50 <memmove+0x44>
		s += n;
		d += n;
  800a25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a28:	89 d6                	mov    %edx,%esi
  800a2a:	09 fe                	or     %edi,%esi
  800a2c:	09 ce                	or     %ecx,%esi
  800a2e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a34:	75 0e                	jne    800a44 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a36:	83 ef 04             	sub    $0x4,%edi
  800a39:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a3f:	fd                   	std    
  800a40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a42:	eb 09                	jmp    800a4d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a44:	83 ef 01             	sub    $0x1,%edi
  800a47:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a4a:	fd                   	std    
  800a4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4d:	fc                   	cld    
  800a4e:	eb 1a                	jmp    800a6a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	89 f2                	mov    %esi,%edx
  800a52:	09 c2                	or     %eax,%edx
  800a54:	09 ca                	or     %ecx,%edx
  800a56:	f6 c2 03             	test   $0x3,%dl
  800a59:	75 0a                	jne    800a65 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a5e:	89 c7                	mov    %eax,%edi
  800a60:	fc                   	cld    
  800a61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a63:	eb 05                	jmp    800a6a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a65:	89 c7                	mov    %eax,%edi
  800a67:	fc                   	cld    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6a:	5e                   	pop    %esi
  800a6b:	5f                   	pop    %edi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a74:	ff 75 10             	push   0x10(%ebp)
  800a77:	ff 75 0c             	push   0xc(%ebp)
  800a7a:	ff 75 08             	push   0x8(%ebp)
  800a7d:	e8 8a ff ff ff       	call   800a0c <memmove>
}
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	89 c6                	mov    %eax,%esi
  800a91:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a94:	eb 06                	jmp    800a9c <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a9c:	39 f0                	cmp    %esi,%eax
  800a9e:	74 14                	je     800ab4 <memcmp+0x30>
		if (*s1 != *s2)
  800aa0:	0f b6 08             	movzbl (%eax),%ecx
  800aa3:	0f b6 1a             	movzbl (%edx),%ebx
  800aa6:	38 d9                	cmp    %bl,%cl
  800aa8:	74 ec                	je     800a96 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800aaa:	0f b6 c1             	movzbl %cl,%eax
  800aad:	0f b6 db             	movzbl %bl,%ebx
  800ab0:	29 d8                	sub    %ebx,%eax
  800ab2:	eb 05                	jmp    800ab9 <memcmp+0x35>
	}

	return 0;
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac6:	89 c2                	mov    %eax,%edx
  800ac8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800acb:	eb 03                	jmp    800ad0 <memfind+0x13>
  800acd:	83 c0 01             	add    $0x1,%eax
  800ad0:	39 d0                	cmp    %edx,%eax
  800ad2:	73 04                	jae    800ad8 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad4:	38 08                	cmp    %cl,(%eax)
  800ad6:	75 f5                	jne    800acd <memfind+0x10>
			break;
	return (void *) s;
}
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
  800ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae6:	eb 03                	jmp    800aeb <strtol+0x11>
		s++;
  800ae8:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800aeb:	0f b6 02             	movzbl (%edx),%eax
  800aee:	3c 20                	cmp    $0x20,%al
  800af0:	74 f6                	je     800ae8 <strtol+0xe>
  800af2:	3c 09                	cmp    $0x9,%al
  800af4:	74 f2                	je     800ae8 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800af6:	3c 2b                	cmp    $0x2b,%al
  800af8:	74 2a                	je     800b24 <strtol+0x4a>
	int neg = 0;
  800afa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aff:	3c 2d                	cmp    $0x2d,%al
  800b01:	74 2b                	je     800b2e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b03:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b09:	75 0f                	jne    800b1a <strtol+0x40>
  800b0b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b0e:	74 28                	je     800b38 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b10:	85 db                	test   %ebx,%ebx
  800b12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b17:	0f 44 d8             	cmove  %eax,%ebx
  800b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b22:	eb 46                	jmp    800b6a <strtol+0x90>
		s++;
  800b24:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2c:	eb d5                	jmp    800b03 <strtol+0x29>
		s++, neg = 1;
  800b2e:	83 c2 01             	add    $0x1,%edx
  800b31:	bf 01 00 00 00       	mov    $0x1,%edi
  800b36:	eb cb                	jmp    800b03 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b3c:	74 0e                	je     800b4c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b3e:	85 db                	test   %ebx,%ebx
  800b40:	75 d8                	jne    800b1a <strtol+0x40>
		s++, base = 8;
  800b42:	83 c2 01             	add    $0x1,%edx
  800b45:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b4a:	eb ce                	jmp    800b1a <strtol+0x40>
		s += 2, base = 16;
  800b4c:	83 c2 02             	add    $0x2,%edx
  800b4f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b54:	eb c4                	jmp    800b1a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b56:	0f be c0             	movsbl %al,%eax
  800b59:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b5c:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b5f:	7d 3a                	jge    800b9b <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b61:	83 c2 01             	add    $0x1,%edx
  800b64:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b68:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b6a:	0f b6 02             	movzbl (%edx),%eax
  800b6d:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b70:	89 f3                	mov    %esi,%ebx
  800b72:	80 fb 09             	cmp    $0x9,%bl
  800b75:	76 df                	jbe    800b56 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b77:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b7a:	89 f3                	mov    %esi,%ebx
  800b7c:	80 fb 19             	cmp    $0x19,%bl
  800b7f:	77 08                	ja     800b89 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b81:	0f be c0             	movsbl %al,%eax
  800b84:	83 e8 57             	sub    $0x57,%eax
  800b87:	eb d3                	jmp    800b5c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b89:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b8c:	89 f3                	mov    %esi,%ebx
  800b8e:	80 fb 19             	cmp    $0x19,%bl
  800b91:	77 08                	ja     800b9b <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b93:	0f be c0             	movsbl %al,%eax
  800b96:	83 e8 37             	sub    $0x37,%eax
  800b99:	eb c1                	jmp    800b5c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9f:	74 05                	je     800ba6 <strtol+0xcc>
		*endptr = (char *) s;
  800ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ba6:	89 c8                	mov    %ecx,%eax
  800ba8:	f7 d8                	neg    %eax
  800baa:	85 ff                	test   %edi,%edi
  800bac:	0f 45 c8             	cmovne %eax,%ecx
}
  800baf:	89 c8                	mov    %ecx,%eax
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc7:	89 c3                	mov    %eax,%ebx
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	89 c6                	mov    %eax,%esi
  800bcd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
  800c04:	b8 03 00 00 00       	mov    $0x3,%eax
  800c09:	89 cb                	mov    %ecx,%ebx
  800c0b:	89 cf                	mov    %ecx,%edi
  800c0d:	89 ce                	mov    %ecx,%esi
  800c0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7f 08                	jg     800c1d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	50                   	push   %eax
  800c21:	6a 03                	push   $0x3
  800c23:	68 5f 2a 80 00       	push   $0x802a5f
  800c28:	6a 2a                	push   $0x2a
  800c2a:	68 7c 2a 80 00       	push   $0x802a7c
  800c2f:	e8 22 17 00 00       	call   802356 <_panic>

00800c34 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c44:	89 d1                	mov    %edx,%ecx
  800c46:	89 d3                	mov    %edx,%ebx
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_yield>:

void
sys_yield(void)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c59:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c63:	89 d1                	mov    %edx,%ecx
  800c65:	89 d3                	mov    %edx,%ebx
  800c67:	89 d7                	mov    %edx,%edi
  800c69:	89 d6                	mov    %edx,%esi
  800c6b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7b:	be 00 00 00 00       	mov    $0x0,%esi
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8e:	89 f7                	mov    %esi,%edi
  800c90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c92:	85 c0                	test   %eax,%eax
  800c94:	7f 08                	jg     800c9e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 04                	push   $0x4
  800ca4:	68 5f 2a 80 00       	push   $0x802a5f
  800ca9:	6a 2a                	push   $0x2a
  800cab:	68 7c 2a 80 00       	push   $0x802a7c
  800cb0:	e8 a1 16 00 00       	call   802356 <_panic>

00800cb5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccf:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7f 08                	jg     800ce0 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	50                   	push   %eax
  800ce4:	6a 05                	push   $0x5
  800ce6:	68 5f 2a 80 00       	push   $0x802a5f
  800ceb:	6a 2a                	push   $0x2a
  800ced:	68 7c 2a 80 00       	push   $0x802a7c
  800cf2:	e8 5f 16 00 00       	call   802356 <_panic>

00800cf7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d10:	89 df                	mov    %ebx,%edi
  800d12:	89 de                	mov    %ebx,%esi
  800d14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7f 08                	jg     800d22 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	6a 06                	push   $0x6
  800d28:	68 5f 2a 80 00       	push   $0x802a5f
  800d2d:	6a 2a                	push   $0x2a
  800d2f:	68 7c 2a 80 00       	push   $0x802a7c
  800d34:	e8 1d 16 00 00       	call   802356 <_panic>

00800d39 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d52:	89 df                	mov    %ebx,%edi
  800d54:	89 de                	mov    %ebx,%esi
  800d56:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7f 08                	jg     800d64 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	50                   	push   %eax
  800d68:	6a 08                	push   $0x8
  800d6a:	68 5f 2a 80 00       	push   $0x802a5f
  800d6f:	6a 2a                	push   $0x2a
  800d71:	68 7c 2a 80 00       	push   $0x802a7c
  800d76:	e8 db 15 00 00       	call   802356 <_panic>

00800d7b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d94:	89 df                	mov    %ebx,%edi
  800d96:	89 de                	mov    %ebx,%esi
  800d98:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7f 08                	jg     800da6 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	50                   	push   %eax
  800daa:	6a 09                	push   $0x9
  800dac:	68 5f 2a 80 00       	push   $0x802a5f
  800db1:	6a 2a                	push   $0x2a
  800db3:	68 7c 2a 80 00       	push   $0x802a7c
  800db8:	e8 99 15 00 00       	call   802356 <_panic>

00800dbd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	7f 08                	jg     800de8 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	50                   	push   %eax
  800dec:	6a 0a                	push   $0xa
  800dee:	68 5f 2a 80 00       	push   $0x802a5f
  800df3:	6a 2a                	push   $0x2a
  800df5:	68 7c 2a 80 00       	push   $0x802a7c
  800dfa:	e8 57 15 00 00       	call   802356 <_panic>

00800dff <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e10:	be 00 00 00 00       	mov    $0x0,%esi
  800e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e30:	8b 55 08             	mov    0x8(%ebp),%edx
  800e33:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e38:	89 cb                	mov    %ecx,%ebx
  800e3a:	89 cf                	mov    %ecx,%edi
  800e3c:	89 ce                	mov    %ecx,%esi
  800e3e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7f 08                	jg     800e4c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4c:	83 ec 0c             	sub    $0xc,%esp
  800e4f:	50                   	push   %eax
  800e50:	6a 0d                	push   $0xd
  800e52:	68 5f 2a 80 00       	push   $0x802a5f
  800e57:	6a 2a                	push   $0x2a
  800e59:	68 7c 2a 80 00       	push   $0x802a7c
  800e5e:	e8 f3 14 00 00       	call   802356 <_panic>

00800e63 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e69:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	89 d3                	mov    %edx,%ebx
  800e77:	89 d7                	mov    %edx,%edi
  800e79:	89 d6                	mov    %edx,%esi
  800e7b:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e93:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e98:	89 df                	mov    %ebx,%edi
  800e9a:	89 de                	mov    %ebx,%esi
  800e9c:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb4:	b8 10 00 00 00       	mov    $0x10,%eax
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	89 de                	mov    %ebx,%esi
  800ebd:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ecc:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ece:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ed2:	0f 84 8e 00 00 00    	je     800f66 <pgfault+0xa2>
  800ed8:	89 f0                	mov    %esi,%eax
  800eda:	c1 e8 0c             	shr    $0xc,%eax
  800edd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee4:	f6 c4 08             	test   $0x8,%ah
  800ee7:	74 7d                	je     800f66 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800ee9:	e8 46 fd ff ff       	call   800c34 <sys_getenvid>
  800eee:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800ef0:	83 ec 04             	sub    $0x4,%esp
  800ef3:	6a 07                	push   $0x7
  800ef5:	68 00 f0 7f 00       	push   $0x7ff000
  800efa:	50                   	push   %eax
  800efb:	e8 72 fd ff ff       	call   800c72 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	78 73                	js     800f7a <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f07:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	68 00 10 00 00       	push   $0x1000
  800f15:	56                   	push   %esi
  800f16:	68 00 f0 7f 00       	push   $0x7ff000
  800f1b:	e8 ec fa ff ff       	call   800a0c <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f20:	83 c4 08             	add    $0x8,%esp
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	e8 cd fd ff ff       	call   800cf7 <sys_page_unmap>
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 5b                	js     800f8c <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f31:	83 ec 0c             	sub    $0xc,%esp
  800f34:	6a 07                	push   $0x7
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	68 00 f0 7f 00       	push   $0x7ff000
  800f3d:	53                   	push   %ebx
  800f3e:	e8 72 fd ff ff       	call   800cb5 <sys_page_map>
  800f43:	83 c4 20             	add    $0x20,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 54                	js     800f9e <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f4a:	83 ec 08             	sub    $0x8,%esp
  800f4d:	68 00 f0 7f 00       	push   $0x7ff000
  800f52:	53                   	push   %ebx
  800f53:	e8 9f fd ff ff       	call   800cf7 <sys_page_unmap>
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	78 51                	js     800fb0 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800f5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f62:	5b                   	pop    %ebx
  800f63:	5e                   	pop    %esi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	68 8c 2a 80 00       	push   $0x802a8c
  800f6e:	6a 1d                	push   $0x1d
  800f70:	68 08 2b 80 00       	push   $0x802b08
  800f75:	e8 dc 13 00 00       	call   802356 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f7a:	50                   	push   %eax
  800f7b:	68 c4 2a 80 00       	push   $0x802ac4
  800f80:	6a 29                	push   $0x29
  800f82:	68 08 2b 80 00       	push   $0x802b08
  800f87:	e8 ca 13 00 00       	call   802356 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f8c:	50                   	push   %eax
  800f8d:	68 e8 2a 80 00       	push   $0x802ae8
  800f92:	6a 2e                	push   $0x2e
  800f94:	68 08 2b 80 00       	push   $0x802b08
  800f99:	e8 b8 13 00 00       	call   802356 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800f9e:	50                   	push   %eax
  800f9f:	68 13 2b 80 00       	push   $0x802b13
  800fa4:	6a 30                	push   $0x30
  800fa6:	68 08 2b 80 00       	push   $0x802b08
  800fab:	e8 a6 13 00 00       	call   802356 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800fb0:	50                   	push   %eax
  800fb1:	68 e8 2a 80 00       	push   $0x802ae8
  800fb6:	6a 32                	push   $0x32
  800fb8:	68 08 2b 80 00       	push   $0x802b08
  800fbd:	e8 94 13 00 00       	call   802356 <_panic>

00800fc2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	57                   	push   %edi
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800fcb:	68 c4 0e 80 00       	push   $0x800ec4
  800fd0:	e8 c7 13 00 00       	call   80239c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd5:	b8 07 00 00 00       	mov    $0x7,%eax
  800fda:	cd 30                	int    $0x30
  800fdc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 30                	js     801016 <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fe6:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800feb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fef:	75 76                	jne    801067 <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff1:	e8 3e fc ff ff       	call   800c34 <sys_getenvid>
  800ff6:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ffb:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801001:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801006:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  80100b:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  80100e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801016:	50                   	push   %eax
  801017:	68 31 2b 80 00       	push   $0x802b31
  80101c:	6a 78                	push   $0x78
  80101e:	68 08 2b 80 00       	push   $0x802b08
  801023:	e8 2e 13 00 00       	call   802356 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801028:	83 ec 0c             	sub    $0xc,%esp
  80102b:	ff 75 e4             	push   -0x1c(%ebp)
  80102e:	57                   	push   %edi
  80102f:	ff 75 dc             	push   -0x24(%ebp)
  801032:	57                   	push   %edi
  801033:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801036:	56                   	push   %esi
  801037:	e8 79 fc ff ff       	call   800cb5 <sys_page_map>
	if(r<0) return r;
  80103c:	83 c4 20             	add    $0x20,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 cb                	js     80100e <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	ff 75 e4             	push   -0x1c(%ebp)
  801049:	57                   	push   %edi
  80104a:	56                   	push   %esi
  80104b:	57                   	push   %edi
  80104c:	56                   	push   %esi
  80104d:	e8 63 fc ff ff       	call   800cb5 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801052:	83 c4 20             	add    $0x20,%esp
  801055:	85 c0                	test   %eax,%eax
  801057:	78 76                	js     8010cf <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801059:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80105f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801065:	74 75                	je     8010dc <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801067:	89 d8                	mov    %ebx,%eax
  801069:	c1 e8 16             	shr    $0x16,%eax
  80106c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801073:	a8 01                	test   $0x1,%al
  801075:	74 e2                	je     801059 <fork+0x97>
  801077:	89 de                	mov    %ebx,%esi
  801079:	c1 ee 0c             	shr    $0xc,%esi
  80107c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801083:	a8 01                	test   $0x1,%al
  801085:	74 d2                	je     801059 <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  801087:	e8 a8 fb ff ff       	call   800c34 <sys_getenvid>
  80108c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  80108f:	89 f7                	mov    %esi,%edi
  801091:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801094:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109b:	89 c1                	mov    %eax,%ecx
  80109d:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8010a3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8010a6:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8010ad:	f6 c6 04             	test   $0x4,%dh
  8010b0:	0f 85 72 ff ff ff    	jne    801028 <fork+0x66>
		perm &= ~PTE_W;
  8010b6:	25 05 0e 00 00       	and    $0xe05,%eax
  8010bb:	80 cc 08             	or     $0x8,%ah
  8010be:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8010c4:	0f 44 c1             	cmove  %ecx,%eax
  8010c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010ca:	e9 59 ff ff ff       	jmp    801028 <fork+0x66>
  8010cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d4:	0f 4f c2             	cmovg  %edx,%eax
  8010d7:	e9 32 ff ff ff       	jmp    80100e <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  8010dc:	83 ec 04             	sub    $0x4,%esp
  8010df:	6a 07                	push   $0x7
  8010e1:	68 00 f0 bf ee       	push   $0xeebff000
  8010e6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010e9:	57                   	push   %edi
  8010ea:	e8 83 fb ff ff       	call   800c72 <sys_page_alloc>
	if(r<0) return r;
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	0f 88 14 ff ff ff    	js     80100e <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010fa:	83 ec 08             	sub    $0x8,%esp
  8010fd:	68 12 24 80 00       	push   $0x802412
  801102:	57                   	push   %edi
  801103:	e8 b5 fc ff ff       	call   800dbd <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	85 c0                	test   %eax,%eax
  80110d:	0f 88 fb fe ff ff    	js     80100e <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801113:	83 ec 08             	sub    $0x8,%esp
  801116:	6a 02                	push   $0x2
  801118:	57                   	push   %edi
  801119:	e8 1b fc ff ff       	call   800d39 <sys_env_set_status>
	if(r<0) return r;
  80111e:	83 c4 10             	add    $0x10,%esp
	return envid;
  801121:	85 c0                	test   %eax,%eax
  801123:	0f 49 c7             	cmovns %edi,%eax
  801126:	e9 e3 fe ff ff       	jmp    80100e <fork+0x4c>

0080112b <sfork>:

// Challenge!
int
sfork(void)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801131:	68 41 2b 80 00       	push   $0x802b41
  801136:	68 a1 00 00 00       	push   $0xa1
  80113b:	68 08 2b 80 00       	push   $0x802b08
  801140:	e8 11 12 00 00       	call   802356 <_panic>

00801145 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	56                   	push   %esi
  801149:	53                   	push   %ebx
  80114a:	8b 75 08             	mov    0x8(%ebp),%esi
  80114d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801150:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801153:	85 c0                	test   %eax,%eax
  801155:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80115a:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	50                   	push   %eax
  801161:	e8 bc fc ff ff       	call   800e22 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	85 f6                	test   %esi,%esi
  80116b:	74 17                	je     801184 <ipc_recv+0x3f>
  80116d:	ba 00 00 00 00       	mov    $0x0,%edx
  801172:	85 c0                	test   %eax,%eax
  801174:	78 0c                	js     801182 <ipc_recv+0x3d>
  801176:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80117c:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801182:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801184:	85 db                	test   %ebx,%ebx
  801186:	74 17                	je     80119f <ipc_recv+0x5a>
  801188:	ba 00 00 00 00       	mov    $0x0,%edx
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 0c                	js     80119d <ipc_recv+0x58>
  801191:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801197:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80119d:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 0b                	js     8011ae <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8011a3:	a1 00 40 80 00       	mov    0x804000,%eax
  8011a8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8011ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	57                   	push   %edi
  8011b9:	56                   	push   %esi
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8011c7:	85 db                	test   %ebx,%ebx
  8011c9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011ce:	0f 44 d8             	cmove  %eax,%ebx
  8011d1:	eb 05                	jmp    8011d8 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8011d3:	e8 7b fa ff ff       	call   800c53 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8011d8:	ff 75 14             	push   0x14(%ebp)
  8011db:	53                   	push   %ebx
  8011dc:	56                   	push   %esi
  8011dd:	57                   	push   %edi
  8011de:	e8 1c fc ff ff       	call   800dff <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011e9:	74 e8                	je     8011d3 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 08                	js     8011f7 <ipc_send+0x42>
	}while (r<0);

}
  8011ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8011f7:	50                   	push   %eax
  8011f8:	68 57 2b 80 00       	push   $0x802b57
  8011fd:	6a 3d                	push   $0x3d
  8011ff:	68 6b 2b 80 00       	push   $0x802b6b
  801204:	e8 4d 11 00 00       	call   802356 <_panic>

00801209 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80120f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801214:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80121a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801220:	8b 52 60             	mov    0x60(%edx),%edx
  801223:	39 ca                	cmp    %ecx,%edx
  801225:	74 11                	je     801238 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801227:	83 c0 01             	add    $0x1,%eax
  80122a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80122f:	75 e3                	jne    801214 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
  801236:	eb 0e                	jmp    801246 <ipc_find_env+0x3d>
			return envs[i].env_id;
  801238:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80123e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801243:	8b 40 58             	mov    0x58(%eax),%eax
}
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80124b:	8b 45 08             	mov    0x8(%ebp),%eax
  80124e:	05 00 00 00 30       	add    $0x30000000,%eax
  801253:	c1 e8 0c             	shr    $0xc,%eax
}
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801263:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801268:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801277:	89 c2                	mov    %eax,%edx
  801279:	c1 ea 16             	shr    $0x16,%edx
  80127c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801283:	f6 c2 01             	test   $0x1,%dl
  801286:	74 29                	je     8012b1 <fd_alloc+0x42>
  801288:	89 c2                	mov    %eax,%edx
  80128a:	c1 ea 0c             	shr    $0xc,%edx
  80128d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801294:	f6 c2 01             	test   $0x1,%dl
  801297:	74 18                	je     8012b1 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801299:	05 00 10 00 00       	add    $0x1000,%eax
  80129e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a3:	75 d2                	jne    801277 <fd_alloc+0x8>
  8012a5:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8012aa:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8012af:	eb 05                	jmp    8012b6 <fd_alloc+0x47>
			return 0;
  8012b1:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8012b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b9:	89 02                	mov    %eax,(%edx)
}
  8012bb:	89 c8                	mov    %ecx,%eax
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012c5:	83 f8 1f             	cmp    $0x1f,%eax
  8012c8:	77 30                	ja     8012fa <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ca:	c1 e0 0c             	shl    $0xc,%eax
  8012cd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d2:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012d8:	f6 c2 01             	test   $0x1,%dl
  8012db:	74 24                	je     801301 <fd_lookup+0x42>
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	c1 ea 0c             	shr    $0xc,%edx
  8012e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e9:	f6 c2 01             	test   $0x1,%dl
  8012ec:	74 1a                	je     801308 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f1:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    
		return -E_INVAL;
  8012fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ff:	eb f7                	jmp    8012f8 <fd_lookup+0x39>
		return -E_INVAL;
  801301:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801306:	eb f0                	jmp    8012f8 <fd_lookup+0x39>
  801308:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130d:	eb e9                	jmp    8012f8 <fd_lookup+0x39>

0080130f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	53                   	push   %ebx
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801319:	b8 00 00 00 00       	mov    $0x0,%eax
  80131e:	bb 0c 30 80 00       	mov    $0x80300c,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801323:	39 13                	cmp    %edx,(%ebx)
  801325:	74 37                	je     80135e <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801327:	83 c0 01             	add    $0x1,%eax
  80132a:	8b 1c 85 f4 2b 80 00 	mov    0x802bf4(,%eax,4),%ebx
  801331:	85 db                	test   %ebx,%ebx
  801333:	75 ee                	jne    801323 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801335:	a1 00 40 80 00       	mov    0x804000,%eax
  80133a:	8b 40 58             	mov    0x58(%eax),%eax
  80133d:	83 ec 04             	sub    $0x4,%esp
  801340:	52                   	push   %edx
  801341:	50                   	push   %eax
  801342:	68 78 2b 80 00       	push   $0x802b78
  801347:	e8 50 ef ff ff       	call   80029c <cprintf>
	*dev = 0;
	return -E_INVAL;
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801354:	8b 55 0c             	mov    0xc(%ebp),%edx
  801357:	89 1a                	mov    %ebx,(%edx)
}
  801359:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135c:	c9                   	leave  
  80135d:	c3                   	ret    
			return 0;
  80135e:	b8 00 00 00 00       	mov    $0x0,%eax
  801363:	eb ef                	jmp    801354 <dev_lookup+0x45>

00801365 <fd_close>:
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	57                   	push   %edi
  801369:	56                   	push   %esi
  80136a:	53                   	push   %ebx
  80136b:	83 ec 24             	sub    $0x24,%esp
  80136e:	8b 75 08             	mov    0x8(%ebp),%esi
  801371:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801374:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801377:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801378:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80137e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801381:	50                   	push   %eax
  801382:	e8 38 ff ff ff       	call   8012bf <fd_lookup>
  801387:	89 c3                	mov    %eax,%ebx
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 05                	js     801395 <fd_close+0x30>
	    || fd != fd2)
  801390:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801393:	74 16                	je     8013ab <fd_close+0x46>
		return (must_exist ? r : 0);
  801395:	89 f8                	mov    %edi,%eax
  801397:	84 c0                	test   %al,%al
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
  80139e:	0f 44 d8             	cmove  %eax,%ebx
}
  8013a1:	89 d8                	mov    %ebx,%eax
  8013a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a6:	5b                   	pop    %ebx
  8013a7:	5e                   	pop    %esi
  8013a8:	5f                   	pop    %edi
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	ff 36                	push   (%esi)
  8013b4:	e8 56 ff ff ff       	call   80130f <dev_lookup>
  8013b9:	89 c3                	mov    %eax,%ebx
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 1a                	js     8013dc <fd_close+0x77>
		if (dev->dev_close)
  8013c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013c5:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8013c8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	74 0b                	je     8013dc <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8013d1:	83 ec 0c             	sub    $0xc,%esp
  8013d4:	56                   	push   %esi
  8013d5:	ff d0                	call   *%eax
  8013d7:	89 c3                	mov    %eax,%ebx
  8013d9:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	56                   	push   %esi
  8013e0:	6a 00                	push   $0x0
  8013e2:	e8 10 f9 ff ff       	call   800cf7 <sys_page_unmap>
	return r;
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	eb b5                	jmp    8013a1 <fd_close+0x3c>

008013ec <close>:

int
close(int fdnum)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	ff 75 08             	push   0x8(%ebp)
  8013f9:	e8 c1 fe ff ff       	call   8012bf <fd_lookup>
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	79 02                	jns    801407 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801405:	c9                   	leave  
  801406:	c3                   	ret    
		return fd_close(fd, 1);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	6a 01                	push   $0x1
  80140c:	ff 75 f4             	push   -0xc(%ebp)
  80140f:	e8 51 ff ff ff       	call   801365 <fd_close>
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	eb ec                	jmp    801405 <close+0x19>

00801419 <close_all>:

void
close_all(void)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	53                   	push   %ebx
  80141d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801420:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	53                   	push   %ebx
  801429:	e8 be ff ff ff       	call   8013ec <close>
	for (i = 0; i < MAXFD; i++)
  80142e:	83 c3 01             	add    $0x1,%ebx
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	83 fb 20             	cmp    $0x20,%ebx
  801437:	75 ec                	jne    801425 <close_all+0xc>
}
  801439:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	57                   	push   %edi
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801447:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	ff 75 08             	push   0x8(%ebp)
  80144e:	e8 6c fe ff ff       	call   8012bf <fd_lookup>
  801453:	89 c3                	mov    %eax,%ebx
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 7f                	js     8014db <dup+0x9d>
		return r;
	close(newfdnum);
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	ff 75 0c             	push   0xc(%ebp)
  801462:	e8 85 ff ff ff       	call   8013ec <close>

	newfd = INDEX2FD(newfdnum);
  801467:	8b 75 0c             	mov    0xc(%ebp),%esi
  80146a:	c1 e6 0c             	shl    $0xc,%esi
  80146d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801476:	89 3c 24             	mov    %edi,(%esp)
  801479:	e8 da fd ff ff       	call   801258 <fd2data>
  80147e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801480:	89 34 24             	mov    %esi,(%esp)
  801483:	e8 d0 fd ff ff       	call   801258 <fd2data>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80148e:	89 d8                	mov    %ebx,%eax
  801490:	c1 e8 16             	shr    $0x16,%eax
  801493:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149a:	a8 01                	test   $0x1,%al
  80149c:	74 11                	je     8014af <dup+0x71>
  80149e:	89 d8                	mov    %ebx,%eax
  8014a0:	c1 e8 0c             	shr    $0xc,%eax
  8014a3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014aa:	f6 c2 01             	test   $0x1,%dl
  8014ad:	75 36                	jne    8014e5 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014af:	89 f8                	mov    %edi,%eax
  8014b1:	c1 e8 0c             	shr    $0xc,%eax
  8014b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c3:	50                   	push   %eax
  8014c4:	56                   	push   %esi
  8014c5:	6a 00                	push   $0x0
  8014c7:	57                   	push   %edi
  8014c8:	6a 00                	push   $0x0
  8014ca:	e8 e6 f7 ff ff       	call   800cb5 <sys_page_map>
  8014cf:	89 c3                	mov    %eax,%ebx
  8014d1:	83 c4 20             	add    $0x20,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 33                	js     80150b <dup+0xcd>
		goto err;

	return newfdnum;
  8014d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014db:	89 d8                	mov    %ebx,%eax
  8014dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e0:	5b                   	pop    %ebx
  8014e1:	5e                   	pop    %esi
  8014e2:	5f                   	pop    %edi
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ec:	83 ec 0c             	sub    $0xc,%esp
  8014ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f4:	50                   	push   %eax
  8014f5:	ff 75 d4             	push   -0x2c(%ebp)
  8014f8:	6a 00                	push   $0x0
  8014fa:	53                   	push   %ebx
  8014fb:	6a 00                	push   $0x0
  8014fd:	e8 b3 f7 ff ff       	call   800cb5 <sys_page_map>
  801502:	89 c3                	mov    %eax,%ebx
  801504:	83 c4 20             	add    $0x20,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	79 a4                	jns    8014af <dup+0x71>
	sys_page_unmap(0, newfd);
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	56                   	push   %esi
  80150f:	6a 00                	push   $0x0
  801511:	e8 e1 f7 ff ff       	call   800cf7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801516:	83 c4 08             	add    $0x8,%esp
  801519:	ff 75 d4             	push   -0x2c(%ebp)
  80151c:	6a 00                	push   $0x0
  80151e:	e8 d4 f7 ff ff       	call   800cf7 <sys_page_unmap>
	return r;
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	eb b3                	jmp    8014db <dup+0x9d>

00801528 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	83 ec 18             	sub    $0x18,%esp
  801530:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801533:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801536:	50                   	push   %eax
  801537:	56                   	push   %esi
  801538:	e8 82 fd ff ff       	call   8012bf <fd_lookup>
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 3c                	js     801580 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801544:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154d:	50                   	push   %eax
  80154e:	ff 33                	push   (%ebx)
  801550:	e8 ba fd ff ff       	call   80130f <dev_lookup>
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 24                	js     801580 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80155c:	8b 43 08             	mov    0x8(%ebx),%eax
  80155f:	83 e0 03             	and    $0x3,%eax
  801562:	83 f8 01             	cmp    $0x1,%eax
  801565:	74 20                	je     801587 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801567:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156a:	8b 40 08             	mov    0x8(%eax),%eax
  80156d:	85 c0                	test   %eax,%eax
  80156f:	74 37                	je     8015a8 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801571:	83 ec 04             	sub    $0x4,%esp
  801574:	ff 75 10             	push   0x10(%ebp)
  801577:	ff 75 0c             	push   0xc(%ebp)
  80157a:	53                   	push   %ebx
  80157b:	ff d0                	call   *%eax
  80157d:	83 c4 10             	add    $0x10,%esp
}
  801580:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801583:	5b                   	pop    %ebx
  801584:	5e                   	pop    %esi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801587:	a1 00 40 80 00       	mov    0x804000,%eax
  80158c:	8b 40 58             	mov    0x58(%eax),%eax
  80158f:	83 ec 04             	sub    $0x4,%esp
  801592:	56                   	push   %esi
  801593:	50                   	push   %eax
  801594:	68 b9 2b 80 00       	push   $0x802bb9
  801599:	e8 fe ec ff ff       	call   80029c <cprintf>
		return -E_INVAL;
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a6:	eb d8                	jmp    801580 <read+0x58>
		return -E_NOT_SUPP;
  8015a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015ad:	eb d1                	jmp    801580 <read+0x58>

008015af <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	57                   	push   %edi
  8015b3:	56                   	push   %esi
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015bb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c3:	eb 02                	jmp    8015c7 <readn+0x18>
  8015c5:	01 c3                	add    %eax,%ebx
  8015c7:	39 f3                	cmp    %esi,%ebx
  8015c9:	73 21                	jae    8015ec <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015cb:	83 ec 04             	sub    $0x4,%esp
  8015ce:	89 f0                	mov    %esi,%eax
  8015d0:	29 d8                	sub    %ebx,%eax
  8015d2:	50                   	push   %eax
  8015d3:	89 d8                	mov    %ebx,%eax
  8015d5:	03 45 0c             	add    0xc(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	57                   	push   %edi
  8015da:	e8 49 ff ff ff       	call   801528 <read>
		if (m < 0)
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 04                	js     8015ea <readn+0x3b>
			return m;
		if (m == 0)
  8015e6:	75 dd                	jne    8015c5 <readn+0x16>
  8015e8:	eb 02                	jmp    8015ec <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ea:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015ec:	89 d8                	mov    %ebx,%eax
  8015ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f1:	5b                   	pop    %ebx
  8015f2:	5e                   	pop    %esi
  8015f3:	5f                   	pop    %edi
  8015f4:	5d                   	pop    %ebp
  8015f5:	c3                   	ret    

008015f6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	56                   	push   %esi
  8015fa:	53                   	push   %ebx
  8015fb:	83 ec 18             	sub    $0x18,%esp
  8015fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801601:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801604:	50                   	push   %eax
  801605:	53                   	push   %ebx
  801606:	e8 b4 fc ff ff       	call   8012bf <fd_lookup>
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 37                	js     801649 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801612:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	ff 36                	push   (%esi)
  80161e:	e8 ec fc ff ff       	call   80130f <dev_lookup>
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 1f                	js     801649 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162a:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80162e:	74 20                	je     801650 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801630:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801633:	8b 40 0c             	mov    0xc(%eax),%eax
  801636:	85 c0                	test   %eax,%eax
  801638:	74 37                	je     801671 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80163a:	83 ec 04             	sub    $0x4,%esp
  80163d:	ff 75 10             	push   0x10(%ebp)
  801640:	ff 75 0c             	push   0xc(%ebp)
  801643:	56                   	push   %esi
  801644:	ff d0                	call   *%eax
  801646:	83 c4 10             	add    $0x10,%esp
}
  801649:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801650:	a1 00 40 80 00       	mov    0x804000,%eax
  801655:	8b 40 58             	mov    0x58(%eax),%eax
  801658:	83 ec 04             	sub    $0x4,%esp
  80165b:	53                   	push   %ebx
  80165c:	50                   	push   %eax
  80165d:	68 d5 2b 80 00       	push   $0x802bd5
  801662:	e8 35 ec ff ff       	call   80029c <cprintf>
		return -E_INVAL;
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80166f:	eb d8                	jmp    801649 <write+0x53>
		return -E_NOT_SUPP;
  801671:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801676:	eb d1                	jmp    801649 <write+0x53>

00801678 <seek>:

int
seek(int fdnum, off_t offset)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	ff 75 08             	push   0x8(%ebp)
  801685:	e8 35 fc ff ff       	call   8012bf <fd_lookup>
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 0e                	js     80169f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801691:	8b 55 0c             	mov    0xc(%ebp),%edx
  801694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801697:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80169a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 18             	sub    $0x18,%esp
  8016a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	53                   	push   %ebx
  8016b1:	e8 09 fc ff ff       	call   8012bf <fd_lookup>
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 34                	js     8016f1 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bd:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c6:	50                   	push   %eax
  8016c7:	ff 36                	push   (%esi)
  8016c9:	e8 41 fc ff ff       	call   80130f <dev_lookup>
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 1c                	js     8016f1 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d5:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8016d9:	74 1d                	je     8016f8 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016de:	8b 40 18             	mov    0x18(%eax),%eax
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	74 34                	je     801719 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	ff 75 0c             	push   0xc(%ebp)
  8016eb:	56                   	push   %esi
  8016ec:	ff d0                	call   *%eax
  8016ee:	83 c4 10             	add    $0x10,%esp
}
  8016f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f4:	5b                   	pop    %ebx
  8016f5:	5e                   	pop    %esi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016f8:	a1 00 40 80 00       	mov    0x804000,%eax
  8016fd:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801700:	83 ec 04             	sub    $0x4,%esp
  801703:	53                   	push   %ebx
  801704:	50                   	push   %eax
  801705:	68 98 2b 80 00       	push   $0x802b98
  80170a:	e8 8d eb ff ff       	call   80029c <cprintf>
		return -E_INVAL;
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801717:	eb d8                	jmp    8016f1 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801719:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80171e:	eb d1                	jmp    8016f1 <ftruncate+0x50>

00801720 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	83 ec 18             	sub    $0x18,%esp
  801728:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	ff 75 08             	push   0x8(%ebp)
  801732:	e8 88 fb ff ff       	call   8012bf <fd_lookup>
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 49                	js     801787 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801747:	50                   	push   %eax
  801748:	ff 36                	push   (%esi)
  80174a:	e8 c0 fb ff ff       	call   80130f <dev_lookup>
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	85 c0                	test   %eax,%eax
  801754:	78 31                	js     801787 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801759:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80175d:	74 2f                	je     80178e <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80175f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801762:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801769:	00 00 00 
	stat->st_isdir = 0;
  80176c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801773:	00 00 00 
	stat->st_dev = dev;
  801776:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80177c:	83 ec 08             	sub    $0x8,%esp
  80177f:	53                   	push   %ebx
  801780:	56                   	push   %esi
  801781:	ff 50 14             	call   *0x14(%eax)
  801784:	83 c4 10             	add    $0x10,%esp
}
  801787:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    
		return -E_NOT_SUPP;
  80178e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801793:	eb f2                	jmp    801787 <fstat+0x67>

00801795 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	6a 00                	push   $0x0
  80179f:	ff 75 08             	push   0x8(%ebp)
  8017a2:	e8 e4 01 00 00       	call   80198b <open>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 1b                	js     8017cb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	ff 75 0c             	push   0xc(%ebp)
  8017b6:	50                   	push   %eax
  8017b7:	e8 64 ff ff ff       	call   801720 <fstat>
  8017bc:	89 c6                	mov    %eax,%esi
	close(fd);
  8017be:	89 1c 24             	mov    %ebx,(%esp)
  8017c1:	e8 26 fc ff ff       	call   8013ec <close>
	return r;
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	89 f3                	mov    %esi,%ebx
}
  8017cb:	89 d8                	mov    %ebx,%eax
  8017cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	56                   	push   %esi
  8017d8:	53                   	push   %ebx
  8017d9:	89 c6                	mov    %eax,%esi
  8017db:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017dd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8017e4:	74 27                	je     80180d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017e6:	6a 07                	push   $0x7
  8017e8:	68 00 50 80 00       	push   $0x805000
  8017ed:	56                   	push   %esi
  8017ee:	ff 35 00 60 80 00    	push   0x806000
  8017f4:	e8 bc f9 ff ff       	call   8011b5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017f9:	83 c4 0c             	add    $0xc,%esp
  8017fc:	6a 00                	push   $0x0
  8017fe:	53                   	push   %ebx
  8017ff:	6a 00                	push   $0x0
  801801:	e8 3f f9 ff ff       	call   801145 <ipc_recv>
}
  801806:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80180d:	83 ec 0c             	sub    $0xc,%esp
  801810:	6a 01                	push   $0x1
  801812:	e8 f2 f9 ff ff       	call   801209 <ipc_find_env>
  801817:	a3 00 60 80 00       	mov    %eax,0x806000
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	eb c5                	jmp    8017e6 <fsipc+0x12>

00801821 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	8b 40 0c             	mov    0xc(%eax),%eax
  80182d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801832:	8b 45 0c             	mov    0xc(%ebp),%eax
  801835:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80183a:	ba 00 00 00 00       	mov    $0x0,%edx
  80183f:	b8 02 00 00 00       	mov    $0x2,%eax
  801844:	e8 8b ff ff ff       	call   8017d4 <fsipc>
}
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <devfile_flush>:
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	8b 40 0c             	mov    0xc(%eax),%eax
  801857:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80185c:	ba 00 00 00 00       	mov    $0x0,%edx
  801861:	b8 06 00 00 00       	mov    $0x6,%eax
  801866:	e8 69 ff ff ff       	call   8017d4 <fsipc>
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    

0080186d <devfile_stat>:
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	53                   	push   %ebx
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801877:	8b 45 08             	mov    0x8(%ebp),%eax
  80187a:	8b 40 0c             	mov    0xc(%eax),%eax
  80187d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801882:	ba 00 00 00 00       	mov    $0x0,%edx
  801887:	b8 05 00 00 00       	mov    $0x5,%eax
  80188c:	e8 43 ff ff ff       	call   8017d4 <fsipc>
  801891:	85 c0                	test   %eax,%eax
  801893:	78 2c                	js     8018c1 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801895:	83 ec 08             	sub    $0x8,%esp
  801898:	68 00 50 80 00       	push   $0x805000
  80189d:	53                   	push   %ebx
  80189e:	e8 d3 ef ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a3:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ae:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c4:	c9                   	leave  
  8018c5:	c3                   	ret    

008018c6 <devfile_write>:
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	83 ec 0c             	sub    $0xc,%esp
  8018cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8018cf:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018d4:	39 d0                	cmp    %edx,%eax
  8018d6:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8018dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8018df:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018e5:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018ea:	50                   	push   %eax
  8018eb:	ff 75 0c             	push   0xc(%ebp)
  8018ee:	68 08 50 80 00       	push   $0x805008
  8018f3:	e8 14 f1 ff ff       	call   800a0c <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8018f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fd:	b8 04 00 00 00       	mov    $0x4,%eax
  801902:	e8 cd fe ff ff       	call   8017d4 <fsipc>
}
  801907:	c9                   	leave  
  801908:	c3                   	ret    

00801909 <devfile_read>:
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	56                   	push   %esi
  80190d:	53                   	push   %ebx
  80190e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	8b 40 0c             	mov    0xc(%eax),%eax
  801917:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80191c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801922:	ba 00 00 00 00       	mov    $0x0,%edx
  801927:	b8 03 00 00 00       	mov    $0x3,%eax
  80192c:	e8 a3 fe ff ff       	call   8017d4 <fsipc>
  801931:	89 c3                	mov    %eax,%ebx
  801933:	85 c0                	test   %eax,%eax
  801935:	78 1f                	js     801956 <devfile_read+0x4d>
	assert(r <= n);
  801937:	39 f0                	cmp    %esi,%eax
  801939:	77 24                	ja     80195f <devfile_read+0x56>
	assert(r <= PGSIZE);
  80193b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801940:	7f 33                	jg     801975 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801942:	83 ec 04             	sub    $0x4,%esp
  801945:	50                   	push   %eax
  801946:	68 00 50 80 00       	push   $0x805000
  80194b:	ff 75 0c             	push   0xc(%ebp)
  80194e:	e8 b9 f0 ff ff       	call   800a0c <memmove>
	return r;
  801953:	83 c4 10             	add    $0x10,%esp
}
  801956:	89 d8                	mov    %ebx,%eax
  801958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5e                   	pop    %esi
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    
	assert(r <= n);
  80195f:	68 08 2c 80 00       	push   $0x802c08
  801964:	68 0f 2c 80 00       	push   $0x802c0f
  801969:	6a 7c                	push   $0x7c
  80196b:	68 24 2c 80 00       	push   $0x802c24
  801970:	e8 e1 09 00 00       	call   802356 <_panic>
	assert(r <= PGSIZE);
  801975:	68 2f 2c 80 00       	push   $0x802c2f
  80197a:	68 0f 2c 80 00       	push   $0x802c0f
  80197f:	6a 7d                	push   $0x7d
  801981:	68 24 2c 80 00       	push   $0x802c24
  801986:	e8 cb 09 00 00       	call   802356 <_panic>

0080198b <open>:
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
  801990:	83 ec 1c             	sub    $0x1c,%esp
  801993:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801996:	56                   	push   %esi
  801997:	e8 9f ee ff ff       	call   80083b <strlen>
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a4:	7f 6c                	jg     801a12 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8019a6:	83 ec 0c             	sub    $0xc,%esp
  8019a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ac:	50                   	push   %eax
  8019ad:	e8 bd f8 ff ff       	call   80126f <fd_alloc>
  8019b2:	89 c3                	mov    %eax,%ebx
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	78 3c                	js     8019f7 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	56                   	push   %esi
  8019bf:	68 00 50 80 00       	push   $0x805000
  8019c4:	e8 ad ee ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cc:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d9:	e8 f6 fd ff ff       	call   8017d4 <fsipc>
  8019de:	89 c3                	mov    %eax,%ebx
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 19                	js     801a00 <open+0x75>
	return fd2num(fd);
  8019e7:	83 ec 0c             	sub    $0xc,%esp
  8019ea:	ff 75 f4             	push   -0xc(%ebp)
  8019ed:	e8 56 f8 ff ff       	call   801248 <fd2num>
  8019f2:	89 c3                	mov    %eax,%ebx
  8019f4:	83 c4 10             	add    $0x10,%esp
}
  8019f7:	89 d8                	mov    %ebx,%eax
  8019f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fc:	5b                   	pop    %ebx
  8019fd:	5e                   	pop    %esi
  8019fe:	5d                   	pop    %ebp
  8019ff:	c3                   	ret    
		fd_close(fd, 0);
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	6a 00                	push   $0x0
  801a05:	ff 75 f4             	push   -0xc(%ebp)
  801a08:	e8 58 f9 ff ff       	call   801365 <fd_close>
		return r;
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	eb e5                	jmp    8019f7 <open+0x6c>
		return -E_BAD_PATH;
  801a12:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a17:	eb de                	jmp    8019f7 <open+0x6c>

00801a19 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a24:	b8 08 00 00 00       	mov    $0x8,%eax
  801a29:	e8 a6 fd ff ff       	call   8017d4 <fsipc>
}
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    

00801a30 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a36:	68 3b 2c 80 00       	push   $0x802c3b
  801a3b:	ff 75 0c             	push   0xc(%ebp)
  801a3e:	e8 33 ee ff ff       	call   800876 <strcpy>
	return 0;
}
  801a43:	b8 00 00 00 00       	mov    $0x0,%eax
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <devsock_close>:
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 10             	sub    $0x10,%esp
  801a51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a54:	53                   	push   %ebx
  801a55:	e8 de 09 00 00       	call   802438 <pageref>
  801a5a:	89 c2                	mov    %eax,%edx
  801a5c:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a5f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a64:	83 fa 01             	cmp    $0x1,%edx
  801a67:	74 05                	je     801a6e <devsock_close+0x24>
}
  801a69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	ff 73 0c             	push   0xc(%ebx)
  801a74:	e8 b7 02 00 00       	call   801d30 <nsipc_close>
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	eb eb                	jmp    801a69 <devsock_close+0x1f>

00801a7e <devsock_write>:
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a84:	6a 00                	push   $0x0
  801a86:	ff 75 10             	push   0x10(%ebp)
  801a89:	ff 75 0c             	push   0xc(%ebp)
  801a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8f:	ff 70 0c             	push   0xc(%eax)
  801a92:	e8 79 03 00 00       	call   801e10 <nsipc_send>
}
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    

00801a99 <devsock_read>:
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a9f:	6a 00                	push   $0x0
  801aa1:	ff 75 10             	push   0x10(%ebp)
  801aa4:	ff 75 0c             	push   0xc(%ebp)
  801aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaa:	ff 70 0c             	push   0xc(%eax)
  801aad:	e8 ef 02 00 00       	call   801da1 <nsipc_recv>
}
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <fd2sockid>:
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aba:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801abd:	52                   	push   %edx
  801abe:	50                   	push   %eax
  801abf:	e8 fb f7 ff ff       	call   8012bf <fd_lookup>
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 10                	js     801adb <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ace:	8b 0d 28 30 80 00    	mov    0x803028,%ecx
  801ad4:	39 08                	cmp    %ecx,(%eax)
  801ad6:	75 05                	jne    801add <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801ad8:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    
		return -E_NOT_SUPP;
  801add:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ae2:	eb f7                	jmp    801adb <fd2sockid+0x27>

00801ae4 <alloc_sockfd>:
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 1c             	sub    $0x1c,%esp
  801aec:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801aee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af1:	50                   	push   %eax
  801af2:	e8 78 f7 ff ff       	call   80126f <fd_alloc>
  801af7:	89 c3                	mov    %eax,%ebx
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	85 c0                	test   %eax,%eax
  801afe:	78 43                	js     801b43 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	68 07 04 00 00       	push   $0x407
  801b08:	ff 75 f4             	push   -0xc(%ebp)
  801b0b:	6a 00                	push   $0x0
  801b0d:	e8 60 f1 ff ff       	call   800c72 <sys_page_alloc>
  801b12:	89 c3                	mov    %eax,%ebx
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	85 c0                	test   %eax,%eax
  801b19:	78 28                	js     801b43 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1e:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801b24:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b29:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b30:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b33:	83 ec 0c             	sub    $0xc,%esp
  801b36:	50                   	push   %eax
  801b37:	e8 0c f7 ff ff       	call   801248 <fd2num>
  801b3c:	89 c3                	mov    %eax,%ebx
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	eb 0c                	jmp    801b4f <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b43:	83 ec 0c             	sub    $0xc,%esp
  801b46:	56                   	push   %esi
  801b47:	e8 e4 01 00 00       	call   801d30 <nsipc_close>
		return r;
  801b4c:	83 c4 10             	add    $0x10,%esp
}
  801b4f:	89 d8                	mov    %ebx,%eax
  801b51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <accept>:
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b61:	e8 4e ff ff ff       	call   801ab4 <fd2sockid>
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 1b                	js     801b85 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b6a:	83 ec 04             	sub    $0x4,%esp
  801b6d:	ff 75 10             	push   0x10(%ebp)
  801b70:	ff 75 0c             	push   0xc(%ebp)
  801b73:	50                   	push   %eax
  801b74:	e8 0e 01 00 00       	call   801c87 <nsipc_accept>
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	78 05                	js     801b85 <accept+0x2d>
	return alloc_sockfd(r);
  801b80:	e8 5f ff ff ff       	call   801ae4 <alloc_sockfd>
}
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <bind>:
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b90:	e8 1f ff ff ff       	call   801ab4 <fd2sockid>
  801b95:	85 c0                	test   %eax,%eax
  801b97:	78 12                	js     801bab <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b99:	83 ec 04             	sub    $0x4,%esp
  801b9c:	ff 75 10             	push   0x10(%ebp)
  801b9f:	ff 75 0c             	push   0xc(%ebp)
  801ba2:	50                   	push   %eax
  801ba3:	e8 31 01 00 00       	call   801cd9 <nsipc_bind>
  801ba8:	83 c4 10             	add    $0x10,%esp
}
  801bab:	c9                   	leave  
  801bac:	c3                   	ret    

00801bad <shutdown>:
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb6:	e8 f9 fe ff ff       	call   801ab4 <fd2sockid>
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	78 0f                	js     801bce <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	ff 75 0c             	push   0xc(%ebp)
  801bc5:	50                   	push   %eax
  801bc6:	e8 43 01 00 00       	call   801d0e <nsipc_shutdown>
  801bcb:	83 c4 10             	add    $0x10,%esp
}
  801bce:	c9                   	leave  
  801bcf:	c3                   	ret    

00801bd0 <connect>:
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd9:	e8 d6 fe ff ff       	call   801ab4 <fd2sockid>
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 12                	js     801bf4 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801be2:	83 ec 04             	sub    $0x4,%esp
  801be5:	ff 75 10             	push   0x10(%ebp)
  801be8:	ff 75 0c             	push   0xc(%ebp)
  801beb:	50                   	push   %eax
  801bec:	e8 59 01 00 00       	call   801d4a <nsipc_connect>
  801bf1:	83 c4 10             	add    $0x10,%esp
}
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <listen>:
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bff:	e8 b0 fe ff ff       	call   801ab4 <fd2sockid>
  801c04:	85 c0                	test   %eax,%eax
  801c06:	78 0f                	js     801c17 <listen+0x21>
	return nsipc_listen(r, backlog);
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	ff 75 0c             	push   0xc(%ebp)
  801c0e:	50                   	push   %eax
  801c0f:	e8 6b 01 00 00       	call   801d7f <nsipc_listen>
  801c14:	83 c4 10             	add    $0x10,%esp
}
  801c17:	c9                   	leave  
  801c18:	c3                   	ret    

00801c19 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c1f:	ff 75 10             	push   0x10(%ebp)
  801c22:	ff 75 0c             	push   0xc(%ebp)
  801c25:	ff 75 08             	push   0x8(%ebp)
  801c28:	e8 41 02 00 00       	call   801e6e <nsipc_socket>
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	85 c0                	test   %eax,%eax
  801c32:	78 05                	js     801c39 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c34:	e8 ab fe ff ff       	call   801ae4 <alloc_sockfd>
}
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    

00801c3b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	53                   	push   %ebx
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c44:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801c4b:	74 26                	je     801c73 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c4d:	6a 07                	push   $0x7
  801c4f:	68 00 70 80 00       	push   $0x807000
  801c54:	53                   	push   %ebx
  801c55:	ff 35 00 80 80 00    	push   0x808000
  801c5b:	e8 55 f5 ff ff       	call   8011b5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c60:	83 c4 0c             	add    $0xc,%esp
  801c63:	6a 00                	push   $0x0
  801c65:	6a 00                	push   $0x0
  801c67:	6a 00                	push   $0x0
  801c69:	e8 d7 f4 ff ff       	call   801145 <ipc_recv>
}
  801c6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	6a 02                	push   $0x2
  801c78:	e8 8c f5 ff ff       	call   801209 <ipc_find_env>
  801c7d:	a3 00 80 80 00       	mov    %eax,0x808000
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	eb c6                	jmp    801c4d <nsipc+0x12>

00801c87 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	56                   	push   %esi
  801c8b:	53                   	push   %ebx
  801c8c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c92:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c97:	8b 06                	mov    (%esi),%eax
  801c99:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca3:	e8 93 ff ff ff       	call   801c3b <nsipc>
  801ca8:	89 c3                	mov    %eax,%ebx
  801caa:	85 c0                	test   %eax,%eax
  801cac:	79 09                	jns    801cb7 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801cae:	89 d8                	mov    %ebx,%eax
  801cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cb7:	83 ec 04             	sub    $0x4,%esp
  801cba:	ff 35 10 70 80 00    	push   0x807010
  801cc0:	68 00 70 80 00       	push   $0x807000
  801cc5:	ff 75 0c             	push   0xc(%ebp)
  801cc8:	e8 3f ed ff ff       	call   800a0c <memmove>
		*addrlen = ret->ret_addrlen;
  801ccd:	a1 10 70 80 00       	mov    0x807010,%eax
  801cd2:	89 06                	mov    %eax,(%esi)
  801cd4:	83 c4 10             	add    $0x10,%esp
	return r;
  801cd7:	eb d5                	jmp    801cae <nsipc_accept+0x27>

00801cd9 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	53                   	push   %ebx
  801cdd:	83 ec 08             	sub    $0x8,%esp
  801ce0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ceb:	53                   	push   %ebx
  801cec:	ff 75 0c             	push   0xc(%ebp)
  801cef:	68 04 70 80 00       	push   $0x807004
  801cf4:	e8 13 ed ff ff       	call   800a0c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cf9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801cff:	b8 02 00 00 00       	mov    $0x2,%eax
  801d04:	e8 32 ff ff ff       	call   801c3b <nsipc>
}
  801d09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d14:	8b 45 08             	mov    0x8(%ebp),%eax
  801d17:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801d24:	b8 03 00 00 00       	mov    $0x3,%eax
  801d29:	e8 0d ff ff ff       	call   801c3b <nsipc>
}
  801d2e:	c9                   	leave  
  801d2f:	c3                   	ret    

00801d30 <nsipc_close>:

int
nsipc_close(int s)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d36:	8b 45 08             	mov    0x8(%ebp),%eax
  801d39:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801d3e:	b8 04 00 00 00       	mov    $0x4,%eax
  801d43:	e8 f3 fe ff ff       	call   801c3b <nsipc>
}
  801d48:	c9                   	leave  
  801d49:	c3                   	ret    

00801d4a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	53                   	push   %ebx
  801d4e:	83 ec 08             	sub    $0x8,%esp
  801d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d54:	8b 45 08             	mov    0x8(%ebp),%eax
  801d57:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d5c:	53                   	push   %ebx
  801d5d:	ff 75 0c             	push   0xc(%ebp)
  801d60:	68 04 70 80 00       	push   $0x807004
  801d65:	e8 a2 ec ff ff       	call   800a0c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d6a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801d70:	b8 05 00 00 00       	mov    $0x5,%eax
  801d75:	e8 c1 fe ff ff       	call   801c3b <nsipc>
}
  801d7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d85:	8b 45 08             	mov    0x8(%ebp),%eax
  801d88:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d90:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d95:	b8 06 00 00 00       	mov    $0x6,%eax
  801d9a:	e8 9c fe ff ff       	call   801c3b <nsipc>
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    

00801da1 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	56                   	push   %esi
  801da5:	53                   	push   %ebx
  801da6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801da9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dac:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801db1:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801db7:	8b 45 14             	mov    0x14(%ebp),%eax
  801dba:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dbf:	b8 07 00 00 00       	mov    $0x7,%eax
  801dc4:	e8 72 fe ff ff       	call   801c3b <nsipc>
  801dc9:	89 c3                	mov    %eax,%ebx
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 22                	js     801df1 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801dcf:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801dd4:	39 c6                	cmp    %eax,%esi
  801dd6:	0f 4e c6             	cmovle %esi,%eax
  801dd9:	39 c3                	cmp    %eax,%ebx
  801ddb:	7f 1d                	jg     801dfa <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ddd:	83 ec 04             	sub    $0x4,%esp
  801de0:	53                   	push   %ebx
  801de1:	68 00 70 80 00       	push   $0x807000
  801de6:	ff 75 0c             	push   0xc(%ebp)
  801de9:	e8 1e ec ff ff       	call   800a0c <memmove>
  801dee:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801df1:	89 d8                	mov    %ebx,%eax
  801df3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df6:	5b                   	pop    %ebx
  801df7:	5e                   	pop    %esi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801dfa:	68 47 2c 80 00       	push   $0x802c47
  801dff:	68 0f 2c 80 00       	push   $0x802c0f
  801e04:	6a 62                	push   $0x62
  801e06:	68 5c 2c 80 00       	push   $0x802c5c
  801e0b:	e8 46 05 00 00       	call   802356 <_panic>

00801e10 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	53                   	push   %ebx
  801e14:	83 ec 04             	sub    $0x4,%esp
  801e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801e22:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e28:	7f 2e                	jg     801e58 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e2a:	83 ec 04             	sub    $0x4,%esp
  801e2d:	53                   	push   %ebx
  801e2e:	ff 75 0c             	push   0xc(%ebp)
  801e31:	68 0c 70 80 00       	push   $0x80700c
  801e36:	e8 d1 eb ff ff       	call   800a0c <memmove>
	nsipcbuf.send.req_size = size;
  801e3b:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801e41:	8b 45 14             	mov    0x14(%ebp),%eax
  801e44:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801e49:	b8 08 00 00 00       	mov    $0x8,%eax
  801e4e:	e8 e8 fd ff ff       	call   801c3b <nsipc>
}
  801e53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    
	assert(size < 1600);
  801e58:	68 68 2c 80 00       	push   $0x802c68
  801e5d:	68 0f 2c 80 00       	push   $0x802c0f
  801e62:	6a 6d                	push   $0x6d
  801e64:	68 5c 2c 80 00       	push   $0x802c5c
  801e69:	e8 e8 04 00 00       	call   802356 <_panic>

00801e6e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e74:	8b 45 08             	mov    0x8(%ebp),%eax
  801e77:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801e84:	8b 45 10             	mov    0x10(%ebp),%eax
  801e87:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e8c:	b8 09 00 00 00       	mov    $0x9,%eax
  801e91:	e8 a5 fd ff ff       	call   801c3b <nsipc>
}
  801e96:	c9                   	leave  
  801e97:	c3                   	ret    

00801e98 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	56                   	push   %esi
  801e9c:	53                   	push   %ebx
  801e9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ea0:	83 ec 0c             	sub    $0xc,%esp
  801ea3:	ff 75 08             	push   0x8(%ebp)
  801ea6:	e8 ad f3 ff ff       	call   801258 <fd2data>
  801eab:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ead:	83 c4 08             	add    $0x8,%esp
  801eb0:	68 74 2c 80 00       	push   $0x802c74
  801eb5:	53                   	push   %ebx
  801eb6:	e8 bb e9 ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ebb:	8b 46 04             	mov    0x4(%esi),%eax
  801ebe:	2b 06                	sub    (%esi),%eax
  801ec0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ec6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ecd:	00 00 00 
	stat->st_dev = &devpipe;
  801ed0:	c7 83 88 00 00 00 44 	movl   $0x803044,0x88(%ebx)
  801ed7:	30 80 00 
	return 0;
}
  801eda:	b8 00 00 00 00       	mov    $0x0,%eax
  801edf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee2:	5b                   	pop    %ebx
  801ee3:	5e                   	pop    %esi
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    

00801ee6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	53                   	push   %ebx
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ef0:	53                   	push   %ebx
  801ef1:	6a 00                	push   $0x0
  801ef3:	e8 ff ed ff ff       	call   800cf7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ef8:	89 1c 24             	mov    %ebx,(%esp)
  801efb:	e8 58 f3 ff ff       	call   801258 <fd2data>
  801f00:	83 c4 08             	add    $0x8,%esp
  801f03:	50                   	push   %eax
  801f04:	6a 00                	push   $0x0
  801f06:	e8 ec ed ff ff       	call   800cf7 <sys_page_unmap>
}
  801f0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f0e:	c9                   	leave  
  801f0f:	c3                   	ret    

00801f10 <_pipeisclosed>:
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	57                   	push   %edi
  801f14:	56                   	push   %esi
  801f15:	53                   	push   %ebx
  801f16:	83 ec 1c             	sub    $0x1c,%esp
  801f19:	89 c7                	mov    %eax,%edi
  801f1b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f1d:	a1 00 40 80 00       	mov    0x804000,%eax
  801f22:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f25:	83 ec 0c             	sub    $0xc,%esp
  801f28:	57                   	push   %edi
  801f29:	e8 0a 05 00 00       	call   802438 <pageref>
  801f2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f31:	89 34 24             	mov    %esi,(%esp)
  801f34:	e8 ff 04 00 00       	call   802438 <pageref>
		nn = thisenv->env_runs;
  801f39:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f3f:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801f42:	83 c4 10             	add    $0x10,%esp
  801f45:	39 cb                	cmp    %ecx,%ebx
  801f47:	74 1b                	je     801f64 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f49:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f4c:	75 cf                	jne    801f1d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f4e:	8b 42 68             	mov    0x68(%edx),%eax
  801f51:	6a 01                	push   $0x1
  801f53:	50                   	push   %eax
  801f54:	53                   	push   %ebx
  801f55:	68 7b 2c 80 00       	push   $0x802c7b
  801f5a:	e8 3d e3 ff ff       	call   80029c <cprintf>
  801f5f:	83 c4 10             	add    $0x10,%esp
  801f62:	eb b9                	jmp    801f1d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f64:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f67:	0f 94 c0             	sete   %al
  801f6a:	0f b6 c0             	movzbl %al,%eax
}
  801f6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f70:	5b                   	pop    %ebx
  801f71:	5e                   	pop    %esi
  801f72:	5f                   	pop    %edi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    

00801f75 <devpipe_write>:
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	57                   	push   %edi
  801f79:	56                   	push   %esi
  801f7a:	53                   	push   %ebx
  801f7b:	83 ec 28             	sub    $0x28,%esp
  801f7e:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f81:	56                   	push   %esi
  801f82:	e8 d1 f2 ff ff       	call   801258 <fd2data>
  801f87:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	bf 00 00 00 00       	mov    $0x0,%edi
  801f91:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f94:	75 09                	jne    801f9f <devpipe_write+0x2a>
	return i;
  801f96:	89 f8                	mov    %edi,%eax
  801f98:	eb 23                	jmp    801fbd <devpipe_write+0x48>
			sys_yield();
  801f9a:	e8 b4 ec ff ff       	call   800c53 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f9f:	8b 43 04             	mov    0x4(%ebx),%eax
  801fa2:	8b 0b                	mov    (%ebx),%ecx
  801fa4:	8d 51 20             	lea    0x20(%ecx),%edx
  801fa7:	39 d0                	cmp    %edx,%eax
  801fa9:	72 1a                	jb     801fc5 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801fab:	89 da                	mov    %ebx,%edx
  801fad:	89 f0                	mov    %esi,%eax
  801faf:	e8 5c ff ff ff       	call   801f10 <_pipeisclosed>
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	74 e2                	je     801f9a <devpipe_write+0x25>
				return 0;
  801fb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc0:	5b                   	pop    %ebx
  801fc1:	5e                   	pop    %esi
  801fc2:	5f                   	pop    %edi
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fc8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fcc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fcf:	89 c2                	mov    %eax,%edx
  801fd1:	c1 fa 1f             	sar    $0x1f,%edx
  801fd4:	89 d1                	mov    %edx,%ecx
  801fd6:	c1 e9 1b             	shr    $0x1b,%ecx
  801fd9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fdc:	83 e2 1f             	and    $0x1f,%edx
  801fdf:	29 ca                	sub    %ecx,%edx
  801fe1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fe5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fe9:	83 c0 01             	add    $0x1,%eax
  801fec:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801fef:	83 c7 01             	add    $0x1,%edi
  801ff2:	eb 9d                	jmp    801f91 <devpipe_write+0x1c>

00801ff4 <devpipe_read>:
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	57                   	push   %edi
  801ff8:	56                   	push   %esi
  801ff9:	53                   	push   %ebx
  801ffa:	83 ec 18             	sub    $0x18,%esp
  801ffd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802000:	57                   	push   %edi
  802001:	e8 52 f2 ff ff       	call   801258 <fd2data>
  802006:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802008:	83 c4 10             	add    $0x10,%esp
  80200b:	be 00 00 00 00       	mov    $0x0,%esi
  802010:	3b 75 10             	cmp    0x10(%ebp),%esi
  802013:	75 13                	jne    802028 <devpipe_read+0x34>
	return i;
  802015:	89 f0                	mov    %esi,%eax
  802017:	eb 02                	jmp    80201b <devpipe_read+0x27>
				return i;
  802019:	89 f0                	mov    %esi,%eax
}
  80201b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201e:	5b                   	pop    %ebx
  80201f:	5e                   	pop    %esi
  802020:	5f                   	pop    %edi
  802021:	5d                   	pop    %ebp
  802022:	c3                   	ret    
			sys_yield();
  802023:	e8 2b ec ff ff       	call   800c53 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802028:	8b 03                	mov    (%ebx),%eax
  80202a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80202d:	75 18                	jne    802047 <devpipe_read+0x53>
			if (i > 0)
  80202f:	85 f6                	test   %esi,%esi
  802031:	75 e6                	jne    802019 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802033:	89 da                	mov    %ebx,%edx
  802035:	89 f8                	mov    %edi,%eax
  802037:	e8 d4 fe ff ff       	call   801f10 <_pipeisclosed>
  80203c:	85 c0                	test   %eax,%eax
  80203e:	74 e3                	je     802023 <devpipe_read+0x2f>
				return 0;
  802040:	b8 00 00 00 00       	mov    $0x0,%eax
  802045:	eb d4                	jmp    80201b <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802047:	99                   	cltd   
  802048:	c1 ea 1b             	shr    $0x1b,%edx
  80204b:	01 d0                	add    %edx,%eax
  80204d:	83 e0 1f             	and    $0x1f,%eax
  802050:	29 d0                	sub    %edx,%eax
  802052:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802057:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80205a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80205d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802060:	83 c6 01             	add    $0x1,%esi
  802063:	eb ab                	jmp    802010 <devpipe_read+0x1c>

00802065 <pipe>:
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	56                   	push   %esi
  802069:	53                   	push   %ebx
  80206a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80206d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802070:	50                   	push   %eax
  802071:	e8 f9 f1 ff ff       	call   80126f <fd_alloc>
  802076:	89 c3                	mov    %eax,%ebx
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	85 c0                	test   %eax,%eax
  80207d:	0f 88 23 01 00 00    	js     8021a6 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802083:	83 ec 04             	sub    $0x4,%esp
  802086:	68 07 04 00 00       	push   $0x407
  80208b:	ff 75 f4             	push   -0xc(%ebp)
  80208e:	6a 00                	push   $0x0
  802090:	e8 dd eb ff ff       	call   800c72 <sys_page_alloc>
  802095:	89 c3                	mov    %eax,%ebx
  802097:	83 c4 10             	add    $0x10,%esp
  80209a:	85 c0                	test   %eax,%eax
  80209c:	0f 88 04 01 00 00    	js     8021a6 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8020a2:	83 ec 0c             	sub    $0xc,%esp
  8020a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020a8:	50                   	push   %eax
  8020a9:	e8 c1 f1 ff ff       	call   80126f <fd_alloc>
  8020ae:	89 c3                	mov    %eax,%ebx
  8020b0:	83 c4 10             	add    $0x10,%esp
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	0f 88 db 00 00 00    	js     802196 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020bb:	83 ec 04             	sub    $0x4,%esp
  8020be:	68 07 04 00 00       	push   $0x407
  8020c3:	ff 75 f0             	push   -0x10(%ebp)
  8020c6:	6a 00                	push   $0x0
  8020c8:	e8 a5 eb ff ff       	call   800c72 <sys_page_alloc>
  8020cd:	89 c3                	mov    %eax,%ebx
  8020cf:	83 c4 10             	add    $0x10,%esp
  8020d2:	85 c0                	test   %eax,%eax
  8020d4:	0f 88 bc 00 00 00    	js     802196 <pipe+0x131>
	va = fd2data(fd0);
  8020da:	83 ec 0c             	sub    $0xc,%esp
  8020dd:	ff 75 f4             	push   -0xc(%ebp)
  8020e0:	e8 73 f1 ff ff       	call   801258 <fd2data>
  8020e5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e7:	83 c4 0c             	add    $0xc,%esp
  8020ea:	68 07 04 00 00       	push   $0x407
  8020ef:	50                   	push   %eax
  8020f0:	6a 00                	push   $0x0
  8020f2:	e8 7b eb ff ff       	call   800c72 <sys_page_alloc>
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	83 c4 10             	add    $0x10,%esp
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	0f 88 82 00 00 00    	js     802186 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802104:	83 ec 0c             	sub    $0xc,%esp
  802107:	ff 75 f0             	push   -0x10(%ebp)
  80210a:	e8 49 f1 ff ff       	call   801258 <fd2data>
  80210f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802116:	50                   	push   %eax
  802117:	6a 00                	push   $0x0
  802119:	56                   	push   %esi
  80211a:	6a 00                	push   $0x0
  80211c:	e8 94 eb ff ff       	call   800cb5 <sys_page_map>
  802121:	89 c3                	mov    %eax,%ebx
  802123:	83 c4 20             	add    $0x20,%esp
  802126:	85 c0                	test   %eax,%eax
  802128:	78 4e                	js     802178 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80212a:	a1 44 30 80 00       	mov    0x803044,%eax
  80212f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802132:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802134:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802137:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80213e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802141:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802143:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802146:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80214d:	83 ec 0c             	sub    $0xc,%esp
  802150:	ff 75 f4             	push   -0xc(%ebp)
  802153:	e8 f0 f0 ff ff       	call   801248 <fd2num>
  802158:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80215b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80215d:	83 c4 04             	add    $0x4,%esp
  802160:	ff 75 f0             	push   -0x10(%ebp)
  802163:	e8 e0 f0 ff ff       	call   801248 <fd2num>
  802168:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80216b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80216e:	83 c4 10             	add    $0x10,%esp
  802171:	bb 00 00 00 00       	mov    $0x0,%ebx
  802176:	eb 2e                	jmp    8021a6 <pipe+0x141>
	sys_page_unmap(0, va);
  802178:	83 ec 08             	sub    $0x8,%esp
  80217b:	56                   	push   %esi
  80217c:	6a 00                	push   $0x0
  80217e:	e8 74 eb ff ff       	call   800cf7 <sys_page_unmap>
  802183:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802186:	83 ec 08             	sub    $0x8,%esp
  802189:	ff 75 f0             	push   -0x10(%ebp)
  80218c:	6a 00                	push   $0x0
  80218e:	e8 64 eb ff ff       	call   800cf7 <sys_page_unmap>
  802193:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802196:	83 ec 08             	sub    $0x8,%esp
  802199:	ff 75 f4             	push   -0xc(%ebp)
  80219c:	6a 00                	push   $0x0
  80219e:	e8 54 eb ff ff       	call   800cf7 <sys_page_unmap>
  8021a3:	83 c4 10             	add    $0x10,%esp
}
  8021a6:	89 d8                	mov    %ebx,%eax
  8021a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ab:	5b                   	pop    %ebx
  8021ac:	5e                   	pop    %esi
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    

008021af <pipeisclosed>:
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b8:	50                   	push   %eax
  8021b9:	ff 75 08             	push   0x8(%ebp)
  8021bc:	e8 fe f0 ff ff       	call   8012bf <fd_lookup>
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	78 18                	js     8021e0 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8021c8:	83 ec 0c             	sub    $0xc,%esp
  8021cb:	ff 75 f4             	push   -0xc(%ebp)
  8021ce:	e8 85 f0 ff ff       	call   801258 <fd2data>
  8021d3:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8021d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d8:	e8 33 fd ff ff       	call   801f10 <_pipeisclosed>
  8021dd:	83 c4 10             	add    $0x10,%esp
}
  8021e0:	c9                   	leave  
  8021e1:	c3                   	ret    

008021e2 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8021e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e7:	c3                   	ret    

008021e8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021ee:	68 93 2c 80 00       	push   $0x802c93
  8021f3:	ff 75 0c             	push   0xc(%ebp)
  8021f6:	e8 7b e6 ff ff       	call   800876 <strcpy>
	return 0;
}
  8021fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802200:	c9                   	leave  
  802201:	c3                   	ret    

00802202 <devcons_write>:
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	57                   	push   %edi
  802206:	56                   	push   %esi
  802207:	53                   	push   %ebx
  802208:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80220e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802213:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802219:	eb 2e                	jmp    802249 <devcons_write+0x47>
		m = n - tot;
  80221b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80221e:	29 f3                	sub    %esi,%ebx
  802220:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802225:	39 c3                	cmp    %eax,%ebx
  802227:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80222a:	83 ec 04             	sub    $0x4,%esp
  80222d:	53                   	push   %ebx
  80222e:	89 f0                	mov    %esi,%eax
  802230:	03 45 0c             	add    0xc(%ebp),%eax
  802233:	50                   	push   %eax
  802234:	57                   	push   %edi
  802235:	e8 d2 e7 ff ff       	call   800a0c <memmove>
		sys_cputs(buf, m);
  80223a:	83 c4 08             	add    $0x8,%esp
  80223d:	53                   	push   %ebx
  80223e:	57                   	push   %edi
  80223f:	e8 72 e9 ff ff       	call   800bb6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802244:	01 de                	add    %ebx,%esi
  802246:	83 c4 10             	add    $0x10,%esp
  802249:	3b 75 10             	cmp    0x10(%ebp),%esi
  80224c:	72 cd                	jb     80221b <devcons_write+0x19>
}
  80224e:	89 f0                	mov    %esi,%eax
  802250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    

00802258 <devcons_read>:
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	83 ec 08             	sub    $0x8,%esp
  80225e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802263:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802267:	75 07                	jne    802270 <devcons_read+0x18>
  802269:	eb 1f                	jmp    80228a <devcons_read+0x32>
		sys_yield();
  80226b:	e8 e3 e9 ff ff       	call   800c53 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802270:	e8 5f e9 ff ff       	call   800bd4 <sys_cgetc>
  802275:	85 c0                	test   %eax,%eax
  802277:	74 f2                	je     80226b <devcons_read+0x13>
	if (c < 0)
  802279:	78 0f                	js     80228a <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80227b:	83 f8 04             	cmp    $0x4,%eax
  80227e:	74 0c                	je     80228c <devcons_read+0x34>
	*(char*)vbuf = c;
  802280:	8b 55 0c             	mov    0xc(%ebp),%edx
  802283:	88 02                	mov    %al,(%edx)
	return 1;
  802285:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80228a:	c9                   	leave  
  80228b:	c3                   	ret    
		return 0;
  80228c:	b8 00 00 00 00       	mov    $0x0,%eax
  802291:	eb f7                	jmp    80228a <devcons_read+0x32>

00802293 <cputchar>:
{
  802293:	55                   	push   %ebp
  802294:	89 e5                	mov    %esp,%ebp
  802296:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802299:	8b 45 08             	mov    0x8(%ebp),%eax
  80229c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80229f:	6a 01                	push   $0x1
  8022a1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a4:	50                   	push   %eax
  8022a5:	e8 0c e9 ff ff       	call   800bb6 <sys_cputs>
}
  8022aa:	83 c4 10             	add    $0x10,%esp
  8022ad:	c9                   	leave  
  8022ae:	c3                   	ret    

008022af <getchar>:
{
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8022b5:	6a 01                	push   $0x1
  8022b7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ba:	50                   	push   %eax
  8022bb:	6a 00                	push   $0x0
  8022bd:	e8 66 f2 ff ff       	call   801528 <read>
	if (r < 0)
  8022c2:	83 c4 10             	add    $0x10,%esp
  8022c5:	85 c0                	test   %eax,%eax
  8022c7:	78 06                	js     8022cf <getchar+0x20>
	if (r < 1)
  8022c9:	74 06                	je     8022d1 <getchar+0x22>
	return c;
  8022cb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8022cf:	c9                   	leave  
  8022d0:	c3                   	ret    
		return -E_EOF;
  8022d1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8022d6:	eb f7                	jmp    8022cf <getchar+0x20>

008022d8 <iscons>:
{
  8022d8:	55                   	push   %ebp
  8022d9:	89 e5                	mov    %esp,%ebp
  8022db:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e1:	50                   	push   %eax
  8022e2:	ff 75 08             	push   0x8(%ebp)
  8022e5:	e8 d5 ef ff ff       	call   8012bf <fd_lookup>
  8022ea:	83 c4 10             	add    $0x10,%esp
  8022ed:	85 c0                	test   %eax,%eax
  8022ef:	78 11                	js     802302 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8022f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f4:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8022fa:	39 10                	cmp    %edx,(%eax)
  8022fc:	0f 94 c0             	sete   %al
  8022ff:	0f b6 c0             	movzbl %al,%eax
}
  802302:	c9                   	leave  
  802303:	c3                   	ret    

00802304 <opencons>:
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80230a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80230d:	50                   	push   %eax
  80230e:	e8 5c ef ff ff       	call   80126f <fd_alloc>
  802313:	83 c4 10             	add    $0x10,%esp
  802316:	85 c0                	test   %eax,%eax
  802318:	78 3a                	js     802354 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80231a:	83 ec 04             	sub    $0x4,%esp
  80231d:	68 07 04 00 00       	push   $0x407
  802322:	ff 75 f4             	push   -0xc(%ebp)
  802325:	6a 00                	push   $0x0
  802327:	e8 46 e9 ff ff       	call   800c72 <sys_page_alloc>
  80232c:	83 c4 10             	add    $0x10,%esp
  80232f:	85 c0                	test   %eax,%eax
  802331:	78 21                	js     802354 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802336:	8b 15 60 30 80 00    	mov    0x803060,%edx
  80233c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80233e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802341:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802348:	83 ec 0c             	sub    $0xc,%esp
  80234b:	50                   	push   %eax
  80234c:	e8 f7 ee ff ff       	call   801248 <fd2num>
  802351:	83 c4 10             	add    $0x10,%esp
}
  802354:	c9                   	leave  
  802355:	c3                   	ret    

00802356 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802356:	55                   	push   %ebp
  802357:	89 e5                	mov    %esp,%ebp
  802359:	56                   	push   %esi
  80235a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80235b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80235e:	8b 35 08 30 80 00    	mov    0x803008,%esi
  802364:	e8 cb e8 ff ff       	call   800c34 <sys_getenvid>
  802369:	83 ec 0c             	sub    $0xc,%esp
  80236c:	ff 75 0c             	push   0xc(%ebp)
  80236f:	ff 75 08             	push   0x8(%ebp)
  802372:	56                   	push   %esi
  802373:	50                   	push   %eax
  802374:	68 a0 2c 80 00       	push   $0x802ca0
  802379:	e8 1e df ff ff       	call   80029c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80237e:	83 c4 18             	add    $0x18,%esp
  802381:	53                   	push   %ebx
  802382:	ff 75 10             	push   0x10(%ebp)
  802385:	e8 c1 de ff ff       	call   80024b <vcprintf>
	cprintf("\n");
  80238a:	c7 04 24 8c 2c 80 00 	movl   $0x802c8c,(%esp)
  802391:	e8 06 df ff ff       	call   80029c <cprintf>
  802396:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802399:	cc                   	int3   
  80239a:	eb fd                	jmp    802399 <_panic+0x43>

0080239c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80239c:	55                   	push   %ebp
  80239d:	89 e5                	mov    %esp,%ebp
  80239f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8023a2:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8023a9:	74 0a                	je     8023b5 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ae:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8023b3:	c9                   	leave  
  8023b4:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8023b5:	e8 7a e8 ff ff       	call   800c34 <sys_getenvid>
  8023ba:	83 ec 04             	sub    $0x4,%esp
  8023bd:	68 07 0e 00 00       	push   $0xe07
  8023c2:	68 00 f0 bf ee       	push   $0xeebff000
  8023c7:	50                   	push   %eax
  8023c8:	e8 a5 e8 ff ff       	call   800c72 <sys_page_alloc>
		if (r < 0) {
  8023cd:	83 c4 10             	add    $0x10,%esp
  8023d0:	85 c0                	test   %eax,%eax
  8023d2:	78 2c                	js     802400 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8023d4:	e8 5b e8 ff ff       	call   800c34 <sys_getenvid>
  8023d9:	83 ec 08             	sub    $0x8,%esp
  8023dc:	68 12 24 80 00       	push   $0x802412
  8023e1:	50                   	push   %eax
  8023e2:	e8 d6 e9 ff ff       	call   800dbd <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8023e7:	83 c4 10             	add    $0x10,%esp
  8023ea:	85 c0                	test   %eax,%eax
  8023ec:	79 bd                	jns    8023ab <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  8023ee:	50                   	push   %eax
  8023ef:	68 04 2d 80 00       	push   $0x802d04
  8023f4:	6a 28                	push   $0x28
  8023f6:	68 3a 2d 80 00       	push   $0x802d3a
  8023fb:	e8 56 ff ff ff       	call   802356 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802400:	50                   	push   %eax
  802401:	68 c4 2c 80 00       	push   $0x802cc4
  802406:	6a 23                	push   $0x23
  802408:	68 3a 2d 80 00       	push   $0x802d3a
  80240d:	e8 44 ff ff ff       	call   802356 <_panic>

00802412 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802412:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802413:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802418:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80241a:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80241d:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802421:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802424:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802428:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80242c:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80242e:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802431:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802432:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802435:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802436:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802437:	c3                   	ret    

00802438 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802438:	55                   	push   %ebp
  802439:	89 e5                	mov    %esp,%ebp
  80243b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80243e:	89 c2                	mov    %eax,%edx
  802440:	c1 ea 16             	shr    $0x16,%edx
  802443:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80244a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80244f:	f6 c1 01             	test   $0x1,%cl
  802452:	74 1c                	je     802470 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802454:	c1 e8 0c             	shr    $0xc,%eax
  802457:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80245e:	a8 01                	test   $0x1,%al
  802460:	74 0e                	je     802470 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802462:	c1 e8 0c             	shr    $0xc,%eax
  802465:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80246c:	ef 
  80246d:	0f b7 d2             	movzwl %dx,%edx
}
  802470:	89 d0                	mov    %edx,%eax
  802472:	5d                   	pop    %ebp
  802473:	c3                   	ret    
  802474:	66 90                	xchg   %ax,%ax
  802476:	66 90                	xchg   %ax,%ax
  802478:	66 90                	xchg   %ax,%ax
  80247a:	66 90                	xchg   %ax,%ax
  80247c:	66 90                	xchg   %ax,%ax
  80247e:	66 90                	xchg   %ax,%ax

00802480 <__udivdi3>:
  802480:	f3 0f 1e fb          	endbr32 
  802484:	55                   	push   %ebp
  802485:	57                   	push   %edi
  802486:	56                   	push   %esi
  802487:	53                   	push   %ebx
  802488:	83 ec 1c             	sub    $0x1c,%esp
  80248b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80248f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802493:	8b 74 24 34          	mov    0x34(%esp),%esi
  802497:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80249b:	85 c0                	test   %eax,%eax
  80249d:	75 19                	jne    8024b8 <__udivdi3+0x38>
  80249f:	39 f3                	cmp    %esi,%ebx
  8024a1:	76 4d                	jbe    8024f0 <__udivdi3+0x70>
  8024a3:	31 ff                	xor    %edi,%edi
  8024a5:	89 e8                	mov    %ebp,%eax
  8024a7:	89 f2                	mov    %esi,%edx
  8024a9:	f7 f3                	div    %ebx
  8024ab:	89 fa                	mov    %edi,%edx
  8024ad:	83 c4 1c             	add    $0x1c,%esp
  8024b0:	5b                   	pop    %ebx
  8024b1:	5e                   	pop    %esi
  8024b2:	5f                   	pop    %edi
  8024b3:	5d                   	pop    %ebp
  8024b4:	c3                   	ret    
  8024b5:	8d 76 00             	lea    0x0(%esi),%esi
  8024b8:	39 f0                	cmp    %esi,%eax
  8024ba:	76 14                	jbe    8024d0 <__udivdi3+0x50>
  8024bc:	31 ff                	xor    %edi,%edi
  8024be:	31 c0                	xor    %eax,%eax
  8024c0:	89 fa                	mov    %edi,%edx
  8024c2:	83 c4 1c             	add    $0x1c,%esp
  8024c5:	5b                   	pop    %ebx
  8024c6:	5e                   	pop    %esi
  8024c7:	5f                   	pop    %edi
  8024c8:	5d                   	pop    %ebp
  8024c9:	c3                   	ret    
  8024ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d0:	0f bd f8             	bsr    %eax,%edi
  8024d3:	83 f7 1f             	xor    $0x1f,%edi
  8024d6:	75 48                	jne    802520 <__udivdi3+0xa0>
  8024d8:	39 f0                	cmp    %esi,%eax
  8024da:	72 06                	jb     8024e2 <__udivdi3+0x62>
  8024dc:	31 c0                	xor    %eax,%eax
  8024de:	39 eb                	cmp    %ebp,%ebx
  8024e0:	77 de                	ja     8024c0 <__udivdi3+0x40>
  8024e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e7:	eb d7                	jmp    8024c0 <__udivdi3+0x40>
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	89 d9                	mov    %ebx,%ecx
  8024f2:	85 db                	test   %ebx,%ebx
  8024f4:	75 0b                	jne    802501 <__udivdi3+0x81>
  8024f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	f7 f3                	div    %ebx
  8024ff:	89 c1                	mov    %eax,%ecx
  802501:	31 d2                	xor    %edx,%edx
  802503:	89 f0                	mov    %esi,%eax
  802505:	f7 f1                	div    %ecx
  802507:	89 c6                	mov    %eax,%esi
  802509:	89 e8                	mov    %ebp,%eax
  80250b:	89 f7                	mov    %esi,%edi
  80250d:	f7 f1                	div    %ecx
  80250f:	89 fa                	mov    %edi,%edx
  802511:	83 c4 1c             	add    $0x1c,%esp
  802514:	5b                   	pop    %ebx
  802515:	5e                   	pop    %esi
  802516:	5f                   	pop    %edi
  802517:	5d                   	pop    %ebp
  802518:	c3                   	ret    
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 f9                	mov    %edi,%ecx
  802522:	ba 20 00 00 00       	mov    $0x20,%edx
  802527:	29 fa                	sub    %edi,%edx
  802529:	d3 e0                	shl    %cl,%eax
  80252b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80252f:	89 d1                	mov    %edx,%ecx
  802531:	89 d8                	mov    %ebx,%eax
  802533:	d3 e8                	shr    %cl,%eax
  802535:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802539:	09 c1                	or     %eax,%ecx
  80253b:	89 f0                	mov    %esi,%eax
  80253d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802541:	89 f9                	mov    %edi,%ecx
  802543:	d3 e3                	shl    %cl,%ebx
  802545:	89 d1                	mov    %edx,%ecx
  802547:	d3 e8                	shr    %cl,%eax
  802549:	89 f9                	mov    %edi,%ecx
  80254b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80254f:	89 eb                	mov    %ebp,%ebx
  802551:	d3 e6                	shl    %cl,%esi
  802553:	89 d1                	mov    %edx,%ecx
  802555:	d3 eb                	shr    %cl,%ebx
  802557:	09 f3                	or     %esi,%ebx
  802559:	89 c6                	mov    %eax,%esi
  80255b:	89 f2                	mov    %esi,%edx
  80255d:	89 d8                	mov    %ebx,%eax
  80255f:	f7 74 24 08          	divl   0x8(%esp)
  802563:	89 d6                	mov    %edx,%esi
  802565:	89 c3                	mov    %eax,%ebx
  802567:	f7 64 24 0c          	mull   0xc(%esp)
  80256b:	39 d6                	cmp    %edx,%esi
  80256d:	72 19                	jb     802588 <__udivdi3+0x108>
  80256f:	89 f9                	mov    %edi,%ecx
  802571:	d3 e5                	shl    %cl,%ebp
  802573:	39 c5                	cmp    %eax,%ebp
  802575:	73 04                	jae    80257b <__udivdi3+0xfb>
  802577:	39 d6                	cmp    %edx,%esi
  802579:	74 0d                	je     802588 <__udivdi3+0x108>
  80257b:	89 d8                	mov    %ebx,%eax
  80257d:	31 ff                	xor    %edi,%edi
  80257f:	e9 3c ff ff ff       	jmp    8024c0 <__udivdi3+0x40>
  802584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802588:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80258b:	31 ff                	xor    %edi,%edi
  80258d:	e9 2e ff ff ff       	jmp    8024c0 <__udivdi3+0x40>
  802592:	66 90                	xchg   %ax,%ax
  802594:	66 90                	xchg   %ax,%ax
  802596:	66 90                	xchg   %ax,%ax
  802598:	66 90                	xchg   %ax,%ax
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__umoddi3>:
  8025a0:	f3 0f 1e fb          	endbr32 
  8025a4:	55                   	push   %ebp
  8025a5:	57                   	push   %edi
  8025a6:	56                   	push   %esi
  8025a7:	53                   	push   %ebx
  8025a8:	83 ec 1c             	sub    $0x1c,%esp
  8025ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025b3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8025b7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8025bb:	89 f0                	mov    %esi,%eax
  8025bd:	89 da                	mov    %ebx,%edx
  8025bf:	85 ff                	test   %edi,%edi
  8025c1:	75 15                	jne    8025d8 <__umoddi3+0x38>
  8025c3:	39 dd                	cmp    %ebx,%ebp
  8025c5:	76 39                	jbe    802600 <__umoddi3+0x60>
  8025c7:	f7 f5                	div    %ebp
  8025c9:	89 d0                	mov    %edx,%eax
  8025cb:	31 d2                	xor    %edx,%edx
  8025cd:	83 c4 1c             	add    $0x1c,%esp
  8025d0:	5b                   	pop    %ebx
  8025d1:	5e                   	pop    %esi
  8025d2:	5f                   	pop    %edi
  8025d3:	5d                   	pop    %ebp
  8025d4:	c3                   	ret    
  8025d5:	8d 76 00             	lea    0x0(%esi),%esi
  8025d8:	39 df                	cmp    %ebx,%edi
  8025da:	77 f1                	ja     8025cd <__umoddi3+0x2d>
  8025dc:	0f bd cf             	bsr    %edi,%ecx
  8025df:	83 f1 1f             	xor    $0x1f,%ecx
  8025e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8025e6:	75 40                	jne    802628 <__umoddi3+0x88>
  8025e8:	39 df                	cmp    %ebx,%edi
  8025ea:	72 04                	jb     8025f0 <__umoddi3+0x50>
  8025ec:	39 f5                	cmp    %esi,%ebp
  8025ee:	77 dd                	ja     8025cd <__umoddi3+0x2d>
  8025f0:	89 da                	mov    %ebx,%edx
  8025f2:	89 f0                	mov    %esi,%eax
  8025f4:	29 e8                	sub    %ebp,%eax
  8025f6:	19 fa                	sbb    %edi,%edx
  8025f8:	eb d3                	jmp    8025cd <__umoddi3+0x2d>
  8025fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802600:	89 e9                	mov    %ebp,%ecx
  802602:	85 ed                	test   %ebp,%ebp
  802604:	75 0b                	jne    802611 <__umoddi3+0x71>
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	f7 f5                	div    %ebp
  80260f:	89 c1                	mov    %eax,%ecx
  802611:	89 d8                	mov    %ebx,%eax
  802613:	31 d2                	xor    %edx,%edx
  802615:	f7 f1                	div    %ecx
  802617:	89 f0                	mov    %esi,%eax
  802619:	f7 f1                	div    %ecx
  80261b:	89 d0                	mov    %edx,%eax
  80261d:	31 d2                	xor    %edx,%edx
  80261f:	eb ac                	jmp    8025cd <__umoddi3+0x2d>
  802621:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802628:	8b 44 24 04          	mov    0x4(%esp),%eax
  80262c:	ba 20 00 00 00       	mov    $0x20,%edx
  802631:	29 c2                	sub    %eax,%edx
  802633:	89 c1                	mov    %eax,%ecx
  802635:	89 e8                	mov    %ebp,%eax
  802637:	d3 e7                	shl    %cl,%edi
  802639:	89 d1                	mov    %edx,%ecx
  80263b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80263f:	d3 e8                	shr    %cl,%eax
  802641:	89 c1                	mov    %eax,%ecx
  802643:	8b 44 24 04          	mov    0x4(%esp),%eax
  802647:	09 f9                	or     %edi,%ecx
  802649:	89 df                	mov    %ebx,%edi
  80264b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80264f:	89 c1                	mov    %eax,%ecx
  802651:	d3 e5                	shl    %cl,%ebp
  802653:	89 d1                	mov    %edx,%ecx
  802655:	d3 ef                	shr    %cl,%edi
  802657:	89 c1                	mov    %eax,%ecx
  802659:	89 f0                	mov    %esi,%eax
  80265b:	d3 e3                	shl    %cl,%ebx
  80265d:	89 d1                	mov    %edx,%ecx
  80265f:	89 fa                	mov    %edi,%edx
  802661:	d3 e8                	shr    %cl,%eax
  802663:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802668:	09 d8                	or     %ebx,%eax
  80266a:	f7 74 24 08          	divl   0x8(%esp)
  80266e:	89 d3                	mov    %edx,%ebx
  802670:	d3 e6                	shl    %cl,%esi
  802672:	f7 e5                	mul    %ebp
  802674:	89 c7                	mov    %eax,%edi
  802676:	89 d1                	mov    %edx,%ecx
  802678:	39 d3                	cmp    %edx,%ebx
  80267a:	72 06                	jb     802682 <__umoddi3+0xe2>
  80267c:	75 0e                	jne    80268c <__umoddi3+0xec>
  80267e:	39 c6                	cmp    %eax,%esi
  802680:	73 0a                	jae    80268c <__umoddi3+0xec>
  802682:	29 e8                	sub    %ebp,%eax
  802684:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802688:	89 d1                	mov    %edx,%ecx
  80268a:	89 c7                	mov    %eax,%edi
  80268c:	89 f5                	mov    %esi,%ebp
  80268e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802692:	29 fd                	sub    %edi,%ebp
  802694:	19 cb                	sbb    %ecx,%ebx
  802696:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80269b:	89 d8                	mov    %ebx,%eax
  80269d:	d3 e0                	shl    %cl,%eax
  80269f:	89 f1                	mov    %esi,%ecx
  8026a1:	d3 ed                	shr    %cl,%ebp
  8026a3:	d3 eb                	shr    %cl,%ebx
  8026a5:	09 e8                	or     %ebp,%eax
  8026a7:	89 da                	mov    %ebx,%edx
  8026a9:	83 c4 1c             	add    $0x1c,%esp
  8026ac:	5b                   	pop    %ebx
  8026ad:	5e                   	pop    %esi
  8026ae:	5f                   	pop    %edi
  8026af:	5d                   	pop    %ebp
  8026b0:	c3                   	ret    
