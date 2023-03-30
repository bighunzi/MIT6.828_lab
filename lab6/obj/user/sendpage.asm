
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
  800039:	e8 81 0f 00 00       	call   800fbf <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 84 a5 00 00 00    	je     8000ee <umain+0xbb>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800049:	a1 00 40 80 00       	mov    0x804000,%eax
  80004e:	8b 40 48             	mov    0x48(%eax),%eax
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 a0 00       	push   $0xa00000
  80005b:	50                   	push   %eax
  80005c:	e8 0e 0c 00 00       	call   800c6f <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800061:	83 c4 04             	add    $0x4,%esp
  800064:	ff 35 04 30 80 00    	push   0x803004
  80006a:	e8 c9 07 00 00       	call   800838 <strlen>
  80006f:	83 c4 0c             	add    $0xc,%esp
  800072:	83 c0 01             	add    $0x1,%eax
  800075:	50                   	push   %eax
  800076:	ff 35 04 30 80 00    	push   0x803004
  80007c:	68 00 00 a0 00       	push   $0xa00000
  800081:	e8 e5 09 00 00       	call   800a6b <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800086:	6a 07                	push   $0x7
  800088:	68 00 00 a0 00       	push   $0xa00000
  80008d:	6a 00                	push   $0x0
  80008f:	ff 75 f4             	push   -0xc(%ebp)
  800092:	e8 0f 11 00 00       	call   8011a6 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800097:	83 c4 1c             	add    $0x1c,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	68 00 00 a0 00       	push   $0xa00000
  8000a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a4:	50                   	push   %eax
  8000a5:	e8 95 10 00 00       	call   80113f <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000aa:	83 c4 0c             	add    $0xc,%esp
  8000ad:	68 00 00 a0 00       	push   $0xa00000
  8000b2:	ff 75 f4             	push   -0xc(%ebp)
  8000b5:	68 a0 26 80 00       	push   $0x8026a0
  8000ba:	e8 da 01 00 00       	call   800299 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000bf:	83 c4 04             	add    $0x4,%esp
  8000c2:	ff 35 00 30 80 00    	push   0x803000
  8000c8:	e8 6b 07 00 00       	call   800838 <strlen>
  8000cd:	83 c4 0c             	add    $0xc,%esp
  8000d0:	50                   	push   %eax
  8000d1:	ff 35 00 30 80 00    	push   0x803000
  8000d7:	68 00 00 a0 00       	push   $0xa00000
  8000dc:	e8 69 08 00 00       	call   80094a <strncmp>
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
  8000fc:	e8 3e 10 00 00       	call   80113f <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800101:	83 c4 0c             	add    $0xc,%esp
  800104:	68 00 00 b0 00       	push   $0xb00000
  800109:	ff 75 f4             	push   -0xc(%ebp)
  80010c:	68 a0 26 80 00       	push   $0x8026a0
  800111:	e8 83 01 00 00       	call   800299 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800116:	83 c4 04             	add    $0x4,%esp
  800119:	ff 35 04 30 80 00    	push   0x803004
  80011f:	e8 14 07 00 00       	call   800838 <strlen>
  800124:	83 c4 0c             	add    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	ff 35 04 30 80 00    	push   0x803004
  80012e:	68 00 00 b0 00       	push   $0xb00000
  800133:	e8 12 08 00 00       	call   80094a <strncmp>
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	85 c0                	test   %eax,%eax
  80013d:	74 3e                	je     80017d <umain+0x14a>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	ff 35 00 30 80 00    	push   0x803000
  800148:	e8 eb 06 00 00       	call   800838 <strlen>
  80014d:	83 c4 0c             	add    $0xc,%esp
  800150:	83 c0 01             	add    $0x1,%eax
  800153:	50                   	push   %eax
  800154:	ff 35 00 30 80 00    	push   0x803000
  80015a:	68 00 00 b0 00       	push   $0xb00000
  80015f:	e8 07 09 00 00       	call   800a6b <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800164:	6a 07                	push   $0x7
  800166:	68 00 00 b0 00       	push   $0xb00000
  80016b:	6a 00                	push   $0x0
  80016d:	ff 75 f4             	push   -0xc(%ebp)
  800170:	e8 31 10 00 00       	call   8011a6 <ipc_send>
		return;
  800175:	83 c4 20             	add    $0x20,%esp
  800178:	e9 6f ff ff ff       	jmp    8000ec <umain+0xb9>
			cprintf("child received correct message\n");
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	68 b4 26 80 00       	push   $0x8026b4
  800185:	e8 0f 01 00 00       	call   800299 <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	eb b0                	jmp    80013f <umain+0x10c>
		cprintf("parent received correct message\n");
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	68 d4 26 80 00       	push   $0x8026d4
  800197:	e8 fd 00 00 00       	call   800299 <cprintf>
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
  8001af:	e8 7d 0a 00 00       	call   800c31 <sys_getenvid>
  8001b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c1:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c6:	85 db                	test   %ebx,%ebx
  8001c8:	7e 07                	jle    8001d1 <libmain+0x2d>
		binaryname = argv[0];
  8001ca:	8b 06                	mov    (%esi),%eax
  8001cc:	a3 08 30 80 00       	mov    %eax,0x803008

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
  8001ed:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001f0:	e8 0f 12 00 00       	call   801404 <close_all>
	sys_env_destroy(0);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	6a 00                	push   $0x0
  8001fa:	e8 f1 09 00 00       	call   800bf0 <sys_env_destroy>
}
  8001ff:	83 c4 10             	add    $0x10,%esp
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	53                   	push   %ebx
  800208:	83 ec 04             	sub    $0x4,%esp
  80020b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80020e:	8b 13                	mov    (%ebx),%edx
  800210:	8d 42 01             	lea    0x1(%edx),%eax
  800213:	89 03                	mov    %eax,(%ebx)
  800215:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800218:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80021c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800221:	74 09                	je     80022c <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800223:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800227:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	68 ff 00 00 00       	push   $0xff
  800234:	8d 43 08             	lea    0x8(%ebx),%eax
  800237:	50                   	push   %eax
  800238:	e8 76 09 00 00       	call   800bb3 <sys_cputs>
		b->idx = 0;
  80023d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800243:	83 c4 10             	add    $0x10,%esp
  800246:	eb db                	jmp    800223 <putch+0x1f>

00800248 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800251:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800258:	00 00 00 
	b.cnt = 0;
  80025b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800262:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800265:	ff 75 0c             	push   0xc(%ebp)
  800268:	ff 75 08             	push   0x8(%ebp)
  80026b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800271:	50                   	push   %eax
  800272:	68 04 02 80 00       	push   $0x800204
  800277:	e8 14 01 00 00       	call   800390 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027c:	83 c4 08             	add    $0x8,%esp
  80027f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800285:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028b:	50                   	push   %eax
  80028c:	e8 22 09 00 00       	call   800bb3 <sys_cputs>

	return b.cnt;
}
  800291:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80029f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a2:	50                   	push   %eax
  8002a3:	ff 75 08             	push   0x8(%ebp)
  8002a6:	e8 9d ff ff ff       	call   800248 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
  8002b3:	83 ec 1c             	sub    $0x1c,%esp
  8002b6:	89 c7                	mov    %eax,%edi
  8002b8:	89 d6                	mov    %edx,%esi
  8002ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c0:	89 d1                	mov    %edx,%ecx
  8002c2:	89 c2                	mov    %eax,%edx
  8002c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002da:	39 c2                	cmp    %eax,%edx
  8002dc:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002df:	72 3e                	jb     80031f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e1:	83 ec 0c             	sub    $0xc,%esp
  8002e4:	ff 75 18             	push   0x18(%ebp)
  8002e7:	83 eb 01             	sub    $0x1,%ebx
  8002ea:	53                   	push   %ebx
  8002eb:	50                   	push   %eax
  8002ec:	83 ec 08             	sub    $0x8,%esp
  8002ef:	ff 75 e4             	push   -0x1c(%ebp)
  8002f2:	ff 75 e0             	push   -0x20(%ebp)
  8002f5:	ff 75 dc             	push   -0x24(%ebp)
  8002f8:	ff 75 d8             	push   -0x28(%ebp)
  8002fb:	e8 60 21 00 00       	call   802460 <__udivdi3>
  800300:	83 c4 18             	add    $0x18,%esp
  800303:	52                   	push   %edx
  800304:	50                   	push   %eax
  800305:	89 f2                	mov    %esi,%edx
  800307:	89 f8                	mov    %edi,%eax
  800309:	e8 9f ff ff ff       	call   8002ad <printnum>
  80030e:	83 c4 20             	add    $0x20,%esp
  800311:	eb 13                	jmp    800326 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800313:	83 ec 08             	sub    $0x8,%esp
  800316:	56                   	push   %esi
  800317:	ff 75 18             	push   0x18(%ebp)
  80031a:	ff d7                	call   *%edi
  80031c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031f:	83 eb 01             	sub    $0x1,%ebx
  800322:	85 db                	test   %ebx,%ebx
  800324:	7f ed                	jg     800313 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800326:	83 ec 08             	sub    $0x8,%esp
  800329:	56                   	push   %esi
  80032a:	83 ec 04             	sub    $0x4,%esp
  80032d:	ff 75 e4             	push   -0x1c(%ebp)
  800330:	ff 75 e0             	push   -0x20(%ebp)
  800333:	ff 75 dc             	push   -0x24(%ebp)
  800336:	ff 75 d8             	push   -0x28(%ebp)
  800339:	e8 42 22 00 00       	call   802580 <__umoddi3>
  80033e:	83 c4 14             	add    $0x14,%esp
  800341:	0f be 80 4c 27 80 00 	movsbl 0x80274c(%eax),%eax
  800348:	50                   	push   %eax
  800349:	ff d7                	call   *%edi
}
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800360:	8b 10                	mov    (%eax),%edx
  800362:	3b 50 04             	cmp    0x4(%eax),%edx
  800365:	73 0a                	jae    800371 <sprintputch+0x1b>
		*b->buf++ = ch;
  800367:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036a:	89 08                	mov    %ecx,(%eax)
  80036c:	8b 45 08             	mov    0x8(%ebp),%eax
  80036f:	88 02                	mov    %al,(%edx)
}
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <printfmt>:
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800379:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037c:	50                   	push   %eax
  80037d:	ff 75 10             	push   0x10(%ebp)
  800380:	ff 75 0c             	push   0xc(%ebp)
  800383:	ff 75 08             	push   0x8(%ebp)
  800386:	e8 05 00 00 00       	call   800390 <vprintfmt>
}
  80038b:	83 c4 10             	add    $0x10,%esp
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <vprintfmt>:
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 3c             	sub    $0x3c,%esp
  800399:	8b 75 08             	mov    0x8(%ebp),%esi
  80039c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80039f:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a2:	eb 0a                	jmp    8003ae <vprintfmt+0x1e>
			putch(ch, putdat);
  8003a4:	83 ec 08             	sub    $0x8,%esp
  8003a7:	53                   	push   %ebx
  8003a8:	50                   	push   %eax
  8003a9:	ff d6                	call   *%esi
  8003ab:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ae:	83 c7 01             	add    $0x1,%edi
  8003b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b5:	83 f8 25             	cmp    $0x25,%eax
  8003b8:	74 0c                	je     8003c6 <vprintfmt+0x36>
			if (ch == '\0')
  8003ba:	85 c0                	test   %eax,%eax
  8003bc:	75 e6                	jne    8003a4 <vprintfmt+0x14>
}
  8003be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c1:	5b                   	pop    %ebx
  8003c2:	5e                   	pop    %esi
  8003c3:	5f                   	pop    %edi
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    
		padc = ' ';
  8003c6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003ca:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003df:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8d 47 01             	lea    0x1(%edi),%eax
  8003e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ea:	0f b6 17             	movzbl (%edi),%edx
  8003ed:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f0:	3c 55                	cmp    $0x55,%al
  8003f2:	0f 87 bb 03 00 00    	ja     8007b3 <vprintfmt+0x423>
  8003f8:	0f b6 c0             	movzbl %al,%eax
  8003fb:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800405:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800409:	eb d9                	jmp    8003e4 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800412:	eb d0                	jmp    8003e4 <vprintfmt+0x54>
  800414:	0f b6 d2             	movzbl %dl,%edx
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800422:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800425:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800429:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80042c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80042f:	83 f9 09             	cmp    $0x9,%ecx
  800432:	77 55                	ja     800489 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800434:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800437:	eb e9                	jmp    800422 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8b 00                	mov    (%eax),%eax
  80043e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 40 04             	lea    0x4(%eax),%eax
  800447:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80044d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800451:	79 91                	jns    8003e4 <vprintfmt+0x54>
				width = precision, precision = -1;
  800453:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800456:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800459:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800460:	eb 82                	jmp    8003e4 <vprintfmt+0x54>
  800462:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800465:	85 d2                	test   %edx,%edx
  800467:	b8 00 00 00 00       	mov    $0x0,%eax
  80046c:	0f 49 c2             	cmovns %edx,%eax
  80046f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800475:	e9 6a ff ff ff       	jmp    8003e4 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80047d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800484:	e9 5b ff ff ff       	jmp    8003e4 <vprintfmt+0x54>
  800489:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80048c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80048f:	eb bc                	jmp    80044d <vprintfmt+0xbd>
			lflag++;
  800491:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800497:	e9 48 ff ff ff       	jmp    8003e4 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 78 04             	lea    0x4(%eax),%edi
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	ff 30                	push   (%eax)
  8004a8:	ff d6                	call   *%esi
			break;
  8004aa:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004ad:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004b0:	e9 9d 02 00 00       	jmp    800752 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 78 04             	lea    0x4(%eax),%edi
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	89 d0                	mov    %edx,%eax
  8004bf:	f7 d8                	neg    %eax
  8004c1:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c4:	83 f8 0f             	cmp    $0xf,%eax
  8004c7:	7f 23                	jg     8004ec <vprintfmt+0x15c>
  8004c9:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	74 18                	je     8004ec <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004d4:	52                   	push   %edx
  8004d5:	68 01 2c 80 00       	push   $0x802c01
  8004da:	53                   	push   %ebx
  8004db:	56                   	push   %esi
  8004dc:	e8 92 fe ff ff       	call   800373 <printfmt>
  8004e1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e7:	e9 66 02 00 00       	jmp    800752 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004ec:	50                   	push   %eax
  8004ed:	68 64 27 80 00       	push   $0x802764
  8004f2:	53                   	push   %ebx
  8004f3:	56                   	push   %esi
  8004f4:	e8 7a fe ff ff       	call   800373 <printfmt>
  8004f9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004ff:	e9 4e 02 00 00       	jmp    800752 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	83 c0 04             	add    $0x4,%eax
  80050a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800512:	85 d2                	test   %edx,%edx
  800514:	b8 5d 27 80 00       	mov    $0x80275d,%eax
  800519:	0f 45 c2             	cmovne %edx,%eax
  80051c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80051f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800523:	7e 06                	jle    80052b <vprintfmt+0x19b>
  800525:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800529:	75 0d                	jne    800538 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052e:	89 c7                	mov    %eax,%edi
  800530:	03 45 e0             	add    -0x20(%ebp),%eax
  800533:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800536:	eb 55                	jmp    80058d <vprintfmt+0x1fd>
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 d8             	push   -0x28(%ebp)
  80053e:	ff 75 cc             	push   -0x34(%ebp)
  800541:	e8 0a 03 00 00       	call   800850 <strnlen>
  800546:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800549:	29 c1                	sub    %eax,%ecx
  80054b:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800553:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800557:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80055a:	eb 0f                	jmp    80056b <vprintfmt+0x1db>
					putch(padc, putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	ff 75 e0             	push   -0x20(%ebp)
  800563:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	83 ef 01             	sub    $0x1,%edi
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	85 ff                	test   %edi,%edi
  80056d:	7f ed                	jg     80055c <vprintfmt+0x1cc>
  80056f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800572:	85 d2                	test   %edx,%edx
  800574:	b8 00 00 00 00       	mov    $0x0,%eax
  800579:	0f 49 c2             	cmovns %edx,%eax
  80057c:	29 c2                	sub    %eax,%edx
  80057e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800581:	eb a8                	jmp    80052b <vprintfmt+0x19b>
					putch(ch, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	52                   	push   %edx
  800588:	ff d6                	call   *%esi
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800590:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800592:	83 c7 01             	add    $0x1,%edi
  800595:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800599:	0f be d0             	movsbl %al,%edx
  80059c:	85 d2                	test   %edx,%edx
  80059e:	74 4b                	je     8005eb <vprintfmt+0x25b>
  8005a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a4:	78 06                	js     8005ac <vprintfmt+0x21c>
  8005a6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005aa:	78 1e                	js     8005ca <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ac:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b0:	74 d1                	je     800583 <vprintfmt+0x1f3>
  8005b2:	0f be c0             	movsbl %al,%eax
  8005b5:	83 e8 20             	sub    $0x20,%eax
  8005b8:	83 f8 5e             	cmp    $0x5e,%eax
  8005bb:	76 c6                	jbe    800583 <vprintfmt+0x1f3>
					putch('?', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 3f                	push   $0x3f
  8005c3:	ff d6                	call   *%esi
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	eb c3                	jmp    80058d <vprintfmt+0x1fd>
  8005ca:	89 cf                	mov    %ecx,%edi
  8005cc:	eb 0e                	jmp    8005dc <vprintfmt+0x24c>
				putch(' ', putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	53                   	push   %ebx
  8005d2:	6a 20                	push   $0x20
  8005d4:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005d6:	83 ef 01             	sub    $0x1,%edi
  8005d9:	83 c4 10             	add    $0x10,%esp
  8005dc:	85 ff                	test   %edi,%edi
  8005de:	7f ee                	jg     8005ce <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005e0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e6:	e9 67 01 00 00       	jmp    800752 <vprintfmt+0x3c2>
  8005eb:	89 cf                	mov    %ecx,%edi
  8005ed:	eb ed                	jmp    8005dc <vprintfmt+0x24c>
	if (lflag >= 2)
  8005ef:	83 f9 01             	cmp    $0x1,%ecx
  8005f2:	7f 1b                	jg     80060f <vprintfmt+0x27f>
	else if (lflag)
  8005f4:	85 c9                	test   %ecx,%ecx
  8005f6:	74 63                	je     80065b <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	99                   	cltd   
  800601:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 40 04             	lea    0x4(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
  80060d:	eb 17                	jmp    800626 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 50 04             	mov    0x4(%eax),%edx
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 40 08             	lea    0x8(%eax),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800626:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800629:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80062c:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800631:	85 c9                	test   %ecx,%ecx
  800633:	0f 89 ff 00 00 00    	jns    800738 <vprintfmt+0x3a8>
				putch('-', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 2d                	push   $0x2d
  80063f:	ff d6                	call   *%esi
				num = -(long long) num;
  800641:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800644:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800647:	f7 da                	neg    %edx
  800649:	83 d1 00             	adc    $0x0,%ecx
  80064c:	f7 d9                	neg    %ecx
  80064e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800651:	bf 0a 00 00 00       	mov    $0xa,%edi
  800656:	e9 dd 00 00 00       	jmp    800738 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800663:	99                   	cltd   
  800664:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8d 40 04             	lea    0x4(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
  800670:	eb b4                	jmp    800626 <vprintfmt+0x296>
	if (lflag >= 2)
  800672:	83 f9 01             	cmp    $0x1,%ecx
  800675:	7f 1e                	jg     800695 <vprintfmt+0x305>
	else if (lflag)
  800677:	85 c9                	test   %ecx,%ecx
  800679:	74 32                	je     8006ad <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8b 10                	mov    (%eax),%edx
  800680:	b9 00 00 00 00       	mov    $0x0,%ecx
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800690:	e9 a3 00 00 00       	jmp    800738 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	8b 48 04             	mov    0x4(%eax),%ecx
  80069d:	8d 40 08             	lea    0x8(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8006a8:	e9 8b 00 00 00       	jmp    800738 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006bd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8006c2:	eb 74                	jmp    800738 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8006c4:	83 f9 01             	cmp    $0x1,%ecx
  8006c7:	7f 1b                	jg     8006e4 <vprintfmt+0x354>
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	74 2c                	je     8006f9 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 10                	mov    (%eax),%edx
  8006d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006dd:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8006e2:	eb 54                	jmp    800738 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ec:	8d 40 08             	lea    0x8(%eax),%eax
  8006ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006f2:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8006f7:	eb 3f                	jmp    800738 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 10                	mov    (%eax),%edx
  8006fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800703:	8d 40 04             	lea    0x4(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800709:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80070e:	eb 28                	jmp    800738 <vprintfmt+0x3a8>
			putch('0', putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	6a 30                	push   $0x30
  800716:	ff d6                	call   *%esi
			putch('x', putdat);
  800718:	83 c4 08             	add    $0x8,%esp
  80071b:	53                   	push   %ebx
  80071c:	6a 78                	push   $0x78
  80071e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8b 10                	mov    (%eax),%edx
  800725:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80072a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80072d:	8d 40 04             	lea    0x4(%eax),%eax
  800730:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800733:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800738:	83 ec 0c             	sub    $0xc,%esp
  80073b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80073f:	50                   	push   %eax
  800740:	ff 75 e0             	push   -0x20(%ebp)
  800743:	57                   	push   %edi
  800744:	51                   	push   %ecx
  800745:	52                   	push   %edx
  800746:	89 da                	mov    %ebx,%edx
  800748:	89 f0                	mov    %esi,%eax
  80074a:	e8 5e fb ff ff       	call   8002ad <printnum>
			break;
  80074f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800752:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800755:	e9 54 fc ff ff       	jmp    8003ae <vprintfmt+0x1e>
	if (lflag >= 2)
  80075a:	83 f9 01             	cmp    $0x1,%ecx
  80075d:	7f 1b                	jg     80077a <vprintfmt+0x3ea>
	else if (lflag)
  80075f:	85 c9                	test   %ecx,%ecx
  800761:	74 2c                	je     80078f <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8b 10                	mov    (%eax),%edx
  800768:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076d:	8d 40 04             	lea    0x4(%eax),%eax
  800770:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800773:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800778:	eb be                	jmp    800738 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 10                	mov    (%eax),%edx
  80077f:	8b 48 04             	mov    0x4(%eax),%ecx
  800782:	8d 40 08             	lea    0x8(%eax),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800788:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80078d:	eb a9                	jmp    800738 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8b 10                	mov    (%eax),%edx
  800794:	b9 00 00 00 00       	mov    $0x0,%ecx
  800799:	8d 40 04             	lea    0x4(%eax),%eax
  80079c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8007a4:	eb 92                	jmp    800738 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8007a6:	83 ec 08             	sub    $0x8,%esp
  8007a9:	53                   	push   %ebx
  8007aa:	6a 25                	push   $0x25
  8007ac:	ff d6                	call   *%esi
			break;
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	eb 9f                	jmp    800752 <vprintfmt+0x3c2>
			putch('%', putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	53                   	push   %ebx
  8007b7:	6a 25                	push   $0x25
  8007b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	89 f8                	mov    %edi,%eax
  8007c0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007c4:	74 05                	je     8007cb <vprintfmt+0x43b>
  8007c6:	83 e8 01             	sub    $0x1,%eax
  8007c9:	eb f5                	jmp    8007c0 <vprintfmt+0x430>
  8007cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ce:	eb 82                	jmp    800752 <vprintfmt+0x3c2>

008007d0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 18             	sub    $0x18,%esp
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007df:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	74 26                	je     800817 <vsnprintf+0x47>
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	7e 22                	jle    800817 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f5:	ff 75 14             	push   0x14(%ebp)
  8007f8:	ff 75 10             	push   0x10(%ebp)
  8007fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007fe:	50                   	push   %eax
  8007ff:	68 56 03 80 00       	push   $0x800356
  800804:	e8 87 fb ff ff       	call   800390 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800809:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80080c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800812:	83 c4 10             	add    $0x10,%esp
}
  800815:	c9                   	leave  
  800816:	c3                   	ret    
		return -E_INVAL;
  800817:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081c:	eb f7                	jmp    800815 <vsnprintf+0x45>

0080081e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800824:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800827:	50                   	push   %eax
  800828:	ff 75 10             	push   0x10(%ebp)
  80082b:	ff 75 0c             	push   0xc(%ebp)
  80082e:	ff 75 08             	push   0x8(%ebp)
  800831:	e8 9a ff ff ff       	call   8007d0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
  800843:	eb 03                	jmp    800848 <strlen+0x10>
		n++;
  800845:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800848:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80084c:	75 f7                	jne    800845 <strlen+0xd>
	return n;
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
  80085e:	eb 03                	jmp    800863 <strnlen+0x13>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800863:	39 d0                	cmp    %edx,%eax
  800865:	74 08                	je     80086f <strnlen+0x1f>
  800867:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086b:	75 f3                	jne    800860 <strnlen+0x10>
  80086d:	89 c2                	mov    %eax,%edx
	return n;
}
  80086f:	89 d0                	mov    %edx,%eax
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
  800882:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800886:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800889:	83 c0 01             	add    $0x1,%eax
  80088c:	84 d2                	test   %dl,%dl
  80088e:	75 f2                	jne    800882 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800890:	89 c8                	mov    %ecx,%eax
  800892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	83 ec 10             	sub    $0x10,%esp
  80089e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a1:	53                   	push   %ebx
  8008a2:	e8 91 ff ff ff       	call   800838 <strlen>
  8008a7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008aa:	ff 75 0c             	push   0xc(%ebp)
  8008ad:	01 d8                	add    %ebx,%eax
  8008af:	50                   	push   %eax
  8008b0:	e8 be ff ff ff       	call   800873 <strcpy>
	return dst;
}
  8008b5:	89 d8                	mov    %ebx,%eax
  8008b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c7:	89 f3                	mov    %esi,%ebx
  8008c9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cc:	89 f0                	mov    %esi,%eax
  8008ce:	eb 0f                	jmp    8008df <strncpy+0x23>
		*dst++ = *src;
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	0f b6 0a             	movzbl (%edx),%ecx
  8008d6:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d9:	80 f9 01             	cmp    $0x1,%cl
  8008dc:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008df:	39 d8                	cmp    %ebx,%eax
  8008e1:	75 ed                	jne    8008d0 <strncpy+0x14>
	}
	return ret;
}
  8008e3:	89 f0                	mov    %esi,%eax
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f9:	85 d2                	test   %edx,%edx
  8008fb:	74 21                	je     80091e <strlcpy+0x35>
  8008fd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800901:	89 f2                	mov    %esi,%edx
  800903:	eb 09                	jmp    80090e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	83 c2 01             	add    $0x1,%edx
  80090b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80090e:	39 c2                	cmp    %eax,%edx
  800910:	74 09                	je     80091b <strlcpy+0x32>
  800912:	0f b6 19             	movzbl (%ecx),%ebx
  800915:	84 db                	test   %bl,%bl
  800917:	75 ec                	jne    800905 <strlcpy+0x1c>
  800919:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80091b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091e:	29 f0                	sub    %esi,%eax
}
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092d:	eb 06                	jmp    800935 <strcmp+0x11>
		p++, q++;
  80092f:	83 c1 01             	add    $0x1,%ecx
  800932:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800935:	0f b6 01             	movzbl (%ecx),%eax
  800938:	84 c0                	test   %al,%al
  80093a:	74 04                	je     800940 <strcmp+0x1c>
  80093c:	3a 02                	cmp    (%edx),%al
  80093e:	74 ef                	je     80092f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800940:	0f b6 c0             	movzbl %al,%eax
  800943:	0f b6 12             	movzbl (%edx),%edx
  800946:	29 d0                	sub    %edx,%eax
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
  800954:	89 c3                	mov    %eax,%ebx
  800956:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800959:	eb 06                	jmp    800961 <strncmp+0x17>
		n--, p++, q++;
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800961:	39 d8                	cmp    %ebx,%eax
  800963:	74 18                	je     80097d <strncmp+0x33>
  800965:	0f b6 08             	movzbl (%eax),%ecx
  800968:	84 c9                	test   %cl,%cl
  80096a:	74 04                	je     800970 <strncmp+0x26>
  80096c:	3a 0a                	cmp    (%edx),%cl
  80096e:	74 eb                	je     80095b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800970:	0f b6 00             	movzbl (%eax),%eax
  800973:	0f b6 12             	movzbl (%edx),%edx
  800976:	29 d0                	sub    %edx,%eax
}
  800978:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    
		return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
  800982:	eb f4                	jmp    800978 <strncmp+0x2e>

00800984 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098e:	eb 03                	jmp    800993 <strchr+0xf>
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	0f b6 10             	movzbl (%eax),%edx
  800996:	84 d2                	test   %dl,%dl
  800998:	74 06                	je     8009a0 <strchr+0x1c>
		if (*s == c)
  80099a:	38 ca                	cmp    %cl,%dl
  80099c:	75 f2                	jne    800990 <strchr+0xc>
  80099e:	eb 05                	jmp    8009a5 <strchr+0x21>
			return (char *) s;
	return 0;
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b4:	38 ca                	cmp    %cl,%dl
  8009b6:	74 09                	je     8009c1 <strfind+0x1a>
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 05                	je     8009c1 <strfind+0x1a>
	for (; *s; s++)
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	eb f0                	jmp    8009b1 <strfind+0xa>
			break;
	return (char *) s;
}
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	57                   	push   %edi
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009cf:	85 c9                	test   %ecx,%ecx
  8009d1:	74 2f                	je     800a02 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d3:	89 f8                	mov    %edi,%eax
  8009d5:	09 c8                	or     %ecx,%eax
  8009d7:	a8 03                	test   $0x3,%al
  8009d9:	75 21                	jne    8009fc <memset+0x39>
		c &= 0xFF;
  8009db:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009df:	89 d0                	mov    %edx,%eax
  8009e1:	c1 e0 08             	shl    $0x8,%eax
  8009e4:	89 d3                	mov    %edx,%ebx
  8009e6:	c1 e3 18             	shl    $0x18,%ebx
  8009e9:	89 d6                	mov    %edx,%esi
  8009eb:	c1 e6 10             	shl    $0x10,%esi
  8009ee:	09 f3                	or     %esi,%ebx
  8009f0:	09 da                	or     %ebx,%edx
  8009f2:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009f7:	fc                   	cld    
  8009f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fa:	eb 06                	jmp    800a02 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ff:	fc                   	cld    
  800a00:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a02:	89 f8                	mov    %edi,%eax
  800a04:	5b                   	pop    %ebx
  800a05:	5e                   	pop    %esi
  800a06:	5f                   	pop    %edi
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	57                   	push   %edi
  800a0d:	56                   	push   %esi
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a14:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a17:	39 c6                	cmp    %eax,%esi
  800a19:	73 32                	jae    800a4d <memmove+0x44>
  800a1b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1e:	39 c2                	cmp    %eax,%edx
  800a20:	76 2b                	jbe    800a4d <memmove+0x44>
		s += n;
		d += n;
  800a22:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a25:	89 d6                	mov    %edx,%esi
  800a27:	09 fe                	or     %edi,%esi
  800a29:	09 ce                	or     %ecx,%esi
  800a2b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a31:	75 0e                	jne    800a41 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a33:	83 ef 04             	sub    $0x4,%edi
  800a36:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a39:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a3c:	fd                   	std    
  800a3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3f:	eb 09                	jmp    800a4a <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a41:	83 ef 01             	sub    $0x1,%edi
  800a44:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a47:	fd                   	std    
  800a48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4a:	fc                   	cld    
  800a4b:	eb 1a                	jmp    800a67 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4d:	89 f2                	mov    %esi,%edx
  800a4f:	09 c2                	or     %eax,%edx
  800a51:	09 ca                	or     %ecx,%edx
  800a53:	f6 c2 03             	test   $0x3,%dl
  800a56:	75 0a                	jne    800a62 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a58:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a5b:	89 c7                	mov    %eax,%edi
  800a5d:	fc                   	cld    
  800a5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a60:	eb 05                	jmp    800a67 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a62:	89 c7                	mov    %eax,%edi
  800a64:	fc                   	cld    
  800a65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a71:	ff 75 10             	push   0x10(%ebp)
  800a74:	ff 75 0c             	push   0xc(%ebp)
  800a77:	ff 75 08             	push   0x8(%ebp)
  800a7a:	e8 8a ff ff ff       	call   800a09 <memmove>
}
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8c:	89 c6                	mov    %eax,%esi
  800a8e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a91:	eb 06                	jmp    800a99 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a99:	39 f0                	cmp    %esi,%eax
  800a9b:	74 14                	je     800ab1 <memcmp+0x30>
		if (*s1 != *s2)
  800a9d:	0f b6 08             	movzbl (%eax),%ecx
  800aa0:	0f b6 1a             	movzbl (%edx),%ebx
  800aa3:	38 d9                	cmp    %bl,%cl
  800aa5:	74 ec                	je     800a93 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800aa7:	0f b6 c1             	movzbl %cl,%eax
  800aaa:	0f b6 db             	movzbl %bl,%ebx
  800aad:	29 d8                	sub    %ebx,%eax
  800aaf:	eb 05                	jmp    800ab6 <memcmp+0x35>
	}

	return 0;
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac3:	89 c2                	mov    %eax,%edx
  800ac5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac8:	eb 03                	jmp    800acd <memfind+0x13>
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	39 d0                	cmp    %edx,%eax
  800acf:	73 04                	jae    800ad5 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad1:	38 08                	cmp    %cl,(%eax)
  800ad3:	75 f5                	jne    800aca <memfind+0x10>
			break;
	return (void *) s;
}
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae3:	eb 03                	jmp    800ae8 <strtol+0x11>
		s++;
  800ae5:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800ae8:	0f b6 02             	movzbl (%edx),%eax
  800aeb:	3c 20                	cmp    $0x20,%al
  800aed:	74 f6                	je     800ae5 <strtol+0xe>
  800aef:	3c 09                	cmp    $0x9,%al
  800af1:	74 f2                	je     800ae5 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800af3:	3c 2b                	cmp    $0x2b,%al
  800af5:	74 2a                	je     800b21 <strtol+0x4a>
	int neg = 0;
  800af7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800afc:	3c 2d                	cmp    $0x2d,%al
  800afe:	74 2b                	je     800b2b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b00:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b06:	75 0f                	jne    800b17 <strtol+0x40>
  800b08:	80 3a 30             	cmpb   $0x30,(%edx)
  800b0b:	74 28                	je     800b35 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b0d:	85 db                	test   %ebx,%ebx
  800b0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b14:	0f 44 d8             	cmove  %eax,%ebx
  800b17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b1f:	eb 46                	jmp    800b67 <strtol+0x90>
		s++;
  800b21:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b24:	bf 00 00 00 00       	mov    $0x0,%edi
  800b29:	eb d5                	jmp    800b00 <strtol+0x29>
		s++, neg = 1;
  800b2b:	83 c2 01             	add    $0x1,%edx
  800b2e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b33:	eb cb                	jmp    800b00 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b35:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b39:	74 0e                	je     800b49 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b3b:	85 db                	test   %ebx,%ebx
  800b3d:	75 d8                	jne    800b17 <strtol+0x40>
		s++, base = 8;
  800b3f:	83 c2 01             	add    $0x1,%edx
  800b42:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b47:	eb ce                	jmp    800b17 <strtol+0x40>
		s += 2, base = 16;
  800b49:	83 c2 02             	add    $0x2,%edx
  800b4c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b51:	eb c4                	jmp    800b17 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b53:	0f be c0             	movsbl %al,%eax
  800b56:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b59:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b5c:	7d 3a                	jge    800b98 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b5e:	83 c2 01             	add    $0x1,%edx
  800b61:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b65:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b67:	0f b6 02             	movzbl (%edx),%eax
  800b6a:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	80 fb 09             	cmp    $0x9,%bl
  800b72:	76 df                	jbe    800b53 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b74:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b77:	89 f3                	mov    %esi,%ebx
  800b79:	80 fb 19             	cmp    $0x19,%bl
  800b7c:	77 08                	ja     800b86 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b7e:	0f be c0             	movsbl %al,%eax
  800b81:	83 e8 57             	sub    $0x57,%eax
  800b84:	eb d3                	jmp    800b59 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b86:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b89:	89 f3                	mov    %esi,%ebx
  800b8b:	80 fb 19             	cmp    $0x19,%bl
  800b8e:	77 08                	ja     800b98 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b90:	0f be c0             	movsbl %al,%eax
  800b93:	83 e8 37             	sub    $0x37,%eax
  800b96:	eb c1                	jmp    800b59 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9c:	74 05                	je     800ba3 <strtol+0xcc>
		*endptr = (char *) s;
  800b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ba3:	89 c8                	mov    %ecx,%eax
  800ba5:	f7 d8                	neg    %eax
  800ba7:	85 ff                	test   %edi,%edi
  800ba9:	0f 45 c8             	cmovne %eax,%ecx
}
  800bac:	89 c8                	mov    %ecx,%eax
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	89 c3                	mov    %eax,%ebx
  800bc6:	89 c7                	mov    %eax,%edi
  800bc8:	89 c6                	mov    %eax,%esi
  800bca:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 01 00 00 00       	mov    $0x1,%eax
  800be1:	89 d1                	mov    %edx,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	b8 03 00 00 00       	mov    $0x3,%eax
  800c06:	89 cb                	mov    %ecx,%ebx
  800c08:	89 cf                	mov    %ecx,%edi
  800c0a:	89 ce                	mov    %ecx,%esi
  800c0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	7f 08                	jg     800c1a <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 03                	push   $0x3
  800c20:	68 3f 2a 80 00       	push   $0x802a3f
  800c25:	6a 2a                	push   $0x2a
  800c27:	68 5c 2a 80 00       	push   $0x802a5c
  800c2c:	e8 10 17 00 00       	call   802341 <_panic>

00800c31 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c37:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c41:	89 d1                	mov    %edx,%ecx
  800c43:	89 d3                	mov    %edx,%ebx
  800c45:	89 d7                	mov    %edx,%edi
  800c47:	89 d6                	mov    %edx,%esi
  800c49:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <sys_yield>:

void
sys_yield(void)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c56:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c60:	89 d1                	mov    %edx,%ecx
  800c62:	89 d3                	mov    %edx,%ebx
  800c64:	89 d7                	mov    %edx,%edi
  800c66:	89 d6                	mov    %edx,%esi
  800c68:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c78:	be 00 00 00 00       	mov    $0x0,%esi
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	b8 04 00 00 00       	mov    $0x4,%eax
  800c88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8b:	89 f7                	mov    %esi,%edi
  800c8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7f 08                	jg     800c9b <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	50                   	push   %eax
  800c9f:	6a 04                	push   $0x4
  800ca1:	68 3f 2a 80 00       	push   $0x802a3f
  800ca6:	6a 2a                	push   $0x2a
  800ca8:	68 5c 2a 80 00       	push   $0x802a5c
  800cad:	e8 8f 16 00 00       	call   802341 <_panic>

00800cb2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccc:	8b 75 18             	mov    0x18(%ebp),%esi
  800ccf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7f 08                	jg     800cdd <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdd:	83 ec 0c             	sub    $0xc,%esp
  800ce0:	50                   	push   %eax
  800ce1:	6a 05                	push   $0x5
  800ce3:	68 3f 2a 80 00       	push   $0x802a3f
  800ce8:	6a 2a                	push   $0x2a
  800cea:	68 5c 2a 80 00       	push   $0x802a5c
  800cef:	e8 4d 16 00 00       	call   802341 <_panic>

00800cf4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0d:	89 df                	mov    %ebx,%edi
  800d0f:	89 de                	mov    %ebx,%esi
  800d11:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7f 08                	jg     800d1f <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1f:	83 ec 0c             	sub    $0xc,%esp
  800d22:	50                   	push   %eax
  800d23:	6a 06                	push   $0x6
  800d25:	68 3f 2a 80 00       	push   $0x802a3f
  800d2a:	6a 2a                	push   $0x2a
  800d2c:	68 5c 2a 80 00       	push   $0x802a5c
  800d31:	e8 0b 16 00 00       	call   802341 <_panic>

00800d36 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d4f:	89 df                	mov    %ebx,%edi
  800d51:	89 de                	mov    %ebx,%esi
  800d53:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7f 08                	jg     800d61 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d61:	83 ec 0c             	sub    $0xc,%esp
  800d64:	50                   	push   %eax
  800d65:	6a 08                	push   $0x8
  800d67:	68 3f 2a 80 00       	push   $0x802a3f
  800d6c:	6a 2a                	push   $0x2a
  800d6e:	68 5c 2a 80 00       	push   $0x802a5c
  800d73:	e8 c9 15 00 00       	call   802341 <_panic>

00800d78 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d91:	89 df                	mov    %ebx,%edi
  800d93:	89 de                	mov    %ebx,%esi
  800d95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d97:	85 c0                	test   %eax,%eax
  800d99:	7f 08                	jg     800da3 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800da7:	6a 09                	push   $0x9
  800da9:	68 3f 2a 80 00       	push   $0x802a3f
  800dae:	6a 2a                	push   $0x2a
  800db0:	68 5c 2a 80 00       	push   $0x802a5c
  800db5:	e8 87 15 00 00       	call   802341 <_panic>

00800dba <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dce:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd3:	89 df                	mov    %ebx,%edi
  800dd5:	89 de                	mov    %ebx,%esi
  800dd7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7f 08                	jg     800de5 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	50                   	push   %eax
  800de9:	6a 0a                	push   $0xa
  800deb:	68 3f 2a 80 00       	push   $0x802a3f
  800df0:	6a 2a                	push   $0x2a
  800df2:	68 5c 2a 80 00       	push   $0x802a5c
  800df7:	e8 45 15 00 00       	call   802341 <_panic>

00800dfc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e0d:	be 00 00 00 00       	mov    $0x0,%esi
  800e12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e18:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e35:	89 cb                	mov    %ecx,%ebx
  800e37:	89 cf                	mov    %ecx,%edi
  800e39:	89 ce                	mov    %ecx,%esi
  800e3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	7f 08                	jg     800e49 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e49:	83 ec 0c             	sub    $0xc,%esp
  800e4c:	50                   	push   %eax
  800e4d:	6a 0d                	push   $0xd
  800e4f:	68 3f 2a 80 00       	push   $0x802a3f
  800e54:	6a 2a                	push   $0x2a
  800e56:	68 5c 2a 80 00       	push   $0x802a5c
  800e5b:	e8 e1 14 00 00       	call   802341 <_panic>

00800e60 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e66:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e70:	89 d1                	mov    %edx,%ecx
  800e72:	89 d3                	mov    %edx,%ebx
  800e74:	89 d7                	mov    %edx,%edi
  800e76:	89 d6                	mov    %edx,%esi
  800e78:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5f                   	pop    %edi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	57                   	push   %edi
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e90:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e95:	89 df                	mov    %ebx,%edi
  800e97:	89 de                	mov    %ebx,%esi
  800e99:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
  800eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb1:	b8 10 00 00 00       	mov    $0x10,%eax
  800eb6:	89 df                	mov    %ebx,%edi
  800eb8:	89 de                	mov    %ebx,%esi
  800eba:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ec9:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ecb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ecf:	0f 84 8e 00 00 00    	je     800f63 <pgfault+0xa2>
  800ed5:	89 f0                	mov    %esi,%eax
  800ed7:	c1 e8 0c             	shr    $0xc,%eax
  800eda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee1:	f6 c4 08             	test   $0x8,%ah
  800ee4:	74 7d                	je     800f63 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800ee6:	e8 46 fd ff ff       	call   800c31 <sys_getenvid>
  800eeb:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800eed:	83 ec 04             	sub    $0x4,%esp
  800ef0:	6a 07                	push   $0x7
  800ef2:	68 00 f0 7f 00       	push   $0x7ff000
  800ef7:	50                   	push   %eax
  800ef8:	e8 72 fd ff ff       	call   800c6f <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	85 c0                	test   %eax,%eax
  800f02:	78 73                	js     800f77 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f04:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	68 00 10 00 00       	push   $0x1000
  800f12:	56                   	push   %esi
  800f13:	68 00 f0 7f 00       	push   $0x7ff000
  800f18:	e8 ec fa ff ff       	call   800a09 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	e8 cd fd ff ff       	call   800cf4 <sys_page_unmap>
  800f27:	83 c4 10             	add    $0x10,%esp
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	78 5b                	js     800f89 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	6a 07                	push   $0x7
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	68 00 f0 7f 00       	push   $0x7ff000
  800f3a:	53                   	push   %ebx
  800f3b:	e8 72 fd ff ff       	call   800cb2 <sys_page_map>
  800f40:	83 c4 20             	add    $0x20,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	78 54                	js     800f9b <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f47:	83 ec 08             	sub    $0x8,%esp
  800f4a:	68 00 f0 7f 00       	push   $0x7ff000
  800f4f:	53                   	push   %ebx
  800f50:	e8 9f fd ff ff       	call   800cf4 <sys_page_unmap>
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	78 51                	js     800fad <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800f5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f63:	83 ec 04             	sub    $0x4,%esp
  800f66:	68 6c 2a 80 00       	push   $0x802a6c
  800f6b:	6a 1d                	push   $0x1d
  800f6d:	68 e8 2a 80 00       	push   $0x802ae8
  800f72:	e8 ca 13 00 00       	call   802341 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f77:	50                   	push   %eax
  800f78:	68 a4 2a 80 00       	push   $0x802aa4
  800f7d:	6a 29                	push   $0x29
  800f7f:	68 e8 2a 80 00       	push   $0x802ae8
  800f84:	e8 b8 13 00 00       	call   802341 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f89:	50                   	push   %eax
  800f8a:	68 c8 2a 80 00       	push   $0x802ac8
  800f8f:	6a 2e                	push   $0x2e
  800f91:	68 e8 2a 80 00       	push   $0x802ae8
  800f96:	e8 a6 13 00 00       	call   802341 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800f9b:	50                   	push   %eax
  800f9c:	68 f3 2a 80 00       	push   $0x802af3
  800fa1:	6a 30                	push   $0x30
  800fa3:	68 e8 2a 80 00       	push   $0x802ae8
  800fa8:	e8 94 13 00 00       	call   802341 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800fad:	50                   	push   %eax
  800fae:	68 c8 2a 80 00       	push   $0x802ac8
  800fb3:	6a 32                	push   $0x32
  800fb5:	68 e8 2a 80 00       	push   $0x802ae8
  800fba:	e8 82 13 00 00       	call   802341 <_panic>

00800fbf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	57                   	push   %edi
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800fc8:	68 c1 0e 80 00       	push   $0x800ec1
  800fcd:	e8 b5 13 00 00       	call   802387 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd2:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd7:	cd 30                	int    $0x30
  800fd9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800fdc:	83 c4 10             	add    $0x10,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	78 2d                	js     801010 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fe3:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800fe8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fec:	75 73                	jne    801061 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fee:	e8 3e fc ff ff       	call   800c31 <sys_getenvid>
  800ff3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ffb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801000:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  801005:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801010:	50                   	push   %eax
  801011:	68 11 2b 80 00       	push   $0x802b11
  801016:	6a 78                	push   $0x78
  801018:	68 e8 2a 80 00       	push   $0x802ae8
  80101d:	e8 1f 13 00 00       	call   802341 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	ff 75 e4             	push   -0x1c(%ebp)
  801028:	57                   	push   %edi
  801029:	ff 75 dc             	push   -0x24(%ebp)
  80102c:	57                   	push   %edi
  80102d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801030:	56                   	push   %esi
  801031:	e8 7c fc ff ff       	call   800cb2 <sys_page_map>
	if(r<0) return r;
  801036:	83 c4 20             	add    $0x20,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 cb                	js     801008 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	ff 75 e4             	push   -0x1c(%ebp)
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	e8 66 fc ff ff       	call   800cb2 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 76                	js     8010c9 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801053:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801059:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80105f:	74 75                	je     8010d6 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801061:	89 d8                	mov    %ebx,%eax
  801063:	c1 e8 16             	shr    $0x16,%eax
  801066:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106d:	a8 01                	test   $0x1,%al
  80106f:	74 e2                	je     801053 <fork+0x94>
  801071:	89 de                	mov    %ebx,%esi
  801073:	c1 ee 0c             	shr    $0xc,%esi
  801076:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80107d:	a8 01                	test   $0x1,%al
  80107f:	74 d2                	je     801053 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801081:	e8 ab fb ff ff       	call   800c31 <sys_getenvid>
  801086:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801089:	89 f7                	mov    %esi,%edi
  80108b:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  80108e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801095:	89 c1                	mov    %eax,%ecx
  801097:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80109d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8010a0:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8010a7:	f6 c6 04             	test   $0x4,%dh
  8010aa:	0f 85 72 ff ff ff    	jne    801022 <fork+0x63>
		perm &= ~PTE_W;
  8010b0:	25 05 0e 00 00       	and    $0xe05,%eax
  8010b5:	80 cc 08             	or     $0x8,%ah
  8010b8:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8010be:	0f 44 c1             	cmove  %ecx,%eax
  8010c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c4:	e9 59 ff ff ff       	jmp    801022 <fork+0x63>
  8010c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ce:	0f 4f c2             	cmovg  %edx,%eax
  8010d1:	e9 32 ff ff ff       	jmp    801008 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  8010d6:	83 ec 04             	sub    $0x4,%esp
  8010d9:	6a 07                	push   $0x7
  8010db:	68 00 f0 bf ee       	push   $0xeebff000
  8010e0:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010e3:	57                   	push   %edi
  8010e4:	e8 86 fb ff ff       	call   800c6f <sys_page_alloc>
	if(r<0) return r;
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	0f 88 14 ff ff ff    	js     801008 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010f4:	83 ec 08             	sub    $0x8,%esp
  8010f7:	68 fd 23 80 00       	push   $0x8023fd
  8010fc:	57                   	push   %edi
  8010fd:	e8 b8 fc ff ff       	call   800dba <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	85 c0                	test   %eax,%eax
  801107:	0f 88 fb fe ff ff    	js     801008 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80110d:	83 ec 08             	sub    $0x8,%esp
  801110:	6a 02                	push   $0x2
  801112:	57                   	push   %edi
  801113:	e8 1e fc ff ff       	call   800d36 <sys_env_set_status>
	if(r<0) return r;
  801118:	83 c4 10             	add    $0x10,%esp
	return envid;
  80111b:	85 c0                	test   %eax,%eax
  80111d:	0f 49 c7             	cmovns %edi,%eax
  801120:	e9 e3 fe ff ff       	jmp    801008 <fork+0x49>

00801125 <sfork>:

// Challenge!
int
sfork(void)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80112b:	68 21 2b 80 00       	push   $0x802b21
  801130:	68 a1 00 00 00       	push   $0xa1
  801135:	68 e8 2a 80 00       	push   $0x802ae8
  80113a:	e8 02 12 00 00       	call   802341 <_panic>

0080113f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	8b 75 08             	mov    0x8(%ebp),%esi
  801147:	8b 45 0c             	mov    0xc(%ebp),%eax
  80114a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80114d:	85 c0                	test   %eax,%eax
  80114f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801154:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801157:	83 ec 0c             	sub    $0xc,%esp
  80115a:	50                   	push   %eax
  80115b:	e8 bf fc ff ff       	call   800e1f <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 f6                	test   %esi,%esi
  801165:	74 14                	je     80117b <ipc_recv+0x3c>
  801167:	ba 00 00 00 00       	mov    $0x0,%edx
  80116c:	85 c0                	test   %eax,%eax
  80116e:	78 09                	js     801179 <ipc_recv+0x3a>
  801170:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801176:	8b 52 74             	mov    0x74(%edx),%edx
  801179:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80117b:	85 db                	test   %ebx,%ebx
  80117d:	74 14                	je     801193 <ipc_recv+0x54>
  80117f:	ba 00 00 00 00       	mov    $0x0,%edx
  801184:	85 c0                	test   %eax,%eax
  801186:	78 09                	js     801191 <ipc_recv+0x52>
  801188:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80118e:	8b 52 78             	mov    0x78(%edx),%edx
  801191:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801193:	85 c0                	test   %eax,%eax
  801195:	78 08                	js     80119f <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801197:	a1 00 40 80 00       	mov    0x804000,%eax
  80119c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80119f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011a2:	5b                   	pop    %ebx
  8011a3:	5e                   	pop    %esi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	57                   	push   %edi
  8011aa:	56                   	push   %esi
  8011ab:	53                   	push   %ebx
  8011ac:	83 ec 0c             	sub    $0xc,%esp
  8011af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8011b8:	85 db                	test   %ebx,%ebx
  8011ba:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011bf:	0f 44 d8             	cmove  %eax,%ebx
  8011c2:	eb 05                	jmp    8011c9 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8011c4:	e8 87 fa ff ff       	call   800c50 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8011c9:	ff 75 14             	push   0x14(%ebp)
  8011cc:	53                   	push   %ebx
  8011cd:	56                   	push   %esi
  8011ce:	57                   	push   %edi
  8011cf:	e8 28 fc ff ff       	call   800dfc <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011da:	74 e8                	je     8011c4 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 08                	js     8011e8 <ipc_send+0x42>
	}while (r<0);

}
  8011e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8011e8:	50                   	push   %eax
  8011e9:	68 37 2b 80 00       	push   $0x802b37
  8011ee:	6a 3d                	push   $0x3d
  8011f0:	68 4b 2b 80 00       	push   $0x802b4b
  8011f5:	e8 47 11 00 00       	call   802341 <_panic>

008011fa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801200:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801205:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801208:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80120e:	8b 52 50             	mov    0x50(%edx),%edx
  801211:	39 ca                	cmp    %ecx,%edx
  801213:	74 11                	je     801226 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801215:	83 c0 01             	add    $0x1,%eax
  801218:	3d 00 04 00 00       	cmp    $0x400,%eax
  80121d:	75 e6                	jne    801205 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
  801224:	eb 0b                	jmp    801231 <ipc_find_env+0x37>
			return envs[i].env_id;
  801226:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801229:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80122e:	8b 40 48             	mov    0x48(%eax),%eax
}
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
  801239:	05 00 00 00 30       	add    $0x30000000,%eax
  80123e:	c1 e8 0c             	shr    $0xc,%eax
}
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801246:	8b 45 08             	mov    0x8(%ebp),%eax
  801249:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80124e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801253:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801262:	89 c2                	mov    %eax,%edx
  801264:	c1 ea 16             	shr    $0x16,%edx
  801267:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126e:	f6 c2 01             	test   $0x1,%dl
  801271:	74 29                	je     80129c <fd_alloc+0x42>
  801273:	89 c2                	mov    %eax,%edx
  801275:	c1 ea 0c             	shr    $0xc,%edx
  801278:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127f:	f6 c2 01             	test   $0x1,%dl
  801282:	74 18                	je     80129c <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801284:	05 00 10 00 00       	add    $0x1000,%eax
  801289:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80128e:	75 d2                	jne    801262 <fd_alloc+0x8>
  801290:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801295:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80129a:	eb 05                	jmp    8012a1 <fd_alloc+0x47>
			return 0;
  80129c:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8012a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a4:	89 02                	mov    %eax,(%edx)
}
  8012a6:	89 c8                	mov    %ecx,%eax
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b0:	83 f8 1f             	cmp    $0x1f,%eax
  8012b3:	77 30                	ja     8012e5 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012b5:	c1 e0 0c             	shl    $0xc,%eax
  8012b8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012bd:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012c3:	f6 c2 01             	test   $0x1,%dl
  8012c6:	74 24                	je     8012ec <fd_lookup+0x42>
  8012c8:	89 c2                	mov    %eax,%edx
  8012ca:	c1 ea 0c             	shr    $0xc,%edx
  8012cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d4:	f6 c2 01             	test   $0x1,%dl
  8012d7:	74 1a                	je     8012f3 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012dc:	89 02                	mov    %eax,(%edx)
	return 0;
  8012de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    
		return -E_INVAL;
  8012e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ea:	eb f7                	jmp    8012e3 <fd_lookup+0x39>
		return -E_INVAL;
  8012ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f1:	eb f0                	jmp    8012e3 <fd_lookup+0x39>
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f8:	eb e9                	jmp    8012e3 <fd_lookup+0x39>

008012fa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 04             	sub    $0x4,%esp
  801301:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801304:	b8 00 00 00 00       	mov    $0x0,%eax
  801309:	bb 0c 30 80 00       	mov    $0x80300c,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80130e:	39 13                	cmp    %edx,(%ebx)
  801310:	74 37                	je     801349 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801312:	83 c0 01             	add    $0x1,%eax
  801315:	8b 1c 85 d4 2b 80 00 	mov    0x802bd4(,%eax,4),%ebx
  80131c:	85 db                	test   %ebx,%ebx
  80131e:	75 ee                	jne    80130e <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801320:	a1 00 40 80 00       	mov    0x804000,%eax
  801325:	8b 40 48             	mov    0x48(%eax),%eax
  801328:	83 ec 04             	sub    $0x4,%esp
  80132b:	52                   	push   %edx
  80132c:	50                   	push   %eax
  80132d:	68 58 2b 80 00       	push   $0x802b58
  801332:	e8 62 ef ff ff       	call   800299 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80133f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801342:	89 1a                	mov    %ebx,(%edx)
}
  801344:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801347:	c9                   	leave  
  801348:	c3                   	ret    
			return 0;
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
  80134e:	eb ef                	jmp    80133f <dev_lookup+0x45>

00801350 <fd_close>:
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	57                   	push   %edi
  801354:	56                   	push   %esi
  801355:	53                   	push   %ebx
  801356:	83 ec 24             	sub    $0x24,%esp
  801359:	8b 75 08             	mov    0x8(%ebp),%esi
  80135c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80135f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801362:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801363:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801369:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80136c:	50                   	push   %eax
  80136d:	e8 38 ff ff ff       	call   8012aa <fd_lookup>
  801372:	89 c3                	mov    %eax,%ebx
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	85 c0                	test   %eax,%eax
  801379:	78 05                	js     801380 <fd_close+0x30>
	    || fd != fd2)
  80137b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80137e:	74 16                	je     801396 <fd_close+0x46>
		return (must_exist ? r : 0);
  801380:	89 f8                	mov    %edi,%eax
  801382:	84 c0                	test   %al,%al
  801384:	b8 00 00 00 00       	mov    $0x0,%eax
  801389:	0f 44 d8             	cmove  %eax,%ebx
}
  80138c:	89 d8                	mov    %ebx,%eax
  80138e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801391:	5b                   	pop    %ebx
  801392:	5e                   	pop    %esi
  801393:	5f                   	pop    %edi
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80139c:	50                   	push   %eax
  80139d:	ff 36                	push   (%esi)
  80139f:	e8 56 ff ff ff       	call   8012fa <dev_lookup>
  8013a4:	89 c3                	mov    %eax,%ebx
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 1a                	js     8013c7 <fd_close+0x77>
		if (dev->dev_close)
  8013ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013b0:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8013b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	74 0b                	je     8013c7 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8013bc:	83 ec 0c             	sub    $0xc,%esp
  8013bf:	56                   	push   %esi
  8013c0:	ff d0                	call   *%eax
  8013c2:	89 c3                	mov    %eax,%ebx
  8013c4:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	56                   	push   %esi
  8013cb:	6a 00                	push   $0x0
  8013cd:	e8 22 f9 ff ff       	call   800cf4 <sys_page_unmap>
	return r;
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	eb b5                	jmp    80138c <fd_close+0x3c>

008013d7 <close>:

int
close(int fdnum)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 75 08             	push   0x8(%ebp)
  8013e4:	e8 c1 fe ff ff       	call   8012aa <fd_lookup>
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	79 02                	jns    8013f2 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    
		return fd_close(fd, 1);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	6a 01                	push   $0x1
  8013f7:	ff 75 f4             	push   -0xc(%ebp)
  8013fa:	e8 51 ff ff ff       	call   801350 <fd_close>
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	eb ec                	jmp    8013f0 <close+0x19>

00801404 <close_all>:

void
close_all(void)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	53                   	push   %ebx
  801408:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80140b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801410:	83 ec 0c             	sub    $0xc,%esp
  801413:	53                   	push   %ebx
  801414:	e8 be ff ff ff       	call   8013d7 <close>
	for (i = 0; i < MAXFD; i++)
  801419:	83 c3 01             	add    $0x1,%ebx
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	83 fb 20             	cmp    $0x20,%ebx
  801422:	75 ec                	jne    801410 <close_all+0xc>
}
  801424:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	57                   	push   %edi
  80142d:	56                   	push   %esi
  80142e:	53                   	push   %ebx
  80142f:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801432:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	ff 75 08             	push   0x8(%ebp)
  801439:	e8 6c fe ff ff       	call   8012aa <fd_lookup>
  80143e:	89 c3                	mov    %eax,%ebx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 7f                	js     8014c6 <dup+0x9d>
		return r;
	close(newfdnum);
  801447:	83 ec 0c             	sub    $0xc,%esp
  80144a:	ff 75 0c             	push   0xc(%ebp)
  80144d:	e8 85 ff ff ff       	call   8013d7 <close>

	newfd = INDEX2FD(newfdnum);
  801452:	8b 75 0c             	mov    0xc(%ebp),%esi
  801455:	c1 e6 0c             	shl    $0xc,%esi
  801458:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80145e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801461:	89 3c 24             	mov    %edi,(%esp)
  801464:	e8 da fd ff ff       	call   801243 <fd2data>
  801469:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80146b:	89 34 24             	mov    %esi,(%esp)
  80146e:	e8 d0 fd ff ff       	call   801243 <fd2data>
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801479:	89 d8                	mov    %ebx,%eax
  80147b:	c1 e8 16             	shr    $0x16,%eax
  80147e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801485:	a8 01                	test   $0x1,%al
  801487:	74 11                	je     80149a <dup+0x71>
  801489:	89 d8                	mov    %ebx,%eax
  80148b:	c1 e8 0c             	shr    $0xc,%eax
  80148e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801495:	f6 c2 01             	test   $0x1,%dl
  801498:	75 36                	jne    8014d0 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149a:	89 f8                	mov    %edi,%eax
  80149c:	c1 e8 0c             	shr    $0xc,%eax
  80149f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ae:	50                   	push   %eax
  8014af:	56                   	push   %esi
  8014b0:	6a 00                	push   $0x0
  8014b2:	57                   	push   %edi
  8014b3:	6a 00                	push   $0x0
  8014b5:	e8 f8 f7 ff ff       	call   800cb2 <sys_page_map>
  8014ba:	89 c3                	mov    %eax,%ebx
  8014bc:	83 c4 20             	add    $0x20,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 33                	js     8014f6 <dup+0xcd>
		goto err;

	return newfdnum;
  8014c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014c6:	89 d8                	mov    %ebx,%eax
  8014c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	5f                   	pop    %edi
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d7:	83 ec 0c             	sub    $0xc,%esp
  8014da:	25 07 0e 00 00       	and    $0xe07,%eax
  8014df:	50                   	push   %eax
  8014e0:	ff 75 d4             	push   -0x2c(%ebp)
  8014e3:	6a 00                	push   $0x0
  8014e5:	53                   	push   %ebx
  8014e6:	6a 00                	push   $0x0
  8014e8:	e8 c5 f7 ff ff       	call   800cb2 <sys_page_map>
  8014ed:	89 c3                	mov    %eax,%ebx
  8014ef:	83 c4 20             	add    $0x20,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	79 a4                	jns    80149a <dup+0x71>
	sys_page_unmap(0, newfd);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	56                   	push   %esi
  8014fa:	6a 00                	push   $0x0
  8014fc:	e8 f3 f7 ff ff       	call   800cf4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801501:	83 c4 08             	add    $0x8,%esp
  801504:	ff 75 d4             	push   -0x2c(%ebp)
  801507:	6a 00                	push   $0x0
  801509:	e8 e6 f7 ff ff       	call   800cf4 <sys_page_unmap>
	return r;
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	eb b3                	jmp    8014c6 <dup+0x9d>

00801513 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	56                   	push   %esi
  801517:	53                   	push   %ebx
  801518:	83 ec 18             	sub    $0x18,%esp
  80151b:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	56                   	push   %esi
  801523:	e8 82 fd ff ff       	call   8012aa <fd_lookup>
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 3c                	js     80156b <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152f:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	ff 33                	push   (%ebx)
  80153b:	e8 ba fd ff ff       	call   8012fa <dev_lookup>
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	85 c0                	test   %eax,%eax
  801545:	78 24                	js     80156b <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801547:	8b 43 08             	mov    0x8(%ebx),%eax
  80154a:	83 e0 03             	and    $0x3,%eax
  80154d:	83 f8 01             	cmp    $0x1,%eax
  801550:	74 20                	je     801572 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801555:	8b 40 08             	mov    0x8(%eax),%eax
  801558:	85 c0                	test   %eax,%eax
  80155a:	74 37                	je     801593 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	ff 75 10             	push   0x10(%ebp)
  801562:	ff 75 0c             	push   0xc(%ebp)
  801565:	53                   	push   %ebx
  801566:	ff d0                	call   *%eax
  801568:	83 c4 10             	add    $0x10,%esp
}
  80156b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5d                   	pop    %ebp
  801571:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801572:	a1 00 40 80 00       	mov    0x804000,%eax
  801577:	8b 40 48             	mov    0x48(%eax),%eax
  80157a:	83 ec 04             	sub    $0x4,%esp
  80157d:	56                   	push   %esi
  80157e:	50                   	push   %eax
  80157f:	68 99 2b 80 00       	push   $0x802b99
  801584:	e8 10 ed ff ff       	call   800299 <cprintf>
		return -E_INVAL;
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801591:	eb d8                	jmp    80156b <read+0x58>
		return -E_NOT_SUPP;
  801593:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801598:	eb d1                	jmp    80156b <read+0x58>

0080159a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	57                   	push   %edi
  80159e:	56                   	push   %esi
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 0c             	sub    $0xc,%esp
  8015a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ae:	eb 02                	jmp    8015b2 <readn+0x18>
  8015b0:	01 c3                	add    %eax,%ebx
  8015b2:	39 f3                	cmp    %esi,%ebx
  8015b4:	73 21                	jae    8015d7 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015b6:	83 ec 04             	sub    $0x4,%esp
  8015b9:	89 f0                	mov    %esi,%eax
  8015bb:	29 d8                	sub    %ebx,%eax
  8015bd:	50                   	push   %eax
  8015be:	89 d8                	mov    %ebx,%eax
  8015c0:	03 45 0c             	add    0xc(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	57                   	push   %edi
  8015c5:	e8 49 ff ff ff       	call   801513 <read>
		if (m < 0)
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 04                	js     8015d5 <readn+0x3b>
			return m;
		if (m == 0)
  8015d1:	75 dd                	jne    8015b0 <readn+0x16>
  8015d3:	eb 02                	jmp    8015d7 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d5:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015d7:	89 d8                	mov    %ebx,%eax
  8015d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015dc:	5b                   	pop    %ebx
  8015dd:	5e                   	pop    %esi
  8015de:	5f                   	pop    %edi
  8015df:	5d                   	pop    %ebp
  8015e0:	c3                   	ret    

008015e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	56                   	push   %esi
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 18             	sub    $0x18,%esp
  8015e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	53                   	push   %ebx
  8015f1:	e8 b4 fc ff ff       	call   8012aa <fd_lookup>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 37                	js     801634 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fd:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	ff 36                	push   (%esi)
  801609:	e8 ec fc ff ff       	call   8012fa <dev_lookup>
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	85 c0                	test   %eax,%eax
  801613:	78 1f                	js     801634 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801615:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801619:	74 20                	je     80163b <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161e:	8b 40 0c             	mov    0xc(%eax),%eax
  801621:	85 c0                	test   %eax,%eax
  801623:	74 37                	je     80165c <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	ff 75 10             	push   0x10(%ebp)
  80162b:	ff 75 0c             	push   0xc(%ebp)
  80162e:	56                   	push   %esi
  80162f:	ff d0                	call   *%eax
  801631:	83 c4 10             	add    $0x10,%esp
}
  801634:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801637:	5b                   	pop    %ebx
  801638:	5e                   	pop    %esi
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80163b:	a1 00 40 80 00       	mov    0x804000,%eax
  801640:	8b 40 48             	mov    0x48(%eax),%eax
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	53                   	push   %ebx
  801647:	50                   	push   %eax
  801648:	68 b5 2b 80 00       	push   $0x802bb5
  80164d:	e8 47 ec ff ff       	call   800299 <cprintf>
		return -E_INVAL;
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80165a:	eb d8                	jmp    801634 <write+0x53>
		return -E_NOT_SUPP;
  80165c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801661:	eb d1                	jmp    801634 <write+0x53>

00801663 <seek>:

int
seek(int fdnum, off_t offset)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801669:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	ff 75 08             	push   0x8(%ebp)
  801670:	e8 35 fc ff ff       	call   8012aa <fd_lookup>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 0e                	js     80168a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80167c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801682:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	56                   	push   %esi
  801690:	53                   	push   %ebx
  801691:	83 ec 18             	sub    $0x18,%esp
  801694:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801697:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169a:	50                   	push   %eax
  80169b:	53                   	push   %ebx
  80169c:	e8 09 fc ff ff       	call   8012aa <fd_lookup>
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 34                	js     8016dc <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a8:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	ff 36                	push   (%esi)
  8016b4:	e8 41 fc ff ff       	call   8012fa <dev_lookup>
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 1c                	js     8016dc <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c0:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8016c4:	74 1d                	je     8016e3 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c9:	8b 40 18             	mov    0x18(%eax),%eax
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	74 34                	je     801704 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d0:	83 ec 08             	sub    $0x8,%esp
  8016d3:	ff 75 0c             	push   0xc(%ebp)
  8016d6:	56                   	push   %esi
  8016d7:	ff d0                	call   *%eax
  8016d9:	83 c4 10             	add    $0x10,%esp
}
  8016dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016df:	5b                   	pop    %ebx
  8016e0:	5e                   	pop    %esi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016e3:	a1 00 40 80 00       	mov    0x804000,%eax
  8016e8:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016eb:	83 ec 04             	sub    $0x4,%esp
  8016ee:	53                   	push   %ebx
  8016ef:	50                   	push   %eax
  8016f0:	68 78 2b 80 00       	push   $0x802b78
  8016f5:	e8 9f eb ff ff       	call   800299 <cprintf>
		return -E_INVAL;
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801702:	eb d8                	jmp    8016dc <ftruncate+0x50>
		return -E_NOT_SUPP;
  801704:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801709:	eb d1                	jmp    8016dc <ftruncate+0x50>

0080170b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	56                   	push   %esi
  80170f:	53                   	push   %ebx
  801710:	83 ec 18             	sub    $0x18,%esp
  801713:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	ff 75 08             	push   0x8(%ebp)
  80171d:	e8 88 fb ff ff       	call   8012aa <fd_lookup>
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	85 c0                	test   %eax,%eax
  801727:	78 49                	js     801772 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801729:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801732:	50                   	push   %eax
  801733:	ff 36                	push   (%esi)
  801735:	e8 c0 fb ff ff       	call   8012fa <dev_lookup>
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	85 c0                	test   %eax,%eax
  80173f:	78 31                	js     801772 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801741:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801744:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801748:	74 2f                	je     801779 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80174a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80174d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801754:	00 00 00 
	stat->st_isdir = 0;
  801757:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80175e:	00 00 00 
	stat->st_dev = dev;
  801761:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	53                   	push   %ebx
  80176b:	56                   	push   %esi
  80176c:	ff 50 14             	call   *0x14(%eax)
  80176f:	83 c4 10             	add    $0x10,%esp
}
  801772:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    
		return -E_NOT_SUPP;
  801779:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80177e:	eb f2                	jmp    801772 <fstat+0x67>

00801780 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801785:	83 ec 08             	sub    $0x8,%esp
  801788:	6a 00                	push   $0x0
  80178a:	ff 75 08             	push   0x8(%ebp)
  80178d:	e8 e4 01 00 00       	call   801976 <open>
  801792:	89 c3                	mov    %eax,%ebx
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	85 c0                	test   %eax,%eax
  801799:	78 1b                	js     8017b6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80179b:	83 ec 08             	sub    $0x8,%esp
  80179e:	ff 75 0c             	push   0xc(%ebp)
  8017a1:	50                   	push   %eax
  8017a2:	e8 64 ff ff ff       	call   80170b <fstat>
  8017a7:	89 c6                	mov    %eax,%esi
	close(fd);
  8017a9:	89 1c 24             	mov    %ebx,(%esp)
  8017ac:	e8 26 fc ff ff       	call   8013d7 <close>
	return r;
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	89 f3                	mov    %esi,%ebx
}
  8017b6:	89 d8                	mov    %ebx,%eax
  8017b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bb:	5b                   	pop    %ebx
  8017bc:	5e                   	pop    %esi
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	56                   	push   %esi
  8017c3:	53                   	push   %ebx
  8017c4:	89 c6                	mov    %eax,%esi
  8017c6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017c8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8017cf:	74 27                	je     8017f8 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d1:	6a 07                	push   $0x7
  8017d3:	68 00 50 80 00       	push   $0x805000
  8017d8:	56                   	push   %esi
  8017d9:	ff 35 00 60 80 00    	push   0x806000
  8017df:	e8 c2 f9 ff ff       	call   8011a6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e4:	83 c4 0c             	add    $0xc,%esp
  8017e7:	6a 00                	push   $0x0
  8017e9:	53                   	push   %ebx
  8017ea:	6a 00                	push   $0x0
  8017ec:	e8 4e f9 ff ff       	call   80113f <ipc_recv>
}
  8017f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f4:	5b                   	pop    %ebx
  8017f5:	5e                   	pop    %esi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f8:	83 ec 0c             	sub    $0xc,%esp
  8017fb:	6a 01                	push   $0x1
  8017fd:	e8 f8 f9 ff ff       	call   8011fa <ipc_find_env>
  801802:	a3 00 60 80 00       	mov    %eax,0x806000
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	eb c5                	jmp    8017d1 <fsipc+0x12>

0080180c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	8b 40 0c             	mov    0xc(%eax),%eax
  801818:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80181d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801820:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801825:	ba 00 00 00 00       	mov    $0x0,%edx
  80182a:	b8 02 00 00 00       	mov    $0x2,%eax
  80182f:	e8 8b ff ff ff       	call   8017bf <fsipc>
}
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <devfile_flush>:
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	8b 40 0c             	mov    0xc(%eax),%eax
  801842:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801847:	ba 00 00 00 00       	mov    $0x0,%edx
  80184c:	b8 06 00 00 00       	mov    $0x6,%eax
  801851:	e8 69 ff ff ff       	call   8017bf <fsipc>
}
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <devfile_stat>:
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	53                   	push   %ebx
  80185c:	83 ec 04             	sub    $0x4,%esp
  80185f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	8b 40 0c             	mov    0xc(%eax),%eax
  801868:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80186d:	ba 00 00 00 00       	mov    $0x0,%edx
  801872:	b8 05 00 00 00       	mov    $0x5,%eax
  801877:	e8 43 ff ff ff       	call   8017bf <fsipc>
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 2c                	js     8018ac <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	68 00 50 80 00       	push   $0x805000
  801888:	53                   	push   %ebx
  801889:	e8 e5 ef ff ff       	call   800873 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80188e:	a1 80 50 80 00       	mov    0x805080,%eax
  801893:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801899:	a1 84 50 80 00       	mov    0x805084,%eax
  80189e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018a4:	83 c4 10             	add    $0x10,%esp
  8018a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <devfile_write>:
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	83 ec 0c             	sub    $0xc,%esp
  8018b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ba:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018bf:	39 d0                	cmp    %edx,%eax
  8018c1:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8018c7:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ca:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018d0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018d5:	50                   	push   %eax
  8018d6:	ff 75 0c             	push   0xc(%ebp)
  8018d9:	68 08 50 80 00       	push   $0x805008
  8018de:	e8 26 f1 ff ff       	call   800a09 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8018e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ed:	e8 cd fe ff ff       	call   8017bf <fsipc>
}
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <devfile_read>:
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801902:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801907:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80190d:	ba 00 00 00 00       	mov    $0x0,%edx
  801912:	b8 03 00 00 00       	mov    $0x3,%eax
  801917:	e8 a3 fe ff ff       	call   8017bf <fsipc>
  80191c:	89 c3                	mov    %eax,%ebx
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 1f                	js     801941 <devfile_read+0x4d>
	assert(r <= n);
  801922:	39 f0                	cmp    %esi,%eax
  801924:	77 24                	ja     80194a <devfile_read+0x56>
	assert(r <= PGSIZE);
  801926:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80192b:	7f 33                	jg     801960 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80192d:	83 ec 04             	sub    $0x4,%esp
  801930:	50                   	push   %eax
  801931:	68 00 50 80 00       	push   $0x805000
  801936:	ff 75 0c             	push   0xc(%ebp)
  801939:	e8 cb f0 ff ff       	call   800a09 <memmove>
	return r;
  80193e:	83 c4 10             	add    $0x10,%esp
}
  801941:	89 d8                	mov    %ebx,%eax
  801943:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801946:	5b                   	pop    %ebx
  801947:	5e                   	pop    %esi
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    
	assert(r <= n);
  80194a:	68 e8 2b 80 00       	push   $0x802be8
  80194f:	68 ef 2b 80 00       	push   $0x802bef
  801954:	6a 7c                	push   $0x7c
  801956:	68 04 2c 80 00       	push   $0x802c04
  80195b:	e8 e1 09 00 00       	call   802341 <_panic>
	assert(r <= PGSIZE);
  801960:	68 0f 2c 80 00       	push   $0x802c0f
  801965:	68 ef 2b 80 00       	push   $0x802bef
  80196a:	6a 7d                	push   $0x7d
  80196c:	68 04 2c 80 00       	push   $0x802c04
  801971:	e8 cb 09 00 00       	call   802341 <_panic>

00801976 <open>:
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	56                   	push   %esi
  80197a:	53                   	push   %ebx
  80197b:	83 ec 1c             	sub    $0x1c,%esp
  80197e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801981:	56                   	push   %esi
  801982:	e8 b1 ee ff ff       	call   800838 <strlen>
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80198f:	7f 6c                	jg     8019fd <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801997:	50                   	push   %eax
  801998:	e8 bd f8 ff ff       	call   80125a <fd_alloc>
  80199d:	89 c3                	mov    %eax,%ebx
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	78 3c                	js     8019e2 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	56                   	push   %esi
  8019aa:	68 00 50 80 00       	push   $0x805000
  8019af:	e8 bf ee ff ff       	call   800873 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b7:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c4:	e8 f6 fd ff ff       	call   8017bf <fsipc>
  8019c9:	89 c3                	mov    %eax,%ebx
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 19                	js     8019eb <open+0x75>
	return fd2num(fd);
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	ff 75 f4             	push   -0xc(%ebp)
  8019d8:	e8 56 f8 ff ff       	call   801233 <fd2num>
  8019dd:	89 c3                	mov    %eax,%ebx
  8019df:	83 c4 10             	add    $0x10,%esp
}
  8019e2:	89 d8                	mov    %ebx,%eax
  8019e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e7:	5b                   	pop    %ebx
  8019e8:	5e                   	pop    %esi
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    
		fd_close(fd, 0);
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	6a 00                	push   $0x0
  8019f0:	ff 75 f4             	push   -0xc(%ebp)
  8019f3:	e8 58 f9 ff ff       	call   801350 <fd_close>
		return r;
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	eb e5                	jmp    8019e2 <open+0x6c>
		return -E_BAD_PATH;
  8019fd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a02:	eb de                	jmp    8019e2 <open+0x6c>

00801a04 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a14:	e8 a6 fd ff ff       	call   8017bf <fsipc>
}
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a21:	68 1b 2c 80 00       	push   $0x802c1b
  801a26:	ff 75 0c             	push   0xc(%ebp)
  801a29:	e8 45 ee ff ff       	call   800873 <strcpy>
	return 0;
}
  801a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <devsock_close>:
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	53                   	push   %ebx
  801a39:	83 ec 10             	sub    $0x10,%esp
  801a3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a3f:	53                   	push   %ebx
  801a40:	e8 de 09 00 00       	call   802423 <pageref>
  801a45:	89 c2                	mov    %eax,%edx
  801a47:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a4a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a4f:	83 fa 01             	cmp    $0x1,%edx
  801a52:	74 05                	je     801a59 <devsock_close+0x24>
}
  801a54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a59:	83 ec 0c             	sub    $0xc,%esp
  801a5c:	ff 73 0c             	push   0xc(%ebx)
  801a5f:	e8 b7 02 00 00       	call   801d1b <nsipc_close>
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	eb eb                	jmp    801a54 <devsock_close+0x1f>

00801a69 <devsock_write>:
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a6f:	6a 00                	push   $0x0
  801a71:	ff 75 10             	push   0x10(%ebp)
  801a74:	ff 75 0c             	push   0xc(%ebp)
  801a77:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7a:	ff 70 0c             	push   0xc(%eax)
  801a7d:	e8 79 03 00 00       	call   801dfb <nsipc_send>
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <devsock_read>:
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a8a:	6a 00                	push   $0x0
  801a8c:	ff 75 10             	push   0x10(%ebp)
  801a8f:	ff 75 0c             	push   0xc(%ebp)
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	ff 70 0c             	push   0xc(%eax)
  801a98:	e8 ef 02 00 00       	call   801d8c <nsipc_recv>
}
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <fd2sockid>:
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aa5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801aa8:	52                   	push   %edx
  801aa9:	50                   	push   %eax
  801aaa:	e8 fb f7 ff ff       	call   8012aa <fd_lookup>
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 10                	js     801ac6 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab9:	8b 0d 28 30 80 00    	mov    0x803028,%ecx
  801abf:	39 08                	cmp    %ecx,(%eax)
  801ac1:	75 05                	jne    801ac8 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801ac3:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    
		return -E_NOT_SUPP;
  801ac8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801acd:	eb f7                	jmp    801ac6 <fd2sockid+0x27>

00801acf <alloc_sockfd>:
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 1c             	sub    $0x1c,%esp
  801ad7:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801ad9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adc:	50                   	push   %eax
  801add:	e8 78 f7 ff ff       	call   80125a <fd_alloc>
  801ae2:	89 c3                	mov    %eax,%ebx
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 43                	js     801b2e <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801aeb:	83 ec 04             	sub    $0x4,%esp
  801aee:	68 07 04 00 00       	push   $0x407
  801af3:	ff 75 f4             	push   -0xc(%ebp)
  801af6:	6a 00                	push   $0x0
  801af8:	e8 72 f1 ff ff       	call   800c6f <sys_page_alloc>
  801afd:	89 c3                	mov    %eax,%ebx
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	85 c0                	test   %eax,%eax
  801b04:	78 28                	js     801b2e <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b09:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801b0f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b14:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b1b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	50                   	push   %eax
  801b22:	e8 0c f7 ff ff       	call   801233 <fd2num>
  801b27:	89 c3                	mov    %eax,%ebx
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	eb 0c                	jmp    801b3a <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b2e:	83 ec 0c             	sub    $0xc,%esp
  801b31:	56                   	push   %esi
  801b32:	e8 e4 01 00 00       	call   801d1b <nsipc_close>
		return r;
  801b37:	83 c4 10             	add    $0x10,%esp
}
  801b3a:	89 d8                	mov    %ebx,%eax
  801b3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <accept>:
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	e8 4e ff ff ff       	call   801a9f <fd2sockid>
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 1b                	js     801b70 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b55:	83 ec 04             	sub    $0x4,%esp
  801b58:	ff 75 10             	push   0x10(%ebp)
  801b5b:	ff 75 0c             	push   0xc(%ebp)
  801b5e:	50                   	push   %eax
  801b5f:	e8 0e 01 00 00       	call   801c72 <nsipc_accept>
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 05                	js     801b70 <accept+0x2d>
	return alloc_sockfd(r);
  801b6b:	e8 5f ff ff ff       	call   801acf <alloc_sockfd>
}
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    

00801b72 <bind>:
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	e8 1f ff ff ff       	call   801a9f <fd2sockid>
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 12                	js     801b96 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	ff 75 10             	push   0x10(%ebp)
  801b8a:	ff 75 0c             	push   0xc(%ebp)
  801b8d:	50                   	push   %eax
  801b8e:	e8 31 01 00 00       	call   801cc4 <nsipc_bind>
  801b93:	83 c4 10             	add    $0x10,%esp
}
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <shutdown>:
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba1:	e8 f9 fe ff ff       	call   801a9f <fd2sockid>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 0f                	js     801bb9 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801baa:	83 ec 08             	sub    $0x8,%esp
  801bad:	ff 75 0c             	push   0xc(%ebp)
  801bb0:	50                   	push   %eax
  801bb1:	e8 43 01 00 00       	call   801cf9 <nsipc_shutdown>
  801bb6:	83 c4 10             	add    $0x10,%esp
}
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    

00801bbb <connect>:
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc4:	e8 d6 fe ff ff       	call   801a9f <fd2sockid>
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	78 12                	js     801bdf <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801bcd:	83 ec 04             	sub    $0x4,%esp
  801bd0:	ff 75 10             	push   0x10(%ebp)
  801bd3:	ff 75 0c             	push   0xc(%ebp)
  801bd6:	50                   	push   %eax
  801bd7:	e8 59 01 00 00       	call   801d35 <nsipc_connect>
  801bdc:	83 c4 10             	add    $0x10,%esp
}
  801bdf:	c9                   	leave  
  801be0:	c3                   	ret    

00801be1 <listen>:
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801be7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bea:	e8 b0 fe ff ff       	call   801a9f <fd2sockid>
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	78 0f                	js     801c02 <listen+0x21>
	return nsipc_listen(r, backlog);
  801bf3:	83 ec 08             	sub    $0x8,%esp
  801bf6:	ff 75 0c             	push   0xc(%ebp)
  801bf9:	50                   	push   %eax
  801bfa:	e8 6b 01 00 00       	call   801d6a <nsipc_listen>
  801bff:	83 c4 10             	add    $0x10,%esp
}
  801c02:	c9                   	leave  
  801c03:	c3                   	ret    

00801c04 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c0a:	ff 75 10             	push   0x10(%ebp)
  801c0d:	ff 75 0c             	push   0xc(%ebp)
  801c10:	ff 75 08             	push   0x8(%ebp)
  801c13:	e8 41 02 00 00       	call   801e59 <nsipc_socket>
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 05                	js     801c24 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c1f:	e8 ab fe ff ff       	call   801acf <alloc_sockfd>
}
  801c24:	c9                   	leave  
  801c25:	c3                   	ret    

00801c26 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	53                   	push   %ebx
  801c2a:	83 ec 04             	sub    $0x4,%esp
  801c2d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c2f:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801c36:	74 26                	je     801c5e <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c38:	6a 07                	push   $0x7
  801c3a:	68 00 70 80 00       	push   $0x807000
  801c3f:	53                   	push   %ebx
  801c40:	ff 35 00 80 80 00    	push   0x808000
  801c46:	e8 5b f5 ff ff       	call   8011a6 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c4b:	83 c4 0c             	add    $0xc,%esp
  801c4e:	6a 00                	push   $0x0
  801c50:	6a 00                	push   $0x0
  801c52:	6a 00                	push   $0x0
  801c54:	e8 e6 f4 ff ff       	call   80113f <ipc_recv>
}
  801c59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5c:	c9                   	leave  
  801c5d:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c5e:	83 ec 0c             	sub    $0xc,%esp
  801c61:	6a 02                	push   $0x2
  801c63:	e8 92 f5 ff ff       	call   8011fa <ipc_find_env>
  801c68:	a3 00 80 80 00       	mov    %eax,0x808000
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	eb c6                	jmp    801c38 <nsipc+0x12>

00801c72 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	56                   	push   %esi
  801c76:	53                   	push   %ebx
  801c77:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c82:	8b 06                	mov    (%esi),%eax
  801c84:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c89:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8e:	e8 93 ff ff ff       	call   801c26 <nsipc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	85 c0                	test   %eax,%eax
  801c97:	79 09                	jns    801ca2 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c99:	89 d8                	mov    %ebx,%eax
  801c9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9e:	5b                   	pop    %ebx
  801c9f:	5e                   	pop    %esi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ca2:	83 ec 04             	sub    $0x4,%esp
  801ca5:	ff 35 10 70 80 00    	push   0x807010
  801cab:	68 00 70 80 00       	push   $0x807000
  801cb0:	ff 75 0c             	push   0xc(%ebp)
  801cb3:	e8 51 ed ff ff       	call   800a09 <memmove>
		*addrlen = ret->ret_addrlen;
  801cb8:	a1 10 70 80 00       	mov    0x807010,%eax
  801cbd:	89 06                	mov    %eax,(%esi)
  801cbf:	83 c4 10             	add    $0x10,%esp
	return r;
  801cc2:	eb d5                	jmp    801c99 <nsipc_accept+0x27>

00801cc4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	53                   	push   %ebx
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cce:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd1:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cd6:	53                   	push   %ebx
  801cd7:	ff 75 0c             	push   0xc(%ebp)
  801cda:	68 04 70 80 00       	push   $0x807004
  801cdf:	e8 25 ed ff ff       	call   800a09 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ce4:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801cea:	b8 02 00 00 00       	mov    $0x2,%eax
  801cef:	e8 32 ff ff ff       	call   801c26 <nsipc>
}
  801cf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    

00801cf9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801d07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801d0f:	b8 03 00 00 00       	mov    $0x3,%eax
  801d14:	e8 0d ff ff ff       	call   801c26 <nsipc>
}
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <nsipc_close>:

int
nsipc_close(int s)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d21:	8b 45 08             	mov    0x8(%ebp),%eax
  801d24:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801d29:	b8 04 00 00 00       	mov    $0x4,%eax
  801d2e:	e8 f3 fe ff ff       	call   801c26 <nsipc>
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	53                   	push   %ebx
  801d39:	83 ec 08             	sub    $0x8,%esp
  801d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d47:	53                   	push   %ebx
  801d48:	ff 75 0c             	push   0xc(%ebp)
  801d4b:	68 04 70 80 00       	push   $0x807004
  801d50:	e8 b4 ec ff ff       	call   800a09 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d55:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801d5b:	b8 05 00 00 00       	mov    $0x5,%eax
  801d60:	e8 c1 fe ff ff       	call   801c26 <nsipc>
}
  801d65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d68:	c9                   	leave  
  801d69:	c3                   	ret    

00801d6a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d70:	8b 45 08             	mov    0x8(%ebp),%eax
  801d73:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d80:	b8 06 00 00 00       	mov    $0x6,%eax
  801d85:	e8 9c fe ff ff       	call   801c26 <nsipc>
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	56                   	push   %esi
  801d90:	53                   	push   %ebx
  801d91:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
  801d97:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d9c:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801da2:	8b 45 14             	mov    0x14(%ebp),%eax
  801da5:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801daa:	b8 07 00 00 00       	mov    $0x7,%eax
  801daf:	e8 72 fe ff ff       	call   801c26 <nsipc>
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	85 c0                	test   %eax,%eax
  801db8:	78 22                	js     801ddc <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801dba:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801dbf:	39 c6                	cmp    %eax,%esi
  801dc1:	0f 4e c6             	cmovle %esi,%eax
  801dc4:	39 c3                	cmp    %eax,%ebx
  801dc6:	7f 1d                	jg     801de5 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801dc8:	83 ec 04             	sub    $0x4,%esp
  801dcb:	53                   	push   %ebx
  801dcc:	68 00 70 80 00       	push   $0x807000
  801dd1:	ff 75 0c             	push   0xc(%ebp)
  801dd4:	e8 30 ec ff ff       	call   800a09 <memmove>
  801dd9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ddc:	89 d8                	mov    %ebx,%eax
  801dde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801de5:	68 27 2c 80 00       	push   $0x802c27
  801dea:	68 ef 2b 80 00       	push   $0x802bef
  801def:	6a 62                	push   $0x62
  801df1:	68 3c 2c 80 00       	push   $0x802c3c
  801df6:	e8 46 05 00 00       	call   802341 <_panic>

00801dfb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	53                   	push   %ebx
  801dff:	83 ec 04             	sub    $0x4,%esp
  801e02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e05:	8b 45 08             	mov    0x8(%ebp),%eax
  801e08:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801e0d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e13:	7f 2e                	jg     801e43 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e15:	83 ec 04             	sub    $0x4,%esp
  801e18:	53                   	push   %ebx
  801e19:	ff 75 0c             	push   0xc(%ebp)
  801e1c:	68 0c 70 80 00       	push   $0x80700c
  801e21:	e8 e3 eb ff ff       	call   800a09 <memmove>
	nsipcbuf.send.req_size = size;
  801e26:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801e2c:	8b 45 14             	mov    0x14(%ebp),%eax
  801e2f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801e34:	b8 08 00 00 00       	mov    $0x8,%eax
  801e39:	e8 e8 fd ff ff       	call   801c26 <nsipc>
}
  801e3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    
	assert(size < 1600);
  801e43:	68 48 2c 80 00       	push   $0x802c48
  801e48:	68 ef 2b 80 00       	push   $0x802bef
  801e4d:	6a 6d                	push   $0x6d
  801e4f:	68 3c 2c 80 00       	push   $0x802c3c
  801e54:	e8 e8 04 00 00       	call   802341 <_panic>

00801e59 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e62:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801e67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6a:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801e6f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e72:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e77:	b8 09 00 00 00       	mov    $0x9,%eax
  801e7c:	e8 a5 fd ff ff       	call   801c26 <nsipc>
}
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    

00801e83 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	56                   	push   %esi
  801e87:	53                   	push   %ebx
  801e88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	ff 75 08             	push   0x8(%ebp)
  801e91:	e8 ad f3 ff ff       	call   801243 <fd2data>
  801e96:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e98:	83 c4 08             	add    $0x8,%esp
  801e9b:	68 54 2c 80 00       	push   $0x802c54
  801ea0:	53                   	push   %ebx
  801ea1:	e8 cd e9 ff ff       	call   800873 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ea6:	8b 46 04             	mov    0x4(%esi),%eax
  801ea9:	2b 06                	sub    (%esi),%eax
  801eab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801eb1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eb8:	00 00 00 
	stat->st_dev = &devpipe;
  801ebb:	c7 83 88 00 00 00 44 	movl   $0x803044,0x88(%ebx)
  801ec2:	30 80 00 
	return 0;
}
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5e                   	pop    %esi
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    

00801ed1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	53                   	push   %ebx
  801ed5:	83 ec 0c             	sub    $0xc,%esp
  801ed8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801edb:	53                   	push   %ebx
  801edc:	6a 00                	push   $0x0
  801ede:	e8 11 ee ff ff       	call   800cf4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ee3:	89 1c 24             	mov    %ebx,(%esp)
  801ee6:	e8 58 f3 ff ff       	call   801243 <fd2data>
  801eeb:	83 c4 08             	add    $0x8,%esp
  801eee:	50                   	push   %eax
  801eef:	6a 00                	push   $0x0
  801ef1:	e8 fe ed ff ff       	call   800cf4 <sys_page_unmap>
}
  801ef6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <_pipeisclosed>:
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	57                   	push   %edi
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	83 ec 1c             	sub    $0x1c,%esp
  801f04:	89 c7                	mov    %eax,%edi
  801f06:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f08:	a1 00 40 80 00       	mov    0x804000,%eax
  801f0d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f10:	83 ec 0c             	sub    $0xc,%esp
  801f13:	57                   	push   %edi
  801f14:	e8 0a 05 00 00       	call   802423 <pageref>
  801f19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f1c:	89 34 24             	mov    %esi,(%esp)
  801f1f:	e8 ff 04 00 00       	call   802423 <pageref>
		nn = thisenv->env_runs;
  801f24:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f2a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f2d:	83 c4 10             	add    $0x10,%esp
  801f30:	39 cb                	cmp    %ecx,%ebx
  801f32:	74 1b                	je     801f4f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f34:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f37:	75 cf                	jne    801f08 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f39:	8b 42 58             	mov    0x58(%edx),%eax
  801f3c:	6a 01                	push   $0x1
  801f3e:	50                   	push   %eax
  801f3f:	53                   	push   %ebx
  801f40:	68 5b 2c 80 00       	push   $0x802c5b
  801f45:	e8 4f e3 ff ff       	call   800299 <cprintf>
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	eb b9                	jmp    801f08 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f4f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f52:	0f 94 c0             	sete   %al
  801f55:	0f b6 c0             	movzbl %al,%eax
}
  801f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5b:	5b                   	pop    %ebx
  801f5c:	5e                   	pop    %esi
  801f5d:	5f                   	pop    %edi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <devpipe_write>:
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	57                   	push   %edi
  801f64:	56                   	push   %esi
  801f65:	53                   	push   %ebx
  801f66:	83 ec 28             	sub    $0x28,%esp
  801f69:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f6c:	56                   	push   %esi
  801f6d:	e8 d1 f2 ff ff       	call   801243 <fd2data>
  801f72:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	bf 00 00 00 00       	mov    $0x0,%edi
  801f7c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f7f:	75 09                	jne    801f8a <devpipe_write+0x2a>
	return i;
  801f81:	89 f8                	mov    %edi,%eax
  801f83:	eb 23                	jmp    801fa8 <devpipe_write+0x48>
			sys_yield();
  801f85:	e8 c6 ec ff ff       	call   800c50 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f8a:	8b 43 04             	mov    0x4(%ebx),%eax
  801f8d:	8b 0b                	mov    (%ebx),%ecx
  801f8f:	8d 51 20             	lea    0x20(%ecx),%edx
  801f92:	39 d0                	cmp    %edx,%eax
  801f94:	72 1a                	jb     801fb0 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f96:	89 da                	mov    %ebx,%edx
  801f98:	89 f0                	mov    %esi,%eax
  801f9a:	e8 5c ff ff ff       	call   801efb <_pipeisclosed>
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	74 e2                	je     801f85 <devpipe_write+0x25>
				return 0;
  801fa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fab:	5b                   	pop    %ebx
  801fac:	5e                   	pop    %esi
  801fad:	5f                   	pop    %edi
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fb7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fba:	89 c2                	mov    %eax,%edx
  801fbc:	c1 fa 1f             	sar    $0x1f,%edx
  801fbf:	89 d1                	mov    %edx,%ecx
  801fc1:	c1 e9 1b             	shr    $0x1b,%ecx
  801fc4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fc7:	83 e2 1f             	and    $0x1f,%edx
  801fca:	29 ca                	sub    %ecx,%edx
  801fcc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fd0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fd4:	83 c0 01             	add    $0x1,%eax
  801fd7:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801fda:	83 c7 01             	add    $0x1,%edi
  801fdd:	eb 9d                	jmp    801f7c <devpipe_write+0x1c>

00801fdf <devpipe_read>:
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	57                   	push   %edi
  801fe3:	56                   	push   %esi
  801fe4:	53                   	push   %ebx
  801fe5:	83 ec 18             	sub    $0x18,%esp
  801fe8:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801feb:	57                   	push   %edi
  801fec:	e8 52 f2 ff ff       	call   801243 <fd2data>
  801ff1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ff3:	83 c4 10             	add    $0x10,%esp
  801ff6:	be 00 00 00 00       	mov    $0x0,%esi
  801ffb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ffe:	75 13                	jne    802013 <devpipe_read+0x34>
	return i;
  802000:	89 f0                	mov    %esi,%eax
  802002:	eb 02                	jmp    802006 <devpipe_read+0x27>
				return i;
  802004:	89 f0                	mov    %esi,%eax
}
  802006:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802009:	5b                   	pop    %ebx
  80200a:	5e                   	pop    %esi
  80200b:	5f                   	pop    %edi
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    
			sys_yield();
  80200e:	e8 3d ec ff ff       	call   800c50 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802013:	8b 03                	mov    (%ebx),%eax
  802015:	3b 43 04             	cmp    0x4(%ebx),%eax
  802018:	75 18                	jne    802032 <devpipe_read+0x53>
			if (i > 0)
  80201a:	85 f6                	test   %esi,%esi
  80201c:	75 e6                	jne    802004 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80201e:	89 da                	mov    %ebx,%edx
  802020:	89 f8                	mov    %edi,%eax
  802022:	e8 d4 fe ff ff       	call   801efb <_pipeisclosed>
  802027:	85 c0                	test   %eax,%eax
  802029:	74 e3                	je     80200e <devpipe_read+0x2f>
				return 0;
  80202b:	b8 00 00 00 00       	mov    $0x0,%eax
  802030:	eb d4                	jmp    802006 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802032:	99                   	cltd   
  802033:	c1 ea 1b             	shr    $0x1b,%edx
  802036:	01 d0                	add    %edx,%eax
  802038:	83 e0 1f             	and    $0x1f,%eax
  80203b:	29 d0                	sub    %edx,%eax
  80203d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802042:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802045:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802048:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80204b:	83 c6 01             	add    $0x1,%esi
  80204e:	eb ab                	jmp    801ffb <devpipe_read+0x1c>

00802050 <pipe>:
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	56                   	push   %esi
  802054:	53                   	push   %ebx
  802055:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802058:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80205b:	50                   	push   %eax
  80205c:	e8 f9 f1 ff ff       	call   80125a <fd_alloc>
  802061:	89 c3                	mov    %eax,%ebx
  802063:	83 c4 10             	add    $0x10,%esp
  802066:	85 c0                	test   %eax,%eax
  802068:	0f 88 23 01 00 00    	js     802191 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206e:	83 ec 04             	sub    $0x4,%esp
  802071:	68 07 04 00 00       	push   $0x407
  802076:	ff 75 f4             	push   -0xc(%ebp)
  802079:	6a 00                	push   $0x0
  80207b:	e8 ef eb ff ff       	call   800c6f <sys_page_alloc>
  802080:	89 c3                	mov    %eax,%ebx
  802082:	83 c4 10             	add    $0x10,%esp
  802085:	85 c0                	test   %eax,%eax
  802087:	0f 88 04 01 00 00    	js     802191 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80208d:	83 ec 0c             	sub    $0xc,%esp
  802090:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802093:	50                   	push   %eax
  802094:	e8 c1 f1 ff ff       	call   80125a <fd_alloc>
  802099:	89 c3                	mov    %eax,%ebx
  80209b:	83 c4 10             	add    $0x10,%esp
  80209e:	85 c0                	test   %eax,%eax
  8020a0:	0f 88 db 00 00 00    	js     802181 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a6:	83 ec 04             	sub    $0x4,%esp
  8020a9:	68 07 04 00 00       	push   $0x407
  8020ae:	ff 75 f0             	push   -0x10(%ebp)
  8020b1:	6a 00                	push   $0x0
  8020b3:	e8 b7 eb ff ff       	call   800c6f <sys_page_alloc>
  8020b8:	89 c3                	mov    %eax,%ebx
  8020ba:	83 c4 10             	add    $0x10,%esp
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	0f 88 bc 00 00 00    	js     802181 <pipe+0x131>
	va = fd2data(fd0);
  8020c5:	83 ec 0c             	sub    $0xc,%esp
  8020c8:	ff 75 f4             	push   -0xc(%ebp)
  8020cb:	e8 73 f1 ff ff       	call   801243 <fd2data>
  8020d0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d2:	83 c4 0c             	add    $0xc,%esp
  8020d5:	68 07 04 00 00       	push   $0x407
  8020da:	50                   	push   %eax
  8020db:	6a 00                	push   $0x0
  8020dd:	e8 8d eb ff ff       	call   800c6f <sys_page_alloc>
  8020e2:	89 c3                	mov    %eax,%ebx
  8020e4:	83 c4 10             	add    $0x10,%esp
  8020e7:	85 c0                	test   %eax,%eax
  8020e9:	0f 88 82 00 00 00    	js     802171 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ef:	83 ec 0c             	sub    $0xc,%esp
  8020f2:	ff 75 f0             	push   -0x10(%ebp)
  8020f5:	e8 49 f1 ff ff       	call   801243 <fd2data>
  8020fa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802101:	50                   	push   %eax
  802102:	6a 00                	push   $0x0
  802104:	56                   	push   %esi
  802105:	6a 00                	push   $0x0
  802107:	e8 a6 eb ff ff       	call   800cb2 <sys_page_map>
  80210c:	89 c3                	mov    %eax,%ebx
  80210e:	83 c4 20             	add    $0x20,%esp
  802111:	85 c0                	test   %eax,%eax
  802113:	78 4e                	js     802163 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802115:	a1 44 30 80 00       	mov    0x803044,%eax
  80211a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80211d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80211f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802122:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802129:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80212c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80212e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802131:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802138:	83 ec 0c             	sub    $0xc,%esp
  80213b:	ff 75 f4             	push   -0xc(%ebp)
  80213e:	e8 f0 f0 ff ff       	call   801233 <fd2num>
  802143:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802146:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802148:	83 c4 04             	add    $0x4,%esp
  80214b:	ff 75 f0             	push   -0x10(%ebp)
  80214e:	e8 e0 f0 ff ff       	call   801233 <fd2num>
  802153:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802156:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802159:	83 c4 10             	add    $0x10,%esp
  80215c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802161:	eb 2e                	jmp    802191 <pipe+0x141>
	sys_page_unmap(0, va);
  802163:	83 ec 08             	sub    $0x8,%esp
  802166:	56                   	push   %esi
  802167:	6a 00                	push   $0x0
  802169:	e8 86 eb ff ff       	call   800cf4 <sys_page_unmap>
  80216e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802171:	83 ec 08             	sub    $0x8,%esp
  802174:	ff 75 f0             	push   -0x10(%ebp)
  802177:	6a 00                	push   $0x0
  802179:	e8 76 eb ff ff       	call   800cf4 <sys_page_unmap>
  80217e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802181:	83 ec 08             	sub    $0x8,%esp
  802184:	ff 75 f4             	push   -0xc(%ebp)
  802187:	6a 00                	push   $0x0
  802189:	e8 66 eb ff ff       	call   800cf4 <sys_page_unmap>
  80218e:	83 c4 10             	add    $0x10,%esp
}
  802191:	89 d8                	mov    %ebx,%eax
  802193:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802196:	5b                   	pop    %ebx
  802197:	5e                   	pop    %esi
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    

0080219a <pipeisclosed>:
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a3:	50                   	push   %eax
  8021a4:	ff 75 08             	push   0x8(%ebp)
  8021a7:	e8 fe f0 ff ff       	call   8012aa <fd_lookup>
  8021ac:	83 c4 10             	add    $0x10,%esp
  8021af:	85 c0                	test   %eax,%eax
  8021b1:	78 18                	js     8021cb <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8021b3:	83 ec 0c             	sub    $0xc,%esp
  8021b6:	ff 75 f4             	push   -0xc(%ebp)
  8021b9:	e8 85 f0 ff ff       	call   801243 <fd2data>
  8021be:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8021c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c3:	e8 33 fd ff ff       	call   801efb <_pipeisclosed>
  8021c8:	83 c4 10             	add    $0x10,%esp
}
  8021cb:	c9                   	leave  
  8021cc:	c3                   	ret    

008021cd <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8021cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d2:	c3                   	ret    

008021d3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021d9:	68 73 2c 80 00       	push   $0x802c73
  8021de:	ff 75 0c             	push   0xc(%ebp)
  8021e1:	e8 8d e6 ff ff       	call   800873 <strcpy>
	return 0;
}
  8021e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021eb:	c9                   	leave  
  8021ec:	c3                   	ret    

008021ed <devcons_write>:
{
  8021ed:	55                   	push   %ebp
  8021ee:	89 e5                	mov    %esp,%ebp
  8021f0:	57                   	push   %edi
  8021f1:	56                   	push   %esi
  8021f2:	53                   	push   %ebx
  8021f3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8021f9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021fe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802204:	eb 2e                	jmp    802234 <devcons_write+0x47>
		m = n - tot;
  802206:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802209:	29 f3                	sub    %esi,%ebx
  80220b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802210:	39 c3                	cmp    %eax,%ebx
  802212:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802215:	83 ec 04             	sub    $0x4,%esp
  802218:	53                   	push   %ebx
  802219:	89 f0                	mov    %esi,%eax
  80221b:	03 45 0c             	add    0xc(%ebp),%eax
  80221e:	50                   	push   %eax
  80221f:	57                   	push   %edi
  802220:	e8 e4 e7 ff ff       	call   800a09 <memmove>
		sys_cputs(buf, m);
  802225:	83 c4 08             	add    $0x8,%esp
  802228:	53                   	push   %ebx
  802229:	57                   	push   %edi
  80222a:	e8 84 e9 ff ff       	call   800bb3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80222f:	01 de                	add    %ebx,%esi
  802231:	83 c4 10             	add    $0x10,%esp
  802234:	3b 75 10             	cmp    0x10(%ebp),%esi
  802237:	72 cd                	jb     802206 <devcons_write+0x19>
}
  802239:	89 f0                	mov    %esi,%eax
  80223b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80223e:	5b                   	pop    %ebx
  80223f:	5e                   	pop    %esi
  802240:	5f                   	pop    %edi
  802241:	5d                   	pop    %ebp
  802242:	c3                   	ret    

00802243 <devcons_read>:
{
  802243:	55                   	push   %ebp
  802244:	89 e5                	mov    %esp,%ebp
  802246:	83 ec 08             	sub    $0x8,%esp
  802249:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80224e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802252:	75 07                	jne    80225b <devcons_read+0x18>
  802254:	eb 1f                	jmp    802275 <devcons_read+0x32>
		sys_yield();
  802256:	e8 f5 e9 ff ff       	call   800c50 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80225b:	e8 71 e9 ff ff       	call   800bd1 <sys_cgetc>
  802260:	85 c0                	test   %eax,%eax
  802262:	74 f2                	je     802256 <devcons_read+0x13>
	if (c < 0)
  802264:	78 0f                	js     802275 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802266:	83 f8 04             	cmp    $0x4,%eax
  802269:	74 0c                	je     802277 <devcons_read+0x34>
	*(char*)vbuf = c;
  80226b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80226e:	88 02                	mov    %al,(%edx)
	return 1;
  802270:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802275:	c9                   	leave  
  802276:	c3                   	ret    
		return 0;
  802277:	b8 00 00 00 00       	mov    $0x0,%eax
  80227c:	eb f7                	jmp    802275 <devcons_read+0x32>

0080227e <cputchar>:
{
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802284:	8b 45 08             	mov    0x8(%ebp),%eax
  802287:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80228a:	6a 01                	push   $0x1
  80228c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80228f:	50                   	push   %eax
  802290:	e8 1e e9 ff ff       	call   800bb3 <sys_cputs>
}
  802295:	83 c4 10             	add    $0x10,%esp
  802298:	c9                   	leave  
  802299:	c3                   	ret    

0080229a <getchar>:
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8022a0:	6a 01                	push   $0x1
  8022a2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a5:	50                   	push   %eax
  8022a6:	6a 00                	push   $0x0
  8022a8:	e8 66 f2 ff ff       	call   801513 <read>
	if (r < 0)
  8022ad:	83 c4 10             	add    $0x10,%esp
  8022b0:	85 c0                	test   %eax,%eax
  8022b2:	78 06                	js     8022ba <getchar+0x20>
	if (r < 1)
  8022b4:	74 06                	je     8022bc <getchar+0x22>
	return c;
  8022b6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8022ba:	c9                   	leave  
  8022bb:	c3                   	ret    
		return -E_EOF;
  8022bc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8022c1:	eb f7                	jmp    8022ba <getchar+0x20>

008022c3 <iscons>:
{
  8022c3:	55                   	push   %ebp
  8022c4:	89 e5                	mov    %esp,%ebp
  8022c6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022cc:	50                   	push   %eax
  8022cd:	ff 75 08             	push   0x8(%ebp)
  8022d0:	e8 d5 ef ff ff       	call   8012aa <fd_lookup>
  8022d5:	83 c4 10             	add    $0x10,%esp
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	78 11                	js     8022ed <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8022dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022df:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8022e5:	39 10                	cmp    %edx,(%eax)
  8022e7:	0f 94 c0             	sete   %al
  8022ea:	0f b6 c0             	movzbl %al,%eax
}
  8022ed:	c9                   	leave  
  8022ee:	c3                   	ret    

008022ef <opencons>:
{
  8022ef:	55                   	push   %ebp
  8022f0:	89 e5                	mov    %esp,%ebp
  8022f2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8022f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f8:	50                   	push   %eax
  8022f9:	e8 5c ef ff ff       	call   80125a <fd_alloc>
  8022fe:	83 c4 10             	add    $0x10,%esp
  802301:	85 c0                	test   %eax,%eax
  802303:	78 3a                	js     80233f <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802305:	83 ec 04             	sub    $0x4,%esp
  802308:	68 07 04 00 00       	push   $0x407
  80230d:	ff 75 f4             	push   -0xc(%ebp)
  802310:	6a 00                	push   $0x0
  802312:	e8 58 e9 ff ff       	call   800c6f <sys_page_alloc>
  802317:	83 c4 10             	add    $0x10,%esp
  80231a:	85 c0                	test   %eax,%eax
  80231c:	78 21                	js     80233f <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80231e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802321:	8b 15 60 30 80 00    	mov    0x803060,%edx
  802327:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802329:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80232c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802333:	83 ec 0c             	sub    $0xc,%esp
  802336:	50                   	push   %eax
  802337:	e8 f7 ee ff ff       	call   801233 <fd2num>
  80233c:	83 c4 10             	add    $0x10,%esp
}
  80233f:	c9                   	leave  
  802340:	c3                   	ret    

00802341 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	56                   	push   %esi
  802345:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802346:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802349:	8b 35 08 30 80 00    	mov    0x803008,%esi
  80234f:	e8 dd e8 ff ff       	call   800c31 <sys_getenvid>
  802354:	83 ec 0c             	sub    $0xc,%esp
  802357:	ff 75 0c             	push   0xc(%ebp)
  80235a:	ff 75 08             	push   0x8(%ebp)
  80235d:	56                   	push   %esi
  80235e:	50                   	push   %eax
  80235f:	68 80 2c 80 00       	push   $0x802c80
  802364:	e8 30 df ff ff       	call   800299 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802369:	83 c4 18             	add    $0x18,%esp
  80236c:	53                   	push   %ebx
  80236d:	ff 75 10             	push   0x10(%ebp)
  802370:	e8 d3 de ff ff       	call   800248 <vcprintf>
	cprintf("\n");
  802375:	c7 04 24 6c 2c 80 00 	movl   $0x802c6c,(%esp)
  80237c:	e8 18 df ff ff       	call   800299 <cprintf>
  802381:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802384:	cc                   	int3   
  802385:	eb fd                	jmp    802384 <_panic+0x43>

00802387 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802387:	55                   	push   %ebp
  802388:	89 e5                	mov    %esp,%ebp
  80238a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80238d:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  802394:	74 0a                	je     8023a0 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802396:	8b 45 08             	mov    0x8(%ebp),%eax
  802399:	a3 04 80 80 00       	mov    %eax,0x808004
}
  80239e:	c9                   	leave  
  80239f:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8023a0:	e8 8c e8 ff ff       	call   800c31 <sys_getenvid>
  8023a5:	83 ec 04             	sub    $0x4,%esp
  8023a8:	68 07 0e 00 00       	push   $0xe07
  8023ad:	68 00 f0 bf ee       	push   $0xeebff000
  8023b2:	50                   	push   %eax
  8023b3:	e8 b7 e8 ff ff       	call   800c6f <sys_page_alloc>
		if (r < 0) {
  8023b8:	83 c4 10             	add    $0x10,%esp
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	78 2c                	js     8023eb <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8023bf:	e8 6d e8 ff ff       	call   800c31 <sys_getenvid>
  8023c4:	83 ec 08             	sub    $0x8,%esp
  8023c7:	68 fd 23 80 00       	push   $0x8023fd
  8023cc:	50                   	push   %eax
  8023cd:	e8 e8 e9 ff ff       	call   800dba <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8023d2:	83 c4 10             	add    $0x10,%esp
  8023d5:	85 c0                	test   %eax,%eax
  8023d7:	79 bd                	jns    802396 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  8023d9:	50                   	push   %eax
  8023da:	68 e4 2c 80 00       	push   $0x802ce4
  8023df:	6a 28                	push   $0x28
  8023e1:	68 1a 2d 80 00       	push   $0x802d1a
  8023e6:	e8 56 ff ff ff       	call   802341 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  8023eb:	50                   	push   %eax
  8023ec:	68 a4 2c 80 00       	push   $0x802ca4
  8023f1:	6a 23                	push   $0x23
  8023f3:	68 1a 2d 80 00       	push   $0x802d1a
  8023f8:	e8 44 ff ff ff       	call   802341 <_panic>

008023fd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023fd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023fe:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802403:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802405:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802408:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80240c:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80240f:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802413:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802417:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802419:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80241c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80241d:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802420:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802421:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802422:	c3                   	ret    

00802423 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802423:	55                   	push   %ebp
  802424:	89 e5                	mov    %esp,%ebp
  802426:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802429:	89 c2                	mov    %eax,%edx
  80242b:	c1 ea 16             	shr    $0x16,%edx
  80242e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802435:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80243a:	f6 c1 01             	test   $0x1,%cl
  80243d:	74 1c                	je     80245b <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80243f:	c1 e8 0c             	shr    $0xc,%eax
  802442:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802449:	a8 01                	test   $0x1,%al
  80244b:	74 0e                	je     80245b <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80244d:	c1 e8 0c             	shr    $0xc,%eax
  802450:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802457:	ef 
  802458:	0f b7 d2             	movzwl %dx,%edx
}
  80245b:	89 d0                	mov    %edx,%eax
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    
  80245f:	90                   	nop

00802460 <__udivdi3>:
  802460:	f3 0f 1e fb          	endbr32 
  802464:	55                   	push   %ebp
  802465:	57                   	push   %edi
  802466:	56                   	push   %esi
  802467:	53                   	push   %ebx
  802468:	83 ec 1c             	sub    $0x1c,%esp
  80246b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80246f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802473:	8b 74 24 34          	mov    0x34(%esp),%esi
  802477:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80247b:	85 c0                	test   %eax,%eax
  80247d:	75 19                	jne    802498 <__udivdi3+0x38>
  80247f:	39 f3                	cmp    %esi,%ebx
  802481:	76 4d                	jbe    8024d0 <__udivdi3+0x70>
  802483:	31 ff                	xor    %edi,%edi
  802485:	89 e8                	mov    %ebp,%eax
  802487:	89 f2                	mov    %esi,%edx
  802489:	f7 f3                	div    %ebx
  80248b:	89 fa                	mov    %edi,%edx
  80248d:	83 c4 1c             	add    $0x1c,%esp
  802490:	5b                   	pop    %ebx
  802491:	5e                   	pop    %esi
  802492:	5f                   	pop    %edi
  802493:	5d                   	pop    %ebp
  802494:	c3                   	ret    
  802495:	8d 76 00             	lea    0x0(%esi),%esi
  802498:	39 f0                	cmp    %esi,%eax
  80249a:	76 14                	jbe    8024b0 <__udivdi3+0x50>
  80249c:	31 ff                	xor    %edi,%edi
  80249e:	31 c0                	xor    %eax,%eax
  8024a0:	89 fa                	mov    %edi,%edx
  8024a2:	83 c4 1c             	add    $0x1c,%esp
  8024a5:	5b                   	pop    %ebx
  8024a6:	5e                   	pop    %esi
  8024a7:	5f                   	pop    %edi
  8024a8:	5d                   	pop    %ebp
  8024a9:	c3                   	ret    
  8024aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b0:	0f bd f8             	bsr    %eax,%edi
  8024b3:	83 f7 1f             	xor    $0x1f,%edi
  8024b6:	75 48                	jne    802500 <__udivdi3+0xa0>
  8024b8:	39 f0                	cmp    %esi,%eax
  8024ba:	72 06                	jb     8024c2 <__udivdi3+0x62>
  8024bc:	31 c0                	xor    %eax,%eax
  8024be:	39 eb                	cmp    %ebp,%ebx
  8024c0:	77 de                	ja     8024a0 <__udivdi3+0x40>
  8024c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c7:	eb d7                	jmp    8024a0 <__udivdi3+0x40>
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	89 d9                	mov    %ebx,%ecx
  8024d2:	85 db                	test   %ebx,%ebx
  8024d4:	75 0b                	jne    8024e1 <__udivdi3+0x81>
  8024d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	f7 f3                	div    %ebx
  8024df:	89 c1                	mov    %eax,%ecx
  8024e1:	31 d2                	xor    %edx,%edx
  8024e3:	89 f0                	mov    %esi,%eax
  8024e5:	f7 f1                	div    %ecx
  8024e7:	89 c6                	mov    %eax,%esi
  8024e9:	89 e8                	mov    %ebp,%eax
  8024eb:	89 f7                	mov    %esi,%edi
  8024ed:	f7 f1                	div    %ecx
  8024ef:	89 fa                	mov    %edi,%edx
  8024f1:	83 c4 1c             	add    $0x1c,%esp
  8024f4:	5b                   	pop    %ebx
  8024f5:	5e                   	pop    %esi
  8024f6:	5f                   	pop    %edi
  8024f7:	5d                   	pop    %ebp
  8024f8:	c3                   	ret    
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 f9                	mov    %edi,%ecx
  802502:	ba 20 00 00 00       	mov    $0x20,%edx
  802507:	29 fa                	sub    %edi,%edx
  802509:	d3 e0                	shl    %cl,%eax
  80250b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80250f:	89 d1                	mov    %edx,%ecx
  802511:	89 d8                	mov    %ebx,%eax
  802513:	d3 e8                	shr    %cl,%eax
  802515:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802519:	09 c1                	or     %eax,%ecx
  80251b:	89 f0                	mov    %esi,%eax
  80251d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802521:	89 f9                	mov    %edi,%ecx
  802523:	d3 e3                	shl    %cl,%ebx
  802525:	89 d1                	mov    %edx,%ecx
  802527:	d3 e8                	shr    %cl,%eax
  802529:	89 f9                	mov    %edi,%ecx
  80252b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80252f:	89 eb                	mov    %ebp,%ebx
  802531:	d3 e6                	shl    %cl,%esi
  802533:	89 d1                	mov    %edx,%ecx
  802535:	d3 eb                	shr    %cl,%ebx
  802537:	09 f3                	or     %esi,%ebx
  802539:	89 c6                	mov    %eax,%esi
  80253b:	89 f2                	mov    %esi,%edx
  80253d:	89 d8                	mov    %ebx,%eax
  80253f:	f7 74 24 08          	divl   0x8(%esp)
  802543:	89 d6                	mov    %edx,%esi
  802545:	89 c3                	mov    %eax,%ebx
  802547:	f7 64 24 0c          	mull   0xc(%esp)
  80254b:	39 d6                	cmp    %edx,%esi
  80254d:	72 19                	jb     802568 <__udivdi3+0x108>
  80254f:	89 f9                	mov    %edi,%ecx
  802551:	d3 e5                	shl    %cl,%ebp
  802553:	39 c5                	cmp    %eax,%ebp
  802555:	73 04                	jae    80255b <__udivdi3+0xfb>
  802557:	39 d6                	cmp    %edx,%esi
  802559:	74 0d                	je     802568 <__udivdi3+0x108>
  80255b:	89 d8                	mov    %ebx,%eax
  80255d:	31 ff                	xor    %edi,%edi
  80255f:	e9 3c ff ff ff       	jmp    8024a0 <__udivdi3+0x40>
  802564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802568:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80256b:	31 ff                	xor    %edi,%edi
  80256d:	e9 2e ff ff ff       	jmp    8024a0 <__udivdi3+0x40>
  802572:	66 90                	xchg   %ax,%ax
  802574:	66 90                	xchg   %ax,%ax
  802576:	66 90                	xchg   %ax,%ax
  802578:	66 90                	xchg   %ax,%ax
  80257a:	66 90                	xchg   %ax,%ax
  80257c:	66 90                	xchg   %ax,%ax
  80257e:	66 90                	xchg   %ax,%ax

00802580 <__umoddi3>:
  802580:	f3 0f 1e fb          	endbr32 
  802584:	55                   	push   %ebp
  802585:	57                   	push   %edi
  802586:	56                   	push   %esi
  802587:	53                   	push   %ebx
  802588:	83 ec 1c             	sub    $0x1c,%esp
  80258b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80258f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802593:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802597:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80259b:	89 f0                	mov    %esi,%eax
  80259d:	89 da                	mov    %ebx,%edx
  80259f:	85 ff                	test   %edi,%edi
  8025a1:	75 15                	jne    8025b8 <__umoddi3+0x38>
  8025a3:	39 dd                	cmp    %ebx,%ebp
  8025a5:	76 39                	jbe    8025e0 <__umoddi3+0x60>
  8025a7:	f7 f5                	div    %ebp
  8025a9:	89 d0                	mov    %edx,%eax
  8025ab:	31 d2                	xor    %edx,%edx
  8025ad:	83 c4 1c             	add    $0x1c,%esp
  8025b0:	5b                   	pop    %ebx
  8025b1:	5e                   	pop    %esi
  8025b2:	5f                   	pop    %edi
  8025b3:	5d                   	pop    %ebp
  8025b4:	c3                   	ret    
  8025b5:	8d 76 00             	lea    0x0(%esi),%esi
  8025b8:	39 df                	cmp    %ebx,%edi
  8025ba:	77 f1                	ja     8025ad <__umoddi3+0x2d>
  8025bc:	0f bd cf             	bsr    %edi,%ecx
  8025bf:	83 f1 1f             	xor    $0x1f,%ecx
  8025c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8025c6:	75 40                	jne    802608 <__umoddi3+0x88>
  8025c8:	39 df                	cmp    %ebx,%edi
  8025ca:	72 04                	jb     8025d0 <__umoddi3+0x50>
  8025cc:	39 f5                	cmp    %esi,%ebp
  8025ce:	77 dd                	ja     8025ad <__umoddi3+0x2d>
  8025d0:	89 da                	mov    %ebx,%edx
  8025d2:	89 f0                	mov    %esi,%eax
  8025d4:	29 e8                	sub    %ebp,%eax
  8025d6:	19 fa                	sbb    %edi,%edx
  8025d8:	eb d3                	jmp    8025ad <__umoddi3+0x2d>
  8025da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e0:	89 e9                	mov    %ebp,%ecx
  8025e2:	85 ed                	test   %ebp,%ebp
  8025e4:	75 0b                	jne    8025f1 <__umoddi3+0x71>
  8025e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  8025ed:	f7 f5                	div    %ebp
  8025ef:	89 c1                	mov    %eax,%ecx
  8025f1:	89 d8                	mov    %ebx,%eax
  8025f3:	31 d2                	xor    %edx,%edx
  8025f5:	f7 f1                	div    %ecx
  8025f7:	89 f0                	mov    %esi,%eax
  8025f9:	f7 f1                	div    %ecx
  8025fb:	89 d0                	mov    %edx,%eax
  8025fd:	31 d2                	xor    %edx,%edx
  8025ff:	eb ac                	jmp    8025ad <__umoddi3+0x2d>
  802601:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802608:	8b 44 24 04          	mov    0x4(%esp),%eax
  80260c:	ba 20 00 00 00       	mov    $0x20,%edx
  802611:	29 c2                	sub    %eax,%edx
  802613:	89 c1                	mov    %eax,%ecx
  802615:	89 e8                	mov    %ebp,%eax
  802617:	d3 e7                	shl    %cl,%edi
  802619:	89 d1                	mov    %edx,%ecx
  80261b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80261f:	d3 e8                	shr    %cl,%eax
  802621:	89 c1                	mov    %eax,%ecx
  802623:	8b 44 24 04          	mov    0x4(%esp),%eax
  802627:	09 f9                	or     %edi,%ecx
  802629:	89 df                	mov    %ebx,%edi
  80262b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80262f:	89 c1                	mov    %eax,%ecx
  802631:	d3 e5                	shl    %cl,%ebp
  802633:	89 d1                	mov    %edx,%ecx
  802635:	d3 ef                	shr    %cl,%edi
  802637:	89 c1                	mov    %eax,%ecx
  802639:	89 f0                	mov    %esi,%eax
  80263b:	d3 e3                	shl    %cl,%ebx
  80263d:	89 d1                	mov    %edx,%ecx
  80263f:	89 fa                	mov    %edi,%edx
  802641:	d3 e8                	shr    %cl,%eax
  802643:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802648:	09 d8                	or     %ebx,%eax
  80264a:	f7 74 24 08          	divl   0x8(%esp)
  80264e:	89 d3                	mov    %edx,%ebx
  802650:	d3 e6                	shl    %cl,%esi
  802652:	f7 e5                	mul    %ebp
  802654:	89 c7                	mov    %eax,%edi
  802656:	89 d1                	mov    %edx,%ecx
  802658:	39 d3                	cmp    %edx,%ebx
  80265a:	72 06                	jb     802662 <__umoddi3+0xe2>
  80265c:	75 0e                	jne    80266c <__umoddi3+0xec>
  80265e:	39 c6                	cmp    %eax,%esi
  802660:	73 0a                	jae    80266c <__umoddi3+0xec>
  802662:	29 e8                	sub    %ebp,%eax
  802664:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802668:	89 d1                	mov    %edx,%ecx
  80266a:	89 c7                	mov    %eax,%edi
  80266c:	89 f5                	mov    %esi,%ebp
  80266e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802672:	29 fd                	sub    %edi,%ebp
  802674:	19 cb                	sbb    %ecx,%ebx
  802676:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80267b:	89 d8                	mov    %ebx,%eax
  80267d:	d3 e0                	shl    %cl,%eax
  80267f:	89 f1                	mov    %esi,%ecx
  802681:	d3 ed                	shr    %cl,%ebp
  802683:	d3 eb                	shr    %cl,%ebx
  802685:	09 e8                	or     %ebp,%eax
  802687:	89 da                	mov    %ebx,%edx
  802689:	83 c4 1c             	add    $0x1c,%esp
  80268c:	5b                   	pop    %ebx
  80268d:	5e                   	pop    %esi
  80268e:	5f                   	pop    %edi
  80268f:	5d                   	pop    %ebp
  802690:	c3                   	ret    
