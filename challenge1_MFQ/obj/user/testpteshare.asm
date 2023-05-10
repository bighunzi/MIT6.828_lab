
obj/user/testpteshare.debug：     文件格式 elf32-i386


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
  80002c:	e8 63 01 00 00       	call   800194 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	push   0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 63 08 00 00       	call   8008ac <strcpy>
	exit();
  800049:	e8 8f 01 00 00       	call   8001dd <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	0f 85 d0 00 00 00    	jne    800134 <umain+0xe1>
	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800064:	83 ec 04             	sub    $0x4,%esp
  800067:	68 07 04 00 00       	push   $0x407
  80006c:	68 00 00 00 a0       	push   $0xa0000000
  800071:	6a 00                	push   $0x0
  800073:	e8 30 0c 00 00       	call   800ca8 <sys_page_alloc>
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	85 c0                	test   %eax,%eax
  80007d:	0f 88 bb 00 00 00    	js     80013e <umain+0xeb>
	if ((r = fork()) < 0)
  800083:	e8 70 0f 00 00       	call   800ff8 <fork>
  800088:	89 c3                	mov    %eax,%ebx
  80008a:	85 c0                	test   %eax,%eax
  80008c:	0f 88 be 00 00 00    	js     800150 <umain+0xfd>
	if (r == 0) {
  800092:	0f 84 ca 00 00 00    	je     800162 <umain+0x10f>
	wait(r);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	53                   	push   %ebx
  80009c:	e8 89 26 00 00       	call   80272a <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	ff 35 04 40 80 00    	push   0x804004
  8000aa:	68 00 00 00 a0       	push   $0xa0000000
  8000af:	e8 a9 08 00 00       	call   80095d <strcmp>
  8000b4:	83 c4 08             	add    $0x8,%esp
  8000b7:	85 c0                	test   %eax,%eax
  8000b9:	b8 20 2d 80 00       	mov    $0x802d20,%eax
  8000be:	ba 26 2d 80 00       	mov    $0x802d26,%edx
  8000c3:	0f 45 c2             	cmovne %edx,%eax
  8000c6:	50                   	push   %eax
  8000c7:	68 53 2d 80 00       	push   $0x802d53
  8000cc:	e8 01 02 00 00       	call   8002d2 <cprintf>
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  8000d1:	6a 00                	push   $0x0
  8000d3:	68 6e 2d 80 00       	push   $0x802d6e
  8000d8:	68 73 2d 80 00       	push   $0x802d73
  8000dd:	68 72 2d 80 00       	push   $0x802d72
  8000e2:	e8 ec 1d 00 00       	call   801ed3 <spawnl>
  8000e7:	83 c4 20             	add    $0x20,%esp
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	0f 88 90 00 00 00    	js     800182 <umain+0x12f>
	wait(r);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	e8 2f 26 00 00       	call   80272a <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  8000fb:	83 c4 08             	add    $0x8,%esp
  8000fe:	ff 35 00 40 80 00    	push   0x804000
  800104:	68 00 00 00 a0       	push   $0xa0000000
  800109:	e8 4f 08 00 00       	call   80095d <strcmp>
  80010e:	83 c4 08             	add    $0x8,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	b8 20 2d 80 00       	mov    $0x802d20,%eax
  800118:	ba 26 2d 80 00       	mov    $0x802d26,%edx
  80011d:	0f 45 c2             	cmovne %edx,%eax
  800120:	50                   	push   %eax
  800121:	68 8a 2d 80 00       	push   $0x802d8a
  800126:	e8 a7 01 00 00       	call   8002d2 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80012b:	cc                   	int3   
}
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800132:	c9                   	leave  
  800133:	c3                   	ret    
		childofspawn();
  800134:	e8 fa fe ff ff       	call   800033 <childofspawn>
  800139:	e9 26 ff ff ff       	jmp    800064 <umain+0x11>
		panic("sys_page_alloc: %e", r);
  80013e:	50                   	push   %eax
  80013f:	68 2c 2d 80 00       	push   $0x802d2c
  800144:	6a 13                	push   $0x13
  800146:	68 3f 2d 80 00       	push   $0x802d3f
  80014b:	e8 a7 00 00 00       	call   8001f7 <_panic>
		panic("fork: %e", r);
  800150:	50                   	push   %eax
  800151:	68 d8 31 80 00       	push   $0x8031d8
  800156:	6a 17                	push   $0x17
  800158:	68 3f 2d 80 00       	push   $0x802d3f
  80015d:	e8 95 00 00 00       	call   8001f7 <_panic>
		strcpy(VA, msg);
  800162:	83 ec 08             	sub    $0x8,%esp
  800165:	ff 35 04 40 80 00    	push   0x804004
  80016b:	68 00 00 00 a0       	push   $0xa0000000
  800170:	e8 37 07 00 00       	call   8008ac <strcpy>
		exit();
  800175:	e8 63 00 00 00       	call   8001dd <exit>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	e9 16 ff ff ff       	jmp    800098 <umain+0x45>
		panic("spawn: %e", r);
  800182:	50                   	push   %eax
  800183:	68 80 2d 80 00       	push   $0x802d80
  800188:	6a 21                	push   $0x21
  80018a:	68 3f 2d 80 00       	push   $0x802d3f
  80018f:	e8 63 00 00 00       	call   8001f7 <_panic>

00800194 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
  800199:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80019c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80019f:	e8 c6 0a 00 00       	call   800c6a <sys_getenvid>
  8001a4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001a9:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8001af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b4:	a3 00 50 80 00       	mov    %eax,0x805000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001b9:	85 db                	test   %ebx,%ebx
  8001bb:	7e 07                	jle    8001c4 <libmain+0x30>
		binaryname = argv[0];
  8001bd:	8b 06                	mov    (%esi),%eax
  8001bf:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001c4:	83 ec 08             	sub    $0x8,%esp
  8001c7:	56                   	push   %esi
  8001c8:	53                   	push   %ebx
  8001c9:	e8 85 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001ce:	e8 0a 00 00 00       	call   8001dd <exit>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5e                   	pop    %esi
  8001db:	5d                   	pop    %ebp
  8001dc:	c3                   	ret    

008001dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e3:	e8 64 11 00 00       	call   80134c <close_all>
	sys_env_destroy(0);
  8001e8:	83 ec 0c             	sub    $0xc,%esp
  8001eb:	6a 00                	push   $0x0
  8001ed:	e8 37 0a 00 00       	call   800c29 <sys_env_destroy>
}
  8001f2:	83 c4 10             	add    $0x10,%esp
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	56                   	push   %esi
  8001fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ff:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800205:	e8 60 0a 00 00       	call   800c6a <sys_getenvid>
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	ff 75 0c             	push   0xc(%ebp)
  800210:	ff 75 08             	push   0x8(%ebp)
  800213:	56                   	push   %esi
  800214:	50                   	push   %eax
  800215:	68 d0 2d 80 00       	push   $0x802dd0
  80021a:	e8 b3 00 00 00       	call   8002d2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021f:	83 c4 18             	add    $0x18,%esp
  800222:	53                   	push   %ebx
  800223:	ff 75 10             	push   0x10(%ebp)
  800226:	e8 56 00 00 00       	call   800281 <vcprintf>
	cprintf("\n");
  80022b:	c7 04 24 bf 33 80 00 	movl   $0x8033bf,(%esp)
  800232:	e8 9b 00 00 00       	call   8002d2 <cprintf>
  800237:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80023a:	cc                   	int3   
  80023b:	eb fd                	jmp    80023a <_panic+0x43>

0080023d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	53                   	push   %ebx
  800241:	83 ec 04             	sub    $0x4,%esp
  800244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800247:	8b 13                	mov    (%ebx),%edx
  800249:	8d 42 01             	lea    0x1(%edx),%eax
  80024c:	89 03                	mov    %eax,(%ebx)
  80024e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800251:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800255:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025a:	74 09                	je     800265 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80025c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800260:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800263:	c9                   	leave  
  800264:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	68 ff 00 00 00       	push   $0xff
  80026d:	8d 43 08             	lea    0x8(%ebx),%eax
  800270:	50                   	push   %eax
  800271:	e8 76 09 00 00       	call   800bec <sys_cputs>
		b->idx = 0;
  800276:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	eb db                	jmp    80025c <putch+0x1f>

00800281 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80028a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800291:	00 00 00 
	b.cnt = 0;
  800294:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80029e:	ff 75 0c             	push   0xc(%ebp)
  8002a1:	ff 75 08             	push   0x8(%ebp)
  8002a4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002aa:	50                   	push   %eax
  8002ab:	68 3d 02 80 00       	push   $0x80023d
  8002b0:	e8 14 01 00 00       	call   8003c9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b5:	83 c4 08             	add    $0x8,%esp
  8002b8:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c4:	50                   	push   %eax
  8002c5:	e8 22 09 00 00       	call   800bec <sys_cputs>

	return b.cnt;
}
  8002ca:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002db:	50                   	push   %eax
  8002dc:	ff 75 08             	push   0x8(%ebp)
  8002df:	e8 9d ff ff ff       	call   800281 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	57                   	push   %edi
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 1c             	sub    $0x1c,%esp
  8002ef:	89 c7                	mov    %eax,%edi
  8002f1:	89 d6                	mov    %edx,%esi
  8002f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f9:	89 d1                	mov    %edx,%ecx
  8002fb:	89 c2                	mov    %eax,%edx
  8002fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800300:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800303:	8b 45 10             	mov    0x10(%ebp),%eax
  800306:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800309:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800313:	39 c2                	cmp    %eax,%edx
  800315:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800318:	72 3e                	jb     800358 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	ff 75 18             	push   0x18(%ebp)
  800320:	83 eb 01             	sub    $0x1,%ebx
  800323:	53                   	push   %ebx
  800324:	50                   	push   %eax
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	ff 75 e4             	push   -0x1c(%ebp)
  80032b:	ff 75 e0             	push   -0x20(%ebp)
  80032e:	ff 75 dc             	push   -0x24(%ebp)
  800331:	ff 75 d8             	push   -0x28(%ebp)
  800334:	e8 97 27 00 00       	call   802ad0 <__udivdi3>
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	52                   	push   %edx
  80033d:	50                   	push   %eax
  80033e:	89 f2                	mov    %esi,%edx
  800340:	89 f8                	mov    %edi,%eax
  800342:	e8 9f ff ff ff       	call   8002e6 <printnum>
  800347:	83 c4 20             	add    $0x20,%esp
  80034a:	eb 13                	jmp    80035f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	56                   	push   %esi
  800350:	ff 75 18             	push   0x18(%ebp)
  800353:	ff d7                	call   *%edi
  800355:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800358:	83 eb 01             	sub    $0x1,%ebx
  80035b:	85 db                	test   %ebx,%ebx
  80035d:	7f ed                	jg     80034c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	56                   	push   %esi
  800363:	83 ec 04             	sub    $0x4,%esp
  800366:	ff 75 e4             	push   -0x1c(%ebp)
  800369:	ff 75 e0             	push   -0x20(%ebp)
  80036c:	ff 75 dc             	push   -0x24(%ebp)
  80036f:	ff 75 d8             	push   -0x28(%ebp)
  800372:	e8 79 28 00 00       	call   802bf0 <__umoddi3>
  800377:	83 c4 14             	add    $0x14,%esp
  80037a:	0f be 80 f3 2d 80 00 	movsbl 0x802df3(%eax),%eax
  800381:	50                   	push   %eax
  800382:	ff d7                	call   *%edi
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800395:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	3b 50 04             	cmp    0x4(%eax),%edx
  80039e:	73 0a                	jae    8003aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	88 02                	mov    %al,(%edx)
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <printfmt>:
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b5:	50                   	push   %eax
  8003b6:	ff 75 10             	push   0x10(%ebp)
  8003b9:	ff 75 0c             	push   0xc(%ebp)
  8003bc:	ff 75 08             	push   0x8(%ebp)
  8003bf:	e8 05 00 00 00       	call   8003c9 <vprintfmt>
}
  8003c4:	83 c4 10             	add    $0x10,%esp
  8003c7:	c9                   	leave  
  8003c8:	c3                   	ret    

008003c9 <vprintfmt>:
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	57                   	push   %edi
  8003cd:	56                   	push   %esi
  8003ce:	53                   	push   %ebx
  8003cf:	83 ec 3c             	sub    $0x3c,%esp
  8003d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003db:	eb 0a                	jmp    8003e7 <vprintfmt+0x1e>
			putch(ch, putdat);
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	53                   	push   %ebx
  8003e1:	50                   	push   %eax
  8003e2:	ff d6                	call   *%esi
  8003e4:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e7:	83 c7 01             	add    $0x1,%edi
  8003ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003ee:	83 f8 25             	cmp    $0x25,%eax
  8003f1:	74 0c                	je     8003ff <vprintfmt+0x36>
			if (ch == '\0')
  8003f3:	85 c0                	test   %eax,%eax
  8003f5:	75 e6                	jne    8003dd <vprintfmt+0x14>
}
  8003f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003fa:	5b                   	pop    %ebx
  8003fb:	5e                   	pop    %esi
  8003fc:	5f                   	pop    %edi
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    
		padc = ' ';
  8003ff:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800403:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80040a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800411:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800418:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8d 47 01             	lea    0x1(%edi),%eax
  800420:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800423:	0f b6 17             	movzbl (%edi),%edx
  800426:	8d 42 dd             	lea    -0x23(%edx),%eax
  800429:	3c 55                	cmp    $0x55,%al
  80042b:	0f 87 bb 03 00 00    	ja     8007ec <vprintfmt+0x423>
  800431:	0f b6 c0             	movzbl %al,%eax
  800434:	ff 24 85 40 2f 80 00 	jmp    *0x802f40(,%eax,4)
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80043e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800442:	eb d9                	jmp    80041d <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800447:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80044b:	eb d0                	jmp    80041d <vprintfmt+0x54>
  80044d:	0f b6 d2             	movzbl %dl,%edx
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80045b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80045e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800462:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800465:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800468:	83 f9 09             	cmp    $0x9,%ecx
  80046b:	77 55                	ja     8004c2 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80046d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800470:	eb e9                	jmp    80045b <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8b 00                	mov    (%eax),%eax
  800477:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8d 40 04             	lea    0x4(%eax),%eax
  800480:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800486:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048a:	79 91                	jns    80041d <vprintfmt+0x54>
				width = precision, precision = -1;
  80048c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80048f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800492:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800499:	eb 82                	jmp    80041d <vprintfmt+0x54>
  80049b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80049e:	85 d2                	test   %edx,%edx
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	0f 49 c2             	cmovns %edx,%eax
  8004a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ae:	e9 6a ff ff ff       	jmp    80041d <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004b6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004bd:	e9 5b ff ff ff       	jmp    80041d <vprintfmt+0x54>
  8004c2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c8:	eb bc                	jmp    800486 <vprintfmt+0xbd>
			lflag++;
  8004ca:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004d0:	e9 48 ff ff ff       	jmp    80041d <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8004d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d8:	8d 78 04             	lea    0x4(%eax),%edi
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	53                   	push   %ebx
  8004df:	ff 30                	push   (%eax)
  8004e1:	ff d6                	call   *%esi
			break;
  8004e3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004e6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004e9:	e9 9d 02 00 00       	jmp    80078b <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 78 04             	lea    0x4(%eax),%edi
  8004f4:	8b 10                	mov    (%eax),%edx
  8004f6:	89 d0                	mov    %edx,%eax
  8004f8:	f7 d8                	neg    %eax
  8004fa:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fd:	83 f8 0f             	cmp    $0xf,%eax
  800500:	7f 23                	jg     800525 <vprintfmt+0x15c>
  800502:	8b 14 85 a0 30 80 00 	mov    0x8030a0(,%eax,4),%edx
  800509:	85 d2                	test   %edx,%edx
  80050b:	74 18                	je     800525 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80050d:	52                   	push   %edx
  80050e:	68 a1 32 80 00       	push   $0x8032a1
  800513:	53                   	push   %ebx
  800514:	56                   	push   %esi
  800515:	e8 92 fe ff ff       	call   8003ac <printfmt>
  80051a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800520:	e9 66 02 00 00       	jmp    80078b <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800525:	50                   	push   %eax
  800526:	68 0b 2e 80 00       	push   $0x802e0b
  80052b:	53                   	push   %ebx
  80052c:	56                   	push   %esi
  80052d:	e8 7a fe ff ff       	call   8003ac <printfmt>
  800532:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800535:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800538:	e9 4e 02 00 00       	jmp    80078b <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	83 c0 04             	add    $0x4,%eax
  800543:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80054b:	85 d2                	test   %edx,%edx
  80054d:	b8 04 2e 80 00       	mov    $0x802e04,%eax
  800552:	0f 45 c2             	cmovne %edx,%eax
  800555:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800558:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80055c:	7e 06                	jle    800564 <vprintfmt+0x19b>
  80055e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800562:	75 0d                	jne    800571 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800564:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800567:	89 c7                	mov    %eax,%edi
  800569:	03 45 e0             	add    -0x20(%ebp),%eax
  80056c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056f:	eb 55                	jmp    8005c6 <vprintfmt+0x1fd>
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	ff 75 d8             	push   -0x28(%ebp)
  800577:	ff 75 cc             	push   -0x34(%ebp)
  80057a:	e8 0a 03 00 00       	call   800889 <strnlen>
  80057f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800582:	29 c1                	sub    %eax,%ecx
  800584:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80058c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800590:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	eb 0f                	jmp    8005a4 <vprintfmt+0x1db>
					putch(padc, putdat);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	53                   	push   %ebx
  800599:	ff 75 e0             	push   -0x20(%ebp)
  80059c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80059e:	83 ef 01             	sub    $0x1,%edi
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	85 ff                	test   %edi,%edi
  8005a6:	7f ed                	jg     800595 <vprintfmt+0x1cc>
  8005a8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ab:	85 d2                	test   %edx,%edx
  8005ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b2:	0f 49 c2             	cmovns %edx,%eax
  8005b5:	29 c2                	sub    %eax,%edx
  8005b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ba:	eb a8                	jmp    800564 <vprintfmt+0x19b>
					putch(ch, putdat);
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	53                   	push   %ebx
  8005c0:	52                   	push   %edx
  8005c1:	ff d6                	call   *%esi
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c9:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cb:	83 c7 01             	add    $0x1,%edi
  8005ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d2:	0f be d0             	movsbl %al,%edx
  8005d5:	85 d2                	test   %edx,%edx
  8005d7:	74 4b                	je     800624 <vprintfmt+0x25b>
  8005d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005dd:	78 06                	js     8005e5 <vprintfmt+0x21c>
  8005df:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005e3:	78 1e                	js     800603 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005e9:	74 d1                	je     8005bc <vprintfmt+0x1f3>
  8005eb:	0f be c0             	movsbl %al,%eax
  8005ee:	83 e8 20             	sub    $0x20,%eax
  8005f1:	83 f8 5e             	cmp    $0x5e,%eax
  8005f4:	76 c6                	jbe    8005bc <vprintfmt+0x1f3>
					putch('?', putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	53                   	push   %ebx
  8005fa:	6a 3f                	push   $0x3f
  8005fc:	ff d6                	call   *%esi
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	eb c3                	jmp    8005c6 <vprintfmt+0x1fd>
  800603:	89 cf                	mov    %ecx,%edi
  800605:	eb 0e                	jmp    800615 <vprintfmt+0x24c>
				putch(' ', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 20                	push   $0x20
  80060d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ee                	jg     800607 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800619:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
  80061f:	e9 67 01 00 00       	jmp    80078b <vprintfmt+0x3c2>
  800624:	89 cf                	mov    %ecx,%edi
  800626:	eb ed                	jmp    800615 <vprintfmt+0x24c>
	if (lflag >= 2)
  800628:	83 f9 01             	cmp    $0x1,%ecx
  80062b:	7f 1b                	jg     800648 <vprintfmt+0x27f>
	else if (lflag)
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	74 63                	je     800694 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	99                   	cltd   
  80063a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
  800646:	eb 17                	jmp    80065f <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 50 04             	mov    0x4(%eax),%edx
  80064e:	8b 00                	mov    (%eax),%eax
  800650:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800653:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 40 08             	lea    0x8(%eax),%eax
  80065c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80065f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800662:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800665:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80066a:	85 c9                	test   %ecx,%ecx
  80066c:	0f 89 ff 00 00 00    	jns    800771 <vprintfmt+0x3a8>
				putch('-', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 2d                	push   $0x2d
  800678:	ff d6                	call   *%esi
				num = -(long long) num;
  80067a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800680:	f7 da                	neg    %edx
  800682:	83 d1 00             	adc    $0x0,%ecx
  800685:	f7 d9                	neg    %ecx
  800687:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80068a:	bf 0a 00 00 00       	mov    $0xa,%edi
  80068f:	e9 dd 00 00 00       	jmp    800771 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 00                	mov    (%eax),%eax
  800699:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069c:	99                   	cltd   
  80069d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 40 04             	lea    0x4(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a9:	eb b4                	jmp    80065f <vprintfmt+0x296>
	if (lflag >= 2)
  8006ab:	83 f9 01             	cmp    $0x1,%ecx
  8006ae:	7f 1e                	jg     8006ce <vprintfmt+0x305>
	else if (lflag)
  8006b0:	85 c9                	test   %ecx,%ecx
  8006b2:	74 32                	je     8006e6 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006be:	8d 40 04             	lea    0x4(%eax),%eax
  8006c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c4:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8006c9:	e9 a3 00 00 00       	jmp    800771 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d6:	8d 40 08             	lea    0x8(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006dc:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8006e1:	e9 8b 00 00 00       	jmp    800771 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f0:	8d 40 04             	lea    0x4(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8006fb:	eb 74                	jmp    800771 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8006fd:	83 f9 01             	cmp    $0x1,%ecx
  800700:	7f 1b                	jg     80071d <vprintfmt+0x354>
	else if (lflag)
  800702:	85 c9                	test   %ecx,%ecx
  800704:	74 2c                	je     800732 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800710:	8d 40 04             	lea    0x4(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800716:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80071b:	eb 54                	jmp    800771 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	8b 48 04             	mov    0x4(%eax),%ecx
  800725:	8d 40 08             	lea    0x8(%eax),%eax
  800728:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80072b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800730:	eb 3f                	jmp    800771 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	8d 40 04             	lea    0x4(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800742:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800747:	eb 28                	jmp    800771 <vprintfmt+0x3a8>
			putch('0', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 30                	push   $0x30
  80074f:	ff d6                	call   *%esi
			putch('x', putdat);
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 78                	push   $0x78
  800757:	ff d6                	call   *%esi
			num = (unsigned long long)
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8b 10                	mov    (%eax),%edx
  80075e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800763:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800766:	8d 40 04             	lea    0x4(%eax),%eax
  800769:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076c:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800771:	83 ec 0c             	sub    $0xc,%esp
  800774:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800778:	50                   	push   %eax
  800779:	ff 75 e0             	push   -0x20(%ebp)
  80077c:	57                   	push   %edi
  80077d:	51                   	push   %ecx
  80077e:	52                   	push   %edx
  80077f:	89 da                	mov    %ebx,%edx
  800781:	89 f0                	mov    %esi,%eax
  800783:	e8 5e fb ff ff       	call   8002e6 <printnum>
			break;
  800788:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80078b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078e:	e9 54 fc ff ff       	jmp    8003e7 <vprintfmt+0x1e>
	if (lflag >= 2)
  800793:	83 f9 01             	cmp    $0x1,%ecx
  800796:	7f 1b                	jg     8007b3 <vprintfmt+0x3ea>
	else if (lflag)
  800798:	85 c9                	test   %ecx,%ecx
  80079a:	74 2c                	je     8007c8 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8b 10                	mov    (%eax),%edx
  8007a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a6:	8d 40 04             	lea    0x4(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ac:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8007b1:	eb be                	jmp    800771 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8b 10                	mov    (%eax),%edx
  8007b8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007bb:	8d 40 08             	lea    0x8(%eax),%eax
  8007be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c1:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8007c6:	eb a9                	jmp    800771 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8b 10                	mov    (%eax),%edx
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8007dd:	eb 92                	jmp    800771 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	6a 25                	push   $0x25
  8007e5:	ff d6                	call   *%esi
			break;
  8007e7:	83 c4 10             	add    $0x10,%esp
  8007ea:	eb 9f                	jmp    80078b <vprintfmt+0x3c2>
			putch('%', putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	53                   	push   %ebx
  8007f0:	6a 25                	push   $0x25
  8007f2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	89 f8                	mov    %edi,%eax
  8007f9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007fd:	74 05                	je     800804 <vprintfmt+0x43b>
  8007ff:	83 e8 01             	sub    $0x1,%eax
  800802:	eb f5                	jmp    8007f9 <vprintfmt+0x430>
  800804:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800807:	eb 82                	jmp    80078b <vprintfmt+0x3c2>

00800809 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	83 ec 18             	sub    $0x18,%esp
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800815:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800818:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800826:	85 c0                	test   %eax,%eax
  800828:	74 26                	je     800850 <vsnprintf+0x47>
  80082a:	85 d2                	test   %edx,%edx
  80082c:	7e 22                	jle    800850 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082e:	ff 75 14             	push   0x14(%ebp)
  800831:	ff 75 10             	push   0x10(%ebp)
  800834:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800837:	50                   	push   %eax
  800838:	68 8f 03 80 00       	push   $0x80038f
  80083d:	e8 87 fb ff ff       	call   8003c9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800842:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800845:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800848:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084b:	83 c4 10             	add    $0x10,%esp
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    
		return -E_INVAL;
  800850:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800855:	eb f7                	jmp    80084e <vsnprintf+0x45>

00800857 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800860:	50                   	push   %eax
  800861:	ff 75 10             	push   0x10(%ebp)
  800864:	ff 75 0c             	push   0xc(%ebp)
  800867:	ff 75 08             	push   0x8(%ebp)
  80086a:	e8 9a ff ff ff       	call   800809 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
  80087c:	eb 03                	jmp    800881 <strlen+0x10>
		n++;
  80087e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800881:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800885:	75 f7                	jne    80087e <strlen+0xd>
	return n;
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
  800897:	eb 03                	jmp    80089c <strnlen+0x13>
		n++;
  800899:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	39 d0                	cmp    %edx,%eax
  80089e:	74 08                	je     8008a8 <strnlen+0x1f>
  8008a0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a4:	75 f3                	jne    800899 <strnlen+0x10>
  8008a6:	89 c2                	mov    %eax,%edx
	return n;
}
  8008a8:	89 d0                	mov    %edx,%eax
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008bf:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008c2:	83 c0 01             	add    $0x1,%eax
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	75 f2                	jne    8008bb <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c9:	89 c8                	mov    %ecx,%eax
  8008cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	83 ec 10             	sub    $0x10,%esp
  8008d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008da:	53                   	push   %ebx
  8008db:	e8 91 ff ff ff       	call   800871 <strlen>
  8008e0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008e3:	ff 75 0c             	push   0xc(%ebp)
  8008e6:	01 d8                	add    %ebx,%eax
  8008e8:	50                   	push   %eax
  8008e9:	e8 be ff ff ff       	call   8008ac <strcpy>
	return dst;
}
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800900:	89 f3                	mov    %esi,%ebx
  800902:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	89 f0                	mov    %esi,%eax
  800907:	eb 0f                	jmp    800918 <strncpy+0x23>
		*dst++ = *src;
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	0f b6 0a             	movzbl (%edx),%ecx
  80090f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800912:	80 f9 01             	cmp    $0x1,%cl
  800915:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800918:	39 d8                	cmp    %ebx,%eax
  80091a:	75 ed                	jne    800909 <strncpy+0x14>
	}
	return ret;
}
  80091c:	89 f0                	mov    %esi,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 75 08             	mov    0x8(%ebp),%esi
  80092a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092d:	8b 55 10             	mov    0x10(%ebp),%edx
  800930:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800932:	85 d2                	test   %edx,%edx
  800934:	74 21                	je     800957 <strlcpy+0x35>
  800936:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80093a:	89 f2                	mov    %esi,%edx
  80093c:	eb 09                	jmp    800947 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093e:	83 c1 01             	add    $0x1,%ecx
  800941:	83 c2 01             	add    $0x1,%edx
  800944:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800947:	39 c2                	cmp    %eax,%edx
  800949:	74 09                	je     800954 <strlcpy+0x32>
  80094b:	0f b6 19             	movzbl (%ecx),%ebx
  80094e:	84 db                	test   %bl,%bl
  800950:	75 ec                	jne    80093e <strlcpy+0x1c>
  800952:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800954:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800957:	29 f0                	sub    %esi,%eax
}
  800959:	5b                   	pop    %ebx
  80095a:	5e                   	pop    %esi
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800963:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800966:	eb 06                	jmp    80096e <strcmp+0x11>
		p++, q++;
  800968:	83 c1 01             	add    $0x1,%ecx
  80096b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80096e:	0f b6 01             	movzbl (%ecx),%eax
  800971:	84 c0                	test   %al,%al
  800973:	74 04                	je     800979 <strcmp+0x1c>
  800975:	3a 02                	cmp    (%edx),%al
  800977:	74 ef                	je     800968 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800979:	0f b6 c0             	movzbl %al,%eax
  80097c:	0f b6 12             	movzbl (%edx),%edx
  80097f:	29 d0                	sub    %edx,%eax
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	89 c3                	mov    %eax,%ebx
  80098f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800992:	eb 06                	jmp    80099a <strncmp+0x17>
		n--, p++, q++;
  800994:	83 c0 01             	add    $0x1,%eax
  800997:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80099a:	39 d8                	cmp    %ebx,%eax
  80099c:	74 18                	je     8009b6 <strncmp+0x33>
  80099e:	0f b6 08             	movzbl (%eax),%ecx
  8009a1:	84 c9                	test   %cl,%cl
  8009a3:	74 04                	je     8009a9 <strncmp+0x26>
  8009a5:	3a 0a                	cmp    (%edx),%cl
  8009a7:	74 eb                	je     800994 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a9:	0f b6 00             	movzbl (%eax),%eax
  8009ac:	0f b6 12             	movzbl (%edx),%edx
  8009af:	29 d0                	sub    %edx,%eax
}
  8009b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    
		return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bb:	eb f4                	jmp    8009b1 <strncmp+0x2e>

008009bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 03                	jmp    8009cc <strchr+0xf>
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	0f b6 10             	movzbl (%eax),%edx
  8009cf:	84 d2                	test   %dl,%dl
  8009d1:	74 06                	je     8009d9 <strchr+0x1c>
		if (*s == c)
  8009d3:	38 ca                	cmp    %cl,%dl
  8009d5:	75 f2                	jne    8009c9 <strchr+0xc>
  8009d7:	eb 05                	jmp    8009de <strchr+0x21>
			return (char *) s;
	return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ea:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ed:	38 ca                	cmp    %cl,%dl
  8009ef:	74 09                	je     8009fa <strfind+0x1a>
  8009f1:	84 d2                	test   %dl,%dl
  8009f3:	74 05                	je     8009fa <strfind+0x1a>
	for (; *s; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	eb f0                	jmp    8009ea <strfind+0xa>
			break;
	return (char *) s;
}
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a08:	85 c9                	test   %ecx,%ecx
  800a0a:	74 2f                	je     800a3b <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0c:	89 f8                	mov    %edi,%eax
  800a0e:	09 c8                	or     %ecx,%eax
  800a10:	a8 03                	test   $0x3,%al
  800a12:	75 21                	jne    800a35 <memset+0x39>
		c &= 0xFF;
  800a14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a18:	89 d0                	mov    %edx,%eax
  800a1a:	c1 e0 08             	shl    $0x8,%eax
  800a1d:	89 d3                	mov    %edx,%ebx
  800a1f:	c1 e3 18             	shl    $0x18,%ebx
  800a22:	89 d6                	mov    %edx,%esi
  800a24:	c1 e6 10             	shl    $0x10,%esi
  800a27:	09 f3                	or     %esi,%ebx
  800a29:	09 da                	or     %ebx,%edx
  800a2b:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a2d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a30:	fc                   	cld    
  800a31:	f3 ab                	rep stos %eax,%es:(%edi)
  800a33:	eb 06                	jmp    800a3b <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a38:	fc                   	cld    
  800a39:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3b:	89 f8                	mov    %edi,%eax
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5f                   	pop    %edi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a50:	39 c6                	cmp    %eax,%esi
  800a52:	73 32                	jae    800a86 <memmove+0x44>
  800a54:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a57:	39 c2                	cmp    %eax,%edx
  800a59:	76 2b                	jbe    800a86 <memmove+0x44>
		s += n;
		d += n;
  800a5b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5e:	89 d6                	mov    %edx,%esi
  800a60:	09 fe                	or     %edi,%esi
  800a62:	09 ce                	or     %ecx,%esi
  800a64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6a:	75 0e                	jne    800a7a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a6c:	83 ef 04             	sub    $0x4,%edi
  800a6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a72:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a75:	fd                   	std    
  800a76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a78:	eb 09                	jmp    800a83 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7a:	83 ef 01             	sub    $0x1,%edi
  800a7d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a80:	fd                   	std    
  800a81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a83:	fc                   	cld    
  800a84:	eb 1a                	jmp    800aa0 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a86:	89 f2                	mov    %esi,%edx
  800a88:	09 c2                	or     %eax,%edx
  800a8a:	09 ca                	or     %ecx,%edx
  800a8c:	f6 c2 03             	test   $0x3,%dl
  800a8f:	75 0a                	jne    800a9b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a91:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a94:	89 c7                	mov    %eax,%edi
  800a96:	fc                   	cld    
  800a97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a99:	eb 05                	jmp    800aa0 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	fc                   	cld    
  800a9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aaa:	ff 75 10             	push   0x10(%ebp)
  800aad:	ff 75 0c             	push   0xc(%ebp)
  800ab0:	ff 75 08             	push   0x8(%ebp)
  800ab3:	e8 8a ff ff ff       	call   800a42 <memmove>
}
  800ab8:	c9                   	leave  
  800ab9:	c3                   	ret    

00800aba <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac5:	89 c6                	mov    %eax,%esi
  800ac7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aca:	eb 06                	jmp    800ad2 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800acc:	83 c0 01             	add    $0x1,%eax
  800acf:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ad2:	39 f0                	cmp    %esi,%eax
  800ad4:	74 14                	je     800aea <memcmp+0x30>
		if (*s1 != *s2)
  800ad6:	0f b6 08             	movzbl (%eax),%ecx
  800ad9:	0f b6 1a             	movzbl (%edx),%ebx
  800adc:	38 d9                	cmp    %bl,%cl
  800ade:	74 ec                	je     800acc <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ae0:	0f b6 c1             	movzbl %cl,%eax
  800ae3:	0f b6 db             	movzbl %bl,%ebx
  800ae6:	29 d8                	sub    %ebx,%eax
  800ae8:	eb 05                	jmp    800aef <memcmp+0x35>
	}

	return 0;
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800afc:	89 c2                	mov    %eax,%edx
  800afe:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b01:	eb 03                	jmp    800b06 <memfind+0x13>
  800b03:	83 c0 01             	add    $0x1,%eax
  800b06:	39 d0                	cmp    %edx,%eax
  800b08:	73 04                	jae    800b0e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0a:	38 08                	cmp    %cl,(%eax)
  800b0c:	75 f5                	jne    800b03 <memfind+0x10>
			break;
	return (void *) s;
}
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
  800b16:	8b 55 08             	mov    0x8(%ebp),%edx
  800b19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1c:	eb 03                	jmp    800b21 <strtol+0x11>
		s++;
  800b1e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b21:	0f b6 02             	movzbl (%edx),%eax
  800b24:	3c 20                	cmp    $0x20,%al
  800b26:	74 f6                	je     800b1e <strtol+0xe>
  800b28:	3c 09                	cmp    $0x9,%al
  800b2a:	74 f2                	je     800b1e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b2c:	3c 2b                	cmp    $0x2b,%al
  800b2e:	74 2a                	je     800b5a <strtol+0x4a>
	int neg = 0;
  800b30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b35:	3c 2d                	cmp    $0x2d,%al
  800b37:	74 2b                	je     800b64 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b39:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3f:	75 0f                	jne    800b50 <strtol+0x40>
  800b41:	80 3a 30             	cmpb   $0x30,(%edx)
  800b44:	74 28                	je     800b6e <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b46:	85 db                	test   %ebx,%ebx
  800b48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4d:	0f 44 d8             	cmove  %eax,%ebx
  800b50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b55:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b58:	eb 46                	jmp    800ba0 <strtol+0x90>
		s++;
  800b5a:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b5d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b62:	eb d5                	jmp    800b39 <strtol+0x29>
		s++, neg = 1;
  800b64:	83 c2 01             	add    $0x1,%edx
  800b67:	bf 01 00 00 00       	mov    $0x1,%edi
  800b6c:	eb cb                	jmp    800b39 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b72:	74 0e                	je     800b82 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b74:	85 db                	test   %ebx,%ebx
  800b76:	75 d8                	jne    800b50 <strtol+0x40>
		s++, base = 8;
  800b78:	83 c2 01             	add    $0x1,%edx
  800b7b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b80:	eb ce                	jmp    800b50 <strtol+0x40>
		s += 2, base = 16;
  800b82:	83 c2 02             	add    $0x2,%edx
  800b85:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b8a:	eb c4                	jmp    800b50 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b8c:	0f be c0             	movsbl %al,%eax
  800b8f:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b92:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b95:	7d 3a                	jge    800bd1 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b9e:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ba0:	0f b6 02             	movzbl (%edx),%eax
  800ba3:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ba6:	89 f3                	mov    %esi,%ebx
  800ba8:	80 fb 09             	cmp    $0x9,%bl
  800bab:	76 df                	jbe    800b8c <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bad:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bb0:	89 f3                	mov    %esi,%ebx
  800bb2:	80 fb 19             	cmp    $0x19,%bl
  800bb5:	77 08                	ja     800bbf <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bb7:	0f be c0             	movsbl %al,%eax
  800bba:	83 e8 57             	sub    $0x57,%eax
  800bbd:	eb d3                	jmp    800b92 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bbf:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bc2:	89 f3                	mov    %esi,%ebx
  800bc4:	80 fb 19             	cmp    $0x19,%bl
  800bc7:	77 08                	ja     800bd1 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bc9:	0f be c0             	movsbl %al,%eax
  800bcc:	83 e8 37             	sub    $0x37,%eax
  800bcf:	eb c1                	jmp    800b92 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd5:	74 05                	je     800bdc <strtol+0xcc>
		*endptr = (char *) s;
  800bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bda:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bdc:	89 c8                	mov    %ecx,%eax
  800bde:	f7 d8                	neg    %eax
  800be0:	85 ff                	test   %edi,%edi
  800be2:	0f 45 c8             	cmovne %eax,%ecx
}
  800be5:	89 c8                	mov    %ecx,%eax
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	89 c3                	mov    %eax,%ebx
  800bff:	89 c7                	mov    %eax,%edi
  800c01:	89 c6                	mov    %eax,%esi
  800c03:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c10:	ba 00 00 00 00       	mov    $0x0,%edx
  800c15:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1a:	89 d1                	mov    %edx,%ecx
  800c1c:	89 d3                	mov    %edx,%ebx
  800c1e:	89 d7                	mov    %edx,%edi
  800c20:	89 d6                	mov    %edx,%esi
  800c22:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c3f:	89 cb                	mov    %ecx,%ebx
  800c41:	89 cf                	mov    %ecx,%edi
  800c43:	89 ce                	mov    %ecx,%esi
  800c45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7f 08                	jg     800c53 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 03                	push   $0x3
  800c59:	68 ff 30 80 00       	push   $0x8030ff
  800c5e:	6a 2a                	push   $0x2a
  800c60:	68 1c 31 80 00       	push   $0x80311c
  800c65:	e8 8d f5 ff ff       	call   8001f7 <_panic>

00800c6a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c70:	ba 00 00 00 00       	mov    $0x0,%edx
  800c75:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7a:	89 d1                	mov    %edx,%ecx
  800c7c:	89 d3                	mov    %edx,%ebx
  800c7e:	89 d7                	mov    %edx,%edi
  800c80:	89 d6                	mov    %edx,%esi
  800c82:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_yield>:

void
sys_yield(void)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c94:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c99:	89 d1                	mov    %edx,%ecx
  800c9b:	89 d3                	mov    %edx,%ebx
  800c9d:	89 d7                	mov    %edx,%edi
  800c9f:	89 d6                	mov    %edx,%esi
  800ca1:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb1:	be 00 00 00 00       	mov    $0x0,%esi
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc4:	89 f7                	mov    %esi,%edi
  800cc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	7f 08                	jg     800cd4 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd4:	83 ec 0c             	sub    $0xc,%esp
  800cd7:	50                   	push   %eax
  800cd8:	6a 04                	push   $0x4
  800cda:	68 ff 30 80 00       	push   $0x8030ff
  800cdf:	6a 2a                	push   $0x2a
  800ce1:	68 1c 31 80 00       	push   $0x80311c
  800ce6:	e8 0c f5 ff ff       	call   8001f7 <_panic>

00800ceb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800cff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d05:	8b 75 18             	mov    0x18(%ebp),%esi
  800d08:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7f 08                	jg     800d16 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d16:	83 ec 0c             	sub    $0xc,%esp
  800d19:	50                   	push   %eax
  800d1a:	6a 05                	push   $0x5
  800d1c:	68 ff 30 80 00       	push   $0x8030ff
  800d21:	6a 2a                	push   $0x2a
  800d23:	68 1c 31 80 00       	push   $0x80311c
  800d28:	e8 ca f4 ff ff       	call   8001f7 <_panic>

00800d2d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	b8 06 00 00 00       	mov    $0x6,%eax
  800d46:	89 df                	mov    %ebx,%edi
  800d48:	89 de                	mov    %ebx,%esi
  800d4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7f 08                	jg     800d58 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	50                   	push   %eax
  800d5c:	6a 06                	push   $0x6
  800d5e:	68 ff 30 80 00       	push   $0x8030ff
  800d63:	6a 2a                	push   $0x2a
  800d65:	68 1c 31 80 00       	push   $0x80311c
  800d6a:	e8 88 f4 ff ff       	call   8001f7 <_panic>

00800d6f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	b8 08 00 00 00       	mov    $0x8,%eax
  800d88:	89 df                	mov    %ebx,%edi
  800d8a:	89 de                	mov    %ebx,%esi
  800d8c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	7f 08                	jg     800d9a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9a:	83 ec 0c             	sub    $0xc,%esp
  800d9d:	50                   	push   %eax
  800d9e:	6a 08                	push   $0x8
  800da0:	68 ff 30 80 00       	push   $0x8030ff
  800da5:	6a 2a                	push   $0x2a
  800da7:	68 1c 31 80 00       	push   $0x80311c
  800dac:	e8 46 f4 ff ff       	call   8001f7 <_panic>

00800db1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800dca:	89 df                	mov    %ebx,%edi
  800dcc:	89 de                	mov    %ebx,%esi
  800dce:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7f 08                	jg     800ddc <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	50                   	push   %eax
  800de0:	6a 09                	push   $0x9
  800de2:	68 ff 30 80 00       	push   $0x8030ff
  800de7:	6a 2a                	push   $0x2a
  800de9:	68 1c 31 80 00       	push   $0x80311c
  800dee:	e8 04 f4 ff ff       	call   8001f7 <_panic>

00800df3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0c:	89 df                	mov    %ebx,%edi
  800e0e:	89 de                	mov    %ebx,%esi
  800e10:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7f 08                	jg     800e1e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1e:	83 ec 0c             	sub    $0xc,%esp
  800e21:	50                   	push   %eax
  800e22:	6a 0a                	push   $0xa
  800e24:	68 ff 30 80 00       	push   $0x8030ff
  800e29:	6a 2a                	push   $0x2a
  800e2b:	68 1c 31 80 00       	push   $0x80311c
  800e30:	e8 c2 f3 ff ff       	call   8001f7 <_panic>

00800e35 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e41:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e46:	be 00 00 00 00       	mov    $0x0,%esi
  800e4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e51:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e6e:	89 cb                	mov    %ecx,%ebx
  800e70:	89 cf                	mov    %ecx,%edi
  800e72:	89 ce                	mov    %ecx,%esi
  800e74:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e76:	85 c0                	test   %eax,%eax
  800e78:	7f 08                	jg     800e82 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e82:	83 ec 0c             	sub    $0xc,%esp
  800e85:	50                   	push   %eax
  800e86:	6a 0d                	push   $0xd
  800e88:	68 ff 30 80 00       	push   $0x8030ff
  800e8d:	6a 2a                	push   $0x2a
  800e8f:	68 1c 31 80 00       	push   $0x80311c
  800e94:	e8 5e f3 ff ff       	call   8001f7 <_panic>

00800e99 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea9:	89 d1                	mov    %edx,%ecx
  800eab:	89 d3                	mov    %edx,%ebx
  800ead:	89 d7                	mov    %edx,%edi
  800eaf:	89 d6                	mov    %edx,%esi
  800eb1:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ebe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ece:	89 df                	mov    %ebx,%edi
  800ed0:	89 de                	mov    %ebx,%esi
  800ed2:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	57                   	push   %edi
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
	asm volatile("int %1\n"
  800edf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eea:	b8 10 00 00 00       	mov    $0x10,%eax
  800eef:	89 df                	mov    %ebx,%edi
  800ef1:	89 de                	mov    %ebx,%esi
  800ef3:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f02:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f04:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f08:	0f 84 8e 00 00 00    	je     800f9c <pgfault+0xa2>
  800f0e:	89 f0                	mov    %esi,%eax
  800f10:	c1 e8 0c             	shr    $0xc,%eax
  800f13:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1a:	f6 c4 08             	test   $0x8,%ah
  800f1d:	74 7d                	je     800f9c <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800f1f:	e8 46 fd ff ff       	call   800c6a <sys_getenvid>
  800f24:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	6a 07                	push   $0x7
  800f2b:	68 00 f0 7f 00       	push   $0x7ff000
  800f30:	50                   	push   %eax
  800f31:	e8 72 fd ff ff       	call   800ca8 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f36:	83 c4 10             	add    $0x10,%esp
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	78 73                	js     800fb0 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f3d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	68 00 10 00 00       	push   $0x1000
  800f4b:	56                   	push   %esi
  800f4c:	68 00 f0 7f 00       	push   $0x7ff000
  800f51:	e8 ec fa ff ff       	call   800a42 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f56:	83 c4 08             	add    $0x8,%esp
  800f59:	56                   	push   %esi
  800f5a:	53                   	push   %ebx
  800f5b:	e8 cd fd ff ff       	call   800d2d <sys_page_unmap>
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	78 5b                	js     800fc2 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	6a 07                	push   $0x7
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	68 00 f0 7f 00       	push   $0x7ff000
  800f73:	53                   	push   %ebx
  800f74:	e8 72 fd ff ff       	call   800ceb <sys_page_map>
  800f79:	83 c4 20             	add    $0x20,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 54                	js     800fd4 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f80:	83 ec 08             	sub    $0x8,%esp
  800f83:	68 00 f0 7f 00       	push   $0x7ff000
  800f88:	53                   	push   %ebx
  800f89:	e8 9f fd ff ff       	call   800d2d <sys_page_unmap>
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	78 51                	js     800fe6 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800f95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f9c:	83 ec 04             	sub    $0x4,%esp
  800f9f:	68 2c 31 80 00       	push   $0x80312c
  800fa4:	6a 1d                	push   $0x1d
  800fa6:	68 a8 31 80 00       	push   $0x8031a8
  800fab:	e8 47 f2 ff ff       	call   8001f7 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800fb0:	50                   	push   %eax
  800fb1:	68 64 31 80 00       	push   $0x803164
  800fb6:	6a 29                	push   $0x29
  800fb8:	68 a8 31 80 00       	push   $0x8031a8
  800fbd:	e8 35 f2 ff ff       	call   8001f7 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800fc2:	50                   	push   %eax
  800fc3:	68 88 31 80 00       	push   $0x803188
  800fc8:	6a 2e                	push   $0x2e
  800fca:	68 a8 31 80 00       	push   $0x8031a8
  800fcf:	e8 23 f2 ff ff       	call   8001f7 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800fd4:	50                   	push   %eax
  800fd5:	68 b3 31 80 00       	push   $0x8031b3
  800fda:	6a 30                	push   $0x30
  800fdc:	68 a8 31 80 00       	push   $0x8031a8
  800fe1:	e8 11 f2 ff ff       	call   8001f7 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800fe6:	50                   	push   %eax
  800fe7:	68 88 31 80 00       	push   $0x803188
  800fec:	6a 32                	push   $0x32
  800fee:	68 a8 31 80 00       	push   $0x8031a8
  800ff3:	e8 ff f1 ff ff       	call   8001f7 <_panic>

00800ff8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	57                   	push   %edi
  800ffc:	56                   	push   %esi
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801001:	68 fa 0e 80 00       	push   $0x800efa
  801006:	e8 e5 18 00 00       	call   8028f0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80100b:	b8 07 00 00 00       	mov    $0x7,%eax
  801010:	cd 30                	int    $0x30
  801012:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 30                	js     80104c <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80101c:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801021:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801025:	75 76                	jne    80109d <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  801027:	e8 3e fc ff ff       	call   800c6a <sys_getenvid>
  80102c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801031:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801037:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80103c:	a3 00 50 80 00       	mov    %eax,0x805000
		return 0;
  801041:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801044:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  80104c:	50                   	push   %eax
  80104d:	68 d1 31 80 00       	push   $0x8031d1
  801052:	6a 78                	push   $0x78
  801054:	68 a8 31 80 00       	push   $0x8031a8
  801059:	e8 99 f1 ff ff       	call   8001f7 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	ff 75 e4             	push   -0x1c(%ebp)
  801064:	57                   	push   %edi
  801065:	ff 75 dc             	push   -0x24(%ebp)
  801068:	57                   	push   %edi
  801069:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80106c:	56                   	push   %esi
  80106d:	e8 79 fc ff ff       	call   800ceb <sys_page_map>
	if(r<0) return r;
  801072:	83 c4 20             	add    $0x20,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	78 cb                	js     801044 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	ff 75 e4             	push   -0x1c(%ebp)
  80107f:	57                   	push   %edi
  801080:	56                   	push   %esi
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	e8 63 fc ff ff       	call   800ceb <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801088:	83 c4 20             	add    $0x20,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	78 76                	js     801105 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80108f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801095:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80109b:	74 75                	je     801112 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  80109d:	89 d8                	mov    %ebx,%eax
  80109f:	c1 e8 16             	shr    $0x16,%eax
  8010a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a9:	a8 01                	test   $0x1,%al
  8010ab:	74 e2                	je     80108f <fork+0x97>
  8010ad:	89 de                	mov    %ebx,%esi
  8010af:	c1 ee 0c             	shr    $0xc,%esi
  8010b2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b9:	a8 01                	test   $0x1,%al
  8010bb:	74 d2                	je     80108f <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  8010bd:	e8 a8 fb ff ff       	call   800c6a <sys_getenvid>
  8010c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8010c5:	89 f7                	mov    %esi,%edi
  8010c7:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  8010ca:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d1:	89 c1                	mov    %eax,%ecx
  8010d3:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8010d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8010dc:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8010e3:	f6 c6 04             	test   $0x4,%dh
  8010e6:	0f 85 72 ff ff ff    	jne    80105e <fork+0x66>
		perm &= ~PTE_W;
  8010ec:	25 05 0e 00 00       	and    $0xe05,%eax
  8010f1:	80 cc 08             	or     $0x8,%ah
  8010f4:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8010fa:	0f 44 c1             	cmove  %ecx,%eax
  8010fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801100:	e9 59 ff ff ff       	jmp    80105e <fork+0x66>
  801105:	ba 00 00 00 00       	mov    $0x0,%edx
  80110a:	0f 4f c2             	cmovg  %edx,%eax
  80110d:	e9 32 ff ff ff       	jmp    801044 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	6a 07                	push   $0x7
  801117:	68 00 f0 bf ee       	push   $0xeebff000
  80111c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80111f:	57                   	push   %edi
  801120:	e8 83 fb ff ff       	call   800ca8 <sys_page_alloc>
	if(r<0) return r;
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	85 c0                	test   %eax,%eax
  80112a:	0f 88 14 ff ff ff    	js     801044 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	68 66 29 80 00       	push   $0x802966
  801138:	57                   	push   %edi
  801139:	e8 b5 fc ff ff       	call   800df3 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	85 c0                	test   %eax,%eax
  801143:	0f 88 fb fe ff ff    	js     801044 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801149:	83 ec 08             	sub    $0x8,%esp
  80114c:	6a 02                	push   $0x2
  80114e:	57                   	push   %edi
  80114f:	e8 1b fc ff ff       	call   800d6f <sys_env_set_status>
	if(r<0) return r;
  801154:	83 c4 10             	add    $0x10,%esp
	return envid;
  801157:	85 c0                	test   %eax,%eax
  801159:	0f 49 c7             	cmovns %edi,%eax
  80115c:	e9 e3 fe ff ff       	jmp    801044 <fork+0x4c>

00801161 <sfork>:

// Challenge!
int
sfork(void)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801167:	68 e1 31 80 00       	push   $0x8031e1
  80116c:	68 a1 00 00 00       	push   $0xa1
  801171:	68 a8 31 80 00       	push   $0x8031a8
  801176:	e8 7c f0 ff ff       	call   8001f7 <_panic>

0080117b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117e:	8b 45 08             	mov    0x8(%ebp),%eax
  801181:	05 00 00 00 30       	add    $0x30000000,%eax
  801186:	c1 e8 0c             	shr    $0xc,%eax
}
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    

0080118b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
  801191:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    

008011a2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011aa:	89 c2                	mov    %eax,%edx
  8011ac:	c1 ea 16             	shr    $0x16,%edx
  8011af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b6:	f6 c2 01             	test   $0x1,%dl
  8011b9:	74 29                	je     8011e4 <fd_alloc+0x42>
  8011bb:	89 c2                	mov    %eax,%edx
  8011bd:	c1 ea 0c             	shr    $0xc,%edx
  8011c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c7:	f6 c2 01             	test   $0x1,%dl
  8011ca:	74 18                	je     8011e4 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011cc:	05 00 10 00 00       	add    $0x1000,%eax
  8011d1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d6:	75 d2                	jne    8011aa <fd_alloc+0x8>
  8011d8:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8011dd:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8011e2:	eb 05                	jmp    8011e9 <fd_alloc+0x47>
			return 0;
  8011e4:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8011e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ec:	89 02                	mov    %eax,(%edx)
}
  8011ee:	89 c8                	mov    %ecx,%eax
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f8:	83 f8 1f             	cmp    $0x1f,%eax
  8011fb:	77 30                	ja     80122d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fd:	c1 e0 0c             	shl    $0xc,%eax
  801200:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801205:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80120b:	f6 c2 01             	test   $0x1,%dl
  80120e:	74 24                	je     801234 <fd_lookup+0x42>
  801210:	89 c2                	mov    %eax,%edx
  801212:	c1 ea 0c             	shr    $0xc,%edx
  801215:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121c:	f6 c2 01             	test   $0x1,%dl
  80121f:	74 1a                	je     80123b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801221:	8b 55 0c             	mov    0xc(%ebp),%edx
  801224:	89 02                	mov    %eax,(%edx)
	return 0;
  801226:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    
		return -E_INVAL;
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801232:	eb f7                	jmp    80122b <fd_lookup+0x39>
		return -E_INVAL;
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801239:	eb f0                	jmp    80122b <fd_lookup+0x39>
  80123b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801240:	eb e9                	jmp    80122b <fd_lookup+0x39>

00801242 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	53                   	push   %ebx
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80124c:	b8 00 00 00 00       	mov    $0x0,%eax
  801251:	bb 0c 40 80 00       	mov    $0x80400c,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801256:	39 13                	cmp    %edx,(%ebx)
  801258:	74 37                	je     801291 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80125a:	83 c0 01             	add    $0x1,%eax
  80125d:	8b 1c 85 74 32 80 00 	mov    0x803274(,%eax,4),%ebx
  801264:	85 db                	test   %ebx,%ebx
  801266:	75 ee                	jne    801256 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801268:	a1 00 50 80 00       	mov    0x805000,%eax
  80126d:	8b 40 58             	mov    0x58(%eax),%eax
  801270:	83 ec 04             	sub    $0x4,%esp
  801273:	52                   	push   %edx
  801274:	50                   	push   %eax
  801275:	68 f8 31 80 00       	push   $0x8031f8
  80127a:	e8 53 f0 ff ff       	call   8002d2 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801287:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128a:	89 1a                	mov    %ebx,(%edx)
}
  80128c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80128f:	c9                   	leave  
  801290:	c3                   	ret    
			return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	eb ef                	jmp    801287 <dev_lookup+0x45>

00801298 <fd_close>:
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 24             	sub    $0x24,%esp
  8012a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012aa:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b4:	50                   	push   %eax
  8012b5:	e8 38 ff ff ff       	call   8011f2 <fd_lookup>
  8012ba:	89 c3                	mov    %eax,%ebx
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 05                	js     8012c8 <fd_close+0x30>
	    || fd != fd2)
  8012c3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012c6:	74 16                	je     8012de <fd_close+0x46>
		return (must_exist ? r : 0);
  8012c8:	89 f8                	mov    %edi,%eax
  8012ca:	84 c0                	test   %al,%al
  8012cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d1:	0f 44 d8             	cmove  %eax,%ebx
}
  8012d4:	89 d8                	mov    %ebx,%eax
  8012d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d9:	5b                   	pop    %ebx
  8012da:	5e                   	pop    %esi
  8012db:	5f                   	pop    %edi
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012e4:	50                   	push   %eax
  8012e5:	ff 36                	push   (%esi)
  8012e7:	e8 56 ff ff ff       	call   801242 <dev_lookup>
  8012ec:	89 c3                	mov    %eax,%ebx
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 1a                	js     80130f <fd_close+0x77>
		if (dev->dev_close)
  8012f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f8:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012fb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801300:	85 c0                	test   %eax,%eax
  801302:	74 0b                	je     80130f <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	56                   	push   %esi
  801308:	ff d0                	call   *%eax
  80130a:	89 c3                	mov    %eax,%ebx
  80130c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	56                   	push   %esi
  801313:	6a 00                	push   $0x0
  801315:	e8 13 fa ff ff       	call   800d2d <sys_page_unmap>
	return r;
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	eb b5                	jmp    8012d4 <fd_close+0x3c>

0080131f <close>:

int
close(int fdnum)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801325:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	ff 75 08             	push   0x8(%ebp)
  80132c:	e8 c1 fe ff ff       	call   8011f2 <fd_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	79 02                	jns    80133a <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    
		return fd_close(fd, 1);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	6a 01                	push   $0x1
  80133f:	ff 75 f4             	push   -0xc(%ebp)
  801342:	e8 51 ff ff ff       	call   801298 <fd_close>
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	eb ec                	jmp    801338 <close+0x19>

0080134c <close_all>:

void
close_all(void)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	53                   	push   %ebx
  801350:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801353:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	53                   	push   %ebx
  80135c:	e8 be ff ff ff       	call   80131f <close>
	for (i = 0; i < MAXFD; i++)
  801361:	83 c3 01             	add    $0x1,%ebx
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	83 fb 20             	cmp    $0x20,%ebx
  80136a:	75 ec                	jne    801358 <close_all+0xc>
}
  80136c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	57                   	push   %edi
  801375:	56                   	push   %esi
  801376:	53                   	push   %ebx
  801377:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80137a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	ff 75 08             	push   0x8(%ebp)
  801381:	e8 6c fe ff ff       	call   8011f2 <fd_lookup>
  801386:	89 c3                	mov    %eax,%ebx
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 7f                	js     80140e <dup+0x9d>
		return r;
	close(newfdnum);
  80138f:	83 ec 0c             	sub    $0xc,%esp
  801392:	ff 75 0c             	push   0xc(%ebp)
  801395:	e8 85 ff ff ff       	call   80131f <close>

	newfd = INDEX2FD(newfdnum);
  80139a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80139d:	c1 e6 0c             	shl    $0xc,%esi
  8013a0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013a9:	89 3c 24             	mov    %edi,(%esp)
  8013ac:	e8 da fd ff ff       	call   80118b <fd2data>
  8013b1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013b3:	89 34 24             	mov    %esi,(%esp)
  8013b6:	e8 d0 fd ff ff       	call   80118b <fd2data>
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c1:	89 d8                	mov    %ebx,%eax
  8013c3:	c1 e8 16             	shr    $0x16,%eax
  8013c6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cd:	a8 01                	test   $0x1,%al
  8013cf:	74 11                	je     8013e2 <dup+0x71>
  8013d1:	89 d8                	mov    %ebx,%eax
  8013d3:	c1 e8 0c             	shr    $0xc,%eax
  8013d6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013dd:	f6 c2 01             	test   $0x1,%dl
  8013e0:	75 36                	jne    801418 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e2:	89 f8                	mov    %edi,%eax
  8013e4:	c1 e8 0c             	shr    $0xc,%eax
  8013e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f6:	50                   	push   %eax
  8013f7:	56                   	push   %esi
  8013f8:	6a 00                	push   $0x0
  8013fa:	57                   	push   %edi
  8013fb:	6a 00                	push   $0x0
  8013fd:	e8 e9 f8 ff ff       	call   800ceb <sys_page_map>
  801402:	89 c3                	mov    %eax,%ebx
  801404:	83 c4 20             	add    $0x20,%esp
  801407:	85 c0                	test   %eax,%eax
  801409:	78 33                	js     80143e <dup+0xcd>
		goto err;

	return newfdnum;
  80140b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80140e:	89 d8                	mov    %ebx,%eax
  801410:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801413:	5b                   	pop    %ebx
  801414:	5e                   	pop    %esi
  801415:	5f                   	pop    %edi
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801418:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141f:	83 ec 0c             	sub    $0xc,%esp
  801422:	25 07 0e 00 00       	and    $0xe07,%eax
  801427:	50                   	push   %eax
  801428:	ff 75 d4             	push   -0x2c(%ebp)
  80142b:	6a 00                	push   $0x0
  80142d:	53                   	push   %ebx
  80142e:	6a 00                	push   $0x0
  801430:	e8 b6 f8 ff ff       	call   800ceb <sys_page_map>
  801435:	89 c3                	mov    %eax,%ebx
  801437:	83 c4 20             	add    $0x20,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	79 a4                	jns    8013e2 <dup+0x71>
	sys_page_unmap(0, newfd);
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	56                   	push   %esi
  801442:	6a 00                	push   $0x0
  801444:	e8 e4 f8 ff ff       	call   800d2d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801449:	83 c4 08             	add    $0x8,%esp
  80144c:	ff 75 d4             	push   -0x2c(%ebp)
  80144f:	6a 00                	push   $0x0
  801451:	e8 d7 f8 ff ff       	call   800d2d <sys_page_unmap>
	return r;
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	eb b3                	jmp    80140e <dup+0x9d>

0080145b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
  801460:	83 ec 18             	sub    $0x18,%esp
  801463:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801466:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	56                   	push   %esi
  80146b:	e8 82 fd ff ff       	call   8011f2 <fd_lookup>
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 3c                	js     8014b3 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801477:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	ff 33                	push   (%ebx)
  801483:	e8 ba fd ff ff       	call   801242 <dev_lookup>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 24                	js     8014b3 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148f:	8b 43 08             	mov    0x8(%ebx),%eax
  801492:	83 e0 03             	and    $0x3,%eax
  801495:	83 f8 01             	cmp    $0x1,%eax
  801498:	74 20                	je     8014ba <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80149a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149d:	8b 40 08             	mov    0x8(%eax),%eax
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	74 37                	je     8014db <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	ff 75 10             	push   0x10(%ebp)
  8014aa:	ff 75 0c             	push   0xc(%ebp)
  8014ad:	53                   	push   %ebx
  8014ae:	ff d0                	call   *%eax
  8014b0:	83 c4 10             	add    $0x10,%esp
}
  8014b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ba:	a1 00 50 80 00       	mov    0x805000,%eax
  8014bf:	8b 40 58             	mov    0x58(%eax),%eax
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	56                   	push   %esi
  8014c6:	50                   	push   %eax
  8014c7:	68 39 32 80 00       	push   $0x803239
  8014cc:	e8 01 ee ff ff       	call   8002d2 <cprintf>
		return -E_INVAL;
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d9:	eb d8                	jmp    8014b3 <read+0x58>
		return -E_NOT_SUPP;
  8014db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014e0:	eb d1                	jmp    8014b3 <read+0x58>

008014e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	57                   	push   %edi
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f6:	eb 02                	jmp    8014fa <readn+0x18>
  8014f8:	01 c3                	add    %eax,%ebx
  8014fa:	39 f3                	cmp    %esi,%ebx
  8014fc:	73 21                	jae    80151f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	89 f0                	mov    %esi,%eax
  801503:	29 d8                	sub    %ebx,%eax
  801505:	50                   	push   %eax
  801506:	89 d8                	mov    %ebx,%eax
  801508:	03 45 0c             	add    0xc(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	57                   	push   %edi
  80150d:	e8 49 ff ff ff       	call   80145b <read>
		if (m < 0)
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 04                	js     80151d <readn+0x3b>
			return m;
		if (m == 0)
  801519:	75 dd                	jne    8014f8 <readn+0x16>
  80151b:	eb 02                	jmp    80151f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80151f:	89 d8                	mov    %ebx,%eax
  801521:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801524:	5b                   	pop    %ebx
  801525:	5e                   	pop    %esi
  801526:	5f                   	pop    %edi
  801527:	5d                   	pop    %ebp
  801528:	c3                   	ret    

00801529 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	56                   	push   %esi
  80152d:	53                   	push   %ebx
  80152e:	83 ec 18             	sub    $0x18,%esp
  801531:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801534:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801537:	50                   	push   %eax
  801538:	53                   	push   %ebx
  801539:	e8 b4 fc ff ff       	call   8011f2 <fd_lookup>
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 37                	js     80157c <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801545:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	ff 36                	push   (%esi)
  801551:	e8 ec fc ff ff       	call   801242 <dev_lookup>
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 1f                	js     80157c <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801561:	74 20                	je     801583 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801563:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801566:	8b 40 0c             	mov    0xc(%eax),%eax
  801569:	85 c0                	test   %eax,%eax
  80156b:	74 37                	je     8015a4 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156d:	83 ec 04             	sub    $0x4,%esp
  801570:	ff 75 10             	push   0x10(%ebp)
  801573:	ff 75 0c             	push   0xc(%ebp)
  801576:	56                   	push   %esi
  801577:	ff d0                	call   *%eax
  801579:	83 c4 10             	add    $0x10,%esp
}
  80157c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157f:	5b                   	pop    %ebx
  801580:	5e                   	pop    %esi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801583:	a1 00 50 80 00       	mov    0x805000,%eax
  801588:	8b 40 58             	mov    0x58(%eax),%eax
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	53                   	push   %ebx
  80158f:	50                   	push   %eax
  801590:	68 55 32 80 00       	push   $0x803255
  801595:	e8 38 ed ff ff       	call   8002d2 <cprintf>
		return -E_INVAL;
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a2:	eb d8                	jmp    80157c <write+0x53>
		return -E_NOT_SUPP;
  8015a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a9:	eb d1                	jmp    80157c <write+0x53>

008015ab <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	ff 75 08             	push   0x8(%ebp)
  8015b8:	e8 35 fc ff ff       	call   8011f2 <fd_lookup>
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 0e                	js     8015d2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ca:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	56                   	push   %esi
  8015d8:	53                   	push   %ebx
  8015d9:	83 ec 18             	sub    $0x18,%esp
  8015dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	53                   	push   %ebx
  8015e4:	e8 09 fc ff ff       	call   8011f2 <fd_lookup>
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 34                	js     801624 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	ff 36                	push   (%esi)
  8015fc:	e8 41 fc ff ff       	call   801242 <dev_lookup>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 1c                	js     801624 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801608:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80160c:	74 1d                	je     80162b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80160e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801611:	8b 40 18             	mov    0x18(%eax),%eax
  801614:	85 c0                	test   %eax,%eax
  801616:	74 34                	je     80164c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	ff 75 0c             	push   0xc(%ebp)
  80161e:	56                   	push   %esi
  80161f:	ff d0                	call   *%eax
  801621:	83 c4 10             	add    $0x10,%esp
}
  801624:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801627:	5b                   	pop    %ebx
  801628:	5e                   	pop    %esi
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80162b:	a1 00 50 80 00       	mov    0x805000,%eax
  801630:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801633:	83 ec 04             	sub    $0x4,%esp
  801636:	53                   	push   %ebx
  801637:	50                   	push   %eax
  801638:	68 18 32 80 00       	push   $0x803218
  80163d:	e8 90 ec ff ff       	call   8002d2 <cprintf>
		return -E_INVAL;
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164a:	eb d8                	jmp    801624 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80164c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801651:	eb d1                	jmp    801624 <ftruncate+0x50>

00801653 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	56                   	push   %esi
  801657:	53                   	push   %ebx
  801658:	83 ec 18             	sub    $0x18,%esp
  80165b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	ff 75 08             	push   0x8(%ebp)
  801665:	e8 88 fb ff ff       	call   8011f2 <fd_lookup>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 49                	js     8016ba <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801671:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167a:	50                   	push   %eax
  80167b:	ff 36                	push   (%esi)
  80167d:	e8 c0 fb ff ff       	call   801242 <dev_lookup>
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	85 c0                	test   %eax,%eax
  801687:	78 31                	js     8016ba <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801690:	74 2f                	je     8016c1 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801692:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801695:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80169c:	00 00 00 
	stat->st_isdir = 0;
  80169f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a6:	00 00 00 
	stat->st_dev = dev;
  8016a9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	53                   	push   %ebx
  8016b3:	56                   	push   %esi
  8016b4:	ff 50 14             	call   *0x14(%eax)
  8016b7:	83 c4 10             	add    $0x10,%esp
}
  8016ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5e                   	pop    %esi
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    
		return -E_NOT_SUPP;
  8016c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016c6:	eb f2                	jmp    8016ba <fstat+0x67>

008016c8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	56                   	push   %esi
  8016cc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016cd:	83 ec 08             	sub    $0x8,%esp
  8016d0:	6a 00                	push   $0x0
  8016d2:	ff 75 08             	push   0x8(%ebp)
  8016d5:	e8 e4 01 00 00       	call   8018be <open>
  8016da:	89 c3                	mov    %eax,%ebx
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 1b                	js     8016fe <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	ff 75 0c             	push   0xc(%ebp)
  8016e9:	50                   	push   %eax
  8016ea:	e8 64 ff ff ff       	call   801653 <fstat>
  8016ef:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f1:	89 1c 24             	mov    %ebx,(%esp)
  8016f4:	e8 26 fc ff ff       	call   80131f <close>
	return r;
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	89 f3                	mov    %esi,%ebx
}
  8016fe:	89 d8                	mov    %ebx,%eax
  801700:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801703:	5b                   	pop    %ebx
  801704:	5e                   	pop    %esi
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	89 c6                	mov    %eax,%esi
  80170e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801710:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801717:	74 27                	je     801740 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801719:	6a 07                	push   $0x7
  80171b:	68 00 60 80 00       	push   $0x806000
  801720:	56                   	push   %esi
  801721:	ff 35 00 70 80 00    	push   0x807000
  801727:	e8 d0 12 00 00       	call   8029fc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80172c:	83 c4 0c             	add    $0xc,%esp
  80172f:	6a 00                	push   $0x0
  801731:	53                   	push   %ebx
  801732:	6a 00                	push   $0x0
  801734:	e8 53 12 00 00       	call   80298c <ipc_recv>
}
  801739:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173c:	5b                   	pop    %ebx
  80173d:	5e                   	pop    %esi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801740:	83 ec 0c             	sub    $0xc,%esp
  801743:	6a 01                	push   $0x1
  801745:	e8 06 13 00 00       	call   802a50 <ipc_find_env>
  80174a:	a3 00 70 80 00       	mov    %eax,0x807000
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	eb c5                	jmp    801719 <fsipc+0x12>

00801754 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80175a:	8b 45 08             	mov    0x8(%ebp),%eax
  80175d:	8b 40 0c             	mov    0xc(%eax),%eax
  801760:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801765:	8b 45 0c             	mov    0xc(%ebp),%eax
  801768:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 02 00 00 00       	mov    $0x2,%eax
  801777:	e8 8b ff ff ff       	call   801707 <fsipc>
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devfile_flush>:
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801784:	8b 45 08             	mov    0x8(%ebp),%eax
  801787:	8b 40 0c             	mov    0xc(%eax),%eax
  80178a:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80178f:	ba 00 00 00 00       	mov    $0x0,%edx
  801794:	b8 06 00 00 00       	mov    $0x6,%eax
  801799:	e8 69 ff ff ff       	call   801707 <fsipc>
}
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <devfile_stat>:
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 04             	sub    $0x4,%esp
  8017a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b0:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8017bf:	e8 43 ff ff ff       	call   801707 <fsipc>
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	78 2c                	js     8017f4 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	68 00 60 80 00       	push   $0x806000
  8017d0:	53                   	push   %ebx
  8017d1:	e8 d6 f0 ff ff       	call   8008ac <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d6:	a1 80 60 80 00       	mov    0x806080,%eax
  8017db:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e1:	a1 84 60 80 00       	mov    0x806084,%eax
  8017e6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <devfile_write>:
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	83 ec 0c             	sub    $0xc,%esp
  8017ff:	8b 45 10             	mov    0x10(%ebp),%eax
  801802:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801807:	39 d0                	cmp    %edx,%eax
  801809:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80180c:	8b 55 08             	mov    0x8(%ebp),%edx
  80180f:	8b 52 0c             	mov    0xc(%edx),%edx
  801812:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801818:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80181d:	50                   	push   %eax
  80181e:	ff 75 0c             	push   0xc(%ebp)
  801821:	68 08 60 80 00       	push   $0x806008
  801826:	e8 17 f2 ff ff       	call   800a42 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80182b:	ba 00 00 00 00       	mov    $0x0,%edx
  801830:	b8 04 00 00 00       	mov    $0x4,%eax
  801835:	e8 cd fe ff ff       	call   801707 <fsipc>
}
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <devfile_read>:
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	56                   	push   %esi
  801840:	53                   	push   %ebx
  801841:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	8b 40 0c             	mov    0xc(%eax),%eax
  80184a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80184f:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801855:	ba 00 00 00 00       	mov    $0x0,%edx
  80185a:	b8 03 00 00 00       	mov    $0x3,%eax
  80185f:	e8 a3 fe ff ff       	call   801707 <fsipc>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	85 c0                	test   %eax,%eax
  801868:	78 1f                	js     801889 <devfile_read+0x4d>
	assert(r <= n);
  80186a:	39 f0                	cmp    %esi,%eax
  80186c:	77 24                	ja     801892 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80186e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801873:	7f 33                	jg     8018a8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801875:	83 ec 04             	sub    $0x4,%esp
  801878:	50                   	push   %eax
  801879:	68 00 60 80 00       	push   $0x806000
  80187e:	ff 75 0c             	push   0xc(%ebp)
  801881:	e8 bc f1 ff ff       	call   800a42 <memmove>
	return r;
  801886:	83 c4 10             	add    $0x10,%esp
}
  801889:	89 d8                	mov    %ebx,%eax
  80188b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188e:	5b                   	pop    %ebx
  80188f:	5e                   	pop    %esi
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    
	assert(r <= n);
  801892:	68 88 32 80 00       	push   $0x803288
  801897:	68 8f 32 80 00       	push   $0x80328f
  80189c:	6a 7c                	push   $0x7c
  80189e:	68 a4 32 80 00       	push   $0x8032a4
  8018a3:	e8 4f e9 ff ff       	call   8001f7 <_panic>
	assert(r <= PGSIZE);
  8018a8:	68 af 32 80 00       	push   $0x8032af
  8018ad:	68 8f 32 80 00       	push   $0x80328f
  8018b2:	6a 7d                	push   $0x7d
  8018b4:	68 a4 32 80 00       	push   $0x8032a4
  8018b9:	e8 39 e9 ff ff       	call   8001f7 <_panic>

008018be <open>:
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	56                   	push   %esi
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 1c             	sub    $0x1c,%esp
  8018c6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018c9:	56                   	push   %esi
  8018ca:	e8 a2 ef ff ff       	call   800871 <strlen>
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d7:	7f 6c                	jg     801945 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018d9:	83 ec 0c             	sub    $0xc,%esp
  8018dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018df:	50                   	push   %eax
  8018e0:	e8 bd f8 ff ff       	call   8011a2 <fd_alloc>
  8018e5:	89 c3                	mov    %eax,%ebx
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 3c                	js     80192a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	56                   	push   %esi
  8018f2:	68 00 60 80 00       	push   $0x806000
  8018f7:	e8 b0 ef ff ff       	call   8008ac <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ff:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801904:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801907:	b8 01 00 00 00       	mov    $0x1,%eax
  80190c:	e8 f6 fd ff ff       	call   801707 <fsipc>
  801911:	89 c3                	mov    %eax,%ebx
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	78 19                	js     801933 <open+0x75>
	return fd2num(fd);
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	ff 75 f4             	push   -0xc(%ebp)
  801920:	e8 56 f8 ff ff       	call   80117b <fd2num>
  801925:	89 c3                	mov    %eax,%ebx
  801927:	83 c4 10             	add    $0x10,%esp
}
  80192a:	89 d8                	mov    %ebx,%eax
  80192c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192f:	5b                   	pop    %ebx
  801930:	5e                   	pop    %esi
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    
		fd_close(fd, 0);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	6a 00                	push   $0x0
  801938:	ff 75 f4             	push   -0xc(%ebp)
  80193b:	e8 58 f9 ff ff       	call   801298 <fd_close>
		return r;
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	eb e5                	jmp    80192a <open+0x6c>
		return -E_BAD_PATH;
  801945:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80194a:	eb de                	jmp    80192a <open+0x6c>

0080194c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801952:	ba 00 00 00 00       	mov    $0x0,%edx
  801957:	b8 08 00 00 00       	mov    $0x8,%eax
  80195c:	e8 a6 fd ff ff       	call   801707 <fsipc>
}
  801961:	c9                   	leave  
  801962:	c3                   	ret    

00801963 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	57                   	push   %edi
  801967:	56                   	push   %esi
  801968:	53                   	push   %ebx
  801969:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80196f:	6a 00                	push   $0x0
  801971:	ff 75 08             	push   0x8(%ebp)
  801974:	e8 45 ff ff ff       	call   8018be <open>
  801979:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	85 c0                	test   %eax,%eax
  801984:	0f 88 ad 04 00 00    	js     801e37 <spawn+0x4d4>
  80198a:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80198c:	83 ec 04             	sub    $0x4,%esp
  80198f:	68 00 02 00 00       	push   $0x200
  801994:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80199a:	50                   	push   %eax
  80199b:	57                   	push   %edi
  80199c:	e8 41 fb ff ff       	call   8014e2 <readn>
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019a9:	75 5a                	jne    801a05 <spawn+0xa2>
	    || elf->e_magic != ELF_MAGIC) {
  8019ab:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019b2:	45 4c 46 
  8019b5:	75 4e                	jne    801a05 <spawn+0xa2>
  8019b7:	b8 07 00 00 00       	mov    $0x7,%eax
  8019bc:	cd 30                	int    $0x30
  8019be:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	0f 88 5f 04 00 00    	js     801e2b <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019d1:	69 f0 8c 00 00 00    	imul   $0x8c,%eax,%esi
  8019d7:	81 c6 10 00 c0 ee    	add    $0xeec00010,%esi
  8019dd:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019e3:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019ea:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019f0:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019f6:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8019fb:	be 00 00 00 00       	mov    $0x0,%esi
  801a00:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  801a03:	eb 4b                	jmp    801a50 <spawn+0xed>
		close(fd);
  801a05:	83 ec 0c             	sub    $0xc,%esp
  801a08:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801a0e:	e8 0c f9 ff ff       	call   80131f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a13:	83 c4 0c             	add    $0xc,%esp
  801a16:	68 7f 45 4c 46       	push   $0x464c457f
  801a1b:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  801a21:	68 bb 32 80 00       	push   $0x8032bb
  801a26:	e8 a7 e8 ff ff       	call   8002d2 <cprintf>
		return -E_NOT_EXEC;
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  801a35:	ff ff ff 
  801a38:	e9 fa 03 00 00       	jmp    801e37 <spawn+0x4d4>
		string_size += strlen(argv[argc]) + 1;
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	50                   	push   %eax
  801a41:	e8 2b ee ff ff       	call   800871 <strlen>
  801a46:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801a4a:	83 c3 01             	add    $0x1,%ebx
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a57:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	75 df                	jne    801a3d <spawn+0xda>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a5e:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801a64:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801a6a:	b8 00 10 40 00       	mov    $0x401000,%eax
  801a6f:	29 f0                	sub    %esi,%eax
  801a71:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a73:	89 c2                	mov    %eax,%edx
  801a75:	83 e2 fc             	and    $0xfffffffc,%edx
  801a78:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a7f:	29 c2                	sub    %eax,%edx
  801a81:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a87:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a8a:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a8f:	0f 86 14 04 00 00    	jbe    801ea9 <spawn+0x546>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a95:	83 ec 04             	sub    $0x4,%esp
  801a98:	6a 07                	push   $0x7
  801a9a:	68 00 00 40 00       	push   $0x400000
  801a9f:	6a 00                	push   $0x0
  801aa1:	e8 02 f2 ff ff       	call   800ca8 <sys_page_alloc>
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	0f 88 fd 03 00 00    	js     801eae <spawn+0x54b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ab1:	be 00 00 00 00       	mov    $0x0,%esi
  801ab6:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801abc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801abf:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801ac5:	7e 32                	jle    801af9 <spawn+0x196>
		argv_store[i] = UTEMP2USTACK(string_store);
  801ac7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801acd:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801ad3:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801ad6:	83 ec 08             	sub    $0x8,%esp
  801ad9:	ff 34 b3             	push   (%ebx,%esi,4)
  801adc:	57                   	push   %edi
  801add:	e8 ca ed ff ff       	call   8008ac <strcpy>
		string_store += strlen(argv[i]) + 1;
  801ae2:	83 c4 04             	add    $0x4,%esp
  801ae5:	ff 34 b3             	push   (%ebx,%esi,4)
  801ae8:	e8 84 ed ff ff       	call   800871 <strlen>
  801aed:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801af1:	83 c6 01             	add    $0x1,%esi
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	eb c6                	jmp    801abf <spawn+0x15c>
	}
	argv_store[argc] = 0;
  801af9:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801aff:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b05:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b0c:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b12:	0f 85 8c 00 00 00    	jne    801ba4 <spawn+0x241>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b18:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b1e:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801b24:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801b27:	89 c8                	mov    %ecx,%eax
  801b29:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801b2f:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b32:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801b37:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	6a 07                	push   $0x7
  801b42:	68 00 d0 bf ee       	push   $0xeebfd000
  801b47:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801b4d:	68 00 00 40 00       	push   $0x400000
  801b52:	6a 00                	push   $0x0
  801b54:	e8 92 f1 ff ff       	call   800ceb <sys_page_map>
  801b59:	89 c3                	mov    %eax,%ebx
  801b5b:	83 c4 20             	add    $0x20,%esp
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	0f 88 50 03 00 00    	js     801eb6 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b66:	83 ec 08             	sub    $0x8,%esp
  801b69:	68 00 00 40 00       	push   $0x400000
  801b6e:	6a 00                	push   $0x0
  801b70:	e8 b8 f1 ff ff       	call   800d2d <sys_page_unmap>
  801b75:	89 c3                	mov    %eax,%ebx
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	0f 88 34 03 00 00    	js     801eb6 <spawn+0x553>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b82:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b88:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b8f:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b95:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801b9c:	00 00 00 
  801b9f:	e9 4e 01 00 00       	jmp    801cf2 <spawn+0x38f>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ba4:	68 48 33 80 00       	push   $0x803348
  801ba9:	68 8f 32 80 00       	push   $0x80328f
  801bae:	68 f2 00 00 00       	push   $0xf2
  801bb3:	68 d5 32 80 00       	push   $0x8032d5
  801bb8:	e8 3a e6 ff ff       	call   8001f7 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bbd:	83 ec 04             	sub    $0x4,%esp
  801bc0:	6a 07                	push   $0x7
  801bc2:	68 00 00 40 00       	push   $0x400000
  801bc7:	6a 00                	push   $0x0
  801bc9:	e8 da f0 ff ff       	call   800ca8 <sys_page_alloc>
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	0f 88 6c 02 00 00    	js     801e45 <spawn+0x4e2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bd9:	83 ec 08             	sub    $0x8,%esp
  801bdc:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801be2:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801be8:	50                   	push   %eax
  801be9:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801bef:	e8 b7 f9 ff ff       	call   8015ab <seek>
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	0f 88 4d 02 00 00    	js     801e4c <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bff:	83 ec 04             	sub    $0x4,%esp
  801c02:	89 f8                	mov    %edi,%eax
  801c04:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c0a:	ba 00 10 00 00       	mov    $0x1000,%edx
  801c0f:	39 d0                	cmp    %edx,%eax
  801c11:	0f 47 c2             	cmova  %edx,%eax
  801c14:	50                   	push   %eax
  801c15:	68 00 00 40 00       	push   $0x400000
  801c1a:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801c20:	e8 bd f8 ff ff       	call   8014e2 <readn>
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	0f 88 23 02 00 00    	js     801e53 <spawn+0x4f0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c30:	83 ec 0c             	sub    $0xc,%esp
  801c33:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801c39:	56                   	push   %esi
  801c3a:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801c40:	68 00 00 40 00       	push   $0x400000
  801c45:	6a 00                	push   $0x0
  801c47:	e8 9f f0 ff ff       	call   800ceb <sys_page_map>
  801c4c:	83 c4 20             	add    $0x20,%esp
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	78 7c                	js     801ccf <spawn+0x36c>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801c53:	83 ec 08             	sub    $0x8,%esp
  801c56:	68 00 00 40 00       	push   $0x400000
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 cb f0 ff ff       	call   800d2d <sys_page_unmap>
  801c62:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801c65:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c6b:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c71:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c77:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c7d:	76 65                	jbe    801ce4 <spawn+0x381>
		if (i >= filesz) {
  801c7f:	39 df                	cmp    %ebx,%edi
  801c81:	0f 87 36 ff ff ff    	ja     801bbd <spawn+0x25a>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c87:	83 ec 04             	sub    $0x4,%esp
  801c8a:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801c90:	56                   	push   %esi
  801c91:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801c97:	e8 0c f0 ff ff       	call   800ca8 <sys_page_alloc>
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	79 c2                	jns    801c65 <spawn+0x302>
  801ca3:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801ca5:	83 ec 0c             	sub    $0xc,%esp
  801ca8:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801cae:	e8 76 ef ff ff       	call   800c29 <sys_env_destroy>
	close(fd);
  801cb3:	83 c4 04             	add    $0x4,%esp
  801cb6:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801cbc:	e8 5e f6 ff ff       	call   80131f <close>
	return r;
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  801cca:	e9 68 01 00 00       	jmp    801e37 <spawn+0x4d4>
				panic("spawn: sys_page_map data: %e", r);
  801ccf:	50                   	push   %eax
  801cd0:	68 e1 32 80 00       	push   $0x8032e1
  801cd5:	68 25 01 00 00       	push   $0x125
  801cda:	68 d5 32 80 00       	push   $0x8032d5
  801cdf:	e8 13 e5 ff ff       	call   8001f7 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ce4:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801ceb:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801cf2:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cf9:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801cff:	7e 67                	jle    801d68 <spawn+0x405>
		if (ph->p_type != ELF_PROG_LOAD)
  801d01:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801d07:	83 39 01             	cmpl   $0x1,(%ecx)
  801d0a:	75 d8                	jne    801ce4 <spawn+0x381>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d0c:	8b 41 18             	mov    0x18(%ecx),%eax
  801d0f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801d15:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801d18:	83 f8 01             	cmp    $0x1,%eax
  801d1b:	19 c0                	sbb    %eax,%eax
  801d1d:	83 e0 fe             	and    $0xfffffffe,%eax
  801d20:	83 c0 07             	add    $0x7,%eax
  801d23:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d29:	8b 51 04             	mov    0x4(%ecx),%edx
  801d2c:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801d32:	8b 79 10             	mov    0x10(%ecx),%edi
  801d35:	8b 59 14             	mov    0x14(%ecx),%ebx
  801d38:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d3e:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  801d41:	89 f0                	mov    %esi,%eax
  801d43:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d48:	74 14                	je     801d5e <spawn+0x3fb>
		va -= i;
  801d4a:	29 c6                	sub    %eax,%esi
		memsz += i;
  801d4c:	01 c3                	add    %eax,%ebx
  801d4e:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801d54:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801d56:	29 c2                	sub    %eax,%edx
  801d58:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d63:	e9 09 ff ff ff       	jmp    801c71 <spawn+0x30e>
	close(fd);
  801d68:	83 ec 0c             	sub    $0xc,%esp
  801d6b:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801d71:	e8 a9 f5 ff ff       	call   80131f <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801d76:	e8 ef ee ff ff       	call   800c6a <sys_getenvid>
  801d7b:	89 c6                	mov    %eax,%esi
  801d7d:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801d80:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801d85:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801d8b:	eb 12                	jmp    801d9f <spawn+0x43c>
  801d8d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d93:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d99:	0f 84 bb 00 00 00    	je     801e5a <spawn+0x4f7>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801d9f:	89 d8                	mov    %ebx,%eax
  801da1:	c1 e8 16             	shr    $0x16,%eax
  801da4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801dab:	a8 01                	test   $0x1,%al
  801dad:	74 de                	je     801d8d <spawn+0x42a>
  801daf:	89 d8                	mov    %ebx,%eax
  801db1:	c1 e8 0c             	shr    $0xc,%eax
  801db4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dbb:	f6 c2 01             	test   $0x1,%dl
  801dbe:	74 cd                	je     801d8d <spawn+0x42a>
  801dc0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dc7:	f6 c6 04             	test   $0x4,%dh
  801dca:	74 c1                	je     801d8d <spawn+0x42a>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801dcc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dd3:	83 ec 0c             	sub    $0xc,%esp
  801dd6:	25 07 0e 00 00       	and    $0xe07,%eax
  801ddb:	50                   	push   %eax
  801ddc:	53                   	push   %ebx
  801ddd:	57                   	push   %edi
  801dde:	53                   	push   %ebx
  801ddf:	56                   	push   %esi
  801de0:	e8 06 ef ff ff       	call   800ceb <sys_page_map>
  801de5:	83 c4 20             	add    $0x20,%esp
  801de8:	85 c0                	test   %eax,%eax
  801dea:	79 a1                	jns    801d8d <spawn+0x42a>
		panic("copy_shared_pages: %e", r);
  801dec:	50                   	push   %eax
  801ded:	68 2f 33 80 00       	push   $0x80332f
  801df2:	68 82 00 00 00       	push   $0x82
  801df7:	68 d5 32 80 00       	push   $0x8032d5
  801dfc:	e8 f6 e3 ff ff       	call   8001f7 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801e01:	50                   	push   %eax
  801e02:	68 fe 32 80 00       	push   $0x8032fe
  801e07:	68 86 00 00 00       	push   $0x86
  801e0c:	68 d5 32 80 00       	push   $0x8032d5
  801e11:	e8 e1 e3 ff ff       	call   8001f7 <_panic>
		panic("sys_env_set_status: %e", r);
  801e16:	50                   	push   %eax
  801e17:	68 18 33 80 00       	push   $0x803318
  801e1c:	68 89 00 00 00       	push   $0x89
  801e21:	68 d5 32 80 00       	push   $0x8032d5
  801e26:	e8 cc e3 ff ff       	call   8001f7 <_panic>
		return r;
  801e2b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e31:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801e37:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5f                   	pop    %edi
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    
  801e45:	89 c7                	mov    %eax,%edi
  801e47:	e9 59 fe ff ff       	jmp    801ca5 <spawn+0x342>
  801e4c:	89 c7                	mov    %eax,%edi
  801e4e:	e9 52 fe ff ff       	jmp    801ca5 <spawn+0x342>
  801e53:	89 c7                	mov    %eax,%edi
  801e55:	e9 4b fe ff ff       	jmp    801ca5 <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e5a:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e61:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e64:	83 ec 08             	sub    $0x8,%esp
  801e67:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e6d:	50                   	push   %eax
  801e6e:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801e74:	e8 38 ef ff ff       	call   800db1 <sys_env_set_trapframe>
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	78 81                	js     801e01 <spawn+0x49e>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e80:	83 ec 08             	sub    $0x8,%esp
  801e83:	6a 02                	push   $0x2
  801e85:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801e8b:	e8 df ee ff ff       	call   800d6f <sys_env_set_status>
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	85 c0                	test   %eax,%eax
  801e95:	0f 88 7b ff ff ff    	js     801e16 <spawn+0x4b3>
	return child;
  801e9b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ea1:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801ea7:	eb 8e                	jmp    801e37 <spawn+0x4d4>
		return -E_NO_MEM;
  801ea9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801eae:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801eb4:	eb 81                	jmp    801e37 <spawn+0x4d4>
	sys_page_unmap(0, UTEMP);
  801eb6:	83 ec 08             	sub    $0x8,%esp
  801eb9:	68 00 00 40 00       	push   $0x400000
  801ebe:	6a 00                	push   $0x0
  801ec0:	e8 68 ee ff ff       	call   800d2d <sys_page_unmap>
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801ece:	e9 64 ff ff ff       	jmp    801e37 <spawn+0x4d4>

00801ed3 <spawnl>:
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
	va_start(vl, arg0);
  801ed8:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801edb:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801ee0:	eb 05                	jmp    801ee7 <spawnl+0x14>
		argc++;
  801ee2:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801ee5:	89 ca                	mov    %ecx,%edx
  801ee7:	8d 4a 04             	lea    0x4(%edx),%ecx
  801eea:	83 3a 00             	cmpl   $0x0,(%edx)
  801eed:	75 f3                	jne    801ee2 <spawnl+0xf>
	const char *argv[argc+2];
  801eef:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801ef6:	89 d3                	mov    %edx,%ebx
  801ef8:	83 e3 f0             	and    $0xfffffff0,%ebx
  801efb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801f01:	89 e1                	mov    %esp,%ecx
  801f03:	29 d1                	sub    %edx,%ecx
  801f05:	39 cc                	cmp    %ecx,%esp
  801f07:	74 10                	je     801f19 <spawnl+0x46>
  801f09:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801f0f:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801f16:	00 
  801f17:	eb ec                	jmp    801f05 <spawnl+0x32>
  801f19:	89 da                	mov    %ebx,%edx
  801f1b:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801f21:	29 d4                	sub    %edx,%esp
  801f23:	85 d2                	test   %edx,%edx
  801f25:	74 05                	je     801f2c <spawnl+0x59>
  801f27:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801f2c:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801f30:	89 da                	mov    %ebx,%edx
  801f32:	c1 ea 02             	shr    $0x2,%edx
  801f35:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801f38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f3b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f42:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801f49:	00 
	va_start(vl, arg0);
  801f4a:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801f4d:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801f4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f54:	eb 0b                	jmp    801f61 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801f56:	83 c0 01             	add    $0x1,%eax
  801f59:	8b 31                	mov    (%ecx),%esi
  801f5b:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801f5e:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801f61:	39 d0                	cmp    %edx,%eax
  801f63:	75 f1                	jne    801f56 <spawnl+0x83>
	return spawn(prog, argv);
  801f65:	83 ec 08             	sub    $0x8,%esp
  801f68:	53                   	push   %ebx
  801f69:	ff 75 08             	push   0x8(%ebp)
  801f6c:	e8 f2 f9 ff ff       	call   801963 <spawn>
}
  801f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801f7e:	68 6e 33 80 00       	push   $0x80336e
  801f83:	ff 75 0c             	push   0xc(%ebp)
  801f86:	e8 21 e9 ff ff       	call   8008ac <strcpy>
	return 0;
}
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <devsock_close>:
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	53                   	push   %ebx
  801f96:	83 ec 10             	sub    $0x10,%esp
  801f99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f9c:	53                   	push   %ebx
  801f9d:	e8 ed 0a 00 00       	call   802a8f <pageref>
  801fa2:	89 c2                	mov    %eax,%edx
  801fa4:	83 c4 10             	add    $0x10,%esp
		return 0;
  801fa7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801fac:	83 fa 01             	cmp    $0x1,%edx
  801faf:	74 05                	je     801fb6 <devsock_close+0x24>
}
  801fb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb4:	c9                   	leave  
  801fb5:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801fb6:	83 ec 0c             	sub    $0xc,%esp
  801fb9:	ff 73 0c             	push   0xc(%ebx)
  801fbc:	e8 b7 02 00 00       	call   802278 <nsipc_close>
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	eb eb                	jmp    801fb1 <devsock_close+0x1f>

00801fc6 <devsock_write>:
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801fcc:	6a 00                	push   $0x0
  801fce:	ff 75 10             	push   0x10(%ebp)
  801fd1:	ff 75 0c             	push   0xc(%ebp)
  801fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd7:	ff 70 0c             	push   0xc(%eax)
  801fda:	e8 79 03 00 00       	call   802358 <nsipc_send>
}
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    

00801fe1 <devsock_read>:
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801fe7:	6a 00                	push   $0x0
  801fe9:	ff 75 10             	push   0x10(%ebp)
  801fec:	ff 75 0c             	push   0xc(%ebp)
  801fef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff2:	ff 70 0c             	push   0xc(%eax)
  801ff5:	e8 ef 02 00 00       	call   8022e9 <nsipc_recv>
}
  801ffa:	c9                   	leave  
  801ffb:	c3                   	ret    

00801ffc <fd2sockid>:
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  802002:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802005:	52                   	push   %edx
  802006:	50                   	push   %eax
  802007:	e8 e6 f1 ff ff       	call   8011f2 <fd_lookup>
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	85 c0                	test   %eax,%eax
  802011:	78 10                	js     802023 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  802013:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802016:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  80201c:	39 08                	cmp    %ecx,(%eax)
  80201e:	75 05                	jne    802025 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  802020:	8b 40 0c             	mov    0xc(%eax),%eax
}
  802023:	c9                   	leave  
  802024:	c3                   	ret    
		return -E_NOT_SUPP;
  802025:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80202a:	eb f7                	jmp    802023 <fd2sockid+0x27>

0080202c <alloc_sockfd>:
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	56                   	push   %esi
  802030:	53                   	push   %ebx
  802031:	83 ec 1c             	sub    $0x1c,%esp
  802034:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  802036:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802039:	50                   	push   %eax
  80203a:	e8 63 f1 ff ff       	call   8011a2 <fd_alloc>
  80203f:	89 c3                	mov    %eax,%ebx
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	85 c0                	test   %eax,%eax
  802046:	78 43                	js     80208b <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802048:	83 ec 04             	sub    $0x4,%esp
  80204b:	68 07 04 00 00       	push   $0x407
  802050:	ff 75 f4             	push   -0xc(%ebp)
  802053:	6a 00                	push   $0x0
  802055:	e8 4e ec ff ff       	call   800ca8 <sys_page_alloc>
  80205a:	89 c3                	mov    %eax,%ebx
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	85 c0                	test   %eax,%eax
  802061:	78 28                	js     80208b <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  802063:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802066:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80206c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80206e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802071:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802078:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80207b:	83 ec 0c             	sub    $0xc,%esp
  80207e:	50                   	push   %eax
  80207f:	e8 f7 f0 ff ff       	call   80117b <fd2num>
  802084:	89 c3                	mov    %eax,%ebx
  802086:	83 c4 10             	add    $0x10,%esp
  802089:	eb 0c                	jmp    802097 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80208b:	83 ec 0c             	sub    $0xc,%esp
  80208e:	56                   	push   %esi
  80208f:	e8 e4 01 00 00       	call   802278 <nsipc_close>
		return r;
  802094:	83 c4 10             	add    $0x10,%esp
}
  802097:	89 d8                	mov    %ebx,%eax
  802099:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209c:	5b                   	pop    %ebx
  80209d:	5e                   	pop    %esi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    

008020a0 <accept>:
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8020a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a9:	e8 4e ff ff ff       	call   801ffc <fd2sockid>
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	78 1b                	js     8020cd <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8020b2:	83 ec 04             	sub    $0x4,%esp
  8020b5:	ff 75 10             	push   0x10(%ebp)
  8020b8:	ff 75 0c             	push   0xc(%ebp)
  8020bb:	50                   	push   %eax
  8020bc:	e8 0e 01 00 00       	call   8021cf <nsipc_accept>
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	78 05                	js     8020cd <accept+0x2d>
	return alloc_sockfd(r);
  8020c8:	e8 5f ff ff ff       	call   80202c <alloc_sockfd>
}
  8020cd:	c9                   	leave  
  8020ce:	c3                   	ret    

008020cf <bind>:
{
  8020cf:	55                   	push   %ebp
  8020d0:	89 e5                	mov    %esp,%ebp
  8020d2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8020d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d8:	e8 1f ff ff ff       	call   801ffc <fd2sockid>
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	78 12                	js     8020f3 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8020e1:	83 ec 04             	sub    $0x4,%esp
  8020e4:	ff 75 10             	push   0x10(%ebp)
  8020e7:	ff 75 0c             	push   0xc(%ebp)
  8020ea:	50                   	push   %eax
  8020eb:	e8 31 01 00 00       	call   802221 <nsipc_bind>
  8020f0:	83 c4 10             	add    $0x10,%esp
}
  8020f3:	c9                   	leave  
  8020f4:	c3                   	ret    

008020f5 <shutdown>:
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8020fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fe:	e8 f9 fe ff ff       	call   801ffc <fd2sockid>
  802103:	85 c0                	test   %eax,%eax
  802105:	78 0f                	js     802116 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  802107:	83 ec 08             	sub    $0x8,%esp
  80210a:	ff 75 0c             	push   0xc(%ebp)
  80210d:	50                   	push   %eax
  80210e:	e8 43 01 00 00       	call   802256 <nsipc_shutdown>
  802113:	83 c4 10             	add    $0x10,%esp
}
  802116:	c9                   	leave  
  802117:	c3                   	ret    

00802118 <connect>:
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80211e:	8b 45 08             	mov    0x8(%ebp),%eax
  802121:	e8 d6 fe ff ff       	call   801ffc <fd2sockid>
  802126:	85 c0                	test   %eax,%eax
  802128:	78 12                	js     80213c <connect+0x24>
	return nsipc_connect(r, name, namelen);
  80212a:	83 ec 04             	sub    $0x4,%esp
  80212d:	ff 75 10             	push   0x10(%ebp)
  802130:	ff 75 0c             	push   0xc(%ebp)
  802133:	50                   	push   %eax
  802134:	e8 59 01 00 00       	call   802292 <nsipc_connect>
  802139:	83 c4 10             	add    $0x10,%esp
}
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <listen>:
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802144:	8b 45 08             	mov    0x8(%ebp),%eax
  802147:	e8 b0 fe ff ff       	call   801ffc <fd2sockid>
  80214c:	85 c0                	test   %eax,%eax
  80214e:	78 0f                	js     80215f <listen+0x21>
	return nsipc_listen(r, backlog);
  802150:	83 ec 08             	sub    $0x8,%esp
  802153:	ff 75 0c             	push   0xc(%ebp)
  802156:	50                   	push   %eax
  802157:	e8 6b 01 00 00       	call   8022c7 <nsipc_listen>
  80215c:	83 c4 10             	add    $0x10,%esp
}
  80215f:	c9                   	leave  
  802160:	c3                   	ret    

00802161 <socket>:

int
socket(int domain, int type, int protocol)
{
  802161:	55                   	push   %ebp
  802162:	89 e5                	mov    %esp,%ebp
  802164:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802167:	ff 75 10             	push   0x10(%ebp)
  80216a:	ff 75 0c             	push   0xc(%ebp)
  80216d:	ff 75 08             	push   0x8(%ebp)
  802170:	e8 41 02 00 00       	call   8023b6 <nsipc_socket>
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	85 c0                	test   %eax,%eax
  80217a:	78 05                	js     802181 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80217c:	e8 ab fe ff ff       	call   80202c <alloc_sockfd>
}
  802181:	c9                   	leave  
  802182:	c3                   	ret    

00802183 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802183:	55                   	push   %ebp
  802184:	89 e5                	mov    %esp,%ebp
  802186:	53                   	push   %ebx
  802187:	83 ec 04             	sub    $0x4,%esp
  80218a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80218c:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802193:	74 26                	je     8021bb <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802195:	6a 07                	push   $0x7
  802197:	68 00 80 80 00       	push   $0x808000
  80219c:	53                   	push   %ebx
  80219d:	ff 35 00 90 80 00    	push   0x809000
  8021a3:	e8 54 08 00 00       	call   8029fc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8021a8:	83 c4 0c             	add    $0xc,%esp
  8021ab:	6a 00                	push   $0x0
  8021ad:	6a 00                	push   $0x0
  8021af:	6a 00                	push   $0x0
  8021b1:	e8 d6 07 00 00       	call   80298c <ipc_recv>
}
  8021b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021b9:	c9                   	leave  
  8021ba:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8021bb:	83 ec 0c             	sub    $0xc,%esp
  8021be:	6a 02                	push   $0x2
  8021c0:	e8 8b 08 00 00       	call   802a50 <ipc_find_env>
  8021c5:	a3 00 90 80 00       	mov    %eax,0x809000
  8021ca:	83 c4 10             	add    $0x10,%esp
  8021cd:	eb c6                	jmp    802195 <nsipc+0x12>

008021cf <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8021d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021da:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8021df:	8b 06                	mov    (%esi),%eax
  8021e1:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	e8 93 ff ff ff       	call   802183 <nsipc>
  8021f0:	89 c3                	mov    %eax,%ebx
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	79 09                	jns    8021ff <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8021f6:	89 d8                	mov    %ebx,%eax
  8021f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fb:	5b                   	pop    %ebx
  8021fc:	5e                   	pop    %esi
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021ff:	83 ec 04             	sub    $0x4,%esp
  802202:	ff 35 10 80 80 00    	push   0x808010
  802208:	68 00 80 80 00       	push   $0x808000
  80220d:	ff 75 0c             	push   0xc(%ebp)
  802210:	e8 2d e8 ff ff       	call   800a42 <memmove>
		*addrlen = ret->ret_addrlen;
  802215:	a1 10 80 80 00       	mov    0x808010,%eax
  80221a:	89 06                	mov    %eax,(%esi)
  80221c:	83 c4 10             	add    $0x10,%esp
	return r;
  80221f:	eb d5                	jmp    8021f6 <nsipc_accept+0x27>

00802221 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802221:	55                   	push   %ebp
  802222:	89 e5                	mov    %esp,%ebp
  802224:	53                   	push   %ebx
  802225:	83 ec 08             	sub    $0x8,%esp
  802228:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80222b:	8b 45 08             	mov    0x8(%ebp),%eax
  80222e:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802233:	53                   	push   %ebx
  802234:	ff 75 0c             	push   0xc(%ebp)
  802237:	68 04 80 80 00       	push   $0x808004
  80223c:	e8 01 e8 ff ff       	call   800a42 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802241:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  802247:	b8 02 00 00 00       	mov    $0x2,%eax
  80224c:	e8 32 ff ff ff       	call   802183 <nsipc>
}
  802251:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802254:	c9                   	leave  
  802255:	c3                   	ret    

00802256 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802256:	55                   	push   %ebp
  802257:	89 e5                	mov    %esp,%ebp
  802259:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80225c:	8b 45 08             	mov    0x8(%ebp),%eax
  80225f:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  802264:	8b 45 0c             	mov    0xc(%ebp),%eax
  802267:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  80226c:	b8 03 00 00 00       	mov    $0x3,%eax
  802271:	e8 0d ff ff ff       	call   802183 <nsipc>
}
  802276:	c9                   	leave  
  802277:	c3                   	ret    

00802278 <nsipc_close>:

int
nsipc_close(int s)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80227e:	8b 45 08             	mov    0x8(%ebp),%eax
  802281:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  802286:	b8 04 00 00 00       	mov    $0x4,%eax
  80228b:	e8 f3 fe ff ff       	call   802183 <nsipc>
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	53                   	push   %ebx
  802296:	83 ec 08             	sub    $0x8,%esp
  802299:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80229c:	8b 45 08             	mov    0x8(%ebp),%eax
  80229f:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8022a4:	53                   	push   %ebx
  8022a5:	ff 75 0c             	push   0xc(%ebp)
  8022a8:	68 04 80 80 00       	push   $0x808004
  8022ad:	e8 90 e7 ff ff       	call   800a42 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8022b2:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  8022b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8022bd:	e8 c1 fe ff ff       	call   802183 <nsipc>
}
  8022c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022c5:	c9                   	leave  
  8022c6:	c3                   	ret    

008022c7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8022c7:	55                   	push   %ebp
  8022c8:	89 e5                	mov    %esp,%ebp
  8022ca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d0:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  8022d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d8:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  8022dd:	b8 06 00 00 00       	mov    $0x6,%eax
  8022e2:	e8 9c fe ff ff       	call   802183 <nsipc>
}
  8022e7:	c9                   	leave  
  8022e8:	c3                   	ret    

008022e9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	56                   	push   %esi
  8022ed:	53                   	push   %ebx
  8022ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f4:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  8022f9:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  8022ff:	8b 45 14             	mov    0x14(%ebp),%eax
  802302:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802307:	b8 07 00 00 00       	mov    $0x7,%eax
  80230c:	e8 72 fe ff ff       	call   802183 <nsipc>
  802311:	89 c3                	mov    %eax,%ebx
  802313:	85 c0                	test   %eax,%eax
  802315:	78 22                	js     802339 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  802317:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80231c:	39 c6                	cmp    %eax,%esi
  80231e:	0f 4e c6             	cmovle %esi,%eax
  802321:	39 c3                	cmp    %eax,%ebx
  802323:	7f 1d                	jg     802342 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802325:	83 ec 04             	sub    $0x4,%esp
  802328:	53                   	push   %ebx
  802329:	68 00 80 80 00       	push   $0x808000
  80232e:	ff 75 0c             	push   0xc(%ebp)
  802331:	e8 0c e7 ff ff       	call   800a42 <memmove>
  802336:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802339:	89 d8                	mov    %ebx,%eax
  80233b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80233e:	5b                   	pop    %ebx
  80233f:	5e                   	pop    %esi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
		assert(r < 1600 && r <= len);
  802342:	68 7a 33 80 00       	push   $0x80337a
  802347:	68 8f 32 80 00       	push   $0x80328f
  80234c:	6a 62                	push   $0x62
  80234e:	68 8f 33 80 00       	push   $0x80338f
  802353:	e8 9f de ff ff       	call   8001f7 <_panic>

00802358 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	53                   	push   %ebx
  80235c:	83 ec 04             	sub    $0x4,%esp
  80235f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802362:	8b 45 08             	mov    0x8(%ebp),%eax
  802365:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  80236a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802370:	7f 2e                	jg     8023a0 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802372:	83 ec 04             	sub    $0x4,%esp
  802375:	53                   	push   %ebx
  802376:	ff 75 0c             	push   0xc(%ebp)
  802379:	68 0c 80 80 00       	push   $0x80800c
  80237e:	e8 bf e6 ff ff       	call   800a42 <memmove>
	nsipcbuf.send.req_size = size;
  802383:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  802389:	8b 45 14             	mov    0x14(%ebp),%eax
  80238c:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  802391:	b8 08 00 00 00       	mov    $0x8,%eax
  802396:	e8 e8 fd ff ff       	call   802183 <nsipc>
}
  80239b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80239e:	c9                   	leave  
  80239f:	c3                   	ret    
	assert(size < 1600);
  8023a0:	68 9b 33 80 00       	push   $0x80339b
  8023a5:	68 8f 32 80 00       	push   $0x80328f
  8023aa:	6a 6d                	push   $0x6d
  8023ac:	68 8f 33 80 00       	push   $0x80338f
  8023b1:	e8 41 de ff ff       	call   8001f7 <_panic>

008023b6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8023b6:	55                   	push   %ebp
  8023b7:	89 e5                	mov    %esp,%ebp
  8023b9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8023bf:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  8023c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c7:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  8023cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8023cf:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  8023d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8023d9:	e8 a5 fd ff ff       	call   802183 <nsipc>
}
  8023de:	c9                   	leave  
  8023df:	c3                   	ret    

008023e0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023e0:	55                   	push   %ebp
  8023e1:	89 e5                	mov    %esp,%ebp
  8023e3:	56                   	push   %esi
  8023e4:	53                   	push   %ebx
  8023e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023e8:	83 ec 0c             	sub    $0xc,%esp
  8023eb:	ff 75 08             	push   0x8(%ebp)
  8023ee:	e8 98 ed ff ff       	call   80118b <fd2data>
  8023f3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8023f5:	83 c4 08             	add    $0x8,%esp
  8023f8:	68 a7 33 80 00       	push   $0x8033a7
  8023fd:	53                   	push   %ebx
  8023fe:	e8 a9 e4 ff ff       	call   8008ac <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802403:	8b 46 04             	mov    0x4(%esi),%eax
  802406:	2b 06                	sub    (%esi),%eax
  802408:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80240e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802415:	00 00 00 
	stat->st_dev = &devpipe;
  802418:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  80241f:	40 80 00 
	return 0;
}
  802422:	b8 00 00 00 00       	mov    $0x0,%eax
  802427:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80242a:	5b                   	pop    %ebx
  80242b:	5e                   	pop    %esi
  80242c:	5d                   	pop    %ebp
  80242d:	c3                   	ret    

0080242e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80242e:	55                   	push   %ebp
  80242f:	89 e5                	mov    %esp,%ebp
  802431:	53                   	push   %ebx
  802432:	83 ec 0c             	sub    $0xc,%esp
  802435:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802438:	53                   	push   %ebx
  802439:	6a 00                	push   $0x0
  80243b:	e8 ed e8 ff ff       	call   800d2d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802440:	89 1c 24             	mov    %ebx,(%esp)
  802443:	e8 43 ed ff ff       	call   80118b <fd2data>
  802448:	83 c4 08             	add    $0x8,%esp
  80244b:	50                   	push   %eax
  80244c:	6a 00                	push   $0x0
  80244e:	e8 da e8 ff ff       	call   800d2d <sys_page_unmap>
}
  802453:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802456:	c9                   	leave  
  802457:	c3                   	ret    

00802458 <_pipeisclosed>:
{
  802458:	55                   	push   %ebp
  802459:	89 e5                	mov    %esp,%ebp
  80245b:	57                   	push   %edi
  80245c:	56                   	push   %esi
  80245d:	53                   	push   %ebx
  80245e:	83 ec 1c             	sub    $0x1c,%esp
  802461:	89 c7                	mov    %eax,%edi
  802463:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802465:	a1 00 50 80 00       	mov    0x805000,%eax
  80246a:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80246d:	83 ec 0c             	sub    $0xc,%esp
  802470:	57                   	push   %edi
  802471:	e8 19 06 00 00       	call   802a8f <pageref>
  802476:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802479:	89 34 24             	mov    %esi,(%esp)
  80247c:	e8 0e 06 00 00       	call   802a8f <pageref>
		nn = thisenv->env_runs;
  802481:	8b 15 00 50 80 00    	mov    0x805000,%edx
  802487:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  80248a:	83 c4 10             	add    $0x10,%esp
  80248d:	39 cb                	cmp    %ecx,%ebx
  80248f:	74 1b                	je     8024ac <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802491:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802494:	75 cf                	jne    802465 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802496:	8b 42 68             	mov    0x68(%edx),%eax
  802499:	6a 01                	push   $0x1
  80249b:	50                   	push   %eax
  80249c:	53                   	push   %ebx
  80249d:	68 ae 33 80 00       	push   $0x8033ae
  8024a2:	e8 2b de ff ff       	call   8002d2 <cprintf>
  8024a7:	83 c4 10             	add    $0x10,%esp
  8024aa:	eb b9                	jmp    802465 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8024ac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8024af:	0f 94 c0             	sete   %al
  8024b2:	0f b6 c0             	movzbl %al,%eax
}
  8024b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024b8:	5b                   	pop    %ebx
  8024b9:	5e                   	pop    %esi
  8024ba:	5f                   	pop    %edi
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    

008024bd <devpipe_write>:
{
  8024bd:	55                   	push   %ebp
  8024be:	89 e5                	mov    %esp,%ebp
  8024c0:	57                   	push   %edi
  8024c1:	56                   	push   %esi
  8024c2:	53                   	push   %ebx
  8024c3:	83 ec 28             	sub    $0x28,%esp
  8024c6:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8024c9:	56                   	push   %esi
  8024ca:	e8 bc ec ff ff       	call   80118b <fd2data>
  8024cf:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8024d1:	83 c4 10             	add    $0x10,%esp
  8024d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8024d9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8024dc:	75 09                	jne    8024e7 <devpipe_write+0x2a>
	return i;
  8024de:	89 f8                	mov    %edi,%eax
  8024e0:	eb 23                	jmp    802505 <devpipe_write+0x48>
			sys_yield();
  8024e2:	e8 a2 e7 ff ff       	call   800c89 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8024e7:	8b 43 04             	mov    0x4(%ebx),%eax
  8024ea:	8b 0b                	mov    (%ebx),%ecx
  8024ec:	8d 51 20             	lea    0x20(%ecx),%edx
  8024ef:	39 d0                	cmp    %edx,%eax
  8024f1:	72 1a                	jb     80250d <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8024f3:	89 da                	mov    %ebx,%edx
  8024f5:	89 f0                	mov    %esi,%eax
  8024f7:	e8 5c ff ff ff       	call   802458 <_pipeisclosed>
  8024fc:	85 c0                	test   %eax,%eax
  8024fe:	74 e2                	je     8024e2 <devpipe_write+0x25>
				return 0;
  802500:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802505:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802508:	5b                   	pop    %ebx
  802509:	5e                   	pop    %esi
  80250a:	5f                   	pop    %edi
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80250d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802510:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802514:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802517:	89 c2                	mov    %eax,%edx
  802519:	c1 fa 1f             	sar    $0x1f,%edx
  80251c:	89 d1                	mov    %edx,%ecx
  80251e:	c1 e9 1b             	shr    $0x1b,%ecx
  802521:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802524:	83 e2 1f             	and    $0x1f,%edx
  802527:	29 ca                	sub    %ecx,%edx
  802529:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80252d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802531:	83 c0 01             	add    $0x1,%eax
  802534:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802537:	83 c7 01             	add    $0x1,%edi
  80253a:	eb 9d                	jmp    8024d9 <devpipe_write+0x1c>

0080253c <devpipe_read>:
{
  80253c:	55                   	push   %ebp
  80253d:	89 e5                	mov    %esp,%ebp
  80253f:	57                   	push   %edi
  802540:	56                   	push   %esi
  802541:	53                   	push   %ebx
  802542:	83 ec 18             	sub    $0x18,%esp
  802545:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802548:	57                   	push   %edi
  802549:	e8 3d ec ff ff       	call   80118b <fd2data>
  80254e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802550:	83 c4 10             	add    $0x10,%esp
  802553:	be 00 00 00 00       	mov    $0x0,%esi
  802558:	3b 75 10             	cmp    0x10(%ebp),%esi
  80255b:	75 13                	jne    802570 <devpipe_read+0x34>
	return i;
  80255d:	89 f0                	mov    %esi,%eax
  80255f:	eb 02                	jmp    802563 <devpipe_read+0x27>
				return i;
  802561:	89 f0                	mov    %esi,%eax
}
  802563:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802566:	5b                   	pop    %ebx
  802567:	5e                   	pop    %esi
  802568:	5f                   	pop    %edi
  802569:	5d                   	pop    %ebp
  80256a:	c3                   	ret    
			sys_yield();
  80256b:	e8 19 e7 ff ff       	call   800c89 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802570:	8b 03                	mov    (%ebx),%eax
  802572:	3b 43 04             	cmp    0x4(%ebx),%eax
  802575:	75 18                	jne    80258f <devpipe_read+0x53>
			if (i > 0)
  802577:	85 f6                	test   %esi,%esi
  802579:	75 e6                	jne    802561 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80257b:	89 da                	mov    %ebx,%edx
  80257d:	89 f8                	mov    %edi,%eax
  80257f:	e8 d4 fe ff ff       	call   802458 <_pipeisclosed>
  802584:	85 c0                	test   %eax,%eax
  802586:	74 e3                	je     80256b <devpipe_read+0x2f>
				return 0;
  802588:	b8 00 00 00 00       	mov    $0x0,%eax
  80258d:	eb d4                	jmp    802563 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80258f:	99                   	cltd   
  802590:	c1 ea 1b             	shr    $0x1b,%edx
  802593:	01 d0                	add    %edx,%eax
  802595:	83 e0 1f             	and    $0x1f,%eax
  802598:	29 d0                	sub    %edx,%eax
  80259a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80259f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025a2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8025a5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8025a8:	83 c6 01             	add    $0x1,%esi
  8025ab:	eb ab                	jmp    802558 <devpipe_read+0x1c>

008025ad <pipe>:
{
  8025ad:	55                   	push   %ebp
  8025ae:	89 e5                	mov    %esp,%ebp
  8025b0:	56                   	push   %esi
  8025b1:	53                   	push   %ebx
  8025b2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8025b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025b8:	50                   	push   %eax
  8025b9:	e8 e4 eb ff ff       	call   8011a2 <fd_alloc>
  8025be:	89 c3                	mov    %eax,%ebx
  8025c0:	83 c4 10             	add    $0x10,%esp
  8025c3:	85 c0                	test   %eax,%eax
  8025c5:	0f 88 23 01 00 00    	js     8026ee <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025cb:	83 ec 04             	sub    $0x4,%esp
  8025ce:	68 07 04 00 00       	push   $0x407
  8025d3:	ff 75 f4             	push   -0xc(%ebp)
  8025d6:	6a 00                	push   $0x0
  8025d8:	e8 cb e6 ff ff       	call   800ca8 <sys_page_alloc>
  8025dd:	89 c3                	mov    %eax,%ebx
  8025df:	83 c4 10             	add    $0x10,%esp
  8025e2:	85 c0                	test   %eax,%eax
  8025e4:	0f 88 04 01 00 00    	js     8026ee <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8025ea:	83 ec 0c             	sub    $0xc,%esp
  8025ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8025f0:	50                   	push   %eax
  8025f1:	e8 ac eb ff ff       	call   8011a2 <fd_alloc>
  8025f6:	89 c3                	mov    %eax,%ebx
  8025f8:	83 c4 10             	add    $0x10,%esp
  8025fb:	85 c0                	test   %eax,%eax
  8025fd:	0f 88 db 00 00 00    	js     8026de <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802603:	83 ec 04             	sub    $0x4,%esp
  802606:	68 07 04 00 00       	push   $0x407
  80260b:	ff 75 f0             	push   -0x10(%ebp)
  80260e:	6a 00                	push   $0x0
  802610:	e8 93 e6 ff ff       	call   800ca8 <sys_page_alloc>
  802615:	89 c3                	mov    %eax,%ebx
  802617:	83 c4 10             	add    $0x10,%esp
  80261a:	85 c0                	test   %eax,%eax
  80261c:	0f 88 bc 00 00 00    	js     8026de <pipe+0x131>
	va = fd2data(fd0);
  802622:	83 ec 0c             	sub    $0xc,%esp
  802625:	ff 75 f4             	push   -0xc(%ebp)
  802628:	e8 5e eb ff ff       	call   80118b <fd2data>
  80262d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80262f:	83 c4 0c             	add    $0xc,%esp
  802632:	68 07 04 00 00       	push   $0x407
  802637:	50                   	push   %eax
  802638:	6a 00                	push   $0x0
  80263a:	e8 69 e6 ff ff       	call   800ca8 <sys_page_alloc>
  80263f:	89 c3                	mov    %eax,%ebx
  802641:	83 c4 10             	add    $0x10,%esp
  802644:	85 c0                	test   %eax,%eax
  802646:	0f 88 82 00 00 00    	js     8026ce <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80264c:	83 ec 0c             	sub    $0xc,%esp
  80264f:	ff 75 f0             	push   -0x10(%ebp)
  802652:	e8 34 eb ff ff       	call   80118b <fd2data>
  802657:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80265e:	50                   	push   %eax
  80265f:	6a 00                	push   $0x0
  802661:	56                   	push   %esi
  802662:	6a 00                	push   $0x0
  802664:	e8 82 e6 ff ff       	call   800ceb <sys_page_map>
  802669:	89 c3                	mov    %eax,%ebx
  80266b:	83 c4 20             	add    $0x20,%esp
  80266e:	85 c0                	test   %eax,%eax
  802670:	78 4e                	js     8026c0 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802672:	a1 44 40 80 00       	mov    0x804044,%eax
  802677:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80267a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80267c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80267f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802686:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802689:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80268b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80268e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802695:	83 ec 0c             	sub    $0xc,%esp
  802698:	ff 75 f4             	push   -0xc(%ebp)
  80269b:	e8 db ea ff ff       	call   80117b <fd2num>
  8026a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026a3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8026a5:	83 c4 04             	add    $0x4,%esp
  8026a8:	ff 75 f0             	push   -0x10(%ebp)
  8026ab:	e8 cb ea ff ff       	call   80117b <fd2num>
  8026b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026b3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8026b6:	83 c4 10             	add    $0x10,%esp
  8026b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026be:	eb 2e                	jmp    8026ee <pipe+0x141>
	sys_page_unmap(0, va);
  8026c0:	83 ec 08             	sub    $0x8,%esp
  8026c3:	56                   	push   %esi
  8026c4:	6a 00                	push   $0x0
  8026c6:	e8 62 e6 ff ff       	call   800d2d <sys_page_unmap>
  8026cb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8026ce:	83 ec 08             	sub    $0x8,%esp
  8026d1:	ff 75 f0             	push   -0x10(%ebp)
  8026d4:	6a 00                	push   $0x0
  8026d6:	e8 52 e6 ff ff       	call   800d2d <sys_page_unmap>
  8026db:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8026de:	83 ec 08             	sub    $0x8,%esp
  8026e1:	ff 75 f4             	push   -0xc(%ebp)
  8026e4:	6a 00                	push   $0x0
  8026e6:	e8 42 e6 ff ff       	call   800d2d <sys_page_unmap>
  8026eb:	83 c4 10             	add    $0x10,%esp
}
  8026ee:	89 d8                	mov    %ebx,%eax
  8026f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026f3:	5b                   	pop    %ebx
  8026f4:	5e                   	pop    %esi
  8026f5:	5d                   	pop    %ebp
  8026f6:	c3                   	ret    

008026f7 <pipeisclosed>:
{
  8026f7:	55                   	push   %ebp
  8026f8:	89 e5                	mov    %esp,%ebp
  8026fa:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802700:	50                   	push   %eax
  802701:	ff 75 08             	push   0x8(%ebp)
  802704:	e8 e9 ea ff ff       	call   8011f2 <fd_lookup>
  802709:	83 c4 10             	add    $0x10,%esp
  80270c:	85 c0                	test   %eax,%eax
  80270e:	78 18                	js     802728 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802710:	83 ec 0c             	sub    $0xc,%esp
  802713:	ff 75 f4             	push   -0xc(%ebp)
  802716:	e8 70 ea ff ff       	call   80118b <fd2data>
  80271b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80271d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802720:	e8 33 fd ff ff       	call   802458 <_pipeisclosed>
  802725:	83 c4 10             	add    $0x10,%esp
}
  802728:	c9                   	leave  
  802729:	c3                   	ret    

0080272a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80272a:	55                   	push   %ebp
  80272b:	89 e5                	mov    %esp,%ebp
  80272d:	56                   	push   %esi
  80272e:	53                   	push   %ebx
  80272f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802732:	85 f6                	test   %esi,%esi
  802734:	74 16                	je     80274c <wait+0x22>
	e = &envs[ENVX(envid)];
  802736:	89 f3                	mov    %esi,%ebx
  802738:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80273e:	69 db 8c 00 00 00    	imul   $0x8c,%ebx,%ebx
  802744:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80274a:	eb 1b                	jmp    802767 <wait+0x3d>
	assert(envid != 0);
  80274c:	68 c6 33 80 00       	push   $0x8033c6
  802751:	68 8f 32 80 00       	push   $0x80328f
  802756:	6a 09                	push   $0x9
  802758:	68 d1 33 80 00       	push   $0x8033d1
  80275d:	e8 95 da ff ff       	call   8001f7 <_panic>
		sys_yield();
  802762:	e8 22 e5 ff ff       	call   800c89 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802767:	8b 43 58             	mov    0x58(%ebx),%eax
  80276a:	39 f0                	cmp    %esi,%eax
  80276c:	75 07                	jne    802775 <wait+0x4b>
  80276e:	8b 43 64             	mov    0x64(%ebx),%eax
  802771:	85 c0                	test   %eax,%eax
  802773:	75 ed                	jne    802762 <wait+0x38>
}
  802775:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802778:	5b                   	pop    %ebx
  802779:	5e                   	pop    %esi
  80277a:	5d                   	pop    %ebp
  80277b:	c3                   	ret    

0080277c <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80277c:	b8 00 00 00 00       	mov    $0x0,%eax
  802781:	c3                   	ret    

00802782 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802782:	55                   	push   %ebp
  802783:	89 e5                	mov    %esp,%ebp
  802785:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802788:	68 dc 33 80 00       	push   $0x8033dc
  80278d:	ff 75 0c             	push   0xc(%ebp)
  802790:	e8 17 e1 ff ff       	call   8008ac <strcpy>
	return 0;
}
  802795:	b8 00 00 00 00       	mov    $0x0,%eax
  80279a:	c9                   	leave  
  80279b:	c3                   	ret    

0080279c <devcons_write>:
{
  80279c:	55                   	push   %ebp
  80279d:	89 e5                	mov    %esp,%ebp
  80279f:	57                   	push   %edi
  8027a0:	56                   	push   %esi
  8027a1:	53                   	push   %ebx
  8027a2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8027a8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8027ad:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8027b3:	eb 2e                	jmp    8027e3 <devcons_write+0x47>
		m = n - tot;
  8027b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027b8:	29 f3                	sub    %esi,%ebx
  8027ba:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8027bf:	39 c3                	cmp    %eax,%ebx
  8027c1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8027c4:	83 ec 04             	sub    $0x4,%esp
  8027c7:	53                   	push   %ebx
  8027c8:	89 f0                	mov    %esi,%eax
  8027ca:	03 45 0c             	add    0xc(%ebp),%eax
  8027cd:	50                   	push   %eax
  8027ce:	57                   	push   %edi
  8027cf:	e8 6e e2 ff ff       	call   800a42 <memmove>
		sys_cputs(buf, m);
  8027d4:	83 c4 08             	add    $0x8,%esp
  8027d7:	53                   	push   %ebx
  8027d8:	57                   	push   %edi
  8027d9:	e8 0e e4 ff ff       	call   800bec <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8027de:	01 de                	add    %ebx,%esi
  8027e0:	83 c4 10             	add    $0x10,%esp
  8027e3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027e6:	72 cd                	jb     8027b5 <devcons_write+0x19>
}
  8027e8:	89 f0                	mov    %esi,%eax
  8027ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027ed:	5b                   	pop    %ebx
  8027ee:	5e                   	pop    %esi
  8027ef:	5f                   	pop    %edi
  8027f0:	5d                   	pop    %ebp
  8027f1:	c3                   	ret    

008027f2 <devcons_read>:
{
  8027f2:	55                   	push   %ebp
  8027f3:	89 e5                	mov    %esp,%ebp
  8027f5:	83 ec 08             	sub    $0x8,%esp
  8027f8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8027fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802801:	75 07                	jne    80280a <devcons_read+0x18>
  802803:	eb 1f                	jmp    802824 <devcons_read+0x32>
		sys_yield();
  802805:	e8 7f e4 ff ff       	call   800c89 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80280a:	e8 fb e3 ff ff       	call   800c0a <sys_cgetc>
  80280f:	85 c0                	test   %eax,%eax
  802811:	74 f2                	je     802805 <devcons_read+0x13>
	if (c < 0)
  802813:	78 0f                	js     802824 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802815:	83 f8 04             	cmp    $0x4,%eax
  802818:	74 0c                	je     802826 <devcons_read+0x34>
	*(char*)vbuf = c;
  80281a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80281d:	88 02                	mov    %al,(%edx)
	return 1;
  80281f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802824:	c9                   	leave  
  802825:	c3                   	ret    
		return 0;
  802826:	b8 00 00 00 00       	mov    $0x0,%eax
  80282b:	eb f7                	jmp    802824 <devcons_read+0x32>

0080282d <cputchar>:
{
  80282d:	55                   	push   %ebp
  80282e:	89 e5                	mov    %esp,%ebp
  802830:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802833:	8b 45 08             	mov    0x8(%ebp),%eax
  802836:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802839:	6a 01                	push   $0x1
  80283b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80283e:	50                   	push   %eax
  80283f:	e8 a8 e3 ff ff       	call   800bec <sys_cputs>
}
  802844:	83 c4 10             	add    $0x10,%esp
  802847:	c9                   	leave  
  802848:	c3                   	ret    

00802849 <getchar>:
{
  802849:	55                   	push   %ebp
  80284a:	89 e5                	mov    %esp,%ebp
  80284c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80284f:	6a 01                	push   $0x1
  802851:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802854:	50                   	push   %eax
  802855:	6a 00                	push   $0x0
  802857:	e8 ff eb ff ff       	call   80145b <read>
	if (r < 0)
  80285c:	83 c4 10             	add    $0x10,%esp
  80285f:	85 c0                	test   %eax,%eax
  802861:	78 06                	js     802869 <getchar+0x20>
	if (r < 1)
  802863:	74 06                	je     80286b <getchar+0x22>
	return c;
  802865:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802869:	c9                   	leave  
  80286a:	c3                   	ret    
		return -E_EOF;
  80286b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802870:	eb f7                	jmp    802869 <getchar+0x20>

00802872 <iscons>:
{
  802872:	55                   	push   %ebp
  802873:	89 e5                	mov    %esp,%ebp
  802875:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802878:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80287b:	50                   	push   %eax
  80287c:	ff 75 08             	push   0x8(%ebp)
  80287f:	e8 6e e9 ff ff       	call   8011f2 <fd_lookup>
  802884:	83 c4 10             	add    $0x10,%esp
  802887:	85 c0                	test   %eax,%eax
  802889:	78 11                	js     80289c <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80288b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80288e:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802894:	39 10                	cmp    %edx,(%eax)
  802896:	0f 94 c0             	sete   %al
  802899:	0f b6 c0             	movzbl %al,%eax
}
  80289c:	c9                   	leave  
  80289d:	c3                   	ret    

0080289e <opencons>:
{
  80289e:	55                   	push   %ebp
  80289f:	89 e5                	mov    %esp,%ebp
  8028a1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8028a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028a7:	50                   	push   %eax
  8028a8:	e8 f5 e8 ff ff       	call   8011a2 <fd_alloc>
  8028ad:	83 c4 10             	add    $0x10,%esp
  8028b0:	85 c0                	test   %eax,%eax
  8028b2:	78 3a                	js     8028ee <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028b4:	83 ec 04             	sub    $0x4,%esp
  8028b7:	68 07 04 00 00       	push   $0x407
  8028bc:	ff 75 f4             	push   -0xc(%ebp)
  8028bf:	6a 00                	push   $0x0
  8028c1:	e8 e2 e3 ff ff       	call   800ca8 <sys_page_alloc>
  8028c6:	83 c4 10             	add    $0x10,%esp
  8028c9:	85 c0                	test   %eax,%eax
  8028cb:	78 21                	js     8028ee <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8028cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028d0:	8b 15 60 40 80 00    	mov    0x804060,%edx
  8028d6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028db:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028e2:	83 ec 0c             	sub    $0xc,%esp
  8028e5:	50                   	push   %eax
  8028e6:	e8 90 e8 ff ff       	call   80117b <fd2num>
  8028eb:	83 c4 10             	add    $0x10,%esp
}
  8028ee:	c9                   	leave  
  8028ef:	c3                   	ret    

008028f0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028f0:	55                   	push   %ebp
  8028f1:	89 e5                	mov    %esp,%ebp
  8028f3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8028f6:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  8028fd:	74 0a                	je     802909 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8028ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802902:	a3 04 90 80 00       	mov    %eax,0x809004
}
  802907:	c9                   	leave  
  802908:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802909:	e8 5c e3 ff ff       	call   800c6a <sys_getenvid>
  80290e:	83 ec 04             	sub    $0x4,%esp
  802911:	68 07 0e 00 00       	push   $0xe07
  802916:	68 00 f0 bf ee       	push   $0xeebff000
  80291b:	50                   	push   %eax
  80291c:	e8 87 e3 ff ff       	call   800ca8 <sys_page_alloc>
		if (r < 0) {
  802921:	83 c4 10             	add    $0x10,%esp
  802924:	85 c0                	test   %eax,%eax
  802926:	78 2c                	js     802954 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802928:	e8 3d e3 ff ff       	call   800c6a <sys_getenvid>
  80292d:	83 ec 08             	sub    $0x8,%esp
  802930:	68 66 29 80 00       	push   $0x802966
  802935:	50                   	push   %eax
  802936:	e8 b8 e4 ff ff       	call   800df3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80293b:	83 c4 10             	add    $0x10,%esp
  80293e:	85 c0                	test   %eax,%eax
  802940:	79 bd                	jns    8028ff <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802942:	50                   	push   %eax
  802943:	68 28 34 80 00       	push   $0x803428
  802948:	6a 28                	push   $0x28
  80294a:	68 5e 34 80 00       	push   $0x80345e
  80294f:	e8 a3 d8 ff ff       	call   8001f7 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802954:	50                   	push   %eax
  802955:	68 e8 33 80 00       	push   $0x8033e8
  80295a:	6a 23                	push   $0x23
  80295c:	68 5e 34 80 00       	push   $0x80345e
  802961:	e8 91 d8 ff ff       	call   8001f7 <_panic>

00802966 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802966:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802967:	a1 04 90 80 00       	mov    0x809004,%eax
	call *%eax
  80296c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80296e:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802971:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802975:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802978:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80297c:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802980:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802982:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802985:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802986:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802989:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80298a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80298b:	c3                   	ret    

0080298c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80298c:	55                   	push   %ebp
  80298d:	89 e5                	mov    %esp,%ebp
  80298f:	56                   	push   %esi
  802990:	53                   	push   %ebx
  802991:	8b 75 08             	mov    0x8(%ebp),%esi
  802994:	8b 45 0c             	mov    0xc(%ebp),%eax
  802997:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80299a:	85 c0                	test   %eax,%eax
  80299c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8029a1:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8029a4:	83 ec 0c             	sub    $0xc,%esp
  8029a7:	50                   	push   %eax
  8029a8:	e8 ab e4 ff ff       	call   800e58 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8029ad:	83 c4 10             	add    $0x10,%esp
  8029b0:	85 f6                	test   %esi,%esi
  8029b2:	74 17                	je     8029cb <ipc_recv+0x3f>
  8029b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8029b9:	85 c0                	test   %eax,%eax
  8029bb:	78 0c                	js     8029c9 <ipc_recv+0x3d>
  8029bd:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8029c3:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8029c9:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8029cb:	85 db                	test   %ebx,%ebx
  8029cd:	74 17                	je     8029e6 <ipc_recv+0x5a>
  8029cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8029d4:	85 c0                	test   %eax,%eax
  8029d6:	78 0c                	js     8029e4 <ipc_recv+0x58>
  8029d8:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8029de:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8029e4:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8029e6:	85 c0                	test   %eax,%eax
  8029e8:	78 0b                	js     8029f5 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8029ea:	a1 00 50 80 00       	mov    0x805000,%eax
  8029ef:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8029f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029f8:	5b                   	pop    %ebx
  8029f9:	5e                   	pop    %esi
  8029fa:	5d                   	pop    %ebp
  8029fb:	c3                   	ret    

008029fc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029fc:	55                   	push   %ebp
  8029fd:	89 e5                	mov    %esp,%ebp
  8029ff:	57                   	push   %edi
  802a00:	56                   	push   %esi
  802a01:	53                   	push   %ebx
  802a02:	83 ec 0c             	sub    $0xc,%esp
  802a05:	8b 7d 08             	mov    0x8(%ebp),%edi
  802a08:	8b 75 0c             	mov    0xc(%ebp),%esi
  802a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802a0e:	85 db                	test   %ebx,%ebx
  802a10:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802a15:	0f 44 d8             	cmove  %eax,%ebx
  802a18:	eb 05                	jmp    802a1f <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802a1a:	e8 6a e2 ff ff       	call   800c89 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802a1f:	ff 75 14             	push   0x14(%ebp)
  802a22:	53                   	push   %ebx
  802a23:	56                   	push   %esi
  802a24:	57                   	push   %edi
  802a25:	e8 0b e4 ff ff       	call   800e35 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802a2a:	83 c4 10             	add    $0x10,%esp
  802a2d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a30:	74 e8                	je     802a1a <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802a32:	85 c0                	test   %eax,%eax
  802a34:	78 08                	js     802a3e <ipc_send+0x42>
	}while (r<0);

}
  802a36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a39:	5b                   	pop    %ebx
  802a3a:	5e                   	pop    %esi
  802a3b:	5f                   	pop    %edi
  802a3c:	5d                   	pop    %ebp
  802a3d:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802a3e:	50                   	push   %eax
  802a3f:	68 6c 34 80 00       	push   $0x80346c
  802a44:	6a 3d                	push   $0x3d
  802a46:	68 80 34 80 00       	push   $0x803480
  802a4b:	e8 a7 d7 ff ff       	call   8001f7 <_panic>

00802a50 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a50:	55                   	push   %ebp
  802a51:	89 e5                	mov    %esp,%ebp
  802a53:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a56:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a5b:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802a61:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a67:	8b 52 60             	mov    0x60(%edx),%edx
  802a6a:	39 ca                	cmp    %ecx,%edx
  802a6c:	74 11                	je     802a7f <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802a6e:	83 c0 01             	add    $0x1,%eax
  802a71:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a76:	75 e3                	jne    802a5b <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802a78:	b8 00 00 00 00       	mov    $0x0,%eax
  802a7d:	eb 0e                	jmp    802a8d <ipc_find_env+0x3d>
			return envs[i].env_id;
  802a7f:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802a85:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a8a:	8b 40 58             	mov    0x58(%eax),%eax
}
  802a8d:	5d                   	pop    %ebp
  802a8e:	c3                   	ret    

00802a8f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a8f:	55                   	push   %ebp
  802a90:	89 e5                	mov    %esp,%ebp
  802a92:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a95:	89 c2                	mov    %eax,%edx
  802a97:	c1 ea 16             	shr    $0x16,%edx
  802a9a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802aa1:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802aa6:	f6 c1 01             	test   $0x1,%cl
  802aa9:	74 1c                	je     802ac7 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802aab:	c1 e8 0c             	shr    $0xc,%eax
  802aae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802ab5:	a8 01                	test   $0x1,%al
  802ab7:	74 0e                	je     802ac7 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ab9:	c1 e8 0c             	shr    $0xc,%eax
  802abc:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802ac3:	ef 
  802ac4:	0f b7 d2             	movzwl %dx,%edx
}
  802ac7:	89 d0                	mov    %edx,%eax
  802ac9:	5d                   	pop    %ebp
  802aca:	c3                   	ret    
  802acb:	66 90                	xchg   %ax,%ax
  802acd:	66 90                	xchg   %ax,%ax
  802acf:	90                   	nop

00802ad0 <__udivdi3>:
  802ad0:	f3 0f 1e fb          	endbr32 
  802ad4:	55                   	push   %ebp
  802ad5:	57                   	push   %edi
  802ad6:	56                   	push   %esi
  802ad7:	53                   	push   %ebx
  802ad8:	83 ec 1c             	sub    $0x1c,%esp
  802adb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802adf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802ae3:	8b 74 24 34          	mov    0x34(%esp),%esi
  802ae7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802aeb:	85 c0                	test   %eax,%eax
  802aed:	75 19                	jne    802b08 <__udivdi3+0x38>
  802aef:	39 f3                	cmp    %esi,%ebx
  802af1:	76 4d                	jbe    802b40 <__udivdi3+0x70>
  802af3:	31 ff                	xor    %edi,%edi
  802af5:	89 e8                	mov    %ebp,%eax
  802af7:	89 f2                	mov    %esi,%edx
  802af9:	f7 f3                	div    %ebx
  802afb:	89 fa                	mov    %edi,%edx
  802afd:	83 c4 1c             	add    $0x1c,%esp
  802b00:	5b                   	pop    %ebx
  802b01:	5e                   	pop    %esi
  802b02:	5f                   	pop    %edi
  802b03:	5d                   	pop    %ebp
  802b04:	c3                   	ret    
  802b05:	8d 76 00             	lea    0x0(%esi),%esi
  802b08:	39 f0                	cmp    %esi,%eax
  802b0a:	76 14                	jbe    802b20 <__udivdi3+0x50>
  802b0c:	31 ff                	xor    %edi,%edi
  802b0e:	31 c0                	xor    %eax,%eax
  802b10:	89 fa                	mov    %edi,%edx
  802b12:	83 c4 1c             	add    $0x1c,%esp
  802b15:	5b                   	pop    %ebx
  802b16:	5e                   	pop    %esi
  802b17:	5f                   	pop    %edi
  802b18:	5d                   	pop    %ebp
  802b19:	c3                   	ret    
  802b1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b20:	0f bd f8             	bsr    %eax,%edi
  802b23:	83 f7 1f             	xor    $0x1f,%edi
  802b26:	75 48                	jne    802b70 <__udivdi3+0xa0>
  802b28:	39 f0                	cmp    %esi,%eax
  802b2a:	72 06                	jb     802b32 <__udivdi3+0x62>
  802b2c:	31 c0                	xor    %eax,%eax
  802b2e:	39 eb                	cmp    %ebp,%ebx
  802b30:	77 de                	ja     802b10 <__udivdi3+0x40>
  802b32:	b8 01 00 00 00       	mov    $0x1,%eax
  802b37:	eb d7                	jmp    802b10 <__udivdi3+0x40>
  802b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b40:	89 d9                	mov    %ebx,%ecx
  802b42:	85 db                	test   %ebx,%ebx
  802b44:	75 0b                	jne    802b51 <__udivdi3+0x81>
  802b46:	b8 01 00 00 00       	mov    $0x1,%eax
  802b4b:	31 d2                	xor    %edx,%edx
  802b4d:	f7 f3                	div    %ebx
  802b4f:	89 c1                	mov    %eax,%ecx
  802b51:	31 d2                	xor    %edx,%edx
  802b53:	89 f0                	mov    %esi,%eax
  802b55:	f7 f1                	div    %ecx
  802b57:	89 c6                	mov    %eax,%esi
  802b59:	89 e8                	mov    %ebp,%eax
  802b5b:	89 f7                	mov    %esi,%edi
  802b5d:	f7 f1                	div    %ecx
  802b5f:	89 fa                	mov    %edi,%edx
  802b61:	83 c4 1c             	add    $0x1c,%esp
  802b64:	5b                   	pop    %ebx
  802b65:	5e                   	pop    %esi
  802b66:	5f                   	pop    %edi
  802b67:	5d                   	pop    %ebp
  802b68:	c3                   	ret    
  802b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b70:	89 f9                	mov    %edi,%ecx
  802b72:	ba 20 00 00 00       	mov    $0x20,%edx
  802b77:	29 fa                	sub    %edi,%edx
  802b79:	d3 e0                	shl    %cl,%eax
  802b7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b7f:	89 d1                	mov    %edx,%ecx
  802b81:	89 d8                	mov    %ebx,%eax
  802b83:	d3 e8                	shr    %cl,%eax
  802b85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802b89:	09 c1                	or     %eax,%ecx
  802b8b:	89 f0                	mov    %esi,%eax
  802b8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b91:	89 f9                	mov    %edi,%ecx
  802b93:	d3 e3                	shl    %cl,%ebx
  802b95:	89 d1                	mov    %edx,%ecx
  802b97:	d3 e8                	shr    %cl,%eax
  802b99:	89 f9                	mov    %edi,%ecx
  802b9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802b9f:	89 eb                	mov    %ebp,%ebx
  802ba1:	d3 e6                	shl    %cl,%esi
  802ba3:	89 d1                	mov    %edx,%ecx
  802ba5:	d3 eb                	shr    %cl,%ebx
  802ba7:	09 f3                	or     %esi,%ebx
  802ba9:	89 c6                	mov    %eax,%esi
  802bab:	89 f2                	mov    %esi,%edx
  802bad:	89 d8                	mov    %ebx,%eax
  802baf:	f7 74 24 08          	divl   0x8(%esp)
  802bb3:	89 d6                	mov    %edx,%esi
  802bb5:	89 c3                	mov    %eax,%ebx
  802bb7:	f7 64 24 0c          	mull   0xc(%esp)
  802bbb:	39 d6                	cmp    %edx,%esi
  802bbd:	72 19                	jb     802bd8 <__udivdi3+0x108>
  802bbf:	89 f9                	mov    %edi,%ecx
  802bc1:	d3 e5                	shl    %cl,%ebp
  802bc3:	39 c5                	cmp    %eax,%ebp
  802bc5:	73 04                	jae    802bcb <__udivdi3+0xfb>
  802bc7:	39 d6                	cmp    %edx,%esi
  802bc9:	74 0d                	je     802bd8 <__udivdi3+0x108>
  802bcb:	89 d8                	mov    %ebx,%eax
  802bcd:	31 ff                	xor    %edi,%edi
  802bcf:	e9 3c ff ff ff       	jmp    802b10 <__udivdi3+0x40>
  802bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bd8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802bdb:	31 ff                	xor    %edi,%edi
  802bdd:	e9 2e ff ff ff       	jmp    802b10 <__udivdi3+0x40>
  802be2:	66 90                	xchg   %ax,%ax
  802be4:	66 90                	xchg   %ax,%ax
  802be6:	66 90                	xchg   %ax,%ax
  802be8:	66 90                	xchg   %ax,%ax
  802bea:	66 90                	xchg   %ax,%ax
  802bec:	66 90                	xchg   %ax,%ax
  802bee:	66 90                	xchg   %ax,%ax

00802bf0 <__umoddi3>:
  802bf0:	f3 0f 1e fb          	endbr32 
  802bf4:	55                   	push   %ebp
  802bf5:	57                   	push   %edi
  802bf6:	56                   	push   %esi
  802bf7:	53                   	push   %ebx
  802bf8:	83 ec 1c             	sub    $0x1c,%esp
  802bfb:	8b 74 24 30          	mov    0x30(%esp),%esi
  802bff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802c03:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802c07:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  802c0b:	89 f0                	mov    %esi,%eax
  802c0d:	89 da                	mov    %ebx,%edx
  802c0f:	85 ff                	test   %edi,%edi
  802c11:	75 15                	jne    802c28 <__umoddi3+0x38>
  802c13:	39 dd                	cmp    %ebx,%ebp
  802c15:	76 39                	jbe    802c50 <__umoddi3+0x60>
  802c17:	f7 f5                	div    %ebp
  802c19:	89 d0                	mov    %edx,%eax
  802c1b:	31 d2                	xor    %edx,%edx
  802c1d:	83 c4 1c             	add    $0x1c,%esp
  802c20:	5b                   	pop    %ebx
  802c21:	5e                   	pop    %esi
  802c22:	5f                   	pop    %edi
  802c23:	5d                   	pop    %ebp
  802c24:	c3                   	ret    
  802c25:	8d 76 00             	lea    0x0(%esi),%esi
  802c28:	39 df                	cmp    %ebx,%edi
  802c2a:	77 f1                	ja     802c1d <__umoddi3+0x2d>
  802c2c:	0f bd cf             	bsr    %edi,%ecx
  802c2f:	83 f1 1f             	xor    $0x1f,%ecx
  802c32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802c36:	75 40                	jne    802c78 <__umoddi3+0x88>
  802c38:	39 df                	cmp    %ebx,%edi
  802c3a:	72 04                	jb     802c40 <__umoddi3+0x50>
  802c3c:	39 f5                	cmp    %esi,%ebp
  802c3e:	77 dd                	ja     802c1d <__umoddi3+0x2d>
  802c40:	89 da                	mov    %ebx,%edx
  802c42:	89 f0                	mov    %esi,%eax
  802c44:	29 e8                	sub    %ebp,%eax
  802c46:	19 fa                	sbb    %edi,%edx
  802c48:	eb d3                	jmp    802c1d <__umoddi3+0x2d>
  802c4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c50:	89 e9                	mov    %ebp,%ecx
  802c52:	85 ed                	test   %ebp,%ebp
  802c54:	75 0b                	jne    802c61 <__umoddi3+0x71>
  802c56:	b8 01 00 00 00       	mov    $0x1,%eax
  802c5b:	31 d2                	xor    %edx,%edx
  802c5d:	f7 f5                	div    %ebp
  802c5f:	89 c1                	mov    %eax,%ecx
  802c61:	89 d8                	mov    %ebx,%eax
  802c63:	31 d2                	xor    %edx,%edx
  802c65:	f7 f1                	div    %ecx
  802c67:	89 f0                	mov    %esi,%eax
  802c69:	f7 f1                	div    %ecx
  802c6b:	89 d0                	mov    %edx,%eax
  802c6d:	31 d2                	xor    %edx,%edx
  802c6f:	eb ac                	jmp    802c1d <__umoddi3+0x2d>
  802c71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c78:	8b 44 24 04          	mov    0x4(%esp),%eax
  802c7c:	ba 20 00 00 00       	mov    $0x20,%edx
  802c81:	29 c2                	sub    %eax,%edx
  802c83:	89 c1                	mov    %eax,%ecx
  802c85:	89 e8                	mov    %ebp,%eax
  802c87:	d3 e7                	shl    %cl,%edi
  802c89:	89 d1                	mov    %edx,%ecx
  802c8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802c8f:	d3 e8                	shr    %cl,%eax
  802c91:	89 c1                	mov    %eax,%ecx
  802c93:	8b 44 24 04          	mov    0x4(%esp),%eax
  802c97:	09 f9                	or     %edi,%ecx
  802c99:	89 df                	mov    %ebx,%edi
  802c9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c9f:	89 c1                	mov    %eax,%ecx
  802ca1:	d3 e5                	shl    %cl,%ebp
  802ca3:	89 d1                	mov    %edx,%ecx
  802ca5:	d3 ef                	shr    %cl,%edi
  802ca7:	89 c1                	mov    %eax,%ecx
  802ca9:	89 f0                	mov    %esi,%eax
  802cab:	d3 e3                	shl    %cl,%ebx
  802cad:	89 d1                	mov    %edx,%ecx
  802caf:	89 fa                	mov    %edi,%edx
  802cb1:	d3 e8                	shr    %cl,%eax
  802cb3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802cb8:	09 d8                	or     %ebx,%eax
  802cba:	f7 74 24 08          	divl   0x8(%esp)
  802cbe:	89 d3                	mov    %edx,%ebx
  802cc0:	d3 e6                	shl    %cl,%esi
  802cc2:	f7 e5                	mul    %ebp
  802cc4:	89 c7                	mov    %eax,%edi
  802cc6:	89 d1                	mov    %edx,%ecx
  802cc8:	39 d3                	cmp    %edx,%ebx
  802cca:	72 06                	jb     802cd2 <__umoddi3+0xe2>
  802ccc:	75 0e                	jne    802cdc <__umoddi3+0xec>
  802cce:	39 c6                	cmp    %eax,%esi
  802cd0:	73 0a                	jae    802cdc <__umoddi3+0xec>
  802cd2:	29 e8                	sub    %ebp,%eax
  802cd4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802cd8:	89 d1                	mov    %edx,%ecx
  802cda:	89 c7                	mov    %eax,%edi
  802cdc:	89 f5                	mov    %esi,%ebp
  802cde:	8b 74 24 04          	mov    0x4(%esp),%esi
  802ce2:	29 fd                	sub    %edi,%ebp
  802ce4:	19 cb                	sbb    %ecx,%ebx
  802ce6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802ceb:	89 d8                	mov    %ebx,%eax
  802ced:	d3 e0                	shl    %cl,%eax
  802cef:	89 f1                	mov    %esi,%ecx
  802cf1:	d3 ed                	shr    %cl,%ebp
  802cf3:	d3 eb                	shr    %cl,%ebx
  802cf5:	09 e8                	or     %ebp,%eax
  802cf7:	89 da                	mov    %ebx,%edx
  802cf9:	83 c4 1c             	add    $0x1c,%esp
  802cfc:	5b                   	pop    %ebx
  802cfd:	5e                   	pop    %esi
  802cfe:	5f                   	pop    %edi
  802cff:	5d                   	pop    %ebp
  802d00:	c3                   	ret    
