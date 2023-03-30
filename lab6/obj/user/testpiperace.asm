
obj/user/testpiperace.debug：     文件格式 elf32-i386


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
  80002c:	e8 bd 01 00 00       	call   8001ee <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 00 27 80 00       	push   $0x802700
  800040:	e8 e4 02 00 00       	call   800329 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 cc 20 00 00       	call   80211c <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	78 59                	js     8000b0 <umain+0x7d>
		panic("pipe: %e", r);
	max = 200;
	if ((r = fork()) < 0)
  800057:	e8 f3 0f 00 00       	call   80104f <fork>
  80005c:	89 c6                	mov    %eax,%esi
  80005e:	85 c0                	test   %eax,%eax
  800060:	78 60                	js     8000c2 <umain+0x8f>
		panic("fork: %e", r);
	if (r == 0) {
  800062:	74 70                	je     8000d4 <umain+0xa1>
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800064:	83 ec 08             	sub    $0x8,%esp
  800067:	56                   	push   %esi
  800068:	68 51 27 80 00       	push   $0x802751
  80006d:	e8 b7 02 00 00       	call   800329 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800072:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  800078:	83 c4 08             	add    $0x8,%esp
  80007b:	6b c6 7c             	imul   $0x7c,%esi,%eax
  80007e:	c1 f8 02             	sar    $0x2,%eax
  800081:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800087:	50                   	push   %eax
  800088:	68 5c 27 80 00       	push   $0x80275c
  80008d:	e8 97 02 00 00       	call   800329 <cprintf>
	dup(p[0], 10);
  800092:	83 c4 08             	add    $0x8,%esp
  800095:	6a 0a                	push   $0xa
  800097:	ff 75 f0             	push   -0x10(%ebp)
  80009a:	e8 1a 14 00 00       	call   8014b9 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	6b de 7c             	imul   $0x7c,%esi,%ebx
  8000a5:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8000ab:	e9 92 00 00 00       	jmp    800142 <umain+0x10f>
		panic("pipe: %e", r);
  8000b0:	50                   	push   %eax
  8000b1:	68 19 27 80 00       	push   $0x802719
  8000b6:	6a 0d                	push   $0xd
  8000b8:	68 22 27 80 00       	push   $0x802722
  8000bd:	e8 8c 01 00 00       	call   80024e <_panic>
		panic("fork: %e", r);
  8000c2:	50                   	push   %eax
  8000c3:	68 f8 2b 80 00       	push   $0x802bf8
  8000c8:	6a 10                	push   $0x10
  8000ca:	68 22 27 80 00       	push   $0x802722
  8000cf:	e8 7a 01 00 00       	call   80024e <_panic>
		close(p[1]);
  8000d4:	83 ec 0c             	sub    $0xc,%esp
  8000d7:	ff 75 f4             	push   -0xc(%ebp)
  8000da:	e8 88 13 00 00       	call   801467 <close>
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	bb c8 00 00 00       	mov    $0xc8,%ebx
  8000e7:	eb 0a                	jmp    8000f3 <umain+0xc0>
			sys_yield();
  8000e9:	e8 f2 0b 00 00       	call   800ce0 <sys_yield>
		for (i=0; i<max; i++) {
  8000ee:	83 eb 01             	sub    $0x1,%ebx
  8000f1:	74 29                	je     80011c <umain+0xe9>
			if(pipeisclosed(p[0])){
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	ff 75 f0             	push   -0x10(%ebp)
  8000f9:	e8 68 21 00 00       	call   802266 <pipeisclosed>
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	85 c0                	test   %eax,%eax
  800103:	74 e4                	je     8000e9 <umain+0xb6>
				cprintf("RACE: pipe appears closed\n");
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	68 36 27 80 00       	push   $0x802736
  80010d:	e8 17 02 00 00       	call   800329 <cprintf>
				exit();
  800112:	e8 1d 01 00 00       	call   800234 <exit>
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	eb cd                	jmp    8000e9 <umain+0xb6>
		ipc_recv(0,0,0);
  80011c:	83 ec 04             	sub    $0x4,%esp
  80011f:	6a 00                	push   $0x0
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	e8 a5 10 00 00       	call   8011cf <ipc_recv>
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	e9 32 ff ff ff       	jmp    800064 <umain+0x31>
		dup(p[0], 10);
  800132:	83 ec 08             	sub    $0x8,%esp
  800135:	6a 0a                	push   $0xa
  800137:	ff 75 f0             	push   -0x10(%ebp)
  80013a:	e8 7a 13 00 00       	call   8014b9 <dup>
  80013f:	83 c4 10             	add    $0x10,%esp
	while (kid->env_status == ENV_RUNNABLE)
  800142:	8b 43 54             	mov    0x54(%ebx),%eax
  800145:	83 f8 02             	cmp    $0x2,%eax
  800148:	74 e8                	je     800132 <umain+0xff>

	cprintf("child done with loop\n");
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	68 67 27 80 00       	push   $0x802767
  800152:	e8 d2 01 00 00       	call   800329 <cprintf>
	if (pipeisclosed(p[0]))
  800157:	83 c4 04             	add    $0x4,%esp
  80015a:	ff 75 f0             	push   -0x10(%ebp)
  80015d:	e8 04 21 00 00       	call   802266 <pipeisclosed>
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	85 c0                	test   %eax,%eax
  800167:	75 48                	jne    8001b1 <umain+0x17e>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800169:	83 ec 08             	sub    $0x8,%esp
  80016c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80016f:	50                   	push   %eax
  800170:	ff 75 f0             	push   -0x10(%ebp)
  800173:	e8 c2 11 00 00       	call   80133a <fd_lookup>
  800178:	83 c4 10             	add    $0x10,%esp
  80017b:	85 c0                	test   %eax,%eax
  80017d:	78 46                	js     8001c5 <umain+0x192>
		panic("cannot look up p[0]: %e", r);
	va = fd2data(fd);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	ff 75 ec             	push   -0x14(%ebp)
  800185:	e8 49 11 00 00       	call   8012d3 <fd2data>
	if (pageref(va) != 3+1)
  80018a:	89 04 24             	mov    %eax,(%esp)
  80018d:	e8 19 19 00 00       	call   801aab <pageref>
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	83 f8 04             	cmp    $0x4,%eax
  800198:	74 3d                	je     8001d7 <umain+0x1a4>
		cprintf("\nchild detected race\n");
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	68 95 27 80 00       	push   $0x802795
  8001a2:	e8 82 01 00 00       	call   800329 <cprintf>
  8001a7:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("\nrace didn't happen\n", max);
}
  8001aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ad:	5b                   	pop    %ebx
  8001ae:	5e                   	pop    %esi
  8001af:	5d                   	pop    %ebp
  8001b0:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001b1:	83 ec 04             	sub    $0x4,%esp
  8001b4:	68 c0 27 80 00       	push   $0x8027c0
  8001b9:	6a 3a                	push   $0x3a
  8001bb:	68 22 27 80 00       	push   $0x802722
  8001c0:	e8 89 00 00 00       	call   80024e <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c5:	50                   	push   %eax
  8001c6:	68 7d 27 80 00       	push   $0x80277d
  8001cb:	6a 3c                	push   $0x3c
  8001cd:	68 22 27 80 00       	push   $0x802722
  8001d2:	e8 77 00 00 00       	call   80024e <_panic>
		cprintf("\nrace didn't happen\n", max);
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	68 c8 00 00 00       	push   $0xc8
  8001df:	68 ab 27 80 00       	push   $0x8027ab
  8001e4:	e8 40 01 00 00       	call   800329 <cprintf>
  8001e9:	83 c4 10             	add    $0x10,%esp
}
  8001ec:	eb bc                	jmp    8001aa <umain+0x177>

008001ee <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001f6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8001f9:	e8 c3 0a 00 00       	call   800cc1 <sys_getenvid>
  8001fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  800203:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800206:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020b:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800210:	85 db                	test   %ebx,%ebx
  800212:	7e 07                	jle    80021b <libmain+0x2d>
		binaryname = argv[0];
  800214:	8b 06                	mov    (%esi),%eax
  800216:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	e8 0e fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800225:	e8 0a 00 00 00       	call   800234 <exit>
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800230:	5b                   	pop    %ebx
  800231:	5e                   	pop    %esi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80023a:	e8 55 12 00 00       	call   801494 <close_all>
	sys_env_destroy(0);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	6a 00                	push   $0x0
  800244:	e8 37 0a 00 00       	call   800c80 <sys_env_destroy>
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800253:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800256:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80025c:	e8 60 0a 00 00       	call   800cc1 <sys_getenvid>
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	ff 75 0c             	push   0xc(%ebp)
  800267:	ff 75 08             	push   0x8(%ebp)
  80026a:	56                   	push   %esi
  80026b:	50                   	push   %eax
  80026c:	68 f4 27 80 00       	push   $0x8027f4
  800271:	e8 b3 00 00 00       	call   800329 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800276:	83 c4 18             	add    $0x18,%esp
  800279:	53                   	push   %ebx
  80027a:	ff 75 10             	push   0x10(%ebp)
  80027d:	e8 56 00 00 00       	call   8002d8 <vcprintf>
	cprintf("\n");
  800282:	c7 04 24 17 27 80 00 	movl   $0x802717,(%esp)
  800289:	e8 9b 00 00 00       	call   800329 <cprintf>
  80028e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800291:	cc                   	int3   
  800292:	eb fd                	jmp    800291 <_panic+0x43>

00800294 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	53                   	push   %ebx
  800298:	83 ec 04             	sub    $0x4,%esp
  80029b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80029e:	8b 13                	mov    (%ebx),%edx
  8002a0:	8d 42 01             	lea    0x1(%edx),%eax
  8002a3:	89 03                	mov    %eax,(%ebx)
  8002a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b1:	74 09                	je     8002bc <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	68 ff 00 00 00       	push   $0xff
  8002c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c7:	50                   	push   %eax
  8002c8:	e8 76 09 00 00       	call   800c43 <sys_cputs>
		b->idx = 0;
  8002cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d3:	83 c4 10             	add    $0x10,%esp
  8002d6:	eb db                	jmp    8002b3 <putch+0x1f>

008002d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e8:	00 00 00 
	b.cnt = 0;
  8002eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f5:	ff 75 0c             	push   0xc(%ebp)
  8002f8:	ff 75 08             	push   0x8(%ebp)
  8002fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	68 94 02 80 00       	push   $0x800294
  800307:	e8 14 01 00 00       	call   800420 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030c:	83 c4 08             	add    $0x8,%esp
  80030f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800315:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80031b:	50                   	push   %eax
  80031c:	e8 22 09 00 00       	call   800c43 <sys_cputs>

	return b.cnt;
}
  800321:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800327:	c9                   	leave  
  800328:	c3                   	ret    

00800329 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800332:	50                   	push   %eax
  800333:	ff 75 08             	push   0x8(%ebp)
  800336:	e8 9d ff ff ff       	call   8002d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033b:	c9                   	leave  
  80033c:	c3                   	ret    

0080033d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 1c             	sub    $0x1c,%esp
  800346:	89 c7                	mov    %eax,%edi
  800348:	89 d6                	mov    %edx,%esi
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800350:	89 d1                	mov    %edx,%ecx
  800352:	89 c2                	mov    %eax,%edx
  800354:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800357:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80035a:	8b 45 10             	mov    0x10(%ebp),%eax
  80035d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800360:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800363:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80036a:	39 c2                	cmp    %eax,%edx
  80036c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80036f:	72 3e                	jb     8003af <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800371:	83 ec 0c             	sub    $0xc,%esp
  800374:	ff 75 18             	push   0x18(%ebp)
  800377:	83 eb 01             	sub    $0x1,%ebx
  80037a:	53                   	push   %ebx
  80037b:	50                   	push   %eax
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	ff 75 e4             	push   -0x1c(%ebp)
  800382:	ff 75 e0             	push   -0x20(%ebp)
  800385:	ff 75 dc             	push   -0x24(%ebp)
  800388:	ff 75 d8             	push   -0x28(%ebp)
  80038b:	e8 20 21 00 00       	call   8024b0 <__udivdi3>
  800390:	83 c4 18             	add    $0x18,%esp
  800393:	52                   	push   %edx
  800394:	50                   	push   %eax
  800395:	89 f2                	mov    %esi,%edx
  800397:	89 f8                	mov    %edi,%eax
  800399:	e8 9f ff ff ff       	call   80033d <printnum>
  80039e:	83 c4 20             	add    $0x20,%esp
  8003a1:	eb 13                	jmp    8003b6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	56                   	push   %esi
  8003a7:	ff 75 18             	push   0x18(%ebp)
  8003aa:	ff d7                	call   *%edi
  8003ac:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003af:	83 eb 01             	sub    $0x1,%ebx
  8003b2:	85 db                	test   %ebx,%ebx
  8003b4:	7f ed                	jg     8003a3 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	56                   	push   %esi
  8003ba:	83 ec 04             	sub    $0x4,%esp
  8003bd:	ff 75 e4             	push   -0x1c(%ebp)
  8003c0:	ff 75 e0             	push   -0x20(%ebp)
  8003c3:	ff 75 dc             	push   -0x24(%ebp)
  8003c6:	ff 75 d8             	push   -0x28(%ebp)
  8003c9:	e8 02 22 00 00       	call   8025d0 <__umoddi3>
  8003ce:	83 c4 14             	add    $0x14,%esp
  8003d1:	0f be 80 17 28 80 00 	movsbl 0x802817(%eax),%eax
  8003d8:	50                   	push   %eax
  8003d9:	ff d7                	call   *%edi
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5f                   	pop    %edi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f5:	73 0a                	jae    800401 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fa:	89 08                	mov    %ecx,(%eax)
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ff:	88 02                	mov    %al,(%edx)
}
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <printfmt>:
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800409:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040c:	50                   	push   %eax
  80040d:	ff 75 10             	push   0x10(%ebp)
  800410:	ff 75 0c             	push   0xc(%ebp)
  800413:	ff 75 08             	push   0x8(%ebp)
  800416:	e8 05 00 00 00       	call   800420 <vprintfmt>
}
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <vprintfmt>:
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	57                   	push   %edi
  800424:	56                   	push   %esi
  800425:	53                   	push   %ebx
  800426:	83 ec 3c             	sub    $0x3c,%esp
  800429:	8b 75 08             	mov    0x8(%ebp),%esi
  80042c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80042f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800432:	eb 0a                	jmp    80043e <vprintfmt+0x1e>
			putch(ch, putdat);
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	50                   	push   %eax
  800439:	ff d6                	call   *%esi
  80043b:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80043e:	83 c7 01             	add    $0x1,%edi
  800441:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800445:	83 f8 25             	cmp    $0x25,%eax
  800448:	74 0c                	je     800456 <vprintfmt+0x36>
			if (ch == '\0')
  80044a:	85 c0                	test   %eax,%eax
  80044c:	75 e6                	jne    800434 <vprintfmt+0x14>
}
  80044e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800451:	5b                   	pop    %ebx
  800452:	5e                   	pop    %esi
  800453:	5f                   	pop    %edi
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    
		padc = ' ';
  800456:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80045a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800461:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800468:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80046f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8d 47 01             	lea    0x1(%edi),%eax
  800477:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80047a:	0f b6 17             	movzbl (%edi),%edx
  80047d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800480:	3c 55                	cmp    $0x55,%al
  800482:	0f 87 bb 03 00 00    	ja     800843 <vprintfmt+0x423>
  800488:	0f b6 c0             	movzbl %al,%eax
  80048b:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800495:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800499:	eb d9                	jmp    800474 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004a2:	eb d0                	jmp    800474 <vprintfmt+0x54>
  8004a4:	0f b6 d2             	movzbl %dl,%edx
  8004a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004b2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004b9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004bc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004bf:	83 f9 09             	cmp    $0x9,%ecx
  8004c2:	77 55                	ja     800519 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8004c4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004c7:	eb e9                	jmp    8004b2 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8b 00                	mov    (%eax),%eax
  8004ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 40 04             	lea    0x4(%eax),%eax
  8004d7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e1:	79 91                	jns    800474 <vprintfmt+0x54>
				width = precision, precision = -1;
  8004e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004f0:	eb 82                	jmp    800474 <vprintfmt+0x54>
  8004f2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f5:	85 d2                	test   %edx,%edx
  8004f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fc:	0f 49 c2             	cmovns %edx,%eax
  8004ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800505:	e9 6a ff ff ff       	jmp    800474 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80050d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800514:	e9 5b ff ff ff       	jmp    800474 <vprintfmt+0x54>
  800519:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80051c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051f:	eb bc                	jmp    8004dd <vprintfmt+0xbd>
			lflag++;
  800521:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800527:	e9 48 ff ff ff       	jmp    800474 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 78 04             	lea    0x4(%eax),%edi
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	ff 30                	push   (%eax)
  800538:	ff d6                	call   *%esi
			break;
  80053a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80053d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800540:	e9 9d 02 00 00       	jmp    8007e2 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 78 04             	lea    0x4(%eax),%edi
  80054b:	8b 10                	mov    (%eax),%edx
  80054d:	89 d0                	mov    %edx,%eax
  80054f:	f7 d8                	neg    %eax
  800551:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800554:	83 f8 0f             	cmp    $0xf,%eax
  800557:	7f 23                	jg     80057c <vprintfmt+0x15c>
  800559:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800560:	85 d2                	test   %edx,%edx
  800562:	74 18                	je     80057c <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800564:	52                   	push   %edx
  800565:	68 e1 2c 80 00       	push   $0x802ce1
  80056a:	53                   	push   %ebx
  80056b:	56                   	push   %esi
  80056c:	e8 92 fe ff ff       	call   800403 <printfmt>
  800571:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800574:	89 7d 14             	mov    %edi,0x14(%ebp)
  800577:	e9 66 02 00 00       	jmp    8007e2 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80057c:	50                   	push   %eax
  80057d:	68 2f 28 80 00       	push   $0x80282f
  800582:	53                   	push   %ebx
  800583:	56                   	push   %esi
  800584:	e8 7a fe ff ff       	call   800403 <printfmt>
  800589:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80058c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80058f:	e9 4e 02 00 00       	jmp    8007e2 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	83 c0 04             	add    $0x4,%eax
  80059a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	b8 28 28 80 00       	mov    $0x802828,%eax
  8005a9:	0f 45 c2             	cmovne %edx,%eax
  8005ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b3:	7e 06                	jle    8005bb <vprintfmt+0x19b>
  8005b5:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005b9:	75 0d                	jne    8005c8 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005be:	89 c7                	mov    %eax,%edi
  8005c0:	03 45 e0             	add    -0x20(%ebp),%eax
  8005c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c6:	eb 55                	jmp    80061d <vprintfmt+0x1fd>
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	ff 75 d8             	push   -0x28(%ebp)
  8005ce:	ff 75 cc             	push   -0x34(%ebp)
  8005d1:	e8 0a 03 00 00       	call   8008e0 <strnlen>
  8005d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d9:	29 c1                	sub    %eax,%ecx
  8005db:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8005e3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ea:	eb 0f                	jmp    8005fb <vprintfmt+0x1db>
					putch(padc, putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	ff 75 e0             	push   -0x20(%ebp)
  8005f3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f5:	83 ef 01             	sub    $0x1,%edi
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	85 ff                	test   %edi,%edi
  8005fd:	7f ed                	jg     8005ec <vprintfmt+0x1cc>
  8005ff:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800602:	85 d2                	test   %edx,%edx
  800604:	b8 00 00 00 00       	mov    $0x0,%eax
  800609:	0f 49 c2             	cmovns %edx,%eax
  80060c:	29 c2                	sub    %eax,%edx
  80060e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800611:	eb a8                	jmp    8005bb <vprintfmt+0x19b>
					putch(ch, putdat);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	52                   	push   %edx
  800618:	ff d6                	call   *%esi
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800620:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800622:	83 c7 01             	add    $0x1,%edi
  800625:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800629:	0f be d0             	movsbl %al,%edx
  80062c:	85 d2                	test   %edx,%edx
  80062e:	74 4b                	je     80067b <vprintfmt+0x25b>
  800630:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800634:	78 06                	js     80063c <vprintfmt+0x21c>
  800636:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80063a:	78 1e                	js     80065a <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80063c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800640:	74 d1                	je     800613 <vprintfmt+0x1f3>
  800642:	0f be c0             	movsbl %al,%eax
  800645:	83 e8 20             	sub    $0x20,%eax
  800648:	83 f8 5e             	cmp    $0x5e,%eax
  80064b:	76 c6                	jbe    800613 <vprintfmt+0x1f3>
					putch('?', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 3f                	push   $0x3f
  800653:	ff d6                	call   *%esi
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	eb c3                	jmp    80061d <vprintfmt+0x1fd>
  80065a:	89 cf                	mov    %ecx,%edi
  80065c:	eb 0e                	jmp    80066c <vprintfmt+0x24c>
				putch(' ', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 20                	push   $0x20
  800664:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800666:	83 ef 01             	sub    $0x1,%edi
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	85 ff                	test   %edi,%edi
  80066e:	7f ee                	jg     80065e <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800670:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
  800676:	e9 67 01 00 00       	jmp    8007e2 <vprintfmt+0x3c2>
  80067b:	89 cf                	mov    %ecx,%edi
  80067d:	eb ed                	jmp    80066c <vprintfmt+0x24c>
	if (lflag >= 2)
  80067f:	83 f9 01             	cmp    $0x1,%ecx
  800682:	7f 1b                	jg     80069f <vprintfmt+0x27f>
	else if (lflag)
  800684:	85 c9                	test   %ecx,%ecx
  800686:	74 63                	je     8006eb <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800690:	99                   	cltd   
  800691:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 40 04             	lea    0x4(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)
  80069d:	eb 17                	jmp    8006b6 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 50 04             	mov    0x4(%eax),%edx
  8006a5:	8b 00                	mov    (%eax),%eax
  8006a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 40 08             	lea    0x8(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006bc:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8006c1:	85 c9                	test   %ecx,%ecx
  8006c3:	0f 89 ff 00 00 00    	jns    8007c8 <vprintfmt+0x3a8>
				putch('-', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 2d                	push   $0x2d
  8006cf:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006d4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006d7:	f7 da                	neg    %edx
  8006d9:	83 d1 00             	adc    $0x0,%ecx
  8006dc:	f7 d9                	neg    %ecx
  8006de:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006e1:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006e6:	e9 dd 00 00 00       	jmp    8007c8 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8b 00                	mov    (%eax),%eax
  8006f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f3:	99                   	cltd   
  8006f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 40 04             	lea    0x4(%eax),%eax
  8006fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800700:	eb b4                	jmp    8006b6 <vprintfmt+0x296>
	if (lflag >= 2)
  800702:	83 f9 01             	cmp    $0x1,%ecx
  800705:	7f 1e                	jg     800725 <vprintfmt+0x305>
	else if (lflag)
  800707:	85 c9                	test   %ecx,%ecx
  800709:	74 32                	je     80073d <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	8b 10                	mov    (%eax),%edx
  800710:	b9 00 00 00 00       	mov    $0x0,%ecx
  800715:	8d 40 04             	lea    0x4(%eax),%eax
  800718:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80071b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800720:	e9 a3 00 00 00       	jmp    8007c8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	8b 48 04             	mov    0x4(%eax),%ecx
  80072d:	8d 40 08             	lea    0x8(%eax),%eax
  800730:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800733:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800738:	e9 8b 00 00 00       	jmp    8007c8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 10                	mov    (%eax),%edx
  800742:	b9 00 00 00 00       	mov    $0x0,%ecx
  800747:	8d 40 04             	lea    0x4(%eax),%eax
  80074a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80074d:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800752:	eb 74                	jmp    8007c8 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800754:	83 f9 01             	cmp    $0x1,%ecx
  800757:	7f 1b                	jg     800774 <vprintfmt+0x354>
	else if (lflag)
  800759:	85 c9                	test   %ecx,%ecx
  80075b:	74 2c                	je     800789 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8b 10                	mov    (%eax),%edx
  800762:	b9 00 00 00 00       	mov    $0x0,%ecx
  800767:	8d 40 04             	lea    0x4(%eax),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80076d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800772:	eb 54                	jmp    8007c8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 10                	mov    (%eax),%edx
  800779:	8b 48 04             	mov    0x4(%eax),%ecx
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800782:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800787:	eb 3f                	jmp    8007c8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8b 10                	mov    (%eax),%edx
  80078e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800793:	8d 40 04             	lea    0x4(%eax),%eax
  800796:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800799:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80079e:	eb 28                	jmp    8007c8 <vprintfmt+0x3a8>
			putch('0', putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	53                   	push   %ebx
  8007a4:	6a 30                	push   $0x30
  8007a6:	ff d6                	call   *%esi
			putch('x', putdat);
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	53                   	push   %ebx
  8007ac:	6a 78                	push   $0x78
  8007ae:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8b 10                	mov    (%eax),%edx
  8007b5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007ba:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007bd:	8d 40 04             	lea    0x4(%eax),%eax
  8007c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c3:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007c8:	83 ec 0c             	sub    $0xc,%esp
  8007cb:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	ff 75 e0             	push   -0x20(%ebp)
  8007d3:	57                   	push   %edi
  8007d4:	51                   	push   %ecx
  8007d5:	52                   	push   %edx
  8007d6:	89 da                	mov    %ebx,%edx
  8007d8:	89 f0                	mov    %esi,%eax
  8007da:	e8 5e fb ff ff       	call   80033d <printnum>
			break;
  8007df:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007e5:	e9 54 fc ff ff       	jmp    80043e <vprintfmt+0x1e>
	if (lflag >= 2)
  8007ea:	83 f9 01             	cmp    $0x1,%ecx
  8007ed:	7f 1b                	jg     80080a <vprintfmt+0x3ea>
	else if (lflag)
  8007ef:	85 c9                	test   %ecx,%ecx
  8007f1:	74 2c                	je     80081f <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8b 10                	mov    (%eax),%edx
  8007f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fd:	8d 40 04             	lea    0x4(%eax),%eax
  800800:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800803:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800808:	eb be                	jmp    8007c8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80080a:	8b 45 14             	mov    0x14(%ebp),%eax
  80080d:	8b 10                	mov    (%eax),%edx
  80080f:	8b 48 04             	mov    0x4(%eax),%ecx
  800812:	8d 40 08             	lea    0x8(%eax),%eax
  800815:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800818:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80081d:	eb a9                	jmp    8007c8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8b 10                	mov    (%eax),%edx
  800824:	b9 00 00 00 00       	mov    $0x0,%ecx
  800829:	8d 40 04             	lea    0x4(%eax),%eax
  80082c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800834:	eb 92                	jmp    8007c8 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800836:	83 ec 08             	sub    $0x8,%esp
  800839:	53                   	push   %ebx
  80083a:	6a 25                	push   $0x25
  80083c:	ff d6                	call   *%esi
			break;
  80083e:	83 c4 10             	add    $0x10,%esp
  800841:	eb 9f                	jmp    8007e2 <vprintfmt+0x3c2>
			putch('%', putdat);
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	53                   	push   %ebx
  800847:	6a 25                	push   $0x25
  800849:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80084b:	83 c4 10             	add    $0x10,%esp
  80084e:	89 f8                	mov    %edi,%eax
  800850:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800854:	74 05                	je     80085b <vprintfmt+0x43b>
  800856:	83 e8 01             	sub    $0x1,%eax
  800859:	eb f5                	jmp    800850 <vprintfmt+0x430>
  80085b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80085e:	eb 82                	jmp    8007e2 <vprintfmt+0x3c2>

00800860 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 18             	sub    $0x18,%esp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800873:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800876:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087d:	85 c0                	test   %eax,%eax
  80087f:	74 26                	je     8008a7 <vsnprintf+0x47>
  800881:	85 d2                	test   %edx,%edx
  800883:	7e 22                	jle    8008a7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800885:	ff 75 14             	push   0x14(%ebp)
  800888:	ff 75 10             	push   0x10(%ebp)
  80088b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088e:	50                   	push   %eax
  80088f:	68 e6 03 80 00       	push   $0x8003e6
  800894:	e8 87 fb ff ff       	call   800420 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800899:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a2:	83 c4 10             	add    $0x10,%esp
}
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    
		return -E_INVAL;
  8008a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ac:	eb f7                	jmp    8008a5 <vsnprintf+0x45>

008008ae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b7:	50                   	push   %eax
  8008b8:	ff 75 10             	push   0x10(%ebp)
  8008bb:	ff 75 0c             	push   0xc(%ebp)
  8008be:	ff 75 08             	push   0x8(%ebp)
  8008c1:	e8 9a ff ff ff       	call   800860 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d3:	eb 03                	jmp    8008d8 <strlen+0x10>
		n++;
  8008d5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008d8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008dc:	75 f7                	jne    8008d5 <strlen+0xd>
	return n;
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ee:	eb 03                	jmp    8008f3 <strnlen+0x13>
		n++;
  8008f0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f3:	39 d0                	cmp    %edx,%eax
  8008f5:	74 08                	je     8008ff <strnlen+0x1f>
  8008f7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008fb:	75 f3                	jne    8008f0 <strnlen+0x10>
  8008fd:	89 c2                	mov    %eax,%edx
	return n;
}
  8008ff:	89 d0                	mov    %edx,%eax
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
  800912:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800916:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	84 d2                	test   %dl,%dl
  80091e:	75 f2                	jne    800912 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800920:	89 c8                	mov    %ecx,%eax
  800922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	83 ec 10             	sub    $0x10,%esp
  80092e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800931:	53                   	push   %ebx
  800932:	e8 91 ff ff ff       	call   8008c8 <strlen>
  800937:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80093a:	ff 75 0c             	push   0xc(%ebp)
  80093d:	01 d8                	add    %ebx,%eax
  80093f:	50                   	push   %eax
  800940:	e8 be ff ff ff       	call   800903 <strcpy>
	return dst;
}
  800945:	89 d8                	mov    %ebx,%eax
  800947:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80094a:	c9                   	leave  
  80094b:	c3                   	ret    

0080094c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 75 08             	mov    0x8(%ebp),%esi
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
  800957:	89 f3                	mov    %esi,%ebx
  800959:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095c:	89 f0                	mov    %esi,%eax
  80095e:	eb 0f                	jmp    80096f <strncpy+0x23>
		*dst++ = *src;
  800960:	83 c0 01             	add    $0x1,%eax
  800963:	0f b6 0a             	movzbl (%edx),%ecx
  800966:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800969:	80 f9 01             	cmp    $0x1,%cl
  80096c:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80096f:	39 d8                	cmp    %ebx,%eax
  800971:	75 ed                	jne    800960 <strncpy+0x14>
	}
	return ret;
}
  800973:	89 f0                	mov    %esi,%eax
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	56                   	push   %esi
  80097d:	53                   	push   %ebx
  80097e:	8b 75 08             	mov    0x8(%ebp),%esi
  800981:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800984:	8b 55 10             	mov    0x10(%ebp),%edx
  800987:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800989:	85 d2                	test   %edx,%edx
  80098b:	74 21                	je     8009ae <strlcpy+0x35>
  80098d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800991:	89 f2                	mov    %esi,%edx
  800993:	eb 09                	jmp    80099e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800995:	83 c1 01             	add    $0x1,%ecx
  800998:	83 c2 01             	add    $0x1,%edx
  80099b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80099e:	39 c2                	cmp    %eax,%edx
  8009a0:	74 09                	je     8009ab <strlcpy+0x32>
  8009a2:	0f b6 19             	movzbl (%ecx),%ebx
  8009a5:	84 db                	test   %bl,%bl
  8009a7:	75 ec                	jne    800995 <strlcpy+0x1c>
  8009a9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ae:	29 f0                	sub    %esi,%eax
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009bd:	eb 06                	jmp    8009c5 <strcmp+0x11>
		p++, q++;
  8009bf:	83 c1 01             	add    $0x1,%ecx
  8009c2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009c5:	0f b6 01             	movzbl (%ecx),%eax
  8009c8:	84 c0                	test   %al,%al
  8009ca:	74 04                	je     8009d0 <strcmp+0x1c>
  8009cc:	3a 02                	cmp    (%edx),%al
  8009ce:	74 ef                	je     8009bf <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d0:	0f b6 c0             	movzbl %al,%eax
  8009d3:	0f b6 12             	movzbl (%edx),%edx
  8009d6:	29 d0                	sub    %edx,%eax
}
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e4:	89 c3                	mov    %eax,%ebx
  8009e6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e9:	eb 06                	jmp    8009f1 <strncmp+0x17>
		n--, p++, q++;
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009f1:	39 d8                	cmp    %ebx,%eax
  8009f3:	74 18                	je     800a0d <strncmp+0x33>
  8009f5:	0f b6 08             	movzbl (%eax),%ecx
  8009f8:	84 c9                	test   %cl,%cl
  8009fa:	74 04                	je     800a00 <strncmp+0x26>
  8009fc:	3a 0a                	cmp    (%edx),%cl
  8009fe:	74 eb                	je     8009eb <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a00:	0f b6 00             	movzbl (%eax),%eax
  800a03:	0f b6 12             	movzbl (%edx),%edx
  800a06:	29 d0                	sub    %edx,%eax
}
  800a08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    
		return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	eb f4                	jmp    800a08 <strncmp+0x2e>

00800a14 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1e:	eb 03                	jmp    800a23 <strchr+0xf>
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	0f b6 10             	movzbl (%eax),%edx
  800a26:	84 d2                	test   %dl,%dl
  800a28:	74 06                	je     800a30 <strchr+0x1c>
		if (*s == c)
  800a2a:	38 ca                	cmp    %cl,%dl
  800a2c:	75 f2                	jne    800a20 <strchr+0xc>
  800a2e:	eb 05                	jmp    800a35 <strchr+0x21>
			return (char *) s;
	return 0;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a41:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a44:	38 ca                	cmp    %cl,%dl
  800a46:	74 09                	je     800a51 <strfind+0x1a>
  800a48:	84 d2                	test   %dl,%dl
  800a4a:	74 05                	je     800a51 <strfind+0x1a>
	for (; *s; s++)
  800a4c:	83 c0 01             	add    $0x1,%eax
  800a4f:	eb f0                	jmp    800a41 <strfind+0xa>
			break;
	return (char *) s;
}
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	57                   	push   %edi
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a5c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a5f:	85 c9                	test   %ecx,%ecx
  800a61:	74 2f                	je     800a92 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a63:	89 f8                	mov    %edi,%eax
  800a65:	09 c8                	or     %ecx,%eax
  800a67:	a8 03                	test   $0x3,%al
  800a69:	75 21                	jne    800a8c <memset+0x39>
		c &= 0xFF;
  800a6b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6f:	89 d0                	mov    %edx,%eax
  800a71:	c1 e0 08             	shl    $0x8,%eax
  800a74:	89 d3                	mov    %edx,%ebx
  800a76:	c1 e3 18             	shl    $0x18,%ebx
  800a79:	89 d6                	mov    %edx,%esi
  800a7b:	c1 e6 10             	shl    $0x10,%esi
  800a7e:	09 f3                	or     %esi,%ebx
  800a80:	09 da                	or     %ebx,%edx
  800a82:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a84:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a87:	fc                   	cld    
  800a88:	f3 ab                	rep stos %eax,%es:(%edi)
  800a8a:	eb 06                	jmp    800a92 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8f:	fc                   	cld    
  800a90:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a92:	89 f8                	mov    %edi,%eax
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa7:	39 c6                	cmp    %eax,%esi
  800aa9:	73 32                	jae    800add <memmove+0x44>
  800aab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aae:	39 c2                	cmp    %eax,%edx
  800ab0:	76 2b                	jbe    800add <memmove+0x44>
		s += n;
		d += n;
  800ab2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab5:	89 d6                	mov    %edx,%esi
  800ab7:	09 fe                	or     %edi,%esi
  800ab9:	09 ce                	or     %ecx,%esi
  800abb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ac1:	75 0e                	jne    800ad1 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac3:	83 ef 04             	sub    $0x4,%edi
  800ac6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800acc:	fd                   	std    
  800acd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acf:	eb 09                	jmp    800ada <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ad1:	83 ef 01             	sub    $0x1,%edi
  800ad4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ad7:	fd                   	std    
  800ad8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ada:	fc                   	cld    
  800adb:	eb 1a                	jmp    800af7 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800add:	89 f2                	mov    %esi,%edx
  800adf:	09 c2                	or     %eax,%edx
  800ae1:	09 ca                	or     %ecx,%edx
  800ae3:	f6 c2 03             	test   $0x3,%dl
  800ae6:	75 0a                	jne    800af2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	fc                   	cld    
  800aee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af0:	eb 05                	jmp    800af7 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800af2:	89 c7                	mov    %eax,%edi
  800af4:	fc                   	cld    
  800af5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b01:	ff 75 10             	push   0x10(%ebp)
  800b04:	ff 75 0c             	push   0xc(%ebp)
  800b07:	ff 75 08             	push   0x8(%ebp)
  800b0a:	e8 8a ff ff ff       	call   800a99 <memmove>
}
  800b0f:	c9                   	leave  
  800b10:	c3                   	ret    

00800b11 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
  800b16:	8b 45 08             	mov    0x8(%ebp),%eax
  800b19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1c:	89 c6                	mov    %eax,%esi
  800b1e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b21:	eb 06                	jmp    800b29 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b23:	83 c0 01             	add    $0x1,%eax
  800b26:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b29:	39 f0                	cmp    %esi,%eax
  800b2b:	74 14                	je     800b41 <memcmp+0x30>
		if (*s1 != *s2)
  800b2d:	0f b6 08             	movzbl (%eax),%ecx
  800b30:	0f b6 1a             	movzbl (%edx),%ebx
  800b33:	38 d9                	cmp    %bl,%cl
  800b35:	74 ec                	je     800b23 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b37:	0f b6 c1             	movzbl %cl,%eax
  800b3a:	0f b6 db             	movzbl %bl,%ebx
  800b3d:	29 d8                	sub    %ebx,%eax
  800b3f:	eb 05                	jmp    800b46 <memcmp+0x35>
	}

	return 0;
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b53:	89 c2                	mov    %eax,%edx
  800b55:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b58:	eb 03                	jmp    800b5d <memfind+0x13>
  800b5a:	83 c0 01             	add    $0x1,%eax
  800b5d:	39 d0                	cmp    %edx,%eax
  800b5f:	73 04                	jae    800b65 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b61:	38 08                	cmp    %cl,(%eax)
  800b63:	75 f5                	jne    800b5a <memfind+0x10>
			break;
	return (void *) s;
}
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b73:	eb 03                	jmp    800b78 <strtol+0x11>
		s++;
  800b75:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b78:	0f b6 02             	movzbl (%edx),%eax
  800b7b:	3c 20                	cmp    $0x20,%al
  800b7d:	74 f6                	je     800b75 <strtol+0xe>
  800b7f:	3c 09                	cmp    $0x9,%al
  800b81:	74 f2                	je     800b75 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b83:	3c 2b                	cmp    $0x2b,%al
  800b85:	74 2a                	je     800bb1 <strtol+0x4a>
	int neg = 0;
  800b87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b8c:	3c 2d                	cmp    $0x2d,%al
  800b8e:	74 2b                	je     800bbb <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b90:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b96:	75 0f                	jne    800ba7 <strtol+0x40>
  800b98:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9b:	74 28                	je     800bc5 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b9d:	85 db                	test   %ebx,%ebx
  800b9f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba4:	0f 44 d8             	cmove  %eax,%ebx
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800baf:	eb 46                	jmp    800bf7 <strtol+0x90>
		s++;
  800bb1:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bb4:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb9:	eb d5                	jmp    800b90 <strtol+0x29>
		s++, neg = 1;
  800bbb:	83 c2 01             	add    $0x1,%edx
  800bbe:	bf 01 00 00 00       	mov    $0x1,%edi
  800bc3:	eb cb                	jmp    800b90 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bc9:	74 0e                	je     800bd9 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bcb:	85 db                	test   %ebx,%ebx
  800bcd:	75 d8                	jne    800ba7 <strtol+0x40>
		s++, base = 8;
  800bcf:	83 c2 01             	add    $0x1,%edx
  800bd2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bd7:	eb ce                	jmp    800ba7 <strtol+0x40>
		s += 2, base = 16;
  800bd9:	83 c2 02             	add    $0x2,%edx
  800bdc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be1:	eb c4                	jmp    800ba7 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800be3:	0f be c0             	movsbl %al,%eax
  800be6:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bec:	7d 3a                	jge    800c28 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bee:	83 c2 01             	add    $0x1,%edx
  800bf1:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bf5:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bf7:	0f b6 02             	movzbl (%edx),%eax
  800bfa:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bfd:	89 f3                	mov    %esi,%ebx
  800bff:	80 fb 09             	cmp    $0x9,%bl
  800c02:	76 df                	jbe    800be3 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800c04:	8d 70 9f             	lea    -0x61(%eax),%esi
  800c07:	89 f3                	mov    %esi,%ebx
  800c09:	80 fb 19             	cmp    $0x19,%bl
  800c0c:	77 08                	ja     800c16 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c0e:	0f be c0             	movsbl %al,%eax
  800c11:	83 e8 57             	sub    $0x57,%eax
  800c14:	eb d3                	jmp    800be9 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c16:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c19:	89 f3                	mov    %esi,%ebx
  800c1b:	80 fb 19             	cmp    $0x19,%bl
  800c1e:	77 08                	ja     800c28 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c20:	0f be c0             	movsbl %al,%eax
  800c23:	83 e8 37             	sub    $0x37,%eax
  800c26:	eb c1                	jmp    800be9 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2c:	74 05                	je     800c33 <strtol+0xcc>
		*endptr = (char *) s;
  800c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c31:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c33:	89 c8                	mov    %ecx,%eax
  800c35:	f7 d8                	neg    %eax
  800c37:	85 ff                	test   %edi,%edi
  800c39:	0f 45 c8             	cmovne %eax,%ecx
}
  800c3c:	89 c8                	mov    %ecx,%eax
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c49:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	89 c3                	mov    %eax,%ebx
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	89 c6                	mov    %eax,%esi
  800c5a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c67:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c71:	89 d1                	mov    %edx,%ecx
  800c73:	89 d3                	mov    %edx,%ebx
  800c75:	89 d7                	mov    %edx,%edi
  800c77:	89 d6                	mov    %edx,%esi
  800c79:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	b8 03 00 00 00       	mov    $0x3,%eax
  800c96:	89 cb                	mov    %ecx,%ebx
  800c98:	89 cf                	mov    %ecx,%edi
  800c9a:	89 ce                	mov    %ecx,%esi
  800c9c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7f 08                	jg     800caa <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 03                	push   $0x3
  800cb0:	68 1f 2b 80 00       	push   $0x802b1f
  800cb5:	6a 2a                	push   $0x2a
  800cb7:	68 3c 2b 80 00       	push   $0x802b3c
  800cbc:	e8 8d f5 ff ff       	call   80024e <_panic>

00800cc1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccc:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd1:	89 d1                	mov    %edx,%ecx
  800cd3:	89 d3                	mov    %edx,%ebx
  800cd5:	89 d7                	mov    %edx,%edi
  800cd7:	89 d6                	mov    %edx,%esi
  800cd9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_yield>:

void
sys_yield(void)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ceb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf0:	89 d1                	mov    %edx,%ecx
  800cf2:	89 d3                	mov    %edx,%ebx
  800cf4:	89 d7                	mov    %edx,%edi
  800cf6:	89 d6                	mov    %edx,%esi
  800cf8:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d08:	be 00 00 00 00       	mov    $0x0,%esi
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	b8 04 00 00 00       	mov    $0x4,%eax
  800d18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1b:	89 f7                	mov    %esi,%edi
  800d1d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7f 08                	jg     800d2b <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	6a 04                	push   $0x4
  800d31:	68 1f 2b 80 00       	push   $0x802b1f
  800d36:	6a 2a                	push   $0x2a
  800d38:	68 3c 2b 80 00       	push   $0x802b3c
  800d3d:	e8 0c f5 ff ff       	call   80024e <_panic>

00800d42 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	b8 05 00 00 00       	mov    $0x5,%eax
  800d56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d59:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7f 08                	jg     800d6d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 05                	push   $0x5
  800d73:	68 1f 2b 80 00       	push   $0x802b1f
  800d78:	6a 2a                	push   $0x2a
  800d7a:	68 3c 2b 80 00       	push   $0x802b3c
  800d7f:	e8 ca f4 ff ff       	call   80024e <_panic>

00800d84 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9d:	89 df                	mov    %ebx,%edi
  800d9f:	89 de                	mov    %ebx,%esi
  800da1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7f 08                	jg     800daf <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	50                   	push   %eax
  800db3:	6a 06                	push   $0x6
  800db5:	68 1f 2b 80 00       	push   $0x802b1f
  800dba:	6a 2a                	push   $0x2a
  800dbc:	68 3c 2b 80 00       	push   $0x802b3c
  800dc1:	e8 88 f4 ff ff       	call   80024e <_panic>

00800dc6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	b8 08 00 00 00       	mov    $0x8,%eax
  800ddf:	89 df                	mov    %ebx,%edi
  800de1:	89 de                	mov    %ebx,%esi
  800de3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de5:	85 c0                	test   %eax,%eax
  800de7:	7f 08                	jg     800df1 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	50                   	push   %eax
  800df5:	6a 08                	push   $0x8
  800df7:	68 1f 2b 80 00       	push   $0x802b1f
  800dfc:	6a 2a                	push   $0x2a
  800dfe:	68 3c 2b 80 00       	push   $0x802b3c
  800e03:	e8 46 f4 ff ff       	call   80024e <_panic>

00800e08 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e21:	89 df                	mov    %ebx,%edi
  800e23:	89 de                	mov    %ebx,%esi
  800e25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e27:	85 c0                	test   %eax,%eax
  800e29:	7f 08                	jg     800e33 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	50                   	push   %eax
  800e37:	6a 09                	push   $0x9
  800e39:	68 1f 2b 80 00       	push   $0x802b1f
  800e3e:	6a 2a                	push   $0x2a
  800e40:	68 3c 2b 80 00       	push   $0x802b3c
  800e45:	e8 04 f4 ff ff       	call   80024e <_panic>

00800e4a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e63:	89 df                	mov    %ebx,%edi
  800e65:	89 de                	mov    %ebx,%esi
  800e67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	7f 08                	jg     800e75 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	50                   	push   %eax
  800e79:	6a 0a                	push   $0xa
  800e7b:	68 1f 2b 80 00       	push   $0x802b1f
  800e80:	6a 2a                	push   $0x2a
  800e82:	68 3c 2b 80 00       	push   $0x802b3c
  800e87:	e8 c2 f3 ff ff       	call   80024e <_panic>

00800e8c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e9d:	be 00 00 00 00       	mov    $0x0,%esi
  800ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	57                   	push   %edi
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ec5:	89 cb                	mov    %ecx,%ebx
  800ec7:	89 cf                	mov    %ecx,%edi
  800ec9:	89 ce                	mov    %ecx,%esi
  800ecb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	7f 08                	jg     800ed9 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed9:	83 ec 0c             	sub    $0xc,%esp
  800edc:	50                   	push   %eax
  800edd:	6a 0d                	push   $0xd
  800edf:	68 1f 2b 80 00       	push   $0x802b1f
  800ee4:	6a 2a                	push   $0x2a
  800ee6:	68 3c 2b 80 00       	push   $0x802b3c
  800eeb:	e8 5e f3 ff ff       	call   80024e <_panic>

00800ef0 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ef6:	ba 00 00 00 00       	mov    $0x0,%edx
  800efb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f00:	89 d1                	mov    %edx,%ecx
  800f02:	89 d3                	mov    %edx,%ebx
  800f04:	89 d7                	mov    %edx,%edi
  800f06:	89 d6                	mov    %edx,%esi
  800f08:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
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
  800f20:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f25:	89 df                	mov    %ebx,%edi
  800f27:	89 de                	mov    %ebx,%esi
  800f29:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f41:	b8 10 00 00 00       	mov    $0x10,%eax
  800f46:	89 df                	mov    %ebx,%edi
  800f48:	89 de                	mov    %ebx,%esi
  800f4a:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5f                   	pop    %edi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	56                   	push   %esi
  800f55:	53                   	push   %ebx
  800f56:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f59:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f5b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f5f:	0f 84 8e 00 00 00    	je     800ff3 <pgfault+0xa2>
  800f65:	89 f0                	mov    %esi,%eax
  800f67:	c1 e8 0c             	shr    $0xc,%eax
  800f6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f71:	f6 c4 08             	test   $0x8,%ah
  800f74:	74 7d                	je     800ff3 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800f76:	e8 46 fd ff ff       	call   800cc1 <sys_getenvid>
  800f7b:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800f7d:	83 ec 04             	sub    $0x4,%esp
  800f80:	6a 07                	push   $0x7
  800f82:	68 00 f0 7f 00       	push   $0x7ff000
  800f87:	50                   	push   %eax
  800f88:	e8 72 fd ff ff       	call   800cff <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 73                	js     801007 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f94:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	68 00 10 00 00       	push   $0x1000
  800fa2:	56                   	push   %esi
  800fa3:	68 00 f0 7f 00       	push   $0x7ff000
  800fa8:	e8 ec fa ff ff       	call   800a99 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800fad:	83 c4 08             	add    $0x8,%esp
  800fb0:	56                   	push   %esi
  800fb1:	53                   	push   %ebx
  800fb2:	e8 cd fd ff ff       	call   800d84 <sys_page_unmap>
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	78 5b                	js     801019 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	6a 07                	push   $0x7
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
  800fc5:	68 00 f0 7f 00       	push   $0x7ff000
  800fca:	53                   	push   %ebx
  800fcb:	e8 72 fd ff ff       	call   800d42 <sys_page_map>
  800fd0:	83 c4 20             	add    $0x20,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 54                	js     80102b <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800fd7:	83 ec 08             	sub    $0x8,%esp
  800fda:	68 00 f0 7f 00       	push   $0x7ff000
  800fdf:	53                   	push   %ebx
  800fe0:	e8 9f fd ff ff       	call   800d84 <sys_page_unmap>
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 51                	js     80103d <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800fec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	68 4c 2b 80 00       	push   $0x802b4c
  800ffb:	6a 1d                	push   $0x1d
  800ffd:	68 c8 2b 80 00       	push   $0x802bc8
  801002:	e8 47 f2 ff ff       	call   80024e <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801007:	50                   	push   %eax
  801008:	68 84 2b 80 00       	push   $0x802b84
  80100d:	6a 29                	push   $0x29
  80100f:	68 c8 2b 80 00       	push   $0x802bc8
  801014:	e8 35 f2 ff ff       	call   80024e <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801019:	50                   	push   %eax
  80101a:	68 a8 2b 80 00       	push   $0x802ba8
  80101f:	6a 2e                	push   $0x2e
  801021:	68 c8 2b 80 00       	push   $0x802bc8
  801026:	e8 23 f2 ff ff       	call   80024e <_panic>
		panic("pgfault: page map failed (%e)", r);
  80102b:	50                   	push   %eax
  80102c:	68 d3 2b 80 00       	push   $0x802bd3
  801031:	6a 30                	push   $0x30
  801033:	68 c8 2b 80 00       	push   $0x802bc8
  801038:	e8 11 f2 ff ff       	call   80024e <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  80103d:	50                   	push   %eax
  80103e:	68 a8 2b 80 00       	push   $0x802ba8
  801043:	6a 32                	push   $0x32
  801045:	68 c8 2b 80 00       	push   $0x802bc8
  80104a:	e8 ff f1 ff ff       	call   80024e <_panic>

0080104f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801058:	68 51 0f 80 00       	push   $0x800f51
  80105d:	e8 ab 13 00 00       	call   80240d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801062:	b8 07 00 00 00       	mov    $0x7,%eax
  801067:	cd 30                	int    $0x30
  801069:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	85 c0                	test   %eax,%eax
  801071:	78 2d                	js     8010a0 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801073:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801078:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80107c:	75 73                	jne    8010f1 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  80107e:	e8 3e fc ff ff       	call   800cc1 <sys_getenvid>
  801083:	25 ff 03 00 00       	and    $0x3ff,%eax
  801088:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80108b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801090:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  801095:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5f                   	pop    %edi
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  8010a0:	50                   	push   %eax
  8010a1:	68 f1 2b 80 00       	push   $0x802bf1
  8010a6:	6a 78                	push   $0x78
  8010a8:	68 c8 2b 80 00       	push   $0x802bc8
  8010ad:	e8 9c f1 ff ff       	call   80024e <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  8010b2:	83 ec 0c             	sub    $0xc,%esp
  8010b5:	ff 75 e4             	push   -0x1c(%ebp)
  8010b8:	57                   	push   %edi
  8010b9:	ff 75 dc             	push   -0x24(%ebp)
  8010bc:	57                   	push   %edi
  8010bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8010c0:	56                   	push   %esi
  8010c1:	e8 7c fc ff ff       	call   800d42 <sys_page_map>
	if(r<0) return r;
  8010c6:	83 c4 20             	add    $0x20,%esp
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	78 cb                	js     801098 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	ff 75 e4             	push   -0x1c(%ebp)
  8010d3:	57                   	push   %edi
  8010d4:	56                   	push   %esi
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	e8 66 fc ff ff       	call   800d42 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8010dc:	83 c4 20             	add    $0x20,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	78 76                	js     801159 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8010e3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010e9:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010ef:	74 75                	je     801166 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8010f1:	89 d8                	mov    %ebx,%eax
  8010f3:	c1 e8 16             	shr    $0x16,%eax
  8010f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fd:	a8 01                	test   $0x1,%al
  8010ff:	74 e2                	je     8010e3 <fork+0x94>
  801101:	89 de                	mov    %ebx,%esi
  801103:	c1 ee 0c             	shr    $0xc,%esi
  801106:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80110d:	a8 01                	test   $0x1,%al
  80110f:	74 d2                	je     8010e3 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801111:	e8 ab fb ff ff       	call   800cc1 <sys_getenvid>
  801116:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801119:	89 f7                	mov    %esi,%edi
  80111b:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  80111e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801125:	89 c1                	mov    %eax,%ecx
  801127:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80112d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801130:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801137:	f6 c6 04             	test   $0x4,%dh
  80113a:	0f 85 72 ff ff ff    	jne    8010b2 <fork+0x63>
		perm &= ~PTE_W;
  801140:	25 05 0e 00 00       	and    $0xe05,%eax
  801145:	80 cc 08             	or     $0x8,%ah
  801148:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  80114e:	0f 44 c1             	cmove  %ecx,%eax
  801151:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801154:	e9 59 ff ff ff       	jmp    8010b2 <fork+0x63>
  801159:	ba 00 00 00 00       	mov    $0x0,%edx
  80115e:	0f 4f c2             	cmovg  %edx,%eax
  801161:	e9 32 ff ff ff       	jmp    801098 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801166:	83 ec 04             	sub    $0x4,%esp
  801169:	6a 07                	push   $0x7
  80116b:	68 00 f0 bf ee       	push   $0xeebff000
  801170:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801173:	57                   	push   %edi
  801174:	e8 86 fb ff ff       	call   800cff <sys_page_alloc>
	if(r<0) return r;
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	0f 88 14 ff ff ff    	js     801098 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	68 83 24 80 00       	push   $0x802483
  80118c:	57                   	push   %edi
  80118d:	e8 b8 fc ff ff       	call   800e4a <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	0f 88 fb fe ff ff    	js     801098 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	6a 02                	push   $0x2
  8011a2:	57                   	push   %edi
  8011a3:	e8 1e fc ff ff       	call   800dc6 <sys_env_set_status>
	if(r<0) return r;
  8011a8:	83 c4 10             	add    $0x10,%esp
	return envid;
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	0f 49 c7             	cmovns %edi,%eax
  8011b0:	e9 e3 fe ff ff       	jmp    801098 <fork+0x49>

008011b5 <sfork>:

// Challenge!
int
sfork(void)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011bb:	68 01 2c 80 00       	push   $0x802c01
  8011c0:	68 a1 00 00 00       	push   $0xa1
  8011c5:	68 c8 2b 80 00       	push   $0x802bc8
  8011ca:	e8 7f f0 ff ff       	call   80024e <_panic>

008011cf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
  8011d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011e4:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8011e7:	83 ec 0c             	sub    $0xc,%esp
  8011ea:	50                   	push   %eax
  8011eb:	e8 bf fc ff ff       	call   800eaf <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 f6                	test   %esi,%esi
  8011f5:	74 14                	je     80120b <ipc_recv+0x3c>
  8011f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 09                	js     801209 <ipc_recv+0x3a>
  801200:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801206:	8b 52 74             	mov    0x74(%edx),%edx
  801209:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80120b:	85 db                	test   %ebx,%ebx
  80120d:	74 14                	je     801223 <ipc_recv+0x54>
  80120f:	ba 00 00 00 00       	mov    $0x0,%edx
  801214:	85 c0                	test   %eax,%eax
  801216:	78 09                	js     801221 <ipc_recv+0x52>
  801218:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80121e:	8b 52 78             	mov    0x78(%edx),%edx
  801221:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801223:	85 c0                	test   %eax,%eax
  801225:	78 08                	js     80122f <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801227:	a1 00 40 80 00       	mov    0x804000,%eax
  80122c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80122f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801232:	5b                   	pop    %ebx
  801233:	5e                   	pop    %esi
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	57                   	push   %edi
  80123a:	56                   	push   %esi
  80123b:	53                   	push   %ebx
  80123c:	83 ec 0c             	sub    $0xc,%esp
  80123f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801242:	8b 75 0c             	mov    0xc(%ebp),%esi
  801245:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801248:	85 db                	test   %ebx,%ebx
  80124a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80124f:	0f 44 d8             	cmove  %eax,%ebx
  801252:	eb 05                	jmp    801259 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801254:	e8 87 fa ff ff       	call   800ce0 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801259:	ff 75 14             	push   0x14(%ebp)
  80125c:	53                   	push   %ebx
  80125d:	56                   	push   %esi
  80125e:	57                   	push   %edi
  80125f:	e8 28 fc ff ff       	call   800e8c <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80126a:	74 e8                	je     801254 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 08                	js     801278 <ipc_send+0x42>
	}while (r<0);

}
  801270:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801273:	5b                   	pop    %ebx
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801278:	50                   	push   %eax
  801279:	68 17 2c 80 00       	push   $0x802c17
  80127e:	6a 3d                	push   $0x3d
  801280:	68 2b 2c 80 00       	push   $0x802c2b
  801285:	e8 c4 ef ff ff       	call   80024e <_panic>

0080128a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801290:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801295:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801298:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80129e:	8b 52 50             	mov    0x50(%edx),%edx
  8012a1:	39 ca                	cmp    %ecx,%edx
  8012a3:	74 11                	je     8012b6 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8012a5:	83 c0 01             	add    $0x1,%eax
  8012a8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012ad:	75 e6                	jne    801295 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8012af:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b4:	eb 0b                	jmp    8012c1 <ipc_find_env+0x37>
			return envs[i].env_id;
  8012b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012be:	8b 40 48             	mov    0x48(%eax),%eax
}
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c9:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ce:	c1 e8 0c             	shr    $0xc,%eax
}
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012e3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	c1 ea 16             	shr    $0x16,%edx
  8012f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012fe:	f6 c2 01             	test   $0x1,%dl
  801301:	74 29                	je     80132c <fd_alloc+0x42>
  801303:	89 c2                	mov    %eax,%edx
  801305:	c1 ea 0c             	shr    $0xc,%edx
  801308:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130f:	f6 c2 01             	test   $0x1,%dl
  801312:	74 18                	je     80132c <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801314:	05 00 10 00 00       	add    $0x1000,%eax
  801319:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80131e:	75 d2                	jne    8012f2 <fd_alloc+0x8>
  801320:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801325:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80132a:	eb 05                	jmp    801331 <fd_alloc+0x47>
			return 0;
  80132c:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801331:	8b 55 08             	mov    0x8(%ebp),%edx
  801334:	89 02                	mov    %eax,(%edx)
}
  801336:	89 c8                	mov    %ecx,%eax
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801340:	83 f8 1f             	cmp    $0x1f,%eax
  801343:	77 30                	ja     801375 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801345:	c1 e0 0c             	shl    $0xc,%eax
  801348:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80134d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801353:	f6 c2 01             	test   $0x1,%dl
  801356:	74 24                	je     80137c <fd_lookup+0x42>
  801358:	89 c2                	mov    %eax,%edx
  80135a:	c1 ea 0c             	shr    $0xc,%edx
  80135d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801364:	f6 c2 01             	test   $0x1,%dl
  801367:	74 1a                	je     801383 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801369:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136c:	89 02                	mov    %eax,(%edx)
	return 0;
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    
		return -E_INVAL;
  801375:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137a:	eb f7                	jmp    801373 <fd_lookup+0x39>
		return -E_INVAL;
  80137c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801381:	eb f0                	jmp    801373 <fd_lookup+0x39>
  801383:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801388:	eb e9                	jmp    801373 <fd_lookup+0x39>

0080138a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	53                   	push   %ebx
  80138e:	83 ec 04             	sub    $0x4,%esp
  801391:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801394:	b8 00 00 00 00       	mov    $0x0,%eax
  801399:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80139e:	39 13                	cmp    %edx,(%ebx)
  8013a0:	74 37                	je     8013d9 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8013a2:	83 c0 01             	add    $0x1,%eax
  8013a5:	8b 1c 85 b4 2c 80 00 	mov    0x802cb4(,%eax,4),%ebx
  8013ac:	85 db                	test   %ebx,%ebx
  8013ae:	75 ee                	jne    80139e <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013b0:	a1 00 40 80 00       	mov    0x804000,%eax
  8013b5:	8b 40 48             	mov    0x48(%eax),%eax
  8013b8:	83 ec 04             	sub    $0x4,%esp
  8013bb:	52                   	push   %edx
  8013bc:	50                   	push   %eax
  8013bd:	68 38 2c 80 00       	push   $0x802c38
  8013c2:	e8 62 ef ff ff       	call   800329 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8013cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d2:	89 1a                	mov    %ebx,(%edx)
}
  8013d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d7:	c9                   	leave  
  8013d8:	c3                   	ret    
			return 0;
  8013d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013de:	eb ef                	jmp    8013cf <dev_lookup+0x45>

008013e0 <fd_close>:
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	57                   	push   %edi
  8013e4:	56                   	push   %esi
  8013e5:	53                   	push   %ebx
  8013e6:	83 ec 24             	sub    $0x24,%esp
  8013e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013f2:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013f9:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013fc:	50                   	push   %eax
  8013fd:	e8 38 ff ff ff       	call   80133a <fd_lookup>
  801402:	89 c3                	mov    %eax,%ebx
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	85 c0                	test   %eax,%eax
  801409:	78 05                	js     801410 <fd_close+0x30>
	    || fd != fd2)
  80140b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80140e:	74 16                	je     801426 <fd_close+0x46>
		return (must_exist ? r : 0);
  801410:	89 f8                	mov    %edi,%eax
  801412:	84 c0                	test   %al,%al
  801414:	b8 00 00 00 00       	mov    $0x0,%eax
  801419:	0f 44 d8             	cmove  %eax,%ebx
}
  80141c:	89 d8                	mov    %ebx,%eax
  80141e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80142c:	50                   	push   %eax
  80142d:	ff 36                	push   (%esi)
  80142f:	e8 56 ff ff ff       	call   80138a <dev_lookup>
  801434:	89 c3                	mov    %eax,%ebx
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	85 c0                	test   %eax,%eax
  80143b:	78 1a                	js     801457 <fd_close+0x77>
		if (dev->dev_close)
  80143d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801440:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801443:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801448:	85 c0                	test   %eax,%eax
  80144a:	74 0b                	je     801457 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	56                   	push   %esi
  801450:	ff d0                	call   *%eax
  801452:	89 c3                	mov    %eax,%ebx
  801454:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	56                   	push   %esi
  80145b:	6a 00                	push   $0x0
  80145d:	e8 22 f9 ff ff       	call   800d84 <sys_page_unmap>
	return r;
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	eb b5                	jmp    80141c <fd_close+0x3c>

00801467 <close>:

int
close(int fdnum)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801470:	50                   	push   %eax
  801471:	ff 75 08             	push   0x8(%ebp)
  801474:	e8 c1 fe ff ff       	call   80133a <fd_lookup>
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	79 02                	jns    801482 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801480:	c9                   	leave  
  801481:	c3                   	ret    
		return fd_close(fd, 1);
  801482:	83 ec 08             	sub    $0x8,%esp
  801485:	6a 01                	push   $0x1
  801487:	ff 75 f4             	push   -0xc(%ebp)
  80148a:	e8 51 ff ff ff       	call   8013e0 <fd_close>
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	eb ec                	jmp    801480 <close+0x19>

00801494 <close_all>:

void
close_all(void)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	53                   	push   %ebx
  801498:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80149b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a0:	83 ec 0c             	sub    $0xc,%esp
  8014a3:	53                   	push   %ebx
  8014a4:	e8 be ff ff ff       	call   801467 <close>
	for (i = 0; i < MAXFD; i++)
  8014a9:	83 c3 01             	add    $0x1,%ebx
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	83 fb 20             	cmp    $0x20,%ebx
  8014b2:	75 ec                	jne    8014a0 <close_all+0xc>
}
  8014b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	57                   	push   %edi
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	ff 75 08             	push   0x8(%ebp)
  8014c9:	e8 6c fe ff ff       	call   80133a <fd_lookup>
  8014ce:	89 c3                	mov    %eax,%ebx
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 7f                	js     801556 <dup+0x9d>
		return r;
	close(newfdnum);
  8014d7:	83 ec 0c             	sub    $0xc,%esp
  8014da:	ff 75 0c             	push   0xc(%ebp)
  8014dd:	e8 85 ff ff ff       	call   801467 <close>

	newfd = INDEX2FD(newfdnum);
  8014e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014e5:	c1 e6 0c             	shl    $0xc,%esi
  8014e8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014f1:	89 3c 24             	mov    %edi,(%esp)
  8014f4:	e8 da fd ff ff       	call   8012d3 <fd2data>
  8014f9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014fb:	89 34 24             	mov    %esi,(%esp)
  8014fe:	e8 d0 fd ff ff       	call   8012d3 <fd2data>
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	c1 e8 16             	shr    $0x16,%eax
  80150e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801515:	a8 01                	test   $0x1,%al
  801517:	74 11                	je     80152a <dup+0x71>
  801519:	89 d8                	mov    %ebx,%eax
  80151b:	c1 e8 0c             	shr    $0xc,%eax
  80151e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801525:	f6 c2 01             	test   $0x1,%dl
  801528:	75 36                	jne    801560 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80152a:	89 f8                	mov    %edi,%eax
  80152c:	c1 e8 0c             	shr    $0xc,%eax
  80152f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801536:	83 ec 0c             	sub    $0xc,%esp
  801539:	25 07 0e 00 00       	and    $0xe07,%eax
  80153e:	50                   	push   %eax
  80153f:	56                   	push   %esi
  801540:	6a 00                	push   $0x0
  801542:	57                   	push   %edi
  801543:	6a 00                	push   $0x0
  801545:	e8 f8 f7 ff ff       	call   800d42 <sys_page_map>
  80154a:	89 c3                	mov    %eax,%ebx
  80154c:	83 c4 20             	add    $0x20,%esp
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 33                	js     801586 <dup+0xcd>
		goto err;

	return newfdnum;
  801553:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801556:	89 d8                	mov    %ebx,%eax
  801558:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155b:	5b                   	pop    %ebx
  80155c:	5e                   	pop    %esi
  80155d:	5f                   	pop    %edi
  80155e:	5d                   	pop    %ebp
  80155f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801560:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801567:	83 ec 0c             	sub    $0xc,%esp
  80156a:	25 07 0e 00 00       	and    $0xe07,%eax
  80156f:	50                   	push   %eax
  801570:	ff 75 d4             	push   -0x2c(%ebp)
  801573:	6a 00                	push   $0x0
  801575:	53                   	push   %ebx
  801576:	6a 00                	push   $0x0
  801578:	e8 c5 f7 ff ff       	call   800d42 <sys_page_map>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	83 c4 20             	add    $0x20,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	79 a4                	jns    80152a <dup+0x71>
	sys_page_unmap(0, newfd);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	56                   	push   %esi
  80158a:	6a 00                	push   $0x0
  80158c:	e8 f3 f7 ff ff       	call   800d84 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	ff 75 d4             	push   -0x2c(%ebp)
  801597:	6a 00                	push   $0x0
  801599:	e8 e6 f7 ff ff       	call   800d84 <sys_page_unmap>
	return r;
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	eb b3                	jmp    801556 <dup+0x9d>

008015a3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	56                   	push   %esi
  8015a7:	53                   	push   %ebx
  8015a8:	83 ec 18             	sub    $0x18,%esp
  8015ab:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	56                   	push   %esi
  8015b3:	e8 82 fd ff ff       	call   80133a <fd_lookup>
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 3c                	js     8015fb <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bf:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8015c2:	83 ec 08             	sub    $0x8,%esp
  8015c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	ff 33                	push   (%ebx)
  8015cb:	e8 ba fd ff ff       	call   80138a <dev_lookup>
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 24                	js     8015fb <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015d7:	8b 43 08             	mov    0x8(%ebx),%eax
  8015da:	83 e0 03             	and    $0x3,%eax
  8015dd:	83 f8 01             	cmp    $0x1,%eax
  8015e0:	74 20                	je     801602 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e5:	8b 40 08             	mov    0x8(%eax),%eax
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	74 37                	je     801623 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015ec:	83 ec 04             	sub    $0x4,%esp
  8015ef:	ff 75 10             	push   0x10(%ebp)
  8015f2:	ff 75 0c             	push   0xc(%ebp)
  8015f5:	53                   	push   %ebx
  8015f6:	ff d0                	call   *%eax
  8015f8:	83 c4 10             	add    $0x10,%esp
}
  8015fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fe:	5b                   	pop    %ebx
  8015ff:	5e                   	pop    %esi
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801602:	a1 00 40 80 00       	mov    0x804000,%eax
  801607:	8b 40 48             	mov    0x48(%eax),%eax
  80160a:	83 ec 04             	sub    $0x4,%esp
  80160d:	56                   	push   %esi
  80160e:	50                   	push   %eax
  80160f:	68 79 2c 80 00       	push   $0x802c79
  801614:	e8 10 ed ff ff       	call   800329 <cprintf>
		return -E_INVAL;
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801621:	eb d8                	jmp    8015fb <read+0x58>
		return -E_NOT_SUPP;
  801623:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801628:	eb d1                	jmp    8015fb <read+0x58>

0080162a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	57                   	push   %edi
  80162e:	56                   	push   %esi
  80162f:	53                   	push   %ebx
  801630:	83 ec 0c             	sub    $0xc,%esp
  801633:	8b 7d 08             	mov    0x8(%ebp),%edi
  801636:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801639:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163e:	eb 02                	jmp    801642 <readn+0x18>
  801640:	01 c3                	add    %eax,%ebx
  801642:	39 f3                	cmp    %esi,%ebx
  801644:	73 21                	jae    801667 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801646:	83 ec 04             	sub    $0x4,%esp
  801649:	89 f0                	mov    %esi,%eax
  80164b:	29 d8                	sub    %ebx,%eax
  80164d:	50                   	push   %eax
  80164e:	89 d8                	mov    %ebx,%eax
  801650:	03 45 0c             	add    0xc(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	57                   	push   %edi
  801655:	e8 49 ff ff ff       	call   8015a3 <read>
		if (m < 0)
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 04                	js     801665 <readn+0x3b>
			return m;
		if (m == 0)
  801661:	75 dd                	jne    801640 <readn+0x16>
  801663:	eb 02                	jmp    801667 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801665:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801667:	89 d8                	mov    %ebx,%eax
  801669:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5e                   	pop    %esi
  80166e:	5f                   	pop    %edi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
  801676:	83 ec 18             	sub    $0x18,%esp
  801679:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167f:	50                   	push   %eax
  801680:	53                   	push   %ebx
  801681:	e8 b4 fc ff ff       	call   80133a <fd_lookup>
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 37                	js     8016c4 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	ff 36                	push   (%esi)
  801699:	e8 ec fc ff ff       	call   80138a <dev_lookup>
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 1f                	js     8016c4 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a5:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8016a9:	74 20                	je     8016cb <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	74 37                	je     8016ec <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016b5:	83 ec 04             	sub    $0x4,%esp
  8016b8:	ff 75 10             	push   0x10(%ebp)
  8016bb:	ff 75 0c             	push   0xc(%ebp)
  8016be:	56                   	push   %esi
  8016bf:	ff d0                	call   *%eax
  8016c1:	83 c4 10             	add    $0x10,%esp
}
  8016c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c7:	5b                   	pop    %ebx
  8016c8:	5e                   	pop    %esi
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cb:	a1 00 40 80 00       	mov    0x804000,%eax
  8016d0:	8b 40 48             	mov    0x48(%eax),%eax
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	53                   	push   %ebx
  8016d7:	50                   	push   %eax
  8016d8:	68 95 2c 80 00       	push   $0x802c95
  8016dd:	e8 47 ec ff ff       	call   800329 <cprintf>
		return -E_INVAL;
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ea:	eb d8                	jmp    8016c4 <write+0x53>
		return -E_NOT_SUPP;
  8016ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f1:	eb d1                	jmp    8016c4 <write+0x53>

008016f3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fc:	50                   	push   %eax
  8016fd:	ff 75 08             	push   0x8(%ebp)
  801700:	e8 35 fc ff ff       	call   80133a <fd_lookup>
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 0e                	js     80171a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80170c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801712:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801715:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	83 ec 18             	sub    $0x18,%esp
  801724:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801727:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172a:	50                   	push   %eax
  80172b:	53                   	push   %ebx
  80172c:	e8 09 fc ff ff       	call   80133a <fd_lookup>
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	85 c0                	test   %eax,%eax
  801736:	78 34                	js     80176c <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801738:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801741:	50                   	push   %eax
  801742:	ff 36                	push   (%esi)
  801744:	e8 41 fc ff ff       	call   80138a <dev_lookup>
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 1c                	js     80176c <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801750:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801754:	74 1d                	je     801773 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801759:	8b 40 18             	mov    0x18(%eax),%eax
  80175c:	85 c0                	test   %eax,%eax
  80175e:	74 34                	je     801794 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	ff 75 0c             	push   0xc(%ebp)
  801766:	56                   	push   %esi
  801767:	ff d0                	call   *%eax
  801769:	83 c4 10             	add    $0x10,%esp
}
  80176c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176f:	5b                   	pop    %ebx
  801770:	5e                   	pop    %esi
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    
			thisenv->env_id, fdnum);
  801773:	a1 00 40 80 00       	mov    0x804000,%eax
  801778:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80177b:	83 ec 04             	sub    $0x4,%esp
  80177e:	53                   	push   %ebx
  80177f:	50                   	push   %eax
  801780:	68 58 2c 80 00       	push   $0x802c58
  801785:	e8 9f eb ff ff       	call   800329 <cprintf>
		return -E_INVAL;
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801792:	eb d8                	jmp    80176c <ftruncate+0x50>
		return -E_NOT_SUPP;
  801794:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801799:	eb d1                	jmp    80176c <ftruncate+0x50>

0080179b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	56                   	push   %esi
  80179f:	53                   	push   %ebx
  8017a0:	83 ec 18             	sub    $0x18,%esp
  8017a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a9:	50                   	push   %eax
  8017aa:	ff 75 08             	push   0x8(%ebp)
  8017ad:	e8 88 fb ff ff       	call   80133a <fd_lookup>
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 49                	js     801802 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8017bc:	83 ec 08             	sub    $0x8,%esp
  8017bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c2:	50                   	push   %eax
  8017c3:	ff 36                	push   (%esi)
  8017c5:	e8 c0 fb ff ff       	call   80138a <dev_lookup>
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 31                	js     801802 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8017d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017d8:	74 2f                	je     801809 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017da:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017e4:	00 00 00 
	stat->st_isdir = 0;
  8017e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ee:	00 00 00 
	stat->st_dev = dev;
  8017f1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	53                   	push   %ebx
  8017fb:	56                   	push   %esi
  8017fc:	ff 50 14             	call   *0x14(%eax)
  8017ff:	83 c4 10             	add    $0x10,%esp
}
  801802:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801805:	5b                   	pop    %ebx
  801806:	5e                   	pop    %esi
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    
		return -E_NOT_SUPP;
  801809:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80180e:	eb f2                	jmp    801802 <fstat+0x67>

00801810 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	6a 00                	push   $0x0
  80181a:	ff 75 08             	push   0x8(%ebp)
  80181d:	e8 e4 01 00 00       	call   801a06 <open>
  801822:	89 c3                	mov    %eax,%ebx
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	85 c0                	test   %eax,%eax
  801829:	78 1b                	js     801846 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	ff 75 0c             	push   0xc(%ebp)
  801831:	50                   	push   %eax
  801832:	e8 64 ff ff ff       	call   80179b <fstat>
  801837:	89 c6                	mov    %eax,%esi
	close(fd);
  801839:	89 1c 24             	mov    %ebx,(%esp)
  80183c:	e8 26 fc ff ff       	call   801467 <close>
	return r;
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	89 f3                	mov    %esi,%ebx
}
  801846:	89 d8                	mov    %ebx,%eax
  801848:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5e                   	pop    %esi
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	89 c6                	mov    %eax,%esi
  801856:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801858:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80185f:	74 27                	je     801888 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801861:	6a 07                	push   $0x7
  801863:	68 00 50 80 00       	push   $0x805000
  801868:	56                   	push   %esi
  801869:	ff 35 00 60 80 00    	push   0x806000
  80186f:	e8 c2 f9 ff ff       	call   801236 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801874:	83 c4 0c             	add    $0xc,%esp
  801877:	6a 00                	push   $0x0
  801879:	53                   	push   %ebx
  80187a:	6a 00                	push   $0x0
  80187c:	e8 4e f9 ff ff       	call   8011cf <ipc_recv>
}
  801881:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801884:	5b                   	pop    %ebx
  801885:	5e                   	pop    %esi
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801888:	83 ec 0c             	sub    $0xc,%esp
  80188b:	6a 01                	push   $0x1
  80188d:	e8 f8 f9 ff ff       	call   80128a <ipc_find_env>
  801892:	a3 00 60 80 00       	mov    %eax,0x806000
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	eb c5                	jmp    801861 <fsipc+0x12>

0080189c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ba:	b8 02 00 00 00       	mov    $0x2,%eax
  8018bf:	e8 8b ff ff ff       	call   80184f <fsipc>
}
  8018c4:	c9                   	leave  
  8018c5:	c3                   	ret    

008018c6 <devfile_flush>:
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8018e1:	e8 69 ff ff ff       	call   80184f <fsipc>
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <devfile_stat>:
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 04             	sub    $0x4,%esp
  8018ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 05 00 00 00       	mov    $0x5,%eax
  801907:	e8 43 ff ff ff       	call   80184f <fsipc>
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 2c                	js     80193c <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	68 00 50 80 00       	push   $0x805000
  801918:	53                   	push   %ebx
  801919:	e8 e5 ef ff ff       	call   800903 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80191e:	a1 80 50 80 00       	mov    0x805080,%eax
  801923:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801929:	a1 84 50 80 00       	mov    0x805084,%eax
  80192e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <devfile_write>:
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 0c             	sub    $0xc,%esp
  801947:	8b 45 10             	mov    0x10(%ebp),%eax
  80194a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80194f:	39 d0                	cmp    %edx,%eax
  801951:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801954:	8b 55 08             	mov    0x8(%ebp),%edx
  801957:	8b 52 0c             	mov    0xc(%edx),%edx
  80195a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801960:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801965:	50                   	push   %eax
  801966:	ff 75 0c             	push   0xc(%ebp)
  801969:	68 08 50 80 00       	push   $0x805008
  80196e:	e8 26 f1 ff ff       	call   800a99 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801973:	ba 00 00 00 00       	mov    $0x0,%edx
  801978:	b8 04 00 00 00       	mov    $0x4,%eax
  80197d:	e8 cd fe ff ff       	call   80184f <fsipc>
}
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <devfile_read>:
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80198c:	8b 45 08             	mov    0x8(%ebp),%eax
  80198f:	8b 40 0c             	mov    0xc(%eax),%eax
  801992:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801997:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80199d:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8019a7:	e8 a3 fe ff ff       	call   80184f <fsipc>
  8019ac:	89 c3                	mov    %eax,%ebx
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	78 1f                	js     8019d1 <devfile_read+0x4d>
	assert(r <= n);
  8019b2:	39 f0                	cmp    %esi,%eax
  8019b4:	77 24                	ja     8019da <devfile_read+0x56>
	assert(r <= PGSIZE);
  8019b6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019bb:	7f 33                	jg     8019f0 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019bd:	83 ec 04             	sub    $0x4,%esp
  8019c0:	50                   	push   %eax
  8019c1:	68 00 50 80 00       	push   $0x805000
  8019c6:	ff 75 0c             	push   0xc(%ebp)
  8019c9:	e8 cb f0 ff ff       	call   800a99 <memmove>
	return r;
  8019ce:	83 c4 10             	add    $0x10,%esp
}
  8019d1:	89 d8                	mov    %ebx,%eax
  8019d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d6:	5b                   	pop    %ebx
  8019d7:	5e                   	pop    %esi
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    
	assert(r <= n);
  8019da:	68 c8 2c 80 00       	push   $0x802cc8
  8019df:	68 cf 2c 80 00       	push   $0x802ccf
  8019e4:	6a 7c                	push   $0x7c
  8019e6:	68 e4 2c 80 00       	push   $0x802ce4
  8019eb:	e8 5e e8 ff ff       	call   80024e <_panic>
	assert(r <= PGSIZE);
  8019f0:	68 ef 2c 80 00       	push   $0x802cef
  8019f5:	68 cf 2c 80 00       	push   $0x802ccf
  8019fa:	6a 7d                	push   $0x7d
  8019fc:	68 e4 2c 80 00       	push   $0x802ce4
  801a01:	e8 48 e8 ff ff       	call   80024e <_panic>

00801a06 <open>:
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	83 ec 1c             	sub    $0x1c,%esp
  801a0e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a11:	56                   	push   %esi
  801a12:	e8 b1 ee ff ff       	call   8008c8 <strlen>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a1f:	7f 6c                	jg     801a8d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801a21:	83 ec 0c             	sub    $0xc,%esp
  801a24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a27:	50                   	push   %eax
  801a28:	e8 bd f8 ff ff       	call   8012ea <fd_alloc>
  801a2d:	89 c3                	mov    %eax,%ebx
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 3c                	js     801a72 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801a36:	83 ec 08             	sub    $0x8,%esp
  801a39:	56                   	push   %esi
  801a3a:	68 00 50 80 00       	push   $0x805000
  801a3f:	e8 bf ee ff ff       	call   800903 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a47:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a4f:	b8 01 00 00 00       	mov    $0x1,%eax
  801a54:	e8 f6 fd ff ff       	call   80184f <fsipc>
  801a59:	89 c3                	mov    %eax,%ebx
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	78 19                	js     801a7b <open+0x75>
	return fd2num(fd);
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	ff 75 f4             	push   -0xc(%ebp)
  801a68:	e8 56 f8 ff ff       	call   8012c3 <fd2num>
  801a6d:	89 c3                	mov    %eax,%ebx
  801a6f:	83 c4 10             	add    $0x10,%esp
}
  801a72:	89 d8                	mov    %ebx,%eax
  801a74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    
		fd_close(fd, 0);
  801a7b:	83 ec 08             	sub    $0x8,%esp
  801a7e:	6a 00                	push   $0x0
  801a80:	ff 75 f4             	push   -0xc(%ebp)
  801a83:	e8 58 f9 ff ff       	call   8013e0 <fd_close>
		return r;
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	eb e5                	jmp    801a72 <open+0x6c>
		return -E_BAD_PATH;
  801a8d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a92:	eb de                	jmp    801a72 <open+0x6c>

00801a94 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9f:	b8 08 00 00 00       	mov    $0x8,%eax
  801aa4:	e8 a6 fd ff ff       	call   80184f <fsipc>
}
  801aa9:	c9                   	leave  
  801aaa:	c3                   	ret    

00801aab <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ab1:	89 c2                	mov    %eax,%edx
  801ab3:	c1 ea 16             	shr    $0x16,%edx
  801ab6:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801abd:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ac2:	f6 c1 01             	test   $0x1,%cl
  801ac5:	74 1c                	je     801ae3 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ac7:	c1 e8 0c             	shr    $0xc,%eax
  801aca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ad1:	a8 01                	test   $0x1,%al
  801ad3:	74 0e                	je     801ae3 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ad5:	c1 e8 0c             	shr    $0xc,%eax
  801ad8:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801adf:	ef 
  801ae0:	0f b7 d2             	movzwl %dx,%edx
}
  801ae3:	89 d0                	mov    %edx,%eax
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801aed:	68 fb 2c 80 00       	push   $0x802cfb
  801af2:	ff 75 0c             	push   0xc(%ebp)
  801af5:	e8 09 ee ff ff       	call   800903 <strcpy>
	return 0;
}
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    

00801b01 <devsock_close>:
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	53                   	push   %ebx
  801b05:	83 ec 10             	sub    $0x10,%esp
  801b08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b0b:	53                   	push   %ebx
  801b0c:	e8 9a ff ff ff       	call   801aab <pageref>
  801b11:	89 c2                	mov    %eax,%edx
  801b13:	83 c4 10             	add    $0x10,%esp
		return 0;
  801b16:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801b1b:	83 fa 01             	cmp    $0x1,%edx
  801b1e:	74 05                	je     801b25 <devsock_close+0x24>
}
  801b20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801b25:	83 ec 0c             	sub    $0xc,%esp
  801b28:	ff 73 0c             	push   0xc(%ebx)
  801b2b:	e8 b7 02 00 00       	call   801de7 <nsipc_close>
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	eb eb                	jmp    801b20 <devsock_close+0x1f>

00801b35 <devsock_write>:
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b3b:	6a 00                	push   $0x0
  801b3d:	ff 75 10             	push   0x10(%ebp)
  801b40:	ff 75 0c             	push   0xc(%ebp)
  801b43:	8b 45 08             	mov    0x8(%ebp),%eax
  801b46:	ff 70 0c             	push   0xc(%eax)
  801b49:	e8 79 03 00 00       	call   801ec7 <nsipc_send>
}
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <devsock_read>:
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b56:	6a 00                	push   $0x0
  801b58:	ff 75 10             	push   0x10(%ebp)
  801b5b:	ff 75 0c             	push   0xc(%ebp)
  801b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b61:	ff 70 0c             	push   0xc(%eax)
  801b64:	e8 ef 02 00 00       	call   801e58 <nsipc_recv>
}
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <fd2sockid>:
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b71:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b74:	52                   	push   %edx
  801b75:	50                   	push   %eax
  801b76:	e8 bf f7 ff ff       	call   80133a <fd_lookup>
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	78 10                	js     801b92 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b85:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b8b:	39 08                	cmp    %ecx,(%eax)
  801b8d:	75 05                	jne    801b94 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801b8f:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    
		return -E_NOT_SUPP;
  801b94:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b99:	eb f7                	jmp    801b92 <fd2sockid+0x27>

00801b9b <alloc_sockfd>:
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 1c             	sub    $0x1c,%esp
  801ba3:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801ba5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba8:	50                   	push   %eax
  801ba9:	e8 3c f7 ff ff       	call   8012ea <fd_alloc>
  801bae:	89 c3                	mov    %eax,%ebx
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 43                	js     801bfa <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bb7:	83 ec 04             	sub    $0x4,%esp
  801bba:	68 07 04 00 00       	push   $0x407
  801bbf:	ff 75 f4             	push   -0xc(%ebp)
  801bc2:	6a 00                	push   $0x0
  801bc4:	e8 36 f1 ff ff       	call   800cff <sys_page_alloc>
  801bc9:	89 c3                	mov    %eax,%ebx
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 28                	js     801bfa <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bdb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801be7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bea:	83 ec 0c             	sub    $0xc,%esp
  801bed:	50                   	push   %eax
  801bee:	e8 d0 f6 ff ff       	call   8012c3 <fd2num>
  801bf3:	89 c3                	mov    %eax,%ebx
  801bf5:	83 c4 10             	add    $0x10,%esp
  801bf8:	eb 0c                	jmp    801c06 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801bfa:	83 ec 0c             	sub    $0xc,%esp
  801bfd:	56                   	push   %esi
  801bfe:	e8 e4 01 00 00       	call   801de7 <nsipc_close>
		return r;
  801c03:	83 c4 10             	add    $0x10,%esp
}
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <accept>:
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c15:	8b 45 08             	mov    0x8(%ebp),%eax
  801c18:	e8 4e ff ff ff       	call   801b6b <fd2sockid>
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 1b                	js     801c3c <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c21:	83 ec 04             	sub    $0x4,%esp
  801c24:	ff 75 10             	push   0x10(%ebp)
  801c27:	ff 75 0c             	push   0xc(%ebp)
  801c2a:	50                   	push   %eax
  801c2b:	e8 0e 01 00 00       	call   801d3e <nsipc_accept>
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	85 c0                	test   %eax,%eax
  801c35:	78 05                	js     801c3c <accept+0x2d>
	return alloc_sockfd(r);
  801c37:	e8 5f ff ff ff       	call   801b9b <alloc_sockfd>
}
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <bind>:
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	e8 1f ff ff ff       	call   801b6b <fd2sockid>
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	78 12                	js     801c62 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801c50:	83 ec 04             	sub    $0x4,%esp
  801c53:	ff 75 10             	push   0x10(%ebp)
  801c56:	ff 75 0c             	push   0xc(%ebp)
  801c59:	50                   	push   %eax
  801c5a:	e8 31 01 00 00       	call   801d90 <nsipc_bind>
  801c5f:	83 c4 10             	add    $0x10,%esp
}
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    

00801c64 <shutdown>:
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6d:	e8 f9 fe ff ff       	call   801b6b <fd2sockid>
  801c72:	85 c0                	test   %eax,%eax
  801c74:	78 0f                	js     801c85 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801c76:	83 ec 08             	sub    $0x8,%esp
  801c79:	ff 75 0c             	push   0xc(%ebp)
  801c7c:	50                   	push   %eax
  801c7d:	e8 43 01 00 00       	call   801dc5 <nsipc_shutdown>
  801c82:	83 c4 10             	add    $0x10,%esp
}
  801c85:	c9                   	leave  
  801c86:	c3                   	ret    

00801c87 <connect>:
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	e8 d6 fe ff ff       	call   801b6b <fd2sockid>
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 12                	js     801cab <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801c99:	83 ec 04             	sub    $0x4,%esp
  801c9c:	ff 75 10             	push   0x10(%ebp)
  801c9f:	ff 75 0c             	push   0xc(%ebp)
  801ca2:	50                   	push   %eax
  801ca3:	e8 59 01 00 00       	call   801e01 <nsipc_connect>
  801ca8:	83 c4 10             	add    $0x10,%esp
}
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <listen>:
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	e8 b0 fe ff ff       	call   801b6b <fd2sockid>
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 0f                	js     801cce <listen+0x21>
	return nsipc_listen(r, backlog);
  801cbf:	83 ec 08             	sub    $0x8,%esp
  801cc2:	ff 75 0c             	push   0xc(%ebp)
  801cc5:	50                   	push   %eax
  801cc6:	e8 6b 01 00 00       	call   801e36 <nsipc_listen>
  801ccb:	83 c4 10             	add    $0x10,%esp
}
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <socket>:

int
socket(int domain, int type, int protocol)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cd6:	ff 75 10             	push   0x10(%ebp)
  801cd9:	ff 75 0c             	push   0xc(%ebp)
  801cdc:	ff 75 08             	push   0x8(%ebp)
  801cdf:	e8 41 02 00 00       	call   801f25 <nsipc_socket>
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	78 05                	js     801cf0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ceb:	e8 ab fe ff ff       	call   801b9b <alloc_sockfd>
}
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	53                   	push   %ebx
  801cf6:	83 ec 04             	sub    $0x4,%esp
  801cf9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cfb:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801d02:	74 26                	je     801d2a <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d04:	6a 07                	push   $0x7
  801d06:	68 00 70 80 00       	push   $0x807000
  801d0b:	53                   	push   %ebx
  801d0c:	ff 35 00 80 80 00    	push   0x808000
  801d12:	e8 1f f5 ff ff       	call   801236 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d17:	83 c4 0c             	add    $0xc,%esp
  801d1a:	6a 00                	push   $0x0
  801d1c:	6a 00                	push   $0x0
  801d1e:	6a 00                	push   $0x0
  801d20:	e8 aa f4 ff ff       	call   8011cf <ipc_recv>
}
  801d25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d28:	c9                   	leave  
  801d29:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d2a:	83 ec 0c             	sub    $0xc,%esp
  801d2d:	6a 02                	push   $0x2
  801d2f:	e8 56 f5 ff ff       	call   80128a <ipc_find_env>
  801d34:	a3 00 80 80 00       	mov    %eax,0x808000
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	eb c6                	jmp    801d04 <nsipc+0x12>

00801d3e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	56                   	push   %esi
  801d42:	53                   	push   %ebx
  801d43:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d46:	8b 45 08             	mov    0x8(%ebp),%eax
  801d49:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d4e:	8b 06                	mov    (%esi),%eax
  801d50:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d55:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5a:	e8 93 ff ff ff       	call   801cf2 <nsipc>
  801d5f:	89 c3                	mov    %eax,%ebx
  801d61:	85 c0                	test   %eax,%eax
  801d63:	79 09                	jns    801d6e <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801d65:	89 d8                	mov    %ebx,%eax
  801d67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d6a:	5b                   	pop    %ebx
  801d6b:	5e                   	pop    %esi
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d6e:	83 ec 04             	sub    $0x4,%esp
  801d71:	ff 35 10 70 80 00    	push   0x807010
  801d77:	68 00 70 80 00       	push   $0x807000
  801d7c:	ff 75 0c             	push   0xc(%ebp)
  801d7f:	e8 15 ed ff ff       	call   800a99 <memmove>
		*addrlen = ret->ret_addrlen;
  801d84:	a1 10 70 80 00       	mov    0x807010,%eax
  801d89:	89 06                	mov    %eax,(%esi)
  801d8b:	83 c4 10             	add    $0x10,%esp
	return r;
  801d8e:	eb d5                	jmp    801d65 <nsipc_accept+0x27>

00801d90 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	53                   	push   %ebx
  801d94:	83 ec 08             	sub    $0x8,%esp
  801d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801da2:	53                   	push   %ebx
  801da3:	ff 75 0c             	push   0xc(%ebp)
  801da6:	68 04 70 80 00       	push   $0x807004
  801dab:	e8 e9 ec ff ff       	call   800a99 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801db0:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801db6:	b8 02 00 00 00       	mov    $0x2,%eax
  801dbb:	e8 32 ff ff ff       	call   801cf2 <nsipc>
}
  801dc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dce:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd6:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ddb:	b8 03 00 00 00       	mov    $0x3,%eax
  801de0:	e8 0d ff ff ff       	call   801cf2 <nsipc>
}
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <nsipc_close>:

int
nsipc_close(int s)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801df5:	b8 04 00 00 00       	mov    $0x4,%eax
  801dfa:	e8 f3 fe ff ff       	call   801cf2 <nsipc>
}
  801dff:	c9                   	leave  
  801e00:	c3                   	ret    

00801e01 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	53                   	push   %ebx
  801e05:	83 ec 08             	sub    $0x8,%esp
  801e08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e13:	53                   	push   %ebx
  801e14:	ff 75 0c             	push   0xc(%ebp)
  801e17:	68 04 70 80 00       	push   $0x807004
  801e1c:	e8 78 ec ff ff       	call   800a99 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e21:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801e27:	b8 05 00 00 00       	mov    $0x5,%eax
  801e2c:	e8 c1 fe ff ff       	call   801cf2 <nsipc>
}
  801e31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801e44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e47:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801e4c:	b8 06 00 00 00       	mov    $0x6,%eax
  801e51:	e8 9c fe ff ff       	call   801cf2 <nsipc>
}
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    

00801e58 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	56                   	push   %esi
  801e5c:	53                   	push   %ebx
  801e5d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e60:	8b 45 08             	mov    0x8(%ebp),%eax
  801e63:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801e68:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801e6e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e71:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e76:	b8 07 00 00 00       	mov    $0x7,%eax
  801e7b:	e8 72 fe ff ff       	call   801cf2 <nsipc>
  801e80:	89 c3                	mov    %eax,%ebx
  801e82:	85 c0                	test   %eax,%eax
  801e84:	78 22                	js     801ea8 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801e86:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e8b:	39 c6                	cmp    %eax,%esi
  801e8d:	0f 4e c6             	cmovle %esi,%eax
  801e90:	39 c3                	cmp    %eax,%ebx
  801e92:	7f 1d                	jg     801eb1 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e94:	83 ec 04             	sub    $0x4,%esp
  801e97:	53                   	push   %ebx
  801e98:	68 00 70 80 00       	push   $0x807000
  801e9d:	ff 75 0c             	push   0xc(%ebp)
  801ea0:	e8 f4 eb ff ff       	call   800a99 <memmove>
  801ea5:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ea8:	89 d8                	mov    %ebx,%eax
  801eaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801eb1:	68 07 2d 80 00       	push   $0x802d07
  801eb6:	68 cf 2c 80 00       	push   $0x802ccf
  801ebb:	6a 62                	push   $0x62
  801ebd:	68 1c 2d 80 00       	push   $0x802d1c
  801ec2:	e8 87 e3 ff ff       	call   80024e <_panic>

00801ec7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 04             	sub    $0x4,%esp
  801ece:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed4:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801ed9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801edf:	7f 2e                	jg     801f0f <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ee1:	83 ec 04             	sub    $0x4,%esp
  801ee4:	53                   	push   %ebx
  801ee5:	ff 75 0c             	push   0xc(%ebp)
  801ee8:	68 0c 70 80 00       	push   $0x80700c
  801eed:	e8 a7 eb ff ff       	call   800a99 <memmove>
	nsipcbuf.send.req_size = size;
  801ef2:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801ef8:	8b 45 14             	mov    0x14(%ebp),%eax
  801efb:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801f00:	b8 08 00 00 00       	mov    $0x8,%eax
  801f05:	e8 e8 fd ff ff       	call   801cf2 <nsipc>
}
  801f0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f0d:	c9                   	leave  
  801f0e:	c3                   	ret    
	assert(size < 1600);
  801f0f:	68 28 2d 80 00       	push   $0x802d28
  801f14:	68 cf 2c 80 00       	push   $0x802ccf
  801f19:	6a 6d                	push   $0x6d
  801f1b:	68 1c 2d 80 00       	push   $0x802d1c
  801f20:	e8 29 e3 ff ff       	call   80024e <_panic>

00801f25 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801f33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f36:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801f3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801f3e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801f43:	b8 09 00 00 00       	mov    $0x9,%eax
  801f48:	e8 a5 fd ff ff       	call   801cf2 <nsipc>
}
  801f4d:	c9                   	leave  
  801f4e:	c3                   	ret    

00801f4f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f57:	83 ec 0c             	sub    $0xc,%esp
  801f5a:	ff 75 08             	push   0x8(%ebp)
  801f5d:	e8 71 f3 ff ff       	call   8012d3 <fd2data>
  801f62:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f64:	83 c4 08             	add    $0x8,%esp
  801f67:	68 34 2d 80 00       	push   $0x802d34
  801f6c:	53                   	push   %ebx
  801f6d:	e8 91 e9 ff ff       	call   800903 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f72:	8b 46 04             	mov    0x4(%esi),%eax
  801f75:	2b 06                	sub    (%esi),%eax
  801f77:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f7d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f84:	00 00 00 
	stat->st_dev = &devpipe;
  801f87:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f8e:	30 80 00 
	return 0;
}
  801f91:	b8 00 00 00 00       	mov    $0x0,%eax
  801f96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	53                   	push   %ebx
  801fa1:	83 ec 0c             	sub    $0xc,%esp
  801fa4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fa7:	53                   	push   %ebx
  801fa8:	6a 00                	push   $0x0
  801faa:	e8 d5 ed ff ff       	call   800d84 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801faf:	89 1c 24             	mov    %ebx,(%esp)
  801fb2:	e8 1c f3 ff ff       	call   8012d3 <fd2data>
  801fb7:	83 c4 08             	add    $0x8,%esp
  801fba:	50                   	push   %eax
  801fbb:	6a 00                	push   $0x0
  801fbd:	e8 c2 ed ff ff       	call   800d84 <sys_page_unmap>
}
  801fc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fc5:	c9                   	leave  
  801fc6:	c3                   	ret    

00801fc7 <_pipeisclosed>:
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	57                   	push   %edi
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	83 ec 1c             	sub    $0x1c,%esp
  801fd0:	89 c7                	mov    %eax,%edi
  801fd2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801fd4:	a1 00 40 80 00       	mov    0x804000,%eax
  801fd9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fdc:	83 ec 0c             	sub    $0xc,%esp
  801fdf:	57                   	push   %edi
  801fe0:	e8 c6 fa ff ff       	call   801aab <pageref>
  801fe5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801fe8:	89 34 24             	mov    %esi,(%esp)
  801feb:	e8 bb fa ff ff       	call   801aab <pageref>
		nn = thisenv->env_runs;
  801ff0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ff6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ff9:	83 c4 10             	add    $0x10,%esp
  801ffc:	39 cb                	cmp    %ecx,%ebx
  801ffe:	74 1b                	je     80201b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802000:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802003:	75 cf                	jne    801fd4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802005:	8b 42 58             	mov    0x58(%edx),%eax
  802008:	6a 01                	push   $0x1
  80200a:	50                   	push   %eax
  80200b:	53                   	push   %ebx
  80200c:	68 3b 2d 80 00       	push   $0x802d3b
  802011:	e8 13 e3 ff ff       	call   800329 <cprintf>
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	eb b9                	jmp    801fd4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80201b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80201e:	0f 94 c0             	sete   %al
  802021:	0f b6 c0             	movzbl %al,%eax
}
  802024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802027:	5b                   	pop    %ebx
  802028:	5e                   	pop    %esi
  802029:	5f                   	pop    %edi
  80202a:	5d                   	pop    %ebp
  80202b:	c3                   	ret    

0080202c <devpipe_write>:
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	57                   	push   %edi
  802030:	56                   	push   %esi
  802031:	53                   	push   %ebx
  802032:	83 ec 28             	sub    $0x28,%esp
  802035:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802038:	56                   	push   %esi
  802039:	e8 95 f2 ff ff       	call   8012d3 <fd2data>
  80203e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802040:	83 c4 10             	add    $0x10,%esp
  802043:	bf 00 00 00 00       	mov    $0x0,%edi
  802048:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80204b:	75 09                	jne    802056 <devpipe_write+0x2a>
	return i;
  80204d:	89 f8                	mov    %edi,%eax
  80204f:	eb 23                	jmp    802074 <devpipe_write+0x48>
			sys_yield();
  802051:	e8 8a ec ff ff       	call   800ce0 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802056:	8b 43 04             	mov    0x4(%ebx),%eax
  802059:	8b 0b                	mov    (%ebx),%ecx
  80205b:	8d 51 20             	lea    0x20(%ecx),%edx
  80205e:	39 d0                	cmp    %edx,%eax
  802060:	72 1a                	jb     80207c <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802062:	89 da                	mov    %ebx,%edx
  802064:	89 f0                	mov    %esi,%eax
  802066:	e8 5c ff ff ff       	call   801fc7 <_pipeisclosed>
  80206b:	85 c0                	test   %eax,%eax
  80206d:	74 e2                	je     802051 <devpipe_write+0x25>
				return 0;
  80206f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802074:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802077:	5b                   	pop    %ebx
  802078:	5e                   	pop    %esi
  802079:	5f                   	pop    %edi
  80207a:	5d                   	pop    %ebp
  80207b:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80207c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80207f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802083:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802086:	89 c2                	mov    %eax,%edx
  802088:	c1 fa 1f             	sar    $0x1f,%edx
  80208b:	89 d1                	mov    %edx,%ecx
  80208d:	c1 e9 1b             	shr    $0x1b,%ecx
  802090:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802093:	83 e2 1f             	and    $0x1f,%edx
  802096:	29 ca                	sub    %ecx,%edx
  802098:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80209c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020a0:	83 c0 01             	add    $0x1,%eax
  8020a3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8020a6:	83 c7 01             	add    $0x1,%edi
  8020a9:	eb 9d                	jmp    802048 <devpipe_write+0x1c>

008020ab <devpipe_read>:
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	57                   	push   %edi
  8020af:	56                   	push   %esi
  8020b0:	53                   	push   %ebx
  8020b1:	83 ec 18             	sub    $0x18,%esp
  8020b4:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8020b7:	57                   	push   %edi
  8020b8:	e8 16 f2 ff ff       	call   8012d3 <fd2data>
  8020bd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	be 00 00 00 00       	mov    $0x0,%esi
  8020c7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020ca:	75 13                	jne    8020df <devpipe_read+0x34>
	return i;
  8020cc:	89 f0                	mov    %esi,%eax
  8020ce:	eb 02                	jmp    8020d2 <devpipe_read+0x27>
				return i;
  8020d0:	89 f0                	mov    %esi,%eax
}
  8020d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d5:	5b                   	pop    %ebx
  8020d6:	5e                   	pop    %esi
  8020d7:	5f                   	pop    %edi
  8020d8:	5d                   	pop    %ebp
  8020d9:	c3                   	ret    
			sys_yield();
  8020da:	e8 01 ec ff ff       	call   800ce0 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8020df:	8b 03                	mov    (%ebx),%eax
  8020e1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020e4:	75 18                	jne    8020fe <devpipe_read+0x53>
			if (i > 0)
  8020e6:	85 f6                	test   %esi,%esi
  8020e8:	75 e6                	jne    8020d0 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8020ea:	89 da                	mov    %ebx,%edx
  8020ec:	89 f8                	mov    %edi,%eax
  8020ee:	e8 d4 fe ff ff       	call   801fc7 <_pipeisclosed>
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	74 e3                	je     8020da <devpipe_read+0x2f>
				return 0;
  8020f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8020fc:	eb d4                	jmp    8020d2 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020fe:	99                   	cltd   
  8020ff:	c1 ea 1b             	shr    $0x1b,%edx
  802102:	01 d0                	add    %edx,%eax
  802104:	83 e0 1f             	and    $0x1f,%eax
  802107:	29 d0                	sub    %edx,%eax
  802109:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80210e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802111:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802114:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802117:	83 c6 01             	add    $0x1,%esi
  80211a:	eb ab                	jmp    8020c7 <devpipe_read+0x1c>

0080211c <pipe>:
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	56                   	push   %esi
  802120:	53                   	push   %ebx
  802121:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802124:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802127:	50                   	push   %eax
  802128:	e8 bd f1 ff ff       	call   8012ea <fd_alloc>
  80212d:	89 c3                	mov    %eax,%ebx
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	85 c0                	test   %eax,%eax
  802134:	0f 88 23 01 00 00    	js     80225d <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80213a:	83 ec 04             	sub    $0x4,%esp
  80213d:	68 07 04 00 00       	push   $0x407
  802142:	ff 75 f4             	push   -0xc(%ebp)
  802145:	6a 00                	push   $0x0
  802147:	e8 b3 eb ff ff       	call   800cff <sys_page_alloc>
  80214c:	89 c3                	mov    %eax,%ebx
  80214e:	83 c4 10             	add    $0x10,%esp
  802151:	85 c0                	test   %eax,%eax
  802153:	0f 88 04 01 00 00    	js     80225d <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802159:	83 ec 0c             	sub    $0xc,%esp
  80215c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80215f:	50                   	push   %eax
  802160:	e8 85 f1 ff ff       	call   8012ea <fd_alloc>
  802165:	89 c3                	mov    %eax,%ebx
  802167:	83 c4 10             	add    $0x10,%esp
  80216a:	85 c0                	test   %eax,%eax
  80216c:	0f 88 db 00 00 00    	js     80224d <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802172:	83 ec 04             	sub    $0x4,%esp
  802175:	68 07 04 00 00       	push   $0x407
  80217a:	ff 75 f0             	push   -0x10(%ebp)
  80217d:	6a 00                	push   $0x0
  80217f:	e8 7b eb ff ff       	call   800cff <sys_page_alloc>
  802184:	89 c3                	mov    %eax,%ebx
  802186:	83 c4 10             	add    $0x10,%esp
  802189:	85 c0                	test   %eax,%eax
  80218b:	0f 88 bc 00 00 00    	js     80224d <pipe+0x131>
	va = fd2data(fd0);
  802191:	83 ec 0c             	sub    $0xc,%esp
  802194:	ff 75 f4             	push   -0xc(%ebp)
  802197:	e8 37 f1 ff ff       	call   8012d3 <fd2data>
  80219c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80219e:	83 c4 0c             	add    $0xc,%esp
  8021a1:	68 07 04 00 00       	push   $0x407
  8021a6:	50                   	push   %eax
  8021a7:	6a 00                	push   $0x0
  8021a9:	e8 51 eb ff ff       	call   800cff <sys_page_alloc>
  8021ae:	89 c3                	mov    %eax,%ebx
  8021b0:	83 c4 10             	add    $0x10,%esp
  8021b3:	85 c0                	test   %eax,%eax
  8021b5:	0f 88 82 00 00 00    	js     80223d <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021bb:	83 ec 0c             	sub    $0xc,%esp
  8021be:	ff 75 f0             	push   -0x10(%ebp)
  8021c1:	e8 0d f1 ff ff       	call   8012d3 <fd2data>
  8021c6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021cd:	50                   	push   %eax
  8021ce:	6a 00                	push   $0x0
  8021d0:	56                   	push   %esi
  8021d1:	6a 00                	push   $0x0
  8021d3:	e8 6a eb ff ff       	call   800d42 <sys_page_map>
  8021d8:	89 c3                	mov    %eax,%ebx
  8021da:	83 c4 20             	add    $0x20,%esp
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	78 4e                	js     80222f <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8021e1:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8021e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021e9:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8021eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021ee:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8021f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021f8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8021fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021fd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802204:	83 ec 0c             	sub    $0xc,%esp
  802207:	ff 75 f4             	push   -0xc(%ebp)
  80220a:	e8 b4 f0 ff ff       	call   8012c3 <fd2num>
  80220f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802212:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802214:	83 c4 04             	add    $0x4,%esp
  802217:	ff 75 f0             	push   -0x10(%ebp)
  80221a:	e8 a4 f0 ff ff       	call   8012c3 <fd2num>
  80221f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802222:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802225:	83 c4 10             	add    $0x10,%esp
  802228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80222d:	eb 2e                	jmp    80225d <pipe+0x141>
	sys_page_unmap(0, va);
  80222f:	83 ec 08             	sub    $0x8,%esp
  802232:	56                   	push   %esi
  802233:	6a 00                	push   $0x0
  802235:	e8 4a eb ff ff       	call   800d84 <sys_page_unmap>
  80223a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80223d:	83 ec 08             	sub    $0x8,%esp
  802240:	ff 75 f0             	push   -0x10(%ebp)
  802243:	6a 00                	push   $0x0
  802245:	e8 3a eb ff ff       	call   800d84 <sys_page_unmap>
  80224a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80224d:	83 ec 08             	sub    $0x8,%esp
  802250:	ff 75 f4             	push   -0xc(%ebp)
  802253:	6a 00                	push   $0x0
  802255:	e8 2a eb ff ff       	call   800d84 <sys_page_unmap>
  80225a:	83 c4 10             	add    $0x10,%esp
}
  80225d:	89 d8                	mov    %ebx,%eax
  80225f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802262:	5b                   	pop    %ebx
  802263:	5e                   	pop    %esi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <pipeisclosed>:
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80226c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80226f:	50                   	push   %eax
  802270:	ff 75 08             	push   0x8(%ebp)
  802273:	e8 c2 f0 ff ff       	call   80133a <fd_lookup>
  802278:	83 c4 10             	add    $0x10,%esp
  80227b:	85 c0                	test   %eax,%eax
  80227d:	78 18                	js     802297 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80227f:	83 ec 0c             	sub    $0xc,%esp
  802282:	ff 75 f4             	push   -0xc(%ebp)
  802285:	e8 49 f0 ff ff       	call   8012d3 <fd2data>
  80228a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80228c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228f:	e8 33 fd ff ff       	call   801fc7 <_pipeisclosed>
  802294:	83 c4 10             	add    $0x10,%esp
}
  802297:	c9                   	leave  
  802298:	c3                   	ret    

00802299 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802299:	b8 00 00 00 00       	mov    $0x0,%eax
  80229e:	c3                   	ret    

0080229f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022a5:	68 53 2d 80 00       	push   $0x802d53
  8022aa:	ff 75 0c             	push   0xc(%ebp)
  8022ad:	e8 51 e6 ff ff       	call   800903 <strcpy>
	return 0;
}
  8022b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b7:	c9                   	leave  
  8022b8:	c3                   	ret    

008022b9 <devcons_write>:
{
  8022b9:	55                   	push   %ebp
  8022ba:	89 e5                	mov    %esp,%ebp
  8022bc:	57                   	push   %edi
  8022bd:	56                   	push   %esi
  8022be:	53                   	push   %ebx
  8022bf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8022c5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022ca:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022d0:	eb 2e                	jmp    802300 <devcons_write+0x47>
		m = n - tot;
  8022d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022d5:	29 f3                	sub    %esi,%ebx
  8022d7:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8022dc:	39 c3                	cmp    %eax,%ebx
  8022de:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022e1:	83 ec 04             	sub    $0x4,%esp
  8022e4:	53                   	push   %ebx
  8022e5:	89 f0                	mov    %esi,%eax
  8022e7:	03 45 0c             	add    0xc(%ebp),%eax
  8022ea:	50                   	push   %eax
  8022eb:	57                   	push   %edi
  8022ec:	e8 a8 e7 ff ff       	call   800a99 <memmove>
		sys_cputs(buf, m);
  8022f1:	83 c4 08             	add    $0x8,%esp
  8022f4:	53                   	push   %ebx
  8022f5:	57                   	push   %edi
  8022f6:	e8 48 e9 ff ff       	call   800c43 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8022fb:	01 de                	add    %ebx,%esi
  8022fd:	83 c4 10             	add    $0x10,%esp
  802300:	3b 75 10             	cmp    0x10(%ebp),%esi
  802303:	72 cd                	jb     8022d2 <devcons_write+0x19>
}
  802305:	89 f0                	mov    %esi,%eax
  802307:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80230a:	5b                   	pop    %ebx
  80230b:	5e                   	pop    %esi
  80230c:	5f                   	pop    %edi
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    

0080230f <devcons_read>:
{
  80230f:	55                   	push   %ebp
  802310:	89 e5                	mov    %esp,%ebp
  802312:	83 ec 08             	sub    $0x8,%esp
  802315:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80231a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80231e:	75 07                	jne    802327 <devcons_read+0x18>
  802320:	eb 1f                	jmp    802341 <devcons_read+0x32>
		sys_yield();
  802322:	e8 b9 e9 ff ff       	call   800ce0 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802327:	e8 35 e9 ff ff       	call   800c61 <sys_cgetc>
  80232c:	85 c0                	test   %eax,%eax
  80232e:	74 f2                	je     802322 <devcons_read+0x13>
	if (c < 0)
  802330:	78 0f                	js     802341 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802332:	83 f8 04             	cmp    $0x4,%eax
  802335:	74 0c                	je     802343 <devcons_read+0x34>
	*(char*)vbuf = c;
  802337:	8b 55 0c             	mov    0xc(%ebp),%edx
  80233a:	88 02                	mov    %al,(%edx)
	return 1;
  80233c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802341:	c9                   	leave  
  802342:	c3                   	ret    
		return 0;
  802343:	b8 00 00 00 00       	mov    $0x0,%eax
  802348:	eb f7                	jmp    802341 <devcons_read+0x32>

0080234a <cputchar>:
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802350:	8b 45 08             	mov    0x8(%ebp),%eax
  802353:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802356:	6a 01                	push   $0x1
  802358:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80235b:	50                   	push   %eax
  80235c:	e8 e2 e8 ff ff       	call   800c43 <sys_cputs>
}
  802361:	83 c4 10             	add    $0x10,%esp
  802364:	c9                   	leave  
  802365:	c3                   	ret    

00802366 <getchar>:
{
  802366:	55                   	push   %ebp
  802367:	89 e5                	mov    %esp,%ebp
  802369:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80236c:	6a 01                	push   $0x1
  80236e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802371:	50                   	push   %eax
  802372:	6a 00                	push   $0x0
  802374:	e8 2a f2 ff ff       	call   8015a3 <read>
	if (r < 0)
  802379:	83 c4 10             	add    $0x10,%esp
  80237c:	85 c0                	test   %eax,%eax
  80237e:	78 06                	js     802386 <getchar+0x20>
	if (r < 1)
  802380:	74 06                	je     802388 <getchar+0x22>
	return c;
  802382:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802386:	c9                   	leave  
  802387:	c3                   	ret    
		return -E_EOF;
  802388:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80238d:	eb f7                	jmp    802386 <getchar+0x20>

0080238f <iscons>:
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802398:	50                   	push   %eax
  802399:	ff 75 08             	push   0x8(%ebp)
  80239c:	e8 99 ef ff ff       	call   80133a <fd_lookup>
  8023a1:	83 c4 10             	add    $0x10,%esp
  8023a4:	85 c0                	test   %eax,%eax
  8023a6:	78 11                	js     8023b9 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8023a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ab:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023b1:	39 10                	cmp    %edx,(%eax)
  8023b3:	0f 94 c0             	sete   %al
  8023b6:	0f b6 c0             	movzbl %al,%eax
}
  8023b9:	c9                   	leave  
  8023ba:	c3                   	ret    

008023bb <opencons>:
{
  8023bb:	55                   	push   %ebp
  8023bc:	89 e5                	mov    %esp,%ebp
  8023be:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c4:	50                   	push   %eax
  8023c5:	e8 20 ef ff ff       	call   8012ea <fd_alloc>
  8023ca:	83 c4 10             	add    $0x10,%esp
  8023cd:	85 c0                	test   %eax,%eax
  8023cf:	78 3a                	js     80240b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023d1:	83 ec 04             	sub    $0x4,%esp
  8023d4:	68 07 04 00 00       	push   $0x407
  8023d9:	ff 75 f4             	push   -0xc(%ebp)
  8023dc:	6a 00                	push   $0x0
  8023de:	e8 1c e9 ff ff       	call   800cff <sys_page_alloc>
  8023e3:	83 c4 10             	add    $0x10,%esp
  8023e6:	85 c0                	test   %eax,%eax
  8023e8:	78 21                	js     80240b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8023ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ed:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023f3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023ff:	83 ec 0c             	sub    $0xc,%esp
  802402:	50                   	push   %eax
  802403:	e8 bb ee ff ff       	call   8012c3 <fd2num>
  802408:	83 c4 10             	add    $0x10,%esp
}
  80240b:	c9                   	leave  
  80240c:	c3                   	ret    

0080240d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802413:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  80241a:	74 0a                	je     802426 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80241c:	8b 45 08             	mov    0x8(%ebp),%eax
  80241f:	a3 04 80 80 00       	mov    %eax,0x808004
}
  802424:	c9                   	leave  
  802425:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802426:	e8 96 e8 ff ff       	call   800cc1 <sys_getenvid>
  80242b:	83 ec 04             	sub    $0x4,%esp
  80242e:	68 07 0e 00 00       	push   $0xe07
  802433:	68 00 f0 bf ee       	push   $0xeebff000
  802438:	50                   	push   %eax
  802439:	e8 c1 e8 ff ff       	call   800cff <sys_page_alloc>
		if (r < 0) {
  80243e:	83 c4 10             	add    $0x10,%esp
  802441:	85 c0                	test   %eax,%eax
  802443:	78 2c                	js     802471 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802445:	e8 77 e8 ff ff       	call   800cc1 <sys_getenvid>
  80244a:	83 ec 08             	sub    $0x8,%esp
  80244d:	68 83 24 80 00       	push   $0x802483
  802452:	50                   	push   %eax
  802453:	e8 f2 e9 ff ff       	call   800e4a <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802458:	83 c4 10             	add    $0x10,%esp
  80245b:	85 c0                	test   %eax,%eax
  80245d:	79 bd                	jns    80241c <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80245f:	50                   	push   %eax
  802460:	68 a0 2d 80 00       	push   $0x802da0
  802465:	6a 28                	push   $0x28
  802467:	68 d6 2d 80 00       	push   $0x802dd6
  80246c:	e8 dd dd ff ff       	call   80024e <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802471:	50                   	push   %eax
  802472:	68 60 2d 80 00       	push   $0x802d60
  802477:	6a 23                	push   $0x23
  802479:	68 d6 2d 80 00       	push   $0x802dd6
  80247e:	e8 cb dd ff ff       	call   80024e <_panic>

00802483 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802483:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802484:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802489:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80248b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80248e:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802492:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802495:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802499:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80249d:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80249f:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8024a2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8024a3:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8024a6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8024a7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8024a8:	c3                   	ret    
  8024a9:	66 90                	xchg   %ax,%ax
  8024ab:	66 90                	xchg   %ax,%ax
  8024ad:	66 90                	xchg   %ax,%ax
  8024af:	90                   	nop

008024b0 <__udivdi3>:
  8024b0:	f3 0f 1e fb          	endbr32 
  8024b4:	55                   	push   %ebp
  8024b5:	57                   	push   %edi
  8024b6:	56                   	push   %esi
  8024b7:	53                   	push   %ebx
  8024b8:	83 ec 1c             	sub    $0x1c,%esp
  8024bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024cb:	85 c0                	test   %eax,%eax
  8024cd:	75 19                	jne    8024e8 <__udivdi3+0x38>
  8024cf:	39 f3                	cmp    %esi,%ebx
  8024d1:	76 4d                	jbe    802520 <__udivdi3+0x70>
  8024d3:	31 ff                	xor    %edi,%edi
  8024d5:	89 e8                	mov    %ebp,%eax
  8024d7:	89 f2                	mov    %esi,%edx
  8024d9:	f7 f3                	div    %ebx
  8024db:	89 fa                	mov    %edi,%edx
  8024dd:	83 c4 1c             	add    $0x1c,%esp
  8024e0:	5b                   	pop    %ebx
  8024e1:	5e                   	pop    %esi
  8024e2:	5f                   	pop    %edi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    
  8024e5:	8d 76 00             	lea    0x0(%esi),%esi
  8024e8:	39 f0                	cmp    %esi,%eax
  8024ea:	76 14                	jbe    802500 <__udivdi3+0x50>
  8024ec:	31 ff                	xor    %edi,%edi
  8024ee:	31 c0                	xor    %eax,%eax
  8024f0:	89 fa                	mov    %edi,%edx
  8024f2:	83 c4 1c             	add    $0x1c,%esp
  8024f5:	5b                   	pop    %ebx
  8024f6:	5e                   	pop    %esi
  8024f7:	5f                   	pop    %edi
  8024f8:	5d                   	pop    %ebp
  8024f9:	c3                   	ret    
  8024fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802500:	0f bd f8             	bsr    %eax,%edi
  802503:	83 f7 1f             	xor    $0x1f,%edi
  802506:	75 48                	jne    802550 <__udivdi3+0xa0>
  802508:	39 f0                	cmp    %esi,%eax
  80250a:	72 06                	jb     802512 <__udivdi3+0x62>
  80250c:	31 c0                	xor    %eax,%eax
  80250e:	39 eb                	cmp    %ebp,%ebx
  802510:	77 de                	ja     8024f0 <__udivdi3+0x40>
  802512:	b8 01 00 00 00       	mov    $0x1,%eax
  802517:	eb d7                	jmp    8024f0 <__udivdi3+0x40>
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 d9                	mov    %ebx,%ecx
  802522:	85 db                	test   %ebx,%ebx
  802524:	75 0b                	jne    802531 <__udivdi3+0x81>
  802526:	b8 01 00 00 00       	mov    $0x1,%eax
  80252b:	31 d2                	xor    %edx,%edx
  80252d:	f7 f3                	div    %ebx
  80252f:	89 c1                	mov    %eax,%ecx
  802531:	31 d2                	xor    %edx,%edx
  802533:	89 f0                	mov    %esi,%eax
  802535:	f7 f1                	div    %ecx
  802537:	89 c6                	mov    %eax,%esi
  802539:	89 e8                	mov    %ebp,%eax
  80253b:	89 f7                	mov    %esi,%edi
  80253d:	f7 f1                	div    %ecx
  80253f:	89 fa                	mov    %edi,%edx
  802541:	83 c4 1c             	add    $0x1c,%esp
  802544:	5b                   	pop    %ebx
  802545:	5e                   	pop    %esi
  802546:	5f                   	pop    %edi
  802547:	5d                   	pop    %ebp
  802548:	c3                   	ret    
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	89 f9                	mov    %edi,%ecx
  802552:	ba 20 00 00 00       	mov    $0x20,%edx
  802557:	29 fa                	sub    %edi,%edx
  802559:	d3 e0                	shl    %cl,%eax
  80255b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80255f:	89 d1                	mov    %edx,%ecx
  802561:	89 d8                	mov    %ebx,%eax
  802563:	d3 e8                	shr    %cl,%eax
  802565:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802569:	09 c1                	or     %eax,%ecx
  80256b:	89 f0                	mov    %esi,%eax
  80256d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802571:	89 f9                	mov    %edi,%ecx
  802573:	d3 e3                	shl    %cl,%ebx
  802575:	89 d1                	mov    %edx,%ecx
  802577:	d3 e8                	shr    %cl,%eax
  802579:	89 f9                	mov    %edi,%ecx
  80257b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80257f:	89 eb                	mov    %ebp,%ebx
  802581:	d3 e6                	shl    %cl,%esi
  802583:	89 d1                	mov    %edx,%ecx
  802585:	d3 eb                	shr    %cl,%ebx
  802587:	09 f3                	or     %esi,%ebx
  802589:	89 c6                	mov    %eax,%esi
  80258b:	89 f2                	mov    %esi,%edx
  80258d:	89 d8                	mov    %ebx,%eax
  80258f:	f7 74 24 08          	divl   0x8(%esp)
  802593:	89 d6                	mov    %edx,%esi
  802595:	89 c3                	mov    %eax,%ebx
  802597:	f7 64 24 0c          	mull   0xc(%esp)
  80259b:	39 d6                	cmp    %edx,%esi
  80259d:	72 19                	jb     8025b8 <__udivdi3+0x108>
  80259f:	89 f9                	mov    %edi,%ecx
  8025a1:	d3 e5                	shl    %cl,%ebp
  8025a3:	39 c5                	cmp    %eax,%ebp
  8025a5:	73 04                	jae    8025ab <__udivdi3+0xfb>
  8025a7:	39 d6                	cmp    %edx,%esi
  8025a9:	74 0d                	je     8025b8 <__udivdi3+0x108>
  8025ab:	89 d8                	mov    %ebx,%eax
  8025ad:	31 ff                	xor    %edi,%edi
  8025af:	e9 3c ff ff ff       	jmp    8024f0 <__udivdi3+0x40>
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025bb:	31 ff                	xor    %edi,%edi
  8025bd:	e9 2e ff ff ff       	jmp    8024f0 <__udivdi3+0x40>
  8025c2:	66 90                	xchg   %ax,%ax
  8025c4:	66 90                	xchg   %ax,%ax
  8025c6:	66 90                	xchg   %ax,%ax
  8025c8:	66 90                	xchg   %ax,%ax
  8025ca:	66 90                	xchg   %ax,%ax
  8025cc:	66 90                	xchg   %ax,%ax
  8025ce:	66 90                	xchg   %ax,%ax

008025d0 <__umoddi3>:
  8025d0:	f3 0f 1e fb          	endbr32 
  8025d4:	55                   	push   %ebp
  8025d5:	57                   	push   %edi
  8025d6:	56                   	push   %esi
  8025d7:	53                   	push   %ebx
  8025d8:	83 ec 1c             	sub    $0x1c,%esp
  8025db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025e3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8025e7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8025eb:	89 f0                	mov    %esi,%eax
  8025ed:	89 da                	mov    %ebx,%edx
  8025ef:	85 ff                	test   %edi,%edi
  8025f1:	75 15                	jne    802608 <__umoddi3+0x38>
  8025f3:	39 dd                	cmp    %ebx,%ebp
  8025f5:	76 39                	jbe    802630 <__umoddi3+0x60>
  8025f7:	f7 f5                	div    %ebp
  8025f9:	89 d0                	mov    %edx,%eax
  8025fb:	31 d2                	xor    %edx,%edx
  8025fd:	83 c4 1c             	add    $0x1c,%esp
  802600:	5b                   	pop    %ebx
  802601:	5e                   	pop    %esi
  802602:	5f                   	pop    %edi
  802603:	5d                   	pop    %ebp
  802604:	c3                   	ret    
  802605:	8d 76 00             	lea    0x0(%esi),%esi
  802608:	39 df                	cmp    %ebx,%edi
  80260a:	77 f1                	ja     8025fd <__umoddi3+0x2d>
  80260c:	0f bd cf             	bsr    %edi,%ecx
  80260f:	83 f1 1f             	xor    $0x1f,%ecx
  802612:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802616:	75 40                	jne    802658 <__umoddi3+0x88>
  802618:	39 df                	cmp    %ebx,%edi
  80261a:	72 04                	jb     802620 <__umoddi3+0x50>
  80261c:	39 f5                	cmp    %esi,%ebp
  80261e:	77 dd                	ja     8025fd <__umoddi3+0x2d>
  802620:	89 da                	mov    %ebx,%edx
  802622:	89 f0                	mov    %esi,%eax
  802624:	29 e8                	sub    %ebp,%eax
  802626:	19 fa                	sbb    %edi,%edx
  802628:	eb d3                	jmp    8025fd <__umoddi3+0x2d>
  80262a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802630:	89 e9                	mov    %ebp,%ecx
  802632:	85 ed                	test   %ebp,%ebp
  802634:	75 0b                	jne    802641 <__umoddi3+0x71>
  802636:	b8 01 00 00 00       	mov    $0x1,%eax
  80263b:	31 d2                	xor    %edx,%edx
  80263d:	f7 f5                	div    %ebp
  80263f:	89 c1                	mov    %eax,%ecx
  802641:	89 d8                	mov    %ebx,%eax
  802643:	31 d2                	xor    %edx,%edx
  802645:	f7 f1                	div    %ecx
  802647:	89 f0                	mov    %esi,%eax
  802649:	f7 f1                	div    %ecx
  80264b:	89 d0                	mov    %edx,%eax
  80264d:	31 d2                	xor    %edx,%edx
  80264f:	eb ac                	jmp    8025fd <__umoddi3+0x2d>
  802651:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802658:	8b 44 24 04          	mov    0x4(%esp),%eax
  80265c:	ba 20 00 00 00       	mov    $0x20,%edx
  802661:	29 c2                	sub    %eax,%edx
  802663:	89 c1                	mov    %eax,%ecx
  802665:	89 e8                	mov    %ebp,%eax
  802667:	d3 e7                	shl    %cl,%edi
  802669:	89 d1                	mov    %edx,%ecx
  80266b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80266f:	d3 e8                	shr    %cl,%eax
  802671:	89 c1                	mov    %eax,%ecx
  802673:	8b 44 24 04          	mov    0x4(%esp),%eax
  802677:	09 f9                	or     %edi,%ecx
  802679:	89 df                	mov    %ebx,%edi
  80267b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80267f:	89 c1                	mov    %eax,%ecx
  802681:	d3 e5                	shl    %cl,%ebp
  802683:	89 d1                	mov    %edx,%ecx
  802685:	d3 ef                	shr    %cl,%edi
  802687:	89 c1                	mov    %eax,%ecx
  802689:	89 f0                	mov    %esi,%eax
  80268b:	d3 e3                	shl    %cl,%ebx
  80268d:	89 d1                	mov    %edx,%ecx
  80268f:	89 fa                	mov    %edi,%edx
  802691:	d3 e8                	shr    %cl,%eax
  802693:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802698:	09 d8                	or     %ebx,%eax
  80269a:	f7 74 24 08          	divl   0x8(%esp)
  80269e:	89 d3                	mov    %edx,%ebx
  8026a0:	d3 e6                	shl    %cl,%esi
  8026a2:	f7 e5                	mul    %ebp
  8026a4:	89 c7                	mov    %eax,%edi
  8026a6:	89 d1                	mov    %edx,%ecx
  8026a8:	39 d3                	cmp    %edx,%ebx
  8026aa:	72 06                	jb     8026b2 <__umoddi3+0xe2>
  8026ac:	75 0e                	jne    8026bc <__umoddi3+0xec>
  8026ae:	39 c6                	cmp    %eax,%esi
  8026b0:	73 0a                	jae    8026bc <__umoddi3+0xec>
  8026b2:	29 e8                	sub    %ebp,%eax
  8026b4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026b8:	89 d1                	mov    %edx,%ecx
  8026ba:	89 c7                	mov    %eax,%edi
  8026bc:	89 f5                	mov    %esi,%ebp
  8026be:	8b 74 24 04          	mov    0x4(%esp),%esi
  8026c2:	29 fd                	sub    %edi,%ebp
  8026c4:	19 cb                	sbb    %ecx,%ebx
  8026c6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8026cb:	89 d8                	mov    %ebx,%eax
  8026cd:	d3 e0                	shl    %cl,%eax
  8026cf:	89 f1                	mov    %esi,%ecx
  8026d1:	d3 ed                	shr    %cl,%ebp
  8026d3:	d3 eb                	shr    %cl,%ebx
  8026d5:	09 e8                	or     %ebp,%eax
  8026d7:	89 da                	mov    %ebx,%edx
  8026d9:	83 c4 1c             	add    $0x1c,%esp
  8026dc:	5b                   	pop    %ebx
  8026dd:	5e                   	pop    %esi
  8026de:	5f                   	pop    %edi
  8026df:	5d                   	pop    %ebp
  8026e0:	c3                   	ret    
