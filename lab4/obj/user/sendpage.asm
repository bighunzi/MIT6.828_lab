
obj/user/sendpage：     文件格式 elf32-i386


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
  800039:	e8 d6 0e 00 00       	call   800f14 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 84 a5 00 00 00    	je     8000ee <umain+0xbb>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800049:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80004e:	8b 40 48             	mov    0x48(%eax),%eax
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 a0 00       	push   $0xa00000
  80005b:	50                   	push   %eax
  80005c:	e8 06 0c 00 00       	call   800c67 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800061:	83 c4 04             	add    $0x4,%esp
  800064:	ff 35 04 20 80 00    	push   0x802004
  80006a:	e8 c1 07 00 00       	call   800830 <strlen>
  80006f:	83 c4 0c             	add    $0xc,%esp
  800072:	83 c0 01             	add    $0x1,%eax
  800075:	50                   	push   %eax
  800076:	ff 35 04 20 80 00    	push   0x802004
  80007c:	68 00 00 a0 00       	push   $0xa00000
  800081:	e8 dd 09 00 00       	call   800a63 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800086:	6a 07                	push   $0x7
  800088:	68 00 00 a0 00       	push   $0xa00000
  80008d:	6a 00                	push   $0x0
  80008f:	ff 75 f4             	push   -0xc(%ebp)
  800092:	e8 52 10 00 00       	call   8010e9 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800097:	83 c4 1c             	add    $0x1c,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	68 00 00 a0 00       	push   $0xa00000
  8000a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a4:	50                   	push   %eax
  8000a5:	e8 d8 0f 00 00       	call   801082 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000aa:	83 c4 0c             	add    $0xc,%esp
  8000ad:	68 00 00 a0 00       	push   $0xa00000
  8000b2:	ff 75 f4             	push   -0xc(%ebp)
  8000b5:	68 a0 14 80 00       	push   $0x8014a0
  8000ba:	e8 d2 01 00 00       	call   800291 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000bf:	83 c4 04             	add    $0x4,%esp
  8000c2:	ff 35 00 20 80 00    	push   0x802000
  8000c8:	e8 63 07 00 00       	call   800830 <strlen>
  8000cd:	83 c4 0c             	add    $0xc,%esp
  8000d0:	50                   	push   %eax
  8000d1:	ff 35 00 20 80 00    	push   0x802000
  8000d7:	68 00 00 a0 00       	push   $0xa00000
  8000dc:	e8 61 08 00 00       	call   800942 <strncmp>
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
  8000fc:	e8 81 0f 00 00       	call   801082 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800101:	83 c4 0c             	add    $0xc,%esp
  800104:	68 00 00 b0 00       	push   $0xb00000
  800109:	ff 75 f4             	push   -0xc(%ebp)
  80010c:	68 a0 14 80 00       	push   $0x8014a0
  800111:	e8 7b 01 00 00       	call   800291 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800116:	83 c4 04             	add    $0x4,%esp
  800119:	ff 35 04 20 80 00    	push   0x802004
  80011f:	e8 0c 07 00 00       	call   800830 <strlen>
  800124:	83 c4 0c             	add    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	ff 35 04 20 80 00    	push   0x802004
  80012e:	68 00 00 b0 00       	push   $0xb00000
  800133:	e8 0a 08 00 00       	call   800942 <strncmp>
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	85 c0                	test   %eax,%eax
  80013d:	74 3e                	je     80017d <umain+0x14a>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	ff 35 00 20 80 00    	push   0x802000
  800148:	e8 e3 06 00 00       	call   800830 <strlen>
  80014d:	83 c4 0c             	add    $0xc,%esp
  800150:	83 c0 01             	add    $0x1,%eax
  800153:	50                   	push   %eax
  800154:	ff 35 00 20 80 00    	push   0x802000
  80015a:	68 00 00 b0 00       	push   $0xb00000
  80015f:	e8 ff 08 00 00       	call   800a63 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800164:	6a 07                	push   $0x7
  800166:	68 00 00 b0 00       	push   $0xb00000
  80016b:	6a 00                	push   $0x0
  80016d:	ff 75 f4             	push   -0xc(%ebp)
  800170:	e8 74 0f 00 00       	call   8010e9 <ipc_send>
		return;
  800175:	83 c4 20             	add    $0x20,%esp
  800178:	e9 6f ff ff ff       	jmp    8000ec <umain+0xb9>
			cprintf("child received correct message\n");
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	68 b4 14 80 00       	push   $0x8014b4
  800185:	e8 07 01 00 00       	call   800291 <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	eb b0                	jmp    80013f <umain+0x10c>
		cprintf("parent received correct message\n");
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	68 d4 14 80 00       	push   $0x8014d4
  800197:	e8 f5 00 00 00       	call   800291 <cprintf>
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
  8001af:	e8 75 0a 00 00       	call   800c29 <sys_getenvid>
  8001b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c1:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c6:	85 db                	test   %ebx,%ebx
  8001c8:	7e 07                	jle    8001d1 <libmain+0x2d>
		binaryname = argv[0];
  8001ca:	8b 06                	mov    (%esi),%eax
  8001cc:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	e8 58 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001db:	e8 0a 00 00 00       	call   8001ea <exit>
}
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001f0:	6a 00                	push   $0x0
  8001f2:	e8 f1 09 00 00       	call   800be8 <sys_env_destroy>
}
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	53                   	push   %ebx
  800200:	83 ec 04             	sub    $0x4,%esp
  800203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800206:	8b 13                	mov    (%ebx),%edx
  800208:	8d 42 01             	lea    0x1(%edx),%eax
  80020b:	89 03                	mov    %eax,(%ebx)
  80020d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800210:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800214:	3d ff 00 00 00       	cmp    $0xff,%eax
  800219:	74 09                	je     800224 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80021b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800222:	c9                   	leave  
  800223:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	68 ff 00 00 00       	push   $0xff
  80022c:	8d 43 08             	lea    0x8(%ebx),%eax
  80022f:	50                   	push   %eax
  800230:	e8 76 09 00 00       	call   800bab <sys_cputs>
		b->idx = 0;
  800235:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	eb db                	jmp    80021b <putch+0x1f>

00800240 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800249:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800250:	00 00 00 
	b.cnt = 0;
  800253:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025d:	ff 75 0c             	push   0xc(%ebp)
  800260:	ff 75 08             	push   0x8(%ebp)
  800263:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800269:	50                   	push   %eax
  80026a:	68 fc 01 80 00       	push   $0x8001fc
  80026f:	e8 14 01 00 00       	call   800388 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800274:	83 c4 08             	add    $0x8,%esp
  800277:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80027d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800283:	50                   	push   %eax
  800284:	e8 22 09 00 00       	call   800bab <sys_cputs>

	return b.cnt;
}
  800289:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800297:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 08             	push   0x8(%ebp)
  80029e:	e8 9d ff ff ff       	call   800240 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 1c             	sub    $0x1c,%esp
  8002ae:	89 c7                	mov    %eax,%edi
  8002b0:	89 d6                	mov    %edx,%esi
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b8:	89 d1                	mov    %edx,%ecx
  8002ba:	89 c2                	mov    %eax,%edx
  8002bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002cb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d2:	39 c2                	cmp    %eax,%edx
  8002d4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d7:	72 3e                	jb     800317 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d9:	83 ec 0c             	sub    $0xc,%esp
  8002dc:	ff 75 18             	push   0x18(%ebp)
  8002df:	83 eb 01             	sub    $0x1,%ebx
  8002e2:	53                   	push   %ebx
  8002e3:	50                   	push   %eax
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	ff 75 e4             	push   -0x1c(%ebp)
  8002ea:	ff 75 e0             	push   -0x20(%ebp)
  8002ed:	ff 75 dc             	push   -0x24(%ebp)
  8002f0:	ff 75 d8             	push   -0x28(%ebp)
  8002f3:	e8 68 0f 00 00       	call   801260 <__udivdi3>
  8002f8:	83 c4 18             	add    $0x18,%esp
  8002fb:	52                   	push   %edx
  8002fc:	50                   	push   %eax
  8002fd:	89 f2                	mov    %esi,%edx
  8002ff:	89 f8                	mov    %edi,%eax
  800301:	e8 9f ff ff ff       	call   8002a5 <printnum>
  800306:	83 c4 20             	add    $0x20,%esp
  800309:	eb 13                	jmp    80031e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	56                   	push   %esi
  80030f:	ff 75 18             	push   0x18(%ebp)
  800312:	ff d7                	call   *%edi
  800314:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800317:	83 eb 01             	sub    $0x1,%ebx
  80031a:	85 db                	test   %ebx,%ebx
  80031c:	7f ed                	jg     80030b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031e:	83 ec 08             	sub    $0x8,%esp
  800321:	56                   	push   %esi
  800322:	83 ec 04             	sub    $0x4,%esp
  800325:	ff 75 e4             	push   -0x1c(%ebp)
  800328:	ff 75 e0             	push   -0x20(%ebp)
  80032b:	ff 75 dc             	push   -0x24(%ebp)
  80032e:	ff 75 d8             	push   -0x28(%ebp)
  800331:	e8 4a 10 00 00       	call   801380 <__umoddi3>
  800336:	83 c4 14             	add    $0x14,%esp
  800339:	0f be 80 4c 15 80 00 	movsbl 0x80154c(%eax),%eax
  800340:	50                   	push   %eax
  800341:	ff d7                	call   *%edi
}
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800354:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	3b 50 04             	cmp    0x4(%eax),%edx
  80035d:	73 0a                	jae    800369 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800362:	89 08                	mov    %ecx,(%eax)
  800364:	8b 45 08             	mov    0x8(%ebp),%eax
  800367:	88 02                	mov    %al,(%edx)
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <printfmt>:
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800371:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800374:	50                   	push   %eax
  800375:	ff 75 10             	push   0x10(%ebp)
  800378:	ff 75 0c             	push   0xc(%ebp)
  80037b:	ff 75 08             	push   0x8(%ebp)
  80037e:	e8 05 00 00 00       	call   800388 <vprintfmt>
}
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <vprintfmt>:
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	57                   	push   %edi
  80038c:	56                   	push   %esi
  80038d:	53                   	push   %ebx
  80038e:	83 ec 3c             	sub    $0x3c,%esp
  800391:	8b 75 08             	mov    0x8(%ebp),%esi
  800394:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800397:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039a:	eb 0a                	jmp    8003a6 <vprintfmt+0x1e>
			putch(ch, putdat);
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	53                   	push   %ebx
  8003a0:	50                   	push   %eax
  8003a1:	ff d6                	call   *%esi
  8003a3:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a6:	83 c7 01             	add    $0x1,%edi
  8003a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003ad:	83 f8 25             	cmp    $0x25,%eax
  8003b0:	74 0c                	je     8003be <vprintfmt+0x36>
			if (ch == '\0')
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	75 e6                	jne    80039c <vprintfmt+0x14>
}
  8003b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5f                   	pop    %edi
  8003bc:	5d                   	pop    %ebp
  8003bd:	c3                   	ret    
		padc = ' ';
  8003be:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003c2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003c9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003d0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8d 47 01             	lea    0x1(%edi),%eax
  8003df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e2:	0f b6 17             	movzbl (%edi),%edx
  8003e5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e8:	3c 55                	cmp    $0x55,%al
  8003ea:	0f 87 bb 03 00 00    	ja     8007ab <vprintfmt+0x423>
  8003f0:	0f b6 c0             	movzbl %al,%eax
  8003f3:	ff 24 85 20 16 80 00 	jmp    *0x801620(,%eax,4)
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003fd:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800401:	eb d9                	jmp    8003dc <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800406:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80040a:	eb d0                	jmp    8003dc <vprintfmt+0x54>
  80040c:	0f b6 d2             	movzbl %dl,%edx
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800412:	b8 00 00 00 00       	mov    $0x0,%eax
  800417:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80041a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800421:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800424:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800427:	83 f9 09             	cmp    $0x9,%ecx
  80042a:	77 55                	ja     800481 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80042c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80042f:	eb e9                	jmp    80041a <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8b 00                	mov    (%eax),%eax
  800436:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 40 04             	lea    0x4(%eax),%eax
  80043f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800445:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800449:	79 91                	jns    8003dc <vprintfmt+0x54>
				width = precision, precision = -1;
  80044b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80044e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800451:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800458:	eb 82                	jmp    8003dc <vprintfmt+0x54>
  80045a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80045d:	85 d2                	test   %edx,%edx
  80045f:	b8 00 00 00 00       	mov    $0x0,%eax
  800464:	0f 49 c2             	cmovns %edx,%eax
  800467:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80046d:	e9 6a ff ff ff       	jmp    8003dc <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800475:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80047c:	e9 5b ff ff ff       	jmp    8003dc <vprintfmt+0x54>
  800481:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800484:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800487:	eb bc                	jmp    800445 <vprintfmt+0xbd>
			lflag++;
  800489:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80048f:	e9 48 ff ff ff       	jmp    8003dc <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 78 04             	lea    0x4(%eax),%edi
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	53                   	push   %ebx
  80049e:	ff 30                	push   (%eax)
  8004a0:	ff d6                	call   *%esi
			break;
  8004a2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004a5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004a8:	e9 9d 02 00 00       	jmp    80074a <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 78 04             	lea    0x4(%eax),%edi
  8004b3:	8b 10                	mov    (%eax),%edx
  8004b5:	89 d0                	mov    %edx,%eax
  8004b7:	f7 d8                	neg    %eax
  8004b9:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004bc:	83 f8 08             	cmp    $0x8,%eax
  8004bf:	7f 23                	jg     8004e4 <vprintfmt+0x15c>
  8004c1:	8b 14 85 80 17 80 00 	mov    0x801780(,%eax,4),%edx
  8004c8:	85 d2                	test   %edx,%edx
  8004ca:	74 18                	je     8004e4 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004cc:	52                   	push   %edx
  8004cd:	68 6d 15 80 00       	push   $0x80156d
  8004d2:	53                   	push   %ebx
  8004d3:	56                   	push   %esi
  8004d4:	e8 92 fe ff ff       	call   80036b <printfmt>
  8004d9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004dc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004df:	e9 66 02 00 00       	jmp    80074a <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004e4:	50                   	push   %eax
  8004e5:	68 64 15 80 00       	push   $0x801564
  8004ea:	53                   	push   %ebx
  8004eb:	56                   	push   %esi
  8004ec:	e8 7a fe ff ff       	call   80036b <printfmt>
  8004f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004f7:	e9 4e 02 00 00       	jmp    80074a <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	83 c0 04             	add    $0x4,%eax
  800502:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80050a:	85 d2                	test   %edx,%edx
  80050c:	b8 5d 15 80 00       	mov    $0x80155d,%eax
  800511:	0f 45 c2             	cmovne %edx,%eax
  800514:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800517:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051b:	7e 06                	jle    800523 <vprintfmt+0x19b>
  80051d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800521:	75 0d                	jne    800530 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800526:	89 c7                	mov    %eax,%edi
  800528:	03 45 e0             	add    -0x20(%ebp),%eax
  80052b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052e:	eb 55                	jmp    800585 <vprintfmt+0x1fd>
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	ff 75 d8             	push   -0x28(%ebp)
  800536:	ff 75 cc             	push   -0x34(%ebp)
  800539:	e8 0a 03 00 00       	call   800848 <strnlen>
  80053e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800541:	29 c1                	sub    %eax,%ecx
  800543:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80054b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80054f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800552:	eb 0f                	jmp    800563 <vprintfmt+0x1db>
					putch(padc, putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	53                   	push   %ebx
  800558:	ff 75 e0             	push   -0x20(%ebp)
  80055b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80055d:	83 ef 01             	sub    $0x1,%edi
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	85 ff                	test   %edi,%edi
  800565:	7f ed                	jg     800554 <vprintfmt+0x1cc>
  800567:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80056a:	85 d2                	test   %edx,%edx
  80056c:	b8 00 00 00 00       	mov    $0x0,%eax
  800571:	0f 49 c2             	cmovns %edx,%eax
  800574:	29 c2                	sub    %eax,%edx
  800576:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800579:	eb a8                	jmp    800523 <vprintfmt+0x19b>
					putch(ch, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	53                   	push   %ebx
  80057f:	52                   	push   %edx
  800580:	ff d6                	call   *%esi
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800588:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058a:	83 c7 01             	add    $0x1,%edi
  80058d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800591:	0f be d0             	movsbl %al,%edx
  800594:	85 d2                	test   %edx,%edx
  800596:	74 4b                	je     8005e3 <vprintfmt+0x25b>
  800598:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059c:	78 06                	js     8005a4 <vprintfmt+0x21c>
  80059e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005a2:	78 1e                	js     8005c2 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005a8:	74 d1                	je     80057b <vprintfmt+0x1f3>
  8005aa:	0f be c0             	movsbl %al,%eax
  8005ad:	83 e8 20             	sub    $0x20,%eax
  8005b0:	83 f8 5e             	cmp    $0x5e,%eax
  8005b3:	76 c6                	jbe    80057b <vprintfmt+0x1f3>
					putch('?', putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	6a 3f                	push   $0x3f
  8005bb:	ff d6                	call   *%esi
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	eb c3                	jmp    800585 <vprintfmt+0x1fd>
  8005c2:	89 cf                	mov    %ecx,%edi
  8005c4:	eb 0e                	jmp    8005d4 <vprintfmt+0x24c>
				putch(' ', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 20                	push   $0x20
  8005cc:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005ce:	83 ef 01             	sub    $0x1,%edi
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	85 ff                	test   %edi,%edi
  8005d6:	7f ee                	jg     8005c6 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005d8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
  8005de:	e9 67 01 00 00       	jmp    80074a <vprintfmt+0x3c2>
  8005e3:	89 cf                	mov    %ecx,%edi
  8005e5:	eb ed                	jmp    8005d4 <vprintfmt+0x24c>
	if (lflag >= 2)
  8005e7:	83 f9 01             	cmp    $0x1,%ecx
  8005ea:	7f 1b                	jg     800607 <vprintfmt+0x27f>
	else if (lflag)
  8005ec:	85 c9                	test   %ecx,%ecx
  8005ee:	74 63                	je     800653 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	99                   	cltd   
  8005f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
  800605:	eb 17                	jmp    80061e <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8b 50 04             	mov    0x4(%eax),%edx
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800612:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 40 08             	lea    0x8(%eax),%eax
  80061b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80061e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800621:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800624:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800629:	85 c9                	test   %ecx,%ecx
  80062b:	0f 89 ff 00 00 00    	jns    800730 <vprintfmt+0x3a8>
				putch('-', putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 2d                	push   $0x2d
  800637:	ff d6                	call   *%esi
				num = -(long long) num;
  800639:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063f:	f7 da                	neg    %edx
  800641:	83 d1 00             	adc    $0x0,%ecx
  800644:	f7 d9                	neg    %ecx
  800646:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800649:	bf 0a 00 00 00       	mov    $0xa,%edi
  80064e:	e9 dd 00 00 00       	jmp    800730 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 00                	mov    (%eax),%eax
  800658:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065b:	99                   	cltd   
  80065c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
  800668:	eb b4                	jmp    80061e <vprintfmt+0x296>
	if (lflag >= 2)
  80066a:	83 f9 01             	cmp    $0x1,%ecx
  80066d:	7f 1e                	jg     80068d <vprintfmt+0x305>
	else if (lflag)
  80066f:	85 c9                	test   %ecx,%ecx
  800671:	74 32                	je     8006a5 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800683:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800688:	e9 a3 00 00 00       	jmp    800730 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 10                	mov    (%eax),%edx
  800692:	8b 48 04             	mov    0x4(%eax),%ecx
  800695:	8d 40 08             	lea    0x8(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80069b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8006a0:	e9 8b 00 00 00       	jmp    800730 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8006ba:	eb 74                	jmp    800730 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8006bc:	83 f9 01             	cmp    $0x1,%ecx
  8006bf:	7f 1b                	jg     8006dc <vprintfmt+0x354>
	else if (lflag)
  8006c1:	85 c9                	test   %ecx,%ecx
  8006c3:	74 2c                	je     8006f1 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cf:	8d 40 04             	lea    0x4(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006d5:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8006da:	eb 54                	jmp    800730 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e4:	8d 40 08             	lea    0x8(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006ea:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8006ef:	eb 3f                	jmp    800730 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8b 10                	mov    (%eax),%edx
  8006f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800701:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800706:	eb 28                	jmp    800730 <vprintfmt+0x3a8>
			putch('0', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 30                	push   $0x30
  80070e:	ff d6                	call   *%esi
			putch('x', putdat);
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	6a 78                	push   $0x78
  800716:	ff d6                	call   *%esi
			num = (unsigned long long)
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8b 10                	mov    (%eax),%edx
  80071d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800722:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800725:	8d 40 04             	lea    0x4(%eax),%eax
  800728:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072b:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800737:	50                   	push   %eax
  800738:	ff 75 e0             	push   -0x20(%ebp)
  80073b:	57                   	push   %edi
  80073c:	51                   	push   %ecx
  80073d:	52                   	push   %edx
  80073e:	89 da                	mov    %ebx,%edx
  800740:	89 f0                	mov    %esi,%eax
  800742:	e8 5e fb ff ff       	call   8002a5 <printnum>
			break;
  800747:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80074a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80074d:	e9 54 fc ff ff       	jmp    8003a6 <vprintfmt+0x1e>
	if (lflag >= 2)
  800752:	83 f9 01             	cmp    $0x1,%ecx
  800755:	7f 1b                	jg     800772 <vprintfmt+0x3ea>
	else if (lflag)
  800757:	85 c9                	test   %ecx,%ecx
  800759:	74 2c                	je     800787 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8b 10                	mov    (%eax),%edx
  800760:	b9 00 00 00 00       	mov    $0x0,%ecx
  800765:	8d 40 04             	lea    0x4(%eax),%eax
  800768:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800770:	eb be                	jmp    800730 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8b 10                	mov    (%eax),%edx
  800777:	8b 48 04             	mov    0x4(%eax),%ecx
  80077a:	8d 40 08             	lea    0x8(%eax),%eax
  80077d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800780:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800785:	eb a9                	jmp    800730 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8b 10                	mov    (%eax),%edx
  80078c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800791:	8d 40 04             	lea    0x4(%eax),%eax
  800794:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800797:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80079c:	eb 92                	jmp    800730 <vprintfmt+0x3a8>
			putch(ch, putdat);
  80079e:	83 ec 08             	sub    $0x8,%esp
  8007a1:	53                   	push   %ebx
  8007a2:	6a 25                	push   $0x25
  8007a4:	ff d6                	call   *%esi
			break;
  8007a6:	83 c4 10             	add    $0x10,%esp
  8007a9:	eb 9f                	jmp    80074a <vprintfmt+0x3c2>
			putch('%', putdat);
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	53                   	push   %ebx
  8007af:	6a 25                	push   $0x25
  8007b1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	89 f8                	mov    %edi,%eax
  8007b8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007bc:	74 05                	je     8007c3 <vprintfmt+0x43b>
  8007be:	83 e8 01             	sub    $0x1,%eax
  8007c1:	eb f5                	jmp    8007b8 <vprintfmt+0x430>
  8007c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007c6:	eb 82                	jmp    80074a <vprintfmt+0x3c2>

008007c8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 18             	sub    $0x18,%esp
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007db:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	74 26                	je     80080f <vsnprintf+0x47>
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	7e 22                	jle    80080f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ed:	ff 75 14             	push   0x14(%ebp)
  8007f0:	ff 75 10             	push   0x10(%ebp)
  8007f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f6:	50                   	push   %eax
  8007f7:	68 4e 03 80 00       	push   $0x80034e
  8007fc:	e8 87 fb ff ff       	call   800388 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800801:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800804:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800807:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080a:	83 c4 10             	add    $0x10,%esp
}
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    
		return -E_INVAL;
  80080f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800814:	eb f7                	jmp    80080d <vsnprintf+0x45>

00800816 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081f:	50                   	push   %eax
  800820:	ff 75 10             	push   0x10(%ebp)
  800823:	ff 75 0c             	push   0xc(%ebp)
  800826:	ff 75 08             	push   0x8(%ebp)
  800829:	e8 9a ff ff ff       	call   8007c8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 03                	jmp    800840 <strlen+0x10>
		n++;
  80083d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800844:	75 f7                	jne    80083d <strlen+0xd>
	return n;
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
  800856:	eb 03                	jmp    80085b <strnlen+0x13>
		n++;
  800858:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	39 d0                	cmp    %edx,%eax
  80085d:	74 08                	je     800867 <strnlen+0x1f>
  80085f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800863:	75 f3                	jne    800858 <strnlen+0x10>
  800865:	89 c2                	mov    %eax,%edx
	return n;
}
  800867:	89 d0                	mov    %edx,%eax
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800872:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
  80087a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80087e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800881:	83 c0 01             	add    $0x1,%eax
  800884:	84 d2                	test   %dl,%dl
  800886:	75 f2                	jne    80087a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800888:	89 c8                	mov    %ecx,%eax
  80088a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	53                   	push   %ebx
  800893:	83 ec 10             	sub    $0x10,%esp
  800896:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800899:	53                   	push   %ebx
  80089a:	e8 91 ff ff ff       	call   800830 <strlen>
  80089f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008a2:	ff 75 0c             	push   0xc(%ebp)
  8008a5:	01 d8                	add    %ebx,%eax
  8008a7:	50                   	push   %eax
  8008a8:	e8 be ff ff ff       	call   80086b <strcpy>
	return dst;
}
  8008ad:	89 d8                	mov    %ebx,%eax
  8008af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	56                   	push   %esi
  8008b8:	53                   	push   %ebx
  8008b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bf:	89 f3                	mov    %esi,%ebx
  8008c1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c4:	89 f0                	mov    %esi,%eax
  8008c6:	eb 0f                	jmp    8008d7 <strncpy+0x23>
		*dst++ = *src;
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	0f b6 0a             	movzbl (%edx),%ecx
  8008ce:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d1:	80 f9 01             	cmp    $0x1,%cl
  8008d4:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008d7:	39 d8                	cmp    %ebx,%eax
  8008d9:	75 ed                	jne    8008c8 <strncpy+0x14>
	}
	return ret;
}
  8008db:	89 f0                	mov    %esi,%eax
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ec:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ef:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	74 21                	je     800916 <strlcpy+0x35>
  8008f5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f9:	89 f2                	mov    %esi,%edx
  8008fb:	eb 09                	jmp    800906 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008fd:	83 c1 01             	add    $0x1,%ecx
  800900:	83 c2 01             	add    $0x1,%edx
  800903:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800906:	39 c2                	cmp    %eax,%edx
  800908:	74 09                	je     800913 <strlcpy+0x32>
  80090a:	0f b6 19             	movzbl (%ecx),%ebx
  80090d:	84 db                	test   %bl,%bl
  80090f:	75 ec                	jne    8008fd <strlcpy+0x1c>
  800911:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800913:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800916:	29 f0                	sub    %esi,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800925:	eb 06                	jmp    80092d <strcmp+0x11>
		p++, q++;
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80092d:	0f b6 01             	movzbl (%ecx),%eax
  800930:	84 c0                	test   %al,%al
  800932:	74 04                	je     800938 <strcmp+0x1c>
  800934:	3a 02                	cmp    (%edx),%al
  800936:	74 ef                	je     800927 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800938:	0f b6 c0             	movzbl %al,%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 c3                	mov    %eax,%ebx
  80094e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800951:	eb 06                	jmp    800959 <strncmp+0x17>
		n--, p++, q++;
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800959:	39 d8                	cmp    %ebx,%eax
  80095b:	74 18                	je     800975 <strncmp+0x33>
  80095d:	0f b6 08             	movzbl (%eax),%ecx
  800960:	84 c9                	test   %cl,%cl
  800962:	74 04                	je     800968 <strncmp+0x26>
  800964:	3a 0a                	cmp    (%edx),%cl
  800966:	74 eb                	je     800953 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800973:	c9                   	leave  
  800974:	c3                   	ret    
		return 0;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
  80097a:	eb f4                	jmp    800970 <strncmp+0x2e>

0080097c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800986:	eb 03                	jmp    80098b <strchr+0xf>
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	0f b6 10             	movzbl (%eax),%edx
  80098e:	84 d2                	test   %dl,%dl
  800990:	74 06                	je     800998 <strchr+0x1c>
		if (*s == c)
  800992:	38 ca                	cmp    %cl,%dl
  800994:	75 f2                	jne    800988 <strchr+0xc>
  800996:	eb 05                	jmp    80099d <strchr+0x21>
			return (char *) s;
	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	74 09                	je     8009b9 <strfind+0x1a>
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	74 05                	je     8009b9 <strfind+0x1a>
	for (; *s; s++)
  8009b4:	83 c0 01             	add    $0x1,%eax
  8009b7:	eb f0                	jmp    8009a9 <strfind+0xa>
			break;
	return (char *) s;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c7:	85 c9                	test   %ecx,%ecx
  8009c9:	74 2f                	je     8009fa <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cb:	89 f8                	mov    %edi,%eax
  8009cd:	09 c8                	or     %ecx,%eax
  8009cf:	a8 03                	test   $0x3,%al
  8009d1:	75 21                	jne    8009f4 <memset+0x39>
		c &= 0xFF;
  8009d3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d7:	89 d0                	mov    %edx,%eax
  8009d9:	c1 e0 08             	shl    $0x8,%eax
  8009dc:	89 d3                	mov    %edx,%ebx
  8009de:	c1 e3 18             	shl    $0x18,%ebx
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 10             	shl    $0x10,%esi
  8009e6:	09 f3                	or     %esi,%ebx
  8009e8:	09 da                	or     %ebx,%edx
  8009ea:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ec:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ef:	fc                   	cld    
  8009f0:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f2:	eb 06                	jmp    8009fa <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f7:	fc                   	cld    
  8009f8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fa:	89 f8                	mov    %edi,%eax
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	57                   	push   %edi
  800a05:	56                   	push   %esi
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0f:	39 c6                	cmp    %eax,%esi
  800a11:	73 32                	jae    800a45 <memmove+0x44>
  800a13:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a16:	39 c2                	cmp    %eax,%edx
  800a18:	76 2b                	jbe    800a45 <memmove+0x44>
		s += n;
		d += n;
  800a1a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1d:	89 d6                	mov    %edx,%esi
  800a1f:	09 fe                	or     %edi,%esi
  800a21:	09 ce                	or     %ecx,%esi
  800a23:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a29:	75 0e                	jne    800a39 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a2b:	83 ef 04             	sub    $0x4,%edi
  800a2e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a31:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a34:	fd                   	std    
  800a35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a37:	eb 09                	jmp    800a42 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a39:	83 ef 01             	sub    $0x1,%edi
  800a3c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a3f:	fd                   	std    
  800a40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a42:	fc                   	cld    
  800a43:	eb 1a                	jmp    800a5f <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a45:	89 f2                	mov    %esi,%edx
  800a47:	09 c2                	or     %eax,%edx
  800a49:	09 ca                	or     %ecx,%edx
  800a4b:	f6 c2 03             	test   $0x3,%dl
  800a4e:	75 0a                	jne    800a5a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a50:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a53:	89 c7                	mov    %eax,%edi
  800a55:	fc                   	cld    
  800a56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a58:	eb 05                	jmp    800a5f <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a5a:	89 c7                	mov    %eax,%edi
  800a5c:	fc                   	cld    
  800a5d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a69:	ff 75 10             	push   0x10(%ebp)
  800a6c:	ff 75 0c             	push   0xc(%ebp)
  800a6f:	ff 75 08             	push   0x8(%ebp)
  800a72:	e8 8a ff ff ff       	call   800a01 <memmove>
}
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a84:	89 c6                	mov    %eax,%esi
  800a86:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a89:	eb 06                	jmp    800a91 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a8b:	83 c0 01             	add    $0x1,%eax
  800a8e:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a91:	39 f0                	cmp    %esi,%eax
  800a93:	74 14                	je     800aa9 <memcmp+0x30>
		if (*s1 != *s2)
  800a95:	0f b6 08             	movzbl (%eax),%ecx
  800a98:	0f b6 1a             	movzbl (%edx),%ebx
  800a9b:	38 d9                	cmp    %bl,%cl
  800a9d:	74 ec                	je     800a8b <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a9f:	0f b6 c1             	movzbl %cl,%eax
  800aa2:	0f b6 db             	movzbl %bl,%ebx
  800aa5:	29 d8                	sub    %ebx,%eax
  800aa7:	eb 05                	jmp    800aae <memcmp+0x35>
	}

	return 0;
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800abb:	89 c2                	mov    %eax,%edx
  800abd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac0:	eb 03                	jmp    800ac5 <memfind+0x13>
  800ac2:	83 c0 01             	add    $0x1,%eax
  800ac5:	39 d0                	cmp    %edx,%eax
  800ac7:	73 04                	jae    800acd <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac9:	38 08                	cmp    %cl,(%eax)
  800acb:	75 f5                	jne    800ac2 <memfind+0x10>
			break;
	return (void *) s;
}
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adb:	eb 03                	jmp    800ae0 <strtol+0x11>
		s++;
  800add:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800ae0:	0f b6 02             	movzbl (%edx),%eax
  800ae3:	3c 20                	cmp    $0x20,%al
  800ae5:	74 f6                	je     800add <strtol+0xe>
  800ae7:	3c 09                	cmp    $0x9,%al
  800ae9:	74 f2                	je     800add <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800aeb:	3c 2b                	cmp    $0x2b,%al
  800aed:	74 2a                	je     800b19 <strtol+0x4a>
	int neg = 0;
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800af4:	3c 2d                	cmp    $0x2d,%al
  800af6:	74 2b                	je     800b23 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afe:	75 0f                	jne    800b0f <strtol+0x40>
  800b00:	80 3a 30             	cmpb   $0x30,(%edx)
  800b03:	74 28                	je     800b2d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b05:	85 db                	test   %ebx,%ebx
  800b07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0c:	0f 44 d8             	cmove  %eax,%ebx
  800b0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b14:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b17:	eb 46                	jmp    800b5f <strtol+0x90>
		s++;
  800b19:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b21:	eb d5                	jmp    800af8 <strtol+0x29>
		s++, neg = 1;
  800b23:	83 c2 01             	add    $0x1,%edx
  800b26:	bf 01 00 00 00       	mov    $0x1,%edi
  800b2b:	eb cb                	jmp    800af8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b31:	74 0e                	je     800b41 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b33:	85 db                	test   %ebx,%ebx
  800b35:	75 d8                	jne    800b0f <strtol+0x40>
		s++, base = 8;
  800b37:	83 c2 01             	add    $0x1,%edx
  800b3a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b3f:	eb ce                	jmp    800b0f <strtol+0x40>
		s += 2, base = 16;
  800b41:	83 c2 02             	add    $0x2,%edx
  800b44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b49:	eb c4                	jmp    800b0f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b4b:	0f be c0             	movsbl %al,%eax
  800b4e:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b51:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b54:	7d 3a                	jge    800b90 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b56:	83 c2 01             	add    $0x1,%edx
  800b59:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b5d:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b5f:	0f b6 02             	movzbl (%edx),%eax
  800b62:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b65:	89 f3                	mov    %esi,%ebx
  800b67:	80 fb 09             	cmp    $0x9,%bl
  800b6a:	76 df                	jbe    800b4b <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b6c:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b6f:	89 f3                	mov    %esi,%ebx
  800b71:	80 fb 19             	cmp    $0x19,%bl
  800b74:	77 08                	ja     800b7e <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b76:	0f be c0             	movsbl %al,%eax
  800b79:	83 e8 57             	sub    $0x57,%eax
  800b7c:	eb d3                	jmp    800b51 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b7e:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b81:	89 f3                	mov    %esi,%ebx
  800b83:	80 fb 19             	cmp    $0x19,%bl
  800b86:	77 08                	ja     800b90 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b88:	0f be c0             	movsbl %al,%eax
  800b8b:	83 e8 37             	sub    $0x37,%eax
  800b8e:	eb c1                	jmp    800b51 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b94:	74 05                	je     800b9b <strtol+0xcc>
		*endptr = (char *) s;
  800b96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b99:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b9b:	89 c8                	mov    %ecx,%eax
  800b9d:	f7 d8                	neg    %eax
  800b9f:	85 ff                	test   %edi,%edi
  800ba1:	0f 45 c8             	cmovne %eax,%ecx
}
  800ba4:	89 c8                	mov    %ecx,%eax
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	89 c3                	mov    %eax,%ebx
  800bbe:	89 c7                	mov    %eax,%edi
  800bc0:	89 c6                	mov    %eax,%esi
  800bc2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd4:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd9:	89 d1                	mov    %edx,%ecx
  800bdb:	89 d3                	mov    %edx,%ebx
  800bdd:	89 d7                	mov    %edx,%edi
  800bdf:	89 d6                	mov    %edx,%esi
  800be1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bfe:	89 cb                	mov    %ecx,%ebx
  800c00:	89 cf                	mov    %ecx,%edi
  800c02:	89 ce                	mov    %ecx,%esi
  800c04:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7f 08                	jg     800c12 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	50                   	push   %eax
  800c16:	6a 03                	push   $0x3
  800c18:	68 a4 17 80 00       	push   $0x8017a4
  800c1d:	6a 2a                	push   $0x2a
  800c1f:	68 c1 17 80 00       	push   $0x8017c1
  800c24:	e8 4d 05 00 00       	call   801176 <_panic>

00800c29 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c34:	b8 02 00 00 00       	mov    $0x2,%eax
  800c39:	89 d1                	mov    %edx,%ecx
  800c3b:	89 d3                	mov    %edx,%ebx
  800c3d:	89 d7                	mov    %edx,%edi
  800c3f:	89 d6                	mov    %edx,%esi
  800c41:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_yield>:

void
sys_yield(void)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c58:	89 d1                	mov    %edx,%ecx
  800c5a:	89 d3                	mov    %edx,%ebx
  800c5c:	89 d7                	mov    %edx,%edi
  800c5e:	89 d6                	mov    %edx,%esi
  800c60:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c70:	be 00 00 00 00       	mov    $0x0,%esi
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c83:	89 f7                	mov    %esi,%edi
  800c85:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7f 08                	jg     800c93 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	50                   	push   %eax
  800c97:	6a 04                	push   $0x4
  800c99:	68 a4 17 80 00       	push   $0x8017a4
  800c9e:	6a 2a                	push   $0x2a
  800ca0:	68 c1 17 80 00       	push   $0x8017c1
  800ca5:	e8 cc 04 00 00       	call   801176 <_panic>

00800caa <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7f 08                	jg     800cd5 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	6a 05                	push   $0x5
  800cdb:	68 a4 17 80 00       	push   $0x8017a4
  800ce0:	6a 2a                	push   $0x2a
  800ce2:	68 c1 17 80 00       	push   $0x8017c1
  800ce7:	e8 8a 04 00 00       	call   801176 <_panic>

00800cec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	b8 06 00 00 00       	mov    $0x6,%eax
  800d05:	89 df                	mov    %ebx,%edi
  800d07:	89 de                	mov    %ebx,%esi
  800d09:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	7f 08                	jg     800d17 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	50                   	push   %eax
  800d1b:	6a 06                	push   $0x6
  800d1d:	68 a4 17 80 00       	push   $0x8017a4
  800d22:	6a 2a                	push   $0x2a
  800d24:	68 c1 17 80 00       	push   $0x8017c1
  800d29:	e8 48 04 00 00       	call   801176 <_panic>

00800d2e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	b8 08 00 00 00       	mov    $0x8,%eax
  800d47:	89 df                	mov    %ebx,%edi
  800d49:	89 de                	mov    %ebx,%esi
  800d4b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7f 08                	jg     800d59 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	50                   	push   %eax
  800d5d:	6a 08                	push   $0x8
  800d5f:	68 a4 17 80 00       	push   $0x8017a4
  800d64:	6a 2a                	push   $0x2a
  800d66:	68 c1 17 80 00       	push   $0x8017c1
  800d6b:	e8 06 04 00 00       	call   801176 <_panic>

00800d70 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d84:	b8 09 00 00 00       	mov    $0x9,%eax
  800d89:	89 df                	mov    %ebx,%edi
  800d8b:	89 de                	mov    %ebx,%esi
  800d8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	7f 08                	jg     800d9b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	50                   	push   %eax
  800d9f:	6a 09                	push   $0x9
  800da1:	68 a4 17 80 00       	push   $0x8017a4
  800da6:	6a 2a                	push   $0x2a
  800da8:	68 c1 17 80 00       	push   $0x8017c1
  800dad:	e8 c4 03 00 00       	call   801176 <_panic>

00800db2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc3:	be 00 00 00 00       	mov    $0x0,%esi
  800dc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dce:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	57                   	push   %edi
  800dd9:	56                   	push   %esi
  800dda:	53                   	push   %ebx
  800ddb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800deb:	89 cb                	mov    %ecx,%ebx
  800ded:	89 cf                	mov    %ecx,%edi
  800def:	89 ce                	mov    %ecx,%esi
  800df1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7f 08                	jg     800dff <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	50                   	push   %eax
  800e03:	6a 0c                	push   $0xc
  800e05:	68 a4 17 80 00       	push   $0x8017a4
  800e0a:	6a 2a                	push   $0x2a
  800e0c:	68 c1 17 80 00       	push   $0x8017c1
  800e11:	e8 60 03 00 00       	call   801176 <_panic>

00800e16 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	56                   	push   %esi
  800e1a:	53                   	push   %ebx
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e1e:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e20:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e24:	0f 84 8e 00 00 00    	je     800eb8 <pgfault+0xa2>
  800e2a:	89 f0                	mov    %esi,%eax
  800e2c:	c1 e8 0c             	shr    $0xc,%eax
  800e2f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e36:	f6 c4 08             	test   $0x8,%ah
  800e39:	74 7d                	je     800eb8 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e3b:	e8 e9 fd ff ff       	call   800c29 <sys_getenvid>
  800e40:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e42:	83 ec 04             	sub    $0x4,%esp
  800e45:	6a 07                	push   $0x7
  800e47:	68 00 f0 7f 00       	push   $0x7ff000
  800e4c:	50                   	push   %eax
  800e4d:	e8 15 fe ff ff       	call   800c67 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e52:	83 c4 10             	add    $0x10,%esp
  800e55:	85 c0                	test   %eax,%eax
  800e57:	78 73                	js     800ecc <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e59:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	68 00 10 00 00       	push   $0x1000
  800e67:	56                   	push   %esi
  800e68:	68 00 f0 7f 00       	push   $0x7ff000
  800e6d:	e8 8f fb ff ff       	call   800a01 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e72:	83 c4 08             	add    $0x8,%esp
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
  800e77:	e8 70 fe ff ff       	call   800cec <sys_page_unmap>
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	78 5b                	js     800ede <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	6a 07                	push   $0x7
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	68 00 f0 7f 00       	push   $0x7ff000
  800e8f:	53                   	push   %ebx
  800e90:	e8 15 fe ff ff       	call   800caa <sys_page_map>
  800e95:	83 c4 20             	add    $0x20,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	78 54                	js     800ef0 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e9c:	83 ec 08             	sub    $0x8,%esp
  800e9f:	68 00 f0 7f 00       	push   $0x7ff000
  800ea4:	53                   	push   %ebx
  800ea5:	e8 42 fe ff ff       	call   800cec <sys_page_unmap>
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	78 51                	js     800f02 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800eb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800eb8:	83 ec 04             	sub    $0x4,%esp
  800ebb:	68 d0 17 80 00       	push   $0x8017d0
  800ec0:	6a 1d                	push   $0x1d
  800ec2:	68 4c 18 80 00       	push   $0x80184c
  800ec7:	e8 aa 02 00 00       	call   801176 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800ecc:	50                   	push   %eax
  800ecd:	68 08 18 80 00       	push   $0x801808
  800ed2:	6a 29                	push   $0x29
  800ed4:	68 4c 18 80 00       	push   $0x80184c
  800ed9:	e8 98 02 00 00       	call   801176 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ede:	50                   	push   %eax
  800edf:	68 2c 18 80 00       	push   $0x80182c
  800ee4:	6a 2e                	push   $0x2e
  800ee6:	68 4c 18 80 00       	push   $0x80184c
  800eeb:	e8 86 02 00 00       	call   801176 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800ef0:	50                   	push   %eax
  800ef1:	68 57 18 80 00       	push   $0x801857
  800ef6:	6a 30                	push   $0x30
  800ef8:	68 4c 18 80 00       	push   $0x80184c
  800efd:	e8 74 02 00 00       	call   801176 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f02:	50                   	push   %eax
  800f03:	68 2c 18 80 00       	push   $0x80182c
  800f08:	6a 32                	push   $0x32
  800f0a:	68 4c 18 80 00       	push   $0x80184c
  800f0f:	e8 62 02 00 00       	call   801176 <_panic>

00800f14 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f1d:	68 16 0e 80 00       	push   $0x800e16
  800f22:	e8 95 02 00 00       	call   8011bc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f27:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2c:	cd 30                	int    $0x30
  800f2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	78 2a                	js     800f62 <fork+0x4e>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f38:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f3d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f41:	75 5e                	jne    800fa1 <fork+0x8d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f43:	e8 e1 fc ff ff       	call   800c29 <sys_getenvid>
  800f48:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f4d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f50:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f55:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  800f5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f5d:	e9 b0 00 00 00       	jmp    801012 <fork+0xfe>
		panic("sys_exofork: %e", envid);
  800f62:	50                   	push   %eax
  800f63:	68 75 18 80 00       	push   $0x801875
  800f68:	6a 75                	push   $0x75
  800f6a:	68 4c 18 80 00       	push   $0x80184c
  800f6f:	e8 02 02 00 00       	call   801176 <_panic>
	r=sys_page_map(this_envid, va, this_envid, va, perm);//一定要用系统调用， 因为权限！！
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	56                   	push   %esi
  800f78:	57                   	push   %edi
  800f79:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800f7c:	51                   	push   %ecx
  800f7d:	57                   	push   %edi
  800f7e:	51                   	push   %ecx
  800f7f:	e8 26 fd ff ff       	call   800caa <sys_page_map>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
		    // dup page to child
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	0f 88 8b 00 00 00    	js     80101a <fork+0x106>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f8f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f95:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f9b:	0f 84 83 00 00 00    	je     801024 <fork+0x110>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800fa1:	89 d8                	mov    %ebx,%eax
  800fa3:	c1 e8 16             	shr    $0x16,%eax
  800fa6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fad:	a8 01                	test   $0x1,%al
  800faf:	74 de                	je     800f8f <fork+0x7b>
  800fb1:	89 de                	mov    %ebx,%esi
  800fb3:	c1 ee 0c             	shr    $0xc,%esi
  800fb6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fbd:	a8 01                	test   $0x1,%al
  800fbf:	74 ce                	je     800f8f <fork+0x7b>
	envid_t this_envid = sys_getenvid();//父进程号
  800fc1:	e8 63 fc ff ff       	call   800c29 <sys_getenvid>
  800fc6:	89 c1                	mov    %eax,%ecx
	void * va = (void *)(pn * PGSIZE);
  800fc8:	89 f7                	mov    %esi,%edi
  800fca:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & 0xFFF;
  800fcd:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
		perm &= ~PTE_W;
  800fd4:	89 d0                	mov    %edx,%eax
  800fd6:	25 fd 0f 00 00       	and    $0xffd,%eax
  800fdb:	80 cc 08             	or     $0x8,%ah
  800fde:	89 d6                	mov    %edx,%esi
  800fe0:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
  800fe6:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800fec:	0f 45 f0             	cmovne %eax,%esi
	perm&=PTE_SYSCALL; // 写sys_page_map函数时 perm必须要达成的要求
  800fef:	81 e6 07 0e 00 00    	and    $0xe07,%esi
	r=sys_page_map(this_envid, va, envid, va, perm);
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	56                   	push   %esi
  800ff9:	57                   	push   %edi
  800ffa:	ff 75 e0             	push   -0x20(%ebp)
  800ffd:	57                   	push   %edi
  800ffe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  801001:	51                   	push   %ecx
  801002:	e8 a3 fc ff ff       	call   800caa <sys_page_map>
	if(r<0) return r;
  801007:	83 c4 20             	add    $0x20,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	0f 89 62 ff ff ff    	jns    800f74 <fork+0x60>
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    
  80101a:	ba 00 00 00 00       	mov    $0x0,%edx
  80101f:	0f 4f c2             	cmovg  %edx,%eax
  801022:	eb ee                	jmp    801012 <fork+0xfe>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801024:	83 ec 04             	sub    $0x4,%esp
  801027:	6a 07                	push   $0x7
  801029:	68 00 f0 bf ee       	push   $0xeebff000
  80102e:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801031:	57                   	push   %edi
  801032:	e8 30 fc ff ff       	call   800c67 <sys_page_alloc>
	if(r<0) return r;
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 d4                	js     801012 <fork+0xfe>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80103e:	83 ec 08             	sub    $0x8,%esp
  801041:	68 32 12 80 00       	push   $0x801232
  801046:	57                   	push   %edi
  801047:	e8 24 fd ff ff       	call   800d70 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 bf                	js     801012 <fork+0xfe>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801053:	83 ec 08             	sub    $0x8,%esp
  801056:	6a 02                	push   $0x2
  801058:	57                   	push   %edi
  801059:	e8 d0 fc ff ff       	call   800d2e <sys_env_set_status>
	if(r<0) return r;
  80105e:	83 c4 10             	add    $0x10,%esp
	return envid;
  801061:	85 c0                	test   %eax,%eax
  801063:	0f 49 c7             	cmovns %edi,%eax
  801066:	eb aa                	jmp    801012 <fork+0xfe>

00801068 <sfork>:

// Challenge!
int
sfork(void)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80106e:	68 85 18 80 00       	push   $0x801885
  801073:	68 9e 00 00 00       	push   $0x9e
  801078:	68 4c 18 80 00       	push   $0x80184c
  80107d:	e8 f4 00 00 00       	call   801176 <_panic>

00801082 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	8b 75 08             	mov    0x8(%ebp),%esi
  80108a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801090:	85 c0                	test   %eax,%eax
  801092:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801097:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	50                   	push   %eax
  80109e:	e8 32 fd ff ff       	call   800dd5 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	85 f6                	test   %esi,%esi
  8010a8:	74 14                	je     8010be <ipc_recv+0x3c>
  8010aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	78 09                	js     8010bc <ipc_recv+0x3a>
  8010b3:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  8010b9:	8b 52 74             	mov    0x74(%edx),%edx
  8010bc:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8010be:	85 db                	test   %ebx,%ebx
  8010c0:	74 14                	je     8010d6 <ipc_recv+0x54>
  8010c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 09                	js     8010d4 <ipc_recv+0x52>
  8010cb:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  8010d1:	8b 52 78             	mov    0x78(%edx),%edx
  8010d4:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	78 08                	js     8010e2 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8010da:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8010df:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 0c             	sub    $0xc,%esp
  8010f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8010fb:	85 db                	test   %ebx,%ebx
  8010fd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801102:	0f 44 d8             	cmove  %eax,%ebx
  801105:	eb 05                	jmp    80110c <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801107:	e8 3c fb ff ff       	call   800c48 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80110c:	ff 75 14             	push   0x14(%ebp)
  80110f:	53                   	push   %ebx
  801110:	56                   	push   %esi
  801111:	57                   	push   %edi
  801112:	e8 9b fc ff ff       	call   800db2 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80111d:	74 e8                	je     801107 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 08                	js     80112b <ipc_send+0x42>
	}while (r<0);

}
  801123:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801126:	5b                   	pop    %ebx
  801127:	5e                   	pop    %esi
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80112b:	50                   	push   %eax
  80112c:	68 9b 18 80 00       	push   $0x80189b
  801131:	6a 3d                	push   $0x3d
  801133:	68 af 18 80 00       	push   $0x8018af
  801138:	e8 39 00 00 00       	call   801176 <_panic>

0080113d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801143:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801148:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80114b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801151:	8b 52 50             	mov    0x50(%edx),%edx
  801154:	39 ca                	cmp    %ecx,%edx
  801156:	74 11                	je     801169 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801158:	83 c0 01             	add    $0x1,%eax
  80115b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801160:	75 e6                	jne    801148 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801162:	b8 00 00 00 00       	mov    $0x0,%eax
  801167:	eb 0b                	jmp    801174 <ipc_find_env+0x37>
			return envs[i].env_id;
  801169:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80116c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801171:	8b 40 48             	mov    0x48(%eax),%eax
}
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80117b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80117e:	8b 35 08 20 80 00    	mov    0x802008,%esi
  801184:	e8 a0 fa ff ff       	call   800c29 <sys_getenvid>
  801189:	83 ec 0c             	sub    $0xc,%esp
  80118c:	ff 75 0c             	push   0xc(%ebp)
  80118f:	ff 75 08             	push   0x8(%ebp)
  801192:	56                   	push   %esi
  801193:	50                   	push   %eax
  801194:	68 bc 18 80 00       	push   $0x8018bc
  801199:	e8 f3 f0 ff ff       	call   800291 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80119e:	83 c4 18             	add    $0x18,%esp
  8011a1:	53                   	push   %ebx
  8011a2:	ff 75 10             	push   0x10(%ebp)
  8011a5:	e8 96 f0 ff ff       	call   800240 <vcprintf>
	cprintf("\n");
  8011aa:	c7 04 24 b2 14 80 00 	movl   $0x8014b2,(%esp)
  8011b1:	e8 db f0 ff ff       	call   800291 <cprintf>
  8011b6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011b9:	cc                   	int3   
  8011ba:	eb fd                	jmp    8011b9 <_panic+0x43>

008011bc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8011c2:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  8011c9:	74 0a                	je     8011d5 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ce:	a3 10 20 80 00       	mov    %eax,0x802010
}
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8011d5:	e8 4f fa ff ff       	call   800c29 <sys_getenvid>
  8011da:	83 ec 04             	sub    $0x4,%esp
  8011dd:	68 07 0e 00 00       	push   $0xe07
  8011e2:	68 00 f0 bf ee       	push   $0xeebff000
  8011e7:	50                   	push   %eax
  8011e8:	e8 7a fa ff ff       	call   800c67 <sys_page_alloc>
		if (r < 0) {
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 2c                	js     801220 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8011f4:	e8 30 fa ff ff       	call   800c29 <sys_getenvid>
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	68 32 12 80 00       	push   $0x801232
  801201:	50                   	push   %eax
  801202:	e8 69 fb ff ff       	call   800d70 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	85 c0                	test   %eax,%eax
  80120c:	79 bd                	jns    8011cb <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80120e:	50                   	push   %eax
  80120f:	68 20 19 80 00       	push   $0x801920
  801214:	6a 28                	push   $0x28
  801216:	68 56 19 80 00       	push   $0x801956
  80121b:	e8 56 ff ff ff       	call   801176 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801220:	50                   	push   %eax
  801221:	68 e0 18 80 00       	push   $0x8018e0
  801226:	6a 23                	push   $0x23
  801228:	68 56 19 80 00       	push   $0x801956
  80122d:	e8 44 ff ff ff       	call   801176 <_panic>

00801232 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801232:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801233:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  801238:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80123a:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80123d:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801241:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801244:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801248:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80124c:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80124e:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801251:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801252:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801255:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801256:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801257:	c3                   	ret    
  801258:	66 90                	xchg   %ax,%ax
  80125a:	66 90                	xchg   %ax,%ax
  80125c:	66 90                	xchg   %ax,%ax
  80125e:	66 90                	xchg   %ax,%ax

00801260 <__udivdi3>:
  801260:	f3 0f 1e fb          	endbr32 
  801264:	55                   	push   %ebp
  801265:	57                   	push   %edi
  801266:	56                   	push   %esi
  801267:	53                   	push   %ebx
  801268:	83 ec 1c             	sub    $0x1c,%esp
  80126b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80126f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801273:	8b 74 24 34          	mov    0x34(%esp),%esi
  801277:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80127b:	85 c0                	test   %eax,%eax
  80127d:	75 19                	jne    801298 <__udivdi3+0x38>
  80127f:	39 f3                	cmp    %esi,%ebx
  801281:	76 4d                	jbe    8012d0 <__udivdi3+0x70>
  801283:	31 ff                	xor    %edi,%edi
  801285:	89 e8                	mov    %ebp,%eax
  801287:	89 f2                	mov    %esi,%edx
  801289:	f7 f3                	div    %ebx
  80128b:	89 fa                	mov    %edi,%edx
  80128d:	83 c4 1c             	add    $0x1c,%esp
  801290:	5b                   	pop    %ebx
  801291:	5e                   	pop    %esi
  801292:	5f                   	pop    %edi
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    
  801295:	8d 76 00             	lea    0x0(%esi),%esi
  801298:	39 f0                	cmp    %esi,%eax
  80129a:	76 14                	jbe    8012b0 <__udivdi3+0x50>
  80129c:	31 ff                	xor    %edi,%edi
  80129e:	31 c0                	xor    %eax,%eax
  8012a0:	89 fa                	mov    %edi,%edx
  8012a2:	83 c4 1c             	add    $0x1c,%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5e                   	pop    %esi
  8012a7:	5f                   	pop    %edi
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    
  8012aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012b0:	0f bd f8             	bsr    %eax,%edi
  8012b3:	83 f7 1f             	xor    $0x1f,%edi
  8012b6:	75 48                	jne    801300 <__udivdi3+0xa0>
  8012b8:	39 f0                	cmp    %esi,%eax
  8012ba:	72 06                	jb     8012c2 <__udivdi3+0x62>
  8012bc:	31 c0                	xor    %eax,%eax
  8012be:	39 eb                	cmp    %ebp,%ebx
  8012c0:	77 de                	ja     8012a0 <__udivdi3+0x40>
  8012c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c7:	eb d7                	jmp    8012a0 <__udivdi3+0x40>
  8012c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012d0:	89 d9                	mov    %ebx,%ecx
  8012d2:	85 db                	test   %ebx,%ebx
  8012d4:	75 0b                	jne    8012e1 <__udivdi3+0x81>
  8012d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	f7 f3                	div    %ebx
  8012df:	89 c1                	mov    %eax,%ecx
  8012e1:	31 d2                	xor    %edx,%edx
  8012e3:	89 f0                	mov    %esi,%eax
  8012e5:	f7 f1                	div    %ecx
  8012e7:	89 c6                	mov    %eax,%esi
  8012e9:	89 e8                	mov    %ebp,%eax
  8012eb:	89 f7                	mov    %esi,%edi
  8012ed:	f7 f1                	div    %ecx
  8012ef:	89 fa                	mov    %edi,%edx
  8012f1:	83 c4 1c             	add    $0x1c,%esp
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5f                   	pop    %edi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    
  8012f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801300:	89 f9                	mov    %edi,%ecx
  801302:	ba 20 00 00 00       	mov    $0x20,%edx
  801307:	29 fa                	sub    %edi,%edx
  801309:	d3 e0                	shl    %cl,%eax
  80130b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130f:	89 d1                	mov    %edx,%ecx
  801311:	89 d8                	mov    %ebx,%eax
  801313:	d3 e8                	shr    %cl,%eax
  801315:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801319:	09 c1                	or     %eax,%ecx
  80131b:	89 f0                	mov    %esi,%eax
  80131d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801321:	89 f9                	mov    %edi,%ecx
  801323:	d3 e3                	shl    %cl,%ebx
  801325:	89 d1                	mov    %edx,%ecx
  801327:	d3 e8                	shr    %cl,%eax
  801329:	89 f9                	mov    %edi,%ecx
  80132b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80132f:	89 eb                	mov    %ebp,%ebx
  801331:	d3 e6                	shl    %cl,%esi
  801333:	89 d1                	mov    %edx,%ecx
  801335:	d3 eb                	shr    %cl,%ebx
  801337:	09 f3                	or     %esi,%ebx
  801339:	89 c6                	mov    %eax,%esi
  80133b:	89 f2                	mov    %esi,%edx
  80133d:	89 d8                	mov    %ebx,%eax
  80133f:	f7 74 24 08          	divl   0x8(%esp)
  801343:	89 d6                	mov    %edx,%esi
  801345:	89 c3                	mov    %eax,%ebx
  801347:	f7 64 24 0c          	mull   0xc(%esp)
  80134b:	39 d6                	cmp    %edx,%esi
  80134d:	72 19                	jb     801368 <__udivdi3+0x108>
  80134f:	89 f9                	mov    %edi,%ecx
  801351:	d3 e5                	shl    %cl,%ebp
  801353:	39 c5                	cmp    %eax,%ebp
  801355:	73 04                	jae    80135b <__udivdi3+0xfb>
  801357:	39 d6                	cmp    %edx,%esi
  801359:	74 0d                	je     801368 <__udivdi3+0x108>
  80135b:	89 d8                	mov    %ebx,%eax
  80135d:	31 ff                	xor    %edi,%edi
  80135f:	e9 3c ff ff ff       	jmp    8012a0 <__udivdi3+0x40>
  801364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801368:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80136b:	31 ff                	xor    %edi,%edi
  80136d:	e9 2e ff ff ff       	jmp    8012a0 <__udivdi3+0x40>
  801372:	66 90                	xchg   %ax,%ax
  801374:	66 90                	xchg   %ax,%ax
  801376:	66 90                	xchg   %ax,%ax
  801378:	66 90                	xchg   %ax,%ax
  80137a:	66 90                	xchg   %ax,%ax
  80137c:	66 90                	xchg   %ax,%ax
  80137e:	66 90                	xchg   %ax,%ax

00801380 <__umoddi3>:
  801380:	f3 0f 1e fb          	endbr32 
  801384:	55                   	push   %ebp
  801385:	57                   	push   %edi
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
  801388:	83 ec 1c             	sub    $0x1c,%esp
  80138b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80138f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801393:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801397:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80139b:	89 f0                	mov    %esi,%eax
  80139d:	89 da                	mov    %ebx,%edx
  80139f:	85 ff                	test   %edi,%edi
  8013a1:	75 15                	jne    8013b8 <__umoddi3+0x38>
  8013a3:	39 dd                	cmp    %ebx,%ebp
  8013a5:	76 39                	jbe    8013e0 <__umoddi3+0x60>
  8013a7:	f7 f5                	div    %ebp
  8013a9:	89 d0                	mov    %edx,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	83 c4 1c             	add    $0x1c,%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    
  8013b5:	8d 76 00             	lea    0x0(%esi),%esi
  8013b8:	39 df                	cmp    %ebx,%edi
  8013ba:	77 f1                	ja     8013ad <__umoddi3+0x2d>
  8013bc:	0f bd cf             	bsr    %edi,%ecx
  8013bf:	83 f1 1f             	xor    $0x1f,%ecx
  8013c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013c6:	75 40                	jne    801408 <__umoddi3+0x88>
  8013c8:	39 df                	cmp    %ebx,%edi
  8013ca:	72 04                	jb     8013d0 <__umoddi3+0x50>
  8013cc:	39 f5                	cmp    %esi,%ebp
  8013ce:	77 dd                	ja     8013ad <__umoddi3+0x2d>
  8013d0:	89 da                	mov    %ebx,%edx
  8013d2:	89 f0                	mov    %esi,%eax
  8013d4:	29 e8                	sub    %ebp,%eax
  8013d6:	19 fa                	sbb    %edi,%edx
  8013d8:	eb d3                	jmp    8013ad <__umoddi3+0x2d>
  8013da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013e0:	89 e9                	mov    %ebp,%ecx
  8013e2:	85 ed                	test   %ebp,%ebp
  8013e4:	75 0b                	jne    8013f1 <__umoddi3+0x71>
  8013e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013eb:	31 d2                	xor    %edx,%edx
  8013ed:	f7 f5                	div    %ebp
  8013ef:	89 c1                	mov    %eax,%ecx
  8013f1:	89 d8                	mov    %ebx,%eax
  8013f3:	31 d2                	xor    %edx,%edx
  8013f5:	f7 f1                	div    %ecx
  8013f7:	89 f0                	mov    %esi,%eax
  8013f9:	f7 f1                	div    %ecx
  8013fb:	89 d0                	mov    %edx,%eax
  8013fd:	31 d2                	xor    %edx,%edx
  8013ff:	eb ac                	jmp    8013ad <__umoddi3+0x2d>
  801401:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801408:	8b 44 24 04          	mov    0x4(%esp),%eax
  80140c:	ba 20 00 00 00       	mov    $0x20,%edx
  801411:	29 c2                	sub    %eax,%edx
  801413:	89 c1                	mov    %eax,%ecx
  801415:	89 e8                	mov    %ebp,%eax
  801417:	d3 e7                	shl    %cl,%edi
  801419:	89 d1                	mov    %edx,%ecx
  80141b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80141f:	d3 e8                	shr    %cl,%eax
  801421:	89 c1                	mov    %eax,%ecx
  801423:	8b 44 24 04          	mov    0x4(%esp),%eax
  801427:	09 f9                	or     %edi,%ecx
  801429:	89 df                	mov    %ebx,%edi
  80142b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80142f:	89 c1                	mov    %eax,%ecx
  801431:	d3 e5                	shl    %cl,%ebp
  801433:	89 d1                	mov    %edx,%ecx
  801435:	d3 ef                	shr    %cl,%edi
  801437:	89 c1                	mov    %eax,%ecx
  801439:	89 f0                	mov    %esi,%eax
  80143b:	d3 e3                	shl    %cl,%ebx
  80143d:	89 d1                	mov    %edx,%ecx
  80143f:	89 fa                	mov    %edi,%edx
  801441:	d3 e8                	shr    %cl,%eax
  801443:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801448:	09 d8                	or     %ebx,%eax
  80144a:	f7 74 24 08          	divl   0x8(%esp)
  80144e:	89 d3                	mov    %edx,%ebx
  801450:	d3 e6                	shl    %cl,%esi
  801452:	f7 e5                	mul    %ebp
  801454:	89 c7                	mov    %eax,%edi
  801456:	89 d1                	mov    %edx,%ecx
  801458:	39 d3                	cmp    %edx,%ebx
  80145a:	72 06                	jb     801462 <__umoddi3+0xe2>
  80145c:	75 0e                	jne    80146c <__umoddi3+0xec>
  80145e:	39 c6                	cmp    %eax,%esi
  801460:	73 0a                	jae    80146c <__umoddi3+0xec>
  801462:	29 e8                	sub    %ebp,%eax
  801464:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801468:	89 d1                	mov    %edx,%ecx
  80146a:	89 c7                	mov    %eax,%edi
  80146c:	89 f5                	mov    %esi,%ebp
  80146e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801472:	29 fd                	sub    %edi,%ebp
  801474:	19 cb                	sbb    %ecx,%ebx
  801476:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80147b:	89 d8                	mov    %ebx,%eax
  80147d:	d3 e0                	shl    %cl,%eax
  80147f:	89 f1                	mov    %esi,%ecx
  801481:	d3 ed                	shr    %cl,%ebp
  801483:	d3 eb                	shr    %cl,%ebx
  801485:	09 e8                	or     %ebp,%eax
  801487:	89 da                	mov    %ebx,%edx
  801489:	83 c4 1c             	add    $0x1c,%esp
  80148c:	5b                   	pop    %ebx
  80148d:	5e                   	pop    %esi
  80148e:	5f                   	pop    %edi
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    
