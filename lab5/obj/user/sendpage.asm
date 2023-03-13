
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
  800039:	e8 20 0f 00 00       	call   800f5e <fork>
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
  800092:	e8 ae 10 00 00       	call   801145 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800097:	83 c4 1c             	add    $0x1c,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	68 00 00 a0 00       	push   $0xa00000
  8000a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a4:	50                   	push   %eax
  8000a5:	e8 34 10 00 00       	call   8010de <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000aa:	83 c4 0c             	add    $0xc,%esp
  8000ad:	68 00 00 a0 00       	push   $0xa00000
  8000b2:	ff 75 f4             	push   -0xc(%ebp)
  8000b5:	68 e0 21 80 00       	push   $0x8021e0
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
  8000fc:	e8 dd 0f 00 00       	call   8010de <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800101:	83 c4 0c             	add    $0xc,%esp
  800104:	68 00 00 b0 00       	push   $0xb00000
  800109:	ff 75 f4             	push   -0xc(%ebp)
  80010c:	68 e0 21 80 00       	push   $0x8021e0
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
  800170:	e8 d0 0f 00 00       	call   801145 <ipc_send>
		return;
  800175:	83 c4 20             	add    $0x20,%esp
  800178:	e9 6f ff ff ff       	jmp    8000ec <umain+0xb9>
			cprintf("child received correct message\n");
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	68 f4 21 80 00       	push   $0x8021f4
  800185:	e8 0f 01 00 00       	call   800299 <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	eb b0                	jmp    80013f <umain+0x10c>
		cprintf("parent received correct message\n");
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	68 14 22 80 00       	push   $0x802214
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
  8001f0:	e8 a9 11 00 00       	call   80139e <close_all>
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
  8002fb:	e8 a0 1c 00 00       	call   801fa0 <__udivdi3>
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
  800339:	e8 82 1d 00 00       	call   8020c0 <__umoddi3>
  80033e:	83 c4 14             	add    $0x14,%esp
  800341:	0f be 80 8c 22 80 00 	movsbl 0x80228c(%eax),%eax
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
  8003fb:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  8004c9:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	74 18                	je     8004ec <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004d4:	52                   	push   %edx
  8004d5:	68 3d 27 80 00       	push   $0x80273d
  8004da:	53                   	push   %ebx
  8004db:	56                   	push   %esi
  8004dc:	e8 92 fe ff ff       	call   800373 <printfmt>
  8004e1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e7:	e9 66 02 00 00       	jmp    800752 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004ec:	50                   	push   %eax
  8004ed:	68 a4 22 80 00       	push   $0x8022a4
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
  800514:	b8 9d 22 80 00       	mov    $0x80229d,%eax
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
  800c20:	68 7f 25 80 00       	push   $0x80257f
  800c25:	6a 2a                	push   $0x2a
  800c27:	68 9c 25 80 00       	push   $0x80259c
  800c2c:	e8 42 12 00 00       	call   801e73 <_panic>

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
  800ca1:	68 7f 25 80 00       	push   $0x80257f
  800ca6:	6a 2a                	push   $0x2a
  800ca8:	68 9c 25 80 00       	push   $0x80259c
  800cad:	e8 c1 11 00 00       	call   801e73 <_panic>

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
  800ce3:	68 7f 25 80 00       	push   $0x80257f
  800ce8:	6a 2a                	push   $0x2a
  800cea:	68 9c 25 80 00       	push   $0x80259c
  800cef:	e8 7f 11 00 00       	call   801e73 <_panic>

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
  800d25:	68 7f 25 80 00       	push   $0x80257f
  800d2a:	6a 2a                	push   $0x2a
  800d2c:	68 9c 25 80 00       	push   $0x80259c
  800d31:	e8 3d 11 00 00       	call   801e73 <_panic>

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
  800d67:	68 7f 25 80 00       	push   $0x80257f
  800d6c:	6a 2a                	push   $0x2a
  800d6e:	68 9c 25 80 00       	push   $0x80259c
  800d73:	e8 fb 10 00 00       	call   801e73 <_panic>

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
  800da9:	68 7f 25 80 00       	push   $0x80257f
  800dae:	6a 2a                	push   $0x2a
  800db0:	68 9c 25 80 00       	push   $0x80259c
  800db5:	e8 b9 10 00 00       	call   801e73 <_panic>

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
  800deb:	68 7f 25 80 00       	push   $0x80257f
  800df0:	6a 2a                	push   $0x2a
  800df2:	68 9c 25 80 00       	push   $0x80259c
  800df7:	e8 77 10 00 00       	call   801e73 <_panic>

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
  800e4f:	68 7f 25 80 00       	push   $0x80257f
  800e54:	6a 2a                	push   $0x2a
  800e56:	68 9c 25 80 00       	push   $0x80259c
  800e5b:	e8 13 10 00 00       	call   801e73 <_panic>

00800e60 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	56                   	push   %esi
  800e64:	53                   	push   %ebx
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e68:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e6a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e6e:	0f 84 8e 00 00 00    	je     800f02 <pgfault+0xa2>
  800e74:	89 f0                	mov    %esi,%eax
  800e76:	c1 e8 0c             	shr    $0xc,%eax
  800e79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e80:	f6 c4 08             	test   $0x8,%ah
  800e83:	74 7d                	je     800f02 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e85:	e8 a7 fd ff ff       	call   800c31 <sys_getenvid>
  800e8a:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	6a 07                	push   $0x7
  800e91:	68 00 f0 7f 00       	push   $0x7ff000
  800e96:	50                   	push   %eax
  800e97:	e8 d3 fd ff ff       	call   800c6f <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	78 73                	js     800f16 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800ea3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	68 00 10 00 00       	push   $0x1000
  800eb1:	56                   	push   %esi
  800eb2:	68 00 f0 7f 00       	push   $0x7ff000
  800eb7:	e8 4d fb ff ff       	call   800a09 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800ebc:	83 c4 08             	add    $0x8,%esp
  800ebf:	56                   	push   %esi
  800ec0:	53                   	push   %ebx
  800ec1:	e8 2e fe ff ff       	call   800cf4 <sys_page_unmap>
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	78 5b                	js     800f28 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800ecd:	83 ec 0c             	sub    $0xc,%esp
  800ed0:	6a 07                	push   $0x7
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	68 00 f0 7f 00       	push   $0x7ff000
  800ed9:	53                   	push   %ebx
  800eda:	e8 d3 fd ff ff       	call   800cb2 <sys_page_map>
  800edf:	83 c4 20             	add    $0x20,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	78 54                	js     800f3a <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800ee6:	83 ec 08             	sub    $0x8,%esp
  800ee9:	68 00 f0 7f 00       	push   $0x7ff000
  800eee:	53                   	push   %ebx
  800eef:	e8 00 fe ff ff       	call   800cf4 <sys_page_unmap>
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	78 51                	js     800f4c <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800efb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	68 ac 25 80 00       	push   $0x8025ac
  800f0a:	6a 1d                	push   $0x1d
  800f0c:	68 28 26 80 00       	push   $0x802628
  800f11:	e8 5d 0f 00 00       	call   801e73 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f16:	50                   	push   %eax
  800f17:	68 e4 25 80 00       	push   $0x8025e4
  800f1c:	6a 29                	push   $0x29
  800f1e:	68 28 26 80 00       	push   $0x802628
  800f23:	e8 4b 0f 00 00       	call   801e73 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f28:	50                   	push   %eax
  800f29:	68 08 26 80 00       	push   $0x802608
  800f2e:	6a 2e                	push   $0x2e
  800f30:	68 28 26 80 00       	push   $0x802628
  800f35:	e8 39 0f 00 00       	call   801e73 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800f3a:	50                   	push   %eax
  800f3b:	68 33 26 80 00       	push   $0x802633
  800f40:	6a 30                	push   $0x30
  800f42:	68 28 26 80 00       	push   $0x802628
  800f47:	e8 27 0f 00 00       	call   801e73 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f4c:	50                   	push   %eax
  800f4d:	68 08 26 80 00       	push   $0x802608
  800f52:	6a 32                	push   $0x32
  800f54:	68 28 26 80 00       	push   $0x802628
  800f59:	e8 15 0f 00 00       	call   801e73 <_panic>

00800f5e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
  800f64:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f67:	68 60 0e 80 00       	push   $0x800e60
  800f6c:	e8 48 0f 00 00       	call   801eb9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f71:	b8 07 00 00 00       	mov    $0x7,%eax
  800f76:	cd 30                	int    $0x30
  800f78:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 2d                	js     800faf <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f82:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f87:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f8b:	75 73                	jne    801000 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f8d:	e8 9f fc ff ff       	call   800c31 <sys_getenvid>
  800f92:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f97:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f9a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9f:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800fa4:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800fa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800faf:	50                   	push   %eax
  800fb0:	68 51 26 80 00       	push   $0x802651
  800fb5:	6a 78                	push   $0x78
  800fb7:	68 28 26 80 00       	push   $0x802628
  800fbc:	e8 b2 0e 00 00       	call   801e73 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800fc1:	83 ec 0c             	sub    $0xc,%esp
  800fc4:	ff 75 e4             	push   -0x1c(%ebp)
  800fc7:	57                   	push   %edi
  800fc8:	ff 75 dc             	push   -0x24(%ebp)
  800fcb:	57                   	push   %edi
  800fcc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fcf:	56                   	push   %esi
  800fd0:	e8 dd fc ff ff       	call   800cb2 <sys_page_map>
	if(r<0) return r;
  800fd5:	83 c4 20             	add    $0x20,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 cb                	js     800fa7 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	ff 75 e4             	push   -0x1c(%ebp)
  800fe2:	57                   	push   %edi
  800fe3:	56                   	push   %esi
  800fe4:	57                   	push   %edi
  800fe5:	56                   	push   %esi
  800fe6:	e8 c7 fc ff ff       	call   800cb2 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 76                	js     801068 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800ff2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ff8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800ffe:	74 75                	je     801075 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801000:	89 d8                	mov    %ebx,%eax
  801002:	c1 e8 16             	shr    $0x16,%eax
  801005:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100c:	a8 01                	test   $0x1,%al
  80100e:	74 e2                	je     800ff2 <fork+0x94>
  801010:	89 de                	mov    %ebx,%esi
  801012:	c1 ee 0c             	shr    $0xc,%esi
  801015:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80101c:	a8 01                	test   $0x1,%al
  80101e:	74 d2                	je     800ff2 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801020:	e8 0c fc ff ff       	call   800c31 <sys_getenvid>
  801025:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801028:	89 f7                	mov    %esi,%edi
  80102a:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  80102d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801034:	89 c1                	mov    %eax,%ecx
  801036:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80103c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  80103f:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801046:	f6 c6 04             	test   $0x4,%dh
  801049:	0f 85 72 ff ff ff    	jne    800fc1 <fork+0x63>
		perm &= ~PTE_W;
  80104f:	25 05 0e 00 00       	and    $0xe05,%eax
  801054:	80 cc 08             	or     $0x8,%ah
  801057:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  80105d:	0f 44 c1             	cmove  %ecx,%eax
  801060:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801063:	e9 59 ff ff ff       	jmp    800fc1 <fork+0x63>
  801068:	ba 00 00 00 00       	mov    $0x0,%edx
  80106d:	0f 4f c2             	cmovg  %edx,%eax
  801070:	e9 32 ff ff ff       	jmp    800fa7 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	6a 07                	push   $0x7
  80107a:	68 00 f0 bf ee       	push   $0xeebff000
  80107f:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801082:	57                   	push   %edi
  801083:	e8 e7 fb ff ff       	call   800c6f <sys_page_alloc>
	if(r<0) return r;
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	0f 88 14 ff ff ff    	js     800fa7 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801093:	83 ec 08             	sub    $0x8,%esp
  801096:	68 2f 1f 80 00       	push   $0x801f2f
  80109b:	57                   	push   %edi
  80109c:	e8 19 fd ff ff       	call   800dba <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	0f 88 fb fe ff ff    	js     800fa7 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010ac:	83 ec 08             	sub    $0x8,%esp
  8010af:	6a 02                	push   $0x2
  8010b1:	57                   	push   %edi
  8010b2:	e8 7f fc ff ff       	call   800d36 <sys_env_set_status>
	if(r<0) return r;
  8010b7:	83 c4 10             	add    $0x10,%esp
	return envid;
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	0f 49 c7             	cmovns %edi,%eax
  8010bf:	e9 e3 fe ff ff       	jmp    800fa7 <fork+0x49>

008010c4 <sfork>:

// Challenge!
int
sfork(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ca:	68 61 26 80 00       	push   $0x802661
  8010cf:	68 a1 00 00 00       	push   $0xa1
  8010d4:	68 28 26 80 00       	push   $0x802628
  8010d9:	e8 95 0d 00 00       	call   801e73 <_panic>

008010de <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010f3:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	50                   	push   %eax
  8010fa:	e8 20 fd ff ff       	call   800e1f <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	85 f6                	test   %esi,%esi
  801104:	74 14                	je     80111a <ipc_recv+0x3c>
  801106:	ba 00 00 00 00       	mov    $0x0,%edx
  80110b:	85 c0                	test   %eax,%eax
  80110d:	78 09                	js     801118 <ipc_recv+0x3a>
  80110f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801115:	8b 52 74             	mov    0x74(%edx),%edx
  801118:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80111a:	85 db                	test   %ebx,%ebx
  80111c:	74 14                	je     801132 <ipc_recv+0x54>
  80111e:	ba 00 00 00 00       	mov    $0x0,%edx
  801123:	85 c0                	test   %eax,%eax
  801125:	78 09                	js     801130 <ipc_recv+0x52>
  801127:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80112d:	8b 52 78             	mov    0x78(%edx),%edx
  801130:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801132:	85 c0                	test   %eax,%eax
  801134:	78 08                	js     80113e <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801136:	a1 00 40 80 00       	mov    0x804000,%eax
  80113b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80113e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801141:	5b                   	pop    %ebx
  801142:	5e                   	pop    %esi
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 0c             	sub    $0xc,%esp
  80114e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801151:	8b 75 0c             	mov    0xc(%ebp),%esi
  801154:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801157:	85 db                	test   %ebx,%ebx
  801159:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80115e:	0f 44 d8             	cmove  %eax,%ebx
  801161:	eb 05                	jmp    801168 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801163:	e8 e8 fa ff ff       	call   800c50 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801168:	ff 75 14             	push   0x14(%ebp)
  80116b:	53                   	push   %ebx
  80116c:	56                   	push   %esi
  80116d:	57                   	push   %edi
  80116e:	e8 89 fc ff ff       	call   800dfc <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801179:	74 e8                	je     801163 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 08                	js     801187 <ipc_send+0x42>
	}while (r<0);

}
  80117f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801187:	50                   	push   %eax
  801188:	68 77 26 80 00       	push   $0x802677
  80118d:	6a 3d                	push   $0x3d
  80118f:	68 8b 26 80 00       	push   $0x80268b
  801194:	e8 da 0c 00 00       	call   801e73 <_panic>

00801199 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011a4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011a7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011ad:	8b 52 50             	mov    0x50(%edx),%edx
  8011b0:	39 ca                	cmp    %ecx,%edx
  8011b2:	74 11                	je     8011c5 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8011b4:	83 c0 01             	add    $0x1,%eax
  8011b7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011bc:	75 e6                	jne    8011a4 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8011be:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c3:	eb 0b                	jmp    8011d0 <ipc_find_env+0x37>
			return envs[i].env_id;
  8011c5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011c8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011cd:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011dd:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e8:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801201:	89 c2                	mov    %eax,%edx
  801203:	c1 ea 16             	shr    $0x16,%edx
  801206:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120d:	f6 c2 01             	test   $0x1,%dl
  801210:	74 29                	je     80123b <fd_alloc+0x42>
  801212:	89 c2                	mov    %eax,%edx
  801214:	c1 ea 0c             	shr    $0xc,%edx
  801217:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121e:	f6 c2 01             	test   $0x1,%dl
  801221:	74 18                	je     80123b <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801223:	05 00 10 00 00       	add    $0x1000,%eax
  801228:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122d:	75 d2                	jne    801201 <fd_alloc+0x8>
  80122f:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801234:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801239:	eb 05                	jmp    801240 <fd_alloc+0x47>
			return 0;
  80123b:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801240:	8b 55 08             	mov    0x8(%ebp),%edx
  801243:	89 02                	mov    %eax,(%edx)
}
  801245:	89 c8                	mov    %ecx,%eax
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80124f:	83 f8 1f             	cmp    $0x1f,%eax
  801252:	77 30                	ja     801284 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801254:	c1 e0 0c             	shl    $0xc,%eax
  801257:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125c:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801262:	f6 c2 01             	test   $0x1,%dl
  801265:	74 24                	je     80128b <fd_lookup+0x42>
  801267:	89 c2                	mov    %eax,%edx
  801269:	c1 ea 0c             	shr    $0xc,%edx
  80126c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801273:	f6 c2 01             	test   $0x1,%dl
  801276:	74 1a                	je     801292 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801278:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127b:	89 02                	mov    %eax,(%edx)
	return 0;
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    
		return -E_INVAL;
  801284:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801289:	eb f7                	jmp    801282 <fd_lookup+0x39>
		return -E_INVAL;
  80128b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801290:	eb f0                	jmp    801282 <fd_lookup+0x39>
  801292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801297:	eb e9                	jmp    801282 <fd_lookup+0x39>

00801299 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	53                   	push   %ebx
  80129d:	83 ec 04             	sub    $0x4,%esp
  8012a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a3:	b8 14 27 80 00       	mov    $0x802714,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  8012a8:	bb 0c 30 80 00       	mov    $0x80300c,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8012ad:	39 13                	cmp    %edx,(%ebx)
  8012af:	74 32                	je     8012e3 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  8012b1:	83 c0 04             	add    $0x4,%eax
  8012b4:	8b 18                	mov    (%eax),%ebx
  8012b6:	85 db                	test   %ebx,%ebx
  8012b8:	75 f3                	jne    8012ad <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ba:	a1 00 40 80 00       	mov    0x804000,%eax
  8012bf:	8b 40 48             	mov    0x48(%eax),%eax
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	52                   	push   %edx
  8012c6:	50                   	push   %eax
  8012c7:	68 98 26 80 00       	push   $0x802698
  8012cc:	e8 c8 ef ff ff       	call   800299 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012dc:	89 1a                	mov    %ebx,(%edx)
}
  8012de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e1:	c9                   	leave  
  8012e2:	c3                   	ret    
			return 0;
  8012e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e8:	eb ef                	jmp    8012d9 <dev_lookup+0x40>

008012ea <fd_close>:
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	57                   	push   %edi
  8012ee:	56                   	push   %esi
  8012ef:	53                   	push   %ebx
  8012f0:	83 ec 24             	sub    $0x24,%esp
  8012f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012fc:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012fd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801303:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801306:	50                   	push   %eax
  801307:	e8 3d ff ff ff       	call   801249 <fd_lookup>
  80130c:	89 c3                	mov    %eax,%ebx
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 05                	js     80131a <fd_close+0x30>
	    || fd != fd2)
  801315:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801318:	74 16                	je     801330 <fd_close+0x46>
		return (must_exist ? r : 0);
  80131a:	89 f8                	mov    %edi,%eax
  80131c:	84 c0                	test   %al,%al
  80131e:	b8 00 00 00 00       	mov    $0x0,%eax
  801323:	0f 44 d8             	cmove  %eax,%ebx
}
  801326:	89 d8                	mov    %ebx,%eax
  801328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5f                   	pop    %edi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	ff 36                	push   (%esi)
  801339:	e8 5b ff ff ff       	call   801299 <dev_lookup>
  80133e:	89 c3                	mov    %eax,%ebx
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	78 1a                	js     801361 <fd_close+0x77>
		if (dev->dev_close)
  801347:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134a:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80134d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801352:	85 c0                	test   %eax,%eax
  801354:	74 0b                	je     801361 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801356:	83 ec 0c             	sub    $0xc,%esp
  801359:	56                   	push   %esi
  80135a:	ff d0                	call   *%eax
  80135c:	89 c3                	mov    %eax,%ebx
  80135e:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	56                   	push   %esi
  801365:	6a 00                	push   $0x0
  801367:	e8 88 f9 ff ff       	call   800cf4 <sys_page_unmap>
	return r;
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	eb b5                	jmp    801326 <fd_close+0x3c>

00801371 <close>:

int
close(int fdnum)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801377:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	ff 75 08             	push   0x8(%ebp)
  80137e:	e8 c6 fe ff ff       	call   801249 <fd_lookup>
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	79 02                	jns    80138c <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    
		return fd_close(fd, 1);
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	6a 01                	push   $0x1
  801391:	ff 75 f4             	push   -0xc(%ebp)
  801394:	e8 51 ff ff ff       	call   8012ea <fd_close>
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	eb ec                	jmp    80138a <close+0x19>

0080139e <close_all>:

void
close_all(void)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	e8 be ff ff ff       	call   801371 <close>
	for (i = 0; i < MAXFD; i++)
  8013b3:	83 c3 01             	add    $0x1,%ebx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	83 fb 20             	cmp    $0x20,%ebx
  8013bc:	75 ec                	jne    8013aa <close_all+0xc>
}
  8013be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	57                   	push   %edi
  8013c7:	56                   	push   %esi
  8013c8:	53                   	push   %ebx
  8013c9:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	ff 75 08             	push   0x8(%ebp)
  8013d3:	e8 71 fe ff ff       	call   801249 <fd_lookup>
  8013d8:	89 c3                	mov    %eax,%ebx
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 7f                	js     801460 <dup+0x9d>
		return r;
	close(newfdnum);
  8013e1:	83 ec 0c             	sub    $0xc,%esp
  8013e4:	ff 75 0c             	push   0xc(%ebp)
  8013e7:	e8 85 ff ff ff       	call   801371 <close>

	newfd = INDEX2FD(newfdnum);
  8013ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013ef:	c1 e6 0c             	shl    $0xc,%esi
  8013f2:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013fb:	89 3c 24             	mov    %edi,(%esp)
  8013fe:	e8 df fd ff ff       	call   8011e2 <fd2data>
  801403:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801405:	89 34 24             	mov    %esi,(%esp)
  801408:	e8 d5 fd ff ff       	call   8011e2 <fd2data>
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801413:	89 d8                	mov    %ebx,%eax
  801415:	c1 e8 16             	shr    $0x16,%eax
  801418:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80141f:	a8 01                	test   $0x1,%al
  801421:	74 11                	je     801434 <dup+0x71>
  801423:	89 d8                	mov    %ebx,%eax
  801425:	c1 e8 0c             	shr    $0xc,%eax
  801428:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80142f:	f6 c2 01             	test   $0x1,%dl
  801432:	75 36                	jne    80146a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801434:	89 f8                	mov    %edi,%eax
  801436:	c1 e8 0c             	shr    $0xc,%eax
  801439:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801440:	83 ec 0c             	sub    $0xc,%esp
  801443:	25 07 0e 00 00       	and    $0xe07,%eax
  801448:	50                   	push   %eax
  801449:	56                   	push   %esi
  80144a:	6a 00                	push   $0x0
  80144c:	57                   	push   %edi
  80144d:	6a 00                	push   $0x0
  80144f:	e8 5e f8 ff ff       	call   800cb2 <sys_page_map>
  801454:	89 c3                	mov    %eax,%ebx
  801456:	83 c4 20             	add    $0x20,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 33                	js     801490 <dup+0xcd>
		goto err;

	return newfdnum;
  80145d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801460:	89 d8                	mov    %ebx,%eax
  801462:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801465:	5b                   	pop    %ebx
  801466:	5e                   	pop    %esi
  801467:	5f                   	pop    %edi
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80146a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801471:	83 ec 0c             	sub    $0xc,%esp
  801474:	25 07 0e 00 00       	and    $0xe07,%eax
  801479:	50                   	push   %eax
  80147a:	ff 75 d4             	push   -0x2c(%ebp)
  80147d:	6a 00                	push   $0x0
  80147f:	53                   	push   %ebx
  801480:	6a 00                	push   $0x0
  801482:	e8 2b f8 ff ff       	call   800cb2 <sys_page_map>
  801487:	89 c3                	mov    %eax,%ebx
  801489:	83 c4 20             	add    $0x20,%esp
  80148c:	85 c0                	test   %eax,%eax
  80148e:	79 a4                	jns    801434 <dup+0x71>
	sys_page_unmap(0, newfd);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	56                   	push   %esi
  801494:	6a 00                	push   $0x0
  801496:	e8 59 f8 ff ff       	call   800cf4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149b:	83 c4 08             	add    $0x8,%esp
  80149e:	ff 75 d4             	push   -0x2c(%ebp)
  8014a1:	6a 00                	push   $0x0
  8014a3:	e8 4c f8 ff ff       	call   800cf4 <sys_page_unmap>
	return r;
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	eb b3                	jmp    801460 <dup+0x9d>

008014ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	56                   	push   %esi
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 18             	sub    $0x18,%esp
  8014b5:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	56                   	push   %esi
  8014bd:	e8 87 fd ff ff       	call   801249 <fd_lookup>
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 3c                	js     801505 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	ff 33                	push   (%ebx)
  8014d5:	e8 bf fd ff ff       	call   801299 <dev_lookup>
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 24                	js     801505 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e1:	8b 43 08             	mov    0x8(%ebx),%eax
  8014e4:	83 e0 03             	and    $0x3,%eax
  8014e7:	83 f8 01             	cmp    $0x1,%eax
  8014ea:	74 20                	je     80150c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ef:	8b 40 08             	mov    0x8(%eax),%eax
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	74 37                	je     80152d <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	ff 75 10             	push   0x10(%ebp)
  8014fc:	ff 75 0c             	push   0xc(%ebp)
  8014ff:	53                   	push   %ebx
  801500:	ff d0                	call   *%eax
  801502:	83 c4 10             	add    $0x10,%esp
}
  801505:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80150c:	a1 00 40 80 00       	mov    0x804000,%eax
  801511:	8b 40 48             	mov    0x48(%eax),%eax
  801514:	83 ec 04             	sub    $0x4,%esp
  801517:	56                   	push   %esi
  801518:	50                   	push   %eax
  801519:	68 d9 26 80 00       	push   $0x8026d9
  80151e:	e8 76 ed ff ff       	call   800299 <cprintf>
		return -E_INVAL;
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152b:	eb d8                	jmp    801505 <read+0x58>
		return -E_NOT_SUPP;
  80152d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801532:	eb d1                	jmp    801505 <read+0x58>

00801534 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	57                   	push   %edi
  801538:	56                   	push   %esi
  801539:	53                   	push   %ebx
  80153a:	83 ec 0c             	sub    $0xc,%esp
  80153d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801540:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801543:	bb 00 00 00 00       	mov    $0x0,%ebx
  801548:	eb 02                	jmp    80154c <readn+0x18>
  80154a:	01 c3                	add    %eax,%ebx
  80154c:	39 f3                	cmp    %esi,%ebx
  80154e:	73 21                	jae    801571 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801550:	83 ec 04             	sub    $0x4,%esp
  801553:	89 f0                	mov    %esi,%eax
  801555:	29 d8                	sub    %ebx,%eax
  801557:	50                   	push   %eax
  801558:	89 d8                	mov    %ebx,%eax
  80155a:	03 45 0c             	add    0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	57                   	push   %edi
  80155f:	e8 49 ff ff ff       	call   8014ad <read>
		if (m < 0)
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	85 c0                	test   %eax,%eax
  801569:	78 04                	js     80156f <readn+0x3b>
			return m;
		if (m == 0)
  80156b:	75 dd                	jne    80154a <readn+0x16>
  80156d:	eb 02                	jmp    801571 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801571:	89 d8                	mov    %ebx,%eax
  801573:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	5f                   	pop    %edi
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    

0080157b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	56                   	push   %esi
  80157f:	53                   	push   %ebx
  801580:	83 ec 18             	sub    $0x18,%esp
  801583:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801586:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	53                   	push   %ebx
  80158b:	e8 b9 fc ff ff       	call   801249 <fd_lookup>
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 37                	js     8015ce <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801597:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	ff 36                	push   (%esi)
  8015a3:	e8 f1 fc ff ff       	call   801299 <dev_lookup>
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 1f                	js     8015ce <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015af:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015b3:	74 20                	je     8015d5 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	74 37                	je     8015f6 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	ff 75 10             	push   0x10(%ebp)
  8015c5:	ff 75 0c             	push   0xc(%ebp)
  8015c8:	56                   	push   %esi
  8015c9:	ff d0                	call   *%eax
  8015cb:	83 c4 10             	add    $0x10,%esp
}
  8015ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d5:	a1 00 40 80 00       	mov    0x804000,%eax
  8015da:	8b 40 48             	mov    0x48(%eax),%eax
  8015dd:	83 ec 04             	sub    $0x4,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	50                   	push   %eax
  8015e2:	68 f5 26 80 00       	push   $0x8026f5
  8015e7:	e8 ad ec ff ff       	call   800299 <cprintf>
		return -E_INVAL;
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f4:	eb d8                	jmp    8015ce <write+0x53>
		return -E_NOT_SUPP;
  8015f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015fb:	eb d1                	jmp    8015ce <write+0x53>

008015fd <seek>:

int
seek(int fdnum, off_t offset)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801603:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	ff 75 08             	push   0x8(%ebp)
  80160a:	e8 3a fc ff ff       	call   801249 <fd_lookup>
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 0e                	js     801624 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801616:	8b 55 0c             	mov    0xc(%ebp),%edx
  801619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80161f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801624:	c9                   	leave  
  801625:	c3                   	ret    

00801626 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	56                   	push   %esi
  80162a:	53                   	push   %ebx
  80162b:	83 ec 18             	sub    $0x18,%esp
  80162e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	53                   	push   %ebx
  801636:	e8 0e fc ff ff       	call   801249 <fd_lookup>
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 34                	js     801676 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801642:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	ff 36                	push   (%esi)
  80164e:	e8 46 fc ff ff       	call   801299 <dev_lookup>
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 1c                	js     801676 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165a:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80165e:	74 1d                	je     80167d <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801663:	8b 40 18             	mov    0x18(%eax),%eax
  801666:	85 c0                	test   %eax,%eax
  801668:	74 34                	je     80169e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	ff 75 0c             	push   0xc(%ebp)
  801670:	56                   	push   %esi
  801671:	ff d0                	call   *%eax
  801673:	83 c4 10             	add    $0x10,%esp
}
  801676:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80167d:	a1 00 40 80 00       	mov    0x804000,%eax
  801682:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801685:	83 ec 04             	sub    $0x4,%esp
  801688:	53                   	push   %ebx
  801689:	50                   	push   %eax
  80168a:	68 b8 26 80 00       	push   $0x8026b8
  80168f:	e8 05 ec ff ff       	call   800299 <cprintf>
		return -E_INVAL;
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169c:	eb d8                	jmp    801676 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80169e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016a3:	eb d1                	jmp    801676 <ftruncate+0x50>

008016a5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	56                   	push   %esi
  8016a9:	53                   	push   %ebx
  8016aa:	83 ec 18             	sub    $0x18,%esp
  8016ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b3:	50                   	push   %eax
  8016b4:	ff 75 08             	push   0x8(%ebp)
  8016b7:	e8 8d fb ff ff       	call   801249 <fd_lookup>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 49                	js     80170c <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cc:	50                   	push   %eax
  8016cd:	ff 36                	push   (%esi)
  8016cf:	e8 c5 fb ff ff       	call   801299 <dev_lookup>
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 31                	js     80170c <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e2:	74 2f                	je     801713 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ee:	00 00 00 
	stat->st_isdir = 0;
  8016f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f8:	00 00 00 
	stat->st_dev = dev;
  8016fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	53                   	push   %ebx
  801705:	56                   	push   %esi
  801706:	ff 50 14             	call   *0x14(%eax)
  801709:	83 c4 10             	add    $0x10,%esp
}
  80170c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    
		return -E_NOT_SUPP;
  801713:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801718:	eb f2                	jmp    80170c <fstat+0x67>

0080171a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	6a 00                	push   $0x0
  801724:	ff 75 08             	push   0x8(%ebp)
  801727:	e8 e4 01 00 00       	call   801910 <open>
  80172c:	89 c3                	mov    %eax,%ebx
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	85 c0                	test   %eax,%eax
  801733:	78 1b                	js     801750 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	ff 75 0c             	push   0xc(%ebp)
  80173b:	50                   	push   %eax
  80173c:	e8 64 ff ff ff       	call   8016a5 <fstat>
  801741:	89 c6                	mov    %eax,%esi
	close(fd);
  801743:	89 1c 24             	mov    %ebx,(%esp)
  801746:	e8 26 fc ff ff       	call   801371 <close>
	return r;
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	89 f3                	mov    %esi,%ebx
}
  801750:	89 d8                	mov    %ebx,%eax
  801752:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801755:	5b                   	pop    %ebx
  801756:	5e                   	pop    %esi
  801757:	5d                   	pop    %ebp
  801758:	c3                   	ret    

00801759 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	89 c6                	mov    %eax,%esi
  801760:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801762:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801769:	74 27                	je     801792 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80176b:	6a 07                	push   $0x7
  80176d:	68 00 50 80 00       	push   $0x805000
  801772:	56                   	push   %esi
  801773:	ff 35 00 60 80 00    	push   0x806000
  801779:	e8 c7 f9 ff ff       	call   801145 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80177e:	83 c4 0c             	add    $0xc,%esp
  801781:	6a 00                	push   $0x0
  801783:	53                   	push   %ebx
  801784:	6a 00                	push   $0x0
  801786:	e8 53 f9 ff ff       	call   8010de <ipc_recv>
}
  80178b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178e:	5b                   	pop    %ebx
  80178f:	5e                   	pop    %esi
  801790:	5d                   	pop    %ebp
  801791:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801792:	83 ec 0c             	sub    $0xc,%esp
  801795:	6a 01                	push   $0x1
  801797:	e8 fd f9 ff ff       	call   801199 <ipc_find_env>
  80179c:	a3 00 60 80 00       	mov    %eax,0x806000
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	eb c5                	jmp    80176b <fsipc+0x12>

008017a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c9:	e8 8b ff ff ff       	call   801759 <fsipc>
}
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    

008017d0 <devfile_flush>:
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8017eb:	e8 69 ff ff ff       	call   801759 <fsipc>
}
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <devfile_stat>:
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 04             	sub    $0x4,%esp
  8017f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801802:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801807:	ba 00 00 00 00       	mov    $0x0,%edx
  80180c:	b8 05 00 00 00       	mov    $0x5,%eax
  801811:	e8 43 ff ff ff       	call   801759 <fsipc>
  801816:	85 c0                	test   %eax,%eax
  801818:	78 2c                	js     801846 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	68 00 50 80 00       	push   $0x805000
  801822:	53                   	push   %ebx
  801823:	e8 4b f0 ff ff       	call   800873 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801828:	a1 80 50 80 00       	mov    0x805080,%eax
  80182d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801833:	a1 84 50 80 00       	mov    0x805084,%eax
  801838:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <devfile_write>:
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	83 ec 0c             	sub    $0xc,%esp
  801851:	8b 45 10             	mov    0x10(%ebp),%eax
  801854:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801859:	39 d0                	cmp    %edx,%eax
  80185b:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80185e:	8b 55 08             	mov    0x8(%ebp),%edx
  801861:	8b 52 0c             	mov    0xc(%edx),%edx
  801864:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80186a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80186f:	50                   	push   %eax
  801870:	ff 75 0c             	push   0xc(%ebp)
  801873:	68 08 50 80 00       	push   $0x805008
  801878:	e8 8c f1 ff ff       	call   800a09 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80187d:	ba 00 00 00 00       	mov    $0x0,%edx
  801882:	b8 04 00 00 00       	mov    $0x4,%eax
  801887:	e8 cd fe ff ff       	call   801759 <fsipc>
}
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <devfile_read>:
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	56                   	push   %esi
  801892:	53                   	push   %ebx
  801893:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801896:	8b 45 08             	mov    0x8(%ebp),%eax
  801899:	8b 40 0c             	mov    0xc(%eax),%eax
  80189c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ac:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b1:	e8 a3 fe ff ff       	call   801759 <fsipc>
  8018b6:	89 c3                	mov    %eax,%ebx
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 1f                	js     8018db <devfile_read+0x4d>
	assert(r <= n);
  8018bc:	39 f0                	cmp    %esi,%eax
  8018be:	77 24                	ja     8018e4 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018c0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c5:	7f 33                	jg     8018fa <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	50                   	push   %eax
  8018cb:	68 00 50 80 00       	push   $0x805000
  8018d0:	ff 75 0c             	push   0xc(%ebp)
  8018d3:	e8 31 f1 ff ff       	call   800a09 <memmove>
	return r;
  8018d8:	83 c4 10             	add    $0x10,%esp
}
  8018db:	89 d8                	mov    %ebx,%eax
  8018dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    
	assert(r <= n);
  8018e4:	68 24 27 80 00       	push   $0x802724
  8018e9:	68 2b 27 80 00       	push   $0x80272b
  8018ee:	6a 7c                	push   $0x7c
  8018f0:	68 40 27 80 00       	push   $0x802740
  8018f5:	e8 79 05 00 00       	call   801e73 <_panic>
	assert(r <= PGSIZE);
  8018fa:	68 4b 27 80 00       	push   $0x80274b
  8018ff:	68 2b 27 80 00       	push   $0x80272b
  801904:	6a 7d                	push   $0x7d
  801906:	68 40 27 80 00       	push   $0x802740
  80190b:	e8 63 05 00 00       	call   801e73 <_panic>

00801910 <open>:
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	83 ec 1c             	sub    $0x1c,%esp
  801918:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80191b:	56                   	push   %esi
  80191c:	e8 17 ef ff ff       	call   800838 <strlen>
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801929:	7f 6c                	jg     801997 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80192b:	83 ec 0c             	sub    $0xc,%esp
  80192e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801931:	50                   	push   %eax
  801932:	e8 c2 f8 ff ff       	call   8011f9 <fd_alloc>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 3c                	js     80197c <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801940:	83 ec 08             	sub    $0x8,%esp
  801943:	56                   	push   %esi
  801944:	68 00 50 80 00       	push   $0x805000
  801949:	e8 25 ef ff ff       	call   800873 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80194e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801951:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801956:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801959:	b8 01 00 00 00       	mov    $0x1,%eax
  80195e:	e8 f6 fd ff ff       	call   801759 <fsipc>
  801963:	89 c3                	mov    %eax,%ebx
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	85 c0                	test   %eax,%eax
  80196a:	78 19                	js     801985 <open+0x75>
	return fd2num(fd);
  80196c:	83 ec 0c             	sub    $0xc,%esp
  80196f:	ff 75 f4             	push   -0xc(%ebp)
  801972:	e8 5b f8 ff ff       	call   8011d2 <fd2num>
  801977:	89 c3                	mov    %eax,%ebx
  801979:	83 c4 10             	add    $0x10,%esp
}
  80197c:	89 d8                	mov    %ebx,%eax
  80197e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801981:	5b                   	pop    %ebx
  801982:	5e                   	pop    %esi
  801983:	5d                   	pop    %ebp
  801984:	c3                   	ret    
		fd_close(fd, 0);
  801985:	83 ec 08             	sub    $0x8,%esp
  801988:	6a 00                	push   $0x0
  80198a:	ff 75 f4             	push   -0xc(%ebp)
  80198d:	e8 58 f9 ff ff       	call   8012ea <fd_close>
		return r;
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	eb e5                	jmp    80197c <open+0x6c>
		return -E_BAD_PATH;
  801997:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80199c:	eb de                	jmp    80197c <open+0x6c>

0080199e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ae:	e8 a6 fd ff ff       	call   801759 <fsipc>
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	56                   	push   %esi
  8019b9:	53                   	push   %ebx
  8019ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	ff 75 08             	push   0x8(%ebp)
  8019c3:	e8 1a f8 ff ff       	call   8011e2 <fd2data>
  8019c8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019ca:	83 c4 08             	add    $0x8,%esp
  8019cd:	68 57 27 80 00       	push   $0x802757
  8019d2:	53                   	push   %ebx
  8019d3:	e8 9b ee ff ff       	call   800873 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019d8:	8b 46 04             	mov    0x4(%esi),%eax
  8019db:	2b 06                	sub    (%esi),%eax
  8019dd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019e3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ea:	00 00 00 
	stat->st_dev = &devpipe;
  8019ed:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  8019f4:	30 80 00 
	return 0;
}
  8019f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ff:	5b                   	pop    %ebx
  801a00:	5e                   	pop    %esi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	53                   	push   %ebx
  801a07:	83 ec 0c             	sub    $0xc,%esp
  801a0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a0d:	53                   	push   %ebx
  801a0e:	6a 00                	push   $0x0
  801a10:	e8 df f2 ff ff       	call   800cf4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a15:	89 1c 24             	mov    %ebx,(%esp)
  801a18:	e8 c5 f7 ff ff       	call   8011e2 <fd2data>
  801a1d:	83 c4 08             	add    $0x8,%esp
  801a20:	50                   	push   %eax
  801a21:	6a 00                	push   $0x0
  801a23:	e8 cc f2 ff ff       	call   800cf4 <sys_page_unmap>
}
  801a28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <_pipeisclosed>:
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	57                   	push   %edi
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	83 ec 1c             	sub    $0x1c,%esp
  801a36:	89 c7                	mov    %eax,%edi
  801a38:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a3a:	a1 00 40 80 00       	mov    0x804000,%eax
  801a3f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	57                   	push   %edi
  801a46:	e8 0a 05 00 00       	call   801f55 <pageref>
  801a4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a4e:	89 34 24             	mov    %esi,(%esp)
  801a51:	e8 ff 04 00 00       	call   801f55 <pageref>
		nn = thisenv->env_runs;
  801a56:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a5c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	39 cb                	cmp    %ecx,%ebx
  801a64:	74 1b                	je     801a81 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a66:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a69:	75 cf                	jne    801a3a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a6b:	8b 42 58             	mov    0x58(%edx),%eax
  801a6e:	6a 01                	push   $0x1
  801a70:	50                   	push   %eax
  801a71:	53                   	push   %ebx
  801a72:	68 5e 27 80 00       	push   $0x80275e
  801a77:	e8 1d e8 ff ff       	call   800299 <cprintf>
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	eb b9                	jmp    801a3a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a81:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a84:	0f 94 c0             	sete   %al
  801a87:	0f b6 c0             	movzbl %al,%eax
}
  801a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5f                   	pop    %edi
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    

00801a92 <devpipe_write>:
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	57                   	push   %edi
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	83 ec 28             	sub    $0x28,%esp
  801a9b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a9e:	56                   	push   %esi
  801a9f:	e8 3e f7 ff ff       	call   8011e2 <fd2data>
  801aa4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	bf 00 00 00 00       	mov    $0x0,%edi
  801aae:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ab1:	75 09                	jne    801abc <devpipe_write+0x2a>
	return i;
  801ab3:	89 f8                	mov    %edi,%eax
  801ab5:	eb 23                	jmp    801ada <devpipe_write+0x48>
			sys_yield();
  801ab7:	e8 94 f1 ff ff       	call   800c50 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801abc:	8b 43 04             	mov    0x4(%ebx),%eax
  801abf:	8b 0b                	mov    (%ebx),%ecx
  801ac1:	8d 51 20             	lea    0x20(%ecx),%edx
  801ac4:	39 d0                	cmp    %edx,%eax
  801ac6:	72 1a                	jb     801ae2 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ac8:	89 da                	mov    %ebx,%edx
  801aca:	89 f0                	mov    %esi,%eax
  801acc:	e8 5c ff ff ff       	call   801a2d <_pipeisclosed>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	74 e2                	je     801ab7 <devpipe_write+0x25>
				return 0;
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5f                   	pop    %edi
  801ae0:	5d                   	pop    %ebp
  801ae1:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ae9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aec:	89 c2                	mov    %eax,%edx
  801aee:	c1 fa 1f             	sar    $0x1f,%edx
  801af1:	89 d1                	mov    %edx,%ecx
  801af3:	c1 e9 1b             	shr    $0x1b,%ecx
  801af6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801af9:	83 e2 1f             	and    $0x1f,%edx
  801afc:	29 ca                	sub    %ecx,%edx
  801afe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b06:	83 c0 01             	add    $0x1,%eax
  801b09:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b0c:	83 c7 01             	add    $0x1,%edi
  801b0f:	eb 9d                	jmp    801aae <devpipe_write+0x1c>

00801b11 <devpipe_read>:
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	57                   	push   %edi
  801b15:	56                   	push   %esi
  801b16:	53                   	push   %ebx
  801b17:	83 ec 18             	sub    $0x18,%esp
  801b1a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b1d:	57                   	push   %edi
  801b1e:	e8 bf f6 ff ff       	call   8011e2 <fd2data>
  801b23:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	be 00 00 00 00       	mov    $0x0,%esi
  801b2d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b30:	75 13                	jne    801b45 <devpipe_read+0x34>
	return i;
  801b32:	89 f0                	mov    %esi,%eax
  801b34:	eb 02                	jmp    801b38 <devpipe_read+0x27>
				return i;
  801b36:	89 f0                	mov    %esi,%eax
}
  801b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3b:	5b                   	pop    %ebx
  801b3c:	5e                   	pop    %esi
  801b3d:	5f                   	pop    %edi
  801b3e:	5d                   	pop    %ebp
  801b3f:	c3                   	ret    
			sys_yield();
  801b40:	e8 0b f1 ff ff       	call   800c50 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b45:	8b 03                	mov    (%ebx),%eax
  801b47:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b4a:	75 18                	jne    801b64 <devpipe_read+0x53>
			if (i > 0)
  801b4c:	85 f6                	test   %esi,%esi
  801b4e:	75 e6                	jne    801b36 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801b50:	89 da                	mov    %ebx,%edx
  801b52:	89 f8                	mov    %edi,%eax
  801b54:	e8 d4 fe ff ff       	call   801a2d <_pipeisclosed>
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	74 e3                	je     801b40 <devpipe_read+0x2f>
				return 0;
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b62:	eb d4                	jmp    801b38 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b64:	99                   	cltd   
  801b65:	c1 ea 1b             	shr    $0x1b,%edx
  801b68:	01 d0                	add    %edx,%eax
  801b6a:	83 e0 1f             	and    $0x1f,%eax
  801b6d:	29 d0                	sub    %edx,%eax
  801b6f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b77:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b7a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b7d:	83 c6 01             	add    $0x1,%esi
  801b80:	eb ab                	jmp    801b2d <devpipe_read+0x1c>

00801b82 <pipe>:
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	56                   	push   %esi
  801b86:	53                   	push   %ebx
  801b87:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8d:	50                   	push   %eax
  801b8e:	e8 66 f6 ff ff       	call   8011f9 <fd_alloc>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	0f 88 23 01 00 00    	js     801cc3 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba0:	83 ec 04             	sub    $0x4,%esp
  801ba3:	68 07 04 00 00       	push   $0x407
  801ba8:	ff 75 f4             	push   -0xc(%ebp)
  801bab:	6a 00                	push   $0x0
  801bad:	e8 bd f0 ff ff       	call   800c6f <sys_page_alloc>
  801bb2:	89 c3                	mov    %eax,%ebx
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 88 04 01 00 00    	js     801cc3 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801bbf:	83 ec 0c             	sub    $0xc,%esp
  801bc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc5:	50                   	push   %eax
  801bc6:	e8 2e f6 ff ff       	call   8011f9 <fd_alloc>
  801bcb:	89 c3                	mov    %eax,%ebx
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	0f 88 db 00 00 00    	js     801cb3 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd8:	83 ec 04             	sub    $0x4,%esp
  801bdb:	68 07 04 00 00       	push   $0x407
  801be0:	ff 75 f0             	push   -0x10(%ebp)
  801be3:	6a 00                	push   $0x0
  801be5:	e8 85 f0 ff ff       	call   800c6f <sys_page_alloc>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	0f 88 bc 00 00 00    	js     801cb3 <pipe+0x131>
	va = fd2data(fd0);
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	ff 75 f4             	push   -0xc(%ebp)
  801bfd:	e8 e0 f5 ff ff       	call   8011e2 <fd2data>
  801c02:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c04:	83 c4 0c             	add    $0xc,%esp
  801c07:	68 07 04 00 00       	push   $0x407
  801c0c:	50                   	push   %eax
  801c0d:	6a 00                	push   $0x0
  801c0f:	e8 5b f0 ff ff       	call   800c6f <sys_page_alloc>
  801c14:	89 c3                	mov    %eax,%ebx
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	0f 88 82 00 00 00    	js     801ca3 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c21:	83 ec 0c             	sub    $0xc,%esp
  801c24:	ff 75 f0             	push   -0x10(%ebp)
  801c27:	e8 b6 f5 ff ff       	call   8011e2 <fd2data>
  801c2c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c33:	50                   	push   %eax
  801c34:	6a 00                	push   $0x0
  801c36:	56                   	push   %esi
  801c37:	6a 00                	push   $0x0
  801c39:	e8 74 f0 ff ff       	call   800cb2 <sys_page_map>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	83 c4 20             	add    $0x20,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	78 4e                	js     801c95 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c47:	a1 28 30 80 00       	mov    0x803028,%eax
  801c4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c4f:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c54:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c5e:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c63:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c6a:	83 ec 0c             	sub    $0xc,%esp
  801c6d:	ff 75 f4             	push   -0xc(%ebp)
  801c70:	e8 5d f5 ff ff       	call   8011d2 <fd2num>
  801c75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c78:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c7a:	83 c4 04             	add    $0x4,%esp
  801c7d:	ff 75 f0             	push   -0x10(%ebp)
  801c80:	e8 4d f5 ff ff       	call   8011d2 <fd2num>
  801c85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c88:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c93:	eb 2e                	jmp    801cc3 <pipe+0x141>
	sys_page_unmap(0, va);
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	56                   	push   %esi
  801c99:	6a 00                	push   $0x0
  801c9b:	e8 54 f0 ff ff       	call   800cf4 <sys_page_unmap>
  801ca0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ca3:	83 ec 08             	sub    $0x8,%esp
  801ca6:	ff 75 f0             	push   -0x10(%ebp)
  801ca9:	6a 00                	push   $0x0
  801cab:	e8 44 f0 ff ff       	call   800cf4 <sys_page_unmap>
  801cb0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801cb3:	83 ec 08             	sub    $0x8,%esp
  801cb6:	ff 75 f4             	push   -0xc(%ebp)
  801cb9:	6a 00                	push   $0x0
  801cbb:	e8 34 f0 ff ff       	call   800cf4 <sys_page_unmap>
  801cc0:	83 c4 10             	add    $0x10,%esp
}
  801cc3:	89 d8                	mov    %ebx,%eax
  801cc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5e                   	pop    %esi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <pipeisclosed>:
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd5:	50                   	push   %eax
  801cd6:	ff 75 08             	push   0x8(%ebp)
  801cd9:	e8 6b f5 ff ff       	call   801249 <fd_lookup>
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	78 18                	js     801cfd <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801ce5:	83 ec 0c             	sub    $0xc,%esp
  801ce8:	ff 75 f4             	push   -0xc(%ebp)
  801ceb:	e8 f2 f4 ff ff       	call   8011e2 <fd2data>
  801cf0:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	e8 33 fd ff ff       	call   801a2d <_pipeisclosed>
  801cfa:	83 c4 10             	add    $0x10,%esp
}
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    

00801cff <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801cff:	b8 00 00 00 00       	mov    $0x0,%eax
  801d04:	c3                   	ret    

00801d05 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d0b:	68 76 27 80 00       	push   $0x802776
  801d10:	ff 75 0c             	push   0xc(%ebp)
  801d13:	e8 5b eb ff ff       	call   800873 <strcpy>
	return 0;
}
  801d18:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1d:	c9                   	leave  
  801d1e:	c3                   	ret    

00801d1f <devcons_write>:
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	57                   	push   %edi
  801d23:	56                   	push   %esi
  801d24:	53                   	push   %ebx
  801d25:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d2b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d30:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d36:	eb 2e                	jmp    801d66 <devcons_write+0x47>
		m = n - tot;
  801d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d3b:	29 f3                	sub    %esi,%ebx
  801d3d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d42:	39 c3                	cmp    %eax,%ebx
  801d44:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d47:	83 ec 04             	sub    $0x4,%esp
  801d4a:	53                   	push   %ebx
  801d4b:	89 f0                	mov    %esi,%eax
  801d4d:	03 45 0c             	add    0xc(%ebp),%eax
  801d50:	50                   	push   %eax
  801d51:	57                   	push   %edi
  801d52:	e8 b2 ec ff ff       	call   800a09 <memmove>
		sys_cputs(buf, m);
  801d57:	83 c4 08             	add    $0x8,%esp
  801d5a:	53                   	push   %ebx
  801d5b:	57                   	push   %edi
  801d5c:	e8 52 ee ff ff       	call   800bb3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d61:	01 de                	add    %ebx,%esi
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d69:	72 cd                	jb     801d38 <devcons_write+0x19>
}
  801d6b:	89 f0                	mov    %esi,%eax
  801d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d70:	5b                   	pop    %ebx
  801d71:	5e                   	pop    %esi
  801d72:	5f                   	pop    %edi
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <devcons_read>:
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 08             	sub    $0x8,%esp
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d84:	75 07                	jne    801d8d <devcons_read+0x18>
  801d86:	eb 1f                	jmp    801da7 <devcons_read+0x32>
		sys_yield();
  801d88:	e8 c3 ee ff ff       	call   800c50 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d8d:	e8 3f ee ff ff       	call   800bd1 <sys_cgetc>
  801d92:	85 c0                	test   %eax,%eax
  801d94:	74 f2                	je     801d88 <devcons_read+0x13>
	if (c < 0)
  801d96:	78 0f                	js     801da7 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801d98:	83 f8 04             	cmp    $0x4,%eax
  801d9b:	74 0c                	je     801da9 <devcons_read+0x34>
	*(char*)vbuf = c;
  801d9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da0:	88 02                	mov    %al,(%edx)
	return 1;
  801da2:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    
		return 0;
  801da9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dae:	eb f7                	jmp    801da7 <devcons_read+0x32>

00801db0 <cputchar>:
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801db6:	8b 45 08             	mov    0x8(%ebp),%eax
  801db9:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801dbc:	6a 01                	push   $0x1
  801dbe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc1:	50                   	push   %eax
  801dc2:	e8 ec ed ff ff       	call   800bb3 <sys_cputs>
}
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <getchar>:
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801dd2:	6a 01                	push   $0x1
  801dd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd7:	50                   	push   %eax
  801dd8:	6a 00                	push   $0x0
  801dda:	e8 ce f6 ff ff       	call   8014ad <read>
	if (r < 0)
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	85 c0                	test   %eax,%eax
  801de4:	78 06                	js     801dec <getchar+0x20>
	if (r < 1)
  801de6:	74 06                	je     801dee <getchar+0x22>
	return c;
  801de8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    
		return -E_EOF;
  801dee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801df3:	eb f7                	jmp    801dec <getchar+0x20>

00801df5 <iscons>:
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	ff 75 08             	push   0x8(%ebp)
  801e02:	e8 42 f4 ff ff       	call   801249 <fd_lookup>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	78 11                	js     801e1f <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e11:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e17:	39 10                	cmp    %edx,(%eax)
  801e19:	0f 94 c0             	sete   %al
  801e1c:	0f b6 c0             	movzbl %al,%eax
}
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    

00801e21 <opencons>:
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2a:	50                   	push   %eax
  801e2b:	e8 c9 f3 ff ff       	call   8011f9 <fd_alloc>
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 3a                	js     801e71 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e37:	83 ec 04             	sub    $0x4,%esp
  801e3a:	68 07 04 00 00       	push   $0x407
  801e3f:	ff 75 f4             	push   -0xc(%ebp)
  801e42:	6a 00                	push   $0x0
  801e44:	e8 26 ee ff ff       	call   800c6f <sys_page_alloc>
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	78 21                	js     801e71 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e53:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e59:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e65:	83 ec 0c             	sub    $0xc,%esp
  801e68:	50                   	push   %eax
  801e69:	e8 64 f3 ff ff       	call   8011d2 <fd2num>
  801e6e:	83 c4 10             	add    $0x10,%esp
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e78:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e7b:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801e81:	e8 ab ed ff ff       	call   800c31 <sys_getenvid>
  801e86:	83 ec 0c             	sub    $0xc,%esp
  801e89:	ff 75 0c             	push   0xc(%ebp)
  801e8c:	ff 75 08             	push   0x8(%ebp)
  801e8f:	56                   	push   %esi
  801e90:	50                   	push   %eax
  801e91:	68 84 27 80 00       	push   $0x802784
  801e96:	e8 fe e3 ff ff       	call   800299 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e9b:	83 c4 18             	add    $0x18,%esp
  801e9e:	53                   	push   %ebx
  801e9f:	ff 75 10             	push   0x10(%ebp)
  801ea2:	e8 a1 e3 ff ff       	call   800248 <vcprintf>
	cprintf("\n");
  801ea7:	c7 04 24 6f 27 80 00 	movl   $0x80276f,(%esp)
  801eae:	e8 e6 e3 ff ff       	call   800299 <cprintf>
  801eb3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eb6:	cc                   	int3   
  801eb7:	eb fd                	jmp    801eb6 <_panic+0x43>

00801eb9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801ebf:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801ec6:	74 0a                	je     801ed2 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecb:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801ed2:	e8 5a ed ff ff       	call   800c31 <sys_getenvid>
  801ed7:	83 ec 04             	sub    $0x4,%esp
  801eda:	68 07 0e 00 00       	push   $0xe07
  801edf:	68 00 f0 bf ee       	push   $0xeebff000
  801ee4:	50                   	push   %eax
  801ee5:	e8 85 ed ff ff       	call   800c6f <sys_page_alloc>
		if (r < 0) {
  801eea:	83 c4 10             	add    $0x10,%esp
  801eed:	85 c0                	test   %eax,%eax
  801eef:	78 2c                	js     801f1d <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801ef1:	e8 3b ed ff ff       	call   800c31 <sys_getenvid>
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	68 2f 1f 80 00       	push   $0x801f2f
  801efe:	50                   	push   %eax
  801eff:	e8 b6 ee ff ff       	call   800dba <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	85 c0                	test   %eax,%eax
  801f09:	79 bd                	jns    801ec8 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801f0b:	50                   	push   %eax
  801f0c:	68 e8 27 80 00       	push   $0x8027e8
  801f11:	6a 28                	push   $0x28
  801f13:	68 1e 28 80 00       	push   $0x80281e
  801f18:	e8 56 ff ff ff       	call   801e73 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801f1d:	50                   	push   %eax
  801f1e:	68 a8 27 80 00       	push   $0x8027a8
  801f23:	6a 23                	push   $0x23
  801f25:	68 1e 28 80 00       	push   $0x80281e
  801f2a:	e8 44 ff ff ff       	call   801e73 <_panic>

00801f2f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f2f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f30:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801f35:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f37:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801f3a:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801f3e:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801f41:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801f45:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801f49:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801f4b:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801f4e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801f4f:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801f52:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801f53:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801f54:	c3                   	ret    

00801f55 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5b:	89 c2                	mov    %eax,%edx
  801f5d:	c1 ea 16             	shr    $0x16,%edx
  801f60:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801f67:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801f6c:	f6 c1 01             	test   $0x1,%cl
  801f6f:	74 1c                	je     801f8d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801f71:	c1 e8 0c             	shr    $0xc,%eax
  801f74:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f7b:	a8 01                	test   $0x1,%al
  801f7d:	74 0e                	je     801f8d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f7f:	c1 e8 0c             	shr    $0xc,%eax
  801f82:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801f89:	ef 
  801f8a:	0f b7 d2             	movzwl %dx,%edx
}
  801f8d:	89 d0                	mov    %edx,%eax
  801f8f:	5d                   	pop    %ebp
  801f90:	c3                   	ret    
  801f91:	66 90                	xchg   %ax,%ax
  801f93:	66 90                	xchg   %ax,%ax
  801f95:	66 90                	xchg   %ax,%ax
  801f97:	66 90                	xchg   %ax,%ax
  801f99:	66 90                	xchg   %ax,%ax
  801f9b:	66 90                	xchg   %ax,%ax
  801f9d:	66 90                	xchg   %ax,%ax
  801f9f:	90                   	nop

00801fa0 <__udivdi3>:
  801fa0:	f3 0f 1e fb          	endbr32 
  801fa4:	55                   	push   %ebp
  801fa5:	57                   	push   %edi
  801fa6:	56                   	push   %esi
  801fa7:	53                   	push   %ebx
  801fa8:	83 ec 1c             	sub    $0x1c,%esp
  801fab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801faf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fb3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fb7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	75 19                	jne    801fd8 <__udivdi3+0x38>
  801fbf:	39 f3                	cmp    %esi,%ebx
  801fc1:	76 4d                	jbe    802010 <__udivdi3+0x70>
  801fc3:	31 ff                	xor    %edi,%edi
  801fc5:	89 e8                	mov    %ebp,%eax
  801fc7:	89 f2                	mov    %esi,%edx
  801fc9:	f7 f3                	div    %ebx
  801fcb:	89 fa                	mov    %edi,%edx
  801fcd:	83 c4 1c             	add    $0x1c,%esp
  801fd0:	5b                   	pop    %ebx
  801fd1:	5e                   	pop    %esi
  801fd2:	5f                   	pop    %edi
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    
  801fd5:	8d 76 00             	lea    0x0(%esi),%esi
  801fd8:	39 f0                	cmp    %esi,%eax
  801fda:	76 14                	jbe    801ff0 <__udivdi3+0x50>
  801fdc:	31 ff                	xor    %edi,%edi
  801fde:	31 c0                	xor    %eax,%eax
  801fe0:	89 fa                	mov    %edi,%edx
  801fe2:	83 c4 1c             	add    $0x1c,%esp
  801fe5:	5b                   	pop    %ebx
  801fe6:	5e                   	pop    %esi
  801fe7:	5f                   	pop    %edi
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    
  801fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff0:	0f bd f8             	bsr    %eax,%edi
  801ff3:	83 f7 1f             	xor    $0x1f,%edi
  801ff6:	75 48                	jne    802040 <__udivdi3+0xa0>
  801ff8:	39 f0                	cmp    %esi,%eax
  801ffa:	72 06                	jb     802002 <__udivdi3+0x62>
  801ffc:	31 c0                	xor    %eax,%eax
  801ffe:	39 eb                	cmp    %ebp,%ebx
  802000:	77 de                	ja     801fe0 <__udivdi3+0x40>
  802002:	b8 01 00 00 00       	mov    $0x1,%eax
  802007:	eb d7                	jmp    801fe0 <__udivdi3+0x40>
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	89 d9                	mov    %ebx,%ecx
  802012:	85 db                	test   %ebx,%ebx
  802014:	75 0b                	jne    802021 <__udivdi3+0x81>
  802016:	b8 01 00 00 00       	mov    $0x1,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	f7 f3                	div    %ebx
  80201f:	89 c1                	mov    %eax,%ecx
  802021:	31 d2                	xor    %edx,%edx
  802023:	89 f0                	mov    %esi,%eax
  802025:	f7 f1                	div    %ecx
  802027:	89 c6                	mov    %eax,%esi
  802029:	89 e8                	mov    %ebp,%eax
  80202b:	89 f7                	mov    %esi,%edi
  80202d:	f7 f1                	div    %ecx
  80202f:	89 fa                	mov    %edi,%edx
  802031:	83 c4 1c             	add    $0x1c,%esp
  802034:	5b                   	pop    %ebx
  802035:	5e                   	pop    %esi
  802036:	5f                   	pop    %edi
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	89 f9                	mov    %edi,%ecx
  802042:	ba 20 00 00 00       	mov    $0x20,%edx
  802047:	29 fa                	sub    %edi,%edx
  802049:	d3 e0                	shl    %cl,%eax
  80204b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80204f:	89 d1                	mov    %edx,%ecx
  802051:	89 d8                	mov    %ebx,%eax
  802053:	d3 e8                	shr    %cl,%eax
  802055:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802059:	09 c1                	or     %eax,%ecx
  80205b:	89 f0                	mov    %esi,%eax
  80205d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e3                	shl    %cl,%ebx
  802065:	89 d1                	mov    %edx,%ecx
  802067:	d3 e8                	shr    %cl,%eax
  802069:	89 f9                	mov    %edi,%ecx
  80206b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80206f:	89 eb                	mov    %ebp,%ebx
  802071:	d3 e6                	shl    %cl,%esi
  802073:	89 d1                	mov    %edx,%ecx
  802075:	d3 eb                	shr    %cl,%ebx
  802077:	09 f3                	or     %esi,%ebx
  802079:	89 c6                	mov    %eax,%esi
  80207b:	89 f2                	mov    %esi,%edx
  80207d:	89 d8                	mov    %ebx,%eax
  80207f:	f7 74 24 08          	divl   0x8(%esp)
  802083:	89 d6                	mov    %edx,%esi
  802085:	89 c3                	mov    %eax,%ebx
  802087:	f7 64 24 0c          	mull   0xc(%esp)
  80208b:	39 d6                	cmp    %edx,%esi
  80208d:	72 19                	jb     8020a8 <__udivdi3+0x108>
  80208f:	89 f9                	mov    %edi,%ecx
  802091:	d3 e5                	shl    %cl,%ebp
  802093:	39 c5                	cmp    %eax,%ebp
  802095:	73 04                	jae    80209b <__udivdi3+0xfb>
  802097:	39 d6                	cmp    %edx,%esi
  802099:	74 0d                	je     8020a8 <__udivdi3+0x108>
  80209b:	89 d8                	mov    %ebx,%eax
  80209d:	31 ff                	xor    %edi,%edi
  80209f:	e9 3c ff ff ff       	jmp    801fe0 <__udivdi3+0x40>
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020ab:	31 ff                	xor    %edi,%edi
  8020ad:	e9 2e ff ff ff       	jmp    801fe0 <__udivdi3+0x40>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	f3 0f 1e fb          	endbr32 
  8020c4:	55                   	push   %ebp
  8020c5:	57                   	push   %edi
  8020c6:	56                   	push   %esi
  8020c7:	53                   	push   %ebx
  8020c8:	83 ec 1c             	sub    $0x1c,%esp
  8020cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020d3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8020d7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8020db:	89 f0                	mov    %esi,%eax
  8020dd:	89 da                	mov    %ebx,%edx
  8020df:	85 ff                	test   %edi,%edi
  8020e1:	75 15                	jne    8020f8 <__umoddi3+0x38>
  8020e3:	39 dd                	cmp    %ebx,%ebp
  8020e5:	76 39                	jbe    802120 <__umoddi3+0x60>
  8020e7:	f7 f5                	div    %ebp
  8020e9:	89 d0                	mov    %edx,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	83 c4 1c             	add    $0x1c,%esp
  8020f0:	5b                   	pop    %ebx
  8020f1:	5e                   	pop    %esi
  8020f2:	5f                   	pop    %edi
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    
  8020f5:	8d 76 00             	lea    0x0(%esi),%esi
  8020f8:	39 df                	cmp    %ebx,%edi
  8020fa:	77 f1                	ja     8020ed <__umoddi3+0x2d>
  8020fc:	0f bd cf             	bsr    %edi,%ecx
  8020ff:	83 f1 1f             	xor    $0x1f,%ecx
  802102:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802106:	75 40                	jne    802148 <__umoddi3+0x88>
  802108:	39 df                	cmp    %ebx,%edi
  80210a:	72 04                	jb     802110 <__umoddi3+0x50>
  80210c:	39 f5                	cmp    %esi,%ebp
  80210e:	77 dd                	ja     8020ed <__umoddi3+0x2d>
  802110:	89 da                	mov    %ebx,%edx
  802112:	89 f0                	mov    %esi,%eax
  802114:	29 e8                	sub    %ebp,%eax
  802116:	19 fa                	sbb    %edi,%edx
  802118:	eb d3                	jmp    8020ed <__umoddi3+0x2d>
  80211a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802120:	89 e9                	mov    %ebp,%ecx
  802122:	85 ed                	test   %ebp,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x71>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f5                	div    %ebp
  80212f:	89 c1                	mov    %eax,%ecx
  802131:	89 d8                	mov    %ebx,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f1                	div    %ecx
  802137:	89 f0                	mov    %esi,%eax
  802139:	f7 f1                	div    %ecx
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	31 d2                	xor    %edx,%edx
  80213f:	eb ac                	jmp    8020ed <__umoddi3+0x2d>
  802141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802148:	8b 44 24 04          	mov    0x4(%esp),%eax
  80214c:	ba 20 00 00 00       	mov    $0x20,%edx
  802151:	29 c2                	sub    %eax,%edx
  802153:	89 c1                	mov    %eax,%ecx
  802155:	89 e8                	mov    %ebp,%eax
  802157:	d3 e7                	shl    %cl,%edi
  802159:	89 d1                	mov    %edx,%ecx
  80215b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80215f:	d3 e8                	shr    %cl,%eax
  802161:	89 c1                	mov    %eax,%ecx
  802163:	8b 44 24 04          	mov    0x4(%esp),%eax
  802167:	09 f9                	or     %edi,%ecx
  802169:	89 df                	mov    %ebx,%edi
  80216b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80216f:	89 c1                	mov    %eax,%ecx
  802171:	d3 e5                	shl    %cl,%ebp
  802173:	89 d1                	mov    %edx,%ecx
  802175:	d3 ef                	shr    %cl,%edi
  802177:	89 c1                	mov    %eax,%ecx
  802179:	89 f0                	mov    %esi,%eax
  80217b:	d3 e3                	shl    %cl,%ebx
  80217d:	89 d1                	mov    %edx,%ecx
  80217f:	89 fa                	mov    %edi,%edx
  802181:	d3 e8                	shr    %cl,%eax
  802183:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802188:	09 d8                	or     %ebx,%eax
  80218a:	f7 74 24 08          	divl   0x8(%esp)
  80218e:	89 d3                	mov    %edx,%ebx
  802190:	d3 e6                	shl    %cl,%esi
  802192:	f7 e5                	mul    %ebp
  802194:	89 c7                	mov    %eax,%edi
  802196:	89 d1                	mov    %edx,%ecx
  802198:	39 d3                	cmp    %edx,%ebx
  80219a:	72 06                	jb     8021a2 <__umoddi3+0xe2>
  80219c:	75 0e                	jne    8021ac <__umoddi3+0xec>
  80219e:	39 c6                	cmp    %eax,%esi
  8021a0:	73 0a                	jae    8021ac <__umoddi3+0xec>
  8021a2:	29 e8                	sub    %ebp,%eax
  8021a4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8021a8:	89 d1                	mov    %edx,%ecx
  8021aa:	89 c7                	mov    %eax,%edi
  8021ac:	89 f5                	mov    %esi,%ebp
  8021ae:	8b 74 24 04          	mov    0x4(%esp),%esi
  8021b2:	29 fd                	sub    %edi,%ebp
  8021b4:	19 cb                	sbb    %ecx,%ebx
  8021b6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8021bb:	89 d8                	mov    %ebx,%eax
  8021bd:	d3 e0                	shl    %cl,%eax
  8021bf:	89 f1                	mov    %esi,%ecx
  8021c1:	d3 ed                	shr    %cl,%ebp
  8021c3:	d3 eb                	shr    %cl,%ebx
  8021c5:	09 e8                	or     %ebp,%eax
  8021c7:	89 da                	mov    %ebx,%edx
  8021c9:	83 c4 1c             	add    $0x1c,%esp
  8021cc:	5b                   	pop    %ebx
  8021cd:	5e                   	pop    %esi
  8021ce:	5f                   	pop    %edi
  8021cf:	5d                   	pop    %ebp
  8021d0:	c3                   	ret    
