
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
  80003e:	68 20 27 80 00       	push   $0x802720
  800043:	e8 a6 18 00 00       	call   8018ee <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	0f 88 ff 00 00 00    	js     800154 <umain+0x121>
		panic("open motd: %e", fd);
	seek(fd, 0);
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	6a 00                	push   $0x0
  80005a:	50                   	push   %eax
  80005b:	e8 7b 15 00 00       	call   8015db <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800060:	83 c4 0c             	add    $0xc,%esp
  800063:	68 00 02 00 00       	push   $0x200
  800068:	68 00 42 80 00       	push   $0x804200
  80006d:	53                   	push   %ebx
  80006e:	e8 9f 14 00 00       	call   801512 <readn>
  800073:	89 c6                	mov    %eax,%esi
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	85 c0                	test   %eax,%eax
  80007a:	0f 8e e6 00 00 00    	jle    800166 <umain+0x133>
		panic("readn: %e", n);

	if ((r = fork()) < 0)
  800080:	e8 a6 0f 00 00       	call   80102b <fork>
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
  800097:	e8 3f 15 00 00       	call   8015db <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  80009c:	c7 04 24 88 27 80 00 	movl   $0x802788,(%esp)
  8000a3:	e8 5d 02 00 00       	call   800305 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	68 00 02 00 00       	push   $0x200
  8000b0:	68 00 40 80 00       	push   $0x804000
  8000b5:	53                   	push   %ebx
  8000b6:	e8 57 14 00 00       	call   801512 <readn>
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
  8000e7:	68 52 27 80 00       	push   $0x802752
  8000ec:	e8 14 02 00 00       	call   800305 <cprintf>
		seek(fd, 0);
  8000f1:	83 c4 08             	add    $0x8,%esp
  8000f4:	6a 00                	push   $0x0
  8000f6:	53                   	push   %ebx
  8000f7:	e8 df 14 00 00       	call   8015db <seek>
		close(fd);
  8000fc:	89 1c 24             	mov    %ebx,(%esp)
  8000ff:	e8 4b 12 00 00       	call   80134f <close>
		exit();
  800104:	e8 07 01 00 00       	call   800210 <exit>
  800109:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80010c:	83 ec 0c             	sub    $0xc,%esp
  80010f:	57                   	push   %edi
  800110:	e8 30 20 00 00       	call   802145 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800115:	83 c4 0c             	add    $0xc,%esp
  800118:	68 00 02 00 00       	push   $0x200
  80011d:	68 00 40 80 00       	push   $0x804000
  800122:	53                   	push   %ebx
  800123:	e8 ea 13 00 00       	call   801512 <readn>
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	39 c6                	cmp    %eax,%esi
  80012d:	0f 85 81 00 00 00    	jne    8001b4 <umain+0x181>
		panic("read in parent got %d, then got %d", n, n2);
	cprintf("read in parent succeeded\n");
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	68 6b 27 80 00       	push   $0x80276b
  80013b:	e8 c5 01 00 00       	call   800305 <cprintf>
	close(fd);
  800140:	89 1c 24             	mov    %ebx,(%esp)
  800143:	e8 07 12 00 00       	call   80134f <close>
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
  800155:	68 25 27 80 00       	push   $0x802725
  80015a:	6a 0c                	push   $0xc
  80015c:	68 33 27 80 00       	push   $0x802733
  800161:	e8 c4 00 00 00       	call   80022a <_panic>
		panic("readn: %e", n);
  800166:	50                   	push   %eax
  800167:	68 48 27 80 00       	push   $0x802748
  80016c:	6a 0f                	push   $0xf
  80016e:	68 33 27 80 00       	push   $0x802733
  800173:	e8 b2 00 00 00       	call   80022a <_panic>
		panic("fork: %e", r);
  800178:	50                   	push   %eax
  800179:	68 58 2c 80 00       	push   $0x802c58
  80017e:	6a 12                	push   $0x12
  800180:	68 33 27 80 00       	push   $0x802733
  800185:	e8 a0 00 00 00       	call   80022a <_panic>
			panic("read in parent got %d, read in child got %d", n, n2);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	56                   	push   %esi
  80018f:	68 cc 27 80 00       	push   $0x8027cc
  800194:	6a 17                	push   $0x17
  800196:	68 33 27 80 00       	push   $0x802733
  80019b:	e8 8a 00 00 00       	call   80022a <_panic>
			panic("read in parent got different bytes from read in child");
  8001a0:	83 ec 04             	sub    $0x4,%esp
  8001a3:	68 f8 27 80 00       	push   $0x8027f8
  8001a8:	6a 19                	push   $0x19
  8001aa:	68 33 27 80 00       	push   $0x802733
  8001af:	e8 76 00 00 00       	call   80022a <_panic>
		panic("read in parent got %d, then got %d", n, n2);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	50                   	push   %eax
  8001b8:	56                   	push   %esi
  8001b9:	68 30 28 80 00       	push   $0x802830
  8001be:	6a 21                	push   $0x21
  8001c0:	68 33 27 80 00       	push   $0x802733
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
  800216:	e8 61 11 00 00       	call   80137c <close_all>
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
  800248:	68 60 28 80 00       	push   $0x802860
  80024d:	e8 b3 00 00 00       	call   800305 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800252:	83 c4 18             	add    $0x18,%esp
  800255:	53                   	push   %ebx
  800256:	ff 75 10             	push   0x10(%ebp)
  800259:	e8 56 00 00 00       	call   8002b4 <vcprintf>
	cprintf("\n");
  80025e:	c7 04 24 69 27 80 00 	movl   $0x802769,(%esp)
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
  800367:	e8 74 21 00 00       	call   8024e0 <__udivdi3>
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
  8003a5:	e8 56 22 00 00       	call   802600 <__umoddi3>
  8003aa:	83 c4 14             	add    $0x14,%esp
  8003ad:	0f be 80 83 28 80 00 	movsbl 0x802883(%eax),%eax
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
  800467:	ff 24 85 c0 29 80 00 	jmp    *0x8029c0(,%eax,4)
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
  800535:	8b 14 85 20 2b 80 00 	mov    0x802b20(,%eax,4),%edx
  80053c:	85 d2                	test   %edx,%edx
  80053e:	74 18                	je     800558 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800540:	52                   	push   %edx
  800541:	68 21 2d 80 00       	push   $0x802d21
  800546:	53                   	push   %ebx
  800547:	56                   	push   %esi
  800548:	e8 92 fe ff ff       	call   8003df <printfmt>
  80054d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800550:	89 7d 14             	mov    %edi,0x14(%ebp)
  800553:	e9 66 02 00 00       	jmp    8007be <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800558:	50                   	push   %eax
  800559:	68 9b 28 80 00       	push   $0x80289b
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
  800580:	b8 94 28 80 00       	mov    $0x802894,%eax
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
  800c8c:	68 7f 2b 80 00       	push   $0x802b7f
  800c91:	6a 2a                	push   $0x2a
  800c93:	68 9c 2b 80 00       	push   $0x802b9c
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
  800d0d:	68 7f 2b 80 00       	push   $0x802b7f
  800d12:	6a 2a                	push   $0x2a
  800d14:	68 9c 2b 80 00       	push   $0x802b9c
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
  800d4f:	68 7f 2b 80 00       	push   $0x802b7f
  800d54:	6a 2a                	push   $0x2a
  800d56:	68 9c 2b 80 00       	push   $0x802b9c
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
  800d91:	68 7f 2b 80 00       	push   $0x802b7f
  800d96:	6a 2a                	push   $0x2a
  800d98:	68 9c 2b 80 00       	push   $0x802b9c
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
  800dd3:	68 7f 2b 80 00       	push   $0x802b7f
  800dd8:	6a 2a                	push   $0x2a
  800dda:	68 9c 2b 80 00       	push   $0x802b9c
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
  800e15:	68 7f 2b 80 00       	push   $0x802b7f
  800e1a:	6a 2a                	push   $0x2a
  800e1c:	68 9c 2b 80 00       	push   $0x802b9c
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
  800e57:	68 7f 2b 80 00       	push   $0x802b7f
  800e5c:	6a 2a                	push   $0x2a
  800e5e:	68 9c 2b 80 00       	push   $0x802b9c
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
  800ebb:	68 7f 2b 80 00       	push   $0x802b7f
  800ec0:	6a 2a                	push   $0x2a
  800ec2:	68 9c 2b 80 00       	push   $0x802b9c
  800ec7:	e8 5e f3 ff ff       	call   80022a <_panic>

00800ecc <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	57                   	push   %edi
  800ed0:	56                   	push   %esi
  800ed1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800edc:	89 d1                	mov    %edx,%ecx
  800ede:	89 d3                	mov    %edx,%ebx
  800ee0:	89 d7                	mov    %edx,%edi
  800ee2:	89 d6                	mov    %edx,%esi
  800ee4:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ef1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efc:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f01:	89 df                	mov    %ebx,%edi
  800f03:	89 de                	mov    %ebx,%esi
  800f05:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f17:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	b8 10 00 00 00       	mov    $0x10,%eax
  800f22:	89 df                	mov    %ebx,%edi
  800f24:	89 de                	mov    %ebx,%esi
  800f26:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	56                   	push   %esi
  800f31:	53                   	push   %ebx
  800f32:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f35:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f37:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f3b:	0f 84 8e 00 00 00    	je     800fcf <pgfault+0xa2>
  800f41:	89 f0                	mov    %esi,%eax
  800f43:	c1 e8 0c             	shr    $0xc,%eax
  800f46:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4d:	f6 c4 08             	test   $0x8,%ah
  800f50:	74 7d                	je     800fcf <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800f52:	e8 46 fd ff ff       	call   800c9d <sys_getenvid>
  800f57:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800f59:	83 ec 04             	sub    $0x4,%esp
  800f5c:	6a 07                	push   $0x7
  800f5e:	68 00 f0 7f 00       	push   $0x7ff000
  800f63:	50                   	push   %eax
  800f64:	e8 72 fd ff ff       	call   800cdb <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	78 73                	js     800fe3 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f70:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f76:	83 ec 04             	sub    $0x4,%esp
  800f79:	68 00 10 00 00       	push   $0x1000
  800f7e:	56                   	push   %esi
  800f7f:	68 00 f0 7f 00       	push   $0x7ff000
  800f84:	e8 ec fa ff ff       	call   800a75 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f89:	83 c4 08             	add    $0x8,%esp
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	e8 cd fd ff ff       	call   800d60 <sys_page_unmap>
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 5b                	js     800ff5 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f9a:	83 ec 0c             	sub    $0xc,%esp
  800f9d:	6a 07                	push   $0x7
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
  800fa1:	68 00 f0 7f 00       	push   $0x7ff000
  800fa6:	53                   	push   %ebx
  800fa7:	e8 72 fd ff ff       	call   800d1e <sys_page_map>
  800fac:	83 c4 20             	add    $0x20,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 54                	js     801007 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800fb3:	83 ec 08             	sub    $0x8,%esp
  800fb6:	68 00 f0 7f 00       	push   $0x7ff000
  800fbb:	53                   	push   %ebx
  800fbc:	e8 9f fd ff ff       	call   800d60 <sys_page_unmap>
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 51                	js     801019 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800fc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	68 ac 2b 80 00       	push   $0x802bac
  800fd7:	6a 1d                	push   $0x1d
  800fd9:	68 28 2c 80 00       	push   $0x802c28
  800fde:	e8 47 f2 ff ff       	call   80022a <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800fe3:	50                   	push   %eax
  800fe4:	68 e4 2b 80 00       	push   $0x802be4
  800fe9:	6a 29                	push   $0x29
  800feb:	68 28 2c 80 00       	push   $0x802c28
  800ff0:	e8 35 f2 ff ff       	call   80022a <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ff5:	50                   	push   %eax
  800ff6:	68 08 2c 80 00       	push   $0x802c08
  800ffb:	6a 2e                	push   $0x2e
  800ffd:	68 28 2c 80 00       	push   $0x802c28
  801002:	e8 23 f2 ff ff       	call   80022a <_panic>
		panic("pgfault: page map failed (%e)", r);
  801007:	50                   	push   %eax
  801008:	68 33 2c 80 00       	push   $0x802c33
  80100d:	6a 30                	push   $0x30
  80100f:	68 28 2c 80 00       	push   $0x802c28
  801014:	e8 11 f2 ff ff       	call   80022a <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801019:	50                   	push   %eax
  80101a:	68 08 2c 80 00       	push   $0x802c08
  80101f:	6a 32                	push   $0x32
  801021:	68 28 2c 80 00       	push   $0x802c28
  801026:	e8 ff f1 ff ff       	call   80022a <_panic>

0080102b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	57                   	push   %edi
  80102f:	56                   	push   %esi
  801030:	53                   	push   %ebx
  801031:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801034:	68 2d 0f 80 00       	push   $0x800f2d
  801039:	e8 ca 12 00 00       	call   802308 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80103e:	b8 07 00 00 00       	mov    $0x7,%eax
  801043:	cd 30                	int    $0x30
  801045:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	78 2d                	js     80107c <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80104f:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801054:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801058:	75 73                	jne    8010cd <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  80105a:	e8 3e fc ff ff       	call   800c9d <sys_getenvid>
  80105f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801064:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80106c:	a3 00 44 80 00       	mov    %eax,0x804400
		return 0;
  801071:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801074:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801077:	5b                   	pop    %ebx
  801078:	5e                   	pop    %esi
  801079:	5f                   	pop    %edi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  80107c:	50                   	push   %eax
  80107d:	68 51 2c 80 00       	push   $0x802c51
  801082:	6a 78                	push   $0x78
  801084:	68 28 2c 80 00       	push   $0x802c28
  801089:	e8 9c f1 ff ff       	call   80022a <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	ff 75 e4             	push   -0x1c(%ebp)
  801094:	57                   	push   %edi
  801095:	ff 75 dc             	push   -0x24(%ebp)
  801098:	57                   	push   %edi
  801099:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80109c:	56                   	push   %esi
  80109d:	e8 7c fc ff ff       	call   800d1e <sys_page_map>
	if(r<0) return r;
  8010a2:	83 c4 20             	add    $0x20,%esp
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	78 cb                	js     801074 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	ff 75 e4             	push   -0x1c(%ebp)
  8010af:	57                   	push   %edi
  8010b0:	56                   	push   %esi
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	e8 66 fc ff ff       	call   800d1e <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8010b8:	83 c4 20             	add    $0x20,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	78 76                	js     801135 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8010bf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010c5:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010cb:	74 75                	je     801142 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8010cd:	89 d8                	mov    %ebx,%eax
  8010cf:	c1 e8 16             	shr    $0x16,%eax
  8010d2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d9:	a8 01                	test   $0x1,%al
  8010db:	74 e2                	je     8010bf <fork+0x94>
  8010dd:	89 de                	mov    %ebx,%esi
  8010df:	c1 ee 0c             	shr    $0xc,%esi
  8010e2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e9:	a8 01                	test   $0x1,%al
  8010eb:	74 d2                	je     8010bf <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  8010ed:	e8 ab fb ff ff       	call   800c9d <sys_getenvid>
  8010f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8010f5:	89 f7                	mov    %esi,%edi
  8010f7:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  8010fa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801101:	89 c1                	mov    %eax,%ecx
  801103:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801109:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  80110c:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801113:	f6 c6 04             	test   $0x4,%dh
  801116:	0f 85 72 ff ff ff    	jne    80108e <fork+0x63>
		perm &= ~PTE_W;
  80111c:	25 05 0e 00 00       	and    $0xe05,%eax
  801121:	80 cc 08             	or     $0x8,%ah
  801124:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  80112a:	0f 44 c1             	cmove  %ecx,%eax
  80112d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801130:	e9 59 ff ff ff       	jmp    80108e <fork+0x63>
  801135:	ba 00 00 00 00       	mov    $0x0,%edx
  80113a:	0f 4f c2             	cmovg  %edx,%eax
  80113d:	e9 32 ff ff ff       	jmp    801074 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801142:	83 ec 04             	sub    $0x4,%esp
  801145:	6a 07                	push   $0x7
  801147:	68 00 f0 bf ee       	push   $0xeebff000
  80114c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80114f:	57                   	push   %edi
  801150:	e8 86 fb ff ff       	call   800cdb <sys_page_alloc>
	if(r<0) return r;
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	85 c0                	test   %eax,%eax
  80115a:	0f 88 14 ff ff ff    	js     801074 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801160:	83 ec 08             	sub    $0x8,%esp
  801163:	68 7e 23 80 00       	push   $0x80237e
  801168:	57                   	push   %edi
  801169:	e8 b8 fc ff ff       	call   800e26 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	85 c0                	test   %eax,%eax
  801173:	0f 88 fb fe ff ff    	js     801074 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801179:	83 ec 08             	sub    $0x8,%esp
  80117c:	6a 02                	push   $0x2
  80117e:	57                   	push   %edi
  80117f:	e8 1e fc ff ff       	call   800da2 <sys_env_set_status>
	if(r<0) return r;
  801184:	83 c4 10             	add    $0x10,%esp
	return envid;
  801187:	85 c0                	test   %eax,%eax
  801189:	0f 49 c7             	cmovns %edi,%eax
  80118c:	e9 e3 fe ff ff       	jmp    801074 <fork+0x49>

00801191 <sfork>:

// Challenge!
int
sfork(void)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801197:	68 61 2c 80 00       	push   $0x802c61
  80119c:	68 a1 00 00 00       	push   $0xa1
  8011a1:	68 28 2c 80 00       	push   $0x802c28
  8011a6:	e8 7f f0 ff ff       	call   80022a <_panic>

008011ab <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b6:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011be:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c1:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011cb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011da:	89 c2                	mov    %eax,%edx
  8011dc:	c1 ea 16             	shr    $0x16,%edx
  8011df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e6:	f6 c2 01             	test   $0x1,%dl
  8011e9:	74 29                	je     801214 <fd_alloc+0x42>
  8011eb:	89 c2                	mov    %eax,%edx
  8011ed:	c1 ea 0c             	shr    $0xc,%edx
  8011f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f7:	f6 c2 01             	test   $0x1,%dl
  8011fa:	74 18                	je     801214 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011fc:	05 00 10 00 00       	add    $0x1000,%eax
  801201:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801206:	75 d2                	jne    8011da <fd_alloc+0x8>
  801208:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80120d:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801212:	eb 05                	jmp    801219 <fd_alloc+0x47>
			return 0;
  801214:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801219:	8b 55 08             	mov    0x8(%ebp),%edx
  80121c:	89 02                	mov    %eax,(%edx)
}
  80121e:	89 c8                	mov    %ecx,%eax
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801228:	83 f8 1f             	cmp    $0x1f,%eax
  80122b:	77 30                	ja     80125d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80122d:	c1 e0 0c             	shl    $0xc,%eax
  801230:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801235:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80123b:	f6 c2 01             	test   $0x1,%dl
  80123e:	74 24                	je     801264 <fd_lookup+0x42>
  801240:	89 c2                	mov    %eax,%edx
  801242:	c1 ea 0c             	shr    $0xc,%edx
  801245:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124c:	f6 c2 01             	test   $0x1,%dl
  80124f:	74 1a                	je     80126b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801251:	8b 55 0c             	mov    0xc(%ebp),%edx
  801254:	89 02                	mov    %eax,(%edx)
	return 0;
  801256:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    
		return -E_INVAL;
  80125d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801262:	eb f7                	jmp    80125b <fd_lookup+0x39>
		return -E_INVAL;
  801264:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801269:	eb f0                	jmp    80125b <fd_lookup+0x39>
  80126b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801270:	eb e9                	jmp    80125b <fd_lookup+0x39>

00801272 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	53                   	push   %ebx
  801276:	83 ec 04             	sub    $0x4,%esp
  801279:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80127c:	b8 00 00 00 00       	mov    $0x0,%eax
  801281:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801286:	39 13                	cmp    %edx,(%ebx)
  801288:	74 37                	je     8012c1 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80128a:	83 c0 01             	add    $0x1,%eax
  80128d:	8b 1c 85 f4 2c 80 00 	mov    0x802cf4(,%eax,4),%ebx
  801294:	85 db                	test   %ebx,%ebx
  801296:	75 ee                	jne    801286 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801298:	a1 00 44 80 00       	mov    0x804400,%eax
  80129d:	8b 40 48             	mov    0x48(%eax),%eax
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	52                   	push   %edx
  8012a4:	50                   	push   %eax
  8012a5:	68 78 2c 80 00       	push   $0x802c78
  8012aa:	e8 56 f0 ff ff       	call   800305 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ba:	89 1a                	mov    %ebx,(%edx)
}
  8012bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    
			return 0;
  8012c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c6:	eb ef                	jmp    8012b7 <dev_lookup+0x45>

008012c8 <fd_close>:
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	57                   	push   %edi
  8012cc:	56                   	push   %esi
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 24             	sub    $0x24,%esp
  8012d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012da:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e4:	50                   	push   %eax
  8012e5:	e8 38 ff ff ff       	call   801222 <fd_lookup>
  8012ea:	89 c3                	mov    %eax,%ebx
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 05                	js     8012f8 <fd_close+0x30>
	    || fd != fd2)
  8012f3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012f6:	74 16                	je     80130e <fd_close+0x46>
		return (must_exist ? r : 0);
  8012f8:	89 f8                	mov    %edi,%eax
  8012fa:	84 c0                	test   %al,%al
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801301:	0f 44 d8             	cmove  %eax,%ebx
}
  801304:	89 d8                	mov    %ebx,%eax
  801306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	5f                   	pop    %edi
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	ff 36                	push   (%esi)
  801317:	e8 56 ff ff ff       	call   801272 <dev_lookup>
  80131c:	89 c3                	mov    %eax,%ebx
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	78 1a                	js     80133f <fd_close+0x77>
		if (dev->dev_close)
  801325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801328:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80132b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801330:	85 c0                	test   %eax,%eax
  801332:	74 0b                	je     80133f <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801334:	83 ec 0c             	sub    $0xc,%esp
  801337:	56                   	push   %esi
  801338:	ff d0                	call   *%eax
  80133a:	89 c3                	mov    %eax,%ebx
  80133c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	56                   	push   %esi
  801343:	6a 00                	push   $0x0
  801345:	e8 16 fa ff ff       	call   800d60 <sys_page_unmap>
	return r;
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	eb b5                	jmp    801304 <fd_close+0x3c>

0080134f <close>:

int
close(int fdnum)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	ff 75 08             	push   0x8(%ebp)
  80135c:	e8 c1 fe ff ff       	call   801222 <fd_lookup>
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	79 02                	jns    80136a <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801368:	c9                   	leave  
  801369:	c3                   	ret    
		return fd_close(fd, 1);
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	6a 01                	push   $0x1
  80136f:	ff 75 f4             	push   -0xc(%ebp)
  801372:	e8 51 ff ff ff       	call   8012c8 <fd_close>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	eb ec                	jmp    801368 <close+0x19>

0080137c <close_all>:

void
close_all(void)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	53                   	push   %ebx
  801380:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801383:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801388:	83 ec 0c             	sub    $0xc,%esp
  80138b:	53                   	push   %ebx
  80138c:	e8 be ff ff ff       	call   80134f <close>
	for (i = 0; i < MAXFD; i++)
  801391:	83 c3 01             	add    $0x1,%ebx
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	83 fb 20             	cmp    $0x20,%ebx
  80139a:	75 ec                	jne    801388 <close_all+0xc>
}
  80139c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    

008013a1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	57                   	push   %edi
  8013a5:	56                   	push   %esi
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	ff 75 08             	push   0x8(%ebp)
  8013b1:	e8 6c fe ff ff       	call   801222 <fd_lookup>
  8013b6:	89 c3                	mov    %eax,%ebx
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 7f                	js     80143e <dup+0x9d>
		return r;
	close(newfdnum);
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	ff 75 0c             	push   0xc(%ebp)
  8013c5:	e8 85 ff ff ff       	call   80134f <close>

	newfd = INDEX2FD(newfdnum);
  8013ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013cd:	c1 e6 0c             	shl    $0xc,%esi
  8013d0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d9:	89 3c 24             	mov    %edi,(%esp)
  8013dc:	e8 da fd ff ff       	call   8011bb <fd2data>
  8013e1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013e3:	89 34 24             	mov    %esi,(%esp)
  8013e6:	e8 d0 fd ff ff       	call   8011bb <fd2data>
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f1:	89 d8                	mov    %ebx,%eax
  8013f3:	c1 e8 16             	shr    $0x16,%eax
  8013f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013fd:	a8 01                	test   $0x1,%al
  8013ff:	74 11                	je     801412 <dup+0x71>
  801401:	89 d8                	mov    %ebx,%eax
  801403:	c1 e8 0c             	shr    $0xc,%eax
  801406:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80140d:	f6 c2 01             	test   $0x1,%dl
  801410:	75 36                	jne    801448 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801412:	89 f8                	mov    %edi,%eax
  801414:	c1 e8 0c             	shr    $0xc,%eax
  801417:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141e:	83 ec 0c             	sub    $0xc,%esp
  801421:	25 07 0e 00 00       	and    $0xe07,%eax
  801426:	50                   	push   %eax
  801427:	56                   	push   %esi
  801428:	6a 00                	push   $0x0
  80142a:	57                   	push   %edi
  80142b:	6a 00                	push   $0x0
  80142d:	e8 ec f8 ff ff       	call   800d1e <sys_page_map>
  801432:	89 c3                	mov    %eax,%ebx
  801434:	83 c4 20             	add    $0x20,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	78 33                	js     80146e <dup+0xcd>
		goto err;

	return newfdnum;
  80143b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80143e:	89 d8                	mov    %ebx,%eax
  801440:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801443:	5b                   	pop    %ebx
  801444:	5e                   	pop    %esi
  801445:	5f                   	pop    %edi
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801448:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144f:	83 ec 0c             	sub    $0xc,%esp
  801452:	25 07 0e 00 00       	and    $0xe07,%eax
  801457:	50                   	push   %eax
  801458:	ff 75 d4             	push   -0x2c(%ebp)
  80145b:	6a 00                	push   $0x0
  80145d:	53                   	push   %ebx
  80145e:	6a 00                	push   $0x0
  801460:	e8 b9 f8 ff ff       	call   800d1e <sys_page_map>
  801465:	89 c3                	mov    %eax,%ebx
  801467:	83 c4 20             	add    $0x20,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	79 a4                	jns    801412 <dup+0x71>
	sys_page_unmap(0, newfd);
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	56                   	push   %esi
  801472:	6a 00                	push   $0x0
  801474:	e8 e7 f8 ff ff       	call   800d60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801479:	83 c4 08             	add    $0x8,%esp
  80147c:	ff 75 d4             	push   -0x2c(%ebp)
  80147f:	6a 00                	push   $0x0
  801481:	e8 da f8 ff ff       	call   800d60 <sys_page_unmap>
	return r;
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	eb b3                	jmp    80143e <dup+0x9d>

0080148b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	56                   	push   %esi
  80148f:	53                   	push   %ebx
  801490:	83 ec 18             	sub    $0x18,%esp
  801493:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801496:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	56                   	push   %esi
  80149b:	e8 82 fd ff ff       	call   801222 <fd_lookup>
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 3c                	js     8014e3 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a7:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b0:	50                   	push   %eax
  8014b1:	ff 33                	push   (%ebx)
  8014b3:	e8 ba fd ff ff       	call   801272 <dev_lookup>
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 24                	js     8014e3 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014bf:	8b 43 08             	mov    0x8(%ebx),%eax
  8014c2:	83 e0 03             	and    $0x3,%eax
  8014c5:	83 f8 01             	cmp    $0x1,%eax
  8014c8:	74 20                	je     8014ea <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cd:	8b 40 08             	mov    0x8(%eax),%eax
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	74 37                	je     80150b <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d4:	83 ec 04             	sub    $0x4,%esp
  8014d7:	ff 75 10             	push   0x10(%ebp)
  8014da:	ff 75 0c             	push   0xc(%ebp)
  8014dd:	53                   	push   %ebx
  8014de:	ff d0                	call   *%eax
  8014e0:	83 c4 10             	add    $0x10,%esp
}
  8014e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e6:	5b                   	pop    %ebx
  8014e7:	5e                   	pop    %esi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ea:	a1 00 44 80 00       	mov    0x804400,%eax
  8014ef:	8b 40 48             	mov    0x48(%eax),%eax
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	56                   	push   %esi
  8014f6:	50                   	push   %eax
  8014f7:	68 b9 2c 80 00       	push   $0x802cb9
  8014fc:	e8 04 ee ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801509:	eb d8                	jmp    8014e3 <read+0x58>
		return -E_NOT_SUPP;
  80150b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801510:	eb d1                	jmp    8014e3 <read+0x58>

00801512 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	57                   	push   %edi
  801516:	56                   	push   %esi
  801517:	53                   	push   %ebx
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80151e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801521:	bb 00 00 00 00       	mov    $0x0,%ebx
  801526:	eb 02                	jmp    80152a <readn+0x18>
  801528:	01 c3                	add    %eax,%ebx
  80152a:	39 f3                	cmp    %esi,%ebx
  80152c:	73 21                	jae    80154f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	89 f0                	mov    %esi,%eax
  801533:	29 d8                	sub    %ebx,%eax
  801535:	50                   	push   %eax
  801536:	89 d8                	mov    %ebx,%eax
  801538:	03 45 0c             	add    0xc(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	57                   	push   %edi
  80153d:	e8 49 ff ff ff       	call   80148b <read>
		if (m < 0)
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	85 c0                	test   %eax,%eax
  801547:	78 04                	js     80154d <readn+0x3b>
			return m;
		if (m == 0)
  801549:	75 dd                	jne    801528 <readn+0x16>
  80154b:	eb 02                	jmp    80154f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80154d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80154f:	89 d8                	mov    %ebx,%eax
  801551:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801554:	5b                   	pop    %ebx
  801555:	5e                   	pop    %esi
  801556:	5f                   	pop    %edi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
  80155e:	83 ec 18             	sub    $0x18,%esp
  801561:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801564:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801567:	50                   	push   %eax
  801568:	53                   	push   %ebx
  801569:	e8 b4 fc ff ff       	call   801222 <fd_lookup>
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	85 c0                	test   %eax,%eax
  801573:	78 37                	js     8015ac <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801575:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157e:	50                   	push   %eax
  80157f:	ff 36                	push   (%esi)
  801581:	e8 ec fc ff ff       	call   801272 <dev_lookup>
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 1f                	js     8015ac <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801591:	74 20                	je     8015b3 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801593:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801596:	8b 40 0c             	mov    0xc(%eax),%eax
  801599:	85 c0                	test   %eax,%eax
  80159b:	74 37                	je     8015d4 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	ff 75 10             	push   0x10(%ebp)
  8015a3:	ff 75 0c             	push   0xc(%ebp)
  8015a6:	56                   	push   %esi
  8015a7:	ff d0                	call   *%eax
  8015a9:	83 c4 10             	add    $0x10,%esp
}
  8015ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b3:	a1 00 44 80 00       	mov    0x804400,%eax
  8015b8:	8b 40 48             	mov    0x48(%eax),%eax
  8015bb:	83 ec 04             	sub    $0x4,%esp
  8015be:	53                   	push   %ebx
  8015bf:	50                   	push   %eax
  8015c0:	68 d5 2c 80 00       	push   $0x802cd5
  8015c5:	e8 3b ed ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d2:	eb d8                	jmp    8015ac <write+0x53>
		return -E_NOT_SUPP;
  8015d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015d9:	eb d1                	jmp    8015ac <write+0x53>

008015db <seek>:

int
seek(int fdnum, off_t offset)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	ff 75 08             	push   0x8(%ebp)
  8015e8:	e8 35 fc ff ff       	call   801222 <fd_lookup>
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 0e                	js     801602 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	56                   	push   %esi
  801608:	53                   	push   %ebx
  801609:	83 ec 18             	sub    $0x18,%esp
  80160c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	53                   	push   %ebx
  801614:	e8 09 fc ff ff       	call   801222 <fd_lookup>
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 34                	js     801654 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801620:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801629:	50                   	push   %eax
  80162a:	ff 36                	push   (%esi)
  80162c:	e8 41 fc ff ff       	call   801272 <dev_lookup>
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	85 c0                	test   %eax,%eax
  801636:	78 1c                	js     801654 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801638:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80163c:	74 1d                	je     80165b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80163e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801641:	8b 40 18             	mov    0x18(%eax),%eax
  801644:	85 c0                	test   %eax,%eax
  801646:	74 34                	je     80167c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	ff 75 0c             	push   0xc(%ebp)
  80164e:	56                   	push   %esi
  80164f:	ff d0                	call   *%eax
  801651:	83 c4 10             	add    $0x10,%esp
}
  801654:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801657:	5b                   	pop    %ebx
  801658:	5e                   	pop    %esi
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80165b:	a1 00 44 80 00       	mov    0x804400,%eax
  801660:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801663:	83 ec 04             	sub    $0x4,%esp
  801666:	53                   	push   %ebx
  801667:	50                   	push   %eax
  801668:	68 98 2c 80 00       	push   $0x802c98
  80166d:	e8 93 ec ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167a:	eb d8                	jmp    801654 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80167c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801681:	eb d1                	jmp    801654 <ftruncate+0x50>

00801683 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	56                   	push   %esi
  801687:	53                   	push   %ebx
  801688:	83 ec 18             	sub    $0x18,%esp
  80168b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	ff 75 08             	push   0x8(%ebp)
  801695:	e8 88 fb ff ff       	call   801222 <fd_lookup>
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 49                	js     8016ea <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016a4:	83 ec 08             	sub    $0x8,%esp
  8016a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016aa:	50                   	push   %eax
  8016ab:	ff 36                	push   (%esi)
  8016ad:	e8 c0 fb ff ff       	call   801272 <dev_lookup>
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	78 31                	js     8016ea <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c0:	74 2f                	je     8016f1 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016cc:	00 00 00 
	stat->st_isdir = 0;
  8016cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d6:	00 00 00 
	stat->st_dev = dev;
  8016d9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	53                   	push   %ebx
  8016e3:	56                   	push   %esi
  8016e4:	ff 50 14             	call   *0x14(%eax)
  8016e7:	83 c4 10             	add    $0x10,%esp
}
  8016ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    
		return -E_NOT_SUPP;
  8016f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f6:	eb f2                	jmp    8016ea <fstat+0x67>

008016f8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	6a 00                	push   $0x0
  801702:	ff 75 08             	push   0x8(%ebp)
  801705:	e8 e4 01 00 00       	call   8018ee <open>
  80170a:	89 c3                	mov    %eax,%ebx
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 1b                	js     80172e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801713:	83 ec 08             	sub    $0x8,%esp
  801716:	ff 75 0c             	push   0xc(%ebp)
  801719:	50                   	push   %eax
  80171a:	e8 64 ff ff ff       	call   801683 <fstat>
  80171f:	89 c6                	mov    %eax,%esi
	close(fd);
  801721:	89 1c 24             	mov    %ebx,(%esp)
  801724:	e8 26 fc ff ff       	call   80134f <close>
	return r;
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	89 f3                	mov    %esi,%ebx
}
  80172e:	89 d8                	mov    %ebx,%eax
  801730:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	89 c6                	mov    %eax,%esi
  80173e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801740:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801747:	74 27                	je     801770 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801749:	6a 07                	push   $0x7
  80174b:	68 00 50 80 00       	push   $0x805000
  801750:	56                   	push   %esi
  801751:	ff 35 00 60 80 00    	push   0x806000
  801757:	e8 af 0c 00 00       	call   80240b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80175c:	83 c4 0c             	add    $0xc,%esp
  80175f:	6a 00                	push   $0x0
  801761:	53                   	push   %ebx
  801762:	6a 00                	push   $0x0
  801764:	e8 3b 0c 00 00       	call   8023a4 <ipc_recv>
}
  801769:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176c:	5b                   	pop    %ebx
  80176d:	5e                   	pop    %esi
  80176e:	5d                   	pop    %ebp
  80176f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801770:	83 ec 0c             	sub    $0xc,%esp
  801773:	6a 01                	push   $0x1
  801775:	e8 e5 0c 00 00       	call   80245f <ipc_find_env>
  80177a:	a3 00 60 80 00       	mov    %eax,0x806000
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	eb c5                	jmp    801749 <fsipc+0x12>

00801784 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 40 0c             	mov    0xc(%eax),%eax
  801790:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801795:	8b 45 0c             	mov    0xc(%ebp),%eax
  801798:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80179d:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8017a7:	e8 8b ff ff ff       	call   801737 <fsipc>
}
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <devfile_flush>:
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8017c9:	e8 69 ff ff ff       	call   801737 <fsipc>
}
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    

008017d0 <devfile_stat>:
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ef:	e8 43 ff ff ff       	call   801737 <fsipc>
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	78 2c                	js     801824 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	68 00 50 80 00       	push   $0x805000
  801800:	53                   	push   %ebx
  801801:	e8 d9 f0 ff ff       	call   8008df <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801806:	a1 80 50 80 00       	mov    0x805080,%eax
  80180b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801811:	a1 84 50 80 00       	mov    0x805084,%eax
  801816:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801824:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801827:	c9                   	leave  
  801828:	c3                   	ret    

00801829 <devfile_write>:
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	8b 45 10             	mov    0x10(%ebp),%eax
  801832:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801837:	39 d0                	cmp    %edx,%eax
  801839:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80183c:	8b 55 08             	mov    0x8(%ebp),%edx
  80183f:	8b 52 0c             	mov    0xc(%edx),%edx
  801842:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801848:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80184d:	50                   	push   %eax
  80184e:	ff 75 0c             	push   0xc(%ebp)
  801851:	68 08 50 80 00       	push   $0x805008
  801856:	e8 1a f2 ff ff       	call   800a75 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80185b:	ba 00 00 00 00       	mov    $0x0,%edx
  801860:	b8 04 00 00 00       	mov    $0x4,%eax
  801865:	e8 cd fe ff ff       	call   801737 <fsipc>
}
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <devfile_read>:
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801874:	8b 45 08             	mov    0x8(%ebp),%eax
  801877:	8b 40 0c             	mov    0xc(%eax),%eax
  80187a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80187f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801885:	ba 00 00 00 00       	mov    $0x0,%edx
  80188a:	b8 03 00 00 00       	mov    $0x3,%eax
  80188f:	e8 a3 fe ff ff       	call   801737 <fsipc>
  801894:	89 c3                	mov    %eax,%ebx
  801896:	85 c0                	test   %eax,%eax
  801898:	78 1f                	js     8018b9 <devfile_read+0x4d>
	assert(r <= n);
  80189a:	39 f0                	cmp    %esi,%eax
  80189c:	77 24                	ja     8018c2 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80189e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a3:	7f 33                	jg     8018d8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018a5:	83 ec 04             	sub    $0x4,%esp
  8018a8:	50                   	push   %eax
  8018a9:	68 00 50 80 00       	push   $0x805000
  8018ae:	ff 75 0c             	push   0xc(%ebp)
  8018b1:	e8 bf f1 ff ff       	call   800a75 <memmove>
	return r;
  8018b6:	83 c4 10             	add    $0x10,%esp
}
  8018b9:	89 d8                	mov    %ebx,%eax
  8018bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018be:	5b                   	pop    %ebx
  8018bf:	5e                   	pop    %esi
  8018c0:	5d                   	pop    %ebp
  8018c1:	c3                   	ret    
	assert(r <= n);
  8018c2:	68 08 2d 80 00       	push   $0x802d08
  8018c7:	68 0f 2d 80 00       	push   $0x802d0f
  8018cc:	6a 7c                	push   $0x7c
  8018ce:	68 24 2d 80 00       	push   $0x802d24
  8018d3:	e8 52 e9 ff ff       	call   80022a <_panic>
	assert(r <= PGSIZE);
  8018d8:	68 2f 2d 80 00       	push   $0x802d2f
  8018dd:	68 0f 2d 80 00       	push   $0x802d0f
  8018e2:	6a 7d                	push   $0x7d
  8018e4:	68 24 2d 80 00       	push   $0x802d24
  8018e9:	e8 3c e9 ff ff       	call   80022a <_panic>

008018ee <open>:
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	56                   	push   %esi
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 1c             	sub    $0x1c,%esp
  8018f6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018f9:	56                   	push   %esi
  8018fa:	e8 a5 ef ff ff       	call   8008a4 <strlen>
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801907:	7f 6c                	jg     801975 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801909:	83 ec 0c             	sub    $0xc,%esp
  80190c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190f:	50                   	push   %eax
  801910:	e8 bd f8 ff ff       	call   8011d2 <fd_alloc>
  801915:	89 c3                	mov    %eax,%ebx
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	85 c0                	test   %eax,%eax
  80191c:	78 3c                	js     80195a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	56                   	push   %esi
  801922:	68 00 50 80 00       	push   $0x805000
  801927:	e8 b3 ef ff ff       	call   8008df <strcpy>
	fsipcbuf.open.req_omode = mode;
  80192c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801934:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801937:	b8 01 00 00 00       	mov    $0x1,%eax
  80193c:	e8 f6 fd ff ff       	call   801737 <fsipc>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	85 c0                	test   %eax,%eax
  801948:	78 19                	js     801963 <open+0x75>
	return fd2num(fd);
  80194a:	83 ec 0c             	sub    $0xc,%esp
  80194d:	ff 75 f4             	push   -0xc(%ebp)
  801950:	e8 56 f8 ff ff       	call   8011ab <fd2num>
  801955:	89 c3                	mov    %eax,%ebx
  801957:	83 c4 10             	add    $0x10,%esp
}
  80195a:	89 d8                	mov    %ebx,%eax
  80195c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195f:	5b                   	pop    %ebx
  801960:	5e                   	pop    %esi
  801961:	5d                   	pop    %ebp
  801962:	c3                   	ret    
		fd_close(fd, 0);
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	6a 00                	push   $0x0
  801968:	ff 75 f4             	push   -0xc(%ebp)
  80196b:	e8 58 f9 ff ff       	call   8012c8 <fd_close>
		return r;
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	eb e5                	jmp    80195a <open+0x6c>
		return -E_BAD_PATH;
  801975:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80197a:	eb de                	jmp    80195a <open+0x6c>

0080197c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801982:	ba 00 00 00 00       	mov    $0x0,%edx
  801987:	b8 08 00 00 00       	mov    $0x8,%eax
  80198c:	e8 a6 fd ff ff       	call   801737 <fsipc>
}
  801991:	c9                   	leave  
  801992:	c3                   	ret    

00801993 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801999:	68 3b 2d 80 00       	push   $0x802d3b
  80199e:	ff 75 0c             	push   0xc(%ebp)
  8019a1:	e8 39 ef ff ff       	call   8008df <strcpy>
	return 0;
}
  8019a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ab:	c9                   	leave  
  8019ac:	c3                   	ret    

008019ad <devsock_close>:
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 10             	sub    $0x10,%esp
  8019b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019b7:	53                   	push   %ebx
  8019b8:	e8 db 0a 00 00       	call   802498 <pageref>
  8019bd:	89 c2                	mov    %eax,%edx
  8019bf:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019c7:	83 fa 01             	cmp    $0x1,%edx
  8019ca:	74 05                	je     8019d1 <devsock_close+0x24>
}
  8019cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8019d1:	83 ec 0c             	sub    $0xc,%esp
  8019d4:	ff 73 0c             	push   0xc(%ebx)
  8019d7:	e8 b7 02 00 00       	call   801c93 <nsipc_close>
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	eb eb                	jmp    8019cc <devsock_close+0x1f>

008019e1 <devsock_write>:
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019e7:	6a 00                	push   $0x0
  8019e9:	ff 75 10             	push   0x10(%ebp)
  8019ec:	ff 75 0c             	push   0xc(%ebp)
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	ff 70 0c             	push   0xc(%eax)
  8019f5:	e8 79 03 00 00       	call   801d73 <nsipc_send>
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <devsock_read>:
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a02:	6a 00                	push   $0x0
  801a04:	ff 75 10             	push   0x10(%ebp)
  801a07:	ff 75 0c             	push   0xc(%ebp)
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	ff 70 0c             	push   0xc(%eax)
  801a10:	e8 ef 02 00 00       	call   801d04 <nsipc_recv>
}
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <fd2sockid>:
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a1d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a20:	52                   	push   %edx
  801a21:	50                   	push   %eax
  801a22:	e8 fb f7 ff ff       	call   801222 <fd_lookup>
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 10                	js     801a3e <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a31:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a37:	39 08                	cmp    %ecx,(%eax)
  801a39:	75 05                	jne    801a40 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a3b:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    
		return -E_NOT_SUPP;
  801a40:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a45:	eb f7                	jmp    801a3e <fd2sockid+0x27>

00801a47 <alloc_sockfd>:
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	56                   	push   %esi
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 1c             	sub    $0x1c,%esp
  801a4f:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a54:	50                   	push   %eax
  801a55:	e8 78 f7 ff ff       	call   8011d2 <fd_alloc>
  801a5a:	89 c3                	mov    %eax,%ebx
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	78 43                	js     801aa6 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a63:	83 ec 04             	sub    $0x4,%esp
  801a66:	68 07 04 00 00       	push   $0x407
  801a6b:	ff 75 f4             	push   -0xc(%ebp)
  801a6e:	6a 00                	push   $0x0
  801a70:	e8 66 f2 ff ff       	call   800cdb <sys_page_alloc>
  801a75:	89 c3                	mov    %eax,%ebx
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 28                	js     801aa6 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a81:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a87:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a93:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	50                   	push   %eax
  801a9a:	e8 0c f7 ff ff       	call   8011ab <fd2num>
  801a9f:	89 c3                	mov    %eax,%ebx
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	eb 0c                	jmp    801ab2 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	56                   	push   %esi
  801aaa:	e8 e4 01 00 00       	call   801c93 <nsipc_close>
		return r;
  801aaf:	83 c4 10             	add    $0x10,%esp
}
  801ab2:	89 d8                	mov    %ebx,%eax
  801ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <accept>:
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac4:	e8 4e ff ff ff       	call   801a17 <fd2sockid>
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	78 1b                	js     801ae8 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	ff 75 10             	push   0x10(%ebp)
  801ad3:	ff 75 0c             	push   0xc(%ebp)
  801ad6:	50                   	push   %eax
  801ad7:	e8 0e 01 00 00       	call   801bea <nsipc_accept>
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	78 05                	js     801ae8 <accept+0x2d>
	return alloc_sockfd(r);
  801ae3:	e8 5f ff ff ff       	call   801a47 <alloc_sockfd>
}
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <bind>:
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	e8 1f ff ff ff       	call   801a17 <fd2sockid>
  801af8:	85 c0                	test   %eax,%eax
  801afa:	78 12                	js     801b0e <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801afc:	83 ec 04             	sub    $0x4,%esp
  801aff:	ff 75 10             	push   0x10(%ebp)
  801b02:	ff 75 0c             	push   0xc(%ebp)
  801b05:	50                   	push   %eax
  801b06:	e8 31 01 00 00       	call   801c3c <nsipc_bind>
  801b0b:	83 c4 10             	add    $0x10,%esp
}
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <shutdown>:
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b16:	8b 45 08             	mov    0x8(%ebp),%eax
  801b19:	e8 f9 fe ff ff       	call   801a17 <fd2sockid>
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 0f                	js     801b31 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b22:	83 ec 08             	sub    $0x8,%esp
  801b25:	ff 75 0c             	push   0xc(%ebp)
  801b28:	50                   	push   %eax
  801b29:	e8 43 01 00 00       	call   801c71 <nsipc_shutdown>
  801b2e:	83 c4 10             	add    $0x10,%esp
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <connect>:
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b39:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3c:	e8 d6 fe ff ff       	call   801a17 <fd2sockid>
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 12                	js     801b57 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b45:	83 ec 04             	sub    $0x4,%esp
  801b48:	ff 75 10             	push   0x10(%ebp)
  801b4b:	ff 75 0c             	push   0xc(%ebp)
  801b4e:	50                   	push   %eax
  801b4f:	e8 59 01 00 00       	call   801cad <nsipc_connect>
  801b54:	83 c4 10             	add    $0x10,%esp
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <listen>:
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	e8 b0 fe ff ff       	call   801a17 <fd2sockid>
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 0f                	js     801b7a <listen+0x21>
	return nsipc_listen(r, backlog);
  801b6b:	83 ec 08             	sub    $0x8,%esp
  801b6e:	ff 75 0c             	push   0xc(%ebp)
  801b71:	50                   	push   %eax
  801b72:	e8 6b 01 00 00       	call   801ce2 <nsipc_listen>
  801b77:	83 c4 10             	add    $0x10,%esp
}
  801b7a:	c9                   	leave  
  801b7b:	c3                   	ret    

00801b7c <socket>:

int
socket(int domain, int type, int protocol)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b82:	ff 75 10             	push   0x10(%ebp)
  801b85:	ff 75 0c             	push   0xc(%ebp)
  801b88:	ff 75 08             	push   0x8(%ebp)
  801b8b:	e8 41 02 00 00       	call   801dd1 <nsipc_socket>
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	85 c0                	test   %eax,%eax
  801b95:	78 05                	js     801b9c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b97:	e8 ab fe ff ff       	call   801a47 <alloc_sockfd>
}
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	53                   	push   %ebx
  801ba2:	83 ec 04             	sub    $0x4,%esp
  801ba5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba7:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801bae:	74 26                	je     801bd6 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bb0:	6a 07                	push   $0x7
  801bb2:	68 00 70 80 00       	push   $0x807000
  801bb7:	53                   	push   %ebx
  801bb8:	ff 35 00 80 80 00    	push   0x808000
  801bbe:	e8 48 08 00 00       	call   80240b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bc3:	83 c4 0c             	add    $0xc,%esp
  801bc6:	6a 00                	push   $0x0
  801bc8:	6a 00                	push   $0x0
  801bca:	6a 00                	push   $0x0
  801bcc:	e8 d3 07 00 00       	call   8023a4 <ipc_recv>
}
  801bd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd4:	c9                   	leave  
  801bd5:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bd6:	83 ec 0c             	sub    $0xc,%esp
  801bd9:	6a 02                	push   $0x2
  801bdb:	e8 7f 08 00 00       	call   80245f <ipc_find_env>
  801be0:	a3 00 80 80 00       	mov    %eax,0x808000
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	eb c6                	jmp    801bb0 <nsipc+0x12>

00801bea <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	56                   	push   %esi
  801bee:	53                   	push   %ebx
  801bef:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bfa:	8b 06                	mov    (%esi),%eax
  801bfc:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	e8 93 ff ff ff       	call   801b9e <nsipc>
  801c0b:	89 c3                	mov    %eax,%ebx
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	79 09                	jns    801c1a <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c11:	89 d8                	mov    %ebx,%eax
  801c13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c1a:	83 ec 04             	sub    $0x4,%esp
  801c1d:	ff 35 10 70 80 00    	push   0x807010
  801c23:	68 00 70 80 00       	push   $0x807000
  801c28:	ff 75 0c             	push   0xc(%ebp)
  801c2b:	e8 45 ee ff ff       	call   800a75 <memmove>
		*addrlen = ret->ret_addrlen;
  801c30:	a1 10 70 80 00       	mov    0x807010,%eax
  801c35:	89 06                	mov    %eax,(%esi)
  801c37:	83 c4 10             	add    $0x10,%esp
	return r;
  801c3a:	eb d5                	jmp    801c11 <nsipc_accept+0x27>

00801c3c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	53                   	push   %ebx
  801c40:	83 ec 08             	sub    $0x8,%esp
  801c43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c4e:	53                   	push   %ebx
  801c4f:	ff 75 0c             	push   0xc(%ebp)
  801c52:	68 04 70 80 00       	push   $0x807004
  801c57:	e8 19 ee ff ff       	call   800a75 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c5c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c62:	b8 02 00 00 00       	mov    $0x2,%eax
  801c67:	e8 32 ff ff ff       	call   801b9e <nsipc>
}
  801c6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    

00801c71 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c77:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c82:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801c87:	b8 03 00 00 00       	mov    $0x3,%eax
  801c8c:	e8 0d ff ff ff       	call   801b9e <nsipc>
}
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    

00801c93 <nsipc_close>:

int
nsipc_close(int s)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c99:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9c:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801ca1:	b8 04 00 00 00       	mov    $0x4,%eax
  801ca6:	e8 f3 fe ff ff       	call   801b9e <nsipc>
}
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	53                   	push   %ebx
  801cb1:	83 ec 08             	sub    $0x8,%esp
  801cb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cba:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cbf:	53                   	push   %ebx
  801cc0:	ff 75 0c             	push   0xc(%ebp)
  801cc3:	68 04 70 80 00       	push   $0x807004
  801cc8:	e8 a8 ed ff ff       	call   800a75 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ccd:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801cd3:	b8 05 00 00 00       	mov    $0x5,%eax
  801cd8:	e8 c1 fe ff ff       	call   801b9e <nsipc>
}
  801cdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801cf8:	b8 06 00 00 00       	mov    $0x6,%eax
  801cfd:	e8 9c fe ff ff       	call   801b9e <nsipc>
}
  801d02:	c9                   	leave  
  801d03:	c3                   	ret    

00801d04 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	56                   	push   %esi
  801d08:	53                   	push   %ebx
  801d09:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d14:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d1a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d1d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d22:	b8 07 00 00 00       	mov    $0x7,%eax
  801d27:	e8 72 fe ff ff       	call   801b9e <nsipc>
  801d2c:	89 c3                	mov    %eax,%ebx
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 22                	js     801d54 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d32:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d37:	39 c6                	cmp    %eax,%esi
  801d39:	0f 4e c6             	cmovle %esi,%eax
  801d3c:	39 c3                	cmp    %eax,%ebx
  801d3e:	7f 1d                	jg     801d5d <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d40:	83 ec 04             	sub    $0x4,%esp
  801d43:	53                   	push   %ebx
  801d44:	68 00 70 80 00       	push   $0x807000
  801d49:	ff 75 0c             	push   0xc(%ebp)
  801d4c:	e8 24 ed ff ff       	call   800a75 <memmove>
  801d51:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d54:	89 d8                	mov    %ebx,%eax
  801d56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d59:	5b                   	pop    %ebx
  801d5a:	5e                   	pop    %esi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d5d:	68 47 2d 80 00       	push   $0x802d47
  801d62:	68 0f 2d 80 00       	push   $0x802d0f
  801d67:	6a 62                	push   $0x62
  801d69:	68 5c 2d 80 00       	push   $0x802d5c
  801d6e:	e8 b7 e4 ff ff       	call   80022a <_panic>

00801d73 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	53                   	push   %ebx
  801d77:	83 ec 04             	sub    $0x4,%esp
  801d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801d85:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d8b:	7f 2e                	jg     801dbb <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d8d:	83 ec 04             	sub    $0x4,%esp
  801d90:	53                   	push   %ebx
  801d91:	ff 75 0c             	push   0xc(%ebp)
  801d94:	68 0c 70 80 00       	push   $0x80700c
  801d99:	e8 d7 ec ff ff       	call   800a75 <memmove>
	nsipcbuf.send.req_size = size;
  801d9e:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801da4:	8b 45 14             	mov    0x14(%ebp),%eax
  801da7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801dac:	b8 08 00 00 00       	mov    $0x8,%eax
  801db1:	e8 e8 fd ff ff       	call   801b9e <nsipc>
}
  801db6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    
	assert(size < 1600);
  801dbb:	68 68 2d 80 00       	push   $0x802d68
  801dc0:	68 0f 2d 80 00       	push   $0x802d0f
  801dc5:	6a 6d                	push   $0x6d
  801dc7:	68 5c 2d 80 00       	push   $0x802d5c
  801dcc:	e8 59 e4 ff ff       	call   80022a <_panic>

00801dd1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dda:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de2:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801de7:	8b 45 10             	mov    0x10(%ebp),%eax
  801dea:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801def:	b8 09 00 00 00       	mov    $0x9,%eax
  801df4:	e8 a5 fd ff ff       	call   801b9e <nsipc>
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	56                   	push   %esi
  801dff:	53                   	push   %ebx
  801e00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e03:	83 ec 0c             	sub    $0xc,%esp
  801e06:	ff 75 08             	push   0x8(%ebp)
  801e09:	e8 ad f3 ff ff       	call   8011bb <fd2data>
  801e0e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e10:	83 c4 08             	add    $0x8,%esp
  801e13:	68 74 2d 80 00       	push   $0x802d74
  801e18:	53                   	push   %ebx
  801e19:	e8 c1 ea ff ff       	call   8008df <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e1e:	8b 46 04             	mov    0x4(%esi),%eax
  801e21:	2b 06                	sub    (%esi),%eax
  801e23:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e29:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e30:	00 00 00 
	stat->st_dev = &devpipe;
  801e33:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e3a:	30 80 00 
	return 0;
}
  801e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e45:	5b                   	pop    %ebx
  801e46:	5e                   	pop    %esi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	53                   	push   %ebx
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e53:	53                   	push   %ebx
  801e54:	6a 00                	push   $0x0
  801e56:	e8 05 ef ff ff       	call   800d60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e5b:	89 1c 24             	mov    %ebx,(%esp)
  801e5e:	e8 58 f3 ff ff       	call   8011bb <fd2data>
  801e63:	83 c4 08             	add    $0x8,%esp
  801e66:	50                   	push   %eax
  801e67:	6a 00                	push   $0x0
  801e69:	e8 f2 ee ff ff       	call   800d60 <sys_page_unmap>
}
  801e6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <_pipeisclosed>:
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	57                   	push   %edi
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	83 ec 1c             	sub    $0x1c,%esp
  801e7c:	89 c7                	mov    %eax,%edi
  801e7e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e80:	a1 00 44 80 00       	mov    0x804400,%eax
  801e85:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e88:	83 ec 0c             	sub    $0xc,%esp
  801e8b:	57                   	push   %edi
  801e8c:	e8 07 06 00 00       	call   802498 <pageref>
  801e91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e94:	89 34 24             	mov    %esi,(%esp)
  801e97:	e8 fc 05 00 00       	call   802498 <pageref>
		nn = thisenv->env_runs;
  801e9c:	8b 15 00 44 80 00    	mov    0x804400,%edx
  801ea2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	39 cb                	cmp    %ecx,%ebx
  801eaa:	74 1b                	je     801ec7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801eac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801eaf:	75 cf                	jne    801e80 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb1:	8b 42 58             	mov    0x58(%edx),%eax
  801eb4:	6a 01                	push   $0x1
  801eb6:	50                   	push   %eax
  801eb7:	53                   	push   %ebx
  801eb8:	68 7b 2d 80 00       	push   $0x802d7b
  801ebd:	e8 43 e4 ff ff       	call   800305 <cprintf>
  801ec2:	83 c4 10             	add    $0x10,%esp
  801ec5:	eb b9                	jmp    801e80 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ec7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801eca:	0f 94 c0             	sete   %al
  801ecd:	0f b6 c0             	movzbl %al,%eax
}
  801ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <devpipe_write>:
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	57                   	push   %edi
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	83 ec 28             	sub    $0x28,%esp
  801ee1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ee4:	56                   	push   %esi
  801ee5:	e8 d1 f2 ff ff       	call   8011bb <fd2data>
  801eea:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	bf 00 00 00 00       	mov    $0x0,%edi
  801ef4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ef7:	75 09                	jne    801f02 <devpipe_write+0x2a>
	return i;
  801ef9:	89 f8                	mov    %edi,%eax
  801efb:	eb 23                	jmp    801f20 <devpipe_write+0x48>
			sys_yield();
  801efd:	e8 ba ed ff ff       	call   800cbc <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f02:	8b 43 04             	mov    0x4(%ebx),%eax
  801f05:	8b 0b                	mov    (%ebx),%ecx
  801f07:	8d 51 20             	lea    0x20(%ecx),%edx
  801f0a:	39 d0                	cmp    %edx,%eax
  801f0c:	72 1a                	jb     801f28 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f0e:	89 da                	mov    %ebx,%edx
  801f10:	89 f0                	mov    %esi,%eax
  801f12:	e8 5c ff ff ff       	call   801e73 <_pipeisclosed>
  801f17:	85 c0                	test   %eax,%eax
  801f19:	74 e2                	je     801efd <devpipe_write+0x25>
				return 0;
  801f1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f2b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f2f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f32:	89 c2                	mov    %eax,%edx
  801f34:	c1 fa 1f             	sar    $0x1f,%edx
  801f37:	89 d1                	mov    %edx,%ecx
  801f39:	c1 e9 1b             	shr    $0x1b,%ecx
  801f3c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f3f:	83 e2 1f             	and    $0x1f,%edx
  801f42:	29 ca                	sub    %ecx,%edx
  801f44:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f48:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f4c:	83 c0 01             	add    $0x1,%eax
  801f4f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f52:	83 c7 01             	add    $0x1,%edi
  801f55:	eb 9d                	jmp    801ef4 <devpipe_write+0x1c>

00801f57 <devpipe_read>:
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	57                   	push   %edi
  801f5b:	56                   	push   %esi
  801f5c:	53                   	push   %ebx
  801f5d:	83 ec 18             	sub    $0x18,%esp
  801f60:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f63:	57                   	push   %edi
  801f64:	e8 52 f2 ff ff       	call   8011bb <fd2data>
  801f69:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	be 00 00 00 00       	mov    $0x0,%esi
  801f73:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f76:	75 13                	jne    801f8b <devpipe_read+0x34>
	return i;
  801f78:	89 f0                	mov    %esi,%eax
  801f7a:	eb 02                	jmp    801f7e <devpipe_read+0x27>
				return i;
  801f7c:	89 f0                	mov    %esi,%eax
}
  801f7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f81:	5b                   	pop    %ebx
  801f82:	5e                   	pop    %esi
  801f83:	5f                   	pop    %edi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    
			sys_yield();
  801f86:	e8 31 ed ff ff       	call   800cbc <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f8b:	8b 03                	mov    (%ebx),%eax
  801f8d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f90:	75 18                	jne    801faa <devpipe_read+0x53>
			if (i > 0)
  801f92:	85 f6                	test   %esi,%esi
  801f94:	75 e6                	jne    801f7c <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801f96:	89 da                	mov    %ebx,%edx
  801f98:	89 f8                	mov    %edi,%eax
  801f9a:	e8 d4 fe ff ff       	call   801e73 <_pipeisclosed>
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	74 e3                	je     801f86 <devpipe_read+0x2f>
				return 0;
  801fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa8:	eb d4                	jmp    801f7e <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801faa:	99                   	cltd   
  801fab:	c1 ea 1b             	shr    $0x1b,%edx
  801fae:	01 d0                	add    %edx,%eax
  801fb0:	83 e0 1f             	and    $0x1f,%eax
  801fb3:	29 d0                	sub    %edx,%eax
  801fb5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fbd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801fc0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801fc3:	83 c6 01             	add    $0x1,%esi
  801fc6:	eb ab                	jmp    801f73 <devpipe_read+0x1c>

00801fc8 <pipe>:
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd3:	50                   	push   %eax
  801fd4:	e8 f9 f1 ff ff       	call   8011d2 <fd_alloc>
  801fd9:	89 c3                	mov    %eax,%ebx
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	0f 88 23 01 00 00    	js     802109 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe6:	83 ec 04             	sub    $0x4,%esp
  801fe9:	68 07 04 00 00       	push   $0x407
  801fee:	ff 75 f4             	push   -0xc(%ebp)
  801ff1:	6a 00                	push   $0x0
  801ff3:	e8 e3 ec ff ff       	call   800cdb <sys_page_alloc>
  801ff8:	89 c3                	mov    %eax,%ebx
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	0f 88 04 01 00 00    	js     802109 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802005:	83 ec 0c             	sub    $0xc,%esp
  802008:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80200b:	50                   	push   %eax
  80200c:	e8 c1 f1 ff ff       	call   8011d2 <fd_alloc>
  802011:	89 c3                	mov    %eax,%ebx
  802013:	83 c4 10             	add    $0x10,%esp
  802016:	85 c0                	test   %eax,%eax
  802018:	0f 88 db 00 00 00    	js     8020f9 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201e:	83 ec 04             	sub    $0x4,%esp
  802021:	68 07 04 00 00       	push   $0x407
  802026:	ff 75 f0             	push   -0x10(%ebp)
  802029:	6a 00                	push   $0x0
  80202b:	e8 ab ec ff ff       	call   800cdb <sys_page_alloc>
  802030:	89 c3                	mov    %eax,%ebx
  802032:	83 c4 10             	add    $0x10,%esp
  802035:	85 c0                	test   %eax,%eax
  802037:	0f 88 bc 00 00 00    	js     8020f9 <pipe+0x131>
	va = fd2data(fd0);
  80203d:	83 ec 0c             	sub    $0xc,%esp
  802040:	ff 75 f4             	push   -0xc(%ebp)
  802043:	e8 73 f1 ff ff       	call   8011bb <fd2data>
  802048:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204a:	83 c4 0c             	add    $0xc,%esp
  80204d:	68 07 04 00 00       	push   $0x407
  802052:	50                   	push   %eax
  802053:	6a 00                	push   $0x0
  802055:	e8 81 ec ff ff       	call   800cdb <sys_page_alloc>
  80205a:	89 c3                	mov    %eax,%ebx
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	85 c0                	test   %eax,%eax
  802061:	0f 88 82 00 00 00    	js     8020e9 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802067:	83 ec 0c             	sub    $0xc,%esp
  80206a:	ff 75 f0             	push   -0x10(%ebp)
  80206d:	e8 49 f1 ff ff       	call   8011bb <fd2data>
  802072:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802079:	50                   	push   %eax
  80207a:	6a 00                	push   $0x0
  80207c:	56                   	push   %esi
  80207d:	6a 00                	push   $0x0
  80207f:	e8 9a ec ff ff       	call   800d1e <sys_page_map>
  802084:	89 c3                	mov    %eax,%ebx
  802086:	83 c4 20             	add    $0x20,%esp
  802089:	85 c0                	test   %eax,%eax
  80208b:	78 4e                	js     8020db <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80208d:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802092:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802095:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802097:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80209a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020a4:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020b0:	83 ec 0c             	sub    $0xc,%esp
  8020b3:	ff 75 f4             	push   -0xc(%ebp)
  8020b6:	e8 f0 f0 ff ff       	call   8011ab <fd2num>
  8020bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020be:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020c0:	83 c4 04             	add    $0x4,%esp
  8020c3:	ff 75 f0             	push   -0x10(%ebp)
  8020c6:	e8 e0 f0 ff ff       	call   8011ab <fd2num>
  8020cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ce:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020d1:	83 c4 10             	add    $0x10,%esp
  8020d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d9:	eb 2e                	jmp    802109 <pipe+0x141>
	sys_page_unmap(0, va);
  8020db:	83 ec 08             	sub    $0x8,%esp
  8020de:	56                   	push   %esi
  8020df:	6a 00                	push   $0x0
  8020e1:	e8 7a ec ff ff       	call   800d60 <sys_page_unmap>
  8020e6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8020e9:	83 ec 08             	sub    $0x8,%esp
  8020ec:	ff 75 f0             	push   -0x10(%ebp)
  8020ef:	6a 00                	push   $0x0
  8020f1:	e8 6a ec ff ff       	call   800d60 <sys_page_unmap>
  8020f6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8020f9:	83 ec 08             	sub    $0x8,%esp
  8020fc:	ff 75 f4             	push   -0xc(%ebp)
  8020ff:	6a 00                	push   $0x0
  802101:	e8 5a ec ff ff       	call   800d60 <sys_page_unmap>
  802106:	83 c4 10             	add    $0x10,%esp
}
  802109:	89 d8                	mov    %ebx,%eax
  80210b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80210e:	5b                   	pop    %ebx
  80210f:	5e                   	pop    %esi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    

00802112 <pipeisclosed>:
{
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802118:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211b:	50                   	push   %eax
  80211c:	ff 75 08             	push   0x8(%ebp)
  80211f:	e8 fe f0 ff ff       	call   801222 <fd_lookup>
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	85 c0                	test   %eax,%eax
  802129:	78 18                	js     802143 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80212b:	83 ec 0c             	sub    $0xc,%esp
  80212e:	ff 75 f4             	push   -0xc(%ebp)
  802131:	e8 85 f0 ff ff       	call   8011bb <fd2data>
  802136:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213b:	e8 33 fd ff ff       	call   801e73 <_pipeisclosed>
  802140:	83 c4 10             	add    $0x10,%esp
}
  802143:	c9                   	leave  
  802144:	c3                   	ret    

00802145 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	56                   	push   %esi
  802149:	53                   	push   %ebx
  80214a:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80214d:	85 f6                	test   %esi,%esi
  80214f:	74 13                	je     802164 <wait+0x1f>
	e = &envs[ENVX(envid)];
  802151:	89 f3                	mov    %esi,%ebx
  802153:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802159:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80215c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802162:	eb 1b                	jmp    80217f <wait+0x3a>
	assert(envid != 0);
  802164:	68 93 2d 80 00       	push   $0x802d93
  802169:	68 0f 2d 80 00       	push   $0x802d0f
  80216e:	6a 09                	push   $0x9
  802170:	68 9e 2d 80 00       	push   $0x802d9e
  802175:	e8 b0 e0 ff ff       	call   80022a <_panic>
		sys_yield();
  80217a:	e8 3d eb ff ff       	call   800cbc <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80217f:	8b 43 48             	mov    0x48(%ebx),%eax
  802182:	39 f0                	cmp    %esi,%eax
  802184:	75 07                	jne    80218d <wait+0x48>
  802186:	8b 43 54             	mov    0x54(%ebx),%eax
  802189:	85 c0                	test   %eax,%eax
  80218b:	75 ed                	jne    80217a <wait+0x35>
}
  80218d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802190:	5b                   	pop    %ebx
  802191:	5e                   	pop    %esi
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    

00802194 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802194:	b8 00 00 00 00       	mov    $0x0,%eax
  802199:	c3                   	ret    

0080219a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021a0:	68 a9 2d 80 00       	push   $0x802da9
  8021a5:	ff 75 0c             	push   0xc(%ebp)
  8021a8:	e8 32 e7 ff ff       	call   8008df <strcpy>
	return 0;
}
  8021ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b2:	c9                   	leave  
  8021b3:	c3                   	ret    

008021b4 <devcons_write>:
{
  8021b4:	55                   	push   %ebp
  8021b5:	89 e5                	mov    %esp,%ebp
  8021b7:	57                   	push   %edi
  8021b8:	56                   	push   %esi
  8021b9:	53                   	push   %ebx
  8021ba:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8021c0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021c5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8021cb:	eb 2e                	jmp    8021fb <devcons_write+0x47>
		m = n - tot;
  8021cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021d0:	29 f3                	sub    %esi,%ebx
  8021d2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8021d7:	39 c3                	cmp    %eax,%ebx
  8021d9:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021dc:	83 ec 04             	sub    $0x4,%esp
  8021df:	53                   	push   %ebx
  8021e0:	89 f0                	mov    %esi,%eax
  8021e2:	03 45 0c             	add    0xc(%ebp),%eax
  8021e5:	50                   	push   %eax
  8021e6:	57                   	push   %edi
  8021e7:	e8 89 e8 ff ff       	call   800a75 <memmove>
		sys_cputs(buf, m);
  8021ec:	83 c4 08             	add    $0x8,%esp
  8021ef:	53                   	push   %ebx
  8021f0:	57                   	push   %edi
  8021f1:	e8 29 ea ff ff       	call   800c1f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021f6:	01 de                	add    %ebx,%esi
  8021f8:	83 c4 10             	add    $0x10,%esp
  8021fb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021fe:	72 cd                	jb     8021cd <devcons_write+0x19>
}
  802200:	89 f0                	mov    %esi,%eax
  802202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802205:	5b                   	pop    %ebx
  802206:	5e                   	pop    %esi
  802207:	5f                   	pop    %edi
  802208:	5d                   	pop    %ebp
  802209:	c3                   	ret    

0080220a <devcons_read>:
{
  80220a:	55                   	push   %ebp
  80220b:	89 e5                	mov    %esp,%ebp
  80220d:	83 ec 08             	sub    $0x8,%esp
  802210:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802215:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802219:	75 07                	jne    802222 <devcons_read+0x18>
  80221b:	eb 1f                	jmp    80223c <devcons_read+0x32>
		sys_yield();
  80221d:	e8 9a ea ff ff       	call   800cbc <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802222:	e8 16 ea ff ff       	call   800c3d <sys_cgetc>
  802227:	85 c0                	test   %eax,%eax
  802229:	74 f2                	je     80221d <devcons_read+0x13>
	if (c < 0)
  80222b:	78 0f                	js     80223c <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80222d:	83 f8 04             	cmp    $0x4,%eax
  802230:	74 0c                	je     80223e <devcons_read+0x34>
	*(char*)vbuf = c;
  802232:	8b 55 0c             	mov    0xc(%ebp),%edx
  802235:	88 02                	mov    %al,(%edx)
	return 1;
  802237:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80223c:	c9                   	leave  
  80223d:	c3                   	ret    
		return 0;
  80223e:	b8 00 00 00 00       	mov    $0x0,%eax
  802243:	eb f7                	jmp    80223c <devcons_read+0x32>

00802245 <cputchar>:
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80224b:	8b 45 08             	mov    0x8(%ebp),%eax
  80224e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802251:	6a 01                	push   $0x1
  802253:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802256:	50                   	push   %eax
  802257:	e8 c3 e9 ff ff       	call   800c1f <sys_cputs>
}
  80225c:	83 c4 10             	add    $0x10,%esp
  80225f:	c9                   	leave  
  802260:	c3                   	ret    

00802261 <getchar>:
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802267:	6a 01                	push   $0x1
  802269:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80226c:	50                   	push   %eax
  80226d:	6a 00                	push   $0x0
  80226f:	e8 17 f2 ff ff       	call   80148b <read>
	if (r < 0)
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	85 c0                	test   %eax,%eax
  802279:	78 06                	js     802281 <getchar+0x20>
	if (r < 1)
  80227b:	74 06                	je     802283 <getchar+0x22>
	return c;
  80227d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802281:	c9                   	leave  
  802282:	c3                   	ret    
		return -E_EOF;
  802283:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802288:	eb f7                	jmp    802281 <getchar+0x20>

0080228a <iscons>:
{
  80228a:	55                   	push   %ebp
  80228b:	89 e5                	mov    %esp,%ebp
  80228d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802290:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802293:	50                   	push   %eax
  802294:	ff 75 08             	push   0x8(%ebp)
  802297:	e8 86 ef ff ff       	call   801222 <fd_lookup>
  80229c:	83 c4 10             	add    $0x10,%esp
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	78 11                	js     8022b4 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8022a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ac:	39 10                	cmp    %edx,(%eax)
  8022ae:	0f 94 c0             	sete   %al
  8022b1:	0f b6 c0             	movzbl %al,%eax
}
  8022b4:	c9                   	leave  
  8022b5:	c3                   	ret    

008022b6 <opencons>:
{
  8022b6:	55                   	push   %ebp
  8022b7:	89 e5                	mov    %esp,%ebp
  8022b9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8022bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022bf:	50                   	push   %eax
  8022c0:	e8 0d ef ff ff       	call   8011d2 <fd_alloc>
  8022c5:	83 c4 10             	add    $0x10,%esp
  8022c8:	85 c0                	test   %eax,%eax
  8022ca:	78 3a                	js     802306 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022cc:	83 ec 04             	sub    $0x4,%esp
  8022cf:	68 07 04 00 00       	push   $0x407
  8022d4:	ff 75 f4             	push   -0xc(%ebp)
  8022d7:	6a 00                	push   $0x0
  8022d9:	e8 fd e9 ff ff       	call   800cdb <sys_page_alloc>
  8022de:	83 c4 10             	add    $0x10,%esp
  8022e1:	85 c0                	test   %eax,%eax
  8022e3:	78 21                	js     802306 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8022e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022fa:	83 ec 0c             	sub    $0xc,%esp
  8022fd:	50                   	push   %eax
  8022fe:	e8 a8 ee ff ff       	call   8011ab <fd2num>
  802303:	83 c4 10             	add    $0x10,%esp
}
  802306:	c9                   	leave  
  802307:	c3                   	ret    

00802308 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802308:	55                   	push   %ebp
  802309:	89 e5                	mov    %esp,%ebp
  80230b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80230e:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  802315:	74 0a                	je     802321 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802317:	8b 45 08             	mov    0x8(%ebp),%eax
  80231a:	a3 04 80 80 00       	mov    %eax,0x808004
}
  80231f:	c9                   	leave  
  802320:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802321:	e8 77 e9 ff ff       	call   800c9d <sys_getenvid>
  802326:	83 ec 04             	sub    $0x4,%esp
  802329:	68 07 0e 00 00       	push   $0xe07
  80232e:	68 00 f0 bf ee       	push   $0xeebff000
  802333:	50                   	push   %eax
  802334:	e8 a2 e9 ff ff       	call   800cdb <sys_page_alloc>
		if (r < 0) {
  802339:	83 c4 10             	add    $0x10,%esp
  80233c:	85 c0                	test   %eax,%eax
  80233e:	78 2c                	js     80236c <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802340:	e8 58 e9 ff ff       	call   800c9d <sys_getenvid>
  802345:	83 ec 08             	sub    $0x8,%esp
  802348:	68 7e 23 80 00       	push   $0x80237e
  80234d:	50                   	push   %eax
  80234e:	e8 d3 ea ff ff       	call   800e26 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802353:	83 c4 10             	add    $0x10,%esp
  802356:	85 c0                	test   %eax,%eax
  802358:	79 bd                	jns    802317 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80235a:	50                   	push   %eax
  80235b:	68 f8 2d 80 00       	push   $0x802df8
  802360:	6a 28                	push   $0x28
  802362:	68 2e 2e 80 00       	push   $0x802e2e
  802367:	e8 be de ff ff       	call   80022a <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80236c:	50                   	push   %eax
  80236d:	68 b8 2d 80 00       	push   $0x802db8
  802372:	6a 23                	push   $0x23
  802374:	68 2e 2e 80 00       	push   $0x802e2e
  802379:	e8 ac de ff ff       	call   80022a <_panic>

0080237e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80237e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80237f:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802384:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802386:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802389:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80238d:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802390:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802394:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802398:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80239a:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80239d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80239e:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8023a1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8023a2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8023a3:	c3                   	ret    

008023a4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	56                   	push   %esi
  8023a8:	53                   	push   %ebx
  8023a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8023ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8023b2:	85 c0                	test   %eax,%eax
  8023b4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023b9:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8023bc:	83 ec 0c             	sub    $0xc,%esp
  8023bf:	50                   	push   %eax
  8023c0:	e8 c6 ea ff ff       	call   800e8b <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8023c5:	83 c4 10             	add    $0x10,%esp
  8023c8:	85 f6                	test   %esi,%esi
  8023ca:	74 14                	je     8023e0 <ipc_recv+0x3c>
  8023cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8023d1:	85 c0                	test   %eax,%eax
  8023d3:	78 09                	js     8023de <ipc_recv+0x3a>
  8023d5:	8b 15 00 44 80 00    	mov    0x804400,%edx
  8023db:	8b 52 74             	mov    0x74(%edx),%edx
  8023de:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8023e0:	85 db                	test   %ebx,%ebx
  8023e2:	74 14                	je     8023f8 <ipc_recv+0x54>
  8023e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8023e9:	85 c0                	test   %eax,%eax
  8023eb:	78 09                	js     8023f6 <ipc_recv+0x52>
  8023ed:	8b 15 00 44 80 00    	mov    0x804400,%edx
  8023f3:	8b 52 78             	mov    0x78(%edx),%edx
  8023f6:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8023f8:	85 c0                	test   %eax,%eax
  8023fa:	78 08                	js     802404 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8023fc:	a1 00 44 80 00       	mov    0x804400,%eax
  802401:	8b 40 70             	mov    0x70(%eax),%eax
}
  802404:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802407:	5b                   	pop    %ebx
  802408:	5e                   	pop    %esi
  802409:	5d                   	pop    %ebp
  80240a:	c3                   	ret    

0080240b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	57                   	push   %edi
  80240f:	56                   	push   %esi
  802410:	53                   	push   %ebx
  802411:	83 ec 0c             	sub    $0xc,%esp
  802414:	8b 7d 08             	mov    0x8(%ebp),%edi
  802417:	8b 75 0c             	mov    0xc(%ebp),%esi
  80241a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80241d:	85 db                	test   %ebx,%ebx
  80241f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802424:	0f 44 d8             	cmove  %eax,%ebx
  802427:	eb 05                	jmp    80242e <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802429:	e8 8e e8 ff ff       	call   800cbc <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80242e:	ff 75 14             	push   0x14(%ebp)
  802431:	53                   	push   %ebx
  802432:	56                   	push   %esi
  802433:	57                   	push   %edi
  802434:	e8 2f ea ff ff       	call   800e68 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802439:	83 c4 10             	add    $0x10,%esp
  80243c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80243f:	74 e8                	je     802429 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802441:	85 c0                	test   %eax,%eax
  802443:	78 08                	js     80244d <ipc_send+0x42>
	}while (r<0);

}
  802445:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80244d:	50                   	push   %eax
  80244e:	68 3c 2e 80 00       	push   $0x802e3c
  802453:	6a 3d                	push   $0x3d
  802455:	68 50 2e 80 00       	push   $0x802e50
  80245a:	e8 cb dd ff ff       	call   80022a <_panic>

0080245f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802465:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80246a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80246d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802473:	8b 52 50             	mov    0x50(%edx),%edx
  802476:	39 ca                	cmp    %ecx,%edx
  802478:	74 11                	je     80248b <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80247a:	83 c0 01             	add    $0x1,%eax
  80247d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802482:	75 e6                	jne    80246a <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802484:	b8 00 00 00 00       	mov    $0x0,%eax
  802489:	eb 0b                	jmp    802496 <ipc_find_env+0x37>
			return envs[i].env_id;
  80248b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80248e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802493:	8b 40 48             	mov    0x48(%eax),%eax
}
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    

00802498 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802498:	55                   	push   %ebp
  802499:	89 e5                	mov    %esp,%ebp
  80249b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80249e:	89 c2                	mov    %eax,%edx
  8024a0:	c1 ea 16             	shr    $0x16,%edx
  8024a3:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8024aa:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8024af:	f6 c1 01             	test   $0x1,%cl
  8024b2:	74 1c                	je     8024d0 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8024b4:	c1 e8 0c             	shr    $0xc,%eax
  8024b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024be:	a8 01                	test   $0x1,%al
  8024c0:	74 0e                	je     8024d0 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024c2:	c1 e8 0c             	shr    $0xc,%eax
  8024c5:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8024cc:	ef 
  8024cd:	0f b7 d2             	movzwl %dx,%edx
}
  8024d0:	89 d0                	mov    %edx,%eax
  8024d2:	5d                   	pop    %ebp
  8024d3:	c3                   	ret    
  8024d4:	66 90                	xchg   %ax,%ax
  8024d6:	66 90                	xchg   %ax,%ax
  8024d8:	66 90                	xchg   %ax,%ax
  8024da:	66 90                	xchg   %ax,%ax
  8024dc:	66 90                	xchg   %ax,%ax
  8024de:	66 90                	xchg   %ax,%ax

008024e0 <__udivdi3>:
  8024e0:	f3 0f 1e fb          	endbr32 
  8024e4:	55                   	push   %ebp
  8024e5:	57                   	push   %edi
  8024e6:	56                   	push   %esi
  8024e7:	53                   	push   %ebx
  8024e8:	83 ec 1c             	sub    $0x1c,%esp
  8024eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024f3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024fb:	85 c0                	test   %eax,%eax
  8024fd:	75 19                	jne    802518 <__udivdi3+0x38>
  8024ff:	39 f3                	cmp    %esi,%ebx
  802501:	76 4d                	jbe    802550 <__udivdi3+0x70>
  802503:	31 ff                	xor    %edi,%edi
  802505:	89 e8                	mov    %ebp,%eax
  802507:	89 f2                	mov    %esi,%edx
  802509:	f7 f3                	div    %ebx
  80250b:	89 fa                	mov    %edi,%edx
  80250d:	83 c4 1c             	add    $0x1c,%esp
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    
  802515:	8d 76 00             	lea    0x0(%esi),%esi
  802518:	39 f0                	cmp    %esi,%eax
  80251a:	76 14                	jbe    802530 <__udivdi3+0x50>
  80251c:	31 ff                	xor    %edi,%edi
  80251e:	31 c0                	xor    %eax,%eax
  802520:	89 fa                	mov    %edi,%edx
  802522:	83 c4 1c             	add    $0x1c,%esp
  802525:	5b                   	pop    %ebx
  802526:	5e                   	pop    %esi
  802527:	5f                   	pop    %edi
  802528:	5d                   	pop    %ebp
  802529:	c3                   	ret    
  80252a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802530:	0f bd f8             	bsr    %eax,%edi
  802533:	83 f7 1f             	xor    $0x1f,%edi
  802536:	75 48                	jne    802580 <__udivdi3+0xa0>
  802538:	39 f0                	cmp    %esi,%eax
  80253a:	72 06                	jb     802542 <__udivdi3+0x62>
  80253c:	31 c0                	xor    %eax,%eax
  80253e:	39 eb                	cmp    %ebp,%ebx
  802540:	77 de                	ja     802520 <__udivdi3+0x40>
  802542:	b8 01 00 00 00       	mov    $0x1,%eax
  802547:	eb d7                	jmp    802520 <__udivdi3+0x40>
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	89 d9                	mov    %ebx,%ecx
  802552:	85 db                	test   %ebx,%ebx
  802554:	75 0b                	jne    802561 <__udivdi3+0x81>
  802556:	b8 01 00 00 00       	mov    $0x1,%eax
  80255b:	31 d2                	xor    %edx,%edx
  80255d:	f7 f3                	div    %ebx
  80255f:	89 c1                	mov    %eax,%ecx
  802561:	31 d2                	xor    %edx,%edx
  802563:	89 f0                	mov    %esi,%eax
  802565:	f7 f1                	div    %ecx
  802567:	89 c6                	mov    %eax,%esi
  802569:	89 e8                	mov    %ebp,%eax
  80256b:	89 f7                	mov    %esi,%edi
  80256d:	f7 f1                	div    %ecx
  80256f:	89 fa                	mov    %edi,%edx
  802571:	83 c4 1c             	add    $0x1c,%esp
  802574:	5b                   	pop    %ebx
  802575:	5e                   	pop    %esi
  802576:	5f                   	pop    %edi
  802577:	5d                   	pop    %ebp
  802578:	c3                   	ret    
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	89 f9                	mov    %edi,%ecx
  802582:	ba 20 00 00 00       	mov    $0x20,%edx
  802587:	29 fa                	sub    %edi,%edx
  802589:	d3 e0                	shl    %cl,%eax
  80258b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80258f:	89 d1                	mov    %edx,%ecx
  802591:	89 d8                	mov    %ebx,%eax
  802593:	d3 e8                	shr    %cl,%eax
  802595:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802599:	09 c1                	or     %eax,%ecx
  80259b:	89 f0                	mov    %esi,%eax
  80259d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025a1:	89 f9                	mov    %edi,%ecx
  8025a3:	d3 e3                	shl    %cl,%ebx
  8025a5:	89 d1                	mov    %edx,%ecx
  8025a7:	d3 e8                	shr    %cl,%eax
  8025a9:	89 f9                	mov    %edi,%ecx
  8025ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8025af:	89 eb                	mov    %ebp,%ebx
  8025b1:	d3 e6                	shl    %cl,%esi
  8025b3:	89 d1                	mov    %edx,%ecx
  8025b5:	d3 eb                	shr    %cl,%ebx
  8025b7:	09 f3                	or     %esi,%ebx
  8025b9:	89 c6                	mov    %eax,%esi
  8025bb:	89 f2                	mov    %esi,%edx
  8025bd:	89 d8                	mov    %ebx,%eax
  8025bf:	f7 74 24 08          	divl   0x8(%esp)
  8025c3:	89 d6                	mov    %edx,%esi
  8025c5:	89 c3                	mov    %eax,%ebx
  8025c7:	f7 64 24 0c          	mull   0xc(%esp)
  8025cb:	39 d6                	cmp    %edx,%esi
  8025cd:	72 19                	jb     8025e8 <__udivdi3+0x108>
  8025cf:	89 f9                	mov    %edi,%ecx
  8025d1:	d3 e5                	shl    %cl,%ebp
  8025d3:	39 c5                	cmp    %eax,%ebp
  8025d5:	73 04                	jae    8025db <__udivdi3+0xfb>
  8025d7:	39 d6                	cmp    %edx,%esi
  8025d9:	74 0d                	je     8025e8 <__udivdi3+0x108>
  8025db:	89 d8                	mov    %ebx,%eax
  8025dd:	31 ff                	xor    %edi,%edi
  8025df:	e9 3c ff ff ff       	jmp    802520 <__udivdi3+0x40>
  8025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025eb:	31 ff                	xor    %edi,%edi
  8025ed:	e9 2e ff ff ff       	jmp    802520 <__udivdi3+0x40>
  8025f2:	66 90                	xchg   %ax,%ax
  8025f4:	66 90                	xchg   %ax,%ax
  8025f6:	66 90                	xchg   %ax,%ax
  8025f8:	66 90                	xchg   %ax,%ax
  8025fa:	66 90                	xchg   %ax,%ax
  8025fc:	66 90                	xchg   %ax,%ax
  8025fe:	66 90                	xchg   %ax,%ax

00802600 <__umoddi3>:
  802600:	f3 0f 1e fb          	endbr32 
  802604:	55                   	push   %ebp
  802605:	57                   	push   %edi
  802606:	56                   	push   %esi
  802607:	53                   	push   %ebx
  802608:	83 ec 1c             	sub    $0x1c,%esp
  80260b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80260f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802613:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802617:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80261b:	89 f0                	mov    %esi,%eax
  80261d:	89 da                	mov    %ebx,%edx
  80261f:	85 ff                	test   %edi,%edi
  802621:	75 15                	jne    802638 <__umoddi3+0x38>
  802623:	39 dd                	cmp    %ebx,%ebp
  802625:	76 39                	jbe    802660 <__umoddi3+0x60>
  802627:	f7 f5                	div    %ebp
  802629:	89 d0                	mov    %edx,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	83 c4 1c             	add    $0x1c,%esp
  802630:	5b                   	pop    %ebx
  802631:	5e                   	pop    %esi
  802632:	5f                   	pop    %edi
  802633:	5d                   	pop    %ebp
  802634:	c3                   	ret    
  802635:	8d 76 00             	lea    0x0(%esi),%esi
  802638:	39 df                	cmp    %ebx,%edi
  80263a:	77 f1                	ja     80262d <__umoddi3+0x2d>
  80263c:	0f bd cf             	bsr    %edi,%ecx
  80263f:	83 f1 1f             	xor    $0x1f,%ecx
  802642:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802646:	75 40                	jne    802688 <__umoddi3+0x88>
  802648:	39 df                	cmp    %ebx,%edi
  80264a:	72 04                	jb     802650 <__umoddi3+0x50>
  80264c:	39 f5                	cmp    %esi,%ebp
  80264e:	77 dd                	ja     80262d <__umoddi3+0x2d>
  802650:	89 da                	mov    %ebx,%edx
  802652:	89 f0                	mov    %esi,%eax
  802654:	29 e8                	sub    %ebp,%eax
  802656:	19 fa                	sbb    %edi,%edx
  802658:	eb d3                	jmp    80262d <__umoddi3+0x2d>
  80265a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802660:	89 e9                	mov    %ebp,%ecx
  802662:	85 ed                	test   %ebp,%ebp
  802664:	75 0b                	jne    802671 <__umoddi3+0x71>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f5                	div    %ebp
  80266f:	89 c1                	mov    %eax,%ecx
  802671:	89 d8                	mov    %ebx,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	f7 f1                	div    %ecx
  802677:	89 f0                	mov    %esi,%eax
  802679:	f7 f1                	div    %ecx
  80267b:	89 d0                	mov    %edx,%eax
  80267d:	31 d2                	xor    %edx,%edx
  80267f:	eb ac                	jmp    80262d <__umoddi3+0x2d>
  802681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802688:	8b 44 24 04          	mov    0x4(%esp),%eax
  80268c:	ba 20 00 00 00       	mov    $0x20,%edx
  802691:	29 c2                	sub    %eax,%edx
  802693:	89 c1                	mov    %eax,%ecx
  802695:	89 e8                	mov    %ebp,%eax
  802697:	d3 e7                	shl    %cl,%edi
  802699:	89 d1                	mov    %edx,%ecx
  80269b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80269f:	d3 e8                	shr    %cl,%eax
  8026a1:	89 c1                	mov    %eax,%ecx
  8026a3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026a7:	09 f9                	or     %edi,%ecx
  8026a9:	89 df                	mov    %ebx,%edi
  8026ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026af:	89 c1                	mov    %eax,%ecx
  8026b1:	d3 e5                	shl    %cl,%ebp
  8026b3:	89 d1                	mov    %edx,%ecx
  8026b5:	d3 ef                	shr    %cl,%edi
  8026b7:	89 c1                	mov    %eax,%ecx
  8026b9:	89 f0                	mov    %esi,%eax
  8026bb:	d3 e3                	shl    %cl,%ebx
  8026bd:	89 d1                	mov    %edx,%ecx
  8026bf:	89 fa                	mov    %edi,%edx
  8026c1:	d3 e8                	shr    %cl,%eax
  8026c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026c8:	09 d8                	or     %ebx,%eax
  8026ca:	f7 74 24 08          	divl   0x8(%esp)
  8026ce:	89 d3                	mov    %edx,%ebx
  8026d0:	d3 e6                	shl    %cl,%esi
  8026d2:	f7 e5                	mul    %ebp
  8026d4:	89 c7                	mov    %eax,%edi
  8026d6:	89 d1                	mov    %edx,%ecx
  8026d8:	39 d3                	cmp    %edx,%ebx
  8026da:	72 06                	jb     8026e2 <__umoddi3+0xe2>
  8026dc:	75 0e                	jne    8026ec <__umoddi3+0xec>
  8026de:	39 c6                	cmp    %eax,%esi
  8026e0:	73 0a                	jae    8026ec <__umoddi3+0xec>
  8026e2:	29 e8                	sub    %ebp,%eax
  8026e4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026e8:	89 d1                	mov    %edx,%ecx
  8026ea:	89 c7                	mov    %eax,%edi
  8026ec:	89 f5                	mov    %esi,%ebp
  8026ee:	8b 74 24 04          	mov    0x4(%esp),%esi
  8026f2:	29 fd                	sub    %edi,%ebp
  8026f4:	19 cb                	sbb    %ecx,%ebx
  8026f6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8026fb:	89 d8                	mov    %ebx,%eax
  8026fd:	d3 e0                	shl    %cl,%eax
  8026ff:	89 f1                	mov    %esi,%ecx
  802701:	d3 ed                	shr    %cl,%ebp
  802703:	d3 eb                	shr    %cl,%ebx
  802705:	09 e8                	or     %ebp,%eax
  802707:	89 da                	mov    %ebx,%edx
  802709:	83 c4 1c             	add    $0x1c,%esp
  80270c:	5b                   	pop    %ebx
  80270d:	5e                   	pop    %esi
  80270e:	5f                   	pop    %edi
  80270f:	5d                   	pop    %ebp
  802710:	c3                   	ret    
