
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
  80003e:	68 60 22 80 00       	push   $0x802260
  800043:	e8 40 18 00 00       	call   801888 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	0f 88 ff 00 00 00    	js     800154 <umain+0x121>
		panic("open motd: %e", fd);
	seek(fd, 0);
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	6a 00                	push   $0x0
  80005a:	50                   	push   %eax
  80005b:	e8 15 15 00 00       	call   801575 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800060:	83 c4 0c             	add    $0xc,%esp
  800063:	68 00 02 00 00       	push   $0x200
  800068:	68 00 42 80 00       	push   $0x804200
  80006d:	53                   	push   %ebx
  80006e:	e8 39 14 00 00       	call   8014ac <readn>
  800073:	89 c6                	mov    %eax,%esi
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	85 c0                	test   %eax,%eax
  80007a:	0f 8e e6 00 00 00    	jle    800166 <umain+0x133>
		panic("readn: %e", n);

	if ((r = fork()) < 0)
  800080:	e8 45 0f 00 00       	call   800fca <fork>
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
  800097:	e8 d9 14 00 00       	call   801575 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  80009c:	c7 04 24 c8 22 80 00 	movl   $0x8022c8,(%esp)
  8000a3:	e8 5d 02 00 00       	call   800305 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	68 00 02 00 00       	push   $0x200
  8000b0:	68 00 40 80 00       	push   $0x804000
  8000b5:	53                   	push   %ebx
  8000b6:	e8 f1 13 00 00       	call   8014ac <readn>
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	39 c6                	cmp    %eax,%esi
  8000c0:	0f 85 c4 00 00 00    	jne    80018a <umain+0x157>
			panic("read in parent got %d, read in child got %d", n, n2);
		if (memcmp(buf, buf2, n) != 0)
  8000c6:	83 ec 04             	sub    $0x4,%esp
  8000c9:	56                   	push   %esi
  8000ca:	68 00 40 80 00       	push   $0x804000
  8000cf:	68 00 42 80 00       	push   $0x804200
  8000d4:	e8 14 0a 00 00       	call   800aed <memcmp>
  8000d9:	83 c4 10             	add    $0x10,%esp
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	0f 85 bc 00 00 00    	jne    8001a0 <umain+0x16d>
			panic("read in parent got different bytes from read in child");
		cprintf("read in child succeeded\n");
  8000e4:	83 ec 0c             	sub    $0xc,%esp
  8000e7:	68 92 22 80 00       	push   $0x802292
  8000ec:	e8 14 02 00 00       	call   800305 <cprintf>
		seek(fd, 0);
  8000f1:	83 c4 08             	add    $0x8,%esp
  8000f4:	6a 00                	push   $0x0
  8000f6:	53                   	push   %ebx
  8000f7:	e8 79 14 00 00       	call   801575 <seek>
		close(fd);
  8000fc:	89 1c 24             	mov    %ebx,(%esp)
  8000ff:	e8 e5 11 00 00       	call   8012e9 <close>
		exit();
  800104:	e8 07 01 00 00       	call   800210 <exit>
  800109:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80010c:	83 ec 0c             	sub    $0xc,%esp
  80010f:	57                   	push   %edi
  800110:	e8 62 1b 00 00       	call   801c77 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800115:	83 c4 0c             	add    $0xc,%esp
  800118:	68 00 02 00 00       	push   $0x200
  80011d:	68 00 40 80 00       	push   $0x804000
  800122:	53                   	push   %ebx
  800123:	e8 84 13 00 00       	call   8014ac <readn>
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	39 c6                	cmp    %eax,%esi
  80012d:	0f 85 81 00 00 00    	jne    8001b4 <umain+0x181>
		panic("read in parent got %d, then got %d", n, n2);
	cprintf("read in parent succeeded\n");
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	68 ab 22 80 00       	push   $0x8022ab
  80013b:	e8 c5 01 00 00       	call   800305 <cprintf>
	close(fd);
  800140:	89 1c 24             	mov    %ebx,(%esp)
  800143:	e8 a1 11 00 00       	call   8012e9 <close>
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
  800155:	68 65 22 80 00       	push   $0x802265
  80015a:	6a 0c                	push   $0xc
  80015c:	68 73 22 80 00       	push   $0x802273
  800161:	e8 c4 00 00 00       	call   80022a <_panic>
		panic("readn: %e", n);
  800166:	50                   	push   %eax
  800167:	68 88 22 80 00       	push   $0x802288
  80016c:	6a 0f                	push   $0xf
  80016e:	68 73 22 80 00       	push   $0x802273
  800173:	e8 b2 00 00 00       	call   80022a <_panic>
		panic("fork: %e", r);
  800178:	50                   	push   %eax
  800179:	68 98 27 80 00       	push   $0x802798
  80017e:	6a 12                	push   $0x12
  800180:	68 73 22 80 00       	push   $0x802273
  800185:	e8 a0 00 00 00       	call   80022a <_panic>
			panic("read in parent got %d, read in child got %d", n, n2);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	56                   	push   %esi
  80018f:	68 0c 23 80 00       	push   $0x80230c
  800194:	6a 17                	push   $0x17
  800196:	68 73 22 80 00       	push   $0x802273
  80019b:	e8 8a 00 00 00       	call   80022a <_panic>
			panic("read in parent got different bytes from read in child");
  8001a0:	83 ec 04             	sub    $0x4,%esp
  8001a3:	68 38 23 80 00       	push   $0x802338
  8001a8:	6a 19                	push   $0x19
  8001aa:	68 73 22 80 00       	push   $0x802273
  8001af:	e8 76 00 00 00       	call   80022a <_panic>
		panic("read in parent got %d, then got %d", n, n2);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	50                   	push   %eax
  8001b8:	56                   	push   %esi
  8001b9:	68 70 23 80 00       	push   $0x802370
  8001be:	6a 21                	push   $0x21
  8001c0:	68 73 22 80 00       	push   $0x802273
  8001c5:	e8 60 00 00 00       	call   80022a <_panic>

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
  8001d5:	e8 c3 0a 00 00       	call   800c9d <sys_getenvid>
  8001da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e7:	a3 00 44 80 00       	mov    %eax,0x804400

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ec:	85 db                	test   %ebx,%ebx
  8001ee:	7e 07                	jle    8001f7 <libmain+0x2d>
		binaryname = argv[0];
  8001f0:	8b 06                	mov    (%esi),%eax
  8001f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001f7:	83 ec 08             	sub    $0x8,%esp
  8001fa:	56                   	push   %esi
  8001fb:	53                   	push   %ebx
  8001fc:	e8 32 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800201:	e8 0a 00 00 00       	call   800210 <exit>
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5e                   	pop    %esi
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    

00800210 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800216:	e8 fb 10 00 00       	call   801316 <close_all>
	sys_env_destroy(0);
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	6a 00                	push   $0x0
  800220:	e8 37 0a 00 00       	call   800c5c <sys_env_destroy>
}
  800225:	83 c4 10             	add    $0x10,%esp
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80022f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800232:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800238:	e8 60 0a 00 00       	call   800c9d <sys_getenvid>
  80023d:	83 ec 0c             	sub    $0xc,%esp
  800240:	ff 75 0c             	push   0xc(%ebp)
  800243:	ff 75 08             	push   0x8(%ebp)
  800246:	56                   	push   %esi
  800247:	50                   	push   %eax
  800248:	68 a0 23 80 00       	push   $0x8023a0
  80024d:	e8 b3 00 00 00       	call   800305 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800252:	83 c4 18             	add    $0x18,%esp
  800255:	53                   	push   %ebx
  800256:	ff 75 10             	push   0x10(%ebp)
  800259:	e8 56 00 00 00       	call   8002b4 <vcprintf>
	cprintf("\n");
  80025e:	c7 04 24 a9 22 80 00 	movl   $0x8022a9,(%esp)
  800265:	e8 9b 00 00 00       	call   800305 <cprintf>
  80026a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026d:	cc                   	int3   
  80026e:	eb fd                	jmp    80026d <_panic+0x43>

00800270 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	53                   	push   %ebx
  800274:	83 ec 04             	sub    $0x4,%esp
  800277:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027a:	8b 13                	mov    (%ebx),%edx
  80027c:	8d 42 01             	lea    0x1(%edx),%eax
  80027f:	89 03                	mov    %eax,(%ebx)
  800281:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800284:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800288:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028d:	74 09                	je     800298 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80028f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800296:	c9                   	leave  
  800297:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	68 ff 00 00 00       	push   $0xff
  8002a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 76 09 00 00       	call   800c1f <sys_cputs>
		b->idx = 0;
  8002a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002af:	83 c4 10             	add    $0x10,%esp
  8002b2:	eb db                	jmp    80028f <putch+0x1f>

008002b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c4:	00 00 00 
	b.cnt = 0;
  8002c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d1:	ff 75 0c             	push   0xc(%ebp)
  8002d4:	ff 75 08             	push   0x8(%ebp)
  8002d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002dd:	50                   	push   %eax
  8002de:	68 70 02 80 00       	push   $0x800270
  8002e3:	e8 14 01 00 00       	call   8003fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e8:	83 c4 08             	add    $0x8,%esp
  8002eb:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f7:	50                   	push   %eax
  8002f8:	e8 22 09 00 00       	call   800c1f <sys_cputs>

	return b.cnt;
}
  8002fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80030e:	50                   	push   %eax
  80030f:	ff 75 08             	push   0x8(%ebp)
  800312:	e8 9d ff ff ff       	call   8002b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 1c             	sub    $0x1c,%esp
  800322:	89 c7                	mov    %eax,%edi
  800324:	89 d6                	mov    %edx,%esi
  800326:	8b 45 08             	mov    0x8(%ebp),%eax
  800329:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032c:	89 d1                	mov    %edx,%ecx
  80032e:	89 c2                	mov    %eax,%edx
  800330:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800333:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800336:	8b 45 10             	mov    0x10(%ebp),%eax
  800339:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800346:	39 c2                	cmp    %eax,%edx
  800348:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80034b:	72 3e                	jb     80038b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034d:	83 ec 0c             	sub    $0xc,%esp
  800350:	ff 75 18             	push   0x18(%ebp)
  800353:	83 eb 01             	sub    $0x1,%ebx
  800356:	53                   	push   %ebx
  800357:	50                   	push   %eax
  800358:	83 ec 08             	sub    $0x8,%esp
  80035b:	ff 75 e4             	push   -0x1c(%ebp)
  80035e:	ff 75 e0             	push   -0x20(%ebp)
  800361:	ff 75 dc             	push   -0x24(%ebp)
  800364:	ff 75 d8             	push   -0x28(%ebp)
  800367:	e8 a4 1c 00 00       	call   802010 <__udivdi3>
  80036c:	83 c4 18             	add    $0x18,%esp
  80036f:	52                   	push   %edx
  800370:	50                   	push   %eax
  800371:	89 f2                	mov    %esi,%edx
  800373:	89 f8                	mov    %edi,%eax
  800375:	e8 9f ff ff ff       	call   800319 <printnum>
  80037a:	83 c4 20             	add    $0x20,%esp
  80037d:	eb 13                	jmp    800392 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	56                   	push   %esi
  800383:	ff 75 18             	push   0x18(%ebp)
  800386:	ff d7                	call   *%edi
  800388:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80038b:	83 eb 01             	sub    $0x1,%ebx
  80038e:	85 db                	test   %ebx,%ebx
  800390:	7f ed                	jg     80037f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	56                   	push   %esi
  800396:	83 ec 04             	sub    $0x4,%esp
  800399:	ff 75 e4             	push   -0x1c(%ebp)
  80039c:	ff 75 e0             	push   -0x20(%ebp)
  80039f:	ff 75 dc             	push   -0x24(%ebp)
  8003a2:	ff 75 d8             	push   -0x28(%ebp)
  8003a5:	e8 86 1d 00 00       	call   802130 <__umoddi3>
  8003aa:	83 c4 14             	add    $0x14,%esp
  8003ad:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
  8003b4:	50                   	push   %eax
  8003b5:	ff d7                	call   *%edi
}
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003bd:	5b                   	pop    %ebx
  8003be:	5e                   	pop    %esi
  8003bf:	5f                   	pop    %edi
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d1:	73 0a                	jae    8003dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d6:	89 08                	mov    %ecx,(%eax)
  8003d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003db:	88 02                	mov    %al,(%edx)
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <printfmt>:
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e8:	50                   	push   %eax
  8003e9:	ff 75 10             	push   0x10(%ebp)
  8003ec:	ff 75 0c             	push   0xc(%ebp)
  8003ef:	ff 75 08             	push   0x8(%ebp)
  8003f2:	e8 05 00 00 00       	call   8003fc <vprintfmt>
}
  8003f7:	83 c4 10             	add    $0x10,%esp
  8003fa:	c9                   	leave  
  8003fb:	c3                   	ret    

008003fc <vprintfmt>:
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	57                   	push   %edi
  800400:	56                   	push   %esi
  800401:	53                   	push   %ebx
  800402:	83 ec 3c             	sub    $0x3c,%esp
  800405:	8b 75 08             	mov    0x8(%ebp),%esi
  800408:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80040b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80040e:	eb 0a                	jmp    80041a <vprintfmt+0x1e>
			putch(ch, putdat);
  800410:	83 ec 08             	sub    $0x8,%esp
  800413:	53                   	push   %ebx
  800414:	50                   	push   %eax
  800415:	ff d6                	call   *%esi
  800417:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041a:	83 c7 01             	add    $0x1,%edi
  80041d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800421:	83 f8 25             	cmp    $0x25,%eax
  800424:	74 0c                	je     800432 <vprintfmt+0x36>
			if (ch == '\0')
  800426:	85 c0                	test   %eax,%eax
  800428:	75 e6                	jne    800410 <vprintfmt+0x14>
}
  80042a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042d:	5b                   	pop    %ebx
  80042e:	5e                   	pop    %esi
  80042f:	5f                   	pop    %edi
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    
		padc = ' ';
  800432:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800436:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80043d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800444:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80044b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8d 47 01             	lea    0x1(%edi),%eax
  800453:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800456:	0f b6 17             	movzbl (%edi),%edx
  800459:	8d 42 dd             	lea    -0x23(%edx),%eax
  80045c:	3c 55                	cmp    $0x55,%al
  80045e:	0f 87 bb 03 00 00    	ja     80081f <vprintfmt+0x423>
  800464:	0f b6 c0             	movzbl %al,%eax
  800467:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800471:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800475:	eb d9                	jmp    800450 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80047e:	eb d0                	jmp    800450 <vprintfmt+0x54>
  800480:	0f b6 d2             	movzbl %dl,%edx
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800486:	b8 00 00 00 00       	mov    $0x0,%eax
  80048b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80048e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800491:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800495:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800498:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80049b:	83 f9 09             	cmp    $0x9,%ecx
  80049e:	77 55                	ja     8004f5 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8004a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004a3:	eb e9                	jmp    80048e <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8b 00                	mov    (%eax),%eax
  8004aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 40 04             	lea    0x4(%eax),%eax
  8004b3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bd:	79 91                	jns    800450 <vprintfmt+0x54>
				width = precision, precision = -1;
  8004bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004cc:	eb 82                	jmp    800450 <vprintfmt+0x54>
  8004ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	0f 49 c2             	cmovns %edx,%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004e1:	e9 6a ff ff ff       	jmp    800450 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004e9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004f0:	e9 5b ff ff ff       	jmp    800450 <vprintfmt+0x54>
  8004f5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fb:	eb bc                	jmp    8004b9 <vprintfmt+0xbd>
			lflag++;
  8004fd:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800503:	e9 48 ff ff ff       	jmp    800450 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 78 04             	lea    0x4(%eax),%edi
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	ff 30                	push   (%eax)
  800514:	ff d6                	call   *%esi
			break;
  800516:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800519:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80051c:	e9 9d 02 00 00       	jmp    8007be <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 78 04             	lea    0x4(%eax),%edi
  800527:	8b 10                	mov    (%eax),%edx
  800529:	89 d0                	mov    %edx,%eax
  80052b:	f7 d8                	neg    %eax
  80052d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800530:	83 f8 0f             	cmp    $0xf,%eax
  800533:	7f 23                	jg     800558 <vprintfmt+0x15c>
  800535:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  80053c:	85 d2                	test   %edx,%edx
  80053e:	74 18                	je     800558 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800540:	52                   	push   %edx
  800541:	68 5d 28 80 00       	push   $0x80285d
  800546:	53                   	push   %ebx
  800547:	56                   	push   %esi
  800548:	e8 92 fe ff ff       	call   8003df <printfmt>
  80054d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800550:	89 7d 14             	mov    %edi,0x14(%ebp)
  800553:	e9 66 02 00 00       	jmp    8007be <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800558:	50                   	push   %eax
  800559:	68 db 23 80 00       	push   $0x8023db
  80055e:	53                   	push   %ebx
  80055f:	56                   	push   %esi
  800560:	e8 7a fe ff ff       	call   8003df <printfmt>
  800565:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800568:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80056b:	e9 4e 02 00 00       	jmp    8007be <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	83 c0 04             	add    $0x4,%eax
  800576:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80057e:	85 d2                	test   %edx,%edx
  800580:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
  800585:	0f 45 c2             	cmovne %edx,%eax
  800588:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80058b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058f:	7e 06                	jle    800597 <vprintfmt+0x19b>
  800591:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800595:	75 0d                	jne    8005a4 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80059a:	89 c7                	mov    %eax,%edi
  80059c:	03 45 e0             	add    -0x20(%ebp),%eax
  80059f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a2:	eb 55                	jmp    8005f9 <vprintfmt+0x1fd>
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	ff 75 d8             	push   -0x28(%ebp)
  8005aa:	ff 75 cc             	push   -0x34(%ebp)
  8005ad:	e8 0a 03 00 00       	call   8008bc <strnlen>
  8005b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b5:	29 c1                	sub    %eax,%ecx
  8005b7:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8005ba:	83 c4 10             	add    $0x10,%esp
  8005bd:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8005bf:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c6:	eb 0f                	jmp    8005d7 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	ff 75 e0             	push   -0x20(%ebp)
  8005cf:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	83 ef 01             	sub    $0x1,%edi
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	85 ff                	test   %edi,%edi
  8005d9:	7f ed                	jg     8005c8 <vprintfmt+0x1cc>
  8005db:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e5:	0f 49 c2             	cmovns %edx,%eax
  8005e8:	29 c2                	sub    %eax,%edx
  8005ea:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ed:	eb a8                	jmp    800597 <vprintfmt+0x19b>
					putch(ch, putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	52                   	push   %edx
  8005f4:	ff d6                	call   *%esi
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fe:	83 c7 01             	add    $0x1,%edi
  800601:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800605:	0f be d0             	movsbl %al,%edx
  800608:	85 d2                	test   %edx,%edx
  80060a:	74 4b                	je     800657 <vprintfmt+0x25b>
  80060c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800610:	78 06                	js     800618 <vprintfmt+0x21c>
  800612:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800616:	78 1e                	js     800636 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800618:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80061c:	74 d1                	je     8005ef <vprintfmt+0x1f3>
  80061e:	0f be c0             	movsbl %al,%eax
  800621:	83 e8 20             	sub    $0x20,%eax
  800624:	83 f8 5e             	cmp    $0x5e,%eax
  800627:	76 c6                	jbe    8005ef <vprintfmt+0x1f3>
					putch('?', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 3f                	push   $0x3f
  80062f:	ff d6                	call   *%esi
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb c3                	jmp    8005f9 <vprintfmt+0x1fd>
  800636:	89 cf                	mov    %ecx,%edi
  800638:	eb 0e                	jmp    800648 <vprintfmt+0x24c>
				putch(' ', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 20                	push   $0x20
  800640:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800642:	83 ef 01             	sub    $0x1,%edi
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	85 ff                	test   %edi,%edi
  80064a:	7f ee                	jg     80063a <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80064c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80064f:	89 45 14             	mov    %eax,0x14(%ebp)
  800652:	e9 67 01 00 00       	jmp    8007be <vprintfmt+0x3c2>
  800657:	89 cf                	mov    %ecx,%edi
  800659:	eb ed                	jmp    800648 <vprintfmt+0x24c>
	if (lflag >= 2)
  80065b:	83 f9 01             	cmp    $0x1,%ecx
  80065e:	7f 1b                	jg     80067b <vprintfmt+0x27f>
	else if (lflag)
  800660:	85 c9                	test   %ecx,%ecx
  800662:	74 63                	je     8006c7 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	99                   	cltd   
  80066d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
  800679:	eb 17                	jmp    800692 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8b 50 04             	mov    0x4(%eax),%edx
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800686:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 40 08             	lea    0x8(%eax),%eax
  80068f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800692:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800695:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800698:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80069d:	85 c9                	test   %ecx,%ecx
  80069f:	0f 89 ff 00 00 00    	jns    8007a4 <vprintfmt+0x3a8>
				putch('-', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 2d                	push   $0x2d
  8006ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b3:	f7 da                	neg    %edx
  8006b5:	83 d1 00             	adc    $0x0,%ecx
  8006b8:	f7 d9                	neg    %ecx
  8006ba:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006bd:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006c2:	e9 dd 00 00 00       	jmp    8007a4 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 00                	mov    (%eax),%eax
  8006cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cf:	99                   	cltd   
  8006d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 40 04             	lea    0x4(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006dc:	eb b4                	jmp    800692 <vprintfmt+0x296>
	if (lflag >= 2)
  8006de:	83 f9 01             	cmp    $0x1,%ecx
  8006e1:	7f 1e                	jg     800701 <vprintfmt+0x305>
	else if (lflag)
  8006e3:	85 c9                	test   %ecx,%ecx
  8006e5:	74 32                	je     800719 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8006fc:	e9 a3 00 00 00       	jmp    8007a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8b 10                	mov    (%eax),%edx
  800706:	8b 48 04             	mov    0x4(%eax),%ecx
  800709:	8d 40 08             	lea    0x8(%eax),%eax
  80070c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800714:	e9 8b 00 00 00       	jmp    8007a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8b 10                	mov    (%eax),%edx
  80071e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800723:	8d 40 04             	lea    0x4(%eax),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800729:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80072e:	eb 74                	jmp    8007a4 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800730:	83 f9 01             	cmp    $0x1,%ecx
  800733:	7f 1b                	jg     800750 <vprintfmt+0x354>
	else if (lflag)
  800735:	85 c9                	test   %ecx,%ecx
  800737:	74 2c                	je     800765 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8b 10                	mov    (%eax),%edx
  80073e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800743:	8d 40 04             	lea    0x4(%eax),%eax
  800746:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800749:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80074e:	eb 54                	jmp    8007a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 10                	mov    (%eax),%edx
  800755:	8b 48 04             	mov    0x4(%eax),%ecx
  800758:	8d 40 08             	lea    0x8(%eax),%eax
  80075b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80075e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800763:	eb 3f                	jmp    8007a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8b 10                	mov    (%eax),%edx
  80076a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076f:	8d 40 04             	lea    0x4(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800775:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80077a:	eb 28                	jmp    8007a4 <vprintfmt+0x3a8>
			putch('0', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 30                	push   $0x30
  800782:	ff d6                	call   *%esi
			putch('x', putdat);
  800784:	83 c4 08             	add    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 78                	push   $0x78
  80078a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8b 10                	mov    (%eax),%edx
  800791:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800796:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800799:	8d 40 04             	lea    0x4(%eax),%eax
  80079c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079f:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007a4:	83 ec 0c             	sub    $0xc,%esp
  8007a7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8007ab:	50                   	push   %eax
  8007ac:	ff 75 e0             	push   -0x20(%ebp)
  8007af:	57                   	push   %edi
  8007b0:	51                   	push   %ecx
  8007b1:	52                   	push   %edx
  8007b2:	89 da                	mov    %ebx,%edx
  8007b4:	89 f0                	mov    %esi,%eax
  8007b6:	e8 5e fb ff ff       	call   800319 <printnum>
			break;
  8007bb:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c1:	e9 54 fc ff ff       	jmp    80041a <vprintfmt+0x1e>
	if (lflag >= 2)
  8007c6:	83 f9 01             	cmp    $0x1,%ecx
  8007c9:	7f 1b                	jg     8007e6 <vprintfmt+0x3ea>
	else if (lflag)
  8007cb:	85 c9                	test   %ecx,%ecx
  8007cd:	74 2c                	je     8007fb <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 10                	mov    (%eax),%edx
  8007d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d9:	8d 40 04             	lea    0x4(%eax),%eax
  8007dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007df:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8007e4:	eb be                	jmp    8007a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8b 10                	mov    (%eax),%edx
  8007eb:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ee:	8d 40 08             	lea    0x8(%eax),%eax
  8007f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8007f9:	eb a9                	jmp    8007a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8b 10                	mov    (%eax),%edx
  800800:	b9 00 00 00 00       	mov    $0x0,%ecx
  800805:	8d 40 04             	lea    0x4(%eax),%eax
  800808:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800810:	eb 92                	jmp    8007a4 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	53                   	push   %ebx
  800816:	6a 25                	push   $0x25
  800818:	ff d6                	call   *%esi
			break;
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	eb 9f                	jmp    8007be <vprintfmt+0x3c2>
			putch('%', putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	53                   	push   %ebx
  800823:	6a 25                	push   $0x25
  800825:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	89 f8                	mov    %edi,%eax
  80082c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800830:	74 05                	je     800837 <vprintfmt+0x43b>
  800832:	83 e8 01             	sub    $0x1,%eax
  800835:	eb f5                	jmp    80082c <vprintfmt+0x430>
  800837:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80083a:	eb 82                	jmp    8007be <vprintfmt+0x3c2>

0080083c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 18             	sub    $0x18,%esp
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800848:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80084f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800852:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800859:	85 c0                	test   %eax,%eax
  80085b:	74 26                	je     800883 <vsnprintf+0x47>
  80085d:	85 d2                	test   %edx,%edx
  80085f:	7e 22                	jle    800883 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800861:	ff 75 14             	push   0x14(%ebp)
  800864:	ff 75 10             	push   0x10(%ebp)
  800867:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086a:	50                   	push   %eax
  80086b:	68 c2 03 80 00       	push   $0x8003c2
  800870:	e8 87 fb ff ff       	call   8003fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800875:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800878:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087e:	83 c4 10             	add    $0x10,%esp
}
  800881:	c9                   	leave  
  800882:	c3                   	ret    
		return -E_INVAL;
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800888:	eb f7                	jmp    800881 <vsnprintf+0x45>

0080088a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800890:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800893:	50                   	push   %eax
  800894:	ff 75 10             	push   0x10(%ebp)
  800897:	ff 75 0c             	push   0xc(%ebp)
  80089a:	ff 75 08             	push   0x8(%ebp)
  80089d:	e8 9a ff ff ff       	call   80083c <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008af:	eb 03                	jmp    8008b4 <strlen+0x10>
		n++;
  8008b1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008b4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b8:	75 f7                	jne    8008b1 <strlen+0xd>
	return n;
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ca:	eb 03                	jmp    8008cf <strnlen+0x13>
		n++;
  8008cc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cf:	39 d0                	cmp    %edx,%eax
  8008d1:	74 08                	je     8008db <strnlen+0x1f>
  8008d3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d7:	75 f3                	jne    8008cc <strnlen+0x10>
  8008d9:	89 c2                	mov    %eax,%edx
	return n;
}
  8008db:	89 d0                	mov    %edx,%eax
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	53                   	push   %ebx
  8008e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ee:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008f2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	75 f2                	jne    8008ee <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008fc:	89 c8                	mov    %ecx,%eax
  8008fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	83 ec 10             	sub    $0x10,%esp
  80090a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090d:	53                   	push   %ebx
  80090e:	e8 91 ff ff ff       	call   8008a4 <strlen>
  800913:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800916:	ff 75 0c             	push   0xc(%ebp)
  800919:	01 d8                	add    %ebx,%eax
  80091b:	50                   	push   %eax
  80091c:	e8 be ff ff ff       	call   8008df <strcpy>
	return dst;
}
  800921:	89 d8                	mov    %ebx,%eax
  800923:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 75 08             	mov    0x8(%ebp),%esi
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
  800933:	89 f3                	mov    %esi,%ebx
  800935:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800938:	89 f0                	mov    %esi,%eax
  80093a:	eb 0f                	jmp    80094b <strncpy+0x23>
		*dst++ = *src;
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	0f b6 0a             	movzbl (%edx),%ecx
  800942:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800945:	80 f9 01             	cmp    $0x1,%cl
  800948:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80094b:	39 d8                	cmp    %ebx,%eax
  80094d:	75 ed                	jne    80093c <strncpy+0x14>
	}
	return ret;
}
  80094f:	89 f0                	mov    %esi,%eax
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 75 08             	mov    0x8(%ebp),%esi
  80095d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800960:	8b 55 10             	mov    0x10(%ebp),%edx
  800963:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800965:	85 d2                	test   %edx,%edx
  800967:	74 21                	je     80098a <strlcpy+0x35>
  800969:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80096d:	89 f2                	mov    %esi,%edx
  80096f:	eb 09                	jmp    80097a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800971:	83 c1 01             	add    $0x1,%ecx
  800974:	83 c2 01             	add    $0x1,%edx
  800977:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80097a:	39 c2                	cmp    %eax,%edx
  80097c:	74 09                	je     800987 <strlcpy+0x32>
  80097e:	0f b6 19             	movzbl (%ecx),%ebx
  800981:	84 db                	test   %bl,%bl
  800983:	75 ec                	jne    800971 <strlcpy+0x1c>
  800985:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800987:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098a:	29 f0                	sub    %esi,%eax
}
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800996:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800999:	eb 06                	jmp    8009a1 <strcmp+0x11>
		p++, q++;
  80099b:	83 c1 01             	add    $0x1,%ecx
  80099e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a1:	0f b6 01             	movzbl (%ecx),%eax
  8009a4:	84 c0                	test   %al,%al
  8009a6:	74 04                	je     8009ac <strcmp+0x1c>
  8009a8:	3a 02                	cmp    (%edx),%al
  8009aa:	74 ef                	je     80099b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ac:	0f b6 c0             	movzbl %al,%eax
  8009af:	0f b6 12             	movzbl (%edx),%edx
  8009b2:	29 d0                	sub    %edx,%eax
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	53                   	push   %ebx
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c0:	89 c3                	mov    %eax,%ebx
  8009c2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c5:	eb 06                	jmp    8009cd <strncmp+0x17>
		n--, p++, q++;
  8009c7:	83 c0 01             	add    $0x1,%eax
  8009ca:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009cd:	39 d8                	cmp    %ebx,%eax
  8009cf:	74 18                	je     8009e9 <strncmp+0x33>
  8009d1:	0f b6 08             	movzbl (%eax),%ecx
  8009d4:	84 c9                	test   %cl,%cl
  8009d6:	74 04                	je     8009dc <strncmp+0x26>
  8009d8:	3a 0a                	cmp    (%edx),%cl
  8009da:	74 eb                	je     8009c7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009dc:	0f b6 00             	movzbl (%eax),%eax
  8009df:	0f b6 12             	movzbl (%edx),%edx
  8009e2:	29 d0                	sub    %edx,%eax
}
  8009e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    
		return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ee:	eb f4                	jmp    8009e4 <strncmp+0x2e>

008009f0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fa:	eb 03                	jmp    8009ff <strchr+0xf>
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	0f b6 10             	movzbl (%eax),%edx
  800a02:	84 d2                	test   %dl,%dl
  800a04:	74 06                	je     800a0c <strchr+0x1c>
		if (*s == c)
  800a06:	38 ca                	cmp    %cl,%dl
  800a08:	75 f2                	jne    8009fc <strchr+0xc>
  800a0a:	eb 05                	jmp    800a11 <strchr+0x21>
			return (char *) s;
	return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a20:	38 ca                	cmp    %cl,%dl
  800a22:	74 09                	je     800a2d <strfind+0x1a>
  800a24:	84 d2                	test   %dl,%dl
  800a26:	74 05                	je     800a2d <strfind+0x1a>
	for (; *s; s++)
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	eb f0                	jmp    800a1d <strfind+0xa>
			break;
	return (char *) s;
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3b:	85 c9                	test   %ecx,%ecx
  800a3d:	74 2f                	je     800a6e <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3f:	89 f8                	mov    %edi,%eax
  800a41:	09 c8                	or     %ecx,%eax
  800a43:	a8 03                	test   $0x3,%al
  800a45:	75 21                	jne    800a68 <memset+0x39>
		c &= 0xFF;
  800a47:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4b:	89 d0                	mov    %edx,%eax
  800a4d:	c1 e0 08             	shl    $0x8,%eax
  800a50:	89 d3                	mov    %edx,%ebx
  800a52:	c1 e3 18             	shl    $0x18,%ebx
  800a55:	89 d6                	mov    %edx,%esi
  800a57:	c1 e6 10             	shl    $0x10,%esi
  800a5a:	09 f3                	or     %esi,%ebx
  800a5c:	09 da                	or     %ebx,%edx
  800a5e:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a60:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a63:	fc                   	cld    
  800a64:	f3 ab                	rep stos %eax,%es:(%edi)
  800a66:	eb 06                	jmp    800a6e <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6b:	fc                   	cld    
  800a6c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6e:	89 f8                	mov    %edi,%eax
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	57                   	push   %edi
  800a79:	56                   	push   %esi
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a83:	39 c6                	cmp    %eax,%esi
  800a85:	73 32                	jae    800ab9 <memmove+0x44>
  800a87:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8a:	39 c2                	cmp    %eax,%edx
  800a8c:	76 2b                	jbe    800ab9 <memmove+0x44>
		s += n;
		d += n;
  800a8e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a91:	89 d6                	mov    %edx,%esi
  800a93:	09 fe                	or     %edi,%esi
  800a95:	09 ce                	or     %ecx,%esi
  800a97:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a9d:	75 0e                	jne    800aad <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a9f:	83 ef 04             	sub    $0x4,%edi
  800aa2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aa8:	fd                   	std    
  800aa9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aab:	eb 09                	jmp    800ab6 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aad:	83 ef 01             	sub    $0x1,%edi
  800ab0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ab3:	fd                   	std    
  800ab4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab6:	fc                   	cld    
  800ab7:	eb 1a                	jmp    800ad3 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab9:	89 f2                	mov    %esi,%edx
  800abb:	09 c2                	or     %eax,%edx
  800abd:	09 ca                	or     %ecx,%edx
  800abf:	f6 c2 03             	test   $0x3,%dl
  800ac2:	75 0a                	jne    800ace <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ac7:	89 c7                	mov    %eax,%edi
  800ac9:	fc                   	cld    
  800aca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acc:	eb 05                	jmp    800ad3 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	fc                   	cld    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800add:	ff 75 10             	push   0x10(%ebp)
  800ae0:	ff 75 0c             	push   0xc(%ebp)
  800ae3:	ff 75 08             	push   0x8(%ebp)
  800ae6:	e8 8a ff ff ff       	call   800a75 <memmove>
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af8:	89 c6                	mov    %eax,%esi
  800afa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afd:	eb 06                	jmp    800b05 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b05:	39 f0                	cmp    %esi,%eax
  800b07:	74 14                	je     800b1d <memcmp+0x30>
		if (*s1 != *s2)
  800b09:	0f b6 08             	movzbl (%eax),%ecx
  800b0c:	0f b6 1a             	movzbl (%edx),%ebx
  800b0f:	38 d9                	cmp    %bl,%cl
  800b11:	74 ec                	je     800aff <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b13:	0f b6 c1             	movzbl %cl,%eax
  800b16:	0f b6 db             	movzbl %bl,%ebx
  800b19:	29 d8                	sub    %ebx,%eax
  800b1b:	eb 05                	jmp    800b22 <memcmp+0x35>
	}

	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b34:	eb 03                	jmp    800b39 <memfind+0x13>
  800b36:	83 c0 01             	add    $0x1,%eax
  800b39:	39 d0                	cmp    %edx,%eax
  800b3b:	73 04                	jae    800b41 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3d:	38 08                	cmp    %cl,(%eax)
  800b3f:	75 f5                	jne    800b36 <memfind+0x10>
			break;
	return (void *) s;
}
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4f:	eb 03                	jmp    800b54 <strtol+0x11>
		s++;
  800b51:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b54:	0f b6 02             	movzbl (%edx),%eax
  800b57:	3c 20                	cmp    $0x20,%al
  800b59:	74 f6                	je     800b51 <strtol+0xe>
  800b5b:	3c 09                	cmp    $0x9,%al
  800b5d:	74 f2                	je     800b51 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b5f:	3c 2b                	cmp    $0x2b,%al
  800b61:	74 2a                	je     800b8d <strtol+0x4a>
	int neg = 0;
  800b63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b68:	3c 2d                	cmp    $0x2d,%al
  800b6a:	74 2b                	je     800b97 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b72:	75 0f                	jne    800b83 <strtol+0x40>
  800b74:	80 3a 30             	cmpb   $0x30,(%edx)
  800b77:	74 28                	je     800ba1 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b79:	85 db                	test   %ebx,%ebx
  800b7b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b80:	0f 44 d8             	cmove  %eax,%ebx
  800b83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b88:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b8b:	eb 46                	jmp    800bd3 <strtol+0x90>
		s++;
  800b8d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b90:	bf 00 00 00 00       	mov    $0x0,%edi
  800b95:	eb d5                	jmp    800b6c <strtol+0x29>
		s++, neg = 1;
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b9f:	eb cb                	jmp    800b6c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba5:	74 0e                	je     800bb5 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ba7:	85 db                	test   %ebx,%ebx
  800ba9:	75 d8                	jne    800b83 <strtol+0x40>
		s++, base = 8;
  800bab:	83 c2 01             	add    $0x1,%edx
  800bae:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb3:	eb ce                	jmp    800b83 <strtol+0x40>
		s += 2, base = 16;
  800bb5:	83 c2 02             	add    $0x2,%edx
  800bb8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bbd:	eb c4                	jmp    800b83 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bbf:	0f be c0             	movsbl %al,%eax
  800bc2:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc5:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bc8:	7d 3a                	jge    800c04 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bca:	83 c2 01             	add    $0x1,%edx
  800bcd:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bd1:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bd3:	0f b6 02             	movzbl (%edx),%eax
  800bd6:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bd9:	89 f3                	mov    %esi,%ebx
  800bdb:	80 fb 09             	cmp    $0x9,%bl
  800bde:	76 df                	jbe    800bbf <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800be0:	8d 70 9f             	lea    -0x61(%eax),%esi
  800be3:	89 f3                	mov    %esi,%ebx
  800be5:	80 fb 19             	cmp    $0x19,%bl
  800be8:	77 08                	ja     800bf2 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bea:	0f be c0             	movsbl %al,%eax
  800bed:	83 e8 57             	sub    $0x57,%eax
  800bf0:	eb d3                	jmp    800bc5 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bf2:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bf5:	89 f3                	mov    %esi,%ebx
  800bf7:	80 fb 19             	cmp    $0x19,%bl
  800bfa:	77 08                	ja     800c04 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bfc:	0f be c0             	movsbl %al,%eax
  800bff:	83 e8 37             	sub    $0x37,%eax
  800c02:	eb c1                	jmp    800bc5 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c08:	74 05                	je     800c0f <strtol+0xcc>
		*endptr = (char *) s;
  800c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c0f:	89 c8                	mov    %ecx,%eax
  800c11:	f7 d8                	neg    %eax
  800c13:	85 ff                	test   %edi,%edi
  800c15:	0f 45 c8             	cmovne %eax,%ecx
}
  800c18:	89 c8                	mov    %ecx,%eax
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c25:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c30:	89 c3                	mov    %eax,%ebx
  800c32:	89 c7                	mov    %eax,%edi
  800c34:	89 c6                	mov    %eax,%esi
  800c36:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_cgetc>:

int
sys_cgetc(void)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 d3                	mov    %edx,%ebx
  800c51:	89 d7                	mov    %edx,%edi
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	b8 03 00 00 00       	mov    $0x3,%eax
  800c72:	89 cb                	mov    %ecx,%ebx
  800c74:	89 cf                	mov    %ecx,%edi
  800c76:	89 ce                	mov    %ecx,%esi
  800c78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7f 08                	jg     800c86 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 03                	push   $0x3
  800c8c:	68 bf 26 80 00       	push   $0x8026bf
  800c91:	6a 2a                	push   $0x2a
  800c93:	68 dc 26 80 00       	push   $0x8026dc
  800c98:	e8 8d f5 ff ff       	call   80022a <_panic>

00800c9d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca8:	b8 02 00 00 00       	mov    $0x2,%eax
  800cad:	89 d1                	mov    %edx,%ecx
  800caf:	89 d3                	mov    %edx,%ebx
  800cb1:	89 d7                	mov    %edx,%edi
  800cb3:	89 d6                	mov    %edx,%esi
  800cb5:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_yield>:

void
sys_yield(void)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ccc:	89 d1                	mov    %edx,%ecx
  800cce:	89 d3                	mov    %edx,%ebx
  800cd0:	89 d7                	mov    %edx,%edi
  800cd2:	89 d6                	mov    %edx,%esi
  800cd4:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce4:	be 00 00 00 00       	mov    $0x0,%esi
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf7:	89 f7                	mov    %esi,%edi
  800cf9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7f 08                	jg     800d07 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 04                	push   $0x4
  800d0d:	68 bf 26 80 00       	push   $0x8026bf
  800d12:	6a 2a                	push   $0x2a
  800d14:	68 dc 26 80 00       	push   $0x8026dc
  800d19:	e8 0c f5 ff ff       	call   80022a <_panic>

00800d1e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d38:	8b 75 18             	mov    0x18(%ebp),%esi
  800d3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7f 08                	jg     800d49 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 05                	push   $0x5
  800d4f:	68 bf 26 80 00       	push   $0x8026bf
  800d54:	6a 2a                	push   $0x2a
  800d56:	68 dc 26 80 00       	push   $0x8026dc
  800d5b:	e8 ca f4 ff ff       	call   80022a <_panic>

00800d60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	b8 06 00 00 00       	mov    $0x6,%eax
  800d79:	89 df                	mov    %ebx,%edi
  800d7b:	89 de                	mov    %ebx,%esi
  800d7d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	7f 08                	jg     800d8b <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 06                	push   $0x6
  800d91:	68 bf 26 80 00       	push   $0x8026bf
  800d96:	6a 2a                	push   $0x2a
  800d98:	68 dc 26 80 00       	push   $0x8026dc
  800d9d:	e8 88 f4 ff ff       	call   80022a <_panic>

00800da2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbb:	89 df                	mov    %ebx,%edi
  800dbd:	89 de                	mov    %ebx,%esi
  800dbf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7f 08                	jg     800dcd <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	50                   	push   %eax
  800dd1:	6a 08                	push   $0x8
  800dd3:	68 bf 26 80 00       	push   $0x8026bf
  800dd8:	6a 2a                	push   $0x2a
  800dda:	68 dc 26 80 00       	push   $0x8026dc
  800ddf:	e8 46 f4 ff ff       	call   80022a <_panic>

00800de4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ded:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfd:	89 df                	mov    %ebx,%edi
  800dff:	89 de                	mov    %ebx,%esi
  800e01:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e03:	85 c0                	test   %eax,%eax
  800e05:	7f 08                	jg     800e0f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	50                   	push   %eax
  800e13:	6a 09                	push   $0x9
  800e15:	68 bf 26 80 00       	push   $0x8026bf
  800e1a:	6a 2a                	push   $0x2a
  800e1c:	68 dc 26 80 00       	push   $0x8026dc
  800e21:	e8 04 f4 ff ff       	call   80022a <_panic>

00800e26 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e34:	8b 55 08             	mov    0x8(%ebp),%edx
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3f:	89 df                	mov    %ebx,%edi
  800e41:	89 de                	mov    %ebx,%esi
  800e43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e45:	85 c0                	test   %eax,%eax
  800e47:	7f 08                	jg     800e51 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	83 ec 0c             	sub    $0xc,%esp
  800e54:	50                   	push   %eax
  800e55:	6a 0a                	push   $0xa
  800e57:	68 bf 26 80 00       	push   $0x8026bf
  800e5c:	6a 2a                	push   $0x2a
  800e5e:	68 dc 26 80 00       	push   $0x8026dc
  800e63:	e8 c2 f3 ff ff       	call   80022a <_panic>

00800e68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e74:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e79:	be 00 00 00 00       	mov    $0x0,%esi
  800e7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e84:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea1:	89 cb                	mov    %ecx,%ebx
  800ea3:	89 cf                	mov    %ecx,%edi
  800ea5:	89 ce                	mov    %ecx,%esi
  800ea7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	7f 08                	jg     800eb5 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ead:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb5:	83 ec 0c             	sub    $0xc,%esp
  800eb8:	50                   	push   %eax
  800eb9:	6a 0d                	push   $0xd
  800ebb:	68 bf 26 80 00       	push   $0x8026bf
  800ec0:	6a 2a                	push   $0x2a
  800ec2:	68 dc 26 80 00       	push   $0x8026dc
  800ec7:	e8 5e f3 ff ff       	call   80022a <_panic>

00800ecc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ed4:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ed6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eda:	0f 84 8e 00 00 00    	je     800f6e <pgfault+0xa2>
  800ee0:	89 f0                	mov    %esi,%eax
  800ee2:	c1 e8 0c             	shr    $0xc,%eax
  800ee5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eec:	f6 c4 08             	test   $0x8,%ah
  800eef:	74 7d                	je     800f6e <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800ef1:	e8 a7 fd ff ff       	call   800c9d <sys_getenvid>
  800ef6:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	6a 07                	push   $0x7
  800efd:	68 00 f0 7f 00       	push   $0x7ff000
  800f02:	50                   	push   %eax
  800f03:	e8 d3 fd ff ff       	call   800cdb <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f08:	83 c4 10             	add    $0x10,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	78 73                	js     800f82 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f0f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f15:	83 ec 04             	sub    $0x4,%esp
  800f18:	68 00 10 00 00       	push   $0x1000
  800f1d:	56                   	push   %esi
  800f1e:	68 00 f0 7f 00       	push   $0x7ff000
  800f23:	e8 4d fb ff ff       	call   800a75 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f28:	83 c4 08             	add    $0x8,%esp
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	e8 2e fe ff ff       	call   800d60 <sys_page_unmap>
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 5b                	js     800f94 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	6a 07                	push   $0x7
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	68 00 f0 7f 00       	push   $0x7ff000
  800f45:	53                   	push   %ebx
  800f46:	e8 d3 fd ff ff       	call   800d1e <sys_page_map>
  800f4b:	83 c4 20             	add    $0x20,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 54                	js     800fa6 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f52:	83 ec 08             	sub    $0x8,%esp
  800f55:	68 00 f0 7f 00       	push   $0x7ff000
  800f5a:	53                   	push   %ebx
  800f5b:	e8 00 fe ff ff       	call   800d60 <sys_page_unmap>
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	78 51                	js     800fb8 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800f67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f6e:	83 ec 04             	sub    $0x4,%esp
  800f71:	68 ec 26 80 00       	push   $0x8026ec
  800f76:	6a 1d                	push   $0x1d
  800f78:	68 68 27 80 00       	push   $0x802768
  800f7d:	e8 a8 f2 ff ff       	call   80022a <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f82:	50                   	push   %eax
  800f83:	68 24 27 80 00       	push   $0x802724
  800f88:	6a 29                	push   $0x29
  800f8a:	68 68 27 80 00       	push   $0x802768
  800f8f:	e8 96 f2 ff ff       	call   80022a <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f94:	50                   	push   %eax
  800f95:	68 48 27 80 00       	push   $0x802748
  800f9a:	6a 2e                	push   $0x2e
  800f9c:	68 68 27 80 00       	push   $0x802768
  800fa1:	e8 84 f2 ff ff       	call   80022a <_panic>
		panic("pgfault: page map failed (%e)", r);
  800fa6:	50                   	push   %eax
  800fa7:	68 73 27 80 00       	push   $0x802773
  800fac:	6a 30                	push   $0x30
  800fae:	68 68 27 80 00       	push   $0x802768
  800fb3:	e8 72 f2 ff ff       	call   80022a <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800fb8:	50                   	push   %eax
  800fb9:	68 48 27 80 00       	push   $0x802748
  800fbe:	6a 32                	push   $0x32
  800fc0:	68 68 27 80 00       	push   $0x802768
  800fc5:	e8 60 f2 ff ff       	call   80022a <_panic>

00800fca <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800fd3:	68 cc 0e 80 00       	push   $0x800ecc
  800fd8:	e8 5d 0e 00 00       	call   801e3a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fdd:	b8 07 00 00 00       	mov    $0x7,%eax
  800fe2:	cd 30                	int    $0x30
  800fe4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 2d                	js     80101b <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fee:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800ff3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ff7:	75 73                	jne    80106c <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff9:	e8 9f fc ff ff       	call   800c9d <sys_getenvid>
  800ffe:	25 ff 03 00 00       	and    $0x3ff,%eax
  801003:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801006:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80100b:	a3 00 44 80 00       	mov    %eax,0x804400
		return 0;
  801010:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801013:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  80101b:	50                   	push   %eax
  80101c:	68 91 27 80 00       	push   $0x802791
  801021:	6a 78                	push   $0x78
  801023:	68 68 27 80 00       	push   $0x802768
  801028:	e8 fd f1 ff ff       	call   80022a <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	ff 75 e4             	push   -0x1c(%ebp)
  801033:	57                   	push   %edi
  801034:	ff 75 dc             	push   -0x24(%ebp)
  801037:	57                   	push   %edi
  801038:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80103b:	56                   	push   %esi
  80103c:	e8 dd fc ff ff       	call   800d1e <sys_page_map>
	if(r<0) return r;
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	78 cb                	js     801013 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	ff 75 e4             	push   -0x1c(%ebp)
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	57                   	push   %edi
  801051:	56                   	push   %esi
  801052:	e8 c7 fc ff ff       	call   800d1e <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801057:	83 c4 20             	add    $0x20,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 76                	js     8010d4 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80105e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801064:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80106a:	74 75                	je     8010e1 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	c1 e8 16             	shr    $0x16,%eax
  801071:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801078:	a8 01                	test   $0x1,%al
  80107a:	74 e2                	je     80105e <fork+0x94>
  80107c:	89 de                	mov    %ebx,%esi
  80107e:	c1 ee 0c             	shr    $0xc,%esi
  801081:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801088:	a8 01                	test   $0x1,%al
  80108a:	74 d2                	je     80105e <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  80108c:	e8 0c fc ff ff       	call   800c9d <sys_getenvid>
  801091:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801094:	89 f7                	mov    %esi,%edi
  801096:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801099:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a0:	89 c1                	mov    %eax,%ecx
  8010a2:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8010a8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8010ab:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8010b2:	f6 c6 04             	test   $0x4,%dh
  8010b5:	0f 85 72 ff ff ff    	jne    80102d <fork+0x63>
		perm &= ~PTE_W;
  8010bb:	25 05 0e 00 00       	and    $0xe05,%eax
  8010c0:	80 cc 08             	or     $0x8,%ah
  8010c3:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8010c9:	0f 44 c1             	cmove  %ecx,%eax
  8010cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010cf:	e9 59 ff ff ff       	jmp    80102d <fork+0x63>
  8010d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d9:	0f 4f c2             	cmovg  %edx,%eax
  8010dc:	e9 32 ff ff ff       	jmp    801013 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  8010e1:	83 ec 04             	sub    $0x4,%esp
  8010e4:	6a 07                	push   $0x7
  8010e6:	68 00 f0 bf ee       	push   $0xeebff000
  8010eb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010ee:	57                   	push   %edi
  8010ef:	e8 e7 fb ff ff       	call   800cdb <sys_page_alloc>
	if(r<0) return r;
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	0f 88 14 ff ff ff    	js     801013 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010ff:	83 ec 08             	sub    $0x8,%esp
  801102:	68 b0 1e 80 00       	push   $0x801eb0
  801107:	57                   	push   %edi
  801108:	e8 19 fd ff ff       	call   800e26 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	85 c0                	test   %eax,%eax
  801112:	0f 88 fb fe ff ff    	js     801013 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801118:	83 ec 08             	sub    $0x8,%esp
  80111b:	6a 02                	push   $0x2
  80111d:	57                   	push   %edi
  80111e:	e8 7f fc ff ff       	call   800da2 <sys_env_set_status>
	if(r<0) return r;
  801123:	83 c4 10             	add    $0x10,%esp
	return envid;
  801126:	85 c0                	test   %eax,%eax
  801128:	0f 49 c7             	cmovns %edi,%eax
  80112b:	e9 e3 fe ff ff       	jmp    801013 <fork+0x49>

00801130 <sfork>:

// Challenge!
int
sfork(void)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801136:	68 a1 27 80 00       	push   $0x8027a1
  80113b:	68 a1 00 00 00       	push   $0xa1
  801140:	68 68 27 80 00       	push   $0x802768
  801145:	e8 e0 f0 ff ff       	call   80022a <_panic>

0080114a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80114d:	8b 45 08             	mov    0x8(%ebp),%eax
  801150:	05 00 00 00 30       	add    $0x30000000,%eax
  801155:	c1 e8 0c             	shr    $0xc,%eax
}
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115d:	8b 45 08             	mov    0x8(%ebp),%eax
  801160:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801165:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80116a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801179:	89 c2                	mov    %eax,%edx
  80117b:	c1 ea 16             	shr    $0x16,%edx
  80117e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801185:	f6 c2 01             	test   $0x1,%dl
  801188:	74 29                	je     8011b3 <fd_alloc+0x42>
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	c1 ea 0c             	shr    $0xc,%edx
  80118f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801196:	f6 c2 01             	test   $0x1,%dl
  801199:	74 18                	je     8011b3 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80119b:	05 00 10 00 00       	add    $0x1000,%eax
  8011a0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a5:	75 d2                	jne    801179 <fd_alloc+0x8>
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8011ac:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8011b1:	eb 05                	jmp    8011b8 <fd_alloc+0x47>
			return 0;
  8011b3:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8011b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bb:	89 02                	mov    %eax,(%edx)
}
  8011bd:	89 c8                	mov    %ecx,%eax
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c7:	83 f8 1f             	cmp    $0x1f,%eax
  8011ca:	77 30                	ja     8011fc <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011cc:	c1 e0 0c             	shl    $0xc,%eax
  8011cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d4:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8011da:	f6 c2 01             	test   $0x1,%dl
  8011dd:	74 24                	je     801203 <fd_lookup+0x42>
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	c1 ea 0c             	shr    $0xc,%edx
  8011e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011eb:	f6 c2 01             	test   $0x1,%dl
  8011ee:	74 1a                	je     80120a <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f3:	89 02                	mov    %eax,(%edx)
	return 0;
  8011f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    
		return -E_INVAL;
  8011fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801201:	eb f7                	jmp    8011fa <fd_lookup+0x39>
		return -E_INVAL;
  801203:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801208:	eb f0                	jmp    8011fa <fd_lookup+0x39>
  80120a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120f:	eb e9                	jmp    8011fa <fd_lookup+0x39>

00801211 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	53                   	push   %ebx
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	8b 55 08             	mov    0x8(%ebp),%edx
  80121b:	b8 34 28 80 00       	mov    $0x802834,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  801220:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801225:	39 13                	cmp    %edx,(%ebx)
  801227:	74 32                	je     80125b <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  801229:	83 c0 04             	add    $0x4,%eax
  80122c:	8b 18                	mov    (%eax),%ebx
  80122e:	85 db                	test   %ebx,%ebx
  801230:	75 f3                	jne    801225 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801232:	a1 00 44 80 00       	mov    0x804400,%eax
  801237:	8b 40 48             	mov    0x48(%eax),%eax
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	52                   	push   %edx
  80123e:	50                   	push   %eax
  80123f:	68 b8 27 80 00       	push   $0x8027b8
  801244:	e8 bc f0 ff ff       	call   800305 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801251:	8b 55 0c             	mov    0xc(%ebp),%edx
  801254:	89 1a                	mov    %ebx,(%edx)
}
  801256:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801259:	c9                   	leave  
  80125a:	c3                   	ret    
			return 0;
  80125b:	b8 00 00 00 00       	mov    $0x0,%eax
  801260:	eb ef                	jmp    801251 <dev_lookup+0x40>

00801262 <fd_close>:
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	57                   	push   %edi
  801266:	56                   	push   %esi
  801267:	53                   	push   %ebx
  801268:	83 ec 24             	sub    $0x24,%esp
  80126b:	8b 75 08             	mov    0x8(%ebp),%esi
  80126e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801271:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801274:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801275:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80127b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127e:	50                   	push   %eax
  80127f:	e8 3d ff ff ff       	call   8011c1 <fd_lookup>
  801284:	89 c3                	mov    %eax,%ebx
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 05                	js     801292 <fd_close+0x30>
	    || fd != fd2)
  80128d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801290:	74 16                	je     8012a8 <fd_close+0x46>
		return (must_exist ? r : 0);
  801292:	89 f8                	mov    %edi,%eax
  801294:	84 c0                	test   %al,%al
  801296:	b8 00 00 00 00       	mov    $0x0,%eax
  80129b:	0f 44 d8             	cmove  %eax,%ebx
}
  80129e:	89 d8                	mov    %ebx,%eax
  8012a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5e                   	pop    %esi
  8012a5:	5f                   	pop    %edi
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	ff 36                	push   (%esi)
  8012b1:	e8 5b ff ff ff       	call   801211 <dev_lookup>
  8012b6:	89 c3                	mov    %eax,%ebx
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 1a                	js     8012d9 <fd_close+0x77>
		if (dev->dev_close)
  8012bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c2:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	74 0b                	je     8012d9 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	56                   	push   %esi
  8012d2:	ff d0                	call   *%eax
  8012d4:	89 c3                	mov    %eax,%ebx
  8012d6:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	56                   	push   %esi
  8012dd:	6a 00                	push   $0x0
  8012df:	e8 7c fa ff ff       	call   800d60 <sys_page_unmap>
	return r;
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	eb b5                	jmp    80129e <fd_close+0x3c>

008012e9 <close>:

int
close(int fdnum)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	ff 75 08             	push   0x8(%ebp)
  8012f6:	e8 c6 fe ff ff       	call   8011c1 <fd_lookup>
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	79 02                	jns    801304 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801302:	c9                   	leave  
  801303:	c3                   	ret    
		return fd_close(fd, 1);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	6a 01                	push   $0x1
  801309:	ff 75 f4             	push   -0xc(%ebp)
  80130c:	e8 51 ff ff ff       	call   801262 <fd_close>
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	eb ec                	jmp    801302 <close+0x19>

00801316 <close_all>:

void
close_all(void)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	53                   	push   %ebx
  80131a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	53                   	push   %ebx
  801326:	e8 be ff ff ff       	call   8012e9 <close>
	for (i = 0; i < MAXFD; i++)
  80132b:	83 c3 01             	add    $0x1,%ebx
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	83 fb 20             	cmp    $0x20,%ebx
  801334:	75 ec                	jne    801322 <close_all+0xc>
}
  801336:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	57                   	push   %edi
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
  801341:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801344:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	ff 75 08             	push   0x8(%ebp)
  80134b:	e8 71 fe ff ff       	call   8011c1 <fd_lookup>
  801350:	89 c3                	mov    %eax,%ebx
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 7f                	js     8013d8 <dup+0x9d>
		return r;
	close(newfdnum);
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	ff 75 0c             	push   0xc(%ebp)
  80135f:	e8 85 ff ff ff       	call   8012e9 <close>

	newfd = INDEX2FD(newfdnum);
  801364:	8b 75 0c             	mov    0xc(%ebp),%esi
  801367:	c1 e6 0c             	shl    $0xc,%esi
  80136a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801373:	89 3c 24             	mov    %edi,(%esp)
  801376:	e8 df fd ff ff       	call   80115a <fd2data>
  80137b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80137d:	89 34 24             	mov    %esi,(%esp)
  801380:	e8 d5 fd ff ff       	call   80115a <fd2data>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138b:	89 d8                	mov    %ebx,%eax
  80138d:	c1 e8 16             	shr    $0x16,%eax
  801390:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801397:	a8 01                	test   $0x1,%al
  801399:	74 11                	je     8013ac <dup+0x71>
  80139b:	89 d8                	mov    %ebx,%eax
  80139d:	c1 e8 0c             	shr    $0xc,%eax
  8013a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a7:	f6 c2 01             	test   $0x1,%dl
  8013aa:	75 36                	jne    8013e2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ac:	89 f8                	mov    %edi,%eax
  8013ae:	c1 e8 0c             	shr    $0xc,%eax
  8013b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c0:	50                   	push   %eax
  8013c1:	56                   	push   %esi
  8013c2:	6a 00                	push   $0x0
  8013c4:	57                   	push   %edi
  8013c5:	6a 00                	push   $0x0
  8013c7:	e8 52 f9 ff ff       	call   800d1e <sys_page_map>
  8013cc:	89 c3                	mov    %eax,%ebx
  8013ce:	83 c4 20             	add    $0x20,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 33                	js     801408 <dup+0xcd>
		goto err;

	return newfdnum;
  8013d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013d8:	89 d8                	mov    %ebx,%eax
  8013da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5f                   	pop    %edi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e9:	83 ec 0c             	sub    $0xc,%esp
  8013ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f1:	50                   	push   %eax
  8013f2:	ff 75 d4             	push   -0x2c(%ebp)
  8013f5:	6a 00                	push   $0x0
  8013f7:	53                   	push   %ebx
  8013f8:	6a 00                	push   $0x0
  8013fa:	e8 1f f9 ff ff       	call   800d1e <sys_page_map>
  8013ff:	89 c3                	mov    %eax,%ebx
  801401:	83 c4 20             	add    $0x20,%esp
  801404:	85 c0                	test   %eax,%eax
  801406:	79 a4                	jns    8013ac <dup+0x71>
	sys_page_unmap(0, newfd);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	56                   	push   %esi
  80140c:	6a 00                	push   $0x0
  80140e:	e8 4d f9 ff ff       	call   800d60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801413:	83 c4 08             	add    $0x8,%esp
  801416:	ff 75 d4             	push   -0x2c(%ebp)
  801419:	6a 00                	push   $0x0
  80141b:	e8 40 f9 ff ff       	call   800d60 <sys_page_unmap>
	return r;
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	eb b3                	jmp    8013d8 <dup+0x9d>

00801425 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	56                   	push   %esi
  801429:	53                   	push   %ebx
  80142a:	83 ec 18             	sub    $0x18,%esp
  80142d:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801430:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	56                   	push   %esi
  801435:	e8 87 fd ff ff       	call   8011c1 <fd_lookup>
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 3c                	js     80147d <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801441:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	ff 33                	push   (%ebx)
  80144d:	e8 bf fd ff ff       	call   801211 <dev_lookup>
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	85 c0                	test   %eax,%eax
  801457:	78 24                	js     80147d <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801459:	8b 43 08             	mov    0x8(%ebx),%eax
  80145c:	83 e0 03             	and    $0x3,%eax
  80145f:	83 f8 01             	cmp    $0x1,%eax
  801462:	74 20                	je     801484 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801464:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801467:	8b 40 08             	mov    0x8(%eax),%eax
  80146a:	85 c0                	test   %eax,%eax
  80146c:	74 37                	je     8014a5 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	ff 75 10             	push   0x10(%ebp)
  801474:	ff 75 0c             	push   0xc(%ebp)
  801477:	53                   	push   %ebx
  801478:	ff d0                	call   *%eax
  80147a:	83 c4 10             	add    $0x10,%esp
}
  80147d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801480:	5b                   	pop    %ebx
  801481:	5e                   	pop    %esi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801484:	a1 00 44 80 00       	mov    0x804400,%eax
  801489:	8b 40 48             	mov    0x48(%eax),%eax
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	56                   	push   %esi
  801490:	50                   	push   %eax
  801491:	68 f9 27 80 00       	push   $0x8027f9
  801496:	e8 6a ee ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a3:	eb d8                	jmp    80147d <read+0x58>
		return -E_NOT_SUPP;
  8014a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014aa:	eb d1                	jmp    80147d <read+0x58>

008014ac <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	57                   	push   %edi
  8014b0:	56                   	push   %esi
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c0:	eb 02                	jmp    8014c4 <readn+0x18>
  8014c2:	01 c3                	add    %eax,%ebx
  8014c4:	39 f3                	cmp    %esi,%ebx
  8014c6:	73 21                	jae    8014e9 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014c8:	83 ec 04             	sub    $0x4,%esp
  8014cb:	89 f0                	mov    %esi,%eax
  8014cd:	29 d8                	sub    %ebx,%eax
  8014cf:	50                   	push   %eax
  8014d0:	89 d8                	mov    %ebx,%eax
  8014d2:	03 45 0c             	add    0xc(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	57                   	push   %edi
  8014d7:	e8 49 ff ff ff       	call   801425 <read>
		if (m < 0)
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 04                	js     8014e7 <readn+0x3b>
			return m;
		if (m == 0)
  8014e3:	75 dd                	jne    8014c2 <readn+0x16>
  8014e5:	eb 02                	jmp    8014e9 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e7:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014e9:	89 d8                	mov    %ebx,%eax
  8014eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ee:	5b                   	pop    %ebx
  8014ef:	5e                   	pop    %esi
  8014f0:	5f                   	pop    %edi
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    

008014f3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 18             	sub    $0x18,%esp
  8014fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	53                   	push   %ebx
  801503:	e8 b9 fc ff ff       	call   8011c1 <fd_lookup>
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 37                	js     801546 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801512:	83 ec 08             	sub    $0x8,%esp
  801515:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	ff 36                	push   (%esi)
  80151b:	e8 f1 fc ff ff       	call   801211 <dev_lookup>
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	85 c0                	test   %eax,%eax
  801525:	78 1f                	js     801546 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801527:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80152b:	74 20                	je     80154d <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80152d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801530:	8b 40 0c             	mov    0xc(%eax),%eax
  801533:	85 c0                	test   %eax,%eax
  801535:	74 37                	je     80156e <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801537:	83 ec 04             	sub    $0x4,%esp
  80153a:	ff 75 10             	push   0x10(%ebp)
  80153d:	ff 75 0c             	push   0xc(%ebp)
  801540:	56                   	push   %esi
  801541:	ff d0                	call   *%eax
  801543:	83 c4 10             	add    $0x10,%esp
}
  801546:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80154d:	a1 00 44 80 00       	mov    0x804400,%eax
  801552:	8b 40 48             	mov    0x48(%eax),%eax
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	53                   	push   %ebx
  801559:	50                   	push   %eax
  80155a:	68 15 28 80 00       	push   $0x802815
  80155f:	e8 a1 ed ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156c:	eb d8                	jmp    801546 <write+0x53>
		return -E_NOT_SUPP;
  80156e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801573:	eb d1                	jmp    801546 <write+0x53>

00801575 <seek>:

int
seek(int fdnum, off_t offset)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157e:	50                   	push   %eax
  80157f:	ff 75 08             	push   0x8(%ebp)
  801582:	e8 3a fc ff ff       	call   8011c1 <fd_lookup>
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 0e                	js     80159c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80158e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801591:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801594:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801597:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80159c:	c9                   	leave  
  80159d:	c3                   	ret    

0080159e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	56                   	push   %esi
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 18             	sub    $0x18,%esp
  8015a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	53                   	push   %ebx
  8015ae:	e8 0e fc ff ff       	call   8011c1 <fd_lookup>
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 34                	js     8015ee <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ba:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	ff 36                	push   (%esi)
  8015c6:	e8 46 fc ff ff       	call   801211 <dev_lookup>
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 1c                	js     8015ee <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d2:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015d6:	74 1d                	je     8015f5 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015db:	8b 40 18             	mov    0x18(%eax),%eax
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	74 34                	je     801616 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	ff 75 0c             	push   0xc(%ebp)
  8015e8:	56                   	push   %esi
  8015e9:	ff d0                	call   *%eax
  8015eb:	83 c4 10             	add    $0x10,%esp
}
  8015ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f1:	5b                   	pop    %ebx
  8015f2:	5e                   	pop    %esi
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015f5:	a1 00 44 80 00       	mov    0x804400,%eax
  8015fa:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fd:	83 ec 04             	sub    $0x4,%esp
  801600:	53                   	push   %ebx
  801601:	50                   	push   %eax
  801602:	68 d8 27 80 00       	push   $0x8027d8
  801607:	e8 f9 ec ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801614:	eb d8                	jmp    8015ee <ftruncate+0x50>
		return -E_NOT_SUPP;
  801616:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80161b:	eb d1                	jmp    8015ee <ftruncate+0x50>

0080161d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	56                   	push   %esi
  801621:	53                   	push   %ebx
  801622:	83 ec 18             	sub    $0x18,%esp
  801625:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801628:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	ff 75 08             	push   0x8(%ebp)
  80162f:	e8 8d fb ff ff       	call   8011c1 <fd_lookup>
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 49                	js     801684 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801644:	50                   	push   %eax
  801645:	ff 36                	push   (%esi)
  801647:	e8 c5 fb ff ff       	call   801211 <dev_lookup>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 31                	js     801684 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801656:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80165a:	74 2f                	je     80168b <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80165c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80165f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801666:	00 00 00 
	stat->st_isdir = 0;
  801669:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801670:	00 00 00 
	stat->st_dev = dev;
  801673:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	53                   	push   %ebx
  80167d:	56                   	push   %esi
  80167e:	ff 50 14             	call   *0x14(%eax)
  801681:	83 c4 10             	add    $0x10,%esp
}
  801684:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801687:	5b                   	pop    %ebx
  801688:	5e                   	pop    %esi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    
		return -E_NOT_SUPP;
  80168b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801690:	eb f2                	jmp    801684 <fstat+0x67>

00801692 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	56                   	push   %esi
  801696:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	6a 00                	push   $0x0
  80169c:	ff 75 08             	push   0x8(%ebp)
  80169f:	e8 e4 01 00 00       	call   801888 <open>
  8016a4:	89 c3                	mov    %eax,%ebx
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 1b                	js     8016c8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	ff 75 0c             	push   0xc(%ebp)
  8016b3:	50                   	push   %eax
  8016b4:	e8 64 ff ff ff       	call   80161d <fstat>
  8016b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8016bb:	89 1c 24             	mov    %ebx,(%esp)
  8016be:	e8 26 fc ff ff       	call   8012e9 <close>
	return r;
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	89 f3                	mov    %esi,%ebx
}
  8016c8:	89 d8                	mov    %ebx,%eax
  8016ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5d                   	pop    %ebp
  8016d0:	c3                   	ret    

008016d1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	56                   	push   %esi
  8016d5:	53                   	push   %ebx
  8016d6:	89 c6                	mov    %eax,%esi
  8016d8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016da:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016e1:	74 27                	je     80170a <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016e3:	6a 07                	push   $0x7
  8016e5:	68 00 50 80 00       	push   $0x805000
  8016ea:	56                   	push   %esi
  8016eb:	ff 35 00 60 80 00    	push   0x806000
  8016f1:	e8 47 08 00 00       	call   801f3d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016f6:	83 c4 0c             	add    $0xc,%esp
  8016f9:	6a 00                	push   $0x0
  8016fb:	53                   	push   %ebx
  8016fc:	6a 00                	push   $0x0
  8016fe:	e8 d3 07 00 00       	call   801ed6 <ipc_recv>
}
  801703:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801706:	5b                   	pop    %ebx
  801707:	5e                   	pop    %esi
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80170a:	83 ec 0c             	sub    $0xc,%esp
  80170d:	6a 01                	push   $0x1
  80170f:	e8 7d 08 00 00       	call   801f91 <ipc_find_env>
  801714:	a3 00 60 80 00       	mov    %eax,0x806000
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	eb c5                	jmp    8016e3 <fsipc+0x12>

0080171e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801724:	8b 45 08             	mov    0x8(%ebp),%eax
  801727:	8b 40 0c             	mov    0xc(%eax),%eax
  80172a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80172f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801732:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801737:	ba 00 00 00 00       	mov    $0x0,%edx
  80173c:	b8 02 00 00 00       	mov    $0x2,%eax
  801741:	e8 8b ff ff ff       	call   8016d1 <fsipc>
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <devfile_flush>:
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
  801751:	8b 40 0c             	mov    0xc(%eax),%eax
  801754:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801759:	ba 00 00 00 00       	mov    $0x0,%edx
  80175e:	b8 06 00 00 00       	mov    $0x6,%eax
  801763:	e8 69 ff ff ff       	call   8016d1 <fsipc>
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <devfile_stat>:
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 04             	sub    $0x4,%esp
  801771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801774:	8b 45 08             	mov    0x8(%ebp),%eax
  801777:	8b 40 0c             	mov    0xc(%eax),%eax
  80177a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80177f:	ba 00 00 00 00       	mov    $0x0,%edx
  801784:	b8 05 00 00 00       	mov    $0x5,%eax
  801789:	e8 43 ff ff ff       	call   8016d1 <fsipc>
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 2c                	js     8017be <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801792:	83 ec 08             	sub    $0x8,%esp
  801795:	68 00 50 80 00       	push   $0x805000
  80179a:	53                   	push   %ebx
  80179b:	e8 3f f1 ff ff       	call   8008df <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017a0:	a1 80 50 80 00       	mov    0x805080,%eax
  8017a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017ab:	a1 84 50 80 00       	mov    0x805084,%eax
  8017b0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <devfile_write>:
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	83 ec 0c             	sub    $0xc,%esp
  8017c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017cc:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017d1:	39 d0                	cmp    %edx,%eax
  8017d3:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8017d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8017dc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017e2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017e7:	50                   	push   %eax
  8017e8:	ff 75 0c             	push   0xc(%ebp)
  8017eb:	68 08 50 80 00       	push   $0x805008
  8017f0:	e8 80 f2 ff ff       	call   800a75 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8017f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fa:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ff:	e8 cd fe ff ff       	call   8016d1 <fsipc>
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <devfile_read>:
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
  80180b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	8b 40 0c             	mov    0xc(%eax),%eax
  801814:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801819:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80181f:	ba 00 00 00 00       	mov    $0x0,%edx
  801824:	b8 03 00 00 00       	mov    $0x3,%eax
  801829:	e8 a3 fe ff ff       	call   8016d1 <fsipc>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	85 c0                	test   %eax,%eax
  801832:	78 1f                	js     801853 <devfile_read+0x4d>
	assert(r <= n);
  801834:	39 f0                	cmp    %esi,%eax
  801836:	77 24                	ja     80185c <devfile_read+0x56>
	assert(r <= PGSIZE);
  801838:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80183d:	7f 33                	jg     801872 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80183f:	83 ec 04             	sub    $0x4,%esp
  801842:	50                   	push   %eax
  801843:	68 00 50 80 00       	push   $0x805000
  801848:	ff 75 0c             	push   0xc(%ebp)
  80184b:	e8 25 f2 ff ff       	call   800a75 <memmove>
	return r;
  801850:	83 c4 10             	add    $0x10,%esp
}
  801853:	89 d8                	mov    %ebx,%eax
  801855:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801858:	5b                   	pop    %ebx
  801859:	5e                   	pop    %esi
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    
	assert(r <= n);
  80185c:	68 44 28 80 00       	push   $0x802844
  801861:	68 4b 28 80 00       	push   $0x80284b
  801866:	6a 7c                	push   $0x7c
  801868:	68 60 28 80 00       	push   $0x802860
  80186d:	e8 b8 e9 ff ff       	call   80022a <_panic>
	assert(r <= PGSIZE);
  801872:	68 6b 28 80 00       	push   $0x80286b
  801877:	68 4b 28 80 00       	push   $0x80284b
  80187c:	6a 7d                	push   $0x7d
  80187e:	68 60 28 80 00       	push   $0x802860
  801883:	e8 a2 e9 ff ff       	call   80022a <_panic>

00801888 <open>:
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	56                   	push   %esi
  80188c:	53                   	push   %ebx
  80188d:	83 ec 1c             	sub    $0x1c,%esp
  801890:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801893:	56                   	push   %esi
  801894:	e8 0b f0 ff ff       	call   8008a4 <strlen>
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a1:	7f 6c                	jg     80190f <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018a3:	83 ec 0c             	sub    $0xc,%esp
  8018a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a9:	50                   	push   %eax
  8018aa:	e8 c2 f8 ff ff       	call   801171 <fd_alloc>
  8018af:	89 c3                	mov    %eax,%ebx
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 3c                	js     8018f4 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018b8:	83 ec 08             	sub    $0x8,%esp
  8018bb:	56                   	push   %esi
  8018bc:	68 00 50 80 00       	push   $0x805000
  8018c1:	e8 19 f0 ff ff       	call   8008df <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c9:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d6:	e8 f6 fd ff ff       	call   8016d1 <fsipc>
  8018db:	89 c3                	mov    %eax,%ebx
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 19                	js     8018fd <open+0x75>
	return fd2num(fd);
  8018e4:	83 ec 0c             	sub    $0xc,%esp
  8018e7:	ff 75 f4             	push   -0xc(%ebp)
  8018ea:	e8 5b f8 ff ff       	call   80114a <fd2num>
  8018ef:	89 c3                	mov    %eax,%ebx
  8018f1:	83 c4 10             	add    $0x10,%esp
}
  8018f4:	89 d8                	mov    %ebx,%eax
  8018f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f9:	5b                   	pop    %ebx
  8018fa:	5e                   	pop    %esi
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    
		fd_close(fd, 0);
  8018fd:	83 ec 08             	sub    $0x8,%esp
  801900:	6a 00                	push   $0x0
  801902:	ff 75 f4             	push   -0xc(%ebp)
  801905:	e8 58 f9 ff ff       	call   801262 <fd_close>
		return r;
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	eb e5                	jmp    8018f4 <open+0x6c>
		return -E_BAD_PATH;
  80190f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801914:	eb de                	jmp    8018f4 <open+0x6c>

00801916 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80191c:	ba 00 00 00 00       	mov    $0x0,%edx
  801921:	b8 08 00 00 00       	mov    $0x8,%eax
  801926:	e8 a6 fd ff ff       	call   8016d1 <fsipc>
}
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
  801932:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801935:	83 ec 0c             	sub    $0xc,%esp
  801938:	ff 75 08             	push   0x8(%ebp)
  80193b:	e8 1a f8 ff ff       	call   80115a <fd2data>
  801940:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801942:	83 c4 08             	add    $0x8,%esp
  801945:	68 77 28 80 00       	push   $0x802877
  80194a:	53                   	push   %ebx
  80194b:	e8 8f ef ff ff       	call   8008df <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801950:	8b 46 04             	mov    0x4(%esi),%eax
  801953:	2b 06                	sub    (%esi),%eax
  801955:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80195b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801962:	00 00 00 
	stat->st_dev = &devpipe;
  801965:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80196c:	30 80 00 
	return 0;
}
  80196f:	b8 00 00 00 00       	mov    $0x0,%eax
  801974:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	53                   	push   %ebx
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801985:	53                   	push   %ebx
  801986:	6a 00                	push   $0x0
  801988:	e8 d3 f3 ff ff       	call   800d60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80198d:	89 1c 24             	mov    %ebx,(%esp)
  801990:	e8 c5 f7 ff ff       	call   80115a <fd2data>
  801995:	83 c4 08             	add    $0x8,%esp
  801998:	50                   	push   %eax
  801999:	6a 00                	push   $0x0
  80199b:	e8 c0 f3 ff ff       	call   800d60 <sys_page_unmap>
}
  8019a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <_pipeisclosed>:
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	57                   	push   %edi
  8019a9:	56                   	push   %esi
  8019aa:	53                   	push   %ebx
  8019ab:	83 ec 1c             	sub    $0x1c,%esp
  8019ae:	89 c7                	mov    %eax,%edi
  8019b0:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8019b2:	a1 00 44 80 00       	mov    0x804400,%eax
  8019b7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	57                   	push   %edi
  8019be:	e8 07 06 00 00       	call   801fca <pageref>
  8019c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019c6:	89 34 24             	mov    %esi,(%esp)
  8019c9:	e8 fc 05 00 00       	call   801fca <pageref>
		nn = thisenv->env_runs;
  8019ce:	8b 15 00 44 80 00    	mov    0x804400,%edx
  8019d4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	39 cb                	cmp    %ecx,%ebx
  8019dc:	74 1b                	je     8019f9 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8019de:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019e1:	75 cf                	jne    8019b2 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019e3:	8b 42 58             	mov    0x58(%edx),%eax
  8019e6:	6a 01                	push   $0x1
  8019e8:	50                   	push   %eax
  8019e9:	53                   	push   %ebx
  8019ea:	68 7e 28 80 00       	push   $0x80287e
  8019ef:	e8 11 e9 ff ff       	call   800305 <cprintf>
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	eb b9                	jmp    8019b2 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8019f9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019fc:	0f 94 c0             	sete   %al
  8019ff:	0f b6 c0             	movzbl %al,%eax
}
  801a02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5f                   	pop    %edi
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    

00801a0a <devpipe_write>:
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	57                   	push   %edi
  801a0e:	56                   	push   %esi
  801a0f:	53                   	push   %ebx
  801a10:	83 ec 28             	sub    $0x28,%esp
  801a13:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a16:	56                   	push   %esi
  801a17:	e8 3e f7 ff ff       	call   80115a <fd2data>
  801a1c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	bf 00 00 00 00       	mov    $0x0,%edi
  801a26:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a29:	75 09                	jne    801a34 <devpipe_write+0x2a>
	return i;
  801a2b:	89 f8                	mov    %edi,%eax
  801a2d:	eb 23                	jmp    801a52 <devpipe_write+0x48>
			sys_yield();
  801a2f:	e8 88 f2 ff ff       	call   800cbc <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a34:	8b 43 04             	mov    0x4(%ebx),%eax
  801a37:	8b 0b                	mov    (%ebx),%ecx
  801a39:	8d 51 20             	lea    0x20(%ecx),%edx
  801a3c:	39 d0                	cmp    %edx,%eax
  801a3e:	72 1a                	jb     801a5a <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801a40:	89 da                	mov    %ebx,%edx
  801a42:	89 f0                	mov    %esi,%eax
  801a44:	e8 5c ff ff ff       	call   8019a5 <_pipeisclosed>
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	74 e2                	je     801a2f <devpipe_write+0x25>
				return 0;
  801a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5e                   	pop    %esi
  801a57:	5f                   	pop    %edi
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a61:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a64:	89 c2                	mov    %eax,%edx
  801a66:	c1 fa 1f             	sar    $0x1f,%edx
  801a69:	89 d1                	mov    %edx,%ecx
  801a6b:	c1 e9 1b             	shr    $0x1b,%ecx
  801a6e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a71:	83 e2 1f             	and    $0x1f,%edx
  801a74:	29 ca                	sub    %ecx,%edx
  801a76:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a7a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a7e:	83 c0 01             	add    $0x1,%eax
  801a81:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a84:	83 c7 01             	add    $0x1,%edi
  801a87:	eb 9d                	jmp    801a26 <devpipe_write+0x1c>

00801a89 <devpipe_read>:
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	57                   	push   %edi
  801a8d:	56                   	push   %esi
  801a8e:	53                   	push   %ebx
  801a8f:	83 ec 18             	sub    $0x18,%esp
  801a92:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a95:	57                   	push   %edi
  801a96:	e8 bf f6 ff ff       	call   80115a <fd2data>
  801a9b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	be 00 00 00 00       	mov    $0x0,%esi
  801aa5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aa8:	75 13                	jne    801abd <devpipe_read+0x34>
	return i;
  801aaa:	89 f0                	mov    %esi,%eax
  801aac:	eb 02                	jmp    801ab0 <devpipe_read+0x27>
				return i;
  801aae:	89 f0                	mov    %esi,%eax
}
  801ab0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab3:	5b                   	pop    %ebx
  801ab4:	5e                   	pop    %esi
  801ab5:	5f                   	pop    %edi
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    
			sys_yield();
  801ab8:	e8 ff f1 ff ff       	call   800cbc <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801abd:	8b 03                	mov    (%ebx),%eax
  801abf:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ac2:	75 18                	jne    801adc <devpipe_read+0x53>
			if (i > 0)
  801ac4:	85 f6                	test   %esi,%esi
  801ac6:	75 e6                	jne    801aae <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801ac8:	89 da                	mov    %ebx,%edx
  801aca:	89 f8                	mov    %edi,%eax
  801acc:	e8 d4 fe ff ff       	call   8019a5 <_pipeisclosed>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	74 e3                	je     801ab8 <devpipe_read+0x2f>
				return 0;
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  801ada:	eb d4                	jmp    801ab0 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801adc:	99                   	cltd   
  801add:	c1 ea 1b             	shr    $0x1b,%edx
  801ae0:	01 d0                	add    %edx,%eax
  801ae2:	83 e0 1f             	and    $0x1f,%eax
  801ae5:	29 d0                	sub    %edx,%eax
  801ae7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aef:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801af2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801af5:	83 c6 01             	add    $0x1,%esi
  801af8:	eb ab                	jmp    801aa5 <devpipe_read+0x1c>

00801afa <pipe>:
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	56                   	push   %esi
  801afe:	53                   	push   %ebx
  801aff:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b05:	50                   	push   %eax
  801b06:	e8 66 f6 ff ff       	call   801171 <fd_alloc>
  801b0b:	89 c3                	mov    %eax,%ebx
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	85 c0                	test   %eax,%eax
  801b12:	0f 88 23 01 00 00    	js     801c3b <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b18:	83 ec 04             	sub    $0x4,%esp
  801b1b:	68 07 04 00 00       	push   $0x407
  801b20:	ff 75 f4             	push   -0xc(%ebp)
  801b23:	6a 00                	push   $0x0
  801b25:	e8 b1 f1 ff ff       	call   800cdb <sys_page_alloc>
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	0f 88 04 01 00 00    	js     801c3b <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b3d:	50                   	push   %eax
  801b3e:	e8 2e f6 ff ff       	call   801171 <fd_alloc>
  801b43:	89 c3                	mov    %eax,%ebx
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	0f 88 db 00 00 00    	js     801c2b <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b50:	83 ec 04             	sub    $0x4,%esp
  801b53:	68 07 04 00 00       	push   $0x407
  801b58:	ff 75 f0             	push   -0x10(%ebp)
  801b5b:	6a 00                	push   $0x0
  801b5d:	e8 79 f1 ff ff       	call   800cdb <sys_page_alloc>
  801b62:	89 c3                	mov    %eax,%ebx
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	85 c0                	test   %eax,%eax
  801b69:	0f 88 bc 00 00 00    	js     801c2b <pipe+0x131>
	va = fd2data(fd0);
  801b6f:	83 ec 0c             	sub    $0xc,%esp
  801b72:	ff 75 f4             	push   -0xc(%ebp)
  801b75:	e8 e0 f5 ff ff       	call   80115a <fd2data>
  801b7a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7c:	83 c4 0c             	add    $0xc,%esp
  801b7f:	68 07 04 00 00       	push   $0x407
  801b84:	50                   	push   %eax
  801b85:	6a 00                	push   $0x0
  801b87:	e8 4f f1 ff ff       	call   800cdb <sys_page_alloc>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	85 c0                	test   %eax,%eax
  801b93:	0f 88 82 00 00 00    	js     801c1b <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	ff 75 f0             	push   -0x10(%ebp)
  801b9f:	e8 b6 f5 ff ff       	call   80115a <fd2data>
  801ba4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bab:	50                   	push   %eax
  801bac:	6a 00                	push   $0x0
  801bae:	56                   	push   %esi
  801baf:	6a 00                	push   $0x0
  801bb1:	e8 68 f1 ff ff       	call   800d1e <sys_page_map>
  801bb6:	89 c3                	mov    %eax,%ebx
  801bb8:	83 c4 20             	add    $0x20,%esp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	78 4e                	js     801c0d <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801bbf:	a1 20 30 80 00       	mov    0x803020,%eax
  801bc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc7:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801bc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bcc:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801bd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bd6:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bdb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801be2:	83 ec 0c             	sub    $0xc,%esp
  801be5:	ff 75 f4             	push   -0xc(%ebp)
  801be8:	e8 5d f5 ff ff       	call   80114a <fd2num>
  801bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bf2:	83 c4 04             	add    $0x4,%esp
  801bf5:	ff 75 f0             	push   -0x10(%ebp)
  801bf8:	e8 4d f5 ff ff       	call   80114a <fd2num>
  801bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c00:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c0b:	eb 2e                	jmp    801c3b <pipe+0x141>
	sys_page_unmap(0, va);
  801c0d:	83 ec 08             	sub    $0x8,%esp
  801c10:	56                   	push   %esi
  801c11:	6a 00                	push   $0x0
  801c13:	e8 48 f1 ff ff       	call   800d60 <sys_page_unmap>
  801c18:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c1b:	83 ec 08             	sub    $0x8,%esp
  801c1e:	ff 75 f0             	push   -0x10(%ebp)
  801c21:	6a 00                	push   $0x0
  801c23:	e8 38 f1 ff ff       	call   800d60 <sys_page_unmap>
  801c28:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801c2b:	83 ec 08             	sub    $0x8,%esp
  801c2e:	ff 75 f4             	push   -0xc(%ebp)
  801c31:	6a 00                	push   $0x0
  801c33:	e8 28 f1 ff ff       	call   800d60 <sys_page_unmap>
  801c38:	83 c4 10             	add    $0x10,%esp
}
  801c3b:	89 d8                	mov    %ebx,%eax
  801c3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c40:	5b                   	pop    %ebx
  801c41:	5e                   	pop    %esi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <pipeisclosed>:
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4d:	50                   	push   %eax
  801c4e:	ff 75 08             	push   0x8(%ebp)
  801c51:	e8 6b f5 ff ff       	call   8011c1 <fd_lookup>
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 18                	js     801c75 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801c5d:	83 ec 0c             	sub    $0xc,%esp
  801c60:	ff 75 f4             	push   -0xc(%ebp)
  801c63:	e8 f2 f4 ff ff       	call   80115a <fd2data>
  801c68:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6d:	e8 33 fd ff ff       	call   8019a5 <_pipeisclosed>
  801c72:	83 c4 10             	add    $0x10,%esp
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	56                   	push   %esi
  801c7b:	53                   	push   %ebx
  801c7c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801c7f:	85 f6                	test   %esi,%esi
  801c81:	74 13                	je     801c96 <wait+0x1f>
	e = &envs[ENVX(envid)];
  801c83:	89 f3                	mov    %esi,%ebx
  801c85:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801c8b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801c8e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801c94:	eb 1b                	jmp    801cb1 <wait+0x3a>
	assert(envid != 0);
  801c96:	68 96 28 80 00       	push   $0x802896
  801c9b:	68 4b 28 80 00       	push   $0x80284b
  801ca0:	6a 09                	push   $0x9
  801ca2:	68 a1 28 80 00       	push   $0x8028a1
  801ca7:	e8 7e e5 ff ff       	call   80022a <_panic>
		sys_yield();
  801cac:	e8 0b f0 ff ff       	call   800cbc <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801cb1:	8b 43 48             	mov    0x48(%ebx),%eax
  801cb4:	39 f0                	cmp    %esi,%eax
  801cb6:	75 07                	jne    801cbf <wait+0x48>
  801cb8:	8b 43 54             	mov    0x54(%ebx),%eax
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	75 ed                	jne    801cac <wait+0x35>
}
  801cbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5e                   	pop    %esi
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    

00801cc6 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccb:	c3                   	ret    

00801ccc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd2:	68 ac 28 80 00       	push   $0x8028ac
  801cd7:	ff 75 0c             	push   0xc(%ebp)
  801cda:	e8 00 ec ff ff       	call   8008df <strcpy>
	return 0;
}
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce4:	c9                   	leave  
  801ce5:	c3                   	ret    

00801ce6 <devcons_write>:
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	57                   	push   %edi
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801cf2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cf7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801cfd:	eb 2e                	jmp    801d2d <devcons_write+0x47>
		m = n - tot;
  801cff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d02:	29 f3                	sub    %esi,%ebx
  801d04:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d09:	39 c3                	cmp    %eax,%ebx
  801d0b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d0e:	83 ec 04             	sub    $0x4,%esp
  801d11:	53                   	push   %ebx
  801d12:	89 f0                	mov    %esi,%eax
  801d14:	03 45 0c             	add    0xc(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	57                   	push   %edi
  801d19:	e8 57 ed ff ff       	call   800a75 <memmove>
		sys_cputs(buf, m);
  801d1e:	83 c4 08             	add    $0x8,%esp
  801d21:	53                   	push   %ebx
  801d22:	57                   	push   %edi
  801d23:	e8 f7 ee ff ff       	call   800c1f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d28:	01 de                	add    %ebx,%esi
  801d2a:	83 c4 10             	add    $0x10,%esp
  801d2d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d30:	72 cd                	jb     801cff <devcons_write+0x19>
}
  801d32:	89 f0                	mov    %esi,%eax
  801d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <devcons_read>:
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 08             	sub    $0x8,%esp
  801d42:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d47:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d4b:	75 07                	jne    801d54 <devcons_read+0x18>
  801d4d:	eb 1f                	jmp    801d6e <devcons_read+0x32>
		sys_yield();
  801d4f:	e8 68 ef ff ff       	call   800cbc <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d54:	e8 e4 ee ff ff       	call   800c3d <sys_cgetc>
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	74 f2                	je     801d4f <devcons_read+0x13>
	if (c < 0)
  801d5d:	78 0f                	js     801d6e <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801d5f:	83 f8 04             	cmp    $0x4,%eax
  801d62:	74 0c                	je     801d70 <devcons_read+0x34>
	*(char*)vbuf = c;
  801d64:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d67:	88 02                	mov    %al,(%edx)
	return 1;
  801d69:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801d6e:	c9                   	leave  
  801d6f:	c3                   	ret    
		return 0;
  801d70:	b8 00 00 00 00       	mov    $0x0,%eax
  801d75:	eb f7                	jmp    801d6e <devcons_read+0x32>

00801d77 <cputchar>:
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d83:	6a 01                	push   $0x1
  801d85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d88:	50                   	push   %eax
  801d89:	e8 91 ee ff ff       	call   800c1f <sys_cputs>
}
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <getchar>:
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d99:	6a 01                	push   $0x1
  801d9b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d9e:	50                   	push   %eax
  801d9f:	6a 00                	push   $0x0
  801da1:	e8 7f f6 ff ff       	call   801425 <read>
	if (r < 0)
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	85 c0                	test   %eax,%eax
  801dab:	78 06                	js     801db3 <getchar+0x20>
	if (r < 1)
  801dad:	74 06                	je     801db5 <getchar+0x22>
	return c;
  801daf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    
		return -E_EOF;
  801db5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801dba:	eb f7                	jmp    801db3 <getchar+0x20>

00801dbc <iscons>:
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc5:	50                   	push   %eax
  801dc6:	ff 75 08             	push   0x8(%ebp)
  801dc9:	e8 f3 f3 ff ff       	call   8011c1 <fd_lookup>
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	78 11                	js     801de6 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dde:	39 10                	cmp    %edx,(%eax)
  801de0:	0f 94 c0             	sete   %al
  801de3:	0f b6 c0             	movzbl %al,%eax
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <opencons>:
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801dee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df1:	50                   	push   %eax
  801df2:	e8 7a f3 ff ff       	call   801171 <fd_alloc>
  801df7:	83 c4 10             	add    $0x10,%esp
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 3a                	js     801e38 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dfe:	83 ec 04             	sub    $0x4,%esp
  801e01:	68 07 04 00 00       	push   $0x407
  801e06:	ff 75 f4             	push   -0xc(%ebp)
  801e09:	6a 00                	push   $0x0
  801e0b:	e8 cb ee ff ff       	call   800cdb <sys_page_alloc>
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	85 c0                	test   %eax,%eax
  801e15:	78 21                	js     801e38 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e20:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e25:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e2c:	83 ec 0c             	sub    $0xc,%esp
  801e2f:	50                   	push   %eax
  801e30:	e8 15 f3 ff ff       	call   80114a <fd2num>
  801e35:	83 c4 10             	add    $0x10,%esp
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801e40:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801e47:	74 0a                	je     801e53 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e49:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4c:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801e53:	e8 45 ee ff ff       	call   800c9d <sys_getenvid>
  801e58:	83 ec 04             	sub    $0x4,%esp
  801e5b:	68 07 0e 00 00       	push   $0xe07
  801e60:	68 00 f0 bf ee       	push   $0xeebff000
  801e65:	50                   	push   %eax
  801e66:	e8 70 ee ff ff       	call   800cdb <sys_page_alloc>
		if (r < 0) {
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	78 2c                	js     801e9e <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e72:	e8 26 ee ff ff       	call   800c9d <sys_getenvid>
  801e77:	83 ec 08             	sub    $0x8,%esp
  801e7a:	68 b0 1e 80 00       	push   $0x801eb0
  801e7f:	50                   	push   %eax
  801e80:	e8 a1 ef ff ff       	call   800e26 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	79 bd                	jns    801e49 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801e8c:	50                   	push   %eax
  801e8d:	68 f8 28 80 00       	push   $0x8028f8
  801e92:	6a 28                	push   $0x28
  801e94:	68 2e 29 80 00       	push   $0x80292e
  801e99:	e8 8c e3 ff ff       	call   80022a <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801e9e:	50                   	push   %eax
  801e9f:	68 b8 28 80 00       	push   $0x8028b8
  801ea4:	6a 23                	push   $0x23
  801ea6:	68 2e 29 80 00       	push   $0x80292e
  801eab:	e8 7a e3 ff ff       	call   80022a <_panic>

00801eb0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801eb0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801eb1:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801eb6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801eb8:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801ebb:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801ebf:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801ec2:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801ec6:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801eca:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801ecc:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801ecf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801ed0:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801ed3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801ed4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801ed5:	c3                   	ret    

00801ed6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	56                   	push   %esi
  801eda:	53                   	push   %ebx
  801edb:	8b 75 08             	mov    0x8(%ebp),%esi
  801ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801eeb:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	50                   	push   %eax
  801ef2:	e8 94 ef ff ff       	call   800e8b <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ef7:	83 c4 10             	add    $0x10,%esp
  801efa:	85 f6                	test   %esi,%esi
  801efc:	74 14                	je     801f12 <ipc_recv+0x3c>
  801efe:	ba 00 00 00 00       	mov    $0x0,%edx
  801f03:	85 c0                	test   %eax,%eax
  801f05:	78 09                	js     801f10 <ipc_recv+0x3a>
  801f07:	8b 15 00 44 80 00    	mov    0x804400,%edx
  801f0d:	8b 52 74             	mov    0x74(%edx),%edx
  801f10:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f12:	85 db                	test   %ebx,%ebx
  801f14:	74 14                	je     801f2a <ipc_recv+0x54>
  801f16:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	78 09                	js     801f28 <ipc_recv+0x52>
  801f1f:	8b 15 00 44 80 00    	mov    0x804400,%edx
  801f25:	8b 52 78             	mov    0x78(%edx),%edx
  801f28:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	78 08                	js     801f36 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f2e:	a1 00 44 80 00       	mov    0x804400,%eax
  801f33:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f39:	5b                   	pop    %ebx
  801f3a:	5e                   	pop    %esi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    

00801f3d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	57                   	push   %edi
  801f41:	56                   	push   %esi
  801f42:	53                   	push   %ebx
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f49:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f4f:	85 db                	test   %ebx,%ebx
  801f51:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f56:	0f 44 d8             	cmove  %eax,%ebx
  801f59:	eb 05                	jmp    801f60 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f5b:	e8 5c ed ff ff       	call   800cbc <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f60:	ff 75 14             	push   0x14(%ebp)
  801f63:	53                   	push   %ebx
  801f64:	56                   	push   %esi
  801f65:	57                   	push   %edi
  801f66:	e8 fd ee ff ff       	call   800e68 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f71:	74 e8                	je     801f5b <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 08                	js     801f7f <ipc_send+0x42>
	}while (r<0);

}
  801f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5f                   	pop    %edi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f7f:	50                   	push   %eax
  801f80:	68 3c 29 80 00       	push   $0x80293c
  801f85:	6a 3d                	push   $0x3d
  801f87:	68 50 29 80 00       	push   $0x802950
  801f8c:	e8 99 e2 ff ff       	call   80022a <_panic>

00801f91 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f9c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f9f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fa5:	8b 52 50             	mov    0x50(%edx),%edx
  801fa8:	39 ca                	cmp    %ecx,%edx
  801faa:	74 11                	je     801fbd <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801fac:	83 c0 01             	add    $0x1,%eax
  801faf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fb4:	75 e6                	jne    801f9c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbb:	eb 0b                	jmp    801fc8 <ipc_find_env+0x37>
			return envs[i].env_id;
  801fbd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fc0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc5:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fc8:	5d                   	pop    %ebp
  801fc9:	c3                   	ret    

00801fca <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd0:	89 c2                	mov    %eax,%edx
  801fd2:	c1 ea 16             	shr    $0x16,%edx
  801fd5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fdc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fe1:	f6 c1 01             	test   $0x1,%cl
  801fe4:	74 1c                	je     802002 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fe6:	c1 e8 0c             	shr    $0xc,%eax
  801fe9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ff0:	a8 01                	test   $0x1,%al
  801ff2:	74 0e                	je     802002 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ff4:	c1 e8 0c             	shr    $0xc,%eax
  801ff7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ffe:	ef 
  801fff:	0f b7 d2             	movzwl %dx,%edx
}
  802002:	89 d0                	mov    %edx,%eax
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__udivdi3>:
  802010:	f3 0f 1e fb          	endbr32 
  802014:	55                   	push   %ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 1c             	sub    $0x1c,%esp
  80201b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80201f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802023:	8b 74 24 34          	mov    0x34(%esp),%esi
  802027:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80202b:	85 c0                	test   %eax,%eax
  80202d:	75 19                	jne    802048 <__udivdi3+0x38>
  80202f:	39 f3                	cmp    %esi,%ebx
  802031:	76 4d                	jbe    802080 <__udivdi3+0x70>
  802033:	31 ff                	xor    %edi,%edi
  802035:	89 e8                	mov    %ebp,%eax
  802037:	89 f2                	mov    %esi,%edx
  802039:	f7 f3                	div    %ebx
  80203b:	89 fa                	mov    %edi,%edx
  80203d:	83 c4 1c             	add    $0x1c,%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
  802048:	39 f0                	cmp    %esi,%eax
  80204a:	76 14                	jbe    802060 <__udivdi3+0x50>
  80204c:	31 ff                	xor    %edi,%edi
  80204e:	31 c0                	xor    %eax,%eax
  802050:	89 fa                	mov    %edi,%edx
  802052:	83 c4 1c             	add    $0x1c,%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    
  80205a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802060:	0f bd f8             	bsr    %eax,%edi
  802063:	83 f7 1f             	xor    $0x1f,%edi
  802066:	75 48                	jne    8020b0 <__udivdi3+0xa0>
  802068:	39 f0                	cmp    %esi,%eax
  80206a:	72 06                	jb     802072 <__udivdi3+0x62>
  80206c:	31 c0                	xor    %eax,%eax
  80206e:	39 eb                	cmp    %ebp,%ebx
  802070:	77 de                	ja     802050 <__udivdi3+0x40>
  802072:	b8 01 00 00 00       	mov    $0x1,%eax
  802077:	eb d7                	jmp    802050 <__udivdi3+0x40>
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d9                	mov    %ebx,%ecx
  802082:	85 db                	test   %ebx,%ebx
  802084:	75 0b                	jne    802091 <__udivdi3+0x81>
  802086:	b8 01 00 00 00       	mov    $0x1,%eax
  80208b:	31 d2                	xor    %edx,%edx
  80208d:	f7 f3                	div    %ebx
  80208f:	89 c1                	mov    %eax,%ecx
  802091:	31 d2                	xor    %edx,%edx
  802093:	89 f0                	mov    %esi,%eax
  802095:	f7 f1                	div    %ecx
  802097:	89 c6                	mov    %eax,%esi
  802099:	89 e8                	mov    %ebp,%eax
  80209b:	89 f7                	mov    %esi,%edi
  80209d:	f7 f1                	div    %ecx
  80209f:	89 fa                	mov    %edi,%edx
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 f9                	mov    %edi,%ecx
  8020b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020b7:	29 fa                	sub    %edi,%edx
  8020b9:	d3 e0                	shl    %cl,%eax
  8020bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020bf:	89 d1                	mov    %edx,%ecx
  8020c1:	89 d8                	mov    %ebx,%eax
  8020c3:	d3 e8                	shr    %cl,%eax
  8020c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020c9:	09 c1                	or     %eax,%ecx
  8020cb:	89 f0                	mov    %esi,%eax
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e3                	shl    %cl,%ebx
  8020d5:	89 d1                	mov    %edx,%ecx
  8020d7:	d3 e8                	shr    %cl,%eax
  8020d9:	89 f9                	mov    %edi,%ecx
  8020db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020df:	89 eb                	mov    %ebp,%ebx
  8020e1:	d3 e6                	shl    %cl,%esi
  8020e3:	89 d1                	mov    %edx,%ecx
  8020e5:	d3 eb                	shr    %cl,%ebx
  8020e7:	09 f3                	or     %esi,%ebx
  8020e9:	89 c6                	mov    %eax,%esi
  8020eb:	89 f2                	mov    %esi,%edx
  8020ed:	89 d8                	mov    %ebx,%eax
  8020ef:	f7 74 24 08          	divl   0x8(%esp)
  8020f3:	89 d6                	mov    %edx,%esi
  8020f5:	89 c3                	mov    %eax,%ebx
  8020f7:	f7 64 24 0c          	mull   0xc(%esp)
  8020fb:	39 d6                	cmp    %edx,%esi
  8020fd:	72 19                	jb     802118 <__udivdi3+0x108>
  8020ff:	89 f9                	mov    %edi,%ecx
  802101:	d3 e5                	shl    %cl,%ebp
  802103:	39 c5                	cmp    %eax,%ebp
  802105:	73 04                	jae    80210b <__udivdi3+0xfb>
  802107:	39 d6                	cmp    %edx,%esi
  802109:	74 0d                	je     802118 <__udivdi3+0x108>
  80210b:	89 d8                	mov    %ebx,%eax
  80210d:	31 ff                	xor    %edi,%edi
  80210f:	e9 3c ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80211b:	31 ff                	xor    %edi,%edi
  80211d:	e9 2e ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__umoddi3>:
  802130:	f3 0f 1e fb          	endbr32 
  802134:	55                   	push   %ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	83 ec 1c             	sub    $0x1c,%esp
  80213b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80213f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802143:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802147:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80214b:	89 f0                	mov    %esi,%eax
  80214d:	89 da                	mov    %ebx,%edx
  80214f:	85 ff                	test   %edi,%edi
  802151:	75 15                	jne    802168 <__umoddi3+0x38>
  802153:	39 dd                	cmp    %ebx,%ebp
  802155:	76 39                	jbe    802190 <__umoddi3+0x60>
  802157:	f7 f5                	div    %ebp
  802159:	89 d0                	mov    %edx,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	83 c4 1c             	add    $0x1c,%esp
  802160:	5b                   	pop    %ebx
  802161:	5e                   	pop    %esi
  802162:	5f                   	pop    %edi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	8d 76 00             	lea    0x0(%esi),%esi
  802168:	39 df                	cmp    %ebx,%edi
  80216a:	77 f1                	ja     80215d <__umoddi3+0x2d>
  80216c:	0f bd cf             	bsr    %edi,%ecx
  80216f:	83 f1 1f             	xor    $0x1f,%ecx
  802172:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802176:	75 40                	jne    8021b8 <__umoddi3+0x88>
  802178:	39 df                	cmp    %ebx,%edi
  80217a:	72 04                	jb     802180 <__umoddi3+0x50>
  80217c:	39 f5                	cmp    %esi,%ebp
  80217e:	77 dd                	ja     80215d <__umoddi3+0x2d>
  802180:	89 da                	mov    %ebx,%edx
  802182:	89 f0                	mov    %esi,%eax
  802184:	29 e8                	sub    %ebp,%eax
  802186:	19 fa                	sbb    %edi,%edx
  802188:	eb d3                	jmp    80215d <__umoddi3+0x2d>
  80218a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802190:	89 e9                	mov    %ebp,%ecx
  802192:	85 ed                	test   %ebp,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x71>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f5                	div    %ebp
  80219f:	89 c1                	mov    %eax,%ecx
  8021a1:	89 d8                	mov    %ebx,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f1                	div    %ecx
  8021a7:	89 f0                	mov    %esi,%eax
  8021a9:	f7 f1                	div    %ecx
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	31 d2                	xor    %edx,%edx
  8021af:	eb ac                	jmp    80215d <__umoddi3+0x2d>
  8021b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8021c1:	29 c2                	sub    %eax,%edx
  8021c3:	89 c1                	mov    %eax,%ecx
  8021c5:	89 e8                	mov    %ebp,%eax
  8021c7:	d3 e7                	shl    %cl,%edi
  8021c9:	89 d1                	mov    %edx,%ecx
  8021cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021cf:	d3 e8                	shr    %cl,%eax
  8021d1:	89 c1                	mov    %eax,%ecx
  8021d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021d7:	09 f9                	or     %edi,%ecx
  8021d9:	89 df                	mov    %ebx,%edi
  8021db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021df:	89 c1                	mov    %eax,%ecx
  8021e1:	d3 e5                	shl    %cl,%ebp
  8021e3:	89 d1                	mov    %edx,%ecx
  8021e5:	d3 ef                	shr    %cl,%edi
  8021e7:	89 c1                	mov    %eax,%ecx
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	d3 e3                	shl    %cl,%ebx
  8021ed:	89 d1                	mov    %edx,%ecx
  8021ef:	89 fa                	mov    %edi,%edx
  8021f1:	d3 e8                	shr    %cl,%eax
  8021f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021f8:	09 d8                	or     %ebx,%eax
  8021fa:	f7 74 24 08          	divl   0x8(%esp)
  8021fe:	89 d3                	mov    %edx,%ebx
  802200:	d3 e6                	shl    %cl,%esi
  802202:	f7 e5                	mul    %ebp
  802204:	89 c7                	mov    %eax,%edi
  802206:	89 d1                	mov    %edx,%ecx
  802208:	39 d3                	cmp    %edx,%ebx
  80220a:	72 06                	jb     802212 <__umoddi3+0xe2>
  80220c:	75 0e                	jne    80221c <__umoddi3+0xec>
  80220e:	39 c6                	cmp    %eax,%esi
  802210:	73 0a                	jae    80221c <__umoddi3+0xec>
  802212:	29 e8                	sub    %ebp,%eax
  802214:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802218:	89 d1                	mov    %edx,%ecx
  80221a:	89 c7                	mov    %eax,%edi
  80221c:	89 f5                	mov    %esi,%ebp
  80221e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802222:	29 fd                	sub    %edi,%ebp
  802224:	19 cb                	sbb    %ecx,%ebx
  802226:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80222b:	89 d8                	mov    %ebx,%eax
  80222d:	d3 e0                	shl    %cl,%eax
  80222f:	89 f1                	mov    %esi,%ecx
  802231:	d3 ed                	shr    %cl,%ebp
  802233:	d3 eb                	shr    %cl,%ebx
  802235:	09 e8                	or     %ebp,%eax
  802237:	89 da                	mov    %ebx,%edx
  802239:	83 c4 1c             	add    $0x1c,%esp
  80223c:	5b                   	pop    %ebx
  80223d:	5e                   	pop    %esi
  80223e:	5f                   	pop    %edi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    
