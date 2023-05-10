
obj/user/testfdsharing.debug：     文件格式 elf32-i386


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
  80002c:	e8 99 01 00 00       	call   8001ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 40 27 80 00       	push   $0x802740
  800043:	e8 ac 18 00 00       	call   8018f4 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	0f 88 ff 00 00 00    	js     800154 <umain+0x121>
		panic("open motd: %e", fd);
	seek(fd, 0);
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	6a 00                	push   $0x0
  80005a:	50                   	push   %eax
  80005b:	e8 81 15 00 00       	call   8015e1 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800060:	83 c4 0c             	add    $0xc,%esp
  800063:	68 00 02 00 00       	push   $0x200
  800068:	68 00 42 80 00       	push   $0x804200
  80006d:	53                   	push   %ebx
  80006e:	e8 a5 14 00 00       	call   801518 <readn>
  800073:	89 c6                	mov    %eax,%esi
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	85 c0                	test   %eax,%eax
  80007a:	0f 8e e6 00 00 00    	jle    800166 <umain+0x133>
		panic("readn: %e", n);

	if ((r = fork()) < 0)
  800080:	e8 a9 0f 00 00       	call   80102e <fork>
  800085:	89 c7                	mov    %eax,%edi
  800087:	85 c0                	test   %eax,%eax
  800089:	0f 88 e9 00 00 00    	js     800178 <umain+0x145>
		panic("fork: %e", r);
	if (r == 0) {
  80008f:	75 7b                	jne    80010c <umain+0xd9>
		seek(fd, 0);
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	6a 00                	push   $0x0
  800096:	53                   	push   %ebx
  800097:	e8 45 15 00 00       	call   8015e1 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  80009c:	c7 04 24 a8 27 80 00 	movl   $0x8027a8,(%esp)
  8000a3:	e8 60 02 00 00       	call   800308 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	68 00 02 00 00       	push   $0x200
  8000b0:	68 00 40 80 00       	push   $0x804000
  8000b5:	53                   	push   %ebx
  8000b6:	e8 5d 14 00 00       	call   801518 <readn>
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	39 c6                	cmp    %eax,%esi
  8000c0:	0f 85 c4 00 00 00    	jne    80018a <umain+0x157>
			panic("read in parent got %d, read in child got %d", n, n2);
		if (memcmp(buf, buf2, n) != 0)
  8000c6:	83 ec 04             	sub    $0x4,%esp
  8000c9:	56                   	push   %esi
  8000ca:	68 00 40 80 00       	push   $0x804000
  8000cf:	68 00 42 80 00       	push   $0x804200
  8000d4:	e8 17 0a 00 00       	call   800af0 <memcmp>
  8000d9:	83 c4 10             	add    $0x10,%esp
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	0f 85 bc 00 00 00    	jne    8001a0 <umain+0x16d>
			panic("read in parent got different bytes from read in child");
		cprintf("read in child succeeded\n");
  8000e4:	83 ec 0c             	sub    $0xc,%esp
  8000e7:	68 72 27 80 00       	push   $0x802772
  8000ec:	e8 17 02 00 00       	call   800308 <cprintf>
		seek(fd, 0);
  8000f1:	83 c4 08             	add    $0x8,%esp
  8000f4:	6a 00                	push   $0x0
  8000f6:	53                   	push   %ebx
  8000f7:	e8 e5 14 00 00       	call   8015e1 <seek>
		close(fd);
  8000fc:	89 1c 24             	mov    %ebx,(%esp)
  8000ff:	e8 51 12 00 00       	call   801355 <close>
		exit();
  800104:	e8 0a 01 00 00       	call   800213 <exit>
  800109:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80010c:	83 ec 0c             	sub    $0xc,%esp
  80010f:	57                   	push   %edi
  800110:	e8 36 20 00 00       	call   80214b <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800115:	83 c4 0c             	add    $0xc,%esp
  800118:	68 00 02 00 00       	push   $0x200
  80011d:	68 00 40 80 00       	push   $0x804000
  800122:	53                   	push   %ebx
  800123:	e8 f0 13 00 00       	call   801518 <readn>
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	39 c6                	cmp    %eax,%esi
  80012d:	0f 85 81 00 00 00    	jne    8001b4 <umain+0x181>
		panic("read in parent got %d, then got %d", n, n2);
	cprintf("read in parent succeeded\n");
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	68 8b 27 80 00       	push   $0x80278b
  80013b:	e8 c8 01 00 00       	call   800308 <cprintf>
	close(fd);
  800140:	89 1c 24             	mov    %ebx,(%esp)
  800143:	e8 0d 12 00 00       	call   801355 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800148:	cc                   	int3   

	breakpoint();
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5f                   	pop    %edi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    
		panic("open motd: %e", fd);
  800154:	50                   	push   %eax
  800155:	68 45 27 80 00       	push   $0x802745
  80015a:	6a 0c                	push   $0xc
  80015c:	68 53 27 80 00       	push   $0x802753
  800161:	e8 c7 00 00 00       	call   80022d <_panic>
		panic("readn: %e", n);
  800166:	50                   	push   %eax
  800167:	68 68 27 80 00       	push   $0x802768
  80016c:	6a 0f                	push   $0xf
  80016e:	68 53 27 80 00       	push   $0x802753
  800173:	e8 b5 00 00 00       	call   80022d <_panic>
		panic("fork: %e", r);
  800178:	50                   	push   %eax
  800179:	68 78 2c 80 00       	push   $0x802c78
  80017e:	6a 12                	push   $0x12
  800180:	68 53 27 80 00       	push   $0x802753
  800185:	e8 a3 00 00 00       	call   80022d <_panic>
			panic("read in parent got %d, read in child got %d", n, n2);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	56                   	push   %esi
  80018f:	68 ec 27 80 00       	push   $0x8027ec
  800194:	6a 17                	push   $0x17
  800196:	68 53 27 80 00       	push   $0x802753
  80019b:	e8 8d 00 00 00       	call   80022d <_panic>
			panic("read in parent got different bytes from read in child");
  8001a0:	83 ec 04             	sub    $0x4,%esp
  8001a3:	68 18 28 80 00       	push   $0x802818
  8001a8:	6a 19                	push   $0x19
  8001aa:	68 53 27 80 00       	push   $0x802753
  8001af:	e8 79 00 00 00       	call   80022d <_panic>
		panic("read in parent got %d, then got %d", n, n2);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	50                   	push   %eax
  8001b8:	56                   	push   %esi
  8001b9:	68 50 28 80 00       	push   $0x802850
  8001be:	6a 21                	push   $0x21
  8001c0:	68 53 27 80 00       	push   $0x802753
  8001c5:	e8 63 00 00 00       	call   80022d <_panic>

008001ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8001d5:	e8 c6 0a 00 00       	call   800ca0 <sys_getenvid>
  8001da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001df:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8001e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ea:	a3 00 44 80 00       	mov    %eax,0x804400

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ef:	85 db                	test   %ebx,%ebx
  8001f1:	7e 07                	jle    8001fa <libmain+0x30>
		binaryname = argv[0];
  8001f3:	8b 06                	mov    (%esi),%eax
  8001f5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	56                   	push   %esi
  8001fe:	53                   	push   %ebx
  8001ff:	e8 2f fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800204:	e8 0a 00 00 00       	call   800213 <exit>
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    

00800213 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800219:	e8 64 11 00 00       	call   801382 <close_all>
	sys_env_destroy(0);
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	6a 00                	push   $0x0
  800223:	e8 37 0a 00 00       	call   800c5f <sys_env_destroy>
}
  800228:	83 c4 10             	add    $0x10,%esp
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800232:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800235:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023b:	e8 60 0a 00 00       	call   800ca0 <sys_getenvid>
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 0c             	push   0xc(%ebp)
  800246:	ff 75 08             	push   0x8(%ebp)
  800249:	56                   	push   %esi
  80024a:	50                   	push   %eax
  80024b:	68 80 28 80 00       	push   $0x802880
  800250:	e8 b3 00 00 00       	call   800308 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800255:	83 c4 18             	add    $0x18,%esp
  800258:	53                   	push   %ebx
  800259:	ff 75 10             	push   0x10(%ebp)
  80025c:	e8 56 00 00 00       	call   8002b7 <vcprintf>
	cprintf("\n");
  800261:	c7 04 24 89 27 80 00 	movl   $0x802789,(%esp)
  800268:	e8 9b 00 00 00       	call   800308 <cprintf>
  80026d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800270:	cc                   	int3   
  800271:	eb fd                	jmp    800270 <_panic+0x43>

00800273 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	53                   	push   %ebx
  800277:	83 ec 04             	sub    $0x4,%esp
  80027a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027d:	8b 13                	mov    (%ebx),%edx
  80027f:	8d 42 01             	lea    0x1(%edx),%eax
  800282:	89 03                	mov    %eax,(%ebx)
  800284:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800287:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800290:	74 09                	je     80029b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800292:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800299:	c9                   	leave  
  80029a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 76 09 00 00       	call   800c22 <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
  8002b5:	eb db                	jmp    800292 <putch+0x1f>

008002b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c7:	00 00 00 
	b.cnt = 0;
  8002ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d4:	ff 75 0c             	push   0xc(%ebp)
  8002d7:	ff 75 08             	push   0x8(%ebp)
  8002da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e0:	50                   	push   %eax
  8002e1:	68 73 02 80 00       	push   $0x800273
  8002e6:	e8 14 01 00 00       	call   8003ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002eb:	83 c4 08             	add    $0x8,%esp
  8002ee:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fa:	50                   	push   %eax
  8002fb:	e8 22 09 00 00       	call   800c22 <sys_cputs>

	return b.cnt;
}
  800300:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 08             	push   0x8(%ebp)
  800315:	e8 9d ff ff ff       	call   8002b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	57                   	push   %edi
  800320:	56                   	push   %esi
  800321:	53                   	push   %ebx
  800322:	83 ec 1c             	sub    $0x1c,%esp
  800325:	89 c7                	mov    %eax,%edi
  800327:	89 d6                	mov    %edx,%esi
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032f:	89 d1                	mov    %edx,%ecx
  800331:	89 c2                	mov    %eax,%edx
  800333:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800336:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800339:	8b 45 10             	mov    0x10(%ebp),%eax
  80033c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800342:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800349:	39 c2                	cmp    %eax,%edx
  80034b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80034e:	72 3e                	jb     80038e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	ff 75 18             	push   0x18(%ebp)
  800356:	83 eb 01             	sub    $0x1,%ebx
  800359:	53                   	push   %ebx
  80035a:	50                   	push   %eax
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	ff 75 e4             	push   -0x1c(%ebp)
  800361:	ff 75 e0             	push   -0x20(%ebp)
  800364:	ff 75 dc             	push   -0x24(%ebp)
  800367:	ff 75 d8             	push   -0x28(%ebp)
  80036a:	e8 81 21 00 00       	call   8024f0 <__udivdi3>
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	52                   	push   %edx
  800373:	50                   	push   %eax
  800374:	89 f2                	mov    %esi,%edx
  800376:	89 f8                	mov    %edi,%eax
  800378:	e8 9f ff ff ff       	call   80031c <printnum>
  80037d:	83 c4 20             	add    $0x20,%esp
  800380:	eb 13                	jmp    800395 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	56                   	push   %esi
  800386:	ff 75 18             	push   0x18(%ebp)
  800389:	ff d7                	call   *%edi
  80038b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80038e:	83 eb 01             	sub    $0x1,%ebx
  800391:	85 db                	test   %ebx,%ebx
  800393:	7f ed                	jg     800382 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	56                   	push   %esi
  800399:	83 ec 04             	sub    $0x4,%esp
  80039c:	ff 75 e4             	push   -0x1c(%ebp)
  80039f:	ff 75 e0             	push   -0x20(%ebp)
  8003a2:	ff 75 dc             	push   -0x24(%ebp)
  8003a5:	ff 75 d8             	push   -0x28(%ebp)
  8003a8:	e8 63 22 00 00       	call   802610 <__umoddi3>
  8003ad:	83 c4 14             	add    $0x14,%esp
  8003b0:	0f be 80 a3 28 80 00 	movsbl 0x8028a3(%eax),%eax
  8003b7:	50                   	push   %eax
  8003b8:	ff d7                	call   *%edi
}
  8003ba:	83 c4 10             	add    $0x10,%esp
  8003bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c0:	5b                   	pop    %ebx
  8003c1:	5e                   	pop    %esi
  8003c2:	5f                   	pop    %edi
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003cb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d4:	73 0a                	jae    8003e0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d9:	89 08                	mov    %ecx,(%eax)
  8003db:	8b 45 08             	mov    0x8(%ebp),%eax
  8003de:	88 02                	mov    %al,(%edx)
}
  8003e0:	5d                   	pop    %ebp
  8003e1:	c3                   	ret    

008003e2 <printfmt>:
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003eb:	50                   	push   %eax
  8003ec:	ff 75 10             	push   0x10(%ebp)
  8003ef:	ff 75 0c             	push   0xc(%ebp)
  8003f2:	ff 75 08             	push   0x8(%ebp)
  8003f5:	e8 05 00 00 00       	call   8003ff <vprintfmt>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <vprintfmt>:
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 3c             	sub    $0x3c,%esp
  800408:	8b 75 08             	mov    0x8(%ebp),%esi
  80040b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80040e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800411:	eb 0a                	jmp    80041d <vprintfmt+0x1e>
			putch(ch, putdat);
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	53                   	push   %ebx
  800417:	50                   	push   %eax
  800418:	ff d6                	call   *%esi
  80041a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041d:	83 c7 01             	add    $0x1,%edi
  800420:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800424:	83 f8 25             	cmp    $0x25,%eax
  800427:	74 0c                	je     800435 <vprintfmt+0x36>
			if (ch == '\0')
  800429:	85 c0                	test   %eax,%eax
  80042b:	75 e6                	jne    800413 <vprintfmt+0x14>
}
  80042d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800430:	5b                   	pop    %ebx
  800431:	5e                   	pop    %esi
  800432:	5f                   	pop    %edi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    
		padc = ' ';
  800435:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800439:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800440:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800447:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80044e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8d 47 01             	lea    0x1(%edi),%eax
  800456:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800459:	0f b6 17             	movzbl (%edi),%edx
  80045c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80045f:	3c 55                	cmp    $0x55,%al
  800461:	0f 87 bb 03 00 00    	ja     800822 <vprintfmt+0x423>
  800467:	0f b6 c0             	movzbl %al,%eax
  80046a:	ff 24 85 e0 29 80 00 	jmp    *0x8029e0(,%eax,4)
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800474:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800478:	eb d9                	jmp    800453 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800481:	eb d0                	jmp    800453 <vprintfmt+0x54>
  800483:	0f b6 d2             	movzbl %dl,%edx
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800489:	b8 00 00 00 00       	mov    $0x0,%eax
  80048e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800491:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800494:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800498:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80049b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80049e:	83 f9 09             	cmp    $0x9,%ecx
  8004a1:	77 55                	ja     8004f8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8004a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004a6:	eb e9                	jmp    800491 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 40 04             	lea    0x4(%eax),%eax
  8004b6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c0:	79 91                	jns    800453 <vprintfmt+0x54>
				width = precision, precision = -1;
  8004c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004cf:	eb 82                	jmp    800453 <vprintfmt+0x54>
  8004d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d4:	85 d2                	test   %edx,%edx
  8004d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004db:	0f 49 c2             	cmovns %edx,%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004e4:	e9 6a ff ff ff       	jmp    800453 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004ec:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004f3:	e9 5b ff ff ff       	jmp    800453 <vprintfmt+0x54>
  8004f8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fe:	eb bc                	jmp    8004bc <vprintfmt+0xbd>
			lflag++;
  800500:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800506:	e9 48 ff ff ff       	jmp    800453 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 78 04             	lea    0x4(%eax),%edi
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	ff 30                	push   (%eax)
  800517:	ff d6                	call   *%esi
			break;
  800519:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80051c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80051f:	e9 9d 02 00 00       	jmp    8007c1 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 78 04             	lea    0x4(%eax),%edi
  80052a:	8b 10                	mov    (%eax),%edx
  80052c:	89 d0                	mov    %edx,%eax
  80052e:	f7 d8                	neg    %eax
  800530:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800533:	83 f8 0f             	cmp    $0xf,%eax
  800536:	7f 23                	jg     80055b <vprintfmt+0x15c>
  800538:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  80053f:	85 d2                	test   %edx,%edx
  800541:	74 18                	je     80055b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800543:	52                   	push   %edx
  800544:	68 41 2d 80 00       	push   $0x802d41
  800549:	53                   	push   %ebx
  80054a:	56                   	push   %esi
  80054b:	e8 92 fe ff ff       	call   8003e2 <printfmt>
  800550:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800553:	89 7d 14             	mov    %edi,0x14(%ebp)
  800556:	e9 66 02 00 00       	jmp    8007c1 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80055b:	50                   	push   %eax
  80055c:	68 bb 28 80 00       	push   $0x8028bb
  800561:	53                   	push   %ebx
  800562:	56                   	push   %esi
  800563:	e8 7a fe ff ff       	call   8003e2 <printfmt>
  800568:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80056b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80056e:	e9 4e 02 00 00       	jmp    8007c1 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	83 c0 04             	add    $0x4,%eax
  800579:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800581:	85 d2                	test   %edx,%edx
  800583:	b8 b4 28 80 00       	mov    $0x8028b4,%eax
  800588:	0f 45 c2             	cmovne %edx,%eax
  80058b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80058e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800592:	7e 06                	jle    80059a <vprintfmt+0x19b>
  800594:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800598:	75 0d                	jne    8005a7 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80059d:	89 c7                	mov    %eax,%edi
  80059f:	03 45 e0             	add    -0x20(%ebp),%eax
  8005a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a5:	eb 55                	jmp    8005fc <vprintfmt+0x1fd>
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 d8             	push   -0x28(%ebp)
  8005ad:	ff 75 cc             	push   -0x34(%ebp)
  8005b0:	e8 0a 03 00 00       	call   8008bf <strnlen>
  8005b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b8:	29 c1                	sub    %eax,%ecx
  8005ba:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8005c2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c9:	eb 0f                	jmp    8005da <vprintfmt+0x1db>
					putch(padc, putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	ff 75 e0             	push   -0x20(%ebp)
  8005d2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	83 ef 01             	sub    $0x1,%edi
  8005d7:	83 c4 10             	add    $0x10,%esp
  8005da:	85 ff                	test   %edi,%edi
  8005dc:	7f ed                	jg     8005cb <vprintfmt+0x1cc>
  8005de:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005e1:	85 d2                	test   %edx,%edx
  8005e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e8:	0f 49 c2             	cmovns %edx,%eax
  8005eb:	29 c2                	sub    %eax,%edx
  8005ed:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f0:	eb a8                	jmp    80059a <vprintfmt+0x19b>
					putch(ch, putdat);
  8005f2:	83 ec 08             	sub    $0x8,%esp
  8005f5:	53                   	push   %ebx
  8005f6:	52                   	push   %edx
  8005f7:	ff d6                	call   *%esi
  8005f9:	83 c4 10             	add    $0x10,%esp
  8005fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ff:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800601:	83 c7 01             	add    $0x1,%edi
  800604:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800608:	0f be d0             	movsbl %al,%edx
  80060b:	85 d2                	test   %edx,%edx
  80060d:	74 4b                	je     80065a <vprintfmt+0x25b>
  80060f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800613:	78 06                	js     80061b <vprintfmt+0x21c>
  800615:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800619:	78 1e                	js     800639 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80061b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80061f:	74 d1                	je     8005f2 <vprintfmt+0x1f3>
  800621:	0f be c0             	movsbl %al,%eax
  800624:	83 e8 20             	sub    $0x20,%eax
  800627:	83 f8 5e             	cmp    $0x5e,%eax
  80062a:	76 c6                	jbe    8005f2 <vprintfmt+0x1f3>
					putch('?', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 3f                	push   $0x3f
  800632:	ff d6                	call   *%esi
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb c3                	jmp    8005fc <vprintfmt+0x1fd>
  800639:	89 cf                	mov    %ecx,%edi
  80063b:	eb 0e                	jmp    80064b <vprintfmt+0x24c>
				putch(' ', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	6a 20                	push   $0x20
  800643:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800645:	83 ef 01             	sub    $0x1,%edi
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	85 ff                	test   %edi,%edi
  80064d:	7f ee                	jg     80063d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80064f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
  800655:	e9 67 01 00 00       	jmp    8007c1 <vprintfmt+0x3c2>
  80065a:	89 cf                	mov    %ecx,%edi
  80065c:	eb ed                	jmp    80064b <vprintfmt+0x24c>
	if (lflag >= 2)
  80065e:	83 f9 01             	cmp    $0x1,%ecx
  800661:	7f 1b                	jg     80067e <vprintfmt+0x27f>
	else if (lflag)
  800663:	85 c9                	test   %ecx,%ecx
  800665:	74 63                	je     8006ca <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 00                	mov    (%eax),%eax
  80066c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066f:	99                   	cltd   
  800670:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
  80067c:	eb 17                	jmp    800695 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 50 04             	mov    0x4(%eax),%edx
  800684:	8b 00                	mov    (%eax),%eax
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 40 08             	lea    0x8(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800695:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800698:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80069b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8006a0:	85 c9                	test   %ecx,%ecx
  8006a2:	0f 89 ff 00 00 00    	jns    8007a7 <vprintfmt+0x3a8>
				putch('-', putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	6a 2d                	push   $0x2d
  8006ae:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b6:	f7 da                	neg    %edx
  8006b8:	83 d1 00             	adc    $0x0,%ecx
  8006bb:	f7 d9                	neg    %ecx
  8006bd:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c0:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006c5:	e9 dd 00 00 00       	jmp    8007a7 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 00                	mov    (%eax),%eax
  8006cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d2:	99                   	cltd   
  8006d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 40 04             	lea    0x4(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8006df:	eb b4                	jmp    800695 <vprintfmt+0x296>
	if (lflag >= 2)
  8006e1:	83 f9 01             	cmp    $0x1,%ecx
  8006e4:	7f 1e                	jg     800704 <vprintfmt+0x305>
	else if (lflag)
  8006e6:	85 c9                	test   %ecx,%ecx
  8006e8:	74 32                	je     80071c <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8b 10                	mov    (%eax),%edx
  8006ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f4:	8d 40 04             	lea    0x4(%eax),%eax
  8006f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006fa:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8006ff:	e9 a3 00 00 00       	jmp    8007a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8b 10                	mov    (%eax),%edx
  800709:	8b 48 04             	mov    0x4(%eax),%ecx
  80070c:	8d 40 08             	lea    0x8(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800712:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800717:	e9 8b 00 00 00       	jmp    8007a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	b9 00 00 00 00       	mov    $0x0,%ecx
  800726:	8d 40 04             	lea    0x4(%eax),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80072c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800731:	eb 74                	jmp    8007a7 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800733:	83 f9 01             	cmp    $0x1,%ecx
  800736:	7f 1b                	jg     800753 <vprintfmt+0x354>
	else if (lflag)
  800738:	85 c9                	test   %ecx,%ecx
  80073a:	74 2c                	je     800768 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 10                	mov    (%eax),%edx
  800741:	b9 00 00 00 00       	mov    $0x0,%ecx
  800746:	8d 40 04             	lea    0x4(%eax),%eax
  800749:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80074c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800751:	eb 54                	jmp    8007a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8b 10                	mov    (%eax),%edx
  800758:	8b 48 04             	mov    0x4(%eax),%ecx
  80075b:	8d 40 08             	lea    0x8(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800761:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800766:	eb 3f                	jmp    8007a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 10                	mov    (%eax),%edx
  80076d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800772:	8d 40 04             	lea    0x4(%eax),%eax
  800775:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800778:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80077d:	eb 28                	jmp    8007a7 <vprintfmt+0x3a8>
			putch('0', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 30                	push   $0x30
  800785:	ff d6                	call   *%esi
			putch('x', putdat);
  800787:	83 c4 08             	add    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	6a 78                	push   $0x78
  80078d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8b 10                	mov    (%eax),%edx
  800794:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800799:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80079c:	8d 40 04             	lea    0x4(%eax),%eax
  80079f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a2:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007a7:	83 ec 0c             	sub    $0xc,%esp
  8007aa:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8007ae:	50                   	push   %eax
  8007af:	ff 75 e0             	push   -0x20(%ebp)
  8007b2:	57                   	push   %edi
  8007b3:	51                   	push   %ecx
  8007b4:	52                   	push   %edx
  8007b5:	89 da                	mov    %ebx,%edx
  8007b7:	89 f0                	mov    %esi,%eax
  8007b9:	e8 5e fb ff ff       	call   80031c <printnum>
			break;
  8007be:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c4:	e9 54 fc ff ff       	jmp    80041d <vprintfmt+0x1e>
	if (lflag >= 2)
  8007c9:	83 f9 01             	cmp    $0x1,%ecx
  8007cc:	7f 1b                	jg     8007e9 <vprintfmt+0x3ea>
	else if (lflag)
  8007ce:	85 c9                	test   %ecx,%ecx
  8007d0:	74 2c                	je     8007fe <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 10                	mov    (%eax),%edx
  8007d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007dc:	8d 40 04             	lea    0x4(%eax),%eax
  8007df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8007e7:	eb be                	jmp    8007a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8b 10                	mov    (%eax),%edx
  8007ee:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f1:	8d 40 08             	lea    0x8(%eax),%eax
  8007f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8007fc:	eb a9                	jmp    8007a7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8b 10                	mov    (%eax),%edx
  800803:	b9 00 00 00 00       	mov    $0x0,%ecx
  800808:	8d 40 04             	lea    0x4(%eax),%eax
  80080b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800813:	eb 92                	jmp    8007a7 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800815:	83 ec 08             	sub    $0x8,%esp
  800818:	53                   	push   %ebx
  800819:	6a 25                	push   $0x25
  80081b:	ff d6                	call   *%esi
			break;
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	eb 9f                	jmp    8007c1 <vprintfmt+0x3c2>
			putch('%', putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	53                   	push   %ebx
  800826:	6a 25                	push   $0x25
  800828:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	89 f8                	mov    %edi,%eax
  80082f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800833:	74 05                	je     80083a <vprintfmt+0x43b>
  800835:	83 e8 01             	sub    $0x1,%eax
  800838:	eb f5                	jmp    80082f <vprintfmt+0x430>
  80083a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80083d:	eb 82                	jmp    8007c1 <vprintfmt+0x3c2>

0080083f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	83 ec 18             	sub    $0x18,%esp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800852:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085c:	85 c0                	test   %eax,%eax
  80085e:	74 26                	je     800886 <vsnprintf+0x47>
  800860:	85 d2                	test   %edx,%edx
  800862:	7e 22                	jle    800886 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800864:	ff 75 14             	push   0x14(%ebp)
  800867:	ff 75 10             	push   0x10(%ebp)
  80086a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	68 c5 03 80 00       	push   $0x8003c5
  800873:	e8 87 fb ff ff       	call   8003ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	83 c4 10             	add    $0x10,%esp
}
  800884:	c9                   	leave  
  800885:	c3                   	ret    
		return -E_INVAL;
  800886:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088b:	eb f7                	jmp    800884 <vsnprintf+0x45>

0080088d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800893:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800896:	50                   	push   %eax
  800897:	ff 75 10             	push   0x10(%ebp)
  80089a:	ff 75 0c             	push   0xc(%ebp)
  80089d:	ff 75 08             	push   0x8(%ebp)
  8008a0:	e8 9a ff ff ff       	call   80083f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b2:	eb 03                	jmp    8008b7 <strlen+0x10>
		n++;
  8008b4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008b7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008bb:	75 f7                	jne    8008b4 <strlen+0xd>
	return n;
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cd:	eb 03                	jmp    8008d2 <strnlen+0x13>
		n++;
  8008cf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d2:	39 d0                	cmp    %edx,%eax
  8008d4:	74 08                	je     8008de <strnlen+0x1f>
  8008d6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008da:	75 f3                	jne    8008cf <strnlen+0x10>
  8008dc:	89 c2                	mov    %eax,%edx
	return n;
}
  8008de:	89 d0                	mov    %edx,%eax
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008f5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008f8:	83 c0 01             	add    $0x1,%eax
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	75 f2                	jne    8008f1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ff:	89 c8                	mov    %ecx,%eax
  800901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	53                   	push   %ebx
  80090a:	83 ec 10             	sub    $0x10,%esp
  80090d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800910:	53                   	push   %ebx
  800911:	e8 91 ff ff ff       	call   8008a7 <strlen>
  800916:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800919:	ff 75 0c             	push   0xc(%ebp)
  80091c:	01 d8                	add    %ebx,%eax
  80091e:	50                   	push   %eax
  80091f:	e8 be ff ff ff       	call   8008e2 <strcpy>
	return dst;
}
  800924:	89 d8                	mov    %ebx,%eax
  800926:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 75 08             	mov    0x8(%ebp),%esi
  800933:	8b 55 0c             	mov    0xc(%ebp),%edx
  800936:	89 f3                	mov    %esi,%ebx
  800938:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093b:	89 f0                	mov    %esi,%eax
  80093d:	eb 0f                	jmp    80094e <strncpy+0x23>
		*dst++ = *src;
  80093f:	83 c0 01             	add    $0x1,%eax
  800942:	0f b6 0a             	movzbl (%edx),%ecx
  800945:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800948:	80 f9 01             	cmp    $0x1,%cl
  80094b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80094e:	39 d8                	cmp    %ebx,%eax
  800950:	75 ed                	jne    80093f <strncpy+0x14>
	}
	return ret;
}
  800952:	89 f0                	mov    %esi,%eax
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 75 08             	mov    0x8(%ebp),%esi
  800960:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800963:	8b 55 10             	mov    0x10(%ebp),%edx
  800966:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800968:	85 d2                	test   %edx,%edx
  80096a:	74 21                	je     80098d <strlcpy+0x35>
  80096c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800970:	89 f2                	mov    %esi,%edx
  800972:	eb 09                	jmp    80097d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800974:	83 c1 01             	add    $0x1,%ecx
  800977:	83 c2 01             	add    $0x1,%edx
  80097a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80097d:	39 c2                	cmp    %eax,%edx
  80097f:	74 09                	je     80098a <strlcpy+0x32>
  800981:	0f b6 19             	movzbl (%ecx),%ebx
  800984:	84 db                	test   %bl,%bl
  800986:	75 ec                	jne    800974 <strlcpy+0x1c>
  800988:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80098a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098d:	29 f0                	sub    %esi,%eax
}
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099c:	eb 06                	jmp    8009a4 <strcmp+0x11>
		p++, q++;
  80099e:	83 c1 01             	add    $0x1,%ecx
  8009a1:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a4:	0f b6 01             	movzbl (%ecx),%eax
  8009a7:	84 c0                	test   %al,%al
  8009a9:	74 04                	je     8009af <strcmp+0x1c>
  8009ab:	3a 02                	cmp    (%edx),%al
  8009ad:	74 ef                	je     80099e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009af:	0f b6 c0             	movzbl %al,%eax
  8009b2:	0f b6 12             	movzbl (%edx),%edx
  8009b5:	29 d0                	sub    %edx,%eax
}
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	89 c3                	mov    %eax,%ebx
  8009c5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c8:	eb 06                	jmp    8009d0 <strncmp+0x17>
		n--, p++, q++;
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d0:	39 d8                	cmp    %ebx,%eax
  8009d2:	74 18                	je     8009ec <strncmp+0x33>
  8009d4:	0f b6 08             	movzbl (%eax),%ecx
  8009d7:	84 c9                	test   %cl,%cl
  8009d9:	74 04                	je     8009df <strncmp+0x26>
  8009db:	3a 0a                	cmp    (%edx),%cl
  8009dd:	74 eb                	je     8009ca <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009df:	0f b6 00             	movzbl (%eax),%eax
  8009e2:	0f b6 12             	movzbl (%edx),%edx
  8009e5:	29 d0                	sub    %edx,%eax
}
  8009e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    
		return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb f4                	jmp    8009e7 <strncmp+0x2e>

008009f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fd:	eb 03                	jmp    800a02 <strchr+0xf>
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	0f b6 10             	movzbl (%eax),%edx
  800a05:	84 d2                	test   %dl,%dl
  800a07:	74 06                	je     800a0f <strchr+0x1c>
		if (*s == c)
  800a09:	38 ca                	cmp    %cl,%dl
  800a0b:	75 f2                	jne    8009ff <strchr+0xc>
  800a0d:	eb 05                	jmp    800a14 <strchr+0x21>
			return (char *) s;
	return 0;
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a20:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a23:	38 ca                	cmp    %cl,%dl
  800a25:	74 09                	je     800a30 <strfind+0x1a>
  800a27:	84 d2                	test   %dl,%dl
  800a29:	74 05                	je     800a30 <strfind+0x1a>
	for (; *s; s++)
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	eb f0                	jmp    800a20 <strfind+0xa>
			break;
	return (char *) s;
}
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	57                   	push   %edi
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3e:	85 c9                	test   %ecx,%ecx
  800a40:	74 2f                	je     800a71 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a42:	89 f8                	mov    %edi,%eax
  800a44:	09 c8                	or     %ecx,%eax
  800a46:	a8 03                	test   $0x3,%al
  800a48:	75 21                	jne    800a6b <memset+0x39>
		c &= 0xFF;
  800a4a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4e:	89 d0                	mov    %edx,%eax
  800a50:	c1 e0 08             	shl    $0x8,%eax
  800a53:	89 d3                	mov    %edx,%ebx
  800a55:	c1 e3 18             	shl    $0x18,%ebx
  800a58:	89 d6                	mov    %edx,%esi
  800a5a:	c1 e6 10             	shl    $0x10,%esi
  800a5d:	09 f3                	or     %esi,%ebx
  800a5f:	09 da                	or     %ebx,%edx
  800a61:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a63:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a66:	fc                   	cld    
  800a67:	f3 ab                	rep stos %eax,%es:(%edi)
  800a69:	eb 06                	jmp    800a71 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	fc                   	cld    
  800a6f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a71:	89 f8                	mov    %edi,%eax
  800a73:	5b                   	pop    %ebx
  800a74:	5e                   	pop    %esi
  800a75:	5f                   	pop    %edi
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a86:	39 c6                	cmp    %eax,%esi
  800a88:	73 32                	jae    800abc <memmove+0x44>
  800a8a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8d:	39 c2                	cmp    %eax,%edx
  800a8f:	76 2b                	jbe    800abc <memmove+0x44>
		s += n;
		d += n;
  800a91:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	09 fe                	or     %edi,%esi
  800a98:	09 ce                	or     %ecx,%esi
  800a9a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa0:	75 0e                	jne    800ab0 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa2:	83 ef 04             	sub    $0x4,%edi
  800aa5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aab:	fd                   	std    
  800aac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aae:	eb 09                	jmp    800ab9 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab0:	83 ef 01             	sub    $0x1,%edi
  800ab3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ab6:	fd                   	std    
  800ab7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab9:	fc                   	cld    
  800aba:	eb 1a                	jmp    800ad6 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abc:	89 f2                	mov    %esi,%edx
  800abe:	09 c2                	or     %eax,%edx
  800ac0:	09 ca                	or     %ecx,%edx
  800ac2:	f6 c2 03             	test   $0x3,%dl
  800ac5:	75 0a                	jne    800ad1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aca:	89 c7                	mov    %eax,%edi
  800acc:	fc                   	cld    
  800acd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acf:	eb 05                	jmp    800ad6 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ad1:	89 c7                	mov    %eax,%edi
  800ad3:	fc                   	cld    
  800ad4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae0:	ff 75 10             	push   0x10(%ebp)
  800ae3:	ff 75 0c             	push   0xc(%ebp)
  800ae6:	ff 75 08             	push   0x8(%ebp)
  800ae9:	e8 8a ff ff ff       	call   800a78 <memmove>
}
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afb:	89 c6                	mov    %eax,%esi
  800afd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b00:	eb 06                	jmp    800b08 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b08:	39 f0                	cmp    %esi,%eax
  800b0a:	74 14                	je     800b20 <memcmp+0x30>
		if (*s1 != *s2)
  800b0c:	0f b6 08             	movzbl (%eax),%ecx
  800b0f:	0f b6 1a             	movzbl (%edx),%ebx
  800b12:	38 d9                	cmp    %bl,%cl
  800b14:	74 ec                	je     800b02 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b16:	0f b6 c1             	movzbl %cl,%eax
  800b19:	0f b6 db             	movzbl %bl,%ebx
  800b1c:	29 d8                	sub    %ebx,%eax
  800b1e:	eb 05                	jmp    800b25 <memcmp+0x35>
	}

	return 0;
  800b20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b32:	89 c2                	mov    %eax,%edx
  800b34:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b37:	eb 03                	jmp    800b3c <memfind+0x13>
  800b39:	83 c0 01             	add    $0x1,%eax
  800b3c:	39 d0                	cmp    %edx,%eax
  800b3e:	73 04                	jae    800b44 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b40:	38 08                	cmp    %cl,(%eax)
  800b42:	75 f5                	jne    800b39 <memfind+0x10>
			break;
	return (void *) s;
}
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b52:	eb 03                	jmp    800b57 <strtol+0x11>
		s++;
  800b54:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b57:	0f b6 02             	movzbl (%edx),%eax
  800b5a:	3c 20                	cmp    $0x20,%al
  800b5c:	74 f6                	je     800b54 <strtol+0xe>
  800b5e:	3c 09                	cmp    $0x9,%al
  800b60:	74 f2                	je     800b54 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b62:	3c 2b                	cmp    $0x2b,%al
  800b64:	74 2a                	je     800b90 <strtol+0x4a>
	int neg = 0;
  800b66:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b6b:	3c 2d                	cmp    $0x2d,%al
  800b6d:	74 2b                	je     800b9a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b75:	75 0f                	jne    800b86 <strtol+0x40>
  800b77:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7a:	74 28                	je     800ba4 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7c:	85 db                	test   %ebx,%ebx
  800b7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b83:	0f 44 d8             	cmove  %eax,%ebx
  800b86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b8e:	eb 46                	jmp    800bd6 <strtol+0x90>
		s++;
  800b90:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b93:	bf 00 00 00 00       	mov    $0x0,%edi
  800b98:	eb d5                	jmp    800b6f <strtol+0x29>
		s++, neg = 1;
  800b9a:	83 c2 01             	add    $0x1,%edx
  800b9d:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba2:	eb cb                	jmp    800b6f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba4:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba8:	74 0e                	je     800bb8 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800baa:	85 db                	test   %ebx,%ebx
  800bac:	75 d8                	jne    800b86 <strtol+0x40>
		s++, base = 8;
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb6:	eb ce                	jmp    800b86 <strtol+0x40>
		s += 2, base = 16;
  800bb8:	83 c2 02             	add    $0x2,%edx
  800bbb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc0:	eb c4                	jmp    800b86 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bc2:	0f be c0             	movsbl %al,%eax
  800bc5:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc8:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bcb:	7d 3a                	jge    800c07 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bd4:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bd6:	0f b6 02             	movzbl (%edx),%eax
  800bd9:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bdc:	89 f3                	mov    %esi,%ebx
  800bde:	80 fb 09             	cmp    $0x9,%bl
  800be1:	76 df                	jbe    800bc2 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800be3:	8d 70 9f             	lea    -0x61(%eax),%esi
  800be6:	89 f3                	mov    %esi,%ebx
  800be8:	80 fb 19             	cmp    $0x19,%bl
  800beb:	77 08                	ja     800bf5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bed:	0f be c0             	movsbl %al,%eax
  800bf0:	83 e8 57             	sub    $0x57,%eax
  800bf3:	eb d3                	jmp    800bc8 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bf5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bf8:	89 f3                	mov    %esi,%ebx
  800bfa:	80 fb 19             	cmp    $0x19,%bl
  800bfd:	77 08                	ja     800c07 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bff:	0f be c0             	movsbl %al,%eax
  800c02:	83 e8 37             	sub    $0x37,%eax
  800c05:	eb c1                	jmp    800bc8 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0b:	74 05                	je     800c12 <strtol+0xcc>
		*endptr = (char *) s;
  800c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c10:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c12:	89 c8                	mov    %ecx,%eax
  800c14:	f7 d8                	neg    %eax
  800c16:	85 ff                	test   %edi,%edi
  800c18:	0f 45 c8             	cmovne %eax,%ecx
}
  800c1b:	89 c8                	mov    %ecx,%eax
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c28:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c33:	89 c3                	mov    %eax,%ebx
  800c35:	89 c7                	mov    %eax,%edi
  800c37:	89 c6                	mov    %eax,%esi
  800c39:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c46:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c50:	89 d1                	mov    %edx,%ecx
  800c52:	89 d3                	mov    %edx,%ebx
  800c54:	89 d7                	mov    %edx,%edi
  800c56:	89 d6                	mov    %edx,%esi
  800c58:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	b8 03 00 00 00       	mov    $0x3,%eax
  800c75:	89 cb                	mov    %ecx,%ebx
  800c77:	89 cf                	mov    %ecx,%edi
  800c79:	89 ce                	mov    %ecx,%esi
  800c7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7f 08                	jg     800c89 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	50                   	push   %eax
  800c8d:	6a 03                	push   $0x3
  800c8f:	68 9f 2b 80 00       	push   $0x802b9f
  800c94:	6a 2a                	push   $0x2a
  800c96:	68 bc 2b 80 00       	push   $0x802bbc
  800c9b:	e8 8d f5 ff ff       	call   80022d <_panic>

00800ca0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cab:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb0:	89 d1                	mov    %edx,%ecx
  800cb2:	89 d3                	mov    %edx,%ebx
  800cb4:	89 d7                	mov    %edx,%edi
  800cb6:	89 d6                	mov    %edx,%esi
  800cb8:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_yield>:

void
sys_yield(void)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cca:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ccf:	89 d1                	mov    %edx,%ecx
  800cd1:	89 d3                	mov    %edx,%ebx
  800cd3:	89 d7                	mov    %edx,%edi
  800cd5:	89 d6                	mov    %edx,%esi
  800cd7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce7:	be 00 00 00 00       	mov    $0x0,%esi
  800cec:	8b 55 08             	mov    0x8(%ebp),%edx
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfa:	89 f7                	mov    %esi,%edi
  800cfc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7f 08                	jg     800d0a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 04                	push   $0x4
  800d10:	68 9f 2b 80 00       	push   $0x802b9f
  800d15:	6a 2a                	push   $0x2a
  800d17:	68 bc 2b 80 00       	push   $0x802bbc
  800d1c:	e8 0c f5 ff ff       	call   80022d <_panic>

00800d21 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	b8 05 00 00 00       	mov    $0x5,%eax
  800d35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d3e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7f 08                	jg     800d4c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 05                	push   $0x5
  800d52:	68 9f 2b 80 00       	push   $0x802b9f
  800d57:	6a 2a                	push   $0x2a
  800d59:	68 bc 2b 80 00       	push   $0x802bbc
  800d5e:	e8 ca f4 ff ff       	call   80022d <_panic>

00800d63 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7f 08                	jg     800d8e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	50                   	push   %eax
  800d92:	6a 06                	push   $0x6
  800d94:	68 9f 2b 80 00       	push   $0x802b9f
  800d99:	6a 2a                	push   $0x2a
  800d9b:	68 bc 2b 80 00       	push   $0x802bbc
  800da0:	e8 88 f4 ff ff       	call   80022d <_panic>

00800da5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbe:	89 df                	mov    %ebx,%edi
  800dc0:	89 de                	mov    %ebx,%esi
  800dc2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7f 08                	jg     800dd0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	50                   	push   %eax
  800dd4:	6a 08                	push   $0x8
  800dd6:	68 9f 2b 80 00       	push   $0x802b9f
  800ddb:	6a 2a                	push   $0x2a
  800ddd:	68 bc 2b 80 00       	push   $0x802bbc
  800de2:	e8 46 f4 ff ff       	call   80022d <_panic>

00800de7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfb:	b8 09 00 00 00       	mov    $0x9,%eax
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7f 08                	jg     800e12 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e12:	83 ec 0c             	sub    $0xc,%esp
  800e15:	50                   	push   %eax
  800e16:	6a 09                	push   $0x9
  800e18:	68 9f 2b 80 00       	push   $0x802b9f
  800e1d:	6a 2a                	push   $0x2a
  800e1f:	68 bc 2b 80 00       	push   $0x802bbc
  800e24:	e8 04 f4 ff ff       	call   80022d <_panic>

00800e29 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e42:	89 df                	mov    %ebx,%edi
  800e44:	89 de                	mov    %ebx,%esi
  800e46:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	7f 08                	jg     800e54 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e54:	83 ec 0c             	sub    $0xc,%esp
  800e57:	50                   	push   %eax
  800e58:	6a 0a                	push   $0xa
  800e5a:	68 9f 2b 80 00       	push   $0x802b9f
  800e5f:	6a 2a                	push   $0x2a
  800e61:	68 bc 2b 80 00       	push   $0x802bbc
  800e66:	e8 c2 f3 ff ff       	call   80022d <_panic>

00800e6b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e71:	8b 55 08             	mov    0x8(%ebp),%edx
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7c:	be 00 00 00 00       	mov    $0x0,%esi
  800e81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e84:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e87:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea4:	89 cb                	mov    %ecx,%ebx
  800ea6:	89 cf                	mov    %ecx,%edi
  800ea8:	89 ce                	mov    %ecx,%esi
  800eaa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eac:	85 c0                	test   %eax,%eax
  800eae:	7f 08                	jg     800eb8 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	50                   	push   %eax
  800ebc:	6a 0d                	push   $0xd
  800ebe:	68 9f 2b 80 00       	push   $0x802b9f
  800ec3:	6a 2a                	push   $0x2a
  800ec5:	68 bc 2b 80 00       	push   $0x802bbc
  800eca:	e8 5e f3 ff ff       	call   80022d <_panic>

00800ecf <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	57                   	push   %edi
  800ed3:	56                   	push   %esi
  800ed4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eda:	b8 0e 00 00 00       	mov    $0xe,%eax
  800edf:	89 d1                	mov    %edx,%ecx
  800ee1:	89 d3                	mov    %edx,%ebx
  800ee3:	89 d7                	mov    %edx,%edi
  800ee5:	89 d6                	mov    %edx,%esi
  800ee7:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ef4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eff:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f04:	89 df                	mov    %ebx,%edi
  800f06:	89 de                	mov    %ebx,%esi
  800f08:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	57                   	push   %edi
  800f13:	56                   	push   %esi
  800f14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f20:	b8 10 00 00 00       	mov    $0x10,%eax
  800f25:	89 df                	mov    %ebx,%edi
  800f27:	89 de                	mov    %ebx,%esi
  800f29:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f38:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f3a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f3e:	0f 84 8e 00 00 00    	je     800fd2 <pgfault+0xa2>
  800f44:	89 f0                	mov    %esi,%eax
  800f46:	c1 e8 0c             	shr    $0xc,%eax
  800f49:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f50:	f6 c4 08             	test   $0x8,%ah
  800f53:	74 7d                	je     800fd2 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800f55:	e8 46 fd ff ff       	call   800ca0 <sys_getenvid>
  800f5a:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800f5c:	83 ec 04             	sub    $0x4,%esp
  800f5f:	6a 07                	push   $0x7
  800f61:	68 00 f0 7f 00       	push   $0x7ff000
  800f66:	50                   	push   %eax
  800f67:	e8 72 fd ff ff       	call   800cde <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 73                	js     800fe6 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f73:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f79:	83 ec 04             	sub    $0x4,%esp
  800f7c:	68 00 10 00 00       	push   $0x1000
  800f81:	56                   	push   %esi
  800f82:	68 00 f0 7f 00       	push   $0x7ff000
  800f87:	e8 ec fa ff ff       	call   800a78 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f8c:	83 c4 08             	add    $0x8,%esp
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	e8 cd fd ff ff       	call   800d63 <sys_page_unmap>
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 5b                	js     800ff8 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f9d:	83 ec 0c             	sub    $0xc,%esp
  800fa0:	6a 07                	push   $0x7
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	68 00 f0 7f 00       	push   $0x7ff000
  800fa9:	53                   	push   %ebx
  800faa:	e8 72 fd ff ff       	call   800d21 <sys_page_map>
  800faf:	83 c4 20             	add    $0x20,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 54                	js     80100a <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800fb6:	83 ec 08             	sub    $0x8,%esp
  800fb9:	68 00 f0 7f 00       	push   $0x7ff000
  800fbe:	53                   	push   %ebx
  800fbf:	e8 9f fd ff ff       	call   800d63 <sys_page_unmap>
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 51                	js     80101c <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800fcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	68 cc 2b 80 00       	push   $0x802bcc
  800fda:	6a 1d                	push   $0x1d
  800fdc:	68 48 2c 80 00       	push   $0x802c48
  800fe1:	e8 47 f2 ff ff       	call   80022d <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800fe6:	50                   	push   %eax
  800fe7:	68 04 2c 80 00       	push   $0x802c04
  800fec:	6a 29                	push   $0x29
  800fee:	68 48 2c 80 00       	push   $0x802c48
  800ff3:	e8 35 f2 ff ff       	call   80022d <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ff8:	50                   	push   %eax
  800ff9:	68 28 2c 80 00       	push   $0x802c28
  800ffe:	6a 2e                	push   $0x2e
  801000:	68 48 2c 80 00       	push   $0x802c48
  801005:	e8 23 f2 ff ff       	call   80022d <_panic>
		panic("pgfault: page map failed (%e)", r);
  80100a:	50                   	push   %eax
  80100b:	68 53 2c 80 00       	push   $0x802c53
  801010:	6a 30                	push   $0x30
  801012:	68 48 2c 80 00       	push   $0x802c48
  801017:	e8 11 f2 ff ff       	call   80022d <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  80101c:	50                   	push   %eax
  80101d:	68 28 2c 80 00       	push   $0x802c28
  801022:	6a 32                	push   $0x32
  801024:	68 48 2c 80 00       	push   $0x802c48
  801029:	e8 ff f1 ff ff       	call   80022d <_panic>

0080102e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801037:	68 30 0f 80 00       	push   $0x800f30
  80103c:	e8 d0 12 00 00       	call   802311 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801041:	b8 07 00 00 00       	mov    $0x7,%eax
  801046:	cd 30                	int    $0x30
  801048:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 30                	js     801082 <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801052:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801057:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80105b:	75 76                	jne    8010d3 <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  80105d:	e8 3e fc ff ff       	call   800ca0 <sys_getenvid>
  801062:	25 ff 03 00 00       	and    $0x3ff,%eax
  801067:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80106d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801072:	a3 00 44 80 00       	mov    %eax,0x804400
		return 0;
  801077:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  80107a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107d:	5b                   	pop    %ebx
  80107e:	5e                   	pop    %esi
  80107f:	5f                   	pop    %edi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801082:	50                   	push   %eax
  801083:	68 71 2c 80 00       	push   $0x802c71
  801088:	6a 78                	push   $0x78
  80108a:	68 48 2c 80 00       	push   $0x802c48
  80108f:	e8 99 f1 ff ff       	call   80022d <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	ff 75 e4             	push   -0x1c(%ebp)
  80109a:	57                   	push   %edi
  80109b:	ff 75 dc             	push   -0x24(%ebp)
  80109e:	57                   	push   %edi
  80109f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8010a2:	56                   	push   %esi
  8010a3:	e8 79 fc ff ff       	call   800d21 <sys_page_map>
	if(r<0) return r;
  8010a8:	83 c4 20             	add    $0x20,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 cb                	js     80107a <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	ff 75 e4             	push   -0x1c(%ebp)
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	e8 63 fc ff ff       	call   800d21 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8010be:	83 c4 20             	add    $0x20,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 76                	js     80113b <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8010c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010cb:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010d1:	74 75                	je     801148 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8010d3:	89 d8                	mov    %ebx,%eax
  8010d5:	c1 e8 16             	shr    $0x16,%eax
  8010d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010df:	a8 01                	test   $0x1,%al
  8010e1:	74 e2                	je     8010c5 <fork+0x97>
  8010e3:	89 de                	mov    %ebx,%esi
  8010e5:	c1 ee 0c             	shr    $0xc,%esi
  8010e8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ef:	a8 01                	test   $0x1,%al
  8010f1:	74 d2                	je     8010c5 <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  8010f3:	e8 a8 fb ff ff       	call   800ca0 <sys_getenvid>
  8010f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8010fb:	89 f7                	mov    %esi,%edi
  8010fd:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801100:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801107:	89 c1                	mov    %eax,%ecx
  801109:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80110f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801112:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801119:	f6 c6 04             	test   $0x4,%dh
  80111c:	0f 85 72 ff ff ff    	jne    801094 <fork+0x66>
		perm &= ~PTE_W;
  801122:	25 05 0e 00 00       	and    $0xe05,%eax
  801127:	80 cc 08             	or     $0x8,%ah
  80112a:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801130:	0f 44 c1             	cmove  %ecx,%eax
  801133:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801136:	e9 59 ff ff ff       	jmp    801094 <fork+0x66>
  80113b:	ba 00 00 00 00       	mov    $0x0,%edx
  801140:	0f 4f c2             	cmovg  %edx,%eax
  801143:	e9 32 ff ff ff       	jmp    80107a <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801148:	83 ec 04             	sub    $0x4,%esp
  80114b:	6a 07                	push   $0x7
  80114d:	68 00 f0 bf ee       	push   $0xeebff000
  801152:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801155:	57                   	push   %edi
  801156:	e8 83 fb ff ff       	call   800cde <sys_page_alloc>
	if(r<0) return r;
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	0f 88 14 ff ff ff    	js     80107a <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	68 87 23 80 00       	push   $0x802387
  80116e:	57                   	push   %edi
  80116f:	e8 b5 fc ff ff       	call   800e29 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	0f 88 fb fe ff ff    	js     80107a <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	6a 02                	push   $0x2
  801184:	57                   	push   %edi
  801185:	e8 1b fc ff ff       	call   800da5 <sys_env_set_status>
	if(r<0) return r;
  80118a:	83 c4 10             	add    $0x10,%esp
	return envid;
  80118d:	85 c0                	test   %eax,%eax
  80118f:	0f 49 c7             	cmovns %edi,%eax
  801192:	e9 e3 fe ff ff       	jmp    80107a <fork+0x4c>

00801197 <sfork>:

// Challenge!
int
sfork(void)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80119d:	68 81 2c 80 00       	push   $0x802c81
  8011a2:	68 a1 00 00 00       	push   $0xa1
  8011a7:	68 48 2c 80 00       	push   $0x802c48
  8011ac:	e8 7c f0 ff ff       	call   80022d <_panic>

008011b1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bc:	c1 e8 0c             	shr    $0xc,%eax
}
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c7:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011d1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e0:	89 c2                	mov    %eax,%edx
  8011e2:	c1 ea 16             	shr    $0x16,%edx
  8011e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ec:	f6 c2 01             	test   $0x1,%dl
  8011ef:	74 29                	je     80121a <fd_alloc+0x42>
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	c1 ea 0c             	shr    $0xc,%edx
  8011f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fd:	f6 c2 01             	test   $0x1,%dl
  801200:	74 18                	je     80121a <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801202:	05 00 10 00 00       	add    $0x1000,%eax
  801207:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80120c:	75 d2                	jne    8011e0 <fd_alloc+0x8>
  80120e:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801213:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801218:	eb 05                	jmp    80121f <fd_alloc+0x47>
			return 0;
  80121a:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80121f:	8b 55 08             	mov    0x8(%ebp),%edx
  801222:	89 02                	mov    %eax,(%edx)
}
  801224:	89 c8                	mov    %ecx,%eax
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80122e:	83 f8 1f             	cmp    $0x1f,%eax
  801231:	77 30                	ja     801263 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801233:	c1 e0 0c             	shl    $0xc,%eax
  801236:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80123b:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801241:	f6 c2 01             	test   $0x1,%dl
  801244:	74 24                	je     80126a <fd_lookup+0x42>
  801246:	89 c2                	mov    %eax,%edx
  801248:	c1 ea 0c             	shr    $0xc,%edx
  80124b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801252:	f6 c2 01             	test   $0x1,%dl
  801255:	74 1a                	je     801271 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125a:	89 02                	mov    %eax,(%edx)
	return 0;
  80125c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    
		return -E_INVAL;
  801263:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801268:	eb f7                	jmp    801261 <fd_lookup+0x39>
		return -E_INVAL;
  80126a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126f:	eb f0                	jmp    801261 <fd_lookup+0x39>
  801271:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801276:	eb e9                	jmp    801261 <fd_lookup+0x39>

00801278 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	53                   	push   %ebx
  80127c:	83 ec 04             	sub    $0x4,%esp
  80127f:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80128c:	39 13                	cmp    %edx,(%ebx)
  80128e:	74 37                	je     8012c7 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801290:	83 c0 01             	add    $0x1,%eax
  801293:	8b 1c 85 14 2d 80 00 	mov    0x802d14(,%eax,4),%ebx
  80129a:	85 db                	test   %ebx,%ebx
  80129c:	75 ee                	jne    80128c <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80129e:	a1 00 44 80 00       	mov    0x804400,%eax
  8012a3:	8b 40 58             	mov    0x58(%eax),%eax
  8012a6:	83 ec 04             	sub    $0x4,%esp
  8012a9:	52                   	push   %edx
  8012aa:	50                   	push   %eax
  8012ab:	68 98 2c 80 00       	push   $0x802c98
  8012b0:	e8 53 f0 ff ff       	call   800308 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c0:	89 1a                	mov    %ebx,(%edx)
}
  8012c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    
			return 0;
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cc:	eb ef                	jmp    8012bd <dev_lookup+0x45>

008012ce <fd_close>:
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 24             	sub    $0x24,%esp
  8012d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012da:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e0:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012e1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e7:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ea:	50                   	push   %eax
  8012eb:	e8 38 ff ff ff       	call   801228 <fd_lookup>
  8012f0:	89 c3                	mov    %eax,%ebx
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 05                	js     8012fe <fd_close+0x30>
	    || fd != fd2)
  8012f9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012fc:	74 16                	je     801314 <fd_close+0x46>
		return (must_exist ? r : 0);
  8012fe:	89 f8                	mov    %edi,%eax
  801300:	84 c0                	test   %al,%al
  801302:	b8 00 00 00 00       	mov    $0x0,%eax
  801307:	0f 44 d8             	cmove  %eax,%ebx
}
  80130a:	89 d8                	mov    %ebx,%eax
  80130c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130f:	5b                   	pop    %ebx
  801310:	5e                   	pop    %esi
  801311:	5f                   	pop    %edi
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	ff 36                	push   (%esi)
  80131d:	e8 56 ff ff ff       	call   801278 <dev_lookup>
  801322:	89 c3                	mov    %eax,%ebx
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 1a                	js     801345 <fd_close+0x77>
		if (dev->dev_close)
  80132b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801331:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801336:	85 c0                	test   %eax,%eax
  801338:	74 0b                	je     801345 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	56                   	push   %esi
  80133e:	ff d0                	call   *%eax
  801340:	89 c3                	mov    %eax,%ebx
  801342:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	56                   	push   %esi
  801349:	6a 00                	push   $0x0
  80134b:	e8 13 fa ff ff       	call   800d63 <sys_page_unmap>
	return r;
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	eb b5                	jmp    80130a <fd_close+0x3c>

00801355 <close>:

int
close(int fdnum)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135e:	50                   	push   %eax
  80135f:	ff 75 08             	push   0x8(%ebp)
  801362:	e8 c1 fe ff ff       	call   801228 <fd_lookup>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	79 02                	jns    801370 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    
		return fd_close(fd, 1);
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	6a 01                	push   $0x1
  801375:	ff 75 f4             	push   -0xc(%ebp)
  801378:	e8 51 ff ff ff       	call   8012ce <fd_close>
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	eb ec                	jmp    80136e <close+0x19>

00801382 <close_all>:

void
close_all(void)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801389:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	53                   	push   %ebx
  801392:	e8 be ff ff ff       	call   801355 <close>
	for (i = 0; i < MAXFD; i++)
  801397:	83 c3 01             	add    $0x1,%ebx
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	83 fb 20             	cmp    $0x20,%ebx
  8013a0:	75 ec                	jne    80138e <close_all+0xc>
}
  8013a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	57                   	push   %edi
  8013ab:	56                   	push   %esi
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 75 08             	push   0x8(%ebp)
  8013b7:	e8 6c fe ff ff       	call   801228 <fd_lookup>
  8013bc:	89 c3                	mov    %eax,%ebx
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 7f                	js     801444 <dup+0x9d>
		return r;
	close(newfdnum);
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	ff 75 0c             	push   0xc(%ebp)
  8013cb:	e8 85 ff ff ff       	call   801355 <close>

	newfd = INDEX2FD(newfdnum);
  8013d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013d3:	c1 e6 0c             	shl    $0xc,%esi
  8013d6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013df:	89 3c 24             	mov    %edi,(%esp)
  8013e2:	e8 da fd ff ff       	call   8011c1 <fd2data>
  8013e7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013e9:	89 34 24             	mov    %esi,(%esp)
  8013ec:	e8 d0 fd ff ff       	call   8011c1 <fd2data>
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f7:	89 d8                	mov    %ebx,%eax
  8013f9:	c1 e8 16             	shr    $0x16,%eax
  8013fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801403:	a8 01                	test   $0x1,%al
  801405:	74 11                	je     801418 <dup+0x71>
  801407:	89 d8                	mov    %ebx,%eax
  801409:	c1 e8 0c             	shr    $0xc,%eax
  80140c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801413:	f6 c2 01             	test   $0x1,%dl
  801416:	75 36                	jne    80144e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801418:	89 f8                	mov    %edi,%eax
  80141a:	c1 e8 0c             	shr    $0xc,%eax
  80141d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801424:	83 ec 0c             	sub    $0xc,%esp
  801427:	25 07 0e 00 00       	and    $0xe07,%eax
  80142c:	50                   	push   %eax
  80142d:	56                   	push   %esi
  80142e:	6a 00                	push   $0x0
  801430:	57                   	push   %edi
  801431:	6a 00                	push   $0x0
  801433:	e8 e9 f8 ff ff       	call   800d21 <sys_page_map>
  801438:	89 c3                	mov    %eax,%ebx
  80143a:	83 c4 20             	add    $0x20,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 33                	js     801474 <dup+0xcd>
		goto err;

	return newfdnum;
  801441:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801444:	89 d8                	mov    %ebx,%eax
  801446:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801449:	5b                   	pop    %ebx
  80144a:	5e                   	pop    %esi
  80144b:	5f                   	pop    %edi
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80144e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	25 07 0e 00 00       	and    $0xe07,%eax
  80145d:	50                   	push   %eax
  80145e:	ff 75 d4             	push   -0x2c(%ebp)
  801461:	6a 00                	push   $0x0
  801463:	53                   	push   %ebx
  801464:	6a 00                	push   $0x0
  801466:	e8 b6 f8 ff ff       	call   800d21 <sys_page_map>
  80146b:	89 c3                	mov    %eax,%ebx
  80146d:	83 c4 20             	add    $0x20,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	79 a4                	jns    801418 <dup+0x71>
	sys_page_unmap(0, newfd);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	56                   	push   %esi
  801478:	6a 00                	push   $0x0
  80147a:	e8 e4 f8 ff ff       	call   800d63 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147f:	83 c4 08             	add    $0x8,%esp
  801482:	ff 75 d4             	push   -0x2c(%ebp)
  801485:	6a 00                	push   $0x0
  801487:	e8 d7 f8 ff ff       	call   800d63 <sys_page_unmap>
	return r;
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	eb b3                	jmp    801444 <dup+0x9d>

00801491 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	56                   	push   %esi
  801495:	53                   	push   %ebx
  801496:	83 ec 18             	sub    $0x18,%esp
  801499:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	56                   	push   %esi
  8014a1:	e8 82 fd ff ff       	call   801228 <fd_lookup>
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 3c                	js     8014e9 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ad:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b6:	50                   	push   %eax
  8014b7:	ff 33                	push   (%ebx)
  8014b9:	e8 ba fd ff ff       	call   801278 <dev_lookup>
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 24                	js     8014e9 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c5:	8b 43 08             	mov    0x8(%ebx),%eax
  8014c8:	83 e0 03             	and    $0x3,%eax
  8014cb:	83 f8 01             	cmp    $0x1,%eax
  8014ce:	74 20                	je     8014f0 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d3:	8b 40 08             	mov    0x8(%eax),%eax
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	74 37                	je     801511 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014da:	83 ec 04             	sub    $0x4,%esp
  8014dd:	ff 75 10             	push   0x10(%ebp)
  8014e0:	ff 75 0c             	push   0xc(%ebp)
  8014e3:	53                   	push   %ebx
  8014e4:	ff d0                	call   *%eax
  8014e6:	83 c4 10             	add    $0x10,%esp
}
  8014e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ec:	5b                   	pop    %ebx
  8014ed:	5e                   	pop    %esi
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f0:	a1 00 44 80 00       	mov    0x804400,%eax
  8014f5:	8b 40 58             	mov    0x58(%eax),%eax
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	56                   	push   %esi
  8014fc:	50                   	push   %eax
  8014fd:	68 d9 2c 80 00       	push   $0x802cd9
  801502:	e8 01 ee ff ff       	call   800308 <cprintf>
		return -E_INVAL;
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150f:	eb d8                	jmp    8014e9 <read+0x58>
		return -E_NOT_SUPP;
  801511:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801516:	eb d1                	jmp    8014e9 <read+0x58>

00801518 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	57                   	push   %edi
  80151c:	56                   	push   %esi
  80151d:	53                   	push   %ebx
  80151e:	83 ec 0c             	sub    $0xc,%esp
  801521:	8b 7d 08             	mov    0x8(%ebp),%edi
  801524:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801527:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152c:	eb 02                	jmp    801530 <readn+0x18>
  80152e:	01 c3                	add    %eax,%ebx
  801530:	39 f3                	cmp    %esi,%ebx
  801532:	73 21                	jae    801555 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801534:	83 ec 04             	sub    $0x4,%esp
  801537:	89 f0                	mov    %esi,%eax
  801539:	29 d8                	sub    %ebx,%eax
  80153b:	50                   	push   %eax
  80153c:	89 d8                	mov    %ebx,%eax
  80153e:	03 45 0c             	add    0xc(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	57                   	push   %edi
  801543:	e8 49 ff ff ff       	call   801491 <read>
		if (m < 0)
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 04                	js     801553 <readn+0x3b>
			return m;
		if (m == 0)
  80154f:	75 dd                	jne    80152e <readn+0x16>
  801551:	eb 02                	jmp    801555 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801553:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801555:	89 d8                	mov    %ebx,%eax
  801557:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5e                   	pop    %esi
  80155c:	5f                   	pop    %edi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    

0080155f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	56                   	push   %esi
  801563:	53                   	push   %ebx
  801564:	83 ec 18             	sub    $0x18,%esp
  801567:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	53                   	push   %ebx
  80156f:	e8 b4 fc ff ff       	call   801228 <fd_lookup>
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 37                	js     8015b2 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	ff 36                	push   (%esi)
  801587:	e8 ec fc ff ff       	call   801278 <dev_lookup>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 1f                	js     8015b2 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801593:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801597:	74 20                	je     8015b9 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159c:	8b 40 0c             	mov    0xc(%eax),%eax
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	74 37                	je     8015da <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a3:	83 ec 04             	sub    $0x4,%esp
  8015a6:	ff 75 10             	push   0x10(%ebp)
  8015a9:	ff 75 0c             	push   0xc(%ebp)
  8015ac:	56                   	push   %esi
  8015ad:	ff d0                	call   *%eax
  8015af:	83 c4 10             	add    $0x10,%esp
}
  8015b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b5:	5b                   	pop    %ebx
  8015b6:	5e                   	pop    %esi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b9:	a1 00 44 80 00       	mov    0x804400,%eax
  8015be:	8b 40 58             	mov    0x58(%eax),%eax
  8015c1:	83 ec 04             	sub    $0x4,%esp
  8015c4:	53                   	push   %ebx
  8015c5:	50                   	push   %eax
  8015c6:	68 f5 2c 80 00       	push   $0x802cf5
  8015cb:	e8 38 ed ff ff       	call   800308 <cprintf>
		return -E_INVAL;
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d8:	eb d8                	jmp    8015b2 <write+0x53>
		return -E_NOT_SUPP;
  8015da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015df:	eb d1                	jmp    8015b2 <write+0x53>

008015e1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	ff 75 08             	push   0x8(%ebp)
  8015ee:	e8 35 fc ff ff       	call   801228 <fd_lookup>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 0e                	js     801608 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801600:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801603:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
  80160f:	83 ec 18             	sub    $0x18,%esp
  801612:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801615:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	53                   	push   %ebx
  80161a:	e8 09 fc ff ff       	call   801228 <fd_lookup>
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	78 34                	js     80165a <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801626:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	ff 36                	push   (%esi)
  801632:	e8 41 fc ff ff       	call   801278 <dev_lookup>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 1c                	js     80165a <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801642:	74 1d                	je     801661 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801644:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801647:	8b 40 18             	mov    0x18(%eax),%eax
  80164a:	85 c0                	test   %eax,%eax
  80164c:	74 34                	je     801682 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	ff 75 0c             	push   0xc(%ebp)
  801654:	56                   	push   %esi
  801655:	ff d0                	call   *%eax
  801657:	83 c4 10             	add    $0x10,%esp
}
  80165a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    
			thisenv->env_id, fdnum);
  801661:	a1 00 44 80 00       	mov    0x804400,%eax
  801666:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801669:	83 ec 04             	sub    $0x4,%esp
  80166c:	53                   	push   %ebx
  80166d:	50                   	push   %eax
  80166e:	68 b8 2c 80 00       	push   $0x802cb8
  801673:	e8 90 ec ff ff       	call   800308 <cprintf>
		return -E_INVAL;
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801680:	eb d8                	jmp    80165a <ftruncate+0x50>
		return -E_NOT_SUPP;
  801682:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801687:	eb d1                	jmp    80165a <ftruncate+0x50>

00801689 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	56                   	push   %esi
  80168d:	53                   	push   %ebx
  80168e:	83 ec 18             	sub    $0x18,%esp
  801691:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801694:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	ff 75 08             	push   0x8(%ebp)
  80169b:	e8 88 fb ff ff       	call   801228 <fd_lookup>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 49                	js     8016f0 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	ff 36                	push   (%esi)
  8016b3:	e8 c0 fb ff ff       	call   801278 <dev_lookup>
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 31                	js     8016f0 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c6:	74 2f                	je     8016f7 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016cb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d2:	00 00 00 
	stat->st_isdir = 0;
  8016d5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016dc:	00 00 00 
	stat->st_dev = dev;
  8016df:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	53                   	push   %ebx
  8016e9:	56                   	push   %esi
  8016ea:	ff 50 14             	call   *0x14(%eax)
  8016ed:	83 c4 10             	add    $0x10,%esp
}
  8016f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5e                   	pop    %esi
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    
		return -E_NOT_SUPP;
  8016f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016fc:	eb f2                	jmp    8016f0 <fstat+0x67>

008016fe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	6a 00                	push   $0x0
  801708:	ff 75 08             	push   0x8(%ebp)
  80170b:	e8 e4 01 00 00       	call   8018f4 <open>
  801710:	89 c3                	mov    %eax,%ebx
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	85 c0                	test   %eax,%eax
  801717:	78 1b                	js     801734 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	ff 75 0c             	push   0xc(%ebp)
  80171f:	50                   	push   %eax
  801720:	e8 64 ff ff ff       	call   801689 <fstat>
  801725:	89 c6                	mov    %eax,%esi
	close(fd);
  801727:	89 1c 24             	mov    %ebx,(%esp)
  80172a:	e8 26 fc ff ff       	call   801355 <close>
	return r;
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	89 f3                	mov    %esi,%ebx
}
  801734:	89 d8                	mov    %ebx,%eax
  801736:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801739:	5b                   	pop    %ebx
  80173a:	5e                   	pop    %esi
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    

0080173d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	89 c6                	mov    %eax,%esi
  801744:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801746:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80174d:	74 27                	je     801776 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174f:	6a 07                	push   $0x7
  801751:	68 00 50 80 00       	push   $0x805000
  801756:	56                   	push   %esi
  801757:	ff 35 00 60 80 00    	push   0x806000
  80175d:	e8 bb 0c 00 00       	call   80241d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801762:	83 c4 0c             	add    $0xc,%esp
  801765:	6a 00                	push   $0x0
  801767:	53                   	push   %ebx
  801768:	6a 00                	push   $0x0
  80176a:	e8 3e 0c 00 00       	call   8023ad <ipc_recv>
}
  80176f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801772:	5b                   	pop    %ebx
  801773:	5e                   	pop    %esi
  801774:	5d                   	pop    %ebp
  801775:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801776:	83 ec 0c             	sub    $0xc,%esp
  801779:	6a 01                	push   $0x1
  80177b:	e8 f1 0c 00 00       	call   802471 <ipc_find_env>
  801780:	a3 00 60 80 00       	mov    %eax,0x806000
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	eb c5                	jmp    80174f <fsipc+0x12>

0080178a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801790:	8b 45 08             	mov    0x8(%ebp),%eax
  801793:	8b 40 0c             	mov    0xc(%eax),%eax
  801796:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80179b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ad:	e8 8b ff ff ff       	call   80173d <fsipc>
}
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    

008017b4 <devfile_flush>:
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8017cf:	e8 69 ff ff ff       	call   80173d <fsipc>
}
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <devfile_stat>:
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 04             	sub    $0x4,%esp
  8017dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f5:	e8 43 ff ff ff       	call   80173d <fsipc>
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 2c                	js     80182a <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fe:	83 ec 08             	sub    $0x8,%esp
  801801:	68 00 50 80 00       	push   $0x805000
  801806:	53                   	push   %ebx
  801807:	e8 d6 f0 ff ff       	call   8008e2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180c:	a1 80 50 80 00       	mov    0x805080,%eax
  801811:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801817:	a1 84 50 80 00       	mov    0x805084,%eax
  80181c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <devfile_write>:
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	83 ec 0c             	sub    $0xc,%esp
  801835:	8b 45 10             	mov    0x10(%ebp),%eax
  801838:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80183d:	39 d0                	cmp    %edx,%eax
  80183f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801842:	8b 55 08             	mov    0x8(%ebp),%edx
  801845:	8b 52 0c             	mov    0xc(%edx),%edx
  801848:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80184e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801853:	50                   	push   %eax
  801854:	ff 75 0c             	push   0xc(%ebp)
  801857:	68 08 50 80 00       	push   $0x805008
  80185c:	e8 17 f2 ff ff       	call   800a78 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	b8 04 00 00 00       	mov    $0x4,%eax
  80186b:	e8 cd fe ff ff       	call   80173d <fsipc>
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_read>:
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	56                   	push   %esi
  801876:	53                   	push   %ebx
  801877:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801885:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188b:	ba 00 00 00 00       	mov    $0x0,%edx
  801890:	b8 03 00 00 00       	mov    $0x3,%eax
  801895:	e8 a3 fe ff ff       	call   80173d <fsipc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 1f                	js     8018bf <devfile_read+0x4d>
	assert(r <= n);
  8018a0:	39 f0                	cmp    %esi,%eax
  8018a2:	77 24                	ja     8018c8 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018a4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a9:	7f 33                	jg     8018de <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	50                   	push   %eax
  8018af:	68 00 50 80 00       	push   $0x805000
  8018b4:	ff 75 0c             	push   0xc(%ebp)
  8018b7:	e8 bc f1 ff ff       	call   800a78 <memmove>
	return r;
  8018bc:	83 c4 10             	add    $0x10,%esp
}
  8018bf:	89 d8                	mov    %ebx,%eax
  8018c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c4:	5b                   	pop    %ebx
  8018c5:	5e                   	pop    %esi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    
	assert(r <= n);
  8018c8:	68 28 2d 80 00       	push   $0x802d28
  8018cd:	68 2f 2d 80 00       	push   $0x802d2f
  8018d2:	6a 7c                	push   $0x7c
  8018d4:	68 44 2d 80 00       	push   $0x802d44
  8018d9:	e8 4f e9 ff ff       	call   80022d <_panic>
	assert(r <= PGSIZE);
  8018de:	68 4f 2d 80 00       	push   $0x802d4f
  8018e3:	68 2f 2d 80 00       	push   $0x802d2f
  8018e8:	6a 7d                	push   $0x7d
  8018ea:	68 44 2d 80 00       	push   $0x802d44
  8018ef:	e8 39 e9 ff ff       	call   80022d <_panic>

008018f4 <open>:
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 1c             	sub    $0x1c,%esp
  8018fc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018ff:	56                   	push   %esi
  801900:	e8 a2 ef ff ff       	call   8008a7 <strlen>
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190d:	7f 6c                	jg     80197b <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80190f:	83 ec 0c             	sub    $0xc,%esp
  801912:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801915:	50                   	push   %eax
  801916:	e8 bd f8 ff ff       	call   8011d8 <fd_alloc>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	78 3c                	js     801960 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	56                   	push   %esi
  801928:	68 00 50 80 00       	push   $0x805000
  80192d:	e8 b0 ef ff ff       	call   8008e2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801932:	8b 45 0c             	mov    0xc(%ebp),%eax
  801935:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80193a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193d:	b8 01 00 00 00       	mov    $0x1,%eax
  801942:	e8 f6 fd ff ff       	call   80173d <fsipc>
  801947:	89 c3                	mov    %eax,%ebx
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 19                	js     801969 <open+0x75>
	return fd2num(fd);
  801950:	83 ec 0c             	sub    $0xc,%esp
  801953:	ff 75 f4             	push   -0xc(%ebp)
  801956:	e8 56 f8 ff ff       	call   8011b1 <fd2num>
  80195b:	89 c3                	mov    %eax,%ebx
  80195d:	83 c4 10             	add    $0x10,%esp
}
  801960:	89 d8                	mov    %ebx,%eax
  801962:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    
		fd_close(fd, 0);
  801969:	83 ec 08             	sub    $0x8,%esp
  80196c:	6a 00                	push   $0x0
  80196e:	ff 75 f4             	push   -0xc(%ebp)
  801971:	e8 58 f9 ff ff       	call   8012ce <fd_close>
		return r;
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	eb e5                	jmp    801960 <open+0x6c>
		return -E_BAD_PATH;
  80197b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801980:	eb de                	jmp    801960 <open+0x6c>

00801982 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801988:	ba 00 00 00 00       	mov    $0x0,%edx
  80198d:	b8 08 00 00 00       	mov    $0x8,%eax
  801992:	e8 a6 fd ff ff       	call   80173d <fsipc>
}
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80199f:	68 5b 2d 80 00       	push   $0x802d5b
  8019a4:	ff 75 0c             	push   0xc(%ebp)
  8019a7:	e8 36 ef ff ff       	call   8008e2 <strcpy>
	return 0;
}
  8019ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <devsock_close>:
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	53                   	push   %ebx
  8019b7:	83 ec 10             	sub    $0x10,%esp
  8019ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019bd:	53                   	push   %ebx
  8019be:	e8 ed 0a 00 00       	call   8024b0 <pageref>
  8019c3:	89 c2                	mov    %eax,%edx
  8019c5:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019c8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019cd:	83 fa 01             	cmp    $0x1,%edx
  8019d0:	74 05                	je     8019d7 <devsock_close+0x24>
}
  8019d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 73 0c             	push   0xc(%ebx)
  8019dd:	e8 b7 02 00 00       	call   801c99 <nsipc_close>
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	eb eb                	jmp    8019d2 <devsock_close+0x1f>

008019e7 <devsock_write>:
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019ed:	6a 00                	push   $0x0
  8019ef:	ff 75 10             	push   0x10(%ebp)
  8019f2:	ff 75 0c             	push   0xc(%ebp)
  8019f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f8:	ff 70 0c             	push   0xc(%eax)
  8019fb:	e8 79 03 00 00       	call   801d79 <nsipc_send>
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devsock_read>:
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a08:	6a 00                	push   $0x0
  801a0a:	ff 75 10             	push   0x10(%ebp)
  801a0d:	ff 75 0c             	push   0xc(%ebp)
  801a10:	8b 45 08             	mov    0x8(%ebp),%eax
  801a13:	ff 70 0c             	push   0xc(%eax)
  801a16:	e8 ef 02 00 00       	call   801d0a <nsipc_recv>
}
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <fd2sockid>:
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a23:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a26:	52                   	push   %edx
  801a27:	50                   	push   %eax
  801a28:	e8 fb f7 ff ff       	call   801228 <fd_lookup>
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	85 c0                	test   %eax,%eax
  801a32:	78 10                	js     801a44 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a37:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a3d:	39 08                	cmp    %ecx,(%eax)
  801a3f:	75 05                	jne    801a46 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a41:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    
		return -E_NOT_SUPP;
  801a46:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a4b:	eb f7                	jmp    801a44 <fd2sockid+0x27>

00801a4d <alloc_sockfd>:
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	83 ec 1c             	sub    $0x1c,%esp
  801a55:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5a:	50                   	push   %eax
  801a5b:	e8 78 f7 ff ff       	call   8011d8 <fd_alloc>
  801a60:	89 c3                	mov    %eax,%ebx
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 43                	js     801aac <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a69:	83 ec 04             	sub    $0x4,%esp
  801a6c:	68 07 04 00 00       	push   $0x407
  801a71:	ff 75 f4             	push   -0xc(%ebp)
  801a74:	6a 00                	push   $0x0
  801a76:	e8 63 f2 ff ff       	call   800cde <sys_page_alloc>
  801a7b:	89 c3                	mov    %eax,%ebx
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	85 c0                	test   %eax,%eax
  801a82:	78 28                	js     801aac <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a8d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a92:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a99:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	50                   	push   %eax
  801aa0:	e8 0c f7 ff ff       	call   8011b1 <fd2num>
  801aa5:	89 c3                	mov    %eax,%ebx
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	eb 0c                	jmp    801ab8 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	56                   	push   %esi
  801ab0:	e8 e4 01 00 00       	call   801c99 <nsipc_close>
		return r;
  801ab5:	83 c4 10             	add    $0x10,%esp
}
  801ab8:	89 d8                	mov    %ebx,%eax
  801aba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abd:	5b                   	pop    %ebx
  801abe:	5e                   	pop    %esi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <accept>:
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	e8 4e ff ff ff       	call   801a1d <fd2sockid>
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	78 1b                	js     801aee <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ad3:	83 ec 04             	sub    $0x4,%esp
  801ad6:	ff 75 10             	push   0x10(%ebp)
  801ad9:	ff 75 0c             	push   0xc(%ebp)
  801adc:	50                   	push   %eax
  801add:	e8 0e 01 00 00       	call   801bf0 <nsipc_accept>
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 05                	js     801aee <accept+0x2d>
	return alloc_sockfd(r);
  801ae9:	e8 5f ff ff ff       	call   801a4d <alloc_sockfd>
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <bind>:
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801af6:	8b 45 08             	mov    0x8(%ebp),%eax
  801af9:	e8 1f ff ff ff       	call   801a1d <fd2sockid>
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 12                	js     801b14 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b02:	83 ec 04             	sub    $0x4,%esp
  801b05:	ff 75 10             	push   0x10(%ebp)
  801b08:	ff 75 0c             	push   0xc(%ebp)
  801b0b:	50                   	push   %eax
  801b0c:	e8 31 01 00 00       	call   801c42 <nsipc_bind>
  801b11:	83 c4 10             	add    $0x10,%esp
}
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <shutdown>:
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	e8 f9 fe ff ff       	call   801a1d <fd2sockid>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 0f                	js     801b37 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b28:	83 ec 08             	sub    $0x8,%esp
  801b2b:	ff 75 0c             	push   0xc(%ebp)
  801b2e:	50                   	push   %eax
  801b2f:	e8 43 01 00 00       	call   801c77 <nsipc_shutdown>
  801b34:	83 c4 10             	add    $0x10,%esp
}
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <connect>:
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b42:	e8 d6 fe ff ff       	call   801a1d <fd2sockid>
  801b47:	85 c0                	test   %eax,%eax
  801b49:	78 12                	js     801b5d <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b4b:	83 ec 04             	sub    $0x4,%esp
  801b4e:	ff 75 10             	push   0x10(%ebp)
  801b51:	ff 75 0c             	push   0xc(%ebp)
  801b54:	50                   	push   %eax
  801b55:	e8 59 01 00 00       	call   801cb3 <nsipc_connect>
  801b5a:	83 c4 10             	add    $0x10,%esp
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <listen>:
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b65:	8b 45 08             	mov    0x8(%ebp),%eax
  801b68:	e8 b0 fe ff ff       	call   801a1d <fd2sockid>
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	78 0f                	js     801b80 <listen+0x21>
	return nsipc_listen(r, backlog);
  801b71:	83 ec 08             	sub    $0x8,%esp
  801b74:	ff 75 0c             	push   0xc(%ebp)
  801b77:	50                   	push   %eax
  801b78:	e8 6b 01 00 00       	call   801ce8 <nsipc_listen>
  801b7d:	83 c4 10             	add    $0x10,%esp
}
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <socket>:

int
socket(int domain, int type, int protocol)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b88:	ff 75 10             	push   0x10(%ebp)
  801b8b:	ff 75 0c             	push   0xc(%ebp)
  801b8e:	ff 75 08             	push   0x8(%ebp)
  801b91:	e8 41 02 00 00       	call   801dd7 <nsipc_socket>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 05                	js     801ba2 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b9d:	e8 ab fe ff ff       	call   801a4d <alloc_sockfd>
}
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	53                   	push   %ebx
  801ba8:	83 ec 04             	sub    $0x4,%esp
  801bab:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bad:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801bb4:	74 26                	je     801bdc <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bb6:	6a 07                	push   $0x7
  801bb8:	68 00 70 80 00       	push   $0x807000
  801bbd:	53                   	push   %ebx
  801bbe:	ff 35 00 80 80 00    	push   0x808000
  801bc4:	e8 54 08 00 00       	call   80241d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bc9:	83 c4 0c             	add    $0xc,%esp
  801bcc:	6a 00                	push   $0x0
  801bce:	6a 00                	push   $0x0
  801bd0:	6a 00                	push   $0x0
  801bd2:	e8 d6 07 00 00       	call   8023ad <ipc_recv>
}
  801bd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bda:	c9                   	leave  
  801bdb:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bdc:	83 ec 0c             	sub    $0xc,%esp
  801bdf:	6a 02                	push   $0x2
  801be1:	e8 8b 08 00 00       	call   802471 <ipc_find_env>
  801be6:	a3 00 80 80 00       	mov    %eax,0x808000
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	eb c6                	jmp    801bb6 <nsipc+0x12>

00801bf0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	56                   	push   %esi
  801bf4:	53                   	push   %ebx
  801bf5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c00:	8b 06                	mov    (%esi),%eax
  801c02:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c07:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0c:	e8 93 ff ff ff       	call   801ba4 <nsipc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	85 c0                	test   %eax,%eax
  801c15:	79 09                	jns    801c20 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c17:	89 d8                	mov    %ebx,%eax
  801c19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c20:	83 ec 04             	sub    $0x4,%esp
  801c23:	ff 35 10 70 80 00    	push   0x807010
  801c29:	68 00 70 80 00       	push   $0x807000
  801c2e:	ff 75 0c             	push   0xc(%ebp)
  801c31:	e8 42 ee ff ff       	call   800a78 <memmove>
		*addrlen = ret->ret_addrlen;
  801c36:	a1 10 70 80 00       	mov    0x807010,%eax
  801c3b:	89 06                	mov    %eax,(%esi)
  801c3d:	83 c4 10             	add    $0x10,%esp
	return r;
  801c40:	eb d5                	jmp    801c17 <nsipc_accept+0x27>

00801c42 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	53                   	push   %ebx
  801c46:	83 ec 08             	sub    $0x8,%esp
  801c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c54:	53                   	push   %ebx
  801c55:	ff 75 0c             	push   0xc(%ebp)
  801c58:	68 04 70 80 00       	push   $0x807004
  801c5d:	e8 16 ee ff ff       	call   800a78 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c62:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c68:	b8 02 00 00 00       	mov    $0x2,%eax
  801c6d:	e8 32 ff ff ff       	call   801ba4 <nsipc>
}
  801c72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c88:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801c8d:	b8 03 00 00 00       	mov    $0x3,%eax
  801c92:	e8 0d ff ff ff       	call   801ba4 <nsipc>
}
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <nsipc_close>:

int
nsipc_close(int s)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801ca7:	b8 04 00 00 00       	mov    $0x4,%eax
  801cac:	e8 f3 fe ff ff       	call   801ba4 <nsipc>
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	53                   	push   %ebx
  801cb7:	83 ec 08             	sub    $0x8,%esp
  801cba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cc5:	53                   	push   %ebx
  801cc6:	ff 75 0c             	push   0xc(%ebp)
  801cc9:	68 04 70 80 00       	push   $0x807004
  801cce:	e8 a5 ed ff ff       	call   800a78 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cd3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801cd9:	b8 05 00 00 00       	mov    $0x5,%eax
  801cde:	e8 c1 fe ff ff       	call   801ba4 <nsipc>
}
  801ce3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf9:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801cfe:	b8 06 00 00 00       	mov    $0x6,%eax
  801d03:	e8 9c fe ff ff       	call   801ba4 <nsipc>
}
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	56                   	push   %esi
  801d0e:	53                   	push   %ebx
  801d0f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d12:	8b 45 08             	mov    0x8(%ebp),%eax
  801d15:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d1a:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d20:	8b 45 14             	mov    0x14(%ebp),%eax
  801d23:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d28:	b8 07 00 00 00       	mov    $0x7,%eax
  801d2d:	e8 72 fe ff ff       	call   801ba4 <nsipc>
  801d32:	89 c3                	mov    %eax,%ebx
  801d34:	85 c0                	test   %eax,%eax
  801d36:	78 22                	js     801d5a <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d38:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d3d:	39 c6                	cmp    %eax,%esi
  801d3f:	0f 4e c6             	cmovle %esi,%eax
  801d42:	39 c3                	cmp    %eax,%ebx
  801d44:	7f 1d                	jg     801d63 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d46:	83 ec 04             	sub    $0x4,%esp
  801d49:	53                   	push   %ebx
  801d4a:	68 00 70 80 00       	push   $0x807000
  801d4f:	ff 75 0c             	push   0xc(%ebp)
  801d52:	e8 21 ed ff ff       	call   800a78 <memmove>
  801d57:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d5a:	89 d8                	mov    %ebx,%eax
  801d5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d63:	68 67 2d 80 00       	push   $0x802d67
  801d68:	68 2f 2d 80 00       	push   $0x802d2f
  801d6d:	6a 62                	push   $0x62
  801d6f:	68 7c 2d 80 00       	push   $0x802d7c
  801d74:	e8 b4 e4 ff ff       	call   80022d <_panic>

00801d79 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	53                   	push   %ebx
  801d7d:	83 ec 04             	sub    $0x4,%esp
  801d80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d83:	8b 45 08             	mov    0x8(%ebp),%eax
  801d86:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801d8b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d91:	7f 2e                	jg     801dc1 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d93:	83 ec 04             	sub    $0x4,%esp
  801d96:	53                   	push   %ebx
  801d97:	ff 75 0c             	push   0xc(%ebp)
  801d9a:	68 0c 70 80 00       	push   $0x80700c
  801d9f:	e8 d4 ec ff ff       	call   800a78 <memmove>
	nsipcbuf.send.req_size = size;
  801da4:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801daa:	8b 45 14             	mov    0x14(%ebp),%eax
  801dad:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801db2:	b8 08 00 00 00       	mov    $0x8,%eax
  801db7:	e8 e8 fd ff ff       	call   801ba4 <nsipc>
}
  801dbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    
	assert(size < 1600);
  801dc1:	68 88 2d 80 00       	push   $0x802d88
  801dc6:	68 2f 2d 80 00       	push   $0x802d2f
  801dcb:	6a 6d                	push   $0x6d
  801dcd:	68 7c 2d 80 00       	push   $0x802d7c
  801dd2:	e8 56 e4 ff ff       	call   80022d <_panic>

00801dd7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de8:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801ded:	8b 45 10             	mov    0x10(%ebp),%eax
  801df0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801df5:	b8 09 00 00 00       	mov    $0x9,%eax
  801dfa:	e8 a5 fd ff ff       	call   801ba4 <nsipc>
}
  801dff:	c9                   	leave  
  801e00:	c3                   	ret    

00801e01 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
  801e06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e09:	83 ec 0c             	sub    $0xc,%esp
  801e0c:	ff 75 08             	push   0x8(%ebp)
  801e0f:	e8 ad f3 ff ff       	call   8011c1 <fd2data>
  801e14:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e16:	83 c4 08             	add    $0x8,%esp
  801e19:	68 94 2d 80 00       	push   $0x802d94
  801e1e:	53                   	push   %ebx
  801e1f:	e8 be ea ff ff       	call   8008e2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e24:	8b 46 04             	mov    0x4(%esi),%eax
  801e27:	2b 06                	sub    (%esi),%eax
  801e29:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e2f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e36:	00 00 00 
	stat->st_dev = &devpipe;
  801e39:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e40:	30 80 00 
	return 0;
}
  801e43:	b8 00 00 00 00       	mov    $0x0,%eax
  801e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4b:	5b                   	pop    %ebx
  801e4c:	5e                   	pop    %esi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	53                   	push   %ebx
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e59:	53                   	push   %ebx
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 02 ef ff ff       	call   800d63 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e61:	89 1c 24             	mov    %ebx,(%esp)
  801e64:	e8 58 f3 ff ff       	call   8011c1 <fd2data>
  801e69:	83 c4 08             	add    $0x8,%esp
  801e6c:	50                   	push   %eax
  801e6d:	6a 00                	push   $0x0
  801e6f:	e8 ef ee ff ff       	call   800d63 <sys_page_unmap>
}
  801e74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <_pipeisclosed>:
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	57                   	push   %edi
  801e7d:	56                   	push   %esi
  801e7e:	53                   	push   %ebx
  801e7f:	83 ec 1c             	sub    $0x1c,%esp
  801e82:	89 c7                	mov    %eax,%edi
  801e84:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e86:	a1 00 44 80 00       	mov    0x804400,%eax
  801e8b:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e8e:	83 ec 0c             	sub    $0xc,%esp
  801e91:	57                   	push   %edi
  801e92:	e8 19 06 00 00       	call   8024b0 <pageref>
  801e97:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e9a:	89 34 24             	mov    %esi,(%esp)
  801e9d:	e8 0e 06 00 00       	call   8024b0 <pageref>
		nn = thisenv->env_runs;
  801ea2:	8b 15 00 44 80 00    	mov    0x804400,%edx
  801ea8:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	39 cb                	cmp    %ecx,%ebx
  801eb0:	74 1b                	je     801ecd <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801eb2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801eb5:	75 cf                	jne    801e86 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb7:	8b 42 68             	mov    0x68(%edx),%eax
  801eba:	6a 01                	push   $0x1
  801ebc:	50                   	push   %eax
  801ebd:	53                   	push   %ebx
  801ebe:	68 9b 2d 80 00       	push   $0x802d9b
  801ec3:	e8 40 e4 ff ff       	call   800308 <cprintf>
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	eb b9                	jmp    801e86 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ecd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ed0:	0f 94 c0             	sete   %al
  801ed3:	0f b6 c0             	movzbl %al,%eax
}
  801ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed9:	5b                   	pop    %ebx
  801eda:	5e                   	pop    %esi
  801edb:	5f                   	pop    %edi
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <devpipe_write>:
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 28             	sub    $0x28,%esp
  801ee7:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801eea:	56                   	push   %esi
  801eeb:	e8 d1 f2 ff ff       	call   8011c1 <fd2data>
  801ef0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	bf 00 00 00 00       	mov    $0x0,%edi
  801efa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801efd:	75 09                	jne    801f08 <devpipe_write+0x2a>
	return i;
  801eff:	89 f8                	mov    %edi,%eax
  801f01:	eb 23                	jmp    801f26 <devpipe_write+0x48>
			sys_yield();
  801f03:	e8 b7 ed ff ff       	call   800cbf <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f08:	8b 43 04             	mov    0x4(%ebx),%eax
  801f0b:	8b 0b                	mov    (%ebx),%ecx
  801f0d:	8d 51 20             	lea    0x20(%ecx),%edx
  801f10:	39 d0                	cmp    %edx,%eax
  801f12:	72 1a                	jb     801f2e <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f14:	89 da                	mov    %ebx,%edx
  801f16:	89 f0                	mov    %esi,%eax
  801f18:	e8 5c ff ff ff       	call   801e79 <_pipeisclosed>
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	74 e2                	je     801f03 <devpipe_write+0x25>
				return 0;
  801f21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f29:	5b                   	pop    %ebx
  801f2a:	5e                   	pop    %esi
  801f2b:	5f                   	pop    %edi
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f31:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f35:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f38:	89 c2                	mov    %eax,%edx
  801f3a:	c1 fa 1f             	sar    $0x1f,%edx
  801f3d:	89 d1                	mov    %edx,%ecx
  801f3f:	c1 e9 1b             	shr    $0x1b,%ecx
  801f42:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f45:	83 e2 1f             	and    $0x1f,%edx
  801f48:	29 ca                	sub    %ecx,%edx
  801f4a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f4e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f52:	83 c0 01             	add    $0x1,%eax
  801f55:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f58:	83 c7 01             	add    $0x1,%edi
  801f5b:	eb 9d                	jmp    801efa <devpipe_write+0x1c>

00801f5d <devpipe_read>:
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	57                   	push   %edi
  801f61:	56                   	push   %esi
  801f62:	53                   	push   %ebx
  801f63:	83 ec 18             	sub    $0x18,%esp
  801f66:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f69:	57                   	push   %edi
  801f6a:	e8 52 f2 ff ff       	call   8011c1 <fd2data>
  801f6f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	be 00 00 00 00       	mov    $0x0,%esi
  801f79:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f7c:	75 13                	jne    801f91 <devpipe_read+0x34>
	return i;
  801f7e:	89 f0                	mov    %esi,%eax
  801f80:	eb 02                	jmp    801f84 <devpipe_read+0x27>
				return i;
  801f82:	89 f0                	mov    %esi,%eax
}
  801f84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f87:	5b                   	pop    %ebx
  801f88:	5e                   	pop    %esi
  801f89:	5f                   	pop    %edi
  801f8a:	5d                   	pop    %ebp
  801f8b:	c3                   	ret    
			sys_yield();
  801f8c:	e8 2e ed ff ff       	call   800cbf <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f91:	8b 03                	mov    (%ebx),%eax
  801f93:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f96:	75 18                	jne    801fb0 <devpipe_read+0x53>
			if (i > 0)
  801f98:	85 f6                	test   %esi,%esi
  801f9a:	75 e6                	jne    801f82 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801f9c:	89 da                	mov    %ebx,%edx
  801f9e:	89 f8                	mov    %edi,%eax
  801fa0:	e8 d4 fe ff ff       	call   801e79 <_pipeisclosed>
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	74 e3                	je     801f8c <devpipe_read+0x2f>
				return 0;
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fae:	eb d4                	jmp    801f84 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fb0:	99                   	cltd   
  801fb1:	c1 ea 1b             	shr    $0x1b,%edx
  801fb4:	01 d0                	add    %edx,%eax
  801fb6:	83 e0 1f             	and    $0x1f,%eax
  801fb9:	29 d0                	sub    %edx,%eax
  801fbb:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fc3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801fc6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801fc9:	83 c6 01             	add    $0x1,%esi
  801fcc:	eb ab                	jmp    801f79 <devpipe_read+0x1c>

00801fce <pipe>:
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd9:	50                   	push   %eax
  801fda:	e8 f9 f1 ff ff       	call   8011d8 <fd_alloc>
  801fdf:	89 c3                	mov    %eax,%ebx
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	0f 88 23 01 00 00    	js     80210f <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fec:	83 ec 04             	sub    $0x4,%esp
  801fef:	68 07 04 00 00       	push   $0x407
  801ff4:	ff 75 f4             	push   -0xc(%ebp)
  801ff7:	6a 00                	push   $0x0
  801ff9:	e8 e0 ec ff ff       	call   800cde <sys_page_alloc>
  801ffe:	89 c3                	mov    %eax,%ebx
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	85 c0                	test   %eax,%eax
  802005:	0f 88 04 01 00 00    	js     80210f <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80200b:	83 ec 0c             	sub    $0xc,%esp
  80200e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802011:	50                   	push   %eax
  802012:	e8 c1 f1 ff ff       	call   8011d8 <fd_alloc>
  802017:	89 c3                	mov    %eax,%ebx
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	85 c0                	test   %eax,%eax
  80201e:	0f 88 db 00 00 00    	js     8020ff <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802024:	83 ec 04             	sub    $0x4,%esp
  802027:	68 07 04 00 00       	push   $0x407
  80202c:	ff 75 f0             	push   -0x10(%ebp)
  80202f:	6a 00                	push   $0x0
  802031:	e8 a8 ec ff ff       	call   800cde <sys_page_alloc>
  802036:	89 c3                	mov    %eax,%ebx
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	85 c0                	test   %eax,%eax
  80203d:	0f 88 bc 00 00 00    	js     8020ff <pipe+0x131>
	va = fd2data(fd0);
  802043:	83 ec 0c             	sub    $0xc,%esp
  802046:	ff 75 f4             	push   -0xc(%ebp)
  802049:	e8 73 f1 ff ff       	call   8011c1 <fd2data>
  80204e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802050:	83 c4 0c             	add    $0xc,%esp
  802053:	68 07 04 00 00       	push   $0x407
  802058:	50                   	push   %eax
  802059:	6a 00                	push   $0x0
  80205b:	e8 7e ec ff ff       	call   800cde <sys_page_alloc>
  802060:	89 c3                	mov    %eax,%ebx
  802062:	83 c4 10             	add    $0x10,%esp
  802065:	85 c0                	test   %eax,%eax
  802067:	0f 88 82 00 00 00    	js     8020ef <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206d:	83 ec 0c             	sub    $0xc,%esp
  802070:	ff 75 f0             	push   -0x10(%ebp)
  802073:	e8 49 f1 ff ff       	call   8011c1 <fd2data>
  802078:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80207f:	50                   	push   %eax
  802080:	6a 00                	push   $0x0
  802082:	56                   	push   %esi
  802083:	6a 00                	push   $0x0
  802085:	e8 97 ec ff ff       	call   800d21 <sys_page_map>
  80208a:	89 c3                	mov    %eax,%ebx
  80208c:	83 c4 20             	add    $0x20,%esp
  80208f:	85 c0                	test   %eax,%eax
  802091:	78 4e                	js     8020e1 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802093:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802098:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80209b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80209d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020a0:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020aa:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020af:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020b6:	83 ec 0c             	sub    $0xc,%esp
  8020b9:	ff 75 f4             	push   -0xc(%ebp)
  8020bc:	e8 f0 f0 ff ff       	call   8011b1 <fd2num>
  8020c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020c6:	83 c4 04             	add    $0x4,%esp
  8020c9:	ff 75 f0             	push   -0x10(%ebp)
  8020cc:	e8 e0 f0 ff ff       	call   8011b1 <fd2num>
  8020d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020d7:	83 c4 10             	add    $0x10,%esp
  8020da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020df:	eb 2e                	jmp    80210f <pipe+0x141>
	sys_page_unmap(0, va);
  8020e1:	83 ec 08             	sub    $0x8,%esp
  8020e4:	56                   	push   %esi
  8020e5:	6a 00                	push   $0x0
  8020e7:	e8 77 ec ff ff       	call   800d63 <sys_page_unmap>
  8020ec:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8020ef:	83 ec 08             	sub    $0x8,%esp
  8020f2:	ff 75 f0             	push   -0x10(%ebp)
  8020f5:	6a 00                	push   $0x0
  8020f7:	e8 67 ec ff ff       	call   800d63 <sys_page_unmap>
  8020fc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8020ff:	83 ec 08             	sub    $0x8,%esp
  802102:	ff 75 f4             	push   -0xc(%ebp)
  802105:	6a 00                	push   $0x0
  802107:	e8 57 ec ff ff       	call   800d63 <sys_page_unmap>
  80210c:	83 c4 10             	add    $0x10,%esp
}
  80210f:	89 d8                	mov    %ebx,%eax
  802111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    

00802118 <pipeisclosed>:
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80211e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802121:	50                   	push   %eax
  802122:	ff 75 08             	push   0x8(%ebp)
  802125:	e8 fe f0 ff ff       	call   801228 <fd_lookup>
  80212a:	83 c4 10             	add    $0x10,%esp
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 18                	js     802149 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802131:	83 ec 0c             	sub    $0xc,%esp
  802134:	ff 75 f4             	push   -0xc(%ebp)
  802137:	e8 85 f0 ff ff       	call   8011c1 <fd2data>
  80213c:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80213e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802141:	e8 33 fd ff ff       	call   801e79 <_pipeisclosed>
  802146:	83 c4 10             	add    $0x10,%esp
}
  802149:	c9                   	leave  
  80214a:	c3                   	ret    

0080214b <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	56                   	push   %esi
  80214f:	53                   	push   %ebx
  802150:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802153:	85 f6                	test   %esi,%esi
  802155:	74 16                	je     80216d <wait+0x22>
	e = &envs[ENVX(envid)];
  802157:	89 f3                	mov    %esi,%ebx
  802159:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80215f:	69 db 8c 00 00 00    	imul   $0x8c,%ebx,%ebx
  802165:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80216b:	eb 1b                	jmp    802188 <wait+0x3d>
	assert(envid != 0);
  80216d:	68 b3 2d 80 00       	push   $0x802db3
  802172:	68 2f 2d 80 00       	push   $0x802d2f
  802177:	6a 09                	push   $0x9
  802179:	68 be 2d 80 00       	push   $0x802dbe
  80217e:	e8 aa e0 ff ff       	call   80022d <_panic>
		sys_yield();
  802183:	e8 37 eb ff ff       	call   800cbf <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802188:	8b 43 58             	mov    0x58(%ebx),%eax
  80218b:	39 f0                	cmp    %esi,%eax
  80218d:	75 07                	jne    802196 <wait+0x4b>
  80218f:	8b 43 64             	mov    0x64(%ebx),%eax
  802192:	85 c0                	test   %eax,%eax
  802194:	75 ed                	jne    802183 <wait+0x38>
}
  802196:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802199:	5b                   	pop    %ebx
  80219a:	5e                   	pop    %esi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    

0080219d <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80219d:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a2:	c3                   	ret    

008021a3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021a9:	68 c9 2d 80 00       	push   $0x802dc9
  8021ae:	ff 75 0c             	push   0xc(%ebp)
  8021b1:	e8 2c e7 ff ff       	call   8008e2 <strcpy>
	return 0;
}
  8021b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021bb:	c9                   	leave  
  8021bc:	c3                   	ret    

008021bd <devcons_write>:
{
  8021bd:	55                   	push   %ebp
  8021be:	89 e5                	mov    %esp,%ebp
  8021c0:	57                   	push   %edi
  8021c1:	56                   	push   %esi
  8021c2:	53                   	push   %ebx
  8021c3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8021c9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021ce:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8021d4:	eb 2e                	jmp    802204 <devcons_write+0x47>
		m = n - tot;
  8021d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021d9:	29 f3                	sub    %esi,%ebx
  8021db:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8021e0:	39 c3                	cmp    %eax,%ebx
  8021e2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021e5:	83 ec 04             	sub    $0x4,%esp
  8021e8:	53                   	push   %ebx
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	03 45 0c             	add    0xc(%ebp),%eax
  8021ee:	50                   	push   %eax
  8021ef:	57                   	push   %edi
  8021f0:	e8 83 e8 ff ff       	call   800a78 <memmove>
		sys_cputs(buf, m);
  8021f5:	83 c4 08             	add    $0x8,%esp
  8021f8:	53                   	push   %ebx
  8021f9:	57                   	push   %edi
  8021fa:	e8 23 ea ff ff       	call   800c22 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021ff:	01 de                	add    %ebx,%esi
  802201:	83 c4 10             	add    $0x10,%esp
  802204:	3b 75 10             	cmp    0x10(%ebp),%esi
  802207:	72 cd                	jb     8021d6 <devcons_write+0x19>
}
  802209:	89 f0                	mov    %esi,%eax
  80220b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80220e:	5b                   	pop    %ebx
  80220f:	5e                   	pop    %esi
  802210:	5f                   	pop    %edi
  802211:	5d                   	pop    %ebp
  802212:	c3                   	ret    

00802213 <devcons_read>:
{
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	83 ec 08             	sub    $0x8,%esp
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80221e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802222:	75 07                	jne    80222b <devcons_read+0x18>
  802224:	eb 1f                	jmp    802245 <devcons_read+0x32>
		sys_yield();
  802226:	e8 94 ea ff ff       	call   800cbf <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80222b:	e8 10 ea ff ff       	call   800c40 <sys_cgetc>
  802230:	85 c0                	test   %eax,%eax
  802232:	74 f2                	je     802226 <devcons_read+0x13>
	if (c < 0)
  802234:	78 0f                	js     802245 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802236:	83 f8 04             	cmp    $0x4,%eax
  802239:	74 0c                	je     802247 <devcons_read+0x34>
	*(char*)vbuf = c;
  80223b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80223e:	88 02                	mov    %al,(%edx)
	return 1;
  802240:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802245:	c9                   	leave  
  802246:	c3                   	ret    
		return 0;
  802247:	b8 00 00 00 00       	mov    $0x0,%eax
  80224c:	eb f7                	jmp    802245 <devcons_read+0x32>

0080224e <cputchar>:
{
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802254:	8b 45 08             	mov    0x8(%ebp),%eax
  802257:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80225a:	6a 01                	push   $0x1
  80225c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80225f:	50                   	push   %eax
  802260:	e8 bd e9 ff ff       	call   800c22 <sys_cputs>
}
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	c9                   	leave  
  802269:	c3                   	ret    

0080226a <getchar>:
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802270:	6a 01                	push   $0x1
  802272:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802275:	50                   	push   %eax
  802276:	6a 00                	push   $0x0
  802278:	e8 14 f2 ff ff       	call   801491 <read>
	if (r < 0)
  80227d:	83 c4 10             	add    $0x10,%esp
  802280:	85 c0                	test   %eax,%eax
  802282:	78 06                	js     80228a <getchar+0x20>
	if (r < 1)
  802284:	74 06                	je     80228c <getchar+0x22>
	return c;
  802286:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80228a:	c9                   	leave  
  80228b:	c3                   	ret    
		return -E_EOF;
  80228c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802291:	eb f7                	jmp    80228a <getchar+0x20>

00802293 <iscons>:
{
  802293:	55                   	push   %ebp
  802294:	89 e5                	mov    %esp,%ebp
  802296:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802299:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229c:	50                   	push   %eax
  80229d:	ff 75 08             	push   0x8(%ebp)
  8022a0:	e8 83 ef ff ff       	call   801228 <fd_lookup>
  8022a5:	83 c4 10             	add    $0x10,%esp
  8022a8:	85 c0                	test   %eax,%eax
  8022aa:	78 11                	js     8022bd <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8022ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022af:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022b5:	39 10                	cmp    %edx,(%eax)
  8022b7:	0f 94 c0             	sete   %al
  8022ba:	0f b6 c0             	movzbl %al,%eax
}
  8022bd:	c9                   	leave  
  8022be:	c3                   	ret    

008022bf <opencons>:
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8022c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c8:	50                   	push   %eax
  8022c9:	e8 0a ef ff ff       	call   8011d8 <fd_alloc>
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	85 c0                	test   %eax,%eax
  8022d3:	78 3a                	js     80230f <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d5:	83 ec 04             	sub    $0x4,%esp
  8022d8:	68 07 04 00 00       	push   $0x407
  8022dd:	ff 75 f4             	push   -0xc(%ebp)
  8022e0:	6a 00                	push   $0x0
  8022e2:	e8 f7 e9 ff ff       	call   800cde <sys_page_alloc>
  8022e7:	83 c4 10             	add    $0x10,%esp
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	78 21                	js     80230f <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8022ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022f7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802303:	83 ec 0c             	sub    $0xc,%esp
  802306:	50                   	push   %eax
  802307:	e8 a5 ee ff ff       	call   8011b1 <fd2num>
  80230c:	83 c4 10             	add    $0x10,%esp
}
  80230f:	c9                   	leave  
  802310:	c3                   	ret    

00802311 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802311:	55                   	push   %ebp
  802312:	89 e5                	mov    %esp,%ebp
  802314:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802317:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  80231e:	74 0a                	je     80232a <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802320:	8b 45 08             	mov    0x8(%ebp),%eax
  802323:	a3 04 80 80 00       	mov    %eax,0x808004
}
  802328:	c9                   	leave  
  802329:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  80232a:	e8 71 e9 ff ff       	call   800ca0 <sys_getenvid>
  80232f:	83 ec 04             	sub    $0x4,%esp
  802332:	68 07 0e 00 00       	push   $0xe07
  802337:	68 00 f0 bf ee       	push   $0xeebff000
  80233c:	50                   	push   %eax
  80233d:	e8 9c e9 ff ff       	call   800cde <sys_page_alloc>
		if (r < 0) {
  802342:	83 c4 10             	add    $0x10,%esp
  802345:	85 c0                	test   %eax,%eax
  802347:	78 2c                	js     802375 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802349:	e8 52 e9 ff ff       	call   800ca0 <sys_getenvid>
  80234e:	83 ec 08             	sub    $0x8,%esp
  802351:	68 87 23 80 00       	push   $0x802387
  802356:	50                   	push   %eax
  802357:	e8 cd ea ff ff       	call   800e29 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80235c:	83 c4 10             	add    $0x10,%esp
  80235f:	85 c0                	test   %eax,%eax
  802361:	79 bd                	jns    802320 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802363:	50                   	push   %eax
  802364:	68 18 2e 80 00       	push   $0x802e18
  802369:	6a 28                	push   $0x28
  80236b:	68 4e 2e 80 00       	push   $0x802e4e
  802370:	e8 b8 de ff ff       	call   80022d <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802375:	50                   	push   %eax
  802376:	68 d8 2d 80 00       	push   $0x802dd8
  80237b:	6a 23                	push   $0x23
  80237d:	68 4e 2e 80 00       	push   $0x802e4e
  802382:	e8 a6 de ff ff       	call   80022d <_panic>

00802387 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802387:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802388:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  80238d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80238f:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802392:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802396:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802399:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80239d:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8023a1:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8023a3:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8023a6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8023a7:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8023aa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8023ab:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8023ac:	c3                   	ret    

008023ad <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023ad:	55                   	push   %ebp
  8023ae:	89 e5                	mov    %esp,%ebp
  8023b0:	56                   	push   %esi
  8023b1:	53                   	push   %ebx
  8023b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8023b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023c2:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8023c5:	83 ec 0c             	sub    $0xc,%esp
  8023c8:	50                   	push   %eax
  8023c9:	e8 c0 ea ff ff       	call   800e8e <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8023ce:	83 c4 10             	add    $0x10,%esp
  8023d1:	85 f6                	test   %esi,%esi
  8023d3:	74 17                	je     8023ec <ipc_recv+0x3f>
  8023d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8023da:	85 c0                	test   %eax,%eax
  8023dc:	78 0c                	js     8023ea <ipc_recv+0x3d>
  8023de:	8b 15 00 44 80 00    	mov    0x804400,%edx
  8023e4:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8023ea:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8023ec:	85 db                	test   %ebx,%ebx
  8023ee:	74 17                	je     802407 <ipc_recv+0x5a>
  8023f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8023f5:	85 c0                	test   %eax,%eax
  8023f7:	78 0c                	js     802405 <ipc_recv+0x58>
  8023f9:	8b 15 00 44 80 00    	mov    0x804400,%edx
  8023ff:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  802405:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802407:	85 c0                	test   %eax,%eax
  802409:	78 0b                	js     802416 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  80240b:	a1 00 44 80 00       	mov    0x804400,%eax
  802410:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  802416:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802419:	5b                   	pop    %ebx
  80241a:	5e                   	pop    %esi
  80241b:	5d                   	pop    %ebp
  80241c:	c3                   	ret    

0080241d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80241d:	55                   	push   %ebp
  80241e:	89 e5                	mov    %esp,%ebp
  802420:	57                   	push   %edi
  802421:	56                   	push   %esi
  802422:	53                   	push   %ebx
  802423:	83 ec 0c             	sub    $0xc,%esp
  802426:	8b 7d 08             	mov    0x8(%ebp),%edi
  802429:	8b 75 0c             	mov    0xc(%ebp),%esi
  80242c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80242f:	85 db                	test   %ebx,%ebx
  802431:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802436:	0f 44 d8             	cmove  %eax,%ebx
  802439:	eb 05                	jmp    802440 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80243b:	e8 7f e8 ff ff       	call   800cbf <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802440:	ff 75 14             	push   0x14(%ebp)
  802443:	53                   	push   %ebx
  802444:	56                   	push   %esi
  802445:	57                   	push   %edi
  802446:	e8 20 ea ff ff       	call   800e6b <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80244b:	83 c4 10             	add    $0x10,%esp
  80244e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802451:	74 e8                	je     80243b <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802453:	85 c0                	test   %eax,%eax
  802455:	78 08                	js     80245f <ipc_send+0x42>
	}while (r<0);

}
  802457:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80245a:	5b                   	pop    %ebx
  80245b:	5e                   	pop    %esi
  80245c:	5f                   	pop    %edi
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80245f:	50                   	push   %eax
  802460:	68 5c 2e 80 00       	push   $0x802e5c
  802465:	6a 3d                	push   $0x3d
  802467:	68 70 2e 80 00       	push   $0x802e70
  80246c:	e8 bc dd ff ff       	call   80022d <_panic>

00802471 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802471:	55                   	push   %ebp
  802472:	89 e5                	mov    %esp,%ebp
  802474:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802477:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80247c:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802482:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802488:	8b 52 60             	mov    0x60(%edx),%edx
  80248b:	39 ca                	cmp    %ecx,%edx
  80248d:	74 11                	je     8024a0 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  80248f:	83 c0 01             	add    $0x1,%eax
  802492:	3d 00 04 00 00       	cmp    $0x400,%eax
  802497:	75 e3                	jne    80247c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802499:	b8 00 00 00 00       	mov    $0x0,%eax
  80249e:	eb 0e                	jmp    8024ae <ipc_find_env+0x3d>
			return envs[i].env_id;
  8024a0:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8024a6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024ab:	8b 40 58             	mov    0x58(%eax),%eax
}
  8024ae:	5d                   	pop    %ebp
  8024af:	c3                   	ret    

008024b0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024b0:	55                   	push   %ebp
  8024b1:	89 e5                	mov    %esp,%ebp
  8024b3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024b6:	89 c2                	mov    %eax,%edx
  8024b8:	c1 ea 16             	shr    $0x16,%edx
  8024bb:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8024c2:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8024c7:	f6 c1 01             	test   $0x1,%cl
  8024ca:	74 1c                	je     8024e8 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8024cc:	c1 e8 0c             	shr    $0xc,%eax
  8024cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024d6:	a8 01                	test   $0x1,%al
  8024d8:	74 0e                	je     8024e8 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024da:	c1 e8 0c             	shr    $0xc,%eax
  8024dd:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8024e4:	ef 
  8024e5:	0f b7 d2             	movzwl %dx,%edx
}
  8024e8:	89 d0                	mov    %edx,%eax
  8024ea:	5d                   	pop    %ebp
  8024eb:	c3                   	ret    
  8024ec:	66 90                	xchg   %ax,%ax
  8024ee:	66 90                	xchg   %ax,%ax

008024f0 <__udivdi3>:
  8024f0:	f3 0f 1e fb          	endbr32 
  8024f4:	55                   	push   %ebp
  8024f5:	57                   	push   %edi
  8024f6:	56                   	push   %esi
  8024f7:	53                   	push   %ebx
  8024f8:	83 ec 1c             	sub    $0x1c,%esp
  8024fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802503:	8b 74 24 34          	mov    0x34(%esp),%esi
  802507:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80250b:	85 c0                	test   %eax,%eax
  80250d:	75 19                	jne    802528 <__udivdi3+0x38>
  80250f:	39 f3                	cmp    %esi,%ebx
  802511:	76 4d                	jbe    802560 <__udivdi3+0x70>
  802513:	31 ff                	xor    %edi,%edi
  802515:	89 e8                	mov    %ebp,%eax
  802517:	89 f2                	mov    %esi,%edx
  802519:	f7 f3                	div    %ebx
  80251b:	89 fa                	mov    %edi,%edx
  80251d:	83 c4 1c             	add    $0x1c,%esp
  802520:	5b                   	pop    %ebx
  802521:	5e                   	pop    %esi
  802522:	5f                   	pop    %edi
  802523:	5d                   	pop    %ebp
  802524:	c3                   	ret    
  802525:	8d 76 00             	lea    0x0(%esi),%esi
  802528:	39 f0                	cmp    %esi,%eax
  80252a:	76 14                	jbe    802540 <__udivdi3+0x50>
  80252c:	31 ff                	xor    %edi,%edi
  80252e:	31 c0                	xor    %eax,%eax
  802530:	89 fa                	mov    %edi,%edx
  802532:	83 c4 1c             	add    $0x1c,%esp
  802535:	5b                   	pop    %ebx
  802536:	5e                   	pop    %esi
  802537:	5f                   	pop    %edi
  802538:	5d                   	pop    %ebp
  802539:	c3                   	ret    
  80253a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802540:	0f bd f8             	bsr    %eax,%edi
  802543:	83 f7 1f             	xor    $0x1f,%edi
  802546:	75 48                	jne    802590 <__udivdi3+0xa0>
  802548:	39 f0                	cmp    %esi,%eax
  80254a:	72 06                	jb     802552 <__udivdi3+0x62>
  80254c:	31 c0                	xor    %eax,%eax
  80254e:	39 eb                	cmp    %ebp,%ebx
  802550:	77 de                	ja     802530 <__udivdi3+0x40>
  802552:	b8 01 00 00 00       	mov    $0x1,%eax
  802557:	eb d7                	jmp    802530 <__udivdi3+0x40>
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	89 d9                	mov    %ebx,%ecx
  802562:	85 db                	test   %ebx,%ebx
  802564:	75 0b                	jne    802571 <__udivdi3+0x81>
  802566:	b8 01 00 00 00       	mov    $0x1,%eax
  80256b:	31 d2                	xor    %edx,%edx
  80256d:	f7 f3                	div    %ebx
  80256f:	89 c1                	mov    %eax,%ecx
  802571:	31 d2                	xor    %edx,%edx
  802573:	89 f0                	mov    %esi,%eax
  802575:	f7 f1                	div    %ecx
  802577:	89 c6                	mov    %eax,%esi
  802579:	89 e8                	mov    %ebp,%eax
  80257b:	89 f7                	mov    %esi,%edi
  80257d:	f7 f1                	div    %ecx
  80257f:	89 fa                	mov    %edi,%edx
  802581:	83 c4 1c             	add    $0x1c,%esp
  802584:	5b                   	pop    %ebx
  802585:	5e                   	pop    %esi
  802586:	5f                   	pop    %edi
  802587:	5d                   	pop    %ebp
  802588:	c3                   	ret    
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	89 f9                	mov    %edi,%ecx
  802592:	ba 20 00 00 00       	mov    $0x20,%edx
  802597:	29 fa                	sub    %edi,%edx
  802599:	d3 e0                	shl    %cl,%eax
  80259b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80259f:	89 d1                	mov    %edx,%ecx
  8025a1:	89 d8                	mov    %ebx,%eax
  8025a3:	d3 e8                	shr    %cl,%eax
  8025a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8025a9:	09 c1                	or     %eax,%ecx
  8025ab:	89 f0                	mov    %esi,%eax
  8025ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025b1:	89 f9                	mov    %edi,%ecx
  8025b3:	d3 e3                	shl    %cl,%ebx
  8025b5:	89 d1                	mov    %edx,%ecx
  8025b7:	d3 e8                	shr    %cl,%eax
  8025b9:	89 f9                	mov    %edi,%ecx
  8025bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8025bf:	89 eb                	mov    %ebp,%ebx
  8025c1:	d3 e6                	shl    %cl,%esi
  8025c3:	89 d1                	mov    %edx,%ecx
  8025c5:	d3 eb                	shr    %cl,%ebx
  8025c7:	09 f3                	or     %esi,%ebx
  8025c9:	89 c6                	mov    %eax,%esi
  8025cb:	89 f2                	mov    %esi,%edx
  8025cd:	89 d8                	mov    %ebx,%eax
  8025cf:	f7 74 24 08          	divl   0x8(%esp)
  8025d3:	89 d6                	mov    %edx,%esi
  8025d5:	89 c3                	mov    %eax,%ebx
  8025d7:	f7 64 24 0c          	mull   0xc(%esp)
  8025db:	39 d6                	cmp    %edx,%esi
  8025dd:	72 19                	jb     8025f8 <__udivdi3+0x108>
  8025df:	89 f9                	mov    %edi,%ecx
  8025e1:	d3 e5                	shl    %cl,%ebp
  8025e3:	39 c5                	cmp    %eax,%ebp
  8025e5:	73 04                	jae    8025eb <__udivdi3+0xfb>
  8025e7:	39 d6                	cmp    %edx,%esi
  8025e9:	74 0d                	je     8025f8 <__udivdi3+0x108>
  8025eb:	89 d8                	mov    %ebx,%eax
  8025ed:	31 ff                	xor    %edi,%edi
  8025ef:	e9 3c ff ff ff       	jmp    802530 <__udivdi3+0x40>
  8025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025fb:	31 ff                	xor    %edi,%edi
  8025fd:	e9 2e ff ff ff       	jmp    802530 <__udivdi3+0x40>
  802602:	66 90                	xchg   %ax,%ax
  802604:	66 90                	xchg   %ax,%ax
  802606:	66 90                	xchg   %ax,%ax
  802608:	66 90                	xchg   %ax,%ax
  80260a:	66 90                	xchg   %ax,%ax
  80260c:	66 90                	xchg   %ax,%ax
  80260e:	66 90                	xchg   %ax,%ax

00802610 <__umoddi3>:
  802610:	f3 0f 1e fb          	endbr32 
  802614:	55                   	push   %ebp
  802615:	57                   	push   %edi
  802616:	56                   	push   %esi
  802617:	53                   	push   %ebx
  802618:	83 ec 1c             	sub    $0x1c,%esp
  80261b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80261f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802623:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802627:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80262b:	89 f0                	mov    %esi,%eax
  80262d:	89 da                	mov    %ebx,%edx
  80262f:	85 ff                	test   %edi,%edi
  802631:	75 15                	jne    802648 <__umoddi3+0x38>
  802633:	39 dd                	cmp    %ebx,%ebp
  802635:	76 39                	jbe    802670 <__umoddi3+0x60>
  802637:	f7 f5                	div    %ebp
  802639:	89 d0                	mov    %edx,%eax
  80263b:	31 d2                	xor    %edx,%edx
  80263d:	83 c4 1c             	add    $0x1c,%esp
  802640:	5b                   	pop    %ebx
  802641:	5e                   	pop    %esi
  802642:	5f                   	pop    %edi
  802643:	5d                   	pop    %ebp
  802644:	c3                   	ret    
  802645:	8d 76 00             	lea    0x0(%esi),%esi
  802648:	39 df                	cmp    %ebx,%edi
  80264a:	77 f1                	ja     80263d <__umoddi3+0x2d>
  80264c:	0f bd cf             	bsr    %edi,%ecx
  80264f:	83 f1 1f             	xor    $0x1f,%ecx
  802652:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802656:	75 40                	jne    802698 <__umoddi3+0x88>
  802658:	39 df                	cmp    %ebx,%edi
  80265a:	72 04                	jb     802660 <__umoddi3+0x50>
  80265c:	39 f5                	cmp    %esi,%ebp
  80265e:	77 dd                	ja     80263d <__umoddi3+0x2d>
  802660:	89 da                	mov    %ebx,%edx
  802662:	89 f0                	mov    %esi,%eax
  802664:	29 e8                	sub    %ebp,%eax
  802666:	19 fa                	sbb    %edi,%edx
  802668:	eb d3                	jmp    80263d <__umoddi3+0x2d>
  80266a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802670:	89 e9                	mov    %ebp,%ecx
  802672:	85 ed                	test   %ebp,%ebp
  802674:	75 0b                	jne    802681 <__umoddi3+0x71>
  802676:	b8 01 00 00 00       	mov    $0x1,%eax
  80267b:	31 d2                	xor    %edx,%edx
  80267d:	f7 f5                	div    %ebp
  80267f:	89 c1                	mov    %eax,%ecx
  802681:	89 d8                	mov    %ebx,%eax
  802683:	31 d2                	xor    %edx,%edx
  802685:	f7 f1                	div    %ecx
  802687:	89 f0                	mov    %esi,%eax
  802689:	f7 f1                	div    %ecx
  80268b:	89 d0                	mov    %edx,%eax
  80268d:	31 d2                	xor    %edx,%edx
  80268f:	eb ac                	jmp    80263d <__umoddi3+0x2d>
  802691:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802698:	8b 44 24 04          	mov    0x4(%esp),%eax
  80269c:	ba 20 00 00 00       	mov    $0x20,%edx
  8026a1:	29 c2                	sub    %eax,%edx
  8026a3:	89 c1                	mov    %eax,%ecx
  8026a5:	89 e8                	mov    %ebp,%eax
  8026a7:	d3 e7                	shl    %cl,%edi
  8026a9:	89 d1                	mov    %edx,%ecx
  8026ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8026af:	d3 e8                	shr    %cl,%eax
  8026b1:	89 c1                	mov    %eax,%ecx
  8026b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026b7:	09 f9                	or     %edi,%ecx
  8026b9:	89 df                	mov    %ebx,%edi
  8026bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026bf:	89 c1                	mov    %eax,%ecx
  8026c1:	d3 e5                	shl    %cl,%ebp
  8026c3:	89 d1                	mov    %edx,%ecx
  8026c5:	d3 ef                	shr    %cl,%edi
  8026c7:	89 c1                	mov    %eax,%ecx
  8026c9:	89 f0                	mov    %esi,%eax
  8026cb:	d3 e3                	shl    %cl,%ebx
  8026cd:	89 d1                	mov    %edx,%ecx
  8026cf:	89 fa                	mov    %edi,%edx
  8026d1:	d3 e8                	shr    %cl,%eax
  8026d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026d8:	09 d8                	or     %ebx,%eax
  8026da:	f7 74 24 08          	divl   0x8(%esp)
  8026de:	89 d3                	mov    %edx,%ebx
  8026e0:	d3 e6                	shl    %cl,%esi
  8026e2:	f7 e5                	mul    %ebp
  8026e4:	89 c7                	mov    %eax,%edi
  8026e6:	89 d1                	mov    %edx,%ecx
  8026e8:	39 d3                	cmp    %edx,%ebx
  8026ea:	72 06                	jb     8026f2 <__umoddi3+0xe2>
  8026ec:	75 0e                	jne    8026fc <__umoddi3+0xec>
  8026ee:	39 c6                	cmp    %eax,%esi
  8026f0:	73 0a                	jae    8026fc <__umoddi3+0xec>
  8026f2:	29 e8                	sub    %ebp,%eax
  8026f4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026f8:	89 d1                	mov    %edx,%ecx
  8026fa:	89 c7                	mov    %eax,%edi
  8026fc:	89 f5                	mov    %esi,%ebp
  8026fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802702:	29 fd                	sub    %edi,%ebp
  802704:	19 cb                	sbb    %ecx,%ebx
  802706:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80270b:	89 d8                	mov    %ebx,%eax
  80270d:	d3 e0                	shl    %cl,%eax
  80270f:	89 f1                	mov    %esi,%ecx
  802711:	d3 ed                	shr    %cl,%ebp
  802713:	d3 eb                	shr    %cl,%ebx
  802715:	09 e8                	or     %ebp,%eax
  802717:	89 da                	mov    %ebx,%edx
  802719:	83 c4 1c             	add    $0x1c,%esp
  80271c:	5b                   	pop    %ebx
  80271d:	5e                   	pop    %esi
  80271e:	5f                   	pop    %edi
  80271f:	5d                   	pop    %ebp
  802720:	c3                   	ret    
